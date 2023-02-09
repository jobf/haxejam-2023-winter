package;

import engine.tasks.TaskList.Progression;
import engine.ui.Fonts;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxBitmapText;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxStringUtil;

class ScoreState extends FlxState{
	var score_amount:FlxBitmapText;
	var score_modifier:FlxBitmapText;
	var score_message:FlxBitmapText;
	var instructions:FlxBitmapText;

	override function create() {
		super.create();
		bgColor = 0xff937d66;
		var score_per_second = 12;
		var time_bonus = score_per_second * Progression.completed_session_time;
		var total_score = time_bonus * Progression.completed_session_count;
		
		score_amount = new FlxBitmapText(Fonts.normal());
		add(score_amount);
		// score_amount.autoSize = true;
		score_amount.text = 'BONUS = ' + FlxStringUtil.formatMoney(time_bonus);
		score_amount.screenCenter();
		score_amount.y -= 150;
		
		score_modifier = new FlxBitmapText(Fonts.normal());
		add(score_modifier);
		score_modifier.text = '${Progression.completed_session_count} COMPLETED SESSIONS';
		score_modifier.screenCenter();
		score_modifier.y -= 50;

		score_message = new FlxBitmapText(Fonts.normal());
		add(score_message);
		score_message.text = 'TOTAL = ${FlxStringUtil.formatMoney(total_score)} !!!';
		score_message.screenCenter();
		score_message.y += 50;
		
		instructions = new FlxBitmapText(Fonts.normal());
		add(instructions);
		instructions.text = 'PRESS ENTER TO GO AGAIN';
		instructions.screenCenter();
		instructions.y += 150;


		FlxSpriteUtil.flicker(score_message, 100, 0.25, true, true);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if(FlxG.keys.justReleased.ENTER){
			var is_hard_reset = true;
			Progression.reset(is_hard_reset);
			FlxG.switchState(new PlayStateDungen());
		}
	}
}