<!---
budget_program_position_allocation_display.cfm
--->
<cfsetting showdebugoutput="no">
<cfparam name="form.contract_number" default="0">


<cfset BudgetManager = CreateObject("component", "components.budgets.BudgetManager").init() />
<cfset BudgetManager.loadBudgetLabels() />

<!----- get the value allocation per position -------->
<cfset qGetBudgetTemplateProgramPositionAllocation = BudgetManager.getBudgetTemplateProgramPositionAllocation(contractNumber=form.contract_number) >

<cfoutput>
<span style="font-weight:bold;font-size:14px;">Position allocation details</span>
<table cellpadding="1" cellspacing="1" class="MainTable" width="600">
	<tr bgcolor="ffdead" valign="top">
		<td id="header" width="20%"><b>Class</b></td>
		<td id="header" width="20%"><b>Budget</b></td>
		<td id="header" width="40%"><b>Position</b></td>
		<td id="header" width="20%"><b>Allocated #BudgetManager.getCommittedDollarLabel()#</b></td>
	</tr>
<cfset Total = 0 />
<cfloop query="qGetBudgetTemplateProgramPositionAllocation">
	<tr>
		<td>#simple_budget_class_desc# (#simple_budget_class_number#)</td>
		<td>#simple_budget_desc# (#simple_budget_number#)</td>
		<td>#position_label#</td>
		<td>#DollarFormat(committed_dollar_allocation)#</td>
	</tr>
	<cfset Total = Total + committed_dollar_allocation />
</cfloop>	
	<tr>
		<td colspan="3" align="right"><b>Total : </b></td>
		<td>#DollarFormat(Total)#</td>
	</tr>
</table>
</cfoutput>