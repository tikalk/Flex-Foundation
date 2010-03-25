package com.tikalk.flex.foundation.interfaces
{
	import org.puremvc.as3.utilities.loadup.interfaces.ILoadupProxy;
	
	public interface IFoundationLoadupProxy extends ILoadupProxy
	{
		function getSRName():String;
		
		function set requires(value:Array):void;
		function get requires():Array;
	}
}