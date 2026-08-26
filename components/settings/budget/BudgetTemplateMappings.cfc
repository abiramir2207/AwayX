<!---  
       Name:          BudgetTemplateMapping.cfc             
       Copyright:     Copyright (c) 2006 Blacksmith Applications, Inc.       
       Created Date:  7/6/2006
       Created By:    Clarence Morse
       Description:   
--->

<cfcomponent displayname="Budget Template Mapping" hint="Budget Template Mapping Manager">

	<!--- getAllMappings--->
	<cfinclude template="budgetTemplateMappings/getAllMappings.cfm">
	
	<!--- isActive --->
	<cfinclude template="budgetTemplateMappings/isActive.cfm">
	
	<!--- lastUpdated --->
	<cfinclude template="budgetTemplateMappings/lastUpdated.cfm">
	
</cfcomponent>