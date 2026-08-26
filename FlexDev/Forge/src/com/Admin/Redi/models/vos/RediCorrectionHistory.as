package com.Admin.Redi.models.vos
{
	import com.shared.models.entity.vos.Customer;
	
	import flash.events.EventDispatcher;

	[Bindable]
	[RemoteClass(Redi="mvc.Models.Admin.Redi.vos.RediCorrectionHistory")]
	public class RediCorrectionHistory extends EventDispatcher
	{
		/*-.........................................Properties..........................................
		WE MAY NEED A DEDICATED HISTORY OBJECT.  A SINGLE "FILE" CAN HAVY MANY INVOICES I BELEIEVE */
		public var uploadId : int = 0;
		public var sourceType : int = 0;//
		public var sourceTypeDesc : String = '';//DOT, Sysco, Honor
		public var headerCount:Number;
		public var headerFailed:Number;
		public var headerLoaded:Number;
		public var detailCount:Number;
		public var detailFailed:Number;
		public var detailLoaded:Number;
		public var fileName:String;
		public var runDate:Date;
		/*-.........................................Constructor..........................................*/
		public function RediCorrectionHistory( rediCorrectionHistory:RediCorrectionHistory = null )
		{
			if( rediCorrectionHistory ) copy( rediCorrectionHistory );
		}
		/*-.........................................Methods..........................................*/
		public function copy( rediCorrectionHistory:RediCorrectionHistory ):void
		{
			this.uploadId = rediCorrectionHistory.uploadId;
			this.sourceType = rediCorrectionHistory.sourceType;
			this.sourceTypeDesc = rediCorrectionHistory.sourceTypeDesc;
			this.headerCount = rediCorrectionHistory.headerCount;
			this.headerFailed = rediCorrectionHistory.headerFailed;
			this.headerLoaded = rediCorrectionHistory.headerLoaded;
			this.detailCount = rediCorrectionHistory.detailCount;
			this.detailFailed = rediCorrectionHistory.detailFailed;
			this.detailLoaded = rediCorrectionHistory.detailLoaded;
			this.fileName = rediCorrectionHistory.fileName;
			this.runDate = rediCorrectionHistory.runDate;
		}
	}
}