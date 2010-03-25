/*
	PureMVC Utility - Loadup - Manage loading of resources
	Copyright (c) 2008-, collaborative, as follows
	2008-2009 Philip Sexton <philip.sexton@puremvc.org>
	Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package org.puremvc.as3.utilities.loadup.model
{
    import org.puremvc.as3.utilities.loadup.interfaces.IRetryParameters;

	/**
	*  See this utility's <code>RetryPolicy</code> class as the consumer of <code>RetryParameters</code>.
	*  See the demo app called LoadupAsOrdered as an example of how <code>RetryParameters</code> 
	*  can be used.
	*  <p>
	*  RetryParameters is a way of encapsulating the configuration parameters required by the 
	*  RetryPolicy class.  A RetryParameters object is immutable.</p>
	*/
	public class RetryParameters implements IRetryParameters {

        protected const NEGATIVE_ARG_MSG :String = ": Negative argument, illegal";

        protected var _maxRetries :int =0;
        protected var _retryInterval :Number =0; // secs
        protected var _timeout :Number =0; //secs
        protected var _expBackoff :Boolean =false;

		public function RetryParameters( maxRetries :int =0, retryInterval :Number =0, timeout :Number =0,
		    expBackoff :Boolean =false )
		{
		    if ( maxRetries < 0 || retryInterval < 0 || timeout < 0 )
		        throw new Error( NEGATIVE_ARG_MSG );
		    this._maxRetries = maxRetries;
		    this._retryInterval = retryInterval;
		    this._timeout = timeout;
		    this._expBackoff = expBackoff;
		}

        /**
         *  Maximum number of retries to allow, zero implies retries not allowed.
         */
		public function get maxRetries() :int { return _maxRetries; }

        /**
         *  Delay before starting a retry operation, unit is seconds, use decimal places as required
         *  e.g. 2 => 2 secs, 0.5 => 500 msecs.
         */
		public function get retryInterval() :Number { return _retryInterval; }

        /**
         *  Timeout to apply to operations on a resource, unit is seconds, use decimal places as required
         *  e.g. 60 => 60 secs.
         */
        public function get timeout() :Number { return _timeout; }

        /**
         *  Controls whether to apply exponential backup logic when using the retry interval.
         */
        public function get expBackoff() :Boolean { return _expBackoff; }

	}

}
