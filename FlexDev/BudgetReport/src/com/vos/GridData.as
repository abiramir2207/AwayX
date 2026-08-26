package com.vos
{
	import flash.events.EventDispatcher;
	[Bindable]
	public class GridData extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		public var sSimpleBudgetClass					: String;
		public var sBudget 								: String;
		public var sSimpleBudgetClassAssociationNumber	: String;
		public var sUserPositionsID						: String;
		public var sPositionLabel						: String;
		public var nSumBudgetDollar 					: Number;
		public var nSumCommittedDollar 					: Number;
		public var nSumActualDollar 					: Number;
		public var nBudgetBalance	 					: Number;
		public var nAvailableBudget	 					: Number;

	
		/*-.........................................Constructor..........................................*/
		public function GridData(	
			sSimpleBudgetClass					: String 	=	"",
			sBudget								: String 	=	"",
			sSimpleBudgetClassAssociationNumber : String 	=	"",
			sUserPositionsID 					: String 	=	"",
			sPositionLabel 						: String 	=	"",
			nSumBudgetDollar 					: Number 	=	0,
			nSumCommittedDollar 				: Number 	=	0,
			nSumActualDollar 					: Number 	=	0,
			nBudgetBalance						: Number	= 	0,
			nAvailableBudget					: Number	= 	0
			)
		
									
		{
			this.sSimpleBudgetClass					= sSimpleBudgetClass;
			this.sBudget							= sBudget;
			this.sSimpleBudgetClassAssociationNumber = sSimpleBudgetClassAssociationNumber;
			this.sUserPositionsID 					= sUserPositionsID;
			this.sPositionLabel 					= sPositionLabel;
			this.nSumBudgetDollar 					= nSumBudgetDollar;
			this.nSumCommittedDollar 				= nSumCommittedDollar;
			this.nSumActualDollar 					= nSumActualDollar;
			this.nBudgetBalance						= nBudgetBalance;
			this.nAvailableBudget					= nAvailableBudget
		
		}
			
		
		
		/*-.........................................Methods..........................................*/
		public function load(newGridData:Object):void 
		{
			this.sSimpleBudgetClass					= newGridData.Simple_Budget_Class;
			this.sBudget							= newGridData.Budget;
			this.sSimpleBudgetClassAssociationNumber = newGridData.Simple_Budget_Class_Association_Number;
			this.sUserPositionsID 					= newGridData.User_Positions_ID;
			this.sPositionLabel 					= newGridData.Position_Label;
			this.nSumBudgetDollar 					= newGridData.Sum_Budget_Dollar;
			this.nSumCommittedDollar 				= newGridData.Sum_Committed_Dollar;
			this.nSumActualDollar 					= newGridData.Sum_Actual_Dollar;
			this.nBudgetBalance						= newGridData.Sum_Budget_Dollar - newGridData.Sum_Committed_Dollar;
			this.nAvailableBudget					= newGridData.Sum_Budget_Dollar - newGridData.Sum_Actual_Dollar
		}

	}
}
