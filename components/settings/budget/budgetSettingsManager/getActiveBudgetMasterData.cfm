	<!--- Return Active Group Members --->
	<cffunction name="getActiveBudgetMasterData" output="false">
		<cfargument name="budgetcategory_id" required="true" type="numeric" hint="1=SALES, 2=CUSTOMER ATTRIBUTES, 3=PRODUCT ATTRIBUTES" />
		<cfargument name="budget_type" required="Yes" type="numeric" />
	
		<cfquery name="masterDataGroups" datasource="#application.datasource#">
			select Group_Level_Desc, Budget_Group_Level_ID, trade_active, volume_active  
			from Budget_Group_level 
			where group_id = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.budgetcategory_id#">
			<cfif arguments.budget_type EQ 1>
			and trade_active = 1 
			<cfelseif arguments.budget_type EQ 2>
			and volume_active = 1
			</cfif>
			and active = 'true'
			order by group_level_desc ASC
		</cfquery>
		
		<cfreturn masterDataGroups />
	</cffunction>