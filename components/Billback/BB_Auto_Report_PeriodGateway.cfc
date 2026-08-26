<cfcomponent output="false">

	<cffunction name="get" output="false" access="remote">
		<cfargument name="id" required="true" />
 		<cfreturn application.oBBReportPeriod.init(arguments.id)>
	</cffunction>


	<cffunction name="save" output="false" access="remote">
		<cfargument name="obj" required="true" />
 		<cfreturn obj.save() />
	</cffunction>


	<cffunction name="delete" output="false" access="remote">
		<cfargument name="id" required="true" />
		<cfset var obj = get(arguments.id)>
		<cfset obj.delete()>
	</cffunction>



	<cffunction name="getAll" output="false" access="remote" returntype="components.Billback.BB_Auto_Report_Period[]">
		<cfset var qRead="">
		<cfset var obj="">
		<cfset var ret=arrayNew(1)>

		<cfquery name="qRead" datasource="#application.datasource#">
			select BB_Auto_Report_Period_ID
			from dbo.BB_Auto_Report_Period
		</cfquery>

		<cfloop query="qRead">
		<cfscript>
			obj = application.oBBReportPeriod.init(qRead.BB_Auto_Report_Period_ID);
			ArrayAppend(ret, obj);
		</cfscript>
		</cfloop>
		<cfreturn ret>
	</cffunction>



	<cffunction name="getAllAsQuery" output="false" access="remote" returntype="query">
		<cfargument name="fieldlist" default="*" hint="List of columns to be returned in the query.">

		<cfset var qRead="">

		<cfquery name="qRead" datasource="#application.datasource#">
			select #arguments.fieldList#
			from dbo.BB_Auto_Report_Period
		</cfquery>

		<cfreturn qRead>
	</cffunction>




</cfcomponent>