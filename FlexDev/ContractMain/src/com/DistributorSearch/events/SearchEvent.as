package com.DistributorSearch.events
{
	import com.DistributorSearch.vos.Settings;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	[Bindable] 
	public class SearchEvent extends Event
	{
		
		/*-.........................................Constants..........................................*/
		public static const GET:String = "getSearchEvent";
		public static const UPD_CB_FILTERS:String = "updCbFilters";
		public static const FILTER:String = "filter";
		public static const RESET_FILTER:String = "resetFilter";
		public static const FILTER_SELECTED:String = "filterSelected";
		public static const UPDATE_CBO_FILTERS:String = "updCbFilters";
		public static const CREATE_LIST:String = "createList";
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
		public static const TEST:String = "testEvent";
		public static const LOAD_ALL_ITEMS:String = "loadAllItems";
		public static const RESET_SCROLLBAR_POSITION:String ="resetScrollbarPosition";
		
		/*-.........................................Properties..........................................*/
		public var name:String;
		public var searchFieldText:String;
		public var f1:String;
		public var f2:String;
		public var f3:String;
		public var f4:String;
		public var f5:String;
		public var f6:String;
		public var itemAC:ArrayCollection = new ArrayCollection();
		public var iList:String;
		public var settings:Settings;
		public var userId:String;
		public var arrUserListItems:Array;
		public var userListItemsName:String;
		public var userListId:int;
		public var programId:int;
		public var discountType:int;
		public var bfilterMiniItem:Boolean;
		public var selectAll:Boolean;
		public var appSettings:Object;
		public var oBaError:Object;
		public var sBaError:String;
		public var surl:String;
		public var oneDistSelection:Boolean;

		/*-.........................................Contructor..........................................*/
		public function SearchEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}	
	}
	
}