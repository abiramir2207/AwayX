<!---
  * ==================================================================================================== 
  *    @File: Common_Files\contracts\ajax\tbd_items.cfm
  *  @Author: Chris Nguyen
  *    @Date: November 2020
  * 
  * @Remarks: Render TBD Items
  *
  * @Parameters:  URL.CID - required, encrypted value for contract_main_id numeric value
  * ==================================================================================================== 
--->
<cfset post_errors = []>
<cfoutput>
    <cfif cgi.request_method is "post">
        <cfset post_errors = validate_save( form )>
        <cfif post_errors.len() eq 0>
            <cflocation url="/common_files/contracts/contract_edit_menu.cfm?CID=#URL.CID#" addtoken="true">
        </cfif>
    </cfif>
</cfoutput>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Update TBD Products</title>
</head>
<body>
    <style>
        body {
            overflow: hidden;
        }
        button.save {
            cursor: pointer;
        }
    </style>
    <div style="display:flex;">
        <!-- program options in left panel -->
        <aside style="width:140px;">
            <cf_cryp type="de" key="#request.key#" string="#URL.CID#">
            <cfif cryp.error>
                <cfthrow message="Failed to decrypt URL.CID" detail=" with value of '#URL.CID#', decrypted result: #serializeJSON(cryp)#">
            <cfelse>
                <cfset CSL_Contract_Main_ID = cryp.value>
                <cfset form.contract_main_id = cryp.value>
                <!--- ~~~~~~~~~~~~~~~~~~~ pull html version of left panel options ~~~~~~~~~~~~~~~~~~~ --->
                <cfset request.getProgramLeftPanelHtml = 1>
                <cfinclude template="/common_files/contracts/contract_status_legend.cfm">
            </cfif>
        </aside>
    
        <!-- tbd items grid  -->
        <main style="flex:1;overflow: auto;">
            <cfoutput>#tbd_grid()#</cfoutput>
        </main>
    </div>

    <cfinclude template="/common_files/focus.cfm">
</body>
</html>


<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~ I render the TBD grid ~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<cffunction name="tbd_grid">
<style>
    a.select_product {
        cursor: pointer;
    }
    .error {
        color: red;
    }
</style>
<!--- program header --->
<cfset request.style = "2020">  
<cfinclude template="/Common_Files/contracts/minimal_contract_info.cfm">


<!--- set up temp table to hold the previously entered information --->
<cfquery datasource="#application.datasource#">
    IF OBJECT_ID ('tempdb..##tmp_tbd_items') IS NOT NULL
        DROP TABLE ##tmp_tbd_items
</cfquery>

<cfquery datasource="#application.datasource#">
    CREATE TABLE ##tmp_tbd_items(
        TBD_ITEM_GUID        VARCHAR(255),
        NEW_ITEM             NVARCHAR(255),
        NEW_ITEM_DESCRIPTION NVARCHAR(255),
        IS_INVALID           BIT
    ) 
</cfquery>

