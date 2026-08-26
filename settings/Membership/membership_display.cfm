<!----
	Name: buying_group.cfm       
	Copyright (c) 2013 Blacksmith Applications, Inc.       
	Description:
	Usage:
---->

<cfparam name="url.display_type" default="buyingGroup">
<cfparam name="form.groupid" default="">
<cfparam name="form.shiptoid" default="">
<cfinclude template="/Common_Files/jQuery.cfm">
<cfinclude template="/Common_Files/dataTables.cfm">

<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript" src="/Script/javascript/FixedHeader.min.js"></script>

<style>
	.row_selected {
    background-color: #ECFFB3 !important;
}
</style>

<!--- Header variables are set below based on TYPE(Family/Buying Group/Customer) --->
<cfif url.display_type EQ "1">
		<cfset col1Header = #application.returned_customer_setting.buying_group_label_singular#&"		##">
		<cfset col2Header = #application.returned_customer_setting.buying_group_label_singular#>
<cfelseif url.display_type EQ "2">
			<cfset col1Header = #application.returned_customer_setting.family_name_label_singular#&"		##">
			<cfset col2Header = #application.returned_customer_setting.family_name_label_singular#>
</cfif>

			<cfset col3Header = #application.returned_customer_setting.shard_ship_to_label#&"		##">
			<cfset col4Header = #application.returned_customer_setting.shard_ship_to_label#>

<link rel="stylesheet" type="text/css" href="/Common_Files/datatable.css">
<cfoutput>
<table class="datagrid">
  <thead>
    <th class="header" style="width:100px;"><b>#col1Header#</b></th>
    <th class="header" style="width:200px;"><b>#col2Header#</b></th>
    <th class="header" style="width:200px;"><b>#col3Header#</b></th>
    <th class="header" style="width:110px;"><b>#col4Header#</b></th>
	<th class="header" style="width:150px;text-align:center;"><b>Start Date</b></th>
    <th class="header" style="width:150px;text-align:center;"><b>End Date</b></th>
  </thead>

 <tbody>
	    <cfset getdata_message = '<tr><td colspan="100" style="font-size:16px; text-align:center;">Processing..... <img src="/Images/ajax-loader.gif" border=0 height="15" width="15"></td></tr>'>
    	#getdata_message#
  </tbody>
</table>


<script>
oTable = $('.datagrid').dataTable( {
      "bServerSide": true
    , "bProcessing": true
    , "bSortClasses": false
	, "bAutoWidth": false
    , "iDisplayLength": 20
    , "oLanguage": {"sSearch": "<b>Search:</b>"} 
    , "sAjaxSource": "ajax/membership_query.cfm?groupid=#form.groupid#&shiptoid=#form.shiptoid#&grouptype=#url.display_type#"
    , "sDom": "prti"
    , "aaSorting": []
    , "aoColumns": [	{"bSearchable": true,  "bSortable":true}
			                    ,	{"bSearchable": true, 	"bSortable":true}
			                    ,	{"bSearchable": true, 	"bSortable":true}
			                    ,	{"bSearchable": true, 	"bSortable":true}
			                    ,	{"bSearchable": false, 	"bSortable":true}
			                    ,	{"bSearchable": false, 	"bSortable":true}
				                 ]
} ).fnSetFilteringDelay();


$(document).ready(function() {
		$('.datagrid tbody tr').live( 'click', function(e)  {
				if($('.datagrid tbody tr').hasClass('row_selected')){
					$('.datagrid tbody tr').removeClass('row_selected');
				}
				$(this).addClass('row_selected');        
		});
});
</script>
</cfoutput>
