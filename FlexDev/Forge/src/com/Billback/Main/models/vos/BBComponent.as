package com.Billback.Main.models.vos
{
	import com.Billback.Main.models.vos.*;
	import com.shared.vos.PaidTo;
	
	import flash.events.EventDispatcher;
	
	[Bindable]
	[RemoteClass(alias="mvc.Models.Billback.vos.BBComponent")]
	public class BBComponent extends EventDispatcher
	{
		public var programID:Number;		// Billback_Program.Program_ID
		public var bbProgramID:String;		// Billback_Program.Billback_Program_ID
		public var componentTypeId:Number;	// 1 = Fixed, 2 = Rebate, 3 = Lumpsum
		public var componentNameId:String;	// PROGRAM_LUMP_SUM_NAME.Program_Lump_Sum_Name_ID / PROGRAM_REBATES_COMPONENT_NAME.Program_Rebates_Component_Name_ID
		public var componentName:String;	// PROGRAM_LUMP_SUM_NAME.Program_Lump_Sum_Name / PROGRAM_REBATES_COMPONENT_NAME.Program_Rebates_Component_Name
		public var componentDesc:String;	// Used for Lump Sum Component Notes: Program_Lump_Sums.Lump_Sum_Description
		public var componentAmount:String;	// Billback_Program_Lumpsum_Component.Amount
		public var programNumber:String;	// Contract_Main.Contract_Number
		public var programTitle:String='';	// Contract_Main.Contract_Title
		public var paidTo:PaidTo;			// Paid To used to maintain the Payee Type
		public var bIsLatestVersion:Boolean;// Value indicating if the program this component belongs to is the latest version
		public var compDescription:String;	// Program_Lump_Sums.Lump_Sum_Description
		public var compRate:String;			// Program_Lump_Sums.Lump_Sum_Description
		public var programComponentId:String;			// Program_Lump_Sums.Program_Lump_Sum_ID
		
		public function BBComponent()
		{	
			// nothing here
		}
		
	}

}
