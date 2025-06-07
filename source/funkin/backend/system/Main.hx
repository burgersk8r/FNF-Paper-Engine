package funkin.backend.system;

#if android
import android.content.Context;
#end

import funkin.backend.system.framerate.FPSCounter;
import funkin.backend.system.FunkinSoundTray;
import flixel.graphics.FlxGraphic;
import flixel.FlxGame;
import flixel.FlxState;
import haxe.io.Path;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import lime.app.Application;
import funkin.menus.TitleState;
import funkin.data.Highscore;

#if linux
import lime.graphics.Image;
#end

#if LUA_ALLOWED
import funkin.backend.scripting.lua.CallbackHandler;
#end
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;

//crash handler stuff
#if CRASH_HANDLER
import haxe.io.Path;
#end

#if DARK_MODE_WINDOW
import funkin.backend.system.windows.DarkMode;
#end

#if linux
@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('
	#define GAMEMODE_AUTO
')
#end

class Main extends Sprite
{
	public static final releaseCycle:String = "Beta";

	public static final game = {
		width: 1280, // WINDOW width
		height: 720, // WINDOW height
		initialState: TitleState, // initial game state
		zoom: -1.0, // game state bounds
		framerate: 60, // default framerate
		skipSplash: true, // if the default flixel splash screen should be skipped
		startFullscreen: false // if the game should start at fullscreen mode
	};

	public static var fpsVar:FPSCounter;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		#if DARK_MODE_WINDOW
		DarkMode.setDarkMode(Lib.current.stage.application.window.title, true); // changing the window color to dark if dark mode is enabled through the users windows settings
		#end

		#if android
		Sys.setCwd(Path.addTrailingSlash(Context.getExternalFilesDir()));
		#elseif ios
		Sys.setCwd(lime.system.System.applicationStorageDirectory);
		#end

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (game.zoom == -1.0)
		{
			var ratioX:Float = stageWidth / game.width;
			var ratioY:Float = stageHeight / game.height;
			game.zoom = Math.min(ratioX, ratioY);
			game.width = Math.ceil(stageWidth / game.zoom);
			game.height = Math.ceil(stageHeight / game.zoom);
		}
	
		#if LUA_ALLOWED Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(CallbackHandler.call)); #end
		Controls.instance = new Controls();
		ClientPrefs.loadDefaultKeys();

		FlxG.save.bind('paper-engine', CoolUtil.getSavePath());
		Highscore.load();

		var game:FlxGame = new FlxGame(game.width, game.height, game.initialState, #if (flixel < "5.0.0") game.zoom, #end game.framerate, game.framerate, game.skipSplash, game.startFullscreen);
		@:privateAccess
		game._customSoundTray = FunkinSoundTray;
		addChild(game);

		#if !mobile
		fpsVar = new FPSCounter(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		if(fpsVar != null) {
			fpsVar.visible = ClientPrefs.data.showFPS;
		}
		#end

		#if linux
		var icon = Image.fromFile("icon.png");
		Lib.current.stage.window.setIcon(icon);
		#end

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end
		
		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#elseif html5
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
		#end

		#if DISCORD_ALLOWED
		DiscordClient.prepare();
		#end

		// shader coords fix
		FlxG.signals.gameResized.add(function (w, h) {
		     if (FlxG.cameras != null) {
			   for (cam in FlxG.cameras.list) {
				if (cam != null && cam.filters != null)
					resetSpriteCache(cam.flashSprite);
			   }
			}

			if (FlxG.game != null)
			resetSpriteCache(FlxG.game);
		});
	}

	static function resetSpriteCache(sprite:Sprite):Void {
		@:privateAccess {
		        sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}

	// Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!
	// very cool person for real they don't get enough credit for their work
	#if CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = "./crash/" + "PaperEngine_" + dateNow + ".txt";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error + "\nPlease report this error to the GitHub page: https://github.com/paigefnf/FNF-Paper-Engine\n\n> Crash Handler written by: sqirra-rng";

		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		Application.current.window.alert(errMsg, "Error!");
		#if DISCORD_ALLOWED
		DiscordClient.shutdown();
		#end
		Sys.exit(1);
	}
	#end
	//RIPPED STRAIGHT FROM DOIDO ENGINE FOR BETTER CRASH HANDLING!!!!
	//WILL BE REMOVED ONCE HTML5 IS MORE STABLE!!
	function onUncaughtError(e:UncaughtErrorEvent):Void
	{
		e.preventDefault();
		e.stopImmediatePropagation();

		var path:String;
		var exception:String = 'Exception: ${e.error}\n';
		var stackTraceString = exception + StringTools.trim(CallStack.toString(CallStack.exceptionStack(true)));
		var dateNow:String = Date.now().toString().replace(" ", "_").replace(":", "'");

		path = 'crash/DoidoEngine_${dateNow}.txt';

		#if sys
		if (!FileSystem.exists("crash/"))
			FileSystem.createDirectory("crash/");
		File.saveContent(path, '${stackTraceString}\n');
		#end

		var normalPath:String = Path.normalize(path);

		//Logs.print(stackTraceString, ERROR, true, true, false, false);
		//Logs.print('Crash dump saved in $normalPath', WARNING, true, true, false, false);

		// byebye
		#if (flixel < "6.0.0")
		FlxG.bitmap.dumpCache();
		#end

		FlxG.bitmap.clearCache();
		//CoolUtil.playMusic();

		//Main.skipTrans = true;
											FlxG.switchState(new CrashHandlerState(stackTraceString + '\n\nCrash log created at: "${normalPath}"'));

	}
}
