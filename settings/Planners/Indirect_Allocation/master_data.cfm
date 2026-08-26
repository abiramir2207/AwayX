<!---
  * ====================================================================================================
  *    @File: settings\Planners\Indirect_Allocation\master_data.cfm
  *  @Author: Chris Nguyen
  *    @Date: 2022 May
  *
  * @Remarks: Download master data to an Excel file with multiple sheets
  *
  * ====================================================================================================
--->
<cfscript>
    settings = application.util.query.get_settings( [     "Planner_Direct_Indirect_Allocation_Direct_Customer_Type"
                                                        , "Planner_Direct_Indirect_Allocation_InDirect_Customer_Type"
                                                        , "Planner_Direct_Indirect_Allocation_Product_Type"
                                                        , "Show_BSA_operators"
                                                        , "Display_Distributor_ID"
                                                        , "Display_Item_No"
                                                    ], 0 );
    allocation_cfc = createObject("component", "mvc.models.planner.IndirectAllocation");
    labels         = allocation_cfc.getLabels();


    // -------------- //
    //  Distributors  //
    // -------------- //
    if ( settings.Planner_Direct_Indirect_Allocation_Direct_Customer_Type eq 0 ) {
        columns = ( settings.Display_Distributor_ID eq '1' ? "Shr_Ship_To" : "Ship_To" ) & ", Name AS '#labels.distributors#',";
        qDistributors = queryExecute( " SELECT #columns# FROM BSA_Foodservice_Customers WHERE Deleted = 0 and Active_Code = 'A'", {} ,{ datasource: application.datasource } );
    }
    else {
        component_cfc   = createObject( "component", "components.customer.group.DistributorGroupAttributeManager" ).init();
        group_attribute = component_cfc.getGroupAttributeInfo( groupLevelTypeId = settings.Planner_Direct_Indirect_Allocation_Direct_Customer_Type );
        qDistributors   = component_cfc.getDistributorGroupValues( DistributorGroupAttributeInfo = group_attribute );
        // select columns to include on master data
        columns         = "Group_Number, Group_Name";
        qDistributors   = queryExecute( " SELECT #columns# FROM qDistributors ", {}, { dbtype: "query" } );
    }


    // ----------- //
    //  Operators  //
    // ----------- //
    if ( settings.Planner_Direct_Indirect_Allocation_InDirect_Customer_Type eq 0 ) {
        columns    = ( settings.show_bsa_operators ? "BSA_Operator_ID" : "Legacy_ID" ) & " AS ID," & "Operator_Name AS '#labels.operators#'";
        qOperators = queryExecute( " SELECT #columns# FROM BSA_Operator WHERE Deleted = 0 and Display_Code = 'A'", {} ,{ datasource: application.datasource } );
    }
    else {
        component_cfc = CreateObject( "component", "components.operator.group.OperatorGroupAttributeManager" ).init();
        qOperators    = component_cfc.getOperatorGroupAttributesMultiple( groupLevelTypeId = settings.Planner_Direct_Indirect_Allocation_InDirect_Customer_Type );
        columns       = "PG_Operator_Category_Code AS PG_Code,PG_Operator_Category_Name AS PG_Name";
        // select columns to include on master data
        qOperators    = queryExecute( " SELECT #columns# FROM qOperators ", {}, { dbtype: "query" } );
    }


    // ---------- //
    //  Products  //
    // ---------- //
    if ( settings.Planner_Direct_Indirect_Allocation_Product_Type eq 0 ) {
        columns   = ( settings.Display_Item_No ? "Item" : "UPC" ) & ",Description AS '#labels.products#" ;
        qProducts = queryExecute( " SELECT #columns# FROM BSA_Foodservice_Items_Master WHERE Deleted = 0 and Active_Code = 'A'", {} ,{ datasource: application.datasource } );
    }
    else {
        component_cfc = CreateObject("component", "components.products.group.ProductGroupAttributeManager").init();
        product_group = component_cfc.getGroupTypeInfo( groupLevelId = settings.Planner_Direct_Indirect_Allocation_Product_Type );
        qProducts     = component_cfc.getProductGroupValues( productGroupType = product_group );
        columns       = "Group_Number, Group_Name";
        // select columns to include on master data
        qProducts    = queryExecute( " SELECT #columns# FROM qProducts ", {}, { dbtype: "query" } );
    }

    xlsData = application.util.query.exportToXLSX( [ qDistributors, qOperators, qProducts ], [ labels.distributors, labels.Operators, labels.Products ] );
</cfscript>

<!--- <cfdump var="#qOperators#" abort="true"> --->

<cfheader name="content-disposition" value="attachment; filename=Master Data As Of #dateFormat( now(), 'dddd mmm d yyyy' )#.xlsx">
<cfcontent type="application/msexcel" variable="#spreadsheetReadBinary( xlsData )#" reset="true">

