<cfcomponent output="false">

	<cffunction name="init" output="false" returntype="components.programs.ProgramComponents">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="GetProgramComponents" output="false" returntype="query">
		<cfargument name="Discount_Type_ID" type="numeric"  required="false" default="0">
		<cfargument name="Program_ID" type="numeric"  required="false" default="0">
		<cfargument name="GL_Account_ID" type="numeric"  required="false" default="0">
		
		<cftransaction isolation="read_uncommitted">
		<cfswitch expression="#arguments.Discount_Type_ID#">
		<!--- Fixed Price --->
			<cfcase value="1">
				<cfquery name="qProgramComponents" datasource="#application.datasource#">
					SELECT 	*
					FROM 	Program_Fixed_Component
					WHERE	Deleted = 0
					<cfif arguments.Program_ID neq 0>
					AND		Program_ID = <cfqueryparam value="#arguments.Program_ID#" cfsqltype="CF_SQL_INTEGER">
					</cfif>
					<cfif arguments.GL_Account_ID neq 0>
					AND		GL_Account_ID = <cfqueryparam value="#arguments.GL_Account_ID#" cfsqltype="CF_SQL_INTEGER">
					</cfif>
				</cfquery>
			</cfcase>
		<!--- Rebate --->
			<cfcase value="2">
				<cfquery name="qProgramComponents" datasource="#application.datasource#">
					SELECT 	*
					FROM 	Program_Rebates_Component
					WHERE	Deleted = 0
					<cfif arguments.Program_ID neq 0>
					AND		Program_ID = <cfqueryparam value="#arguments.Program_ID#" cfsqltype="CF_SQL_INTEGER">
					</cfif>
					<cfif arguments.GL_Account_ID neq 0>
					AND		GL_Account_ID = <cfqueryparam value="#arguments.GL_Account_ID#" cfsqltype="CF_SQL_INTEGER">
					</cfif>
				</cfquery>
			</cfcase>
		<!--- Lump Sum --->
			<cfcase value="3">
				<cfquery name="qProgramComponents" datasource="#application.datasource#">
					SELECT 	*
					FROM 	Program_Lump_Sums
					WHERE	Deleted = 0
					<cfif arguments.Program_ID neq 0>
					AND		Program_ID = <cfqueryparam value="#arguments.Program_ID#" cfsqltype="CF_SQL_INTEGER">
					</cfif>
					<cfif arguments.GL_Account_ID neq 0>
					AND		GL_Account_ID = <cfqueryparam value="#arguments.GL_Account_ID#" cfsqltype="CF_SQL_INTEGER">
					</cfif>
				</cfquery>
			</cfcase>
		<!--- Growth --->
			<cfcase value="4">
				<cfquery name="qProgramComponents" datasource="#application.datasource#">
					SELECT 	*
					FROM 	Program_Growth_Components
					WHERE	Deleted = 0
					<cfif arguments.Program_ID neq 0>
					AND		Program_ID = <cfqueryparam value="#arguments.Program_ID#" cfsqltype="CF_SQL_INTEGER">
					</cfif>
					<cfif arguments.GL_Account_ID neq 0>
					AND		GL_Account_ID = <cfqueryparam value="#arguments.GL_Account_ID#" cfsqltype="CF_SQL_INTEGER">
					</cfif>
				</cfquery>
			</cfcase>
		</cfswitch>
		</cftransaction>
		
		<cfreturn qProgramComponents />
	
	</cffunction>

	
</cfcomponent>