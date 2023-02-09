package test;

import dropecho.ds.BSPNode;
import dropecho.ds.BSPTree;
import dropecho.ds.algos.PostOrderTraversal;
import dropecho.dungen.bsp.BSPData;
import dropecho.dungen.bsp.Generator;
import dropecho.dungen.generators.RoomGenerator;
import dropecho.interop.Extender;
import engine.map.BluePrint;
import engine.map.Canvas.AsciiCanvas;
import test.FlxRandomShim;
import utest.Test;

using dropecho.dungen.Map2d;

class FloorGenTests extends Test
{
	var flxRandom:FlxRandomShim;
	var rng:RandomInt;
	var door_width:Int;
	var bath_width:Int;
	var blue_print:BluePrint;

	function setup()
	{
		flxRandom = new FlxRandomShim();
		rng = flxRandom.int;
		door_width = 4;
		bath_width = 4;
		blue_print = new BluePrint(rng);
	}

	function test_dgen()
	{
		var w:Int = 40;
		var h:Int = 40;

		var seed = 5117;

		var blue_print = new BluePrint(rng);
		var rooms = blue_print.generate_dungen_apartment(w, h, seed);

		trace('seed $seed');
		trace('rooms.length' + rooms.length);

		var interior_walls = new AsciiCanvas(w, h);

		var first = 0;
		var small_rooms = rooms.splice(first, 3);
		var large_rooms = rooms.splice(rooms.length - 1, rooms.length);
		var all_rooms = small_rooms.concat(large_rooms);

		// draw walls
		for (i => r in all_rooms)
		{
			trace('\n $i room ${r.walls.w} x ${r.walls.h}');
			trace('$i  has ${r.interior_walls.length} internal walls');

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
				
				trace('room $i door center ${center.x} ${center.y}');

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
	}
}
