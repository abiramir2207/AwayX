<cfcomponent displayname="BasisCodeManager" hint="Basis Code Manager" extends="components.Base">


	<cffunction name="init" returntype="components.Operating_Group.BasisCodeManager" output="false">	
		<cfreturn this />		
	</cffunction>
	
	<cffunction name="getBasisCodes" output="false" returntype="query">
		<cfargument name="id" type="numeric" required="false" default="0" />
		
		<!--- get the Basis Codes --->
		<cfquery name="qGetBasisCodes" datasource="#application.datasource#">			
			SELECT 	Basis_Code_Master_ID,
					Basis_Code_ID Basis_Code_Number,
					Basis_Code_Desc,
					Basis_Code_Type
			FROM 	Basis_Code			
			WHERE	Deleted = 0			
			<cfif arguments.id NEQ 0>
			AND		Basis_Code_Master_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
		</cfquery>
		
		<cfreturn qGetBasisCodes />
		
	</cffunction>
	
	<cffunction name="getBasicCodeDesc" output="false" returntype="string">
		<cfargument name="id" type="numeric" required="true" />	
		
		<cfif arguments.id EQ 0>
			<cfreturn "" />
		<cfelse>
			<cfset qGetBasisCode = getBasisCodes(arguments.id) />		
			<cfreturn qGetBasisCode.Basis_Code_Desc />
		</cfif>
		
	</cffunction>
	
	<cffunction name="getBasicCodeType" output="false" returntype="string">
		<cfargument name="id" type="numeric" required="true" />	
		
		<cfif arguments.id EQ 0>
			<cfreturn "" />
		<cfelse>
			<cfset qGetBasisCode = getBasisCodes(arguments.id) />		
			<cfreturn qGetBasisCode.Basis_Code_Type />
		</cfif>
		
	</cffunction>	
	
</cfcomponent>