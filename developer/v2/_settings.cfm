<!--
  * ====================================================================================================
  *  @Author: Chris Nguyen
  *    @Date: 2018-02-01 14:36:03
  *
  * @Remarks:
  *
  *
  *
  *
  * ====================================================================================================
-->
<!doctype html>
<html lang="en">
<head>
	<title>Maintain Settings</title>
    <!--- <link href="<cfoutput>#request.forge_cdn#</cfoutput>/styles/normalize/8.0.0/normalize.min.css" rel="stylesheet"> --->
    <link rel="stylesheet" type="text/css" href="<cfoutput>#request.forge_cdn#</cfoutput>/script/javascript/noty/3.1.4/noty.css?v=0158400">

	<link rel="stylesheet" type="text/css" href="<cfoutput>#request.forge_cdn#</cfoutput>/styles/tailwind/0.7/tailwind.min.css?v=080654236">
    <style>
		/* Box-sizing border-box */
		* { -moz-box-sizing: border-box; -webkit-box-sizing: border-box; box-sizing: border-box; }
		html, body { margin: 0; padding: 0;
			font-family : Arial;
			font-size : 10pt;
		}

		#commands {
			display: flex;
			height: 5vh;
			padding: 1vh 0 0vh 0;
		}
			div.filler {
				flex-grow: 10;
			}
			div.title {
				color: #818152;
				font-size: 2.5vh;
				font-weight: bold;
				letter-spacing:0.125vw;
				margin-left: 1vw;
			}

		button.button {
			background-color: #edeef2;
			border-radius: 50px;
			border: 1px solid #d8d9dd;
			box-sizing: border-box;
			box-shadow: 0px 2px 4px -1px rgba(86, 87, 96, 0.3);
			color: #343540;
			font-size: 11px;
			font-weight: 500;
			height: 20px;
			margin: 0 15px;
			padding: 0px 15px 0 15px;
		}
			button.button:hover {
				color: #406be4;
				background-color: #fff;
			}
			button.button:focus {
				outline: 0;
			}
			button.alt {
				background-color: #ffffff;
				border: 1px solid #d8d9dd;
				color: #343540;
			}
			button.recommended {
				background-color: #406be4;
				color: #ffffff;
			}
				button.recommended:hover {
					background-color: #406be4;
					color: #ffffff;
					opacity: .9;
				}
			button.danger {
				background-color: #bf1c36;
				color: #ffffff;
			}
				button.danger:hover {
					background-color: #bf1c36;
					color: #ffffff;
					opacity: .9;
				}
        div.ag-input-text-wrapper {
            margin-top: 5px;
        }
	</style>
</head>

