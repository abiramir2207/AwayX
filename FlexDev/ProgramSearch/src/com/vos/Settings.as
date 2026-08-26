package com.vos
{
	[Bindable]
	/**
	  * This is the value object for different settings and variables loaded on initialization
	*/
	public class Settings
	{
		/*-.........................................Properties..........................................*/
		public var userId : String;
		public var programId : int;
		public var discountType : int;
		public var logindate : Date;
		public var appSettings:Object;
		public var appFlex:Object;
		public var user:Object;
		public var status:String;
		public var reload:String;
		public var importlist_type: Boolean;		
		public var Creating_User_Position: int;
		public var Include_work_in_progress_below_me: int;		
		public var timeZoneOffset : int = 0;
		public var useDayLightSavingsTime : Boolean = true;

		
		/*-.........................................Constructor..........................................*/
		public function Settings(	userId : String 	=	"", 
									programId : int 	=	0, 
									discountType : int 	=	0,
									appSettings:Object 	= 	null,
									appFlex:Object 	= 	null,
									user:Object 	= 	null,
									logindate : Date 	=	null,
									status :String =	"",
									reload :String =	"",
									importlist_type: Boolean = false,
									Creating_User_Position: int = 0,
									Include_work_in_progress_below_me: int = 0)
		
									
		{
			this.userId = userId;
			this.programId = programId;
			this.discountType = discountType;
			this.appSettings = new Object();
			this.appFlex = new Object();
			this.user = new Object();
			this.logindate =  ( logindate == null ) ?  new Date() : logindate;
			this.status = status;
			this.reload = reload;
			this.importlist_type = importlist_type;
			this.Creating_User_Position = Creating_User_Position;
			this.Include_work_in_progress_below_me = Include_work_in_progress_below_me;
		}
			
		
		
		/*-.........................................Methods..........................................*/
		public function load(newSettings:Settings):void 
		{
			this.userId = newSettings.userId;
			this.programId = newSettings.programId;
			this.discountType = newSettings.discountType;
			this.logindate =  newSettings.logindate;
			this.appSettings =  newSettings.appSettings;
			this.appFlex =  newSettings.appFlex;
			this.user =  newSettings.user;
			this.status =  newSettings.status;
			this.reload =  newSettings.reload;
			this.importlist_type = newSettings.importlist_type;			
			this.Creating_User_Position = newSettings.Creating_User_Position;
			this.Include_work_in_progress_below_me = newSettings.Include_work_in_progress_below_me;			
			this.timeZoneOffset = newSettings.timeZoneOffset;
			this.useDayLightSavingsTime = newSettings.useDayLightSavingsTime;			
		}

	}
}