package engine.tasks;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

@:structInit
class TaskConfig
{
	public var x:Int;
	public var y:Int;
	public var color:FlxColor;
	public var size:Int;
	public var task_duration_seconds:Float;
	public var task_cooloff_seconds:Float;
}

class Task extends FlxSprite
{
	public var config:TaskConfig;

	var task_remaining_seconds:Float;
	// var cooloff_remaining_seconds:Float;
	var is_player_here:Bool;
	var timer:FlxTimer;
	var is_cooling_off:Bool;



	public function new(config:TaskConfig)
	{
		super(config.x, config.y);
		this.config = config;
		makeGraphic(config.size, config.size, config.color);
		immovable = true;
		task_remaining_seconds = config.task_duration_seconds;
		is_cooling_off = false;
		trace('made basket $x $y');
		timer = new FlxTimer();
	}

	public function decrease_task_remaining(seconds:Float, on_task_complete:() -> Void)
	{
		if(is_cooling_off){
			return;
		}
		
		if (task_remaining_seconds > 0)
		{
			task_remaining_seconds -= seconds;
			if (task_remaining_seconds <= 0)
			{
				on_task_complete();
				is_cooling_off = true;
				// cooloff_remaining_seconds = config.task_cooloff_seconds;
				timer.start(config.task_cooloff_seconds, timer -> {
					task_remaining_seconds = config.task_duration_seconds;
					is_cooling_off = false;
					trace('cool off complete');
				});
			}
		}
	}


	public function get_progress():Float
	{
		return task_remaining_seconds;
	}

	public function get_duration():Float
	{
		return config.task_duration_seconds;
	}
}
