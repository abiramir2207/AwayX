package com.models
{
	import com.events.*;
	import com.vos.BudgetLabels;
	import com.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.core.Application;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.utils.ObjectUtil;
	[Bindable]
	public class SettingsManager extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		
		private var _settings:Settings 				= new Settings();
		public	var oBudgetLabels:BudgetLabels		= new BudgetLabels;
		
		private var _userId 	: String;
		private var _programId 	: int;
		private var _logindate 	: Date;
		
		
		/*-.........................................Setters and Getters..........................................*/
		
		[Bindable (event="settingsChanged")]
		public function get settings():Settings
		{
			return _settings;
		}
		
		[Bindable (event="budgetLabelsChanged")]
		public function get budgetLabels():BudgetLabels
		{
			return oBudgetLabels;
		}

		/*-.........................................Methods..........................................*/
		[Bindable (event="saveSettings")]
		public function saveSettings(s:Settings):void
		{
			_settings = s;
			//_settings.load(s);
			dispatchEvent(new Event('settingsChanged'));
		}
		

	    public function loadURLParameters():void {
	    	//var tempSettings:Settings = new Settings();
	    	
	       for (var i:String in Application.application.parameters) {
	        	switch (i) 
	        		{ 
					    case "userID" : 
					    	_userId = Application.application.parameters[i];
					        break; 
					}
				}
			_settings.userId = _userId;
			
			/* _settings.userId = "248DCC82-19B9-E720-224CF46D9CB1F4F2"//_userId; */
		
	     	}
	     	
	      /* public function loadBudgetLabels():void {
	    
			_budgetLabels.userId = "248DCC82-19B9-E720-224CF46D9CB1F4F2"//_userId;
		
	     	} */
	    /* test method used for appsettings*/
	   public function setAppSettings(o:Object):void
		{
			_settings.appFlex.var1 	= o.APPFLEX.VAR1;
			_settings.appFlex.var2 	= o.APPFLEX.VAR2;
			_settings.appSettings 	= o.APPSETTINGS;
			_settings.user 			= o.USER;
			//this.showSettings(_settings);
			this.dispatchEvent(new Event('settingsChanged'));
		} 
		
		public function fnGetBudgetLabels(acBudgetLabels:ArrayCollection):void
		{			
			var tempObj:Object								= acBudgetLabels[0];
			oBudgetLabels._sBudgetDollarLabel				= tempObj['Budget_Dollar_Label'];
			oBudgetLabels._sCommittedDollarLabel			= tempObj['Committed_Dollar_Label'];
			oBudgetLabels._sBudgetBalanceLabel 				= tempObj['Budget_Balance_Label'];
			oBudgetLabels._sApprovedPaymentDollarLabel 		= tempObj['Approved_Payment_Dollar_Label'];
			oBudgetLabels._sAvailableBudgetDollarLabel 		= tempObj['Available_Budget_Dollar_Label'];
			oBudgetLabels._sBudgetClassAssociationLabel 	= tempObj['Budget_Class_Association_Label'];			
		
			this.dispatchEvent(new Event('budgetLabelsChanged'));
		
		}
	
	   public function showSettings(o:Object):void
		{
			Alert.show(ObjectUtil.toString(o.appSettings) + "  ::  " + ObjectUtil.toString(o.appSettings.col1));
		} 

	}
}