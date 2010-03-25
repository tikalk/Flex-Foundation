package com.tikalk.flex.foundation.patterns.command
{
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.utilities.loadup.model.LoadupMonitorProxy;
	import org.puremvc.as3.utilities.loadup.model.RetryParameters;
	import org.puremvc.as3.utilities.loadup.model.RetryPolicy;
	
	public class FoundationLoadupCommand extends FoundationSimpleCommand
	{
		override public function execute(notification:INotification):void
		{
			var monitor :LoadupMonitorProxy;
			monitor = facade.retrieveProxy( LoadupMonitorProxy.NAME ) as LoadupMonitorProxy;
		    monitor.defaultRetryPolicy = new RetryPolicy( notification.getBody() as RetryParameters) ;
		    monitor.loadResources();
		}		
	}
}