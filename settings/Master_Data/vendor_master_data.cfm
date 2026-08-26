<cf_layout selectedIndex=3  layoutID = "masterdata">
<!----
	Name: index.cfm
	Created By:   Anand Rao :: 02/19/2017
	Copyright (c) 2017 Blacksmith Applications, Inc.
 	Description:
	Usage: Used to research Vendors without filters
	
---->
 <cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
 <cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
  <cfset LabelComp 			    = Createobject("component", "components.settings.labels.labels").init() />
  <!--- <cfset qGetOperatorTypeLabel 	  = LabelComp.getGeneralLabels('Operator Type') />
  <cfset qGetOperatorTypeLabel 	  = LabelComp.getGeneralLabels('Operator Type') />
  <cfset qGetLocationTypeLabel 	= LabelComp.getGeneralLabels('Location Type') />
  <cfset qGetOperatorCategoryLabel 	= LabelComp.getGeneralLabels('Operator Category') />
  <cfset qGetOperatorPriorityLabel 	= LabelComp.getGeneralLabels('Operator Priority') /> --->
  <cfset appSettings = genSettingsManager.get()>

	<cfif businessSegManager.isEnabledForVendorType() EQ 1>
		<cfset BSAVariables = "Vendor ID, Vendor Name, Vendor Address, #appSettings.getbusiness_segment_label()#, Active, Deleted">
	<cfelse>
		<cfset BSAVariables = "Vendor ID, Vendor Name, Vendor Address, Active, Deleted">
	</cfif>
 
<link rel="stylesheet" type="text/css" href="/Common_Files/datatable.css">
<br>

<cfif businessSegManager.isEnabledForVendorType() EQ 1>
	<cfset variables.columnSizes = [1.5, 1.5, 2.5, 0.75, 0.75, 0.75]>
<cfelse>
	<cfset variables.columnSizes = [1.5, 1.5, 2.5, 0.75, 0.75]>
</cfif>
<cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( variables.columnSizes )>
<table class="datagrid" style="clear:both;table-layout:fixed;width:100%;">
 <!---  <cfloop array="#variables.columnSizes#" index="variables.columnPercentage">
    <cfoutput><col style="width:#variables.columnPercentage#%"></cfoutput>
  </cfloop>  ---> 
		<!--- <col style = "width:20%">
		<col style = "width:20%">
		<col style = "width:40%">
		<cfif businessSegManager.isEnabledForVendorType() EQ 1>
			<col style = "width:8%">
			<col style = "width:6%">
			<col style = "width:6%">
		<cfelse>
			<col style = "width:10%">
			<col style = "width:10%">
		</cfif>  --->

  <thead>
	<tr>
	<!--- <cfloop from ="1" to="#listlen(BSAVariables)#" index="BSAvar">
	    <th class="header"  align="left"><b><cfoutput>#listgetat(BSAVariables,BSAvar)#</cfoutput></b></th>
	 </cfloop> --->
	 <th align="left"><b>Vendor ID</b></th>
	 <th align="left"><b>Vendor Name</b></th>
	 <th align="left" style="width:120;px"><b>Vendor Address</b></th>
	 <cfif businessSegManager.isEnabledForVendorType() EQ 1>
		<th align="left"><b><cfoutput>#appSettings.getbusiness_segment_label()#</cfoutput></b></th>
		<th align="left"><b>Active</b></th>
	 	<th align="left"><b>Deleted</b></th>	 
	<cfelse>	
		<th align="left"><b>Active</b></th>
	 	<th align="left"><b>Deleted</b></th>	 
	</cfif>
	
	</tr>
  </thead>
  <tbody>
	<cfset getdata_message = '<tr><td colspan="100" style="font-size:16px; text-align:center;">Processing..... <img src="/Images/ajax-loader.gif" border=0 height="15" width="15"></td></tr>'>
    <cfoutput>#getdata_message#</cfoutput>
  </tbody>
</table>

<cfset looplen = #listlen(BSAVariables)#>

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
    , "sAjaxSource": "ajax/vendor_master_data_Ajax.cfm"
  	,"sScrollY": sScrollY
    , "sDom": 'fp<"export">rti'
    ,"bSortCellsTop" : true
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
  window.open( "/Common_Files/exportAll.cfm?" + "type=VendorMasterData"
  				+ "&friendlyFileName=<cfoutput>#urlEncodedFormat('Vendor_Master_data')#</cfoutput>"
              ,"_blank"
              ,"toolbar=no, scrollbars=no, resizable=no, top=10000, left=1, width=1, height=1");
}
	<cfoutput>
	$('div.export').html("&nbsp;&nbsp;<a href='javascript:exportAll();'>#application.util.string.actionLinkFormat('export all')#</a> &nbsp;");
	</cfoutput>
</script>
</cf_layout>