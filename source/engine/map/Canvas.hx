package engine.map;

import engine.building.Layout.Placement;
import engine.map.BluePrint;

class AsciiCanvas extends GridLogic
{
	var cells:Array<String>;

	public function new(width:Int, height:Int, empty_symbol:String = ".")
	{
		super(width, height);
		this.cells = [for (i in 0...totalCells()) empty_symbol];
	}

	public function draw_line(x_start:Int, y_start:Int, x_end:Int, y_end:Int, symbol:String)
	{
		var line_thickness = 1;
		for (y in y_start...y_end + line_thickness)
			{
			for (x in x_start...x_end + line_thickness)
			{
				if(isInBounds(x, y)){
					cells[index(x, y)] = symbol;
				}
				else{
					trace('out of bounds $x $y');
				}
			}
		}
	}

	public function get_cell(x:Int, y:Int):String
	{
		return cells[index(x, y)];
	}

	public function set_cell(x:Int, y:Int, symbol:String)
	{
		cells[index(x, y)] = symbol;
	}

	public function draw_rectangle(rect:Rectangle, symbol:String, edge_left:Int, edge_top:Int, fill:Bool = false, is_rotated:Bool = false)
	{
		var rect_to_draw:Rectangle = {
			y: rect.y,
			x: rect.x,
			w: rect.w,
			h: rect.h
		}

		if (is_rotated)
		{
			rect_to_draw.x = rect.y;
			rect_to_draw.y = rect.x;
			rect_to_draw.w = rect.h;
			rect_to_draw.h = rect.w;
		}

		var left = edge_left + rect_to_draw.x;
		var right = edge_left + rect_to_draw.x + rect_to_draw.w;
		var top = edge_top + rect_to_draw.y;
		var bottom = edge_top + rect_to_draw.y + rect_to_draw.h;

		if (fill)
		{
			for (x in top...bottom)
			{
				for (y in left...right)
				{
					cells[index(x, y)] = symbol;
				}
			}
		}
		else
		{
			draw_line(left, top, right, top, symbol);
			draw_line(left, bottom, right, bottom, symbol);
			draw_line(left, top, left, bottom, symbol);
			draw_line(right, top, right, bottom, symbol);
		}
	}

	public function stamp_canvas(canvas:AsciiCanvas, x_offset_by:Int, y_offset_by:Int)
	{
		for (x in 0...canvas.numColumns)
		{
			for (y in 0...canvas.numRows)
			{
				var symbol = canvas.get_cell(x, y);
				if(symbol == "."){
					continue;
				}
				set_cell(x + x_offset_by, y + y_offset_by, symbol);
			}
		}
	}

	public function print(empty_char:String = " ")
	{
		for (r in 0...numRows)
		{
			var start = r * numColumns;
			var end = start + numColumns;
			var line = cells.slice(start, end).join("");
			var cleaned = StringTools.replace(line, ".", empty_char);

			cleaned = StringTools.replace(cleaned, "+", " ");
			cleaned = StringTools.replace(cleaned, "o", ",");
			trace(cleaned);
		}
	}

	public function csv() :String
	{
		var stringbuffer = new StringBuf();
		for (r in 0...numRows)
		{
			var start = r * numColumns;
			var end = start + numColumns;
			var line = cells.slice(start, end).join(",");
			var cleaned = StringTools.replace(line, ".", "0");
			cleaned = StringTools.replace(cleaned, "##", "#");
			cleaned = StringTools.replace(cleaned, "#", "1");
			cleaned = StringTools.replace(cleaned, "+", "0");
			cleaned = StringTools.replace(cleaned, "o", "0");
			stringbuffer.add(cleaned + '\n');
			// trace(cleaned);
		}

		return stringbuffer.toString();
	}

	public function rotate_clockwise()
	{
		var size = numColumns;
		var rotated:Array<String> = [for (i in 0...cells.length) "."];
		for (i in 0...size)
		{
			for (j in 0...size)
			{
				rotated[i * size + j] = cells[(size - j - 1) * size + i];
			}
		}
		cells = rotated;
	}

	public function get_empty_spaces(grid_size:Int):Array<Placement> {
		var placements:Array<Placement> = [];
		for(i => cell in cells){
			if(cell == "."){
				var x = column(i);
				var y = row(i);
				
				placements.push({
					x_pixel: x * grid_size,
					y_pixel: y * grid_size,
					location: EMPTY
				});
			}
		}
		return placements;
	}
}

class GridLogic
{
	public var numColumns(default, null):Int;
	public var numRows(default, null):Int;

	public function new(numColumns:Int, numRows:Int)
	{
		this.numColumns = numColumns;
		this.numRows = numRows;
	}

	public function totalCells():Int
	{
		return numColumns * numRows;
	}

	public function isInBounds(column:Int, row:Int):Bool
	{
		return column >= 0 && row >= 0 && column < numColumns && row < numRows;
	}

	public function column(index:Int):Int
	{
		return Std.int(index % numColumns);
	}

	public function row(index:Int):Int
	{
		return Std.int(index / numColumns);
	}

	public function index(column:Int, row:Int):Int
	{
		return column + numColumns * row;
	}
}
