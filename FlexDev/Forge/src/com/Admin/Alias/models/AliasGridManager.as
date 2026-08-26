package com.Admin.Alias.models
{
	import com.shared.components.*;
	import com.shared.components.chBoxIsSelectedDg;
	import com.shared.components.chBoxSelectAllDg;
	import com.shared.components.filters.DataGridDeleteColumn;
	import com.shared.components.filters.DataGridFilterColumn;
	import com.shared.components.filters.DataGridFilterColumnMultiSelect;
	import com.shared.models.GridManager;
	import com.shared.views.renderer.gridCombo;
	import com.shared.vos.AppFlex;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.controls.Alert;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	
	public class AliasGridManager  extends GridManager
	{
		/*................  Constructor  ...................*/
		private var dispatcher:IEventDispatcher;
		public function AliasGridManager ( dispatcher:IEventDispatcher )
		{
			super();
			this.dispatcher = dispatcher;
			buildGrid();
		}
		
		/* regular grid. */
		private function buildGrid():void
		{
			this.buildGridCols();
		}
		
		/* custom grid */
		private function buildUniproGrid():void
		{
			this.uniproBuildGridCols();
		}
		
		public function changeDataGrid(dataGridType:String):void
		{
			if(dataGridType == '11'){			
				buildUniproGrid();
			}
			else{
				buildGrid();
			}
		}
		
		private var _arrAliasDgCols:Array = new Array();
		[Bindable (event="arrAliasDgColsChanged")]
		public function get arrAliasItemsDgCols():Array
		{
			return _arrAliasDgCols;
		}

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
			for each(var col:DataGridColumn in _arrAliasDgCols)
			{
				if (col.dataField == "payeeID")
				{
					col.headerText = this.labelSettings.appFlex.bbLabels.Vendor  + " ID"; // Vendor 
				}
			}
		} 
 
		public function buildGridCols():void
		{
			var col:DataGridFilterColumn;
			var colSel:DataGridColumn;
			_arrAliasDgCols = new Array;
			/*.....	isSelected	.....................  */
		 	colSel = new DataGridColumn('isSelected');
			colSel.dataField = 'isSelected';
			colSel.editable = true;
			colSel.sortable = false;
			colSel.width = 25;
			colSel.rendererIsEditor=true;
			colSel.headerRenderer = new ClassFactory(chBoxSelectAllDg);
			colSel.itemRenderer = new ClassFactory(chBoxIsSelectedDg);
			colSel.editorDataField = "varCbSelected";
			
			_arrAliasDgCols.push(colSel); 
			/*.....     Delete icon         .....................  */
            var colDelete:DataGridDeleteColumn;
            colDelete = new DataGridDeleteColumn('');
            colDelete.editable = false;
            colDelete.sortable = false;
            colDelete.width = 25;
            _arrAliasDgCols.push(colDelete);
			/*.....	Alias ID	....................   */
			col = new DataGridFilterColumn("aliasID");
			col.dataField = "aliasID";
			col.headerText = "Alias ID";
			col.width = 100;
			col.editable = false;
			_arrAliasDgCols.push(col);
			/*.....	Alias Description	....................   */
			col = new DataGridFilterColumn("aliasDesc");
			col.dataField = "aliasDesc";
			col.headerText = "Alias Desc";
			col.width = 150;
			col.editable = false;
			_arrAliasDgCols.push(col);
		
			
			/*.....	Alias Address	....................   */   
			col = new DataGridFilterColumn("aliasAddress");
			col.dataField = "aliasAddress";
			col.headerText = "Alias Address";
			col.width = 200;
			col.editable = false;
			col.visible = false;
			col.showDataTips = true;
			col.labelFunction = aliasAddressLabelFunc;
			col.dataTipFunction = function(item:Object):String{var desc:String = "";
				if(item != null)
				{
					desc = item.aliasAddress.toString();
				}
				return desc;};
			_arrAliasDgCols.push(col);
			/*.....	Entity ID	....................   */
			col = new DataGridFilterColumn("entityID");			
			col.dataField = "entityID";
			col.headerText = "ID";
			col.width = 100;
			col.editable = false;			
			_arrAliasDgCols.push(col);
			/*.....	Entity Description	....................   */
			col = new DataGridFilterColumn("entityDesc");
			col.dataField = "entityDesc";
			col.headerText = "Desc";
			col.width = 400;
			col.editable = false;
			_arrAliasDgCols.push(col);
			/*.....	Payee_ID	....................   */
			col = new DataGridFilterColumn("payeeID");			
			col.dataField = "payeeID";
			col.headerText = "Payee ID";
			col.width = 75;
			col.editable = false;
			col.visible = true;
			_arrAliasDgCols.push(col);			
			/*.....	Entity Address	....................   */
			col = new DataGridFilterColumn("entityAddress");
			col.dataField = "entityAddress";
			col.headerText = "Address";
			col.width = 200;
			col.editable = false;
			col.visible = false;
			col.showDataTips = true;
			col.dataTipFunction = function(item:Object):String{var desc:String = "";
				if(item != null)
				{
					desc = item.entityAddress.toString();
				}
				return desc;};
			_arrAliasDgCols.push(col);

			/*.....	Holding Invoice Count	....................   */
			col = new DataGridFilterColumn("holdInvoiceCount");
			col.dataField = "holdInvoiceCount";
			col.headerText = "Hold Invoice Count";
			col.width = 100;
			col.visible = false;
			col.editable = false;
			_arrAliasDgCols.push(col);
			
			/* Empty col so last row is not huge ....................
			col = new DataGridFilterColumn("xSpace");
			col.visible = true;
			col.headerText = '';*/
			/* with a "minus" sign, the last column is hidden 
			col.width = -3.59;
			col.editable = false;
			col.visible = true;
			_arrAliasDgCols.push(col);*/
			dispatchEvent(new Event('arrAliasDgColsChanged'));
		}
		
		public function showHideAdressCols(b:Boolean,iTab:int,sSourceType:String):void{
			//need to rebuild since ui is not updating on time
			// this.buildGridCols();
			/* Currently, we not only just have a regular grid, but also another grid ("unipro_450", i.e. SourceType = 11).
			In the future,we may have more grids. The below logic is applicable only for the regular grid.
			If we call this logic for other grids, then the "address" column gets hidden, when it should be visible for
			other grid(s) ("unipro_450") all the time. Other Source types (if they do have a diiferent grids), may have to 
			be added below in the future.
			*/
			if(sSourceType != '11'){
				
					for each(var col:* in this._arrAliasDgCols){
						switch (col.dataField) {
							case 'entityAddress':	
								col.visible = b;
								if(b){col.width = 190}
								else{col.width = 0}
								break; 
							case 'aliasAddress':
								col.visible = b;
								if(b){col.width = 190}
								else{col.width = 0}
								break;
							case 'isSelected':
								col.width = 25;
								break;
							case null: //deletecol
								col.width = 25;
								break;
							case 'aliasID':
								col.width = 100;
								break;
							case 'aliasDesc':
								if(b){col.width = 150}
								else{col.width = 315}
								break;
							case 'entityID':
								col.width = 100;
								break;
							case 'payeeID':
								if(iTab == 0 && sSourceType == '1'){
									col.width = 100;
									col.visible = true;
								}
								else{
									col.width = 0;
									col.visible = false;
								}
								break;
							case 'entityDesc':
								if(b){
									col.width = 125;
								}
								else{
									col.width = 315;
								}
								break;
							case 'holdInvoiceCount':
								if (this.labelSettings.appSettings.SHOW_HOLDING_PEN && sSourceType == '1')
								{
									col.width = 100;
									col.visible = true;
								}
								else
								{
									col.width = 0;
									col.visible = false;
								}
							default: 
								trace ("showHideAdressCols unknown col") ; 
						} 
					}
					dispatchEvent(new Event('arrAliasDgColsChanged'));
				}
		}
		
		public function uniproBuildGridCols():void
		{
			var col:DataGridFilterColumn;
			var colSel:DataGridColumn;
			_arrAliasDgCols = new Array;
			/*.....	isSelected	.....................  */
			colSel = new DataGridColumn('isSelected');
			colSel.dataField = 'isSelected';
			colSel.editable = true;
			colSel.sortable = false;
			colSel.width = 25;
			colSel.rendererIsEditor=true;
			colSel.headerRenderer = new ClassFactory(chBoxSelectAllDg);
			colSel.itemRenderer = new ClassFactory(chBoxIsSelectedDg);
			colSel.editorDataField = "varCbSelected";
			
			_arrAliasDgCols.push(colSel); 
			/*.....     Delete icon         .....................  */
			var colDelete:DataGridDeleteColumn;
			colDelete = new DataGridDeleteColumn('');
			colDelete.editable = false;
			colDelete.sortable = false;
				colDelete.width = 25;
			_arrAliasDgCols.push(colDelete);
			/*.....	Alias ID	....................   */
			col = new DataGridFilterColumn("aliasID");
			col.dataField = "aliasID";
			col.headerText = "DUN";
			col.width = 125;
			col.editable = false;
			_arrAliasDgCols.push(col);
			/*.....	Alias Region	....................   */
			col = new DataGridFilterColumn("aliasRegion");
			col.dataField = "aliasRegion";
			col.headerText = "Region";
			col.width = 125;
			col.editable = false;
			_arrAliasDgCols.push(col);
		/*.....	Alias Address	....................   */
			col = new DataGridFilterColumn("aliasDesc");
			col.dataField = "aliasDesc";
			col.headerText = "Name";
			col.width = 150;
			col.editable = false;
			_arrAliasDgCols.push(col);
			/*.....	Alias Address	....................   */
			col = new DataGridFilterColumn("aliasAddress");			
			col.dataField = "aliasAddress";
			col.headerText = "Address";
			col.width = 125;
			col.editable = false;			
			_arrAliasDgCols.push(col);
			/*.....	Alias City	....................   */
			col = new DataGridFilterColumn("aliasCity");
			col.dataField = "aliasCity";
			col.headerText = "City";
			col.width = 100;
			col.editable = false;
			_arrAliasDgCols.push(col);
			/*.....	Alias State	....................   */
			col = new DataGridFilterColumn("aliasState");			
			col.dataField = "aliasState";
			col.headerText = "State";
			col.width = 100;
			col.editable = false;
			col.visible = true;
			_arrAliasDgCols.push(col);			
			/*.....	Alias Zip	....................   */
			col = new DataGridFilterColumn("aliasZIP");
			col.dataField = "aliasZIP";
			col.headerText = "ZIP";
			col.width = 100;
			col.editable = false;
			_arrAliasDgCols.push(col);
			/*.....	Alias UnproNum	....................   */
			col = new DataGridFilterColumn("aliasUniproNum");
			col.dataField = "aliasUniproNum";
			col.headerText = "Unipro Num";
			col.width = 100;
			col.editable = false;
			_arrAliasDgCols.push(col);			
			/*.....	Alias Loc	....................   */
			col = new DataGridFilterColumn("aliasLoc");
			col.dataField = "aliasLoc";
			col.headerText = "Loc";
			col.width = 100;
			col.editable = false;
			_arrAliasDgCols.push(col);					
			/*.....	Entity ID	....................   */
			col = new DataGridFilterColumn("entityID");
			col.dataField = "entityID";
			col.headerText = "ID";
			col.width = 100;
			col.editable = false;
			_arrAliasDgCols.push(col);	
			/*.....	Entity Description	....................   */
			col = new DataGridFilterColumn("entityDesc");
			col.dataField = "entityDesc";
			col.headerText = "Desc";
			col.width = 100;
			col.editable = false;
			_arrAliasDgCols.push(col);
			/* Empty col so last row is not huge ....................
			col = new DataGridFilterColumn("xSpace");
			col.visible = true;
			col.headerText = '';*/
			/* with a "minus" sign, the last column is hidden 
			col.width = -3.59;
			col.editable = false;
			col.visible = true;
			_arrAliasDgCols.push(col);*/
			dispatchEvent(new Event('arrAliasDgColsChanged'));
		}	
		
		public function aliasAddressLabelFunc(item:Object, column:DataGridColumn):String 
		{
			return item['aliasAddress'] + ' ' + item['aliasCity']  + ' ' + item['aliasState']  + ' ' + item['aliasZIP'];	
		}
	}
}