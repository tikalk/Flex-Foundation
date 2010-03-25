/*
	PureMVC Utility - Loadup - Manage loading of resources
	Copyright (c) 2007-2008, collaborative, as follows
	2007 Daniele Ugoletti, Joel Caballero
	2008 Philip Sexton <philip.sexton@puremvc.org>
	2009 Philip Sexton <philip.sexton@puremvc.org>
	Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package org.puremvc.as3.utilities.loadup.model
{
	import org.puremvc.as3.interfaces.IProxy;
    import org.puremvc.as3.patterns.proxy.Proxy;
    import org.puremvc.as3.utilities.loadup.interfaces.ILoadupProxy;
    import org.puremvc.as3.utilities.loadup.interfaces.IResourceList;
    import org.puremvc.as3.utilities.loadup.interfaces.IRetryPolicy;
    import org.puremvc.as3.utilities.loadup.interfaces.IRetryParameters;
    import org.puremvc.as3.utilities.loadup.Loadup;

	/**
	*  The Loadup utility offers a solution to the problem of how to manage the loading of data resources, 
	*  be that at application startup or at some other time in the duration of the application.  See the
	*  Loadup class for an introduction to this utility.
	*  <p>
	*  An example of use is as follows. 
	*  In the context of the puremvc framework, the application typically has a startup command that manages 
	*  the instantiation of essential actors like proxies and mediators.  At this time, you may also want to 
	*  prime the application with some resources, for example data, before allowing user interaction. This 
	*  utility offers a way of doing that.</p>
	*  <p>
	*  The utility enables the application to do the following
	*  <ul><li>
	*  state how the resource loading should be sequenced so that dependent resources are loaded in correct order</li>
	*  <li>specify a retry policy, per resource</li>
	*  <li>be aware of the progress of the resource loading</li>
	*  <li>know when the resource loading is complete</li>
	*  <li>cater for an open-ended list of resources.</li></ul>
	*  <p>
	*  The demo app called LoadupAsOrdered provides an example use of this utility.</p>
	*  <p>
	*  This LoadupMonitorProxy class has the main role in managing the loading process.  The client application 
	*  creates an instance of it for each batch of loading to be done.  The term Monitor is used in the
	*  following documentation to signify this instance. Each Monitor instance is made unique by the
	*  proxyName it is given; hence there can be concurrent instances. When only one instance is required, the
	*  default name may well be sufficient. When the client application is finished with an instance, it should
	*  invoke the cleanup operation to facilitate garbage collection.</p>
	*  <p>
	*  Repeated use of one monitor instance is possible, serial not concurrent, by invoking the reset 
	*  operation to reset the state of the monitor and ready it for reuse.</p>
	*  <p>
	*  For each loadup resource to be managed, the app has created a <code>LoadupResourceProxy</code>
	*  object.  The app must register each of these with the Monitor, using the <code>addResource</code>
	*  method.  See the <code>LoadupResourceProxy</code> class for detail on that class.</p>
	*  <p>
	*  It is assumed that the app has defined separate 'loaded' notifications for each resource.  When the
	*  app completes a resource load, it will send the relevant notification.  The app must register the
	*  utility command <code>LoadupResourceLoadedCommand</code> for each of these notifications, so that 
	*  the command can inform the Monitor that the resource has been loaded.</p>
	*  <p>
	*  Given that a resource load could fail, it is also recommended the app defines separate 'failed'
	*  notifications for each resource.  If a fail occurs, the app will send the relevant notification.
	*  The app must register the utility command <code>LoadupResourceFailedCommand</code> for each
	*  of these notifications, so that the command can inform the Monitor that the resource load has failed.</p>
	*  <p>
	*  NOTE NOTE that 'loaded' and 'failed' notifications MUST MUST use the body of the 
	*  <code>Notification</code> to identify the resource, using the application's resource proxy name. In 
	*  the case a 'failed' notification, the body can contain the name as a simple String object, as it would
	*  for a 'loaded' notification, but it can also embed the name in a FailureInfo object.  A FailureInfo 
	*  object enables the app to send a 'do not retry' instruction to the utility, when required.</p>
	*  <p>
	*  NOTE NOTE that 'loaded' and 'failed' notifications, when the monitor instance has its own
	*  custom name, i.e. a name other than the default name, MUST MUST include the monitor's name as the
	*  notification type, so that the utility command (see above) can know which monitor to inform.</p>
	*  <p>
	*  The app starts the loading of resources using the <code>loadResources</code> method.  For each resource
	*  that the Monitor decides should be loaded, it invokes the <code>load</code> method on the app's
	*  resource proxy using the <code>ILoadupProxy</code> interface.</p>
	*  <p>
	*  When the utility receives a 'failed' notification, and the notification does not state 'do not retry',
	*  that is, retry is allowed (this is the default),
	*  the utility will retry to load that resource, subject to the retry policy associated with the resource.</p>
	*  <p>
	*  During the loading of resources, the Monitor can send various notifications to the application.
	*  These are as follows:
	*  <ul><li>LOADING_PROGRESS: sent after each resource load, with percent loaded as the note body, an integer</li>
	*  <li>RETRYING_LOAD_RESOURCE: a load operation has failed and the Monitor is now retrying the load; the 
	*  notification identifies the resource using the app's resource proxy name in the notification body</li>
	*  <li>LOAD_RESOURCE_TIMED_OUT: the Monitor has asked the app to load a resource and has now timed out
	*  the load; the timeout was decided by the <code>LoadupResourceProxy</code> for the resource; the 
	*  notification identifies the resource using the app's resource proxy name in the notification body</li>
	*  <li>LOADING_COMPLETE: all resources have been successfully loaded</li>
	*  <li>LOADING_FINISHED_INCOMPLETE: all resources that could be loaded have been loaded, but not all have
	*  been loaded; some may have failed, even after retries, some may have timed out, some may depend on others 
	*  and one of those others has failed</li>
	*  <li>CALL_OUT_OF_SYNC_IGNORED: the app has called a method on the Monitor and that method is not valid
	*  at this stage of the process</li>
	*  <li>WAITING_FOR_MORE_RESOURCES: when the context is an open-ended resource list (see below), and all 
	*  resources listed so far have been loaded, this notification is sent instead of the LOADING_COMPLETE 
	*  notification</li>
	*  </ul></p>
	*  <p>Each notification sent by the Monitor includes a notification type; this is the Monitor's
	*  proxyName.</p>
	*  <p>
	*  The recommended response of the app to each of these notifications is as follows:
	*  <ul><li>LOADING_PROGRESS: optional</li>
	*  <li>RETRYING_LOAD_RESOURCE: optional</li>
	*  <li>LOAD_RESOURCE_TIMED_OUT: optional, see the <code>getFailedResourcesThisTry()</code> method as another
	*  way to find out what resources have failed or have timed out</li>
	*  <li>LOADING_COMPLETE: should listen for, now the application can proceed</li>
	*  <li>LOADING_FINISHED_INCOMPLETE: should listen for, can try again to load the remaining resources by 
	*  invoking the <code>tryToCompleteLoadResources</code> method on the Monitor; in this case, the Monitor 
	*  resets the retry policy of each outstanding resource, so that the retry history is removed and each 
	*  resource can be retried again to the fullest extent</li>
	*  <li>CALL_OUT_OF_SYNC_IGNORED: should listen for, should probably abort loadup and debug</li>
	*  <li>WAITING_FOR_MORE_RESOURCES: optional</li>
	*  </ul></p>
	*  <p>
	*  Technically, it is worth noting that an application could choose to ignore the <code>LoadupResourceLoadedCommand</code>
	*  and the <code>LoadupResourceFailedCommand</code>, and instead directly invoke the corresponding methods on the Monitor,
	*  namely, <code>resourceLoaded</code> and <code>resourceFailed</code>.</p>
	*  <p>
	*  An Error is thrown when certain exceptions are encountered, for example 
	*  <ul><li>
	*  Invalid Resources: if the Monitor decides that the set of resources cannot
	*  be loaded, for example, there are no resources, or they have inter-dependencies such that it is
	*  not feasible to load them.</li></p>
	*  <p>
	*  The property <code>defaultRetryPolicy</code> is a convenient way of setting a retry policy that will be used
	*  as the default in <code>LoadupResourceProxy</code> objects.  This is assigned an initial value based on the 
	*  utility's own standard retry policy and configured as: maxRetries=0, retryInterval=0, timeout=300secs.  The timeout
	*  is set because it is deemed important to have some fallback timeout in the case of asynchronous operations. 
	*  Also, see method reConfigureAllRetryPolicies() below.</p>
	*  <p>
	*  The utility can be used to load an open-ended list of resources, where the full set of resources is not known 
	*  at the outset.  For example, the first resource loaded might determine what other resources are to be loaded. This 
	*  method of loading is accomplished as follows
	*  <ul><li>
	*  before invoking loadResources(), invoke keepResourceListOpen()</li>
	*  <li>after invoking loadResources(), use addResource() or addResources() to add to the list, as the 
	*  additional resources arise; note that the LoadupResourceProxy 'requires' property should be set before 
	*  adding to the list; this requirement can lead to addResources() being preferred as the means of adding an 
	*  inter-dependent set of resources; consequently, the approach implemented by the 
	*  makeAndRegisterLoadupResource method of the LoadupAsOrdered demo is not applicable in this circumstance</li>
	*  <li>invoke closeResourceList() to inform the monitor that all resources have been added</li>
	*  <li>before invoking loadResources(), set the expectedNumberOfResources property, if you want the report of 
	*  loading progress to be reasonable; this will be used until a more exact number is known.</li></ul></p>
	*  <p>
	*  Adapted from original code of Meekgeek and Daniele Ugoletti,
	*  implemented in Daniele's ApplicationSkeleton_v1.3 demo, Nov 2007,
	*  posted to the puremvc forums.</p>
	*  
	*/
    public class LoadupMonitorProxy extends Proxy implements IProxy {
		public static const NAME :String = "LoadupMonitorProxy";

        // Notifications to client app
		public static const LOADING_PROGRESS :String = Loadup.LOADING_PROGRESS;
		public static const LOADING_COMPLETE :String = Loadup.LOADING_COMPLETE;
		public static const LOADING_FINISHED_INCOMPLETE :String = Loadup.LOADING_FINISHED_INCOMPLETE;
		public static const RETRYING_LOAD_RESOURCE :String = Loadup.RETRYING_LOAD_RESOURCE;
		public static const LOAD_RESOURCE_TIMED_OUT :String = Loadup.LOAD_RESOURCE_TIMED_OUT;
		public static const CALL_OUT_OF_SYNC_IGNORED :String = Loadup.CALL_OUT_OF_SYNC_IGNORED;
		public static const WAITING_FOR_MORE_RESOURCES :String = Loadup.WAITING_FOR_MORE_RESOURCES;

        /**
         *  If the client app overrides the initial value of this var, then it is in charge of its
         *  value; the reset() operation DOES NOT reset it to the initial value.
         */
        public var waitingForMoreResourcesNotificationName :String = WAITING_FOR_MORE_RESOURCES;

        /**
        *  This var is used by the addResourceViaLoadupProxy method.  The client app can assign a value,
        *  to override the initial value, if desired.
        */
        public var prefixIfAutoLRPName :String = Loadup.PREFIX_IF_AUTO_LRP_NAME;

		//--------------------------------

		protected const UNKNOWN_ILOADUP_PROXY_MSG :String = 
		    ": Unknown ILoadupProxy in loaded/failed notification, not known in LoadupMonitorProxy instance named :";

        protected const INVALID_RESET_MSG :String = ": LoadupMonitorProxy does not allow reset at this time";

        protected const INVALID_RESOURCES_MSG :String = ": Invalid set of resources, check dependencies";

        private var _defaultRetryPolicy :IRetryPolicy;

		private var _loadedResources :Array = new Array();
		private var _failedResourcesThisTry :Array = new Array();
		private var loadingActive :Boolean = false;
		private var loadingCommenced :Boolean = false;

		/**
		 * Constructor
		 *    @param proxyName
		 *    @param data If you want to specify data and not proxyName, use (null,data)
		 */
		public function LoadupMonitorProxy( proxyName :String = null, data :IResourceList = null ) {

            super( proxyName ? proxyName : NAME, data ? data : new ResourceList() );

            initializeMonitor();
        }

        /**
         *  @see #reset()
         */
        protected function initializeMonitor() :void {
            resourceList.initialize();
            _defaultRetryPolicy = new RetryPolicy( new RetryParameters(0, 0, 300) );
    		_loadedResources.length = 0;
    		_failedResourcesThisTry.length = 0;
    		loadingActive = false;
    		loadingCommenced = false;
        }

		protected function get resourceList() :IResourceList {
		    return data as IResourceList;
		}

		public function set defaultRetryPolicy( p :IRetryPolicy ) :void {
	        _defaultRetryPolicy = p;
		}
		public function get defaultRetryPolicy() :IRetryPolicy {
		    return _defaultRetryPolicy;
		}

        /**
         *  After loading has 'finished incomplete', this method is a convenient way for the client app
         *  to change the retry policies, where the same input parameters apply to all policy instances. 
         *  Another way is for the app to set a new retry policy instance on each LoadupResourceProxy 
         *  that requires it.  Of course, it is perfectly valid to leave the policies unchanged.
         */
		public function reConfigureAllRetryPolicies( retryParameters :IRetryParameters ) :void {
		    if ( !loadingActive ) {
    			for( var i:int = 0; i < this.resourceList.length; i++) {
    				var r :LoadupResourceProxy = this.resourceList.getItemAt(i) as LoadupResourceProxy;
    				if ( !r.isLoaded() && r.retryPolicy )
    				    r.retryPolicy.reConfigure( retryParameters );
    			}
		    }
		}

        /**
         *  An array of LoadupResourceProxy objects.
         */
        protected function get loadedResources() :Array {
            return _loadedResources;
        }

        /**
         *  An array of LoadupResourceProxy objects.
         */
        protected function get failedResourcesThisTry() :Array {
            return _failedResourcesThisTry;
        }

        /**
         *  These 3 functions provide safe read-only access to 3 non-public objects.
         */
        public function getLoadedResources() :Array { return _loadedResources.concat(); }

        public function getFailedResourcesThisTry() :Array { return _failedResourcesThisTry.concat(); }

        public function getResourceList() :IResourceList { return resourceList.copy(); }

		/**
         *  Add a resource to be loaded.  Should be done before invoking loadResources(), unless client app is
         *  using the facility to keep the resource list open.
         *  In the case of the list being kept open, if adding resources after loading has commenced, add them
         *  in strict logical order according to dependencies; if this is difficult, consider the alternative 
         *  addResources() method. Otherwise, the Invalid Resources error could occur.
         */
		public function addResource( r :LoadupResourceProxy ):void {
		    if ( resourceList.isOpen() ) {
			    resourceList.addResource( r, this );
			    if ( loadingCommenced ) {
			        loadResourcesAfterAddingMoreResources();
			    }
			}
			else
			    doSendNotification( CALL_OUT_OF_SYNC_IGNORED );
		}
		/**
         *  Add resourceS to be loaded.  Should be done before invoking loadResources(), unless client app is
         *  using the facility to keep the resource list open.
         *  This facility to add multiple resources is likely to be useful when adding resources after loading
         *  has commenced and the resources have inter dependencies.
         */
		public function addResources( resources :Array ):void {
		    if ( resourceList.isOpen() ) {
			    resourceList.addResources( resources, this );
			    if ( loadingCommenced ) {
			        loadResourcesAfterAddingMoreResources();
			    }
			}
			else
			    doSendNotification( CALL_OUT_OF_SYNC_IGNORED );
		}
		public function keepResourceListOpen() :void {
		    resourceList.keepOpen();
		}
        /**
         *  If resource list is already closed, then nothing happens.
         */
		public function closeResourceList() :void {
		    if ( ! resourceList.isClosed() )
		        doCloseResourceList();
		}
		protected function doCloseResourceList() :void {
		    resourceList.forceClose();

            if ( loadingCommenced ) {

    		    // now have more exact measure of progress.
    		    sendProgressNotification();

    			if ( allResourcesLoaded() ) {
    			    finishThisTry( LOADING_COMPLETE );
    			}

                // Else are we finished, though all not loaded?
                else if ( isLoadingFinished() ) {
    			    finishThisTry( LOADING_FINISHED_INCOMPLETE );                
                }

    			else {
    			    // Now that resource list is closed, the conditions for loading remaining resources and
    			    // the check for finished may behave differently, so invoke loading again.
			        loadResourcesAfterClosingResourceList();
    			}
            }
		}
		/**
         *  See addResource() above.  This method offers an alternative to that, as a shortcut for the 
         *  client app, whereby the app does not have to create the LoadupResourceProxy (lrp) object for the 
         *  ILoadupProxy object.  Instead, the Loadup utility (LU) will create and register the lrp object, 
         *  naming it as follows
         *  <ul><li>
         *  use the name supplied as the second, optional argument; if supplied</li>
         *  <li>otherwise, create a name by prefixing a suitable string to the name of the given 
         *  ILoadupProxy object; the prefix is specified in the var <code>prefixIfAutoLRPName</code>, which
         *  has an initial value that should usually suffice for uniqueness 
         *  i.e. const Loadup.PREFIX_IF_AUTO_LRP_NAME i.e. "luLR_"</li>
         *  </ul>
         *  This shortcut is probably attractive only if there are no dependencies between the resources, 
         *  because the app requires references to the lrp objects, to express the dependencies. 
         */
		public function addResourceViaLoadupProxy( px :ILoadupProxy, resourceProxyName :String = null ) :void {
		    var lrpName :String = ( resourceProxyName ? resourceProxyName : prefixIfAutoLRPName + px.getProxyName() );
		    var lrp :LoadupResourceProxy = new LoadupResourceProxy( lrpName, px );
		    facade.registerProxy( lrp );
		    addResource( lrp );
		}
		/**
         *  Add resourceS via an array of ILoadupProxy objects - alternative to adding them singly.  In this
         *  case, the client app must accept the default naming of the LoadupResourceProxy objects. 
         */
		public function addResourcesViaLoadupProxy( pxs :Array ) :void {
		    for ( var i:int=0; i < pxs.length; i++ ) {
		        addResourceViaLoadupProxy( pxs[i] as ILoadupProxy );
		    }
		}

        /**
         *  Find the resource, that is, the LoadupResourceProxy object, where the corresponding
         *  ILoadupProxy object has the given name.  Return null if not found.  An example use
         *  of this is with the proxyName caotained in a notification from the Loadup utility.
         */
        public function getResourceViaLoadupProxyName( proxyName :String ) :LoadupResourceProxy {
            return this.resourceList.getResourceViaLoadupProxyName( proxyName );
        }

		/**
		 *    Only relevant if keepResourceListOpen() is relevant; purpose is to make the reporting
		 *    of loading progress more valid. 
		 */
		public function set expectedNumberOfResources( num :int ) :void {
		    resourceList.expectedNumberOfResources = num;
		}

        /**
         *  Is the monitor active, meaning is it engaged in loading resources or has it finished this
         *  try.
         */
        public function isActive() :Boolean {
            return loadingActive;
        }

		/**
         * Start to load all resources. Expect to be called just once.
         *  Guard against unexpected usage:
         *  e.g. empty resourceList, e.g. infeasible 'requires' specification. 
         */
		public function loadResources() :void {
		    if (loadingActive)
		        doSendNotification( CALL_OUT_OF_SYNC_IGNORED );

            // Otherwise, commence loading, but note check for feasibility.
		    else {
		        loadingCommenced = true;
		        loadingActive = true;

                // Ensure resource list is closed against further additions, unless specifically kept open.
		        if ( resourceList.isOkToClose() ) resourceList.close();

                if ( ! isLoadResourcesFeasible() )
    	            throw new Error( INVALID_RESOURCES_MSG );

		        // Ensure that LoadupResourceProxy dependencies cannot be changed.
		        closeRequiresOnResourceProxies();

		        doLoadResources();
		    }
		}
		private function doLoadResources() :void {
			for( var i:int = 0; i < this.resourceList.length; i++) {
				var r :LoadupResourceProxy = this.resourceList.getItemAt(i) as LoadupResourceProxy;
				if ( r.isOkToLoad() ) {
					r.setStatusToLoading();
					r.startLoad();
				}
			}
		}

		private function loadResourcesAfterAddingMoreResources() :void {
		    loadResourcesAfterChangingResourceList();
		}
		private function loadResourcesAfterClosingResourceList() :void {
		    loadResourcesAfterChangingResourceList();
		}
		private function loadResourcesAfterChangingResourceList() :void {
		    if ( ! isLoadResourcesFeasible () )
		        throw new Error( INVALID_RESOURCES_MSG );
		    else {
		        loadingActive = true;  // may already be true
		        closeRequiresOnResourceProxies();
		        doLoadResources();
		    }
		}

		/**
         * The resource is loaded, update the state and check if the loading process is complete.
		 * 
         * @param proxyNname App resource proxy name for the loaded resource.
         *  @throws Error when the given proxy name is not recognised by this LoadupMonitorProxy.
         */
		public function resourceLoaded( proxyName :String ):void {
		    var r :LoadupResourceProxy = resolveAppProxyNameElseError( proxyName );
		    if ( ! loadingActive) {
	            doSendNotification( CALL_OUT_OF_SYNC_IGNORED, proxyName );
		    }
		    else
		        doResourceLoaded( r );
	    }
		private function doResourceLoaded( r :LoadupResourceProxy ):void {

            // Ignore unless this is a valid transition, for example, ignore if 
            // an unexpected 'loaded' from the client app after we have timed out.
            if ( r.isOkToSetLoaded() ) {
    			r.setStatusToLoaded();
    			loadedResources.push( r );

    			// Send a notification specifying percent loaded.
    			sendProgressNotification();

                // Are all resources loaded?
    			if ( allResourcesLoaded() ) {
    			    if ( resourceList.isClosed() )
    			        finishThisTry( LOADING_COMPLETE );
    			    else
    			        finishThisTry( waitingForMoreResourcesNotificationName );
    			}
                // Else are we finished, though all not loaded?
                else if ( isLoadingFinished() ) {
    			    finishThisTry( LOADING_FINISHED_INCOMPLETE );                
                }
                // Otherwise, keep loading.
                else
    				this.doLoadResources();
    		}
		}
		private function resolveAppProxyNameElseError( appProxyName :String ) :LoadupResourceProxy {
		    var r :LoadupResourceProxy = findLRProxyByAppProxyName( appProxyName );
		    if (r == null ) 
		        throw new Error( appProxyName + UNKNOWN_ILOADUP_PROXY_MSG + getProxyName() );
		    return r;
		}

        /**
         *  Sends the Loading Progress notification, with percent loaded, for client app to observe.
         *  Used internally by the Loadup utility, but can be invoked by a client app if desired, for
         *  example to cause more frequent notifications because there is a custom calculation of progress
         *  percentage.
         */
		public function sendProgressNotification() :void {
			doSendNotification( LOADING_PROGRESS, resourceList.progressPercentage );
		}

		/**
         * The resource load has failed, update the state, retry the load if possible,
         *  otherwise check are we finished with this try to load resources.
		 * 
         * @param proxyNname App resource proxy name for the failed load.
         * @param allowRetry False means the client app says 'do not retry'.
         *  @throws Error when the given proxy name is not recognised by this LoadupMonitorProxy.
         */
		public function resourceFailed( proxyName :String, allowRetry :Boolean =true ):void {
		    var r :LoadupResourceProxy = resolveAppProxyNameElseError( proxyName );
 		    if ( ! loadingActive)
 		        doSendNotification( CALL_OUT_OF_SYNC_IGNORED, proxyName );
 		    else
	            doResourceFailed( r, allowRetry );
 	    }
		private function doResourceFailed( r :LoadupResourceProxy, allowRetry :Boolean ):void {

            // Ignore unless this is a valid transition, for example, ignore if
            // an unexpected 'failed' from the client app after we have timed out.
            if ( r.isOkToSetFailed() ) {
    			r.setStatusToFailed();
    			if ( allowRetry && r.isOkToRetry() ) {
    			    r.setStatusToLoading();
    			    r.startRetry();
        			// Notify the client app
        		    doSendNotification( LoadupMonitorProxy.RETRYING_LOAD_RESOURCE, r.appResourceProxyName() );
    			}
    			else {
        			failedResourcesThisTry.push( r );
                    // Are we finished, though not all loaded?  If so, notify the client app.
                    if ( isLoadingFinished() ) {
                        finishThisTry( LOADING_FINISHED_INCOMPLETE );                
                    }
    			}
    		}
		}

		/**
         * Loading of the resource has timed out, update the state and
         *  check if the loading process is complete.
         */
		internal function resourceHasBeenTimedOut( r :LoadupResourceProxy ):void {
			// Notify the client app
		    doSendNotification( LoadupMonitorProxy.LOAD_RESOURCE_TIMED_OUT, r.appResourceProxyName() );

			failedResourcesThisTry.push( r );

            // Are we finished, though not all loaded?  If so, notify the client app.
            if ( isLoadingFinished() ) {
			    finishThisTry( LOADING_FINISHED_INCOMPLETE );                
            }
		}

		/**
         *  Try to complete the loading of outstanding resources
         */
		public function tryToCompleteLoadResources():void {
 		    if (loadingActive)
 		        doSendNotification( CALL_OUT_OF_SYNC_IGNORED );
 		    else {
 		        loadingActive = true;
 		        doTryToCompleteLoadResources();
 		    }
 		}
		private function doTryToCompleteLoadResources():void {
		    //tryAgainCount++;
		    _failedResourcesThisTry = new Array();
		    resetResourceProxies();
		    doLoadResources();
		}

        /**
         *  Is it ok to reset this monitor?
         *  Yes, if the monitor is not currently active; by active we mean that loading has started and the 
         *  monitor has not yet reached a LOADING_COMPLETE or LOADING_FINISHED_INCOMPLETE state.
         */
        public function isOkToReset() :Boolean {
            return !loadingActive;
        }
        /**
         *  Reset the state of the monitor, so that it is ready for reuse.  This includes the cleanup 
         *  operation, that is, removal of the previous LoadupResourceProxy objects from the map of 
         *  registered proxies.
         *  <p>
         *  It is recommended that the client app check via isOkToReset() before invoking reset().</p>
         *  <p>
         *  Note that an alternative to reset is to instantiate a new LoadupMonitorProxy.</p>
         *  
         *  @throws Error if reset is not allowed.
         */
        public function reset() :void {
            if ( isOkToReset() ) {
                removeResourceProxies();
                initializeMonitor();
            }
            else
    		    throw new Error( INVALID_RESET_MSG );
        }
        /**
         *  This cleanup feature deals with removal of object state that is closely bound with this loadup 
         *  monitor instance. It is recommended that the client app invoke this or an equivalent, before 
         *  removing the monitor instance. The reset() operation includes this cleanup and is a valid 
         *  alternative.
         *  <p>
         *  Specifically, cleanup includes
         *  <ul>
         *  <li>removal of the LoadupResourceProxy objects from the map of registered proxies.</li>
         *  </ul></p>
         */
        public function cleanup() :void {
            if ( ! loadingActive )
                removeResourceProxies();
        }
        protected function removeResourceProxies() :void {
			for( var i:int = 0; i < this.resourceList.length; i++) {
				var r :LoadupResourceProxy = this.resourceList.getItemAt(i) as LoadupResourceProxy;
			    facade.removeProxy( r.getProxyName() );
			}
        }

		/**
         * Check have all the listed resources been loaded.
         */
		public function allResourcesLoaded():Boolean {
		    return (loadedResources.length >= resourceList.length);
		}

		/**
         *  Check if the loading process is finished.
         *  For each resource that has not yet been processed, 
         *  check whether it could be loaded.  If none can be
         *  loaded, then we are finished.
         *  <p>
         *  Also, for finished, an essential condition is that the resourceList is closed.</p>
         */
    	protected function isLoadingFinished():Boolean {
    	    if ( ! resourceList.isClosed() )
    	        return false;

			for( var i:int = 0; i < this.resourceList.length; i++) {
				var r :LoadupResourceProxy = this.resourceList.getItemAt(i) as LoadupResourceProxy;
				// Ignore resources already processed
				if ( loadedResources.indexOf( r ) >= 0 )
				    continue;
				if ( failedResourcesThisTry.indexOf( r ) >= 0 )
				    continue;
				if (r.isLoading() || r.isOkToLoad() )
				    return false;
			}
			return true;
		}

		/**
         *  For each resource that has not yet been processed, 
         *  check is there at least one that could be loaded.  The r.isOkToLoad test should reveal
         *  cases like circular linkages across the requires property of the LRP objects and a 
         *  requires property that contains an LRP object that has not been added as a resource.
         */
    	protected function isAnyRemainingResourceLoadable():Boolean {
			for( var i:int = 0; i < this.resourceList.length; i++) {
				var r :LoadupResourceProxy = this.resourceList.getItemAt(i) as LoadupResourceProxy;
				// Ignore resources already processed
				if ( loadedResources.indexOf( r ) >= 0 )
				    continue;
				if ( failedResourcesThisTry.indexOf( r ) >= 0 )
				    continue;
				if (r.isLoading() || r.isOkToLoad() )
				    return true;
			}
			return false;
		}

        /**
         *  Find the LoadupResourceProxy object, in the resourceList, that refers to the
         *  app resource proxy of the given name.
         */
	    protected function findLRProxyByAppProxyName( appProxyName :String ) :LoadupResourceProxy {
			for( var i:int = 0; i < this.resourceList.length; i++) {
				var r:LoadupResourceProxy = this.resourceList.getItemAt(i) as LoadupResourceProxy;
				if ( r.appResourceProxyName() == appProxyName )
				    return r;
			}
	        return null;
	    }

        /**
         *  Load resources is feasible unless there something illogical about the set of 
         *  resources.
         */
        protected function isLoadResourcesFeasible() :Boolean {
            if ( resourceList.length == 0 && resourceList.isToBeKeptOpen() ) return true;
            if ( resourceList.length == 0 ) return false;
            if (  ! isAnyRemainingResourceLoadable() ) return false;
            return true;
        }

        /**
         *  Notification type is this LoadupMonitorProxy's proxyName.
         */
        protected function doSendNotification( notificationName :String, body :Object=null ) :void {
            sendNotification( notificationName, body, getProxyName() );
        }

		private function finishThisTry( noteName :String ) :void {
            loadingActive = false;
		    doSendNotification( noteName );                		    
		}

        private function closeRequiresOnResourceProxies() :void {
			for( var i:int = 0; i < this.resourceList.length; i++) {
				var r :LoadupResourceProxy = this.resourceList.getItemAt(i) as LoadupResourceProxy;
				// may already be closed, but so what!
				r.closeRequires();
			}
        }

        private function resetResourceProxies() :void {
			for( var i:int = 0; i < this.resourceList.length; i++) {
				var r :LoadupResourceProxy = this.resourceList.getItemAt(i) as LoadupResourceProxy;
				// Ignore resources already processed
				if ( loadedResources.indexOf( r ) >= 0 )
				    continue;
				if ( r.isOkToReset() )
				    r.reset();
			}
        }

	}
}
