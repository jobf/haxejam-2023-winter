package engine.tasks;

import flixel.FlxSprite;
import flixel.util.FlxColor;

@:structInit
class ItemConfig{
	public var x:Float;
	public var y:Float;
	public var color:FlxColor;
	public var size:Int;
	public var asset_path:Null<String> = null;
}

class Item extends FlxSprite{
	public var config:ItemConfig;

	public function new(config:ItemConfig){
		super(config.x, config.y);
		this.config = config;
		if(config.asset_path == null){
			makeGraphic(config.size, config.size, config.color);
		}
		else{
			loadGraphic(config.asset_path, true, config.size, config.size);
		}
		immovable = true;
	}
}