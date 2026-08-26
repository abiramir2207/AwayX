package com.shared.models
{
	import com.shared.events.*;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.utils.ObjectUtil;
	[Bindable]
	public class SettingsManager extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		
		private var _settings:Settings = new Settings();
		private var _userId : String;
		private var _programId : int;
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
			//_userId = "248DCC82-19B9-E720-224CF46D9CB1F4F2"
			_settings.userId = "248DCC82-19B9-E720-224CF46D9CB1F4F2"//_userId;
			_settings.programId = 300//_programId;
	     	}
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
	   public function showSettings(o:Object):void
		{
			Alert.show(ObjectUtil.toString(o.appSettings) + "  ::  " + ObjectUtil.toString(o.appSettings.col1));
		} 

	}
}