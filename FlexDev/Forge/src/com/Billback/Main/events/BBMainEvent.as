package com.Billback.Main.events
{
	import com.Billback.Main.models.vos.BBHeader;
	import com.Billback.Main.models.vos.Billback;
	import com.Billback.Main.models.vos.Payee;
	import com.Billback.Main.models.vos.Status;
	import com.Billback.Upload.models.vos.BBRawEDIHeader;
	import com.Billback.Upload.models.vos.BBUploadHeader;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	
	public class BBMainEvent extends Event
	{
		
		/*-.........................................Constants..........................................*/
		public static const GET:String = "getSearchEvent";
		public static const LOAD_MODS_BBSEARCH:String = "loadModsBBSearch";
		public static const LOAD_MODS_BBCORRECTIONS:String = "loadModsBBCorrections";
		public static const LOAD_MODS_ALIAS:String = "loadModsAlias";
		public static const BSA_ERROR:String = "bsaError";
		public static const BSA_NO_SERVICE_ERROR:String = "bsaNoServiceError";
		public static const BB_MAIN_LOAD_APP_SETTINGS:String = "bbMainloadAppSettings";
		public static const DELETE_SEARCH_BBHEADER:String = "deleteSearchBBHeader";
		public static const SEARCH_ITEMS:String = "searchItems";
		public static const EDIT_BB:String = "editBB";
		public static const CLOSE_BB:String = "closeBB";
		public static const CHANGE_LABEL:String = "changeModuleLabel";
		public static const EDIT_BB_UPLOAD:String = "editBBUpload";
		public static const CLOSE_BB_UPLOAD:String = "closeBBUpload";
		public static const LOAD_DEVIATIONS:String = "loadDeviations";
		public static const CLOSE_DEVIATIONS:String = "closeDeviations";
		public static const UPDATE_SEARCH_BBHEADER:String = "updateSearchBBHeader";
		public static const GET_BB_CLOSINGMETHODS:String = "getBBClosingMethods";
		public static const LOAD_BB_CLOSINGMETHODS:String = "loadBBClosingMethods";
		public static const GET_BB_ANALYSTS:String = "getBBAnalysts";
		public static const LOAD_BB_ANALYSTS:String = "loadBBAnalysts";
		public static const UNLOCK_BB:String = 	"unlockBB";
		public static const UNLOCK_BB_UPLOAD:String = 	"unlockBBUpload";
		public static const LOAD_BB_RAW_EDI_DETAIL:String = "loadBBRAWEDIDetail";
		public static const CLOSE_BB_RAW_EDI_DETAIL:String = "closeBBRawEDIDetail"
		
		/*-.........................................Properties..........................................*/
		
		public var appSettings:Object;
		public var bbAnalysts:Array;
		public var bbHeader:BBHeader;
		public var bbId:String;
		public var bbUploadHeader:BBUploadHeader;
		public var billback:Billback;
		public var closingMethodList:Array;
		public var oBaError:Object;
		public var payeeList:Array;
		public var programId:int;
		public var sBaError:String;
		public var settings:Settings;
		public var sState:String;
		public var status:int;
		public var timeZoneOffset:int;
		public var useDayLightSavingsTime:Boolean;
		public var userId:String;
		public var bbRawEDIHeader:BBRawEDIHeader;
		// public var reDirector:String;
		
		/*-.........................................Contructor..........................................*/
		public function BBMainEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}	
	}
	
}