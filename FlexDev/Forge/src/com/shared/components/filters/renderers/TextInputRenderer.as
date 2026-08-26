package com.shared.components.filters.renderers
{
	import com.shared.components.filters.DataGridFilterColumn;
	import com.shared.components.filters.FilterDatagrid;
	import com.shared.events.MainEvent;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.collections.ArrayCollection;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.controls.DataGrid;
	import mx.controls.Text;
	import mx.controls.TextInput;
	import mx.controls.listClasses.BaseListData;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import mx.core.ScrollPolicy;
	import mx.managers.FocusManager;
	import mx.utils.StringUtil;
	
	import spark.components.Image;
	
	public class TextInputRenderer extends VBox implements IDropInListItemRenderer
	{
		private var _listData:BaseListData;
		
		[Bindable]private var headerText:Text;
		
		//edit
		[Bindable]private var editComp:TextInput;	
		[Bindable]private var hbEdit:HBox = new HBox();
		[Bindable]private var imgEdit:Image = new Image();
		//filter
		[Bindable]private var filterComp:TextInput;
		[Bindable]private var hbFilter:HBox = new HBox();
		[Bindable]private var imgFilter:Image = new Image();
		
		private var _data:DataGridFilterColumn;
		
		[Embed(source="assets/Images/filter-icon_15_trans.gif")]
		[Bindable]
		private var imgFilterCls:Class;
		[Embed(source="assets/Images/edit_15.gif")]
		[Bindable]
		private var imgEditCls:Class;
		
		private var filterCompWatcher:ChangeWatcher;
		private var editCompWatcher:ChangeWatcher;
		
		private var hbEditVisibilityWatcher:ChangeWatcher;
		private var hbEditIncludeWatcher:ChangeWatcher;
		
		private var hbFilterVisibilityWatcher:ChangeWatcher;
		private var hbFilterIncludeWatcher:ChangeWatcher;
		
		public function TextInputRenderer()
		{
			super();
			horizontalScrollPolicy = ScrollPolicy.OFF;
			verticalScrollPolicy = ScrollPolicy.OFF;
			super.setStyle("verticalGap", "1");
			super.setStyle("horizontalAlign","center");
			super.setStyle("verticalAlign","bottom");
			
			/*  D31359: Test 7.0 Issues/Anand Rao/10-Apr-2012
				The below functionality was removed for the below reasons:
				a) The Edit functionality was not working and removing the below code made it work   
				b) When a cell in the grid was edited or the focus was placed on the filter text box, 
				the below code was causing the datagrid to sort automatically [added for Milan]
			*/
			// this.addEventListener(Event.REMOVED ,dispose,false,0,true);

		}
		
		private function dispose(e:Event):void{
			if(filterComp.hasEventListener(Event.CHANGE)){
				editComp.removeEventListener(Event.CHANGE,onEditChange);
				filterComp.removeEventListener(Event.CHANGE,onFilterChange);
				
				editComp.removeEventListener(MouseEvent.MOUSE_UP,onClickHandler);
				hbEdit.removeEventListener(MouseEvent.MOUSE_UP,onClickHandler);
				imgEdit.removeEventListener(MouseEvent.MOUSE_UP,onClickHandler);
				
				editComp.removeEventListener(MouseEvent.CLICK,onClickHandler);
				hbEdit.removeEventListener(MouseEvent.CLICK,onClickHandler);
				imgEdit.removeEventListener(MouseEvent.CLICK,onClickHandler);
				
				editComp.removeEventListener(MouseEvent.MOUSE_DOWN,onClickHandler);
				hbEdit.removeEventListener(MouseEvent.MOUSE_DOWN,onClickHandler);
				imgEdit.removeEventListener(MouseEvent.MOUSE_DOWN,onClickHandler);
				
				filterComp.removeEventListener(Event.CHANGE,onFilterChange);
				filterComp.removeEventListener(MouseEvent.MOUSE_UP,onClickHandler);
				hbFilter.removeEventListener(MouseEvent.MOUSE_UP,onClickHandler);
				imgFilter.removeEventListener(MouseEvent.MOUSE_UP,onClickHandler);
				
				filterComp.removeEventListener(MouseEvent.CLICK,onClickHandler);
				hbFilter.removeEventListener(MouseEvent.CLICK,onClickHandler);
				imgFilter.removeEventListener(MouseEvent.CLICK,onClickHandler);
				
				filterComp.removeEventListener(MouseEvent.MOUSE_DOWN,onClickHandler);
				hbFilter.removeEventListener(MouseEvent.MOUSE_DOWN,onClickHandler);
				imgFilter.removeEventListener(MouseEvent.MOUSE_DOWN,onClickHandler);
				
				filterCompWatcher.unwatch();
				editCompWatcher.unwatch();
				
				hbEditVisibilityWatcher.unwatch();
				hbEditIncludeWatcher.unwatch();
				
				hbFilterVisibilityWatcher.unwatch();
				hbFilterIncludeWatcher.unwatch();
				
				filterCompWatcher = null;
				editCompWatcher= null;
				
				hbEditVisibilityWatcher = null;
				hbEditIncludeWatcher = null;
				
				hbFilterVisibilityWatcher = null;
				hbFilterIncludeWatcher = null;
			}
			this.removeEventListener(Event.REMOVED,dispose);
		}
		
		override public function set width(value:Number):void
		{
			super.width = value;
		}
		
		override public function set percentWidth(value:Number):void
		{
			super.percentWidth = value;
		}
		
		//override protected function 
		override protected function createChildren():void
		{
			super.createChildren();
			if(!headerText)
			{
				headerText = new Text;
				headerText.percentWidth = 100;
				headerText.setStyle("textAlign", "center");
				headerText.setStyle("verticalAlign", "middle");
				/* The style sheet changes do not affect header font. The changes need to be made here for "FilterDataGrid" */
				headerText.setStyle("fontWeight", "bold");
				headerText.setStyle("fontSize", "11");
				headerText.setStyle("fontFamily", "Century Gothic, Verdana, Arial");
				headerText.selectable = false;		
				addChild(headerText);
			}
			if(!filterComp)
			{
				hbFilter.percentWidth = 100;
				//hbFilter.height = 23;
				//define image
				
				imgFilter.source = this.imgFilterCls;
				imgFilter.verticalAlign = 'middle';
				
				filterComp = new TextInput();
				filterComp.percentWidth = 75;
				filterComp.height = 18;
				filterComp.toolTip = 'filter data';
				filterComp.setStyle("borderColor","#000000");
				filterComp.setStyle("borderAlpha",".3");
				filterComp.setStyle("fontWeight", "normal");
				filterComp.setStyle("fontSize", "10");

				filterComp.addEventListener(Event.CHANGE,onFilterChange,false,0,true);
				filterComp.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDownHandler,false,0,true);
				filterComp.addEventListener("focusOut",onFocusOutHandler,false,0,true);
				
				filterComp.addEventListener(MouseEvent.MOUSE_UP,onClickHandler,false,0,true);
				hbFilter.addEventListener(MouseEvent.MOUSE_UP,onClickHandler,false,0,true);
				imgFilter.addEventListener(MouseEvent.MOUSE_UP,onClickHandler,false,0,true);
				
				filterComp.addEventListener(MouseEvent.CLICK,onClickHandler,false,0,true);
				hbFilter.addEventListener(MouseEvent.CLICK,onClickHandler,false,0,true);
				imgFilter.addEventListener(MouseEvent.CLICK,onClickHandler,false,0,true);
				
				filterComp.addEventListener(MouseEvent.MOUSE_DOWN,onClickHandler,false,0,true);
				hbFilter.addEventListener(MouseEvent.MOUSE_DOWN,onClickHandler,false,0,true);
				imgFilter.addEventListener(MouseEvent.MOUSE_DOWN,onClickHandler,false,0,true);
				//addEventListener(MouseEvent.CLICK,onClickHandler);
				//addEventListener(MouseEvent.MOUSE_DOWN,onClickHandler);
				
				//add hbox
				addChild(hbFilter);
				//add image and text input
				hbFilter.addChild(imgFilter);
				hbFilter.addChild(filterComp);
			}
			if(!editComp)
			{
				
				hbEdit.percentWidth = 100;
				//hbFilter.height = 23;
				//define image
				imgEdit.source = this.imgEditCls;
				imgEdit.verticalAlign = 'middle';
				
				editComp = new TextInput();
				editComp.percentWidth = 75;
				editComp.height = 18;
				editComp.toolTip = 'edit data';		
				editComp.setStyle("borderColor","#000000");
				editComp.setStyle("borderAlpha",".3");
				
				//editComp.addEventListener(Event.CHANGE,onEditChange,false,0,true);
				editComp.addEventListener(KeyboardEvent.KEY_DOWN,onEditKeyDownHandler,false,0,true);
				editComp.addEventListener("focusOut",onFocusOutEditHandler,false,0,true);
				
				editComp.addEventListener(MouseEvent.MOUSE_UP,onClickHandler,false,0,true);
				hbEdit.addEventListener(MouseEvent.MOUSE_UP,onClickHandler,false,0,true);
				imgEdit.addEventListener(MouseEvent.MOUSE_UP,onClickHandler,false,0,true);
				
				editComp.addEventListener(MouseEvent.CLICK,onClickHandler,false,0,true);
				hbEdit.addEventListener(MouseEvent.CLICK,onClickHandler,false,0,true);
				imgEdit.addEventListener(MouseEvent.CLICK,onClickHandler,false,0,true);
				
				editComp.addEventListener(MouseEvent.MOUSE_DOWN,onClickHandler,false,0,true);
				hbEdit.addEventListener(MouseEvent.MOUSE_DOWN,onClickHandler,false,0,true);
				imgEdit.addEventListener(MouseEvent.MOUSE_DOWN,onClickHandler,false,0,true);
				
				//add hbox to renderer
				addChild(hbEdit);
				//add image and text input to hBox
				hbEdit.addChild(imgEdit);
				hbEdit.addChild(editComp);
				
			}
		}
		
		// Filter data function
		private function filterDataHandler():void
		{
				_data.filterText = filterComp.text;
				DataGrid(listData.owner).dispatchEvent(new Event("filterEvent"));
		}
		
		private function onClickHandler(event:MouseEvent):void
		{
			//if(event.target.parent.className == 'TextInput')
			//{
			//event.stopImmediatePropagation();
			//event.preventDefault();
			event.stopPropagation();
			//}
		}
		
		private function onKeyDownHandler(event:KeyboardEvent):void
		{	
			// "tab" key
			if(event.keyCode.toString() == '9')
			{
				// go to "first row" and "first column" on the grid
				DataGrid(listData.owner).setFocus();
				DataGrid(listData.owner).selectedIndex = 0;
				/* 	This creates an issue on the Corrections grid (detail grid), when the tab focus goes from textbox to checkbox and then when the tab
					goes out of the checkbox
				*/
				//DataGrid(listData.owner).editedItemPosition = { rowIndex: 0 , columnIndex: 1 };
			}
			
			// "enter" key OR "tab" key
			if(event.keyCode.toString() == '13' || event.keyCode.toString() == '9')
			{	
				// call filter data function
				filterDataHandler();
				
			}
		}
		
		private function onFocusOutHandler(event:FocusEvent):void
		{
			// call filter data function only if there is text
			if(_data.filterText.length != 0){
				filterDataHandler();
			}
		}
		
		private function onFilterChange(event:Event):void
		{
				_data.filterText = filterComp.text;
			
				// If there is no data to filter on, return all results
				if(_data.filterText.length == 0)
				{
					// call filter data function
					filterDataHandler();
				}
		}
		
		private function onEditKeyDownHandler(event:KeyboardEvent):void
		{	
			// "tab" key
			if(event.keyCode.toString() == '9')
			{
				// go to "first row" and "first column" on the grid
				DataGrid(listData.owner).setFocus();
				DataGrid(listData.owner).selectedIndex = 0;
				/* 	This creates an issue on the Corrections grid (detail grid), when the tab focus goes from textbox to checkbox and then when the tab
				goes out of the checkbox
				*/
				//DataGrid(listData.owner).editedItemPosition = { rowIndex: 0 , columnIndex: 1 };
			}
			
			// "enter" key OR "tab" key
			if(event.keyCode.toString() == '13' || event.keyCode.toString() == '9')
			{	
				// call filter data function
				onEditChange(event);
			}
		}
		private function onFocusOutEditHandler(event:FocusEvent):void
		{
			// call filter data function.  only if there is text...incase they just clcicked in and out of edit text box
			if(editComp.text.length > 0){
				onEditChange(event);
			}
		}
		
		private function onEditChange(event:Event):void
		{
			_data.editText = editComp.text;
			//so we don't loses the ones we are filtering
			var iVisibleCounter:int = 0;
			if(filterComp.text.length){
				_data.filterText = _data.editText;
				filterComp.text = _data.editText;
			}
			DataGrid(listData.owner).dispatchEvent(new Event("editEvent"));
			var dp:ArrayCollection = DataGrid(listData.owner).dataProvider as ArrayCollection;
			var dpMain:Array 	   = dp.source as Array;
			dp.disableAutoUpdate();
			for each(var o:* in dp){
				if(o.isSelected){
					o[_data.dataField] = _data.editText;
					//dispatch Update row in case anyone is listening
					var evt:MainEvent = new MainEvent(MainEvent.UPDATE_ROW);
					evt.objRowData = o;
					DataGrid(listData.owner).dispatchEvent(evt);
				}
			}
			/* 
				The below condition will check to see if the no. of records in the returned 
				arraycollection is equal to the no. of records in the source and also check to see
				if the id equals "dgBBUploadItem" which is the Individual corrections grid and
				work only for that grid. -Anand Rao/08-May-2012
			    this makes no sense.  if they dont equal repeat the loop?
			*/
			/*if ((dp.length != dpMain.length) && (DataGrid(listData.owner).id == "dgBBUploadItem"))
			{
				for each(var obj:* in dp)
				{
					obj[_data.dataField] = _data.editText;	
				}
			}*/
			dp.enableAutoUpdate();
			dp.refresh();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		/*public function set editCompVisible(value:Boolean):void
		{
		editComp.visible = value;
		}*/
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
			_data = value as DataGridFilterColumn;
			headerText.text = _data.headerText;
			//filter tooltip
			filterComp.toolTip = 'filter data on ' + headerText.text;
			imgFilter.toolTip = 'filter data on ' + headerText.text;
			//edit tooltip
			editComp.toolTip = 'edit ' + headerText.text + ' column.  update all selected (checked) rows';
			imgEdit.toolTip = 'edit ' + headerText.text + ' column.  update all selected (checked) rows';
			
			filterCompWatcher = BindingUtils.bindProperty(filterComp,"text",_data,"filterText",false,true);
			editCompWatcher   = BindingUtils.bindProperty(editComp,"text",_data,"editText",false,true);
			
			hbEditVisibilityWatcher = BindingUtils.bindProperty(hbEdit,"visible",_data,"editVisible",false,true);
			hbEditIncludeWatcher 	= BindingUtils.bindProperty(hbEdit,"includeInLayout",_data,"editVisible",false,true);
			
			hbFilterVisibilityWatcher 	= BindingUtils.bindProperty(hbFilter,"visible",_data,"filterVisible",false,true);
			hbFilterIncludeWatcher		= BindingUtils.bindProperty(hbFilter,"includeInLayout",_data,"filterVisible",false,true);
		}
		
		override public function get data():Object
		{
			return _data;
		}
		
	}
}
