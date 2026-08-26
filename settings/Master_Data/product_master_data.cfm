<cfif isDefined('url.type')>
	<cfset selectedIndex = 4>
	<cfset layoutID = ''>
	<cfset ajaxFile = 'ajax/product_master_data_Ajax.cfm?type=sysPlanningGroups'>
	<cfset functioname = 'ProductSystemMasterData'>
	<cfset filename = urlEncodedFormat('Product_System_Master_Data')>
<cfelse>
	<cfset selectedIndex = 1>
	<cfset layoutID = 'masterdata'>
	<cfset ajaxFile = 'ajax/product_master_data_Ajax.cfm'>
	<cfset functioname = 'ProductMasterData'>
	<cfset filename = urlEncodedFormat('Product_Master_Data')>
</cfif>
<cf_layout selectedIndex=#selectedIndex# layoutID = "#layoutID#">

<!----
	Name: index.cfm
	Created By:   Dinesh Rachala :: 08/03/2016
	Copyright (c) 2016 Blacksmith Applications, Inc.
 	Description:
	Usage: Used to research distributor without filters
---->
	<cfquery NAME="qItemList" datasource="#application.datasource#">
		SELECT PGL.Product_Group_Level_ID,PGL.Group_Internal_Label,PGL.Group_Level_Desc,PGA.Product_Group_Attribute_Table
		,PGA.Product_Group_Attribute_ID_Field,PGA.Product_Group_Attribute_Master_ID_Field,PGA.Product_Group_Attribute_Name_Field,PGA.Product_Group_Attribute_Number_Field
		FROM dbo.Product_Group_Level PGL
		INNER JOIN dbo.Product_Group_Attribute PGA
		ON PGA.Product_Group_Level_ID = PGL.Product_Group_Level_ID
		WHERE PGL.Deleted = 0
		AND PGL.Active = 1
		AND PGL.Is_PG = 0
		ORDER BY PGL.Group_Internal_Label ASC
	</cfquery>


<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />

<!--- Assign column width in percentage --->
<cfset ItemColumnWidth = 9>
<cfset DescriptionColumnWidth = 8>
<cfset GTINColumnWidth = 9>
<cfset ActiveColumnWidth = 5>
<cfset DeletedColumnWidth = 5>

<!--- Get the count of product attribute columns --->
<cfif qItemList.RecordCount>
	<cfset columnCount = ListLen(valueList(qItemList.Group_Internal_Label))>
<cfelse>
	<cfset columnCount = 1>
</cfif>
<!--- Add the "segment" to the count --->
<cfif businessSegManager.isEnabledForProduct()>
	<cfset columnCount = columnCount + 1>
</cfif>

<!--- Get the remaining width percentage to be assigned to the different columns --->
<cfset columnWidthPercent = (100 - (ItemColumnWidth + DescriptionColumnWidth + ActiveColumnWidth + DeletedColumnWidth)) /columnCount>

<link rel="stylesheet" type="text/css" href="/Common_Files/datatable.css">
<br>
<table class="datagrid" style="table-layout:fixed">
<cfif ! isDefined('url.type')>
<cfoutput>
 <col width="#ItemColumnWidth#%"><col width="#DescriptionColumnWidth#%"><col width="#GTINColumnWidth#%"><col width="#ActiveColumnWidth#%"><col width="#DeletedColumnWidth#%">
	<cfloop from="1" to="#columnCount#" index="i">
		<col width="#columnWidthPercent#%">
	</cfloop>
 </cfoutput>
</cfif>
<thead>
 	<tr>
	    <th class="header" rowspan="2" align="left"><b><cfoutput>#application.returned_customer_setting.Item_Label#</cfoutput></b></th>
	    <th class="header" rowspan="2" align="left"><b>Description</b></th>
		<th class="header" rowspan="2" align="left"><b>GTIN</b></th>
	<cfif isDefined('url.type')>
	    <th class="header" rowspan="2" align="left"><b>PG Type Code</b></th>
	    <th class="header" rowspan="2" align="left"><b>PG Type Name</b></th>
	    <th class="header" rowspan="2" align="left"><b>PG Product Category Code</b></th>
	    <th class="header" rowspan="2" align="left"><b>PG Product Category Name</b></th>
	</cfif>
	    <th class="header" rowspan="2" align="left"><b>Active</b></th>
	    <th class="header" rowspan="2" align="left"><b>Deleted</b></th>
		<cfif businessSegManager.isEnabledForProduct()>
			 <th class="header" rowspan="2" align="left"><b><cfoutput>#appSettings.getbusiness_segment_label()#</cfoutput></b></th>
		</cfif>
	  <cfoutput query="qItemList">
	    <th class="header" align="left" title="#Group_Level_Desc#">
		    <cfif len(Group_Level_Desc) LTE 10>
			    <b>#Group_Level_Desc#</b>
		    <cfelse>
		    	<b>#Left(Group_Level_Desc, 10)#..</b>
			</cfif>
		</th>
	  </cfoutput>
	</tr>
	<tr>
	  <cfoutput query="qItemList">
	    <th class="header" align="left" title="#Group_Internal_Label#">
		    <cfset GroupLevelDescInternal = #Replace(Group_Internal_Label,'Distributor','Dist','ALL')#>
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
.word_wrap
{
	word-wrap:break-word;
}
</style>
<script>
var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? .71 : .55) * windowHeight;
oTable = $('.datagrid').dataTable( {
	  "bServerSide": true
	, "bProcessing": true
	, "bSortClasses": false
	, "bAutoWidth": false
	, "iDisplayLength": 100
	, "oLanguage": {"sSearch": "<b>Search:</b>"}
	, "sAjaxSource": "<cfoutput>#ajaxFile#</cfoutput>"
	, "sScrollY": sScrollY
	, "sDom": 'fp<"export">rti'
	, "aaSorting": []
	, "drawCallback": function () { $('.dataTables_scrollBody thead tr').css({ display: 'none' });}// this gets rid of duplicate headers
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
					<cfif businessSegManager.isEnabledForProduct()>
					,	{"bSearchable": true, "bSortable":true}
					</cfif>
					<cfoutput>
					<cfloop from="1" to="#qItemList.RecordCount#" index="listlength">
					,	{"bSearchable": true, "bSortable":true, "sClass":"word_wrap"}
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