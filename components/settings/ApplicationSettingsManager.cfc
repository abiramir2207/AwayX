<!---
FILENAME:   components/settings/ApplicationSettingsManager.cfm
Copyright   (c) 2008 Blacksmith Applications, Inc.
CREATED:  ??/??/??  ??
EDITED:   09/26/08  RBL [16314]
--->
<cfcomponent hint="Futures Pricing Settings Manager" extends="components.Base">
  <cfset this.settings = CreateObject("component","components.settings.ApplicationSettings").init() />

  <cffunction name="init" output="false" returntype="components.settings.ApplicationSettingsManager">

	<cfset useLakebaseForthis_original = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_application_settings")>
<cfif useLakebaseForthis_original>
	<cftry>
		<cfset this.original = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_application_settings", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForthis_original = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForthis_original>
<cfquery name="this.original" datasource="#application.datasource#">
		SELECT * FROM _Application_Settings
	</cfquery>
</cfif>

  	<cfreturn this />
  </cffunction>

<cffunction name="get" output="false" returntype="components.settings.ApplicationSettings">
	<cfargument name="loadSettings" type="numeric" required="false" default="1">
	<cfargument name="settingsType" type="numeric" required="false" default="0">
	<cfargument name="reload" type="numeric" required="false" default="0">
	<cfif arguments.reload EQ 0 AND arguments.loadSettings EQ 1>
		<cfset this.settings = application.appSettingsGet />
		<cfreturn this.settings />
	</cfif>
	<cfif arguments.loadSettings>
		<cfquery name="qGetSettings" datasource="#application.datasource#">
			SELECT  *
			<cfif arguments.settingsType EQ 1>
				,
				_Application_Settings.App_Settings_Updated_By Updated_By,
				_Users.Name_First + ' ' + _Users.Name_Last AS UpdatedByFullName,
				App_Settings_Updated_On Updated_On
			<cfelseif arguments.settingsType EQ 2>
				,
				_Application_Settings.Internal_Settings_Updated_By Updated_By,
				_Users.Name_First + ' ' + _Users.Name_Last AS UpdatedByFullName,
				Internal_Settings_Updated_On Updated_On
			<cfelseif arguments.settingsType EQ 3>
				,
				_Application_Settings.Approval_Settings_Updated_By Updated_By,
				_Users.Name_First + ' ' + _Users.Name_Last AS UpdatedByFullName,
				Approval_Settings_Updated_On Updated_On
			<cfelseif arguments.settingsType EQ 4>
				,
				_Application_Settings.Password_Settings_Updated_By Updated_By,
				_Users.Name_First + ' ' + _Users.Name_Last AS UpdatedByFullName,
				Password_Settings_Updated_On Updated_On
			<cfelseif arguments.settingsType EQ 6>
				,
				_Application_Settings.Margin_Settings_Updated_By Updated_By,
				_Users.Name_First + ' ' + _Users.Name_Last AS UpdatedByFullName,
				Margin_Settings_Updated_On Updated_On
			<cfelseif arguments.settingsType EQ 7>
				,
				_Application_Settings.Billback_Labels_Updated_By Updated_By,
				_Users.Name_First + ' ' + _Users.Name_Last AS UpdatedByFullName,
				Billback_Labels_Updated_On Updated_On
			<cfelseif arguments.settingsType EQ 8>
				,
				_Application_Settings.Pullback_Labels_Updated_By Updated_By,
				_Users.Name_First + ' ' + _Users.Name_Last AS UpdatedByFullName,
				Pullback_Labels_Updated_On Updated_On
			<cfelseif arguments.settingsType EQ 9>
				,
				_Application_Settings.Table_Column_Labels_Updated_By Updated_By,
				_Users.Name_First + ' ' + _Users.Name_Last AS UpdatedByFullName,
				Table_Column_Labels_Updated_On Updated_On
			<cfelseif arguments.settingsType EQ 10>
				,
				_Application_Settings.Pricing_level_Labels_Updated_By Updated_By,
				_Users.Name_First + ' ' + _Users.Name_Last AS UpdatedByFullName,
				Pricing_level_Labels_Updated_On Updated_On
			<cfelseif arguments.settingsType EQ 11>
				,
				_Application_Settings.Program_Summary_Labels_Updated_By Updated_By,
				_Users.Name_First + ' ' + _Users.Name_Last AS UpdatedByFullName,
				Program_Summary_Labels_Updated_On Updated_On
			<cfelseif arguments.settingsType EQ 12>
				,
				_Application_Settings.Product_Labels_Updated_By Updated_By,
				_Users.Name_First + ' ' + _Users.Name_Last AS UpdatedByFullName,
				Product_Labels_Updated_On Updated_On
			<cfelseif arguments.settingsType EQ 13>
				,
				_Application_Settings.Distributor_Labels_Updated_By Updated_By,
				_Users.Name_First + ' ' + _Users.Name_Last AS UpdatedByFullName,
				Distributor_Labels_Updated_On Updated_On
			<cfelseif arguments.settingsType EQ 14>
				,
				_Application_Settings.Settings_Panel_Access_Updated_By Updated_By,
				_Users.Name_First + ' ' + _Users.Name_Last AS UpdatedByFullName,
				Settings_Panel_Access_Updated_On Updated_On
			<cfelseif arguments.settingsType EQ 15>
				,
				_Application_Settings.Approval_Via_Email_Updated_By Updated_By,
				_Users.Name_First + ' ' + _Users.Name_Last AS UpdatedByFullName,
				Approval_Via_Email_Updated_On Updated_On
			<cfelseif arguments.settingsType EQ 16>
				,
				_Application_Settings.General_Labels_Updated_By Updated_By,
				_Users.Name_First + ' ' + _Users.Name_Last AS UpdatedByFullName,
				General_Labels_Updated_On Updated_On
			<cfelseif arguments.settingsType EQ 17>
				,
				_Application_Settings.Deduction_Labels_Updated_By Updated_By,
				_Users.Name_First + ' ' + _Users.Name_Last AS UpdatedByFullName,
				Deduction_Labels_Updated_On Updated_On
				<!--- Dev Note: Drachala; D27872: Add new Billback Lables START--->
			<cfelseif arguments.settingsType EQ 18>
				,
				_Application_Settings.Billback_Labels_Updated_By Updated_By,
				_Users.Name_First + ' ' + _Users.Name_Last AS UpdatedByFullName,
				Billback_Labels_Updated_On Updated_On
				<!--- Dev Note: Drachala; D27872: Add new Billback Lables END--->
				<!--- 29856	labels for Fixed Price, Rebate, Lump Sum, Growth --->
			<cfelseif arguments.settingsType EQ 19>
				,
				_Application_Settings.Discount_Type_Labels_Updated_By,
				_Users.Name_First + ' ' + _Users.Name_Last AS UpdatedByFullName,
				Discount_Type_Labels_Updated_On Updated_On
				<!--- 29856	labels for Fixed Price, Rebate, Lump Sum, Growth --->
			<cfelseif arguments.settingsType EQ 20>
				,
				_Application_Settings.Dashboard_Labels_Updated_By Updated_By,
				_Users.Name_First + ' ' + _Users.Name_Last AS UpdatedByFullName,
				Dashboard_Labels_Updated_On Updated_On
			<!--- 63670 - labels for program letters --->
			<cfelseif arguments.settingsType EQ 21>
				,
				_Application_Settings.Program_Letters_Labels_Updated_By Updated_By,
				_Users.Name_First + ' ' + _Users.Name_Last AS UpdatedByFullName,
				Program_Letters_Labels_Updated_On Updated_On
			<!--- 64600 - labels for planner --->
			<cfelseif arguments.settingsType EQ 22>
				,
				_Application_Settings.Planner_Labels_Updated_By Updated_By,
				_Users.Name_First + ' ' + _Users.Name_Last AS UpdatedByFullName,
				Planner_Labels_Updated_On Updated_On
			</cfif>
			FROM  _Application_Settings
			<cfif arguments.settingsType EQ 1>
				LEFT JOIN _Users
				ON
				_Users.Deleted = 0
				AND
				_Users.User_ID = _Application_Settings.App_Settings_Updated_By
			<cfelseif arguments.settingsType EQ 2>
				LEFT JOIN _Users
				ON
				_Users.Deleted = 0
				AND
				_Users.User_ID = _Application_Settings.Internal_Settings_Updated_By
			<cfelseif arguments.settingsType EQ 3>
				LEFT JOIN _Users
				ON
				_Users.Deleted = 0
				AND
				_Users.User_ID = _Application_Settings.Approval_Settings_Updated_By
			<cfelseif arguments.settingsType EQ 4>
				LEFT JOIN _Users
				ON
				_Users.Deleted = 0
				AND
				_Users.User_ID = _Application_Settings.Password_Settings_Updated_By
			<cfelseif arguments.settingsType EQ 6>
				LEFT JOIN _Users
				ON
				_Users.Deleted = 0
				AND
				_Users.User_ID = _Application_Settings.Margin_Settings_Updated_By
			<cfelseif arguments.settingsType EQ 7>
				LEFT JOIN _Users
				ON
				_Users.Deleted = 0
				AND
				_Users.User_ID = _Application_Settings.Billback_Labels_Updated_By
			<cfelseif arguments.settingsType EQ 8>
				LEFT JOIN _Users
				ON
				_Users.Deleted = 0
				AND
				_Users.User_ID = _Application_Settings.Pullback_Labels_Updated_By
			<cfelseif arguments.settingsType EQ 9>
				LEFT JOIN _Users
				ON
				_Users.Deleted = 0
				AND
				_Users.User_ID = _Application_Settings.Table_Column_Labels_Updated_By
			<cfelseif arguments.settingsType EQ 10>
				LEFT JOIN _Users
				ON
				_Users.Deleted = 0
				AND
				_Users.User_ID = _Application_Settings.Pricing_Level_Labels_Updated_By
			<cfelseif arguments.settingsType EQ 11>
				LEFT JOIN _Users
				ON
				_Users.Deleted = 0
				AND
				_Users.User_ID = _Application_Settings.Program_Summary_Labels_Updated_By
			<cfelseif arguments.settingsType EQ 12>
				LEFT JOIN _Users
				ON
				_Users.Deleted = 0
				AND
				_Users.User_ID = _Application_Settings.Product_Labels_Updated_By
			<cfelseif arguments.settingsType EQ 13>
				LEFT JOIN _Users
				ON
				_Users.Deleted = 0
				AND
				_Users.User_ID = _Application_Settings.Distributor_Labels_Updated_By
			<cfelseif arguments.settingsType EQ 14>
				LEFT JOIN _Users
				ON
				_Users.Deleted = 0
				AND
				_Users.User_ID = _Application_Settings.Settings_Panel_Access_Updated_By
			<cfelseif arguments.settingsType EQ 15>
				LEFT JOIN _Users
				ON
				_Users.Deleted = 0
				AND
				_Users.User_ID = _Application_Settings.Approval_Via_Email_Updated_By
			<cfelseif arguments.settingsType EQ 16>
				LEFT JOIN _Users
				ON
				_Users.Deleted = 0
				AND
				_Users.User_ID = _Application_Settings.General_Labels_Updated_By
			<cfelseif arguments.settingsType EQ 17>
				LEFT JOIN _Users
				ON
				_Users.Deleted = 0
				AND
				_Users.User_ID = _Application_Settings.Deduction_Labels_Updated_By
				<!--- Dev Note: Drachala; D27872: Add new Billback Lables START--->
			<cfelseif arguments.settingsType EQ 18>
				LEFT JOIN _Users
				ON
				_Users.Deleted = 0
				AND
				_Users.User_ID = _Application_Settings.Billback_Labels_Updated_By
				<!--- Dev Note: Drachala; D27872: Add new Billback Lables END--->
				<!--- 29856	labels for Fixed Price, Rebate, Lump Sum, Growth --->
			<cfelseif arguments.settingsType EQ 19>
				LEFT JOIN _Users
				ON
				_Users.Deleted = 0
				AND
				_Users.User_ID = _Application_Settings.Discount_Type_Labels_Updated_By
				<!--- 29856	labels for Fixed Price, Rebate, Lump Sum, Growth --->
			<cfelseif arguments.settingsType EQ 20>
				LEFT JOIN _Users
				ON
				_Users.Deleted = 0
				AND
				_Users.User_ID = _Application_Settings.Dashboard_Labels_Updated_By
			<!--- 63670 - labels for program letters --->
			<cfelseif arguments.settingsType EQ 21>
				LEFT JOIN _Users
				ON
				_Users.Deleted = 0
				AND
				_Users.User_ID = _Application_Settings.Program_Letters_Labels_Updated_By
			<!--- 64600 - labels for planner --->
			<cfelseif arguments.settingsType EQ 22>
				LEFT JOIN _Users
				ON
				_Users.Deleted = 0
				AND
				_Users.User_ID = _Application_Settings.Program_Letters_Labels_Updated_By
			</cfif>
		</cfquery>
		<cfloop query="qGetSettings">
			<cfscript>
			//  <!------ 1 ----->
			this.settings.setProgramInterfaceBuffer(Program_Interface_Buffer) ;
			this.settings.setawaitingactiondays(awaiting_action_days) ;
			this.settings.setTrafficInfoDays(traffic_info_days) ;
			this.settings.setPrinter2Name(Printer2_Name) ;
			this.settings.setProgramNumberPrefix(Program_Number_Prefix) ;
			this.settings.setBillbackNumberPrefix(Billback_Number_Prefix) ;
			this.settings.setDeductionNumberPrefix(Deduction_Number_Prefix) ;
			this.settings.setDDCreditNumberPrefix(DD_Credit_Number_Prefix) ;
			this.settings.setPlannerNumberPrefix(Planner_Number_Prefix) ;
			this.settings.setAutoClaimBuffer(Auto_Claim_Buffer) ;
			this.settings.setDocumentPath(Document_Path) ;
			this.settings.setDocumentMapping(Document_Mapping) ;
			//  <!------ 2 ----->
			this.settings.setDollarGrowth(Dollar_Growth) ;
			this.settings.setUseXMaterial(Use_X_Material) ;
			this.settings.setUseProductGroup1(UseProductGroup1) ;
			this.settings.setUseProductGroup2(UseProductGroup2) ;
			this.settings.setUseProductGroup3(UseProductGroup3) ;
			this.settings.setUseProductGroup4(UseProductGroup4) ;
			this.settings.setUseProductGroup5(UseProductGroup5) ;
			this.settings.setUseProductHierarchy(UseProductHierarchy) ;
			this.settings.setAppSettingsOnForAll(ApplicationSettingsOnForAll) ;
			this.settings.setSendAutoAttachments(Send_Auto_Attachments) ;
			this.settings.setAutoBroker(Auto_Broker) ;
			this.settings.setRfaAgree(RFA_Agree) ;
			this.settings.setCustomertype(Customer_type) ;
			this.settings.setRestrictProductUOM(Restrict_Product_UOM) ;
			this.settings.setAllowNavigate(AllowNavigate) ;
			this.settings.setRebateMaxComponents(Rebate_Max_Components) ;
			this.settings.setLabelNotes(LabelNotes) ;
			this.settings.setFloorPrice(Floor_Price) ;
			this.settings.setLumpMultipleProducts(Lump_Multiple_Products) ;
			this.settings.setprogramnotesrequired(programnotesrequired) ;
			this.settings.setEquipment_Placement(Equipment_Placement) ;
			this.settings.setSendApprovedProgramsEmailAdress(Send_Approved_Programs_EmailAdress) ;
			this.settings.setClasscodesOn(Classcodes_On) ;
			this.settings.setsendsecondaryemail(send_secondary_email) ;
			this.settings.setfixedcomponents_on(fixedcomponents_on) ;
			this.settings.setrolloverprograms_on(rolloverprograms_on) ;
			this.settings.setGrowthExpansion1(Growth_Expansion_1) ;
			this.settings.setForbidAllowProfilesInTemplates(ForbidAllowProfilesInTemplates) ;
			this.settings.setuploadmargintargets_on(uploadmargintargets_on) ;
			this.settings.setRestrictAccessOnGroup(RestrictAccessOnGroup) ;
			this.settings.setbusinessconsiderations_on(businessconsiderations_on) ;
			this.settings.setcustid_on(custid_on) ;
			this.settings.setsinglesign_on(singlesign_on) ;
			this.settings.setBBFixedCalcTypesOn(BB_Fixed_Calc_Types_On) ;
			this.settings.setClaimAutoPrint(claimAutoPrint) ;
			this.settings.setAllowAllDistributors(allowAllDistributors) ;
			this.settings.setMaxProfileCount(maxProfileCount) ;
			this.settings.setDistributorMultiPosition(distributorMultiPosition) ;
			this.settings.setOperatorSearchRestrict(operatorSearchRestrict) ;
			this.settings.setSalesOrgOn(Sales_Org_On) ;
			this.settings.setDistributionChannelOn(Distribution_Channel_On) ;
			this.settings.setDeleteProgramMessage(Delete_Program_Message) ;
			this.settings.setDeleteIsCancelAutoRenew(Delete_Autorenew_Pgm_Is_Cancel) ;
			this.settings.setcancelProgramEmail(Cancel_Program_Email) ;
			this.settings.setPaymentCycleAtDiscountType(Payment_Cycle_At_Discount_Type) ;
			this.settings.setSettlement_SAP_Business(Settlement_SAP_Business) ;
			this.settings.setSysco_Report_On(Sysco_Report_On) ;
			this.settings.setSend_to_SAP(Send_to_SAP) ;
			this.settings.settemplatecodes_on(templatecodes_on) ;
			this.settings.setbusiness_segment_label(business_segment_label) ;
			this.settings.setintegation_Instance_ID(Integation_Instance_ID) ;
			this.settings.setBB_Ref_Num_Max_Length(BB_Ref_Num_Max_Length) ;
			this.settings.setBB_2Ref_Num_Max_Length(BB_2Ref_Num_Max_Length) ;
			this.settings.setLOB_label(LOB_label) ;
			this.settings.setAllowMultiLevelGroups(Allow_Multi_Level_Groups) ;
			this.settings.setProgramAgreeEscalate(Program_Agree_Escalate) ;
			this.settings.setCheckOrderClass(Check_Order_Class) ;
			this.settings.setOrderClassValue(Order_Class_Value) ;
			this.settings.setBB_Payee_Operator_Ship_To_Req(BB_Payee_Operator_Ship_To_Req) ;
			this.settings.setVendor_Selection_Pay_Req(Vendor_Selection_Pay_Req) ;
			this.settings.setBillback_Payment_Request_Without_Vendor_Selection(Billback_Payment_Request_Without_Vendor_Selection);
			this.settings.setSkipVendorSelectionOnBBApproval(Skip_Vendor_Selection_On_BB_Approval);
			this.settings.setRestrict_DD_Reason_Code_By_Closing_method(Restrict_DD_Reason_Code_By_Closing_method) ;
			this.settings.setMultiple_BB_Per_Deduction(Multiple_BB_Per_Deduction) ;
			this.settings.setAllow_Negative_Billback(Allow_Negative_Billback) ;
			this.settings.setBB_Allow_Off_Invoice_Closing_Method(BB_Allow_Off_Invoice_Closing_Method) ;
			this.settings.setInterface_700_To_Client(Interface_700_To_Client) ;
			this.settings.setDD_Show_reassign(DD_Show_reassign) ;
			this.settings.setAuto_Deviation_On(Auto_Deviation_On) ;
			this.settings.setDD_Show_Classification(DD_Show_Classification) ;
			this.settings.setDD_Show_DeductionType(DD_Show_DeductionType) ;       //  <!---26487--->
			this.settings.setDD_Show_Edit_Customer_Num(DD_Show_Edit_Customer_Num) ;
			//  <!---   this.settings.setDD_Show_Write_Off(DD_Show_Write_Off) ; --->
			this.settings.setDD_Show_Create_Adjustment(DD_Show_Create_Adjustment) ;
			this.settings.setComponent_Product_Restrictions_On(Component_Product_Restrictions_On) ;
			this.settings.setDD_Show_Delete(DD_Show_Delete) ;
			this.settings.setDD_Show_ReOpen(DD_Show_ReOpen) ;
			this.settings.setDD_Show_Reject(DD_Show_Reject) ;
			this.settings.setDD_Show_Program(DD_Show_Program) ;
			this.settings.setDD_Show_Invoices(DD_Show_Invoices) ;
			this.settings.setDD_Allow_Non_Trade(DD_Allow_Non_Trade) ; //<!--- D29481:Non trade deductions START--->
			this.settings.setERP_Deal_ID_PopUp(ERP_Deal_ID_PopUp) ;
			this.settings.setBB_Allow_UnKnow_Program_Creation(BB_Allow_UnKnow_Program_Creation) ;
			this.settings.setBB_Pay_Req_Dup_Check(BB_Pay_Req_Dup_Check) ;
			//  <!---   this.settings.setTemplate_Notes_Availability(Template_Notes_Availability) ;  ---> //  <!--- BJF: Removed with label 13333  --->
			this.settings.setMatch_BB_DD_Based_On_Same_ReferenceNum(Match_BB_DD_Based_On_Same_ReferenceNum) ;
			this.settings.setUserNumberRestrict(User_Number_Restrict) ;
			this.settings.setUSDANOIEnabled(USDANOI_Enabled) ;
			this.settings.setProductSearchGetProductByProgramOn(Program_By_Product_On) ;
			this.settings.setDisableGroupProductSearchINproductSearch(Disable_Group_Selection_In_Product_Search) ;
			this.settings.setStartAutoRenewAtRFA(Start_Auto_Renew_At_RFA) ;
			this.settings.setDistSearchGetDistByProgramOn(Dist_Search_Get_Dist_By_Program_On) ;
			this.settings.setInvoiceBrokerFilterRestrict(Invoice_Broker_Filter_Restrict) ;
			this.settings.setCustsearchRebaterecipientOn(CustsearchRebaterecipientOn) ;
			this.settings.setViewProgramProductGroupType(View_Program_Product_Group_Type) ;
			this.settings.setOneProgramPerBillback(One_Program_Per_Billback) ;
			this.settings.setProgramBudgetOn(Program_Budget_On) ;
			this.settings.setSpendingCapVersion(Spending_Cap_Version) ;
			this.settings.setGrowthDecimal4PercentTier(Growth_Decimal_4_Percent_Tier) ;
			this.settings.setCaptureGroupsOnSave(Capture_Groups_On_Save) ;
			this.settings.setForInvoicesDisplayOI(For_Invoices_Display_OI) ;
			this.settings.setBidRequestPriceListId(Bid_Request_Price_List_ID) ;
			this.settings.setRFAEmailEvent(RFA_Email_Event) ;
			this.settings.setBbAgreeEmail(BB_Agree_Email) ;
			this.settings.setBBCheckPayTo(BB_Check_Pay_To) ;
			this.settings.setAppErrorAddToPunchlist(App_Error_Add_To_Punchlist) ;
			this.settings.setdisableBBAddProgram(disable_BB_Add_Program) ;
			this.settings.setPgmLumpsumDetailedDisplay(Pgm_Lumpsum_Detailed_Display) ;
			this.settings.setGroupByGroupType(Group_By_Group_Type) ;
			this.settings.setShowORHideGroupsInViewMargin(Show_Or_Hide_Groups) ;
			this.settings.setRenew_expired_programs(Renew_expired_programs) ;
			this.settings.setUse_Accounting_Program_Type(Use_Accounting_Program_Type) ;
			this.settings.setBB_PP_Manual_Discount(BB_PP_Manual_Discount) ;
			this.settings.setBBDateDevInExpectedVol(BB_Date_Dev_In_Expected_Vol) ;
			this.settings.setShowBSAOperators(Show_BSA_Operators) ;
			this.settings.setBidRequestAvailable(Bid_Request_Available) ;
			this.settings.setFuturesPricingAvailable(Futures_Pricing_Available) ;
			this.settings.setExternalWebserviceURL(External_Webservice_URL) ;
			this.settings.setWebserverInternalIPAddress(Webserver_Internal_IP_Address) ;
			this.settings.setAutoRenewSpaninPW(AutoRenewSpaninPW) ;
			this.settings.setlettersavailable(letters_available) ;
			this.settings.setDeviationLabel(Deviation_Label) ;
			this.settings.setProgram_Allow_Null_Rate(Program_Allow_Null_Rate) ;
			this.settings.setClaims_at_Comp_Level(Claims_at_Comp_Level) ;
			this.settings.setPgmDisableEditWhileSendingToClient(Pgm_Disable_Edit_While_Sending_To_Client) ;
			this.settings.setOperatingGroupOn(Operating_Group_On) ;
			this.settings.setlettersavailable(letters_available) ;
			this.settings.setlettersfromemail(letters_from_email) ;
			this.settings.setletterssubject(letters_subject) ;
			this.settings.setSearchSequenceOn(Search_Sequence_On) ;
			this.settings.setlocalcostvariables(local_cost_variables) ;
			this.settings.setcustomerbasedcosts(customer_based_costs) ;
			this.settings.setmaxlocalcostvars(max_local_cost_vars) ;
			this.settings.setPgmGrpsOnlyProdAtLowerLevel(Pgm_Grps_Only_Prod_At_Lower_Level) ;
			this.settings.setprintincludeheader(print_includeheader) ;
			this.settings.setpricingtemplatelist(pricing_template_list) ;
			this.settings.setShowProjectsScoreCard(Show_Projects_ScoreCard) ;
			this.settings.setPgmScorecardRevisionReport(Pgm_Scorecard_Revision_Report) ;
			this.settings.setInvoicePositionRestriction(Invoice_Position_Restriction) ;
			this.settings.setDistributorLetterName(Distributor_Letter_Name) ;
			this.settings.setOperatorLetterName(Operator_Letter_Name) ;
			this.settings.setRemoveMarketFromPgmSearchPage(Remove_Market_From_Pgm_SearchPage) ;
			this.settings.setCheckAllDuplicateProgram(Check_All_Duplicate_Program) ;
			this.settings.setAuthority_Sequence_For_HQ_Only(Authority_Sequence_For_HQ_Only) ;
			this.settings.setPgmViewDisplaySPRAddress2(Pgm_View_Display_SPR_Address2) ;
			this.settings.setBidRequestHierarchyLevel(Bid_Request_Hierarchy_Level) ;
			this.settings.settradeplanneroff(Trade_Planner_Off) ;
			this.settings.setapprovalmatrixoff(Approval_Matrix_Off) ;
			this.settings.setAllowed_to_Add_Operator(Allowed_to_Add_Operator) ;
			this.settings.setCreated_Operators_Default_Active(Created_Operators_Default_Active) ;
			this.settings.setPgmEmailPricingAdmin(Pgm_Email_Pricing_Admin) ;
			this.settings.setLettersAcceptedBy(Letters_Accepted_By) ;
			this.settings.setLettersAddress(Letters_Address) ;
			this.settings.setBBRestrictRouteUserList(BB_Restrict_Route_User_List) ;
			this.settings.setCommonAccessURLPrefix(Common_Access_URL_Prefix) ;
			this.settings.setPgmLikeProductCheckbox(Pgm_Like_Product_Checkbox) ;
			this.settings.setviewapprovedmarginsreport(view_approved_margins_report) ;
			this.settings.setPgmDisplayBothRateUOM(Pgm_Display_Both_Rate_UOM) ;
			this.settings.setretainoriginalRSP(retain_original_RSP) ;
			this.settings.setDailyRSPUpdate(Daily_RSP_Update) ;
			this.settings.setMass_Pay_Billback(Mass_Pay_Billback) ;
			this.settings.setClaimMech_Popup(ClaimMech_Popup) ;
			this.settings.setDisplayOnlyAssignedDeductions(Display_Only_Assigned_Deductions) ;
			this.settings.setcancelallprogramversions(cancel_all_program_versions) ;
			this.settings.setShowMapping(Show_Mapping) ;
			this.settings.setAvoidSharedProductsinLumpSum(disallow_shared_products_in_lumpsum) ;
			this.settings.setRemoveHelpIcon(Remove_Help_Icon) ;
			this.settings.Setdisplayclientshelpdeskinfo(display_clients_help_desk_info) ;
			this.settings.setClientsHelpDeskInfo(clients_help_desk_info) ;
			this.settings.setUserFaxNumber(User_Fax_Number) ;
			this.settings.setBillbacksSalesTax(Billbacks_Sales_Tax) ;
			this.settings.setrevisionreportuom(revision_report_uom) ;
			this.settings.setdisplayzerosviewprogram(display_zeros_view_program) ;
			this.settings.setApplyRSPFilters(Apply_RSP_Filters) ;
			this.settings.setdirectpricingon(direct_pricing_on) ;
			this.settings.setPgmGrpLevel3IsExclusion(Pgm_Grp_Level3_Is_Exclusion) ;
			this.settings.setShowUploadAccrual(ShowUploadAccrual) ;
			this.settings.setBonusInGrowthSwitch(Bonus_Growth_Switch) ;
			this.settings.setSearchProductHierarchyExcludeList(Search_Product_Hierarchy_Exclude_List) ;
			this.settings.setletterscompanylogopath(letters_company_logo_path) ;
			this.settings.setpaymenthistoryon(payment_history_on) ;
			this.settings.setBBAllowVendorMasterSearch(BB_Allow_Vendor_Master_Search) ;
			this.settings.setVendorSearchInBBPayeePage(Vendor_Search_In_BB_Payee_Page) ;
			this.settings.setBBAllowVendorCrossRefSearch(BB_Allow_Vendor_Cross_Ref_Search) ;
			this.settings.setDDReassignAnalystWhileChangingPayTo(DD_Reassign_Analyst_While_Changing_Pay_To) ;
			this.settings.setDDAssignmentBasedOnShrShipto(DD_Assignment_Based_On_Shr_Ship_to) ;
			this.settings.setDDAllowNegativeAmountCredits(DD_Allow_Negative_Amount_Credits) ;
			this.settings.setDDChangeClassificationBeforeRFA(DD_Change_Classification_Before_RFA) ;
			this.settings.setDDAllowWriteOff(DD_Allow_Write_Off) ;
			this.settings.setDDSentRejectIn1510(DD_Sent_Reject_In_1510) ;
			this.settings.setDDCloseWithEqualBBAmt(DD_Close_With_Equal_BB_Amt) ;
			this.settings.setPullBack_Start_Date(PullBack_Start_Date) ;
			this.settings.setPopulate_180Day_From(Populate_180Day_From) ;
			this.settings.setBidRequestUsePriceByDate(BidRequest_Use_Price_ByDate) ;
			this.settings.setBidRequestComponentsOn(BidRequest_Components_On) ;
			this.settings.setDontReviseUntillSAPokAck(DontRevise_Untill_SAP_OKack) ;//  <!--- Dev Note: KAL; D8067 --->
			this.settings.setLumpSumDistributors(Show_LumpSum_Distributors) ;
			this.settings.setShow_BB_Route(Show_BB_Route) ;
			this.settings.setsenddistributorbrokeremail(send_distributor_broker_email) ;
			this.settings.set_Requester_Approver(Display_Requester_Approver) ;
			this.settings.set_Requester_Approver_Position(Display_Requester_Approver_Position) ;
			this.settings.setHide_BSA_Users(Hide_BSA_Users) ;
			this.settings.setHQpositionsOn(HQpositionsOn) ;
			this.settings.set_Report_Payment_History(Report_Payment_History) ;
			this.settings.setUploadDocumentPrivacyOff(Upload_Document_Privacy_Off) ;
			this.settings.setDivideProgramVolumeForGroups(Divide_Pgm_Vol_4_Groups) ;
			this.settings.setProgramVolumeShowGroups(Pgm_Vol_Show_Groups) ;
			this.settings.setShowManagerDetailsOnViewProgram(ShowManagerDetailsOnViewProgram) ;
			this.settings.setViewPgmSortBy(ViewPgmSortBy) ; //  <!--- Dev Note: CPM 8223 --->
			this.settings.setCrucibleOn(Crucible_On) ;
			this.settings.setBrokerTradeQuestOn(Broker_Trade_Quest_On) ;
			this.settings.setProgramCategory(Show_Program_Category) ; //  <!--- Dev Note: Milan 8452 --->
			this.settings.setPullbacksOn(PullbacksOn) ;
			this.settings.setPullbackLabel(Pullback_Label) ; //  <!--- Dev Note: DRK 9326 --->
			this.settings.setPgmPostApprovalStatus(Pgm_Post_Approval_Status) ;
			this.settings.setPgmPostApprovalStatusType(Pgm_Post_Approval_Status_Type) ;//  <!--- Dev Note: DRK 6122 --->
			this.settings.setConfidentialityAgreementStatus(Turn_off_Confidentiality_Agreement) ; //  <!--- Dev Note: Milan 8469 --->
			this.settings.setRemoteEventsEmail(Remote_Events_Email) ; //  <!--- Dev Note: Milan 8482 --->
			this.settings.setProgramScoreCard(Operator_Distributor_On_Program_Scorecard) ; //  <!--- Dev Note: Milan 8516 --->
			this.settings.setNumberOfDaysForMiniItemMaster(Number_Of_Days_For_Mini_Item_Master) ;//  <!--- Dev Note: Milan 8471 --->
			this.settings.setDisplayEvaluationNotes(Display_Evaluation_Notes) ;//  <!--- Dev Note: CPM 8506 --->
			this.settings.setRemoveBrokerSelection(Remove_Broker_Selection) ;//  <!--- Dev Note: CPM 8536 --->
			this.settings.setAppErrorEmailLinkAlone(App_Error_Email_Link_Alone) ;
			this.settings.setDisplayEligibleRSP(Display_Eligible_RSP) ;//  <!--- Dev Note: CPM 7920 --->
			this.settings.setBBDisplayResubmit(BB_Display_Resubmit) ;
			this.settings.setBBAllowReverse(BB_Allow_Reverse) ;
			this.settings.setUseItemCustPrice(Use_Item_Cust_Price) ;
			this.settings.setShowBBExcelReport(Show_BB_Excel_Report) ;//  <!--- Dev Note: Milan 8521 --->
			this.settings.setDisplayInterfaceFlagsSet1(DisplayInterfaceFlagsSet1) ;
			this.settings.setShowManualBillback(Show_Manual_Billback) ;//  <!--- Dev Note: Milan 9165 --->
			this.settings.setShowAutoBillback(Show_Auto_Billback) ;//  <!--- Dev Note: Milan 9165 --->
			this.settings.setAutoBillBackType(Auto_BillBack_Type) ;//  <!--- Dev Note: Milan 9165 --->
			this.settings.setPriceListdisplayedRightClick(PriceList_displayed_Right_Click) ;//  <!--- Dev Note: GV 9284 --->
			this.settings.setView_Trade_Checkbook(View_Trade_Checkbook) ;//  <!--- Dev Note: BJF 9313 --->
			this.settings.setView_Auto_Checkbook(View_Auto_Checkbook) ;//  <!--- Dev Note: BJF 9313 --->
			this.settings.setView_Legacy_ID(View_Legacy_ID) ;//  <!---Dev Note: Milan 9360 --->
			this.settings.setModify_Legacy_ID(Modify_Legacy_ID) ;//  <!---Dev Note: Milan 9360 --->
			this.settings.setRevisionTypesOn(RevisionTypesOn) ;//  <!---Dev Note: GV 9391 --->
			this.settings.setWelcomeLetterOn(Welcome_Letter_On) ; //  <!--- Dev Note: Clay 9254 --->
			this.settings.setTemplateRestrictGroupLevel(Template_Restrict_Group_Level) ;//  <!---Dev Note: DRK 9674 --->
			this.settings.setRestrictHierarchyLevelOnClassCode(Restrict_Hierarchy_Level_On_Class_Code) ;//  <!---Dev Note: DRK 9679 --->
			this.settings.setPasswordRequirementsStatus(Turn_Off_Password_Requirements_Msg) ; //  <!--- Dev Note: Milan 9879 --->
			this.settings.setUse_AccrualLog_For_TC(Use_AccrualLog_For_TC) ; //  <!---Dev Note: BJF 7963 & 10139 --->
			this.settings.setAllowOneComponentforPullbacks(Allow_One_Component_for_Pullbacks) ; //  <!---Dev Note:  Milan 9956 --->
			this.settings.setProgramSpecialRevisionFlag(Program_Special_Revision_Flag) ;//  <!---Dev Note: DRK 10295 --->
			this.settings.setGroupLevelBillback(Group_Level_Billback) ;//  <!---Dev Note: Kal 10343 --->
			this.settings.setAllowUnKnownPayeeInBillback(Allow_Unknown_Payee_In_Billback) ;//  <!---Dev Note: Milan 10380 --->
			this.settings.setHideInvalidComponentTypesInBillbacks(Hide_Invalid_Component_Types_In_Billbacks) ;//  <!---Dev Note: Milan 10433 --->
			this.settings.setBillbackScorecardCache(Billback_Scorecard_Cache) ;//  <!--- 10619 --->
			this.settings.setProgramScorecardCache(Program_Scorecard_Cache) ;//  <!--- 10548 --->
			this.settings.setProjectScorecardCache(Project_Scorecard_Cache) ;
			this.settings.setMultiDistributorBB(Multi_Distributor_BB) ;//  <!---  Dev Note:  MarkS 10055 --->
			this.settings.setUse_Different_From_Address(Use_Different_From_Address);//  <!--- BJF D10644 --->
			this.settings.setDifferent_From_Address(Different_From_Address);
			this.settings.setDifferent_From_Address(Different_From_Address) ;//  <!--- BJF D10644 --->
			this.settings.setUse_Big_Billbacks(Use_Big_Billbacks);//  <!--- BJF D10291 --->
			this.settings.setOnePageClaimForm(One_Page_Claim_Form) ;//  <!--- BDensmore --->
			this.settings.setBillbackClosingMethod(Billback_Closing_Method) ;//  <!---Dev Note: Milan 10605 --->
			this.settings.setLost_Bids_Deviated(Lost_Bids_Deviated);//  <!--- BJF D10608 --->
			this.settings.setFreight_Calculator_On(Freight_Calculator_On);//  <!--- CPM 10941 --->
			this.settings.setLoginPageLogoPath(Login_Page_Logo_Path);
			this.settings.setappEZButtonOn(app_EZButton_On);
			this.settings.setSuppressGroupsZeroItems(suppress_groups_zero_items);
			this.settings.setSuppressBusinessConsiderations(suppress_business_considerations);
			this.settings.setAddTodoOnDocAttach(Add_Todo_On_Doc_Attach) ;
			this.settings.setIncludeUsersEmailAuto(include_users_email_auto) ;
			this.settings.setProgramApprovalForInactiveOperators(Program_Approval_For_Inactive_Operators) ;
			this.settings.setReleaseSettlement(Release_Settlement) ;//  <!--- CPM 11286 --->
			this.settings.setDisableAutoLogin(Disable_Auto_Login) ;//  <!---  Dev Note:  MarkS 11287 --->
			this.settings.setDataIntViewer(Data_Int_Viewer) ;//  <!---  Dev Note:  MarkS 10729 --->
			this.settings.setLumpSumComponentInProgram(same_lump_sum_component_in_program);//  <!--- Dev Note: BSD D11414 --->
			this.settings.setAllow_Percent_Operator_Programs(Allow_Percent_Operator_Programs);//  <!--- Dev Note: BJF D11527 --->
			this.settings.setBBDeviationUseMaxPrice(BB_Deviation_Use_Max_Price) ;//  <!---  Dev Note:  MarkS 11127 --->
			this.settings.setBillbackModifyAgree(Billback_Modify_Agree);//  <!--- Dev Note: KAL; D11049 --->
			this.settings.setOnlyAccrualTPAPullbacks(OnlyAccrualTPA_Pullbacks);
			this.settings.setUOMEAAvailable(UOM_EA_Available);//  <!----- D11545: Create a new Rebate Type for Scan Programs ----->
			this.settings.setPosition_Tree_Display_Distributor(Position_Tree_Display_Distributor); //  <!----- D12004: Remove distributors from tree ----->
			this.settings.setbb_upload_updated(bb_upload_updated) ;  //  <!--- removed with label 18746 --->
			this.settings.setBBAutoReport(BB_Auto_report) ; //  <!---  Dev Note:  MarkS 11427 --->
			this.settings.setBBAutoPayCustomerGroupInInvoice(BB_Auto_Pay_Customer_Group_In_Invoice) ;//  <!--- Dev Note: D18880--->
			this.settings.setBBAutoPayDisablePayEach(BB_Auto_Pay_Disable_Pay_Each) ;//  <!--- Dev Note: D18879--->
			this.settings.setBBAutoPaylumpSum( BB_Auto_Pay_Lump_Sum );   // D29963
			this.settings.setBBAutoPayAllowNegativePaidAmount(BB_Auto_Pay_Allow_Negative_Paid_Amount) ;//  <!--- Dev Note: D19057--->
			this.settings.setBBAutoReportisManuallyConfigured(BB_Auto_Report_isManually_Configured) ;
			this.settings.setBBAutoReportAllowManual(BB_Auto_Report_Allow_Manual) ;
			this.settings.setBBAutoReportAllowReverse(BB_Auto_Report_Allow_Reverse) ;
			this.settings.setPgmMarginRebateUseAutoPayPrice(Pgm_Margin_Rebate_Use_Auto_Pay_Price) ;
			this.settings.setSplitBillbacks(split_billback) ;//  <!--- Dev Note: BSD D11643 Turn Split Billbacks on or off --->
			this.settings.setShowExportPrograms(Show_Export_Programs) ;//  <!--- Dev Note: Milan D11495 Lamb Export - Sales Agreement Application --->
			this.settings.setInterface_BuyingGroup_As_Group_To_Client(Interface_BuyingGroup_As_Group_To_Client) ;
			this.settings.setBBExpectedRateGTClaimRate(BB_Expected_Rate_GT_Claim_Rate) ; //  <!---  Dev Note:  MarkS 12498 --->
			this.settings.setBBAutoReportStartDate(BB_Auto_Report_Start_Date) ; //  <!---  Dev Note:  MarkS 12575 --->
			this.settings.setBudgetsFunctionalityOn(Budgets_Functionality_On) ;
			this.settings.setBudgetSelectionRequired(Budget_Selection_Required) ;
			this.settings.setBudgetSingleLevelForFixed(Budget_Single_Level_For_Fixed) ;
			this.settings.setBudgetsProgramApproveEmailAddress(Budgets_Program_Approve_Email_Address) ;
			this.settings.setBudgetsBillbackApproveEmailAddress(Budgets_Billback_Approve_Email_Address) ;
			this.settings.setDistributor_Product_Integrity_On(Distributor_Product_Integrity_On) ;
			this.settings.setShowClaimAdjustment(Show_Claim_Adjustment) ;//  <!--- D12937: Hide Claim Adj --->
			this.settings.setItemMarginTargetORGrossMarginForPriceList(ItemMarginTarget_OR_GrossMargin_For_PriceList) ;//  <!--- Dev Note: Milan; 13016 --->
			this.settings.setShow_Fixed_Freight(Show_Fixed_Freight) ;//  <!--- Dev Note: BJF 13395 5.0 only --->
			//  <!--- 13397 5.0 only --->
			this.settings.setShow_Component_Accrual(Show_Component_Accrual) ;
			this.settings.setShow_Component_Floor_Pricing(Show_Component_Floor_Pricing) ;
			//  <!--- 13428 5.0 only --->
			this.settings.setGL_Account_On(GL_Account_On) ;
			this.settings.setGL_Account_Required_for_Comp(GL_Account_Required_for_Comp) ;
			this.settings.setExact_List_Matching_On(Exact_List_Matching_On) ;
			//  <!--- Dev Note: KAL; D13469: Brokerage Application Settings --->
			this.settings.setBrokerage_Functionality_On(Brokerage_Functionality_On) ;
			this.settings.setAuto_BB_Create_Status_ID(Auto_BB_Create_Status_ID) ;
			this.settings.setBrokerage_Margin_Calculation(Brokerage_Margin_Calculation) ;
			this.settings.setBB_Reference_Uppercase(BB_Reference_Uppercase) ;
			this.settings.setSuppressBillbackBusinessConsiderations(Suppress_Billback_Business_Considerations);
			this.settings.setDisplayDistributorOffInvoice(Display_Distributor_OffInvoice);
			this.settings.setDisplayProposal(Display_Proposal);
			this.settings.setDisplayUSDANOI(Display_USDANOI);
			this.settings.setDisableAddingComponentsOnRevision(Disable_Adding_Components_On_Revision);
			this.settings.setViewDeleteRecords(View_Delete_Records);
			this.settings.setDD_Negative_Splits(DD_Negative_Splits);
			this.settings.setProgramLockTypeID(Program_Lock_Type_ID);
			this.settings.setLabelSets(Label_Sets);
			this.settings.setProgramClaimRatesReportAvailable(Program_Claim_Rates_Report_Available);
			this.settings.setProgramClaimRatesReportExcludeRegularPrices(Program_Claim_Rates_Report_Exclude_Regular_Prices);
			this.settings.setShowReasonCodeOnBBApprovalScreen(Show_Reason_Code_On_BB_Approval_Screen);
			this.settings.setHide_Billback_Adjustments(Hide_Billback_Adjustments);
			this.settings.setSSL_On_All_Pages(SSL_On_All_Pages);
			this.settings.setAuditTrailStorage(Audit_Trail_Storage);
			this.settings.setAllowBidStatusEditAnytime(Allow_Bid_Status_Edit_Anytime);
			this.settings.setReasonCodeinBillbackDED(Reason_Code_in_Billback_DED);
			this.settings.setShowPricingReport(Show_Pricing_Report);
			this.settings.setDaysOfHistoricalDataForSpecialPriceList(Days_Of_Historical_Data_For_SpecialPriceList);
			this.settings.setBBAllowResetAfterDEDInterface(BB_Allow_Reset_After_DED_Interface);
			this.settings.setBBAllowResetBeforePMTInterfacePRStatus(BB_Allow_Reset_Before_PMT_Interface_PR_Status);
			this.settings.setProductReplacementEnabled(Product_Replacement_Enabled);
			this.settings.setBillbackAllowMultipleBudgets(Billback_Allow_Multiple_Budgets);
			this.settings.setAllowBillbackToCreditMatching(Allow_Billback_To_Credit_Matching);
			this.settings.setMaxFutureDaysForClaimRatesORPricingExtract(Max_Future_Days_For_Claim_Rates_OR_Pricing_Extract);
			this.settings.setIsVantageOn(Is_Vantage_On);
			this.settings.setVantageDataSource(Vantage_DataSource);
			this.settings.setSearch_Selection_Tracking_On(Search_Selection_Tracking_On);
			this.settings.setExpiredRecentlyDays(Expired_Recently_Days);
			this.settings.setPreActiveReplaceParent(Pre_Active_Replace_Parent);
			this.settings.setViewProgramVolumeUOM(View_Program_Volume_UOM);
			this.settings.setViewProgramEstimatedAmount(View_Program_Estimated_Amount);
			this.settings.setFilterBusinessSegments(Filter_Business_Segments);
			this.settings.setProgramAlerts(Program_Alerts);
			this.settings.setReset_Won_Lost_On_Revision(Reset_Won_Lost_On_Revision);
			this.settings.setApprovalViaEmail(Approval_Via_Email);
			this.settings.setDD_Restrict_ShipTo_For_BB(DD_Restrict_ShipTo_For_BB);
			this.settings.setPrimary_Product_Attribute(Primary_Product_Attribute);
			this.settings.setBB_Inserts_Credit_To_Invoices(BB_Inserts_Credit_To_Invoices);
			this.settings.setBB_Status_To_Insert_Credit(BB_Status_To_Insert_Credit);
			this.settings.setShow_BB_Summary_Statement(Show_BB_Summary_Statement);
			this.settings.setOperator_Creation_Fields_Required(Operator_Creation_Fields_Required);
			this.settings.setThirdPartyBBUpload(Third_Party_BB_Upload);
			this.settings.setBBProductAllowZeroVolume(BB_Product_Allow_Zero_Volume);
			this.settings.setBBShowModifyProgram(BB_Show_Modify_Program);
			//  <!---   this.settings.setDisplay_Hold_Release_Checkbox(Display_Hold_Release_Checkbox); --->
			//  <!--- Dev Note: KAL; D20523: App setting to turn flex search tools on/off --->
			this.settings.setFlexProgramSearch(Flex_Program_Search) ;
			this.settings.setFlexDistributorSearch(Flex_Distributor_Search) ;
			this.settings.setFlexBrokerSearch(Flex_Broker_Search) ;
			this.settings.setFlexOperatorSearch(Flex_Operator_Search) ;
			this.settings.setFlexProductSearch(Flex_Product_Search) ;
			this.settings.setDisplayCashDiscountMargin(Display_Cash_Discount_Margin); //  <!--- Dev Note: KAL; D20537 --->
			this.settings.setBBAutoPayToOperatorUseInvoiceOprID(BB_Auto_Pay_To_Operator_Use_Invoice_Opr_ID) ;
			this.settings.setWebserviceOn(WebserviceOn);
			this.settings.setAllowReviseActiveWithPreActive(Allow_Revise_Active_With_Pre_Active);
			this.settings.setCreditTypeIsDDReasonCode(Credit_Type_Is_DD_Reason_Code);
			this.settings.setProgramSearchDollarsAndVolume(Program_Search_Dollars_And_Volume);
			this.settings.setPymtHistoryDollarsIncludeOffInvoiceDollars(Pymt_history_Dollars_Include_OffInvoice_Dollars);
			this.settings.setCheckAllBBDuplicate(Check_All_BB_Duplicate);
			//  <!---  Dev Notes: D23639/Anand Rao/14-Jun-10  BB reason codes --->
			this.settings.setReasonCodeInBillbackDisplaySetting(Reason_Code_in_Billback_Display_Setting);
			this.settings.setSearchInactiveProductsInPrograms(Search_Inactive_Products_Programs);
			this.settings.setSearchInactiveDistributorsInPrograms(Search_Inactive_Distributors_Programs);
			this.settings.setSearchInactiveOperatorsInPrograms(Search_Inactive_Operators_Programs);  //  <!---26199--->
			this.settings.setretainoriginalRSPcopy(retain_original_RSP_copy) ;
			this.settings.setBillback_Module(Billback_Module) ;
			this.settings.setDeduction_Module(Deduction_Module) ;
			this.settings.setBBReasonCodeAllowMultiple(BB_Reason_Code_Allow_Multiple) ;
			this.settings.setMarginItemsExclude(Margin_Items_Exclude) ;
			this.settings.setPlanningGroups(Planning_Groups) ;
			this.settings.setSimpleClause(Simple_Clause) ;
			this.settings.setBC_On_RFA_af_Reset(BC_On_RFA_af_Reset) ;
			this.settings.setRequire_Business_Considerations_On_New_Programs(Require_Business_Considerations_On_New_Programs) ;
			this.settings.setDD_User_Reference(DD_User_Reference) ;
			this.settings.setBBCreatedRecentlyDays(BB_Created_Recently_Days) ;
			this.settings.setDisplayNotesFieldOnProgram(Display_notes_field_on_program);
			this.settings.setUserAccountMiddleInitial(User_Account_Middle_Initial);
			this.settings.setUseFixedPriceType(Use_Fixed_Price_Type);
			this.settings.setDisplayQuoteLetter(Display_Quote_Letter);
			this.settings.setPriceListByTemplate(Price_List_By_Template);
			this.settings.setShortcutNoRoutingAllowed(Shortcut_No_Routing_Allowed);
			this.settings.setPositionFieldsFilterOnProgramSegment(Position_Fields_Filtered_Based_On_Program_Segment);//D28618 Drachala: Position Drop Down Fields filtered based on Program Business Segment
			this.settings.setBaseSaleLabel(Base_Sale_Label);//D28459: Change Base Sales program labels to custom label for Hormel Added This Appsetting Variable.
			this.settings.setNetSaleLabel(Net_Sale_Label);//D28459: Change Base Sales program labels to custom label for Hormel Added This Appsetting Variable.
			this.settings.setErpDeductionDocPath(Erp_Deduction_Doc_Path);
			this.settings.setDisplayOnlyBillbackParent(Display_Only_Billback_Parent);
			this.settings.setDocumentsDisplayUploadForm(Documents_Display_Upload_Form);
			this.settings.setEdit_Product_Master_Data(Edit_Product_Master_Data);
			this.settings.setInvoiceCostForVantage(Invc_Cost_From_Invc_File);// D30750:Create app setting to use invoice cost from invoice file END
			this.settings.setMultipleBillTosForShipTo(Multiple_BillTos_For_ShipTo);// D30486: Multiple AR numbers to 1 Account(Customer)-UI
			this.settings.setDDClosedBBStatus(DD_Closed_BB_Status);
			this.settings.setBBResetUnacknowledgedInterface(BB_Reset_Unacknowledged_Interface);
			this.settings.setBBReinterfaceUnacknowledgedInterface(BB_Reinterface_Unacknowledged_Interface);
			this.settings.setBillbackDisplayAllProgramComponents(Billback_Display_All_Program_Components); //D31378:Add Program w/o Payee Components don't display
			this.settings.setFaviconPath(Favicon_Path);  //31616 -Add favorite icon to URL address line
			this.settings.setBB_LS_Claimed_Rebate_Expected(BB_LS_Claimed_Rebate_Expected);  //31769 - Billback Deviation Grid
			this.settings.setCRAConsiderAnalyst(CRA_Consider_Analyst);//D32585 Drachala: Approval e-mails sending to all TL's
			this.settings.setBillback_Upload_Business_Segment(Billback_Upload_Business_Segment);//D29947 Update billback upload for SO/DC
			this.settings.setBillbackFileUploadType(Billback_File_Upload_Type); // D33957  Modify standard billback upload to one file
			this.settings.setTemplateMultipleProductAttrGroups(Template_Multiple_Product_Attr_Groups);//D35295
			this.settings.setProfitabilityModel(Profitability_Model); //36542
			this.settings.setMassCopy(Mass_Copy);
			this.settings.setAutoRenewScheduled(Auto_Renew_Scheduled); //37007 - Auto Renew sending wrong program email attachments
			this.settings.setBBAutoApproveLogic(Custom_Auto_Approve_Type);//37022
			this.settings.setViewOperatorinBillbackDeviation(View_Operator_in_Billback_Deviation);
			this.settings.setBBOverlapDeviationBasedOnOperator(BB_Overlap_Deviation_Based_On_Operator);
			this.settings.setBBDefaultProgramRetryProcess(BB_Default_Program_Retry_Process);
			this.settings.setBBDefaultProgramRetryAlsoCallDeviation(BB_Default_Program_Retry_Also_Call_Deviation);
			this.settings.setProgram_Allow_Negative_Rebate_Rates(Program_Allow_Negative_Rebate_Rates) ;
			this.settings.setAllowableOverlapPeriod(Allowable_Overlap_Period);
			this.settings.setBB_Inserts_Credit_To_Invoices_GT(BB_Inserts_Credit_To_Invoices_GT);
			this.settings.setProgram_search_dates(Program_search_dates);//D38043  :: Program revision dates - View Program
			this.settings.setUNIPRO_450(UNIPRO_450);
			this.settings.setDeviationGridAllowManualValuesGTClaimed(Deviation_Grid_Allow_Manual_Values_GT_Claimed);
			this.settings.setBBPayeeBrokerShipToReq(BB_Payee_Broker_Ship_To_Req);
			this.settings.setEditableClaimedDollarsQuantity(Editable_Claimed_Dollars_Quantity);
			this.settings.setDDReopenParent(DD_Reopen_Parent); //--- D40312 Heinz ITC - Deductions Reopen Issues
			this.settings.setOperatorQBrandLegacy(Operator_Q_Brand_Legacy);  // D40156
			this.settings.setCancelPgmNoBBMonths(Cancel_Pgm_No_BB_Months);  // D35165
			this.settings.setEnableGroupMembershipDates(Enable_Group_Membership_Dates);
			this.settings.setBBPowerpunch(BB_Powerpunch);  // 43155
			this.settings.setDD_Reopen_Interface(DD_Reopen_Interface) ; // D42284 :: Rebill vs closed deduction reopened
			this.settings.setDeductionQuickUpdate(Deduction_Quick_Update);  // D42846
			this.settings.setAutoApproveProductsOnRevision(Auto_Approve_Products_On_Revision);  // D42590
			this.settings.setBBPaymentRequestHoldRelease(BB_Payment_Request_Hold_Release);  // 43559
			this.settings.setApproveBBBasedOnProfileTotalApprovalAmount(Approve_BB_Based_On_Profile_Total_Approval_Amount);  // 43559
			this.settings.setRFA_Notification_1_Case(RFA_Notification_1_Case);
			this.settings.setShowHoldingPen(Show_Holding_Pen);
			this.settings.setDateTolerance(Date_Tolerance);
			this.settings.setDontSetBidProductStatusRevise(Dont_Set_Bid_Product_Status_on_Revise); //43588
			this.settings.setMassChangePreactive(Mass_Change_Preactive); //44077
			this.settings.setAuto_Reconcile_Match_Central_BB(Auto_Reconcile_Match_Central_BB); // D45778 :Auto Reconcile BB's closed to deduction in 1500
			this.settings.setByPassExpectedRateCalculationEnhancement(By_Pass_Expected_Rate_Calculation_Enhancement); //45864
			this.settings.setPayeeFromPlanningGroups(Payee_From_Planning_Groups); //45076
			this.settings.setBBReferenceNumRequired(BB_ReferenceNum_Required); // 46525
			this.settings.setAllow_BB_Dont_Count_From_Program(Allow_BB_Dont_Count_From_Program); // 48049
			this.settings.setUseInvoiceMarket(Use_Invoice_Market); // 49540
			this.settings.setEnableEDIUploadRawDataViewer(Enable_EDI_Upload_Raw_Data_Viewer); // 49837
			//  <!------ 3 ----->
			this.settings.setApprovalPoundMarginOn(Approval_Pound_Margin_On) ;
			this.settings.setApprovalPercentMarginOn(Approval_Percent_Margin_On) ;
			this.settings.setApprovalTotalPgmMarginOn(Approval_Total_Pgm_Margin_On) ;
			this.settings.setApprovalSpendingCapOn(Approval_Spending_Cap_On) ;
			this.settings.setApprovalLayeredOn(Approval_Layered_On) ;
			this.settings.setApprovalMarginType(Approval_Margin_Type) ; //  <!--- Dev Note: KAL; D20537: Margin Approval - Trade as Percent of Gross Sales. Forge changes --->
			this.settings.setDisplay_Trade_Percent_on_Margin(Display_Trade_Percent_on_Margin) ; //  <!---BJF: 21597 - display related to Kal''s 20537 above --->
			this.settings.setMarginOperatingIncomePercentType(Margin_Operating_Income_Percent_Type) ; //  <!--- Dev Notes: 23637/Anand Rao/08-Jun-10 Operating Income % calculation --->
			this.settings.setApprovalDisposableOn(Approval_Disposable_On) ;
			this.settings.setapprovalStandardOn(Approval_Standard_On) ;
			this.settings.setdisplayclientshelpdeskinfo(display_clients_help_desk_info) ;
			this.settings.setUserFaxNumber(User_Fax_Number) ;
			this.settings.setapprovalLayeredCosts(Approval_Layered_Costs) ;

			this.settings.setUseDCSOBasesales(Use_DC_SO_Base_sales) ;
			this.settings.setusecostmultiplier(use_cost_multiplier) ;
			this.settings.setBidRequestDisplayAllowance(BidRequest_Display_Allowance) ;
			this.settings.setmodifyagreeprogram(modify_agree_program);
			this.settings.setdisablepagesinrfa(disable_pages_in_rfa);//D43661 :: Program RFA status - disable pages and require user to Reset to make any changes
			//  <!--- Dev Note: GV; D9662  --->
			this.settings.setMarginDisplayLB(Margin_Display_LB) ;
			this.settings.setMarginDisplayCS(Margin_Display_CS) ;
			this.settings.setMarginDisplayEQ(Margin_Display_EQ) ;
			this.settings.setMarginDisplayDefault(Margin_Display_default) ;
			this.settings.setshowfixedpriceadditionalfields(showfixedprice_additionalfields) ;
			this.settings.setshowrebateadditionalfields(showrebate_additionalfields) ;
			this.settings.setApproveLSComponentByProfile(Approve_LS_Component_By_Profile) ;
			this.settings.setTPA_Includes_PreActive(TPA_Includes_PreActive) ;
			this.settings.setTPA_Includes_Active(TPA_Includes_Active) ;
			this.settings.setTPA_Includes_Expiring(TPA_Includes_Expiring) ;
			this.settings.setTPA_Includes_Program_Dates(TPA_Includes_Program_Dates) ;
			this.settings.setOperatorTPAInDistributorPrograms(Operator_TPA_In_Distributor_Programs) ;
			this.settings.setLS_Allocation(LS_Allocation);//D30065:LUMP SUM DOLLAR ALLOCATION ON CASE VOLUME BASIS
			this.settings.setSequentialNetSalesOperatingMargin(Sequential_Net_Sales_Operating_Margin);
			this.settings.setAutoWeightDistributorsProgramRevision(Auto_Weight_Distributors_Program_On_Revision);//D41881
			this.settings.setCustomMaxRate(Custom_Max_Rate);//D45263 :: Create table to store max rates by template/profile
			//  <!--- 13397 5.0 only --->
			this.Show_Component_Accrual = 0;
			this.Show_Component_Floor_Pricing = 0;
			//  <!--- End Dev Note: GV; D9662  --->
			this.settings.setBillbackQuickPay(Billback_Quick_Pay); //--- D25219: SOW - Enable mass paying of payables
			this.settings.setSingleSignOnOverrideUserId(SingleSignOnOverrideUserId);
			this.settings.setTradeEligibilityReport(Trade_Eligibility_Report);//D49844 :: Create new app setting called �?Trade Eligibility Report�? with ON/OFF options
			this.settings.setPrgWonLostOnOffInvoiceRecord(Update_Program_Won_Lost_Based_On_OI);//D49855 :: Win/Loss Bid - Create new app setting called “Update Program won/loss based on Off invoice Record�?
			this.settings.setModifyExpiredPrograms(Modify_Expired_Programs);//D50074 :: Viewing and Editing prior program versions
			this.settings.setDisplayOrphanAlertProgramRevise(Display_Orphan_Alert_Program_Revise);//D52449 :: Create new app settings to control Orphan Pop up Alert
			this.settings.setProgramAlertOnRFARate0(Program_Alert_On_RFA_Rate_0);//D50884 :: Improvements to the Rebate Page inside a Program 8.0 Release...
			this.settings.setModifyVendorRecords(Modify_Vendor_Records);	  //D57447 :: Create and modify vendor records
			//  <!------ 4 -----> //  <!--- Dev Note: KAL; 7916 --->
			this.settings.setNewPassword(email_new_password) ;
			this.settings.setTempPassword(email_temp_password) ;
			this.settings.setAdminPassword(email_admin_password) ;
			this.settings.setPasswordChangeDays(password_change_days) ;
			this.settings.setPasswordMinLen(Password_Min_Length) ;
			this.settings.setPasswordHistory(Password_History) ;
			this.settings.setPasswordUpperChar(Password_Upper_Char) ;
			this.settings.setPasswordLowerChar(Password_Lower_Char) ;
			this.settings.setPasswordNumChar(Password_Num_Char) ;
			this.settings.setPasswordSpecialChar(Password_Special_Char) ;
			//  <!--- Dev Note: Clay 9254 New Default Password for Users --->
			this.settings.setDefaultPasswordOn(Default_Password_On) ;
			this.settings.setDefaultPasswordForNewUsers(Default_Password_For_New_Users) ;
			this.settings.setPasswordKey('7y36746z2o6lfh5hgxgol85di7') ;
			this.settings.setLoginAndPasswordChangeMsg(Login_And_Password_Change_Msg) ; //  <!--- Dev Note: Milan 9879 --->
			this.settings.setChangePasswordScreenMsg(Change_Password_Screen_Msg) ; //  <!--- Dev Note: Milan 9879 --->
			this.settings.setSeparateIdPasswordEmail(Separate_Id_Password_Email) ; //  <!--- Dev Note: Milan 9879 --->
			//  <!--- 5 --->
			this.settings.setEmail_Auto_Renewed_Programs(Email_Auto_Renewed_Programs) ;
			this.settings.setSend_Release_Settlement_Emailaddress(Send_Release_Settlement_Emailaddress);
			this.settings.setNotify_RSP_Only_NotAllHQUser(Notify_RSP_Only_NotAllHQUser) ;
			this.settings.setSend_RFA_Agree_Emails_To_CRA_Users(Send_RFA_Agree_Emails_To_CRA_Users) ;
			//  <!--- 6 --->
			this.settings.setMarginColHeader1(marginColHeader1) ;
			this.settings.setMarginColHeader2(marginColHeader2) ;
			this.settings.setMarginColHeader3(marginColHeader3) ;
			this.settings.setMarginColHeader4(marginColHeader4) ;
			this.settings.setMarginColHeader5(marginColHeader5) ;
			this.settings.setMarginColHeader6(marginColHeader6) ;
			this.settings.setMarginColHeader7(marginColHeader7) ;
			this.settings.setMarginColHeader8(marginColHeader8) ;
			this.settings.setMarginColHeader9(marginColHeader9) ;
			this.settings.setMarginColHeader10(marginColHeader10) ;
			this.settings.setMarginColHeader11(marginColHeader11) ;
			this.settings.setMarginColHeader12(marginColHeader12) ;
			this.settings.setMarginColHeader13(marginColHeader13) ;
			this.settings.setMarginColHeader14(marginColHeader14) ;
			//  <!--- 16314 [begin] --->
			this.settings.setMarginColHeader15(marginColHeader15) ;
			//  <!--- 16314 [end] --->
			this.settings.setMarginColHeader16(marginColHeader16) ;
			this.settings.setMarginColHeader17(marginColHeader17) ;
			this.settings.setMarginColHeader18(marginColHeader18) ;
			this.settings.setMarginColHeader19(marginColHeader19) ;
			this.settings.setMarginColHeader20(marginColHeader20) ;
			this.settings.setMarginColHeader21(marginColHeader21) ;
			this.settings.setMarginColHeader22(marginColHeader22) ;
			this.settings.setMarginColHeader23(marginColHeader23) ;
            //65744
			this.settings.setMarginColHeader24(marginColHeader24) ;
			this.settings.setMarginColHeader25(marginColHeader25) ;
            //65744
      this.settings.setMarginColHeader26(marginColHeader26) ;//76537

			this.settings.setMarginCostColHeader1(marginCostColHeader1) ;
			this.settings.setMarginCostColHeader2(marginCostColHeader2) ;
			this.settings.setMarginCostColHeader3(marginCostColHeader3) ;
			this.settings.setMarginCostColHeader4(marginCostColHeader4) ;
			this.settings.setMarginCostColHeader5(marginCostColHeader5) ;
			//D42028	Cost fields in Huhtamaki stage: re-label and remove ones not using
			this.settings.setMarginCostColHeader6(marginCostColHeader6) ;
			this.settings.setMarginCostColHeader7(marginCostColHeader7) ;
			this.settings.setMarginCostColHeader8(marginCostColHeader8) ;
			this.settings.setMarginCostColHeader1_delete(marginCostColHeader1_delete) ;
			this.settings.setMarginCostColHeader2_delete(marginCostColHeader2_delete) ;
			this.settings.setMarginCostColHeader3_delete(marginCostColHeader3_delete) ;
			this.settings.setMarginCostColHeader4_delete(marginCostColHeader4_delete) ;
			this.settings.setMarginCostColHeader5_delete(marginCostColHeader5_delete) ;
			this.settings.setMarginCostColHeader6_delete(marginCostColHeader6_delete) ;
			this.settings.setMarginCostColHeader7_delete(marginCostColHeader7_delete) ;
			this.settings.setMarginCostColHeader8_delete(marginCostColHeader8_delete) ;
			//D42028	Cost fields in Huhtamaki stage: re-label and remove ones not using
			//  <!--- Dev Notes: Anand Rao 19441--->
			this.settings.setBB_Deviations_Override_Price(BB_Deviations_Override_Price) ;
			this.settings.setBB_Upload_III_P_Qty_Amt_Editable(BB_Upload_III_P_Qty_Amt_Editable) ;
			this.settings.setFlex_BB_Deviation(Flex_BB_Deviation) ;
			//  <!--- End 19441--->
			//  <!--- Dev Notes: ANa - 24087 BB fractional vol  --->
			this.settings.setBB_Fractional_Volume(BB_Fractional_Volume) ;
			//  <!--- Dev Notes: 21185/Anand Rao/10-Nov-09 Setting for displaying Vendor ID Null form --->
			this.settings.setDisplay_Vendor_ID_Null_Form(Display_Vendor_ID_Null_Form) ;
			//  <!--- End 21185 --->
			//  <!--- Dev Notes: 21923/Anand Rao/22-Jan-2010 Settings for BB Deviation Grid --->
			this.settings.setUpdate_BB_Approve_Amt(Update_BB_Approve_Amt) ;
			this.settings.setBB_Approve_Expected_Rate_Less_Tolerance(BB_Approve_Expected_Rate_Less_Tolerance) ;
			//  <!--- End 21185 --->
			//  <!--- Dev Notes: 19384/Anand Rao/05-Apr-10 Rebill Interface and changes --->
			this.settings.setIntegrated_Rebill(Integrated_Rebill) ;
			//  <!--- End D19384 --->
			//  <!--- Dev Notes: 21554/Anand Rao/30-Apr-10 HZ - Single sign on to application using LDAP --->
			this.settings.setLDAP_SSO_Enabled(LDAP_SSO_Enabled) ;
			//  <!--- End D21554 --->
			//  <!--- Dev Notes: D23692/Anand Rao/28-Jun-10 --->
			this.settings.setDocumentPurgeAge(Document_Purge_Age);
			this.settings.setFTPDocumentPath(FTP_Document_Path);
			//  <!---  End D23692 --->
			//  <!--- 15: Approval via Email --->
			this.settings.setPinMinLength(pinMinLength) ;
			this.settings.setEmailOutJobTime(emailOutJobTime) ;
			this.settings.setEmailOutJobSuccess(emailOutJobSuccess) ;
			this.settings.setEmailInJobInterval(emailInJobInterval) ;
			this.settings.setEmailInJobSuccess(emailInJobSuccess) ;
			this.settings.setEmailApprovalInstructions(emailApprovalInstructions) ;
			this.settings.setBillBack_Statement_Type( qGetSettings.Billback_statement_Type );   // 27047
			this.settings.setExternal_contacts( qGetSettings.External_Contacts_Option );  // 28345
			// <!--- D29997: Update Items proposal status based on approved billback/Anand Rao/15-Feb-2012  --->
			this.settings.setPrgWonLostOnBBApproval(qGetSettings.Update_Program_Won_Lost_Based_On_Billback_Approval);
			this.settings.setBillbackModuleType(qGetSettings.Billback_Module_Type);
			// <!--- D33041: Add 'base sales price' to the billback rate pop up window (CF)/Anand Rao/25-Jul-2012 --->
			this.settings.setBillback_Display_Base_Sales_in_Rate_Dev(qGetSettings.Billback_Display_Base_Sales_in_Rate_Dev);
			this.settings.setBB_Count_Indicator(qGetSettings.BB_Count_Indicator);  // 34665
			this.settings.setShowBrandOnViewProgram(qGetSettings.Show_Brand_On_View_Program);
			</cfscript>
			<cfif arguments.settingsType NEQ 0>
				<cfset this.settings.setUpdatedBy(Updated_By) />
				<cfset this.settings.setUpdatedByUserName(UpdatedByFullName) />
				<cfset this.settings.setUpdatedOn(Updated_On) />
			</cfif>
		</cfloop>
	</cfif>
	<cfreturn this.settings />
