package funkin.game.stages;

import funkin.game.stages.objects.*;

enum HenchmenKillState
{
	WAIT;
	KILLING;
	SPEEDING_OFFSCREEN;
	SPEEDING;
	STOPPING;
}

class Limo extends BaseStage
{
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:BGSprite;
	var fastCarCanDrive:Bool = true;

	var limoKillingState:HenchmenKillState = WAIT;
	var limoMetalPole:BGSprite;
	var limoLight:BGSprite;
	var limoCorpse:BGSprite;
	var limoCorpseTwo:BGSprite;
	var bgLimo:BGSprite;
	var grpLimoParticles:FlxTypedGroup<BGSprite>;
	var dancersDiff:Float = 320;
	var limoSpeed:Float = 800;

	override function create()
	{
		add(new BGSprite('game/stages/limo/limoSunset', -120, -50, 0.1, 0.1));

		if(!ClientPrefs.data.lowQuality)
		{
			bgLimo = new BGSprite('game/stages/limo/bgLimo', -150, 480, 0.4, 0.4, ['background limo pink'], true);
			add(bgLimo);

			initGoreAssets();
			initDancers();
			initParticles();
			Paths.sound('game/limo/dancerdeath'); // Cache
			setDefaultGF('gf-car');
		}

		fastCar = new BGSprite('game/stages/limo/fastCarLol', -300, 160);
		fastCar.active = true;
	}

	override function createPost()
	{
		resetFastCar();
		addBehindGF(fastCar);
		addBehindGF(new BGSprite('game/stages/limo/limoDrive', -120, 550, 1, 1, ['Limo stage'], true));
	}

	override function update(elapsed:Float)
	{
		if (!ClientPrefs.data.lowQuality)
		{
			handleParticles();
			updateKillSequence(elapsed);
		}
	}

	override function beatHit()
	{
		if (!ClientPrefs.data.lowQuality)
			for (d in grpLimoDancers) d.dance();

		if (FlxG.random.bool(10) && fastCarCanDrive)
			fastCarDrive();
	}

