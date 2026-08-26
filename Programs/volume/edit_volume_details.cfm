<!---
* ==================================================================================================== 
*    @File: \programs\volume\edit_volume_details.cfm
*  @Author: Chris Nguyen
*    @Date: 2019-02-01
* 
* @Remarks:   
*
*
* 
*  
* ==================================================================================================== 
--->
<cfinclude template="edit_volume_header.cfm">
<cfscript>
    param name="form.action" default="view";
    param name="form.group_a" default="distributor";
    param name="form.group_b" default="";
    param name="form.product_group_level" default="0";
    param name="form.include_zero" default="0";

    datatables.version    = "1.10.19";
    volume_cfc            = createObject("component", "mvc.models.program.volume.volumeApplicator");
    qUOM                  = volume_cfc.getVolumeApplyToUOM(url.program_id);
    qProdGroupTypes       = volume_cfc.getVolumeProductGroupTypes(url.program_id);

    item_label        = application.returned_customer_setting.item_label;
    distributor_label = application.returned_customer_setting.distributor_label_singular;
    operator_label    = application.returned_customer_setting.operator_label_singular;

    switch (form.group_a) {
        case "distributor":            
            column1_label = distributor_label;
            break;
        case "operator":            
            column1_label = operator_label;
            break;
        default:
            column1_label = item_label;        
    }

    is_operator_template  = qProgram.bOpType;

    // product/distributor/operator number, product/distributor/operator description
    column_estimate_sizes = [ 5, 15 ];

    // operator view has both operator info and product info
    if (form.group_a is "operator") {
        arrayAppend(column_estimate_sizes, 5);      // product number
        arrayAppend(column_estimate_sizes, 15);     // product description
    }

    case_position         = 0;
    lbs_position          = 0;
    each_position         = 0;
    sleeve_position       = 0;
    opp                   = {};         // opportunity volume
    opp.case_position     = 0;          // opportunity volume case
    opp.lbs_position      = 0;          // opportunity volume lbs
    UOMs                  = valueList(qUOM.Abbreviation);
    // add CS if configured & determine the position
    if (UOMs contains "CS") {
        arrayAppend(column_estimate_sizes, 5);
        case_position = arrayLen(column_estimate_sizes);
    }
    // add LBS if configured & determine the position
    if (UOMs contains "LB") {
        arrayAppend(column_estimate_sizes, 5);
        lbs_position = arrayLen(column_estimate_sizes); 
    }
    // add EA if configured & determine the position
    if (UOMs contains "EA") {
        arrayAppend(column_estimate_sizes, 5);
        each_position = arrayLen(column_estimate_sizes); 
    }
    // add SL if configured & determine the position
    if (UOMs contains "SL") {
        arrayAppend(column_estimate_sizes, 5);
        sleeve_position = arrayLen(column_estimate_sizes); 
    }
    // add opportunity CS/LB
    if (qProgram.Opportunity_Volume eq "1") {
        if (UOMs contains "CS") {
            arrayAppend(column_estimate_sizes, 5);
            opp.case_position = arrayLen(column_estimate_sizes);
        }
        // add LBS if configured & determine the position
        if (UOMs contains "LB") {
            arrayAppend(column_estimate_sizes, 5);
            opp.lbs_position = arrayLen(column_estimate_sizes); 
        }
    }
    // figure out the width percentages
    column_widths = application.util.array.dtColumnSizeInPercent( column_estimate_sizes );
</cfscript>

<cf_include files="/common_files/jQuery.cfm, /common_files/dataTables2.cfm, /script/javascript/numeral.min.js">

<style>
    label {
        margin-right: 7px;
    }
    input[type=search] {
        border: 1px solid #dae1e7;
    }
    select.group {
        width: 100px;
    }
    div#details_filter {
        float: left;
        margin-bottom: 7px;
    }
    td.dt-body-right, td.total {
        text-align: right;
        /* width: 4rem; */
        overflow: visible;
        /* padding-right: .25rem; */
    }
    div.groups {
        float: left;
    }
</style>

