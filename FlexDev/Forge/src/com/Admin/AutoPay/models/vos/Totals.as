package com.Admin.AutoPay.models.vos
{
	import flash.events.EventDispatcher;

	[Bindable]
	//[RemoteClass(alias="mvc.Models.Admin.AutoPay.vos.Status")]
	public class Totals extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		public var bbAmount:Number = 0;
		public var recaptureAmount:Number = 0;
		public var deviationAmount:Number = 0;
		public var reportCount:Number = 0;
		public var billbackCount:Number = 0;
		public var programCount:Number = 0;

		/*-.........................................Constructor..........................................*/
		
		public function Totals(st:Totals = null){
			
			if( st ) copy( st );
		}
		
		/*-.........................................Methods..........................................*/
		public function copy(st:Totals):void
		{
			this.bbAmount = st.bbAmount;
			this.recaptureAmount = st.recaptureAmount;
			this.deviationAmount = st.deviationAmount;
			this.reportCount = st.reportCount;
			this.billbackCount = st.billbackCount;
			this.programCount = st.programCount;
			
		}

	}
}