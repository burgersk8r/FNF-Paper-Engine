package funkin.game.stages;

import funkin.game.stages.objects.*;

class Mall extends BaseStage
{
	var upperBoppers:BGSprite = null;
	var bottomBoppers:MallCrowd = null;
	var santa:BGSprite = null;

	override function create()
	{
		addOptimizedSprite('game/stages/mall/bgWalls', -1000, -500, 0.2, 0.2, 0.8);

		if (!ClientPrefs.data.lowQuality)
		{
			upperBoppers = addOptimizedSprite('game/stages/mall/upperBop', -240, -90, 0.33, 0.33, 0.85, ['Upper Crowd Bob']);
			addOptimizedSprite('game/stages/mall/bgEscalator', -1100, -600, 0.3, 0.3, 0.9);
		}

		add(new BGSprite('game/stages/mall/christmasTree', 370, -250, 0.40, 0.40));

		bottomBoppers = new MallCrowd(-300, 140);
		add(bottomBoppers);

		add(new BGSprite('game/stages/mall/fgSnow', -600, 700));

		santa = new BGSprite('game/stages/mall/santa', -840, 150, 1, 1, ['santa idle in fear']);
		add(santa);

		Paths.sound('game/week5/Lights_Shut_off');
		setDefaultGF('gf-christmas');

		if (isStoryMode && !seenCutscene)
			setEndCallback(eggnogEndCutscene);
	}

	// Helper method for sprite creation with scaling and memory-friendly defaults
	private function addOptimizedSprite(
		path:String, x:Float, y:Float, 
		scrollX:Float = 1, scrollY:Float = 1, 
		scale:Float = 1, anims:Array<String> = null
	):BGSprite {
		var sprite = new BGSprite(path, x, y, scrollX, scrollY, anims);
		if (scale != 1)
		{
			sprite.setGraphicSize(Std.int(sprite.width * scale));
			sprite.updateHitbox();
		}
		add(sprite);
		return sprite;
	}

	override function countdownTick(count:Countdown, num:Int)
		everyoneDance();

	override function beatHit()
		everyoneDance();

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		if (eventName == "Hey!") {
			switch (value1.toLowerCase().trim()) {
				case 'bf', 'boyfriend', '0':
					return;
			}
			bottomBoppers.animation.play('hey', true);
			bottomBoppers.heyTimer = flValue2;
		}
	}

	function everyoneDance()
	{
		if (upperBoppers != null)
			upperBoppers.dance(true);

		if (bottomBoppers != null)
			bottomBoppers.dance(true);

		if (santa != null)
			santa.dance(true);
	}

	function eggnogEndCutscene()
	{
		if (PlayState.storyPlaylist[1] == null)
		{
			endSong();
			return;
		}

		var nextSong:String = Paths.formatToSongPath(PlayState.storyPlaylist[1]);
		if (nextSong == 'winter-horrorland')
		{
			FlxG.sound.play(Paths.sound('game/week5/Lights_Shut_off'));

			var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
				-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
			blackShit.scrollFactor.set();
			add(blackShit);

			camHUD.visible = false;
			inCutscene = true;
			canPause = false;

			new FlxTimer().start(1.5, function(tmr:FlxTimer) {
				endSong();
			});
		}
		else endSong();
	}
}
