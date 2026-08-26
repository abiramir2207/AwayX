<!---
Name: 			saveBudget.cfm
Copyright:		(c) 2006 Blacksmith Applications, Inc.
Description:	I am responsible for saving the high level budget data
Parameters:		N/A
Usage:			N/A
--->

<cffunction name="saveBudget" access="public" returntype="void" output="no" hint="I am responsible for saving the high level budget data">
	
	<cfif this.budgetId eq 0>
		<!------ do insert ----->
		<cfquery name="qInsertBudget" datasource="#application.datasource#">
			INSERT INTO Budget(Budget_Group_ID, Budget_Code, Budget_Name, Budget_Value, Budget_UOM, Budget_Start_Date, Budget_End_Date, Created_By)
			VALUES	(
						<cfqueryparam value="#this.budgetGroupId#" cfsqltype="CF_SQL_INTEGER">,
						<cfqueryparam value="#this.budgetCode#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#this.budgetName#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#this.budgetValue#" cfsqltype="CF_SQL_DECIMAL">,
						<cfqueryparam value="#this.budgetUOM#" cfsqltype="CF_SQL_INTEGER">,
						<cfqueryparam value="#this.budgetStartDate#" cfsqltype="CF_SQL_DATE">,
						<cfqueryparam value="#this.budgetEndDate#" cfsqltype="CF_SQL_DATE">,
						<cfqueryparam value="#this.userId#" cfsqltype="CF_SQL_VARCHAR">
					)
		</cfquery>
		
	<cfelse>
		<!------ do update ----->
		<cfquery name="qUpdateBudget" datasource="#application.datasource#">
			UPDATE	Budget
			SET		Budget_Code 		= <cfqueryparam value="#this.budgetCode#" cfsqltype="CF_SQL_VARCHAR">, 
					Budget_Name 		= <cfqueryparam value="#this.budgetName#" cfsqltype="CF_SQL_VARCHAR">, 
					Budget_Value 		= <cfqueryparam value="#this.budgetValue#" cfsqltype="CF_SQL_DECIMAL">, 
					Budget_UOM 			= <cfqueryparam value="#this.budgetUOM#" cfsqltype="CF_SQL_INTEGER">, 
					Budget_Start_Date 	= <cfqueryparam value="#this.budgetStartDate#" cfsqltype="CF_SQL_DATE">, 
					Budget_End_Date 	= <cfqueryparam value="#this.budgetEndDate#" cfsqltype="CF_SQL_DATE">, 
					Updated_by 			= <cfqueryparam value="#this.userId#" cfsqltype="CF_SQL_VARCHAR">, 
					Updated_Date 		= GetDate()
			WHERE	Budget_ID 			= <cfqueryparam value="#this.budgetId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
	</cfif>
		
</cffunction>
