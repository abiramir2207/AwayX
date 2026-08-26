<CFOUTPUT>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Category - Operators</title>
</head>

<body>
<CFSET ThisPage = CGI.SCRIPT_NAME>
<cfset pageLength = 18>
<!------ category_operators.cfm ----->
<cfparam name="url.id" 	default="0">
<cfparam name="form.id" 	default="#url.id#">
<cfparam name="form.sort_by" 	default="">
<cfparam name="form.sort_order" 	default="">
<cfif form.id>
	<cfset operator = CreateObject("component","components.customer.operator.operator") />
	<cfset StSearch = StructNew()>
	<cfset StSearch.categoryId = form.id>	
	<cfset GetOperators = operator.getOperator(StSearch, form.sort_by, form.sort_order)>	
	
	<CFSET formName = "frmOperatorCategory">
	<form action="#ThisPage#" method="post" name="#formName#">
		<input type="Hidden" name="id" value="#form.id#">
		<cfinclude template="/settings/operator_tree/displayOperatorList.cfm">
	</form>	
</cfif>

</body>
</html>
</CFOUTPUT>