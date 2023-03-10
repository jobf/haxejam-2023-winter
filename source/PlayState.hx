package;

import engine.actor.Actor;
import engine.actor.Controller;
import engine.building.Apartment;
import engine.building.Layout;
import engine.flx.CallbackFlxBar;
import engine.map.BluePrint;
import engine.tasks.Item;
import engine.tasks.Task;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class PlayState extends FlxState
{
	var controller:Controller;
	var edge_left:Int;
	var edge_top:Int;
	var grid_size:Int;

	var collected_laundry:FlxTypedGroup<Item>;
	var hud_camera:FlxCamera;
	var hud:Hud;
	var level_timer:FlxTimer;
	var level_progress_bar:CallbackFlxBar;
	var is_player_moving:Bool = false;
	var camera_zoom_tween:FlxTween;
	var zoom_out_max:Float = 0.72;
	var zoom_increment:Float = 0.002;
	var apartment:Apartment;
	var collected_items:Array<Item> = [];
	var collection_size:Int = 16;
	var collection_size_gap:Int = 10;
	var collection_x:Int;
	var collection_y:Int;
	var overlapping_task:Task;


	override public function create()
	{
		super.create();
		bgColor = 0xff959595;
		FlxG.worldBounds.width = 4096;
		FlxG.worldBounds.height = 4096;

		hud = new Hud();
		add(hud);

		var blue_print = new BluePrint(FlxG.random.int);
		
		var floor_plan = blue_print.generate_floor_plan();

		edge_left = 40;
		edge_top = 40;
		grid_size = 32;

		collected_laundry = new FlxTypedGroup<Item>();
		hud.add(collected_laundry);

		apartment = new Apartment(floor_plan, edge_left, edge_top, grid_size);
		add(apartment);

		task_complete[BASKET] = deposit_collected_items;

		FlxG.camera.follow(apartment.player);
		controller = new Controller(apartment.player);

		apartment.player.on_start_moving = () -> player_started_moving();
		apartment.player.on_stop_moving = () -> player_stopped_moving();

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
		level_timer.start(level_duration_seconds, timer -> {
			trace('timer reached end');
			end_level();
		});

		level_progress_bar = new CallbackFlxBar(0, 0, LEFT_TO_RIGHT, FlxG.width, 10, () -> return level_timer.progress * level_duration_seconds, 0, 30);
		level_progress_bar.scrollFactor.set(0, 0);
		level_progress_bar.cameras = [hud_camera];
		for (hint_text in apartment.hint_texts.members) {
			hint_text.cameras = [hud_camera];
		}
		hud.add(level_progress_bar);
		hud.add(apartment.hint_texts);
	}

	function end_level()
	{
		trace('level ends!');
		FlxG.camera.fade(FlxColor.BLACK, 1, false, start_next_level);
	}

	function start_next_level():Void
	{
		var pause_for_thought = new FlxTimer();
		pause_for_thought.start(0.5, timer -> FlxG.resetState());
	}

	function player_stopped_moving()
	{
		is_player_moving = false;
		// tween zoom back to normal
		camera_zoom_tween = FlxTween.num(FlxG.camera.zoom, 1.0, 0.25, f ->
		{
			FlxG.camera.zoom = f;
			// trace('new zoom  $f');
		});
	}

	function player_started_moving()
	{
		is_player_moving = true;
		if (camera_zoom_tween != null && camera_zoom_tween.active)
		{
			camera_zoom_tween.cancel();
		}
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
		FlxG.collide(apartment.player, apartment.walls);
		
		// interact with items
		FlxG.overlap(apartment.laundry, apartment.player, overlap_laundry_with_player);
		
		// complete tasks, set to null first because player may have moved
		overlapping_task = null;
		FlxG.overlap(apartment.tasks, apartment.player, overlap_task_with_player);

		// progress task if player is at one
		if(overlapping_task != null){
			var on_complete = task_complete.exists(overlapping_task.placement.location) 
			? task_complete[overlapping_task.placement.location]
			: () -> return;
			
			overlapping_task.decrease_task_remaining(elapsed, on_complete);
			overlapping_task.show_hint();
		}

		// zoom camera out while player is moving
		if (is_player_moving && FlxG.camera.zoom > zoom_out_max)
		{
			FlxG.camera.zoom -= zoom_increment;
		}
	}

	var task_complete:Map<Location, ()->Void> = [];

	function overlap_laundry_with_player(laundry:Item, player:Actor)
	{
		collect(laundry);
	}

	function overlap_task_with_player(task:Task, player:Actor)
	{
		overlapping_task = task;
	}
	
	function deposit_collected_items()
	{
		trace('deposit_collected_items');
		for (item in collected_items)
		{
			// todo - animate item deposit
			// todo - count items ? tally score ?
			item.kill();
		}

		collected_items = [];
	}

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
