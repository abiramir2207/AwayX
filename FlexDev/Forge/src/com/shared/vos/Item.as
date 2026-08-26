package com.shared.vos
{
	[Bindable]
	[RemoteClass(alias="mvc.Models.Item.vos.Item")]
	/**
	 * Item is the row level detail for the datagrid.  It is Dyanamic since a ProdRate obj is added to each 
	 * record when a component is added.
	 * @author msaunders
	 */
	public dynamic class Item
	{
		/*-.........................................Properties..........................................*/
		public var itemGuid : String;
		public var isSelected :Boolean;
		public var baItem : String;
		public var baItemDisplay : String;
		public var Description : String;
		public var Brand_Name : String;
		public var Q_Brand : String;
		public var Type_Code_Desc : String;
		public var Type_Group_Desc : String;
		public var Item_Status : String;
		public var volume : Number = 1;
		public var marketPrice:Number;
		public var rateMPOrig:Number;
		public var marketPriceCS:Number;
		public var marketPriceLB:Number;
		public var uomMP:Uom;
		public var isGroup :Boolean;
		public var customPrintCharge:CustomPrintCharge = new CustomPrintCharge();
		public var customPrint:CustomPrint = new CustomPrint();
		public var rateEz:Number;

	}
}
