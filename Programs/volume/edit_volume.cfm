<cfsilent>
<!---
* ====================================================================================================
*    @File: \programs\volume\edit_volume.cfm
*  @Author: Chris Nguyen
*    @Date: 2019-02-01
*
* @Remarks: "edit_volume_page_size" - number of rows on a page, optional settings, default to 500
*
*           Page rendering flow for best performance with DataTables 1.10.19:
*           1. Server sends header and empty table to user's browser
*           2. Ajax call is triggered from user's browser to retrieve JSON data from server for table body
*           3. DataTables on user's browser renders only the first page, defer rendering of other pages
* ====================================================================================================
--->
<cfscript>
    param name="form.action" default="edit";
    param name="form.forecast" default="0";
    param name="form.product_group_level" default="";

    datatables.version    = "1.10.19";
    // load select extension and button extension to support selection and export to excel
    datatables.extensions = "select,buttons";
    volume_cfc            = createObject("component", "mvc.models.program.volume.volumeApplicator");
    qUOM                  = volume_cfc.getVolumeApplyToUOM(url.program_id);
    qProdGroupTypes       = volume_cfc.getVolumeProductGroupTypes(url.program_id);
    product_label         = application.returned_customer_setting.item_label;

    request.min_max_range = '';
</cfscript>
</cfsilent>

<cfinclude template="/programs/volume/edit_volume_header.cfm">

<cf_include files="#arrayToList([    "/common_files/jQuery.cfm"
                                    ,"/common_files/dataTables2.cfm"
                                    ,"/script/javascript/numeral.min.js"
                                    ,"/script/javascript/numeric/jquery.numeric.min.js"
                                    ,"/styles/css-loader.css"
                                ])#">

<cfset jQueryUI.widgets = "tooltip">
<cfinclude template="/common_files/jQueryUI.cfm">

<style>
    body {
        overflow-y: hidden;
    }
    img.help {
        position: relative;
        top: 3px;
    }
    div.noty_body {
        text-align: center;
    }
    input.review {
        border:1px solid red;
    }
    input.vol, input.total {
        text-align: right;
        width: 4rem;
        border-width: 1px;
        overflow: visible;
        padding-right: .25rem;
    }
    td.vol {
        /* text-align: center; */
    }
    tr, td {
        overflow: hidden;
    }
    div.dt-buttons {
        margin-bottom: 6px;
    }
</style>

<cfscript>
    // checkbox, product number, product description
    column_estimate_sizes = [ 1, 5, 15 ];
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

    // add EACH if configured & determine the position
    if (UOMs contains "EA") {
        arrayAppend(column_estimate_sizes, 5);
        each_position = arrayLen(column_estimate_sizes);
    }
    // add EACH if configured & determine the position
    if (UOMs contains "SL") {
        arrayAppend(column_estimate_sizes, 5);
        sleeve_position = arrayLen(column_estimate_sizes);
    }

    // figure out the width percentages
    column_widths = application.util.array.dtColumnSizeInPercent( column_estimate_sizes );
</cfscript>

<form method="post" name="edit_volume" action="/programs/volume/edit_volume.cfm?<cfoutput>#cgi.query_string#</cfoutput>">

<div class="flex pt-0 pb-2">
    <section class="mr-4">
        <label class="font-semibold tracking-wide mr-1">Display by:</label>
        <select name="product_group_level" class="border">
            <cfoutput query="qProdGroupTypes">
                <option value="#qProdGroupTypes.Product_Group_Level_Id#" <cfif form.product_group_level eq qProdGroupTypes.Product_Group_Level_Id>selected=selected</cfif>>#qProdGroupTypes.Group_Level_Desc#</option>
            </cfoutput>
        </select>
        &nbsp;<img src="/images/help_small.gif" class="help mr-1" title="Changing the current view using the Display By feature will not automatically save any edits you have made to the forecast since your last save event. To see the results of your modifications, please be sure to save first.">
    </section>

    <section class="ml-4 mr-2">
        <label class="font-semibold tracking-wide mr-2">Apply</label>
        <input type="text" name="apply_value" class="border mr-2 w-12 mass" value="">
        <select name="apply_uom" class="border mr-2">
            <cfoutput query="qUOM">
                <cfif trim(qUOM.Abbreviation) neq '%'>
                    <option value="#trim(lcase(qUOM.Abbreviation))#">#qUOM.Abbreviation#</option>
                </cfif>
            </cfoutput>
            <option value="%">%</option>
        </select>
        <select name="apply_target" class="border mr-1">
            <option value="">Apply...</option>
            <option value="selected">To Selected Items</option>
            <option value="all">To All Items</option>
            <cfif qProgram.Opportunity_Volume eq "1">
                <option value="selected_opp">To Selected Opp Items</option>
                <option value="all_opp">To All Opp Items</option>
            </cfif>
            <option value="total" id="total_target">As Total Prg Vol</option>
        </select>
        <img src="/images/help_small.gif" class="help" title="Volume can only be a whole integer. While evenly allocating volume, if volume becomes a fraction it will be rounded up or down accordingly to be come a whole integer.">
    </section>

    <section class="ml-4">
        <button type="button" class="button forecast"  title="Use forecast button to recalculate the estimated<br>volumes and ignore any changes you made.">Forecast</button>
        <button type="button" class="button save" id="save">Save</button>
        <button type="button" class="button save" id="save_close">Save/Close</button>
    </section>

    <section class="text-right flex-1 pt-1 pr-1 text-red-dark">* = user edited record</section>
</div>

<cfif cgi.request_method is "post">
    <!--- reset to default action --->
    <cfset form.action = "edit">
</cfif>

