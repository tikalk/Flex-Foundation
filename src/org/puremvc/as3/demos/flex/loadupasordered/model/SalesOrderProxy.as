/*
	PureMVC Flex Demo - Use Loadup Utility - Manage loading of data resources
	Copyright (c) 2008 Philip Sexton <philip.sexton@puremvc.org>
	Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package org.puremvc.as3.demos.flex.loadupasordered.model
{
	import org.puremvc.as3.demos.flex.loadupasordered.ApplicationFacade;
	import org.puremvc.as3.utilities.asyncstub.model.AsyncStubProxy;
	import com.tikalk.flex.foundation.interfaces.IFoundationLoadupProxy;
    
	public class SalesOrderProxy extends EntityProxy implements IFoundationLoadupProxy
	{
		public static const NAME:String = 'SalesOrderProxy';
		public static const SRNAME:String = 'SalesOrderSRProxy';

        private var loadCount :int = 0;

		public function SalesOrderProxy( ) {
			super( NAME );
		}
		
		public function getSRName():String
		{
			return SRNAME;
		}		


        /**
         *  Use AsyncStubProxy to simulate an async load.
         *  Given that load() may be called more than once, because of retries,
         *  possibly after timeout,
         *  we discard any results that are not for the latest call, by use
         *  of the token property of the async stub.
         */
        public function load() :void {
            loadCount++;
            sendNotification( ApplicationFacade.SALES_ORDER_LOADING );
            var stub :AsyncStubProxy = new AsyncStubProxy();
            stub.token = loadCount;
            stub.asyncAction( loaded, failed );
        }

        protected function loaded( asToken :Object =null ) :void {
            if ( ( asToken == null ) || ( (asToken as int) == loadCount ) )
                sendLoadedNotification( ApplicationFacade.SALES_ORDER_LOADED, NAME, SRNAME);
        }

        protected function failed( asToken :Object =null ) :void {
            if ( ( asToken == null ) || ( (asToken as int) == loadCount ) )
                sendLoadedNotification( ApplicationFacade.SALES_ORDER_FAILED, NAME, SRNAME);
        }

	}
}