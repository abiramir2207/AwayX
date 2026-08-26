<!---
Script: Send_RS_ACK_Notification.cfm
Date:	1/18/2007
Author:	Clarence Morse
Label:	11286
Description: This page will notify the released_by user that that their program has been released.
			 Auto-Released Programs (contract_main.released = 2) are excluded from this notification.
			 They are forwarded by send_rs_ack_report.cfm which is forwarded to the either the system contact
			 or the defined user in the Notifications control panel.
--->



<cfif NOT isDefined("appSettings")>
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>
</cfif>


<!--- Check whether the process has executed before and if so Stop --->

<cfif isdefined("application.release_settlement_user_sent") EQ FALSE>
	<cfset application.release_settlement_user_sent = '#dateformat(now(),'mm/dd/yyyy')#' />
<cfelse>
	<cfif application.release_settlement_user_sent EQ '#dateformat(now(),'mm/dd/yyyy')#'>
		<p>Report Already Sent</p>
		<cfabort>
	<cfelse>
		<cfset application.release_settlement_user_sent = '#dateformat(now(),'mm/dd/yyyy')#' />
	</cfif>
</cfif>

<cfinclude template="/get_Contact_Admin_Email_Address.cfm" />



<cfif appSettings.getReleaseSettlement()>
<!--- SEND EMAIL TO ALERT USERS of status change --->
<cfquery name="getGSettings" datasource="#application.datasource#">
	SELECT distinct released_by, user_email
	FROM contract_main
	LEFT JOIN _users ON
	contract_main.released_by = _users.user_id
	where datediff(day,released_ack_date,getdate())  = 1
	AND released_by IS NOT NULL
</cfquery>

<cfparam name="LocationFrom" default="Auto">

<cfif getGSettings.RecordCount EQ 0>
	<cfabort>
</cfif>

<cfloop query="getGSettings">
			<cfset AlreadySentTo = "">
			<cfset userid = getGSettings.released_by />

			<cfsavecontent variable="userReport">
				<cfinclude template="/templates/email/rs_acknowledgement_user_report.cfm" />
			</cfsavecontent>

 				<cfif ListContains(AlreadySentTo,getGSettings.Released_By) IS False>
					<cfset AlreadySentTo = listappend(AlreadySentTo,getGSettings.Released_By)>

					<CF_EMAILWRAPPER
						TO			=	"#getGSettings.user_email#"
						FROM		=	"#Contact_Admin_Email_Address#"
						SUBJECT		=	"Release Settlement Acknowledgement Notification"
						TYPE		=	"html"
						messagetype =	"1"
						generatedby =	"2"
						appArea     =	"1">
					<cfoutput>#userReport#</cfoutput>
					</CF_EMAILWRAPPER>

				</cfif>
				<p>Report sent.</p>
	</cfloop>
</cfif>