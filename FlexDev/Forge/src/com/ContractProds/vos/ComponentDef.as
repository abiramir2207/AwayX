package com.ContractProds.vos
{
	import flash.events.EventDispatcher;

	[Bindable]
	[RemoteClass(alias="mvc.Models.Program.Component.vos.ComponentDef")]
	/**
	 * ComponentDef holds the definition for a component.  Each array is a list of valid options for the comp.
	 * @author msaunders
	 */
	public class ComponentDef extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		public var componentId : int;
		public var name : String;
		public var type : int;
		public var fixedType : int = 0;
		public var greatestProgramValue:Boolean;
		public var uom : Array;
		public var paidTo : Array;
		public var paymentCycle : Array;
		public var claimMechanic : Array;
		public var glAccount : Array;
		public var bGreatestValue : Boolean;
		public var bDefaultComp : Boolean;
		/*-.........................................Constructor..........................................*/
		public function ComponentDef( componentDef:ComponentDef = null )
		{
			if( componentDef ) copy( componentDef );
		}
		/*-.........................................Methods..........................................*/
		public function copy( componentDef:ComponentDef ):void
		{
			componentId 		= componentDef.componentId;
			name  				= componentDef.name;
			type  				= componentDef.type;
			fixedType			= componentDef.fixedType;
			greatestProgramValue = componentDef.greatestProgramValue;
			uom  				= componentDef.uom;
			paidTo  			= componentDef.paidTo;
			paymentCycle 		= componentDef.paymentCycle;
			claimMechanic 		= componentDef.claimMechanic;
			glAccount  			= componentDef.glAccount;
			bGreatestValue		= componentDef.bGreatestValue;
			bDefaultComp		= componentDef.bDefaultComp;
		}
	}
}