<form name="edit_volume_details" method="post">
<cfsavecontent variable="header_options">
    <!--- <div class="pt-2 pb-2"> --->
        <!--- <label class="font-semibold tracking-wide mr-1">Search:</label> <input type="search" name="dt_search" id="dt_search" class="mr-4"> --->
    <label class="font-semibold tracking-wide mr-1 ml-4">Group A:</label>
        <cfoutput>
        <cfset temp.group_a = ''>
        <select name="group_a" class="border mr-2 group">
            <option value="Customer" <cfif qProgram.GroupADefault is "Customer" or form.group_a is "Customer">selected <cfset temp.group_a = "customer"></cfif>>#(application.returned_customer_setting.Distributor_Label_Singular eq '' ? "Distributor": application.returned_customer_setting.Distributor_Label_Singular)#</option>
            <option value="Item" <cfif qProgram.GroupADefault is "Item" or form.group_a is "Item">selected <cfset temp.group_a = "item"></cfif> >#(application.returned_customer_setting.item_label eq "" ? "Item" : application.returned_customer_setting.item_label)#</option>
            <cfif qProgram.bOpType>
                <option value="Operator" <cfif qProgram.GroupADefault is "Operator" or form.group_a is "Operator">selected <cfset temp.group_a = "operator"></cfif>>#(application.returned_customer_setting.Operator_Label_Singular eq "" ? "Operator" : application.returned_customer_setting.Operator_Label_Singular)#</option>
            </cfif>
        </select>
        <cfset form.group_a = temp.group_a>
        </cfoutput>        
        <label class="font-semibold tracking-wide mr-1 ml-4">Group B:</label>
        <cfset temp.group_b = ''>
        <select name="group_b" class="border mr-6 group">
            <cfif !qProgram.bOpType>
                 <cfset temp.group_b = "INV">
                <option value="INV" <cfif form.group_b is "INV" or form.group_b is ''>selected=selected</cfif>>Invoices</option>
            </cfif>
            <cfif qProgram.bDirectShipmentShow>
                 <cfset temp.group_b = "DIR-SHIP">
                <option value="DIR-SHIP" <cfif form.group_b is "DIR-SHIP" or form.group_b is ''>selected=selected</cfif>>Direct Shipment</option>
            </cfif>
            <cfif qProgram.bBillbackShow>
                 <cfset temp.group_b = "BBK">
                <option value="BBK" <cfif form.group_b is "BBK" or form.group_b is ''>selected=selected</cfif>>Billbacks</option>
            </cfif>
            <cfif qProgram.bCreditsShow>
                 <cfset temp.group_b = "CRD">
                <option value="CRD" <cfif form.group_b is "CRD" or form.group_b is ''>selected=selected</cfif>>Credits</option>
            </cfif>
        </select>
        <cfset from.group_b = temp.group_b>
        <label><input type="checkbox" name="include_zero" <cfif form.include_zero eq 1 or form.include_zero is "on">checked <cfset form.include_zero = 1></cfif>> Include zero volume</label>
    <!--- </div>    --->
</cfsavecontent>

