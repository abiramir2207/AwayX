<!---
	FILENAME: 	program_alert_action.cfm
	Copyright 	(c) 2008 Blacksmith Applications, Inc.
	CREATED: 	Tim Ford
--->

<cfset variables.oProgramAlertManager = createObject("component", "components.settings.ProgramAlerts.ProgramAlertManager") />

<cfoutput>

	<!--- Remove all Program Alerts --->
	<cfset variables.oProgramAlertManager.deleteProgramAlertTemplate() />
	
	<cfloop from="1" to="#ListLen(form.Distributor_Operator)#" index="indxDistOpTemp">
	
		<cfset variables.distributorOperator	= 	ListGetAt(form.Distributor_Operator,indxDistOpTemp) />
		<cfset variables.distributorTemplate 	= 	ListFirst(trim(variables.distributorOperator), "_") />
		<cfset variables.operatorTemplate 		= 	ListLast(trim(variables.distributorOperator), "_") />
		
		<!--- Add a Program Alert for each --->
		<cfset variables.oProgramAlertManager.addProgramAlertTemplate(variables.distributorTemplate, variables.operatorTemplate) />

	</cfloop>

	<!--- Remove all Program Status Alerts --->
	<cfset variables.oProgramAlertManager.deleteProgramAlertStatus() />
	
	<cfloop from="1" to="#ListLen(form.Contract_Status_Type_ID)#" index="indxStatusTemp">
	
		<cfset variables.alertStatus = ListGetAt(form.Contract_Status_Type_ID,indxStatusTemp) />
		
		<!--- Add a Program Status Alert for each --->
		<cfset variables.oProgramAlertManager.addProgramAlertStatus(variables.alertStatus) />

	</cfloop>
	
	<cfset variables.oProgramAlertManager.addProgramAlertReminder(form.reminder) />
		
</cfoutput>

<cflocation url="index.cfm" />