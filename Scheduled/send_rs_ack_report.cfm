<!---
Script: Send_RS_ACK_Notification.cfm
Date:	1/18/2007
Author:	Clarence Morse
Label:	11286
Description: This is a report of all acknowledgement of released programs (1,2) for the current day.
			 This report is forwarded either to the application contact or the user defined in the
			 notifications control panel.
--->


<cfif NOT isDefined("appSettings")>
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>
</cfif>



<!--- Check whether the process has executed before and if so Stop --->

<cfif isdefined("application.release_settlement_sent") EQ FALSE>
	<cfset application.release_settlement_sent = '#dateformat(now(),'mm/dd/yyyy')#' />
<cfelse>
	<cfif application.release_settlement_sent EQ '#dateformat(now(),'mm/dd/yyyy')#'>
		<p>Report Already Sent</p>
		<cfabort>
	<cfelse>
		<cfset application.release_settlement_sent = '#dateformat(now(),'mm/dd/yyyy')#' />
	</cfif>
</cfif>



<cfinclude template="/get_Contact_Admin_Email_Address.cfm" />


<!--- Get Count of Acknowledged Records --->
<cfif appSettings.getReleaseSettlement()>
<!--- SEND EMAIL TO ALERT USERS of status change --->
<cfquery name="getGSettings" datasource="#application.datasource#">
	SELECT count(contract_main_id) AS "count"
	FROM contract_main
	LEFT JOIN _users ON
	contract_main.released_by = _users.user_id
	WHERE released_ack_date IS NOT NULL
			AND released > 0
			AND datediff(day,released_ack_date,getdate()) = 1
</cfquery>

<cfparam name="LocationFrom" default="Auto">

<cfif getGSettings.Count EQ 0>
	<cfabort>
</cfif>
<cfset reportRecipient = appSettings.getSend_Release_Settlement_Emailaddress() />

<cfif len(reportRecipient) EQ 0>
	<cfset reportRecipient = Contact_Admin_Email_Address />
</cfif>

				<cfsavecontent variable="adminReport">
					<cfinclude template="/templates/email/rs_acknowledgement_admin_report.cfm" />
				</cfsavecontent>

						<CF_EMAILWRAPPER
							TO			=	"#reportRecipient#"
							FROM		=	"#Contact_Admin_Email_Address#"
							SUBJECT		=	"Release Settlement Acknowledgement Notification"
							TYPE		=	"html"
							messagetype =	"1"
							generatedby =	"2"
							appArea     =	"1">
						<cfoutput>#adminReport#</cfoutput>
						</CF_EMAILWRAPPER>
				<p>Report Sent</p>
</cfif>
