package com.tikalk.flex.foundation.patterns.facade
{
	import org.puremvc.as3.patterns.facade.Facade;
	import com.tikalk.flex.foundation.core.FoundationController;
	import com.tikalk.flex.foundation.core.FoundationModel;
	import com.tikalk.flex.foundation.core.FoundationView;
	import com.tikalk.flex.foundation.patterns.command.FoundationLoadupCommand;
	import org.puremvc.as3.utilities.loadup.model.LoadupMonitorProxy;
	
	public class FoundationFacade extends Facade
	{
		public function FoundationFacade()
		{
			super();
		}
		// Singleton ApplicationFacade Factory Method
		public static function getInstance(): FoundationFacade {
			if (instance == null) {
				instance = new FoundationFacade( );
			}
			return instance as FoundationFacade;
		}
		override protected function initializeModel( ):void 
		{
			model = FoundationModel.getInstance();// No need of calling the super
			
			//TODO: Should be Conditional
			this.registerProxy( new LoadupMonitorProxy() );
		}
		
		override protected function initializeController():void
		{
			controller = FoundationController.getInstance();
			
			//TODO: Should be Conditional
			this.registerCommand(FoundationConstants.LOAD_RESOURCES, FoundationLoadupCommand);
		}
		
		override protected function initializeView():void
		{
			view = FoundationView.getInstance();
		}
	}
}