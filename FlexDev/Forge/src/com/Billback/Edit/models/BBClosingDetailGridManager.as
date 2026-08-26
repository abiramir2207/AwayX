package com.Billback.Edit.models
{
	import com.Billback.Edit.views.renderer.closingMethodCombo;
	import com.Billback.Edit.views.renderer.ViewDeductions;
	import com.Billback.Upload.views.renderer.gridLabel;
	import com.shared.components.*;
	import com.shared.components.DataGridClearColumn;
	import com.shared.components.filters.DataGridDeleteColumn;
	import com.shared.components.filters.DataGridFilterColumn;
	import com.shared.components.filters.DataGridFilterColumnMultiSelect;
	import com.shared.models.GridManager;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	
	public class BBClosingDetailGridManager  extends GridManager
	{
		[Bindable]
		public var arrClosingMethod:Array = new Array();
		/*................  Constructor  ...................*/
		private var dispatcher:IEventDispatcher;
		public function BBClosingDetailGridManager ( dispatcher:IEventDispatcher )
		{
			super();
			this.dispatcher = dispatcher;
			this.buildGridCols();
			this.buildDgBBDeductionCols();
		}
		/* arrBBClosingDetailDgCols bound to dgBBClosingDetail.columns */
		private var _arrBBClosingDetailDgCols:Array = new Array();
		[Bindable (event="arrBBClosingDetailDgColsChanged")]
		public function get arrBBClosingDetailDgCols():Array
		{
			return _arrBBClosingDetailDgCols;
		}

		/* arrBBDeductionDgCols bound to dgBBDeduction.columns */
		private var _arrBBDeductionDgCols:Array = new Array();
		[Bindable (event="arrBBDeductionDgColsChanged")]
		public function get arrBBDeductionDgCols():Array
		{
			return _arrBBDeductionDgCols;
		}
		
		public function buildGridCols():void
		{
			var col:DataGridColumn;
			//var col:DataGridFilterColumnMultiSelect;
			var colMulti:DataGridFilterColumn;
			/*.....	isSelected	.....................  */
			/*col = new DataGridColumn('isSelected');
			col.dataField = 'isSelected';
			col.editable = true;
			col.sortable = false;
			col.width = 40;
			col.rendererIsEditor=true;
			var cf:ClassFactory = new ClassFactory(chBoxSelectAllDg);
			col.headerRenderer = cf;
			col.itemRenderer = new ClassFactory(chBoxIsSelectedDg);
			col.editorDataField = "varCbSelected";
			_arrBBClosingDetailDgCols.push(col);*/
			
			/*.....	clear icon	.....................  */
			var colClear:DataGridClearColumn;
			colClear = new DataGridClearColumn('');
			colClear.editable = false;
			colClear.sortable = false;
			colClear.width = 30;
			_arrBBClosingDetailDgCols.push(colClear);
			
			/*.....	closingMethod	....................   */
			col = new DataGridColumn("closingMethod");
			col.dataField = "closingMethod.description";
			col.headerText = "Closing Method";
			col.width = 125;
			col.editable = false;
			col.sortable = false;
			//col.labelFunction = labelFunc;
			_arrBBClosingDetailDgCols.push(col);
			/*col.rendererIsEditor=true;
			var cf:ClassFactory = new ClassFactory(closingMethodCombo);
			cf.properties = { cmDp: arr };
			col.itemRenderer = cf;
			col.editorDataField = "closingMethod";*/
			

			/*.....	amount	....................   */
			col = new DataGridColumn("amount");
			col.dataField = "amount";
			col.headerText = "Amount";
			col.width = 75;
			col.editable = true;
			col.sortable = false;
			col.labelFunction = labelFuncTwoDecimal;
			col.showDataTips = true;
			_arrBBClosingDetailDgCols.push(col);
			
			/*.....	deduction	....................   */
			col = new DataGridColumn("deduction.deductionNumber");
			col.dataField = "deduction.deductionNumber";
			col.headerText = "Deduction";
			col.width = 175;
			col.editable = false;
			col.sortable = false;
			col.showDataTips = true;
			col.labelFunction = deductionLabelFunc;;
			_arrBBClosingDetailDgCols.push(col);
			
			/*.....	specialHandling	....................   */
			/*col = new DataGridColumn("specialHandling");
			col.dataField = "specialHandling";
			col.headerText = "special handling";
			col.width = 400;
			col.editable = true;
			_arrBBClosingDetailDgCols.push(col);*/
			
			
			/* Empty col so last row is not huge ....................*/
			col = new DataGridColumn("xSpace");
			col.visible = true;
			col.headerText = '';
			col.width = .99;
			col.editable = false;
			col.visible = true;
			_arrBBClosingDetailDgCols.push(col); 
			dispatchEvent(new Event('arrBBClosingDetailDgColsChanged'));
		}
		
		public function buildDgBBDeductionCols():void
		{
			var col:DataGridColumn;
			//var col:DataGridFilterColumnMultiSelect;
			var colFilter:DataGridFilterColumn;
			
			/*.....	delete icon	.....................  */
			/*var colDelete:DataGridDeleteColumn;
			colDelete = new DataGridDeleteColumn('');
			colDelete.editable = false;
			colDelete.sortable = false;
			colDelete.width = 40;
			_arrBBDeductionDgCols.push(colDelete);*/
			
			/*.....	deduction	....................   */
			colFilter = new DataGridFilterColumn("deduction");
			colFilter.dataField = "deductionNumber";
			colFilter.headerText = "Deduction #";
			colFilter.width = 175;
			colFilter.editable = false;
			_arrBBDeductionDgCols.push(colFilter);
			
			/*.....	Amount	....................   */
			colFilter = new DataGridFilterColumn("amount");
			colFilter.dataField = "amount";
			colFilter.headerText = "Amount";
			colFilter.width = 125;
			colFilter.editable = false;
			colFilter.labelFunction = labelFuncTwoDecimal;
			_arrBBDeductionDgCols.push(colFilter);
			
			/*.....	Customer	....................   */
			/*colFilter = new DataGridFilterColumn("distObj.name");
			colFilter.dataField = "distObj.name";
			colFilter.headerText = "customer";
			colFilter.width = 200;
			colFilter.editable = false;
			colFilter.labelFunction = labelFunc;
			_arrBBDeductionDgCols.push(colFilter);*/
			
			/*.....	Broker	....................   */
			/*colFilter = new DataGridFilterColumn("brokerObj.name");
			colFilter.dataField = "brokerObj.name";
			colFilter.headerText = "broker";
			colFilter.width = 200;
			colFilter.editable = false;
			colFilter.labelFunction = labelFunc;
			_arrBBDeductionDgCols.push(colFilter);*/
			
			/*.....	More Info ....................  */
			col = new DataGridColumn("deductionID");
			col.dataField = "deductionID";
			col.itemRenderer = new ClassFactory(ViewDeductions);
			col.visible = true;
			col.headerText = "";
			col.width = 40;
			col.editable = false;
			col.sortable = false;
			_arrBBDeductionDgCols.push(col);
			
			/* Empty col so last row is not huge ....................*/
			col = new DataGridColumn("xSpace");
			col.visible = true;
			col.headerText = '';
			col.width = .99;
			col.editable = false;
			col.visible = true;
			col.sortable = false;
			_arrBBDeductionDgCols.push(col); 
			dispatchEvent(new Event('arrBBDeductionDgColsChanged'));
		}
		
		public function closingMethodLabelFunc(item:Object, col:DataGridColumn):String{
			var s:String = '';
			if(item.deductionNumber){
				s = item.deductionNumber + '-' + item.spNumber;
			}
			return s;
		}
		
		public function deductionLabelFunc(item:Object, col:DataGridColumn):String{
			var s:String = '';
			if(item.deduction){
				s = item.deduction.deductionNumber;
				if(item.deduction.spNumber.length){
					s = s + '-' + item.deduction.spNumber;
				}
			}
			return s;
		}
	}
}