package com.shared.components.filters.renderers
{
	import com.shared.events.MainEvent;
	
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	import mx.containers.Canvas;
	import mx.controls.AdvancedDataGrid;
	import mx.controls.Alert;
	import mx.controls.CheckBox;
	import mx.controls.DataGrid;
	import mx.controls.listClasses.BaseListData;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.utils.ObjectUtil;
	
	import spark.components.Image;
	
	public class InsertRowIconRenderer extends Canvas implements IDropInListItemRenderer, IListItemRenderer {
		
		protected var _listData:BaseListData;
		[Bindable] protected var imgAdd:Image;
		[Embed(source="assets/Images/add.png")]
		[Bindable]	protected var imgAddCls:Class;

		
		override protected function createChildren():void {
			super.createChildren();
			this.imgAdd = new Image();
			this.imgAdd.source = this.imgAddCls;
			this.imgAdd.toolTip = 'insert new row';
			this.imgAdd.useHandCursor = true;
			this.imgAdd.buttonMode = true;
			this.addChild(this.imgAdd);
			this.imgAdd.addEventListener( MouseEvent.CLICK, dispatchColumnSelected,false,0,true);
			//this.addEventListener(Event.REMOVED_FROM_STAGE,dispose);
		}
		
		private function dispose(e:Event):void{
			if(this.imgAdd.hasEventListener(MouseEvent.CLICK)){
				this.imgAdd.removeEventListener( MouseEvent.CLICK, dispatchColumnSelected);
			}
			//this.removeEventListener(Event.REMOVED_FROM_STAGE,dispose);
		}
		
		[Bindable("dataChange")]
		public function get listData():BaseListData {
			return _listData;
		}
		
		// Define the setter method,
		public function set listData(value:BaseListData):void {
			_listData = value;
		}
		
		override public function set data(data:Object):void { }
		
		override public function get data():Object { return null; }
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			this.imgAdd.x = (unscaledWidth - this.imgAdd.getExplicitOrMeasuredWidth())/2 ;
			this.imgAdd.y = (unscaledHeight - this.imgAdd.getExplicitOrMeasuredHeight())/2;
			this.imgAdd.setActualSize(this.imgAdd.getExplicitOrMeasuredWidth(), this.imgAdd.getExplicitOrMeasuredHeight());
		}
		
		
		private function dispatchColumnSelected(evt:MouseEvent):void {
			var event:MainEvent = new MainEvent(MainEvent.INSERT_ROW);
			event.currentRow = listData.rowIndex;
			this.dispatchEvent(event);
			
			/*... check if DataGrid or AdvancedDataGrid; dispatch event ...*/
			/*
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