<cfoutput>
    <input type="hidden" name="action" value="#form.action#">
    <input type="hidden" name="forecast" value="#form.forecast#">
    <input type="hidden" name="group_by" value="">
    <input type="hidden" name="program_id" value="#url.program_id#">
    <table class="dataTable display nowrap" id="edit_volume" width="100%">
        <thead>
            <tr>
                <th style="width:#column_widths[1]#%"></th>
                <th style="width:#column_widths[2]#%">#product_label# Number</th>
                <th style="width:#column_widths[3]#%">#product_label# Description</th>
            <cfif case_position>
                <th style="width:#column_widths[case_position]#%;">Cases#min_max_header("cases")#</th>
            <cfelse>
                <th></th>   <!--- hidden column --->
            </cfif>
            <cfif lbs_position>
                <th style="width:#column_widths[lbs_position]#%;">Pounds#min_max_header("pounds")#</th>
            <cfelse>
                <th></th>   <!--- hidden column --->
            </cfif>
            <cfif opp.case_position>
                <th style="width:#column_widths[opp.case_position]#%;">Opp Cases#min_max_header("cases")#</th>
            <cfelse>
                <th></th>   <!--- hidden column --->
            </cfif>
            <cfif opp.lbs_position>
                <th style="width:#column_widths[opp.lbs_position]#%;">Opp Pounds#min_max_header("pounds")#</th>
            <cfelse>
                <th></th>   <!--- hidden column --->
            </cfif>
            <cfif each_position>
                <th style="width:#column_widths[each_position]#%;">Each#min_max_header("each")#</th>
            <cfelse>
                <th></th>   <!--- hidden column --->
            </cfif>
            <cfif sleeve_position>
                <th style="width:#column_widths[sleeve_position]#%;">Sleeve#min_max_header("sleeve")#</th>
            <cfelse>
                <th></th>   <!--- hidden column --->
            </cfif>
            </tr>
        </thead>

        <tfoot>
            <tr>
                <td style="width:#column_widths[1]#%"></td>
                <td style="width:#column_widths[2]#%"></td>
                <td style="width:#column_widths[3]#%;text-align:right !important;" class="font-semibold tracking-wide">Grand Total</td>
            <cfif case_position>
                <td style="width:#column_widths[case_position]#%;"> <input type="text" disabled class="total_cases total"> </td>
            <cfelse>
                <td></td>   <!--- hidden column --->
            </cfif>
            <cfif lbs_position>
                <td style="width:#column_widths[lbs_position]#%;"> <input type="text" disabled class="total_pounds total"> </td>
            <cfelse>
                <td></td>   <!--- hidden column --->
            </cfif>
            <cfif opp.case_position gt 0>
                <td style="width:#column_widths[opp.case_position]#%;"> <input type="text" disabled class="opportunity_total_cases total"> </td>
            <cfelse>
                <td></td>   <!--- hidden column --->
            </cfif>
            <cfif opp.lbs_position>
                <td style="width:#column_widths[opp.lbs_position]#%;"> <input type="text" disabled class="opportunity_total_pounds total"> </td>
            <cfelse>
                <td></td>   <!--- hidden column --->
            </cfif>
            <cfif each_position>
                <td style="width:#column_widths[each_position]#%;"> <input type="text" disabled class="total_each_volume total"> </td>
            <cfelse>
                <td></td>   <!--- hidden column --->
            </cfif>
            <cfif sleeve_position>
                <td style="width:#column_widths[sleeve_position]#%;"> <input type="text" disabled class="total_sleeve_volume total"> </td>
            <cfelse>
                <td></td>   <!--- hidden column --->
            </cfif>
            </tr>
        </tfoot>
    </table>
    </form>
</cfoutput>