<body>

	<cfquery name="qSettings" datasource="#application.datasource#">
		SELECT UPPER(SUBSTRING(Input_Name, 1, 1)) + SUBSTRING(Input_Name, 2, 999) + '*' AS Input_Name
      			,Value
		  FROM _Settings
	</cfquery>
	<cfquery name="qApp_Settings" datasource="#application.datasource#">
		SELECT * FROM _application_settings
	</cfquery>

	<cfset settings = []>
	<cfoutput query="qSettings">
		<cfset arrayAppend(settings, {input_name:qSettings.input_name, value:qSettings.value})>
	</cfoutput>
	<cfloop list="#qApp_Settings.columnList#" index="column">
		<cfset arrayAppend(settings, {input_name:application.util.string.capFirstTitle(column), value:qApp_Settings[column][1] })>
	</cfloop>

    <!--- <p style="height:3vh;text-align:center;margin:1vh 5px 0 5px;font-size:13px;">Double click on setting value to make changes. Changes are saved automatically after leaving the input.</p> --->

    <!--- <div style="margin:1vh 5px;height:5vh;" class="flex items-center bg-blue text-white text-sm font-bold px-4 py-3" role="alert">
        <svg class="fill-current w-4 h-4 mr-2" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M12.432 0c1.34 0 2.01.912 2.01 1.957 0 1.305-1.164 2.512-2.679 2.512-1.269 0-2.009-.75-1.974-1.99C9.789 1.436 10.67 0 12.432 0zM8.309 20c-1.058 0-1.833-.652-1.093-3.524l1.214-5.092c.211-.814.246-1.141 0-1.141-.317 0-1.689.562-2.502 1.117l-.528-.88c2.572-2.186 5.531-3.467 6.801-3.467 1.057 0 1.233 1.273.705 3.23l-1.391 5.352c-.246.945-.141 1.271.106 1.271.317 0 1.357-.392 2.379-1.207l.6.814C12.098 19.02 9.365 20 8.309 20z"/></svg>
        <p class="opacity-75">Click on the pen button to edit the setting value. Click outside the editing value to stop the editing.</p>
    </div> --->

    <cfset request.ag_grid_theme = "ag-theme-balham">
    <cfinclude template="ag-grid.cfm">
    <cfinclude template="/common_files/jQuery.cfm">

    <div id="myGrid" style="height:96vh;margin:0 5px;" class="ag-theme-balham"></div>

    <cfscript>
        can_edit = false;
    </cfscript>

    <script src="<cfoutput>#request.forge_cdn#</cfoutput>/script/javascript/noty/3.1.4/noty.min.js?v=0158400" ></script>

	<script>
		gridOptions = {
			animateRows: false,
			columnDefs: [ {	editable: false,
							field: "INPUT_NAME",
							filter: "agTextColumnFilter",
                            filterParams: { apply: false },
                            floatingFilterComponentParams: { suppressFilterButton: true },
							headerName: "Setting Name (classic in italic font)",
							width: 450,
							sort: 'asc',
							cellRenderer:function( params ) {
															return ( params.data.INPUT_NAME.indexOf( '*' ) == -1 )
																		? '<i style="color:green">' + params.data.INPUT_NAME + '</i>'
																		: params.data.INPUT_NAME.replace( '*', '' )
														}
						  },

						  {	editable: <cfoutput>#(can_edit ? true : false)#</cfoutput>,
                            field: "VALUE",
                            floatingFilterComponentParams: { suppressFilterButton: true },
                            headerName: "Setting Value",
                            sortable: false,
                            // gets clicked, the editing starts.
                            // cellRenderer: 'singleClickEditRenderer',
							onCellValueChanged: function(params) {
                                                                    // console.log(params.newValue)
																	if (params.newValue != params.oldValue) {

                                                                        if (confirm("Do you wish to update " + params.data.INPUT_NAME + " setting?\n\nfrom: " + params.oldValue + "\nto: " + params.newValue)) {
																		    var request = new XMLHttpRequest();
																		    request.open('GET', '_settings.cfm?input_name=' + params.data.INPUT_NAME + '&value=' + params.data.VALUE, true);
																		    request.send();
                                                                        }
                                                                        else {
                                                                            return false;
                                                                            var rowNode = gridOptions.api.getRowNode(params.node.id);
                                                                            // gridOptions.suppressChangeDetection = true;
																			// console.log("TCL: gridOptions.suppressChangeDetection", gridOptions.suppressChangeDetection)
                                                                            rowNode.setDataValue('VALUE', params.oldValue);
                                                                            // gridOptions.suppressChangeDetection = false;
                                                                        }
																	}
																},
							filter: false,
							width: 900
						  }
						],
			rowData: <cfoutput>#serializeJSON(settings)#</cfoutput>,
			getRowNodeId: function(data) { return data.INPUT_NAME; },
            suppressClickEdit: true,
            components:{ singleClickEditRenderer:getRenderer() },
            // stopEditingWhenGridLosesFocus: true,
            // onFirstDataRendered: onFirstDataRendered
		};

		gridOptions.defaultColDef = {
                                         sortable: true
                                        ,filter: true
										,suppressFilter: false
										,suppressMenu: true
										,suppressMovable: true
										,unSortIcon: true
									};
		gridOptions.floatingFilter            = true;
		gridOptions.groupHideOpenParents      = false;
		gridOptions.rowDeselection            = true;
		gridOptions.suppressContextMenu       = true;
		gridOptions.suppressRowClickSelection = false;

		let gridDiv = document.querySelector('#myGrid');
		new agGrid.Grid(gridDiv, gridOptions);

        // auto size all columns
        function onFirstDataRendered(params) {
            // let allColumnIds = [];
            // gridOptions.columnApi.getAllColumns().forEach(function(column) {
            //     allColumnIds.push(column.colId);
            // });
            // gridOptions.columnApi.autoSizeColumns(allColumnIds);
        }

        function getRenderer() {
            function CellRenderer() {
            }

            CellRenderer.prototype.createGui = function () {
                var template = '<span><button class="button" id="theButton">&#x1F58B</button><span id="theValue" style="padding-left: 4px;"></span></span>';
                var tempDiv = document.createElement('div');
                tempDiv.innerHTML = template;
                this.eGui = tempDiv.firstElementChild;
            };

            CellRenderer.prototype.init = function (params) {
                // create the gui
                this.createGui();
                // keep params, we use it in onButtonClicked
                this.params = params;

                // attach the value to the value span
                var eValue = this.eGui.querySelector('#theValue');

                eValue.innerHTML = params.value;
                // setup the button, first get reference to it
                this.eButton = this.eGui.querySelector('#theButton');

                // bind the listener so 'this' is preserved, also keep reference to it for removal
                this.buttonClickListener = this.onButtonClicked.bind(this);
                // add the listener
                this.eButton.addEventListener('click', this.buttonClickListener);
            };
            CellRenderer.prototype.onButtonClicked = function () {
                // start editing this cell. see the docs on the params that this method takes
                var startEditingParams = {
                    rowIndex: this.params.rowIndex,
                    colKey: this.params.column.getId()
                };
                this.params.api.startEditingCell(startEditingParams);
            };
            CellRenderer.prototype.getGui = function () {
                // returns our gui to the grid for this cell
                return this.eGui;
            };
            CellRenderer.prototype.destroy = function () {
                // be good, clean up the listener
                this.eButton.removeEventListener('click', this.buttonClickListener);
            };

            return CellRenderer;
        }

		function copyToClipboard( text ) {
			let $temp = $( "<input>" );
			$( "body" ).append( $temp );
			$temp.val( text ).select();
			document.execCommand( "copy" );
			$temp.remove();
		}

		$( "#myGrid" ).dblclick( function( e ) {
			let clipboard = $( e.target ).text();
			console.log( { clipboard } );
			copyToClipboard( clipboard );
		});

        const storage_name = "_settings.cfm";
        window.addEventListener('beforeunload', function (e) {
            localStorage.setItem( storage_name, $( "input.ag-floating-filter-input" ).val() );
        });

        gridOptions.api.setFilterModel( { INPUT_NAME: { filterType: 'text', type: 'startsWith', filter:localStorage.getItem( storage_name ) } } );

	</script>
	<cfset request.focusHiLightOff = 1>
</body>
</html>