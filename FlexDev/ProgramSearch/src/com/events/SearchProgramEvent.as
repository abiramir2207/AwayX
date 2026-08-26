package com.events
{
	import com.vos.SearchGridColumnSize;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	//import flash.event.Event;
	[Bindable] 
	/**
	  * All the event declarations for the SearchProgram goes in this file.
	*/
	public class SearchProgramEvent extends Event
	{		
		/*-.........................................Constants..........................................*/
		public static const ON_RESULT:String 			   = "onResult";
		public static const GET:String					   = "get";
		public static const CALL_GET:String					   = "callGet";
		public static const GET_USERID:String 			   = "getUserID_result";
		public static const GET_ALL_TEMPLATES:String 	   = "fnGetAllTemplate";
		public static const GET_ALL_STATUS:String 		   = "fnGetAllStatus";
		public static const GET_ALL_USER_POSITIONS:String  = "fnGetAllUserPositions";
		public static const GET_ALL_BUYING_GROUPS:String   = "fnGetAllBuyingGroups";
		public static const GET_ALL_FAMILY_NAMES:String    = "fnGetAllFamilyNames";
		public static const GET_USERS_AND_POSITIONS:String = "fnGetUsersAndPositions";
		public static const CHECK_MASTER_DATA_COMPLETE:String = "checkMasterDataComplete";
	
		/* - ******** Error/Fault capturing Events ******* - */		
		public static const ON_FAULT:String 					= "onFault"; 
		public static const GET_ALL_TEMPLATES_FAIL:String 	    = "fnGetAllTemplateFail";
		public static const GET_ALL_STATUS_FAIL:String 		    = "fnGetAllStatusFail";
		public static const GET_ALL_USER_POSITIONS_FAIL:String  = "fnGetAllUserPositionsFail";
		public static const GET_ALL_BUYING_GROUPS_FAIL:String   = "fnGetAllBuyingGroupsFail";
		public static const GET_ALL_FAMILY_NAMES_FAIL:String    = "fnGetAllFamilyNamesFail";
		public static const GET_USERS_AND_POSITIONS_FAIL:String = "fnGetUsersAndPositionsFail";
		
		/* - ******** General Functions/Methods ******* - */			
		public static const RESET_FILTERS:String  	 = "ResetFilters";
		public static const SET_FILTER:String  	 	= "setFilter";
		public static const DATA_GRID_SORT:String  	 	= "SortGridData";
		public static const SET_USER_POSITION:String = "SetUserPosition";
		public static const FILTER_PROGRAMS:String   = "FilterPrograms";
		public static const INITIAL_FUNC:String		 = "InitialFunc";
		public static const FILTER_RESULTS:String 	 = "filterResults";
		public static const INIT_APP:String			 = "InitApp";
	
		public static const BSA_ERROR:String 			= "bsaError";		
		public static const BSA_NO_SERVICE_ERROR:String = "bsaNoServiceError";
		public static const EVT_LOADCOMBOS:String 		= "evtLoadCombos";
		public static const LOAD_APP_SETTINGS:String 	= "loadAppSettings";
		public static const SC_SCISSOR_CLICKED:String 	= "scScissorClicked";
		public static const CREATE_LIST:String 					= "createList";
		public static const GET_USERLIST:String 				= "getUserList";
		public static const SAVE_USERLIST:String 				= "saveUserList";
		public static const DELETE_USERLIST:String 			= "deleteUserList";
		public static const GET_USERLIST_ITEMS:String 	= "getUserListItems";		
		public static const FILTER_SELECTED:String 			= "filterSelected";
		public static const RO_FILTER_PROGRAMS:String 			= "roFilterPrograms";
		public static const FILTER_STATUS_RESULTS:String ="getStatusFilterData";
		public static const LOAD_SO_ITEMS:String ="getLoadedSharedObjectItems";
		public static const HIDE_INFO:String ="hideInfo";
		public static const SHOW_INFO:String ="showInfo";
		public static const UNCHECK_SELECTED:String ="uncheckSelected";	
		public static const RESET_SCROLLBAR_POSITION:String ="resetScrollbarPosition";
		public static const SHOW_SELECTED_OPTIONS:String ="showSelectedOptions";
		public static const EXPORT_XLS:String ="exportXLS";
		public static const SELECT_OPTIONS_PROGRAM:String = "selectOptionsProgram";
		public static const SELECT_OPTIONS_CATALOG:String = "selectOptionsCatalog";
		public static const IMPORT_ITEMS:String = "ImportItems";
		public static const SET_STATUS:String = "setStatus";
		public static const GET_ALL_COLUMNS_SIZE:String = "getAllColumnsSize";
		public static const SAVE_ALL_COLUMNS_SIZE:String = "saveAllColumnsSize";
		public static const SET_COLUMN_SIZE:String = "setColumnSize";
		public static const RESET_COLUMN_ORDER:String = "resetColumnOrder";
		public static const UPDATE_CREATE_LIST:String = "updateCreateList";
		
		/* - ******** Program Popup page methods ******* - */
		public static const GET_PROGRAM_AUTORENEW_INFO:String 	= "getProgramAutoRenewInfo";
		public static const GET_BUSINESS_SEGMENT_SETTING:String 	= "getBusinessSegmentSetting";
		public static const GET_INTERFACE_INFO:String 	   		= "getInterfaceInfo";
		public static const GET_ATTACHMENT_INFO:String 		   	= "getAttachmentInfo";
		public static const GET_PROGRAM_SAP_INFO:String  		= "getProgramSAPInfo";
		public static const GET_PROGRAM_DETAILS:String 	   		= "getProgramDetails";
		public static const GET_CRA_DETAILS:String 	   			= "getCRADetails";
		public static const GET_WORKFLOW_DATA:String 	   			= "getWorkflowData";
		public static const GET_NRA_DATA:String 	   			= "getNRAData";		
		public static const GET_PROGRAM_REVISION_COUNT:String 	= "getAreThereRevisions";
		public static const GET_GL_ACCOUNT_INFO:String = "fnGetGLAccountInfo";
		
	 	/*-.........................................Properties..........................................*/	
		public var initialTime:int;
     	public var loadComplete:int;
 		public var ProgramsReturned:Number; 
    	public var Duration_Time:Number;   	
	
		public var oBaError:Object;
		public var sBaError:String;
 		public var sURL:String;
 		
		public var eStatus:String;
		public var eTemplate:String;
		public var eRSP:String;
		public var eBuyingGroups:String;
		public var eFamilyName:String;
		public var eBudgetClasses:String;
		public var ePositions:String;
		public var eProgramInfo:String;
 		public var eUserName:String;
		public var eUName:String;
 		public var eReportType:String;
 		public var eFileName:String;
 		public var eConditions:String;
		public var eBusinessSegments:String;
		public var eSearchGridColumnSize:SearchGridColumnSize;
 		
 		public var eProgram_Info:String;
		public var eDistributor_Info:String;
		public var eOperator_Info:String;
		public var eItem_Info:String;
		public var programAC:ArrayCollection = new ArrayCollection;
		public var userId:String;
		public var programId:String;
		public var set1:String;
		public var set2:String;
		public var set3:String;
		public var set4:String;
		public var set5:String;
		public var set6:String;
		public var arrUserListItems:Array;
		public var userListItemsName:String;
		public var userListId:int;
		public var iList:String;
		public var sStartDate:String;
		public var sEndDate:String;
		public var showCatalog:int;
		public var sUpdateCreateList:String;
		
		public var Include_work_in_progress_below_me:int;
		public var Creating_User_Position:int;
		
		public var timeZoneOffset:int;
		public var useDayLightSavingsTime:Boolean;
		
		
		/* - ******** Program Popup page vars ******* - */
		public var eAutoRenewInfo:int;
		public var eInterfaceInfo:int;
		public var eAttachmentInfo:int;
		public var eProgramSAPInfo:int;
		public var eProgramDetailsInfo:int;
		public var eCRADetailsInfo:int;
		public var eWorkflowData:int;
		public var eNRAData:int;
		public var eBusinessSegmentSetting:Boolean;
		public var eResponsibleUserIDInfo:String;
		public var eProgramRevisionCountInfo:int;
		public var eGLAccountInfo:int;
		
		/*-.........................................Contructor..........................................*/
		public function SearchProgramEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)		
		{
			super(type, bubbles, cancelable);
		}	
	}
	
}