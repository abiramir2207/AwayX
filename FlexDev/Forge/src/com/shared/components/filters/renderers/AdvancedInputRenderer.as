package com.shared.components.filters.renderers
{
	import com.shared.components.filters.AdvancedDataGridFilterColumn;
	import com.shared.components.filters.FilterAdvancedDatagrid;
	import com.shared.components.spark.ComboBoxSkinBa;
	import com.shared.events.MainEvent;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.AdvancedDataGrid;
	import mx.controls.Alert;
	import mx.controls.Text;
	import mx.controls.TextInput;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridHeaderRenderer;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridSortItemRenderer;
	import mx.controls.listClasses.BaseListData;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import mx.core.ScrollPolicy;
	import mx.core.UITextField;
	import mx.events.AdvancedDataGridEvent;
	import mx.managers.FocusManager;
	import mx.utils.StringUtil;
	
	import flashx.textLayout.formats.*;
	import spark.components.CheckBox;
	import spark.components.ComboBox;
	import spark.components.HGroup;
	import spark.components.Image;
	import spark.components.Label;
	import spark.components.supportClasses.Skin;

	
	public class AdvancedInputRenderer extends VBox implements IDropInListItemRenderer
	{
		private var _listData:BaseListData;
		
		//[Bindable]private var headerText:Text;
		[Bindable]private var headerText:Label;
		
		[Bindable]private var sortIcon:AdvancedDataGridSortItemRenderer = new AdvancedDataGridSortItemRenderer();
		[Bindable]private var hGroupSort:HBox = new HBox();
		//filter
		[Bindable]private var filterComp:TextInput;
		[Bindable]private var hbFilter:HBox = new HBox();
		[Bindable]private var imgFilter:Image = new Image();
		[Bindable]private var chkBFilter:CheckBox;
		
		//edit via text
		[Bindable]private var editComp:TextInput;
		[Bindable]private var hbEdit:HBox = new HBox();
		[Bindable]private var imgEdit:Image = new Image();
		[Bindable]private var imgApplyEdit:Image = new Image();
		
		//filter combo
		[Bindable]private var filterCombo:ComboBox;
		[Bindable]private var hbfilterCombo:HBox = new HBox();
				
		private var _data:AdvancedDataGridFilterColumn;
		
		[Embed(source="assets/Images/filter-icon_15_trans.gif")]
		[Bindable]
		private var imgFilterCls:Class;
		[Embed(source="assets/Images/edit_15.gif")]
		[Bindable]
		private var imgEditCls:Class;
		[Embed(source="assets/Images/add.png")]
		[Bindable]
		private var imgApplyEditCls:Class;
		
		private var filterCompWatcher:ChangeWatcher;
		private var editCompWatcher:ChangeWatcher;
		
		private var hbEditVisibilityWatcher:ChangeWatcher;
		private var hbEditIncludeWatcher:ChangeWatcher;
		
		private var chkBFilterVisibilityWatcher:ChangeWatcher;
		private var chkBFilterIncludeWatcher:ChangeWatcher;
		
		private var hbFilterVisibilityWatcher:ChangeWatcher;
		private var hbFilterIncludeWatcher:ChangeWatcher;
		
		private var hbFilterComboVisibilityWatcher:ChangeWatcher;
		private var hbFilterComboIncludeWatcher:ChangeWatcher;
		
		private var filterComboDpWatcher:ChangeWatcher;
		private var filterComboWatcher:ChangeWatcher;
		private var filterComboSelectedWatcher:ChangeWatcher;
		
		
		public function AdvancedInputRenderer()
		{
			super();
			this.percentHeight = 100;
			horizontalScrollPolicy = ScrollPolicy.OFF;
			verticalScrollPolicy = ScrollPolicy.OFF;
			super.setStyle("verticalGap", "1");
			super.setStyle("horizonatalGap",  "1");
			super.setStyle("verticalAlign","top");
			super.setStyle("horizontalAlign","center");
			//this.addEventListener(Event.REMOVED_FROM_STAGE,dispose);
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
		
		public function mouseEventToHeaderPart(event:MouseEvent):String{
			return AdvancedDataGrid.HEADER_TEXT_PART;
		}
		
		/*override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			filterComp.setFocus();
		}*/
		//performs the layout of the child controls
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			
			var textLabel:UITextField;
			var n:int = numChildren;
			// Cache padding values
			var paddingLeft:int   = getStyle("paddingLeft");
			var paddingRight:int  = getStyle("paddingRight");
			var paddingTop:int    = getStyle("paddingTop");
			var paddingBottom:int = getStyle("paddingBottom");
			for (var i:int = 0; i < n; i++)
			{
				var sort:DisplayObject = getChildAt(i);
				
				if (sort is AdvancedDataGridSortItemRenderer)
				{
					var sortItemRendererX:Number = unscaledWidth
						- sort.width
						- 3;
					/*var sortItemRendererY:Number = (unscaledHeight - sort.height
						- paddingTop - paddingBottom
					) / 2
						+ paddingTop;*/
					
					sort.x = Math.round(sortItemRendererX);
					sort.y = Math.round(headerText.y);                   
					
				}else if(sort is UITextField){
					
					textLabel = sort as UITextField;
				}
			}
			//check to avoid overllaping of text on the checkbox
			/*var xMin_text:int = sortIcon.x + sortIcon.measuredWidth;
			if(textLabel !=null && textLabel.x < xMin_text){
				
				textLabel.x = xMin_text;
				textLabel.truncateToFit();
				
			}*/
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			if(!headerText)
			{
				//this.owner.addEventListener(AdvancedDataGridEvent.SORT,sortListener);
				this.owner.addEventListener(AdvancedDataGridEvent.SORT,sortListener);
				super.setStyle("verticalGap", "1");
				super.setStyle("horizonatalGap",  "1");
				super.setStyle("verticalAlign","top");
				super.setStyle("horizontalAlign","center");
				headerText = new Label();
				headerText.id = "tHeaderText";
				headerText.percentHeight = 100;
				headerText.setStyle("verticalAlign", VerticalAlign.TOP);
				headerText.setStyle("textAlign", "center");
				/* The style sheet changes do not affect header font. The changes need to be made here for "FilterAdvancedDataGrid" */
				headerText.setStyle("fontWeight", "bold");
				headerText.setStyle("fontSize", "11");
				headerText.setStyle("fontFamily", "Century Gothic, Verdana, Arial");
			//	headerText.selectable = false;
				
				//hGroupSort.percentWidth = 95;
				//hGroupSort.percentHeight = 25;
				//hGroupSort.setStyle("horizontalAlign","center");
				//hGroupSort.owner = this.owner;
				
				//hGroupSort.addChild(headerText);
				//hGroupSort.addChild(sortIcon);
				//this.addChild(hGroupSort);
				sortIcon.includeInLayout = false;
				this.addChild(headerText);
				this.addChild(sortIcon);
				
			}


			if(!filterComp)
			{
				hbFilter.percentWidth = 95;
				hbFilter.height = 22;
				imgFilter.source = this.imgFilterCls;
				imgFilter.verticalAlign = 'middle';
				imgFilter.id= 'imgfilterheader';
				
				filterComp = new TextInput();
				filterComp.setStyle("verticalAlign","top");
				filterComp.setStyle("fontWeight", "bold");
				filterComp.setStyle("fontSize", "10");
				filterComp.percentWidth = 70;
				filterComp.height = 20;
				filterComp.toolTip = 'filter data';
				filterComp.tabEnabled = true;
				filterComp.tabIndex = 1;
				filterComp.addEventListener(Event.CHANGE,onFilterChange);
				filterComp.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDownHandler);
				filterComp.id = 'tifilterheader';
				filterComp.addEventListener("focusOut",onFocusOutHandler);
				
				chkBFilter = new CheckBox();
				chkBFilter.id = 'chkfilterheader';
				chkBFilter.addEventListener(MouseEvent.CLICK, onChkBClickHandler,false,0,true);
			
				
				/*filterComp.addEventListener(MouseEvent.MOUSE_UP,onClickHandler,false,0,true);
				hbFilter.addEventListener(MouseEvent.MOUSE_UP,onClickHandler,false,0,true);
				imgFilter.addEventListener(MouseEvent.MOUSE_UP,onClickHandler,false,0,true);
				
				filterComp.addEventListener(MouseEvent.CLICK,onClickHandler,false,0,true);
				hbFilter.addEventListener(MouseEvent.CLICK,onClickHandler,false,0,true);
				imgFilter.addEventListener(MouseEvent.CLICK,onClickHandler,false,0,true);
				
				filterComp.addEventListener(MouseEvent.MOUSE_DOWN,onClickHandler,false,0,true);
				hbFilter.addEventListener(MouseEvent.MOUSE_DOWN,onClickHandler,false,0,true);
				imgFilter.addEventListener(MouseEvent.MOUSE_DOWN,onClickHandler,false,0,true);*/
				
				//add hbox
				addChild(hbFilter);
				//add image and text input
				hbFilter.addChild(imgFilter);
				hbFilter.addChild(filterComp);
				hbFilter.addChild(chkBFilter);
			}
			if(!editComp)
			{	
				hbEdit.percentWidth = 95;
				hbEdit.height = 22;
				//define image
				imgEdit.source = this.imgEditCls;
				imgEdit.verticalAlign = 'middle';
				imgEdit.id = 'imgeditfilterheader';
				
				editComp = new TextInput();
				editComp.percentWidth = 70;
				editComp.height = 20;
				editComp.toolTip = 'edit data';
				editComp.tabEnabled = true;
				editComp.id = 'editcompfilterheader';
				//editComp.addEventListener(Event.CHANGE,onEditChange);
				
				imgApplyEdit.source = this.imgApplyEditCls;
				imgApplyEdit.verticalAlign = 'middle';
				imgApplyEdit.useHandCursor = true;
				imgApplyEdit.buttonMode = true;
				imgApplyEdit.addEventListener(MouseEvent.CLICK, onEditChange,false,0,true);
				imgApplyEdit.id = 'imgapplyfilterheader';
				
				
		/*		editComp.addEventListener(MouseEvent.MOUSE_UP,onClickHandler,false,0,true);
				hbEdit.addEventListener(MouseEvent.MOUSE_UP,onClickHandler,false,0,true);
				imgEdit.addEventListener(MouseEvent.MOUSE_UP,onClickHandler,false,0,true);
				
				editComp.addEventListener(MouseEvent.CLICK,onClickHandler,false,0,true);
				hbEdit.addEventListener(MouseEvent.CLICK,onClickHandler,false,0,true);
				imgEdit.addEventListener(MouseEvent.CLICK,onClickHandler,false,0,true);
				
				editComp.addEventListener(MouseEvent.MOUSE_DOWN,onClickHandler,false,0,true);
				hbEdit.addEventListener(MouseEvent.MOUSE_DOWN,onClickHandler,false,0,true);
				imgEdit.addEventListener(MouseEvent.MOUSE_DOWN,onClickHandler,false,0,true);*/
				
				//add hbox to renderer
				addChild(hbEdit);
				//add image and text input to hBox
				hbEdit.addChild(imgEdit);
				hbEdit.addChild(editComp);
				hbEdit.addChild(imgApplyEdit);
				
			}
			if(!filterCombo)
			{
				hbfilterCombo.percentWidth = 95;
				hbfilterCombo.height = 20
				
				//imgFilter.source = this.imgFilterCls;
				//imgFilter.verticalAlign = 'middle';
				
				filterCombo = new ComboBox();
				filterCombo.setStyle("skinClass",ComboBoxSkinBa);
				filterCombo.setStyle('alternatingItemColors',0xFFFFFF);
			//	filterCombo.
				filterCombo.percentWidth = 95;
				filterCombo.height = 18;
				filterCombo.id = 'cmbfilterheader';
				//filterCombo.defaultButton.height = 18;
				filterCombo.toolTip = 'filter data';
				filterCombo.tabEnabled = true;
				filterCombo.tabIndex = 1;
				filterCombo.addEventListener(Event.CHANGE,onFilterComboChange);
				filterCombo.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDownHandler);
				//filterCombo.addEventListener("focusOut",onFocusOutHandler);
				
				//filterCombo.addEventListener(MouseEvent.MOUSE_UP,onClickHandler,false,0,true);
				//hbfilterCombo.addEventListener(MouseEvent.MOUSE_UP,onClickHandler,false,0,true);
				
				//filterCombo.addEventListener(MouseEvent.CLICK,onClickHandler,false,0,true);
				//hbFilter.addEventListener(MouseEvent.CLICK,onClickHandler,false,0,true);
				
				//filterCombo.addEventListener(MouseEvent.MOUSE_DOWN,onClickHandler,false,0,true);
				//hbfilterCombo.addEventListener(MouseEvent.MOUSE_DOWN,onClickHandler,false,0,true);
				
				//add hbox
				addChild(hbfilterCombo);
				hbfilterCombo.addChild(filterCombo);
			}
		}
		
		// Filter data function
		private function filterDataHandler():void
		{
			_data.filterText = filterComp.text;
			_data.filterComboText = this.filterCombo.selectedItem;
			AdvancedDataGrid(listData.owner).dispatchEvent(new Event("filterEvent"));
		}
		
		private function onClickHandler(event:MouseEvent):void{
			//event.stopImmediatePropagation();
			//event.stopPropagation();
			//event.preventDefault();
			trace('Click Header');
		}
		public function sortListener(e:AdvancedDataGridEvent):void{
			//e.triggerEvent.target.owner.id
			//  'openButton is the ID of the button for the comboBox dropdown'
			var obj:*;
			if(e.triggerEvent.target.hasOwnProperty("id") && e.triggerEvent.target.id && (e.triggerEvent.target.id == 'openButton' || e.triggerEvent.target.id == 'textDisplay' )){
				obj = e.triggerEvent.target;
			}else if(e.triggerEvent && e.triggerEvent.target && e.triggerEvent.target.owner && e.triggerEvent.target.owner.id ){
				obj = e.triggerEvent.target.owner;
			}
			if(obj){
				var s:String = obj.id.toString();
				if(s.toLowerCase().indexOf('filterheader')== -1 && s != 'openButton' && s != 'textDisplay'){
					var e:AdvancedDataGridEvent = new AdvancedDataGridEvent(AdvancedDataGridEvent.SORT);
					var dg:AdvancedDataGrid = this.owner as AdvancedDataGrid;
					//dg.callLater(dispatchEvent, [e]);
				}
				else{
					e.stopImmediatePropagation();
				}
			}
			var event:AdvancedDataGridEvent = e;
		}
		
		private function onKeyDownHandler(event:KeyboardEvent):void{
			// "tab" key
			if(event.keyCode.toString() == '9')
			{
				// go to "first row" and "first column" on the grid
				AdvancedDataGrid(listData.owner).setFocus();
				AdvancedDataGrid(listData.owner).selectedIndex = 0;
				/* 	This creates an issue on the Corrections grid (detail grid), when the tab focus goes from textbox to checkbox and then when the tab
				goes out of the checkbox
				*/
			}
			
			// "enter" key OR "tab" key
			if(event.keyCode.toString() == '13' || event.keyCode.toString() == '9')
			{	
				var cmb:ComboBox = event.currentTarget as ComboBox;
				var ti:mx.controls.TextInput = event.currentTarget as mx.controls.TextInput;
				if(!cmb){
					event.stopImmediatePropagation();
					filterDataHandler();
					if(ti && event.keyCode.toString() == '13'){
						callLater(setFocusText, [ti]);
					}
				}
				// call filter data function
			}
		}
		
		private function onFocusOutHandler(event:FocusEvent):void
		{
			// call filter data function
			// call filter data function only if there is text
			if(_data.filterText.length != 0){
				filterDataHandler();
			}
		}
		
		private function onFilterChange(event:Event):void
		{
			_data.filterText = filterComp.text;
			// If there is no data to filter on, return all results
			if(_data.filterText.length == 0 )  // TOO Much Delay  || _data.filterText.length > 3
			{
				// call filter data function
				filterDataHandler();
				callLater(setFocusText, [filterComp]);
			}
		}
		
		private function onFilterComboChange(event:Event):void
		{
			_data.filterComboText = this.filterCombo.selectedItem;
			// If there is no data to filter on, return all results
			// call filter data function
				filterDataHandler();
				callLater(setFocusCombo, [filterCombo]);
		}

		private function onEditChange(event:Event):void
		{
			_data.editText = editComp.text;
			
			AdvancedDataGrid(listData.owner).dispatchEvent(new Event("editEvent"));
			var dp:ArrayCollection = AdvancedDataGrid(listData.owner).dataProvider as ArrayCollection;
			var sSource:String = _data.dataField;
			
			
			var evt:MainEvent = new MainEvent(MainEvent.VALIDATE_MASS_UPDATE);
			evt.editText = _data.editText;
			evt.objMassUpdate = dp;
			evt.sSource = sSource;
			this.dispatchEvent(evt);
			
			dp.enableAutoUpdate();
			dp.refresh();
			callLater(setFocusText, [editComp]);
		}
		
		/**
		 * To set the focus back to the text input
		 */
		private function setFocusText(focusObj:TextInput):void {
			focusObj.setFocus();
			focusObj.setSelection(focusObj.selectionActivePosition,focusObj.selectionActivePosition);
			
		}
		private function setFocusCombo(focusObj:ComboBox):void {
			focusObj.setFocus();
			
		}
		
		private function onChkBClickHandler(event:MouseEvent):void{
			AdvancedDataGrid(listData.owner).dispatchEvent(new Event("editVisibleChanged"));
			var dp:ArrayCollection = AdvancedDataGrid(listData.owner).dataProvider as ArrayCollection;
			_data.editVisible = chkBFilter.selected;
			
			if (!_data.editVisible){
				_data.filterText = "";
				_data.editText = "";
			}
			
			dp.enableAutoUpdate();
			dp.refresh();
		}
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
			_data = value as AdvancedDataGridFilterColumn;
			if(_data){
				headerText.text = _data.headerText;
				headerText.width = _data.width;
				headerText.percentHeight = 100;
			}
			if(this._data && this._data.sortable){
				headerText.toolTip = 'Sort by ' +  headerText.text;
			}
			if(this._data.toolTip != ''){
				headerText.toolTip =  headerText.toolTip + '\n[ '+ this._data.toolTip + ' ]';
			}
			this.filterCombo.openButton.height = 18;
			/*if(this.data){
				filterCombo.dataProvider = this.data.filterComboDp as IList;
			}*/
			
			/* Dev Note; 30780. Not using the visible property as of now. Might be used if we need to hide or disable the editable checkbox 
			(program and assoc dist) on the BB item grid
			*/
			//chkBFilter.visible = _data.editable;
			
			//filter tooltip
			filterComp.toolTip = 'filter data on ' + headerText.text;
			imgFilter.toolTip = 'filter data on ' + headerText.text;
			//edit tooltip
			editComp.toolTip = 'edit ' + headerText.text + ' column.  update all selected (checked) rows';
			imgEdit.toolTip = 'edit ' + headerText.text + ' column.  update all selected (checked) rows';
			
			chkBFilter.toolTip = 'display edit field to mass apply ' + headerText.text;
			
			imgApplyEdit.toolTip =  'apply ' + headerText.text + ' to all selected (checked) rows';
			
			filterCompWatcher = BindingUtils.bindProperty(filterComp,"text",_data,"filterText",false,true);
			editCompWatcher   = BindingUtils.bindProperty(editComp,"text",_data,"editText",false,true);
			
			hbEditVisibilityWatcher = BindingUtils.bindProperty(hbEdit,"visible",_data,"editVisible",false,true);
			hbEditIncludeWatcher 	= BindingUtils.bindProperty(hbEdit,"includeInLayout",_data,"editVisible",false,true);
			
			chkBFilterVisibilityWatcher = BindingUtils.bindProperty(chkBFilter,"visible",_data,"chkBFilterVisible",false,true);
			chkBFilterIncludeWatcher 	= BindingUtils.bindProperty(chkBFilter,"includeInLayout",_data,"chkBFilterVisible",false,true);
			
			hbFilterVisibilityWatcher 	= BindingUtils.bindProperty(hbFilter,"visible",_data,"filterVisible",false,true);
			hbFilterIncludeWatcher		= BindingUtils.bindProperty(hbFilter,"includeInLayout",_data,"filterVisible",false,true);
			
			hbFilterComboVisibilityWatcher 	= BindingUtils.bindProperty(hbfilterCombo,"visible",_data,"filterComboVisible",false,true);
			hbFilterComboIncludeWatcher		= BindingUtils.bindProperty(hbfilterCombo,"includeInLayout",_data,"filterComboVisible",false,true);
			
			filterComboDpWatcher = BindingUtils.bindProperty(filterCombo,"dataProvider",_data,"filterComboDp",false,true);
			filterComboWatcher = BindingUtils.bindProperty(filterCombo,"selectedItem",_data,"filterComboText",false,true);
			filterComboSelectedWatcher = BindingUtils.bindProperty(filterCombo,"selectedIndex",_data,"filterComboSelectedIndex",false,true);
		}
		
		override public function get data():Object
		{
			return _data;
		}	
	}
}
