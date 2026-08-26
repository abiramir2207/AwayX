<!---------------------------------------------------------------------------------------------------------------------
      Template: \Program_Wizard\index.cfm
      Date:     2013 April
      Author:   Chris Nguyen
      Purpose:  List program templates & allow users to manage them

      Remarks:
----------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML>
<cfinclude template="/get_access_profile.cfm">
<cfset SPA = CreateObject("component","components.user.settingsPanelAccess").init() />
<cfset getSPA = SPA.getSPAccess()>

<cfif getSPA.Program_Wizard_Index EQ 0>
  <cflocation url="/Manufacturers/home.cfm" addtoken="yes">
</cfif>
<cfparam name="FORM.showAllSegments" default="0">
<html>
<head>
  <title>Program Wizard</title>
  <link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
  <style>
  #createnew-div { margin:0px 0; float:right; position:relative; top:5px; }
  #createnew-div select { margin:0 8px 0 0; }
  #datagrid2 { margin-top:-15px; }
  #generictypefilter { width:225px; }
  .datagrid TBODY TR.even { BACKGROUND-COLOR: #eeffee }
  .actiontd { padding-left: 30px; }
  .action { margin:0 8px; }
  .blank { margin-right:55px; }
  .activate { background-color: #FFDEAD; }
  #generictypefilter { width: 98%; }
  </style>
  <cf_include files="/styles/css-loader.css">
</head>
<body>

<cfinclude template="/helpsystem/help_link.cfm">
<cfset PAGETITLE = "PROGRAM TEMPLATES: CREATE & EDIT">
<cfinclude template="/settings/settings_title.cfm">

<cfscript>
	genericTypes = [ 'Distributor Trade/Shelter' ];
	labels = {};
	labels.select_generic_type = 'Select Generic Type';
	templateManager = CreateObject("component", "components.programs.template.TemplateManager").init();
	Lock_Release = templateManager.ReleaseLocks(request.AccessStructure.User_ID);
	appSettings = application.appSettingsGet;

	if ( appSettings.getDisplayProposal() )
		arrayAppend(genericTypes, 'Bid Request');

	if ( application.appSettingsGet.getBrokerage_Functionality_On() )
		arrayAppend(genericTypes, 'Brokerage');

	if ( application.appSettingsGet.getdirectpricingon() )
		arrayAppend(genericTypes, 'Direct Pricing');

	if ( appSettings.getDisplayDistributorOffInvoice() )
		arrayAppend(genericTypes, 'Distributor Off-Invoice');

	arrayAppend(genericTypes, 'Field Execution');
	arrayAppend(genericTypes, 'LSAutoPay');
	arrayAppend(genericTypes, 'Operator Direct or HQ Programs');
	arrayAppend(genericTypes, 'Operator-Deviated Pricing');

	if ( appSettings.getDisplayUSDANOI() )
		arrayAppend(genericTypes, 'USDA NOI');

	// save all general labels into a structure
	general_labels = application.util.query.generalLabel( arrayToList(genericTypes) );
</cfscript>
<form name="dummyform" method="post">
<div id="createnew-div">
<cfif (appSettings.Filter_Business_Segments EQ 1)>
	<b>Show templates for all Segments</b>
	<input type="checkbox" name="showAllSegments" onclick="document.dummyform.submit();" value="1">&nbsp;&nbsp;&nbsp;
</cfif>
	<cfoutput><b>To create a new template: &nbsp;</b>
	<select name="newgenerictype" id="newgenerictype">
		<option>#labels.select_generic_type#</option>
		<cfloop array="#genericTypes#" index="genericType">
			<option>#general_labels[ genericType ]#</option>
		</cfloop>
	</select>
	<a href="##" id="createnew-a">#application.util.string.actionLinkFormat("create")#</a>
	</cfoutput>
</div>
</form>
<div id="datagrid2">
<table class="datagrid" id="datagrid"  style='table-layout:fixed'>
<col width="20%">
<col width="25%">
<col width="35%">
<col width="20%">
<thead>
<tr>
    <cfoutput>
    <th class="columnfilter" align="left">Generic Type<br/><select id="generictypefilter"><option value=''> </option><cfloop array="#genericTypes#" index="genericType"><option>#general_labels[ genericType ]#</option></cfloop></select></th>
    </cfoutput>
    <th align="left">Program Type</th>
    <th align="left">Description</th>
    <th align="left">Actions</th>
</tr>
</thead>
<tbody>
<cfloop array="#genericTypes#" index="genericType">
	<cfset qTemplates = templateManager.getTemplatesByGenericType(genericType, request.AccessStructure.Company_Main_ID) />
  <cfset variables.descriptionDisplayLength = 112>
	<cfoutput query="qTemplates">
		<cfif qTemplates.IS_Locked EQ 1> <cfset Locker = templateManager.GetLockerInfo(qTemplates.Locked_By) /> </cfif>
		<tr>
			<td>#general_labels[ genericType ]#</td>
			<td>#qTemplates.Created_Type#</td>
        	<td>#qTemplates.Program_Description#</td>
			<td>
			    <a href="summary.cfm?Generic_Type=DP&ID=#qTemplates.ProgramControl_Panel_Options_ID#" class="action">#application.util.string.actionLinkFormat("summary")#</a><cfif qTemplates.IS_Locked eq 1><br></cfif>
					 <a href="create_edit.cfm?Generic_Type=DP&ID=#qTemplates.ProgramControl_Panel_Options_ID#&Action=Edit&displayheader=0" class="action"><cfif qTemplates.IS_Locked eq 1><img align="absbottom" src="/images/lock.gif" border="0" title="This template is currently being viewed by #ucase(Locker)#">
					 <BR />
					<span style="color:RGB(255,0,0);font-size:12px;font-weight:bold;text-decoration:none;">Locked By<br />#ucase(Locker)#</span>
					 #application.util.string.actionLinkFormat("read only&nbsp;")#<cfelse> #application.util.string.actionLinkFormat("edit &nbsp;")#</cfif> </a><br>
					 <cfif qTemplates.IS_Locked neq 1>
					 	<a href="delete.cfm?ID=#qTemplates.ProgramControl_Panel_Options_ID#" class="action">#application.util.string.actionLinkFormat("&nbsp;&nbsp; delete &nbsp;&nbsp;")#</a>
					 	<cfif qTemplates.Active eq 1>
					 		<a href="create_edit.cfm?Generic_Type=#genericType#&ID=#qTemplates.ProgramControl_Panel_Options_ID#&Action=Copy&displayheader=0" class="action">#application.util.string.actionLinkFormat("copy")#</a>
					 	</cfif>
            <cfif qTemplates.active eq 0><a href="activate.cfm?ID=#qTemplates.ProgramControl_Panel_Options_ID#" class="action attentionAction">#application.util.string.actionLinkFormat("activate")#</a></cfif>
					 </cfif>
					 <br><a href="SettingDownloadToExcel.cfm?ID=#qTemplates.ProgramControl_Panel_Options_ID#" style="margin:0 8px;">#application.util.string.actionLinkFormat("&nbsp;&nbsp;download settings&nbsp;&nbsp; ")#</a>
			</td>
		</tr>
	</cfoutput>
</cfloop>
</tbody>
</table>
</div>

<cfinclude template="/common_files/jQuery.cfm">
<cfset datatables.version = "1.9.1">
<cfinclude template="/common_files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>

<script>
var oTable = $('table#datagrid').dataTable({
     "bAutoWidth": false
    ,"bPaginate": false
    ,"bSortClasses": false
    ,"bScrollCollapse": true
    ,"sDom": 'fti'
    ,"aoColumns": [   {"bSortable":false, "bSearchable":true }
                    , {"bSortable":true,  "bSearchable":true}
                    , {"bSortable":true,  "bSearchable":true}
                    , {"bSortable":false, "bSearchable":false} ]
  }).fnSetFilteringDelay();
<!--- hovering background color switching --->
$('table#datagrid tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });

$("thead th").each( function ( i ) {
	if ( $(this).hasClass("columnfilter") ) {
      // build select tag dynamically if "addselect" class is found
		  if ( $(this).hasClass("addselect") ) {
				 $(this).html( $(this).html() + '<br/>' + fnCreateSelect( oTable.fnGetColumnData(i) ) );
		  }
      $('select', this).change( function () {
          oTable.fnFilter( $(this).val(), i );
          if ( $(this).val() )
          	$('#newgenerictype').val( $(this).val() );
          else
          	$('#newgenerictype').val( <cfoutput>'#labels.select_generic_type#'</cfoutput> );
      } );
  }
} );

$('#createnew-a').click(function() {
	var genericType = $('#newgenerictype').val();
	if ( genericType !== <cfoutput>'#labels.select_generic_type#'</cfoutput>) {
		window.location = 'create_edit.cfm?Action=Create&Generic_Type=' + genericType;
	}
	else {
		alert( 'Please select a generic type for the new program template first.' );
		return false;
	}
});
$("a.action").click(function(){
	show_loader( "LOADING, PLEASE WAIT..." );
});

</script>
</body>
</html>