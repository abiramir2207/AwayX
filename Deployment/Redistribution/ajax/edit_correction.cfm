<cfsetting showDebugOutput="no">
<cfsetting enablecfoutputonly="true">
<!---
  * ==================================================================================================== 
  *    @File: Deployment\Redistribution\ajax\edit_correction.cfm
  *  @Author: Chris Nguyen
  *    @Date: 2019 May - 85971
  * 
  * @Remarks: Pull a correction from database
  *  
  * ==================================================================================================== 
--->
<cfscript>
    redi                        = createObject("component", "mvc.Models.Admin.Redi.vos.RediCorrectionHeader");
    redi.rediCorrectionHeaderId = form.header_primary_key;
    rediDAO                     = createObject("component", "mvc.Models.Admin.Redi.RediDAO");
    qRediHdr                    = rediDAO.getRediHeaderData(redi);
    rediEditDAO                 = createObject("component", "mvc.Models.Admin.Redi.RediEditDAO");
    qAlias                      = rediEditDAO.getRediEditDetailData(redi);
</cfscript>
<cfoutput>

<!--- get current lock status --->
<cfquery name="qLock" datasource="#application.datasource#">
    SELECT  Locked,
            User_Id_Locked,
            u.Name_First + ' ' + u.Name_Last AS Locked_By
        FROM REDI_EC_HEADER
            LEFT JOIN _Users u ON u.User_ID = User_Id_Locked
    WHERE REDI_EC_Header_id = #form.header_primary_key#
</cfquery>

<cfscript>
    current_mode = qLock.recordCount 
                    and qLock.Locked
                    and qLock.User_Id_Locked neq ''
                    and qLock.User_Id_Locked eq '#request.AccessStructure.User_ID#'
                    ? "editing"
                    : "read_only";

    // create header_id attribute for various elements on this tab
    header_id_attribute = "header_id='#form.header_primary_key#'";
    is_editing          = (current_mode is "editing");
</cfscript>

<form #header_id_attribute# name="form_#header_primary_key#" class="edit_tab" onsubmit="return false">
<input type="hidden" name="arbitrary">
<input type="hidden" name="ExistingProductList">
<input type="hidden" name="selected_products">
<input type="hidden" name="parent_call_back" value="product_by_id">

<div class="mb-0 flex pt-0 pb-2 justify-between">
    <div class="mr-3">
        <button type="button" class="button read_edit #current_mode# #(is_editing ? 'danger' : 'recommended')#" #header_id_attribute#
                title='#(is_editing ? "Click to release exclusive editing" : "Click to lock for exclusive editing")#'>
            #replaceNoCase(current_mode, "_", " ")#
        </button>
        <cfif is_editing>
            <button type="button" class="button validate" title="Click to save this redistribution correction and create invoice.">validate</button>
        </cfif>
        <button type="button" class="button close" #header_id_attribute#>close</button>
    </div>
    <div>
        <a href="##" class="alias_management">#application.util.string.linkFormat("alias management")#</a>
    </div>
</div>

