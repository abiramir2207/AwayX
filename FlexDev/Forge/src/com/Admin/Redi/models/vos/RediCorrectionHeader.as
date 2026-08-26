package com.Admin.Redi.models.vos
{
	import com.shared.models.entity.vos.Customer;
	import com.shared.models.entity.vos.Lock;
	
	import flash.events.EventDispatcher;

	[Bindable]
	[RemoteClass(alias="mvc.Models.Admin.Redi.vos.RediCorrectionHeader")]
	public class RediCorrectionHeader extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		public var rediCorrectionHeaderId:Number= 0; //unique counter
		public var uploadId:Number= 0;
		public var isSelected:Boolean;
		public var lock:Lock;
		public var sourceType : String = '';//
		public var sourceTypeDesc : String = '';//DOT, Sysco, Honor
		public var originalCustomer:Customer;//Original Buyer
		public var finalCustomer:Customer;//Final Buyer
		public var invoiceNumber:String = '';//Orig
		public var invoiceDate:Date;//Orig
		public var poNum:String;
		public var InvCases:Number;//total for file
		public var InvDollars:Number;//total for file
		public var errorMessage:String;
		public var arrRediCorrectionItems:Array;
		public var originalCustomerShipToNew : String = ''; //new shipto for alias (via another process)
		public var finalCustomerShipToNew : String = ''; //new shipto for alias (via another process)
		public var bReprocess:Boolean; //all Aliases have been corrected (by another process)
		public var bFixable:Boolean; //some errors cannot be fixed (duplicate invoice or invalid price)
		//public var history:RediCorrectionHistory; //counts of records: total, loaded and failed
		/*-  WE MAY NEED A DEDICATED HISTORY OBJECT (NOT A CHILD OH HEADER).  A SINGLE "FILE" CAN HAVE MANY INVOICES I BELEIEVE *******************/
		
		/*-.........................................Constructor..........................................*/
		public function RediCorrectionHeader( rediCorrectionHeader:RediCorrectionHeader = null )
		{
			if( rediCorrectionHeader ) copy( rediCorrectionHeader );
		}
		/*-.........................................Methods..........................................*/
		public function copy( rediCorrectionHeader:RediCorrectionHeader ):void
		{
			this.rediCorrectionHeaderId = rediCorrectionHeader.rediCorrectionHeaderId;
			this.uploadId = rediCorrectionHeader.uploadId;
			this.isSelected = rediCorrectionHeader.isSelected;
			this.lock = rediCorrectionHeader.lock;
			this.originalCustomer = new Customer(rediCorrectionHeader.originalCustomer);
			this.finalCustomer = new Customer(rediCorrectionHeader.finalCustomer);
			this.sourceType = rediCorrectionHeader.sourceType;
			this.sourceTypeDesc = rediCorrectionHeader.sourceTypeDesc;
			this.invoiceNumber = rediCorrectionHeader.invoiceNumber;
			this.invoiceDate = rediCorrectionHeader.invoiceDate;
			this.poNum = rediCorrectionHeader.poNum;
			this.InvCases = rediCorrectionHeader.InvCases;
			this.InvDollars = rediCorrectionHeader.InvDollars;
			this.errorMessage = rediCorrectionHeader.errorMessage;
			this.arrRediCorrectionItems = rediCorrectionHeader.arrRediCorrectionItems;
			this.bFixable = rediCorrectionHeader.bFixable ;
			this.bReprocess = rediCorrectionHeader.bReprocess;
			this.finalCustomerShipToNew = rediCorrectionHeader.finalCustomerShipToNew ;
			this.originalCustomerShipToNew = rediCorrectionHeader.originalCustomerShipToNew ;
			//this.history = new RediCorrectionHistory(rediCorrectionHeader.history);
		}
	}
}