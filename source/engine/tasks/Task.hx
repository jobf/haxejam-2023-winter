package engine.tasks;

import engine.building.Layout;
import engine.flx.CallbackFlxBar;
import engine.ui.Fonts;
import flixel.FlxSprite;
import flixel.text.FlxBitmapText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

@:structInit
class TaskConfig
{
	public var hint:String = "";
	public var x:Int;
	public var y:Int;
	public var color:FlxColor;
	public var size:Int = 48;
	public var task_duration_seconds:Float;
	public var task_cooloff_seconds:Float;
	public var is_repeatable:Bool = false;
}

class Task extends FlxSprite
{
	public var config:TaskConfig;

	var task_remaining_seconds:Float;
	var is_player_here:Bool;
	var timer:FlxTimer;
	var is_cooling_off:Bool;
	public var progress_meter:CallbackFlxBar;
	public var placement:Placement;
	public var hint:FlxBitmapText;
	var timer_hint:FlxTimer;
	var hint_visible_duration:Float = 2.0;
	var is_hint_available:Bool;


	
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
		timer_hint = new FlxTimer();
		progress_meter = new CallbackFlxBar(x + config.size + 4, y, BOTTOM_TO_TOP, 20, 30, () -> get_progress(), 0, get_duration());
		hint = new FlxBitmapText(Fonts.normal());
		hint.text = config.hint;
		hint.screenCenter();
		hint.y -= 130;
		hint.visible = false;
		hint.scrollFactor.set(0,0);
		trace('init task : $x $y');
	}

	public function decrease_task_remaining(seconds:Float, on_task_complete:() -> Void)
	{
		if(is_cooling_off){
			// hint.visible = false;
			return;
		}
		
		if (task_remaining_seconds > 0)
		{
			// hint.visible = true;
			task_remaining_seconds -= seconds;
			if (task_remaining_seconds <= 0)
			{
				on_task_complete();
				trace('is cooling off');
				is_cooling_off = true;
				if(config.is_repeatable){
					trace('starting cool off timer');
					// cool off before resetting to allow repeat
					timer.start(config.task_cooloff_seconds, timer -> {
						task_remaining_seconds = config.task_duration_seconds;
						is_cooling_off = false;
						trace('cool off complete');
					});
				}
				else{
					is_hint_available = false;
				}
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

	public function show_hint() {
		// var can_show_hint = config.is_repeatable || tim
		// if(config.is_repeatable)
		hint.visible = true;
		timer_hint.start(hint_visible_duration, timer -> {
			hint.visible = false;
		});
	}
}
