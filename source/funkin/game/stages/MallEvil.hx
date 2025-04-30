package funkin.game.stages;

import funkin.game.stages.objects.*;

class MallEvil extends BaseStage
{
	override function create()
	{
		addOptimizedSprite('stages/week5/christmas/evilBG', -400, -500, 0.2, 0.2, 0.8);

		if (!ClientPrefs.data.lowQuality) {
			add(new BGSprite('stages/week5/christmas/evilTree', 300, -300, 0.2, 0.2));
			add(new BGSprite('stages/week5/christmas/evilSnow', -200, 700));
		}

		setDefaultGF('gf-christmas');

		// Winter Horrorland cutscene
		if (isStoryMode && !seenCutscene && songName == 'winter-horrorland') {
			setStartCallback(winterHorrorlandCutscene);
		}
	}

	// Helper method for optimized sprite loading
	private function addOptimizedSprite(
		path:String, x:Float, y:Float, 
		scrollX:Float = 1, scrollY:Float = 1, 
		scale:Float = 1
	):BGSprite {
		var sprite = new BGSprite(path, x, y, scrollX, scrollY);
		if (scale != 1) {
			sprite.setGraphicSize(Std.int(sprite.width * scale));
			sprite.updateHitbox();
		}
		add(sprite);
		return sprite;
	}

	function winterHorrorlandCutscene()
	{
		camHUD.visible = false;
		inCutscene = true;

		FlxG.sound.play(Paths.sound('game/week5/Lights_Turn_On'));
		FlxG.camera.zoom = 1.5;
		FlxG.camera.focusOn(new FlxPoint(400, -2050));

		var blackScreen:FlxSprite = new FlxSprite().makeGraphic(
			Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
		blackScreen.scrollFactor.set();
		add(blackScreen);

		FlxTween.tween(blackScreen, {alpha: 0}, 0.7, {
			ease: FlxEase.linear,
			onComplete: function(_) {
				remove(blackScreen);
				blackScreen.destroy();
			}
		});

		new FlxTimer().start(0.8, function(_) {
			camHUD.visible = true;
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
				ease: FlxEase.quadInOut,
				onComplete: function(_) {
					startCountdown();
				}
			});
		});
	}
}
