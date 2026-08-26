<!---
	Copyright (c)2012 Blacksmith Applications, Inc.       
	Filename:		C:\Work\base\AwayX\settings\Planning_Groups\volume_forecast_duplicates.cfm
	Created:		8/14/2012
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
<cfelse>
	<cfset BusinessSegEnabled =0>
</cfif>

<cfoutput>
		<table>
				<tr>
						<td>
								<b>Filter: &nbsp;&nbsp;</b>
						</td>
						<td>
							<select onchange="category(this.value)" style="width:200px; border:none; background-color:##fcf9f9;">
										<option  value="1" <cfif url.category EQ 1>SELECTED</cfif>>#application.returned_customer_setting.Item_Label#</option>
										<option  value="2" <cfif url.category EQ 2>SELECTED</cfif>>#application.returned_customer_setting.distributor_label_singular#</option>
										<option  value="0" <cfif url.category EQ 0>SELECTED</cfif>>Duplicate items across plans</option>
							</select>
						</td>
						<td  align="left"><a href="Volume_Forecast_Duplicates_Excel.cfm?category=#url.category#&BusinessSegEnabled=#BusinessSegEnabled#">#ActionText("excel")#</a></td>
				</tr>
		</table>
		
<table class="datagrid">
  <thead>
	
<cfif url.category EQ 0>
		<th class="header"><b>#application.returned_customer_setting.Shard_Ship_To_Label#</b></th>
		<th class="header"><b>#application.returned_customer_setting.distributor_label_singular#</b></th>
		<th class="header"><b>#application.returned_customer_setting.ITEM_Label#</b></th>
		<th class="header"><b>Description</b></th>
		<th class="header"><b>Planning Group 1</b></th>
		<th class="header"><b>Product PG1</b></th>
		<th class="header"><b>Distributor PG1</b></th>
		<th class="header"><b>Planning Group 2</b></th>
		<th class="header"><b>Product PG2</b></th>
		<th class="header"><b>Distributor PG2</b></th>
<cfelse>
	
		<th class="header"><b>Plan</b></th>
		<th class="header"><b>Class</b></th>
		<cfif (isBusinessSegEnabledForProduct AND url.category EQ 1) OR (isBusinessSegEnabledForDistributor AND url.category EQ 2)>
		<th class="header"><b>#appSettings.getbusiness_segment_label()#</b></th>
		</cfif>
		<th class="header"><b>Planning Group 1</b></th>
		<th class="header"><b>Planning Group 2</b></th>
		<cfif url.category EQ 1>
		<th class="header"><b>#application.returned_customer_setting.ITEM_Label#</b></th>
		<th class="header"><b>Description</b></th>
		<cfelseif url.category EQ 2>
		<th class="header"><b>#application.returned_customer_setting.Shard_Ship_To_Label#</b></th>
		<th class="header"><b>#application.returned_customer_setting.distributor_label_singular#</b></th>		
		</cfif>
</cfif>
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
    , "sAjaxSource": "ajax/Volume_Forecast_Duplicates_Query.cfm?category=#url.category#&BusinessSegEnabled=#BusinessSegEnabled#"
    , "sDom": "fprti" 
    , "aaSorting": []
    , "aoColumns": [  		
				    									{"bSearchable": true,  "bSortable":true}
					                   				 ,	{"bSearchable": true, 	"bSortable":true}
					                   			<cfif url.category NEQ 0>
													 <cfif isBusinessSegEnabledForProduct OR isBusinessSegEnabledForDistributor>
					                    			,	{"bSearchable": true, 	"bSortable":true}
					                    			</cfif>
												</cfif>
					                    			,	{"bSearchable": true, 	"bSortable":true}
					                   				 ,	{"bSearchable": true, 	"bSortable":true}
					                    			,	{"bSearchable": true, 	"bSortable":true}
					                    			,	{"bSearchable": true, 	"bSortable":true}	
    									<cfif url.category EQ 0>
						                    		,	{"bSearchable": true, 	"bSortable":true}
					                   				 ,	{"bSearchable": true, 	"bSortable":true}
					                    			,	{"bSearchable": true, 	"bSortable":true}
					                    			,	{"bSearchable": true, 	"bSortable":true}		                    				
										</cfif>                    			
	                 ]
} ).fnSetFilteringDelay();

function category(type){
window.location.href = "index.cfm?type=Research&subtype=#FORM.display#&category="+type;
}
</script>
</cfoutput>
