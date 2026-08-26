package com.Admin.AutoPay.events
{
	import com.Admin.AutoPay.models.vos.AutoPayDetail;
	import com.Admin.AutoPay.models.vos.SearchParms;
	import com.Billback.Main.models.vos.BBHeader;
	import com.shared.models.entity.vos.Lock;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	
	public class AutoPayEvent extends Event
	{
		
		/*-.........................................Constants..........................................*/
		public static const APPROVE_AUTO_PAY_REPORT:String = "approveAutoPayReport";
		public static const COPY_AUTO_PAY_REPORT:String = "copyAutoPayReport";
		public static const DELETE_AUTO_PAY_REPORT:String = "deleteAutoPayReport";
		public static const EDIT_AUTO_PAY_REPORT:String = "editAutoPayReport";
		public static const EXPORT_UNIVERSAL:String = "exportUniversal";
		public static const RUN_AUTO_PAY_REPORT:String = "runAutoPayReport";
		public static const FILTER_EMPTY_PAY_PERIOD:String = "filterEmptyPayPeriod";
		public static const GET_DATA:String = "getDataEvent";
		public static const GET_REPORT_LOCK:String = "getReportLock";
		public static const GET_REPORT_SUMMARY:String = "getReportSummary";
		public static const MODIFY_AUTO_PAY_REPORT:String = "modifyAutoPayReport";
		public static const SELECT_ROW:String = "selectRow";
		public static const SET_REPORT_LOCK:String = "setReportLock";
		public static const SET_USER_ID:String = "setUserIdEvent";
		public static const SET_SEARCH_PARMS:String = "setSearchParms";
		public static const BSA_ERROR:String = "bsaError";
		public static const BSA_NO_SERVICE_ERROR:String = "bsaNoServiceError";
		public static const AutoPay_LOAD_APP_SETTINGS:String = "AutoPayLoadAppSettings";
		public static const SEARCH_ITEMS:String = "searchItems";
		public static const UPDATE_REPORT_BY_ID:String = "updateReportById";

		/*-.........................................Properties..........................................*/
		
		public var sAction:String;
		public var appSettings:Object;
		public var autoPayDetail:AutoPayDetail;
		public var arr:Array;
		public var b:Boolean;
		//public var dtStart:Date;
		//public var dtEnd:Date;
		public var lock:Lock = new Lock();
		public var programId:int;
		public var oBaError:Object;
		public var reportId:Number = 0;
		public var sBaError:String;
		public var searchParms:SearchParms = new SearchParms();
		public var settings:Settings;
		public var sState:String;
		public var userId:String;

		/*-.........................................Contructor..........................................*/
		public function AutoPayEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
			
		}	
	}
	
}