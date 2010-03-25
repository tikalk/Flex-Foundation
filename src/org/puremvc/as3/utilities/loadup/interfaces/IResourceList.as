/*
	PureMVC Utility - Loadup - Manage loading of resources
	Copyright (c) 2008-, collaborative, as follows
	2008-2009 Philip Sexton <philip.sexton@puremvc.org>
	Your reuse is governed by the Creative Commons Attribution 3.0 License
*/

package org.puremvc.as3.utilities.loadup.interfaces
{
    import org.puremvc.as3.utilities.loadup.model.LoadupResourceProxy;
    import org.puremvc.as3.utilities.loadup.model.LoadupMonitorProxy;

    /**
     *  The data property of LoadupMonitorProxy.
     */
	public interface IResourceList {

		function addResource( r :LoadupResourceProxy, m :LoadupMonitorProxy ) :void;

		function addResources( rs :Array, m :LoadupMonitorProxy ) :void;

		function get length() :int;

		function getItemAt( i :int ) :Object;

		function contains( r :Object ) :Boolean;

		function isOkToClose() :Boolean;

		function close() :void;

		function forceClose() :void;

		function keepOpen() :void;

		function isOpen() :Boolean;

		function isClosed() :Boolean;

		function isToBeKeptOpen() :Boolean;

		function set expectedNumberOfResources( num :int ) :void;

		function get expectedNumberOfResources() :int;

        function get progressPercentage() :Number;

        function initialize() :void;

        function copy() :IResourceList;

        function getResourceViaLoadupProxyName( proxyName :String ) :LoadupResourceProxy;

		function getResources() :Array;

	}
}
