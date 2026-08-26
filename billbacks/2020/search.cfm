<!---
  * ====================================================================================================
  *    @File: \billbacks\gm\search.cfm
  *  @Author: Chris Nguyen
  *    @Date: January 2020
  *
  * @Remarks: Search billbacks - search tab (under home tab)
  *
  * ====================================================================================================
--->
<cfprocessingdirective pageencoding = "utf-8">
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta http-equiv="X-UA-Compatible" content="ie=edge">
	<cfset local.arrowDown = "/images/arrow-d-blue-12.png" />
	<cfset local.arrowRight = "/images/arrow-r-blue-12.png" />
</head>
<body>
    <cfsavecontent variable="styles">
        <style>
            * {
                box-sizing: border-box;
                margin-top: 0;
                margin-bottom: 0;
                padding: 0;
            }
            body {
                overflow: hidden;
            }
            iframe {
                border: 0;
                box-sizing: border-box;
                width: 100%;
                padding: 0;
            }
            header {
                margin: 0;
                padding: 0;
            }
        </style>
		<cf_include files="shared_styles.css, search.css, /styles/tabnav-2020.css">

		</cfsavecontent>
    <cfhtmlhead text="#application.util.string.compress( styles )#">
    <cfparam name="URL.status" default="0">
    <cfscript>
		selected_status = '';

		switch(url.status) {
		    case "1":
		         selected_status = 'WIP';
		         break;
		    case "2":
		         selected_status = 'RFA';  //under review
		         break;
		    case "203":
		         selected_status = 'UR';  //under review
		         break;
		    case "202":
		         selected_status = 'PA';  // Pending Approval
		         break;
		    case "201":
		         selected_status = 'AG'; //Agreed
		         break;
		    case "3":
		         selected_status = 'APP';
		         break;
		    case "7":
		         selected_status = 'PND VEN';
		         break;
		    case "4":
		         selected_status = 'PMT REQ';
		         break;
		    case "8":
		         selected_status = 'APP VD';
		         break;
		    case "9":
		         selected_status = 'MAN REJ';
		         break;
		}
	</cfscript>

    <cfinvoke component      = "mvc.Models.Billback.BillbackLoadManager"
            method         = "getBillbackLookupData"
            userid         = "#request.AccessStructure.user_id#"
            returnvariable = "lookup">

	<cfoutput>
    <!--- ~~~~~~~~~~ top section ~~~~~~~~~~~ --->
	<button id="searchSectionBtn" class="sectionHeader">
		<img src="#local.arrowDown#" alt="expand/collapse" style="padding:1px 3px 0 0">
        Billback Search Results: &nbsp;<span id="record_count"></span>
	</button>

    <main>
        <nav style="background-color:##FFEDD2; padding-top:2px;">
            <ul>
                <li name="options" class="nav active">Options</li>
                <li name="tools" class="nav">Tools</li>
            </ul>
        </nav>

		<!--- ~~~~~~~~~~ options ~ middle section ~~~~~~~~~~~ --->
		<form id="bbSearchForm" style="width:100%">

			<!--- ~~~~~~~~~~ options ~ middle section ~~~~~~~~~~~ --->
			<cfsavecontent variable="options">
			<section id="filter_elements" name="options" class="middle">
				<cfoutput>
				<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
				<!--- ~~~~~~~~~~~ left side ~~~~~~~~~~~~ --->
				<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
				<article class="mediumW">
					<label>CTM ID</label> <input type="text" class="text" name="BBCodeKeyword" tabindex="1" value2="566"> <br>
					<label>Program</label> <input type="text" class="text" name="programKeyword" tabindex="4"> <br>
					<label>Type</label>
						<select class="multi" name="typeListSelect" tabindex="7" multiple="multiple">
							<cfloop array="#lookup.typeList#" index="type_filter">
								<option value="#type_filter.description#">#type_filter.description#</option>
							</cfloop>
						</select> <br>
					<label>Amount</label>
						<select name="amountTypeSelect" tabindex="12">
							<cfloop array="#lookup.amountTypeList#" index="amount_type_filter">
								<option value="#amount_type_filter#">#amount_type_filter#</option>
							</cfloop>
						</select>
						<select name="amountCriteriaSelect" tabindex="13">
							<cfloop array="#lookup.criteriaList#" index="criteria_filter">
								<option value="#criteria_filter#">#criteria_filter#</option>
							</cfloop>
						</select>
						<input type="text" class="small text currency" name="amountValueKeyword" tabindex="14"> <br>
					<label>Check ##</label> <input type="text" class="text" name="checkNoKeyword" tabindex="20"> <br>
					<label><b>Data View</b></label>
						<label class="basic" title="Current = Billbacks created within the last #application.util.query.get_setting('Bb_created_recently_days', 0)# days that are not in Paid or Approved-Void status.">
							<input type="radio" name="currentIncludingPaid" value="current" checked="checked" tabindex="24">
							 Current
						</label>
					<!--- <label>&nbsp;</label> --->
						<label class="basic" title="Current including paid/void = All billbacks including those in Paid and Approved-Void status.">
							<input type="radio" name="currentIncludingPaid" value="current_including_paid_void" tabindex="35">
							Current including paid/void
						</label> <br> <br>
					<label>&nbsp;</label>
						<label class="basic"> <input type="checkbox" name="duplicate_only" tabindex="29"> Duplicates only </label>
                        <button class="button delay" name="refresh" title="Refresh the list with 'Current' Billbacks">Refresh Data</button> <span id='dataDate'></span>
				</article>

				<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
				<!--- ~~~~~~~~~~~ center side ~~~~~~~~~~~ --->
				<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
				<article>
					<label>Inv ##</label> <input type="text" class="text" name="BBNumberKeyword" tabindex="2" value2="727"> <br>
					<label>Analyst</label>
						<select class="multi" name="analystListSelect" tabindex="5" multiple="multiple">
							<cfloop array="#lookup.analystList#" index="analyst_filter">
								<option value="#analyst_filter.IdInt#">#analyst_filter.fullName#</option>
							</cfloop>
						</select> <br>
					<label>Account</label> <input type="text" class="text" name="payeeKeyword" tabindex="8"> <br>
					<label>Entity</label>
						<select class="small" name="entitySelect" tabindex="15">
							<cfloop array="#lookup.entityTypeList#" index="entity_filter">
								<option value="#entity_filter#">#entity_filter#</option>
							</cfloop>
						</select>
						<input type="text" class="text" name="entityKeyword" class="medium" tabindex="16">
						<br>
					<label>History</label>
						<select class="small" name="historySelect" tabindex="21">
							<cfloop array="#lookup.historyTypeList#" index="history_filter">
								<option value="#history_filter#">#history_filter#</option>
							</cfloop>
						</select>
						<!--- <br>              <label>&nbsp;</label>  --->
						<!--- <span class="ml1"></span> --->
						<select class="multi" name="historyUsernameSelect" tabindex="22"  multiple="multiple">
							<cfloop array="#lookup.userList#" index="user_filter">
								<option value="#user_filter.idInt#">#user_filter.fullName#</option>
							</cfloop>
						</select>
						<br>
					<!---<br>
					<label>&nbsp;</label>
						<b>Favorite</b> (click on the 'tools' tab to access)<br>
					<label>Name</label>
						<input type="text" class="text" name="favorite" tabindex="30">
						<button class="button">Save</button>
					--->
				</article>

				<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
				<!--- ~~~~~~~~~~~ right side ~~~~~~~~~~~~ --->
				<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
				<article class="longW">
					<label>Status</label>
						<select class="multi" name="statusListSelect" tabindex="3" multiple="multiple" id="statusListSelect">
							<cfloop array="#lookup.statusList#" index="status_filter">
								<cfscript>
									statSelected = '';
									if(selected_status == status_filter.abbreviation){ statSelected = 'Selected';}
								</cfscript>
								<option #statSelected# value="#status_filter.abbreviation#">#status_filter.description#</option>
							</cfloop>
						</select> <br>
					<label>Closing Method</label>
						<select class="multi" name="closing_method" tabindex="6" multiple="multiple">
							<cfloop array="#lookup.closingMethodList#" index="closing_method_filter">
								<option value="#closing_method_filter.abbreviation#">#closing_method_filter.description#</option>
							</cfloop>
						</select> <br>
					<label>Start Date</label>
						<select name="dateRangeStartTypeSelect" tabindex="9">
							<cfloop array="#lookup.dateTypeList#" index="date_selector_filter">
								<option value="#date_selector_filter#">#date_selector_filter#</option>
							</cfloop>
						</select>
							<select name="dateRangeStartCriteriaSelect" tabindex="10">
								<cfloop array="#lookup.criteriaList#" index="criteria_filter">
								<option value="#criteria_filter#">#criteria_filter#</option>
							</cfloop>
						</select>
						<input type="text" class="text small date" name="dateRangeStartValueKeyword" tabindex="11"> <br>
					<label>End Date</label>
						<select name="dateRangeEndTypeSelect" tabindex="17">
							<cfloop array="#lookup.dateTypeList#" index="date_selector_filter">
								<option value="#date_selector_filter#">#date_selector_filter#</option>
							</cfloop>
						</select>
						<select name="dateRangeEndCriteriaSelect" tabindex="18">
							<cfloop array="#lookup.criteriaList#" index="criteria_filter">
								<option value="#criteria_filter#">#criteria_filter#</option>
							</cfloop>
						</select>
						<input type="text" class="text small date" name="dateRangeEndValueKeyword" tabindex="19"> <br>
					<label>Actions</label>
						<select class="actionList single" name="actionSelect" tabindex="23">
							<option></option>
							<cfloop array="#lookup.actionList#" index="action_filter">
								<option value="#action_filter#">#action_filter#</option>
							</cfloop>
						</select>
                        <button class="button recommended resetAction" style="display: none;" name="resetWIP">reset selected to WIP</button>
                        <button class="button recommended deleteAction" style="display: none;" name="deleteSelected">delete selected</button>
                        <button class="button recommended reassignAction" style="display: none;" name="reassignSelected">reassign selected</button>
                        <br>
                        <div class="reassignAction" style="display: none;">
                            <label >Reassign Selected</label>
                            <select class="multi" style="display: none;" name="reassignBBUserSelect">
                                <cfloop array="#lookup.analystList#" index="analyst_filter">
                                    <option value="#analyst_filter.idInt#">#analyst_filter.fullName#</option>
                                </cfloop>
                            </select>
                            <br>
                        </div>
					<label>Conditions</label>
						<select class="single" name="conditionSelect" tabindex="26">
							<option></option>
							<cfloop array="#lookup.conditionList#" index="condition_filter">
								<option value="#condition_filter#">#condition_filter#</option>
							</cfloop>
						</select>
						<button class="button delay recommended ml1" name="search" tabindex="27">Search</button>
						<button class="button delay" name="reset" tabindex="28">Reset</button> <br> <br>
					<label>&nbsp;</label>
						<button class="button export" name="download_data" tabindex="31">Download Data</button>
						<button class="button" id="create_inv" tabindex="32">Create Invoice</button>
				</article>
				</cfoutput>
			</section>
			</cfsavecontent>

			<cfoutput>#application.util.string.compress(options)#</cfoutput>
		</form>



		<!--- ~~~~~~~~~~ tools ~ middle section ~~~~~~~~~~~ --->
		<section id="tool_elements" name="tools" class="middle">
			<!---
			<article class="">
				<label>Enter List:</label><br>
				<textarea id="toolsList" rows="10" cols="1">
				</textarea><br>
				<button class="button">Search</button>
			</article>
			<article>
				<label>Favorites:</label><br>
				<textarea id="toolsFavs" rows="10" cols="1">
				</textarea><br>
				<button class="button">Search</button>
				<button class="button">Delete</button>
			</article>
			--->
			<article>
				<label style="margin-left:8px;">Documents:</label><br><br>
				<button class="button" onclick="uploadDocs();">Upload Documents</button><br><br>
				<button class="button" onclick="searchDocs();">Search Documents</button>
			</article>
		</section>

	</main>
	</cfoutput>


	<!--- ~~~~~~~~~~ bottom grid section ~~~~~~~~~~~ --->
	<section id="bb_grid" class="ag-theme-balham">
	</section>

	<!--- NOTE: include multiselect.cfm  before jqueryUI to avoid conflicts --->
	<cfset jQuery.version = '1.12.4'>
    <cfset jQueryUI.widgets = "datepicker">
	<cf_include files=#arrayToList( [ "/common_files/jQuery.cfm",
										"/common_files/multiselect.cfm",
										"/common_files/jQueryUI.cfm",
										"/common_Files/ag-Grid.cfm",
										"/script/javascript/moment.min.js",
										"/script/javascript/numeral.min.js",
										"/script/javascript/string_functions.min.js",
										"/common_files/noty.cfm",
										"/common_files/dhx_message.cfm",
										"/script/javascript/dayjs/1.8/dayjs.min.js",
										"/script/javascript/numeric/jquery.numeric.min.js"
									] )#>

	<style>
		/* Make the resize lines bigger */
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

	<script>
		$("section[name=tools]").hide();	// immediately hide tools sub-tab (do it here so "show" will restore "flex" instead of "block")
	</script>

    <script>
        'use strict';

        <!---  json visible starting column, JSON hidden columns come back in the leading positions  --->
        const CONFIG = {
                            STARTING_DISPLAY_COLUMN: 8
                            , UI_NAME: "ag_bb_2020_search_v11_12_2020"	// NOTE: Change if column definition changes
                            , GRID_ID: "#bb_grid"
                        };
        <!--- ~~~~~~~~ column positions in json response to be used in filtering logic ~~~~~~~~~~~~~~~~~--->
        const COL = {
                        ACCOUNT: CONFIG.STARTING_DISPLAY_COLUMN + 5
                        , ANALYST: 1
                        , APPROVED: CONFIG.STARTING_DISPLAY_COLUMN + 10
                        , BB_RECEIVED_DATE: CONFIG.STARTING_DISPLAY_COLUMN + 4
                        , BB_REQUEST_APPROVAL_DATE: 4
                        , BB_TYPE_DESCRIPTION: 2
                        , BILLBACK_ID_INT: 0
                        , CLAIMED: CONFIG.STARTING_DISPLAY_COLUMN + 9
                        , CLOSING_METHOD: CONFIG.STARTING_DISPLAY_COLUMN + 11
                        , CREATED_DATE: 3
                        , CTM_ID: CONFIG.STARTING_DISPLAY_COLUMN + 1
                        , DATE_APPROVED: 5
                        , DELIVERY_END: CONFIG.STARTING_DISPLAY_COLUMN + 8
                        , DELIVERY_START: CONFIG.STARTING_DISPLAY_COLUMN + 7
                        , INV: CONFIG.STARTING_DISPLAY_COLUMN + 2
                        , PAID_DATE: 6
                        , PAYEE: CONFIG.STARTING_DISPLAY_COLUMN + 6
                        , RECEIVED_DATE: CONFIG.STARTING_DISPLAY_COLUMN + 4
                        , STATUS:  CONFIG.STARTING_DISPLAY_COLUMN
                        , TITLE: CONFIG.STARTING_DISPLAY_COLUMN + 3
                        , BILLBACK_ID: 7
                        , VENDOR_PAYEE_ID: CONFIG.STARTING_DISPLAY_COLUMN + 12
                        , CREATOR_USER_INT: CONFIG.STARTING_DISPLAY_COLUMN + 13
                        , REQUEST_APPROVAL_USER_INT: CONFIG.STARTING_DISPLAY_COLUMN + 14
                        , APPROVED_USER_INT: CONFIG.STARTING_DISPLAY_COLUMN + 15
                        , DISAGREE_USER_INT: CONFIG.STARTING_DISPLAY_COLUMN + 16
                        , RESET_USER_INT: CONFIG.STARTING_DISPLAY_COLUMN + 17
                        , RESET_ALLOWED: CONFIG.STARTING_DISPLAY_COLUMN + 18
                        , DELETE_ALLOWED: CONFIG.STARTING_DISPLAY_COLUMN + 19
                        , HOLD_ALLOWED: CONFIG.STARTING_DISPLAY_COLUMN + 20
                        , RELEASE_ALLOWED: CONFIG.STARTING_DISPLAY_COLUMN + 21
                        , REASSIGN_ALLOWED: CONFIG.STARTING_DISPLAY_COLUMN + 22
                        , MASS_APPROVE_ALLOWED: CONFIG.STARTING_DISPLAY_COLUMN + 23
                        , DOCUMENT_ATTACHED: CONFIG.STARTING_DISPLAY_COLUMN + 24
                        , DISCREPANCY: CONFIG.STARTING_DISPLAY_COLUMN + 25
                        , NOTACKNOWLEDGED: CONFIG.STARTING_DISPLAY_COLUMN + 26
                        , BB_UPLOAD_DUP_GROUP_ID: CONFIG.STARTING_DISPLAY_COLUMN + 33
                    };

        <!--- ~~~~~~~~~~ glob = global variables  ~~~~~~~~~~ --->
        let glob = {
                        search_requested: false
                        , matching_bbs: []
                        , full_text_search: 0
                        , data_view: "current"
                        , filterStatus: 0
                    };
         <cfif url.status NEQ 0>
        	glob.filterStatus = 1;
        </cfif>

        adjust_grid_height();

        <!--- ~~ define ag-grid configuration ~~ --->
        glob.my_grid = {
                defaultColDef: {     editable:         false
                                    , filter:          false
                                    , resizable:       true
                                    , sortable:        true
                                    , suppressMenu:    true
                                    , suppressMovable: false
                                    , unSortIcon:      false
                                }
                ,columnDefs: [
                            { headerName:'Status', valueGetter:function(p){ return p.data[COL.STATUS] }, width: 100, headerCheckboxSelection:true, headerCheckboxSelectionFilteredOnly:true, checkboxSelection:true }
                            ,{ headerName:'CTM ID', width: 100, valueGetter:function(p){ return p.data[COL.CTM_ID] }, sort: 'desc' }
                            ,{ headerName:'Inv', width: 175, valueGetter:function(p){ return p.data[COL.INV] } }
                            ,{ headerName:'Title',
                                    width: 250,
                                    suppressSizeToFit: true,
                                    valueGetter:function(p){ return p.data[COL.TITLE] } }
                            ,{ headerName:'Received Date',  width: 100,
                                    valueGetter:function(p){ return p.data[COL.RECEIVED_DATE] },
                                    valueFormatter:function(p){ return dayjs(p.data[COL.RECEIVED_DATE].toString(), "YYYYMMDD").format("MM/DD/YYYY"); },
									cellClass: ["mmddyy"]
                                }
                            ,{ headerName:'Account', valueGetter:function(p){ return p.data[COL.ACCOUNT] } }
                            ,{ headerName:'Payee', valueGetter:function(p){ return p.data[COL.PAYEE] } }
                            ,{ headerName:'Delivery Start',width: 100,
                                    valueGetter:function(p){ return p.data[COL.DELIVERY_START] },
                                    valueFormatter:function(p){ return dayjs(p.data[COL.DELIVERY_START].toString(), "YYYYMMDD").format("MM/DD/YYYY"); },
									cellClass: ["mmddyy"]
                                }
                            ,{ headerName:'Delivery End', width: 100,
                                    valueGetter:function(p){ return p.data[COL.DELIVERY_END] },
                                    valueFormatter:function(p){ return dayjs(p.data[COL.DELIVERY_END].toString(), "YYYYMMDD").format("MM/DD/YYYY"); },
									cellClass: ["mmddyy"]
                                }
                            ,{ headerName:'Claimed', width: 75,
                                    type:'numericColumn',
                                    valueGetter:function(p){ return p.data[COL.CLAIMED] },
                                    valueFormatter:function(p){ return numberFormat(p.data[COL.CLAIMED]) }
                                }
                            ,{ headerName:'Approved', width: 75,
                                    type:'numericColumn',
                                    valueGetter:function(p){ return p.data[COL.APPROVED] },
                                    valueFormatter:function(p){ return numberFormat(p.data[COL.APPROVED]) }
                                }
                            ,{ headerName:'Closing Method', width: 140, valueGetter:function(p){ return p.data[COL.CLOSING_METHOD] } , width: 100}
							,{ headerName:'Approved User', width: 140, hide: true, valueGetter:function(p){ return p.data[35] } }
							,{ headerName:'Reset User', width: 140, hide: true, valueGetter:function(p){ return p.data[36] } }
							,{ headerName:'Disagree User', width: 140, hide: true, valueGetter:function(p){ return p.data[37] } }
							,{ headerName:'RFA User', width: 140, hide: true, valueGetter:function(p){ return p.data[38] } }
							,{ headerName:'Creator User', width: 140, hide: true, valueGetter:function(p){ return p.data[39] } }
							,{ headerName:'Analyst User', width: 140, hide: true, valueGetter:function(p){ return p.data[40] } }
                            ,{ headerName:'More Info',
                                    width: 175,
                                    suppressSizeToFit: true,
                                    cellClass: "more_info",
                                    cellRenderer:function(p) {
                                        let current_bb = p.data[ COL.BILLBACK_ID ];
                                        let current_bb_code = p.data[ COL.CTM_ID ];

                                        var eDiv = document.createElement('div');
                                        eDiv.innerHTML = "<a class='button-preview' title='click to preview " + current_bb_code + "'>[ preview ]</a>   " +
                                                            "<a class='button-details' title='click for details of " + current_bb_code + "'>[ details ]</a>   " +
                                                            "<a class='button-val' title='BB deviation tool for " + current_bb_code + "'>[ val ]</a>";


                                        var ePreviewButton = eDiv.querySelectorAll('.button-preview')[0];
                                        ePreviewButton.addEventListener('click', function() {
                                            NewWindowTopLeft("/billbacks/capture/bb_preview.cfm?BBID="+current_bb, "Billback Preview", 900, 640, "yes", "yes");
                                        });

                                        var eDetailsButton = eDiv.querySelectorAll('.button-details')[0];
                                        eDetailsButton.addEventListener('click', function() {
                                            NewWindowTopLeft("/billbacks/scorecard/billback_details.cfm?BBID="+current_bb, "Billback Details", 900, 640, "yes", "yes");
                                        });

                                         var eDevButton = eDiv.querySelectorAll('.button-val')[0];
                                        eDevButton.addEventListener('click', function() {
                                            NewWindowTopLeft("/billbacks/Deviation/Deviation_Main.cfm?bbid="+current_bb+"&caller=BBAgGridScoreCard&source=BBAgGridScoreCard", "Billback Deviations", 900, 640, "yes", "yes");
                                        });

                                        return eDiv;
                                    }

                                }
                            ]
                ,enableRangeSelection:      false
                ,floatingFilter:            false
                ,getRowNodeId:              function(data) { return data[ COL.BILLBACK_ID_INT ] }       // use billback_id as row node id
                ,pagination:                false
                ,rowModelType:              "clientSide"
                ,rowSelection:              'multiple'
                ,suppressContextMenu:       true
                ,suppressRowClickSelection: true
				,suppressDragLeaveHidesColumns: true
                ,isExternalFilterPresent: isExternalFilterPresent
                ,doesExternalFilterPass: doesExternalFilterPass
                //,onFilterChanged: function(e) {console.log(e);}
                ,onCellDoubleClicked:       function(event) { if(event.column.colId == 12){return} else parent.parent.create_tab( event.node.data[ COL.BILLBACK_ID_INT ], event.node.data[COL.CTM_ID] ) }
                ,excelStyles: [
					{ id: "mmddyy", dataType: "dateTime", numberFormat: {format: 'MM/DD/YY'} }
					,{ id: 'stringType', dataType:"string" }
					,{ id: 'header', font:{bold:true, color:"#FFFFFF"}, interior:{color: '#000000', pattern: 'Solid'} }
				]
            };

		ag_grid_default( glob.my_grid );
        init_ag_grid( glob.my_grid, CONFIG.GRID_ID );

		window.onbeforeunload = save_columns;

		// Restore column settings only on initial load, but do not restore the user column visibility.  Once loaded, callback to hide
		ag_restore( glob.my_grid, CONFIG.UI_NAME, hide_columns );

        <!--- ~~~~~~ gather grid content ~~~~~~~ --->
        get_grid_content();

        <!--- ~~~~~ search button handler ~~~~~~ --->
        $("button[name=search]").click( function(e){
            e.preventDefault();
            if (glob.search_requested) {
				// one search at time
                //console.log("search is running...")
            }
            else {
                // if data view was changed ~ refresh grid content/ paid is selected
                const newSearch = checkDataView();
                if (newSearch) {
                    get_grid_content();
                }
                search_content();
            }
            return false;
        });

        $("button[name=reset]").click( function(e) {
            e.preventDefault();

            $('select').prop('selectedIndex',0);
            $("input[name=currentIncludingPaid][value=current]").prop('checked', true);
            $("input[name=duplicate_only]").prop('checked',false);
            $("input[type=text]").val('');
            $("select.multi").multiselect("uncheckAll");
            $("select.single").val('');

			$("button.resetAction").hide();
            $("button.deleteAction").hide();
            $(".reassignAction").hide();

			glob.my_grid.api.deselectAll();
			glob.my_grid.rowSelection = "multiple";

            glob.matching_bbs = [];
            // call the search click handler; if data view changed then data is reloaded
			glob.search_requested = 0;
            $("button[name=search]").trigger( "click" );
            return false;
        });

        $("button[name=refresh]").click( function(e){
            e.preventDefault();
            get_grid_content();
            return false;
		});

        $("li.nav").click( function() {
            let selected_option = $(this);
            $("li.nav").removeClass("active");
            selected_option.addClass("active");
            $("section.middle").hide();
            $("section[name=" + selected_option.attr('name') + "]").show();
        });

        $("input[name=currentIncludingPaid]").click( function(e){
        	var selectedOption = $("input[name=currentIncludingPaid]:checked").val();
        	if(selectedOption == 'current_including_paid_void'){
        		$("button[name=refresh]").prop("disabled",true);
        		$("button[name=refresh]").prop("title","Use Search in order to access 'Current including paid/void' Billback data");
        	}
        	else{
        		$("button[name=refresh]").prop("disabled",false);
        		$("button[name=refresh]").prop("title","Refresh the list with Current Billbacks");
        	}
            return true;
		});


        <!--- ~~~~~~~~~~~~~~~~ adjust columns to fit when window is resized ~~~~~~~~~~~~~~~~~ --->
        $(window).resize(function(){
            adjust_grid_height();
        });

        function save_columns() {
            ag_save( glob.my_grid, CONFIG.UI_NAME );
		};

		// Hide the user columns, only shown when filtered
		function hide_columns() {
			if (glob.my_grid.columnApi.getAllGridColumns()){
				glob.my_grid.columnApi.setColumnsVisible(['12','13','14','15','16','17'], false);
			}
		}

        <!--- ~~~~~~ adjust grid height ~~~~~~ --->
        function adjust_grid_height() {
            let grid_element = $("section" + CONFIG.GRID_ID);
            if (grid_element) {
                let grid_height  = $(window).innerHeight() - grid_element[0].offsetTop;
                grid_element.css( { "height": grid_height + "px", "width": "100%" } );
            }
		}


        <!--- ~~~~~ check data view ~~~~~~ --->
		function checkDataView() {
            const data_view = $("input[name=currentIncludingPaid]:checked").val();
            if (data_view == 'current_including_paid_void' || glob.data_view !== data_view) {
            // if (glob.data_view !== data_view) {
                glob.data_view = data_view;
                return 1;
            }else {
                return 0;
            }
		}


        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~ call backend to gather billbacks to display in the grid ~~~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        function get_grid_content() {
            //$("button.delay").hide();
            //$("button.delay").css("opacity", "0");
            $("button.delay").prop("disabled",true);
            <!--- ~~~~~~~~~ clear record count, grid content & show progressing message ~~~~~~~~~ --->
            $("#record_count").text(" ");
            glob.my_grid.api.setRowData( [] );
            glob.my_grid.api.showLoadingOverlay();
            const form = $( "form" );
            $.ajax({
                    url: "ajax/search.cfm"
                    ,data: form.serialize()
                    ,type: "POST"
                    //,error: function(xhr, status, error) { glob.search_requested = 0; error_handler(arguments); }
                    ,async: true
                }).done(function( result ) {
            			glob.my_grid.api.hideOverlay();
                        //$("button.delay").show();
                        $("button.delay").css("opacity", "1");
                        $("button.delay").prop("disabled",false);
                        var paidOption = $("input[name=currentIncludingPaid]:checked").val();
			        	if(paidOption == 'current_including_paid_void'){
			        		$("button[name=refresh]").prop("disabled",true);
			        	}
			        	else{
			        		$("button[name=refresh]").prop("disabled",false);
			        	}

                        if (typeof result === 'string') {
                            result = JSON.parse(result);
                                glob.my_grid.api.setRowData( result.ROWS );
                                var warnMessage = '';
                                var displayCount = thousands_separators(glob.my_grid.api.getDisplayedRowCount());
                                var d = new Date();
                              	if(displayCount == '50,000'){
									$("#record_count").text("Top " + displayCount + " records");
									$("#dataDate").html(" Top " + displayCount + " records as of: " + moment(d).format('L h:mm:ss a') );
									noty({ text: "Top 50k records returned.<br>Please use filters to refine your results."	//<br>Click anywhere on this box to close.
				                                        ,type: 'information'
				                                        ,layout: 'center'
				                                        ,killer: true
														,timeout:3000
				                        });
								}
								else{
									$("#record_count").text(displayCount + " records");
									$("#dataDate").html(" Data as of: " + moment(d).format('L h:mm:ss a') );
								}
                        }
                        return true;
            	})
            	.then(
            			() =>{
                        if(glob.filterStatus == 1){
                        	//search_content();
                        	$("button[name=search]").trigger("click");
                        	glob.filterStatus = 0; //only filter status first time in from scorecard
                        }
    				})
            	.fail(function(xhr, status, error) { glob.search_requested = 0; error_handler(arguments); });
			}


        var tmpStatusList = '';

        function search_content() {
            glob.search_requested = 1;
            glob.full_text_search = 0;

            $("button.resetAction").hide();
            $("button.deleteAction").hide();
            $(".reassignAction").hide();

            tmpStatusList = $("#statusListSelect").val();

            var bSearchPendingStatus = false;
            if($("#statusListSelect").val()){
                if($("#statusListSelect").val().indexOf("PA") != -1){
                    bSearchPendingStatus = true;
                    $("#statusListSelect").val('PA');
                }
            }

            var sel = $("select[name=actionSelect]").val();
            if(sel== "Reset"){
                $("button.resetAction").show();
                // $("select[name=statusListSelect]").val(["RFA", "APP", "PMT REQ"]);
                glob.my_grid.api.deselectAll();
                glob.my_grid.rowSelection = "single";
            }
            else if(sel== "Delete"){
                $("button.deleteAction").show();
                // $("select[name=statusListSelect]").val(["WIP", "RFA"]);
            }
            else if(sel== "Reassign"){
                $(".reassignAction").show();
                // $("select[name=statusListSelect]").val(["WIP", "RFA"]);
            }

            <!---  enable UI to show while doing heavy JS work  --->
            let loadChain = new LoadChain();

            <!--- ~~~~~ program filter is not blank trigger full-text server-side filtering ~~~~~~ --->
            if ( $("input[name=programKeyword]").val().trim()
                    || ( $("input[name=entityKeyword]").val().trim() && $("select[name=entitySelect]").val().toLowerCase() !== "payee" )
                    || $("input[name=checkNoKeyword]").val().trim()
                    || $("input[name=payeeKeyword]").val().trim()
                    || bSearchPendingStatus == true
                    ) {
                loadChain.push(function(){
                    glob.full_text_search = 1;
                    <!--- ~~~~~~~~~ clear record count, grid content & show progressing message ~~~~~~~~~ --->
                    $("#record_count").text(" ");
                    glob.my_grid.api.showLoadingOverlay();
                });

                loadChain.push(function(){
                    const form = $( "form" );
                    $.ajax({
                        url: "ajax/search_fulltext.cfm?t=" + $.now()
                        ,data: form.serialize()
                        ,type: "POST"
                        ,async: false
                        ,error: function(xhr, status, error) { glob.search_requested = 0; error_handler(arguments); }
                        ,success: function( result ) {
                                                        if (typeof result === 'string') {
                                                            glob.matching_bbs = JSON.parse(result);
                                                        }
                                                    }
                                                });
                });
            }

            <!--- ~~~~~ client-side filtering ~~~~~~ --->
            loadChain.push(function(){
                //reset for Filter
                $("#statusListSelect").val(tmpStatusList);
                $("#statusListSelect option[value='PA']").prop("selected", false);
                glob.my_grid.api.onFilterChanged();
                $("#record_count").text(glob.my_grid.api.getDisplayedRowCount() + " records");
                glob.my_grid.api.hideOverlay();
                glob.search_requested = 0;
                $("#statusListSelect").val(tmpStatusList);
            });
            loadChain.start();
        }

        // Called initially from Settlements.cfm when a BB is approved.  The call traverses up to refreshSearchRow() in search.cfm, which themn calls this function.
        function refreshRow(bb){
        	let rn = glob.my_grid.api.getRowNode(bb.bbheader.billbackidint);
        	let data = rn.data;
        	data[8] = bb.bbheader.status.abbreviation;
        	data[18] = bb.bbheader.approvedamount;
            data[10] = bb.bbheader.bbnumber;
            data[11] = bb.bbheader.title;
        	rn.setData(data);
            get_grid_content();
        }

        // Called initially from edit_billback_events.cfm when a BB is approved.
        function refreshRowFromEdit(bb){

        	let rn      = glob.my_grid.api.getRowNode(bb.bbheader.billbackidint);
            if(typeof rn !== "undefined") {
                let data    = rn.data;
                data[8]     = bb.bbheader.status.abbreviation;
                data[10]    = bb.bbheader.bbnumber;
                data[11]    = bb.bbheader.title;
                data[18]    = bb.bbheader.approvedamount;
                data[22]    = bb.bbheader.requestapproval.idint;
                data[38]    = bb.bbheader.requestapproval.id;
                rn.setData(data);
                glob.search_requested = 1;
                $("button[name=search]").trigger( "click" );
            }
        }

        function compare_numbers(num_1, operator, num_2) {
            switch (operator.trim()) {
                case "=":
                    return num_1 == num_2;
                case ">=":
                    return num_1 >= num_2;
                case "<=":
                    return num_1 <= num_2;
                default:
                    return false;
            }
        }

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~~~~ identify column in json data based on selected date type ~~~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        function date_type_json_position( date_type ) {
            switch (date_type.toLowerCase()) {
                case "start":
                    return COL.DELIVERY_START;
                case "end":
                    return COL.DELIVERY_END;
                case "create":
                    return COL.CREATED_DATE;
                case "rfa":
                    return COL.BB_REQUEST_APPROVAL_DATE;
                case "approved":
                    return COL.DATE_APPROVED;
                case "paid":
                    return COL.PAID_DATE;
                case "inv":
                    return COL.RECEIVED_DATE;
                default:
                    return 0;
            }
        }

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~~~~ identify column in json data based on selected amount type ~~~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        function amount_json_position( amount_type ) {
            switch (amount_type.toLowerCase()) {
                case "claimed":
                    return COL.CLAIMED;
                case "approved":
                    return COL.APPROVED;
                default:
                    return 0;
            }
        }

        <!--- ~~~~~~~~ change date to a simple format YYYYMMDD for easy comparisons ~~~~~~~~~ --->
        function simplify_date( mm_dd_yyyy ) {
            return mm_dd_yyyy
                    ? dayjs( mm_dd_yyyy.toString(), "MM/DD/YYYY" ).format("YYYYMMDD")
                    : '';
        }

        <!--- ~~~~ setting up for filtering ~~~~ --->
        function isExternalFilterPresent() {

			hide_columns();	// hide any previous columns

            if (glob.search_requested) {
                <!---  place filtering elements into global keys  --->
                glob.ctm_id  = $("input[name=BBCodeKeyword]").val().trim().toLowerCase();
                glob.inv     = $("input[name=BBNumberKeyword]").val().trim().toLowerCase();
                glob.account = $("input[name=payeeKeyword]").val().trim().toLowerCase();
                glob.statuses = $("select[name=statusListSelect]").val();
                if (glob.statuses === null) {
                    glob.statuses = [];
                }
                glob.analysts = $("select[name=analystListSelect]").val();

                // convert selected analysts to numeric values
                glob.analysts = (glob.analysts === null)
                                    ? []
                                    : glob.analysts.map(function(i){ return parseInt(i,10)});

                glob.historyType = $("select[name=historySelect]").val();
                glob.history = $("select[name=historyUsernameSelect]").val();
                // convert selected history to numeric values
                glob.history = (glob.history === null)
                                    ? []
                                    : glob.history.map(function(i){ return parseInt(i,10)});

                glob.closing_methods = $("select[name=closing_method]").val();
                // convert selected closing methods to lower case
                glob.closing_methods = (glob.closing_methods === null)
                                            ? []
                                            : glob.closing_methods.map(function(i){ return i.toLowerCase() });
                glob.types = $("select[name=typeListSelect]").val();
                // convert selected types to lower case
                glob.types = (glob.types === null)
                                ? []
                                : glob.types.map(function(i){ return i.toLowerCase() });
                glob.start_date = { val: simplify_date( $("input[name=dateRangeStartValueKeyword]").val() )
                                    , type_position: date_type_json_position( $("select[name=dateRangeStartTypeSelect]").val() )
                                    , operator: $("select[name=dateRangeStartCriteriaSelect]").val()
                                };
                glob.end_date = { val: simplify_date( $("input[name=dateRangeEndValueKeyword]").val() )
                                    , type_position: date_type_json_position( $("select[name=dateRangeEndTypeSelect]").val() )
                                    , operator: $("select[name=dateRangeEndCriteriaSelect]").val()
                                };
                glob.amount = { val: $("input[name=amountValueKeyword]").val()
                                    , type_position: amount_json_position( $("select[name=amountTypeSelect]").val() )
                                    , operator: $("select[name=amountCriteriaSelect]").val() };
                glob.entity = { val: $("input[name=entityKeyword]").val().trim()
                                    , type: $("select[name=entitySelect]").val().trim().toLowerCase() };
                glob.check_number = $("input[name=checkNoKeyword]").val().trim();
                glob.actionType = $("select[name=actionSelect]").val();
                glob.condition = $("select[name=conditionSelect]").val();
                glob.duplicateonly = $("input[name=duplicate_only]").prop('checked');

            }
            else {
                <!---  reset filtering elements in global keys  --->
                glob.ctm_id          = '';
                glob.inv             = '';
                glob.account         = '';
                glob.statuses        = [];
                glob.analysts        = [];
                glob.closing_methods = [];
                glob.types           = [];
                glob.matching_bbs    = [];
                glob.start_date      = { val: '', type_position: -1, operator: '' };
                glob.end_date        = { val: '', type_position: -1, operator: '' };
                glob.amount          = { val: '', type_position: -1, operator: '' };
                glob.entity          = { val: '', type: '' };
                glob.check_number    = '';
                glob.history         = [];
                glob.historyType        = '';
                glob.actionType      = [];
                glob.condition       = [];
                glob.duplicateonly   = false;
            }
            if(glob.historyType != '' && glob.history.length){
            	switch (glob.historyType) {
	                case "Approved By":
	                	glob.my_grid.columnApi.setColumnVisible('12', true);
	                    break;
	                case "Reset By":
	                	glob.my_grid.columnApi.setColumnVisible('13', true);
	                    break;
	                case "Disagreed By":
	                	glob.my_grid.columnApi.setColumnVisible('14', true);
	                    break;
	                case "RFA By":
	                	glob.my_grid.columnApi.setColumnVisible('15', true);
	                    break;
	                case "Created By":
	                	glob.my_grid.columnApi.setColumnVisible('16', true);
	                    break;
	                default:
	                    console.log('History type not handled');
	            }
            }
            if(glob.analysts.length){
            	glob.my_grid.columnApi.setColumnVisible('17', true)
            }

            return (glob.search_requested === 1);
        }

        <!--- ~~~~~ client-side filtering ~~~~~~ --->
        function doesExternalFilterPass( node ) {
             //console.log(node );
            //if (glob.search_requested) {
                if (
                            <!--- ~~~~~~~~~~~~~ CTM ID filter exists and matching failed ~~~~~~~~~~~~~ --->
                        ( glob.ctm_id && (node.data[COL.TITLE].toString().toLowerCase().indexOf(glob.ctm_id) < 0 && node.data[COL.CTM_ID].toLowerCase().indexOf( glob.ctm_id ) < 0) )
                            <!--- ~~~~~~~~~~~~~ INV filter exists and matching failed ~~~~~~~~~~~~~ --->
                        || ( glob.inv && node.data[COL.INV].toString().toLowerCase().indexOf( glob.inv ) < 0 )
                            <!--- ~~~~~~~~~~~~~ ACCOUNT filter exists and matching failed ~~~~~~~~~~~~~ --->
                        //|| ( glob.account && node.data[COL.ACCOUNT].toLowerCase().indexOf( glob.account ) < 0 )
                            <!--- ~~~~~~~~~~~~~ STATUSES filter exists and matching failed ~~~~~~~~~~~~~ --->
                        || ( glob.statuses.length && glob.statuses.indexOf( node.data[COL.STATUS]) < 0 )
                            <!--- ~~~~~~~~~~~~~ ANALYST filter exists and matching failed ~~~~~~~~~~~~~ --->
                        || ( glob.analysts.length && glob.analysts.indexOf( node.data[COL.ANALYST]) < 0 )
                            <!--- ~~~~~~~~~~~~~ CLOSING METHOD filter exists and matching failed ~~~~~~~~~~~~~ --->
                        || ( glob.closing_methods.length && glob.closing_methods.indexOf( node.data[COL.CLOSING_METHOD].toLowerCase()) < 0 )
                            <!--- ~~~~~~~~~~~~~ TYPE filter exists and matching failed ~~~~~~~~~~~~~ --->
                        || ( glob.types.length && glob.types.indexOf( node.data[COL.BB_TYPE_DESCRIPTION].toLowerCase()) < 0 )
                            <!--- ~~~~~~~~~~~~~ historyUsername filter exists and matching failed ~~~~~~~~~~~~~ --->
                            /*  history select mapping
                                CREATOR_USER_INT		    Created By
                                REQUEST_APPROVAL_USER_INT	RFA By
                                APPROVED_USER_INT		    Approved By
                                DISAGREE_USER_INT		    Disagreed By
                                RESET_USER_INT			    Reset By
                            */
                        || ( glob.history.length && glob.historyType === 'Created By' && glob.history.indexOf( node.data[COL.CREATOR_USER_INT]) < 0 )
                        || ( glob.history.length && glob.historyType === 'RFA By' && glob.history.indexOf( node.data[COL.REQUEST_APPROVAL_USER_INT]) < 0 )
                        || ( glob.history.length && glob.historyType === 'Approved By' && glob.history.indexOf( node.data[COL.APPROVED_USER_INT]) < 0 )
                        || ( glob.history.length && glob.historyType === 'Disagreed By' && glob.history.indexOf( node.data[COL.DISAGREE_USER_INT]) < 0 )
                        || ( glob.history.length && glob.historyType === 'Reset By' && glob.history.indexOf( node.data[COL.RESET_USER_INT]) < 0 )

                        <!--- ~~~~~~~~~~~~~ ACTIONS filter exists and matching failed ~~~~~~~~~~~~~ --->
                        || ( glob.actionType.length && glob.actionType == 'Reset' && node.data[COL.RESET_ALLOWED] == 0 )
                        || ( glob.actionType.length && glob.actionType == 'Delete' && node.data[COL.DELETE_ALLOWED] == 0 )
                        || ( glob.actionType.length && glob.actionType == 'Hold' &&  node.data[COL.HOLD_ALLOWED] == 0 )
                        || ( glob.actionType.length && glob.actionType == 'Release' &&  node.data[COL.RELEASE_ALLOWED] == 0 )
                        || ( glob.actionType.length && glob.actionType == 'Reassign' &&   node.data[COL.REASSIGN_ALLOWED] == 0 )
                        || ( glob.actionType.length && glob.actionType == 'Mass Approve' &&  node.data[COL.MASS_APPROVE_ALLOWED] == 0 )

                         <!--- ~~~~~~~~~~~~~ Conditions filter exists and matching failed ~~~~~~~~~~~~~ --->
                         /*
                            Doc attached
                            No Doc attached
                            Discrepancy
                            Not Ack'd
                         */
                        || ( glob.condition.length && glob.condition.toLowerCase() == 'doc attached' &&  node.data[COL.DOCUMENT_ATTACHED] == 0)
                        || ( glob.condition.length && glob.condition.toLowerCase() == 'no doc attached' &&  node.data[COL.DOCUMENT_ATTACHED] == 1)
                        || ( glob.condition.length && glob.condition.toLowerCase() == 'discrepancy' && node.data[COL.DISCREPANCY] == 0)
                        || ( glob.condition.length && glob.condition.toLowerCase() == 'not ack\'d' &&  node.data[COL.NOTACKNOWLEDGED] == 0)

                        <!--- ~~~~~~~~~~~~~ Duplicate filter exists and matching failed ~~~~~~~~~~~~~ --->
                        || (glob.duplicateonly == true && node.data[COL.BB_UPLOAD_DUP_GROUP_ID] == "")

                    )

                    return false;

                <!--- ~~~ start/end date, amount filtering ~~~~ --->
                if (
                        ( glob.start_date.val.length && !compare_numbers(simplify_date(node.data[glob.start_date.type_position]), glob.start_date.operator, glob.start_date.val) )
                        || ( glob.end_date.val.length && !compare_numbers(simplify_date(node.data[glob.end_date.type_position]), glob.end_date.operator, glob.end_date.val) )
                        || ( glob.amount.val.length && !compare_numbers(node.data[glob.amount.type_position], glob.amount.operator, parseFloat(glob.amount.val)) )
                    )
                    return false;

				if(
                        glob.entity.type === "payee" && glob.entity.val.length && node.data[COL.PAYEE].toLowerCase().indexOf( glob.entity.val.toLowerCase() ) < 0 && glob.entity.val.length && node.data[COL.VENDOR_PAYEE_ID].toString().toLowerCase().indexOf( glob.entity.val.toLowerCase() ) < 0
                	)
                    return false;

                if ( glob.full_text_search ) {
                    if (
                            ( glob.matching_bbs.length == 0 )
                            || ( glob.matching_bbs.indexOf( node.data[0] ) < 0 )
                        )
                        return false;
                }
            //}
            <!---  current row matches filtering criteria  --->
            //console.log(node );
            return true;
        }

        $("input.currency").numeric({ negative: true, decimal: true });

        $(".date").datepicker({
            dateFormat: "m/d/yy",
            changeMonth: true,
            changeYear: true,
            onSelect: function( selected ) {
                // change date limit based on selected value
                if ( jQuery(this).attr("name") === "dateRangeStartValueKeyword" )
                    jQuery("input[name=dateRangeEndValueKeyword]").datepicker("option", "minDate", selected);
                else
                    jQuery("input[name=dateRangeStartValueKeyword]").datepicker("option", "maxDate", selected);
            }
        });

        $("button.export").click(function(e){

            //var excelColKeys = ['BB_Status_Abbreviation','BB_Code','BB_Reference','BB_Title','BB_Received_Date','Payee','VendorPayee','BB_Start_Date','BB_End_Date','BB_Amount','Approved_Amount','Billback_Closing_Method_Abbreviation'];

            var excelColKeys = [];
            var colSt = glob.my_grid.columnApi.getColumnState();


            colSt.forEach(function(item){
                let colObj = glob.my_grid.columnApi.getColumn(item.colId);
                if(colObj.userProvidedColDef.headerName != "More Info"){
		            excelColKeys.push(colObj);
                }
        	});

            var params = {
                allColumns: false,
                columnKeys: excelColKeys,
                fileName: 'Billback_List',
                sheetName: 'Billback_List'
            };

            glob.my_grid.api.exportDataAsExcel(params);
            return false;
		});

		// Create new Invoice
		$("#create_inv").click(function(e){
			parent.create_tab (0, "new");
		});

		$("button.resetAction").click(function(e){
			var selectedRows = glob.my_grid.api.getSelectedRows();
			if (selectedRows.length == 0) {
				noty({ layout:"center", type:"error", text: "Please select at least one Invoice.", timeout:3000,
						animation: {open:{height:'toggle'}, close:{height:'toggle'}, easing:'swing',speed: 50} });
			}
			else {
				let popup = dhtmlx.modalbox( {
					text: "Do you really want to set this Invoice to Work In Progress status?",
					title: "Confirm Reset",
					buttons: ["Yes", "No"],
					callback: function(res) {
						// res is 0 if they picked the first button (Yes)
						if (res == 0) {
							glob.my_grid.api.showLoadingOverlay();
							glob.my_grid.api.forEachNodeAfterFilter(function(node) {
								<!--- ~~ apply to selected rows only ~~~ --->
								if (node.selected) {
									//console.log(node.data[0], "<cfoutput>#request.AccessStructure.user_id#</cfoutput>");
									$.ajax({ url: "/mvc/Models/Billback/BillbackManager.cfc"
											,type: "post"
											,data: { 	method: "resetBB",
														userId:'<cfoutput>#request.AccessStructure.user_id#</cfoutput>',
														billbackID:	node.data[0]
													}
											,async: true
											,error: function(xhr, status, error) { glob.search_requested = 0; error_handler(arguments); }
											,success: function( result ) {
												glob.search_requested = 1; get_grid_content();
												noty({ layout:"center", type:"information", text: "Reset complete", timeout:2000,
													animation:{open:{height:'toggle'},close:{height:'toggle'},easing:'swing',speed:50} });
												return true;
											}
									});
								}
							});
						}
					}
				});
				return false;
			}
			return false;
        });

        //delete billbacks
        $("button.deleteAction").click(function(e){
			var selectedRows = glob.my_grid.api.getSelectedRows();
			if (selectedRows.length == 0) {
				noty({ layout:"center", type:"error", text: "Please select at least one Invoice.", timeout:3000,
						animation: {open:{height:'toggle'}, close:{height:'toggle'}, easing:'swing',speed: 50} });
			}
			else {
				let popup = dhtmlx.modalbox( {
					text: "Do you really want to delete the selected Invoice(s)?",
					title: "Confirm Deletion",
					buttons: ["Yes", "No"],
					callback: function(res) {
						// res is 0 if they picked the first button (Yes)
						if (res == 0) {
							let lBillback = 0;
							glob.my_grid.api.showLoadingOverlay();
							glob.my_grid.api.forEachNodeAfterFilter(function(node) {
								<!--- ~~ apply to selected rows only ~~~ --->
								if (node.selected) {
									if(lBillback == 0){
										lBillback = node.data[0];
									}
									else{
										lBillback = lBillback + ',' + node.data[0];
									}
								}
							});

							$.ajax({ url: "/mvc/Models/Billback/BillbackManager.cfc"
									,type: "post"
									,data: { 	method: "checkBBEligibleForDelete",
												userId:'<cfoutput>#request.AccessStructure.user_id#</cfoutput>',
												billbackList:	lBillback
											}
									,async: true
									,error: function(xhr, status, error) { glob.search_requested = 0; error_handler(arguments); }
									,success: function( result ) {
										glob.search_requested = 1; get_grid_content();
										noty({ layout:"center", type:"information", text: "Deletion complete", timeout:2000,
											animation:{open:{height:'toggle'},close:{height:'toggle'},easing:'swing',speed:50} });
										return true;
									}

							});
						}
					}
				});
				return false;
			}
			return false;
		});

         //reassign billbacks
        $("button.reassignAction").click(function(e){
			var selectedRows = glob.my_grid.api.getSelectedRows();
			if (selectedRows.length == 0) {
				noty({ layout:"center", type:"error", text: "Please select one Invoice.", timeout:3000,
						animation: {open:{height:'toggle'}, close:{height:'toggle'}, easing:'swing',speed: 50} });
			}
			else {
				let popup = dhtmlx.modalbox( {
					text: "Do you really want to reassign the selected Invoice(s)?",
					title: "Confirm Reassignment",
					buttons: ["Yes", "No"],
					callback: function(res) {
						// res is 0 if they picked the first button (Yes)
						if (res == 0) {
							var BBFilterparams =  $("select[name=reassignBBUserSelect]").val();
							let lBillback = 0;
							glob.my_grid.api.showLoadingOverlay();
							glob.my_grid.api.forEachNodeAfterFilter(function(node) {
								<!--- ~~ apply to selected rows only ~~~ --->
								if (node.selected) {
									if(lBillback == 0){
										lBillback = node.data[0];
									}
									else{
										lBillback = lBillback + ',' + node.data[0];
									}
								}
							});
							$.ajax({ url: "/mvc/Models/Billback/BillbackManager.cfc"
									,type: "post"
									,data: { 	method: "reassignBB",
												BBFilterParams: BBFilterparams,
												billbackList:	lBillback
											}
									,async: true
									,error: function(xhr, status, error) { glob.search_requested = 0; error_handler(arguments); }
									,success: function( result ) {
										glob.search_requested = 1; get_grid_content();
										noty({ layout:"center", type:"information", text: "Reassign complete", timeout:2000,
											animation:{open:{height:'toggle'},close:{height:'toggle'},easing:'swing',speed:50} });
									}
							});
						}
					}
				});
				return false;
			}
			return false;
		});


		// Get selected BBs into a string list (used for upload and search)
		function getSelectedBBs() {
			var selectedRows = glob.my_grid.api.getSelectedRows();
			var billbackListString = '';

			if (selectedRows.length != 0) {
				selectedRows.forEach(function(selectedRow, index) {
					if (index > 0) {
						billbackListString += ',';
					}
					billbackListString += selectedRow[7];
					// console.log("Sel row: "+selectedRow);
				});
			}
			return billbackListString;
		}
		/*.....................	UPLOAD .....................*/
		function uploadDocs() {
			let bbListString = getSelectedBBs();

			if (bbListString === '') {
				noty({ layout:"center", type:"error", text: "Please select at least one Invoice.", timeout:3000,
					animation: {open:{height:'toggle'}, close:{height:'toggle'}, easing:'swing',speed: 50} });
			}
			else {
				// alert("Uploading to: "+bbListString);
				NewWindow("/common_files/documents/create_multiple_document_details.cfm?BBMassUpload=1&BillbackList="+bbListString, "winUpload", 600, 500, "yes", "yes");

			}
		}

		/*.....................	SEARCH .....................*/
		function searchDocs() {
			let bbListString = getSelectedBBs();

			if (bbListString === '') {
				noty({ layout:"center", type:"error", text: "Please select at least one Invoice.", timeout:3000,
					animation: {open:{height:'toggle'}, close:{height:'toggle'}, easing:'swing',speed: 50} });
			}
			else {
				// alert("Searching: "+bbListString);
				// TBD How to upload to multiple BBs?
				// NewWindow("/billbacks/capture/Attachments_Form.cfm?BillbackList="+bbListString,"winSearch","600","810","yes","yes");
			}
		}

		function thousands_separators(num)
		  {
		    var num_parts = num.toString().split(".");
		    num_parts[0] = num_parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
		    return num_parts.join(".");
		  }

    </script>



    <script>
        config.multiselect.buttonWidth  = null;
        config.multiselect.selectedList = 1;
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~~ define minimum number of rows to enable find feature in dropdown ~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        const multi_select_min_rows_filter = <cfoutput>#max( 10   <!--- default value --->
                                                            ,val( application.util.query.get_setting("multi_select_min_rows_filter", 0) )  <!--- optional setting --->
                                                            )
                                                            #</cfoutput>;

        $("select.multi").multiselect( config.multiselect );
        $("select.multi").each(function() {
            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!--- ~ enable find feature when number of options in dropdown is large (customizable) ~ --->
            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            if ($("option", this).length > multi_select_min_rows_filter) {
                $(this).multiselectfilter( { label: "Find", placeholder: "" } );
            }
        });

        <!---  trigger searching function after pressing the enter key  --->
        $(document).ready(function() {
                                        $(window).keydown( function( event ) {
                                            if ( event.keyCode == 13 ) {
                                                event.preventDefault();
                                                search_content();
                                                return false;
                                            }
                                        });
                                    });


		// handler for clicking collapsible section header
		var arrowDown  = '<cfoutput>#local.arrowDown#</cfoutput>';
		var arrowRight = '<cfoutput>#local.arrowRight#</cfoutput>';
		$( ".sectionHeader" ).on( "click", function() {
			var imgUrl = $(this).children(0).attr('src');
			if ( imgUrl == arrowDown ) {
				$(this).children(0).attr("src", arrowRight);
			}else {
				$(this).children(0).attr("src", arrowDown);
			}
			$(this).next().toggle();        // show/hide following div

			// When open/close section, resize the grid (to take advantage of more room available)
			adjust_grid_height();
		});

    </script>

    <cfinclude template="/common_files/focus.cfm">
</body>
</html>