package com.Billback.Upload.models.vos
{
	import flash.events.EventDispatcher;
	
	[Bindable]
	[RemoteClass(alias="mvc.Models.Billback.vos.BBRawEDIFilterParams")]
	/**
	 * @author Anand
	 */
	public class BBRawEDIFilterParams extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
	 
		public var BBNumberKeyword : String;
		public var BBDateKeyboard:Date;
		public var vendorNumber:String;
		public var vendorName:String;
		public var payeeNumber:String;
		public var payeeName:String;
		public var agreementNumber:String;
		public var agreementName:String;
		public var clearRecords:Boolean;
		public var BBRawEDIDetail : Array = new Array();
		
		/*-.........................................Constructor..........................................*/
		public function BBRawEDIFilterParams(		
			BBNumberKeyword:String = '',
			BBDateKeyboard:Date    = null,
			vendorNumber:String    = '',
			vendorName:String 	   = '',
			payeeNumber:String 	   = '',
			payeeName:String 	   = '',
			agreementNumber:String = '',
			agreementName:String   = '',
			clearRecords:Boolean   = false,
			BBRawEDIDetail:Array   = null
		)
		{			
			/* When calling the constructor with the "new" keyword, the properties (for some reason) do not exist and so we have a conditional statement here
			for some properties which prevents it to be set to null and sets it to new Array(). This is useful when using "reset" on multi-select combobox 
			as when this constructor called, the selected checkboxes are unselected as needed.
			*/
			this.BBNumberKeyword = BBNumberKeyword;
		 	this.BBDateKeyboard  = BBDateKeyboard;
			this.vendorNumber 	 = vendorNumber;
			this.vendorName 	 = vendorName;
			this.payeeNumber 	 = payeeNumber;
			this.payeeName 		 = payeeName;
			this.agreementNumber = agreementNumber;
			this.agreementName 	 = agreementName;
			this.clearRecords 	 = clearRecords;
			if(BBRawEDIDetail)
				this.BBRawEDIDetail = BBRawEDIDetail;			
		}
		
	}
}
