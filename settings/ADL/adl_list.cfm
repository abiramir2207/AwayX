<!---
  * ==================================================================================================== 
  *    @File: /settings/ADL/adl_list.cfm
  *  @Author: Sharon Harris
  *    @Date: April 2021
  * 
  * @Remarks: List the Authorized Distribution Lists with edit and delete options
  *
  * ==================================================================================================== 
--->
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
    <cfscript>
        request.ag_grid_dense = 0;
        adl_cfc = createObject("component", "mvc.models.settings.ADLManager");
        if (isDefined("url.remid")) {
            adl_cfc.deleteADLHeader( url.remid );
        }
        qADL = adl_cfc.getADLHeaderAsArray();
    </cfscript>

    <cf_include files="/common_files/ag-Grid.cfm, /common_files/jQuery.cfm, /styles/ag-grid-ba.css">

    <style>
		html {
			background-color: white;
		}
        div.actions {
            margin: 10px;            
        }
		#aggrid {
			padding-left: 10px;
            width: 590px;
        }
		/* Make the grid resize lines bigger */
		.ag-header-cell-resize {
			content: '';
			position: absolute;
			top: 0;
			right: 0 !important;
			margin: 0 !important;
			width: 4px !important;			/* so make it wider, change the background color to match the hdr, and add a thin border */
			background: #ffce84;
			border-right: 1px solid #9b9b9c;
			z-index: 0;
		}
    </style>

	<main class="listContent">
		<div class="actions">
			<button class="button new">Add a List</button>
		</div>

		<div id="aggrid" class="ag-theme-balham"></div>  
	</main> 

    <script>
        'use strict';

        const config = { starting_column: 1 };
        config.query = <cfoutput>#serializeJSON( qADL )#</cfoutput>;
		
        <!--- ~~~~~~~~~~ glob = global variables  ~~~~~~~~~~ --->
        let glob = { grid_id: "#aggrid" };
  
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
				{ headerName:"ID", field:"AUTHORIZED_DISTRIBUTION_LIST_HEADER_ID", hide: true }
				,{ headerName:"Title", field:"TITLE", width:150
					// ,cellRenderer: function(params) {
						// return '<a href="#" title="Click here to edit list"></a>';
					// }
				}
				,{headerName:"Customer", field:"CUSTOMER", width:250}
				,{headerName:"", width:170,
					cellRenderer: function(p) {
						return '<div>'
								+ '<button class="button go_edit" title="Edit List details">Edit</button>'
								+ '<button class="button go_details" title="View associated Items">Details</button>'
								+ '<button class="button go_delete" title="Delete List details">Delete</button>'
								+ '</div>' ;
					} 

					,onCellClicked: function(params) {
						if (params.event.target.classList.contains("go_edit")) {
							let adl_id = params.data.AUTHORIZED_DISTRIBUTION_LIST_HEADER_ID;
							let adl_label = params.data.TITLE;
							parent.edit_tab (adl_id, adl_label);
						}
						else if (params.event.target.classList.contains("go_details")) {
							NewWindow("/settings/ADL/adl_details.cfm?id=" + params.data.AUTHORIZED_DISTRIBUTION_LIST_HEADER_ID,"winDetails","950","600","yes","yes"); 
						}
						else if (params.event.target.classList.contains("go_delete")) {
							if (confirm("Are you sure that you wish to delete " + params.data.TITLE + "?")) {
                                window.location = "adl_list.cfm?remid=" + params.data.AUTHORIZED_DISTRIBUTION_LIST_HEADER_ID;
                            }
						}
					}

				}
			]
			,domLayout:					'autoHeight'
			,enableRangeSelection:      false
			,floatingFilter:            false
			,pagination:                false
			,rowData:                   config.query
			,rowModelType:              "clientSide"
			,rowSelection:              false
			,suppressContextMenu:       true
			,suppressRowClickSelection: true
		};
 
        ag_grid_default( glob.my_grid );
        init_ag_grid( glob.my_grid, glob.grid_id );

        $("button.new").click(function(){
            parent.create_new_tab();
        });

    </script>

    <cfinclude template="/common_files/focus.cfm">
</body>
</html>