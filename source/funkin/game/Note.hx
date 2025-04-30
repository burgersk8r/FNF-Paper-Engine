package funkin.game;

import funkin.backend.animation.PsychAnimationController;
import funkin.backend.system.NoteTypesConfig;
import funkin.backend.shaders.RGBPalette;
import funkin.backend.shaders.RGBPalette.RGBShaderReference;
import funkin.game.StrumNote;
import flixel.math.FlxRect;

using StringTools;

typedef EventNote = {
	strumTime:Float,
	event:String,
	value1:String,
	value2:String
}

typedef NoteSplashData = {
	disabled:Bool,
	texture:String,
	useGlobalShader:Bool,
	useRGBShader:Bool,
	antialiasing:Bool,
	r:FlxColor,
	g:FlxColor,
	b:FlxColor,
	a:Float
}

class Note extends FlxSprite {
	public var extraData:Map<String, Dynamic> = new Map<String, Dynamic>();
	public var strumTime:Float = 0;
	public var noteData:Int = 0;
	public var mustPress:Bool = false;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var missed:Bool = false;
	public var ignoreNote:Bool = false;
	public var hitByOpponent:Bool = false;
	public var noteWasHit:Bool = false;
	public var prevNote:Note;
	public var nextNote:Note;
	public var spawned:Bool = false;
	public var tail:Array<Note> = [];
	public var parent:Note;
	public var blockHit:Bool = false;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var noteType(default, set):String = null;
	public var eventName:String = '';
	public var eventLength:Int = 0;
	public var eventVal1:String = '';
	public var eventVal2:String = '';
	public var rgbShader:RGBShaderReference;
	public static var globalRgbShaders:Array<RGBPalette> = [];
	public static var skinExistenceCache:Map<String, Bool> = new Map<String, Bool>();
	public var inEditor:Bool = false;
	public var animSuffix:String = '';
	public var gfNote:Bool = false;
	public var earlyHitMult:Float = 1;
	public var lateHitMult:Float = 1;
	public var lowPriority:Bool = false;
	public static var SUSTAIN_SIZE:Int = 44;
	public static var swagWidth:Float = 160 * 0.7;
	public static var colArray:Array<String> = ['purple', 'blue', 'green', 'red'];
	public static var defaultNoteSkin(default, never):String = 'noteSkins/strums';
	public var noteSplashData:NoteSplashData = {
		disabled: false,
		texture: null,
		antialiasing: !PlayState.isPixelStage,
		useGlobalShader: false,
		useRGBShader: (PlayState.SONG != null) ? !(PlayState.SONG.disableNoteRGB == true) : true,
		r: -1,
		g: -1,
		b: -1,
		a: ClientPrefs.data.splashAlpha
	};
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var offsetAngle:Float = 0;
	public var multAlpha:Float = 1;
	public var multSpeed(default, set):Float = 1;
	public var copyX:Bool = true;
	public var copyY:Bool = true;
	public var copyAngle:Bool = true;
	public var copyAlpha:Bool = true;
	public var hitHealth:Float = 0.023;
	public var missHealth:Float = 0.0475;
	public var rating:String = 'unknown';
	public var ratingMod:Float = 0;
	public var ratingDisabled:Bool = false;
	public var texture(default, set):String = null;
	public var noAnimation:Bool = false;
	public var noMissAnimation:Bool = false;
	public var hitCausesMiss:Bool = false;
	public var distance:Float = 2000;
	public var hitsoundDisabled:Bool = false;
	public var hitsoundChartEditor:Bool = true;
	public var hitsound:String = 'game/hitsound';
	public var hitsoundChartBF:String = 'chartSounds/chartTick';
	public var hitsoundChartDad:String = 'chartSounds/chartSnap';
	var _lastNoteOffX:Float = 0;
	static var _lastValidChecked:String;
	public var originalHeight:Float = 6;
	public var correctionOffset:Float = 0;

