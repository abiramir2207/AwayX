package com.shared.components.filters.renderers
{
	import com.shared.components.filters.DataGridFilterColumn;
	import com.shared.components.filters.DataGridFilterColumnMultiSelect;
	import com.shared.views.renderer.MultiSelectionDropDown;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.DataGrid;
	import mx.controls.Text;
	import mx.controls.TextInput;
	import mx.controls.dataGridClasses.DataGridListData;
	import mx.controls.listClasses.BaseListData;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import mx.core.ScrollPolicy;
	import mx.utils.StringUtil;
	
	import spark.components.Image;
	
	//import spark.components.DataGrid;
	
	public class MultiSelectRenderer extends VBox implements IDropInListItemRenderer
	{
		private var _listData:BaseListData;

		
		[Embed(source="assets/Images/filter-icon_15_trans.gif")]
		[Bindable]
		private var imgFilterCls:Class;
		[Embed(source="assets/Images/edit_15.gif")]
		[Bindable]
		private var imgEditCls:Class;
		
		private var headerText:Text;
		
		//edit
		[Bindable]private var editComp:TextInput;	
		[Bindable]private var hbEdit:HBox = new HBox();
		[Bindable]private var imgEdit:Image = new Image();
		//filter
		[Bindable]private var filterComp:MultiSelectionDropDown;
		[Bindable]private var hbFilter:HBox = new HBox();
		[Bindable]private var imgFilter:Image = new Image();
		
		private var _data:DataGridFilterColumnMultiSelect;
		private var _dataGrid:mx.controls.DataGrid;
		private var _dataField:String;
		
		public function MultiSelectRenderer()
		{
			super();
			horizontalScrollPolicy = ScrollPolicy.OFF;
			verticalScrollPolicy = ScrollPolicy.OFF;
			super.setStyle("verticalGap", "1");
			super.setStyle("horizontalAlign","center");
		}
		
		override public function set width(value:Number):void
		{
			super.width = value;
		}
		
		override public function set percentWidth(value:Number):void
		{
			super.percentWidth = value;
		}
		
		
		override protected function createChildren():void
		{
			super.createChildren();
			if(!headerText)
			{
				headerText = new Text;
				headerText.percentWidth = 100;
				headerText.setStyle("textAlign", "center");
				headerText.setStyle("verticalAlign", "middle");
				headerText.selectable = false;		
				addChild(headerText);
			}
			if(!filterComp)
			{
				hbFilter.percentWidth = 100;
				
				imgFilter.source = this.imgFilterCls;
				imgFilter.verticalAlign = 'middle';
				
				filterComp = new MultiSelectionDropDown;
				filterComp.percentWidth = 99.5;
				filterComp.addEventListener(Event.CHANGE,onFilterChange,false,0,true);
				
				filterComp.addEventListener(Event.CHANGE,onFilterChange,false,0,true);
				filterComp.addEventListener(MouseEvent.MOUSE_UP,onClickHandler,false,0,true);
				hbFilter.addEventListener(MouseEvent.MOUSE_UP,onClickHandler,false,0,true);
				imgFilter.addEventListener(MouseEvent.MOUSE_UP,onClickHandler,false,0,true);
				
				filterComp.addEventListener(MouseEvent.CLICK,onClickHandler,false,0,true);
				hbFilter.addEventListener(MouseEvent.CLICK,onClickHandler,false,0,true);
				imgFilter.addEventListener(MouseEvent.CLICK,onClickHandler,false,0,true);
				
				filterComp.addEventListener(MouseEvent.MOUSE_DOWN,onClickHandler,false,0,true);
				hbFilter.addEventListener(MouseEvent.MOUSE_DOWN,onClickHandler,false,0,true);
				imgFilter.addEventListener(MouseEvent.MOUSE_DOWN,onClickHandler,false,0,true);
				
				//addEventListener(MouseEvent.MOUSE_UP,onClickHandler);
				//add hbox
				addChild(hbFilter);
				//add image and text input
				hbFilter.addChild(imgFilter);
				hbFilter.addChild(filterComp);
			}
			
		
		}
		
		private function onClickHandler(event:MouseEvent):void
		{
			if(event.currentTarget == filterComp)
			{
				event.stopImmediatePropagation();
			}
		}
		
		private function onFilterChange(event:Event):void
		{
			_data.filterArray = filterComp.arrSelectedItems;
			DataGrid(listData.owner).dispatchEvent(new Event("filterEvent"));
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
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
			_dataGrid = value.owner as mx.controls.DataGrid;
			_dataField = (value as DataGridListData).dataField;
		}
		
		override public function set data(value:Object):void
		{
			_data = value as DataGridFilterColumnMultiSelect;
			headerText.text = _data.headerText;
			BindingUtils.bindProperty(filterComp,"currentSelection",_data,"filterArray");
			callLater(setFilterDp);
		}
		
		override public function get data():Object
		{
			return _data;
		}
		
		private function setFilterDp():void {
			var dp:ArrayCollection = _dataGrid.dataProvider as ArrayCollection;
			var n:Number = 0;
			var arrDp:Array = new Array();
			if(dp){
				for each (var oItem:Object in dp) {
					if(arrDp.indexOf(oItem[_dataField]) == -1)
					{
						arrDp.push(oItem[_dataField]);
					}
				}
			}
			this.filterComp.dataProvider = new ArrayList(arrDp);
			this.filterComp.currentSelection = _data.filterArray;
			
		}
		
	}
}
