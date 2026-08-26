<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\addBudget.cfm
      Date:     June 10, 2011
      Author:   Chris Nguyen
      Purpose:  Create a new budget
----------------------------------------------------------------------------------------------------------------------->

<cfscript>
  form.Budget_Contribution_Factor_Type_ID = "";
</cfscript>

<div style="margin:0px">
<fieldset style="padding:10px; width: 600px; border: 1px solid blue;">
	<legend style="font: bold 14px sans-serif; color: red;">Budget - Add</legend>

<cfinclude template="budgetgeneral.cfm">

<!--------------------------------------------------------------------------------------------------------------------->
<cfinclude template="actionFormat.cfm">
<!--------------------------------------------------------------------------------------------------------------------->

<div id="action" style="clear:both;margin-top:40px">
 <cfoutput>
 <a href="javascript:window.location='index.cfm'">#LCase(ActionText("cancel"))#</a>
 </cfoutput>
</div>
</fieldset>
</div>

<!--------------------------------------------------------------------------------------------------------------------->

<cfinclude template="/common_files/jQuery.cfm">

<script type="text/javascript">
function switchfactor( budget_type ) {
  if ( budget_type.value == 1)
    document.forms[budget_form].command.value = "editFixed";
  else if ( budget_type.value == 2)
    document.forms[budget_form].command.value = "editAccrual";
  else if ( budget_type.value == 3)
    document.forms[budget_form].command.value = "editVariable";
  document.forms[budget_form].submit();
}
$('input').bind({
	focus: function(){ $(this).addClass('hilight'); }
	,blur: function(){ $(this).removeClass('hilight'); }
});

$('form input:visible:enabled:first').focus();
</script>