package engine.actor;

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
	
	function stop(){
		actor.stop();
	}

	public function update(keys:FlxKeyboard)
	{
		stop();
		
		if (keys.pressed.LEFT)
		{
			move_left();
		}
		if (keys.pressed.RIGHT)
		{
			move_right();
		}
		if (keys.pressed.UP)
		{
			move_up();
		}
		if (keys.pressed.DOWN)
		{
			move_down();
		}
	}
}
