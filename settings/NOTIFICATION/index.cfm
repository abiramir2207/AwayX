<cfparam name="form.currentAction" default="view">
<cfparam name="form.Budgets_Program_Approve_Email_Address" default="">
<cfparam name="form.Budgets_Program_Approve_Email_Address" default="">
<cfparam name="form.Program_Without_Budget_Email_Address" default="">
<cfparam name="form.pgmEmailPricingAdmin" default=0>
<cfparam name="form.Send_New_Distributor_Default_Vendor_Email" default="">
<cfparam name="form.Send_New_Billback_Default_Vendor_Email" default="">
<cfparam name="form.send_bb_auto_uploaded" default="">
<cfparam name="form.Budgets_Billback_Approve_Email_Address" default="">
<cfparam name="form.billback_rfa_agree_email_event" default="0">
<cfparam name="form.Send_RFA_Agree_Emails_To_CRA_Users" default="0">
<cfparam name="form.RFA_Email_Event" default="0">

<style>

.dottedTop
{
	border-top: dashed #cccccc 1px;
}

</style>

<cf_include file_to_include="/script/tTip.js,/styles/tTip.css"/>

<script langauge="javascript">
		function ShowHideSummarizedEmail()
		{
				if(document.myForm.Send_Summarized_Weekly_Expiring_Email[0].checked == true)
				{
					document.all.Expiring_Email_Row.style.display= "none";
					document.myForm.Number_Of_Days_For_Summarized_Weekly_Expiring_Email.value= '';
				}
				else
				{
					document.all.Expiring_Email_Row.style.display= "";
				}
		}

		function ShowHideSendRFAemailstoCRA()
		{
				if(document.myForm.Notify_RSP_Only_NotAllHQUser[1].checked == true)
				{
					document.all.SendRFAAgreeEmailsToCRAUsers.style.display= "";
					document.all.DoNotSendRFAAgreeEmailsToCRAUsers.style.display= "";
					
				}
				else
				{
					document.all.SendRFAAgreeEmailsToCRAUsers.style.display = "none";
					document.all.DoNotSendRFAAgreeEmailsToCRAUsers.style.display= "none";
				}
		}
		

		function DoValidation()
		{
			var ErrorCount = 0;
			if(document.myForm.Send_Summarized_Weekly_Expiring_Email[1].checked == true && (document.myForm.Number_Of_Days_For_Summarized_Weekly_Expiring_Email.value == 0 || document.myForm.Number_Of_Days_For_Summarized_Weekly_Expiring_Email.value == '' ))
			{
				ErrorCount++;
				queueMessage("You must enter the number of days for summarized weekly notification of programs expiring", document.all.Expiring_Email_Days);
			}
			else
			{
				clearQueue(document.all.Expiring_Email_Days);
			}
			
			if(document.myForm.Send_Program_Starting_Email[1].checked == true && (document.myForm.Number_Of_Days_For_Program_Start.value == 0 || document.myForm.Number_Of_Days_For_Program_Start.value == '' ))
			{
				ErrorCount++;
				queueMessage("You must enter the number of days until the program starts", document.all.Number_Of_Days_For_Program_Start);
			}
			else
			{
				clearQueue(document.all.Number_Of_Days_For_Program_Start);
			}

			<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
			if(ErrorCount > 0)
			{
				showMessageWindow();
				return false;
			}
			else
			{
				document.myForm.submit();
			}
		}
</script>
<CF_MessageWindow>
<cfswitch expression="#form.currentAction#">
	<cfcase value="view">
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

	<html>
	<head>
		<title>Untitled</title>

	</head>

	<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" onLoad="ShowHideSummarizedEmail();ShowHideSendRFAemailstoCRA()">
	<CFSET PAGETITLE = "Email Notification Options">
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

	<cfquery name="getCurrentSettings" datasource="#application.datasource#">
		SELECT general_Settings.*, _Users.Name_First, _Users.Name_Last
		FROM general_Settings
			LEFT JOIN _Users
			ON _Users.User_ID = general_Settings.Email_Settings_Updated_By
	</cfquery>
<!--- D38427 : Billback email notifications  --->
	<cfset useLakebaseForgetAppSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_application_settings")>
<cfif useLakebaseForgetAppSettings>
	<cftry>
		<cfset getAppSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_application_settings", {
				"select" = "send_secondary_email,send_auto_attachments,send_approved_programs_emailadress,cancel_program_email,rfa_email_event,send_release_settlement_emailaddress,bb_agree_email,send_distributor_broker_email,send_create_auto_billback_email,email_auto_renewed_programs,bb_approved_email,ba_support_email,only_notify_rsp_of_approval,budgets_program_approve_email_address,budgets_billback_approve_email_address,send_program_error_ack_emailaddress,pgm_email_pricing_admin,third_party_bb_upload,program_without_budget_email_address,billback_rfa_agree_email_event,show_fixed_freight,send_summarized_weekly_notification_fuel_surcharge,billback_rfa_agree_email_event,notify_rsp_only_notallhquser,send_rfa_agree_emails_to_cra_users"
			}), "send_secondary_email,send_auto_attachments,send_approved_programs_emailadress,cancel_program_email,rfa_email_event,send_release_settlement_emailaddress,bb_agree_email,send_distributor_broker_email,send_create_auto_billback_email,email_auto_renewed_programs,bb_approved_email,ba_support_email,only_notify_rsp_of_approval,budgets_program_approve_email_address,budgets_billback_approve_email_address,send_program_error_ack_emailaddress,pgm_email_pricing_admin,third_party_bb_upload,program_without_budget_email_address,billback_rfa_agree_email_event,show_fixed_freight,send_summarized_weekly_notification_fuel_surcharge,billback_rfa_agree_email_event,notify_rsp_only_notallhquser,send_rfa_agree_emails_to_cra_users"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetAppSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetAppSettings>
