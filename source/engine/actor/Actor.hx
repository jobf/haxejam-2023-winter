package engine.actor;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
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

	var asset_path:String = "";
	var is_animated:Bool = false;
	var animation_frame_rate: Int = 12;
	var animation_frame_size: Int = 64;
	public var animation_frame_index_idle: Int = 0;
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
		if(config.asset_path.length > 0){
			loadGraphic(config.asset_path, config.is_animated, config.animation_frame_size, config.animation_frame_size);
			if(config.is_animated){
				set_up_animations();
			}
		}
		else{
			makeGraphic(1, 1, config.color);
			// scale to actual size
			scale.x = config.size;
			scale.y = config.size;
		}

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

	function set_up_animations() {
		var num_columns = 8;
		var directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"];
		for (row => d in directions) {
			var start_frame = row * num_columns;
			var end_frame = start_frame + num_columns;
			animation.add(d, [for(n in start_frame...end_frame) n], config.animation_frame_rate);
		}
		animation.play("S");
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

	public function stop(notify_stopped:Bool, is_hard_stop:Bool = false)
	{
		acceleration.set(0, 0);
		if(is_hard_stop){
			velocity.set(0, 0);
		}
		if(notify_stopped){
			on_stop_moving();
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		var is_idle = velocity.x == 0 && velocity.y == 0;
		if(is_idle){
			animation.play(animation.curAnim.name, true, config.animation_frame_index_idle);
		}
		else{
			var direction:Cardinal = velocity_to_cardinal(velocity);
			var animation_name:String = direction + '';
			animation.play(animation_name);
		}
	}

	function velocity_to_cardinal(velocity:FlxPoint):Cardinal {
		var direction:Cardinal = S;
		
		if(velocity.y > 0){
			direction = S;
			if(velocity.x != 0){
				direction = velocity.x > 0 ? SE : SW;
			}
			return direction;
		}

		if(velocity.y < 0){
			direction = N;
			if(velocity.x != 0){
				direction = velocity.x > 0 ? NE : NW;
			}
			return direction;
		}

		if(velocity.x > 0){
			direction = E;
			if(velocity.y != 0){
				direction = velocity.y > 0 ? SE : NE;
			}
			return direction;
		}

		if(velocity.x < 0){
			direction = W;
			if(velocity.y != 0){
				direction = velocity.y > 0 ? SW : NW;
			}
			return direction;
		}

		return direction;
	}
}

enum Cardinal{
	N;
	NE;
	E;
	SE;
	S;
	SW;
	W;
	NW;
}
