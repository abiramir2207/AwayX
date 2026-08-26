<cfcomponent displayname="AplicationSettingsSave" output="false">

    <cffunction name="init" output="false">

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

    <!--- To avoid an error, add any new entries in other function, below --->
    <cffunction name="saveSettingType2" output="false" returntype="void">
        <cfargument name="settings" required="true">

        <!------ update ----->
        <cfquery name="qUpdateSettings" datasource="#application.datasource#">
            UPDATE	_Application_Settings
            SET		Dollar_Growth 		= <cfqueryparam value="#arguments.settings.getDollarGrowth()#" cfsqltype="CF_SQL_bit">,
                    Use_X_Material 		= <cfqueryparam value="#arguments.settings.getUseXMaterial()#" cfsqltype="CF_SQL_bit">,
                    UseProductGroup1 	= <cfqueryparam value="#arguments.settings.getUseProductGroup1()#" cfsqltype="CF_SQL_bit">,
                    UseProductGroup2 	= <cfqueryparam value="#arguments.settings.getUseProductGroup2()#" cfsqltype="CF_SQL_bit">,
                    UseProductGroup3 	= <cfqueryparam value="#arguments.settings.getUseProductGroup3()#" cfsqltype="CF_SQL_bit">,
                    UseProductGroup4 	= <cfqueryparam value="#arguments.settings.getUseProductGroup4()#" cfsqltype="CF_SQL_bit">,
                    UseProductGroup5 	= <cfqueryparam value="#arguments.settings.getUseProductGroup5()#" cfsqltype="CF_SQL_bit">,
                    UseProductHierarchy	= <cfqueryparam value="#arguments.settings.getUseProductHierarchy()#" cfsqltype="CF_SQL_bit">,
                    ApplicationSettingsOnForAll	= <cfqueryparam value="#arguments.settings.getAppSettingsOnForAll()#" cfsqltype="CF_SQL_bit">,
                    Auto_Broker	= <cfqueryparam value="#arguments.settings.getAutoBroker()#" cfsqltype="CF_SQL_bit">,
                    RFA_Agree	= <cfqueryparam value="#arguments.settings.getRfaAgree()#" cfsqltype="CF_SQL_bit">,
                    Customer_type	= <cfqueryparam value="#arguments.settings.getCustomertype()#" cfsqltype="CF_SQL_bit">,
                    Restrict_Product_UOM	= <cfqueryparam value="#arguments.settings.getRestrictProductUOM()#" cfsqltype="CF_SQL_bit">,
                    Rebate_Max_Components	= <cfqueryparam value="#arguments.settings.getRebateMaxComponents()#" cfsqltype="CF_SQL_INTEGER">,
                    Floor_Price	= <cfqueryparam value="#arguments.settings.getFloorPrice()#" cfsqltype="CF_SQL_VARCHAR">,
                    AllowNavigate	= <cfqueryparam value="#arguments.settings.getAllowNavigate()#" cfsqltype="CF_SQL_bit">,
                    Lump_Multiple_Products = <cfqueryparam value="#arguments.settings.getLumpMultipleProducts()#" cfsqltype="CF_SQL_bit">,
                    programnotesrequired = <cfqueryparam value="#arguments.settings.getprogramnotesrequired()#" cfsqltype="CF_SQL_bit">,
                    Equipment_Placement = <cfqueryparam value="#arguments.settings.getEquipment_Placement()#" cfsqltype="CF_SQL_bit">,
                    Classcodes_On = <cfqueryparam value="#arguments.settings.getClasscodesOn()#" cfsqltype="CF_SQL_bit">,
                    Growth_Expansion_1 = <cfqueryparam value="#arguments.settings.getGrowthExpansion1()#" cfsqltype="CF_SQL_bit">,
                    fixedcomponents_on  = <cfqueryparam value="#arguments.settings.getfixedcomponents_on()#" cfsqltype="CF_SQL_bit">,
                    rolloverprograms_on = <cfqueryparam value="#arguments.settings.getrolloverprograms_on()#" cfsqltype="CF_SQL_bit">,
                    ForbidAllowProfilesInTemplates = <cfqueryparam value="#arguments.settings.getForbidAllowProfilesInTemplates()#" cfsqltype="CF_SQL_bit">,
                    uploadmargintargets_on = <cfqueryparam value="#arguments.settings.getuploadmargintargets_on()#" cfsqltype="CF_SQL_bit">,
                    businessconsiderations_on = <cfqueryparam value="#arguments.settings.getbusinessconsiderations_on()#" cfsqltype="CF_SQL_bit">,
                    RestrictAccessOnGroup = <cfqueryparam value="#arguments.settings.getRestrictAccessOnGroup()#" cfsqltype="CF_SQL_bit">,
                    custid_on = <cfqueryparam value="#arguments.settings.getcustid_on()#" cfsqltype="CF_SQL_bit">,
                    singlesign_on = <cfqueryparam value="#arguments.settings.getsinglesign_on()#" cfsqltype="CF_SQL_TINYINT">,
                    BB_Fixed_Calc_Types_On = <cfqueryparam value="#arguments.settings.getBBFixedCalcTypesOn()#" cfsqltype="CF_SQL_bit">,
                    claimAutoPrint = <cfqueryparam value="#arguments.settings.getClaimAutoPrint()#" cfsqltype="CF_SQL_bit">,
                    allowAllDistributors = <cfqueryparam value="#arguments.settings.getAllowAllDistributors()#" cfsqltype="CF_SQL_bit">,
                    maxProfileCount = <cfqueryparam value="#arguments.settings.getMaxProfileCount()#" cfsqltype="CF_SQL_INTEGER">,
                    distributorMultiPosition = <cfqueryparam value="#arguments.settings.getDistributorMultiPosition()#" cfsqltype="CF_SQL_bit">,
                    operatorSearchRestrict = <cfqueryparam value="#arguments.settings.getOperatorSearchRestrict()#" cfsqltype="CF_SQL_bit">,
                    Sales_Org_On = <cfqueryparam value="#arguments.settings.getSalesOrgOn()#" cfsqltype="CF_SQL_bit">,
                    Distribution_Channel_On = <cfqueryparam value="#arguments.settings.getDistributionChannelOn()#" cfsqltype="CF_SQL_bit">,
                    Delete_Program_Message = <cfqueryparam value="#arguments.settings.getDeleteProgramMessage()#" cfsqltype="CF_SQL_VARCHAR">,
                    Delete_Autorenew_Pgm_Is_Cancel = <cfqueryparam value="#arguments.settings.getDeleteIsCancelAutoRenew()#" cfsqltype="CF_SQL_bit">,
                    Payment_Cycle_At_Discount_Type = <cfqueryparam value="#arguments.settings.getPaymentCycleAtDiscountType()#" cfsqltype="CF_SQL_bit">,
                    Settlement_SAP_Business = <cfqueryparam value="#arguments.settings.getSettlement_SAP_Business()#" cfsqltype="CF_SQL_bit">,
                    Sysco_Report_On = <cfqueryparam value="#arguments.settings.getSysco_Report_On()#" cfsqltype="CF_SQL_bit">,
                    Send_to_SAP = <cfqueryparam value="#arguments.settings.getSend_to_SAP()#" cfsqltype="CF_SQL_bit">,
                    templatecodes_on = <cfqueryparam value="#arguments.settings.gettemplatecodes_on()#" cfsqltype="CF_SQL_bit">,
                    Integation_Instance_ID = <cfqueryparam value="#arguments.settings.getIntegation_Instance_ID()#" cfsqltype="CF_SQL_VARCHAR">,
                    BB_Ref_Num_Max_Length = <cfqueryparam value="#arguments.settings.getBB_Ref_Num_Max_Length()#" cfsqltype="CF_SQL_VARCHAR">,
                    BB_2Ref_Num_Max_Length = <cfqueryparam value="#arguments.settings.getBB_2Ref_Num_Max_Length()#" cfsqltype="CF_SQL_VARCHAR">,
                    Allow_Multi_Level_Groups = <cfqueryparam value="#arguments.settings.getAllowMultiLevelGroups()#" cfsqltype="CF_SQL_bit">,
                    Program_Agree_Escalate = <cfqueryparam value="#arguments.settings.getProgramAgreeEscalate()#" cfsqltype="CF_SQL_bit">,
                    Check_Order_Class = <cfqueryparam value="#arguments.settings.getCheckOrderClass()#" cfsqltype="CF_SQL_bit">,
                    Order_Class_Value = <cfqueryparam value="#arguments.settings.getOrderClassValue()#" cfsqltype="CF_SQL_VARCHAR">,
                    BB_Payee_Operator_Ship_To_Req = <cfqueryparam value="#arguments.settings.getBB_Payee_Operator_Ship_To_Req()#" cfsqltype="CF_SQL_bit">,
                    Vendor_Selection_Pay_Req = <cfqueryparam value="#arguments.settings.getVendor_Selection_Pay_Req()#" cfsqltype="CF_SQL_bit">,
                    Billback_Payment_Request_Without_Vendor_Selection = <cfqueryparam value="#arguments.settings.getBillback_Payment_Request_Without_Vendor_Selection()#" cfsqltype="CF_SQL_bit">,
                    Restrict_DD_Reason_Code_By_Closing_method = <cfqueryparam value="#arguments.settings.getRestrict_DD_Reason_Code_By_Closing_method()#" cfsqltype="CF_SQL_bit">,
                    Multiple_BB_Per_Deduction = <cfqueryparam value="#arguments.settings.getMultiple_BB_Per_Deduction()#" cfsqltype="CF_SQL_bit">,
                    Allow_Negative_Billback = <cfqueryparam value="#arguments.settings.getAllow_Negative_Billback()#" cfsqltype="CF_SQL_bit">,
                    BB_Allow_Off_Invoice_Closing_Method = <cfqueryparam value="#arguments.settings.getBB_Allow_Off_Invoice_Closing_Method()#" cfsqltype="CF_SQL_bit">,
                    Interface_700_To_Client = <cfqueryparam value="#arguments.settings.getInterface_700_To_Client()#" cfsqltype="CF_SQL_bit">,
                    DD_Show_reassign = <cfqueryparam value="#arguments.settings.getDD_Show_reassign()#" cfsqltype="CF_SQL_bit">,
                    Auto_Deviation_On = <cfqueryparam value="#arguments.settings.getAuto_Deviation_On()#" cfsqltype="CF_SQL_bit">,
                    DD_Show_Classification = <cfqueryparam value="#arguments.settings.getDD_Show_Classification()#" cfsqltype="CF_SQL_bit">,
                    DD_Show_DeductionType = <cfqueryparam value="#arguments.settings.getDD_Show_DeductionType()#" cfsqltype="CF_SQL_bit">,  <!---26487--->
                    DD_Show_Edit_Customer_Num = <cfqueryparam value="#arguments.settings.getDD_Show_Edit_Customer_Num()#" cfsqltype="CF_SQL_bit">,
                    DD_Show_Create_Adjustment = <cfqueryparam value="#arguments.settings.getDD_Show_Create_Adjustment()#" cfsqltype="CF_SQL_bit">,
                    Component_Product_Restrictions_On = <cfqueryparam value="#arguments.settings.getComponent_Product_Restrictions_On()#" cfsqltype="CF_SQL_bit">,
                    DD_Show_Delete = <cfqueryparam value="#arguments.settings.getDD_Show_Delete()#" cfsqltype="CF_SQL_bit">,
                    DD_Show_ReOpen = <cfqueryparam value="#arguments.settings.getDD_Show_ReOpen()#" cfsqltype="CF_SQL_bit">,
                    DD_Show_Reject = <cfqueryparam value="#arguments.settings.getDD_Show_Reject()#" cfsqltype="CF_SQL_bit">,
                    DD_Show_Program = <cfqueryparam value="#arguments.settings.getDD_Show_Program()#" cfsqltype="CF_SQL_bit">,
                    DD_Show_Invoices = <cfqueryparam value="#arguments.settings.getDD_Show_Invoices()#" cfsqltype="CF_SQL_bit">,
                    ERP_Deal_ID_PopUp = <cfqueryparam value="#arguments.settings.getERP_Deal_ID_PopUp()#" cfsqltype="CF_SQL_bit">,
                    BB_Allow_UnKnow_Program_Creation = <cfqueryparam value="#arguments.settings.getBB_Allow_UnKnow_Program_Creation()#" cfsqltype="CF_SQL_bit">,
                    BB_Pay_Req_Dup_Check = <cfqueryparam value="#arguments.settings.getBB_Pay_Req_Dup_Check()#" cfsqltype="CF_SQL_bit">,
                    <!--- Template_Notes_Availability = <cfqueryparam value="#arguments.settings.getTemplate_Notes_Availability()#" cfsqltype="CF_SQL_bit">, ---> <!--- BJF: Removed with label 13333	 --->
                    Match_BB_DD_Based_On_Same_ReferenceNum = <cfqueryparam value="#arguments.settings.getMatch_BB_DD_Based_On_Same_ReferenceNum()#" cfsqltype="CF_SQL_bit">,
                    User_Number_Restrict = <cfqueryparam value="#arguments.settings.getUserNumberRestrict()#" cfsqltype="CF_SQL_bit">,
                    USDANOI_Enabled = <cfqueryparam value="#arguments.settings.getUSDANOIENABLED()#" cfsqltype="CF_SQL_bit">,
                    Program_By_Product_On = <cfqueryparam value="#arguments.settings.getProductSearchGetProductByProgramOn()#" cfsqltype="CF_SQL_bit">,
                    Disable_Group_Selection_In_Product_Search = <cfqueryparam value="#arguments.settings.getDisableGroupProductSearchINproductSearch()#" cfsqltype="CF_SQL_bit">,
                    Start_Auto_Renew_At_RFA = <cfqueryparam value="#arguments.settings.getStartAutoRenewAtRFA()#" cfsqltype="CF_SQL_bit">,
                    Dist_Search_Get_Dist_By_Program_On = <cfqueryparam value="#arguments.settings.getDistSearchGetDistByProgramOn()#" cfsqltype="CF_SQL_bit">,
                    Invoice_Broker_Filter_Restrict = <cfqueryparam value="#arguments.settings.getInvoiceBrokerFilterRestrict()#" cfsqltype="CF_SQL_bit">,
                    View_Program_Product_Group_Type = <cfqueryparam value="#arguments.settings.getViewProgramProductGroupType()#" cfsqltype="CF_SQL_INTEGER">,
                    CustsearchRebaterecipientOn = <cfqueryparam value="#arguments.settings.getCustsearchRebaterecipientOn()#" cfsqltype="CF_SQL_bit">,
                    One_Program_Per_Billback = <cfqueryparam value="#arguments.settings.getOneProgramPerBillback()#" cfsqltype="CF_SQL_bit">,
                    Program_Budget_On = <cfqueryparam value="#arguments.settings.getProgramBudgetOn()#" cfsqltype="CF_SQL_bit">,
                    Spending_Cap_Version = <cfqueryparam value="#arguments.settings.getSpendingCapVersion()#" cfsqltype="CF_SQL_bit">,
                    Growth_Decimal_4_Percent_Tier = <cfqueryparam value="#arguments.settings.getGrowthDecimal4PercentTier()#" cfsqltype="CF_SQL_bit">,
                    For_invoices_Display_OI = <cfqueryparam value="#arguments.settings.getForinvoicesDisplayOI()#" cfsqltype="CF_SQL_bit">,
                    Bid_Request_Price_List_ID = <cfqueryparam value="#arguments.settings.getBidRequestPriceListId()#" cfsqltype="CF_SQL_CHAR">,
                    <!---BB_Agree_Email = <cfqueryparam value="#arguments.settings.getBBAgreeEmail()#" cfsqltype="CF_SQL_BIT">, --->
                    BB_Check_Pay_To = <cfqueryparam value="#arguments.settings.getBBCheckPayTo()#" cfsqltype="CF_SQL_BIT">,
                    App_Error_Add_To_Punchlist = <cfqueryparam value="#arguments.settings.getAppErrorAddToPunchlist()#" cfsqltype="CF_SQL_BIT">,
                    disable_BB_Add_Program = <cfqueryparam value="#arguments.settings.getdisableBBAddProgram()#" cfsqltype="CF_SQL_BIT">,
                    Pgm_Lumpsum_Detailed_Display = <cfqueryparam value="#arguments.settings.getPgmLumpsumDetailedDisplay()#" cfsqltype="CF_SQL_BIT">,
                    Renew_expired_programs = <cfqueryparam value="#arguments.settings.getRenew_expired_programs()#" cfsqltype="CF_SQL_BIT">,
                    Use_Accounting_Program_Type = <cfqueryparam value="#arguments.settings.getUse_Accounting_Program_Type()#" cfsqltype="CF_SQL_bit">,
                    BB_PP_Manual_Discount = <cfqueryparam value="#arguments.settings.getBB_PP_Manual_Discount()#" cfsqltype="CF_SQL_bit">,
                    BB_Date_Dev_In_Expected_Vol = <cfqueryparam value="#arguments.settings.getBBDateDevInExpectedVol()#" cfsqltype="CF_SQL_bit">,
                    Show_BSA_Operators = <cfqueryparam value="#arguments.settings.getShowBSAOperators()#" cfsqltype="CF_SQL_bit">,
                    Bid_Request_Available = <cfqueryparam value="#arguments.settings.getBidRequestAvailable()#" cfsqltype="CF_SQL_bit">,
                    Futures_Pricing_Available = <cfqueryparam value="#arguments.settings.getFuturesPricingAvailable()#" cfsqltype="CF_SQL_bit">,
                    External_Webservice_URL = <cfqueryparam value="#arguments.settings.getExternalWebserviceURL()#" cfsqltype="CF_SQL_VARCHAR">,
                    Webserver_Internal_IP_Address = <cfqueryparam value="#arguments.settings.getWebserverInternalIPAddress()#" cfsqltype="CF_SQL_VARCHAR">,
                    AutoRenewSpaninPW = <cfqueryparam value="#arguments.settings.getAutoRenewSpaninPW()#" cfsqltype="CF_SQL_bit">,
                    Program_Allow_Null_Rate = <cfqueryparam value="#arguments.settings.getProgram_Allow_Null_Rate()#" cfsqltype="CF_SQL_BIT">,
                    Claims_at_Comp_Level = <cfqueryparam value="#arguments.settings.getClaims_at_Comp_Level()#" cfsqltype="CF_SQL_BIT">,
                    Pgm_Disable_Edit_While_Sending_To_Client = <cfqueryparam value="#arguments.settings.getPgmDisableEditWhileSendingToClient()#" cfsqltype="CF_SQL_bit">,
                    Operating_Group_On = <cfqueryparam value="#arguments.settings.getOperatingGroupOn()#" cfsqltype="CF_SQL_bit">,
                    letters_available = <cfqueryparam value="#arguments.settings.getlettersavailable()#" cfsqltype="CF_SQL_INTEGER">,
                    letters_from_email = <cfqueryparam value="#arguments.settings.getlettersfromemail()#" cfsqltype="CF_SQL_VARCHAR">,
                    letters_subject = <cfqueryparam value="#arguments.settings.getletterssubject()#" cfsqltype="CF_SQL_VARCHAR">,
                    Search_Sequence_On = <cfqueryparam value="#arguments.settings.getSearchSequenceOn()#" cfsqltype="CF_SQL_bit">,
                    local_cost_variables = <cfqueryparam value="#arguments.settings.getlocalcostvariables()#" cfsqltype="CF_SQL_INTEGER">,
                    customer_based_costs = <cfqueryparam value="#arguments.settings.getcustomerbasedcosts()#" cfsqltype="CF_SQL_bit">,
                    max_local_cost_vars = <cfqueryparam value="#arguments.settings.getmaxlocalcostvars()#" cfsqltype="CF_SQL_INTEGER">,
                    Pgm_Grps_Only_Prod_At_Lower_Level = <cfqueryparam value="#arguments.settings.getPgmGrpsOnlyProdAtLowerLevel()#" cfsqltype="CF_SQL_bit">,
                    Group_By_Group_Type =  <cfqueryparam value="#arguments.settings.getGroupByGroupType()#" cfsqltype="CF_SQL_INTEGER">,
                    Show_Or_Hide_Groups = <cfqueryparam value="#arguments.settings.getShowORHideGroupsInViewMargin()#" cfsqltype="CF_SQL_INTEGER">,
                    Trade_Planner_Off = <cfqueryparam value="#arguments.settings.gettradeplanneroff()#" cfsqltype="CF_SQL_bit">,
                    Approval_Matrix_Off = <cfqueryparam value="#arguments.settings.getapprovalmatrixoff()#" cfsqltype="CF_SQL_bit">,
                    Allowed_to_Add_Operator = <cfqueryparam value="#arguments.settings.getAllowed_to_Add_Operator()#" cfsqltype="CF_SQL_CHAR">,
                    Created_Operators_Default_Active = <cfqueryparam value="#arguments.settings.getCreated_Operators_Default_Active()#" cfsqltype="CF_SQL_bit">,
                    print_includeheader = <cfqueryparam value="#arguments.settings.getprintincludeheader()#" cfsqltype="CF_SQL_bit">,
                    pricing_template_list = <cfqueryparam value="#arguments.settings.getpricingtemplatelist()#" cfsqltype="CF_SQL_VARCHAR">,
                    Show_Projects_ScoreCard = <cfqueryparam value="#arguments.settings.getShowProjectsScoreCard()#" cfsqltype="CF_SQL_Bit">,
                    Pgm_Scorecard_Revision_Report = <cfqueryparam value="#arguments.settings.getPgmScorecardRevisionReport()#" cfsqltype="CF_SQL_Bit">,
                    Invoice_Position_Restriction = <cfqueryparam value="#arguments.settings.getInvoicePositionRestriction()#" cfsqltype="CF_SQL_Bit">,
                    Distributor_Letter_Name = <cfqueryparam value="#arguments.settings.getDistributorLetterName()#" cfsqltype="CF_SQL_VARCHAR">,
                    Operator_Letter_Name = <cfqueryparam value="#arguments.settings.getOperatorLetterName()#" cfsqltype="CF_SQL_VARCHAR">,
                    Remove_Market_From_Pgm_SearchPage =  <cfqueryparam value="#arguments.settings.getRemoveMarketFromPgmSearchPage()#" cfsqltype="CF_SQL_Bit">,
                    Check_All_Duplicate_Program = <cfqueryparam value="#arguments.settings.getCheckAllDuplicateProgram()#" cfsqltype="CF_SQL_bit">,
                    Authority_Sequence_For_HQ_Only = <cfqueryparam value="#arguments.settings.getAuthority_Sequence_For_HQ_Only()#" cfsqltype="CF_SQL_bit">,
                    Pgm_View_Display_SPR_Address2 = <cfqueryparam value="#arguments.settings.getPgmViewDisplaySPRAddress2()#" cfsqltype="CF_SQL_bit">,
                    Bid_Request_Hierarchy_Level = <cfqueryparam value="#arguments.settings.getBidRequestHierarchyLevel()#" cfsqltype="CF_SQL_VARCHAR">,
                    <!---Pgm_Email_Pricing_Admin = <cfqueryparam value="#arguments.settings.getPgmEmailPricingAdmin()#" cfsqltype="CF_SQL_bit">,---> <!--- removed with label 18746 --->
                    Letters_Accepted_By = <cfqueryparam value="#arguments.settings.getLettersAcceptedBy()#" cfsqltype="CF_SQL_VARCHAR">,
                    Letters_Address = <cfqueryparam value="#arguments.settings.getLettersAddress()#" cfsqltype="CF_SQL_VARCHAR">,
                    BB_Restrict_Route_User_List = <cfqueryparam value="#arguments.settings.getBBRestrictRouteUserList()#" cfsqltype="CF_SQL_bit">,
                    Common_Access_URL_Prefix = <cfqueryparam value="#arguments.settings.getCommonAccessURLPrefix()#" cfsqltype="CF_SQL_VARCHAR">,
                    Pgm_Like_Product_Checkbox = <cfqueryparam value="#arguments.settings.getPgmLikeProductCheckbox()#" cfsqltype="CF_SQL_bit">,
                    view_approved_margins_report = <cfqueryparam value="#arguments.settings.getviewapprovedmarginsreport()#" cfsqltype="CF_SQL_bit">,
                    Pgm_Display_Both_Rate_UOM = <cfqueryparam value="#arguments.settings.getPgmDisplayBothRateUOM()#" cfsqltype="CF_SQL_bit">,
                    retain_original_RSP = <cfqueryparam value="#arguments.settings.getretainoriginalRSP()#" cfsqltype="CF_SQL_bit">,
                    Daily_RSP_Update = <cfqueryparam value="#arguments.settings.getdailyRSPUpdate()#" cfsqltype="CF_SQL_bit">,
                    Mass_Pay_Billback = <cfqueryparam value="#arguments.settings.getMass_Pay_Billback()#" cfsqltype="CF_SQL_INTEGER">,
                    ClaimMech_Popup = <cfqueryparam value="#arguments.settings.getClaimMech_Popup()#" cfsqltype="CF_SQL_INTEGER">,
                    Display_Only_Assigned_Deductions = <cfqueryparam value="#arguments.settings.getDisplayOnlyAssignedDeductions()#" cfsqltype="CF_SQL_BIT">,
                    cancel_all_program_versions = <cfqueryparam value="#arguments.settings.getcancelallprogramversions()#" cfsqltype="CF_SQL_bit">,
                    Show_Mapping = <cfqueryparam value="#arguments.settings.getShowMapping()#" cfsqltype="CF_SQL_bit">,
                    Billbacks_Sales_Tax = <cfqueryparam value="#arguments.settings.getBillbacksSalesTax()#" cfsqltype="CF_SQL_INTEGER">,
                    Show_Lumpsum_Distributors = <cfqueryparam value="#arguments.settings.getLumpSumDistributors()#" cfsqltype="CF_SQL_bit">,
                    Show_BB_Route = <cfqueryparam value="#arguments.settings.getShow_BB_Route()#" cfsqltype="CF_SQL_bit">,
                    Display_Requester_Approver = <cfqueryparam value="#arguments.settings.get_Requester_Approver()#" cfsqltype="CF_SQL_bit">,
                    Display_Requester_Approver_Position = <cfqueryparam value="#arguments.settings.get_Requester_Approver_Position()#" cfsqltype="CF_SQL_bit">,
                    Hide_BSA_Users = <cfqueryparam value="#arguments.settings.getHide_BSA_Users()#" cfsqltype="CF_SQL_bit">,
                    Report_Payment_History = <cfqueryparam value="#arguments.settings.get_Report_Payment_History()#" cfsqltype="CF_SQL_bit">,
                    Show_Program_Category = <cfqueryparam value="#arguments.settings.getProgramCategory()#" cfsqltype="CF_SQL_bit">,
                    disallow_shared_products_in_lumpsum = <cfqueryparam value="#arguments.settings.getAvoidSharedProductsinLumpSum()#" cfsqltype="CF_SQL_INTEGER">,
                    Remove_Help_Icon = <cfqueryparam value="#arguments.settings.getRemoveHelpIcon()#" cfsqltype="CF_SQL_bit">,
                    display_clients_help_desk_info = <cfqueryparam value="#arguments.settings.getdisplayclientshelpdeskinfo()#" cfsqltype="CF_SQL_bit">,
                    User_Fax_Number = <cfqueryparam value="#arguments.settings.getUserFaxNumber()#" cfsqltype="CF_SQL_bit">,
                    clients_help_desk_info = <cfqueryparam value="#arguments.settings.getclientshelpdeskinfo()#" cfsqltype="CF_SQL_VARCHAR">,
                    revision_report_uom =  <cfqueryparam value="#arguments.settings.getrevisionreportuom()#" cfsqltype="CF_SQL_integer">,
                    display_zeros_view_program = <cfqueryparam value="#arguments.settings.getdisplayzerosviewprogram()#" cfsqltype="CF_SQL_bit">,
                    Apply_RSP_Filters = <cfqueryparam value="#arguments.settings.getApplyRSPFilters()#" cfsqltype="CF_SQL_bit">,
                    direct_pricing_on = <cfqueryparam value="#arguments.settings.getdirectpricingon()#" cfsqltype="CF_SQL_bit">,
                    Pgm_Grp_Level3_Is_Exclusion = <cfqueryparam value="#arguments.settings.getPgmGrpLevel3IsExclusion()#" cfsqltype="CF_SQL_bit">,
                    ShowUploadAccrual = <cfqueryparam value="#arguments.settings.getShowUploadAccrual()#" cfsqltype="CF_SQL_bit">,
                    Bonus_Growth_Switch = <cfqueryparam value="#arguments.settings.getBonusInGrowthSwitch()#" cfsqltype="CF_SQL_bit">,
                    ViewPgmSortBy = <cfqueryparam value="#arguments.settings.getViewPgmSortBy()#" cfsqltype="CF_SQL_INTEGER">,<!--- Dev Note: CPM 8223 --->
                    Search_Product_Hierarchy_Exclude_List = <cfqueryparam value="#arguments.settings.getSearchProductHierarchyExcludeList()#" cfsqltype="CF_SQL_VARCHAR">,
                    letters_company_logo_path = <cfqueryparam value="#arguments.settings.getletterscompanylogopath()#" cfsqltype="CF_SQL_VARCHAR">,
                    payment_history_on = <cfqueryparam value="#arguments.settings.getpaymenthistoryon()#" cfsqltype="CF_SQL_bit">,
                    BB_Allow_Vendor_Master_Search = <cfqueryparam value="#arguments.settings.getBBAllowVendorMasterSearch()#" cfsqltype="CF_SQL_bit">,
                    Vendor_Search_In_BB_Payee_Page = <cfqueryparam value="#arguments.settings.getVendorSearchInBBPayeePage()#" cfsqltype="CF_SQL_bit">,
                    DD_Reassign_Analyst_While_Changing_Pay_To = <cfqueryparam value="#arguments.settings.getDDReassignAnalystWhileChangingPayTo()#" cfsqltype="CF_SQL_bit">,
                    DD_Assignment_Based_On_Shr_Ship_to = <cfqueryparam value="#arguments.settings.getDDAssignmentBasedOnShrShipto()#" cfsqltype="CF_SQL_bit">,
                    DD_Allow_Negative_Amount_Credits = <cfqueryparam value="#arguments.settings.getDDAllowNegativeAmountCredits()#" cfsqltype="CF_SQL_bit">,
                    DD_Change_Classification_Before_RFA = <cfqueryparam value="#arguments.settings.getDDChangeClassificationBeforeRFA()#" cfsqltype="CF_SQL_bit">,
                    DD_Allow_Write_Off = <cfqueryparam value="#arguments.settings.getDDAllowWriteOff()#" cfsqltype="CF_SQL_bit">,
                    DD_Sent_Reject_In_1510 = <cfqueryparam value="#arguments.settings.getDDSentRejectIn1510()#" cfsqltype="CF_SQL_bit">,
                    DD_Close_With_Equal_BB_Amt = <cfqueryparam value="#arguments.settings.getDDCloseWithEqualBBAmt()#" cfsqltype="CF_SQL_bit">,
                    Populate_180Day_From = <cfqueryparam value="#arguments.settings.getPopulate_180Day_From()#" cfsqltype="CF_SQL_INTEGER">,
                    BidRequest_Use_Price_ByDate = <cfqueryparam value="#arguments.settings.getBidRequestUsePriceByDate()#" cfsqltype="CF_SQL_bit">,
                    BidRequest_Components_On = <cfqueryparam value="#arguments.settings.getBidRequestComponentsOn()#" cfsqltype="CF_SQL_bit">,
                    DontRevise_Untill_SAP_OKack = <cfqueryparam value="#arguments.settings.getDontReviseUntillSAPokAck()#" cfsqltype="CF_SQL_bit">,
                    HQpositionsOn  = <cfqueryparam value="#arguments.settings.getHQpositionsOn()#" cfsqltype="CF_SQL_bit">,
                    Upload_Document_Privacy_Off = <cfqueryparam value="#arguments.settings.getUploadDocumentPrivacyOff()#" cfsqltype="cf_sql_bit">, <!--- CPM 8275 --->
                    Divide_Pgm_Vol_4_Groups = <cfqueryparam value="#arguments.settings.getDivideProgramVolumeForGroups()#" cfsqltype="cf_sql_integer">,
                    Pgm_Vol_Show_Groups = <cfqueryparam value="#arguments.settings.getProgramVolumeShowGroups()#" cfsqltype="cf_sql_bit">,
                    ShowManagerDetailsOnViewProgram = <cfqueryparam value="#arguments.settings.getShowManagerDetailsOnViewProgram()#" cfsqltype="cf_sql_bit">,
                    Crucible_On = <cfqueryparam value="#arguments.settings.getCrucibleOn()#" cfsqltype="CF_SQL_INTEGER">,
                    Broker_Trade_Quest_On = <cfqueryparam value="#arguments.settings.getBrokerTradeQuestOn()#" cfsqltype="CF_SQL_INTEGER">,
                    PullbacksOn =  <cfqueryparam value="#arguments.settings.getPullbacksOn()#" cfsqltype="cf_sql_bit">,
                    Pgm_Post_Approval_Status = <cfqueryparam value="#arguments.settings.getPgmPostApprovalStatus()#" cfsqltype="CF_SQL_INTEGER">,
                    Pgm_Post_Approval_Status_Type = <cfqueryparam value="#arguments.settings.getPgmPostApprovalStatusType()#" cfsqltype="CF_SQL_INTEGER">, <!--- Dev Note: DRK 6122 --->
                    Turn_off_Confidentiality_Agreement = <cfqueryparam value="#arguments.settings.getConfidentialityAgreementStatus()#" cfsqltype="cf_sql_bit">, <!--- Dev Note: Milan 8469 --->
                    Remote_Events_Email = <cfqueryparam value="#arguments.settings.getRemoteEventsEmail()#" cfsqltype="cf_sql_varchar">, <!--- Dev Note: Milan 8482 --->
                    Operator_Distributor_On_Program_Scorecard = <cfqueryparam value="#arguments.settings.getProgramScoreCard()#" cfsqltype="cf_sql_char">, <!--- Dev Note: Milan 8516 --->
                    Number_Of_Days_For_Mini_Item_Master = <cfqueryparam value="#arguments.settings.getNumberOfDaysForMiniItemMaster()#" cfsqltype="CF_SQL_SMALLINT">,<!--- Dev Note: Milan 8471 --->
                    Display_Evaluation_Notes = <cfqueryparam value="#arguments.settings.getDisplayEvaluationNotes()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: CPM 8506 --->
                    Remove_Broker_Selection = <cfqueryparam value="#arguments.settings.getRemoveBrokerSelection()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: CPM 8536 --->
                    Display_Eligible_RSP = <cfqueryparam value="#arguments.settings.getDisplayEligibleRSP()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: CPM 7920 --->
                    App_Error_Email_Link_Alone = <cfqueryparam value="#arguments.settings.getAppErrorEmailLinkAlone()#" cfsqltype="CF_SQL_BIT">,
                    BidRequest_Display_Allowance = <cfqueryparam value="#arguments.settings.getBidRequestDisplayAllowance()#" cfsqltype="CF_SQL_BIT">,
                    modify_agree_program = <cfqueryparam value="#arguments.settings.getmodifyagreeprogram()#" cfsqltype="CF_SQL_BIT">,
                    BB_Display_Resubmit = <cfqueryparam value="#arguments.settings.getBBDisplayResubmit()#" cfsqltype="CF_SQL_BIT">,
                    BB_Allow_Reverse = <cfqueryparam value="#arguments.settings.getBBAllowReverse()#" cfsqltype="CF_SQL_BIT">,
                    Use_Item_Cust_Price = <cfqueryparam value="#arguments.settings.getUseItemCustPrice()#" cfsqltype="CF_SQL_BIT">,
                    Show_BB_Excel_Report = <cfqueryparam value="#arguments.settings.getShowBBExcelReport()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: Milan 8521 --->
                    DisplayInterfaceFlagsSet1 = <cfqueryparam value="#arguments.settings.getDisplayInterfaceFlagsSet1()#" cfsqltype="CF_SQL_BIT">,
                    Show_Manual_Billback = <cfqueryparam value="#arguments.settings.getShowManualBillback()#" cfsqltype="CF_SQL_BIT">, <!--- Dev Note: Milan 9165 --->
                    Show_Auto_Billback = <cfqueryparam value="#arguments.settings.getShowAutoBillback()#" cfsqltype="CF_SQL_BIT">,  <!--- Dev Note: Milan 9165 --->
                    Auto_BillBack_Type =  <cfqueryparam value="#arguments.settings.getAutoBillBackType()#" cfsqltype="CF_SQL_BIT">, <!--- Dev Note: Milan 9165 --->
                    PriceList_displayed_Right_Click = <cfqueryparam value="#arguments.settings.getPriceListdisplayedRightClick()#" cfsqltype="CF_SQL_INTEGER">, <!--- Dev Note: Kal 9688 --->
                    View_Trade_Checkbook = <cfqueryparam value="#arguments.settings.getView_Trade_Checkbook()#" cfsqltype="CF_SQL_BIT">,
                    View_Auto_Checkbook = <cfqueryparam value="#arguments.settings.getView_Auto_Checkbook()#" cfsqltype="CF_SQL_BIT">,
                    View_Legacy_ID = <cfqueryparam value="#arguments.settings.getView_Legacy_ID()#" cfsqltype="CF_SQL_BIT">,
                    Modify_Legacy_ID = <cfqueryparam value="#arguments.settings.getModify_Legacy_ID()#" cfsqltype="CF_SQL_BIT">,
                    RevisionTypesOn = <cfqueryparam value="#arguments.settings.getRevisionTypesOn()#" cfsqltype="CF_SQL_BIT">,
                    Welcome_Letter_On = <cfqueryparam value="#arguments.settings.getWelcomeLetterOn()#" cfsqltype="CF_SQL_BIT">,
                    Template_Restrict_Group_Level = <cfqueryparam value="#arguments.settings.getTemplateRestrictGroupLevel()#" cfsqltype="CF_SQL_INTEGER">,
                    Restrict_Hierarchy_Level_On_Class_Code = <cfqueryparam value="#arguments.settings.getRestrictHierarchyLevelOnClassCode()#" cfsqltype="CF_SQL_VARCHAR">,
                    Turn_Off_Password_Requirements_Msg = <cfqueryparam value="#arguments.settings.getPasswordRequirementsStatus()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: Milan 9879 --->
                    Use_AccrualLog_For_TC = <cfqueryparam value="#arguments.settings.getUse_AccrualLog_For_TC()#" cfsqltype="CF_SQL_BIT">,<!---Dev Note: BJF 7963 & 10139 --->
                    Allow_One_Component_for_Pullbacks = <cfqueryparam value="#arguments.settings.getAllowOneComponentforPullbacks()#" cfsqltype="CF_SQL_BIT">,<!---Dev Note: Milan 9956 --->
                    Program_Special_Revision_Flag = <cfqueryparam value="#arguments.settings.getProgramSpecialRevisionFlag()#" cfsqltype="CF_SQL_BIT">,
                    Multi_Distributor_BB = <cfqueryparam value="#arguments.settings.getMultiDistributorBB()#" cfsqltype="CF_SQL_BIT">,<!---  Dev Note:  MarkS 10055 --->
                    Group_Level_Billback = <cfqueryparam value="#arguments.settings.getGroupLevelBillback()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: KAL; 10343 --->
                    Allow_Unknown_Payee_In_Billback = <cfqueryparam value="#arguments.settings.getAllowUnKnownPayeeInBillback()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: Milan; 10380 --->
                    Hide_Invalid_Component_Types_In_Billbacks = <cfqueryparam value="#arguments.settings.getHideInvalidComponentTypesInBillbacks()#" cfsqltype="CF_SQL_BIT">,
                    Billback_Scorecard_Cache = <cfqueryparam value="#arguments.settings.getBillbackScorecardCache()#" cfsqltype="CF_SQL_BIT">,
                    <!--- Dev Note: Milan; 10433 --->
                    Program_Scorecard_Cache = <cfqueryparam value="#arguments.settings.getProgramScorecardCache()#" cfsqltype="CF_SQL_BIT">,
                    Use_Different_From_Address = <cfqueryparam value="#arguments.settings.getUse_Different_From_Address()#" cfsqltype="CF_SQL_BIT">,
                    Different_From_Address = <cfqueryparam value="#arguments.settings.getDifferent_From_Address()#" cfsqltype="CF_SQL_VARCHAR">,
                    Use_Big_Billbacks = <cfqueryparam value="#arguments.settings.getUse_Big_Billbacks()#" cfsqltype="CF_SQL_BIT">,
                    One_Page_Claim_Form =  <cfqueryparam value="#arguments.settings.getOnePageClaimForm()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: BDensmore 10788 --->
                    Billback_Closing_Method = <cfqueryparam value="#arguments.settings.getBillbackClosingMethod()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: Milan; 10605 --->
                    Lost_Bids_Deviated = <cfqueryparam value="#arguments.settings.getLost_Bids_Deviated()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: BJF D10608 --->
                    showfixedprice_additionalfields =  <cfqueryparam value="#arguments.settings.getshowfixedpriceadditionalfields()#" cfsqltype="CF_SQL_BIT">,
                    Freight_Calculator_On = <cfqueryparam value="#arguments.settings.getFreight_Calculator_On()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: CPM 10941 --->
                    Login_Page_Logo_Path = <cfqueryparam value="#arguments.settings.getLoginPageLogoPath()#" cfsqltype="CF_SQL_VARCHAR">,
                    app_EZButton_On =  <cfqueryparam value="#arguments.settings.getappEZButtonOn()#" cfsqltype="CF_SQL_BIT">,
                    suppress_groups_zero_items =  <cfqueryparam value="#arguments.settings.getSuppressGroupsZeroItems()#" cfsqltype="CF_SQL_BIT">,
                    suppress_business_considerations = <cfqueryparam value="#arguments.settings.getSuppressBusinessConsiderations()#" cfsqltype="CF_SQL_BIT">,
                    Add_Todo_On_Doc_Attach = <cfqueryparam value="#arguments.settings.getAddTodoOnDocAttach()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: CPM 11135 --->
                    include_users_email_auto = <cfqueryparam value="#arguments.settings.getIncludeUsersEmailAuto()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: CPM 11135 --->
                    Program_Approval_For_Inactive_Operators = <cfqueryparam value="#arguments.settings.getProgramApprovalForInactiveOperators()#" cfsqltype="CF_SQL_BIT">,
                    Release_Settlement = <cfqueryparam value="#arguments.settings.getReleaseSettlement()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: CPM 11286 --->
                    Disable_Auto_login = <cfqueryparam value="#arguments.settings.getDisableAutoLogin()#" cfsqltype="CF_SQL_BIT">,<!---  Dev Note:  MarkS 11287 --->
                    Data_Int_Viewer = <cfqueryparam value="#arguments.settings.getDataIntViewer()#" cfsqltype="CF_SQL_BIT">,<!---  Dev Note:  MarkS 10729 --->
                    BB_Deviation_Use_Max_Price = <cfqueryparam value="#arguments.settings.getBBDeviationUseMaxPrice()#" cfsqltype="CF_SQL_INTEGER">,<!---  Dev Note:  MarkS 11127 --->
                    same_lump_sum_component_in_program = <cfqueryparam value="#arguments.settings.getLumpSumComponentInProgram()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: BSD D11414 --->
                    <!---Send_Release_Settlement_Emailaddress = <cfqueryparam value="#arguments.settings.getSend_Release_Settlement_Emailaddress()#" cfsqltype="CF_sql_varchar">, ---><!--- Dev Note: CPM 11286 --->
                    Allow_Percent_Operator_Programs = <cfqueryparam value="#arguments.settings.getAllow_Percent_Operator_Programs()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: BSD D11414 --->
                    Billback_Modify_Agree = <cfqueryparam value="#arguments.settings.getBillbackModifyAgree()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: KAL; D11049 --->
                    OnlyAccrualTPA_Pullbacks = <cfqueryparam value="#arguments.settings.getOnlyAccrualTPAPullbacks()#" cfsqltype="CF_SQL_BIT">,
                    UOM_EA_Available = <cfqueryparam value="#arguments.settings.getUOMEAAvailable()#" cfsqltype="CF_SQL_BIT">,
                    Position_Tree_Display_Distributor = <cfqueryparam value="#arguments.settings.getPosition_Tree_Display_Distributor()#" cfsqltype="CF_SQL_BIT">
                      <!--- Do not add any more records to this update. Add them to saveSettingType3 below --->
            </cfquery>
        <cfset Track_Changes()>
    </cffunction>

    <!--- To avoid an error, add any new entries in this function, rather than the function above --->
    <cffunction name="saveSettingType3" output="true" returntype="void">
        <cfargument name="settings" required="true">
        <cfset var qUpdateSettings="" />
        <cfset var var_isNull = "no" />
        <!------ update ----->
        <cfif (arguments.settings.getDocumentPurgeAge() EQ "")>
          <cfset var_isNull = "yes" />
        </cfif>


        <cfquery name="qUpdateSettings" datasource="#application.datasource#">
            UPDATE	_Application_Settings
            SET
          <!---26199 - 2011/feb/23 moved these 20 assignments below from saveSettingType2() to here
          to fix the "Branch target offset too large for short" error--->
                    <!---BB_UPLOAD_UPDATED = <cfqueryparam value="#arguments.settings.getBB_UPLOAD_UPDATED()#" cfsqltype="CF_SQL_BIT">,---><!---removed with label 18746 --->
                    BB_Auto_report = <cfqueryparam value="#arguments.settings.getBBAutoReport()#" cfsqltype="CF_SQL_BIT">,
                    split_billback = <cfqueryparam value="#arguments.settings.getSplitBillbacks()#" cfsqltype="CF_SQL_BIT">,
                    Show_Export_Programs = <cfqueryparam value="#arguments.settings.getShowExportPrograms()#" cfsqltype="CF_SQL_BIT">,
                    Interface_BuyingGroup_As_Group_To_Client = <cfqueryparam value="#arguments.settings.getInterface_BuyingGroup_As_Group_To_Client()#" cfsqltype="CF_SQL_BIT">,
                    BB_Expected_Rate_GT_Claim_Rate = <cfqueryparam value="#arguments.settings.getBBExpectedRateGTClaimRate()#" cfsqltype="CF_SQL_BIT">, <!---  Dev Note:  MarkS 12498 --->
                    BB_Auto_Report_Start_Date = <cfqueryparam value="#arguments.settings.getBBAutoReportStartDate()#" cfsqltype="cf_sql_timestamp" />, <!---  Dev Note:  MarkS 12575 --->
                    Budgets_Functionality_On = <cfqueryparam value="#arguments.settings.getBudgetsFunctionalityOn()#" cfsqltype="CF_SQL_BIT">,
                    Budget_Selection_Required = <cfqueryparam value="#arguments.settings.getBudgetSelectionRequired()#" cfsqltype="CF_SQL_BIT">,
                    Budget_Single_Level_For_Fixed = <cfqueryparam value="#arguments.settings.getBudgetSingleLevelForFixed()#" cfsqltype="CF_SQL_BIT">,
                    Distributor_Product_Integrity_On = <cfqueryparam value="#arguments.settings.getDistributor_Product_Integrity_On()#" cfsqltype="CF_SQL_BIT">,
                    Show_Claim_Adjustment = <cfqueryparam value="#arguments.settings.getShowClaimAdjustment()#" cfsqltype="CF_SQL_BIT">,
                    ItemMarginTarget_OR_GrossMargin_For_PriceList = <cfqueryparam value="#arguments.settings.getItemMarginTargetORGrossMarginForPriceList()#" cfsqltype="CF_SQL_CHAR">,
                    Show_Fixed_Freight = <cfqueryparam value="#arguments.settings.getShow_Fixed_Freight()#" cfsqltype="CF_SQL_BIT">,
                    Show_Component_Accrual = <cfqueryparam value="#arguments.settings.getShow_Component_Accrual()#" cfsqltype="CF_SQL_BIT">,
                    Show_Component_Floor_Pricing = <cfqueryparam value="#arguments.settings.getShow_Component_Floor_Pricing()#" cfsqltype="CF_SQL_BIT">,
                    GL_Account_On = <cfqueryparam value="#arguments.settings.getGL_Account_On()#" cfsqltype="CF_SQL_BIT">,
                    GL_Account_Required_for_Comp = <cfqueryparam value="#arguments.settings.getGL_Account_Required_for_Comp()#" cfsqltype="CF_SQL_BIT">,
                    BB_Reference_Uppercase = <cfqueryparam value="#arguments.settings.getBB_Reference_Uppercase()#" cfsqltype="CF_SQL_BIT">,
                    Exact_List_Matching_On = <cfqueryparam value="#arguments.settings.getExact_List_Matching_On()#" cfsqltype="CF_SQL_BIT">,
                    Suppress_Billback_Business_Considerations = <cfqueryparam value="#arguments.settings.getSuppressBillbackBusinessConsiderations()#" cfsqltype="CF_SQL_BIT">,
          <!---end of 26199--->

                    DD_Allow_Non_Trade = <cfqueryparam value="#arguments.settings.getDD_Allow_Non_Trade()#" cfsqltype="CF_SQL_bit">,<!--- D29481:Non trade deductions --->
                Brokerage_Functionality_On = <cfqueryparam value="#arguments.settings.getBrokerage_Functionality_On()#" cfsqltype="cf_sql_bit">,
                    Auto_BB_Create_Status_ID = <cfqueryparam value="#arguments.settings.getAuto_BB_Create_Status_ID()#" cfsqltype="cf_sql_integer">,
                    Brokerage_Margin_Calculation = <cfqueryparam value="#arguments.settings.getBrokerage_Margin_Calculation()#" cfsqltype="cf_sql_bit">,
                    Display_Distributor_OffInvoice = <cfqueryparam value="#arguments.settings.getDisplayDistributorOffInvoice()#" cfsqltype="CF_SQL_BIT">,<!---  Dev Note:  Milan 14314 --->
                    Display_Proposal = <cfqueryparam value="#arguments.settings.getDisplayProposal()#" cfsqltype="CF_SQL_BIT">,<!---  Dev Note:  Milan 14314 --->
                    Display_USDANOI = <cfqueryparam value="#arguments.settings.getDisplayUSDANOI()#" cfsqltype="CF_SQL_BIT">,<!---  Dev Note:  Milan 14314 --->
                    Disable_Adding_Components_On_Revision = <cfqueryparam value="#arguments.settings.getDisableAddingComponentsOnRevision()#" cfsqltype="CF_SQL_BIT">,
                    View_Delete_Records = <cfqueryparam value="#arguments.settings.getViewDeleteRecords()#" cfsqltype="CF_SQL_BIT">,
                    DD_Negative_Splits = <cfqueryparam value="#arguments.settings.getDD_Negative_Splits()#" cfsqltype="CF_SQL_BIT">,
                    Program_Lock_Type_ID = <cfqueryparam value="#arguments.settings.getProgramLockTypeID()#" cfsqltype="CF_SQL_INTEGER">,
                    Label_Sets = <cfqueryparam value="#arguments.settings.getLabelSets()#" cfsqltype="CF_SQL_BIT">,
                    Program_Claim_Rates_Report_Available = <cfqueryparam value="#arguments.settings.getProgramClaimRatesReportAvailable()#" cfsqltype="CF_SQL_BIT">,
                    Program_Claim_Rates_Report_Exclude_Regular_Prices = <cfqueryparam value="#arguments.settings.getProgramClaimRatesReportExcludeRegularPrices()#" cfsqltype="CF_SQL_BIT">,
                    Show_Reason_Code_On_BB_Approval_Screen = <cfqueryparam value="#arguments.settings.getShowReasonCodeOnBBApprovalScreen()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: Milan; 15415 --->
                    BB_Auto_Report_isManually_Configured = <cfqueryparam value="#arguments.settings.getBBAutoReportisManuallyConfigured()#" cfsqltype="CF_SQL_BIT">,
                    BB_Auto_Report_Allow_Manual = <cfqueryparam value="#arguments.settings.getBBAutoReportAllowManual()#" cfsqltype="CF_SQL_BIT">,
                    BB_Auto_Report_Allow_Reverse = <cfqueryparam value="#arguments.settings.getBBAutoReportAllowReverse()#" cfsqltype="CF_SQL_BIT">,
                    Pgm_Margin_Rebate_Use_Auto_Pay_Price = <cfqueryparam value="#arguments.settings.getPgmMarginRebateUseAutoPayPrice()#" cfsqltype="CF_SQL_BIT">,
                    Hide_Billback_Adjustments = <cfqueryparam value="#arguments.settings.getHide_Billback_Adjustments()#" cfsqltype="CF_SQL_BIT">,
                    SSL_On_All_Pages = <cfqueryparam value="#arguments.settings.getSSL_On_All_Pages()#" cfsqltype="CF_SQL_BIT">,
                    Audit_Trail_Storage = <cfqueryparam value="#arguments.settings.getAuditTrailStorage()#" cfsqltype="CF_SQL_TINYINT">,<!--- Dev Note: DAA; 15331 --->
                    Allow_Bid_Status_Edit_Anytime = <cfqueryparam value="#arguments.settings.getAllowBidStatusEditAnytime()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: DAA; 16859 --->
                    Reason_Code_in_Billback_DED = <cfqueryparam value="#arguments.settings.getReasonCodeinBillbackDED()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: DAA; 16974 --->
                    Show_Pricing_Report = <cfqueryparam value="#arguments.settings.getShowPricingReport()#" cfsqltype="CF_SQL_BIT">,
                    Days_Of_Historical_Data_For_SpecialPriceList = <cfqueryparam value="#arguments.settings.getDaysOfHistoricalDataForSpecialPriceList()#" cfsqltype="CF_SQL_SMALLINT">,
                    BB_Allow_Reset_After_DED_Interface = <cfqueryparam value="#arguments.settings.getBBAllowResetAfterDEDInterface()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: DRK D16732 --->
                    BB_Allow_Reset_Before_PMT_Interface_PR_Status = <cfqueryparam value="#arguments.settings.getBBAllowResetBeforePMTInterfacePRStatus()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: DRK D16732 --->
                    Product_Replacement_Enabled = <cfqueryparam value="#arguments.settings.getProductReplacementEnabled()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: DRK D13872 --->
                    Billback_Allow_Multiple_Budgets = <cfqueryparam value="#arguments.settings.getBillbackAllowMultipleBudgets()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: DRK D16645 --->
                    Project_Scorecard_Cache = <cfqueryparam value="#arguments.settings.getProjectScorecardCache()#" cfsqltype="CF_SQL_BIT">,	<!--- D17674 RBL 12/08/08 --->
                    Allow_Billback_To_Credit_Matching = <cfqueryparam value="#arguments.settings.getAllowBillbackToCreditMatching()#" cfsqltype="CF_SQL_BIT">,
                    Max_Future_Days_For_Claim_Rates_OR_Pricing_Extract = <cfqueryparam value="#arguments.settings.getMaxFutureDaysForClaimRatesORPricingExtract()#" cfsqltype="CF_SQL_SMALLINT">,<!--- Dev Note: Milan D17838 --->
                    Is_Vantage_On = <cfqueryparam value="#arguments.settings.getIsVantageOn()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: Milan 17867 --->
                    Vantage_DataSource = <cfqueryparam value="#arguments.settings.getVantageDataSource()#" cfsqltype="CF_SQL_VARCHAR">,<!--- Dev Note: Milan 17867 --->
                    Search_Selection_Tracking_On = <cfqueryparam value="#arguments.settings.getSearch_Selection_Tracking_On()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: BJF 18081 --->
                    Expired_Recently_Days = <cfqueryparam value="#arguments.settings.getExpiredRecentlyDays()#" cfsqltype="cf_sql_integer">,<!--- Dev Note: DRK 18668 --->
                    Pre_Active_Replace_Parent = <cfqueryparam value="#arguments.settings.getPreActiveReplaceParent()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: TSF 18682 --->
                    View_Program_Volume_UOM = <cfqueryparam value="#arguments.settings.getViewProgramVolumeUOM()#" cfsqltype="cf_sql_integer">,<!--- Dev Note: 18882--->
                    View_Program_Estimated_Amount = <cfqueryparam value="#arguments.settings.getViewProgramEstimatedAmount()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: 18882 --->
                    BB_Auto_Pay_Customer_Group_In_Invoice = <cfqueryparam value="#arguments.settings.getBBAutoPayCustomerGroupInInvoice()#" cfsqltype="cf_sql_bit">,
                    BB_Auto_Pay_Disable_Pay_Each = <cfqueryparam value="#arguments.settings.getBBAutoPayDisablePayEach()#" cfsqltype="cf_sql_bit">,
                    BB_Auto_Pay_Lump_Sum = <cfqueryparam value="#arguments.settings.getBBAutoPayLumpSum()#" cfsqltype="cf_sql_bit">,
                    BB_Auto_Pay_Allow_Negative_Paid_Amount = <cfqueryparam value="#arguments.settings.getBBAutoPayAllowNegativePaidAmount()#" cfsqltype="cf_sql_bit">,<!--- Dev Note: MWS 19057--->
                    Filter_Business_Segments = <cfqueryparam value="#arguments.settings.getFilterBusinessSegments()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: TSF 18940 --->
                    BB_Allow_Vendor_Cross_Ref_Search = <cfqueryparam value="#arguments.settings.getBBAllowVendorCrossRefSearch()#" cfsqltype="CF_SQL_bit">,
                    Program_Alerts = <cfqueryparam value="#arguments.settings.getProgramAlerts()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: TSF 18950 --->
                    Reset_Won_Lost_On_Revision = <cfqueryparam value="#arguments.settings.getReset_Won_Lost_On_Revision()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: TSF 18950 --->
                    Approval_Via_Email = <cfqueryparam value="#arguments.settings.getApprovalViaEmail()#" cfsqltype="CF_SQL_BIT" />, <!--- Dev Note: KAL; D19440: Approval via Email --->
                    DD_Restrict_ShipTo_For_BB = <cfqueryparam value="#arguments.settings.getDD_Restrict_ShipTo_For_BB()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: BJF 19297 --->
                    Primary_Product_Attribute = <cfqueryparam value="#arguments.settings.getPrimary_Product_Attribute()#" cfsqltype="CF_SQL_Integer">,<!--- Dev Note: BJF 19297 --->
                    BB_Inserts_Credit_To_Invoices = <cfqueryparam value="#arguments.settings.getBB_Inserts_Credit_To_Invoices()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: BJF 19297 --->
                    BB_Status_To_Insert_Credit = <cfqueryparam value="#arguments.settings.getBB_Status_To_Insert_Credit()#" cfsqltype="CF_sql_integer">,<!--- Dev Note: BJF 19297 --->
                    Show_BB_Summary_Statement = <cfqueryparam value="#arguments.settings.getShow_BB_Summary_Statement()#" cfsqltype="CF_sql_integer">,<!--- Dev Note: BJF 20743  --->
                    Operator_Creation_Fields_Required = <cfqueryparam value="#arguments.settings.getOperator_Creation_Fields_Required()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: Milan 19451 --->
                    Third_Party_BB_Upload = <cfqueryparam value="#arguments.settings.getThirdPartyBBUpload()#" cfsqltype="CF_SQL_Integer">,<!--- Dev Note: Milan 20399 --->
                    BB_Show_Modify_Program = <cfqueryparam value="#arguments.settings.getBBShowModifyProgram()#" cfsqltype="CF_SQL_Integer">,<!--- Dev Note: TSF 20454 --->
                    BB_Deviations_Override_Price = <cfqueryparam value="#arguments.settings.getBB_Deviations_Override_Price()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: Anand Rao 19441 --->
                    BB_Upload_III_P_Qty_Amt_Editable = <cfqueryparam value="#arguments.settings.getBB_Upload_III_P_Qty_Amt_Editable()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: Anand Rao 19441 --->
                    Flex_BB_Deviation = <cfqueryparam value="#arguments.settings.getFlex_BB_Deviation()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: Anand Rao 19441 --->
                    BB_Fractional_Volume = <cfqueryparam value="#arguments.settings.getBB_Fractional_Volume()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: Ana 24087 --->

                    <!--- Display_Hold_Release_Checkbox = <cfqueryparam value="#arguments.settings.getDisplay_Hold_Release_Checkbox()#" cfsqltype="CF_SQL_BIT">,---><!--- Dev Note: Milan 20724 --->
                    Display_Vendor_ID_Null_Form = <cfqueryparam value="#arguments.settings.getDisplay_Vendor_ID_Null_Form()#" cfsqltype="CF_SQL_BIT">,<!--- Dev Note: Anand Rao 21185 --->

                    <!--- Dev Note: KAL; D20523: App setting to turn flex search tools on/off --->
                    Flex_Program_Search = <cfqueryparam value="#arguments.settings.getFlexProgramSearch()#" cfsqltype="CF_SQL_TINYINT">, <!---D29074 changed bit to tinyint --->
                    Flex_Distributor_Search = <cfqueryparam value="#arguments.settings.getFlexDistributorSearch()#" cfsqltype="cf_sql_bit">,
                    Flex_Broker_Search = <cfqueryparam value="#arguments.settings.getFlexBrokerSearch()#" cfsqltype="cf_sql_bit">,
                    Flex_Operator_Search = <cfqueryparam value="#arguments.settings.getFlexOperatorSearch()#" cfsqltype="cf_sql_bit">,
                    Flex_Product_Search = <cfqueryparam value="#arguments.settings.getFlexProductSearch()#" cfsqltype="cf_sql_bit">,
                    Program_Search_Dollars_And_Volume = <cfqueryparam value="#arguments.settings.getProgramSearchDollarsAndVolume()#" cfsqltype="CF_SQL_BIT">,
                    Display_Cash_Discount_Margin = <cfqueryparam value="#arguments.settings.getDisplayCashDiscountMargin()#" cfsqltype="cf_sql_bit">, <!--- Dev Note: KAL 20537  --->
                    BB_Auto_Pay_To_Operator_Use_Invoice_Opr_ID = <cfqueryparam value="#arguments.settings.getBBAutoPayToOperatorUseInvoiceOprID()#" cfsqltype="cf_sql_bit">,
                    BB_Product_Allow_Zero_Volume = <cfqueryparam value="#arguments.settings.getBBProductAllowZeroVolume()#" cfsqltype="cf_sql_bit">,
                    <!--- Dev Notes: 21923/Anand Rao/22-Jan-2010 Settings for BB Deviation Grid --->
                    Update_BB_Approve_Amt = <cfqueryparam value="#arguments.settings.getUpdate_BB_Approve_Amt()#" cfsqltype="cf_sql_bit">,
                    BB_Approve_Expected_Rate_Less_Tolerance = <cfqueryparam value="#arguments.settings.getBB_Approve_Expected_Rate_Less_Tolerance()#" cfsqltype="cf_sql_bit">,
                    <!--- Dev Notes: 19384/Anand Rao/05-Apr-10 Rebill Interface and changes --->
                    Integrated_Rebill = <cfqueryparam value="#arguments.settings.getIntegrated_Rebill()#" cfsqltype="cf_sql_bit">,
                    <!--- Dev Notes: 21554/Anand Rao/30-Apr-10 HZ - Single sign on to application using LDAP --->
                    LDAP_SSO_Enabled =  <cfqueryparam value="#arguments.settings.getLDAP_SSO_Enabled()#" cfsqltype="cf_sql_bit">,
                    Allow_Revise_Active_With_Pre_Active = <cfqueryparam value="#arguments.settings.getAllowReviseActiveWithPreActive()#" cfsqltype="cf_sql_bit">,
                    Credit_Type_Is_DD_Reason_Code = <cfqueryparam value="#arguments.settings.getCreditTypeIsDDReasonCode()#" cfsqltype="cf_sql_bit">,
                    <!--- Dev Notes: D23639/Anand Rao/14-Jun-10	BB reason codes --->
                    Reason_Code_in_Billback_Display_Setting = <cfqueryparam value="#arguments.settings.getReasonCodeInBillbackDisplaySetting()#" cfsqltype="cf_sql_tinyint">,
                      Document_Purge_Age = <cfqueryparam value="#arguments.settings.getDocumentPurgeAge()#" cfsqltype="CF_SQL_INTEGER" null="#var_isNull#"  >, 	<!--- Dev Notes: D23692/Anand Rao/28-Jun-10 --->
                    FTP_Document_Path = <cfqueryparam value="#arguments.settings.getFTPDocumentPath()#" cfsqltype="cf_sql_varchar" >, 	<!--- Dev Notes: D23692/KAL/22-Jul-2010 --->
                    Search_Inactive_Products_Programs = <cfqueryparam value="#arguments.settings.getSearchInactiveProductsInPrograms()#" cfsqltype="cf_sql_bit">,
                    Search_Inactive_Distributors_Programs = <cfqueryparam value="#arguments.settings.getSearchInactiveDistributorsInPrograms()#" cfsqltype="cf_sql_bit">,
                    Search_Inactive_Operators_Programs = <cfqueryparam value="#arguments.settings.getSearchInactiveOperatorsInPrograms()#" cfsqltype="cf_sql_bit">,   <!---26199--->
                    retain_original_RSP_copy = <cfqueryparam value="#arguments.settings.getretainoriginalRSPcopy()#" cfsqltype="CF_SQL_bit">,
                    Billback_Module = <cfqueryparam value="#arguments.settings.getBillback_Module()#" cfsqltype="CF_SQL_bit">,
                    Deduction_Module = <cfqueryparam value="#arguments.settings.getDeduction_Module()#" cfsqltype="CF_SQL_bit">,
                    BB_Reason_Code_Allow_Multiple = <cfqueryparam value="#arguments.settings.getBBReasonCodeAllowMultiple()#" cfsqltype="CF_SQL_bit">,
                    Margin_Items_Exclude = <cfqueryparam value="#arguments.settings.getMarginItemsExclude()#" cfsqltype="cf_sql_bit">,
                    Planning_Groups = <cfqueryparam value="#arguments.settings.getPlanningGroups()#" cfsqltype="cf_sql_bit">,
                    BC_On_RFA_af_Reset = <cfqueryparam value="#arguments.settings.getBC_On_RFA_af_Reset()#" cfsqltype="cf_sql_bit">,
                    Require_Business_Considerations_On_New_Programs = <cfqueryparam value="#arguments.settings.getRequire_Business_Considerations_On_New_Programs()#" cfsqltype="cf_sql_bit">,
                    DD_User_Reference = <cfqueryparam value="#arguments.settings.getDD_User_Reference()#" cfsqltype="cf_sql_bit">,
                    BB_Created_Recently_Days = <cfqueryparam value="#arguments.settings.getBBCreatedRecentlyDays()#" cfsqltype="cf_sql_integer">,
                    Display_notes_field_on_program = <cfqueryparam value="#arguments.settings.getDisplayNotesFieldOnProgram()#" cfsqltype="CF_SQL_bit">,
                    User_Account_Middle_Initial = <cfqueryparam value="#arguments.settings.getUserAccountMiddleInitial()#" cfsqltype="CF_SQL_bit">,
                    showrebate_additionalfields =  <cfqueryparam value="#arguments.settings.getshowrebateadditionalfields()#" cfsqltype="CF_SQL_BIT">,
                    Use_Fixed_Price_Type = <cfqueryparam value="#arguments.settings.getUseFixedPriceType()#" cfsqltype="CF_SQL_bit">,
                    Display_Quote_Letter = <cfqueryparam value="#arguments.settings.getDisplayQuoteLetter()#" cfsqltype="CF_SQL_bit">,
                    Price_List_By_Template = <cfqueryparam value="#arguments.settings.getPriceListByTemplate()#" cfsqltype="CF_SQL_bit">,
                    Billback_Statement_Type = <cfqueryparam value="#arguments.settings.getBillBack_Statement_Type()#" cfsqltype="CF_SQL_VARCHAR">,
                    Shortcut_No_Routing_Allowed = <cfqueryparam value="#arguments.settings.getShortcutNoRoutingAllowed()#" cfsqltype="CF_SQL_VARCHAR">,
                    Position_Fields_Filtered_Based_On_Program_Segment = <cfqueryparam value="#arguments.settings.getPositionFieldsFilterOnProgramSegment()#" cfsqltype="CF_SQL_BIT">,<!--- D28618 Drachala: Position Drop Down Fields filtered based on Program Business Segment  --->
                    Display_Only_Billback_Parent = <cfqueryparam value="#arguments.settings.getDisplayOnlyBillbackParent()#" cfsqltype="CF_SQL_BIT">,
                    Erp_Deduction_Doc_Path = <cfqueryparam value="#arguments.settings.getErpDeductionDocPath()#" cfsqltype="CF_SQL_VARCHAR">,<!--- D29482: mws Path to a server in client ERP to get .pdf files related to deductions--->
                    Documents_Display_Upload_Form = <cfqueryparam value="#arguments.settings.getDocumentsDisplayUploadForm()#" cfsqltype="CF_SQL_bit">,
                    External_Contacts_Option = <cfqueryparam value="#arguments.settings.getExternal_Contacts()#">,
                    Edit_Product_Master_Data = <cfqueryparam value="#arguments.settings.getEdit_Product_Master_Data()#" cfsqltype="CF_SQL_bit">,
                    Update_Program_Won_Lost_Based_On_Billback_Approval = <cfqueryparam value="#arguments.settings.getPrgWonLostOnBBApproval()#" cfsqltype="CF_SQL_TINYINT">,
                    DD_Closed_BB_Status = <cfqueryparam value="#arguments.settings.getDDClosedBBStatus()#" cfsqltype="CF_SQL_bit">,
                    BB_Reset_Unacknowledged_Interface = <cfqueryparam value="#arguments.settings.getBBResetUnacknowledgedInterface()#" cfsqltype="CF_SQL_bit">,
                    BB_Reinterface_Unacknowledged_Interface = <cfqueryparam value="#arguments.settings.getBBReinterfaceUnacknowledgedInterface()#" cfsqltype="CF_SQL_bit">,

                    <!----- leave this blank space above ----->
                    Internal_Settings_Updated_By = <cfqueryparam value="#arguments.settings.getUpdatedBy()#" cfsqltype="CF_SQL_VARCHAR">,
                    Internal_Settings_Updated_On = GetDate(),
                    Invc_Cost_From_Invc_File = <cfqueryparam value="#arguments.settings.getInvoiceCostForVantage()#" cfsqltype="cf_sql_bit">,	<!--- D30750:Create app setting to use invoice cost from invoice file --->
                    Multiple_BillTos_For_ShipTo = <cfqueryparam value="#arguments.settings.getMultipleBillTosForShipTo()#" cfsqltype="cf_sql_bit">,	<!--- D30486: Multiple AR numbers to 1 Account(Customer)-UI --->
                    Billback_Quick_pay = <cfqueryparam value="#arguments.settings.getBillbackQuickPay()#" cfsqltype="CF_SQL_INTEGER" />, <!--- D25219: SOW - Enable mass paying of payables --->
                    Billback_Display_All_Program_Components = <cfqueryparam value="#arguments.settings.getBillbackDisplayAllProgramComponents()#" cfsqltype="cf_sql_bit">,
                     <!--- 31378:Add Program w/o Payee Components don't display --->
                    Billback_Module_Type = <cfqueryparam value="#arguments.settings.getBillbackModuleType()#" cfsqltype="CF_SQL_TINYINT">, <!--- 31505: App setting for Flex BB Module --->
                    Favicon_Path = <cfqueryparam value="#arguments.settings.getFaviconPath()#" cfsqltype="CF_SQL_VARCHAR">, <!--- 31505: App setting for Flex BB Module --->
                    BB_LS_Claimed_Rebate_Expected = <cfqueryparam value="#arguments.settings.getBB_LS_Claimed_Rebate_Expected()#" cfsqltype="cf_sql_bit"> <!--- 31769: Billback Deviation Grid --->
                    ,CRA_Consider_Analyst = <cfqueryparam value="#arguments.settings.getCRAConsiderAnalyst()#" cfsqltype="cf_sql_bit"><!---  D32585 Approval e-mails sending to all TL's --->
                    ,Billback_Display_Base_Sales_in_Rate_Dev = <cfqueryparam value="#arguments.settings.getBillback_Display_Base_Sales_in_Rate_Dev()#" cfsqltype="cf_sql_bit"> <!--- D33041: Add 'base sales price' to the billback rate pop up window (CF) --->
                    ,Billback_Upload_Business_Segment= <cfqueryparam value="#arguments.settings.getBillback_Upload_Business_Segment()#" cfsqltype="cf_sql_bit"><!--- D29947 Update billback upload for SO/DC --->
                    ,Billback_File_Upload_Type = <cfqueryparam value="#arguments.settings.getBillbackFileUploadType()#" cfsqltype="CF_SQL_TINYINT"><!--- D33957  Modify standard billback upload to one file --->
                    ,BB_Count_Indicator= <cfqueryparam value="#arguments.settings.getBB_Count_Indicator()#" cfsqltype="cf_sql_varchar">  <!--- 34665 --->
                    ,Template_Multiple_Product_Attr_Groups = <cfqueryparam value="#arguments.settings.getTemplateMultipleProductAttrGroups()#" cfsqltype="cf_sql_bit">  <!--- //D35295 --->
                    ,Profitability_Model=<cfqueryparam value="#arguments.settings.getProfitabilityModel()#" cfsqltype="cf_sql_bit">
                    ,Mass_Copy=<cfqueryparam value="#arguments.settings.getMassCopy()#" cfsqltype="cf_sql_bit">
                    ,Custom_Auto_Approve_Type = <cfqueryparam value="#arguments.settings.getBBAutoApproveLogic()#" cfsqltype="CF_SQL_INTEGER">
                    ,View_Operator_in_Billback_Deviation=<cfqueryparam value="#arguments.settings.getViewOperatorinBillbackDeviation()#" cfsqltype="cf_sql_bit">
                    ,BB_Overlap_Deviation_Based_On_Operator=<cfqueryparam value="#arguments.settings.getBBOverlapDeviationBasedOnOperator()#" cfsqltype="cf_sql_bit">
                    ,BB_Default_Program_Retry_Process=<cfqueryparam value="#arguments.settings.getBBDefaultProgramRetryProcess()#" cfsqltype="cf_sql_bit">
                    ,BB_Default_Program_Retry_Also_Call_Deviation=<cfqueryparam value="#arguments.settings.getBBDefaultProgramRetryAlsoCallDeviation()#" cfsqltype="cf_sql_bit">
                    ,Program_Allow_Negative_Rebate_Rates = <cfqueryparam value="#arguments.settings.getProgram_Allow_Negative_Rebate_Rates()#" cfsqltype="CF_SQL_BIT">
                    ,Allowable_Overlap_Period = <cfqueryparam value="#arguments.settings.getAllowableOverlapPeriod()#" cfsqltype="CF_SQL_TINYINT">
                    ,BB_Inserts_Credit_To_Invoices_GT =  <cfqueryparam value="#arguments.settings.getBB_Inserts_Credit_To_Invoices_GT()#" cfsqltype="cf_sql_varchar">
                     ,Program_search_dates = <cfqueryparam value="#arguments.settings.getProgram_search_dates()#" cfsqltype="CF_SQL_BIT"><!--- D38043  :: Program revision dates - View Program --->
                    ,UNIPRO_450 = <cfqueryparam value="#arguments.settings.getUNIPRO_450()#" cfsqltype="CF_SQL_BIT">
                    ,Deviation_Grid_Allow_Manual_Values_GT_Claimed = <cfqueryparam value="#arguments.settings.getDeviationGridAllowManualValuesGTClaimed()#" cfsqltype="CF_SQL_BIT">
                    ,BB_Payee_Broker_Ship_To_Req = <cfqueryparam value="#arguments.settings.getBBPayeeBrokerShipToReq()#" cfsqltype="CF_SQL_BIT">
                    ,Editable_Claimed_Dollars_Quantity = <cfqueryparam value="#arguments.settings.getEditableClaimedDollarsQuantity()#" cfsqltype="CF_SQL_BIT">
                    ,DD_Reopen_Parent = <cfqueryparam value="#arguments.settings.getDDReopenParent()#" cfsqltype="CF_SQL_BIT">
                    ,Operator_Q_Brand_Legacy = <cfqueryparam value="#arguments.settings.getOperatorQBrandLegacy()#" cfsqltype="CF_SQL_BIT">
                    ,Cancel_Pgm_No_BB_Months = <cfqueryparam value="#arguments.settings.getCancelPgmNoBBMonths()#" cfsqltype="CF_SQL_TINYINT">---D35165
                    ,Show_Brand_On_View_Program = <cfqueryparam value="#arguments.settings.getShowBrandOnViewProgram()#" cfsqltype="CF_SQL_TINYINT">
                    ,Enable_Group_Membership_Dates = <cfqueryparam value="#arguments.settings.getEnableGroupMembershipDates()#" cfsqltype="CF_SQL_BIT">
                    ,DD_Reopen_Interface = <cfqueryparam value="#arguments.settings.getDD_Reopen_Interface()#" cfsqltype="CF_SQL_BIT"><!--- D42284 :: Rebill vs closed deduction reopened  --->
                    ,BB_Powerpunch = <cfqueryparam value="#arguments.settings.getBBPowerpunch()#" cfsqltype="CF_SQL_BIT"> <!--- 43155: Billback Program Change --->
                    ,Deduction_Quick_Update = <cfqueryparam value="#arguments.settings.getDeductionQuickUpdate()#" cfsqltype="CF_SQL_BIT"><!---D42846 :: Deduction tool upgrades --->
                    ,Auto_Approve_Products_On_Revision = <cfqueryparam value="#arguments.settings.getAutoApproveProductsOnRevision()#" cfsqltype="CF_SQL_BIT"><!--- D42590 :: Auto approve products on revision --->
                    ,BB_Payment_Request_Hold_Release = <cfqueryparam value="#arguments.settings.getBBPaymentRequestHoldRelease()#" cfsqltype="CF_SQL_BIT"><!--- 43559 BB Pymt Req Hold/Release --->
                    ,Show_Holding_Pen = <cfqueryparam value="#arguments.settings.getShowHoldingPen()#" cfsqltype="CF_SQL_BIT">
                    ,Approve_BB_Based_On_Profile_Total_Approval_Amount = <cfqueryparam value="#arguments.settings.getApproveBBBasedOnProfileTotalApprovalAmount()#" cfsqltype="CF_SQL_BIT"><!--- 43559: BB Pymt Amt Within Profile�s Total Approval Amt = Approved Status --->
                    ,disable_pages_in_rfa = <cfqueryparam value="#arguments.settings.getdisablepagesinrfa()#" cfsqltype="CF_SQL_BIT"><!---D43661 :: Program RFA status - disable pages and require user to Reset to make any changes  --->
          ,Auto_Weight_Distributors_Program_On_Revision = <cfqueryparam value="#arguments.settings.getAutoWeightDistributorsProgramRevision()#" cfsqltype="CF_SQL_BIT"><!--- D41881 :: Auto adjust of DST Weights--->
                    ,Date_Tolerance = <cfqueryparam value="#arguments.settings.getDateTolerance()#" cfsqltype="CF_SQL_TINYINT"><!--- D44724: Billback Approval Automation --->
             ,RFA_Notification_1_Case = <cfqueryparam value="#arguments.settings.getRFA_Notification_1_Case()#" cfsqltype="CF_SQL_BIT">
                    ,Dont_Set_Bid_Product_Status_on_Revise = <cfqueryparam value="#arguments.settings.getDontSetBidProductStatusRevise()#" cfsqltype="CF_SQL_BIT">
                    ,Custom_Max_Rate = <cfqueryparam value="#arguments.settings.getCustomMaxRate()#" cfsqltype="CF_SQL_BIT"><!---D45263 :: Create table to store max rates by template/profile --->
                    ,Mass_Change_Preactive = <cfqueryparam value="#arguments.settings.getMassChangePreactive()#" cfsqltype="CF_SQL_BIT"><!---44077 :: Mass change preactive dates --->
                    ,Auto_Reconcile_Match_Central_BB = <cfqueryparam value="#arguments.settings.getAuto_Reconcile_Match_Central_BB()#" cfsqltype="CF_SQL_BIT">	<!--- D45778 :Auto Reconcile BB's closed to deduction in 1500--->
                    ,Payee_From_Planning_Groups = <cfqueryparam value="#arguments.settings.getPayeeFromPlanningGroups()#" cfsqltype="CF_SQL_BIT">	<!--- 45076 :Establish payee from the planning groups--->
                    ,BB_ReferenceNum_Required = <cfqueryparam value="#arguments.settings.getBBReferenceNumRequired()#" cfsqltype="CF_SQL_BIT">	<!--- D46525: Make BB Reference Field Required/Anand Rao/25-Nov-2014 --->
                    ,Allow_BB_Dont_Count_From_Program = <cfqueryparam value="#arguments.settings.getAllow_BB_Dont_Count_From_Program()#" cfsqltype="CF_SQL_TINYINT">	<!--- D48049: Count / Dont Count Volume based on Program Component --->
                    ,Use_Invoice_Market = <cfqueryparam value="#arguments.settings.getUseInvoiceMarket()#" cfsqltype="CF_SQL_BIT">	<!--- 49540: App Setting - Use_Invoice_Market --->
                    ,SingleSignOnOverrideUserId = <cfqueryparam value="#arguments.settings.getSingleSignOnOverrideUserId()#" cfsqltype="CF_SQL_TINYINT"> <!--- D48816 :: Single Sign On field needed to hold Username--->
                    ,Trade_Eligibility_Report = <cfqueryparam value="#arguments.settings.getTradeEligibilityReport()#" cfsqltype="CF_SQL_BIT"><!--- D49844 :: Create new app setting called �?Trade Eligibility Report�? with ON/OFF options --->
                    ,Enable_EDI_Upload_Raw_Data_Viewer = <cfqueryparam value="#arguments.settings.getEnableEDIUploadRawDataViewer()#" cfsqltype="CF_SQL_TINYINT"> <!--- D49837:CAG PROD - BB LH link EDI Download --->
                    ,Update_Program_Won_Lost_Based_On_OI = <cfqueryparam value="#arguments.settings.getPrgWonLostOnOffInvoiceRecord()#" cfsqltype="CF_SQL_BIT"><!--- D49855 :: Win/Loss Bid - Create new app setting called “Update Program won/loss based on Off invoice Record�? --->
                    ,Modify_Expired_Programs = <cfqueryparam value="#arguments.settings.getModifyExpiredPrograms()#" cfsqltype="CF_SQL_BIT"><!---D50074 :: Viewing and Editing prior program versions --->
                    ,Pymt_history_Dollars_Include_OffInvoice_Dollars = <cfqueryparam value="#arguments.settings.getPymtHistoryDollarsIncludeOffInvoiceDollars()#" cfsqltype="CF_SQL_BIT"><!---50324 "Payment history dollars" include "Off Invoice" Dollars --->
                    ,Check_All_BB_Duplicate = <cfqueryparam value="#arguments.settings.getCheckAllBBDuplicate()#" cfsqltype="CF_SQL_BIT"><!--- 51607 New Duplicate BB Logic - Appsetting Changes --->
                    ,Display_Orphan_Alert_Program_Revise = <cfqueryparam value="#arguments.settings.getDisplayOrphanAlertProgramRevise()#" cfsqltype="CF_SQL_BIT"> <!--- D52449 :: Create new app settings to control Orphan Pop up Alert --->
                    ,Program_Alert_On_RFA_Rate_0 = <cfqueryparam value="#arguments.settings.getProgramAlertOnRFARate0()#" cfsqltype="CF_SQL_BIT"> <!--- D50884 :: Improvements to the Rebate Page inside a Program 8.0 Release...  --->
                    ,Modify_Vendor_Records	 = <cfqueryparam value="#arguments.settings.getModifyVendorRecords()#" cfsqltype="CF_SQL_BIT">	<!--- D57447 :: Create and modify vendor records --->
                    ,Skip_Vendor_Selection_On_BB_Approval	 = <cfqueryparam value="#arguments.settings.getSkipVendorSelectionOnBBApproval()#" cfsqltype="CF_SQL_BIT">	<!--- 60998 :: Skip vendor selection on approval, if BB already has vendor associated to it. --->
                </cfquery>

        <!--- 2015 january 22 - chrisn: introduced _SETTINGS table with multiple rows feature for 2015 internal settings storage --->

        <cfset useLakebaseForgetCols = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_settings")>
