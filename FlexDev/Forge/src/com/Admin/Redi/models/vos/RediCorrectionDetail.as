package com.Admin.Redi.models.vos
{
	
	import flash.events.EventDispatcher;

	[Bindable]
	[RemoteClass(alias="mvc.Models.Admin.Redi.vos.RediCorrectionDetail")]
	public class RediCorrectionDetail extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		public var rediCorrectionHeaderId:Number= 3333; //unique counter
		public var rediCorrectionDetailId:Number= 3333; //unique counter
		public var isSelected:Boolean;
		public var item : String = '';
		public var itemDesc : String = '';//
		public var itemPackSize : String = '';//DOT, Sysco, Honor
		public var aliasItem : String = '';//Original Buyer
		public var aliasItemDesc : String = '';//Final Buyer
		public var aliasItemPackSize:Number= 0;//Orig
		public var aliasRecordId:Number= 0;//Orig
		public var invoiceCases:Number= 0;//Orig
		public var invoicePriceCS:Number= 0;
		public var invoicePriceLB:Number= 0;
		public var errorMessage : String = '';
		//public var history:RediCorrectionHistory; //counts of records: total, loaded and failed
		/*-  WE MAY NEED A DEDICATED HISTORY OBJECT (NOT A CHILD OH Detail).  A SINGLE "FILE" CAN HAVE MANY INVOICES I BELEIEVE *******************/
		
		/*-.........................................Constructor..........................................*/
		public function RediCorrectionDetail( rediCorrectionDetail:RediCorrectionDetail = null )
		{
			if( rediCorrectionDetail ) copy( rediCorrectionDetail );
		}
		/*-.........................................Methods..........................................*/
		public function copy( rediCorrectionDetail:RediCorrectionDetail ):void
		{
			this.rediCorrectionHeaderId = rediCorrectionDetail.rediCorrectionHeaderId;
			this.rediCorrectionDetailId = rediCorrectionDetail.rediCorrectionDetailId;
			this.isSelected = rediCorrectionDetail.isSelected;
			this.item = rediCorrectionDetail.item;
			this.itemDesc = rediCorrectionDetail.itemDesc;
			this.itemPackSize = rediCorrectionDetail.itemPackSize;
			this.aliasItem = rediCorrectionDetail.aliasItem;
			this.aliasItemDesc = rediCorrectionDetail.aliasItemDesc;
			this.aliasItemPackSize = rediCorrectionDetail.aliasItemPackSize;
			this.aliasRecordId = rediCorrectionDetail.aliasRecordId;
			this.invoiceCases =rediCorrectionDetail.invoiceCases;
			this.invoicePriceCS = rediCorrectionDetail.invoicePriceCS;
			this.invoicePriceLB = rediCorrectionDetail.invoicePriceLB;
			this.errorMessage = rediCorrectionDetail.errorMessage;
		}
	}
}