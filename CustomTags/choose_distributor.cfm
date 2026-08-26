<!-----------------------------------------------------------------------------------------------------------------------------------
      Template: \CustomTags\choose_distributor.cfm
      Label:    45383
      Date:     2014 October
      Author:   Chris Nguyen
      Purpose:  List active distributors with Ajax calls to support large table, allows to make multiple selections

      Input =
        distributors_input_name =  required,
                                   hidden html input variable name,
                                   it contains a list of selected distributors delimited by commas

      API =
        selected_distributors() = call to get all selected distributors in a comma-delimited list & place it in the above hidden variable
----------------------------------------------------------------------------------------------------------------------------------->
<cfif thisTag.executionMode is "start">

    <!--- do nothing --->

<cfelse>
    <cfparam name="attributes.multiple_selection" default=0>

    <link rel="stylesheet" type="text/css" href="/common_files/datatable.css">

    <style>
      #prod211 { margin: 5px 0 20px;}
      .center { text-align: center; }
      .clear { clear:both; }
      .columnfilter { width:99%; }
      .red { color:red; }
    </style>

    <cfscript>
      variables.columnSizes = [0.5, 1.5, 0.75, 2, 2, 2, 2];
      variables.columnSizes = application.util.array.dtColumnSizeInPercent( variables.columnSizes );
    </cfscript>

    <cfset useLakebaseForvariables_qFamily = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("distributor_family")>
<cfif useLakebaseForvariables_qFamily>
	<cftry>
		<cfset variables.qFamily = application.oLakebase.toQuery(
			application.oLakebase.selectRows("distributor_family", {
				"deleted" = "eq.0",
				"order" = "family_name.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForvariables_qFamily = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForvariables_qFamily>
<cfquery name="variables.qFamily" datasource="#application.datasource#">
        SELECT * FROM Distributor_Family WHERE Deleted = 0 ORDER BY Family_Name
    </cfquery>
</cfif>

    <cfset useLakebaseForvariables_qBuyingGroup = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("distributor_buying_groups")>
<cfif useLakebaseForvariables_qBuyingGroup>
	<cftry>
		<cfset variables.qBuyingGroup = application.oLakebase.toQuery(
			application.oLakebase.selectRows("distributor_buying_groups", {
				"deleted" = "eq.0",
				"order" = "buying_group_name.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForvariables_qBuyingGroup = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForvariables_qBuyingGroup>
<cfquery name="variables.qBuyingGroup" datasource="#application.datasource#">
        SELECT * FROM Distributor_Buying_Groups WHERE Deleted = 0 ORDER BY Buying_Group_Name
    </cfquery>
</cfif>

    <cfsavecontent variable="variables.bodyText">
        <!--- distributors --->
        <table class="datagrid" id="datagrid09" style='table-layout:fixed'>
            <cfloop array="#variables.columnSizes#" index="variables.columnPercentage">
            <cfoutput><col width="#variables.columnPercentage#%"></cfoutput>
            </cfloop>

            <thead>
                <tr>
                    <th>&nbsp;</th>
                    <th>Name</th>
                    <th>ID</th>
                    <th>Address</th>
                    <th>City State Zip</th>
                    <cfoutput>
                    <th>#application.returned_customer_setting.Family_Name_Label_Singular#<br>
                        <select class="columnfilter">
                            <option> </option>
                            <cfloop query="variables.qFamily">
                                <option>#variables.qFamily.Family_Name#</option>
                            </cfloop>
                        </select>
                    </th>
                    <th>#application.returned_customer_setting.Buying_Group_Label_Singular#<br>
                        <select class="columnfilter">
                            <option> </option>
                            <cfloop query="variables.qBuyingGroup">
                                <option>#variables.qBuyingGroup.Buying_Group_Name#</option>
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

    var $selected_distributors = <cfoutput>$('input[name=#attributes.distributors_input_name#]')</cfoutput>;

    selected_distributors = function () {
      <!--- all checked rows are saved in a hidden input with a name of 'checkedBoxes'
            we pass this list of values to Ajax to maintain all user's selection
            before we send we need to refresh the values in this hidden input       --->
      <cfif attributes.multiple_selection eq '1'>
        var hiddenCBoxes = $selected_distributors.val();
      <cfelse>
        var hiddenCBoxes = '';
      </cfif>

      <!--- convert the list into an array for easy manipulation --->
      if (hiddenCBoxes.length == 0)
        var aCheckedBoxes = [];
      else
        var aCheckedBoxes = hiddenCBoxes.split(",");

      <!--- scan thru all checkboxes on the page --->
      $('#datagrid09 input.cb').each( function() {
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
      $selected_distributors.val( hiddenCBoxes );
    };


    $(function() {
        var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? .61 : .5) * windowHeight;
        var oTable = $('#datagrid09').dataTable({
           "aaSorting": [[ 1, "asc" ]]
          ,"aLengthMenu": [ [100, 200, 500], [100, 200, 500]]
          ,"aoColumns": [
                           {"bSortable":false, "bSearchable":false, "sClass":"center" }
                          ,{"bSortable":true,  "bSearchable":true}
                          ,{"bSortable":true,  "bSearchable":true}
                          ,{"bSortable":true,  "bSearchable":true}
                          ,{"bSortable":true,  "bSearchable":true}
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
          ,"sAjaxSource": "/customTags/ajax/choose_distributor.cfm"
          ,"sDom": 'fpltipr'
          ,"sScrollY": sScrollY         <!--- data grid height --->
          ,"sServerMethod": "POST"
          ,"fnServerParams": function ( aoData ) {
                <!--- maintain a list of selected distributors when multiple selection is allowed --->
                <cfif attributes.multiple_selection eq '1'>
                    selected_distributors();
                </cfif>
                aoData.push( { "name": "checkedBoxes", "value": $selected_distributors.val() }
                            ,{ "name": "multiple_selection", "value": <cfoutput>#attributes.multiple_selection#</cfoutput>  } );
            }
        }).fnSetFilteringDelay();

        $('#datagrid09 tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });

        $('#datagrid09 tbody').on('click', 'input.cb', function(e) {
            e.stopPropagation();
        });

        $('#datagrid09 tbody').on('click', 'tr', function() {
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