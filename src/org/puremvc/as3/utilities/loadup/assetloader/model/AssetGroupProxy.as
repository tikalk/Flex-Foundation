/*
	PureMVC Utility - Loadup
	Copyright (c) 2008-2009 Philip Sexton <philip.sexton@puremvc.org>
	Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package org.puremvc.as3.utilities.loadup.assetloader.model
{
	//import flash.display.Loader;

	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;

    import org.puremvc.as3.utilities.loadup.Loadup;
    import org.puremvc.as3.utilities.loadup.model.LoadupMonitorProxy;
    import org.puremvc.as3.utilities.loadup.assetloader.interfaces.IAsset;
    import org.puremvc.as3.utilities.loadup.assetloader.interfaces.IAssetLoaderFactory;

    /**
     *  This is a proxy class for a group of assets.  It contains a list of AssetProxy objects,
     *  one for each asset.  It is mainly concerned with the loading of those assets.  Loading is
     *  carried out by the Loadup utility (LU), using one instance of LoadupMonitorProxy.
     *  <p>
     *  After loading is complete, this proxy remains as a repository of the AssetProxy objects
     *  and hence of the assets themselves.</p>
     *  <p>
     *  As key to understanding AssetGroupProxy and AssetProxy, first see AssetTypeMap, 
     *  AssetFactory and AssetLoaderFactory.</p>
     *  <p>
     *  Loading progress reporting is managed here, being the progress of the group of assets. The
     *  approach adopted ignores the LU progress reporting.  The standard LU progress reporting is
     *  simply based on number of assets loaded.  We want to take account of asset size.</p>
     *  <p>
     *  An alternative that would integrate with LU progress notification could be as follows
     *  <ul>
     *  <li>extend ResourceList and override get progressPercentage so as to use AssetGroupProxy and
     *  AssetProxy information and thus calculate the percentage in a manner equivalent to the
     *  approach used here</li>
     *  <li>inject this custom ResourceList into the LoadupMonitorProxy constructor; creating and
     *  registering a new LoadupMonitorProxy should not be a problem, providing there is not one
     *  currently active</li>
     *  <li>invoke the Loadup utility sendProgressNotification() method each time a progress report
     *  is required.</li>
     *  </ul></p>
     *  <p>
     *  The approach adopted here is considered simpler than the above alternative.</p>
     *  
     */
	public class AssetGroupProxy extends Proxy
	{
        protected const NEED_MONITOR_MSG :String = 
            ": Need Monitor, AssetGroupProxy is invalid without a LoadupMonitorProxy";

        protected var assetLoaderFactory :IAssetLoaderFactory;
        protected var luMonitor :LoadupMonitorProxy;
        protected var _progressReportInterval :Number = 0.5; //secs, = 500 msecs.
        protected var timeOfLastProgressReport :Date = new Date();

        /**
         *  This property, luMonitorProxyName, exists for robustness, since 
         *  it continues to have a value even if luMonitor is nulled via cleanup; we rely on
         *  it when sending notifications. 
         */
        protected var luMonitorProxyName :String;

		/**
		 * Constructor
		 *    @param factory 
		 *    @param proxyName
		 *    @param monitor if not specified, then the monitor with name LoadupMonitorProxy.NAME is assumed, 
		 *    but note that onRegister will throw an Error if the monitor does not exist.
		 */
		public function AssetGroupProxy( factory :IAssetLoaderFactory, proxyName :String, 
		    monitor :LoadupMonitorProxy =null ) 
		{
			    super( proxyName, new Array() );
    			this.assetLoaderFactory = factory;
    			this.luMonitor = monitor;
		}
		override public function onRegister() :void {
		    if ( luMonitor == null ) {
		        luMonitor = facade.retrieveProxy( LoadupMonitorProxy.NAME ) as LoadupMonitorProxy;
		        if ( luMonitor == null )
    			    throw new Error( NEED_MONITOR_MSG );
		    }
		}

		public function getAssetLoaderFactory() :IAssetLoaderFactory {
		    return assetLoaderFactory;
		}

		public function getLUMonitor() :LoadupMonitorProxy {
		    return luMonitor;
		}
		public function getLUMonitorProxyName() :String {
		    if ( ! luMonitorProxyName ) luMonitorProxyName = luMonitor.getProxyName();
		    return luMonitorProxyName;
		}

		public function addAssetProxy( px :IProxy ) :void {
		    assetProxies.push( px );
		}

		public function set progressReportInterval( interval :Number ) :void {
		    _progressReportInterval = interval;
		}
		public function get progressReportInterval() :Number {
		    return _progressReportInterval;
		}

		public function isLoaded() :Boolean {
            var assetPx :AssetProxy;
            for (var i:int=0; i < assetProxies.length; i++) {
                assetPx = assetProxies[ i ] as AssetProxy;
                if ( ! assetPx.isLoaded() )
                    return false;
            }
            return true;
        }
		public function getAssetProxy( url :String ) :AssetProxy {
		    var assetPx :AssetProxy;
		    for (var i:int=0; i < assetProxies.length; i++) {
		        assetPx = assetProxies[i] as AssetProxy;
		        if ( assetPx && ( assetPx.url == url ))
		            return assetPx;
		    }
		    return null;
		}
		public function getAsset( url :String ) :IAsset {
		    var assetPx :AssetProxy = getAssetProxy( url );
	        return  assetPx ? assetPx.asset : null;
		}

        /**
         *  Re the calculation of percent loaded for the asset group
         *  - a count of number loaded, as one of the inputs, proved of little value, since the 
         *  loading complete event can occur a relatively long time after the bytes have been loaded.
         *  
         */
        public function loadingProgress( assetPx :AssetProxy, forceReport :Boolean = false ) :void {
            if ( forceReport || progressReportIsDue() ) {
                timeOfLastProgressReport = new Date();
                var percentLoaded :Number;
                 if ( allAssetProxiesHaveBytesTotal() ) {
                    percentLoaded =  ( calcOverallBytesLoaded() *100 ) / calcOverallBytesTotal() ;
                }
                else {
                    // rough estimate, ignores relative asset sizes
                    percentLoaded = ( sumOfAssetPercentsLoaded() / assetProxies.length );
                }
                doSendNotification( Loadup.ASSET_GROUP_LOAD_PROGRESS, percentLoaded );
            }
        }


        public function allAssetProxiesHaveBytesTotal() :Boolean {
            for (var i:int=0; i < assetProxies.length; i++) {
                if (( assetProxies[i] as AssetProxy ).getBytesTotal() == 0 )
                    return false;
            }
            return true;
        }
        public function calcOverallBytesTotal() :Number {
            var total :int =0;
            for (var i:int=0; i < assetProxies.length; i++) {
                total += ( assetProxies[i] as AssetProxy ).getBytesTotal();
            }
            return total;
        }
        /**
         *  For an asset with bytesTotal of zero, ignore any bytesLoaded value.
         */
        public function calcOverallBytesLoaded() :Number {
            var total :int =0;
            var assetPx :AssetProxy;
            for (var i:int=0; i < assetProxies.length; i++) {
                assetPx = assetProxies[ i ] as AssetProxy;
                if ( assetPx.getBytesTotal() > 0 )
                    total += assetPx.getBytesLoaded();
            }
            return total;
        }
        public function sumOfAssetPercentsLoaded() :Number {
            var sum :Number =0;
            var assetPx :AssetProxy;
            for (var i:int=0; i < assetProxies.length; i++) {
                assetPx = assetProxies[ i ] as AssetProxy;
                if ( assetPx.isLoaded() )
                    sum += 100;
                else if ( assetPx.getBytesTotal() > 0 )
                    sum +=  ( assetPx.getBytesLoaded() *100 ) / assetPx.getBytesTotal();
            }
            return sum;
        }
        /**
         *  This cleanup feature provides the client app with the option to remove, from this 
         *  AssetGroupProxy, references that relate only to the process of loading assets, when
         *  they are no longer needed.  For example, the references to LoadupMonitorProxy and
         *  IAssetLoaderFactory are removed. A condition for this removal is that the 
         *  LoadupMonitorProxy has been de-registered.
         */
        public function cleanupAfterLoading() :void {
            if ( luMonitor && !facade.hasProxy( luMonitor.getProxyName() )) {
                luMonitor = null;
                assetLoaderFactory = null;
            }
        }
        /**
         *  This cleanup feature provides the client app with a way to remove (i.e. de-register using
         *  facade.removeProxy) the AssetProxy objects belonging to this AssetGroupProxy.  The context
         *  is that this AssetGroupProxy is no longer required.
         */
        public function cleanup() :void {
            removeAssetProxies();
            // and the following, just for completeness.
            luMonitor = null;
            assetLoaderFactory = null;
        }

        //--------------------------------------------------------------------
		protected function get assetProxies() :Array {
		    return data as Array;
		}

        protected function progressReportIsDue() :Boolean {
            var timeNow :Date = new Date();
            if ( timeNow.time >= ( timeOfLastProgressReport.time + progressReportInterval*1000 ))
                return true;
            else
                return false;
        }

        /**
         *  Notification type is the LoadupMonitorProxy's proxyName.
         *  @see org.puremvc.as3.utilities.loadup.model.LoadupMonitorProxy#doSendNotification()
         */
        protected function doSendNotification( notificationName :String, body :Object=null ) :void {
            sendNotification( notificationName, body, getLUMonitorProxyName() );
        }

        /**
         *  @see #cleanup()
         */
        protected function removeAssetProxies() :void {
            var assetPx :AssetProxy;
            for (var i:int=0; i < assetProxies.length; i++) {
                assetPx = assetProxies[ i ] as AssetProxy;
                   facade.removeProxy( assetPx.getProxyName() );
            }
            assetProxies.length = 0;
        }

	}
}