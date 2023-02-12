package engine.building;

import engine.actor.Actor;
import engine.building.Layout;
import engine.map.BluePrint;
import engine.map.Canvas.AsciiCanvas;
import engine.map.Data;
import engine.map.Dungen.ApartmentGenerator;
import engine.tasks.Item;
import engine.tasks.Task;
import engine.tasks.TaskList;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.tile.FlxBaseTilemap;
import flixel.tile.FlxTileblock;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;

class ApartmentDungen extends FlxGroup
{
	public var player(default, null):Actor;
	public var tasks(default, null):FlxTypedGroup<Task>;
	public var task_zones(default, null):FlxTypedGroup<TaskZone>;
	public var laundry(default, null):FlxTypedGroup<Item>;
	public var hint_texts(default, null):FlxGroup;

	var empty_spots:Array<Placement>;
	var edge_left:Int = 0;
	var edge_top:Int = 0;
	var grid_size:Int;
	var door_width:Int = 4;
	var rng:RandomInt;
	var map_auto(default, null):FlxTilemap;

	public function new(config:ApartmentConfig, w:Int, h:Int, grid_size:Int, tasks_to_complete:Array<Location>)
	{
		super();

		var floor_map = new FlxTilemap();
		add(floor_map);
		
		task_zones = new FlxTypedGroup<TaskZone>();
		add(task_zones);

		tasks = new FlxTypedGroup<Task>();
		add(tasks);

		laundry = new FlxTypedGroup<Item>();
		add(laundry);

		hint_texts = new FlxGroup();

		this.grid_size = grid_size;
		rng = FlxG.random.int;

		var apartment_canvas = new AsciiCanvas(w, h);

		var small_rooms = config.rooms.splice(0, ApartmentGenerator.room_order.length - 1);
		var large_rooms = config.rooms.splice(config.rooms.length - 1, config.rooms.length);
		var all_rooms = small_rooms.concat(large_rooms);
		var task_zone_lookup:Map<Room, TaskZone> = [];
		large_rooms[0].room = BEDROOM;
		var unassigned_rooms = config.rooms.filter(space -> space.room == EMPTY);

		// draw walls
		for (i => r in all_rooms)
		{
			// trace('\n $i room ${r.walls.w} x ${r.walls.h}');
			// trace('$i  has ${r.apartment_canvas.length} internal walls');

			apartment_canvas.draw_rectangle(r.walls, i + '', 0, 0);
			var wall_symbol = i + '';
			// var wall_symbol = ",";
			var wall_symbol = "#";
			for (w in r.interior_walls)
			{
				apartment_canvas.draw_line(w.x_start, w.y_start, w.x_end, w.y_end, wall_symbol);
			}
		}

		// set up rest of room
		for (i => r in all_rooms)
		{
			
			var x_task_zone = Std.int(r.task_zone.x * grid_size);
			var y_task_zone = Std.int(r.task_zone.y * grid_size);
			var w_task_zone = Std.int(r.task_zone.w * grid_size);
			var h_task_zone = Std.int(r.task_zone.h * grid_size);
			
			trace('make zone hotspot room ${r.room} $x_task_zone , $y_task_zone  $w_task_zone x $h_task_zone');
			
			var tazk_zone_color = switch r.room
			{
				// case EMPTY:
				case BATH: FlxColor.CYAN;
				case WASH: FlxColor.LIME;
				case WC: FlxColor.BROWN;
				case BEDROOM: FlxColor.PURPLE;
				case KITCHEN: FlxColor.GRAY;
				case _: FlxColor.BLACK;
			}
			tazk_zone_color.alpha = 0;

			var zone_config:TaskZoneConfig = {
				x_pixel: x_task_zone,
				y_pixel: y_task_zone,
				w_pixel: w_task_zone,
				h_pixel: h_task_zone,
				room: r.room,
				rect: r.task_zone,
				color: tazk_zone_color,
				spaces: [
					{
						task: EMPTY,
						shape: {
							x: x_task_zone,
							y: y_task_zone,
							w: 128,
							h: 128
						},
					},
					{
						task: EMPTY,
						shape: {
							x: x_task_zone + 128,
							y: y_task_zone + 128,
							w: 128,
							h: 128
						},
					}
				]
			}
			var task_zone = new TaskZone(zone_config);
			task_zones.add(task_zone);
			task_zone_lookup[r.room] = task_zone;
			
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

				apartment_canvas.draw_line(x_start, y_start, x_end, y_end, door_symbol);
			}
		}

