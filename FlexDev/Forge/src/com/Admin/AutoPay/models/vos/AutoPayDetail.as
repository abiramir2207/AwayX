package com.Admin.AutoPay.models.vos
{
	import flash.events.EventDispatcher;

	[Bindable]
	[RemoteClass(alias="mvc.Models.Admin.AutoPay.vos.AutoPayDetail")]
	public class AutoPayDetail extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		public var reportId:Number = 0;
		public var reportStatus:Status;
		public var Billback_id:String;
		public var bbCode:String;
		public var bbTitle:String;
		public var reportTitle:String;
		public var bbAmount:Number = 0;
		public var pullbackAmount:Number = 0;
		public var deviationAmount:Number = 0;
		public var exclusionAmount:Number = 0;
		public var startDate:Date;
		public var endDate:Date;
		public var updDate:Date;
		public var firstName:String;
		public var lastName:String;
		public var contractTitle:String;
		public var contractNumber:String;
		public var compName:String;
		public var contractId:Number = 0;
		public var payeeName:String;
		public var payeeId:String;
		/*-.........................................Constructor..........................................*/
		public function AutoPayDetail()
		{
			
		}
		/*
		public function BBProdRate( bbProdRate:BBProdRate = null )
		{
		if( bbProdRate ) copy( bbProdRate );
		}
		*/
		
		/*-.........................................Methods..........................................*/
		/*
		public function copy( autoPayDetail:AutoPayDetail ):void
		{
				
		}
		*/
	}
}