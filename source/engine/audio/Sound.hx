package engine.audio;

import flixel.FlxG;

class Sound{
	static var item_collect_path:String = "assets/sounds/item_collect.wav";
	static var task_start_path:String = "assets/sounds/task_start.wav";
	static var task_complete_path:String = "assets/sounds/task_complete.wav";
	static var samples_volume: Float = 1.0;

	public static function play_item_collect(){
		FlxG.sound.play(item_collect_path, samples_volume);
	}

	public static function play_task_start(){
		FlxG.sound.play(task_start_path, samples_volume);
	}

	public static function play_task_complete(){
		FlxG.sound.play(task_complete_path, samples_volume);
	}
}