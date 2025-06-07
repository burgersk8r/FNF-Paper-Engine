package funkin.menus;

import funkin.backend.Song;
import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import funkin.editors.MasterEditorMenu;
import funkin.options.OptionsState;

enum MainMenuColumn {
	LEFT;
	CENTER;
	RIGHT;
}

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.7.3';
	public static var paperEngineVersion:String = '0.1.0';
	public static var curSelected:Int = 0;
	public static var curColumn:MainMenuColumn = CENTER;
	var allowMouse:Bool = true;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var leftItem:FlxSprite;
	var rightItem:FlxSprite;

	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'merch',
		'credits',
		#if MODS_ALLOWED 'mods' #end
	];

	var leftOption:String = #if ACHIEVEMENTS_ALLOWED 'achievements' #else null #end;
	var rightOption:String = 'options';

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	override function create()
	{
		Paths.clearUnusedMemory();
		
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Main Menu", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var cursor:FlxSprite;

		cursor = new FlxSprite();

		cursor.makeGraphic(15, 15, FlxColor.TRANSPARENT);

		cursor.loadGraphic(Paths.image('game/hud/cursors/cursor'));
		FlxG.mouse.load(cursor.pixels);

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('game/menus/mainmenu/menuBG'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('game/menus/mainmenu/menuBGMagenta'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		add(magenta);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (num => option in optionShit)
			{
				var item:FlxSprite = createMenuItem(option, 0, (num * 140) + 90);
				item.y += (4 - optionShit.length) * 70; // Offsets for when you have anything other than 4 items
				item.screenCenter(X);
			}

		if (leftOption != null)
			leftItem = createMenuItem(leftOption, 60, 490);
		if (rightOption != null)
		{
			rightItem = createMenuItem(rightOption, FlxG.width - 60, 490);
			rightItem.x -= rightItem.width;
		}

		var paperVer:FlxText = new FlxText(12, FlxG.height - 64, 0, "Paper Engine v" + paperEngineVersion, 12);
		paperVer.scrollFactor.set();
		paperVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(paperVer);
		var psychVer:FlxText = new FlxText(12, FlxG.height - 44, 0, "Pysch Engine v" + psychEngineVersion, 12);
		psychVer.scrollFactor.set();
		psychVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(psychVer);
		var funkinVer:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		funkinVer.scrollFactor.set();
		funkinVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(funkinVer);
		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		// Unlocks "Freaky on a Friday Night" achievement if it's a Friday and between 18:00 PM and 23:59 PM
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
			Achievements.unlock('friday_night_play');

		#if MODS_ALLOWED
		Achievements.reloadList();
		#end
		#end

		super.create();

		FlxG.camera.follow(camFollow, null, 9);
	}


	function createMenuItem(name:String, x:Float, y:Float):FlxSprite
		{
			var menuItem:FlxSprite = new FlxSprite(x, y);
			menuItem.frames = Paths.getSparrowAtlas('game/menus/mainmenu/$name');
			menuItem.animation.addByPrefix('idle', '$name idle', 24, true);
			menuItem.animation.addByPrefix('selected', '$name selected', 24, true);
			menuItem.animation.play('idle');
			menuItem.updateHitbox();
			
			menuItem.scrollFactor.set();
			menuItems.add(menuItem);
			return menuItem;
		}
	
	var timeNotMoving:Float = 0;
	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.volume += 0.5 * elapsed;
		}
		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
				changeItem(-1);

			if (controls.UI_DOWN_P)
				changeItem(1);

			var allowMouse:Bool = allowMouse;
			if (allowMouse && ((FlxG.mouse.deltaScreenX != 0 && FlxG.mouse.deltaScreenY != 0) || FlxG.mouse.justPressed)) //FlxG.mouse.deltaScreenX/Y checks is more accurate than FlxG.mouse.justMoved
			{
				allowMouse = false;
				FlxG.mouse.visible = true;
				timeNotMoving = 0;

				var selectedItem:FlxSprite;
				switch(curColumn)
				{
					case CENTER:
						selectedItem = menuItems.members[curSelected];
					case LEFT:
						selectedItem = leftItem;
					case RIGHT:
						selectedItem = rightItem;
				}

				if(leftItem != null && FlxG.mouse.overlaps(leftItem))
				{
					allowMouse = true;
					if(selectedItem != leftItem)
					{
						curColumn = LEFT;
						changeItem();
					}
				}
				else if(rightItem != null && FlxG.mouse.overlaps(rightItem))
				{
					allowMouse = true;
					if(selectedItem != rightItem)
					{
						curColumn = RIGHT;
						changeItem();
					}
				}
				else
				{
					var dist:Float = -1;
					var distItem:Int = -1;
					for (i in 0...optionShit.length)
					{
						var memb:FlxSprite = menuItems.members[i];
						if(FlxG.mouse.overlaps(memb))
						{
							var distance:Float = Math.sqrt(Math.pow(memb.getGraphicMidpoint().x - FlxG.mouse.screenX, 2) + Math.pow(memb.getGraphicMidpoint().y - FlxG.mouse.screenY, 2));
							if (dist < 0 || distance < dist)
							{
								dist = distance;
								distItem = i;
								allowMouse = true;
							}
						}
					}

					if(distItem != -1 && selectedItem != menuItems.members[distItem])
					{
						curColumn = CENTER;
						curSelected = distItem;
						changeItem();
					}
				}
			}
			else
			{
				timeNotMoving += elapsed;
				if(timeNotMoving > 2) FlxG.mouse.visible = false;
			}

			switch(curColumn)
			{
				case CENTER:
					if(controls.UI_LEFT_P && leftOption != null)
					{
						curColumn = LEFT;
						changeItem();
					}
					else if(controls.UI_RIGHT_P && rightOption != null)
					{
						curColumn = RIGHT;
						changeItem();
					}

				case LEFT:
					if(controls.UI_RIGHT_P)
					{
						curColumn = CENTER;
						changeItem();
					}

				case RIGHT:
					if(controls.UI_LEFT_P)
					{
						curColumn = CENTER;
						changeItem();
					}
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('menus/cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT || (FlxG.mouse.justPressed && allowMouse))
			{
				FlxG.sound.play(Paths.sound('menus/confirmMenu'));
				if (optionShit[curSelected] == 'merch')
				{
					CoolUtil.browserLoad('https://needlejuicerecords.com/pages/friday-night-funkin');
				}
				else
				{
					selectedSomethin = true;

					if (ClientPrefs.data.flashing)
						FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					var option:String;
					var item:FlxSprite;

					switch(curColumn)
					{
						case CENTER:
							option = optionShit[curSelected];
							item = menuItems.members[curSelected];
	
						case LEFT:
							option = leftOption;
							item = leftItem;
	
						case RIGHT:
							option = rightOption;
							item = rightItem;
					}

					FlxFlicker.flicker(item, 1, 0.06, false, false, function(flick:FlxFlicker)
						{
							switch (option)
							{
								case 'story_mode':
									FlxG.switchState(new StoryMenuState());
								case 'freeplay':
									FlxG.switchState(new FreeplayState());
		
								#if MODS_ALLOWED
								case 'mods':
									FlxG.switchState(new ModsMenuState());
								#end
		
								#if ACHIEVEMENTS_ALLOWED
								case 'achievements':
									FlxG.switchState(new AchievementsMenuState());
								#end
		
								case 'credits':
									FlxG.switchState(new CreditsState());
								case 'options':
									FlxG.switchState(new OptionsState());
									OptionsState.onPlayState = false;
									if (PlayState.SONG != null)
									{
										PlayState.SONG.arrowSkin = null;
										PlayState.SONG.splashSkin = null;
										PlayState.stageUI = 'normal';
									}
								case 'merch':
									CoolUtil.browserLoad('https://needlejuicerecords.com/pages/friday-night-funkin');
									selectedSomethin = false;
									item.visible = true;
								default:
									trace('Menu Item ${option} doesn\'t do anything');
									selectedSomethin = false;
									item.visible = true;
							}
						});
						
						for (memb in menuItems)
						{
							if(memb == item)
								continue;
		
							FlxTween.tween(memb, {alpha: 0}, 0.4, {ease: FlxEase.quadOut});
						}
					}
					if (FlxG.keys.justPressed.P)
					{
						selectedSomethin = true;
						FlxG.switchState(new MasterEditorMenu());
					}
				}
				super.update(elapsed);
			}
		}
	
	function changeItem(change:Int = 0)
		{
			if(change != 0) curColumn = CENTER;
			curSelected = FlxMath.wrap(curSelected + change, 0, optionShit.length - 1);
			FlxG.sound.play(Paths.sound('menus/scrollMenu'));
	
			for (item in menuItems)
			{
				item.animation.play('idle');
				item.centerOffsets();
			}
	
			var selectedItem:FlxSprite;
			switch(curColumn)
			{
				case CENTER:
					selectedItem = menuItems.members[curSelected];
				case LEFT:
					selectedItem = leftItem;
				case RIGHT:
					selectedItem = rightItem;
			}
			selectedItem.animation.play('selected');
			selectedItem.centerOffsets();
			camFollow.y = selectedItem.getGraphicMidpoint().y;
		}
	}