		var external:Rectangle = {
			y: 0,
			x: 0,
			w: w - 1,
			h: h - 1
		}

		var floor_canvas = new AsciiCanvas(w, h);
		
		// todo - finish kitchen tiles once that area is defined
		if (task_zone_lookup.exists(KITCHEN))
		{
			var kitchen = task_zone_lookup[KITCHEN];
			// fill kitchen tiles
			// floor_canvas.draw_rectangle()
		}
		floor_map.loadMapFromCSV(floor_canvas.csv("1"), "assets/images/carpet-00.png", 32, 32);

		apartment_canvas.draw_rectangle(external, "#", 0, 0);

		map_auto = new FlxTilemap();
		var csv = apartment_canvas.csv();
		// trace(csv);

		map_auto.loadMapFromCSV(csv, "assets/images/auto-tiles-32-debug.png", grid_size, grid_size, FlxTilemapAutoTiling.AUTO);
		add(map_auto);

		// x_pixel y_pixel for player here are actually x_grid and y_grid -_-
		apartment_canvas.set_cell(config.player.x_pixel, config.player.x_pixel, "@");

		config.player.x_pixel *= grid_size;
		config.player.y_pixel *= grid_size;
		place_player(config.player);

		for (location in tasks_to_complete)
		{
			if (location == RUG)
			{
				// todo handle this better
				if (TaskData.configurations.exists(RUG))
				{
					var rug_room = unassigned_rooms[1];
					var x_rug_grid = Std.int((rug_room.task_zone.w / 2) + rug_room.task_zone.x);
					var y_rug_grid = Std.int((rug_room.task_zone.h / 2) + rug_room.task_zone.y);

					var rug_placement:Placement = {
						y_pixel: y_rug_grid * grid_size,
						x_pixel: x_rug_grid * grid_size,
						location: RUG
					}

					place_task(rug_placement, TaskData.configurations[RUG]);
				}
			}
			else
			{
				var is_task_configured = TaskData.configurations.exists(location);

				if (!is_task_configured)
				{
					trace('!!! WARNING no task configured for $location');
					continue;
				}

				var task_details = TaskData.configurations[location];

				var is_task_placement_arranged = task_zone_lookup.exists(task_details.room);

				if (!is_task_placement_arranged)
				{
					trace('!!! WARNING no placement configured for $location');
					continue;
				}

				var zone = task_zone_lookup[task_details.room];
				var task_is_placed = false;
				for (space in zone.config.spaces) {
					if(task_is_placed || space.is_occupied){
						continue;
					}
					var placement:Placement = {
						x_pixel: Std.int(space.shape.w / 2 + space.shape.x),
						y_pixel: Std.int(space.shape.h / 2 + space.shape.y),
						location: location
					}
					space.task = location;
					space.is_occupied = true;
					place_task(placement, task_details);
					task_is_placed = true;
				}
			}
		}

		empty_spots = apartment_canvas.get_empty_spaces(grid_size);

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

	function place_task(placement:Placement, details:TaskDetails)
	{
		trace('set up task ' + placement.location + ' ${placement.x_pixel} , ${placement.y_pixel} ');
		// var task_size = 48;
		// var task_center = task_size / 2;
		var task = new Task({
			x: placement.x_pixel, // Std.int(placement.x_pixel - task_center),
			y: placement.y_pixel, // Std.int(placement.y_pixel - task_center),
			color: get_color(placement.location),
			details: details
		}, placement);

		tasks.add(task);
		add(task.progress_meter);
		task_list[placement.location] = task;
		for (text in task.hint.hints) {
			hint_texts.add(text);
		}
	}

	var laundry_frames:Array<Int> = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17];

	function place_dirty_laundry(spot:Placement)
	{
		var item = new Item({
			x: spot.x_pixel,
			y: spot.y_pixel,
			size: grid_size,
			color: 0xFFf3edc6,
			asset_path: "assets/images/items-32.png"
		});

		var random_laundry_item_index:Int = FlxG.random.int(0, laundry_frames.length - 1);
		item.animation.frameIndex = laundry_frames[random_laundry_item_index];
		laundry.add(item);
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
			case _: 0x33acbef6;
		}
	}
}
