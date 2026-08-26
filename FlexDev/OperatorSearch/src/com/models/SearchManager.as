package com.models
{
	import com.events.*;
	import com.views.*;
	import com.vos.*;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.external.*;
	import flash.net.SharedObject;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.managers.PopUpManager;
	
	//[Bindable]
	public class SearchManager extends EventDispatcher 
	{
		/*-.........................................Properties..........................................*/
		/* local references for combo box arrays and operator AC */
		private var _operatorList:ArrayCollection= new ArrayCollection();
		private var _arrState:Array = new Array();
		private var _arrOperatorType:Array = new Array();
		private var _arrStatus:Array = new Array();
		
		/* place holders for criteria passed to operatorFilter() */
		private var _state:String = "";
		private var _operatorType:String = "";
		private var _status:String = "";
		private var _searchString:String = "";
		
		/* createlist vars */
		private var arrValidItems:Array = new Array();
		private var arrInValidItems:Array = new Array();
		private var arrItemsToAdd:Array = new Array();
		private var arrImportItems:Array = new Array();
		public	var popUp:UserOperatorLists;
		
		/* ComboBox/Dropdown filter labels  */
		[Bindable] public var lblCbState:String = "";
		[Bindable] public var lblCbOperatorType:String = "";
		[Bindable] public var lblCbStatus:String = "";	
		
		/* Bindable variable to hold the selected items.*/
		[Bindable] public var arrSelectedItems:Array = new Array();
		
		public var sharedObj:SharedObject;
		
		/*-.........................................Setters and Getters..........................................*/
		// bound to dgItems dataprovider
		[Bindable (event="operatorListChanged")]
		public function get operatorList():ArrayCollection
			{	return _operatorList;}
		
		/*  cbState combo box dp */
		[Bindable (event="updCbStateEvent")]
		public function get arrState():Array
			{	return _arrState; }
		
		/*  cbOperatorType  combo box dp */
		[Bindable (event="updCbOperatorTypeEvent")]
		public function get arrOperatorType():Array
			{	return _arrOperatorType; }			
			
		/* cbStatus combo box dp */
		[Bindable (event="updCbStatusEvent")]
		public function get arrStatus():Array
			{	return _arrStatus; }


		[Bindable (event="updCbFilters")]
		public function updFilters():void
			{	
				/* reset combo box arrays */
				this.resetFilters();
				/* populate array with data from filtered Array Collection */
				this._operatorList.toArray().forEach(getUniqueFilters);
				/* sort arrays */
				this.sortFilters();
				
				/* Add the "ALL" Selection as the first element of each array */
				var strAll:String = new String();
				strAll = "";
        		this._arrState.unshift(strAll);
				this._arrOperatorType.unshift(strAll);
				this._arrStatus.unshift(strAll);
				dispatchEvent(new Event('updCbStateEvent'));
				dispatchEvent(new Event('updCbOperatorTypeEvent'));
				dispatchEvent(new Event('updCbStatusEvent'));
			}
		
		/** 
		 * This function updates the filter.
		 * @param acState Argument is array collection of states.
		 * 
		 */		
		public function updStateFilter(acState:ArrayCollection):void
			{	
				/* reset state combo box arrays */
				this._arrState = new Array();
				/* populate array with data from filtered Array Collection */
				acState.toArray().forEach(getUniqueFilters);
				
				/* Add the "ALL" Selection as the first element of each array */
				var strAll:String = new String();
				strAll = "";
        		this._arrState.unshift("Show All "+ lblCbState);
				dispatchEvent(new Event('updCbStateEvent'));
			}
		

		public function updOperatorTypeFilter(acOperatorType:ArrayCollection):void
			{	
				/* reset state combo box arrays */
				this._arrOperatorType = new Array();
				/* populate array with data from filtered Array Collection */
				acOperatorType.toArray().forEach(getUniqueFilters);
				
				/* Add the "ALL" Selection as the first element of each array */
				var strAll:String = new String();
				strAll = "";
        		this._arrOperatorType.unshift("Show All "+ lblCbOperatorType);
				dispatchEvent(new Event('updCbOperatorTypeEvent'));
			}
		
		public function updStatusFilter(acStatus:ArrayCollection):void
			{	
				/* reset state combo box arrays */
				this._arrStatus = new Array();
				/* populate array with data from filtered Array Collection */
				acStatus.toArray().forEach(getUniqueFilters);
				
				/* Add the "ALL" Selection as the first element of each array */
				var strAll:String = new String();
				strAll = "";
        		this._arrStatus.unshift("Show All "+ lblCbStatus);
				dispatchEvent(new Event('updCbStatusEvent'));
			}
				
		/* probably wont need this */	
		public function get searchString():String
			{	return _searchString; }

		
		/*-.........................................Methods..........................................*/
		/* operatorResutls() gets called on application load.  we pass results from db to this method and
		assign local _operatorlist var the value of passed in AC. the local var gets called by a public getter that is bound to the Datagrid.
		Then populate combo bax arrays. */ 
		public function operatorResults(ac:ArrayCollection):void 
			{
				// this._operatorList = ac;
				this._operatorList = new ArrayCollection();
				if( ( ac != null ) &&
	    			( ac is ArrayCollection ) &&
	    			( ac.length > 0 ) )
	    		{
	    			for each(var i:Object in ac){
	    			var arrIndex:int =  arrSelectedItems.indexOf(i['BSA_Operator_ID']);
					var d:GridData = new GridData();
						d.load(i);
						if(arrIndex >= 0){
							d.isSelected = true;
						}
					this._operatorList.addItem(d);
					}
			    }
			    
				dispatchEvent(new Event('operatorListChanged'));
			}
			
		/* used for test of shared objects */
		public function loadResults():void 
			{
				//this._operatorList = ac;
				sharedObj = SharedObject.getLocal("operators");
				this._operatorList = sharedObj.data.operatorList;
				this.updFilters();
				dispatchEvent(new Event('operatorListChanged'));
			}
			

		/* This is what we are here for.  Set some local vars and then run the filterfunction on the Arraycollection */
		public function operatorFilter(searchTerm:String,state:String,operatorType:String,status:String):void 
			{	
				/* update current selections */
				this._searchString = searchTerm;
				this._state = state;
				this._operatorType = operatorType;
				this._status = status;
				
				/* filter the data */
				this._operatorList.filterFunction = this.operatorFilterFunc;
				this._operatorList.refresh();								

				/* broadcast updates */
				dispatchEvent(new Event('operatorListChanged'));

				/* Reload the Combo Box Filters */
				this.updFilters();
			}

		/* run the filter function to return selected rows */
		public function filterSelected():void
			{
				this._operatorList.filterFunction = this.operatorFilterSelectedFunc;
				this._operatorList.refresh();
				dispatchEvent(new Event('operatorListChanged'));
			}

		/* run the function to return all the retruned rows not just filtered, opposite of above */
		public function filterDeSelected():void
			{
				this._operatorList.filterFunction = null;
				this._operatorList.refresh();
				dispatchEvent(new Event('operatorListChanged'));
			}
		
		/* For the arrays that populate the filter dropdowns we do some maint */	
		public function resetFilters():void
			{
				this._arrState = new Array();
				this._arrOperatorType = new Array();
				this._arrStatus = new Array();
			}
			
		public function sortFilters():void
			{
				this._arrState.sort();
				this._arrOperatorType.sort();
				this._arrStatus.sort();
			}
			
		/* UPDATE Filter Drop Downs xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx */
		public function getUniqueFilters(element:*, index:int, arr:Array):void
			{	
				/* State *********** */
				if (_arrState.length != 0) { 
					if (_arrState.indexOf(element.Operator_State)== -1 && element.Operator_State != '') {_arrState.push(element.Operator_State);}
				}
				else if(element.Operator_State != ''){
						_arrState.push(element.Operator_State);
				}
				/* Operator Type *********** */	
				if (_arrOperatorType.length != 0) {
					if (_arrOperatorType.indexOf(element.Operator_Type)== -1 && element.Operator_Type != '') {_arrOperatorType.push(element.Operator_Type);}
				}
				else if(element.Operator_Type != '') {
						_arrOperatorType.push(element.Operator_Type);
				}
				
				/* Status *********** */
				if (_arrStatus.length != 0) {
					if (_arrStatus.indexOf(element.Display_Code)== -1 && element.Display_Code != '') {_arrStatus.push(element.Display_Code);}
				}
				else if(element.Display_Code != '') {
						_arrStatus.push(element.Display_Code);
				}
			}


		/*  MAIN SEARCH FILTER xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx */	
		public function operatorFilterFunc(operator:Object):Boolean
			{
				return (
							(	/* filter the AC against the Drop down filter selections */
								(_state == ' ' || (operator['Operator_State'].toUpperCase().indexOf(_state.toUpperCase()) == 0))
								&&
								(_operatorType == ' ' || (operator['Operator_Type'].toUpperCase().indexOf(_operatorType.toUpperCase()) == 0))
								&&
								(_status == ' ' || (operator['Display_Code'].toUpperCase().indexOf(_status.toUpperCase()) == 0))
							)		
								&& 
							(
								(_searchString == '')
									||	/* if there is anything entered, filter the AC against the search string entered by the user */
								(
									(operator['BSA_Operator_ID'].toUpperCase().indexOf(_searchString.toUpperCase()) != -1)	||
									(operator['Legacy_ID'].toUpperCase().indexOf(_searchString.toUpperCase()) != -1) 		||
									(operator['Operator_Name'].toUpperCase().indexOf(_searchString.toUpperCase()) != -1) 	||
									(operator['Operator_City'].toUpperCase().indexOf(_searchString.toUpperCase()) != -1) 	||
									(operator['Operator_State'].toUpperCase().indexOf(_searchString.toUpperCase()) != -1)
								)
							)
						)
			}
			/* operatorFilterFunc end */
			
		/* FILTER FUNC SELECTED xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx */
		public function operatorFilterSelectedFunc(operator:Object):Boolean
			{
				return operator['isSelected'] == 1
			}/* operatorFilterSelectedFunc end */
		 
		/* FILTER FUNC CREATE LIST xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx */
		/* filter func for create/saved list operators  */
        public function operatorFilterCreateListFunc(operator:Object):Boolean
			{
				return (arrValidItems.indexOf(operator['BSA_Operator_ID']) >= 0)
			}
			
		/* CREATE LIST xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx */	
		public function createList(txt:String):void
			{
				arrItemsToAdd = new Array();
				arrItemsToAdd = listToArray(txt);
				displayList(arrItemsToAdd);
			}
			
		/* DISPLAY List: either already saved or called from create list xxxxxxxxxxxxxxxxxxxxxxxxxxx */
		public function displayList(arrItemsToAdd:Array):void
			{
				arrValidItems = new Array();
				arrInValidItems = new Array();
						for each(var sItem:String in arrItemsToAdd)
						{
							for each(var oOperator:Object in this._operatorList.source)
							{
								if(oOperator['BSA_Operator_ID'].match(new RegExp(sItem, 'i')))
									{	arrValidItems.push(sItem)
										break;
									}
							}
							if(arrValidItems.indexOf(sItem) == -1)
								{arrInValidItems.push(sItem)}
						}
				
				this._operatorList.filterFunction = this.operatorFilterCreateListFunc;
				this._operatorList.refresh();
				this.selectAll();
				dispatchEvent(new Event('operatorListChanged'));
				/* if there are any invalid operators display the valid and invalid lists */
				if(arrInValidItems.length > 0)
				{
					/* if there are any invalid operators pop up the results */
					showPopUp(arrInValidItems,arrValidItems);
				}
			}
			
		/* Show Pop-Up Box with List of Valid and Invalid operators */
		private function showPopUp(aInvalidItems:Array,aValidItems:Array):void{
				popUp = UserOperatorLists(PopUpManager.createPopUp(Application.application as DisplayObject,UserOperatorLists,true));
				PopUpManager.centerPopUp(popUp);
				popUp.aInvalidItems = aInvalidItems;
				popUp.aValidItems = aValidItems;
			}
		
		private function selectAll():void 
		 	{
		   		/* _operatorList is the Var bound to the DP of our datagrid.
		   		it gets updated when we filter so loop over it and select all */
			    for each(var oOperator:Object in this._operatorList)
				   	{
				   		oOperator.isSelected = 1;
				    }
		 	}
		
		/* split a list to an array using the carriage return the value */	
		private function listToArray(value:String, delimiter:String = "\r"):Array 
			{
                return value.split(delimiter);
            }

		/* TRACK operators xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx */
		/* Keep Track of selected operators, so when a new query is fired, we dont loose currently selected operators */	
		public function trackSelectedOperator(oOperator:Object):void{
 				var arrIndex:int = arrSelectedItems.indexOf(oOperator['BSA_Operator_ID']);
 				// if the operator is not in the selected list and selected then add it 
				if(oOperator['isSelected'] == 1 && arrIndex == -1)
					{arrSelectedItems.push(oOperator['BSA_Operator_ID'])}
				// if the operator is in the selected list and deselected then remove it
				if(oOperator['isSelected'] == 0 && arrIndex >= 0)
					{arrSelectedItems.splice(arrIndex,1)}
				// Alert.show("Selected Length : " + arrSelectedItems.length);	
			}
	
		/* IMPORT operators xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx */	
		public function importOperators():void
			{
				this.callWrapper(arrSelectedItems);
			}
		 
  		/* Send Array of selected operators to calling page (via this wrapper) */
	     public function callWrapper(arrItemstoImport:Array):void {
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