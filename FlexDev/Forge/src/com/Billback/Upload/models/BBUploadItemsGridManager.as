package com.Billback.Upload.models
{
	import com.Billback.Edit.models.vos.BBToolsLock;
	import com.Billback.Upload.views.renderer.gridLabel;
	import com.shared.components.*;
	import com.shared.components.filters.DataGridDeleteColumn;
	import com.shared.components.filters.DataGridFilterColumn;
	import com.shared.components.filters.DataGridFilterColumnMultiSelect;
	import com.shared.models.GridManager;
	import com.shared.views.renderer.gridCombo;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	
	public class BBUploadItemsGridManager  extends GridManager
	{
		/*................  Constructor  ...................*/
		private var dispatcher:IEventDispatcher;
		public function BBUploadItemsGridManager ( dispatcher:IEventDispatcher )
		{
			super();
			this.dispatcher = dispatcher;
			this.buildGridCols();
		}
		
		/*.......................  Properties  .......................*/
		[Bindable] public var objBBToolsLock:BBToolsLock = new BBToolsLock();
		
		/* arrBBUploadItemsDgCols bound to dgItems.columns */
		private var _arrBBUploadItemsDgCols:Array = new Array();
		[Bindable (event="arrBBUploadItemsDgColsChanged")]
		public function get arrBBUploadItemsDgCols():Array
		{
			return _arrBBUploadItemsDgCols;
		}
	/*	this.itemGuid = bbProdRate.itemGuid;
		this.isSelected = bbProdRate.isSelected;
		this.itemNumber = bbProdRate.itemNumber;
		this.description = bbProdRate.description;
		this.uom = bbProdRate.uom;
		this.rate = bbProdRate.rate;
		this.volume = bbProdRate.volume;*/
		
		public function setGridLockUnlock(lock:Boolean):void
		{
			
			/* Loop though the items grid and set the EDITABLE property of the columns to true OR false */
			for each(var col:DataGridColumn in arrBBUploadItemsDgCols)
			{
				if(col.dataField == 'contractNumber' || col.dataField == 'contractTitle'
					|| col.dataField == 'operatorLegacyId' || col.dataField == 'item' || col.dataField == 'dupShipTo'
				)
				{					
					col.editable = lock;	
				}
			}
			
			/* Loop though the items grid and set the VISIBLE property of the columns to true OR false */
			for each(var colOther:DataGridColumn in arrBBUploadItemsDgCols)
			{
				if(colOther.dataField == 'isSelected' || colOther.dataField == 'del') 
				{			
					colOther.visible = lock;
				}
			}
			
			//dispatchEvent(new Event('arrBBEditItemsDgColsChanged'));
		}

		public function buildGridCols():void
		{
			var col:DataGridColumn;
			//var colMulti:DataGridFilterColumnMultiSelect;
			var colMulti:DataGridFilterColumn;
			/* id field not displayed helps the sort if data is simialr ....................*/
			col = new DataGridColumn("rowID"); // bbDetailID
			col.dataField = 'rowID'; // bbDetailID
			col.visible = true;
			col.headerText = 'row ID';
			col.width = 50; // 50
			col.editable = false;
			col.visible = true;
			_arrBBUploadItemsDgCols.push(col); 
			/*.....	isSelected	.....................  */
			col = new DataGridColumn('isSelected');
			col.dataField = 'isSelected';
			col.editable = true;
			col.sortable = false;
			col.width = 40; // 40
			col.rendererIsEditor=true;
			var cf:ClassFactory = new ClassFactory(chBoxSelectAllDg);
			col.headerRenderer = cf;
			col.itemRenderer = new ClassFactory(chBoxIsSelectedDg);
			col.editorDataField = "varCbSelected";
			//col.itemEditor = new ClassFactory(chBoxIsSelectedSpark);
			//col.rendererIsEditable = true;
			_arrBBUploadItemsDgCols.push(col);

			/*.....	delete icon	.....................  */
			var colDelete:DataGridDeleteColumn;
			colDelete = new DataGridDeleteColumn('del');
			colDelete.editable = false;
			colDelete.sortable = false;
			colDelete.width = 40; //40 
			_arrBBUploadItemsDgCols.push(colDelete);
			
			/*.....	customer	....................   */
			colMulti = new DataGridFilterColumn("dupShipTo");
			colMulti.dataField = "dupShipTo";
			colMulti.headerText = "(A) SAP Dist Num";
			colMulti.width = 80; // 150
			colMulti.editable = true;
			colMulti.itemRenderer = new ClassFactory(gridLabel);
			_arrBBUploadItemsDgCols.push(colMulti);
			
			/*.....	custNumber	....................   */
			colMulti = new DataGridFilterColumn("custNumber");
			colMulti.dataField = "custNumber";
			colMulti.headerText = "(B) Cust Dist Code";
			colMulti.width = 56; // 160
			colMulti.editable = false;
			colMulti.itemRenderer = new ClassFactory(gridLabel);
			_arrBBUploadItemsDgCols.push(colMulti);
			
			/*.....	custName	....................   */
			colMulti = new DataGridFilterColumn("custName");
			colMulti.dataField = "custName";
			colMulti.headerText = "(C) Cust Dist Name";
			colMulti.width = 80; // 190
			colMulti.editable = false;
			colMulti.itemRenderer = new ClassFactory(gridLabel);
			//colMulti.editVisible = true;
			_arrBBUploadItemsDgCols.push(colMulti);
			
			
			/*.....	custContractNumber	....................   */
			colMulti = new DataGridFilterColumn("custContractNumber");
			colMulti.dataField = "custContractNumber";
			colMulti.headerText = "(D) Cust Promo Code";
			//col.labelFunction = formatDollar;//comes from extends GridManager in shared.models
			colMulti.width = 80; // 150
			colMulti.editable = false;
			colMulti.itemRenderer = new ClassFactory(gridLabel);
			_arrBBUploadItemsDgCols.push(colMulti);
			
			/*.....	custContractDescription	....................   */
			colMulti = new DataGridFilterColumn("custContractDescription");
			colMulti.dataField = "custContractDescription";
			colMulti.headerText = "(E) Cust Promo Desc";
			colMulti.width = 150; // 190
			colMulti.editable = false;
			colMulti.itemRenderer = new ClassFactory(gridLabel);
			_arrBBUploadItemsDgCols.push(colMulti);
			
			/*.....	contractNumber	....................   */
			colMulti = new DataGridFilterColumn("contractNumber");
			colMulti.dataField = "contractNumber";
			colMulti.headerText = "(F) GMI Program #";
			colMulti.width = 80; // 150
			colMulti.editable = true;
			colMulti.itemRenderer = new ClassFactory(gridLabel);
			_arrBBUploadItemsDgCols.push(colMulti);
			
			/*.....	contractTitle	....................   */
			/*	colMulti = new DataGridFilterColumn("contractTitle");
				colMulti.dataField = "contractTitle";
				colMulti.headerText = "(G) GMI Promo #";
				colMulti.width = 140;
				colMulti.editable = true;
				colMulti.itemRenderer = new ClassFactory(gridLabel);
				_arrBBUploadItemsDgCols.push(colMulti);
			*/
			
			/*.....	operatorLegacyId	....................   */
			colMulti = new DataGridFilterColumn("operatorLegacyId");
			colMulti.dataField = "operatorLegacyId";
			colMulti.headerText = "(G) SAP Promoted Cust";
			colMulti.width = 80; // 160
			colMulti.editable = true;
			colMulti.itemRenderer = new ClassFactory(gridLabel);
			_arrBBUploadItemsDgCols.push(colMulti);
			
			/*.........  Customer GMI Product Code ...............*/
	
			/*.....	item	....................   */
			colMulti = new DataGridFilterColumn("item");
			colMulti.dataField = "item";
			colMulti.headerText = "(H) Base Product Code";
			colMulti.width = 80; // 160
			colMulti.editable = true;
			colMulti.itemRenderer = new ClassFactory(gridLabel);
			_arrBBUploadItemsDgCols.push(colMulti);
			
			/*.....	custItem	....................   Customer GMI Product Code, Base Product Code, Cust Product Code, Cust Product Desc */
			colMulti = new DataGridFilterColumn("custItem");
			colMulti.dataField = "custItem";
			colMulti.headerText = "(I) Cust Provided Product Code";
			colMulti.width = 80; // 215
			colMulti.editable = false;
			colMulti.itemRenderer = new ClassFactory(gridLabel);
			_arrBBUploadItemsDgCols.push(colMulti);
			
			/*.....	custItemDescription	....................   */
			colMulti = new DataGridFilterColumn("custItemDescription");
			colMulti.dataField = "custItemDescription";
			colMulti.headerText = "(J) Cust Product Desc";
			colMulti.width = 165; // 165
			colMulti.editable = false;
			colMulti.itemRenderer = new ClassFactory(gridLabel);
			_arrBBUploadItemsDgCols.push(colMulti);
			
			/*.....	BBProductQuantity	....................   */
			colMulti = new DataGridFilterColumn("BBProductQuantity");
			colMulti.dataField = "BBProductQuantity";
			colMulti.headerText = "(K) Quantity";
			colMulti.labelFunction = StringUtils.dgFormatDecimal2;
			colMulti.width = 70; // 100
			colMulti.editable = false;
			colMulti.itemRenderer = new ClassFactory(gridLabel);
			//colMulti.labelFunction = errLabelFunc;
			_arrBBUploadItemsDgCols.push(colMulti);
			
			/*.....	caseRate	....................   */
			colMulti = new DataGridFilterColumn("caseRate");
			colMulti.dataField = "caseRate";
			colMulti.headerText = "(L) Case Rate";
			//col.labelFunction = formatDollar;//comes from extends GridManager in shared.models
			colMulti.width = 70; // 115
			colMulti.editable = false;
			colMulti.itemRenderer = new ClassFactory(gridLabel);
			_arrBBUploadItemsDgCols.push(colMulti);
			
			/*.....	BBRate	....................   */
			colMulti = new DataGridFilterColumn("BBRate");
			colMulti.dataField = "BBRate";
			colMulti.headerText = "(M) Payment Amount";
			colMulti.labelFunction = StringUtils.dgFormatDecimal2;
			colMulti.width = 70; // 140 
			colMulti.editable = false;
			colMulti.itemRenderer = new ClassFactory(gridLabel);
			_arrBBUploadItemsDgCols.push(colMulti);
			
			/*.....	operatorId	....................   */
			colMulti = new DataGridFilterColumn("operatorId");
			colMulti.dataField = "operatorId";
			colMulti.headerText = "(N) Operator Id";
			colMulti.width = 80; // 150
			colMulti.editable = false;
			_arrBBUploadItemsDgCols.push(colMulti);
			
			/*.....	operatorName	....................   */
			colMulti = new DataGridFilterColumn("operatorName");
			colMulti.dataField = "operatorName";
			colMulti.headerText = "(O) Operator Name";
			colMulti.width = 80; // 150
			colMulti.editable = false;
			colMulti.itemRenderer = new ClassFactory(gridLabel);
			_arrBBUploadItemsDgCols.push(colMulti);
			
			/*.....	operatorAddress1	....................   */
			colMulti = new DataGridFilterColumn("operatorAddress1");
			colMulti.dataField = "operatorAddress1";
			colMulti.headerText = "(P) Operator Address1";
			colMulti.width = 80; // 155 
			colMulti.editable = false;
			colMulti.itemRenderer = new ClassFactory(gridLabel);
			_arrBBUploadItemsDgCols.push(colMulti);
			
			/*.....	operatorCity	....................   */
			colMulti = new DataGridFilterColumn("operatorCity");
			colMulti.dataField = "operatorCity";
			colMulti.headerText = "(Q) Operator City";
			colMulti.width = 80; // 140
			colMulti.editable = false;
			colMulti.itemRenderer = new ClassFactory(gridLabel);
			_arrBBUploadItemsDgCols.push(colMulti);
			
			/*.....	operatorState	....................   */
			colMulti = new DataGridFilterColumn("operatorState");
			colMulti.dataField = "operatorState";
			colMulti.headerText = "(R) Operator State";
			colMulti.width = 80; // 140
			colMulti.editable = false;
			colMulti.itemRenderer = new ClassFactory(gridLabel);
			_arrBBUploadItemsDgCols.push(colMulti);
			
			/*.....	operatorZip	....................   */
			colMulti = new DataGridFilterColumn("operatorZip");
			colMulti.dataField = "operatorZip";
			colMulti.headerText = "(S) Operator Zip";
			colMulti.width = 80; // 140
			colMulti.editable = false;
			colMulti.itemRenderer = new ClassFactory(gridLabel);
			_arrBBUploadItemsDgCols.push(colMulti);
			
			/*.....	Discount_Type	....................   */
			colMulti = new DataGridFilterColumn("DiscountType");
			colMulti.dataField = "DiscountType";
			colMulti.headerText = "(T) Discount Type";
			colMulti.width = 80; // 140
			colMulti.editable = false;
			colMulti.itemRenderer = new ClassFactory(gridLabel);
			_arrBBUploadItemsDgCols.push(colMulti);
			
			/* Empty col so last row is not huge ....................*/
			col = new DataGridColumn("xSpace");
			col.visible = true;
			col.headerText = '';
			col.width = .99;
			col.editable = false;
			col.visible = true;
			_arrBBUploadItemsDgCols.push(col); 
			dispatchEvent(new Event('arrBBUploadItemsDgColsChanged'));
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