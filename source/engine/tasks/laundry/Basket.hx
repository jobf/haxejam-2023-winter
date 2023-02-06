package engine.tasks.laundry;

import flixel.FlxSprite;
import flixel.util.FlxColor;

@:structInit
class BasketConfig{
	public var x:Int;
	public var y:Int;
	public var color:FlxColor;
	public var size:Int;
}

class Basket extends FlxSprite{
	public var config:BasketConfig;

	public function new(config:BasketConfig){
		super(config.x, config.y);
		this.config = config;
		makeGraphic(config.size, config.size, config.color);
		immovable = true;
		trace('made basket $x $y');
	}
}