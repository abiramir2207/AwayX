<cfif isDefined("blnSubmit")>
	<cfset useLakebaseForgetCurrentNotes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("work_request")>
<cfif useLakebaseForgetCurrentNotes>
	<cftry>
		<cfset getCurrentNotes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("work_request", {
				"work_request_id" = "eq.#form.Work_Request_ID#",
				"select" = "notes as notesprevious"
			}), "notes as notesprevious"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetCurrentNotes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetCurrentNotes>
<cfquery name="getCurrentNotes" datasource="#application.datasource#">
		select  Notes as NotesPrevious
		from Work_Request
		where Work_Request_ID = '#form.Work_Request_ID#'
	</cfquery>
</cfif>
	<cfquery name="UpdateNotes" datasource="#application.datasource#">
		UPDATE Work_Request
		SET Notes = <cfqueryparam value="#form.Notes#">
		WHERE Work_Request_ID = '#form.Work_Request_ID#'
	</cfquery>

	<cfoutput>
	<cfset useLakebaseForGetUserInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForGetUserInfo>
	<cftry>
		<cfset GetUserInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#request.accessStructure.User_ID#",
				"select" = "name_first,name_last,user_email"
			}), "name_first,name_last,user_email"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetUserInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetUserInfo>
<cfquery name="GetUserInfo" datasource="#application.datasource#">
		SELECT Name_First, Name_Last, User_Email
		FROM _Users WHERE User_ID = '#request.accessStructure.User_ID#'
	</cfquery>
</cfif>

	<cfif form.Notes NEQ getCurrentNotes.NotesPrevious>
		<cfset useLakebaseForSupportEmail = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_application_settings")>
<cfif useLakebaseForSupportEmail>
	<cftry>
		<cfset SupportEmail = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_application_settings", {
				"select" = "ba_support_email"
			}), "ba_support_email"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForSupportEmail = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSupportEmail>
<cfquery name="SupportEmail" datasource="#application.datasource#">
			SELECT BA_Support_Email
			FROM _Application_Settings
		</cfquery>
</cfif>

		<CFIF application.oApplicationAppSettingsManager.getApplicationAppSettings().getWebserviceOn() EQ 1>

			<CFTHREAD ACTION="RUN" NAME="#GetUserInfo.Name_First##GetUserInfo.Name_Last##timeFormat(now(), 'HHmmsstt')##DateFormat(now(), 'mmm-dd-yyyy')#" Notes="#form.Notes#" Notes_UpdatedBy="#GetUserInfo.Name_First# #GetUserInfo.Name_Last#"  BA_Ticket_Number="#form.BA_Ticket_Number#"  User_Email="#GetUserInfo.User_Email#">
				<cfinclude template="work_request_notes_edit_thread.cfm">
				<cflog file="WRLog" application="no" text="WR The Notes field on Work Request #BA_Ticket_Number# has been updated by  #Notes_UpdatedBy#">
			</CFTHREAD>
		<CFELSE>
		<cfquery name="UpdateNotesPunch" datasource="punchlist">
			UPDATE Punch_Work_Request
			SET 	Notes_UpdatedBy = '#GetUserInfo.Name_First# #GetUserInfo.Name_Last#',
			Notes = <cfqueryparam value="#form.Notes#">
			WHERE Punch_ID = '#form.BA_Ticket_Number#'
		</cfquery>

		<cfset emailSubjet = 	"The Notes field on Work Request ###form.BA_Ticket_Number# has been updated by #GetUserInfo.Name_First# #GetUserInfo.Name_Last#">
		<cfset emailSubjetDetails = 	"The work request ###form.BA_Ticket_Number# has been updated by #GetUserInfo.Name_First# #GetUserInfo.Name_Last# at  #timeFormat(now(), 'HH:mm')# #DateFormat(now(), 'mm/dd/yy')#" >

		<cfquery name="PunchInformation" datasource="punchlist">
			SELECT Punch.*,  Punch_Status.Punch_Status_Desc,Punch_Function.Punch_Function_Desc, Punch_Type.Punch_Type_Desc,Punch_Priority.Punch_Priority_Desc
			FROM 	Punch
			LEFT JOIN Punch_Status 	ON Punch.Punch_Status_ID = Punch_Status.Punch_Status_ID
			LEFT JOIN Punch_Function  ON Punch.Punch_Function_ID = Punch_Function.Punch_Function_ID
			LEFT JOIN Punch_Type ON Punch.Punch_Type_ID = Punch_Type.Punch_Type_ID
			LEFT JOIN Punch_Priority ON Punch.Punch_Priority_ID = Punch_Priority.Punch_Priority_ID
			LEFT JOIN Punch_Priority_BA ON Punch.Punch_Priority_BA_ID = Punch_Priority_BA.Punch_Priority_BA_ID
			WHERE Punch_ID = '#form.BA_Ticket_Number#'
		</cfquery>
		<cfset Work_Request_ID_Mail ="#form.Work_Request_ID#">
		<cfinclude template="WR_emailFormat.cfm">
		</CFIF>
	</cfif>
	</cfoutput>
	<cfif Form.Search_Data eq 0>
		<script>
			window.opener.location.href = window.opener.location.href;
			window.close();
		</script>
	<cfelse>
		<script>
			var openerFormObj = opener.DataForm;
			openerFormObj.display.value = "searchResults";
			openerFormObj.submit();
			window.close();
		</script>
	</cfif>
