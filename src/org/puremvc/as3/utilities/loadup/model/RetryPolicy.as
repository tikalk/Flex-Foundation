/*
	PureMVC Utility - Loadup - Manage loading of resources
	Copyright (c) 2008-, collaborative, as follows
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
    import org.puremvc.as3.utilities.loadup.interfaces.IRetryParameters;

	/**
	*  See the <code>LoadupMonitorProxy</code> class for the primary documentation on the
	*  Loadup utility.
	*  Within the utility, it is the <code>LoadupResourceProxy</code>class that interacts with 
	*  <code>RetryPolicy</code>.
	*  See the demo app called LoadupAsOrdered as an example of
	*  how <code>RetryPolicy</code> can be used.  In particular, see LoadResourcesCommand in
	*  that app.
	*  <p>
	*  This RetryPolicy is the standard implementation of a Retry Policy for the Loadup utility.
	*  It implements the IRetryPolicy interface.  A client app could implement this interface differently 
	*  and hence have a different retry policy when using the Loadup utility.  Each loadup resource
	*  must reference an instance of IRetryPolicy.  It uses this policy to manage retries of failed loads
	*  and to manage timeout on loading.</p>
	*  <p>
	*  This standard Retry Policy is as follows
	*  <ul><li>
	*  takes configuration parameters: maxRetries, retryInterval (secs), timeout (secs), expBackoff (true/false)</li>
	*  <li>these parameters are supplied via an IRetryParameters object</li>
	*  <li>when maxRetries is non-zero, on failure to load a resource, the utility will automatically retry
	*  to load it, but will only retry 'maxRetries' times</li>
	*  <li>the start of each retry will be delayed 'retryInterval' seconds</li>
	*  <li>a timeout of zero means timeout is not applicable</li>
	*  <li>timeout is the limit on load time; when it is exceeded, the load of the resource is abandoned, 
	*  it has 'timed out'; load time means the cumulative time of load and retries</li>
	*  <li>the elapsed time for loads and retry loads, for comparison with the timeout figure, is accumulated
	*  as follows: it is the sum of the time for the first load attempt and the times for each retry attempt; the
	*  retryInterval is not included</li>
	*  <li>expBackoff, meaning Exponential Backoff, can be requested; if requested, then the retry
	*  interval is increased by a factor with each use; currently this factor is 2</li>
	*  </ul></p>
	*/
	public class RetryPolicy implements IRetryPolicy {

        protected var retryParameters :IRetryParameters;
        protected var failedCount :int =0;
        protected var failedTimeAccumulated :Number =0; //secs
        protected var timedOut :Boolean =false;

        /**
         *  Two properties, lastRetryInterval and expBackoffFactor1, are used to support the 
         *  exponential backoff operation.
         */
        protected var lastRetryInterval :Number =0;
        public var expBackoffFactor1 :int = 2;

		public function RetryPolicy( retryParameters :IRetryParameters ) {
		    this.retryParameters = retryParameters;
		}
		public function get maxRetries() :int { return retryParameters.maxRetries; }

		public function get retryInterval() :Number { return retryParameters.retryInterval; }

        public function get timeout() :Number { return retryParameters.timeout; }

        public function get expBackoff() :Boolean { return retryParameters.expBackoff; }

        /**
         *  @see org.puremvc.as3.utilities.loadup.interfaces.IRetryPolicy#copy() IRetryPolicy#copy()
         */
        public function copy() :IRetryPolicy {
            return new RetryPolicy( retryParameters );
        }

        /**
         *  Reset this policy as regards the configuration parameters and the state variables
         *  that have tracked activity to-date.  Should only be done when users of the policy
         *  have finished with the current state.
         *  @see org.puremvc.as3.utilities.loadup.interfaces.IRetryPolicy#reConfigure() IRetryPolicy#reConfigure()
         */
        public function reConfigure( retryParameters :IRetryParameters ) :void {
            this.retryParameters = retryParameters;
            reset();
        }

        /**
         *  Updates internal state.
         *  Includes setting to a timedOut state if that is
         *  an outcome, though would normally expect the timedOut state to
         *  be recognised and set by another object e.g. LoadupResourceProxy.
         *  @param timeToFailure Time elapsed from start of operation until failure; unit is msecs.
         */
        public function addFailure( timeToFailure :Number ) :void {
            failedCount++;
            failedTimeAccumulated += (timeToFailure / 1000);
            if ( isTimeoutApplicable() && failedTimeAccumulated >= timeout )
                setToTimedOut();
        }
        public function isOkToRetry() :Boolean {
            return !timedOut && failedCount > 0 && ( failedCount <= maxRetries );
        }

        /**
         *  @see org.puremvc.as3.utilities.loadup.interfaces.IRetryPolicy#reset() IRetryPolicy#reset()
         */
        public function reset() :void {
            failedCount = 0;
            failedTimeAccumulated = 0;
            timedOut = false;
            lastRetryInterval = 0;
        }

        public function isTimeoutApplicable() :Boolean {
            return retryParameters.timeout > 0;
        }

        /**
         *  @see org.puremvc.as3.utilities.loadup.interfaces.IRetryPolicy#getTimeoutTimer() IRetryPolicy#getTimeoutTimer()
         */
        public function getTimeoutTimer() :Timer {
            if ( !isTimeoutApplicable() || timedOut )
                return null;
		    return new Timer( ( timeout - failedTimeAccumulated ) *1000, 1 );
        }

        public function setToTimedOut() :void {
            timedOut = true;
        }
        public function isTimedOut() :Boolean { return timedOut; }

        /**
         *  @see org.puremvc.as3.utilities.loadup.interfaces.IRetryPolicy#getRetryTimer() IRetryPolicy#getRetryTimer()
         */
        public function getRetryTimer() :Timer {
            if ( retryInterval > 0 ) {
                var rti :Number = ( expBackoff ? getNextRetryInterval() : retryInterval );
		        return new Timer( rti *1000, 1 );
            }
		    else
		        return null;
        }

        protected function getNextRetryInterval() :Number {
            if ( lastRetryInterval == 0 )
                return ( lastRetryInterval = retryInterval );
            else
                // future: consider random factor within a fixed range
                return ( lastRetryInterval = lastRetryInterval * expBackoffFactor1 );
        }

        public function getFailedCount() :int { return failedCount; }

        public function getFailedTimeAccumulated() :Number { return failedTimeAccumulated; }

        public function getLastRetryInterval() :Number { return lastRetryInterval; }

        public function getRetryParameters() :IRetryParameters { return retryParameters; }
	}

}
