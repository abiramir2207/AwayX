<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<!---------------------------------------------------------------------------------------------------------------------
			Template: \Common_Files\Volume\g564\productsDetail.cfm
			Date:     Jan 22, 2013
			Author:   Chris Nguyen
			Purpose:  Display products in volume forecast plan

			Notes:    URL parameter names are soundex values so they are not obvious to users (more secure)

			Required Input:  1. url.l143: VF Level ID (numeric)
											 	 2. url.v451: volume Forecast ID (numeric)

----------------------------------------------------------------------------------------------------------------------->
<html>
<head>
	<title>Volume Forecast <cfoutput>#application.returned_customer_setting.item_label#</cfoutput></title>

	<style>
	#top-bar {
	  top: 0px;
	  left: 8px;
	  position: fixed;
	  height: 53px;
	  width: 99%;
	  z-index: 999;
	  overflow: hidden;
	  background:white;
	}
	#content {
	  padding:53px 0 0 0;
	  position:relative;
	  z-index: 1;
	}
	hr { color:red; }
	h3 { margin:0; }
  @media print {
    .noPrint { display:none; }
		#top-bar { position: static; }
  }
  .action { margin-left:15px; }
	</style>
	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
</head>

<cfoutput>
<cfquery name="qVolumePlan" Datasource="#application.datasource#">
	SELECT Plan_Name = vf_Plan.vf_Plan_desc
	      ,Forecast_Level
	      ,User_Position_Id = 0
			  ,Position_Customer = CASE
			                        WHEN vf_Plan.Forecast_Level = 4 THEN bsa_FoodService_Customers.Name + ' (' + bsa_FoodService_Customers.shr_ship_to + ')'
			                        WHEN vf_Level.Service_Market_Id IS NOT NULL THEN Service_Markets.Market_Name
			                        WHEN vf_Level.Service_Region_Id IS NOT NULL
			                             AND vf_Level.Service_Market_Id IS NULL THEN Service_Regions.Region_Name
			                        WHEN vf_Level.Service_Zone_Id IS NOT NULL
			                             AND vf_Level.Service_Region_Id IS NULL
			                             AND vf_Level.Service_Market_Id IS NULL THEN Service_Zones.Zone_Name
			                        ELSE 'HQ'
			                       END
		FROM vf_Level
		     INNER JOIN vf_Plan ON vf_Plan.vf_Plan_Id = vf_Level.vf_Plan_Id
				 LEFT OUTER JOIN Service_Regions ON vf_level.Service_Region_ID  = Service_Regions.Service_Region_ID
				 LEFT OUTER JOIN Service_Markets ON vf_Level.Service_Market_ID = Service_Markets.Service_Market_ID
				 LEFT OUTER JOIN Service_Zones ON vf_Level.Service_Zone_ID = Service_Zones.Service_Zone_ID
				 LEFT JOIN bsa_FoodService_Customers ON vf_Plan.Forecast_Level = 4 AND vf_Level.bsa_FoodService_Customers_Id = bsa_FoodService_Customers.bsa_FoodService_Customers_Id
	 WHERE vf_Level.vf_Level_Id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#url.l143#">
</cfquery>
</cfoutput>

<!--------------------------------------------------------------------------------------------------------------------->
<cfscript>
  application.oController.getObject(path="mvc.models.volumeforecast.vfmanager", name="vfmanager", bReload=1);
  qProducts = application.oVfManager.getProducts( url.v451 );
</cfscript>
<!--------------------------------------------------------------------------------------------------------------------->

<body>
<div id="top-bar">
	<cfoutput><h3>#application.returned_customer_setting.item_label# for #qVolumePlan.Plan_Name# - #qVolumePlan.Position_Customer#</h3></cfoutput>
	<hr/>
	<div class="noPrint" style="margin:3px 0 5px 0;">
	<a href="javascript:window.print()"><cfoutput>#application.util.string.actionLinkFormat("print this page")#</cfoutput></a>
	<a href="javascript:exportAll();"><cfoutput>#application.util.string.actionLinkFormat('export all')#</cfoutput></a><!---D60306 --->
	<a class="action" href="javascript:window.close();"><cfoutput>#application.util.string.actionLinkFormat("close window")#</cfoutput></a>
	</div>
</div>
<div id="content">
<div class="datagridwrapper">
<table id="datagrid" class="datagrid">
<thead>
	<tr>
		<cfoutput>
	  <th>#application.returned_customer_setting.type_group_label_singular#</th>
	  <th>#application.returned_customer_setting.item_label#</th>
	  <th>Description</th>
	  </cfoutput>
  </tr>
</thead>
<tbody>
	<cfsetting enablecfoutputonly=true>
	<cfloop query="qProducts">
    <cfoutput><tr></cfoutput>
      <cfoutput><td>#qProducts.pg_Product_Category_Name#</td></cfoutput>
      <cfoutput><td>#qProducts.Item#</td></cfoutput>
      <cfoutput><td>#qProducts.Description#</td></cfoutput>
    <cfoutput></tr></cfoutput>
  </cfloop>
	<cfsetting enablecfoutputonly=false>
</tbody>
</table>
</div>
</div>
<!---D60306 ::Exporting All Pages from Budgets and Volume Forecasts START --->
<cfset fileName =#application.returned_customer_setting.item_label#&' for '&#qVolumePlan.Plan_Name#>
<cfset fileName = replace(fileName,' ','_','ALL')>
<!---D60306 ::Exporting All Pages from Budgets and Volume Forecasts END --->
<!------------------------------------------------JAVASCRIPT----------------------------------------------------------->
<cfinclude template="/common_files/jQuery.cfm">
<cfinclude template="/common_files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript" src="/Script/javascript/table2csv.js"></script>
<script type="text/javascript">

<cfif qProducts.recordCount gt 250>
	<cfset sDom = 'fiptp'>
<cfelse>
	<cfset sDom = 'fit'>
</cfif>
var mydatagrid = $('#datagrid').dataTable({
     "bAutoWidth": false
    ,"bPaginate": true
    ,"bSortClasses": false
    ,"bScrollCollapse": true
    ,"sDom": <cfoutput>'#sDom#'</cfoutput>
    ,"aaSorting": []    // no initial sorting for better speed
    ,"iDisplayLength": 250
    ,"oLanguage": { "sSearch": "Search:&nbsp;&nbsp;" }
    ,"aoColumns": [   	{"sWidth": "30%"}
                    			, 	{"sWidth": "20%"}
                    			,	{"sWidth": "50%"}
                  			]

  }).fnSetFilteringDelay();

  exportAll = function() {
    const export_src = "/Common_Files/exportAll.cfm?" + "type=productsDetail"
                                              + "&v451=<cfoutput>#url.v451#</cfoutput>"
                                              + "&friendlyFileName=<cfoutput>#urlEncodedFormat(fileName)#</cfoutput>";
    generate_export( export_src );
  }

</script>

</body>
</html>
