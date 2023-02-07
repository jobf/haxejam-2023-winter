package engine.building;

import engine.actor.Actor;
import engine.building.Layout.Location;
import engine.building.Layout.Placement;
import engine.map.Data.FloorPlan;
import engine.tasks.Item;
import engine.tasks.Task;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;

class Apartment extends FlxGroup
{
	public var player(default, null):Actor;
	public var tasks(default, null):FlxTypedGroup<Task>;
	public var walls(default, null):FlxTypedGroup<Wall>;
	public var laundry(default, null):FlxTypedGroup<Item>;
	public var help_texts(default, null):FlxGroup;
	
	var empty_spots:Array<Placement>;
	var edge_left:Int;
	var edge_top:Int;
	var grid_size:Int;


	public function new(plan:FloorPlan, edge_left:Int, edge_top:Int, grid_size:Int)
	{
		super();
		this.edge_left = edge_left;
		this.edge_top = edge_top;
		this.grid_size = grid_size;

		walls = new FlxTypedGroup<Wall>();
		add(walls);
		
		tasks = new FlxTypedGroup<Task>();
		add(tasks);

		laundry = new FlxTypedGroup<Item>();
		add(laundry);

		help_texts = new FlxGroup();


		empty_spots = [];

		for (placement in Layout.placements(plan, edge_left, edge_top, grid_size))
		{
			switch placement.location
			{
				case WALL:
					place_wall(placement);
				case PLAYER:
					place_player(placement);
				case EMPTY:
					empty_spots.push(placement);
				case _: place_task(placement);
			}
		}

		// shuffle the empty spots before distributing items
		FlxG.random.shuffle(empty_spots);

		var index_empty_spot = 0;

		// distribute laundry
		var total_dirty_laundry = 8;
		for (i in 0...total_dirty_laundry)
		{
			place_dirty_laundry(empty_spots[i]);
			index_empty_spot++;
		}
	}
	
	function place_player(spot:Placement)
	{
		player = new Actor({
			asset_path: "assets/images/blob-64.png",
			x_start: spot.x_pixel,
			y_start: spot.y_pixel,
			x_velocity_max: 400,
			y_velocity_max: 400,
			drag_multiplier: 6
		});

		add(player);
	}

	function place_wall(spot:Placement)
	{
		walls.add(new Wall({
			x: spot.x_pixel,
			y: spot.y_pixel,
			size: grid_size,
			color: 0x6a5f49ff
		}));
	}

	public var task_list(default, null):Map<Location, Task> = [];
	
	function place_task(placement:Placement){
		var task_size = 48;
		var toilet_center = task_size / 2;
		var task = new Task({
			x: Std.int(placement.x_pixel - toilet_center),
			y: Std.int(placement.y_pixel - toilet_center),
			size: task_size,
			color: get_color(placement.location),
			task_duration_seconds: get_task_duration(placement.location), 
			task_cooloff_seconds: get_task_cool_off(placement.location), // only let it happen once per session
			help: get_task_help_message(placement.location),
		}, placement);
		tasks.add(task);
		add(task.progress_meter);
		task_list[placement.location] = task;
		help_texts.add(task.help);
	}

	function get_task_help_message(location:Location):String {
		return switch location {
			case BASKET: "BRING ME CLOTHES !";
			case LAVATORY: "STAY WITH ME !";
			case _: "";
		}
	}

	function get_task_duration(location:Location):Float {
		return switch location {
			case BASKET: 1.0;
			case LAVATORY: 5.0;
			case _: 0.0;
		}
	}

	function get_task_cool_off(location:Location):Float {
		return switch location {
			case BASKET: 4.0;
			case _: 999; // 999 long enough to prevent reset before session end
		}
	}

	function get_color(location:Location):FlxColor {
		return switch location {
			case EMPTY: FlxColor.TRANSPARENT;
			case PLAYER: 0xC0B12531;
			case WALL:0x6a5f49ff;
			case BASKET:0xffffffff;
			case LAVATORY:0xff876b61;
		}
	}
	

	function place_dirty_laundry(spot:Placement)
	{
		laundry.add(new Item({
			x: spot.x_pixel,
			y: spot.y_pixel,
			size: grid_size,
			color: 0xFFf3edc6
		}));
	}
}
