package com.Billback.Upload.models.vos
{
	import com.Billback.Upload.models.vos.BBUploadDetailError;
	
	import flash.events.EventDispatcher;
	[Bindable]
	[RemoteClass(alias="mvc.Models.Billback.vos.BBUploadDetail")]
    public class BBUploadDetail extends EventDispatcher
	{  
          public var uploadID:int;
		  public var isSelected:Boolean;
          public var shipTo:String;
		  public var dupShipTo:String; // Dup_Claim_Org_ID
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
          public var BBProductQuantity:Number;
          public var caseRate:String;
          public var BBRate:Number;
          public var contractNumber:String;
          public var contractTitle:String;
          public var bbDetailID:int;
          public var bbHeaderID:int;
          public var errMsg:String;
          public var errType:String;
          public var errObj:BBUploadDetailError;
          public var uploadtype:String;
		  public var rowID: int;
		  public var DiscountType:String;
		  public var bEdited:Boolean;

          public function BBUploadDetail()
	      {
		  }    
	}
}
