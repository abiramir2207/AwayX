package com.ContractProds.models
{	
	import com.ContractProds.components.ProgBarWin;
	import com.ContractProds.components.StringUtils;
	import com.ContractProds.events.ComponentEvent;
	import com.ContractProds.events.SearchEvent;
	import com.ContractProds.models.ComponentManager;
	import com.ContractProds.views.UserItemLists;
	import com.shared.components.filters.FilterAdvancedDatagrid;
	import com.shared.models.entity.vos.Customer;
	import com.shared.vos.Component;
	import com.shared.vos.CustomPrint;
	import com.shared.vos.CustomPrintCharge;
	import com.shared.vos.FilterParms;
	import com.shared.vos.Item;
	import com.shared.vos.ProdRate;
	import com.shared.vos.Program;
	import com.shared.vos.Settings;
	import com.shared.vos.Uom;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.core.IFlexDisplayObject;
	import mx.managers.PopUpManager;
	import mx.managers.PopUpManagerChildList;
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
	/*	private var _arrBrand:Array = new Array();
		private var _arrQBrand:Array = new Array();
		private var _arrTypeCode:Array = new Array();
		private var _arrTypeGroup:Array = new Array();*/
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
		
		[Bindable]
		public var fadg:FilterAdvancedDatagrid;
		
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

		// _arrItemStatusList 
		[Bindable (event="updCbStatusEvent")]
		public function get arrItemStatusList():Array
		{	return _arrItemStatusList; }
					
		/*  FilterParms From FilterPM*/
		private var _oFilterParms:FilterParms = new FilterParms();
		[Bindable (event="smFilterParmsChanged")]
		public function get oFilterParms():FilterParms
		{
			return _oFilterParms;
		}
		public function set oFilterParms(f:FilterParms):void
		{
			this._oFilterParms = f;
			dispatchEvent(new Event('smFilterParmsChanged'));
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
		/* Program */
		private var _program:Program = new Program();
		[Bindable (event="SMProgramChange")]
		public function get program():Program
		{
			return _program;
		}
		public function set program(prg:Program):void
		{
			this._program = prg;
			dispatchEvent(new Event('SMProgramChange'));
		}
		/*.................funcFilterInsert......................*/
		private var _funcFilterInsert:Function = function(inObject:Object):Boolean{return true;};
		[Bindable (event="funcFilterInsertChange")]
		public function get funcFilterInsert():Function
		{
			return _funcFilterInsert;
		}
		public function set funcFilterInsert(func:Function):void
		{
			this._funcFilterInsert = func;
			dispatchEvent(new Event('funcFilterInsertChange'));
		}
		[Bindable (event="updCbFilters")]
		/** 
		 * Populate the drop downs and adds header rows : UPD_CB_FILTER
		 */		
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

			/* SAVE SHARED OBJECT WITH LIST OF ALL ITEMS */
			saveSOitems();
			//this.updFilters();
			dispatchEvent(new Event('itemListChanged'));
			/*Now get Program PRoduct List Info*/
			var e:ComponentEvent = new ComponentEvent(ComponentEvent.LOAD_PROGRAM);
			e.programId = this.oSettings.programId;
			e.bMarketPrice = this.oSettings.bMarketPrice;
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
			if(this.oSettings.bMarketPrice){
				this._soItemList = SharedObject.getLocal("itemsMP"+this.oSettings.userId+"_"+ this.oSettings.templateFilterId,"/");	
			}
			else{
				this._soItemList = SharedObject.getLocal("items"+this.oSettings.userId+"_"+ this.oSettings.templateFilterId,"/");	
			}
			
			
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
				if (this._soItemList.size > 1 && this._oSettings.iMpId != 0)
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
							/*var e:SearchEvent = new SearchEvent(SearchEvent.GET_PROGRAM_PRODUCTS);
								e.userId = this.oSettings.userId;
								e.programId = this.oSettings.programId;
								e.statusFilterOn = this.oSettings.statusFilterOn;
								e.bMarketPrice = this.oSettings.bMarketPrice;
								e.templateFilterId = this.oSettings.templateFilterId;
								this._dispatcher.dispatchEvent(e);*/
							 //this.updFilters();
							 dispatchEvent(new Event('itemListChanged'));
							 //totTime = getTimer() - startTime;
							 //Alert.show('validate prog prods: ' + totTime.toString());
							 /*Now get Program PRoduct List Info*/
							 var e:ComponentEvent = new ComponentEvent(ComponentEvent.LOAD_PROGRAM);
							 e.programId = this.oSettings.programId;
							 e.bMarketPrice = this.oSettings.bMarketPrice;
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
		/* remove items not in this programs list of items *** NO LONGER USED*** YES IT IS -> 
		   it is used to update the Custom Print Charge Properties from the server.                                                  *********************** 
		ITEMS ARE NOT REMOVED.  Items are cached at the Template Level (Based on Template Filters) Now so Removal is not necessary   ***********************
		****************************************************************************************************************************************************/
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
				// try catch was needed before the arcopy was a deepcopy (clone).  also added if(idx == arr.length) check in case all matches
				 //  are found before we reach end of validProgram array. 
			//	try{
					if(idx == arr.length || arr[idx].itemGuid != i.itemGuid){
						//this._itemList.source[counter].customPrintCharge.printMinPrice = this._itemList.source[counter].marketPrice;
						if(idx == arr.length){
							break;
						}
					}
					else{
						
						var cpc:CustomPrintCharge = arr[idx].customPrintCharge;
						var cp:CustomPrint = arr[idx].customPrint;
						//Set customprint in the AC...item obj,  Prodrate only gets updated if data is ok.
						this._itemList.source[counter].customPrintCharge = cpc;// arr[idx].customPrintCharge;//do we need a copy()?
						this._itemList.source[counter].customPrint    = new CustomPrint(cp);//arr[idx].customPrint;
						
						for each(var c:Component in this.acComponents){
							if(c.type == 1){
								var s:String = '';
								s = s + c.type as String;
								s = s + c.componentId as String;
								var p:ProdRate = this._itemList.source[counter][s]['prodRate'];
								p.rateMPOrig = arr[idx].rateMPOrig;
								/*set PrintMinPrice based on UOM
									* only if it has an MP Rate	
									* if it is a new component (no rates set yet, default the rate to the min Price	*/
								//If we found an upcharge
								if( cpc.printMinPrice > 0){  //&& cpc.printMakeReady > 0 && cpc.printPrePress > 0 && cpc.printPlate > 0
									//converted items do not have a MP so use the one stored on the program
									if(p.rateMP == 0 || isNaN(p.rateMP) == true){
										p.rateMP 	= arr[idx].marketPrice;
										p.rateMPCS 	= arr[idx].marketPriceCS;
										p.rateMPLB 	= arr[idx].marketPriceLB;
									}
									p.customPrint = cp;
									if(p.uom.uomId == 0){
										p.uom = p.uomMP;
									}
									if(p.uom.uomId == 1){
										p.rateMPCustom = cpc.printMinPriceCS;
										this._itemList.source[counter].customPrintCharge.printMinPrice = this._itemList.source[counter].customPrintCharge.printMinPriceCS;
									}else{
										p.rateMPCustom = cpc.printMinPriceLB;
										this._itemList.source[counter].customPrintCharge.printMinPrice = this._itemList.source[counter].customPrintCharge.printMinPriceLB;
									}
									/*  Default the rate to the Min Price :: TURNED OFF
										if(isNaN(p.rate) || p.rate == 0  && this.component.prodRate.length == 0){
											p.rate = p.rateMPCustom;
										}
									*/	
								}
								else{
									//this._itemList.source[counter].customPrint.reset();
									//this._itemList.source[counter].customPrintCharge = new CustomPrintCharge();
									// i.customPrintCharge = new CustomPrintCharge();
									this._itemList.source[counter].customPrintCharge.printMinPrice = 0;
									this._itemList.source[counter].customPrintCharge.printMinPriceCS = 0;
									this._itemList.source[counter].customPrintCharge.printMinPriceLB = 0;
								}
								
								//this.setRateUom(p,i,s);
								this.setRateUom(p,this._itemList.source[counter],s);
								//this._itemList.source[counter][s]['prodRate']['rateMPCustom'] = arr[idx].customPrintCharge.printMinPrice;
							}
						}
						//this._itemList.source[counter].marketPrice = arr[idx].marketPrice;
						//this._itemList.source[counter].uomMP = arr[idx].uomMP;
						idx++;
					}
			//	}	
				/*catch (err:Error){
					trace('Error B:' + this._itemList.length.toString() + ' ::i.baItem ' + i.baItem + ' ::idx ' + idx + ' :: Counter ' + counter+ ' :: err  ' + err.message+ ' :: err  ' + err.name);
					continue;
				}*/
				counter++;
			}
			arrCopy = new Array();
			fadg.saveScrollPos();
			this._itemList.refresh();
			fadg.setScrollPos();
		}
		
		/*  insert an empty Component into the Grid*/
		public function addComponent(c:Component):void
		{
			var sId:String = '';
			sId = ComponentManager.getSelectedCompId(this.component);
			for each(var i:Item in this._itemList.source){
				i[sId] = new Object();
				var p:ProdRate = new ProdRate();
				p.itemGuid = i.itemGuid;
				p.itemNumber = i.baItem;
				i[sId]['prodRate'] = new ProdRate(p);
				/* if there is a Market price with the item, then the MP uom is the only uom available */
			//KRAFT	if(i.marketPrice && c.type == ComponentManager.FIXED_TYPE_ID){
					var arr:Array = new Array();
					arr.push(i.uomMP);
				//KRAFT	i[sId]['uomDp'] = arr;
					//x i[sId+'.prodRate.rateMP'] = i.marketPrice;
					//x i[sId+'.prodRate.uomMP']  = i.uomMP.abbreviation; //display "string" = abbreviation
					i[sId]['prodRate']['rateMP'] = i.marketPrice;
					i[sId]['prodRate']['uomMP']  = i.uomMP;//nested object:uom
					i[sId]['prodRate']['rateMPCustom'] = i.marketPrice
					i[sId]['prodRate']['rateMPOrig'] = i.rateMPOrig;
					i[sId]['prodRate']['rateMPCS'] = i.marketPriceCS;
					i[sId]['prodRate']['rateMPLB'] = i.marketPriceLB;
					i[sId]['prodRate']['customPrint'] = i.customPrint;
					i[sId]['prodRate']['rateEz'] = i.rateEz;
				// KRAFFT}
				/* else use uom from component */
				//KRAFT else{
					i[sId]['uomDp'] = this.component.uom;
					i[sId]['rateConverted'] = i[sId]['prodRate'].rate;
				//k}
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
			}
			dispatchEvent(new Event('itemListChanged'));
		}
		
		/*.................getProdRate......................*/
		public function getProdRate( prodRate:ProdRate,comp:Component = null ):Number
		{	
			var n:Number;
			if(!comp){
				comp = this.component
			}
			
			for each( var pr:ProdRate in comp.prodRate)
			{
				if( pr.itemGuid == prodRate.itemGuid)
				{
					n= pr.rate;
					break;
					
				}
			}
			
			return n;
		}
		
		/*.................call setRateUom For Selected Items......................*/
		public function setSelectedRateUom( p:ProdRate,iAction:int,adg:FilterAdvancedDatagrid ):void
		{
			var sId:String = '';
			var bRateNotNum:Boolean = isNaN(p.rate);
			sId = ComponentManager.getSelectedCompId(this.component);
			var arrUpd:Array = new Array();
			
			/*var scroll:int= adg.verticalScrollPosition;
			var selIdx:int= adg.selectedIndex;*/
			adg.saveScrollPos();
			
			
			
			for each(var i:Item in this._itemList){
				if(i.isSelected){
					//handle for mass apply the uom with no rate entered
					if(bRateNotNum){
						p.itemGuid = i.itemGuid;
						p.rate = getProdRate(p);
					}
					//setRateUom(p,i);
					arrUpd.push(i.baItem)
					var pr:ProdRate = i[sId].prodRate;//new ProdRate(p.itemGuid,p.itemNumber,i[sId].prodRate.uom);
					switch (iAction) {
						case 0:
							//absolute
							pr.rate = p.rate;
							pr.uom  = p.uom;
							setRateUom(pr,i);
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
							if(this.component.type == ComponentManager.REBATE_TYPE_ID){
								pr.rate =  (pr.rateMP) - (pr.rateMP + (pr.rateMP * (p.rate * .01)));
							}
							else{
								pr.rate = pr.rateMP + (pr.rateMP * (p.rate * .01));
							}
							setRateUom(pr,i);
							break;
						case 4:
							//MP incremental
							if(this.component.type == ComponentManager.REBATE_TYPE_ID){
								pr.rate = (pr.rateMP + p.rate) - pr.rateMP;
							}
							else{
								pr.rate = pr.rateMP + p.rate;
							}
							setRateUom(pr,i);
							break;
						case 5:
							//eq MP Rate
							pr.rate = pr.rateMP;
							setRateUom(pr,i);
							break;
						case 6:
							//eq Ez Rate
							pr.rate = i.rateEz;
							setRateUom(pr,i,sId);
							break;
						default:
							trace("Not 0, 1, 2, 3, or 4");
					}
				}
			}
			this.itemList.refresh();
			adg.validateNow();
			/*adg.selectedIndex  = selIdx;
			adg.verticalScrollPosition = scroll;*/
			adg.setScrollPos();
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

			if(i.marketPrice){
				if(newProdRate.uom.uomId == 2){
					newProdRate.rateMP = i.marketPriceLB;
				}
				else{
					newProdRate.rateMP = i.marketPriceCS;
				}
				
				if(isNaN(newProdRate.rateMPCustom)){
					newProdRate.rateMPCustom = i.marketPrice;
				}
				newProdRate.rateMPCS = i.marketPriceCS;
				newProdRate.rateMPLB = i.marketPriceLB;
				newProdRate.rateMPOrig = i.rateMPOrig;
				newProdRate.customPrint.bCustomPrint = i.customPrint.bCustomPrint;
				newProdRate.uomMP  = i.uomMP;
				if(newProdRate.uom.uomId == 3){
					newProdRate.varianceMP = newProdRate.rateMPCS * (newProdRate.rate/100);
					newProdRate.variancePercMP = newProdRate.rate;
				}
				else{
					newProdRate.varianceMP = newProdRate.rateMP - newProdRate.rate;
					newProdRate.variancePercMP = (newProdRate.varianceMP/newProdRate.rateMP) * 100;
				}
				
			}
			//pr.volume = newProdRate.volume;
			newProdRate.rateConverted = newProdRate.rate * this.program.conversionFactor;
			i[sId].prodRate = newProdRate;
			
			i.volume = newProdRate.volume;
			/* Update the Component */
				var e:ComponentEvent = new ComponentEvent(ComponentEvent.SET_SINGLE_RATE_UOM);
				e.prodRate = newProdRate; //pr;
				e.item = i;
				e.sId = sId;
				this._dispatcher.dispatchEvent(e);
			
		}
		/*.................convertRateUom :: customPrintQuote convert function......................*/
		public function convertItems(itemConvert:Item):void
		{
			
			var sId:String = '';
			sId = ComponentManager.getSelectedCompId(this.component);
			var arrUpd:Array = new Array();
			var n:int = 0;
			/*var scroll:int= adg.verticalScrollPosition;
			var selIdx:int= adg.selectedIndex;*/
		//	adg.saveScrollPos();
			for each(var i:Item in this.itemList.source){
				var pr:ProdRate = i[sId].prodRate as ProdRate;
				if(pr.rate > 0 && i.Type_Group_desc == ComponentManager.TYPE_GROUP_DESC){  //has rate and NONE 
					i.Type_Code_desc;
					for each(var iNew:Item in this.itemList.source){
						if( iNew.isGroup && iNew.Type_Code_desc == i.Type_Code_desc){ //Part Type
							if(iNew.Type_Group_desc == itemConvert.Type_Group_desc){//Print Group
								if(iNew.Brand_Name == i.Brand_Name){ // Print Type
									var prNew:ProdRate = new ProdRate(pr);
									//prNew.rate = pr.rate;
									//prNew.uom = pr.uom;
									//prNew.rateMPCustom = pr.rateMPCustom;
									//prNew.rateMPOrig = pr.rateMPOrig;
									//prNew.rateMPCS = pr.rateMPCS;
									//prNew.rateMPLB = pr.rateMPLB;
									//prNew.volume   = pr.volume;
									prNew.description = iNew.Description;
									iNew.customPrint = pr.customPrint;
									iNew.customPrintCharge = i.customPrintCharge;
									//prNew.customPrint = pr.customPrint;
									// ? prNew.rateMPCS = iNew.marketPriceCS;
									// ? prNew.rateMPLB = iNew.marketPriceLB;
										
									prNew.itemGuid = iNew.itemGuid;
									setRateUom(prNew,iNew);//set rate for new item
									
									var prOld:ProdRate = new ProdRate();
									prOld.itemGuid = i.itemGuid;
									prOld.rate = 0;
									prOld.customPrint = i.customPrint;
									setRateUom(prOld,i);//set rate for old NONE item to 0
									
									n++;
									break;
								}
							}
							
						}
					}
				}
			}
			
			Alert.show( n + ' groups converted to: ' + itemConvert.Type_Group_desc);
			this.itemList.refresh();
		//	adg.validateNow();
		//	adg.setScrollPos();
			dispatchEvent(new Event('itemListChanged'));
			
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
			
			oFilterParms.acData = this.acComponents;
			oFilterParms.acData2 = new ArrayCollection(this.program.distributors);
			dispatchEvent(new Event('smFilterParmsChanged'));
			/* filter the data */
			this.funcFilterInsert = this.itemFilterFunc;
			
			/* broadcast updates */
			dispatchEvent(new Event('itemListChanged'));
	
			/* Reset the scrollbar position to the top.*/
			var e:SearchEvent = new SearchEvent(SearchEvent.RESET_SCROLLBAR_POSITION);
   			//  this._dispatcher.dispatchEvent(e);  **********************************************  COMMENTED OUT TODO: LOOKS OK  ????? *****************************************************
		}

		/** Run the filter function to return records in the miniItemMaster (180 day table) : FILTER_MINI_ITEMS */
		public function filterMiniItems():void
		{
			this.funcFilterInsert = this.itemFilterMiniFunc;
		//	this._itemList.filterFunction = this.itemFilterMiniFunc;
		//	this._itemList.refresh();
			dispatchEvent(new Event('itemListChanged'));
		}
		/** Reload the AC back to original dataset. RESET Button : RESET_FILTER */
		public function filterReset():void
		{	this.funcFilterInsert = function(inObject:Object):Boolean{return true;};
			
			/* Reset the scrollbar position to the top. */
			var e:SearchEvent = new SearchEvent(SearchEvent.RESET_SCROLLBAR_POSITION);
   			this._dispatcher.dispatchEvent(e);
		}

       /*  MAIN SEARCH FILTER ............................................... */
		[Bindable] 
		public var itemFilterFunc:Function =
		function(item:Object):Boolean
		{ 
			var bFilter:Boolean = 
				( 
					(
						(oFilterParms.searchFieldText == '')
					)
					/*	&& TODO: uncomment
					(
						oFilterParms.bfilterMiniItem == false || (_acMiniItems.indexOf(item['baItem']) >= 0)
					)*/
				)
				/* Filter rates > 0 section */
				var bFilterRate:Boolean = true;
				/*TODO: uncomment*/
				if(oFilterParms.bfilterRates){
					for each(var c:Component in oFilterParms.acData){
						var s:String = '';
							s = s + c.type as String;
							s = s + c.componentId as String;
						if(item.hasOwnProperty(s)){
							if(StringUtils.IsNumeric(item[s]['prodRate']['rate']) && item[s]['prodRate']['rate'] != 0){
								bFilterRate = true;
								break;
							}
							else{//check customer level rates
								if(c.fixedType == ComponentManager.FIXED_CUST_RATE_TYPE_ID ){
									var p:ProdRate = item[s]['prodRate'] as ProdRate;
									bFilterRate = p.checkCustRate(oFilterParms.acData2.source);
									if(bFilterRate){ //if it has a rate, don't check next comp (since it migh treturn false)
										break;
									}
								}
								else{
									bFilterRate = false;
								}
							}
						}	
					}
				}
				/* Filter MP variance > 0 section */
			var bFilterVarianceMP:Boolean = true;
			/*	TODO: uncomment*/
			if(this.oFilterParms.bfilterVarianceMP){
					for each(var comp:Component in oFilterParms.acData){
						var sId:String = '';
						sId = sId + comp.type as String;
						sId = sId + comp.componentId as String;
						if(item.hasOwnProperty(sId)){
							if(StringUtils.IsNumeric(item[sId]['prodRate']['varianceMP']) && item[sId]['prodRate']['varianceMP'] != 0){
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
				if(this.oFilterParms.bfilterSelected){
					/* if not selected return false */
					if(!item['isSelected']){
						bfilterSelect = false;
					}
				}
				/* Filter item MP section */
				var bfilterMP:Boolean = true;
				if(this.oFilterParms.bfilterMP){
					/* if not selected return false */
					if(item['marketPrice'] == "" || item['marketPrice'] == 0){
						bfilterMP = false;
					}
				}	
				/* Filter items (vs group) section */
				var bfilterItem:Boolean = true;
				if(this.oFilterParms.bfilterA){
					/* if group return false */
					if(item['isGroup'] == true){
						bfilterItem = false;
					}
				}
				/* Filter Groups section */
				var bfilterGroup:Boolean = true;
				if(this.oFilterParms.bfilterB){
					/* if not group return false */
					if(item['isGroup'] == false){
						bfilterGroup = false;
					}
				}
				/* Filter 'NONE' section 'CUSTOM'*/
				var bfilterC:Boolean = true;
				if(this.oFilterParms.bfilterC){
					/* if not type group = 'none'  */
					if(item['Type_Group_desc']  != ComponentManager.TYPE_GROUP_DESC){
						bfilterC = false;
					}
				}
				/* Filter item ez rate section */
				var bfilterEz:Boolean = true;
				if(this.oFilterParms.bfilterEz){
					/* if not selected return false */
					if(item['rateEz'] == "" || item['rateEz'] == 0){
						bfilterEz = false;
					}
				}
				/* Filter item ez rate section */
				var bfilterProdStatus:Boolean = true;
				if(this.oFilterParms.sfilterProductStatus.indexOf('All') == -1){
					/* if not selected return false */
					if(item['Item_Status'] != this.oFilterParms.sfilterProductStatus){
						bfilterProdStatus = false;
					}
				}
			return (bFilter == true && bFilterRate == true && bfilterSelect == true && bFilterVarianceMP == true && bfilterMP == true && bfilterItem == true && bfilterGroup == true && bfilterC == true && bfilterEz == true && bfilterProdStatus == true);
		};/* itemFilterFunc end */
		 
		/* FILTER FUNC CREATE LIST ............................................... 
									...............................................*/
		/* filter func for create/saved list items  */
        private function itemFilterCreateListFunc(item:Object):Boolean
		{
			return (arrValidItems.indexOf(item['baItem']) >= 0)
		}

		/* FILTER FUNC MiniItemMaster (180 table) ............................................... */	
		/* filter func for create/saved list items  */
		[Bindable] 
		public var itemFilterMiniFunc:Function =
        function(item:Object):Boolean
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
			var arrTxtList:Array = StringUtils.listToArray(txt);
			var arrCustCols:Array = new Array();
			/* SHOW PRogress Bar */
			var popUpProgBar:ProgBarWin = ProgBarWin(PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject,ProgBarWin,true,PopUpManagerChildList.POPUP));
			var b:Boolean = this.showLoading(this._itemList.source.length,popUpProgBar);
			var iPrdAttrCount:int = this.program.arrPrdAttr.length;
			//the number of cols in file is dynamic based on PrdAttrs in Template.  For Groups, item is the Guid and stored in last col
			var iItemPos:int = iPrdAttrCount + 5;
			//Customer level rates get valid CustRate Cols
			if(this.component.fixedType == ComponentManager.FIXED_CUST_RATE_TYPE_ID){
				//first row
				var ix:int = 0;
				var arrCols:Array = StringUtils.listToArray(arrTxtList[0],",");
				for each(var s:String in arrCols){
					for each(var cust:Customer in this.program.distributors){
						if(s.indexOf(cust.shipTo) != -1){
							//store column index and Ship_to index
							var obj:Object = new Object();
							obj.index = x;
							obj.shipTo = cust.shipTo;
							arrCustCols.push(obj)
						}
					}
					x++;
				}
			}
			/* loop over list and trim whitespace*/
			var sId:String = ComponentManager.getSelectedCompId(this.component);
			for each(var i:String in arrTxtList)
				{
					var prodRate:ProdRate = new ProdRate();
					var arr:Array = StringUtils.listToArray(i,",");
					
					
					if(arr.length > 1){
						//if group deal use guid from last col
						var regEx:RegExp = /"/g;
						var sItem:String;
						if(this.program.template.bGroupDeal && this.oSettings.appSettings.Template_Multiple_Product_Attr_Groups){ 
							sItem = StringUtils.Trim(arr[arr.length - 1]).replace('=','');//last position in array
							sItem = sItem.replace(regEx,'');
							//if(this.component.type == ComponentManager.FIXED_TYPE_ID){
								var sDesc:String = '';
								for(var x:int=1;x <= iPrdAttrCount;x++){
									if(sDesc.length > 0){sDesc = sDesc + "/"}
									sDesc = sDesc + arr[arr.length - x - 1];
								}
							//}
						}
						else{//use item number in first col
							sItem = StringUtils.Trim(arr[0]).replace('=','');
							sItem = sItem.replace(regEx,'');
						}
						prodRate.itemNumber = sItem;
						prodRate.description = sDesc;
						var guid:String = StringUtils.Trim(arr[arr.length - 1]).replace('=','');
						guid = guid.replace(regEx,'');
						prodRate.itemGuid = guid;
						prodRate.rate = Number(arr[2]) as Number;
						prodRate.uom.abbreviation = arr[3].toString().toUpperCase();
						prodRate.volume = arr[4];
						/* Loop Over Component Uom to see if we have a valid one from user input */
						for each(var uom:Uom in this.component.uom){
							if(uom.abbreviation == arr[3] || uom.description == arr[3]){
								prodRate.uom = uom;
							}
						}
						//Loop over Cust columns and create rateCust Property for valid customers
						if(this.component.fixedType == ComponentManager.FIXED_CUST_RATE_TYPE_ID){
							var rateCust:Number;
							for each(var objCol:Object in arrCustCols){ //this.program.distributors
								rateCust = Number(arr[objCol.index]) as Number
								if(isNaN(rateCust))
								{rateCust = 0}
								prodRate['rateCust_'+ objCol.shipTo] = rateCust;
								prodRate['rateCustConverted_' + objCol.shipTo] = rateCust * this.program.conversionFactor;
							}
						}
					}
					if(prodRate.itemNumber.toLowerCase() != 'item' && prodRate.itemNumber.toLowerCase() != 'key' && prodRate.itemNumber != ''){
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
			//Validate Against current product list.  Item, rate and UOM Validation.  Timeout is used to allow ui to update (progbar popup) in between cycles
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
			var popUpProgBar:ProgBarWin = ProgBarWin(PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject,ProgBarWin,true,PopUpManagerChildList.POPUP));
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
			
			//DEFAULT GROUPS FILTER ON
			//this.oFilterParms.bfilterB = this.program.template.bGroupDeal;
			this.oFilterParms.bfilterC = false;
			if(this.component.prodRate){
				this.oFilterParms.bfilterRates = this.component.prodRate.length > 0;	
			}
			if(this.program.template.bGroupDeal && !this.oFilterParms.bfilterRates && this.oSettings.appSettings.Template_Multiple_Product_Attr_Groups){
				this.oFilterParms.bfilterB = true;
				 //If custom Print, Filter NONE as well
				if(this.program.template.bCustomPrint &&
					//this.component.fixedType != com.ContractProds.models.ComponentManager.FIXED_CUST_RATE_TYPE_ID &&
					//this.oSettings.appSettings.Template_Multiple_Product_Attr_Groups  && 
					//this.component.type == 1   && 
					!this.oSettings.bMarketPrice){
					this.oFilterParms.bfilterC = true;//generic Bool to hold setting for Filter 'NONE'
				}
			}
			if(!this.oFilterParms.bfilterRates  && this.program.template.bEZButtonOn){
				this.oFilterParms.bfilterEz = true;
			}
			else if(!this.oFilterParms.bfilterRates && this.program.bMarketPriceTemplate){ //this.program.bMarketPriceTemplate && 
				this.oFilterParms.bfilterMP = true;
			}
			
			var e:SearchEvent = new SearchEvent(SearchEvent.SAVE_FILTER_PARMS);
			e.oFilterParms = this._oFilterParms;
			this._dispatcher.dispatchEvent(e);
			
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
			
			this.funcFilterInsert = this.itemFilterFunc;
		//	this._itemList.filterFunction = this.itemFilterCreateListFunc;
		//	this._itemList.refresh();
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
						if (getTimer() - startTime > 500) {
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
								var sItemDisplay:String = prodRate.itemNumber;
								//if it is a group itemNumber = itemGuid
								if(prodRate.itemGuid == prodRate.itemNumber && prodRate.itemNumber.length == 36){
									sItemDisplay = prodRate.description;
								}
								var rate:Number = prodRate.rate;
								var uomAbbrev:String = prodRate.uom.abbreviation;
								var uom:Uom = prodRate.uom;
								var volume:Number = prodRate.volume;
								//if it is Cust level rate, see if we have any Cust rates.
								var bCustRate:Boolean = false;
								if(StringUtils.IsNumeric(rate.toString()) && rate == 0 && this.component.fixedType == ComponentManager.FIXED_CUST_RATE_TYPE_ID ){
									bCustRate = prodRate.checkCustRate(this.program.distributors);
								}
								//We need either a rate or a cust rate to add item
								if((StringUtils.IsNumeric(rate.toString()) && rate >= 0) ||  bCustRate){ //&& StringUtils.IsNumeric(volume.toString())
									var x:int = 1;
									for each(var cUom:Uom in component.uom){
										if(cUom.abbreviation == uom.abbreviation){
											//arrValidItems.push(oItem['baItem']) //store the actual item that matched
											if(arrValidItems.indexOf(sItemDisplay) < 0){
												arrValidItems.push(sItemDisplay)
											}
											 //store the actual item that matched
											//arrOValidItems.push(o);
											arrStrValidItems.push(sItem) //keep track of the string typed by user
											/* SET PRODRATE HERE */
											prodRate.itemGuid = oItem.itemGuid;
											setRateUom(prodRate,oItem,arrItemsToAdd[i][1]);
											/* exact match only needs to find one record */
											break;
										}
										else if(x == component.uom.length){
											oInvalidItem = new Object();
											oInvalidItem.item = sItem;
											oInvalidItem.itemDisplay = sItemDisplay;
											oInvalidItem.rate = prodRate.rate;// arrStrItemsToAdd[i]['rate'];// was arrStrItemsToAdd[i][1]
											oInvalidItem.uom  = uomAbbrev;
											///TURN THIS CHECK OFF ##############################################################################
											//oInvalidItem.volume  = arrStrItemsToAdd[i]['volume'];// was arrStrItemsToAdd[i][3]
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
									//if(!StringUtils.IsNumeric(volume.toString()))
									//	{sErrorMessage = sErrorMessage + ' VOLUME';};
									oInvalidItem = new Object();
									oInvalidItem.item = sItem;
									oInvalidItem.itemDisplay = sItemDisplay;
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
					oInvalidItem.itemDisplay = pr.itemNumber;
					//if it is a group itemNumber = itemGuid
					if(pr.itemGuid == pr.itemNumber && pr.itemNumber.length == 36){
						oInvalidItem.itemDisplay = pr.description;
					}
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
				for each(var cmp:Component in this.acComponents){
					var cmpEvtDelRate:ComponentEvent = new ComponentEvent(ComponentEvent.DELETE_PROD_RATE);
					var prdRt:ProdRate = new ProdRate();
					prdRt.itemNumber = o.item;
					//if it is a group itemNumber = itemGuid
					prdRt.itemGuid = o.item;
					/*if(o.itemGuid == pr.itemNumber){
					oInvalidItem.itemDisplay = pr.description;
					prdRt.itemGuid = o.item;
					}*/
					cmpEvtDelRate.prodRate = prdRt;
					cmpEvtDelRate.component = cmp;
					this._dispatcher.dispatchEvent(cmpEvtDelRate);
				}
				
			}
			//by default, the "View rates" filter is OFF for MP and ON for regular Prodrate
			//	this._oFilterParms.bfilterRates = !this.oSettings.bMarketPrice;
			
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
			popUp = UserItemLists(PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject,UserItemLists,true));
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
		
		public function selectItemsFilter(event:ComponentEvent):void{
			//Clear Filters except "bfilterSelected"
			this._oFilterParms = new FilterParms();
			this._oFilterParms.bfilterSelected = true;
			var e:SearchEvent = new SearchEvent(SearchEvent.SAVE_FILTER_PARMS);
			e.oFilterParms = this._oFilterParms;
			this._dispatcher.dispatchEvent(e);
			
			for each(var oItem:Item in this._itemList){
				if(event.arr1.indexOf(oItem.itemGuid) > -1){
					oItem.isSelected = true;
				}
				else{
					oItem.isSelected = false;
				}
				
			}
			//FILTER
			var evt:SearchEvent = new SearchEvent(SearchEvent.FILTER);
			evt.oFilterParms = this._oFilterParms;
			/* dispatch the event */
			this._dispatcher.dispatchEvent(evt);
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
