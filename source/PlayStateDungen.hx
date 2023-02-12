package;

import engine.actor.Actor;
import engine.actor.Controller;
import engine.audio.Music;
import engine.audio.Sound;
import engine.building.ApartmentDungen;
import engine.building.Layout;
import engine.flx.CallbackFlxBar;
import engine.map.BluePrint;
import engine.tasks.Item;
import engine.tasks.Task;
import engine.tasks.TaskList;
import engine.ui.Fonts;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;

class PlayStateDungen extends FlxState
{
	var controller:Controller;
	var edge_left:Int;
	var edge_top:Int;
	var grid_size:Int;

	var collected_laundry:FlxTypedGroup<Item>;
	var hud_camera:FlxCamera;
	var hud:Hud;
	var level_progress_bar:CallbackFlxBar;
	var is_player_moving:Bool = false;
	var camera_zoom_tween:FlxTween;
	var zoom_out_max:Float = 0.72;
	var zoom_increment:Float = 0.002;
	var apartment:ApartmentDungen;
	var collected_items:Array<Item> = [];
	var collection_size:Int = 16;
	var collection_size_gap:Int = 10;
	var collection_x:Int;
	var collection_y:Int;
	var overlapping_task:Task;

	var task_list:TaskList;
	var session_timer:SessionTimer;



	override public function create()
	{
		super.create();
		Progression.reset();

		bgColor = FlxColor.WHITE;
		FlxG.worldBounds.width = 4096;
		FlxG.worldBounds.height = 4096;

		hud = new Hud();
		add(hud);

		
		var tasks_to_complete = Progression.get_tasks();
		trace('completed levels =  ${Progression.completed_session_count}, num tasks now ${tasks_to_complete.length}');
		
		task_list = new TaskList(tasks_to_complete);
		task_list.set_task_on_complete(BASKET, deposit_collected_items);

		var width = 36;
		var height = 36;
		edge_left = 0;
		edge_top = 0;
		grid_size = 32;
		var seed = -1; // will use random seed
		// var seed = 5117; // for testing specific 
		var blue_print = new BluePrint(FlxG.random.int);
		var apartment_config = blue_print.generate_dungen_apartment(width, height, seed);

		collected_laundry = new FlxTypedGroup<Item>();
		hud.add(collected_laundry);

		apartment = new ApartmentDungen(apartment_config, width, height, grid_size, tasks_to_complete);
		add(apartment);

		@:privateAccess
		FlxG.worldBounds.width = apartment.map_auto.width;
		@:privateAccess
		FlxG.worldBounds.height = apartment.map_auto.height;

		FlxG.camera.follow(apartment.player);
		// FlxG.camera.setScrollBoundsRect(0, 0, FlxG.worldBounds.width, FlxG.worldBounds.height);
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
		session_timer = new SessionTimer(task_list.seconds_allotted, ()-> end_level());
		// level_timer.start(task_list.seconds_allotted, timer -> end_level());

		var color_bg = ProgressColors.color_bg;
		var color_fg = ProgressColors.color_fg;
		level_progress_bar = new CallbackFlxBar(0, 0, LEFT_TO_RIGHT, FlxG.width, 10, color_bg, color_fg,
			() -> session_timer.get_time_remaining(),0, task_list.seconds_allotted);
		level_progress_bar.scrollFactor.set(0, 0);
		level_progress_bar.cameras = [hud_camera];
		for (hint_text in apartment.hint_texts.members) {
			hint_text.cameras = [hud_camera];
		}
		hud.add(level_progress_bar);
		hud.add(apartment.hint_texts);
		Music.play_game_music();
	}

	function end_level()
	{
		trace('level ends!');
		
		Progression.is_session_ended = true;
		FlxG.camera.follow(null);
		apartment.player.animation.play("S");
		apartment.player.animation.stop();
		apartment.player.animation.frameIndex = apartment.player.config.animation_frame_index_idle;
		apartment.player.stop(false, true);
		Music.stop();
		if(task_list.is_list_complete())
		{
			Progression.completed_session_count++;
			Progression.completed_session_time = session_timer.get_time_remaining();
			start_next_level();
		}
		else
		{
			start_score_state();
		}
	}

	function start_score_state(){
		var scoreBg = 0xfffec7fb;
		collected_laundry.clear();
		FlxSpriteUtil.fadeOut(apartment.player, 1.25);
		var pause_for_thought = new FlxTimer();
		pause_for_thought.start(1.5, timer -> {
			FlxG.camera.fade(scoreBg, 2, false, ()->{
				var session_text = hud.show_text("Oh no!\nYou ran out of time!");
				FlxSpriteUtil.fadeOut(session_text, 3.5, tween -> {
					FlxG.switchState(new ScoreState());
				});
			});
		});
	}

