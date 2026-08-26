package com.shared.events
{
	import com.shared.components.filters.FilterAdvancedDatagrid;
	import com.shared.models.entity.vos.Customer;
	import com.shared.vos.Component;
	import com.shared.vos.Payee;
	import com.shared.vos.Program;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	[Bindable] 
	public class MainEvent extends Event
	{
		
		/*-.........................................Constants..........................................*/
		public static const BSA_ERROR:String = "bsaError";
		public static const BSA_NO_SERVICE_ERROR:String = "bsaNoServiceError";
		public static const CLEAR_ROW:String = "clearRow";
		public static const CLOSE_PAYEE:String = "closePayee";
		public static const COMPONENT_UPDATE:String = "componentUpdate";
		public static const DELETE_ROW:String = "deleteRow";
		public static const DELETE_CORRECTION_ROW:String = "deleteCorrectionRowMain";
		public static const DOWNLOAD_FILE:String = "downloadFile";
		public static const DOWNLOAD_FILE_COMPLETE:String = "downloadFileComplete";
		public static const FOCUS_ROW:String = "focusRow";
		public static const FILTER_DATAGRID_COMPLETE:String = "filterDataGridComplete";
		public static const GET:String = "getSearchEvent";
		public static const INSERT_ROW:String = "insertRow";
		public static const LOAD_APP_SETTINGS:String = "loadAppSettings";
		public static const LOAD_MODS_MAIN:String = "loadModsMain";
		public static const SEARCH_ITEMS:String = "searchItems";
		public static const READ_FILE:String = "readFile";
		public static const READ_FILE_COMPLETE:String = "readFileComplete";
		public static const SEARCH_PAYEE:String = "searchPayee";
		public static const SELECT_ROW:String = "selectRow";
		public static const SEND_REFERENCE:String = "sendrReference";
		public static const SET_LOCAL_APP_SETTINGS:String = "setLocalAppSettings";
		public static const SETTINGS_LOADED:String = "SettingsLoaded";
		public static const UPDATE_ROW:String = "updateRow";
		public static const UPLOAD_FILE:String = "uploadFile";
		public static const VALIDATE_MASS_UPDATE:String = "validateMassUpdate";

		/*-.........................................Properties..........................................*/
		
		public var appSettings:Object;
		public var bOneDist:Boolean;
		public var customer:Customer;
		public var eStatus:int;
		public var fadg:FilterAdvancedDatagrid;
		public var objRowData:Object;
		public var oBaError:Object;
		public var programId:int;
		public var payee:Payee;
		public var payeeTypeId:int;
		public var sBaError:String;
		public var sState:String;
		public var sURL:String;
		public var settings:Settings;
		public var userId:String;
		public var currentRow:int;
		public var component:Component;
		public var objMassUpdate:Object;
		public var editText:String;
		public var sSource:String;
		public var uploadIDList:String;
		/*-.........................................Contructor..........................................*/
		public function MainEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}	
	}
	
}