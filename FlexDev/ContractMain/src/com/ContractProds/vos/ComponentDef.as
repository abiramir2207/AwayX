package com.ContractProds.vos
{
	[Bindable]
	[RemoteClass(alias="mvc.Models.Program.Component.vos.ComponentDef")]
	/**
	 * ComponentDef holds the definition for a component.  Each array is a list of valid options for the comp.
	 * @author msaunders
	 */
	public class ComponentDef
	{
		/*-.........................................Properties..........................................*/
		public var componentId : int;
		public var name : String;
		public var type : int;
		public var uom : Array;
		public var paidTo : Array;
		public var paymentCycle : Array;
		public var claimMechanic : Array;
		public var glAccount : Array;
		/*-.........................................Constructor..........................................*/
		public function ComponentDef( componentDef:ComponentDef = null )
		{
			if( componentDef ) copy( componentDef );
		}
		/*-.........................................Methods..........................................*/
		public function copy( componentDef:ComponentDef ):void
		{
			componentId = componentDef.componentId;
			name  = componentDef.name;
			type  = componentDef.type;
			uom  = componentDef.uom;
			paidTo  = componentDef.paidTo;
			paymentCycle  = componentDef.paymentCycle;
			claimMechanic  = componentDef.claimMechanic;
			glAccount  = componentDef.glAccount;
		}
	}
}