<cfif useLakebaseForgetCols>
	<cftry>
		<cfset getCols = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_settings", {
				"select" = "input_name,value"
			}), "input_name,value"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetCols = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetCols>
<cfquery name="getCols" datasource="#application.datasource#">
            SELECT Input_Name, Value FROM _Settings
        </cfquery>
</cfif>

        <cfparam name="request.accessStructure.name_first" default="">
        <cfparam name="request.accessStructure.name_last"  default="">

        <!--- scan thru all new setting input names and save their values into the database --->
        <cfquery name="local.update" datasource="#application.datasource#">
            EXEC sp_set_session_context 'Updated_By', '#request.accessStructure.name_first# #request.accessStructure.name_last#'
            <cfloop query="getCols">
                <cfset local.input_name = trim(getCols.input_name)>

                <!--- take care only non-blank setting input name --->
                <cfif len(local.input_name)>
                    <!--- handle input not submitted with the form (e.g. unchecked checkbox) --->
                    <cfset local.value = trim(structKeyExists(form, local.input_name) ? form[ local.input_name ] : getCols.value )>

                    <!--- place setting value in the form into the database --->
                    UPDATE _Settings
                       SET Value = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.value#">
                     WHERE Input_Name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.input_name#">
                </cfif>
            </cfloop>
            EXEC sp_set_session_context 'Updated_By', NULL
        </cfquery>

        <cfset Track_Changes()>
    </cffunction>

    <cfinclude template="TrackChanges.cfm">
</cfcomponent>