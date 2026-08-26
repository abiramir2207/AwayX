package com.Admin.Redi.models
{
	import com.Admin.Redi.views.renderer.itemSearch;
	import com.shared.components.chBoxIsSelected;
	import com.shared.components.chBoxSelectAll;
	import com.shared.components.filters.AdvancedDataGridFilterColumn;
	import com.shared.components.filters.DataGridFilterColumn;
	import com.shared.models.GridManager;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.core.ClassFactory;

	
	public class RediEditGridManager  extends GridManager
	{
		/*................  Constructor  ...................*/
		private var dispatcher:IEventDispatcher;
		public function RediEditGridManager ( dispatcher:IEventDispatcher )
		{
			super();
			this.dispatcher = dispatcher;
			this.buildEditGridCols();
		}
		/* arrRediEditDgCols bound to dgRediOpen.columns */
		private var _arrRediEditDgCols:Array = new Array();
		[Bindable (event="arrRediEditDgColsChanged")]
		public function get arrRediEditDgCols():Array
		{
			return _arrRediEditDgCols;
		}
		
		[Bindable]
		private var custLabel:String = 'Customer';
		
		private var _oSettings:Settings = new Settings();
		[Bindable (event="reGridMansettingsChanged")]
		override public function get oSettings():Settings
		{
			return _oSettings;
		}
		override public function set oSettings(s:Settings):void
		{
			this._oSettings = s;
			//updateGridColsHeaderText();
			dispatchEvent(new Event('reGridMansettingsChanged'));
			for each(var c:* in this.arrRediEditDgCols){
				c = c as AdvancedDataGridFilterColumn;
				if(c && this.oSettings.appSettings.hasOwnProperty('Distributor_Label_Singular')){
					custLabel = this.oSettings.appSettings.Distributor_Label_Singular;
					switch(c.dataField){
						case 'tradePartCust' :
							if(c.dataFieldComplex == 'name'){
								c.headerText = custLabel + ' Name';
							}
							else if(c.dataFieldComplex == 'shipTo'){
								c.headerText = custLabel + ' #';
							}
							break;
						case 'tradePartId' :
							c.headerText = this.oSettings.appSettings.Original_Buyer_Label + ' Id';
							break;
						default:
							//trace("Out of range");
							break;
					}
				}
			}
		}

		public function buildEditGridCols():void
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
			//col.editorDataField = "varCbSelected";
			//col.itemEditor = new ClassFactory(chBoxIsSelectedSpark);
			//col.rendererIsEditable = true;
			//_arrRediOpenDgCols.push(col);    */
			/*.....	tradePartId	....................   
			this.item = rediCorrectionDetail.item;
			this.itemDesc = rediCorrectionDetail.itemDesc;
			this.itemPackSize = rediCorrectionDetail.itemPackSize;
			this.aliasItem = rediCorrectionDetail.aliasItem;
			this.aliasItemDesc = rediCorrectionDetail.aliasItemDesc;
			this.aliasItemPackSize = rediCorrectionDetail.aliasItemPackSize;
			this.invoiceCases =rediCorrectionDetail.invoiceCases;
			this.invoicePriceCS = rediCorrectionDetail.invoicePriceCS;
			this.invoicePriceLB = rediCorrectionDetail.invoicePriceLB;
			this.errorMessage = rediCorrectionDetail.errorMessage;*/
			
			/*.....	alias item	....................   */
			col = new AdvancedDataGridFilterColumn("aliasItem");
			col.dataField = "aliasItem";
			col.headerText = "Alias Item";
			col.width = 100;
			col.editable = false;
			_arrRediEditDgCols.push(col);
			/*.....	invoiceNumber	....................   */
			col = new AdvancedDataGridFilterColumn("aliasItemDesc");
			col.dataField = "aliasItemDesc";
			col.headerText = "Alias Item Description";
			col.width = 100;
			col.editable = false;
			_arrRediEditDgCols.push(col);
			/*.....	Customer_Name	....................   */
			/*col = new AdvancedDataGridFilterColumn("aliasItemPackSize");
			col.dataField = "aliasItemPackSize";
			col.headerText = "Alias Item Pack Size";
			col.width = 100;
			col.editable = false;
			_arrRediEditDgCols.push(col);*/
			
			/*.....	item	....................   */
		/*	col = new AdvancedDataGridFilterColumn("item");
			col.dataField = "item";
			col.headerText = "Item";
			col.width = 100;
			col.editable = true;
			_arrRediEditDgCols.push(col);*/
			/* item column */	
			colPlain = new AdvancedDataGridColumn("item");
			colPlain.dataField = "item";
			colPlain.headerText = "Item";
			colPlain.width = 100;
			colPlain.editable = true;
			colPlain.itemEditor = new ClassFactory(itemSearch);
			colPlain.editorDataField = 'retVal';
			colPlain.editable = true;
			//colUom.resizable= false;
			_arrRediEditDgCols.push(colPlain);
			
			/*.....	itemDesc	....................   */
			col = new AdvancedDataGridFilterColumn("itemDesc");
			col.dataField = "itemDesc";
			col.headerText = "Item Description";
			col.width = 200;
			col.editable = false;
			_arrRediEditDgCols.push(col);
			/*.....	itemPackSize	....................   */
		/*	col = new AdvancedDataGridFilterColumn("itemPackSize");
			col.dataField = "itemPackSize";
			col.headerText = "Item Pack Size";
			col.width = 100;
			col.editable = false;
			_arrRediEditDgCols.push(col);*/
			/*.....	InvCases	....................   */
			colPlain = new AdvancedDataGridColumn("invoiceCases");
			colPlain.dataField = "invoiceCases";
			colPlain.headerText = "Inv. CS";
			colPlain.width = 75;
			colPlain.editable = false;
			_arrRediEditDgCols.push(colPlain);
			/*.....	InvDollars	....................   */
			colPlain = new AdvancedDataGridColumn("invoicePriceCS");
			colPlain.dataField = "invoicePriceCS";
			colPlain.headerText = "Inv. $";
			colPlain.width = 75;
			colPlain.editable = false;
			_arrRediEditDgCols.push(colPlain);
			/*.....	errormessage	....................   */
			col = new AdvancedDataGridFilterColumn("errorMessage");
			col.dataField = "errorMessage";
			col.headerText = "Message";
			col.width = 175;
			col.editable = false;
			_arrRediEditDgCols.push(col);
			/*.....	End	....................   */
			/* Empty col so last row is not huge ....................*/
			colPlain = new AdvancedDataGridColumn("xSpace");
			colPlain.visible = true;
			colPlain.headerText = '';
			colPlain.width = .99;
			colPlain.editable = false;
			colPlain.visible = true;
			_arrRediEditDgCols.push(colPlain); 
			dispatchEvent(new Event('arrRediEditDgColsChanged'));
		}
		
		public function uomLabelFunc(item:Object, col:DataGridFilterColumn):String{
			return item.uom.abbreviation;
		}
		public function custNameLabelFunc(item:Object, column:AdvancedDataGridColumn):String 
		{
			return item[column.dataField].name;	
		}
		public function custNumberLabelFunc(item:Object, column:AdvancedDataGridColumn):String 
		{
			return item[column.dataField].shipTo;
		}
	}
}