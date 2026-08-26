<!---- 
budget_billback_approve_email.cfm
Send a summary email for billbacks that are approved beyond budget dollars
---->
<cfset budgetsBillbackApproveEmailAddress = Trim(application.oApplicationAppSettingsManager.getApplicationAppSettings().getBudgetsBillbackApproveEmailAddress()) />
<cfif Len(budgetsBillbackApproveEmailAddress) gt 0>
	<cfset qGetBillbackApprovalInfo = CreateObject("component", "components.billback.BillbackSummaryManager").getBillbackApprovalInfo(billbackId=arguments.billbackId) />
	<cfset BudgetManager = CreateObject("component", "components.budgets.BudgetManager").init() />
	<cfset BudgetManager.loadBudgetLabels() />
	<cfset qBudgetsForBillback = CreateObject("component", "components.budgets.BudgetBillbackManager").getBudgetsForBillback(billbackID = arguments.billbackID) />
	<cfquery name="qBudgetsForCurrentBillback" dbtype="query">
		SELECT	*
		FROM	qBudgetsForBillback
		WHERE	Actual_Allocated_Percent IS NOT NULL
	</cfquery>
	<cfinclude template="/get_Contact_Admin_Email_Address.cfm">
	<CF_EMAILWRAPPER 
		TO			=	"#budgetsBillbackApproveEmailAddress#"
		FROM		=	"#Contact_Admin_Email_Address#"
		SUBJECT		=	"Billback #qGetBillbackApprovalInfo.BB_Code# is approved beyond budget dollars."
		TYPE		=	"html" 
		messagetype="1" 
		generatedby="1"
		appArea="1"
	>
	<cfoutput>
		<TABLE>
		<TR>
		<TD VALIGN="top">
		Billback [#qGetBillbackApprovalInfo.BB_Code#] "#qGetBillbackApprovalInfo.BB_Title#" is approved beyond budget dollars by #qGetBillbackApprovalInfo.Billback_Approver# on #DateFormat(qGetBillbackApprovalInfo.Date_Approved, "mm/dd/yyyy")# #TimeFormat(qGetBillbackApprovalInfo.Date_Approved, "hh:mm:ss tt")#.<br>
		<hr style="color:black;height:1px">
		<cfloop query="qBudgetsForCurrentBillback">
			Class: #Simple_Budget_Class_Desc# (#Simple_Budget_Class_Number#)<br>
			Budget: #Simple_Budget_Desc# (#Simple_Budget_Number#)<br>
			#BudgetManager.getBudgetClassAssociationLabel()#: #Simple_Budget_Class_Association_Number#<br>
			Budget Balance: <font <cfif Budget_Balance LT 0>color="red"</cfif>><b>#DollarFormat(Budget_Balance)#</b></font><br>
			Current billback allocated %: #Actual_Allocated_Percent#%<br>
			Current billback allocated dollar: #DollarFormat(Actual_Dollar)#
			<hr style="color:black;height:1px">
		</cfloop>		
		</TD>
		</TR>
		</TABLE>		
	</cfoutput>
	</CF_EMAILWRAPPER>
</cfif>