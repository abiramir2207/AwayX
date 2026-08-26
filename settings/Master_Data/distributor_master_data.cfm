<cfif isDefined('url.type')>
	<cfset selectedIndex = 4>
	<cfset layoutID = ''>
	<cfset ajaxFile = 'ajax/distributor_master_data_Ajax.cfm?type=sysPlanningGroups'>
	<cfset functioname = 'CustomerSystemMasterData'>
	<cfset filename = urlEncodedFormat('Customer_System_Master_Data')>
<cfelse>
	<cfset selectedIndex = 0>
	<cfset layoutID = 'masterdata'>
	<cfset ajaxFile = 'ajax/distributor_master_data_Ajax.cfm'>
	<cfset functioname = 'CustomerMasterData'>
	<cfset filename = urlEncodedFormat('Customer_Master_Data')>
</cfif>
<cf_layout selectedIndex=#selectedIndex# layoutID = "#layoutID#">
<!----
	Name: index.cfm
	Created By:   Dinesh Rachala :: 08/03/2016
	Copyright (c) 2016 Blacksmith Applications, Inc.
 	Description:
	Usage: Used to research distributor without filters
---->
	<cfquery NAME="qDistList" datasource="#application.datasource#">
		SELECT l.Distributor_Group_Level_ID, l.Group_Level_Desc, l.Distributor_Group_Attribute_Table,
		              l.Distributor_Group_Attribute_ID_Field, l.Distributor_Group_Attribute_Master_ID_Field,
		              l.Distributor_Group_Attribute_Number_Field, l.Distributor_Group_Attribute_Name_Field
		              , l.Group_Level_Desc_Internal
		FROM   Distributor_group_level l
		WHERE  l.Deleted = 0
		AND     l.Distributor_Group_Level_Type_ID NOT IN (23, 24, 25, 26)
		AND     l.Active = 1
		AND     l.Is_PG = 0
		AND     l.Distributor_Group_Attribute_Table IS NOT NULL
	</cfquery>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />

<link rel="stylesheet" type="text/css" href="/Common_Files/datatable.css">
<br>
<table class="datagrid" style='table-layout:fixed'>
<thead>
 	<tr>
	    <th class="header" rowspan="2" align="left"><b><cfoutput>#application.returned_customer_setting.shard_ship_to_label#</cfoutput></b></th>
	    <th class="header" rowspan="2" align="left"><b>Name</b></th>
	    <th class="header" rowspan="2" align="left"><b>Address</b></th>
	<cfif isDefined('url.type')>
	    <th class="header" rowspan="2" align="left"><b>PG Type Code</b></th>
	    <th class="header" rowspan="2" align="left"><b>PG Type Name</b></th>
	    <th class="header" rowspan="2" align="left"><b>PG Customer Category Code</b></th>
	    <th class="header" rowspan="2" align="left"><b>PG Customer Category Name</b></th>
	</cfif>
	    <th class="header" rowspan="2" align="left"><b>Active</b></th>
	    <th class="header" rowspan="2" align="left"><b>Deleted</b></th>
		<cfif businessSegManager.isEnabledForDistributor()>
			 <th class="header" rowspan="2" align="left"><b><cfoutput>#appSettings.getbusiness_segment_label()#</cfoutput></b></th>
		</cfif>
	  <cfoutput query="qDistList">
	    <th class="header" align="left" nowrap title="#Group_Level_Desc#">
		    <cfif len(Group_Level_Desc) LTE 10>
			    <b>#Group_Level_Desc#</b>
		    <cfelse>
		    	<b>#Left(Group_Level_Desc, 10)#..</b>
			</cfif>
		</th>
	  </cfoutput>
	</tr>
	<tr>
	  <cfoutput query="qDistList">
	    <th class="header" align="left" title="#Group_Level_Desc_Internal#">
		    <cfset GroupLevelDescInternal = #Replace(Group_Level_Desc_Internal,'Distributor','Dist','ALL')#>
		    <cfif len(GroupLevelDescInternal) LTE 12>
			    <b>#GroupLevelDescInternal#</b>
		    <cfelse>
		    	<b>#Left(GroupLevelDescInternal, 10)#..</b>
			</cfif>
		</th>
	  </cfoutput>
	</tr>
  </thead>
  <tbody>
	<cfset getdata_message = '<tr><td colspan="100" style="font-size:16px; text-align:center;">Processing..... <img src="/Images/ajax-loader.gif" border=0 height="15" width="15"></td></tr>'>
    <cfoutput>#getdata_message#</cfoutput>
  </tbody>
</table>

<cfinclude template="/Common_Files/jQuery.cfm">
<cfinclude template="/Common_Files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<style>
.dataTables_scrollBody table thead{
    display:none;
}
</style>
<script>
var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? .71 : .55) * windowHeight;
oTable = $('.datagrid').dataTable( {
      "bServerSide": true
    , "bProcessing": true
    , "bSortClasses": false
	, "bAutoWidth": false
    , "iDisplayLength": 500
    , "oLanguage": {"sSearch": "<b>Search:</b>"}
    , "sAjaxSource": "<cfoutput>#ajaxFile#</cfoutput>"
  	,"sScrollY": sScrollY
    , "sDom": 'fp<"export">rti'
    , "aaSorting": []
    , "aoColumns": [
						{"bSearchable": true, "bSortable":true}
					,	{"bSearchable": true, "bSortable":true}
					,	{"bSearchable": true, "bSortable":true}
					<cfif isDefined('url.type')>
					,	{"bSearchable": true, "bSortable":true}
					,	{"bSearchable": true, "bSortable":true}
					,	{"bSearchable": true, "bSortable":true}
					,	{"bSearchable": true, "bSortable":true}
					</cfif>
					,	{"bSearchable": false, "bSortable":true}
					,	{"bSearchable": false, "bSortable":true}
					<cfif businessSegManager.isEnabledForDistributor()>
					,	{"bSearchable": false, "bSortable":true}
					</cfif>
					<cfoutput>
					<cfloop from="1" to="#qDistList.RecordCount#" index="listlength">
					,	{"bSearchable": true,  "bSortable":true}
					</cfloop>
					</cfoutput>
	                 ]
} ).fnSetFilteringDelay();

	exportAll = function() {
		window.open( "/Common_Files/exportAll.cfm?" + "type=<cfoutput>#functioname#</cfoutput>"+ "&friendlyFileName=<cfoutput>#filename#</cfoutput>","_blank","toolbar=no, scrollbars=no, resizable=no, top=10000, left=1, width=1, height=1");
	}
	<cfoutput>
	$('div.export').html("&nbsp;&nbsp;<a href='javascript:exportAll();'>#application.util.string.actionLinkFormat('export all')#</a> &nbsp;");
	</cfoutput>
</script>
</cf_layout>