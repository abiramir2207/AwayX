package com.ContractProds.models
{
	import com.ContractProds.events.*;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.utils.ObjectUtil;
	import flash.events.IEventDispatcher;

	public class ConProdSettings extends EventDispatcher
	{
		/*-...................................... Constructor.......................................*/
		private var dispatcher:IEventDispatcher;
		public function ConProdSettings( dispatcher:IEventDispatcher ):void
		{
			this.dispatcher = dispatcher;
		}
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
		
		private var _cfApp_buttonHeight:int;
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
	    	//Alert.show(ObjectUtil.toString(FlexGlobals.topLevelApplication.parameters));
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
					    case "brand" :
					    	_brand = FlexGlobals.topLevelApplication.parameters[i];
					    	 break; 
					    case "qBrand" :
					    	_qBrand = FlexGlobals.topLevelApplication.parameters[i];
					    	 break; 
					    case "typeCode" :
					    	_typeCode = FlexGlobals.topLevelApplication.parameters[i];
					    	 break; 
					    case "typeGroup" :
					    	_typeGroup = FlexGlobals.topLevelApplication.parameters[i];
					        break; 
					    /* add more params here
					    	case "" :
					    	ProgramId = FlexGlobals.topLevelApplication.parameters[i];  
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
			//_settings.userId = "248DCC82-19B9-E720-224CF46D9CB1F4F2";
			//_settings.programId = 98928;
			//_settings.discountType = 2;
			dispatchEvent(new Event('settingsChanged'));
	     	}
	    /* test method used for appsettings */
	   public function setAppSettings(o:Object):void
		{
			_settings.appSettings 	= o.APPSETTINGS;
			//_settings.user 			= o.USER;
			_settings.UIAttributes.cfApp_buttonHeight 	= o.UIATTRIBUTES.CFAPP_BUTTONHEIGHT;
			_cfApp_buttonHeight = _settings.UIAttributes.cfApp_buttonHeight;
			_settings.UIAttributes.cfApp_comboBoxHeight = o.UIATTRIBUTES.CFAPP_COMBOBOXHEIGHT;
			_cfApp_comboBoxHeight = _settings.UIAttributes.cfApp_comboBoxHeight;
			_settings.UIAttributes.cfApp_textInputHeight = o.UIATTRIBUTES.CFAPP_TEXTINPUTHEIGHT;
			_cfApp_textInputHeight = _settings.UIAttributes.cfApp_textInputHeight;
			//this.showSettings(_settings);
			this.dispatchEvent(new Event('settingsChanged'));
			this.dispatchEvent(new Event('buttonHeightChanged'));
			this.dispatchEvent(new Event('comboBoxHeightChanged'));
			this.dispatchEvent(new Event('textInputHeighChanged'));
		} 
	   public function showSettings(o:Object):void
		{
			Alert.show(ObjectUtil.toString("  :: " + o));
		} 

	}
}