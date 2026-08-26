<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<!--------------------------------------------------------------------------------------------------------------------------------------------------------
	Template:  \Common_Files\Volume\g500\vfexport.cfm
	Date:      2013 Jan 17
	Author:    Chris Nguyen
		
	Purposes:  Export volume forecast to an Excel file
	
	Remarks:   GM requested all 4 quarters and YTD/Annual to be included in the export. It may take a while to gather all the data and dump it out to an
	           Excel file. Instead of displaying a blank page, I decided to display a "please wait.." message with an animated processing image and call
	           an Ajax component to create the Excel file.
	           
	           GenerateExport() function in vfexport.cfc returns 2 pieces of information in json format:
	            1. ExcelFileName = full path of the export Excel file name
	            2. ExcelFileURL  = Web root relative path of the export Excel file. 
	            
  Required Input:  1. url.l143: VF Level ID (numeric)
	                 2. url.v451: VF plan ID (numeric)            
--------------------------------------------------------------------------------------------------------------------------------------------------------->

<html lang="en">
<head>
 <meta http-equiv="content-type" content="text/html; charset=utf-8">
 <title>Volume Forecast Export</title>
 <style>
 #wait { font-size:1.1em; }
 #ready { display:none; font-size:1.1em; }
 .mediumButton { width:60px; }	
 .action { margin-right:25px; font-weight:bold; font-size:10px; }
	h3 { padding:3px 0 0 0; color:black; margin:0; }
	hr { color:red; }
 </style>
</head>
<cfoutput>

<cfquery name="qVolumePlan" Datasource="#application.datasource#">
	<cfif url.l143 neq 'SUMMARY'>
		SELECT Plan_Name = vf_Plan.vf_Plan_desc
		      ,Forecast_Level
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
		 WHERE vf_Level.vf_level_id = #url.l143#
	<cfelse>
		SELECT Plan_Name = vf_Plan.vf_Plan_desc
		      ,Forecast_Level
		      ,User_Position_Id = ''
					 ,Position_Customer = 'SUMMARY'
			FROM vf_Plan
		 WHERE vf_Plan.vf_Plan_Id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#url.v451#">
	</cfif>
</cfquery>

<body>
<!---<div id="top-bar">
  <cfoutput>
  <h3>#qVolumePlan.Plan_Name# - #qVolumePlan.Position_Customer#</h3>
  </cfoutput>
</div>
--->
<cfoutput><h3>Export for #qVolumePlan.Plan_Name# - #qVolumePlan.Position_Customer#</h3></cfoutput>
<hr/><br/>
<div id="wait">
Exporting volume forecast data, please wait ... <img src="/Images/ajax-loader.gif" border=0 height="15" width="15">
</div>
<div id="ready">
  Your volume forecast export is ready. You may <a target="_blank" id="excel" href="##"><b>open it here</b></a>.<p></p>
  <button id="b_close" class="action mediumButton" onclick="window.close();">Close</button>
</div>

<cfinclude template="/common_files/jQuery.cfm">
<script>
  $.ajax({ url: "ajax/vfexport.cfc"
      ,type: "post"
      ,data: { method: <cfif structKeyExists(url,'ytd')>"generateYTDExport"<cfelse>"generateQtrExport"</cfif>
              ,vfc_plan_id: "#url.v451#"
              ,vfc_level_id: "#url.l143#" }
      ,dataType: "json"
 			,error: function(jqXHR, textStatus, errorThrown) { alert( 'An unexpected problem has occurred, please try again later.' ); window.close(); }
      ,success: function(json) {  
																     $('##wait').hide();
																     $('##excel').attr('href', json.EXCELFILEURL);
																     $('##ready').fadeIn(); 
																   }
    });
</script>
</body>
</html>
</cfoutput>
