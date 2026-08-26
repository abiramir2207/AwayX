<!---
Document		:	/settings/budgets/index.cfm
Author			:	Deepa Kunnath
Date Created	:	Jun 6, 2007
Purpose			:	Entry point for budget settings
Arguments		:	
Called from		: 
					/Settings/settings_frame_toc.cfm
					/Settings/settings_frame_mainwindow.cfm
--->
<cfsetting enablecfoutputonly="Yes">

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---///////////////////////////////////////////  Command Variables ///////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<CFPARAM NAME="url.command" DEFAULT="listBudgetClass">
<CFPARAM NAME="form.command" DEFAULT="#url.command#">
<CFPARAM NAME="form.id" DEFAULT="0">
<CFPARAM NAME="form.returnCommand" DEFAULT="">

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---///////////////////////////////////////////  Components / Variables ///////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<cfset formName = "BudgetForm" />
<CFSET PAGETITLE = "PROGRAMS: Budgets">

<cfset BudgetManager = CreateObject("component", "components.budgets.BudgetManager").init() />

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE></TITLE>
	<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
	<SCRIPT LANGUAGE="JavaScript" SRC="budget.js"></SCRIPT>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfinclude template="budget_setting_header.cfm" />

<FORM ACTION="index.cfm" METHOD="post" NAME="#formName#" style="display:inline;">

