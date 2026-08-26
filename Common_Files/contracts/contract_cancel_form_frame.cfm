<!-----
		Name: 			contract_cancel_form_frame.cfm
               			Copyright (c) 2006 Blacksmith Applications, Inc.
		Created:
						03/13/2006
						Deepa Kunnath
		Last Modified:
						03/13/2006
						Deepa Kunnath
		Description:
                       This page gives differet cancel options to the user when user click cancel program

		Parameters:
                       CID - encrypted program ID
		Usage:
                       contract_cancel_form_frame.cfm?CID=0202J8444AB6AA54B0A040441
----->

<cfparam name="URL.CID" 	default="">
<cfif URL.CID NEQ "">
	<cf_cryp type="de" string ="#URL.CID#" key="#request.key#">
	<CFSET Program_ID = cryp.value>

	<cfset program = CreateObject("component", "components.programs.program") />
	<cfset qGetProgramInfo = program.getProgramInfo(Program_ID) />
	<cfset qGetProgramUserSettings = program.getProgramUserSettings() />

	<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
	<cfif appSettings.getcancelallprogramversions()>
		<cfset ProgramOrVersion = "program">
	<cfelse>
		<cfset ProgramOrVersion = "version">
	</cfif>	
	
	<cfset option2Available = 0 />
	<!------ only if today is between the contract start date and end date ----->
	<!--- 31691 if program start date is greater than �today�, then, update both the program start date and program end date to be equal to �today�
	<cfif 		dateDiff("d", qGetProgramInfo.Contract_Start_Date, Now()) GTE 0
			AND	dateDiff("d", Now(), qGetProgramInfo.Contract_End_Date) GT 0>
		<cfset option2Available = 1 />
	</cfif>
	--->
	<cfif dateDiff("d", Now(), qGetProgramInfo.Contract_End_Date) GTE 0>
		<cfset option2Available = 1 />
	</cfif>
	<cfinclude template="/Get_Access_Profile.cfm" />

	<cfset selected = "" />
	<cfif qGetProgramUserSettings.Cancel_Program_Options EQ 2>
		<cfset selected = "checked" />
	</cfif>
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

	<html>
	<head>
		<title><cfoutput>Cancel #ProgramOrVersion# [#qGetProgramInfo.Contract_Number#] #qGetProgramInfo.Contract_Title#</cfoutput></title>
	</head>

	<body>
	<CFIF Get_Profile_Settings.Delete_Program_Access EQ 0>

	<table align="center" cellpadding="4" cellspacing="0">
	<tr>
		<td style="color:red;font-weight:bold;">You do not have access to cancel this #ProgramOrVersion#</td>
	</tr>
	<tr>
	<td align="center">
	<CF_smallLink
			title = "close window"
			url = "##"
			parameters = "onClick=""javascript: window.close();return false;"""
		>
	</td>
	</tr>
	</table>

	<cfabort>
	</CFIF>


	<script language="JavaScript">
	function cancelProgram() {
		var cancel_option = 0;
		var cancelFormID  = "CancelForm";
		if (window.dialogArguments)      // chromefix
			var oParentForm = window.dialogArguments.document.getElementById(cancelFormID);
		else
			var oParentForm = window.opener.document.getElementById(cancelFormID);

		if(document.all.cancel_option[1].checked)
			cancel_option = 1;

		oParentForm.cancel_option.value = cancel_option;
		oParentForm.submit();
		window.close();
		return true;
	}
	</script>
	<br>
	<table align="center" cellpadding="4" cellspacing="0" border="0">
	<caption style="font-weight:bold;"><cfoutput>Cancel #ProgramOrVersion# [#qGetProgramInfo.Contract_Number#] #qGetProgramInfo.Contract_Title#</cfoutput>
	</caption>
	<cfoutput>
	<tr <cfif qGetProgramUserSettings.Cancel_Program_Options EQ 2 > style="display:none"</cfif>>	
	<td colspan="2" align="left">
	<input type="Radio" name="cancel_option" value="1" checked>Cancel #ProgramOrVersion# and retain the original end date of the #ProgramOrVersion# (#DateFormat(qGetProgramInfo.Contract_End_Date, "mm/dd/yyyy")#)<br />
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This option treats the #ProgramOrVersion# as if it were never a valid #ProgramOrVersion#.
	</td>
	</tr>
	<tr <cfif qGetProgramUserSettings.Cancel_Program_Options EQ 1 > style="display:none"</cfif>>
	<td colspan="2" align="left">
	<input type="Radio" name="cancel_option" value="2" <cfif option2Available EQ 0>DISABLED<cfelse>#selected#</cfif>>Cancel #ProgramOrVersion# and set end date = today (#DateFormat(Now(), "mm/dd/yyyy")#)<br />
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This option treats the #ProgramOrVersion# as if it were valid from its start date until today. After &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;today it is considered canceled and no longer valid.
	</td>	
	</tr>
	<tr>
	<td align="center" style="color:red" colspan="2">
	If you are trying to cancel the #ProgramOrVersion# with a future end date, please revise the #ProgramOrVersion#, establish a new end date and request approval
	</td>
	</tr>
	</cfoutput>
	<tr>
	<td align="center">
	<CF_smallLink
			title = "cancel #ProgramOrVersion#"
			url = "##"
			parameters = "onClick=""javascript: return cancelProgram();"""
		>
	</td>
	<td align="center">
	<CF_smallLink
			title = "close window"
			url = "##"
			parameters = "onClick=""javascript: window.close();return false;"""
		>
	</td>
	</tr>

	</table>


	</body>
	</html>
</cfif>