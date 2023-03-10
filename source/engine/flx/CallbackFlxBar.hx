package engine.flx;

import flixel.ui.FlxBar;

class CallbackFlxBar extends FlxBar
{
	var getValue:() -> Float;

	public function new(x:Float = 0, y:Float = 0, ?direction:FlxBarFillDirection, width:Int = 100, height:Int = 10, color_bg:Int, color_fg:Int, getValue:() -> Float, min:Float = 0,
			max:Float = 100, showBorder:Bool = false)
	{
		
		super(x, y, direction, width, height, color_bg, color_fg, null, null, min, max);
		this.getValue = getValue;
	}

	override public function update(elapsed:Float):Void
	{
		value = getValue();
		super.update(elapsed);
	}
}