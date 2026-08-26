<cfcomponent displayname="AccountingProgramTypeManager" hint="Accounting Program Type Manager" extends="components.Base">

	<cffunction name="init" returntype="components.programs.Accounting_Program_Type.AccountingProgramTypeManager" output="false">
		<cfreturn this />
	</cffunction>

	<cffunction name="getAccountingProgramTypes" output="false" returntype="query">
		<cfargument name="accPgmTypeId" type="numeric" required="false" default="0" />	
		
		<cfquery name="qGetAccountingProgramTypes" datasource="#application.datasource#">
			SELECT 	Accounting_Program_Type_ID, APT_Name, APT_Reference_Number
			FROM 	Accounting_Program_Type
			WHERE	Deleted = 0
			<cfif IsNumeric(arguments.accPgmTypeId) AND arguments.accPgmTypeId NEQ 0>
			AND		Accounting_Program_Type.Accounting_Program_Type_ID = <cfqueryparam value="#arguments.accPgmTypeId#" cfsqltype="CF_SQL_INTEGER">
			<cfelse>
			AND		Active = 1
			</cfif>
		</cfquery>
		
		<cfreturn qGetAccountingProgramTypes />
		
	</cffunction>
	
</cfcomponent>	
