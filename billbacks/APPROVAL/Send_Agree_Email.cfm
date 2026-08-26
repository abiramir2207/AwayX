<!---
Document		:	/Billbacks/approval/Send_Agree_Email.cfm
Author			:	Deepa Kunnath
Date Created	:	Nov 08, 2004
Purpose			:	TO send mail to CRA (currently responsible for approval) if applicable
Arguments		:	AgreeEmailBillbackId, AgreeEmailUserId, BillbackManager
Called from		: 
					/Billbacks/approval/payment_confirmation.cfm					
--->

<cfif NOT isDefined("appSettings")>
	<cfset appSettings = CreateObject("component", "components.settings.ApplicationSettingsManager").get() />
</cfif>
<cfif NOT isDefined("BillbackManager")>
	<cfset BillbackManager = CreateObject("component", "components.billback.BillbackManager").init() />
</cfif>

<cfif appSettings.getBBAgreeEmail()>
	<cfif BillbackManager.sendEmailtoNextCRA(AgreeEmailBillbackId, AgreeEmailUserId)>
		<cfset LocationFrom = "UponAgree">
		<cfset Billback_ID = AgreeEmailBillbackId>
		<cfinclude template="/ANYTHING_AUTOMATED/EMAIL/rfa_billback_emailer.cfm">
		<cfparam name="didWeSendEmail" 	default="0">
		<cfif didWeSendEmail><!------ Set the sent email bit ----->
			<cfset BillbackManager.setSentEmailtoNextCRA(AgreeEmailBillbackId, AgreeEmailUserId) />
		</cfif>
	</cfif>	
</cfif>