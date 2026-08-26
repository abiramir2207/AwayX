<!----
	Filename:	C:\Work\Code\base\AwayX\settings\Planning_Groups\Type_PG_Info.cfm
	Created:	10/1/2012
 	Developer:	drachala        
	Copyright (c) 2012 Blacksmith Applications, Inc.       
             
	Description:
		USED TO MAKE AJAX CALLS TO DB FOR TYPE PLANNING GROUPS
	Usage:
		SETTING>>ADMINISTRATOR>>PLANNING GROUPS.
---->
<link rel="stylesheet" type="text/css" href="/Common_Files/datatable.css">
	<cfquery name="qryGetPGTypeByID" datasource="#application.datasource#" >
		    SELECT	DISTINCT
			PGT.PG_Type_ID,
			PGT.PG_Type_Code,
	        PGT.PG_Type_Name,
	        PGT.PG_Group_Type, 
			PGT.Is_System  
	        FROM	PG_Type PGT
	        LEFT JOIN PG_Product_Category PGPC 
	        ON		PGPC.Pg_Type_ID = PGT.PG_Type_ID 
	        AND		PGPC.Active = 1 
	        AND		PGPC.Deleted = 0
	        LEFT JOIN PG_Customer_Category PGCC 
	        ON		PGCC.Pg_Type_ID = PGT.PG_Type_ID 
	        AND		PGCC.Active = 1 
	        AND		PGCC.Deleted = 0
	        LEFT JOIN PG_Operator_Category PGOC 
	        ON		PGOC.PG_Type_ID = PGT.PG_Type_ID 
	        AND		PGOC.Active = 1 
	        AND		PGOC.Deleted = 0
	        WHERE	PGT.Active = #url.active# 
	        AND		PGT.Deleted = 0
			AND     PGT.PG_Type_ID = #trim(url.id)#
	</cfquery>
<cfoutput>
	
	<div style="width:100%; margin:5px;font-size:14px;">
		<div style="width:48%;float:left;"><b>PG Code:</b> #qryGetPGTypeByID.PG_Type_Code#</div> 
		<div style="width:48%;float:right;text-align:right;"><b>PG Name:</b> #qryGetPGTypeByID.PG_Type_Name#</div>
	</div>

<table class="datagrid">
  <thead>
    <th class="header"><b>PG Code</b></th>
    <th class="header"><b>PG Name</b></th>
    <th class="header"><b>Include/Exclude</b></th>
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
    , "sAjaxSource": "ajax/Type_PG_Info_Query.cfm?PGGroup=<cfoutput>#group#</cfoutput>&PGTypeID=<cfoutput>#id#</cfoutput>"
    , "sDom": "fprti"
    , "aaSorting": []
    , "aoColumns": [  		
							{"bSearchable": true,  "bSortable":true}
	                    ,	{"bSearchable": true, 	"bSortable":true}
	                    ,	{"bSearchable": false, 	"bSortable":true}
	                           ]
} ).fnSetFilteringDelay();
</script>