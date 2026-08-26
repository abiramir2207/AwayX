package com.Admin.events
{
	import flash.events.Event;
	import mx.collections.ArrayCollection;
	
	public class AdminEvent extends Event
	{
		
		/*-.........................................Constants..........................................*/
		public static const GET_ALL:String = "getAllEvent";

		/*-.........................................Properties..........................................*/
		
		
		public var userId:String;
		public var programId:int;
		public var appSettings:Object;
		public var oBaError:Object;
		public var sBaError:String;

		/*-.........................................Contructor..........................................*/
		public function AdminEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}	
	}
}