<!---      
	Name:          	list_budget_group.cfm
	Copyright:     	Copyright (c) 2006 Blacksmith Applications, Inc.       
	Created Date:  	05/08/2006
	Created By:    	Deepa Kunnath
	Description:   	This page will handle the display for displaying teh list of the list of budget groups and budgets
	Parameters:    	
	Usage:         	
--->


<cfoutput>

<b><a href="##">[deactivate selected]</a></b>
<br><br>

<cfset arLen = ArrayLen(arBudgetGroups) />

<table cellpadding="2" cellspacing="0" border="0" width="90%" class="TableGrid">
<thead>
	<th>&nbsp;</th>
	<th>Budget Code</th>
	<th>Budget Name</th>
	<th>Value</th>
	<th>Start Date</th>
	<th>End Date</th>
	<th>&nbsp;</th>
	<th>&nbsp;</th>
	<th>&nbsp;</th>
</thead>
<cfloop from="1" to="#arLen#" index="i">
	<!------ display budget group ----->
	<cfset BudgetGroup = arBudgetGroups[i] />
	<cfset arBudgets = BudgetGroup.budgetGroupMembers />
	<tr class="tableheaders">
		<td>&nbsp;</td>
		<td><a href="index.cfm?command=addEditBudgetGroup&id=#BudgetGroup.budgetGroupId#">#BudgetGroup.budgetGroupCode#</a></td>
		<td><a href="index.cfm?command=addEditBudgetGroup&id=#BudgetGroup.budgetGroupId#">#BudgetGroup.budgetGroupName#</a></td>
		<td align="right"><cfif BudgetGroup.budgetGroupUOM eq 4>#DollarFormat(BudgetGroup.budgetGroupValue)#<cfelse>#NumberFormat(BudgetGroup.budgetGroupValue, "___,___")#</cfif></td>
		<td align="right">#DateFormat(BudgetGroup.budgetGroupStartDate, "mm/dd/yyyy")#</td>
		<td align="right">#DateFormat(BudgetGroup.budgetGroupEndDate, "mm/dd/yyyy")#</td>
		<td align="center"><a href="index.cfm?command=createBudget&id=#BudgetGroup.budgetGroupId#">[create budget]</a></td>
		<td align="center"><a href="##">[upload budget]</a></td>
		<td align="center"><a href="##">[period dist]</a></td>
	</tr>
	<!------ display the budgets belonging to this budget group ----->
	<cfset totalAllocatedValue = 0 />
	<cfset arLenBudget = ArrayLen(arBudgets) />
	<cfloop from="1" to="#arLenBudget#" index="j">
	<cfset Budget = arBudgets[j] />
	<tr>
		<td><input type="Checkbox" name="Budget_ID" value="#Budget.budgetId#"></td>
		<td><a href="index.cfm?command=edit#BudgetGroup.BudgetGroupTypeCode#Budget&id=#Budget.budgetId#">#Budget.budgetCode#</a></td>
		<td><a href="index.cfm?command=edit#BudgetGroup.BudgetGroupTypeCode#Budget&id=#Budget.budgetId#">#Budget.budgetName#</a></td>
		<td align="right"><cfif Budget.budgetUOM eq 4>#DollarFormat(Budget.budgetValue)#<cfelse>#NumberFormat(Budget.budgetValue, "___,___")#</cfif></td>
		<td align="right">#DateFormat(Budget.budgetStartDate, "mm/dd/yyyy")#</td>
		<td align="right">#DateFormat(Budget.budgetEndDate, "mm/dd/yyyy")#</td>
		<td>&nbsp;</td>
	</tr>
	<cfset totalAllocatedValue = totalAllocatedValue + Budget.budgetValue />
	</cfloop>
	<cfset unAllocatedValue = BudgetGroup.budgetGroupValue - totalAllocatedValue />
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td>"unallocated" dollars</td>
		<td align="right"><cfif BudgetGroup.budgetGroupUOM eq 4>#DollarFormat(unAllocatedValue)#<cfelse>#NumberFormat(unAllocatedValue, "___,___")#</cfif></td>		
	</tr>
</cfloop>
</table>
</cfoutput>