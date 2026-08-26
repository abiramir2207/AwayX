<!DOCTYPE html>
<html lang="en">
<cfscript>
    labelManager   = createObject( "component", "components.settings.Labels.Labels" ).init();
    planner_labels = labelManager.plannerLabels();
</cfscript>

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <cfoutput>
    <title>#planner_labels.distributor_singular# Members</title>
    </cfoutput>
</head>
<body>
<cf_include files="/common_files/ag-Grid.cfm, /common_files/jQuery.cfm">    <!--- jquery is needed for focus.cfm --->

<style>
    <!--- REQUIRED: For now, need to update these "ag-" classes, may move to common file --->
    .ag-theme-balham { font-size: 11px; }
    .ag-header { font-size: 11px !important; }
    .ag-theme-balham .ag-cell {
        padding-left: 2px;
        padding-right: 0px;
    }
    .ag-theme-balham .ag-row-selected {
        border-bottom-color: #b5b5b5; /* don't hide lines when selected */
    }
</style>

<cfparam name="URL.id"     default="">
<cfparam name="URL.Column" default="">

<cfif URL.Column is "Planner">
    <cfset getplanner = createObject( "component", "mvc.Models.Planner.PlannerManager" )>
	<cfset qdetails   = getplanner.getCustomers( URL.id, 0 )>
    <cfset json_data  = application.util.query.toAgGridJSON(qdetails, 'Number, Description')>

<cfelseif URL.Column is "Distributor"><!---Distributor Query --->

	<cfquery datasource="#application.datasource#">
		DROP TABLE IF EXISTS ##Customer_Group_Members
	</cfquery>

    <cfset display_shr_ship_to = application.util.query.get_Setting( 'Display_Distributor_ID', 0 )>

	<cfquery name="qdetails" datasource="#application.datasource#">
		CREATE TABLE ##Customer_Group_Members (BSA_Foodservice_Customers_ID uniqueidentifier)

		EXEC Planner_Customer_Group_Members_Get   #url.top_level#
                                                , '#url.customer#'
                                                , #url.template#
                                                , '##Customer_Group_Members'

		SELECT <cfif display_shr_ship_to eq '1'>
                    c.Shr_Ship_To
                <cfelse>
                    c.ship_to
                </cfif> AS number,
				c.Name  AS description
		FROM   ##Customer_Group_Members t
		        INNER JOIN BSA_Foodservice_Customers c
		            ON c.BSA_Foodservice_Customers_ID = t.BSA_Foodservice_Customers_ID
        FOR JSON PATH, INCLUDE_NULL_VALUES
	</cfquery>

    <cfset json_data = ''>
    <cfloop query="qdetails">
        <cfset json_data = json_data & qdetails[ qDetails.columnList.listFirst() ][ qdetails.currentRow ]>
    </cfloop>

<cfelse>
    <!--- unexpected URL.Column parameter value --->
    <cfabort>
</cfif>

<cfoutput>
<h2 style="margin-left:3%">#planner_labels.distributor_singular# Members</h2>
</cfoutput>

<div id="distributor_Grid" style="margin:0 3% 10px; height:90vh; width:94%" class="ag-theme-balham"></div>

<div style="text-align:center">
    <button style="cursor:pointer" class="button recommended" onclick="window.close()"> Close </button>
</div>

<script>
    let GridOptions = {
                	defaultColDef: {     editable:         false
                                        , resizable:       true
                                        , sortable:        true
                                        , suppressMenu:    true
                                        , suppressMovable: false
                                        , unSortIcon:      false
                                        }
                    ,columnDefs: [
                                    {headerName: "Ship To", field: "number", width:120, filter: "agTextColumnFilter"   },          <!--- NOTE the lower-case!! --->
                                    {headerName: "Name", field: "description",filter: "agTextColumnFilter", width:400 }
                                ]
                    ,rowData: <cfoutput>#json_data#</cfoutput>
                    ,rowModelType: "clientSide"
                    ,cacheBlockSize: 2000
                    ,debug: false
                    ,floatingFilter: true
                };
    ag_grid_default( GridOptions );		// set up default features
    init_ag_grid( GridOptions, "#distributor_Grid", false );  // init distributor client-side grid
</script>

<cfinclude template="/common_files/focus.cfm">
</body>
</html>
