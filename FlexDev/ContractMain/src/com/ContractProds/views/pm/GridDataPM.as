package com.ContractProds.views.pm
{
	import com.ContractProds.components.*;
	import com.ContractProds.events.ComponentEvent;
	import com.ContractProds.events.SearchEvent;
	import com.ContractProds.models.ComponentManager;
	import com.ContractProds.vos.Component;
	import com.ContractProds.vos.FilterParms;
	import com.ContractProds.vos.Item;
	import com.ContractProds.vos.Uom;
	import com.shared.vos.Settings;
	
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
		[Bindable] public var items:ArrayCollection = new ArrayCollection();
		[Bindable] public var sRecordMessage:String = "";
		[Bindable] public var statusFilterOn:int = 0;
		/* bound from componentManager -> the show hide check box */
		[Bindable] public var bShowFixed:Boolean;
		[Bindable] public var bShowRebate:Boolean;
		/* Settings Object */
		private var _oSettings:Settings = new Settings();
		[Bindable (event="pmsettingsChanged")]
		public function get oSettings():Settings
		{
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
	 		event.preventDefault();              
	 		if (event.keyCode == Keyboard.ENTER) 
	 		/* ITEM_DOUBLE_CLICK calls selectRow()   */  
	 		selectRow(event);              
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
   
		/*  update oFilterParms.bfilterRates*/
		public function updateBfilterRates(  value:Boolean):void
		{
			this._oFilterParms.bfilterRates = value;
			//this.save();
			var e:SearchEvent = new SearchEvent(SearchEvent.SAVE_FILTER_PARMS);
				e.oFilterParms = this._oFilterParms;
				this.dispatcher.dispatchEvent(e);
				dispatchEvent(new Event('pmGFilterParmsChanged'));
			/* set the data we need to pass to Filter Function Event */
			var evt:SearchEvent = new SearchEvent(SearchEvent.FILTER);
				evt.oFilterParms = this.oFilterParms;
				/* dispatch the event */
           		this.dispatcher.dispatchEvent(evt);
		}
		
		/*  update oFilterParms.bfilterVarianceMP*/
		public function updateBfilterVarianceMP(  value:Boolean):void
		{
			this._oFilterParms.bfilterVarianceMP = value;
			//this.save();
			var e:SearchEvent = new SearchEvent(SearchEvent.SAVE_FILTER_PARMS);
			e.oFilterParms = this._oFilterParms;
			this.dispatcher.dispatchEvent(e);
			dispatchEvent(new Event('pmGFilterParmsChanged'));
			/* set the data we need to pass to Filter Function Event */
			var evt:SearchEvent = new SearchEvent(SearchEvent.FILTER);
			evt.oFilterParms = this.oFilterParms;
			/* dispatch the event */
			this.dispatcher.dispatchEvent(evt);
		}
		/*  update oFilterParms.bfilterVarianceMP*/
		public function updateBfilterMP(  value:Boolean):void
		{
			this._oFilterParms.bfilterMP = value;
			//this.save();
			var e:SearchEvent = new SearchEvent(SearchEvent.SAVE_FILTER_PARMS);
			e.oFilterParms = this._oFilterParms;
			this.dispatcher.dispatchEvent(e);
			dispatchEvent(new Event('pmGFilterParmsChanged'));
			/* set the data we need to pass to Filter Function Event */
			var evt:SearchEvent = new SearchEvent(SearchEvent.FILTER);
			evt.oFilterParms = this.oFilterParms;
			/* dispatch the event */
			this.dispatcher.dispatchEvent(evt);
		}
		/* ................itemEditEnd  .................*/   
		public function itemEditEnd(event:AdvancedDataGridEvent):void
		{
			var s:String = '';
				s = event.dataField;
			var item:Item = event.currentTarget.itemEditorInstance.listData.item as Item;
			var adg:AdvancedDataGrid = event.currentTarget.itemEditorInstance.listData.owner as AdvancedDataGrid;
			var scroll:int= adg.verticalScrollPosition;
			var selIdx:int= adg.selectedIndex;
			
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