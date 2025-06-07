/* package funkin.game;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import funkin.game.Note;
import funkin.game.NoteSplash;
import funkin.game.StrumNote;
import funkin.game.PlayState;
import funkin.data.ClientPrefs;
import funkin.backend.system.Conductor;
import funkin.backend.assets.Paths;

class SustainSplash extends FlxSprite {
  public static var startCrochet:Float;
  public static var frameRate:Int;
  public static var isPixelStage:Bool;

  public var destroyTimer:FlxTimer;

  public function new():Void {
    super();

    frames = Paths.getSparrowAtlas('game/hud/splashes/holdSplashes/default');
    animation.addByPrefix('hold', 'hold', frameRate, true);
    animation.addByPrefix('end', 'end', 24, false);
    animation.play('hold');
    animation.curAnim.looped = true;

    destroyTimer = new FlxTimer();
  }

  public function setupSusSplash(strum:StrumNote, end:Note, ?playbackRate:Float = 1):Void {
    var tailLength = end.parent.tail.length;
    var strumOffset = end.parent.strumTime - Conductor.songPosition + ClientPrefs.data.ratingOffset;
    var timeThingy = ((startCrochet * tailLength + strumOffset) / playbackRate) * 0.001;

    end.extraData['default'] = this;

    clipRect = new FlxRect(0, isPixelStage ? -210 : 0, frameWidth, frameHeight);

    if (end.shader != null) {
      shader = new NoteSplash.PixelSplashShaderRef().shader;
      shader.data.r.value = end.shader.data.r.value;
      shader.data.g.value = end.shader.data.g.value;
      shader.data.b.value = end.shader.data.b.value;
      shader.data.mult.value = end.shader.data.mult.value;
    }

    setPosition(strum.x, strum.y);
    offset.set(isPixelStage ? 112.5 : 106.25, 100);

    destroyTimer.start(timeThingy, (_) -> {
      if (!end.mustPress) {
        die(end);
        return;
      }

      alpha = ClientPrefs.data.holdSplashAlpha;
      clipRect = null;

      animation.play('end');
      animation.curAnim.looped = false;
      animation.curAnim.frameRate = 24;
      animation.finishCallback = (_) -> die(end);
    });
  }

  public function die(?end:Note = null):Void {
    kill();
    super.kill();

    if (FlxG.state is PlayState) {
      PlayState.instance.grpHoldSplashes.remove(this);
    }

    destroy();
    super.destroy();

    if (end != null) {
      end.extraData['default'] = null;
    }
  }
} */