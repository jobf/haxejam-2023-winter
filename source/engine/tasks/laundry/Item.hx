package engine.tasks.laundry;

import flixel.FlxSprite;
import flixel.util.FlxColor;

@:structInit
class ItemConfig{
	public var x:Float;
	public var y:Float;
	public var color:FlxColor;
	public var size:Int;
}

class Item extends FlxSprite{
	public var config:ItemConfig;

	public function new(config:ItemConfig){
		super(config.x, config.y);
		this.config = config;
		makeGraphic(config.size, config.size, config.color);
		immovable = true;
	}
}