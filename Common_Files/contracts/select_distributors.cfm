
<cfsilent>
<CFSET PAGE_TITLE="Select Program #application.returned_customer_setting.distributor_label_plural#">

<cfparam name="form.dosearch" default="0">
<cfparam name="form.WeightAssignmentCompleted" default="0">
<cfparam name="form.finishedselectingitems" default="1">
<cfparam name="url.CID" default="">
<cfparam name="form.updateFinalItemListFrompopup" default = "0">
<cfparam name="url.Is_Group" default="0" />
<cfparam name="url.User_Selection_Group_Or_Dist" default="0"/ >
<cfparam name="form.Dynamic_Static_Groups" default="0" />
<cfparam name="TheQuery.Recordcount" default="0">
<cfparam name="form.Line_Of_Business_ID" default="NULL">
<cfparam name="form.Contract_Main_ID" default="">
<cfparam name="Default_Dist_Whse" default="0">
<cfparam name="Selected_Dist_Whse" default="0">
<cfparam name="Form.Distributor_Level_1" 	default="">
<cfparam name="form.autoApplyWeight" default = "0">  <!--- D41881 :: Auto adjust of DST Weights --->
<cfparam name="form.searchstring"	default="">
<cfparam name="form.FinalItemList"	default="">
<cfparam name="form.finishedselectingitems"	default="0">
<cfparam name="form.LoadSavedDistributors"	default="1">
<cfparam name="form.editcurrentweight"	default="0">
<cfparam name="form.Is_Group"	default="0">
<cfparam name="form.excludeDistributor"		default="">
<cfparam name="ShowBrokerInResult"	default="0">
<cfparam name="form.Business_Segment_ID"	default="0">
<cfparam name="form.businessSegmentsOn"		default="0">
<cfparam name="form.plannerID"		default="0">
<cfparam name="form.grpSubmitted" default="0">
<cfif isdefined("URL.plannerID")>
	<cfset form.plannerID = URL.plannerID />
</cfif>

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<cfset baseSettings = CreateObject("component","components.Base") />
<cfinclude template="/get_access_profile.cfm">
<cfset request.custom_rfp_process = appSettings.get_Setting('Custom_RFP_Process',0)>
</cfsilent>

<CFIF len(trim(URL.CID)) GT 0>
	<CF_Cryp type="de" key="#request.key#" string="#URL.CID#">

	<cfset useLakebaseForGetContractInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForGetContractInfo>
	<cftry>
		<cfset GetContractInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#cryp.value#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetContractInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetContractInfo>
<cfquery name="GetContractInfo" datasource="#application.datasource#">
		SELECT *
		FROM Contract_Main
		WHERE Contract_Main_ID = '#cryp.value#'
	</cfquery>
</cfif>
	<!---D42322 ::  Programs cannot be submitted for approval
		Added : "Custom_Fixed_Price_Options" to below Query--->
	 <cfset useLakebaseForGetTemplateInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForGetTemplateInfo>
	<cftry>
		<cfset GetTemplateInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#GetContractInfo.ProgramType_ID#",
				"select" = "first_parent_id,base_sales_equal_to_lowest_bracket,custom_fixed_price_options,rfp_process"
			}), "first_parent_id,base_sales_equal_to_lowest_bracket,custom_fixed_price_options,rfp_process"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetTemplateInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetTemplateInfo>
<cfquery name="GetTemplateInfo" datasource="#application.datasource#">
		SELECT First_parent_ID,
				Base_Sales_Equal_To_Lowest_Bracket,
				Custom_Fixed_Price_Options,
				RFP_Process
		FROM Program_Control_Panel_Options
		WHERE ProgramControl_Panel_Options_ID = #GetContractInfo.ProgramType_ID#
	 </cfquery>
</cfif>

		<cfset TemplateFiltersId = GetContractInfo.Template_Filters_Id />
		<cfset form.Line_Of_Business_ID = GetContractInfo.Line_Of_Business_ID>
		<!--- D50074 :: Viewing and Editing prior program versions START --->
		<cfset ModifyDeletedPrograms = CreateObject("component","components.programs.program").ModifyDeletedProgram(GetContractInfo.Contract_Main_ID,Get_Profile_Settings.Modify_Expired_Programs) />
		<!--- D50074 :: Viewing and Editing prior program versions END --->
		<!--- Do not show the tabs if the contract is approved --->
	<CFIF GetContractInfo.Contract_Status_Type_IDX GT 2 AND ModifyDeletedPrograms EQ 0 AND form.PlannerID EQ 0><!--- D50074 :: Viewing and Editing prior program versions --->
		<script>
			history.back();
		</script>
		<CFABORT>
	</CFIF>
</CFIF>

<CF_Cryp type="de" key="#request.key#" string="#URL.CID#">
<CFSET FORM.Contract_Main_ID = cryp.value>

<cfset DistGroupManager = CreateObject("component", "components.programs.distributors.DistributorGroupManager").init() />
<cfset DistGroupDataManager = CreateObject("component", "components.customer.Group.DataManager").init() />
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset ProdGroupDataManager = CreateObject("component", "components.products.Group.DataManager").init() />
<cfset businessSegmentID = businessSegManager.getSegmentIdByProgram(FORM.Contract_Main_ID) />

<!--- set group data information --->
<cfset qGetDistGroupData = DistGroupManager.getDistGroupInfo(FORM.Contract_Main_ID) />
<cfparam name="form.Is_Group" default="#qGetDistGroupData.Specify_Distributor_Groups#" />

<cfset form.Dynamic_Static_Groups = qGetDistGroupData.Dynamic_Static_Groups />

<!--- LOAD DISTRIBUTOR SEARCH QUERY --->
		<!--- <cfif isdefined("session.qGetDistributors")>
			<cfset StructDelete(session,"qGetDistributors",false) />
		</cfif>
			<cfset application.oController.getObject("mvc.models.Distributor.DistributorSearchService") />
			<cfset application.oDistributorSearchService.getDistributors(FORM.Contract_Main_ID) />
--->

<!---//////////////////////////////////////Business Segment Section/////////////////////////////////////--->
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset busSegIdForProgram = businessSegManager.getSegmentIdByProgram(FORM.Contract_Main_ID) />

