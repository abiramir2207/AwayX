package com.ContractProds.events
{
	import com.shared.vos.CustomPrint;
	import com.shared.vos.FilterParms;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	[Bindable] 
	public class SearchEvent extends Event
	{
		
		/*-.........................................Constants..........................................*/
		public static const GET:String = "getSearchEvent";
		public static const GET_PROGRAM_PRODUCTS:String = "getProgProdsSearchEvent";
		public static const UPD_CB_FILTERS:String = "updCbFilters";
		public static const FILTER:String = "filter";
		public static const RESET_FILTER:String = "resetFilter";
		public static const FILTER_SELECTED:String = "filterSelected";
		public static const FILTER_RATES:String = "filterRates";
		public static const UPDATE_CBO_FILTERS:String = "updCbFilters";
		public static const CREATE_LIST:String = "createList";
		public static const CHK_FILTER_SEL_RESET:String = "chkFilterSelReset";
		public static const IMPORT_ITEMS:String = "importItems";
		public static const SAVE_SETTINGS:String = "saveSettings";
		public static const GET_USERLIST:String = "getUserList";
		public static const SAVE_USERLIST:String = "saveUserList";
		public static const DELETE_USERLIST:String = "deleteUserList";
		public static const GET_USERLIST_ITEMS:String = "getUserListItems";
		public static const GET_MINI_ITEMS:String = "getMiniItems";
		public static const FILTER_MINI_ITEMS:String = "filterMiniItems";
		public static const SELECT_ALL:String = "selectAll";
		public static const BSA_ERROR:String = "bsaError";
		public static const BSA_NO_SERVICE_ERROR:String = "bsaNoServiceError";
		public static const LOAD_APP_SETTINGS:String = "loadAppSettings";
		public static const GET_DISC_TYPES_ON_PRG_TEMPLATE:String = "getDiscTypesPrgTemplate";
		public static const RESET_SCROLLBAR_POSITION:String ="resetScrollbarPosition";
		public static const SAVE_FILTER_PARMS:String = "saveFilterParms";
		public static const LOAD_SO:String = "loadSo";
		public static const BUILD_SHOW_HIDE_CHK:String = "buildShowHideChk";

		/*-.........................................Properties..........................................*/
		public var name:String;
		public var searchFieldText:String;
		public var brand:String;
		public var qBrand:String;
		public var typeCode:String;
		public var typeGroup:String;
		public var lblStatus:String;
		/* this object replaces (contains) the properties above */
		public var oFilterParms:FilterParms;
		public var itemAC:ArrayCollection = new ArrayCollection;
		public var iList:String;
		public var settings:Settings;
		public var userId:String;
		public var arrUserListItems:Array;
		public var userListItemsName:String;
		public var userListId:int;
		public var programId:int;
		public var discountType:int;
		public var bfilterMiniItem:Boolean;
		public var programDiscountTypes:String;
		public var statusFilterOn:int;
		public var selectAll:Boolean;
		public var templateFilterId:int;
		public var bMarketPrice:Boolean;
		public var appSettings:Object;
		public var oBaError:Object;
		public var sBaError:String;
		public var bAllProds:Boolean;
		public var customPrint:CustomPrint = new CustomPrint();
		public var aItems:Array = new Array();

		/*-.........................................Contructor..........................................*/
		public function SearchEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}	
	}
	
}