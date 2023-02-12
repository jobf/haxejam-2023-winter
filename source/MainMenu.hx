package;

import engine.audio.Music;
import engine.tasks.TaskList;
import engine.ui.Fonts;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;

class MainMenu extends FlxState
{
	var instructions:FlxBitmapText;
	var title:FlxBitmapText;


	override public function create()
	{
		FlxG.camera.bgColor = FlxColor.WHITE;
		super.create();

		add(new FlxSprite(0, 64, 'assets/images/title.png').screenCenter(X));

		instructions = new FlxBitmapText(Fonts.normal());
		instructions.alignment = FlxTextAlign.CENTER;
		instructions.text = 'Press ENTER\n\nto begin!';
		instructions.screenCenter(X);
		instructions.y = FlxG.height - instructions.height - 64;
		add(instructions);
		Music.play_menu_music();

		var timer = new FlxTimer();
		timer.start(1.5, timer -> FlxSpriteUtil.flicker(instructions, 100, 0.25, true, true));
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if(FlxG.keys.justReleased.ENTER){
			Music.stop();
			var is_hard_reset = true;
			Progression.reset(is_hard_reset);
			FlxG.switchState(new PlayStateDungen());
		}
	}
}
