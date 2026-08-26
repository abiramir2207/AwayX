package com.Billback.Search.models
{
	import com.Billback.Main.models.vos.Type;
	import com.Billback.Search.views.billback_details;
	import com.Billback.Search.vos.BBFilterParams;
	import com.Billback.Search.vos.BBSearchGridColumnSize;
	import com.shared.components.*;
	import com.shared.models.GridManager;
	import com.shared.models.entity.vos.User;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.core.ClassFactory;
	import mx.utils.ObjectUtil;
	
	import spark.components.gridClasses.*;
	
	public class BBSearchGridManager extends GridManager
	{
		/*................  Constructor  ...................*/
		private var dispatcher:IEventDispatcher;		
		
		//private var eBBFilterParams:BBFilterParams = new BBFilterParams();	
		private var objBBSearchGridColumnSize:BBSearchGridColumnSize =  new BBSearchGridColumnSize();
	
		public function setAllColumnsSize(columnObject:BBSearchGridColumnSize):void
		{			
			var intNumberColumns:int = 0;
			
			/* Assign the column width of all the default visible columns based on the values from the db which are either saved by the user 
			  OR are default values. Also, assign the column header names based on label names.
			*/
			for each(var col:AdvancedDataGridColumn in arrBBSearchDgCols)
			{
				if(col.headerText == 'Status'){
					col.width = columnObject.status;
				}
				
				if(col.headerText == 'Payable'){
					col.width = columnObject.BBCode;
					col.headerText = this.oSettings.appFlex.bbLabels.Payable;
				}
				
				if(col.headerText == 'Billback'){
					col.width = columnObject.BBNumber;
					col.headerText = this.oSettings.appFlex.bbLabels.Billback;
				}
				
				if(col.headerText == 'Title'){
					col.width = columnObject.title;
					col.headerText = this.oSettings.appFlex.bbLabels.Title;
				}
				
				if(col.headerText == 'BB Date'){
					col.width = columnObject.BBDate;
					col.headerText = this.oSettings.appFlex.bbLabels.Billback + ' Date';
				}
				
				if(col.headerText == 'Received Date'){
					col.width = columnObject.BBReceivedDate;
					col.headerText = 'Received Date';
				}
				
				if(col.headerText == 'Payee'){
					col.width = columnObject.payee;
					col.headerText = this.oSettings.appFlex.bbLabels.Payee;
				}
				
				if(col.headerText == 'Vendor'){
					col.width = columnObject.vendor;
					col.headerText = this.oSettings.appFlex.bbLabels.Vendor;
				}
				
				if(col.headerText == 'Start Date'){
					col.width = columnObject.startDate;
					col.headerText = this.oSettings.appFlex.bbLabels.Delivery_Period_Start;
				}
				
				if(col.headerText == 'End Date'){
					col.width = columnObject.endDate;
					col.headerText = this.oSettings.appFlex.bbLabels.Delivery_Period_End;
				}
				
				if(col.headerText == 'Claimed'){
					col.width = columnObject.claimedAmount;
					col.headerText = this.oSettings.appFlex.bbLabels.Claimed;
				}
				
				if(col.headerText == 'Approved'){
					col.width = columnObject.approvedAmount;
				}
				
				if(col.headerText == 'Closing Method'){
					col.width = columnObject.closingMethod;
					col.headerText = this.oSettings.appFlex.bbLabels.Closing_Method;
				}
				
				if(col.headerText == 'More Info'){
					col.width = columnObject.moreInfo;
				}
			}

			dispatchEvent(new Event('arrBBSearchDgColsChanged'));
		}
		
		/* 	Assign the column width of the column selected by the user. The user uses the horizontal slider to adjust the column width */
		public function setColumnSize(columnName:String,columnWidth:int):void
		{
			
			for each(var col:AdvancedDataGridColumn in arrBBSearchDgCols)
			{
				if(columnName == col.headerText){
		
					col.width =  columnWidth;
				}
				
					if(col.headerText == 'Status'){
			 			this.objBBSearchGridColumnSize.status = col.width;
			 		}
			 		
			 		if(col.headerText == this.oSettings.appFlex.bbLabels.Payable){
			 			this.objBBSearchGridColumnSize.BBCode = col.width;
			 		}
			 		
			 		if(col.headerText == this.oSettings.appFlex.bbLabels.Billback){
			 			this.objBBSearchGridColumnSize.BBNumber = col.width;
			 		}
			 		
			 		if(col.headerText == this.oSettings.appFlex.bbLabels.Title){
			 			this.objBBSearchGridColumnSize.title = col.width;;
			 		}
			 		
			 		if(col.headerText == this.oSettings.appFlex.bbLabels.Billback + ' Date'){
			 			this.objBBSearchGridColumnSize.BBDate = col.width;
			 		}
			 		
					if(col.headerText == 'Received Date'){
						this.objBBSearchGridColumnSize.BBReceivedDate = col.width;
					}
					
			 		if(col.headerText == this.oSettings.appFlex.bbLabels.Payee){
			 			this.objBBSearchGridColumnSize.payee = col.width;
			 		}
			 		
			 		if(col.headerText == this.oSettings.appFlex.bbLabels.Vendor){
			 			this.objBBSearchGridColumnSize.vendor = col.width;
			 		}
			 		
			 		if(col.headerText == this.oSettings.appFlex.bbLabels.Delivery_Period_Start){
			 			this.objBBSearchGridColumnSize.startDate = col.width;
			 		}
			 		
			 		if(col.headerText == this.oSettings.appFlex.bbLabels.Delivery_Period_End){
			 			this.objBBSearchGridColumnSize.endDate = col.width;
			 		}
			 		
			 		if(col.headerText == this.oSettings.appFlex.bbLabels.Claimed){
			 			this.objBBSearchGridColumnSize.claimedAmount = col.width;
			 		}
			 		
			 		if(col.headerText == 'Approved'){
			 			this.objBBSearchGridColumnSize.approvedAmount = col.width;
			 		}
			 		
			 		if(col.headerText == this.oSettings.appFlex.bbLabels.Closing_Method){
			 			this.objBBSearchGridColumnSize.closingMethod = col.width;
			 		}
			 		
			 		if(col.headerText == 'More Info'){
			 			this.objBBSearchGridColumnSize.moreInfo = col.width;
			 		}				
								
				
			}

			dispatchEvent(new Event('arrBBSearchDgColsChanged'));
		}
		
		public function showHideColumns(eBBFilterParams:BBFilterParams):void
		{			
			var arrSelectedBBTypes:Array = new Array();	

			/* Loop through the "Type object" and populate the arrSelectedBBTypes Array
			   with the description from the Status Object.
			*/
			for each(var oBBType:Type in eBBFilterParams.typeListSelect)
			{   if(oBBType != null)
				{
					arrSelectedBBTypes.push(oBBType.id);
				}
				
			}		
			
			var arrSelectedAnalysts:Array = new Array();	
			
			/* Loop through the "User object" and populate the arrSelectedAnalysts Array
			   with the fullName from the Status Object.
			*/
			for each(var oUser:User in eBBFilterParams.analystListSelect)
			{   if(oUser != null)
				{
					arrSelectedAnalysts.push(oUser.idInt);
				}				
			}
			
			var arrSelectedCreatorUser:Array = new Array();	
			var arrSelectedRFAUser:Array = new Array();	
			var arrSelectedApproverUser:Array = new Array();
			var arrSelectedDisagreeUser:Array = new Array();
			var arrSelectedResetUser:Array = new Array();
			
			/* Loop through the "User object" and populate the arrSelectedAnalysts Array
			   with the fullName from the Status Object.
			*/
			for each(var oHistoryUser:User in eBBFilterParams.historyUsernameSelect)
			{   if(oHistoryUser != null)
				{
					if(eBBFilterParams.historySelect == 'Created By'){
						arrSelectedCreatorUser.push(oHistoryUser.idInt);
					}

					if(eBBFilterParams.historySelect == 'RFA By'){
						arrSelectedRFAUser.push(oHistoryUser.idInt);
					}
					
					if(eBBFilterParams.historySelect == 'Approved By'){
						arrSelectedApproverUser.push(oHistoryUser.idInt);
					}
					
					if(eBBFilterParams.historySelect == 'Disagreed By'){
						arrSelectedDisagreeUser.push(oHistoryUser.idInt);
					}
					
					if(eBBFilterParams.historySelect ==  'Reset By'){
						arrSelectedResetUser.push(oHistoryUser.idInt);
					}
				}
			}		

			/* These columns are hidden by default. When the user selects a search option, the show that appropriate column. Eg: When user selects "Type" from the
			   dropdown, show the "Type" column.
			 */
			for each(var col:AdvancedDataGridColumn in arrBBSearchDgCols)
			{
				if(col.headerText == 'Type'){
					col.visible =  Boolean(arrSelectedBBTypes.length);
				}
				
				if(col.headerText == 'Analyst'){
					col.visible =  Boolean(arrSelectedAnalysts.length);
				}
				
				if(col.headerText == 'Creator'){
					col.visible =  Boolean(arrSelectedCreatorUser.length);
				}
				
				if(col.headerText == 'RFA By'){
					col.visible =  Boolean(arrSelectedRFAUser.length);
				}
				
				if(col.headerText == 'Approved By'){
					col.visible =  Boolean(arrSelectedApproverUser.length);
				}
				
				if(col.headerText == 'Disagree By'){
					col.visible =  Boolean(arrSelectedDisagreeUser.length);
				}
				
				if(col.headerText == 'Reset By'){
					col.visible =  Boolean(arrSelectedResetUser.length);
				}
			}

			dispatchEvent(new Event('arrBBSearchDgColsChanged'));
		}
		
		
		public function BBSearchGridManager ( dispatcher:IEventDispatcher )
		{
			super();
			this.dispatcher = dispatcher;
			this.buildGridCols();
		}		
		
		/* arrBBSearchDgCols bound to dgItems.columns */
		private var _arrBBSearchDgCols:Array = new Array();
		[Bindable (event="arrBBSearchDgColsChanged")]
		public function get arrBBSearchDgCols():Array
		{
			return _arrBBSearchDgCols;
		}

		public function buildGridCols():void
		{
			var col:AdvancedDataGridColumn;
			/*.....	isSelected	.....................  */
			col = new AdvancedDataGridColumn('isSelected');
			col.dataField = 'isSelected';
			col.editable = true;
			col.sortable = false;
			col.width = 40;
			col.rendererIsEditor=true;
			col.headerRenderer = new ClassFactory(chBoxSelectAll);
			col.itemRenderer = new ClassFactory(chBoxIsSelected);
			//col.itemEditor = new ClassFactory(chBoxIsSelectedSpark);
			//col.rendererIsEditable = true;
			//col.editorDataField = "varCbSelected";
			_arrBBSearchDgCols.push(col);
			/*.....	Status	....................   */
			col = new AdvancedDataGridColumn("status");
			col.labelFunction = statusLabelFunc;
			//col.dataField = "status";
			col.headerText = "Status";
			col.sortCompareFunction = statusSortFunc;
			//col.width = 85;
			 col.editable = false;
			_arrBBSearchDgCols.push(col);
			/*.....	BBCode (Payable #)	...................  */
			col = new AdvancedDataGridColumn("BBCode");
			//col.dataField = "BBCode";
			col.headerText = "Payable";
			//col.width = 85;
			col.editable = false;
			_arrBBSearchDgCols.push(col);
			/*.....	BB #	...................  */
			col = new AdvancedDataGridColumn("BBNumber");
			//col.dataField = "BBNumber";
			col.headerText = "Billback";
			//col.width = 100;
			col.editable = false;
			_arrBBSearchDgCols.push(col);
			col = new AdvancedDataGridColumn("title");
			//col.dataField = "title";
			col.headerText = "Title";
			//col.width = 75;
			col.editable = false;
			_arrBBSearchDgCols.push(col);
			/*.....	BBDate	....................   */
		/*	col = new AdvancedDataGridColumn("BBDate");
			//col.dataField = "BBDate";
			col.headerText = "BB Date";
			col.labelFunction = formatDt;
			//col.width = 100;
			col.editable = false;
			_arrBBSearchDgCols.push(col);
			
			*/
			/*.....	BB Received Date	....................   */
			col = new AdvancedDataGridColumn("BBReceivedDate");
			//col.dataField = "BBDate";
			col.headerText = "Received Date";
			col.labelFunction = formatDt;
			//col.width = 100;
			col.editable = false;
			_arrBBSearchDgCols.push(col);
			
			/*.....	Payee	....................   */
			col = new AdvancedDataGridColumn("payee");
			//col.dataField = "payee";
			col.headerText = "Payee";
			col.labelFunction = payeeLabelFunc;
			col.sortCompareFunction = payeeLabelSortFunc;
			//col.width = 100;
			col.editable = false;
			_arrBBSearchDgCols.push(col);
			/*.....	Payee ID	....................   */
			col = new AdvancedDataGridColumn("payee");
			//col.dataField = "payee";
			col.headerText = "Payee ID";
			col.labelFunction = payeeIDLabelFunc;
			col.sortCompareFunction = payeeIDSortFunc;
			//col.width = 100;
			col.editable = false;
			col.visible = false;
			_arrBBSearchDgCols.push(col);
			/*.....	Vendor Name	....................   */
			col = new AdvancedDataGridColumn("vendor");
			col.headerText = "Vendor";
			col.labelFunction = vendorLabelFunc;
			col.sortCompareFunction = vendorLabelSortFunc;
			//col.width = 100;
			col.editable = false;
			_arrBBSearchDgCols.push(col);
			/*.....	Vendor ID	....................   */
			col = new AdvancedDataGridColumn("vendor");
			col.headerText = "Vendor ID";
			col.labelFunction = vendorIDLabelFunc;
			col.sortCompareFunction = vendorIDSortFunc;
			//col.width = 100;
			col.editable = false;
			col.visible = false;
			_arrBBSearchDgCols.push(col);
			/*.....	Start Date....................   */
			col = new AdvancedDataGridColumn("startDate");
			//col.dataField = "StartDate";
			col.headerText = "Start Date";
			col.labelFunction = formatDt;
			//col.width = 100;
			col.editable = false;
			_arrBBSearchDgCols.push(col);
			/*.....	End Date	....................   */
			col = new AdvancedDataGridColumn("endDate");
			//col.dataField = "endDate";
			col.headerText = "End Date";
			col.labelFunction = formatDt;
			//col.width = 75;
			col.editable = false;
			_arrBBSearchDgCols.push(col);
			/*.....	Claimed $	....................   */
			col = new AdvancedDataGridColumn("amount");
			//col.dataField = "amount";
			col.labelFunction = StringUtils.FormatDecimal2;
			col.headerText = "Claimed";
			//col.width = 75;
			col.editable = false;
			_arrBBSearchDgCols.push(col);
			/*.....	Approved $	....................   */
			col = new AdvancedDataGridColumn("approvedAmount");
			//col.dataField = "approvedAmount";
			col.labelFunction = StringUtils.FormatDecimal2;
			col.headerText = "Approved";
			//col.width = 75;
			col.editable = true;
			_arrBBSearchDgCols.push(col);
			/*.....	Closing Method	....................   */
			col = new AdvancedDataGridColumn("closingMethod");
			//col.dataField = "closingMethod";
			col.headerText = "Closing Method";
			col.labelFunction = closingMethodLabelFunc;
			col.sortCompareFunction = closingMethodSortFunc;
			//col.width = 100;
			col.visible = true;
			col.editable = false;
			_arrBBSearchDgCols.push(col);
			/*.....	Analyst....................  */
			col = new AdvancedDataGridColumn("analyst");
			//col.dataField = "analyst";
			col.visible = false;
			col.headerText = "Analyst";
			col.labelFunction = analystLabelFunc;
			col.sortCompareFunction = analystSortFunc;
			//col.width = 125;
			col.editable = false;
			_arrBBSearchDgCols.push(col);
			/*.....	Creator ....................  */
			col = new AdvancedDataGridColumn("creator");
			//col.dataField = "creator";
			col.visible = false;
			col.headerText = "Creator";
			col.labelFunction = creatorLabelFunc;
			col.sortCompareFunction = creatorSortFunc;
			//col.width = 125;
			col.editable = false;
			_arrBBSearchDgCols.push(col);
			/*.....	RFA By ....................  */
			col = new AdvancedDataGridColumn("requestApproval");
			//col.dataField = "requestApproval";
			col.visible = false;
			col.headerText = "RFA By";
			col.labelFunction = RFAByLabelFunc;
			col.sortCompareFunction = RFABySortFunc;
			//col.width = 125;
			col.editable = false;
			_arrBBSearchDgCols.push(col);
			/*.....	Disagree By ....................  */
			col = new AdvancedDataGridColumn("disagree");
			//col.dataField = "disagree";
			col.visible = false;
			col.headerText = "Disagree By";
			col.labelFunction = disagreeByLabelFunc;
			col.sortCompareFunction = disagreeBySortFunc;
			//col.width = 125;
			col.editable = false;
			_arrBBSearchDgCols.push(col);
			/*.....	Reset By ....................  */
			col = new AdvancedDataGridColumn("reset");
			//col.dataField = "reset";
			col.visible = false;
			col.headerText = "Reset By";
			col.labelFunction = resetByLabelFunc;
			col.sortCompareFunction = resetBySortFunc;
			//col.width = 125;
			col.editable = false;
			_arrBBSearchDgCols.push(col);
			/*.....	Approved By ....................  */
			col = new AdvancedDataGridColumn("approved");
			//col.dataField = "approved";
			col.visible = false;
			col.headerText = "Approved By";
			col.labelFunction = approvedByLabelFunc;
			col.sortCompareFunction = approvedBySortFunc;
			//col.width = 125;
			col.editable = false;
			_arrBBSearchDgCols.push(col);
			/*.....	BB Type ....................  */
			col = new AdvancedDataGridColumn("BBtype");
			//col.dataField = "BBtype";
			col.visible = false;
			col.headerText = "Type";
			col.labelFunction = BBTypeLabelFunc;
			col.sortCompareFunction = BBTypeSortFunc;
			//col.width = 125;
			col.editable = false;
			_arrBBSearchDgCols.push(col);
			/*.....	Check Number ....................  */
			col = new AdvancedDataGridColumn("checkNumber");
			//col.dataField = "checkNumber";
			col.visible = false;
			col.headerText = "Check #";
			//col.width = 125;
			col.editable = false;
			_arrBBSearchDgCols.push(col);
			/*.....	Billback_ID_Int ....................  */
			col = new AdvancedDataGridColumn("billbackIDInt");
			//col.dataField = "billbackIDInt";
			col.visible = false;
			col.headerText = "billbackIDInt";
			//col.width = 125;
			col.editable = false;
			_arrBBSearchDgCols.push(col);
			/*.....	More Info ....................  */
			col = new AdvancedDataGridColumn("");
			col.dataField = "";
			col.itemRenderer = new ClassFactory(billback_details);
			col.visible = true;
			col.headerText = "More Info";
			// set a default size to avoid scrollbars before it completely loads
			//col.width = 175;
			col.editable = false;
			col.sortable = false;
			_arrBBSearchDgCols.push(col);
			/* Empty col so last row is not huge */
			col = new AdvancedDataGridColumn("xSpace");
			col.visible = true;
			col.headerText = '';
			col.width = -2.99;
			col.editable = false;
			_arrBBSearchDgCols.push(col);
			dispatchEvent(new Event('arrBBSearchDgColsChanged'));
		}
			/* GRID COLUMN LABEL FUNCTIIONS */
			private function statusLabelFunc(item:Object, col:AdvancedDataGridColumn):String
		    {
		    	var strAbbr:String = '';
		    	
		    	 if(item.status){
		    	 	strAbbr =  item.status.abbreviation;		    	 	
		    	 }

		    	 return strAbbr;
		    }
		    
			private function payeeLabelFunc(item:Object, col:AdvancedDataGridColumn):String
		    {
		    	var strPayeeName:String = '';
		    	
		    	 if(item.payee){
		    	 	strPayeeName =  item.payee.name;		    	 	
		    	 }

		    	 return strPayeeName;
		    }
		    
		    private function payeeIDLabelFunc(item:Object, col:AdvancedDataGridColumn):String
		    {	
		    	var strPayeeID:String = '';
		    	
		    	 if(item.payee){
		    	 	strPayeeID =  item.payee.payeeId;		    	 	
		    	 }

		    	 return strPayeeID;
		    }
		    
		    private function vendorLabelFunc(item:Object, col:AdvancedDataGridColumn):String
		    {
		    	var strVendorName:String = '';
		    	
		    	 if(item.vendor){
		    	 	strVendorName =  item.vendor.name;		    	 	
		    	 }

		    	 return strVendorName;
		    }
		    
		    private function vendorIDLabelFunc(item:Object, col:AdvancedDataGridColumn):String
		    {
		    	var strVendorID:String = '';
		    	
		    	 if(item.vendor){
		    	 	strVendorID =  item.vendor.payeeId;		    	 	
		    	 }

		    	 return strVendorID;
		    }
		    
		    private function closingMethodLabelFunc(item:Object, col:AdvancedDataGridColumn):String
		    {
		    	var strClosingMethod:String = '';
		    	
		    	 if(item.closingMethod){
		    	 	strClosingMethod =  item.closingMethod.abbreviation;		    	 	
		    	 }

		    	 return strClosingMethod;
		    }
		    
		    private function analystLabelFunc(item:Object, col:AdvancedDataGridColumn):String
		    {
		    	var strAnalyst:String = '';
		    	
		    	 if(item.analyst){
		    	 	strAnalyst =  item.analyst.fullName;		    	 	
		    	 }

		    	 return strAnalyst;
		    }
		    
		    private function creatorLabelFunc(item:Object, col:AdvancedDataGridColumn):String
		    {	
		    	var strCreator:String = '';
		    	
		    	 if(item.creator){
		    	 	strCreator =  item.creator.fullName;		    	 	
		    	 }
		    	 
		    	 return strCreator;
		    }
		    
		  	private function RFAByLabelFunc(item:Object, col:AdvancedDataGridColumn):String
		    {
		    	 var strRFA:String = '';
		    	
		    	 if(item.requestApproval){
		    	 	strRFA =  item.requestApproval.fullName;		    	 	
		    	 } 
		    	 
		    	return strRFA;
		    }
		    
		    private function disagreeByLabelFunc(item:Object, col:AdvancedDataGridColumn):String
		    {
		    	var strDisagree:String = '';
		    	
		    	 if(item.requestApproval){
		    	 	strDisagree =  item.disagree.fullName;		    	 	
		    	 } 
		    	 
		    	 return strDisagree;
		    }
		    
		    private function resetByLabelFunc(item:Object, col:AdvancedDataGridColumn):String
		    {
		    	var strReset:String = '';
		    	
		    	 if(item.requestApproval){
		    	 	strReset =  item.reset.fullName;		    	 	
		    	 } 
		    	 
		    	 return strReset;
		    }
		    
		    private function approvedByLabelFunc(item:Object, col:AdvancedDataGridColumn):String
		    {
		    	var strApproved:String = '';
		    	
		    	 if(item.requestApproval){
		    	 	strApproved =  item.approved.fullName;		    	 	
		    	 } 
		    	 
		    	 return strApproved;
		    }
		    
		    private function BBTypeLabelFunc(item:Object, col:AdvancedDataGridColumn):String
		    {
		    	var strBBType:String = '';
		    	
		    	 if(item.requestApproval){
		    	 	strBBType =  item.BBtype.description;		    	 	
		    	 } 
		    	 
		    	 return strBBType;
		    }
		    
		    
		    /* GRID COLUMN SORT FUNCTIIONS. "true" is case-insensitive sorting */
		    private function statusSortFunc(itemA:Object, itemB:Object):int
		    {
		    	return ObjectUtil.stringCompare(itemA.status.abbreviation, itemB.status.abbreviation, true);
		    }
		    
		 	private function payeeLabelSortFunc(itemA:Object, itemB:Object):int
         	{
				return ObjectUtil.stringCompare(itemA.payee.name, itemB.payee.name, true);	
         	}
         	
         	private function payeeIDSortFunc(itemA:Object, itemB:Object):int
		    {
		    	 return ObjectUtil.stringCompare(itemA.payee.payeeId, itemB.payee.payeeId, true);
		    }
		    
		    private function vendorLabelSortFunc(itemA:Object, itemB:Object):int
         	{
				return ObjectUtil.stringCompare(itemA.vendor.name, itemB.vendor.name, true);	
         	}
         	
         	private function vendorIDSortFunc(itemA:Object, itemB:Object):int
         	{
				return ObjectUtil.stringCompare(itemA.vendor.payeeId, itemB.vendor.payeeId, true);	
         	}
         	
		    private function closingMethodSortFunc(itemA:Object, itemB:Object):int
		    {
		    	 return ObjectUtil.stringCompare(itemA.closingMethod.abbreviation, itemB.closingMethod.abbreviation, true);
		    }
		    
		   	private function analystSortFunc(itemA:Object, itemB:Object):int
		    {
		    	 return ObjectUtil.stringCompare(itemA.analyst.fullName, itemB.analyst.fullName, true);
		    }
		    
		 	private function creatorSortFunc(itemA:Object, itemB:Object):int
         	{
				return ObjectUtil.stringCompare(itemA.creator.fullName, itemB.creator.fullName, true);	
         	}
         	
         	private function RFABySortFunc(itemA:Object, itemB:Object):int
		    {
		    	 return ObjectUtil.stringCompare(itemA.requestApproval.fullName, itemB.requestApproval.fullName, true);
		    }		    
		 
		    private function disagreeBySortFunc(itemA:Object, itemB:Object):int
		    {
		    	 return ObjectUtil.stringCompare(itemA.disagree.fullName, itemB.disagree.fullName, true);
		    }
		    
		    private function resetBySortFunc(itemA:Object, itemB:Object):int
		    {
		    	 return ObjectUtil.stringCompare(itemA.reset.fullName, itemB.reset.fullName, true);
		    }
		    
		    private function approvedBySortFunc(itemA:Object, itemB:Object):int
		    {
		    	 return ObjectUtil.stringCompare(itemA.approved.fullName, itemB.approved.fullName, true);
		    }
		    
		    private function BBTypeSortFunc(itemA:Object, itemB:Object):int
		    {
		    	 return ObjectUtil.stringCompare(itemA.BBtype.description, itemB.BBtype.description, true);
		    }
	}
}