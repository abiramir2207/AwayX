package com.vos
{
	[Bindable]
	[RemoteClass(alias="mvc.Models.Item.vos.ItemGridData")]
	public class ItemGridData
	{
		/*-.........................................Properties..........................................*/
		public var itemGuid : String;
		public var isSelected :Boolean;
		public var baItem : String;
		public var Description : String;
		public var Brand_Name : String;
		public var Q_Brand : String;
		public var Type_Code_Desc : String;
		public var Type_Group_Desc : String;
		public var Fixed_Price_Included : Boolean;
		public var Rebate_Included : Boolean;
		public var LumpSum_Included : Boolean;
		public var Growth_Included : Boolean;
		public var BidRequest_Included : Boolean;
		public var Item_Status : String;

	}
}
