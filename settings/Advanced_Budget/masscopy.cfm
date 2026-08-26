<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\masscopy.cfm
      Date:     Aug 24 2011
      Author:   Chris Nguyen
      Purpose:  Provide a way to mass copy all budgets for a specific budget class to another budget class
----------------------------------------------------------------------------------------------------------------------->
<html lang="en">
<head>
 <meta http-equiv="content-type" content="text/html; charset=utf-8">
 <title></title>
 <link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
 <link rel="stylesheet" type="text/css" href="/common_files/impromptu.css">
 <style type="text/css">
 .dollar { text-align:right; }
 .mid { text-align:center; }
 .fieldset2 { margin:10px; padding:0 10px 10px 10px; border:0 none; border-top:#cccccc 1px solid; width:20%}
 .legend2 { margin:0.5em; padding:0 0.5em; background:transparent; color:#003366; font-size:1.1em; font-weight:bold; }
 #actions { margin:20px 0 20px 180px; clear:both; }
 #actions a { margin:0 15px; }
 #masscopy label { font-weight:bold; margin-right:10px; }
 #masscopy select { margin:10px; width:250px; }
 .bclass { float:left; }
 .fromto { position:relative; top:-75px; }
 </style>
</head>
<body>
<cfset pagetitle = "PROGRAMS: Budgets">
<cfinclude template="/settings/settings_title.cfm">
<cfscript>
 main = {};
 const = {};
 const.variable_budget = 3;
 const.customers = 4;
</cfscript>

<cfif StructKeyExists(form, 'from_class')>
  <!---<cfdump var="#form#"> <cfabort>--->
  <cfoutput>
  	<cfstoredproc procedure="ADV_BUDGET_MASS_COPY"
	      dataSource="#application.datasource#"
	      returnCode="Yes"
	      debug="Yes">
	     <cfprocparam type="in" cfsqltype = cf_sql_integer value="#form.from_class#" dbVarName = @from_budget_class_id>
	     <cfprocparam type="in" cfsqltype = cf_sql_integer value="#form.to_class#" dbVarName = @to_budget_class_id>
	  </cfstoredproc>
  </cfoutput>
  <cflocation url="index.cfm?bySearch=#url.bySearch#&byClassIDs=#url.byClassIDs#&byBudgetCodes=#trim(url.byBudgetCodes)#&byGroupIDs=#url.byGroupIDs#&byBudgetTypeIDs=#url.byBudgetTypeIDs#&bySegmentIDs=#url.bySegmentIDs#" >
</cfif>

<!--------------------------------------------------------------------------------------------------------------------->
<cfinclude template="actionFormat.cfm">
<!--------------------------------------------------------------------------------------------------------------------->
<cfinvoke method="getBudgetClass" component="mvc.Models.AdvancedBudget.BudgetClassManager" returnvariable="main.qClasses" >

<fieldset id="mainfieldset" style="padding:10px; border:1px solid blue;">
  <legend style="font: bold 14px sans-serif; color: red;">Budget - Mass Copy</legend>

	<form name="masscopy" id="masscopy" action="" method="post">
	  <div class="bclass">
	  <fieldset class="fieldset2">
	  	<legend class="legend2">From Budget Class</legend>
	    <!---<label class="fromto">From Budget Class:</label>--->
	    <select name="from_class" size="10">
	    <cfsetting enablecfoutputonly="true" >
	    <cfloop query="main.qClasses">
	      <cfoutput><option value="#main.qClasses.budget_class_id#">#main.qClasses.budget_class_desc#</option></cfoutput>
	    </cfloop>
	    <cfsetting enablecfoutputonly="false" >
	    </select>
	  </fieldset>
	  </div>
	
	  <div class="bclass">
	  <fieldset class="fieldset2">
		  <legend class="legend2">To Budget Class</legend>
		  <!---<label class="fromto">To Budget Class:  </label>--->
		  <select name="to_class" size="10">
		  <cfsetting enablecfoutputonly="true" >
		  <cfloop query="main.qClasses">
		    <cfoutput><option value="#main.qClasses.budget_class_id#">#main.qClasses.budget_class_desc#</option></cfoutput>
		  </cfloop>
		  <cfsetting enablecfoutputonly="false" >
		  </select>
	  </fieldset>
	  </div>
	</form>
	<!----- action links ----->
	<cfoutput>
		<div id="actions">
		 <a href="##" id="copy">#LCase(ActionText("copy"))#</a>
		 <a href="javascript:window.location='index.cfm?bySearch=#url.bySearch#&byClassIDs=#url.byClassIDs#&byBudgetCodes=#trim(url.byBudgetCodes)#&byGroupIDs=#url.byGroupIDs#&byBudgetTypeIDs=#url.byBudgetTypeIDs#&bySegmentIDs=#url.bySegmentIDs#';">#LCase(ActionText("return to budgets list"))#</a>
		</div>
	</cfoutput>
</fieldset>

<!--------------------------------------------------------------------------------------------------------------------->

<cfinclude template="/common_files/jQuery.cfm">
<script type="text/javascript" src="/Script/javascript/jquery-impromptu.3.1.min.js"></script>

<script type="text/javascript">
$.prompt.setDefaults( { opacity:'0.3', prefix:'cleanblue', top:'35%' } );
$('#copy').click(function(){
  var error_message = '',
      from_selected = $('select[name=from_class] option:selected').val(),
      to_selected   = $('select[name=to_class] option:selected').val();
  if ( !from_selected ) {
    error_message = error_message + 'Please choose from budget class.<br>';
  }
  if ( !to_selected ) {
    error_message = error_message + 'Please choose to budget class.<br>';
  }
  if (error_message) {
    $.prompt (error_message);
  }
  else if ( from_selected == to_selected ) {
    $.prompt ( 'From budget class and to budget class must be different.' );
  }
  else {
    $('form[name=masscopy]').submit();
  }
});
$('input,select').bind('focus', function(){ $(this).addClass('hilight'); }).bind('blur', function(){ $(this).removeClass('hilight'); });
$('form select:visible:enabled:first').focus();
</script>
</body>
</html>



