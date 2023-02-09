import engine.map.BluePrint;
import engine.map.Canvas;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;

class FloorGenState extends FlxState
{
	var edge_left:Float;
	var edge_top:Float;
	var door_width:Int = 4;
	var rng:RandomInt;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.keys.justPressed.R)
		{
			FlxG.resetState();
		}
	}

	override function create()
	{
		super.create();
		rng = FlxG.random.int;
		var w:Int = 40;
		var h:Int = 40;

		var seed = 5117;

		var blue_print = new BluePrint(rng);
		var rooms = blue_print.generate_dungen_apartment(w, h, seed);

		trace('seed $seed');
		// trace('rooms.length' + rooms.length);

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
		for (i => r in all_rooms) {
			for(w in r.all_walls){
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
						// case _:
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

		var num_rotations = rng(0, 3);
		for (i in 0...num_rotations)
		{
			interior_walls.rotate_clockwise();
		}
		
		interior_walls.print();

		var map_auto = new FlxTilemap();
		var csv = interior_walls.csv();
		trace(csv);
		map_auto.loadMapFromCSV(csv, "assets/images/auto-tiles-32-debug.png", 32, 32,
			FlxTilemapAutoTiling.AUTO);
		add(map_auto);
	}

	function draw_rectangle(rect:Rectangle, color:FlxColor)
	{
		var edge_left = this.edge_left - rect.w / 2;
		var edge_top = this.edge_top - rect.h / 2;
		
		var left = edge_left + rect.x;
		var right = edge_left + rect.x + rect.w;
		var top = edge_top + rect.y;
		var bottom = edge_top + rect.y + rect.h;

		var lines = [
			new FlxLine(left, top, right, top, color),
			new FlxLine(left, bottom, right, bottom, color),
			new FlxLine(left, top, left, bottom, color),
			new FlxLine(right, top, right, bottom, color)
		];

		for (line in lines)
		{
			add(line);
		}

		camera.zoom = 6;
	}

	function draw_furniture(rect:Rectangle, room:Room){
		var edge_left = this.edge_left - rect.w / 2;
		var edge_top = this.edge_top - rect.h / 2;
		switch room {
			case BATH: 
				var width_bath = rect.w;
				var height_bath = 4;
				var x = rect.x;
				var y = rect.y + height_bath;
				var w = width_bath;
				var h = height_bath;
				draw_rectangle({
					y: y,
					x: x,
					w: w,
					h: h
				}, FlxColor.PINK);
			case _:
			// case EMPTY:
			// case WASH:
			// case WC:
			// case KITCHEN:
		}
	}
}

class TemplateRooms
{
	public static var minimum:Map<Room, RoomShape> = [
		BATH => {
			room: BATH,
			short_edge: 13,
			long_edge: 9,
		},
		WASH => {
			room: WASH,
			short_edge: 12,
			long_edge: 14,
		},
		WC => {
			room: WC,
			short_edge: 8,
			long_edge: 8,
		}
	];

	public static var maximum:Map<Room, RoomShape> = [
		BATH => {
			room: BATH,
			short_edge: 13,
			long_edge: 13,
		},
		WASH => {
			room: WASH,
			short_edge: 14,
			long_edge: 20,
		},
		WC => {
			room: WC,
			short_edge: 8,
			long_edge: 11,
		}
	];
	// public static var bath_minimum:RoomShape = {
	// 	room: BATH,
	// 	short_edge: 10,
	// 	long_edge: 13,
	// }
	// public static var bath_maximum:RoomShape = {
	// 	room: BATH,
	// 	short_edge: 14,
	// 	long_edge: 15,
	// }
	// public static var wash_minimum:RoomShape = {
	// 	room: WASH,
	// 	short_edge: 12,
	// 	long_edge: 14,
	// }
	// public static var wash_maximum:RoomShape = {
	// 	room: WASH,
	// 	short_edge: 14,
	// 	long_edge: 20,
	// }
	// public static var wc_minimum:RoomShape = {
	// 	room: WC,
	// 	short_edge: 8,
	// 	long_edge: 8,
	// }
	// public static var wc_maximum:RoomShape = {
	// 	room: WC,
	// 	short_edge: 8,
	// 	long_edge: 11,
	// }
}

@:structInit
class RoomShape
{
	public var short_edge:Int;
	public var long_edge:Int;
	public var room:Room = EMPTY;
}

enum Room
{
	EMPTY;
	BATH;
	WASH;
	WC;
	KITCHEN;
}

class FlxLine extends FlxSprite
{
	var x_start:Float;
	var y_start:Float;

	var x_end:Float;
	var y_end:Float;

	var x_distance:Float;
	var y_distance:Float;

	public function new(x_start:Float, y_start:Float, x_end:Float, y_end:Float, color:FlxColor, width:Int = 1)
	{
		super(x_start, y_start);

		this.x_start = x_start;
		this.y_start = y_start;
		this.x_end = x_end;
		this.y_end = y_end;

		makeGraphic(1, 1, color, true);
		origin.set(0, 0);
		line_update();
	}

	function set_start(x:Float, y:Float)
	{
		x_start = x;
		y_start = y;
		line_update();
	}

	function set_end(x:Float, y:Float)
	{
		x_end = x;
		y_end = y;
		line_update();
	}

	function line_update()
	{
		offset.set(0, 0);
		// line start position
		x = x_start;
		y = y_start;

		// distances on each axis
		x_distance = x_end - x_start;
		y_distance = y_end - y_start;

		// line thickness
		scale.x = width;

		// line length
		scale.y = Math.sqrt(x_distance * x_distance + y_distance * y_distance);

		// line rotation
		angle = Math.atan2(x_start - x_end, -(y_start - y_end)) * (180 / Math.PI);
	}
}
