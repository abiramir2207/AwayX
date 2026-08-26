<cfcomponent displayname="AllowanceCodeManager" hint="Allowance Code Manager" extends="components.Base">


	<cffunction name="init" returntype="components.Operating_Group.AllowanceCodeManager" output="false">	
		<cfreturn this />		
	</cffunction>
	
	<cffunction name="getAllowanceCodes" output="false" returntype="query">
		<cfargument name="id" type="numeric" required="false" default="0" />
		
		<!--- get the Allowance Codes --->
		<cfquery name="qGetAllowanceCodes" datasource="#application.datasource#">			
			SELECT 	Allowance_Code_ID,
					Allowance_Code_Number,
					Allowance_Code_Desc,
					Basis_Code_Master_ID,
					Treatment_Code_Master_ID
			FROM 	Allowance_Code			
			WHERE	Deleted = 0			
			<cfif arguments.id NEQ 0>
			AND		Allowance_Code_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
		</cfquery>
		
		<cfreturn qGetAllowanceCodes />
		
	</cffunction>
	
	<cffunction name="getAllowanceCodeDesc" output="false" returntype="string">
		<cfargument name="id" type="numeric" required="true" />	
		
		<!--- get the Operating Groups --->
		<cfset qGetAllowanceCode = getAllowanceCodes(arguments.id) />		
		
		<cfreturn qGetAllowanceCode.Allowance_Code_Desc />
		
	</cffunction>
	
	
	
</cfcomponent>