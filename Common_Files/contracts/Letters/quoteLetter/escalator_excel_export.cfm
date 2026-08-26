<!---
  * ====================================================================================================
  *    @File: \Common_Files\contracts\Letters\quoteLetter\escalator_excel_export.cfm
  *  @Author: Chris Nguyen
  *    @Date: December 2020
  *
  * @Remarks: Generate escalator excel export for a given program
  *
  * ====================================================================================================
--->
<!--- change 0 to 1 to directly generate excel file from browser URL --->
<cfif 0>
    <cfoutput>
        <h3>#listLast(cgi.script_name,'/')#</h3>    
        <cfset escalator_excel_export( { contract_main_id:66120, export_fulpath:"d:\temp\Escalator Export #timeFormat(now(), 'hh_mm_ss tt')#.xlsx", term:"1% 15 Net 30" } )>
    </cfoutput>
</cfif>



<cfscript>
public function escalator_excel_export( excel ) output="false" {

    // bring in our popular reusable functions
    structAppend( url, createObject( "component", "components.udf" ) );
    
    // place all local variables under this short and sweet 'l' (stands for local) structure
    var l   = {};
    // pull in excel export shared formats
    var fmt = get_export_formats();

    // <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    // <!--- ~~~ gather component functions ~~~ --->
    // <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    structAppend(url, createObject("component", "components.programs.Display_Program.viewprogramtemplateManager"));
    l.rfp_cfc = createObject("component", "mvc.Models.program.RfpManager");

    // <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    // <!--- ~~~~~ gather export content ~~~~~~ --->
    // <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    l.qProgram      = queryExecute( "
                                    SELECT cm.Contract_Number
                                            ,cm.Revision_Version
                                            ,cm.effective_start_date
                                            ,cm.effective_end_date
                                            ,u.name_first + ' ' + u.name_last AS RSP
                                            ,'(' + u.work_phone_1 + ') ' + u.work_phone_2 + '-' + u.work_phone_3 AS work_phone
                                            ,p.profiles_desc
                                    FROM Contract_Main cm
                                            LEFT JOIN _Users u ON u.User_ID = cm.Responsible_User_ID
                                            LEFT JOIN Profiles p on p.Profiles_ID = u.Profiles_ID and p.Deleted = 0
                                    WHERE Contract_Main_ID = ? ", [ arguments.excel.contract_main_id ], {datasource = application.datasource }
                                );
    l.qOperator     = getOperators( arguments.excel.contract_main_id );
    l.qDistributors = getDistributors(arguments.excel.contract_main_id, application.returned_customer_setting.business_segments_on, 0);
    l.qProducts     = l.rfp_cfc.getRfpProductsObject( arguments.excel.contract_main_id );
    l.qCommodoties  = queryExecute( "
                                        SELECT DISTINCT /*R.Contract_Products_Id,*/
                                            /*I.Item,*/
                                            /*PFP.Market_Price_Rate_Orig                    AS [Current_FOB_Price],*/
                                            /*Cast(PFP.Fixed_Price_Value AS DECIMAL(12, 2)) AS [New_FOB_Price],*/
                                            C.Symbol                                      AS [Index_From_Commodity],
                                            ex.Exchange_Detail_Abrev                      AS [Index_Source],
                                            C.Start_Price                                 AS [Current_Benchmark],
                                            C.Comm_End_Price                              AS [New_Benchmark],
                                            C.Comm_End_Price - C.Start_Price              AS [Index_Change],
                                            CASE C.Start_Price
                                                WHEN 0 then 0
                                                ELSE
                                                    CAST(   (((C.Comm_End_Price - C.Start_Price)/ C.Start_Price)    ) AS DECIMAL (10,4)) 
                                                END 
                                            AS Perc_Change
                                            FROM   Program_Formula_Pricing_Rules R
                                            INNER JOIN Program_Formula_Pricing_Rule_Comm_Data C
                                                    ON C.Program_Formula_Pricing_Rule_ID = R.Program_Formula_Pricing_Rule_ID
                                            INNER JOIN Contract_Products CP
                                                    ON CP.Contract_Main_Id = R.Program_Id
                                                        AND CP.Contract_Products_ID = R.Contract_Products_Id
                                            INNER JOIN Program_Fixed_Price_Product_Data PFP
                                                    ON PFP.Contract_Products_ID = CP.Contract_Products_ID
                                            INNER JOIN BSA_Foodservice_Items_Master I
                                                    ON I.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID
                                            INNER JOIN Commodities_Exchange_Detail Ex
                                                    ON Ex.Exchange_Detail_ID = C.Exchange
                                        WHERE  R.Program_ID = ?
                                            AND R.Deleted = 0
                                            AND C.Deleted = 0
                                            AND CP.Deleted = 0
                                            AND PFP.Deleted = 0 
                                            AND CAST(PFP.Fixed_Price_Value as Decimal (12,4)) > 0
                                            ORDER BY Ex.Exchange_Detail_Abrev, C.Symbol                                                
                                            ", [ arguments.excel.contract_main_id ], {datasource = application.datasource }
                                );
    // writeDump(l.qCommodoties);
    l.sheet         = SpreadsheetNew( l.qProgram.Contract_number & " Escalator Export", listLast(arguments.excel.export_fulpath, '.') eq "xlsx" );


    // <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    // <!--- ~~~~~~~~~ Logo/Title go here ~~~~~~~~~~ --->
    // <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    l.title = 2;      // l.title starting row number

    spreadsheetSetRowHeight(l.sheet, 2, 26.25);
    spreadSheetSetColumnWidth(l.sheet, 1, 21.43);
    l.logo_binary = FileReadBinary( expandPath("/images/Logon_Blacksmith/index_huhtamaki_02_small.png") );
    SpreadsheetAddImage(l.sheet, l.logo_binary, 'png', '2,1,3,2');
    spreadsheetSetRowHeight(l.sheet, 2, 26.25);
    spreadSheetSetColumnWidth(l.sheet, 1, 21.43);

    spreadsheetMergeCells(l.sheet, l.title, l.title, 2, 8);
    spreadsheetSetCellValue(l.sheet, "Huhtamaki Escalator / De-Escalator",  l.title, 2);

    // <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    // <!--- ~~~~~~~ Address goes here ~~~~~~~~ --->
    // <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    l.address = 1;    // l.address starting row number
    spreadsheetSetCellValue(l.sheet, "9201 Packaging Dr.", l.address, 9);
    spreadsheetSetCellValue(l.sheet, "DeSoto, KS 66018",   l.address + 1, 9);
    spreadsheetSetCellValue(l.sheet, "(800) 539-3726",     l.address + 2, 9);

    // style title and address
    spreadsheetFormatCell (l.sheet, fmt.title, l.title, 2);
    spreadsheetFormatCellRange (l.sheet, { font:fmt.font_family, fontsize:fmt.font_size }, l.address, 6, l.address + 2, 9);

    // <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    // <!--- ~~~~~~~ Program goes here ~~~~~~~~ --->
    // <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    l.program = 5;    // l.program starting row number
    spreadsheetSetCellValue(l.sheet, "Program ID", l.program, 1);
    spreadsheetSetCellValue(l.sheet, l.qProgram.Contract_number & ( l.qProgram.Revision_Version ? '-' & numberFormat(l.qProgram.Revision_Version, "009") : '' ), l.program, 2);

    spreadsheetSetCellValue(l.sheet, "Operator",   l.program + 1, 1);        spreadsheetSetCellValue(l.sheet, l.qOperator.Operator_Name, l.program + 1, 2);
    spreadsheetSetCellValue(l.sheet, "Terms",      l.program + 2, 1);        spreadsheetSetCellValue(l.sheet, arguments.excel.term,  l.program + 2, 2);
    spreadsheetSetCellValue(l.sheet, "Date",       l.program + 3, 1);        spreadsheetSetCellValue(l.sheet, dateFormat(now(), "m/d/yyyy"),  l.program + 3, 2);

    spreadsheetSetCellValue(l.sheet, "Effective Dates", l.program + 5, 1);   
    if ( isDate( l.qProgram.effective_start_date ) ) {
        spreadsheetSetCellValue(l.sheet, dateFormat(l.qProgram.effective_start_date, "mmmm d, yyyy")
                                            & " to "
                                            & dateFormat(l.qProgram.effective_end_date, "mmmm d, yyyy"),  l.program + 5, 2);
    }

    spreadsheetSetCellValue(l.sheet, "Contact Name",  l.program, 8);       spreadsheetSetCellValue(l.sheet, l.qProgram.RSP,  l.program, 9);
    spreadsheetSetCellValue(l.sheet, "Contact Title", l.program + 1, 8);   spreadsheetSetCellValue(l.sheet, l.qProgram.profiles_desc,  l.program + 1, 9);
    spreadsheetSetCellValue(l.sheet, "Phone Number",  l.program + 2, 8);   spreadsheetSetCellValue(l.sheet, l.qProgram.work_phone,  l.program + 2, 9);


        // <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        // <!--- ~~~~~~~~~~~~ Index Data ~~~~~~~~~~~~~ --->
        // <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

        // style program section
        spreadsheetFormatCellRange(l.sheet, { bold:true, font:fmt.font_family, fontsize:fmt.font_size }, l.program, 1, l.program + 7, 1);
        spreadsheetFormatCellRange(l.sheet, { bold:true, font:fmt.font_family, fontsize:fmt.font_size }, l.program, 5,  l.program + 2, 8);
        spreadsheetFormatCellRange(l.sheet, { font:fmt.font_family, fontsize:fmt.font_size }, l.program, 2, l.program + 7, 2);
        spreadsheetFormatCellRange(l.sheet, { font:fmt.font_family, fontsize:fmt.font_size }, l.program, 9, l.program + 7, 9);

        spreadsheetAddrow(l.sheet, "Index,Index Source,Current Benchmark,New Benchmark,Index Change,% Change", l.program + 8, 2);
        spreadsheetFormatRow (l.sheet, fmt.table_header, l.program + 8);
        spreadSheetSetRowHeight(l.sheet, l.program + 8, 30);

        l.comm_count = 0;
        for (l.this in l.qCommodoties) {
            l.comm_count++;
            l.excel_row_number = l.program + 8 + l.comm_count;    // this is excel row number
            // remove all commas from structure values otherwise the number of output columns will be changed
            spreadsheetAddRow(l.sheet, arrayToList([ replace(l.this.Index_From_Commodity, ",", " ", "all")
                                                    ,replace(l.this.Index_Source, ",", " ", "all")
                                                    ,l.this.Current_Benchmark
                                                    ,l.this.New_BenchMark
                                                    ,l.this.Index_Change
                                                    ,l.this.Perc_Change
                                                    ]),l.excel_row_number,2);
            // use alternate colors for odd/even rows
            l.row_format          = fmt.table_body[ (l.comm_count mod 2) + 1];
            l.dollar_format       = duplicate( l.row_format ).append( fmt.currency );
            l.dollar_format_four       = duplicate( l.row_format ).append( fmt.currencyFour );
            l.indent_format       = duplicate( l.row_format ).append( { indent: 1 } );
            l.percentage_format   = duplicate( l.row_format ).append( fmt.percentageFour );

            spreadsheetFormatRow(l.sheet, l.row_format, l.excel_row_number);

            spreadsheetFormatCell(l.sheet, l.percentage_format, l.excel_row_number, 7);
            spreadsheetFormatCellRange(l.sheet, l.dollar_format_four, l.excel_row_number, 4, l.excel_row_number, 6);
        }
        spreadSheetSetColumnWidth(l.sheet, 3, 14);
        spreadSheetSetColumnWidth(l.sheet, 4, 14);
        spreadSheetSetColumnWidth(l.sheet, 5, 18);
        spreadSheetSetColumnWidth(l.sheet, 6, 14);
        spreadSheetSetColumnWidth(l.sheet, 7, 14);
        spreadSheetSetColumnWidth(l.sheet, 8, 14);
        spreadSheetSetColumnWidth(l.sheet, 9, 14);



    // <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    // <!--- ~~~~~~~ Products go here ~~~~~~~~ --->
    // <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    l.products = l.program + 11 + l.qCommodoties.recordCount;
    l.columns_list = arrayToList( [ "Huhtamaki Item##"
                                    ,"Item Description"
                                    ,"Pack Size"
                                    ,"Case Weight LBs "
                                    ,"Paperboard/Resin LBs#chr(10)# of Material per Case"
                                    ,"Price $ Change Case"
                                    ,"Curr FOB Price/CS"
                                    ,"New FOB Price/CS"
                                    ,"% Change"] );
    spreadsheetAddrow(l.sheet, l.columns_list, l.products, 1);
    // style table header
    spreadSheetSetRowHeight(l.sheet, l.products, 40);
    spreadsheetFormatRow(l.sheet, { verticalalignment:"vertical_center", textwrap:true }, l.products);
    spreadsheetFormatCellRange (l.sheet, fmt.table_header, l.products, 1,  l.products, listLen(l.columns_list));

    // insert rows into table body
    l.product_count = 0;
    for (l.this in l.qProducts) {
        l.product_count++;
        // find the largest fixed component price
        l.component_price = l.this.reduce( function ( result, key, value ) {
            return ( key contains "fixed_price_value_"
                        ? max( result, value )
                        : result );
        }, 0);

        // gather commodities for current product
        //l.qProductCommodoties = queryExecute( " SELECT * FROM l.qCommodoties WHERE Item = '#l.this.item#' ", [], { dbtype = "query" } );
        // writeDump(l.qProductCommodoties);
        //l.productCommodoties  = queryToArray( l.qProductCommodoties );

        // remove all commas from structure values otherwise the number of output columns will be changed
        spreadsheetAddRow(l.sheet, arrayToList([ chr(160) & l.this.item
                                                ,replace(l.this.description, ",", " ", "all")
                                                ,l.this.case_count
                                                ,l.this.gross_weight
                                                ,l.this.net_weight
                                                ,l.component_price - l.this.current_price      
                                                ,l.this.current_price
                                                ,l.component_price      
                                                ,l.this.variance_perc / 100
                                                ]));
        
        l.excel_row_number    = l.products + l.product_count;
        l.row_format          = fmt.table_body[ (l.product_count mod 2) + 1];
        l.benchmark_format    = duplicate( l.row_format ).append( { dataformat: "$##,0.0000;($##,0.0000)" } );
        l.dollar_format       = duplicate( l.row_format ).append( fmt.currency );
        l.gross_weight_format = duplicate( l.row_format ).append( { dataformat: "##,0.000;(##,0.000)" } );
        l.indent_format       = duplicate( l.row_format ).append( { indent: 1 } );
        l.pack_size_format    = duplicate( l.row_format ).append( { dataformat: "0,0" } );
        l.percentage_format   = duplicate( l.row_format ).append( fmt.percentage );

        spreadsheetFormatRow(l.sheet, l.row_format, l.excel_row_number);

        spreadsheetFormatCell(l.sheet, l.pack_size_format, l.excel_row_number, 3);        
        spreadsheetFormatCell(l.sheet, l.gross_weight_format, l.excel_row_number, 4);        
        spreadsheetFormatCell(l.sheet, l.gross_weight_format, l.excel_row_number, 5);        
        spreadsheetFormatCell(l.sheet, l.percentage_format, l.excel_row_number, 9);

        // spreadsheetFormatCell(l.sheet, l.indent_format, l.excel_row_number, 10);
        // spreadsheetFormatCell(l.sheet, l.indent_format, l.excel_row_number, 15);
        // spreadsheetFormatCell(l.sheet, l.indent_format, l.excel_row_number, 20);
        
        spreadsheetFormatCellRange(l.sheet, l.dollar_format, l.excel_row_number, 6, l.excel_row_number, 8);
        // spreadsheetFormatCellRange(l.sheet, l.benchmark_format, l.excel_row_number, 12, l.excel_row_number, 14);
        // spreadsheetFormatCellRange(l.sheet, l.benchmark_format, l.excel_row_number, 17, l.excel_row_number, 19);
        // spreadsheetFormatCellRange(l.sheet, l.benchmark_format, l.excel_row_number, 22, l.excel_row_number, 24);
    }
   
    spreadSheetWrite(l.sheet, "#arguments.excel.export_fulpath#", true);

    return "OK";
}
</cfscript>
