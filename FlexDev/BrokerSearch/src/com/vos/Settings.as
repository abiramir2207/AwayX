package com.vos
{
	import com.vos.AppFlex;
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
		/** Comes in URL flashvars : contract_main_id so we can find already selected Brokers*/
		public var programId : int;
		public var discountType : int;
		public var logindate : Date;
		/** Holds CF _Appsettings. empty Object since all settings are in appFlex Object */
		public var appSettings : Object;
		/** Object holds custom settings for this flex app */
		public var appFlex : AppFlex;
		/** Empty Object*/
		public var user : Object;
		/** Object Holds common Ui settings : cfApp_buttonHeight, cfApp_comboBoxHeight, cfApp_textInputHeight */
		public var UIAttributes : Object;

		
		/*-.........................................Constructor..........................................*/
		public function Settings(	userId : String 	=	"", 
									programId : int 	=	0, 
									discountType : int 	=	0,
									appSettings:Object 	= 	null,
									appFlex:AppFlex 	= 	null,
									user:Object 		= 	null,
									UIAttributes:Object = 	null,
									logindate : Date 	=	null)
		
									
		{
			this.userId 		= userId;
			this.programId 		= programId;
			this.discountType 	= discountType;
			this.appSettings 	= new Object(),
			this.appFlex		= new AppFlex(),
			this.user 			= new Object(),
			this.UIAttributes 	= new Object(),
			this.logindate 		=  ( logindate == null ) ?  new Date() : logindate;
		}
			
		
		
		/*-.........................................Methods..........................................*/
		public function load(newSettings:Settings):void 
		{
			this.userId 		= newSettings.userId;
			this.programId 		= newSettings.programId;
			this.discountType 	= newSettings.discountType;
			this.logindate 		= newSettings.logindate;
			this.appSettings 	= newSettings.appSettings;
			this.appFlex 		= newSettings.appFlex;
			this.user			= newSettings.user;
			this.UIAttributes 	= newSettings.UIAttributes;			
		}

	}
}