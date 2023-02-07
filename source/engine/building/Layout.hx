package engine.building;

import engine.map.Data.FloorPlan;

class Layout {
	public static function placements(plan:FloorPlan, edge_left:Int, edge_top:Int, grid_size:Int):Array<Placement>{

		var placements:Array<Placement> = [];

		for (room in plan.rooms)
			{
				for (row => line in room.map)
				{
					trace('laying room map: $line');

					var y_pixel = map_to_world(row, edge_left, grid_size);
					
					for (column in 0...line.length)
					{
						var x_pixel = map_to_world(column, edge_top, grid_size);
						
						var symbol = line.charAt(column);

						placements.push({
							y_pixel: y_pixel,
							x_pixel: x_pixel,
							location: switch symbol {
								case "#": WALL;
								case "B": BASKET;
								case "L": LAVATORY;
								case "@": PLAYER;
								case _: EMPTY;
							}
						});
					}
				}
			}

		return placements;
	}

	inline static function map_to_world(map:Int, edge:Int, size:Int):Int{
		return edge + (map * size);
	}
}

@:structInit
class Placement{
	public var x_pixel:Int;
	public var y_pixel:Int;
	public var location:Location;
}

enum Location{
	EMPTY;
	PLAYER;
	WALL;
	BASKET;
	LAVATORY;
}
