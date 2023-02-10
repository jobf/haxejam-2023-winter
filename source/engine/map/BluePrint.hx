package engine.map;

import dropecho.dungen.bsp.Generator;
import engine.map.Canvas;
import engine.map.Data;
import engine.map.Dungen.ApartmentGenerator;

class BluePrint
{
	var rng:RandomInt;
	var door_width:Int;
	var bath_width:Int;

	public function new(rng:RandomInt)
	{
		this.rng = rng;
		door_width = 3;
		bath_width = 4;
	}

	public function generate_floor_plan():FloorPlan
	{
		return {
			rooms: [
				{
					map: [
						"######################################################      ",
						"#               #                         #          #      ",
						"#                                         #          #      ",
						"#                                 B       #          #      ",
						"#                                         #          #######",
						"#               #                         #                #",
						"#               #                         #                #",
						"#               ####  ####                #                #",
						"#               #        #                #                #",
						"#################        ########         #                #",
						"#               #        #            #####    #############",
						"#               # L      #                                 #",
						"#               #        #   @                             #",
						"#               ##########                                 #",
						"#               #                                          #",
						"#               #                                          #",
						"#               #                                          #",
						"#                                                          #",
						"#                                                          #",
						"#                                                          #",
						"#                                                          #",
						"#               #                                          #",
						"#               #                                          #",
						"#               #                                          #",
						"############################################################"
					]
				}
			]
		}
	}

	public function generate_dungen_apartment(width:Int, height:Int, seed_:Int = -1):Array<RoomSpace>
	{
		var seed = seed_ < 0 ? rng(0, 9999) : seed_;

		var bsp = new Generator({
			width: width,
			height: height,
			minWidth: 7,
			minHeight: 9,
			depth: 4,
			ratio: .909,
			seed: seed + ''
		}).generate();

		var rooms:Array<RoomSpace> = [];

		var map = ApartmentGenerator.buildRooms(bsp, rooms, {
			left: 0,
			right: width,
			top: 0,
			bottom: height,
		}, {
			tileCorridor: 3,
			tileFloor: 2,
			tileWall: 0,
			padding: 0
		});

		return rooms;
	}
}

@:structInit
class Rectangle
{
	public var x:Int = 0;
	public var y:Int = 0;
	public var w:Int;
	public var h:Int;
	public var area(get, never):Int;

	function get_area():Int
	{
		return w * h;
	}
}

function overlaps_rectangle(rect:Rectangle, x:Int, y:Int):Bool
{
	return x > rect.x && (rect.x + rect.w) > x && y > rect.y && (rect.y + rect.h) > y;
}

class TemplateRooms
{
	public static var minimum:Map<Room, RoomShape> = [
		BATH => {
			short_edge: 13,
			long_edge: 9,
		},
		WASH => {
			short_edge: 12,
			long_edge: 14,
		},
		WC => {
			short_edge: 8,
			long_edge: 8,
		}
	];

	public static var maximum:Map<Room, RoomShape> = [
		BATH => {
			short_edge: 13,
			long_edge: 13,
		},
		WASH => {
			short_edge: 14,
			long_edge: 20,
		},
		WC => {
			short_edge: 8,
			long_edge: 11,
		}
	];
}

function rotate_rectangle(rect:Rectangle)
{
	var x = rect.y;
	var y = rect.x;
	var w = rect.h;
	var h = rect.w;
	rect.x = x;
	rect.y = y;
	rect.w = w;
	rect.h = h;
}

typedef RandomInt = (min:Int, max:Int, ?excludes:Array<Int>) -> Int;

@:structInit
class DoorPlacement
{
	public var left:DoorSpace;
	public var right:DoorSpace;
	public var top:DoorSpace;
	public var bottom:DoorSpace;
	public var door_width:Int;
}

@:structInit
class Int2
{
	public var x:Int;
	public var y:Int;
}

@:structInit
class DoorSpace
{
	public var spaces:Array<Int2>;
	public var has_space:Bool;
	public var edge:Edge;
	public var center(get, never):Int2;

	function get_center():Int2
	{
		return spaces[1];
	}
}

@:structInit
class RoomSpace
{
	public var index:Int = 0;
	public var walls:Rectangle;
	public var door:DoorSpace;
	public var task_zone:Rectangle;
	public var cells:AsciiCanvas;
	public var interior_walls:Array<Wall> = [];
	public var aligned_walls:Array<Wall> = [];
	public var all_walls:Array<Wall> = [];
	public var room:Room;
}

enum Edge
{
	TOP;
	RIGHT;
	BOTTOM;
	LEFT;
}

@:structInit
class Wall
{
	public var x_start:Int;
	public var y_start:Int;
	public var x_end:Int;
	public var y_end:Int;
	public var edge:Edge;
}

@:structInit
class Perimeter
{
	public var left:Int;
	public var right:Int;
	public var top:Int;
	public var bottom:Int;
}
