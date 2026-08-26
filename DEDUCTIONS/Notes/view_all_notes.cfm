<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>View All Notes</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/fixed_popup.js"></SCRIPT>
</head>

<body onload = "mytimer = setTimeout('fcsOnMe()', 25);">

<cfset useLakebaseForDeductionInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForDeductionInfo>
	<cftry>
		<cfset DeductionInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions", {
				"select" = "dd_dedid",
				"deduction_id" = "eq.#Deduction_ID#"
			}),
			"dd_dedid"
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForDeductionInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeductionInfo>
<cfquery name="DeductionInfo" datasource="#application.datasource#">
	SELECT 	Deductions.DD_DedID
	FROM 	Deductions
	WHERE 	Deduction_ID = '#Deduction_ID#'
</cfquery>
</cfif>

<!---Get All Notes--->
<cfquery name="DD_Notes" datasource="#application.datasource#">
SELECT DD_Notes.*, _users.Name_First, _users.Name_Last
FROM 	DD_Notes
	LEFT JOIN _users 
	ON _users.User_ID = DD_Notes.DD_Note_By
WHERE 	DD_Notes.deleted = 0
AND 	Deduction_ID = '#Deduction_ID#'
ORDER BY DD_Note_Date DESC
</cfquery>

<div align="center">

<table width="90%" align="center"><tr><td valign="Center" align="Center">
<cfoutput>
<strong><FONT COLOR="Navy" SIZE="2"><B>Notes form Deduction ###DeductionInfo.DD_DedID#</B></font></strong></td><td valign="Center" align="right"><img src="/images/notes.gif">&nbsp;  </td></tr>
</cfoutput>
</table>

<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" WIDTH="100%" CLASS="MAINTABLE">
	<CFIF DD_Notes.RecordCount GT 0>
		<TR BGCOLOR="FFE083">
			<TD ><B>Notes</B></TD>
			<TD><B>Created</B></TD>
			<TD ><B>Created By</B></TD>
		</TR>
		<CFOUTPUT QUERY="DD_Notes">
			<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
				<TD >#DD_Notes.DD_Note#</TD>
				<TD NOWRAP width="120">#DateFormat(DD_Notes..DD_Note_Date,"mm/dd/yyyy")# #timeFormat(DD_Notes..DD_Note_Date, 'hh:mm:tt')# </TD>
				<TD NOWRAP width="100">
				<cfif (len(Name_First) GT 0) OR (len(Name_Last) GT 0)>
					#Name_First# #Name_Last#
				<cfelse>
					N/A
				</cfif>
				</TD>	
			</TR>
		</CFOUTPUT>
	</CFIF>
</TABLE>
</div>
<br><br><br>
<div align="center">
<CF_smallLink 
	title = "close window" 
	url = "##"
	parameters = "onClick=""javascript: window.close();return false;"""
>
</div>
</body>
</html>
