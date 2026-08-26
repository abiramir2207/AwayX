package com.Admin.Alias.models
{
	import com.shared.components.*;
	import com.shared.components.filters.DataGridFilterColumn;
	import com.shared.models.GridManager;
	import com.shared.views.renderer.gridCombo;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	
	public class AliasItemsGridManager  extends GridManager
	{
		/*................  Constructor  ...................*/
		private var dispatcher:IEventDispatcher;
		public function AliasItemsGridManager ( dispatcher:IEventDispatcher )
		{
			super();
			this.dispatcher = dispatcher;
			this.buildGridCols();
		}
		/* arrAliasItemsDgCols bound to dgItems.columns */
		private var _arrAliasItemsDgCols:Array = new Array();
		[Bindable (event="arrAliasItemsDgColsChanged")]
		public function get arrAliasItemsDgCols():Array
		{
			return _arrAliasItemsDgCols;
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
			//_arrAliasItemsDgCols.push(col);
			/*.....	itemNumber	....................   */
			col = new DataGridFilterColumn("itemNumber");
			col.dataField = "itemNumber";
			col.headerText = "item";
			col.width = 175;
			col.editable = false;
			_arrAliasItemsDgCols.push(col);
			/*.....	description	....................   */
			col = new DataGridFilterColumn("description");
			col.dataField = "description";
			col.headerText = "description";
			col.width = 175;
			col.editable = false;
			_arrAliasItemsDgCols.push(col);
			/*.....	uom	....................   */
			col = new DataGridFilterColumn("uom");
			
			var uomEditor:ClassFactory = new ClassFactory(gridCombo);
			//uomEditor.properties = { uomDp: arrUomDp };
			
			col.dataField = "uom";
			col.headerText = "uom";
			col.labelFunction = uomLabelFunc;
			col.width = 150;
			col.editable = true;
			col.itemEditor = uomEditor;
			col.editorDataField = 'value';
			col.editable = true;
			
			//col.resizable= false;
			_arrAliasItemsDgCols.push(col);
			/*.....	rate	....................   */
			col = new DataGridFilterColumn("rate");
			col.dataField = "rate";
			col.headerText = "rate";
			col.labelFunction = formatDollar;//comes from extends GridManager in shared.models
			col.width = 175;
			col.editable = false;
			_arrAliasItemsDgCols.push(col);
			/*.....	volume	....................   */
			col = new DataGridFilterColumn("volume");
			col.dataField = "volume";
			col.headerText = "volume";
			col.width = 175;
			col.editable = false;
			_arrAliasItemsDgCols.push(col);
			/* Empty col so last row is not huge ....................*/
			col = new DataGridFilterColumn("xSpace");
			col.visible = true;
			col.headerText = '';
			col.width = .99;
			col.editable = false;
			col.visible = true;
			_arrAliasItemsDgCols.push(col); 
			dispatchEvent(new Event('arrAliasItemsDgColsChanged'));
		}
		
		public function uomLabelFunc(item:Object, col:DataGridFilterColumn):String{
			return item.uom.abbreviation;
		}
	}
}