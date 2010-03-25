package com.tikalk.flex.foundation.core
{
	import org.puremvc.as3.core.Model;
	import org.puremvc.as3.interfaces.IModel;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.facade.Facade;
	import com.tikalk.flex.foundation.interfaces.IFoundationLoadupProxy;
	import org.puremvc.as3.utilities.loadup.model.LoadupMonitorProxy;
	import org.puremvc.as3.utilities.loadup.model.LoadupResourceProxy;
	
	public class FoundationModel extends Model implements IModel
	{
		private var monitor :LoadupMonitorProxy;
		
		public static function getInstance() : IModel 
		{
			if (instance == null) instance = new FoundationModel( );
			return instance;
		}

		override public function registerProxy( proxy:IProxy ) : void
		{
			super.registerProxy(proxy);
			
			//IFoundationLoadupProxy
			if (proxy is IFoundationLoadupProxy)
			{
				makeAndRegisterLoadupResource(IFoundationLoadupProxy(proxy).getSRName(),proxy as IFoundationLoadupProxy);
			}
		}
		
		private function makeAndRegisterLoadupResource( proxyName :String, appResourceProxy :IFoundationLoadupProxy ):LoadupResourceProxy 
		{
			var r :LoadupResourceProxy = new LoadupResourceProxy( proxyName, appResourceProxy );
			registerProxy(r);
			
			monitor = retrieveProxy(LoadupMonitorProxy.NAME ) as LoadupMonitorProxy;
			monitor.addResource( r );
			return r;
		}	

	}
}