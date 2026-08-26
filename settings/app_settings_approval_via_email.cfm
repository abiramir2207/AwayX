<!---
	Copyright (c)2009 Blacksmith Applications, Inc.
	Filename:		AwayX/settings/app_settings_approval_via_email.cfm
	Created:		7/30/2009
	Developer:		kvangapalli
	Description:	This page is used to set/modify the settings for approval via email
	Usage:			AwayX/mvc/Models/Program/Approval/EmailApprovalManager.cfc
	WR:				34144,34979,35686
					D61738 - Remote Approval for Exchange Online / Office 365 - 6/15/2016
					D78742 - Remote Approval for billbacks - 8/15/2018

--->
<style type="text/css">
	tr.divider { background-color: white !important; }
	tr.divider > td { font-weight: bold; font-size:15px; letter-spacing: 1px; text-transform: uppercase; text-shadow: 4px 4px 4px #aaa; color:red; }
</style>
<cfoutput>
<cfset genSettingsManager = createObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset application.oController.getObject(path="mvc.Models.Program.Approval.EmailApprovalManager",name="EmailApprovalManager",bReload= 1) />
<cfset application.oController.getObject(path="components.settings.encryption",name="cryp_key",bReload= 0) />
<cfset variables.cryp_key  = application.ocryp_key.getPasswordKey() />

<!--- get Auto Approver Settings --->
<cfset variables.qGetAutoApproverSettings 	= application.oEmailApprovalManager.getAutoApproverSettings() />
<cfset variables.autoApproveEmail 			= variables.qGetAutoApproverSettings.Auto_Approve_Email />
<cfset variables.bbAutoApproveEmail 		= variables.qGetAutoApproverSettings.BB_Auto_Approve_Email />
<cfset variables.userName 					= variables.qGetAutoApproverSettings.userName />
<cfset variables.mailServer					= variables.qGetAutoApproverSettings.mail_Server />
<cfset variables.domainServer				= variables.qGetAutoApproverSettings.domain_Server />
<cfset variables.mailFolder					= variables.qGetAutoApproverSettings.mail_Folder />
<cfset variables.mailSSL 					= variables.qGetAutoApproverSettings.Mail_SSL />
<!--- Use the decrypt function to get the password --->
<cf_cryp string="#variables.qGetAutoApproverSettings.password#" type="de" key="#variables.cryp_key#">
<cfparam name="cryp.value" 	default=""/>
<cfset variables.password 	= cryp.value />

<!--- Dev Note: KAL; 08/27/2012; Dxxxx: Remote Approval for Exchange 2010 using EWS Java API --->
<!--- ********** begin: java objects for exchange 2010 support ********** --->
<!--- 1. Create an instance of the ExchangeService class --->
<cfobject type="Java" class="microsoft.exchange.webservices.data.core.ExchangeService" name="service">
<cfset service.init()>

<!--- 2. Set the credentials --->
<!--- 2a. Create an instance of the WebCredentials class --->
<cfobject type="Java" class="microsoft.exchange.webservices.data.credential.WebCredentials" name="credentials">
<cfset credentials.init("#variables.userName#","#variables.password#", "#variables.domainServer#")>			<!--- 2b. Set the credentials --->
<cfset service.setCredentials(credentials) />																<!--- 2c. Set the credentials in the service object --->

<!--- 3.  Set the URL to Exchange (stay away from autodsicovery) --->
<cfif variables.mailSSL>
	<cfset variables.exchangeURL = "https://#mailServer#/ews/Exchange.asmx" />
<cfelse>
	<cfset variables.exchangeURL = "http://#mailServer#/ews/Exchange.asmx" />
</cfif>
<cfobject type="Java" class="java.net.URI" name="uri">									<!--- 3a. Create an instance of the uri class --->
<cfset uri.init(variables.exchangeURL) />												<!--- 3b. Set the full path --->
<cfset service.setUrl(uri) />															<!--- 3c. Set the url in the service object --->

<!--- Create a instance of the EmailMessage class to assign each mail to it --->
<cfobject type="Java" action="create" class="microsoft.exchange.webservices.data.core.service.item.EmailMessage" name="message">
<cfset message = message.init(service) />								<!--- Initiate the EmailMessage instance to the service object --->

<!--- Create a instance of the MessageBody class to send invalid pin message --->
<cfobject type="Java" class="microsoft.exchange.webservices.data.property.complex.MessageBody" name="invalidPinMsgBody">
<cfset invalidPinMsgBody.init("You entered an invalid pin. Please enter the correct pin")>	<!--- Build Message content for pin failure --->

<cfobject type="Java" class="microsoft.exchange.webservices.data.core.enumeration.property.WellKnownFolderName" name="wkfn">
<cfobject type="Java" class="microsoft.exchange.webservices.data.core.enumeration.service.ConflictResolutionMode" name="conflictMode">
<cfobject type="Java" class="microsoft.exchange.webservices.data.core.enumeration.service.DeleteMode" name="deleteMode">
<cfobject type="Java" class="microsoft.exchange.webservices.data.core.PropertySet" name="propertySet">
<cfobject type="Java" class="microsoft.exchange.webservices.data.property.complex.EmailAddress" name="emailAddress">
<cfobject type="Java" class="microsoft.exchange.webservices.data.property.complex.FolderId" name="folders">
<cfobject type="Java" class="microsoft.exchange.webservices.data.property.complex.Mailbox" name="mailBox">
<cfobject type="Java" class="microsoft.exchange.webservices.data.search.filter.SearchFilter" name="searchFilter">
<cfobject type="Java" class="microsoft.exchange.webservices.data.search.FolderView" name="folderView">
<cfobject type="Java" class="microsoft.exchange.webservices.data.search.ItemView" name="itemView">

<!--- ********** end: java objects for exchange 2010 support ********** --->

<!--- Begin: Java EWS API --->
<!--- Folder Structure is as follows: RootFolder > Folders > [Client] --->
<cfset rootfolder =  folders.init(wkfn.MsgFolderRoot) />					<!--- Get an instance of the root folder --->
<cfset viewFolders = service.findFolders(rootfolder, folderView.init(50) ) />
<cfset variables.parentFolder = "" />

<!--- Get the list of folders from the root folder  --->
<cfloop array="#viewFolders.getFolders()#" index="xFolder">
	<cfif xFolder.getDisplayName() eq listFirst(variables.mailFolder, '/')>
		<cfset variables.parentFolder = xFolder.getDisplayName() & '/' />
		<cfset viewSubFolders = xFolder.findFolders(folderView.init(xFolder.getChildFolderCount())) />
	</cfif>
</cfloop>
<!--- End: Java EWS API --->


<cfif form.state>

	<cfparam name="form.pin_min_length"              default="4">
	<!--- program --->
	<cfparam name="form.email_out_job_time"          default="">
	<cfparam name="form.email_out_job_success"       default="">
	<cfparam name="form.email_in_job_interval"       default="3">
	<cfparam name="form.email_in_job_success"        default="">
	<cfparam name="form.email_approval_instructions" default="">

	<!--- billback --->
	<cfparam name="form.bb_email_out_job_time"          default="">
	<cfparam name="form.bb_email_out_job_success"       default="">
	<cfparam name="form.bb_email_in_job_interval"       default="3">
	<cfparam name="form.bb_email_in_job_success"        default="">
	<cfparam name="form.bb_email_approval_instructions" default="">

	<!--- get Program Auto Approver Settings --->
	<cfparam name="form.autoApproveEmail" 	default="#variables.autoApproveEmail#" />
	<cfparam name="form.mailFolder"			default="#variables.mailFolder#" />
	<cfparam name="form.mailServer"			default="#variables.mailServer#" />
	<cfparam name="form.domainServer"		default="#variables.domainServer#" />
	<cfparam name="form.userName" 			default="#variables.userName#" />
	<cfparam name="form.password" 			default="#variables.password#" />

	<cfset appSettings = genSettingsManager.get(2)>
	<cfset appSettings.setPinMinLength(form.pin_min_length) />

	<!--- program job settings --->
	<cfset appSettings.setEmailOutJobTime(form.email_out_job_time) />
	<cfset appSettings.setEmailOutJobSuccess(form.email_out_job_success) />
	<cfset appSettings.setEmailInJobInterval(form.email_in_job_interval) />
	<cfset appSettings.setEmailInJobSuccess(form.email_in_job_success) />
	<cfset appSettings.setEmailApprovalInstructions(form.email_approval_instructions) />


	<!--- billback job settings
	These will be auto saved from form scope into _settings --->

	<cfset appSettings.setUpdatedBy(request.AccessStructure.User_ID)>
	<cfset genSettingsManager.save(15)>

	<!--- set the Auto Approver Settings; encryprt the password before save --->
	<cf_cryp string="#form.password#" type="en" key="#variables.cryp_key#">
	<cfparam name="cryp.value" 	default=""/>
	<cfset application.oEmailApprovalManager.setAutoApproverSettings(form.userName, cryp.value, form.mailServer, form.domainServer, form.mailFolder, form.autoApproveEmail, form.bbAutoApproveEmail) />

	<cfset HTTPVariable = "http:">
	<cfif Application.oApplicationAppSettingsManager.getApplicationAppSettings().getSSL_On_All_Pages() >
		<cfset HTTPVariable = "https:">
	</cfif>

	<!--- D57544: Invalid extension of the file name. Valid extensions are : log,txt. --->
	<cfif appSettings.getApprovalViaEmail()>
		<cfschedule action = "update"
			task = "#application.returned_customer_setting.Company_Name# - Prg Approval via Email - Send Email"
			operation = "HTTPRequest"
			url = "#HTTPVariable#//#HTTP_HOST#/Scheduled/ApprovalViaEmailSendEmail.cfm"
			startDate = "#DateFormat(Now(),"mm/dd/yyyy")#"
			startTime = "#TimeFormat(appSettings.getEmailOutJobTime(), "short")#"
			interval = "Daily"
			resolveURL = "Yes"
			publish = "Yes"
			path = "#expandPath('/Scheduled/')#"
			file = "ApprovalViaEmailSendEmail.log" <!--- D57544 --->
			requestTimeOut = "600">

		<cfschedule action = "update"
			task = "#application.returned_customer_setting.Company_Name# - Prg Approval via Email - Read Email"
			operation = "HTTPRequest"
			url = "#HTTPVariable#//#HTTP_HOST#/Scheduled/ApprovalViaEmailReadEmail.cfm"
			startDate = "#DateFormat(Now(),"mm/dd/yyyy")#"
			startTime = "12:00 AM"
			interval = "#val(appSettings.getEmailInJobInterval()*3600)#"
			resolveURL = "Yes"
			publish = "Yes"
			path = "#expandPath('/Scheduled/')#"
			file = "ApprovalViaEmailReadEmail.log"	<!--- D57544 --->
			requestTimeOut = "600">
	</cfif>

	<cfif appSettings.get_Setting('BB_Approval_Via_Email') >
		<cfschedule action = "update"
			task = "#application.returned_customer_setting.Company_Name# - BB Approval via Email - Send Email"
			operation = "HTTPRequest"
			url = "#HTTPVariable#//#HTTP_HOST#/Scheduled/BBApprovalViaEmailSendEmail.cfm"
			startDate = "#DateFormat(Now(),"mm/dd/yyyy")#"
			startTime = "#TimeFormat(appSettings.get_Setting('BB_Email_Out_Job_Time'), "short")#"
			interval = "Daily"
			resolveURL = "Yes"
			publish = "Yes"
			path = "#expandPath('/Scheduled/')#"
			file = "BBApprovalViaEmailSendEmail.log" <!--- D57544 --->
			requestTimeOut = "600">

		<cfschedule action = "update"
			task = "#application.returned_customer_setting.Company_Name# - BB Approval via Email - Read Email"
			operation = "HTTPRequest"
			url = "#HTTPVariable#//#HTTP_HOST#/Scheduled/BBApprovalViaEmailReadEmail.cfm"
			startDate = "#DateFormat(Now(),"mm/dd/yyyy")#"
			startTime = "12:00 AM"
			interval = "#val(appSettings.get_Setting('BB_Email_In_Job_Interval')*3600)#"
			resolveURL = "Yes"
			publish = "Yes"
			path = "#expandPath('/Scheduled/')#"
			file = "BBApprovalViaEmailReadEmail.log"	<!--- D57544 --->
			requestTimeOut = "600">
	</cfif>
	<cflocation addtoken="No" url="#thisPage#">
	<cfabort>
</cfif>

<cfset appSettings = genSettingsManager.get(1, 15, 1)>

<style>
	.appSettingsInput
	{
		text-align:right;
		width:50px;
	}
	.appSettingsInputLong
	{
		text-align:left;
		width:450px;
	}
</style>

<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/string_validations.js"></SCRIPT>
<script language="JavaScript">

	function validateAndSubmit(thisForm)
	{
		ErrorCount = 0
		//	[A-Z0-9._]+@[A-Z0-9.-]+\.[A-Z]{2,4}	- Email Validation
		var pin_min_length = <cfoutput>#appSettings.getPinMinLength()#</cfoutput>
		if (document.all.pin_min_length.value < pin_min_length || document.all.pin_min_length.value > 9 || document.all.pin_min_length.length < 0)
		{
			ErrorCount++;
			queueMessage("Minimum length for pin must be atleast " + pin_min_length + " or more", document.all.err_sp_pinMinLength);
		}
		else
		{
			clearQueue(document.all.error_err_sp_pinMinLength);
		}

		if(ErrorCount == 0)
		{
				submitForm(thisForm, "ApprovalViaEmail");
		}
		else
		{
			showMessageWindow()
		}

	}
</script>
<br>
<cfif Len(appSettings.getUpdatedBy()) GT 0>
	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
		<TR>
			<TD>
				<FONT SIZE="2"><B>The settings were last updated on #dateformat(appSettings.getUpdatedOn(), 'mm/dd/yyyy')# #timeformat(appSettings.getUpdatedOn(), 'hh:mm:ss TT')# by #appSettings.getUpdatedByUserName()#</B></FONT>	</TD>
			</TD>
		</TR>
	</TABLE>
	<br>
</cfif>
<table cellpadding="2" cellspacing="0" border="0">
	<tr>
		<td>Minimum Length for Pin:</td>
		<td><span id="err_sp_pin_min_length">&nbsp;&nbsp;</span></td>
		<td align="left"><input maxlength="1" onkeypress="return Allow_Key_List('0123456789');" onblur="javaScript: makeValidIntFloat(this, 1, '0');" class="appSettingsInput" type="Text" name="pin_min_length" value="#appSettings.getPinMinLength()#"> (default 4)</td>
	</tr>

	<!--- Program Remote Approval Settings ----------------------------------------------------------------------------------------- --->
	<cfif appSettings.getApprovalViaEmail()>
		<cfset renderDivider("Program")>
		<tr>
			<td>Schedule - Send email job daily at:</td>
			<td><span id="err_sp_email_out_job_time">&nbsp;&nbsp;</span></td>
			<td align="left"><input maxlength="8"  onkeypress="return Allow_Key_List('0123456789:am pm');" class="appSettingsInput" type="Text" name="email_out_job_time" value="#appSettings.getEmailOutJobTime()#"> (hh:mm am/pm)</td>
		</tr>
		<tr>
			<td>Email - Send email job success to:</td>
			<td><span id="err_sp_email_out_job_success">&nbsp;&nbsp;</span></td>
			<td align="left"><input class="appSettingsInputLong" type="Text" name="email_out_job_success" value="#appSettings.getEmailOutJobSuccess()#"></td>
		</tr>
		<tr>
			<td>Schedule - Read incoming email job daily every:</td>
			<td><span id="err_sp_email_in_job_interval">&nbsp;&nbsp;</span></td>
			<td align="left"><input maxlength="8"  onkeypress="return Allow_Key_List('0123456789');" onblur="javaScript: makeValidIntFloat(this, 1, '0');"  class="appSettingsInput" type="Text" name="email_in_job_interval" value="#appSettings.getEmailInJobInterval()#"> hours</td>
		</tr>
		<tr>
			<td>Email - Read incoming email job success to:</td>
			<td><span id="err_sp_email_in_job_success">&nbsp;&nbsp;</span></td>
			<td align="left"><input class="appSettingsInputLong" type="Text" name="email_in_job_success" value="#appSettings.getEmailInJobSuccess()#"></td>
		</tr>
		<tr>
			<td>Instructions for Approving Programs via Email:</td>
			<td><span id="err_sp_email_approval_instructions">&nbsp;&nbsp;</span></td>
			<td align="left"><textarea name="email_approval_instructions" cols="120" rows="5" class="appSettingsInputLong">#appSettings.getEmailApprovalInstructions()#</textarea></td>
		</tr>
	</cfif>
	<!--- BB Remote Approval Settings ----------------------------------------------------------------------------------------- --->
	<cfif appSettings.get_Setting('BB_Approval_Via_Email') >
		<cfset renderDivider("Billback")>
		<tr>
			<td>Schedule - Send email job daily at:</td>
			<td><span id="err_sp_bb_email_out_job_time">&nbsp;&nbsp;</span></td>
			<td align="left"><input maxlength="8"  onkeypress="return Allow_Key_List('0123456789:am pm');" class="appSettingsInput" type="Text" name="bb_email_out_job_time" value="#appSettings.get_Setting('BB_email_out_job_time')#"> (hh:mm am/pm)</td>
		</tr>
		<tr>
			<td>Email - Send email job success to:</td>
			<td><span id="err_sp_bb_email_out_job_success">&nbsp;&nbsp;</span></td>
			<td align="left"><input class="appSettingsInputLong" type="Text" name="bb_email_out_job_success" value="#appSettings.get_Setting('BB_Email_Out_Job_Success')#"></td>
		</tr>
		<tr>
			<td>Schedule - Read incoming email job daily every:</td>
			<td><span id="err_sp_bb_email_in_job_interval">&nbsp;&nbsp;</span></td>
			<td align="left"><input maxlength="8"  onkeypress="return Allow_Key_List('0123456789');" onblur="javaScript: makeValidIntFloat(this, 1, '0');"  class="appSettingsInput" type="Text" name="bb_email_in_job_interval" value="#appSettings.get_Setting('BB_Email_In_Job_Interval')#"> hours</td>
		</tr>
		<tr>
			<td>Email - Read incoming email job success to:</td>
			<td><span id="err_sp_bb_email_in_job_success">&nbsp;&nbsp;</span></td>
			<td align="left"><input class="appSettingsInputLong" type="Text" name="bb_email_in_job_success" value="#appSettings.get_Setting('BB_Email_In_Job_Success')#"></td>
		</tr>
		<tr>
			<td>Instructions for Approving Billbacks via Email:</td>
			<td><span id="err_sp_bb_Email_Approval_Instructions">&nbsp;&nbsp;</span></td>
			<td align="left"><textarea name="bb_Email_Approval_Instructions" cols="120" rows="5" class="appSettingsInputLong">#appSettings.get_Setting('BB_Email_Approval_Instructions')#</textarea></td>
		</tr>
	</cfif>

	<!--- Settings ----------------------------------------------------------------------------------------- --->
	<cfset renderDivider("Settings")>
	<tr>
		<td>Auto Approve - Program - Email Address</td>
		<td><span id="err_sp_autoApproveEmail">&nbsp;&nbsp;</span></td>
		<td align="left"><input class="appSettingsInputLong" type="Text" name="autoApproveEmail" value="#variables.autoApproveEmail#"></td>
	</tr>
	<tr>
		<td>Auto Approve - Billback - Email Address</td>
		<td><span id="err_sp_bbAutoApproveEmail">&nbsp;&nbsp;</span></td>
		<td align="left"><input class="appSettingsInputLong" type="Text" name="BbAutoApproveEmail" value="#variables.bbAutoApproveEmail#"></td>
	</tr>
	<tr>
		<td>Auto Approve - Folder for this client:</td>
		<td><span id="err_sp_mailFolder">&nbsp;&nbsp;</span></td>
		<td align="left">
			<select name="mailFolder">
				<option value=""/></option>
				<!--- Loop over the list of child folders and get the client folder  --->
				<cfloop array="#viewSubFolders.getFolders()#" index="xSubFolder">
					<option value="#variables.parentFolder##xSubFolder.getDisplayName()#" <cfif xSubFolder.getDisplayName() eq  listLast(variables.mailFolder, '/')>selected</cfif>>#xSubFolder.getDisplayName()#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td>Auto Approve - Account Mail Server</td>
		<td><span id="err_sp_mailServer">&nbsp;&nbsp;</span></td>
		<td align="left"><input class="appSettingsInputLong" type="Text" name="mailServer" value="#variables.mailServer#"></td>
	</tr>
	<tr>
		<td>Auto Approve - Account Domain (FQDN)</td>
		<td><span id="err_sp_domainServer">&nbsp;&nbsp;</span></td>
		<td align="left"><input class="appSettingsInputLong" type="Text" name="domainServer" value="#variables.domainServer#"></td>
	</tr>
	<tr>
		<td>Auto Approve - User Name:</td>
		<td><span id="err_sp_userName">&nbsp;&nbsp;</span></td>
		<td align="left"><input class="appSettingsInputLong" type="Text" name="userName" value="#variables.userName#"></td>
	</tr>
	<tr>
		<td>Auto Approver - User Password:</td>
		<td><span id="err_sp_password">&nbsp;&nbsp;</span></td>
		<td align="left"><input class="appSettingsInputLong" type="password" name="password" value="#variables.password#"></td>
	</tr>

</table>

<br><br>
<div align="center">
	<CF_button
			button_name		=	""
			button_caption	=	"Save"
			button_action	=	"validateAndSubmit(document.#formName#);"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"Save"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
</div>
</cfoutput>
<!------------------------------------------------------------------------------------------------------------>
<cffunction name="renderDivider" hint="Render section header with a title and section footer (without a title)">
	<cfargument name="title" required="false" default="" hint="do not pass anything to render a section footer">

	<tr class="divider">
		<td colspan="3">
			<hr class="six">
			<cfoutput>#arguments.title#</cfoutput>
			<hr class="four">
		</td>
	</tr>
</cffunction>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
