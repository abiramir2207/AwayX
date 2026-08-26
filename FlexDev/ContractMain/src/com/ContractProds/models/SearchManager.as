package com.ContractProds.models
{	
	import com.ContractProds.components.ProgBarWin;
	import com.ContractProds.components.StringUtils;
	import com.ContractProds.events.*;
	import com.ContractProds.models.ComponentManager;
	import com.ContractProds.views.*;
	import com.ContractProds.vos.Component;
	import com.ContractProds.vos.FilterParms;
	import com.ContractProds.vos.Item;
	import com.ContractProds.vos.Payee;
	import com.ContractProds.vos.ProdRate;
	import com.ContractProds.vos.Uom;
	import com.asfusion.mate.events.Dispatcher;
	import com.shared.vos.Settings;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.external.*;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.containers.TitleWindow;
	import mx.controls.Alert;
	import mx.controls.ProgressBar;
	import mx.controls.ProgressBarMode;
	import mx.core.Application;
	import mx.core.IFlexDisplayObject;
	import mx.managers.PopUpManager;
	import mx.managers.PopUpManagerChildList;
	import mx.messaging.channels.StreamingAMFChannel;
	import mx.utils.ObjectUtil;
	
	//[Bindable]
	/**
	 * Logic for filtering, selecting, and importing items. Also includes initial data load handlers and Drop down box population.
	 * @author msaunders
	 */	
	public class SearchManager extends EventDispatcher 
	{
		/*-.........................................Properties..........................................*/
		/* local references for combo box arrays and item AC */
		private var _itemList:ArrayCollection;
		private var _soItemList:SharedObject;
		private var _arrBrand:Array = new Array();
		private var _arrQBrand:Array = new Array();
		private var _arrTypeCode:Array = new Array();
		private var _arrTypeGroup:Array = new Array();
		private var _arrProgramDiscountTypes:Array = new Array();
		private var _arrItemStatusList:Array = new Array("Show All Status", "Active", "In-Active");		
		private var _sRecordMessage:String = new String('');
		private var _dSOlastSavedDate:Date = new Date(null);
		private var _dTodayDate:Date = new Date();
		/* place holders for criteria passed to itemFilter() */
		private var _brand:String = "";
		private var _qBrand:String = "";
		private var _typeCode:String = "";
		private var _typeGroup:String = "";
		private var _programDiscountTypes:String = "";
		private var _searchString:String = "";
		private var _lblStatus:String = "";
		private var _bFilterMiniItem:Boolean = false;
		/* createlist vars */
		private var arrValidItems:Array = new Array();
		private var arrInValidItems:Array = new Array();
		//private var arrItemsToAdd:Array = new Array();
		private var arrImportItems:Array = new Array();
		public var popUp:UserItemLists;
		public var popUpProgBar:ProgBarWin;
		/* miniItems (180 table) */
		private var _acMiniItems:Array;		
		public var sharedObj:SharedObject;
		
		//public var progBar:ProgressBar;
		//public var winProgBar:TitleWindow = new TitleWindow();
		public var progBarWindow:IFlexDisplayObject;
		/*-.........................................Setters and Getters..........................................*/
		// bound to dgItems dataprovider
		[Bindable (event="itemListChanged")]
		public function get itemList():ArrayCollection
		{	
			if(_itemList.length > 1){
				_sRecordMessage = 'records';
			}
			else{
				_sRecordMessage = 'record';
			}
			dispatchEvent(new Event('recMessageChanged'));
			return _itemList;
		}
		/* string display for record count */
		[Bindable (event="recMessageChanged")]
		public function get sRecordMessage():String
		{	return _sRecordMessage;}
			
		/* miniItemList (180 table) */
		[Bindable (event="miniItemListChanged")]
		public function get miniItemList():Array
			{	return _acMiniItems;}
		
		/* programDiscountTypes combo box dp */
		[Bindable (event="programDiscountTypesChanged")]
		public function get arrProgramDiscountTypesList():Array
			{	return _arrProgramDiscountTypes;}
				
		/*  cbBrand combo box dp */
		[Bindable (event="updCbBrandEvent")]
		public function get arrBrand():Array
		{	return _arrBrand; }
		
		/*  cbQBrand  combo box dp */
		[Bindable (event="updCbQBEvent")]
		public function get arrQBrand():Array
		{	return _arrQBrand; }
			
		/* cbTypeCode  combo box dp */
		[Bindable (event="updCbTCEvent")]
		public function get arrTypeCode():Array
			{	return _arrTypeCode; }
			
		/* cbTypeGroup combo box dp */
		[Bindable (event="updCbTGEvent")]
		public function get arrTypeGroup():Array
		{	return _arrTypeGroup; }

		/*
		_arrItemStatusList */
		[Bindable (event="updCbStatusEvent")]
		public function get arrItemStatusList():Array
		{	return _arrItemStatusList; }
					
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
		/*.................acComponents......................*/
		private var _acComponents:ArrayCollection = new ArrayCollection;
		[Bindable (event="ComponentsChange")]
		public function get acComponents():ArrayCollection
		{
			return _acComponents;
		}
		public function set acComponents(comps:ArrayCollection):void
		{
			this._acComponents = comps;
			dispatchEvent(new Event('ComponentsChange'));
		}
		/*...................... Component ......................*/
		private var _component:Component = new Component();
		[Bindable (event="SMComponentChange")]
		public function get component():Component
		{
			return _component;
		}
		public function set component(comp:Component):void
		{
			this._component = comp;
			dispatchEvent(new Event('SMComponentChange'));
		}
		[Bindable (event="updCbFilters")]
		/** 
		 * Populate the drop downs and adds header rows : UPD_CB_FILTER
		 */		
		public function updFilters():void
		{
				/* reset combo box arrays */
			var startTime:int = getTimer();
			var totTime:int = getTimer();
			
			this.resetFilters();
				/* populate array with data from filtered Ac */
			this._itemList.toArray().forEach(getUniqueFilters);
				/* sort arrays */
			this.sortFilters()
				/* Add the "ALL" Selection as the first element of each array */
			var strAll:String = new String();
    		strAll = "Show All";
    		this._arrBrand.unshift(strAll + " " + _oSettings.brand);
			this._arrQBrand.unshift(strAll + " " + _oSettings.qBrand);
			this._arrTypeCode.unshift(strAll + " " + _oSettings.typeCode);
			this._arrTypeGroup.unshift(strAll + " " + _oSettings.typeGroup);
			this._arrItemStatusList.unshift(strAll + " " + _oSettings.lblStatus);
			dispatchEvent(new Event('updCbBrandEvent'));
			dispatchEvent(new Event('updCbQBEvent'));
			dispatchEvent(new Event('updCbTCEvent'));
			dispatchEvent(new Event('updCbTGEvent'));
			dispatchEvent(new Event('updCbStatusEvent'));
			totTime = getTimer() - startTime;
			//Alert.show('update filters: ' + totTime.toString() + ' :: ' + startTime.toString());
		}
		/* probably wont need this */	
		public function get searchString():String
		{	return _searchString; }


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

		/*-...................................... Constructor.......................................*/
		private var _dispatcher:IEventDispatcher;
		public function SearchManager( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}

		/*-.........................................Methods..........................................*/
		/** itemresutls() gets called on application load.  We pass results from db to this method and
			* assign local _itemlist var the value of passed in AC. the local var gets called by a public getter that is bound to the Datagrid.
			* we call getSlectedItemsFromWrapper to read a form var that holds the list of selected items.
			* Each record is a typed object mapped to .cfc mvc.Models.Item.vos.ItemGridData
			* Then populate combo box arrays. : GET */ 
		public function itemResults(arr:Array):void 
		{
			var igd:Item;
			if( arr is Array )
    		{
				/*set the public var*/
				this._itemList = new ArrayCollection(arr);
		    }
			//	this.updFilters();
			dispatchEvent(new Event('itemListChanged'));
			/* SAVE SHARED OBJECT WITH LIST OF ALL ITEMS */
			saveSOitems();
			/*Now get Program PRoduct List Info*/
			var e:SearchEvent = new SearchEvent(SearchEvent.GET_PROGRAM_PRODUCTS);
			e.userId = this.oSettings.userId;
			e.programId = this.oSettings.programId;
			e.statusFilterOn = this.oSettings.statusFilterOn;
			e.bMarketPrice = this.oSettings.bMarketPrice;
			e.templateFilterId = this.oSettings.templateFilterId;
			this._dispatcher.dispatchEvent(e);
		}
		
		private function saveSOitems():void
		{
			/* save the items to the client */
			var d:Date = new Date();			
			this._soItemList.data.dSavedDate = d;
			this._soItemList.data.itemList = new ArrayCollection(ObjectUtil.copy( this._itemList.source ) as Array );

			/* If the shared object does not exist, then write the data to it. */		 
			if(!this._soItemList.data.customObject)
			{
				this._soItemList.flush(10000000);
			}	 	
			this._dSOlastSavedDate = d;
		}
		
		private function setdSOlastSavedDate():void
		{
			/* save shared object for the user based on UserID */
			this._soItemList = SharedObject.getLocal("items"+this.oSettings.userId,"/");	
			
			// set our dSOlastSavedDate to our received SO's dSavedDate
			if( ( this._soItemList.data.dSavedDate != undefined ) &&
				( this._soItemList.data.dSavedDate is Date ) )
			{
				this._dSOlastSavedDate = this._soItemList.data.dSavedDate as Date;
				//Alert.show("data from SO::" + this._soItems.data.dSavedDate);
				dispatchEvent(new Event('eSOlastSavedDate'));
			}
			else{			  
				this._dSOlastSavedDate = new Date(_dTodayDate.getFullYear(),_dTodayDate.getMonth(),(_dTodayDate.getDate()-1),0,0,0,0);
			}
		}
		
		public function loadSOitems():void 
		{
				// 1.) go get our SO
				this.setdSOlastSavedDate();
				var b:Boolean;
				// 2.) if we got a keeper
				if (this._soItemList.size > 1)
				{
					if(	( this._dSOlastSavedDate.getFullYear() == this._dTodayDate.getFullYear() ) && 
						( this._dSOlastSavedDate.getMonth() == this._dTodayDate.getMonth() ) &&
						( this._dSOlastSavedDate.getDate() == this._dTodayDate.getDate() ) )
					{
						if(
							( this._soItemList.data.itemList.length >= 0 ) )
						{
							// 5.) this._itemList from so
							
							 this._itemList = new ArrayCollection( ObjectUtil.copy( _soItemList.data.itemList.source ) as Array );

							/*Now get Program PRoduct List Info*/
							var e:SearchEvent = new SearchEvent(SearchEvent.GET_PROGRAM_PRODUCTS);
								e.userId = this.oSettings.userId;
								e.programId = this.oSettings.programId;
								e.statusFilterOn = this.oSettings.statusFilterOn;
								e.bMarketPrice = this.oSettings.bMarketPrice;
								e.templateFilterId = this.oSettings.templateFilterId;
								this._dispatcher.dispatchEvent(e);
						}
						else
						{
							b=true;
						}
					}
					else
					{
						b=true;	
					}
				}	
				else
				{
					b=true;
				}
				if(b){
					var evt:SearchEvent = new SearchEvent(SearchEvent.GET);
						evt.userId = this.oSettings.userId;
						evt.programId = this.oSettings.programId;
						evt.statusFilterOn = this.oSettings.statusFilterOn;
						evt.bMarketPrice = this.oSettings.bMarketPrice;
						evt.templateFilterId = this.oSettings.templateFilterId;
						this._dispatcher.dispatchEvent(evt); 
				}
		}
		/* remove items not in this programs list of items */
		public function validateProgramProducts(arr:Array):void 
		{
			var idx:int = 0;
			var counter:int = 0;
			var iPLen:int = arr.length;
			var iItmLen:int = this._itemList.source.length;
			var arrCopy:Array = this.clone(this._itemList.source);
			//var startTime:int = getTimer();
			//var totTime:int = getTimer();
			for each(var i:Item in arrCopy)
			{
				/* try catch was needed before the arcopy was a deepcopy (clone).  also added if(idx == arr.length) check in case all matches
				   are found before we reach end of validProgram array. */
				try{
					if(idx == arr.length || arr[idx].itemGuid != i.itemGuid){
						try{
							this._itemList.removeItemAt(idx);
							//trace('Remove: ' + this._itemList.length.toString() + ' ::i.baItem ' + i.baItem + ' ::idx ' + idx);
						}
						catch (err:Error){
							//trace('Error A: ' + this._itemList.length.toString() + ' ::i.baItem ' + i.baItem + ' ::arr[idx] ' + arr[idx].baItem 
							//	+ ' ::idx ' + idx + ' :: Counter ' + counter);
							continue;
						}
						
					}
					else{
						//i.marketPrice = arr[idx].marketPrice;
						this._itemList[idx].marketPrice = arr[idx].marketPrice;
						this._itemList[idx].uomMP = arr[idx].uomMP;
						this._itemList[idx].marketPriceCS = arr[idx].marketPriceCS;
						this._itemList[idx].marketPriceLB = arr[idx].marketPriceLB;
						idx++;
						
						
						//trace('Increment: ' + this._itemList.length.toString() + ' ::i.baItem ' + i.baItem + ' ::idx ' + idx + ' :: Counter ' + counter);
					}
				}	
				catch (err:Error){
					//trace('Error B:' + this._itemList.length.toString() + ' ::i.baItem ' + i.baItem + ' ::idx ' + idx + ' :: Counter ' + counter);
					this._itemList.removeItemAt(idx);
					continue;
				}
				counter++;
			}
			arrCopy = new Array();
			
			this.updFilters();
			dispatchEvent(new Event('itemListChanged'));
			//totTime = getTimer() - startTime;
			//Alert.show('validate prog prods: ' + totTime.toString());
			/*Now get Program PRoduct List Info*/
			var e:ComponentEvent = new ComponentEvent(ComponentEvent.LOAD_PROGRAM);
			e.programId = this.oSettings.programId;
			e.bMarketPrice = this.oSettings.bMarketPrice;
			this._dispatcher.dispatchEvent(e);
				
			
		}
		/* used for test of shared objects */
		public function loadResults():void 
		{
			//this._itemList = ac;
			sharedObj = SharedObject.getLocal("items");
			this._itemList = sharedObj.data.itemList;
			this.updFilters();
			dispatchEvent(new Event('itemListChanged'));
		}
		/*  insert an empty Component into the Grid*/
		public function addComponent(c:Component):void
		{
			var sId:String = '';
			sId = ComponentManager.getSelectedCompId(this.component);
			for each(var i:Item in this._itemList.source){
				i[sId] = new Object();
				i[sId]['prodRate'] = new ProdRate(i.itemGuid,i.baItem);
				/* if there is a Market price with the item, then the MP uom is the only uom available */
				if(i.marketPrice && c.type == ComponentManager.FIXED_TYPE_ID){
					//var arr:Array = new Array();
					//arr.push(i.uomMP);
					//i[sId]['uomDp'] = arr;
					i[sId]['uomDp'] = this.component.uom;	
					i[sId+'.prodRate.rateMP'] = i.marketPrice;
					i[sId+'.prodRate.uomMP']  = i.uomMP.abbreviation; //display "string" = abbreviation
					i[sId+'.prodRate.rateMPCS'] = i.marketPriceCS;
					i[sId+'.prodRate.rateMPLB'] = i.marketPriceLB;
					//i[sId]['prodRate']['rateMP'] = i.marketPrice;
					//i[sId]['prodRate']['uomMP']  = i.uomMP;//nested object:uom
				}
				/* else use uom from component */
				else{
					i[sId]['uomDp'] = this.component.uom;	
				}
				
			}
			/* TODO: Insert column into the DG.  need to build DG in pModel first */
			dispatchEvent(new Event('itemListChanged'));
		}
		
		/*  delete Component from the Grid*/
		public function deleteComponent(c:Component):void
		{
			var sId:String = '';
			sId = ComponentManager.getSelectedCompId(this.component);
			for each(var i:Item in this._itemList.source){
				delete i[sId];
				delete i[sId+'.prodRate.rate'];
				delete i[sId+'.prodRate.uom'];
				delete i[sId+'.prodRate.rateMP']; 
				delete i[sId+'.prodRate.uomMP'];  
				delete i[sId+'.prodRate.variancePercMP'];
				delete i[sId+'.prodRate.varianceMP'];
				delete i[sId+'.prodRate.rateMPCS']; 
				delete i[sId+'.prodRate.rateMPLB']; 
			}
			dispatchEvent(new Event('itemListChanged'));
		}
		/*.................call setRateUom For Selected Items......................*/
		public function setSelectedRateUom( p:ProdRate,iAction:int=0 ):void
		{
			var sId:String = '';
			sId = ComponentManager.getSelectedCompId(this.component);
			var arrUpd:Array = new Array();
			for each(var i:Item in this._itemList){
				if(i.isSelected){
					//setRateUom(p,i);
					arrUpd.push(i.baItem)
					var pr:ProdRate = new ProdRate(p.itemGuid,p.itemNumber,i[sId].prodRate.uom);
					switch (iAction) {
						case 0:
							//absolute
							setRateUom(p,i);
							break;
						case 1:
							//percent
							pr.rate = i[sId].prodRate.rate + (i[sId].prodRate.rate * (p.rate * .01));
							setRateUom(pr,i);
							break;
						case 2:
							//incremental
							pr.rate = i[sId].prodRate.rate + p.rate;
							setRateUom(pr,i);
							break;
						case 3:
							//MP percent
							pr.rate = i.marketPrice + (i.marketPrice * (p.rate * .01));
							setRateUom(pr,i);
							break;
						case 4:
							//MP incremental
							pr.rate = i.marketPrice + p.rate;
							setRateUom(pr,i);
							break;
						case 5:
							//eq MP Rate
							pr.rate = i.marketPrice;
							setRateUom(pr,i);
							break
						default:
							trace("Not 0, 1, 2, 3, or 4");
					}
				}
			}
			this.itemList.refresh();
			dispatchEvent(new Event('itemListChanged'));
			/* Send results back to ui */
			var e:ComponentEvent = new ComponentEvent(ComponentEvent.SET_RESULT_LOG);
				e.sResult = arrUpd.length + ' items updated ';
   			this._dispatcher.dispatchEvent(e);
   			/* TODO: USE arrUpd to update the Component ProdRate Object */
   			if(arrUpd.length == 0){
   				Alert.show(arrUpd.length + ' items selected! \r\nUse the check boxes on each row or highlight a row(s) and press the [Enter] key to select products.');
   			}	
		}
		/*.................setRateUom......................*/
		public function setRateUom( newProdRate:ProdRate, i:Item, sId:String = ''):void
		{
			if(sId == ''){
				sId = ComponentManager.getSelectedCompId(this.component);
			}

			var pr:ProdRate = i[sId].prodRate;
				pr.rate = newProdRate.rate;
				pr.uom  = newProdRate.uom;
				pr.rateMP = i.marketPrice; 
				//pr.uomMP  = i.uomMP;
				//pr.varianceMP = newProdRate.rate - i.marketPrice;
				//pr.variancePercMP = (newProdRate.rate - i.marketPrice)/i.marketPrice;
				pr.volume = newProdRate.volume;
			/* since nested props are not ok as dataField for renderer, set the "dislpay value" */
			i[sId+'.prodRate.rate'] = newProdRate.rate;
			i[sId+'.prodRate.uom']  = newProdRate.uom.abbreviation;
			if(i.marketPrice){
				i[sId+'.prodRate.rateMP'] = i.marketPrice; 
				i[sId+'.prodRate.uomMP']  = i.uomMP.abbreviation;
				if (pr.uom.uomId == 2){
					i[sId+'.prodRate.variancePercMP']  = ((i.marketPriceLB - newProdRate.rate)/i.marketPriceLB)*100;
					i[sId+'.prodRate.varianceMP']  = i.marketPriceLB - newProdRate.rate;
				}
				else{
					i[sId+'.prodRate.variancePercMP']  = ((i.marketPriceCS - newProdRate.rate)/i.marketPriceCS)*100;
					i[sId+'.prodRate.varianceMP']  = i.marketPriceCS - newProdRate.rate;	
				}
				i[sId+'.prodRate.rateMPCS'] = i.marketPriceCS; 
				i[sId+'.prodRate.rateMPLB'] = i.marketPriceLB; 
			}
			else{
				i[sId+'.prodRate.rateMP'] = null;
				i[sId+'.prodRate.variancePercMP']  = null;
				i[sId+'.prodRate.varianceMP']  = null;
				i[sId+'.prodRate.rateMPCS'] = null;
				i[sId+'.prodRate.rateMPLB'] = null; 
			}
			
			i.volume = newProdRate.volume;
			newProdRate.rateMP = i.marketPrice;
			/* Update the Component */
			var e:ComponentEvent = new ComponentEvent(ComponentEvent.SET_SINGLE_RATE_UOM);
				e.prodRate = newProdRate;
				e.item = i;
				e.sId = sId;
   			this._dispatcher.dispatchEvent(e);

		}
		/**Result handler for populating the array that holds the list of items in 180 day table : GET_MINI_ITEMS */
		public function miniItemResults(ac:Array):void 
		{
			this._acMiniItems = ac;
			/* dispatchEvent(new Event('miniItemListChanged'));
			var event:SearchEvent = new SearchEvent(SearchEvent.FILTER_MINI_ITEMS);
			this._dispatcher.dispatchEvent(event); */
			this.itemFilter();

		}

		public function programDiscountTypesResult(arrProgramDiscountTypes:Array):void 
		{
			this._arrProgramDiscountTypes = arrProgramDiscountTypes;
			this._arrProgramDiscountTypes.unshift("Search Item From");
			dispatchEvent(new Event('programDiscountTypesChanged'));
		}

		/** This is what we are here for.  Set some local vars and then run the filterfunction on the Arraycollection : FILTER 
		 * st:String,br:String,qBr:String,tc:String,tg:String,bFM:Boolean,pd:String,sta:String*/
		public function itemFilter(event:SearchEvent=null):void 
		{
			/* update current selections */
			trace('Filter called');
			this._searchString = oFilterParms.searchFieldText;
			this._brand = oFilterParms.brand;
			this._qBrand = oFilterParms.qBrand;
			this._typeCode = oFilterParms.typeCode;
			this._typeGroup = oFilterParms.typeGroup;
			this._bFilterMiniItem = oFilterParms.bfilterMiniItem;
			this._programDiscountTypes = oFilterParms.programDiscountTypes;
			this._lblStatus = oFilterParms.lblStatus;
			/* filter the data */
			this._itemList.filterFunction = this.itemFilterFunc;
			this._itemList.refresh();
			
			/* broadcast updates */
			dispatchEvent(new Event('itemListChanged'));
				/* Reload the Combo Box Filters */
					this.updFilters();
				
				
			/* Reset the scrollbar position to the top.*/
			var e:SearchEvent = new SearchEvent(SearchEvent.RESET_SCROLLBAR_POSITION);
   			this._dispatcher.dispatchEvent(e);
		}

		/** Run the filter function to return records in the miniItemMaster (180 day table) : FILTER_MINI_ITEMS */
		public function filterMiniItems():void
		{
			this._itemList.filterFunction = this.itemFilterMiniFunc;
			this._itemList.refresh();
			dispatchEvent(new Event('itemListChanged'));
		}
		/** Reload the AC back to original dataset. RESET Button : RESET_FILTER */
		public function filterReset():void
		{
			this._itemList.filterFunction = null;
			this._itemList.refresh();
			/* Reload the Combo Box Filters */
			this.updFilters();
			/* do not dispatch event.  let datagrid stay empty */
			//dispatchEvent(new Event('itemListChanged'));
			
			/* Reset the scrollbar position to the top. */
			var e:SearchEvent = new SearchEvent(SearchEvent.RESET_SCROLLBAR_POSITION);
   			this._dispatcher.dispatchEvent(e);
		}

		/* For the arrays that populate the filter dropdowns	we do some maint */	
		private function resetFilters():void
		{
			this._arrBrand = new Array();
			this._arrQBrand = new Array();
			this._arrTypeCode = new Array();
			this._arrTypeGroup = new Array();
			this._arrProgramDiscountTypes = new Array();
			this._arrItemStatusList = new Array();
		}

		private function sortFilters():void
		{
			this._arrBrand.sort();
			this._arrQBrand.sort();
			this._arrTypeCode.sort();
			this._arrTypeGroup.sort();
			this._arrProgramDiscountTypes.sort();
			
		}

		/* UPDATE Filter Drop Downs ............................................... */
		private function getUniqueFilters(element:*, index:int, arr:Array):void
		{	
			
				/* BRAND *********** */
			if (_arrBrand.length != 0) { 
				if (_arrBrand.indexOf(element.Brand_Name)== -1 && element.Brand_Name != '') {_arrBrand.push(element.Brand_Name);}
			}
			else if(element.Brand_Name != ''){
					_arrBrand.push(element.Brand_Name);
			}
				/* QBRAND *********** */	
			if (_arrQBrand.length != 0) {
				if (_arrQBrand.indexOf(element.Q_Brand)== -1 && element.Q_Brand != '') {_arrQBrand.push(element.Q_Brand);}
			}
			else if(element.Q_Brand != '') {
					_arrQBrand.push(element.Q_Brand);
			}
				/* TYPECODE *********** */
			if (_arrTypeCode.length != 0) {
				if (_arrTypeCode.indexOf(element.Type_Code_Desc)== -1 && element.Type_Code_Desc != '') {_arrTypeCode.push(element.Type_Code_Desc);}
			}
			else if(element.Type_Code_Desc != '') {
					_arrTypeCode.push(element.Type_Code_Desc);
			}
				/* TYPEGROUP *********** */
			if (_arrTypeGroup.length != 0) {
				if (_arrTypeGroup.indexOf(element.Type_Group_Desc)== -1 && element.Type_Group_Desc != '') {_arrTypeGroup.push(element.Type_Group_Desc);}
			}
			else if(element.Type_Group_Desc != '') {
					_arrTypeGroup.push(element.Type_Group_Desc);
			}
			
				/* STATUS *********** */
			if (_arrItemStatusList.length != 0) {
				if (_arrItemStatusList.indexOf(element.Item_Status)== -1 && element.Item_Status != '') {_arrItemStatusList.push(element.Item_Status);}
			}
			else if(element.Item_Status != '') {
					_arrItemStatusList.push(element.Item_Status);
			}
		}

       /*  MAIN SEARCH FILTER ............................................... */	
		private function itemFilterFunc(item:Object):Boolean
		{ 
			var bFilter:Boolean = 
				(
					(	/* filter the AC against the Drop down filter selections */
						(_brand == 'Show All' + " " + _oSettings.brand || (item['Brand_Name'].toUpperCase().indexOf(_brand.toUpperCase()) == 0))
							&&
						(_qBrand == 'Show All' + " " + _oSettings.qBrand || (item['Q_Brand'].toUpperCase().indexOf(_qBrand.toUpperCase()) == 0))
							&&
						(_typeCode == 'Show All' + " " + _oSettings.typeCode || (item['Type_Code_Desc'].toUpperCase().indexOf(_typeCode.toUpperCase()) == 0)) // fix for null records item['Type_Code_Desc'].toString().length > 0 && 
							&&
						(_typeGroup == 'Show All' + " " + _oSettings.typeGroup || (item['Type_Group_Desc'].toUpperCase().indexOf(_typeGroup.toUpperCase()) == 0))
						&&
						(_lblStatus == 'Show All' + " " + _oSettings.lblStatus || (item['Item_Status'].toUpperCase().indexOf(_lblStatus.toUpperCase()) == 0))
					 )
							&& 
						(
							(_searchString == '')
								||	/* if there is anything entered, filter the AC against the search string entered by the user */
							(
								(item['baItem'].toUpperCase().indexOf(_searchString.toUpperCase()) != -1) ||
								(item['Description'].toUpperCase().indexOf(_searchString.toUpperCase()) != -1) ||
								(item['Brand_Name'].toUpperCase().indexOf(_searchString.toUpperCase()) != -1) ||
								(item['Q_Brand'].toUpperCase().indexOf(_searchString.toUpperCase()) != -1) ||
								(item['Type_Code_Desc'].toUpperCase().indexOf(_searchString.toUpperCase()) != -1) ||
								(item['Type_Group_Desc'].toUpperCase().indexOf(_searchString.toUpperCase()) != -1)||
								(item['Item_Status'].toUpperCase().indexOf(_searchString.toUpperCase()) != -1)
							)
						)
							&&
						(
							_bFilterMiniItem == false || (_acMiniItems.indexOf(item['baItem']) >= 0)
						)
					)
				/* Filter rates > 0 section */
				var bFilterRate:Boolean = true;
				if(this._oFilterParms.bfilterRates){
					for each(var c:Component in this._acComponents){
						var s:String = '';
							s = s + c.type as String;
							s = s + c.componentId as String;
						if(item.hasOwnProperty(s)){
							//var x:* = StringUtils.IsNumeric(item[s]['prodRate']['rate']);
							//var z:* = item[s]['prodRate']['rate'];
							if(StringUtils.IsNumeric(item[s]['prodRate']['rate']) && item[s]['prodRate']['rate'] >= 0){
								bFilterRate = true;
								break;
							}
							else{
								bFilterRate = false;
							}
						}	
					}
				}
				/* Filter MP variance > 0 section */
				var bFilterVarianceMP:Boolean = true;
				if(this._oFilterParms.bfilterVarianceMP){
					for each(var comp:Component in this._acComponents){
						var sId:String = '';
						sId = sId + comp.type as String;
						sId = sId + comp.componentId as String;
						if(item.hasOwnProperty(sId)){
							//var x:* = StringUtils.IsNumeric(item[sId+'.prodRate.varianceMP']);
							//var z:* = item[sId+'.prodRate.varianceMP'];
							if(StringUtils.IsNumeric(item[sId+'.prodRate.varianceMP']) && item[sId+'.prodRate.varianceMP'] != 0){
								bFilterVarianceMP = true;
								break;
							}
							else{
								bFilterVarianceMP = false;
							}
						}	
					}
				}
				/* Filter item isSelected section */
				var bfilterSelect:Boolean = true;
				if(this._oFilterParms.bfilterSelected){
					/* if not selected return false */
					if(!item['isSelected']){
						bfilterSelect = false;
					}
				}
				/* Filter item MP section */
				var bfilterMP:Boolean = true;
				if(this._oFilterParms.bfilterMP){
					/* if not selected return false */
					if(item['marketPrice'] == ""){
						bfilterMP = false;
					}
				}
			return (bFilter == true && bFilterRate == true && bfilterSelect == true && bFilterVarianceMP == true && bfilterMP == true);
		}/* itemFilterFunc end */
		 
		/* FILTER FUNC CREATE LIST ............................................... 
									...............................................*/
		/* filter func for create/saved list items  */
        private function itemFilterCreateListFunc(item:Object):Boolean
		{
			return (arrValidItems.indexOf(item['baItem']) >= 0)
		}

		/* FILTER FUNC MiniItemMaster (180 table) ............................................... */	
		/* filter func for create/saved list items  */
        private function itemFilterMiniFunc(item:Object):Boolean
		{
			return (_acMiniItems.indexOf(item['baItem']) >= 0)
		}

		/**
		 *  Handler for Create List Button Click : CREATE_LIST 
		 * @param  String String holds the list of items from create list box with carriage return as delimeter
		 * Handles Import lsit as wel as typed in list (import has 3 cols, typed in list  is just item numbers)*/	
		public function createList(txt:String):void
		{
			var arrItemsToAdd:Array = new Array();
			var arrSimpleItemsToAdd:Array = new Array();
			var arrStrItemsToAdd:Array = new Array();
			/* SHOW PRogress Bar */
			var popUpProgBar:ProgBarWin = ProgBarWin(PopUpManager.createPopUp(Application.application as DisplayObject,ProgBarWin,true,PopUpManagerChildList.POPUP));
			var b:Boolean = this.showLoading(this._itemList.source.length,popUpProgBar);
			/* loop over list and trim whitespace*/
			var sId:String = ComponentManager.getSelectedCompId(this.component);
			for each(var i:String in StringUtils.listToArray(txt))
				{
					var prodRate:ProdRate = new ProdRate();
					var arr:Array = StringUtils.listToArray(i,",");
					prodRate.itemNumber = StringUtils.Trim(arr[0]);
					
					if(arr.length > 1){
						prodRate.rate = Number(arr[1]) as Number;
						prodRate.uom.abbreviation = arr[2].toString().toUpperCase();
						prodRate.volume = arr[3];
						/* Loop Over Component Uom to see if we have a valid one from user input */
						for each(var uom:Uom in this.component.uom){
							if(uom.abbreviation == arr[2] || uom.description == arr[2]){
								prodRate.uom = uom;
							}
						}
					}
					
					if(prodRate.itemNumber.toLowerCase() != 'item' && prodRate.itemNumber != ''){
						 arrItemsToAdd.push([prodRate,sId]);
						 arrStrItemsToAdd.push(arr); /* the text string with original values from the uploaded csv */
						 arrSimpleItemsToAdd.push(prodRate.itemNumber.toLowerCase())
						}

				}
			/* Send results back to ui */
			/*var e:ComponentEvent = new ComponentEvent(ComponentEvent.DISPLAY_LIST_RATE);
			e.arr1 = arrItemsToAdd;
			e.arr2 = arrSimpleItemsToAdd;
			e.arr3 = arrStrItemsToAdd;
			this._dispatcher.dispatchEvent(e);*/
			setTimeout(displayListRate, 10, arrItemsToAdd,arrSimpleItemsToAdd,arrStrItemsToAdd,popUpProgBar);
			//displayListRate(arrItemsToAdd,arrSimpleItemsToAdd,arrStrItemsToAdd);
		}
		/* take list of Prodrates from server on initial load */
		public function loadProdRates():void
		{
			var arrItemsToAdd:Array = new Array();
			var arrStrItemsToAdd:Array = new Array();
			var arr:Array = new Array();
				
			var arrSimpleItemsToAdd:Array = new Array();
			/* SHOW PRogress Bar */
			var popUpProgBar:ProgBarWin = ProgBarWin(PopUpManager.createPopUp(Application.application as DisplayObject,ProgBarWin,true,PopUpManagerChildList.POPUP));
			var b:Boolean = this.showLoading(this._itemList.source.length,popUpProgBar);
			for each(var c:Component in this.acComponents){
				arr = c.prodRate;
				var sId:String = ComponentManager.getSelectedCompId(c);
				/* loop over list and trim whitespace*/
				for each(var pr:ProdRate in arr)
				{
					arrItemsToAdd.push([pr,sId]);
					arrStrItemsToAdd.push(pr);
					arrSimpleItemsToAdd.push(pr.itemNumber.toLowerCase())
				}
			}
			setTimeout(displayListRate, 10, arrItemsToAdd,arrSimpleItemsToAdd,arrStrItemsToAdd,popUpProgBar);
			//displayListRate(arrItemsToAdd,arrSimpleItemsToAdd,arrStrItemsToAdd);
		}

		/** DisplayList(): Either already selected items (view selected check box) or 
		 * called from create list : GET_USERLIST_ITEMS
		 * @param Array  Array of items to display
   		 */
		public function displayList(arrItemsToAdd:Array):void
		{	
			var arrStrValidItems:Array = new Array();
			arrValidItems = new Array();
			arrInValidItems = new Array();
					for each(var sItem:String in arrItemsToAdd)
					{
						for each(var oItem:Object in this._itemList.source)
						{	/* appsetting to determine if the create list should be an exact match */
							if(this._oSettings.appSettings.Exact_List_Matching_On == 1)
								{  
									if(oItem['baItem'].match(new RegExp("^"+ sItem + "$", 'i')))
										{	arrValidItems.push(oItem['baItem']) //store the actual item that matched
											arrStrValidItems.push(sItem) //keep track of the string typed by user
											/* exact match only needs to find one record */
											break;
										}	
								}
							else{
									if(oItem['baItem'].match(new RegExp(sItem, 'i')))
										{	arrValidItems.push(oItem['baItem']) //store the actual item that matched
											arrStrValidItems.push(sItem) //keep track of the string typed by user
										}
								}
							
						}
						/* if current item from create list is not in the list of valid items (arrStrValidItems) it must be invalid */
						if(arrStrValidItems.indexOf(sItem) == -1)
							{arrInValidItems.push(sItem)}
					}
			
			this._itemList.filterFunction = this.itemFilterCreateListFunc;
			this._itemList.refresh();
			//this.selectAll();
			this._oFilterParms = new FilterParms();
			this._oFilterParms.bfilterSelected = true;
			var e:SearchEvent = new SearchEvent(SearchEvent.SAVE_FILTER_PARMS);
				e.oFilterParms = this._oFilterParms;
				this._dispatcher.dispatchEvent(e);

			/* if there are any invalid items display the valid and invalid lists */
			if(arrInValidItems.length > 0)
			{
				/* if there are any invalis items pop up the results */
				showPopUp(arrInValidItems,arrValidItems);
			}
		}
		/* Called from create List. when a user types in a list of items or when they use IMPORT from csv */
		public function displayListRate(arrItemsToAdd:Array,
										arrSimpleItemsToAdd:Array,
										arrStrItemsToAdd:Array,
										popUpProgBar:ProgBarWin,
										idx:int = 0,
										arrStrValidItems:Array = null,
										arrStrInValidItems:Array = null):void
		{	trace('displayListRate');
			this._itemList.disableAutoUpdate();
			var arrTmpItemIx:Array = new Array();
			var oInvalidItem:Object = new Object();
			var iPr:int = 0;
			var startTime:int = getTimer();
			//var intP:int = 0;
			if(idx == 0){
				arrValidItems = new Array();
				arrInValidItems = new Array();
				arrStrValidItems = new Array();
				arrStrInValidItems = new Array();
			}
					/*  Loop over all items */
					for (idx = idx; idx < this._itemList.source.length; idx++)//(var oItem:Item in this._itemList.source)
					{
						var oItem:Item = this._itemList.source[idx];
						/* Update Profgress bar every 250 millsec.  Then call this method again in 10 millisec.  delay is needded to 
						for Flash to open the single thread for UI updates*/
						if (getTimer() - startTime > 250) {
							setTimeout(displayListRate, 10,
										arrItemsToAdd,
										arrSimpleItemsToAdd,
										arrStrItemsToAdd,
										popUpProgBar,
										idx,
										arrStrValidItems,
										arrStrInValidItems);
							setLoadingProgress(idx,this._itemList.source.length,popUpProgBar);
							return;
						}
						/*If current item in dp is in list of items to add then validate and add*/
						iPr = arrSimpleItemsToAdd.indexOf(oItem.baItem.toLowerCase());
						var ln:uint = arrSimpleItemsToAdd.length;
						if( iPr > -1){
							/*  The item might be in the list of Prodrates twice for multiple components so get them all*/
							arrTmpItemIx = new Array();
							arrTmpItemIx.push(iPr);
							for(var ix:uint; ix < ln; ix++){
								iPr = arrSimpleItemsToAdd.indexOf(oItem.baItem.toLowerCase(),iPr + 1);
								if( iPr > -1)
									{arrTmpItemIx.push(iPr);}
								else{break;}
							}
							for each(var i:int in arrTmpItemIx){
								var prodRate:ProdRate = arrItemsToAdd[i][0];
								var sItem:String = prodRate.itemNumber;
								var rate:Number = prodRate.rate;
								var uomAbbrev:String = prodRate.uom.abbreviation;
								var uom:Uom = prodRate.uom;
								var volume:Number = prodRate.volume;
								
								if(StringUtils.IsNumeric(rate.toString()) && rate >= 0 && StringUtils.IsNumeric(volume.toString())){
									var x:int = 1;
									for each(var cUom:Uom in component.uom){
										if(cUom.abbreviation == uom.abbreviation){
											arrValidItems.push(oItem['baItem']) //store the actual item that matched
											//arrOValidItems.push(o);
											arrStrValidItems.push(sItem) //keep track of the string typed by user
											/* SET PRODRATE HERE */
											setRateUom(prodRate,oItem,arrItemsToAdd[i][1]);
											/* exact match only needs to find one record */
											break;
										}
										else if(x == component.uom.length){
											oInvalidItem = new Object();
											oInvalidItem.item = sItem;
											oInvalidItem.rate = arrStrItemsToAdd[i]['rate'];// was arrStrItemsToAdd[i][1]
											oInvalidItem.uom  = uomAbbrev;
											oInvalidItem.volume  = arrStrItemsToAdd[i]['volume'];// was arrStrItemsToAdd[i][3]
											oInvalidItem.sError = 'Invalid UOM';
											arrStrInValidItems.push(sItem);
											arrInValidItems.push(oInvalidItem);
											
											/* SET PRODRATE HERE 
											prodRate.rate = 0;
											prodRate.uom = cUom;
											setRateUom(prodRate,oItem,arrItemsToAdd[i][1]); */
										}
										x++;
									}
								} //else invalid rate
								else{
									var sErrorMessage:String = 'Invalid';
									if(!StringUtils.IsNumeric(rate.toString()) || rate < 0)
										{sErrorMessage = sErrorMessage + ' RATE';};
									if(!StringUtils.IsNumeric(volume.toString()))
										{sErrorMessage = sErrorMessage + ' VOLUME';};
									oInvalidItem = new Object();
									oInvalidItem.item = sItem;
									oInvalidItem.rate = arrStrItemsToAdd[i][1];
									oInvalidItem.uom  = uomAbbrev;
									oInvalidItem.volume  = arrStrItemsToAdd[i][3];
									oInvalidItem.sError = sErrorMessage;
									arrStrInValidItems.push(sItem);
									arrInValidItems.push(oInvalidItem);
								}
							}//for each prodrates
						} //else invalid item	
					}
			/* if current item from create list is not in the list of valid items (arrStrValidItems) 
			 AND it has not already been flagged as Invalid (arrStrInValidItems) 
			 it must be invalid due to bad item*/
			for each(var arrX:Array  in arrItemsToAdd){
				var pr:ProdRate = arrX[0]
				if(arrStrValidItems.indexOf(pr.itemNumber) == -1 && arrStrInValidItems.indexOf(pr.itemNumber) == -1)
				{
					oInvalidItem = new Object();
					oInvalidItem.item = pr.itemNumber;
					oInvalidItem.rate = pr.rate;
					oInvalidItem.uom  = pr.uom.abbreviation;
					oInvalidItem.volume  = pr.volume;
					oInvalidItem.sError = 'Invalid ITEM';
					arrStrInValidItems.push(pr.itemNumber);
					arrInValidItems.push(oInvalidItem); 
					
					/* SET PRODRATE HERE  NEED TO REMOVE HERE
					prodRate.rate = 0;
					prodRate.uom = cUom;
					setRateUom(prodRate,oItem,arrItemsToAdd[i][1]); */
				}
			}
			//remove the items from the component
			
			for each(var o:Object  in arrInValidItems){
				var cmpEvtDelRate:ComponentEvent = new ComponentEvent(ComponentEvent.DELETE_PROD_RATE);
				var prdRt:ProdRate = new ProdRate();
				prdRt.itemNumber = o.item;
				cmpEvtDelRate.prodRate = prdRt;
				this._dispatcher.dispatchEvent(cmpEvtDelRate);
			}
			//by default, the "View rates" filter is OFF for MP and ON for regular Prodrate
			this._oFilterParms.bfilterRates = !this.oSettings.bMarketPrice;
			
			var e:SearchEvent = new SearchEvent(SearchEvent.SAVE_FILTER_PARMS);
				e.oFilterParms = this._oFilterParms;
				this._dispatcher.dispatchEvent(e);
			/* set the data we need to pass to Filter Function Event */
			var evt:SearchEvent = new SearchEvent(SearchEvent.FILTER);
				evt.oFilterParms = this._oFilterParms;
				/* dispatch the event */
           	this._dispatcher.dispatchEvent(evt);
           	/* Send results back to UI */
			var cmpEvt:ComponentEvent = new ComponentEvent(ComponentEvent.SET_RESULT_LOG);
				cmpEvt.sResult = '[ ' + arrValidItems.length + ' Items]' + '  [ ' + arrInValidItems.length + ' Rejected ] :: ';
   			this._dispatcher.dispatchEvent(cmpEvt);
			
			clearLoadingProgress(popUpProgBar);
			
			//this._itemList.enableAutoUpdate();
			
			dispatchEvent(new Event('itemListChanged'));
			/* if there are any invalid items display the valid and invalid lists */
			if(arrInValidItems.length > 0)
			{
				/* if there are any invalis items pop up the results */
				showPopUp(arrInValidItems,arrValidItems);
			}
		}

		/* Show Pop-Up Box with List of Valid and Invalid Items
		TODO: add reject reasons to invalidItems array (need to create array of objects).  
		Need to change display to handle new fields and validation 9above) to populate them */
		private function showPopUp(aInvalidItems:Array,aValidItems:Array):void{
			popUp = UserItemLists(PopUpManager.createPopUp(Application.application as DisplayObject,UserItemLists,true));
			PopUpManager.centerPopUp(popUp);
			popUp.aInvalidItems = aInvalidItems;
			popUp.dispatcher = this._dispatcher;
			popUp.aValidItems = aValidItems;
		}
		private function showLoading(i:uint,popUpProgBar:ProgBarWin):Boolean
		{
			//PopUpManager.addPopUp(_progBar,this,true);
			PopUpManager.centerPopUp(popUpProgBar);
			popUpProgBar.initBar(0,i);
			return true;
		}
		private function setLoadingProgress(i:int,x:uint,popUpProgBar:ProgBarWin):void
		{
			popUpProgBar.setProgress(i, x);
		}
		private function clearLoadingProgress(popUpProgBar:ProgBarWin):void
		{ 
			popUpProgBar.removePopUp();
			trace('remove prog bar');
		}

		 private function selectAll():void 
	 	{
	   		/* _itemList is the Var bound to the DP of our datagrid.
	   		it gets updated when we filter so loop over it and select all */
		    for each(var oItem:Object in this._itemList)
			   	{
			   		oItem.isSelected = 1;
			    }
	 	}
		 
		private function clone(source:Object):* 
		 { 
			 var myBA:ByteArray = new ByteArray(); 
			 myBA.writeObject(source); 
			 myBA.position = 0; 
			 return(myBA.readObject()); 
		 }

	}/* Class end */
}/* Package end */