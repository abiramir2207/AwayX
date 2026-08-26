
<!---------------------------------------------------------------------------------------------------------------------
      Template: \Settings\Recapture_By_Operator.cfm
      Date:     2013 April
      Author:   Deepa Kunnath
      Purpose:  List operators selected in the rcapture list.

      Remarks:
----------------------------------------------------------------------------------------------------------------------->
<cfparam name="form.save_action" default="0">
<cfparam name="form.Operator_List" default="">

<cfset oRecaptureOperatorList = CreateObject("component", "components.programs.RecaptureOperatorList") />

<cfif form.save_action eq "select_operator">
	
	<cfset oRecaptureOperatorList.addOperators(form.Operator_List, Request.AccessStructure.User_ID) />
	
	<cflocation url="/Settings/Recapture_By_Operator.cfm" addtoken="No" />
	
<cfelseif form.save_action eq "delete_selected">
	
	<cfset oRecaptureOperatorList.deleteOperators(form.Delete_Records, Request.AccessStructure.User_ID) />
	
	<cflocation url="/Settings/Recapture_By_Operator.cfm" addtoken="No" />
	
</cfif>

<cfset OperatorLabel = application.returned_customer_setting.operator_label_singular />
<CFSET PAGETITLE = "Recapture by #LCase(OperatorLabel)#">
<!DOCTYPE HTML>
<cfinclude template="/actionFormat.cfm">
<html>
<head>
  <title>#PAGETITLE#</title>
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
.rowHead {
	font-family: Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
	font-weight: bold;
	color: #000099;
	text-align: left;
	border-bottom-color: #990000;
	background-color: #ffce84;
	
	border-top-width: 1px;
	border-right-width: 1px;
	border-bottom-width: 1px;
	border-left-width: 1px;
	border-top-style: none;
	border-right-style: solid;
	border-bottom-style: solid;
	border-left-style: none;
}
 .colHead {
	border-top-width: 1px;
	border-right-width: 1px;
	border-bottom-width: 1px;
	border-left-width: 1px;
	border-top-style: none;
	border-right-style: solid;
	border-bottom-style: solid;
	border-left-style: none;
}
  </style>
</head>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
	
<cfset qRecaptureOperators = oRecaptureOperatorList.getRecaptureOperatorList() />

<br>
<div>
<cfoutput>
	<a href="##" id="delete_selected">#application.util.string.actionLinkFormat("delete selected")#</a>
	<a href="##" id="select_operator">#application.util.string.actionLinkFormat("select #LCase(application.returned_customer_setting.operator_label_plural)#")#</a>	
</cfoutput>
</div>
<br><br>

<form id="data_form" action="#cgi.script_name#?ReportID=#url.ReportID#" method="post">
<input type="hidden" name="save_action" id="save_action" value="0">
<cfoutput>
<input type="hidden" name="Operator_List" id="Operator_List" value="#ValueList(qRecaptureOperators.BSA_Operator_ID)#">
</cfoutput>

<cfif qRecaptureOperators.recordCount EQ 0>
	No entry data found
<cfelse>


<div id="datagrid2">
<table class="datagrid" id="datagrid"  style='table-layout:fixed'>
<col width="5%"><!--- checkbox --->
<col width="15%"><!--- ID --->
<col width="25%"><!--- Name --->
<col width="15%"><!--- City --->
<col width="10%"><!--- State --->
<col width="15%"><!--- Added By --->
<col width="15%"><!--- Added On --->
<thead>
<cfoutput>
<tr>
    <th align="left"><input type="checkbox" id="select_all"></th>
	<th align="left">#OperatorLabel# ID</th>
    <th align="left">#OperatorLabel# Name</th>
	<th align="left">City</th>
	<th align="left">State</th>
	<th align="left">Added By</th>
	<th align="left">Added On</th>
</tr>
</cfoutput>
</thead>
<tbody>
	<cfoutput query="qRecaptureOperators">
	<tr>
		<td><input type="checkbox" class="cb" name="Delete_Records" value="#BSA_Operator_ID#"></td>
		<td>#Legacy_ID#</td>
		<td>#Operator_Name#</td>
		<td>#Operator_City#</td>
		<td>#Operator_State#</td>
		<td>#Created_By#</td>
		<td>#DateFormat(Created_Date, "mm/dd/yyyy")#</td>
	</tr>
	</cfoutput>
</tbody>
</table>
</div>

</cfif>

</form>


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
    ,"aoColumns": [   {"bSortable":false, "bSearchable":false }
                    , {"bSortable":true, "bSearchable":true}
                    , {"bSortable":true, "bSearchable":true}
                    , {"bSortable":true, "bSearchable":true}
                    , {"bSortable":true, "bSearchable":true}
                    , {"bSortable":true, "bSearchable":true}
                    , {"bSortable":true, "bSearchable":true}
                  ]
  });

<!--- hovering background color switching --->
$('table#datagrid tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });

$('#delete_selected').click(function(e) {
	oTable.fnFilter( '', 1 );
 	oTable.fnFilter( '' );   // display hidden rows while saving, only displayed records will be saved
 	$('#save_action').val("delete_selected");
 	$('#data_form').submit();
});

$('#select_operator').click(function(e) {
	$('#save_action').val("select_operator");
	NewWindow("/billbacks/search_screens/PM_select_operators.cfm?Formname=data_form&SelectSingleSearchResultOnly=0", "operatorwindow", 800, 600, "yes", "yes")
});

$('#select_all').change(function(e){      <!---listen for the change event on the toggle--->
 $('.cb').prop('checked', ( this.checked ) ? true : false );
 e.stopPropagation();
});


</script>
</body>
</html>