	private function set_multSpeed(value:Float):Float {
		resizeByRatio(value / multSpeed);
		multSpeed = value;
		return value;
	}

	public function resizeByRatio(ratio:Float) {
		if (isSustainNote && animation.curAnim != null && !animation.curAnim.name.endsWith('end')) {
			scale.y *= ratio;
			updateHitbox();
		}
	}

	private function set_texture(value:String):String {
		if (texture != value) reloadNote(value);
		texture = value;
		return value;
	}

	public function defaultRGB() {
		var arr:Array<FlxColor> = ClientPrefs.data.arrowRGB[noteData];
		if (PlayState.isPixelStage) arr = ClientPrefs.data.arrowRGBPixel[noteData];
		if (noteData > -1 && noteData <= arr.length) {
			rgbShader.r = arr[0];
			rgbShader.g = arr[1];
			rgbShader.b = arr[2];
		}
	}

	private function set_noteType(value:String):String {
		noteSplashData.texture = PlayState.SONG != null ? PlayState.SONG.splashSkin : 'splashes';
		defaultRGB();
		if (noteData > -1 && noteType != value) {
			switch (value) {
				case 'Hurt Note':
					ignoreNote = mustPress;
					rgbShader.r = 0xFF101010;
					rgbShader.g = 0xFFFF0000;
					rgbShader.b = 0xFF990022;
					noteSplashData.r = 0xFFFF0000;
					noteSplashData.g = 0xFF101010;
					noteSplashData.texture = 'splashes-electric';
					lowPriority = true;
					missHealth = isSustainNote ? 0.25 : 0.1;
					hitCausesMiss = true;
					hitsound = 'cancelMenu';
					hitsoundChartEditor = false;
				case 'Alt Animation': animSuffix = '-alt';
				case 'No Animation':
					noAnimation = true;
					noMissAnimation = true;
				case 'GF Sing': gfNote = true;
			}
			if (value != null && value.length > 1)
				NoteTypesConfig.applyNoteTypeData(this, value);
			if (hitsound != 'game/hitsound' && ClientPrefs.data.hitsoundVolume > 0)
				Paths.sound(hitsound);
			noteType = value;
		}
		return value;
	}

