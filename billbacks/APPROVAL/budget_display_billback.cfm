<!---- /billbacks/approval/budget_display_billback.cfm ----->
<cfparam name="url.Billback_ID" default="">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Billback - Budget Display</title>
</head>

<body RIGHTMARGIN="8" LEFTMARGIN="8">

<style>
	.budgetProgramDetails {color:blue;}
</style>
<cfif url.Billback_ID neq "">

<cfset BudgetManager = CreateObject("component", "components.budgets.BudgetManager").init() />
<cfset BudgetBillbackManager = CreateObject("component", "components.budgets.BudgetBillbackManager").init() />

<cfset BudgetManager.loadBudgetLabels() />

<cfset qArray = BudgetBillbackManager.getBudgetDetailsForBillback(billbackId = url.Billback_ID) />
<cfset qBudgetDetailsForBillback = qArray[1] />
<cfset qBudgetsForBillback = qArray[2] />

<cfoutput>
<table BORDER="0" CELLPADDING="0" CELLSPACING="0" width="100%">
	<TR>
		<TD COLSPAN="100%">
			<CFINCLUDE TEMPLATE="#Application.Doc_Mapping#/data_files/created/#application.returned_customer_setting.qry_customer_name_font_start#">
			#application.returned_customer_setting.company_name#</DIV>
			<FONT SIZE="+1" COLOR="Navy">
				<B>#qBudgetsForBillback.BB_Code#</B>
			</FONT>
			#qBudgetsForBillback.BB_Title#
		</td>
	</tr>
</table>
</cfoutput>

<hr color="orange">

<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />
<cfset payeeTypeName = "Payee" />
<cfif IsNumeric(qBudgetDetailsForBillback.Billback_Payee_Type_ID)>
	<cfset payeeTypeName = templateManager.getPaymentPaidToTypeDesc(paidToID = qBudgetDetailsForBillback.Billback_Payee_Type_ID, paidToDesc="") />
