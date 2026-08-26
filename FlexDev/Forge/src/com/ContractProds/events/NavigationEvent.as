package com.ContractProds.events
{
	
	import flash.events.Event;

	public class NavigationEvent extends Event
	{
		/*-.........................................Constants..........................................*/
		
		public static const ITEM_LIST: String 	=	"itemListNavigationEvent";
		public static const LOGIN: String 			= "loginNavigationEvent";
		public static const INIT_SETTINGS: String 			= "initSettings";
		
		/*-.........................................Constructor..........................................*/	
		public function NavigationEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}