<script>

    <!--- string constants --->
    window.previous    = "prev";        // volume input attribute
    window.cases       = "cs";          // volume input class
    window.pounds      = "lbs";         // volume input class
    window.dirty       = "dirty";       // dirty input attribute, it exists when input is changed
    window.opp         = { cases: "o_cs", pounds: "o_lbs" }     // opportunity volume input classes :: must be diff from other volume
    window.attention_css = "review";    // volume input that fails min/max rules
    window.each        = "ea";          // volume input class
    window.sleeve      = "sl";          // volume input class


    <!--- column positions in JSON.data array returned from aJax call --->
    window.columns = {
                        item: 1
                        ,description: 2
                        ,original_cases: 3
                        ,original_pounds: 4
                        ,bsa_foodservice_items_master_id: 5
                        ,net_weight: 6
                        ,user_edited: 7
                        ,opportunity_pounds: 8
                        ,opportunity_cases: 9
                        ,each_volume: 10
                        ,sleeve_volume: 11
    };

    <!--- grand totals in footer --->
    window.total_cases      = 0;
    window.total_pounds     = 0;
    window.opportunity_total_cases  = 0;
    window.opportunity_total_pounds = 0;
    window.total_each_volume        = 0;
    window.total_sleeve_volume      = 0;

    <cfoutput>
        // do not use page size due to Karen wants the mass apply methods go to all pages
        // set it to a ridiculous high value to allow maintenance flexibilities
        window.page_size = 9 * 999999;

        <!--- set up min/max rules with on/off status and value --->
        window.min_rule = { enabled:#(qProgram.Min_Global_Volume is '1' ? 1 : 0)#
                            ,min_value:#(qProgram.VolUOMType is "cases"
                                                    ? qProgram.Min_Global_Volume_Size_CS
                                                    : qProgram.Min_Global_Volume_Size_LBS)#
                            };
        window.max_rule = { enabled:#(qProgram.Max_Global_Volume is '1' ? 1 : 0)#
                            ,max_value:#(qProgram.VolUOMType is "cases"
                                                    ? qProgram.Max_Global_Volume_Size_CS
                                                    : qProgram.Max_Global_Volume_Size_LBS)#
                            };
    </cfoutput>

    <!--- performance tracking --->
    window.dt_duration = duration("DataTables.draw()");

    window.dt = $("table#edit_volume")
                    .DataTable({
                                "ajax": {
                                    data: { <cfoutput>program_id: #url.program_id#, action: "#form.action#",forecast: "#form.forecast#"</cfoutput>,   product_group_level: $("select[name=product_group_level]").val(), group_by: $("input[name=group_by]").val() }
                                    ,type: "POST"
                                    ,url: "/programs/volume/ajax/edit_volume.cfm"
                                }
                                ,"autoWidth": false
                                ,"buttons": [   "selectAll"
                                                , "selectNone"
                                                ,{ extend: "excelHtml5"
                                                    ,autoFilter: false
                                                    ,footer: true
                                                    ,text: "Export to Excel"
                                                    ,exportOptions: {
                                                                        columns:  function ( idx, data, node ) {
                                                                                                // skip checkbox in 1st column and invisible columns
                                                                                                return idx > 0 && node.cellIndex > -1;
                                                                                    }
                                                                        ,format: {  body: function(data, row, column, node) {
                                                                                                                                let input_element = $(node).children("input");
                                                                                                                                // extract input value from td cell
                                                                                                                                return input_element.length > 0
                                                                                                                                            ? input_element.val()
                                                                                                                                            : data;
                                                                                                                }
                                                                                    ,header: function(data, row, column, node) {
                                                                                                                                let line_break = data.indexOf("<br>");
                                                                                                                                return line_break !== -1
                                                                                                                                        ? data.substr(1, line_break - 1)     // exclude min= max=
                                                                                                                                        : data;
                                                                                                                            }
                                                                                    // tfoot data render :: DT could not extract data from input in tfoot!
                                                                                    ,footer: function(data, row, column, node) {
                                                                                                                                if (data.indexOf("opportunity_total_pounds") !== -1)   // lbs column
                                                                                                                                    return numeral(window.opportunity_total_pounds).format();
                                                                                                                                else if (data.indexOf("opportunity_total_cases") !== -1)   // lbs column
                                                                                                                                    return numeral(window.opportunity_total_cases).format();
                                                                                                                                else if (data.indexOf("total_cases") !== -1)         // cases column
                                                                                                                                    return numeral(window.total_cases).format();
                                                                                                                                else if (data.indexOf("total_pounds") !== -1)   // lbs column
                                                                                                                                    return numeral(window.total_pounds).format();
                                                                                                                                else if (data.indexOf("total_each_volume") !== -1)   // each column
                                                                                                                                    return numeral(window.total_each_volume).format();
                                                                                                                                else if (data.indexOf("total_sleeve_volume") !== -1)   // sleeve column
                                                                                                                                    return numeral(window.total_sleeve_volume).format();
                                                                                                                                else
                                                                                                                                    return data;
                                                                                                                            }
                                                                                    }
                                                                        ,modifier: { selected: null }   // export all rows regardless of selected status
                                                                        ,orthogonal: "export"           // export operation indicator
                                                                    }
                                                }
                                            ]
                                ,"columns": [
                                        <cfoutput>
                                             { "width": "#column_widths[1]#%", "orderable": false, className: 'select-checkbox' }
                                            ,{ "width": "#column_widths[2]#%" }
                                            ,{ "width": "#column_widths[3]#%" }
                                        <cfif case_position eq 0>
                                            ,{ "visible": false }
                                        <cfelse>
                                            ,{ "width": "#column_widths[case_position]#%",  className: 'vol', "orderDataType": "dom-input", "render": function (data, type, row) {
                                                                                                                                return type === "export"
                                                                                                                                        ? row[ window.columns.original_cases ]
                                                                                                                                        : "<input type='text' class='vol " + window.cases + " ' value='"
                                                                                                                                            + numeral(row[ window.columns.original_cases] ).format()
                                                                                                                                            + "'"
                                                                                                                                            <!--- assign cousin lbs class if it exists --->
                                                                                                                                            + " cousin=" + <cfif lbs_position eq 0>0<cfelse> window.pounds </cfif> + " "
                                                                                                                                            + " name='cs_" + row[ window.columns.bsa_foodservice_items_master_id ] + "' "
                                                                                                                                            <!--- previous value for grand total calculation --->
                                                                                                                                            + window.previous + "='"
                                                                                                                                            + row[ window.columns.original_cases ]
                                                                                                                                            + "'>"
                                                                                                                                            <!--- user edited indicator --->
                                                                                                                                            + " <span class='text-red-dark' "
                                                                                                                                            + (row[ window.columns.user_edited ] === 0 ? "style='visibility:hidden'" : "")
                                                                                                                                            + ">*</span>"
                                                                                                                                            ;
                                                                                                                            }   }
                                        </cfif>
                                        <cfif lbs_position eq 0>
                                            ,{ "visible": false }
                                        <cfelse>
                                            ,{ "width": "#column_widths[lbs_position]#%",  className: 'vol', "orderDataType": "dom-input", "render": function (data, type, row) {
                                                                                                                            return type === "export"
                                                                                                                                   ? row[ window.columns.original_pounds ]
                                                                                                                                   : "<input type='text' class='vol " + window.pounds + " ' value='"
                                                                                                                                        + numeral(row[ window.columns.original_pounds ]).format()
                                                                                                                                        + "'"
                                                                                                                                        <!--- assign cousin cases class if it exists --->
                                                                                                                                        + " cousin=" + <cfif case_position eq 0>0<cfelse> window.cases </cfif> + " "
                                                                                                                                        + " name='lbs_" + row[ window.columns.bsa_foodservice_items_master_id ] + "' "
                                                                                                                                        <!--- previous value for grand total calculation --->
                                                                                                                                        + window.previous + "='"
                                                                                                                                        + row[ window.columns.original_pounds ]
                                                                                                                                        + "'>"
                                                                                                                                        <!--- user edited indicator --->
                                                                                                                                        + " <span class='text-red-dark' "
                                                                                                                                        + (row[ window.columns.user_edited ] === 0 ? "style='visibility:hidden'" : "")
                                                                                                                                        + ">*</span>"
                                                                                                                                        ;
                                                                                                                }
                                                }
                                        </cfif>


                                        <cfif opp.case_position eq 0>
                                            ,{ "visible": false }
                                        <cfelse>
                                            ,{ "width": "#column_widths[opp.case_position]#%",  className: 'vol', "orderDataType": "dom-input", "render": function (data, type, row) {
                                                                                                                                return type === "export"
                                                                                                                                        ? row[ window.columns.opportunity_cases ]
                                                                                                                                        : "<input type='text' class='vol " + window.opp.cases + " ' value='"
                                                                                                                                            + numeral(row[ window.columns.opportunity_cases] ).format()
                                                                                                                                            + "'"
                                                                                                                                            <!--- assign cousin lbs class if it exists --->
                                                                                                                                            + " cousin=" + <cfif opp.lbs_position eq 0>0<cfelse> window.opp.pounds </cfif> + " "
                                                                                                                                            + " name='ocs_" + row[ window.columns.bsa_foodservice_items_master_id ] + "' "
                                                                                                                                            <!--- previous value for grand total calculation --->
                                                                                                                                            + window.previous + "='"
                                                                                                                                            + row[ window.columns.opportunity_cases ]
                                                                                                                                            + "'>"
                                                                                                                                            <!--- user edited indicator --->
                                                                                                                                            + " <span class='text-red-dark' "
                                                                                                                                            + (row[ window.columns.user_edited ] === 0 ? "style='visibility:hidden'" : "")
                                                                                                                                            + ">*</span>"
                                                                                                                                            ;
                                                                                                                            }   }
                                        </cfif>
                                        <cfif opp.lbs_position eq 0>
                                            ,{ "visible": false }
                                        <cfelse>
                                            ,{ "width": "#column_widths[lbs_position]#%",  className: 'vol', "orderDataType": "dom-input", "render": function (data, type, row) {
                                                                                                                            return type === "export"
                                                                                                                                   ? row[ window.columns.opportunity_pounds ]
                                                                                                                                   : "<input type='text' class='vol " + window.opp.pounds + " ' value='"
                                                                                                                                        + numeral(row[ window.columns.opportunity_pounds ]).format()
                                                                                                                                        + "'"
                                                                                                                                        <!--- assign cousin cases class if it exists --->
                                                                                                                                        + " cousin=" + <cfif opp.case_position eq 0>0<cfelse> window.opp.cases </cfif> + " "
                                                                                                                                        + " name='olbs_" + row[ window.columns.bsa_foodservice_items_master_id ] + "' "
                                                                                                                                        <!--- previous value for grand total calculation --->
                                                                                                                                        + window.previous + "='"
                                                                                                                                        + row[ window.columns.opportunity_pounds ]
                                                                                                                                        + "'>"
                                                                                                                                        <!--- user edited indicator --->
                                                                                                                                        + " <span class='text-red-dark' "
                                                                                                                                        + (row[ window.columns.user_edited ] === 0 ? "style='visibility:hidden'" : "")
                                                                                                                                        + ">*</span>"
                                                                                                                                        ;
                                                                                                                }
                                                }
                                        </cfif>
                                        <cfif each_position eq 0>
                                            ,{ "visible": false }
                                        <cfelse>
                                            ,{ "width": "#column_widths[each_position]#%",  className: 'vol', "orderDataType": "dom-input", "render": function (data, type, row) {
                                                                                                                                return type === "export"
                                                                                                                                        ? row[ window.columns.each_volume ]
                                                                                                                                        : "<input type='text' class='vol " + window.each + " ' value='"
                                                                                                                                            + numeral(row[ window.columns.each_volume] ).format()
                                                                                                                                            + "'"
                                                                                                                                            <!--- assign cousin lbs class if it exists --->
                                                                                                                                            + " cousin=0 "
                                                                                                                                            + " name='ea_" + row[ window.columns.bsa_foodservice_items_master_id ] + "' "
                                                                                                                                            <!--- previous value for grand total calculation --->
                                                                                                                                            + window.previous + "='"
                                                                                                                                            + row[ window.columns.each_volume ]
                                                                                                                                            + "'>"
                                                                                                                                            <!--- user edited indicator --->
                                                                                                                                            + " <span class='text-red-dark' "
                                                                                                                                            + (row[ window.columns.user_edited ] === 0 ? "style='visibility:hidden'" : "")
                                                                                                                                            + ">*</span>"
                                                                                                                                            ;
                                                                                                                            }   }
                                        </cfif>
                                        <cfif sleeve_position eq 0>
                                            ,{ "visible": false }
                                        <cfelse>
                                            ,{ "width": "#column_widths[sleeve_position]#%",  className: 'vol', "orderDataType": "dom-input", "render": function (data, type, row) {
                                                                                                                                return type === "export"
                                                                                                                                        ? row[ window.columns.sleeve_volume ]
                                                                                                                                        : "<input type='text' class='vol " + window.sleeve + " ' value='"
                                                                                                                                            + numeral(row[ window.columns.sleeve_volume] ).format()
                                                                                                                                            + "'"
                                                                                                                                            <!--- assign cousin lbs class if it exists --->
                                                                                                                                            + " cousin=0 "
                                                                                                                                            + " name='sl_" + row[ window.columns.bsa_foodservice_items_master_id ] + "' "
                                                                                                                                            <!--- previous value for grand total calculation --->
                                                                                                                                            + window.previous + "='"
                                                                                                                                            + row[ window.columns.sleeve_volume ]
                                                                                                                                            + "'>"
                                                                                                                                            <!--- user edited indicator --->
                                                                                                                                            + " <span class='text-red-dark' "
                                                                                                                                            + (row[ window.columns.user_edited ] === 0 ? "style='visibility:hidden'" : "")
                                                                                                                                            + ">*</span>"
                                                                                                                                            ;
                                                                                                                            }   }
                                        </cfif>
                                        </cfoutput>
                                        ]
                                ,"deferRender": true        // set it to true to render only page one for best performance
                                ,"dom": "Bt"
                                ,"initComplete": function( settings, json ) {
                                                                                <!--- change buttons style by calling a function defined in dataTables2.cfm--->
                                                                                draw_callback();
                                                                                window.total_cases   = json.total_cases;
                                                                                window.total_pounds  = json.total_pounds;
                                                                                window.opportunity_total_cases  = json.opportunity_total_cases;
                                                                                window.opportunity_total_pounds = json.opportunity_total_pounds;
                                                                                window.total_each_volume = json.total_each_volume;
                                                                                window.total_sleeve_volume = json.total_sleeve_volume;
                                                                                refresh_totals();
                                                                            }
                                ,"orderClasses": false
                                ,"order": []
                                ,"rowId": function(row) { return row[window.columns.bsa_foodservice_items_master_id]; }        // BSA_Foodservice_Items_Master_ID
                                ,"paging": false
                                ,"pageLength": window.page_size
                                ,"scrollY": pixelToVH(get_grid_full_height("edit_volume", -75)) + "vh"
                                ,"scrollCollapse": true
                                ,"searching": false
                                ,"select": { style: "multi", selector: "td:first-child"}
                            });

$.fn.dataTable.ext.order['dom-input'] = function (settings, col) {
    return this.api().column(col, { order: 'index' }).nodes().map(function (td, i) {
        return $('input', td).val();
    });
}

    window.dt.on( 'draw', function() {
                        <!------------------------------>
                        <!--- Event for input volume --->
                        <!------------------------------>
                        $("input.vol")
                                        // .off()                                                      // remove existing handlers
                                        .numeric( {decimal: false, negative: false} )               // numeric data entry restriction
                                        .focus(function() {
                                                <!--- save current value into previous attribute --->
                                                $(this).attr(window.previous, $(this).val());
                                            })
                                        .change(function(){
                                                    let orig_input = $(this);
                                                    <!--- change zero value to one --->
                                                    if (orig_input.val() == 0) {
                                                        orig_input.val(1);
                                                    }

                                                    <!--- quick way to calculate total by just reducing total by previous value and then add in the new value --->
                                                    if ( orig_input.hasClass(window.opp.cases) ) {
                                                        window.opportunity_total_cases += delta_volume(orig_input);
                                                    }
                                                    else if ( orig_input.hasClass(window.opp.pounds) ) {
                                                        window.opportunity_total_pounds += delta_volume(orig_input);
                                                    }
                                                    else if ( orig_input.hasClass(window.cases) ) {
                                                        window.total_cases += delta_volume(orig_input);
                                                    }
                                                    else if ( orig_input.hasClass(window.pounds) ) {
                                                        window.total_pounds += delta_volume(orig_input);
                                                    }
                                                    else if ( orig_input.hasClass(window.each) ) {
                                                        window.total_each_volume += delta_volume(orig_input);
                                                    }
                                                    else if ( orig_input.hasClass(window.sleeve) ) {
                                                        window.total_sleeve_volume += delta_volume(orig_input);
                                                    }

                                                    set_volume(orig_input, orig_input.val());
                                                    refresh_cousin(orig_input, "change");
                                                    refresh_totals();
                                                    save_recommeded();
                                                    // let d = new Date(); console.log(d.toLocaleTimeString());
                                            });
                            } );        <!--- window.dt.on( 'draw' Đ --->

    Noty.overrideDefaults({
        closeWith: ["click", "button"],
        layout: "center",
        killer: true,
        theme: "metroui",
        timeout: false,
        type: "error",
        animation: { open: null, close: null }
    });

    // return the delta difference in between previous volume and current volume :: volume is a jquery object
    function delta_volume(volume) {
        return +volume.val() - +volume.attr( window.previous ).replace(/,/g, '');
    };

    // update volume with a new value :: volume is a jquery object
    function set_volume(volume, new_value) {
        volume
            .val(new_value)                         // save new value
            .attr(window.previous, new_value)       // refresh previous value
            .attr(window.dirty, 1)                  // flag as dirty (changed)
            .next()                                 // traverse to user edit indicator
            .css("visibility", "visible");          // display user edited indicator
    }

    function save_recommeded(){
        if (!$("button.save").hasClass("recommended")) {
            $("button.save").addClass("recommended");
            // data changed :: export to excel has no ability to get latest changes so disable it
            // $("button.buttons-excel").attr("disabled", "disabled").addClass("disabled");
        }
    };

    <!-------------->
    <!--- Events --->
    <!-------------->
    <!--- redraw the page when window is resized --->
    $(window).resize(function(){
        window.dt.draw();
    });

    $("select[name=product_group_level]").change(function(){
        $("form[name=edit_volume]").submit();
    });

    $("select[name=apply_uom]").change(function(){
        <!--- disable As Total Prg Vol option when method is percentage --->
        if ($(this).val() === "%")
            $("#total_target").attr("disabled", "disabled");
        else
            $("#total_target").removeAttr("disabled");
    });

    $("input[name=exclude_auto_volume]").change(function(){
        $(this).attr(window.dirty, 1)                  // flag as dirty (changed)
    });

    $("select[name=apply_target]").change(function(){
        let apply_value  = $("input[name=apply_value]").val();
        let apply_uom    = $("select[name=apply_uom]").val();
        let apply_target = $(this).val();

        <!--- bail out when nothing is selected --->
        if (apply_target === "")
            return;

        let selected_rows_count = apply_target === "all" || apply_target === "all_opp"
                                    ? window.dt.rows().count()
                                    : window.dt.rows( { selected:true } ).count();


        // reset apply target back to nothing
        $(this).val("");

        <!--- validate apply value --->
        let errors = [];
        if (apply_value === '') {
            errors.push("Please enter a value to mass apply.");
        }
        else if (apply_value == 0) {
            errors.push("Please enter a non zero value to mass apply.");
        }
        else if (apply_value < 0 && apply_uom !== "%") {
            errors.push("Sorry, negative value is only applicable to percentage (%) method.");
        }
        else if (apply_value <= -100) {
            errors.push("Sorry, your apply value is not valid.<br><br>Please re-enter a negative value<br>between -1 and -99.");
        }

        if (errors.length) {
            new Noty({ text:errors.join("<br>") }).show();
            return;
        }

        if (apply_target === "total") {
            apply_as_total_prg_vol(apply_value, apply_uom, apply_target);
            return;
        }

        <!--- mass apply when rows selection exists --->
        if ( selected_rows_count > 0 ) {
            apply_by_quantities(apply_value, apply_uom, apply_target, selected_rows_count);
        }
        else {
            new Noty({ text:<cfoutput>"Please select at least one #lcase(product_label)# to apply."</cfoutput>, timeout: 2500 }).show();
        }
    });             <!--- $("#apply_target").change() --->

    $("button.forecast").click(function(){
        show_loader("Recalculating volume, please wait...", 1500);
        $("input[name=action]").val("EDIT-FORECAST");
        $("input[name=forecast]").val("1");
        $("form[name=edit_volume]").submit();
    });

    $("button.save").click(function(){
        <!--- validate based on min/max rules defined in program template settings --->
        <!--- validate cases --->
        let errors = 0;
        if (window.min_rule.enabled || window.max_rule.enabled) {
            <cfif qProgram.VolUOMType is "cases">
                errors = min_max_errors( window.cases );
                if (errors) {
                    return false;
                }
                <cfif qProgram.Opportunity_Volume eq "1">
                    errors += min_max_errors( window.opp.cases );
                </cfif>
                if (errors) {
                    return false;
                }
            </cfif>
            <cfif qProgram.VolUOMType is "pounds">
                <!--- validate pounds --->
                    errors = min_max_errors( window.pounds );
                    if (errors) {
                        return false;
                    }
                    <cfif qProgram.Opportunity_Volume eq "1">
                        errors += min_max_errors( window.opp.pounds );
                    </cfif>
                    if (errors) {
                        return false;
                    }
            </cfif>
        }

        <!--- use LoadChain() to provide visual changes in processing lengthy JS operations --->
        let form       = {};
        let loadChain  = new LoadChain();
        let save_close = $(this).text().toLowerCase().indexOf("close");

        loadChain.push(function() { show_loader( "Saving changes, please wait...", 1500 ); });

        loadChain.push(function() {
            let dirty_count = 0;
            // save all changed inputs into a JS form structure to pass to Ajax backend
            $( window.dt.$("input[dirty]")
                        .serializeArray() ).each(function(index, element) {
                                                dirty_count++;
                                                form[element.name] = element.value
                                            });

            // include additional parameters to pass
            form.program_id          = $("input[name=program_id]").val();
            form.product_group_level = $("select[name=product_group_level]").val();
            form.group_by            = $("input[name=group_by]").val();
            form.exclude_auto_volume = $("input[name=exclude_auto_volume]").prop("checked")
                                            ? 1
                                            : 0;
            form.forecast = $("input[name=forecast]").val();
            if (dirty_count || $("input[name=exclude_auto_volume][dirty]").length || $("input[name=forecast]").val()) {
                $.ajax({
                        async: false,
                        contentType: "application/json",
                        data: JSON.stringify( form ),
                        dataType: "json",
                        type: "POST",
                        url: "/mvc/Models/Program/Volume/VolumeApplicator.cfc?method=saveVolume&p=" + $.now()
                });
            }

            if (save_close > -1) {
                let parent_href = window.opener.location.href;
                <!--- ~~ add fromflex=1 to parent url ~~ --->
                if (parent_href.toLowerCase().indexOf("&fromflex") < 0) {
                    parent_href = parent_href + "&FromFlex=1";
                }
                <!---  refresh view program page with updated volume  --->
                window.opener.location.href = parent_href;
                window.close(); self.close();
            }
            else {
                $("input[name=forecast]").val("0");
                $("form[name=edit_volume]").submit();
            }
        });

        loadChain.start();
    });     <!--- ("button.save") --->

    <!----------->
    <!--- API --->
    <!----------->
    <!--------------------------------->
    function min_max_errors( uom_class ) {
    <!--------------------------------->
        let error_count = 0;
        window.dt.$("input." + uom_class)
            // .removeClass(window.attention_css)
            .each(function(){
            <!--- validate against minimum --->
            if (window.min_rule.enabled) {
                if ( $(this).val() < window.min_rule.min_value ) {
                    $(this).addClass(window.attention_css);
                    error_count++;
                }
            }
            <!--- validate against maximum --->
            if (window.max_rule.enabled) {
                if ( $(this).val() > window.max_rule.max_value ) {
                    $(this).addClass(window.attention_css);
                    error_count++;
                }
            }
        });

        if (error_count) {
            let msg = numeral(error_count).format()
                            + " volume"
                            + (error_count > 1 ? "s are" : " is")
                            + " out of range (" + "<cfoutput>#replaceNoCase(request.min_max_range, "=", " of ", "all")#</cfoutput>" + "), set in the template.<br><br>Please review and adjust.";
            new Noty({ text:msg }).show();
        }

        return error_count;
    };      <!--- min_max_errors --->

    <!-------------------------------------------------------------------->
    function apply_as_total_prg_vol(apply_value, apply_uom, apply_target) {
    <!-------------------------------------------------------------------->
        <!--- use LoadChain() to provide visual changes in processing lengthy JS operations --->
        let loadChain = new LoadChain();
        <!--- apply to all rows, ignore rows selection in 1st column --->
        let rows_count = window.dt.rows().count();

        <!--- too many rows selected :: redraw table to bring back all rows --->
        if (rows_count > window.page_size) {
            loadChain.push(function() { show_loader("Applying changes to " + numeral(rows_count).format() + <cfoutput>" #lcase(product_label)#s, please wait..."</cfoutput>); });
            loadChain.push(function() { window.dt.page.len(-1).draw(); });
        }

        loadChain.push(function(){
            let equal_splitted_amount = Math.floor(apply_value / rows_count);
            let remainder = +apply_value - (+equal_splitted_amount * rows_count);

            <!--- apply to cases --->
            if ( apply_uom === "cs") {
                $("tr input." + window.cases).each(function() {
                    let orig_input = $(this);
                    <!--- add one to splitted amount when remainder is greater than 0 --->
                    let calculated_volume = equal_splitted_amount + (remainder > 0 ? 1: 0);
                    remainder = remainder - 1;
                    <!--- quick way to calculate total by reducing total by previous value and then add the new value --->
                    window.total_cases += +calculated_volume - +orig_input.attr(window.previous);
                    set_volume(orig_input, calculated_volume);
                    refresh_cousin( orig_input );
                });
            }

            <!--- apply to pounds --->
            if ( apply_uom === "lbs") {
                $("tr input." + window.pounds).each(function() {
                    let orig_input = $(this);
                    <!--- add one to splitted amount when remainder is greater than 0 --->
                    let calculated_volume = equal_splitted_amount + (remainder > 0 ? 1: 0);
                    remainder = remainder - 1;
                    <!--- quick way to calculate total by reducing total by previous value and then add the new value --->
                    window.total_pounds +=  +calculated_volume - +orig_input.attr(window.previous);
                    set_volume(orig_input, calculated_volume);
                    refresh_cousin( orig_input );
                });
            }

            <!--- apply to each --->
            if ( apply_uom === "ea") {
                $("tr input." + window.each).each(function() {
                    let orig_input = $(this);
                    <!--- add one to splitted amount when remainder is greater than 0 --->
                    let calculated_volume = equal_splitted_amount + (remainder > 0 ? 1: 0);
                    remainder = remainder - 1;
                    <!--- quick way to calculate total by reducing total by previous value and then add the new value --->
                    window.total_each_volume += +calculated_volume - +orig_input.attr(window.previous);
                    set_volume(orig_input, calculated_volume);
                    refresh_cousin( orig_input );
                });
            }

            <!--- apply to each --->
            if ( apply_uom === "sl") {
                $("tr input." + window.sleeve).each(function() {
                    let orig_input = $(this);
                    <!--- add one to splitted amount when remainder is greater than 0 --->
                    let calculated_volume = equal_splitted_amount + (remainder > 0 ? 1: 0);
                    remainder = remainder - 1;
                    <!--- quick way to calculate total by reducing total by previous value and then add the new value --->
                    window.total_sleeve_volume += +calculated_volume - +orig_input.attr(window.previous);
                    set_volume(orig_input, calculated_volume);
                    refresh_cousin( orig_input );
                });
            }
        });

        loadChain.push(function() {
            refresh_totals();
            save_recommeded();
            <!--- change page size back to original --->
            if (rows_count > window.page_size) {
                $("div.loader").hide();
                window.dt.page.len( window.page_size ).draw();
            }
        });

        loadChain.start();
    };   <!--- function apply_as_total_prg_vol() --->


    <!-------------------------------------------------------------------------------------->
    function apply_by_quantities(apply_value, apply_uom, apply_target, selected_rows_count) {
    <!-------------------------------------------------------------------------------------->
        <!--- use LoadChain() to provide visual changes in processing lengthy JS operations --->
        let loadChain = new LoadChain();

        <!--- too many rows selected :: redraw table to bring back all rows --->
        if (selected_rows_count > window.page_size) {
            loadChain.push(function() { show_loader("Applying changes to " + numeral(selected_rows_count).format() + <cfoutput>" #lcase(product_label)#s, please wait..."</cfoutput>); });
            loadChain.push(function() { window.dt.page.len(-1).draw(); });
        }

        loadChain.push(function(){
            <!--- assign rows selector based on apply target --->
            let tr_selector = ( apply_target === "selected" || apply_target === "selected_opp"
                                        ? "tr.selected"
                                        : "tr" );

            <!--- apply to cases --->
            if ( apply_uom === "cs") {
                let column_selector = (apply_target === "selected_opp" || apply_target === "all_opp"
                                            ? window.opp.cases
                                            : window.cases);
                $(tr_selector + " input." + column_selector).each(function() {
                    let orig_input = $(this);
                    let delta_value = +apply_value - +orig_input.attr(window.previous);
                    <!--- quick way to calculate total by reducing total by previous value and then add the new value --->
                    if (column_selector === window.opp.cases)
                        window.opportunity_total_cases += delta_value;
                    else {
                        window.total_cases += delta_value;
                    }
                    set_volume(orig_input, apply_value);
                    refresh_cousin( orig_input );
                });
            }

            <!--- apply to sleeve --->
            if ( apply_uom === "sl") {
                let column_selector = window.sleeve;
                $(tr_selector + " input." + column_selector).each(function() {
                    let orig_input = $(this);
                    let delta_value = +apply_value - +orig_input.attr(window.previous);
                    <!--- quick way to calculate total by reducing total by previous value and then add the new value --->
                    window.total_sleeve_volume += delta_value;
                    set_volume(orig_input, apply_value);
                    refresh_cousin( orig_input );
                });
            }

            <!--- apply to each --->
            else if ( apply_uom === "ea") {
                let column_selector = window.each;
                $(tr_selector + " input." + column_selector).each(function() {
                    let orig_input = $(this);
                    let delta_value = +apply_value - +orig_input.attr(window.previous);
                    <!--- quick way to calculate total by reducing total by previous value and then add the new value --->
                    window.total_each_volume += delta_value;
                    set_volume(orig_input, apply_value);
                    refresh_cousin( orig_input );
                });
            }

            <!--- apply to pounds --->
            else if ( apply_uom === "lbs") {
                let column_selector = (apply_target === "selected_opp" || apply_target === "all_opp"
                                            ? window.opp.pounds
                                            : window.pounds);
                $(tr_selector + " input." + column_selector).each(function() {
                    let orig_input = $(this);
                    let delta_value = +apply_value - +orig_input.attr(window.previous);
                    <!--- quick way to calculate total by reducing total by previous value and then add the new value --->
                    if (column_selector === window.opp.pounds) {
                        window.opportunity_total_pounds += delta_value;
                    }
                    else {
                        window.total_pounds += delta_value;
                    }
                    set_volume(orig_input, apply_value);
                    refresh_cousin( orig_input );
                });
            }

            <!--- apply based on % to both cases and pounds --->
            else if ( apply_uom === "%") {
                let percentage_value = +apply_value;
                let column_selector = (apply_target === "selected_opp" || apply_target === "all_opp"
                                        ? tr_selector + " input." + window.opp.cases + "," + tr_selector + " input." + window.opp.pounds
                                        : tr_selector + " input." + window.cases + "," + tr_selector + " input." + window.pounds + "," + tr_selector + " input." + window.each + "," + tr_selector + " input." + window.sleeve);
                $(column_selector).each(function() {
                    let orig_input        = $(this)
                        ,current_value    = orig_input.val().replace(",", "")
                        ,new_value        = Math.round( +current_value + (+current_value * percentage_value / 100) );

                    <!--- safeguard :: reset new value to 1 when it less than or equal to zero :: they are invalid values --->
                    new_value = ( new_value <= 0 ? 1 : new_value );
                    let delta_value = +new_value - +orig_input.attr(window.previous);

                    <!--- quick way to calculate total by reducing total by previous value and then add the new value --->
                    if (orig_input.hasClass(window.cases)) {
                        window.total_cases += delta_value;
                    }
                    else if (orig_input.hasClass(window.pounds)) {
                        window.total_pounds += delta_value;
                    }
                    else if (orig_input.hasClass(window.opp.cases)) {
                        window.opportunity_total_cases += delta_value;
                    }
                    else if (orig_input.hasClass(window.opp.pounds)) {
                        window.opportunity_total_pounds += delta_value;
                    }
                    else if (orig_input.hasClass(window.each)) {
                        window.total_each_volume += delta_value;
                    }
                    else if (orig_input.hasClass(window.sleeve)) {
                        window.total_sleeve_volume += delta_value;
                    }

                    set_volume(orig_input, new_value);
                });
            }
        });

        loadChain.push(function() {
            refresh_totals();
            save_recommeded();
            <!--- change page size back to original --->
            if (selected_rows_count > window.page_size) {
                $("div.loader").hide();
                window.dt.page.len( window.page_size ).draw();
            }
        });

        loadChain.start();
    }; <!--- function mass_apply_by_quantities() --->



    <!------------------------>
    function refresh_totals() {
    <!------------------------>
        <cfoutput>
        let column = 0;
        <cfif case_position>
            // case_position is a CF variable with value starts from 1 (not zero like JS)
            // column position includes invisible columns :: should mirror thead, tfoot
            column = window.dt.column(3);
            $(column.footer())
                .children("input")
                .val( numeral(window.total_cases).format() );
        </cfif>
        <cfif lbs_position>
            // lbs_position is a CF variable with value starts from 1 (not zero like JS)
            // column position includes invisible columns :: should mirror thead, tfoot
            column = window.dt.column(4);
            $(column.footer())
                .children("input")
                .val( numeral(window.total_pounds).format() );
        </cfif>

        <cfif opp.case_position>
            // opp.case_position is a CF variable with value starts from 1 (not zero like JS)
            // column position includes invisible columns :: should mirror thead, tfoot
            column = window.dt.column(5);
            $(column.footer())
                .children("input")
                .val( numeral(window.opportunity_total_cases).format() );
        </cfif>
        <cfif opp.lbs_position>
            // opp.lbs_position is a CF variable with value starts from 1 (not zero like JS)
            // column position includes invisible columns :: should mirror thead, tfoot
            column = window.dt.column(6);
            $(column.footer())
                .children("input")
                .val( numeral(window.opportunity_total_pounds).format() );
        </cfif>
        <cfif each_position>
            // each_position is a CF variable with value starts from 1 (not zero like JS)
            // column position includes invisible columns :: should mirror thead, tfoot
            column = window.dt.column(7);
            $(column.footer())
                .children("input")
                .val( numeral(window.total_each_volume).format() );
        </cfif>
        <cfif sleeve_position>
            // sleeve_position is a CF variable with value starts from 1 (not zero like JS)
            // column position includes invisible columns :: should mirror thead, tfoot
            column = window.dt.column(8);
            $(column.footer())
                .children("input")
                .val( numeral(window.total_sleeve_volume).format() );
        </cfif>
        </cfoutput>
    };


    <!---------------------------------------------------------------->
    <!--- calculate totals for the otheruom input on the same row --->
    <!---------------------------------------------------------------->
    <!------------------------------------>
    function refresh_cousin( orig_input, operation ) {
    <!------------------------------------>
        operation = operation || "";

        if (orig_input.attr("cousin") === '')
            return;

        <!--- find the other uom cousin input --->
        // travel back to td parent, td uncles and locate the cousin input
        let cousin_input = orig_input
                                .parent()
                                .siblings()                 // uncles
                                .children("input." + orig_input.attr("cousin"));
		// console.log("TCL: functionrefresh_cousin -> cousin_input", cousin_input);

        <!--- the other uom cousin does not exist :: bail out --->
        if (cousin_input.length <= 0)
            return;

        let new_cases = 0, new_pounds = 0;
        <!--- find hidden net weight in the current row --->
        let net_weight = window.dt.row( orig_input.closest("tr") ).data()[ window.columns.net_weight ];

        <!--- calculate new opportunity pounds value --->
        if ( orig_input.hasClass(window.opp.cases) ) {
            new_pounds = Math.round(orig_input.val() * net_weight);

            // JIRA FL-125 - Automated Adjustments for zero value
            // If the pounds value is 0 and the net weight of that product is less than 1, then set the pounds
            // value to be 1 and then set the cases accordingly based on net weight. (pounds divided by net weight)
            if (operation === "change" && new_pounds == 0 && net_weight < 1) {
                new_pounds = 1;
                new_cases  = Math.round(new_pounds / net_weight);   // refresh cases :: override entered value
                window.opportunity_total_cases += +new_cases - +orig_input.attr(window.previous);     // update total
                set_volume(orig_input, new_cases);                  // refresh previous value & edited flag
            }

            window.opportunity_total_pounds += +new_pounds - +cousin_input.attr(window.previous);  // update total
            set_volume(cousin_input, new_pounds);               // refresh previous value & edited flag
        }

        <!--- calculate new opportunity cases value --->
        else if ( orig_input.hasClass(window.opp.pounds) ) {
            new_cases = Math.round(orig_input.val() / net_weight);

            // JIRA FL-125 - Automated Adjustments for zero value
            // If the cases value is 0 then set the cases value to be 1 and then set the pounds accordingly
            // based on net weight. (cases multiplied by net weight)
            if (operation === "change" && new_cases == 0 ) {
                new_cases  = 1;
                new_pounds = Math.round(new_cases * net_weight);    // refresh cases :: override entered value
                window.opportunity_total_pounds += +new_pounds - +orig_input.attr(window.previous);    // update total
                set_volume(orig_input, new_pounds);                 // refresh previous value & edited flag
            }

            window.opportunity_total_cases += +new_cases - +cousin_input.attr(window.previous);       // update total
            set_volume(cousin_input, new_cases);                    // refresh previous & edited flag
        }

        <!--- calculate new pounds value --->
        else if ( orig_input.hasClass(window.cases) ) {
            new_pounds = Math.round(orig_input.val() * net_weight);

            // JIRA FL-125 - Automated Adjustments for zero value
            // If the pounds value is 0 and the net weight of that product is less than 1, then set the pounds
            // value to be 1 and then set the cases accordingly based on net weight. (pounds divided by net weight)
            if (operation === "change" && new_pounds == 0 && net_weight < 1) {
                new_pounds = 1;
                new_cases  = Math.round(new_pounds / net_weight);   // refresh cases :: override entered value
                window.total_cases += +new_cases - +orig_input.attr(window.previous);     // update total
                set_volume(orig_input, new_cases);                  // refresh previous value & edited flag
            }

            window.total_pounds += +new_pounds - +cousin_input.attr(window.previous);  // update total
            set_volume(cousin_input, new_pounds);               // refresh previous value & edited flag
        }

        <!--- calculate new cases value --->
        else if ( orig_input.hasClass(window.pounds) ) {
            new_cases = Math.round(orig_input.val() / net_weight);

            // JIRA FL-125 - Automated Adjustments for zero value
            // If the cases value is 0 then set the cases value to be 1 and then set the pounds accordingly
            // based on net weight. (cases multiplied by net weight)
            if (operation === "change" && new_cases == 0 ) {
                new_cases  = 1;
                new_pounds = Math.round(new_cases * net_weight);    // refresh cases :: override entered value
                window.total_pounds += +new_pounds - +orig_input.attr(window.previous);    // update total
                set_volume(orig_input, new_pounds);                 // refresh previous value & edited flag
            }

            window.total_cases += +new_cases - +cousin_input.attr(window.previous);       // update total
            set_volume(cousin_input, new_cases);                    // refresh previous & edited flag
        }
    };       <!--- refresh_cousin() --->

    $('.deci').numeric( {decimal: true, negative: false} );
    $('.mass').numeric( {decimal: true, negative: true}  );

/*
ENTER KEY WILL MOVE FOCUES TO NEXT INPUT
*/
$(document).on("keypress", "input", function(e){
    var inputLength = ($(".dataTable input.vol").length);
    if( e.which == 13 ) {
        var inputs = $(".dataTable input.vol");
        var nextIndex = inputs.index(this) + 1;

        if(nextIndex < inputLength){
            inputs[nextIndex].focus();
        }

    }
});

</script>


<!---------------------------------------------------------------------------------------------------------->
<cffunction name="min_max_header" output="false" hint="Returns min max information to display in the header">
<!---------------------------------------------------------------------------------------------------------->
    <cfargument name="uom" required="true">
    <cfset local.result = []>

    <cfif arguments.uom is "cases" and arguments.uom is qProgram.VolUOMType>
        <cfif qProgram.Min_Global_Volume is "1">
            <cfset arrayAppend(local.result, "min=" & qProgram.Min_Global_Volume_Size_CS)>
        </cfif>
        <cfif qProgram.Max_Global_Volume is "1">
            <cfset arrayAppend(local.result, "max=" & qProgram.Max_Global_Volume_Size_CS)>
        </cfif>
        <!--- save the range for validation error message in JS --->
        <cfset request.min_max_range = arrayToList(local.result, ", ")>

    <cfelseif arguments.uom is "pounds" and arguments.uom is qProgram.VolUOMType>
        <cfif qProgram.Min_Global_Volume is "1">
            <cfset arrayAppend(local.result, "min=" & qProgram.Min_Global_Volume_Size_LBS)>
        </cfif>
        <cfif qProgram.Max_Global_Volume is "1">
            <cfset arrayAppend(local.result, "max=" & qProgram.Max_Global_Volume_Size_LBS)>
        </cfif>
        <!--- save the range for validation error message in JS --->
        <cfset request.min_max_range = arrayToList(local.result, ", ")>
    </cfif>

    <cfreturn arrayLen(local.result) eq 0
                    ? ""
                    : '<br> <span class="font-hairline" style="font-size:9px">' & arrayToList(local.result, " ") & "</span>">
</cffunction>        <!--- name="min_max_header" --->


<cfinclude template="/programs/volume/edit_volume_footer.cfm">
