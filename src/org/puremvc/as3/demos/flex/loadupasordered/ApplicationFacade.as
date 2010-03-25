/*
	PureMVC Flex Demo - Use Loadup Utility - Manage loading of data resources
	Copyright (c) 2008 Philip Sexton <philip.sexton@puremvc.org>
	Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package org.puremvc.as3.demos.flex.loadupasordered {
	import org.puremvc.as3.interfaces.IFacade;
	import org.puremvc.as3.patterns.facade.Facade;
	import org.puremvc.as3.patterns.observer.Notification;

    import org.puremvc.as3.demos.flex.loadupasordered.controller.StartupCommand;
    import org.puremvc.as3.demos.flex.loadupasordered.controller.LoadResourcesCommand;
    import org.puremvc.as3.demos.flex.loadupasordered.controller.TryToCompleteLoadResourcesCommand;

    import org.puremvc.as3.utilities.loadup.controller.LoadupResourceLoadedCommand;
    import org.puremvc.as3.utilities.loadup.controller.LoadupResourceFailedCommand;
    import com.tikalk.flex.foundation.patterns.facade.FoundationFacade;

	public class ApplicationFacade extends FoundationFacade implements IFacade
	{
		// Notification name constants
		public static const STARTUP:String = "startup";

        public static const TRY_TO_COMPLETE_LOAD_RESOURCES :String = "tryToCompleteLoadResources";
        public static const LOAD_RESOURCES :String = "loadResources";

		public static const CUSTOMER_LOADING:String = "customerLoading";
		public static const CUSTOMER_LOADED:String = "customerLoaded";
		public static const CUSTOMER_FAILED:String = "customerFailed";
		public static const PRODUCT_LOADING:String = "productLoading";
		public static const PRODUCT_LOADED:String = "productLoaded";
		public static const PRODUCT_FAILED:String = "productFailed";
		public static const SALES_ORDER_LOADING:String = "salesOrderLoading";
		public static const SALES_ORDER_LOADED:String = "salesOrderLoaded";
		public static const SALES_ORDER_FAILED:String = "salesOrderFailed";
		public static const DEBTOR_ACCOUNT_LOADING:String = "debtorAccountLoading";
		public static const DEBTOR_ACCOUNT_LOADED:String = "debtorAccountLoaded";
		public static const DEBTOR_ACCOUNT_FAILED:String = "debtorAccountFailed";
		public static const INVOICE_LOADING:String = "invoiceLoading";
		public static const INVOICE_LOADED:String = "invoiceLoaded";
		public static const INVOICE_FAILED:String = "invoiceFailed";

		/**
		 * Singleton ApplicationFacade Factory Method
		 */
		public static function getInstance() : ApplicationFacade {
			if ( instance == null ) instance = new ApplicationFacade( );
			return instance as ApplicationFacade;
		}

		/**
		 * Register Commands with the Controller 
		 */
		override protected function initializeController( ) : void {
			super.initializeController();			
			registerCommand( STARTUP, StartupCommand );
			registerCommand( LOAD_RESOURCES, LoadResourcesCommand );
			registerCommand( TRY_TO_COMPLETE_LOAD_RESOURCES, TryToCompleteLoadResourcesCommand );

			registerResourceLoadedCommand( CUSTOMER_LOADED );
			registerResourceLoadedCommand( PRODUCT_LOADED );
			registerResourceLoadedCommand( SALES_ORDER_LOADED );
			registerResourceLoadedCommand( DEBTOR_ACCOUNT_LOADED );
			registerResourceLoadedCommand( INVOICE_LOADED );

			registerResourceFailedCommand( CUSTOMER_FAILED );
			registerResourceFailedCommand( PRODUCT_FAILED );
			registerResourceFailedCommand( SALES_ORDER_FAILED );
			registerResourceFailedCommand( DEBTOR_ACCOUNT_FAILED );
			registerResourceFailedCommand( INVOICE_FAILED );
		}

        public function startup(app:Object) :void {
            sendNotification( STARTUP, app );
        }

        private function registerResourceLoadedCommand( notificationName :String ) :void {
            registerCommand( notificationName, LoadupResourceLoadedCommand );
        }
        private function registerResourceFailedCommand( notificationName :String ) :void {
            registerCommand( notificationName, LoadupResourceFailedCommand );
        }

	}
}