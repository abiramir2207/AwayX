<cfsilent>
<!----------------------------------------------------------------------------------
Name         :  /AwayX/Planners/Create/planner_details.cfm
Copyright    :  (c) 2016 Blacksmith Applications, Inc.
Created Date :  27/Aug/2020
Created By   :  Tim Ford
Description  :  Display Planner details and workflow
---------------------------------------------------------------------------------->

<cfparam name="url.plannerId" default="">

<cfset searchManager  = CreateObject("component","mvc.Models.Program.Search_Program") />
<cfset plannerManager  = CreateObject("component","mvc.Models.Planner.PlannerManager") />

<!--- Get data needed --->
<cfset qGetPlannerData = plannerManager.getPlanner(url.plannerId) />
<cfset qGetProgramData = plannerManager.getProgramsByPlannerId(url.plannerId) />
<cfset qGetPlannerWorkFlow = plannerManager.getPlannerWorkflow(url.plannerId) />
<cfset bTPOExists = plannerManager.checkTPO(url.plannerId) />


<!---created empty arrays --->
<cfset aPlannerWorkFlowData = arrayNew(1) />
<cfset aWorkFlowData = arrayNew(1) />
<cfset tmpaWorkFlowData = arrayNew(1) />

<!---loop over program data and insert contract number into workflow struct to display --->
<cfloop query="qGetProgramData">
	<cfset tmpArray = searchManager.getWorkFlowData(programId = Contract_Main_ID) />
	<cfloop index = "i" from ="1" to="#ArrayLen(tmpArray)#">
		<cfset tmp = StructInsert(tmpArray[i], "Contract_Number", Contract_Number & '-' &  Version) />
	</cfloop>
	<cfset ArrayAppend(tmpaWorkFlowData, tmpArray)  />
</cfloop>

<!---create single dimensional array for program workflow data --->
<cfloop index = "i" from ="1" to="#ArrayLen(tmpaWorkFlowData)#">
	<cfloop index = "n" from ="1" to="#ArrayLen(tmpaWorkFlowData[i])#">
		<cfset tmpaWorkFlowData[i][n].Action_date = '#DateFormat(tmpaWorkFlowData[i][n].Action_date, "mm/dd/yyyy")# #TimeFormat(tmpaWorkFlowData[i][n].Action_date, "hh:mm tt")#'>
		<cfset ArrayAppend(aWorkFlowData, tmpaWorkFlowData[i][n])  />
	</cfloop>
</cfloop>


</cfsilent>
<!---create array of structs for planner workflow data --->
<cfloop query="qGetPlannerWorkFlow">
	<cfset stTemp = StructNew() />
	<cfset stTemp.planner = #Planner_Number#  />
	<cfset stTemp.action = #action#  />
	<cfset stTemp.name = #name#  />
	<cfset stTemp.position = #User_Position#  />
	<cfset stTemp.profile = #Profile#  />
	<cfset stTemp.authority_Sequence = #Authority_Sequence#  />
	<cfset stTemp.date = '#DateFormat(action_date, "mm/dd/yyyy")# #TimeFormat(action_date, "hh:mm tt")#'  />
	<cfset ArrayAppend(aPlannerWorkFlowData, stTemp)  />
</cfloop>

