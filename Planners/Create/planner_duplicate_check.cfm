<!----------------------------------------------------------------------------------
Name         :  /AwayX/Planners/Create/planner_duplicate_check.cfm
Copyright    :  (c) 2016 Blacksmith Applications, Inc.
Created Date :  23/Sept/2020
Created By   :  Tim Ford
Description  :  Display Planner Program duplicates during Planer RFA and approval
---------------------------------------------------------------------------------->

<cfparam name="url.plannerId" default="0">
<cfparam name="url.programList" default="0">
<cfparam name="url.plannerAction"	default="">
<cfset dupAction = 1>

<cfquery name="qGetDupData" datasource="#application.datasource#">
	SELECT	distinct
			Contract_Main.Contract_Main_ID,
			Contract_Main.Contract_Number,
			Contract_Main.Contract_Title,
			_Users.User_ID, _Users.User_Email,
			_Users.Name_First + ' ' + _Users.Name_Last AS User_Full_Name,
			_Users.Name_First, _Users.Name_Last,
			_Users.Profiles_ID,
			_Users.Work_Phone_1 + '-' + _Users.Work_Phone_2 + '-' + _Users.Work_Phone_3 As User_Work_Phone,
			_Users.Work_Phone_Ext, _Users.Authority_Sequence_ID,
			_Users.Title, _Users.User_Number, User_Positions.Position_Label,
			_Users.Work_Address_1, _Users.Work_Address_2, _Users.Work_City, _Users.Work_State, _Users.Work_Zip, _Users.Company_Name,
			_Users.Crucible_File_Download, _states.State_Code,
			ISNULL(_Users.Is_Eligible_RSP, 0) as Is_Eligible_RSP, ISNULL(_Users.Is_On_Behalf_Of, 0) as Is_On_Behalf_Of,
			Position_Level = CASE WHEN User_Positions.Service_Market_ID IS NOT NULL THEN 3
									WHEN User_Positions.Service_Region_ID IS NOT NULL
										AND User_Positions.Service_Market_ID IS NULL THEN 2
									WHEN User_Positions.Service_Zone_ID IS NOT NULL
										AND User_Positions.Service_Region_ID IS NULL
										AND User_Positions.Service_Market_ID IS NULL THEN 1
									ELSE 0
								END,
			User_Position_Holders.User_Positions_ID,
			_Users.User_Code,
			_Users.Analytics_SSO_User_Name,
			_Users.Ember_Info,
			pcpo.Duplicate_Program_Action
	FROM	Contract_Main 
			inner join _Users on _Users.User_ID = Contract_Main.Creator_ID
			LEFT JOIN User_Position_Holders ON User_Position_Holders.User_ID = _Users.User_ID
			AND User_Position_Holders.User_Position_Type = 'P'
			AND User_Position_Holders.Deleted = 0
			LEFT JOIN User_Positions ON User_Positions.Deleted = 0
			AND User_Positions.User_Positions_ID = User_Position_Holders.User_Positions_ID
			LEFT JOIN _states ON _states.State_ID = _Users.Work_State
			INNER JOIN Program_Control_Panel_Options pcpo on pcpo.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
	WHERE 	Contract_Main.Contract_Main_ID IN (#ListQualify(url.programList, "'")#)
			AND Contract_Main.Contract_Status_Type_IDX <> 1

</cfquery>


<cfset aDuplicateData = arrayNew(1) />

<!---create array of structs for duplicate data --->
<cfloop query="qGetDupData">
	<cf_cryp type="en" string ="#Contract_Main_ID#" key="#request.key#">
	<cfset ContractID = cryp.value>
	<cfset stTemp = StructNew() />
	<cfset stTemp.contract_main_id = #ContractID#  />
	<cfset stTemp.contract_number = #Contract_Number#  />
	<cfset stTemp.contract_title = #Contract_Title#  />
    <cfset stTemp.sales_person = #User_Full_Name#  />
    <cfset stTemp.user_position = #Position_Label#  />
    <cfset stTemp.work_phone = #User_Work_Phone#  />
    <cfset stTemp.work_address = "#Work_Address_1#  #Work_Address_2#"  />
    <cfset stTemp.city_state_zip = "#Work_City# #State_Code# #Work_Zip#"  />
	<cfset ArrayAppend(aDuplicateData, stTemp)  />
	<!---if any program has the "Prevent dups of approved programs" template set to 2 then don't allow planner to be approved --->
	<cfif qGetDupData.Duplicate_Program_Action eq 2>
		<cfset dupAction = 2 />
	</cfif>
</cfloop>

<!DOCTYPE html>
<html lang="en">
	<head>
		<title>Planner Program Duplicate</title>
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
			div.msg {
				font-size:13px;
				text-align:center;
				margin:13px 0;
			}
		</style>
		
	</head>	

	<body>
	<cfinclude template="/common_files/jQuery.cfm">
    <div class="msg">
		Warning: Duplicate program(s) already exists
	</div>

	<div align="center">
	<table>
		<tr>
			<cfif dupAction EQ 1>
				<td>
				<CF_button
						button_name		=	"continueRFA"
						button_caption	=	"continue"
						button_action	=	"plannerRFAapprove();"
						button_type		=	"javascript_link"
						button_width	=	"150"
						button_color	=	"Navy"
						button_tip		=	"continue with the application"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
				>
				</td>
			</cfif>
			<td>
			<CF_button
				button_name		=	""
				button_caption	=	"cancel"
				button_action	=	"window.close();"
				button_type		=	"javascript_link"
				button_width	=	"150"
				button_color	=	"Navy"
				button_tip		=	"Click here to close"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
			</td>
		</tr>
	</table>
	</div>

	<div id="duplicateDataGrid" class="ag-theme-balham"></div>

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

		// Setup the duplicate data Grid
		var duplicateRowData = [{}];
		<cfoutput> #toScript(aDuplicateData, "duplicateRowData")#; </cfoutput>

		var duplicateColumnDefs = [
			{headerName: "Contract Number", field: "contract_number",
				cellRenderer: function(params) {
							let contractNumberCel =
								"<a onclick=newWin('" +  params.data.contract_main_id  + "');>" +
									params.data.contract_number +
								"</a>";
							return contractNumberCel;
						},
			},
			{headerName: "Contract Title", field: "contract_title"},
            {headerName: "Sales Person", field: "sales_person",  wrapText: true, autoHeight: true, 
				cellRenderer: function(params) {
							let salesPersonCel =
								'<div>' +
									params.data.sales_person + '<br>' +
									params.data.user_position + '<br>' +
									params.data.work_phone + '<br>' +
									params.data.work_address + '<br>' +
									params.data.city_state_zip + '<br>' +
								'</div>';
							return salesPersonCel;
						},
			},
          
		];
		// Init Program Workflow grid
		var duplicateDataGridOptions = {
			 columnDefs: duplicateColumnDefs
			,rowData: duplicateRowData
			,rowModelType: "clientSide"
			,debug: false
            ,onGridReady: function (params) {
                params.api.sizeColumnsToFit();
            }
			 ,domLayout:					"autoHeight"
		};
		ag_grid_default(duplicateDataGridOptions);		// set up default features
		init_ag_grid( duplicateDataGridOptions, "#duplicateDataGrid", false );


		//function to call when coming from planner program RFA and Approve
		function plannerRFAapprove(){
			//if RFA then submit rfa form in opener
			<cfif url.plannerAction eq "rfa">
				$("form[name=rfa]", opener.document).submit();
			//if approve then submit approval form in opener
			<cfelseif url.plannerAction eq "approve">
				$("form[name=approval]", opener.document).submit();
			</cfif>
			window.close();
		}

		function newWin(contractMainId){
			NewWindow('/scorecard/program_display.cfm?display_program=1&CID='+contractMainId,'ViewProgram','900','700','Yes', 'Yes');
		}

	</script>
	<cfinclude template="/common_files/focus.cfm">
</body>
</html>
	