<cfif businessSegManager.isEnabledForDistributor()>
	<cfset form.businessSegmentsOn = 1 />
	<cfset form.Business_Segment_Id = trim(busSegIdForProgram) />
	<cfset form.businessSegmentsOn = 1 />
	<!---get the desctiption to display--->
	<cfset qGetThisBusSegment = businessSegManager.get(busSegIdForProgram) />
	<cfset Bus_Segment_Desc = qGetThisBusSegment.Business_Unit_Desc />

</cfif>

<cfset Group_Business_segment_id = 0>
<cfif form.businessSegmentsOn eq 1 and isDefined("FORM.BUSINESS_SEGMENT_ID")><!------ signature meat shares customers with ref ----->
	<cfset CustomerBSFilter = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager").get(FORM.Business_Segment_Id) />
	<cfset form.business_segment_id = CustomerBSFilter.Customer_BS_Filter>
	<cfset ShowBrokerInResult = CustomerBSFilter.Customer_Show_Broker>
	<cfset Group_Business_segment_id = CustomerBSFilter.Customer_Group_BS_Filter>
</cfif>

<cfif appSettings.getDistributorMultiPosition()>
	<cfset ShowBrokerInResult = 0>
</cfif>
<!---////////////////////////////////////////End Business Segment Section/////////////////////////////////////--->


<!--- If "Exclude" produsta already exist and the user imports more products from the "distributor" pop up page, the "form.excludeDistributor"
list should be removed from "FORM.FinalItemList".
Note: "form.excludeDistributor" is saved to to different table - "Contract_Distributors_Exceptions".
--->
<cfset FORM.FinalItemList = baseSettings.listCompare(FORM.FinalItemList, Replace(form.excludeDistributor,"_","-","ALL"))>

<!------ see details below ----->
<cfset Group_Or_Dist_Based_On_User_Selection = 0 />
<cfif isDefined("url.User_Selection_Group_Or_Dist") AND url.User_Selection_Group_Or_Dist EQ 1>
	<cfset form.Is_Group = url.Is_Group />
	<cfset Group_Or_Dist_Based_On_User_Selection = 1 />
</cfif>

<CFIF FORM.LoadSavedDistributors EQ 1>

	<!------ Find is there is groups items already saved ----->
	<cfif appSettings.getSearchSequenceOn() AND NOT Group_Or_Dist_Based_On_User_Selection>
		<cfset form.Is_Group = DistGroupManager.ProgramDistributorIsGroup(cryp.value) />
	</cfif>

	<cfquery name="CheckForExistingDistributors" datasource="#application.datasource#">
		SELECT 	*
		FROM 	Contract_Distributors
		WHERE 	Contract_Main_ID = '#cryp.value#'
		AND 	Deleted = 0
		<!---D56899 :: Modified below IF condition so that we can display already selected GROUP and INDIVIDUAL distributors all time if template setting allow user to pick group and individual distributors. --->
		<cfif form.Is_Group eq 1 AND (qGetDistGroupData.specify_distributor_groups EQ 0 OR qGetDistGroupData.specify_individual_distributors EQ 0)>
		AND		Is_Group = 1
		</cfif>
		AND Captured_From_Group = 0 <!---D56899 --->
	</cfquery>

	<!--- Call this when the page is initially loaded, but not when distributors are imported from the popup. In that case, we need the
	distributors from the popup, instead.
	--->
	<cfif form.updateFinalItemListFrompopup eq 0>
		<cfif CheckForExistingDistributors.recordcount GT 0>
			<CFSET FORM.FinalItemList = valuelist(CheckForExistingDistributors.BSA_Foodservice_Customers_ID)>
		<cfelse>
			<CFSET FORM.FinalItemList = "">
			<!--- Reset "FORM.updateFinalItemListFrompopup" back to 0 --->
			<cfset FORM.updateFinalItemListFrompopup = 0>
		</cfif>
	</cfif>

	<!--- (start) get distributor exceptions --->
	<CFIF Form.WeightAssignmentCompleted EQ 0>
		<cfset useLakebaseForCheckForExistingDistributorExceptions = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_distributors_exceptions")>
<cfif useLakebaseForCheckForExistingDistributorExceptions>
	<cftry>
		<cfset CheckForExistingDistributorExceptions = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_distributors_exceptions", {
				"contract_main_id" = "eq.#cryp.value#",
				"select" = "bsa_foodservice_customers_id"
			}), "bsa_foodservice_customers_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheckForExistingDistributorExceptions = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckForExistingDistributorExceptions>
<cfquery name="CheckForExistingDistributorExceptions" datasource="#application.datasource#">
			SELECT 	BSA_Foodservice_Customers_ID
			FROM 	Contract_Distributors_Exceptions
			WHERE 	Contract_Main_ID = '#cryp.value#'
		</cfquery>
</cfif>

		<cfif CheckForExistingDistributorExceptions.recordcount GT 0>
			<CFSET form.ExcludeDistributor = Replace(valuelist(CheckForExistingDistributorExceptions.BSA_Foodservice_Customers_ID),"-","_","ALL")>
		<cfelse>
			<CFSET form.ExcludeDistributor = "">
		</cfif>
	</CFIF>
	<!--- (end) get distributor exceptions --->

	<!--- We need to remove the "distributor exceptions" from FORM.FinalItemList. The need to go to the "Contract_Distributors_Exceptions" table and
	not "Contract_Distributors" table.
	--->
	<cfset FORM.FinalItemList = baseSettings.listCompare(FORM.FinalItemList, Replace(form.excludeDistributor,"_","-","ALL"))>

	<cfset useLakebaseForqGetLevel_1_Distributors = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("checkforexistingdistributors")>
