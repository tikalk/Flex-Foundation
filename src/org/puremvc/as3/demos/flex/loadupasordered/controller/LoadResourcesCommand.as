/*
	PureMVC Flex Demo - Use Loadup Utility - Manage loading of data resources
	Copyright (c) 2008 Philip Sexton <philip.sexton@puremvc.org>
	Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package org.puremvc.as3.demos.flex.loadupasordered.controller {
	
	import org.puremvc.as3.demos.flex.loadupasordered.model.CustomerProxy;
	import org.puremvc.as3.demos.flex.loadupasordered.model.DebtorAccountProxy;
	import org.puremvc.as3.demos.flex.loadupasordered.model.InvoiceProxy;
	import org.puremvc.as3.demos.flex.loadupasordered.model.ProductProxy;
	import org.puremvc.as3.demos.flex.loadupasordered.model.SalesOrderProxy;
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import com.tikalk.flex.foundation.interfaces.IFoundationLoadupProxy;
	import com.tikalk.flex.foundation.patterns.facade.FoundationConstants;

	public class LoadResourcesCommand extends SimpleCommand implements ICommand {

		/**
		 * 
		 * As regards an open-ended resource list, see BY THE WAY below.
		 */

		

		override public function execute( note:INotification ) : void {

            
			var cusPx :IFoundationLoadupProxy = new CustomerProxy();
			var proPx :IFoundationLoadupProxy = new ProductProxy();
			var soPx :IFoundationLoadupProxy = new SalesOrderProxy();
			var daccPx :IFoundationLoadupProxy = new DebtorAccountProxy();
			var invPx :IFoundationLoadupProxy = new InvoiceProxy();

            facade.registerProxy( cusPx );
            facade.registerProxy( proPx );
            facade.registerProxy( soPx );
            facade.registerProxy( daccPx );
            facade.registerProxy( invPx );
			
			
			cusPx.requires = [proPx]
            soPx.requires = [daccPx]
            invPx.requires = [daccPx, soPx];

            sendNotification(FoundationConstants.LOAD_RESOURCES,note.getBody());

		}
        


        /* BY THE WAY...
        *   If you wanted to consider an open-ended resource list, the following lines of code
        *   illustrate how the above code would be changed so that the Invoice resource is added 
        *   after loading of the others has commenced.
        *   
        var rCus :LoadupResourceProxy = makeAndRegisterLoadupResource( CustomerProxy.SRNAME, cusPx );
        var rPro :LoadupResourceProxy = makeAndRegisterLoadupResource( ProductProxy.SRNAME, proPx );
        var rSO :LoadupResourceProxy = makeAndRegisterLoadupResource( SalesOrderProxy.SRNAME, soPx );
        var rDAcc :LoadupResourceProxy = makeAndRegisterLoadupResource( DebtorAccountProxy.SRNAME, daccPx );

        rSO.requires = [ rCus, rPro ];
        rDAcc.requires = [ rCus ];

        monitor.keepResourceListOpen();
        monitor.expectedNumberOfResources = 20; // extreme example, line is optional
        monitor.loadResources();

        var rInv :LoadupResourceProxy = new LoadupResourceProxy( InvoiceProxy.SRNAME, invPx );
        facade.registerProxy( rInv );
        rInv.requires = [ rDAcc, rSO ];
        monitor.addResource( rInv );
        monitor.closeResourceList(); // comment this line to observe behaviour
        */

	}
	
}
