
<cfif isDefined("Auto_Checkbook_ID")>

	<cfquery name="UpdateAutoCheckbooks" datasource="#application.datasource#">
	UPDATE Auto_Checkbook
	SET Deleted = 1
	WHERE Auto_Checkbook_ID = '#Auto_Checkbook_ID#'
	</cfquery>

</cfif>

<cflocation url="/billbacks/ledger/auto_checkbook/index.cfm">