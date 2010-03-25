/*
	PureMVC Utility - Loadup - Manage loading of resources
	Copyright (c) 2007-2008, collaborative, as follows
	2007 Daniele Ugoletti, Joel Caballero
	2008-2009 Philip Sexton <philip.sexton@puremvc.org>
	Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package org.puremvc.as3.utilities.loadup.controller {
	
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.utilities.loadup.model.LoadupMonitorProxy;

	/**
	 *  Provides a command that is invoked when an application succeeds in
	 *  loading a loadup resource.  The resource has been loaded by the
	 *  application's own resource proxy.
	 *  The command invocation is via a <code>Notification</code> 
	 *  sent by the application.
	 *  <p>
	 *  The body of the <code>Notification</code> MUST MUST
	 *  MUST identify the resource, using the application's ILoadupProxy proxyName.</p>
	 *  <p>
	 *  The type of the <code>Notification</code> MUST meet the following requirement
	 *  <ul><li>if the related LoadupMonitorProxy instance has a custom name, i.e. the
	 *  proxyName is not LoadupMonitorProxy.NAME, then the type must contain this 
	 *  custom name.</li></ul></p>
	 *  <p>
	 *  This command must be registered for all the relevant notifications, for example
	 *  in the application's concrete facade.</p>
	 */
	public class LoadupResourceLoadedCommand extends LoadupResourceCommand implements ICommand {

        protected const NULL_MONITOR_MSG :String = 
        ": Null Monitor, invalid loaded notification from application, unable to determine LoadupMonitorProxy name";

		/**
		 * Inform the loadup monitor that a resource has been loaded.
		 * The notification body identifies the particular resource.
		 */
		override public function execute( note:INotification ) : void {
		    var monitor :LoadupMonitorProxy = calcMonitorProxy( note.getType() );
		    if ( monitor == null )
		        throw new Error( NULL_MONITOR_MSG );

		    monitor.resourceLoaded( note.getBody() as String );
		}
	}
	
}
