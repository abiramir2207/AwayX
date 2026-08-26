// ActionScript file
package com.models
{
	import com.asfusion.mate.events.Dispatcher;
	import com.events.*;
	import com.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.utils.ObjectUtil;
	
	[Bindable]
	/**
	 * This handles all the the settings - Application, profile etc.
	 */
	public class ProgramSettingsManager extends EventDispatcher
	{
		private var _settings:Settings = new Settings();
		private var _userId : String;
		private var _programId : int;
		private var _status: String;
		private var _reload: String;
		private var _logindate : Date;
		private var _importlist_type: Boolean;
		
		private var _Creating_User_Position: int;
		private var _Include_work_in_progress_below_me: int;
		
		public function ProgramSettingsManager():void
		{
			_settings.timeZoneOffset = this.getTimeZoneOffSetInUTC();
			_settings.useDayLightSavingsTime = this.useDST();
		}
		
		[Bindable (event="settingsChanged")]
		public function get settings():Settings
		{
			return _settings;
		}
		
		[Bindable (event="saveSettings")]
		public function saveSettings(s:Settings):void
		{
			_settings = s;
			dispatchEvent(new Event('settingsChanged'));
		}		
		
		/**
		 * Pass values to flex through the URL.
		 */  
		public function loadURLParameters():void {
			//_userId = 'D1635E3F-19B9-E720-22F5DFCEB4BD2882';
			
			for (var i:String in Application.application.parameters) {
				switch (i) 
				{ 
					case "userID" : 
						_userId = Application.application.parameters[i];
						break; 
					case "status" : 
						_status = Application.application.parameters[i];
						//Alert.show(Application.application.parameters[i]);
						break; 
					case "reload" : 
						_reload = Application.application.parameters[i];
						break; 
					
					case "importlist_type" : 
						_importlist_type = Application.application.parameters[i];
						break;
					
					case "Creating_User_Position" : 
						//Alert.show(i);
						//Alert.show(Application.application.parameters[i]);
						_Creating_User_Position = Application.application.parameters[i];
						break;
					
					case "Include_work_in_progress_below_me" : 
						//Alert.show(i);
						//Alert.show(Application.application.parameters[i]);
						_Include_work_in_progress_below_me = Application.application.parameters[i];
						break;
					
					
				}
			}
			_settings.userId = _userId;
			_settings.status = _status;
			_settings.reload = _reload;
			_settings.importlist_type = _importlist_type;
			_settings.Creating_User_Position = _Creating_User_Position;
			_settings.Include_work_in_progress_below_me = _Include_work_in_progress_below_me;
			
			
			if(!_settings.userId ){
				_settings.userId = "A9D10DB8-FFA6-A641-033E6F23BAC4E9CA";
			}
		}
		
		/* *************************************************************************
		All the setting that are set using the PropertyInjectors are set within 
		the scope of the Flex _settings variables for accessing within Flex  
		************************************************************************* */
		/**
		 * Make the settings (application, profile etc) available in Flex.
		 * After the settings are loaded, Call the "EVT_LOADCOMBOS" event to load
		 the search options.
		 */  	
		public function setAppSettings(o:Object):void
		{
			_settings.appFlex.cfApp_familyLabel				   = o.APPFLEX.CFAPP_FAMILYLABEL;
			_settings.appFlex.cfApp_buyingGroupLabel  		   = o.APPFLEX.CFAPP_BUYINGGROUPLABEL;
			_settings.appFlex.cfApp_operatorLabel    		   = o.APPFLEX.CFAPP_OPERATORLABEL;
			_settings.appFlex.cfApp_operatorIDLabel    		   = o.APPFLEX.CFAPP_OPERATORIDLABEL;
			_settings.appFlex.cfApp_operatorNameLabel    	   = o.APPFLEX.CFAPP_OPERATORNAMELABEL;
				
			_settings.appFlex.cfApp_distributorLabel 		   = o.APPFLEX.CFAPP_DISTRIBUTORLABEL;
			_settings.appFlex.cfApp_referencenumberlabel	   = o.APPFLEX.CFAPP_REFERENCENUMBERLABEL;
			_settings.appFlex.cfApp_qbrandlabel				   = o.APPFLEX.CFAPP_QBRANDLABEL;
			_settings.appFlex.cfApp_typegrouplabel		       = o.APPFLEX.CFAPP_TYPEGROUPLABEL;
			_settings.appFlex.cfApp_typecodelabel		       = o.APPFLEX.CFAPP_TYPECODELABEL;
			_settings.appFlex.cfApp_itemlabel		           = o.APPFLEX.CFAPP_ITEMLABEL;
			_settings.appFlex.cfApp_shardshiptolabel		   = o.APPFLEX.CFAPP_SHARDSHIPTOLABEL;
			_settings.appFlex.cfMis_fileSize				   = o.APPFLEX.CFMIS_FILESIZE;
			_settings.appFlex.cfMis_dtFileModified		       = o.APPFLEX.CFMIS_DTFILEMODIFIED;
			
			_settings.appFlex.cfApp_deleteIsCancelAutoRenew    = o.APPFLEX.CFAPP_DELETEISCANCELAUTORENEW;
			_settings.appFlex.cfApp_deleteProgramMessage       = o.APPFLEX.CFAPP_DELETEPROGRAMMESSAGE;			
			_settings.appFlex.cfApp_approvalSpendingCapOn      = o.APPFLEX.CFAPP_APPROVALSPENDINGCAPON;
			_settings.appFlex.cfApp_pgmScorecardRevisionReport = o.APPFLEX.CFAPP_PGMSCORECARDREVISIONREPORT;
			_settings.appFlex.cfApp_sendToSAP   			   = o.APPFLEX.CFAPP_SENDTOSAP;
			_settings.appFlex.cfApp_programAgreeEscalate   	   = o.APPFLEX.CFAPP_PROGRAMAGREEESCALATE;
			_settings.appFlex.cfApp_approvalLayeredOn   	   = o.APPFLEX.CFAPP_APPROVALLAYEREDON;
			_settings.appFlex.cfApp_approvalStandardOn  	   = o.APPFLEX.CFAPP_APPROVALSTANDARDON;
			_settings.appFlex.cfApp_QuoteLetters		  	   = o.APPFLEX.CFAPP_QUOTELETTERS;
			_settings.appFlex.cfApp_ShowClaimRatesReport 	   = o.APPFLEX.CFAPP_PROGRAMCLAIMRATESREPORTAVAILABLE;
			_settings.appFlex.cfApp_ShowPricingReport 		   = o.APPFLEX.CFAPP_SHOWPRICINGREPORT;
			_settings.appFlex.cfApp_exactlistmatchingon		   = o.APPFLEX.CFAPP_EXACTLISTMATCHINGON;
			_settings.appFlex.cfApp_rolloverprogramson		   = o.APPFLEX.CFAPP_ROLLOVERPROGRAMSON;
			_settings.appFlex.cfApp_pgmpostapprovalstatus	   = o.APPFLEX.CFAPP_PGMPOSTAPPROVALSTATUS;
			_settings.appFlex.cfApp_buttonHeight		   	   = o.APPFLEX.CFAPP_BUTTONHEIGHT;
			_settings.appFlex.cfApp_comboBoxHeight		   	   = o.APPFLEX.CFAPP_COMBOBOXHEIGHT;
			_settings.appFlex.cfApp_comboBoxContentWidth	   = o.APPFLEX.CFAPP_COMBOBOXCONTENTWIDTH;
			_settings.appFlex.cfApp_textInputHeight		   	   = o.APPFLEX.CFAPP_TEXTINPUTHEIGHT;
			_settings.appFlex.cfApp_scorecardsortoption        = o.APPFLEX.CFAPP_SCORECARDSORTOPTION;
			_settings.appFlex.cfApp_scorecardsortmethod        = o.APPFLEX.CFAPP_SCORECARDSORTMETHOD;
			_settings.appFlex.cfApp_exactlistmatchingonmessage = o.APPFLEX.CFAPP_EXACTLISTMATCHINGONMESSAGE;			
			_settings.appFlex.cfApp_displayTradeDollars 		= o.APPFLEX.CFAPP_DISPLAYTRADEDOLLARS;
			_settings.appFlex.cfApp_displayPaymentDollars 		= o.APPFLEX.CFAPP_DISPLAYPAYMENTDOLLARS;
			_settings.appFlex.cfApp_displayVolume				= o.APPFLEX.CFAPP_DISPLAYVOLUME;
			_settings.appFlex.cfApp_displayOperatorInfo			= o.APPFLEX.CFAPP_DISPLAYOPERATORINFO;
			_settings.appFlex.cfApp_displayTradeDollarsLabel 	= o.APPFLEX.CFAPP_DISPLAYTRADEDOLLARSLABEL;
			_settings.appFlex.cfApp_displayPaymentDollarsLabel 	= o.APPFLEX.CFAPP_DISPLAYPAYMENTDOLLARSLABEL;
			_settings.appFlex.cfApp_displayVolumeLabel			= o.APPFLEX.CFAPP_DISPLAYVOLUMELABEL;	
			_settings.appFlex.cfApp_BusinessSegmentsLabel		= o.APPFLEX.CFAPP_BUSINESSSEGMENTSLABEL;
			_settings.appFlex.cfApp_showbudgetDropdown			= o.APPFLEX.CFAPP_SHOWBUDGETDROPDOWN;	
			_settings.appFlex.cfApp_releaseSettlement      	    = o.APPFLEX.CFAPP_RELEASESETTLEMENT;
			_settings.appFlex.cfApp_programlocktypeid      	    = o.APPFLEX.CFAPP_PROGRAMLOCKTYPEID;
			_settings.appFlex.cfApp_businesssegmenton      	    = o.APPFLEX.CFAPP_BUSINESSSEGMENTON;
			_settings.appFlex.cfApp_BestPlanOn					= o.APPFLEX.CFAPP_BESTPLANON;
			
			_settings.appFlex.cfPro_deleteProgramAccess   	   = o.APPFLEX.CFPRO_DELETEPROGRAMACCESS;
			_settings.appFlex.cfPro_massRFAProgramApprove      = o.APPFLEX.CFPRO_MASSRFAPROGRAMAPPROVE;
			_settings.appFlex.cfPro_readOnlyCatalogAccess      = o.APPFLEX.CFPRO_READONLYCATALOGACCESS;						
			_settings.appFlex.cfPro_seeAwardedInCatalog        = o.APPFLEX.CFPRO_SEEAWARDEDINCATALOG;
			_settings.appFlex.cfPro_RFAAgreed                  = o.APPFLEX.CFPRO_RFAAGREED;
			_settings.appFlex.cfPro_createProgramAccess        = o.APPFLEX.CFPRO_CREATEPROGRAMACCESS;
			_settings.appFlex.cfPro_searchdocuments        	   = o.APPFLEX.CFPRO_SEARCHDOCUMENTS;
			_settings.appFlex.cfPro_releaseSettlement          = o.APPFLEX.CFPRO_RELEASESETTLEMENT;
				
			_settings.appSettings = o.APPSETTINGS;
			_settings.user = o.USER;
			dispatchEvent(new Event('settingsChanged'));
			/*
			After the settings are loaded, Call the "EVT_LOADCOMBOS" event to load
			the search options.
			*/
			var e_Dispatcher:Dispatcher = new Dispatcher();
			var e:SearchProgramEvent = new SearchProgramEvent(SearchProgramEvent.EVT_LOADCOMBOS);
			e_Dispatcher.dispatchEvent(e);
		} 
		
		public function showSettings(o:Object):void
		{
			Alert.show(ObjectUtil.toString("  :: " + o));
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
	} // Class Ends
} //Package Ends