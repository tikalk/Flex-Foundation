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
	 *  Provides a command that is invoked when an application fails to load
	 *  a loadup resource.  The failure occurs within the application's own
	 *  resource proxy when it is carrying out the load activity.
	 *  The command invocation is via a <code>Notification</code> 
	 *  sent by the application.
	 *  <p>The body of the <code>Notification</code> MUST MUST
	 *  MUST identify the resource, using the application's ILoadupProxy proxyName.  This
	 *  name can be simply a String object or can be embedded in a FailureInfo object.</p>
	 *  <p>
	 *  The type of the <code>Notification</code> MUST meet the following requirement
	 *  <ul><li>if the related LoadupMonitorProxy instance has a custom name, i.e. the
	 *  proxyName is not LoadupMonitorProxy.NAME, then the type must contain this 
	 *  custom name.</li></ul></p>
	 *  <p>
	 *  This command must be registered for all the relevant notifications, for example
	 *  in the application's concrete facade.</p>
	 */
	public class LoadupResourceFailedCommand extends LoadupResourceCommand implements ICommand {

        protected const NULL_MONITOR_MSG :String = 
        ": Null Monitor, invalid failed notification from application, unable to determine LoadupMonitorProxy name";

		/**
		 * Inform the loadup monitor that a resource load has failed.
		 * The notification body identifies the particular resource; it can be a String or a FailureInfo.
		 */
		override public function execute( note:INotification ) : void {
		    var monitor :LoadupMonitorProxy = calcMonitorProxy( note.getType() );
		    if ( monitor == null )
		        throw new Error( NULL_MONITOR_MSG );

		    var proxyName :String;
		    var allowRetry :Boolean = true;
		    var info :FailureInfo = note.getBody() as FailureInfo;
		    if ( info ) {
		        proxyName = info.proxyName;
		        allowRetry = info.allowRetry;
		    }
		    else {
		        proxyName = note.getBody() as String;
		    }

		    monitor.resourceFailed( proxyName, allowRetry );
		}
	}
	
}
