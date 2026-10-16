import haxe.Constraints.Function;

import openfl.Vector;

import starling.animation.Juggler;
import starling.animation.Transitions;
import starling.display.Sprite;
import starling.display.Sprite3D;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.textures.Texture;

class PlayingField extends Sprite3D
{
    private var _cards:Sprite;
    private var _juggler:Juggler;
    private var _selectedCards:Array<Card>;
    private var _numTurnedCards:Int;
    
    private static final ANIM_TIME:Float = 0.5;
    
    public function new()
    {
        super();
        _juggler = new Juggler();
    }
    
    public function dealCards(numColumns:Int, numRows:Int):Void
    {
        removeChildren();
        
        _cards = createCardPlane(numColumns, numRows);
        addChild(_cards);
        
        for (i in 0..._cards.numChildren)
            dealCard(cast(_cards.getChildAt(i), Card), i * 0.075);
        
        _selectedCards  = [];
        _numTurnedCards = 0;
    }
    
    public function removeCards(onComplete:Function):Void
    {
        function complete(card:Card):Void
        {
            onComplete();
        }

        var numCards:Int = _cards.numChildren;
        
        for (i in 0...numCards)
        {
            var card:Card = cast(_cards.getChildAt(i), Card);
            var onRemoved:(Card)->Void = (i < numCards - 1) ? null : complete;
            removeCard(card, i * 0.075, onRemoved);
        }
    }
    
    public function concealAllCards():Void
    {
        for (i in 0..._cards.numChildren)
            turnCard(cast(_cards.getChildAt(i), Card), 0, onCardConcealed);
    }
    
    public function advanceTime(time:Float):Void
    {
        _juggler.advanceTime(time);
    }
    
    private function createCardPlane(numColumns:Int, numRows:Int):Sprite
    {
        var plane:Sprite = new Sprite();
        addChild(plane);
        
        var iconTextures:Vector<Texture> = Assets.getTextures("icon-");
        shuffleTextures(iconTextures);
        
        var cards:Array<Card> = [];
        for (i in 0...Math.floor(numColumns * numRows / 2))
        {
            var iconTexture:Texture = iconTextures.pop();
            cards.push(new Card(i, iconTexture));
            cards.push(new Card(i, iconTexture));
        }
        
        shuffleCards(cards);
        
        var margin:Float = 20;
        var cardSize:Float = cards[0].width;
        var offsetX:Float = (numColumns * cardSize + (numColumns - 1) * margin) / -2;
        var offsetY:Float = (numRows    * cardSize + (numRows    - 1) * margin) / -2;
        var count:Int = 0;
        
        for (col in 0...numColumns)
        {
            for (row in 0...numRows)
            {
                var card:Card = cards.pop();
                card.x = (cardSize + margin) * col + cardSize / 2 + offsetX;
                card.y = (cardSize + margin) * row + cardSize / 2 + offsetY;
                card.useHandCursor = true;
                card.touchGroup = true;
                card.touchable = false;
                card.addEventListener(TouchEvent.TOUCH, onCardTouched);
                plane.addChild(card);
            }
        }
        
        return plane;
    }
    
    // event handlers
    
    private function onCardTouched(event:TouchEvent):Void
    {
        var card:Card = cast(event.target, Card);
        var touch:Touch = event.getTouch(card, TouchPhase.ENDED);
        
        if (touch != null && _selectedCards.length < 2)
        {
            _selectedCards.push(card);
            card.touchable = false;
            turnCard(card, 0, onCardRevelead);
        }
    }
    
    private function onCardRevelead(card:Card):Void
    {
        if (_selectedCards.indexOf(card) == 1)
        {
            if (_selectedCards[0].id == _selectedCards[1].id)
            {
                _numTurnedCards += 2;
                _selectedCards = [];
                
                if (_numTurnedCards == _cards.numChildren)
                    dispatchEventWith(Event.COMPLETE, true);
            }
            else
            {
                turnCard(_selectedCards[0], ANIM_TIME);
                turnCard(_selectedCards[1], ANIM_TIME, function(card:Card):Void
                {
                    _selectedCards[0].touchable = _selectedCards[1].touchable = true;
                    _selectedCards = [];
                });
            }
        }
    }
    
    private function onCardConcealed(card:Card):Void
    {
        card.touchable = true;
    }
    
    // animation
    
    private function dealCard(card:Card, delay:Float=0):Void
    {
        card.alpha = 0;
        card.z = -150;
        
        _juggler.tween(card, ANIM_TIME, {
            z: 0,
            alpha: 1.0,
            delay: delay,
            transition: Transitions.EASE_OUT
        });
    }
    
    private function removeCard(card:Card, delay:Float=0, onComplete:(Card)->Void=null):Void
    {
        card.alpha = 1.0;
        card.z = 0;
        
        _juggler.tween(card, ANIM_TIME, {
            z: -150,
            alpha: 0.0,
            delay: delay,
            onComplete: onComplete,
            onCompleteArgs: [card],
            transition: Transitions.EASE_IN
        });
    }
    
    private function turnCard(card:Card, delay:Float=0, onComplete:(Card)->Void=null):Void
    {
        // We reduce draw calls via a small trick: each *3d-transformed* card will cause
        // a draw call. By swaping the up- and downside of the card before the animation and
        // then making sure it ends with a 'rotationY' of zero, the card will only be
        // 3d-transformed while it's being turned -- not when it lies flat.

        card.swapSides();
        card.rotationY = Math.PI;
        card.concealed = !card.concealed;
        
        _juggler.removeTweens(card);
        _juggler.tween(card, ANIM_TIME, { 
            rotationY: 0,
            delay: delay,
            onComplete: onComplete,
            onCompleteArgs: [card],
            transition: Transitions.EASE_IN_OUT
        });
    }
    
    // helpers
    
    private function shuffleCards(array:Array<Card>):Void
    {
        var length:Int = array.length;
        
        for (i in 0...length) {
            array.insert(Std.int(Math.random() * array.length), array.pop());
        }
    }
    
    private function shuffleTextures(vec:Vector<Texture>):Void
    {
        var length:Int = vec.length;
        
        for (i in 0...length) {
            vec.insertAt(Std.int(Math.random() * vec.length), vec.pop());
        }
    }
}