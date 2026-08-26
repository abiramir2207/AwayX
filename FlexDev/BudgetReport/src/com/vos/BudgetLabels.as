package com.vos
{
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	
	[Bindable]
	public class BudgetLabels extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/

		//Labels
		public var _sBudgetDollarLabel:String;
		public var _sCommittedDollarLabel:String;
		public var _sBudgetBalanceLabel:String;
		public var _sApprovedPaymentDollarLabel:String;
		public var _sAvailableBudgetDollarLabel:String;
		public var _sBudgetClassAssociationLabel:String;
		
	
		/*-.........................................Constructor..........................................*/
		public function BudgetLabels(	
			sBudgetDollarLabel					: String 	=	"",
			sCommittedDollarLabel				: String 	=	"",
			sBudgetBalanceLabel 				: String 	=	"",
			sApprovedPaymentDollarLabel 		: String 	=	"",
			sAvailableBudgetDollarLabel 		: String 	=	"",
			sBudgetClassAssociationLabel 		: String 	=	""
			)
		
									
		{
			this._sBudgetDollarLabel			= sBudgetDollarLabel;
			this._sCommittedDollarLabel			= sCommittedDollarLabel;
			this._sBudgetBalanceLabel 			= sBudgetBalanceLabel;
			this._sApprovedPaymentDollarLabel 	= sApprovedPaymentDollarLabel;
			this._sAvailableBudgetDollarLabel 	= sAvailableBudgetDollarLabel;
			this._sBudgetClassAssociationLabel 	= sBudgetClassAssociationLabel;	
		}

	}
}
