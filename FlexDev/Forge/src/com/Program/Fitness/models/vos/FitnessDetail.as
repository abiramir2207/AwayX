package com.Program.Fitness.models.vos
{
	
	import flash.events.EventDispatcher;
	[Bindable]
	[RemoteClass(alias="mvc.Models.Program.Fitness.vos.FitnessDetail")]
	public class FitnessDetail extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/

		public var item: String = '';
		public var description: String = '';
		public var sigLabel: String = '';
		public var eligibility:String = '';
		public var yago:Number = 0;
		public var revenue:Number = 0;
		public var cases:Number = 0;
		public var lbs:Number = 0;
		public var yagoNon:Number = 0;
		public var revenueNon:Number = 0;
		public var casesNon:Number = 0;
		public var lbsNon:Number = 0;
		public var qBrand: String = '';
		public var prodVarA: String = '';
		public var typeCodeDesc: String = '';
		
		
		/*-.........................................Constructor..........................................*/
		public function FitnessDetail( fitnessDetail:FitnessDetail = null )
		{
			if( fitnessDetail ) copy( fitnessDetail );
		}
		/*-.........................................Methods..........................................*/
		public function copy( fitnessDetail:FitnessDetail ):void
		{
			this.item = 		fitnessDetail.item;
			this.description = 	fitnessDetail.description;
			this.sigLabel =		fitnessDetail.sigLabel;
			this.eligibility = 	fitnessDetail.eligibility;
			this.yago = 		fitnessDetail.yago;
			this.revenue = 		fitnessDetail.revenue;
			this.cases = 		fitnessDetail.cases;
			this.lbs = 			fitnessDetail.lbs;
			this.yagoNon = 		fitnessDetail.yagoNon;
			this.revenueNon = 	fitnessDetail.revenueNon;
			this.casesNon = 	fitnessDetail.casesNon;
			this.lbsNon = 		fitnessDetail.lbsNon;
			this.qBrand = 		fitnessDetail.qBrand;
			this.prodVarA = 	fitnessDetail.prodVarA;
			this.typeCodeDesc = fitnessDetail.typeCodeDesc;
		}
	}
}