</cffunction>

<cffunction name="getBBAliasSourceType" output="false" returntype="query">
	<cfquery name="qBBAliasSourceType" datasource="#application.datasource#">
		SELECT bbc.BB_Claim_Source_Xref_ID,
		bbc.Source_Code + ' ' + bbu.Source_Category As Source_Code_Display, bbc.active
		FROM BB_Upload_Source_Type_Lookup bbu
		INNER JOIN BB_claim_Source_Xref bbc
		ON bbu.Source_Type = bbc.Source_Type
		WHERE bbu.deleted = 0
		AND bbu.Use_Search_Tool <> 1
		AND bbc.deleted = 0
		AND Source_Type_Desc =
		<!--- We do not want to show custom sources like 'PG0280' for P&G.
		In fact these sources should not even appear for P&G in the app setting as
		there are too may of these.
		--->
		CASE WHEN bbu.Source_Category = '3rd Party'
		THEN '3rd party single source'
		ELSE
		bbu.Source_Type_Desc
		END
		order by Source_Code_Display
	</cfquery>
	<cfreturn qBBAliasSourceType />
</cffunction>

<cffunction name="saveBBAliasSourceType" output="false">
	<cfargument name="BBAliasSourceTypeList" type="string" required="true" default="0">
	<cfargument name="settingsBBAliasSourceType" type="string" required="true" default="0">
	<cfif arguments.settingsBBAliasSourceType eq 0>
		<!--- /* Make all the options Inactive */ --->
		<cfquery name="updateBBAliasSourceType" datasource="#application.datasource#">
			update BB_claim_Source_Xref
			set active = 0
			where BB_claim_Source_Xref_ID in (<cfqueryparam value="#arguments.BBAliasSourceTypeList#" cfsqltype="CF_SQL_VARCHAR" list="true">)

			update bbu
			set bbu.Active = 0
			from
			BB_Upload_Source_Type_Lookup bbu
			inner join
			BB_claim_Source_Xref bbc
			on bbu.Source_Type = bbc.Source_Type
			where bbc.BB_claim_Source_Xref_ID in(<cfqueryparam value="#arguments.BBAliasSourceTypeList#" cfsqltype="CF_SQL_VARCHAR" list="true">)
		</cfquery>
	<cfelse>
		<!--- /* Make all the options Inactive */ --->
		<cfquery name="updateBBAliasSourceType" datasource="#application.datasource#">
			update BB_claim_Source_Xref
			set active = 0
			where BB_claim_Source_Xref_ID in (<cfqueryparam value="#arguments.BBAliasSourceTypeList#" cfsqltype="CF_SQL_VARCHAR" list="true">)

			update bbu
			set bbu.Active = 0
			from
			BB_Upload_Source_Type_Lookup bbu
			inner join
			BB_claim_Source_Xref bbc
			on bbu.Source_Type = bbc.Source_Type
			where bbc.BB_claim_Source_Xref_ID in(<cfqueryparam value="#arguments.BBAliasSourceTypeList#" cfsqltype="CF_SQL_VARCHAR" list="true">)
		</cfquery>
		<!--- /* Turn those options active which are checked using checkbox. */ --->
		<cfquery name="qBBAliasSourceType" datasource="#application.datasource#">
			update BB_claim_Source_Xref
			set active = 1
			where BB_claim_Source_Xref_ID in (<cfqueryparam value="#arguments.settingsBBAliasSourceType#" cfsqltype="CF_SQL_VARCHAR" list="true">)

			update bbu
			set bbu.Active = 1
			from
			BB_Upload_Source_Type_Lookup bbu
			inner join
			BB_claim_Source_Xref bbc
			on bbu.Source_Type = bbc.Source_Type
			where bbc.BB_claim_Source_Xref_ID in (<cfqueryparam value="#arguments.settingsBBAliasSourceType#" cfsqltype="CF_SQL_VARCHAR" list="true">)
		</cfquery>
	</cfif>
