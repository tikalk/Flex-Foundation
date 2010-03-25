package com.tikalk.flex.foundation.patterns.mediator
{
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class FoundationMediator extends Mediator
	{
		public function FoundationMediator(mediatorName:String=null, viewComponent:Object=null)
		{
			super(mediatorName, viewComponent);
		}
	}
}