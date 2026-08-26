<!---      
       Name:          BudgetSettingsManager.cfc               
       Copyright:     Copyright (c) 2006 Blacksmith Applications, Inc.       
       Created Date:  05/23/2006
       Created By:    Clarence Morse
       Description:   Budget Settings Manager
--->

<cfcomponent displayname="BudgetSettingsManager" hint="Budget Settings Manager">
	<!--- Get Control Panel Settings Defaults & Control Levels --->
		<cfinclude template="budgetSettingsManager/getsettings.cfm">	

	<!--- Set Control Panel Settings Defaults & Control Levels --->	
		<cfinclude template="budgetSettingsManager/setsettings.cfm">
	
	<!--- Get Max Control Panel Control Levels --->
		<cfinclude template="budgetSettingsManager/getcontrollevels.cfm">
		
	<!--- Get Budget Category Ids --->
		<cfinclude template="budgetSettingsManager/getcategoryid.cfm">	
	
	<!--- Volume UOM Get & Update --->
		<cfinclude template="budgetSettingsManager/getvolumeuom.cfm">
		<cfinclude template="budgetSettingsManager/updatevolumeuom.cfm">	
	
	<!--- Budget Master Data Functions --->
		<cfinclude template="budgetSettingsManager/getbudgetmasterdata.cfm">	
		<cfinclude template="budgetSettingsManager/getactivebudgetmasterdata.cfm">
		<cfinclude template="budgetSettingsManager/updategroups.cfm">
	
	<!--- Budget Allocation Types Functions --->
		<cfinclude template="budgetSettingsManager/getallocationtypes.cfm">
		<cfinclude template="budgetSettingsManager/updateallocationtypes.cfm">	
		<cfinclude template="budgetSettingsManager/getActiveAllocationTypes.cfm">
	
	<!--- Budget General Settings --->
		<cfinclude template="budgetSettingsManager/getBudgetSettings.cfm">
		
</cfcomponent>