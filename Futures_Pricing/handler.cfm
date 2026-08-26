<!------ handler.cfm ----->
<CFOUTPUT>
<CFSET PAGE_TITLE="Futures Pricing">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>#PAGE_TITLE#</TITLE>
</HEAD>

<BODY TOPMARGIN="2" leftmargin="2">
<cfinclude template="/Script/cf/string_functions.cfm">
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<SCRIPT SRC="/Common_Files/Delete_Functions.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/math_functions.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/Queue.js"></SCRIPT>
<script language="JavaScript" src="common/common.js"></script>
<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>

<cfinclude template="common/common.cfm">

<cfinclude template="handler_core.cfm" />

<input type="Hidden" name="pagePhase" value="#pagePhase#">
<cfif isDefined("requestObj")>
<script language="JavaScript">
	checkStatusBetweenFrames(#requestObj.getStatusId()#, "#form.command#", #form.id#);
	function checkStatusBetweenFrames(currStatus, sCommand, iId)
	{
		var parsentWinStatusObj = window.parent.statusId;
		if(parsentWinStatusObj)
		{
			if(parsentWinStatusObj.value != currStatus)
			{
				window.parent.location.href = "view.cfm?command=" + sCommand + "&id=" + iId;
			}
		}
	}
</script>
</cfif>
</BODY>
</HTML>
</CFOUTPUT>