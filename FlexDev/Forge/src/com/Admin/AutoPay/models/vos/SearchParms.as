package com.Admin.AutoPay.models.vos
{
	import flash.events.EventDispatcher;

	[Bindable]
	//[RemoteClass(alias="mvc.Models.Admin.AutoPay.vos.AutoPayDetail")]
	public class SearchParms extends EventDispatcher
	{
		/*-.........................................Properties..........................................
		approve delete copy edit run*/
		public var dStart:Date;
		public var dEnd:Date;
		public var reportId:Number;
		public var invoiceNumber:String;
		/*-.........................................Constructor..........................................*/
		public function SearchParms(sp:SearchParms = null)
		{
			///set some default values
			this.dStart = new Date();
			this.dStart[ 'month' ] += -12;
			this.dEnd = new Date();
			this.reportId = 0;
			this.invoiceNumber = '';
			
			if( sp ) copy( sp );
		}
		
		/*-.........................................Methods..........................................*/
		
		public function copy( sp:SearchParms ):void
		{
			this.dStart = sp.dStart;
			this.dEnd = sp.dEnd;
			this.reportId = sp.reportId;
			this.invoiceNumber = sp.invoiceNumber;
				
		}
		
	}
}