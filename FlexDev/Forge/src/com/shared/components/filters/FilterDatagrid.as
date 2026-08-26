package com.shared.components.filters
{
	
	
	import com.Billback.Upload.models.vos.BBUploadLog;
	import com.shared.components.filters.header.DataGridFilterHeader;
	import com.shared.components.mx.DataGridBa;
	import com.shared.events.MainEvent;
	import com.shared.views.skins.DataGridHeaderBackgroundSkinBa;
	import com.shared.views.skins.DataGridHeaderSeparatorSkinBa;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.collections.IList;
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	import mx.controls.Alert;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.FlexGlobals;
	import mx.core.mx_internal;
	import mx.events.CloseEvent;
	import mx.events.DataGridEvent;
	import mx.formatters.DateFormatter;
	import mx.skins.spark.DataGridHeaderBackgroundSkin;
	import mx.skins.spark.DataGridHeaderSeparatorSkin;
	import mx.utils.ObjectUtil;

	use namespace mx_internal;
	
	public class FilterDatagrid extends DataGridBa
	{
		
		public var _dtFormatDateTime:DateFormatter = new DateFormatter();
		
		private var _filterInsert:Function = function(inObject:Object):Boolean{return true;};
		[Bindable (event="filterInsertChanged")]
		public function get filterInsert():Function{
			return _filterInsert;
		}
		public function set filterInsert(fn:Function):void{
			_filterInsert = fn;
			dispatchEvent(new Event('filterInsertChanged'));
		}
		//[Bindable]
		//public var bAllowDelete:Boolean = false;
		
		private var _bAllowDelete:Boolean = false;
		[Bindable (event="bAllowDeleteChanged")]
		public function get bAllowDelete():Boolean{
			return _bAllowDelete;
		}
		public function set bAllowDelete(b:Boolean):void{
			this.removeEventListener(KeyboardEvent.KEY_UP, keyHandler);
			_bAllowDelete = b;
			//insert has timing issue.  columns array gets overwritten after this col is added
			if(b){
				this.addEventListener(KeyboardEvent.KEY_UP, keyHandler);
				/*var dgDelCol:DataGridDeleteColumn = new DataGridDeleteColumn('delete');
				this.columns.unshift(dgDelCol);
				this.invalidateDisplayList();*/
			}
			dispatchEvent(new Event('bAllowDeleteChanged'));
		}
		/* dispatcher so we can talk to Mate*/
		private var _dispatcher:IEventDispatcher = new EventDispatcher();
		[Bindable (event="fdDispatcherChanged")]
		public function get dispatcher():IEventDispatcher{
			return _dispatcher;
		}
		public function set dispatcher(disp:IEventDispatcher):void{
			
			_dispatcher = disp;
			dispatchEvent(new Event('fdDispatcherChanged'));
		}
		
		/*........ Value gets passed down to DataGridFilterColumn [same property name] Show Hide the FILTER textinput in the header ..........*/
		private var _filterVisible:Boolean = true;
		public function set filterVisible(inValue:Boolean):void
		{
			_filterVisible = inValue;
			dispatchEvent(new Event('dgFilterVisibleChanged'));
			this.applyHeaderOptions();
		} 
		
		[Bindable (event="dgFilterVisibleChanged")]
		public function get filterVisible():Boolean
		{
			return _filterVisible;
		}
		/*........ Value gets passed down to DataGridFilterColumn [same property name] Show Hide the EDIT textinput in the header ..........*/
		private var _editVisible:Boolean = false;
		public function set editVisible(inValue:Boolean):void
		{
			_editVisible = inValue;
			dispatchEvent(new Event('dgEditVisibleChanged'));
			this.applyHeaderOptions();
			
		} 
		[Bindable (event="dgEditVisibleChanged")]
		public function get editVisible():Boolean
		{
			var b:Boolean;
			b = (this.editable && _editVisible);
			return b;
		}
		
		override public function set columns(value:Array):void{
			super.columns = value;
			this.applyHeaderOptions();
		}
		
		override public function set rowCount(value:int):void{
			super.rowCount = value;
		}
		
		/*...........................................*/
		/*................  METHODS  ................*/
		/*...........................................*/

		public function FilterDatagrid():void
		{
			super();
			headerClass = DataGridFilterHeader;
			addEventListener("filterEvent",onFilterChange);
			addEventListener(DataGridEvent.COLUMN_STRETCH, onColumnStretch);
			this.rowHeight = 19;
			//this.headerHeight = 75;
			/* The event bubbles on its own. No need to add the listener. I was passing "dispatcher" as an argument from the grid so that event can be dispatched
			   from here, but it is not required.
			*/
			//addEventListener(MainEvent.DELETE_ROW,deleteHandler);
		}
		
		override public function set dataProvider(value:Object):void
		{
			clearHeaderFilterEditText();
			//if the dp has not changed (some code fired the set with out changing source)
			// we do not need to run the resetFilters
			var b:Boolean = true;
			if(super.dataProvider &&  super.dataProvider.source == value){
				b = false;
			}
			super.dataProvider = value;
			if(b){
				this.resetFilters(filterFunction);
			}
			//(dataProvider as ICollectionView).filterFunction = filterFunction;
			//(dataProvider as ICollectionView).refresh();
		}
		
		private function onColumnStretch(event:DataGridEvent) : void {
			_columnsAdjusted = true;
		}		
		private var _columnsAdjusted : Boolean = false;
		
		/**
		 * @private
		 * Storage for the columnWidths property.
		 */
		private var _columnWidths : Array = new Array();
		
		/**
		 * @private
		 */
		private var _columnWidthsChanged : Boolean = false;
		
		/**
		 * @private
		 * Stores the explicit width portions of the column widths.
		 */
		private var _explicitColWidths : Object;
		
		/**
		 * @private
		 * Stores the percentage width portions of the column widths.
		 */
		private var _percentColWidths : Object;
		
		//--------------------------------------
		//   Getters / Setters 
		//--------------------------------------
		
		public function get columnWidths() : Array {
			return _columnWidths;
		}

		public function set columnWidths(values : Array) : void {
			if (_columnWidths != values) {
				_columnWidths = values;
				_columnWidthsChanged = true;
				invalidateProperties();
				invalidateDisplayList();
			}
		}
		
		override protected function commitProperties() : void {
			super.commitProperties();
			if (_columnWidthsChanged) {
				splitPercentWidths(columnWidths);
				_columnWidthsChanged = false;
			}
		}
		
		override protected function updateDisplayList(unscaledWidth : Number, unscaledHeight : Number) : void {
			// Determine how much width is left over for percentage calculations after the fixed
			// widths are allocated.
			var leftoverWidth : Number = unscaledWidth;
			
			for each (var explicitColWidth : Number in _explicitColWidths) {
				leftoverWidth -= explicitColWidth;
			}
			
			// Manually adjust the column width before doing super.updateDisplayList. This way when 
			// super.updateDisplayList is called, it can perform any minor adjustments to the columns, 
			// but the column widths will still be pretty consistant with the specified widths.
			if (columns && columnWidths && !_columnsAdjusted && columns.length == columnWidths.length) {
				for (var i : int = 0; i < columnWidths.length; i++) {
					var w : Number = 0;
					
					if (_explicitColWidths[i]) {
						w = _explicitColWidths[i];
					}
					else {
						w = leftoverWidth * (_percentColWidths[i] / 100);
					}
					
					// Adjust the column's width. After digging through the DataGridColumn, I found 
					// 3 different properties that need to be set to override the default column width 
					// calculations performed by DataGrid and DataGridColumn. They are _width (changed 
					// in the setWidth method), explicitWidth, and preferredWidth.
					columns[i].setWidth(w);
					columns[i].explicitWidth = w;
					columns[i].preferredWidth = w;
				}
			}
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
		}
		private function splitPercentWidths(values : Array) : void {
			if (columns && columnWidths && columnWidths.length > 0) {
				_percentColWidths = new Object();
				_explicitColWidths = new Object();
				
				for (var i : uint = 0; i < columnWidths.length; i++) {
					var columnWidth : String = columnWidths[i] + "";
					
					// If columnWidth contains a '%' then it is a percentage width, otherwise
					// it is an explicit width.
					if (columnWidth.indexOf("%") == -1) {
						_explicitColWidths[i] = Number(columnWidth);
					}
					else {
						_percentColWidths[i] = Number(columnWidth.substr(0, columnWidth.length - 1));
					}
				}
			}
		}		
		
		private function  onFilterChange(event:Event):void
		{
			if(dataProvider)
				(dataProvider as ICollectionView).refresh();
			selectedIndex = 0;
			//Tim Ford - Label 31469: Upload & History eInvoice tab filter
			//had to add this code so that first entry gets selected in upload history grid
			if (event.target.dataProvider && event.target.dataProvider.length && this.id == 'dgBBUploadHistory'){
				this.parentDocument.pModel.selectHistory(event.target.dataProvider[0]);
			}
			var e:MainEvent = new MainEvent(MainEvent.FILTER_DATAGRID_COMPLETE);
			e.sState = 'SNAPPY';
			this.dispatcher.dispatchEvent(e);
		}
		
		public function resetFilters(inFilterFunction:Function = null):void
		{
			
			if(inFilterFunction == null)
			{
				clearHeaderFilterEditText();
	  		}
			if(dataProvider)
			{
				(dataProvider as ICollectionView).filterFunction = filterFunction;//inFilterFunction;
				(dataProvider as ICollectionView).refresh();
				//displayHeaderFilterOptions((dataProvider as ICollectionView).length > 0);
			}
			selectedIndex = 0;
			
		}
		
		private function clearHeaderFilterEditText():void{
			var iLen:int= columnCount;
			for(var i:int=0;i<iLen;i++)
			{
				var dgc:DataGridColumn = columns[i] as DataGridColumn;
				if(dgc is DataGridFilterColumn)
				{
					DataGridFilterColumn(dgc).filterText = "";
					DataGridFilterColumn(dgc).editText = "";
				}	
			}
		}
		
		/* click handler for turning the show/hide of th efilter and edit options in the header renderer */
		public function displayHeaderOptions(bFilter:Boolean = true,bEdit:Boolean = false):void{
			//var ac:ArrayCollection = dg.dataProvider as ArrayCollection;
			//ac.disableAutoUpdate();
			//setters will call applyHeaderOptions
			this.filterVisible	= bFilter;
			this.editVisible	= bEdit;

		}
		
		public function applyHeaderOptions():void{
			//var ac:ArrayCollection = dg.dataProvider as ArrayCollection;
			//ac.disableAutoUpdate();
			for each(var c:DataGridColumn in this.columns){
				var dgc:DataGridColumn = c as DataGridColumn;
				var dField:String = dgc.dataField;
				if(dgc is DataGridFilterColumn == false  && dgc is DataGridFilterColumnMultiSelect == false)
					continue;
				if(dgc is DataGridFilterColumn){
					DataGridFilterColumn(dgc).filterVisible = this.filterVisible;
					DataGridFilterColumn(dgc).editVisible = this.editVisible;
				}
				else if(dgc is DataGridFilterColumnMultiSelect){
					DataGridFilterColumnMultiSelect(dgc).filterVisible = this.filterVisible;
					DataGridFilterColumnMultiSelect(dgc).editVisible = this.editVisible;
				}
			}
			/* 
				The below code was resetting the filters upon checking and unchecking the
				filter checkbox earlier. Now only the filter headers will toggle when the 
				filter checkbox is clicked.
			*/ 
			/*
			if(!this.filterVisible){
				this.resetFilters();
			}
			*/
		}
		

		private function setFiltersDataProvider():void{
			
			
		}
		
		/*private function keyHandler(event:KeyboardEvent):void {
			Alert.show(event.keyCode + "/" + event.charCode);
		}*/
		
		private function keyHandler(event:KeyboardEvent):void
		{
			if(this.bAllowDelete && event.keyCode == 46 && event.charCode == 127 && event.target.className == 'FilterDatagrid')
			{
				//var data:ArrayCollection = dataProvider as ArrayCollection;
				deleteRow();
			}
		}
		
		private function deleteHandler(event:MainEvent):void
		{
			//var data:ArrayCollection = dataProvider as ArrayCollection;
			//deleteRow(event.iNum);
			//this._dispatcher.dispatchEvent(event);
			//event.stopPropagation();
		}
		
		private function deleteRow(iRowIndex:int = -1):void
		{
			var winAlert:Alert;
			//var data:ArrayCollection = dataProvider as ArrayCollection;
			if(iRowIndex != -1){
				this.selectedIndices[0] = iRowIndex;
				this.selectedIndex = iRowIndex;
			}
			if(this.selectedIndices.length > 0)
			{
				var s:String = "Delete Record?";
			 	if(this.selectedIndices.length > 1){
					s = "Delete " + this.selectedIndices.length.toString() + " Records?";
				}
				winAlert = Alert.show(s, "Confirm",
					Alert.OK | Alert.CANCEL, this,
					alertListener, null, Alert.OK)	
					var newX:Number = 550;
					var newY:Number = 300;
					/* Without "validateNow()", the positioning of the "Alert" window does not happen when the 
					   user deletes for the first time. Second time onwards, it does work.				   
					*/
					winAlert.validateNow();
					/* Without "callLater", the positioning does not work */
					callLater(winAlert.move,[newX, newY]);
			}
			else{
				Alert.show("Please select a row to delete", "Delete Alert");
			}
		}
		
		private function alertListener(eventObj:CloseEvent):void {
			// Check to see if the OK button was pressed.
			if (eventObj.detail==Alert.OK) {
				var evt:MainEvent = new MainEvent(MainEvent.DELETE_ROW);
				var dp:ArrayCollection = this.dataProvider as ArrayCollection;
				for each(var obj:Object in this.selectedItems){
					//dispatch to Mate
					evt.objRowData = obj;
					this._dispatcher.dispatchEvent(evt);
					//remove item
					var i:int = dp.getItemIndex(obj);
					dp.removeItemAt(i);
				}				
				
			}
		}
		
		public static function isDate( value:String ):Boolean {
			return Date.parse( value ) > 0;
		}
		
		public function filterFunction(inObject:Object):Boolean
		{
			var iLen:int= columnCount;
			_dtFormatDateTime.formatString 	= 'MM/DD/YYYY L:NN A';
        	for(var i:int=0;i<iLen;i++)
        	{
        		var dgc:DataGridColumn = columns[i] as DataGridColumn;
        		var dField:String = dgc.dataField;
			    if(dgc is DataGridFilterColumn == false  && dgc is DataGridFilterColumnMultiSelect == false)
			    	continue;
				if(dgc is DataGridFilterColumn){
					var srchStr:String =  DataGridFilterColumn(dgc).filterText;
					var x:Boolean = filterInsert(inObject);
					if(srchStr == "" && filterInsert(inObject))
						continue;
					var dataStr:String;// = dgc.itemToLabel(inObject).toLowerCase();
					//Handle complex objects
					var arr:Array;
					arr = dgc.dataField.toString().split(".");
					if(arr.length == 1){
						dataStr = inObject[arr[0]];
					}
					else if(arr.length == 2 && inObject[arr[0]]){
						dataStr = inObject[arr[0]][arr[1]];
					}
					else if(arr.length == 3 && inObject[arr[0]] && inObject[arr[1]]){
						dataStr = inObject[arr[0]][arr[1]][arr[2]];
					}
					/* 
						D30723: Flex BB Upload and Corrections page changes/05-Mar-2012
						Added checking to see if the value is a date and then format it as
						the format was different in the Grid from the array so the filter was not
						working on dates.
					*/
					if (isDate(dataStr))
					{
						dataStr = this._dtFormatDateTime.format(dataStr); 
					}
					//check the filter textInput from the header as well as the Filter func passed in
					//iff either fail, return false -> item is not visible
					
					var b:* = filterInsert(inObject);
					var bFilterltInsert:Boolean = filterInsert(inObject);
					var iIndex:int = dataStr.toLowerCase().indexOf(srchStr.toLowerCase());
					if((iIndex) == -1 || !bFilterltInsert){
						return false;
					}
				}
				else if(dgc is DataGridFilterColumnMultiSelect){
					var dgcm:DataGridFilterColumnMultiSelect = DataGridFilterColumnMultiSelect(dgc);
					var arrFilters:Array = dgcm.filterArray;
					if(!arrFilters.length && filterInsert(inObject))
						continue;
					for each(var o:* in arrFilters){			
						if(o == dgc.itemToLabel(inObject)){
							return true;
						}
					}
					return false;
				}
			    
        	}
        	return true;
		}
		
	}
}