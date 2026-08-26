<!DOCTYPE html>
<!----------------------------------------------------------------------------------
Name         :  AwayX\Script\javascript\ag-grid\sample1.cfm
Copyright    :  (c) 2018 Blacksmith Applications, Inc.
Created Date :  1/Oct/2018
Created By   :  Sharon Harris
Description  :  Sample page with a single simple ag-grid table
                Client-side ag-grid requires row-data be provided in a javascript array

                See "REQUIRED" comments in code below

                To test this, add this line to your page:
                <a href="/Script/javascript/ag-grid/sample1.cfm">TEST ag-grid example</a><br>

---------------------------------------------------------------------------------->

<html lang="en">
	<head>
		<title>Sample 1 - Simple AG-GRID</title>
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
            <div class="Title5"> This sample page shows how to include 1 simple Grid on the page </div><br>

            <!--- REQUIRED: define the placement of the grid in html and give it an ID to refer to, and the class --->
            <div id="example_1_Grid" style="margin-left:25px; height:120px; width:700px" class="ag-theme-balham"></div>
        </div>

        <!--- Setup Client-side Grid --->
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
        </script>
        
	    <cfinclude template="/common_files/focus.cfm">  <!--- Standard BA --->
    </body>
</html>