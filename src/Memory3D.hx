import openfl.display.Sprite;

import starling.core.Starling;

class Memory3D extends Sprite
{
	private var _starling:Starling;
	
	public function new()
	{
		super();
		_starling = new Starling(Game, stage, null, null, "auto", "auto");
		_starling.start();
	}
}