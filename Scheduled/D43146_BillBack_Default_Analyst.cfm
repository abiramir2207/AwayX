<cfquery name="variables.qBillBacks" datasource="#application.datasource#">
  SELECT *
    FROM BILLBACK
   WHERE Analyst_User_Id IS NULL
</cfquery>

<!---<cfdump var="#variables.qBillBacks#" abort="true">--->


<cfset billbackAssignmentManager = CreateOBject("component", "components.billback.BillbackAssignmentManager") />

<cfoutput query="variables.qBillBacks">
  <cfset billbackAssignmentManager.saveBillbackAnalyst( variables.qBillBacks.BillBack_Id )>
</cfoutput>
