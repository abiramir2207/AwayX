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
		private var _formName : String;
		private var _statusFilterOn : int;
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

		/*-.........................................Methods..........................................*/
		[Bindable (event="saveSettings")]
		public function saveSettings(s:Settings):void
		{
			_settings = s;
			dispatchEvent(new Event('settingsChanged'));
		}

		/** Load URL paramaters (FLASHVARS)
		 * settings.userId
		 * settings.discountType
		 * settings.programIdramId;
		 * settings.brand
		 * settings.qBrand;
		 * settings.typeCode
		 * settings.typeGroupGroup */
	    public function loadParameters():void {
	    	//Alert.show(ObjectUtil.toString(Application.application.parameters));
	        for (var i:String in Application.application.parameters) {
	        	switch (i) 
	        		{ 
					    case "userID" : 
					    	_userId = Application.application.parameters[i];
					        break; 
					    case "programID" : 
					        _programId = Application.application.parameters[i];  
					        break; 
					    case "discountTypeID" :
					    		_discountType = Application.application.parameters[i];
					    	 	break;
					    case "formName" :
					    		_formName = Application.application.parameters[i];
					    	break;   
							case "statusFilterOn" :
					    		_statusFilterOn = Application.application.parameters[i];
					    	break;   
					    case "brand" :
					    	_brand = Application.application.parameters[i];
					    	 break; 
					    case "qBrand" :
					    	_qBrand = Application.application.parameters[i];
					    	 break; 
					    case "typeCode" :
					    	_typeCode = Application.application.parameters[i];
					    	 break; 
					    case "typeGroup" :
					    	_typeGroup = Application.application.parameters[i];
					        break; 
					    /* add more params here
					    	case "" :
					    	ProgramId = Application.application.parameters[i];  
					        break; */  
					}
				}
				 
			_settings.userId = _userId;
			_settings.discountType = _discountType;
			_settings.programId = _programId;
			_settings.formName = _formName;
			_settings.statusFilterOn = _statusFilterOn;
			_settings.brand = _brand;
			_settings.qBrand = _qBrand;
			_settings.typeCode = _typeCode;
			_settings.typeGroup = _typeGroup;
			_settings.lblStatus = "Status";
			//_settings.userId = 'D1635E3F-19B9-E720-22F5DFCEB4BD2882';
			//_settings.programId = 82;
			//_settings.discountType = 2;
			dispatchEvent(new Event('settingsChanged'));
	     	}
	    /* test method used for appsettings */
	   public function setAppSettings(o:Object):void
		{
			_settings.appSettings 	= o.APPSETTINGS;
			//_settings.user 			= o.USER;
			_settings.UIAttributes.cfApp_buttonHeight 	= o.UIATTRIBUTES.CFAPP_BUTTONHEIGHT;
			_settings.UIAttributes.cfApp_comboBoxHeight = o.UIATTRIBUTES.CFAPP_COMBOBOXHEIGHT;
			_settings.UIAttributes.cfApp_textInputHeight = o.UIATTRIBUTES.CFAPP_TEXTINPUTHEIGHT;
			//this.showSettings(_settings);
			this.dispatchEvent(new Event('settingsChanged'));
		} 
	   public function showSettings(o:Object):void
		{
			Alert.show(ObjectUtil.toString("  :: " + o));
		} 

	}
}