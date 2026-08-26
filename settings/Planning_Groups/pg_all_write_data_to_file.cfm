<!---------------------------------------------------------------------------------------------------------------------
Template: \settings\planning_groups\pg_all_write_data_to_file.cfm
Date:     Oct 15th, 2012
Author:   Milan
Purpose:  If there are associated budgets,volumes,programs or templates for the planning group, then do not allow the user to delete the planning group.
	  Write the planning group details to an excel file.
Parameters: planningGroupType: 1 = product, 2 = Distributor and 3 = Operator
----------------------------------------------------------------------------------------------------------------------->

<!--- ***(START)**** CODE FOR PRODUCTS AND DISTRIBUTORS.NOT FOR OPERATORS --->

<!---*****PROGRAMS*****--->
<!--- get programs for a planning group --->
<cfset qryProgramsForPlanningGroup  = PGManager.getProgramsForPlanningGroup(planningGroupType,id)>

<!---*****TEMPLATES*****--->
<!--- get templates for a planning group --->

<cfset qryTemplatesForPlanningGroup  = PGManager.getTemplatesForPlanningGroup(planningGroupType,id)>
<!--- ***(END)**** CODE FOR PRODUCTS AND DISTRIBUTORS.NOT FOR OPERATORS --->


<!--- ***(START)**** CODE FOR PRODUCTS, DISTRIBUTORS AND OPERATORS --->

<!--- For non-operator (products and distributors) planning groups
Note: Budgets and Volume do not exist for operators (planningGroupType = 3)
--->
<cfif planningGroupType neq 3>
	<!---*****BUDGETS*****--->
	<!--- get existing budgets for a planning group --->
	<cfset qryBudgetsForPlanningGroup  = PGManager.getBudgetsForPlanningGroup(planningGroupType,id)>
	
	<!---*****VOLUME PLANS(FORECAST)*****--->
	<!--- get volume plan (forecast) for a planning group --->
	<cfset qryVolumePlansForPlanningGroup  = PGManager.getVolumePlansForPlanningGroup(planningGroupType,id)>
	
	<!--- If any programs and/or templates and/or budgets and/or volume plans (forecast) exist for the planning group --->
	<cfif qryProgramsForPlanningGroup.recordcount GT 0 
		OR qryTemplatesForPlanningGroup.recordcount GT 0 
		OR qryBudgetsForPlanningGroup.recordcount GT 0 
		OR qryVolumePlansForPlanningGroup.recordcount GT 0>

		<cfset NodeletePG = 1>
	</cfif>	

<!--- For operator planning group --->
<cfelse>
	<!--- If any programs and/or templates exist for the planning group --->
	<cfif qryProgramsForPlanningGroup.recordcount GT 0 OR qryTemplatesForPlanningGroup.recordcount GT 0>
		<cfset NodeletePG = 1>
	</cfif>	

</cfif>
<!--- ***(END)**** CODE FOR PRODUCTS, DISTRIBUTORS AND OPERATORS --->

<!--- errorNumber is to output the error sequence number: 1,2,3 etc --->
<cfset errorNumber = 0>

<!--- Error message for associated members. --->
<cfif Evaluate("#QryPGCategoryDefinitionByID#.RecordCount") GT 0>
	<cfset errorNumber = errorNumber + 1>
	<cfset NoDeleteReasonListForPG = NoDeleteReasonListForPG & "<br>" & "#errorNumber#:  Members are associated with it">
</cfif>


<!--- File details to download for the planning groups.
Note: The Excel file does not have any group member details. It is only for planning groups with existing budget, volume forecast, programs and templates.
--->
<cfset file_name = "planningGroups_#entityType#_#DateFormat(now(),'mmddyyyy')#_#TimeFormat(now(),'hhmmss')#.xls">
<cfset file_path = "#Application.Doc_Path#\Temp_Files\Documents\Temp_Uploaded_Doc\#file_name#">


