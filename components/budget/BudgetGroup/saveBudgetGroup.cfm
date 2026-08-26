<!---
Name: 			saveBudgetGroup.cfm
Copyright:		(c) 2006 Blacksmith Applications, Inc.
Description:	I am responsible for saving the budget group data
Parameters:		N/A
Usage:			N/A
--->

<cffunction name="saveBudgetGroup" access="public" returntype="void" output="no" hint="I am responsible for saving the budget group data">
	
	<cfif this.budgetGroupId eq 0>
		<!------ do insert ----->
		
		<cfquery name="qInsertBudgetGroup" datasource="#application.datasource#">
			INSERT INTO Budget_Group (Budget_Group_Code, Budget_Group_Name, Budget_Group_Value, Budget_Group_UOM, Budget_Group_Start_Date, Budget_Group_End_Date, Budget_Group_Type_ID)
			VALUES 	(
					<cfqueryparam value="#this.budgetGroupCode#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#this.budgetGroupName#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#this.budgetGroupValue#" cfsqltype="CF_SQL_DECIMAL">,
					<cfqueryparam value="#this.budgetGroupUOM#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#this.budgetGroupStartDate#" cfsqltype="CF_SQL_DATE">,
					<cfqueryparam value="#this.budgetGroupEndDate#" cfsqltype="CF_SQL_DATE">,
					<cfqueryparam value="#this.budgetGroupTypeId#" cfsqltype="CF_SQL_INTEGER">
					)
		</cfquery>
		
	<cfelse>
		<!------ do update ----->
		
		<cfquery name="qUpdateBudgetGroup" datasource="#application.datasource#">
			UPDATE	Budget_Group
			SET		Budget_Group_Code = <cfqueryparam value="#this.budgetGroupCode#" cfsqltype="CF_SQL_VARCHAR">, 
					Budget_Group_Name = <cfqueryparam value="#this.budgetGroupName#" cfsqltype="CF_SQL_VARCHAR">, 
					Budget_Group_Value = <cfqueryparam value="#this.budgetGroupValue#" cfsqltype="CF_SQL_DECIMAL">, 
					Budget_Group_UOM = <cfqueryparam value="#this.budgetGroupUOM#" cfsqltype="CF_SQL_INTEGER">, 
					Budget_Group_Start_Date = <cfqueryparam value="#this.budgetGroupStartDate#" cfsqltype="CF_SQL_DATE">, 
					Budget_Group_End_Date = <cfqueryparam value="#this.budgetGroupEndDate#" cfsqltype="CF_SQL_DATE">, 
					Budget_Group_Type_ID = <cfqueryparam value="#this.budgetGroupTypeId#" cfsqltype="CF_SQL_INTEGER">
			WHERE	Budget_Group_ID = <cfqueryparam value="#this.budgetGroupId#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
	
	</cfif>
		
</cffunction>
