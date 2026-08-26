<!---
	Name:          	budget_group_create_edit.cfm
	Copyright:     	Copyright (c) 2011 Blacksmith Applications, Inc.
	Created Date:  	05/19/2011
	Created By:    	Deepa Kunnath
	Description:   	This page is the UI for creating and editing budget group
	Parameters:
	Usage:
--->
<cfparam name="edit" default="1" >
<style>
td.label {
  text-align: right;
  padding-right: 15px;
  font-weight: bold;
}
</style>

<!--------------------------------------------------------------------------------------------------------------------->
<cfinclude template="actionFormat.cfm">
<!--------------------------------------------------------------------------------------------------------------------->

<cfset oBudgetGroupManager = createObject('component','mvc.Models.AdvancedBudget.BudgetGroupManager') />

<cfif form.clicked_save eq "1">
  <cfscript>
	 oBudgetGroup        = oBudgetGroupManager.getSingleBudgetGroup(0);
	 oBudgetGroup.id     = form.Budget_Group_ID;
	 oBudgetGroup.number = form.BudgetGroupNumber;
	 oBudgetGroup.desc   = form.BudgetGroupDesc;
	 oBudgetGroup.active = form.Active;

	 oBudgetGroupManager.saveBudgetGroup(oBudgetGroup);
  </cfscript>
	<cflocation url="index.cfm?command=listbudgetgroup">

<cfelseif form.command eq "deleteBudgetGroup">
  <cfset vars = {}>
  <cfquery name="vars.delete" datasource="#application.datasource#">
    UPDATE Budget_Group
       SET Deleted = 1
     WHERE Budget_Group_Id = <cfqueryparam value="#form.Budget_Group_Id#" cfsqltype="cf_sql_integer">
  </cfquery>
	<cflocation url="index.cfm?command=listbudgetgroup">
</cfif>

<cfset oBudgetGroup = oBudgetGroupManager.getSingleBudgetGroup(form.Budget_Group_ID) />

<fieldset style="padding:10px; width: 100%; border: 1px solid blue;">
	<legend style="font: bold 14px sans-serif; color: red;">Budget Group - <cfif form.budget_group_id eq "0">Add<cfelse>Edit</cfif></legend>

<div style="margin:15px">
<cfoutput>
<table cellspacing="5">

	<tr>
		<td class="label">Code:</td>
		<td><input type="text" name="BudgetGroupNumber" value="#oBudgetGroup.number#" size=10 maxlength=10 <cfif ! qGetCreateBudget.Create_Budget>disabled</cfif>></td>
	</tr>

	<tr>
		<td class="label">Description:</td>
		<td><input type="text" name="BudgetGroupDesc" value="#oBudgetGroup.desc#" size=50 maxlength=50 <cfif ! qGetCreateBudget.Create_Budget>disabled</cfif>></td>
	</tr>

	<tr>
		<td class="label">Active:</td>
		<td>
			<input type="radio" name="Active" value="1" <cfif oBudgetGroup.active eq 1>checked</cfif> <cfif ! qGetCreateBudget.Create_Budget>disabled</cfif>> Yes
			&nbsp;&nbsp;&nbsp;
			<input type="radio" name="Active" value="0" <cfif oBudgetGroup.active eq 0>checked</cfif> <cfif ! qGetCreateBudget.Create_Budget>disabled</cfif>> No
		</td>
	</tr>

</table>
</div>
</cfoutput>

<!----- Save / Cancel Buttons ----->
<div style="float:left; margin:10px 0 0 20px">
 <cfoutput>
 	<cfif qGetCreateBudget.Create_Budget>
 		<a href="javascript:save_group()">#LCase(ActionText("save"))#</a>
	</cfif>
 		<a href="javascript:window.location='index.cfm?command=listBudgetGroup'" style="margin:30px">#LCase(ActionText("return to budget classes list"))#</a>
 </cfoutput>
</div>

</fieldset>

<!--------------------------------------------------------------------------------------------------------------------->

<cfinclude template="/common_files/jQuery.cfm">

<script type="text/javascript">
function save_group() {
    document.forms[budget_form].command.value = "saveBudgetGroup";
    document.forms[budget_form].clicked_save.value = "1";
    document.forms[budget_form].submit();
}
$('input,select').bind('focus', function(){ $(this).addClass('hilight'); }).bind('blur', function(){ $(this).removeClass('hilight'); });
$('form input:visible:enabled:first').focus();
</script>