package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.util.FlxColor;
import openfl.display.Sprite;

class MainMenu extends FlxState
{
	static var bitmapfont:FlxBitmapFont;
	var bitmaptext:FlxBitmapText;

	override public function create() {
        
        FlxG.camera.bgColor = FlxColor.WHITE;
        super.create();
        
        //var sprite = new FlxSprite();
		//sprite.loadGraphic("assets/images/title.png");
        //sprite.y = FlxG.height/3;
		//sprite.screenCenter(X);
		//add(sprite);

		bitmapfont = FlxBitmapFont.fromAngelCode("assets/images/bulky.png","assets/data/bulky.xml");
		bitmaptext = new FlxBitmapText(bitmapfont);
		bitmaptext.y = 64;
		bitmaptext.alignment = FlxTextAlign.CENTER;
		bitmaptext.text = "Hold your horses!\n\nWe know you're excited!\n\nSo are we!\n\nJust sit back\n\nThe Game Will Be Finished\nSoon!";
		add(bitmaptext);
		/*bitmaptext = new FlxBitmapText(bitmapfont);
		bitmaptext.y = 96;
		bitmaptext.text = "We know youre excited!";
		add(bitmaptext);
		
		bitmaptext = new FlxBitmapText(bitmapfont);
		bitmaptext.y = 128;
		bitmaptext.text = "So are we!";
		add(bitmaptext);
		bitmaptext = new FlxBitmapText(bitmapfont);
		bitmaptext.y = 160;
		bitmaptext.text = "Please wait until the game is finished!";
		add(bitmaptext);*/
		
	}
}
