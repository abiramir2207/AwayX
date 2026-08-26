<cfsetting enablecfoutputonly="Yes" showdebugoutput="Yes">
<CFIF NOT IsDefined("reportInclude")>
	<CFINCLUDE TEMPLATE="reportInclude.cfm">
</CFIF>
<!--------Set defaults------------->
<CFSET userID=request.AccessStructure.user_id>
<CFSET fromAction=true>
<!--------End Set defaults------------->

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
JavaScript code for showing the Error Messages using client side pop up
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx------->
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

sSql = "";

</CFSCRIPT>
<!--------------
End Validate Form Fields
------------------------>



<CFIF allClear>
	<CFINCLUDE TEMPLATE="#getProductMarginAnalysis#">
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
<cfif Form.rReportType EQ "Product_Based_Margin_Analysis">
	<!-------------------------Program Summary Report--------------------------------------------------->
	<CFINCLUDE TEMPLATE="#getProductMarginAnalysis#">
<cfelse>
<!-------------------------Product Summary Report--------------------------------------------------->
	<CFINCLUDE TEMPLATE="#getProgramMarginAnalysis#">
</cfif>

xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
	
<CFELSE>	
	<!----
	Some error occured, so show the main page with
	Error Message
	and also fill the form with the last edited but still not updated data	
	------->
	<cfoutput>
	<script language="JavaScript">
	alert("Some of the required fields are missing.");
	window.close();
	</script>
	</cfoutput>
	<!----
	<CFSET sErr=true>
	<CFSET action="showError">
	<CFINCLUDE template="#reportPage#">
	--->
</CFIF>