<cfif useLakebaseForqGetLevel_1_Distributors>
	<cftry>
		<cfset qGetLevel_1_Distributors = application.oLakebase.toQuery(
			application.oLakebase.selectRows("checkforexistingdistributors", {
				"distributor_group_level_id" = "eq.1",
				"select" = "distributor_group_id"
			}), "distributor_group_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetLevel_1_Distributors = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetLevel_1_Distributors>
<cfquery name="qGetLevel_1_Distributors" dbtype="query">
		SELECT	Distributor_Group_ID
		FROM	CheckForExistingDistributors
		WHERE 	Distributor_Group_Level_ID = 1
	</cfquery>
</cfif>

	<cfif qGetLevel_1_Distributors.recordcount GT 0>
	<cfset FORM.Distributor_Level_1 = ValueList(qGetLevel_1_Distributors.Distributor_Group_ID) />
	<cfelse>
		<cfset FORM.Distributor_Level_1 = "">
	</cfif>
	<!---if we have any group customers then flag group search bit--->
	<cfquery name="qCheckGroupCustomers" dbtype="query">
		SELECT	Distributor_Group_ID
		FROM	CheckForExistingDistributors
		WHERE 	Distributor_Group_Level_ID > 1
	</cfquery>

</CFIF>

<cfset FORM.groupLevelDistributors = 0 />
		<cfif Len(FORM.Distributor_Level_1) GT 0>
		<cfset groupLevelDistributorId = DistGroupManager.getDistributorForGroupDistributors(1, form.Distributor_Level_1) />
		<cfset FORM.FinalItemList = groupLevelDistributorId />
		<cfset FORM.groupLevelDistributors = 1 />
		<CFIF FORM.LoadSavedDistributors EQ 0>
			<cfset Form.editcurrentweight = 1 />
			<cfset FORM.finishedselectingitems = 1 />
			<cfset "FORM.Weight_DID_#replace(ListFirst(FORM.FinalItemList, ","),"-","_","ALL")#" = 100 />
		</CFIF>
</cfif>

<!--- D30860:HZPROD328 - DUPLICATE DISTRIBUTORS ON PROGRAMS START --->
<cfset noduplicates = StructNew()>
<cfloop index="items" list="#form.FinalItemList#">
	<cfset noduplicates[items] = "">
</cfloop>
<cfset Form.FinalItemList = StructKeyList(noduplicates)>
<!--- D30860:HZPROD328 - DUPLICATE DISTRIBUTORS ON PROGRAMS END --->

	<cfset objProgramFreight = CreateObject("component", "components.freight.ProgramFreight") />
	<cfset objProgram = CreateObject("component", "components.programs.program") />
	<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />
	<cfset IsFreightProgram = GenProgramManager.GetIsProgramFreightOn(FORM.Contract_Main_ID)>
	<cfset qryProgram = objProgram.getProgramInfo(FORM.Contract_Main_ID) />
<!----*************************************************************************************************************************--->
<!----*********************************************DISTRIBUTOR APPLY VOLUME****************************************************--->
<!----*************************************************************************************************************************--->
<CFIF FORM.finishedselectingitems EQ 1>
<!---Only one distributor--->
	<!--- lock checker --->
	<CFSET LockChecker_CID  = FORM.Contract_Main_ID>
	<CFINCLUDE TEMPLATE="LockChecker.cfm">
	<!--- lock checker --->

	<!---
	START CHANGES FOR D19112: Program copy or revise 'dropping'
	The "edit distributors" link was causing issue with the "revision settings " restrictions
	User was able to uncheck using the "select all check box" and then use the "edit distributors" link which was not retaining the selections / hidden from current page
	Solution: Before save, make sure the list of distributor ids from parent program is retained if revision settings for "remove distributor not allowed" is ON
	--->
	<cfset RevisionSettingsManager = CreateObject("component", "components.programs.Display_Program.revision_settings") />
	<cfset RevisionStatus = RevisionSettingsManager.getRevisionStatus(cryp.value)>

	<!--- if program is a revision --->
	<cfif	RevisionStatus.Is_A_Revision eq 1>

		<!--- get revision settings --->
		<cfset RevisionSettings = RevisionSettingsManager.getRevisionSettings(templateId = qryProgram.programtype_id,profilesID = request.AccessStructure.Profiles_ID, ContractMainID = FORM.Contract_Main_ID)>
		<cfset Revision_Settings_Allowed = 0 />
		<cfif RevisionSettings.Apply_to_All eq 1 OR (RevisionSettings.Apply_to_All eq 2 AND RevisionStatus.Contract_Reference_Number neq "")>
			<cfset Revision_Settings_Allowed = 1 />
		</cfif>

		<!--- revision settings is ON and remove distributor is not allowed --->
		<cfif	Revision_Settings_Allowed eq 1
				AND RevisionSettings.Distributors_Removed eq 2>

				<!--- get list of distributor id from parent program --->
				<cfset ParentProgramDistributors = objProgram.getParentProgramDistributors(FORM.Contract_Main_ID) />
				<!--- append the list of distributor id from parent program to current list --->
				<cfset FORM.FinalItemList = DistGroupManager.listAppendIfNotExist(FORM.FinalItemList, ValueList(ParentProgramDistributors.BSA_Foodservice_Customers_ID)) />
		</cfif>
	</cfif>
	<!---
	END CHANGES FOR D19112: Program copy or revise 'dropping'
	--->

	<!--- check for the weight assignment completed flag, if low get the assignments otherwise move on --->
	<cfif FORM.WeightAssignmentCompleted EQ 0 AND LoadSavedDistributors eq 0>

		<!--- D27177: Auto weighting and hidden We will automatically allocate the weight if it is not a freight program --->
		<!--- D41881 :: Auto adjust of DST Weights START--->
			<cfif appSettings.getAutoWeightDistributorsProgramRevision()>
			 	<cfset form.autoApplyWeight = 1>
			</cfif>
		<!--- D41881 :: Auto adjust of DST Weights END--->
		<cfif IsFreightProgram EQ 0 AND FORM.editcurrentweight EQ 0 AND form.autoApplyWeight>

			<cfset iDistributorListLen = listlen(FORM.FinalItemList) />
			<cfif iDistributorListLen> <!--- if no distributor selected, do not try to set the weight --->

				<!---<cfset iDefaultWeight = request.app_general_functions.roundDecimalPlaces(100.00 / iDistributorListLen, 2) />--->
				<cfset iDefaultWeight = 100.00 / iDistributorListLen />

				<cfset iTotalWeightAssigned = 0 />

				<cfloop list="#form.FinalItemList#" index="CurrentRecord">
					<cfset stripCustId = request.app_general_functions.replaceHyphen(CurrentRecord) />
					<cfparam name="form.Group_Level_ID_#stripCustId#" default="0" />
					<cfset thisGroupLevel = Evaluate("form.Group_Level_ID_#stripCustId#")/>

					<cfset "FORM.Weight_DID_#stripCustId#" = iDefaultWeight />
					<cfset "FORM.Group_Level_ID_#stripCustId#" = "#thisGroupLevel#" />
					<cfset iTotalWeightAssigned = iTotalWeightAssigned + iDefaultWeight />
				</cfloop>

				<!--- if weight does not add up to 100, set the remaining to last record --->
				<cfif iTotalWeightAssigned neq 100>
					<cfset "FORM.Weight_DID_#stripCustId#" = iDefaultWeight + (100 - iTotalWeightAssigned) />
				</cfif>

			</cfif>

				<cfset FORM.WeightAssignmentCompleted = 1 />
				<cfset FORM.finishedselectingitems = 1 />
				<cfset FORM.editcurrentweight = 0 />
				<cfset FORM.Distributor_Level_1 = "#FORM.Distributor_Level_1#" />

			<!---</cfif>--->

		</cfif>
	</cfif>

	<!--- check for the weight assignment completed flag, if low get the assignments otherwise move on --->
	<CFIF FORM.WeightAssignmentCompleted EQ 0>
		<cfinclude template="select_distributors_assign_weight.cfm" />
	<CFELSE><!------FORM.WeightAssignmentCompleted EQ 0----->

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---////////////////////////////////////// Save Into the database start /////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
		<cfset useLakebaseForCheckForSavedDistributors = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_distributors")>
<cfif useLakebaseForCheckForSavedDistributors>
	<cftry>
		<cfset CheckForSavedDistributors = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_distributors", {
				"contract_main_id" = "eq.#FORM.Contract_Main_ID#",
				"deleted" = "eq.0",
				"select" = "bsa_foodservice_customers_id,program_weight,warehouse_master_id"
			}), "bsa_foodservice_customers_id,program_weight,warehouse_master_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheckForSavedDistributors = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckForSavedDistributors>