</cffunction>

<cffunction name="save" output="false">
	<cfargument name="settingsType" type="numeric" required="true" default="0">
	<cfif arguments.settingsType EQ 1>
		<cftransaction action="BEGIN">
		<cftry>
			<!------ insert new ----->
			<cfquery name="qUpdateSettings" datasource="#application.datasource#">
				UPDATE  _Application_Settings
				SET   Program_Interface_Buffer = <cfqueryparam value="#this.settings.getProgramInterfaceBuffer()#" cfsqltype="CF_SQL_INTEGER">,
				awaiting_action_days = <cfqueryparam value="#this.settings.getawaitingactiondays()#" cfsqltype="CF_SQL_INTEGER">,
				App_Settings_Updated_By = <cfqueryparam value="#this.settings.getUpdatedBy()#" cfsqltype="CF_SQL_VARCHAR">,
				Traffic_Info_Days = <cfqueryparam value="#this.settings.getTrafficInfoDays()#" cfsqltype="CF_SQL_INTEGER">,
				Printer2_Name = <cfqueryparam value="#this.settings.getPrinter2Name()#" cfsqltype="CF_SQL_VARCHAR">,
				Program_Number_Prefix = <cfqueryparam value="#this.settings.getProgramNumberPrefix()#" cfsqltype="CF_SQL_VARCHAR">,
				Billback_Number_Prefix = <cfqueryparam value="#this.settings.getBillbackNumberPrefix()#" cfsqltype="CF_SQL_VARCHAR">,
				Deduction_Number_Prefix = <cfqueryparam value="#this.settings.getDeductionNumberPrefix()#" cfsqltype="CF_SQL_VARCHAR">,
				DD_Credit_Number_Prefix = <cfqueryparam value="#this.settings.getDDCreditNumberPrefix()#" cfsqltype="CF_SQL_VARCHAR">,
				Planner_Number_Prefix = <cfqueryparam value="#this.settings.getPlannerNumberPrefix()#" cfsqltype="CF_SQL_VARCHAR">,
				Auto_Claim_Buffer = <cfqueryparam value="#this.settings.getAutoClaimBuffer()#" cfsqltype="CF_SQL_INTEGER">,
				<!---
				Purposely used .Documentpath instead of .getDocumentpath()
				We usually leave _application_settings.document_path as blank
				If it is blank, getDocumentpath() will return the application location
				So if we use .Documentpath it will stay blank
				--->
				Document_Path = <cfqueryparam value="#this.settings.DocumentPath#" cfsqltype="CF_SQL_VARCHAR">,
				Document_Mapping = <cfqueryparam value="#this.settings.getDocumentMapping()#" cfsqltype="CF_SQL_VARCHAR">,
				App_Settings_Updated_On = GetDate()
			</cfquery>
			<cfset Track_Changes()>
			<cfcatch>
				<cftransaction action="ROLLBACK">
				<cfrethrow>
			</cfcatch>
		</cftry>
		</cftransaction>
	<cfelseif arguments.settingsType EQ 2>
		<cfset  variables.Setting2 = CreateObject("component","components.settings.AplicationSettingsSaveType2").init() />
		<cfset  Setting2.saveSettingType2(this.settings) />
		<cfset  Setting2.saveSettingType3(this.settings) />
	<cfelseif arguments.settingsType EQ 3>
		<cftransaction action="BEGIN">
		<cftry>
			<!------ insert new ----->
			<cfquery name="qUpdateSettings" datasource="#application.datasource#">
				UPDATE  _Application_Settings
				SET   Approval_Pound_Margin_On    = <cfqueryparam value="#this.settings.getApprovalPoundMarginOn()#" cfsqltype="CF_SQL_bit">,
				Approval_Percent_Margin_On    = <cfqueryparam value="#this.settings.getApprovalPercentMarginOn()#" cfsqltype="CF_SQL_bit">,
				Approval_Total_Pgm_Margin_On  = <cfqueryparam value="#this.settings.getApprovalTotalPgmMarginOn()#" cfsqltype="CF_SQL_bit">,
				Approval_Spending_Cap_On    = <cfqueryparam value="#this.settings.getApprovalSpendingCapOn()#" cfsqltype="CF_SQL_bit">,
				Approval_Layered_On       = <cfqueryparam value="#this.settings.getApprovalLayeredOn()#" cfsqltype="CF_SQL_bit">,
				Approval_Margin_Type      =  <cfqueryparam value="#this.settings.getApprovalMarginType()#" cfsqltype="CF_SQL_Integer">,
				Display_Trade_Percent_on_Margin = <cfqueryparam value="#this.settings.getDisplay_Trade_Percent_on_Margin()#" cfsqltype="CF_SQL_bit">,
				Margin_Operating_Income_Percent_Type = <cfqueryparam value="#this.settings.getMarginOperatingIncomePercentType()#" cfsqltype="CF_SQL_TINYINT">,
				Approval_Disposable_On   = <cfqueryparam value="#this.settings.getApprovalDisposableOn()#" cfsqltype="CF_SQL_bit">,
				Approval_Standard_On = <cfqueryparam value="#this.settings.getapprovalStandardOn()#" cfsqltype="CF_SQL_bit">,
				Approval_Layered_Costs = <cfqueryparam value="#this.settings.getapprovalLayeredCosts()#" cfsqltype="CF_SQL_Integer">,
				use_cost_multiplier = <cfqueryparam value="#this.settings.getusecostmultiplier()#" cfsqltype="CF_SQL_bit">,
				Use_DC_SO_Base_sales = <cfqueryparam value="#this.settings.getUseDCSOBasesales()#" cfsqltype="CF_SQL_Integer">,
				Margin_Display_LB = <cfqueryparam value="#this.settings.getMarginDisplayLB()#" cfsqltype="CF_SQL_bit">,
				Margin_Display_CS = <cfqueryparam value="#this.settings.getMarginDisplayCS()#" cfsqltype="CF_SQL_bit">,
				Margin_Display_EQ = <cfqueryparam value="#this.settings.getMarginDisplayEQ()#" cfsqltype="CF_SQL_bit">,
				Margin_Display_default = <cfqueryparam value="#this.settings.getMarginDisplaydefault()#" cfsqltype="CF_SQL_Integer">,
				TPA_Includes_PreActive = <cfqueryparam value="#this.settings.getTPA_Includes_PreActive()#" cfsqltype="cf_sql_bit">,
				TPA_Includes_Active = <cfqueryparam value="#this.settings.getTPA_Includes_Active()#" cfsqltype="cf_sql_bit">,
				TPA_Includes_Expiring = <cfqueryparam value="#this.settings.getTPA_Includes_Expiring()#" cfsqltype="cf_sql_bit">,
				TPA_Includes_Program_Dates = <cfqueryparam value="#this.settings.getTPA_Includes_Program_Dates()#" cfsqltype="cf_sql_bit">,
				Operator_TPA_In_Distributor_Programs = <cfqueryparam value="#this.settings.getOperatorTPAInDistributorPrograms()#" cfsqltype="CF_SQL_BIT">,
				Approve_LS_Component_By_Profile = <cfqueryparam value="#this.settings.getApproveLSComponentByProfile()#" cfsqltype="CF_SQL_bit">,
				LS_Allocation = <cfqueryparam value="#this.settings.getLS_Allocation()#" cfsqltype="CF_SQL_Integer">,<!--- D30065:LUMP SUM DOLLAR ALLOCATION ON CASE VOLUME BASIS --->
				Sequential_Net_Sales_Operating_Margin = <cfqueryparam value="#this.settings.getSequentialNetSalesOperatingMargin()#" cfsqltype="CF_SQL_bit">,
				Approval_Settings_Updated_By = <cfqueryparam value="#this.settings.getUpdatedBy()#" cfsqltype="CF_SQL_VARCHAR">,
				Approval_Settings_Updated_On = GetDate()
			</cfquery>
			<cfset Track_Changes()>
			<cfquery name="getCols" datasource="#application.datasource#">
				SELECT Input_Name, Value FROM _Settings
			</cfquery>

			<!--- scan thru all new setting input names and save their values into the database --->
			<!--- place setting value in the form into the database --->
			<cfquery datasource="#application.datasource#" result="_r">
				<cfif ( isDefined( "request.accessStructure.name_first" ) and isDefined( "request.accessStructure.name_last" ) )>
					EXEC sp_set_session_context 'Updated_By', '#request.accessStructure.name_first# #request.accessStructure.name_last#'
				</cfif>
				<cfloop query="getCols">
					<cfset local.input_name = trim(getCols.input_name)>

					<!--- take care only non-blank setting input name --->
					<cfif len(local.input_name)>
						<!--- handle input not submitted with the form (e.g. unchecked checkbox) --->
						<cfset local.value = trim(structKeyExists(form, local.input_name) ? form[ local.input_name ] : getCols.Value )>

							UPDATE _Settings
							SET Value = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.value#">
							WHERE Input_Name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.input_name#">
					</cfif>
				</cfloop>
				EXEC sp_set_session_context 'Updated_By', NULL
			</cfquery>
			<cfset Track_Changes()>
			<cfcatch>
				<cftransaction action="ROLLBACK">
				<cfrethrow>
			</cfcatch>
		</cftry>
		</cftransaction>
	<cfelseif arguments.settingsType EQ 4>
		<cftransaction action="BEGIN">
		<cftry>
			<!------ insert new ----->
			<cfquery name="qUpdateSettings" datasource="#application.datasource#">
				UPDATE  _Application_Settings
				SET
				Email_New_Password = <cfqueryparam value="#this.settings.getNewPassword()#" cfsqltype="CF_SQL_BIT">,
				Email_Temp_Password = <cfqueryparam value="#this.settings.getTempPassword()#" cfsqltype="CF_SQL_BIT">,
				Email_Admin_Password = <cfqueryparam value="#this.settings.getAdminPassword()#" cfsqltype="CF_SQL_BIT">,
				Password_Change_Days = <cfqueryparam value="#this.settings.getPasswordChangeDays()#" cfsqltype="CF_SQL_INTEGER">,
				Password_Min_Length = <cfqueryparam value="#this.settings.getPasswordMinLen()#" cfsqltype="CF_SQL_NUMERIC">,
				Password_History = <cfqueryparam value="#this.settings.getPasswordHistory()#" cfsqltype="CF_SQL_INTEGER">,
				Password_Upper_Char = <cfqueryparam value="#this.settings.getPasswordUpperChar()#" cfsqltype="CF_SQL_BIT">,
				Password_Lower_Char = <cfqueryparam value="#this.settings.getPasswordLowerChar()#" cfsqltype="CF_SQL_BIT">,
				Password_Num_Char = <cfqueryparam value="#this.settings.getPasswordNumChar()#" cfsqltype="CF_SQL_BIT">,
				Password_Special_Char = <cfqueryparam value="#this.settings.getPasswordSpecialChar()#" cfsqltype="CF_SQL_BIT">,
				Password_Settings_Updated_By = <cfqueryparam value="#this.settings.getUpdatedBy()#" cfsqltype="CF_SQL_VARCHAR">,
				<!--- Dev Note: Clay 9254 New Default Password for Users --->
				Default_Password_On = <cfqueryparam value="#this.settings.getDefaultPasswordOn()#" cfsqltype="CF_SQL_VARCHAR">,
				Default_Password_For_New_Users = <cfqueryparam value="#this.settings.getDefaultPasswordForNewUsers()#" cfsqltype="CF_SQL_VARCHAR">,
				Password_Settings_Updated_On = GetDate(),
				Login_And_Password_Change_Msg = <cfqueryparam value="#this.settings.getLoginAndPasswordChangeMsg()#" cfsqltype="CF_SQL_VARCHAR">,
				Change_Password_Screen_Msg = <cfqueryparam value="#this.settings.getChangePasswordScreenMsg()#" cfsqltype="CF_SQL_VARCHAR">,
				Separate_Id_Password_Email = <cfqueryparam value="#this.settings.getSeparateIdPasswordEmail()#" cfsqltype="CF_SQL_BIT">
			</cfquery>
			<cfset Track_Changes()>
			<cfcatch>
				<cftransaction action="ROLLBACK">
				<cfrethrow>
			</cfcatch>
		</cftry>
		</cftransaction>
		<!--- Dev Note: BSD; 11439 --->
	<cfelseif arguments.settingsType EQ 6>
		<cftransaction action="BEGIN">
		<cftry>
			<!------ insert new ----->
			<cfquery name="qUpdateSettings" datasource="#application.datasource#">
				UPDATE  _Application_Settings
				SET
				MarginColHeader1 = <cfqueryparam value="#this.settings.getMarginColHeader1()#" cfsqltype="CF_SQL_VARCHAR">,
				MarginColHeader2 = <cfqueryparam value="#this.settings.getMarginColHeader2()#" cfsqltype="CF_SQL_VARCHAR">,
				MarginColHeader3 = <cfqueryparam value="#this.settings.getMarginColHeader3()#" cfsqltype="CF_SQL_VARCHAR">,
				MarginColHeader4 = <cfqueryparam value="#this.settings.getMarginColHeader4()#" cfsqltype="CF_SQL_VARCHAR">,
				MarginColHeader5 = <cfqueryparam value="#this.settings.getMarginColHeader5()#" cfsqltype="CF_SQL_VARCHAR">,
				MarginColHeader6 = <cfqueryparam value="#this.settings.getMarginColHeader6()#" cfsqltype="CF_SQL_VARCHAR">,
				MarginColHeader7 = <cfqueryparam value="#this.settings.getMarginColHeader7()#" cfsqltype="CF_SQL_VARCHAR">,
				MarginColHeader8 = <cfqueryparam value="#this.settings.getMarginColHeader8()#" cfsqltype="CF_SQL_VARCHAR">,
				MarginColHeader9 = <cfqueryparam value="#this.settings.getMarginColHeader9()#" cfsqltype="CF_SQL_VARCHAR">,
				MarginColHeader10 = <cfqueryparam value="#this.settings.getMarginColHeader10()#" cfsqltype="CF_SQL_VARCHAR">,
				MarginColHeader11 = <cfqueryparam value="#this.settings.getMarginColHeader11()#" cfsqltype="CF_SQL_VARCHAR">,
				MarginColHeader12 = <cfqueryparam value="#this.settings.getMarginColHeader12()#" cfsqltype="CF_SQL_VARCHAR">,
				MarginColHeader13 = <cfqueryparam value="#this.settings.getMarginColHeader13()#" cfsqltype="CF_SQL_VARCHAR">,
				MarginColHeader14 = <cfqueryparam value="#this.settings.getMarginColHeader14()#" cfsqltype="CF_SQL_VARCHAR">,
				MarginColHeader15 = <cfqueryparam value="#this.settings.getMarginColHeader15()#" cfsqltype="CF_SQL_VARCHAR">, <!--- 16314 --->
				MarginColHeader16 = <cfqueryparam value="#this.settings.getMarginColHeader16()#" cfsqltype="CF_SQL_VARCHAR">, <!--- 20537 --->
				MarginColHeader17 = <cfqueryparam value="#this.settings.getMarginColHeader17()#" cfsqltype="CF_SQL_VARCHAR">, <!--- 20537 --->
				MarginColHeader18 = <cfqueryparam value="#this.settings.getMarginColHeader18()#" cfsqltype="CF_SQL_VARCHAR">, <!--- 24130 --->
				MarginColHeader19 = <cfqueryparam value="#this.settings.getMarginColHeader19()#" cfsqltype="CF_SQL_VARCHAR">, <!--- 24130 --->
				MarginColHeader20 = <cfqueryparam value="#this.settings.getMarginColHeader20()#" cfsqltype="CF_SQL_VARCHAR">, <!---  --->
				MarginColHeader21 = <cfqueryparam value="#this.settings.getMarginColHeader21()#" cfsqltype="CF_SQL_VARCHAR">, <!---  --->
				marginColHeader22 = <cfqueryparam value="#this.settings.getMarginColHeader22()#" cfsqltype="CF_SQL_VARCHAR">, <!--- 39801 --->
				marginColHeader23 = <cfqueryparam value="#this.settings.getMarginColHeader23()#" cfsqltype="CF_SQL_VARCHAR">, <!--- 42990 --->
	           <!---65744 - CC - Move LaborOH cost to a different product cost field START --->
                MarginColHeader24 = <cfqueryparam value="#this.settings.getMarginColHeader24()#" cfsqltype="CF_SQL_VARCHAR">,
				MarginColHeader25 = <cfqueryparam value="#this.settings.getMarginColHeader25()#" cfsqltype="CF_SQL_VARCHAR">,
				MarginColHeader26 = <cfqueryparam value="#this.settings.getMarginColHeader26()#" cfsqltype="CF_SQL_VARCHAR">,<!---76537--->
                <!---65744 - CC - Move LaborOH cost to a different product cost field END --->
                MarginCostColHeader1 = <cfqueryparam value="#this.settings.getMarginCostColHeader1()#" cfsqltype="CF_SQL_VARCHAR">,
				MarginCostColHeader2 = <cfqueryparam value="#this.settings.getMarginCostColHeader2()#" cfsqltype="CF_SQL_VARCHAR">,
				MarginCostColHeader3 = <cfqueryparam value="#this.settings.getMarginCostColHeader3()#" cfsqltype="CF_SQL_VARCHAR">,
				MarginCostColHeader4 = <cfqueryparam value="#this.settings.getMarginCostColHeader4()#" cfsqltype="CF_SQL_VARCHAR">,
				MarginCostColHeader5 = <cfqueryparam value="#this.settings.getMarginCostColHeader5()#" cfsqltype="CF_SQL_VARCHAR">,
				<!--- D42028	Cost fields in Huhtamaki stage: re-label and remove ones not using --->
				MarginCostColHeader6 = <cfqueryparam value="#this.settings.getMarginCostColHeader6()#" cfsqltype="CF_SQL_VARCHAR">,
				MarginCostColHeader7 = <cfqueryparam value="#this.settings.getMarginCostColHeader7()#" cfsqltype="CF_SQL_VARCHAR">,
				MarginCostColHeader8 = <cfqueryparam value="#this.settings.getMarginCostColHeader8()#" cfsqltype="CF_SQL_VARCHAR">,
				MarginCostColHeader1_delete = <cfqueryparam value="#this.settings.getMarginCostColHeader1_delete()#" cfsqltype="CF_SQL_VARCHAR">,
				MarginCostColHeader2_delete = <cfqueryparam value="#this.settings.getMarginCostColHeader2_delete()#" cfsqltype="CF_SQL_VARCHAR">,
				MarginCostColHeader3_delete = <cfqueryparam value="#this.settings.getMarginCostColHeader3_delete()#" cfsqltype="CF_SQL_VARCHAR">,
				MarginCostColHeader4_delete = <cfqueryparam value="#this.settings.getMarginCostColHeader4_delete()#" cfsqltype="CF_SQL_VARCHAR">,
				MarginCostColHeader5_delete = <cfqueryparam value="#this.settings.getMarginCostColHeader5_delete()#" cfsqltype="CF_SQL_VARCHAR">,
				MarginCostColHeader6_delete = <cfqueryparam value="#this.settings.getMarginCostColHeader6_delete()#" cfsqltype="CF_SQL_VARCHAR">,
				MarginCostColHeader7_delete = <cfqueryparam value="#this.settings.getMarginCostColHeader7_delete()#" cfsqltype="CF_SQL_VARCHAR">,
				MarginCostColHeader8_delete = <cfqueryparam value="#this.settings.getMarginCostColHeader8_delete()#" cfsqltype="CF_SQL_VARCHAR">,
				<!--- D42028	Cost fields in Huhtamaki stage: re-label and remove ones not using --->

                Margin_Settings_Updated_By = <cfqueryparam value="#this.settings.getUpdatedBy()#" cfsqltype="CF_SQL_VARCHAR">,
				Margin_Settings_Updated_On = GetDate()
			</cfquery>
			<cfset Track_Changes()>
			<cfcatch>
				<cftransaction action="ROLLBACK">
				<cfrethrow>
			</cfcatch>
		</cftry>
		</cftransaction>
		<!--- Dev Note: DAA - D14309 --->
	<cfelseif arguments.settingsType EQ 7>
		<cftransaction action="BEGIN">
		<cftry>
			<!------ insert new ----->
			<cfquery name="qUpdateSettings" datasource="#application.datasource#">
				UPDATE  _Application_Settings
				SET
				Product_Labels_Updated_By = <cfqueryparam value="#this.settings.getUpdatedBy()#" cfsqltype="CF_SQL_VARCHAR">,
				Product_Labels_Updated_On = GetDate()
			</cfquery>
			<cfset Track_Changes()>
			<cfcatch>
				<cftransaction action="ROLLBACK">
				<cfrethrow>
			</cfcatch>
		</cftry>
		</cftransaction>
	<cfelseif arguments.settingsType EQ 8>
		<cftransaction action="BEGIN">
		<cftry>
			<!------ insert new ----->
			<cfquery name="qUpdateSettings" datasource="#application.datasource#">
				UPDATE  _Application_Settings
				SET
				Distributor_Labels_Updated_By = <cfqueryparam value="#this.settings.getUpdatedBy()#" cfsqltype="CF_SQL_VARCHAR">,
				Distributor_Labels_Updated_On = GetDate()
			</cfquery>
			<cfset Track_Changes()>
			<cfcatch>
				<cftransaction action="ROLLBACK">
				<cfrethrow>
			</cfcatch>
		</cftry>
		</cftransaction>
	<cfelseif arguments.settingsType EQ 9>
		<cftransaction action="BEGIN">
		<cftry>
			<!------ insert new ----->
			<cfquery name="qUpdateSettings" datasource="#application.datasource#">
				UPDATE	_Application_Settings
				SET
				Billback_Labels_Updated_By = <cfqueryparam value="#this.settings.getUpdatedBy()#" cfsqltype="CF_SQL_VARCHAR">,
				Billback_Labels_Updated_On = GetDate()
			</cfquery>
			<cfset Track_Changes()>
			<cfcatch>
				<cftransaction action="ROLLBACK">
				<cfrethrow>
			</cfcatch>
		</cftry>
		</cftransaction>
	<cfelseif arguments.settingsType EQ 10>
		<cftransaction action="BEGIN">
		<cftry>
			<!------ insert new ----->
			<cfquery name="qUpdateSettings" datasource="#application.datasource#">
				UPDATE  _Application_Settings
				SET
				Pullback_Labels_Updated_By = <cfqueryparam value="#this.settings.getUpdatedBy()#" cfsqltype="CF_SQL_VARCHAR">,
				Pullback_Labels_Updated_On = GetDate()
			</cfquery>
			<cfset Track_Changes()>
			<cfcatch>
				<cftransaction action="ROLLBACK">
				<cfrethrow>
			</cfcatch>
		</cftry>
		</cftransaction>
	<cfelseif arguments.settingsType EQ 11>
		<cftransaction action="BEGIN">
		<cftry>
			<!------ insert new ----->
			<cfquery name="qUpdateSettings" datasource="#application.datasource#">
				UPDATE  _Application_Settings
				SET
				Table_Column_Labels_Updated_By = <cfqueryparam value="#this.settings.getUpdatedBy()#" cfsqltype="CF_SQL_VARCHAR">,
				Table_Column_Labels_Updated_On = GetDate()
			</cfquery>
			<cfset Track_Changes()>
			<cfcatch>
				<cftransaction action="ROLLBACK">
				<cfrethrow>
			</cfcatch>
		</cftry>
		</cftransaction>
	<cfelseif arguments.settingsType EQ 12>
		<cftransaction action="BEGIN">
		<cftry>
			<!------ insert new ----->
			<cfquery name="qUpdateSettings" datasource="#application.datasource#">
				UPDATE  _Application_Settings
				SET
				Pricing_level_Labels_Updated_By = <cfqueryparam value="#this.settings.getUpdatedBy()#" cfsqltype="CF_SQL_VARCHAR">,
				Pricing_level_Labels_Updated_On = GetDate()
			</cfquery>
			<cfset Track_Changes()>
			<cfcatch>
				<cftransaction action="ROLLBACK">
				<cfrethrow>
			</cfcatch>
		</cftry>
		</cftransaction>
	<cfelseif arguments.settingsType EQ 13>
		<cftransaction action="BEGIN">
		<cftry>
			<!------ insert new ----->
			<cfquery name="qUpdateSettings" datasource="#application.datasource#">
				UPDATE  _Application_Settings
				SET
				Program_Summary_Labels_Updated_By = <cfqueryparam value="#this.settings.getUpdatedBy()#" cfsqltype="CF_SQL_VARCHAR">,
				Program_Summary_Labels_Updated_On = GetDate()
			</cfquery>
			<cfset Track_Changes()>
			<cfcatch>
				<cftransaction action="ROLLBACK">
				<cfrethrow>
			</cfcatch>
		</cftry>
		</cftransaction>
	<cfelseif arguments.settingsType EQ 14>
		<cftransaction action="BEGIN">
		<cftry>
			<!------ insert new ----->
			<cfquery name="qUpdateSettings" datasource="#application.datasource#">
				UPDATE  _Application_Settings
				SET
				Settings_Panel_Access_Updated_By = <cfqueryparam value="#this.settings.getUpdatedBy()#" cfsqltype="CF_SQL_VARCHAR">,
				Settings_Panel_Access_Updated_On = GetDate()
			</cfquery>
			<cfset Track_Changes()>
			<cfcatch>
				<cftransaction action="ROLLBACK">
				<cfrethrow>
			</cfcatch>
		</cftry>
		</cftransaction>
	<cfelseif arguments.settingsType EQ 15>
		<cftransaction action="BEGIN">
		<cftry>
			<!------ insert new ----->
			<cfquery name="qUpdateSettings" datasource="#application.datasource#">
				UPDATE  _Application_Settings
				SET
				PinMinLength = <cfqueryparam value="#this.settings.getPinMinLength()#" cfsqltype="cf_sql_integer">,
				EmailOutJobTime = <cfqueryparam value="#this.settings.getEmailOutJobTime()#" cfsqltype="cf_sql_varchar">,
				EmailOutJobSuccess = <cfqueryparam value="#this.settings.getEmailOutJobSuccess()#" cfsqltype="cf_sql_varchar">,
				EmailInJobInterval = <cfqueryparam value="#this.settings.getEmailInJobInterval()#" cfsqltype="cf_sql_integer">,
				EmailInJobSuccess = <cfqueryparam value="#this.settings.getEmailInJobSuccess()#" cfsqltype="cf_sql_varchar">,
				EmailApprovalInstructions = <cfqueryparam value="#this.settings.getEmailApprovalInstructions()#" cfsqltype="cf_sql_varchar">,
				Approval_Via_Email_Updated_By = <cfqueryparam value="#this.settings.getUpdatedBy()#" cfsqltype="cf_sql_varchar">,
				Approval_Via_Email_Updated_On = GetDate()
			</cfquery>
			<cfset Track_Changes()>

			<cfquery name="getCols" datasource="#application.datasource#">
				SELECT Input_Name, Value FROM _Settings
			</cfquery>

			<!--- scan thru all new setting input names and save their values into the database --->
			<!--- place setting value in the form into the database --->
			<cfquery datasource="#application.datasource#" result="_r">
				<cfif ( isDefined( "request.accessStructure.name_first" ) and isDefined( "request.accessStructure.name_last" ) )>
					EXEC sp_set_session_context 'Updated_By', '#request.accessStructure.name_first# #request.accessStructure.name_last#'
				</cfif>
				<cfloop query="getCols">
					<cfset local.input_name = trim(getCols.input_name)>

					<!--- take care only non-blank setting input name --->
					<cfif len(local.input_name)>
						<!--- handle input not submitted with the form (e.g. unchecked checkbox) --->
						<cfset local.value = trim(structKeyExists(form, local.input_name) ? form[ local.input_name ] : getCols.Value )>
						UPDATE _Settings
						SET Value = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.value#">
						WHERE Input_Name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.input_name#">
					</cfif>
				</cfloop>
				EXEC sp_set_session_context 'Updated_By', NULL
			</cfquery>

			<cfcatch>
				<cftransaction action="ROLLBACK">
				<cfrethrow>
			</cfcatch>
		</cftry>
		</cftransaction>
	<cfelseif arguments.settingsType EQ 16>
		<cftransaction action="BEGIN">
		<cftry>
			<!------ insert new ----->
			<cfquery name="qUpdateSettings" datasource="#application.datasource#">
				UPDATE  _Application_Settings
				SET
				General_Labels_Updated_By = <cfqueryparam value="#this.settings.getUpdatedBy()#" cfsqltype="CF_SQL_VARCHAR">,
				General_Labels_Updated_On = GetDate()
			</cfquery>
			<cfset Track_Changes()>
			<cfcatch>
				<cftransaction action="ROLLBACK">
				<cfrethrow>
			</cfcatch>
		</cftry>
		</cftransaction>
	<cfelseif arguments.settingsType EQ 17>
		<cftransaction action="BEGIN">
		<cftry>
			<!------ insert new ----->
			<cfquery name="qUpdateSettings" datasource="#application.datasource#">
				UPDATE  _Application_Settings
				SET
				Deduction_Labels_Updated_By = <cfqueryparam value="#this.settings.getUpdatedBy()#" cfsqltype="CF_SQL_VARCHAR">,
				Deduction_Labels_Updated_On = GetDate()
			</cfquery>
			<cfset Track_Changes()>
			<cfcatch>
				<cftransaction action="ROLLBACK">
				<cfrethrow>
			</cfcatch>
		</cftry>
		</cftransaction>
		<!--- BillBack Labels --->
		<!--- Dev Note: Drachala; D27872: Add new Billback Lables START--->
	<cfelseif arguments.settingsType EQ 18>
		<cftransaction action="BEGIN">
		<cftry>
			<!------ insert new ----->
			<cfquery name="qUpdateSettings" datasource="#application.datasource#">
				UPDATE  _Application_Settings
				SET
				Billback_Labels_Updated_By  = <cfqueryparam value="#this.settings.getUpdatedBy()#" cfsqltype="CF_SQL_VARCHAR">,
				Billback_Labels_Updated_On  = GetDate()
			</cfquery>
			<cfset Track_Changes()>
			<cfcatch>
				<cftransaction action="ROLLBACK">
				<cfrethrow>
			</cfcatch>
		</cftry>
		</cftransaction>
		<!--- Dev Note: Drachala; D27872: Add new Billback Lables END--->
		<!--- 29856	labels for Fixed Price, Rebate, Lump Sum, Growth --->
	<cfelseif arguments.settingsType EQ 19>
		<cftransaction action="BEGIN">
		<cftry>
			<!------ insert new ----->
			<cfquery name="qUpdateSettings" datasource="#application.datasource#">
				UPDATE  _Application_Settings
				SET
				Discount_Type_Labels_Updated_By  = <cfqueryparam value="#this.settings.getUpdatedBy()#" cfsqltype="CF_SQL_VARCHAR">,
				Discount_Type_Labels_Updated_On  = GetDate()
			</cfquery>
			<cfset Track_Changes()>
			<cfcatch>
				<cftransaction action="ROLLBACK">
				<cfrethrow>
			</cfcatch>
		</cftry>
		</cftransaction>
		<!--- 29856	labels for Fixed Price, Rebate, Lump Sum, Growth --->
	<cfelseif arguments.settingsType EQ 20>
		<cftransaction action="BEGIN">
		<cftry>
			<!------ insert new ----->
			<cfquery name="qUpdateSettings" datasource="#application.datasource#">
				UPDATE  _Application_Settings
				SET
				Dashboard_Labels_Updated_By = <cfqueryparam value="#this.settings.getUpdatedBy()#" cfsqltype="CF_SQL_VARCHAR">,
				Dashboard_Labels_Updated_On = GetDate()
			</cfquery>
			<cfset Track_Changes()>
			<cfcatch>
				<cftransaction action="ROLLBACK">
				<cfrethrow>
			</cfcatch>
		</cftry>
		</cftransaction>
	<!--- 63670 - labels for program letters --->
	<cfelseif arguments.settingsType EQ 21>
		<cftransaction action="BEGIN">
		<cftry>
			<!------ insert new ----->
			<cfquery name="qUpdateSettings" datasource="#application.datasource#">
				UPDATE	_Application_Settings
				SET
				Program_Letters_Labels_Updated_By = <cfqueryparam value="#this.settings.getUpdatedBy()#" cfsqltype="CF_SQL_VARCHAR">,
				Program_Letters_Labels_Updated_On = GetDate()
			</cfquery>
			<cfset Track_Changes()>
			<cfcatch>
				<cftransaction action="ROLLBACK">
				<cfrethrow>
			</cfcatch>
		</cftry>
		</cftransaction>
	<!--- 64600 - labels for planner --->
	<cfelseif arguments.settingsType EQ 22>
		<cftransaction action="BEGIN">
		<cftry>
			<!------ insert new ----->
			<cfquery name="qUpdateSettings" datasource="#application.datasource#">
				UPDATE	_Application_Settings
				SET
				Planner_Labels_Updated_By = <cfqueryparam value="#this.settings.getUpdatedBy()#" cfsqltype="CF_SQL_VARCHAR">,
				Planner_Labels_Updated_On = GetDate()
			</cfquery>
			<cfset Track_Changes()>
			<cfcatch>
				<cftransaction action="ROLLBACK">
				<cfrethrow>
			</cfcatch>
		</cftry>
		</cftransaction>
	</cfif>
