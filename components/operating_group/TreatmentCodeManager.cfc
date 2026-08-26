<cfcomponent displayname="TreatmentCodeManager" hint="Treatment Code Manager" extends="components.Base">


	<cffunction name="init" returntype="components.Operating_Group.TreatmentCodeManager" output="false">	
		<cfreturn this />		
	</cffunction>
	
	<cffunction name="getTreatmentCodes" output="false" returntype="query">
		<cfargument name="id" type="numeric" required="false" default="0" />
		<cfargument name="type" type="string" required="false" default="" />
		
		<!--- get the Treatment Codes --->
		<cfquery name="qGetTreatmentCodes" datasource="#application.datasource#">			
			SELECT 	Treatment_Code_Master_ID,
					Treatment_Code_ID Treatment_Code_Number,
					Treatment_Code_Desc,
					Treatment_Code_Type
			FROM 	Treatment_Code			
			WHERE	Deleted = 0
			AND		RTRIM(Treatment_Code_Desc) <> ''	
			<cfif arguments.id NEQ 0>
			AND		Treatment_Code_Master_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
			<cfif arguments.type NEQ "">
			AND		Treatment_Code_Type = <cfqueryparam value="#arguments.type#" cfsqltype="CF_SQL_VARCHAR">
			</cfif>
			ORDER BY Treatment_Code_Desc
		</cfquery>
		
		<cfreturn qGetTreatmentCodes />
		
	</cffunction>
	
	<cffunction name="getTreatmentCodeDesc" output="false" returntype="string">
		<cfargument name="id" type="numeric" required="true" />	
		
		<cfif arguments.id EQ 0>
			<cfreturn "" />
		<cfelse>
			<cfset qGetTreatmentCode = getTreatmentCodes(arguments.id) />
			<cfreturn qGetTreatmentCode.Treatment_Code_Desc />
		</cfif>
		
		
	</cffunction>
	
	
	
</cfcomponent>