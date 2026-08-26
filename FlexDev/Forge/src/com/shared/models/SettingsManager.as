package com.shared.models
{
	//import com.shared.events.*;
	import com.shared.events.MainEvent;
	import com.shared.vos.AppSettings;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.system.ApplicationDomain;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.styles.StyleManager;
	import mx.utils.ObjectUtil;
	
	import spark.components.Application;

	[Bindable]
	public class SettingsManager extends EventDispatcher
	{
		/*-...................................... Constructor.......................................*/
		private var _dispatcher:IEventDispatcher;
		public function SettingsManager( dispatcher:IEventDispatcher = null ):void
		{
			if(dispatcher){
				this._dispatcher = dispatcher;
			}
			else{
				this._dispatcher = new EventDispatcher();
			}
			
			_settings.timeZoneOffset = this.getTimeZoneOffSetInUTC();
			_settings.useDayLightSavingsTime = this.useDST();
		}
		
		/*-.........................................Properties..........................................*/
		
		//public static var statSettings:Settings  = new Settings();
		
		private var _settings:Settings = new Settings();
		private var _userId : String;
		private var _programId : int;
		private var _discountType : int;
		private var _formName : String;
		private var _statusFilterOn : int;
		private var _templateFilterId : int;
		private var _brand : String;
		private var _qBrand : String;
		private var _status:int;
		private var _typeCode : String;
		private var _typeGroup : String;
		private var _lblStatus : String;
		private var _logindate : Date;
		private var _iMpId : int;
		private var _source:String;
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
			var app:* = FlexGlobals.topLevelApplication;
	        for (var i:String in FlexGlobals.topLevelApplication.parameters) {
				var sVal:String = FlexGlobals.topLevelApplication.parameters[i];
				
				
	        	switch (i) 
	        		{ 
					    case "userID" : 
					    	_userId 		= sVal;
					        break; 
					    case "programID" : 
					        _programId 		= parseInt(sVal);  
					        break; 
					    case "discountTypeID" :
					    	_discountType 	= parseInt(sVal);
					    	 break;
					    case "formName" :
					    	_formName  		= sVal;
					    	break;   
					    case "statusFilterOn" :
				    		_statusFilterOn = parseInt(sVal);
				    		break; 
				    	case "status" :
				    		_status 		= parseInt(sVal);
				    	break; 
						case "bMarketPrice" :
							if(parseInt(sVal) == 1){
								_settings.bMarketPrice = true;
							}
							break;
						case "templateFilterId" :
							_templateFilterId = parseInt(sVal);
							break;
						case "iMpId" :
							_iMpId  		= parseInt(sVal);
							break; 
						case "source" :
							_source  		= sVal;
							break; 
						case "debug" : 
							_settings.bDebug 		= FlexGlobals.topLevelApplication.parameters[i];
							break;
					    /* add more params here
					    	case "" :
					    	ProgramId = Application.application.parameters[i];  
					        break; */  
					}
	           		//sVars += i + ":" + Application.application.parameters[i] + "\n";
				}
			i = null;
			if(app.loaderInfo  && app.loaderInfo.loaderURL.toString().indexOf('bin-debug') != -1){
				_settings.bDebug = true;
			}
			_settings.userId 		= _userId;
			_settings.discountType 	= _discountType;
			_settings.programId 	= _programId;
			_settings.formName 		= _formName;
			_settings.status 		= _status;
			_settings.statusFilterOn = _statusFilterOn;
			_settings.templateFilterId = _templateFilterId;
			_settings.iMpId 		= _iMpId;
			_settings.source = _source;
			_settings.lblStatus = "Status";
			_settings.sBBDeviationSource = "EDIT";
			//comment next 3 out for deployment
			if(!_userId && !_programId){
				_settings.userId ='01ED443C-9A1B-C993-6BD2867CA7A5FC16' // "01ED443C-9A1B-C993-6BD2867CA7A5FC16"; //Dev_71
			//	_settings.userId =	'F7B6EFBC-B61B-D6CC-181379B2DDDD7CC1';//msaunders2 Kraft stage
			// _settings.userId = '01ED443C-9A1B-C993-6BD2867CA7A5FC16';		
			// _settings.programId 		= 43;//644 //2272;//1527;
			// _settings.templateFilterId =  5;//35;//36;//35 for ip
	
			}
			//Alert.show(_settings.statusFilterOn.toString());
			//_settings.discountType = 2;
			dispatchEvent(new Event('settingsChanged'));
	     	}
	    /* set results from server (remoteobject) call */
	   public function setAppSettings(o:*):void
		{	
		    this.loadURLParameters();
			if(o){
				_settings.appSettings 	= o.APPSETTINGS;
				//Alert.show(ObjectUtil.toString(_settings.appSettings));
				_settings.userId 							= o.USER.stAccessStructure.User_ID;
				_settings.user 								= o.USER;
				_settings.cfApp_buttonHeight  				= o.CFAPP_BUTTONHEIGHT;
				_settings.cfApp_comboBoxHeight  			= o.CFAPP_COMBOBOXHEIGHT;
				_settings.cfApp_comboBoxContentWidth	   	= o.CFAPP_COMBOBOXCONTENTWIDTH;
				_settings.cfApp_textInputHeight  			= o.CFAPP_TEXTINPUTHEIGHT;
				_settings.cfApp_scorecardsortoption  		= o.CFAPP_SCORECARDSORTOPTION;
				_settings.cfApp_scorecardsortmethod  		= o.CFAPP_SCORECARDSORTMETHOD;
				_settings.appFlex.distributorSingularLabel 	= o.APPFLEX.CFAPP_DISTRIBUTORSINGULARLABEL;
				_settings.appFlex.bbLabels				 	= o.APPFLEX.BBLABELS;
				_settings.sURL								= o.sURL;
				_settings.sBBDeviationSource				= "EDIT";
				_settings.appFlex.billToLabel				 = o.APPFLEX.BILLTOLABEL;
				_settings.appSettings.SHOW_HOLDING_PEN 	= o.APPSETTINGS.SHOW_HOLDING_PEN;
				/*_settings.appFlex.var1 	= o.APPFLEX.VAR1;
				_settings.appFlex.var2 	= o.APPFLEX.VAR2;*/
				_settings.brand = o.APPFLEX.BRAND;
				_settings.qBrand = o.APPFLEX.QBRAND;
				_settings.typeCode = o.APPFLEX.TYPECODE;
				_settings.typeGroup = o.APPFLEX.TYPEGROUP;
				_settings.user 			= o.USER;
			}

			this.dispatchEvent(new Event('settingsChanged'));
			//now load Mods
			var evt:MainEvent = new MainEvent(MainEvent.LOAD_MODS_MAIN);
			evt.settings = this._settings;
			this._dispatcher.dispatchEvent(evt);
		}
	   public function setLocalAppSettings(e:MainEvent):void
	   {	
		   
		   this._settings = e.settings;
		   this.dispatchEvent(new Event('settingsChanged'));
	   }
	   public function showSettings(o:Object):void
		{
			Alert.show(ObjectUtil.toString(o.appSettings) + "  ::  " + ObjectUtil.toString(o.appSettings.col1));
		} 
	   
	   /* Get the difference in minutes between UTC and the time zone where the user is accessing the application */			
	   public function getTimeZoneOffSetInUTC():int
	   {
		   var today:Date = new Date();
		   var UTCDiff:int = today.getTimezoneOffset();
		  /*if( this.useDaylightSavingsTime()){
			   UTCDiff = UTCDiff - 60;
		   }*/
		   return UTCDiff;
	   }
	   
	   /* Returns whether the user timezone uses Daylight Savings Time */
	   public function useDST():Boolean{
		   //crete a winter date and sumer date
		   var bUseDST:Boolean;
		   var now:Date = new Date();
		   var winter:Date = new Date(now.getFullYear(),01,01);
		   var summer:Date = new Date(now.getFullYear(),07,01);
		   //get offsets
		   var winterOffset:Number = winter.getTimezoneOffset();
		   var summerOffset:Number = summer.getTimezoneOffset();
		   
		   if(winterOffset == summerOffset){
			   bUseDST = false;
		   }
		   else{
			   bUseDST = true;
		   }
		  /*var nowOffset:Number = now.getTimezoneOffset();*/
		   
		   /*if((nowOffset == summerOffset) && (nowOffset != winterOffset)) {
			   //daylight savings in effect, add one hour
		   } else {
			   //no dst, use nothing
		   }*/ 
		   /*return ((nowOffset == summerOffset) && (nowOffset != winterOffset)) ;*/
		   return bUseDST;
	   }
	   
	   public static function applyRuntimeStyleSheet(s:String,u:UIComponent):void
	   {
		   //var s:String = mx_internal::VERSION;
		   var myPattern:RegExp = /[.]/g; 
		   s = s.replace(myPattern,'');
		   s = s.substr(0,3);
		   switch(s)
		   {
			   case '411':
				  u.styleManager.loadStyleDeclarations("/flex/mainFx411.swf",true,false, ApplicationDomain.currentDomain);
				   break;
			   case '410':
				   u.styleManager.loadStyleDeclarations("/flex/mainFx410.swf",true,false, ApplicationDomain.currentDomain);
				   break;
			   case '460':
				   u.styleManager.loadStyleDeclarations("/flex/mainFx46.swf");
				   break;
			   case '450':
				   u.styleManager.loadStyleDeclarations("/flex/mainFx45.swf");
				   break;
			   default:
				   u.styleManager.loadStyleDeclarations("/flex/mainFx411.swf");
				   break;
		   }
		   
	   }
	   

	}
}
