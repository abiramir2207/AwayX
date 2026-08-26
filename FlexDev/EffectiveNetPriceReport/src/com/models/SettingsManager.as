package com.models
{
	import com.events.*;
	import com.vos.NetPriceSettings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.utils.ObjectUtil;
	[Bindable]
	public class SettingsManager extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		
		private var _settings:NetPriceSettings = new NetPriceSettings();
		private var _userId : String;
		private var _logindate : Date;
		/*-.........................................Setters and Getters..........................................*/
		
		[Bindable (event="settingsChanged")]
		public function get settings():NetPriceSettings
		{
			return _settings;
		}

		/*-.........................................Methods..........................................*/
		[Bindable (event="saveSettings")]
		public function saveSettings(s:NetPriceSettings):void
		{
			_settings = s;
			//_settings.load(s);
			dispatchEvent(new Event('settingsChanged'));
		}

	    public function loadURLParameters():void {
	    	
	    	_userId = "01590773-8F5D-4348-83E869203577507B"; // dkunnath
			//_userId = "520F3454-D56B-B01B-C244AF530CB2CD09"; // dkunnath1

	    	for (var i:String in Application.application.parameters) {
	        	switch (i) 
	        		{ 
					    case "userID" : 
					    	_userId = Application.application.parameters[i];
					        break;		    
					}
	           		//sVars += i + ":" + Application.application.parameters[i] + "\n";
				}
				
			_settings.userId = _userId;
			
	     	}
	    /* test method used for appsettings*/
	   public function setAppSettings(o:Object):void
		{
			_settings.appFlex.brokerlabel 	= o.APPFLEX.BROKERLABEL;
			_settings.appFlex.regionlabel 	= o.APPFLEX.REGIONLABEL;
			_settings.appFlex.familylabel 	= o.APPFLEX.FAMILYLABEL;
			_settings.appFlex.buyinggrouplabel 	= o.APPFLEX.BUYINGGROUPLABEL;
			_settings.appFlex.typecodelabel 	= o.APPFLEX.TYPECODELABEL;
			_settings.appFlex.operatorlabel 	= o.APPFLEX.OPERATORLABEL;
			_settings.appFlex.itemlabel 	= o.APPFLEX.ITEMLABEL;
			_settings.appFlex.shardshiptolabel 	= o.APPFLEX.SHARDSHIPTOLABEL;
			_settings.appFlex.distributorlabel 	= o.APPFLEX.DISTRIBUTORLABEL;
			
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