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
	
	
	public class BBRawEDIGridManager  extends GridManager
	{
		/*................  Constructor  ...................*/
		private var dispatcher:IEventDispatcher;
		public function BBRawEDIGridManager ( dispatcher:IEventDispatcher )
		{
			super();
			this.dispatcher = dispatcher;
			this.buildGridCols();
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
			for each(var col:DataGridColumn in _arrBBRawEDIDgCols)
			{
				if 	(col.dataField == "Upload_ID")
				{
					col.headerText = "Upload ID";
				}	
				if (col.dataField == "Claim_Num")
				{
					col.headerText = this.labelSettings.appFlex.bbLabels.Billback + " #"; 
				}
				if (col.dataField == "Claim_Date")
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
		private var _arrBBRawEDIDgCols:Array = new Array();
		[Bindable (event="arrBBRawEDIDgColsChanged")]
		public function get arrBBRawEDIDgCols():Array
		{
			return _arrBBRawEDIDgCols;
		}
	
		private function sortCompareFunc(itemA:Object, itemB:Object):int
		{
			return ObjectUtil.numericCompare(itemA.BBAmount, itemB.BBAmount);	
		}
 
		public function buildGridCols():void
		{
			var col:DataGridColumn;
			//var colMulti:DataGridFilterColumnMultiSelect;
			var colMulti:DataGridFilterColumn;
			/*.....	1. isSelected	.....................  */
			col = new DataGridColumn('isSelected');
			col.dataField = 'isSelected';
			col.editable = true;
			col.sortable = false;
		//	col.width = .03;
			col.rendererIsEditor=true;
			col.headerRenderer = new ClassFactory(chBoxSelectAllDg);
			col.itemRenderer = new ClassFactory(chBoxIsSelectedDg);
			col.editorDataField = "varCbSelected";
			col.visible = false;
			_arrBBRawEDIDgCols.push(col); 

			/*.....	2. upload Id	....................   */			
			col = new DataGridFilterColumn("uploadID");
			col.dataField = "Upload_ID";
			col.headerText = "ID";
		//	col.width = .06;
			col.editable = false;
			_arrBBRawEDIDgCols.push(col);
			
			/*.....	3. Claim_Num 	Results:....................   */
			
			// col = new DataGridColumn("bbHdrCounter");
			col = new DataGridFilterColumn("bbHdrCounter");
			col.dataField = "Billback_Upload_III_PH_ID";
			col.headerText = "Hdr ID";
		//	col.width = .06;
			col.visible = true;
			col.editable = false;
			_arrBBRawEDIDgCols.push(col);
		
			/*.....	4. Claim_Num 	....................   */
			colMulti = new DataGridFilterColumn("claimNum");
			colMulti.dataField = "Claim_Num";
			colMulti.headerText = "Inv #";
		//	colMulti.width = .10;
			colMulti.editable = false;
			_arrBBRawEDIDgCols.push(colMulti);
			
			/*.....	5. Claim_Date	....................   */
			colMulti = new DataGridFilterColumn("claimDate");
			colMulti.dataField = "Claim_Date";
			colMulti.headerText = "Inv Date";
		//	colMulti.width = .10;
			colMulti.labelFunction = formatDtDg;
			colMulti.editable = false;
			_arrBBRawEDIDgCols.push(colMulti);
 			
			/*.....	6. Vendor_ID	....................   */
			colMulti = new DataGridFilterColumn("VendorID");
			colMulti.dataField = "Vendor_ID";
			colMulti.headerText = "Payee Number";
		//	colMulti.width = .10;
			colMulti.editable = false;
			_arrBBRawEDIDgCols.push(colMulti);
			
			/*.....	7. Vendor_Name	....................   */
			colMulti = new DataGridFilterColumn("vendorName");
			colMulti.dataField = "Vendor_Name";
			colMulti.headerText = "Payee Name";
	//		colMulti.width = .10;
			colMulti.editable = false;
			_arrBBRawEDIDgCols.push(colMulti);
			
			/*.....	8. Distributor_ID	....................   */
			colMulti = new DataGridFilterColumn("payeeNumber");
			colMulti.dataField = "Distributor_ID";
			colMulti.headerText = "Account Number";
		//	colMulti.width = .10;
			colMulti.editable = false;
			_arrBBRawEDIDgCols.push(colMulti);
			
			/*.....	9. Distributor_Name	....................   */
			colMulti = new DataGridFilterColumn("payeeName");
			colMulti.dataField = "Distributor_Name";
			colMulti.headerText = "Account Name";
		//	colMulti.width = .10;
			colMulti.editable = false;
			_arrBBRawEDIDgCols.push(colMulti);			
						
			/*.....	10. Total Amount	....................   */
			colMulti = new DataGridFilterColumn("ETotalClaimedAmt");
			colMulti.dataField = "E_Total_Claimed_Amt";
			colMulti.headerText = "Total Amount";
	//		colMulti.width = .05;
			colMulti.editable = false;
			_arrBBRawEDIDgCols.push(colMulti);
			
			/*.....	11. Total Volume	....................   */
			colMulti = new DataGridFilterColumn("TotVolume");
			colMulti.dataField = "Tot_Volume";
			colMulti.headerText = "Volume";
		//	colMulti.width = .05;
			colMulti.editable = false;
			_arrBBRawEDIDgCols.push(colMulti);
			
			/*.....	12. Deleted_By	....................   */
			colMulti = new DataGridFilterColumn("DeletedBy");
			colMulti.dataField = "Deleted_By";
			colMulti.headerText = "Deleted By";
		//	colMulti.width = .05;
			colMulti.editable = false;
			_arrBBRawEDIDgCols.push(colMulti);			
			
			/*.....	13. Deleted_Date	....................   */
			colMulti = new DataGridFilterColumn("DeletedDate");
			colMulti.dataField = "Deleted_Date";
			colMulti.headerText = "Deleted Date";
			colMulti.labelFunction = formatDt;
		//	colMulti.width = .05;
			colMulti.labelFunction = formatDtDg;
			colMulti.editable = false;
			_arrBBRawEDIDgCols.push(colMulti);
			
			/* ..... 14. Empty col so last row is not huge ....................*/
			col = new DataGridColumn("xSpace");
			col.visible = true;
			col.headerText = '';
		//	col.width = .01;
			col.editable = false;
			col.visible = true;
			_arrBBRawEDIDgCols.push(col); 
			dispatchEvent(new Event('arrBBRawEDIDgColsChanged'));
		}
		
		public function uomLabelFunc(item:Object, col:DataGridColumn):String{
			return item.uom.abbreviation;
		}
		
		// BBAmount
		public function BBAmountLabelFunc(item:Object, col:DataGridFilterColumn):String{
			var s:String = '';
			if(item.BBAmount){
				s = item.BBAmount;
				if(parseFloat(item.BBAmount) == item.BBAmount){
					s = _decTwoFormat.format(item.BBAmount);
				}
			}
			return s;
		}
		
	}
}