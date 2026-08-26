package com.events
{
	import com.vos.NetPriceSettings;
	
	import flash.events.Event;
	
	import mx.containers.Canvas;
	import mx.controls.DataGrid;
	
	[Bindable] 
	public class NetPriceEvent extends Event
	{
		
		/*-.........................................Constants..........................................*/
		public static const GET_REPORT:String = "getReport";
		public static const GET_REPORT_FROM_CACHE:String = "getReportFromCache";
		public static const STORE_REPORT_TO_CACHE:String = "storeReportToCache";
		public static const GET_REPORT_REFRESH_DATA:String = "getReportRefreshData";
		public static const GET_USER_MARKET_DATA:String = "getUserMarketData";
		public static const GET_AUX_DATA:String = "getAuxiliaryData";
		public static const BSA_ERROR:String = "bsaError";
		public static const BSA_NO_SERVICE_ERROR:String = "bsaNoServiceError";
		public static const LOAD_APP_SETTINGS:String = "loadAppSettings";		
		public static const FILTER_RESULTS:String 	 = "filterResults";
		public static const RESET_FILTER:String 	 = "resetFilter";
		public static const PRINT_PAGE:String 	 = "printPage";
		public static const EXPORT_CSV:String 	 = "exportCSV";

		/*-.........................................Properties..........................................*/
		
		public var settings:NetPriceSettings;
		public var userId:String;
		public var programId:int;
		public var appSettings:Object;
		public var oBaError:Object;
		public var sBaError:String;
		
		//Filtering
		public var eDistributorKeyword:String;
		public var eBuyingGroup:String;
		public var eFamilyName:String;
		public var eRegion:String;
		public var eBroker:String;
		public var eProductKeyword:String;
		public var eTypeCode:String;
		
		//Display ON/OFF
		public var eShowBroker:Boolean;
		public var eShowRegion:Boolean;
		public var eShowFamily:Boolean;
		public var eShowBuyingGroup:Boolean;
		public var eShowTypeCode:Boolean;
		
		public var eShowCase:Boolean;
		public var eShowPound:Boolean;
		
		public var eOptionBNetSales:Boolean;
		public var eOptionBPercentageDiscount:Boolean;
		public var eOptionBSpendingRate:Boolean;
		
		//Printing
		public var ePage:Canvas = new Canvas();
		
		//Export to CSV
		public var eDataGrid:DataGrid;

		/*-.........................................Contructor..........................................*/
		public function NetPriceEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}	
	}
	
}