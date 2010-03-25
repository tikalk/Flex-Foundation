package com.tikalk.flex.foundation.core
{
	import org.puremvc.as3.core.View;
	import org.puremvc.as3.interfaces.IView;
	
	public class FoundationView extends View implements IView
	{
		public static function getInstance() : IView 
		{
			if (instance == null) instance = new FoundationView( );
			return instance;
		}
	}
}