	public static function initializeGlobalRGBShader(noteData:Int) {
		if (globalRgbShaders[noteData] == null) {
			var newRGB:RGBPalette = new RGBPalette();
			globalRgbShaders[noteData] = newRGB;
			var arr:Array<FlxColor> = (!PlayState.isPixelStage)
				? ClientPrefs.data.arrowRGB[noteData]
				: ClientPrefs.data.arrowRGBPixel[noteData];
			if (noteData > -1 && noteData <= arr.length) {
				newRGB.r = arr[0];
				newRGB.g = arr[1];
				newRGB.b = arr[2];
			}
		}
		return globalRgbShaders[noteData];
	}

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inEditor:Bool = false, ?createdFrom:Dynamic = null) {
		super();
		animation = new PsychAnimationController(this);
		antialiasing = ClientPrefs.data.antialiasing;
		if (createdFrom == null) createdFrom = PlayState.instance;
		if (prevNote == null) prevNote = this;
		this.prevNote = prevNote;
		this.inEditor = inEditor;
		this.moves = false;
		isSustainNote = sustainNote;
		this.strumTime = strumTime + (inEditor ? 0 : ClientPrefs.data.noteOffset);
		this.noteData = noteData;
		x += (ClientPrefs.data.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X) + 50;
		y -= 2000;
		if (noteData > -1) {
			texture = '';
			rgbShader = new RGBShaderReference(this, initializeGlobalRGBShader(noteData));
			if (PlayState.SONG != null && PlayState.SONG.disableNoteRGB)
				rgbShader.enabled = false;
			x += swagWidth * noteData;
			if (!isSustainNote && noteData < colArray.length) {
				animation.play(colArray[noteData % colArray.length] + 'Scroll');
			}
		}
		if (prevNote != null) prevNote.nextNote = this;
		if (isSustainNote && prevNote != null) {
			alpha = multAlpha = 0.6;
			hitsoundDisabled = true;
			if (ClientPrefs.data.downScroll) flipY = true;
			offsetX += width / 2;
			copyAngle = false;
			animation.play(colArray[noteData % colArray.length] + 'holdend');
			updateHitbox();
			offsetX -= width / 2;
			if (PlayState.isPixelStage) offsetX += 30;
			if (prevNote.isSustainNote) {
				prevNote.animation.play(colArray[prevNote.noteData % colArray.length] + 'hold');
				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.05;
				if (createdFrom != null && createdFrom.songSpeed != null)
					prevNote.scale.y *= createdFrom.songSpeed;
				if (PlayState.isPixelStage) {
					prevNote.scale.y *= 1.19;
					prevNote.scale.y *= (6 / height);
				}
				prevNote.updateHitbox();
			}
			if (PlayState.isPixelStage) {
				scale.y *= PlayState.daPixelZoom;
				updateHitbox();
			}
			earlyHitMult = 0;
		} else {
			centerOffsets();
			centerOrigin();
		}
		x += offsetX;
	}
	public function reloadNote(texture:String = '', postfix:String = '') {
		if (texture == null) texture = '';
		if (postfix == null) postfix = '';

		var skin:String = texture + postfix;
		if (texture.length < 1) {
			skin = (PlayState.SONG != null && PlayState.SONG.arrowSkin != null)
				? PlayState.SONG.arrowSkin
				: defaultNoteSkin + postfix;
		}

		var animName = animation.curAnim != null ? animation.curAnim.name : null;
		var lastScaleY:Float = scale.y;
		var skinPixel = skin;
		var skinPostfix = getNoteSkinPostfix();
		var customSkin = skin + skinPostfix;
		var path = PlayState.isPixelStage ? 'pixelUI/' : '';
		var filePath = 'images/' + path + customSkin + '.png';

		var exists:Bool = skinExistenceCache.exists(filePath)
			? skinExistenceCache.get(filePath)
			: Paths.fileExists(filePath, IMAGE);

		if (!skinExistenceCache.exists(filePath))
			skinExistenceCache.set(filePath, exists);

		if (exists) {
			skin = customSkin;
			_lastValidChecked = customSkin;
		} else {
			skinPostfix = '';
		}

		if (PlayState.isPixelStage) {
			var graphic;
			if (isSustainNote) {
				graphic = Paths.image('pixelUI/' + skinPixel + 'ENDS' + skinPostfix);
				loadGraphic(graphic, true, Math.floor(graphic.width / 4), Math.floor(graphic.height / 2));
				originalHeight = graphic.height / 2;
			} else {
				graphic = Paths.image('pixelUI/' + skinPixel + skinPostfix);
				loadGraphic(graphic, true, Math.floor(graphic.width / 4), Math.floor(graphic.height / 5));
			}

			setGraphicSize(Std.int(width * PlayState.daPixelZoom));
			loadPixelNoteAnims();
			antialiasing = false;

			if (isSustainNote) {
				offsetX += _lastNoteOffX;
				_lastNoteOffX = (width - 7) * (PlayState.daPixelZoom / 2);
				offsetX -= _lastNoteOffX;
			}
		} else {
			frames = Paths.getSparrowAtlas(skin);
			loadNoteAnims();
			if (!isSustainNote) {
				centerOffsets();
				centerOrigin();
			}
		}

		if (isSustainNote)
			scale.y = lastScaleY;

		updateHitbox();

		if (animName != null)
			animation.play(animName, true);
	}

	public static function getNoteSkinPostfix() {
		var skin = ClientPrefs.data.noteSkin;
		if (skin != ClientPrefs.defaultData.noteSkin)
			return '-' + skin.trim().toLowerCase().replace(' ', '_');
		return '';
	}

	function loadNoteAnims() {
		if (isSustainNote) {
			attemptToAddAnimationByPrefix('purpleholdend', 'pruple end hold', 24, true);
			animation.addByPrefix(colArray[noteData] + 'holdend', colArray[noteData] + ' hold end', 24, true);
			animation.addByPrefix(colArray[noteData] + 'hold', colArray[noteData] + ' hold piece', 24, true);
		} else {
			animation.addByPrefix(colArray[noteData] + 'Scroll', colArray[noteData] + '0');
		}
		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
	}

	function loadPixelNoteAnims() {
		if (isSustainNote) {
			animation.add(colArray[noteData] + 'holdend', [noteData + 4], 24, true);
			animation.add(colArray[noteData] + 'hold', [noteData], 24, true);
		} else {
			animation.add(colArray[noteData] + 'Scroll', [noteData + 4], 24, true);
		}
	}

	function attemptToAddAnimationByPrefix(name:String, prefix:String, framerate:Float = 24, doLoop:Bool = true) {
		var animFrames = [];
		@:privateAccess
		animation.findByPrefix(animFrames, prefix);
		if (animFrames.length > 0)
			animation.addByPrefix(name, prefix, framerate, doLoop);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (mustPress) {
			canBeHit = (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * lateHitMult) &&
						strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult));
			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		} else {
			canBeHit = false;
			if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult)) {
				if ((isSustainNote && prevNote.wasGoodHit) || strumTime <= Conductor.songPosition)
					wasGoodHit = true;
			}
		}

		if (tooLate && !inEditor && alpha > 0.3)
			alpha = 0.3;
	}

	override public function destroy() {
		super.destroy();
		_lastValidChecked = '';
	}

	public function followStrumNote(myStrum:StrumNote, fakeCrochet:Float, songSpeed:Float = 1) {
		var strumX = myStrum.x;
		var strumY = myStrum.y;
		var strumAngle = myStrum.angle;
		var strumAlpha = myStrum.alpha;
		var strumDirection = myStrum.direction;

		distance = 0.45 * (Conductor.songPosition - strumTime) * songSpeed * multSpeed;
		if (!myStrum.downScroll) distance *= -1;

		var angleRad = strumDirection * 0.0174533;

		if (copyAngle)
			angle = strumDirection - 90 + strumAngle + offsetAngle;

		if (copyAlpha)
			alpha = strumAlpha * multAlpha;

		if (copyX)
			x = strumX + offsetX + Math.cos(angleRad) * distance;

		if (copyY) {
			y = strumY + offsetY + correctionOffset + Math.sin(angleRad) * distance;
			if (myStrum.downScroll && isSustainNote) {
				if (PlayState.isPixelStage) y -= PlayState.daPixelZoom * 9.5;
				y -= (frameHeight * scale.y) - (Note.swagWidth / 2);
			}
		}
	}

	public function clipToStrumNote(myStrum:StrumNote) {
		var center = myStrum.y + offsetY + Note.swagWidth / 2;

		if (isSustainNote && (mustPress || !ignoreNote) &&
			(!mustPress || (wasGoodHit || (prevNote.wasGoodHit && !canBeHit))))
		{
			if (clipRect == null)
				clipRect = new FlxRect(0, 0, frameWidth, frameHeight);

			if (myStrum.downScroll && (y - offset.y * scale.y + height >= center)) {
				clipRect.width = frameWidth;
				clipRect.height = (center - y) / scale.y;
				clipRect.y = frameHeight - clipRect.height;
			} else if (!myStrum.downScroll && (y + offset.y * scale.y <= center)) {
				clipRect.y = (center - y) / scale.y;
				clipRect.width = width / scale.x;
				clipRect.height = (height / scale.y) - clipRect.y;
			}
		}
	}

	@:noCompletion
	override function set_clipRect(rect:FlxRect):FlxRect {
		clipRect = rect;
		if (frames != null)
			frame = frames.frames[animation.frameIndex];
		return rect;
	}
}
