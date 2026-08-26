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
		public var userId : String;
		public var programId : int;
		public var oneDistSelection : Boolean;
		public var discountType : int;
		public var logindate : Date;
		public var appSettings : Object;
		public var appFlex : AppFlex;
		public var user : Object;
		public var UIAttributes : Object;

		
		/*-.........................................Constructor..........................................*/
		public function Settings(	userId : String 	=	"", 
									programId : int 	=	0,
									oneDistSelection : Boolean = false,
									discountType : int 	=	0,
									appSettings:Object 	= 	null,
									appFlex:AppFlex 	= 	null,
									user:Object 		= 	null,
									UIAttributes:Object = 	null,
									logindate : Date 	=	null)
		
									
		{
			this.userId = userId;
			this.programId = programId;
			this.oneDistSelection = oneDistSelection;
			this.discountType = discountType;
			this.appSettings = new Object(),
			this.appFlex = new AppFlex(),
			this.user = new Object(),
			this.UIAttributes = new Object(),
			this.logindate =  ( logindate == null ) ?  new Date() : logindate;
		}
			
		
		
		/*-.........................................Methods..........................................*/
		public function load(newSettings:Settings):void 
		{
			this.userId = newSettings.userId;
			this.programId = newSettings.programId;
			this.oneDistSelection = newSettings.oneDistSelection;
			this.discountType = newSettings.discountType;
			this.logindate =  newSettings.logindate;
			this.appSettings =  newSettings.appSettings;
			this.appFlex =  newSettings.appFlex;
			this.user =  newSettings.user;
			this.UIAttributes =  newSettings.UIAttributes;
			
		}

	}
}