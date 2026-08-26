package com.DistributorSearch.models
{
	import com.ContractProds.events.ComponentEvent;
	import com.ContractProds.models.ComponentManager;
	import com.DistributorSearch.components.StringUtils;
	import com.DistributorSearch.events.SearchEvent;
	import com.DistributorSearch.views.UserItemLists;
	import com.DistributorSearch.vos.GridData;
	import com.DistributorSearch.vos.Settings;
	import com.asfusion.mate.events.Dispatcher;
	import com.shared.events.MainEvent;
	import com.shared.vos.Payee;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.SharedObject;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.core.IFlexDisplayObject;
	import mx.managers.PopUpManager;
	import mx.utils.ObjectUtil;

	/**
	 * Logic for filtering, selecting, and importing items. Also includes initial data load handlers and Drop down box population.
	 * @author msaunders
	 */	
	public class SearchManager extends EventDispatcher 
	{
		/*-.........................................Properties..........................................*/
		/* local references for combo box arrays and item AC */
		private var _itemList:ArrayCollection= new ArrayCollection();
		private var _soItems:SharedObject;
		private var _dSOlastSavedDate:Date = new Date();
		private var _dTodayDate:Date = new Date();
		public var strAlertMessage:String = new String("");
		private var _arr1:Array = new Array();
		private var _arr2:Array = new Array();
		private var _arr3:Array = new Array();
		private var _arr4:Array = new Array();
		private var _arr5:Array = new Array();
		private var _arr6:Array = new Array();
		private var _sRecordMessage:String = new String('');
		/* place holders for criteria passed to itemFilter() */
		private var _f1:String = "";
		private var _f2:String = "";
		private var _f3:String = "";
		private var _f4:String = "";
		private var _f5:String = "";
		private var _f6:String = "";
		private var _searchString:String = "";
		private var _bFilterMiniItem:Boolean = false;
		/* place column names */
		[Bindable]
		public var _settings:Settings = new Settings();
		/* createlist vars */
		private var arrValidItems:Array = new Array();
		private var arrInValidItems:Array = new Array();
		private var arrItemsToAdd:Array = new Array();
		private var arrImportItems:Array = new Array();
		public var popUp:UserItemLists;
		/* miniItems (180 table) */
		private var _acMiniItems:Array;
		public var sharedObj:SharedObject;
		[Bindable]
		public var AllText:String = "Filter:";
		
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

		/*  cb1 combo box dp */
		[Bindable (event="updCb1Event")]
		public function get arr1():Array
			{	return _arr1; }
		
		/*  cb2  combo box dp */
		[Bindable (event="updCb2Event")]
		public function get arr2():Array
			{	return _arr2; }
			
		/* cb3  combo box dp */
		[Bindable (event="updCb3Event")]
		public function get arr3():Array
			{	return _arr3; }
			
		/* cb4 combo box dp */
		[Bindable (event="updCb4Event")]
		public function get arr4():Array
			{	return _arr4; }
			
		/* cb5 combo box dp */
		[Bindable (event="updCb5Event")]
		public function get arr5():Array
			{	return _arr5; }
			
		/* cb6 combo box dp */
		[Bindable (event="updCb6Event")]
		public function get arr6():Array
			{	return _arr6; }
		/** 
		 * Populate the drop downs and adds header rows : UPD_CB_FILTER
		 */		
		public function updFilters():void
			{	 //Alert.show(ObjectUtil.toString(_settings.settings)); 
					/* reset combo box arrays */
				this.resetFilters();
					/* populate array with data from filtered Ac */
				this._itemList.toArray().forEach(getUniqueFilters);
					/* sort arrays */
				this.sortFilters()
					/* Add the "ALL" Selection as the first element of each array */
				var strAll:String = new String();
        		strAll = this.AllText;
        		this._arr1.unshift(strAll + " " + this._settings.appFlex.col1);
				this._arr2.unshift(strAll + " " + this._settings.appFlex.col2);
				this._arr3.unshift(strAll + " " + this._settings.appFlex.col3);
				this._arr4.unshift(strAll + " " + this._settings.appFlex.col4);
				this._arr5.unshift(strAll + " " + this._settings.appFlex.col5);
				this._arr6.unshift(strAll + " " + this._settings.appFlex.col6);
				dispatchEvent(new Event('updCb1Event'));
				dispatchEvent(new Event('updCb2Event'));
				dispatchEvent(new Event('updCb3Event'));
				dispatchEvent(new Event('updCb4Event'));
				dispatchEvent(new Event('updCb5Event'));
				dispatchEvent(new Event('updCb6Event'));
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
		/*-...................................... Constructor.......................................*/
		private var _dispatcher:IEventDispatcher;
		public function SearchManager( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}
		
		/*-.........................................Methods..........................................*/
		/** itemresutls() gets called on application load.  We pass results from db to this method and
			*assign local _itemlist var the value of passed in AC. the local var gets called by a public getter that is bound to the Datagrid.
			*Then populate combo bax arrays. : GET */ 
		public function itemResults(ac:Array):void 
			{
				var d:GridData = new GridData();
				//TODO:  Grab arrCustAttr fromOBJ.  Build ShowHide checkboxes (dispatch to UI via setter and binding)
				this._itemList = new ArrayCollection(ac);
				
				/* if( ( ac != null ) &&
	    			( ac is ArrayCollection ) &&
	    			( ac.length > 0 ) )
	    		{
	    			for each(var i:Object in ac){
					var d:GridData = new GridData();
						d.load(i);
					this._itemList.addItem(d);
					}
			    } */	
				//this._itemList = ac;
				this.updFilters();
				dispatchEvent(new Event('itemListChanged'));
				selectShipTo();
				// TESTING perf of SharedObjects
				/* sharedObj = SharedObject.getLocal("distributors","/");
				sharedObj.data.itemList = ac;
				sharedObj.flush(); */
				
			}
		public function checkItemList():void 
		{
			if(this.itemList.length == 0){
				var e:SearchEvent = new SearchEvent(SearchEvent.GET);
				e.programId = this._settings.programId;
				_dispatcher.dispatchEvent(e);
			}
			else
			{
				selectShipTo();
			}
		}
		public function selectShipTo():void 
		{
			var s:String = this.settings.shipTo;
			for each(var d:GridData in this.itemList.source){
				if(s != '' && d.baItem == s){
					d.isSelected = true;
				}
				else{
					d.isSelected = false;
				}
			}
		}
		/** used for test of shared objects */
		public function loadResults():void 
			{
				//this._itemList = ac;
				sharedObj = SharedObject.getLocal("distributors","/");
				this._itemList = sharedObj.data.itemList;
				this.updFilters();
				dispatchEvent(new Event('itemListChanged'));
			}
		/** used for test of shared objects.  Decides when to load cached data or get fresh data from server */
		public function loadSOitems(programId:int,discountType:int):void 
			{
				// 1.) go get our SO
				this._soItems = SharedObject.getLocal("distributors","/");
				
				// 2.) if we got a keeper
			    if (this._soItems.size)
			    {	
			    	// 3.) if we have a saved date
			    	if( ( this._soItems.data.dSavedDate != undefined ) &&
			    		( this._soItems.data.dSavedDate is Date ) )
			    	{
			    		// set our dSOlastSavedDate to our received SO's dSavedDate
			    		this._dSOlastSavedDate = this._soItems.data.dSavedDate as Date;
			    		//strAlertMessage += "set our dSOlastSavedDate of " + this._dSOlastSavedDate.toDateString() + " to our received SO's dSavedDate\n";
			    	}
			    	
			    	// 4.) if our 'up to date' dSOlastSavedDate is the same DATE (not 24 hour and not hr/min) as today (dTodayDate), proceed
			    	if(	( this._dSOlastSavedDate.getFullYear() == this._dTodayDate.getFullYear() ) && 
			    		( this._dSOlastSavedDate.getMonth() == this._dTodayDate.getMonth() ) &&
			    		( this._dSOlastSavedDate.getDate() == this._dTodayDate.getDate() ) )
			    	{
			    		if( ( this._soItems.data.acItems != undefined ) &&
			    			( this._soItems.data.acItems != null ) &&
			    			( this._soItems.data.acItems.length > 0 ) )
				    	{
				    		// 5.) this._itemList from so
				    		this._itemList = _soItems.data.acItems as ArrayCollection;
				    		//this.itemResults(_soItems.data.acItems as ArrayCollection);
				    		this.updFilters();
							dispatchEvent(new Event('itemListChanged'));
 
		    				//strAlertMessage += "sent incoming SO to itemResults() from loadSOitems()\n";
				    	}
				    	else
				    	{
				    		// a.) go get the items from the db
				    		dispatchSearchEventGet(programId,discountType);
				    	}
			    	}
			    	else
			    	{
			    		// b.) go get the items from the db
			    		dispatchSearchEventGet(programId,discountType);  		
			    	}
			    }	
			    else
			    {	
			    	// c.) go get the items from the db
		    		dispatchSearchEventGet(programId,discountType);
			    }
			    
			    //Alert.show(strAlertMessage);
			}
		private function saveSOitems():void
		{
			this._soItems.data.acItems = this._itemList;
			this._soItems.data.dSavedDate = _dTodayDate;
		  	this._soItems.flush(10000000);
		    //strAlertMessage += "saveSOitems()\n";
		   // Alert.show(strAlertMessage);	
		}
		private function dispatchSearchEventGet(programId:int,discountType:int):void{
				var e_Dispatcher:Dispatcher = new Dispatcher();
	    		var e:SearchEvent = new SearchEvent(SearchEvent.GET);
	    		e.discountType = discountType;
	    		e.programId = programId;
       			e_Dispatcher.dispatchEvent(e);
		}
		/**Result handler for populating the array that holds the list of items in 180 day table : GET_MINI_ITEMS */
		public function miniItemResults(ac:Array):void 
			{
				this._acMiniItems = ac;
				//Alert.show(" :: " + ObjectUtil.toString(ac))
				dispatchEvent(new Event('miniItemListChanged'));
			}
			
		/** This is what we are here for.  Set some local vars and then run the filterfunction on the Arraycollection : FILTER */
		public function itemFilter(st:String,f1:String,f2:String,f3:String,f4:String,f5:String,f6:String):void 
			{	
				/* update current selections */
				this._searchString = st;
				this._f1 = f1;
				this._f2 = f2;
				this._f3 = f3;
				this._f4 = f4;
				this._f5 = f5;
				this._f6 = f6;
				//Alert.show(ObjectUtil.toString(f1) + " :: \r" + _f1.length + " :: " + _f1[0].valueOf())
				/* filter the data */
				this._itemList.filterFunction = this.itemFilterFunc;
				this._itemList.refresh();
       		
				/* broadcast updates */
				dispatchEvent(new Event('itemListChanged'));
			/* Reload the Combo Box Filters */
/*XXXXXXXXXXXXX UNCOMMENT TO RETAIN CONTEXT SENSITIVE SEARCHES XXXXXXXXXXXXXXXXXXXXXX
				this.updFilters();*/
				
				/* Reset the scrollbar position to the top.*/
		 		//var e_Dispatcher:Dispatcher = new Dispatcher();
				var e:SearchEvent = new SearchEvent(SearchEvent.RESET_SCROLLBAR_POSITION);
       			_dispatcher.dispatchEvent(e);

			}
		/** Run the filter function to return selected rows : FILTER_SELECTED */
		public function filterSelected():void
			{
				this._itemList.filterFunction = this.itemFilterSelectedFunc;
				this._itemList.refresh();
				dispatchEvent(new Event('itemListChanged'));
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
				/* tell the dg that the data has been updated */
				dispatchEvent(new Event('itemListChanged'));
				
				/* Reset the scrollbar position to the top. */
				//var e_Dispatcher:Dispatcher = new Dispatcher();
				var e:SearchEvent = new SearchEvent(SearchEvent.RESET_SCROLLBAR_POSITION);
       			_dispatcher.dispatchEvent(e);
			}

		/* For the arrays that populate the filter dropdowns	we do some maint */	
		private function resetFilters():void
			{
				this._arr1 = new Array();
				this._arr2 = new Array();
				this._arr3 = new Array();
				this._arr4 = new Array();
				this._arr5 = new Array();
				this._arr6 = new Array();
			}
		private function sortFilters():void
			{
				this._arr1.sort();
				this._arr2.sort();
				this._arr3.sort();
				this._arr4.sort();
				this._arr5.sort();
				this._arr6.sort();
			}
	/* UPDATE Filter Drop Downs xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx */
	private function getUniqueFilters(element:*, index:int, arr:Array):void
			{
					/* col1 *********** */
				if (_arr1.length != 0) { 
					if (_arr1.indexOf(element.col1)== -1 && element.col1 != '') {_arr1.push(element.col1);}
				}
				else if(element.col1 != ''){
						_arr1.push(element.col1);
				}
					/* col2 *********** */	
				if (_arr2.length != 0) {
					if (_arr2.indexOf(element.col2)== -1 && element.col2 != '') {_arr2.push(element.col2);}
				}
				else if(element.col2 != '') {
						_arr2.push(element.col2);
				}
					/* col3 *********** */
				if (_arr3.length != 0) {
					if (_arr3.indexOf(element.col3)== -1 && element.col3 != '') {_arr3.push(element.col3);}
				}
				else if(element.col3 != '') {
						_arr3.push(element.col3);
				}
					/* col4 *********** */
				if (_arr4.length != 0) {
					if (_arr4.indexOf(element.col4)== -1 && element.col4 != '') {_arr4.push(element.col4);}
				}
				else if(element.col4 != '') {
						_arr4.push(element.col4);
				}
					/* col5 *********** */
				if (_arr5.length != 0) {
					if (_arr5.indexOf(element.col5)== -1 && element.col5 != '') {_arr5.push(element.col5);}
				}
				else if(element.col5 != '') {
						_arr5.push(element.col5);
				}
					/* col4 *********** */
				if (_arr6.length != 0) {
					if (_arr6.indexOf(element.col6)== -1 && element.col6 != '') {_arr6.push(element.col6);}
				}
				else if(element.col6 != '') {
						_arr6.push(element.col6);
				}
			}


       /*  MAIN SEARCH FILTER xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx */	
		private function itemFilterFunc(item:Object):Boolean
			{
				return (
						(	/* filter the AC against the Drop down filter selections */
							(_f1 == (this.AllText + " " + this._settings.appFlex.col1) || (item['col1'].toUpperCase().indexOf(_f1.toUpperCase()) == 0))
								&&
							(_f2 == (this.AllText + " " + this._settings.appFlex.col2) || (item['col2'].toUpperCase().indexOf(_f2.toUpperCase()) == 0))
								&&
							(_f3 == (this.AllText + " " + this._settings.appFlex.col3) || (item['col3'].toUpperCase().indexOf(_f3.toUpperCase()) == 0)) // fix for null records item['Type_Code_Desc'].toString().length > 0 && 
								&&
							(_f4 == (this.AllText + " " + this._settings.appFlex.col4) || (item['col4'].toUpperCase().indexOf(_f4.toUpperCase()) == 0))
							&&
							(_f5 == (this.AllText + " " + this._settings.appFlex.col5) || (item['col5'].toUpperCase().indexOf(_f5.toUpperCase()) == 0))
							&&
							(_f6 == (this.AllText + " " + this._settings.appFlex.col6) || (item['col6'].toUpperCase().indexOf(_f6.toUpperCase()) == 0))
						)
								&& 
							(
								(_searchString == '')
									||	/* if there is anything entered, filter the AC against the search string entered by the user */
								(
									(item['baItem'].toUpperCase().indexOf(_searchString.toUpperCase()) != -1) ||
									(item['Description'].toUpperCase().indexOf(_searchString.toUpperCase()) != -1) ||
									(item['col1'].toUpperCase().indexOf(_searchString.toUpperCase()) != -1) ||
									(item['col2'].toUpperCase().indexOf(_searchString.toUpperCase()) != -1) ||
									(item['col3'].toUpperCase().indexOf(_searchString.toUpperCase()) != -1) ||
									(item['col4'].toUpperCase().indexOf(_searchString.toUpperCase()) != -1) ||
									(item['col5'].toUpperCase().indexOf(_searchString.toUpperCase()) != -1) ||
									(item['col6'].toUpperCase().indexOf(_searchString.toUpperCase()) != -1)
			
								)
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
				/* Only select All if we can select more than one*/
				/*
				if(this._settings.oneDistSelection == false)
				{
					this.selectAll();
				}
				*/
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
				popUp = UserItemLists(PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject,UserItemLists,true));
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
                return value.split(delimiter);
            } */
		/** Handles the IMPORT Items Button Click. Creates list of selected items (removing dupes) and 
		 * then sends the lsit to js via the callWrapper() method : IMPORT_ITEMS	 */	
		public function importItems():void
			{
				arrImportItems = new Array();
				var p:Payee = new Payee();
				for each(var oItem:Object in this._itemList.source)
							{
								if(oItem['isSelected'] == 1 && arrImportItems.indexOf(oItem['distGuid']) == -1)
									{	arrImportItems.push(oItem['distGuid'])
										p.name = oItem['Description'];
										p.payeeId = oItem['baItem'];
										p.payeeTypeId = ComponentManager.DISTRIBUTOR_TYPE_ID; //TODO: need a constant from payee object here
									}
							}
				//this.callWrapper(arrImportItems);
				/* update the Component with new Payee
				TODO: this needs to be dynamic so later on we can update the Program Dist selection from here as well */	
				var e_Dispatcher:Dispatcher = new Dispatcher();
				var e:ComponentEvent = new ComponentEvent(ComponentEvent.SET_PAYEE,true);
					e.payee = p;
       			e_Dispatcher.dispatchEvent(e);
       			/* Close the popup from the main App */
       			var event:MainEvent = new MainEvent(MainEvent.CLOSE_PAYEE);
				var sharedPayee:Payee = new Payee(p.payeeTypeId,p.name,p.payeeId);
				event.payee = sharedPayee;
       			e_Dispatcher.dispatchEvent(event);
			}
		 
  		/* Send Array of selected items to calling page (via this wrapper) */
	     /*private function callWrapper(arrItemstoImport:Array):void {
	        var s:String;
	        if (ExternalInterface.available) {
	           var wrapperFunction:String = "finishedSearching";
	           s = ExternalInterface.call(wrapperFunction, arrItemstoImport);
	        } else {
	           s = "Wrapper not available";
	        }
	     }*/
	}/* Class end */
}/* Package end */