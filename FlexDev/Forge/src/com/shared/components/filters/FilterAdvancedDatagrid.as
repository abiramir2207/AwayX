package com.shared.components.filters
{
	
	import com.shared.components.filters.header.AdvancedDataGridFilterHeader;
	import com.shared.components.mx.AdvancedDataGridBa;
	import com.shared.events.MainEvent;
	import com.shared.vos.FilterParms;
	import com.shared.vos.Settings;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.controls.AdvancedDataGrid;
	import mx.controls.Alert;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.core.FlexGlobals;
	import mx.core.mx_internal;
	import mx.events.CloseEvent;
	import mx.events.CollectionEvent;
	import mx.utils.ObjectUtil;
	
	
	use namespace mx_internal;
	
	public class FilterAdvancedDatagrid extends AdvancedDataGridBa
	{
		
		private var _filterInsert:Function = function(inObject:Object):Boolean{return true;};
		[Bindable (event="filterInsertChanged")]
		public function get filterInsert():Function{
			return _filterInsert;
		}
		public function set filterInsert(fn:Function):void{
			_filterInsert = fn;
			dispatchEvent(new Event('filterInsertChanged'));
			dispatchEvent(new Event('filterEvent'));
		}
		
		/*  FilterParms From FilterPM*/
		private var _oFilterParms:FilterParms = new FilterParms();
		[Bindable (event="pmFilterParmsChanged")]
		public function get oFilterParms():FilterParms
		{
			return _oFilterParms;
		}
		public function set oFilterParms(f:FilterParms):void
		{
			this._oFilterParms = f;
			dispatchEvent(new Event('pmFilterParmsChanged'));
		}
		
		/* Settings Object */
		private var _oSettings:Settings = new Settings();
		[Bindable (event="fasettingsChanged")]
		public function get oSettings():Settings
		{
			return _oSettings;
		}
		public function set oSettings(s:Settings):void
		{
			this._oSettings = s;
			dispatchEvent(new Event('fasettingsChanged'));
		}
		
		
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
			
			//tried this in constructor but custom property [_dispatcher] was not set yet
			var evt:MainEvent = new MainEvent(MainEvent.SEND_REFERENCE);
			evt.fadg = this;
			this.dispatcher.dispatchEvent(evt)
		}
		
		/*........ Value gets passed down to AdvancedDataGridColumn [same property name] Show Hide the FILTER textinput in the header ..........*/
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
		/*........ Value gets passed down to AdvancedDataGridColumn [same property name] Show Hide the EDIT textinput in the header ..........*/
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
		/*
		override public function set columns(value:Array):void{
			super.columns = value;
			this.applyHeaderOptions();
		}
		
		override public function set rowCount(value:int):void{
			super.rowCount = value;
		}
		*/
		/*...........................................*/
		/*................  METHODS  ................*/
		/*...........................................*/

		public function FilterAdvancedDatagrid():void
		{
			super();
			addEventListener("filterEvent",onFilterChange);
			addEventListener("editEvent",onEditChange);
			this.rowHeight = 19;
			this.headerWordWrap = true;
			
			
		}
		
		override public function set dataProvider(value:Object):void
		{
			//if(dataProvider)
			//	resetFilters();
			resetFilters(filterFunction);
			super.dataProvider = value;
			if(dataProvider){
				dataProvider.toArray().forEach(getUniqueFilters);
			}
			super.dataProvider.filterFunction = filterFunction;
		}
		/*override protected function drawRowBackground(s:Sprite, rowIndex:int, y:Number, height:Number, color:uint, dataIndex:int):void{
			var o:Object = rowNumberToData(dataIndex);
			if(o && o.hasOwnProperty('bError') && o.bError == true){
				color = 0xFF6F6F;
			}
			
			super.drawRowBackground(s,rowIndex,y,height,color,dataIndex);
		}*/
		
		override protected function columnDraggingMouseMoveHandler(event:MouseEvent):void{
			if(event.target.hasOwnProperty('owner') && event.target.owner.id && event.target.owner.id.toString().indexOf('tifilterheader') == -1){
				super.columnDraggingMouseMoveHandler(event);
			}
		}
		
		override protected function drawItem(item:IListItemRenderer,
											 selected:Boolean = false,
											 highlighted:Boolean = false,
											 caret:Boolean = false,
											 transition:Boolean = false):void
		{
			if (!item)
				return;
			if (rowMap[item.name] == null)
				return;
			
			super.drawItem(item, selected, highlighted, caret, transition);
			
			var rowIndex:int = rowMap[item.name].rowIndex;
			var optimumColumns:Array = getOptimumColumns();
			var n:int = optimumColumns.length;
			for (var i:int = 0; i < n; i++)
			{
				var r:IListItemRenderer = listItems[rowIndex][i];
				if(r){
					r.validateDisplayList();
					updateDisplayOfItemRenderer(r);
				}
			}
		}
		private function  onFilterChange(event:Event):void
		{
			if(dataProvider){
				this.anchorBookmark = null;
				var icv:ICollectionView = dataProvider as ICollectionView;
				(icv).refresh();
				dispatchEvent(new Event(CollectionEvent.COLLECTION_CHANGE));
				//selectedIndex = -1;
				dataProvider.toArray().forEach(getUniqueFilters);
			}
		}
		
		private function  onEditChange(event:Event):void
		{
			if(dataProvider){
				(dataProvider as ICollectionView).refresh();
				dataProvider.toArray().forEach(getUniqueFilters);
			}
		}
		
		public function resetFilters(inFilterFunction:Function = null):void
		{
			
			if(inFilterFunction == null)
			{
				var iLen:int= columnCount;
	        	for(var i:int=0;i<iLen;i++)
	        	{
	        		var dgc:AdvancedDataGridColumn  = columns[i] as AdvancedDataGridColumn ;
	        		if(dgc is AdvancedDataGridFilterColumn)
	        		{
						AdvancedDataGridFilterColumn(dgc).filterText = "";
						AdvancedDataGridFilterColumn(dgc).editText = "";
						AdvancedDataGridFilterColumn(dgc).filterComboSelectedIndex = 0;
						AdvancedDataGridFilterColumn(dgc).filterComboText = '';
	        		}	
	        	}
	  		}
			if(dataProvider)
			{
				(dataProvider as ICollectionView).filterFunction = filterFunction;//inFilterFunction;
				(dataProvider as ICollectionView).refresh();
				dispatchEvent(new Event(CollectionEvent.COLLECTION_CHANGE));
				this.validateNow();
				//displayHeaderFilterOptions((dataProvider as ICollectionView).length > 0);
			}
			selectedIndex = 0;
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
			for each(var c:AdvancedDataGridColumn in this.columns){
				var dgc:AdvancedDataGridColumn = c as AdvancedDataGridColumn;
				var dField:String = dgc.dataField;
				if(dgc is AdvancedDataGridFilterColumn == false)
					continue;
				if(dgc is AdvancedDataGridFilterColumn){
					AdvancedDataGridFilterColumn(dgc).filterVisible = this.filterVisible;
					AdvancedDataGridFilterColumn(dgc).editVisible = this.editVisible;
				}
			}
			if(!this.filterVisible){
				this.resetFilters();
			}
		}
		

		private function setFiltersDataProvider():void{
			
			
		}
		
		//Cache scroll position
		private var scroll:int;
		private var selIdx:int;
		public function saveScrollPos():void{
			scroll = this.verticalScrollPosition;
			selIdx = this.selectedIndex;
		}
		//set scroll back to cache position
		public function setScrollPos():void{
			this.selectedIndex  = selIdx;
			this.verticalScrollPosition = scroll;
		}
		
		private function keyHandler(event:KeyboardEvent):void
		{
			if(this.bAllowDelete && event.keyCode == 46 && event.charCode == 127 && event.target.className == 'FilterAdvancedDatagrid')
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
		
		private function filterFunction(inObject:Object):Boolean
		{
			var iLen:int= columnCount;
        	for(var i:int=0;i<iLen;i++)
        	{
        		var dgc:AdvancedDataGridFilterColumn = columns[i] as AdvancedDataGridFilterColumn;
			    if(dgc is AdvancedDataGridFilterColumn == false)
			    	continue;
				if(dgc is AdvancedDataGridFilterColumn){
					var srchStr:String =  AdvancedDataGridFilterColumn(dgc).filterText;
					var srchStrCombo:String =  AdvancedDataGridFilterColumn(dgc).filterComboText;
					var x:Boolean = filterInsert(inObject);
					if(srchStr == "" && (srchStrCombo == "" || srchStrCombo == "All") && filterInsert(inObject))
						continue;
					var dataStr:String;// = dgc.itemToLabel(inObject).toLowerCase();
					//Handle complex objects
					var arr:Array;
					arr = dgc.dataField.toString().split(".");
					if(dgc.dataFieldComplex != ''){
						arr = dgc.dataFieldComplex.toString().split(".");
					}
					if(arr.length == 1){
						dataStr = inObject[arr[0]];
					}
					else if(arr.length == 2 && inObject != null && inObject[arr[0]]){
						dataStr = inObject[arr[0]][arr[1]];
					}
					else if(arr.length == 3 && inObject != null && inObject[arr[0]] && inObject[arr[1]]){
						dataStr = inObject[arr[0]][arr[1]][arr[2]];
					}
					//check the filter textInput from the header as well as the Filter func passed in
					//iff either fail, return false -> item is not visible
					var b:* = filterInsert(inObject);
					var bFilterltInsert:Boolean = filterInsert(inObject);
					var iIndex:int = dataStr.toLowerCase().indexOf(srchStr.toLowerCase());
					var iComboIndex:int = dataStr.toLowerCase().indexOf(srchStrCombo.toLowerCase());
					if(srchStrCombo.length != dataStr.length){iComboIndex = -1}
					if(srchStrCombo == "All" || srchStrCombo == ""){iComboIndex = 0}
					//if any scenario is false, this item is filtered out (Text input search, Combo box search, FilterInsert)
					if((iIndex) == -1 || iComboIndex != 0 || !bFilterltInsert){
						return false;
					}
				}
        	}
			var w:* = 0;
        	return true;
		}
		
		/* UPDATE Filter Drop Downs ............................................... */
		private function getUniqueFilters(inObject:*, index:int, arr:Array):void
		{	
			var iLen:int= columnCount;
			for(var i:int=0;i<iLen;i++)
			{
				var dgc:AdvancedDataGridColumn = columns[i] as AdvancedDataGridColumn;
				var dField:String = dgc.dataField;
				if(dgc is AdvancedDataGridFilterColumn == false)
					continue;
				if(dgc is AdvancedDataGridFilterColumn){
					var dgfc:AdvancedDataGridFilterColumn = dgc as AdvancedDataGridFilterColumn;
					if(dgfc.filterComboVisible){
						//clear out old dp on first pass
						if(index == 0){dgfc.filterComboDp.source = new Array()}
						if (dgfc.filterComboDp.length != 0) { 
							if (dgfc.filterComboDp.source.indexOf(inObject[dgfc.dataField])== -1 && inObject[dgfc.dataField] != ''){
								dgfc.filterComboDp.source.push(inObject[dgfc.dataField]);
							}
						}
						else if(inObject[dgfc.dataField] != ''){
							dgfc.filterComboDp.source.push(inObject[dgfc.dataField]);
						}
						//if we are on the last row, add the "all choice to the DP
						if(index == (this.dataProvider.length - 1))
							{
								dgfc.filterComboDp.source.sort();
								dgfc.filterComboDp.source.unshift("All");
								if (dgfc.filterComboText != '' && dgfc.filterComboText != 'All')
									{ dgfc.filterComboSelectedIndex = 1;}
								else
									{dgfc.filterComboSelectedIndex = 0;}
								dispatchEvent(new Event('filterComboSelectedChanged'));
							}
					}	
				}
			}
		
		}
		
		
	}
}