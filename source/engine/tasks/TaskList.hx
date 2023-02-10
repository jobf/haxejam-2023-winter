package engine.tasks;

import engine.building.Layout.Location;
import engine.map.Data.Room;

class TaskList
{
	var tasks_to_complete:Array<Location>;
	var completed_tasks:Array<Location>;
	var on_task_complete:Map<Location, () -> Void> = [];

	public var seconds_allotted(default, null):Float;

	public function new(tasks_to_complete:Array<Location>)
	{
		this.tasks_to_complete = tasks_to_complete;
		this.completed_tasks = [];
		#if speedrun
		task_time_allowed = 2;
		#end
		
		// start with somethign to give em a change
		seconds_allotted = 10;
		var time_reduction = 0.1; // knock some time off to uyp the urgency
		for (location in tasks_to_complete) {
			var task_duration = TaskData.configurations[location].task_duration_seconds;
			var reduction = task_duration * time_reduction;
			seconds_allotted += (task_duration - reduction);
		}
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
			// special case for laundry
			if(location == BASKET){
				on_complete();
			}
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
			frame_index: 32,
			frame_index_complete: 40,
			room: WASH,
			task_duration_seconds: 0.25,
			task_cooloff_seconds: 0.0,
			hint_text: "BRING ME CLOTHES !",
			is_repeatable: true
		},
		LAVATORY => {
			frame_index: 48,
			frame_index_complete: 56,
			room: WC,
			task_duration_seconds: 3.0,
			is_repeatable: false,
		},
		RUG => {
			frame_index: 16,
			frame_index_complete: 24,
			room:EMPTY,
			task_duration_seconds: 1.5,
			is_repeatable: false,
		},
		BED => {
			frame_index: 0,
			frame_index_complete: 8,
			room:BEDROOM,
			task_duration_seconds: 2.0,
			is_repeatable: false,
		}
	];
}

@:structInit
class TaskDetails
{
	public var time_bonus(get, never):Float;

	public var room:Room;
	public var frame_index:Int;
	public var frame_index_complete:Int;
	public var frame_size:Int = 128;
	public var task_duration_seconds:Float;
	public var task_cooloff_seconds:Float = 999;
	public var completed_time_bonus_percentage:Float = 0.7;
	public var is_repeatable:Bool;
	public var hint_text:String = "STAY WITH ME !";
	public var hint_cool_off_text:String = "";
	public var hint_completed_text:String = "TASK COMPLETE !";
	public var asset_path:String = "assets/images/tasks-128.png";
	public var hint_duration_seconds:Float = 1.25;

	function get_time_bonus():Float {
		return completed_time_bonus_percentage * task_duration_seconds;
	}
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
		var tasks =  [BASKET];

		#if alltasks
		completed_session_count = 999;
		#end

		if(completed_session_count > 1){
			tasks.push(LAVATORY);
		}

		if(completed_session_count > 3){
			tasks.push(BED);
		}

		if(completed_session_count >= 5){
			tasks.push(RUG);
		}

		return tasks;
	}
}
