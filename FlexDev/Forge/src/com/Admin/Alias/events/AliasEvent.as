package com.Admin.Alias.events
{
	import com.Admin.Alias.models.vos.AliasDef;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	public class AliasEvent extends Event
	{
		
		/*-.........................................Constants..........................................*/
		public static const LOAD_DISTRIBUTOR_ALIAS:String = "loadDistributorAliasEvent";
		public static const LOAD_ITEM_ALIAS:String = "loadItemAliasEvent";
		public static const LOAD_PROGRAM_ALIAS:String = "loadProgramAliasEvent";
		public static const LOAD_OPERATOR_ALIAS:String = "loadOperatorAliasEvent";
		public static const SET_USER_ID:String = "setUserIdEvent";
		public static const BSA_ERROR:String = "bsaError";
		public static const BSA_NO_SERVICE_ERROR:String = "bsaNoServiceError";
		public static const ALIAS_LOAD_APP_SETTINGS:String = "AliasLoadAppSettings";
		public static const SEARCH_ITEMS:String = "searchItems";
		public static const SET_SELECTED_ALIAS:String = "setSelectedAlias";
		public static const SAVE_ALIAS:String = "saveAlias";
		public static const SET_SOURCE:String = "setSource";
		public static const GET_DISTRIBUTOR_INFO:String = "getDistributorInfo";
		public static const GET_ITEM_INFO:String = "getItemInfo";
		public static const GET_PROGRAM_INFO:String = "getProgramInfo";
		public static const GET_OPERATOR_INFO:String = "getOperatorInfo";
		public static const GET_SOURCE_INFO:String = "getSourceInfo";
		public static const RESET_ALIAS_SELECTED:String = "resetAliasSelected";
		public static const LOAD_SOURCE_SEARCH:String = "loadSourceSearch";
		public static const LOAD_PAYEE:String = "loadPayee";
		public static const LOAD_DISTRIBUTOR_SEARCH:String = "loadDistributorSearch";
		public static const LOAD_ITEM_SEARCH:String = "loadItemSearch";
		public static const LOAD_PROGRAM_SEARCH:String = "loadProgramSearch";
		public static const LOAD_OPERATOR_SEARCH:String = "loadOperatorSearch";
		public static const SHOW_UNASSIGNED_ALIASES:String = "showUnassignedAliases";
		public static const SET_SHOW_UNASSIGNED_ALIASES:String = "setShowUnassignedAliases";
		public static const SHOW_IGNORE_ALIASES:String = "showIgnoreAliases";
		public static const SET_SHOW_IGNORE_ALIASES:String = "setShowIgnoreAliases";
		public static const GET_SOURCE_TYPES:String = "getSourceTypes";
		public static const DISABLE_ENABLE_PAYEE:String = "disableEnablePayee";
		public static const CHANGE_DATA_PROVIDER:String = "changeDataProvider";
		public static const CHANGE_DATA_GRID:String = "changeDataGrid";
		public static const EXPORT_XLS:String = "exportXLS";
		public static const SET_INITIAL_FOCUS:String = "setInitialFocus";
		public static const LABEL_CHANGE:String = "LabelChange";	
		
		// this will be used to remove the filter on the DataGrid when ever the tab is changed
		public static const RESET_INITIAL_FILTER:String = "resetInitialFilter";
		public static const SAVE_SELECTED_ALIAS:String = "saveSelectedAlias";
		public static const RELOAD_CURRENT_DATA:String = "reloadCurrentData";
		public static const SHOW_HIDE_ADDRESS_COLS:String = 'showHideAddressCols';
		public static const UNCHECK_SELECTED:String = 'uncheckSelected';
		public static const ASSIGN_ALL_UNASSIGNED_DISTRIBUTORS:String = "assignAllUnassignedDistributors";	
		public static const IGNORE_ALL_UNIGNORED:String = "ignoreAllUnIgnored";	
		public static const IMPORT_ALIAS_LIST:String = "importAliasList";


		/*-.........................................Properties..........................................*/
		
		public var settings:Settings;
		public var userId:String;
		public var BBId:String;
		public var programId:int;
		public var appSettings:Object;
		public var oBaError:Object;
		public var sBaError:String;
		public var sState:String;
		public var aliasDef:AliasDef;	
		public var sDistributorID:String;
		public var sItemID:String;
		public var sProgramID:String;
		public var sOperatorID:String;
		public var bIsDistGUID:Boolean;
		public var bIsItemGUID:Boolean;
		public var bIsContractNumber:Boolean;
		public var bIsLegacyID:Boolean;		
		public var bShowUnassigned:Boolean;
		//public var bShowIgnore:Boolean;
		public var iShowIgnore:int;
		public var bShowAddressCols:Boolean;
		public var sSourceID:String;
		public var sSourceType:String;
		public var iSourceType:int;
		public var iEntityType:int;
		public var iDataProviderIndex:int;
		public var sUseSearchTool:String;
		public var iSelectedTab:int;
		public var sDataGridType:String;
		public var sAliasList:String;
		public var labelText1:String;
		//Do not remove the two below
		public var sAssignDistributorID:String;
		public var sAssignDistributorDesc:String;
		public var aliasRowsSelected:ArrayCollection;
		/*-.........................................Contructor..........................................*/
		public function AliasEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}	
	}
	
}