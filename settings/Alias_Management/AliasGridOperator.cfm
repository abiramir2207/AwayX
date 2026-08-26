<!---
  * ====================================================================================================
  *  @Author: Sharon Harris
  *  @Date: 24-Jan-2019
  *  Alias Management, configuring Grid for Operators
  *     Included as Template into AliasGridManager.cfm
  *     
  *
  *
  * ====================================================================================================
--->
<script>
    //------------------------------------------------------------------------------------------------------
    // Define the Grid column Sets, see AliasGridManager.cfm for shared column definitions
    //------------------------------------------------------------------------------------------------------
    var Cols3 = /* operator */
        [c_selectCol, c_aliasID, c_aliasDesc, c_aliasAddress, c_entityID, c_entityDesc, c_payeeID, c_entityAddress, c_holdInvoiceCount, c_unknown];


    //------------------------------------------------------------------------------------------------------
    // Build the Operator Grid
    //------------------------------------------------------------------------------------------------------
    function buildGrid_Operator(aliasSourceType, GridOptions, tabIndex) {
        let countID = "#count"+tabIndex;

        // call common grid setup with the Operator columns and test data
        GridOptions = buildGridCols(GridOptions, Cols3, "#myAliasGrid", countID, tabIndex);

        // show/hide some columns based on source type
        GridOptions = customizeCols_Operator(aliasSourceType, GridOptions);
        return (GridOptions);
    }

	function loadData_Operator(countID,params,sourceType,sourceID,tabIndex){
		/* Add these additonal search filters to "params.request.filterModel". */ 
		params.request.filterModel['isAssigned'] = !($('input[name=assigned_filter]').is(':checked'));
		params.request.filterModel['unKnown'] = $('input[name=ignore_filter]:checked').val();

		$.ajax({type    : "post"
				,url     : "ajax/alias_data.cfm?entityType="+tabIndex
				,dataType: "json"
				,data    : {
								sourceType: sourceType
								,sourceID: sourceID
								,startRow: params.request.startRow
								,endRow: params.request.endRow
								,filterModel: JSON.stringify(params.request.filterModel)
								,sortColumn: params.request.sortModel.length ? params.request.sortModel[0].colId : ""
								,sortOrder: params.request.sortModel.length ? params.request.sortModel[0].sort : ""
							}	

				,success : function (response) {
							var arr_columns = [];
							/* We need the list of columns in javascript, but the columns are defined in CF (alias_columns_arr).
							To get the list of columns in javascrpt, we need to loop through the data in CF and create an array 
							in javascript. THis way we can get the sme column list in javascript. No need to hardcdde the 
							array in javascript.
							*/
							<cfoutput>
							<cfloop from="1" to="#ArrayLen(alias_columns_arr)#" index="i">
								arr_columns.push('#alias_columns_arr[i]#');
							</cfloop>
							</cfoutput>

							<!--- "response" does not have column names defined, but it has the array indexes defined.
							"convertToArrayOfObjects" function will assign column names, so that AG grid can load the 
							data in appropriate columns. --->
							var data_to_load = convertToArrayOfObjects(response,arr_columns);

							if (response.length == 0) {
								$("span.ag-loading-icon").hide();
								$("span.ag-loading-text").text("No records found.")
								updateCount(countID, 0);  // update screen display with record count
							}
							else{
								params.successCallback(data_to_load, data_to_load[0].ROWS_CNT);
								updateCount(countID, data_to_load[0].ROWS_CNT);  // update screen display with record count
							}	
				}
				,error: function(xhr, status, err) {
						alert('error occured');
				}
		});

	}

    //------------------------------------------------------------------------------------------------------
    // Depending on the source type, some grid columns are visible/hidden
    //------------------------------------------------------------------------------------------------------
    function customizeCols_Operator(aliasSourceType, GridOptions) {
        let bShowAddressCols = true;    // always true for Operator
        let payeeID_visible = false;
        let holdInvoiceCount_visible = false;     

        if (aliasSourceType == 1) {
            <cfif application.appSettingsGet.getShowHoldingPen() EQ 1>
            {
                holdInvoiceCount_visible = true;
            }
            </cfif>
        }
           
        GridOptions.columnApi.setColumnVisible("ENTITYADDRESS", bShowAddressCols);
        GridOptions.columnApi.setColumnVisible("ALIASADDRESS", bShowAddressCols);
        GridOptions.columnApi.setColumnVisible("PAYEEID", payeeID_visible);
        GridOptions.columnApi.setColumnVisible("HOLDINVOICECOUNT", holdInvoiceCount_visible);

        return (GridOptions);

    }
</script>