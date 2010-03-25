/*
	PureMVC Utility - Loadup - Manage loading of resources
	Copyright (c) 2008-, collaborative, as follows
	2008 Philip Sexton <philip.sexton@puremvc.org>
	Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package org.puremvc.as3.utilities.loadup.controller
{
    /**
     *  FailureInfo can be used as the Notification body when a resource load fails.
     *  See InvoiceProxy class in LoadupAsOrdered demo for an example use of this class.
     */
	public class FailureInfo {

        private var _proxyName :String;
        private var _allowRetry :Boolean;

		public function FailureInfo( proxyName :String, allowRetry :Boolean =true ) {
		    this._proxyName = proxyName;
		    this._allowRetry = allowRetry;
		}
		public function get proxyName() :String { return _proxyName; }
		public function get allowRetry() :Boolean { return _allowRetry; }
	}
}
