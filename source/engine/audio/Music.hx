package engine.audio;

import flixel.FlxG;

class Music
{
	static var menu_path:String = 'assets/music/menu';
	static var game_path:String = 'assets/music/game';
	static var volume = 0.3;

	static function play(path:String){
		var is_music_playing = FlxG.sound.music != null && FlxG.sound.music.playing;
		if (!is_music_playing)
		{
			var file_extension = '.mp3';
			#if !web
			file_extension = '.ogg';
			#end
			var asset_path = path + file_extension;
			var is_looped = true;
			trace('playing $asset_path');
			FlxG.sound.playMusic(asset_path, volume, is_looped);
		}
	}
	
	static public function stop(){
		var is_music_playing = FlxG.sound.music != null;
		if(is_music_playing){
			FlxG.sound.music.stop();
		}
	}
	
	static public function play_menu_music()
	{
		stop();
		play(menu_path);
	}
	
	static public function play_game_music()
	{
		stop();
		play(game_path);
	}

}
