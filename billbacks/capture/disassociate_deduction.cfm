<!--- Separate deduction and billback --->
<cfparam name="blnSubmit" default=0>

<cfif blnSubmit IS 1>

<cfquery name="UpdateDeductions" datasource="#application.datasource#">
UPDATE Deductions 
SET DD_Closure_ID = null
WHERE Deduction_ID = '#Deduction_ID#'
</cfquery>

<script>
opener.location.reload(true);
 self.close();

</script>

<cfelse>


<html>

<title>Disassociate deduction</title>

<body>

<div align="center">
Are you sure that you want to disassociate this deduction from this billback?
<p>
<cfoutput>
<form name="Disassociate" action="disassociate_deduction.cfm" method="post">
<input type="hidden" name="blnSubmit" value="1">
<input type="hidden" name="Deduction_ID" value="#Deduction_ID#">
<input type="hidden" name="Billback_ID" value="#Billback_ID#">
<input type="submit" value="Yes, disassociate">

</form>
</cfoutput>
</p>

</div>

</body>

</html>
</cfif>