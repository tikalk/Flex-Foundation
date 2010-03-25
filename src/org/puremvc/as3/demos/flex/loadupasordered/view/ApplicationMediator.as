/*
	PureMVC Flex Demo - Use Loadup Utility - Manage loading of data resources
	Copyright (c) 2008 Philip Sexton <philip.sexton@puremvc.org>
	Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package org.puremvc.as3.demos.flex.loadupasordered.view {
	import flash.events.Event;
    import mx.collections.ListCollectionView;
    import mx.collections.ArrayCollection;

	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	import org.puremvc.as3.patterns.observer.Notification;

	import org.puremvc.as3.utilities.loadup.model.LoadupMonitorProxy;
	import org.puremvc.as3.utilities.loadup.controller.FailureInfo;

	import org.puremvc.as3.demos.flex.loadupasordered.ApplicationFacade;

	public class ApplicationMediator extends Mediator implements IMediator
	{
		public static const NAME:String = 'ApplicationMediator';

        private static const LOADING :String = "Loading...";
        private static const LOADED :String = "Loaded";

        private var notificationsReceived :ListCollectionView = new ArrayCollection();
        private var monitor :LoadupMonitorProxy;

		public function ApplicationMediator( viewComponent:Object ) {
			super( NAME, viewComponent );
			app.notifications = notificationsReceived;
			app.addEventListener( LoadupAsOrdered.LOAD, onLoad );
			app.addEventListener( LoadupAsOrdered.TRY_TO_COMPLETE, onTryToComplete );

			monitor = facade.retrieveProxy( LoadupMonitorProxy.NAME ) as LoadupMonitorProxy;
		}
		
		protected function get app() :LoadupAsOrdered {
			return viewComponent as LoadupAsOrdered;
		}

        private function onLoad( event:Event ) :void {
            app.paramsEntryIsEnabled = false;
            app.overallStatus = "Load in progress...";
            sendNotification( ApplicationFacade.LOAD_RESOURCES, app.retryParameters);
        }
        private function onTryToComplete( event:Event ) :void {
            app.paramsEntryIsEnabled = false;
            app.overallStatus = "Trying to complete load...";
            sendNotification( ApplicationFacade.TRY_TO_COMPLETE_LOAD_RESOURCES, app.retryParameters);
        }

		override public function listNotificationInterests():Array {
			return [
			    LoadupMonitorProxy.LOADING_PROGRESS,
                LoadupMonitorProxy.RETRYING_LOAD_RESOURCE,
			    LoadupMonitorProxy.LOAD_RESOURCE_TIMED_OUT,
			    LoadupMonitorProxy.LOADING_COMPLETE,
			    LoadupMonitorProxy.LOADING_FINISHED_INCOMPLETE,
			    LoadupMonitorProxy.CALL_OUT_OF_SYNC_IGNORED,
			    LoadupMonitorProxy.WAITING_FOR_MORE_RESOURCES,
				ApplicationFacade.CUSTOMER_LOADING,
				ApplicationFacade.CUSTOMER_LOADED,
				ApplicationFacade.CUSTOMER_FAILED,
				ApplicationFacade.PRODUCT_LOADING,
				ApplicationFacade.PRODUCT_LOADED,
				ApplicationFacade.PRODUCT_FAILED,
				ApplicationFacade.SALES_ORDER_LOADING,
				ApplicationFacade.SALES_ORDER_LOADED,
				ApplicationFacade.SALES_ORDER_FAILED,
				ApplicationFacade.DEBTOR_ACCOUNT_LOADING,
				ApplicationFacade.DEBTOR_ACCOUNT_LOADED,
				ApplicationFacade.DEBTOR_ACCOUNT_FAILED,
				ApplicationFacade.INVOICE_LOADING,
				ApplicationFacade.INVOICE_LOADED,
				ApplicationFacade.INVOICE_FAILED
				   ];
		}
		override public function handleNotification( note:INotification ):void {
		    addToNotificationsReceived( note );
			switch ( note.getName() ) {
			    case LoadupMonitorProxy.CALL_OUT_OF_SYNC_IGNORED:
			        app.overallStatus = "Abnormal State, See Notifications, Abort"
			        break;
			    case LoadupMonitorProxy.LOADING_PROGRESS:
			        app.pb.setProgress( note.getBody() as Number, 100);
			        break;
			    case LoadupMonitorProxy.LOADING_COMPLETE:
		            app.overallStatus = "Finished complete";
			        break;
			    case LoadupMonitorProxy.LOADING_FINISHED_INCOMPLETE:
			        app.overallStatus = "Finished Incomplete";
			        app.retryIsVisible = true;
			        app.retryIsEnabled = true;
			        app.paramsEntryIsEnabled = true;
			        app.mode = 2;
			        break;
				case ApplicationFacade.CUSTOMER_LOADING: app.customerStatus = LOADING;
					break;
				case ApplicationFacade.CUSTOMER_LOADED: app.customerStatus = LOADED;
					break;
				case ApplicationFacade.PRODUCT_LOADING: app.productStatus = LOADING;
					break;
				case ApplicationFacade.PRODUCT_LOADED: app.productStatus = LOADED;
					break;
				case ApplicationFacade.SALES_ORDER_LOADING: app.salesOrderStatus = LOADING;
					break;
				case ApplicationFacade.SALES_ORDER_LOADED: app.salesOrderStatus = LOADED;
					break;
				case ApplicationFacade.DEBTOR_ACCOUNT_LOADING: app.debtorAccountStatus = LOADING;
					break;
				case ApplicationFacade.DEBTOR_ACCOUNT_LOADED: app.debtorAccountStatus = LOADED;
					break;
				case ApplicationFacade.INVOICE_LOADING: app.invoiceStatus = LOADING;
					break;
				case ApplicationFacade.INVOICE_LOADED: app.invoiceStatus = LOADED;
					break;
			}
		}
		private function addToNotificationsReceived( note :INotification ) :void {
		    var noteText :String = note.getName();
		    var body :String = note.getBody() as String;
		    if ( body )
		        noteText += "[" + body + "]";
		    else {
		        var info :FailureInfo = note.getBody() as FailureInfo;
		        if ( info ) {
		            var infoContent :String = info.proxyName;
		            if ( info.allowRetry == false )
		                infoContent += ", Do Not Retry";
		            noteText += "[" + infoContent + "]"
		        }
		    }
		    notificationsReceived.addItemAt(noteText, 0);
		}

	}
}