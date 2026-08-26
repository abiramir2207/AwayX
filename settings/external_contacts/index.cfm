<!DOCTYPE HTML>
<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\external_contacts\index.cfm
      Date:     2013 December
      Author:   Chris Nguyen
      Purpose:  Manage external contacts

      Notes:

      Required Input:
----------------------------------------------------------------------------------------------------------------------->
<html>
<head>
  <title></title>
  <link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
  <style>
    #mainfieldset { padding:1%; border:1px solid blue; width:98%; }
    #loading { font-weight:bold; color:#D2691E; margin-top:5px; }
    .edit { width:17px; height:17px; cursor:pointer; }
    .center { text-align: center; }   <!--- 52788 --->
  </style>
</head>

<!--------------------------------------------------------------------------------------------------------------------->

<cfscript>
  variables.genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init();
  variables.appSettings = genSettingsManager.get();

  variables.allowToEdit = (variables.appSettings.external_Contacts_Option eq "2" ? 1 : 0);
</cfscript>

<!--------------------------------------------------------------------------------------------------------------------->

<body>
<fieldset id="mainfieldset">
  <legend style="font:bold 14px sans-serif; color:red;"> External Contacts </legend>

  <cfset variables.columnSizes = [4, 4, 4, 4, 4, 4, 4, 1]>
  <cfif variables.allowToEdit>
    <cfset arrayPrepend(variables.columnSizes, 1)>
    <div style="margin:5px 0;display:none;" id="addnew">
      <cfoutput><a href="edit.cfm?contact_id=0">#application.util.string.actionLinkFormat2("add new contact")#</a></cfoutput>
    </div>
  </cfif>

  <div id="loading">Loading data, please wait...</div>

  <cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( variables.columnSizes )>

  <div style="margin:5px 0 0 0;">
  <table id="datagrid" class="datagrid" style='table-layout:fixed;display:none;'>
    <cfloop array="#variables.columnSizes#" index="variables.columnPercentage">
      <cfoutput><col width="#variables.columnPercentage#%"></cfoutput>
    </cfloop>
    <thead>
      <tr>
        <cfif variables.allowToEdit><th> </th></cfif>
        <th>Name</th>
        <th>Company</th>
		    <th>Job Title</th>
        <th>Address</th>
		    <th>Phone/Fax</th>
        <th>Email</th>
        <th>Notes</th>
		    <th>Del</th>
      </tr>
    </thead>
  <tbody>
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
var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? .80 : .65) * windowHeight;
$("#loading").hide();
$(function() {
  $("#addnew").show();
  var mydatagrid = $('#datagrid').show().dataTable({
       aaSorting: []
      ,"bAutoWidth": false
      ,"bPaginate": true
      ,"bProcessing": true
      ,"bServerSide": true
      ,"iDisplayLength": 200
      ,"sDom": 'fptipr'
      ,"sAjaxSource": <cfoutput>"ajax/index.cfm?allowToEdit=#variables.allowToEdit#"</cfoutput>
      ,"bSortClasses": false
      ,"bScrollCollapse": false
      ,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
      ,"sScrollY": sScrollY         <!--- data grid height --->
      ,"aoColumns": [  <cfif variables.allowToEdit>{ "bSortable":false, "sClass":"center" },</cfif>
                       {}
                      ,{}
          					  ,{}
          					  ,{}
                      ,{"bSearchable":false}
                      ,{"bSearchable":false}
                      ,{"bSortable":false, "bSearchable":false}
					            ,{"bSortable":false, "bSearchable":false, "sClass":"center"}
                    ]
    }).fnSetFilteringDelay();

});
$('#datagrid tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });
$('#datagrid tbody').on('click', 'td a, td img.edit', function(e) {
  var contact_id = $(e.target).attr('contactId'), height = 600, width = 800;
  <cfoutput>
  window.location = "#application.HTTPVar##CGI.server_name#/settings/external_contacts/edit.cfm?contact_id=" + contact_id;
  </cfoutput>
  return false;
});
function removed(contractID, name){
  var Delete = confirm("Do you wish to delete '" + name + "' contact?");
  if (Delete){
  		NewWindow("edit.cfm?del146=1&Contact_ID=" + contractID + "&name=" + name, "DeleteExtenalContact", "500", "150", "no", "no");
	}
}
</script>
</body>
</html>