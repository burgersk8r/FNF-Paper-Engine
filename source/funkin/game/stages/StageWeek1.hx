package funkin.game.stages;

import funkin.game.stages.objects.*;
import funkin.game.Character;

class StageWeek1 extends BaseStage
{
	override function create()
	{
		add(new BGSprite('stages/week1/stageback', -600, -200, 0.9, 0.9));

		var stageFront:BGSprite = new BGSprite('stages/week1/stagefront', -650, 600, 0.9, 0.9);
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		stageFront.updateHitbox();
		add(stageFront);

		if (!ClientPrefs.data.lowQuality)
		{
			// Helper function to create light sprites
			function createStageLight(x:Float, flip:Bool = false):BGSprite {
				var light = new BGSprite('stages/week1/stage_light', x, -100, 0.9, 0.9);
				light.setGraphicSize(Std.int(light.width * 1.1));
				light.updateHitbox();
				light.flipX = flip;
				return light;
			}

			add(createStageLight(-125));
			add(createStageLight(1225, true));

			var stageCurtains:BGSprite = new BGSprite('stages/week1/stagecurtains', -500, -300, 1.3, 1.3);
			stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
			stageCurtains.updateHitbox();
			add(stageCurtains);
		}
	}
}
