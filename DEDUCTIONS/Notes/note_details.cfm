<cfparam name="Close" default="0">
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<cfset useLakebaseForDeductionsProfilesSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions_profiles_settings")>
<cfif useLakebaseForDeductionsProfilesSettings>
	<cftry>
		<cfset DeductionsProfilesSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions_profiles_settings", {
				"profiles_id" = "eq.#Get_Profile_Settings.Profiles_ID#"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForDeductionsProfilesSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeductionsProfilesSettings>
<cfquery name="DeductionsProfilesSettings" datasource="#application.datasource#">
SELECT * FROM Deductions_Profiles_Settings WHERE Profiles_ID = '#Get_Profile_Settings.Profiles_ID#'
</cfquery>
</cfif>

<cfif Close IS 1>
	<cfset useLakebaseForCloseReminder = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_notes")>
	<cfif useLakebaseForCloseReminder>
		<cftry>
			<cfset application.oLakebase.updateRows("dd_notes",
				{ "dd_note_id" = "eq.#DD_Note_ID#" },
				{ "deleted" = 1 }
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForCloseReminder = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForCloseReminder>
	<cfquery name="CloseReminder" datasource="#application.datasource#">
	UPDATE DD_Notes
	SET Deleted = 1
	WHERE DD_Note_ID = '#DD_Note_ID#'
	</cfquery>
	</cfif>
	
	<cfquery name="Latest_Notes" datasource="#application.datasource#">
		UPDATE Deductions
		SET Notes_Count = (SELECT COUNT(Deleted) FROM DD_Notes WHERE Deduction_ID  = Deductions.Deduction_ID AND Deleted = 0),
		Latest_DD_Note_ID = (SELECT TOP 1 DD_Note_ID FROM DD_Notes WHERE Deduction_ID  = Deductions.Deduction_ID AND Deleted = 0 ORDER BY Created_Date DESC)
		FROM Deductions WHERE Deleted = 0 AND Deduction_ID = '#Deduction_ID#'
	</cfquery>
		
	<script>
		window.close()		
		opener.document.all.Refresh.submit()
	</script>
	<cfabort>

</cfif>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Note Details</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/fixed_popup.js"></SCRIPT>
</head>

<body onload = "mytimer = setTimeout('fcsOnMe()', 25);">

<cfoutput>

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
SELECT Deductions.DD_DedID
FROM Deductions
WHERE Deduction_ID = '#Deduction_ID#'
</cfquery>
</cfif>

<!---Reminder data--->
<cfquery name="Note" datasource="#application.datasource#">
SELECT DD_Notes.*, isNull(_users.Name_First,DD_Note_By) as Name_First, _users.Name_Last
FROM DD_Notes
	LEFT JOIN _users 
	ON _users.User_ID = DD_Notes.DD_Note_By
WHERE DD_Note_ID = '#DD_Note_ID#'
</cfquery>

<div align="center">

<table width="90%" align="center"><tr><Td valign="Center">
<strong><font size="+1" color="navy">Note for Deduction ###DeductionInfo.DD_DedID#</font></strong></td><td valign="Center" align="right"><img src="/images/notes.gif">&nbsp; &nbsp; &nbsp; </TD></tr>

</table>

<table border="0" cellpadding="2" cellspacing="0" width="90%" align="center" style="border-left:solid navy 2px;	border-right:solid navy 2px; border-top:solid navy 2px; border-bottom:solid navy 2px;">

<tr>
	<td valign="top">Note Text:</td>
	<td colspan="2">#Note.DD_Note#</td>
</tr>
<tr>
	<td>Created By:</td>
	<td colspan="2">#Note.Name_First# #Note.Name_Last#</td>
</tr>
<tr>
	<td valign="top">Created On:</td>
	<td colspan="2">#DateFormat(Note.DD_Note_Date, 'MM/DD/YYYY')# #TimeFormat(Note.DD_Note_Date, 'H:MM tt')#</td>
</tr>

</table>
<cfif DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1>
	<table align="center">
	<tr><td  align="center">
		<CFIF Note.Automated_notes EQ 1>
		<font color="red">** System Automated Notes. No edit or delete permission given.</font>
		<CFELSE>
		<strong><A href="/deductions/notes/note_details.cfm?DD_Note_ID=#DD_Note_ID#&Deduction_ID=#Deduction_ID#&Close=1"><font color="navy">[ delete note ]</font></A></font>  <A href="/deductions/notes/create_note.cfm?DD_Note_ID=#DD_Note_ID#&Deduction_ID=#Deduction_ID#"><font color="navy">[ edit note ]</A></font></strong>		
		</CFIF>
	</td></tr>
	</table>
</cfif>
</div>
<!---Distributor contact info--->
</cfoutput>
</body>
</html>