<cfquery name="getAppSettings" datasource="#application.datasource#">
	SELECT 	Send_Secondary_Email, Send_Auto_Attachments, Send_Approved_programs_Emailadress, Cancel_Program_Email, RFA_Email_Event, send_release_settlement_emailaddress,
			BB_Agree_Email, Send_Distributor_Broker_Email, Send_Create_Auto_Billback_Email, Email_Auto_Renewed_Programs, BB_Approved_Email, BA_Support_Email, Only_Notify_RSP_Of_Approval,
			Budgets_Program_Approve_Email_Address, Budgets_Billback_Approve_Email_Address,send_Program_Error_Ack_emailaddress,Pgm_Email_Pricing_Admin,Third_Party_BB_Upload,
			Program_Without_Budget_Email_Address,Billback_RFA_Agree_Email_Event,Show_Fixed_Freight,Send_Summarized_Weekly_Notification_Fuel_Surcharge,
			Billback_RFA_Agree_Email_Event,Notify_RSP_Only_NotAllHQUser,Send_RFA_Agree_Emails_To_CRA_Users
	FROM 	_Application_Settings
	</cfquery>
</cfif>
		<cfoutput>
	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0" align="center">
<TR>
<TD>
	<FONT SIZE="2"><B>The settings were last updated on #dateformat(getCurrentSettings.Email_Settings_Updated_Date, 'mm/dd/yyyy')# #timeformat(getCurrentSettings.Email_Settings_Updated_Date, 'hh:mm:ss TT')# by #getCurrentSettings.Name_First# #getCurrentSettings.Name_Last#</B></FONT>	</TD>
</TD>
</TR>
</TABLE>

	<form name="myForm" action="index.cfm" method="post">

	<!---Developer's note: This updates both rfa_email and send_auto_rfa_email. They seem to always be used in conjunction with each other and do the same thing. BJF --->
