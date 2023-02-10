package engine.tasks;

import engine.building.Layout.Location;
import engine.map.Data.Room;

class TaskList
{
	var tasks_to_complete:Array<Location>;
	var completed_tasks:Array<Location>;
	var on_task_complete:Map<Location, () -> Void> = [];

	public var seconds_allotted(default, null):Int;

	public function new(tasks_to_complete:Array<Location>)
	{
		this.tasks_to_complete = tasks_to_complete;
		this.completed_tasks = [];
		var task_time_allowed = 15; // different time allowance per task type
		#if speedrun
		task_time_allowed = 2;
		#end

		seconds_allotted = tasks_to_complete.length * task_time_allowed;
	}

	public function is_list_complete():Bool
	{
		return completed_tasks.length == tasks_to_complete.length;
	}

	public function mark_task_complete(location:Location)
	{
		completed_tasks.push(location);
	}

	public function set_task_on_complete(location:Location, on_complete:Void->Void)
	{
		on_task_complete[location] = on_complete;
	}

	public function get_task_on_complete(location:Location):Void->Void
	{
		var on_complete = on_task_complete.exists(location) ? on_task_complete[location] : () -> return;

		return () ->
		{
			if (!completed_tasks.contains(location))
			{
				completed_tasks.push(location);
				on_complete();
			}
		}
	}
}

class TaskData
{
	public static var configurations:Map<Location, TaskDetails> = [
		BASKET => {
			room: WASH,
			task_duration_seconds: 0.5,
			task_cooloff_seconds: 0.5,
			hint_text: "BRING ME CLOTHES !",
			is_repeatable: true
		},
		LAVATORY => {
			room: WC,
			task_duration_seconds: 5.0,
			is_repeatable: false,
			hint_text: "STAY WITH ME !",
		}
	];
}

@:structInit
class TaskDetails
{
	public var room:Room;
	public var task_duration_seconds:Float;
	public var task_cooloff_seconds:Float = 999;
	public var is_repeatable:Bool;
	public var hint_text:String;
	public var hint_cool_off_text:String = "CANNOT USE AGAIN TOO SOON";
	public var hint_completed_text:String = "TASK COMPLETE !";
}

class Progression
{
	public static var is_session_ended:Bool;
	public static var completed_session_count:Int;
	public static var completed_session_time:Float;

	public static function reset(is_hard_reset:Bool = false)
	{
		if (is_hard_reset)
		{
			completed_session_count = 0;
			completed_session_time = 0;
		}

		is_session_ended = false;
	}

	public static function get_tasks():Array<Location>
	{
		if(completed_session_count > 1){
			return [BASKET, LAVATORY];
		}

		// etc . . . 
		// if(completed_session_count > 3){
		// 	return [BASKET, LAVATORY, FISH];
		// }


		return [BASKET];
	}
}
