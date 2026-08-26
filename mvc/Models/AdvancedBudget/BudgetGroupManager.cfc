<cfcomponent alias="mvc.Models.AdvancedBudget.BudgetGroupManager">

	<cffunction name="getBudgetGroup" returntype="query" access="public" hint="Will return a query with all BudgetGroup" output="false">
		<cfargument name="BudgetGroupId" type="numeric" required="false" default="0" />
		
		<cfset var qGetBudgetGroup = "" / >
		<cfquery name="qGetBudgetGroup" datasource="#application.datasource#">
			SELECT	Budget_Group_ID,
					Budget_Group_Number,
					Budget_Group_Desc,
					Active,
					Last_Updated_Date,
					Last_Updated_By
			FROM	Budget_Group
			WHERE	Deleted = 0
			<cfif arguments.BudgetGroupId neq "0">
			AND 	Budget_Group_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.BudgetGroupId#" />		
			</cfif>
			ORDER BY Budget_Group_Number, Budget_Group_Desc
		</cfquery>
		
		<cfreturn qGetBudgetGroup />
	
	</cffunction>

	<cffunction name="getSingleBudgetGroup" returntype="mvc.Models.AdvancedBudget.vos.BudgetGroup" access="public" hint="Will return the BudgetGroup object" output="false">
		<cfargument name="BudgetGroupId" type="numeric" required="true" />
		
		<cfset var oBudgetGroup = createObject('component','mvc.Models.AdvancedBudget.vos.BudgetGroup') />
		
		<cfif arguments.BudgetGroupId>
			
			<!--- do the query and get the data --->
			<cfset qGetBudgetGroup = getBudgetGroup(arguments.BudgetGroupId) />
			
			<cfset oBudgetGroup.id = qGetBudgetGroup.Budget_Group_ID />
			<cfset oBudgetGroup.number = qGetBudgetGroup.Budget_Group_Number />
			<cfset oBudgetGroup.desc = qGetBudgetGroup.Budget_Group_Desc />
			<cfset oBudgetGroup.active = qGetBudgetGroup.Active />
			<cfset oBudgetGroup.lastUpdatedDate = qGetBudgetGroup.Last_Updated_Date />
			<cfset oBudgetGroup.lastUpdatedBy = qGetBudgetGroup.Last_Updated_By />
					
		</cfif>
		
		<cfreturn oBudgetGroup />
	
	</cffunction>
	
	<cffunction name="saveBudgetGroup" returntype="void" access="public" hint="Will save the Budget Class into the database" output="true">
		<cfargument name="argBudgetGroup" type="mvc.Models.AdvancedBudget.vos.BudgetGroup" required="true" />
		
		<cfset var qInsertBudgetGroup = "" / >
		<cfset var qUpdateBudgetGroup = "" / >
		
		<cfset var oBudgetGroup = arguments.argBudgetGroup />
		
		<cfif oBudgetGroup.id eq 0>
			<!--- insert --->
			<cfquery name="qInsertBudgetGroup" datasource="#application.datasource#">
				INSERT INTO Budget_Group (				
					Budget_Group_Number,
					Budget_Group_Desc,
					Active,
					Last_Updated_Date,
					Last_Updated_By
				)
				VALUES (
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#oBudgetGroup.number#" />,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#oBudgetGroup.desc#" />,
					<cfqueryparam cfsqltype="cf_sql_bit" value="#oBudgetGroup.active#" />,
					GetDate(),
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#" />
				)
			</cfquery>
		
		<cfelse>
			<!--- update --->
			<cfquery name="qUpdateBudgetGroup" datasource="#application.datasource#">
				UPDATE	Budget_Group
				SET		Budget_Group_Number = <cfqueryparam cfsqltype="cf_sql_varchar" value="#oBudgetGroup.number#" />,
						Budget_Group_Desc = <cfqueryparam cfsqltype="cf_sql_varchar" value="#oBudgetGroup.desc#" />,
						Active = <cfqueryparam cfsqltype="cf_sql_bit" value="#oBudgetGroup.active#" />,
						Last_Updated_Date = GetDate(),
						Last_Updated_By = <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#" />
				WHERE	Budget_Group_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#oBudgetGroup.id#" />
			</cfquery>
		
		</cfif>
		
	</cffunction>

</cfcomponent>