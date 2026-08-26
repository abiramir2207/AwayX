package com.ItemSearch.models
{	
	import com.asfusion.mate.events.Dispatcher;
	import com.ItemSearch.events.*;
	import com.ItemSearch.views.*;
	import com.ItemSearch.vos.*;
	import com.ItemSearch.components.StringUtils;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.external.*;
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.managers.PopUpManager;
	import mx.utils.ObjectUtil;
	import flash.net.SharedObject;
	
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
		private var _arrBrand:Array = new Array();
		private var _arrQBrand:Array = new Array();
		private var _arrTypeCode:Array = new Array();
		private var _arrTypeGroup:Array = new Array();
		private var _arrProgramDiscountTypes:Array = new Array();
		private var _sRecordMessage:String = new String('');
		/* place holders for criteria passed to itemFilter() */
		private var _brand:String = "";
		private var _qBrand:String = "";
		private var _typeCode:String = "";
		private var _typeGroup:String = "";
		private var _programDiscountTypes:String = "";
		private var _searchString:String = "";
		private var _bFilterMiniItem:Boolean = false;
		private var _settings:Settings = new Settings();
		/* createlist vars */
		private var arrValidItems:Array = new Array();
		private var arrInValidItems:Array = new Array();
		private var arrItemsToAdd:Array = new Array();
		private var arrImportItems:Array = new Array();
		public var popUp:UserItemLists;
		/* miniItems (180 table) */
		private var _acMiniItems:Array;		
		public var sharedObj:SharedObject;
		
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

		[Bindable (event="updCbFilters")]
		/** 
		 * Populate the drop downs and adds header rows : UPD_CB_FILTER
		 */		
		public function updFilters():void
			{	/* Alert.show('UPDATE FILTERS','work damit!'); */
					/* reset combo box arrays */
				this.resetFilters();
					/* populate array with data from filtered Ac */
				this._itemList.toArray().forEach(getUniqueFilters);
					/* sort arrays */
				this.sortFilters()
					/* Add the "ALL" Selection as the first element of each array */
				var strAll:String = new String();
        		strAll = "Show All";
        		this._arrBrand.unshift(strAll + " " + _settings.brand);
				this._arrQBrand.unshift(strAll + " " + _settings.qBrand);
				this._arrTypeCode.unshift(strAll + " " + _settings.typeCode);
				this._arrTypeGroup.unshift(strAll + " " + _settings.typeGroup);
				dispatchEvent(new Event('updCbBrandEvent'));
				dispatchEvent(new Event('updCbQBEvent'));
				dispatchEvent(new Event('updCbTCEvent'));
				dispatchEvent(new Event('updCbTGEvent'));
			}
		/* probably wont need this */	
		public function get searchString():String
			{	return _searchString; }


		public function set settings(s:Settings):void 
			{
				this._settings = s;
			}
		public function get settings():Settings 
			{
				return _settings;
			}
		/*-.........................................Constructor..........................................*/
		private var dispatcher:IEventDispatcher;
		public function SearchManager( dispatcher:IEventDispatcher ):void
		{
			this.dispatcher = dispatcher;
		}

		/*-.........................................Methods..........................................*/
		/** itemresutls() gets called on application load.  We pass results from db to this method and
			* assign local _itemlist var the value of passed in AC. the local var gets called by a public getter that is bound to the Datagrid.
			* we call getSlectedItemsFromWrapper to read a form var that holds the list of selected items.
			* Each record is a typed object mapped to .cfc mvc.Models.Item.vos.ItemGridData
			* Then populate combo box arrays. : GET */ 
		public function itemResults(arr:Array):void 
			{
			//	this.getSlectedItemsFromWrapper();
				/* loop over arr and cast records as a GridData() object */
				if( arr is Array )
	    		{
		    		for each(var igd:ItemGridData in arr)
		    			{ 
		    				if(arrItemsToAdd.indexOf(igd['itemGuid']) != -1)
		    					{
		    						igd.isSelected = true;
		    					}
		    			}
					/*set the public var*/
					this._itemList = new ArrayCollection(arr);
			    }
				this.updFilters();
				dispatchEvent(new Event('itemListChanged'));
			}

		/* get list of selected items from calling page (via this wrapper ItemSearchFx.cfm) */
	    private function getSlectedItemsFromWrapper():void {
	        var s:String;
	        var a:Array;
	        var e:SearchEvent = new SearchEvent(SearchEvent.BSA_ERROR);
			var d:Dispatcher = new Dispatcher();
	        if (ExternalInterface.available) {
	        try {
	           ExternalInterface.addCallback("sendToActionScript", receivedFromJavaScript)
	           ExternalInterface.call("sendToActionScript");
			} catch (error:SecurityError) {
					e.sBaError = "A SecurityError occurred getting selected items: " + error.message + "\n"
					d.dispatchEvent(e);
   				} 
   				catch (error:Error) {
					e.sBaError = "An Error occurred getting selected items: " + error.message + "\n"
					d.dispatchEvent(e);
                }
	        } else {
	        	e.sBaError = "Wrapper not available getting selected items: "
				d.dispatchEvent(e);
	        }
	     }

		/** parse the list of already selected items sent from the wrapper page via JS. */
	   public function receivedFromJavaScript(s:String):void {
              /* loop over list and trim whitespace */
				for each(var i:String in StringUtils.listToArray(s,","))
							{
							 	arrItemsToAdd.push(StringUtils.Trim(i));
							}
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

		/**Result handler for populating the array that holds the list of items in 180 day table : GET_MINI_ITEMS */
		public function miniItemResults(ac:Array):void 
		{
			this._acMiniItems = ac;
			dispatchEvent(new Event('miniItemListChanged'));
			var event:SearchEvent = new SearchEvent(SearchEvent.FILTER_MINI_ITEMS);
			var d:Dispatcher = new Dispatcher();
			d.dispatchEvent(event);

		}

		public function programDiscountTypesResult(arrProgramDiscountTypes:Array):void 
			{
				this._arrProgramDiscountTypes = arrProgramDiscountTypes;
				this._arrProgramDiscountTypes.unshift("Search Item From");
				dispatchEvent(new Event('programDiscountTypesChanged'));
			}

		/** This is what we are here for.  Set some local vars and then run the filterfunction on the Arraycollection : FILTER */
		public function itemFilter(st:String,br:String,qBr:String,tc:String,tg:String,bFM:Boolean,pd:String):void 
			{
				/* update current selections */
				this._searchString = st;
				this._brand = br;
				this._qBrand = qBr;
				this._typeCode = tc;
				this._typeGroup = tg;
				this._bFilterMiniItem = bFM;
				this._programDiscountTypes = pd;
				/* filter the data */
				this._itemList.filterFunction = this.itemFilterFunc;
				this._itemList.refresh();
				
				/* broadcast updates */
				dispatchEvent(new Event('itemListChanged'));
					/* dispatchEvent(new Event('updCbFilters')); NOT WORKING? call method directly */
					/* Reload the Combo Box Filters 
						this.updFilters();
					*/
					
				/* Reset the scrollbar position to the top.*/
		 		var e_Dispatcher:Dispatcher = new Dispatcher();
				var e:SearchEvent = new SearchEvent(SearchEvent.RESET_SCROLLBAR_POSITION);
       			e_Dispatcher.dispatchEvent(e);
			}

		/** Run the filter function to return selected rows : FILTER_SELECTED */
		public function filterSelected():void
			{
				this._itemList.filterFunction = this.itemFilterSelectedFunc;
				this._itemList.refresh();
				dispatchEvent(new Event('itemListChanged'));
			}

		/** Run the filter function to return records in the miniItemMaster (180 day table) : FILTER_MINI_ITEMS */
		/* public function filterMiniItems():void
			{
				this._itemList.filterFunction = this.itemFilterMiniFunc;
				this._itemList.refresh();
				dispatchEvent(new Event('itemListChanged'));
			} */
		/** Reload the AC back to original dataset. RESET Button : RESET_FILTER */
		public function filterReset():void
			{
				this._itemList.filterFunction = null;
				this._itemList.refresh();
				/* Reload the Combo Box Filters */
				//this.updFilters();
				/* do not dispatch event.  let datagrid stay empty */
				//dispatchEvent(new Event('itemListChanged'));
				
				/* Reset the scrollbar position to the top. */
				var e_Dispatcher:Dispatcher = new Dispatcher();
				var e:SearchEvent = new SearchEvent(SearchEvent.RESET_SCROLLBAR_POSITION);
       			e_Dispatcher.dispatchEvent(e);
			}

		/* For the arrays that populate the filter dropdowns	we do some maint */	
		private function resetFilters():void
			{
				this._arrBrand = new Array();
				this._arrQBrand = new Array();
				this._arrTypeCode = new Array();
				this._arrTypeGroup = new Array();
				this._arrProgramDiscountTypes = new Array();
			}

		private function sortFilters():void
			{
				this._arrBrand.sort();
				this._arrQBrand.sort();
				this._arrTypeCode.sort();
				this._arrTypeGroup.sort();
				this._arrProgramDiscountTypes.sort();
			}

	/* UPDATE Filter Drop Downs xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx */
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
			}

       /*  MAIN SEARCH FILTER xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx */	
		private function itemFilterFunc(item:Object):Boolean
			{
				return (
						(	/* filter the AC against the Drop down filter selections */
							(_brand == 'Show All' + " " + _settings.brand || (item['Brand_Name'].toUpperCase().indexOf(_brand.toUpperCase()) == 0))
								&&
							(_qBrand == 'Show All' + " " + _settings.qBrand || (item['Q_Brand'].toUpperCase().indexOf(_qBrand.toUpperCase()) == 0))
								&&
							(_typeCode == 'Show All' + " " + _settings.typeCode || (item['Type_Code_Desc'].toUpperCase().indexOf(_typeCode.toUpperCase()) == 0)) // fix for null records item['Type_Code_Desc'].toString().length > 0 && 
								&&
							(_typeGroup == 'Show All' + " " + _settings.typeGroup || (item['Type_Group_Desc'].toUpperCase().indexOf(_typeGroup.toUpperCase()) == 0))
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
									(item['Type_Group_Desc'].toUpperCase().indexOf(_searchString.toUpperCase()) != -1)
									/* old regex version
									item['baItem'].match(new RegExp(_searchString, 'i')) || 
									item['Description'].match(new RegExp(_searchString, 'i')) ||
									item['Brand_Name'].match(new RegExp(_searchString, 'i')) ||
									item['Q_Brand'].match(new RegExp(_searchString, 'i')) ||
									item['Type_Code_Desc'].match(new RegExp(_searchString, 'i')) ||
									item['Type_Group_Desc'].match(new RegExp(_searchString, 'i'))
									*/
								)
							)
							
								&& 
							(
								(_programDiscountTypes == 'Search Item From')
									||	/* filter the AC against the products included in a specific discount type searched */
								(
							 		(_programDiscountTypes == 'Fixed Price' && item.Fixed_Price_Included == true)                  
                                 	||
                                 	(_programDiscountTypes == 'Rebate' && item.Rebate_Included == true)                  
                                 	||
                                 	(_programDiscountTypes == 'Lump Sum' && item.LumpSum_Included == true)      
                                	||
                                 	(_programDiscountTypes == 'Growth' && item.Growth_Included == true)         
                                	||
                                 	(_programDiscountTypes == 'Bid Request' && item.BidRequest_Included == true)                                               
								)
							)
							
							
								&&
							(
								_bFilterMiniItem == false || (_acMiniItems.indexOf(item['baItem']) >= 0)
							)
						)
			}/* itemFilterFunc end */

		/* FILTER FUNC SELECTED xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx */
		private function itemFilterSelectedFunc(item:Object):Boolean
			{
				return item['isSelected'] == 1
			}/* itemFilterSelectedFunc end */
		 
		/* FILTER FUNC CREATE LIST xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx */
		/* filter func for create/saved list items  */
        private function itemFilterCreateListFunc(item:Object):Boolean
			{
				return (arrValidItems.indexOf(item['baItem']) >= 0)
			}

		/* FILTER FUNC MiniItemMaster (180 table) xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx */	
		/* filter func for create/saved list items  */
        private function itemFilterMiniFunc(item:Object):Boolean
			{
				return (_acMiniItems.indexOf(item['baItem']) >= 0)
			}

		/**
		 *  Handler for Create List Button Click : CREATE_LIST 
		 * @param  String String holds the list of items from create list box with carriage return as delimeter*/	
		public function createList(txt:String):void
			{
				arrItemsToAdd = new Array();
				/* loop over list and trim whitespace*/
				for each(var i:String in StringUtils.listToArray(txt))
							{
							 	arrItemsToAdd.push(StringUtils.Trim(i));
							}
				displayList(arrItemsToAdd);
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
								if(this._settings.appSettings.Exact_List_Matching_On == 1)
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
				this.selectAll();
				dispatchEvent(new Event('itemListChanged'));
				/* if there are any invalid items display the valid and invalid lists */
				if(arrInValidItems.length > 0)
				{
					/* if there are any invalis items pop up the results */
					showPopUp(arrInValidItems,arrValidItems);
				}
			}

		/* Show Pop-Up Box with List of Valsi and Invalid Items */
		private function showPopUp(aInvalidItems:Array,aValidItems:Array):void{
				popUp = UserItemLists(PopUpManager.createPopUp(Application.application as DisplayObject,UserItemLists,true));
				PopUpManager.centerPopUp(popUp);
				popUp.aInvalidItems = aInvalidItems;
				popUp.aValidItems = aValidItems;
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

		/* split a list to an array using the carriage return delimiter */	
		/* private function listToArray(value:String, delimiter:String = "\r"):Array 
			{	
				 trim whitespace 
				var a:Array = new Array();
				for each(var i:String in value.split(delimiter))
							{
							 	a.push(StringUtils.Trim(i));
							}
                return a;
            } */
		/** Handles the IMPORT Items Button Click. Creates list of selected items (removing dupes) and 
		 * then sends the lsit to js via the callWrapper() method : IMPORT_ITEMS	 */	
		public function importItems():void
			{
				arrImportItems = new Array();
				for each(var oItem:Object in this._itemList.source)
							{
								if(oItem['isSelected'] == 1 && arrImportItems.indexOf(oItem['itemGuid']) == -1)
									{arrImportItems.push(oItem['itemGuid'])}
							}
				this.callWrapper(arrImportItems);	
			}

  		/* Send Array of selected items to calling page (via this wrapper) */
	     private function callWrapper(arrItemstoImport:Array):void {
	        var s:String;
	        if (ExternalInterface.available) {
	           var wrapperFunction:String = "finishedSearching";
	           s = ExternalInterface.call(wrapperFunction, arrItemstoImport);
	        } else {
	           s = "Wrapper not available";
	        }
	       // trace(s); 
	     }
	}/* Class end */
}/* Package end */