	function start_next_level():Void
	{
		var pause_for_thought = new FlxTimer();
		pause_for_thought.start(1.5, timer -> {
			FlxG.camera.fade(FlxColor.WHITE, 2, false, ()->{
				var session_text = hud.show_text("Congratulations!\nStarting new day!");
				FlxSpriteUtil.fadeOut(session_text, 3.5, tween -> {
					FlxG.switchState(new PlayStateDungen());
				});
			});
		});
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

	//// UPDATE 

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if(Progression.is_session_ended){
			return;
		}

		session_timer.update(elapsed);
		
		if(task_list.is_list_complete())
		{
			end_level();
		}

		controller.update(FlxG.keys);
		#if debug
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
		#end

		@:privateAccess
		FlxG.collide(apartment.map_auto, apartment.player);
		
		// interact with items
		FlxG.overlap(apartment.laundry, apartment.player, overlap_laundry_with_player);
		
		// complete tasks, set to null first because player may have moved
		overlapping_task = null;
		FlxG.overlap(apartment.tasks, apartment.player, overlap_task_with_player);

		// progress task if player is at one
		if(overlapping_task != null){
			if(overlapping_task.placement.location == BASKET){
				
				if(collected_items.length > 0){
					var task_on_complete = task_list.get_task_on_complete(overlapping_task.placement.location);
					var on_complete = ()->{
						task_on_complete();
						// if collected at least half of the laundry we call it complete
						if(task_list.total_collected_items >= 4){
							overlapping_task.animation.frameIndex = overlapping_task.config.details.frame_index_complete;
							Sound.play_task_complete();
						}
					}
					overlapping_task.decrease_task_remaining(elapsed, on_complete);
				}
				overlapping_task.show_hint();
			}
			else{
				var task_on_complete = task_list.get_task_on_complete(overlapping_task.placement.location);
				var on_complete = ()->{
					task_on_complete();
					gain_time();
				}
				overlapping_task.decrease_task_remaining(elapsed, on_complete);
				overlapping_task.show_hint();
			}
		}

		// zoom camera out while player is moving
		if (is_player_moving && FlxG.camera.zoom > zoom_out_max)
		{
			FlxG.camera.zoom -= zoom_increment;
		}
	}

	function show_time_bonus(time_bonus:Float){
		var time_text:String = FlxStringUtil.formatMoney(time_bonus);
		var x = apartment.player.x;
		var y = apartment.player.y;
		var y_start = y - 32;
		var y_end = y_start - 48;
		var text = new FlxBitmapText(Fonts.small());
		text.text = '+$time_text';
		text.x = x;
		text.y = y_start;
		add(text);
		FlxSpriteUtil.fadeOut(text);
		FlxTween.tween(text, {y: y_end});
	}

	function gain_time() {
		if(overlapping_task.placement.location == BASKET){
			// time bonus for laundry handled in deposit_collected_items
			return;
		}
		
		var time_bonus = overlapping_task.config.details.time_bonus;
		session_timer.gain_time(time_bonus);
		show_time_bonus(time_bonus);
	}
	

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
		var seconds_per_item = 0.7;
		var time_bonus_total  = collected_items.length * seconds_per_item;
		trace('deposit_collected_items $seconds_per_item * ${collected_items.length} = $time_bonus_total');
		session_timer.gain_time(time_bonus_total);
		show_time_bonus(time_bonus_total);
		for (item in collected_items)
		{
			task_list.total_collected_items++;
			// todo - animate item deposit
			// todo - count items ? tally score ?
			item.kill();
		}

		collected_items = [];
	}

	function collect(laundry:Item)
	{
		Sound.play_item_collect();
		var collection_size = 32;
		laundry.kill();
		var collected = new Item({
			y: collection_y,
			x: collection_x + ((collection_size + collection_size_gap) * collected_items.length),
			size: collection_size,
			color: laundry.config.color,
			asset_path: "assets/images/items-32.png"
		});
		collected.animation.frameIndex = laundry.animation.frameIndex;
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

	public function show_text(text:String):FlxBitmapText {
		var session_text = new FlxBitmapText(Fonts.normal());
		// session_text.background = true;
		// session_text.backgroundColor = FlxColor.WHITE;
		session_text.fieldWidth = FlxG.width;
		session_text.alignment = CENTER;
		session_text.text = text;
		session_text.scrollFactor.set(0,0);
		add(session_text);
		session_text.screenCenter();
		return session_text;
	}
}

class SessionTimer{
	var initial_duration_seconds:Float;
	var remaining_seconds:Float;
	var is_complete:Bool;
	var on_complete:Void->Void;

	public function new(initial_duration_seconds:Float, on_complete:Void->Void){
		this.initial_duration_seconds = initial_duration_seconds;
		remaining_seconds = initial_duration_seconds;
		is_complete = false;
		this.on_complete = on_complete;
	}

	public function update(elapsed_seconds:Float){
		if(is_complete){
			return;
		}
		
		remaining_seconds -= elapsed_seconds;
		
		if(remaining_seconds <= 0){
			is_complete = true;
			on_complete();
		}
	}

	public function get_progress_percentage():Float{
		return remaining_seconds / initial_duration_seconds;
	}

	public function gain_time(seconds:Float){
		remaining_seconds += seconds;
		if(remaining_seconds > initial_duration_seconds){
			remaining_seconds = initial_duration_seconds;
		}
	}

	public function get_time_remaining():Float {
		return remaining_seconds;
	}
}