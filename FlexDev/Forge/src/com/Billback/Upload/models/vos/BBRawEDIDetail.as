package com.Billback.Upload.models.vos
{
	import flash.events.EventDispatcher;
	[Bindable]
	[RemoteClass(alias="mvc.Models.Billback.vos.BBRawEDIDetail")]
    public class BBRawEDIDetail extends EventDispatcher
	{  
		
		public var UploadID: int;				// upload_ID
		public var BBUploadIIIPHID:int; 		// Billback_Upload_III_PH_ID
		public var BBNumber : String;			// Claim_Num
		public var BBDate:Date;					// Claim_Date
		public var PeriodStDate:String;			// Distributor_ID
		public var PeriodEndDate:String;		// Distributor_Name
		public var AgreementNum:String;			// Agreement_Num	
		public var AgreementName:String;		// Agreement_Name
		public var VendorLocNum:String;			// Vendor_Loc_Num	
		public var VendorInvNum:String;			// Vendor_Inv_Num
		public var DCACName:String;				// DC_AC_Name
		public var DCACNum:String;				// DC_AC_Num
		public var STAddress1:String;			// ST_Address1	
		public var STCity:String;				// ST_City
		public var STState:String;				// ST_State
		public var STZipCode:String;			// ST_Zip_Code
		public var CSQTY:String;				// CS_QTY
		public var UPCCODE:String;				// UPC_Code
		public var ManufactureItemID:String;	// Manufacture_Item_ID
		public var DCProductNum:String;			// DC_Product_Num
		public var AwardAmt:String;				// Award_Amt
		public var DCProductDesc:String;		// DC_Product_Desc 
		public var DeletedBy:String;			// Deleted_By
		public var DeletedDate:Date;			// Deleted_Date

		public function BBRawEDIDetail()
	    {
		}    
	}
}
