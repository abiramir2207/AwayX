	<!--- Return All Group Members --->	
	<cffunction name="getBudgetMasterData" output="false">
		<cfargument name="budgetcategory_id" required="true" type="numeric" />
	
		<cfquery name="masterDataGroups" datasource="#application.datasource#">		
			select Group_Level_Desc, Budget_Group_Level_ID, trade_active, volume_active
			from Budget_Group_level 
			where group_id = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.budgetcategory_id#">
			and active = 'true'
			order by group_level_desc ASC
		</cfquery>	
	
		<cfreturn masterDataGroups />
	</cffunction>