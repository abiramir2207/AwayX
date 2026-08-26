package com.models
{
	import com.events.*;
	import com.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.utils.ObjectUtil;
	[Bindable]
	/**
	 * Handles the initial load of URL parameters and settings (application and user) from the server
	 * @author msaunders
	 */	
	public class SettingsManager extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		
		private var _settings:Settings = new Settings();
		private var _userId : String;
		private var _programId : int;
		private var _discountType : int;
		private var _logindate : Date;
		/*-.........................................Setters and Getters..........................................*/
		
		[Bindable (event="settingsChanged")]
		public function get settings():Settings
		{
			return _settings;
		}

		/*-.........................................Methods..........................................*/
		[Bindable (event="saveSettings")]
		public function saveSettings(s:Settings):void
		{
			_settings = s;
			//_settings.load(s);
			dispatchEvent(new Event('settingsChanged'));
		}
		
			//Contract_Main_Id=19189&Discount_Type_ID=2&User_ID=D1635E3F-19B9-E720-22F5DFCEB4BD2882",
		//private var sVars:String
	    public function loadURLParameters():void {
	    	//var tempSettings:Settings = new Settings();
	        for (var i:String in Application.application.parameters) {
	        	switch (i) 
	        		{ 
					    case "userID" : 
					    	_userId = Application.application.parameters[i];
					        break; 
					    case "programID" : 
					        _programId = Application.application.parameters[i];  
					        break;
					    /* add more params here
					    	case "" :
					    	ProgramId = Application.application.parameters[i];  
					        break; */  
					}
	           		//sVars += i + ":" + Application.application.parameters[i] + "\n";
				}
				//Alert.show(sVars);
			_settings.userId = _userId;
			_settings.programId = _programId;
			//dispatchEvent(new Event('settingsChanged'));
			//var event:SearchEvent = new SearchEvent(SearchEvent.LOAD_APP_SETTINGS);
			//dispatchEvent(event); 
	     	}
	    /* test method used for appsettings*/
	   public function setAppSettings(o:Object):void
		{
			_settings.appFlex.col1 = o.APPFLEX.COL1;
			_settings.appFlex.col2 = o.APPFLEX.COL2;
			_settings.appFlex.col3 = o.APPFLEX.COL3;
			_settings.appFlex.col4 = o.APPFLEX.COL4;
			_settings.appFlex.col5 = o.APPFLEX.COL5;
			_settings.appFlex.col6 = o.APPFLEX.COL6;
			_settings.appFlex.brokerLabel = o.APPFLEX.BROKERLABEL;
			
			_settings.appSettings = o.APPSETTINGS;
			_settings.user = o.USER;
			
			_settings.UIAttributes.cfApp_buttonHeight		= o.UIATTRIBUTES.CFAPP_BUTTONHEIGHT;
			_settings.UIAttributes.cfApp_comboBoxHeight		= o.UIATTRIBUTES.CFAPP_COMBOBOXHEIGHT;
			_settings.UIAttributes.cfApp_textInputHeight	= o.UIATTRIBUTES.CFAPP_TEXTINPUTHEIGHT;
			
			//this.showSettings(_settings);
			this.dispatchEvent(new Event('settingsChanged'));
		} 
	   public function showSettings(o:Object):void
		{
			Alert.show(ObjectUtil.toString(o.appSettings) + "  ::  " + ObjectUtil.toString(o.appSettings.col1));
		} 

	}
}