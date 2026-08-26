<!------------------- reportDelete.cfm ---------------------------->
<CFIF NOT IsDefined("reportInclude")>
	<CFINCLUDE TEMPLATE="reportInclude.cfm">
</CFIF>

<CFPARAM NAME="URL.rID" DEFAULT="">
<CFPARAM NAME="rID" DEFAULT="#URL.rID#">

<cfset rDelete=true>
<cfset reportType="">
<CFIF isNumeric(rID)>
	<cfset commited=false>
	<cftransaction action = "begin">
		<cftry>		  	
	  	<cfquery name="q_GetReportType" datasource="#application.datasource#">
			Select 	Report_Type
			From	Report_Type
			Where	Report_Type_ID=#rID#
		</cfquery>
		<cfif q_GetReportType.recordCount GT 0>
			<cfset reportType=q_GetReportType.Report_Type>			
		</cfif>
		
		<cfquery name="q_ReportTemplateDelete" datasource="#application.datasource#">
			Delete 	Report_Template
			Where	Report_Type_ID=#rID#
		</cfquery>
		
		<cfquery name="q_ReportStructureDelete" datasource="#application.datasource#">
			Delete	Report_Structure
			Where	Report_Type_ID=#rID#
		</cfquery>
		
		<cfquery name="q_ReportDelete" datasource="#application.datasource#">
			Delete	Report_Type		
			Where	Report_Type_ID=#rID#
		</cfquery>

		
		<cfschedule action = "delete"
		  task = "#reportType##rID#">
		  
		<cftransaction action = "commit"/>
		<cfset commited=true>
		
			<!------<cfcatch type = "DATABASE">---->
			<cfcatch>
	    		<cftransaction action = "rollback"/>
					<P>#cfcatch.message#</P>
			</cfcatch>	
		</cftry>
		</cftransaction>
</CFIF>

<CFLOCATION URL="#reportListPage#" ADDTOKEN=false>
