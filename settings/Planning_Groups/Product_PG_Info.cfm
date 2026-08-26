<!----
	Filename:	C:\Work\Code\base\AwayX\settings\Planning_Groups\Product_PG_Info.cfm
	Created:	10/1/2012
 	Developer:	drachala        
	Copyright (c) 2012 Blacksmith Applications, Inc.       
             
	Description:
		USED TO MAKE AJAX CALLS TO DB FOR TYPE PLANNING GROUPS
	Usage:
		SETTING>>ADMINISTRATOR>>PLANNING GROUPS.
---->
<link rel="stylesheet" type="text/css" href="/Common_Files/datatable.css">
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get(0)>
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset isBusinessSegEnabledForProduct = businessSegManager.isEnabledForProduct() /> 
<cfset PGManager = CreateObject("component", "components.settings.PlanningGroups.PlanningGroupsManager").init() />
<cfset ProductInfo = PGManager.fnGetPGProductCategoryByID('#id#')>

<cfif (isDefined("URL.calledFrom") AND URL.calledFrom EQ "prodAddEdit")>
	<cfset url.sSearch = ''>
	<cfstoredproc procedure="Get_Product_Group_Info_For_PG" datasource="#application.datasource#">
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@PG_Product_Category_ID" value = "#id#" null="no">
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@Keyword" value = "#url.sSearch#" null="no">
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@OrderByField" value="Group_Name" null="no">
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@OrderBy" value="ASC" null="no">
		<cfprocresult name="qryPGProductCategoryDefinitionByID">
	</cfstoredproc>
	<cfif (isDefined("qryPGProductCategoryDefinitionByID") AND qryPGProductCategoryDefinitionByID.RecordCount EQ 0)>
		<cflocation url = "/settings/planning_Groups/dspViewMicroMembers.cfm?Group_ID=#id#&PGType=1&members="> 
		<cfabort>
	</cfif>
</cfif>	
	
<cfoutput>
	
	<div style="width:100%; margin:5px;font-size:14px;">
		<div style="width:48%;float:left;text-align:left;"><b>PG Code:</b> #ProductInfo.PG_Product_Category_Code#</div> 
		<div style="width:48%;float:right;text-align:right;"><b>PG Name:</b> #ProductInfo.PG_Product_Category_Name#</div>
	</div>
	 
	<table class="datagrid">
	  <thead>
	    <th class="header" nowrap><b>Group/#application.returned_customer_setting.Item_Label# Description</b></th>
	    <th class="header" nowrap><b>Group/#application.returned_customer_setting.Item_Label# Number</b></th>
	    <th class="header" nowrap><b>Group/#application.returned_customer_setting.Item_Label# Name</b></th>
		<th class="header" nowrap><b>Include/Exclude</b></th>
		<cfif isBusinessSegEnabledForProduct>
		<th class="header" nowrap><b>#appsettings.Business_Segment_Label#</b></th>
		</cfif>
	  </thead>
	  <tbody>
		<cfset getdata_message = '<tr><td colspan="100" style="font-size:16px; text-align:center;">Processing..... <img src="/Images/ajax-loader.gif" border=0 height="15" width="15"></td></tr>'>
	    #getdata_message#
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
    , "sAjaxSource": "ajax/Product_PG_Info_Query.cfm?ID=<cfoutput>#id#</cfoutput>"
    , "sDom": "fprti"
    , "aaSorting": []
    , "aoColumns": [  		
							{"bSearchable": true,  "bSortable":true}
	                    ,	{"bSearchable": true, 	"bSortable":true}
	                    ,	{"bSearchable": true, 	"bSortable":true}
						,	{"bSearchable": false, 	"bSortable":true}
						<cfif isBusinessSegEnabledForProduct>
						,	{"bSearchable": true, 	"bSortable":true}
						</cfif>
	                           ]
} ).fnSetFilteringDelay();
</script>