<cfoutput>    
    <table class="dataTable display nowrap" id="details" width="100%">
    <thead>
        <tr>
            <th style="width:#column_widths[1]#%">#column1_label# Number</th>
            <th style="width:#column_widths[2]#%">#column1_label# Description</th>
        
        <!--- operator view has both operator info and product info --->
        <cfif (form.group_a is "operator")>
            <th style="width:#column_widths[3]#%">#application.returned_customer_setting.item_label# Number</th>
            <th style="width:#column_widths[4]#%">#application.returned_customer_setting.item_label# Description</th>
        </cfif>

        <cfif case_position>
            <th style="width:#column_widths[case_position]#%;text-align:center !important;">
                Cases
            </th>
        <cfelse>
            <th></th>   <!--- hidden column --->
        </cfif>
        <cfif lbs_position>
            <th style="width:#column_widths[lbs_position]#%;text-align:center !important;">
                Pounds
            </th>
        <cfelse>
            <th></th>   <!--- hidden column --->
        </cfif>
        <cfif opp.case_position>
            <th style="width:#column_widths[opp.case_position]#%;text-align:center !important;">
                Opp Cases
            </th>
        <cfelse>
            <th></th>   <!--- hidden column --->
        </cfif>
        <cfif opp.lbs_position>
            <th style="width:#column_widths[opp.lbs_position]#%;text-align:center !important;">
                Opp Pounds
            </th>
        <cfelse>
            <th></th>   <!--- hidden column --->
        </cfif>
        <cfif each_position>
            <th style="width:#column_widths[each_position]#%;text-align:center !important;">
                Each
            </th>
        <cfelse>
            <th></th>   <!--- hidden column --->
        </cfif>
        <cfif sleeve_position>
            <th style="width:#column_widths[sleeve_position]#%;text-align:center !important;">
                Each
            </th>
        <cfelse>
            <th></th>   <!--- hidden column --->
        </cfif>
        </tr>
    </thead>
    <tfoot>
        <tr>
            <td style="width:#column_widths[1]#%"></td>
        <!--- operator view has both operator info and product info --->
        <cfif (form.group_a is "operator")>
            <td style="width:#column_widths[2]#%"></td>
            <td style="width:#column_widths[3]#%"></td>
            <td style="width:#column_widths[4]#%;text-align:right !important;" class="font-semibold tracking-wide">Grand Total</td>
        <cfelse>
            <td style="width:#column_widths[2]#%;text-align:right !important;" class="font-semibold tracking-wide">Grand Total</td>
        </cfif>
        <cfif case_position>
            <td style="width:#column_widths[case_position]#%" class="total_cases total"></td>
        <cfelse>
            <td></td>   <!--- hidden column --->
        </cfif>
        <cfif lbs_position>
            <td style="width:#column_widths[lbs_position]#%" class="total_pounds total"></td>
        <cfelse>
            <td></td>   <!--- hidden column --->
        </cfif>
        <cfif opp.case_position gt 0>
            <td style="width:#column_widths[opp.case_position]#%" class="opportunity_total_cases total"></td>
        <cfelse>
            <td></td>   <!--- hidden column --->
        </cfif>
        <cfif opp.lbs_position>
            <td style="width:#column_widths[opp.lbs_position]#%" class="opportunity_total_pounds total"></td>
        <cfelse>
            <td></td>   <!--- hidden column --->
        </cfif>
        <cfif each_position>
            <td style="width:#column_widths[each_position]#%" class="total_each_volume total"></td>
        <cfelse>
            <td></td>   <!--- hidden column --->
        </cfif>
        <cfif sleeve_position>
            <td style="width:#column_widths[sleeve_position]#%" class="total_sleeve_volume total"></td>
        <cfelse>
            <td></td>   <!--- hidden column --->
        </cfif>
        </tr>
    </tfoot>
    </table>
</cfoutput>      
</form>

