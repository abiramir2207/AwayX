package com.shared.components.filters.renderers
{
	//import com.shared.components.filters.AdvDataGridDeleteColumn;
	//import com.shared.components.filters.DataGridDeleteColumn;
	//import com.shared.components.filters.FilterDatagrid;
	import com.shared.events.MainEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.AdvancedDataGrid;
	import mx.controls.Alert;
	import mx.controls.DataGrid;
	import mx.controls.Image;
	import mx.controls.Text;
	import mx.controls.listClasses.AdvancedListBase;
	import mx.controls.listClasses.BaseListData;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import mx.controls.listClasses.ListBase;
	import mx.core.ScrollPolicy;
	import mx.events.CloseEvent;
	import mx.utils.ObjectUtil;
	
	import spark.components.DataGrid;
	import spark.components.supportClasses.ListBase;
	
	public class ClearIconRenderer extends VBox implements IDropInListItemRenderer
	{
		public function ClearIconRenderer()
		{
			super();
			horizontalScrollPolicy = ScrollPolicy.OFF;
			verticalScrollPolicy = ScrollPolicy.OFF;
			//this.addEventListener(Event.REMOVED_FROM_STAGE,dispose);
		}
		
		private var _listData:BaseListData;
		private var _data:*;
		private var _dp:ArrayCollection;
		private var _bDelete:Boolean;
		private var _dg:*;
		[Bindable]private var headerText:Text;
		[Bindable]private var hbDelete:HBox;
		
		[Bindable]private var imgDelete:Image = new Image();
		
		[Embed(source="assets/Images/delete.png")]
		[Bindable] private var imgDeleteCls:Class;
		
		override public function set width(value:Number):void
		{
			super.width = value;
		}
		
		override public function set percentWidth(value:Number):void
		{
			super.percentWidth = value;
		}
		
		private function dispose(e:Event):void{
			if(imgDelete.hasEventListener(MouseEvent.MOUSE_UP)){
				imgDelete.removeEventListener(MouseEvent.MOUSE_UP,onClickHandler);
			}
			//this.removeEventListener(Event.REMOVED_FROM_STAGE,dispose);
		}
		override protected function createChildren():void
		{
			super.createChildren();
			this.imgDelete.source = this.imgDeleteCls;
			this.addChild(this.imgDelete);
			this.imgDelete.toolTip = 'reset this row';
			this.imgDelete.useHandCursor = true;
			this.imgDelete.buttonMode = true;
			
		}
		
		// center the icon
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			this.imgDelete.x = (unscaledWidth - this.imgDelete.getExplicitOrMeasuredWidth())/2 ;
			this.imgDelete.y = (unscaledHeight - this.imgDelete.getExplicitOrMeasuredHeight())/2;
			this.imgDelete.setActualSize(this.imgDelete.getExplicitOrMeasuredWidth(), this.imgDelete.getExplicitOrMeasuredHeight());
		}
		
		private function onClickHandler(event:Event):void
		{
			this.clearRow();
		}
		
		private function clearRow():void
		{

			var iRowIndex:int = this._dp.getItemIndex( this.data );			
			var objItem:Object = this._dp.getItemAt(iRowIndex);
			var evt:MainEvent = new MainEvent(MainEvent.CLEAR_ROW);
			evt.objRowData = objItem;
			_dg.dispatchEvent(evt);
			_dp.refresh();
			
		}
		
		private function alertListener(eventObj:CloseEvent):void {
			// Check to see if the OK button was pressed.
			if (eventObj.detail==Alert.OK) {							
				//var iRowIndex:int = this._listData.rowIndex; -- "rowIndex" gives the index of the records visible at a moment on the grid.
				
				/* get the index of the dataprovider */
				var iRowIndex:int = this._dp.getItemIndex( this.data );			
				var objItem:Object = this._dp.getItemAt(iRowIndex);
				
				//_dp.removeItemAt( iRowIndex );
				
				var evt:MainEvent = new MainEvent(MainEvent.CLEAR_ROW);
				evt.objRowData = objItem;
				_dg.dispatchEvent(evt);
				
			}
			_dp.refresh();
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
		
		import mx.utils.DescribeTypeCache;
		override public function set data(value:Object):void
		{
			//var type:XML = DescribeTypeCache.describeType(value);
			//var b:Boolean = type.@isDynamic.toString() == "true";
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
	}
}