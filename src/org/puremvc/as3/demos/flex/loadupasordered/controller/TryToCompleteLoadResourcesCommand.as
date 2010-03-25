/*
	PureMVC Flex Demo - Use Loadup Utility - Manage loading of data resources
	Copyright (c) 2008 Philip Sexton <philip.sexton@puremvc.org>
	Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package org.puremvc.as3.demos.flex.loadupasordered.controller {
	
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	import org.puremvc.as3.utilities.loadup.model.LoadupMonitorProxy;
	import org.puremvc.as3.utilities.loadup.model.RetryPolicy;
	import org.puremvc.as3.utilities.loadup.model.RetryParameters;

	public class TryToCompleteLoadResourcesCommand extends SimpleCommand implements ICommand {

		override public function execute( note:INotification ) : void {

    		var monitor :LoadupMonitorProxy;
		    monitor = facade.retrieveProxy( LoadupMonitorProxy.NAME ) as LoadupMonitorProxy;

		    monitor.reConfigureAllRetryPolicies( note.getBody() as RetryParameters );

            monitor.tryToCompleteLoadResources();
		}
	}
	
}
