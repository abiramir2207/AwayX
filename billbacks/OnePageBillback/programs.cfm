<!---
* ====================================================================================================
*    @File: \billbacks\OnePageBillback\programs.cfm
*  @Author: Sharon Harris
*    @Date: June 2019
*
* @Remarks: OnePageBillback Settlements page - Programs search results tab content
*
* ====================================================================================================
--->
<cfscript>
	param name="form.BB_Date"	default="#dateformat(now(),'m/d/yyyy')#";
	param name="form.Del_Start"	default="";
	param name="form.Del_End"	default="";
</cfscript>

<cfoutput>

<div class="programs m-1">
	<!--- Information cards at the top --->
	<div class="flex">

		<!--- First card --->
		<div class="m-0">
			<div class="card-header">
				Billback Header Information
				<span style="padding: 0 0 0 5px">
					<i class="fa fa-info-circle" title="This information will be used to generate the Billback header" style="font-size:11px"></i>
				</span>
			</div>
			<div class="card-main flex">
				<div class="mr-2">
					<div class="text-center">Billback Ref ##</div>
					<input type="text" class="mb-1" name="BB_Ref" id="BB_Ref" size="10">
					<div class="text-center">Delivery Start</div>
					<input name="Del_Start" id="Del_Start" type="text" class="card-input date-info mb-1" value="#form.Del_Start#">

				</div>
				<div class="mr-2">
					<div class="text-center">Billback Date</div>
					<input name="BB_Date" id="BB_Date" type="text" class="card-input date-info mb-1" value="#form.BB_Date#">

					<div class="text-center">Delivery End</div>
					<input name="Del_End" id="Del_End" type="text" class="card-input date-info mb-1" value="#form.Del_End#">

				</div>
				<div class="mr-2">
					<div class="text-center">Payee Type</div>
					<select id="Payee_Type" class="card-input" onchange="PayeeTypeChange()" >
						<option value="0" id="0"> </option>
						<!--- <cfoutput query=""> --->
							<!--- <option value="#Payee_Type#" source_code="#Payee_Code#">#Payee_Type_Display#</option> --->
						<!--- </cfoutput> --->
					</select>
				</div>
				<div class="mr-2">
					<div class="text-center">Closing Method</div>
					<select id="Closing_Method" class="card-input" onchange="Closing_MethodChange()" >
						<option value="0" id="0"> </option>
						<!--- <cfoutput query=""> --->
							<!--- <option value="#Closing_Method#" source_code="#Closing_Method#">#Closing_Method_Display#</option> --->
						<!--- </cfoutput> --->
					</select>
				</div>
				<div class="mr-2">
					<div class="text-center">Vendor</div>
					<input type="text" name="Vendor" id="Vendor" size="10">
				</div>
			</div>
		</div>

		<!--- Second card --->
		<div class="m-0 ml-4">
			<div class="card-header">
				Settlement detail
				<span class="pl-8">$1,345.00</span>
			</div>
			<div class="card-main flex">
				<div class="mr-2">
					<div>104000945-003-000</div>
				</div>
				<div class="mr-2">
					<div class="text-center">Claimed Amt</div>
					<input type="text" class="mb-1" name="Claimed_Amt" id="Claimed_Amt" size="10">
					<div class="text-center">Variance</div>
					<input type="text" class="mb-1" name="Variance" id="Variance" size="10">
				</div>
				<div class="mr-3">
					<div class="text-center">Claimed Qty</div>
					<div><input type="text" name="Claimed_Qty" id="Claimed_Qty" size="10">
					LB</div>
				</div>
				<div class="mr-2">
					<div class="text-center">Closure Reason Code</div>
					<select id="Closure_Reason_Code" class="card-input-wide mb-1" onchange="Closure_Reason_CodeChange()" >
						<option value="0" id="0"> </option>
						<!--- <cfoutput query=""> --->
							<!--- <option value="#Closure_Reason_Code#" source_code="#Closure_Reason_Code#">#Closure_Reason_Code_Display#</option> --->
						<!--- </cfoutput> --->
					</select>

					<div class="mt-1">
						<button type="button" onClick="" title="Generate Billback" class="button recommended">Generate</button>
					</div>
				</div>
			</div>
		</div>
	</div>



	<!--- result count and action button area --->
	<div class="flex justify-between my-1">
		<span class="ml-1 text-xs" style="position:relative; top:3px;">
			Program results: <span id="grid_count"> ...</span>
		</span>
		<!--- <cfif local.External_Customer_Profile_Access eq 0> --->
		<button id="column_tool" class="button" style="height: 16px;"></button>
		<!--- </cfif> --->
	</div>

	<!-------------------->
	<!--- Program GRID --->
	<!-------------------->
	<div id="programGrid" class="ag-theme-balham"></div>