<cfswitch expression="#form.command#">
	
	<!---------------------------------- Budget Class ---------------------------------->
	<cfcase value="listBudgetClass">
		<cfinclude template="budget_class_list.cfm" />
	</cfcase>
	
	<cfcase value="ceBudgetClass">
		<cfinclude template="budget_class_create_edit.cfm" />
	</cfcase>
	
	<cfcase value="saveBudgetClass">
		<!--- save budget class --->
		<cfset saveResponse = BudgetManager.saveBudgetClass(
						form.id, 
						form.Simple_Budget_Class_Number, 
						form.Simple_Budget_Class_Desc,
						form.Simple_Budget_Class_Start_Date,
						form.Simple_Budget_Class_End_Date) />
						
		<cfset saveMessage = saveResponse[1] />				
		<cfif saveMessage eq "">
			<cfset BudgetManager.addBudgetAssociationToClass(
						classID = saveResponse[2], 
						oForm = form) />
			<cflocation url="index.cfm?command=#form.returnCommand#" />
		<cfelse>
			<cfset form.command = "ceBudgetClass" />
			<cfinclude template="budget_class_create_edit.cfm" />
		</cfif>						
		
	</cfcase>
	
	<cfcase value="deactivateBudgetClass">
		<!--- deactivate budget class --->
		<cfset saveResponse = BudgetManager.activateDeactivateBudgetClass(form.id, 0, request.AccessStructure.User_ID) />
		<cfset saveMessage = 1 />				
		<cfif saveResponse[1] eq "">
			<cflocation url="index.cfm?command=#form.returnCommand#" />
		<cfelse>
			<cfset form.command = "listBudgetClass" />
			<cfinclude template="budget_class_list.cfm" />
		</cfif>
	</cfcase>
	
	<cfcase value="activateBudgetClass">
		<!--- activate budget class --->
		<cfset saveResponse = BudgetManager.activateDeactivateBudgetClass(form.id, 1, request.AccessStructure.User_ID) />
		<cfset saveMessage = saveResponse[1] />				
		<cfif saveMessage eq "">
			<cflocation url="index.cfm?command=#form.returnCommand#" />
		<cfelse>
			<cfset form.command = "listBudgetClass" />
			<cfinclude template="budget_class_list.cfm" />
		</cfif>
	</cfcase>
	
	<!---------------------------------- Budget ---------------------------------->
	<cfcase value="listBudget">
		<cfinclude template="budget_list.cfm" />
	</cfcase>
	
	<cfcase value="ceBudget">
		<cfinclude template="budget_create_edit.cfm" />
	</cfcase>
	
	<cfcase value="saveBudget">
		<!--- save budget --->
		<cfset form.id = BudgetManager.saveBudget(
						form.id, 
						form.Simple_Budget_Number, 
						form.Simple_Budget_Desc) />
		<cfset BudgetManager.addClassAssociationToBudget(
						budgetID = form.id, 
						oForm = form) />
		<cflocation url="index.cfm?command=#form.returnCommand#" />
	</cfcase>
	
	<cfcase value="deactivateBudget">
		<!--- deactivate budget --->
		<cfset saveResponse = BudgetManager.activateDeactivateBudget(form.id, 0, request.AccessStructure.User_ID) />
		<cfset saveMessage = 1 />				
		<cfif saveResponse[1] eq "">
			<cflocation url="index.cfm?command=#form.returnCommand#" />
		<cfelse>
			<cfset form.command = "listBudget" />
			<cfinclude template="budget_list.cfm" />
		</cfif>
	</cfcase>
	
	<cfcase value="activateBudget">
		<!--- activate budget --->
		<cfset form.id = BudgetManager.activateDeactivateBudget(form.id, 1, request.AccessStructure.User_ID) />
		<cflocation url="index.cfm?command=#form.returnCommand#" />
	</cfcase>
	
	<cfcase value="deleteBudget">
		<!--- delete budget --->
		<cfset form.id = BudgetManager.deleteBudget(form.id, request.AccessStructure.User_ID) />
		<cflocation url="index.cfm?command=#form.returnCommand#" />
	</cfcase>
	
	<cfcase value="listBudgetLabel">
		<cfinclude template="budget_label_edit.cfm" />
	</cfcase>
	
	<cfcase value="saveBudgetLabel">
		<!--- save budget labels --->
		<cfset form.id = BudgetManager.saveBudgetLabels(
							budgetDollarLabel = form.Budget_Dollar_Label, 
							committedDollarLabel = form.Committed_Dollar_Label, 
							budgetBalanceLabel = form.Budget_Balance_Label, 
							approvedPaymentDollarLabel = form.Approved_Payment_Dollar_Label, 
							availableBudgetDollarLabel = form.Available_Budget_Dollar_Label,
							budgetClassAssociationLabel = form.Budget_Class_Association_Label, 
							userId = request.AccessStructure.User_ID) />
		<cflocation url="index.cfm" />
	</cfcase>
	<!---------------------------------- Budget Class Association ---------------------------------->
	
	<cfcase value="listBudgetClassAssociation,listActiveBudgetClassAssociation,listInActiveBudgetClassAssociation" delimiters=",">
		<cfset iActive = -1 />
		<cfif form.command eq "listActiveBudgetClassAssociation">
			<cfset iActive = 1 />
		<cfelseif form.command eq "listInActiveBudgetClassAssociation">
			<cfset iActive = 0 />
		</cfif>
		<cfinclude template="budget_class_association_list.cfm" />
	</cfcase>
	
	<cfcase value="saveBudgetClassAssociationNumber">
		<cfset BudgetManager.saveBudgetClassAssociationNumber(
						oForm = form) />
		<cflocation url="index.cfm?command=#form.returnCommand#" />
	</cfcase>
	
	<cfcase value="deactivateBudgetClassAssociation">
		<!--- deactivate budget class association --->
		<cfset saveResponse = BudgetManager.activateDeactivateBudgetClassAssociationSingle(form.id, 0, request.AccessStructure.User_ID) />
		<cfset saveMessage = 1 />				
		<cfif saveResponse[1] eq "">
			<cflocation url="index.cfm?command=#form.returnCommand#" />
		<cfelse>
			<cfset form.command = "listActiveBudgetClassAssociation" />
			<cfset iActive = 1 />
			<cfinclude template="budget_class_association_list.cfm" />
		</cfif>
	</cfcase>
	
	<cfcase value="activateBudgetClassAssociation">
		<!--- deactivate budget class association --->
		<cfset form.id = BudgetManager.activateDeactivateBudgetClassAssociationSingle(form.id, 1, request.AccessStructure.User_ID) />
		<cflocation url="index.cfm?command=#form.returnCommand#" />
	</cfcase>
	
	<cfcase value="deleteBudgetClassAssociation">
		<!--- delete budget class association --->
		<cfset form.id = BudgetManager.deleteBudgetClassAssociation(form.id, request.AccessStructure.User_ID) />
		<cflocation url="index.cfm?command=#form.returnCommand#" />
	</cfcase>
	
	<cfcase value="deactivateBudgetClassAssociationMulti">
		<!--- deactivate budget class association --->
		<CFPARAM NAME="form.Simple_Budget_Class_Association_ID" DEFAULT="">		
		<cfset saveResponse = BudgetManager.activateDeactivateBudgetClassAssociationMulti(form.Simple_Budget_Class_Association_ID, 0, request.AccessStructure.User_ID) />
		<cfset saveMessage = 1 />				
		<cfif saveResponse[1] eq "">
			<cflocation url="index.cfm?command=#form.returnCommand#" />
		<cfelse>
			<cfset form.command = "listActiveBudgetClassAssociation" />
			<cfset iActive = 1 />
			<cfinclude template="budget_class_association_list.cfm" />
		</cfif>
	</cfcase>
	
	<cfcase value="activateBudgetClassAssociationMulti">
		<!--- activate budget class association --->
		<CFPARAM NAME="form.Simple_Budget_Class_Association_ID" DEFAULT="">		
		<cfset form.id = BudgetManager.activateDeactivateBudgetClassAssociationMulti(form.Simple_Budget_Class_Association_ID, 1, request.AccessStructure.User_ID) />
		<cflocation url="index.cfm?command=#form.returnCommand#" />
	</cfcase>	

	<cfcase value="deleteBudgetClassAssociationMulti">
		<!--- delete budget class association --->
		<CFPARAM NAME="form.Simple_Budget_Class_Association_ID" DEFAULT="">		
		<cfset form.id = BudgetManager.deleteBudgetClassAssociationMulti(form.Simple_Budget_Class_Association_ID, request.AccessStructure.User_ID) />
		<cflocation url="index.cfm?command=#form.returnCommand#" />
	</cfcase>	
	
	<cfdefaultcase>
		<cfinclude template="budget_class_list.cfm" />
	</cfdefaultcase>
</cfswitch>


<!---hidden form fields--->
<input name="command" type="hidden" value="#form.command#" />
<input name="id" type="hidden" value="#form.id#" />
<input name="returnCommand" type="hidden" value="#form.returnCommand#" />

</FORM>

</BODY>
</HTML>
</cfoutput>