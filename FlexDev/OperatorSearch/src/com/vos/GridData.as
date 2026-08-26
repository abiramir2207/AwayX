package com.vos
{
	import flash.events.EventDispatcher;
	[Bindable]
	public class GridData extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		public var BSA_Operator_ID:String;
		public var Legacy_ID:String;
		public var Operator_Name:String;
		public var Operator_City:String;
		public var Operator_State:String;
		public var Operator_Zip:String;
		public var Operator_Type:String;
		public var Business_Segment_ID:int;
		public var Display_Code:String;
		public var isSelected:Boolean;
		/**
		 * Operator Object. 
		 * Each row in the data grid is a grid data object
		 * 
		 * @param BSA_Operator_ID
		 * @param Legacy_ID 
		 * @param Operator_Name
		 * @param Operator_City
		 * @param Operator_State
		 * @param Operator_Zip
		 * @param Operator_Type
		 * @param Business_Segment_ID
		 * @param Display_Code
		 * @param isSelected
		 * 
		 */		
		/*-.........................................Constructor..........................................*/
		public function GridData(	BSA_Operator_ID:String			= "",
									Legacy_ID:String				= "",
									Operator_Name:String			= "",
									Operator_City:String			= "",
									Operator_State:String			= "",
									Operator_Zip:String				= "",
									Operator_Type:String	= "",
									Business_Segment_ID:int			= 0,
									Display_Code:String				= "",
									isSelected:Boolean				= false								
								)							
		{
			this.BSA_Operator_ID 			= BSA_Operator_ID;
			this.Legacy_ID 					= Legacy_ID;
			this.Operator_Name				= Operator_Name;
			this.Operator_City				= Operator_City;
			this.Operator_State				= Operator_State;
			this.Operator_Zip				= Operator_Zip;
			this.Operator_Type		= Operator_Type;
			this.Business_Segment_ID		= Business_Segment_ID;
			this.Display_Code				= Display_Code;
			this.isSelected					= isSelected;
		}
			
		
		
		/*-.........................................Methods..........................................*/
		public function load(newGridData:Object):void 
		{	
			this.BSA_Operator_ID 			= newGridData.BSA_Operator_ID;
			this.Legacy_ID 					= newGridData.Legacy_ID;
			this.Operator_Name				= newGridData.Operator_Name;
			this.Operator_City				= newGridData.Operator_City;
			this.Operator_State				= newGridData.Operator_State;
			this.Operator_Zip				= newGridData.Operator_Zip;
			this.Operator_Type		= newGridData.Operator_Type;
			this.Business_Segment_ID		= newGridData.Business_Segment_ID;
			this.Display_Code				= newGridData.Display_Code;
			this.isSelected					= newGridData.isSelected;
		}

	}
}
