<!---  
       Name:          BudgetAjaxManager.cfc    
       Copyright:     Copyright (c) 2007 Blacksmith Applications, Inc.       
       Created Date:  7/23/2008
       Created By:    dkunnath
       Description:   
--->
 <cfcomponent extends="components.ajaxCFC.ajax">

	<cffunction name="getBudgetClassAssociation" output="no" returntype="query">
			
		<cfset var dataArray = ArrayNew(1)>
		
		
			<cfset BudgetManager = CreateObject("component", "components.budgets.BudgetManager").init() />
			<cfreturn BudgetManager.getBudgetClassAssociation(active=1) />			
		
	</cffunction>
	
	<cffunction name="getBudgetTemplateProgramCommittedAjax" access="public" output="no" returntype="query">
		<cfargument name="templateParentID" type="numeric" required="true" />
		<cfargument name="simpleBudgetClassID" type="numeric" required="true" />
		<cfargument name="simpleBudgetID" type="numeric" required="true" />
			
		<cfset var dataArray = ArrayNew(1)>
		
			<cfset BudgetManager = CreateObject("component", "components.budgets.BudgetManager").init() />
			
			<cfreturn BudgetManager.getBudgetTemplateProgramCommitted(
						templateParentID = arguments.templateParentID, 
						simpleBudgetClassID = arguments.simpleBudgetClassID, 
						simpleBudgetID = arguments.simpleBudgetID) />
								
		
	</cffunction>
	
	<cffunction name="getBudgetTemplateBillbackActualAjax" access="public" output="no" returntype="query">
		<cfargument name="templateParentID" type="numeric" required="true" />
		<cfargument name="simpleBudgetClassID" type="numeric" required="true" />
		<cfargument name="simpleBudgetID" type="numeric" required="true" />
			
		<cfset var dataArray = ArrayNew(1)>
		
			<cfset BudgetManager = CreateObject("component", "components.budgets.BudgetManager").init() />
			
			<cfreturn BudgetManager.getBudgetTemplateBillbackActual(
						templateParentID = arguments.templateParentID, 
						simpleBudgetClassID = arguments.simpleBudgetClassID, 
						simpleBudgetID = arguments.simpleBudgetID) />
								
	</cffunction>	
	
</cfcomponent>