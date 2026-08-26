package com.Program.Fitness.models.vos
{
	
	import flash.events.EventDispatcher;
	[Bindable]
	[RemoteClass(alias="mvc.Models.Program.Fitness.vos.FitnessSearchDef")]
	public class FitnessSearchDef extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		public var BusinessSegment0:Array = new Array();
		public var Area1:Array = new Array();
		public var Region2:Array = new Array();
		public var Customer3:Array = new Array();
		public var Year4:Array = new Array();
		public var Program5:Array = new Array();
		public var Period6:Array = new Array();
		
		/*public var Category7:Array = new Array();
		public var Family8:Array = new Array();
		public var Finance9:Array = new Array();*/
		public var BusinessSegment0Idx:Number = 0;
		public var Area1Idx:Number			= 0;
		public var Region2Idx:Number		= 0;
		public var Customer3Idx:Number		= 0;
		public var Year4Idx:Number			= 0;
		public var Program5Idx:Number		= 0;
		public var Period6Idx:Number		= 0;
		
		
		/*public var Category7Idx:Number		= 0;
		public var Family8Idx:Number		= 0;
		public var Finance9Idx:Number		= 0;*/
		
		public var Current:String			= '';
		
		
		/*-.........................................Constructor..........................................*/
		public function FitnessSearchDef( fitnessSearchDef:FitnessSearchDef = null )
		{
			if( fitnessSearchDef ) copy( fitnessSearchDef );
		}
		/*-.........................................Methods..........................................*/
		public function copy( fitnessSearchDef:FitnessSearchDef ):void
		{
			this.Area1 		= 		fitnessSearchDef.Area1;
			this.Region2 	= 		fitnessSearchDef.Region2;
			this.Customer3	= 		fitnessSearchDef.Customer3;
			this.Year4		= 		fitnessSearchDef.Year4;
			this.Program5 	= 		fitnessSearchDef.Program5;
			this.Period6 	= 		fitnessSearchDef.Period6;
			this.BusinessSegment0 = fitnessSearchDef.BusinessSegment0;
			/*this.Category7 	= 		fitnessSearchDef.Category7;
			this.Family8 	= 		fitnessSearchDef.Family8;
			this.Finance9 	= 		fitnessSearchDef.Finance9;*/
			
			this.Area1Idx 		= 		fitnessSearchDef.Area1Idx;
			this.Region2Idx 	= 		fitnessSearchDef.Region2Idx;
			this.Customer3Idx	= 		fitnessSearchDef.Customer3Idx;
			this.Year4Idx		= 		fitnessSearchDef.Year4Idx;
			this.Program5Idx 	= 		fitnessSearchDef.Program5Idx;
			this.Period6Idx 	= 		fitnessSearchDef.Period6Idx;
			this.BusinessSegment0Idx =	fitnessSearchDef.BusinessSegment0Idx;
			/*this.Category7Idx 	= 		fitnessSearchDef.Category7Idx;
			this.Family8Idx 	= 		fitnessSearchDef.Family8Idx;
			this.Finance9Idx 	= 		fitnessSearchDef.Finance9Idx;*/
			
			this.Current		=		fitnessSearchDef.Current;
		}
	}
}


