 /**
 *  All the event declarations for the VolumeApplicator goes in this package.
 */ 
package com.events
 {
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;

	/**
 	*  All the event declarations for the VolumeApplicator goes in this Class.
 	*/ 

	[Bindable] 
	public class VolumeApplicatorEvent extends Event
	{
		/*-.........................................Constants..........................................*/
		public static const GET_VOLUME_DETAILS:String 		= "fnGetVolumeDetails";
		public static const GET_VOLUME_EDIT:String 			= "fnGetVolumeEdit";
		public static const GET_PROGRAM_DETAILS:String 		= "fnGetProgramDetails";
		public static const OPR_CONTROL_SETTING:String 		= "OprControlSetting";
		public static const SAVE_CHANGES:String 			= "SaveChanges";
		public static const FORCE_FORECAST:String			= "ForceForecast";
		public static const GET_ALL_TEMPLATES:String 	   	= "fnGetAllTemplate";
		public static const GET_ALL_STATUS:String 		   	= "fnGetAllStatus";
		public static const GET_ALL_USER_POSITIONS:String  	= "fnGetAllUserPositions";
		public static const GET_ALL_BUYING_GROUPS:String   	= "fnGetAllBuyingGroups";
		public static const GET_ALL_FAMILY_NAMES:String    	= "fnGetAllFamilyNames";
		public static const GET_USERS_AND_POSITIONS:String 	= "fnGetUsersAndPositions";
		public static const GET_SETTINGS:String				= "fnGetSettings"
		public static const GET_PRODUCT_GROUP_TYPES:String	= "fnGetProductGroupTypes"
		public static const GET_APPLY_TO_UOM:String			= "fnGetVolumeApplyToUOM"
			
		
		 
		/* - ******** General Functions/Methods ******* - */

		public static const RESET_FILTERS:String  	 		= "ResetFilters";
		public static const FILTER_PROGRAMS:String   		= "FilterPrograms";
		public static const INITIAL_FUNC:String		 	 	= "InitialFunc";
		public static const FILTER_RESULTS:String 	 		= "filterResults";
		public static const INIT_APP:String			 		= "InitApp";
		public static const BSA_ERROR:String 				= "bsaError";		
		public static const BSA_NO_SERVICE_ERROR:String 	= "bsaNoServiceError";
		public static const ENABLE_SAVE:String 				= "bEnableSave";
	 
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
		public var ePositions:String;
		public var eProgramInfo:String;
 		public var eUserName:String;
 		public var eReportType:String;
 		public var eFileName:String;
 		public var eProgram_Info:String;
		public var eDistributor_Info:String;
		public var eOperator_Info:String;
		public var eItem_Info:String;
		public var volumeAC:ArrayCollection = new ArrayCollection;
		public var dgVolumeDataSet:Array = new Array;
		public var dgVolumeDataEditSet:Array = new Array;
		public var userId:String;
		public var bOpType:String;
		public var appAreaTitle:String;
		//public var appQtyUOMIDX:String;
		//public var appUOMType:String;
		public var volQtyUOMIDX:String;
		public var volUOMType:String;	
		public var appAreaKeyword:String;
		public var appAreaStartDate:String;
		public var appAreaEndDate:String;
		public var appAreaSpanDays:String;
		public var appAreaContractNumber:String;
		public var appProgramID:String;
		public var profileID:String;
		public var appGroupADefault:String;
		public var appGroupBDefault:String;
		public var appPrgMode:String = "VIEW"; // Default value VIEW; possible values "VIEW, EDIT"
		public var appEditMode:String = "EDIT";
		public var appGroupA:String = "CUSTOMER"; // Default value
		public var appGroupB:String = "INV";
		public var bDirectShipmentShow:String;
		public var bBillbackShow:String;
		public var bCreditsShow:String;
		public var strVolumeHelpText:String;
		public var bDetailsDisplay:String; 
		public var programId:String;
		public var arrUserListItems:Array;
		public var userListItemsName:String;
		public var userListId:int;
		public var iList:String;
		public var bOpportunityVolumeShow:Boolean;
		public var nProductGroupLevel:Number = 0;
		public var excludeAutoVolumeUpdates:Boolean;
		public var saveType:String = '2';
		
		
 
		/*-.........................................Contructor..........................................*/
		/**
		 * Constructor for the VolumeApplicatorEvent
		 */ 
		public function VolumeApplicatorEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)		
		{
			super(type, bubbles, cancelable);
		}	
	}
	
}