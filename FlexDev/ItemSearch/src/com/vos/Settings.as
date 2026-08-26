package com.vos
{
	import flash.events.EventDispatcher;
	[Bindable]
	/**
	 * Settings is the master settings object returned from CF.  Several properties are Objects themselves.
	 * @author msaunders
	 */
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
		public var appSettings : Object;
		/** Comes in URL flashvars : String describes the Qbrand dg column and Filter combobox */
		public var qBrand : String;
		/** Comes in URL flashvars : String describes the typeCode dg column and Filter combobox */
		public var typeCode : String;
		/** Comes in URL flashvars : String describes the typeGroup dg column and Filter combobox */
		public var typeGroup : String;
		/** Object Holds common Ui settings : cfApp_buttonHeight, cfApp_comboBoxHeight, cfApp_textInputHeight */
		public var UIAttributes : Object;
		
		/*-.........................................Constructor..........................................*/
		public function Settings(	userId : String =		"", 
									programId : int =		0, 
									discountType : int =	0,
									formName : String = "",
									statusFilterOn : int = 0,
									lblStatus :String = "Status",
									brand : String = 		"",
									appSettings:Object 	= 	null,
									qBrand : String = 		"",
									typeCode : String = 	"",
									typeGroup : String = 	"",
									UIAttributes:Object = 	null,
									logindate : Date =		null ) 
		{
			this.userId = userId;
			this.programId = programId;
			this.discountType = discountType;
			this.formName = formName;
			this.statusFilterOn = statusFilterOn;
			this.lblStatus = lblStatus;
			this.brand = brand;
			this.appSettings = new Object(),
			this.qBrand = qBrand,
			this.typeCode = typeCode,
			this.typeGroup = typeGroup,
			this.UIAttributes = new Object(),
			this.logindate =  ( logindate == null ) ?  new Date() : logindate;
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
			this.typeGroup = newSettings.typeGroup,
			this.logindate =  newSettings.logindate;
			this.appSettings =  newSettings.appSettings;
			this.UIAttributes =  newSettings.UIAttributes;
			
		}

	}
}