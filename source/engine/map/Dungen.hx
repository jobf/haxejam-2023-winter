package engine.map;

import dropecho.ds.BSPNode;
import dropecho.ds.BSPTree;
import dropecho.ds.algos.PostOrderTraversal;
import dropecho.dungen.bsp.BSPData;
import dropecho.dungen.generators.RoomGenerator;
import dropecho.interop.Extender;
import engine.map.BluePrint;
import engine.map.Canvas;
import engine.map.Data;

using dropecho.dungen.Map2d;

class ApartmentGenerator
{
	public static function buildRooms(tree:BSPTree<BSPData>, config:ApartmentConfig, ?opts:Dynamic = null):Map2d
	{
		var room_order:Array<Room> = [
			WC,
			BATH,
			WASH,
			BEDROOM
		];
		
		var found_player = false;
		
		var found_rooms:Array<Room> = [];
		
		var params = Extender.defaults(new RoomParams(), opts);

		var rootvalue = tree.getRoot().value;
		var map = new Map2d(rootvalue.width, rootvalue.height, params.tileWall);

		function makeRoom(node:BSPNode<BSPData>):Bool
		{
			if (node.hasLeft() || node.hasRight())
			{
				return true;
			}

			var lPad = Std.int(params.padding / 2);
			var rPad = Std.int(params.padding / 2) + params.padding % 2;

			var roomStartX:Int = node.value.x + 1 + lPad;
			var roomStartY:Int = node.value.y + 1 + lPad;
			var roomEndX:Int = (node.value.x + node.value.width) - 1 - rPad;
			var roomEndY:Int = (node.value.y + node.value.height) - 1 - rPad;

			if (roomStartX != 1)
			{
				roomStartX -= 1;
			}
			if (roomStartY != 1)
			{
				roomStartY -= 1;
			}

			for (x in roomStartX...roomEndX)
			{
				for (y in roomStartY...roomEndY)
				{
					map.set(x, y, params.tileFloor);
				}
			}
			
			var walls_rect:Rectangle = {
				w: 0,
				h: 0
			}

			var door:DoorSpace = {
				spaces: [],
				has_space: false,
				edge: TOP,
			};

			
			walls_rect.x = roomStartX - 1;
			walls_rect.y = roomStartY - 1;
			
			walls_rect.w = roomEndX - (roomStartX - 1);
			walls_rect.h = roomEndY - (roomStartY - 1);
			
			var task_rect:Rectangle = {
				x: walls_rect.x,
				y: walls_rect.y,
				w: walls_rect.w,
				h: walls_rect.h,//Std.int(walls_rect.h / 2)
			}

			var walls:Array<Wall> = [
				{
					edge: TOP,
					x_start: walls_rect.x,
					x_end: walls_rect.x + walls_rect.w,
					y_start: walls_rect.y,
					y_end: walls_rect.y,
				},
				{
					edge: BOTTOM,
					x_start: walls_rect.x,
					x_end: walls_rect.x + walls_rect.w,
					y_start: walls_rect.y + walls_rect.h,
					y_end: walls_rect.y + walls_rect.h,
				},
				{
					edge: LEFT,
					x_start: walls_rect.x,
					x_end: walls_rect.x,
					y_start: walls_rect.y,
					y_end: walls_rect.y + walls_rect.h,
				},
				{
					edge: RIGHT,
					x_start: walls_rect.x + walls_rect.w,
					x_end: walls_rect.x + walls_rect.w,
					y_start: walls_rect.y,
					y_end: walls_rect.y + walls_rect.h,
				},
			];

			var interior_walls:Array<Wall> = walls.filter(wall ->
			{
				var is_interior = false;

				var right_edge = wall.x_end;
				var left_edge = wall.x_start;
				var top_edge = wall.y_start;
				var bottom_edge = wall.y_end;

				// trace('\n edges');
				// trace('right $right_edge == ${edges.right}');
				// trace('left $left_edge == ${edges.left}');
				// trace('top $top_edge == ${edges.top}');
				// trace('bottom $bottom_edge == ${edges.bottom}');
				// trace( '!!! wall edge ${edges.right}  : ${right_edge}');

				switch wall.edge
				{
					case TOP:
						is_interior = !(top_edge == config.edges.top);
						// trace('is top and interior $is_interior');
					case BOTTOM:
						is_interior = !(bottom_edge == config.edges.bottom);
						// trace('is bottom and interior $is_interior');
					case RIGHT:
						is_interior = !(right_edge == config.edges.right);
						// trace('is right and interior $is_interior');
					case LEFT:
						is_interior = !(left_edge == config.edges.left);
						// trace('is left and interior $is_interior');
				}
				is_interior;
			});

			// trace('\n');
			var aligned_walls:Array<Wall> = interior_walls.filter(wall ->
			{
				var aligns_with_other_wall = false;
				for (other_wall in interior_walls)
				{
					switch wall.edge
					{
						case TOP: aligns_with_other_wall = other_wall.y_start == wall.y_start;
						case BOTTOM: aligns_with_other_wall = other_wall.y_start == wall.y_start;
						case RIGHT: aligns_with_other_wall = other_wall.x_start == wall.x_start;
						case LEFT: aligns_with_other_wall = other_wall.x_start == wall.x_start;
					}
				}
				aligns_with_other_wall;
			});

			var is_all_rooms_found = found_rooms.length == room_order.length;
			var room_found = is_all_rooms_found ? EMPTY : room_order[found_rooms.length];
			if(room_found == null){
				room_found = EMPTY;
			}

			if(room_found == EMPTY && !found_player){
				var x_player = Std.int((walls_rect.w / 2) + walls_rect.x);
				var y_player = Std.int((walls_rect.h / 2) + walls_rect.y);
				config.player.x_pixel = x_player;
				config.player.y_pixel = y_player;
				found_player = true;
				trace(' player located $x_player $y_player');
			}

			found_rooms.push(room_found);
			
			config.rooms.push({
				index: config.rooms.length,
				walls: walls_rect,
				task_zone: task_rect,
				door: door,
				cells: new AsciiCanvas(walls_rect.w, walls_rect.h),
				interior_walls: interior_walls,
				aligned_walls: aligned_walls,
				all_walls: walls,
				room: room_found
			});

			return true;
		}

		

		var visitor = new PostOrderTraversal();

		visitor.run(tree.root, makeRoom);
		visitor.visited.resize(0);

		return map;
	}
}




/**
	Definitions of furniture sizes at grid level
**/
class Furniture{

	public static var rooms:Map<Room, Array<RoomShape>> = [
		EMPTY => [
			rug
		],
		BEDROOM => [
			bed
		],
	];

	// public static var bath:RoomShape  = {
	// 	long_edge: 6,
	// 	short_edge: 4
	// }

	public static var bed:RoomShape  = {
		long_edge: 4,
		short_edge: 3
	}

	public static var rug:RoomShape  = {
		long_edge: 4,
		short_edge: 3
	}
}
