package funkin;

import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.util.FlxGradient;

/*
	State that is displayed when the game crashes.

    PLEASE NOTE!!!! THIS IS RIPPED STRAIGHT FROM DOIDO AND WILL ONLY BE USED IN HTML5 TESTING!
*/

class CrashHandlerState extends MusicBeatState
{
    var errorMsg:String = "";

    public function new(errorMsg:String)
    {
        super();
        this.errorMsg = errorMsg;
    }

    override function create()
    {
        super.create();
        var bg = new FlxSprite().loadGraphic(Paths.image('game/menus/mainmenu/menuBGBlue'));
        bg.screenCenter();
        bg.alpha = 0.3;
        add(bg);

        var titleTxt = new FlxText(0, 16, 0, "THE GAME HAS CRASHED!!");
        titleTxt.setFormat('vcr.ttf', 36, 0xFFFFFFFF, CENTER);
        titleTxt.screenCenter(X);
        add(titleTxt);

        var errorTxt = new FlxText(24,titleTxt.y + titleTxt.height + 16, FlxG.width - 24, errorMsg);
        errorTxt.setFormat('vcr.ttf', 24, 0xFFFFFFFF, LEFT);
        add(errorTxt);

        var infoTxt = new FlxText(24, 0, 'Press ESCAPE to return to main menu');
        infoTxt.setFormat('vcr.ttf', 24, 0xFFFFFFFF, RIGHT);
        infoTxt.x = FlxG.width - infoTxt.width - 16;
        infoTxt.y = FlxG.height- infoTxt.height - 16;
        add(infoTxt);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        
        if(controls.ACCEPT || controls.BACK)
        {
            FlxG.switchState(new funkin.menus.MainMenuState());
        }
         
    }
}