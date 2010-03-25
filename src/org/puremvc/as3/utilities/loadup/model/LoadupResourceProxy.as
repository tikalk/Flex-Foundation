/*
	PureMVC Utility - Loadup - Manage loading of resources
	Copyright (c) 2007-2008, collaborative, as follows
	2007 Daniele Ugoletti, Joel Caballero
	2008-2009 Philip Sexton <philip.sexton@puremvc.org>
	Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package org.puremvc.as3.utilities.loadup.model
{
    import flash.utils.Timer;
    import flash.events.TimerEvent;

	import org.puremvc.as3.interfaces.IProxy;
    import org.puremvc.as3.patterns.proxy.Proxy;
    import org.puremvc.as3.utilities.loadup.interfaces.ILoadupProxy;
    import org.puremvc.as3.utilities.loadup.interfaces.IRetryPolicy;

	/**
	*  See the <code>LoadupMonitorProxy</code> class for the primary documentation on the
	*  Loadup utility.  See the demo app called LoadupAsOrdered as an example of
	*  how <code>LoadupResourceProxy</code> can be used.  In particular, see LoadResourcesCommand in
	*  that app.
	*  <p>
	*  It is assumed that the client application has a puremvc-compliant proxy object for each
	*  loadup resource, each uniquely named. Those objects must implement <code>ILoadupProxy</code>.</p>
	*  <p>
	*  In addition, the app must instantiate a <code>LoadupResourceProxy</code> object for
	*  each loadup resource, with a reference to the ILoadupProxy object being passed to 
	*  the constructor.  These <code>LoadupResourceProxy</code> objects exist only for the purposes of
	*  the utility.  How they are named is of no interest to the utility.  Each of these objects should be
	*  registered with the puremvc model i.e. facade.registerProxy; this is absolutely required when the
	*  utility is used with puremvc multicore.
	*  <p>
	*  To specify dependencies between resources, use the <code>requires</code> property.  For example,
	*  if we have 3 resources <code>r1,r2,r3</code>, and r3 requires that r1 and r2 must be loaded first,
	*  then we state <code>r3.requires = [r1, r2];</code>.</p>
	*  <p> 
	*  Assignment to the requires property is ignored if it occurs 
	*  after a certain stage in the loading process as managed by LoadupMonitorProxy (the monitor), as follows
	*  <ul><li>
	*  after invocation of the monitor's loadResources() method, for those resources already listed</li>
	*  <li>after a resource is added to the monitor's list using addResource() or addResources(), when that occurs 
	*  after invocation of loadResources().</li></ul> 
	*  </p>
	*  <p>Each resource adopts a Retry Policy, to govern retries to load resources when a load attempt fails,
	*  and to govern application of timeouts on load attempts.  The utility provides a particular RetryPolicy
	*  class that the client app can use, but the app could also implement its own in accordance with the
	*  IRetryPolicy interface.  However, regardless of retry policy, there is a built-in assumption that 
	*  automatic retries do not occur after timeout.</p>
	*  <p>
	*  Use of the <code>retryPolicy</code> property is as follows
	*  <ul><li>
	*  provides the client app with a means to set a retry policy specific to this resource</li>
	*  <li>the initial value is null; this means use the defaultRetryPolicy from LoadupMonitorProxy</li>
	*  <li>the app can set the defaultRetryPolicy property on LoadupMonitorProxy</li>
	*  <li>the app can set the retryPolicy property on each resource, but should only bother to do 
	*  so if it differs from defaultRetryPolicy</li>
	*  <li>the app can set this before invoking LoadupMonitorProxy.loadResources(), and can also set this later,
	*  in the case where loading finishes incomplete, if a change of policy is required, before invoking
	*  LoadupMonitorProxy.tryToCompleteLoadResources</li>
	*  <li>another way to effect a change of policy, where the same input parameters apply to all policy 
	*  instances, is to use the reConfigureAllRetryPolicies() method on LoadupMonitorProxy.</li>
	*  </ul></p>
	*  <p>
	*  Adapted from original code of Daniele Ugoletti in his
	*  ApplicationSkeleton_v1.3 demo, Nov 2007, posted to the puremvc forums.
	*  Also from code of Joel Caballero, Feb 2008, posted to the forums.</p>
	*  
	*/
	public class LoadupResourceProxy extends Proxy implements IProxy {

        private static const EMPTY :int = 1;
        private static const LOADING :int = 2;
        private static const TIMED_OUT :int = 3;
        private static const FAILED :int = 4;
        private static const LOADED :int = 5;

		private var status :int;

		// LoadupResourceProxys, pre-requisites for this resource, if any.
		// These pre-requisites must be loaded before this can be loaded.
		private var _requires :Array;

        private var _appResourceProxy :ILoadupProxy;

        private var _retryPolicy :IRetryPolicy;

        private var _monitor :LoadupMonitorProxy;

		private var timeoutTimer :Timer;
		private var retryTimer :Timer;
        private var loadingStartTime :Number =0;
        private var requiresAreClosed :Boolean =false;

		public function LoadupResourceProxy( proxyName :String, appResourceProxy :ILoadupProxy) {
		    super( proxyName );
		    this._appResourceProxy = appResourceProxy;
			this.status = EMPTY;
			this.requires = new Array();
		}

		public function set requires( resources :Array ) :void {
		    if ( ! requiresAreClosed )
		        _requires = resources;
		}
		public function get requires() :Array {
		    return _requires;
		}

        /**
         *  Can only be set when the LoadupMonitorProxy is not engaged in loading; for example, 
         *  before loading commences or after loading is "finished incomplete".
         */
		public function set retryPolicy( rp :IRetryPolicy ) :void {
		    if ( monitorIsNotActive() )
		        _retryPolicy = rp;
		}
		public function get retryPolicy() :IRetryPolicy {
		    // lazy instantiation, when setting from defaultRetryPolicy.
		    if ( _retryPolicy == null ) {
		        _retryPolicy = monitor.defaultRetryPolicy.copy();
		    }
		    return _retryPolicy;
		}

        /**
         *  For a LoadupResourceProxy object, the monitor property is set by the addResource or the addResources
         *  method of the IResourceList implementation, when the LoadupResourceProxy is added to the resource
         *  list for this LoadupMonitorProxy instance.   
         */
        public function set monitor( m :LoadupMonitorProxy ) :void {
		    _monitor = m;
        }
        public function get monitor() :LoadupMonitorProxy {
		    return _monitor;
        }

		public function get appResourceProxy() :ILoadupProxy {
		    return _appResourceProxy;
		}

		public function appResourceProxyName() :String {
		    return _appResourceProxy.getProxyName();
		}

		public function isLoading() :Boolean {
		    return status == LOADING;
		}
		public function isTimedOut() :Boolean {
		    return status == TIMED_OUT;
		}
		public function isFailed() :Boolean {
		    return status == FAILED;
		}
		public function isLoaded() :Boolean {
		    return status == LOADED;
		}

        internal function closeRequires() :void {
            requiresAreClosed = true;
        }
		internal function setStatusToLoading() :void {
		    status = LOADING;
		}
		internal function setStatusToTimedOut() :void {
		    status = TIMED_OUT;
		    resetTimeoutTimer();
	        retryPolicy.setToTimedOut();
		}
		internal function setStatusToFailed() :void {
		    status = FAILED;
		    resetTimeoutTimer();
		    // addFailure arg is: timeToFailure = timeNow - loadingStartTime;
		    retryPolicy.addFailure( new Date().time - loadingStartTime );
		}
		internal function setStatusToLoaded() :void {
		    status = LOADED;
		    resetTimeoutTimer();
		}

		internal function isOkToLoad() :Boolean {
		    if ( status != EMPTY )
		        return false;
		    for( var i:int =0; i < requires.length; i++) {
		        if ( ! (requires[i] as LoadupResourceProxy).isLoaded() )
		            return false;
		    }
		    return true;
		}
		internal function isOkToSetLoaded() :Boolean {
		    return status == LOADING;
		}
		internal function isOkToSetFailed() :Boolean {
		    return status == LOADING;
		}

		internal function isOkToRetry() :Boolean {
		    if ( status != FAILED )
		        return false;
		    return retryPolicy.isOkToRetry();
		}
		internal function startLoad() :void {
		    if ( retryPolicy.isTimeoutApplicable() ) {
    		    timeoutTimer = retryPolicy.getTimeoutTimer();
    		    if ( timeoutTimer )
		            startTimeoutTimer();
		    }
		    loadingStartTime = new Date().time; // now
		    appResourceProxy.load();
		}
		internal function startRetry() :void {
		    retryTimer = retryPolicy.getRetryTimer();
		    if ( retryTimer )
		        startRetryTimer();
		    else
		        // no delay with this retry, proceed immediately to retry the load
		        startLoad();
		}

		internal function isOkToReset() :Boolean {
		    return !( status == LOADING || status == LOADED )
		}
		internal function reset() :void {
		    status = EMPTY;
		    retryPolicy.reset();
		}

		private function startTimeoutTimer() :void {
		    timeoutTimer.addEventListener( TimerEvent.TIMER, timedOut );		        
		    timeoutTimer.start();
		}
		private function resetTimeoutTimer() :void {
		    if ( timeoutTimer != null )
		        timeoutTimer.reset();
		}
		private function timedOut( e :TimerEvent ) :void {
	        setStatusToTimedOut();
		    monitor.resourceHasBeenTimedOut( this );
		}

		private function startRetryTimer() :void {
		    retryTimer.addEventListener( TimerEvent.TIMER, startLoadOnTimerEvent );		        
		    retryTimer.start();
		}
		private function resetRetryTimer() :void {
		    if ( retryTimer != null )
		        retryTimer.reset();
		}
		private function startLoadOnTimerEvent( e :TimerEvent ) :void {
		    resetRetryTimer();
	        startLoad();
		}

        private function monitorIsNotActive() :Boolean {
            return !( monitor && monitor.isActive() );
        }

        /**
         *  Public getter, to facilitate testing.
         */
        public function getLoadingStartTime() :Number { return loadingStartTime; }
	}

}