<!DOCTYPE html>
<html lang="en">
	<head>
		<title>Planner Details</title>
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<style>
			#links {
				padding-bottom: 7px;
			}
			#links a {
				font-size: 11px;
				font-weight: bold;
				margin-left: 3px;
				margin-right: 20px;
			}
			.section-header {
				color: #343540;
				font-size: 11px;
				margin-left: 3px;
				margin-right: 5px;
				float: left;
			}
			.section-rule {
				border:0;
				height: 1px;
				background: #d8d9dd;
				clear: none;
				position: relative;
			}
			/* Styles for flexible top Detail columns */
			.details-container {	/* Flex container */
				display: flex;
				flex-direction: row;
   				justify-content: flex-start;
				clear: both;
				margin-left: 10px;
			}

			.detail-col {
				display:table;
				border-collapse:collapse;
			}

			.table-row {
				display:table-row;
			}

			.detail-col label,
			.detail-field {
				display:table-cell;
				font-size: 12px;
				padding-right: 10px;
				padding-top: 6px;
			}

			.detail-col label {
				color: #7c7c7c;
				text-align: right;
				min-width: 90px;
			}
			.detail-field {
				color: #343540;
				padding-right: 20px;
				min-width: 120px;

			}
		</style>

	<cfoutput>

	</head>

	<body>
		<cfinclude template="/common_files/jQuery.cfm">
		<div class="page_title1">#Application.PlannerLabel# Details</div>
			<!--- DETAILS Section --->
			<div class="section-header">DETAILS</div> <hr class="section-rule">
			<div class="details-container">
				<!--- First column --->
				<div class="detail-col">
					<div class="table-row">
						<label>#Application.PlannerLabel#:</label>
						<span class="detail-field">#qGetPlannerData.Planner_Number#</span>
					</div>
					<div class="table-row">
						<label>Date:</label>
						<span class="detail-field">#qGetPlannerData.Planner_Start_Date# - #qGetPlannerData.Planner_End_Date#</span>
					</div>
					<div class="table-row">
						<label>Sent From TPO:</label>
						<span class="detail-field"><cfif bTPOExists>Yes<cfelse>No</cfif></span>
					</div>
				</div>

				<!--- Second column --->
				<div class="detail-col">
					<div class="table-row">
						<label>Title:</label>
						<span class="detail-field">#qGetPlannerData.Planner_Title#</span>
					</div>
					<div class="table-row">
						<label>RSP:</label>
						<span class="detail-field">#qGetPlannerData.RSP_User_Name# (#qGetPlannerData.RSP_Position#)</span>
					</div>

				</div>
			</div>
		</div>
		<br>
		<!--- ************************ Planner WorkFlow Info  ************************ --->
		<cfset pwfLen = ArrayLen(aPlannerWorkFlowData)>
		<cfif isDefined("aPlannerWorkFlowData") AND (pwfLen NEQ 0)>
			<br>
			<div class="section-header">#UCASE(Application.PlannerLabel)# WORKFLOW</div> <hr class="section-rule">
			<br>
			<cfif pwfLen GT 1> <cfset pwfHeight = "100"><cfelse><cfset pwfHeight = "50"></cfif>
			<div id="plannerWorkflowGrid" style="margin-left:25px; height:#pwfHeight#px; width:820px" class="ag-theme-balham"></div>
		</cfif>


		<!--- ************************ Program WorkFlow Info  ************************ --->
		<cfset wfLen = ArrayLen(aWorkFlowData)>
		<cfif isDefined("aWorkFlowData") AND (wfLen NEQ 0)>
			<br>
			<div class="section-header">#UCASE(Application.PlannerPrgLabel)# WORKFLOW</div> <hr class="section-rule">
			<br>
			<cfif wfLen GT 1> <cfset wfHeight = "200"><cfelse><cfset wfHeight = "50"></cfif>
			<div id="programWorkflowGrid" style="margin-left:25px; height:#wfHeight#px; width:820px" class="ag-theme-balham"></div>
		</cfif>

	</cfoutput>

	<!--- Include ag-grids --->
	<cfset request.ag_grid_theme = "ba-ag-theme-balham">
	<cfinclude template="/common_Files/ag-Grid.cfm">
	<style>
		.ag-theme-balham {
			font-size: 11px;
		}
		.ag-header {
			font-size: 11px !important;
		}
		.ag-theme-balham .ag-cell {
			padding-left: 2px;
			padding-right: 0px;
		}
  		.ag-theme-balham .ag-row-selected {
    		border-bottom-color: #b5b5b5; /* don't hide lines when selected */
		}
		.ag-theme-balham .ag-selection-checkbox span {
		    left: 2px; /* center the checkbox */
    	}
	</style>

	<!--- Setup Client-side Grids --->
	<script>

		// Setup the Planner Workflow Grid
		var plannerWorkflowRowData = [{}];
		<cfoutput> #toScript(aPlannerWorkFlowData, "plannerWorkflowRowData")#; </cfoutput>

		var plannerWorkflowColumnDefs = [
			{headerName: "<cfoutput>#Application.PlannerLabel#</cfoutput>", field: "planner", width:85},
			{headerName: "Action", field: "action", width:65},
			{headerName: "Name", field: "name", width:130},
			{headerName: "Position", field: "position", width:125},
			{headerName: "Profile", field: "profile", width:110},
			{headerName: "Authority Sequence", field: "authority_sequence", width:150},
			{headerName: "Date", field: "date", width:115}
		];
		// Init Planner Workflow grid
		var plannerWorkflowGridOptions = {
			 columnDefs: plannerWorkflowColumnDefs
			,rowData: plannerWorkflowRowData
			,rowModelType: "clientSide"
			,cacheBlockSize: 2000
			,debug: false
		};
		ag_grid_default(plannerWorkflowGridOptions);		// set up default features
		init_ag_grid( plannerWorkflowGridOptions, "#plannerWorkflowGrid", false );


		// Setup the Program Workflow Grid
		var programWorkflowRowData = [{}];
		<cfoutput> #toScript(aWorkFlowData, "programWorkflowRowData")#; </cfoutput>

		var programWorkflowColumnDefs = [
			{headerName: "<cfoutput>#Application.PlannerPrgLabel#</cfoutput>", field: "contract_number", width:95},
			{headerName: "Action", field: "action", width:65},
			{headerName: "Name", field: "name", width:130},
			{headerName: "Position", field: "position", width:125},
			{headerName: "Profile", field: "profiles_desc", width:110},
			{headerName: "Authority Sequence", field: "authority_sequence_name", width:150},
			{headerName: "Date", field: "action_date", width:115}
		];
		// Init Program Workflow grid
		var programWorkflowGridOptions = {
			 columnDefs: programWorkflowColumnDefs
			,rowData: programWorkflowRowData
			,rowModelType: "clientSide"
			,cacheBlockSize: 2000
			,debug: false
		};
		ag_grid_default(programWorkflowGridOptions);		// set up default features
		init_ag_grid( programWorkflowGridOptions, "#programWorkflowGrid", false );

	</script>
	<cfinclude template="/common_files/focus.cfm">
</body>
</html>
