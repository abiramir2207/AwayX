package com.Billback.Search.models
{
	import com.Billback.Main.events.BBMainEvent;
	import com.Billback.Main.models.vos.*;
	import com.Billback.Search.events.BBSearchEvent;
	import com.Billback.Search.views.BBSearchGrid;
	import com.Billback.Search.views.MassApproveList;
	import com.Billback.Search.views.UserItemLists;
	import com.Billback.Search.vos.BBFilterDef;
	import com.Billback.Search.vos.BBFilterParams;
	import com.Billback.Search.vos.BBSearchGridColumnSize;
	import com.shared.components.StringUtils;
	import com.shared.models.entity.vos.User;
	import com.shared.vos.Settings;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ListCollectionView;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	import mx.utils.ObjectUtil;
	
	
	public class BBSearchManager extends EventDispatcher 
	{
		/*-...................................... Constructor.......................................*/
		private var _dispatcher:IEventDispatcher;
		public function BBSearchManager( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}
		
		/*.......................................  Properties  ......................................*/
		/*.................oSettings......................*/
		public var oSettings:Settings = new Settings();
		/*.................acData......................*/
		private var _acData:ArrayCollection = new ArrayCollection();
		private var _objLookupData:BBFilterDef = new BBFilterDef();
		private var _objBBFilterParams:BBFilterParams = new BBFilterParams();
		//private var _objBBHeader:BBHeader = new BBHeader();
		//private var _objBBDetails:BBDetails = new BBDetails();
		//private var _arrBBDetails:Array = new Array();
		private var _objBBSearchGridColumnSize:BBSearchGridColumnSize =  new BBSearchGridColumnSize();	
		public var arrBillbackIdIntFilter:Array = new Array();			
		public var sharedObj:SharedObject;
		public var _soItems:SharedObject;
		public var _dSOlastSavedDate:Date = new Date(null);
		private var _dTodayDate:Date = new Date();
		private var bShowPaidStatusMessage:Boolean = true;
		public var arrValidItems:Array = new Array();
		public var arrInValidItems:Array = new Array();
		public var arrItemsToAdd:Array = new Array();
		public var popUp:UserItemLists;
		public var popUpMassApprove:MassApproveList;
		private var arrFilterBBForUploadedDocs:Array = new Array();
		private var arrSelectedStatuses:Array = new Array();
		private var _acDataTemp:ArrayCollection = new ArrayCollection();
		private var bGetSearch:Boolean = false;
		private var bNonPaidBBList:Boolean = false;
		private var _dataViewOption:String;		
		private var objScorecardStatus:Status = new Status();
		private var scorecardBBFilterParams:BBFilterParams =  new BBFilterParams();
		
		[Bindable]
		public var _listCollView:ListCollectionView;
		
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
		public var bShowLoadingOptions:Boolean = false;
		
		[Bindable]
		public var intNavListSelectedIndex:int = 0;
		
		private var arrStatus:Array = new Array();
		
		private var bFromSearch:Boolean = true;
		
		private var bDataLookupLoadComplete:Boolean = false;
		private var bGridDataLoadComplete:Boolean = false;
		
		private var _scorecardStatusID:int = 0;
		
		// for xls export and file download
		private var downloadFileRef:FileReference = new FileReference();
		
		
		[Bindable (event="acDataChanged")]
		public function get acData():ArrayCollection
		{
			return _acData;
		}
		public function set acData(acData:ArrayCollection):void
		{
			this._acData = acData;
			dispatchEvent(new Event('acDataChanged'));
			this._listCollView = new ListCollectionView(acData);			
			dispatchEvent(new Event('listCollViewChanged'));
		}
		
		[Bindable (event="listCollViewChanged")]
		public function get listCollView():ListCollectionView
		{
			return _listCollView;
		}	
		public function set listCollView(listCollView:ListCollectionView):void
		{
			this._listCollView = listCollView;
			dispatchEvent(new Event('listCollViewChanged'));
		}
		
		[Bindable (event="objLookupDataChanged")]
		public function get objLookupData():BBFilterDef
		{
			return _objLookupData;
		}
		public function set objLookupData(objLookupData:BBFilterDef):void
		{
			// Dev Note: KAL; 31075; Flex BB - remove 'reinstate' as closing method
			if(objLookupData.closingMethodList.length){
				var nPos:Number; 
				//loop and find reinstate and remove it
				for each(var oClosingMethod:ClosingMethod in objLookupData.closingMethodList){
					if(oClosingMethod.id == 10){
						nPos = objLookupData.closingMethodList.indexOf(oClosingMethod);
						break;
					}
				}
				if(!isNaN(nPos)){objLookupData.closingMethodList.splice(nPos, 1);}				
			}
			this._objLookupData = objLookupData;
			dispatchEvent(new Event('objLookupDataChanged'));
		}	
		
		[Bindable (event="objFilterParamsChanged")]
		public function get objBBFilterParams():BBFilterParams
		{
			return _objBBFilterParams;
		}
		public function set objBBFilterParams(objBBFilterParams:BBFilterParams):void
		{
			this._objBBFilterParams = objBBFilterParams;
			dispatchEvent(new Event('objFilterParamsChanged'));
		}
		
		[Bindable (event="dataViewOptionChanged")]
		public function get dataViewOption():String
		{
			return _dataViewOption;
		}
		public function set dataViewOption(dataViewOption:String):void
		{
			this._dataViewOption = dataViewOption;
			dispatchEvent(new Event('dataViewOptionChanged'));
		}
		
		[Bindable (event="scorecardStatusIDChanged")]
		public function get scorecardStatusID():int
		{
			return _scorecardStatusID;
		}
		public function set scorecardStatusID(scorecardStatusID:int):void
		{
			this._scorecardStatusID = scorecardStatusID;
			dispatchEvent(new Event('scorecardStatusIDChanged'));
		}
		
		[Bindable (event="objBBSearchGridColumnSizeDataChanged")]
		public function get objBBSearchGridColumnSize():BBSearchGridColumnSize
		{
			return _objBBSearchGridColumnSize;
		}
		
		public function set objBBSearchGridColumnSize(objBBSearchGridColumnSize:BBSearchGridColumnSize):void
		{
			this._objBBSearchGridColumnSize = objBBSearchGridColumnSize;
			dispatchEvent(new Event('objBBSearchGridColumnSizeDataChanged'));
		}	
		
		/*-..
		/*-.........................................Methods..........................................*/
		public function test(x:*):void{
			Alert.show('here: '  + ObjectUtil.toString(x) );
			
		}
		
		public function dataResults(arr:Array,userId:String):void{
			
			if( arr is Array )
			{
				this.acData = new ArrayCollection(arr);
				
				/*Save Shared Object */
				this.saveSOitems();
				
				/* If the user visits from the scorecard and the status is NOT (PAID or APPROVED-VOID). */
				if(this.scorecardStatusID != 0 && (this.scorecardStatusID != 5 && this.scorecardStatusID != 8)){
					scorecardFilterByStatus();
					
					/* The grid data load is complete */
					bGridDataLoadComplete = true;
					
					/* To reset the scorecard variables, we have to make sure that the grid data has been loaded and the lookup data has been loaded.
					Once these are loaded, the data is filtered using the status and the dropdown has that status selected. Once this has been done,
					then reset the scorecard variables */
					if(bDataLookupLoadComplete == true){
						resetScorecardVariables();
					}
				}
					/* This code will be called when the user visits from the scorecard using the paid or approved-void status, provided the shared object did not exist from
					before, i.e. when the user's first visit to the billback grid is through the scorecard using the PAID or Approved Void status. When the user has already 
					visited the grid once during the day, then the shared object remains all day and so clicking on "paid" again will not execute the code below. */
				else if(this.scorecardStatusID == 5 || this.scorecardStatusID == 8){
					var eventLoad1:BBSearchEvent = new BBSearchEvent ( BBSearchEvent.LOAD_ARCHIVE_BB_SEARCH );							
					eventLoad1.eBBFilterParams = this.scorecardBBFilterParams;
					eventLoad1.userId = userId;		
					
					this._dispatcher.dispatchEvent( eventLoad1 );
				}	
					
				else{
					additionalActions(true);
				}
			}			
		}
		
		public function dataArchiveResults(arr:Array,o:BBFilterParams):void{
			/* If the count of billback records is beyond what we allow to return */
			if(arr[0].billbackIDInt == -1)
			{
				Alert.show("The number of records for the search is beyond the maximum that can be returned. Please restrict your search using search conditions.");	
			}	 
			else
			{
				if( arr is Array)
				{					
					/* When the user searches by "current incuding paid" option OR when the user visits the search tool from the scorecard using the "paid" option */
					/* This array has billbacks in "paid" status only. */
					if(arr.length){
						
						deleteBillbackInOldStatus(arr);
						
						/* SCORECARD: If the user visits from the scorecard and the status is PAID or APPROVED-VOID. */
						if(this.scorecardStatusID == 5 || this.scorecardStatusID == 8){
							scorecardFilterByStatus();
							additionalActions(true);
							
							/* The grid data load is complete */
							bGridDataLoadComplete = true;
							
							/* To reset the scorecard variables, we have to make sure that the grid data has been loaded and the lookup data has been loaded.
							Once these are loaded, the data is filtered using the status and the dropdown has that status selected. Once this has been done,
							then reset the scorecard variables */
							if(bDataLookupLoadComplete == true){
								resetScorecardVariables();
							}
						}
							/* FROM INSIDE SEARCH TOOL: When the user searches by "current incuding paid" option */
						else{
							
							
							/* Get a list of statuses that the user is searching on.*/
							getStatusList(o);
							
							/* If any of the following options is selected, then send the request to sql to filter the "current" dataset */
							if(o.programKeyword != '' 
								|| (o.entityKeyword != '' && o.entitySelect != this.oSettings.appFlex.bbLabels.Vendor)
								|| arrSelectedStatuses.indexOf('Agreed') != -1 
								|| arrSelectedStatuses.indexOf('Pending Approval') != -1 
								||
								arrSelectedStatuses.indexOf('Under Review') != -1)
							{
								
								var eventRemote:BBSearchEvent = new BBSearchEvent(BBSearchEvent.BB_REMOTE_SEARCH_FILTER_DATA); //FILTER USING SQL ON SERVER
								eventRemote.eBBFilterParams = o;			
								this._dispatcher.dispatchEvent(eventRemote);	
							}
								/* Do a local filter of the "current" dataset */
							else
							{
								var eventLocal:BBSearchEvent = new BBSearchEvent(BBSearchEvent.BB_SEARCH_FILTER_DATA);
								eventLocal.eBBFilterParams = o;
								this._dispatcher.dispatchEvent(eventLocal);	
							}
							
							/* Sort the data in flex */
							additionalActions(false);
						}
					}
					else{	
						/* No records */				
						this.acData = new ArrayCollection(new Array());
					}
				}
			}
		}
		
		/* When billback is deleted from the edit screen */
		public function deleteBillback(arr:Array):void{
			
			var iCounter:int = -1;
			
			for each( var objItem:Object in this._soItems.data.billbackList.source)
			{	
				iCounter = iCounter + 1;
				
				for each(var oItem:Object in arr)
				{
					if(oItem['billbackIDInt'] == objItem['billbackIDInt'])
					{	
						/* Delete the billback from the shared object */
						this._soItems.data.billbackList.source.splice(iCounter,1);
					}
				}
			}
			
			/* The datasource without the deleted billback */
			this._acDataTemp = new ArrayCollection(this._soItems.data.billbackList.source);			
			bGetSearch = true;		
		}
		
		public function deleteBillbackInOldStatus(arr:Array):void{
			
			var iCounter:int = -1;
			
			/* 	Dev Note - (30219/30427/31468 - Milan) -
			- The user clicks on "search billbacks" to get a list of billbacks for the first time during the day.
			- Since the user views the "current" view by default, those billbacks will be in non-paid status, eg:"payment request" or any other status.
			- Later in the day, one or more of those billbacks could be set to "PAID" status. 
			- Now, when the user selects "current including paid/void" option and searches for data then the following happens:
			- The billbacks in "NON PAID" status (billbacks retrieved in current mode) merge with the billbacks in "PAID" status.
			- The above action will cause those billbacks that have changed to "PAID" status during the day to cause duplicate records due
			to merging of datasets. So the resultset will have 2 records for the same billback - one in "PAID" and one in "NON-PAID".
			- The code here deletes the billback in "NON-PAID" status from the shared object, if that billback now exists in the "PAID" status. */
			
			/* 	Note: When we have a billback in a certain status on flex grid and later when the billback's status changes eg:(WIP to RFA), the new bbheader 
			gets returned from CF to flex and so another record for the same bb but a newer status gets added to the bb grid. The code below will only keep 
			the record from the latest status. */
			
			/* 	Whenever a user clicks on "save" on the billback edit page or clicks on "approve" or "agree" on the billback settlement page, 
			CF returns the updated header and so this code will get called for those requests too. */
			for each( var objItem:Object in this._soItems.data.billbackList.source)
			{	
				iCounter = iCounter + 1;
				
				for each(var oItem:Object in arr)
				{
					if(oItem['billbackIDInt'] == objItem['billbackIDInt'])
					{
						this._soItems.data.billbackList.source.splice(iCounter,1);
					}
				}
			}
			
			/* 	If there are no records for billbacks in PAID status, make the "Shared Object" as the dataset. 
			Note:This condition should not be executed for non-paid billbacks */
			if(arr[0].billbackIDInt == 0)
			{
				this._acDataTemp = new ArrayCollection(this._soItems.data.billbackList.source);
				
			}
				/* Take the "CURRENT" data from the "Shared Object" and append the results of the search (arr) to it. */
			else
			{
				this._acDataTemp = new ArrayCollection(arr.concat(this._soItems.data.billbackList.source));
			}
			
			bGetSearch = true;		
		}
		
		/* remove items not in this billback list */
		/*
		public function validateBillbacks(arr:Array):void 
		{
		var idx:int = 0;
		var counter:int = -1;
		var iPLen:int = arr.length;
		var iItmLen:int = this._soItems.data.billbackList.source.length;
		var arrCopy:Array = this.clone(this._soItems.data.billbackList.source);
		
		
		for each(var i:* in arrCopy)
		{								
		if(idx == arr.length || arr[idx].billbackIDInt != i['billbackIDInt'])
		
		if(arr[idx].billbackIDInt == i[idx].billbackIDInt)
		{
		this._soItems.data.billbackList.source.splice(idx,1);
		}
		idx++;
		}
		//arrCopy = new Array();
		}
		*/
		
		/*
		private function clone(source:Object):* 
		{ 
		var myBA:ByteArray = new ByteArray(); 
		myBA.writeObject(source); 
		myBA.position = 0; 
		return(myBA.readObject()); 
		}
		*/	
		
		private function getStatusList(bbFilterParams:BBFilterParams):void
		{    		
			arrSelectedStatuses = new Array();
			
			/* Loop through the "Status object" and populate the arrSelectedStatuses Array
			with the abbreviation from the Status Object.
			*/
			for each(var oStatus:Status in bbFilterParams.statusListSelect)
			{		
				if(oStatus != null)
				{
					arrSelectedStatuses.push(oStatus.description);
				}				
			}			
		}
		
		/* When the "details" info is returned from the DB, add the details info to the "details" property
		on the BBHeader. "selectedHeader" is the row selected on the datagrid.
		*/
		public function showBBDetails(objBBDetails:BBDetails):void
		{
			selectedBBHeader.details = objBBDetails;
		}
		
		private var _selectedBBHeader:BBHeader = new BBHeader();
		[Bindable (event="sSelectedBBHeaderChanged")]
		public function get selectedBBHeader():BBHeader
		{
			return _selectedBBHeader;
		}
		
		public function set selectedBBHeader(bbh:BBHeader):void
		{
			_selectedBBHeader = bbh;
			dispatchEvent(new Event('sSelectedBBHeaderChanged'));
		}
		
		/* When the user clicks on any row on the datagrid, then we need to know which row was clicked. selectedBBHeader
		is the selected row.
		*/
		public function setSelectedBBHeader(bbh:BBHeader):void
		{
			for each(var bbhDp:BBHeader in this.acData){
				if(bbh){
					if(bbhDp.billbackIDInt == bbh.billbackIDInt){
						this.selectedBBHeader = bbhDp;
						break;
					}
				}
			}
		}
		
		private function saveSOitems():void
		{
			var d:Date = new Date();			
			this._soItems.data.dSavedDate = d;
			this._soItems.data.billbackList = this.acData;
			
			/* If the shared object does not exist, then write the data to it. */		 
			if(!this._soItems.data.customObject)
			{
				this._soItems.flush(10000000);
			}		 	
			this._dSOlastSavedDate = d;		  		
			dispatchEvent(new Event('eSOlastSavedDate'));
			//Alert.show("saved::" + this._soItems.data.dSavedDate;
			/*  W2k3 Path ex.-> C:\Users\mmushran\AppData\Roaming\Macromedia\Flash Player\#SharedObjects\8ZJB3N24\#localhost */
			//strAlertMessage += "saveSOitems()\n";
			// Alert.show(strAlertMessage);	
		}
		
		/**
		 * Get the saved date of the shared object
		 * This function is bound to event 'eSOlastSavedDate'
		 */			
		[Bindable (event="eSOlastSavedDate")]
		public function get dSOlastSavedDate():String
		{
			var s:String;
			s = StringUtils.getUSDate(_dSOlastSavedDate);
			s = s + ' ' + StringUtils.getUSClockTime(_dSOlastSavedDate.getHours(), _dSOlastSavedDate.getMinutes());
			return s;
		}
		
		/* userId:String */
		public function loadSOitems(userId:String,status:int):void
		{	
			/* Set the status */
			this.scorecardStatusID = status;
			
			/* If the user us visting from the scorecard using a status and the status is not already set */
			if(this.scorecardStatusID != 0 && this.objScorecardStatus.id == 0){
				setStatusForScorecardSearch();
			}
			
			/* "current" or "current including paid/approved-void" */
			var eventDataViewOption:BBSearchEvent = new BBSearchEvent (BBSearchEvent.DATA_VIEW_OPTION);
			eventDataViewOption.eStatus = this.scorecardStatusID;
			this._dispatcher.dispatchEvent(eventDataViewOption);
			
			// 1.) go get our SO
			this.setdSOlastSavedDate(userId);
			var strAlertMessage:String = "";
			
			// 2.) if we got a keeper
			if (this._soItems.size)
			{
				// 3.) if we have a saved date
				//moved into setdSOlastSavedDate()
				// 4.) if our 'up to date' dSOlastSavedDate is the same DATE (not 24 hour and not hr/min) as today (dTodayDate), proceed					
				
				if(	( this._dSOlastSavedDate.getFullYear() == this._dTodayDate.getFullYear() ) && 
					( this._dSOlastSavedDate.getMonth() == this._dTodayDate.getMonth() ) &&
					( this._dSOlastSavedDate.getDate() == this._dTodayDate.getDate() ) )
				{
					if( ( this._soItems.data.billbackList != undefined ) &&
						( this._soItems.data.billbackList != null ) &&
						( this._soItems.data.billbackList.length >= 0 ) )
					{
						// 5.) this._itemList from so
						this.acData = _soItems.data.billbackList as ArrayCollection;
						//this.itemResults(_soItems.data.acItems as ArrayCollection);
						//this.updFilters();
						
						/* If the user visits from the scorecard from a particular billback status, then
						when the user selects any other option from the data view dropdown,
						and then reselects "Current", we only see the original status filtered records
						without using "this._acData.filterFunction = null;"
						*/						
						this.acData.filterFunction = null;
						//this.acData.refresh();			
						//dispatchEvent(new Event('objLookupDataChanged'));
						//dispatchEvent(new Event('acDataChanged'));
						
						/* Filter by Status Passed from the scorecard */
						//FilterByStatus();
						
						/* If there are any previously checked items in the shared object, uncheck them */
						var eventUncheckSelected:BBSearchEvent = new BBSearchEvent(BBSearchEvent.UNCHECK_SELECTED);
						this._dispatcher.dispatchEvent(eventUncheckSelected);
						
						/* If the request is NOT from the scorecard */
						if(this.scorecardStatusID == 0){
							additionalActions(true);
						}
						
						/* If the user visits by the scorecard and the status is neither PAID nor APPROVED-VOID.*/
						if(this.scorecardStatusID != 0 && (this.scorecardStatusID  != 5 && this.scorecardStatusID  != 8)){
							scorecardFilterByStatus();
							bGridDataLoadComplete = true;
						}		
						
						/* If the user visits from the scorecard and the status is either PAID or APPROVED-VOID. */
						if(this.scorecardStatusID == 5 || this.scorecardStatusID == 8){
							var eventLoad:BBSearchEvent = new BBSearchEvent ( BBSearchEvent.LOAD_ARCHIVE_BB_SEARCH );							
							eventLoad.eBBFilterParams = this.scorecardBBFilterParams;
							eventLoad.userId = userId;		
							
							this._dispatcher.dispatchEvent( eventLoad );
						}						
						
						//strAlertMessage += "sent incoming SO to itemResults() from loadSOitems()\n";
						//Alert.show("data from SO::" + this._soItems.data.dSavedDate + '   :::   ' + new Date());
					}
					else
					{
						// a.) go get the items from the db
						//dispatchSearchEventGet(ArchiveYear,userId,showCatalog);
						//Alert.show(this._soItems.data.dSavedDate + ': a   ');
						var eventLoad1:BBSearchEvent = new BBSearchEvent ( BBSearchEvent.LOAD_BB_SEARCH );
						//this.objBBFilterParams.refreshData = false;
						
						eventLoad1.eBBFilterParams = this.objBBFilterParams;
						/* Without "currentIncludingPaid = false", when the user visits from the scorecard using the "paid" status (first request of the day), the
						request below has "currentIncludingPaid = true". This brings up incorrect data. */
						eventLoad1.eBBFilterParams.currentIncludingPaid = false;
						eventLoad1.userId = userId;		
						this._dispatcher.dispatchEvent( eventLoad1 );
					}
				}
				else
				{
					// b.) go get the items from the db
					//dispatchSearchEventGet(ArchiveYear,userId,showCatalog);  
					//Alert.show(this._soItems.data.dSavedDate + ': b   ');	
					//Alert.show('333');
					var eventLoad2:BBSearchEvent = new BBSearchEvent ( BBSearchEvent.LOAD_BB_SEARCH );
					//this.objBBFilterParams.refreshData = false;
					
					eventLoad2.eBBFilterParams = this.objBBFilterParams;
					/* Without "currentIncludingPaid = false", when the user visits from the scorecard using the "paid" status (first request of the day), the
					request below has "currentIncludingPaid = true". This brings up incorrect data. */
					eventLoad2.eBBFilterParams.currentIncludingPaid = false;
					eventLoad2.userId = userId;			
					this._dispatcher.dispatchEvent( eventLoad2 );	
				}
			}	
			else
			{
				// c.) go get the items from the db
				//dispatchSearchEventGet(ArchiveYear,userId,showCatalog);
				//Alert.show(this._soItems.data.dSavedDate + ': c  ');
				var eventLoad3:BBSearchEvent = new BBSearchEvent ( BBSearchEvent.LOAD_BB_SEARCH );
				//this.objBBFilterParams.refreshData = false;   				
				
				eventLoad3.eBBFilterParams = this.objBBFilterParams;
				/* Without "currentIncludingPaid = false", when the user visits from the scorecard using the "paid" status (first request of the day), the
				request below has "currentIncludingPaid = true". This brings up incorrect data. */
				eventLoad3.eBBFilterParams.currentIncludingPaid = false;
				eventLoad3.userId = userId;
				this._dispatcher.dispatchEvent( eventLoad3 );
			}	
			
		}
		
		public function SortGridData():void
		{			
			var bScorecardSortMethod:Boolean;
			var bCaseInsensitive:Boolean;
			
			if(this.oSettings.cfApp_scorecardsortmethod == "ASC"){
				bScorecardSortMethod = false;
			}
			else{
				bScorecardSortMethod = true;
			}
			
			/* If the sort is on any date field, make CaseInsensitive as false. If it is set as true, then the records do not get sorted as date */
			if(this.oSettings.cfApp_scorecardsortoption == "BBDate" 
				|| this.oSettings.cfApp_scorecardsortoption == "BBReceivedDate"
				|| this.oSettings.cfApp_scorecardsortoption == "startDate" 
				|| this.oSettings.cfApp_scorecardsortoption == "endDate"){
				bCaseInsensitive = false;
			}
			else{
				bCaseInsensitive = true;
			}
			
			var dataSortField:SortField = new SortField();
			
			/* sort column */
			dataSortField.name = this.oSettings.cfApp_scorecardsortoption;
			/* sort case-insensitive  */
			dataSortField.caseInsensitive = bCaseInsensitive;
			/* sort order */
			dataSortField.descending = bScorecardSortMethod;
			
			var dataSort:Sort = new Sort();
			dataSort.fields = [dataSortField];
			
			/* default sorting/refreshing for acData */
			this.acData.sort = dataSort;			
			this.acData.refresh();
			
			/* The grid's dataprovider is a "ListviewCollection". Do a default sorting/refreshing of the "listViewCollection" too. */
			this.listCollView.sort = dataSort;
			this.listCollView.refresh();
			
		} 
		private function scorecardFilterByStatus():void{
			
			/* If the status is Agreed (201), Pending Approval (202) OR Under Review (203), Call the remote search, as the
			result for these is in real-time. From the result set, do a local filter on flex.
			*/
			var eventFilterByStatus:BBSearchEvent;
			if(this.scorecardStatusID == 201 || this.scorecardStatusID == 202 || this.scorecardStatusID == 203)
			{
				eventFilterByStatus = new BBSearchEvent(BBSearchEvent.BB_REMOTE_SEARCH_FILTER_DATA);
			}
				/* For statuses other than Agreed, Pending Approval OR Under Review, Call the local filter on flex only. */
			else{
				eventFilterByStatus = new BBSearchEvent(BBSearchEvent.BB_SEARCH_FILTER_DATA);
			}		
			
			//eventFilterByStatus.eBBFilterParams = new BBFilterParams('','','','','','',0,'','',null,'','','',null,'','',new Array(new Status(status,'','')),null,null,null,false,false,'','',false,0,'','',false,false,null,false);
			eventFilterByStatus.eBBFilterParams = this.scorecardBBFilterParams;//this.objBBFilterParams;			
			
			this._dispatcher.dispatchEvent(eventFilterByStatus);
			
			additionalActions(true);
		}
		
		private function additionalActions(reset:Boolean):void{
			
			/* If reset argument is true and the user is not visiting from the scorecard, then reset all filters. */
			if(reset == true){
				if(this.scorecardStatusID == 0)
				{
					/* When not visiting from the scorecard with a status, do not refresh the grid data */ 	
					var eventReset:BBSearchEvent = new BBSearchEvent ( BBSearchEvent.RESET_FILTERS );	
					eventReset.eRefreshData = true;							
					this._dispatcher.dispatchEvent( eventReset );
					
					/* Reset the dropdown */
					this.objBBFilterParams = new BBFilterParams();
				}
				else{
					/* When visiting from the scorecard, call "SHOW_HIDE_CONTROLS" from here. When the user is not visiting from
					the scorecard, it is already being called from the "filterReset" function in "BBSearchFiltersPModel". */
					var eventShowHide:BBSearchEvent = new BBSearchEvent(BBSearchEvent.SHOW_HIDE_CONTROLS);
					eventShowHide.eSearchResultsCount = 0;
					this._dispatcher.dispatchEvent(eventShowHide);
					
					this.objBBFilterParams = this.scorecardBBFilterParams;
				}
			}
			
			/* Sort grid data */
			var eventDataGridSort:BBSearchEvent = new BBSearchEvent(BBSearchEvent.DATA_GRID_SORT);
			this._dispatcher.dispatchEvent(eventDataGridSort);			
		}
		
		private function setStatusForScorecardSearch():void{
			
			/* Add the status id in the status object */
			this.objScorecardStatus.id = this.scorecardStatusID;		
			
			/* Get the status description. The multi-option dropdowns values are selected based on description.
			To have the status selected on the status dropdown, set the status description from the status lookupData. */
			if(this.objScorecardStatus.description == ''){
				for each(var oStatus:Status in this.objLookupData.statusList){
					if(oStatus.id == this.scorecardStatusID){
						this.objScorecardStatus.description = oStatus.description;
					}
				}
			}		
			
			//this.objScorecardStatus.description = getStatusDesc(this.scorecardStatusID);
			
			this.scorecardBBFilterParams.statusListSelect = new Array(new Status(this.objScorecardStatus));
			
			/* If the user visits from the scorecard and the status is either PAID or APPROVED-VOID, then keep the
			"current including paid/void" radio button option selected.
			*/
			if(this.scorecardStatusID == 5 || this.scorecardStatusID == 8){
				this.scorecardBBFilterParams.currentIncludingPaid = true;
			}
			
			this.objBBFilterParams = this.scorecardBBFilterParams;
		}
		
		/* Get the status names. */
		/* private function getStatusDesc(status:int):String{		
		var stDesc:String = '';
		
		if(status == 1){
		stDesc = 'Work In progress'	
		}
		else if(status == 2){
		stDesc = 'Request For Approval'	
		}
		else if(status == 3){
		stDesc = 'Approved'	
		}
		else if(status == 4){
		stDesc = 'Payment Request'	
		}
		else if(status == 5){
		stDesc = 'Paid'	
		}
		else if(status == 6){
		stDesc = 'Pending Fund Update'	
		}
		else if(status == 7){
		stDesc = 'Pending Vendor ID'	
		}
		else if(status == 8){
		stDesc = 'Approved - VOID'	
		}
		else if(status == 201){
		stDesc = 'Agreed'	
		}
		else if(status == 202){
		stDesc = 'Pending Approval'	
		}
		else if(status == 203){
		stDesc = 'Under Review'	
		}
		
		return stDesc;		
		}*/
		
		/**
		 * Set the saved date of the shared object
		 */		
		public function setdSOlastSavedDate(userId:String):void
		{
			/* save shared object for the user based on UserID */
			this._soItems = SharedObject.getLocal("billbacks_"+userId,"/");
			
			// set our dSOlastSavedDate to our received SO's dSavedDate
			if( ( this._soItems.data.dSavedDate != undefined ) &&
				( this._soItems.data.dSavedDate is Date ) )
			{
				this._dSOlastSavedDate = this._soItems.data.dSavedDate as Date;
				//Alert.show("data from SO::" + this._soItems.data.dSavedDate);
				dispatchEvent(new Event('eSOlastSavedDate'));
			}
			else{			  
				this._dSOlastSavedDate = new Date(_dTodayDate.getFullYear(),_dTodayDate.getMonth(),(_dTodayDate.getDate()-1),0,0,0,0);
			}
		}
		
		/**
		 * uncheck selected billbacks in the shared object
		 */	
		public function uncheckSelectedItems():void
		{
			for each(var oItem:Object in this.acData.source)
			{
				if(oItem['isSelected'] == true)
				{
					oItem['isSelected'] = false;
				}
			}	
		}
		
		/**
		 * Delete the billback in the db and the datagrid
		 * @param deleteMessage
		 * Returns the "delete" confirmation message
		 */		
		public function delRowInGrid(deleteMessage:Object):void
		{
			
			var idxCtr:int = 0;
			var strMessage:String = new String();
			
			/* Remove bb from the search grid */
			for each(var oItemBBList:Object in deleteMessage.ARRBILLBACKIDLIST)
			{
				
				for each(var oItemBBDelete:Object in this.acData.source)
				{ 
					if (oItemBBDelete.billbackIDInt.toString() == oItemBBList)
					{	
						idxCtr = this.acData.getItemIndex(oItemBBDelete);	
						
						this.acData.removeItemAt(idxCtr);
					}
					
				}
				
				dispatchEvent(new Event('acDataChanged'));
				this.acData.refresh();
				/* The grid's dataprovider is a "ListviewCollection". The grid's dataprovider is a "ListviewCollection". Refresh it too, just to be on the safe side. */
				this.listCollView.refresh();
			}
			
			/* Shoe the alert message - Whether on delete or the reasons for not deleting it. */
			Alert.show(deleteMessage.SHOWMSG.toString());	 	
		}
		
		public function resetConfirmation(returnObj:Object,userId:String):void
		{			
			if(returnObj.SHOWMSG != '')
			{
				Alert.show(returnObj.SHOWMSG);
			}
			else{
				/* Update the record on the billback search results grid */
				var e:BBMainEvent = new BBMainEvent(BBMainEvent.UPDATE_SEARCH_BBHEADER);
				e.bbHeader= returnObj.BBH;
				this._dispatcher.dispatchEvent(e);
				
				additionalActions(true);
				
				Alert.show('The billback was reset successfully.');
			}
		}
		
		public function ressignConfirmation(returnArray:Array,userId:String):void
		{
			/* All the records will have either true or false and so using returnArray[0] (first record) is fine */
			if(returnArray[0].SUCCESS == 'true'){
				
				/* Loop through the records which were reassigned */
				for each(var o:Object in returnArray){		
					
					/* Update the record on the billback search results grid */
					var e:BBMainEvent = new BBMainEvent(BBMainEvent.UPDATE_SEARCH_BBHEADER);
					
					e.bbHeader= o.BBH;
					this._dispatcher.dispatchEvent(e);					
				}
				
				//additionalActions(true);	
				
				Alert.show('The selected billbacks have been reassigned successfully.');
			}
			else{
				Alert.show('The billbacks could not be reassigned.');
			}			
		}		
		
		/* CREATE LIST xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx */	
		/**
		 * search for multiple billbacks
		 * @param txt
		 */		
		public function createList(txt:String):void
		{
			//Alert.show(txt);
			arrItemsToAdd = new Array();
			arrItemsToAdd = listToArray(txt);
			displaySearchList(arrItemsToAdd);
		}
		
		/**
		 * split a list to an array using the carriage return delimiter
		 * @param value
		 * @param delimiter
		 * @return Array
		 */		
		private function listToArray(value:String, delimiter:String = "\r"):Array 
		{
			/* trim whitespace */
			var a:Array = new Array();
			
			for each(var i:String in value.split(delimiter))
			{
				a.push(StringUtils.Trim(i));
			}
			
			return a;
		}
		
		/**
		 * DISPLAY SearchList: Called from create list xxxxxxxxxxxxxxxxxxxxxxxxxxx
		 * @param arrItemsToAdd
		 */		
		public function displaySearchList(arrItemsToAdd:Array):void
		{
			arrValidItems = new Array();
			arrInValidItems = new Array();
			var arrFValidItems:Array = new Array();
			
			for each(var sItem:String in arrItemsToAdd)
			{
				if(StringUtils.Trim(sItem).length)
				{
					for each(var oItem:Object in this.acData.source)
					{	
						if(this.oSettings.appSettings.Exact_List_Matching_On == true)
						{
							/* Look for an exact match on payable number OR billback number */
							if(oItem['searchableBBCode'].match(new RegExp("^"+ sItem + "$", 'i')))
							{	
								arrValidItems.push(oItem['searchableBBCode'])
								/* arrFValidItems needs sItem only */
								arrFValidItems.push(sItem)
								break;
							}
							else if(oItem['BBNumber'].match(new RegExp("^"+ sItem + "$", 'i')))
							{
								arrValidItems.push(oItem['BBNumber'])
								/* arrFValidItems needs sItem only */
								arrFValidItems.push(sItem)
								break;
							}
						}
						else
						{	
							if(oItem['searchableBBCode'].match(new RegExp(sItem, 'i')))
							{	
								arrValidItems.push(oItem['searchableBBCode'])
								/* arrFValidItems needs sItem only */
								arrFValidItems.push(sItem)
							}
							else if(oItem['BBNumber'].match(new RegExp(sItem, 'i')))
							{	
								arrValidItems.push(oItem['BBNumber'])
								/* arrFValidItems needs sItem only */
								arrFValidItems.push(sItem)
							}
						}
					}
					
					/* Check for the existence of program in the array */
					if(arrFValidItems.indexOf(sItem) == -1)
					{
						arrInValidItems.push(sItem)
					}
				}
			}
			
			this.acData.filterFunction = this.itemFilterCreateListFunc;
			this.acData.refresh();
			/* The grid's dataprovider is a "ListviewCollection". Refresh it too. In my testing, this "refresh" is needed. */
			this.listCollView.refresh();
			
			//dispatchEvent(new Event('programListChanged'));
			
			/* if there are any invalid Programs display the valid and invalid lists */
			if(arrInValidItems.length > 0)
			{
				/* if there are any invalid items, pop up the results */
				showPopUp(arrInValidItems,arrValidItems);
			}
		}
		
		/**
		 * filter func for create/saved list items
		 * @param item
		 * Returns boolean after checks whether the billback exists in the array
		 */		
		public function itemFilterCreateListFunc(item:Object):Boolean
		{
			return (arrValidItems.indexOf(item['searchableBBCode']) >= 0 || arrValidItems.indexOf(item['BBNumber']) >= 0 )
		}
		
		
		/**
		 * Show Pop-Up Box with List of Valid and Invalid Billbacks
		 * @param aInvalidItems
		 * @param aValidItems
		 */		
		private function showPopUp(aInvalidItems:Array,aValidItems:Array):void
		{
			popUp = UserItemLists(PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject,UserItemLists,true));
			PopUpManager.centerPopUp(popUp);
			popUp.aInvalidItems = aInvalidItems;
			popUp.aValidItems = aValidItems;
		}
		
		public function dataLookup(obj:BBFilterDef):void{
			
			this.objLookupData = obj;	
			
			/* BBCorrections and Alias modules should be called from here. It was intially being called from BillbackMain.mxml, which 
			caused an issue when a user visited the grid using the scorecard - The status used to visit the scorecard was not being
			retained consistently on the status dropdown. Once the lookupdata is retrived, then calling these modules fixes the issue.
			Note: DataLookUp is being called from "BillbackMain.mxml" */
			
			/* Call the BB corections module */
			var eventLoadModCorrections:BBMainEvent = new BBMainEvent ( BBMainEvent.LOAD_MODS_BBCORRECTIONS );			
			this._dispatcher.dispatchEvent( eventLoadModCorrections );
			
			/* Call the Alias module */
			var eventLoadModAlias:BBMainEvent = new BBMainEvent ( BBMainEvent.LOAD_MODS_ALIAS );			
			this._dispatcher.dispatchEvent( eventLoadModAlias );
			
			/* If the user visits using the scorecard */
			if(this.scorecardStatusID != 0){
				setStatusForScorecardSearch();
				
				/* The lookup data load is complete */
				bDataLookupLoadComplete = true;
				
				/* To reset the scorecard variables, we have to make sure that the grid data has been loaded and the lookup data has been loaded.
				Once these are loaded, the data is filtered using the status and the dropdown has that status selected. Once this has been done,
				then reset the scorecard variables */
				if(bGridDataLoadComplete == true){
					resetScorecardVariables();
				}		
			}
		}
		
		/* Reset the scorecard variables after the user visits from the scorecard.
		Note: When the user visits from the scorecard and then clicks on "reset" - If the dropdown does not reset correctly,
		then this function might not be getting called and that could be the issue. */
		private function resetScorecardVariables():void{
			this.scorecardStatusID = 0;
			this.scorecardBBFilterParams = new BBFilterParams();
		}
		
		public function dataGridColumnSize(obj:BBSearchGridColumnSize):void{
			this.objBBSearchGridColumnSize = obj;
			dispatchEvent(new Event('objBBSearchGridColumnSizeDataChanged'));			
		}
		
		// Export XLS Handler
		public function fnExportXLS():void
		{	
			var strBillbackList:String  ='';
			var strStartDate:String = '';
			var strEndDate:String = '';
			var strBBDate:String = '';					
			var strBBReceivedDate:String = '';
			
			/* (String.fromCharCode(9) means tab) */
			var strBillbackheader:String = 'Status' + String.fromCharCode(9) + 'Payable #' + String.fromCharCode(9) + 'Billback #' + String.fromCharCode(9) + 'Title'+ String.fromCharCode(9) + 'Received Date'+ String.fromCharCode(9) +'Payee'+ String.fromCharCode(9) +'Vendor'+ String.fromCharCode(9)+ 'Start Date'+ String.fromCharCode(9)+ 'End Date'+ String.fromCharCode(9)+ 'Claimed $'+ String.fromCharCode(9)+ 'Approved $'+ String.fromCharCode(9)+ 'Closing Method' + String.fromCharCode(9) + 'Analyst' + String.fromCharCode(9) + 'Approved By';
			
			/* Loop through the records in the datagrid view (filtered records). Then a "save" option 
			will appear where the user can save the records as an Excel file on their local machine.
			*/
// try{
			for each(var o:Object in this.acData)
			{	
				if ((o['startDate'] != null) && (o['startDate'].toString() != ''))
				{	
					strStartDate = o['startDate'].getMonth() + 1 +"/"+ o['startDate'].getDate()+"/"+ o['startDate'].getFullYear();
				}
				
				if ((o['endDate'] != null) && (o['endDate'].toString() != ''))
				{
					strEndDate = o['endDate'].getMonth() + 1 +"/"+ o['endDate'].getDate()+"/"+ o['endDate'].getFullYear();
				// strBBDate = o['BBDate'].getMonth() + 1 +"/"+ o['BBDate'].getDate()+"/"+ o['BBDate'].getFullYear();
				}
				
				if ((o['BBReceivedDate'] != null) && (o['BBReceivedDate'].toString() != ''))
				{
					strBBReceivedDate = o['BBReceivedDate'].getMonth() + 1 +"/"+ o['BBReceivedDate'].getDate()+"/"+ o['BBReceivedDate'].getFullYear();
				}
			
				strBillbackList = strBillbackList + o.status.abbreviation + String.fromCharCode(9) + o.BBCode.toString() + String.fromCharCode(9) + o.BBNumber.toString() + String.fromCharCode(9) + o.title.toString() + String.fromCharCode(9) + strBBReceivedDate + String.fromCharCode(9) + o.payee.name.toString() + String.fromCharCode(9) + o.vendor.name.toString() + String.fromCharCode(9) + strStartDate + String.fromCharCode(9) + strEndDate + String.fromCharCode(9) +  o.amount.toString() + String.fromCharCode(9) + o.approvedAmount.toString() + String.fromCharCode(9) +  o.closingMethod.description + String.fromCharCode(9) + o.analyst.fullName.toString() + String.fromCharCode(9) + o.approved.fullName.toString() + String.fromCharCode(13) + String.fromCharCode(10);
			}	
			strBillbackList = strBillbackheader +  String.fromCharCode(13) + String.fromCharCode(10) + strBillbackList;
			downloadFileRef.save(strBillbackList,"Billback_List.xls");
/*}
catch (err:*) {
	Alert.show(ObjectUtil.toString(err));
}
*/
		}
		
		public function showHideControls(recordCount:int):void
		{
			/* Do not remove this (this.intNavListSelectedIndex = 0). It makes sure that the code works properly all the time. I have commented it as
			it is not being used.
			*/
			//this.intNavListSelectedIndex = 0;
			
			if(recordCount > 0)
			{
				if(this.objBBFilterParams.actionSelect == 'Reassign')
				{
					this.bshowReAssign = true;
					this.bshowRelease = false;
					this.bshowHold = false;					
					this.bshowReset = false;
					this.bshowMassApprove = false;
					this.bshowDelete = false;
					
					/* Increase the height of the top search filters section, so that the "Reassign To" dropdown can be added on an additional row */
					var eventSearchScreenHeight:BBSearchEvent = new BBSearchEvent ( BBSearchEvent.BB_SEARCH_FILTERS_SCREEN_HEIGHT);							
					eventSearchScreenHeight.eSearchFiltersScreenHeightIncrease = true;
					
					this._dispatcher.dispatchEvent( eventSearchScreenHeight );
	
					/* comment the below line because:
					On reassign, we need to show the "search" and "reset" button, so that the user can use the features. 
					*/
					//this.bShowLoadingOptions = false;
				}
				else if(this.objBBFilterParams.actionSelect == 'Hold')
				{
					this.bshowHold = true;
					this.bshowReAssign = false;
					this.bshowRelease = false;
					this.bshowReset = false;
					this.bshowMassApprove = false;
					this.bshowDelete = false;
					this.bShowLoadingOptions = true;				    
				}	
				else if(this.objBBFilterParams.actionSelect == 'Release')
				{
					this.bshowRelease = true;
					this.bshowReAssign = false;				    				    
					this.bshowHold = false;
					this.bshowReset = false;
					this.bshowMassApprove = false;
					this.bshowDelete = false;
					this.bShowLoadingOptions = true;
				}
				else if(this.objBBFilterParams.actionSelect == 'Mass Approve')
				{				    				    
					this.bshowMassApprove = true; 
					this.bshowReAssign = false;
					this.bshowRelease = false;
					this.bshowHold = false;
					this.bshowReset = false;		
					this.bshowDelete = false;
					this.bShowLoadingOptions = true;		      
				}
				else if(this.objBBFilterParams.actionSelect == 'Reset')
				{
					this.bshowReset = true;
					this.bshowReAssign = false;
					this.bshowRelease = false;
					this.bshowHold = false;
					this.bshowMassApprove = false;    
					this.bshowDelete = false;
					this.bShowLoadingOptions = true;
				}
				else if(this.objBBFilterParams.actionSelect == 'Delete')
				{
					this.bshowDelete = true;
					this.bshowReset = false;
					this.bshowReAssign = false;
					this.bshowRelease = false;
					this.bshowHold = false;
					this.bshowMassApprove = false;
					this.bShowLoadingOptions = true; 				    
				}
				
				/*if(this.objBBFilterParams.actionSelect == 'Reassign' || this.objBBFilterParams.actionSelect == 'Hold'	
				|| this.objBBFilterParams.actionSelect == 'Release' || this.objBBFilterParams.actionSelect == 'Mass Approve'
				|| this.objBBFilterParams.actionSelect == 'Reset' || this.objBBFilterParams.actionSelect == 'Delete')
				{
				this.intNavListSelectedIndex = 1;
				}*/
			}
			
			if(this.objBBFilterParams.actionSelect == 'Select Action for' || recordCount == 0)
			{	
				this.bshowReAssign = false;
				this.bshowRelease = false;
				this.bshowHold = false;
				this.bshowReset = false;
				this.bshowMassApprove = false;
				this.bshowDelete = false;
				this.bShowLoadingOptions = true;				    
				
				//this.intNavListSelectedIndex = 0;
			}
			
		}		
		
		public function dataRemoteFilter(o:Object):void{
			/*
			Stores the billback_id_Int based on search of the following:
			Distributor, Operator, Item, and statuses - pending approval,agreed and under review
			*/
			this.arrBillbackIdIntFilter = o.F;
		}
		
		public function dataFilter(o:BBFilterParams):void{
			
			/* Reset the array meant to hold the status */
			this.arrStatus = new Array();
			
			/* If the user visits from the scorecard.i.e. by using a status, then store the status in an array and send it to the filter function.
			Setting "objBBFilterParams" with the value of status resets the status dropdown and the dropdown does not have the status selected.
			Not sure why the dropdown gets reset.			 
			*/			
			if(FlexGlobals.topLevelApplication.parameters.status)
			{
				if(FlexGlobals.topLevelApplication.parameters.status == 201 || FlexGlobals.topLevelApplication.parameters.status == 202
					|| FlexGlobals.topLevelApplication.parameters.status == 203)
				{	
					/* Store the status passed in the "arrStatus" Array */
					this.arrStatus[0] = o.statusListSelect[0].id;
					//this.arrStatus[0] = FlexGlobals.topLevelApplication.parameters.status;
					/* Reset the url variable passed to flex, so that the searches made after the data is loaded goes to the 
					other (else) condition,i.e. "objBBFilterParams" is used.
					*/
					FlexGlobals.topLevelApplication.parameters.status = 0;
				}
					/* Call this when the data filtering needs to be done for statuses other than Agreed, Pending Approval and Under Review. */
				else
				{
					/* This fires the 'objFilterParamsChanged' event */
					this.objBBFilterParams = o;
				}
			}
				/* Call this when the data filtering needs to be done when the data is already loaded. */
			else
			{
				/* This fires the 'objFilterParamsChanged' event */
				this.objBBFilterParams = o;
			}
			
			/* Request is from the search module */
			bFromSearch = true;
			
			filter();
		}
		
		public function filter():void
		{	
			
			/* When the search is made using "current including paid/void" option */
			if(bGetSearch == true)
			{				
				/* If it is a non-paid billback, store the updated data in the shared object. Paid data is not stored in a shared object. */
				if(bNonPaidBBList == true){
					/* Set the temp data to be the actual data source. The temp data stores the updated data. 
					Note: We are using ".source" here due to the following reason:
					- When a bb is reset,reassigned,deleted etc from the bb search grid or from bb edit, we update the bb search grid with the refreshed results. When we do this,
					we want to maintain the sort which already exists on the grid (whether that is the default sort or it has been sorted using some other column(s) by the user.) 
					If I use "this.acData = this._acDataTemp", then the sort will go away. 
					Note: Whether we user ".source" or not, the scrollbar will still scroll to the top after data update.
					*/
					this.acData.source = this._acDataTemp.source;
					
					this.saveSOitems();
					/* Reset the value */
					bNonPaidBBList = false;
				}
				else{
					/* Set the temp data to be the actual data source. The temp data stores the updated data.
					".SOURCE" IS NOT USED HERE. IF IT IS USED, THEN WHEN WE SEARCH BY "PAID DATA", THE PAID BB'S WILL BE ADDED TO THE SHARED OBJECT, WHICH WE DO NOT WANT. */
					this.acData = this._acDataTemp;
				}
				/* Reset the value */
				bGetSearch = false;
			}
			
			/* Reset "bShowPaidStatusMessage" to true, so that the user can see the message everytime billbacks in "paid" status 
			are not included in the dataset and "paid" status is selected from the Status dropdown.			   
			*/
			bShowPaidStatusMessage= true;		
			
			if(this.objBBFilterParams.BBIDIntList.length > 0)
			{
				this.acData.filterFunction = this.BBFilterResultsForDoc;
			}
			else
			{
				this.acData.filterFunction = this.BBFilterResults;
			}
			
			this.acData.refresh();
			/* The grid's dataprovider is a "ListviewCollection". Refresh it too. In my testing, this "refresh" is needed. */
			this.listCollView.refresh();
			
			var eventShowHide:BBSearchEvent = new BBSearchEvent(BBSearchEvent.SHOW_HIDE_CONTROLS);
			eventShowHide.eSearchResultsCount = 1;
			this._dispatcher.dispatchEvent(eventShowHide);	
		}		
		
		public function BBFilterResultsForDoc(item:Object):Boolean
		{
			return(this.objBBFilterParams.BBIDIntList.indexOf(item.billbackIDInt) >=0);
		}
		
		public function BBFilterResults(item:Object):Boolean
		{	
			var bReturn:Boolean = false;
			var bClosingMethod:Boolean = false;
			
			/* SEARCH BY DATE OPTIONS */			
			var nGridDateRangeStartValue:Number;
			var nGridDateRangeEndValue:Number;
			var bDateRangeStartSearchResult:Boolean = false;
			var bDateRangeEndSearchResult:Boolean = false;
			var nSearchRangeStartDateValue:Number = Date.parse(this.objBBFilterParams.dateRangeStartValueKeyword);
			var nSearchRangeEndDateValue:Number = Date.parse(this.objBBFilterParams.dateRangeEndValueKeyword);
			
			
			/* start date */
			if(this.objBBFilterParams.dateRangeStartTypeSelect == this.oSettings.appFlex.bbLabels.Billback)
			{
				nGridDateRangeStartValue = Date.parse(item.BBReceivedDate);
			}
			else if (this.objBBFilterParams.dateRangeStartTypeSelect == 'Start')
			{
				nGridDateRangeStartValue = Date.parse(item.startDate);
			}			
			else if (this.objBBFilterParams.dateRangeStartTypeSelect == 'End')
			{
				nGridDateRangeStartValue = Date.parse(item.endDate);
			}
			else if (this.objBBFilterParams.dateRangeStartTypeSelect == 'Create')
			{
				nGridDateRangeStartValue = Date.parse(item.createdDate);
			}
			else if (this.objBBFilterParams.dateRangeStartTypeSelect == 'RFA')
			{
				nGridDateRangeStartValue = Date.parse(item.requestApprovalDate);
			}
			else if (this.objBBFilterParams.dateRangeStartTypeSelect == 'Approved')
			{
				nGridDateRangeStartValue = Date.parse(item.approvedDate);
			}
			else if (this.objBBFilterParams.dateRangeStartTypeSelect == 'Paid')
			{
				nGridDateRangeStartValue = Date.parse(item.paidDate);
			}			
			
			
			if(this.objBBFilterParams.dateRangeStartCriteriaSelect == "=")
			{
				bDateRangeStartSearchResult = (nGridDateRangeStartValue == nSearchRangeStartDateValue);		
			}
			else if(this.objBBFilterParams.dateRangeStartCriteriaSelect == "<=")
			{
				bDateRangeStartSearchResult = (nGridDateRangeStartValue <= nSearchRangeStartDateValue);
			}	
			else if	(this.objBBFilterParams.dateRangeStartCriteriaSelect == ">=")
			{
				bDateRangeStartSearchResult = (nGridDateRangeStartValue >= nSearchRangeStartDateValue);
			}
					
			
			/* end date */
			if(this.objBBFilterParams.dateRangeEndTypeSelect == this.oSettings.appFlex.bbLabels.Billback)
			{
				nGridDateRangeEndValue = Date.parse(item.BBReceivedDate);
			}
			else if (this.objBBFilterParams.dateRangeEndTypeSelect == 'Start')
			{
				nGridDateRangeEndValue = Date.parse(item.startDate);
			}			
			else if (this.objBBFilterParams.dateRangeEndTypeSelect == 'End')
			{
				nGridDateRangeEndValue = Date.parse(item.endDate);
			}
			else if (this.objBBFilterParams.dateRangeEndTypeSelect == 'Create')
			{
				nGridDateRangeEndValue = Date.parse(item.createdDate);
			}
			else if (this.objBBFilterParams.dateRangeEndTypeSelect == 'RFA')
			{
				nGridDateRangeEndValue = Date.parse(item.requestApprovalDate);
			}
			else if (this.objBBFilterParams.dateRangeEndTypeSelect == 'Approved')
			{
				nGridDateRangeEndValue = Date.parse(item.approvedDate);
			}
			else if (this.objBBFilterParams.dateRangeEndTypeSelect == 'Paid')
			{
				nGridDateRangeEndValue = Date.parse(item.paidDate);
			}	
			
					
			if(this.objBBFilterParams.dateRangeEndCriteriaSelect == "=")
			{
				bDateRangeEndSearchResult = (nGridDateRangeEndValue == nSearchRangeEndDateValue);		
			}
			else if(this.objBBFilterParams.dateRangeEndCriteriaSelect == "<=")
			{
				bDateRangeEndSearchResult = (nGridDateRangeEndValue <= nSearchRangeEndDateValue);
			}	
			else if	(this.objBBFilterParams.dateRangeEndCriteriaSelect == ">=")
			{
				bDateRangeEndSearchResult = (nGridDateRangeEndValue >= nSearchRangeEndDateValue);
			}
			
			/* SEARCH BY AMOUNT OPTIONS */			
			var nGridAmountValue:Number;
			var nSearchAmountValue:Number = this.objBBFilterParams.amountValueKeyword;
			var bAmountSearchResult:Boolean;
			
			if(this.objBBFilterParams.amountTypeSelect == 'Claimed')
			{
				nGridAmountValue = item.amount;
			}
			else if (this.objBBFilterParams.amountTypeSelect == 'Approved')
			{
				nGridAmountValue = item.approvedAmount;
			}			
			
			
			if(this.objBBFilterParams.amountCriteriaSelect == "=")
			{
				bAmountSearchResult = (nGridAmountValue == nSearchAmountValue);		
			}
			else if(this.objBBFilterParams.amountCriteriaSelect == "<=")
			{
				bAmountSearchResult = (nGridAmountValue <= nSearchAmountValue);
			}	
			else if	(this.objBBFilterParams.amountCriteriaSelect == ">=")
			{
				bAmountSearchResult = (nGridAmountValue >= nSearchAmountValue);
			}
			
			
			var arrSelectedStatuses:Array = new Array();
			
			/* Loop through the "Status object" and populate the arrSelectedStatuses Array
			with the id from the Status Object.
			*/
			for each(var oStatus:Status in this.objBBFilterParams.statusListSelect)
			{	
				/* Add in the "arrSelectedStatuses" array all statuses other than "Agreed", "Pending Approval" and "Under Approval" */
				if(oStatus != null && oStatus.id != 201 && oStatus.id != 202 && oStatus.id != 203)
				{
					arrSelectedStatuses.push(oStatus.id);
				}				
			}	
			
			var arrSelectedOtherStatuses:Array = new Array();
			
			/* When the user visits from the scorecard using agreed OR pending approval OR under review, we do not use ObjFilterparams.
			Instead we populate status in an array (arrStatus) and filter the grid using that status.
			*/
			if(this.arrStatus.length > 0)
			{
				
				arrSelectedOtherStatuses.push(this.arrStatus[0]);
			}
			else
			{	/* Loop through the "Status object" and populate the arrSelectedOtherStatuses Array
				with the id from the Status Object.
				*/
				for each(var oOtherStatus:Status in this.objBBFilterParams.statusListSelect)
				{		
					if(oOtherStatus != null && (oOtherStatus.id == 201 || oOtherStatus.id == 202 || oOtherStatus.id == 203))
					{
						arrSelectedOtherStatuses.push(oOtherStatus.id);
					}				
				}				
			}	
			
			var arrSelectedUsers:Array = new Array();	
			
			/* Loop through the "User object" and populate the arrSelectedAnalysts Array
			with the fullName from the Status Object.
			*/
			for each(var oHistoryUser:User in this.objBBFilterParams.historyUsernameSelect)
			{   if(oHistoryUser != null)
			{
				arrSelectedUsers.push(oHistoryUser.idInt);
			}
			}			
			
			var arrSelectedAnalysts:Array = new Array();	
			
			/* Loop through the "User object" and populate the arrSelectedAnalysts Array
			with the fullName from the Status Object.
			*/
			for each(var oUser:User in this.objBBFilterParams.analystListSelect)
			{   if(oUser != null)
			{
				arrSelectedAnalysts.push(oUser.idInt);
			}				
			}		
			
			var arrSelectedBBTypes:Array = new Array();	
			
			/* Loop through the "Type object" and populate the arrSelectedBBTypes Array
			with the description from the Status Object.
			*/
			for each(var oBBType:Type in this.objBBFilterParams.typeListSelect)
			{   if(oBBType != null)
			{
				arrSelectedBBTypes.push(oBBType.id);
			}
				
			}	
			
			var arrSelectedClosingMethods:Array = new Array();	
			
			/* Loop through the "ClosingMethod object" and populate the arrSelectedClosingMethods Array
			with the description from the ClosingMethod Object.
			*/
			for each(var oClosingMethod:ClosingMethod in this.objBBFilterParams.closingMethodSelect)
			{   if(oClosingMethod != null)
			{
				arrSelectedClosingMethods.push(oClosingMethod.id);
			}
				
			}
			
			if(
				(bShowPaidStatusMessage == true && bFromSearch == true && this.objBBFilterParams.currentIncludingPaid == false)
				&& 
				(
					/* If the paid option is selected on the status dropdown OR the date search is on "paid" date. */
					(
						arrSelectedStatuses.indexOf(5) != -1 || this.objBBFilterParams.dateRangeStartTypeSelect == 'Paid'
						|| this.objBBFilterParams.dateRangeEndTypeSelect == 'Paid'
					)
					||
					/* If the "Approved-VOID" option is selected on the status dropdown. */
					(
						arrSelectedStatuses.indexOf(8) != -1
					)			
				 )
			)
			{
				bShowPaidStatusMessage = false;
				Alert.show('The current dataset does not include billbacks in "Paid" or "Approved-VOID" Status.');			
			}
			
			/* [BEGIN] Filter on closing method */
			bClosingMethod =
				/* None of the closing methods was selected */
				(arrSelectedClosingMethods.length == 0)
				||
				/* closing method passed criteria */
				(arrSelectedClosingMethods.indexOf(item.closingMethod.id) != -1)
			
			/* 	For billbacks of status approved and beyond, search for closing methods of the billback's children, i.e. splits. 
			If the billback does not have splits,then the closing method of the billback (there will be not splits) will be used.
			Note: Splits are created so that the billback can have multiple closing methods.
			item.closingMethod.idList.length means billback has splits. */			
			if(bClosingMethod == false && arrSelectedClosingMethods.length > 0 && item.status.id >= 3 && item.closingMethod.idList.length > 0){	
				var arrCM:Array = new Array();
				
				/* 	The closing methods of the split are in a comma-delimited format for every parent billback and so one needs to loop through
				all the different closing methods of the splits. If the closing method being searched on matches any of the children's billback 
				closing method,then return true.
				*/
				arrCM = item.closingMethod.idList.split(',');
				
				for each(var cm:int in arrCM)
				{
					if(arrSelectedClosingMethods.indexOf(cm) != -1){
						bClosingMethod = true;
						break;
					}
				}
			}
			/* [END] Filter on closing method */
			
			/* Filter on the other criterias */
			bReturn = 
				(
					
					(	/* No status selected */
						(arrSelectedStatuses.length == 0 && arrSelectedOtherStatuses.length == 0)
						||
						/* All statuses except - Status of 201 - Agreed, 202 - Pending Approval, 203 - Under Review */
						arrSelectedStatuses.length > 0 && arrSelectedOtherStatuses.length == 0 && arrSelectedStatuses.indexOf(item.status.id) != -1
						||
						/* Full-text search - Status of 201 - Agreed and/or 202 - Pending Approval and/or 203 - Under Review */
						arrSelectedOtherStatuses.length > 0 && arrSelectedStatuses.length == 0 && this.arrBillbackIdIntFilter.indexOf(item.billbackIDInt) >=0
						||
						/* Local (flex) status filter AND Status of 201 - Agreed and/or 202 - Pending Approval and/or 203 - Under Review */
						(arrSelectedStatuses.length > 0 && arrSelectedOtherStatuses.length > 0 && (arrSelectedStatuses.indexOf(item.status.id) != -1 || this.arrBillbackIdIntFilter.indexOf(item.billbackIDInt) >=0))
					)
					&&
					(
						(arrSelectedAnalysts.length == 0)
						||
						(arrSelectedAnalysts.indexOf(item.analyst.idInt) != -1)
					)
					&&
					(
						(arrSelectedBBTypes.length == 0)
						||
						(arrSelectedBBTypes.indexOf(item.BBtype.id) != -1)
					)
					&&
					(
						this.objBBFilterParams.BBCodeKeyword.length == 0
						||
						(item.BBCode.toLowerCase().indexOf(this.objBBFilterParams.BBCodeKeyword.toLowerCase()) != -1
							|| 
							item.title.toLowerCase().indexOf(this.objBBFilterParams.BBCodeKeyword.toLowerCase()) != -1
						)
						
						
					)			    
					&& 
					(
						this.objBBFilterParams.checkNoKeyword.length == 0
						||
						item.checkNumber.toLowerCase().indexOf(this.objBBFilterParams.checkNoKeyword.toLowerCase()) != -1
					)
					&&
					(
						this.objBBFilterParams.BBNumberKeyword.length == 0
						||
						item.BBNumber.toLowerCase().indexOf(this.objBBFilterParams.BBNumberKeyword.toLowerCase()) != -1
						||
						item.referenceNumber.toLowerCase().indexOf(this.objBBFilterParams.BBNumberKeyword.toLowerCase()) != -1
					)
					&&
					(
						this.objBBFilterParams.bSearchDateRangeStart == false
						||
						bDateRangeStartSearchResult
					)
					&&
					(
						this.objBBFilterParams.bSearchDateRangeEnd == false
						||
						bDateRangeEndSearchResult
					)
					&&
					(
						this.objBBFilterParams.bSearchAmount == false
						||
						bAmountSearchResult
					)			    
					&&
					(
						(this.objBBFilterParams.conditionSelect == 'Select Conditions' || this.objBBFilterParams.conditionSelect.length == 0)
						||
						(
							(this.objBBFilterParams.conditionSelect == 'Doc attached' && item.documentAttached == true)
							||
							(this.objBBFilterParams.conditionSelect == 'No Doc attached' && item.documentAttached == false)
							||
							(this.objBBFilterParams.conditionSelect == this.oSettings.appFlex.bbLabels.Deviation && item.deviated == true)
							||
							(this.objBBFilterParams.conditionSelect.indexOf('Not Ack') != -1 && item.notAcknowledged == true)
						)
					)			 	
					&&
					(
						(arrSelectedUsers.length == 0)
						||
						(
							(this.objBBFilterParams.historySelect == 'Created By' && arrSelectedUsers.indexOf(item.creator.idInt) != -1) 
							|| 
							(this.objBBFilterParams.historySelect == 'RFA By' && arrSelectedUsers.indexOf(item.requestApproval.idInt) != -1)
							|| 
							(this.objBBFilterParams.historySelect == 'Approved By' && arrSelectedUsers.indexOf(item.approved.idInt) != -1) 
							||
							(this.objBBFilterParams.historySelect == 'Disagreed By' && arrSelectedUsers.indexOf(item.disagree.idInt) != -1) 
							|| 
							(this.objBBFilterParams.historySelect == 'Reset By' && arrSelectedUsers.indexOf(item.reset.idInt) != -1)
						)
					)
					&&	
					(	/* Full-text search - Program Search */
						/* Full-text search - All entities except vendor. Vendor search is not a full-text search. It is a local search */
						(this.objBBFilterParams.programKeyword.length == 0 && (this.objBBFilterParams.entityKeyword.length == 0 || this.objBBFilterParams.entitySelect == this.oSettings.appFlex.bbLabels.Vendor))
						||
						(this.arrBillbackIdIntFilter.indexOf(item.billbackIDInt) >=0)
					)
					&&
					(
						this.objBBFilterParams.payeeKeyword.length == 0
						||
						(
							item.payee.name.toLowerCase().indexOf(this.objBBFilterParams.payeeKeyword.toLowerCase()) != -1
							||
							item.payee.payeeId.toLowerCase().indexOf(this.objBBFilterParams.payeeKeyword.toLowerCase()) != -1 
						)			    	
					)
					&&
					(  /* Do local filtering for Vendor only */
						this.objBBFilterParams.entityKeyword.length == 0 || this.objBBFilterParams.entitySelect != this.oSettings.appFlex.bbLabels.Vendor
						||
						(
							item.vendor.name.toLowerCase().indexOf(this.objBBFilterParams.entityKeyword.toLowerCase()) != -1
							||
							item.vendor.payeeId.toLowerCase().indexOf(this.objBBFilterParams.entityKeyword.toLowerCase()) != -1 
						)			    	
					)
					&&
					(
						(this.objBBFilterParams.actionSelect == 'Select Action for' || this.objBBFilterParams.actionSelect.length == 0)
						||
						(
							(this.objBBFilterParams.actionSelect == 'Reset' && item.resetAllowed == true)
							||
							(this.objBBFilterParams.actionSelect == 'Delete' && item.deleteAllowed == true)
							||
							(this.objBBFilterParams.actionSelect == 'Hold' && item.holdAllowed == true)
							||
							(this.objBBFilterParams.actionSelect == 'Release' && item.releaseAllowed == true)
							||
							/* Reassign is always allowed */
							(this.objBBFilterParams.actionSelect == 'Reassign' && item.reassignAllowed == true)
							||
							(this.objBBFilterParams.actionSelect == 'Mass Approve' && item.massApproveAllowed == true)
							
						)
					)
					&& (this.objBBFilterParams.clearRecords == false)			
					
					&& (bClosingMethod == true)
					
					  && (
						(this.objBBFilterParams.bChkDuplicate == true && (item.BBUploadDupGroupID != 0 ))
						||
						(this.objBBFilterParams.bChkDuplicate == false && item.BBUploadDupGroupID >=0 )
						) 
				)
			
			
			return bReturn;			
		}
		
		
		public function copyBillbackHandler(bb:Billback):void
		{
			
			var e:BBMainEvent = new BBMainEvent(BBMainEvent.EDIT_BB);
			e.bbHeader = bb.bbHeader;
			e.payeeList = new Array(bb.bbHeader.payee);
			e.bbAnalysts = objLookupData.analystList;
			e.closingMethodList = objLookupData.closingMethodList;
			this.acData.addItem(e.bbHeader);
			this.acData.refresh();
			/* The grid's dataprovider is a "ListviewCollection". Refresh it too, just to be on the safe side. */
			this.listCollView.refresh();
			this._dispatcher.dispatchEvent(e);
			
		}
		
		public function massApproveConfirmation(ObjHeader:Object):void
		{			
			var idxCtr:int = 0;
			
			for each(var oItemBBList:BBHeader in ObjHeader.APPROVEDLIST)
			{	
				//idxCtr = 0;
				
				for each(var oItemBBDelete:Object in this.acData.source)
				{
					//idxCtr = idxCtr + 1;
					
					if (oItemBBDelete.billbackIDInt.toString() == oItemBBList.billbackIDInt.toString())
					{		
						/* To update the header directly, use this line and comment the two lines below */
						//this.acData.source[idxCtr] = oItemBBList;
						idxCtr = this.acData.getItemIndex(oItemBBDelete);						
						this.acData.removeItemAt(idxCtr);
						break;
					}	
				}				
			}		
			
			for each(var oItemBBList1:BBHeader in ObjHeader.ERRORMSG)
			{	
				//idxCtr = 0;
				
				for each(var oItemBBDelete1:Object in this.acData.source)
				{	
					//idxCtr = idxCtr + 1;
					
					if (oItemBBDelete1.billbackIDInt.toString() == oItemBBList1.billbackIDInt.toString())
					{	
						/* To update the header directly, use this line and comment the two lines below. Also, comment the concat below. */
						//this._acData.source[idxCtr] = oItemBBList1;
						idxCtr = this.acData.getItemIndex(oItemBBDelete1);						
						this.acData.removeItemAt(idxCtr);
						break;
					}		
				}			
				
			}
			
			
			/* Take the "acData" and append the approved billbacks list and the unapproved billback list. */
			this.acData = new ArrayCollection(ObjHeader.APPROVEDLIST.concat(ObjHeader.ERRORMSG).concat(this.acData.source));
			
			/* Refresh the results of the approved and unapproved billbacks and show those billbacks at the top of the grid. */
			this.acData.refresh();
			/* The grid's dataprovider is a "ListviewCollection". Refresh it too, just to be on the safe side. */
			this.listCollView.refresh();
			
			/* pop up for the results of billback approval */
			showPopUpBillbackApproval(ObjHeader.APPROVEDLIST.concat(ObjHeader.ERRORMSG));
		}
		
		/**
		 * Show Pop-Up Box with List of approved Billbacks
		 * @param arrObjHeader
		 */		
		private function showPopUpBillbackApproval(arrObjHeader:Array):void
		{
			popUpMassApprove = MassApproveList(PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject,MassApproveList,true));
			PopUpManager.centerPopUp(popUpMassApprove);
			popUpMassApprove.arrObjHeader = arrObjHeader;
		}
		
		
		/* When the BBHeader on the Settlement module or Edit module is updated,
		the BBheader on the search grid needs to be updated too.
		*/
		public function setUpdatedBBHeader(bbh:BBHeader):void
		{
			/* Take action only when the bb is not copied ("bbh.BBNumber" exists) */
			if(bbh.BBNumber.length > 0)
			{
				/* Add BBHeader to an array. Function "deleteBillbackInOldStatus" accepts an array */
				var arrBBHeader:Array = new Array();
				
				/* We will always have one record in bbh */
				arrBBHeader[0] = bbh;
				
				bNonPaidBBList = true;
				
				/* 	When we have a billback in a certain status on flex grid and later when the billback's status changes, the new bbheader gets returned
				from CF to flex and another record for the same bb but a newer status gets added to the bb grid. The function below will only keep the
				record from the latest status. */
				deleteBillbackInOldStatus(arrBBHeader);
				/* No need to save the shared object here. It will be saved later in the code, once "this.acData" is set */
				//this.saveSOitems();
				
				/* Request is not from the search module. "setUpdatedBBHeader" function is called from other modules. */
				bFromSearch = false;
				
				filter();
				
				/* Refresh the results of the approved and unapproved billbacks and show those billbacks at the top of the grid.
				Note: Now this function is being called from many places.
				*/
				dispatchEvent(new Event('acDataChanged'));
				//this._acData.refresh();
			}
		}
		
		public function setUpdatedBBHeaderList(arrBBH:Array):void
		{	
			/* Loop through the list of bbheaders and update the bbheader on bb search. */
			for each(var bbh:BBHeader in arrBBH)
			{
				setUpdatedBBHeader(bbh);
			}
			
			Alert.show("The document process is completed.");			
		}
		
		/* When the BBHeader on the Settlement module or Edit module is updated,
		the BBheader on the search grid needs to be updated too.
		*/
		public function setDeletedBBHeader(bbh:BBHeader):void
		{
			/* Add BBHeader to an array. Function "deleteBillbackInOldStatus" accepts an array */
			var arrBBHeader:Array = new Array();
			
			/* We will always have one record in bbh */
			arrBBHeader[0] = bbh;
			
			bNonPaidBBList = true;
			
			/* 	Delete the billback from the shared object. */
			deleteBillback(arrBBHeader);
			/* No need to save the shared object here. It will be saved later in the code, once "this.acData" is set */
			//this.saveSOitems();
			
			/* Request is not from the search module. "setDeletedBBHeader"  function is called from other modules. */
			bFromSearch = false;
			
			filter();
			
			/* Refresh the results of the approved and unapproved billbacks and show those billbacks at the top of the grid. */
			dispatchEvent(new Event('acDataChanged'));	
			//this.acData.refresh();
		}
		
		public function setDataViewOption(status:int):void{
			/* For paid or approved-void status, keep the "Current including paid/void" option selected, else select the "Current" option. */
			if(status == 5 || status == 8){
				this.dataViewOption = 'current_including_paid';
			}
			else{
				this.dataViewOption = 'current';	
			}			
		}		
	}
}