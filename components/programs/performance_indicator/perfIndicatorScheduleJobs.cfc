<cfcomponent>
	<cffunction name="GetReportName" access="public" returntype="query">
		<CFQUERY NAME="q_reportName" datasource="#application.datasource#">
			SELECT Max(Report_Type_ID) as maxReport_Type_ID
			FROM Report_Type
		</CFQUERY>
		<cfreturn q_reportName />
	</cffunction>
</cfcomponent>