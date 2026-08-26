package com.ContractProds.views.pm
{
	import com.ContractProds.events.ComponentEvent;
	import com.ContractProds.events.SearchEvent;
	import com.ContractProds.models.ComponentManager;
	import com.shared.components.filters.AdvancedDataGridFilterColumn;
	import com.shared.components.filters.FilterAdvancedDatagrid;
	import com.shared.vos.Component;
	import com.shared.vos.FilterParms;
	import com.shared.vos.Item;
	import com.shared.vos.Program;
	import com.shared.vos.Settings;
	import com.shared.vos.Uom;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import mx.collections.ArrayCollection;
	import mx.controls.AdvancedDataGrid;
	import mx.controls.Alert;
	import mx.controls.ComboBox;
	import mx.controls.TextInput;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.core.ClassFactory;
	import mx.events.AdvancedDataGridEvent;
	import mx.events.DataGridEvent;
	import mx.events.FlexEvent;
	import mx.events.ItemClickEvent;
	import mx.events.ListEvent;
	import mx.formatters.CurrencyFormatter;
	import mx.formatters.NumberFormatter;
	import mx.utils.ObjectUtil;
	
	[Bindable]
	public class GridDataPM extends EventDispatcher
	{
		/*.......................  Constructor  .......................*/
		private var dispatcher:IEventDispatcher;
		public function GridDataPM( dispatcher:IEventDispatcher ):void
		{
			this.dispatcher = dispatcher;
		}
		
		/*.......................  Properties  .......................*/
		
		/* boound from searchManager.itemList -> dp for grid */
		public var items:ArrayCollection = new ArrayCollection();
		public var sRecordMessage:String = "";
		public var statusFilterOn:int = 0;
		private var _arrProductStatus = new Array('All Status','Active','In-Active');
		/* bound from componentManager -> the show hide check box */
		public var bShowFixed:Boolean;
		public var bShowRebate:Boolean;
		//[Bindable] public var funcFilterInsert:Function;
		/*.................funcFilterInsert......................*/
		private var _funcFilterInsert:Function = function(inObject:Object):Boolean{return true;};
		[Bindable (event="funcFilterInsertChangePM")]
		public function get funcFilterInsert():Function
		{
			return _funcFilterInsert;
		}
		public function set funcFilterInsert(func:Function):void
		{
			this._funcFilterInsert = func;
			dispatchEvent(new Event('funcFilterInsertChangePM'));
		}
		/* Settings Object */
		private var _oSettings:Settings = new Settings();
		[Bindable (event="pmsettingsChanged")]
		public function get oSettings():Settings
		{
			this.arrProductStatus = _arrProductStatus;
			return _oSettings;
		}
		public function set oSettings(s:Settings):void
		{
			this._oSettings = s;			
			dispatchEvent(new Event('pmsettingsChanged'));
		}
		
		/* arrDgItemsCols bound to dgItems.columns */
		private var _arrDgItemsCols:Array = new Array();
		[Bindable (event="arrDgItemsColsChangedPM")]
		public function get arrDgItemsCols():Array
		{
			return _arrDgItemsCols;
		}
		public function set arrDgItemsCols(arr:Array):void
		{
			this._arrDgItemsCols = arr;
			dispatchEvent(new Event('arrDgItemsColsChangedPM'));
		}
		/*  FilterParms */
		private var _oFilterParms:FilterParms = new FilterParms();
		[Bindable (event="pmGFilterParmsChanged")]
		public function get oFilterParms():FilterParms
		{
			return _oFilterParms;
		}
		public function set oFilterParms(f:FilterParms):void
		{
			this._oFilterParms = f;
			dispatchEvent(new Event('pmGFilterParmsChanged'));
		}
		
		[Bindable (event="updProductStatusEvent")]
		public function get arrProductStatus():Array
		{	return _arrProductStatus; }
		
		public function set arrProductStatus(a:Array):void
		{   /* If "search inactive products" setting is OFF, remove "inactive products". */
			if(statusFilterOn == 0)
			{
				this._arrProductStatus = a.splice(0,2);
			}
			else{
				this._arrProductStatus = a;
			}
			dispatchEvent(new Event('updProductStatusEvent'));
		}
		
		/* Program */
		private var _program:Program = new Program();
		[Bindable (event="GDPMProgramChange")]
		public function get program():Program
		{
			return _program;
		}
		public function set program(prg:Program):void
		{
			this._program = prg;
			dispatchEvent(new Event('GDPMProgramChange'));
		}
		/*.......................  Methods  .......................*/
		/* Handle datagrid row double click (or enter key) -> toggle isSelected value for All selected Rows */
		public function selectRow(event:*):void
		{
			/* Loop over selectedItems array (mx.controls.listClasses.ListBase) */
			var arrSelectedRows:Array = event.currentTarget.selectedItems;
			for each(var item:Object in arrSelectedRows)
			{
				item.isSelected = !item.isSelected;
			}
		}
		
		/*  handler for when a user presses enter on a DG row */
		public function enterRow(event:KeyboardEvent):void 
		{  
			//event.preventDefault();              
			if (event.keyCode == Keyboard.ENTER) {
				//if the enter came from the grid AND The user was not in an Editable col (rate or UOM)
				var afdg:FilterAdvancedDatagrid = event.currentTarget as FilterAdvancedDatagrid;
				var ti:TextInput = event.target.owner as TextInput;
				var cbx:ComboBox = event.target as ComboBox;
				if(afdg && !ti && !cbx){
					/* ITEM_DOUBLE_CLICK calls selectRow()   */  
					selectRow(event); 
				}
			}
			
			//dgItems.dispatchEvent(new ListEvent(ListEvent.ITEM_DOUBLE_CLICK));
		}
		
		
		/* Handle when user hits enter key on a form element -> dispatch the click event for the element */
		public function enterButton(event:KeyboardEvent):void 
		{                
			if (event.keyCode == Keyboard.ENTER)
			{
				// Create new event object.
				var mev:MouseEvent = new MouseEvent(MouseEvent.CLICK);
				// Dispatch click event to the target of original keydown event.
				event.currentTarget.dispatchEvent(mev);                 
			}
		}
		
		/* Handle when user hits enter key on a checkbox */
		public function enterCheckBox(event:KeyboardEvent):void 
		{                
			if (event.keyCode == Keyboard.ENTER)
			{
				// Create new event object.
				var mev:MouseEvent = new MouseEvent(MouseEvent.CLICK);
				// Dispatch click event to the target of original keydown event.
				event.currentTarget.selected = !event.currentTarget.selected;                 
			}
		}
		
		public function Call_Sort_Data(evt:AdvancedDataGridEvent):void {
			/* Reset the scrollbar position to the top. */
			var e:SearchEvent = new SearchEvent(SearchEvent.RESET_SCROLLBAR_POSITION);
			this.dispatchEvent(e);
		}
		
		/* Handle when user hits enter key on a form element -> dispatch the click event for the element */
		public function reset():void 
		{                
			
			var e:SearchEvent = new SearchEvent(SearchEvent.RESET_FILTER);
			this.dispatcher.dispatchEvent(e);
		}
		/*  update oFilterParms.bfilterRates*/
		public function updateBfilterRates(  b:Boolean):void
		{
			this._oFilterParms.bfilterRates = b;
			//this.save();
			this.filter();
		}
		
		//Filter Selected Items
		public function updateBfilterSelected(b:Boolean):void
		{
			this._oFilterParms.bfilterSelected = b;
			//this.save();
			this.filter();
		}
		
		/*  update oFilterParms.bfilterVarianceMP*/
		public function updateBfilterVarianceMP(  b:Boolean):void
		{
			this._oFilterParms.bfilterVarianceMP = b;
			//this.save();
			this.filter();
		}
		/*  update oFilterParms.bfilterVarianceMP*/
		public function updateBfilterMP(  b:Boolean):void
		{
			this._oFilterParms.bfilterMP = b;
			//this.save();
			this.filter();
		}
		//Filter Items
		public function updateBfilterItems(event:Event):void
		{
			this._oFilterParms.bfilterA = event.currentTarget.selected;
			//this.save();
			this.filter();
		}
		//Filter Groups
		public function updateBfilterGroups(event:Event):void
		{
			this._oFilterParms.bfilterB = event.currentTarget.selected;
			//this.save();
			this.filter();
		}
		
		//Filter 'NONE'
		public function updateBfilterNone(event:Event):void
		{
			this._oFilterParms.bfilterC = event.currentTarget.selected;
			//this.save();
			this.filter();
		}
		public function updateBfilterEz(  b:Boolean):void
		{
			this._oFilterParms.bfilterEz = b;
			//this.save();
			this.filter();
		}
		public function updateFilterProductStatus(  o:Object):void
		{
			var s:String = o as String;
			/*	if(s.indexOf('All') == -1){
			this._oFilterParms.sfilterProductStatus = s;
			}
			else{
			this._oFilterParms.sfilterProductStatus = '';
			}*/
			this._oFilterParms.sfilterProductStatus = s;
			this.filter();
		}
		/*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx*/
		
		private function save():void{
			var e:SearchEvent = new SearchEvent(SearchEvent.SAVE_FILTER_PARMS);
			e.oFilterParms = this._oFilterParms;
			this.dispatcher.dispatchEvent(e);
			dispatchEvent(new Event('pmGFilterParmsChanged'));
			
		}
		
		private function filter():void{
			//save first
			this.save();
			/* set the data we need to pass to Filter Function Event */
			var evt:SearchEvent = new SearchEvent(SearchEvent.FILTER);
			evt.oFilterParms = this.oFilterParms;
			/* dispatch the event */
			this.dispatcher.dispatchEvent(evt);
		}
		
		/*  update oFilterParms.bfilterRates*/
		public function setBfilterRates(  b:Boolean):void
		{
			this._oFilterParms.bfilterRates = b;
			this.save();
			
		}
		
		/*  update oFilterParms.bfilterRates*/
		public function setBfilterSelected(  b:Boolean):void
		{
			this._oFilterParms.bfilterSelected = b;
			this.save();
			
		}
		
		/*  update oFilterParms.bfilterVarianceMP*/
		public function setBfilterVarianceMP(  b:Boolean):void
		{
			this._oFilterParms.bfilterVarianceMP = b;
			this.save();
			
		}
		/*  update oFilterParms.bfilterVarianceMP*/
		public function setBfilterMP(  b:Boolean):void
		{
			this._oFilterParms.bfilterMP = b;
			this.save();
			
		}
		//Filter Items
		public function setBfilterItems(b:Boolean):void
		{
			this._oFilterParms.bfilterA = b;
			this.save();
			
		}
		//Filter Groups
		public function setBfilterGroups(b:Boolean):void
		{
			this._oFilterParms.bfilterB = b;
			this.save();
			
		}
		//Filter 'NONE'
		public function setBfilterNone(b:Boolean):void
		{
			this._oFilterParms.bfilterC = b;
			this.save();
			
		}
		
		/*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx*/
		
		
		/* ................itemEditEnd  .................*/   
		public function itemEditEnd(event:AdvancedDataGridEvent):void
		{
			var s:String = '';
			s = event.dataField;
			var item:Item = event.currentTarget.itemEditorInstance.listData.item as Item;
			var adg:FilterAdvancedDatagrid = event.currentTarget.itemEditorInstance.listData.owner as FilterAdvancedDatagrid;
			var scroll:int= adg.verticalScrollPosition;
			var selIdx:int= adg.selectedIndex;
			var prodRate:*;
			/* if we just edited a rate or UOM from an itemeditor -> update the component data */
			if(event.currentTarget.itemEditorInstance.hasOwnProperty('txtInp')){
				s = s.replace('.prodRate.rate','');
				var txtInp:TextInput = event.currentTarget.itemEditorInstance.txtInp;
				var evt:ComponentEvent = new ComponentEvent(ComponentEvent.SET_RATE);
				evt.item = item;
				evt.sId = s;
				evt.sRate = txtInp.text;
				this.dispatcher.dispatchEvent(evt);
				/* refresh will display the updated variances, but if there is an active SORT on then the data gets 
				resorted and it is not cool for the user*/
				adg.validateNow();
				adg.selectedItem = item;
				adg.verticalScrollPosition = scroll;
			}
			else if(event.currentTarget.itemEditorInstance.hasOwnProperty('txtInpCust')){
				var sProp:String = adg.columns[event.columnIndex].dataFieldComplex;
				var txtInpCust:TextInput = event.currentTarget.itemEditorInstance.txtInpCust;
				prodRate = item[s]["prodRate"];//["rateCust_" + sProp];
				//ALREADY SET IN itemEditor	prodRate["rateCust_" + sProp] = txtInpCust.text;
				//ADD it To Component
				var eCustRate:ComponentEvent = new ComponentEvent(ComponentEvent.SET_RATE);
				eCustRate.item = item;
				eCustRate.sId = s;
				eCustRate.sRate = txtInpCust.text;
				this.dispatcher.dispatchEvent(eCustRate);
				/* refresh will display the updated variances, but if there is an active SORT on then the data gets 
				resorted and it is not cool for the user*/
				adg.validateNow();
				adg.selectedItem = item;
				adg.verticalScrollPosition = scroll;
			}
			else if(event.currentTarget.itemEditorInstance.hasOwnProperty('cboUom')){
				s = s.replace('.prodRate.uom','');
				var cboUom:ComboBox = event.currentTarget.itemEditorInstance.cboUom;
				var e:ComponentEvent = new ComponentEvent(ComponentEvent.SET_UOM);
				e.item = item;
				e.sId = s;
				e.uom = cboUom.selectedItem as Uom;
				this.dispatcher.dispatchEvent(e);
				/* refresh will display the updated variances, but if there is an active SORT on then the data gets 
				resorted and it is not cool for the user*/
				adg.validateNow();
				adg.selectedItem = item;
				adg.verticalScrollPosition = scroll;
			}else if(s == 'volume'){
				//event.currentTarget.itemEditorInstance.text = event.currentTarget.itemEditorInstance.listData.item[s];
				var evtVol:ComponentEvent = new ComponentEvent(ComponentEvent.SET_VOL);
				evtVol.item = item;
				evtVol.nRate = Number(event.currentTarget.itemEditorInstance.text.replace(',','')) as Number;
				evtVol.adg = adg;
				this.dispatcher.dispatchEvent(evtVol);
				
			}
			
			// Get the cell editor and cast it to TextInput.
			/*  
			// Get the old value.
			var oldVal:String = 
			event.currentTarget.editedItemRenderer.data[event.data Field];*/
		}
		/* ................  .................*/   
		public function addComponent(comp:Component):void
		{
			
		}
		/* ................  .................*/
		public function deleteComponent(comp:Component):void
		{
			
		}
		public function rateLabelFunction(i:Item,varName:String):String
		{
			return i.prodRate[varName];
		}
		/* public function getUomLabel(i:Item):String{
		return i.ComboBoxContent.
		} */
		/* format the grid cols */
		
	}
}