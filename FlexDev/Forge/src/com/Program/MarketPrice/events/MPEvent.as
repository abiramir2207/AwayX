package com.Program.MarketPrice.events
{
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	[Bindable] 
	public class MPEvent extends Event
	{
		
		/*-.........................................Constants..........................................*/
		public static const GET:String = "getSearchEvent";
		public static const FILTER:String = "FilterEvent";
		public static const APPROVE:String = "Approve";
		public static const CANCEL:String = "CancelEvent";
		public static const BSA_ERROR:String = "bsaError";
		public static const BSA_NO_SERVICE_ERROR:String = "bsaNoServiceError";
		public static const LOAD_APP_SETTINGS:String = "loadAppSettings";
		public static const SEARCH_ITEMS:String = "searchItems";

		/*-.........................................Properties..........................................*/
		
		public var settings:Settings;
		public var userId:String;
		public var programId:int;
		public var bFilter:Boolean;
		public var appSettings:Object;
		public var oBaError:Object;
		public var sBaError:String;
		public var sState:String;

		/*-.........................................Contructor..........................................*/
		public function MPEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}	
	}
	
}