</cfif>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>

	<title>Work Request Notes Edit</title>

</head>

<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- Dev Note: KAL - D7443: This stops the [get help] from displaying twice  --->
<CFSET GetHelpURL =1>

<CFPARAM NAME="URL.Work_Request_ID" DEFAULT=0>
<CFPARAM NAME="URL.Search_Data" DEFAULT=0>
<CFPARAM NAME="SaveDisabled"  DEFAULT="">
<CFPARAM NAME="SaveDisabledText"  DEFAULT="">
<body>


<CFSET URL.PageTitle="Work Request Notes Edit">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFQUERY NAME="Get_WR_Details" datasource="#application.datasource#">
	Select		*
	From		Work_Request
	Where Work_Request_ID = #Work_Request_ID#
</CFQUERY>

<cfquery name="GetUserInfo" datasource="#application.datasource#">
SELECT User_Code FROM _Users WHERE User_ID LIKE '#request.accessStructure.User_ID#'
</cfquery>

<cfif #Get_WR_Details.BA_Ticket_Number# EQ "" OR #Get_WR_Details.BA_Ticket_Number# EQ 0>
	<cfset SaveDisabled  = "disabled">
	<cfset SaveDisabledText = "Blacksmith is in the process of assigning a request ## to your record. Please modify this request later.">
</cfif>
	<TABLE BORDER="0" CELLSPACING="10" CELLPADDING="0" WIDTH="750">
		<cfoutput>

		<TR>
			<TD VALIGN="top">

				<SPAN CLASS="title2">#Get_WR_Details.BA_Ticket_Number# - #Get_WR_Details.Work_Title#</SPAN>
				<HR COLOR="Blue" SIZE="1">
				<form name="UpdateNotes" method="post" action="work_request_notes_edit.cfm">
					<input type="hidden" name="blnSubmit" value="1">
					<input type="hidden" name="Work_Request_ID" value="#Work_Request_ID#">
					<input type="hidden" name="Search_Data" value="#Search_Data#">
					<input type="hidden" name="BA_Ticket_Number" value="#Get_WR_Details.BA_Ticket_Number#">
					<!---<input type="hidden" name="NotesPrevious" value="#Get_WR_Details.Notes#">--->
					<textarea name="Notes" cols="140" rows="17"  #SaveDisabled#>#GetUserInfo.User_Code# #DateFormat(now(), "mm/dd/yy")# #timeFormat(now(), "HH:mm")#:
#trim(Get_WR_Details.Notes)# #SaveDisabledText#</textarea>

						<div align="right"><input type="submit" value="Modify notes"  #SaveDisabled#></div>
					</form>
			</TD>
		</TR>
		</cfoutput>

	</TABLE>

</body>
</html>

