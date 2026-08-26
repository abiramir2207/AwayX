<cfcomponent output="false" alias="mvc.Models.Billback.vos.BBComponent">

	<!---
	programID 		=  Billback_Program.Program_ID;
	bbProgramID 	= Billback_Program.Billback_Program_ID;
	componentTypeId = 1 = Fixed, 2 = Rebate, 3 = Lumpsum
	componentNameId	= PROGRAM_LUMP_SUM_NAME.Program_Lump_Sum_Name_ID / PROGRAM_REBATES_COMPONENT_NAME.Program_Rebates_Component_Name_ID;
	componentName	= PROGRAM_LUMP_SUM_NAME.Program_Lump_Sum_Name / PROGRAM_REBATES_COMPONENT_NAME.Program_Rebates_Component_Name;
	componentDesc	= Program_Lump_Sums.Lump_Sum_Description;
	componentAmount	= Billback_Program_Lumpsum_Component.Amount;
	programNumber 	= Contract_Main.Contract_Number;
--->
    <cfproperty name="isSelected"       type="boolean"  default="0" />
	<cfproperty name="programID"		type="numeric"	default="0"	hint="programID =  Billback_Program.Program_ID">
	<cfproperty name="bbProgramID"		type="string"	default=""	hint="bbProgramID = Billback_Program.Billback_Program_ID">
	<cfproperty name="componentTypeId" 	type="numeric" 	default="0"	hint="1 = Fixed, 2 = Rebate, 3 = Lumpsum">
	<cfproperty name="componentNameId" 	type="string" 	default=""	hint="componentNameId = PROGRAM_LUMP_SUM_NAME.Program_Lump_Sum_Name_ID / PROGRAM_REBATES_COMPONENT_NAME.Program_Rebates_Component_Name_ID">
	<cfproperty name="componentName" 	type="string" 	default=""	hint="componentName = PROGRAM_LUMP_SUM_NAME.Program_Lump_Sum_Name / PROGRAM_REBATES_COMPONENT_NAME.Program_Rebates_Component_Name">
	<cfproperty name="componentDesc" 	type="string" 	default=""	hint="Used for Lump Sum Component Notes: Program_Lump_Sums.Lump_Sum_Description">
	<cfproperty name="componentAmount" 	type="string" 	default="0"	hint="componentAmount = Billback_Program_Lumpsum_Component.Amount">
	<cfproperty name="programNumber" 	type="string" 	default="0"	hint="programNumber = Contract_Main.Contract_Number">
	<cfproperty name="programTitle" 	type="string" 	default=""	hint="programTitle = Contract_Main.Contract_Title">
	<cfproperty name="paidTo" 			type="mvc.Models.Program.Component.vos.PaidTo" 	default="">
	<cfproperty name="bIsLatestVersion" type="boolean">
	<cfproperty name="compDescription" 	type="string" 	default="0"	hint="compDescription = Program_Lump_Sums.Lump_Sum_Description">
	<cfproperty name="compRate" 		type="string" 	default="0"	hint="compRate = Program_Lump_Sums.Lump_Sum_Amount">
    <cfproperty name="programComponentId" type="string" default="" 	hint="compRate = Program_Lump_Sums.Program_Lump_Sum_ID" />


	<cfscript>
        //Initialize the CFC with the default properties values.
        this.isSelected = 0;
		this.programID = 0;
		this.bbProgramID = "";
		this.componentTypeId = 0;
		this.componentNameId = "";
		this.componentName = "";
		this.componentDesc = "";
		this.componentAmount = "";
		this.programNumber = "";
		this.programTitle = "";
		this.paidTo = "";
		this.bIsLatestVersion = 1;
		this.compDescription = "";
		this.compRate = "";
		this.programComponentId = "";
	</cfscript>

	<cffunction name="init" output="false" returntype="BBComponent">
		<cfreturn this>
	</cffunction>

</cfcomponent>