<cfquery name="CheckForSavedDistributors" datasource="#application.datasource#">
			SELECT BSA_Foodservice_Customers_ID,Program_Weight,Warehouse_Master_ID
			FROM Contract_Distributors
			WHERE Contract_Main_ID = '#FORM.Contract_Main_ID#'
			AND Deleted = 0
		</cfquery>
</cfif>

		<cfset SavedItemList = valuelist(CheckForSavedDistributors.BSA_Foodservice_Customers_ID)>

		<cfoutput query="CheckForSavedDistributors">
			<cfset stripCustId = request.app_general_functions.replaceHyphen(BSA_Foodservice_Customers_ID) />
			<!--- Create Saved Distributor's Unique ID's --->
			<cfset "DistributorInfo_#stripCustId#" = CheckForSavedDistributors.BSA_Foodservice_Customers_ID&'___'&CheckForSavedDistributors.Program_Weight&'___'&CheckForSavedDistributors.Warehouse_Master_ID>
			<!--- Get Saved Distributor Weights and Warehouse --->
			<cfset "DistributorWeight_#stripCustId#" = CheckForSavedDistributors.Program_Weight />
			<cfset "DistributorWarehouse_#stripCustId#" = CheckForSavedDistributors.Warehouse_Master_ID />
		</cfoutput>

		<!--- "form.excludeDistributorList" is the hidden variable which stores the updated list of "distributor exceptions". If that variable exists,
		we need to use that list instead.
		--->
		<cfif IsDefined("form.excludeDistributorList")>
			<cfset form.excludeDistributor = form.excludeDistributorList>
		</cfif>

		<!--- We need to remoove the "distributor exceptions" from FORM.FinalItemList. "distributor exceptions" are loaded from the
		"Contract_Distributors_Exceptions" table and not "Contract_Distributors" table.
		--->
		<cfset FORM.FinalItemList = baseSettings.listCompare(FORM.FinalItemList, Replace(form.excludeDistributor,"_","-","ALL"))>

		<cfquery name="CheckForExistingDistributors" datasource="#application.datasource#">
			SELECT 	*
			FROM Contract_Distributors
			WHERE Contract_Main_ID = '#FORM.Contract_Main_ID#' and Deleted = 0
			<CFIF listlen(FORM.FinalItemList) GT 0>
				AND BSA_Foodservice_Customers_ID NOT IN(#replace(listqualify(FORM.FinalItemList, "'", ","), '"', "'", "ALL")#)
			</CFIF>
		</cfquery>

		<cfset DeletedDistributorList = valuelist(CheckForExistingDistributors.BSA_Foodservice_Customers_ID)>

		<cfset useLakebaseFordeletedCurrentDistributors = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_distributors")>
<cfif useLakebaseFordeletedCurrentDistributors>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_distributors",
			{
				"contract_main_id" = "eq.#Form.Contract_Main_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseFordeletedCurrentDistributors = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeletedCurrentDistributors>
<CFQUERY NAME="deletedCurrentDistributors" datasource="#application.datasource#">
			UPDATE Contract_Distributors
			SET Deleted = 1
			WHERE Contract_Main_ID = '#Form.Contract_Main_ID#'
		</CFQUERY>
</cfif>

		<CFQUERY NAME = "Specify_Broker" datasource="#Application.Datasource#">
			SELECT  Program_Control_Panel_Options.Specify_Brokers Specify_Brokers, Date_Exclusions_ON, 	Generic_Type
			FROM  Contract_Main
			 INNER JOIN Program_Control_Panel_Options
			 ON  Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
			WHERE Contract_Main.Contract_Main_ID =  #Form.Contract_Main_ID#
		</CFQUERY>

		<!--- Delete Auto_Broker --->
		<cfset useLakebaseFordeletedCurrentBrokers = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_brokers")>
<cfif useLakebaseFordeletedCurrentBrokers>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_brokers",
			{
				"contract_main_id" = "eq.#Form.Contract_Main_ID#",
				"auto_selection" = "eq.1"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseFordeletedCurrentBrokers = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeletedCurrentBrokers>
<CFQUERY NAME="deletedCurrentBrokers" datasource="#application.datasource#">
			UPDATE Contract_Brokers
			SET Deleted = 1
			WHERE Contract_Main_ID = '#Form.Contract_Main_ID#' AND Auto_Selection = 1
		</CFQUERY>
</cfif>
		<!--- ################### --->

		<!--- (start) DISTRIBUTOR EXCEPTIONS
		Note: SP 'Capture_Customer_Groups" deletes the distributors which are in the "Contract_Distributors_Exceptions" table
		from the "Contract_Distributors" table.
		--->
		<cfset useLakebaseForDelDistributorExceptions = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_distributors_exceptions")>
<cfif useLakebaseForDelDistributorExceptions>
	<cftry>
		<cfset application.oLakebase.deleteRows("contract_distributors_exceptions", {
			"contract_main_id" = "eq.#FORM.Contract_Main_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForDelDistributorExceptions = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDelDistributorExceptions>
<cfquery name="DelDistributorExceptions" datasource="#application.datasource#">
			DELETE FROM Contract_Distributors_Exceptions
			WHERE Contract_Main_ID = '#FORM.Contract_Main_ID#'
		</cfquery>
</cfif>

		<CFIF IsDefined("form.excludeDistributor") AND form.excludeDistributor neq "">
			<CFLOOP INDEX="ListDistributor_ID" LIST="#request.app_general_functions.listRemoveDupes(excludeDistributor,",")#" DELIMITERS=",">
				<cfquery name="SaveDistributorExceptions" datasource="#application.datasource#">
					INSERT INTO Contract_Distributors_Exceptions
					(BSA_Foodservice_Customers_ID, Contract_Main_ID)
					VALUES
					('#Replace(ListDistributor_ID,"_","-", "ALL")#', '#FORM.Contract_Main_ID#')
				</cfquery>
			</CFLOOP>
		</CFIF>
		<!--- (end) DISTRIBUTOR EXCEPTIONS --->

<!--- Declare freight approval variables --->
	<cfset Distributor_Delete = 0>
	<cfset Distributor_Add = 0>
	<cfset Distributor_Weight_Change = 0>
	<cfset Distributor_Warehouse_Change = 0>
	<cfset Distributor_Warehouse_Change_List = "">

		<CFLOOP INDEX="ListDistributor_ID" LIST="#trim(FORM.FinalItemList)#" DELIMITERS=",">
			<cfif isDefined("FORM.Weight_DID_#replace(ListDistributor_ID,'-','_','ALL')#")>
				<CFSET Dis_Program_Weight = evaluate("FORM.Weight_DID_#replace(ListDistributor_ID,"-","_","ALL")#")>
			<cfelse>
				<cfset Dis_Program_Weight = 0 />
			</cfif> 
				<cfset stripCustId = request.app_general_functions.replaceHyphen(ListDistributor_ID) />
				<cfparam name="form.Group_Level_ID_#stripCustId#" default="0" />
				<cfparam name="FORM.Distributor_Level_1" default="0" />
				<cfparam name="FORM.groupLevelDistributors" default="0" />
				<cfparam name="FORM.Is_Group" default="0" />
				<cfparam name="FORM.Dynamic_Static_Groups" default="0" />
				<cfparam name="FORM.SelectedWarehouse_#stripCustId#" default="0" />
				<cfparam name="FORM.DefaultWarehouse_#stripCustId#" default="0" />
						<cfset useLakebaseForisitgroup = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
<cfif useLakebaseForisitgroup>
	<cftry>
		<cfset isitgroup = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_customers", {
				"bsa_foodservice_customers_id" = "eq.#ListDistributor_ID#",
				"ship_to" = "eq.Group"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForisitgroup = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForisitgroup>
<cfquery name="isitgroup" datasource="#application.datasource#">
							SELECT *
							FROM 	BSA_Foodservice_Customers
							WHERE BSA_Foodservice_Customers_ID = '#ListDistributor_ID#'
							AND 	ship_to = 'Group'
						</cfquery>
</cfif>
						<cfif isitgroup.recordcount>
							<cfset form.Is_Group = 1>
						<cfelse>
							<cfset form.Is_Group = 0>
						</cfif>
				<!--- D56899 END --->
				<!---handle for groups--->
				<cfif form.Is_Group eq 1>
					<cfset useLakebaseForqGetDistributorGroupLevelID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("distributor_group_distributor")>
<cfif useLakebaseForqGetDistributorGroupLevelID>
	<cftry>
		<cfset qGetDistributorGroupLevelID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("distributor_group_distributor", {
				"distributor_id" = "eq.#ListDistributor_ID#",
				"deleted" = "eq.0",
				"select" = "distributor_group_level_id"
			}), "distributor_group_level_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDistributorGroupLevelID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDistributorGroupLevelID>
<cfquery name="qGetDistributorGroupLevelID" datasource="#application.datasource#">
						SELECT	Distributor_Group_Level_ID
						FROM   Distributor_Group_Distributor
						WHERE Distributor_ID = '#ListDistributor_ID#'
						AND Deleted = 0
					</cfquery>
</cfif>

					<cfset thisGroupLevel = qGetDistributorGroupLevelID.Distributor_Group_Level_ID / >
					<cfset thisGroupId = ListDistributor_ID />
				<cfelse>
					<cfset thisGroupLevel = FORM.groupLevelDistributors />
					<cfset thisGroupId = FORM.Distributor_Level_1 />
				</cfif>

			<!---set thisGroupLevel = to 0 if it's a null string--->
			<cfif trim(thisGroupLevel) eq "">
				<cfset thisGroupLevel = 0 />
			</cfif>

		<!--- If it's a freight program and there are no groups - ngt --->
		<cfif IsFreightProgram eq 1 or request.custom_rfp_process>

			<!--- Get the selected and default warehouses --->
			<cfset Selected_Dist_Whse = Evaluate('FORM.SelectedWarehouse_'&stripCustId)>
			<cfset Default_Dist_Whse = Evaluate('FORM.DefaultWarehouse_'&stripCustId)>

			<!--- Reset Freight Approval If Distributor Added --->
			<cfif Distributor_Add eq 0>
			<cfif CheckForSavedDistributors.Recordcount neq 0>
				<cfif ListFindNoCase(SavedItemList, ListDistributor_ID) eq 0>
					<cfif qryProgram.Freight_Approved eq 1>
						<cfset objProgramFreight.resetFreightApproval(FORM.Contract_Main_ID,request.AccessStructure.User_ID,'Reset Approval - Distributor Add')>
					</cfif>
						<cfset Distributor_Add = 1>
				</cfif>
			</cfif>
			</cfif>

			<!--- Reset Freight Approval If Distributor Deleted --->
			<cfif Distributor_Delete eq 0>
				<cfif ListLen(DeletedDistributorList,",") gt 0>
					<cfif qryProgram.Freight_Approved eq 1>
						<cfset objProgramFreight.resetFreightApproval(FORM.Contract_Main_ID,request.AccessStructure.User_ID,'Reset Approval - Distributor Delete')>
					</cfif>
						<cfset Distributor_Delete = 1>
				</cfif>
			</cfif>

			<!--- Reset Freight Approval If Distributor Weight Changes --->
			<cfif Distributor_Weight_Change eq 0>
				<cfif CheckForSavedDistributors.Recordcount neq 0>
					<cfif FindNoCase(ListDistributor_ID,"DistributorInfo_#ListDistributor_ID#") neq 0>
					<cfif IsDefined('DistributorWeight_'&stripCustId)>
						<cfif Dis_Program_Weight neq  "#Evaluate('DistributorWeight_'&stripCustId)#">
							<cfif qryProgram.Freight_Approved eq 1>
								<cfset objProgramFreight.resetFreightApproval(FORM.Contract_Main_ID,request.AccessStructure.User_ID,'Reset Approval - Distributor Weight Change')>
							</cfif>
								<cfset Distributor_Weight_Change = 1>
							</cfif>
						</cfif>
					</cfif>
				</cfif>
			</cfif>

			<!--- Reset Freight Approval If Distributor Warehouse Changes --->
			<cfif CheckForSavedDistributors.Recordcount neq 0>
				<cfif FindNoCase(ListDistributor_ID,"DistributorInfo_#ListDistributor_ID#") neq 0>
				<cfif IsDefined('DistributorWarehouse_'&stripCustId)>
					<cfif Selected_Dist_Whse neq  "#Evaluate('DistributorWarehouse_'&stripCustId)#">
						<cfif qryProgram.Freight_Approved eq 1>warehouse 1
							<cfset objProgramFreight.resetFreightApproval(FORM.Contract_Main_ID,request.AccessStructure.User_ID,'Reset Approval - Distributor Warehouse Change')>
						</cfif>
							<cfset Distributor_Warehouse_Change = 1>
								<CFQUERY NAME="deletedCurrentBrokers" datasource="#application.datasource#">
									UPDATE	Program_Distributor_Freight
									SET Warehouse_Master_ID = '#Selected_Dist_Whse#'
									WHERE Program_ID = '#FORM.Contract_Main_ID#'
									AND Distributor_Group_ID = '#ListDistributor_ID#'
									AND Deleted = 0
								</CFQUERY>
							<cfset Distributor_Warehouse_Change_List = ListAppend(Distributor_Warehouse_Change_List,'#ListDistributor_ID#')>
					</cfif>
					</cfif>
				</cfif>
			</cfif>

		</cfif>

			<cfset Overridden_Warehouse = 0>

			<!--- If the warehouse is overridden, record it --->
			<cfif Default_Dist_Whse neq Selected_Dist_Whse>
				<cfset Overridden_Warehouse = 1>
			</cfif>
			<!--- D56899 START--->
				<cfif form.Is_Group EQ 0>
					<cfset useLakebaseForDeleteDuplicates = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_distributors")>
<cfif useLakebaseForDeleteDuplicates>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_distributors",
			{
				"contract_main_id" = "eq.#FORM.Contract_Main_ID#",
				"bsa_foodservice_customers_id" = "eq.#ListDistributor_ID#",
				"captured_from_group" = "eq.1",
				"deleted" = "eq.0"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDeleteDuplicates = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeleteDuplicates>
<cfquery name="DeleteDuplicates" datasource="#application.datasource#">
						UPDATE Contract_Distributors
						SET DELETED = 1
						WHERE Contract_Main_ID = '#FORM.Contract_Main_ID#'
						AND BSA_Foodservice_Customers_ID = '#ListDistributor_ID#'
						AND Captured_From_Group = 1
						AND Deleted = 0
					</cfquery>
</cfif>
				</cfif>
            <!--- D56899 END--->

			<cfquery name="SaveDistributor" datasource="#application.datasource#">
				INSERT INTO Contract_Distributors
				(BSA_Foodservice_Customers_ID, Contract_Main_ID,Program_Weight, Distributor_Group_Level_ID, Distributor_Group_ID, Is_Group, Dynamic_Static_Groups,Warehouse_Master_ID,Default_Warehouse_Master_ID,Overridden_Warehouse_Master_ID)
				VALUES
				('#ListDistributor_ID#', '#FORM.Contract_Main_ID#',  '#request.app_general_functions.roundDecimalPlaces(trim(Dis_Program_Weight), 2)#', #thisGroupLevel#, '#thisGroupId#', #form.Is_Group#, #form.Dynamic_Static_Groups#
				,<cfif Selected_Dist_Whse eq 0>NULL<cfelse>'#Selected_Dist_Whse#'</cfif>,<cfif Default_Dist_Whse eq 0>NULL<cfelse>'#Default_Dist_Whse#'</cfif>,'#Overridden_Warehouse#')
			</cfquery>

			<!---D42322 ::  Programs cannot be submitted for approval
			Added "GetTemplateInfo.Custom_Fixed_Price_Options" to below IF condition
			--->
			<cfif ProdGroupDataManager.isGroupDeal(FORM.Contract_Main_ID) AND GetTemplateInfo.Custom_Fixed_Price_Options eq 0>
				<!---if it's a group then flag to process when applying volume--->
				<cfset useLakebaseForqFlagGroup = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForqFlagGroup>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_main",
			{
				"deleted" = "eq.0",
				"contract_main_id" = "eq.#Form.Contract_Main_ID#"
			},
			{
				"group_processed" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqFlagGroup = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqFlagGroup>
<cfquery name="qFlagGroup" datasource="#application.datasource#">
					UPDATE	Contract_Main
					SET		Group_Processed = 1
					WHERE	Deleted = 0
					AND 	Contract_Main_ID = #Form.Contract_Main_ID#
				</cfquery>
</cfif>
			</cfif>

			<!---if it's a group being added then capture group customers--->
			<cfif form.Is_Group EQ 1>

				<cfstoredproc procedure="CAPTURE_CUSTOMER_GROUPS" datasource="#application.datasource#">

					<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#FORM.Contract_Main_ID#" null="no">
					<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@@PROGRAM_WEIGHT" value="#trim(Dis_Program_Weight)#" null="no">
					<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@DISTRIBUTOR_GROUP_LEVEL_ID" value="#thisGroupLevel#" null="no">
					<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@@DISTRIBUTOR_GROUP_ID" value="#thisGroupId#" null="no">
					<cfprocparam type="In" CFSQLType="CF_SQL_BIT" dbVarName = "@@DYNAMIC_STATIC_GROUPS" value = "#form.Dynamic_Static_Groups#" null="no">

				</cfstoredproc>

			</cfif>

			<!--- Select Broker_Id from BSA_Foodservice_Customers And Insert into Contract_Brokers --->
			<CFIF NOT (appSettings.getDistributorMultiPosition()) and form.Is_Group NEQ 1 AND NOT Specify_Broker.Generic_Type EQ "LSAutoPay"><!---  NO BROKER INSERT FOR GENERIC TYPE LSAutoPay --->
				<cfset useLakebaseForGet_Broker = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
<cfif useLakebaseForGet_Broker>
	<cftry>
		<cfset Get_Broker = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_customers", {
				"bsa_foodservice_customers_id" = "eq.#ListDistributor_ID#",
				"select" = "bsa_foodservice_brokers_id"
			}), "bsa_foodservice_brokers_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Broker = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Broker>
<CFQUERY NAME="Get_Broker" DATASOURCE="#application.datasource#">
					SELECT BSA_Foodservice_Brokers_ID
					FROM BSA_Foodservice_Customers
					WHERE BSA_Foodservice_Customers_ID = '#ListDistributor_ID#'
				</CFQUERY>
</cfif>
				<CFQUERY NAME = "Check_existance" DATASOURCE = "#Application.Datasource#">
					SELECT BSA_Foodservice_Brokers_ID
					FROM Contract_Brokers
					WHERE <cfif len(trim(Get_Broker.BSA_Foodservice_Brokers_ID)) EQ 36> <!--- length of guid --->
							BSA_Foodservice_Brokers_ID = '#Get_Broker.BSA_Foodservice_Brokers_ID#'
						  <cfelse>
							1=2
						  </cfif>
					AND Contract_Main_Id = #FORM.Contract_Main_ID# AND Deleted = 0
				</CFQUERY>
				<CFIF Check_existance.recordcount EQ 0 and len(trim(Get_Broker.BSA_Foodservice_Brokers_ID)) EQ 36> <!--- length of guid --->
					<cfset useLakebaseForinsert_autobrokers = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_brokers")>
<cfif useLakebaseForinsert_autobrokers>
	<cftry>
		<cfset application.oLakebase.insertRow("contract_brokers", {
			"bsa_foodservice_brokers_id" = "#Get_Broker.BSA_Foodservice_Brokers_ID#",
			"contract_main_id" = "#FORM.Contract_Main_ID#",
			"auto_selection" = "1"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForinsert_autobrokers = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForinsert_autobrokers>
<CFQUERY NAME="insert_autobrokers" DATASOURCE="#Application.Datasource#">
						INSERT INTO Contract_Brokers
						(BSA_Foodservice_Brokers_ID, Contract_Main_ID,Auto_Selection)
						VALUES
						('#Get_Broker.BSA_Foodservice_Brokers_ID#','#FORM.Contract_Main_ID#',1)
					</CFQUERY>
</cfif>
				</CFIF>
			</CFIF>
			<!--- ################################################################################### --->
		</CFLOOP>

		<!--- 87446 - Delete distributor dups. In this WR duplicate was found only for Captured_From_Group = 0 records
		If there are duplicates identified for Captured_From_Group = 1 records, it should be handled in the capture SP.
		--->
		<cfquery name="DelDistributorDuplicates" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmp_dist_dup_to_del') IS NOT NULL
			DROP TABLE ##tmp_dist_dup_to_del

			SELECT	Contract_Main_ID, BSA_Foodservice_Customers_ID, COUNT(*) AS Cnt, Max(Contract_Distributors_ID) as Max_Contract_Distributors_ID
			INTO	##tmp_dist_dup_to_del
			FROM	Contract_Distributors
			WHERE	Contract_Main_ID = '#FORM.Contract_Main_ID#'
			AND		Deleted = 0
			AND		Captured_From_Group = 0
			GROUP BY Contract_Main_ID, BSA_Foodservice_Customers_ID
			HAVING COUNT(*) > 1

			IF EXISTS (SELECT 1 FROM ##tmp_dist_dup_to_del)
			BEGIN
				UPDATE	cd
				SET		Deleted = 1
				FROM	##tmp_dist_dup_to_del t
				INNER JOIN Contract_Distributors cd
				ON		cd.Contract_Main_ID = t.Contract_Main_ID
				AND		cd.BSA_Foodservice_Customers_ID = t.BSA_Foodservice_Customers_ID
				AND		cd.Deleted = 0
				AND		cd.Captured_From_Group = 0
				AND		cd.Contract_Distributors_ID != t.Max_Contract_Distributors_ID -- Keep the latest record
			END
		</cfquery>

		<!--- When there are no distributor groups on the program, remove all the exceptions, as the exceptions are created from the group. --->
		<cfquery name="delDistExceptions" datasource="#application.datasource#">
			IF NOT EXISTS(
				SELECT 1
				FROM Contract_Distributors
				WHERE Contract_Main_ID = '#FORM.Contract_Main_ID#'
				AND deleted = 0
				AND Is_Group =1
			)
			BEGIN
				DELETE FROM Contract_Distributors_Exceptions
				WHERE Contract_Main_ID = '#FORM.Contract_Main_ID#'
			END
		</cfquery>
		<!---- If its a freight program --->
		<cfif IsFreightProgram eq 1>

			<!--- If all the Distributors are deleted --->
			<cfif ListLen(FORM.FinalItemList) eq 0>
				<cfset objProgramFreight.resetFreightApproval(FORM.Contract_Main_ID,request.AccessStructure.User_ID,'Reset Approval - Distributor Delete')>
			</cfif>

			<!--- Delete Deleted Distributors freight Info --->
			<cfif Distributor_Delete eq 1 OR ListLen(FORM.FinalItemList) eq 0>
				<cfset objProgramFreight.DeleteDistributorFreightInfo('#FORM.Contract_Main_ID#',DeletedDistributorList)>
			</cfif>

			<!--- Recalculate freight for the newly added distributors only, if the program is not a WIP --->
			<cfif Distributor_Add eq 1>
				<cfset objProgramFreight.PopulateProgramDistributorFreight('#FORM.Contract_Main_ID#',0)>
			</cfif>

			<!---- Recaclulate freight for the distributor whose warehouse has changed --->
			<cfif Distributor_Warehouse_Change eq 1>
				<cfloop list="#Distributor_Warehouse_Change_List#" index="i">
					<cfset objProgramFreight.PopulateProgramDistributorFreight('#FORM.Contract_Main_ID#',0,'#i#')>
				</cfloop>
			</cfif>

		</cfif>

		<cfif appsettings.getsysco_report_on()>
			<cfquery name="checkDistributor" datasource="#application.datasource#">
			select BSA_Foodservice_Customers.name as Cust_Name
			from Contract_Distributors
			INNER JOIN BSA_Foodservice_Customers ON
			Contract_Distributors.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID and BSA_Foodservice_Customers.deleted = 0
			INNER JOIN Distributor_Family
			ON BSA_Foodservice_Customers.Family_ID = Distributor_Family.Family_ID
			and Distributor_Family.deleted = 0
			INNER JOIN Distributor_Buying_Groups
			ON BSA_Foodservice_Customers.Buying_Group_ID = Distributor_Buying_Groups.Buying_Group_ID
			and Distributor_Buying_Groups.deleted = 0
			where Contract_Distributors.deleted = 0
			and (BSA_Foodservice_Customers.Name like '%sysco%' OR
				Distributor_Family.Family_Name like '%sysco%' OR
				Distributor_Buying_Groups.Buying_Group_Name like '%sysco%')
			and Contract_Distributors.contract_main_id = '#FORM.Contract_Main_ID#'
			</cfquery>
			<cfif checkDistributor.recordcount GT 0>
				<cfset useLakebaseForupdateSyscoFeild = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForupdateSyscoFeild>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_main",
			{
				"contract_main_id" = "eq.#FORM.Contract_Main_ID#"
			},
			{
				"contract_contains_sysco" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdateSyscoFeild = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdateSyscoFeild>
<cfquery name="updateSyscoFeild" datasource="#application.datasource#">
					update contract_main
					set Contract_contains_Sysco = 1
					where contract_main_id = '#FORM.Contract_Main_ID#'
				</cfquery>
</cfif>
			<cfelse>
				<cfquery name="updateSyscoFeild" datasource="#application.datasource#">
					update contract_main
					set Contract_contains_Sysco = 0
					where contract_main_id = '#FORM.Contract_Main_ID#'
				</cfquery>
			</cfif>
		</cfif>

		<!--- When fixed price type is ON, update the price list ID based on selected distributors --->
		<cfif appSettings.getUseFixedPriceType()>
			<cfset objProgram.saveProgramPriceListID(
					programID = FORM.Contract_Main_ID,
					Base_Sales_Equal_To_Lowest_Bracket = GetTemplateInfo.Base_Sales_Equal_To_Lowest_Bracket) />
		</cfif>

		<cfif request.custom_rfp_process eq 1 AND (GetTemplateInfo.RFP_Process EQ 1)	>
			<cfscript>
				oRFP				= CreateObject("component", "mvc.Models.Program.RfpManager");
				WarehouseMasterId 	= oRFP.getDefaultWarehouse(Form.Contract_Main_ID);
			</cfscript>
			<cfif WarehouseMasterId NEQ 0>
				<cfquery name="updateDefault_Warehouse_Master_ID" datasource="#application.datasource#">
					UPDATE Contract_Products SET Warehouse_Master_Id = '#WarehouseMasterId#'
					WHERE Contract_Main_ID = '#Form.Contract_Main_ID#' AND
							Deleted = 0 AND
							ISNULL(Warehouse_Master_Id,0) = 0
				</cfquery>
			</cfif>
		</cfif>
		
		<cfif form.plannerID EQ 0>
			<CFIF CheckForExistingDistributors.Recordcount EQ 0>
				<!--- REDIRECTOR --->
				<cfset useLakebaseForgetContractProgramID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForgetContractProgramID>
	<cftry>
		<cfset getContractProgramID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#Form.Contract_Main_ID#",
				"select" = "programtype_id"
			}), "programtype_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetContractProgramID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetContractProgramID>
<cfquery name="getContractProgramID" datasource="#application.datasource#">
					SELECT ProgramType_ID
					FROM Contract_Main
					WHERE COntract_Main_ID = '#Form.Contract_Main_ID#'
				</cfquery>
</cfif>
	
				<CFSET redirector_Program_ID = getContractProgramID.ProgramType_ID>
				<CFSET redirector_FromPage_ID = 4>
				<cfset CSL_Contract_Main_Id = Form.Contract_Main_ID />
				<cfinclude template="internal_redirector_based_on_settings.cfm">
				<CFLOCATION url="redirect.cfm?destination=#redirector_NextLocation#&CID=#URL.CID#">
			<CFELSE>
				<cflocation url="Contract_Edit_Menu.cfm?CID=#URL.CID#">
			</CFIF>
		<cfelse>
			<cfoutput>
				<script>
					window.location.href="/planners/create/planner_alternate_customers.cfm?bedit=#URL.bEdit#&plannerId=#form.plannerId#&CID=#form.CID#";
				</script>
			</cfoutput>
		</cfif>
			
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---////////////////////////////////////// Save Into the database end /////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->

	</CFIF><!------FORM.WeightAssignmentCompleted EQ 0----->


</CFIF><!------FORM.finishedselectingitems EQ 1----->

