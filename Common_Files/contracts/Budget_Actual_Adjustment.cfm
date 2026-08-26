<!----
	Name: Budget_Actual_Adjustment.cfm         
	Copyright (c) 2013 Blacksmith Applications, Inc.       
---->	
<cfset contractnumber =url.contractnumber>
<cfset contractMainID = url.contractID>
<cfset plannerID = url.plannerID>
<cfset form.BUDGET_ID=0>
<cfset PaymentHistory = "yes">
<cfinclude template="/settings/Advanced_Budget/listActAdjustment.cfm">

