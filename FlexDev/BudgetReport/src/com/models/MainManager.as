package com.models
{
	import com.events.*;
	import com.views.*;
	import com.vos.*;
	
	import flash.events.*;
	import flash.external.*;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.*;
	import mx.utils.ObjectUtil;
	
	//[Bindable]
	public class MainManager extends EventDispatcher 
	{
		/*-.........................................Properties..........................................*/
		/* local references for combo box arrays and item AC */
		private var _acData:ArrayCollection			= new ArrayCollection();
		private var _arrAllClass:Array 				= new Array();
		private var _arrSimpleBudget:Array 			= new Array();
		private var _arrBudgetAssociation:Array 	= new Array();
		private var _arrUserPositions:Array 		= new Array();

		[Bindable] public var _sBudgetClassAssociationLabel:String = "";

		//Default displays for the class
		public var sDefaultClass:String 	 		= "Show All Classes";
		public var sDefaultSimpleBudget:String  	= "Show All Budgets";
		public var sDefaultBudgetAssociation:String = "Show All " + _sBudgetClassAssociationLabel;
		public var sDefaultUserPositions:String 	= "Show All User Positions";
		
		//Set up the variables - these start as defaults but will populate with what's passed from the dropdowns
		public var _Class:String 	 				= sDefaultClass;
		public var _SimpleBudget:String  			= sDefaultSimpleBudget;
		public var _BudgetAssociation:String    	= sDefaultBudgetAssociation;
		public var _UserPositions:String 			= sDefaultUserPositions;
		
		//private var _string:String = "";
		private var _settings:Settings 					= new Settings();
		
		/*-.........................................Setters and Getters..........................................*/
		// bound to dgItems dataprovider
		[Bindable (event="dataChanged")]
		public function get acData():ArrayCollection
			{
				return _acData;
			}

		[Bindable (event="updCbClassEvent")]
		public function get arrAllClass():Array
		{	
			return _arrAllClass; 
		} 
		
		[Bindable (event="updSimpleBudgetEvent")]
		public function get arrSimpleBudget():Array
		{	
			return _arrSimpleBudget; 
		} 
		
		[Bindable (event="updBudgetAssociationEvent")]
		public function get arrBudgetAssociation():Array
		{	
			return _arrBudgetAssociation; 
		} 
		[Bindable (event="updUserPositionsEvent")]
		public function get arrUserPositions():Array
		{	
			return _arrUserPositions; 
		} 
		
		
		public function set settings(s:Settings):void 
			{
				this._settings = s;
			}
		public function get settings():Settings 
			{
				return _settings;
			}

		
		/*-.........................................Methods..........................................*/
		/* itemresutls() gets called on application load.  we pass results from db to this method */ 
		public function dataResults(ac:ArrayCollection):void 
			{
				//Alert.show(ac.toString())
				//this._acData = ac;
				/* loop over ac and cast records as a GridData() object */
				if( ( ac != null ) &&
	    			( ac is ArrayCollection ) &&
	    			( ac.length > 0 ) )
	    		{
	    			for each(var i:Object in ac){
					var d:GridData = new GridData();
						d.load(i);
					this._acData.addItem(d);
					} 
			    	//this.saveSOitems();
			    } 
				dispatchEvent(new Event('dataChanged'));				
			}
				
		public function fnBudgetFilter(fClass:String,
 									fSimpleBudget:String,
 									fBudgetAssociation:String,
									fUserPositions:String):void
			{
				var acData:Array = new Array();
				this._Class 			= fClass; 
				this._SimpleBudget 		= fSimpleBudget;
				this._BudgetAssociation = fBudgetAssociation;
				this._UserPositions 	= fUserPositions;		
				/* Alert.show(this._BudgetAssociation.toString());
				Alert.show(sDefaultSimpleBudget.toString()); */
				this._acData.filterFunction = this.budgetFilterFunc;
		 		this.acData.refresh();	 
			}
		
		public function budgetFilterFunc(item:Object):Boolean
		{
      		{
      				return (/* filter the AC against the Drop down filter selections */
						
						(_Class == sDefaultClass || (item['sSimpleBudgetClass'].toUpperCase().indexOf(_Class.toUpperCase()) == 0))
						&& 
						(_SimpleBudget == sDefaultSimpleBudget || (item['sBudget'].toUpperCase().indexOf(_SimpleBudget.toUpperCase()) == 0))
						&&
						(_UserPositions == sDefaultUserPositions || (item['sPositionLabel'].toUpperCase().indexOf(_UserPositions.toUpperCase()) == 0))
						&&
						 (_BudgetAssociation == 'Show All ' + _sBudgetClassAssociationLabel + 's' || (item['sSimpleBudgetClassAssociationNumber'].toUpperCase().indexOf(_BudgetAssociation.toUpperCase()) == 0))
					 	
							)
			}/* budgetFilterFunc end */
		} 	 
		
		/* *********POPULATES DROPDOWNS*********  */		
 		public function fnGetAllClass(acClassResult:ArrayCollection):void
 		{
 			//Alert.show(acClassResult.toString());
			//this line converts the ArrayCollection of the query result to an array for use by the dropdown
			this._arrAllClass = acClassResult.source;
			this._arrAllClass.unshift(sDefaultClass); 
			dispatchEvent(new Event('updCbClassEvent'));
	  	}
	  	
	  	public function fnGetSimpleBudget(acSimpleBudget:ArrayCollection):void
 		{
 			//Alert.show(acSimpleBudget.toString());
			//this line converts the ArrayCollection of the query result to an array for use by the dropdown
			this._arrSimpleBudget = acSimpleBudget.source;
			this._arrSimpleBudget.unshift(sDefaultSimpleBudget); 
			dispatchEvent(new Event('updSimpleBudgetEvent'));
	  	}
	  	public function fnGetBudgetAssociation(acBudgetAssociation:ArrayCollection):void
 		{
 			//Alert.show(acBudgetAssociation.toString());
			//this line converts the ArrayCollection of the query result to an array for use by the dropdown
			this._arrBudgetAssociation = acBudgetAssociation.source;
			this._arrBudgetAssociation.unshift('Show All ' + _sBudgetClassAssociationLabel + 's');
	  		dispatchEvent(new Event('updBudgetAssociationEvent'));
	  	}
	  		public function fnGetUserPositions(acUserPositions:ArrayCollection):void
 		{
 			//Alert.show(acBudgetAssociation.toString());
			//this line converts the ArrayCollection of the query result to an array for use by the dropdown
			this._arrUserPositions = acUserPositions.source;
			 _arrUserPositions.unshift(sDefaultUserPositions); 
			dispatchEvent(new Event('updUserPositionsEvent'));
	  	}
	  	
	  	public function Alerter(xx:*):void
		{
			Alert.show(ObjectUtil.toString(xx));
			
		} 	
	  	
	}/* Class end */
}/* Package end */