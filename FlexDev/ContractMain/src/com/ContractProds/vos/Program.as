package com.ContractProds.vos
{
	import com.shared.vos.Template;

	[Bindable]
	[RemoteClass(alias="mvc.Models.Program.Component.vos.Program")]
	public class Program
	{
		/*-.........................................Properties..........................................*/
		public var programId:int;
		public var title:String = '';
		public var number:String = '';
		public var startDate:String;	// New
		public var endDate:String;		// New
		public var distributors:Array = new Array(); 	// New
		public var operators:Array = new Array(); 	// New
		public var components:Array = new Array();
		public var componentType:Array = new Array();
		public var bMarketPriceTemplate:Boolean;
		public var arrPrdAttr:Array  = new Array();
		//public var arrCustomers: Array = new Array();
		public var arrCustAttr:Array  = new Array();
		public var template:Template = new Template();
		public var conversionFactor:Number;
		public var bHasConversionFactor:Boolean;
		public var bRevision:Boolean;

	}
}