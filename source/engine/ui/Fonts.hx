package engine.ui;

import flixel.graphics.frames.FlxBitmapFont;
import flixel.math.FlxPoint;

class Fonts{
	static var cached_normal:FlxBitmapFont;

	static public function normal():FlxBitmapFont {
		if(cached_normal == null){
			cached_normal = FlxBitmapFont.fromMonospace("assets/images/font-24.png", FlxBitmapFont.DEFAULT_CHARS, FlxPoint.get(24, 24));
		}
		return cached_normal;
	}
}