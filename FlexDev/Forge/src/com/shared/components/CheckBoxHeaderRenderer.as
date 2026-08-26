package com.shared.components
{
		
	import com.shared.events.MainEvent;
	
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.controls.AdvancedDataGrid;
	import mx.controls.Alert;
	import mx.controls.CheckBox;
	import mx.controls.DataGrid;
	import mx.controls.Image;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridListData;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.controls.dataGridClasses.DataGridListData;
	import mx.controls.listClasses.BaseListData;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.events.AdvancedDataGridEvent;
	import mx.events.DataGridEvent;
	import mx.geom.RoundedRectangle;
	
	public class CheckBoxHeaderRenderer extends Canvas implements IDropInListItemRenderer, IListItemRenderer
	{
		protected var _showAddRow:Boolean;
		protected var selector:CheckBox;
		protected var _data:*;
		protected var _listData:BaseListData;
		protected var _dp:ArrayCollection;
		protected var _dataGrid:*;
		protected var _dataField:String;

		[Bindable] protected var imgAdd:Image;
		[Embed(source="assets/Images/add.png")]
		[Bindable]	protected var imgAddCls:Class;	
		
		/*-...................................... Constructor .......................................*/
		public function CheckBoxHeaderRenderer(){
			super();
		}
		
		/*-...................................... Properties .......................................*/

		/* show/hide insert row */
		public function get showAddRow():Boolean{
			return _showAddRow;
		}
		public function set showAddRow(bShowAddRow:Boolean):void{
			this._showAddRow = bShowAddRow;		
		}
		
		/* listData methods */
		[Bindable("dataChange")]
		public function get listData():BaseListData {
			return _listData;
		}

		public function set listData(value:BaseListData):void {
			_listData = value;
			if(value.owner is mx.controls.DataGrid){
				_dp = DataGrid(value.owner).dataProvider as ArrayCollection;
				_dataField = (value as DataGridListData).dataField;
			}
			else if(value.owner is AdvancedDataGrid){
				_dp = AdvancedDataGrid(value.owner).dataProvider as ArrayCollection;
				_dataField = (value as AdvancedDataGridListData).dataField;
			}
		}
		
		/* data methods */
		override public function get data():Object {
			return _data;
		}
		
		override public function set data(value:Object):void {
			if(listData.owner is mx.controls.DataGrid){
				_data = value as DataGridColumn;
			}
			else if(listData.owner is AdvancedDataGrid){
				_data = value as AdvancedDataGridColumn;
			}	
		}

		// Add checkbox and insert row icon
		override protected function createChildren():void {
			super.createChildren();
			
			// check box
			this.selector = new CheckBox();
			selector.setStyle("horizontalCenter", "0");
			if(showAddRow){
				selector.setStyle("verticalCenter", "-10");
			}else{
				selector.setStyle("verticalCenter", "0");
			}
			this.selector.useHandCursor = true;
			this.selector.buttonMode = true;
			this.addChild(this.selector);
			this.selector.addEventListener(MouseEvent.CLICK, dispatchCheckBoxSelected);

			// add row icon
			if(showAddRow){
				this.imgAdd = new Image();
				this.imgAdd.setStyle("horizontalCenter", "0");
				this.imgAdd.setStyle("verticalCenter", "10");
				this.imgAdd.toolTip = 'insert new row';
				this.imgAdd.useHandCursor = true;
				this.imgAdd.buttonMode = true;
				this.imgAdd.source = this.imgAddCls;
				this.addChild(this.imgAdd);
				this.imgAdd.addEventListener(MouseEvent.CLICK, dispatchInsertRowSelected);
			}
		}		


		// checkbox clicked
		private function dispatchCheckBoxSelected(evt:MouseEvent):void {
			for each (var oItem:Object in _dp) {
				 oItem[_dataField] = selector.selected;
			}
		}
		
		// addRow clicked
		private function dispatchInsertRowSelected(evt:MouseEvent):void {
			var event:MainEvent = new MainEvent(MainEvent.INSERT_ROW);
			this.dispatchEvent(event);
			// KAL: leaving this code here to incase the event doesnt dispatch correctly;
			/*... check if DataGrid or AdvancedDataGrid; dispatch event ...
			if(listData.owner is mx.controls.DataGrid){
				DataGrid(listData.owner).dispatchEvent(event);
			}
			else if(listData.owner is AdvancedDataGrid){
				AdvancedDataGrid(listData.owner).dispatchEvent(event);
			}	
			*/
		}

	}
	
}