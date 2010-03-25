/*
	PureMVC Utility - Loadup
	Copyright (c) 2008-2009 Philip Sexton <philip.sexton@puremvc.org>
	Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package org.puremvc.as3.utilities.loadup.assetloader.model
{
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;

    import org.puremvc.as3.utilities.loadup.Loadup;
	import org.puremvc.as3.utilities.loadup.interfaces.ILoadupProxy;
	import org.puremvc.as3.utilities.loadup.controller.FailureInfo;
    import org.puremvc.as3.utilities.loadup.model.LoadupMonitorProxy;
    import org.puremvc.as3.utilities.loadup.assetloader.interfaces.IAssetLoader;
    import org.puremvc.as3.utilities.loadup.assetloader.interfaces.IAsset;

    /**
     *  This is a proxy class for an asset.  It contains an IASSET object.  It is created
     *  before the asset is loaded, and is involved in the loading.  It implements
     *  ILoadupProxy so that the Loadup utility can be used to manage the asset loading.
     *  <p>
     *  After loading is complete, this proxy remains as a repository of the IASSET object.</p>
     *  <p>
     *  It is intended that this proxy can act for a range of asset types, providing there is
     *  a suitable loader.  As key to understanding the approach, see AssetTypeMap, AssetFactory 
     *  and AssetLoaderFactory.</p>
     *  <p>
     *  The loader class, of type IAssetLoader, has a Delegate type role.  It works for this 
     *  AssetProxy class and reports back to it.</p>
     *  
     */
	public class AssetProxy extends Proxy implements ILoadupProxy
	{
        protected var assetGroupProxy :AssetGroupProxy;
        protected var loader :IAssetLoader;

        protected var bytesLoaded :Number = 0;
        protected var bytesTotal :Number = 0;
		protected var loadingCommenced :Boolean = false;
        protected var loaded :Boolean = false;

        /**
         *  Contains the latest error message, if there is one. 
         */
        protected var loadingErrorMessage :String = "";

		public function AssetProxy( assetGroupProxy :AssetGroupProxy, proxyName :String, data :IAsset ) {
		    this.assetGroupProxy = assetGroupProxy;
			super( proxyName, data );
		}
		
		public function get url() :String {
		    return (data as IAsset).url;
		}
		public function get asset() :IAsset {
	        return data as IAsset;
		}
		public function set assetData( data :Object ) :void {
		    //( data as IAsset ).data = data;
		    asset.data = data;
		}
		public function getBytesLoaded() :Number {
		    return bytesLoaded;
		}
		public function getBytesTotal() :Number {
		    return bytesTotal;
		}
		public function isLoadingCommenced() :Boolean {
		    return loadingCommenced;
		}
		public function isLoaded() :Boolean {
		    return loaded;
		}
		public function getLoadingErrorMessage() :String {
		    return loadingErrorMessage;
		}

        // assume only invoked by loadup utility 
        public function load() :void {
            loadingCommenced = true;
            if (loaded) {
                // don't really expect this case
                doSendNotification( Loadup.ASSET_LOADED, getProxyName() );
            }
            else {
                this.loader = assetGroupProxy.getAssetLoaderFactory().getAssetLoader( asset.type, this );
                loader.load( url );
            }
        }

        /**
         *  The following suite of 'loading...' methods are callable from the loader object,
         *  based on loading events and outcomes.  They are not for public use otherwise.
         */

        /**
         *  Responds to feedback from the loader object.  Progress notifications are sent at
         *  the asset group level.
         */
        public function loadingProgress( bytesLoaded :Number, bytesTotal :Number ) :void {
            this.bytesLoaded = bytesLoaded;
            this.bytesTotal = bytesTotal;
            assetGroupProxy.loadingProgress( this );
        }
        /**
         *  Responds to feedback from the loader object, that loading is complete.
         *  Send ASSET_LOADED note, absolutely essential to the Loadup utility.
         *  Send NEW_ASSET_AVAILABLE note, may be of interest to client app.
         *  Always include the notification type, to enable selection in client app.
         */
        public function loadingComplete( loadedData :Object ) :void {
            loaded = true;
            assetData = loadedData;
            loadingErrorMessage = "";
            doSendNotification( Loadup.NEW_ASSET_AVAILABLE, asset );
            assetGroupProxy.loadingProgress( this, /* force report */ true );
            doSendNotification( Loadup.ASSET_LOADED, getProxyName() );
        }
        /**
         *  Responds to feedback from the loader object, that io error has occurred.
         *  Send ASSET_LOAD_FAILED note, absolutely essential to the Loadup utility.
         *  Send ASSET_LOAD_FAILED_IOERROR note, may be of interest to client app.
         *  Always include the notification type, to enable selection in client app.
         */
        public function loadingIOError( errMsg :String ) :void {
            loadingErrorMessage = errMsg;
            doSendNotification( Loadup.ASSET_LOAD_FAILED_IOERROR, this );
            doSendNotification( Loadup.ASSET_LOAD_FAILED, getProxyName() );
        }
        /**
         *  Responds to feedback from the loader object, that security error has occurred.
         *  Send ASSET_LOAD_FAILED note, absolutely essential to the Loadup utility.  With this
         *  kind or error, tell the LU not to bother with retry.
         *  Send ASSET_LOAD_FAILED_SECURITY note, may be of interest to client app.
         *  Always include the notification type, to enable selection in client app.
         */
        public function loadingSecurityError( errMsg :String ) :void {
            loadingErrorMessage = errMsg;
            var infoToLoadup :FailureInfo = new FailureInfo( getProxyName(), /* allowRetry=NO*/ false);
            doSendNotification( Loadup.ASSET_LOAD_FAILED_SECURITY, this );
            doSendNotification( Loadup.ASSET_LOAD_FAILED, infoToLoadup );
        }

        //--------------------------------------------------------------------
        /**
         *  Notification type is the LoadupMonitorProxy's proxyName.
         *  @see AssetGroupProxy#doSendNotification()
         *  @see org.puremvc.as3.utilities.loadup.model.LoadupMonitorProxy#doSendNotification()
         */
        protected function doSendNotification( notificationName :String, body :Object=null ) :void {
            sendNotification( notificationName, body, assetGroupProxy.getLUMonitorProxyName() );
        }

	}
}