package com.shared.events
{
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import com.ContractProds.vos.Payee;
	
	[Bindable] 
	public class MainEvent extends Event
	{
		
		/*-.........................................Constants..........................................*/
		public static const GET:String = "getSearchEvent";
		public static const BSA_ERROR:String = "bsaError";
		public static const BSA_NO_SERVICE_ERROR:String = "bsaNoServiceError";
		public static const LOAD_APP_SETTINGS:String = "loadAppSettings";
		public static const SEARCH_ITEMS:String = "searchItems";
		public static const SEARCH_PAYEE:String = "searchPayee";
		public static const CLOSE_PAYEE:String = "closePayee";

		/*-.........................................Properties..........................................*/
		
		public var settings:Settings;
		public var userId:String;
		public var programId:int;
		public var appSettings:Object;
		public var oBaError:Object;
		public var sBaError:String;
		public var sState:String;
		public var payee:Payee;
		public var payeeTypeId:int;

		/*-.........................................Contructor..........................................*/
		public function MainEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}	
	}
	
}