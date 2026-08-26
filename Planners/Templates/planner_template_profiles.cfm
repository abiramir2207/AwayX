<!---------------------------------------------------------------------------------------------------------------------
	  Template:  \planners\template\planner_template_profiles.cfm
		  Date:  2018 Oct
		Author:  Chris Nguyen
	   Purpose:  Manage planner template profiles
----------------------------------------------------------------------------------------------------------------------->

<!--- gather planner permissions for all profiles --->
<cfquery name="qPermissions" datasource="#application.datasource#">
	SELECT Access_is_forbidden, Profile_ID, Planner_Template_ID
	  FROM Profile_Forbidden_Planner
	 WHERE Planner_Template_ID = #form.id#
			AND Deleted = 0
</cfquery>

<!--- set up an array for ag-Grid --->
<cfset settings = []>
<cfoutput query="qProfiles">
	<!--- locate for a specific profile --->
	<cfquery name="qAccess" dbtype="query">
		SELECT *
		  FROM qPermissions
		 WHERE qPermissions.Profile_ID = #qProfiles.Profiles_ID#
				AND qPermissions.Planner_Template_ID = #form.id#
	</cfquery>
	<!--- a specific profile does not exist (it may be new) so find "any new profiles" --->
	<cfif qAccess.recordCount eq 0>
		<cfquery name="qAccess" dbtype="query">
			SELECT *
			  FROM qPermissions
			 WHERE qPermissions.Profile_ID = 0
					AND qPermissions.Planner_Template_ID = #form.id#
		</cfquery>
	</cfif>

	<cfset arrayAppend(settings, {profile_name:qProfiles.Profiles_Desc, allow_access:(qAccess.Access_is_forbidden eq 1 ? 0 : 1), id:qProfiles.Profiles_ID})>
</cfoutput>

<cfset request.ag_grid_theme = "ag-theme-balham">
<cfinclude template="/common_files/ag-Grid.cfm">


<div id="myGrid" style="height:75vh; width:460px;" class="ag-theme-balham"></div>
<input type="hidden" name="save_profiles">
<span id="profileAccess"></span> <!--- checked profile fields will be added here dynamically --->
<script>
	var columnDefs = [
                        {	 editable: false
                            ,field: "PROFILE_NAME"
                            ,headerName: "Profile Name"
                            ,filter: false
                            ,sortable: false
                            ,width: 275
                        },
                        ,{	 editable: false
                            ,cellRenderer: function(params) { 
                                                                return '<input type="checkbox" class="access" '
                                                                        + (params.value == '1' ? "checked=checked" : "") 
                                                                        + ' name=allow_access_' + params.data.ID
																		+ ' id=' + params.data.ID
                                                                        + '>'; 
                                                            }
                            ,field: "ALLOW_ACCESS"
                            ,headerComponentParams : {
                                                        template:
                                                            '<div class="ag-cell-label-container" role="presentation">' +
                                                            '  <span ref="eMenu" class="ag-header-icon ag-header-cell-menu-button"></span>' +
                                                            '  <div ref="eLabel" class="ag-header-cell-label" role="presentation">' +
                                                            '    <span ref="eSortOrder" class="ag-header-icon ag-sort-order" ></span>' +
                                                            '    <span ref="eSortAsc" class="ag-header-icon ag-sort-ascending-icon" ></span>' +
                                                            '    <span ref="eSortDesc" class="ag-header-icon ag-sort-descending-icon" ></span>' +
                                                            '    <span ref="eSortNone" class="ag-header-icon ag-sort-none-icon" ></span>' +
                                                            '    <input type="checkbox" id="all_access"> <span ref="eText" class="ag-header-cell-text" role="columnheader"></span>' +
                                                            '    <span ref="eFilter" class="ag-header-icon ag-filter-icon"></span>' +
                                                            '  </div>' +
                                                            '</div>'
                                                    }
                            ,filter: false
                            ,sortable: false
                            ,width: 150
                        }
                    ]

	let gridOptions = {
		columnDefs: columnDefs,
		suppressRowClickSelection: true,
		rowBuffer: <cfoutput>#qProfiles.recordCount#</cfoutput>,
		rowSelection: 'multiple',
        rowData: <cfoutput>#serializeJSON(settings)#</cfoutput>,
		getRowNodeId: function(data) { return data.ID; },
		onGridReady: function() { 
									// select all checkbox logic
									$(document).on("click", "input#all_access", function(e) {
										$("input.access").prop("checked", $(this).prop("checked"));
										if (!$(this).prop("checked")){
											gridOptions.api.forEachNode( function (node) {
												node.setSelected(false);
											});
										}
										else{
											gridOptions.api.forEachNode( function (node) {
												node.setSelected(true);
											});
										}
									});
									// when one checkbox is unchecked make the select all checkbox in the header unchecked
									$(document).on("click", "input.access", function(e) {
										if (!$(this).prop("checked")){
											$("input#all_access").prop("checked", false);
											gridOptions.api.getRowNode($(this).attr("id")).setSelected(false);
											}
											else{
												gridOptions.api.getRowNode($(this).attr("id")).setSelected(true);
											}
                                    });
                                }
	};

	ag_grid_default( gridOptions );
	init_ag_grid( gridOptions, "#myGrid", false );	
	gridOptions.api.forEachNode( function (node) {	
	if (node.data.ALLOW_ACCESS == 1) {
		node.setSelected(true);
		}
	});

	/* WR D110975 - Planner Template issues: Profiles getting deleted. 
	Commented grid set up below and added grid setup above. This file is part of an include that gets displayed when the profiles tab is selected. 
	If the tab is not selected the grid won't initialize causing all the profile settings to get deleted. */
	/*
	// setup the grid after the page has finished loading
	document.addEventListener('DOMContentLoaded', function() {
		ag_grid_default( gridOptions );
		init_ag_grid( gridOptions, "#myGrid", false );
	    gridOptions.api.forEachNode( function (node) {
	        if (node.data.ALLOW_ACCESS == 1) {
	            node.setSelected(true);
	        }
	    });
    });
	*/
</script>

