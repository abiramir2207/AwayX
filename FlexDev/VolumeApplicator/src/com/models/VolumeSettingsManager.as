// ActionScript file
/**
 * All model classes are declare within this package
 */
package com.models
{
	import com.events.*;
	import com.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.external.*;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.core.mx_internal;
	import mx.managers.BrowserManager;
	import mx.managers.IBrowserManager;
	import mx.managers.PopUpManager;
	import mx.utils.ObjectUtil;

	
	/**
 	 * This class sets all the different settings that will be used 
 	 * in the application. 
 	 */ 
	[Bindable]
	public class VolumeSettingsManager extends EventDispatcher
	{
		/*-...................................... Constructor.......................................*/
		private var _dispatcher:IEventDispatcher;
		public function VolumeSettingsManager( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}
		
		private var _settings:Settings = new Settings();
		private var _userId:String;
	 	private var _appAreaTitle:String;
	 	//private var _appQtyUOMIDX:String;
	 	//private var _appUOMType:String;
		private var _volQtyUOMIDX:String;
		private var _volUOMType:String;
		private var _appAreaKeyword:String;
		private var _appAreaStartDate:String;
		private var _appAreaEndDate:String;
		private var _appAreaSpanDays:String;
		private var _appAreaContractNumber:String; 
		private var _appProgramType:String;
		private var _appMinGlobalVolume:String;
		private var _appMinGlobalVolumeSizeCS:String;
		private var _appMinGlobalVolumeSizeLB:String;
		private var _appMaxGlobalVolume:String;
		private var _appMaxGlobalVolumeSizeCS:String;
		private var _appMaxGlobalVolumeSizeLB:String;
		private var _appGroupADefault:String;
		private var _appGroupBDefault:String;
		private var _bOpType:String;
		private var _bDirectShipmentShow:String;
		private var _bBillbackShow:String;
		private var _bCreditsShow:String;
		private var _bDetailsDisplay:String;
		private var _strVolumeHelpText:String;
		private var _appProgramID:String;
		private var _profileID:String;
		private var _bOpportunityVolumeShow:Boolean;
  		private var Notification:Alert;
   	 	private var NotificationTimer:Timer;
    	private var browserManager:IBrowserManager;
		//private var objProgramUOM:Object = new Object;
		private var objVolumeUOM:Object = new Object;
		private var objPercentUOM:Object = new Object;
		private var objVolumeUOM2:Object = new Object;
		public var acUOM:ArrayCollection= new ArrayCollection;
		public var acApplyAction:ArrayCollection;
		private var _excludeAutoVolumeUpdates:String;
		private var _volumePageUOMCS:Number;
		private var _volumePageUOMLB:Number;
		private var _autoVolumeExcludeUpdatedData:String;
		

		/**
		* This getter function returns an Object:_settings of type Settings
		*/  
		[Bindable (event="settingsChanged")]
		public function get settings():Settings
		{
			return _settings;
		}
		
		/**
		* This function sets the _settings and dispatches the event <em>settingsChanged</em>
		*/ 
		[Bindable (event="saveSettings")]
		public function saveSettings(s:Settings):void
		{
			_settings = s;
			dispatchEvent(new Event('settingsChanged'));
		}		
 
		/**
		* This function loops over the Application Object and sets the 
		* <em>userID</em>, <em>appProgramID</em> and <em>profileID</em> 
		* variables within the settings Object
		*/  
		public function loadParameters():void 
	 	{
	 		browserManager = BrowserManager.getInstance();
			browserManager.setTitle("Volume Applicator");
	  	for (var i:String in Application.application.parameters) 
	  	{
	    	switch (i) 
	      { 
			    case "userID" : 
			    	_userId = Application.application.parameters[i];
			      break; 
			    case "appProgramID" :
			    	_appProgramID = Application.application.parameters[i];			    	
			    	break;
			    case "profileID" : 
			    	_profileID = 	Application.application.parameters[i];
			    	break;	  
			    	
				}
			}
			
		
			_settings.userId 			= _userId;
			_settings.appProgramID		= _appProgramID;
			_settings.profileID			= _profileID;
			
		
		
		dispatchEvent(new Event('settingsChanged'));
	  }
	  
	  /* *************************************************************************
	  	All the setting that are set using the PropertyInjectors are set within 
	  	the scope of the Flex _settings variables for accessing within the Flex  
	  ************************************************************************* */
	  /**
	  * This function loops over the result got back from the coldfusion for the 
	  * details about the Program_ID and sets them in the 
	  * different variables in the settings Object 
	  * 
	  * @param result holds the result set from coldfusion as an ArrayCollection 
	  */ 	  
	     	
		public function setProgramAttributes(result:ArrayCollection):void
		{
			for(var i:int = 0; i< result.length; i++)
			{
				_appAreaTitle 		 		= result[i].Contract_Title;

				//_appQtyUOMIDX			 	= result[i].Contract_Quantity_UOM_IDX;
				//_appUOMType					= result[i].PrgUOMType;

				_volQtyUOMIDX				= result[i].VolUOMIDX;
				_volUOMType					= result[i].VolUOMType;			
				_appAreaKeyword 	 		= "Program";
				_appAreaStartDate 			= result[i].Contract_Start_Date;
				_appAreaEndDate 	 		= result[i].Contract_End_Date;
				_appAreaSpanDays  			= result[i].Contract_Span;
				_appAreaContractNumber  	= result[i].Contract_Number;
				_appProgramType 			= result[i].Generic_Type;
				_appMinGlobalVolume 		= result[i].Min_Global_Volume;
				_appMinGlobalVolumeSizeCS	= result[i].Min_Global_Volume_Size_CS;
				_appMinGlobalVolumeSizeLB 	= result[i].Min_Global_Volume_Size_LBS;
				_appMaxGlobalVolume 		= result[i].Max_Global_Volume;
				_appMaxGlobalVolumeSizeCS 	= result[i].Max_Global_Volume_Size_CS;
				_appMaxGlobalVolumeSizeLB 	= result[i].Max_Global_Volume_Size_LBS;
				_appGroupADefault 			= result[i].GroupADefault;
				_appGroupBDefault			= result[i].GroupBDefault;
				_bOpType 					= result[i].bOpType.toString();
				_bDirectShipmentShow 		= result[i].bDirectShipmentShow.toString();
				_bBillbackShow 				= result[i].bBillbackShow.toString();
				_bCreditsShow 				= result[i].bCreditsShow.toString();
				_strVolumeHelpText			= result[i].Volume_Help_Text.toString();
				_bDetailsDisplay			= result[i].Volume_Details_Tab_Display;
				_bOpportunityVolumeShow		= result[i].Opportunity_Volume;
				_excludeAutoVolumeUpdates	= result[i].Exclude_From_Auto_Volume_Updates;
				_volumePageUOMCS			= result[i].Volume_Page_UOM_CS;
				_volumePageUOMLB			= result[i].Volume_Page_UOM_LB;
				_autoVolumeExcludeUpdatedData	= result[i].Auto_Volume_Exclude_Updated_Data;
			}	
			
			
			_settings.appAreaTitle 		 		= _appAreaTitle;
			//_settings.appQtyUOMIDX				= _appQtyUOMIDX;
			//_settings.appUOMType				= _appUOMType;
			_settings.volQtyUOMIDX				= _volQtyUOMIDX;
			_settings.volUOMType				= _volUOMType;			
			_settings.appAreaKeyword 	 		= _appAreaKeyword;
			_settings.appAreaStartDate 			= _appAreaStartDate;
			_settings.appAreaEndDate 	 		= _appAreaEndDate;
			_settings.appAreaSpanDays  			= _appAreaSpanDays;
			_settings.appAreaContractNumber  	= _appAreaContractNumber;
			_settings.appProgramType 			= _appProgramType;
			_settings.appMinGlobalVolume 		= _appMinGlobalVolume;
			_settings.appMinGlobalVolumeSizeCS 	= _appMinGlobalVolumeSizeCS;
			_settings.appMinGlobalVolumeSizeLB 	= _appMinGlobalVolumeSizeLB;
			_settings.appMaxGlobalVolume 		= _appMaxGlobalVolume;
			_settings.appMaxGlobalVolumeSizeCS 	= _appMaxGlobalVolumeSizeCS;
			_settings.appMaxGlobalVolumeSizeLB 	= _appMaxGlobalVolumeSizeLB;
			_settings.appGroupADefault 			= _appGroupADefault;
			_settings.appGroupBDefault 			= _appGroupBDefault;
			_settings.bOpType 					= _bOpType;
			_settings.bDirectShipmentShow 		= _bDirectShipmentShow;
			_settings.bBillbackShow 			= _bBillbackShow;
			_settings.bCreditsShow 				= _bCreditsShow;
			_settings.strVolumeHelpText			= _strVolumeHelpText;
			_settings.bDetailsDisplay			= _bDetailsDisplay;
			_settings.bOpportunityVolumeShow	= _bOpportunityVolumeShow;
			_settings.volumePageUOMCS			= _volumePageUOMCS;
			_settings.volumePageUOMLB			= _volumePageUOMLB;
			_settings.autoVolumeExcludeUpdatedData			= _autoVolumeExcludeUpdatedData;
			//objProgramUOM.label 				= this._appUOMType;
			//objProgramUOM.data 					= this._appQtyUOMIDX;
			objVolumeUOM.label 					= this._volUOMType;
			objVolumeUOM.data 					= this._volQtyUOMIDX;
			//acUOM.addItem(objVolumeUOM);
			objPercentUOM.label					= "%";
			objPercentUOM.data					= 3;
			//acUOM.addItem(objPercentUOM);
			this.getApplyActions(_bOpportunityVolumeShow);
			// handle for which UOM column to display
			if (this._volumePageUOMCS == 1){
				_settings.bCasesVolumeShow = true;
				objVolumeUOM2.label					= "LB";
				objVolumeUOM2.data					= 2;
				//acUOM.addItem(objVolumeUOM2);
				if (this._bOpportunityVolumeShow){
					_settings.bOpportunityCasesVolumeShow = true;
				}
			}
			
			if(this._volumePageUOMLB == 1){
				_settings.bPoundsVolumeShow = true;
				objVolumeUOM2.label					= "CS";
				objVolumeUOM2.data					= 1;
				//acUOM.addItem(objVolumeUOM2);
				if (this._bOpportunityVolumeShow){
					_settings.bOpportunityPoundsVolumeShow = true;
				}
			}
			
			// D35145: Volume Applicator - Disable Auto Volume
			
			if (this._excludeAutoVolumeUpdates == 'true'){
				_settings.excludeAutoVolumeUpdates = true;
			}
			else{
				_settings.excludeAutoVolumeUpdates = false;
			}
			
	 	} 
		
		public function getProgramSettings(o:Object):void
		{
			_settings.customer_Label	 					 = o.APPFLEX.CFAPP_CUSTOMERLABEL;
			_settings.item_Label	 		 					 = o.APPFLEX.CFAPP_ITEMLABEL;
			_settings.pound_Label	 		 					 = o.APPFLEX.CFAPP_POUNDLABEL;
			_settings.operator_Label	 					 = o.APPFLEX.CFAPP_OPERATORLABEL;
			_settings.rebatePercentageOnNetSales = o.APPFLEX.CFAPP_REBATEPERCENTAGEONNETSALES;	
		}	
		
		public function getApplyToUOM(result:ArrayCollection):void
		{
			for(var i:int = 0; i< result.length; i++)
			{
				var obj:Object = new Object;
				obj.label 					= result[i].Abbreviation;
				obj.data 					= result[i].Unit_Of_Measure_ID;
				acUOM.addItem(obj);
				
			}	
			
		} 
	
		
		/**
		* This function throws an Alert when called.  But the alert stays commented and will be used
		* if there is a need for debugging 
		*/ 
		public function showSettings(o:Object):void
		{
			//Alert.show(ObjectUtil.toString("  :: " + o));
		} 
	 
	 /* ************************************************************************
			showAlerter() function is a function that is used in the MainEventMap
			to show alerts for testing the coding
		************************************************************************ */			
 	
 		public function showAlerter(xx:*,strTitle:String):void
 		{
 			Alert.show(ObjectUtil.toString(xx),strTitle);
 		}
 	
 		/**
 		* This function is used in the MainEventMap to show alerts after
 		* saving the data. This alert will be shown for 2.5 seconds and automatically
 		* close after that and User will not have an option to click "OK" button
 		* as no button will be displayed in this alert.
		*/
		
		/* public function saveAlerter(xx:*,strTitle:String):void
		{
			
			var s:String;
      if (ExternalInterface.available) 
      {
      	var wrapperFunction:String = "fnRefreshParent";
        s = ExternalInterface.call(wrapperFunction);
      } 
      else 
      {
       // s = "Wrapper not available";
        Alert.show(ObjectUtil.toString(xx),strTitle);
      }
			
		} */
			
		
	  	public function saveAlerter(xx:*,strTitle:String,saveType:String):void{
				NotificationTimer = new Timer(2500, 1);
	      		NotificationTimer.addEventListener(TimerEvent.TIMER_COMPLETE, removeNotification);
	      		Notification = 	Alert.show(ObjectUtil.toString(xx),strTitle);
	      		var buttons:Array = Notification.mx_internal::alertForm.mx_internal::buttons;
				for ( var i:int=0; i<buttons.length; i++ )
				{
					Notification.mx_internal::alertForm.removeChild(Notification.mx_internal::alertForm.mx_internal::buttons[i]);
				}
				NotificationTimer.reset();
	      		NotificationTimer.start();
				var eventEnableSave:VolumeApplicatorEvent = new VolumeApplicatorEvent(VolumeApplicatorEvent.ENABLE_SAVE);
				this._dispatcher.dispatchEvent(eventEnableSave);
				
	      		var s:String;
	      		if (ExternalInterface.available && saveType != '1') 
	      		{
	      			var wrapperFunction:String = "fnRefreshParent";
	        		s = ExternalInterface.call(wrapperFunction);
	      		} 
		} 
	  
		private function removeNotification(evt:TimerEvent):void{
	    	PopUpManager.removePopUp(Notification);
	    }
		
		public function getApplyActions(oppVolume:Boolean):void{
		
			var arrActions:Array= 
				[
					{label:"Apply...", data:"0"},
					{label:"To Selected Items", data:"1"},
					{label:"To All Items", data:"2"}
				];
			if (oppVolume){
				arrActions.push({label:"To Selected Opp Items", data:"4"});
				arrActions.push({label:"To All Opp Items", data:"5"});
				arrActions.push({label:"As Total Opp Prg Vol", data:"6"});
			}
			arrActions.push({label:"As Total Prg Vol", data:"3"});
			
			this.acApplyAction = new ArrayCollection(arrActions);
		}
	  
	} // Class Ends
} //Package Ends