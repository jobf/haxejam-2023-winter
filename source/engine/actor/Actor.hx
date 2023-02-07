package engine.actor;

import flixel.FlxSprite;
import flixel.util.FlxColor;

@:allow(engine.actor.Actor)
@:structInit
class ActorConfig
{
	var x_start:Int;
	var y_start:Int;
	var x_velocity_max:Float;
	var y_velocity_max:Float;

	/** larger drag_multiplier makes stopping faster**/
	var drag_multiplier:Float;

	var size:Int = 64;
	var color:FlxColor = 0xC0B12531;
}

@:allow(engine.actor.Controller)
class Actor extends FlxSprite
{
	var x_offset_center:Float;

	public var config(default, null):ActorConfig;
	public var can_move_outside_bounds:Bool = false;
	public var on_start_moving:() -> Void = () -> trace("start moving");
	public var on_stop_moving:() -> Void = () -> trace("stop moving");

	public function new(config:ActorConfig)
	{
		super(config.x_start, config.y_start);
		this.config = config;
		x_offset_center = config.size / 2;

		// init 1x1 pixel graphic so it can be scaled to any size
		makeGraphic(1, 1, config.color);

		// scale t0 actual size
		scale.x = config.size;
		scale.y = config.size;

		// increase hitbox because it starts at 1 x 1
		width = config.size * 0.7;
		height = config.size * 0.7;

		// re-center hitbox because everything has changed
		centerOffsets();

		// set top speed
		maxVelocity.x = config.x_velocity_max;
		maxVelocity.y = config.y_velocity_max;

		// set slow down
		drag.x = maxVelocity.x * config.drag_multiplier;
		drag.y = maxVelocity.y * config.drag_multiplier;
	}

	public function set_direction_x(direction:Int)
	{
		facing = direction > 0 ? RIGHT : LEFT;
		acceleration.x = drag.x * direction;
		on_start_moving();
	}

	public function set_direction_y(direction:Int)
	{
		facing = direction > 0 ? DOWN : UP;
		acceleration.y = drag.y * direction;
		on_start_moving();
	}

	public function stop(notify_stopped:Bool)
	{
		acceleration.set(0, 0);
		if(notify_stopped){
			on_stop_moving();
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
