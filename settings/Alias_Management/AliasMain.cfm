<!---
  * ====================================================================================================
  *  @Author: Sharon Harris
  *  @Date: 2018-10-29
  *  New Alias Management, replacing Flex version AliasMainFx.cfm

  *
  *
  *
  *
  * ====================================================================================================
--->
<!doctype html>
<html lang="en">
<head>
	<title>Alias Management @ Blacksmith Applications</title>
	<cfsavecontent variable="head_content">
	<style>
		html, body {
			margin: 0;
			padding: 0;
			width: 99.5%
		}

		.Title6           { margin-left: 15px; }
		select#sourceType { margin-left: 5px;
			margin-top: 2px;
			padding: 2px;
			border-radius: 3px;
		}


		.sectionHeader {
			background-color: #edeef2;
			border:1px solid #d8d9dd;
			color: #343540;
			cursor: pointer;
			line-height: 24px;
			text-align: left;
			transition: 0.4s;
			width: 100%;
		}
		.sectionHeader:hover {
			background-color: #FFF;
			border: 1px solid #406be4;
		}
		.sectionHeader:focus {  /* remove distracting focus border */
			outline:0;
		}
		.section {
			background-color: #fff;
			display: none;
			padding: 5px;
		}
		.buttonBar {
			float: right;
			margin-right: 5px;
			margin-top: 5px;
			padding-left: 20px;
		}
		.aliasSet {
			background-color: #edeef2;
			border: 1px solid #c4c5c7;
			border-radius: 8px;
			margin-top: 3px;
		}
		.filterSet {
			background-color: #edeef2;
			border: 1px solid #c4c5c7;
			border-radius: 2px;
			padding-bottom: 3px;
			padding-top: 3px;
		}
		legend {
			font-size: 11px;
			font-weight: bold;
		}
		.gridFilters {
			/* float: right; */
			margin-right: 5px;
			margin-top: 5px;
			margin-left: 5px;
		}

		.inline-field span,
		.inline-field fieldset,
		.inline-field input,
		.inline-field label {
			display: inline-block;
			/* margin-bottom: 0; */
			vertical-align: middle;
		}


		/* Styles for Edit Alias section */
		.flex-container {
			display: flex;
		}
		.flex-column {
			align-items: flex-start;
			display:table;
			border-spacing: 3px;
			line-height: 10px;
			margin-left: 10px;
			margin-right: 10px;
		}

		.detail-row {
			display: table-row;
			width: 100%;
		}
			.detail-row.hidden,
			.detail-row > span.hidden,
			.detail-row > label.hidden,
			.detail-row > input.hidden {display:none;}

			.detail-row > span.empty {opacity:0;}

			.detail-row > span,
			.detail-row > label {
				font-size: 11px;
				font-style: normal;
				display: table-cell;
			}
			.detail-row > input {
				border: solid 1px #c4c5c7;
				border-radius: 3px;
				/* display: table-cell; */ /* breaks in IE */
				height: 16px;
				padding: 1px 3px;
			}
		.cell {display: table-cell;}
		.btn-img {
			vertical-align: bottom;
		}
		.btn-icon {
			color: #406be4;
		}
		a:visited, a:link, a:hover  {
			text-decoration: none;
		}
		input[type="radio" i] {
		<!---     margin-top: 0px;--->
			margin-bottom: 2px;
		}


	</style>
	</cfsavecontent>
	<cfset local.arrowDown = "/images/arrow-d-blue-12.png" />
	<cfset local.arrowRight = "/images/arrow-r-blue-12.png" />
	<cfhtmlhead text="#application.util.string.compress( head_content )#">
</head>

