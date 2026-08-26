package com.shared.models
{
	import com.shared.events.*;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.utils.ObjectUtil;
	[Bindable]
	public class SettingsManager extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		
		public static var statSettings:Settings  = new Settings();
		private var _settings:Settings = new Settings();
		private var _userId : String;
		private var _programId : int;
		private var _discountType : int;
		private var _formName : String;
		private var _statusFilterOn : int;
		private var _templateFilterId : int;
		private var _brand : String;
		private var _qBrand : String;
		private var _typeCode : String;
		private var _typeGroup : String;
		private var _lblStatus : String;
		private var _logindate : Date;
		/*-.........................................Setters and Getters..........................................*/
		
		[Bindable (event="settingsChanged")]
		public function get settings():Settings
		{
			return _settings;
		}
		//commented out.  Not really needed for Binding to work, but might be better "practice"
		/* private var _cfApp_buttonHeight:int;
		[Bindable (event="buttonHeightChanged")]
		public function get cfApp_buttonHeight():int
		{
			return _cfApp_buttonHeight;
		}
		
		private var _cfApp_comboBoxHeight:int;
		[Bindable (event="comboBoxHeightChanged")]
		public function get cfApp_comboBoxHeight():int
		{
			return _cfApp_comboBoxHeight;
		}
		
		private var _cfApp_textInputHeight:int;
		[Bindable (event="textInputChanged")]
		public function get cfApp_textInputHeight():int
		{
			return _cfApp_textInputHeight;
		} */
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
	        for (var i:String in FlexGlobals.topLevelApplication.parameters) {
	        	switch (i) 
	        		{ 
					    case "userID" : 
					    	_userId = FlexGlobals.topLevelApplication.parameters[i];
					        break; 
					    case "programID" : 
					        _programId = FlexGlobals.topLevelApplication.parameters[i];  
					        break; 
					    case "discountTypeID" :
					    	_discountType = FlexGlobals.topLevelApplication.parameters[i];
					    	 break;
					    case "formName" :
					    	_formName = FlexGlobals.topLevelApplication.parameters[i];
					    	break;   
						case "statusFilterOn" :
				    		_statusFilterOn = FlexGlobals.topLevelApplication.parameters[i];
				    		break;
						case "bMarketPrice" :
							if(FlexGlobals.topLevelApplication.parameters[i] == 1){
								_settings.bMarketPrice = true;
							}
							break;
						case "templateFilterId" :
							_templateFilterId = FlexGlobals.topLevelApplication.parameters[i];
							break;
					    /* add more params here
					    	case "" :
					    	ProgramId = Application.application.parameters[i];  
					        break; */  
					}
	           		//sVars += i + ":" + Application.application.parameters[i] + "\n";
				}
			_settings.userId = _userId;
			_settings.discountType = _discountType;
			_settings.programId = _programId;
			_settings.formName = _formName;
			_settings.statusFilterOn = _statusFilterOn;
			_settings.templateFilterId = _templateFilterId;
			_settings.lblStatus = "Status";
			//comment next 3 out for deployment
			if(!_userId && !_programId){
				_settings.userId = 'A9D10DB8-FFA6-A641-033E6F23BAC4E9CA';
				_settings.programId = 1737;//39;//100023;//100009;//1;//99959; //99726; //98928;
				_settings.statusFilterOn = 1;
				//_settings.bMarketPrice = true;//false;//true;
				//_settings.templateFilterId = 113;
			}
			
			//_settings.discountType = 2;
			dispatchEvent(new Event('settingsChanged'));
	     	}
	    /* test method used for appsettings*/
	   public function setAppSettings(o:Object):void
		{
			_settings.appFlex.var1 	= o.APPFLEX.VAR1;
			_settings.appFlex.var2 	= o.APPFLEX.VAR2;
			_settings.appSettings 	= o.APPSETTINGS;
			_settings.brand = o.APPFLEX.BRAND;
			_settings.qBrand = o.APPFLEX.QBRAND;
			_settings.typeCode = o.APPFLEX.TYPECODE;
			_settings.typeGroup = o.APPFLEX.TYPEGROUP;
			_settings.user 			= o.USER;
			_settings.UIAttributes.cfApp_buttonHeight 	= o.UIATTRIBUTES.CFAPP_BUTTONHEIGHT;
			//_cfApp_buttonHeight = _settings.UIAttributes.cfApp_buttonHeight;
			_settings.UIAttributes.cfApp_comboBoxHeight = o.UIATTRIBUTES.CFAPP_COMBOBOXHEIGHT;
			//_cfApp_comboBoxHeight = _settings.UIAttributes.cfApp_comboBoxHeight;
			_settings.UIAttributes.cfApp_textInputHeight = o.UIATTRIBUTES.CFAPP_TEXTINPUTHEIGHT;

			statSettings = _settings;
			//_cfApp_textInputHeight = _settings.UIAttributes.cfApp_textInputHeight;
			//this.showSettings(_settings);
			this.dispatchEvent(new Event('settingsChanged'));
			this.dispatchEvent(new Event('buttonHeightChanged'));
			this.dispatchEvent(new Event('comboBoxHeightChanged'));
			this.dispatchEvent(new Event('textInputHeighChanged'));
		} 
	   public function showSettings(o:Object):void
		{
			Alert.show(ObjectUtil.toString(o.appSettings) + "  ::  " + ObjectUtil.toString(o.appSettings.col1));
		} 

	}
}