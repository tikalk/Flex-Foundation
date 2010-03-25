/*
	PureMVC Flex Demo - Use Loadup Utility - Manage loading of data resources
	Copyright (c) 2008 Philip Sexton <philip.sexton@puremvc.org>
	Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package org.puremvc.as3.demos.flex.loadupasordered.model
{
	import org.puremvc.as3.interfaces.IProxy;
	import com.tikalk.flex.foundation.patterns.proxy.FoundationProxy;
	import org.puremvc.as3.utilities.loadup.model.LoadupResourceProxy;
    
    /**
    *   An abstract class, to facilitate the actual resource proxies.
    */
	public class EntityProxy extends FoundationProxy implements IProxy
	{
		public function EntityProxy( name :String ) {
			super( name );
		}

        /**
         *  Resource has been loaded.  We send a loaded notification.
         *  However, to keep the presentation clean within the demo, that is,
         *  to keep in sync with the Loadup utility (LU) and avoid an incorrect
         *  'loaded' notification on our display screen, only send the
         *  notification if LU has not timed out this resource.
         *  This is a matter for the demo; LU knows to ignore any such
         *  loaded notifications.
         */
        protected function sendLoadedNotification( noteName :String, noteBody :Object, srName :String ) :void {
            var srProxy :LoadupResourceProxy = facade.retrieveProxy( srName ) as LoadupResourceProxy;
            if ( ! srProxy.isTimedOut() )
                sendNotification( noteName, noteBody );
        }

        

	}
}