<!----
	Filename:	C:\Work\Code\base\AwayX\settings\edit_master_data\index.cfm
	Created:	3/12/2012
 	Developer:	drachala        
	Copyright (c) 2012 Blacksmith Applications, Inc.       
             
	Description:
		USED TO MAKE AJAX CALLS TO DB FOR MASTER DATA
	Usage:
		SETTING>>ADMINISTRATOR>>EDIT_MASTER_DATA.
----><br>
<cfajaximport tags="cfwindow,cfform,CFINPUT-AUTOSUGGEST" >

<cfparam name="info" default= "0">

<!--- D32337: Edit master data -- cant change Type C label.. START --->
<cfquery name="qDistributorsettings" datasource="#application.datasource#" >
	SELECT Group_Level_Desc
	FROM   Distributor_group_level
	WHERE  Distributor_group_attribute_table IN ('Distributor_Type','Distributor_Type_B','Distributor_Type_C','Distributor_Type_H' )
</cfquery>

<cfset labels = arraynew(1)>
<cfloop query="qDistributorsettings">
<cfset arrayappend(labels, #qDistributorsettings.Group_Level_Desc#)>
</cfloop>
<!--- D32337: Edit master data -- cant change Type C label.. END --->

<cfoutput>
	
	<link rel="stylesheet" type="text/css" href="/Common_Files/datatable.css">
	<table class="datagrid">
	  <thead>
	    <th width="8%"><b>Ship To</b></th>
	    <th width="11%"><b>Name</b></th>
		<th width="10%"><b>Address</b></th><!---D39476 :: Edit Master Data - Distributor - add address, city, state --->
		<th width="10%"><b>City</b></th><!---D39476 :: Edit Master Data - Distributor - add address, city, state --->
		<th width="5%"><b>State</b></th><!---D39476 :: Edit Master Data - Distributor - add address, city, state --->
	    <th width="10%"><b>Bracket ID</b></th>
	    <th width="12%"><b>Price List Description</b></th>
		<th width="10%"><b>#labels[1]#</b></th><!--- D32337: Edit master data -- cant change Type C label..  --->
		<th width="10%"><b>#labels[3]#</b></th><!--- D32337: Edit master data -- cant change Type C label..  --->
		<th width="10%"><b>#labels[2]#</b></th><!--- D44724: Billback Approval Automation/Distributor_Type_B selection --->
		<th width="3%"><b>#labels[4]#</b></th><!--- START: D75132: Enhancement ReD Price List & Flag /Anand Rao/28-Nov-2018 --->
	  </thead>
	  <tbody>
	  </tbody>
	</table>

</cfoutput>

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
    , "sAjaxSource": "ajax/Edit_Distributor_Master_Data_Query.cfm"
    , "sDom": "fprti"
    , "aaSorting": []
    , "aoColumns": [  		
							{"bSearchable": true,  	"bSortable":true}
	                    ,	{"bSearchable": true, 	"bSortable":true}
						,	{"bSearchable": true, 	"bSortable":true}
						,	{"bSearchable": true, 	"bSortable":true}
						,	{"bSearchable": false, 	"bSortable":true}
	                    ,	{"bSearchable": true, 	"bSortable":true}
						,	{"bSearchable": true, 	"bSortable":true}
	                    ,	{"bSearchable": true, 	"bSortable":true}
						,	{"bSearchable": true, 	"bSortable":true}
						,	{"bSearchable": true, 	"bSortable":true}
						,	{"bSearchable": false, 	"bSortable":true}
	                 ]
} ).fnSetFilteringDelay();
function navigate(id){
	window.open('Distributor_Master_Edit.cfm?CUSID=' + id, 'EditDistributorMaster', 'width=550,height=350,scrollbars=0');
}
</script>