<!---
  * ==================================================================================================== 
  *    @File: /settings/ADL/adl_details.cfm
  *  @Author: Sharon Harris
  *    @Date: April 2021
  * 
  * @Remarks: View the Authorized Distribution Lists details in a popup
  *
  * ==================================================================================================== 
--->
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
	<style>
		div#actions { margin: 5px; }
		div#aggrid { margin: 0 5px; height: 500px; }
	</style>
</head>
<body>
	
    <cfscript>
        adl_cfc = createObject("component", "mvc.models.settings.ADLManager");
        qHeader = adl_cfc.getADLHeader(headerId=url.id);
        qADLDetail = adl_cfc.getADLdetailAsArray(url.id);
    </cfscript>
	
	<cfset request.ag_grid_version = "23">

	<cf_include files="/common_files/ag-Grid.cfm, /common_files/jQuery.cfm, /script/javascript/numeral.min.js, /styles/css-loader.css, /styles/font-awesome.min.css">

	<div class="page_title1">View Authorized Distribution List: <span style="margin-left:10px"><cfoutput>#qHeader.Title#</cfoutput></span></div>
	<div id="actions">
		<button class="button export">Export</button>
	</div>


	<div id="aggrid" class="ag-theme-balham"></div>   



	<cfinclude template="/settings/ADL/adl_detail_grid.cfm">

	<script>
		'use strict';

		<!--- ~~~~~~~~~~ glob = global variables  ~~~~~~~~~~ --->
		let glob = { grid_id: "#aggrid" };

		// Create the Grid as uneditable.  Same function as with the editor
		glob.my_grid = create_detail_grid (glob.grid_id, false);

		glob.my_grid.api.onFilterChanged();		// filter out the incomplete rows


		$("button.export").click(function(e){
            let d           = new Date();
            let date_string = (d.getMonth()+1) + '-' + d.getDate() + '-' + d.getFullYear();
            let file_title  = "ADL Details";
            glob.my_grid.api.exportDataAsExcel( { fileName: file_title + " As Of " + date_string, sheetName: file_title } );
        });
	
	</script>

	<cfinclude template="/common_files/focus.cfm">
</body>
</html>