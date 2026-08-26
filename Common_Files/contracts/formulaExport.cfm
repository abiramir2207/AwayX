<!---
  * ====================================================================================================
  *    @File: Common_Files\contracts\formulaExport.cfm
  *  @Author: Chris Nguyen
  *    @Date: 2022 July 20
  *
  * @Remarks: Formula export for Tyson
  *
  *         http://cnguyen.dynu.net/formula_export
  *
  * ====================================================================================================
--->
<cfoutput>
<cfscript>
    is_debug = 0;

    param name="url.contractNumber" default="PRG-XXXXXXX";

    udf = new components.udf();
    cfc = new components.programs.ProgramManager();
    layout.decimalPrecision = cfc.decimalPrecisionByUOM( 2, 1 );

    cfc = new mvc.Models.Program.FormulaItemLevel();
    // -------------------------------------
    // pull in data to include in the export
    // -------------------------------------
    FPExport = cfc.getFormulaPricingExport( url.id );

    // -------------------------------------------------------------
    // determine the highest number of commodities in the program
    //   for example: item 1 has two commodities,
    //                item 2 has one,
    //                item 3 has seven
    //   the "expected" value in this variable is seven
    // -------------------------------------------------------------
    layout.highest_commodity_count = ( () => { var q = queryExecute( " SELECT MAX( _Number_Of_Comms ) AS _Highest_Commodities_Per_Item
                                                                         FROM FPExport.products ",
                                                                     {}, { dbtype: "query" } );

                                               return q._Highest_Commodities_Per_Item;
                                            } )();


    // ----------------------------------------------------------------------------------------------------
    // figure out the highest number of calculations in all commodity positions
    //     for example: item 1 has two commodities;
    //                          commodity 1 has three calculations
    //                          commodity 2 has seven calculations :: ** (highest by commodity position)
    //
    //                  item 2 has three commodities;
    //                          commodity 1 has five calculations :: ** (highest by commodity position)
    //                          commodity 2 has one calculations
    //                          commodity 3 has four calculations :: ** (highest by commodity position)
    //
    //   the "expected" value in the returned array is [ 5, 7, 4 ]
    // ----------------------------------------------------------------------------------------------------
    layout.calculations_for_commodities = ( () => {
                                                    local.highest_calculations = [];

                                                    // initialize to one calculation per commodity position
                                                    for ( local.count = 1; local.count <= layout.highest_commodity_count; local.count ++ ) {
                                                        local.highest_calculations[ local.count ] = 1;
                                                    }

                                                    local.commodity_position = 1;
                                                    local.current_item  = '';

                                                    // FPExport is a variable defined in this function's caller
                                                    for ( local.product in FPExport.products ) {
                                                        if ( local.current_item is local.product.item ) {
                                                            // same item with a new commodity, so increment the commodity counter
                                                            local.commodity_position ++;
                                                        }
                                                        else {
                                                            // new item, so reset commodity counter to one
                                                            local.commodity_position = 1;
                                                        }
                                                        local.current_item  = local.product.item;

                                                        // keep track of the highest number of calculations in this commodity position
                                                        local.highest_calculations[ local.commodity_position ] = max( local.product._Calculations_Count, local.highest_calculations[ local.commodity_position ] );
                                                    }

                                                    return local.highest_calculations;
                                                  } )();


    // -------------------------------------------------------------
    // figure out the highest number of modifications in all items
    // -------------------------------------------------------------
    layout.highest_modifications_Count = ( () => {
                                                    local.processed = [];
                                                    local.max_number_of_modifications = 0;

                                                    for ( local.modification in FPExport.modifications ) {
                                                        //
                                                        // did this current item gets processed before? if no, then process it
                                                        //
                                                        if ( local.processed.findNoCase( local.modification._BSA_Foodservice_Items_Master_ID ) eq 0 ) {
                                                            local.processed.append( local.modification._BSA_Foodservice_Items_Master_ID );

                                                            local.query = queryExecute( "  SELECT COUNT(*) AS Counter
                                                                                            FROM FPExport.modifications
                                                                                            WHERE _BSA_Foodservice_Items_Master_ID = '#local.modification._BSA_Foodservice_Items_Master_ID#'  ",
                                                                                            {}, { dbtype: "query" } );

                                                            local.max_number_of_modifications = max( local.max_number_of_modifications, local.query.Counter );
                                                        }
                                                    }

                                                    return local.max_number_of_modifications;
                                                } )();

    layout.product_columnList = udf.columnList( FPExport.products );
    layout.product_columns    = getTopColumns( layout.product_columnList, 3 );            // product columns are displayed only once in a row;
                                                                                          // the other commodity columns & component columns are repeated on the same row
    layout.component_columnList = udf.columnList( FPExport.calculations );
    layout.component_columns    = getTopColumns( layout.component_columnList, 4 );        // pull component column names from query

    layout.modification_columnList = udf.columnList( FPExport.modifications );
    layout.modification_columns    = getTopColumns( layout.modification_columnList, 4 );  // pull modification column names from query

    // ---------------------------------------
    // define a storage for the first sheet
    // ---------------------------------------
    sheet_1       = [ [] ];
    sheet_1[ 1 ]  = getColumnHeaders();

    row_number    = 1;          // track Excel row number
    current_item  = '';
    SumWeightedPrice = 0;
    commodity_position = 0;     // track commodity position in an item

    // -----------------------------------
    // build the rows in the body
    // -----------------------------------
    for ( product in FPExport.products ) {
        // ---------------------------------------------
        // same item; increment the commodity position
        // ---------------------------------------------
        if ( current_item is product.item ) {
            commodity_position ++;
        }
        else {
            row_number ++;
            commodities = queryExecute( " SELECT *
                                            FROM FPExport.products
                                            WHERE _BSA_Foodservice_Items_Master_ID = '#product._BSA_Foodservice_Items_Master_ID#'
                                            ", {}, { dbtype: "query" } );

            qSum = queryExecute( " SELECT SUM(_Final_price) AS Final_Price FROM commodities ", {}, { dbtype: "query" } );

            commodity_position = 1;
            current_item       = product.item;
            SumWeightedPrice   = qSum.Final_Price;

            // -----------------------------------
            // add new array element ( new row )
            // -----------------------------------
            sheet_1[ row_number ] = [];
            // fill up all cells with empty strings
            arraySet( sheet_1[ row_number ], 1, layout.column_count, '' );

            // -----------------------------------------------------
            // Individual product columns are displayed here
            // -----------------------------------------------------
            for ( i = 1; i <= 3; i ++ ) {
                sheet_1[ row_number ][ i ] = product[ layout.product_columns[ i ] ];
            }
        }

        // gather calculations for the current commodity
        calculations = udf.queryToArray( queryExecute( " SELECT *
                                                           FROM FPExport.calculations
                                                          WHERE _BSA_Foodservice_Items_Master_ID = '#product._BSA_Foodservice_Items_Master_ID#'
                                                                AND _Program_Formula_Pricing_Rule_Comm_Data_ID = '#product._Program_Formula_Pricing_Rule_Comm_Data_ID#'
                                                        ", {}, { dbtype: "query" } ) );

        // -----------------------------------------------------------
        // Commodities and calculations are displayed in this block
        // -----------------------------------------------------------
        for ( product_column_index = 4; product_column_index <= layout.product_columnList.listLen(); product_column_index ++ ) {
            product_column_name = layout.product_columnList.listGetAt( product_column_index );

            // skipping appropriate columns
            if ( layout.product_columns.findNoCase( product_column_name ) or left( product_column_name, 1 ) is '_' ) {
                continue;
            }

            if ( product_column_name is "Weight" ) {
                sheet_1[ row_number ][ layout.commodities[ commodity_position ].weight ] = product[ product_column_name ];
            }
            else if ( product_column_name is "Final Price" ) {
                sheet_1[ row_number ][ layout.commodities[ commodity_position ].weight + 1 ] = product[ product_column_name ];
            }
            else {
                commodity_column_number = layout.commodities[ commodity_position ].starting_column + product_column_index - 4;
                sheet_1[ row_number ][ commodity_column_number ] = product[ product_column_name ];
            }

            // add component columns right after Start Price
            if ( product_column_name is "Start Price" ) {
                // ------------------------------------------
                // Calculations are displayed in this block
                // ------------------------------------------
                comp_price = 0;
                calc_type  = 0;

                for ( calculation_position = 1; calculation_position <= calculations.len(); calculation_position ++ ) {
                    // calculation type changes, reset component price
                    if ( calc_type neq calculations[ calculation_position ]._Calc_Type ) {
                        comp_price = val( calculations[ calculation_position ]._Start_price );
                    }
                    calc_type = calculations[ calculation_position ]._Calc_Type;

                    for ( column_index = 1; column_index <= layout.component_columns.len(); column_index ++ ) {
                        cell        = '';
                        calculation = calculations[ calculation_position ];
                        component_column_name = layout.component_columns[ column_index ];

                        // if the user selects $ as the UOM for the component entered, do not populate the ‘Component Input’ or ‘Component UOM’ columns
                        if ( component_column_name contains "UOM" ) {
                            cell = ( calculation._UOM is '$' ) ? '' : calculation[ component_column_name ];
                        }
                        // component input column
                        else if ( component_column_name contains "input" ) {
                            cell = ( calculation._UOM is '$' )
                                        ? ''
                                        : numberFormat( calculation[ component_column_name ], layout.decimalPrecision );

                            // total up component price
                            if ( calculation._UOM neq '%' and cell neq '' ) {
                                comp_price += val( cell );
                            }
                        }
                        // component description column
                        else if ( component_column_name contains "desc" ) {
                            cell = calculation[ component_column_name ];
                        }
                        // component final column
                        else {
                            cell = ( calculation._UOM is '%' )
                                        ? ( comp_price * calculation._Amount / 100 )
                                        : calculation._Amount;
                            // total up component price
                            if ( cell neq '' ) {
                                comp_price += cell;
                            }
                            cell = numberFormat( cell, layout.decimalPrecision );
                        }
                        calculation_column_number = layout.commodities[ commodity_position ].calculations[ calculation_position ] + column_index - 1;
                        // add cell to Excel sheet
                        sheet_1[ row_number ][ calculation_column_number ] = cell;
                    }
                }
            };      // if ( product_column_name is "Start Price" )

        }  // --- for ( product_column_index... ) ---



        // ------------------------------------------------------------------------
        // is this the last commodity for the item? if yes, output modifications
        // ------------------------------------------------------------------------
        if ( commodity_position >= commodities.recordCount ) {
            modifications = udf.queryToArray( queryExecute( " SELECT *
                                                                FROM FPExport.modifications
                                                               WHERE _BSA_Foodservice_Items_Master_ID = '#product._BSA_Foodservice_Items_Master_ID#'
                                                            ", {}, { dbtype: "query" } ) );
            ThisPrice = SumWeightedPrice;

            // -------------------------------------------
            // Modifications are displayed in this block
            // -------------------------------------------
            for ( modification_position = 1; modification_position <= modifications.len(); modification_position ++ ) {
                for ( column_index = 1; column_index <= layout.modification_columns.len(); column_index ++ ) {
                    cell         = '';
                    modification = modifications[ modification_position ];
                    modification_column_name = layout.modification_columns[ column_index ];

                    // if the user selects $ as the UOM for the component entered, do not populate the ‘Component Input’ or ‘Component UOM’ columns
                    if ( modification_column_name contains "UOM" ) {
                        cell = ( modification._UOM is '$' ) ? '' : modification[ modification_column_name ];
                    }
                    // modification input column
                    else if ( modification_column_name contains "input" ) {
                        cell = ( modification._UOM is '$' )
                                    ? ''
                                    : numberFormat( modification[ modification_column_name ], layout.decimalPrecision );
                    }
                    // modification description column
                    else if ( modification_column_name contains "desc" ) {
                        cell = modification[ modification_column_name ];
                    }
                    // modification final column
                    else {
                        cell = modification._Amount;
                        if ( modification._UOM is '%' ) {
                            PreviousPrice = modification_position gt 1
                                                ? modifications[ modification_position - 1 ]._Final_price
                                                : 0;
                            cell = PreviousPrice * modification._Amount / 100;
                        }
                        else if ( modification._UOM is '/' ) {
                            cell = ThisPrice / modification._Amount;
                            ThisPrice = cell;
                        }
                        cell = numberFormat( cell, layout.decimalPrecision );
                    }

                    modification_column_number = layout.modifications[ modification_position ] + column_index - 1;
                    // add cell to Excel sheet
                    sheet_1[ row_number ][ modification_column_number ] = cell ;
                }
            }   // for ( modification_position = 1; modification_position <= ... )
        }   // if ( commodity_position >= commodities.recordCount )
    }

    if ( is_debug ) {
        request.senderEmail_address = cgi.server_name contains "cnguyen" ? "admin@trieuhang.com" : "forge@blacksmithapplications.com";
        request.dumpToEmail_address = "cnguyen@blacksmithapplications.com";
        udf.dumpToEmail( layout, sheet_1, FPExport );
    }
    //if margin display is CUSTOM_T then show markets
    if (application.util.query.get_setting('Margin_Display_Style') EQ "CUSTOM_T"){
         sheet_names = [ "Formula Details", "Markets" ];
    }
    else{
         sheet_names = [ "Formula Details" ];
    }
   
    workBook    = spreadSheetNew( sheet_names[ 1 ], "yes" );

    // --------------------------
    // generate the first sheet
    // --------------------------
    spreadSheetAddRows( workBook, sheet_1, 1 );
    formatNumericColumn();
    formatHeaderRow();

    // --------------------------------------
    // add Markets sheet and make it active if margin display is CUSTOM_T
    // --------------------------------------
    if (application.util.query.get_setting('Margin_Display_Style') EQ "CUSTOM_T"){
        spreadSheetCreateSheet( workBook, sheet_names[ 2 ] );
        spreadSheetSetActiveSheet( workBook, sheet_names[ 2 ] );

        if ( FPExport.markets.recordCount ) {
            spreadSheetAddRow( workBook, udf.columnList( FPExport.markets ) );
            formatHeaderRow();
            spreadSheetAddRows( workBook, FPExport.markets );
        }
    }

    savedFileName = getTempDirectory() & createUuid() & ".xlsx";
    spreadSheetSetActiveSheet( workBook, sheet_names[ 1 ] );
    spreadSheetWrite( workBook, savedFileName, true );
</cfscript>
</cfoutput>

<cfheader name="content-disposition" value="attachment; filename=#url.contractNumber# Formula Export.xlsx">
<cfcontent type="application/msexcel" variable="#spreadsheetReadBinary( spreadSheetRead( savedFileName ) )#" reset="true">


<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------- --->

<cfscript>

    function formatNumericColumn() output="false" hint="Format numeric columns on active Excel sheet" {
        local.format = "##0." & repeatString( "0", listLast( layout.decimalPrecision, "." ).len() );

        for ( var local.column in layout.numeric_columns ) {
            spreadSheetFormatColumn( workBook, { bold="false", dataformat:local.format }, local.column );
        }
    }

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------------

    function formatHeaderRow() output="false" hint="Format the first header row on an active Excel sheet" {
        spreadSheetFormatRow( workBook, { bold="true", color="black", textwrap="true", verticalalignment="vertical_center", alignment="center" }, 1 );
    }

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------------

    function getTopColumns( required columns_list, required number_of_top_columns ) output="false"
                        hint="Returns the column names array based on a given number of columns at the top of list" {
        local.top_columns = [];

        for ( var i = 1; i <= arguments.columns_list.listLen(); i ++ ) {
            if ( i <= arguments.number_of_top_columns ) {
                local.top_columns.append( arguments.columns_list.listGetAt( i ) );
            }
        }

        return local.top_columns;
    };

    // ----------------------------------------------------------------------------------------------------------------------------------------------------------
    // figure out the column headers
    //     for example: item 1 has two commodities;
    //                          commodity 1 has three calculations
    //                          commodity 2 has two calculations  :: ** (highest by commodity position)
    //
    //                  item 2 has three commodities;
    //                          commodity 1 has five calculations :: ** (highest by commodity position)
    //                          commodity 2 has one calculations
    //
    //   the "expected" returned array is [ item, commodity1, calculation1, calculation2, calculation3, calculation5, commdity2, calculation1, calculation2 ]
    // ----------------------------------------------------------------------------------------------------------------------------------------------------------
    function getColumnHeaders() output="false" hint="Returns an array of column headers" {
        local.column_counter = 0;
        local.column_headers = [];

        // save columns positions into structure arrays defined in the parent
        // keep track of numeric column positions
        layout.numeric_columns = [];
        // first commodity starts in column 4
        layout.commodities = [ { starting_column: 4 } ];

        // --------------------------------------------------------------
        // build the column headers row with repeated commodities columns
        // --------------------------------------------------------------
        for ( local.commodity_position = 1; local.commodity_position <= layout.highest_commodity_count; local.commodity_position ++ ) {
            for ( local.column_name in layout.product_columnList ) {
                // -------------------------------------
                // skip all columns with a prefix of '_'
                // -------------------------------------
                if ( left( local.column_name, 1 ) is '_' ) {
                    continue;
                }

                // ------------------------------------------------
                // skip item, description on subsequent commodities
                // ------------------------------------------------
                if ( local.commodity_position gt 1 ) {
                    if ( local.column_name is layout.product_columns[ 1 ] ) {
                        layout.commodities.append( { starting_column: local.column_counter + 1 } );
                    }
                    if ( layout.product_columns.findNoCase( local.column_name ) ) {
                        continue;
                    }
                }

                local.column_counter ++;

                // append column header to the header row
                local.column_headers.append( local.column_name );

                if ( local.column_name contains "Price" ) {
                    layout.numeric_columns.append( local.column_counter );
                }

                // -----------------------------------------------
                // add component columns right after Start Price
                // -----------------------------------------------
                if ( local.column_name is "Start Price" ) {
                    layout.commodities[ local.commodity_position ].calculations = [];
                    // -------------------------------------------------------------------------------------------------
                    // add component column sets based on the highest number of calculations in the commodity position
                    // -------------------------------------------------------------------------------------------------
                    for ( var calculation_position = 1; calculation_position <= layout.calculations_for_commodities[ local.commodity_position ]; calculation_position ++ ) {
                        for ( var component_column_name in layout.component_columns ) {
                            local.column_counter ++;

                            // keep track of calculation starting column
                            if ( component_column_name is layout.component_columns[ 1 ] ) {
                                layout.commodities[ local.commodity_position ].calculations.append( local.column_counter );
                            }

                            // split the component column header name onto 2 lines
                            local.column_headers.append( component_column_name.replaceNoCase( "Component", "Component" & chr(10) & chr(13) ) );

                            // component input and final component value
                            if ( component_column_name contains "input" or component_column_name contains "final" ) {
                                layout.numeric_columns.append( local.column_counter );
                            }
                        }
                    }
                }
                else if ( local.column_name is "Weight" ) {
                    layout.commodities[ local.commodity_position ].weight = local.column_counter;
                    layout.numeric_columns.append( local.column_counter );
                }
                ;
            }
        }

        // save modification columns positions into a structure array defined in the parent
        layout.modifications = [];
        // ---------------------------------------------
        // build the column headers for modifications
        // ---------------------------------------------
        for ( local.modification_position = 1; local.modification_position <= layout.highest_modifications_Count; local.modification_position ++ ) {
            for ( var modification_column_name in layout.modification_columns ) {
                local.column_counter ++;

                // keep track of modification starting column
                if ( modification_column_name is layout.modification_columns[ 1 ] ) {
                    layout.modifications.append( local.column_counter );
                }

                // split the modification column header name onto 2 lines
                local.column_headers.append( modification_column_name.replaceNoCase( "Modification", "Modification" & chr(10) & chr(13) ) );

                // modification input and final modification value
                if ( modification_column_name contains "input" or modification_column_name contains "final" ) {
                    layout.numeric_columns.append( local.column_counter );
                }
            }
        }

        // keep track of total number of columns in the export
        layout.column_count = local.column_counter;

        return local.column_headers;
    };

</cfscript>