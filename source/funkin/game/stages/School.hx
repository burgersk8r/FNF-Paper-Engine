package funkin.game.stages;

import funkin.game.stages.objects.*;
import funkin.game.GameOverSubstate;
import funkin.game.cutscenes.DialogueBox;

import openfl.utils.Assets as OpenFlAssets;

class School extends BaseStage
{
	var bgGirls:BackgroundGirls;

	override function create()
	{
		var _song = PlayState.SONG;

		// Ensure Game Over assets are set
		if (_song.gameOverSound == null || _song.gameOverSound.trim().length < 1)
			GameOverSubstate.deathSoundName = 'gameover/fnf_loss_sfx-pixel';

		if (_song.gameOverLoop == null || _song.gameOverLoop.trim().length < 1)
			GameOverSubstate.loopSoundName = 'gameover/gameOver-pixel';

		if (_song.gameOverEnd == null || _song.gameOverEnd.trim().length < 1)
			GameOverSubstate.endSoundName = 'gameover/gameOverEnd-pixel';

		if (_song.gameOverChar == null || _song.gameOverChar.trim().length < 1)
			GameOverSubstate.characterName = 'bf-pixel-dead';

		// Sky Background
		var bgSky = new BGSprite('pixelVariant/game/stages/school/weebSky', 0, 0, 0.1, 0.1);
		bgSky.antialiasing = false;
		add(bgSky);

		var repositionShit = -200;
		var widShit = Std.int(bgSky.width * PlayState.daPixelZoom);
		if (widShit <= 0) widShit = 1280; // fallback to prevent invisible graphics

		// School Background
		var bgSchool = new BGSprite('pixelVariant/game/stages/school/weebSchool', repositionShit, 0, 0.6, 0.9);
		bgSchool.antialiasing = false;
		add(bgSchool);

		// Street
		var bgStreet = new BGSprite('pixelVariant/game/stages/school/weebStreet', repositionShit, 0, 0.95, 0.95);
		bgStreet.antialiasing = false;
		add(bgStreet);

		// Trees behind
		if (!ClientPrefs.data.lowQuality) {
			var fgTrees = new BGSprite('pixelVariant/game/stages/school/weebTreesBack', repositionShit + 170, 130, 0.9, 0.9);
			fgTrees.setGraphicSize(Std.int(widShit * 0.8));
			fgTrees.updateHitbox();
			fgTrees.antialiasing = false;
			add(fgTrees);
		}

		// Animated tree
		var bgTrees = new FlxSprite(repositionShit - 380, -800);
		bgTrees.frames = Paths.getPackerAtlas('pixelVariant/game/stages/school/weebTrees');
		if (bgTrees.frames == null) trace("ERROR: Missing atlas for weebTrees!");
		bgTrees.animation.add('treeLoop', [for (i in 0...19) i], 12);
		bgTrees.animation.play('treeLoop');
		bgTrees.scrollFactor.set(0.85, 0.85);
		bgTrees.antialiasing = false;
		add(bgTrees);

		// Petals
		if (!ClientPrefs.data.lowQuality) {
			var treeLeaves = new BGSprite('pixelVariant/game/stages/school/petals', repositionShit, -40, 0.85, 0.85, ['PETALS ALL'], true);
			treeLeaves.setGraphicSize(widShit);
			treeLeaves.updateHitbox();
			treeLeaves.antialiasing = false;
			add(treeLeaves);
		}

		// Rescale & update hitboxes
		bgSky.setGraphicSize(widShit);
		bgSchool.setGraphicSize(widShit);
		bgStreet.setGraphicSize(widShit);
		bgTrees.setGraphicSize(Std.int(widShit * 1.4));

		bgSky.updateHitbox();
		bgSchool.updateHitbox();
		bgStreet.updateHitbox();
		bgTrees.updateHitbox();

		// Background girls
		if (!ClientPrefs.data.lowQuality) {
			bgGirls = new BackgroundGirls(-100, 190);
			bgGirls.scrollFactor.set(0.9, 0.9);
			add(bgGirls);
		}

		setDefaultGF('gf-pixel');

		switch (songName)
		{
			case 'senpai':
				FlxG.sound.playMusic(Paths.music('cutscenes/pixel/Lunchbox'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);

			case 'roses':
				FlxG.sound.play(Paths.sound('cutscenes/ANGRY_TEXT_BOX'));
		}

		if (isStoryMode && !seenCutscene)
		{
			if (songName == 'roses')
				FlxG.sound.play(Paths.sound('game/week6/ANGRY'));
			initDoof();
			setStartCallback(schoolIntro);
		}
	}

	override function beatHit()
	{
		if (bgGirls != null)
			bgGirls.dance();
	}

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		if (eventName == "BG Freaks Expression" && bgGirls != null)
			bgGirls.swapDanceType();
	}

	var doof:DialogueBox = null;
	function initDoof()
	{
		var file:String = Paths.dialogueTxt('levels/' + '/dialogues/' + songName + 'Dialogue');

		#if MODS_ALLOWED
		if (!FileSystem.exists(file))
		#else
		if (!OpenFlAssets.exists(file))
		#end
		{
			startCountdown();
			return;
		}

		FlxSprite.defaultAntialiasing = false;

		doof = new DialogueBox(false, CoolUtil.coolTextFile(file));
		doof.cameras = [camHUD];
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = PlayState.instance.startNextDialogue;
		doof.skipDialogueThing = PlayState.instance.skipDialogue;
	}

	function schoolIntro():Void
	{
		inCutscene = true;
		var black = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();

		if (songName == 'senpai') add(black);

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;
			if (black.alpha > 0)
				tmr.reset(0.3);
			else
			{
				if (doof != null) add(doof);
				else startCountdown();

				remove(black);
				black.destroy();
			}
		});
	}
}
