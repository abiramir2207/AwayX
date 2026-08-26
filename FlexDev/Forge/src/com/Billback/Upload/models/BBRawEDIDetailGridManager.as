package com.Billback.Upload.models
{
	import com.Billback.Upload.views.renderer.gridLabel;
	import com.shared.components.*;
	import com.shared.components.filters.DataGridFilterColumn;
	import com.shared.components.filters.DataGridFilterColumnMultiSelect;
	import com.shared.models.GridManager;
	import com.shared.views.renderer.gridCombo;
	import com.shared.vos.AppFlex;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import mx.events.FlexEvent;
	
	import mx.controls.Alert;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.utils.ObjectUtil;
	/* Presentation Model */
	
	
	public class BBRawEDIDetailGridManager  extends GridManager
	{
		/*................  Constructor  ...................*/
		private var dispatcher:IEventDispatcher;
		public function BBRawEDIDetailGridManager ( dispatcher:IEventDispatcher )
		{
			super();
			this.dispatcher = dispatcher;
			this.buildEDIGridCols();
		}
		
		// public var labelSettings:Settings = new Settings(); 
		
		private var _labelSettings:Settings = new Settings();
		[Bindable (event="labelSettingsChanged")]
		public function get labelSettings():Settings
		{
			return _labelSettings;
		}
		public function set labelSettings(s:Settings):void
		{
			this._labelSettings = s;
			dispatchEvent(new Event('labelSettingsChanged'));
			updateLabels();
		}
		
		public function updateLabels():void
		{
			for each(var col:DataGridColumn in _arrBBRawEDIItemsDgCols)
			{
				if 	(col.dataField == "UploadID")
				{
					col.headerText = "Upload ID";
				}	
				if (col.dataField == "BBNumber")
				{
					col.headerText = this.labelSettings.appFlex.bbLabels.Billback + " #"; 
				}
				if (col.dataField == "BBDate")
				{
					col.headerText = this.labelSettings.appFlex.bbLabels.Billback + " Date"; 
				}
				if (col.dataField == "Vendor_ID")
				{
					col.headerText = this.labelSettings.appFlex.bbLabels.Vendor + " Number"; 
				}
				if (col.dataField == "Vendor_Name")
				{
					col.headerText = this.labelSettings.appFlex.bbLabels.Vendor + " Name"; 
				}
			}
		} 
		/*
		Upload_ID	Billback_Upload_III_PH_ID	Claim_Num	Claim_Date	Vendor_ID	Vendor_Name	Distributor_ID	Distributor_Name	Agreement_Num	Agreement_Name
		4611	1	0400046736	01/01/2013	256021	SYSCO NORTH TEXAS	73171B51-EB4E-4DBF-8649-5771C1E6F3FF	SYSCO NORTH TEXAS	2000045052	GM(REFRIG) HPISD
		*/
		/* arrBBCorrectionsDgCols bound to dgItems.columns */
		private var _arrBBRawEDIItemsDgCols:Array = new Array();
		[Bindable (event="arrBBRawEDIItemsDgColsChanged")]
		public function get arrBBRawEDIItemsDgCols():Array
		{
			return _arrBBRawEDIItemsDgCols;
		}
		
		private function sortCompareFunc(itemA:Object, itemB:Object):int
		{
			return ObjectUtil.numericCompare(itemA.AwardAmt, itemB.AwardAmt);	
		}
		
		public function BBAmountLabelFunc(item:Object, col:DataGridFilterColumn):String{
			var s:String = '';
			if(item.AwardAmt){
				s = item.AwardAmt;
				if(parseFloat(item.AwardAmt) == item.AwardAmt){
					s = _decTwoFormat.format(item.AwardAmt);
				}
			}
			return s;
		}
 
		public function buildEDIGridCols():void
		{
			var col:DataGridColumn;
			//var colMulti:DataGridFilterColumnMultiSelect;
			var colMulti:DataGridFilterColumn;
			/*.....	1. isSelected	.....................  */
			col = new DataGridColumn('isSelected');
			col.dataField = 'isSelected';
			col.editable = true;
			col.sortable = false;
			col.width = .04;
			col.rendererIsEditor=true;
			col.headerRenderer = new ClassFactory(chBoxSelectAllDg);
			col.itemRenderer = new ClassFactory(chBoxIsSelectedDg);
			col.editorDataField = "varCbSelected";
			col.visible = false;
			_arrBBRawEDIItemsDgCols.push(col); 

			/*.....	2. Billback_Invoice_Number	....................   */			
			col = new DataGridFilterColumn("BBNumber");
			col.dataField = "BBNumber";
			col.headerText = "Claim Num";
			col.width = .04;
			col.editable = false;
			 
			_arrBBRawEDIItemsDgCols.push(col);
			
			/*.....	3. Billback_Invoice_Date ....................   */
			
			col = new DataGridColumn("BBDate");
			col.dataField = "BBDate";
			col.headerText = "Date";
			col.width = .04;
			col.visible = false;
			col.labelFunction = formatDtDg;
			col.editable = false;
			_arrBBRawEDIItemsDgCols.push(col);
		
			/*.....	4. Report_Start_Date 	....................   */
			colMulti = new DataGridFilterColumn("PeriodStDate");
			colMulti.dataField = "PeriodStDate";
			colMulti.headerText = "Start Date";
			colMulti.width = .04;
			colMulti.labelFunction = formatDtDg;
			colMulti.editable = false;
			_arrBBRawEDIItemsDgCols.push(colMulti);
			
			/*.....	5. Report_End_Date	....................   */
			colMulti = new DataGridFilterColumn("PeriodEndDate");
			colMulti.dataField = "PeriodEndDate";
			colMulti.headerText = "End Date";
			colMulti.width = .04;
			colMulti.labelFunction = formatDtDg;
			colMulti.editable = false;
			_arrBBRawEDIItemsDgCols.push(colMulti);
 			
			/*.....	6. Agreement_Number	....................   */
			colMulti = new DataGridFilterColumn("AgreementNum");
			colMulti.dataField = "AgreementNum";
			colMulti.headerText = "Agreement Number";
			colMulti.width = .04;
			colMulti.editable = false;
			_arrBBRawEDIItemsDgCols.push(colMulti);
			
			/*.....	7. Agreement_Name	....................   */
			colMulti = new DataGridFilterColumn("AgreementName");
			colMulti.dataField = "AgreementName";
			colMulti.headerText = "Agreement Name";
			colMulti.width = .05;
			colMulti.editable = false;
			_arrBBRawEDIItemsDgCols.push(colMulti);
			
			/*.....	8. Distributor_Name	....................   */
			colMulti = new DataGridFilterColumn("VendorLocNum");
			colMulti.dataField = "VendorLocNum";
			colMulti.headerText = "Distributor Name";
			colMulti.width = .05;
			colMulti.editable = false;
			_arrBBRawEDIItemsDgCols.push(colMulti);			
			
			/*.....	9. Distributor_Name_ID	....................   */
			colMulti = new DataGridFilterColumn("VendorInvNum");
			colMulti.dataField = "VendorInvNum";
			colMulti.headerText = "Distributor Name ID";
			colMulti.width = .05;
			colMulti.editable = false;
			_arrBBRawEDIItemsDgCols.push(colMulti);			
			
			/*.....	10. Ship_To_Name	....................   */
			colMulti = new DataGridFilterColumn("DCACName");
			colMulti.dataField = "DCACName";
			colMulti.headerText = "Ship to Name";
			colMulti.width = .04;
			colMulti.editable = false;
			_arrBBRawEDIItemsDgCols.push(colMulti);	
			
			/*.....	11. Ship_To_Name_ID	....................   */
			colMulti = new DataGridFilterColumn("DCACNum");
			colMulti.dataField = "DCACNum";
			colMulti.headerText = "Ship to Name ID";
			colMulti.width = .04;
			colMulti.editable = false;
			_arrBBRawEDIItemsDgCols.push(colMulti);	
			
			/*.....	12. Ship to Address	....................   */
			colMulti = new DataGridFilterColumn("STAddress1");
			colMulti.dataField = "STAddress1";
			colMulti.headerText = "Address";
			colMulti.width = .04;
			colMulti.editable = false;
			_arrBBRawEDIItemsDgCols.push(colMulti);	
			
			/*.....	13. Ship to City	....................   */
			colMulti = new DataGridFilterColumn("STCity");
			colMulti.dataField = "STCity";
			colMulti.headerText = "City";
			colMulti.width = .04;
			colMulti.editable = false;
			_arrBBRawEDIItemsDgCols.push(colMulti);	
			
			/*.....	14. Ship to State	....................   */
			colMulti = new DataGridFilterColumn("STState");
			colMulti.dataField = "STState";
			colMulti.headerText = "State";
			colMulti.width = .04;
			colMulti.editable = false;
			_arrBBRawEDIItemsDgCols.push(colMulti);	
			
			/*.....	15. Ship to Zip	....................   */
			colMulti = new DataGridFilterColumn("STZipCode");
			colMulti.dataField = "STZipCode";
			colMulti.headerText = "Zip Code";
			colMulti.width = .04;
			colMulti.editable = false;
			_arrBBRawEDIItemsDgCols.push(colMulti);	
			
			/*.....	16. Quantity_Sold	....................   */
			colMulti = new DataGridFilterColumn("CSQTY");
			colMulti.dataField = "CSQTY";
			colMulti.headerText = "QTY Sold";
			colMulti.width = .04;
			colMulti.editable = false;
			_arrBBRawEDIItemsDgCols.push(colMulti);	
			
			/*.....	17. UPC_Code	....................   */
			colMulti = new DataGridFilterColumn("UPCCODE");
			colMulti.dataField = "UPCCODE";
			colMulti.headerText = "UPC Code";
			colMulti.width = .04;
			colMulti.editable = false;
			_arrBBRawEDIItemsDgCols.push(colMulti);	
			
			/*.....	18. Manufacture_Item_ID	....................   */
			colMulti = new DataGridFilterColumn("ManufactureItemID ");
			colMulti.dataField = "ManufactureItemID";
			colMulti.headerText = "Manufacture Item ID ";
			colMulti.width = .05;
			colMulti.editable = false;
			_arrBBRawEDIItemsDgCols.push(colMulti);	
			
			/*.....	19. Customer_Invoice_Item	....................   */
			colMulti = new DataGridFilterColumn("DCProductNum");
			colMulti.dataField = "DCProductNum";
			colMulti.headerText = "Customer Invoice Item ";
			colMulti.width = .05;
			colMulti.editable = false;
			_arrBBRawEDIItemsDgCols.push(colMulti);	
			
			/*.....	20. Charge_Back_Amount	....................   */
			colMulti = new DataGridFilterColumn("AwardAmt");
			colMulti.dataField = "AwardAmt";
			colMulti.headerText = "Charge Back Amount ";
			colMulti.width = .05;
			colMulti.editable = false;
			colMulti.labelFunction = BBAmountLabelFunc;
			colMulti.sortCompareFunction = sortCompareFunc;
			_arrBBRawEDIItemsDgCols.push(colMulti);	
			
			/*.....	21. Item_Description	....................   */
			colMulti = new DataGridFilterColumn("DCProductDesc");
			colMulti.dataField = "DCProductDesc";
			colMulti.headerText = "Item Description";
			colMulti.width = .05;
			colMulti.editable = false;
			_arrBBRawEDIItemsDgCols.push(colMulti);	
			
			/*.....	22. Billback_Invoice_Number	....................   */			
			col = new DataGridFilterColumn("DeletedBy");
			col.dataField = "DeletedBy";
			col.headerText = "Deleted By";
			col.width = .04;
			col.editable = false;
			
			_arrBBRawEDIItemsDgCols.push(col);
			
			/*.....	23. Billback_Invoice_Date ....................   */
			
			col = new DataGridFilterColumn("DeletedDate");
			col.dataField = "DeletedDate";
			col.headerText = "Deleted Date";
			col.width = .04;
			col.labelFunction = formatDtDg;
			col.editable = false;
			_arrBBRawEDIItemsDgCols.push(col);
	
			/* ..... 24. Empty col so last row is not huge ....................*/
			col = new DataGridColumn("xSpace");
			col.visible = true;
			col.headerText = '';
			col.width = .01;
			col.editable = false;
			col.visible = true;
			_arrBBRawEDIItemsDgCols.push(col); 
			dispatchEvent(new Event('arrBBRawEDIItemsDgColsChanged'));
		}
		
		public function uomLabelFunc(item:Object, col:DataGridColumn):String{
			return item.uom.abbreviation;
		}
		
		/*public function errLabelFunc(item:Object, col:DataGridFilterColumn):String{
		var s:String = item[col.dataField].toString();
		//col.setStyle('color','red');
		//col.setStyle('font-style','italic');
		return s;
		}*/
	
		
	}
}