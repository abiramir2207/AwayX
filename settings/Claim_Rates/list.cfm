<!DOCTYPE HTML>
<!---------------------------------------------------------------------------------------------------------------------
			Template: \settings\Claim_Rates\list.cfm
			Date:     2013 June
			Author:   Chris Nguyen
			Purpose:  Manage claim rates settings	
----------------------------------------------------------------------------------------------------------------------->
<html>
<head>
	<title>Claim Rates Settings</title>
	<style>
	fieldset { margin:0 5px; padding: 7px; border: 1px solid blue; }
	legend { font: bold 14px sans-serif; color: red; }
	#createNew { margin: 7px 0; }
	a.edit { margin-right: 15px; }
	a.copy { margin-right: 15px; }
	a.disabled { color: gray !important; }
	#defaultSetting { margin: 12px 5px; }
	</style>
	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
</head>

<!--------------------------------------------------------------------------------------------------------------------->

<cfscript>
	vars = {};
	vars.claimRateCFC = createObject("component", "components.programs.claimRates");
	vars.claimRateSettings = vars.claimRateCFC.getClaimRates();
</cfscript>

<!--------------------------------------------------------------------------------------------------------------------->

<body>
<fieldset>
	<legend>Claim Rates Settings</legend>
<div id="createNew">
	<cfoutput><a href="##">#application.util.string.actionLinkFormat("create new setting")#</a></cfoutput>
</div>
<div class="datagridwrapper">
<table id="datagrid" class="datagrid" style='table-layout:fixed'>
	<col width="50%">
  <col width="50%">
	<thead>
		<tr>
		  <th>Setting Name</th>
		  <th>Actions</th>
	  </tr>
	</thead>
<tbody>
	<cfsetting enablecfoutputonly=true>
	<cfloop query="vars.claimRateSettings">    
    <cfoutput><tr class="settingsList" default_setting="#default_setting#"></cfoutput>
      <cfoutput><td><cfif vars.claimRateSettings.default_setting><span style="color:red;font-weight:bold;font-size:12px;">*</span></cfif>&nbsp;#trim(vars.claimRateSettings.config_Name)#</td></cfoutput>
      <cfoutput><td config_id="#vars.claimRateSettings.config_id#" default_setting="#default_setting#"><a href="##" class="edit">#application.util.string.actionLinkFormat("edit")#</a><a href="##" class="copy">#application.util.string.actionLinkFormat("copy")#</a><a href="##" <cfif vars.claimRateSettings.UsageCount neq 0>class="disabled"<cfelse>class="delete"</cfif>>#application.util.string.actionLinkFormat("delete")#</a></td></cfoutput>
    <cfoutput></tr></cfoutput>
  </cfloop>
	<cfsetting enablecfoutputonly=false>
</tbody>
</table>
</div>
<div id="defaultSetting"> <span style="color:red;font-weight:bold;font-size:12px;">*</span> indicates default</div>
</fieldset>

<!------------------------------------------------JAVASCRIPT----------------------------------------------------------->

<cfinclude template="/common_files/jQuery.cfm">
<cfset datatables.version = "1.9.1">
<cfinclude template="/common_files/dataTables.cfm">

<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script>
$(function() {
	var mydatagrid = $('#datagrid').dataTable({
		aaSorting: [ [1, 'asc'] ] 
		,"aoColumns": [ { "bSortable": true  } 
						,{ "bSortable": false } ]
		,"bAutoWidth": false
		,"bPaginate": false
		,"bSortClasses": false
		,"bScrollCollapse": true
		,"sDom": 'fti'
	}).fnSetFilteringDelay();

	$('#datagrid tr').hover (
		function() { $(this).addClass("over"); },
		function() { $(this).removeClass("over"); }
	);  
});

var defaultSetting = 0;

$("#createNew a").on("click", function() { 
	/* If there is an already existing "default" setting */
	if($('.settingsList[default_setting=1]').length){
		defaultSetting = 1;
	}
	window.location.href = "edit.cfm?config_id=-1"+ "&default_setting=" + defaultSetting });
$("a.edit").on("click", function() { 
	/* If the setting is the "default setting" and the only default setting (There should be only one, but checking for it - just in case) */
	if($('.settingsList[default_setting=1]').length == 1 && $(this).parent('td').attr("default_setting") == 1){
		defaultSetting = 1;
	}
	window.location.href = "edit.cfm?config_id=" + $(this).parent('td').attr("config_id") + "&default_setting=" + defaultSetting });
$("a.copy").on("click", function() { 
	/* If there is an already existing "default" setting */
	if($('.settingsList[default_setting=1]').length){
		defaultSetting = 1;
	}
	window.location.href = "copy.cfm?config_id=" + $(this).parent('td').attr("config_id") + "&default_setting=" + defaultSetting });
$("a.delete").on("click", function() { 
	if ( $(this).hasClass("disabled") ) {
		return;
	}
	
	/* If the setting which is to be deleted is the default setting, then do not allow user to delete that setting.
	Here the code also checks to see whether there are more than 1 records which are set as default. (This should not happpen,
	but just in case). If yes, then deleting one of the records which is set as default is fine.
	*/
	if($('.settingsList[default_setting=1]').length == 1 && $(this).parent('td').attr("default_setting") == 1){
		alert('Currently, this is the default setting. Please set another setting as a default before deleting this one.');
	}
	else{
		if ( confirm('Are you sure you want to delete setting ' + '"' + $(this).parents('tr').find('td:first').text() + '"') ) {
			window.location.href = "delete.cfm?config_id=" + $(this).parent('td').attr("config_id");
		}
	}
});
</script>
</body>
</html>