<script>
    <!--- pull page size from optional hidden setting --->
    window.page_size   = <cfoutput>#val(application.util.query.get_setting("edit_volume_page_size", 0))#</cfoutput>;
    window.page_size   = (window.page_size === 0 ? 500 : window.page_size);

    <!--- grand totals in footer --->
    window.total_cases      = 0;
    window.total_pounds     = 0;
    window.opportunity_total_cases  = 0;
    window.opportunity_total_pounds = 0;
    window.total_each_volume        = 0;
    window.total_sleeve_volume      = 0;
    <cfoutput>    
    window.distributor_label = '#distributor_label#';
    window.operator_label    = '#operator_label#';
    window.item_label        = '#item_label#';
    </cfoutput>   

    window.dt = $("table#details")
                    .DataTable({
                                "ajax": {
                                    <cfoutput>
                                    "data": function() { 
                                                let params = {};
                                                params.program_id          = #url.program_id#;
                                                params.action              = "#form.action#";
                                                params.product_group_level = $("select[name=product_group_level]").length 
                                                                                ? $("select[name=product_group_level]").val()
                                                                                : '#form.product_group_level#';
                                                params.group_by            = $("select[name=group_a]").length
                                                                                ? $("select[name=group_a]").val()
                                                                                : '#form.group_a#';
                                                params.include_zero        = $("input[name=include_zero]").length
                                                                                ? ($("input[name=include_zero]").is(":checked") ? 1 : 0)
                                                                                : #form.include_zero#;
                                                params.group_b             = $("select[name=group_b]").length
                                                                                ? $("select[name=group_b]").val()
                                                                                : '#form.group_b#'
                                            return params;
                                        }
                                    </cfoutput>
                                    ,"type": "POST"
                                    ,"url": "ajax/edit_volume_details.cfm"
                                }
                                ,"autoWidth": false     
                                ,"columns": [
                                        <cfoutput>
                                             { "width": "#column_widths[1]#%" }
                                            ,{ "width": "#column_widths[2]#%" }
                                        <cfif (form.group_a is "operator")>
                                            ,{ "width": "#column_widths[3]#%" }
                                            ,{ "width": "#column_widths[4]#%" }
                                        </cfif>
                                        <cfif case_position eq 0>
                                            ,{ "visible": false }
                                        <cfelse>
                                            ,{ "width": "#column_widths[case_position]#%", "orderable": true, "className": "dt-body-right case" }
                                        </cfif>
                                        <cfif lbs_position eq 0>
                                            ,{ "visible": false }
                                        <cfelse>
                                            ,{ "width": "#column_widths[lbs_position]#%", "orderable": true, "className": "dt-body-right pound" }
                                        </cfif>


                                        <cfif opp.case_position eq 0>
                                            ,{ "visible": false }
                                        <cfelse>
                                            ,{ "width": "#column_widths[opp.case_position]#%", "orderable": true, "className": "dt-body-right opp_case" }
                                        </cfif>
                                        <cfif opp.lbs_position eq 0>
                                            ,{ "visible": false }
                                        <cfelse>
                                            ,{ "width": "#column_widths[lbs_position]#%", "orderable": true, "className": "dt-body-right opp_pound" }
                                        </cfif>
                                        </cfoutput>                                             
                                        <cfif each_position eq 0>
                                            ,{ "visible": false }
                                        <cfelse>
                                            ,{ "width": "#column_widths[each_position]#%", "orderable": true, "className": "dt-body-right each" }
                                        </cfif>
                                        <cfif sleeve_position eq 0>
                                            ,{ "visible": false }
                                        <cfelse>
                                            ,{ "width": "#column_widths[sleeve_position]#%", "orderable": true, "className": "dt-body-right sleeve" }
                                        </cfif>
                                        ]   
                                ,"deferRender": true        // set it to true to render only page one for best performance
                                ,"dom": "f<'groups'>pt"
                                ,"orderClasses": false  
                                ,"order": []
                                ,"paging": false
                                ,"pageLength": window.page_size
                                ,"scrollY": pixelToVH(get_grid_full_height("details", -75)) + "vh"
                                ,"scrollCollapse": true
                                ,"searching": true
                                ,"initComplete": function( settings, json ) { refresh_totals( json ); }
                            });

    // insert group a, group b and include zero checkbox
    $("div.groups").html( <cfoutput>'#application.util.string.compress( header_options )#'</cfoutput> );

    // save the initial group A selection
    window.group_a = $("select[name=group_a]").val().trim().toLowerCase();

    window.dt.on('draw', function(){
        window.total_cases   = 0;
        window.total_pounds  = 0;
        window.total_each_volume  = 0;
        window.total_sleeve_volume  = 0;
        window.opportunity_total_cases  = 0;
        window.opportunity_total_pounds = 0;

        $("tbody tr").each(function(){
            var acase = $(this).find("td.case");
            var pound = $(this).find("td.pound");
            var opp_case = $(this).find("td.opp_case");
            var opp_pound = $(this).find("td.opp_pound");
            var each = $(this).find("td.each");
            var sleeve = $(this).find("td.sleeve");
            if (acase.length)
                window.total_cases += +acase.text();
            if (pound.length)
                window.total_pounds += +pound.text();
            if (opp_case.length)
                window.opportunity_total_cases += +opp_case.text();
            if (opp_pound.length)
                window.opportunity_total_pounds += +opp_pound.text();
            if (each.length)
                window.total_each_volume += +each.text();
            if (sleeve.length)
                window.total_sleeve_volume += +each.text();
        });

        refresh_totals();            
    });
    
    function ajax_reload() {
        window.dt.ajax.reload( function( json ){
            refresh_totals( json );
        });o
    };

    // toggle to include zero volumes
    $("input[name=include_zero]").change(function(){ ajax_reload(); });

    function column_header_label( group_a ) {
        switch (group_a) {
            case 'item':
                return window.item_label;
                break;
            case 'operator':
                return window.operator_label;
                break;
            case 'customer':
                return window.distributor_label;
                break;        
            default:
                return group_a;
                break;
        }
    };

    $("select[name=group_a]").change(function(){
        // switch to/from operator page with extra columns :: requires form posting (else part) 
        // - otherwise just reload the ajax call with diff parameters (if part)
        if ($(this).val().toLowerCase() !== "operator" && window.group_a !== "operator") {
            let new_header_label = column_header_label($(this).val().toLowerCase());

            // refresh column headers based on group_a selection
            let column1 = window.dt.column(0);
            $(column1.header()).text( new_header_label + " Number");
            let column2 = window.dt.column(1);
            $(column2.header()).text( new_header_label + " Description");

            ajax_reload();
        }
        else {
            $("form[name=edit_volume_details]").submit();
        }
    });

    $("select[name=group_b]").change(function(){ ajax_reload(); });

    <!------------------------------>
    function refresh_totals( json ) {
    <!------------------------------>
        if (typeof json !== 'undefined') {
            window.total_cases   = json.total_cases;
            window.total_pounds  = json.total_pounds;
            window.opportunity_total_cases  = json.opportunity_total_cases;
            window.opportunity_total_pounds = json.opportunity_total_pounds;
            window.total_each_volume  = json.total_each_volume;
            window.total_sleeve_volume  = json.total_sleeve_volume;
        }

        <cfoutput>
        let column = 0;
        let offset = 0;
        <cfif (form.group_a is "operator")>
            offset = 2;
        </cfif>
        <cfif case_position>
            // case_position is a CF variable with value starts from 1 (not zero like JS) 
            // column position includes invisible columns :: should mirror thead, tfoot
            column = window.dt.column(2 + offset);
            $(column.footer())
                .text( numeral(window.total_cases).format() );
        </cfif>
        <cfif lbs_position>
            // lbs_position is a CF variable with value starts from 1 (not zero like JS) 
            // column position includes invisible columns :: should mirror thead, tfoot
            column = window.dt.column(3 + offset);
            $(column.footer())
                .text( numeral(window.total_pounds).format() );
        </cfif>

        <cfif opp.case_position>
            // opp.case_position is a CF variable with value starts from 1 (not zero like JS) 
            // column position includes invisible columns :: should mirror thead, tfoot
            column = window.dt.column(4 + offset);
            $(column.footer())
                .text( numeral(window.opportunity_total_cases).format() );
        </cfif>
        <cfif opp.lbs_position>
            // opp.lbs_position is a CF variable with value starts from 1 (not zero like JS) 
            // column position includes invisible columns :: should mirror thead, tfoot
            column = window.dt.column(5 + offset);
            $(column.footer())
                .text( numeral(window.opportunity_total_pounds).format() );
        </cfif>
        <cfif each_position>
            // each_position is a CF variable with value starts from 1 (not zero like JS) 
            // column position includes invisible columns :: should mirror thead, tfoot
            column = window.dt.column(6 + offset);
            $(column.footer())
                .text( numeral(window.total_each_volume).format() );
        </cfif>
        <cfif sleeve_position>
            // sleeve_position is a CF variable with value starts from 1 (not zero like JS) 
            // column position includes invisible columns :: should mirror thead, tfoot
            column = window.dt.column(7 + offset);
            $(column.footer())
                .text( numeral(window.total_sleeve_volume).format() );
        </cfif>
        </cfoutput>
    };
</script>

<cfinclude template="edit_volume_footer.cfm">
