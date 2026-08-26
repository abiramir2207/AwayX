// ActionScript file
package
{
	[RemoteClass(alias="billbacks.ClaimForm.Services.ClaimService")]
	
	public dynamic class ClaimService
	{
		
		public var Item_Id:Number = 0;
		public var Program_ItemId:String = "";
		public var Item_Desc:String = "";
		public var Item_Case_Weight:Number = 0;
		public var Num_Cases_Claimed:Number = 0;
		public var Net_Lbs_Claimed:Number;
		public var STD:String = "";
		public var Promo_rate:Number = 0;
		public var Invoice_Price:Number = 0;
		public var Promo_Amt:Number = 0;
		public var Price_List:Number = 0;
		public var Less Corp Allow:Number = 0;
		public var Less_Local_Allow:Number = 0;
		public var Net_Promo_Amt:Number = 0;
		public var Adj_Extended_Amt:Number;
		public var ClaimFormFK:Number = 0;


		public function ClaimService()
		{
		}
		
	}
}