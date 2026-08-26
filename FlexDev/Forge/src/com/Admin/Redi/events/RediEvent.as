package com.Admin.Redi.events
{
	import com.Admin.Redi.models.vos.RediCorrectionHeader;
	import com.Billback.Main.models.vos.BBHeader;
	import com.shared.models.entity.vos.Customer;
	import com.shared.models.entity.vos.Lock;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	
	public class RediEvent extends Event
	{
		
		/*-.........................................Constants..........................................*/
		public static const DELETE_CORRECTION:String = "deleteCorrection";
		public static const EDIT_CORRECTION:String = "editCorrection";
		public static const LOAD_REDI_HISTORY:String = "loadRediHistoryEvent";
		public static const LOAD_REDI_OPEN:String = "loadRediOpenEvent";
		public static const LOAD_REDI_EDIT:String = "loadRediEditEvent";
		public static const FILTER:String = "filterRedi";
		public static const GET_CORRECTION_LOCK:String = "rediGetCorrectionLockEvent";
		public static const GET_REDI_SETTINGS:String = "rediGetSettingsEvent";
		public static const SET_USER_ID:String = "setUserIdEvent";
		public static const BSA_ERROR:String = "bsaError";
		public static const BSA_NO_SERVICE_ERROR:String = "bsaNoServiceError";
		public static const CALL_CLOSE_CORRECTION:String = "callCloseCorrection";
		public static const CLOSE_CORRECTION:String = "closeCorrection";
		public static const LOOKUP_ITEMS:String = "lookupItems";
		public static const Redi_LOAD_APP_SETTINGS:String = "RediLoadAppSettings";
		public static const REPROCESS_REDI:String = "reprocessRedi";
		public static const SEARCH_ITEMS:String = "searchItems";
		public static const SEARCH_CUSTOMER:String = "searchCustomer";
		public static const VALIDATE_REDI:String = "validateRedi";
		public static const VALIDATE_MULTIPLE_REDI:String = "validateMultipleRedi";
		public static const SAVE_REDI_SETTINGS:String = "saveRediSettings";
		public static const EXTRACT_OPEN_REDI:String = "extractOpenRedi";

		/*-.........................................Properties..........................................*/
		
		public var b:Boolean;//generic bool
		public var customer:Customer;
		public var settings:Settings;
		public var rch:RediCorrectionHeader;
		public var sItem:String;
		public var lock:Lock;
		public var userId:String;
		public var rediId:String;
		public var programId:int;
		public var appSettings:Object;
		public var oBaError:Object;
		public var sBaError:String;
		public var sState:String;
		public var bbHeader:BBHeader;
		public var arr:Array; //generic used to past array data

		/*-.........................................Contructor..........................................*/
		public function RediEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}	
	}
	
}