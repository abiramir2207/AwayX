<!---
	FILENAME:	Program_Alert_Payment_Notification.cfm
	Copyright:	(c) 2014 Blacksmith Applications, Inc.
	CREATED BY:	Tim Ford
--->

<CFINCLUDE TEMPLATE="/get_Contact_Admin_Email_Address.cfm">
	
<CFQUERY NAME="qProgramPaymentNotifications" DATASOURCE="#Application.Datasource#">
	SELECT	DISTINCT cm.Contract_Number, cm.Contract_Main_ID, cm.Contract_Title, pcpo.Payment_Notification_Span, u.User_ID, u.User_Email
	FROM	Billback b
			INNER JOIN BB_Approved ba ON ba.billback_id = b.billback_id
			INNER JOIN Billback_Program bp ON bp.Billback_ID = b.Billback_ID AND bp.Deleted = 0
			INNER JOIN Contract_Main cm ON  cm.Contract_Main_ID = bp.Program_ID
			INNER JOIN Contract_Main_Aux_Data cma on cma.Contract_Main_ID = cm.Contract_Main_ID
			INNER JOIN Program_Control_Panel_Options pcpo ON pcpo.ProgramControl_Panel_Options_ID = cm.ProgramType_ID AND pcpo.Payment_Notification = 1
			INNER JOIN _Users u on u.User_ID = cm.Responsible_User_ID
	WHERE	b.Billback_Status_ID >= 3 
	AND		b.Billback_Status_ID <> 8
	AND		b.Deleted = 0
	AND		b.BB_Parent_ID IS NULL
	AND		DATEDIFF(d, ba.Date_Approved, getdate()) > = pcpo.Payment_Notification_Span
	AND		NOT EXISTS (SELECT Program_ID FROM Program_Alert_Payment_Notification_Log)
</CFQUERY>

<cfoutput>


<cfloop query="qProgramPaymentNotifications">
	
	<cfset variables.userEmail					= qProgramPaymentNotifications.User_Email />
	<cfset variables.contractNumber				= qProgramPaymentNotifications.Contract_Number />
	<cfset variables.contractTitle				= qProgramPaymentNotifications.Contract_Title />
	<cfset variables.paymentNotificationSpan	= qProgramPaymentNotifications.Payment_Notification_Span />
	<cfset variables.programID					= qProgramPaymentNotifications.Contract_Main_ID />
	<cfset variables.userId						= qProgramPaymentNotifications.User_ID />

	<cfsavecontent variable="variables.programAlertPaymentNotificationEmail">
	<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	<style>
		.tableheaders
		{
			font-size:13px;
			font-weight:bold;
			border-bottom:thin ##FFFFFF 0px; 
				
		}	
		BODY, TD, .normal
		{
			font-family : Arial;
			font-size : 8pt;
			color : Black;
		}
		TABLE.Maintable TD 
		{
			border-bottom:solid ##93BEE2 1px; font-size : 10px;
		}
		.normal
		{
			font-family : Arial;
			font-size : 8pt;
			color : Black;
		}	
	</style>
	<title>Program Alert Payment Notification</title>
	</head>
	<body>
		<p>
			<span style="FONT-SIZE: 12pt; FONT-FAMILY: 'Century Gothic'">
				Program Alert Payment Notification
			</span>
			<br>
			<span style="FONT-SIZE: 10pt; FONT-FAMILY: 'Century Gothic'">
				Please be advised that the last payment for program #variables.contractNumber# is greater than #variables.paymentNotificationSpan# days.
			</span>
		</p>	
	</body>
	</html>
	</cfsavecontent>

	<CF_EMAILWRAPPER  	
		TO 			= "#variables.userEmail#"
		FROM		= "#Contact_Admin_Email_Address#"
		SUBJECT		= "Program Alert Payment Notification: #variables.contractNumber# - #variables.contractTitle#"
		TYPE		= "html" 
		messagetype	= "1" 
		generatedby	= "1"
		appArea		= "1"
	>
		#variables.programAlertPaymentNotificationEmail#
	</CF_EMAILWRAPPER>

	<cfset useLakebaseForqLogNotification = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_alert_payment_notification_log")>
<cfif useLakebaseForqLogNotification>
	<cftry>
		<cfset application.oLakebase.insertRow("program_alert_payment_notification_log", {
			"program_id" = "#variables.programID#",
			"user_id" = "#variables.userId#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqLogNotification = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqLogNotification>
<CFQUERY NAME="qLogNotification" DATASOURCE="#Application.Datasource#">
		INSERT INTO Program_Alert_Payment_Notification_Log
			(Program_ID, User_ID)
		VALUES
			('#variables.programID#', '#variables.userId#')
	</CFQUERY>
</cfif>
	
</cfloop>

</cfoutput>
