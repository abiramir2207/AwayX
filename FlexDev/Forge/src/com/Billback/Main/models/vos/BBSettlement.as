package com.Billback.Main.models.vos
{
	import flash.events.EventDispatcher;
	[Bindable]
	[RemoteClass(alias="mvc.Models.Billback.vos.BBSettlement")]
	public class BBSettlement extends EventDispatcher
	{  
		/* bbClosingDetail here is actually of type "BBClosingDetail" */
		public var bbClosingDetail:Array = new Array();
		public var bSpecialHandling:Boolean;
		public var bIsBillbackWithinBudget:Boolean;
		public var paymentNotes : String = '';
		public var templateApproval:Boolean;
		public var lastDateToClaim:Boolean;
		public var bIsReversible:Boolean;	
		
		
		public function BBSettlement( bbSettle:BBSettlement = null )
		{
			if( bbSettle ) copy( bbSettle );
		}
		/*-.........................................Methods..........................................*/
		public function copy( bbSettle:BBSettlement ):void
		{
			if(bbSettle.bbClosingDetail){
				var arr:Array = new Array();
				for each(var bbClose:BBClosingDetail in bbSettle.bbClosingDetail){
					arr.push(new BBClosingDetail(bbClose));
				}
				this.bbClosingDetail = arr;
			}
			this.bSpecialHandling = bbSettle.bSpecialHandling;
			this.bIsBillbackWithinBudget = bbSettle.bIsBillbackWithinBudget;
			this.paymentNotes = bbSettle.paymentNotes;
			this.templateApproval 	= bbSettle.templateApproval;
			this.lastDateToClaim = bbSettle.lastDateToClaim;
			this.bIsReversible	 = bbSettle.bIsReversible;
		} 
	}
}
