package;

import engine.actor.Actor;
import engine.actor.Controller;
import engine.building.Construct;
import engine.building.Wall;
import engine.map.BluePrint;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

class PlayState extends FlxState
{
	var controller:Controller;
	var player:Actor;
	var walls:FlxTypedGroup<Wall>;

	override public function create()
	{
		super.create();

		FlxG.worldBounds.width = 4096;
		FlxG.worldBounds.height = 4096;

		var floor_plan = BluePrint.generate_floor_plan();

		var edge_left = 40;
		var edge_top = 40;
		var wall_size = 32;

		walls = new FlxTypedGroup<Wall>();
		add(walls);

		Construct.walls(floor_plan, edge_left, edge_top, wall_size, walls);

		var x_center = Std.int(FlxG.width / 2);
		var y_center = Std.int(FlxG.height / 2);

		player = new Actor({
			x_start: x_center,
			y_start: y_center,
			x_velocity_max: 400,
			y_velocity_max: 400,
			drag_multiplier: 2
		});

		add(player);

		FlxG.camera.follow(player);

		controller = new Controller(player);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		controller.update(FlxG.keys);
		FlxG.collide(player, walls);
	}
}
