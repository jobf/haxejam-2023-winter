package engine.actor;

import flixel.input.keyboard.FlxKey;
import flixel.input.keyboard.FlxKeyboard;

class Controller
{
	var actor:Actor;

	public function new(actor:Actor)
	{
		this.actor = actor;
	}

	function move_left()
	{
		actor.set_direction_x(-1);
	}

	function move_right()
	{
		actor.set_direction_x(1);
	}

	function move_up()
	{
		actor.set_direction_y(-1);
	}

	function move_down()
	{
		actor.set_direction_y(1);
	}

	function stop(notify_stopped:Bool)
	{
		actor.stop(notify_stopped);
	}

	var keys_left:Array<FlxKey> = [LEFT, A];
	var keys_right:Array<FlxKey> = [RIGHT, D];
	var keys_up:Array<FlxKey> = [UP, W];
	var keys_down:Array<FlxKey> = [DOWN, S];
	var keys_all_movement:Array<FlxKey> = [LEFT, A, RIGHT, D, UP, W, DOWN, S];

	public function update(keys:FlxKeyboard)
	{
		stop(false);

		if (keys.anyPressed(keys_left))
		{
			move_left();
		}
		if (keys.anyPressed(keys_right))
		{
			move_right();
		}
		if (keys.anyPressed(keys_up))
		{
			move_up();
		}
		if (keys.anyPressed(keys_down))
		{
			move_down();
		}
		if(keys.anyJustReleased(keys_all_movement)){
			stop(true);
		}
	}
}
