<!---
	Name: btm_budget_view.cfm         
	Copyright (c) 2006 Blacksmith Applications, Inc.                  
	Description:
		<brief description of what the file is used for>
--->	

<!--- Get Budgets 	--->
<!--- Get Templates --->
<cfinvoke component="components.settings.budget.BudgetTemplateMappings" method="LastUpdated" returnvariable="qLastUpdated">
<cfinvoke component="components.user.usermanager" method="getusername" userid="#qLastUpdated.created_by#" returnvariable="SettingsUpdateUser">  	

<TABLE ID="lastUpdatedBy" BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
<TR>
<TD align="left" width="600px" style="font-size:12px;">
	<B>The budget settings were last updated on <CFOUTPUT>#dateformat(qLastUpdated.created_on, 'm/d/yyy')# #timeformat(qLastUpdated.created_on, 'h:mm:ss TT')# by #SettingsUpdateUser#</CFOUTPUT></B></TD>
</TD>
</TR>
</TABLE>
<br>

<cfset loadargs = "budget_template_mappings.cfm?viewmode=template" />
<cfset linkname = "Template View" />

<table>
<tr>
<td>
<cf_button 	name="linkView" button_type="link" button_caption="Budget Settings > Go To #linkname#" button_action="#loadargs#">
</td>
<td>
<cf_button 	name="linkView" button_type="link" button_caption="Save Settings" button_action="javascript:submitForm();">
</td>
</tr>
</table>
<br>

<script>
	//function to check or uncheck all checkboxes of category
	function checkMatchingProd(type_code,checked)
	{
		var elemColctn2 = document.budget_to_template_mapping.getElementsByTagName("input");
		for (var i = 0; i < elemColctn2.length; i++)
		{
			if (elemColctn2[i].id == type_code)
			{
					elemColctn2[i].checked = checked;
			}
		}
	}
			
	function submitForm()
	{
		document.all.budget_to_template_mapping.submit();
	}
</script>



<form method="post" name="budget_to_template_mapping" action="budget_template_mappings_action.cfm">
<input type="hidden" name="viewmode" value="budget">
<!--- Obtain Lists of Budgets & Templates  --->
<cfinvoke component="components.budget.budgetgroupmanager" method="getBudgetGroups" returnvariable="arBudgetGroups">
<cfinvoke component="components.programs.template.TemplateManager" method="getAll" returnvariable="qGetTemplates">

<cfinclude template="budget_active_relationship.cfm" />

<cfoutput>
	<cfset arLenBudgetGroups = ArrayLen(arBudgetGroups) />
	<!--- Loop Over Budget Groups --->
	<cfloop index="arBudgetGroupIdx" from="1" to="#arLenBudgetGroups#" step="1">
		<cfset arLenBudgetGroupMembers = ArrayLen(arBudgetGroups[arBudgetGroupIdx].budgetgroupmembers) />
			<!--- Looping Over Budget Group Members --->
			<cfloop index="arBudgetGroupMembersIdx" from="1" to="#arLenBudgetGroupMembers#" step="1">
			<table width="800px" border="1" style="border-collapse:collapse;">
				<tr>
					<cfset tblID = "#arBudgetGroups[arBudgetGroupIdx].BudgetGroupID#_#arBudgetGroups[arBudgetGroupIdx].budgetgroupmembers[arBudgetGroupMembersIdx].budgetReferenceId#" />
					<td colspan="2" style="font-weight:bold;border-right:0px">BUDGET: #UCASE(arBudgetGroups[arBudgetGroupIdx].budgetgroupmembers[arBudgetGroupMembersIdx].BudgetName)#</td>
					<td colspan="2" style="font-weight:bold;display:inline;text-align:right;border-left:0px">
					<a href="javascript:checkMatchingProd('id_#JSSTRINGFORMAT(tblID)#',true)">(Select All)</a>&nbsp;
					<a href="javascript:checkMatchingProd('id_#JSSTRINGFORMAT(tblID)#',false)">(Deselect All)</a>
					</td>
				</tr>
				<!--- Loop Over Active Templates --->
				<cfloop query="qGetTemplates">
							<cfset currentRow = currentRow + 1>
							<cfset lastcell = currentRow MOD 4>
							<cfif lastcell EQ 1>
							<tr>
							</cfif>
								<td width="25%">
									<input type="checkbox" id="id_#JSSTRINGFORMAT(tblID)#" Name="#PROGRAMCONTROL_PANEL_OPTIONS_ID#_#tblID#" value="1" <cfif isActive(First_Parent_ID,arBudgetGroups[arBudgetGroupIdx].budgetgroupmembers[arBudgetGroupMembersIdx].budgetReferenceId)>CHECKED</cfif> > 
									&nbsp;&nbsp; #Created_Type#
								</td>
							<cfif lastcell EQ 0>
							</tr>
							</cfif>		
				</cfloop>	
			</cfloop>
		</table>
	<br>
	</cfloop>
	<cfset currentRow = 0 />
</cfoutput>
</form>
<table>
<tr>
<td>
<cf_button 	name="linkView" button_type="link" button_caption="Budget Settings > Go To #linkname#" button_action="#loadargs#">
</td>
<td>
<cf_button 	name="linkView" button_type="link" button_caption="Save Settings" button_action="javascript:submitForm();">
</td>
</tr>
</table>


