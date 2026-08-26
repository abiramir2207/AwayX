// ActionScript file
/**
* All the classes for the events are declared in this package 
*/
package com.events
{
	
	import flash.events.Event;
	/**
	 * This class holds the NavigationEvents used in the application
	 */ 
	public class NavigationEvent extends Event
	{
		/*-.........................................Constants..........................................*/
		
		public static const PROGRAM_LIST: String 	=	"ProgramListNavigationEvent";
		public static const LOGIN: String 			= "loginNavigationEvent";
		
		/*-.........................................Constructor..........................................*/	
		public function NavigationEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	} // Class
} // Package
