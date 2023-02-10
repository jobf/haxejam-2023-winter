package;

import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();

		var zoom = 1;
		var update_rate = 60;
		var draw_rate = 60;
		var skip_splash = true;
		var start_full_screen = false;
		#if original
		addChild(new FlxGame(0, 0, PlayState, zoom, update_rate, draw_rate, skip_splash, start_full_screen));
		#else
		addChild(new FlxGame(0, 0, PlayStateDungen, zoom, update_rate, draw_rate, skip_splash, start_full_screen));
		#end


		FlxG.mouse.useSystemCursor = true;
	}
}
