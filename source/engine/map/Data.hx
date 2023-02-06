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
