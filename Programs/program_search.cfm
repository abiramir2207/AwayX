<!---
  * ====================================================================================================
  * @Author: Chris Nguyen
  * @Date: 2018-02-01
  *
  * @Remarks:
  *
  *
  *
  *
  * ====================================================================================================
--->
<cfparam name="url.CPAccess" default=""><!--- 83860 URL.CPAccess will be used in Application_Common.cfm ---->
<cfparam name="url.scorecard_status" default="0">
<cfparam name="url.Include_work_in_progress_below_me" default="0">
<cfparam name="url.Creating_User_Position" default="0">
<cfparam name="url.importlist_type" default="0">
<cfparam name="url.Formname" default="">
<cfparam name="url.Fieldname" default="">
<cfparam name="url.display_type" default="0">

<cfset local.External_Customer_Profile_Access = 0 />
<cfset local.URLCPAccessArg1 = "" />
<cfset local.URLCPAccessArgN = "" />
<cfif request.AccessStructure.External_Customer_Profile_Access EQ "1">
	<cfset local.External_Customer_Profile_Access = 1 />
	<cfset local.URLCPAccessArg1 = "CPAccess=#URL.CPAccess#" />
	<cfset local.URLCPAccessArgN = "&CPAccess=#URL.CPAccess#" />
</cfif>

<cfinclude template="program_columns.cfm">

<!doctype html>
<html lang="en">
<head>
	<title>Program Search</title>
	<cfsavecontent variable="head_content">
	<cf_include files="/styles/font-awesome.min.css">
	<style>
		html, body {
			margin: 0;
			padding: 0;
		}
		.btn-icon {
			color: #406be4;
		}
		.btn-icon-enlarged {
			color: #406be4;
			font-size: 1.3em;
			position: relative;
			top: -1px;
		}
		.box {
			box-sizing: border-box;
		}
		#container {
			display: flex;
			height: 99vh;
			border: 0px solid black;
		}
			fieldset {
				border: 1px solid #d8d9dd;
				border-radius: 8px;
				margin-right: 5px;
				min-width: 240px;
			}



		.header-box {
			background-color: #ffedd2;
			border-radius: 8px 8px 0px 0px;
			font-size: 12px;
			height: 0.7rem;
			margin: -1px;       /* overwrite border */
			padding: 5px;       /* padding+contents = height of header */
			padding-left: 10px;
			border-bottom: 1px solid #d8d9dd;
		}
			a:link#close,
			a:visited#close {
				background-color: #ffe5bf;
				border-radius: 0px 8px 0px 0px;
				color : #406BE4;
				text-decoration : none;
				cursor: pointer;
				float: right;
				margin: -5px;   /* override header-box padding to make it flush */
				padding-right: 10px;
			}
			a:hover#close {
				text-decoration : underline;
			}

			a:link#options,
			a:visited#options {
				background-color: #ffe5bf;
				border-radius: 8px 0px 0px 0px;
				color : #406BE4;
				text-decoration : none;
				float: left;
				margin: -5px;   /* override header-box padding to make it flush */
				margin-left: -10px;   /* override header-box padding-left to make it flush */
				margin-right: 25px;
				padding-left: 10px;
				padding-right: 10px;
				display: none;
				cursor: default;
			}
				a:hover#options {
					text-decoration : underline;
				}


			legend.ps {
				margin-left: 15px;
				padding: 0 8px;
				font-size: 12px;
				font-weight: bold;
				color: #343540;
			}
			#filters {
				flex: 0 0 240px;
				transition: margin 0.3s ease
			}
				.action {
					padding: 0px 15px;
					font-weight: 600;
					cursor: pointer;
					color: blue;
				}
					.action::after {
						color: red;
						font-weight: bold;
						content: " ]"
					}
					.action::before {
						color: red;
						font-weight: bold;
						content: "[ "
					}

            div.flex {
                display: flex;
                align-items: center;
            }

            div.search_results {
                width: 50%;
            }

            div.refresh_data {
                justify-content: flex-end;
                width: 50%;
            }

			#grid {
				flex: 10 1 auto;
				padding: 0;
				margin: 0;
			}
				#grid_summary {
					display: flex;
					margin: 0.85vh 0 0.7vh 0;
				}
					#grid_count {
						color: #343540;
					}
					#grid_filters {
					}
					div.filler {
						flex-grow: 10;
					}
				#myGrid {
					height: 90.0vh;
				}
				a.preview, a.details, a.quick_pay, a.payment {
					margin-right: 4px;
				}
	</style>
	</cfsavecontent>
	<cfhtmlhead text="#application.util.string.compress( head_content )#">