<table border="0">

	<tr><td colspan="4"><strong><font color="navy" size="2">General Email Settings</font></strong></td></tr>
	
	<tr><td colspan="4">	<CF_smallLink 
					title = "Download documentation on these settings" 
					url = "/help_files/Blacksmith_Email_Notifications.doc"
					parameters = ""
				></td></tr>

	<!--- send_secondary_email --->
	<tr>
		<td align="right" class="dottedTop" valign="top"><strong>Send emails to user's secondary positions <br>(not just their primary)</strong><br>Used for status change emails only.</td>
		<td align="right" class="dottedTop">No<br>
		<td class="dottedTop"><input name="send_secondary_email" type="radio" value="0" <cfif getAppSettings.send_secondary_email EQ 0> CHECKED</cfif>></td>
	</tr>
	<tr>
		<td>&nbsp; </td>
		<td align="right">Yes</td>
		<td><input name="send_secondary_email" type="radio" value="1" <cfif getAppSettings.send_secondary_email EQ 1> CHECKED</cfif>></td>
	</tr>

	<!--- send_auto_attachments --->
	<tr>
		<td align="right" class="dottedTop" valign="top"><strong>Send emails with attachments (recommended)</strong></td>
		<td align="right" class="dottedTop">No<br>
		<td class="dottedTop"><input name="send_auto_attachments" type="radio" value="0" <cfif getAppSettings.send_auto_attachments EQ 0> CHECKED</cfif>></td>
	</tr>
	<tr>
		<td>&nbsp; </td>
		<td align="right">Yes</td>
		<td><input name="send_auto_attachments" type="radio" value="1" <cfif getAppSettings.send_auto_attachments EQ 1> CHECKED</cfif>></td>
	</tr>

		<!--- Blacksmith support email --->
	<tr>
		<td align="right"  class="dottedTop" valign="top"><strong>Blacksmith Support Email Address:</strong></td>
		<td align="right"  class="dottedTop">&nbsp; <br>
		<td  class="dottedTop"><input name="BA_Support_Email" type="text" size="75" maxlength="50" value="#getAppSettings.BA_Support_Email#"></td>
	</tr>


	<tr><td colspan="4" class="dottedTop"><strong><font color="navy" size="2"><br>Program Emails</font></strong></td></tr>

	<!---Provide option to email Pricing Admin--->
	<tr>
		<td align="right"  class="dottedTop" valign="top"><strong>Program: Provide option to email Pricing Admin</strong></td>
		<td align="right" class="dottedTop">No<br>
		<td class="dottedTop"><input name="pgmEmailPricingAdmin" type="radio" value="0" <cfif getAppSettings.Pgm_Email_Pricing_Admin EQ 0> CHECKED</cfif>></td>
	</tr>
	<tr>
		<td>&nbsp; </td>
		<td align="right">Yes</td>
		<td><input name="pgmEmailPricingAdmin" type="radio" value="1" <cfif getAppSettings.Pgm_Email_Pricing_Admin EQ 1> CHECKED</cfif>></td>
	</tr>

	<!---RFA_Email & Send_Auto_RFA_Email --->
	<tr>
		<td align="right"  class="dottedTop" valign="top"><strong>Send emails at all on 'Request for Approval' or 'Agree'</strong></td>

		<td align="right" class="dottedTop">No<br>
		<td class="dottedTop"><input name="rfa_email" type="radio" value="0" <cfif getCurrentSettings.RFA_Email EQ 0> CHECKED</cfif>></td>
	</tr>
	<tr>
		<td>&nbsp; </td>
		<td align="right">Yes</td>
		<td><input name="rfa_email" type="radio" value="1" <cfif getCurrentSettings.RFA_Email EQ 1> CHECKED</cfif>></td>
	</tr>

	<!---RFA_Email_Event --->
	<tr>
		<td align="right"  class="dottedTop" valign="top"><strong>Send above emails on:</strong></td>
		<td align="right" class="dottedTop">On 'RFA' only<br>
		<td class="dottedTop"><input type="radio" name="rfa_email_event" value="1" <cfif getAppSettings.RFA_Email_Event IS 1>checked</cfif>></td>
	</tr>
	<tr>
		<td>&nbsp; </td>
		<td align="right">On 'Agree' only </td>
		<td><input type="radio" name="rfa_email_event" value="2" <cfif getAppSettings.RFA_Email_Event IS 2>checked</cfif>></td>
	</tr>
	<tr>
		<td>&nbsp; </td>
		<td align="right">On both events</td>
		<td><input type="radio" name="rfa_email_event" value="3" <cfif getAppSettings.RFA_Email_Event IS 3>checked</cfif>></td>
	</tr>

	<!---Send_Approve_Email --->
	<tr>
		<td align="right"  class="dottedTop" valign="top"><strong>Send email when program is approved</strong></td>
		<td align="right" class="dottedTop">No<br>
		<td class="dottedTop"><input name="send_approve_email" type="radio" value="0" <cfif getCurrentSettings.send_approve_email EQ 0> CHECKED</cfif>></td>
	</tr>
	<tr>
		<td>&nbsp; </td>
		<td align="right">Yes</td>
		<td><input name="send_approve_email" type="radio" value="1" <cfif getCurrentSettings.send_approve_email EQ 1> CHECKED</cfif>></td>
	</tr>

	<!--- Only_Notify_RSP_Of_Approval --->
	<tr>
		<td align="right"  class="dottedTop" valign="top"><strong>Send email ONLY to RSP on approval</strong><br>(disregards broker and ship to selections -- will only email one user)</td>
		<td align="right" class="dottedTop">No<br>
		<td class="dottedTop"><input name="Only_Notify_RSP_Of_Approval" type="radio" value="0" <cfif getAppSettings.Only_Notify_RSP_Of_Approval EQ 0> CHECKED</cfif>></td>
	</tr>
	<tr>
		<td>&nbsp; </td>
		<td align="right">Yes</td>
		<td><input name="Only_Notify_RSP_Of_Approval" type="radio" value="1" <cfif getAppSettings.Only_Notify_RSP_Of_Approval EQ 1> CHECKED</cfif>></td>
	</tr>

	<!--- send_distributor_broker_email --->
	<tr>
		<td align="right"  class="dottedTop" valign="top"><strong>Upon approval, email all users associated to the ship to</strong></td>
		<td align="right" class="dottedTop">No<br>
		<td class="dottedTop"><input name="send_distributor_broker_email" type="radio" value="0" <cfif getAppSettings.send_distributor_broker_email EQ 0> CHECKED</cfif>></td>
	</tr>
	<tr>
		<td>&nbsp; </td>
		<td align="right">Yes</td>
		<td><input name="send_distributor_broker_email" type="radio" value="1" <cfif getAppSettings.send_distributor_broker_email EQ 1> CHECKED</cfif>></td>
	</tr>

	<!--- Send_Daily_Active_Email --->
	<tr>
		<td align="right"  class="dottedTop" valign="top"><strong>Send notification of program becoming active</strong></td>
		<td align="right" class="dottedTop">No<br>
		<td class="dottedTop"><input name="Send_Daily_Active_Email" type="radio" value="0" <cfif getCurrentSettings.Send_Daily_Active_Email EQ 0> CHECKED</cfif>></td>
	</tr>
	<tr>
		<td>&nbsp; </td>
		<td align="right">Yes</td>
		<td><input name="Send_Daily_Active_Email" type="radio" value="1" <cfif getCurrentSettings.Send_Daily_Active_Email EQ 1> CHECKED</cfif>></td>
	</tr>
	
		<!--- Send Program Starting in Pending status --->
	<tr>
		<td align="right"  class="dottedTop" valign="top"><strong>Send notification of program starting in Pending Status</strong></td>
		<td align="right" class="dottedTop">No<br>
		<td class="dottedTop"><input name="Send_Program_Starting_Email" type="radio" value="0" <cfif getCurrentSettings.Send_Program_Starting_Email EQ 0> CHECKED</cfif>></td>
	</tr>
	<tr>
		<td>&nbsp; </td>
		<td align="right">Yes</td>
		<td><input name="Send_Program_Starting_Email" type="radio" value="1" <cfif getCurrentSettings.Send_Program_Starting_Email EQ 1> CHECKED</cfif>></td>
	</tr>
	<tr>
		<td align="right"  valign="top"><strong>Number of days before program starts</strong></td>
		<td align="right" >&nbsp;  </td>
		<td><input name="Number_Of_Days_For_Program_Start" type="text" value="#getCurrentSettings.Number_Of_Days_For_Program_Start#" size="1" maxlength="3"></td>
	</tr>

	<!--- Send_Daily_Expiring_Email --->
	<tr>
		<td align="right"  class="dottedTop" valign="top"><strong>Send notification of programs expiring</strong></td>
		<td align="right" class="dottedTop">No<br>
		<td class="dottedTop"><input name="Send_Daily_Expiring_Email" type="radio" value="0" <cfif getCurrentSettings.Send_Daily_Expiring_Email EQ 0> CHECKED</cfif>></td>
	</tr>
	<tr>
		<td>&nbsp; </td>
		<td align="right">Yes</td>
		<td><input name="Send_Daily_Expiring_Email" type="radio" value="1" <cfif getCurrentSettings.Send_Daily_Expiring_Email EQ 1> CHECKED</cfif>></td>
	</tr>
	<!--- Send_Weekly_Expiring_Email --->
	<tr>
		<td align="right" class="dottedTop" valign="top"><strong>Send summarized weekly notification of programs expiring</strong></td>
		<td align="right" class="dottedTop">No<br>
		<td class="dottedTop"><input name="Send_Summarized_Weekly_Expiring_Email" type="radio" value="0" onClick="ShowHideSummarizedEmail()" <cfif getCurrentSettings.Send_Summarized_Weekly_Expiring_Email EQ 0> CHECKED</cfif>></td>
	</tr>
	<tr>
		<td>&nbsp; </td>
		<td align="right">Yes</td>
		<td><input name="Send_Summarized_Weekly_Expiring_Email" type="radio" value="1" onClick="ShowHideSummarizedEmail()" <cfif getCurrentSettings.Send_Summarized_Weekly_Expiring_Email EQ 1> CHECKED</cfif>></td>
	</tr>
	<!--- Number_Of_Days_For_Summarized_Weekly_Expiring_Email --->
	<span id="Expiring_Email_Days"></span>
	<tr id="Expiring_Email_Row">
		<td align="right"  valign="top"><strong>Number of days for summarized weekly notification of programs expiring</strong></td>
		<td align="right" >&nbsp;  </td>
		<td><input name="Number_Of_Days_For_Summarized_Weekly_Expiring_Email" type="text" value="#getCurrentSettings.Number_Of_Days_For_Summarized_Weekly_Expiring_Email#" size="1" maxlength="3"></td>
	</tr>

	<!--- Send_Daily_Expired_Email --->
	<tr>
		<td align="right"  class="dottedTop" valign="top"><strong>Send notification when a program has expired</strong></td>
		<td align="right" class="dottedTop">No<br>
		<td class="dottedTop"><input name="Send_Daily_Expired_Email" type="radio" value="0" <cfif getCurrentSettings.Send_Daily_Expired_Email EQ 0> CHECKED</cfif>></td>
	</tr>
	<tr>
		<td>&nbsp; </td>
		<td align="right">Yes</td>
		<td><input name="Send_Daily_Expired_Email" type="radio" value="1" <cfif getCurrentSettings.Send_Daily_Expired_Email EQ 1> CHECKED</cfif>></td>
	</tr>

	<!--- cancel_program_email --->
	<tr>
		<td align="right"  class="dottedTop" valign="top"><strong>Send notification when program has been cancelled</strong></td>
		<td align="right" class="dottedTop">No<br>
		<td class="dottedTop"><input name="cancel_program_email" type="radio" value="0" <cfif getAppSettings.cancel_program_email EQ 0> CHECKED</cfif>></td>
	</tr>
	<tr>
		<td>&nbsp; </td>
		<td align="right">Yes</td>
		<td><input name="cancel_program_email" type="radio" value="1" <cfif getAppSettings.cancel_program_email EQ 1> CHECKED</cfif>></td>
	</tr>

	<!--- Send_Broker_Email --->
	<tr>
		<td align="right" class="dottedTop"  valign="top"><strong>Send email to the broker associated with the program<br>(applies to all above)</strong></td>
		<td align="right" class="dottedTop">No<br>
		<td class="dottedTop"><input name="Send_Broker_Email" type="radio" value="0" <cfif getCurrentSettings.Send_Broker_Email EQ 0> CHECKED</cfif>></td>
	</tr>
	<tr>
		<td>&nbsp; </td>
		<td align="right">Yes</td>
		<td><input name="Send_Broker_Email" type="radio" value="1" <cfif getCurrentSettings.Send_Broker_Email EQ 1> CHECKED</cfif>></td>
	</tr>

	<!--- Email_Auto_Renewed_Programs --->
	<tr>
		<td align="right"  class="dottedTop" valign="top"><strong>Send email to RSP when auto renew program has been created</strong></td>
		<td align="right" class="dottedTop">No<br>
		<td class="dottedTop"><input name="Email_Auto_Renewed_Programs" type="radio" value="0" <cfif getAppSettings.Email_Auto_Renewed_Programs EQ 0> CHECKED</cfif>></td>
    </tr>

	<tr>
		<td>&nbsp; </td>
		<td align="right">Yes</td>
		<td><input name="Email_Auto_Renewed_Programs" type="radio" value="1" <cfif getAppSettings.Email_Auto_Renewed_Programs EQ 1> CHECKED</cfif>></td>
	</tr>

    <cfset request.Email_to_RSP_when_auto_revise_program_created = application.util.query.get_setting("Email_to_RSP_when_auto_revise_program_created", 0)>

	<tr>
		<td align="right" class="dottedTop" valign="top"><strong>Send email to RSP when auto revise program has been created</strong></td>
		<td align="right" class="dottedTop">No<br>
		<td class="dottedTop"><input name="Email_to_RSP_when_auto_revise_program_created" type="radio" value="0" <cfif request.Email_to_RSP_when_auto_revise_program_created eq 0> checked</cfif>></td>
    </tr>
	<tr>
		<td>&nbsp; </td>
		<td align="right">Yes</td>
		<td><input name="Email_to_RSP_when_auto_revise_program_created" type="radio" value="1" <cfif request.Email_to_RSP_when_auto_revise_program_created eq 1> checked</cfif>></td>
	</tr>
    

	<!--- Notify_RSP_Only_NotAllHQUser --->
	<tr>
		<td align="right" class="dottedTop" valign="top"><span onmouseout="popUpTip(event,'tNotifyRSPHQ');" onmouseover="popUpTip(event,'tNotifyRSPHQ');"> <strong>Send notification to RSP Only, Not All Users in HQ position</strong><img src="/images/help_small.gif" /></span>
		<div id="tNotifyRSPHQ" class="tip">
		When this setting is ON, if the Program RSP Position is Headquarters, the notifications will only go to the Program RSP and not all users in Headquarters position. 
		This applies to RFA, Agree, Active, Approved, Expiring, Cancelled and Expired notifications.     
		When the sub setting called Send RFA/Agree emails to CRA users is ON, this will send RFA/Agree emails to the program�s CRA users. 
		This setting was created because client has Distributor Trade programs where marketing managers are responsible for specific type codes.  
		The RFA/Agree emails are needed to notify them their product brands need agree/approve action.
		</div>
		</td>
		<td align="right" class="dottedTop">No<br>
		<td class="dottedTop"><input name="Notify_RSP_Only_NotAllHQUser" type="radio" value="0" onClick="ShowHideSendRFAemailstoCRA()" <cfif getAppSettings.Notify_RSP_Only_NotAllHQUser EQ 0> CHECKED</cfif>></td>
	</tr>
	<tr>
		<td>&nbsp; </td>
		<td align="right">Yes</td>
		<td><input name="Notify_RSP_Only_NotAllHQUser" type="radio" value="1" onClick="ShowHideSendRFAemailstoCRA()" <cfif getAppSettings.Notify_RSP_Only_NotAllHQUser EQ 1> CHECKED</cfif>></td>
	</tr>
	<tr id="SendRFAAgreeEmailsToCRAUsers">
		<td align="right" valign="top"><strong>Send RFA/Agree emails to CRA users</strong></td>
		<td align="right">No<br>
		<td><input name="Send_RFA_Agree_Emails_To_CRA_Users" type="radio" value="0" <cfif getAppSettings.Send_RFA_Agree_Emails_To_CRA_Users EQ 0> CHECKED</cfif>></td>
	</tr>
	<tr id="DoNotSendRFAAgreeEmailsToCRAUsers">
		<td>&nbsp; </td>
		<td align="right">Yes</td>
		<td><input name="Send_RFA_Agree_Emails_To_CRA_Users" type="radio" value="1" <cfif getAppSettings.Send_RFA_Agree_Emails_To_CRA_Users EQ 1> CHECKED</cfif>></td>
	</tr>
	
	<!--- 
			38586: Simplot ENH - Fuel Surcharge Expiring.   CF WORK / Anand Rao / 30-Jul-2013
			-- Send Summarized weekly notification of fuel surcharge expiring
	--->
	<cfif (getAppSettings.Show_Fixed_Freight)>
		<tr>
			<td align="right"  class="dottedTop" valign="top"><strong>Send Summarized weekly notification of fuel surcharge expiring</strong></td>
			<td align="right" class="dottedTop">No<br>
			<td class="dottedTop"><input name="Send_Summarized_Weekly_Notification_Fuel_Surcharge" type="radio" value="0" <cfif getAppSettings.Send_Summarized_Weekly_Notification_Fuel_Surcharge EQ 0> CHECKED</cfif>></td>
		</tr>
		<tr>
		<td>&nbsp; </td>
		<td align="right">Yes</td>
		<td><input name="Send_Summarized_Weekly_Notification_Fuel_Surcharge" type="radio" value="1" <cfif getAppSettings.Send_Summarized_Weekly_Notification_Fuel_Surcharge EQ 1> CHECKED</cfif>></td>
	</tr>
	<cfelse>
		<input name="Send_Summarized_Weekly_Notification_Fuel_Surcharge" type="hidden" value="#getAppSettings.Send_Summarized_Weekly_Notification_Fuel_Surcharge#">
	</cfif>
	<!--- END 38586 --->

	<!--- send_approved_programs_emailadress --->

	<tr>
		<td align="right"  class="dottedTop" valign="top"><strong>Send Approved Programs EmailAddress: <br>(if in doubt, leave this blank)</strong></td>
		<td align="right" class="dottedTop">&nbsp;  </td>
		<td class="dottedTop"><input name="send_approved_programs_emailadress" type="text" value="#getAppSettings.send_approved_programs_emailadress#" size="75" maxlength="225"></td>
	</tr>

	<!--- send_release_settlement_emailaddress --->
	<tr>
		<td align="right"  class="dottedTop" valign="top"><strong>Send Release Settlement report to the following address: <br>(if in doubt, leave this blank)</strong></td>
		<td align="right" class="dottedTop">&nbsp;  </td>
		<td class="dottedTop"><input name="send_release_settlement_emailaddress" type="text" value="#getAppSettings.send_release_settlement_emailaddress#" size="75" maxlength="100"></td>
	</tr>
	
	<!--- budget - program approve summary email --->
	<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getBudgetsFunctionalityOn()>
	<tr>
		<td align="right"  class="dottedTop" valign="top"><strong>Send summary email for programs that are <br>approved beyond budget dollars to the following address: <br>(leave blank for no email)</strong></td>
		<td align="right" class="dottedTop">&nbsp;  </td>
		<td class="dottedTop"><input name="Budgets_Program_Approve_Email_Address" type="text" value="#getAppSettings.Budgets_Program_Approve_Email_Address#" size="75" maxlength="225"></td>
	</tr>
	
	<tr>
		<td align="right"  class="dottedTop" valign="top"><strong>Send summary email for programs that <br>do not have a budget to the following address: <br>(leave blank for no email)</strong></td>
		<td align="right" class="dottedTop">&nbsp;  </td>
		<td class="dottedTop"><input name="Program_Without_Budget_Email_Address" type="text" value="#getAppSettings.Program_Without_Budget_Email_Address#" size="75" maxlength="225"></td>
	</tr>
	</cfif>
	
	<!--- Program_Error_Acknowledgement_emailaddress --->
	<tr>
		<td align="right"  class="dottedTop" valign="top"><strong>Send Program Error Acknowledgement report to the following address: <br>(if in doubt, leave this blank)</strong></td>
		<td align="right" class="dottedTop">&nbsp;  </td>
		<td class="dottedTop"><input name="send_Program_Error_Ack_emailaddress" type="text" value="#getAppSettings.send_Program_Error_Ack_emailaddress#" size="75" maxlength="100"></td>
	</tr>
	
	
	<!---***********************************************************************************--->
	<!---*********************** BILLBACK EMAILS - START  **********************************--->
	<!---***********************************************************************************--->
	
	<tr><td colspan="4" class="dottedTop"><strong><font color="navy" size="2"><br>Billback Emails</font></strong></td></tr>

