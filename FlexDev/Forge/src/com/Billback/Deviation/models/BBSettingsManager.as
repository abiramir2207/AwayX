/**
 * This is the settingsManager which sets all the different settings that will be used 
 * in the application. 
 */ 
package com.Billback.Deviation.models
{
	import com.Billback.Deviation.events.*;
	import com.Billback.Deviation.vos.Settings;
	import com.asfusion.mate.events.Dispatcher;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.core.mx_internal;
	import mx.events.BrowserChangeEvent;
	import mx.events.CloseEvent;
	import mx.managers.BrowserManager;
	import mx.managers.IBrowserManager;
	import mx.managers.PopUpManager;
	import mx.messaging.channels.StreamingHTTPChannel;
	import mx.utils.ObjectUtil;
	import mx.utils.StringUtil;
	
	/**
 	* This class sets all the different settings that will be used 
 	* in the application. 
 	*/ 
	[Bindable]
	public class BBSettingsManager extends EventDispatcher
	{
		/*-...................................... Constructor.......................................*/
		private var _dispatcher:IEventDispatcher;
		public function BBSettingsManager( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}
		
		/*-.........................................Properties..........................................*/
		
		private var _settings:Settings = new Settings();
		private var _userId 	: String;
		private var _callerSource : String;		
		private var _programId : int;
		private var _logindate : Date;
		private var _BBID : String; 	
		private var _BBTitle : String;
		private var _BBStartDate : String;
		private var _BBEndDate : String;
		private var _BBAmount : String;
		private var _BBCode : String;
		private var _BBDate : String;
		private var _PayeeName : String;
		private var _BBDevOvPrice : String;
		private var _BBUpdApproveAmt : String;
		private var _BBApproveExpRateLessTol : String;
		private var _BBApproveDisAgree : String;
		private var _BBManualRateCheck : String;
		private var _BBVolumeOverride : String;		
		private var _BBRateOverride : String;		
		private var _BBStatusID : String;
		private var _BBEditable : String;
		private var _ExpBtnBgColor : String;
    	private var _ExpBtnFontColor : String;
    	private var _EltBtnBgColor : String;
	  	private var _EltBtnFontColor : String;
    	private var _ClmBtnBgColor : String;
	  	private var _ClmBtnFontColor : String;
    	private var _SelBtnBgColor : String;
    	private var _SelBtnFontColor  : String; 
		private var _ProfileBBExpected : String;
		private var _ProfileBBELT : String;
		private var _ProfileBBClaimed : String;
		private var _ProfileBBSelected : String;
		private var _BBFractionalVolume : String;
		private var _BBLSClaimedRebateExpected : String;
		
		private var Notification:Alert;
    	private var NotificationTimer:Timer;
		/*-.........................................Setters and Getters..........................................*/
		
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
		* This function loops over the Application Object and sets the <em>userID</em> and <em> BBID</em>
		* variables within the settings Object
		*/  
	  public function loadURLParameters():void 
	  {
			for (var i:String in Application.application.parameters) 
			{
	  		switch (i) 
	      { 
					case "userID" : 
						_userId = Application.application.parameters[i];
					  break; 
					case "BBID" : 
					 	_BBID = Application.application.parameters[i];    
					  break;
					case "source" :
					  _callerSource = Application.application.parameters[i];
					  break;  
					}
				}
				
				// _userId = "248DCC82-19B9-E720-224CF46D9CB1F4F2"
				// _settings.userId = "248DCC82-19B9-E720-224CF46D9CB1F4F2"//_userId;
				// _settings.programId = 300//_programId;
				
				/* Actual settings*/
				_settings.sUserId 			= _userId;
				_settings.sBBID 				= _BBID;
				_settings.sCallerSource = _callerSource;
				
				/* Setting for testing */
			// _settings.sUserId = '9DB94A8F-1372-E732-0AB15D54AB78AB7F';
 
			// only two discount types 1,2
			// _settings.sBBID = '44b05590-4458-442e-a53b-49bcc75d4aa4'; //  5 records
			// All discount types 
			
			// Awayx 
			// _settings.sUserId = '7C1AD487-1372-E732-0AB518C56F2F618F'; //Userid : asrinivasarao1
			//  _settings.sBBID = '1dc908c2-02a2-4542-8f20-817e7654c97f';
			// _settings.sCallerSource = "flexBB";  
			  	
			// solo2
			 // _settings.sUserId = '24E3A618-19B9-E720-220546B0685ECEE7'; //Userid : dkunnath
			 //	_settings.sUserId = '0778E8F3-19B9-E720-225211B4E6EC4B04'; //Userid : asrinivasarao1
			

			// _settings.sBBID = '7a91c3bc-74f5-47aa-b351-c6c8187c5429'; // Editable_RATE is 0 so Rate will not have Radio button
			// _settings.sBBID = 'eadaac9b-ea64-4e82-af65-7a43ff3b8389'; // Editable_RATE is 1 so Rate will have Radio button 
 	
	 	}
	   
	  public function setLocalParameters(event:MainEvent):void 
	  {
		 
		  
		  // _userId = "248DCC82-19B9-E720-224CF46D9CB1F4F2"
		  // _settings.userId = "248DCC82-19B9-E720-224CF46D9CB1F4F2"//_userId;
		  // _settings.programId = 300//_programId;
		  
		  /* Actual settings*/
		  _settings.sUserId 			= event.sUserId;
		  _settings.sBBID 				= event.sBBID;
		  _settings.sCallerSource = event.sCallerSource;
		  
	  }
	  /**
	  * This function loops over the result got back from the coldfusion for the 
	  * details about the Billback_ID and sets them in the 
	  * different variables in the settings Object 
	  * 
	  * @param result Holds the result set from coldfusion as an ArrayCollection 
	  */  
		public function setBillbackHeader(result:ArrayCollection):void
		{
			/* 
				if the flex window throws an error in the below line
				while loading, it is because the user is not logged in 
				and the appSettings are not set 
			*/
			//try{
				for(var i:int = 0; i< result.length; i++)
				{
					_BBCode 		 		 = result.source[i].BB_Code;
					_BBDate 		 		 = result.source[i].BB_Date;
					_BBTitle 		 		 = result.source[i].BB_Title;
					_BBAmount 	 			 = result.source[i].BB_Amount;
					_PayeeName 	 			 = result.source[i].Payee_Name;
					_BBEndDate 	 			 = result.source[i].BB_End_Date;					
					_BBStatusID 			 = result.source[i].Billback_Status_ID;					
					_BBStartDate 			 = result.source[i].BB_Start_Date;
					_BBDevOvPrice 			 = result.source[i].BB_DEVIATIONS_OVERRIDE_PRICE;
					_BBUpdApproveAmt 		 = result.source[i].UPDATE_BB_APPROVE_AMT;
					_BBApproveExpRateLessTol = result.source[i].BB_APPROVE_EXPECTED_RATE_LESS_TOLERANCE;
					_BBApproveDisAgree		 = result.source[i].BB_APPROVE;	
					_BBManualRateCheck 		 = result.source[i].BB_DEV_GRID_MANUAL_RATE_OVERRIDE_CHECK;
					_BBVolumeOverride		 = result.source[i].BB_VOLUME_OVERRIDE;
					_BBRateOverride			 = result.source[i].BB_RATE_OVERRIDE;
					_ExpBtnBgColor			 = result.source[i].EXPBTNBGCOLOR;
	    		 	_ExpBtnFontColor		 = result.source[i].EXPBTNFONTCOLOR;
	     			_EltBtnBgColor 			 = result.source[i].ELTBTNBGCOLOR;
		   			_EltBtnFontColor 	 	 = result.source[i].ELTBTNFONTCOLOR;
	      			_ClmBtnBgColor  		 = result.source[i].CLMBTNBGCOLOR;
		    		_ClmBtnFontColor 		 = result.source[i].CLMBTNFONTCOLOR;
	      			_SelBtnBgColor 			 = result.source[i].SELBTNBGCOLOR;
	      			_SelBtnFontColor  		 = result.source[i].SELBTNFONTCOLOR; 
					_ProfileBBExpected 		 = result.source[i].PROFILE_BB_DEVGRID_EXPECTED;
					_ProfileBBELT			 = result.source[i].PROFILE_BB_DEVGRID_ELT;
					_ProfileBBClaimed		 = result.source[i].PROFILE_BB_DEVGRID_CLAIMED;
					_ProfileBBSelected		 = result.source[i].PROFILE_BB_DEVGRID_SELECTED;
					_BBFractionalVolume		 = result.source[i].BB_FRACTIONAL_VOLUME;
					_BBLSClaimedRebateExpected	= result.source[i].BB_LS_CLAIMED_REBATE_EXPECTED;
					
				}
				
				/* 
					if the status id is 2-Request For Approval or 3-Approved and the update approved 
					amount flag appsetting is set to 1 then the user should be able to edit the record.
					We are doing the above checking here and setting the variable sBBEditable to 1,
					which will be used in all the controls to either enable or disable the control. 
					
				*/	
				
				if (_BBStatusID == '2' || (_BBStatusID == '3' && _BBUpdApproveAmt == '1'))
				{
					_BBEditable = '1';
				}
				else
				{
					_BBEditable = '0';
				}
				_settings.sBBCode 		 		 	= _BBCode;
				_settings.sBBDate 		 			= _BBDate;
				_settings.sBBTitle 		 			= _BBTitle;
				_settings.sBBAmount 	 			= _BBAmount;
				_settings.sPayeeName 	 			= _PayeeName;
				_settings.sBBEndDate 	 			= _BBEndDate;
				_settings.sBBEditable				= _BBEditable;			
				_settings.sBBStatusID   			= _BBStatusID;				
				_settings.sBBStartDate  			= _BBStartDate;
				_settings.sBBDevOvPrice 			= _BBDevOvPrice;
				_settings.sBBUpdApproveAmt 			= _BBUpdApproveAmt;
				_settings.sBBApproveExpRateLessTol 	= _BBApproveExpRateLessTol;	
				_settings.sBBApproveDisAgree		= _BBApproveDisAgree;		
				_settings.sBBManualRateCheck 		= _BBManualRateCheck;	
				_settings.sBBVolumeOverride			= _BBVolumeOverride;
				_settings.sBBRateOverride			= _BBRateOverride;
				_settings.sExpBtnBgColor			= _ExpBtnBgColor;
      			_settings.sExpBtnFontColor			= _ExpBtnFontColor;
      			_settings.sEltBtnBgColor			= _EltBtnBgColor;
		    	_settings.sEltBtnFontColor 			= _EltBtnFontColor;
	      		_settings.sClmBtnBgColor			= _ClmBtnBgColor;
		      	_settings.sClmBtnFontColor			= _ClmBtnFontColor;
	      		_settings.sSelBtnBgColor			= _SelBtnBgColor;
	      		_settings.sSelBtnFontColor			= _SelBtnFontColor; 
				_settings.sProfileBBExpected 		= _ProfileBBExpected;
				_settings.sProfileBBELT			 	= _ProfileBBELT;
				_settings.sProfileBBClaimed		 	= _ProfileBBClaimed;
				_settings.sProfileBBSelected		= _ProfileBBSelected;
				_settings.sBBFractionalVolume		= _BBFractionalVolume;
				_settings.sBBLSClaimedRebateExpected	= _BBLSClaimedRebateExpected;
				
				
		//	}
			//catch(err:Error)
		//	{ 
		//		Alert.show("Looks like you are not logged in. Please make sure you are logged in!!");
		//	}
		}

		/**
		* This function throws an Alert when called.  But the alert stays commented and will be used
		* if there is a need for debugging 
		*/   
		public function showSettings(o:Object):void
		{
			//Alert.show(ObjectUtil.toString(o.appSettings) + "  ::  " + ObjectUtil.toString(o.appSettings.col1));
		} 
 
		/**
		* This function is used in the MainEventMap to show alerts after saving the data.
		* This alert will be shown for 3.5 seconds and automatically close after than 
		* and User will not have an option to click "OK" button as no button will be 
		* displayed in this alert.
		* 
		* @param xx This could be of any type hence * (xx:*) is set as the type for the param
		* @param strTitle This param holds the title that needs to be displayed for the Alert
		* @param doAction This param will be checked and only if it is <strong>"doSave"</strong> the Alert will be displayed   
		*/ 		
		public function saveAlerter(xx:*,strTitle:String,doAction:String):void
		{
			/* 
				Since the xx in case of an error is getting the value "1" the string comparison 
			 	is not working as expected and failing the condition hence checking is made 
			 	for the length
			*/ 
			if (doAction == 'doSaveRecalc')
			{
				// for deviation recalculation
				var eventReloadGrid:MainEvent	= new MainEvent(MainEvent.GET_BILLBACK_DETAILS);
				eventReloadGrid.sBBID 	 		= this.settings.sBBID;
				this._dispatcher.dispatchEvent(eventReloadGrid);
			}
			//if((doAction == 'doSave' || doAction == 'doSaveRecalc') || (ObjectUtil.toString(xx).length == 3) || (ObjectUtil.toString(xx) != '""'))
			if(doAction == 'doSave' || (ObjectUtil.toString(xx).length == 3) || (ObjectUtil.toString(xx) != '""'))
			{
				if (ObjectUtil.toString(xx).length == 3)
				{
					Alert.show(ObjectUtil.toString(xx) + "This billback is locked by another User.  Please lock the billback and try your actions again.","Lock Error!!");
				}
				else
				{
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
					
					// for enabling buttons
					var eventEnableButtons:MainEvent	= new MainEvent(MainEvent.ENABLE_BUTTONS);
					this._dispatcher.dispatchEvent(eventEnableButtons);
		   		}
	   		}
			else if(doAction == 'doSaveApprove')
			{
				var e:MainEvent = new MainEvent ( MainEvent.CLOSE_DEVIATION );
				//go to settlerment tab
				e.doAction = 'settlement';
				this._dispatcher.dispatchEvent( e );
			}
		   /* else if (doAction == 'doSaveApprove')
		   		{
		   		var e_Dispatcher:Dispatcher = new Dispatcher();
		   		var e:MainEvent = new MainEvent(MainEvent.APPROVE);
		   		e.doAction = doAction;
		   		e_Dispatcher.dispatchEvent(e);
		   } */	
		} 
  
  	/**
  	* This function will be called after the x amount of secs to Auto Close the Alert
  	*/  
		private function removeNotification(evt:TimerEvent):void 
		{
			NotificationTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, removeNotification);
			PopUpManager.removePopUp(Notification);

		}
		private function removeNotificationClose(evt:TimerEvent):void 
		{
			NotificationTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, removeNotificationClose);
			PopUpManager.removePopUp(Notification);
			
			var e:MainEvent = new MainEvent ( MainEvent.CLOSE_DEVIATION );
			//go to settlerment tab
			e.doAction = 'settlement';
			this._dispatcher.dispatchEvent( e );
		}
	}
}