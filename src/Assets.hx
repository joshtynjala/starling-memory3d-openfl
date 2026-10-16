import openfl.Vector;
import openfl.display.BitmapData;
import openfl.errors.Error;

import starling.core.Starling;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

class Assets
{
    private static var _atlas:TextureAtlas;
    
    public static function getTexture(name:String):Texture
    {
        init();
        return _atlas.getTexture(name);
    }
    
    public static function getTextures(prefix:String):Vector<Texture>
    {
        init();
        return _atlas.getTextures(prefix);
    }
    
    private static function init():Void
    {
        if (Starling.current == null)
            throw new Error("Initialize Starling before accessing textures.");
        
        if (_atlas == null)
        {
            var atlasBitmapData:BitmapData = openfl.utils.Assets.getBitmapData("assets/textures/atlas.png");
            var atlasTexture:Texture = Texture.fromBitmapData(atlasBitmapData, false);
            var atlasXml:Xml = Xml.parse(openfl.utils.Assets.getText("assets/textures/atlas.xml"));
            
            _atlas = new TextureAtlas(atlasTexture, atlasXml);
        }
    }
}