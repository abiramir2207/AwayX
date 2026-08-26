package com.Billback.Upload.models.vos
{
	import flash.events.EventDispatcher;
	
	[Bindable]
	[RemoteClass(alias="mvc.Models.Billback.vos.BBRawEDIHeader")]
	/**
	 * @author Anand
	 */
	public class BBRawEDIHeader extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
	 
		public var UploadID: int;			// upload_ID
		public var BBUploadIIIPHID:int; 	// Billback_Upload_III_PH_ID
		public var BBNumber : String;		// Claim_Num
		public var BBDate:Date;				// Claim_Date
		public var vendorNumber:String;		// Vendor_ID
		public var vendorName:String;		// Vendor_Name
		public var payeeNumber:String;		// Distributor_ID
		public var payeeName:String;		// Distributor_Name
		public var agreementNumber:String;	// Agreement_Num	
		public var agreementName:String;	// Agreement_Name
		public var ETotalClaimedAmt:String;	// E_Total_Claimed_Amt
		public var TotVolume:String;		// Tot_Volume
		public var DeletedBy:String;		// Deleted_By
		public var DeletedDate:Date;		// Deleted_Date
		public var bbRawEDIDetail:Array;	// BBRawEDIDetail Array
				
		/*-.........................................Constructor..........................................*/
		public function BBRawEDIHeader(	
			UploadID:int 			= 0,
			BBUploadIIIPHID:int 	= 0,
			BBNumber:String 		= '',
			BBDate:Date 			= null,
			vendorNumber:String 	= '',
			vendorName:String 		= '',
			payeeNumber:String 		= '',
			payeeName:String 		= '',
			agreementNumber:String 	= '',
			agreementName:String 	= '',
			ETotalClaimedAmt:String	= '',
			TotVolume:String 		= '',
			DeletedBy:String 		= '',
			DeletedDate:Date 		= null,
			bbRawEDIDetail:Array 	= null
		)
		{			
			/* 
				When calling the constructor with the "new" keyword, the properties (for some reason) do not exist and so we have a conditional statement here
				for some properties which prevents it to be set to null and sets it to new Array(). This is useful when using "reset" on multi-select combobox 
				as when this constructor called, the selected checkboxes are unselected as needed.
			*/
			this.UploadID		  = UploadID;
			this.BBUploadIIIPHID  = BBUploadIIIPHID;
			this.BBNumber		  = BBNumber;
		 	this.BBDate 		  = BBDate;
			this.vendorNumber 	  = vendorNumber;
			this.vendorName 	  = vendorName;
			this.payeeNumber 	  = payeeNumber;
			this.payeeName 		  = payeeName;
			this.agreementNumber  = agreementNumber;
			this.agreementName 	  = agreementName;
			this.ETotalClaimedAmt = ETotalClaimedAmt;
			this.TotVolume 		  = TotVolume;
			this.DeletedBy		  = DeletedBy;
			this.DeletedDate	  = DeletedDate;
			this.bbRawEDIDetail   = bbRawEDIDetail;
		}
	}
}
