package com.Billback.Upload.models.vos
{
	import com.shared.models.entity.vos.Operator;
	import com.shared.models.entity.vos.User;
	import com.shared.vos.Payee;
	
	import flash.events.EventDispatcher;
	[Bindable]
	[RemoteClass(alias="mvc.Models.Billback.vos.BBUploadHeaderError")]
    public class BBUploadHeaderError extends EventDispatcher
	{  
		public var vendorId:String;
		public var vendorName:String;
		public var shipTo:String;
	// 	public var dupShipTo:String;
		public var BBReference:String;
		public var billbackTitle:String;
		public var BBDate:String;
		public var startDate:String;
		public var endDate:String;
		public var BBAmount:String;
		public var operatorLegacyID:String;
		public var others:String;
		public var agreementNum:String;
		public var agreementName:String;		

          public function BBUploadHeaderError()
	      {
			  /*this.billbackTitle = 'dupe';
			  this.closingMethod = 'bad';
			  this.distributorID = 'unknown';
			  this.endDate = 'wrong century';
			  this.invoiceDate = 'bad year';
			  this.operatorID = 'dont like';
			  this.payeeType = 'unfreindly';
			  this.postmarkDate = 'd14';
			  this.receiptDate = 'bad week';
			  this.referenceNumber = 'does not refer';
			  this.referenceNum = 'too vague';
			  this.startDate = 'after end date';
			  this.vendor = 'vendor is a criminal';*/
		  }    
	}
}
