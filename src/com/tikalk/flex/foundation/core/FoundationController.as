package com.tikalk.flex.foundation.core
{
	import org.puremvc.as3.core.Controller;
	import org.puremvc.as3.interfaces.IController;
	
	public class FoundationController extends Controller implements IController
	{
		public static function getInstance() : IController 
		{
			if (instance == null) instance = new FoundationController( );
			return instance;
		}
	}
}