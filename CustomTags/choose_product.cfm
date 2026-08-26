<!-----------------------------------------------------------------------------------------------------------------------------------
      Template: \CustomTags\choose_product.cfm
      Label:    45383
      Date:     2014 October
      Author:   Chris Nguyen
      Purpose:  List active non-group products with Ajax calls to support large table, allows to make multiple selections

      Input =
        products_input_name =  required,
                               hidden html input variable name,
                               it contains a list of selected products delimited by commas

      API =
        selected_products() = call to get all selected products in a comma-delimited list & place it in the above hidden variable
----------------------------------------------------------------------------------------------------------------------------------->
<cfif thisTag.executionMode is "start">

    <!--- do nothing --->

<cfelse>
    <link rel="stylesheet" type="text/css" href="/common_files/datatable.css">

    <style>
      #prod211 { margin: 5px 0 20px;}
      .center { text-align: center; }
      .clear { clear:both; }
      .columnfilter { width:99%; }
      .red { color:red; }
    </style>

    <cfscript>
      variables.columnSizes = [0.5, 1, 2.5, 2, 2, 2, 2];
      variables.columnSizes = application.util.array.dtColumnSizeInPercent( variables.columnSizes );

      variables.dataCFC     = createObject("component", "components.general.Profitability_Models");
      variables.qTypeCodes  = variables.dataCFC.getTypeCodes();
      variables.qTypeGroups = variables.dataCFC.getTypeGroups();

      variables.dataCFC  = createObject("component", "components.products.products");
      variables.qBrands  = variables.dataCFC.getBrands();
      variables.qQBrands = variables.dataCFC.getQBrands();
    </cfscript>


    <cfsavecontent variable="variables.bodyText">
        <!--- products --->
        <table class="datagrid" id="datagrid41" style='table-layout:fixed'>
            <cfloop array="#variables.columnSizes#" index="variables.columnPercentage">
            <cfoutput><col width="#variables.columnPercentage#%"></cfoutput>
            </cfloop>

            <thead>
                <tr>
                    <cfoutput>
                    <th>&nbsp;</th>
                    <th>#application.returned_customer_setting.Item_Label#</th>
                    <th>Description</th>
                    <th>#application.returned_customer_setting.Type_Code_Label_Singular#<br/>
                        <select class="columnfilter">
                            <option> </option>
                            <cfloop query="variables.qTypeCodes">
                                <option>#variables.qTypeCodes.Type_Code_Desc#</option>
                            </cfloop>
                        </select>
                    </th>
                    <th>#application.returned_customer_setting.Type_Group_Label_Singular#<br/>
                        <select class="columnfilter">
                            <option> </option>
                            <cfloop query="variables.qTypeGroups">
                                <option>#variables.qTypeGroups.Type_Group_Desc#</option>
                            </cfloop>
                        </select>
                    </th>
                    <th>Brand<br/>
                        <select  class="columnfilter">
                            <option> </option>
                            <cfloop query="variables.qBrands">
                                <option>#variables.qBrands.Brand_Name#</option>
                            </cfloop>
                        </select>
                    </th>
                    <th>#application.returned_customer_setting.Q_Brand_Label_Singular#<br/>
                        <select class="columnfilter">
                            <option> </option>
                            <cfloop query="qQBrands">
                                <option>#qQBrands.q_Brand#</option>
                            </cfloop>
                        </select>
                    </th>
                    </cfoutput>
                </tr>
            </thead>

            <tbody>
            </tbody>
        </table>
    </cfsavecontent>

    <cfoutput>#application.util.string.compress(variables.bodyText)#</cfoutput>

    <!------------------------------------------------JAVASCRIPT----------------------------------------------------------->

    <cfinclude template="/common_files/jQuery.cfm">
    <cfset datatables.version = "1.9.1">
    <cfinclude template="/common_files/dataTables.cfm">
    <script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>

    <script>
    <!--- below IE 9 indexOf array does NOT exist --->
    if (!Array.prototype.indexOf) {
      Array.prototype.indexOf = function(elt /*, from*/) {
        var len = this.length >>> 0;

        var from = Number(arguments[1]) || 0;
        from = (from < 0)
             ? Math.ceil(from)
             : Math.floor(from);
        if (from < 0)
          from += len;

        for (; from < len; from++) {
          if (from in this &&
              this[from] === elt)
            return from;
        }
        return -1;
      };
    };

    var $selected_products = <cfoutput>$('input[name=#attributes.products_input_name#]')</cfoutput>;

    selected_products = function () {
      <!--- all checked rows are saved in a hidden input with a name of 'checkedBoxes'
            we pass this list of values to Ajax to maintain all user's selection
            before we send we need to refresh the values in this hidden input       --->
      var hiddenCBoxes = $selected_products.val();
      <!--- convert the list into an array for easy manipulation --->
      if (hiddenCBoxes.length == 0)
        var aCheckedBoxes = [];
      else
        var aCheckedBoxes = hiddenCBoxes.split(",");

      <!--- scan thru all checkboxes on the page --->
      $('#datagrid41 input.cb').each( function() {
        var item_id = $(this).val();

        if ( $(this).prop('checked') ) {
          // checked box is not in the array, add it
          if (aCheckedBoxes.indexOf( item_id ) == -1)
            aCheckedBoxes.push( item_id );
        }
        else {
          // box is not checked so we need to remove it
          while(aCheckedBoxes.indexOf( item_id ) != -1) {
            aCheckedBoxes.splice(aCheckedBoxes.indexOf( item_id ),1);
          }
        }
      });

      <!--- convert array back to a list for passing to Ajax and for usage in form action --->
      hiddenCBoxes = aCheckedBoxes.join(",");
      <!--- refresh the hidden input with ALL selected rows --->
      $selected_products.val( hiddenCBoxes );
    };


    $(function() {
        var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? .61 : .5) * windowHeight;
        var oTable = $('#datagrid41').dataTable({
           "aaSorting": [[ 1, "asc" ]]
          ,"aLengthMenu": [ [100, 200, 500], [100, 200, 500]]
          ,"aoColumns": [
                           {"bSortable":false, "bSearchable":false, "sClass":"center" }
                          ,{"bSortable":true,  "bSearchable":true}
                          ,{"bSortable":true,  "bSearchable":false}
                          ,{"bSortable":false,  "bSearchable":false}
                          ,{"bSortable":false,  "bSearchable":false}
                          ,{"bSortable":false,  "bSearchable":false}
                          ,{"bSortable":false,  "bSearchable":false}
                        ]
          ,"bAutoWidth": false
          ,"bPaginate": true
          ,"bProcessing": true
          ,"bServerSide": true
          ,"bScrollCollapse": false
          ,"bSortClasses": false
          ,"iDisplayLength": 100
          ,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
          ,"sAjaxSource": "/customTags/ajax/choose_product.cfm?"
          ,"sDom": 'fpltipr'
          ,"sScrollY": sScrollY         <!--- data grid height --->
          ,"sServerMethod": "POST"      <!--- use POST because of possible large volume of product data --->
          ,"fnServerParams": function ( aoData ) {
                <!--- keep track of ALL selected products --->
                selected_products();
                <!--- send ALL selected products to the server --->
                aoData.push( { "name": "checkedBoxes", "value": $selected_products.val() } );
            }
        }).fnSetFilteringDelay();

        <!--- hovering tr style --->
        $('#datagrid41 tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });

        <!--- disable the event on checkbox because it is handled by the parent tr further down below --->
        $('#datagrid41 tbody').on('click', 'input.cb', function(e) {
            e.stopPropagation();
        });

        <!--- click on any tr row would select the product on that row --->
        $('#datagrid41 tbody').on('click', 'tr', function() {
            var cb = $(this).find('input');
            cb.prop("checked", !cb.prop("checked"));
        });

        /* filter by dropdowns */
        $("thead th").each( function ( i ) {
            if ( $(this).find("select.columnfilter") ) {
                $('select', this).change( function () {
                    oTable.fnFilter( $(this).val(), i );
                });
            }
        });
    });
    </script>
</cfif>