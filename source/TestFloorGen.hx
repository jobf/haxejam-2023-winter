package;

import flixel.FlxGame;
import openfl.display.Sprite;

class TestFloorGen extends Sprite
{
	public function new()
	{
		super();
		var zoom = 1;
		var update_rate = 60;
		var draw_rate = 60;
		var skip_splash = true;
		var start_full_screen = false;
		addChild(new FlxGame(0, 0, FloorGenState, zoom, update_rate, draw_rate, skip_splash, start_full_screen));
	}
}
