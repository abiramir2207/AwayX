<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Call Details</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/fixed_popup.js"></SCRIPT>
</head>

<cfoutput>

<cfset useLakebaseForDeductionInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForDeductionInfo>
	<cftry>
		<cfset DeductionInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions", { "select" = "dd_dedid", "deduction_id" = "eq.#Deduction_ID#" })
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForDeductionInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeductionInfo>
	<cfquery name="DeductionInfo" datasource="#application.datasource#">
	SELECT Deductions.DD_DedID
	FROM Deductions
	WHERE Deduction_ID = '#Deduction_ID#'
	</cfquery>
</cfif>

<!---Reminder data--->
<cfquery name="CallLog" datasource="#application.datasource#">
SELECT DD_Call_Log.*, _users.Name_First, _users.Name_Last
FROM DD_Call_Log
	INNER JOIN _users 
	ON _users.User_ID = DD_Call_Log.Person_Who_Called
WHERE DD_Call_Log_ID = '#DD_Call_Log_ID#'
</cfquery>

<body onload = "mytimer = setTimeout('fcsOnMe()', 25);">

<div align="center">

<table width="90%" align="center"><tr><Td valign="Center">
<strong><font size="+1" color="navy">Call made for Deduction ###DeductionInfo.DD_DedID#</font></strong></td><td valign="Center" align="right"><img src="/images/notes.gif">&nbsp; &nbsp; &nbsp; </TD></tr>

</table>

<table border="0" cellpadding="2" cellspacing="0" width="90%" align="center" style="border-left:solid navy 2px;	border-right:solid navy 2px; border-top:solid navy 2px; border-bottom:solid navy 2px;">

<tr>
	<td valign="top">Called:</td>
	<td colspan="2">#CallLog.Person_Called#</td>
</tr>
<tr>
	<td valign="top">Call Notes:</td>
	<td colspan="2">#CallLog.Call_Synopsis#</td>
</tr>
<tr>
	<td>Created By:</td>
	<td colspan="2">#CallLog.Name_First# #CallLog.Name_Last#</td>
</tr>
<tr>
	<td valign="top">Created On:</td>
	<td colspan="2">#DateFormat(CallLog.Call_Date, 'MM/DD/YYYY')# #TimeFormat(CallLog.Call_Date, 'H:MM tt')#</td>
</tr>

</table>
<!--- <table align="center">
<tr><td  align="center"><strong><A href="/deductions/notes/note_details.cfm?DD_Note_ID=#DD_Note_ID#&Deduction_ID=#Deduction_ID#&Close=1"><font color="navy">[ delete note ]</font></A></font>  <A href="/deductions/notes/create_note.cfm?DD_Note_ID=#DD_Note_ID#&Deduction_ID=#Deduction_ID#"><font color="navy">[ edit note ]</A></font></strong></td></tr>
</table> --->

</div>
<!---Distributor contact info--->
</cfoutput>
</body>
</html>
