package com.ContractProds.vos
{
	[Bindable]
	[RemoteClass(alias="mvc.Models.Program.Component.vos.Component")]
	/**
	 * Component includes component details as well as an array of ProdRate objs.
	 * @author msaunders
	 */
	public class Component
	{
		/*-.........................................Properties..........................................*/
		public var componentId : int = 0;
		public var name : String = '';
		public var type : int;
		public var prodRate : Array;
		public var uom : Array;
		public var paidTo : PaidTo;
		public var paymentCycle : PaymentCycle;
		public var claimMechanic : ClaimMechanic;
		public var payee : Payee;
		public var glAccount :GlAccount;
		public var bMarketPriceTemplate:Boolean;
		/*-.........................................Constructor..........................................*/
		public function Component( component:Component = null )
		{
			if( component ) copy( component );
		}
		/*-.........................................Methods..........................................*/
		public function copy( component:Component ):void
		{
			componentId = component.componentId;
			name  = component.name;
			type  = component.type;
			prodRate  = component.prodRate;
			uom  = component.uom;
			paidTo  = component.paidTo;
			paymentCycle  = component.paymentCycle;
			claimMechanic  = component.claimMechanic;
			payee  = component.payee;
			glAccount  = component.glAccount;
			bMarketPriceTemplate = component.bMarketPriceTemplate;
		}
	}
}