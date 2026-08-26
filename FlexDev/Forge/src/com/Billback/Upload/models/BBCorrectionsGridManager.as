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
	
	
	public class BBCorrectionsGridManager  extends GridManager
	{
		/*................  Constructor  ...................*/
		private var dispatcher:IEventDispatcher;
		public function BBCorrectionsGridManager ( dispatcher:IEventDispatcher )
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
			for each(var col:DataGridColumn in _arrBBCorrectionsDgCols)
			{
				if (col.dataField == "BBReference")
				{
					col.headerText = this.labelSettings.appFlex.bbLabels.Billback; 
				}
				if (col.dataField == "vendorName")
				{
					col.headerText = this.labelSettings.appFlex.bbLabels.Vendor; 
				}
				if (col.dataField == "BBAmount")
				{
					col.headerText = this.labelSettings.appFlex.bbLabels.Claimed; 
				}
				if (col.dataField == "startDate")
				{
					col.headerText = this.labelSettings.appFlex.bbLabels.Delivery_Period_Start; 
				}
				if (col.dataField == "endDate")
				{
					col.headerText = this.labelSettings.appFlex.bbLabels.Delivery_Period_End; 
				}
			}
		} 
		
		/* arrBBCorrectionsDgCols bound to dgItems.columns */
		private var _arrBBCorrectionsDgCols:Array = new Array();
		[Bindable (event="arrBBCorrectionsDgColsChanged")]
		public function get arrBBCorrectionsDgCols():Array
		{
			return _arrBBCorrectionsDgCols;
		}
		/*	this.itemGuid = bbProdRate.itemGuid;
		this.isSelected = bbProdRate.isSelected;
		this.itemNumber = bbProdRate.itemNumber;
		this.description = bbProdRate.description;
		this.uom = bbProdRate.uom;
		this.rate = bbProdRate.rate;
		this.volume = bbProdRate.volume;*/
		
		private function sortCompareFunc(itemA:Object, itemB:Object):int
		{
			return ObjectUtil.numericCompare(itemA.BBAmount, itemB.BBAmount);	
		}
 
		public function buildGridCols():void
		{
			var col:DataGridColumn;
			//var colMulti:DataGridFilterColumnMultiSelect;
			var colMulti:DataGridFilterColumn;
			/*.....	isSelected	.....................  */
			col = new DataGridColumn('isSelected');
			col.dataField = 'isSelected';
			col.editable = true;
			col.sortable = false;
			col.width = .03;
			col.rendererIsEditor=true;
			col.headerRenderer = new ClassFactory(chBoxSelectAllDg);
			col.itemRenderer = new ClassFactory(chBoxIsSelectedDg);
			col.editorDataField = "varCbSelected";
			_arrBBCorrectionsDgCols.push(col); 

			/*.....	upload Id	....................   */			
			col = new DataGridFilterColumn("uploadID");
			col.dataField = "uploadID";
			col.headerText = "ID";
			col.width = .05;
			col.editable = false;
			_arrBBCorrectionsDgCols.push(col);
			
			col = new DataGridColumn("bbHdrCounter");
			col.dataField = "bbHdrCounter";
			col.headerText = "Hdr ID";
			col.width = .04;
			col.editable = false;
			_arrBBCorrectionsDgCols.push(col);
			
			/*.....	uploadUser	....................   */
			colMulti = new DataGridFilterColumn("uploadUser");
			colMulti.dataField = "uploadUser.fullName";
			colMulti.headerText = "Upload User";
			colMulti.width = .10;
			colMulti.editable = false;
			_arrBBCorrectionsDgCols.push(colMulti);
			
			/*.....	Status 	....................   */
			colMulti = new DataGridFilterColumn("uploadStatus");
			colMulti.dataField = "uploadStatus";
			colMulti.headerText = "Status";
			colMulti.width = .14;
			colMulti.editable = false;
			_arrBBCorrectionsDgCols.push(colMulti);
			
			/*.....	uploadDateTime	....................   */
			colMulti = new DataGridFilterColumn("uploadDateTime");
			colMulti.dataField = "uploadDateTime";
			colMulti.headerText = "Upload Date";
			colMulti.width = .11;
			colMulti.labelFunction = formatDateTime;
			colMulti.editable = false;
			_arrBBCorrectionsDgCols.push(colMulti);
 			
			/*.....	BBReference	....................   */
			colMulti = new DataGridFilterColumn("BBReference");
			colMulti.dataField = "BBReference";
			colMulti.headerText = "Cust Invoice";
			colMulti.width = .10;
			colMulti.editable = false;
			_arrBBCorrectionsDgCols.push(colMulti);
			
			/*.....	vendorName	....................   */
			colMulti = new DataGridFilterColumn("vendorName");
			colMulti.dataField = "vendorName";
			colMulti.headerText = "Vendor Name";
			colMulti.width = .11;
			colMulti.editable = false;
			_arrBBCorrectionsDgCols.push(colMulti);
			
			/*.....	BBAmount	....................   */
			colMulti = new DataGridFilterColumn("BBAmount");
			colMulti.dataField = "BBAmount";
			colMulti.headerText = "Amount";
			colMulti.labelFunction = BBAmountLabelFunc;
			colMulti.width = .08;
			colMulti.editable = false;
			colMulti.sortCompareFunction = sortCompareFunc;
			_arrBBCorrectionsDgCols.push(colMulti);
			
			/*.....	startDate	....................   */
			colMulti = new DataGridFilterColumn("startDate");
			colMulti.dataField = "startDate";
			colMulti.headerText = "Start Date";
			colMulti.width = .08;
			colMulti.editable = false;
			_arrBBCorrectionsDgCols.push(colMulti);
			
			/*.....	endDate	....................   */
			colMulti = new DataGridFilterColumn("endDate");
			colMulti.dataField = "endDate";
			colMulti.headerText = "End Date";
			//col.labelFunction = formatDollar;//comes from extends GridManager in shared.models
			colMulti.width = .08;
			colMulti.editable = false;
			_arrBBCorrectionsDgCols.push(colMulti);
			
			/*.....	uploadType ....................   */
			colMulti = new DataGridFilterColumn("uploadType");
			colMulti.dataField = "uploadType";
			colMulti.headerText = "Type";
			colMulti.width = .07;
			colMulti.editable = false;
			_arrBBCorrectionsDgCols.push(colMulti);
						
			/* Empty col so last row is not huge ....................*/
			col = new DataGridColumn("xSpace");
			col.visible = true;
			col.headerText = '';
			col.width = .01;
			col.editable = false;
			col.visible = true;
			_arrBBCorrectionsDgCols.push(col); 
			dispatchEvent(new Event('arrBBCorrectionsDgColsChanged'));
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