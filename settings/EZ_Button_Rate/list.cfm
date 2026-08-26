<!DOCTYPE HTML>
<!---------------------------------------------------------------------------------------------------------------------
			Template: \settings\EZ_Button_Rate\list.cfm
			Date:     13-Nov-2015
			Author:   Anand Rao
			Purpose:  Manage EZ Button Rate Settings
----------------------------------------------------------------------------------------------------------------------->
<html>
<head>
	<title>EZ Button Rate Settings</title>
	<style>
	fieldset { margin:0; padding: 1%; border: 1px solid blue; width: 98%; }
	legend { font: bold 14px sans-serif; color: red; }
	#createNew { margin: 7px 0; }
	a.edit { margin-right: 15px; }
	a.copy { margin-right: 15px; }
	a.delete { margin-right: 15px; }
	a.downloadRate { margin-right: 15px; }
	a.disabled { margin-right: 15px; color: gray !important; cursor: default;}
	#datagrid th { text-align: left; }
	</style>
	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
</head>
<!--------------------------------------------------------------------------------------------------------------------->

<cfscript>
	vars = {};
	vars.EZButtonRateCFC = createObject("component", "components.programs.EZButton_ProgramManager");
	vars.EZButtonRateSettings = vars.EZButtonRateCFC.getEZButtonRates();
</cfscript>

<!--------------------------------------------------------------------------------------------------------------------->

<body>
	<!--- <cfinclude template="/actionFormat.cfm"> --->
<fieldset>
	<legend>EZ Button Rate Settings</legend>
<div id="createNew">
	<cfoutput><a href="##">#application.util.string.actionLinkFormat2("create new setting")#</a></cfoutput>
</div>
<div class="datagridwrapper">
<table id="datagrid" class="datagrid" style='table-layout:fixed'>
<col width="30%">
<col width="70%">
	<thead>
		<tr>
		  <th>EZ Button Rate Name</th>
		  <th>Actions</th>
	  </tr>
	</thead>
	<tbody>
		<cfsetting enablecfoutputonly=true>
		<cfloop query="vars.EZButtonRateSettings">
	    	<cfoutput>
				<tr>
	      			<td>#trim(vars.EZButtonRateSettings.EZ_Button_Rate_Title)#</td>
	      			<td EZ_Button_Rate_ID="#vars.EZButtonRateSettings.EZ_Button_Rate_ID#"><a href="##" class="edit">#application.util.string.actionLinkFormat2("edit")#</a><a href="##" class="copy">#application.util.string.actionLinkFormat2("copy")#</a><a href="##" <cfif vars.EZButtonRateSettings.UsageCount neq 0>class="disabled" style="cursor: default;"<cfelse>class="delete"</cfif>>#application.util.string.actionLinkFormat2("delete")#</a><a onClick="NewWindow('/Program_Wizard/Ez_button_rates.cfm?EZButtonRateID=#vars.EZButtonRateSettings.EZ_Button_Rate_ID#', 'EZButtonRates', '600', '400', 'Yes', 'Yes')" style="cursor:pointer" class="downloadRate">
				#application.util.string.actionLinkFormat2("download rates")#
					</a>
					</td>
 				</tr></cfoutput>
	  	</cfloop>
		<cfsetting enablecfoutputonly=false>
	</tbody>
</table>
</div>
</fieldset>

<!------------------------------------------------JAVASCRIPT----------------------------------------------------------->

<cfinclude template="/common_files/jQuery.cfm">
<cfset datatables.version = "1.9.1">
<cfinclude template="/common_files/dataTables.cfm">

<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script>
$(function() {
	var mydatagrid = $('#datagrid').dataTable({
       "aoColumns": [ { "bSortable": true  }
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

$("#createNew a").on("click", function() { window.location.href = "edit.cfm?EZ_Button_Rate_ID=-1"; });
$("a.edit").on("click", function() {
	window.location.href = "edit.cfm?actType=edit&EZ_Button_Rate_ID=" + $(this).parent('td').attr("EZ_Button_Rate_ID"); });
$("a.copy").on("click", function() {
	window.location.href = "edit.cfm?actType=copy&EZ_Button_Rate_ID=" + $(this).parent('td').attr("EZ_Button_Rate_ID"); });
$("a.delete").on("click", function() {
	if ( $(this).hasClass("disabled") ) {
		return;
	}
	if ( confirm('Are you sure you want to delete setting ' + '"' + $(this).parents('tr').find('td:first').text() + '"') ) {
		window.location.href = "delete.cfm?EZ_Button_Rate_ID=" + $(this).parent('td').attr("EZ_Button_Rate_ID");
	}
});
</script>
<cfinclude template="/common_files/focus.cfm">
</body>
</html>