</cffunction>

<cffunction name="getApprovalTypeList" output="false" returntype="string">
	<cfset AvailableApprovalOptions = "">
	<cfif application.appSettingsGet.getApprovalPoundMarginOn()>
		<cfset AvailableApprovalOptions = ListAppend(AvailableApprovalOptions, 1, ",")>
	</cfif>
	<cfif application.appSettingsGet.getApprovalPercentMarginOn()>
		<cfset AvailableApprovalOptions = ListAppend(AvailableApprovalOptions, 2, ",")>
	</cfif>
	<cfif application.appSettingsGet.getApprovalTotalPgmMarginOn()>
		<cfset AvailableApprovalOptions = ListAppend(AvailableApprovalOptions, 3, ",")>
	</cfif>
	<cfif application.appSettingsGet.getApprovalSpendingCapOn()>
		<cfset AvailableApprovalOptions = ListAppend(AvailableApprovalOptions, 4, ",")>
	</cfif>
	<cfif application.appSettingsGet.getApprovalLayeredOn()>
		<cfset AvailableApprovalOptions = ListAppend(AvailableApprovalOptions, 5, ",")>
	</cfif>
	<cfif application.appSettingsGet.getApprovalDisposableOn()>
		<cfset AvailableApprovalOptions = ListAppend(AvailableApprovalOptions, 6, ",")>
	</cfif>
	<cfif application.appSettingsGet.getApprovalStandardOn()>
		<cfset AvailableApprovalOptions = ListAppend(AvailableApprovalOptions, 7, ",")>
	</cfif>
	<cfreturn AvailableApprovalOptions>
