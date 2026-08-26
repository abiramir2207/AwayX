package com.Billback.Upload.models.vos
{
	import flash.events.EventDispatcher;
	[Bindable]
	[RemoteClass(alias="mvc.Models.Billback.vos.BBUploadDetailError")]
    public class BBUploadDetailError extends EventDispatcher
	{  
		public var shipTo:String;
		public var dupShipTo:String;
		public var custNumber:String;
		public var custName:String;
		public var operatorLegacyId:String;
		public var custContractNumber:String;
		public var custContractDescription:String;
		public var operatorId:String;
		public var operatorName:String;
		public var operatorAddress1:String;
		public var operatorAddress2:String;
		public var operatorCity:String;
		public var operatorState:String;
		public var operatorZip:String;
		public var item:String;
		public var custItem:String;
		public var custItemDescription:String;
		public var BBProductQuantity:String;
		public var caseRate:String;
		public var BBRate:String;
		public var contractNumber:String;
		public var contractTitle:String;
		public var others:String;
		public var DiscountType:String;

          public function BBUploadDetailError(err:BBUploadDetailError = null)
	      {
			  if(err){
				  //TODO: set properties
			  }
		  }    
	}
}
