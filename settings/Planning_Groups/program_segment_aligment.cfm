<!---
	Copyright (c)2012 Blacksmith Applications, Inc.       
	Filename:		C:\Work\base\AwayX\settings\Planning_Groups\Accrual_Budget_Duplicates.cfm
	Created:		8/15/2012
	Developer:		drachala
	Description:	<brief description of what the file is used for>
	Usage:			<templates that depend on this file>
	Tip:			<gotchas>
--->

<link rel="stylesheet" type="text/css" href="/Common_Files/datatable.css">
<cfinclude template="/settings/Advanced_Budget/actionFormat.cfm">
<cfparam name="url.category" default="1">
<cfif url.category EQ 1>
<cfset BusinessSegEnabled = isBusinessSegEnabledForProduct>
<cfelseif url.category Eq 2>
<cfset BusinessSegEnabled = isBusinessSegEnabledForDistributor>
</cfif>
<cfoutput>
		<table>
				<tr>
						<td>
								<b>Filter: &nbsp;&nbsp;</b>
						</td>
						<td>
							<select onchange="category(this.value)" style="width:100px; border:none; background-color:##fcf9f9;">
										<option  value="1" <cfif url.category EQ 1>SELECTED</cfif>>#application.returned_customer_setting.Item_Label#</option>
										<option  value="2" <cfif url.category EQ 2>SELECTED</cfif>>#application.returned_customer_setting.distributor_label_singular#</option>
							</select>
						</td>
						<td><a href="Program_Segment_Alignment_Excel.cfm?category=#url.category#&BusinessSegEnabled=#BusinessSegEnabled#">#ActionText("excel")#</a></td>
				</tr>
		</table>
		
<table class="datagrid">
  <thead>
		<th class="header"><b>Program Number</b></th>
		<th class="header"><b>Title</b></th>
		<cfif (isBusinessSegEnabledForProduct AND url.category EQ 1) OR (isBusinessSegEnabledForDistributor AND url.category EQ 2)>
		<th class="header"><b>#appSettings.getbusiness_segment_label()#</b></th>
		</cfif>
		<th class="header"><b>Created Type</b></th>
		<th class="header"><b><cfif #url.category# eq 2>#application.returned_customer_setting.LEGACY_SHIP_TO_LABEL#<cfelse>#application.returned_customer_setting.ITEM_Label#</cfif></b></th>
		<th class="header"><b>Description</b></th>
		<th class="header"><b>Category Name</b></th>		
  </thead>
  <tbody>
    <cfset getdata_message = '<tr><td colspan="100" style="font-size:16px; text-align:center;">Processing..... <img src="/Images/ajax-loader.gif" border=0 height="15" width="15"></td></tr>'>
    #getdata_message#
  </tbody>
</table>
<cfif isBusinessSegEnabledForProduct AND url.category EQ 1 >
<cfset BusinessSegEnabled= #isBusinessSegEnabledForProduct#>
<cfelseif isBusinessSegEnabledForDistributor AND url.category EQ 2>
<cfset BusinessSegEnabled = #isBusinessSegEnabledForDistributor#>
<cfelse>
<cfset BusinessSegEnabled = 0>
</cfif>

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
    , "sAjaxSource": "ajax/Program_Segment_Aligment_Query.cfm?category=#url.category#&BusinessSegEnabled=#BusinessSegEnabled#"
    , "sDom": "fprti" 
    , "aaSorting": []
    , "aoColumns": [  		{"bSearchable": true,  "bSortable":true}
	                   				 ,	{"bSearchable": true, 	"bSortable":true}
	                   				 <cfif isBusinessSegEnabledForProduct OR isBusinessSegEnabledForDistributor>
	                    			,	{"bSearchable": true, 	"bSortable":true}
	                    			</cfif>
	                    			,	{"bSearchable": true, 	"bSortable":true}
	                   				 ,	{"bSearchable": true, 	"bSortable":true}
	                    			,	{"bSearchable": true, 	"bSortable":true}
	                    			,	{"bSearchable": true, 	"bSortable":true}	                    			
	                 ]
} ).fnSetFilteringDelay();

function category(type){
window.location.href = "index.cfm?type=Research&subtype=#FORM.display#&category="+type;
}
</script>
</cfoutput>
