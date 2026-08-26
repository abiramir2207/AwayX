<!--
  * ====================================================================================================
  *  @Author: Chris Nguyen
  *    @Date: 2018-05-10 11:20:28
  *
  * @Remarks:
  *
  *
  *
  *
  * ====================================================================================================
-->
<cf_include files="/script/javascript/multipleselect/1.2/multiple-select_bsa.js, /script/javascript/multipleselect/1.2/multiple-select.css, /Common_Files/dhx_message.cfm">
	<style>
		body {
			/* font-size: 10px; */
		}
		div.filter {
			margin-bottom: 2px;
			width: 100%;
		}
			div.filter > i.label {
				font-style: normal;
				display: inline-block;
				margin-left: 4px;
				width: 25%;
			}
			div.filter > input {
				border: solid 1px #c4c5c7;
				border-radius: 3px;
				height: 16px;
				width: 70%;
			}
			div.filter > select {
				border: solid 1px #c4c5c7;
				border-radius: 3px;
				height: 16px;
			}
			div.filter > input.date {
				padding-left: 3px;
				width: 56px;
			}
		.active-panel {
			background-color: #f5f6fa;
			border-color: #d8d9dd;
			border-radius: 0 0 8px 8px;
			border-style: solid;
			border-width: 0px 1px 1px 1px;
			min-height: 430px;
			padding-top:5px;
			padding-left:4px;
			padding-right:4px;
			width: 100%;
		}
		select[multiple] {
			height: 12px;
			width: 100%;
		}
		/* Customize the multiple select style */
		.ms-drop ul {
			padding: 0px 8px;	/* default padding: 5px 8px; */
		}
		.ms-choice {
			height: 20px;		/* default 26px */
			line-height: 20px;	/* default 26px */
			color: #343540;
			font-size: 8pt;
		}
		.ms-choice > div {
			height: 19px;		/* default 25px */
			top: -2px;			/* center arrow vertically */
		}
		.ms-choice > span.placeholder {
			font-size: 8pt;
			color: #343540;
			opacity: 0.5;
		}
	</style>

	<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
	<CFSET getSettingsManagerProfiles = CreateObject("component", "components.settings.settings_management.TemplateSettingsManager").getProfileSettings()>
	<cfscript>
		// filters configuration
		// config.filters = "";
		config.filters = "discount_type";
		appSettings = application.appSettingsGet;

		param name="form.program_search"      default="";
		param name="form.distributor_search"  default="";
		param name="form.operator_search"     default="";
		param name="form.item_search"         default="";
		param name="form.status_list"         default="";
		param name="form.template_list"       default="";
		param name="form.rsp_list"            default="";
		param name="form.buying_group_list"   default="";
		param name="form.family_list"         default="";
		param name="form.condition_list"      default="";
		param name="form.workflow_steps_list" default="";
		param name="form.user_list"           default="";
		param name="form.user_position_list"  default="";
		param name="form.action_list"         default="";
		param name="form.budget_class_list"   default="";
		param name="form.business_segment"    default="";
		param name="form.from_date"	          default="#dateformat(DateAdd('d',- appSettings.getExpiredRecentlyDays(),now()),'m/d/yyyy')#";
		param name="form.to_date"             default="";
		param name="form.show_catalog"     default="";

		param name="form.discount_type"				default="";
		param name="form.fixed_discount_types"		default="";
		param name="form.rebate_discount_types"		default="";
		param name="form.lump_sum_discount_types"	default="";
		param name="form.growth_discount_types"     default="";
		param name="form.rate_val"     				default="";
		param name="form.rate_compare"     			default="";
		param name="form.rate_uom"     				default="";

		objSearchProgram  = CreateObject("component", "mvc.Models.Program.Search_Program");
		objProgramList    = CreateObject("component", "mvc.Models.Program.ProgramList");
		stProgramSettings = objSearchProgram.getProgramSettingsObject(request.AccessStructure.user_id);

		qFavorites       = objProgramList.getFavoriteProgramList(request.AccessStructure.user_id);
		qStatusList      = objSearchProgram.getAllStatus();
		qTemplatesList   = objSearchProgram.getAllTemplate();
		qUsersList       = objSearchProgram.getUsersAndPositions();
		qBuyingGroups    = objSearchProgram.getAllBuyingGroups();
		qFamilyNames     = objSearchProgram.getAllFamilyNames();
		qUserPositions   = objSearchProgram.getAllUserPositions();
		arrWorkflowSteps = ["Created By", "RFA By", "CRA", "Approved By"];
		qBudgetClasses   = objSearchProgram.getBudgetClasses();
		qBusinessSegments  = objSearchProgram.getBusinessSegments();
		default_from_date = dateformat(DateAdd('d',- appSettings.getExpiredRecentlyDays(),now()),'m/d/yyyy');
		// <!--- Conditions --->
		arrConditions = [
			 {conditionId = 1, condition = "Auto renew"}
			,{conditionId = 2, condition = "Auto renew pairs"}
			,{conditionId = 4, condition = "Cancelled"}
			,{conditionId = 5, condition = "Disagreed"}
			,{conditionId = 6, condition = "Doc attached"}
			,{conditionId = 7, condition = "Not Cancelled"}
			,{conditionId = 8, condition = "Revision"}
			,{conditionId = 9, condition = "Expiring No Revision"}
		];

		if(stProgramSettings.bestplanon eq 1){
			arrayAppend(arrConditions,{conditionId = 3, condition = "Best Plan Programs"});
		}
		if (application.appSettingsget.getrolloverprograms_on()){
			arrayAppend(arrConditions,{conditionId = 10, condition = "Rollover"});
		}
		if (application.appSettingsget.getReleaseSettlement()) {
			arrayAppend(arrConditions,{conditionId = 11, condition = "Released"});
			arrayAppend(arrConditions,{conditionId = 12, condition = "Not Released"});
		}
		if (application.appsettingsget.getProgramLockTypeID()) {
			arrayAppend(arrConditions,{conditionId = 13, condition = "Acknowledged"});
			arrayAppend(arrConditions,{conditionId = 14, condition = "Not Acknowledged"});
		}
			arrayAppend(arrConditions,{conditionId = 15, condition = "Uploaded"});
			arrayAppend(arrConditions,{conditionId = 16, condition = "Restrict from BB = No"});
			arrayAppend(arrConditions,{conditionId = 17, condition = "Restrict from BB = Yes"});


		// <!--- numeric sort on "conditionId". This way the entries will always be displayed numericallly by conditionId" --->
		arraySort(arrConditions,
			function (e1, e2){
				if (e1.conditionId lt e2.conditionId)
					return -1;
				else if (e1.conditionId eq e2.conditionId)
					return 0;
				else
					return 1;
		});

		// <!--- Actions --->
		arrActions = [
			{actionId = 1, action = "Delete"}
		];

		if (objSearchProgram.getIsBidRequest() eq 1)
			arrayAppend(arrActions,{actionId = 2, action = "Edit Won/Lost Status"});

		if (get_profile_settings.mass_rfa_program_approve)
			arrayAppend(arrActions,{actionId = 3, action = "Mass Approve"});

		if (application.appsettingsget.getReleaseSettlement() AND get_profile_settings.Release_Settlement)
			arrayAppend(arrActions,{actionId = 4, action = "Release"});

		// <!--- Status --->
		arrStatus = [];

		for (i = 1; i <= qStatusList.recordCount; i++) {
			arrayAppend(arrStatus,{statusID = qStatusList.contract_status_type_id[i] , status =  qStatusList.Contract_Status_Type_Desc[i]});
		}

		if (get_profile_settings.rfa_agreed) {
			arrayAppend(arrStatus,{statusID = 101, status = "Agreed"});
			arrayAppend(arrStatus,{statusID = 102, status = "Pending Approval"});
			arrayAppend(arrStatus,{statusID = 103, status = "Under Review"});
		}

		arrayAppend(arrStatus,{statusID = 104, status = "Approved"});

		if (application.appsettingsget.getPgmPostApprovalStatus()) {
			arrayAppend(arrStatus,{statusID = 105, status = "Pending ERP Research"});
			arrayAppend(arrStatus,{statusID = 106, status = "Pending ERP Entry"});
		}

		// <!--- Template --->
		templateList = quotedValueList(qTemplatesList.Created_Type);

		// <!--- Users --->
		usersList = quotedValueList(qUsersList.User_Name);
	</cfscript>

	<cfoutput>

	<cfset prgSearchKeywords = "Keyword search on any of the fields:&##13; ID, Title, #application.returned_customer_setting.reference_number_label#">

	<cfif appSettings.getView_Legacy_ID() eq 1>
		<cfset prgSearchKeywords = ListAppend(prgSearchKeywords, 'Legacy ID',",")>
	</cfif>

	<cfsavecontent variable="filter_content">
	<!--- For loading data, we do not need to post this form as we use AJAX, but for "download data", we post this form and so we have the action set to "/Common_Files/exportAll.cfm". --->
		<form name="frmPrograms" class="active-panel" method="post" action="/Common_Files/exportAll.cfm">

		<div class="filter" title="#prgSearchKeywords#"><i class="label">Program</i><input type="text" name="program_search" id="program_search" size="30" value="#form.program_search#"></div>

		<div class="filter" title="Keyword search on any of the fields:&##13;#application.returned_customer_setting.shard_ship_to_label#, Name, City, State,&##13;#application.returned_customer_setting.family_name_label_singular# ID, #application.returned_customer_setting.family_name_label_singular# Name,&##13;#application.returned_customer_setting.buying_group_label_singular# ID, #application.returned_customer_setting.buying_group_label_singular# Name">
			<i class="label"><cfif application.returned_customer_setting.distributor_label_singular neq"">#application.returned_customer_setting.distributor_label_singular#<cfelse>Distributor</cfif></i><input type="text" name="distributor_search" id="distributor_search" size="30" value="#form.distributor_search#">
		</div>
		<div class="filter" title="Keyword search on any of the fields:&##13; ID, Name, City, State, Zip, Location Type"><i class="label">#application.returned_customer_setting.operator_label_singular#</i><input type="text" name="operator_search" id="operator_search" size="30" value="#form.operator_search#"></div>
		<div class="filter" title="Keyword search on any of the fields:&##13; #application.returned_customer_setting.item_label#, Description, Brand Name, #application.returned_customer_setting.q_brand_label_singular#,&##13;#application.returned_customer_setting.type_code_label_singular#, #application.returned_customer_setting.type_group_label_singular#"><i class="label">#application.returned_customer_setting.item_label#</i><input type="text" name="item_search" id="item_search" size="30" value="#form.item_search#"></div>
	<cfif local.External_Customer_Profile_Access eq 0>
		<div class="filter" title="select a search that you saved">
			<select name="favorite_list" id="favorite_list">
				<cfloop query="qFavorites">
					<option value="#User_Program_List_ID#">#List_Name#</option>
				</cfloop>
			</select>
		</div>
	</cfif>
		<div class="filter" title="filter: Program Status">
			<select name="status_list" id="status_list" multiple="multiple" style="width:99%;">
				<cfscript>
					ArrayEach(arrStatus,function(stStatus){
						writeOutput('<option value=#stStatus["statusId"]#>#stStatus["status"]#</option>');
					 });
				</cfscript>
			</select>
		</div>
		<div class="filter" title="filter: Program Template">
			<select name="template_list" id="template_list" multiple="multiple">
				<cfloop query="qTemplatesList">
					<option value="#qTemplatesList.First_Parent_ID#">#qTemplatesList.Created_Type#</option>
				</cfloop>
			</select>
		</div>
		<div class="filter" title="filter: Responsible Sales Person">
			<select name="rsp_list" id="rsp_list" multiple="multiple">
				<cfloop query="qUsersList">
					<cfif qUsersList.Is_Eligible_RSP eq 1>
					<option value="#qUsersList.User_ID#">#qUsersList.User_Name#</option>
					</cfif>
				</cfloop>
			</select>
		</div>

		<div class="filter" title="filter:#application.returned_customer_setting.buying_group_label_singular#">
			<select name="buying_group_list" id="buying_group_list" multiple="multiple">
				<cfloop query="qBuyingGroups">
					<option value="#qBuyingGroups.Buying_Group_ID#">#qBuyingGroups.Buying_Group_Name#</option>
				</cfloop>
			</select>
		</div>

		<div class="filter" title="filter:#application.returned_customer_setting.family_name_label_singular#">
			<select name="family_list" id="family_list" multiple="multiple">
				<cfloop query="qFamilyNames">
					<option value="#qFamilyNames.Family_ID#">#qFamilyNames.Family_Name#</option>
				</cfloop>
			</select>
		</div>
	<cfif local.External_Customer_Profile_Access eq 0>
		<div class="filter" title="filter: Conditions">
			<select name="condition_list" id="condition_list" multiple="multiple">
				<cfscript>
					ArrayEach(arrConditions,function(stCondition){
						writeOutput('<option value=#stCondition["conditionId"]#>#stCondition["condition"]#</option>');
					 });
				</cfscript>
			</select>
		</div>

		<div class="filter" title="filter: Workflow step">
			<select name="workflow_steps_list" id="workflow_steps_list" multiple="multiple" onChange="errorValidation();">
				<cfloop from="1" to="#ArrayLen(arrWorkflowSteps)#" index="i">
					<option value="#i#">#arrWorkflowSteps[i]#</option>
				</cfloop>
			</select>
		</div>
		<div class="filter" title="filter: User Position of">
			<select name="user_list" id="user_list" multiple="multiple" onChange="setPosition();errorValidation();">
				<cfloop query="qUsersList">
					<option value="#qUsersList.User_ID#" userPositionsID="#qUsersList.User_Positions_ID#">#qUsersList.User_Name#</option>
				</cfloop>
			</select>
		</div>
		<div class="filter" title="filter: User Position">
			<select name="user_position_list" id="user_position_list" multiple="multiple" onChange="resetUserList();errorValidation();">
				<cfloop query="qUserPositions">
					<option value="#qUserPositions.User_Positions_ID#">#qUserPositions.Position_Label_And_ID#</option>
				</cfloop>
			</select>
		</div>
		<div class="filter" title="Select Program Actions">
			<select name="action_list" id="action_list" multiple="multiple">
				<cfscript>
					ArrayEach(arrActions,function(stAction){
						writeOutput('<option value=#stAction["actionId"]#>#stAction["action"]#</option>');
					 });
				</cfscript>
			</select>
		</div>
		<cfif stProgramSettings.showbudgetDropdown>
		<div class="filter" title="filter: Budget Classes">
			<select name="budget_class_list" id="budget_class_list" multiple="multiple">
				<cfloop query="qBudgetClasses">
					<option value="#qBudgetClasses.Budget_Class_ID#">#qBudgetClasses.Budget_Class_Desc#</option>
				</cfloop>
			</select>
		</div>
		</cfif>
		<cfif stProgramSettings.businesssegmenton>
		<div class="filter" title="filter: #application.appsettingsget.getbusiness_segment_label()#">
			<select name="business_segment" id="business_segment" multiple="multiple">
				<cfloop query="qBusinessSegments">
					<option value="#qBusinessSegments.Business_Segment_ID#">#qBusinessSegments.Business_Unit_Desc#</option>
				</cfloop>
			</select>
		</div>
		</cfif>

		<cfquery datasource="#application.datasource#" name="qDiscounts">
			SELECT *
			  FROM Discount_Type
			 WHERE Discount_Type_ID IN (1, 2, 3, 4) AND Deleted = 0
		</cfquery>

		<!--- ngt --->
		<cfif listFindNoCase(config.filters, "discount_type")>
			<div class="filter" title="filter: Discount Type">
				<select name="discount_type" id="discount_type" multiple="multiple">
					<option></option>
					<cfloop query="qDiscounts">
						<option value="#qDiscounts.Discount_Type_ID#">#qDiscounts.Discount_Type_Desc#</option>
					</cfloop>
				</select>
			</div>

			<div class="filter hidden" title="filter: Fixed Discount Types" name="fixed_discount_types">
				<cfquery datasource="#application.datasource#" name="qDiscounts">
					SELECT Program_Fixed_Component_Name_ID, Program_Fixed_Component_Name
					FROM Program_Fixed_Component_Name cn
					WHERE cn.Deleted = 0
							ORDER BY Program_Fixed_Component_Name
				</cfquery>
				<select name="fixed_discount_types" id="fixed_discount_types" multiple="multiple" class="discount_type">
					<cfloop query="qDiscounts">
						<option value="#qDiscounts.Program_Fixed_Component_Name_ID#">#qDiscounts.Program_Fixed_Component_Name#</option>
					</cfloop>
				</select>
			</div>

			<div class="filter hidden" title="filter: Rebate Discount Types" name="rebate_discount_types">
				<cfquery datasource="#application.datasource#" name="qDiscounts">
					SELECT Program_Rebates_Component_Name_ID, Program_Rebates_Component_Name
					FROM Program_Rebates_Component_Name cn
					WHERE cn.Deleted = 0
							ORDER BY Program_Rebates_Component_Name
				</cfquery>
				<select name="rebate_discount_types" id="rebate_discount_types" multiple="multiple" class="discount_type">
					<cfloop query="qDiscounts">
						<option value="#qDiscounts.Program_Rebates_Component_Name_ID#">#qDiscounts.Program_Rebates_Component_Name#</option>
					</cfloop>
				</select>
			</div>

			<div class="filter hidden" title="filter: Lump Sum Discount Types" name="lump_sum_discount_types">
				<cfquery datasource="#application.datasource#" name="qDiscounts">
					SELECT Program_Lump_Sum_Name, Program_Lump_Sum_Name_ID
					FROM Program_Lump_Sum_Name cn
					WHERE cn.Deleted = 0
							order by Program_Lump_Sum_Name
				</cfquery>
				<select name="lump_sum_discount_types" id="lump_sum_discount_types" multiple="multiple" class="discount_type">
					<cfloop query="qDiscounts">
						<option value="#qDiscounts.Program_Lump_Sum_Name_ID#">#qDiscounts.Program_Lump_Sum_Name#</option>
					</cfloop>
				</select>
			</div>

			<div class="filter hidden" title="filter: Growth Discount Types" name="growth_discount_types">
				<cfquery datasource="#application.datasource#" name="qDiscounts">
					SELECT Program_Growth_Components_Name, Program_Growth_Components_Name_id
					FROM Program_Growth_Components_Name cn
					WHERE cn.Deleted = 0
							ORDER BY Program_Growth_Components_Name
				</cfquery>
				<select name="growth_discount_types" id="growth_discount_types" multiple="multiple" class="discount_type">
					<cfloop query="qDiscounts">
						<option value="#qDiscounts.Program_Growth_Components_Name_ID#">#qDiscounts.Program_Growth_Components_Name#</option>
					</cfloop>
				</select>
			</div>
			<div class="filter" title: "filter: Rate comparison" style="margin-left: 8px;">
				Rate:
				<select name="rate_compare" id="rate_compare" style="width: 30% !important;">
					<option value=""></option>
					<option value="Greater_Or_Equal">&gt;=</option>
					<option value="Equal">=</option>
					<option value="Less_Or_Equal">&lt;=</option>
				</select>
				<input type="text" name="rate_val" id = "rate_val" Title="Enter a Rate" style="width:80px;" />
				<br>
			</div>
			<div class="filter" title="filter: UOM">
					<cfquery datasource="#application.datasource#" name="qUOM">
					SELECT Unit_Of_Measure_ID,
						Unit_Of_Measure_Desc,
						Abbreviation,
						Display_Order,
						External_Id,
						Unit_of_Measure_Desc_Singular,
						Abbreviation_Singular
					FROM dbo.Units_of_Measure
					ORDER BY Unit_Of_Measure_ID
					</cfquery>
				<select name="rate_uom" id="rate_uom" multiple="multiple">
					<cfloop query="qUOM">
						<option value="#qUOM.Unit_Of_Measure_ID#">#qUOM.Unit_Of_Measure_Desc# (#trim(qUOM.Abbreviation)#)</option>
					</cfloop>
				</select>
			</div>
		</cfif>     <!--- <cfif listFindNoCase(config.filters, "discount_type")> --->

		<!--- Show the "Data Source" dropdown. only when we have "catalog" profile setting ON. If it is OFF, there is no need to show the dropdown, just for one option --->
		<cfif get_profile_settings.read_only_catalog_access OR appSettings.get_Setting('Retail_Planner') EQ '1'>
			<div class="filter" title="filter: Data source">
				<select name="show_catalog" id="show_catalog" multiple="multiple">
					<option value="0">Data source: Programs</option>
					<option value="1">Data source: Catalog</option>
					<cfif appSettings.get_Setting('Retail_Planner') EQ '1' AND get_profile_settings.Planner_Create NEQ 0>
					<option value="2" selected="selected">Data source: Programs & Events</option>
					<option value="3">Data source: Events</option>
					</cfif>
				</select>
			</div>
		</cfif>

		<div class="filter" style="margin-left: 8px; margin-top:5px;">
			Date Range
			<input name="from_date" id="from_date" type="text" class="date" value="#form.from_date#"> to
			<input name="to_date" id="to_date" type="text" class="date" value="#form.to_date#">
		</div>
	</cfif>
		<div style="margin-top:10px; margin-bottom:10px;">
			<button type="button" onClick="filterData('MainSearch');" title="search using the selected filters" class="button recommended" style="margin:0 4px;">search</button>
			<button type="button" onClick="resetOptions();" title="clear the filters" class="button alt" style="margin:0 4px;">reset</button>
		<cfif local.External_Customer_Profile_Access eq 0>
			<button type="button" onClick="saveFavorites();" title="save the filters for your future use" class="button alt" style="margin:0 4px;">save</button>
		</cfif>
		</div>

		<input type="hidden" name="searchType" id="searchType" value="MainSearch">

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~ pass url.refresh_data=1 to load most recent data into the cache ~~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <cfparam name="url.refresh_data" default="0">
		<input type="hidden" name="refreshData" id="refreshData" value="#Val(url.refresh_data)#">
		<input type="hidden" name="type" value="getProgramsData">
		<input type="hidden" name="friendlyFileName" value="Program_List">
		<input type="hidden" name="Include_Operator_In_CSV" id="Include_Operator_In_CSV" value="1">
	</form>

	<form action="/Scorecard/masseditstatus.cfm" method="post" name="editStatusForm" id="editStatusForm">
		<input type="Hidden" name="massEditStatusList" id="massEditStatusList" value="" />
		<input type="Hidden" name="FromAGGrid" value="1" />
	</form>

	<form action="/scorecard/massapproval.cfm" method="post" name="massApprovalForm" id="massApprovalForm">
		<input type="Hidden" name="massApprovalProgramList" id="massApprovalProgramList" value="" />
		<input type="Hidden" name="FromAGGrid" value="1" />
	</form>

	<form action="/common_files/contracts/release_settlement.cfm" method="post" name="releaseSettlementForm" id="releaseSettlementForm">
	   <input type="hidden" name="ListContractMainID" id="ListContractMainID" value="" />
	   <input type="hidden" name="FromAGGrid" value="1" />
	</form>
	</cfsavecontent>
	#application.util.string.compress(filter_content)#

	<script>
	let userSelectionError = 0;
	let workflowrSelectionError = 0;

	function errorValidation(){
		/* If an option from "workflow" dropdown is selected, but none of the options from either the user or user positions dropdown is selected. */
		var drpWorkflow = $("select[name=workflow_steps_list]");
		var drpUserPosition = $("select[name=user_position_list]");
		var drpUserList = $("select[name=user_list]");

		if(
		(drpWorkflow.multipleSelect('getSelects').toString() !='')
		&&
		(drpUserPosition.multipleSelect('getSelects').toString() == '' && drpUserList.multipleSelect('getSelects').toString() == '')
		)
		{	/* set the border color for the dropdowns to "red" */
			drpUserList.multipleSelect('validation');
			drpUserPosition.multipleSelect('validation');
			userSelectionError = 1;
		}
		else
		{
			/* remove the border color */
			drpUserList.multipleSelect('clearValidation');
			drpUserPosition.multipleSelect('clearValidation');
			userSelectionError = 0;
		}

		if(
		(drpUserPosition.multipleSelect('getSelects').toString() != '' || drpUserList.multipleSelect('getSelects').toString() != '')
		&&
		(drpWorkflow.multipleSelect('getSelects').toString() =='')
		)
		{	/* set the border color for the dropdowns to "red" */
			drpWorkflow.multipleSelect('validation');
			workflowrSelectionError = 1;
		}
		else
		{
			/* remove the border color */
			drpWorkflow.multipleSelect('clearValidation');
			workflowrSelectionError = 0;
		}
		if((drpUserPosition.multipleSelect('getSelects').toString() != '') && (workflowrSelectionError == 1))
		{
			$("select[name=workflow_steps_list]").multipleSelect('setSelects','1');
			drpWorkflow.multipleSelect('clearValidation');
			workflowrSelectionError = 0;
		}
	}

	function filterData(search_type, refresh_data)
	{
		var dType 		= $("select[name=discount_type]");
		var dFixedDT 	= $("select[name=fixed_discount_types]");
		var dRebateDT	= $("select[name=rebate_discount_types]");
		var dLSDT 		= $("select[name=lump_sum_discount_types]");
		var dGrowthDT 	= $("select[name=growth_discount_types]");
		var dUOMs 		= $("select[name=rate_uom]");
		var dCond 		= $("select[name=condition_list]");
		var tRate 		= $("input[name=rate_val]").val();
		var dRCompare 	= $("select[name=rate_compare]");

		/*
		var dShowCatalog = $("select[name=show_catalog]");
		var iShowCatVal = dShowCatalog.multipleSelect('getSelects').toString()
		$('input[name=iShowCatalog]').val(iShowCatVal);
		alert('iShowCatalog val is:');
		alert($('input[name=iShowCatalog]').val());
		// alert(dShowCatalog.multipleSelect('getSelects').toString()));
		*/
		/* "MainSearch" is for search from main page "Search tab" and "ListSearch" is search from the "list" tab. */
		$( '##searchType' ).val(search_type);

		var bRefreshData = 0;
		if(refresh_data) bRefreshData = 1;
		$( '##refreshData' ).val(bRefreshData);

		let errorMessage = '';
		if( $('##from_date').val() != '' && $('##to_date').val() != ''){
			if( (Date.parse($('##to_date').val())) < (Date.parse($('##from_date').val())) ){
				errorMessage = errorMessage.concat('The end date must be after the start date\n')
			}
		}

		errorValidation();

		if(userSelectionError==1)
		{
			errorMessage = errorMessage.concat('Please select a user or user position. \n');
		}
		if(workflowrSelectionError==1)
		{
			errorMessage = errorMessage.concat('Please select an option from workflow. \n');
		}

		 if (dType.multipleSelect('getSelects').toString() == '1' &&  dFixedDT.multipleSelect('getSelects').toString() == '' )
		{
			errorMessage = errorMessage.concat('Please select a Fixed Price Component. \n');
		}
		 if (dType.multipleSelect('getSelects').toString() == '2' &&  dRebateDT.multipleSelect('getSelects').toString() == '' )
		{
			errorMessage = errorMessage.concat('Please select a Rebate Component. \n');
		}
		 if (dType.multipleSelect('getSelects').toString() == '3' &&  dLSDT.multipleSelect('getSelects').toString() == '' )
		{
			errorMessage = errorMessage.concat('Please select a LumpSum Component. \n');
		}
		 if (dType.multipleSelect('getSelects').toString() == '4' &&  dGrowthDT.multipleSelect('getSelects').toString() == '' )
		{
			errorMessage = errorMessage.concat('Please select a Growth Component. \n');
		}
		if (dType.multipleSelect('getSelects').toString() == '' &&  dUOMs.multipleSelect('getSelects').toString() != '' )
		{
			errorMessage = errorMessage.concat('Please select a Discount Type. \n');
		}
		if (((dCond.multipleSelect('getSelects').toString().indexOf('16') != -1) || (dCond.multipleSelect('getSelects').toString().indexOf('17') != -1)) &&  dType.multipleSelect('getSelects').toString() == '' )
		{
			errorMessage = errorMessage.concat('Please select a Discount Type. \n');
		}

        let rate_compare_operator = dRCompare.val();
		if (dType.multipleSelect('getSelects').toString() === '' && (tRate !== '' || rate_compare_operator))
		{
			errorMessage = errorMessage.concat('Please select a Discount Type. \n');
		}

		if(errorMessage.length){
			alert(errorMessage);
			return;
		}
		else{
			// remove leading/trailing blank spaces prior to server submission
			$("input[name=program_search], input[name=distributor_search], input[name=operator_search], input=[name=item_search], input=[rate_val]").each(function(){
				let new_value = $(this).val().trim();
				$(this).val( new_value );
			});
			gridOptions.api.onFilterChanged();
			showHideLinks();
		}
	}

	$("select[name=favorite_list]").change(function() {
		let list_id = $("select[name=favorite_list]").multipleSelect('getSelects').toString();
		if(list_id != ''){
			$.ajax({type    : "post"
					,url     : "/mvc/Models/Program/ProgramList.cfc"
					,dataType: "json"
					,data: { method: "getSavedUserProgramFavorite"
							,listID: list_id
							}
					,success : function (response) {
							$("select[name=status_list]").multipleSelect('setSelects',response.STATUS);
							$("select[name=template_list]").multipleSelect('setSelects',response.TEMPLATE);
							$("select[name=rsp_list]").multipleSelect('setSelects',response.RSP);
							$("select[name=buying_group_list]").multipleSelect('setSelects',response.BUYINGGROUP);
							$("select[name=family_list]").multipleSelect('setSelects',response.FAMILY);
							$("select[name=condition_list]").multipleSelect('setSelects',response.CONDITIONS);

							$("select[name=workflow_steps_list]").multipleSelect('setSelects',response.PROGRAMINFO);
							$("select[name=user_list]").multipleSelect('setSelects',response.USERINFO);
							$("select[name=user_position_list]").multipleSelect('setSelects',response.POSITION);
							$("select[name=action_list]").multipleSelect('setSelects',response.REPORTTYPE);
							<cfif stProgramSettings.showbudgetDropdown>
								$("select[name=budget_class_list]").multipleSelect('setSelects',response.BUDGETCLASS);
							</cfif>
							<cfif stProgramSettings.businesssegmenton>
								$("select[name=business_segment]").multipleSelect('setSelects',response.BUSINESSSEGMENT);
							</cfif>
							// 96448: HF Bundle - Program Search - New Filtering Options - Anand Rao/23-Oct-2020
							$("select[name=discount_type]").multipleSelect('setSelects',response.DISCOUNT_TYPE);
							$("select[name=fixed_discount_types]").multipleSelect('setSelects',response.FIXED_DISCOUNT_TYPES);
							$("select[name=rebate_discount_types]").multipleSelect('setSelects',response.REBATE_DISCOUNT_TYPES);
							$("select[name=lump_sum_discount_types]").multipleSelect('setSelects',response.LUMP_SUM_DISCOUNT_TYPES);
							$("select[name=growth_discount_types]").multipleSelect('setSelects',response.GROWTH_DISCOUNT_TYPES);
							$("select[name=rate_compare]").val(response.RATE_COMPARE);
							$("select[name=rate_uom]").multipleSelect('setSelects',response.RATE_UOM);
							$('##rate_val').val(response.RATE_VAL);

							<cfif get_profile_settings.read_only_catalog_access OR appSettings.get_Setting('Retail_Planner') EQ '1'>
								$("select[name=show_catalog]").multipleSelect('setSelects',response.DATASOURCE);
							</cfif> 

							$('##program_search').val(response.PROGRAM_INFO);
							$('##distributor_search').val(response.DISTRIBUTOR_INFO);
							$('##operator_search').val(response.OPERATOR_INFO);
							$('##item_search').val(response.ITEM_INFO);

							filterData('MainSearch');
					}
			});
		}
	})

	function deleteEntry(){
		$(document).on('click','.deleteItem', function () {

			/* find the value of the deleted radio/checkbox button option. We need it to delete that record from the db. */
			let deleted_id = $(this).closest('li').find('input').val();

			/* remove deleted entry from the dropdown */
			$('select[name=favorite_list] option[value=\'' + deleted_id + '\']').remove();
			$("select[name=favorite_list]").multipleSelect('refresh');

			$.ajax({type    : "post"
					,url     : "/mvc/Models/Program/ProgramList.cfc"
					,dataType: "json"
					,data: { method: "deleteUserProgramList"
							,ID: deleted_id
							}
			});
		});
	}

	<!--- Dropdowns --->
	function ms_config(placeholder, deleteOption, single, dropWidth, position) {
		deleteOption = ( deleteOption || false);
		single       = ( single || false );
		dropWidth   = (dropWidth || '230px');
		position   = (position || 'bottom');
		selectAllDelimiter = "[]"

		if(placeholder == ''){
			selectAllDelimiter = '';
		}

		return ({
					 deleteOption: deleteOption
					,filter: true
					,placeholder: placeholder
					,selectAllDelimiter: selectAllDelimiter
					,selectAllText: placeholder
					,single: single
					,width: '99%'
					,dropWidth : dropWidth
					,maxHeight: '200'
					/* position: 'top' will make sure that the dropdown opens up upwards */
					,position: position
				});
	};

	function activate_multipleSelect() {

		$("select[name=status_list]").multipleSelect( ms_config('Show All Status') );
		$("select[name=template_list]").multipleSelect( ms_config('Show All Templates', false, false, '325px') );
		$("select[name=rsp_list]").multipleSelect( ms_config('Show All RSP') );

		$("select[name=buying_group_list]").multipleSelect( ms_config('Show All #application.returned_customer_setting.buying_group_label_singular#', false, false, '350px') );
		$("select[name=family_list]").multipleSelect( ms_config('Show All #application.returned_customer_setting.family_name_label_singular#', false, false, '350px') );
	<cfif local.External_Customer_Profile_Access eq 0>
		$("select[name=favorite_list]").multipleSelect( ms_config( 'Saved Searches', true, true, '325px' ));
		$("select[name=condition_list]").multipleSelect( ms_config('Show All Conditions') );
		$("select[name=workflow_steps_list]").multipleSelect( ms_config('Show All Workflow Steps',false,false,'230px','top') );

		$("select[name=user_list]").multipleSelect( ms_config('Show All Users', false, true,'230px','top' ) );
		$("select[name=user_position_list]").multipleSelect(ms_config( 'Show All Positions', false, false, '425px','top' ));
		$("select[name=action_list]").multipleSelect( ms_config('Select Action', false, true,'230px','top') );

		<cfif stProgramSettings.showbudgetDropdown>
			$("select[name=budget_class_list]").multipleSelect( ms_config('Show All Budget Class',false,false,'230px','top') );
		</cfif>
		<cfif stProgramSettings.businesssegmenton>
			$("select[name=business_segment]").multipleSelect( ms_config('Show All #application.appsettingsget.getbusiness_segment_label()#',false,false,'230px','top') );
		</cfif>
		<cfif get_profile_settings.read_only_catalog_access OR appSettings.get_Setting('Retail_Planner') EQ '1'>
			$("select[name=show_catalog]").multipleSelect(ms_config('',false,true,'230px','top') );
		</cfif>
			<cfif get_profile_settings.Planner_Create EQ 0>
				$("select[name=show_catalog]").multipleSelect('setSelects',['0']);
			<cfelse>
				$("select[name=show_catalog]").multipleSelect('setSelects',['2']);
			</cfif>	
		// ngt
		<cfif listFindNoCase(config.filters, "discount_type")>
			$("select[name=discount_type]").multipleSelect( ms_config('Show All Discount Types', false, true,'230px','top') );
			$("select[name=fixed_discount_types]").multipleSelect( ms_config('Select Fixed Discount Types', false, false,'230px','top') );
			$("select[name=rebate_discount_types]").multipleSelect( ms_config('Select Rebate Discount Types', false, false,'230px','top') );
			$("select[name=lump_sum_discount_types]").multipleSelect( ms_config('Select Lump Sum Discount Types', false, false,'230px','top') );
			$("select[name=growth_discount_types]").multipleSelect( ms_config('Select Growth Discount Types', false, false,'230px','top') );
			$("select[name=rate_uom]").multipleSelect(ms_config('Show All UOMs',false,false,'230px','top') );
		</cfif>
	</cfif>
	}

	let displayTradeDollarsLabel    = '#stProgramSettings.tradeDollarsLabel#';
	let displayPaymentDollarsLabel  = '#stProgramSettings.paymentDollarsLabel#';
	let displayVolumeLabel          = '#stProgramSettings.volumeLabel#';
	let displayBusinessSegmentLabel = '#application.appsettingsget.getbusiness_segment_label()#';

	let selected_programs = '';
	function selectPrograms(){
		selected_programs = '';
		for (var i=0; i<gridOptions.api.getSelectedRows().length; i++){
			selected_programs = selected_programs + gridOptions.api.getSelectedRows()[i].CONTRACT_MAIN_ID
			if(i != (gridOptions.api.getSelectedRows().length -1)){
				selected_programs = selected_programs + ",";
			}
		}
	}

	function deleteProgram(){
		selectPrograms();

		if(selected_programs != ''){
			if(confirm("Are you sure you want to delete selected programs? \n #application.appSettingsget.getDeleteProgramMessage()# (OK = Yes   Cancel = No)")){

				$.ajax({type    : "post"
						,url     : "/mvc/Models/Program/Search_Program.cfc"
						,dataType: "json"
						,data: { method: "deleteProgram"
								,program_id_list: selected_programs
								}

						,success : function (response) {
							let msg = '';
							for(i=0;i<response.RETURNMSG.length; i++){
							msg = msg + response.RETURNMSG[i].SHOW_MSG +  '\n';
							}
							gridOptions.api.onFilterChanged();

						}
				});
			}
		}
		else{
			alert('Please select at least one program to delete');
		}
	}

	function resetOptions(){
		$("select[name=favorite_list],select[name=status_list],select[name=template_list],select[name=rsp_list],select[name=buying_group_list],select[name=family_list],select[name=condition_list],select[name=workflow_steps_list],select[name=user_list],select[name=user_position_list],select[name=action_list]").multipleSelect('uncheckAll');
		$("select[name=workflow_steps_list]").multipleSelect('uncheckAll');
		$("select[name=rate_uom]").multipleSelect('uncheckAll');

		<cfif stProgramSettings.showbudgetDropdown>
			$("select[name=budget_class_list]").multipleSelect('uncheckAll');
		</cfif>
		<cfif stProgramSettings.businesssegmenton>
			$("select[name=business_segment]").multipleSelect('uncheckAll');
		</cfif>
		$('##program_search').val('');
		$('##distributor_search').val('');
		$('##operator_search').val('');
		$('##item_search').val('');

		$('##from_date').val('');
		$('##from_date').val('#default_from_date#');
		$('##to_date').val('');

		$("##delete,##won_loss_status,##mass_approve,##release").hide();

		/* Remove the sorting of column on the grid */
		gridOptions.api.setSortModel(null);

		/* Reset the grid */
		gridOptions.api.onFilterChanged();

		/* When the user selects for "Edit won/loss status" option from the "Action" dropdown,
		a new column titled "Bid Status is added to the grid. We need to hide that column on "reset". */
		gridOptions.columnApi.setColumnVisible('BIDREQUEST_STATUS',false);

		// ngt
		$("div[name=fixed_discount_types], div[name=rebate_discount_types], div[name=lump_sum_discount_types], div[name=growth_discount_types]").hide();
		$("select[name=discount_type], select.discount_type").multipleSelect('uncheckAll');
		$('##rate_val').val('');
		$('##rate_compare').val('');

	}

	let arrWonLossProgramList = [];
	function setWonLossProgramText(obj,programId){
		let wonLossStatusID = 0 ;
		/* 2 is "Won" and 4 is "Lost" */
		let index1 = arrWonLossProgramList.indexOf(programId+'_2');
		let index2 = arrWonLossProgramList.indexOf(programId+'_4');

		if(index1 != -1) {
			arrWonLossProgramList.splice(index1, 1);
		}
		else if (index2 != -1){
			arrWonLossProgramList.splice(index2, 1);
		}

		if($(obj).html() == '[ W ]'){
			$(obj).html('[ L ]');
			wonLossStatusID = 4;
		}
		else{
			$(obj).html('[ W ]');
			wonLossStatusID = 2;
		}

		arrWonLossProgramList.push(programId+'_'+wonLossStatusID);
	}

	function setWonLossProgram(){
		selectPrograms();

		if(selected_programs != ''){
			if(confirm("Press OK to change the selected programs status")){
				editSelectedProgramStatus();
			}
		}
		else{
			alert('Please select at least one program to change the proposal status');
		}
	}

	function setMassApproveProgram(){
		selectPrograms();

		if(selected_programs != ''){
			if(confirm("Press OK to approve the selected programs")){
				massApproveSelectedProgram();
			}
		}
		else{
			alert('Please select at least one program Ready For Approval first');
		}
	}

	function setReleaseProgram(){
		selectPrograms();

		if(selected_programs != ''){
			if(confirm("Press OK to continue")){
				releaseSelectedProgram();
			}
		}
		else{
			alert('Please select at least one program to release');
		}
	}



	function massApproveSelectedProgram(){
		/* Cannot pass values through a URL, because we need to pass a huge number programs as a comma-delimited list. URL has a max size restriction. */
		/* Open a popup with a blank URL. */
		window.open("","winmassapproval","height=600,width=900,toolbar=no,scrollbars=yes,resizable=yes");
		window.massApprovalForm.massApprovalProgramList.value = selected_programs;
		/*Set the target of the blank window to be the form name. This way on form submission,we can submit the form data to the pop-up page. */
		window.massApprovalForm.target="winmassapproval";
		window.massApprovalForm.submit();
	}

	function releaseSelectedProgram(){
		/* Cannot pass values through a URL, because we need to pass a huge number programs as a comma-delimited list. URL has a max size restriction. */
		/* Open a popup with a blank URL. */
		window.open("","releaseSettlement","height=150,width=300,toolbar=no,scrollbars=yes,resizable=yes");
		window.releaseSettlementForm.ListContractMainID.value = selected_programs;
		/*Set the target of the blank window to be the form name. This way on form submission,we can submit the form data to the pop-up page. */
		window.releaseSettlementForm.target="releaseSettlement";
		window.releaseSettlementForm.submit();
	}

	function editSelectedProgramStatus()
	{
        let won_loss = [];

        for (let i=0; i<gridOptions.api.getSelectedRows().length; i++){
			let contract_main_id = gridOptions.api.getSelectedRows()[i].CONTRACT_MAIN_ID;

            // default to won
            // contract_main_id_2 means "Won" & contract_main_id_4 means "Lost"
            let result = "_2";
            // was it reassigned manually to lost?
            if (arrWonLossProgramList.indexOf(contract_main_id + "_4") != -1) {
                result = "_4";
            }
            won_loss.push(contract_main_id + result);
		}

		/* Cannot pass values through a URL, because we need to pass a huge number programs as a comma-delimited list. URL has a max size restriction. */
		/* Open a popup with a blank URL. */
		window.open("","masseditstatus","height=600,width=900,toolbar=no,scrollbars=yes,resizable=yes");
		window.editStatusForm.massEditStatusList.value = won_loss.join();
		/*Set the target of the blank window to be the form name. This way on form submission,we can submit the form data to the pop-up page. */
		window.editStatusForm.target="masseditstatus";
		window.editStatusForm.submit();
	}

	<!--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX Handle for Importing Items	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	function importSelected(){
		selectPrograms();

		if(selected_programs != ''){
			sendItems(selected_programs);
		}
		else{
			alert('Please select at least one program');
		}
	}

	<!--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX Handle for Importing Items	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	function sendItems(s){
	<cfif URL.Formname neq "" and URL.Fieldname neq "">
			opener.document.all.#URL.Formname#.#URL.Fieldname#.value = s;
			if(opener.document.all.#URL.Formname#.display_type)
			{
				opener.document.all.#URL.Formname#.display_type.value = #URL.display_type#;
			}
			opener.document.all.#URL.Formname#.#URL.Fieldname#.value = s;
			opener.document.#URL.Formname#.submit();
		window.close();
	</cfif>
	}

	function showHideLinks(){
		selectedActionOption = $("select[name=action_list]").multipleSelect('getSelects').toString();
        const MAIN_SEARCH    = "MainSearch";
        let search_type      = $('##searchType' ).val();

		if(selectedActionOption == 1 && search_type == MAIN_SEARCH){
			$("##delete").show();
		}
		else{
			$("##delete").hide();
		}

		if (selectedActionOption == 2 && search_type == MAIN_SEARCH){
		    gridOptions.columnApi.setColumnVisible('BIDREQUESTSTATUS',true);
			$("##won_loss_status").show();
		}
		else{
		    gridOptions.columnApi.setColumnVisible('BIDREQUESTSTATUS',false);
			$("##won_loss_status").hide();
		}

		if (selectedActionOption == 3 && search_type == MAIN_SEARCH){
			$("##mass_approve").show();
		}
		else{
			$("##mass_approve").hide();
		}

	    if (selectedActionOption == 4 && (search_type == MAIN_SEARCH || search_type == 'ListSearch')){
			$("##release").show();
		}
		else{
			$("##release").hide();
		}
		/* Empty the array. When the user searches for data, empty the array, as the selected values are no longer valid. */
		arrWonLossProgramList = [];
	}

	function saveFavorites() {
		$.ajax({type    : "post"
				,url     : "/mvc/Models/Program/ProgramList.cfc"
				,dataType: "json"
				,data: { method: "getFavoritesCount"
						,userID: '#request.AccessStructure.user_id#'
						}
				,success : function (response) {
					if(response.FAVORITECOUNT > 25){
						alert("The limit for the favorites list is 25.");
					}
					else{
						let popup = dhtmlx.modalbox( {
							text: 'Name: <input type=\"text\" id=\"favorite\" value=\"\" style=\"width:200px;\">',
							title: "Save Search",
							buttons: ["Save", "Cancel"],
							callback: function(result) {
								let favorite_name = popup.getElementsByTagName("input")[0].value;

								/* If the user clicks on the "save" button */
								if(result == 0){
									$.ajax({type    : "post"
										,url     : "/mvc/Models/Program/ProgramList.cfc"
										,dataType: "json"
										,data: { method: "getDuplicateFavoritesByName"
												,userID: '#request.AccessStructure.user_id#'
												,lName: favorite_name
												}
										,success : function (response) {
										if(response.DUPLICATECOUNT == 0){
												saveFavoritesData(favorite_name);
											}
											else{
												alert("There is already an existing favorite with the same name. Please use a different name or delete the existing favorite and then try again.");
											}
										}
									});
								}
							}
						});

						// if there is an input field on the popup, focus on it
						let elem = popup.getElementsByTagName("input")[0];
							if ( elem )
								elem.focus();
					}
				}
		});
	}

	function showInValidCreateList(invalidProgramsList){
		 let msg           = '<div style="overflow-y: auto; max-height: 300px; text-align: left;">'
		 let formattedList = invalidProgramsList.split(",").join("<br />");
			 msg           = msg + formattedList + '</div>';
		 dhx_alert_wait(msg, 0,'These Program IDs were not found');
	}

	//let timerFavorite = "";
	function saveFavoritesData(favorite_name){
		$.ajax({type    : "post"
				,url     : "/mvc/Models/Program/ProgramList.cfc"
				,dataType: "json"
				,data: { method: "saveUserFavoriteProgramCriteria"
						,UserId: '#request.AccessStructure.user_id#'
						,lName: favorite_name
						,Status: $("select[name=status_list]").multipleSelect('getSelects').toString()
						,Template:  $("select[name=template_list]").multipleSelect('getSelects').toString()
						,RSP:  $("select[name=rsp_list]").multipleSelect('getSelects').toString()
						,BuyingGroup: $("select[name=buying_group_list]").multipleSelect('getSelects').toString()
						,Family: $("select[name=family_list]").multipleSelect('getSelects').toString()
						,UserInfo: $("select[name=user_list]").multipleSelect('getSelects').toString()
						,Position: $("select[name=user_position_list]").multipleSelect('getSelects').toString()
						,ProgramInfo:  $("select[name=workflow_steps_list]").multipleSelect('getSelects').toString()
						,ReportType:  $("select[name=action_list]").multipleSelect('getSelects').toString()
						,Conditions: $("select[name=condition_list]").multipleSelect('getSelects').toString()
						,Program_Info: $( "##program_search" ).val()
						,Distributor_Info: $( "##distributor_search" ).val()
						,Operator_Info: $( "##operator_search" ).val()
						,Item_Info: $( "##item_search" ).val()
						<cfif stProgramSettings.showbudgetDropdown>
						,BudgetClass:  $("select[name=budget_class_list]").multipleSelect('getSelects').toString()
						</cfif>
						<cfif stProgramSettings.businesssegmenton>
						,BusinessSegment:  $("select[name=business_segment]").multipleSelect('getSelects').toString()
						</cfif>
						<cfif get_profile_settings.read_only_catalog_access OR appSettings.get_Setting('Retail_Planner') EQ '1'>
						,Datasource: $("select[name=show_catalog]").multipleSelect('getSelects').toString()
						<cfelse>
						,Datasource: 'Programs'
						</cfif>
						,Discount_Type: $("select[name=discount_type]").multipleSelect('getSelects').toString()
						,Fixed_Discount_Types: $("select[name=fixed_discount_types]").multipleSelect('getSelects').toString()
						,Rebate_Discount_Types: $("select[name=rebate_discount_types]").multipleSelect('getSelects').toString()
						,Lump_Sum_Discount_Types: $("select[name=lump_sum_discount_types]").multipleSelect('getSelects').toString()
						,Growth_Discount_Types: $("select[name=growth_discount_types]").multipleSelect('getSelects').toString()
						,Rate_Compare: $('##rate_compare').val()
						,Rate_Uom: $("select[name=rate_uom]").multipleSelect('getSelects').toString()
						,Rate_Val: $('##rate_val').val()
				}
				,success : function (response) {
							$("select[name=favorite_list]").prepend('<option value=' + response.LISTID + '>' + response.LISTNAME + '</option>');
							$("select[name=favorite_list]").multipleSelect('refresh');
							$("select[name=favorite_list]").multipleSelect('open');
							//timerFavorite = window.setInterval(function(){closeFavoritesDropDown()},3000);
						}
		});
	}
	/*
	Auto close dropdown
	function closeFavoritesDropDown(){
		$("select[name=favorite_list]").multipleSelect('close');
		window.clearInterval(timerFavorite);
	}
	*/

	$(".date").datepicker({
		dateFormat: "m/d/yy",
		changeMonth: true,
		changeYear: true,
		onSelect: function( selected ) {
			// change date limit based on selected value
			if ( jQuery(this).attr("name") === "from_date" )
				jQuery("input[name=to_date]").datepicker("option", "minDate", selected);
			else
				jQuery("input[name=from_date]").datepicker("option", "maxDate", selected);
		}
	});

	/* When a user gets selected from the "users" dropdown, make the selected option of the "user position" dropdown,
	the select user's "user position".
	Since we have two onChange events - one on the "users" dropdown and the other on the  "user positions" dropdown,
	one keeps on calling each other in an infinite loop and so we need the "DoNotResetDropdown" variable.
	*/
	let DoNotResetDropdown = 0;
	function setPosition(){
		/* Get the "user position" of the selected user */
		let arrSelectedPositionID = [$("##user_list").find(':selected').attr('userPositionsID')];

		if(DoNotResetDropdown == 0){
			DoNotResetDropdown = 1;
			/* set the "user position" dropdown to the user position of the selected user */
			$("select[name=user_position_list]").multipleSelect('setSelects',arrSelectedPositionID);
			DoNotResetDropdown = 0;
		}
	}

	/* When a user selects a user position from the "user position" dropdown, reset the "users" dropdown.
	Since we have two onChange events - one on the "users" dropdown and the other on the  "user positions" dropdown,
	one keeps on calling each other in an infinite loop and so we need the "DoNotResetDropdown" variable.
	*/
	function resetUserList(){
		let selectedPositionIDUserDropdown = $("##user_list").find(':selected').attr('userPositionsID');
		let selectedPositionIDUserPositionDropdown = $("select[name=user_position_list]").multipleSelect('getSelects').toString();
		DoNotResetDropdown = 1;

		if(selectedPositionIDUserDropdown != selectedPositionIDUserPositionDropdown){
			/* Reset the "users" dropdown. */
			$("select[name=user_list]").multipleSelect('uncheckAll');
		}
		DoNotResetDropdown = 0;
	}

	$(document).keypress(function(e) {
		/* Filter the data, when the "Enter" key is pressed, but when the user is on the "list" tab (program_create_list),
		then do not filter data, when the "Enter" key is pressed, as we user "Enter" key to go to a new line on that screen.
		*/
		if (e.which == 13 && e.srcElement.id != 'program_create_list') {
		   filterData('MainSearch');
		}
	});

	// ngt
	$("select[name=discount_type]").change(function(){
		let discount = $(this).find("option:selected").val();
		$("div[name=fixed_discount_types], div[name=rebate_discount_types], div[name=lump_sum_discount_types], div[name=growth_discount_types]").hide();
		// $("div.discount_type").hide();
		// console.log({discount});
		switch(discount) {
			case '': break;
			case '1': $("div[name=fixed_discount_types]").show(); break;
			case '2': $("div[name=rebate_discount_types]").show(); break;
			case '3': $("div[name=lump_sum_discount_types]").show(); break;
			case '4': $("div[name=growth_discount_types]").show(); break;
		}
	});
	</script>
	</cfoutput>