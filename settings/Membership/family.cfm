<!----
	Name: buying_group.cfm       
	Copyright (c) 2013 Blacksmith Applications, Inc.       
	Description:
	Usage:
---->
<link rel="stylesheet" type="text/css" href="/Common_Files/datatable.css">

<table class="datagrid">
  <thead>
    <th class="header" style="width:100px;"><b>A</b></th>
    <th class="header" style="width:200px;"><b>B</b></th>
    <th class="header" style="width:200px;"><b>C</b></th>
    <th class="header" style="width:110px;"><b>D</b></th>
	<th class="header" style="width:50px;text-align:center;"><b>E</b></th>
    <th class="header" style="width:50px;text-align:center;"><b>F</b></th>
  </thead>
  <tbody>
	    <cfset getdata_message = '<tr><td colspan="100" style="font-size:16px; text-align:center;">Processing..... <img src="/Images/ajax-loader.gif" border=0 height="15" width="15"></td></tr>'>
    <cfoutput>#getdata_message#</cfoutput>
  </tbody>
</table>

<cfinclude template="/Common_Files/jQuery.cfm">
<cfinclude template="/Common_Files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript" src="/Script/javascript/FixedHeader.min.js"></script>

<script>
oTable = $('.datagrid').dataTable( {
      "bServerSide": true
    , "bProcessing": true
    , "bSortClasses": false
	, "bAutoWidth": false
    , "iDisplayLength": 20
    , "oLanguage": {"sSearch": "<b>Search:</b>"} 
    , "sAjaxSource": "ajax/query.cfm"
    , "sDom": "fprti"
    , "aaSorting": []
    , "aoColumns": [	{"bSearchable": true,  "bSortable":false}
			                    ,	{"bSearchable": true, 	"bSortable":true}
			                    ,	{"bSearchable": true, 	"bSortable":true}
			                    ,	{"bSearchable": true, 	"bSortable":true}
			                    ,	{"bSearchable": false, 	"bSortable":false}
			                    ,	{"bSearchable": false, 	"bSortable":false}
				                 ]
} ).fnSetFilteringDelay();
</script>