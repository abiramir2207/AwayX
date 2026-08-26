package com.models
{
	import com.asfusion.mate.events.Dispatcher;
	import com.components.StringUtils;
	import com.events.*;
	import com.views.*;
	import com.vos.NetPriceSettings;
	import com.components.DataGridDataExporter;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.external.*;
	import flash.net.FileReference;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.printing.*;
	
	//[Bindable]
	public class NetPriceManager extends EventDispatcher 
	{
		/*-************** Local variables / properties *******************************************/
		
		/*-************ private variables which has bindable getters and setters ************-*/
		
		// settings
		private var _settings:NetPriceSettings = new NetPriceSettings();
		
		// report data
		private var _acReportData:ArrayCollection = null;
		private var _acReportDataTotal:ArrayCollection = null;
         
        // drop down data
		private var _arrAllBuyingGroup:Array 	= new Array();
		private var _arrAllFamily:Array 	= new Array();
		private var _arrAllRegion:Array 	= new Array();
		private var _arrAllBroker:Array 	= new Array();
		private var _arrAllTypeCode:Array 	= new Array();
		
		// display dimentions
		private var _iColumnWidthId:int = 50;
		private var _iColumnWidthDesc:int = 110;
		private var _iColumnWidthValues:int = 50;
         
        /*-************ private local variables ************-*/
        private var _sMarketIdList:String 	= "";
        private var _arColumnNames:Array = new Array();
        
        private var _arDataTotalColumns:Array = new Array(
        "Cases_Invoiced",
		"Pounds_Invoiced",
		"Sales_Dollar");
		
		private var _arDescriptionColumns:Array = new Array(
		"Distributor_ID",
		"Distributor_Name",
		"Broker_Name",
		"Region_Name",
		"Family_Name",
		"Buying_Group_Name",
		"Item",
		"Item_Description",
		"Type_Code_Desc");
		
		
		// Shared Object
		private var _soItems:SharedObject;
		private var _dSOLastSavedDate:Date = null;
		
		// settings labels
		private var _sAllTextBuyingGroup:String 	 = "";
		private var _sAllTextFamilyName:String		= "";
		private var _sAllTextRegionName:String		= "";
		private var _sAllTextBrokerName:String		= "";
		private var _sAllTextTypeCode:String		= "";
		
		// settings labels
		private var _sDistributorKeyword:String 	= "";
		private var _sBuyingGroup:String 	 = "";
		private var _sFamilyName:String 		 = "";
		private var _sRegionName:String 		 = "";
		private var _sBrokerName:String 		 = "";
		private var _sProductKeyword:String 	= "";
		private var _sTypeCode:String 		 = "";
		
		// display switches
		private var _bShowBroker:Boolean;
		private var _bShowRegion:Boolean;
		private var _bShowFamily:Boolean;
		private var _bShowBuyingGroup:Boolean;
		private var _bShowTypeCode:Boolean;
		
		private var _bShowCase:Boolean;
		private var _bShowPound:Boolean;
		
		private var _bOptionBNetSales:Boolean;
		private var _bOptionBPercentageDiscount:Boolean;
		private var _bOptionBSpendingRate:Boolean;
		
		// for printing
		private var _oPage:Canvas = new Canvas();
		
		// for csv export and file download
		private var downloadFileRef:FileReference = null;
		//private static const CSV_DOWNLOAD_URL:String = "/flex/HTTPService/Report/get_csv_data.cfm";
		private static const CSV_DOWNLOAD_URL:String = "/flex/HTTPService/Report/get_csv_data_for_user.cfm";
				
		/*-************** Bindable Setters and Getters *******************************************/
		[Bindable (event="reportDataChanged")]
		public function get acReportData():ArrayCollection
		{
			return _acReportData;
		} 
		public function set acReportData(argAcReportData:ArrayCollection):void
		{
			_acReportData = argAcReportData;			
			dispatchEvent(new Event('reportDataChanged'));
		}
		
		[Bindable (event="ReportDataTotalChanged")]
		public function get ReportDataTotal():ArrayCollection
		{
			return _acReportDataTotal;
		} 
		public function set ReportDataTotal(acReportDataTotal:ArrayCollection):void
		{
			_acReportDataTotal = acReportDataTotal;
			dispatchEvent(new Event('ReportDataTotalChanged'));
		}
		
		[Bindable (event="ColumnWidthIdChanged")]
		public function get ColumnWidthId():int 
		{
				return _iColumnWidthId;
		}
		public function set ColumnWidthId(val:int):void 
		{
			this._iColumnWidthId = val;
			dispatchEvent(new Event('ColumnWidthIdChanged'));
		}
		
		[Bindable (event="ColumnWidthDescChanged")]
		public function get ColumnWidthDesc():int 
		{
				return _iColumnWidthDesc;
		}
		public function set ColumnWidthDesc(val:int):void 
		{
			this._iColumnWidthDesc = val;
			dispatchEvent(new Event('ColumnWidthDescChanged'));
		}
		
		[Bindable (event="ColumnWidthValuesChanged")]
		public function get ColumnWidthValues():int 
		{
				return _iColumnWidthValues;
		}
		public function set ColumnWidthValues(val:int):void 
		{
			this._iColumnWidthValues = val;
			dispatchEvent(new Event('ColumnWidthValuesChanged'));
		}
		
		[Bindable (event="updCbBuyingGroupEvent")]
		public function get arrAllBuyingGroup():Array
		{	
			return _arrAllBuyingGroup; 
		} 
		
		[Bindable (event="updCbFamilyEvent")]
		public function get arrAllFamily():Array
		{	
			return _arrAllFamily; 
		}
		
		[Bindable (event="updCbRegionEvent")]
		public function get arrAllRegion():Array
		{	
			return _arrAllRegion; 
		}
		
		[Bindable (event="updCbBrokerEvent")]
		public function get arrAllBroker():Array
		{	
			return _arrAllBroker; 
		}
		
		[Bindable (event="updCbTypeCodeEvent")]
		public function get arrAllTypeCode():Array
		{	
			return _arrAllTypeCode; 
		}
		
		[Bindable (event="eSOLastSavedDate")]
		public function get getSOLastSavedDate():String
		{	
			var s:String = "";
			if(_dSOLastSavedDate is Date)
			{
				s = StringUtils.getUSDate(_dSOLastSavedDate);
				s = s + ' ' + StringUtils.getUSClockTime(_dSOLastSavedDate.getHours(), _dSOLastSavedDate.getMinutes());
			}
			return s;
		}
		
		public function set SOLastSavedDate(dDate: Date):void
		{	
			_dSOLastSavedDate = dDate;
			dispatchEvent(new Event('eSOLastSavedDate')); 
		}
		
		/*-************** Setters and Getters *******************************************/
		public function get settings():NetPriceSettings 
		{
			return _settings;
		}
		public function set settings(s:NetPriceSettings):void 
		{
			this._settings = s;
		}
		public function get MarketIdList():String 
		{
				return _sMarketIdList;
		}
		public function set MarketIdList(str:String):void 
		{
				this._sMarketIdList = str;
		}
			
		public function get page():Canvas 
		{
				return _oPage;
		}
		public function set page(obj:Canvas):void 
		{
			this._oPage = obj;
		}
		
		
		/*-************** Functions *******************************************/
		
		// Function to calculate totals based on the array collection
		private function CalculateTotals():void
		{
			var result : Array = [];
			var item:Object = new Object();;
			
			var nFieldsCount:int = _arDataTotalColumns.length;
			var n:int = _acReportData.length;
			var sdataField:String;
			var nValue:Number;
			
			for (var k:int = 0; k < nFieldsCount; k++)
			{
				item[_arDataTotalColumns[k]] = 0;	
			}			
			
			for (var i:int = 0; i < n; i++)
			{
				for (var j:int = 0; j < nFieldsCount; j++)
				{
					sdataField = _arDataTotalColumns[j];
					nValue = Number(_acReportData[i][sdataField]);
					if(!isNaN(nValue))
						item[sdataField] = item[sdataField] + nValue;	
				}				
			}
			
			result.push(item);
			ReportDataTotal = new ArrayCollection(result);
			
			
		}
			
		/*-************** Handler Functions *******************************************/
		
		public function fnLoadMarketIdList(sMarketIdList:String):void
		{
			MarketIdList = sMarketIdList;
		}
		
		
		public function fnLoadReport(ac:String, sUserId:String):void 
		{

			var result : Array = [];
			var sub:Number = 0;
			var item:Object = null;
			var sServiceMarketId:String = _sMarketIdList;
			var arData : Array;
			var bHeader:Boolean = true;
  
  			var arr : Array = ac.split( "\r\n" );
			
			// set column names from the first row
			_arColumnNames = arr[0].split(",");
			
			// loop over each row (separated by line feed)
         	for each ( var str : String in arr )
			{
				if(str.length)
				{
					arData = str.split(",");
	            	item = new Object();
	            	sub = 0;
	            	// loop over each column (separated by comma)
	            	for each (var sData : String in arData)
					{
						if(_arDescriptionColumns.indexOf(_arColumnNames[sub]) >= 0)
						{
							// description column
							item[_arColumnNames[sub]] = sData;
						}
						else
						{
							// number column
							item[_arColumnNames[sub]] = Number(sData);
						}
						
						sub++;
					}
					
					// filter based on market
					// if HQ market id will be blank so no need to filter
					if(sServiceMarketId.length == 0 || sServiceMarketId.match(new RegExp(item["Service_Market_ID"], 'i')))
					{
						if(!bHeader)
						{
							result.push(item);							
						}
					}
				}
				bHeader = false;
			}
			
			// first row is the header and should be deleted from the data array
			//result.splice(0, 1);
			
			acReportData = new ArrayCollection(result);
			CalculateTotals();
			
			//dispatchSaveSharedOjectEvent(sUserId);
			
			//saveToSharedObject(sUserId);
			
		}
		
		// Shared Object Functions - START
		public function fnLoadFromSharedObject(sUserId:String):void
		{
			
			this._soItems = SharedObject.getLocal("EffectiveNetPrice_" + sUserId, "/");
			if (this._soItems.size > 0)
			{
				acReportData = this._soItems.data.acReportData;
				ReportDataTotal = this._soItems.data.acReportDataTotal;
				if(this._soItems.data.dSavedDate != undefined && this._soItems.data.dSavedDate is Date)
				{
					SOLastSavedDate = this._soItems.data.dSavedDate as Date;
				}
				
			}
			else
			{
				dispatchGetReportEvent(sUserId);
			}
			
		}
		
		public function saveToSharedObject(sUserId:String):void
		{
			var dDate:Date = new Date();
			this._soItems = SharedObject.getLocal("EffectiveNetPrice_" + sUserId, "/");
			this._soItems.data.dSavedDate = dDate;
			this._soItems.data.acReportData = this._acReportData;
			this._soItems.data.acReportDataTotal = this._acReportDataTotal
		  	//this._soItems.flush();
		  	SOLastSavedDate = dDate;
		  	
		  	
		}
		
		private function dispatchSaveSharedOjectEvent(sUserId:String):void
		{
			var eDispatcher:Dispatcher = new Dispatcher();			
	    	var e:NetPriceEvent = new NetPriceEvent(NetPriceEvent.STORE_REPORT_TO_CACHE);
    		e.userId = sUserId;
    		eDispatcher.dispatchEvent(e);
		}
		
		// Shared Object Functions - END
		
		private function dispatchGetReportEvent(sUserId:String):void
		{
			var eDispatcher:Dispatcher = new Dispatcher();			
	    	var e:NetPriceEvent = new NetPriceEvent(NetPriceEvent.GET_REPORT);
    		e.userId = sUserId;
    		eDispatcher.dispatchEvent(e);
		}
		
		public function fnSetDropDownData(arResult:Object):void
		{
			// Buying Groups
		 	_arrAllBuyingGroup = arResult.BUYINGGROUP.source;
		 	_sAllTextBuyingGroup = "Show All " + _settings.appFlex.buyinggrouplabel;
		 	_arrAllBuyingGroup.unshift(_sAllTextBuyingGroup);
	    	dispatchEvent(new Event('updCbBuyingGroupEvent'));
	    	
	    	// Family
		 	_arrAllFamily = arResult.FAMILY.source;
		 	_sAllTextFamilyName = "Show All " + _settings.appFlex.familylabel;
		 	_arrAllFamily.unshift(_sAllTextFamilyName);
	    	dispatchEvent(new Event('updCbFamilyEvent'));
	    	
	    	// Region
		 	_arrAllRegion = arResult.REGION.source;
		 	_sAllTextRegionName = "Show All " + _settings.appFlex.regionlabel;
		 	_arrAllRegion.unshift(_sAllTextRegionName);
	    	dispatchEvent(new Event('updCbRegionEvent'));
	    	
	    	// Broker
		 	_arrAllBroker = arResult.BROKER.source;
		 	_sAllTextBrokerName = "Show All " + _settings.appFlex.brokerlabel;
		 	_arrAllBroker.unshift(_sAllTextBrokerName);
	    	dispatchEvent(new Event('updCbBrokerEvent'));
	    	
	    	// Type Code
		 	_arrAllTypeCode = arResult.TYPECODE.source;
		 	_sAllTextTypeCode = "Show All " + _settings.appFlex.typecodelabel;
		 	_arrAllTypeCode.unshift(_sAllTextTypeCode);
	    	dispatchEvent(new Event('updCbTypeCodeEvent'));
	    	
		}
		
		// Handlers for different actions taken by the user
		
		// Reset Filter Handler
		public function fnResetFilter():void
		{
			this._acReportData.filterFunction = null;
		 	this._acReportData.refresh();
		 	CalculateTotals();
		 
		}
		
		// Filter results Handler
		public function fnFilterResults(event:NetPriceEvent):void
		{
			this._sDistributorKeyword = StringUtils.massEscape(StringUtils.Trim(event.eDistributorKeyword)).toUpperCase();
			this._sBuyingGroup	= StringUtils.Trim(event.eBuyingGroup).toUpperCase();
			this._sFamilyName	= StringUtils.Trim(event.eFamilyName).toUpperCase();
			this._sRegionName	= StringUtils.Trim(event.eRegion).toUpperCase();
			this._sBrokerName	= StringUtils.Trim(event.eBroker).toUpperCase();
			this._sProductKeyword = StringUtils.massEscape(StringUtils.Trim(event.eProductKeyword)).toUpperCase();
			this._sTypeCode		= StringUtils.Trim(event.eTypeCode).toUpperCase();
			
			if(this._sBuyingGroup == StringUtils.Trim(_sAllTextBuyingGroup.toUpperCase()))
				this._sBuyingGroup = "";
			if(this._sFamilyName == StringUtils.Trim(_sAllTextFamilyName.toUpperCase()))
				this._sFamilyName = "";
			if(this._sRegionName == StringUtils.Trim(_sAllTextRegionName.toUpperCase()))
				this._sRegionName = "";
			if(this._sBrokerName == StringUtils.Trim(_sAllTextBrokerName.toUpperCase()))
				this._sBrokerName = "";
			if(this._sTypeCode == StringUtils.Trim(_sAllTextTypeCode.toUpperCase()))
				this._sTypeCode = "";
			
			this._acReportData.filterFunction = this.reportFilterFunc;
		 	this._acReportData.refresh();
		 	CalculateTotals();
		 
		}
		
		
		// filterFunction used by filter results
		public function reportFilterFunc(item:Object):Boolean
		{
			var bReturnValue: Boolean = false;
			try
			{
			bReturnValue = (
      			// Filter Distributor Keyword 
				(
		   	    	_sDistributorKeyword.length == 0 ||
		   	    	(
		   	   		 _sDistributorKeyword.length > 0 
		   	    	 && 
		   	    		(
		   	    			item.Distributor_ID.toUpperCase().match(new RegExp(_sDistributorKeyword, 'i'))
		   	    		|| 	item.Distributor_Name.toUpperCase().match(new RegExp(_sDistributorKeyword, 'i'))
		   	    		|| 	item.Broker_Name.toUpperCase().match(new RegExp(_sDistributorKeyword, 'i'))
		   	    		|| 	item.Region_Name.toUpperCase().match(new RegExp(_sDistributorKeyword, 'i'))
		   	    		|| 	item.Family_Name.toUpperCase().match(new RegExp(_sDistributorKeyword, 'i'))
		   	    		|| 	item.Buying_Group_Name.toUpperCase().match(new RegExp(_sDistributorKeyword, 'i'))
		   	   			)
		   	    	 )
				)
				&&
				// Filter Product Keyword 
				(
		   	    	_sProductKeyword.length == 0 ||
		   	    	(
		   	   		 _sProductKeyword.length > 0 
		   	    	 && 
		   	    		(
		   	    			item.Item.toUpperCase().match(new RegExp(_sProductKeyword, 'i'))
		   	    		|| 	item.Item_Description.toUpperCase().match(new RegExp(_sProductKeyword, 'i'))
		   	    		|| 	item.Type_Code_Desc.toUpperCase().match(new RegExp(_sProductKeyword, 'i'))		   	    		
		   	   			)
		   	    	 )
				)
				&&
		   	   // Filter Buying Group 
				(
		   	    	_sBuyingGroup.length == 0 ||
		   	    	(
		   	   		 _sBuyingGroup.length > 0 
		   	    	 && 
		   	    		(
		   	    		item.Buying_Group_Name.toUpperCase().indexOf(_sBuyingGroup) >= 0
		   	   			)
		   	    	 )
				)
				&&
				// Filter Family
				(
		   	    	_sFamilyName.length == 0 ||
		   	    	(
		   	   		 _sFamilyName.length > 0 
		   	    	 && 
		   	    		(
		   	    		item.Family_Name.toUpperCase().indexOf(_sFamilyName) >= 0
		   	   			)
		   	    	 )
				)
				&&
				// Filter Region
				(
		   	    	_sRegionName.length == 0 ||
		   	    	(
		   	   		 _sRegionName.length > 0 
		   	    	 && 
		   	    		(
		   	    		item.Region_Name.toUpperCase().indexOf(_sRegionName) >= 0
		   	   			)
		   	    	 )
				)
				&&
				// Filter Broker
				(
		   	    	_sBrokerName.length == 0 ||
		   	    	(
		   	   		 _sBrokerName.length > 0 
		   	    	 && 
		   	    		(
		   	    		item.Broker_Name.toUpperCase().indexOf(_sBrokerName) >= 0
		   	   			)
		   	    	 )
				)
				&&
				// Filter Type Code Desc
				(
		   	    	_sTypeCode.length == 0 ||
		   	    	(
		   	   		 _sTypeCode.length > 0 
		   	    	 && 
		   	    		(
		   	    		item.Type_Code_Desc.toUpperCase().indexOf(_sTypeCode) >= 0
		   	   			)
		   	    	 )
				)
			) 
			}
			catch(e:Error)
			{
				bReturnValue = false;
			}
			return bReturnValue;
		}// end function reportFilterFunc
		
		// Print page Handler
		public function fnPrintPage(event:NetPriceEvent):void
		{
			page = event.ePage;
			_bShowBroker = event.eShowBroker;
			_bShowRegion = event.eShowRegion;
			_bShowFamily = event.eShowFamily;
			_bShowBuyingGroup = event.eShowBuyingGroup;
			
			_bShowCase = event.eShowCase;
			_bShowPound = event.eShowPound;
			
			_bOptionBNetSales = event.eOptionBNetSales;
			_bOptionBPercentageDiscount = event.eOptionBPercentageDiscount;
			_bOptionBSpendingRate = event.eOptionBSpendingRate;
			
			// Create an instance of the FlexPrintJob class.
            var printJob:FlexPrintJob = new FlexPrintJob();
            
            // Start the print job.
            if (printJob.start() != true) return;

            var printView:NetPricePrintView = new NetPricePrintView();
            

			printView.width=printJob.pageWidth;
			printView.height=printJob.pageHeight;
			printView.settings = settings;
						
			
			printView.ColumnWidthId = ColumnWidthId;
			printView.ColumnWidthDesc = ColumnWidthDesc;
			printView.ColumnWidthValues = ColumnWidthValues;
			
			printView.ShowBroker = _bShowBroker;
			printView.ShowRegion = _bShowRegion;
			printView.ShowFamily = _bShowFamily;
			printView.ShowBuyingGroup = _bShowBuyingGroup;
			printView.ShowTypeCode = _bShowTypeCode;
			
			printView.ShowCase = _bShowCase;
			printView.ShowPound = _bShowPound;
			
			printView.OptionBNetSales = _bOptionBNetSales;
			printView.OptionBPercentageDiscount = _bOptionBPercentageDiscount;
			printView.OptionBSpendingRate = _bOptionBSpendingRate;
			
			
			page.addChild(printView);
			
            printView.PrintGrid.dataProvider = this._acReportData;
            
            printView.showPage("single");
            
            
            if(!printView.PrintGrid.validNextPage)
			{
				printJob.addObject(printView, FlexPrintJobScaleType.MATCH_HEIGHT);	
			}
			else
			{
				printView.showPage("first");
				printJob.addObject(printView,FlexPrintJobScaleType.MATCH_HEIGHT);
				printView.pageNumber++;
				
				while(printView.pageNumber < 5)
				{
					printView.PrintGrid.nextPage();
					if(!printView.PrintGrid.validNextPage) 
					{
						// This is the last page; queue it and exit the print loop.
						printJob.addObject(printView,FlexPrintJobScaleType.MATCH_HEIGHT);
						break;
					}
					else
					{
	                    // This is not the last page. Queue a middle page.	 
						printView.showPage("middle");
						printJob.addObject(printView, FlexPrintJobScaleType.MATCH_HEIGHT);
						printView.pageNumber++;
					}
				}
			}
	        
			page.removeChild(printView);
            // Send the job to the printer.
            printJob.send();
		}
		
		// Export CSV Handler
		public function fnExportCSV(event:NetPriceEvent):void
		{
			if (!downloadFileRef)
			{
				downloadFileRef = new FileReference();
			}
			var request:URLRequest = new URLRequest();
			var fileName:String;
			var urlVar:URLVariables = new URLVariables ("userId=" + event.userId);
				
			fileName = "Effective_Net_Price_Report.csv";
			
			request.url = CSV_DOWNLOAD_URL;
			request.method = URLRequestMethod.POST;				
			request.data = urlVar;
			
			downloadFileRef.download(request, fileName);		
			
		}
		
		public function fnExportCSVOriginal(event:NetPriceEvent):void
		{
			var csvData:String = DataGridDataExporter.exportCSV (event.eDataGrid,",");
			if (csvData.length > 0)
			{
				if (!downloadFileRef)
				{
					downloadFileRef = new FileReference();
				}
				var request:URLRequest = new URLRequest();
				var fileName:String;
				var urlVar:URLVariables = new URLVariables ("csvdata=" + escape(csvData));
					
				fileName = "Effective_Net_Price_Report.csv";
				
				request.url = CSV_DOWNLOAD_URL;
				request.method = URLRequestMethod.POST;				
				request.data = urlVar;
				
				downloadFileRef.download(request, fileName);		
				
			}
		}
				

	}/* Class end */
}/* Package end */