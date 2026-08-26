package com.shared.vos
{
	import flash.events.EventDispatcher;
	[Bindable]
	public class Settings extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		/** Comes in URL flashvars : GUID (cf createuuid() 35-character xxxxxxxx-xxxx-xxxx-xxxxxxxxxxxxxxxx) from _Users.user_id table*/
		public var userId : String;
		/** Comes in URL flashvars : contract_main_id so we can find already selected products*/
		public var programId : int;
		/** Comes in URL flashvars : discount_type_id so we can find already selected products*/
		public var discountType : int;
		public var formName : String;
		public var statusFilterOn : int;		
		public var lblStatus : String;
		public var logindate : Date;
		/** Comes in URL flashvars : String describes the brand dg column and Filter combobox */
		public var brand : String;
		/** Holds CF _Appsettings  Only 1 Key used here : Exact_List_Matching_On */
		public var appSettings :AppSettings = new AppSettings();
		/** Comes in URL flashvars : String describes the Qbrand dg column and Filter combobox */
		public var appFlex : AppFlex;
		public var user : Object;
		public var qBrand : String;
		public var timeZoneOffset : int = 0;
		public var useDayLightSavingsTime : Boolean = true;
		/** Comes in URL flashvars : String describes the typeCode dg column and Filter combobox */
		public var typeCode : String;
		/** Comes in URL flashvars : String describes the typeGroup dg column and Filter combobox */
		public var typeGroup : String;
		/** Object Holds common Ui settings : cfApp_buttonHeight, cfApp_comboBoxHeight, cfApp_textInputHeight */
		public var distributorSingularLabel:String;
		public var UIAttributes : Object;
		public var cfApp_buttonHeight : String = '16';
		public var cfApp_comboBoxHeight : String = '15';
		public var cfApp_textInputHeight : String = '20';
		public var cfApp_comboBoxContentWidth : String = '360';
		public var cfApp_scorecardsortoption : String;
		public var cfApp_scorecardsortmethod : String;	
		public var bMarketPrice:Boolean;
		public var templateFilterId : int;
		public var status:int;
		public var sURL:String;
		public var sBBDeviationSource : String;
		public var bDebug : Boolean;
		public var iMpId : int;
		public var source:String;
		
		/*-.........................................Constructor..........................................*/
		public function Settings(	userId : String =		"", 
									programId : int =		0, 
									discountType : int =	0,
									formName : String = "",
									statusFilterOn : int = 0,
									lblStatus :String = "Status",
									brand : String = 		"",
									appSettings:AppSettings = 	null,
									appFlex:AppFlex 	= 	null,
									user:Object 		= 	null,
									qBrand : String = 		"",
									typeCode : String = 	"",
									typeGroup : String = 	"",
									distributorSingularLabel : String = "",
									//UIAttributes:Object = 	null,
									cfApp_buttonHeight:String = "16",
									cfApp_comboBoxHeight:String = "15",
									cfApp_textInputHeight:String = "20",
									cfApp_scorecardsortoption:String = "",
									cfApp_scorecardsortmethod:String = "",
									logindate : Date =		null,
									bMarketPrice:Boolean =	false,
									templateFilterId: int	= 0,
									status:int = 0,
									sURL:String = '',
									sBBDeviationSource:String = "EDIT",
									iMpId : int =		0,
									source : String = '') 
		{
			this.userId = userId;
			this.programId = programId;
			this.discountType = discountType;
			this.formName = formName;
			this.statusFilterOn = statusFilterOn;
			this.lblStatus = lblStatus;
			this.brand = brand;
			this.appSettings = new AppSettings(),
			this.appFlex = new AppFlex(),
			this.user = new Object(),
			this.qBrand = qBrand,
			this.typeCode = typeCode,
			this.typeGroup = typeGroup,
			this.distributorSingularLabel = distributorSingularLabel,
			//this.UIAttributes = new Object(),
			this.cfApp_buttonHeight = cfApp_buttonHeight,
			this.cfApp_comboBoxHeight = cfApp_comboBoxHeight,
			this.cfApp_textInputHeight = cfApp_textInputHeight,
			this.cfApp_scorecardsortmethod = cfApp_scorecardsortmethod,
			this.cfApp_scorecardsortoption = cfApp_scorecardsortoption,
			this.logindate =  ( logindate == null ) ?  new Date() : logindate;
			this.bMarketPrice = bMarketPrice;
			this.templateFilterId = templateFilterId;
			this.status = status;
			this.sURL = sURL;
			this.sBBDeviationSource = sBBDeviationSource;
			this.iMpId = iMpId;
			this.source = source;
		}
		
		/*-.........................................Methods..........................................*/
		public function load(newSettings:Settings):void 
		{
			this.userId = newSettings.userId;
			this.programId = newSettings.programId;
			this.discountType = newSettings.discountType;
			this.formName = newSettings.formName;
			this.statusFilterOn = newSettings.statusFilterOn;
			this.lblStatus = newSettings.lblStatus;
			this.brand = newSettings.brand;
			this.qBrand = newSettings.qBrand,
			this.typeCode = newSettings.typeCode, 
			this.distributorSingularLabel = newSettings.distributorSingularLabel,
			this.typeGroup = newSettings.typeGroup,
			this.logindate =  newSettings.logindate;
			this.appSettings =  newSettings.appSettings;
			this.UIAttributes =  newSettings.UIAttributes;
			this.cfApp_buttonHeight = newSettings.cfApp_buttonHeight;
			this.bMarketPrice =  newSettings.bMarketPrice;
			this.status = newSettings.status;
			this.sURL = newSettings.sURL;
			this.templateFilterId =  newSettings.templateFilterId;
			this.timeZoneOffset = newSettings.timeZoneOffset;
			this.useDayLightSavingsTime = newSettings.useDayLightSavingsTime;
			this.sBBDeviationSource = newSettings.sBBDeviationSource;
			this.bDebug = newSettings.bDebug;
			this.iMpId = newSettings.iMpId;
			this.source = newSettings.source;
			
		}

	}
}