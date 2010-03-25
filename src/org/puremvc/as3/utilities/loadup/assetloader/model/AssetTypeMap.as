/*
	PureMVC Utility - Loadup
	Copyright (c) 2008-09 Philip Sexton <philip.sexton@puremvc.org>
	Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package org.puremvc.as3.utilities.loadup.assetloader.model
{
    import flash.net.URLRequest;
    import flash.system.LoaderContext;

    import org.puremvc.as3.utilities.loadup.Loadup;
    import org.puremvc.as3.utilities.loadup.assetloader.interfaces.IAssetTypeMap;
    import org.puremvc.as3.utilities.loadup.assetloader.model.assets.AssetOfTypeImage;
    import org.puremvc.as3.utilities.loadup.assetloader.model.assets.AssetOfTypeSwf;
    import org.puremvc.as3.utilities.loadup.assetloader.model.assets.AssetOfTypeText;
    import org.puremvc.as3.utilities.loadup.assetloader.model.loaders.AssetLoadByLoader;
    import org.puremvc.as3.utilities.loadup.assetloader.model.loaders.AssetLoadByURLLoader;

    /**
     *  An asset must have a type; the default types are Image, Text and Swf. 
     * <p>
     * Map asset types to...<ul>
     * <li>asset classes</li>
     * <li>asset loader classes</li>
     * <li>LoaderContext objects (optional)</li>
     * <li>URLRequest objects (optional).</li></ul></p>
     * <p>
     * LoaderContext is relevant when Loader.load() requires a non-null context argument.</p>
     * <p>
     * URLRequest is relevant, as used by loaders, when it requires particular property settings,
     * for example, the requestHeaders property.</p>
     * <p>
     * It is assumed that a type that maps to a LoaderContext object, must also map to the 
     * AssetLoadByLoader class in the main map.</p>
     * 
     */
	public class AssetTypeMap implements IAssetTypeMap
	{
    	protected function defaultMap() :Object {
    	    var obj :Object = new Object();
    	    obj[ Loadup.IMAGE_ASSET_TYPE ]     = [ AssetOfTypeImage, AssetLoadByLoader ];
    	    obj[ Loadup.TEXT_ASSET_TYPE ]      = [ AssetOfTypeText, AssetLoadByURLLoader ];
    	    obj[ Loadup.SWF_ASSET_TYPE ]       = [ AssetOfTypeSwf, AssetLoadByLoader ];
    	    return obj;
    	}

    	protected function defaultMapToLoaderContext() :Object {
    	    var obj :Object = new Object();
    	    /*--------------
    	    *  For example...
    	    obj[ Loadup.xxxxx_ASSET_TYPE ]     = new LoaderContext( whatever );
    	    ...
    	    ----------------*/
    	    return obj;
    	}

    	protected function defaultMapToURLRequest() :Object {
    	    var obj :Object = new Object();
    	    /*---------------
    	    *  For example...
    	    var ureq :URLRequest;
    	    ureq = new URLRequest();
    	    ureq.xxx = whatever
    	    ureq.yyy = whatever
    	    ...
    	    obj[ Loadup.xxxxx_ASSET_TYPE ] = ureq;
    	    ureq = new URLRequest();
    	    ureq.aaa = whatever
    	    ureq.bbb = whatever
    	    ...
    	    obj[ Loadup.yyyyy_ASSET_TYPE ] = ureq;
    	    ...
    	    ---------------*/
    	    return obj;
    	}

        protected var map :Object;

        /**
         *  Could be empty, only use when required.
         */
        protected var mapToLoaderContext :Object;

        /**
         *  Could be empty, only use when required.
         */
        protected var mapToURLRequest :Object;

		public function AssetTypeMap( map :Object = null, mapToLoaderContext :Object = null, 
		    mapToURLRequest :Object = null )
		{
		    this.map = ( map ? map : defaultMap() );
            this.mapToLoaderContext = ( mapToLoaderContext ? mapToLoaderContext : defaultMapToLoaderContext() );
            this.mapToURLRequest = ( mapToURLRequest ? mapToURLRequest : defaultMapToURLRequest() );
		}

        public function getAssetClass( assetType :String ) :Class {
            return map[ assetType ][0];
        }

        public function getAssetLoaderClass( assetType :String ) :Class {
            return map[ assetType ][1];
        }

        public function getLoaderContext( assetType :String ) :LoaderContext {
            return mapToLoaderContext[ assetType ];
        }
        public function getURLRequest( assetType :String ) :URLRequest {
            return mapToURLRequest[ assetType ];
        }

	}
}