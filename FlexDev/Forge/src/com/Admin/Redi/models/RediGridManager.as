package com.Admin.Redi.models
{
	import com.shared.components.chBoxIsSelected;
	import com.shared.components.chBoxSelectAll;
	import com.shared.components.filters.AdvancedDataGridFilterColumn;
	import com.shared.components.filters.DataGridFilterColumn;
	import com.shared.models.GridManager;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.controls.AdvancedDataGrid;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.ClassFactory;
	
	import spark.globalization.SortingCollator;

	
	public class RediGridManager  extends GridManager
	{
		[Bindable]
		public var dgRediHistory:AdvancedDataGrid;
		[Bindable]
		public var dgRediOpen:AdvancedDataGrid;
		/*................  Constructor  ...................*/
		private var dispatcher:IEventDispatcher;
		public function RediGridManager ( dispatcher:IEventDispatcher )
		{
			super();
			this.dispatcher = dispatcher;
			this.buildOpenGridCols();
			this.buildHistoryGridCols();
		}
		[Bindable]
		private var custLabel:String = 'Customer';
		private var _oSettings:Settings = new Settings();
		[Bindable (event="pmsettingsChanged")]
		override public function get oSettings():Settings
		{
			return _oSettings;
		}
		override public function set oSettings(s:Settings):void
		{
			this._oSettings = s;
			//updateGridColsHeaderText();
			dispatchEvent(new Event('pmsettingsChanged'));
			
			for each(var c:* in this._arrRediOpenDgCols){
				c = c as AdvancedDataGridFilterColumn;
				if(c){
					custLabel = this.oSettings.appSettings.Distributor_Label_Singular;
					switch(c.dataField){
						case 'originalCustomer' :
							switch(c.dataFieldComplex){
								case 'originalCustomer.aliasName' :
									trace("originalCustomer.aliasName");
									c.headerText = this.oSettings.appSettings.Original_Buyer_Label + ' Name';
									break;
								case 'originalCustomer.aliasShipTo' :
									c.headerText = this.oSettings.appSettings.Original_Buyer_Label + ' ' + this.oSettings.appSettings.Shard_Ship_To_Label;
									trace("originalCustomer.aliasShipto");
									break;
								default:
									trace("rename not found inside");
									break;
							}
							break;
						case 'finalCustomer' :
							switch(c.dataFieldComplex){
								case 'finalCustomer.aliasName' :
									trace("finalCustomer.aliasName");
									c.headerText = this.oSettings.appSettings.Final_Buyer_Label + ' Name';
									break;
								case 'finalCustomer.aliasShipTo' :
									trace("finalCustomer.aliasShipTo");
									c.headerText = this.oSettings.appSettings.Final_Buyer_Label + ' ' + this.oSettings.appSettings.Shard_Ship_To_Label;
									break;
								default:
									trace("rename not found inside");
									break;
							}
							break;
						case 'tradePartId' :
							c.headerText = this.oSettings.appSettings.Original_Buyer_Label + ' Id';
							trace("tradePart");
							break;
						default:
							trace("rename not found");
							break;
					}
				}
			}
			
			/*for each(var c:* in this._arrRediHistoryDgCols){
				c = c as AdvancedDataGridFilterColumn;
				if(c){
					custLabel = this.oSettings.appSettings.Distributor_Label_Singular;
					switch(c.dataField){
						case 'tradePartId' :
							c.headerText = this.oSettings.appSettings.Original_Buyer_Label + ' Id';
						default:
							trace("rename not found");
							break;
					}
				}
			}*/
		}
		
		/* arrRediOpenDgCols bound to dgRediOpen.columns */
		private var _arrRediOpenDgCols:Array = new Array();
		[Bindable (event="arrRediOpenDgColsChanged")]
		public function get arrRediOpenDgCols():Array
		{
			return _arrRediOpenDgCols;
		}
		/* arrRediHistoryDgCols bound to dgRediHistorycolumns */
		private var _arrRediHistoryDgCols:Array = new Array();
		[Bindable (event="arrRediHistoryDgColsChanged")]
		public function get arrRediHistoryDgCols():Array
		{
			return _arrRediHistoryDgCols;
		}
		
		private var _arrRediEditDgCols:Array = new Array();
		[Bindable (event="arrRediEditDgColsChanged")]
		public function get arrRediEditDgCols():Array
		{
			return _arrRediEditDgCols;
		}

		public function buildOpenGridCols():void
		{
			var col:AdvancedDataGridFilterColumn;
			var colPlain:AdvancedDataGridColumn;
			/*.....	isSelected	.....................  */
			col = new AdvancedDataGridFilterColumn('isSelected');
			col.dataField = 'isSelected';
			col.editable = true;
			col.sortable = false;
			col.width = 40;
			col.rendererIsEditor=true;
			col.headerRenderer = new ClassFactory(chBoxSelectAll);
			col.itemRenderer = new ClassFactory(chBoxIsSelected);
			col.editorDataField = "varCbSelected";
			//col.itemEditor = new ClassFactory(chBoxIsSelectedSpark);
			//col.rendererIsEditable = true;
			_arrRediOpenDgCols.push(col);
			//Distributor_Label_Singular
			col = new AdvancedDataGridFilterColumn("uploadId");
			col.dataField = "uploadId";
			col.headerText = "Upload Id";
			col.width = 70 ;
			col.editable = false;
			_arrRediOpenDgCols.push(col);
			/*.....	tradePartId	....................   */
			col = new AdvancedDataGridFilterColumn("sourceTypeDesc");
			col.dataField = "sourceType";
			col.headerText = "Source#";
			col.width = 100;
			col.editable = false;
			col.filterComboVisible = true;
			_arrRediOpenDgCols.push(col);
			/*.....	tradePartId	....................   */
			col = new AdvancedDataGridFilterColumn("sourceTypeDesc");
			col.dataField = "sourceTypeDesc";
			col.headerText = "Source";
			col.width = 100;
			col.editable = false;
			col.filterComboVisible = true;
			_arrRediOpenDgCols.push(col);
			/*.....	invoiceNumber	....................   */
			col = new AdvancedDataGridFilterColumn("invoiceNumber");
			col.dataField = "invoiceNumber";
			col.headerText = "Invoice #";
			col.width = 100;
			col.editable = false;
			_arrRediOpenDgCols.push(col);
			/*.....	invoiceDate	....................   */
			colPlain = new AdvancedDataGridColumn("invoiceDate");
			colPlain.dataField = "invoiceDate";
			colPlain.headerText = "Inv. Date";
			colPlain.labelFunction = this.formatDt;
			colPlain.width = 100;
			colPlain.editable = false;
			_arrRediOpenDgCols.push(colPlain);
			/*.....	Customer_Name	....................   */
			col = new AdvancedDataGridFilterColumn("originalCustomer");
			col.dataField = "originalCustomer";
			col.labelFunction = custNameLabelFunc;
			col.headerText = this.oSettings.appSettings.Original_Buyer_Label + ' Name';
			col.dataFieldComplex = 'originalCustomer.aliasName';
			col.sortCompareFunction = this.sortCompareNameOrig;
			col.width = 125;
			col.editable = false;
			_arrRediOpenDgCols.push(col);
			/*.....	Customer Number	....................   */
			col = new AdvancedDataGridFilterColumn("originalCustomer");
			col.dataField = "originalCustomer";
			col.headerText = this.oSettings.appSettings.Original_Buyer_Label + ' ' + this.oSettings.appSettings.Shard_Ship_To_Label;
			col.labelFunction = custNumberLabelFunc;
			col.dataFieldComplex = 'originalCustomer.aliasShipTo';
			col.sortCompareFunction = this.sortCompareNumberOrig;
			col.width = 100;
			col.editable = false;
			_arrRediOpenDgCols.push(col);
			/*.....	Customer_Name	....................   */
			col = new AdvancedDataGridFilterColumn("finalCustomer");
			col.dataField = "finalCustomer";
			col.labelFunction = custNameLabelFunc;
			col.headerText = this.oSettings.appSettings.Final_Buyer_Label + ' Name';
			col.dataFieldComplex = 'finalCustomer.aliasName';
			col.sortCompareFunction = this.sortCompareNameFinal;
			col.width = 125;
			col.editable = false;
			_arrRediOpenDgCols.push(col);
			/*.....	Customer Number	....................   */
			col = new AdvancedDataGridFilterColumn("finalCustomer");
			col.dataField = "finalCustomer";
			col.headerText = this.oSettings.appSettings.Final_Buyer_Label + ' ' + this.oSettings.appSettings.Shard_Ship_To_Label;
			col.labelFunction = custNumberLabelFunc;
			col.dataFieldComplex = 'finalCustomer.aliasShipTo';
			col.sortCompareFunction = this.sortCompareNumberFinal;
			col.width = 100;
			col.editable = false;
			_arrRediOpenDgCols.push(col);
			/*.....	poNum	....................   */
			col = new AdvancedDataGridFilterColumn("poNum");
			col.dataField = "poNum";
			col.headerText = "PO #";
			col.width = 75;
			col.editable = false;
			_arrRediOpenDgCols.push(col);
			/*.....	InvCases	....................   */
			colPlain = new AdvancedDataGridColumn("InvCases");
			colPlain.dataField = "InvCases";
			colPlain.headerText = "Total CS";
			colPlain.width = 50;
			colPlain.editable = false;
			_arrRediOpenDgCols.push(colPlain);
			/*.....	InvDollars	....................   */
			colPlain = new AdvancedDataGridColumn("InvDollars");
			colPlain.dataField = "InvDollars";
			colPlain.headerText = "Total $";
			colPlain.formatter = this._dlrFormatter;
			colPlain.setStyle('textAlign','right');
			colPlain.width = 75;
			colPlain.editable = false;
			_arrRediOpenDgCols.push(colPlain);
			/*.....	errormessage	....................   */
			col = new AdvancedDataGridFilterColumn("errorMessage");
			col.dataField = "errorMessage";
			col.headerText = "Message";
			col.width = 150;
			col.editable = false;
			_arrRediOpenDgCols.push(col);
			/*.....	End	....................   */
			/* Empty col so last row is not huge ....................*/
			colPlain = new AdvancedDataGridColumn("xSpace");
			colPlain.visible = true;
			colPlain.headerText = '';
			colPlain.width = .99;
			colPlain.editable = false;
			colPlain.visible = true;
			_arrRediOpenDgCols.push(colPlain); 
			dispatchEvent(new Event('arrRediOpenDgColsChanged'));
		}
		
		public function buildHistoryGridCols():void
		{
			var col:AdvancedDataGridFilterColumn;
			var colPlain:AdvancedDataGridColumn;
			/*.....	isSelected	.....................  */
			/*col = new AdvancedDataGridFilterColumn('isSelected');
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
			//_arrRediHistoryDgCols.push(col);    */
			/*.....	sourceType	....................   */
			col = new AdvancedDataGridFilterColumn("uploadId");
			col.dataField = "uploadId";
			col.headerText = "Upload Id";
			col.width = 70 ;
			col.editable = false;
			_arrRediHistoryDgCols.push(col);
			/*.....	sourceType	....................   */
			col = new AdvancedDataGridFilterColumn("sourceType");
			col.dataField = "sourceType";
			col.headerText = "Partner Id";
			col.width = 100;
			col.editable = false;
			col.filterComboVisible = true;
			_arrRediHistoryDgCols.push(col);
			/*.....	Report_Id	....................   */
			col = new AdvancedDataGridFilterColumn("sourceTypeDesc");
			col.dataField = "sourceTypeDesc";
			col.headerText = "Partner Name";
			col.width = 100;
			col.editable = false;
			col.filterComboVisible = true;
			_arrRediHistoryDgCols.push(col);
			/*.....	invoiceNumber	....................   */
			/*col = new AdvancedDataGridFilterColumn("invoiceNumber");
			col.dataField = "invoiceNumber";
			col.headerText = "Invoice #";
			col.width = 100;
			col.editable = false;
			_arrRediHistoryDgCols.push(col);*/
			/*.....	invoiceDate	....................   */
			/*colPlain = new AdvancedDataGridColumn("invoiceDate");
			colPlain.dataField = "invoiceDate";
			colPlain.headerText = "Inv. Date";
			colPlain.width = 100;
			colPlain.editable = false;
			_arrRediHistoryDgCols.push(colPlain);*/
			/*.....	headerCount	....................   */
			colPlain = new AdvancedDataGridColumn("headerCount");
			colPlain.dataField = "headerCount";
			colPlain.headerText = "Header Count";
			colPlain.width = 75;
			colPlain.headerWordWrap = true;
			colPlain.editable = false;
			_arrRediHistoryDgCols.push(colPlain);
			/*.....	headerFailed	....................   */
			colPlain = new AdvancedDataGridColumn("headerFailed");
			colPlain.dataField = "headerFailed";
			colPlain.headerText = "Header Failed";
			colPlain.width = 75;
			colPlain.headerWordWrap = true;
			colPlain.editable = false;
			_arrRediHistoryDgCols.push(colPlain);
			/*.....	headerLoaded	....................   */
			colPlain = new AdvancedDataGridColumn("headerLoaded");
			colPlain.dataField = "headerLoaded";
			colPlain.headerText = "Header Loaded";
			colPlain.width = 75;
			colPlain.editable = false;
			_arrRediHistoryDgCols.push(colPlain);
			/*.....	detailCount	....................   */
			colPlain = new AdvancedDataGridColumn("detailCount");
			colPlain.dataField = "detailCount";
			colPlain.headerText = "Detail Count";
			colPlain.width = 65;
			colPlain.headerWordWrap = true;
			colPlain.editable = false;
			_arrRediHistoryDgCols.push(colPlain);
			/*.....	detailFailed	....................   */
			colPlain = new AdvancedDataGridColumn("detailFailed");
			colPlain.dataField = "detailFailed";
			colPlain.headerText = "Detail Failed";
			colPlain.width = 65;
			colPlain.headerWordWrap = true;
			colPlain.editable = false;
			_arrRediHistoryDgCols.push(colPlain);
			/*.....	detailLoaded	....................   */
			colPlain = new AdvancedDataGridColumn("detailLoaded");
			colPlain.dataField = "detailLoaded";
			colPlain.headerText = "Detail Loaded";
			colPlain.width = 65;
			colPlain.headerWordWrap = true;
			colPlain.editable = false;
			_arrRediHistoryDgCols.push(colPlain);
			/*.....	invoiceNumber	....................   */
			col = new AdvancedDataGridFilterColumn("fileName");
			col.dataField = "fileName";
			col.headerText = "File Name";
			col.width = 100;
			col.editable = false;
			_arrRediHistoryDgCols.push(col);
			/*.....	date	....................   */
			col = new AdvancedDataGridFilterColumn("runDate");
			col.dataField = "runDate";
			col.headerText = "Date";
			col.width = 100;
			col.editable = false;
			col.labelFunction = this.formatDt;
			_arrRediHistoryDgCols.push(col);
			/*.....	End	....................   */
			/* Empty col so last row is not huge ....................*/
			colPlain = new AdvancedDataGridColumn("xSpace");
			colPlain.visible = true;
			colPlain.headerText = '';
			colPlain.width = .99;
			colPlain.editable = false;
			colPlain.visible = true;
			_arrRediHistoryDgCols.push(colPlain); 
			dispatchEvent(new Event('arrRediHistoryDgColsChanged'));
		}
		
		public function uomLabelFunc(item:Object, col:DataGridFilterColumn):String{
			return item.uom.abbreviation;
		}
		public function custNameLabelFunc(item:Object, column:AdvancedDataGridColumn):String 
		{
			var s:String = ''
			if(item[column.dataField]){ 
				s = item[column.dataField].aliasName;
			}
			
			return s;
		}
		private var collator:SortingCollator = new SortingCollator();
		public function custNumberLabelFunc(item:Object, column:AdvancedDataGridColumn):String 
		{
			var s:String = ''
			if(item[column.dataField]){ 
				s=  item[column.dataField].aliasShipTo;
			}
			return s;
		}
		public function sortCompareNameOrig(obj1:Object, obj2:Object):int { 
			collator.ignoreCase = true;
			return collator.compare(obj1['originalCustomer'].aliasName, obj2['originalCustomer'].aliasName);
		}
		public function sortCompareNumberOrig(obj1:Object, obj2:Object):int { 
			collator.ignoreCase = true;
			return collator.compare(obj1['originalCustomer'].aliasShipTo, obj2['originalCustomer'].aliasShipTo);
		}
		
		public function sortCompareNameFinal(obj1:Object, obj2:Object):int { 
			collator.ignoreCase = true;
			return collator.compare(obj1['finalCustomer'].aliasName, obj2['finalCustomer'].aliasName);
		}
		public function sortCompareNumberFinal(obj1:Object, obj2:Object):int { 
			collator.ignoreCase = true;
			return collator.compare(obj1['finalCustomer'].aliasShipTo, obj2['finalCustomer'].aliasShipTo);
		}
		
	}
}