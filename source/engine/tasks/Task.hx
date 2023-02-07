package engine.tasks;

import engine.building.Layout;
import engine.flx.CallbackFlxBar;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

@:structInit
class TaskConfig
{
	public var x:Int;
	public var y:Int;
	public var color:FlxColor;
	public var size:Int = 48;
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
	public var progress_meter:CallbackFlxBar;
	public var placement:Placement;
	
	public function new(config:TaskConfig, placement:Placement)
	{
		super(config.x, config.y);
		this.config = config;
		this.placement = placement;
		makeGraphic(config.size, config.size, config.color);
		immovable = true;
		task_remaining_seconds = config.task_duration_seconds;
		is_cooling_off = false;
		timer = new FlxTimer();
		progress_meter = new CallbackFlxBar(x + config.size + 4, y, BOTTOM_TO_TOP, 20, 30, () -> get_progress(), 0, get_duration());
		trace('init task : $x $y');
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


	inline function get_progress():Float
	{
		return task_remaining_seconds;
	}

	inline function get_duration():Float
	{
		return config.task_duration_seconds;
	}
}
