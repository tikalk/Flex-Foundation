/*
	PureMVC Utility - Loadup - Manage loading of resources
	Copyright (c) 2008-09 Philip Sexton <philip.sexton@puremvc.org>
	Your reuse is governed by the Creative Commons Attribution 3.0 License
*/

package org.puremvc.as3.utilities.loadup.interfaces
{

    /**
     *  The retry parameters used by a retry policy must implement this interface.
     */
	public interface IRetryParameters {

        function get maxRetries() :int;

        function get retryInterval() :Number;

        function get timeout() :Number;

        function get expBackoff() :Boolean;

	}
}