</cffunction>

<cffunction name="getApprovalTypeLongDesc" output="false" returntype="string">
	<cfargument name="approvalType" required="true" type="numeric">
	<cfset returnValue = "">
	<cfswitch expression="#arguments.approvalType#">
		<cfcase value="1">
			<cfset returnValue = "$/Pound Margin">
		</cfcase>
		<cfcase value="2">
			<cfset returnValue = "% Margin">
		</cfcase>
		<cfcase value="3">
			<cfset returnValue = "Total Program % Margin">
		</cfcase>
		<cfcase value="4">
			<cfset returnValue = "Spending Cap">
		</cfcase>
		<cfcase value="5">
			<cfset returnValue = "Layered">
		</cfcase>
		<cfcase value="6">
			<cfset returnValue = "Disposable Goods">
		</cfcase>
		<cfcase value="7">
			<cfset returnValue = "Standard">
		</cfcase>
	</cfswitch>
	<cfreturn returnValue>
</cffunction>

<cffunction name="getApprovalTypeShortDesc" output="false" returntype="string">
	<cfargument name="approvalType" required="true" type="numeric">
	<cfset returnValue = "">
	<cfswitch expression="#arguments.approvalType#">
		<cfcase value="1">
			<cfset returnValue = "$/PM">
		</cfcase>
		<cfcase value="2">
			<cfset returnValue = "% M">
		</cfcase>
		<cfcase value="3">
			<cfset returnValue = "TP%M">
		</cfcase>
		<cfcase value="4">
			<cfset returnValue = "SC">
		</cfcase>
		<cfcase value="5">
			<cfset returnValue = "L">
		</cfcase>
		<cfcase value="6">
			<cfset returnValue = "D">
		</cfcase>
		<cfcase value="7">
			<cfset returnValue = "S">
		</cfcase>
	</cfswitch>
	<cfreturn returnValue>
