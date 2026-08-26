package com.Billback.Search.views.pm
{
	import com.Billback.Main.events.BBMainEvent;
	import com.Billback.Main.models.vos.*;
	import com.Billback.Search.events.BBSearchEvent;
	import com.Billback.Search.vos.BBFilterDef;
	import com.Billback.Search.vos.BBFilterParams;
	import com.Billback.Search.vos.BBSearchGridColumnSize;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.external.ExternalInterface;
	import flash.net.*;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ListCollectionView;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.utils.ObjectUtil;
	
	public class BBSearchFiltersPModel extends EventDispatcher
	{
		/*.......................  Constructor  .......................*/
		private var _dispatcher:IEventDispatcher;
		public function BBSearchFiltersPModel( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}
		
		
		
		/*.......................  Properties  .......................*/
		[Bindable]
		public var acData:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var listCollView:ListCollectionView = new ListCollectionView();
		[Bindable]
		public var oSettings:Settings = new Settings();
		//[Bindable (event="drpIxChgPc")] public var StatusIdx:int = 0;
		private var _DefaultOption:int = 0;
		public var userId:String;
		private var bLoadCurrent:Boolean = false;
		private var bRefreshData:Boolean = false;
		public var bGetFavorites:Boolean = false;
		public var bSearchData:Boolean = false;
		public var bClearData:Boolean = false;
		public var bFilterBBForUploadedDocs:Boolean = false;
		private var strListName:String = new String();
		private var strImportItems:String = new String();
		private var arrImportItems:Array = new Array();
		private var arrBBHeader:Array = new Array();
		public var iSelectedIndex:int = 0;
		private var resetSelectedIndex:Boolean = false;
		private var _objBBFilterParams:BBFilterParams = new BBFilterParams();
		
		[Bindable]
		public var dataViewOption:String = new String();
		
		[Bindable]
		public var bBBtypeColumnVisible:Boolean = true;		
		
		[Bindable]
		public var arrUserList:Array = new Array();
		
		//public var arrBillbackIdIntFilter:Array = new Array();
		[Bindable]
		public var objBBFilterParams:BBFilterParams = new BBFilterParams();
		
		[Bindable]
		public var objBBSearchGridColumnSize:BBSearchGridColumnSize = new BBSearchGridColumnSize();
		
		[Bindable]
		public var dSODate:String = new String();
		
		private var arrSelectedStatuses:Array = new Array();
		
		[Bindable]
		public var bshowReAssign:Boolean = false;
		
		[Bindable]
		public var bshowHold:Boolean = false;
		
		[Bindable]
		public var bshowRelease:Boolean = false;
		
		[Bindable]
		public var bshowReset:Boolean = false;
		
		[Bindable]
		public var bshowMassApprove:Boolean = false;
		
		[Bindable]
		public var bshowDelete:Boolean = false;
		
		[Bindable]
		public var intNavListSelectedIndex:int = 0;
		
		[Bindable]
		public var bShowLoadingOptions:Boolean = true;
		
		public var resetType:String = new String('');
		
		[Bindable]
		/* Note: This value is hardcoded twice on this file. */
		public var nHeightContainer:Number = 248;
		
		[Bindable]
		public var nWidthContainer:Number = 1210;
		
		[Bindable]
		public var scorecardStatusID:int = 0;
		
		[Bindable]
		public var iComboBoxContentWidth:int;
		
		/* The below code can be used to set a defaultindex for a dropdown on load. */
		[Bindable (event="drpDefaultOption")]
		public function get DefaultOption():int
		{
			return _DefaultOption;
		}
		
		private var _objLookupData:BBFilterDef;
		[Bindable (event="PMobjLookupDataChanged")]
		public function get objLookupData():BBFilterDef
		{			
			_DefaultOption = 0;
			dispatchEvent(new Event('drpDefaultOption'));
			return _objLookupData;
		}
		
		public function set objLookupData(objLookupData:BBFilterDef):void
		{
			this._objLookupData = objLookupData;
			
			/* In my "filterReset function, I do "objLookupData = objLookupData". This adds this entry again on the dropdown. 
			The below logic is to avoid the duplication of the entry.
			*/
			
			if(this._objLookupData.actionList.indexOf("Select Action for") == -1)
			{
				this._objLookupData.actionList.unshift("Select Action for");
			}
			
			if(this._objLookupData.conditionList.indexOf("Select Conditions") == -1)
			{
				this._objLookupData.conditionList.unshift("Select Conditions");
			}
			
			dispatchEvent(new Event('PMobjLookupDataChanged'));
		}	
		
		private function getStatusList():void
		{    		
			arrSelectedStatuses = new Array();
			
			/* Loop through the "Status object" and populate the arrSelectedStatuses Array
			with the abbreviation from the Status Object.
			*/
			for each(var oStatus:Status in this.objBBFilterParams.statusListSelect)
			{		
				if(oStatus != null)
				{
					arrSelectedStatuses.push(oStatus.description);
				}				
			}			
		}
		
		public function saveBBFilterParams():void
		{	
			getStatusList();
			
			/* Save the user favorites */
			if(bGetFavorites == true)
			{
				var eventFavorites:BBSearchEvent = new BBSearchEvent(BBSearchEvent.SAVE_USER_LIST);
				eventFavorites.eBBFilterParams = this.objBBFilterParams;
				eventFavorites.userId = userId;		
				eventFavorites.euserListItemsName = strListName;	
				this._dispatcher.dispatchEvent(eventFavorites);
				bGetFavorites = false;		
			}
				
				/* Load the "CURRENT" data */
			else if(bLoadCurrent == true)
			{
				var eventLoadCurrent:BBSearchEvent = new BBSearchEvent(BBSearchEvent.LOAD_SO_ITEMS);
				eventLoadCurrent.userId = userId;		
				eventLoadCurrent.eStatus = 0;		
				this._dispatcher.dispatchEvent(eventLoadCurrent);
				bLoadCurrent = false;
			}
				
				/* Call the "REFRESH" data */
			else if(bRefreshData == true)
			{
				var eventRefreshLoad:BBSearchEvent = new BBSearchEvent(BBSearchEvent.LOAD_BB_SEARCH);
				
				eventRefreshLoad.eBBFilterParams = this.objBBFilterParams;
				eventRefreshLoad.userId = userId;
				this._dispatcher.dispatchEvent(eventRefreshLoad);
				bRefreshData = false;		
			}
				
				/* Search for data in "paid" or "approved-void" status. This data is not searchable in the "current" mode, but in "current including paid/void" mode. */
			else if(bSearchData == true)
			{
				var eventLoadArchiveBBSearch:BBSearchEvent = new BBSearchEvent(BBSearchEvent.LOAD_ARCHIVE_BB_SEARCH);
				
				eventLoadArchiveBBSearch.eBBFilterParams = this.objBBFilterParams;
				eventLoadArchiveBBSearch.userId = userId;			
				this._dispatcher.dispatchEvent(eventLoadArchiveBBSearch);				
				bSearchData = false;		
			}
				/* This is used for clear the grid. */
			else if (bClearData == true)
			{
				var eventClearData:BBSearchEvent = new BBSearchEvent(BBSearchEvent.BB_SEARCH_FILTER_DATA);
				eventClearData.eBBFilterParams = this.objBBFilterParams;
				this._dispatcher.dispatchEvent(eventClearData);				
				
				// Reset these variables
				bClearData = false;
				this.objBBFilterParams.clearRecords = false;
			}
				/* This is used to filter records to show only those billbacks where the user attached OR deleted documents. */
			else if (bFilterBBForUploadedDocs == true)
			{
				var eventFilterBBForUploadedDocs:BBSearchEvent = new BBSearchEvent(BBSearchEvent.BB_SEARCH_FILTER_DATA);
				eventFilterBBForUploadedDocs.eBBFilterParams = this.objBBFilterParams;
				this._dispatcher.dispatchEvent(eventFilterBBForUploadedDocs);	
				
				/* Note: We are not resetting the  "bFilterBBForUploadedDocs" variable to "false" here. It gets reset on "updateBBFilterForDocs" function 
				in BBSearchFilters.mxml, when the user clicks on the "options" tab.
				*/
			}
				/* Call fulltext for program and entity search (except vendor which is a local search). Call separate queries for Agreed, Pending Approval and 
				Under Review. When the result are returned, filter the grid results with the results of the query. This is used for remote filtering, i.e. 
				based on results returned from sql server
				*/
			else if(this.objBBFilterParams.programKeyword != '' 
				|| (this.objBBFilterParams.entityKeyword != '' && this.objBBFilterParams.entitySelect != this.oSettings.appFlex.bbLabels.Vendor)
				|| arrSelectedStatuses.indexOf('Agreed') != -1 
				|| arrSelectedStatuses.indexOf('Pending Approval') != -1 
				||
				arrSelectedStatuses.indexOf('Under Review') != -1)
			{
				var eventRemote:BBSearchEvent = new BBSearchEvent(BBSearchEvent.BB_REMOTE_SEARCH_FILTER_DATA); //FILTER USING SQL ON SERVER
				eventRemote.eBBFilterParams = this.objBBFilterParams;			
				this._dispatcher.dispatchEvent(eventRemote);
			}
				
				/* This is used for "Local" Filtering, i.e. filtering on FLEX. */
			else
			{
				var eventLocal:BBSearchEvent = new BBSearchEvent(BBSearchEvent.BB_SEARCH_FILTER_DATA);
				eventLocal.eBBFilterParams = this.objBBFilterParams;
				this._dispatcher.dispatchEvent(eventLocal);
			}
		}
		
		
		public function updatePayableNumber(payableNumber:String):void
		{	
			this.objBBFilterParams.BBCodeKeyword = payableNumber;
		}
		
		public function updateBBNumber(BBNumber:String):void
		{			
			this.objBBFilterParams.BBNumberKeyword = BBNumber;
		}
		
		public function updateCheckNumber(checkNumber:String):void
		{				
			this.objBBFilterParams.checkNoKeyword = checkNumber;
		}
		
		/* set "status" to be used for searching */	
		public function updateStatus(status:Array):void
		{  
			this.objBBFilterParams.statusListSelect = status;
		}
		
		/* set "analyst" to be used for searching */
		public function updateAnalyst(analyst:Array):void
		{  
			this.objBBFilterParams.analystListSelect = analyst;
		}
		
		/* set "user" data to be used for searching */	
		public function updateUser(historyValue:String,user:Array):void
		{  
			this.objBBFilterParams.historySelect = historyValue;
			this.objBBFilterParams.historyUsernameSelect = user;
		}
		
		/* set "bbType" data to be used for searching */	
		public function updateBBType(BBtype:Array):void
		{  
			this.objBBFilterParams.typeListSelect = BBtype;
		}
		
		/* set "closing method" data to be used for searching */
		public function updateClosingMethod(closingMethod:Array):void
		{  
			this.objBBFilterParams.closingMethodSelect = closingMethod;
		}
		
		/* set "payee" data to be used for searching */
		public function updatePayee(payee:String):void
		{  
			this.objBBFilterParams.payeeKeyword = payee;
		}		
		
		/* set "amount" data to be used for searching */		
		public function updateAmountValue(amountType:String,amountCriteria:String,amountValue:String):void
		{
			if(amountValue.length != 0)
			{
				this.objBBFilterParams.amountTypeSelect = amountType;
				this.objBBFilterParams.amountCriteriaSelect = amountCriteria;
				this.objBBFilterParams.amountValueKeyword = new Number(amountValue);
				this.objBBFilterParams.bSearchAmount = true;
			}
			else
			{
				this.objBBFilterParams.amountTypeSelect = '';
				this.objBBFilterParams.amountCriteriaSelect = '';
				this.objBBFilterParams.amountValueKeyword = new Number(null);
				this.objBBFilterParams.bSearchAmount = false;	
			}
			
		}
		
		/* set "start date" data to be used for searching. Length of 10 is date in MM/DD/YYYY format */
		public function updateDateRangeStartValue(dateType:String,dateCriteria:String,dateValue:String):void
		{
			if(dateValue.length == 10)
			{
				this.objBBFilterParams.dateRangeStartTypeSelect = dateType;
				this.objBBFilterParams.dateRangeStartCriteriaSelect = dateCriteria;
				this.objBBFilterParams.dateRangeStartValueKeyword = new Date(dateValue);
				this.objBBFilterParams.bSearchDateRangeStart = true;
			}
			else
			{
				this.objBBFilterParams.dateRangeStartTypeSelect = '';
				this.objBBFilterParams.dateRangeStartCriteriaSelect = '';
				this.objBBFilterParams.dateRangeStartValueKeyword = new Date(null);
				this.objBBFilterParams.bSearchDateRangeStart = false;				
			}
		}
		
		/* set "end date" data to be used for searching. Length of 10 is date in MM/DD/YYYY format */
		public function updateDateRangeEndValue(dateType:String,dateCriteria:String,dateValue:String):void
		{
			if(dateValue.length == 10)
			{
				this.objBBFilterParams.dateRangeEndTypeSelect = dateType;
				this.objBBFilterParams.dateRangeEndCriteriaSelect = dateCriteria;
				this.objBBFilterParams.dateRangeEndValueKeyword = new Date(dateValue);
				this.objBBFilterParams.bSearchDateRangeEnd = true;
			}
			else
			{
				this.objBBFilterParams.dateRangeEndTypeSelect = '';
				this.objBBFilterParams.dateRangeEndCriteriaSelect = '';
				this.objBBFilterParams.dateRangeEndValueKeyword = new Date(null);
				this.objBBFilterParams.bSearchDateRangeEnd = false;				
			}
		}
		
		/* set "condition" data to be used for searching. */
		public function updateConditionsValue(conditionsValue:String):void
		{
			this.objBBFilterParams.conditionSelect = conditionsValue;			
		}
		
		public function updateProgram(program:String):void
		{
			this.objBBFilterParams.programKeyword = program;		
		}
		
		public function updateDuplicateCheck(chkDup:Boolean):void
		{
			this.objBBFilterParams.bChkDuplicate = chkDup;		
		}
		
		/* set "entity" data to be used for searching */
		public function updateEntity(entity:String,entityValue:String):void
		{ 
			this.objBBFilterParams.entitySelect = entity;
			this.objBBFilterParams.entityKeyword = entityValue;	
		}		
		
		/* set "action" data to be used for searching */		 
		public function updateActions(action:String):void
		{
			this.objBBFilterParams.actionSelect = action;
		}		
		
		/* When the user clicks on "search", call saveBBFilterParams */		
		public function updateSearchData():void
		{
			/* Set "current including paid/void" based on "bSearchData" */
			setCurrentIncludingPaid();
			
			saveBBFilterParams();				
		}
		
		/* Call saveBBFilterParams to "Refresh" data. */
		public function updateRefreshData():void
		{
			/* Set "current including paid/void" based on "bSearchData". In this case, it is false */ 
			setCurrentIncludingPaid();
			
			bRefreshData = true;
			saveBBFilterParams();				
		}
		
		/* Call saveBBFilterParams to call the shared object to load saved data. */
		public function loadCurrent():void
		{
			bLoadCurrent = true;
			saveBBFilterParams();
		}
		
		/* Call saveBBFilterParams to clear the "CURRENT" data. */
		public function clearCurrent():void
		{
			bClearData = true;
			
			this.objBBFilterParams.clearRecords =  true;
			saveBBFilterParams();
			
			//this.objBBFilterParams.clearRecords =  false;
		}
		
		/* Getter to set ScrollToIndex to 0 for datagrid scrollbar to reset */
		private var _iScrollToIndex:int;
		[Bindable (event="acScrollToIndex")]		
		public function get scrollToIndex():int
		{
			return _iScrollToIndex;
		}
		
		public function filterReset(brefreshData:Boolean):void
		{			
			
			/* Reset the objBBFilterParams values, when the user does not visit from the scorecard */
			if(this.scorecardStatusID == 0){
				this.objBBFilterParams = new BBFilterParams();	
			}
			
			/* Reset the filters (except textbox values as those values are not a part of objLookupData) */	
			if(resetType != ''){
				/* For resetting dropdowns (I am not sure whether this code is still required or not).
				"this.objBBFilterParams = new BBFilterParams()" should actually reset the dropdowns */
				objLookupData = objLookupData;
			}
			
			/* Set the "actionSelect" property of "objBBFilterParams" to be 'Select Action for' */
			this.objBBFilterParams.actionSelect = 'Select Action for';
			
			/* Hide Reset, Mass Approve, Delete, Release, Hold, Reassign options */
			var eventShowHide:BBSearchEvent = new BBSearchEvent(BBSearchEvent.SHOW_HIDE_CONTROLS);
			eventShowHide.eSearchResultsCount = 0;
			this._dispatcher.dispatchEvent(eventShowHide);
			
			/* Show "loading options" */
			this.bShowLoadingOptions = true;	
			
			/* do not reset the grid when visiting from the scorecard with a status as we need the results filtered by status */
			if(brefreshData == true)
			{
				this.acData.filterFunction = null;
				this.acData.refresh();
				/* The grid's dataprovider is a "ListviewCollection". The grid's dataprovider is a "ListviewCollection". Refresh it too, just to be on the safe side. */
				this.listCollView.refresh();
			}
			
			/* Set the scrollbar position to beginning of the grid - Index = 0 */		
			_iScrollToIndex = 0;	
			
			/* Reset the scrollbar after refreshing data. */		
			dispatchEvent(new Event('acScrollToIndex'));
		}
		
		public function saveUserList(listName:String):void
		{
			/* Limit the favorites entries to 25 */
			if(this.arrUserList.length > 25){
				Alert.show("The limit for the favorites list is 25. Either delete one or edit an existing one.");
			}
			else
			{
				strListName = listName;	  	
				saveBBFilterParams();
			}
		}
		
		/* Call this function to load the BBFilterParams object, which can be passed to saveBBFilterParams to filter favorites data */		 	
		public function getUserListItems(o:Object):void
		{
			/* Check whether the "current including paid/void" option was selected while saving the "favorite". 
			This is used to decide whether to search for paid/approved-void data or not */						
			if(o.currentIncludingPaid == true){
				bSearchData = true;
			}
			
			this.objBBFilterParams = new BBFilterParams(o.BBCodeKeyword,o.BBNumberKeyword,o.programKeyword,o.checkNoKeyword,o.amountTypeSelect,o.amountCriteriaSelect,
				o.amountValueKeyword,o.dateRangeStartTypeSelect,o.dateRangeStartCriteriaSelect,o.dateRangeStartValueKeyword,o.dateRangeEndTypeSelect,
				o.dateRangeEndCriteriaSelect,o.dateRangeEndValueKeyword,o.entitySelect,o.entityKeyword,o.historySelect,o.historyUsernameSelect,o.actionSelect,
				o.conditionSelect,o.statusListSelect,o.closingMethodSelect,o.typeListSelect,o.analystListSelect,o.bSearchDateRangeStart,o.bSearchDateRangeEnd,
				o.bSearchAmount,o.payeeKeyword,o.userBillbackListId,o.userId,o.listName,o.currentIncludingPaid,o.bChkDuplicate);
			saveBBFilterParams();
		}
		
		public function deleteUserList(listID:int):void
		{
			var eventDeleteFavorite:BBSearchEvent = new BBSearchEvent(BBSearchEvent.DELETE_USERLIST);
			eventDeleteFavorite.euserListId = listID;
			this._dispatcher.dispatchEvent(eventDeleteFavorite); 
		}	
		
		public function callCreateList(txt:String):void
		{
			var eventCreateList:BBSearchEvent = new BBSearchEvent(BBSearchEvent.CREATE_LIST);
			eventCreateList.eList = txt;
			this._dispatcher.dispatchEvent(eventCreateList);
		} 	
		
		/* Generate xls file for the datagrid records */
		public function callExportXLS():void
		{					
			var eventExportXLS:BBSearchEvent = new BBSearchEvent(BBSearchEvent.EXPORT_XLS);
			this._dispatcher.dispatchEvent(eventExportXLS);		
		}
		
		/* Populate objBBSearchGridColumnSize object for column width */
		public function setColumnSize(columnHeader:String,columnWidth:int):void
		{	
			if(columnHeader == 'Status'){
				this.objBBSearchGridColumnSize.status = columnWidth;
			}
			
			if(columnHeader == this.oSettings.appFlex.bbLabels.Payable){
				this.objBBSearchGridColumnSize.BBCode = columnWidth;
			}
			
			if(columnHeader == this.oSettings.appFlex.bbLabels.Billback){
				this.objBBSearchGridColumnSize.BBNumber = columnWidth;
			}
			
			if(columnHeader == this.oSettings.appFlex.bbLabels.Title){
				this.objBBSearchGridColumnSize.title = columnWidth;
			}
			
			if(columnHeader == this.oSettings.appFlex.bbLabels.Billback + ' Date'){
				this.objBBSearchGridColumnSize.BBDate = columnWidth;
			}
			
			if(columnHeader == 'Received Date'){
				this.objBBSearchGridColumnSize.BBReceivedDate = columnWidth;
			}
			
			if(columnHeader == this.oSettings.appFlex.bbLabels.Payee){
				this.objBBSearchGridColumnSize.payee = columnWidth;
			}
			
			if(columnHeader == this.oSettings.appFlex.bbLabels.Vendor){
				this.objBBSearchGridColumnSize.vendor = columnWidth;
			}
			
			if(columnHeader == this.oSettings.appFlex.bbLabels.Delivery_Period_Start){
				this.objBBSearchGridColumnSize.startDate = columnWidth;
			}
			
			if(columnHeader == this.oSettings.appFlex.bbLabels.Delivery_Period_End){
				this.objBBSearchGridColumnSize.endDate = columnWidth;
			}
			
			if(columnHeader == this.oSettings.appFlex.bbLabels.Claimed){
				this.objBBSearchGridColumnSize.claimedAmount = columnWidth;
			}
			
			if(columnHeader == 'Approved'){
				this.objBBSearchGridColumnSize.approvedAmount = columnWidth;
			}
			
			if(columnHeader == this.oSettings.appFlex.bbLabels.Closing_Method){
				this.objBBSearchGridColumnSize.closingMethod = columnWidth;
			}	
			
			if(columnHeader == 'More Info'){
				this.objBBSearchGridColumnSize.moreInfo = columnWidth;
			}			
			
			var eventSetColumnSize:BBSearchEvent = new BBSearchEvent(BBSearchEvent.SET_COLUMN_SIZE);
			eventSetColumnSize.eColumnHeader = columnHeader;
			eventSetColumnSize.eColumnWidth = columnWidth;
			this._dispatcher.dispatchEvent(eventSetColumnSize);		
		}
		
		public function saveColumnSize():void
		{			
			var eventSaveColumnSize:BBSearchEvent = new BBSearchEvent(BBSearchEvent.SAVE_ALL_COLUMNS_SIZE);
			
			eventSaveColumnSize.userId = userId;	
			eventSaveColumnSize.eBBSearchGridColumnSize = this.objBBSearchGridColumnSize;
			
			this._dispatcher.dispatchEvent(eventSaveColumnSize);		
		}
		
		/* Call this to delete the selected billbacks */
		public function updateDelete():void
		{			
			this.strImportItems = new String();
			this.arrImportItems = new Array();
			
			for each(var oItem:Object in acData.source)
			{
				if(oItem['isSelected'] == true)
				{
					this.arrImportItems.push(oItem['billbackIDInt']);
				}
				
				this.strImportItems = this.arrImportItems.toString();
			}
			
			DeleteConfirm();
		}
		
		private function DeleteConfirm():void
		{
			var alertResult:Alert;
			
			/* If the user has selected at least one billback */
			if(this.strImportItems.length > 0){           
				alertResult = Alert.show("Do you really want to delete the selected " + this.oSettings.appFlex.bbLabels.Billback +"s?", "Confirm Delete!", Alert.YES | Alert.NO, null, DeleteBB);  
			}  
			else{
				Alert.show("Please select at least one " + this.oSettings.appFlex.bbLabels.Billback + " to delete.");	
			}        
		}
		
		private function DeleteBB(CloseEvent:Object) : void
		{ 
			/* CloseEvent.detail is 1 for "yes" and 2 for "no" */
			if(CloseEvent.detail == 1){
				
				var eventBBDelete:BBSearchEvent = new BBSearchEvent(BBSearchEvent.BB_DELETE);	
				eventBBDelete.userId = userId;		
				eventBBDelete.eBBDelete = this.strImportItems;				
				this._dispatcher.dispatchEvent(eventBBDelete);
				
				//var url:URLRequest = new URLRequest("/billbacks/common/multiple_bb_delete.cfm?BillbackList="+this.strImportItems+"&FromFlex=1");
				//navigateToURL(url, "_self");	          
			}  
		}
		
		/* Call this to reset the selected billbacks */
		public function updateReset():void
		{						
			this.strImportItems = new String();
			this.arrImportItems = new Array();
			
			for each(var oItem:Object in acData.source)
			{
				if(oItem['isSelected'] == true)
				{
					this.arrImportItems.push(oItem['billbackIDInt']);
				}
				
				this.strImportItems = this.arrImportItems.toString();
			}
			
			ResetConfirm();
		}
		
		private function ResetConfirm():void
		{
			var alertResult:Alert;
			/* If the user has selected at least one billback */
			if(this.arrImportItems.length == 1){           
				alertResult = Alert.show("Do you really want to reset this " + this.oSettings.appFlex.bbLabels.Billback + " to Work In Progress status?", "Confirm Reset!", Alert.YES | Alert.NO, null, ResetBB);  
			}  
			else if(this.arrImportItems.length > 1){
				Alert.show("Only one " + this.oSettings.appFlex.bbLabels.Billback + " at a time is allowed to be Reset to WIP");
			}      
			else{
				Alert.show("Please select a " + this.oSettings.appFlex.bbLabels.Billback + " to be Reset to WIP");	
			}  
		}
		
		private function ResetBB(CloseEvent:Object) : void
		{ 
			/* CloseEvent.detail is 1 for "yes" and 2 for "no" */
			if(CloseEvent.detail == 1){
				
				var eventBBReset:BBSearchEvent = new BBSearchEvent(BBSearchEvent.BB_RESET);	
				eventBBReset.userId = userId;		
				eventBBReset.eBBReset = this.strImportItems;				
				this._dispatcher.dispatchEvent(eventBBReset);			         
			}  
		}
		
		/* Call this to reassign the selected billbacks */
		public function updateReassign(reassignToUserList:*):void
		{
			this.objBBFilterParams.reassignBBUserSelect = reassignToUserList;
			
			if(this.objBBFilterParams.reassignBBUserSelect.length == 0)
			{
				Alert.show("Please select an " + this.oSettings.appFlex.bbLabels.Analyst + " to reassign to.");
			}
			else if(this.objBBFilterParams.reassignBBUserSelect.length > 1)
			{
				Alert.show("Please select only one " + this.oSettings.appFlex.bbLabels.Analyst + " to reassign to.");
			}
			else
			{
				
				this.strImportItems = new String();
				this.arrImportItems = new Array();
				
				for each(var oItem:Object in acData.source)
				{
					if(oItem['isSelected'] == true)
					{
						this.arrImportItems.push(oItem['billbackIDInt']);
					}
					
					this.strImportItems = this.arrImportItems.toString();
				}
				
				this.objBBFilterParams.reassignBBUserSelect = reassignToUserList;
				
				ReassignConfirm();
			}
		}
		
		private function ReassignConfirm():void
		{
			var alertResult:Alert;
			
			/* If the user has selected at least one billback */
			if(this.arrImportItems.length > 0){
				alertResult = Alert.show("Do you really want to reassign the selected " + this.oSettings.appFlex.bbLabels.Billback + "s?", "Confirm Reassign!", Alert.YES | Alert.NO, null, ReassignBB);  
			}       
			else{
				Alert.show("Please select a " + this.oSettings.appFlex.bbLabels.Billback + " to be reassigned");	
			}  
		}
		
		private function ReassignBB(CloseEvent:Object) : void
		{ 
			/* CloseEvent.detail is 1 for "yes" and 2 for "no" */
			if(CloseEvent.detail == 1){
				
				var eventBBReassign:BBSearchEvent = new BBSearchEvent(BBSearchEvent.BB_REASSIGN);
				
				eventBBReassign.eBBFilterParams = this.objBBFilterParams;
				eventBBReassign.eBBRessign = this.strImportItems;		
				this._dispatcher.dispatchEvent(eventBBReassign);        
			}  
		}
		/* same function as in BBSearchGridPModel.as but used to create a new BB */
		public function selectBB():void{
			var e:BBMainEvent = new BBMainEvent(BBMainEvent.EDIT_BB);
			var bbH:BBHeader = new BBHeader();
			e.bbHeader = bbH;
			e.payeeList = new Array(bbH.payee);
			e.closingMethodList = objLookupData.closingMethodList; // Send in the closingMethod List too for the edit screen dropdown instead of loading from CF.
			e.bbAnalysts = objLookupData.analystList; // Send in the analysts List too for the edit screen dropdown instead of loading from CF.
			this._dispatcher.dispatchEvent(e);
		}
		
		/* Call this to delete the selected billbacks */
		public function updateSearchAndUploadDocs(type:int):void
		{			
			this.strImportItems = new String();
			this.arrImportItems = new Array();
			
			for each(var oItem:Object in acData.source)
			{
				if(oItem['isSelected'] == true)
				{
					this.arrImportItems.push(oItem['billbackIDInt']);
				}
				
				this.strImportItems = this.arrImportItems.toString();
			}
			
			searchAndUploadDocsConfirm(type);
		}
		
		/* The user should select at least one billback before uploading or deleting documents */
		private function searchAndUploadDocsConfirm(type):void
		{
			var alertResult:Alert;
			
			/* If the user has selected at least one billback */
			if(this.arrImportItems.length == 0){          
				Alert.show("Please select at least one " + this.oSettings.appFlex.bbLabels.Billback);
			}  
			else{
				searchAndUploadDocs(type);
			}        
		}
		
		/* Open a popup where the user can upload and search documents. Deleting is not allowed from here as this is for multiple billbacks. To delete any document, the user
		needs to visit this page from inside a billback
		*/
		private function searchAndUploadDocs(type) : void
		{ 	
			var currentAppName:String = FlexGlobals.topLevelApplication.toString();
			var winjscommand:String;
			
			if (ExternalInterface.available)
			{
				ExternalInterface.addCallback("saveDocs", saveDocs);
				
				/* upload documents */
				if(type == 1)
				{
					winjscommand ="/BillbackID_Wrapper.cfm?FormName=flex&FlexAppName="+currentAppName+"&BillbackList="+this.strImportItems+"&Page_Relocate=/common_files/documents/create_multiple_document_details.cfm";	
				}
					/* search documents */
				else
				{
					winjscommand ="/BillbackID_Wrapper.cfm?FormName=flex&FlexAppName="+currentAppName+"&BillbackList="+this.strImportItems+"&Page_Relocate=/billbacks/capture/Attachments_Form.cfm";
					
				}
				var jscommand:String = "window.open('"+winjscommand+"','winPrint','height=600,width=810,toolbar=no,scrollbars=yes,left=0,top=0,screenX=0,screenY=0,resizable=no');"   
				var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");   
				navigateToURL(url, "_self");
			}
		}
		
		/* Get a list of Billback_ID_Int after it is returned from the popup page and then filter the grid with just those records. */
		public function saveDocs(BillbackList:String):void {
			
			bFilterBBForUploadedDocs = true;
			
			/* Get the updated bbheader(s) and reload it on "BB Search" */
			var e:BBSearchEvent = new BBSearchEvent(BBSearchEvent.GET_UPDATED_BB_HEADER_LIST);
			e.ebillbackIDIntList = BillbackList;//int(i);  
			this._dispatcher.dispatchEvent(e);	
			
			
			for each(var i:String in BillbackList.split(","))			
			{	/* Populate "this.objBBFilterParams.BBIDIntList". */
				this.objBBFilterParams.BBIDIntList.push(int(i));
			}
			
			/* Filter by only those billbacks for which documrnt has been uploaded. */
			saveBBFilterParams();
		}
		
		/* Create an array of BBHeader and use it for Mass Aproval */
		public function updateMassApprove():void
		{			
			this.arrBBHeader = new Array();
			
			for each(var oItem:BBHeader in acData.source)
			{
				if(oItem['isSelected'] == true)
				{
					this.arrBBHeader.push(oItem);
				}
			}
			
			massApproveConfirm();
		}
		
		/* The user should select at least one billback before mass approving a billback */
		private function massApproveConfirm():void
		{
			var alertResult:Alert;
			
			/* If the user has selected at least one billback */
			if(this.arrBBHeader.length > 0){           
				alertResult = Alert.show("Do you really want to approve the selected " + this.oSettings.appFlex.bbLabels.Billback + "s?", "Confirm Mass Approve!", Alert.YES | Alert.NO, null, massApprove);  
			}       
			else{
				Alert.show("Please select a " + this.oSettings.appFlex.bbLabels.Billback + " to be approved");	
			}     
		}
		
		/* Mass Approve billback. */
		private function massApprove(CloseEvent:Object) : void
		{ 
			/* CloseEvent.detail is 1 for "yes" and 2 for "no" */
			if(CloseEvent.detail == 1){
				
				/* call event for Mass Approval */
				var eventBBMassApprove:BBSearchEvent = new BBSearchEvent(BBSearchEvent.MASS_APPROVE_BILLBACKS);
				
				/* Array of BBHeader */
				eventBBMassApprove.eArrBBHeader = this.arrBBHeader;
				
				/* Here '0' is the balance amount (balance amount has to be zero) and 'approve' is the action. */
				var bbSA:BBSettlementAction = new BBSettlementAction(0,'approve');
				
				eventBBMassApprove.eBBApprovalAction = bbSA;
				this._dispatcher.dispatchEvent(eventBBMassApprove);		 
			}  
		}
		
		private function setCurrentIncludingPaid():void
		{ 		
			/* If the user is searching for "current including paid/void" data */
			if(bSearchData == true){	
				this.objBBFilterParams.currentIncludingPaid = true;
			}
			else{
				this.objBBFilterParams.currentIncludingPaid = false;
			}
		}
		
		/* Adjust the height of the top section of the bb search screen, i.e. the filters section. */
		public function setFilterScreenHeight(bType:Boolean):void
		{ 		
			if(bType == true){	
				/* increase height */
				this.nHeightContainer = 275;
			}
			else{
				/* original height */
				/* Note: This value is hardcoded twice on this file - Once at the top of this file. */
				this.nHeightContainer = 248;
			}
		}
	}
}