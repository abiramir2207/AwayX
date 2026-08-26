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
	public class SettingsManager extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/	
		private var _settings:Settings = new Settings();

		
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
	    	
	        for (var i:String in Application.application.parameters) {
	        	switch (i) 
	        		{ 
					    case "userID" : 
					    	_settings.userId = Application.application.parameters[i];
					        break; 
					    case "programID" : 
					        _settings.programId = Application.application.parameters[i];  
					        break; 
					    case "businessSegmentsOn" :
					    	_settings.businessSegmentsOn = Application.application.parameters[i];
					    	 break; 
					    case "businessSegmentID" :
					    	_settings.businessSegmentID = Application.application.parameters[i];
					    	 break;
					    case "preSelected" :
					    	_settings.preSelected = listToArray(Application.application.parameters[i]);
					    	break;	
					}
	           }
	        
	       
	        // Comment this next section  out - testing purposes only
	        _settings.userId 				=	'27F27BD6-1143-34F0-DD9BAED5F9542ED1' ;			
			_settings.programId				=	71428 ;
			_settings.businessSegmentsOn	=	true ;
			_settings.businessSegmentID 	=	1 ;
			_settings.preSelected			= 	new Array('25275','51070','35755'); // subs in Florida
	        
	        
	        // Comment this next line out - testing purposes only 
			// this.showSettings(_settings);
			
			this.dispatchEvent(new Event('settingsChanged'));
			
		}

	   public function setAppSettings(o:Object):void
		{
			_settings.operatorID			= o.APPFLEX.OPERATORID;
			_settings.operatorSingular		= o.APPFLEX.OPERATORSINGULAR;
			_settings.operatorPlural		= o.APPFLEX.OPERATORPLURAL;
			_settings.city					= o.APPFLEX.CITY;
			_settings.state					= o.APPFLEX.STATE;
			_settings.operatorType			= o.APPFLEX.OPERATORTYPE;
			_settings.status				= o.APPFLEX.STATUS;
			_settings.legacyID				= o.APPFLEX.LEGACYID;
			
			/* UI Attribute Settings */
			_settings.appButtonHeight 		= o.APPFLEX.CFAPP_BUTTONHEIGHT;
			_settings.appComboBoxHeight 	= o.APPFLEX.CFAPP_COMBOBOXHEIGHT;
			_settings.appTextInputHeight 	= o.APPFLEX.CFAPP_TEXTINPUTHEIGHT;
			
			/* App setting */
			_settings.cfApp_showBSAOperators   = o.APPFLEX.CFAPP_SHOWBSAOPERATORS;

			_settings.appSettings 			= o.APPSETTINGS;

			// Comment this next line out - testing purposes only
			// this.showSettings(_settings);
			this.dispatchEvent(new Event('settingsChanged'));
		} 


	   public function showSettings(o:Object):void
		{
			Alert.show(ObjectUtil.toString(" All Settings "
				+ "\n user ID: "			+ ObjectUtil.toString(o.userId)
				+ "\n Program ID: "			+ ObjectUtil.toString(o.programId)
				+ "\n businessSegmentsOn: "	+ ObjectUtil.toString(o.businessSegmentsOn)
				+ "\n businessSegmentID: "	+ ObjectUtil.toString(o.businessSegmentID)
				+ "\n Operator Id: "		+ ObjectUtil.toString(o.operatorID)
				+ "\n Plural: "				+ ObjectUtil.toString(o.operatorPlural)
				+ "\n operator: "			+ ObjectUtil.toString(o.operatorType)
				+ "\n preSelected: "		+ ObjectUtil.toString(o.preSelected)
			));
		}
		
		private function listToArray(value:String, delimiter:String = ","):Array 
		{
            return value.split(delimiter);
        }	
	 
		

	}
}