<!--- D38427 : Billback email notifications START --->
		<!---Billback_RFA_Email & Send_Auto_Billback_RFA_Email --->
		<tr>
			<td align="right"  class="dottedTop" valign="top"><strong>Send emails at all on 'Request for Approval' or 'Agree'</strong></td>

			<td align="right" class="dottedTop">No<br>
			<td class="dottedTop"><input name="billback_rfa_email" type="radio" value="0" <cfif getAppSettings.BB_Agree_Email EQ 0> CHECKED</cfif>></td>
		</tr>
		<tr>
			<td>&nbsp; </td>
			<td align="right">Yes</td>
			<td><input name="billback_rfa_email" type="radio" value="1" <cfif getAppSettings.BB_Agree_Email EQ 1> CHECKED</cfif>></td>
		</tr>

		<!---Billback_RFA_Email_Event --->
		<tr>
			<td align="right"  class="dottedTop" valign="top"><strong>Send above emails on:</strong></td>
			<td align="right" class="dottedTop">On 'RFA' only<br>
			<td class="dottedTop"><input type="radio" name="billback_rfa_agree_email_event" value="1" <cfif getAppSettings.Billback_RFA_Agree_Email_Event IS 1>checked</cfif>></td>
		</tr>
		<tr>
			<td>&nbsp; </td>
			<td align="right">On 'Agree' only </td>
			<td><input type="radio" name="billback_rfa_agree_email_event" value="2" <cfif getAppSettings.Billback_RFA_Agree_Email_Event IS 2>checked</cfif>></td>
		</tr>
		<tr>
			<td>&nbsp; </td>
			<td align="right">On both events</td>
			<td><input type="radio" name="billback_rfa_agree_email_event" value="3" <cfif getAppSettings.Billback_RFA_Agree_Email_Event IS 3>checked</cfif>></td>
		</tr>



	<!--- BB_Agree_Email 
	<tr>
		<td align="right"  class="dottedTop" valign="top"><strong>Send email when a billback has been agreed to</strong></td>

		<td align="right" class="dottedTop">No<br>
		<td class="dottedTop"><input name="BB_Agree_Email" type="radio" value="0" <cfif getAppSettings.BB_Agree_Email EQ 0> CHECKED</cfif>></td>
	</tr>
	<tr>
		<td>&nbsp; </td>
		<td align="right">Yes</td>
		<td><input name="BB_Agree_Email" type="radio" value="1" <cfif getAppSettings.BB_Agree_Email EQ 1> CHECKED</cfif>></td>
	</tr> --->
			<!--- D38427 : Billback email notifications END --->
	<!--- BB_Approved_Email --->
	<tr>
		<td align="right"  class="dottedTop" valign="top"><strong>Send email on billback approval</strong></td>

		<td align="right" class="dottedTop">No<br>
		<td class="dottedTop"><input name="BB_Approved_Email" type="radio" value="0" CHECKED></td>
	</tr>
	<tr>
		<td>&nbsp; </td>
		<td align="right">Yes</td>
		<td><input name="BB_Approved_Email" type="radio" value="1" <cfif getAppSettings.BB_Approved_Email EQ 1> CHECKED</cfif>></td>
	</tr>

	<!--- send_daily_aging_billback_email --->
	<tr>
		<td align="right"  class="dottedTop" valign="top"><strong>Send notification about aging billbacks</strong></td>
		<td align="right" class="dottedTop">No<br>
		<td class="dottedTop"><input name="send_daily_aging_billback_email" type="radio" value="0" <cfif getCurrentSettings.send_daily_aging_billback_email EQ 0> CHECKED</cfif>></td>
	</tr>
	<tr>
		<td>&nbsp; </td>
		<td align="right">Yes</td>
		<td><input name="send_daily_aging_billback_email" type="radio" value="1" <cfif getCurrentSettings.send_daily_aging_billback_email EQ 1> CHECKED</cfif>></td>
	</tr>

	<!--- Removed: Setting no longer being used 
	<tr>
		<td align="right"  class="dottedTop" valign="top"><strong>Send email on auto billback creation</strong></td>

		<td align="right" class="dottedTop">No<br>
		<td class="dottedTop"><input name="Send_Create_Auto_Billback_Email" type="radio" value="0" <cfif getAppSettings.Send_Create_Auto_Billback_Email EQ 0> CHECKED</cfif>></td>
	</tr>
	<tr>
		<td>&nbsp; </td>
		<td align="right">Yes</td>
		<td><input name="Send_Create_Auto_Billback_Email" type="radio" value="1" <cfif getAppSettings.Send_Create_Auto_Billback_Email EQ 1> CHECKED</cfif>></td>
	</tr>
	--->
	<!--- send_bb_auto_uploaded --->