</cfif>
<!-------------------- loop over programs - start -------------------------------------------->
<table cellpadding="2" cellspacing="0" width="90%" align="center">
<cfoutput query="qBudgetDetailsForBillback" group="contract_number">
	<cfset programTotalAvailableBudgetDollar = 0 />
	<tr>
		<td colspan="100%" bgcolor="ccffcc">[#Contract_Number#] #Contract_Title#</b>
		</td>
	</tr>
	<!-------------------- loop over budgets - end -------------------------------------------->
	<cfoutput group="Simple_Budget_Class_Association_ID">
	<tr bgcolor="ffdead" valign="top" style="font-weight:bold;">
		<td>#BudgetManager.getBudgetClassAssociationLabel()#</td>
		<td align="right">version ##</td>
		<td align="right">Pgm Alloc %</td>
		<td>&nbsp;</td>
		<td align="right">#BudgetManager.getCommittedDollarLabel()#<br>(#payeeTypeName#)</td>
		<cfif qBudgetDetailsForBillback.Billback_Payee_Type_ID eq 1><td>&nbsp;</td><td align="right">Weight</td></cfif>
		<td>&nbsp;</td>
		<td align="right">#BudgetManager.getCommittedDollarLabel()#<Br>(Payee)</td>		
	</tr>
	<cfset budgetTotal = 0 />
	<cfoutput>
		<tr>
			<td>#Simple_Budget_Class_Association_Number#</td>
			<td align="right">#Revision_Version#</td>
			<td align="right">#Committed_Allocation_Percent#%</td>
			<td align="center">*</td>
			<td align="right">#DollarFormat(Program_Committed_For_Payee_Type)#</td>
			<cfif Billback_Payee_Type_ID eq 1><td align="center">*</td><td align="right">#payee_weight#%</td></cfif>
			<td align="center">=</td>
			<td align="right">#DollarFormat(Program_Committed_For_Payee)#</td>			
		</tr>
		<cfset budgetTotal = budgetTotal + Val(Program_Committed_For_Payee) />
	</cfoutput>
	<cfset colspanCount = 6 />
	<cfif qBudgetDetailsForBillback.Billback_Payee_Type_ID eq 1>
		<cfset colspanCount = colspanCount + 2 />
	</cfif>
	<cfquery name="getActualDollarForProgramBudget" dbtype="query">
		SELECT	Program_Committed_Dollar, Actual_Dollar_Program, 
				Actual_Dollar_Payee, Budget_Balance, Actual_Dollar
		FROM	qBudgetsForBillback
		WHERE	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="cf_sql_varchar">
		AND		Billback_Program_ID = <cfqueryparam value="#Billback_Program_ID#" cfsqltype="cf_sql_varchar">
		AND		Simple_Budget_Class_ID = <cfqueryparam value="#Simple_Budget_Class_ID#" cfsqltype="cf_sql_integer">
		AND		Simple_Budget_ID = <cfqueryparam value="#Simple_Budget_ID#" cfsqltype="cf_sql_integer">
	</cfquery>
	
	<cfset Display_Program_Committed_Dollar = Val(getActualDollarForProgramBudget.Program_Committed_Dollar) />
	<cfset Actual_Dollar_Payee = Val(getActualDollarForProgramBudget.Actual_Dollar_Payee) />
	<cfset Actual_Dollar_Program = Val(getActualDollarForProgramBudget.Actual_Dollar_Program) />
	<cfset Budget_Balance = Val(getActualDollarForProgramBudget.Budget_Balance) />
	<cfset Actual_Dollar_Current_Billback = Val(getActualDollarForProgramBudget.Actual_Dollar) />
	<tr>
		<td colspan="#colspanCount#" align="right" class="budgetProgramDetails">&##931; #BudgetManager.getCommittedDollarLabel()# (Payee)</td>
		<td align="right" class="budgetProgramDetails">#DollarFormat(budgetTotal)#</td>		
	</tr>
	<tr>
		<td colspan="#colspanCount#" align="right" class="budgetProgramDetails">#BudgetManager.getApprovedPaymentDollarLabel()# (Payee)</td>
		<td align="right" class="budgetProgramDetails">#DollarFormat(Actual_Dollar_Payee)#</td>		
	</tr>
	<tr>
		<td colspan="#colspanCount#" align="right" class="budgetProgramDetails">#BudgetManager.getCommittedDollarLabel()# (Program)</td>
		<td align="right" class="budgetProgramDetails">#DollarFormat(Display_Program_Committed_Dollar)#</td>		
	</tr>
	<tr>
		<td colspan="#colspanCount#" align="right" class="budgetProgramDetails">#BudgetManager.getApprovedPaymentDollarLabel()# (Program)</td>
		<td align="right" class="budgetProgramDetails">#DollarFormat(Actual_Dollar_Program)#</td>		
	</tr>
	<tr>
		<td colspan="#colspanCount#" align="right" class="budgetProgramDetails">#BudgetManager.getAvailableBudgetDollarLabel()#</td>
		<td align="right" class="budgetProgramDetails" style="font-weight:bold;">#DollarFormat(Budget_Balance)#</td>		
	</tr>
	<cfset programTotalAvailableBudgetDollar = programTotalAvailableBudgetDollar + Budget_Balance />
	<cfif qBudgetsForBillback.Billback_Status_ID GT 2>
	<tr>
		<td colspan="#colspanCount#" align="right" class="budgetProgramDetails">#BudgetManager.getApprovedPaymentDollarLabel()# (current billback)</td>
		<td align="right" class="budgetProgramDetails" style="font-weight:bold;">#DollarFormat(Val(Actual_Dollar_Current_Billback))#</td>		
	</tr>
	</cfif>
	</cfoutput>
	<!-------------------- loop over budgets - end -------------------------------------------->
<tr>
	<td style="border-top:1 solid black;" colspan="#colspanCount#" align="right" class="budgetProgramDetails">&##931; #BudgetManager.getAvailableBudgetDollarLabel()#</td>
	<td style="border-top:1 solid black;font-weight:bold;" align="right" class="budgetProgramDetails">#DollarFormat(programTotalAvailableBudgetDollar)#</td>		
</tr>
</cfoutput>
</table>

<!-------------------- loop over programs - end -------------------------------------------->


</cfif>
<cfoutput>
<br><br>
<center>
	<CF_button
		button_name		=	""
		button_caption	=	"close"
		button_action	=	"window.close();"
		button_type		=	"javascript_link"
		button_width	=	"50"
		button_color	=	"Navy"
		button_tip		=	"execute"
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>
</center>				
</cfoutput>
	
</body>
</html>
