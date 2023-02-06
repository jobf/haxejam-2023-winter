package engine.building;

import engine.map.Data.FloorPlan;
import flixel.group.FlxGroup.FlxTypedGroup;

class Construct {
	public static function walls(plan:FloorPlan, edge_left:Int, edge_top:Int, wall_size:Int, wall_group:FlxTypedGroup<Wall>){
		for (room in plan.rooms)
			{
				for (row => line in room.map)
				{
					trace('laying room map: $line');
					for (column in 0...line.length)
					{
						var symbol = line.charAt(column);
						switch symbol
						{
							case "#":
								wall_group.add(new Wall({
									y: edge_left + (row * wall_size),
									x: edge_top + (column * wall_size),
									size: wall_size,
									color: 0x6a5f49ff
								}));
							case _:
						}
					}
				}
			}
	}
}