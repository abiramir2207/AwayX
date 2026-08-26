<!---------------------------------------------------------------------------------------------------------------------
	Name:          	copyBudget.cfm
	Copyright:     	Copyright (c) 2011 Blacksmith Applications, Inc.
	Created Date:  	06/29/2011
	Created By:    	Deepa Kunnath
	Description:   	This page will copy a budget
	Parameters:		form.Budget_Id
	Usage:
----------------------------------------------------------------------------------------------------------------------->

<cfset vars = {}>

<CFSTOREDPROC PROCEDURE="ADV_BUDGET_COPY" datasource="#application.datasource#">
	<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_INTEGER "	DBVARNAME="@original_budget_id"		VALUE="#form.Budget_Id#">
	<!---<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_VARCHAR"	DBVARNAME="@Current_User_ID"				VALUE="#request.AccessStructure.User_ID#">--->
	<CFPROCPARAM TYPE="Out"	CFSQLTYPE="CF_SQL_INTEGER"	DBVARNAME="@new_budget_id"					VARIABLE="new_budget_id">	
</CFSTOREDPROC>

<cfquery name="vars.qBudget" datasource="#application.datasource#">
	SELECT 	b.Budget_Contribution_Factor_Type_ID
	FROM 	Budget b   
	WHERE 	b.Budget_ID = <cfqueryparam value="#new_budget_id#" cfsqltype="cf_sql_integer">
</cfquery>


<cfoutput>
<script language="javascript">
	document.forms[budget_form].budget_id.value = "#new_budget_id#";
	budget_type = "#vars.qBudget.Budget_Contribution_Factor_Type_ID#";
	document.forms[budget_form].load_fromdb.value = "1";
	
	if (budget_type == "1")
    	document.forms[budget_form].command.value = "editFixed";
  	else if (budget_type == "2")
    	document.forms[budget_form].command.value = "editAccrual";
  	else if (budget_type == "3")
    	document.forms[budget_form].command.value = "editVariable";
    
	document.forms[budget_form].submit();
</script>
</cfoutput>
