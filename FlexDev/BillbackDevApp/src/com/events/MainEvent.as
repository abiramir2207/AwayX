/**
 * Main Event class that holds the declaration for all the events used in the application. 
 */
package com.events
{
	import com.vos.Settings;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	/**
 	* MainEvent class holds the declaration for all the events used in the application. 
 	*/	
	[Bindable] 
	public class MainEvent extends Event
	{
		
		/*-.........................................Constants..........................................*/
		public static const GET:String 									= "getSearchEvent";
		public static const BSA_ERROR:String 						= "bsaError";
		public static const BSA_NO_SERVICE_ERROR:String = "bsaNoServiceError";
		public static const LOAD_APP_SETTINGS:String 		= "loadAppSettings";
		public static const GET_BILLBACK_HEADER:String 	= "getBBHeader";
		public static const GET_BILLBACK_DETAILS:String = "getBBDetails";
		public static const FILTER_RESULTS:String 			= "filterResults";
		public static const SAVE_CHANGES:String 				= "saveChanges";
		public static const APPROVE:String							= "ApprovePage";
		public static const RECALCULATE:String					= "Recalculate";
		/*-.........................................Properties..........................................*/
		
		public var settings:Settings;
		public var sUserId:String;
		public var iProgramId:int;
		public var sCallerSource:String;
		public var appSettings:Object;
		public var oBaError:Object;
		public var sBaError:String;
		public var Billback_ID:String;
		public var sBBID:String;
		public var doAction:String;
		public var dgEditedSet:Array = new Array;
		public var sCaller:String;
		public var evtObj:Object;
		public var sOptionalVal:String;
		public var sAllowValuesGTClaimed:String;		
		public var ApprovalBtn:String;
		
		/*-.........................................Contructor..........................................*/
		/**
		 * Constructor for the MainEvent 
		 */ 
		public function MainEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}	
	}
	
}