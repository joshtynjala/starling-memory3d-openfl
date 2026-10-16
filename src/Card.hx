import openfl.geom.Vector3D;

import starling.display.Image;
import starling.display.Sprite;
import starling.display.Sprite3D;
import starling.display.Stage;
import starling.events.Event;
import starling.textures.Texture;

class Card extends Sprite3D
{
    private var _front:Sprite;
    private var _back:Sprite;
    private var _id:Int;
    private var _concealed:Bool;
    
    private static var sHelperPoint3D:Vector3D = new Vector3D();
    
    public function new(id:Int, iconTexture:Texture)
    {
        super();
        init(id, iconTexture);
    }
    
    private function init(id:Int, iconTexture:Texture):Void
    {
        _id = id;
        _concealed = false;
        
        var cardFront:Image = new Image(Assets.getTexture("card-front"));
        var cardBack:Image = new Image(Assets.getTexture("card-back"));
        var icon:Image = new Image(iconTexture);
        
        _front = new Sprite();
        _front.addChild(cardFront);
        
        icon.scaleX = icon.scaleY = 0.8;
        icon.x = (cardFront.width  - icon.width)  / 2;
        icon.y = (cardFront.height - icon.height) / 2;
        
        _front.addChild(icon);
        _front.alignPivot();
        
        _back = new Sprite();
        _back.addChild(cardBack);
        _back.alignPivot();
        _back.scaleX = -1;
        
        addChild(_front);
        addChild(_back);
        
        addEventListener(Event.ENTER_FRAME, updateVisibility);
    }
    
    public function updateVisibility():Void
    {
        var stage:Stage = this.stage;
        if (stage == null) return;
        
        stage.getCameraPosition(this, sHelperPoint3D);
        
        _front.visible = sHelperPoint3D.z <  0;
        _back.visible  = sHelperPoint3D.z >= 0;
        
        if (scaleX * scaleY < 0)
        {
            _front.visible = !_front.visible;
            _back.visible  = !_back.visible;
        }
    }
    
    public function swapSides():Void
    {
        var tmp:Sprite = _front;
        _front = _back;
        _back = tmp;

        _front.scaleX *= -1;
        _back.scaleX *= -1;
    }

    public var id(get, never):Int;

    private function get_id():Int { return _id; }
    
    public var concealed(get, set):Bool;

    private function get_concealed():Bool { return _concealed; }
    private function set_concealed(value:Bool):Bool { return _concealed = value; }
}