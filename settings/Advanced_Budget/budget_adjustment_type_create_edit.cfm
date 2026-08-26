<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\budget_adjustment_type_create_edit.cfm
      Date:     May 24, 2012
      Author:   Chris Nguyen
      Purpose:  Edit, Delete, Save budget adjustment type
----------------------------------------------------------------------------------------------------------------------->
<cfparam name="edit" default="1" >
<style>
td.label {
  text-align: right;
  padding-right: 15px;
  font-weight: bold;
}
.item {
	margin:15px;
}
.itemlabel {
	width:75px;
	font-weight:bold;
	text-align:right;
	margin-right:12px;
}
.radioimg {
	position:relative;
	top:2px;
}
.radiospan {
	margin-right:10px;
}
</style>

<cfset vars.oBudgetAdjustmentManager = createObject('component','mvc.Models.AdvancedBudget.BudgetAdjustmentManager') />

<cfif form.clicked_save eq "1">
  <cfscript>
		vars.oBudgetAdjustmentManager.saveBudgetAdjustmentType();
  </cfscript>
	<cflocation url="index.cfm?command=listAdjustmentTypes">

<cfelseif form.command eq "deleteAdjustmentType">
  <cfset vars = {}>
  <cfquery name="vars.delete" datasource="#application.datasource#">
    UPDATE Budget_Adjustment_Type
       SET Deleted = 1
     WHERE Budget_Adjustment_Type_Id = <cfqueryparam value="#form.Budget_Adjustment_Type_Id#" cfsqltype="cf_sql_integer">
  </cfquery>
	<cflocation url="index.cfm?command=listAdjustmentTypes">
</cfif>

<cfscript>
	form.code = '';
	form.description = '';
	form.active = '1';
</cfscript>

<cfif form.Budget_Adjustment_Type_Id neq "0">
	<cfset oAdjustmentType = vars.oBudgetAdjustmentManager.getBudgetAdjustmentTypes( form.Budget_Adjustment_Type_Id ) />
	<cfscript>
		form.code = oAdjustmentType.code;
		form.description = oAdjustmentType.description;
		form.active = oAdjustmentType.active;
	</cfscript>
</cfif>

<fieldset style="padding:10px; width: 100%; border: 1px solid blue;">
	<legend style="font: bold 14px sans-serif; color: red;">
		Budget Adjustment Type - 
		<cfif form.Budget_Adjustment_Type_Id eq "0">
			Add
		<cfelse>
			<cfif ! qGetCreateBudget.Create_Budget>
				View
			<cfelse>
				Edit
			</cfif>
		</cfif>
	</legend>

<cfoutput>
<div style="margin:15px">
	<div class="item">
		<label class="itemlabel" for="code">Code:</label>
		<input type="text" name="code" id="code" value="#form.code#" size=10 maxlength=10 <cfif ! qGetCreateBudget.Create_Budget>disabled</cfif>>
	</div>
	
	<div class="item">
		<label class="itemlabel" for="description">Description:</label>
		<input type="text" name="description" id="description" value="#form.description#" size=50 maxlength=50 <cfif ! qGetCreateBudget.Create_Budget>disabled</cfif>>
	</div>
	
	<div class="item">
		<label class="itemlabel">Active:</label>
		<span class="radiospan">
			<input type="radio" class="radioimg" name="Active" id="active_yes" value="1" <cfif form.active eq 1>checked</cfif> <cfif ! qGetCreateBudget.Create_Budget>disabled</cfif>> 
			<label for="active_yes">Yes</label>
		</span>
		<span class="radiospan">
			<input type="radio" class="radioimg" name="Active" id="active_no" value="0" <cfif form.active eq 0>checked</cfif> <cfif ! qGetCreateBudget.Create_Budget>disabled</cfif>>
			<label for="active_no">No</label>
		</span>
	</div>
</div>
<input type="hidden" name="Budget_Adjustment_Type_Id" id="budget_adjustment_type_id" value="#form.budget_adjustment_type_id#"/>
</cfoutput>

<!----- Save / Cancel Buttons ----->
<div style="margin:20px 0 15px 120px">
 <cfoutput>
 	 <cfif qGetCreateBudget.Create_Budget>
		 <a href="javascript:save_info();">#application.util.string.actionLinkFormat("save")#</a>
	</cfif>
 <a href="javascript:window.location='index.cfm?command=listAdjustmentTypes'" style="margin:30px">#application.util.string.actionLinkFormat("return to budget adjustment types list")#</a>
 </cfoutput>
</div>

</fieldset>

<!--------------------------------------------------------------------------------------------------------------------->

<cfinclude template="/common_files/jQuery.cfm">

<script type="text/javascript">
function save_info() {
	var error_msg = '';
	if (document.forms[budget_form].code.value === '') {
		error_msg = 'Please enter a code.\n';
		document.forms[budget_form].code.focus();
	}
	if (document.forms[budget_form].description.value === '') {
		if ( error_msg ) ;
		else {
			document.forms[budget_form].description.focus();
		}
		error_msg = error_msg + 'Please enter a description.\n';
	}
	if ( error_msg ) {
		alert( error_msg );
	}
	else {
    document.forms[budget_form].command.value = "saveAdjustmentType";
    document.forms[budget_form].clicked_save.value = "1";
    document.forms[budget_form].submit();
  }
}	
$('input,select').bind('focus', function(){ $(this).addClass('hilight'); }).bind('blur', function(){ $(this).removeClass('hilight'); });
$('form input:visible:enabled:first').focus();
</script>