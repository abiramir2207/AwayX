package com.vos
{
	[Bindable]
	public class Settings
	{
		/*-.........................................Properties..........................................*/
		public var userId:String;
		public var programId:int;
		public var preSelected:Array;

		public var businessSegmentsOn:Boolean;
		public var businessSegmentID:int;

		public var operatorID:String;
		public var operatorSingular:String;
		public var operatorPlural:String;

		public var city:String;
		public var state:String;
		public var operatorType:String;
		public var status:String;
		public var legacyID:String;
		
		public var appButtonHeight:int;
		public var appComboBoxHeight:int;
		public var appTextInputHeight:int;
		
		public var cfApp_showBSAOperators:int;
		
		public var appSettings : Object;
		
		
		/*-.........................................Constructor..........................................*/
		public function Settings(	userId:String 				=	"", 
									programId:int 				=	0, 
									businessSegmentsOn:Boolean	=	false,
									businessSegmentID:int		=	0,
									operatorID:String			=	"",
									operatorSingular:String		=	"",
									operatorPlural:String		=	"",
									city:String 				= 	"",
									state:String 				= 	"",
									operatorType:String			= 	"",
									status:String 				= 	"",
									legacyID:String				=	"",
									appSettings:Object 			= 	null
								) 
		{
			this.userId 			= userId;
			this.programId 			= programId;
			
			this.businessSegmentsOn	= businessSegmentsOn;
			this.businessSegmentID 	= businessSegmentID;
	
			this.operatorID			= operatorID;
			this.operatorSingular	= operatorSingular;
			this.operatorPlural		= operatorPlural;	
			
			this.city				= city;
			this.state 				= state;
			this.operatorType 		= operatorType;
			this.status 			= status;
			this.legacyID			= legacyID;
			
			this.appSettings 		= new Object();
		}
		
		/*-.........................................Methods..........................................*/
		public function load(newSettings:Settings):void 
		{
			this.userId 			= newSettings.userId;
			this.programId 			= newSettings.programId;
			
			this.businessSegmentsOn	= newSettings.businessSegmentsOn;
			this.businessSegmentID 	= newSettings.businessSegmentID;
	
			this.operatorID			= newSettings.operatorID;
			this.operatorSingular	= newSettings.operatorSingular;
			this.operatorPlural		= newSettings.operatorPlural;			
			
			this.city				= newSettings.city;
			this.state 				= newSettings.state;
			this.operatorType 		= newSettings.operatorType;
			this.status 			= newSettings.status;		
			this.legacyID			= newSettings.legacyID;
			
			this.appSettings 		= newSettings.appSettings;
		}

	}
}