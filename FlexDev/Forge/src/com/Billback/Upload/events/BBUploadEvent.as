package com.Billback.Upload.events
{
	
	import com.Billback.Edit.models.vos.BBToolsLock;
	import com.Billback.Main.models.vos.BBHeader;
	import com.Billback.Main.models.vos.Payee;
	import com.Billback.Upload.models.vos.BBRawEDIHeader;
	import com.Billback.Upload.models.vos.BBUploadHeader;
	import com.Billback.Upload.models.vos.BBUploadLog;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	
	public class BBUploadEvent extends Event
	{
		
		/*-.........................................Constants..........................................*/
		public static const ADD_BB_CORRECTIONS:String 	= "addBBCorrectionsEvent";
		public static const BSA_ERROR:String 				= "bsaError";
		public static const BSA_NO_SERVICE_ERROR:String 	= "bsaNoServiceError";
		public static const BB_LOAD_APP_SETTINGS:String 	= "bbLoadAppSettings";
		public static const CLEAR_SELECTED_VENDOR:String	= "uploadClearSelectedVendor";
		public static const LOAD_DISTRIBUTOR:String			  =	"uploadloadDistributor";		
		public static const LOAD_DISTRIBUTOR_SEARCH:String		= "uploadLoadDistributorSearch";
		public static const LOAD_OPERATOR:String			  =	"uploadloadOperator";		
		public static const LOAD_OPERATOR_SEARCH:String		= "uploadLoadOperatorSearch";
		public static const DELETE_BB_UPLOAD:String 		= "deleteBBCorrectionsEvent";//Delete record in DB
		public static const DELETE_CORRECTION_ROW:String = "deleteCorrectionRowUploadEvent";
		public static const LOAD_BB_EDIT:String 			= "loadBBUploadEvent";
		public static const LOAD_BB_CORRECTIONS:String 	= "loadBBCorrectionsEvent";
		public static const LOAD_CREATED_BILLBACKS:String = "loadCreatedBillbacks";
		public static const LOAD_BB_UPLOAD_HISTORY:String = "loadBBUploadHistoryEvent";
		public static const LOAD_VENDOR:String			  =	"uploadloadVendor";		
		public static const LOAD_VENDOR_SEARCH:String		= "uploadLoadVendorSearch";
		public static const REMOVE_BB_UPLOAD:String 		= "removeBBCorrectionsEvent";//remove from List (not DELETE)
		public static const SET_USER_ID:String 			= "setUserIdEvent";
		public static const SEARCH_ITEMS:String 			= "searchItems";
		public static const SELECT_BB_UPLOAD_LOG:String	= "selectBBUploadLog";
		public static const VALIDATE:String 				= "validate";
		public static const LOCK_BB_EDIT:String						=	"lockBBEdit";
		public static const GET_LOCK_BB_EDIT:String					=	"getLockBBEdit";
		public static const UNLOCK_OTHER_LOCKED_USER:String			=	"unlockOtherLockedUser";
		public static const SET_GRID_LOCK_UNLOCK:String				= 	"setGridLockUnlock";
		public static const SET_BB_TOOLS_LOCK:String				= 	"setBBToolsLock";
		public static const LOAD_RAW_EDI_DATA_SEARCH:String			= "loadRawEDIDataSearch";
		public static const LOAD_BB_RAW_EDI_DETAIL:String			= "loadBBRawEDIDetailUpdEvt";
		/*-.........................................Properties..........................................*/
		
		public var appSettings:Object;
		public var arrBBcorrrections:Array;
		public var BBId:String;
		public var bbUploadHeader:BBUploadHeader;
		public var bbHeaderID:int;
		public var bbUploadLog:BBUploadLog;
		public var dtStart:Date;
		public var dtEnd:Date;
		public var oBaError:Object;
		public var programId:int;
		public var sBaError:String;
		public var settings:Settings;
		public var sState:String;
		public var userId:String;
		public var uploadId:int;
		public var lockIt:Boolean;
		public var bbtoggle:Boolean;
		public var bbUnlockExistingLockedByUser:Boolean;
		public var bbClose:Boolean;
		public var vendorId:String;
		public var vendor:Payee;
		public var distributorId:String;
		public var operatorId:String;
		public var sAction:String;
		public var uploadIDList:String;
		public var bDisplayAll:Boolean;
		public var bbToolsLock:BBToolsLock;
		
		public var payableNumber:String;
		public var bbDate:Date;
		public var vendorName:String;
		public var accountNumber:String;
		public var accountName:String;
		public var custPromoCode:String;
		public var custPromoDesc:String;
		public var oBBEDIFilterParams:Object;
		public var bbRawEDIHeader:BBRawEDIHeader;
		
		
		/*-.........................................Contructor..........................................*/
		public function BBUploadEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}	
	}
	
}