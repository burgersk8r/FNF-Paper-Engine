package funkin.game.stages;

import flixel.addons.effects.FlxTrail;
import funkin.game.stages.objects.*;
import funkin.game.GameOverSubstate;
import funkin.game.cutscenes.DialogueBox;
import openfl.utils.Assets as OpenFlAssets;

class SchoolEvil extends BaseStage
{
	var bgGhouls:BGSprite;
	var doof:DialogueBox;

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


		var posX = 400;
		var posY = 200;

		// Background
		var bg = !ClientPrefs.data.lowQuality
			? new BGSprite('pixelVariant/game/stages/school/animatedEvilSchool', posX, posY, 0.8, 0.9, ['background 2'], true)
			: new BGSprite('pixelVariant/game/stages/school/animatedEvilSchool_low', posX, posY, 0.8, 0.9);

		bg.scale.set(PlayState.daPixelZoom, PlayState.daPixelZoom);
		bg.antialiasing = false;
		add(bg);

		setDefaultGF('gf-pixel');

		// Background music
		FlxG.sound.playMusic(Paths.music('cutscenes/pixel/LunchboxScary'), 0);
		FlxG.sound.music.fadeIn(1, 0, 0.8);

		// Dialogue setup
		if (isStoryMode && !seenCutscene)
		{
			initDoof();
			setStartCallback(schoolIntro);
		}
	}

	override function createPost()
	{
		// Add trailing effect to dad character
		var trail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
		addBehindDad(trail);
	}

	override function eventPushed(event:funkin.game.Note.EventNote)
	{
		if (event.event == "Trigger BG Ghouls" && !ClientPrefs.data.lowQuality)
		{
			bgGhouls = new BGSprite('pixelVariant/game/stages/school/bgGhouls', -100, 190, 0.9, 0.9, ['BG freaks glitch instance'], false);
			bgGhouls.setGraphicSize(Std.int(bgGhouls.width * PlayState.daPixelZoom));
			bgGhouls.updateHitbox();
			bgGhouls.visible = false;
			bgGhouls.antialiasing = false;

			bgGhouls.animation.finishCallback = function(name:String)
			{
				if (name == 'BG freaks glitch instance')
					bgGhouls.visible = false;
			};

			addBehindGF(bgGhouls);
		}
	}

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		if (eventName == "Trigger BG Ghouls" && bgGhouls != null && !ClientPrefs.data.lowQuality)
		{
			bgGhouls.visible = true;
			bgGhouls.dance(true);
		}
	}

	function initDoof()
	{
		var file = Paths.dialogueTxt(songName + '/dialogue/' + songName + 'Dialogue');

		FlxSprite.defaultAntialiasing = false;

		#if MODS_ALLOWED
		if (!FileSystem.exists(file))
		#else
		if (!OpenFlAssets.exists(file))
		#end
		{
			startCountdown();
			return;
		}

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

		// Red flash background
		var red = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();
		add(red);

		// Evil Senpai sprite setup
		var senpaiEvil = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('pixelVariant/game/stages/school/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.updateHitbox();
		senpaiEvil.scrollFactor.set();
		senpaiEvil.screenCenter();
		senpaiEvil.x += 300;
		camHUD.visible = false;

		new FlxTimer().start(2.1, function(_) {
			if (doof != null)
			{
				add(senpaiEvil);
				senpaiEvil.alpha = 0;

				new FlxTimer().start(0.3, function(fadeTimer:FlxTimer)
				{
					senpaiEvil.alpha += 0.15;

					if (senpaiEvil.alpha < 1)
					{
						fadeTimer.reset();
					}
					else
					{
						senpaiEvil.animation.play('idle');

						FlxG.sound.play(Paths.sound('game/week6/Senpai_Dies'), 1, false, null, true, function() {
							remove(senpaiEvil);
							senpaiEvil.destroy();
							remove(red);
							red.destroy();

							FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function() {
								add(doof);
								camHUD.visible = true;
							}, true);
						});

						new FlxTimer().start(3.2, function(_) {
							FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
						});
					}
				});
			}
		});
	}
}