</div>
</cfoutput>




<script>

$(".date-info").datepicker({
	dateFormat: "m/d/yy",
	changeMonth: true,
	changeYear: true,
	onSelect: function( selected ) {
		let dateName = jQuery(this).attr("name");
		// change date limit based on selected value (if start/end)
		if ( dateName === "Del_Start" )
			jQuery("input[name=Del_End]").datepicker("option", "minDate", selected);
		else if ( dateName === "Del_End" )
			jQuery("input[name=Del_Start]").datepicker("option", "maxDate", selected);
	}
});


<!--- <cfif local.External_Customer_Profile_Access eq 0> --->
const show_column_tool = "show column tool";
$("#column_tool").text( show_column_tool );
<!--- </cfif> --->

// Toggle the column tool button
$("#column_tool").click(function(){
	if ( ProgramGridOptions.api.isSideBarVisible() ) {
		ProgramGridOptions.api.setSideBarVisible(false);
		$(this).text( show_column_tool );
	}
	else {
		ProgramGridOptions.api.setSideBarVisible(true);
		ProgramGridOptions.api.openToolPanel('columns');
		$("div.ag-side-buttons").hide();
		$(this).text( "hide column tool" );
	}
});

// Create the sideBarDef object
function setup_sidebar(gridOptions) {
	gridOptions.sideBar = {
		hiddenByDefault: true,
		toolPanels: [ {
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
		}]
	};
}


var ProgramGridOptions = {};	// GLOBAL options for Program grid

function Build_ProgramsGrid() {
	set_grid_full_height ("programGrid");
	ProgramGridOptions = {
		columnDefs: [
			{width:23, checkboxSelection:true, suppressToolPanel:true, suppressMovable:true, sortable:false, pinned:"left", lockPosition:true},
			{headerName: "<cfoutput>#Application.PlannerLabel#</cfoutput> #", field: "PLANNER_NUMBER", width: 75},
			{headerName: "Program #", field: "PROGRAM_NUMBER", width: 100},
			{headerName: "Program Title", field: "PROGRAM_TITLE", width: 110},
		],
		/* Keep a high number for cacheBlockSize (currently 20000), so that scrolling is not slow. */
		cacheBlockSize: 20000,
		debug: false,
		rowSelection: "multiple",
		rowDeselection: true,
		suppressCellSelection: true,

		// rowModelType: "serverSide",
		rowModelType: "clientSide",     // TODO change to server-side
		rowData: rowData_Programs
	};

	ag_grid_default (ProgramGridOptions);		// set up default features
	setup_sidebar(ProgramGridOptions);
	init_ag_grid( ProgramGridOptions, "#programGrid", false );	// TODO: change to true for server-side
}

// TEST DATA - REPLACE WITH REAL SERVER DATA
var rowData_Programs = [
    {PLANNER_NUMBER: "PLR-1002535", PROGRAM_NUMBER: "PRG-1002530", PROGRAM_TITLE:"J&B SuperOne Rebate"},
    {PLANNER_NUMBER: "PLR-1002535", PROGRAM_NUMBER: "PRG-1002531", PROGRAM_TITLE:"J&B SuperOne Rebate"},
    {PLANNER_NUMBER: "PLR-1002535", PROGRAM_NUMBER: "PRG-1002532", PROGRAM_TITLE:"J&B SuperOne Rebate"},
    {PLANNER_NUMBER: "PLR-1002535", PROGRAM_NUMBER: "PRG-1002533", PROGRAM_TITLE:"J&B SuperOne Rebate"},
    {PLANNER_NUMBER: "PLR-1002535", PROGRAM_NUMBER: "PRG-1002534", PROGRAM_TITLE:"J&B SuperOne Rebate"},
    {PLANNER_NUMBER: "PLR-1002535", PROGRAM_NUMBER: "PRG-1002535", PROGRAM_TITLE:"J&B SuperOne Rebate"},
    {PLANNER_NUMBER: "PLR-1002410", PROGRAM_NUMBER: "PRG-1002419-009", PROGRAM_TITLE:"J&B SuperOne Rebate"},
];

</script>