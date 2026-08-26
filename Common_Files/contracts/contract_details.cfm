<cfsilent>
<!----------------------------------------------------------------------------------
Name         :  AwayX/Common_Files/contracts/contract_details.cfm
Copyright    :  (c) 2016 Blacksmith Applications, Inc.
Created Date :  19/Jul/2016
Created By   :  Anand Rao, Sharon Harris
Description  :  Display the details about the program
---------------------------------------------------------------------------------->
<cfparam name="url.fromPrg" default="0">

<cfset contractMainID = URL.contractId />
<cfset URL.contract_main_ID = contractMainID />

<cfset searchManager  = CreateObject("component","mvc.Models.Program.Search_Program") />


<cfset qProgramDetails 		 	= searchManager.getProgramDetails(Program_ID = contractMainID) />
<cfset qProgramAutoRenewInfo 	= searchManager.getProgramAutoRenewInfo(Program_ID = contractMainID) />
<cfset qInterfaceInfo 		 	= searchManager.getInterfaceInfo(Program_ID = contractMainID) />
<cfset qAttachmentInfo		 	= searchManager.getAttachmentInfo(Program_ID = contractMainID) />
<cfset qAreThereRevisions		= searchManager.getAreThereRevisions(Program_ID = contractMainID) />
<cfset qGLAccount			  	= searchManager.getGLAccount(Program_ID = contractMainID) />
<cfset qBusinessSegmentSetting	= searchManager.getBusinessSegmentSetting() />
<cfset aWorkFlowData 			= searchManager.getWorkFlowData(programId = contractMainID) />
<!--- Setup with Formatted date for display --->
<cfloop index = "i" from ="1" to="#ArrayLen(aWorkFlowData)#" >
	<cfset aWorkFlowData[i].Action_date = '#DateFormat(aWorkFlowData[i].Action_date, "mm/dd/yyyy")# #TimeFormat(aWorkFlowData[i].Action_date, "hh:mm tt")#'>
</cfloop>
<cfset RSP_ID					= qProgramDetails.Responsible_user_Id>
<cfset qCRA         			= searchManager.getApprovableUserList(contractMainID, RSP_ID) />
<cfset qNRA           			= searchManager.getNextApprovableUsers(contractMainID) />
<cfset appsettings 				= application.oapplicationappsettingsmanager.getapplicationappsettings()>

<cfquery name="qGetProgram" datasource="#application.datasource#">
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SELECT 	Planner_ID, ProgramType_ID
	FROM 	Contract_Main
	WHERE 	Contract_Main_ID =  '#contractMainID#'
</cfquery>

<cfset isPlannerProgram = Val(qGetProgram.Planner_ID) />
<cfset local.plannerId = qGetProgram.Planner_ID />
<cfset local.templateId = qGetProgram.ProgramType_ID />

<CFPARAM NAME="URL.CPAccess" DEFAULT=""><!--- 83860 URL.CPAccess will be used in Application_Common.cfm ---->
<cfset local.URLCPAccessArgN = "" />
<cfif request.AccessStructure.External_Customer_Profile_Access EQ "1">
	<cfset local.External_Customer_Profile_Access = 1 />
	<cfset local.URLCPAccessArg1 = "?CPAccess=#URL.CPAccess#" />
	<cfset local.URLCPAccessArgN = "&CPAccess=#URL.CPAccess#" />
</cfif>

</cfsilent>
<!--- ************************* Program Details ************************* --->

