package engine.map;


@:structInit
class FloorPlan
{
	public var rooms:Array<RoomPlan>;
}

@:structInit
class RoomPlan
{
	public var map:Array<String>;
}

@:structInit
class RoomShape
{
	public var short_edge:Int;
	public var long_edge:Int;
}

enum Room
{
	EMPTY;
	BATH;
	WASH;
	WC;
	BED;
	KITCHEN;
}