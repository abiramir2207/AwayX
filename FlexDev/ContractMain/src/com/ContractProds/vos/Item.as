package com.ContractProds.vos
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
		public var Description : String;
		public var Brand_Name : String;
		public var Q_Brand : String;
		public var Type_Code_Desc : String;
		public var Type_Group_Desc : String;
		public var Item_Status : String;
		public var volume : Number;
		public var marketPrice:Number;
		public var marketPriceCS:Number;
		public var marketPriceLB:Number;
		public var uomMP:Uom;

	}
}
