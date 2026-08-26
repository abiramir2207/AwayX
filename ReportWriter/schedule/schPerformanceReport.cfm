<!--------------------------  schInvoiceReport.cfm ---------------------->

<!------------------- Get form value from DB------------------------->
<CFLOOP QUERY="q_getReportStructure">
	<cfif Ucase(trim(Report_Structure)) EQ "RREPORTTYPE">
		<cfset invoice_reportType = trim(Report_Structure_Value) >
	</cfif>
	<cfif trim(Report_Structure_Value) NEQ "none">
		<cfset Report_Structure_Actual_Value = trim(Report_Structure_Value) >
	<cfelse>
		<cfset Report_Structure_Actual_Value = "" >
	</cfif>
	<CFSET Evaluate("form.#Report_Structure#=""#Report_Structure_Actual_Value#""")>
</CFLOOP>
<!-----<CFINCLUDE TEMPLATE="generateProductReport.cfm">------->	
<cfset scheduleFlag = 1 >
<cfsilent><CFINCLUDE TEMPLATE="/Common_Files/Performance_Indicators/progPerfIndicator.cfm"></cfsilent>
<CFINCLUDE TEMPLATE="#schSendPerformance#">

<!--- retrieve form detail information from report related tables--->
<!--- redirect to the invoice action page with mail_flag = 2--->
<!--- send email along with the attached the html file to the user when job is done --->
