<!---      
	Name:          	add_edit_budget_group.cfm
	Copyright:     	Copyright (c) 2006 Blacksmith Applications, Inc.       
	Created Date:  	05/08/2006
	Created By:    	Deepa Kunnath
	Description:   	This page will have the display for add edit budget group
	Parameters:    	BudgetGroup - an instance of BudgetGroup object					
	Usage:         	
--->
<SCRIPT SRC="/budget/budget_group/budget_group.js"></SCRIPT>
<cfoutput>
<table cellpadding="2" cellspacing="0" border="0" width="600">
<caption align="left" style="color:red;font-weight:bold;"><cfif bAdd>Add<cfelse>Edit</cfif> Group</caption>
<colgroup>
<col align="right" width="100%"></col>
</colgroup>
<tr>
	<td>Budget Group Code</td>
	<td colspan="3"><input type="Text" name="Budget_Group_Code" value="#BudgetGroup.budgetGroupCode#" class="LONGINPUT" /></td>
</tr>
<tr>
	<td>Budget Group Name</td>
	<td colspan="3"><input type="Text" name="Budget_Group_Name" value="#BudgetGroup.budgetGroupName#" class="LONGINPUT" /></td>
</tr>
<tr>
	<td>Budget Group Value</td>
	<td colspan="3"><input type="Text" name="Budget_Group_Value" value="#BudgetGroup.budgetGroupValue#" class="LONGINPUT" /></td>
</tr>
<tr>
	<td>UOM</td>
	<td colspan="3">
	<cf_uom_dropdown
		dropdown_id				=	"Budget_Group_UOM"
		default_option_on		=	"0"
		default_option_text		=	""
		default_option_value	=	""
		dropdown_name			=	"Budget_Group_UOM"
		option_text_abbreviated	=	"1"
		plural_uom_display		=	""
		selected_uom_id			=	"#BudgetGroup.budgetGroupUOM#"
		uom_id_exclusion_list	=	"3"
		uom_id_inclusion_list	=	""
		Show_Dollar				=	"1"
	>
	</td>
</tr>
<tr>
	<td>Budget Dates</td>
	<td>
	<CF_EASYDATE FORMNAME="frmBudget" FIELDNAME="Budget_Group_Start_Date" FORMAT="mm/dd/yyyy" DEFAULT="#BudgetGroup.budgetGroupStartDate#">
	</td>
	<td width="10">&nbsp;</td>
	<td align="right">
	<CF_EASYDATE FORMNAME="frmBudget" FIELDNAME="Budget_Group_End_Date" FORMAT="mm/dd/yyyy" DEFAULT="#BudgetGroup.budgetGroupEndDate#">
	</td>
</tr>
<tr>
	<td>Budget Group Type</td>
	<td colspan="3">
	<cfset arLen = ArrayLen(arBudgetGroupTypes) />
	<select name="Budget_Group_Type">
	<cfloop from="1" to="#arLen#" index="i">
		<cfset BudgetGroupType = arBudgetGroupTypes[i] />
		<option value="#BudgetGroupType.budgetGroupTypeId#" <cfif BudgetGroup.budgetGroupTypeId eq BudgetGroupType.budgetGroupTypeId>selected</cfif>>#BudgetGroupType.budgetGroupTypeName#</option>
	</cfloop>
	</select>
	</td>
</tr>
<tr>
	<td colspan="100%" align="center">
	<input type="Hidden" name="id" value="#BudgetGroup.budgetGroupId#"" />
	&nbsp;<br>
	<CF_smallLink 
			title = "save" 
			url = "##"
			parameters = "onClick=""javascript: return submitAddEditBudgetGroup();"""
		>
	</td>
</tr>
</table>
</cfoutput>