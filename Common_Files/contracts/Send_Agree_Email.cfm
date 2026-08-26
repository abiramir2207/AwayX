<!---
Document		:	/Common_Files/contracts/Send_Agree_Email.cfm
Author			:	Deepa Kunnath
Date Created	:	Nov 03, 2004
Purpose			:	TO send mail eo CRA (currently responsible for approval) if applicable
Arguments		:	AgreeEmailProgramId, AgreeEmailUserId, realProgramManager
Called from		: 
					/Common_Files/contracts/program_agree_action.cfm
					/Common_Files/contracts/contract_layered_approve_action.cfm
					/Scorecard/massapproval.cfm
--->

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfif appSettings.getRFAEmailEvent() EQ 2 OR appSettings.getRFAEmailEvent() EQ 3><!------ 2=At Agree, send only to CRA (currently responsible for approval) users ----->
	<cfif realProgramManager.sendEmailtoNextCRA(AgreeEmailProgramId, AgreeEmailUserId)>
		<cfset LocationFrom = "UponAgree">
		<cfset Contract_Main_ID = AgreeEmailProgramId>
		<cfinclude template="/ANYTHING_AUTOMATED/EMAIL/rfa_program_emailer.cfm">
		<cfparam name="didWeSendEmail" 	default="0">
		<cfif didWeSendEmail><!------ Set the sent email bit ----->
			<cfset realProgramManager.setSentEmailtoNextCRA(AgreeEmailProgramId, AgreeEmailUserId) />
		</cfif>
	</cfif>	
</cfif>	