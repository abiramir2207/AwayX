package com.DistributorSearch.models
{
	import com.DistributorSearch.vos.Settings;
	import com.shared.events.MainEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.messaging.channels.StreamingAMFChannel;
	import mx.utils.ObjectUtil;

	[Bindable]
	/**
	 * Handles the initial load of URL parameters and settings (application and user) from the server
	 * @author msaunders
	 */	
	public class SettingsManager extends EventDispatcher
	{
		/*-...................................... Constructor.......................................*/
		private var _dispatcher:IEventDispatcher;
		public function SettingsManager( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}
		/*-.........................................Properties..........................................*/
		
		private var _settings:Settings = new Settings();
		private var _userId : String;
		private var _programId : int;
		private var _oneDistSelection : Boolean;
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

	    public function loadURLParameters(p:int,bOneDistSelection:Boolean,shipTo:String):void {
	    	//var tempSettings:Settings = new Settings();
			trace('load URL: ' + p.toString());
	        for (var i:String in Application.application.parameters) {
	        	switch (i) 
	        		{ 
					    case "userID" : 
					    	_userId = Application.application.parameters[i];
					        break; 
					    case "programID" : 
					        _programId = Application.application.parameters[i];  
					        break;
					    case "oneDistSelection" :
					    	_oneDistSelection = Boolean(Application.application.parameters[i]);  
					        break;
					    /* add more params here
					    	case "" :
					    	ProgramId = Application.application.parameters[i];  
					        break; */  
					}
	           		//sVars += i + ":" + Application.application.parameters[i] + "\n";
				}
			if(p){
				_programId = p;
			}
			if(bOneDistSelection){
				_oneDistSelection = bOneDistSelection;
			}
			_settings.shipTo = shipTo;
			_settings.userId = _userId;
			_settings.programId = _programId;
			if(!_userId && !_programId){
				//_settings.userId = "A9D10DB8-FFA6-A641-033E6F23BAC4E9CA";
				//_settings.programId 		= 1638;//1527;
			}
			_settings.oneDistSelection = Boolean(_oneDistSelection);
			dispatchEvent(new Event('settingsChanged'));
			
			/*var evt:MainEvent = new MainEvent(MainEvent.SETTINGS_LOADED);
			evt.programId = p;
			evt.bOneDist = _settings.oneDistSelection;
			this._dispatcher.dispatchEvent(evt);*/
	     	}
	    /* test method used for appsettings*/
	   public function setAppSettings(o:Object):void
		{
			_settings.appFlex.col1 	= o.APPFLEX.COL1;
			_settings.appFlex.col2 	= o.APPFLEX.COL2;
			_settings.appFlex.col3 	= o.APPFLEX.COL3;
			_settings.appFlex.col4 	= o.APPFLEX.COL4;
			_settings.appFlex.col5 	= o.APPFLEX.COL5;
			_settings.appFlex.col6 	= o.APPFLEX.COL6;
			_settings.appFlex.distLabel = o.APPFLEX.DISTLABEL;
			_settings.appFlex.oneDistSelection = Boolean(o.APPFLEX.ONEDISTSELECTION);
			_settings.appSettings 	= o.APPSETTINGS;
			_settings.user 			= o.USER;
			_settings.UIAttributes.cfApp_buttonHeight 	= o.UIATTRIBUTES.CFAPP_BUTTONHEIGHT;
			_settings.UIAttributes.cfApp_comboBoxHeight = o.UIATTRIBUTES.CFAPP_COMBOBOXHEIGHT;
			_settings.UIAttributes.cfApp_textInputHeight = o.UIATTRIBUTES.CFAPP_TEXTINPUTHEIGHT;
			//this.showSettings(o.APPFLEX);
			this.dispatchEvent(new Event('settingsChanged'));
			//now load Mods
		
		} 
	   public function showSettings(o:Object):void
		{
			Alert.show(ObjectUtil.toString(o) + "  ::  ");
		} 

	}
}