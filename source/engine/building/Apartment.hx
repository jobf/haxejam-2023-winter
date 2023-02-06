package engine.building;

import engine.actor.Actor;
import engine.building.Layout.Placement;
import engine.map.Data.FloorPlan;
import engine.tasks.laundry.Basket;
import engine.tasks.laundry.Item;
import flixel.FlxG;
import flixel.group.FlxGroup;

class Apartment extends FlxGroup
{
	public var player(default, null):Actor;
	public var walls(default, null):FlxTypedGroup<Wall>;
	public var laundry(default, null):FlxTypedGroup<Item>;
	public var basket(default, null):Basket;

	var empty_spots:Array<Placement>;
	var edge_left:Int;
	var edge_top:Int;
	var grid_size:Int;

	public function new(plan:FloorPlan, edge_left:Int, edge_top:Int, grid_size:Int)
	{
		super();
		this.edge_left = edge_left;
		this.edge_top = edge_top;
		this.grid_size = grid_size;

		walls = new FlxTypedGroup<Wall>();
		add(walls);

		laundry = new FlxTypedGroup<Item>();
		add(laundry);

		empty_spots = [];

		for (placement in Layout.placements(plan, edge_left, edge_top, grid_size))
		{
			switch placement.location
			{
				case WALL:
					place_wall(placement);
				case BASKET:
					place_basket(placement);
				case PLAYER:
					place_player(placement);
				case EMPTY:
					empty_spots.push(placement);
			}
		}

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
			x_start: spot.x_pixel,
			y_start: spot.y_pixel,
			x_velocity_max: 400,
			y_velocity_max: 400,
			drag_multiplier: 6
		});

		add(player);
	}

	function place_wall(spot:Placement)
	{
		walls.add(new Wall({
			x: spot.x_pixel,
			y: spot.y_pixel,
			size: grid_size,
			color: 0x6a5f49ff
		}));
	}

	function place_basket(spot:Placement)
	{
		var basket_size = 64;
		var basket_center = basket_size / 2;
		basket = new Basket({
			x: Std.int(spot.x_pixel - basket_center),
			y: Std.int(spot.y_pixel - basket_center),
			size: basket_size,
			color: 0xffffffff
		});
		add(basket);
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
}