<!--- 	<tr>
		<td align="right"  class="dottedTop" valign="top"><strong>Send billback auto uploaded report to: <br>seperate multiple addresses with semi-colons<br>(if in doubt, leave this blank)</strong></td>
		<td align="right" class="dottedTop">&nbsp;  </td>
		<td class="dottedTop"><input name="send_bb_auto_uploaded" type="text" value="#getCurrentSettings.send_bb_auto_uploaded#" size="75" maxlength="250"></td>
	</tr> --->
	<input name="Send_Create_Auto_Billback_Email" type="hidden" value="0" />
	<!--- budget - billback approve summary email --->
	<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getBudgetsFunctionalityOn()>
	<tr>
		<td align="right"  class="dottedTop" valign="top"><strong>Send summary email for billbacks that are <br>approved beyond budget dollars to the following address: <br>(leave blank for no email)</strong></td>
		<td align="right" class="dottedTop">&nbsp;  </td>
		<td class="dottedTop"><input name="Budgets_Billback_Approve_Email_Address" type="text" value="#getAppSettings.Budgets_Billback_Approve_Email_Address#" size="75" maxlength="225"></td>
	</tr>
	</cfif>

	<!--- Send Auto Deviation Report --->
	<tr>
		<td align="right"  class="dottedTop" valign="top"><strong>Send auto deviation report to: <br>seperate multiple addresses with semi-colons</strong></td>
		<td align="right" class="dottedTop">&nbsp;  </td>
		<td class="dottedTop"><input name="Send_Auto_Deviation" type="text" value="#trim(getCurrentSettings.Send_Auto_Deviation)#" size="75" maxlength="250"></td>
	</tr>
	
	<tr>
		<td align="right"  class="dottedTop" valign="top">
		<strong>
			<!--- Send billback upload audit report emails to:  --->
			Send 3rd party BB upload audit report to: <br>
			seperate multiple addresses with semi-colons </strong> </td>
		<td align="right" class="dottedTop">&nbsp;</td>
		<td class="dottedTop"><TEXTAREA NAME="Send_Billback_Upload_Audit_Report_Email" COLS="75" ROWS="5">#getCurrentSettings.Send_Billback_Upload_Audit_Report_Email#</TEXTAREA></td>
	</tr>
	<cfif getAppSettings.Third_Party_BB_Upload eq 2>
		<tr>
			<td align="right" class="dottedTop" valign="top">
				<strong>
					Send email if record in 3rd party BB upload does not have a default vendor or closing method:<br> 
					seperate multiple addresses with semi-colons
				</strong>
			</td>
			<td align="right" class="dottedTop">&nbsp;</td>
			<td class="dottedTop"><TEXTAREA NAME="Send_New_Distributor_Default_Vendor_Email" COLS="75" ROWS="5">#getCurrentSettings.Send_New_Distributor_Default_Vendor_Email#</TEXTAREA></td>
		</tr>
	</cfif>

	<tr>
		<td align="right"  class="dottedTop" valign="top">
		<strong>
			<!--- Send billback upload audit report emails to:  --->
			Send Distributor Auto Add email to: <br>
			seperate multiple addresses with semi-colons </strong> </td>
		<td align="right" class="dottedTop">&nbsp;</td>
		<td class="dottedTop"><TEXTAREA NAME="Send_Distributor_Auto_Add_Email" COLS="75" ROWS="5">#getCurrentSettings.Send_Distributor_Auto_Add_Email#</TEXTAREA></td>
	</tr>
		
		<!---***********************************************************************************--->
	<!---*********************** DEDUCTION EMAILS - BEGIN  ********************************--->
	<!---***********************************************************************************--->
	<tr><td colspan="4" class="dottedTop"><strong><font color="navy" size="2"><br>Deduction Emails</font></strong></td></tr>
	
	<tr>
		<td align="right"  class="dottedTop" valign="top"><strong>Send summary email report for <br> all open deductions with non-active customers :<br>(leave blank for no email)</strong></td>
		<td align="right" class="dottedTop">&nbsp;  </td>
		<!--- <td class="dottedTop"><input name="Budgets_Billback_Approve_Email_Address" type="textarea"  value="#getAppSettings.Budgets_Billback_Approve_Email_Address#" size="75" maxlength="225"></td> --->
		<td class="dottedTop"><input name="Open_DD_Inactive_Customers_Email_Address" value="#getCurrentSettings.Open_DD_Inactive_Customers_Email_Address#" size="75" maxlength="225"/></td>

	</tr>	

	<!---***********************************************************************************--->
	<!---*********************** JOB STATUS EMAILS - BEGIN  ********************************--->
	<!---***********************************************************************************--->
		<tr><td colspan="4" class="dottedTop"><strong><font color="navy" size="2"><br>Job Status Emails</font></strong></td></tr>
	
	<tr>
		<td align="right"  class="dottedTop" valign="top"><strong>Send job status emails to: <br>seperate multiple addresses with semi-colons</strong></td>
		<td align="right" class="dottedTop">&nbsp;  </td>
		<td class="dottedTop"><TEXTAREA NAME="send_job_status_email" COLS="75" ROWS="5">#getCurrentSettings.send_job_status_email#</TEXTAREA></td>
	</tr>
	<tr>
		<td colspan="3" align="right" class="dottedTop">&nbsp;  </td>
	</tr>	
	
	<!---***********************************************************************************--->
	<!---*********************** BILLBACK UPLOAD AUDIT REPORT EMAILS - BEGIN  ********************************--->
	<!---***********************************************************************************--->
	<!---
	<tr><td colspan="4" class="dottedTop"><strong><font color="navy" size="2"><br>Billback Upload Audit Report Emails</font></strong></td></tr>
	
	<tr>
		<td align="right"  class="dottedTop" valign="top">
			<strong>
				<!--- Send billback upload audit report emails to:  --->
				Send 3rd party BB upload audit report to:
				<br>seperate multiple addresses with semi-colons
			</strong>
		</td>
		<td align="right" class="dottedTop">&nbsp;  </td>
		<td class="dottedTop"><TEXTAREA NAME="Send_Billback_Upload_Audit_Report_Email" COLS="75" ROWS="5">#getCurrentSettings.Send_Billback_Upload_Audit_Report_Email#</TEXTAREA></td>
	</tr>
	<tr>
		<td colspan="3" align="right" class="dottedTop">&nbsp;  </td>
	</tr>
	
	<!---***********************************************************************************--->
	<!---*********************** NEW DISTRIBUTOR DEFAULT VENDOR OR BB CLOSING METHOD EMAILS - BEGIN  ********************************--->
	<!---***********************************************************************************--->
	<cfif getAppSettings.Third_Party_BB_Upload eq 2>
	<tr><td colspan="4" class="dottedTop"><strong><font color="navy" size="2"><br>Records Without a Default Vendor or Default BB Closing Method</font></strong></td></tr>
	
	<tr>
		<td align="right"  class="dottedTop" valign="top"><strong>Send email if either a distributor or a Tibersoft billback does not have a default vendor/default bb closing method: <br>seperate multiple addresses with semi-colons</strong></td>
		<td align="right" class="dottedTop">&nbsp;  </td>
		<td class="dottedTop"><TEXTAREA NAME="Send_New_Distributor_Default_Vendor_Email" COLS="75" ROWS="5">#getCurrentSettings.Send_New_Distributor_Default_Vendor_Email#</TEXTAREA></td>
	</tr>
	<tr>
		<td colspan="3" align="right" class="dottedTop">&nbsp;  </td>
	</tr>
	</cfif>
	--->
