/*
	PureMVC Utility - Loadup - Manage loading of resources
	Copyright (c) 2009 Philip Sexton <philip.sexton@puremvc.org>
	Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package org.puremvc.as3.utilities.loadup.controller {
	
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.patterns.command.SimpleCommand;
    import org.puremvc.as3.utilities.loadup.model.LoadupMonitorProxy;

	/**
	 *  Abstract class
	 */
	public class LoadupResourceCommand extends SimpleCommand implements ICommand {

		protected function calcMonitorProxy( noteType :String ) :LoadupMonitorProxy {
		    var mon :LoadupMonitorProxy;
		    // First try noteType as LoadupMonitorProxy proxyName 
		    if ( noteType != null ) {
    		    mon = facade.retrieveProxy( noteType ) as LoadupMonitorProxy;
    		    if ( mon ) return mon;
		    }
		    // Otherwise, only possibility is the default name for a LoadupMonitorProxy
		    return facade.retrieveProxy( LoadupMonitorProxy.NAME ) as LoadupMonitorProxy;
		}
	}
	
}