<!--- load previously entered information into temp table --->
<cfif post_errors.len()>
    <cfloop collection="#form#" item="element">
        <cfif listFirst(element, "$") is "NEW_ITEM">
            <cfset tbd_item = listToArray(element, "$")>

            <!--- manually entered new products would not have description, add an empty string --->
            <cfif tbd_item.len() eq 2>
                <cfset tbd_item.append('')>
            </cfif>

            <cfquery datasource="#application.datasource#">
                INSERT INTO ##tmp_tbd_items 
                        (TBD_ITEM_GUID, NEW_ITEM, NEW_ITEM_DESCRIPTION, IS_INVALID)
                VALUES ('#tbd_item[2]#', '#form[element]#', '#tbd_item[3]#', #arrayFindNoCase(post_errors, form[element]) ? 1 : 0#)
            </cfquery>
        </cfif>
    </cfloop>
</cfif>

<!--- pull in previously entered information from temp table --->
<cfquery name="qTBD" datasource="#application.datasource#">
    SELECT DISTINCT tbd.TBD_Item
            ,tbd.Item_Description
            ,PFPPD.fixed_Price_Value
            ,ISNULL(tmp.New_Item, '') AS New_Item
            ,ISNULL(tmp.New_Item_Description, '') AS New_Item_Description
            ,'' AS Action
            ,tbd.BSA_Foodservice_Items_Master_ID AS TBD_ITEM_GUID
            ,ISNULL(tmp.Is_Invalid, 0) AS IS_INVALID
    FROM   Contract_Products cp
        JOIN TBD_Item tbd
            ON cp.BSA_Foodservice_Items_Master_ID = tbd.BSA_Foodservice_Items_Master_ID
        JOIN Program_Fixed_Price_Product_Data PFPPD
            ON cp.Contract_Products_ID = PFPPD.Contract_Products_ID
        LEFT JOIN ##tmp_tbd_items tmp ON tmp.TBD_ITEM_GUID = tbd.BSA_Foodservice_Items_Master_ID
    WHERE  cp.Contract_Main_ID = #form.Contract_Main_ID# AND
            CAST(PFPPD.Fixed_Price_Value as decimal(12,4)) != 0.0 AND
            cp.Deleted = 0
</cfquery>



<div style="margin:10px">
    <button class="button recommended save">save</button>
</div>


<div id="aggrid" style="height:750px;width:100%;margin:0px 0 0 0;padding:0;" class="ag-theme-balham"></div>   

<cfoutput>
    <form method="post" name="tbd_items" action="tbd_items.cfm?CID=#URL.CID#">
        <input type="hidden" name="contract_main_id" value="#form.Contract_Main_ID#">
    </form>
</cfoutput>

<cf_include files="/common_files/ag-Grid.cfm, /common_files/jQuery.cfm, /script/javascript/numeral.min.js, /script/javascript/numeric/jquery.numeric.min.js, /styles/css-loader.css">

<script>
    'use strict';

    const config = { starting_column: 1 };
    config.query = <cfoutput>#serializeJSON( qTBD, "struct" )#</cfoutput>;

    <!--- ~~~~~~~~~~ glob = global variables  ~~~~~~~~~~ --->
    let glob = { grid_id: "#aggrid", select_product_node_id: null };

    <!--- ~~ define ag-grid configuration ~~ --->
    glob.my_grid = {
            defaultColDef: {     editable:        false
                                ,suppressMenu:    true
                                ,suppressMovable: false
                                ,unSortIcon:      false
                                ,sortable:        true
                                ,resizable:       true
                                ,filter: false
                            }
            ,columnDefs: [
                            { headerName:"Product", field:"TBD_ITEM" }
                            ,{ headerName:"Description", field:"ITEM_DESCRIPTION", width:275, suppressSizeToFit:true }
                            ,{ headerName:"Component", field:"FIXED_PRICE_VALUE", valueFormatter:function(p){ return currencyFormat(p.value)}, type:'numericColumn', width:175, suppressSizeToFit:true }
                            ,{ headerName:"New Product", field:"NEW_ITEM", editable:true, cellClass:function(row) { return row.data.IS_INVALID ? "attention" : "editable" } }
                            ,{ headerName:"Description", suppressSizeToFit:true, width:275, field:"NEW_ITEM_DESCRIPTION" }
                           , { headerName:"", field:"ACTION", suppressSizeToFit:true, cellRenderer:function(p){ return <cfoutput>"<a class='select_product' node_id=" + p.node.id + ">#application.util.string.linkFormat('select product')#</a>"</cfoutput>} }
                        ]
            ,enableRangeSelection:      false
            ,floatingFilter:            false
            ,pagination:                false
            ,rowData:                   config.query
            ,rowModelType:              "clientSide"
            ,rowSelection:              false
            ,suppressContextMenu:       true
            ,suppressRowClickSelection: true
            ,onCellValueChanged: function (params) {
                                                    let rowNode = glob.my_grid.api.getRowNode( params.node.id );
                                                    if (params.oldValue !== params.newValue) {
                                                        $.ajax({type: "post"
                                                                ,url: "/mvc/Models/Admin/Alias/AliasManager.cfc"
                                                                ,dataType: "json"
                                                                ,data: { method: "getItemInfoJSON"
                                                                        ,itemID: params.data.NEW_ITEM
                                                                        ,isGUID: 0
                                                                        }
                                                                ,success : function (response) {
                                                                    if (rowNode && response) {
                                                                        rowNode.setDataValue('NEW_ITEM_DESCRIPTION', response.desc);
                                                                    }
                                                                }
                                                        });
                                                    }
                                                }
            ,onGridReady:               function(p) {
                                            $("a.select_product").click(function(){ 
                                                /* keep track of clicked row */
                                                glob.select_product_node_id = $(this).attr("node_id");
                                                popupInCenter( "/Common_Files/contracts/product_Select_V1.cfm"
                                                                            + "?SelectSingleSearchResultOnly=1"
                                                                            + "&callback=refresh_item", "select_product" );
                                            });
                                        }
        };

    ag_grid_default( glob.my_grid );    
    init_ag_grid( glob.my_grid, glob.grid_id );

    /////////////////////////////////////////////////
    // call back function from product lookup popup
    /////////////////////////////////////////////////
    function refresh_item( selected_product ) {
        let rowNode = glob.my_grid.api.getRowNode( glob.select_product_node_id );
        if (rowNode && selected_product && selected_product.length) {
            rowNode.setDataValue('NEW_ITEM', selected_product[0].product);
            rowNode.setDataValue('NEW_ITEM_DESCRIPTION', selected_product[0].description);
        }
    }

    $("button.save").click(function(){
        let form = $("form[name=tbd_items]");
        let new_item_count = 0;
        glob.my_grid.api.forEachNode(function(rowNode, index) {
            <!--- ~~ select only rows with new item ~~ save each new item into this form element
                Example: input name="NEW_ITEM$tbd_product_guid$new_product_description" value="selected_new_product_number"
                Where: 
                    Form input element name:
                            2nd list entry = tbd product guid
                            3rd list entry = new product description
                    Form input element value = selected new product number
            --->
            if (rowNode.data.NEW_ITEM !== '') {
                new_item_count++;
                form.append("<input type=hidden name='NEW_ITEM" 
                                                            + '$' + rowNode.data.TBD_ITEM_GUID              
                                                            + '$' + (!!rowNode.data.NEW_ITEM_DESCRIPTION ? rowNode.data.NEW_ITEM_DESCRIPTION : '')
                                                            + "' value='" 
                                                            + rowNode.data.NEW_ITEM 
                                                            + "'>");
            }
        });

        if (new_item_count == 0) {
            alert( "Please enter at least one new product prior to clicking on save." );
        }
        else if (confirm("Are all of the TBD item updates correct?")) {
            show_loader( "SAVING CHANGES..." );
            form.submit();
        }
    });
</script>

<cfif post_errors.len()>
    <cfset request.noty_version = "3">
    <cfinclude template="/common_files/noty.cfm">
    <script>
        // append closing message by calling noty_message() function & pass your messages
        new Noty( { type:"error"
                    ,layout:'center'
                    ,text: noty_message("<strong>Please correct the invalid new products.</strong>") }).show();
    </script>
</cfif>
</cffunction>


<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~ I validate/save new products ~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<cffunction name="validate_save" output="false">
    <cfargument name="form" required="true">

    <cfset local.errors = []>
    <cfset local.valids = []>

    <!--- look for new products elements in form scope --->
    <cfloop collection="#arguments.form#" item="local.key">
        <cfif listFirst(local.key, "$") is "NEW_ITEM">
            <cfset local.new_item = arguments.form[ local.key ]>
            <!--- parse new product element into multiple parts --->
            <cfset local.entries  = local.key.listToArray('$')>

            <cfquery name="local.qValidation" datasource="#application.datasource#">
                SELECT BSA_Foodservice_Items_Master_ID 
                  FROM BSA_Foodservice_Items_Master 
                 WHERE Item = '#local.new_item#'
            </cfquery>

            <cfif local.qValidation.recordCount eq 0>
                <cfset local.errors.append( local.new_item )>
            <cfelse>
                <cfset local.valids.append( local.entries[2] )>
                <!--- save new product to an intermediate table for stored procedure execution later --->
                <cfquery datasource="#application.datasource#">
                    INSERT INTO TBD_Item_Switch_Log 
                            ( Contract_Main_ID, TBD_BSA_Foodservice_Items_Master_ID, New_BSA_Foodservice_Items_Master_ID )
                    VALUES  ( #arguments.form.Contract_Main_ID#, '#local.entries[2]#', '#local.qValidation.BSA_Foodservice_Items_Master_ID#')
                </cfquery>
            </cfif>
        </cfif>
     </cfloop>

     <cfif local.valids.len()>
        <!--- post valid new products to the backend --->
        <cfstoredproc procedure = "Update_TBD_Items" dataSource="#application.datasource#">
            <cfprocparam type="in" cfsqltype = "cf_sql_varchar"	value="#arguments.form.Contract_Main_ID#" dbvarname="@Contract_Main_ID">
        </cfstoredproc>
     </cfif>

     <cfreturn local.errors>
</cffunction>