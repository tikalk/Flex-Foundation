/*
	PureMVC Utility - Loadup - Manage loading of resources
	Copyright (c) 2008-, collaborative, as follows
	2008-2009 Philip Sexton <philip.sexton@puremvc.org>
	Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package org.puremvc.as3.utilities.loadup.model
{
    import org.puremvc.as3.utilities.loadup.interfaces.IResourceList;

	/**
	*  This class holds the list of resources that LoadupMonitorProxy manages as its data property.
	*  The list starts as open, so that resources can be added.  At some point it is closed, so that 
	*  no further resources can be added.
	*  
	*  The 'resources' are assumed to be LoadupResourceProxy objects.
	*/
	public class ResourceList implements IResourceList {

        private static const OPEN :int = 1;
        private static const CLOSED :int = 2;

        protected var _resources :Array = new Array();
        protected var _status :int = OPEN;
        protected var _toBeKeptOpen :Boolean = false;
        protected var _expectedNumberOfResources :int = 0;

		public function ResourceList() {
		    initializeResourceList();
		}

		public function addResource( r :LoadupResourceProxy, m :LoadupMonitorProxy ) :void {
		    if ( _status == OPEN) {
		        _resources.push(r);
		        r.monitor = m;
		    }
		}
		public function addResources( rs :Array, m :LoadupMonitorProxy ) :void {
		    var r :LoadupResourceProxy;
		    if ( _status == OPEN) {
    			for( var i:int = 0; i < rs.length; i++) {
    			    r = rs[i];
    			    _resources.push( r );
    			    r.monitor = m;
    			}
		    }
		}
		public function get length() :int {
		    return _resources.length;
		}
		public function getItemAt( i :int ) :Object {
		    return _resources[i];
		}
		public function contains( r :Object ) :Boolean {
		    return _resources.indexOf( r ) >= 0
		}

		public function isOkToClose() :Boolean {
		    return _toBeKeptOpen ? false : true;
		}
		public function close() :void {
		    if ( isOkToClose () )
		        _status = CLOSED;
		}
		public function forceClose() :void {
		    _status = CLOSED;
		    _toBeKeptOpen = false;
		}

		public function keepOpen() :void {
		    if ( _status == OPEN )
		        _toBeKeptOpen = true;
		}
		public function isOpen() :Boolean {
		    return _status == OPEN;
		}
		public function isClosed() :Boolean {
		    return _status == CLOSED;
		}
		public function isToBeKeptOpen() :Boolean {
		    return _toBeKeptOpen;
		}

		public function set expectedNumberOfResources( num :int ) :void {
	        _expectedNumberOfResources = num;
		}
		public function get expectedNumberOfResources() :int {
		    if ( isOpen() && _expectedNumberOfResources > _resources.length )
		        return _expectedNumberOfResources;
		    else
		        return _resources.length;
		}

        /**
         *  Override this method if a different calculation is required.
         */
        public function get progressPercentage() :Number {
            if ( expectedNumberOfResources > 0 )
                return ( numberOfLoadedResources() * 100 ) / expectedNumberOfResources;
            else
                return 0;
        }

        public function initialize() :void {
            initializeResourceList();
        }

        public function copy() :IResourceList {
            var rl :ResourceList = new ResourceList();
            rl._resources = this._resources.concat();
            rl._status = this._status;
            rl._toBeKeptOpen = this._toBeKeptOpen;
            rl._expectedNumberOfResources = this._expectedNumberOfResources;
            return rl;
        }

        /**
         *  In this resource list, find the LoadupResourceProxy object, where the corresponding
         *  ILoadupProxy object has the given name.  Return null if not found.
         */
        public function getResourceViaLoadupProxyName( proxyName :String ) :LoadupResourceProxy {
			for( var i:int = 0; i < _resources.length; i++) {
			    if ( ( _resources[i] as LoadupResourceProxy ).appResourceProxyName() == proxyName )
			        return _resources[i] as LoadupResourceProxy;
			}
            return null;
        }

        /**
         *  The resources array of this IResourceList; an array of LoadupResourceProxy objects.
         *  This is safe, read-only access; as regards the array.
         */
		public function getResources() :Array {
		    return _resources.concat();
		}

        protected function initializeResourceList() :void {
            _resources.length = 0;
            _status = OPEN;
            _toBeKeptOpen = false;
            _expectedNumberOfResources = 0;
        }

        protected function numberOfLoadedResources() :int {
            var count :int = 0;
			for( var i:int = 0; i < _resources.length; i++) {
			    if ( ( _resources[i] as LoadupResourceProxy ).isLoaded())
			        count++;
			}
            return count;
        }

	}

}
