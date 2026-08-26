<!---Operator_Auto_Claim_Process.cfm--->

<!---Just a simple call the USP_OPERATOR_AUTO_CLAIM_PROCESS stored procedure--->
<cfstoredproc procedure="USP_OPERATOR_AUTO_CLAIM_PROCESS" datasource="#application.datasource#">

</cfstoredproc>

<!--- If Auto BB setting is on, send Auto BB Email --->
<cfquery name="selAutoBBEmail" datasource="#application.datasource#">
	SELECT Send_Create_Auto_Billback_Email
	FROM _Application_Settings
</cfquery>

<cfif selAutoBBEmail.Send_Create_Auto_Billback_Email eq 1>
		<cfinclude template="/scheduled/send_create_auto_billback_email.cfm">
<cfelse>

		<cfquery name="updAutoBBEmail" datasource="#application.datasource#">
			UPDATE Billback
			SET Sent_Create_Auto_Billback_Email = 1
		</cfquery>

</cfif>

