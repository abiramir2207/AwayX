package com.events
{
	import com.vos.Settings;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	[Bindable] 
	public class SearchEvent extends Event
	{
		
		/*-.........................................Constants..........................................*/
		public static const BSA_ERROR:String = "bsaError";
		public static const BSA_NO_SERVICE_ERROR:String = "bsaNoServiceError";
		public static const CREATE_LIST:String = "createList";
		public static const DELETE_USERLIST:String = "deleteUserList";
		public static const FILTER:String = "filter";
		public static const FILTER_DESELECTED:String = "filterDeSelected";
		public static const FILTER_SELECTED:String = "filterSelected";
		public static const GET_OPERATORS:String = "getSearchOperatorFromDB";
		public static const GET_OPERATORS_EVENT:String = "getSearchOperatorEvent";
		public static const GET_SAVED_OPERATORS:String = "getSavedOperatorFromDB";
		public static const GET_SAVED_OPERATORS_EVENT:String = "getSavedOperatorsEvent";
		public static const GET_USERLIST:String = "getUserList";
		public static const GET_USERLIST_OPERATORS:String = "getUserListOperators";
		public static const IMPORT_OPERATORS:String = "importOperators";
		public static const LOAD_APP_SETTINGS:String = "loadAppSettings";
		public static const LOAD_Filter_Values:String = "loadFilterValues";
		public static const LOAD_Operator_Type_Values:String = "loadOperatorTypeValues";
		public static const LOAD_State_Values:String = "loadStateValues";
		public static const LOAD_Status_Values:String = "loadStatusValues";
		public static const RESET_FILTER:String = "resetFilter";
		public static const SAVE_SETTINGS:String = "saveSettings";
		public static const SAVE_USERLIST:String = "saveUserList";
		public static const SELECT_ALL:String = "selectAll";
		public static const TRACK_OPERATORS:String = "trackOperators";
		public static const UPD_CB_FILTERS:String = "updCbFilters";
		public static const UPDATE_CBO_FILTERS:String = "updCbFilters";
		public static const RESET_SCROLLBAR_POSITION:String ="resetScrollbarPosition";

		

		/*-.........................................Properties..........................................*/
		public var arrUserListOperators:Array;
		public var businessSegmentID:int;
		public var businessSegmentsOn:Boolean;
		public var discountType:int;
		public var iList:String;
		public var name:String;
		public var oBaError:Object;
		public var operatorAC:ArrayCollection = new ArrayCollection;
		public var operatorType:String;
		public var programId:int;
		public var savedOperatorIDs:String;
		public var sBaError:String;
		public var searchFieldText:String;
		public var selectAll:Boolean;
		public var selectedOperator:Object;
		public var settings:Settings;
		public var state:String;
		public var status:String;
		public var userId:String;
		public var userListId:int;
		public var userListOperatorsName:String;

		/*-.........................................Contructor..........................................*/
		/**
		 * Default constructor
		 * 
		 * @param type This will be one of the event types defined above.
		 * @param bubbles This is always true, saying the event to bubble up to the main event handler.
		 * @param cancelable
		 * 
		 */		
		public function SearchEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}	
	}
	
}