</cffunction>

<cffunction name="getDisplayGroupType" output="false" returntype="numeric">
	<cfargument name="savedGroupTypeId" required="true" type="numeric">
	<cfset returnValue = 0>
	<cfif arguments.savedGroupTypeId EQ 1>
		<!------ type code ----->
		<cfset returnValue = arguments.savedGroupTypeId>
		<cfset this.settings.setViewProgramProductGroupTypeDesc(application.returned_customer_setting.type_code_label_singular) />
	<cfelseif arguments.savedGroupTypeId EQ 3>
		<!------ Q Brand ----->
		<cfif this.settings.getUseProductGroup2()>
			<cfset returnValue = arguments.savedGroupTypeId>
			<cfset this.settings.setViewProgramProductGroupTypeDesc(application.returned_customer_setting.q_brand_label_singular) />
		</cfif>
	</cfif>
	<cfreturn returnValue>
</cffunction>

<cffunction name="getPriceListIds" output="false" returntype="query">
	<cfset useLakebaseForqGetPriceListIds = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("price_list_header")>
<cfif useLakebaseForqGetPriceListIds>
	<cftry>
		<cfset qGetPriceListIds = application.oLakebase.toQuery(
			application.oLakebase.selectRows("price_list_header", {
				"deleted" = "eq.0",
				"order" = "price_list_id.asc",
				"select" = "price_list_id"
			}), "price_list_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetPriceListIds = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetPriceListIds>
<cfquery name="qGetPriceListIds" datasource="#application.datasource#">
		SELECT  Price_List_ID
		FROM  Price_List_Header
		WHERE Deleted = 0
		ORDER BY Price_List_ID
	</cfquery>
</cfif>
	<cfreturn qGetPriceListIds>
</cffunction>

<cffunction name="getDiscountTypeDesc" output="false" returntype="string">
	<cfargument name="discountTypeId" required="true" type="numeric" />
	<cfquery name="qGetDiscountTypes" datasource="#application.datasource#">
		SELECT  Discount_Type_Desc
		FROM  Discount_Type
		WHERE Deleted = 0
		AND   Discount_Type_ID = <cfqueryparam value="#arguments.discountTypeId#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfreturn qGetDiscountTypes.Discount_Type_Desc />
</cffunction>

<cffunction name="getcategories" output="false" returntype="Query">
	<cfquery name="qlistcategories" datasource="#application.datasource#" >
		SELECT  Name
		FROM Application_Setting_Setting_Category
		ORDER BY Name ASC
	</cfquery>
	<cfreturn qlistcategories>
</cffunction>

<cffunction name="getsettings" output="false" returntype="Query" >
	<cfargument name="settings_type" 	required="true" 	type="string" >
	<cfargument name="settings_search" 	required="false" 	type="any" >
	<cfquery name="qlistsettings" datasource="#application.datasource#">
		SELECT 	APS.Description,
				APS.Value,
				APS.Help_Info,
				APS.Dependency_Id,
				APS.Options_Display,
				APS.Options_Value,
				DT.Data_Type_Description,
				FC.Control,
				APPC.Name,
				APS.SETTINGS_NAME
		FROM   		Application_Settings APS
		LEFT JOIN	Application_Setting_Data_Type DT ON APS.Application_Setting_Data_Type_ID = DT.Application_Setting_Data_Type_ID
		LEFT JOIN   Application_Setting_Setting_Form_Control FC ON APS.Application_Setting_Form_Control_ID = FC.Application_Setting_Form_Control_ID
		LEFT JOIN 	Application_Setting_Setting_Category APPC ON APS.Application_Setting_Setting_Category_ID = APPC.Application_Setting_Setting_Category_ID
		WHERE     	APS.Deleted = 0
		<cfif (arguments.settings_type NEQ 'ALL') AND (len(arguments.settings_search) EQ 0)>
			AND 	APPC.Name = <cfqueryparam value="#arguments.settings_type#" cfsqltype="CF_SQL_VARCHAR">
		</cfif>
		<cfif len(arguments.settings_search)>
			AND		APS.SETTINGS_NAME LIKE <cfqueryparam value="%#arguments.settings_search#%" cfsqltype="CF_SQL_VARCHAR">
		</cfif>
		ORDER BY    APS.Description ASC
	</cfquery>
	<cfreturn qlistsettings>
</cffunction>

<cfinclude template="TrackChanges.cfm">

</cfcomponent>
