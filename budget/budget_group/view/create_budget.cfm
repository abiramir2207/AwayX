<!---      
	Name:          	create_budget.cfm
	Copyright:     	Copyright (c) 2006 Blacksmith Applications, Inc.       
	Created Date:  	05/08/2006
	Created By:    	Deepa Kunnath
	Description:   	This page will have the display for adding and editing high level information about budgets belonging to this budget group
	Parameters:    	BudgetGroup - an instance of BudgetGroup object					
	Usage:         	
--->
<SCRIPT SRC="/budget/budget_group/budget_group.js"></SCRIPT>
<cfoutput>
<!------ display the header ----->
<table cellpadding="4" cellspacing="1">
<colgroup>
<col></col>
<col style="font-weight:bold;"></col>
</colgroup>
<tr>
	<td>Budget Group Code</td>
	<td>#BudgetGroup.budgetGroupCode#</td>
</tr>
<tr>
	<td>Budget Group Name</td>
	<td>#BudgetGroup.budgetGroupName#</td>
</tr>
<tr>
	<td>Total Budget Group Value</td>
	<td align="right"><cfif BudgetGroup.budgetGroupUOM eq 4>#DollarFormat(BudgetGroup.budgetGroupValue)#<cfelse>#BudgetGroup.budgetGroupValue#</cfif></td>
</tr>
<tr>
	<td>Allocated Budget</td>
	<td align="right">&nbsp;</td>
</tr>
<tr>
	<td>Unallocated Budget</td>
	<td align="right">&nbsp;</td>
</tr>
<tr>
	<td><input type="Text" name="Starting_Budget_Code" value="" /></td>
	<td nowrap>Starting budget Number</td>
</tr>
</table>

<!------ display the multiple rows for budgets ----->
<table cellpadding="4" cellspacing="1" class="TableGrid" id="createBudgetTable">
<thead>
	<th>Budget Code</th>
	<th>Budget Name</th>
	<th>Value</th>
	<th>UOM</th>
	<th>Start Date</th>
	<th>End Date</th>
	<th><a href="##" onclick="javascript: return addTableRowCreateBudget();">+</a></th>
</thead>
<cfset arLen = ArrayLen(arBudgets) />
<cfloop from="1" to="#arLen#" index="i">
<cfset Budget = arBudgets[i] />
<tr>
	<td><input type="Text" name="Budget_Code_#i#" value="#Budget.budgetCode#" />
	<input type="Hidden" name="Budget_Count" value="#i#" />
	<input type="Hidden" name="Budget_ID_#i#" value="#Budget.budgetId#" />
	</td>
	<td><input type="Text" name="Budget_Name_#i#" value="#Budget.budgetName#" /></td>
	<td><input type="Text" name="Budget_Value_#i#" value="#Budget.budgetValue#" /></td>
	<td>
	<cf_uom_dropdown
		dropdown_id				=	"Budget_UOM_#i#"
		default_option_on		=	"0"
		default_option_text		=	""
		default_option_value	=	""
		dropdown_name			=	"Budget_UOM_#i#"
		option_text_abbreviated	=	"1"
		plural_uom_display		=	""
		selected_uom_id			=	"#Budget.budgetUOM#"
		uom_id_exclusion_list	=	""
		uom_id_inclusion_list	=	""
		Show_Dollar				=	"1"
	>
	</td>
	<td><CF_EASYDATE2 FORMNAME="frmBudget" FIELDNAME="Budget_Start_Date_#i#" FORMAT="mm/dd/yyyy" DEFAULT="#Budget.budgetStartDate#"></td>
	<td><CF_EASYDATE2 FORMNAME="frmBudget" FIELDNAME="Budget_End_Date_#i#" FORMAT="mm/dd/yyyy" DEFAULT="#Budget.budgetEndDate#"></td>
</tr>
</cfloop>
</table>
<table width="700">
<tr>
	<td colspan="100%" align="center" id="header">
	<input type="Hidden" name="id" value="#BudgetGroup.budgetGroupId#"" />
	&nbsp;<br>
	<CF_smallLink 
			title = "save" 
			url = "##"
			parameters = "onClick=""javascript: return submitCreateBudget();"""
		>
	</td>
</tr>
</table>
</cfoutput>