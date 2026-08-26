<cfif isDefined('url.type')>
  <cfset selectedIndex = 4>
  <cfset layoutID = ''>
  <cfset ajaxFile = 'ajax/Operator_master_data_Ajax.cfm?type=sysPlanningGroups'>
  <cfset functioname = 'OperatorSystemMasterData'>
  <cfset filename = urlEncodedFormat('Operator_System_Master_Data')>
<cfelse>
  <cfset selectedIndex = 2>
  <cfset layoutID = 'masterdata'>
  <cfset ajaxFile = 'ajax/Operator_master_data_Ajax.cfm'>
  <cfset functioname = 'OperatorMasterData'>
  <cfset filename = urlEncodedFormat('Operator_Master_Data')>
</cfif>
<cf_layout selectedIndex=#selectedIndex# layoutID = "#layoutID#">
<!----
	Name: index.cfm
	Created By:   Dinesh Rachala :: 08/03/2016
	Copyright (c) 2016 Blacksmith Applications, Inc.
 	Description:
	Usage: Used to research distributor without filters
---->
  <cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
 <cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
  <cfset LabelComp 			    = Createobject("component", "components.settings.labels.labels").init() />
  <cfset qGetOperatorTypeLabel 	  = LabelComp.getGeneralLabels('Operator Type') />
  <cfset qGetOperatorTypeLabel 	  = LabelComp.getGeneralLabels('Operator Type') />
  <cfset qGetLocationTypeLabel 	= LabelComp.getGeneralLabels('Location Type') />
  <cfset qGetOperatorCategoryLabel 	= LabelComp.getGeneralLabels('Operator Category') />
  <cfset qGetOperatorPriorityLabel 	= LabelComp.getGeneralLabels('Operator Priority') />
  <cfset appSettings = genSettingsManager.get()>

<cfscript>
	if (businessSegManager.isEnabledForOperator()) {
		local.business_segment_label = replace(appSettings.getbusiness_segment_label(), " ", "_");
	}
</cfscript>

<cfif businessSegManager.isEnabledForOperator()>
  <cfif isDefined('url.type')>
    <cfset BSAVariables = "Operator ID, Legacy ID, Operator Name, PG Type Code, PG Type Name, PG Operator Category Code, PG Operator Category Name, Active, Deleted, #local.business_segment_label#,City, State, Location Type, Category, Priority, Type">
    <cfset ClientVariables = "#application.returned_customer_setting.operator_label_singular# ID, Legacy ID, #application.returned_customer_setting.operator_label_singular# Name, <cfif isDefined('url.type')>PG Type Code, PG Type Name, PG Operator Category Code, PG Operator Category Name,</cfif> Active, Deleted, #local.business_segment_label#,City, State, #qGetLocationTypeLabel.GENERAL_LABELS_LABEL#, #qGetOperatorCategoryLabel.GENERAL_LABELS_LABEL#, #qGetOperatorPriorityLabel.GENERAL_LABELS_LABEL#, #qGetOperatorTypeLabel.GENERAL_LABELS_LABEL#">
  <cfelse>
    <cfset BSAVariables = "Operator ID, Legacy ID, Operator Name, Active, Deleted, City, State, Location Type, Category, Priority, Type">
    <cfset ClientVariables = "#application.returned_customer_setting.operator_label_singular# ID, Legacy ID, #application.returned_customer_setting.operator_label_singular# Name, Active, Deleted, City, State, #qGetLocationTypeLabel.GENERAL_LABELS_LABEL#, #qGetOperatorCategoryLabel.GENERAL_LABELS_LABEL#, #qGetOperatorPriorityLabel.GENERAL_LABELS_LABEL#, #qGetOperatorTypeLabel.GENERAL_LABELS_LABEL#">
  </cfif>
<cfelse>
  <cfif isDefined('url.type')>
    <cfset BSAVariables = "Operator ID, Legacy ID, Operator Name, PG Type Code, PG Type Name, PG Operator Category Code, PG Operator Category Name, Active, Deleted, City, State, Location Type, Category, Priority, Type">
    <cfset ClientVariables = "#application.returned_customer_setting.operator_label_singular# ID, Legacy ID, #application.returned_customer_setting.operator_label_singular# Name, <cfif isDefined('url.type')>PG Type Code, PG Type Name, PG Operator Category Code, PG Operator Category Name,</cfif> Active, Deleted, City, State, #qGetLocationTypeLabel.GENERAL_LABELS_LABEL#, #qGetOperatorCategoryLabel.GENERAL_LABELS_LABEL#, #qGetOperatorPriorityLabel.GENERAL_LABELS_LABEL#, #qGetOperatorTypeLabel.GENERAL_LABELS_LABEL#">
  <cfelse>
    <cfset BSAVariables = "Operator ID, Legacy ID, Operator Name, Active, Deleted, City, State, Location Type, Category, Priority, Type">
    <cfset ClientVariables = "#application.returned_customer_setting.operator_label_singular# ID, Legacy ID, #application.returned_customer_setting.operator_label_singular# Name, Active, Deleted, City, State, #qGetLocationTypeLabel.GENERAL_LABELS_LABEL#, #qGetOperatorCategoryLabel.GENERAL_LABELS_LABEL#, #qGetOperatorPriorityLabel.GENERAL_LABELS_LABEL#, #qGetOperatorTypeLabel.GENERAL_LABELS_LABEL#">
  </cfif>
</cfif>

<cfset client_columns = listToArray(ClientVariables)>
<cfset bsa_columns    = listToArray(BSAVariables)>
<cfset header_columns = []>

<cfloop from="1" to="#min(arrayLen(client_columns), arrayLen(bsa_columns))#" index="column_counter">
	<!--- use a single column label if client label is the same as bsa label otherwise combine the two --->
	<cfset arrayAppend(header_columns, trim(client_columns[column_counter]) is trim(bsa_columns[column_counter])
											? trim(client_columns[column_counter])
											: trim(client_columns[column_counter]) & "<br>" & trim(bsa_columns[column_counter]))>
</cfloop>

<link rel="stylesheet" type="text/css" href="/Common_Files/datatable.css">
<br>
<table class="datagrid" style='table-layout:fixed'>
  <thead>
	<tr>
		<cfloop from="1" to="#arrayLen(header_columns)#" index="column_counter">
			<th class="header"><cfoutput>#header_columns[column_counter]#</cfoutput></th>
		</cfloop>
	</tr>
  </thead>
  <tbody>
	<cfset getdata_message = '<tr><td colspan="100" style="font-size:16px; text-align:center;">Processing..... <img src="/Images/ajax-loader.gif" border=0 height="15" width="15"></td></tr>'>
    <cfoutput>#getdata_message#</cfoutput>
  </tbody>
</table>

<cfset looplen = #listlen(ClientVariables)#>

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
              , "sScrollY": sScrollY
              , "sDom": 'fp<"export">rti'
              , "bSortCellsTop" : true
              , "aaSorting": []
              , "aoColumns": [
                <cfoutput>
                  <cfloop from="1" to="#looplen#" index="listlength">
                    <cfif listlength NEQ 1>,</cfif>{"bSearchable": true,  "bSortable":true}
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