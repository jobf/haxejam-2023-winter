package engine.tasks;

import engine.building.Layout.Location;

class TaskList
{
	var tasks_to_complete:Array<Location>;
	var completed_tasks:Array<Location>;
	var on_task_complete:Map<Location, () -> Void> = [];

	public function new(tasks_to_complete:Array<Location>)
	{
		this.tasks_to_complete = tasks_to_complete;
		this.completed_tasks = [];
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
		var on_complete = on_task_complete.exists(location)
			? on_task_complete[location]
			: () -> return;

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
			task_duration_seconds: 0.5,
			task_cooloff_seconds: 0.5,
			hint_text: "BRING ME CLOTHES !",
			is_repeatable: true
		},
		LAVATORY => {
			task_duration_seconds: 5.0,
			is_repeatable: false,
			hint_text: "STAY WITH ME !",
		}
	];
}

@:structInit
class TaskDetails
{
	public var task_duration_seconds:Float;
	public var task_cooloff_seconds:Float = 999;
	public var is_repeatable:Bool;
	public var hint_text:String;
	public var hint_cool_off_text:String = "CANNOT USE AGAIN TOO SOON";
	public var hint_completed_text:String = "TASK COMPLETE !";
}
