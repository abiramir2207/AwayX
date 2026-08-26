<!---
	Name: 	budget_settings.cfm        
	Copyright (c) 2006 Blacksmith Applications, Inc.       
    Author: Clarence Morse         
	Label: 	9906
--->	

<CFPARAM NAME="url.viewMode" type="string" default="budget">
<CFSET PageTitle="BUDGET TEMPLATE MAPPINGS: #UCASE(URL.VIEWMODE)#">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">

<!---- Get Budget Groups --->
<!---- Get BudgetsGroupMembers --->
<!---- Get Templates --->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>

<script language="JavaScript" type="text/javascript">
	function loadview(type)
	{	if (type.value == "budget")
			window.location.href="budget_template_mappings.cfm?viewmode=budget";
		else if (type.value == "template")
			window.location.href="budget_template_mappings.cfm?viewmode=template";	}
</script>

</head>

<body>

<cfif url.viewMode EQ 'budget'>
	<!--- Placeholder For budget_view include --->
	<cfinclude template="btm_budget_view.cfm">
<cfelseif url.viewMode EQ 'template'>
	<!--- Placeholder for template_view include --->
	<cfinclude template="btm_template_view.cfm">
</cfif>
</body>
</html>
