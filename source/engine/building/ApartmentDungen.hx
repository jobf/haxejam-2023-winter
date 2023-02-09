package engine.building;

import engine.actor.Actor;
import engine.building.Layout.Location;
import engine.building.Layout.Placement;
import engine.map.BluePrint.RoomSpace;
import engine.map.BluePrint;
import engine.map.Canvas.AsciiCanvas;
import engine.map.Data.FloorPlan;
import engine.tasks.Item;
import engine.tasks.Task;
import engine.tasks.TaskList.TaskData;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.tile.FlxBaseTilemap;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;

class ApartmentDungen extends FlxGroup
{
	public var player(default, null):Actor;
	public var tasks(default, null):FlxTypedGroup<Task>;
	public var laundry(default, null):FlxTypedGroup<Item>;
	public var hint_texts(default, null):FlxGroup;

	var empty_spots:Array<Placement>;
	var edge_left:Int = 0;
	var edge_top:Int = 0;
	var grid_size:Int;
	var door_width:Int = 4;
	var rng:RandomInt;
	var map_auto(default, null):FlxTilemap;

	public function new(rooms:Array<RoomSpace>, w:Int, h:Int, grid_size:Int, tasks_to_complete:Array<Location>)
	{
		super();

		this.grid_size = grid_size;
		rng = FlxG.random.int;
		
		var interior_walls = new AsciiCanvas(w, h);

		var first = 0;
		var small_rooms = rooms.splice(first, 3);
		var large_rooms = rooms.splice(rooms.length - 1, rooms.length);
		var all_rooms = small_rooms.concat(large_rooms);

		// draw walls
		for (i => r in all_rooms)
		{
			// trace('\n $i room ${r.walls.w} x ${r.walls.h}');
			// trace('$i  has ${r.interior_walls.length} internal walls');

			interior_walls.draw_rectangle(r.walls, i + '', 0, 0);
			var wall_symbol = i + '';
			// var wall_symbol = ",";
			var wall_symbol = "#";
			for (w in r.interior_walls)
			{
				interior_walls.draw_line(w.x_start, w.y_start, w.x_end, w.y_end, wall_symbol);
			}
		}

		// add doors to all walls
		for (i => r in all_rooms)
		{
			for (w in r.all_walls)
			{
				var width = w.x_start + w.x_end;
				var height = w.y_start + w.y_end;
				var x_center = Std.int(width / 2);
				var y_center = Std.int(height / 2);
				var center:Int2 = {
					x: x_center,
					y: y_center
				}

				// trace('room $i door center ${center.x} ${center.y}');

				var door_center = Std.int(door_width / 2);
				var door_symbol = "+";

				var x_start = 0;
				var y_start = 0;
				var x_end = 0;
				var y_end = 0;

				switch w.edge
				{
					case TOP:
						x_start = center.x - door_center;
						x_end = center.x + door_center;
						y_start = center.y;
						y_end = center.y;
					case BOTTOM:
						x_start = center.x - door_center;
						x_end = center.x + door_center;
						y_start = center.y;
						y_end = center.y;
					case LEFT:
						x_start = center.x;
						x_end = center.x;
						y_start = center.y - door_center;
						y_end = center.y + door_center;
					case RIGHT:
						x_start = center.x;
						x_end = center.x;
						y_start = center.y - door_center;
						y_end = center.y + door_center;
				}

				interior_walls.draw_line(x_start, y_start, x_end, y_end, door_symbol);
			}
		}

		var external:Rectangle = {
			y: 0,
			x: 0,
			w: w - 1,
			h: h - 1
		}
		interior_walls.draw_rectangle(external, "#", 0, 0);

		map_auto = new FlxTilemap();
		var csv = interior_walls.csv();
		// trace(csv);

		map_auto.loadMapFromCSV(csv, "assets/images/auto-tiles-32-debug.png", grid_size, grid_size, FlxTilemapAutoTiling.AUTO);
		add(map_auto);

		tasks = new FlxTypedGroup<Task>();
		add(tasks);

		laundry = new FlxTypedGroup<Item>();
		add(laundry);

		hint_texts = new FlxGroup();

		place_player({
			y_pixel: 64,
			x_pixel: 64,
			location: PLAYER
		});

		var task_placements:Map<Location, Placement> = [];

		var task_room = rooms[0];
		var x_task_location = Std.int(task_room.walls.x +  task_room.walls.w / 2);
		var y_task_location = Std.int(task_room.walls.x +  task_room.walls.w / 2);
		interior_walls.set_cell(x_task_location, y_task_location, "B");
		var placement:Placement = {
			y_pixel: x_task_location * grid_size,
			x_pixel: x_task_location * grid_size,
			location: BASKET
		}
		task_placements[BASKET] = placement;

		var taks_room = rooms[1];
		var x_task_location = Std.int(taks_room.walls.x +  taks_room.walls.w / 2);
		var y_task_location = Std.int(taks_room.walls.x +  taks_room.walls.w / 2);
		interior_walls.set_cell(x_task_location, y_task_location, "L");
		var placement:Placement = {
			y_pixel: x_task_location * grid_size,
			x_pixel: x_task_location * grid_size,
			location: LAVATORY
		}
		task_placements[LAVATORY] = placement;

		for(location in tasks_to_complete){
			if(task_placements.exists(location)){
				place_task(task_placements[location]);
			}
			else{
				trace('!!! WARNING no placement configured for $location');
			}
		}

		empty_spots = interior_walls.get_empty_spaces(grid_size);

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
			asset_path: "assets/images/laundry-animation-8-directional-debug.png",
			is_animated: true,
			x_start: spot.x_pixel,
			y_start: spot.y_pixel,
			x_velocity_max: 400,
			y_velocity_max: 400,
			drag_multiplier: 6
		});

		trace('player at ${player.x} ${player.y}');
		add(player);
	}

	public var task_list(default, null):Map<Location, Task> = [];

	function place_task(placement:Placement)
	{
		var task_size = 48;
		var toilet_center = task_size / 2;
		var task = new Task({
			x: Std.int(placement.x_pixel - toilet_center),
			y: Std.int(placement.y_pixel - toilet_center),
			size: task_size,
			color: get_color(placement.location),
			details: TaskData.configurations[placement.location]
		}, placement);
		
		tasks.add(task);
		add(task.progress_meter);
		task_list[placement.location] = task;
		hint_texts.add(task.hint);
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


	function get_color(location:Location):FlxColor
	{
		return switch location
		{
			case EMPTY: FlxColor.TRANSPARENT;
			case PLAYER: 0xC0B12531;
			case WALL: 0x6a5f49ff;
			case BASKET: 0xffffffff;
			case LAVATORY: 0xff876b61;
		}
	}

}
