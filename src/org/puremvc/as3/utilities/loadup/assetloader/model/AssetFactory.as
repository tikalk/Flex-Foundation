/*
	PureMVC Utility - Loadup
	Copyright (c) 2008-09 Philip Sexton <philip.sexton@puremvc.org>
	Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package org.puremvc.as3.utilities.loadup.assetloader.model
{
    import org.puremvc.as3.utilities.loadup.Loadup;
    import org.puremvc.as3.utilities.loadup.assetloader.interfaces.IAsset;
    import org.puremvc.as3.utilities.loadup.assetloader.interfaces.IAssetFactory;
    import org.puremvc.as3.utilities.loadup.assetloader.interfaces.IAssetTypeMap;

    /**
     *  This factory produces IAsset objects via its getAsset method.  The inputs are the asset url
     *  and an optional type.  When a type is not given, it is calculated from the url, based on the
     *  url string ending, as follows
     *  <ul>
     *  <li>.jpg, .gif, .png => Image</li>
     *  <li>.txt, .xml, .css => Text</li>
     *  <li>.swf => Swf</li>
     *  <li>any other alphabetic ending, e.g. .abcde, => Text</li>
     *  <li>otherwise, e.g. no ending, => Error is thrown.</li></ul>
     *  <p>
     *  At instantiation, the factory is given an IAssetTypeMap instance.  Given the asset type, this map 
     *  is used to lookup the Class to use to instantiate the IAsset object.</p>
     */
	public class AssetFactory implements IAssetFactory
	{
		protected const UNEXPECTED_URL_TYPE_MSG :String =
		    ": AssetFactory, urlToType(), unexpected url type";

        protected var assetTypeMap :IAssetTypeMap;

		public function AssetFactory( assetTypeMap :IAssetTypeMap ) {
		    this.assetTypeMap = assetTypeMap;
		}
		//----------------------------------------------------------------------------

		public function getAsset( url :String, type :String = null ) :IAsset {
		    var assetType :String = type;
		    if ( ! assetType )
		        assetType = urlToType( url );
		    var assetClass :Class = assetTypeMap.getAssetClass( assetType );
		    return new assetClass( url );
		}

        //-----------------------------------------------------------------------------

		protected function urlToType( url :String ) :String {
		    var urllo :String = url.toLowerCase();
		    // the typical endings...
		    if ( endsWithAnyOf( urllo, [".jpg", ".gif", ".png"] ) ) return Loadup.IMAGE_ASSET_TYPE;

		    else if ( endsWithAnyOf( urllo, [".txt", ".xml", ".css"] ) ) return Loadup.TEXT_ASSET_TYPE;

		    else if ( endsWithAnyOf( urllo, [".swf"] ) ) return Loadup.SWF_ASSET_TYPE;

            // else default to Text for any other alphabetic ending
            else if ( urllo.match(/\.[a-z]+$/)) return Loadup.TEXT_ASSET_TYPE;

            else throw new Error( url + UNEXPECTED_URL_TYPE_MSG );
		}

		protected function endsWithAnyOf( url :String , endings :Array ) :Boolean {
		    var ulen : int = url.length;
		    var ix :int;
		    for (var i:int=0; i < endings.length; i++ ) {
		        ix = url.lastIndexOf( endings[i] );
		        if ( ix >= 0 && ( ix == ulen - endings[i].length ) )
		            return true;
		    }
		    return false;
		}

	}
}