package funkin.objects; 

class FreeplayIcon extends FlxSprite // this is just HealthIcon but for freeplay
{
	public var sprTracker:FlxSprite;
	private var char:String = '';

	public function new(char:String = '', ?allowGPU:Bool = true)
	{
		super();
		changeIcon(char, allowGPU);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public function changeIcon(char:String, ?allowGPU:Bool = true) {
		if(this.char != char) {
			var name:String = 'menus/freeplay/icons/$char/icon';
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'menus/freeplay/icons/$char/icon';
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'menus/freeplay/icons/face/icon';
			
			var graphic = Paths.image(name, allowGPU);
			loadGraphic(graphic, true, 150, 150);
			iconOffsets[0] = (width - 150) / 2;
			updateHitbox();
			animation.add(char, [0], 0, false);
			animation.play(char);
			this.char = char;
			antialiasing = ClientPrefs.data.antialiasing;
		}
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
	}

	public function getCharacter():String {
		return char;
	}
}
