/*
	PureMVC Flex Demo - Use Loadup Utility - Manage loading of data resources
	Copyright (c) 2008 Philip Sexton <philip.sexton@puremvc.org>
	Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package org.puremvc.as3.demos.flex.loadupasordered.controller {
	
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

    import org.puremvc.as3.demos.flex.loadupasordered.view.ApplicationMediator;

	public class StartupCommand extends SimpleCommand implements ICommand {

		/**
		 * Register the essential Proxies and Mediators.
		 * 
		 * Get the View Components for the Mediators from the app,
		 * which passed a reference to itself on the notification.
		 */

		override public function execute( note:INotification ) : void {

			facade.registerMediator( new ApplicationMediator( note.getBody() ) );
		}
	}
	
}
