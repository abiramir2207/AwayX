package com.shared.components.filters.renderers
{
	
	import com.shared.components.filters.FilterAdvancedDatagrid;
	import com.shared.components.filters.FilterDatagrid;
	import com.shared.events.MainEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.AdvancedDataGrid;
	import mx.controls.Alert;
	import mx.controls.DataGrid;
	import mx.controls.Text;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridListData;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.controls.dataGridClasses.DataGridListData;
	import mx.controls.listClasses.AdvancedListBase;
	import mx.controls.listClasses.BaseListData;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import mx.core.ScrollPolicy;
	import mx.events.AdvancedDataGridEvent;
	import mx.events.CloseEvent;
	import mx.events.DataGridEvent;
	import mx.geom.RoundedRectangle;
	import mx.managers.FocusManager;
	import mx.utils.StringUtil;
	
	import spark.components.DataGrid;
	import spark.components.Image;
	import spark.components.supportClasses.ListBase;
	
	public class DeleteAddHeaderRenderer extends Canvas implements IDropInListItemRenderer
	{
		
		private var _data:*;
		private var _listData:BaseListData;
		private var _dg:*;
		private var _dp:ArrayCollection;
		private var _dataGrid:*;
		private var _dataField:String;
		private var _bDelete:Boolean;
		private var _fdg:spark.components.DataGrid;
		private var _advfdg:AdvancedDataGrid;
		
		
		[Bindable]private var imgDelete:Image = new Image();
		[Embed(source="assets/Images/delete.png")]
		[Bindable] private var imgDeleteCls:Class;
		
		[Bindable] private var imgAdd:Image = new Image();
		[Embed(source="assets/Images/add.png")]
		[Bindable]	private var imgAddCls:Class;	
		
		/*-...................................... Constructor .......................................*/
		public function DeleteAddHeaderRenderer(){
			super();
			horizontalScrollPolicy = ScrollPolicy.OFF;
			verticalScrollPolicy = ScrollPolicy.OFF;
			//this.addEventListener(Event.REMOVED_FROM_STAGE,dispose);
		}
		
		/*-...................................... Properties .......................................*/

		private function dispose(e:Event):void{
			if(imgDelete.hasEventListener(MouseEvent.MOUSE_UP)){
				imgDelete.removeEventListener(MouseEvent.MOUSE_UP,onClickHandler);
			}
			//this.removeEventListener(Event.REMOVED_FROM_STAGE,dispose);
		}
	
		override public function set width(value:Number):void
		{
			super.width = value;
		}
		
		override public function set percentWidth(value:Number):void
		{
			super.percentWidth = value;
		}
		
		// Add checkbox and insert row icon
		override protected function createChildren():void {
			super.createChildren();
			
			/* This file is being called from DataGrid and AdvancedDataGrid. The grid could be "FilterDataGrid" or "FilterAdvancedDataGrid" which extend DataGrid or AdvancedDataGrid */
			_fdg = this.owner as spark.components.DataGrid;
			_advfdg = this.owner as AdvancedDataGrid;
			
			//add delete icon
			this.imgDelete.source = this.imgDeleteCls;
			this.imgDelete.percentWidth = 100;
			this.imgDelete.setStyle("horizontalCenter", "0");
			this.imgDelete.setStyle("verticalCenter", "-10");
			this.imgDelete.toolTip = 'delete selected rows';
			this.imgDelete.useHandCursor = true;
			this.imgDelete.buttonMode = true;
			this.addChild(this.imgDelete);
			
			/* For bb edit grid which uses "_advfdg", the editable property is set to "items" and not "true" and that is why "editable != false" is being used below, instead of
			"editable == true". The alias grid is using "_fdg" and since the grid is not editable, we do not want to show the "add row" icon. */
			if((_fdg && _fdg.editable != false) || (_advfdg && _advfdg.editable != false)){
				//add insert icon
				this.imgAdd.source = this.imgAddCls;
				this.imgAdd.percentWidth = 100;
				this.imgAdd.setStyle("horizontalCenter", "0");
				this.imgAdd.setStyle("verticalCenter", "10");
				this.imgAdd.toolTip = 'insert new row';
				this.imgAdd.useHandCursor = true;
				this.imgAdd.buttonMode = true;
				this.imgAdd.addEventListener(MouseEvent.CLICK, dispatchInsertRowSelected);
				this.addChild(this.imgAdd);
			}			
		}
		
		// center the icon
		/*
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			this.imgDelete.x = (unscaledWidth - this.imgDelete.getExplicitOrMeasuredWidth())/2 ;
			this.imgDelete.y = (unscaledHeight - this.imgDelete.getExplicitOrMeasuredHeight())/2;
			this.imgDelete.setActualSize(this.imgDelete.getExplicitOrMeasuredWidth(), this.imgDelete.getExplicitOrMeasuredHeight());
		}
		*/
		private function onClickHandler(event:Event):void
		{
			this.deleteRow();
		}
		
		private function deleteRow():void
		{
			var winAlert:Alert;
			
			if(this._bDelete){
				winAlert = Alert.show('Are you sure you want to delete selected record(s)?', "Confirm", Alert.OK | Alert.CANCEL,this.parent as Sprite, alertListener, null, Alert.OK)	
				var newX:Number = 550;
				var newY:Number = 300;
				/* Without "validateNow()", the positioning of the "Alert" window does not happen when the 
				user deletes for the first time. Second time onwards, it does work.				   
				*/
				winAlert.validateNow();
				/* Without "callLater", the positioning does not work */
				callLater(winAlert.move,[newX, newY]);
			}
			
		}
		
		private function alertListener(eventObj:CloseEvent):void {
			// Check to see if the OK button was pressed.
			if (eventObj.detail==Alert.OK){
				//loop through the data provider to check for selected records
				for(var i:uint = 0; i < this._dp.length; null ){
					var obj:Object = Object(this._dp[i])
					//remove from the dataprovider if a record was selected
					if(obj.isSelected == true){
						this._dp.removeItemAt(this._dp.getItemIndex(obj));
					//FIX FOR BBEDIT.  columnIndex gets out of whack -> HACK!	
						if(this._dg.editedItemPosition){
							if (this._dg.editedItemPosition.columnIndex >= this._dg.columns.length){
								this._dg.editedItemPosition = { rowIndex:this._dg.editedItemPosition.rowIndex, columnIndex:this._dg.columns.length-1 };
								this._dg.validateNow();
							}
						}
						
						var evt:MainEvent = new MainEvent(MainEvent.DELETE_ROW);
						evt.objRowData = obj;
						_dg.dispatchEvent(evt);
					}
					else{
						i++;
					}
				}
				this._dp.refresh();
			}
		}
		//----------------------------------
		//  listData
		//----------------------------------
		
		/**
		 *  Implements the <code>listData</code> property
		 *  using setter and getter methods.
		 */
		public function get listData():BaseListData
		{
			return _listData; 
		}
		
		/**
		 *  @private
		 */
		public function set listData(value:BaseListData):void
		{
			_listData = value;
		}
		
		override public function set data(value:Object):void
		{
			
			if(value){
				if(!value.hasOwnProperty('bDelete')){
					this._bDelete = true;
				}
				else{
					this._bDelete = value.bDelete;
				}
				
				if(this._bDelete){
					if(!imgDelete.hasEventListener(MouseEvent.MOUSE_UP)){
						imgDelete.addEventListener(MouseEvent.MOUSE_UP,onClickHandler,false,0,true);
					}
				}
				else{
					imgDelete.removeEventListener(MouseEvent.MOUSE_UP,onClickHandler);
				}
				
				//set dp based on dg type
				if(listData.owner is mx.controls.DataGrid){
					this._dg = listData.owner as mx.controls.listClasses.ListBase;
				}
				else if(listData.owner is AdvancedDataGrid){
					this._dg = listData.owner as AdvancedListBase;
				}
				else if(listData.owner is spark.components.DataGrid){
					this._dg = listData.owner as spark.components.supportClasses.ListBase;
				}
				_data = value;
				this._dp = _dg.dataProvider as ArrayCollection;
			}
		}
		
		override public function get data():Object
		{
			return _data;
		}
		
		// checkbox clicked
		private function dispatchDeleteRowSelected(evt:MouseEvent):void {
			for each (var oItem:Object in _dp) {
				//oItem[_dataField];
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