package com.DistributorSearch.models
{
	import com.DistributorSearch.views.renderer.RateText;
	import com.DistributorSearch.views.renderer.UomCombo;
	import com.DistributorSearch.vos.Settings;
	import com.shared.components.filters.AdvancedDataGridFilterColumn;
	import com.shared.models.GridManager;
	import com.shared.vos.CustomerAttr;
	import com.shared.vos.Program;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumnGroup;
	import mx.core.ClassFactory;
	
	public class GridManager extends com.shared.models.GridManager
	{
		private var dispatcher:IEventDispatcher;
		public function GridManager( dispatcher:IEventDispatcher )
		{
			super();
			this.dispatcher = dispatcher;
			this.buildGridCols();
		}
		/* Settings Object */
		private var _sSettings:Settings = new Settings();
		[Bindable (event="distSettingsChanged")]
		public function get sSettings():Settings
		{
			return _sSettings;
		}
		public function set sSettings(s:Settings):void
		{
			this._sSettings = s;
			updateGridColsHeaderText();
			dispatchEvent(new Event('distSettingsChanged'));
		}
		/* arrDgItemsCols bound to dgItems.columns */
		private var _arrDgItemsCols:Array = new Array();
		[Bindable (event="arrDgItemsColsChanged")]
		public function get arrDgItemsCols():Array
		{
			return _arrDgItemsCols;
		}
		/* Program */
		private var _program:Program = new Program();
		[Bindable (event="gmProgramChange")]
		public function get program():Program
		{
			return _program;
		}
		public function set program(prg:Program):void
		{
			this._program = prg;
			dispatchEvent(new Event('gmProgramChange'));
			/* program defines template level Prod attrs.  add them to grid*/
			insertCustAttrCols();
		}
		/* build arrDgItemsCols which is boound to dgItems.columns in the view.  Should make this dynamic...populate it from a vos with static vars*/
		public function buildGridCols():void
		{
			var iWidth:int = 75;
			/*.....	baItem	.....  */
			var col:AdvancedDataGridColumn = new AdvancedDataGridColumn();
			var colFilter:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn("baItem");
			colFilter.dataField = "baItem";
			colFilter.headerText = "Distributor ID";
			colFilter.width = 100;
			colFilter.editable = false;
			col.draggable = false;
			_arrDgItemsCols.push(colFilter);
			/*.....	Description	.....  */
			colFilter = new AdvancedDataGridFilterColumn("Description");
			colFilter.dataField = "Description";
			colFilter.headerText = "Name";
			colFilter.width = 200;
			colFilter.editable = false;
			col.draggable = false;
			_arrDgItemsCols.push(colFilter);
			/*.....	Address	.....  */
			colFilter = new AdvancedDataGridFilterColumn("Address");
			colFilter.dataField = "Address";
			colFilter.headerText = "Address";
			colFilter.width = 275;
			colFilter.editable = false;
			colFilter.draggable = false;
			_arrDgItemsCols.push(colFilter);
			
			/*.....	col1	.....  */
			/*col = new AdvancedDataGridColumn("col1");
			col.dataField = "col1";
			//col.headerText = "Address";
			col.width = 100;
			col.editable = false;
			_arrDgItemsCols.push(col);*/
			
			
			/*.....	Rate	.....  */
		/*	col = new AdvancedDataGridColumn("Rate");
			col.dataField = "rate";
			col.headerText = "rate";
			col.labelFunction = formatDollar;
			col.width = 150;
			col.editable = false;
			_arrDgItemsCols.push(col);*/
			
			/* column group */
			var colGroup:AdvancedDataGridColumnGroup = new AdvancedDataGridColumnGroup();
			colGroup.headerText = 'Freight';
			//colGroup.width = iWidth * 2;
			//colGroup.minWidth = iWidth * 2;
			/* rate column */
		/*	var colRate:AdvancedDataGridColumn = new AdvancedDataGridColumn('rate');
			colRate.itemEditor = new ClassFactory(RateText);
			colRate.headerText = 'rate';
			colRate.dataField = 'rate';
			colRate.editorDataField = 'value';
			colRate.editable = true;
			colRate.labelFunction = formatDecimal;
			colRate.setStyle('textAlign','right');
			colRate.minWidth = iWidth;
			colRate.resizable= false;
			colRate.width = iWidth;*/
			/* uom column */	
			/*var colUom:AdvancedDataGridColumn = new AdvancedDataGridColumn('uom');
			colUom.itemEditor = new ClassFactory(UomCombo);
			colUom.headerText = 'uom';
			colUom.dataField = 'uom';
			colUom.editorDataField = 'value';
			colUom.editable = true;
			colUom.minWidth = iWidth;
			colUom.resizable= false;
			colUom.width = iWidth;
			
			colGroup.children.push(colRate);
			colGroup.children.push(colUom);
			_arrDgItemsCols.push(colGroup);*/
			/* Empty col so last row is not huge */
			col = new AdvancedDataGridColumn("xSpace");
			col.visible = true;
			col.headerText = '';
			col.width = .99;
			col.editable = false;
			col.visible = true;
			_arrDgItemsCols.push(col); 
			dispatchEvent(new Event('arrDgItemsColsChanged'));
			
		/*      <mx:DataGridColumn dataField="baItem" headerText="Distributor ID" width="100" editable="false" />
				<mx:DataGridColumn dataField="Description" headerText="Name" width="200" editable="false" />
				<mx:DataGridColumn dataField="Address" headerText="Address" width="300" editable="false" />
				<mx:DataGridColumn id="dgCol1" dataField="col1" headerText="{this.lblCol1}" width="100" editable="false" visible="{chShowcol1.selected}" />
				<mx:DataGridColumn id="dgCol2" dataField="col2" headerText="{this.lblCol2}" width="100" editable="false" visible="{chShowcol2.selected}" />
				<mx:DataGridColumn id="dgCol3" dataField="col3" headerText="{this.lblCol3}" width="100" editable="false" visible="{chShowcol3.selected}" />
				<mx:DataGridColumn id="dgCol4" dataField="col4" headerText="{this.lblCol4}" width="100" editable="false" visible="{chShowcol4.selected}" />
				<mx:DataGridColumn id="dgCol5" dataField="col5" headerText="{this.lblCol5}" width="100" editable="false" visible="{chShowcol5.selected}" />
				<mx:DataGridColumn id="dgCol6" dataField="col6" headerText="{this.lblCol6}" width="100" editable="false" visible="{chShowcol6.selected}" />   */
		}
		
		/* fired when oSettings gets updated -> update the headertext in dgItems.columns */
		public function updateGridColsHeaderText():void
		{
			for each(var col:AdvancedDataGridColumn in this._arrDgItemsCols){
				switch(col.dataField)
				{
					case 'Brand_Name':
						col.headerText = this.oSettings.brand;
						break;
					case 'Q_Brand':
						col.headerText = this.oSettings.qBrand;
						break;
					case 'Type_Code_Desc':
						col.headerText = this.oSettings.typeCode;
						break;
					case 'Type_Group_Desc':
						col.headerText = this.oSettings.typeGroup;
						break;
					case 'Item_Status':
						col.headerText = this.oSettings.lblStatus;
						break;
				}
			}
		}
		
		/* fired after program data arrives with Template specific prod attrs (allow in search, group in search) */
		public function insertCustAttrCols():void
		{
			for each(var ca:CustomerAttr in this.program.arrCustAttr){
				var b:Boolean = true;
				//check if the col already exists
				for each(var col:AdvancedDataGridColumn in this._arrDgItemsCols){
					if(col.dataField == ca.customerGroupAttributeNameField){
						b = false;
						break;
					}
				}
				if(b){
					/*.....	Add Cust Attrs	.....  */
					var colFilter:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn(ca.customerGroupAttributeNameField);
					colFilter.dataField = ca.customerGroupAttributeNameField;
					colFilter.headerText = ca.groupLevelDesc;
					colFilter.width = 200;
					colFilter.editable = false;
					colFilter.sortable = true;
					colFilter.visible = true;
					colFilter.filterComboVisible = true;
					colFilter.filterVisible = true;
					this._arrDgItemsCols.splice(this._arrDgItemsCols.length - 2,0,colFilter.cloneFC());
				}
			}
		}
		
		public function uomLabelFunc(item:Object, col:AdvancedDataGridColumn):String{
			return item.uom.abbreviation;
		}
	}
}