package engine.tasks;

import engine.building.Layout;
import engine.flx.CallbackFlxBar;
import engine.map.BluePrint.Rectangle;
import engine.map.Data;
import engine.tasks.TaskList.TaskDetails;
import engine.ui.Fonts;
import flixel.FlxSprite;
import flixel.text.FlxBitmapText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

@:structInit
class TaskConfig
{
	public var x:Int;
	public var y:Int;
	public var color:FlxColor;
	public var details:Null<TaskDetails> = null;
}

@:structInit
class TaskEvents{
	public var on_setup:Null<Void->Void> = null;
	public var is_complete:Null<Void->Bool> = null;
	public var on_complete:Null<Void->Void> = null;
	public var show_hint:Null<Void->Void> = null;
}

@:structInit
class TaskZoneConfig{
	public var x_pixel:Int;
	public var y_pixel:Int;
	public var w_pixel:Int;
	public var h_pixel:Int;
	public var rect:Rectangle;
	public var room:Room;
	public var color:FlxColor;
}

class TaskZone extends  FlxSprite{
	public var config(default, null):TaskZoneConfig;

	public function new(config:TaskZoneConfig){
		super(config.x_pixel, config.y_pixel);
		this.config = config;
		makeGraphic(config.w_pixel, config.h_pixel, config.color, true);
	}
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
	public var hint(default, null):Hint;
	var hint_state:HintState;

	
	public function new(config:TaskConfig, placement:Placement)
	{
		super(config.x, config.y);
		this.config = config;
		this.placement = placement;
		loadGraphic(config.details.asset_path, true, config.details.frame_size, config.details.frame_size);
		animation.frameIndex = config.details.frame_index;
		immovable = true;
		task_remaining_seconds = config.details.task_duration_seconds;
		is_cooling_off = false;
		timer = new FlxTimer();
		progress_meter = new CallbackFlxBar(x + config.details.frame_size + 4, y, BOTTOM_TO_TOP, 20, 30, () -> get_progress(), 0, get_duration());
		hint = new Hint(config.details);
		hint_state = READY;
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
				animation.frameIndex = config.details.frame_index_complete;
				// trace('is cooling off');
				is_cooling_off = true;
				hint_state = COOLING_OFF;
				if(config.details.is_repeatable){
					// trace('starting cool off timer');
					// cool off before resetting to allow repeat

					if(config.details.task_cooloff_seconds > 0){
						timer.start(config.details.task_cooloff_seconds, timer -> {
							task_remaining_seconds = config.details.task_duration_seconds;
							is_cooling_off = false;
							hint_state = READY;
							// trace('cool off complete');
						});
					}
					else{
						// special case for laundry
						is_cooling_off = false;
						hint_state = READY;
						task_remaining_seconds = config.details.task_duration_seconds;
					}
				}
				else{
					hint_state = COMPLETE;
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
		return config.details.task_duration_seconds;
	}

	public function show_hint() {
		hint.show_hint(hint_state);
	}
}

enum HintState{
	IDLE;
	READY;
	COOLING_OFF;
	COMPLETE;
}

/*
	public var hint_text:String = "STAY WITH ME !";
	public var hint_cool_off_text:String = "CANNOT USE AGAIN TOO SOON";
	public var hint_completed_text:String = "TASK COMPLETE !";
*/
class Hint{
	var hint_states:Map<HintState, FlxBitmapText>;
	public var hints:Array<FlxBitmapText>;
	var task_details:TaskDetails;
	var timer:FlxTimer;
	var current_state:HintState;



	public function new(task_details:TaskDetails){
		this.task_details = task_details;
		hint_states = [];
		hints = [];
		current_state = IDLE;
		timer = new FlxTimer();
		add_hint(task_details.hint_text, READY);
		add_hint(task_details.hint_cool_off_text, COOLING_OFF);
		add_hint(task_details.hint_completed_text, COMPLETE);
	}

	function add_hint(text:String, state:HintState){
		var hint = new FlxBitmapText(Fonts.normal());
		hint.text = text;
		hint.screenCenter();
		hint.y -= 130;
		hint.visible = false;
		hint.scrollFactor.set(0,0);
		hint_states[state] = hint;
		hints.push(hint);
	}

	public function show_hint(state:HintState){
		if(timer.active && state == current_state){
			return;
		}
		
		for (text in hints) {
			text.visible = false;
		}
		// trace(state);
		current_state = state;
		hint_states[state].visible = true;

		timer.start(task_details.hint_duration_seconds, timer -> {
			hint_states[state].visible = false;
			current_state = IDLE;
		});
	}

}