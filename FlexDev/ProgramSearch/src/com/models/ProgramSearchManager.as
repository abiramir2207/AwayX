package com.models
//package com.models.ProgramSeachManager
{
	import com.asfusion.mate.events.Dispatcher;
	import com.components.StringUtils;
	import com.events.*;
	import com.views.*;
	import com.vos.*;
	
	import flash.display.DisplayObject;
	import flash.events.*;
	import flash.external.*;
	import flash.net.FileReference;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.events.*;
	import mx.managers.PopUpManager;
	import mx.utils.ObjectUtil;

	/* ************************************************************************
		The below import gets dropped automatically so if you encounter an error
		add this below statement to the list of imports at the top and leave 
		this comment block as is 
	***************************************************************************/
	//import flash.utils.getTimer; 
	[Bindable]
	/**
	  * This handles the program search logic.
	*/
	public class ProgramSearchManager extends EventDispatcher 
	{
 
		public var _arrAllTemplate:Array 		= new Array();
		public var _arrAllStatus:Array 	   		= new Array();		 
		public var _arrAllUserPositions:Array 	= new Array();
		public var _arrAllBuyingGroups:Array 	= new Array();
		public var _arrAllFamilyNames:Array 	= new Array();
		public var _arrAllBudgetClasses:Array 	= new Array();
		public var _arrAllBusinessSegments:Array = new Array();
		public var _arrAllUsers:Array 			= new Array();
		public var _arrAllRSP:Array 			= new Array();
		public var _arrAllProgram:Array    		= new Array("Created By", "RFA By", "CRA", "Approved By");
		public var _arrAllReportType:Array    	= new Array("Select Action for", "Delete"); 
		public var _arrAllConditions:Array		= new Array("Select Conditions", "Auto renewed", "Auto renew pairs", "Cancelled", "Disagreed","Doc attached", "Not Cancelled", "Revision", "Expiring No Revisions");   		
		private var arrImportItems:Array;
		public var _Template:Array		 	 	= new Array("Show All Templates");
		public var _UName:Array 		 		= new Array("Show All Users");
		public var _Positions:Array 		 	= new Array("Show All Positions");
		public var _RSP:Array 				 	= new Array("Show All RSP");
		public var _Report_List:Array		 	= new Array("Select Action for");
		public var _Conditions:Array		 	= new Array("Select Conditions");
		public var _Status:Array 			 	= new Array("Show All Status");
		public var _BusinessSegments:Array		= new Array("Show All " + sBusinessSegmentsLabel);
		public var _ProgramInfo:Array 		 	= new Array("Created By");
		public var UserAccess:Array 		 	= new Array();
			
		public var _iUserId:String				="";
		
		public var _BuyingGroups:String 	 = "";
		public var _FamilyName:String 		 = "";
		public var _BudgetClasses:String	 = "";

		public var _Program_Info:String 	 = "";
		public var _Distributor_Info:String  = "";
		public var _Operator_Info:String     = "";
		public var _Item_Info:String 		 = "";
		public var iMasterDataComplete:int	 = 0; 
		
		/* Start - variables that hold data on a temp basis
		to pass it on to loadResults(); */
		public var sProgramsTemp:String = "";
		public var iCatalogTemp:int = 0;
		public var sStartDateTemp:String = "";
		public var sEndDateTemp:String = "";
		public var iCreating_User_Position:int = 0;
		public var iInclude_work_in_progress_below_me:int = 0;

		/* End - variables that hold data on a temp basis
		to pass it on to loadResults(); */
		
		//public var vchStatus:String			 = "";
		//public var UserAccess:ArrayCollection = null;
		//public var _UserName:String 		 = "Show All Users";
		 			
		private var _UserPositionSelectedIndex:int = 0;
				
		/* **** Program popup variables* ****/
		public var StrProgramAutoRenewInfo:String = "";	
		public var StrInterfaceInfo:String = "";
		public var StrAttachmentInfo:String = "";
		public var acProgramSAPInfo:ArrayCollection = null;
		public var acProgramDetails:ArrayCollection = null;
		public var acCRADetails:ArrayCollection = null;
		public var acWorkflowData:ArrayCollection = null;
		public var acNRAData:ArrayCollection = null;
		public var StrProgramRevisionCount:String ="";
		public var StrGLAccount:String ="";
		public var StrQuoteLetters:String ="";
		public var arrProgramDistinctYears:Array = new Array();
		
		public var _sURL:String = "";
		private var _acProgramData:ArrayCollection = null;
		private var _objGridColumnSize:SearchGridColumnSize = new SearchGridColumnSize();
			
		public var arrValidItems:Array = new Array();
		public var arrInValidItems:Array = new Array();
		public var arrItemsToAdd:Array = new Array();
	 	public var popUp:UserItemLists;
	 	public var sPrgBuyingGroupLabel:String  = "";
	 	public var sPrgFamilyLabel:String = "";
	    //public var sPrgReadOnlyCatalogAccess:String = "";
        public var sRFAAgreed:String = "";	
        public var bBusinessSegment:Boolean;
	 	private var _arrProgramIdFilter:Array = new Array();
	 	private var _arrProgramIdUnderRevFilter:Array = new Array();
        public var bBidRequestTemplate:Boolean;
		public var sMassRFAProgramApprove:String = "";
		public var sApprovalSpendingCapOn:String = "";
		public var sDeleteProgramAccess:String = "";
		public var sDeleteIsCancelAutoRenew:String = "";
		public var bExactListMatchingOn:Boolean = false;
		public var bShowClaimRatesReport:Boolean = false;
		public var bShowPricingReport:Boolean = false;
		public var bRolloverProgramsOn:Boolean = false;
		public var bshowBestPlan:Boolean = false;
		public var bReleaseSettlement:Boolean = false;
		public var sProfileReleaseSettlement:String = "";
		public var bPgmPostApprovalStatus:Boolean = false;
		public var sharedObj:SharedObject;
		public var _soItems:SharedObject;
		public var _dSOlastSavedDate:Date = new Date(null);
		private var _dTodayDate:Date = new Date();
		public var sReload:String = "";
		public var sStatus:String = "";
		public var bDisplayTradeDollars:Boolean = false;						
		public var bDisplayPaymentDollars:Boolean = false;
		public var bDisplayVolume:Boolean = false;
		public var bshowBusinessSegment:Boolean = false;
		public var bDisplayOperatorInfo:Boolean = false;
		public var sDisplayTradeDollarsLabel:String = new String();					
		public var sDisplayPaymentDollarsLabel:String = new String();
		public var sDisplayVolumeLabel:String = new String();
		public var sBusinessSegmentsLabel:String = new String();	
		public var sOperatorIDLabel:String = new String();				
		public var sOperatorNameLabel:String = new String();
		
		public var iprogramLockTypeID:Number;
		public var arrCreateList:Array = new Array();
						
		// for xls export and file download
		private var downloadFileRef:FileReference = new FileReference();
		
		/**
 		 * This function is bound to event 'updCbProgramEvent'
 		 */	   	
		[Bindable (event="updCbProgramEvent")]
		public function get arrAllProgram():Array
		{	
			return _arrAllProgram;  
		}	
				  
 		/**
 		 * Gets a list of options ("Created By", "RFA By", "Approved By")
 		 * Calls event 'updCbProgramEvent'
 		 */			 
		public function fnGetProgram():void
		{
	  	  	dispatchEvent(new Event('updCbProgramEvent'));	
		} 
		
		/**
 		 * This function is bound to event 'updProgramDataEvent'
 		 */	 
		[Bindable (event="updProgramDataEvent")]
		public function get acProgramData():ArrayCollection
		{
			return _acProgramData;
		} 
		
		[Bindable (event="objGridColumnSizeChanged")]
		public function get objGridColumnSize():SearchGridColumnSize
		{
			return _objGridColumnSize;
		}
		public function set objGridColumnSize(objGridColumnSize:SearchGridColumnSize):void
		{
			this._objGridColumnSize = objGridColumnSize;
			dispatchEvent(new Event('objGridColumnSizeChanged'));
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

		/**
		 * Alerter() function is a function that is used in the MainEventMap
			to show alerts for testing the coding 
		 * @param xx
		 */					
		public function Alerter(xx:*):void
		{
			Alert.show(ObjectUtil.toString(xx));
			
		} 	
		
		/**
		 * Filter by Status Passed from the scorecard
		 * Calls event 'FILTER_STATUS_RESULTS'
		 */		
		public function FilterByStatus():void
		{	
			var e_Dispatcher:Dispatcher = new Dispatcher();
			var e:SearchProgramEvent = new SearchProgramEvent(SearchProgramEvent.FILTER_STATUS_RESULTS);
   			e.eStatus = this.sStatus;
   			e_Dispatcher.dispatchEvent(e);		
		}
		
		/**
		 * Sort Grid data based on the app setting column
		 * Calls event 'DATA_GRID_SORT'
		 */
		public function SortGridData():void
		{
			var e_Dispatcher:Dispatcher = new Dispatcher();
			var e:SearchProgramEvent = new SearchProgramEvent(SearchProgramEvent.DATA_GRID_SORT);
	   		e_Dispatcher.dispatchEvent(e); 						
		}
		
		/**
		 * Load program data on a temp basis from the CSV formatted query result
		 * @param ac
		 * @param showCatalog
		 * @param ArchiveYear
		 * @param Creating_User_Position
		 * @param Include_work_in_progress_below_me
		 
		 */	
		public function saveCSVData(ac:String,showCatalog:int,sStartDate:String,sEndDate:String,Creating_User_Position:int,Include_work_in_progress_below_me:int):void
		{
			/* These variables are used to hold on to the program data until
			   all the following are complete:
			   - HTTPService returns the program data
			   - The dropdowns (User, UserPosition,Status,Template) are populated
			*/
			sProgramsTemp = ac;
			iCatalogTemp = showCatalog;
			sStartDateTemp = sStartDateTemp;
			sEndDateTemp = sEndDate;
			iCreating_User_Position = Creating_User_Position;
			iInclude_work_in_progress_below_me = Include_work_in_progress_below_me;
			
			/* Inform that the program data from the database is available now. Since we are calling "CHECK_MASTER_DATA_COMPLETE",
			the "iMasterDataComplete" counter will be incremented by 1. This way we know that the program search data from db is ready to load.			
			(Note: When the data is being retrieved from the shared object, this function ("saveCSVData") is not called. "iMasterDataComplete" 
			counter will still be incremented by 1 but that way we will know that the shared object data is ready to load) */
			
			var e_Dispatcher:Dispatcher = new Dispatcher();
			var e:SearchProgramEvent = new SearchProgramEvent(SearchProgramEvent.CHECK_MASTER_DATA_COMPLETE);
			e_Dispatcher.dispatchEvent(e); 	
		}
		
		/**
		 * Load program data from the data loaded using saveCSVData()
		 * @param ac
		 * @param showCatalog
		 * @param ArchiveYear
		 * @param Creating_User_Position
		 * @param Include_work_in_progress_below_me
		 
		 */		
		public function loadResults(ac:String,showCatalog:int,sStartDate:String,sEndDate:String,Creating_User_Position:int,Include_work_in_progress_below_me:int):void 
		{
          var result : Array = [];
		  var sub:Number = 0;
		  var item:Object = null;
		  var arData:Array;
		  var arr:Array = ac.split( "\n" );
		  var pattern_contract_number:RegExp = /000-/;
		  var strReplacedContractNumber:String;
		  var strRevisionVersion:String;
		  var strReplacedRevisionVersion:String;
		  var iStatus:int;
		
          // set column names from the first row
          var _arColumnNames:Array;
          _arColumnNames = arr[0].split(",");
       	
       	/* Sometimes there is an error and flex does not return even the header. I am
       	   checking for the existence of the "contract_number" column in the header.
       	*/
       	 if(_arColumnNames.indexOf('contract_number') != -1)
       	 {
			// loop over each row (separated by line feed)
         	for each ( var str : String in arr )
			{
				/* Sometimes there could be empty lines at the end of the dataset. Empty lines have a length of 1. 
				So, looking for length greater than 1 is fine.
				*/
				if(str.length > 1)
				{
					arData = str.split(",");
	            	item = new Object();
	            	sub = 0;
	            	
	            	// loop over each column (separated by comma)
	            	for each (var sData : String in arData)
					{		
						/* Convert start date and end date into date format */
						if(_arColumnNames[sub] == 'contract_start_date' || _arColumnNames[sub] == 'contract_end_date')
						{
							item[_arColumnNames[sub]] = new Date(sData);
						}
						/* Convert "rfa age" column to int for sorting */
						else if(_arColumnNames[sub] == 'rfa_age' && sData.length > 0)
						{
							item[_arColumnNames[sub]] = new int(sData);
						}
						/* So that sorting works correctly for the "rfa age" column, blank values need to convert to 0.
						All rows need to have the same dataType for sorting to work correctly. If data is blank for some rows,
						sorting will fail.
						*/
						else if(_arColumnNames[sub] == 'rfa_age' && sData.length == 0)
						{
							item[_arColumnNames[sub]] = 0;
						}										
						else
						{
						item[_arColumnNames[sub]] = sData;
						}						
						sub++;
					}
						result.push(item);
				}
			}

		     // first row is the header and should be deleted from the data array
             result.splice(0, 1);
         }
         else
         {
         	Alert.show("Either the session has timed out OR there is some other issue. Please click on the 'Logout' button and login again OR contact your System Administrator.");
         }
             this._acProgramData = new ArrayCollection(result);    

			/* This is the default loading condition. 
			- A shared Object has previously not been loaded
			  for the user for that day
			- The data requested is not catalog data
			- We are not searching for data for a specific year
			(This condition is also called when we choose "Current" 
		 	from the dropdown, as long as the above conditions
		 	are true)
			*/		
		if(showCatalog != 1 && sStartDate == '' && sEndDate == '' && Include_work_in_progress_below_me == 0)
		{
			dispatchEvent(new Event('updProgramDataEvent'));
			this.saveSOitems();				
		}
		else
		{
		/* Always get the data from the server for Catalog and Archive Year options.
		   Currently the cached shared object option does not exist for it
		 */
		
		 /* If the data requested is Catalog Data. This condition is even
		 	called even when the shared Object does not exist for the day,
		 	which means, when the "Catalog" option is the first
		 	action taken by the user on a day
		  */
		  if(showCatalog == 1)
		  {
			dispatchEvent(new Event('updProgramDataEvent'));
		  }
		  /* If the data requested is for a partular year */
		  else
		  {
		  	dispatchEvent(new Event('updProgramDataEvent'));
		  }
		}
		/* Filter only when the Status Exists. Do not do it for Catalog Status.
		   as it is not actually a status. It is actually another option on the
		   scorecard	
		*/
		if(this.sStatus != null && this.sStatus != '' && this.sStatus != 'Show All Status' && this.sStatus != 'Catalog')		
		{
			FilterByStatus();
			
			/* Set the status to blank as it is not used once the data is loaded */
			this.sStatus = '';
		}
		else
		{
			/* Sort the data grid by the default value */
			SortGridData();		
		}	
				// TESTING perf of SharedObjects
				//sharedObj = SharedObject.getLocal("distributors");
				//sharedObj.data.itemList = ac;
				//sharedObj.flush();
		}
		/* used for test of shared objects 
		public function showResults():void 
			{
				sharedObj = SharedObject.getLocal("programs","/");
				this._acProgramData = sharedObj.data.programList;
				sDataLoadType = 'Current';
				dispatchEvent(new Event('updProgramDataEvent'));
			}*/
		
		/**
		 * Set the saved date of the shared object
		 */		
		public function setdSOlastSavedDate():void
			{
				/* save shared object for the user based on UserID */
				this._soItems = SharedObject.getLocal("programs_"+_iUserId,"/");	

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
		 * This function decided whether to load the data from db or shared object
		 * @param Status
		 * @param ArchiveYear
		 * @param userId
		 * @param showCatalog
		 * @param Creating_User_Position
		 * @param Include_work_in_progress_below_me
		 */		
		public function loadSOitems(Status:String,sStartDate:String,sEndDate:String,userId:String,showCatalog:int,Creating_User_Position:int,Include_work_in_progress_below_me:int):void 
			{	
			
			 this.sStatus = Status;
			 
			 var e_Dispatcher:Dispatcher = new Dispatcher();
			 
			 /* Get the width for the grid columns */
			 var e6:SearchProgramEvent = new SearchProgramEvent(SearchProgramEvent.GET_ALL_COLUMNS_SIZE);
			 e6.userId = _iUserId;
			 e_Dispatcher.dispatchEvent(e6);	

			/* We get data from the database for catalog and Archive year searches
			   and so we do not need the "Date as of" date, as the data is always current.
			   Also, when we click on the 'Catalog' radio button, we hide the "Current" 
			   and "Year" options
			*/
			if(showCatalog == 1 || (sStartDate != '' && sEndDate != '') || this.sStatus == 'Catalog')
			{
				var e:SearchProgramEvent = new SearchProgramEvent(SearchProgramEvent.HIDE_INFO);
       			e_Dispatcher.dispatchEvent(e);	
       			
       			var e1:SearchProgramEvent = new SearchProgramEvent(SearchProgramEvent.SELECT_OPTIONS_CATALOG);
       			e_Dispatcher.dispatchEvent(e1);	
			}
			else
			{
				/* Now show the "Current" and "Year" options */
				var e2:SearchProgramEvent = new SearchProgramEvent(SearchProgramEvent.SHOW_INFO);
       			e_Dispatcher.dispatchEvent(e2);
       			
       			var e3:SearchProgramEvent = new SearchProgramEvent(SearchProgramEvent.SELECT_OPTIONS_PROGRAM);
       			e_Dispatcher.dispatchEvent(e3);
			}
			
			/* Load Catalog data */
			if(this.sStatus == 'Catalog')
			{
	    		var e4:SearchProgramEvent = new SearchProgramEvent(SearchProgramEvent.GET);
	    			e4.userId 		=  _iUserId;
					e4.sStartDate	= '';
					e4.sEndDate	= '';
					e4.showCatalog 	= 1;
					e4.eStatus 		= 'Catalog';
       			e_Dispatcher.dispatchEvent(e4);		
			}
			else
			{

				// 1.) go get our SO
				this.setdSOlastSavedDate();
				var strAlertMessage:String = "";
				/* "sReload" is blank by default. It is set to '1' when a user opens a new window 
				   in CF to cancel, purge , delete, Mass Approve, Edit Won/Loss Bid Status etc a program. 
				   We need to make a db call to get the latest program data and not show the cached shared 0bject. 
				   "sReload" is passed to ProgramSearchFx.cfm as a flash variable.Do not take this action when
				   searching data for a particular year   
				*/
				// 2.) if we got a keeper
			    if (this._soItems.size && (sReload == '' || sReload == null)  && (sStartDate == '' && sEndDate == '') && Include_work_in_progress_below_me == 0)
			    {	//Alert.show(this._soItems.data.dSavedDate + ': last Saved   ' + this._soItems.data.name);
			    	// 3.) if we have a saved date
			        //moved into setdSOlastSavedDate()
			    	// 4.) if our 'up to date' dSOlastSavedDate is the same DATE (not 24 hour and not hr/min) as today (dTodayDate), proceed					

			    	if(	( this._dSOlastSavedDate.getFullYear() == this._dTodayDate.getFullYear() ) && 
			    		( this._dSOlastSavedDate.getMonth() == this._dTodayDate.getMonth() ) &&
			    		( this._dSOlastSavedDate.getDate() == this._dTodayDate.getDate() ) )
			    	{
			    		if( ( this._soItems.data.programList != undefined ) &&
			    			( this._soItems.data.programList != null ) &&
			    			( this._soItems.data.programList.length >= 0 ) )
				    	{
							/* All the data available to load program search data is ready */
							if(this.iMasterDataComplete >= 5){
					    		// 5.) this._itemList from so
								
								loadDataFromSharedObject();
			    				//strAlertMessage += "sent incoming SO to itemResults() from loadSOitems()\n";
			    				//Alert.show("data from SO::" + this._soItems.data.dSavedDate + '   :::   ' + new Date());
							}
							else{								
								/* Inform that the program data from shared object is available now. Since we are calling "CHECK_MASTER_DATA_COMPLETE",
								the "iMasterDataComplete" counter will be incremented by 1. This way we know that the program search data from shared object is ready to load.			
								(Note: When the data is being retrieved from the database (not shared object), this logic will not be executed. "iMasterDataComplete" 
								counter will still be incremented by 1 but that way we will know that the database data is ready to load) */
							
								var evt:SearchProgramEvent = new SearchProgramEvent(SearchProgramEvent.CHECK_MASTER_DATA_COMPLETE);
								e_Dispatcher.dispatchEvent(evt); 			
							}
				    	}
				    	else
				    	{
				    		// a.) go get the items from the db
				    		dispatchSearchEventGet(sStartDate,sEndDate,userId,showCatalog,Creating_User_Position,Include_work_in_progress_below_me);
				    		//Alert.show(this._soItems.data.dSavedDate + ': a   ');
				    	}
			    	}
			    	else
			    	{
			    		// b.) go get the items from the db
			    		dispatchSearchEventGet(sStartDate,sEndDate,userId,showCatalog,Creating_User_Position,Include_work_in_progress_below_me);  
			    		//Alert.show(this._soItems.data.dSavedDate + ': b   ');		
			    	}
			    }	
			    else
			    {
			    	// c.) go get the items from the db
		    			dispatchSearchEventGet(sStartDate,sEndDate,userId,showCatalog,Creating_User_Position,Include_work_in_progress_below_me);
		    		//Alert.show(this._soItems.data.dSavedDate + ': c  ');
			    }			
			  }   
				/* Reset the data column sequence and the hide/show status of that column based on the data from the db. */
				var es:SearchProgramEvent = new SearchProgramEvent(SearchProgramEvent.RESET_COLUMN_ORDER);
				e_Dispatcher.dispatchEvent(es);					
			}
		
		
		private function loadDataFromSharedObject():void{
		
			// 5.) this._itemList from so
			this._acProgramData = _soItems.data.programList as ArrayCollection;
			//this.updFilters();
			
			/* If the user visits from the scorecard from a particular program status, then
			when the user selects any other option from the data view dropdown (For eg: catalog),
			and then reselects "Current", we only see the original status filtered records
			without using "this._acProgramData.filterFunction = null;"
			*/
			this._acProgramData.filterFunction = null;
			
			dispatchEvent(new Event('updProgramDataEvent'));
			
			/* Filter by Status Passed from the scorecard */
			FilterByStatus();
			
			/* If there are any previously checked items in the shared object, uncheck them */
			var e_Dispatcher:Dispatcher = new Dispatcher();
			var e5:SearchProgramEvent = new SearchProgramEvent(SearchProgramEvent.UNCHECK_SELECTED);
			e_Dispatcher.dispatchEvent(e5);
			
			/* Sort the data grid by the default value */			
			SortGridData();	
			
			/* Set the status to blank as it is not used once the data is loaded */
			this.sStatus = ''
		}
		
		private function saveSOitems():void{
			
			var d:Date = new Date();			
			this._soItems.data.dSavedDate = d;
			this._soItems.data.programList = this._acProgramData;
			//Alert.show(this._acProgramData.length.toString()):
			/* If the shared object does not exist, then write the data to it. */		 
			if(!this._soItems.data.customObject)
			{
				this._soItems.flush(10000000);
		 	}		 	
		 	this._dSOlastSavedDate = d;		  		
		  	dispatchEvent(new Event('eSOlastSavedDate'));
		  	//Alert.show("saved::" + this._soItems.data.dSavedDate;
		  	/*  W2k3 Path ex.-> C:\Documents and Settings\msaunders.INTRA\Application Data\Macromedia\Flash Player\#SharedObjects\YCZDZE3T\sirius */
		    //strAlertMessage += "saveSOitems()\n";
		   // Alert.show(strAlertMessage);	
		}	
			
		/**
		 * Check whether the dropdowns (User, UserPosition,Status,Template) and program data are loaded
		 */		
		public function checkMasterDataComplete():void{
				this.iMasterDataComplete = this.iMasterDataComplete + 1;			
				
				/* There are 5 data objects we are looking for before the program data is loaded -
				   - 1. program data (Either from the db OR from the shared object)
				   - Data from the following dropdowns-
				     (2. User, 3. UserPosition,4. Status,5. Template)
				
				     Since sometimes, the program data is available even before the dropdowns are loaded,
				     the flex grid does not get loaded with any data. To check for existence of data in
				     these dropdowns is important because the program data needs those dropdowns
				     to populate its own data from ID's to description.
					 The loading of data also relies on the settings from the "ProgramSettingsManager".
				     I am using >=5 because, after the initial load, refreshing the date or
				     getting data using the Archive Year will increment the counter and so (">=") will always
					 work as the counter gets incremented.
				*/

				/* "this.iMasterDataComplete" will be at least 5 while loading data.*/
				if(this.iMasterDataComplete >= 5)
				{					
					/* This is when data is retrived from the db */
					if(sProgramsTemp.length > 1){
							loadResults(sProgramsTemp,iCatalogTemp,sStartDateTemp,sEndDateTemp,iCreating_User_Position,iInclude_work_in_progress_below_me);
					 }
					else{
						 /* This is when data is retrieved from the shared object */
						 var e_Dispatcher:Dispatcher = new Dispatcher();
						 
						 /* The loading of data relies on the settings. While testing, the value of "sScorecardSortOption" was null on 
						 "ProgramSearchPanel.mxml". That is why I added loading of data (LOAD_SO_ITEMS) below. Since this gets called 
						 after the settings are loaded, "sScorecardSortOption" is available for sorting the data. */
						 var e:SearchProgramEvent = new SearchProgramEvent(SearchProgramEvent.LOAD_SO_ITEMS);	
						 e.eStatus = this.sStatus;
						 e.sStartDate	= '';
						 e.sEndDate	= '';
						 e.userId =  _iUserId;
						 e.showCatalog = 0;
						 e.Creating_User_Position = iCreating_User_Position;
						 e.Include_work_in_progress_below_me = iInclude_work_in_progress_below_me;
						 e_Dispatcher.dispatchEvent(e);
					 }
				}
		}

		private function dispatchSearchEventGet(sStartDate:String,sEndDate:String,userId:String,showCatalog:int,Creating_User_Position:int,Include_work_in_progress_below_me:int):void{
		var e_Dispatcher:Dispatcher = new Dispatcher();
		var e:SearchProgramEvent = new SearchProgramEvent(SearchProgramEvent.GET);

		e.sStartDate	= '';
		e.sEndDate	= '';
		e.userId = userId;
		e.showCatalog = showCatalog;
		e.Creating_User_Position = Creating_User_Position;
		e.Include_work_in_progress_below_me = Include_work_in_progress_below_me;
   		e_Dispatcher.dispatchEvent(e);
		}

		/**
		 * Search for programs based on keyword 
		  (Distributor, Operator, Item, Buying Group, Family and certain statuses)
		 * @param o
		 */		
		public function setRoFilter(o:Object):void
		{		
				/*
				Stores the programs based on search of the following:
		   		Distributor, Operator, Item, Buying Group, Family, and statuses - pending approval and agreed
				*/
				this._arrProgramIdFilter = o.F;
				/*
				Stores the programs based on search of the programs "Under Review"	   		
				*/
				this._arrProgramIdUnderRevFilter = o.U;	
				
				/* Reset the scrollbar position to the top. This happens after the sql server filter.
				   This code is also called seperately after local filter on flex.
		 		*/
				var e_Dispatcher:Dispatcher = new Dispatcher();
				var e:SearchProgramEvent = new SearchProgramEvent(SearchProgramEvent.RESET_SCROLLBAR_POSITION);
       			e_Dispatcher.dispatchEvent(e);
						
		}
		
 		/**
 		 * This function is bound to event 'updCbTemplateEvent'
 		 */	
		[Bindable (event="updCbTemplateEvent")]
		public function get arrAllTemplate():Array
		{	
			return _arrAllTemplate; 
		}
		 
 		/**
 		 * Gets a list of templates 
 		 * @param aTemplateResult
 		 * Calls event 'updCbTemplateEvent'
 		 */		
 		public function fnGetAllTemplate(aTemplateResult:ArrayCollection):void
 		{
			_arrAllTemplate = aTemplateResult.source;
			_arrAllTemplate.unshift("Show All Templates");
			dispatchEvent(new Event('updCbTemplateEvent'));
			
			/* Inform that the template data is available now */
			var e_Dispatcher:Dispatcher = new Dispatcher();
			var e:SearchProgramEvent = new SearchProgramEvent(SearchProgramEvent.CHECK_MASTER_DATA_COMPLETE);
			e_Dispatcher.dispatchEvent(e); 	
	  	}
		  
		 /**
 		 * This function is bound to event 'updCbStatusEvent'
 		 */	  		
		[Bindable (event="updCbStatusEvent")]
		public function get arrAllStatus():Array
		{	
			return _arrAllStatus; 
		} 
		
		/**
 		 * Gets a list of statuses. Also decides whether the user sees "Agreed","Pending Approval" and "Under Review" 
 		 * @param aStatusResult
 		 * Calls event 'updCbStatusEvent'
 		 */	
		public function fnGetAllStatus(aStatusResult:ArrayCollection):void
		{
	        _arrAllStatus = aStatusResult.source;

	    	if(sRFAAgreed == '1')
	    	{
	    		_arrAllStatus.push("Agreed"); 
	    		_arrAllStatus.push("Pending Approval");
	    		_arrAllStatus.push("Under Review");
	    	}
	    		_arrAllStatus.push("Approved");
	    		
	    	if(bPgmPostApprovalStatus == true)
	    	{	
	    		_arrAllStatus.push("Pending ERP Research"); 
	    		_arrAllStatus.push("Pending ERP Entry");
	    	}
	    	    	
	    		_arrAllStatus.unshift("Show All Status"); 
	    	
	    	dispatchEvent(new Event('updCbStatusEvent'));
	    	
	    	/* Inform that the status data is available now */
			var e_Dispatcher:Dispatcher = new Dispatcher();
			var e:SearchProgramEvent = new SearchProgramEvent(SearchProgramEvent.CHECK_MASTER_DATA_COMPLETE);
			e_Dispatcher.dispatchEvent(e); 	
			 }
		 
		/**
 		 * This function is bound to event 'updCbUserPositionEvent'
 		 */	   
		[Bindable (event="updCbUserPositionEvent")]
		public function get arrAllUserPositions():Array
		{	
			return _arrAllUserPositions; 
		} 
		
		/**
 		 * Gets a list of user positions
 		 * @param aUserPositionsResult
 		 * Calls event 'updCbUserPositionEvent'
 		 */	
		public function fnGetAllUserPositions(aUserPositionsResult:ArrayCollection):void
		{
			_arrAllUserPositions = aUserPositionsResult.source;
	    	_arrAllUserPositions.unshift("Show All Positions");
	    	dispatchEvent(new Event('updCbUserPositionEvent'));
	    	
	    	/* Inform that the user position data is available now */
			var e_Dispatcher:Dispatcher = new Dispatcher();
			var e:SearchProgramEvent = new SearchProgramEvent(SearchProgramEvent.CHECK_MASTER_DATA_COMPLETE);
			e_Dispatcher.dispatchEvent(e); 		    	
		 }
		
		/**
 		 * This function is bound to event 'updCbBuyingGroupsEvent'
 		 */	
		[Bindable (event="updCbBuyingGroupsEvent")]
		public function get arrAllBuyingGroups():Array
		{	
			return _arrAllBuyingGroups; 
		}
		 
	 	/**
 		 * Gets a list of buying groups
 		 * @param aBuyingGroupsResult
 		 * Calls event 'updCbBuyingGroupsEvent'
 		 */	
		public function fnGetAllBuyingGroups(aBuyingGroupsResult:ArrayCollection):void
		{
		 	_arrAllBuyingGroups = aBuyingGroupsResult.source;
	    	_arrAllBuyingGroups.unshift("Show All " + sPrgBuyingGroupLabel);
	    	dispatchEvent(new Event('updCbBuyingGroupsEvent'));
		}
		
		/**
 		 * This function is bound to event 'updCbFamilyNamesEvent'
 		 */	
		[Bindable (event="updCbFamilyNamesEvent")]
		public function get arrAllFamilyNames():Array
		{	
			return _arrAllFamilyNames; 
		}
		
		/**
		 * Gets a list of families
		 * @param aFamilyNameResult
		 * Calls event 'updCbFamilyNamesEvent'
		 */	
		public function fnGetAllFamilyNames(aFamilyNameResult:ArrayCollection):void
		{
			_arrAllFamilyNames = aFamilyNameResult.source;
			_arrAllFamilyNames.unshift("Show All "+ sPrgFamilyLabel);
			dispatchEvent(new Event('updCbFamilyNamesEvent'));
		}
		
		/**
		 * This function is bound to event 'updCbBudgetClassesEvent'
		 */	
		[Bindable (event="updCbBudgetClassesEvent")]
		public function get arrAllBudgetClasses():Array
		{	
			return _arrAllBudgetClasses; 
		}
				
		/**
		 * Gets budget classes
		 * @param aBudgetClassResult
		 * Calls event 'updCbBudgetClassesEvent'
		 */	
		public function fnGetBudgetClasses(aBudgetClassResult:ArrayCollection):void
		{
			_arrAllBudgetClasses = aBudgetClassResult.source;
			_arrAllBudgetClasses.unshift("Show All Budget Class");
			dispatchEvent(new Event('updCbBudgetClassesEvent'));
		}
		
		/**
		 * This function is bound to event 'updCbBusinessSegmentsEvent'
		 */	
		[Bindable (event="updCbBusinessSegmentsEvent")]
		public function get arrAllBusinessSegments():Array
		{	
			return _arrAllBusinessSegments; 
		}		
		
		public function fnGetBusinessSegments(aBusinessSegmentsResult:ArrayCollection):void
		{
			_arrAllBusinessSegments = aBusinessSegmentsResult.source;
			_arrAllBusinessSegments.unshift("Show All " + sBusinessSegmentsLabel);
			dispatchEvent(new Event('updCbBusinessSegmentsEvent'));
		}		

		private function clone(source:Object):*
		{
			var baObj:ByteArray = new ByteArray();
			baObj.writeObject(source);
			baObj.position = 0;
			return(baObj.readObject());
		}
		
		/**
 		 * Gets a list of users and positions
 		 * @param aUsersAndPositionsResult
 		 * Calls function 'fnGetUsers' and 'fnGetRSP'
 		 */	  
		public function fnGetUsersAndPositions(aUsersAndPositionsResult:ArrayCollection):void
		{
			var acGetUsers:ArrayCollection = new ArrayCollection(clone(aUsersAndPositionsResult.source));
			var acGetRSPTmp:ArrayCollection = new ArrayCollection(clone(aUsersAndPositionsResult.source));		
			var arrRSP:Array = new Array();
			
			/* Loop through the "users" arrayCollection */
			for each(var oItem:Object in acGetRSPTmp)
			{	/* Populate an array with the users who are "Eligible_RSP". */
				if(oItem['Is_Eligible_RSP'] == true)
				{
					arrRSP.push(oItem);						
				}
			}	
			
			/* Populate the RSP arrayCollection */
			var acGetRSP:ArrayCollection = new ArrayCollection(arrRSP);
			fnGetUsers(acGetUsers);
			fnGetRSP(acGetRSP);
		}
				
		/**
 		 * This function is bound to event 'updCbUsersEvent'
 		 */	
		[Bindable (event="updCbUsersEvent")]
		public function get arrAllUsers():Array
		{	
			return _arrAllUsers; 
		}	
			
		/**
 		 * Gets a list of users
 		 * @param aUsersResult
 		 * Calls event 'updCbUsersEvent'
 		 */	  
		public function fnGetUsers(aUsersResult:ArrayCollection):void
		{
			_arrAllUsers = aUsersResult.source;
	 		_arrAllUsers.unshift("Show All Users");
	  	  	dispatchEvent(new Event('updCbUsersEvent'));
	  	  	
	  	  	/* Inform that the user data is available now */
			var e_Dispatcher:Dispatcher = new Dispatcher();
			var e:SearchProgramEvent = new SearchProgramEvent(SearchProgramEvent.CHECK_MASTER_DATA_COMPLETE);
			e_Dispatcher.dispatchEvent(e);	  	  		
		} 
		 
		/**
 		 * This function is bound to event 'updCbRSPEvent'
 		 */	  
		[Bindable (event="updCbRSPEvent")]
		public function get arrAllRSP():Array
		{	
			return _arrAllRSP;  
		}	
				  
		/**
 		 * Gets a list of RSP
 		 * @param aRSPResult
 		 * Calls event 'updCbRSPEvent'
 		 */	 
		public function fnGetRSP(aRSPResult:ArrayCollection):void
		{
			_arrAllRSP = aRSPResult.source;
			/* Add at the beginning of the array */
	 		_arrAllRSP.unshift("Show All RSP");
			/* Add at the end of the array */
			_arrAllRSP.push("Vacant");
	  	  	dispatchEvent(new Event('updCbRSPEvent'));	
		} 	
				
		/**
 		 * This function is bound to event 'updCbConditionsEvent'
 		 */	
		[Bindable (event="updCbConditionsEvent")]
		public function get arrAllConditions():Array
		{			
			return _arrAllConditions;  
		}	
		
		/**
 		 * Gets a list of options including Auto renewed, Cancelled, Doc attached, Not Cancelled, Revision, and Rollover
 		 * Calls event 'updCbConditionsEvent'
 		 */	
		public function fnGetConditions():void
		{		
			if(bshowBestPlan == true)
			{
				_arrAllConditions.push("Best Plan Programs");
			}
			
			if(bRolloverProgramsOn == true)
			{
				 _arrAllConditions.push("Rollover");
			}		
			
			if(bReleaseSettlement == true)
			{			
				_arrAllConditions.push("Released");
				_arrAllConditions.push("Not Released");
			}
			
			if(iprogramLockTypeID != 0)
			{
				_arrAllConditions.push("Acknowledged");
				_arrAllConditions.push("Not Acknowledged");								
			}
			
			_arrAllConditions.push("Uploaded");		
			
	  	  	dispatchEvent(new Event('updCbConditionsEvent'));
		} 
				
		/**
 		 * This function is bound to event 'updCbReportTypeEvent'
 		 */	
		[Bindable (event="updCbReportTypeEvent")]
		public function get arrAllReportType():Array
		{	
			return _arrAllReportType;  
		}	
				  
		/**
 		 * Gets a list of options including claim rates, pricing, delete, "Edit Won/Lost Status and Mass Approve
 		 * Calls event 'updCbReportTypeEvent'
 		 */	
		public function fnGetReportType():void
		{	
			/* 
			D40930: KAL: Commented below two options 
			-- Claim rates is moved out of program search to the home page 
			-- Pricing report is depricated
			
			if(bShowClaimRatesReport == true)
			{
				 _arrAllReportType.push("Claim Rates");
			}	
			if(bShowPricingReport == true)
			{
				 _arrAllReportType.push("Pricing");
			}
			*/
			
			if(this.bBidRequestTemplate == true)
			{
				 _arrAllReportType.push("Edit Won/Lost Status");				 
			}
			if(sMassRFAProgramApprove == '1')
			{
				 _arrAllReportType.push("Mass Approve");				 
			}
			
			if(bReleaseSettlement == true && sProfileReleaseSettlement == '1')
			{			
				_arrAllReportType.push("Release");
			}				
	  	  	dispatchEvent(new Event('updCbReportTypeEvent'));
		}  
		
		/**
 		 * This function is bound to event 'getBidRequestTemplateEvent'
 		 */	
		[Bindable (event="getBidRequestTemplateEvent")]
		public function get getBidRequestTemplate():Boolean
		{
			return bBidRequestTemplate;  
		}	
			
		/**
 		 * Checks whether any template has "BidRequest" ON
 		 * @param BidRequestTemplate
 		 * Calls event 'getBidRequestTemplateEvent'
 		 */		  
		public function fnGetBidRequestTemplate(BidRequestTemplate:Boolean):void{
			bBidRequestTemplate = BidRequestTemplate;
			this.bBidRequestTemplate = BidRequestTemplate;
	  	  	dispatchEvent(new Event('getBidRequestTemplateEvent'));	
		}  
		
		/* 		
		[Bindable (event="updCbFilters")]
		public function updFilters():void
		{	 
			this._acProgramData.toArray().forEach(getUniqueFilters);
			this.sortFilters();
		} 
		*/	
		
		/**
 		 * This function is bound to event 'updUserPositionSelectedIndexEvent'
 		 */			
		[Bindable (event="updUserPositionSelectedIndexEvent")]
		public function get UserPositionSelectedIndex():int
		{	
			return _UserPositionSelectedIndex;
		}
	
		/**
 		 * The user position should be the same as the position of the user selected
 		 * @param UserName
 		 * Calls event 'updUserPositionSelectedIndexEvent'
 		 */	
		public function Set_User_Position(UserName:String):void
		{
        for (var i: int = 1; i < _arrAllUserPositions.length; i++) 
        { 
          if(UserName !='')
          {          	
       		if(_arrAllUserPositions[i].User_Positions_ID == UserName)
       		{
       		 _UserPositionSelectedIndex = i;
       		 break;
       		}  
       	  }
       	  /* If the search is for 'Show All Users' */
       	  else
       	  {
       	   	 _UserPositionSelectedIndex = 0;
       		 break;
       	  }
        }

        dispatchEvent(new Event('updUserPositionSelectedIndexEvent'));
		
		/* Filter programs right after the "user position" is selected.
		This has been added here due to a timing issue.
		*/
		var e_Dispatcher:Dispatcher = new Dispatcher();
		var eFilter:SearchProgramEvent = new SearchProgramEvent(SearchProgramEvent.FILTER_PROGRAMS);
		e_Dispatcher.dispatchEvent(eFilter);
		
   		} 
   		
   		/**
 		 * This function is bound to event 'getProgramAutoRenewInfoEvent'
 		 */		
		[Bindable (event="getProgramAutoRenewInfoEvent")]
		public function get getProgramAutoRenewInfo():String
		{	
			return StrProgramAutoRenewInfo; 
		}	
				  
		/**
 		 * Get program renewal info - whether renewed or to be renewed
 		 * @param AutoRenewInfo
 		 * Calls event 'getProgramAutoRenewInfoEvent'
 		 */	 
		public function fnGetProgramAutoRenewInfo(AutoRenewInfo:String):void
		{
			StrProgramAutoRenewInfo = AutoRenewInfo;
	  	  	dispatchEvent(new Event('getProgramAutoRenewInfoEvent'));	
		} 	 
		
		/**
 		 * This function is bound to event 'getStrInterfaceInfoEvent'
 		 */	
		[Bindable (event="getStrInterfaceInfoEvent")]
		public function	get getInterfaceInfo():String
		{	
			return StrInterfaceInfo;  
		}			  
		
		/**
 		 * Get program Interface (ERP) info
 		 * @param InterfaceInfo
 		 * Calls event 'getStrInterfaceInfoEvent'
 		 */	  
		public function fnGetInterfaceInfo(InterfaceInfo:String):void
		{
			StrInterfaceInfo = InterfaceInfo;
	  	  	dispatchEvent(new Event('getStrInterfaceInfoEvent'));	
		} 	
		  
		/**
 		 * This function is bound to event 'getStrAttachmentInfoEvent'
 		 */	
		[Bindable (event="getStrAttachmentInfoEvent")]
		public function get getAttachmentInfo():String
		{	
			return StrAttachmentInfo;  
		}
					  
		/**
 		 * Get program attachment info
 		 * @param AttachmentInfo
 		 * Calls event 'getStrAttachmentInfoEvent'
 		 */	  
		public function fnGetAttachmentInfo(AttachmentInfo:String):void
		{
			StrAttachmentInfo = AttachmentInfo;
	  	  	dispatchEvent(new Event('getStrAttachmentInfoEvent'));	
		} 	  		 
		
		/**
 		 * This function is bound to event 'getStrProgramSAPInfoEvent'
 		 */	
		[Bindable (event="getStrProgramSAPInfoEvent")]
		public function get getProgramSAPInfo():ArrayCollection
		{	
			return acProgramSAPInfo;  
		}	
				  
		/**
 		 * Get program SAP reference numbers
 		 * @param ProgramSAPInfo
 		 * Calls event 'getStrProgramSAPInfoEvent'
 		 */	 
		public function fnGetProgramSAPInfo(ProgramSAPInfo:ArrayCollection):void
		{
			acProgramSAPInfo = ProgramSAPInfo;
	  	  	dispatchEvent(new Event('getStrProgramSAPInfoEvent'));	
		}
		
		/**
 		 * This function is bound to event 'getProgramDetailsEvent'
 		 */	
		[Bindable (event="getProgramDetailsEvent")]
		public function get getProgramDetails():ArrayCollection
		{	
			return acProgramDetails;  
		}
		
		/**
 		 * Get program details for the pop up
 		 * @param ProgramDetails
 		 * Calls event 'getProgramDetailsEvent'
 		 */	
		public function fnGetProgramDetails(ProgramDetails:ArrayCollection):void
		{
			acProgramDetails = ProgramDetails;
	  	  	dispatchEvent(new Event('getProgramDetailsEvent'));
	  	  	/* If the status is 2, get CRA Info. Status is 2 for
	  	  	   RFA, Agreed,Under Review and Pending Approval.
	  	  	*/
	  	  	/* We will always disptch getCRADetails and getNRADetails
	  	  	if(ProgramDetails.getItemAt(0).Contract_Status_Type_IDX == 2)
	  	  	{
	  	  	*/
	  	  	var e_Dispatcher:Dispatcher = new Dispatcher();
			var e:SearchProgramEvent = new SearchProgramEvent(SearchProgramEvent.GET_CRA_DETAILS);
       		e.eCRADetailsInfo = ProgramDetails.getItemAt(0).Contract_Main_ID;         
	        e.eResponsibleUserIDInfo = ProgramDetails.getItemAt(0).Responsible_User_ID;
       		e_Dispatcher.dispatchEvent(e);
       				
			var ev_Dispatcher:Dispatcher = new Dispatcher();
			var ev:SearchProgramEvent = new SearchProgramEvent(SearchProgramEvent.GET_NRA_DATA);
       		ev.eNRAData = ProgramDetails.getItemAt(0).Contract_Main_ID;    
       		ev_Dispatcher.dispatchEvent(ev);
       		/*
			} 
			*/ 
		}

		/**
 		 * This function is bound to event 'getBusinessSegmentSettingEvent'
 		 */	
		[Bindable (event="getBusinessSegmentSettingEvent")]
		public function get getBusinessSegmentSetting():Boolean
		{	
			return bBusinessSegment;  
		}
		
		/**
 		 * Whether the business segment is ON
 		 * @param BusinessSegmentSetting
 		 * Calls event 'getBusinessSegmentSettingEvent'
 		 */	
		public function fnGetBusinessSegmentStatus(BusinessSegmentSetting:Boolean):void
		{
			bBusinessSegment = BusinessSegmentSetting;
	  	  	dispatchEvent(new Event('getBusinessSegmentSettingEvent'));	
		}  
		
		/**
 		 * This function is bound to event 'getCRADetailsEvent'
 		 */	
		[Bindable (event="getCRADetailsEvent")]
		public function get getCRADetails():ArrayCollection
		{	
			return acCRADetails;  
		}
		
		/**
 		 * Get program CRA infp
 		 * @param CRADetails
 		 * Calls event 'getCRADetailsEvent'
 		 */	
		public function fnGetCRADetails(CRADetails:ArrayCollection):void
		{
			acCRADetails = CRADetails;
	  	  	dispatchEvent(new Event('getCRADetailsEvent'));	
		} 
		
		/**
 		 * This function is bound to event 'getWorkflowData'
 		 */	
		[Bindable (event="getWorkflowData")]
		public function get getWorkflowData():ArrayCollection
		{	
			return acWorkflowData;  
		}
		
		/**
 		 * Get program Workflow data
 		 * @param WorkflowData
 		 * Calls event 'getWorkflowData'
 		 */	
		public function fnGetWorkflowData(WorkflowData:Array):void
		{
			acWorkflowData = new ArrayCollection(WorkflowData) ;
	  	  	dispatchEvent(new Event('getWorkflowData'));	
		} 
		
		/**
 		 * This function is bound to event 'getNRAData'
 		 */	
		[Bindable (event="getNRAData")]
		public function get getNRAData():ArrayCollection
		{	
			return acNRAData;  
		}
		
		/**
 		 * Get program NRA data
 		 * @param WorkflowData
 		 * Calls event 'getNRAData'
 		 */	
		public function fnGetNRAData(NRAData:ArrayCollection):void
		{
			acNRAData = NRAData;
	  	  	dispatchEvent(new Event('getNRAData'));	
		} 
		
		/**
 		 * This function is bound to event 'getProgramDistinctYearsEvent'
 		 */	
		[Bindable (event="getProgramDistinctYearsEvent")]
		public function get getProgramDistinctYears():Array
		{
			return arrProgramDistinctYears;  
		}
		
		/**
 		 * Get a list of years to populate the dropdown for archive (history) 
 		 * @param ProgramYears
 		 * Calls event 'getProgramDistinctYearsEvent'
 		 */	
		public function fnGetProgramDistinctYears(ProgramYears:ArrayCollection):void
		{
			var e_Dispatcher:Dispatcher = new Dispatcher();
			arrProgramDistinctYears = ProgramYears.source;

	  	  	dispatchEvent(new Event('getProgramDistinctYearsEvent'));	
	  	  	
		}   		
		 
		/**
 		 * This function is bound to event 'getProgramRevisionCountEvent'
 		 */	
		[Bindable (event="getProgramRevisionCountEvent")]
		public function get getProgramRevisionCount():String
		{	
			return StrProgramRevisionCount;
		}
		
		/**
 		 * Find whether the program is revised or not
 		 * @param RevisionCount
 		 * Calls event 'getProgramRevisionCountEvent'
 		 */	
		public function fnGetProgramRevisionCount(RevisionCount:String):void
		{
			StrProgramRevisionCount = RevisionCount;
	  	  	dispatchEvent(new Event('getProgramRevisionCountEvent'));
		}  	 
		
		/**
 		 * This function is bound to event 'getGLAccountEvent'
 		 */	
		[Bindable (event="getGLAccountEvent")]
		public function get getGLAccount():String
		{	
			return StrGLAccount;  
		}
		
		/**
 		 * Get program GL Account info
 		 * @param GLAccount
 		 * Calls event 'getGLAccountEvent'
 		 */	
		public function fnGetGLAccount(GLAccount:String):void
		{
			StrGLAccount = GLAccount;
	  	  	dispatchEvent(new Event('getGLAccountEvent'));
		}  

		
		/* This is called when the user clicks on "refresh Data".
		   All except "status" are reset.
		*/
		private function reset_filter():void{
			//_Status = new Array("Show All Status")
			_Template = new Array("Show All Templates");
			_RSP = new Array("Show All RSP");
			_UName = new Array("Show All Users");
			_Positions = new Array("Show All Positions");
			_Report_List = new Array("Select Action for");
			_Conditions = new Array("Select Conditions");			
			_BusinessSegments = new Array("Show All " + sBusinessSegmentsLabel);
			_BudgetClasses = "";
			_Program_Info 	 = "";
			_Distributor_Info 	 = "";
			_Operator_Info 	 = "";
			_Item_Info 	 = "";
			_BuyingGroups 	 = "";
			_FamilyName	 = "";
		}
		
		/*			 		
		public function resetFilters():void
		{
			this._arrAllTemplate 	  = new Array();
			this._arrAllStatus 		  = new Array();		 
			this._arrAllUserPositions = new Array();
			this._arrAllBuyingGroups  = new Array();
			this._arrAllFamilyNames   = new Array();
			this._arrAllUsers 		  = new Array();
			this._arrAllRSP 		  = new Array();
			//this._arrAllProgram    	  = new Array();
			//this._arrAllReportType	  = new Array();
		}
		
		
		public function sortFilters():void
		{
			this._arrAllTemplate.sort();
			this._arrAllStatus.sort();		 
			this._arrAllUserPositions.sort();
			this._arrAllBuyingGroups.sort();
			this._arrAllFamilyNames.sort();
			this._arrAllUsers.sort();
			this._arrAllRSP.sort();		
		}
		*/
		
		//public function getUniqueFilters(element:*, index:int, arr:Array):void
		//{
		//	/* ******************* PROGRAM TEMPLATE  ******************** */	
		//	if (_arrAllTemplate.length != 0) 
		//	{ 
		//			if (_arrAllTemplate.indexOf(element.ProgramTemplate)== -1 && element.ProgramTemplate != '')
		//			{
		//				_arrAllTemplate.push(element.ProgramTemplate);}
		//			}
		//			else if(element.ProgramTemplate != '')
		//			{
		//				_arrAllTemplate.push(element.ProgramTemplate);
		//			}
		//	/* ******************* PROGRAM STATUS  ******************** */
		//	if (_arrAllStatus.length != 0) 
		//	{ 
		//			if (_arrAllStatus.indexOf(element.ProgramStatus)== -1 && element.ProgramStatus != '') 
		//			{
		//				_arrAllStatus.push(element.ProgramStatus);
		//			}
		//	}
		//	else if(element.ProgramStatus != '')
		//	{
		//			_arrAllStatus.push(element.ProgramStatus);
		//	}
		//	/* ******************* USER POSITIONS  ******************** */
		//	if (_arrAllUserPositions.length != 0) 
		//	{ 
		//			if (_arrAllUserPositions.indexOf(element.UserPositions)== -1 && element.UserPositions != '') 
		//			{
		//				_arrAllUserPositions.push(element.UserPositions);
		//			}
		//	}
		//	else if(element.UserPositions != '')
		//	{
		//				_arrAllUserPositions.push(element.UserPositions);
		//	}			
		//	/* ******************* BUYING GROUPS  ******************** */
		//	if (_arrAllBuyingGroups.length != 0) 
		//	{ 
		//			if (_arrAllBuyingGroups.indexOf(element.BuyingGroups)== -1 && element.BuyingGroups != '') 
		//			{
		//				_arrAllBuyingGroups.push(element.BuyingGroups);
		//			}
		//	}
		//	else if(element.BuyingGroups != '')
		//	{
		//				_arrAllBuyingGroups.push(element.BuyingGroups);
		//	}			
		//	/* ******************* FAMILY NAME  ******************** */
		//	if (_arrAllFamilyNames.length != 0) 
		//	{ 
		//			if (_arrAllFamilyNames.indexOf(element.FamilyName)== -1 && element.FamilyName != '') 
		//			{
		//				_arrAllFamilyNames.push(element.FamilyName);
		//			}
		//	}
		//	else if(element.FamilyName != '')
		//	{
		//				_arrAllFamilyNames.push(element.FamilyName);
		//	}			
		//	/* ******************* USER  ******************** */
		//	if (_arrAllUsers.length != 0) 
		//	{ 
		//			if (_arrAllUsers.indexOf(element.UserName)== -1 && element.UserName != '') 
		//			{
		//				_arrAllUsers.push(element.UserName);}
		//			}
		//	else if(element.UserName != '')
		//	{
		//				_arrAllUsers.push(element.UserName);
		//	}			
		//	/* ******************* RSP  ******************** */
		//	if (_arrAllRSP.length != 0) 
		//	{ 
		//			if (_arrAllRSP.indexOf(element.Responsible_Sales_Person)== -1 && element.Responsible_Sales_Person != '') 
		//			{
		//				_arrAllRSP.push(element.Responsible_Sales_Person);}
		//			}
		//	else if(element.Responsible_Sales_Person != '')
		//	{
		//				_arrAllRSP.push(element.Responsible_Sales_Person);
		//	}			
		//	/* ******************* PROGRAM   ******************** */
		//	if (_arrAllProgram.length != 0) 
		//	{ 
		//			if (_arrAllProgram.indexOf(element.ProgramInfo)== -1 && element.ProgramInfo != '') 
		//			{
		//				_arrAllProgram.push(element.ProgramInfo);}
		//			}
		//	else if(element.ProgramInfo != '')
		//	{
		//				_arrAllProgram.push(element.ProgramInfo);
		//	}			
		//	/* ******************* REPORT TYPE   ******************** */
		//	if (_arrAllReportType.length != 0) 
		//	{ 
		//			if (_arrAllReportType.indexOf(element.Report_List)== -1 && element.Report_List != '') 
		//			{
		//				_arrAllReportType.push(element.Report_List);}
		//			}
		//	else if(element.Report_List != '')
		//	{
		//				_arrAllReportType.push(element.Report_List);
		//	}			

		//}
 		/**
 		 * This function accepts the search arguments
 		 * @param fProgram_Info
 		 * @param fDistributor_Info
 		 * @param fOperator_Info
 		 * @param fItem_Info
 		 * @param fStatus
 		 * @param fTemplate
 		 * @param fRSP
 		 * @param fBuyingGroups
 		 * @param fFamilyName
 		 * @param fPositions
 		 * @param fProgramInfo
 		 * @param fReportType
 		 * @param fConditions
		 * @param fBudgetClasses
		 * @param fBusinessSegments
 		 */ 			
 		public function programFilter(fProgram_Info:String,
 										fDistributor_Info:String,
 										fOperator_Info:String,
										fItem_Info:String,
										fStatus:String,
										fTemplate:String,
										fRSP:String,
										fBuyingGroups:String,
										fFamilyName:String,
										fUName:String,
										fPositions:String,
										fProgramInfo:String,
										fReportType:String,
										fConditions:String,
										fBudgetClasses:String,
										fBusinessSegments:String):void
		{
			
			var acProgramResult:Array = new Array();
			
			// text box 
			/* Dev Note:(46817) - If special characters are used in the search criteria, escape these to include it in the search criteria. */
			this._Program_Info = escapeRegexChars(fProgram_Info);
			this._Distributor_Info = fDistributor_Info;
			this._Operator_Info = fOperator_Info;
			this._Item_Info = fItem_Info;
			
			// combo box
			this._BuyingGroups= fBuyingGroups;		
			this._FamilyName= fFamilyName;
			this._BudgetClasses = fBudgetClasses;
			this._Status= convertToArray(fStatus);
			this._Template = convertToArray(fTemplate);
			this._RSP = convertToArray(fRSP);	
			this._UName = convertToArray(fUName);	
			this._Positions = convertToArray(fPositions);
			this._ProgramInfo= convertToArray(fProgramInfo); 
			this._Report_List = convertToArray(fReportType);
			this._Conditions = convertToArray(fConditions);
			this._BusinessSegments = convertToArray(fBusinessSegments);
			
			//this._UserName = fUserName;

			this._acProgramData.filterFunction = this.programFilterFunc;
		 	this._acProgramData.refresh();
		 	
		 	/* Reset the scrollbar position to the top. This happens after the local filter 
		 	(at flex level). This code is also called seperately after sql server filter.
		 	*/
		 	var e_Dispatcher:Dispatcher = new Dispatcher();
			var e:SearchProgramEvent = new SearchProgramEvent(SearchProgramEvent.RESET_SCROLLBAR_POSITION);
       		e_Dispatcher.dispatchEvent(e);
       		
       		/* Call the event to show the selected search options */
		    var e1:SearchProgramEvent = new SearchProgramEvent(SearchProgramEvent.SHOW_SELECTED_OPTIONS);
		 	e_Dispatcher.dispatchEvent(e1);	
		}
		
		/**
		 * This function is called to convert the search criteria from string to Array.
		 * We need Array for multiple criteria combobox search, so that the search critera
		 * does not behave like the 'Like' Operator
		 * @param SearchCriteria
		 * 
		 */	
		private function convertToArray(SearchCriteria:String):Array
		{
			var arrSearchCriteria:Array = new Array();
			arrSearchCriteria = SearchCriteria.split(",");
			return 	arrSearchCriteria;
		}
	
		/**
		 * This function is called when the user visits from the scorecard. We need to
		   filter the records based on the status link linked.
		 * @param fStatus
		 * 
		 */		
		public function programFilterStatus(fStatus:String):void
		{

		if(fStatus != null && fStatus != '')

		{
			var acProgramResult:Array = new Array();

			this._Status= convertToArray(fStatus);
			if( fStatus.indexOf('Pending Approval') != -1 ||  fStatus.indexOf('Agreed') != -1 ||  fStatus.indexOf('Under Review') != -1)
			{
				var e_Dispatcher:Dispatcher = new Dispatcher();
				//FILTER USING SQL ON SERVER
	    		var e:SearchProgramEvent = new SearchProgramEvent(SearchProgramEvent.RO_FILTER_PROGRAMS);
	    			e.userId 			= _iUserId;
					e.eStatus 			= fStatus;
					e.eTemplate 		= 'Show All Templates';
					e.eRSP				= 'Show All RSP';
					e.eBuyingGroups 	= '';
					e.eFamilyName		= '';
					e.eUName			= 'Show All Users';
					e.ePositions		= 'Show All Positions';
					e.eProgramInfo 		= 'Created By';
					e.eReportType		= 'Select Action for';
					e.eConditions		= 'Select Conditions';
					e.eProgram_Info 	= '';
					e.eDistributor_Info = '';
					e.eOperator_Info 	= '';
					e.eItem_Info 		= '';
					e.eBudgetClasses	= 'Show All Budget Class';
					e.eBusinessSegments	= 'Show All ' + sBusinessSegmentsLabel;
       			e_Dispatcher.dispatchEvent(e);
			}
			/* If Statuses need not make a db call to filter on statuses, we do not need to do the above
			   We need to run ths filter below for all the statuses.
			*/
				this._acProgramData.filterFunction = this.programFilterFunc;
		 		this._acProgramData.refresh();
		 }
		}

		
		public function programFilterFunc(item:Object):Boolean
		{
      		var vchApproved:Boolean = false;
			/* ****************************************************************
				The below two variables hold the value that gets displayed in the
				drop down list and it is recreated here for checking and displaying
				the results accordingly
			********************************************************************/
			var strFNLabel:String;
			var strBGLabel:String;
			var strBusSegmentLabel:String;
			
			strBGLabel = 'Show All ' + sPrgBuyingGroupLabel;
			strFNLabel = 'Show All ' + sPrgFamilyLabel;  
			strBusSegmentLabel = 'Show All ' + sBusinessSegmentsLabel;  
			
      		if (_Status.indexOf("Approved") != -1)
      		{
      	 		vchApproved = true;
			} 
			
      	 	return	(
	 		 	(
	 		    		_Status[0] == 'Show All Status'
	 					||
					(
						/*Any status except (Approved,Pending Approval,Agreed and Under Review) */
						_Status.indexOf(item.contract_status_type_desc) != -1 
						
						/* Approved */
						|| 											
						(vchApproved == true && item.approved_status == vchApproved)				
						
						/* 'Pending Approval' and 'Agreed' */
						||				
			   			((_Status.indexOf('Pending Approval') != -1 || _Status.indexOf('Agreed') != -1) && _arrProgramIdFilter.indexOf(item['contract_main_id']) >= 0)
			   			
			   			/* 'Under Review' */
			   			||
			   			(
				   			_Status.indexOf('Under Review') != -1
				   			&&
			   	    		_arrProgramIdUnderRevFilter.indexOf(item['contract_main_id']) == -1 
			   	    		&&
			   	    		item.contract_status_type_desc.toUpperCase().indexOf('READY FOR APPROVAL') != -1
		   	    		)
		   	    		
		   	    		/* Pending ERP Research and Pending ERP Entry */
						|| 											
						(_Status.indexOf('Pending ERP Research') != -1	&& item.program_post_approval_status_id == '1')
						||
						(_Status.indexOf('Pending ERP Entry') != -1	&& item.program_post_approval_status_id == '2')
			   		)
				)

				&&(_Template[0] == 'Show All Templates' || _Template.indexOf(item.created_type) != -1)	
                
                &&(_RSP[0] == 'Show All RSP' || _RSP.indexOf(item.rsp_user) != -1)
          		
				&& 	
				(
					_Positions[0] == 'Show All Positions'
					||
					(        
						(_ProgramInfo.indexOf('Created By') != -1 && _Positions.indexOf(item.owner_position) != -1)                  
						||
						(_ProgramInfo .indexOf('RFA By') != -1 && _Positions.indexOf(item.rfa_position) != -1)                  
						||
						(_ProgramInfo.indexOf('Approved By') != -1 && _Positions.indexOf(item.approver_position) != -1)   
						/* CRA. This one goes to CF for filtering */
						||				
						((_ProgramInfo.indexOf('CRA') != -1) && _arrProgramIdFilter.indexOf(item['contract_main_id']) >= 0)
					) 
				)  				
				&& 	
				(
					_UName[0] == 'Show All Users'
					||
					(        
						(_ProgramInfo.indexOf('Created By') != -1 && _UName == item.creator_user)                  
						||
						(_ProgramInfo .indexOf('RFA By') != -1 && _UName == item.rfa_user)                  
						||
						(_ProgramInfo.indexOf('Approved By') != -1 && _UName == item.approver_user)     
						/* CRA. This one goes to CF for filtering */
						||				
						((_ProgramInfo.indexOf('CRA') != -1) && _arrProgramIdFilter.indexOf(item['contract_main_id']) >= 0)
					) 
				)    
		   	  
		   	  	&& 	
		   	   	(
				 _Report_List[0]== 'Select Action for'
		   	   	||
		   	   		(	/* Note: For any logic change for claim rates or pricing or edit status or mass approve - please make 
						a corresponding change in the "getSelectedEntries" function on "ProgramSearchPanel.mxml" */ 
				   	   (_Report_List.indexOf('Claim Rates') != -1 && item.is_catalog == 0 && item.include_claim_rates_report == '1')
				   	   ||
				   	   (_Report_List.indexOf('Pricing') != -1 && item.is_catalog == 0 && item.include_pricing_report == '1')   	
				   	   ||
				   	   (
				   	   _Report_List.indexOf('Delete') != -1
				   	   		&& item.status_id <= 2 && item.is_catalog == 0
					   	   && 
					   	    (
					   	    parseInt(sDeleteProgramAccess) == 1
					   	    ||
					   	    parseInt(item.is_autorenew) == 0
					   	    ||
					   	    parseInt(sDeleteIsCancelAutoRenew) == 0
				   	   		)		
					   )
				   	   ||
				   	   (_Report_List.indexOf('Edit Won/Lost Status') != -1 && item.is_catalog == 0 && item.status_id == 10) 		
				   	   ||
				   	   (_Report_List.indexOf('Mass Approve') != -1 && item.is_catalog == 0 && item.status_id == 2)	
					   ||
					   /* This will not only filter programs based on "release_eligible" filter but also would look at another filter - "programs listed on the 'create list' box */
					   (_Report_List.indexOf('Release') != -1 && item.release_eligible == 1 && (arrCreateList.length == 0 || arrCreateList.indexOf(item.searchable_contract_number) >= 0))	
					   

				   	)  
		   	   	)
				/* "Budget class" filtering.This one goes to CF for filtering */
				&&((_BudgetClasses.length == 0 || _BudgetClasses.indexOf('Show All Budget Class') != -1)|| (_BudgetClasses.length > 0 && _arrProgramIdFilter.indexOf(item['contract_main_id']) >= 0))				
		   	   	&& 	
		   	   	(
				 _Conditions[0] == 'Select Conditions'
		   	   	||
		   	   		(
		   	   			/* indexOf = 0 means "exact match". indexOf = -1 means "string found" */
				   	   (_Conditions.indexOf('Auto renewed') != -1 && item.is_autorenew == '1')
				   	   ||
					   (_Conditions.indexOf('Auto renew pairs') != -1 && item.autorenew_pairs == '1')
					   ||
					   (_Conditions.indexOf('Best Plan Programs') != -1 && item.Best_Plan_Program == '1')
					   ||
					   (_Conditions.indexOf('Cancelled') != -1 && item.cancelled == '1')
				   	   ||
					   (_Conditions.indexOf('Disagreed') != -1 && item.disagreed == '1')
					   ||
				   	   (_Conditions.indexOf('Doc attached') != -1 && item.is_catalog == 0 && item.doc_attached == '1')
				   	   ||
				   	   (_Conditions.indexOf('Not Cancelled') != -1 && item.cancelled == '0')   	
				   	   ||
				   	   /* is_catalog is not needed as catalog view is only for approved programs */
				   	   (_Conditions.indexOf('Revision') != -1 && item.revision_in_process == '1')  
				   	   ||
				   	   (_Conditions.indexOf('Rollover') != -1 && item.rollover == '1')  
					   ||
					   (_Conditions.indexOf('Expiring No Revisions') != -1 && item.expiring_no_revisions == '1')  					   
					   ||
					   (_Conditions.indexOf('Released') != -1 && item.program_released == '1')
					   ||
					   (_Conditions.indexOf('Not Released') != -1 && item.program_released == '0')
					   ||
					   (_Conditions.indexOf('Acknowledged') != -1 && item.acknowledged == '1')
					   ||
					   (_Conditions.indexOf('Not Acknowledged') != -1 && item.not_acknowledged == '1')		
					   ||
					   (_Conditions.indexOf('Uploaded') != -1 && item.creation_method == '2')		   
					)  
		   	   	)	
				/* While visiting from the scorecard, "strBusSegmentLabel" can be null when "_BusinessSegments" is populated and so in those cases " _BusinessSegments[0] == "Show All null" works as a solution, as
				the programs do get filtered by status.
				*/
				&&(bshowBusinessSegment == false || _BusinessSegments[0] == "Show All null" || _BusinessSegments[0] == strBusSegmentLabel || _BusinessSegments.indexOf(item.business_segment) != -1)	
				
		   	   /* Program Reference Number,Contract_Number (with revision number),Contract_Title,Contract_Number (with prefix), Legacy_ID */
		   	   	&& 
		   	    (
		   	    	_Program_Info.length == 0 || 
		   	    	(
		   	   		 _Program_Info.length > 0 
		   	    	 && 
		   	    		(
		   	    		item.contract_reference_number.match(new RegExp(_Program_Info, 'i'))
		   	   			||
		   	   			item.contract_number.match(new RegExp(_Program_Info, 'i'))
		   	   			||
		   	   			item.contract_title.match(new RegExp(_Program_Info, 'i'))
		   			   	||
		   	   			item.prefixed_contract_number.match(new RegExp(_Program_Info, 'i'))
						||
						item.legacy_id.match(new RegExp(_Program_Info, 'i'))						
						)
		   	    	 )
		   	     ) 
		   	     	
		   	   /* Keyword Filter (Distributor, Operator, Item, Buying Group, Family) */
		   	   && 
		   	    (
		   	    	/* When we get data through shared object very quickly and by the time this function gets filtered, we still do not get
		   	    	   the data for _BuyingGroups and _FamilyName and so I added a OR condition for them being blank
		   	    	 */
		   	    	(
		   	    		_Distributor_Info.length == 0 && _Operator_Info.length == 0 && _Item_Info.length == 0
		   	    		&& 
		   	    		(_BuyingGroups == strBGLabel || _BuyingGroups=='') && (_FamilyName == strFNLabel || _FamilyName=='')
		   	    	)
		   	    	||
			   	    _arrProgramIdFilter.indexOf(item['contract_main_id']) >= 0
		   	     )	     
		   	  ) 
		   	}  
		
		/*
		[Bindable]
		public function programResults(ac:ArrayCollection):void
		{
			this._acProgramData = ac;
		}
		*/
		
		private function escapeRegexChars(s:String):String
		{
			var newString:String = 
				s.replace(
					new RegExp("([{}\(\)\^$&.\*\?\/\+\|\[\\\\]|\]|\-)","g"),
					"\\$1");
			return newString;
		}
		
		//[Bindable]
		public function setAppSettings(aSettings:ArrayCollection):void
		{
			Alert.show(ObjectUtil.toString(aSettings));
		}
		
		/**
		 * Delete the program in the db and the datagrid
		 * @param iProgramID
		 * @param DeleteMessage
		 * Returns the "delete" confirmation message
		 */		
		public function delRowInGrid(iProgramID:String,DeleteMessage:Array):void
		{
		
		 var arrDelMessage1:Array;
		 var arrDelMessage2:Array;
		  
		 arrDelMessage1 = new Array(DeleteMessage[0]);
		 arrDelMessage2 = new Array(DeleteMessage[1]);
			
		 if(arrDelMessage1[0] == 1){	
			var idxCtr:int = 0;
			for each(var o:Object in this._acProgramData)
			{
				if (o.contract_main_id.toString().indexOf(iProgramID) > -1)
				{	
					idxCtr = this._acProgramData.getItemIndex(o);	
					this._acProgramData.removeItemAt(idxCtr);
				}
			}		 	
			dispatchEvent(new Event('programListChanged'));
			this._acProgramData.refresh();
		  }
		  	if(arrDelMessage2[0] != ''){
		 		Alert.show(arrDelMessage2[0]);
		 	}
		 	
		}
		
		// Export XLS Handler
		public function fnExportXLS():void
		{
			var strProgramList:String  ='';
			var strContract_Start_Date:String;
			var strContract_End_Date:String;
			/* (String.fromCharCode(9) means tab) */
			var strProgramheader:String = 'Status' + String.fromCharCode(9) + 'RFA Age' + String.fromCharCode(9) + 'Program' + String.fromCharCode(9) + 'Title' + String.fromCharCode(9) 
				+ 'Type'+ String.fromCharCode(9) + 'Start Date' + String.fromCharCode(9) + 'End Date' + String.fromCharCode(9) + 'RSP' 
				
				if(bDisplayTradeDollars){ 
					strProgramheader = strProgramheader + String.fromCharCode(9) + sDisplayTradeDollarsLabel 
				}
				if(bDisplayPaymentDollars){ 
					strProgramheader = strProgramheader + String.fromCharCode(9) + sDisplayPaymentDollarsLabel
				}			
				if(bDisplayVolume){ 
					strProgramheader = strProgramheader + String.fromCharCode(9) + sDisplayVolumeLabel
				}
				if(bshowBusinessSegment){
					strProgramheader = strProgramheader + String.fromCharCode(9) + sBusinessSegmentsLabel
				}
				if(bDisplayOperatorInfo){
					strProgramheader = strProgramheader + String.fromCharCode(9) + sOperatorIDLabel
					strProgramheader = strProgramheader + String.fromCharCode(9) + sOperatorNameLabel
				}
			/* Loop through the records in the datagrid view (not the whole data set). Then a "save" option 
			   will appear where the user can save the records as an Excel file on their local machine.
			*/
			for each(var o:Object in this._acProgramData)
			{	
				strContract_Start_Date = o['contract_start_date'].getMonth() + 1 +"/"+ o['contract_start_date'].getDate()+"/"+ o['contract_start_date'].getFullYear();
				strContract_End_Date = o['contract_end_date'].getMonth() + 1 +"/"+ o['contract_end_date'].getDate()+"/"+ o['contract_end_date'].getFullYear();
				/* (String.fromCharCode(9) means tab) */
				strProgramList = strProgramList + o['status_abbreviation'] + String.fromCharCode(9) + o['rfa_age'] + String.fromCharCode(9) 
								+ o['contract_number'] + String.fromCharCode(9) + o['contract_title'] 
								+ String.fromCharCode(9) + o['created_type'] + String.fromCharCode(9) + strContract_Start_Date + String.fromCharCode(9) 
								+ strContract_End_Date + String.fromCharCode(9) + o['rsp_user']
								
					if(bDisplayTradeDollars){ 
						strProgramList = strProgramList + String.fromCharCode(9) + o['program_trade_spend']
					}
					if(bDisplayPaymentDollars){ 
						strProgramList = strProgramList + String.fromCharCode(9) + o['program_payment']
					}					
					if(bDisplayVolume){ 
						strProgramList = strProgramList + String.fromCharCode(9) + o['program_volume']
					}
					if(bshowBusinessSegment){ 
						strProgramList = strProgramList + String.fromCharCode(9) + o['business_segment']
					}
					if(bDisplayOperatorInfo){
						strProgramList = strProgramList + String.fromCharCode(9) + o['operator_id']
						strProgramList = strProgramList + String.fromCharCode(9) + o['operator_name']
					}					
					strProgramList = strProgramList + String.fromCharCode(13) + String.fromCharCode(10)
			}	
			strProgramList = strProgramheader +  String.fromCharCode(13) + String.fromCharCode(10) + strProgramList;
			downloadFileRef.save(strProgramList,"Program_List.xls");		
		}
		
/*  PROGRAM LIST starts here */

		/**
		 * filter func for create/saved list items
		 * @param item
		 * Returns boolean after checks whether the program exists in the array
		 */		
		public function itemFilterCreateListFunc(item:Object):Boolean
		{
				return (arrValidItems.indexOf(item['searchable_contract_number']) >= 0)
		}

/* CREATE LIST xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx */	
		/**
		 * Create a list of favorite programs
		 * @param txt
		 */		
		public function createList(txt:String):void
		{
			arrItemsToAdd = new Array();
			arrItemsToAdd = listToArray(txt);
			displaySearchList(arrItemsToAdd);
		}
		
		public function update_create_list(txt:String):void
		{
			arrCreateList = new Array();
			if(txt.length > 0){
				arrCreateList = listToArray(txt);
			}
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
					for each(var oItem:Object in this._acProgramData.source)
					{	
						if(bExactListMatchingOn == true)
						{	
							/* Look for an exact match on program number */
							if(oItem['searchable_contract_number'].match(new RegExp("^"+ sItem + "$", 'i')))
							{	
								arrValidItems.push(oItem['searchable_contract_number'])
								/* arrFValidItems needs sItem only */
								arrFValidItems.push(sItem)
								break;
							}
						}
						else
						{	
							if(oItem['searchable_contract_number'].match(new RegExp(sItem, 'i')))
							{	
							arrValidItems.push(oItem['searchable_contract_number'])
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

				this._acProgramData.filterFunction = this.itemFilterCreateListFunc;
				this._acProgramData.refresh();
				dispatchEvent(new Event('programListChanged'));
				
				/* if there are any invalid Programs display the valid and invalid lists */
				if(arrInValidItems.length > 0)
				{
					/* if there are any invalid items, pop up the results */
					showPopUp(arrInValidItems,arrValidItems);
				}
		}
		
		
		/**
		 * DISPLAY List: Already saved xxxxxxxxxxxxxxxxxxxxxxxxxxx
		 * @param arrItemsToAdd
		 */		
		public function displayList(arrItemsToAdd:Array):void
		{
			arrValidItems = new Array();
			arrInValidItems = new Array();
			var arrFValidItems:Array = new Array();
			
		 	var e_Dispatcher:Dispatcher = new Dispatcher();
			
			var strFNLabel:String;
			var strBGLabel:String;
			var strBusSegmentLabel:String;
			
			strBGLabel = 'Show All ' + sPrgBuyingGroupLabel;
			strFNLabel = 'Show All ' + sPrgFamilyLabel; 
			strBusSegmentLabel = 'Show All ' + sBusinessSegmentsLabel; 
		 
			if(
			/* Distributor keyword(s) */
			arrItemsToAdd[10].length > 0 
			/* Operator keyword(s) */
			|| arrItemsToAdd[11].length > 0 
			/* Item keyword(s) */
			|| arrItemsToAdd[12].length > 0 
			/* Program keyword(s) */
   			|| arrItemsToAdd[0].indexOf('Pending Approval' ) != -1 
   			|| arrItemsToAdd[0].indexOf('Agreed' ) != -1 
   			|| arrItemsToAdd[0].indexOf('Under Review' ) != -1 
   			/* Buying Group keyword(s) */
   			|| arrItemsToAdd[3].length > 0 
   			/* Family keyword(s) */
   			|| arrItemsToAdd[4].length > 0
			/* Budget Class */
			|| arrItemsToAdd[14].length > 0
			/* ProgramInfo */
			|| arrItemsToAdd[7].indexOf('CRA' ) != -1) 
   			{
   				
	   			//FILTER USING SQL ON SERVER
		   		var e:SearchProgramEvent = new SearchProgramEvent(SearchProgramEvent.RO_FILTER_PROGRAMS);	
		   			
		   		e.userId 	= _iUserId;
	   			
	   			/* Status */
	   			if(arrItemsToAdd[0] != ''){ 
	   				e.eStatus 	= arrItemsToAdd[0];
	   			}
	   			else{
	   				e.eStatus 	= 'Show All Status';
	   			}
				
				/* Template */
				if(arrItemsToAdd[1] != ''){ 
	   				e.eTemplate  = arrItemsToAdd[1];
	   			}
	   			else{
	   				e.eTemplate  = 'Show All Templates';
	   			}
	   			
	   			/* RSP */
	   			if(arrItemsToAdd[2] != ''){ 
	   				e.eRSP	= arrItemsToAdd[2];
	   			}
	   			else{
	   				e.eRSP 	= 'Show All RSP';
	   			}
	   			
	   			/* Buying Group */
	   			if(arrItemsToAdd[3] != ''){ 
	   				e.eBuyingGroups = arrItemsToAdd[3];
	   			}
	   			else{
	   				e.eBuyingGroups = strBGLabel;
	   			}
	   			
	   			/* Family */
	   			if(arrItemsToAdd[4] != ''){ 
	   				e.eFamilyName 	= arrItemsToAdd[4];
	   			}
	   			else{
	   				e.eFamilyName 	= strFNLabel;
	   			}
				
				/* User */
				if(arrItemsToAdd[5] != ''){ 
					e.eUName	= arrItemsToAdd[5];
				}
				else{
					e.eUName 	= 'Show All Users';
				}
	   			
	   			/* Position */
	   			if(arrItemsToAdd[6] != ''){ 
	   				e.ePositions 	= arrItemsToAdd[6];
	   			}
	   			else{
	   				e.ePositions 	= 'Show All Positions';
	   			}
	   			
				/* ProgramInfo */
	   			if(arrItemsToAdd[7] != ''){ 
	   				e.eProgramInfo 	= arrItemsToAdd[7];
	   			}
	   			else{
	   				e.eProgramInfo 	= 'Created By';
	   			}
	   			
	   			/* Action */
	   			if(arrItemsToAdd[8] != ''){ 
	   				e.eReportType 	= arrItemsToAdd[8];
	   			}
	   			else{
	   				e.eReportType 	= 'Select Action for';
	   			}
	   			
	   			/* Conditions */
	   			if(arrItemsToAdd[9] != ''){ 
	   				e.eConditions 	= arrItemsToAdd[9];
	   			}
	   			else{
	   				e.eConditions 	= 'Select Conditions';
	   			}
	   			
	   			/* Program Info */
	   			if(arrItemsToAdd[10] != ''){ 
	   				e.eProgram_Info = arrItemsToAdd[10];
	   			}
	   			else{
	   				e.eProgram_Info = '';
	   			}
	   			
	   			/* Distributor Info */
	   			if(arrItemsToAdd[11] != ''){ 
	   				e.eDistributor_Info  = arrItemsToAdd[11];
	   			}
	   			else{
	   				e.eDistributor_Info  = '';
	   			}
	   			
	   			/* Operator Info */
	   			if(arrItemsToAdd[12] != ''){ 
	   				e.eOperator_Info = arrItemsToAdd[12];
	   			}
	   			else{
	   				e.eOperator_Info = '';
	   			}
	   			
	   			/* Item Info */
	   			if(arrItemsToAdd[13] != ''){ 
	   				e.eItem_Info = arrItemsToAdd[13];
	   			}
	   			else{
	   				e.eItem_Info = '';
	   			}		   				
				
				/* Budget Class */
				if(arrItemsToAdd[14] != ''){ 
					e.eBudgetClasses 	= arrItemsToAdd[14];
				}
				else{
					e.eBudgetClasses 	= 'Show All Budget Class';
				}
				
				/* Business segment */
				if(arrItemsToAdd[15] != ''){ 
					e.eBusinessSegments	= arrItemsToAdd[15];
				}
				else{
					e.eBusinessSegments = strBusSegmentLabel;
				}				
				
				e_Dispatcher.dispatchEvent(e);
			}
	   		
	   		else
	   		{
	   			//LOCAL FILTER	   				
				var e1:SearchProgramEvent = new SearchProgramEvent(SearchProgramEvent.FILTER_RESULTS);
	   		
		   		/* Status */
		   		if(arrItemsToAdd[0] != ''){ 
	   				e1.eStatus 	= arrItemsToAdd[0];
	   			}
	   			else{
	   				e1.eStatus 	= 'Show All Status';
	   			}
				
				/* Template */
				if(arrItemsToAdd[1] != ''){ 
	   				e1.eTemplate  = arrItemsToAdd[1];
	   			}
	   			else{
	   				e1.eTemplate  = 'Show All Templates';
	   			}
	   			
	   			/* RSP */
	   			if(arrItemsToAdd[2] != ''){ 
	   				e1.eRSP	= arrItemsToAdd[2];
	   			}
	   			else{
	   				e1.eRSP 	= 'Show All RSP';
	   			}
	   			
	   			/* Buying Group */
	   			if(arrItemsToAdd[3] != ''){ 
	   				e1.eBuyingGroups = arrItemsToAdd[3];
	   			}
	   			else{
	   				e1.eBuyingGroups = '';
	   			}
	   			
	   			/* Family */
	   			if(arrItemsToAdd[4] != ''){ 
	   				e1.eFamilyName 	= arrItemsToAdd[4];
	   			}
	   			else{
	   				e1.eFamilyName 	= '';
	   			}
				
				/* User */
				if(arrItemsToAdd[5] != ''){ 
					e1.eUName 	= arrItemsToAdd[5];
				}
				else{
					e1.eUName 	= 'Show All Users';
				}
	   			
	   			/* Position */
	   			if(arrItemsToAdd[6] != ''){ 
	   				e1.ePositions 	= arrItemsToAdd[6];
	   			}
	   			else{
	   				e1.ePositions 	= 'Show All Positions';
	   			}
	   			
	   			/* ProgramInfo */
	   			if(arrItemsToAdd[7] != ''){ 
	   				e1.eProgramInfo 	= arrItemsToAdd[7];
	   			}
	   			else{
	   				e1.eProgramInfo 	= 'Created By';
	   			}
	   			
	   			/* Action */
	   			if(arrItemsToAdd[8] != ''){ 
	   				e1.eReportType 	= arrItemsToAdd[8];
	   			}
	   			else{
	   				e1.eReportType 	= 'Select Action for';
	   			}
	   			
	   			/* Conditions */
	   			if(arrItemsToAdd[9] != ''){ 
	   				e1.eConditions 	= arrItemsToAdd[9];
	   			}
	   			else{
	   				e1.eConditions 	= 'Select Conditions';
	   			}
	   			
	   			/* Program Info */
	   			if(arrItemsToAdd[10] != ''){ 
	   				e1.eProgram_Info = arrItemsToAdd[10];
	   			}
	   			else{
	   				e1.eProgram_Info = '';
	   			}
	   			
	   			/* Distributor Info */
	   			if(arrItemsToAdd[11] != ''){ 
	   				e1.eDistributor_Info  = arrItemsToAdd[11];
	   			}
	   			else{
	   				e1.eDistributor_Info  = '';
	   			}
	   			
	   			/* Operator Info */
	   			if(arrItemsToAdd[12] != ''){ 
	   				e1.eOperator_Info = arrItemsToAdd[12];
	   			}
	   			else{
	   				e1.eOperator_Info = '';
	   			}
	   			
	   			/* Item Info */
	   			if(arrItemsToAdd[13] != ''){ 
	   				e1.eItem_Info = arrItemsToAdd[13];
	   			}
	   			else{
	   				e1.eItem_Info = '';
	   			}
				
				/* Budget Class */
				if(arrItemsToAdd[14] != ''){ 
					e1.eBudgetClasses 	= arrItemsToAdd[14];
				}
				else{
					e1.eBudgetClasses 	= 'Show All Budget Class';
				}
				
				/* Business segment */
				if(arrItemsToAdd[15] != ''){ 
					e1.eBusinessSegments	= arrItemsToAdd[15];
				}
				else{
					e1.eBusinessSegments = strBusSegmentLabel;
				}						
				
		   		e_Dispatcher.dispatchEvent(e1);
		   	}
			
		}
		
		/**
		 * Show Pop-Up Box with List of Valid and Invalid Programs
		 * @param aInvalidItems
		 * @param aValidItems
		 */		
		private function showPopUp(aInvalidItems:Array,aValidItems:Array):void
		{
				popUp = UserItemLists(PopUpManager.createPopUp(Application.application as DisplayObject,UserItemLists,true));
				PopUpManager.centerPopUp(popUp);
				popUp.aInvalidItems = aInvalidItems;
				popUp.aValidItems = aValidItems;
		}
		
		/**
		 * ********************************************************************** 
		  	_acProgramData is the Var bound to the DP of our datagrid.
		   		it gets updated when we filter so loop over it and select all 
		   **********************************************************************
		 */		
		private function selectAll():void 
		{
			for each(var oItem:Object in this._acProgramData)
			{
				oItem.isSelected = 1;
			}
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
		
		
		public function importItems():void
		{
			arrImportItems = new Array();
			for each(var oItem:Object in this.acProgramData.source)
						{
							if(oItem['isSelected'] == 1 && arrImportItems.indexOf(oItem['contract_main_id']) == -1)
								{arrImportItems.push(oItem['contract_main_id'])}
						}
			this.callWrapper(arrImportItems);	
		}
		 
  		/* Send Array of selected items to calling page (via this wrapper) */
	     private function callWrapper(arrItemstoImport:Array):void {
	        var s:String;
	      // Alert.show(ObjectUtil.toString(arrItemstoImport));
	        if (ExternalInterface.available) {
	        	//Alert.show(ObjectUtil.toString(arrItemstoImport));
	           var wrapperFunction:String = "finishedSearching";
	           s = ExternalInterface.call(wrapperFunction, arrItemstoImport);
	        } else {
	           s = "Wrapper not available";
	        }
	     }
		 
		 /* Pass the status, so that the results could sort by "status" (if any) when data is refreshed */
		 public function setStatus(status:String):void{
			 this.sStatus = status;
			 reset_filter();
		 }
		 
		 public function setAllColumnsSize(gridColumnSize:SearchGridColumnSize):void{
			this.objGridColumnSize = gridColumnSize;
		 }
		
		
/* PROGRAM LIST ENDS HERE */
	}/* Class end */
}/* Package end */