<body>
	<cfset jQueryUI.widgets = "tooltip">
	<cfset request.ag_grid_theme = "ba-ag-theme-balham">

	<cf_include files=#arrayToList( [ "  /common_files/jQuery.cfm",
										"/common_Files/ag-Grid.cfm",
										"/common_files/tabnavFlex.cfm",
										"/styles/font-awesome.min.css",
										"/settings/Alias_Management/dropbtn.cfm",
										"/settings/Alias_Management/AliasGridManager.cfm"
										] )#>
	<style>
		<!--- override the ag-grid styles included above --->
		.ag-theme-balham {
			font-size: 11px;
		}
		.ag-header {
			font-size: 11px !important;
		}
		.ag-theme-balham .ag-cell {
			/* padding-left: 4px; */
			padding-right: 2px;
		}
		.ag-theme-balham .ag-header-cell-label {
			width: 100%;	/* work around ag-grid bug #2328 which leaves space for menu icon */
		}
		.ag-theme-balham .ag-header-cell {
			padding-left: 6px;  /* get checkbox to line up */
		}
		.ag-theme-balham .ag-row-selected {
			border-bottom-color: #b5b5b5; /* don't hide lines when selected */
		}
		.ag-theme-balham .ag-selection-checkbox span {
			left: 2px; /* center the checkbox */
		}
	</style>

	<!---  Get to the Source Types list --->
	<cfset variables.oAliasDAO = createObject('component','mvc.Models.Admin.Alias.AliasManagerDAO') />
	<cfset qgetAliasSourceTypes = variables.oAliasDAO.getSourceTypeLookup()>


	<!-------------------->
	<!--- Page Display --->
	<!-------------------->
	<div class="page_title1"> ALIAS MANAGEMENT </div>

	<!-------------------------------------------------------------------------------------->
	<!-------------------------- CHOOSE SOURCE SECTION ------------------------------------->
	<!-------------------------------------------------------------------------------------->
	<div id="loadSection">
		<button id="loadDataBtn" class="sectionHeader">
			<img src=<cfoutput>#local.arrowRight#</cfoutput> alt="expand/collapse"> Load Alias Data
		</button>
		<div id="loadData" class="section">
			<div class="flex-container">

				<!--- First column --->
				<div class="flex-column">
					<div class="detail-row">
						<label class="cell Title6"> Choose a Source type:</label>
						<select id="sourceType" onchange="sourceTypeChange()" >
							<option value="0" id="0">*************PLEASE SELECT*************</option>
							<cfoutput query="qgetAliasSourceTypes">
								<option value="#Source_Type#" source_code="#Source_Code#">#Source_Code_Display#</option>
							</cfoutput>
						</select>
					</div>
				</div> <!--- end col 1 --->

				<!--- Second column --->
				<div class="flex-column">
					<form name="frmPayeeSearch">
						<div class="detail-row hidden" id="payeeDisplay">
								<label class="cell Title6" id="payeeLabel"> Payee:</label>
								<!---  NOTE: The popup which populates this textbox requires the name of the textbox to be "Vendor_ID" (case sensitive) --->
								<input type="text" name="Vendor_ID" id="Vendor_ID" size="25">
								<a href="#" onclick="showPayeeID();return false;" id="idPayeePopup">
									<i class="fa fa-search btn-icon"></i>
								</a>
						</div>
						<div class="detail-row hidden" id="vendorDisplay">
							<span class="empty cell"></span> <!--- empty left label --->
							<span class="cell" style="max-width: 160px;" id="vendorInfo"></span>
						</div>
					</form>
				</div>  <!--- end col 2 --->

				<!--- Third column --->
				<div class="flex-column">
					<div class="detail-row">
						<button type="button" onClick="searchAliases();" class="button recommended hidden" id="searchBtn" style="margin-left:0px;">Search</button>
					</div>
				</div>  <!--- end col 3 --->

			</div>
		</div>
		<br>
	</div>

	<div id="downloadSection" style="display:none">
		<cfoutput>
		<button type="button" id="btnDownloadDist" onClick="downloadAliases('0');" class="button">download all #application.returned_customer_setting.distributor_label_singular# data</button>
		<button type="button" id="btnDownloadItem" onClick="downloadAliases('1');" class="button">download all #application.returned_customer_setting.item_label# data</button>
		<button type="button" id="btnDownloadPrg"  onClick="downloadAliases('2');" class="button">download all Program data</button>
		<button type="button" id="btnDownloadOpr"  onClick="downloadAliases('3');" class="button">download all #application.returned_customer_setting.operator_label_singular# data</button>
		<button type="button" id="btnDownloadAll"  onClick="downloadAliases('All');" class="button">download all data</button>
		</cfoutput>
	</div>
    <!-------------------------------------------------------------------------------------->
    <!-------------------------- MANAGE ALIAS SECTION -------------------------------------->
    <!-------------------------------------------------------------------------------------->
	<div id="manageSection" class="hidden">
		<button id="manageBtn" class="sectionHeader">
			<img src=<cfoutput>#local.arrowRight#</cfoutput> alt="expand/collapse"> Aliases
		</button>
		<div id="manageData" class="section">
			<span class="buttonBar">
				<button type="button" id="btnDownloadFull" onClick="downloadAliases('Full');" class="button">download all data</button>
			</span>
			<div class="nav">
			<cfoutput>
			<ul class="nav" style="width:40%; flex-wrap:nowrap" id="tabArea">
				<li  class="topnav" onclick="setActiveTab(event, 'distributorContent')" id="defaultTab">#application.returned_customer_setting.distributor_label_singular#&nbsp; <span id="count0"></span></li>
				<li  class="topnav" onclick="setActiveTab(event, 'productContent')" id="productTab">#application.returned_customer_setting.item_label#&nbsp; <span id="count1"></span></li>
				<li  class="topnav" onclick="setActiveTab(event, 'programContent')" id="programTab">Program&nbsp; <span id="count2"></span></li>
				<li  class="topnav" onclick="setActiveTab(event, 'operatorContent')" id="operatorTab">#application.returned_customer_setting.operator_label_singular#&nbsp; <span id="count3"></span></li>
			</ul>
			</cfoutput>
			</div>


			<!--- NOTE: Instead of 4 completely different tab contents, this is setup as:
						- one shared but customized "edit details" subsection
						- one shared filter bar
						- one grid, customized per sourceType and per dataType(tab)
						- empty tabContents (since they are all the same)
			--->

			<!--- SUB-SECTION FOR ALIAS EDIT  --->
			<form id="editSubSectionForm" name="editSubSectionForm">
				<fieldset id="editSubSection" class="aliasSet">
					<legend>Edit Alias Details</legend>
					<!--- see FlexDev\Forge\src\com\Admin\Alias\views\AliasGrid.mxml --->
					<div class="flex-container">
						<!--- First column --->
						<div class="flex-column" id="col1">
							<div class="detail-row">
								<label for="alias_id">Alias ID</label>
								<input type="text" name="alias_id" id="alias_id" size="25">
							</div>
							<div class="detail-row" id="e_aliasDesc">
								<label for="alias_desc">Alias Desc</label>
								<input type="text" name="alias_desc" id="alias_desc" size="25">
							</div>
							<div class="detail-row inline-field">
								<label for="ignore_flag">Ignore</label>
								<input type="checkbox" name="ignore_flag" id="ignore_flag">
							</div>
							<div class="detail-row hidden" id="e_uniproNum">
								<label for="unipro_num">Unipro Num</label>
								<input type="text" name="unipro_num" id="unipro_num" size="25">
							</div>
						</div> <!--- end col 1 --->

						<!--- Second column --->
						<div class="flex-column" id="col2">
							<div class="detail-row">
								<label for="entity_id" style="text-align: right">ID</label>
								<input type="text" name="entity_id" id="entity_id" size="20">
								<input type="hidden" name="bsaId" id="bsaId" size="20">
								<a id="idPopup"  href="#" onclick="popupID();return false;">
									<i class="fa fa-search btn-icon"></i>
								</a>
							</div>
							<div class="detail-row">
								<span class="empty">.<br>. </span> <!--- empty left label --->
								<span class="label" style="max-width: 160px;" id="e_entityDesc"></span>
							</div>
							<div class="detail-row hidden" id="e_vendor">
								<label for="payee_id">Pymt Recipient ID</label>
								<input type="text" name="payee_id" id="payee_id" size="20">
							</div>
							<div class="detail-row hidden" id="e_loc">
								<label for="loc_id">Loc</label>
								<input type="text" name="loc_id" id="loc_id" size="20">
							</div>
						</div> <!--- end col 2 --->

						<!--- Third column --->
						<div class="flex-column" id="col3">
							<div class="detail-row">
								<button type="button" onClick="saveAlias();" class="button recommended">Save</button>
							</div>
							<div class="detail-row">
								<button type="button" onClick="clearEditSubSection();deSelectAllRows();" class="button alt">Reset</button>
							</div>
						</div>

						<!--- Fourth column --->
						<div class="flex-column" id="col4">
							<div class="detail-row hidden" id="e_uploadCSV">
								<button type="button" onClick="uploadCSV();" class="button alt">Upload CSV</button>
							</div>
						</div>
						<!--- Fifth column --->
						<div class="flex-column" id="col5">
							<div class="detail-row" id="e_download">
								<button type="button" id="btnDownload" onClick="downloadAliases();" class="button alt">
								download data
								</button>
							</div>
						</div>
					</div>
				</fieldset>
			</form>

			<!--- Menus above the grid --->
			<div style="display:flex; justify-content:space-between; align-items:center;">
				<!--- Menu --->
				<div class="dropdown">
					<button onclick="ShowHideDropbtn()" id="dropbtn" class="button" style="margin: 5px 5px 0px 5px">
						Apply to Selected&nbsp;<i class="fa fa-caret-down"></i>
					</button>
					<div id="myDropdown" class="dropdown-content">
						<a href="##" onclick="javascript:massApply('ignore');return false;">Ignore</a>
						<a href="##" onclick="javascript:massApply('unIgnore');return false;">un-Ignore</a>
						<a href="##" onclick="javascript:massApply('assignID');return false;">Assign ID</a>
						<a href="##" onclick="javascript:massApply('delete');return false;">Delete</a>
					</div>
				</div>

				<!--- FILTERS  --->
				<div class="inline-field" >
					<span class="gridFilters">Filters:</span>
					<fieldset class="gridFilters filterSet">
						<!--- "Hide assigned" filter goes here --->
						<input type="checkbox" name="assigned_filter" value="1" id="af" onClick="refreshGrid();">
						<label for="af">Show only unassigned</label>
					</fieldset>
					<fieldset class="gridFilters filterSet">
						<!--- "ignored" filters go here --->
						<input type="radio" name="ignore_filter" value="1" id="ig1" onClick="refreshGrid();">
						<label for="ig1">Show ignored</label>
						<input type="radio" name="ignore_filter" value="2" id="ig2" onClick="refreshGrid();">
						<label for="ig2">Show un-ignored</label>
						<input type="radio" name="ignore_filter" value="3" checked id="ig3" onClick="refreshGrid();">
						<label for="ig3">Show both</label>
					</fieldset>
				</div>
			</div>

			<!--- GRID, created based on sourceType and dataType --->
			<div id="myAliasGrid" style="margin: 5px 0 0 5px; width: 100%" class="ag-theme-balham"></div>

			<!--- empty because all the tab contents (above) are shared, not hidden --->
			<div id="distributorContent" class="tabContent"></div>
			<div id="productContent" class="tabContent"></div>
			<div id="programContent" class="tabContent"></div>
			<div id="operatorContent" class="tabContent"></div>
		</div>
		<cfoutput>
		<!--- form for Exporting (downloading) data --->
		<form name="frmAlias" id="frmAlias" method="post" action="/Common_Files/exportAll.cfm">
			<input type="hidden" name="type" value="getAliasData" />
			<input type="hidden" name="entity_type" id="entity_type" />
			<input type="hidden" name="source_type" id="source_type" />
			<input type="hidden" name="source_id" id="source_id" />
			<input type="hidden" name="filterModel" id="filterModel" />
			<input type="hidden" name="friendlyFileName" id="friendlyFileName" />
		</form>
		</cfoutput>
		</div>

		<!-------------------------------------------------------------------------------------->
		<!--------------------------------- SCRIPTS -------------------------------------------->
		<!-------------------------------------------------------------------------------------->
		<script>
		const UNIPRO_SOURCE_TYPE = 11;
		var arrowDown  = '<cfoutput>#local.arrowDown#</cfoutput>';
		var arrowRight = '<cfoutput>#local.arrowRight#</cfoutput>';
		var AliasSourceTypeSearched = -1;   // save most recent type searched
		var strSourceType = -1;             // save most recent type searched
		var strSourceID = "";               // save most recent type searched


		// handler for clicking section headers
		$( ".sectionHeader" ).on( "click", function() {
			var sectionClicker = $(this).attr("id");    // button id

			var imgUrl = $(this).children(0).attr('src');
			if ( imgUrl == arrowDown ) {
				$(this).children(0).attr("src", arrowRight);
			}else {
				$(this).children(0).attr("src", arrowDown);
			}
			$(this).next().toggle();        // show/hide div

			// Special case - if open/close first section, resize the grid (to take advantage of more room available)
			set_grid_full_height("myAliasGrid");
		});

		function setActiveTab(event, tabID) {
			showTab(event, tabID);

			// If a search has happened (vs original initialization of tab default), then customize the rest of the page too
			if (AliasSourceTypeSearched != -1) {
				customizeEditSubSection();

				// destroy current grid
				destroyGrid();

				// create new grid
				createGrid(getActiveTab(), AliasSourceTypeSearched);

				// once visible, can auto-size active tab grid
				sizeActiveGrid();
			}
		}

		function getActiveTab() {
			// Get all elements with class="topnav" and return the index # of the "active" one
			let topnavs = document.getElementsByClassName("topnav");
			for (i = 0; i < topnavs.length; i++) {
				if (topnavs[i].classList.contains("active")) {
					return i;
				}
			}
			return 0;
		}

		function downloadAliases(type){
			/* If the user is downloading selected source data for a single entity.
			e.g. - Sysco Distributors OR Sysco Items OR Sysco Programs OR Sysco Operators
			*/
			if(typeof type == "undefined"){
				$("#frmAlias input[name=entity_type]").val( getActiveTab() );
			}
			/* If the user is downloading the entire alias data for all the entities -
			distributor,item,program and operator.
			*/
			else if(type == "All"){
				$("#frmAlias input[name=entity_type]").val( '' );
			}
			/* If the user is downloading the selected source data for all the entities -
			e.g. Sysco distributor data AND Sysco item data AND Sysco program data AND Sysco operator data.
			*/
			else if(type == "Full"){
				$("#frmAlias input[name=entity_type]").val( '' );
			}
			/* If the user is downloading the entire alias data for a single entity.
			All distributor data OR All item data OR All program data OR All operator data.
			*/
			else{
				$("#frmAlias input[name=entity_type]").val( type );
			}

			$("#frmAlias input[name=source_type]").val( $('#sourceType').val() );
			$("#frmAlias input[name=source_id]").val( $('#sourceType').find("option:selected").attr("source_code") );

			if(typeof type == "undefined"){
				$("#frmAlias input[name=filterModel]").val( JSON.stringify(GridOptions.api.getFilterModel()) );
			}

			$("#frmAlias input[name=friendlyFileName]").val('Alias_List_');

			frmAlias.submit();
		}

		function uploadCSV(){
			let eType = getActiveTab();
			let sType =  $('#sourceType').val();
			let sID = $('#sourceType').find("option:selected").attr("source_code");

			NewWindow("uploadfile.cfm?entity_type="+eType+"&source_type="+sType+"&source_id="+sID, "upload","600","300","yes","yes");
		}

		<!--- Clear the Edit Alias "form" data --->
		function clearEditSubSection() {
			document.getElementById("editSubSectionForm").reset();
			$('#e_entityDesc').text('');
		}

		<!--- Show/Hide the conditionally-visible fields in the "Edit Alias Details" sub-section --->
		<!--- called when source type changes, when active tab changes (including on load) --->
		function customizeEditSubSection() {
			clearEditSubSection();
			let aliasSourceType = AliasSourceTypeSearched;
			let dataProviderType = getActiveTab();

			// Developers: setup any conditional field ids and their conditions in this array
			var editFields = [
				{id: "e_aliasDesc",
				visible:
					(aliasSourceType != UNIPRO_SOURCE_TYPE) ?
					"true" : "false"
				},
				{id: "e_uniproNum",
				visible:
					(aliasSourceType == UNIPRO_SOURCE_TYPE) ?
					"true" : "false"
				},
				{id: "e_vendor",
				visible:
					(dataProviderType == 0) && (aliasSourceType == '1') ?
					"true" : "false"
				},
				{id: "e_loc",
				visible:
					(aliasSourceType == UNIPRO_SOURCE_TYPE) ?
					"true" : "false"
				},
				{id: "e_uploadCSV",
				visible:
					(aliasSourceType == UNIPRO_SOURCE_TYPE) || (aliasSourceType == 14) ?
					"true" : "false"
				}
			];

			<!--- show/hide each customizable field --->
			editFields.forEach(function(element) {
				e_item = document.getElementById(element.id);
				if (element.visible == "false") {
					e_item.classList.add("hidden");
				}
				else { // show it
					if (e_item.classList.contains("hidden")) {
						e_item.classList.remove("hidden");
					}
				}
			});
		}

		<!--- Pop up the ID chooser, based on which data type tab --->
		<!--- TODO: convert fns from FlexDev\Forge\src\com\Admin\Alias\models\AliasManager.as --->
		function popupID() {
			switch (getActiveTab()) {
				case 0:
					showDistributorSearch();
					break;
				case 1:
					showItemSearch();
					break;
				case 2:
					showProgramSearch();
					break;
				case 3:
					showOperatorSearch();
					break;
			}
		}


        var gpo_one_page_program_creation = <cfoutput>#val(application.util.query.get_setting("GPO_One_Page_Program_Creation", 0))#</cfoutput>;

        // keep track of popup window
        var search_payee_window = null;
		function showPayeeID() {
            // new popup window is needed based on gpo setting and popup status
            if ( gpo_one_page_program_creation == 0 || search_payee_window == null || search_payee_window.closed ) {
			    search_payee_window = NewWindowTopLeft("/GL_Code/Vendor_Management/Vendor_Master_Search.cfm?Formname=frmPayeeSearch&ReloadForm=0&FieldName=Vendor_ID&PageSource=VendorSearch", "payeesearchwindow", 850, 600, "yes", "yes", 1);
            }
            else {
                search_payee_window.focus();
            }
		}

        // keep track of popup window
        var search_distributor_window = null;
		function showDistributorSearch() {
            // new popup window is needed based on gpo setting and popup status
            if ( gpo_one_page_program_creation == 0 || search_distributor_window == null || search_distributor_window.closed ) {
    			search_distributor_window = NewWindowTopLeft("/billbacks/search_Screens/PM_select_distributors.cfm?Formname=editSubSectionForm&ReloadForm=0&FieldName=Vendor_ID&PageSource=AliasDistributorSearch&OnlyDistributorsUnderMe=1", "distributorsearchwindow", 850, 600, "yes", "yes", 1);
            }
            else {
                search_distributor_window.focus();
            }
		}

        // keep track of popup window
        var search_item_window = null;
		function showItemSearch() {
            // new popup window is needed based on gpo setting and popup status
            if ( gpo_one_page_program_creation == 0 || search_item_window == null || search_item_window.closed ) {
    			search_item_window = NewWindowTopLeft("/common_files/contracts/product_Select_V1.cfm?Formname=editSubSectionForm&PageSource=AliasItemSearch&SelectSingleSearchResultOnly=1", "itemsearchwindow", 850, 600, "yes", "yes", 1);
            }
            else {
                search_item_window.focus();
            }
		}

        // keep track of popup window
        var search_program_window = null;
		function showProgramSearch() {
            // new popup window is needed based on gpo setting and popup status
            if ( gpo_one_page_program_creation == 0 || search_program_window == null || search_program_window.closed ) {
    			search_program_window = NewWindowTopLeft("/billbacks/search_screens/search_programs.cfm?Formname=editSubSectionForm&PageSource=AliasProgramSearch&fieldname=Program_List&SelectSingleSearchResultOnly=1&ProgramRestrictions=0", "programsearchwindow", 850, 600, "yes", "yes", 1);
            }
            else {
                search_program_window.focus();
            }
		}

        // keep track of popup window
        var search_operator_window = null;
		function showOperatorSearch(){
            // new popup window is needed based on gpo setting and popup status
            const window_name = "operatorsearchwindow";
    		const source_code = $('#sourceType').find("option:selected").attr("source_code");
            const url = "/billbacks/search_screens/pm_select_operators.cfm?Formname=editSubSectionForm&PageSource=AliasOperatorSearch&gpokey="
                            + source_code
                            + "&zip="
                            + selectedRecordZip;

            if ( gpo_one_page_program_creation == 0 || search_operator_window == null || search_operator_window.closed ) {
	    		search_operator_window = NewWindowTopLeft(url, window_name, 900, 600, "yes", "yes", 1);
            }
            else {
                search_operator_window.focus();
                search_operator_window = window.open(url, window_name);
            }
		}


		function searchAliases(){
			<!--- Given source type and optional Payee, initiate searches for aliases & open second section  --->

			// If Unipro, only show first tab
			if ($("#sourceType option:selected").val() == UNIPRO_SOURCE_TYPE) {
				document.getElementById("defaultTab").click();  // Unipro Needs to go to default tab, can make this conditional if not wanted for other source types.
				// hide the other 3
				hideOtherTabs();
			}
			else {
				// make sure the other 3 tabs are unhidden
				unHideOtherTabs();

			}
			AliasSourceTypeSearched = $("#sourceType option:selected").val();

			// Setup params for later Ajax calls (ex when switching tabs)
			strSourceType = $('#sourceType').val();
			strSourceID = $('#sourceType').find("option:selected").attr("source_code");
			/* If the Source Type is "Payee Alias", then use the "Vendor ID" the user enters on the "Payee" textbox */
			if(strSourceType == 2){
				/* If by imputting a vendor id in the textbox, no vendor descriptuon is returned, it is an invalid vendor. */
				if($('#vendorInfo').html().length == 0){
					alert('Please enter a valid payee');
					return;
				}
				strSourceID = $('#Vendor_ID').val();
			}

			// if first time, show section
			unHide ('manageSection');

			// if section header is not already open, click to open
			if ($('#manageBtn').next().css('display') == 'none'){
				$('#manageBtn').click();
			}

			clearEditSubSection();
			customizeEditSubSection();

			// Free up any existing grid before making new one
			destroyGrid();

			// Clear all 4 tab "counts" (they are outdated now with new search results)
			clearCounts();

			createGrid(getActiveTab(), AliasSourceTypeSearched);

			sizeActiveGrid();
		}

		function sourceTypeChange(){
			/* Note: The alias edit section shows up only after a source type is chosen */

			let src_type = $('#sourceType').val();

			document.all.downloadSection.style.display = 'none';

			if(src_type == 0){
				/* Clear out the grid area so that any prior data isn't left showing while waiting for user to Search */
				hide( 'manageSection');
				hide ('payeeDisplay');      // input prompt row
				hide ('vendorDisplay');     // name and address row
				// and clear them so when shown again, they are empty
				document.getElementById('Vendor_ID').value = "";        // input box
				document.getElementById("vendorInfo").innerHTML = "";   // name and address
				destroyGrid();
				clearCounts();
				showSearch (false);
			}
			/* If the user selects  "Payee Alias" from the "source" dropdown, show
			the payee (vendor) textbox, label, description and disabled search button */
			else if(src_type == 2){
				unHide ('payeeDisplay');    // input prompt row
				unHide ('vendorDisplay');   // name and address row
				hide( 'manageSection');
				enableSearch (false);       // disable (grey-out) search if Payee is empty
				showSearch (true);

				/* Clear out the grid area so that any prior data isn't left showing while waiting for user to Search */
				destroyGrid();
				clearCounts();
				AliasSourceTypeSearched = -1;

			}
			else if(src_type == 100){
				//$('#downloadSection').css('display') == '';
				document.all.downloadSection.style.display = '';
				hide( 'manageSection');
				destroyGrid();
			}
			else{
				/* if not "Payee Alias", then hide the extra stuff */
				hide ('payeeDisplay');      // input prompt row
				hide ('vendorDisplay');     // name and address row
				// and clear them so when shown again, they are empty
				document.getElementById('Vendor_ID').value = "";        // input box
				document.getElementById("vendorInfo").innerHTML = "";   // name and address

				/* For most source types, we can search immediately, no need to push a button */
				showSearch (false);
				searchAliases();

			}
		}

		function getDistributorInfo(distributor_id,is_guid, update_entity_id){
			$.ajax({type    : "post"
					,url: "/mvc/Models/Admin/Alias/AliasManager.cfc"
					,dataType: "json"
					,data: { method: "getDistributorInfoJSON"
							,distributorID: distributor_id
							,isGUID:is_guid
							}
					,success : function (response) {
						let distributor_info = '<span style="font-weight:bold">'+response["name"]+'</span>' +  '<br />' +' <span style="font-weight:bold">'+response["address"]+'</span>';
						if(response["name"] == ''){
							$('#e_entityDesc').html('');
						}
						else{
							$('#e_entityDesc').html(distributor_info);
						}

						if(update_entity_id == 1){
							$('#entity_id').val(response["shipTo"]);
						}
						$('#entity_id').trigger('change');
					}
			});
		}

		function getItemInfo(item_id,is_guid, update_entity_id){
			$.ajax({type    : "post"
					,url: "/mvc/Models/Admin/Alias/AliasManager.cfc"
					,dataType: "json"
					,data: { method: "getItemInfoJSON"
							,itemID: item_id
							,isGUID:is_guid
							}
					,success : function (response) {
						let item_info = '<span style="font-weight:bold">'+response["desc"]+'</span>';
						if(response["desc"] == ''){
							$('#e_entityDesc').html('');
						}
						else{
							$('#e_entityDesc').html(item_info);
						}

						if(update_entity_id == 1){
							$('#entity_id').val(response["ItemID"]);

						}
						$('#entity_id').trigger('change');
					}
			});
		}

		function getProgramInfo(program_id,is_contract_number,update_entity_id){
			$.ajax({type    : "post"
					,url: "/mvc/Models/Admin/Alias/AliasManager.cfc"
					,dataType: "json"
					,data: { method: "getProgramInfoJSON"
							,programID: program_id
							,isContractNumber:is_contract_number
							}
					,success : function (response) {
						let program_info = '<span style="font-weight:bold">'+response["desc"]+'</span>';
						$('#e_entityDesc').html(program_info);

						if(update_entity_id == 1){
							$('#entity_id').val(response["contractID"]);
						}
						$('#entity_id').trigger('change');
					}
			});
		}

		function getOperatorInfo(operator_id,is_legacy_id,update_entity_id){
			$.ajax({type    : "post"
					,url: "/mvc/Models/Admin/Alias/AliasManager.cfc"
					,dataType: "json"
					,data: { method: "getOperatorInfoJSON"
							,operatorID: operator_id
							,isLegacyID:is_legacy_id
							}
					,success : function (response) {
						let operator_info = '<span style="font-weight:bold">'+response["name"]+'</span>' +  '<br />' +' <span style="font-weight:bold">'+response["address"]+'</span>';
						if(response["name"] == ''){
							$('#e_entityDesc').html('');
						}
						else{
							$('#e_entityDesc').html(operator_info);
						}

						if(update_entity_id == 1){
							$('#entity_id').val(response["legacyID"]);
							$('#bsaId').val(response["BSA_Operator_ID"]);
						}
						$('#entity_id').trigger('change');
					}
			});
		}

		function getVendorInfo(vendor_id){
			$.ajax({type    : "post"
				,url: "/mvc/Models/Admin/Alias/AliasManager.cfc"
				,dataType: "json"
				,data: { method: "getVendorInfoJSON"
						,vendorID: vendor_id
						}
				,success : function (response) {
						let vendor_info = '';
						if(response["name"] != ''){
							vendor_info = '<span style="font-weight:bold">'+response["name"]+'</span>' +  '<br />' +' <span style="font-weight:bold">'+response["address"]+'</span>';
						}
						$('#vendorInfo').html(vendor_info);
							enableSearch(true);
						}
			});
		}

		function getPastedData(e){
			let clipboardData = e.clipboardData || e.originalEvent.clipboardData || window.clipboardData;
			let pastedData = clipboardData.getData('text');
		return pastedData;
		}

		$("#Vendor_ID").on("paste", function(e) {
			let pasted_data = getPastedData(e);
			getVendorInfo(pasted_data);
		});

		$("#Vendor_ID").on("change", function() {
			getVendorInfo($(this).val());
		});


		$("#alias_id,#alias_desc,#ignore_flag,#unipro_num,#entity_id,#payee_id,#e_entityDesc,#loc_id").on("change", function() {
			/* "keyup event on these elements triggers the change event from "getDistributorInfo","getItemInfo","getProgramInfo" and "getOperatorInfo" functions,
				which calls this function. It also gets called when only the "change" event is called. We do not need "updateEntityDescription" here because when
				we are using 'keyup" and "paste" events, we do not need the "change" event to be called as 'keyup" and "paste" events covers the "change" event.
				The only other way "change" event can be called is when when imports an id from a popuo. In that scenario, we are already call the
				"getDistributorInfo" or "getItemInfo" or "getProgramInfo" or "getOperatorInfo" functions, which updates the entity description.
			*/
			let element_id = $(this).attr('id');
			let input_value = $(this).val();

			updateAliasData(element_id,input_value);
		});

		$("#alias_id,#alias_desc,#ignore_flag,#unipro_num,#entity_id,#payee_id,#e_entityDesc,#loc_id").on("keyup", function() {
			let element_id = $(this).attr('id');
			let input_value = $(this).val();

				if(element_id == 'entity_id'){
					let entityType = getActiveTab();
					/* If entity id changes, change description too. It is also important in cases where the entity is not valid, and so
					we have to show no description.
					*/
					updateEntityDescription(entityType,input_value);
				}
			updateAliasData(element_id,input_value);
		});

		$("#alias_id,#alias_des,#unipro_num,#entity_id,#payee_id,#loc_id").on("paste", function(e) {
			let element_id = $(this).attr('id');
			let pasted_data = getPastedData(e);

				if(element_id == 'entity_id'){
					let entityType = getActiveTab();
					/* If entity id changes, change description too. It is also important in cases where the entity is not valid, and so
					we have to show no description.
					*/
					updateEntityDescription(entityType,pasted_data);
				}
			updateAliasData(element_id,pasted_data);
		});


		function updateEntityDescription(entity_id,input_data){
			if(entity_id == 0){
				getDistributorInfo(input_data,0,0)
			}
			else if(entity_id == 1){
				getItemInfo(input_data,0,0)
			}
			else if(entity_id == 2){
				getProgramInfo(input_data,1,0)
			}
			else if(entity_id == 3){
				getOperatorInfo(input_data,1,0)
			}
		}

		function saveAlias(){
			let entityType = getActiveTab();
			let singleRecord = 1;
			let AliasDef = {};
			let recordExists = 0;
			let err_message = '';
			let is_error = 0;
			let is_error_entity_ID = 0;

			selectedRows = GridOptions.api.getSelectedRows();
			let selectedRecordCount = selectedRows.length;

			/*
				The below code has been changed such that:
				a) show alert and do not save when the alias_id is blank
				b) [Removed] show watning alert when entity is blank and ignore is uncheked - but save the record - no hard stop
			*/
			if($('#e_entityDesc').html() == ''){
				err_message =  'Please enter a valid entity ID';
				is_error = 1;
			}
			else if($('#alias_id').val() == '' && (selectedRecordCount=== undefined || selectedRecordCount == 0)) /* || ($('#entity_id').val() == '') && $('#ignore_flag').is(':checked') == false */
			{
				err_message =  'These fields are required:' + '\n' + 'Alias ID';
				is_error = 1;
			}

			if(is_error == 1)
			{
				alert(err_message);
				return;
			}
		else
			{
			/*	 // put it back if we have to show an alert for the missing ID.
			if($('#entity_id').val() == '' && $('#ignore_flag').is(':checked') == false){
				err_message = err_message + '\n' + 'Warning: please enter a valid ID';
				is_error_entity_ID = 1;
			}
if(is_error_entity_ID == 1){
					alert(err_message);
				} */
			/*		else
				{	*/
					 /* NEW RECORD - If no record is selected and the user clicks on save - A new record to insert. */

					 if(selectedRecordCount=== undefined || selectedRecordCount == 0){
						AliasDef = [{"BSAID":$('#bsaId').val(),"ALIASID":$('#alias_id').val(),"ALIASDESC":$('#alias_desc').val(),"ENTITYID":$('#entity_id').val(),"UNKNOWN":$('#ignore_flag').is(':checked')
						,"PAYEEID":$('#payee_id').val(),"ALIASUNIPRONUM":$('#unipro_num').val(),"ALIASLOC":$('#loc_id').val(),"SOURCEID":strSourceID,"SOURCETYPE":strSourceType
						,"RECORDID":0,"ALIASREGION":'',"ALIASADDRESS":'',"ALIASCITY":'',"ALIASSTATE":'',"ALIASZIP":''}];
					}
					else{
					/* EDIT EXISTING RECORD */
						selectedRows = GridOptions.api.getSelectedRows();
						for (var i = 0; i < selectedRows.length; i++) {
							selectedRows[i].SOURCEID = strSourceID;
							selectedRows[i].SOURCETYPE = strSourceType;
						}
						AliasDef = selectedRows;
						recordExists = 1
					}


					for (var i = 0; i < AliasDef.length; i++) {
							var ALIASID = AliasDef[i].ALIASID;
							var ALIASDESC = AliasDef[i].ALIASDESC;

							if(ALIASID =='Infinity')  {
								AliasDef[i].ALIASID = '~Infinity';
							}
							if(ALIASDESC =='Infinity')  {
								AliasDef[i].ALIASDESC =  '~Infinity';
							}
						}


					 if(selectedRecordCount > 1){
							singleRecord = 0;
					 }

					$.ajax({type    : "post"
							,url: "/mvc/Models/Admin/Alias/AliasManager.cfc"
							,dataType: "json"
							,data: { method: "saveAliasJSON"
									,AliasDef: JSON.stringify(AliasDef)
									,entityType: entityType
									,userID:<cfoutput>'#request.AccessStructure.User_ID#'</cfoutput>
									,singleRecord: singleRecord
									}
							,success : function (response) {
								clearEditSubSection();
								/* If editing ecisting record */
								if(recordExists == 1){
									alert('saved');
								}
								else{
									/** If new record, then get the newly inserted record from the db */
									refreshGrid();
								}
							}
					});
			/* 	}*/
			 }
		}

		function deleteAlias(){
			let entityType = getActiveTab();
			selectedRows = GridOptions.api.getSelectedRows();

			$.ajax({type    : "post"
					,url: "/mvc/Models/Admin/Alias/AliasManager.cfc"
					,dataType: "json"
					,data: { method: "deleteAliasJSON"
							,AliasDef: JSON.stringify(selectedRows)
							,entityType: entityType
							}
					,success : function (response) {
						clearEditSubSection();
						refreshGrid();
					}
			});
		}

		function massApply(action){

			let selectedRows = GridOptions.api.getSelectedRows();
			let selectedRecordsCount =  Object.keys(selectedRows).length;

			if(selectedRecordsCount == 0){
				alert('Please select (using checkbox) at least one record');
			}
			else{

				if(action =='ignore'){
					updateAliasDataMassApply('UNKNOWN', 1);
				}
				else if(action =='unIgnore'){
					updateAliasDataMassApply('UNKNOWN', 0);
				}
				else if(action =='assignID'){
					updateAliasDataMassApply('ENTITYID', $('#entity_id').val());
				}
				else if(action =='delete'){
					if(confirm("Are you sure you want to delete the selected records?")){
						deleteAlias();
					}
				}
			}
		}

		function clearCounts() {
			// Clear all 4 tab "counts"
			for (i=0; i < 4; i++) {
				clearCount("#count"+i);
			}
		}
		function unHide(elID) {
			let elem = document.getElementById(elID);
			if (elem.classList.contains("hidden")) {
				elem.classList.remove("hidden");
			}
		}
		function hide(elID) {
			let elem = document.getElementById(elID);
			if (elem.classList.contains("hidden") == false) {
				elem.classList.add("hidden");
			}
		}
		function hideOtherTabs() {
			hide ('productTab');
			hide ('programTab');
			hide ('operatorTab');
			document.getElementById('tabArea').style.width="10%";
		}
		function unHideOtherTabs() {
			unHide ('productTab');
			unHide ('programTab');
			unHide ('operatorTab');
			document.getElementById('tabArea').style.width="40%";

		}
		function enableSearch(b) {
			document.getElementById("searchBtn").disabled = !b;  // b=true =>disabled=false
		}
		function showSearch(b) {
			b ? unHide("searchBtn") : hide("searchBtn");
		}

		function getSelected() {

			// TODO Move to functions in the data type files (distributor, program, etc)

			// sSelected = '';
			// for (i=0; i<gridOptions.api.getSelectedRows().length; i++) {
				// sSelected = sSelected + gridOptions.api.getSelectedRows()[i].CONTRACT_MAIN_ID  TODO::: WHAT ID
				// if (i != (gridOptions.api.getSelectedRows().length -1)) {
					// sSelected = sSelected + ",";
				// }
			// }

			return ("");
		}

		// On load....
		// Open the first section
		window.onload = $('#loadDataBtn').click();

		// Init the default tab for the results section
		document.getElementById("defaultTab").click();

		// Resize grid height whenever the browser is resized
		$(window).resize(function(){ set_grid_full_height("myAliasGrid"); });
		</script>

		<cfinclude template="/Common_Files/focus.cfm">


</body>
</html>