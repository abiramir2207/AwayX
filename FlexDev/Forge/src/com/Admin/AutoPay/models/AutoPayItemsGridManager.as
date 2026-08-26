package com.Admin.AutoPay.models
{
	import com.shared.components.*;
	import com.shared.components.filters.DataGridFilterColumn;
	import com.shared.models.GridManager;
	import com.shared.views.renderer.gridCombo;
	import com.shared.components.StringUtils;
	import com.Admin.AutoPay.views.renderer.program_summary;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	
	public class AutoPayItemsGridManager  extends GridManager
	{
		/*................  Constructor  ...................*/
		private var dispatcher:IEventDispatcher;
		public function AutoPayItemsGridManager ( dispatcher:IEventDispatcher )
		{
			super();
			this.dispatcher = dispatcher;
			this.buildGridCols();
		}
		/* arrAutoPayItemsDgCols bound to dgItems.columns */
		private var _arrAutoPayItemsDgCols:Array = new Array();
		[Bindable (event="arrAutoPayItemsDgColsChanged")]
		public function get arrAutoPayItemsDgCols():Array
		{
			return _arrAutoPayItemsDgCols;
		}
	/*	this.itemGuid = bbProdRate.itemGuid;
		this.isSelected = bbProdRate.isSelected;
		this.itemNumber = bbProdRate.itemNumber;
		this.description = bbProdRate.description;
		this.uom = bbProdRate.uom;
		this.rate = bbProdRate.rate;
		this.volume = bbProdRate.volume;*/

		public function buildGridCols():void
		{
			var col:DataGridFilterColumn;
			var colPlain:DataGridColumn;
			/*.....	isSelected	.....................  */
			/*col = new DataGridFilterColumn('isSelected');
			col.dataField = 'isSelected';
			col.editable = true;
			col.sortable = false;
			col.width = 40;
			col.rendererIsEditor=true;
			col.headerRenderer = new ClassFactory(chBoxSelectAll);
			col.itemRenderer = new ClassFactory(chBoxIsSelected);
			col.editorDataField = "varCbSelected";*/
			//col.itemEditor = new ClassFactory(chBoxIsSelectedSpark);
			//col.rendererIsEditable = true;
			//_arrAutoPayItemsDgCols.push(col);
			
		/*	reportId|reportStatus|Billback_id|bbCode|bbTitle|bbAmount|startDate|endDate|updDate|firstName|lastName|contractTitle|contractNumber|contractId|payeeName|payeeId     */
			/*.....	Report_Id	....................   */
			col = new DataGridFilterColumn("reportId");
			col.dataField = "reportId";
			col.headerText = "Rpt Id";
			col.width = 50;
			col.editable = false;
			_arrAutoPayItemsDgCols.push(col);
			/*.....	Status	....................   */
			col = new DataGridFilterColumn("reportStatus");
			col.dataField = "reportStatus.description";
			col.headerText = "Status";
			//col.labelFunction = formatDollar;//comes from extends GridManager in shared.models
			col.width = 60;
			col.editable = false;
			_arrAutoPayItemsDgCols.push(col);
			/*.....	Start	....................   */
			colPlain = new DataGridColumn("startDate");
			colPlain.dataField = "startDate";
			colPlain.headerText = "Start";
			colPlain.labelFunction = this.formatDtDg;
			colPlain.width = 75;
			colPlain.editable = false;
			_arrAutoPayItemsDgCols.push(colPlain);
			/*.....	End	....................   */
			colPlain = new DataGridColumn("endDate");
			colPlain.dataField = "endDate";
			colPlain.headerText = "End";
			colPlain.labelFunction = this.formatDtDg;
			colPlain.width = 75;
			colPlain.editable = false;
			_arrAutoPayItemsDgCols.push(colPlain);
			/*.....	Program	....................   */
			col = new DataGridFilterColumn("contractNumber");
			col.dataField = "contractNumber";
			col.headerText = "Program";
			col.width = 95;
			col.editable = false;
			col.itemRenderer = new ClassFactory(com.Admin.AutoPay.views.renderer.program_summary);
			_arrAutoPayItemsDgCols.push(col);
			/*.....	compName	....................   */
			col = new DataGridFilterColumn("compName");
			col.dataField = "compName";
			col.headerText = "Component";
			col.width = 150;
			col.editable = false;
			_arrAutoPayItemsDgCols.push(col);
			/*.....	payeeName	....................   */
			col = new DataGridFilterColumn("payeeName");
			col.dataField = "payeeName";
			col.headerText = "Payee ID/Name";
			col.width = 150;
			col.editable = false;
			_arrAutoPayItemsDgCols.push(col);
			
			/*.....	payeeId	....................   */
			/*col = new DataGridFilterColumn("payeeId");
			col.dataField = "payeeId";
			col.headerText = "Payee Id";
			col.width = 70;
			col.editable = false;
			_arrAutoPayItemsDgCols.push(col);*/
			/*.....	Billback	....................   */
			col = new DataGridFilterColumn("bbCode");
			col.dataField = "bbCode";
			col.headerText = "Billback";
			col.width = 112;
			col.editable = false;
			col.itemRenderer = new ClassFactory(com.Admin.AutoPay.views.renderer.Billback_Summary);
			_arrAutoPayItemsDgCols.push(col);
			/*.....	bbAmount	....................   */
			col = new DataGridFilterColumn("bbAmount");
			col.dataField = "bbAmount";
			col.headerText = "BB Amt";
			col.labelFunction = StringUtils.dgFormatDollarDec2;
			col.width = 65;
			col.setStyle("textAlign","right");
			col.editable = false;
			_arrAutoPayItemsDgCols.push(col);
			/*.....	pullbackAmount	....................   */
			col = new DataGridFilterColumn("pullbackAmount");
			col.dataField = "pullbackAmount";
			col.headerText = "Recapture Amt";
			col.labelFunction = StringUtils.dgFormatDollarDec2;
			col.width = 65;
			col.setStyle("textAlign","right");
			col.editable = false;
			_arrAutoPayItemsDgCols.push(col);
			/*.....	deviationAmount	....................   */
			col = new DataGridFilterColumn("deviationAmount");
			col.dataField = "deviationAmount";
			col.headerText = "Deviation Amt";
			col.labelFunction = StringUtils.dgFormatDollarDec2;
			col.width = 65;
			col.setStyle("textAlign","right");
			col.editable = false;
			_arrAutoPayItemsDgCols.push(col);
			/*.....	User	....................   */
			col = new DataGridFilterColumn("lastName");
			col.dataField = "lastName";
			col.headerText = "User";
			col.width = 80;
			col.editable = false;
			_arrAutoPayItemsDgCols.push(col);
			/*.....	Updated	....................   */
			col = new DataGridFilterColumn("updDate");
			col.dataField = "updDate";
			col.headerText = "Updated";
			col.labelFunction = this.formatDtDg;
			col.width = 75;
			col.editable = false;
			_arrAutoPayItemsDgCols.push(col);
			/* Empty col so last row is not huge ....................*/
		/*	colPlain = new DataGridColumn("xSpace");
			colPlain.visible = true;
			colPlain.headerText = '';
			colPlain.width = .01;
			colPlain.editable = false;
			colPlain.visible = true;
			_arrAutoPayItemsDgCols.push(colPlain); 
			dispatchEvent(new Event('arrAutoPayItemsDgColsChanged'));*/
		}
		
		public function uomLabelFunc(item:Object, col:DataGridFilterColumn):String{
			return item.uom.abbreviation;
		}
	}
}