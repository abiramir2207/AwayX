package com.shared.vos
{
	import com.ContractProds.vos.ComponentDef;

	[Bindable]
	[RemoteClass(alias="mvc.Models.Program.Component.vos.Component")]
	/**
	 * Component includes component details as well as an array of ProdRate objs.
	 * @author msaunders
	 */
	public class Component
	{
		/*-.........................................Properties..........................................*/
		public var isSelected : Boolean;
		public var componentId : int = 0;
		public var name : String;
		public var type : int;
		public var fixedType : int = 0;
		public var prodRate : Array;
		public var uom : Array;
		public var paidTo : PaidTo;
		public var paymentCycle : PaymentCycle;
		public var claimMechanic : ClaimMechanic;
		public var payee : Payee;
		public var glAccount :GlAccount;
		public var bMarketPriceTemplate:Boolean;
		public var amount:Number = 0;
		public var programId:int = 0;			//program id
		public var programNumber:String = ''; 	//program number
		public var programTitle:String = ''; 	//program title
		public var compDescription:String = ''; //description of component added by user (optional)
		public var compRate:String = ''; 		//the rate from the program
		public var programComponentId:String = ''; 		//component UUID
		public var customPrint:CustomPrint = new CustomPrint();
		public var componentDef:ComponentDef = new ComponentDef();
		
		/*-.........................................Constructor..........................................*/
		public function Component( component:Component = null )
		{
			if( component ) copy( component );
		}
		/*-.........................................Methods..........................................*/
		public function copy( comp:Component ):void
		{
			this.isSelected 			= comp.isSelected;
			this.componentId			= comp.componentId;
			this.name 					= comp.name;
			this.type  					= comp.type;
			this.fixedType				= comp.fixedType;
			this.prodRate  				= comp.prodRate;
			this.uom 	 				= comp.uom;
			this.paidTo  				= comp.paidTo;
			this.paymentCycle  			= comp.paymentCycle;
			this.claimMechanic 		 	= comp.claimMechanic;
			this.payee  				= comp.payee;
			this.glAccount  			= comp.glAccount;
			this.bMarketPriceTemplate	= comp.bMarketPriceTemplate;
			this.amount 				= comp.amount;
			this.programId 				= comp.programId;
			this.programNumber 			= comp.programNumber;
			this.programTitle			= comp.programTitle;
			this.compDescription		= comp.compDescription;
			this.compRate				= comp.compRate;
			this.programComponentId		= comp.programComponentId;
			this.customPrint			= new CustomPrint(comp.customPrint);
			this.componentDef			= new ComponentDef(comp.componentDef);
		}
	}
}