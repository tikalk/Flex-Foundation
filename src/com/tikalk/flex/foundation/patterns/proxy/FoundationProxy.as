package com.tikalk.flex.foundation.patterns.proxy
{
	import org.puremvc.as3.patterns.proxy.Proxy;
	import com.tikalk.flex.foundation.interfaces.IFoundationLoadupProxy;
	import org.puremvc.as3.utilities.loadup.model.LoadupResourceProxy;
	
	public class FoundationProxy extends Proxy
	{
		public function FoundationProxy(proxyName:String=null, data:Object=null)
		{
			super(proxyName, data);
		}
		
		//////////////////////////////////////
		//	IFoundationLoadupProxy
		//////////////////////////////////////
		private var _requires:Array;
		
		public function set requires(value:Array):void
		{
			if(!(this is IFoundationLoadupProxy))
			{
				return;
			}
			
			_requires = value;
			var wrapperLoadupProxy:LoadupResourceProxy = facade.retrieveProxy(IFoundationLoadupProxy(this).getSRName()) as LoadupResourceProxy;
			var requiredLoadupProxy:LoadupResourceProxy;
			var loadupProxyArray:Array = new Array();
			for each (var proxy:IFoundationLoadupProxy in value)
			{
				requiredLoadupProxy = facade.retrieveProxy(proxy.getSRName()) as LoadupResourceProxy;
				loadupProxyArray.push(requiredLoadupProxy); 
			}
			
			wrapperLoadupProxy.requires = loadupProxyArray;		
		}
		
		public function get requires():Array
		{
			return _requires;
		}
	}
}