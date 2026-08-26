<!DOCTYPE html>
<!----------------------------------------------------------------------------------
Name         :  AwayX\Script\javascript\ag-grid\sample2.cfm
Copyright    :  (c) 2018 Blacksmith Applications, Inc.
Created Date :  2/Oct/2018
Created By   :  Sharon Harris
Description  :  Sample page with 3 ag-grid tables
                All 3 are simple, client-side tables.
                Client-side ag-grid requires row-data be provided in a javascript array
                - Example 1 is using hard-coded data to show a simple setup
                - Example 2 is getting data in from a CF array
                - Example 3 is getting data from a CF query
                See "REQUIRED" comments in code below

                To test this, add these 2 lines to your page:
                <cfset request.contractTestID="39010" />    // contract id for data, defaults to 39010
                <a href="/Script/javascript/ag-grid/sample2.cfm">TEST ag-grid examples</a><br>

---------------------------------------------------------------------------------->

<!--- Sample data --->
<cfparam name="request.contractTestID" default="39010"> <!--- there must be a better way to do this... Hard coding default program ID--->
<cfset searchManager  = CreateObject("component","mvc.Models.Program.Search_Program") />
<cfset qTestProgramDetails = searchManager.getProgramDetails(request.contractTestID) /> <!--- get query for data --->
<cfset aTestWorkFlowData = searchManager.getWorkFlowData(request.contractTestID) /> <!--- get array of data --->


