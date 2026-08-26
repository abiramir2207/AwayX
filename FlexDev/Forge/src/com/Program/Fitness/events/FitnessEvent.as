package com.Program.Fitness.events
{
	import com.Billback.Main.models.vos.BBHeader;
	import com.Program.Fitness.models.vos.FitnessSearchDef;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	
	public class FitnessEvent extends Event
	{
		
		/*-.........................................Constants..........................................*/
		public static const LOAD_Fitness:String = "loadFitnessEvent";
		public static const LOAD_HEADER_DATA = "loadHeaderData";
		public static const SET_HEADER_DATA = "setHeaderData";
		public static const SET_USER_ID:String = "setUserIdEvent";
		public static const BSA_ERROR:String = "bsaError";
		public static const BSA_NO_SERVICE_ERROR:String = "bsaNoServiceError";
		public static const Fitness_LOAD_APP_SETTINGS:String = "FitnessLoadAppSettings";
		public static const SEARCH_ITEMS:String = "searchItems";
		public static const SET_DETAIL_DATA:String = "setDetailData";

		/*-.........................................Properties..........................................*/
		
		public var a:Array;
		public var settings:Settings;
		public var userId:String;
		public var fitnessSearchDef:FitnessSearchDef;
		public var programId:int;
		public var appSettings:Object;
		public var oBaError:Object;
		public var sBaError:String;
		public var sState:String;

		/*-.........................................Contructor..........................................*/
		public function FitnessEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}	
	}
	
}