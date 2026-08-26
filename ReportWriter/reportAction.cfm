<cfsetting enablecfoutputonly="Yes" showdebugoutput="Yes">
<CFIF NOT IsDefined("reportInclude")>
	<CFINCLUDE TEMPLATE="reportInclude.cfm">
</CFIF>
<!--------Set defaults------------->
<CFSET userID=request.AccessStructure.user_id>
<CFSET fromAction=true>
<!--------End Set defaults------------->

<!------------------------
JavaScript code for showing the Error Messages using client side pop up
---------------------------->
<SCRIPT LANGUAGE="JavaScript">
var arrErrors = new Array();
var arrSpans = new Array();
function addError(sErr,sSpan)
{
	var arLen = arrErrors.length;
	arrErrors[arLen] = sErr; 
	arrSpans[arLen] = sSpan;
}

function showError()
{
	var arLen = arrErrors.length;
	if(arLen > 0)
	{
		for(i=0;i<arLen;i++)
		{
			queueMessage(arrErrors[i], eval("document.all." + arrSpans[i]));
		}
		showMessageWindow();
	}
}
</SCRIPT>
<!------------------------
End JavaScript code for showing the Error Messages using client side pop up
---------------------------->


<!--------------
Validate Form Fields
------------------------>
<CFSCRIPT>
allClear = true;


//allClear = false;
//writeToErrorMessage("Invalid Email Address " & validEmail,"error_Email_Address");

sSql = "";

</CFSCRIPT>
<!--------------
End Validate Form Fields
------------------------>



<CFIF allClear>
<!----
<CFIF isDefined("Form.GenerateEmail")>
<cfinclude template = "reportEmailAction.cfm">
<!----</CFIF>---> --->

<cfif Form.rReportType EQ "ProgramSummary">
	<!-------------------------Program Summary Report--------------------------------------------------->
	<CFINCLUDE TEMPLATE="#getProgramReportPage#">
<cfelseif Form.rReportType EQ "invoiceprogramSummary">
	<CFINCLUDE TEMPLATE="#getnewProgramReportPage#">
<cfelseif Form.rReportType EQ "invoiceproductSummary">
	<CFINCLUDE TEMPLATE="#getnewProductReportPage#">
<cfelse>
<!-------------------------Product Summary Report--------------------------------------------------->
	<CFINCLUDE TEMPLATE="#getProductReportPage#">
</cfif>

	
<CFELSE>	
	<!----
	Some error occured, so show the main page with
	Error Message
	and also fill the form with the last edited but still not updated data	
	------->
	<cfoutput>Errrooooooooooooor</cfoutput>
	<!----
	<CFSET sErr=true>
	<CFSET action="showError">
	<CFINCLUDE template="#reportPage#">
	--->
</CFIF>
