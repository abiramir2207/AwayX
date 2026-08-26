	<!--- Return Budget Allocation Types --->
	<cffunction name="getAllocationTypes" output="false" returnType="query">
		<cfargument name="budget_type" required="Yes" type="numeric" />
		<cfquery name="qAllocationTypes" datasource="#application.datasource#">
			select allocation_id, allocation_desc, trade_include, volume_include, updated_on
			from budget_allocation_type
			where 1 = 1
			<cfif arguments.budget_type EQ 1>
				AND trade_active = 1
			<cfelseif arguments.budget_type EQ 2>
				AND volume_active = 1
			</cfif>
			order by allocation_id ASC
		</cfquery>
		<cfreturn qAllocationTypes />
	</cffunction>