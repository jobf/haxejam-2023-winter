package deploy;

import haxe.io.Path;
import sys.io.File;

using DateTools;

class Deploy{
	public static function main() {
		
		var host_remote = File.getContent("secrets/remote_host");
		var path_remote = File.getContent("secrets/remote_path");

		if(host_remote.length == 0 || path_remote.length == 0){
			trace('Cannot deploy without secrets.');
		}

		var path_local = "export/html5/bin";

		var file_name_index = "index.html";
		var file_name_readme = "readme.md";
		
		append_readme(path_local, file_name_index, file_name_readme);

		var path_version = Date.now().format("%d-%H-%M");
		
		var command:String = "scp";
		
		var args:Array<String> = [
			"-r",
			path_local,
			'$host_remote:$path_remote/$path_version',
		];

		Sys.command(command, args);
	}

	static function append_readme(path_local:String, file_name_index:String, file_name_readme:String) {
		var path_index = Path.join([path_local, file_name_index]);

		trace('reading $path_index');

		var file_lines = File.getContent(path_index).split('\n');

		trace('num lines ${file_lines.length}');

		var lines_to_append = File.getContent(file_name_readme).split('\n');
		
		var start_line = 54;

		for (line in lines_to_append) {
			var html_line = '$line <br/>';
			file_lines.insert(start_line, html_line);
			start_line++;
		}

		var new_index_file = file_lines.join('\n');

		File.saveContent(path_index, new_index_file);
	}
}