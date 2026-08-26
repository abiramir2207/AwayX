package com.ContractProds.views.pm
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.ui.Keyboard;
	import com.ContractProds.events.SearchEvent;
	import com.shared.vos.Settings;
	import com.shared.vos.FilterParms;
	import mx.collections.ArrayCollection;
	
	public class FilterPM extends EventDispatcher
	{
		/*.......................  Constructor  .......................*/
		private var dispatcher:IEventDispatcher;
		public function FilterPM( dispatcher:IEventDispatcher ):void
		{
			this.dispatcher = dispatcher;
		}
		
		/*.......................  Properties  .......................*/
		/*  dpBrand -> needed to atch updates to the DP so we can reset selected item: setCboSelection() ......*/
		//[Bindable] public var dpBrand:Array = null;
		private var _dpBrand:Array = new Array();
		[Bindable (event="pmdpBrandChanged")]
		public function get dpBrand ():Array
		{
			return _dpBrand;
		}
		public function set dpBrand (arr:Array):void
		{
			this._dpBrand = arr;
			dispatchEvent(new Event('pmdpBrandChanged'));
			/* if a dp changes, update the comboBox selections (after we dispatch the dp update!) ........*/
			if (_oFilterParms.brand != '' &&  _oFilterParms.brand.indexOf('Show All') != 0)
				{ cbBrand = 1;}
			else
				{cbBrand = 0;}
			dispatchEvent(new Event('pmcbBrandChg'));
		}
		
		/** dataprovider for cbQBrand combobox*/
		//[Bindable] public var dpQBrand:Array = null;
		private var _dpQBrand:Array = new Array();
		[Bindable (event="dpQBrandChanged")]
		public function get dpQBrand ():Array
		{
			return _dpQBrand;
		}
		public function set dpQBrand (arr:Array):void
		{
			this._dpQBrand = arr;
			dispatchEvent(new Event('dpQBrandChanged'));
			/* if a dp changes, update the comboBox selections (after we dispatch the dp update!) ........*/
			if (_oFilterParms.qBrand != '' &&  _oFilterParms.qBrand.indexOf('Show All') != 0)
				{ cbQBrand = 1;}
			else
				{cbQBrand = 0;}
			dispatchEvent(new Event('pmcbQBrandChg'));
		}
		/** dataprovider for cbTypeCode combobox*/
		//[Bindable] public var dpTypeCode:Array = null;
		private var _dpTypeCode:Array = new Array();
		[Bindable (event="dpTypeCodeChanged")]
		public function get dpTypeCode ():Array
		{
			return _dpTypeCode;
		}
		public function set dpTypeCode (arr:Array):void
		{
			this._dpTypeCode = arr;
			dispatchEvent(new Event('dpTypeCodeChanged'));
			/* if a dp changes, update the comboBox selections (after we dispatch the dp update!) ........*/
			if (_oFilterParms.typeCode != '' &&  _oFilterParms.typeCode.indexOf('Show All') != 0)
				{ cbTypeCode = 1;}
			else
				{cbTypeCode = 0;}
			dispatchEvent(new Event('pmcbTypeCodeChg'));
		}
		/** dataprovider for cbTypeGroup combobox*/
		//[Bindable] public var dpTypeGroup:Array = null;
		private var _dpTypeGroup:Array = new Array();
		[Bindable (event="dpTGChanged")]
		public function get dpTypeGroup ():Array
		{
			return _dpTypeGroup;
		}
		public function set dpTypeGroup (arr:Array):void
		{
			this._dpTypeGroup= arr;
			dispatchEvent(new Event('dpTGChanged'));
			/* if a dp changes, update the comboBox selections (after we dispatch the dp update!) ........*/
			if (_oFilterParms.typeGroup != '' &&  _oFilterParms.typeGroup.indexOf('Show All') != 0)
				{ cbTypeGroup = 1;}
			else
				{cbTypeGroup = 0;}
			dispatchEvent(new Event('pmCbTypeGroupChg'));
		}
		
		/** dataprovider for cbItemStatusList combobox*/
		//[Bindable] public var dpTypeGroup:Array = null;
		private var _dpItemStatusList:Array = new Array();
		[Bindable (event="dpISLChanged")]
		public function get dpItemStatusList ():Array
		{
			return _dpItemStatusList;
		}
		public function set dpItemStatusList (arr:Array):void
		{
			this._dpItemStatusList= arr;
			dispatchEvent(new Event('dpISLChanged'));
			/* if a dp changes, update the comboBox selections (after we dispatch the dp update!) ........*/
			if (_oFilterParms.lblStatus != '' &&  _oFilterParms.lblStatus.indexOf('Show All') != 0)
				{ cbItemStatusList = 1;}
			else
				{cbItemStatusList = 0;}
			dispatchEvent(new Event('pmCbItemStatusChg'));
		}
		
		/** dataprovider for cbPrgTypesDiscList combobox*/
		[Bindable] public var dpPrgTypesDiscList:Array = null;	
		/** dataprovider for cbItemStatusList combobox*/
		//[Bindable] public var dpItemStatusList:Array = null;			

		[Bindable] public var sRecordMessage:String = "";
		[Bindable] public var iComboBoxHeight:int;
		[Bindable] public var iTextInputHeight:int;
		[Bindable] public var iButtonHeight:int;
		[Bindable] public var bLoadMiniItems:Boolean = false;
		[Bindable] public var statusFilterOn:int = 0;

		[Bindable (event="pmcbBrandChg")]
		public var cbBrand:int = 0;
	    [Bindable (event="pmcbQBrandChg")]
	    public var cbQBrand:int = 0;
	    [Bindable (event="pmcbTypeCodeChg")]
	    public var cbTypeCode:int = 0;
	    [Bindable (event="pmCbTypeGroupChg")]
	    public var cbTypeGroup:int = 0;
	    [Bindable (event="pmCbItemStatusChg")]
	    public var cbItemStatusList:int = 0;
		
		private var searchStrLen:int = 0;
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

		/*  FilterParms */
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

		
		/*.......................  Methods  .......................*/
		/*  update oFilterParms.bfilterMiniItem*/
		public function updateBfilterMiniItem(  value:Boolean):void
		{
			this._oFilterParms.bfilterMiniItem = value;
			this.save();
			this.filterMiniItems();
		}
		/*  update oFilterParms.bfilterSelected*/
		public function updateBfilterSelected(  value:Boolean):void
		{
			this._oFilterParms.bfilterSelected = value;
			this.save();
			//this.filterSelected();
			this.filter()
		}
		
		/*  update oFilterParms.bfilterRates*/
		public function updateBfilterRates(  value:Boolean):void
		{
			this._oFilterParms.bfilterRates = value;
			this.save();
			//this.filterRates();
			this.filter();
		}
		/*  update oFilterParms.brand*/
		public function updateBrand(  value:String):void
		{
			this._oFilterParms.brand = value;
			this.save();
			this.filter();
		}
		/*  update oFilterParms.lblStatus*/
		public function updateLblStatus(  value:String):void
		{
			this._oFilterParms.lblStatus = value;
			this.save();
			this.filter();
		}
		/*  update oFilterParms.*/
		public function updateProgramDiscountTypes(  value:String):void
		{
			this._oFilterParms.programDiscountTypes = value;
			this.save();
			this.filter();
		}
		/*  update oFilterParms.QBrand*/
		public function updateqQBrand(  value:String):void
		{
			this._oFilterParms.qBrand = value;
			this.save();
			this.filter();
		}
		/*  update oFilterParms.SearchFieldText*/
		public function updateSearchFieldText(  value:String):void
		{
			this._oFilterParms.searchFieldText = value;
			this.save();
		}
		/*  update oFilterParms.typeCode*/
		public function updateTypeCode(  value:String):void
		{
			this._oFilterParms.typeCode = value;
			this.save();
			this.filter();
		}
		/*  update oFilterParms.TypeGroup*/
		public function updateTypeGroup(  value:String):void
		{
			this._oFilterParms.typeGroup = value;
			this.save();
			this.filter();
		}
		//.................save......................
		public function save():void
		{
			var event:SearchEvent = new SearchEvent(SearchEvent.SAVE_FILTER_PARMS);
			event.oFilterParms = this._oFilterParms;
			this.dispatcher.dispatchEvent(event);
			dispatchEvent(new Event('pmFilterParmsChanged'));
		}
		
		/**
		 * filter event from the ListenerInjector event type SearchEvent.FILTER_MINI_ITEMS
		*/
		public function filterEventHandler(e:Event):void 
		{
			this.filter();
		}
		
		/* SEARCH filterMiniItems() -> calls setFilter() -> goes to model.searchManager.itemFilterFunc */ 
		public function filterMiniItems():void
		{
			if(this.bLoadMiniItems)
			{
				filter();
			}
			else
			{
				this.bLoadMiniItems = true;
				/* set the data we need to pass to Filter Function Event */
				var event:SearchEvent = new SearchEvent(SearchEvent.GET_MINI_ITEMS);
				event.programId = this.oSettings.programId;
				this.dispatcher.dispatchEvent(event);
			}
		}
		
		/* 	******************************************************************************* */
		/* SEARCH filter() -> calls setFilter() -> goes to model.searchManager.itemFilterFunc */ 
			public function filter():void
			{
				var event:SearchEvent = new SearchEvent(SearchEvent.FILTER);
					event.oFilterParms = this.oFilterParms;
					/* dispatch the event */
               		this.dispatcher.dispatchEvent(event);
			}
				
		    /* Reset scrollbar to the top */   
	        /* public function resetScrollbarPosition(e:Event):void{
				dgItems.scrollToIndex(0);
				} */
				
			private function setFilter():void {
				
 
				/* set the data we need to pass to Filter Function Event */
				var event:SearchEvent = new SearchEvent(SearchEvent.FILTER);
					event.oFilterParms = this.oFilterParms;
					/* dispatch the event */
               		this.dispatcher.dispatchEvent(event);
               	//setCboSelection();
               	
           }	
	            
			public function filterReset():void {
				this._oFilterParms = new FilterParms();
				this.save();
					
		          var event:SearchEvent = new SearchEvent(SearchEvent.RESET_FILTER);
	              this.dispatcher.dispatchEvent(event);
	               	/* reset the text input */
	               	/* _oFilterParms.searchFieldText = '';
		   			this.cboBoxReset();
		   			this.chBoxReset(); */
		   			/* make datagrid look empty for user 
		   			this.items = new ArrayCollection();*/
	        }
	       /* 	******************************************************************************* */
	           
	        /* Reset all of the Combo Boxes to have nothing selected */
	        public function cboBoxReset():void {
				_oFilterParms.brand = '';
	   			_oFilterParms.qBrand = '';
	   			_oFilterParms.typeCode = '';
	   			_oFilterParms.typeGroup = '';
	   			_oFilterParms.programDiscountTypes = '';
	   			_oFilterParms.lblStatus = '';
	   			dispatchEvent(new Event('pmFilterParmsChanged'));
	        }          
			/* Handle chFilterSelected checkBox click -> Display on the selected items (filter on isSelected) */
	        public function filterSelected():void 
		 	{
		 		/* clear the filter mini item master box */
				_oFilterParms.bfilterMiniItem = false;
				
				if (_oFilterParms.bfilterSelected == true) /*  display selected items */
					{
						var event:SearchEvent = new SearchEvent(SearchEvent.FILTER_SELECTED);
						this.dispatcher.dispatchEvent(event);	
					}
				else /* bring us back to the last state of filtering */
					{
					 filter();
					}
			}
			/* Handle when user hits enter key in seach box -> call the filter() method */
			 public function enterSearchBox(event:KeyboardEvent):void 
		 	{                
		 		if (event.keyCode == Keyboard.ENTER)
		 		/* call main filter method */             
		 		this.filter();
		 	}

	}
}