</head>
<body>
	<cfset jQueryUI.widgets = "tooltip,datepicker">
	<cfinclude template="/common_files/jQuery.cfm">


	<div id="container" class="box">

		<!-- Left pane -->
		<fieldset style="padding:0px;" id="filters" class="box">
			<div class="header-box">
                <cfif local.External_Customer_Profile_Access eq 0>
                    Options
                    <span style="padding: 0 0 0 5px">
                        <i class="fa fa-info-circle btn-icon" id="selectedOptions" title="Select filters to search" style="font-size:14px"></i>
                    </span>
                </cfif>
				<a id="close" class="header-box" href="#" onclick="hideOptions();return false;"><i class="fa fa-angle-double-left btn-icon-enlarged"></i></a>
			</div>
			<cfinclude template ="/programs/program_search_options.cfm">
		</fieldset>

		<!-- Right pane -->
		<fieldset id="grid" class="box">
            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!--- ~ Search results & refresh data ~~ --->
            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <div class="flex header-box">
                <div class="flex search_results">
				    <a id="options" class="header-box" href="#" onclick="showOptions();return false;"><i class="fa fa-angle-double-right btn-icon-enlarged"></i></a>
				    Search results:&nbsp; <span id="grid_count"> ...</span>
                </div>
                <div class="flex refresh_data">
                    <span class="last_refresh"></span>
                    <button type="button" id="refresh_data" class="button" onClick="filterData('MainSearch', 1)" style="width:103px;text-align:center;position:relative;right:-4px;"><i class="fa fa-refresh btn-icon"></i>&nbsp; refresh data</button>
                </div>
			</div>

			<div id="grid_summary">
				<cfif local.External_Customer_Profile_Access eq 0>
					<cfif url.importlist_type eq 1>
					<button type="button" id="import_selected" class="button" onClick="importSelected()">import selected</button>
					</cfif>

					<button type="button" id="select_all" class="button">select all</button>
					<button type="button" id="unselect_all" class="button">unselect all</button>
					<cfif stProgramSettings.createProgramAccess>
						<button type="button" id="create_program" class="button">
						<i class="fa fa-plus btn-icon"></i>&nbsp;create program</button>
					</cfif>
					<button type="button" id="download_data" class="button">
						<i class="fa fa-arrow-down btn-icon"></i>&nbsp;download data</button>

					<!--- Keep class="hidden". It will be only be shown conditionally. --->
					<button type="button" id="delete" class="hidden button" onClick="deleteProgram()">delete selected</button>
					<button type="button" id="won_loss_status" class="hidden button" onClick="setWonLossProgram()">edit won/loss status</button>
					<button type="button" id="mass_approve" class="hidden button" onClick="setMassApproveProgram()">mass approve</button>
					<button type="button" id="release" class="hidden button" onClick="setReleaseProgram()">release</button>
				</cfif>

				<div class="filler"></div>
				<cfif local.External_Customer_Profile_Access eq 0>
				<button id="column_tool" class="button"></button>
				</cfif>
			</div>
			<div id="myGrid" class="ag-theme-balham"></div>
		</fieldset>
	</div>

	<cfscript>
		request.ag_grid_version     = 20;
		variables.DefaultSortColumn = stProgramSettings.userProgram.Scorecard_Sort_option;
		variables.DefaultSortOrder  = stProgramSettings.userProgram.Scorecard_Sort_Method;
		variables.SortOrder         = "'asc','desc'";

		variables.width = 1345;
		variables.height = 950;
		if(application.appSettingsGet.get_Setting('Custom_RFP_Process',0) == 1){
			variables.width = 1875;
		}
	</cfscript>

	<cfinclude template="/common_Files/ag-Grid.cfm">
	<style>
		.ag-theme-balham {
			font-size: 11px;
		}
		.ag-header {
			font-size: 11px !important;
		}
		.ag-theme-balham .ag-cell {
			padding-right: 2px;
		}
		.ag-theme-balham .ag-header-cell-label {
			width: 100%;	/* work around ag-grid bug #2328 which leaves space for menu icon */
		}
  		.ag-theme-balham .ag-row-selected {
    		border-bottom-color: #b5b5b5; /* don't hide lines when selected */
		}
        .ag-theme-balham .ag-selection-checkbox span {
            top: 1.5px;
        }
	</style>

	<script>
        set_grid_full_height("myGrid");
		var QuickPayHeight =  window.screen.height;
		var QuickPayWidth =  window.screen.width;
		let focus_on_search = 1;
		let initial_load = 1;
		let grid_data = '';
		let contract_main_id = 0;
		let gridOptions = {
			columnDefs: [/* Keep "lockPosition:true" for the first 2 columns. This way when a user moves the column by dragging, the column index of the columns are preserved.
						Without this change, "Bid Status" column would lose its original column index of 1. We always want to show "Bid Status"as the second column. */
						{width:23,
							checkboxSelection:function(params)
							{
								 if ($("select[name=action_list]").multipleSelect('getSelects').toString() == 3 && params.data.PLANNER_ID != 0)
								 {
								 	return false;
								 }
								return true;
							}
						, suppressToolPanel:true, suppressMovable:true, sortable:false, pinned:"left", lockPosition:true<cfif local.External_Customer_Profile_Access eq 1>,hide:true</cfif>,bsaSupressExcel:1 },
						{headerName:"Bid Status", field:"BIDREQUESTSTATUS", width:120, lockPosition:true,
									 cellRenderer:function(params) {
																		return '<a href="#" class="bid_won_loss_status" title="Set won/lost" onClick="setWonLossProgramText(this,\'' + params.data.CONTRACT_MAIN_ID + '\');">[ W ]</a>'
																	},
										hide:true, suppressToolPanel:true},
						{headerName: "Status", field: "STATUS", width: 70, sortingOrder: [<cfoutput>#variables.SortOrder#</cfoutput>]},
						{headerName: "RFA Age", field: "RFAAGE", width: 70, sortingOrder: [<cfoutput>#variables.SortOrder#</cfoutput>]<cfif local.External_Customer_Profile_Access eq 1>,hide:true</cfif>},
						{headerName: "Program", field: "PROGRAM", width: 110, suppressToolPanel:true, sortingOrder: [<cfoutput>#variables.SortOrder#</cfoutput>] <cfif variables.DefaultSortColumn eq "program">,sort: <cfoutput>'#lcase(variables.DefaultSortOrder)#'</cfoutput></cfif>,
									 onCellClicked: function(params) {
														let contract_main_id = params.data.CONTRACT_MAIN_ID;
														let planner_id = params.data.PLANNER_ID;
														let template_id = params.data.TEMPLATE_ID;
														let win_name = 'winSummary_' + contract_main_id;
														if ( params.data.ISCATALOG == 0 ) {
															if ( params.data.PLANNER_ID == 0 ||  (params.data.PLANNER_ID != 0 && params.data.RETAIL_PLANNER_PROGRAM_SPECIFIC_APPROVAL == 1)) {
																NewWindowTopLeft("/CID_Wrapper.cfm?Program_ID="+contract_main_id+"&Page_Relocate=/common_files/contracts/contract_edit_menu.cfm",win_name,<cfoutput>"#variables.width#","#variables.height#"</cfoutput>,"yes","yes");
															}
															else {
																	popup2022( "planner_program_open.cfm?program_id="+contract_main_id+"&planner_id="+planner_id+"&template_id="+template_id, win_name, "XL", "LG" )
															}
														}
										},
									 cellRenderer: function(params) {
														let prg_link = '<a href="#" title="Click here to view/edit program">[' + params.value + ']</a>';
														if(params.data.ISCATALOG == 1 && params.data.BEST_PLAN_PROGRAM == 0) {
															/* The user should not be able to click on the link to open the program for catalog programs. */
															prg_link = '<span style="color:#808080">[' + params.value + ']</span>';
														}
														if(params.data.ISCATALOG == 0 && params.data.BEST_PLAN_PROGRAM == 1) {
															/* The user should not be able to click on the link to open the program for catalog programs. */
															prg_link = '<span style="color:red">[' + params.value + ']</span>';
														}
														return prg_link;
									 }
									},
						{headerName: "Title", field: "TITLE", width: 120, sortingOrder: [<cfoutput>#variables.SortOrder#</cfoutput>]<cfif variables.DefaultSortColumn eq "title">,sort: <cfoutput>'#lcase(variables.DefaultSortOrder)#'</cfoutput></cfif>},
						{headerName: "Type", field: "TYPE", width: 120, sortingOrder: [<cfoutput>#variables.SortOrder#</cfoutput>]<cfif variables.DefaultSortColumn eq "type">,sort: <cfoutput>'#lcase(variables.DefaultSortOrder)#'</cfoutput></cfif>},
						{headerName: "Start Date", field: "STARTDATE", width: 70, valueFormatter: DateCellRenderer, sortingOrder: [<cfoutput>#variables.SortOrder#</cfoutput>]<cfif variables.DefaultSortColumn eq "startdate">,sort: <cfoutput>'#lcase(variables.DefaultSortOrder)#'</cfoutput></cfif>},
						{headerName: "End Date", field: "ENDDATE", width: 70, valueFormatter: DateCellRenderer, sortingOrder: [<cfoutput>#variables.SortOrder#</cfoutput>]<cfif variables.DefaultSortColumn eq "enddate">,sort: <cfoutput>'#lcase(variables.DefaultSortOrder)#'</cfoutput></cfif>},
						{headerName: "RSP", field: "RSP", width: 110, sortingOrder: [<cfoutput>#variables.SortOrder#</cfoutput>]},
						<cfif stProgramSettings.businesssegmenton>
						{headerName: displayBusinessSegmentLabel, field: "BUSINESSSEGMENT", width: 70, sortingOrder: [<cfoutput>#variables.SortOrder#</cfoutput>]},
						</cfif>
						<cfif stProgramSettings.userprogram.display_payment_dollars>
						{headerName: displayTradeDollarsLabel, field: "TRADEDOLLARS", width: 90, valueFormatter: CurrencyCellRenderer, type: "numericColumn", sortingOrder: [<cfoutput>#variables.SortOrder#</cfoutput>]<cfif local.External_Customer_Profile_Access eq 1>,hide:true</cfif>},
						</cfif>
						<cfif stProgramSettings.userprogram.display_payment_dollars>
						{headerName: displayPaymentDollarsLabel, field: "PAYMENTDOLLARS", width: 90, valueFormatter: CurrencyCellRenderer, type: "numericColumn", sortingOrder: [<cfoutput>#variables.SortOrder#</cfoutput>]<cfif local.External_Customer_Profile_Access eq 1>,hide:true</cfif>},
						</cfif>
						<cfif stProgramSettings.userprogram.display_volume>
						{headerName: displayVolumeLabel, field: "VOLUME", width: 90, valueFormatter: NumberCellRenderer, type: "numericColumn", sortingOrder: [<cfoutput>#variables.SortOrder#</cfoutput>]},
						</cfif>
            {headerName:"Operator", field: "OPERATORNAME", hide: true, suppressColumnsToolPanel: true, suppressFiltersToolPanel: true, suppressToolPanel: true },
						{headerName:"Operator ID", field: "OPERATORID", hide: true, suppressColumnsToolPanel: true, suppressFiltersToolPanel: true, suppressToolPanel: true},
						{headerName: "More Info", field: "MOREINFO", width: 187, sortable:false,bsaSupressExcel:1,
									 onCellClicked: function(params) {
														let contract_main_id = params.data.CONTRACT_MAIN_ID;
														let contract_number = params.data.CONTRACT_NUMBER;
														let manual_cancel	= params.data.MANUAL_CANCEL;
														let cancelled_by = params.data.CANCELLED_BY;
														let cancelled_date = params.data.CANCELLED_DATE;
														let planner_id = params.data.PLANNER_ID;
														switch (params.event.target.className) {
															case "preview":	/* If "catalog" is selected from the "datasource" dropdown and the user has "Read_Only_Catalog_Access" profile ON */
																if(params.data.ISCATALOG == 1) {
																	if (params.data.PLANNER_ID == 0 ||  (params.data.PLANNER_ID != 0 && params.data.RETAIL_PLANNER_PROGRAM_SPECIFIC_APPROVAL == 1)) {
																		popup2022( "/CID_Wrapper.cfm?Program_ID=" + contract_main_id
																					+ "<cfoutput>#local.URLCPAccessArgN#</cfoutput>&CatalogView=1&Page_Relocate=/scorecard/program_display.cfm"
																					, "winPreview", "MD", "XL");
																	}
																	else
																	{
																		/* passing url.numb to disallow changing mode */
																		popupCenter2022( "/planners/create/planner_program_create.cfm?programId=" + contract_main_id
																						+ "&plannerID=" + planner_id
																						+ "&bLock=1"
																						+ "&bInit=1"
																						+ "&numb=1"
																						, "winDetails", "XL", "LG" );
																	}
																}
																else
																{
																	if (params.data.PLANNER_ID == 0 ||  (params.data.PLANNER_ID != 0 && params.data.RETAIL_PLANNER_PROGRAM_SPECIFIC_APPROVAL == 1)) {
																		popup2022( "/CID_Wrapper.cfm?Program_ID=" + contract_main_id
																						+ "&Page_Relocate=/scorecard/program_display.cfm"
																						, "winPreview", "MD", "XL" );
																	}
																	else
																	{
																		/* passing url.numb to disallow changing mode */
																		popupCenter2022( "/planners/create/planner_program_create.cfm?programId=" + contract_main_id
																						+ "&plannerID=" + planner_id
																						+ "&bLock=1"
																						+ "&bInit=1"
																						+ "&numb=1"
																						, "winDetails", "XL", "LG" );
																	}
																};
																break;
															case "details":
																popupCenter2022( "/Common_Files/contracts/contract_details.cfm?fromPrg=1&contractId=" + contract_main_id
																				+ "<cfoutput>#local.URLCPAccessArgN#</cfoutput>"
																				, "winDetails", "SM", "LG" );
																break;
															case "quick_pay":
																popup2022( "/CID_Wrapper.cfm?Program_ID=" + contract_main_id
																			+ "&Page_Relocate=/scorecard/quick_pay_main.cfm"
																			, "winQuickPay" );
																break;
															case "payment":
																<cfif local.External_Customer_Profile_Access eq 0>
																	popup2022( "/common_files/contracts/payment_history/payment_history.cfm?ContractId=" + contract_main_id
																				,"winPaymentHistory", "LG", "LG" );
																<cfelse>
																	popup2022( "/common_files/contracts/payment_history/view_billback_payment_history.cfm?selectedMonths=ALL<cfoutput>#local.URLCPAccessArgN#</cfoutput>&ContractNumber="+contract_number+"&ContractId=" + contract_main_id
																				,"winPaymentHistory", "LG", "LG" );
																</cfif>
																break;
														}
													},
									 cellRenderer: function(params)
									 {
										/* Preview link */
										let more_info_links ='<a href="#" title="Click here for program preview" class="preview">[preview]</a>';
										let canceltitle = 'Cancelled by: ' + params.data.CANCELLED_BY  +  ' on ' + params.data.CANCELLED_DATE;

										if(params.data.ISCATALOG == 0) {

											<cfif local.External_Customer_Profile_Access eq 0>

											/* Detail link */
											more_info_links = more_info_links + '<a href="#" title="Click here for program details" class="details">[details]</a>';

											/* Quick Pay link */
											<cfif (application.util.query.get_setting('Quick_Pay_in_Program_Search') eq "1"
											or (application.util.query.get_setting('Quick_Pay_in_Program_Search') eq "2" and Get_Profile_Settings.AQP_Available eq 1))>

											if (params.data.CLAIMMECH	&& params.data.MANUAL_CANCEL == 0	&& params.data.RELEASED == 0 && params.data.DUMMY_PROGRAM == 0
												&&
												(
													(<cfoutput>#application.util.query.get_setting('Quick_Pay_in_Program_Search')#</cfoutput> == '2' && params.data.PAYS_TO_DISTRIBUTOR ==1)
													||<cfoutput># application.util.query.get_setting('Quick_Pay_in_Program_Search')#</cfoutput> != '2'
													)
													){

												more_info_links = more_info_links + '<a href="#" title="Click here for quick pay details" class="quick_pay">[quick pay]</a>';
											}
											</cfif>
											</cfif>

											/* Payment History link */
											if (params.data.PAYHIST) {
												more_info_links = more_info_links + '<a href="#" title="Click here for program payment history" class="payment">[$]</a>';
											}

										}// Not catalog

										/* Cancel info icon */
										if (params.data.MANUAL_CANCEL == 1) {
											more_info_links = more_info_links + '<img src="/images/no_small.gif" title="' + canceltitle + '" />';
										}
										return more_info_links;
									 }
						}
						]
			/* Keep a high number for cacheBlockSize (currently 20000), so that scrolling is not slow. */
			,cacheBlockSize: <cfoutput>#max(20000, val(application.util.query.get_setting("Program_Search_CacheBlockSize", 0)))#</cfoutput>
			,debug: false
			,rowModelType: "serverSide"
			,rowSelection: "multiple"
			,rowDeselection: true
			,getRowNodeId: function(data) { return data.CONTRACT_MAIN_ID; }
		};
		ag_grid_default(gridOptions);		// set up default features

	<cfif local.External_Customer_Profile_Access eq 0>
		gridOptions.sideBar = { toolPanels: [
												{
													id: 'columns',
													labelDefault: 'Columns',
													labelKey: 'columns',
													iconKey: 'columns',
													toolPanel: 'agColumnsToolPanel',
													toolPanelParams: {
														suppressColumnExpandAll: true,
														suppressColumnFilter: true,
														suppressColumnSelectAll: true,
														suppressPivotMode: true,
														suppressPivots: true,
														suppressRowGroups: true,
														suppressValues: true,
													}
												}
											]
								};
		</cfif>

		AjaxDatasource.prototype.getRows = function(params) {
								$(".button").prop("disabled",true);	//Prevent DoubleClick
								if(initial_load == 1){
										/* Call the query to get the stored grid properties - column index (order), hide/show(visible status) and width. */
										$.ajax({type    : "post"
												,url     : "/mvc/Models/Program/Search_Program.cfc?<cfoutput>#local.URLCPAccessArg1#</cfoutput>&t=" + $.now()
												,dataType: "json"
												,data: { method: "callSearchGridColumnSizeInfo"
														,userID:  <cfoutput>'#request.AccessStructure.user_id#'</cfoutput>
														}
												,success : function (response) {
															let fieldID;
															let lastColumnIndex = response.length + 1;
															for(let i=0;i<response.length;i++){
																	if(response[i].COLWIDTH != 0){
																		/* set column width */
																		gridOptions.columnApi.setColumnWidth(response[i].COLNAME, response[i].COLWIDTH);
																	}
																	/* set column order */
																	gridOptions.columnApi.moveColumn(response[i].COLNAME, response[i].COLORDER);
																	/* set column visible status */
                                  gridOptions.columnApi.setColumnVisible(response[i].COLNAME, response[i].COLVIEWABLE == 1);

																	/* If "MORE_INFO", is not the last column, unpin the "MORE_INFO" column */
																	if(response[i].COLORDER==lastColumnIndex){
																		if(response[i].COLNAME != 'MOREINFO'){
																			gridOptions.columnApi.setColumnPinned('MOREINFO', false)
																		}
																	}
															}
												}
										});
									/* If the user visits from the program status scorecard on the home page, then set the "Status" dropdown to the
									status which the user clicked on. By doing this, the program data will be filtered by this selected status.
									Some users may also see the "Catalog" option from the scorecard. This is not a status.
									Note: This code has been added for the initial load only (initial_load == 1).
									*/
									var arrDataSource = ['0']; // "Programs" option from the "Datasource" dropdown. This is the default.
									<cfif url.scorecard_status neq 0>
										<!--- For "catalog" --->
										<cfif url.scorecard_status eq 9>
										arrDataSource = ['1']; // "Catalog" option from the "Datasource" dropdown.
										<cfelse>
										<!--- For "Status" dropdown, when the user visits from the program scorecard. --->
										<cfoutput>
										var arrStatus = ['#url.scorecard_status#'];
										</cfoutput>
										<!--- set the "status" dropdown to have a selected value --->
										$("select[name=status_list]").multipleSelect('setSelects',arrStatus);
										</cfif>
									<cfelse>
										<cfif appSettings.get_Setting('Retail_Planner') EQ '1' AND get_profile_settings.Planner_Create EQ 0>
											arrDataSource = ['0'];
										<cfelseif appSettings.get_Setting('Retail_Planner') EQ '1' AND get_profile_settings.Planner_Create NEQ 0>
											arrDataSource = ['2'];
										</cfif>
									</cfif>

									<!--- set the "datasource" dropdown to have a selected value --->
										$("select[name=show_catalog]").multipleSelect('setSelects',arrDataSource);
								}
								initial_load = 0;

                    // clear out existing rows count, last refresh date-time info
                    $("#grid_count").text('');
                    if ($("#refreshData").val()) {
                        $("span.last_refresh").text('');
                    }

					/* clear out all selected rows because they may not be in the new search result and Ag-grid does not clear them automatically. */
					//don't clear out rows if the action is mass approve. Users want to use programs that they have filtered using program list.
					let searchType      = $("select[name=action_list]").multipleSelect('getSelects').toString();
					if(searchType != 3){
						gridOptions.api.deselectAll();
					}

					$.ajax({	 type    : "post"
						,url     : "ajax/program_data.cfm?<cfoutput>#local.URLCPAccessArg1#</cfoutput>"
						,dataType: "json"
						,data    : {
									startRow: params.request.startRow
									,endRow: params.request.endRow
									,sortColumn: params.request.sortModel.length ? params.request.sortModel[0].colId : ""
									,sortOrder: params.request.sortModel.length ? params.request.sortModel[0].sort : ""
									,buying_group_list: $("select[name=buying_group_list]").multipleSelect('getSelects').toString()
									,distributor_search: $( "#distributor_search" ).val()
									,family_list: $("select[name=family_list]").multipleSelect('getSelects').toString()
									,item_search: $( "#item_search" ).val()
									,match_type: $("input[name='match_type']:checked").val()
									,operator_search: $( "#operator_search" ).val()
									,profiles_Id: <cfoutput>'#request.AccessStructure.profiles_id#'</cfoutput>
									,program_create_list:  $.trim($( "#program_create_list" ).val())
									,program_search: $( "#program_search" ).val()
									,rsp_list: $("select[name=rsp_list]").multipleSelect('getSelects').toString()
									,status_list: $("select[name=status_list]").multipleSelect('getSelects').toString()
									,template_list: $("select[name=template_list]").multipleSelect('getSelects').toString()
								<cfif local.External_Customer_Profile_Access eq 0>
									,from_date: $( "#from_date" ).val()
									,to_date: $( "#to_date" ).val()
									,action_list: $("select[name=action_list]").multipleSelect('getSelects').toString()
									,budget_class_list: <cfif stProgramSettings.showbudgetDropdown>$("select[name=budget_class_list]").multipleSelect('getSelects').toString()<cfelse>''</cfif>
									,business_segment: <cfif stProgramSettings.businesssegmenton> $("select[name=business_segment]").multipleSelect('getSelects').toString()<cfelse>''</cfif>
									,condition_list: $("select[name=condition_list]").multipleSelect('getSelects').toString()
									,user_ID: <cfoutput>'#request.AccessStructure.user_id#'</cfoutput>
									,user_list: $("select[name=user_list]").multipleSelect('getSelects').toString()
									,user_position_list: $("select[name=user_position_list]").multipleSelect('getSelects').toString()
									,workflow_steps_list: $("select[name=workflow_steps_list]").multipleSelect('getSelects').toString()
									,show_catalog: <cfif get_profile_settings.read_only_catalog_access OR appSettings.get_Setting('Retail_Planner') EQ '1'>$("select[name=show_catalog]").multipleSelect('getSelects').toString()<cfelse>0</cfif>
									,Include_work_in_progress_below_me: <cfoutput>#url.Include_work_in_progress_below_me#</cfoutput>
									,Creating_User_Position: <cfoutput>#url.Creating_User_Position#</cfoutput>
								</cfif>
									,search_type: $( "#searchType" ).val()
									,refresh_data: $( "#refreshData" ).val()
									,discount_type: $("select[name=discount_type]").multipleSelect('getSelects').toString()
									,fixed_discount_types: $("select[name=fixed_discount_types]").multipleSelect('getSelects').toString()
									,rebate_discount_types: $("select[name=rebate_discount_types]").multipleSelect('getSelects').toString()
									,lump_sum_discount_types: $("select[name=lump_sum_discount_types]").multipleSelect('getSelects').toString()
									,growth_discount_types: $("select[name=growth_discount_types]").multipleSelect('getSelects').toString()
									,rate_compare: $("select[name=rate_compare]").val()
									,rate_val: $( "#rate_val" ).val()
									,rate_uom: $("select[name=rate_uom]").multipleSelect('getSelects').toString()
									}

						,success : function (response) {
								var arr_columns = [];
								/* We need the list of columns in javascript, but the columns are defined in CF (program_columns_arr).
								To get the list of columns in javascrpt, we need to loop through the data in CF and create an array
								in javascript. THis way we can get the same column list in javascript. No need to hardcdde the
								array in javascript.
								*/
								<cfoutput>
								<cfloop from="1" to="#ArrayLen(program_columns_arr)#" index="i">
									arr_columns.push('#program_columns_arr[i]#');
								</cfloop>
								</cfoutput>
								<!--- "response" does not have column names defined, but it has the array indexes defined.
								"convertToArrayOfObjects" function will assign column names, so that AG grid can load the
								data in appropriate columns. --->
								var data_to_load = convertToArrayOfObjects(response,arr_columns);
								if (response.length == 0) {
									$("span.ag-loading-icon").hide();
									$("span.ag-loading-text").text("No programs found.")
									/* update screen display with record count */
									$("#grid_count").text(0);
								}
								else if(response.length != 0 && data_to_load[0].ROWS_CNT == ''){
									if($.trim($( "#program_create_list" ).val()) != ''){
										if(data_to_load[0].LIST_BAD_ROWS != ''){
											showInValidCreateList(data_to_load[0].LIST_BAD_ROWS);
										}
									}
									$("span.ag-loading-icon").hide();
									$("span.ag-loading-text").text("No programs found.")
									/* update screen display with record count */
									$("#grid_count").text(0);
								}
								else{
									//timer.stop();
									/* If the user searches using "create list" (start) */
									if($.trim($( "#program_create_list" ).val()) != ''){
										if(data_to_load[0].LIST_BAD_ROWS != ''){
											showInValidCreateList(data_to_load[0].LIST_BAD_ROWS);
										}
									}
									/* If the user searches using "create list" (end) */
									params.successCallback(data_to_load, data_to_load[0].ROWS_CNT);
									/* update screen display with record count */
									$("#grid_count").text(data_to_load[0].ROWS_CNT.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","));

									if (focus_on_search) {

										if ( !is_ie() )
											$("input[name=program_search]").focus();
									}
									focus_on_search = 0;
									jQuery( "[title]" ).tooltip().click(function(){ jQuery('[class^="ui-tooltip"]').remove(); });
								}
								$(".button").prop("disabled",false);  //Enable Buttons after results Load

                                // refresh data was clicked, gather the refresh datetime info
                                if ($("#refreshData").val()) {
                                    $.ajax({
                                        url: "/mvc/Models/Program/ProgramManager.cfc",
                                        data: { method: "last_refresh_datetime" },
                                        success: function (result) {
                                            $("span.last_refresh").text( result.replace(/"/g, '') );
                                        }
                                    });
                                }
						}
						,error: function(xhr, status, err) {
								$(".button").prop("disabled",false);	//Enable Buttons onError
								/* If the user searches using "create list" */
								if($.trim($( "#program_create_list" ).val()) != ''){
									$("span.ag-loading-icon").hide();
									$("span.ag-loading-text").text("No programs found.")
								}
						}
					});
					$( '#refreshData' ).val(0);
				};

		init_ag_grid( gridOptions, "#myGrid", true );

		$(window).resize(function(){
			// gridOptions.api.sizeColumnsToFit();
		});

		const select_all_text   = "select all";
		const unselect_all_text = "unselect all";
		$("#select_all").click(function (e) {
			e.stopPropagation();
			let action = $(this).text();
			gridOptions.api.forEachNode(function(node){
				node.setSelected( true );
			});
		});
		$("#unselect_all").click(function () {
			gridOptions.api.forEachNode(function(node){
				node.setSelected( false );
			});
		});

		const usdFormat = new Intl.NumberFormat('en-US', {
															style: 'currency',
															currency: 'USD',
															minimumFractionDigits: 2
														});
		function CurrencyCellRenderer(params) {
			return usdFormat.format(params.value);
		}

		function NumberCellRenderer(params) {
			return new Intl.NumberFormat().format(params.value);
		}

		function DateCellRenderer(params) {
			var date = new Date(params.value);

			var year = date.getFullYear();
			var month = date.getMonth()+1;
			var day = date.getDate();

			if (day < 10) {
			  day = '0' + day;
			}
			if (month < 10) {
			  month = '0' + month;
			}

			return month + '/' + day + '/' + year;
		}

		<cfif local.External_Customer_Profile_Access eq 0>
		const show_column_tool = "show column tool";
		$("#column_tool").text( show_column_tool );
		</cfif>
		$("#column_tool").click(function(){
			if ( gridOptions.api.isToolPanelShowing() ) {
				gridOptions.api.closeToolPanel();
				$(this).text( show_column_tool );
			}
			else {
				gridOptions.api.openToolPanel("columns");
				$(this).text( "hide column tool" );
			}
		});

		/* Show/Hide the left Options panel */
		function hideOptions() {
			// Animate via changing margin to negative #
			let border_width = 3,
				filtersWidth = $("#filters").width() + border_width;
			$("#filters").css("margin-left", "-"+filtersWidth+"px");

			// Show the link for un-hiding the Options panel
			$("#options").css("display", "block");
			$("#options").css("cursor", "pointer");
		};
		function showOptions() {
			let border_width = 3;
			$("#filters").css("margin-left", border_width+"px");

			// Hide the "Options" link when the Options panel is open
			$("#options").css("display", "none");
			$("#options").css("cursor", "default");
		};

		activate_multipleSelect();

        /* Save the column properties - column index (order), hide/show(visible status) and width. */
		function save_program_search_columns(){
			/* "getAllGridColumns" returns even the hidden column. "getColumnState" and "getAllColumns" do not. */
			let arrAllGridColumns = gridOptions.columnApi.getAllGridColumns();
			let objSearchGridColumnSize = new Object();

            for (var i=0; i<arrAllGridColumns.length; i++){
				/* Ignore the first two columns - checkbox column and "BIDREQUESTSTATUS" column */
				if(arrAllGridColumns[i].colId !=  '0' && arrAllGridColumns[i].colId != 'BIDREQUESTSTATUS'){
					/* Store the grid column properties in the object */
					objSearchGridColumnSize[arrAllGridColumns[i].colId] =  i+ ':' + Number(arrAllGridColumns[i].visible)  + ':' + arrAllGridColumns[i].actualWidth;
				}
			}

            // modern Chrome/MS Edge no longer allow XHR in onunload a page - use sendBeacon() instead
            if("sendBeacon" in navigator) {
                let user_info = new FormData();
            	user_info.append("userId", <cfoutput>'#request.AccessStructure.user_id#'</cfoutput>);
            	user_info.append("columns", JSON.stringify(objSearchGridColumnSize));

                navigator.sendBeacon("/mvc/Models/Program/Search_Program.cfc?method=saveSearchGridColumnInfo", user_info);
            }
            else {
                $.ajax({type    : "post"
                        ,url     : "/mvc/Models/Program/Search_Program.cfc"
                        ,async: !is_ie()
                        ,dataType: "json"
                        ,data: { method: "saveSearchGridColumnInfo"
                                ,userID:  <cfoutput>'#request.AccessStructure.user_id#'</cfoutput>
                                ,columns: JSON.stringify(objSearchGridColumnSize)
                                }
                });
            }
		}

		// If any filters are used, make into a string and display to user
		function showSelectedOptions() {
			let defaultOptionsToolTip = 'search results can be filtered';
			let introToolTip = "Filters selected:\n";
			let allOptions = [];

			allOptions[0] = $("select[name=status_list]").multipleSelect('getSelects', 'text');
			allOptions[1] = $("select[name=template_list]").multipleSelect('getSelects', 'text');
			allOptions[2] = $("select[name=rsp_list]").multipleSelect('getSelects', 'text');
			allOptions[3] = $("select[name=buying_group_list]").multipleSelect('getSelects', 'text');
			allOptions[4] = $("select[name=family_list]").multipleSelect('getSelects', 'text');
			allOptions[5] = $("select[name=condition_list]").multipleSelect('getSelects', 'text');
			allOptions[6] = $("select[name=workflow_steps_list]").multipleSelect('getSelects', 'text');
			allOptions[7] = $("select[name=user_list]").multipleSelect('getSelects', 'text')
			allOptions[8] = $("select[name=user_position_list]").multipleSelect('getSelects', 'text');
			allOptions[9] = $("select[name=action_list]").multipleSelect('getSelects', 'text');
			allOptions[10] = <cfif stProgramSettings.showbudgetDropdown>$("select[name=budget_class_list]").multipleSelect('getSelects', 'text')<cfelse>''</cfif>;
			allOptions[11] = <cfif stProgramSettings.businesssegmenton> $("select[name=business_segment]").multipleSelect('getSelects', 'text')<cfelse>''</cfif>;
			allOptions[12] = <cfif get_profile_settings.read_only_catalog_access OR appSettings.get_Setting('Retail_Planner') EQ '1'>$("select[name=show_catalog]").multipleSelect('getSelects', 'text').toString()<cfelse>''</cfif>;
			allOptions[13] = $("select[name=discount_type]").multipleSelect('getSelects', 'text');
			allOptions[14] = $("select[name=fixed_discount_types]").multipleSelect('getSelects', 'text');
			allOptions[15] = $("select[name=rebate_discount_types]").multipleSelect('getSelects', 'text');
			allOptions[16] = $("select[name=lump_sum_discount_types]").multipleSelect('getSelects', 'text');
			allOptions[17] = $("select[name=growth_discount_types]").multipleSelect('getSelects', 'text');
			allOptions[18] = $("select[name=rate_uom]").multipleSelect('getSelects', 'text');

			// remove empty strings and then join the rest with newlines
			let sparse = allOptions.filter(function (s) { return s.length ? s : false }).join("\n");
			if (sparse.length) {
				sparse = introToolTip + sparse;
			}

			return (sparse.length ? sparse : defaultOptionsToolTip);
		}

		$("#create_program").click(function(){
			NewWindowTopLeft("/common_files/select_new_program_type.cfm", "winSummary","1345","710","yes","yes");
		});

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~~~ Download Data ~~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
		$("#download_data").click(function(e){

            e.preventDefault();

            let d           = new Date();
            let date_string = (d.getMonth()+1) + '-' + d.getDate() + '-' + d.getFullYear();
            let file_title  = <cfoutput>"Program Search"</cfoutput>;

            let columns     = columnsForExport(gridOptions);        // gather visible columns
           // columns.push("OPERATOR_NAME", "OPERATOR_LEGACY_ID");    // append invisible operator columns

            let config      = { allColumns: true
                                , fileName  : file_title + " As Of " + date_string
                                , sheetName : file_title
                            };

            config.processCellCallback = function( params ) {
                if ( params.column.colDef.field === "STARTDATE" || params.column.colDef.field === "ENDDATE" ) {
                    let date  = new Date(params.value);

                    /* validate date column & return the short format m/d/yyyy */
                    if ( date instanceof Date && !isNaN(date) ) {
                        let year  = date.getFullYear();
                        let month = date.getMonth() + 1;
                        let day   = date.getDate();

                        return month + '/' + day + '/' + year;
                    }
                }

                return params.value;
            }

            gridOptions.api.exportDataAsExcel( config );
            return false;
		});

		// Show selected criteria when hovering over the "i" icon
		$(document).ready(function(){
			// $("#selectedOptions").hover(function(){ $(this).attr('title', showSelectedOptions()); });
            <cfif local.External_Customer_Profile_Access eq 0>
			    // jquery tooltip is used...
			    $("#selectedOptions").hover(function(){
				    $( "#selectedOptions" ).tooltip( "option", "content", showSelectedOptions() );
			    });
            </cfif>
		});
        $(window).resize(function(){ set_grid_full_height("myGrid") });
        $(window).unload(function(){ save_program_search_columns() });

	</script>

	<cfinclude template="/common_files/popup2022.cfm">

	<cfinclude template="/Common_Files/focus.cfm">
</body>
</html>