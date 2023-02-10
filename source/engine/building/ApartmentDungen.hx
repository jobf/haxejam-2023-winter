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
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tile.FlxBaseTilemap;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;

class ApartmentDungen extends FlxGroup
{
	public var player(default, null):Actor;
	public var tasks(default, null):FlxTypedGroup<Task>;
	public var task_zones(default, null):FlxTypedGroup<FlxSprite>;
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

		task_zones = new FlxTypedGroup<FlxSprite>();
		add(task_zones);
		
		tasks = new FlxTypedGroup<Task>();
		add(tasks);

		laundry = new FlxTypedGroup<Item>();
		add(laundry);


		hint_texts = new FlxGroup();

		this.grid_size = grid_size;
		rng = FlxG.random.int;

		var interior_walls = new AsciiCanvas(w, h);

		// order of first three ROOM types are set in Dungen
		var small_rooms = rooms.splice(0, 3);
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

		// set up rest of room 
		var task_placements:Map<Location, Placement> = [];
		for (i => r in all_rooms)
		{
			var x_task_zone = Std.int(r.task_zone.x * grid_size);
			var y_task_zone = Std.int(r.task_zone.y * grid_size);
			var w_task_zone = Std.int(r.task_zone.w * grid_size);
			var h_task_zone = Std.int(r.task_zone.h * grid_size);
			
			trace('make zone hotspot room ${r.room} $x_task_zone , $y_task_zone  $w_task_zone x $h_task_zone');

			var task_zone = new FlxSprite(x_task_zone, y_task_zone);
			var tazk_zone_color = switch r.room
			{
				// case EMPTY:
				case BATH: FlxColor.CYAN;
				case WASH: FlxColor.LIME;
				case WC: FlxColor.BROWN;
				case BED: FlxColor.PURPLE;
				case KITCHEN: FlxColor.GRAY;
				case _: FlxColor.BLACK;
			}
			tazk_zone_color.alpha = 40;
			task_zone.makeGraphic(w_task_zone, h_task_zone, tazk_zone_color);
			task_zones.add(task_zone);

			var x_grid = Std.int(task_zone.x / grid_size);
			var y_grid = Std.int(task_zone.y / grid_size);
			var x_pixel = Std.int(task_zone.width / 2);
			var y_pixel = Std.int(task_zone.height / 2);
			
			switch r.room {
				// case EMPTY:
				// case BATH:
				case WASH:
					interior_walls.set_cell(x_grid, y_grid, "B");
					var placement:Placement = {
						x_pixel: x_pixel,
						y_pixel: y_pixel,
						location: BASKET
					}
					task_placements[BASKET] = placement;
				case WC:
					interior_walls.set_cell(x_grid, y_grid, "L");
					var placement:Placement = {
						x_pixel: x_pixel,
						y_pixel: y_pixel,
						location: LAVATORY
					}
					task_placements[LAVATORY] = placement;
				// case BED:
				// case KITCHEN:
				case _:
			}

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

		var player_placement:Placement = {
			y_pixel: 64,
			x_pixel: 64,
			location: PLAYER
		}

		place_player(player_placement);
		var x_grid_player = Std.int(player_placement.x_pixel / grid_size);
		var y_grid_player = Std.int(player_placement.y_pixel / grid_size);
		// todo - get player position from grid (outsize of all task zone)
		// instead of setting here
		interior_walls.set_cell(x_grid_player, y_grid_player, "@");

		

		for (location in tasks_to_complete)
		{
			if (task_placements.exists(location))
			{
				
				place_task(task_placements[location]);
			}
			else
			{
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
		trace('set up task ' + placement.location + ' ${placement.x_pixel} , ${placement.y_pixel} ');
		var task_size = 48;
		var task_center = task_size / 2;
		var task = new Task({
			x: Std.int(placement.x_pixel - task_center),
			y: Std.int(placement.y_pixel - task_center),
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
