<!---
  * ====================================================================================================
  *    @File: \Common_Files\contracts\Letters\quoteLetter\blended_delivered_freight_matrix_excel_export.cfm
  *  @Author: Chris Nguyen
  *    @Date: December 2020
  *
  * @Remarks: Generate blended delivered freight matrix excel export for a given program
  *
  * ====================================================================================================
--->
<!--- change 0 to 1 to directly generate excel file from browser URL --->
<cfif 0>
    <cfoutput><h3>#listLast(cgi.script_name,'/')#</h3></cfoutput>
    <cfoutput>
        <cfset ids = [ 66191, 66183 ]>
        <cfset blended_delivered_freight_matrix_excel_export( { contract_main_id:ids[1], export_fulpath:"d:\temp\Blended Export #timeFormat(now(), 'hh_mm_ss tt')#.xlsx", term:"1% 15 Net 30" } )>
    </cfoutput>
</cfif>


<cffunction name="blended_delivered_freight_matrix_excel_export" output="false">
    <cfargument name="excel" required="true" hint='{ contract_main_id:66100, export_fulpath:"d:\temp\blended.xlsx", term:"1% 15 Net 30" }'>

    <cfscript>
        // bring in our popular reusable functions
        structAppend( url, createObject( "component", "components.udf" ) );
        
        // place all local variables under this short and sweet 'l' (stands for local) structure
        var l   = {};
        // pull excel export shared formats
        var fmt = get_export_formats();

        // <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        // <!--- ~~~ gather component functions ~~~ --->
        // <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        structAppend(url, createObject("component", "components.programs.Display_Program.viewprogramtemplateManager"));


        // <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        // <!--- ~~~~~ gather export content ~~~~~~ --->
        // <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        l.qOperator = getOperators( arguments.excel.contract_main_id );
        l.qProgram  = queryExecute( "
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
                                        WHERE Contract_Main_ID = ? "
                                    ,[ arguments.excel.contract_main_id ] ,{datasource = application.datasource }
                                    );
        l.qProducts = queryExecute("
                                    SELECT C.Name                                                                                AS Distributor
                                    , C.Ship_To                                                                             AS [Ship_to_Number]
                                    , C.City                                                                                AS [Ship_To_City]
                                    , C.State                                                                               AS [Ship_to_state]
                                    , C.ZipCode                                                                             AS Ship_To_ZipCode
                                    , CD.Program_Weight                                                                     AS Percent_Volume
                                    , WM.Warehouse_Name
                                    , WM.Warehouse_Code
                                    , wm.Warehouse_City                                                                     AS [Ship_From_City]
                                    , wm.Warehouse_State                                                                    AS [Ship_From_State]
                                    , wm.Warehouse_Zip                                                                      AS Ship_From_ZipCode
                                    , '(' + Cast(WM.Warehouse_Code AS VARCHAR(25)) + ') ' + WM.Warehouse_Name               AS Facility_desc
                                    , I.Item
                                    , I.Description
                                    , ISNULL (ISNULL (NULLIF(Cast(CP.case_cube AS DECIMAL(14, 2)), 0.0), i.Case_Count), 0)  AS Case_cube
                                    , ISNULL (ISNULL (NULLIF(Cast(CP.case_count AS DECIMAL(14, 2)), 0.0), i.PACK_QTY), 0.0) AS Case_count
                                    , I.Cases_Pallet
                                    , I.Gross_Weight
                                    , ISNULL (ISNULL (NULLIF(cast(CP.case_count AS DECIMAL(14, 2)), 0.0), i.PACK_QTY), 0.0) AS Case_pack
                                    , PFFR.OBF_Rate + PFFR.Freight_Upcharge_Amount + PFFR.Input_Adjustment_Amount           AS Freight_per_CS
                                    , PFFR.FOB_Price
                                    , PFFR.Delivered_Price
                                    , PFFR.OBF_Rate
                                    , PFFR.Freight_Upcharge_Amount
                                    , PFFR.Input_Adjustment_Amount
                                    , CASE PFFR.Item_Bracket_ID
                                        WHEN 1 THEN
                                            'TL'
                                        WHEN 2 THEN
                                            'LTL'
                                        ELSE 
                                            ''
                                      END                                                                                   AS MODE
                                    , OBF.Order_Average_Pallet
                                    , OBF.Freight_Rate_Per_Volume
                                    , PFFR.Total_Freight_CS
                                FROM Program_Fixed_Freight_Rates            PFFR
                                    INNER JOIN Contract_Distributors        CD
                                        ON CD.Contract_Main_ID = PFFR.Program_id
                                            AND CD.BSA_Foodservice_Customers_ID = PFFR.Customer_id
                                            AND CD.Deleted = 0
                                    INNER JOIN BSA_Foodservice_Customers    C
                                        ON C.BSA_Foodservice_Customers_ID = PFFR.Customer_Id
                                            AND C.Deleted = 0
                                    INNER JOIN BSA_Foodservice_Items_Master I
                                        ON I.BSA_Foodservice_Items_Master_ID = PFFR.Product_Id
                                    LEFT JOIN Warehouse_Master             WM
                                        ON WM.Warehouse_Master_ID = PFFR.Warehouse_Master_Id
                                            AND WM.Deleted = 0
                                    INNER JOIN Contract_products            CP
                                        ON CP.Contract_Products_ID = PFFR.Contract_Products_ID
                                            AND CP.Deleted = 0
                                    LEFT JOIN Outbound_Freight             OBF
                                        ON OBF.BSA_Foodservice_Customers_ID = C.BSA_Foodservice_Customers_ID
                                            AND OBF.Warehouse_Master_ID = WM.Warehouse_Master_ID
                                            AND OBF.Deleted = 0
                                            AND OBF.Stock_Item_Bracket = PFFR.Item_Bracket_ID
                                WHERE Program_Id = ?
                                    AND PFFR.Deleted = 0
                                ORDER BY Distributor
                                    , Item


                                        "
                                ,[ arguments.excel.contract_main_id ], {datasource = application.datasource } );
        // writeDump(l.qProducts);
        l.sheet = SpreadsheetNew( l.qProgram.Contract_number & " Blended Export", listLast(arguments.excel.export_fulpath, '.') eq "xlsx" );

        // <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        // <!--- ~~~~~~~~~ Logo/Title go here ~~~~~~~~~~ --->
        // <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        l.title = 2;      // l.title starting row number
        spreadsheetSetRowHeight(l.sheet, 2, 20.2);
        spreadSheetSetColumnWidth(l.sheet, 1, 21.43);
        l.logo_binary = FileReadBinary( expandPath("/images/Huhtamaki_logo_03.png") );     /*  /images/Logon_Blacksmith/index_huhtamaki_02_small.png */
        SpreadsheetAddImage(l.sheet, l.logo_binary, 'png', '2,1,3,2');
    
        spreadsheetMergeCells(l.sheet, l.title, l.title, 2, 5);
        spreadsheetSetCellValue(l.sheet, "Huhtamaki Price Quote",  l.title, 2);

        // <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        // <!--- ~~~~~~~ Address goes here ~~~~~~~~ --->
        // <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        l.address = 1;    // l.address starting row number
        spreadsheetSetCellValue(l.sheet, "9201 Packaging Dr.", l.address, 6);
        spreadsheetSetCellValue(l.sheet, "DeSoto, KS 66018",   l.address + 1, 6);
        spreadsheetSetCellValue(l.sheet, "(800) 539-3726",     l.address + 2, 6);

        // style title & address
        spreadsheetFormatCell (l.sheet, fmt.title, l.title, 2);
        spreadsheetFormatCellRange (l.sheet, { font:fmt.font_family, fontsize:fmt.font_size }, l.address, 6, l.address + 2, 6);

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
        if ( isDate(l.qProgram.effective_start_date) ) {
            spreadsheetSetCellValue(l.sheet, dateFormat(l.qProgram.effective_start_date, "mmmm d, yyyy")
                                                            & " to "
                                                            & dateFormat(l.qProgram.effective_end_date, "mmmm d, yyyy"),  l.program + 5, 2);
        }

        spreadsheetSetCellValue(l.sheet, "Contact Name",  l.program, 5);     spreadsheetSetCellValue(l.sheet, l.qProgram.RSP,  l.program, 6);
        spreadsheetSetCellValue(l.sheet, "Contact Title", l.program + 1, 5);   spreadsheetSetCellValue(l.sheet, l.qProgram.profiles_desc,  l.program + 1, 6);
        spreadsheetSetCellValue(l.sheet, "Phone Number",  l.program + 2, 5);   spreadsheetSetCellValue(l.sheet, l.qProgram.work_phone,  l.program + 2, 6);


        // style program section
        spreadsheetFormatCellRange (l.sheet, { bold:true, font:fmt.font_family, fontsize:fmt.font_size }, l.program, 1, l.program + 7, 1);
        spreadsheetFormatCellRange (l.sheet, { bold:true, font:fmt.font_family, fontsize:fmt.font_size }, l.program, 5,  l.program + 2, 5);
        spreadsheetFormatCellRange (l.sheet, { font:fmt.font_family, fontsize:fmt.font_size }, l.program, 2, l.program + 7, 2);
        spreadsheetFormatCellRange (l.sheet, { font:fmt.font_family, fontsize:fmt.font_size }, l.program, 6, l.program + 7, 6);

        // <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        // <!--- ~~~~~~~ Distributors go here ~~~~~~~~ --->
        // <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        l.products = l.program + 8;
        l.columns_list = arrayToList( [ "Distributor", 
                                        "Ship To#chr(10)# City", 
                                        "Ship To#chr(10)# State", 
                                        "Ship To#chr(10)# Zip Code", 
                                        "Ship To Number", 
                                        "Ship From#chr(10)# City", 
                                        "Ship From#chr(10)# State", 
                                        "Ship From#chr(10)# Zip Code", 
                                        "% of Volume", 
                                        "Mfr Spec. ##", 
                                        "Item Description", 
                                        "Case pack", 
                                        "Case cube", 
                                        "Cases/Pallet", 
                                        "Gross#chr(10)# Wt/Cs (lb)", 
                                        "Shipping#chr(10)# Units", 
                                        "Pallet Count#chr(10)# per#chr(10)# Load Shipped", 
                                        "Mode#chr(10)# (TL/LTL)", 
                                        "Freight Cost#chr(10)# per Cube", 
                                        "Freight /#chr(10)# Case", 
                                        "Total Blended#chr(10)# Freight / Case",
                                        "FOB#chr(10)# Price / Case", 
                                        "Delivered#chr(10)# Pricing / Case"
                                    ] );
        spreadsheetAddrow(l.sheet, l.columns_list, l.products, 1);

        // styles for table header
        spreadSheetSetRowHeight(l.sheet, l.products, 50);
        spreadsheetFormatRow(l.sheet, { verticalalignment:"vertical_center", textwrap:true }, l.products);
        spreadsheetFormatCellRange (l.sheet, fmt.table_header, l.products, 1,  l.products, listLen(l.columns_list));        

        for (l.this in l.qProducts) {
            // remove all commas from structure values otherwise the number of output columns will be changed
            spreadsheetAddRow(l.sheet, arrayToList([ replace(l.this.Distributor, ",", " ", "all")
                                                    ,l.this.Ship_To_City 
                                                    ,l.this.Ship_To_State
                                                    ,l.this.Ship_To_ZipCode
                                                    ,l.this.Ship_To_Number
                                                    ,l.this.Ship_From_City
                                                    ,l.this.Ship_From_State
                                                    ,l.this.Ship_From_ZipCode
                                                    ,l.this.Percent_Volume / 100
                                                    ,chr(160) & l.this.Item
                                                    ,replace(l.this.Description, ",", " ", "all")
                                                    ,l.this.Case_Pack
                                                    ,l.this.Case_Cube
                                                    ,l.this.Cases_Pallet
                                                    ,l.this.Gross_Weight
                                                    ,'Cube'
                                                    ,l.this.Order_Average_Pallet
                                                    ,l.this.mode
                                                    ,l.this.Freight_Rate_Per_Volume
                                                    ,l.this.Freight_Per_Cs
                                                    ,l.this.Total_Freight_CS
                                                    ,l.this.FOB_Price
                                                    ,l.this.Delivered_Price
                                                ]));

            l.excel_row_number  = l.products + l.qProducts.currentRow;
            l.row_format        = fmt.table_body[ (l.qProducts.currentRow mod 2) + 1];
            l.deci2_format      = duplicate( l.row_format ).append( { dataformat: "0.00" } );
            l.deci3_format      = duplicate( l.row_format ).append( { dataformat: "0.000" } );
            l.dollar_format     = duplicate( l.row_format ).append( fmt.currency );
            l.indent_format     = duplicate( l.row_format ).append( { indent: 1 } );
            l.percentage_format = duplicate( l.row_format ).append( fmt.percentage );
            l.pack_size_format  = duplicate( l.row_format ).append( { dataformat: "0,0" } );
            l.pallet_cnt_format = duplicate( l.row_format ).append( { dataformat: "0.0" } );
            l.ship_to_format    = duplicate( l.row_format ).append( { dataformat: "0000000000", alignment: "left"  } );
            l.zip_code_format   = duplicate( l.row_format ).append( { dataformat: "00000", alignment: "left"  } );

            spreadsheetFormatRow(l.sheet, l.row_format, l.excel_row_number);

            spreadsheetFormatCell (l.sheet, l.zip_code_format,    l.excel_row_number, 4);
            spreadsheetFormatCell (l.sheet, l.ship_to_format,     l.excel_row_number, 5);
            spreadsheetFormatCell (l.sheet, l.zip_code_format,    l.excel_row_number, 8);
            spreadsheetFormatCell (l.sheet, l.percentage_format,  l.excel_row_number, 9);
            spreadsheetFormatCell (l.sheet, l.pack_size_format,   l.excel_row_number, 12);
            spreadsheetFormatCell (l.sheet, l.deci2_format,       l.excel_row_number, 13);
            spreadsheetFormatCell (l.sheet, l.deci3_format,       l.excel_row_number, 15);
            spreadsheetFormatCell (l.sheet, l.indent_format,      l.excel_row_number, 16);
            spreadsheetFormatCell (l.sheet, l.pallet_cnt_format,  l.excel_row_number, 17);
            spreadsheetFormatCell (l.sheet, l.indent_format,      l.excel_row_number, 18);
            spreadsheetFormatCellRange (l.sheet, l.dollar_format, l.excel_row_number, 19, l.excel_row_number, 23);
        }

        SpreadSheetSetColumnWidth (l.sheet, 10, 20);

        spreadSheetWrite(l.sheet, "#arguments.excel.export_fulpath#", true);
    </cfscript>

</cffunction>

