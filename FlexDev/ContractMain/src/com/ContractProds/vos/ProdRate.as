package com.ContractProds.vos
{
	[Bindable]
	[RemoteClass(alias="mvc.Models.Program.Component.vos.ProdRate")]
	/**
	 * ProdRate is a child of Component.prodRate array
	 * @author msaunders
	 */
	public class ProdRate
	{
		/*-.........................................Properties..........................................*/
		public var itemGuid : String;
		public var itemNumber : String;
		public var Description : String;
		public var uom :Uom;
		public var rate :Number;
		public var rateMP :Number;
		public var rateMPCS :Number;
		public var rateMPLB :Number;
		//public var varianceMP :Number;
		//public var variancePercMP :Number;
		public var volume :Number;
		
		/*-.........................................Constructor..........................................*/
		public function ProdRate( 
									itemGuid:String = '',
									itemNumber:String = '',
									uom :Uom = null
								)
		{
			this.itemGuid = itemGuid;
			this.itemNumber = itemNumber;
			this.uom = uom == null ? new Uom() : uom;
		}

	}
}