	override function closeSubState() if (paused && carTimer != null) carTimer.active = true;
	override function openSubState(_) if (paused && carTimer != null) carTimer.active = false;

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		if (eventName == "Kill Henchmen") killHenchmen();
	}

	function dancersParenting()
	{
		for (i in 0...grpLimoDancers.length)
			grpLimoDancers.members[i].x = (370 * i) + dancersDiff + bgLimo.x;
	}

	function initDancers()
	{
		grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
		add(grpLimoDancers);
		for (i in 0...5)
		{
			var dancer = new BackgroundDancer((370 * i) + dancersDiff + bgLimo.x, bgLimo.y - 400);
			dancer.scrollFactor.set(0.4, 0.4);
			grpLimoDancers.add(dancer);
		}
	}

	function initGoreAssets()
	{
		limoMetalPole = new BGSprite('game/stages/limo/gore/metalPole', -500, 220, 0.4, 0.4);
		limoCorpse = new BGSprite('game/stages/limo/gore/noooooo', -500, limoMetalPole.y - 130, 0.4, 0.4, ['Henchmen on rail'], true);
		limoCorpseTwo = new BGSprite('game/stages/limo/gore/noooooo', -500, limoMetalPole.y, 0.4, 0.4, ['henchmen death'], true);
		limoLight = new BGSprite('game/stages/limo/gore/coldHeartKiller', limoMetalPole.x - 180, limoMetalPole.y - 80, 0.4, 0.4);

		add(limoMetalPole);
		add(limoCorpse);
		add(limoCorpseTwo);
		add(limoLight);

		resetLimoKill();
	}

	function initParticles()
	{
		grpLimoParticles = new FlxTypedGroup<BGSprite>();
		add(grpLimoParticles);

		// Preload invisible particle to warm up pool
		var particle = new BGSprite('game/stages/limo/gore/stupidBlood', -400, -400, 0.4, 0.4, ['blood'], false);
		particle.alpha = 0.01;
		grpLimoParticles.add(particle);
	}

	function handleParticles()
	{
		for (spr in grpLimoParticles)
		{
			if (spr.animation.curAnim != null && spr.animation.curAnim.finished)
			{
				spr.kill();
				grpLimoParticles.remove(spr, true);
				spr.destroy();
			}
		}
	}

	function updateKillSequence(elapsed:Float)
	{
		switch(limoKillingState)
		{
			case KILLING:
				movePole(elapsed);
				checkDancerKills();

				if(limoMetalPole.x > FlxG.width * 2)
				{
					resetLimoKill();
					limoSpeed = 800;
					limoKillingState = SPEEDING_OFFSCREEN;
				}

			case SPEEDING_OFFSCREEN:
				limoSpeed -= 4000 * elapsed;
				bgLimo.x -= limoSpeed * elapsed;
				if(bgLimo.x > FlxG.width * 1.5)
				{
					limoSpeed = 3000;
					limoKillingState = SPEEDING;
				}

			case SPEEDING:
				limoSpeed -= 2000 * elapsed;
				if(limoSpeed < 1000) limoSpeed = 1000;
				bgLimo.x -= limoSpeed * elapsed;

				if(bgLimo.x < -275)
				{
					limoKillingState = STOPPING;
					limoSpeed = 800;
				}
				dancersParenting();

			case STOPPING:
				bgLimo.x = FlxMath.lerp(-150, bgLimo.x, Math.exp(-elapsed * 9));
				if (Math.round(bgLimo.x) == -150)
				{
					bgLimo.x = -150;
					limoKillingState = WAIT;
				}
				dancersParenting();
			default:
		}
	}

	function movePole(elapsed:Float)
	{
		limoMetalPole.x += 5000 * elapsed;
		limoLight.x = limoMetalPole.x - 180;
		limoCorpse.x = limoLight.x - 50;
		limoCorpseTwo.x = limoLight.x + 35;
	}

	function checkDancerKills()
	{
		for (i in 0...grpLimoDancers.length)
		{
			var dancer = grpLimoDancers.members[i];
			if (dancer.x < FlxG.width * 1.5 && limoLight.x > (370 * i) + 170)
			{
				if (i == 0 || i == 3)
				{
					if(i == 0) FlxG.sound.play(Paths.sound('game/week4/dancerdeath'), 0.5);
					spawnBloodParticles(dancer.x, dancer.y, i == 3 ? ' 2 ' : ' ');
				}
				else if (i == 1) limoCorpse.visible = true;
				else if (i == 2) limoCorpseTwo.visible = true;

				dancer.x += FlxG.width * 2;
			}
		}
	}

	function spawnBloodParticles(x:Float, y:Float, diffStr:String)
	{
		inline function addParticle(path:String, ox:Float, oy:Float, anim:Array<String>, flip:Bool = false, angle:Float = 0)
		{
			var p = new BGSprite(path, x + ox, y + oy, 0.4, 0.4, anim, false);
			p.flipX = flip;
			p.angle = angle;
			grpLimoParticles.add(p);
		}

		addParticle('game/stages/limo/gore/noooooo', 200, 0, ['hench leg spin' + diffStr + 'PINK']);
		addParticle('game/stages/limo/gore/noooooo', 160, 200, ['hench arm spin' + diffStr + 'PINK']);
		addParticle('game/stages/limo/gore/noooooo', 0, 50, ['hench head spin' + diffStr + 'PINK']);
		addParticle('game/stages/limo/gore/stupidBlood', -110, 20, ['blood'], true, -57.5);
	}

	function resetLimoKill()
	{
		limoMetalPole.x = limoLight.x = limoCorpse.x = limoCorpseTwo.x = -500;
		limoMetalPole.visible = limoLight.visible = limoCorpse.visible = limoCorpseTwo.visible = false;
	}

	function resetFastCar()
	{
		fastCar.setPosition(-12600, FlxG.random.int(140, 250));
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	var carTimer:FlxTimer;
	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('game/week4/carPass', 0, 1), 0.7);
		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		carTimer = new FlxTimer().start(2, function(_) {
			resetFastCar();
			carTimer = null;
		});
	}

	function killHenchmen()
	{
		if (!ClientPrefs.data.lowQuality && limoKillingState == WAIT)
		{
			limoMetalPole.x = -400;
			limoMetalPole.visible = limoLight.visible = true;
			limoCorpse.visible = limoCorpseTwo.visible = false;
			limoKillingState = KILLING;

			#if ACHIEVEMENTS_ALLOWED
			var kills = Achievements.addScore("roadkill_enthusiast");
			FlxG.log.add('Henchmen kills: $kills');
			#end
		}
	}
}
