package com.events
{
	import com.vos.Settings;
	
	import flash.events.Event;
	
	[Bindable] 
	public class MainEvent extends Event
	{
		
		/*-.........................................Constants..........................................*/
		public static const GET:String 						= "getSearchEvent";
		public static const LOAD_APP_SETTINGS:String 		= "loadAppSettings";
		
		//Dropdowns
		public static const GET_CLASSES:String 				= "fnGetAllClass";
		public static const GET_SIMPLEBUDGET:String 		= "fnGetSimpleBudget";
		public static const GET_BUDGETASSOCIATION:String 	= "fnGetBudgetAssociation";
		public static const GET_USERPOSITIONS:String 		= "fnGetUserPositions";
		
		//Labels
		public static const GET_BUDGETLABELS:String			= "fnGetBudgetLabels";
		
		//Filter function
		public static const BUDGETFILTER:String 			= "fnBudgetFilter";
		public static const FILTERRESULTS:String 			= "fnFilterResults";
		public static const CALL_GET:String 				= "fnCallGet";
		
		/* - ******** Error/Fault capturing Events ******* - */	
		public static const BSA_ERROR:String 				= "bsaError";
		public static const BSA_NO_SERVICE_ERROR:String 	= "bsaNoServiceError";
		
		
		/*-.........................................Properties..........................................*/
		
		public var settings:Settings;
		public var userId:String;
		public var programId:int;
		public var appSettings:Object;
		public var oBaError:Object;
		public var sBaError:String;
		
		public var eClass:String;
		public var eSimpleBudget:String;
		public var eBudgetAssociation:String;
		public var eUserPositions:String;
		

		/*-.........................................Contructor..........................................*/
		public function MainEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}	
	}
	
}