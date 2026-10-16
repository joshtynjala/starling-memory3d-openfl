import openfl.geom.Point;

import starling.display.Quad;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

class Game extends Sprite
{
    private static final NUM_ROWS:Int = 3;
    private static final NUM_COLUMNS:Int = 4;
    
    private var _playingField:PlayingField;
    
    public function new()
    {
        super();

        addEventListener(Event.ADDED_TO_STAGE, init);
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
        addEventListener(Event.COMPLETE, onComplete);
        addEventListener(TouchEvent.TOUCH, onTouch);
    }
    
    private function init():Void
    {
        var width:Int  = stage.stageWidth;
        var height:Int = stage.stageHeight;
        
        var background:Quad = createBackground(width, height, 0x80b0, 0xa7ff); 
        addChild(background);
        
        _playingField = new PlayingField();
        _playingField.x = width / 2;
        _playingField.y = height / 2;
        _playingField.rotationX = -0.6;
        addChild(_playingField);
        
        startGame();
    }
    
    private function startGame():Void
    {
        _playingField.dealCards(NUM_COLUMNS, NUM_ROWS);
        addEventListener(TouchEvent.TOUCH, onStartTouch);
        useHandCursor = true;
    }
    
    // event handlers
    
    private function onTouch(event:TouchEvent):Void
    {
        var touch:Touch = event.getTouch(this, TouchPhase.MOVED);
        
        if (_playingField != null && event.shiftKey && touch != null)
        {
            var delta:Point = touch.getMovement(this);
            _playingField.rotationX += delta.y * 0.01;
            _playingField.rotationY -= delta.x * 0.01;
        }
    }
    
    private function onStartTouch(event:TouchEvent):Void
    {
        if (event.getTouch(this, TouchPhase.ENDED) != null)
        {
            useHandCursor = false;
            removeEventListener(TouchEvent.TOUCH, onStartTouch);
            _playingField.concealAllCards();
        }
    }
    
    private function onEnterFrame(event:EnterFrameEvent, passedTime:Float):Void
    {
        _playingField.advanceTime(passedTime);
    }
    
    private function onComplete():Void
    {
        _playingField.removeCards(startGame);
    }
    
    // helpers
    
    private function createBackground(width:Int, height:Int, colorA:UInt, colorB:UInt):Quad
    {
        var quad:Quad = new Quad(width, height, colorA);
        quad.setVertexColor(2, colorB);
        quad.setVertexColor(3, colorB);
        return quad;
    }
}