</table>
	<input type="Hidden" name="currentAction" value="update">
	<BR>
	<input type="button" value="Save" onClick="DoValidation()">
	</form>

    </cfoutput>
    
	</body>
	</html>
	</cfcase>

	<cfcase value="update">

		<cfquery name="saveChanges" datasource="#application.datasource#">
			UPDATE general_Settings
			SET
				RFA_Email 						= 	'#form.rfa_email#',
				Send_Auto_Rfa_Email 			= 	'#form.rfa_email#',
				send_approve_email				=   '#form.send_approve_email#',
				Send_Broker_Email				= 	'#form.Send_Broker_Email#',
				Send_Daily_Active_Email			= 	'#form.Send_Daily_Active_Email#',
				Send_Daily_Aging_Billback_Email	= 	'#form.Send_Daily_Aging_Billback_Email#',
				Send_Daily_Expiring_Email		= 	'#form.Send_Daily_Expiring_Email#',
				Send_Summarized_Weekly_Expiring_Email		= 	'#form.Send_Summarized_Weekly_Expiring_Email#',
				Number_Of_Days_For_Summarized_Weekly_Expiring_Email		= 	'#form.Number_Of_Days_For_Summarized_Weekly_Expiring_Email#',
				Send_Daily_Expired_Email		= 	'#form.Send_Daily_Expired_Email#',
				Send_Program_Starting_Email     =   '#Send_Program_Starting_Email#',
				Number_Of_Days_For_Program_Start =  #Number_Of_Days_For_Program_Start#,
				send_bb_auto_uploaded			= 	'#form.send_bb_auto_uploaded#',
				Send_Auto_Deviation				=	'#trim(form.Send_Auto_Deviation)#',
				Open_DD_Inactive_Customers_Email_Address = <cfqueryparam value="#form.Open_DD_Inactive_Customers_Email_Address#" cfsqltype="cf_sql_varchar">,
				Email_Settings_Updated_By		= 	'#request.AccessStructure.User_ID#',			
				Send_Job_Status_Email = '#trim(form.Send_Job_Status_Email)#',
				Send_Billback_Upload_Audit_Report_Email = '#trim(form.Send_Billback_Upload_Audit_Report_Email)#',
				Send_New_Distributor_Default_Vendor_Email = '#trim(form.Send_New_Distributor_Default_Vendor_Email)#',
				Email_Settings_Updated_Date		=	getdate(),
				Send_Distributor_Auto_Add_Email = '#trim(FORM.Send_Distributor_Auto_Add_Email)#'
		</cfquery>

		<cfquery name="SaveAppSettingChanges" datasource="#application.datasource#">
			UPDATE _application_settings
			SET
				send_secondary_email				=	'#form.send_secondary_email#',
				send_auto_attachments				=	'#form.send_auto_attachments#',
				send_approved_programs_emailadress	=	'#form.send_approved_programs_emailadress#',
				cancel_program_email				=	'#form.cancel_program_email#',
				rfa_email_event						=	'#form.rfa_email_event#',
				bb_Agree_Email						=	'#form.billback_rfa_email#',
				BB_Approved_Email					= 	'#form.BB_Approved_Email#',
				send_distributor_broker_email		=	'#form.send_distributor_broker_email#',
				Email_Auto_Renewed_Programs			=	'#form.Email_Auto_Renewed_Programs#',
				Send_Create_Auto_Billback_Email 	= 	'#Send_Create_Auto_Billback_Email#',
				send_release_settlement_emailaddress = '#form.send_release_settlement_emailaddress#',
				BA_Support_Email					= 	'#BA_Support_Email#',
				Only_Notify_RSP_Of_Approval			= 	'#Only_Notify_RSP_Of_Approval#',
				Budgets_Program_Approve_Email_Address	=	'#Form.Budgets_Program_Approve_Email_Address#',
				Program_Without_Budget_Email_Address	= 	'#Form.Program_Without_Budget_Email_Address#',
				Budgets_Billback_Approve_Email_Address	=	'#Form.Budgets_Billback_Approve_Email_Address#',
				send_Program_Error_Ack_emailaddress = '#FORM.send_Program_Error_Ack_emailaddress#',
				Pgm_Email_Pricing_Admin = '#FORM.pgmEmailPricingAdmin#',
				billback_rfa_Agree_email_event						=	'#form.billback_rfa_agree_email_event#',<!---D38427 : Billback email notifications  --->
				Send_Summarized_Weekly_Notification_Fuel_Surcharge = '#FORM.Send_Summarized_Weekly_Notification_Fuel_Surcharge#',
				Notify_RSP_Only_NotAllHQUser = '#FORM.Notify_RSP_Only_NotAllHQUser#',
				Send_RFA_Agree_Emails_To_CRA_Users = '#FORM.Send_RFA_Agree_Emails_To_CRA_Users#'
		</cfquery>

		<cfinclude template="/Application_AppSettingsMan.cfm">

        <cfif structKeyExists(form, "Email_to_RSP_when_auto_revise_program_created")>
            <cfquery datasource="#application.datasource#">
                UPDATE _Settings 
                   SET Value = #form.Email_to_RSP_when_auto_revise_program_created#
                 WHERE Input_Name = 'Email_to_RSP_when_auto_revise_program_created'
            </cfquery>
        </cfif>

		<cflocation url="index.cfm">
	</cfcase>
</cfswitch>

<!--- update the application var application.appSettingsGet used in other templates --->
<cfinclude template="/Application_AppSettingsMan.cfm">