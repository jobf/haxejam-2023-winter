package;

import engine.actor.Actor;
import engine.actor.Controller;
import engine.building.Layout;
import engine.building.Wall;
import engine.flx.CallbackFlxBar;
import engine.map.BluePrint;
import engine.tasks.laundry.Basket;
import engine.tasks.laundry.Item;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class PlayState extends FlxState
{
	var controller:Controller;
	var player:Actor;
	var edge_left:Int;
	var edge_top:Int;
	var grid_size:Int;

	var walls:FlxTypedGroup<Wall>;
	var laundry:FlxTypedGroup<Item>;
	var collected_laundry:FlxTypedGroup<Item>;
	var basket:Basket;
	// var main_camera:FlxCamera;
	var hud_camera:FlxCamera;
	var hud:Hud;
	var level_timer:FlxTimer;
	var level_progress_bar:CallbackFlxBar;
	var is_player_moving:Bool = false;
	var camera_zoom_tween:FlxTween;
	var zoom_out_max:Float = 0.72;
	var zoom_increment:Float = 0.002;

	override public function create()
	{
		super.create();

		FlxG.worldBounds.width = 4096;
		FlxG.worldBounds.height = 4096;

		hud = new Hud();
		add(hud);

		var floor_plan = BluePrint.generate_floor_plan();

		edge_left = 40;
		edge_top = 40;
		grid_size = 32;

		walls = new FlxTypedGroup<Wall>();
		add(walls);

		laundry = new FlxTypedGroup<Item>();
		add(laundry);

		collected_laundry = new FlxTypedGroup<Item>();
		hud.add(collected_laundry);

		var empty_spots:Array<Placement> = [];

		for (placement in Layout.placements(floor_plan, edge_left, edge_top, grid_size))
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
		collection_x = 10;
		collection_y = FlxG.height - 42;

		hud_camera = new FlxCamera(0, 0, FlxG.camera.width, FlxG.camera.height);
		hud_camera.zoom = 1;
		hud_camera.alpha = 0.8;
		hud_camera.bgColor = FlxColor.TRANSPARENT;
		hud_camera.follow(hud.background, FlxCameraFollowStyle.NO_DEAD_ZONE);

		FlxG.cameras.add(hud_camera);
		var level_duration_seconds = 30;
		level_timer = new FlxTimer();
		level_timer.start(level_duration_seconds, timer -> end_level());
		
		level_progress_bar = new CallbackFlxBar(0, 0, LEFT_TO_RIGHT, FlxG.width, 10, () -> return level_timer.progress * level_duration_seconds, 0, 30);
		level_progress_bar.scrollFactor.set(0, 0);
		level_progress_bar.cameras = [hud_camera];
		hud.add(level_progress_bar);
	}

	function end_level() {
		trace('level ends!');
		FlxG.camera.fade(FlxColor.BLACK, 1, false, start_next_level);
	}

	function start_next_level():Void {
		var pause_for_thought = new FlxTimer();
		pause_for_thought.start(0.5, timer -> FlxG.resetState());
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
		FlxG.camera.follow(player);

		controller = new Controller(player);
		player.on_start_moving = () -> player_started_moving();
		player.on_stop_moving = () -> player_stopped_moving();
	}

	function player_stopped_moving() {
		is_player_moving = false;
		// tween zoom back to normal
		camera_zoom_tween = FlxTween.num(FlxG.camera.zoom, 1.0, 0.25, f -> {
			FlxG.camera.zoom = f;
			trace('new zoom  $f');
		});
	}

	function player_started_moving() {
		is_player_moving = true;
		if(camera_zoom_tween != null && camera_zoom_tween.active){
			camera_zoom_tween.cancel();
		}
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

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		controller.update(FlxG.keys);
		if (FlxG.keys.justPressed.I)
		{
			zoom(-1);
		}
		if (FlxG.keys.justPressed.O)
		{
			zoom(1);
		}
		if (FlxG.keys.justPressed.R)
		{
			FlxG.resetState();
		}
		// stop running through walls
		FlxG.collide(player, walls);

		// interact with items
		FlxG.overlap(laundry, player, overlap_laundry_with_player);

		// drop laundry
		FlxG.overlap(basket, player, overlap_basket_with_player);

		// zoom camear out while player is moving
		if(is_player_moving && FlxG.camera.zoom > zoom_out_max){
			FlxG.camera.zoom -= zoom_increment;
		}
	}

	function overlap_laundry_with_player(laundry:Item, player:Actor)
	{
		collect(laundry);
	}

	function overlap_basket_with_player(basket:Basket, player:Actor)
	{
		deposit_collected_items();
	}

	function deposit_collected_items()
	{
		for (item in collected_items)
		{
			// todo - animate item deposit
			// todo - count items ? tally score ?
			item.kill();
		}

		collected_items = [];
	}

	var collected_items:Array<Item> = [];
	var collection_size:Int = 16;
	var collection_size_gap:Int = 10;
	var collection_x:Int;
	var collection_y:Int;

	function collect(laundry:Item)
	{
		laundry.kill();
		var collected = new Item({
			y: collection_y,
			x: collection_x + ((collection_size + collection_size_gap) * collected_items.length),
			size: collection_size,
			color: laundry.config.color
		});
		collected.cameras = [hud_camera];
		collected_items.push(collected);
		collected_laundry.add(collected);
		collected.scrollFactor.set(0, 0);
	}

	var zoom_amount:Float = 0.05;

	function zoom(direction:Int)
	{
		zoom_amount += direction;
		if (zoom_amount < 1)
		{
			zoom_amount = 1;
		}
		else
		{
			zoom_amount = 0.5;
		}
		FlxG.camera.zoom = zoom_amount;
		hud_camera.zoom = 1;
	}
}

class Hud extends FlxGroup
{
	public var background:FlxSprite;

	public function new()
	{
		super();

		// add a graphic for the hud_camera to follow
		// it needs to be out of the bounds of the main camera
		// otherwise we see the main camera content duplicated

		var x:Int = 100000;
		background = new FlxSprite(x, 0);
		background.makeGraphic(1, 1, FlxColor.TRANSPARENT);
		add(background);
	}
}