<!--- ***(START)**** CODE FOR PRODUCTS AND DISTRIBUTORS.NOT FOR OPERATORS --->

<!--- For non-operator planning groups: Budgets and Volume do not exist for operators (planningGroupType = 3). It is for products and distributors  --->
<cfif planningGroupType neq 3>
	<!--- If budgets exist for the planning group --->
	<cfif qryBudgetsForPlanningGroup.RecordCount GT 0>
		<cfset errorNumber = errorNumber + 1>
		<cfset NoDeleteReasonListForPG = NoDeleteReasonListForPG & "<br>" & "#errorNumber#:  It is associated with one or more budgets">

		<cfset fileExistStatus = 1>
		
		<!--- write the excel file which has the details --->
		<cfspreadsheet  
		    action="write" 
		    filename = "#file_path#"
		    query = "qryBudgetsForPlanningGroup" 
		    sheetname = "budgets">
	</cfif>

	<!--- If the file already exists, then update the file with volume plan (forecast) details in a new tab, else write the file --->
	<cfif fileExistStatus eq 1>
		<cfset fileAction = "update">
	<cfelse>
		<cfset fileAction = "write">
	</cfif>

	<!--- If volume plans (forecast) exist for the planning group --->
	<cfif qryVolumePlansForPlanningGroup.RecordCount GT 0>
		<cfset errorNumber = errorNumber + 1>
		<cfset NoDeleteReasonListForPG = NoDeleteReasonListForPG & "<br>" & "#errorNumber#:  It is associated with one or more volume plans">
		
		<!--- write the excel file which has the details --->
		<cfspreadsheet  
		    action="#fileAction#" 
		    filename = "#file_path#" 
		    query = "qryVolumePlansForPlanningGroup" 
		    sheetname = "volume plans">
		    
		    <cfset fileExistStatus = 1>
	</cfif>
</cfif>

<!--- ***(END)**** CODE FOR PRODUCTS AND DISTRIBUTORS.NOT FOR OPERATORS --->

	<!--- If the file already exists, then update the file with program details in a new tab, else write the file --->
	<cfif fileExistStatus eq 1>
		<cfset fileAction = "update">
	<cfelse>
		<cfset fileAction = "write">
	</cfif>


<!--- ***(START)****CODE FOR PRODUCTS, DISTRIBUTORS AND OPERATORS --->

<!--- If programs exist for the planning group --->
<cfif qryProgramsForPlanningGroup.RecordCount GT 0>
	<cfset errorNumber = errorNumber + 1>
	<cfset NoDeleteReasonListForPG = NoDeleteReasonListForPG & "<br>" & "#errorNumber#:  It is associated with one or more programs">

	<cfset fileExistStatus = 1>
	
	<!--- write the excel file which has the details --->
	<cfspreadsheet  
	    action="#fileAction#" 
	    filename = "#file_path#" 
	    query = "qryProgramsForPlanningGroup" 
	    sheetname = "programs">
</cfif>

	<!--- If the file already exists, then update the file with template details in a new tab, else write the file --->
	<cfif fileExistStatus eq 1>
		<cfset fileAction = "update">
	<cfelse>
		<cfset fileAction = "write">
	</cfif>

<!--- If templates exist for the planning group --->
<cfif qryTemplatesForPlanningGroup.RecordCount GT 0>
	<cfset errorNumber = errorNumber + 1>
	<cfset NoDeleteReasonListForPG = NoDeleteReasonListForPG & "<br>" & "#errorNumber#:  It is associated with one or more templates">

	<cfset fileExistStatus = 1>
	
	<!--- write the excel file which has the details --->
	<cfspreadsheet  
	    action="#fileAction#" 
	    filename = "#file_path#" 
	    query = "qryTemplatesForPlanningGroup" 
	    sheetname = "templates">
</cfif>
<!--- ***(END)****CODE FOR PRODUCTS, DISTRIBUTORS AND OPERATORS --->