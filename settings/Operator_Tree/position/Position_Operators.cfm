<!------ Position_Operators.cfm ----->
<cfparam name="URL.UID" 	default="">
<cfparam name="FORM.UID" 	default="#URL.UID#">
<CFIF FORM.UID NEQ "" AND IsNumeric(FORM.UID)>
<CFOUTPUT>
<CFSET ThisPage = CGI.SCRIPT_NAME>
<CFSET formName = "frmOperatorPosition">

<script language="JavaScript">
	 function submitForm()
	{
		var oForm = document.#formName#;
		oForm.action = "Operator_Position_Action.cfm";
		oForm.submit();
		return false;
	} 
</script>


<cfparam name="FORM.sort_by" 	default="Operator Name">
<cfparam name="FORM.sort_order" 	default="ASC">

<cfset operator = CreateObject("component","components.customer.operator.operator") />
<cfset StSearch = StructNew()>
<cfset StSearch.positionId = FORM.UID>	
<cfset GetOperators = operator.getOperator(StSearch, form.sort_by, form.sort_order)>	

<form action="#ThisPage#" method="post" name="#formName#" style="height:100%">
	<input type="Hidden" name="UID" value="#FORM.UID#">
	<cfinclude template="/settings/operator_tree/displayOperatorList.cfm">
</form>
</CFOUTPUT>
	
</CFIF>