<!--- <cfdump var="#qRediHdr#"> --->
<div class="mb-2 rounded-lg" style="background-color:##EDEEF2;">
    <p class="pt-1 pl-5 ml-4 tracking-wide">Redi Correction &nbsp; <span class="tracking-wide font-extrabold">#qRediHdr.SourceType# #qRediHdr.SourceTypeDesc# :: [ecid #qRediHdr.rediCorrectionHeaderId#]</span></p>
    <input type="hidden" name="row_identity" class="header" value="#qRediHdr.rediCorrectionHeaderId#">
    <div class="flex p-2">
        <cfset sold_to_label = application.returned_customer_setting.Shard_Ship_To_Label>
        <div class="w-1/3 leading-loose">
            <label class="corr">#form.Original_Buyer_Label# Name</label>                  <i class="corr">#qRediHdr.OriginalCustomerAliasName#</i> <br>
            <label class="corr">#form.Original_Buyer_Label# #sold_to_label#</label>       <i class="corr">#qRediHdr.originalCustomerAliasShipTo#</i> <br>
            <label class="corr">#form.Original_Buyer_Label# Address</label>               <i class="corr">#qRediHdr.originalCustomerAliasAddress#</i> <br>
            <label class="corr">Man. #form.Original_Buyer_Label# Name</label>             <i class="corr">#qRediHdr.originalCustomerName#</i> <br>
            <label class="corr">Man. #form.Original_Buyer_Label# #sold_to_label#</label> 
                <cfif is_editing eq false> 
                    <i class="corr">#qRediHdr.originalCustomerShipTo#</i>
                <cfelse>
                    <!--- <cfset input_name = "original_customer_ship_to" & '_' & form.header_primary_key> --->
                    <cfset input_name = "original_customer_ship_to">
                    <input type="text" class="editable original_customer_ship_to header" value="#qRediHdr.originalCustomerShipTo#" name="#input_name#"> 
                    <input type="hidden" name="#input_name#_guid" value="#qRediHdr.originalCustomerID#">   <!--- imported value is stored in this hidden variable --->
                    <i #header_id_attribute# title="Click to search for Man. #form.Original_Buyer_Label# #sold_to_label#" class="distributor fa fa-search"></i>    
            </cfif><br>
            <label class="corr">Man. #form.Original_Buyer_Label# Address</label>          <i class="corr">#qRediHdr.originalCustomerAddress#</i> <br>
        </div>
        <div class="w-1/3 leading-loose">
            <label class="corr">#form.Final_Buyer_Label#  Name</label>                 <i class="corr">#qRediHdr.FinalCustomerAliasName#</i> <br>
            <label class="corr">#form.Final_Buyer_Label# #sold_to_label#</label>       <i class="corr">#qRediHdr.FinalCustomerAliasShipto#</i> <br>
            <label class="corr">#form.Final_Buyer_Label#  Address</label>              <i class="corr">#qRediHdr.FinalCustomerAliasAddress#</i> <br>
            <label class="corr">Man. #form.Final_Buyer_Label#  Name</label>            <i class="corr">#qRediHdr.FinalCustomerName#</i> <br>
            <label class="corr">Man. #form.Final_Buyer_Label# #sold_to_label#</label> 
                <cfif is_editing eq false> 
                    <i class="corr">#qRediHdr.FinalCustomerShipto#</i>
                <cfelse>            
                    <!--- <cfset input_name = "final_customer_ship_to" & '_' & form.header_primary_key> --->
                    <cfset input_name = "final_customer_ship_to">
                    <input type="text" class="editable final_customer_ship_to header" value="#qRediHdr.FinalCustomerShipto#" name="#input_name#">
                    <input type="hidden" name="#input_name#_guid" value="#qRediHdr.FinalCustomerID#">   <!--- imported value is stored in this hidden variable --->
                    <i #header_id_attribute# title="Click to search for Man. #form.Final_Buyer_Label# #sold_to_label#" class="distributor fa fa-search"></i>
                </cfif><br>
            <label class="corr">Man. #form.Final_Buyer_Label# Address</label>          <i class="corr">#qRediHdr.FinalCustomerAddress#</i> <br>
        </div>
        <div class="w-1/3 leading-loose">
            <label class="corr">#form.Original_Buyer_Label# Inv. ##</label>   <i class="corr">#qRediHdr.InvoiceNumber#</i> <br>
            <label class="corr">PO ##</label>                                 <i class="corr">#qRediHdr.PoNum#</i> <br>
            <label class="corr">#form.Original_Buyer_Label# Inv. Date</label> <i class="corr">#dateFormat(qRediHdr.InvoiceDate, "mmm d, yyyy")#</i> <br>
            <label class="corr">Total Cases</label>                           <i class="corr">#numberFormat(qRediHdr.InvCases,",0")#</i> <br>
            <label class="corr">Total Dollars</label>                         <i class="corr">#dollarFormat(qRediHdr.InvDollars)#</i> <br>
            <label class="corr align-top">Message</label>                     <textarea readonly class="corr w-48">#qRediHdr.ErrorMessage#</textarea>
        </div>
    </div>
</div>   

<div class="ag-theme-balham" id="agdiv_#form.header_primary_key#">
</div>    
</form>

<script>
    const data_index = {      alias_item_id          : 0
                            , alias_item_description : 1
                            , item_id                : 2
                            , item_description       : 3
                            , invoice_cs             : 4
                            , invoice_dollar         : 5
                            , message                : 6
                        };

    // save grid options to "edit_grids" (a global structure)
    edit_grids["#form.header_primary_key#"] = {
        columnDefs: [
                     { headerName:'Alias Item', valueGetter:function(p){ return p.data[ 0 ] }, sort:'desc' }
                    ,{ headerName:'Alias Item Desc', valueGetter:function(p){ return p.data[ 1 ] } }
                    ,{ headerName:'Item', valueGetter:function(p){ return p.data[ 2 ] }, filter:false
                                                <cfif is_editing>
                                                    ,cellRenderer:function(p){ return "<input class='item detail' type='text' name=item_" + p.data[7] + " value=" + p.data[2] + "> <i class='fa fa-search item'></i>" }
                                                </cfif>
                                                }
                    ,{ headerName:'Item Desc', valueGetter:function(p){ return p.data[ 3 ] } }
                    ,{ headerName:'Inv. CS', valueGetter:function(p){ return p.data[ 4 ] }, type:'numericColumn', filter:false }
                    ,{ headerName:'Inv. $', valueGetter:function(p){ return p.data[ 5 ] }, valueFormatter:function(p){ return currencyFormat(p.data[ 5 ]) }, type:'numericColumn', filter:false }
                    ,{ headerName:'Message', valueGetter:function(p){ return p.data[ 6 ] } }
                ]
        ,defaultColDef:              {
                                            editable:                      false
                                          , filterParams:                  { apply: false }
                                          , floatingFilterComponentParams: { suppressFilterButton: true }
                                          , suppressMenu:                  true
                                          , suppressMovable:               false
                                          , unSortIcon:                    false
                                          , sortable:                      true
                                          , resizable:                     true
                                          , filter:                        'agTextColumnFilter'
                                    }
        , enableRangeSelection:      false
        , floatingFilter:            true
        , onFirstDataRendered:       function(params) { params.api.sizeColumnsToFit() }
        , pagination:                true
        , paginationPageSize:        #form.redistribution_page_size#
        , rowModelType:              "clientSide"
        , rowData:                   #application.util.query.toDtJSON(qAlias, "ALIAS_ITEM_NUMBER, ALIAS_ITEM_DESC, ITEM_NUMBER, DESCRIPTION, QTY, UNIT_PRICE, ERR_MSG, REDI_EC_DETAIL_ID")#
        , suppressContextMenu:       true
        , suppressRowClickSelection: true
    };

    ag_grid_default( edit_grids["#form.header_primary_key#"] );
    init_ag_grid( edit_grids["#form.header_primary_key#"], "##agdiv_#form.header_primary_key#", false );  
</script>
</cfoutput>
