package;

import engine.actor.Actor;
import engine.actor.Controller;
import engine.building.Layout;
import engine.building.Wall;
import engine.map.BluePrint;
import engine.tasks.laundry.Basket;
import engine.tasks.laundry.Item;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

class PlayState extends FlxState
{
	var controller:Controller;
	var player:Actor;
	var edge_left:Int;
	var edge_top:Int;
	var grid_size:Int;

	var walls:FlxTypedGroup<Wall>;
	var laundry:FlxTypedGroup<Item>;
	var basket:Basket;


	override public function create()
	{
		super.create();

		FlxG.worldBounds.width = 4096;
		FlxG.worldBounds.height = 4096;

		var floor_plan = BluePrint.generate_floor_plan();

		edge_left = 40;
		edge_top = 40;
		grid_size = 32;

		walls = new FlxTypedGroup<Wall>();
		add(walls);

		laundry = new FlxTypedGroup<Item>();
		add(laundry);

		var empty_spots:Array<Placement> = [];
		
		for (placement in Layout.placements(floor_plan, edge_left, edge_top, grid_size)) {
			switch placement.location {
				case WALL: place_wall(placement);
				case BASKET: place_basket(placement);
				case PLAYER: place_player(placement);
				case EMPTY: empty_spots.push(placement);
			}
		}
		
		// shuffle the empty spots before distributing items
		FlxG.random.shuffle(empty_spots);
		
		var index_empty_spot = 0;
		
		// distrbute laundry
		var total_dirty_laundry = 8;
		for (i in 0...total_dirty_laundry) {
			place_dirty_laundry(empty_spots[i]);
			index_empty_spot++;
		}


		FlxG.camera.zoom = zoom_amount;
	}

	function place_player(spot:Placement) {
		player = new Actor({
			x_start: spot.x_pixel,
			y_start: spot.y_pixel,
			x_velocity_max: 400,
			y_velocity_max: 400,
			drag_multiplier: 6
		});

		add(player);
		FlxG.camera.follow(player);

		controller = new Controller(player);
	}

	function place_wall(spot:Placement) {
		walls.add(new Wall({
			x: spot.x_pixel,
			y: spot.y_pixel,
			size: grid_size,
			color: 0x6a5f49ff
		}));
	}

	function place_basket(spot:Placement) {
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

	function place_dirty_laundry(spot:Placement) {
		laundry.add(new Item({
			x: spot.x_pixel,
			y: spot.y_pixel,
			size: grid_size,
			color: 0xFFf3edc6
		}));
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		controller.update(FlxG.keys);
		if(FlxG.keys.justPressed.I){
			zoom(-1);
		}
		if(FlxG.keys.justPressed.O){
			zoom(1);
		}
		if(FlxG.keys.justPressed.R){
			FlxG.resetState();
		}
		FlxG.collide(player, walls);
	}

	var zoom_amount:Float = 0.5;
	function zoom(direction:Int) {
		zoom_amount += direction;
		if(zoom_amount < 1){
			zoom_amount = 1;
		}
		else{
			zoom_amount = 0.5;
		}
		FlxG.camera.zoom = zoom_amount;
	}
}