<html lang="en">
	<head>
		<title>Sample 2 - Three Simple AG-GRID tables</title>
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">


        <!--- Include ag-grid --->
        <!--- REQUIRED: Define the theme and include the ag-grid files --->
        <cfset request.ag_grid_theme = "ba-ag-theme-balham">    <!--- use the Blacksmith theme --->
        <cf_include files="/common_files/ag-Grid.cfm, /common_files/jQuery.cfm">    <!--- jquery is needed for focus.cfm --->

        <style>
            <!--- REQUIRED: For now, need to update these "ag-" classes, may move to common file --->
            .ag-theme-balham { font-size: 11px; }
            .ag-header { font-size: 11px !important; }
            .ag-theme-balham .ag-cell {
                padding-left: 2px;
                padding-right: 0px;
            }
            .ag-theme-balham .ag-row-selected {
                border-bottom-color: #b5b5b5; /* don't hide lines when selected */
            }
            .ag-theme-balham .ag-selection-checkbox span {
                left: 2px; /* center the checkbox */
            }
        </style>


    </head>
    <body>
        <div style="margin:10px"><br>
            <div class="Title5"> This sample page shows how to include 3 simple Grids on the same page </div><br>

            <div class="Title7"> Sample 1: hard-coded test data</div>
            <!--- REQUIRED: define the placement of the grid in html and give it an ID to refer to, and the class --->
            <div id="example_1_Grid" style="margin-left:25px; height:120px; width:700px" class="ag-theme-balham"></div>


            <cfif isDefined("aTestWorkFlowData") AND ((ArrayLen(aTestWorkFlowData)) NEQ 0)>
                <br>
                <div class="Title7"> Sample 2: getting data from an Array</div>
                <div id="example_2_Grid" style="margin-left:25px; height:150px; width:700px" class="ag-theme-balham"></div>
            </cfif>

            <cfif isDefined("qTestProgramDetails") AND (qTestProgramDetails.Recordcount NEQ 0)>
                <br>
                <div class="Title7"> Sample 3: getting data from a Query</div>
                <div id="example_3_Grid" style="margin-left:25px; height:100px; width:550px" class="ag-theme-balham"></div>
            </cfif>
        </div>

        <!--- Setup Client-side Grids --->
        <script>
            // *************************************************************
            // *******************************************
            // example 1: Simple Hard-coded row data
            var example_1_RowData = [
                {status: "RFA", rfa: "119", program: "[PRG-10000281]", title: "National Pricing List", templateT: "PR00 National Price List", startD: "01/01/2017", volume: 0},
                {status: "WIP", rfa: "121", program: "[PRG-10012273]", title: "Regional Pricing List", templateT: "PR05 Regional Price List", startD: "01/01/2017", volume: 1000},
                {status: "RFA", rfa: "131", program: "[PRG-10222275]", title: "Regional Pricing List", templateT: "PR03 Regional Price List", startD: "01/01/2018", volume: 10000},
                {status: "EXD", rfa: "151", program: "[PRG-10000179]", title: "16 Regional Pricing List", templateT: "PR00 Regional Price List", startD: "01/01/2016", volume: 500},
            ];

            var example_1_ColumnDefs = [
                {headerName: "Status", field: "status",unSortIcon: true, width:50},
                {headerName: "RFA", field: "rfa", unSortIcon: false, width:50},
                {headerName: "Program", field: "program", unSortIcon: true, width:120},
                {headerName: "Title", field: "title", unSortIcon: true, width:160},
                {headerName: "Type", field: "templateT", unSortIcon: true, width:150},
                {headerName: "Start Date", field: "startD", unSortIcon: true, width:80},
                {headerName: "Volume", field: "volume", unSortIcon: true, width:80, type: "numericColumn"}
            ];

             // Init example_1 grid
            var example_1_GridOptions = {
                columnDefs: example_1_ColumnDefs
                ,rowData: example_1_RowData
                ,rowModelType: "clientSide"
            };
            <!--- REQUIRED: setup Grid options, including options, column, and row definitions, and call init with ID --->
            ag_grid_default(example_1_GridOptions);		// set up default features
            init_ag_grid( example_1_GridOptions, "#example_1_Grid", false );  // init example_1 client-side grid



            // *************************************************************
            // *************************************************************
            // example 2: Getting data from an Array
            var example_2_RowData = [{}];
            <cfoutput> #toScript(aTestWorkFlowData, "example_2_RowData")#; </cfoutput>

            var example_2_ColumnDefs = [
                {headerName: "Action", field: "action", width:65},
                {headerName: "Name", field: "name", width:130},
                {headerName: "Position", field: "position", width:125},
                {headerName: "Profile", field: "profiles_desc", width:110},
                {headerName: "Authority Sequence", field: "authority_sequence_name", width:140},
                {headerName: "Date", field: "action_date", width:130}
            ];
            // Init Example 2 grid
            var example_2_GridOptions = {
                columnDefs: example_2_ColumnDefs
                ,rowData: example_2_RowData
                ,rowModelType: "clientSide"
                ,cacheBlockSize: 2000
                ,debug: false
            };
            ag_grid_default(example_2_GridOptions);		// set up default features
            init_ag_grid( example_2_GridOptions, "#example_2_Grid", false );  // init example_2 client-side grid



            // *************************************************************
            // *************************************************************
            // example 3: Getting data from a Query
            // <cfif isDefined("qTestProgramDetails") AND (qTestProgramDetails.Recordcount NEQ 0)>

                var example_3_RowData = <cfoutput>#application.util.query.toAgGridJSON(qTestProgramDetails, 'Contract_Number, Contract_Title, Responsible_Sales_Person, date_span')#</cfoutput>
                var example_3_ColumnDefs = [
                    {headerName: "Number", field: "contract_number", width:120},          <!--- NOTE the lower-case!! --->
                    {headerName: "Title", field: "contract_title", width:150},
                    {headerName: "RSP", field: "responsible_sales_person", width:110},
                    {headerName: "Version Date", field: "date_span", width:150}
                ];
                // Init Example 3 grid
                var example_3_GridOptions = {
                    columnDefs: example_3_ColumnDefs
                    ,rowData: example_3_RowData
                    ,rowModelType: "clientSide"
                    ,cacheBlockSize: 2000
                    ,debug: false
                };
                ag_grid_default(example_3_GridOptions);		// set up default features
                init_ag_grid( example_3_GridOptions, "#example_3_Grid", false );  // init example_3 client-side grid
            // </cfif>
        </script>

	    <cfinclude template="/common_files/focus.cfm">  <!--- Standard BA --->
    </body>
</html>