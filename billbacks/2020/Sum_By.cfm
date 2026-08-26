<!---
  * ====================================================================================================
  *    @File: \billbacks\2020\Sum_By.cfm
  *  @Author: Sharon Harris
  *    @Date: Aug 2020
  *
  * @Remarks: Editing billbacks - Popup that shows bilback sum by program, distributor, item.
  *				see: FlexDev\Forge\src\com\Billback\Edit\views\BBEditSum.mxml
  * ====================================================================================================
--->
<cfprocessingdirective pageencoding = "utf-8">
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
</head>
<body>
    <cfsavecontent variable="styles">
        <style>
            * {
                box-sizing: border-box;
                margin-top: 0;
                margin-bottom: 0;
                padding: 0;
            }
            body {
                overflow: hidden;
            }
            #sumby_top, #bottom {
                margin: 10px 0;
            }
            #drpSumBy {
                width: 200px;
            }
        </style>
        <cf_include files="shared_styles.css">
        </cfsavecontent>
    <cfhtmlhead text="#application.util.string.compress( styles )#">
            

    <!--- ~~~~~~~~~~ top section ~~~~~~~~~~~ --->
    <section id="sumby_top">
        <label>Sum-by:</label>
        <select class="single" name="drpSumBy" id="drpSumBy">
            <!--- Options are populated by js from aSumByList --->
        </select> 


    </section>

    <!--- ~~~~~~~~~~  Grid section ~~~~~~~~~~~ --->
    <section class="">

        <div id="shared_grid" style="height:250px;" class="ag-theme-balham">
        </div>
    </section>

    <section id="bottom">
        <button class="button" onclick="window.close()">Close</button>
    </section>


    <cf_include files=#arrayToList( [ "/common_files/jQuery.cfm",
                                    "/common_files/jQueryUI.cfm",
                                    "/script/javascript/numeral.min.js",
                                    "/script/javascript/string_functions.min.js",
                                    "/common_files/ag-grid.cfm"
                                    ] )#>
    <style>
        /* Make the resize lines bigger */
        .ag-header-cell-resize {
            content: '';
            position: absolute;
            top: 0;
            right: 0 !important;
            margin: 0 !important;
            width: 4px !important;			/* so make it wider, change the background color to match the hdr, and add a thin border */
            background: #ffce84;
            border-right: 1px solid #9b9b9c;
            z-index: 0;
        }		
    </style>

    <script>
        'use strict';
        <!--- ~~~~~~~~~~ glob = global variables  ~~~~~~~~~~ --->
        var glob = {
            aSumByList: ["Program", "Distributor", "Item"],
            selectedItem: "Program",
            bb: {}
        };
        // Array indices for aSumByList
        const PROGRAM = 0;
        const DISTRIBUTOR = 1;
        const ITEM = 2;

        // UOM TYpes
        const CASES = 1;

        // Component Types
        const LUMPSUM = 3;

        // Populate the drop-down
        function initDropDown() {
            $('#drpSumBy').empty();
            $.each(glob.aSumByList, function(i, p) {
                $('#drpSumBy').append($('<option></option>').val(p).html(p));
            });
            // Set default to first one
            $('#drpSumBy').val(glob.aSumByList[PROGRAM]);
        }

        // wait for the document to be loaded, otherwise ag-Grid will not find the div in the document.
        document.addEventListener("DOMContentLoaded", function () {
            initDropDown();
            buildGrid();
        });

        function buildGrid() {
            ag_grid_default( glob.shared_grid );
            init_ag_grid( glob.shared_grid, "#shared_grid" );
            getData();
        }
        
        // Initial load of the grid
        function getData(){
                    glob.bb = window.opener.bb;
                    // console.log(glob.bb);
                    calcGridData();
        }

        //  Grid setup
        glob.shared_grid = {
            defaultColDef: {     editable:         false
                                , filter:          false
                                , resizable:       true
                                , sortable:        true
                                , suppressMenu:    true
                                , suppressMovable: false
                                , unSortIcon:      false
            }
            ,columnDefs: [
                {headerName: glob.selectedItem,  field: 'name', width:245},
                {headerName: glob.selectedItem+" #",  field: 'id', width:120},
                {headerName: "Total Volume",  field: 'vol', type:'numericColumn', valueFormatter: volumeFormatter, width:120},
                {headerName: "Total $",  field: 'amt', type:'numericColumn', valueFormatter: currencyFormatter, width:120}
            ]
            ,enableRangeSelection:      false
            ,floatingFilter:            false
            ,pagination:                false
            // ,rowData: 				rowData_Program
            ,rowModelType:              "clientSide"
            ,suppressContextMenu:       true
            ,suppressRowClickSelection: true
            ,pinnedBottomRowData: createFooterData()
        }

        // when user changes drop-down
        $('#drpSumBy').on('change', function (e) {
            let optionSelected = $("option:selected", this);
            glob.selectedItem = this.value;

            // change the grid data and header names
            updateHeaderNames();
            calcGridData();
        });

        // Update the first 2 column header names to match the drop-down item chosen
        // Ex: Program & Program #, Distributor & Distributor #, Item & Item #
        function updateHeaderNames() {
            glob.shared_grid.api.getColumnDef("name").headerName = glob.selectedItem;
            glob.shared_grid.api.getColumnDef("id").headerName = glob.selectedItem+" #";
            glob.shared_grid.api.refreshHeader();
        }


        // ------ Get new grid data based on type chosen
        function calcGridData() {

            var aKeys = new Array();	// list of keys for data in the grid (to check for dups)
            var aRows = new Array();	// Build this Array of rows of data

            // for the total row
            var totalDollars = 0; 
            var totalVolume = 0;

            // for the Lumpsum row on Distributor & Item
            var totalLSDollars = 0; 
            var totalLSVolume = 0;

            //*********** Prg-Dist-Item COLLECT DATA and get TOTALS *********************//
            // loop over bbprgdistitemrate and put the values into the aRows for display
            glob.bb.bbprgdistitemrate.forEach (bbItem => {

                if (bbItem.bbprodrate.itemnumber && bbItem.bbprodrate.volume) {
                    var iPosition;					
                    var itemVol	= 0; 
                    var oRow 	= new Object();		//current row of data being built
                    oRow.name 	= "";
                    oRow.id 	= "";
                    oRow.amt	= 0;
                    oRow.vol	= 0;

                    //get the volume cs/lbs 
                    if (bbItem.bbprodrate.uom.uomid == CASES) {
                        itemVol = parseFloat(bbItem.bbprodrate.volume);
                    } else {
                        itemVol = parseFloat(bbItem.bbprodrate.volume/bbItem.bbprodrate.netweight);
                    }						

                    switch (glob.selectedItem) {

                        // ************ PROGRAM ***********
                        case glob.aSumByList[PROGRAM]:
                            // -- get Program data
                            // If that program already exists in our list, load that data and update the amt and vol
                            iPosition = aKeys.lastIndexOf (bbItem.bbprogram.number);
                            if (iPosition != -1) { // exists
                                oRow = aRows[iPosition];
                            }
                            //add the amount
                            oRow.amt += bbItem.bbprodrate.amount;
                            
                            //add the volume cs/lbs 
                            oRow.vol += itemVol;
                            
                            if (iPosition == -1) {  //doesn't exist
                                oRow.name 	= bbItem.bbprogram.title;
                                oRow.id 	= bbItem.bbprogram.number;
                                aRows.push (oRow);								
                                aKeys.push (bbItem.bbprogram.number);	// save the key for looking up dups
                            }
                            break;

                        // ************ DISTRIBUTOR ***********
                        case glob.aSumByList[DISTRIBUTOR]:
                            // get Distributor data
                            // If that Distributor already exists in our list, load that data and update the amt and vol

                            iPosition = aKeys.lastIndexOf (bbItem.bbdistributor.shipto);
                            if (iPosition != -1) { // exists
                                oRow = aRows[iPosition];
                            }
                            //add the amount
                            oRow.amt += bbItem.bbprodrate.amount;
                            
                            //add the volume cs/lbs 
                            oRow.vol += itemVol;
                            
                            if (iPosition == -1) {  //doesn't exist
                                oRow.name 	= bbItem.bbdistributor.name;
                                oRow.id 	= bbItem.bbdistributor.shipto;
                                aRows.push (oRow);								
                                aKeys.push (bbItem.bbdistributor.shipto);	// save the key for looking up dups
                            }							
                            break;

                        // ***************** ITEM ****************
                        case glob.aSumByList[ITEM]:
                            // Get Item data
                            // If that Item already exists in our list, load that data and update the amt and vol

                            iPosition = aKeys.lastIndexOf (bbItem.bbprodrate.itemnumber);
                            if (iPosition != -1) { // exists
                                oRow = aRows[iPosition];
                            }
                            //add the amount
                            oRow.amt += bbItem.bbprodrate.amount;
                            
                            //add the volume cs/lbs 
                            oRow.vol += itemVol;
                            
                            if (iPosition == -1) {  //doesn't exist
                                oRow.name 	= bbItem.bbprodrate.description;
                                oRow.id 	= bbItem.bbprodrate.itemnumber;
                                aRows.push (oRow);								
                                aKeys.push (bbItem.bbprodrate.itemnumber);	// save the key for looking up dups
                            }							
                            break;
                    }

                    // Update running totals (for bottom row)						
                    totalDollars += bbItem.bbprodrate.amount; 
                    totalVolume += itemVol;
                    
                } //end if valid
            }); // end for each bbItem


            //*********** LUMPSUM CALCULATIONS *********************//
            // loop over lumpsums and sum the values
            glob.bb.bbcomponent.forEach (bbComp => {
                if (bbComp.componenttypeid == LUMPSUM && !isNaN(parseFloat(bbComp.componentamount))) {
                    var iPosition = 0;
                    var oRow 	= new Object();		//current row of LS data being built
                    oRow.name 	= "";
                    oRow.id 	= "";
                    oRow.amt	= 0;
                    oRow.vol	= 0;					

                    // program
                    if (glob.selectedItem == glob.aSumByList[PROGRAM]) {
                        iPosition = aKeys.lastIndexOf (bbComp.programnumber);
                        if (iPosition != -1) { // exists
                            oRow = aRows[iPosition];
                        }
                        //add the amount
                        oRow.amt += bbComp.componentamount;
                        oRow.vol += 0;

                        if (iPosition == -1) {  //doesn't exist
                            oRow.name 	= bbComp.programtitle;
                            oRow.id 	= bbComp.programnumber;
                            aRows.push (oRow);								
                            aKeys.push (bbComp.programnumber);	// save the key for looking up dups
                        }
                    }
                    // Dist or Item
                    else{
                        totalLSDollars 	= totalLSDollars + parseFloat(bbComp.componentamount);
                        totalLSVolume	= 0;
                    }
                    totalDollars += parseFloat(bbComp.componentamount);
                }
            });


            // DISPLAY RESULTS
            // Set the list of data into the grid
            glob.shared_grid.api.setRowData(aRows);

            // Add the bottom rows
            addBottomRows(createFooterData(totalDollars,totalVolume, totalLSDollars,totalLSVolume));
        }



        

        // Add one or two bottom rows: Lump Sum and Total or just Total, pinned to the bottom (so won't sort or scroll)
        function addBottomRows (rows) {
            glob.shared_grid.api.setPinnedBottomRowData(rows);
        }
        // Create the Lump Sum and Total footer rows
        function createFooterData(totalDollars,totalVolume, totalLSDollars,totalLSVolume) {
            var result = [];

            // Program does not get Lump Sum row; Dist and Item do
            if (glob.selectedItem != glob.aSumByList[PROGRAM]) {
                result.push({
                    name: "",
                    id: "**Lump Sum",
                    vol: totalLSVolume,
                    amt: totalLSDollars
                });				
            }

            result.push({
                name: "",
                id: "TOTAL",
                vol: totalVolume,
                amt: totalDollars
            });

            return result;
        }


        // Ex: $1,234.56
        function currencyFormatter(params) {
            if (params.value == '0' || params.value == ''){
                return '$0.00';
            }
            else {
                return numeral(params.value).format('($0,0.00)');
            }
        }
        // Ex: 1,234.56
        function volumeFormatter(params) {
            if (params.value == '0' || params.value == ''){
                return '0.00';
            }
            else {
                return numeral(params.value).format('(0,0.00)');
            }
        }

    </script>

    <cfinclude template="/common_files/focus.cfm">
</body>
</html>