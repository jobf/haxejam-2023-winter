package engine.building;

import flixel.FlxSprite;
import flixel.util.FlxColor;

@:structInit
class WallConfig
{
	public var x:Int;
	public var y:Int;
	public var color:FlxColor;
	public var size:Int;
}

class Wall extends FlxSprite
{
	public var config:WallConfig;

	public function new(config:WallConfig)
	{
		super(config.x, config.y);
		this.config = config;
		makeGraphic(config.size, config.size, config.color);
		immovable = true;
	}
}
