package com.Billback.Search.events
{
	import com.Billback.Main.models.vos.BBHeader;
	import com.Billback.Main.models.vos.BBSettlementAction;
	import com.Billback.Search.vos.BBFilterParams;
	import com.Billback.Search.vos.BBSearchGridColumnSize;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	
	public class BBSearchEvent extends Event
	{
		
		/*-.........................................Constants..........................................*/
		public static const BB_DELETE:String = "bbDelete";
		public static const BB_REASSIGN:String = "bbReassign";
		public static const BB_REMOTE_SEARCH_FILTER_DATA:String = "bbRemoteSearchFilterData";
		public static const BB_RESET:String = "bbReset";
		public static const BB_SEARCH_FILTER_DATA:String = "bbSearchFilterData";
		public static const BB_SEARCH_LOAD_APP_SETTINGS:String = "bbsearchloadAppSettings";
		public static const BB_SEARCH_NO_DATA:String = "bbSearchNoData"
		public static const BB_SHOW_HIDE_COLUMNS:String = "bbShowHideColumns";
		public static const BSA_ERROR:String = "bsaError";
		public static const BSA_NO_SERVICE_ERROR:String = "bsaNoServiceError";
		public static const COPY_BILLBACK:String = "copyBB";
		public static const CREATE_LIST:String = "createList";
		public static const DELETE_USERLIST:String = "deleteUserList";
		public static const EXPORT_XLS:String = "exportXLS";
		public static const GET_ALL_COLUMNS_SIZE:String = "getAllColumnsSize";
		public static const GET_BILLBACK_DETAILS:String = "getBillbackDetails";
		public static const GET_UPDATED_BB_HEADER_LIST:String = "getUpdatedBBheaderList";
		public static const GET_USER_LIST:String = "getUserList";
		public static const LOAD_ARCHIVE_BB_SEARCH:String = "loadArchiveBBSearch";
		public static const LOAD_BB_SEARCH:String = "loadBBSearchEvent";
		public static const LOAD_BB_SEARCH_LOOKUP_DATA:String = "loadBBSearchLookupData";
		public static const LOAD_PAID_BB_SEARCH:String = "loadPaidBBSearch";
		public static const LOAD_SO_ITEMS:String = "getLoadedSharedObjectItems";
		public static const MASS_APPROVE_BILLBACKS:String = "massApproveBillbacks";
		public static const REFRESH_BB_SEARCH:String = "refreshBBSearchEvent";
		public static const RESET_FILTERS:String = "bbResetFilters";
		public static const SAVE_ALL_COLUMNS_SIZE:String = "saveAllColumnsSize";
		public static const SAVE_USER_LIST:String = "saveUserList";
		public static const SELECT_BB:String = "selectBB";
		public static const SET_COLUMN_SIZE:String = "setColumnSize";
		public static const SET_FILTER:String = "setFilter";
		public static const SET_DELETE_BB_HEADER:String = "setDeleteBBHeader";
		public static const SET_UPDATE_BB_HEADER:String = "setUpdateBBHeader";
		public static const SET_UPDATE_BB_HEADER_LIST:String = "setUpdateBBHeaderList";		
		public static const SHOW_HIDE_CONTROLS:String = "showHideControls";
		public static const UNCHECK_SELECTED:String = "uncheckSelected";
		public static const DATA_VIEW_OPTION:String = "dataViewOption";
		public static const DATA_GRID_SORT:String = "dataGridSort";	
		public static const BB_SEARCH_FILTERS_SCREEN_HEIGHT:String = "bbSearchFiltersScreenHeight";
		
		/*-.........................................Properties..........................................*/
		
		public var settings:Settings;
		public var userId:String;
		public var programId:int;
		public var appSettings:Object;
		public var oBaError:Object;
		public var sBaError:String;
		public var sState:String;
		public var eBBFilterParams:BBFilterParams;
		public var euserListItemsName:String;
		public var euserListId:int;
		public var eList:String;
		public var eColumnHeader:String;
		public var eColumnWidth:int;
		public var eBBSearchGridColumnSize:BBSearchGridColumnSize;
		public var eSearchResultsCount:int;
		public var eBBDelete:String;
		public var eBBReset:String;
		public var eBBRessign:String;
		public var eStatus:int;
		public var ebillbackIDInt:int;
		public var ebillbackIDIntList:String;
		public var eBBHeader:BBHeader;
		public var eRefreshData:Boolean;
		public var eBBApprovalAction:BBSettlementAction;
		public var eArrBBHeader:Array = new Array();
		public var eSearchFiltersScreenHeightIncrease:Boolean;
		
		/*-.........................................Contructor..........................................*/
		public function BBSearchEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}	
	}
	
}