<!DOCTYPE html>
<html lang="en">
	<head>
		<title>Program Details</title>
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
		<script language="javascript">
			function openPrintEmailPage(program_ID,Action)
			{
				var winjscommand ="/CID_Wrapper.cfm?ID=#contractMainID#&Page_Relocate=/common_files/contracts/email_fax_handler.cfm&Action="+Action;
				window.open(winjscommand,'winPrint','height=2000,width=2000,toolbar=no,scrollbars=yes,left=0,top=0,screenX=0,screenY=0,resizable=no');
			}

			function CopyProgram()
			{
				var copy_confirm = confirm("Are you sure you want to copy this program?");
				if (copy_confirm)
				{
					<cfif isPlannerProgram>
						var winjscommand = "/Planners/Create/planner_program_create.cfm?programId=#contractMainID#&plannerID=#local.plannerId#&templateId=#local.templateId#&bInit=1&bCopy=1";
						popupInCenter(winjscommand,'winEdit');
					<cfelse>
						var winjscommand ="/CID_Wrapper.cfm?ID=#contractMainID#&Page_Relocate=/common_files/contracts/email_fax_handler.cfm&Action=copy";
						window.open(winjscommand,'wincopy','height=1400,width=1000,toolbar=no,scrollbars=yes,left=0,top=0,screenX=0,screenY=0,resizable=no');
					</cfif>
				}
			}

			function openLetters()
			{
				var winjscommand ="/CID_Wrapper.cfm?ID=#contractMainID#&Page_Relocate=/common_files/contracts/letters/distributors.cfm&Action=quoteletters";
				window.open(winjscommand,'winLetters','height=800,width=800,toolbar=no,scrollbars=yes,left=0,top=0,screenX=0,screenY=0,resizable=no');
			}

			function showRevisionDetails()
			{
				var winjscommand ="/reportwriter/performance_reports/revisionreport.cfm?Contract_main_id=#contractMainID#&Contract_Status=#qProgramDetails.Contract_Status_Type_IDX#&bypassRevSummary=1<cfoutput>#local.URLCPAccessArgN#</cfoutput>";
				window.open(winjscommand,'win','height=550,width=1200,toolbar=no,scrollbars=yes,resizable=yes');
			}

			function openPriorVersionInfo(CMID,Cont_Num){
				NewWindowTopLeft("/common_files/contracts/prior_version_interface_info.cfm?Contract_main_id="+CMID,"winPriorVersionInterfaceInfo","1050","450","yes","yes");
			}
		</script>
	</head>

	<cfif application.appSettingsGet.getDisplayQuoteLetter() AND application.appSettingsGet.getlettersavailable() eq 3>
		<cfset sQuoteLetters = "1" />
	<cfelse>
		<cfset sQuoteLetters = "0" />
	</cfif>

	<body>
		<cfinclude template="/common_files/jQuery.cfm">
		<div class="page_title1">Program Details</div>


		<cfif isDefined("qProgramDetails") AND (qProgramDetails.Recordcount NEQ 0)>
			<cfinclude template="/common_files/general_labels.cfm">
			<!--- LINKS --->
			<cfif request.AccessStructure.External_Customer_Profile_Access NEQ "1">
			<div id="links">
				<a href="##" onclick="javascript:openPrintEmailPage(#contractMainID#,'print');">Print</a>
				<cfif (sQuoteLetters EQ "0")>
					<a href="##" onclick="javascript:openPrintEmailPage(#contractMainID#,'email');">Email</a>
				</cfif>
				<cfif qProgramDetails.Planner_ID EQ 0 OR ! url.fromPrg>
					<a href="##" onclick="javascript:CopyProgram();">Copy</a>
				</cfif>
				<cfif (sQuoteLetters EQ "1")>
					<a href="##" onclick="javascript:openLetters();">Quote Letter</a>
				</cfif>
			</div>
			</cfif>


			<!--- DETAILS Section --->
			<div class="section-header">DETAILS</div> <hr class="section-rule">
			<div class="details-container">
				<!--- First column --->
				<div class="detail-col">
					<div class="table-row">
						<label>Program:</label>
						<span class="detail-field">#qProgramDetails.Contract_Number#</span>
					</div>
					<div class="table-row">
						<label>Version date:</label>
						<span class="detail-field">#qProgramDetails.date_span#</span>
					</div>
					<div class="table-row">
						<label>Version volume:</label>
						<span class="detail-field">#NumberFormat(qProgramDetails.Contract_Quantity)# #qProgramDetails.Abbreviation#</span>
					</div>
					<div class="table-row">
						<label>Total volume:</label>
						<span class="detail-field">#NumberFormat(qProgramDetails.Total_Contract_Quantity,"___,___,___")# #qProgramDetails.Abbreviation#</span>
					</div>
					<div class="table-row">
						<cfif qProgramDetails.Locked_By NEQ "">
							<label>Locked by:</label>
							<span class="detail-field">#qProgramDetails.Locked_By#</span>
						</cfif>
					</div>
					<div class="table-row">
						<cfif isDefined("qBusinessSegmentSetting") AND (qBusinessSegmentSetting EQ 1)>
							<label>Segment:</label>
							<span class="detail-field">#qProgramDetails.Business_Unit_Desc#</span>
						</cfif>
					</div>
					<div class="table-row">
						<cfif isDefined("qProgramAutoRenewInfo") AND (qProgramAutoRenewInfo NEQ "")>
							<label>Auto Renew:</label>
							<span class="detail-field">#qProgramAutoRenewInfo#</span>
						</cfif>
					</div>
					<div class="table-row">
						<cfif isDefined("qGLAccount") AND (qGLAccount NEQ "")>
							<label>GL Code:</label>
							<span class="detail-field">#qGLAccount#</span>
						</cfif>
					</div>

					<cfif isDefined("qAreThereRevisions") AND (qAreThereRevisions NEQ 0)>
						<div class="table-row">
							<label><a href="##" onclick="javascript:showRevisionDetails();" title="Click for Revision Details...">Revision:</a> </label>
							<span class="detail-field">This program has been Revised</span>
						</div>
					<cfelseif (qProgramDetails.Revision_of_Contract_Main_ID NEQ "" AND qProgramDetails.Is_A_Revision EQ 1)>
						<div class="table-row">
							<label>Revision:</label>
							<span class="detail-field">This is a Revision
								<br><a href="##" onclick="javascript:showRevisionDetails();" title="Click for Revision Details..." class="addLink">#application.util.string.linkFormat("revision history")#</a></span>
						</div>
					</cfif>

					<div class="table-row">
						<cfif isDefined("qAttachmentInfo") AND (qAttachmentInfo NEQ "")>
							<label>Documents:</label>
							<span class="detail-field">#qAttachmentInfo#</span>
						</cfif>
					</div>
				</div>

				<!--- Second column --->
				<div class="detail-col">
					<div class="table-row">
						<label>Title:</label>
						<span class="detail-field">#qProgramDetails.Contract_Title#</span>
					</div>
					<div class="table-row">
						<label>RSP:</label>
						<span class="detail-field">#qProgramDetails.Responsible_Sales_Person# (#qProgramDetails.RSP_Position_Label#)</span>
					</div>
					<div class="table-row">
						<cfif qProgramDetails.delivery_period_date_span NEQ "">
							<label>#general_labels[ delivery_period ]#:</label>
							<span class="detail-field">#qProgramDetails.delivery_period_date_span#</span>
						</cfif>
					</div>
					<div class="table-row">
						<cfif qProgramDetails.contract_reference_number NEQ "">
							<label>Reference:</label>
							<span class="detail-field">#qProgramDetails.contract_reference_number#</span>
						</cfif>
					</div>
					<div class="table-row">
						<cfif isDefined("qInterfaceInfo") AND (qInterfaceInfo NEQ "")>
							<label>Interface info:</label>
							<cfset qInterfaceInfoTrimmed = trim(replace(qInterfaceInfo, chr(13) & chr(10), "<br>", "ALL"))>
							<span class="detail-field">#qInterfaceInfoTrimmed#</span>
						</cfif>
					</div>
					<!--- Check if the current version is a revision --->
					<cfif (qProgramDetails.Revision_of_Contract_Main_ID NEQ "" AND qProgramDetails.Is_A_Revision EQ 1)>
						<!--- If the string "Ack ID" exists in the Interface info --->
						<cfif findNoCase("Ack ID",qInterfaceInfo) GT 0>
						<div class="table-row">
							<label></label>	<!--- Empty --->
							<span class="detail-field">
							<cfoutput>
								<a href="##" onclick="javascript:openPriorVersionInfo('#qProgramDetails.Contract_Main_ID#','#qProgramDetails.Contract_Number#');" title="Click for prior version interface info" class="addLink">#application.util.string.linkFormat("prior version interface info")#</a>
							</cfoutput>
							</span>
						</div>
						</cfif>
					</cfif>
				</div>
			</div>
			<br>
		</cfif>

		<!--- ************************ WorkFlow Info  ************************ --->
		<cfset wfLen = ArrayLen(aWorkFlowData)>
		<cfif isDefined("aWorkFlowData") AND (wfLen NEQ 0)>
			<br>
			<div class="section-header">WORKFLOW</div> <hr class="section-rule">
			<br>
			<cfif wfLen GT 1> <cfset wfHeight = "100"><cfelse><cfset wfHeight = "50"></cfif>
			<div id="workflowGrid" style="margin-left:25px; height:#wfHeight#px; width:720px" class="ag-theme-balham"></div>
		</cfif>


		<!--- ************************ CRA Info  ************************ --->
		<cfif qCRA.recordcount gt 0>
			<br><br>
			<div class="section-header">CRA (Currently Responsible for Approval)</div><hr class="section-rule">
			<br>
			<div id="CRAGrid" style="margin-left:25px; height: 100px;width:550px" class="ag-theme-balham"></div>
		</cfif>


		<!--- ************************ NRA Info  ************************ --->
			<cfif (qCRA.recordcount gt 0) AND (qNRA.recordcount gt 0)>
			<br>
			<div class="section-header">NRA</div><hr class="section-rule">
			<div style="margin-bottom: 2px; margin-left:25px">after the above person(s) take action, below is a list of person(s) that may need to take approval action.</div>

			<div id="NRAGrid" style="margin-left:25px; height: 100px;width:550px" class="ag-theme-balham"></div>
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
		// Setup the Workflow Grid
		var workflowRowData = [{}];
		<cfoutput> #toScript(aWorkFlowData, "workflowRowData")#; </cfoutput>

		var workflowColumnDefs = [
			{headerName: "Action", field: "action", width:65},
			{headerName: "Name", field: "name", width:130},
			{headerName: "Position", field: "position", width:125},
			{headerName: "Profile", field: "profiles_desc", width:110},
			{headerName: "Authority Sequence", field: "authority_sequence_name", width:150},
			{headerName: "Date", field: "action_date", width:115}
		];
		// Init Workflow grid
		var workflowGridOptions = {
			 columnDefs: workflowColumnDefs
			,rowData: workflowRowData
			,rowModelType: "clientSide"
			,cacheBlockSize: 2000
			,debug: false
		};
		ag_grid_default(workflowGridOptions);		// set up default features
		init_ag_grid( workflowGridOptions, "#workflowGrid", false );


		// Setup the CRA Grid
		<cfif qCRA.recordcount gt 0>
			var CRAColumnDefs = [
				{headerName: "Name", field: "user_full_name", width:140},
				{headerName: "Position", field: "position_label", width:125},
				{headerName: "Profile", field: "profiles_desc", width:110},
				{headerName: "Authority Sequence", field: "authority_sequence_name", width:150}
			];
			// Init CRA grid
			var CRAGridOptions = {
				columnDefs: CRAColumnDefs
				,rowData: <cfoutput>#application.util.query.toAgGridJSON(qCRA, 'User_Full_Name, Position_Label, Profiles_Desc, Authority_Sequence_Name')#</cfoutput>
				,rowModelType: "clientSide"
				,cacheBlockSize: 2000
				,debug: false
			};
			ag_grid_default(CRAGridOptions);		// set up default features
			init_ag_grid( CRAGridOptions, "#CRAGrid", false );


			// Setup the NRA Grid
			<cfif qNRA.recordcount gt 0>
				var NRAColumnDefs = [
					{headerName: "Name", field: "user_full_name", width:140},
					{headerName: "Position", field: "position_label", width:125},
					{headerName: "Profile", field: "profiles_desc", width:110},
					{headerName: "Authority Sequence", field: "authority_sequence_name", width:150}
				];
				// Init NRA grid
				var NRAGridOptions = {
					columnDefs: NRAColumnDefs
					,rowData: <cfoutput>#application.util.query.toAgGridJSON(qNRA, 'User_Full_Name, Position_Label, Profiles_Desc, Authority_Sequence_Name')#</cfoutput>
					,rowModelType: "clientSide"
					,cacheBlockSize: 2000
					,debug: false
				};
				ag_grid_default(NRAGridOptions);		// set up default features
				init_ag_grid( NRAGridOptions, "#NRAGrid", false );
			</cfif> <!--- NRA --->
		</cfif> <!--- CRA --->
	</script>
	<cfinclude template="/common_files/focus.cfm">
</body>
</html>
