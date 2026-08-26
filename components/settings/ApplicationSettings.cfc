<!---
	FILENAME:   components/settings/ApplicationSettings.cfm
	Copyright   (c) 2008 Blacksmith Applications, Inc.
	CREATED:  ??/??/??  ??
	EDITED:   09/26/08  RBL [16314]
--->
<cfcomponent hint="Futures Pricing Settings" extends="components.Base" output="false">
	<!------ 1 ----->
	<cfscript>
		this.programInterfaceBuffer = 0;
		this.awaitingactiondays = 0;
		this.SendReportTo  = 0;
		this.ReportRunDays  = 0;
		this.TrafficInfoDays = 0;
		this.billbackNumberPrefix = "";
		this.deductionNumberPrefix = "";
		this.DDCreditNumberPrefix = "";
		this.plannerNumberPrefix = "";
		this.AutoClaimBuffer = 0;
		this.DocumentPath = "";
		this.DocumentMapping = "";
	</cfscript>

	<!------ 2 ----->
	<cfscript>
		this.DollarGrowth = 0 ;
		this.UseXMaterial = 0;
		this.useProductGroup1 = 0;
		this.useProductGroup2 = 0;
		this.useProductGroup3 = 0;
		this.useProductGroup4 = 0;
		this.useProductGroup5 = 0;
		this.useProductHierarchy = 0;
		this.appSettingsOnForAll = 0;
		this.sendAutoAttachments = 0;
		this.autoBroker = 0;
		this.rfaAgree = 0;
		this.customertype = 0;
		this.restrictProductUOM = 0;
		this.rebateMaxComponents = 1;
		this.labelnotes = "";
		this.FloorPrice = 0;
		this.allownavigate = 0;
		this.programnotesrequired = 0;
		this.lumpMultipleProducts = 0;
		this.Equipment_Placement = 0;
		this.Send_Approved_Programs_EmailAdress = 0;
		this.Only_Notify_RSP_Of_Approval = 0;
		this.Classcodes_On = 0;
		this.send_secondary_email = 0;
		this.growthExpansion1 = 0;
		this.fixedcomponents_on = 0;
		this.rolloverprograms_on = 0;
		this.forbidAllowProfilesInTemplates = 0;
		this.uploadmargintargets_on  = 0;
		this.restrictAccessOnGroup  = 0;
		this.businessconsiderations_on = 0;
		this.custid_on = 0;
		this.singlesign_on = 0;
		this.BB_Fixed_Calc_Types_On = 0;
		this.claimAutoPrint = 0;
		this.allowAllDistributors = 0;
		this.maxProfileCount = 0;
		this.distributorMultiPosition = 0;
		this.operatorSearchRestrict = 0;
		this.SalesOrgOn = 0;
		this.DistributionChannelOn = 0;
		this.deleteProgramMessage = "";
		this.DeleteIsCancelAutoRenew = 0;
		this.cancelProgramEmail = 0;
		this.PaymentCycleAtDiscountType = 0;
		this.Settlement_SAP_Business = 0;
		this.Sysco_Report_On = 0;
		this.allowMultiLevelGroups = 0;
		this.ProgramAgreeEscalate = 0;
		this.checkOrderClass = 0;
		this.OrderClassValue = "";
		this.business_segment_label = "";
		this.Integation_Instance_ID = "";
		this.BB_Ref_Num_Max_Length = "";
		this.BB_2Ref_Num_Max_Length = "";
		this.lob_label = "";
		this.Send_to_SAP = 0;
		this.BB_Payee_Operator_Ship_To_Req = 0;
		this.Vendor_Selection_Pay_Req = 0;
		this.Billback_Payment_Request_Without_Vendor_Selection = 0;
		this.Skip_Vendor_Selection_On_BB_Approval = 0;
		this.Restrict_DD_Reason_Code_By_Closing_method = 0;
		this.Multiple_BB_Per_Deduction = 0;
		this.Allow_Negative_Billback = 0;
		this.BB_Allow_Off_Invoice_Closing_Method = 0;
		this.Interface_700_To_Client = 0;
		this.DD_Show_reassign = 0;
		this.Auto_Deviation_On = 0;
		this.DD_Show_Classification = 0;
		this.DD_Show_DeductionType = 0;	 // ---26487---;
		this.DD_Show_Edit_Customer_Num = 0;
		this.DD_Show_Create_Adjustment = 0;
		this.Component_Product_Restrictions_On = 0;
		this.DD_Show_Delete = 0;
		this.DD_Show_ReOpen = 0;
		this.DD_Show_Reject = 0;
		this.DD_Show_Program = 0;
		this.DD_Show_Invoices = 0;
		this.DD_Allow_Non_Trade = 0; //D29481:Non trade deductions START---;
		this.DD_Reopen_Interface = 0; //D42284 :: Rebill vs closed deduction reopened;
		this.ERP_Deal_ID_PopUp = 0;
		this.BB_Allow_UnKnow_Program_Creation = 0;
		this.BB_Pay_Req_Dup_Check = 0;
		//--- <cfset this.Template_Notes_Availability = 0; ---; --- BJF: Removed with label 13333  ---;
		this.templatecodes_on = 0;
		this.userNumberRestrict = 0;
		this.USDANOIEnabled = 0;
		this.productSearchGetProductByProgramOn = 0 ;
		this.disableGroupProductSearchINproductSearch = 1 ;
		this.startAutoRenewAtRFA = 1 ;
		this.DistSearchGetDistByProgramOn = 0 ;
		this.invoiceBrokerFilterRestrict = 0 ;
		this.viewProgramProductGroupType = 0 ;
		this.OneProgramPerBillback = 0 ;
		this.programBudgetOn = 0 ;
		this.viewProgramProductGroupTypeDesc = "" ;
		this.spendingCapVersion = 0 ;
		this.growthDecimal4PercentTier = 0 ;
		this.printer2Name = "" ;
		this.captureGroupsOnSave = 1 ;
		this.ForInvoicesDisplayOI = 0 ;
		this.bidRequestPriceListId = 0 ;
		this.RFAEmailEvent = 1 ;
		this.bbAgreeEmail = 0 ;
		this.bbCheckPayTo = 0 ;
		this.appErrorAddToPunchlist = 0 ;
		this.disableBBAddProgram = 0 ;
		this.pgmLumpsumDetailedDisplay = 0 ;
		this.Renew_expired_programs = 0 ;
		this.Use_Accounting_Program_Type = 0 ;
		this.BB_PP_Manual_Discount = 0 ;
		this.BBDateDevInExpectedVol = 0 ;
		this.showBSAOperators = 0 ;
		this.BidRequestAvailable = 0 ;
		this.FuturesPricingAvailable = 0 ;
		this.ExternalWebserviceURL = "" ;
		this.WebserverInternalIPAddress = "" ;
		this.AutoRenewSpaninPW = 0 ;
		this.lettersavailable = 0 ;
		this.deviationLabel = "" ;
		this.Program_Allow_Null_Rate = 0 ;
		this.Claims_at_Comp_Level = 0 ;
		this.pgmDisableEditWhileSendingToClient = 0 ;
		this.operatingGroupOn = 0 ;
		this.lettersavailable = 0 ;
		this.letterssubject = "" ;
		this.lettersfromemail = "" ;
		this.searchSequenceOn = 0 ;
		this.localcostvariables = 0 ;
		this.customerbasedcosts = 0 ;
		this.maxlocalcostvars = 0 ;
		this.pgmGrpsOnlyProdAtLowerLevel = 0 ;
		this.groupByGroupType = 0 ;
		this.print_includeheader = 0 ;
		this.pricing_template_list = "" ;
		this.ShowProjectsScoreCard = 1 ;
		this.PgmScorecardRevisionReport = 1 ;
		this.InvoicePositionRestriction = 0 ;
		this.Distributor_Letter_Name = "" ;
		this.Operator_Letter_Name = "" ;
		this.RemoveMarketFromPgmSearchPage = "" ;
		this.Check_All_Duplicate_Program = 0 ;
		this.Authority_Sequence_For_HQ_Only = 0 ;
		this.pgmViewDisplaySPRAddress2 = 0 ;
		this.Bid_Request_Hierarchy_Level = "" ;
		this.Show_OR_Hide_Groups_In_View_Margin = 0 ;
		this.tradeplanneroff = 0 ;
		this.approvalmatrixoff = 0 ;
		this.Allowed_to_Add_Operator = 1 ;
		this.Created_Operators_Default_Active = 0 ;
		this.programNumberPrefix = "" ;
		this.pgmEmailPricingAdmin = 0 ;
		this.Letters_Accepted_By = 0 ;
		this.Letters_Address = 0 ;
		this.BBRestrictRouteUserList = 0 ;
		this.commonAccessURLPrefix = "" ;
		this.pgmLikeProductCheckbox = 0 ;
		this.view_approved_margins_report = 0 ;
		this.pgmDisplayBothRateUOM = 0 ;
		this.retain_original_RSP = 0 ;
		this.dailyRSPUpdate = 0 ;
		this.Mass_Pay_Billback = 0 ;
		this.cancelallprogramversions = 0 ;
		this.ClaimMech_Popup = 0 ;
		this.Display_Only_Assigned_Deductions = 0 ;
		this.ShowMapping = 0 ;
		this.Avoid_Shared_Products_in_LumpSum = 0 ;
		this.Remove_Help_Icon = 0 ;
		this.display_clients_help_desk_info = 0 ;
		this.clients_help_desk_info = "" ;
		this.User_Fax_Number = 0 ;
		this.BillbacksSalesTax = 0 ;
		this.direct_pricing_on = 0;
		this.revision_report_uom = 1;
		this.display_zeros_view_program = 0;
		this.Apply_RSP_Filters = 0;
		this.pgmGrpLevel3IsExclusion = 0;
		this.ShowUploadAccrual = 0;
		this.bonusingrowthswitch = 0 ;
		this.searchProductHierarchyExcludeList = 0;
		this.letters_company_logo_path = 0;
		this.payment_history_on = 0;
		this.BB_Allow_Vendor_Master_Search = 0;
		this.Vendor_Search_In_BB_Payee_Page = 0;
		this.BBAllowVendorCrossRefSearch = 0;
		this.DD_Reassign_Analyst_While_Changing_Pay_To = 0;
		this.DD_Assignment_Based_On_Shr_Ship_to = 0;
		this.DD_Allow_Negative_Amount_Credits = 0;
		this.DD_Change_Classification_Before_RFA = 0;
		this.DD_Allow_Write_Off = 0;
		this.DD_Sent_Reject_In_1510 = 0;
		this.DD_Close_With_Equal_BB_Amt = 0;
		this.PullBack_Start_Date = "";
		this.Populate_180Day_From = 0;
		this.BidRequest_Use_Price_ByDate = 0;
		this.BidRequest_Components_On = 0;
		this.DontRevise_Untill_SAP_OKack = 0;  //--- Dev Note: KAL; D8067 ---;
		this.ShowLumpSumDistributors = 0 ;
		this.Show_BB_Route = 0 ;
		this.send_distributor_broker_email = 0 ;
		this.Display_Requester_Approver = 0 ;
		this.Display_Requester_Approver_Position = 0 ;
		this.Hide_BSA_Users = 1 ;
		this.HQpositionsOn = 1 ;
		this.Report_Payment_History = 0 ;
		this.Upload_Document_Privacy_Off = 0 ;  //--- Dev Note: CPM D8275 ---;
		this.CustsearchRebaterecipientOn = 0;
		this.Divide_Pgm_Vol_4_Groups = 0 ;
		this.Pgm_Vol_Show_Groups = 0 ;
		this.ShowManagerDetailsOnViewProgram = 0 ;
		this.ViewPgmSortBy = 0 ; //--- Dev Note: CPM D8223 ---;
		this.crucibleOn = 0 ;
		this.brokerTradeQuestOn = 0 ;
		this.ShowProgramCategory = 0 ; //--- Dev Note: Milan D8452 ---;
		this.PullbacksOn = 0 ;
		this.pullbackLabel = 0 ; //--- Dev Note: DRK 9326 ---;
		this.Search_Mini_Item_Master  = 0 ;
		this.pgmPostApprovalStatus = 0 ;
		this.pgmPostApprovalStatusType = 0 ;//--- Dev Note: DRK 6122 ---;
		this.ConfidentialityAgreement = 0 ; //--- Dev Note: Milan 8469 ---;
		this.RemoteEventsEmail = "" ; //--- Dev Note: Milan 8482 ---;
		this.OperatorDistributorProgramScoreCard = 0 ; //--- Dev Note: Milan 8516 ---;
		this.NumberOfDaysForMiniItemMaster = 0 ;  //--- Dev Note: Milan 8471 ---;
		this.Display_Evaluation_Notes = 0 ; //--- Dev Note: CPM 8506 ---;
		this.Remove_Broker_Selection = 0 ; //--- Dev Note: CPM 8536 ---;
		this.Display_Eligible_RSP = 0 ; //--- Dev Note: CPM 7920 ---;
		this.appErrorEmailLinkAlone = 0 ;
		this.BidRequest_Display_Allowance  = 0;
		this.modify_agree_program  = 0;
		this.disable_pages_in_rfa  = 0; //D43661 :: Program RFA status - disable pages and require user to Reset to make any changes
		this.BBDisplayResubmit  = 0;
		this.BBAllowReverse = 0 ;
		this.Use_Item_Cust_Price = 0 ;
		this.ShowBBExcelReport = 0 ; //--- Dev Note: Milan 8521 ---;
		this.displayInterfaceFlagsSet1 = 0 ;
		this.ShowManualBillBack = 0 ; //--- Dev Note: Milan 9165 ---;
		this.ShowAutoBillBack = 0 ; //--- Dev Note: Milan 9165 ---;
		this.AutoBillBackType = 0 ; //--- Dev Note: Milan 9165 ---;
		this.PriceList_displayed_Right_Click = 0 ; //--- Dev Note: GV 9284 ---;
		this.View_Trade_Checkbook = 0; //--- Dev Note: BJF 9313 ---;
		this.View_Auto_Checkbook = 0; //--- Dev Note: BJF 9313 ---;
		this.View_legacy_ID = 0; //--- Dev Note: Milan 9360 ---;
		this.Modify_legacy_ID = 0; //--- Dev Note: Milan 9360 ---;
		this.RevisionTypesOn = 0; //--- Dev Note: GV 9391 ---;
		this.WelcomeLetterOn = 0;//--- Dev Note: Clay 9254   ---;
		this.templateRestrictGroupLevel  = 0;//---Dev Note: DRK 9674 ---;
		this.restrictHierarchyLevelOnClassCode  = "" ;//---Dev Note: DRK 9679 ---;
		this.PasswordRequirementsStatus  = 0 ;//---Dev Note: Milan 9879 ---;
		this.Use_AccrualLog_For_TC  = 0 ;//---Dev Note: BJF 7963 & 10139 ---;
		this.Allow_One_Component_for_Pullbacks  = 0 ;//---Dev Note: Milan 9956 ---;
		this.programSpecialRevisionFlag  = "" ;//---Dev Note: DRK 10295 ---;
		this.GroupLevelBillback = "" ;//---Dev Note: Kal 10343 ---;
		this.Allow_UnKnown_Payee_In_Billback = 1 ;//--- Dev Note: Milan 10380 ---;
		this.Hide_Invalid_Component_Types_In_Billbacks = 0;//--- Dev Note: Milan 10433 ---;
		this.billbackScorecardCache = 1 ; //--- Dev Note: DRK D10619 ---;
		this.programScorecardCache = 1 ;
		this.projectScorecardCache = 1 ; //--- D17674 RBL 12/08/08 ---;
		this.Use_Big_Billbacks = 0 ; //--- Dev Note: BJF D10291 ---;
		this.Billback_Closing_Method = 1 ;//--- Dev Note: Milan 10605 ---;
		this.Lost_Bids_Deviated = 0 ;//--- Dev Note: BJF D10608 ---;
		this.One_Page_Claim_Form = 0 ;//--- Dev Note: BDensmore 10788 ---;
		this.Freight_Calculator_On = 0 ;//--- Dev Note: Clay D10941 ---;
		this.loginPageLogoPath = "/images/Logon_Blacksmith/index_02.gif" ;
		this.app_EZButton_On = 0 ;
		this.suppressGroupsZeroItems = 0 ;
		this.suppressBusinessConsiderations = 0 ;
		this.AddTodoOnDocAttach = 0 ;
		this.IncludeUsersEmailAuto = 0 ;
		this.programApprovalForInactiveOperators = 0 ;
		this.DisableAutoLogin = 0 ;//---  Dev Note:  MarkS 11287 ---;
		this.DataIntViewer = 0 ;//---  Dev Note:  MarkS 10729 ---;
		this.settings.BBDeviationUseMaxPrice = 0 ;//---  Dev Note:  MarkS 11127 ---;
		this.ReleaseSettlement = 0;
		this.LumpSumComponentInProgram = 0 ; //--- Dev Note: BSD D11414 ---;
		this.send_release_settlement_emailaddress = ""; //--- Dev Note: CPM 11286 ---;
		this.Allow_Percent_Operator_Programs = 0; //--- Dev Note: BJF D11527 ---;
		this.BillbackModifyAgree = 0 ; //--- Dev Note: KAL D11049  ---;
		this.OnlyAccrualTPA_Pullbacks = 0 ;
		this.UOMEAAvailable = 0 ;//----- D11545: Create a new Rebate Type for Scan Programs -----;
		this.Position_Tree_Display_Distributor = 1 ;//----- D12004: Remove distributors from tree -----;
		this.BB_UPLOAD_UPDATED = 1 ;
		this.SplitBillbacks = 0 ;//--- Dev Note: BSD D11643 Turn Split Billbacks on or off ---;
		this.BB_Auto_report = 0 ;//---  Dev Note:  MarkS 11427 Auto Billbacks Via the BB Auto Report Screen in Settings ---;
		this.BB_Auto_Pay_Customer_Group_In_Invoice = 1 ;//--- Dev Note: D18880---;
		this.BB_Auto_Pay_Disable_Pay_Each = 0 ;//--- Dev Note: D18879---;
		this.BB_Auto_Pay_Allow_Negative_Paid_Amount = 1 ;//--- Dev Note: D19057---;
		this.BB_Auto_Pay_Lump_Sum = 0; //Dev Note: BB_Auto_Pay_Lump_Sum MarkS
		this.BBAutoReportisManuallyConfigured = 0 ;
		this.BBAutoReportAllowManual = 0;
		this.BBAutoReportAllowReverse = 0;
		this.PgmMarginRebateUseAutoPayPrice = 0;
		this.ShowExportPrograms = 0 ;//--- Dev Note: Milan D11495 Lamb Export - Sales Agreement Application ---;
		this.Interface_BuyingGroup_As_Group_To_Client = 0;
		this.BB_Expected_Rate_GT_Claim_Rate = 0 ; //---  Dev Note:  MarkS 12498 ---;
		this.BB_Auto_Report_Start_Date = now() ; //---  Dev Note:  MarkS 12575 ---;
		this.budgetsFunctionalityOn = 0 ;
		this.budgetSelectionRequired = 0 ;
		this.budgetSingleLevelForFixed = 0 ; // 43536
		this.budgetsProgramApproveEmailAddress = "" ;
		this.budgetsBillbackApproveEmailAddress = "" ;
		this.Distributor_Product_Integrity_On = 0 ; //--- BJF: D11212 ---;
		this.showClaimAdjustment = 1 ; //--- DRK: D12937 ---;
		this.ItemMarginTarget_OR_GrossMargin_For_PriceList = 0 ; //--- Dev Note: Milan 13016 ---;
		this.Show_Fixed_Freight = 0;
		//--- 13397 5.0 only ---;
		this.Show_Component_Accrual = 0;
		this.Show_Component_Floor_Pricing = 0;
		//--- 13428 5.0 only ---;
		this.GL_Account_On = 0;
		this.GL_Account_Required_for_Comp = 0;
		this.Exact_List_Matching_On = 0;
		//--- Dev Note: KAL; D13469: Brokerage Application Settings ---;
		this.Brokerage_Functionality_On = 0;
		this.Auto_BB_Create_Status_ID = 0;
		this.Brokerage_Margin_Calculation = 0;
		this.BB_Reference_Uppercase = 0;
		this.suppressBillbackBusinessConsiderations = 0 ;
		this.DisplayDistributorOffInvoice = 0 ; //---  Dev Note:  Milan 14314 ---;
		this.DisplayProposal = 0 ; //---  Dev Note:  Milan 14314 ---;
		this.DisplayUSDANOI = 0 ; //---  Dev Note:  Milan 14314 ---;
		this.Disable_Adding_Components_On_Revision = 0 ;
		this.View_Delete_Records = 0 ;
		this.DD_Negative_Splits = 0 ;
		this.Program_Lock_Type_ID = 0 ;
		this.Label_Sets = 0 ;//--- DAA D14842 ---;
		this.programClaimRatesReportAvailable = 0 ;
		this.programClaimRatesReportExcludeRegularPrices = 0 ;
		this.Show_Reason_Code_On_BB_Approval_Screen = 0 ;//--- Dev Note: Milan; 15415 ---;
		this.Hide_Billback_Adjustments = 0;//--- BJF: D15741 ---;
		this.SSL_On = 0;
		this.SSL_On_All_Pages = 0;
		this.AuditTrailStorage = 0;//--- DAA D15331 ---;
		this.AllowBidStatusEditAnytime = 0;//--- DAA D16859 ---;
		this.ReasonCodeinBillbackDED = 0;//--- DAA D16974 ---;
		this.Show_Pricing_Report = 0;
		this.Days_of_Historical_Data_For_SpecialPriceList = 0;
		this.BBAllowResetAfterDEDInterface = 0;//--- DRK D16732 ---;
		this.BBAllowResetBeforePMTInterfacePRStatus = 0;//--- DRK D16732 ---;
		this.ProductReplacementEnabled = 0;//--- DRK D13872 ---;
		this.BillbackAllowMultipleBudgets = 0;
		this.AllowBillbackToCreditMatching = 0;
		this.MaxFutureDaysForClaimRatesORPricingExtract = 0; //---  Dev Note:  Milan 17838 ---;
		this.IsVantageOn = 0; //---  Dev Note:  Milan 17867 ---;
		this.VantageDataSource = ""; //---  Dev Note:  Milan 17867 ---;
		this.Search_Selection_Tracking_On = 0;//--- Dev Note: BJF 18081 ---;
		this.expiredRecentlyDays = 0;//--- Dev Note: DRK 18668 ---;
		this.Pre_Active_Replace_Parent = 0;//--- Dev Note: TSF 18682 ---;
		this.View_Program_Volume_UOM = 3;//--- Dev Note:  18882 ---;
		this.View_Program_Estimated_Amount = 0;//--- Dev  18882 ---;
		this.Filter_Business_Segments = 0;//--- Dev Note: TSF 18940 ---;
		this.Program_Alerts = 0;//--- Dev Note: TSF 18950 ---;
		this.Reset_Won_Lost_On_Revision = 0;//--- Dev Note: BJF 19170 ---;
		this.ApprovalViaEmail = 0 ; //--- Dev Note: KAL; D19440: Approval via Email ---;
		this.DD_Restrict_ShipTo_For_BB = 0;//--- Dev Note: BJF 19297 ---;
		this.Primary_Product_Attribute = "";//--- Dev Note: BJF ---;
		this.BB_Inserts_Credit_To_Invoices = 0;//--- Dev Note: BJF 19303 ---;
		this.BB_Status_To_Insert_Credit = 5;//--- Dev Note: BJF 19303 ---;
		this.Show_BB_Summary_Statement = 0;//--- Dev Note: BJF 20743  ---;
		this.BillBack_Statement_Type = '';  //27047 - ChrisN
		this.Operator_Creation_Fields_Required = 0;//--- Dev Note: Milan 19451 ---;
		this.ThirdPartyBBUpload = 0;//--- Dev Note: Milan 20399 ---;
		//--- Dev Note: KAL; D20523: App setting to turn flex search tools on/off ---;
		this.FlexProgramSearch = 0 ;
		this.BillbackModuleType	 = 0 ;
		this.FlexDistributorSearch = 0 ;
		this.FlexBrokerSearch = 0 ;
		this.FlexOperatorSearch = 0 ;
		this.FlexProductSearch = 0 ;
		this.BB_Show_Modify_Program = 0;//--- Dev Note: TSF 20454 ---;
		this.BB_Deviations_Override_Price = 0;//--- Dev Note: Anand Rao 19441---;
		this.BB_Upload_III_P_Qty_Amt_Editable = 0; //--- Dev Note: Anand Rao 19441---;
		this.Flex_BB_Deviation = 0; //--- Dev Note: Anand Rao 19441---;
		this.Program_Search_Dollars_And_Volume = 0; //--- 50324: Add Dollars and volume for program search---;
		this.Pymt_history_Dollars_Include_OffInvoice_Dollars = 0; //--- 50324 - "Payment history dollars" include "Off Invoice" Dollars.---;
		this.Check_All_BB_Duplicate = 0; // --- 51607 New Duplicate BB Logic - Appsetting Changes
		this.BB_Fractional_Volume = 0; //--- Dev Note: Ana 24087---;
		this.Display_Vendor_ID_Null_Form = 0; //--- Dev Note: Anand Rao 21185---;
		//--- <cfset this.DisplayHoldReleaseCheckbox = 0; ---; //--- Dev Note: Milan 20724 ---;
		this.DisplayCashDiscountMargin = 0; //--- Dev Note: KAL; D20537 ---;
		this.BBAutoPayToOperatorUseInvoiceOprID = 0; //--- Dev Note: Mark S D20848---;
		this.BB_Product_Allow_Zero_Volume = 0; //--- Dev Note: Mark S D21414---;
		this.WebserviceOn = 0 ;
		//--- 21923/Anand Rao/22-Jan-2010 ---;
		this.Update_BB_Approve_Amt = 0 ;
		this.BB_Approve_Expected_Rate_Less_Tolerance = 0 ;
		//--- Dev Notes: 19384/Anand Rao/05-Apr-10 Rebill Interface and changes ---;
		this.Integrated_Rebill = 0 ;
		this.Allow_Revise_Active_With_Pre_Active = 0 ;
		this.Credit_Type_Is_DD_Reason_Code = 0 ;
		this.Reason_Code_in_Billback_Display_Setting  = 1;
		this.Search_Inactive_Products_Programs = 0;
		this.Search_Inactive_Distributors_Programs = 0;
		this.Search_Inactive_Operators_Programs = 0;		//---26199---;
		this.retain_original_RSP_copy = 0 ;
		this.Billback_Module = 1 ;
		this.Deduction_Module = 1 ;
		this.FTP_Document_Path = "" ;
		this.marginItemsExclude = 0 ;
		this.PlanningGroups = 0 ;
		this.BB_Reason_Code_Allow_Multiple = 0 ;
		this.Simple_Clause = 0 ;
		this.BC_On_RFA_af_Reset = 0 ;
		this.Require_Business_Considerations_On_New_Programs = 0;
		this.DD_User_Reference = 0 ;
		this.BBCreatedRecentlyDays = 0;
		this.Display_notes_field_on_program  = 1;
		this.User_Account_Middle_Initial  = 0;
		this.Use_Fixed_Price_Type  = 0;
		this.Display_Quote_Letter  = 0;
		this.Price_List_By_Template  = 0;
		this.Shortcut_No_Routing_Allowed = 0;
		this.Position_Fields_Filtered_Based_On_Program_Segment = 0; //D28618 Drachala: Position Drop Down Fields filtered based on Program Business Segment
		this.Base_Sale_Label = "";//D28459: Change Base Sales program labels to custom label for Hormel Added This Appsetting Variable.
		this.Net_Sale_Label = "";//D28459: Change Base Sales program labels to custom label for Hormel Added This Appsetting Variable.
		this.ErpDeductionDocPath = ""; //D29482
		this.Documents_Display_Upload_Form = 0;
		this.External_Contacts_Option = 0;  //28345
		this.Edit_Product_Master_Data = 0;
		this.PrgWonLostOnBBApproval = 0;
		this.InvoiceCostForVantage  = 0;//D30750:Create app setting to use invoice cost from invoice file
		this.Multiple_BillTos_For_ShipTo = 0;//D30486: Multiple AR numbers to 1 Account(Customer)-UI
		this.BillbackQuickPay = 0;//D25219: SOW - Enable mass paying of payables
		this.DD_Closed_BB_Status = 0;
		this.BB_Reset_Unacknowledged_Interface = 0;
		this.BB_Reinterface_Unacknowledged_Interface = 0;
		this.Billback_Display_All_Program_Components = 0;//31378:Add Program w/o Payee Components don't display
		this.Favicon_Path = ''; //31616 -Add favorite icon to URL address line
		this.BB_LS_Claimed_Rebate_Expected = 0; //31769 - Billback Deviation Grid
		this.CRAConsiderAnalyst=0; //D32585 Drachala Approval e-mails sending to all TL's
		this.Billback_Display_Base_Sales_in_Rate_Dev = 0;
		this.Billback_Upload_Business_Segment = 0;//D29947 Update billback upload for SO/DC
		this.Billback_File_Upload_Type = 2; //D33957  Modify standard billback upload to one file
		this.Template_Multiple_Product_Attr_Groups = 0; //use template setting Allow_In_Group_Search to define Product attrs that Form a group record
		this.Profitability_Model = 0; //D36542
		this.Mass_Copy = 0;
		this.autoRenewScheduled = 0; //37007 - Auto Renew sending wrong program email attachments
		this.BB_Auto_Approve_Logic = 0; //D37022
		this.View_Operator_in_Billback_Deviation = 0; // D36746
		this.BB_Overlap_Deviation_Based_On_Operator = 0; // D36746
		this.BB_Default_Program_Retry_Process = 0; // D36746
		this.BB_Default_Program_Retry_Also_Call_Deviation = 0; // D36746
		this.Program_Allow_Negative_Rebate_Rates = 0;
		this.AllowableOverlapPeriod = 0; //D40749	Allowable Overlap Period setting
		this.BB_Inserts_Credit_To_Invoices_GT = "";//D38043  :: Program revision dates - View Program
		this.Program_search_dates=0;//D38043  :: Program revision dates - View Program
		this.UNIPRO_450  = 0;
		this.Deviation_Grid_Allow_Manual_Values_GT_Claimed= 0;
		this.BB_Payee_Broker_Ship_To_Req = 0;
		this.Editable_Claimed_Dollars_Quantity = 0;
		this.DDReopenParent = 0; // D40312
		this.Operator_Q_Brand_Legacy = 0;  // D40156
		this.CancelPgmNoBBMonths = 0;  // D35165
		this.ShowBrandOnViewProgram = 0;
		this.Enable_Group_Membership_Dates = 0;
		this.DeductionQuickUpdate = 0;  // D42846
		this.AutoApproveProductsOnRevision = 0; // 42590
		this.BB_Powerpunch = 0; //43155
		this.BBPaymentRequestHoldRelease = 0; // 43559
		this.ApproveBBBasedOnProfileTotalApprovalAmount = 0; // 43559
		this.Auto_Weight_Distributors_Program_Revision = 0;   // D41881
		this.RFA_Notification_1_Case = 0;
		this.Show_Holding_Pen = 0; // D44787
		this.DateTolerance = 0;
		this.Dont_Set_Bid_Product_Status_on_Revise = 0; //45235 :: Bid flags not flipping correctly
		this.Custom_Max_Rate=0;//D45263 :: Create table to store max rates by template/profile
		this.Mass_Change_Preactive = 0;
		this.Auto_Reconcile_Match_Central_BB = 0; // D45778 :Auto Reconcile BB's closed to deduction in 1500
		this.By_Pass_Expected_Rate_Calculation_Enhancement = 0; //45864 :: JRS - Expected rate calculation [LTL, Redi] Bypass
		this.Payee_From_Planning_Groups = 0;
		this.BB_ReferenceNum_Required = 0;
		this.Allow_BB_Dont_Count_From_Program = 0; // D48049: Count / Dont Count Volume based on Program Component
		this.Use_Invoice_Market = 0; // 49540: App Setting - Use_Invoice_Market
		this.SingleSignOnOverrideUserId = 0;//D48816 :: Single Sign On field needed to hold Username
		this.TradeEligibilityReport = 0;//D49844 :: Create new app setting called �?Trade Eligibility Report�? with ON/OFF options
		this.Enable_EDI_Upload_Raw_Data_Viewer = 0; //D49837:CAG PROD - BB LH link EDI Download
		this.PrgWonLostOnOffInvoiceRecord = 0;//D49855 :: Win/Loss Bid - Create new app setting called “Update Program won/loss based on Off invoice Record�?
		this.ModifyExpiredPrograms = 0;//D50074 :: Viewing and Editing prior program versions
		this.DisplayOrphanAlertProgramRevise = 0;//D52449 :: Create new app settings to control Orphan Pop up Alert
		this.ProgramAlertOnRFARate0 = 0;//D50884 :: Improvements to the Rebate Page inside a Program 8.0 Release...
		this.Modify_Vendor_Records = 0;//D57447 :: Create and modify vendor records
	</cfscript>

	<!------ 3 ----->
	<cfscript>
		this.approvalPoundMarginOn = 0;
		this.approvalPercentMarginOn = 0;
		this.approvalTotalPgmMarginOn = 0;
		this.approvalSpendingCapOn = 0;
		this.approvalLayeredOn = 0;
		this.approvalMarginType = 0;
		this.Display_Trade_Percent_on_Margin = 0;
		this.marginOperatingIncomePercentType = 1;
		this.ApprovalDisposableOn = 0;
		this.ApprovalStandardOn = 0;
		this.approvalLayeredCosts = 0;
		this.Use_DC_SO_Base_sales = 0;
		this.use_cost_multiplier = 0;
		this.Margin_Display_LB = 0;
		this.Margin_Display_CS = 0;
		this.Margin_Display_EQ = 0;
		this.Margin_Display_default = 0;
		this.TPA_Includes_PreActive = 0 ;
		this.TPA_Includes_Active = 0 ;
		this.TPA_Includes_Expiring = 0 ;
		this.TPA_Includes_Program_Dates = 0 ;
		this.OperatorTPAInDistributorPrograms = 0 ;
		this.showfixedprice_additionalfields = 0;
		this.showrebate_additionalfields = 0;
		this.Approve_LS_Component_By_Profile = 0;
		this.LS_Allocation = 0;
		this.Sequential_Net_Sales_Operating_Margin = 0;
	</cfscript>

	<!------ 4 ----->   <!--- Dev Note: KAL; 7916 --->
	<cfscript>
		this.TempPassword = 0 ;
		this.NewPassword = 0 ;
		this.AdminPassword = 0 ;
		this.PasswordChangeDays = 0 ;
		this.PasswordMinLen = 0 ;
		this.PasswordHistory = 0 ;
		this.PasswordUpperChar = 0 ;
		this.PasswordLowerChar = 0 ;
		this.PasswordNumChar = 0 ;
		this.PasswordSpecialChar = 0 ;
		this.defaultPasswordOn = 0 ;  // Dev Note: Clay 9254
		this.defaultPasswordForNewUsers = "" ;  // Dev Note: Clay 9254
		this.passwordKey = "" ;  // Dev Note: Clay 9254
		this.LoginAndPasswordChangeMsg = "" ;  // Dev Note: Milan 9879
		this.changePasswordScreenMsg = "" ;  // Dev Note: Milan 9879
		this.separateIdPasswordEmail = 0;   // Dev NoteL Kal 52846
		this.MultiDistributorBB = "0" ;  //  Dev Note:  MarkS 10055
		this.Use_Different_From_Address = "0" ;  // BJF D10644
		this.Different_From_Address = "" ;  // BJF D10644
		this.Display_Only_Billback_Parent = 0;
	</cfscript>

	<!--- 5  --->	 <!---BJF Email settings --->
	<cfset this.Email_Auto_Renewed_Programs = 0>
	<cfset this.Notify_RSP_Only_NotAllHQUser = 0>
	<cfset this.Send_RFA_Agree_Emails_To_CRA_Users = 0>

	<!--- 6  --->	 <!---BSD Margin Page settings --->
	<cfscript>
		this.marginColHeader1 = "" ;
		this.marginColHeader2 = "" ;
		this.marginColHeader3 = "" ;
		this.marginColHeader4 = "" ;
		this.marginColHeader5 = "" ;
		this.marginColHeader6 = "" ;
		this.marginColHeader7 = "" ;
		this.marginColHeader8 = "" ;
		this.marginColHeader9 = "" ;
		this.marginColHeader10= "" ;
		this.marginColHeader11 = "" ;
		this.marginColHeader12 = "" ;
		this.marginColHeader13 = "" ;
		this.marginColHeader14 = "" ;
		this.marginColHeader15 = "" ;   // 16314 --->
		this.marginColHeader16 = "" ;   // 20537 --->
		this.marginColHeader17 = "" ;   // 20537 --->
		this.MarginColHeader18 = "" ;   // 24130 --->
		this.MarginColHeader19 = "" ;   // 24130 --->
		this.MarginColHeader20 = "" ;   //  --->
		this.MarginColHeader21 = "" ;   //  --->
		this.marginColHeader22 = "";
		this.marginColHeader23 = "";
        //65744 START
        this.marginColHeader24 = "";
		this.marginColHeader25 = "";
        //65744 END
    this.marginColHeader26="" ;//76537
    
    this.marginCostColHeader1 = "" ;
		this.marginCostColHeader2 = "" ;
		this.marginCostColHeader3 = "" ;
		this.marginCostColHeader4 = "" ;
		this.marginCostColHeader5 = "" ;
		//D42028	Cost fields in Huhtamaki stage: re-label and remove ones not using
		this.marginCostColHeader6 = "" ;
		this.marginCostColHeader7 = "" ;
		this.marginCostColHeader8 = "" ;
		this.marginCostColHeader1_delete = "" ;
		this.marginCostColHeader2_delete = "" ;
		this.marginCostColHeader3_delete = "" ;
		this.marginCostColHeader4_delete = "" ;
		this.marginCostColHeader5_delete = "" ;
		this.marginCostColHeader6_delete = "" ;
		this.marginCostColHeader7_delete = "" ;
		this.marginCostColHeader8_delete = "" ;
		//D42028	Cost fields in Huhtamaki stage: re-label and remove ones not using
	</cfscript>

	<!------ 15 ----->	<!--- Dev Note: KAL; 19440: Approval via Email --->
	<cfscript>
		this.pinMinLength = 0 ;
		this.emailOutJobTime = "" ;
		this.emailOutJobSuccess = "";
		this.emailInJobInterval = 0;
		this.emailInJobSuccess = "";
		this.emailApprovalInstructions = "";
	</cfscript>

	<!--- Dev Notes: 21554/KAL/30-Apr-10 HZ - Single sign on to application using LDAP --->
	<cfscript>
		this.LDAP_SSO_Enabled = 0 ;
		this.LDAP_Server = "" ;
		this.LDAP_Read_Username = "" ;
		this.LDAP_Read_Password = "" ;
		this.LDAP_Port = "" ;
		this.LDAP_SSL_Port = "" ;
		this.LDAP_Org_Name = "" ;
		this.LDAP_Org_Unit_Name = "" ;
		this.LDAP_Issue_Message = "" ;
		this.LDAP_New_User_Message = "" ;
		this.BB_Count_Indicator = "Distributor";   // 34665
	</cfscript>

	<!--- Generic --->
	<cfscript>
		this.updatedBy = "" ;
		this.updatedByUserName = "" ;
		this.updatedOn = "" ;
	</cfscript>

	<cffunction name="init" output="false" returntype="components.settings.ApplicationSettings">
		<cfreturn this />
	</cffunction>

	<!--- handle Auto Renew at RFA--->
	<cffunction name="setStartAutoRenewAtRFA" output="false" returntype="void" access="public">
		<cfargument name="startAutoRenewAtRFA" type="boolean" required="true">
		<cfset this.startAutoRenewAtRFA = arguments.startAutoRenewAtRFA />
	</cffunction>

	<cffunction name="getStartAutoRenewAtRFA" output="false" access="public" returntype="boolean">
		<cfreturn this.startAutoRenewAtRFA />
	</cffunction>

	<!--- handle disable group search in product search --->
	<cffunction name="setDisableGroupProductSearchINproductSearch" output="false" returntype="void" access="public">
		<cfargument name="disableGroupProductSearchINproductSearch" type="boolean" required="true">
		<cfset this.disableGroupProductSearchINproductSearch = arguments.disableGroupProductSearchINproductSearch />
	</cffunction>

	<cffunction name="getDisableGroupProductSearchINproductSearch" output="false" access="public" returntype="boolean">
		<cfreturn this.disableGroupProductSearchINproductSearch />
	</cffunction>

	<!--- TrafficInfoDays setter --->
	<cffunction name="setTrafficInfoDays" access="public" output="false">
		<cfargument name="TrafficInfoDays" type="numeric" required="true" />
		<cfset this.TrafficInfoDays = arguments.TrafficInfoDays />
	</cffunction>

	<!--- TrafficInfoDays Getter --->
	<cffunction name="getTrafficInfoDays" access="public" returntype="numeric" output="false">
		<cfreturn this.TrafficInfoDays />
	</cffunction>

	<!--- DollarGrowth setter --->
	<cffunction name="setDollarGrowth" access="public" output="false">
		<cfargument name="DollarGrowth" type="boolean" required="true" />
		<cfset this.DollarGrowth = arguments.DollarGrowth />
	</cffunction>

	<!--- DollarGrowth getter --->
	<cffunction name="getDollarGrowth" access="public" returntype="boolean" output="false">
		<cfreturn this.DollarGrowth />
	</cffunction>

	<!--- leadTime setter --->
	<cffunction name="setProgramInterfaceBuffer" access="public" output="false">
		<cfargument name="programInterfaceBuffer" type="numeric" required="true" />
		<cfset this.programInterfaceBuffer = arguments.programInterfaceBuffer />
	</cffunction>

	<!--- leadTime getter --->
	<cffunction name="getProgramInterfaceBuffer" access="public" returntype="string" output="false">
		<cfreturn this.programInterfaceBuffer />
	</cffunction>

	<!--- No. of days to allow a profile to take action setter --->
	<cffunction name="setawaitingactiondays" access="public" output="false">
		<cfargument name="awaitingactiondays" type="numeric" required="true" />
		<cfset this.awaitingactiondays = arguments.awaitingactiondays />
	</cffunction>

	<!--- No. of days to allow a profile to take action getter --->
	<cffunction name="getawaitingactiondays" access="public" returntype="string" output="false">
		<cfreturn this.awaitingactiondays />
	</cffunction>

	<!--- Whether the new growth modification doen for Heinz is on or off --->
	<cffunction name="setGrowthExpansion1" access="public" output="false">
		<cfargument name="growthExpansion1" type="numeric" required="true" />
		<cfset this.growthExpansion1 = arguments.growthExpansion1 />
	</cffunction>

	<!--- Whether the new growth modification doen for Heinz is on or off --->
	<cffunction name="getGrowthExpansion1" access="public" returntype="string" output="false">
		<cfreturn this.growthExpansion1 />
	</cffunction>

	<!--- UseXMaterial setter --->
	<cffunction name="setUseXMaterial" access="public" output="false">
		<cfargument name="UseXMaterial" type="boolean" required="true" />
		<cfset this.UseXMaterial = arguments.UseXMaterial />
	</cffunction>

	<!--- UseXMaterial getter --->
	<cffunction name="getUseXMaterial" access="public" returntype="boolean" output="false">
		<cfreturn this.UseXMaterial />
	</cffunction>

	<!--- ProductGroup1 setter --->
	<cffunction name="setUseProductGroup1" access="public" output="false">
		<cfargument name="useProductGroup1" type="boolean" required="true" />
		<cfset this.useProductGroup1 = arguments.useProductGroup1 />
	</cffunction>

	<!--- ProductGroup1 getter --->
	<cffunction name="getUseProductGroup1" access="public" returntype="boolean" output="false">
		<cfreturn this.useProductGroup1 />
	</cffunction>

	<!--- ProductGroup2 setter --->
	<cffunction name="setUseProductGroup2" access="public" output="false">
		<cfargument name="useProductGroup2" type="boolean" required="true" />
		<cfset this.useProductGroup2 = arguments.useProductGroup2 />
	</cffunction>

	<!--- ProductGroup2 getter --->
	<cffunction name="getUseProductGroup2" access="public" returntype="boolean" output="false">
		<cfreturn this.useProductGroup2 />
	</cffunction>

	<!--- ProductGroup3 setter --->
	<cffunction name="setUseProductGroup3" access="public" output="false">
		<cfargument name="useProductGroup3" type="boolean" required="true" />
		<cfset this.useProductGroup3 = arguments.useProductGroup3 />
	</cffunction>

	<!--- ProductGroup3 getter --->
	<cffunction name="getUseProductGroup3" access="public" returntype="boolean" output="false">
		<cfreturn this.useProductGroup3 />
	</cffunction>

	<!--- ProductGroup4 setter --->
	<cffunction name="setUseProductGroup4" access="public" output="false">
		<cfargument name="useProductGroup4" type="boolean" required="true" />
		<cfset this.useProductGroup4 = arguments.useProductGroup4 />
	</cffunction>

	<!--- ProductGroup4 getter --->
	<cffunction name="getUseProductGroup4" access="public" returntype="boolean" output="false">
		<cfreturn this.useProductGroup4 />
	</cffunction>

	<!--- ProductGroup5 setter --->
	<cffunction name="setUseProductGroup5" access="public" output="false">
		<cfargument name="useProductGroup5" type="boolean" required="true" />
		<cfset this.useProductGroup5 = arguments.useProductGroup5 />
	</cffunction>

	<!--- ProductGroup5 getter --->
	<cffunction name="getUseProductGroup5" access="public" returntype="boolean" output="false">
		<cfreturn this.useProductGroup5 />
	</cffunction>

	<!--- ProductHierarchy setter --->
	<cffunction name="setUseProductHierarchy" access="public" output="false">
		<cfargument name="useProductHierarchy" type="boolean" required="true" />
		<cfset this.useProductHierarchy = arguments.useProductHierarchy />
	</cffunction>

	<!--- ProductHierarchy getter --->
	<cffunction name="getUseProductHierarchy" access="public" returntype="boolean" output="false">
		<cfreturn this.useProductHierarchy />
	</cffunction>

	<!--- appSettingsOnForAll setter --->
	<cffunction name="setAppSettingsOnForAll" access="public" output="false">
		<cfargument name="appSettingsOnForAll" type="boolean" required="true" />
		<cfset this.appSettingsOnForAll = arguments.appSettingsOnForAll />
	</cffunction>

	<!--- appSettingsOnForAll getter --->
	<cffunction name="getAppSettingsOnForAll" access="public" returntype="boolean" output="false">
		<cfreturn this.appSettingsOnForAll />
	</cffunction>

	<!--- sendAutoAttachments setter --->
	<cffunction name="setSendAutoAttachments" access="public" output="false">
		<cfargument name="sendAutoAttachments" type="boolean" required="true" />
		<cfset this.sendAutoAttachments = arguments.sendAutoAttachments />
	</cffunction>

	<!--- sendAutoAttachments getter --->
	<cffunction name="getSendAutoAttachments" access="public" returntype="boolean" output="false">
		<cfreturn this.sendAutoAttachments />
	</cffunction>

	<!--- AutoBroker setter --->
	<cffunction name="setAutoBroker" access="public" output="false">
		<cfargument name="autoBroker" type="boolean" required="true" />
		<cfset this.autoBroker = arguments.autoBroker />
	</cffunction>

	<!--- autoBroker getter --->
	<cffunction name="getAutoBroker" access="public" returntype="boolean" output="false">
		<cfreturn this.autoBroker />
	</cffunction>

	<!--- rfaAgree setter --->
	<cffunction name="setRfaAgree" access="public" output="false">
		<cfargument name="rfaAgree" type="boolean" required="true" />
		<cfset this.rfaAgree = arguments.rfaAgree />
	</cffunction>

	<!--- rfaAgree getter --->
	<cffunction name="getRfaAgree" access="public" returntype="boolean" output="false">
		<cfreturn this.rfaAgree />
	</cffunction>

	<!--- Customertype setter --->
	<cffunction name="setCustomertype" access="public" output="false">
		<cfargument name="customertype" type="boolean" required="true" />
		<cfset this.customertype = arguments.customertype />
	</cffunction>

	<!--- Customertype getter --->
	<cffunction name="getCustomertype" access="public" returntype="boolean" output="false">
		<cfreturn this.customertype />
	</cffunction>

	<!--- restrictProductUOM setter --->
	<cffunction name="setRestrictProductUOM" access="public" output="false">
		<cfargument name="restrictProductUOM" type="boolean" required="true" />
		<cfset this.restrictProductUOM = arguments.restrictProductUOM />
	</cffunction>

	<!--- restrictProductUOM getter --->
	<cffunction name="getRestrictProductUOM" access="public" returntype="boolean" output="false">
		<cfreturn this.restrictProductUOM />
	</cffunction>

	<!--- rebateMaxComponents setter --->
	<cffunction name="setRebateMaxComponents" access="public" output="false">
		<cfargument name="rebateMaxComponents" type="numeric" required="true" />
		<cfset this.rebateMaxComponents = arguments.rebateMaxComponents />
	</cffunction>

	<!--- rebateMaxComponents getter --->
	<cffunction name="getRebateMaxComponents" access="public" returntype="numeric" output="false">
		<cfreturn this.rebateMaxComponents />
	</cffunction>

	<!--- labelnotes setter --->
	<cffunction name="setLabelNotes" access="public" output="false">
		<cfargument name="LabelNotes" type="string" required="true" />
		<cfset this.LabelNotes = arguments.LabelNotes />
	</cffunction>

	<!--- labelnotes getter --->
	<cffunction name="getLabelNotes" access="public" returntype="string" output="false">
		<cfreturn this.LabelNotes />
	</cffunction>

	<!--- FloorPrice setter --->
	<cffunction name="setFloorPrice" access="public" output="false">
		<cfargument name="FloorPrice" type="string" required="true" />
		<cfset this.FloorPrice = arguments.FloorPrice />
	</cffunction>

	<!--- FloorPrice getter --->
	<cffunction name="getFloorPrice" access="public" returntype="string" output="false">
		<cfreturn this.FloorPrice />
	</cffunction>

	<!--- Allow Navigate setter --->
	<cffunction name="setAllowNavigate" access="public" output="false">
		<cfargument name="AllowNavigate" type="boolean" required="true" />
		<cfset this.AllowNavigate = arguments.AllowNavigate />
	</cffunction>

	<!--- Allow Navigate getter --->
	<cffunction name="getAllowNavigate" access="public" returntype="boolean" output="false">
		<cfreturn this.AllowNavigate />
	</cffunction>

	<!--- programnotesrequired --->
	<cffunction name="setprogramnotesrequired" access="public" output="false">
		<cfargument name="programnotesrequired" type="boolean" required="true" />
		<cfset this.programnotesrequired = arguments.programnotesrequired />
	</cffunction>

	<cffunction name="getprogramnotesrequired" access="public" returntype="boolean" output="false">
		<cfreturn this.programnotesrequired />
	</cffunction>

	<!--- lumpMultipleProducts setter --->
	<cffunction name="setLumpMultipleProducts" access="public" output="false">
		<cfargument name="lumpMultipleProducts" type="boolean" required="true" />
		<cfset this.lumpMultipleProducts = arguments.lumpMultipleProducts />
	</cffunction>

	<!--- lumpMultipleProducts getter --->
	<cffunction name="getLumpMultipleProducts" access="public" returntype="boolean" output="false">
		<cfreturn this.lumpMultipleProducts />
	</cffunction>

	<!--- Equipment_Placement setter --->
	<cffunction name="setEquipment_Placement" access="public" output="false">
		<cfargument name="Equipment_Placement" type="boolean" required="true" />
		<cfset this.Equipment_Placement = arguments.Equipment_Placement />
	</cffunction>

	<!--- lumpMultipleProducts getter --->
	<cffunction name="getEquipment_Placement" access="public" returntype="boolean" output="false">
		<cfreturn this.Equipment_Placement />
	</cffunction>

	<!--- Send_Approved_Programs_EmailAdress setter --->
	<cffunction name="setSendApprovedProgramsEmailAdress" access="public" output="false">
		<cfargument name="Send_Approved_Programs_EmailAdress" type="string" required="true" />
		<cfset this.Send_Approved_Programs_EmailAdress = arguments.Send_Approved_Programs_EmailAdress />
	</cffunction>

	<!--- Send_Approved_Programs_EmailAdress getter --->
	<cffunction name="getSendApprovedProgramsEmailAdress" access="public" returntype="string" output="false">
		<cfreturn this.Send_Approved_Programs_EmailAdress />
	</cffunction>

	<!--- Only_Notify_RSP_Of_Approval setter --->
	<cffunction name="setOnly_Notify_RSP_Of_Approval" access="public" output="false">
		<cfargument name="Only_Notify_RSP_Of_Approval" type="string" required="true" />
		<cfset this.Only_Notify_RSP_Of_Approval = arguments.Only_Notify_RSP_Of_Approval />
	</cffunction>

	<!--- Send_Approved_Programs_EmailAdress getter --->
	<cffunction name="getOnly_Notify_RSP_Of_Approval" access="public" returntype="string" output="false">
		<cfreturn this.Only_Notify_RSP_Of_Approval />
	</cffunction>

	<!--- Classcodes_On setter --->
	<cffunction name="setClasscodesOn" access="public" output="false">
		<cfargument name="Classcodes_On" type="boolean" required="true" />
		<cfset this.Classcodes_On = arguments.Classcodes_On />
	</cffunction>

	<!--- Classcodes_On getter --->
	<cffunction name="getClasscodesOn" access="public" returntype="boolean" output="false">
		<cfreturn this.Classcodes_On />
	</cffunction>

	<!--- Send Email to Secondary Positions- Status change Notification--->
	<cffunction name="setsendsecondaryemail" access="public" output="false">
		<cfargument name="send_secondary_email" type="boolean" required="true" />
		<cfset this.send_secondary_email = arguments.send_secondary_email />
	</cffunction>

	<!--- Send Email to Secondary Positions - Status change Notification --->
	<cffunction name="getsendsecondaryemail" access="public" returntype="boolean" output="false">
		<cfreturn this.send_secondary_email />
	</cffunction>

	<!--- fixedcomponents_on setter --->
	<cffunction name="setfixedcomponents_on" access="public" output="false">
		<cfargument name="fixedcomponents_on" type="boolean" required="true" />
		<cfset this.fixedcomponents_on = arguments.fixedcomponents_on />
	</cffunction>

	<!--- fixedcomponents_on getter --->
	<cffunction name="getfixedcomponents_on" access="public" returntype="boolean" output="false">
		<cfreturn this.fixedcomponents_on />
	</cffunction>

	<!--- rolloverprograms_on  setter --->
	<cffunction name="setrolloverprograms_on" access="public" output="false">
		<cfargument name="rolloverprograms_on" type="boolean" required="true" />
		<cfset this.rolloverprograms_on = arguments.rolloverprograms_on />
	</cffunction>

	<!--- rolloverprograms_on  getter --->
	<cffunction name="getrolloverprograms_on" access="public" returntype="boolean" output="false">
		<cfreturn this.rolloverprograms_on />
	</cffunction>

	<!--- forbidAllowProfilesInTemplates  setter --->
	<cffunction name="setForbidAllowProfilesInTemplates" access="public" output="false">
		<cfargument name="forbidAllowProfilesInTemplates" type="boolean" required="true" />
		<cfset this.forbidAllowProfilesInTemplates = arguments.forbidAllowProfilesInTemplates />
	</cffunction>

	<!--- uploadmargintargets_on  setter --->
	<cffunction name="setuploadmargintargets_on" access="public" output="false">
		<cfargument name="uploadmargintargets_on" type="boolean" required="true" />
		<cfset this.uploadmargintargets_on = arguments.uploadmargintargets_on />
	</cffunction>

	<!--- uploadmargintargets_on  getter --->
	<cffunction name="getuploadmargintargets_on" access="public" returntype="boolean" output="false">
		<cfreturn this.uploadmargintargets_on />
	</cffunction>

	<!--- restrictAccessOnGroup  setter --->
	<cffunction name="setRestrictAccessOnGroup" access="public" output="false">
		<cfargument name="restrictAccessOnGroup" type="boolean" required="true" />
		<cfset this.restrictAccessOnGroup = arguments.restrictAccessOnGroup />
	</cffunction>

	<!--- restrictAccessOnGroup  getter --->
	<cffunction name="getRestrictAccessOnGroup" access="public" returntype="boolean" output="false">
		<cfreturn this.restrictAccessOnGroup />
	</cffunction>

	<!--- businessconsiderations_on  setter --->
	<cffunction name="setbusinessconsiderations_on" access="public" output="false">
		<cfargument name="businessconsiderations_on" type="boolean" required="true" />
		<cfset this.businessconsiderations_on = arguments.businessconsiderations_on />
	</cffunction>

	<!--- businessconsiderations_on  getter --->
	<cffunction name="getbusinessconsiderations_on" access="public" returntype="boolean" output="false">
		<cfreturn this.businessconsiderations_on />
	</cffunction>

	<!--- custid_on  setter --->
	<cffunction name="setcustid_on" access="public" output="false">
		<cfargument name="custid_on" type="boolean" required="true" />
		<cfset this.custid_on = arguments.custid_on />
	</cffunction>

	<!--- custid_on  getter --->
	<cffunction name="getcustid_on" access="public" returntype="boolean" output="false">
		<cfreturn this.custid_on />
	</cffunction>

	<!--- singlesign_on  setter --->
	<cffunction name="setsinglesign_on" access="public" output="false">
		<cfargument name="singlesign_on" type="numeric" required="true" />
		<cfset this.singlesign_on = arguments.singlesign_on />
	</cffunction>

	<!--- singlesign_on  getter --->
	<cffunction name="getsinglesign_on" access="public" returntype="numeric" output="false">
		<cfreturn this.singlesign_on />
	</cffunction>

	<!--- BB_Fixed_Calc_Types_On  setter --->
	<cffunction name="setBBFixedCalcTypesOn" access="public" output="false">
		<cfargument name="BB_Fixed_Calc_Types_On" type="boolean" required="true" />
		<cfset this.BB_Fixed_Calc_Types_On = arguments.BB_Fixed_Calc_Types_On />
	</cffunction>

	<!--- BB_Fixed_Calc_Types_On  getter --->
	<cffunction name="getBBFixedCalcTypesOn" access="public" returntype="boolean" output="false">
		<cfreturn this.BB_Fixed_Calc_Types_On />
	</cffunction>

	<!--- claimAutoPrint  setter --->
	<cffunction name="setClaimAutoPrint" access="public" output="false">
		<cfargument name="claimAutoPrint" type="boolean" required="true" />
		<cfset this.claimAutoPrint = arguments.claimAutoPrint />
	</cffunction>

	<!--- claimAutoPrint  getter --->
	<cffunction name="getClaimAutoPrint" access="public" returntype="boolean" output="false">
		<cfreturn this.claimAutoPrint />
	</cffunction>

	<!--- allowAllDistributors  setter --->
	<cffunction name="setAllowAllDistributors" access="public" output="false">
		<cfargument name="allowAllDistributors" type="boolean" required="true" />
		<cfset this.allowAllDistributors = arguments.allowAllDistributors />
	</cffunction>

	<!--- allowAllDistributors  getter --->
	<cffunction name="getAllowAllDistributors" access="public" returntype="boolean" output="false">
		<cfreturn this.allowAllDistributors />
	</cffunction>

	<!--- maxProfileCount  setter --->
	<cffunction name="setMaxProfileCount" access="public" output="false">
		<cfargument name="maxProfileCount" type="numeric" required="true" />
		<cfset this.maxProfileCount = arguments.maxProfileCount />
	</cffunction>

	<!--- maxProfileCount  getter --->
	<cffunction name="getMaxProfileCount" access="public" returntype="numeric" output="false">
		<cfreturn this.maxProfileCount />
	</cffunction>

	<!--- distributorMultiPosition  setter --->
	<cffunction name="setDistributorMultiPosition" access="public" output="false">
		<cfargument name="distributorMultiPosition" type="boolean" required="true" />
		<cfset this.distributorMultiPosition = arguments.distributorMultiPosition />
	</cffunction>

	<!--- operatorSearchRestrict  getter --->
	<cffunction name="getOperatorSearchRestrict" access="public" returntype="boolean" output="false">
		<cfreturn this.operatorSearchRestrict />
	</cffunction>

	<!--- operatorSearchRestrict  setter --->
	<cffunction name="setOperatorSearchRestrict" access="public" output="false">
		<cfargument name="operatorSearchRestrict" type="boolean" required="true" />
		<cfset this.operatorSearchRestrict = arguments.operatorSearchRestrict />
	</cffunction>

	<!--- SalesOrgOn  getter --->
	<cffunction name="getSalesOrgOn" access="public" returntype="boolean" output="false">
		<cfreturn this.SalesOrgOn />
	</cffunction>

	<!--- SalesOrgOn  setter --->
	<cffunction name="setSalesOrgOn" access="public" output="false">
		<cfargument name="SalesOrgOn" type="boolean" required="true" />
		<cfset this.SalesOrgOn = arguments.SalesOrgOn />
	</cffunction>

	<!--- DistributionChannelOn  getter --->
	<cffunction name="getDistributionChannelOn" access="public" returntype="boolean" output="false">
		<cfreturn this.DistributionChannelOn />
	</cffunction>

	<!--- DistributionChannelOn  setter --->
	<cffunction name="setDistributionChannelOn" access="public" output="false">
		<cfargument name="DistributionChannelOn" type="boolean" required="true" />
		<cfset this.DistributionChannelOn = arguments.DistributionChannelOn />
	</cffunction>

	<!--- deleteProgramMessage  getter --->
	<cffunction name="getDeleteProgramMessage" access="public" returntype="string" output="false">
		<cfreturn this.deleteProgramMessage />
	</cffunction>

	<!--- deleteProgramMessage  setter --->
	<cffunction name="setDeleteProgramMessage" access="public" output="false">
		<cfargument name="deleteProgramMessage" type="string" required="true" />
		<cfset this.deleteProgramMessage = arguments.deleteProgramMessage />
	</cffunction>

	<!--- DeleteIsCancelAutoRenew  getter --->
	<cffunction name="getDeleteIsCancelAutoRenew" access="public" returntype="boolean" output="false">
		<cfreturn this.DeleteIsCancelAutoRenew />
	</cffunction>

	<!--- DeleteIsCancelAutoRenew  setter --->
	<cffunction name="setDeleteIsCancelAutoRenew" access="public" output="false">
		<cfargument name="DeleteIsCancelAutoRenew" type="boolean" required="true" />
		<cfset this.DeleteIsCancelAutoRenew = arguments.DeleteIsCancelAutoRenew />
	</cffunction>

	<!--- cancelProgramEmail  getter --->
	<cffunction name="getCancelProgramEmail" access="public" returntype="boolean" output="false">
		<cfreturn this.cancelProgramEmail />
	</cffunction>

	<!--- cancelProgramEmail  setter --->
	<cffunction name="setCancelProgramEmail" access="public" output="false">
		<cfargument name="cancelProgramEmail" type="boolean" required="true" />
		<cfset this.cancelProgramEmail = arguments.cancelProgramEmail />
	</cffunction>

	<!--- PaymentCycleAtDiscountType  getter --->
	<cffunction name="getPaymentCycleAtDiscountType" access="public" returntype="boolean" output="false">
		<cfreturn this.PaymentCycleAtDiscountType />
	</cffunction>

	<!--- PaymentCycleAtDiscountType  setter --->
	<cffunction name="setPaymentCycleAtDiscountType" access="public" output="false">
		<cfargument name="PaymentCycleAtDiscountType" type="boolean" required="true" />
		<cfset this.PaymentCycleAtDiscountType = arguments.PaymentCycleAtDiscountType />
	</cffunction>

	<!--- Settlement_SAP_Business  getter --->
	<cffunction name="getSettlement_SAP_Business" access="public" returntype="boolean" output="false">
		<cfreturn this.Settlement_SAP_Business />
	</cffunction>

	<!--- Settlement_SAP_Business  setter --->
	<cffunction name="setSettlement_SAP_Business" access="public" output="false">
		<cfargument name="Settlement_SAP_Business" type="boolean" required="true" />
		<cfset this.Settlement_SAP_Business = arguments.Settlement_SAP_Business />
	</cffunction>

	<!--- Sysco_Report_On  getter --->
	<cffunction name="getSysco_Report_On" access="public" returntype="boolean" output="false">
		<cfreturn this.Sysco_Report_On />
	</cffunction>

	<!--- Sysco_Report_On  setter --->
	<cffunction name="setSysco_Report_On" access="public" output="false">
		<cfargument name="Sysco_Report_On" type="boolean" required="true" />
		<cfset this.Sysco_Report_On = arguments.Sysco_Report_On />
	</cffunction>

	<!--- Send_to_SAP  getter --->
	<cffunction name="getSend_to_SAP" access="public" returntype="boolean" output="false">
		<cfreturn this.Send_to_SAP />
	</cffunction>

	<!--- Send_to_SAP  setter --->
	<cffunction name="setSend_to_SAP" access="public" output="false">
		<cfargument name="Send_to_SAP" type="boolean" required="true" />
		<cfset this.Send_to_SAP = arguments.Send_to_SAP />
	</cffunction>

	<!--- templatecodes_on  getter --->
	<cffunction name="gettemplatecodes_on" access="public" returntype="boolean" output="false">
		<cfreturn this.templatecodes_on />
	</cffunction>

	<!--- templatecodes_on  setter --->
	<cffunction name="settemplatecodes_on" access="public" output="false">
		<cfargument name="templatecodes_on" type="boolean" required="true" />
		<cfset this.templatecodes_on = arguments.templatecodes_on />
	</cffunction>

	<!--- BB_Payee_Operator_Ship_To_Req  getter --->
	<cffunction name="getBB_Payee_Operator_Ship_To_Req" access="public" returntype="boolean" output="false">
		<cfreturn this.BB_Payee_Operator_Ship_To_Req />
	</cffunction>

	<!--- BB_Payee_Operator_Ship_To_Req  setter --->
	<cffunction name="setBB_Payee_Operator_Ship_To_Req" access="public" output="false">
		<cfargument name="BB_Payee_Operator_Ship_To_Req" type="boolean" required="true" />
		<cfset this.BB_Payee_Operator_Ship_To_Req = arguments.BB_Payee_Operator_Ship_To_Req />
	</cffunction>

	<!--- Vendor_Selection_Pay_Req  getter --->
	<cffunction name="getVendor_Selection_Pay_Req" access="public" returntype="boolean" output="false">
		<cfreturn this.Vendor_Selection_Pay_Req />
	</cffunction>

	<!--- Vendor_Selection_Pay_Req  setter --->
	<cffunction name="setVendor_Selection_Pay_Req" access="public" output="false">
		<cfargument name="Vendor_Selection_Pay_Req" type="boolean" required="true" />
		<cfset this.Vendor_Selection_Pay_Req = arguments.Vendor_Selection_Pay_Req />
	</cffunction>

	<cffunction name="getBillback_Payment_Request_Without_Vendor_Selection" access="public" returntype="boolean" output="false">
		<cfreturn this.Billback_Payment_Request_Without_Vendor_Selection />
	</cffunction>

	<cffunction name="setBillback_Payment_Request_Without_Vendor_Selection" access="public" output="false">
		<cfargument name="Billback_Payment_Request_Without_Vendor_Selection" type="boolean" required="true" />
		<cfset this.Billback_Payment_Request_Without_Vendor_Selection = arguments.Billback_Payment_Request_Without_Vendor_Selection />
	</cffunction>

	<cffunction name="getSkipVendorSelectionOnBBApproval" access="public" returntype="boolean" output="false">
		<cfreturn this.Skip_Vendor_Selection_On_BB_Approval />
	</cffunction>

	<cffunction name="setSkipVendorSelectionOnBBApproval" access="public" output="false">
		<cfargument name="Skip_Vendor_Selection_On_BB_Approval" type="boolean" required="true" />
		<cfset this.Skip_Vendor_Selection_On_BB_Approval = arguments.Skip_Vendor_Selection_On_BB_Approval />
	</cffunction>

	<!--- Restrict_DD_Reason_Code_By_Closing_method  getter --->
	<cffunction name="getRestrict_DD_Reason_Code_By_Closing_method" access="public" returntype="boolean" output="false">
		<cfreturn this.Restrict_DD_Reason_Code_By_Closing_method />
	</cffunction>

	<!--- Restrict_DD_Reason_Code_By_Closing_method  setter --->
	<cffunction name="setRestrict_DD_Reason_Code_By_Closing_method" access="public" output="false">
		<cfargument name="Restrict_DD_Reason_Code_By_Closing_method" type="boolean" required="true" />
		<cfset this.Restrict_DD_Reason_Code_By_Closing_method = arguments.Restrict_DD_Reason_Code_By_Closing_method />
	</cffunction>

	<!--- Multiple_BB_Per_Deduction  getter --->
	<cffunction name="getMultiple_BB_Per_Deduction" access="public" returntype="boolean" output="false">
		<cfreturn this.Multiple_BB_Per_Deduction />
	</cffunction>

	<!--- Multiple_BB_Per_Deduction  setter --->
	<cffunction name="setMultiple_BB_Per_Deduction" access="public" output="false">
		<cfargument name="Multiple_BB_Per_Deduction" type="boolean" required="true" />
		<cfset this.Multiple_BB_Per_Deduction = arguments.Multiple_BB_Per_Deduction />
	</cffunction>

	<!--- Allow_Negative_Billback  getter --->
	<cffunction name="getAllow_Negative_Billback" access="public" returntype="boolean" output="false">
		<cfreturn this.Allow_Negative_Billback />
	</cffunction>

	<!--- Allow_Negative_Billback  setter --->
	<cffunction name="setAllow_Negative_Billback" access="public" output="false">
		<cfargument name="Allow_Negative_Billback" type="boolean" required="true" />
		<cfset this.Allow_Negative_Billback = arguments.Allow_Negative_Billback />
	</cffunction>

	<!--- BB_Allow_Off_Invoice_Closing_Method  getter --->
	<cffunction name="getBB_Allow_Off_Invoice_Closing_Method" access="public" returntype="boolean" output="false">
		<cfreturn this.BB_Allow_Off_Invoice_Closing_Method />
	</cffunction>

	<!--- BB_Allow_Off_Invoice_Closing_Method  setter --->
	<cffunction name="setBB_Allow_Off_Invoice_Closing_Method" access="public" output="false">
		<cfargument name="BB_Allow_Off_Invoice_Closing_Method" type="boolean" required="true" />
		<cfset this.BB_Allow_Off_Invoice_Closing_Method = arguments.BB_Allow_Off_Invoice_Closing_Method />
	</cffunction>

	<!--- Interface_700_To_Client  getter --->
	<cffunction name="getInterface_700_To_Client" access="public" returntype="boolean" output="false">
		<cfreturn this.Interface_700_To_Client />
	</cffunction>

	<!--- Interface_700_To_Client  setter --->
	<cffunction name="setInterface_700_To_Client" access="public" output="false">
		<cfargument name="Interface_700_To_Client" type="boolean" required="true" />
		<cfset this.Interface_700_To_Client = arguments.Interface_700_To_Client />
	</cffunction>

	<!--- DD_Show_reassign  getter --->
	<cffunction name="getDD_Show_reassign" access="public" returntype="boolean" output="false">
		<cfreturn this.DD_Show_reassign />
	</cffunction>

	<!--- DD_Show_reassign  setter --->
	<cffunction name="setDD_Show_reassign" access="public" output="false">
		<cfargument name="DD_Show_reassign" type="boolean" required="true" />
		<cfset this.DD_Show_reassign = arguments.DD_Show_reassign />
	</cffunction>

	<!--- Auto_Deviation_On  getter --->
	<cffunction name="getAuto_Deviation_On" access="public" returntype="boolean" output="false">
		<cfreturn this.Auto_Deviation_On />
	</cffunction>

	<!--- Auto_Deviation_On  setter --->
	<cffunction name="setAuto_Deviation_On" access="public" output="false">
		<cfargument name="Auto_Deviation_On" type="boolean" required="true" />
		<cfset this.Auto_Deviation_On = arguments.Auto_Deviation_On />
	</cffunction>

	<!--- DD_Show_Classification  getter --->
	<cffunction name="getDD_Show_Classification" access="public" returntype="boolean" output="false">
		<cfreturn this.DD_Show_Classification />
	</cffunction>

	<!--- DD_Show_Classification  setter --->
	<cffunction name="setDD_Show_Classification" access="public" output="false">
		<cfargument name="DD_Show_Classification" type="boolean" required="true" />
		<cfset this.DD_Show_Classification = arguments.DD_Show_Classification />
	</cffunction>

	<!--- DD_Show_DeductionType  getter --->   <!---26487--->
	<cffunction name="getDD_Show_DeductionType" access="public" returntype="boolean" output="false">
		<cfreturn this.DD_Show_DeductionType />
	</cffunction>

	<!--- DD_Show_DeductionType  setter --->   <!---26487--->
	<cffunction name="setDD_Show_DeductionType" access="public" output="false">
		<cfargument name="DD_Show_DeductionType" type="boolean" required="true" />
		<cfset this.DD_Show_DeductionType = arguments.DD_Show_DeductionType />
	</cffunction>

	<!--- DD_Show_Edit_Customer_Num  getter --->
	<cffunction name="getDD_Show_Edit_Customer_Num" access="public" returntype="boolean" output="false">
		<cfreturn this.DD_Show_Edit_Customer_Num />
	</cffunction>

	<!--- DD_Show_Edit_Customer_Num  setter --->
	<cffunction name="setDD_Show_Edit_Customer_Num" access="public" output="false">
		<cfargument name="DD_Show_Edit_Customer_Num" type="boolean" required="true" />
		<cfset this.DD_Show_Edit_Customer_Num = arguments.DD_Show_Edit_Customer_Num />
	</cffunction>

	<!--- DD_Show_Create_Adjustment  getter --->
	<cffunction name="getDD_Show_Create_Adjustment" access="public" returntype="boolean" output="false">
		<cfreturn this.DD_Show_Create_Adjustment />
	</cffunction>

	<!--- DD_Show_Create_Adjustment  setter --->
	<cffunction name="setDD_Show_Create_Adjustment" access="public" output="false">
		<cfargument name="DD_Show_Create_Adjustment" type="boolean" required="true" />
		<cfset this.DD_Show_Create_Adjustment = arguments.DD_Show_Create_Adjustment />
	</cffunction>

	<!--- DD_Show_Delete  getter --->
	<cffunction name="getComponent_Product_Restrictions_On" access="public" returntype="boolean" output="false">
		<cfreturn this.Component_Product_Restrictions_On />
	</cffunction>

	<!--- Component_Product_Restrictions_On  setter --->
	<cffunction name="setComponent_Product_Restrictions_On" access="public" output="false">
		<cfargument name="Component_Product_Restrictions_On" type="boolean" required="true" />
		<cfset this.Component_Product_Restrictions_On = arguments.Component_Product_Restrictions_On />
	</cffunction>

	<!--- DD_Show_Delete  getter --->
	<cffunction name="getDD_Show_Delete" access="public" returntype="boolean" output="false">
		<cfreturn this.DD_Show_Delete />
	</cffunction>

	<!--- DD_Show_Delete  setter --->
	<cffunction name="setDD_Show_Delete" access="public" output="false">
		<cfargument name="DD_Show_Delete" type="boolean" required="true" />
		<cfset this.DD_Show_Delete = arguments.DD_Show_Delete />
	</cffunction>

	<!--- DD_Show_ReOpen  getter --->
	<cffunction name="getDD_Show_ReOpen" access="public" returntype="boolean" output="false">
		<cfreturn this.DD_Show_ReOpen />
	</cffunction>

	<!--- DD_Show_ReOpen  setter --->
	<cffunction name="setDD_Show_ReOpen" access="public" output="false">
		<cfargument name="DD_Show_ReOpen" type="boolean" required="true" />
		<cfset this.DD_Show_ReOpen = arguments.DD_Show_ReOpen />
	</cffunction>

	<!--- DD_Show_Reject  getter --->
	<cffunction name="getDD_Show_Reject" access="public" returntype="boolean" output="false">
		<cfreturn this.DD_Show_Reject />
	</cffunction>

	<!--- DD_Show_Reject  setter --->
	<cffunction name="setDD_Show_Reject" access="public" output="false">
		<cfargument name="DD_Show_Reject" type="boolean" required="true" />
		<cfset this.DD_Show_Reject = arguments.DD_Show_Reject />
	</cffunction>

	<!--- DD_Show_Program  getter --->
	<cffunction name="getDD_Show_Program" access="public" returntype="boolean" output="false">
		<cfreturn this.DD_Show_Program />
	</cffunction>

	<!--- DD_Show_Program  setter --->
	<cffunction name="setDD_Show_Program" access="public" output="false">
		<cfargument name="DD_Show_Program" type="boolean" required="true" />
		<cfset this.DD_Show_Program = arguments.DD_Show_Program />
	</cffunction>

	<!--- DD_Show_Invoices  getter --->
	<cffunction name="getDD_Show_Invoices" access="public" returntype="boolean" output="false">
		<cfreturn this.DD_Show_Invoices />
	</cffunction>

	<!--- DD_Show_Invoices  setter --->
	<cffunction name="setDD_Show_Invoices" access="public" output="false">
		<cfargument name="DD_Show_Invoices" type="boolean" required="true" />
		<cfset this.DD_Show_Invoices = arguments.DD_Show_Invoices />
	</cffunction>

	<!--- D29481:Non trade deductions START--->
	<!--- DD_Allow_Non_Trade  getter --->
	<cffunction name="getDD_Allow_Non_Trade" access="public" returntype="boolean" output="false">
		<cfreturn this.DD_Allow_Non_Trade />
	</cffunction>

	<!--- DD_Allow_Non_Trade  setter --->
	<cffunction name="setDD_Allow_Non_Trade" access="public" output="false">
		<cfargument name="DD_Allow_Non_Trade" type="boolean" required="true" />
		<cfset this.DD_Allow_Non_Trade = arguments.DD_Allow_Non_Trade />
	</cffunction>
	<!--- D29481:Non trade deductions END--->

	<!--- ERP_Deal_ID_PopUp  getter --->
	<cffunction name="getERP_Deal_ID_PopUp" access="public" returntype="boolean" output="false">
		<cfreturn this.ERP_Deal_ID_PopUp />
	</cffunction>

	<!--- ERP_Deal_ID_PopUp  setter --->
	<cffunction name="setERP_Deal_ID_PopUp" access="public" output="false">
		<cfargument name="ERP_Deal_ID_PopUp" type="boolean" required="true" />
		<cfset this.ERP_Deal_ID_PopUp = arguments.ERP_Deal_ID_PopUp />
	</cffunction>

	<!--- BB_Allow_UnKnow_Program_Creation getter --->
	<cffunction name="getBB_Allow_UnKnow_Program_Creation" access="public" returntype="boolean" output="false">
		<cfreturn this.BB_Allow_UnKnow_Program_Creation />
	</cffunction>

	<!--- BB_Allow_UnKnow_Program_Creation  setter --->
	<cffunction name="setBB_Allow_UnKnow_Program_Creation" access="public" output="false">
		<cfargument name="BB_Allow_UnKnow_Program_Creation" type="boolean" required="true" />
		<cfset this.BB_Allow_UnKnow_Program_Creation = arguments.BB_Allow_UnKnow_Program_Creation />
	</cffunction>

	<!--- BB_Pay_Req_Dup_Check --->
	<cffunction name="getBB_Pay_Req_Dup_Check" access="public" returntype="boolean" output="false">
		<cfreturn this.BB_Pay_Req_Dup_Check />
	</cffunction>

	<!--- BB_Pay_Req_Dup_Check --->
	<cffunction name="setBB_Pay_Req_Dup_Check" access="public" output="false">
		<cfargument name="BB_Pay_Req_Dup_Check" type="boolean" required="true" />
		<cfset this.BB_Pay_Req_Dup_Check = arguments.BB_Pay_Req_Dup_Check />
	</cffunction>

	<!--- BJF: Removed with label 13333
	<!--- Template_Notes_Availability --->
	<cffunction name="getTemplate_Notes_Availability" access="public" returntype="boolean" output="false">
		<cfreturn this.Template_Notes_Availability />
	</cffunction>

	<!--- Template_Notes_Availability --->
	<cffunction name="setTemplate_Notes_Availability" access="public" output="false">
		<cfargument name="Template_Notes_Availability" type="boolean" required="true" />
		<cfset this.Template_Notes_Availability = arguments.Template_Notes_Availability />
	</cffunction>
	--->

	<!--- Match_BB_DD_Based_On_Same_ReferenceNum  getter --->
	<cffunction name="getMatch_BB_DD_Based_On_Same_ReferenceNum" access="public" returntype="boolean" output="false">
		<cfreturn this.Match_BB_DD_Based_On_Same_ReferenceNum />
	</cffunction>

	<!--- Match_BB_DD_Based_On_Same_ReferenceNum  setter --->
	<cffunction name="setMatch_BB_DD_Based_On_Same_ReferenceNum" access="public" output="false">
		<cfargument name="Match_BB_DD_Based_On_Same_ReferenceNum" type="boolean" required="true" />
		<cfset this.Match_BB_DD_Based_On_Same_ReferenceNum = arguments.Match_BB_DD_Based_On_Same_ReferenceNum />
	</cffunction>

	<!--- business_segment_label  getter --->
	<cffunction name="getbusiness_segment_label" access="public" returntype="string" output="false">
		<cfreturn this.business_segment_label />
	</cffunction>

	<!--- business_segment_label  setter --->
	<cffunction name="setbusiness_segment_label" access="public" output="false">
		<cfargument name="business_segment_label" type="string" required="true" />
		<cfset this.business_segment_label = arguments.business_segment_label />
	</cffunction>

	<!--- Integation_Instance_ID  getter --->
	<cffunction name="getintegation_Instance_ID" access="public" returntype="string" output="false">
		<cfreturn this.Integation_Instance_ID />
	</cffunction>

	<!--- Integation_Instance_ID  setter --->
	<cffunction name="setintegation_Instance_ID" access="public" output="false">
		<cfargument name="Integation_Instance_ID" type="string" required="true" />
		<cfset this.Integation_Instance_ID = arguments.Integation_Instance_ID />
	</cffunction>

	<!--- BB_Ref_Num_Max_Length  getter --->
	<cffunction name="getBB_Ref_Num_Max_Length" access="public" returntype="string" output="false">
		<cfreturn this.BB_Ref_Num_Max_Length />
	</cffunction>

	<!--- Integation_Instance_ID  setter --->
	<cffunction name="setBB_Ref_Num_Max_Length" access="public" output="false">
		<cfargument name="BB_Ref_Num_Max_Length" type="string" required="true" />
		<cfset this.BB_Ref_Num_Max_Length = arguments.BB_Ref_Num_Max_Length />
	</cffunction>

	<!--- BB_2Ref_Num_Max_Length  getter --->
	<cffunction name="getBB_2Ref_Num_Max_Length" access="public" returntype="string" output="false">
		<cfreturn this.BB_2Ref_Num_Max_Length />
	</cffunction>

	<!--- BB_2Ref_Num_Max_Length  setter --->
	<cffunction name="setBB_2Ref_Num_Max_Length" access="public" output="false">
		<cfargument name="BB_2Ref_Num_Max_Length" type="string" required="true" />
		<cfset this.BB_2Ref_Num_Max_Length = arguments.BB_2Ref_Num_Max_Length />
	</cffunction>

	<!---lob_label  getter --->
	<cffunction name="getlob_label" access="public" returntype="string" output="false">
		<cfreturn this.lob_label />
	</cffunction>

	<!--- lob_label  setter --->
	<cffunction name="setlob_label" access="public" output="false">
		<cfargument name="lob_label" type="string" required="true" />
		<cfset this.lob_label = arguments.lob_label />
	</cffunction>

	<!--- distributorMultiPosition  getter --->
	<cffunction name="getDistributorMultiPosition" access="public" returntype="boolean" output="false">
		<cfreturn this.distributorMultiPosition />
	</cffunction>

	<!--- forbidAllowProfilesInTemplates  getter --->
	<cffunction name="getForbidAllowProfilesInTemplates" access="public" returntype="boolean" output="false">
		<cfreturn this.forbidAllowProfilesInTemplates />
	</cffunction>

	<!--- approvalPoundMarginOn  setter --->
	<cffunction name="setApprovalPoundMarginOn" access="public" output="false">
		<cfargument name="approvalPoundMarginOn" type="boolean" required="true" />
		<cfset this.approvalPoundMarginOn = arguments.approvalPoundMarginOn />
	</cffunction>

	<!--- approvalPoundMarginOn  getter --->
	<cffunction name="getApprovalPoundMarginOn" access="public" returntype="boolean" output="false">
		<cfreturn this.approvalPoundMarginOn />
	</cffunction>

	<!--- approvalPercentMarginOn  setter --->
	<cffunction name="setApprovalPercentMarginOn" access="public" output="false">
		<cfargument name="approvalPercentMarginOn" type="boolean" required="true" />
		<cfset this.approvalPercentMarginOn = arguments.approvalPercentMarginOn />
	</cffunction>

	<!--- approvalPercentMarginOn  getter --->
	<cffunction name="getApprovalPercentMarginOn" access="public" returntype="boolean" output="false">
		<cfreturn this.approvalPercentMarginOn />
	</cffunction>

	<!--- approvalTotalPgmMarginOn  setter --->
	<cffunction name="setApprovalTotalPgmMarginOn" access="public" output="false">
		<cfargument name="approvalTotalPgmMarginOn" type="boolean" required="true" />
		<cfset this.approvalTotalPgmMarginOn = arguments.approvalTotalPgmMarginOn />
	</cffunction>

	<!--- approvalTotalPgmMarginOn  getter --->
	<cffunction name="getApprovalTotalPgmMarginOn" access="public" returntype="boolean" output="false">
		<cfreturn this.approvalTotalPgmMarginOn />
	</cffunction>

	<!--- approvalSpendingCapOn  setter --->
	<cffunction name="setApprovalSpendingCapOn" access="public" output="false">
		<cfargument name="approvalSpendingCapOn" type="boolean" required="true" />
		<cfset this.approvalSpendingCapOn = arguments.approvalSpendingCapOn />
	</cffunction>

	<!--- approvalSpendingCapOn  getter --->
	<cffunction name="getApprovalSpendingCapOn" access="public" returntype="boolean" output="false">
		<cfreturn this.approvalSpendingCapOn />
	</cffunction>

	<!--- approvalLayeredOn  setter --->
	<cffunction name="setApprovalLayeredOn" access="public" output="false">
		<cfargument name="approvalLayeredOn" type="boolean" required="true" />
		<cfset this.approvalLayeredOn = arguments.approvalLayeredOn />
	</cffunction>

	<!--- approvalLayeredOn  getter --->
	<cffunction name="getApprovalLayeredOn" access="public" returntype="boolean" output="false">
		<cfreturn this.approvalLayeredOn />
	</cffunction>

	<!--- approvalDisposableOn  setter --->
	<cffunction name="setApprovalDisposableOn" access="public" output="false">
		<cfargument name="ApprovalDisposableOn" type="boolean" required="true" />
		<cfset this.ApprovalDisposableOn = arguments.ApprovalDisposableOn />
	</cffunction>

	<!--- approvalLayeredOn  getter --->
	<cffunction name="getApprovalDisposableOn" access="public" returntype="boolean" output="false">
		<cfreturn this.ApprovalDisposableOn />
	</cffunction>

	<!--- approvalStandardOn  setter --->
	<cffunction name="setapprovalStandardOn" access="public" output="false">
		<cfargument name="approvalStandardOn" type="boolean" required="true" />
		<cfset this.approvalStandardOn = arguments.approvalStandardOn />
	</cffunction>

	<!--- approvalStandardOn  getter --->
	<cffunction name="getapprovalStandardOn" access="public" returntype="boolean" output="false">
		<cfreturn this.approvalStandardOn />
	</cffunction>

	<!--- approvalLayeredCosts  setter --->
	<cffunction name="setapprovalLayeredCosts" access="public" output="false">
		<cfargument name="approvalLayeredCosts" type="numeric" required="true" />
		<cfset this.approvalLayeredCosts = arguments.approvalLayeredCosts />
	</cffunction>

	<!--- approvalLayeredOn  getter --->
	<cffunction name="getapprovalLayeredCosts" access="public" returntype="numeric" output="false">
		<cfreturn this.approvalLayeredCosts />
	</cffunction>

	<!--- updatedBy setter --->
	<cffunction name="setUpdatedBy" access="public" output="false">
		<cfargument name="updatedBy" type="string" required="true" />
		<cfset this.updatedBy = arguments.updatedBy />
	</cffunction>

	<!--- updatedBy getter --->
	<cffunction name="getUpdatedBy" access="public" returntype="string" output="false">
		<cfreturn this.updatedBy />
	</cffunction>

	<!--- updatedByUserName setter --->
	<cffunction name="setUpdatedByUserName" access="public" output="false">
		<cfargument name="updatedByUserName" type="string" required="true" />
		<cfset this.updatedByUserName = arguments.updatedByUserName />
	</cffunction>

	<!--- updatedByUserName getter --->
	<cffunction name="getUpdatedByUserName" access="public" returntype="string" output="false">
		<cfreturn this.updatedByUserName />
	</cffunction>

	<!--- updatedOn setter --->
	<cffunction name="setUpdatedOn" access="public" output="false">
		<cfargument name="updatedOn" type="string" required="true" />
		<cfset this.updatedOn = arguments.updatedOn />
	</cffunction>

	<!--- updatedOn getter --->
	<cffunction name="getUpdatedOn" access="public" returntype="string" output="false">
		<cfreturn this.updatedOn />
	</cffunction>

	<!--- allowMultiLevelGroups setter --->
	<cffunction name="setAllowMultiLevelGroups" access="public" output="false">
		<cfargument name="allowMultiLevelGroups" type="numeric" required="true" default="0" />
		<cfset this.allowMultiLevelGroups = arguments.allowMultiLevelGroups />
	</cffunction>

	<!--- allowMultiLevelGroups getter --->
	<cffunction name="getAllowMultiLevelGroups" access="public" returntype="numeric" output="false">
		<cfreturn this.allowMultiLevelGroups />
	</cffunction>

	<!--- ProgramAgreeEscalate setter --->
	<cffunction name="setProgramAgreeEscalate" access="public" output="false">
		<cfargument name="ProgramAgreeEscalate" type="numeric" required="true" default="0" />
		<cfset this.ProgramAgreeEscalate = arguments.ProgramAgreeEscalate />
	</cffunction>

	<!--- ProgramAgreeEscalate getter --->
	<cffunction name="getProgramAgreeEscalate" access="public" returntype="numeric" output="false">
		<cfreturn this.ProgramAgreeEscalate />
	</cffunction>

	<!--- checkOrderClass setter --->
	<cffunction name="setCheckOrderClass" access="public" output="false">
		<cfargument name="checkOrderClass" type="numeric" required="true" default="0" />
		<cfset this.checkOrderClass = arguments.checkOrderClass />
	</cffunction>

	<!--- checkOrderClass getter --->
	<cffunction name="getCheckOrderClass" access="public" returntype="numeric" output="false">
		<cfreturn this.checkOrderClass />
	</cffunction>

	<!--- OrderClassValue setter --->
	<cffunction name="setOrderClassValue" access="public" output="false">
		<cfargument name="OrderClassValue" type="string" required="true" default="0" />
		<cfset this.OrderClassValue = arguments.OrderClassValue />
	</cffunction>

	<!--- OrderClassValue getter --->
	<cffunction name="getOrderClassValue" access="public" returntype="string" output="false">
		<cfreturn this.OrderClassValue />
	</cffunction>

	<!--- userNumberRestrict setter --->
	<cffunction name="setUserNumberRestrict" access="public" output="false">
		<cfargument name="userNumberRestrict" type="numeric" required="true" default="0" />
		<cfset this.userNumberRestrict = arguments.userNumberRestrict />
	</cffunction>

	<!--- userNumberRestrict getter --->
	<cffunction name="getUserNumberRestrict" access="public" returntype="numeric" output="false">
		<cfreturn this.userNumberRestrict />
	</cffunction>

	<!--- USDANOIEnabled setter --->
	<cffunction name="setUSDANOIEnabled" access="public" output="false">
		<cfargument name="USDANOIEnabled" type="numeric" required="true" default="0" />
		<cfset this.USDANOIEnabled = arguments.USDANOIEnabled />
	</cffunction>

	<!--- userNumberRestrict getter --->
	<cffunction name="getUSDANOIEnabled" access="public" returntype="numeric" output="false">
		<cfreturn this.USDANOIEnabled />
	</cffunction>

	<!--- ProductByProgramOn getter --->
	<cffunction name="setProductSearchGetProductByProgramOn" access="public" output="false">
		<cfargument name="productSearchGetProductByProgramOn" type="numeric" required="true" default="0" />
		<cfset this.productSearchGetProductByProgramOn = arguments.productSearchGetProductByProgramOn />
	</cffunction>

	<!--- ProductByProgramOn setter --->
	<cffunction name="getProductSearchGetProductByProgramOn" access="public" output="false">
		<cfreturn this.productSearchGetProductByProgramOn/>
	</cffunction>

	<!--- invoiceBrokerFilterRestrict getter --->
	<cffunction name="setInvoiceBrokerFilterRestrict" access="public" output="false">
		<cfargument name="invoiceBrokerFilterRestrict" type="numeric" required="true" default="0" />
		<cfset this.invoiceBrokerFilterRestrict = arguments.invoiceBrokerFilterRestrict />
	</cffunction>

	<!--- invoiceBrokerFilterRestrict setter --->
	<cffunction name="getInvoiceBrokerFilterRestrict" access="public" output="false">
		<cfreturn this.invoiceBrokerFilterRestrict/>
	</cffunction>

	<!--- viewProgramProductGroupType getter --->
	<cffunction name="setViewProgramProductGroupType" access="public" output="false">
		<cfargument name="viewProgramProductGroupType" type="numeric" required="true" default="0" />
		<cfset this.viewProgramProductGroupType = arguments.viewProgramProductGroupType />
	</cffunction>

	<!--- viewProgramProductGroupType setter --->
	<cffunction name="getViewProgramProductGroupType" access="public" output="false" returntype="numeric">
		<cfreturn this.viewProgramProductGroupType/>
	</cffunction>

	<!--- viewProgramProductGroupTypeDesc getter --->
	<cffunction name="setViewProgramProductGroupTypeDesc" access="public" output="false">
		<cfargument name="viewProgramProductGroupTypeDesc" type="string" required="true"  />
		<cfset this.viewProgramProductGroupTypeDesc = arguments.viewProgramProductGroupTypeDesc />
	</cffunction>

	<!--- viewProgramProductGroupTypeDesc setter --->
	<cffunction name="getViewProgramProductGroupTypeDesc" access="public" output="false" returntype="string">
		<cfreturn this.viewProgramProductGroupTypeDesc/>
	</cffunction>

	<!--- spendingCapVersion getter --->
	<cffunction name="setSpendingCapVersion" access="public" output="false">
		<cfargument name="spendingCapVersion" type="numeric" required="true"  />
		<cfset this.spendingCapVersion = arguments.spendingCapVersion />
	</cffunction>

	<!--- spendingCapVersion setter --->
	<cffunction name="getSpendingCapVersion" access="public" output="false" returntype="numeric">
		<cfreturn this.spendingCapVersion/>
	</cffunction>

	<!--- growthDecimal4PercentTier getter --->
	<cffunction name="setGrowthDecimal4PercentTier" access="public" output="false">
		<cfargument name="growthDecimal4PercentTier" type="boolean" required="true"  />
		<cfset this.growthDecimal4PercentTier = arguments.growthDecimal4PercentTier />
	</cffunction>

	<!--- growthDecimal4PercentTier setter --->
	<cffunction name="getGrowthDecimal4PercentTier" access="public" output="false" returntype="boolean">
		<cfreturn this.growthDecimal4PercentTier/>
	</cffunction>

	<!--- printer2Name getter --->
	<cffunction name="setPrinter2Name" access="public" output="false">
		<cfargument name="printer2Name" type="string" required="true"  />
		<cfset this.printer2Name = arguments.printer2Name />
	</cffunction>

	<!--- printer2Name setter --->
	<cffunction name="getPrinter2Name" access="public" output="false" returntype="string">
		<cfreturn this.printer2Name/>
	</cffunction>

	<!--- CustsearchRebaterecipientOn getter --->
	<cffunction name="setCustsearchRebaterecipientOn" access="public" output="false">
		<cfargument name="CustsearchRebaterecipientOn" type="numeric" required="true" default="0" />
		<cfset this.CustsearchRebaterecipientOn = arguments.CustsearchRebaterecipientOn />
	</cffunction>

	<!--- CustsearchRebaterecipientOn setter --->
	<cffunction name="getCustsearchRebaterecipientOn" access="public" output="false">
		<cfreturn this.CustsearchRebaterecipientOn/>
	</cffunction>

	<!--- DistributorByProgramOn getter --->
	<cffunction name="setDistSearchGetDistByProgramOn" access="public" output="false">
		<cfargument name="distSearchGetDistByProgramOn" type="numeric" required="true" default="0" />
		<cfset this.DistSearchGetDistByProgramOn = arguments.distSearchGetDistByProgramOn />
	</cffunction>

	<!--- DistributorByProgramOn setter --->
	<cffunction name="getDistSearchGetDistByProgramOn" access="public" output="false">
		<cfreturn this.DistSearchGetDistByProgramOn/>
	</cffunction>

	<!--- OneProgramPerBillback getter --->
	<cffunction name="setOneProgramPerBillback" access="public" output="false">
		<cfargument name="oneProgramPerBillback" type="numeric" required="true" default="0" />
		<cfset this.OneProgramPerBillback = arguments.oneProgramPerBillback />
	</cffunction>

	<!--- OneProgramPerBillback setter --->
	<cffunction name="getOneProgramPerBillback" access="public" output="false">
		<cfreturn this.OneProgramPerBillback/>
	</cffunction>

	<!--- programBudgetOn getter --->
	<cffunction name="setProgramBudgetOn" access="public" output="false">
		<cfargument name="programBudgetOn" type="boolean" required="true" default="0" />
		<cfset this.programBudgetOn = arguments.programBudgetOn />
	</cffunction>

	<!--- programBudgetOn setter --->
	<cffunction name="getProgramBudgetOn" access="public" output="false">
		<cfreturn this.programBudgetOn/>
	</cffunction>

	<!--- captureGroupsOnSave getter --->
	<cffunction name="setCaptureGroupsOnSave" access="public" output="false">
		<cfargument name="captureGroupsOnSave" type="boolean" required="true" default="0" />
		<cfset this.captureGroupsOnSave = arguments.captureGroupsOnSave />
	</cffunction>

	<!--- captureGroupsOnSave setter --->
	<cffunction name="getCaptureGroupsOnSave" access="public" output="false">
		<cfreturn this.captureGroupsOnSave/>
	</cffunction>

	<!--- For Invoices, Display OI getter --->
	<cffunction name="setForInvoicesDisplayOI" access="public" output="false">
		<cfargument name="ForInvoicesDisplayOI" type="boolean" required="true" default="0" />
		<cfset this.ForInvoicesDisplayOI = arguments.ForInvoicesDisplayOI />
	</cffunction>

	<!--- For Invoices, Display OI setter --->
	<cffunction name="getForInvoicesDisplayOI" access="public" output="false">
		<cfreturn this.ForInvoicesDisplayOI/>
	</cffunction>

	<!--- bidRequestPriceListId getter --->
	<cffunction name="setBidRequestPriceListId" access="public" output="false">
		<cfargument name="bidRequestPriceListId" required="true" default="0" />
		<cfset this.bidRequestPriceListId = arguments.bidRequestPriceListId />
	</cffunction>

	<!--- bidRequestPriceListId setter --->
	<cffunction name="getBidRequestPriceListId" access="public" output="false">
		<cfreturn this.bidRequestPriceListId/>
	</cffunction>

	<!--- RFAEmailEvent getter --->
	<cffunction name="setRFAEmailEvent" access="public" output="false">
		<cfargument name="RFAEmailEvent" required="true" default="0" />
		<cfset this.RFAEmailEvent = arguments.RFAEmailEvent />
	</cffunction>

	<!--- RFAEmailEvent setter --->
	<cffunction name="getRFAEmailEvent" access="public" output="false">
		<cfreturn this.RFAEmailEvent/>
	</cffunction>

	<!--- bbAgreeEmail getter --->
	<cffunction name="setBbAgreeEmail" access="public" output="false">
		<cfargument name="bbAgreeEmail" required="true" default="0" />
		<cfset this.bbAgreeEmail = arguments.bbAgreeEmail />
	</cffunction>

	<!--- bbAgreeEmail setter --->
	<cffunction name="getBbAgreeEmail" access="public" output="false">
		<cfreturn this.bbAgreeEmail/>
	</cffunction>

	<!--- bbCheckPayTo getter --->
	<cffunction name="setBBCheckPayTo" access="public" output="false">
		<cfargument name="bbCheckPayTo" required="true" default="0" />
		<cfset this.bbCheckPayTo = arguments.bbCheckPayTo />
	</cffunction>

	<!--- bbCheckPayTo setter --->
	<cffunction name="getBBCheckPayTo" access="public" output="false">
		<cfreturn this.bbCheckPayTo/>
	</cffunction>

	<!--- appErrorAddToPunchlist getter --->
	<cffunction name="setAppErrorAddToPunchlist" access="public" output="false">
		<cfargument name="appErrorAddToPunchlist" required="true" default="0" />
		<cfset this.appErrorAddToPunchlist = arguments.appErrorAddToPunchlist />
	</cffunction>

	<!--- appErrorAddToPunchlist setter --->
	<cffunction name="getAppErrorAddToPunchlist" access="public" output="false">
		<cfreturn this.appErrorAddToPunchlist/>
	</cffunction>

	<!--- disableBBAddProgram getter --->
	<cffunction name="setdisableBBAddProgram" access="public" output="false">
		<cfargument name="disableBBAddProgram" required="true" default="0" />
		<cfset this.disableBBAddProgram = arguments.disableBBAddProgram />
	</cffunction>

	<!--- disableBBAddProgram setter --->
	<cffunction name="getdisableBBAddProgram" access="public" output="false">
		<cfreturn this.disableBBAddProgram/>
	</cffunction>

	<!--- pgmLumpsumDetailedDisplay getter --->
	<cffunction name="setPgmLumpsumDetailedDisplay" access="public" output="false">
		<cfargument name="pgmLumpsumDetailedDisplay" required="true" default="0" />
		<cfset this.pgmLumpsumDetailedDisplay = arguments.pgmLumpsumDetailedDisplay />
	</cffunction>

	<!--- pgmLumpsumDetailedDisplay setter --->
	<cffunction name="getPgmLumpsumDetailedDisplay" access="public" output="false">
		<cfreturn this.pgmLumpsumDetailedDisplay/>
	</cffunction>

	<!--- Renew_expired_programs getter --->
	<cffunction name="setRenew_expired_programs" access="public" output="false">
		<cfargument name="Renew_expired_programs" required="true" default="0" />
		<cfset this.Renew_expired_programs = arguments.Renew_expired_programs />
	</cffunction>

	<!--- Renew_expired_programs setter --->
	<cffunction name="getRenew_expired_programs" access="public" output="false">
		<cfreturn this.Renew_expired_programs/>
	</cffunction>

	<!--- BBDateDevInExpectedVol setter --->
	<cffunction name="setBBDateDevInExpectedVol" access="public" output="false">
		<cfargument name="BBDateDevInExpectedVol" type="boolean" required="true" default="0" />
		<cfset this.BBDateDevInExpectedVol = arguments.BBDateDevInExpectedVol />
	</cffunction>

	<!--- BBDateDevInExpectedVol getter --->
	<cffunction name="getBBDateDevInExpectedVol" access="public" output="false">
		<cfreturn this.BBDateDevInExpectedVol/>
	</cffunction>

	<!--- BidRequestAvailable setter --->
	<cffunction name="setBidRequestAvailable" access="public" output="false">
		<cfargument name="BidRequestAvailable" type="boolean" required="true" default="0" />
		<cfset this.BidRequestAvailable = arguments.BidRequestAvailable />
	</cffunction>

	<!--- BidRequestAvailable getter --->
	<cffunction name="getBidRequestAvailable" access="public" output="false">
		<cfreturn this.BidRequestAvailable/>
	</cffunction>

	<!--- showBSAOperators setter --->
	<cffunction name="setShowBSAOperators" access="public" output="false">
		<cfargument name="showBSAOperators" type="boolean" required="true" default="0" />
		<cfset this.showBSAOperators = arguments.showBSAOperators />
	</cffunction>

	<!--- showBSAOperators getter --->
	<cffunction name="getShowBSAOperators" access="public" output="false">
		<cfreturn this.showBSAOperators/>
	</cffunction>

	<!--- ExternalWebserviceURL setter --->
	<cffunction name="setExternalWebserviceURL" access="public" output="false">
		<cfargument name="ExternalWebserviceURL" type="string" required="true" default="" />
		<cfset this.ExternalWebserviceURL = arguments.ExternalWebserviceURL />
	</cffunction>

	<!--- ExternalWebserviceURL getter --->
	<cffunction name="getExternalWebserviceURL" access="public" output="false">
		<cfreturn this.ExternalWebserviceURL/>
	</cffunction>

	<!--- WebserverInternalIPAddress setter --->
	<cffunction name="setWebserverInternalIPAddress" access="public" output="false">
		<cfargument name="WebserverInternalIPAddress" type="string" required="true" default="" />
		<cfset this.WebserverInternalIPAddress = arguments.WebserverInternalIPAddress />
	</cffunction>

	<!--- WebserverInternalIPAddress getter --->
	<cffunction name="getWebserverInternalIPAddress" access="public" output="false">
		<cfreturn this.WebserverInternalIPAddress/>
	</cffunction>

	<!--- Use_Accounting_Program_Type setter --->
	<cffunction name="setBB_PP_Manual_Discount" access="public" output="false">
		<cfargument name="BB_PP_Manual_Discount" type="boolean" required="true" default="0" />
		<cfset this.BB_PP_Manual_Discount = arguments.BB_PP_Manual_Discount />
	</cffunction>

	<!--- Use_Accounting_Program_Type getter --->
	<cffunction name="getBB_PP_Manual_Discount" access="public" output="false">
		<cfreturn this.BB_PP_Manual_Discount/>
	</cffunction>

	<!--- FuturesPricingAvailable setter --->
	<cffunction name="setFuturesPricingAvailable" access="public" output="false">
		<cfargument name="FuturesPricingAvailable" type="boolean" required="true" default="0" />
		<cfset this.FuturesPricingAvailable = arguments.FuturesPricingAvailable />
	</cffunction>

	<!--- FuturesPricingAvailable getter --->
	<cffunction name="getFuturesPricingAvailable" access="public" output="false">
		<cfreturn this.FuturesPricingAvailable/>
	</cffunction>

	<!--- AutoRenewSpaninPW setter --->
	<cffunction name="setAutoRenewSpaninPW" access="public" output="false">
		<cfargument name="AutoRenewSpaninPW" type="string" required="true" default="" />
		<cfset this.AutoRenewSpaninPW = arguments.AutoRenewSpaninPW />
	</cffunction>

	<!--- AutoRenewSpaninPW getter --->
	<cffunction name="getAutoRenewSpaninPW" access="public" output="false">
		<cfreturn this.AutoRenewSpaninPW/>
	</cffunction>

	<!--- lettersavailable setter --->
	<cffunction name="setlettersavailable" access="public" output="false">
		<cfargument name="lettersavailable" type="boolean" required="true" default="0" />
		<cfset this.lettersavailable = arguments.lettersavailable />
	</cffunction>

	<!--- lettersavailable getter --->
	<cffunction name="getlettersavailable" access="public" output="false">
		<cfreturn this.lettersavailable/>
	</cffunction>

	<!--- letterssubject setter --->
	<cffunction name="setletterssubject" access="public" output="false">
		<cfargument name="letterssubject" type="string" required="true" default="" />
		<cfset this.letterssubject = arguments.letterssubject />
	</cffunction>

	<!--- letterssubject getter --->
	<cffunction name="getletterssubject" access="public" output="false">
		<cfreturn this.letterssubject/>
	</cffunction>

	<!--- lettersfromemail setter --->
	<cffunction name="setlettersfromemail" access="public" output="false">
		<cfargument name="lettersfromemail" type="string" required="true" default="" />
		<cfset this.lettersfromemail = arguments.lettersfromemail />
	</cffunction>

	<!--- lettersfromemail getter --->
	<cffunction name="getlettersfromemail" access="public" output="false">
		<cfreturn this.lettersfromemail/>
	</cffunction>

	<!--- deviationLabel setter --->
	<cffunction name="setDeviationLabel" access="public" output="false">
		<cfargument name="deviationLabel" type="string" required="true" default="" />
		<cfset this.deviationLabel = arguments.deviationLabel />
	</cffunction>

	<!--- deviationLabel getter --->
	<cffunction name="getDeviationLabel" access="public" output="false">
		<cfreturn trim(this.deviationLabel) />
	</cffunction>

	<!--- Program_Allow_Null_Rate --->
	<cffunction name="setProgram_Allow_Null_Rate" access="public" output="false">
		<cfargument name="Program_Allow_Null_Rate" type="numeric" required="true" default="" />
		<cfset this.Program_Allow_Null_Rate = arguments.Program_Allow_Null_Rate />
	</cffunction>

	<!--- Program_Allow_Null_Rate getter --->
	<cffunction name="getProgram_Allow_Null_Rate" access="public" output="false">
		<cfreturn trim(this.Program_Allow_Null_Rate) />
	</cffunction>

	<!--- Claims_at_Comp_Level --->
	<cffunction name="setClaims_at_Comp_Level" access="public" output="false">
		<cfargument name="Claims_at_Comp_Level" type="numeric" required="true" default="" />
		<cfset this.Claims_at_Comp_Level = arguments.Claims_at_Comp_Level />
	</cffunction>

	<!--- Claims_at_Comp_Level getter --->
	<cffunction name="getClaims_at_Comp_Level" access="public" output="false">
		<cfreturn trim(this.Claims_at_Comp_Level) />
	</cffunction>

	<!--- pgmDisableEditWhileSendingToClient setter --->
	<cffunction name="setPgmDisableEditWhileSendingToClient" access="public" output="false">
		<cfargument name="pgmDisableEditWhileSendingToClient" type="boolean" required="true" default="0" />
		<cfset this.pgmDisableEditWhileSendingToClient = arguments.pgmDisableEditWhileSendingToClient />
	</cffunction>

	<!--- pgmDisableEditWhileSendingToClient getter --->
	<cffunction name="getPgmDisableEditWhileSendingToClient" access="public" output="false">
		<cfreturn this.pgmDisableEditWhileSendingToClient/>
	</cffunction>

	<!--- operatingGroupOn setter --->
	<cffunction name="setOperatingGroupOn" access="public" output="false">
		<cfargument name="operatingGroupOn" type="boolean" required="true" default="0" />
		<cfset this.operatingGroupOn = arguments.operatingGroupOn />
	</cffunction>

	<!--- operatingGroupOn getter --->
	<cffunction name="getOperatingGroupOn" access="public" output="false">
		<cfreturn this.operatingGroupOn/>
	</cffunction>

	<!--- Use_Accounting_Program_Type setter --->
	<cffunction name="setUse_Accounting_Program_Type" access="public" output="false">
		<cfargument name="Use_Accounting_Program_Type" type="boolean" required="true" default="0" />
		<cfset this.Use_Accounting_Program_Type = arguments.Use_Accounting_Program_Type />
	</cffunction>

	<!--- Use_Accounting_Program_Type getter --->
	<cffunction name="getUse_Accounting_Program_Type" access="public" output="false">
		<cfreturn this.Use_Accounting_Program_Type/>
	</cffunction>

	<!--- searchSequenceOn setter --->
	<cffunction name="setSearchSequenceOn" access="public" output="false">
		<cfargument name="searchSequenceOn" type="boolean" required="true" default="0" />
		<cfset this.searchSequenceOn = arguments.searchSequenceOn />
	</cffunction>

	<!--- searchSequenceOn getter --->
	<cffunction name="getSearchSequenceOn" access="public" output="false">
		<cfreturn this.searchSequenceOn/>
	</cffunction>

	<!--- localcostvariables setter --->
	<cffunction name="setlocalcostvariables" access="public" output="false">
		<cfargument name="localcostvariables" type="numeric" required="true" default="0" />
		<cfset this.localcostvariables = arguments.localcostvariables />
	</cffunction>

	<!--- localcostvariables getter --->
	<cffunction name="getlocalcostvariables" access="public" output="false">
		<cfreturn this.localcostvariables/>
	</cffunction>

	<!--- customerbasedcosts setter --->
	<cffunction name="setcustomerbasedcosts" access="public" output="false">
		<cfargument name="customerbasedcosts" type="boolean" required="true" default="0" />
		<cfset this.customerbasedcosts = arguments.customerbasedcosts />
	</cffunction>

	<!--- customerbasedcosts getter --->
	<cffunction name="getcustomerbasedcosts" access="public" output="false">
		<cfreturn this.customerbasedcosts/>
	</cffunction>

	<!--- maxlocalcostvars setter --->
	<cffunction name="setmaxlocalcostvars" access="public" output="false">
		<cfargument name="maxlocalcostvars" type="numeric" required="true" default="0" />
		<cfset this.maxlocalcostvars = arguments.maxlocalcostvars />
	</cffunction>

	<!--- maxlocalcostvars getter --->
	<cffunction name="getmaxlocalcostvars" access="public" output="false">
		<cfreturn this.maxlocalcostvars/>
	</cffunction>

	<!--- pgmGrpsOnlyProdAtLowerLevel setter --->
	<cffunction name="setPgmGrpsOnlyProdAtLowerLevel" access="public" output="false">
		<cfargument name="pgmGrpsOnlyProdAtLowerLevel" type="boolean" required="true" default="0" />
		<cfset this.pgmGrpsOnlyProdAtLowerLevel = arguments.pgmGrpsOnlyProdAtLowerLevel />
	</cffunction>

	<!--- pgmGrpsOnlyProdAtLowerLevel getter --->
	<cffunction name="getPgmGrpsOnlyProdAtLowerLevel" access="public" output="false">
		<cfreturn this.pgmGrpsOnlyProdAtLowerLevel/>
	</cffunction>

	<!--- groupByGroupType setter --->
	<cffunction name="setGroupByGroupType" access="public" output="false">
		<cfargument name="groupByGroupType" type="boolean" required="true" default="0" />
		<cfset this.groupByGroupType = arguments.groupByGroupType />
	</cffunction>

	<!--- groupByGroupType getter --->
	<cffunction name="getGroupByGroupType" access="public" output="false">
		<cfreturn this.groupByGroupType/>
	</cffunction>

	<!--- printincludeheader setter --->
	<cffunction name="setprintincludeheader" access="public" output="false">
		<cfargument name="printincludeheader" type="boolean" required="true" default="0" />
		<cfset this.printincludeheader = arguments.printincludeheader />
	</cffunction>

	<!--- printincludeheader getter --->
	<cffunction name="getprintincludeheader" access="public" output="false">
		<cfreturn this.printincludeheader/>
	</cffunction>

	<!--- CheckAllDuplicateProgram setter --->
	<cffunction name="setCheckAllDuplicateProgram" access="public" output="false">
		<cfargument name="CheckAllDuplicateProgram" type="boolean" required="true" default="0" />
		<cfset this.CheckAllDuplicateProgram = arguments.CheckAllDuplicateProgram />
	</cffunction>

	<!--- CheckAllDuplicateProgram getter --->
	<cffunction name="getCheckAllDuplicateProgram" access="public" output="false">
		<cfreturn this.CheckAllDuplicateProgram/>
	</cffunction>

	<!--- pricing_template_list setter --->
	<cffunction name="setpricingtemplatelist" access="public" output="false">
		<cfargument name="pricingtemplatelist" type="string" required="true" default="0" />
		<cfset this.pricingtemplatelist = arguments.pricingtemplatelist />
	</cffunction>

	<!--- pricing_template_list getter --->
	<cffunction name="getpricingtemplatelist" access="public" output="false">
		<cfreturn this.pricingtemplatelist/>
	</cffunction>

	<!--- Distributor_Letter_Name setter --->
	<cffunction name="setDistributorLetterName" access="public" output="false">
		<cfargument name="Distributor_Letter_Name" type="string" required="true" default="" />
		<cfset this.Distributor_Letter_Name = arguments.Distributor_Letter_Name />
	</cffunction>

	<!--- Distributor_Letter_Name getter --->
	<cffunction name="getDistributorLetterName" access="public" output="false">
		<cfreturn this.Distributor_Letter_Name/>
	</cffunction>

	<!--- Operator_Letter_Name setter --->
	<cffunction name="setOperatorLetterName" access="public" output="false">
		<cfargument name="Operator_Letter_Name" type="string" required="true" default="" />
		<cfset this.Operator_Letter_Name = arguments.Operator_Letter_Name />
	</cffunction>

	<!--- Operator_Letter_Name getter --->
	<cffunction name="getOperatorLetterName" access="public" output="false">
		<cfreturn this.Operator_Letter_Name/>
	</cffunction>

	<!--- Show_Projects_ScoreCard setter --->
	<cffunction name="setShowProjectsScoreCard" access="public" output="false">
		<cfargument name="ShowProjectsScoreCard" type="string" required="true" default="1" />
		<cfset this.ShowProjectsScoreCard = arguments.ShowProjectsScoreCard />
	</cffunction>

	<!--- Show_Projects_ScoreCard getter --->
	<cffunction name="getShowProjectsScoreCard" access="public" output="false">
		<cfreturn this.ShowProjectsScoreCard/>
	</cffunction>

	<!--- PgmScorecardRevisionReport setter --->
	<cffunction name="setPgmScorecardRevisionReport" access="public" output="false">
		<cfargument name="pgmScorecardRevisionReport" type="boolean" required="true" default="1" />
		<cfset this.pgmScorecardRevisionReport = arguments.pgmScorecardRevisionReport />
	</cffunction>

	<!--- PgmScorecardRevisionReport getter --->
	<cffunction name="getPgmScorecardRevisionReport" access="public" output="false">
		<cfreturn this.pgmScorecardRevisionReport/>
	</cffunction>

	<!--- InvoicePositionRestriction setter --->
	<cffunction name="setInvoicePositionRestriction" access="public" output="false">
		<cfargument name="invoicePositionRestriction" type="boolean" required="true" default="1" />
		<cfset this.invoicePositionRestriction = arguments.invoicePositionRestriction />
	</cffunction>

	<!--- InvoicePositionRestriction getter --->
	<cffunction name="getInvoicePositionRestriction" access="public" output="false">
		<cfreturn this.invoicePositionRestriction/>
	</cffunction>

	<!--- InvoicePositionRestriction setter --->
	<cffunction name="setRemoveMarketFromPgmSearchPage" access="public" output="false">
		<cfargument name="RemoveMarketFromPgmSearchPage" type="boolean" required="true" default="1" />
		<cfset this.RemoveMarketFromPgmSearchPage = arguments.RemoveMarketFromPgmSearchPage />
	</cffunction>

	<!--- InvoicePositionRestriction getter --->
	<cffunction name="getRemoveMarketFromPgmSearchPage" access="public" output="false">
		<cfreturn this.RemoveMarketFromPgmSearchPage/>
	</cffunction>

	<!--- InvoicePositionRestriction setter --->
	<cffunction name="setAuthority_Sequence_For_HQ_Only" access="public" output="false">
		<cfargument name="Authority_Sequence_For_HQ_Only" type="boolean" required="true" default="1" />
		<cfset this.Authority_Sequence_For_HQ_Only = arguments.Authority_Sequence_For_HQ_Only />
	</cffunction>

	<!--- InvoicePositionRestriction getter --->
	<cffunction name="getAuthority_Sequence_For_HQ_Only" access="public" output="false">
		<cfreturn this.Authority_Sequence_For_HQ_Only/>
	</cffunction>

	<!--- pgmViewDisplaySPRAddress2 setter --->
	<cffunction name="setPgmViewDisplaySPRAddress2" access="public" output="false">
		<cfargument name="pgmViewDisplaySPRAddress2" type="boolean" required="true" />
		<cfset this.pgmViewDisplaySPRAddress2 = arguments.pgmViewDisplaySPRAddress2 />
	</cffunction>

	<!--- pgmViewDisplaySPRAddress2 getter --->
	<cffunction name="getPgmViewDisplaySPRAddress2" access="public" output="false">
		<cfreturn this.pgmViewDisplaySPRAddress2 />
	</cffunction>

	<!--- bidRequestHierarchyLevel setter --->
	<cffunction name="setBidRequestHierarchyLevel" access="public" output="false">
		<cfargument name="bidRequestHierarchyLevel" type="string" required="true" default="" />
		<cfset this.Bid_Request_Hierarchy_Level = arguments.bidRequestHierarchyLevel />
	</cffunction>

	<!--- bidRequestHierarchyLevel getter --->
	<cffunction name="getBidRequestHierarchyLevel" access="public" output="false">
		<cfreturn this.Bid_Request_Hierarchy_Level />
	</cffunction>

	<!--- hide/show groups in view margin setter --->
	<cffunction name="setShowORHideGroupsInViewMargin" access="public" output="false" returntype="void">
		<cfargument name="Show_OR_Hide_Groups_In_View_Margin" type="numeric" required="true" default="" />
		<cfset this.Show_OR_Hide_Groups_In_View_Margin = arguments.Show_OR_Hide_Groups_In_View_Margin />
	</cffunction>

	<!--- hide/show groups in view margin getter --->
	<cffunction name="getShowORHideGroupsInViewMargin" access="public" output="false" returntype="numeric">
		<cfreturn this.Show_OR_Hide_Groups_In_View_Margin />
	</cffunction>

	<!--- tradeplanneroff setter --->
	<cffunction name="settradeplanneroff" access="public" output="false" returntype="void">
		<cfargument name="tradeplanneroff" type="boolean" required="true" default="" />
		<cfset this.tradeplanneroff = arguments.tradeplanneroff />
	</cffunction>

	<!--- tradeplanneroff margin getter --->
	<cffunction name="gettradeplanneroff" access="public" output="false" returntype="boolean">
		<cfreturn this.tradeplanneroff />
	</cffunction>

	<!--- approvalmatrixoff setter --->
	<cffunction name="setapprovalmatrixoff" access="public" output="false" returntype="void">
		<cfargument name="approvalmatrixoff" type="boolean" required="true" default="" />
		<cfset this.approvalmatrixoff = arguments.approvalmatrixoff />
	</cffunction>

	<!---approvalmatrixoff getter --->
	<cffunction name="getapprovalmatrixoff" access="public" output="false" returntype="boolean">
		<cfreturn this.approvalmatrixoff />
	</cffunction>

	<!--- Allowed_to_Add_Operator setter --->
	<cffunction name="setAllowed_to_Add_Operator" access="public" output="false" returntype="void">
		<cfargument name="Allowed_to_Add_Operator" type="string" required="true" default="" />
		<cfset this.Allowed_to_Add_Operator = arguments.Allowed_to_Add_Operator />
	</cffunction>

	<cffunction name="getAllowed_to_Add_Operator" access="public" output="false" returntype="string">
		<cfreturn this.Allowed_to_Add_Operator />
	</cffunction>

	<!--- Created_Operators_Default_Active setter --->
	<cffunction name="setCreated_Operators_Default_Active" access="public" output="false" returntype="void">
		<cfargument name="Created_Operators_Default_Active" type="string" required="true" default="" />
		<cfset this.Created_Operators_Default_Active = arguments.Created_Operators_Default_Active />
	</cffunction>

	<!--- Created_Operators_Default_Active getter --->
	<cffunction name="getCreated_Operators_Default_Active" access="public" output="false" returntype="string">
		<cfreturn this.Created_Operators_Default_Active />
	</cffunction>

	<!--- programNumberPrefix setter --->
	<cffunction name="setProgramNumberPrefix" access="public" output="false">
		<cfargument name="programNumberPrefix" type="string" required="true" default="0" />
		<cfset this.programNumberPrefix = arguments.programNumberPrefix />
	</cffunction>

	<!--- programNumberPrefix getter --->
	<cffunction name="getProgramNumberPrefix" access="public" output="false">
		<cfreturn this.programNumberPrefix/>
	</cffunction>

	<!--- billbackNumberPrefix setter --->
	<cffunction name="setBillbackNumberPrefix" access="public" output="false">
		<cfargument name="billbackNumberPrefix" type="string" required="true" default="0" />
		<cfset this.billbackNumberPrefix = arguments.billbackNumberPrefix />
	</cffunction>

	<!--- billbackNumberPrefix getter --->
	<cffunction name="getBillbackNumberPrefix" access="public" output="false">
		<cfreturn this.billbackNumberPrefix/>
	</cffunction>

	<!--- deductionNumberPrefix setter --->
	<cffunction name="setDeductionNumberPrefix" access="public" output="false">
		<cfargument name="deductionNumberPrefix" type="string" required="true" default="0" />
		<cfset this.deductionNumberPrefix = arguments.deductionNumberPrefix />
	</cffunction>

	<!--- deductionNumberPrefix getter --->
	<cffunction name="getDeductionNumberPrefix" access="public" output="false">
		<cfreturn this.deductionNumberPrefix/>
	</cffunction>

	<!--- DDCreditNumberPrefix Setter & getter --->
	<cffunction name="setDDCreditNumberPrefix" access="public" output="false">
		<cfargument name="DDCreditNumberPrefix" type="string" required="true" default="0" />
		<cfset this.DDCreditNumberPrefix = arguments.DDCreditNumberPrefix />
	</cffunction>

	<cffunction name="getDDCreditNumberPrefix" access="public" output="false">
		<cfreturn this.DDCreditNumberPrefix/>
	</cffunction>

	<!--- plannerNumberPrefix setter --->
	<cffunction name="setPlannerNumberPrefix" access="public" output="false">
		<cfargument name="plannerNumberPrefix" type="string" required="true" default="0" />
		<cfset this.plannerNumberPrefix = arguments.plannerNumberPrefix />
	</cffunction>

	<!--- plannerNumberPrefix getter --->
	<cffunction name="getPlannerNumberPrefix" access="public" output="false">
		<cfreturn this.plannerNumberPrefix/>
	</cffunction>

	<!--- AutoClaimBuffer setter --->
	<cffunction name="setAutoClaimBuffer" access="public" output="false">
		<cfargument name="AutoClaimBuffer" type="numeric" required="true" default="0" />
		<cfset this.AutoClaimBuffer = arguments.AutoClaimBuffer />
	</cffunction>

	<!--- AutoClaimBuffer getter --->
	<cffunction access="public" name="getAutoClaimBuffer" output="false" returntype="numeric">
		<cfreturn this.AutoClaimBuffer/>
	</cffunction>

	<!--- pgmEmailPricingAdmin setter --->
	<cffunction name="setPgmEmailPricingAdmin" access="public" output="false">
		<cfargument name="pgmEmailPricingAdmin" type="boolean" required="true" default="0" />
		<cfset this.pgmEmailPricingAdmin = arguments.pgmEmailPricingAdmin />
	</cffunction>

	<!--- pgmEmailPricingAdmin getter --->
	<cffunction name="getPgmEmailPricingAdmin" access="public" output="false" returntype="boolean">
		<cfreturn this.pgmEmailPricingAdmin/>
	</cffunction>

	<!--- Letters_Accepted_By setter --->
	<cffunction name="setLettersAcceptedBy" access="public" output="false">
		<cfargument name="Letters_Accepted_By" type="string" required="true" default="" />
		<cfset this.Letters_Accepted_By = arguments.Letters_Accepted_By />
	</cffunction>

	<!--- Letters_Accepted_By getter --->
	<cffunction name="getLettersAcceptedBy" access="public" output="false">
		<cfreturn this.Letters_Accepted_By/>
	</cffunction>

	<!--- Letters_Address setter --->
	<cffunction name="setLettersAddress" access="public" output="false">
		<cfargument name="Letters_Address" type="string" required="true" default="1" />
		<cfset this.Letters_Address = arguments.Letters_Address />
	</cffunction>

	<!--- Letters_Address getter --->
	<cffunction name="getLettersAddress" access="public" output="false">
		<cfreturn this.Letters_Address />
	</cffunction>

	<!--- BBRestrictRouteUserList setter --->
	<cffunction name="setBBRestrictRouteUserList" access="public" output="false">
		<cfargument name="BBRestrictRouteUserList" type="boolean" required="true" default="0" />
		<cfset this.BBRestrictRouteUserList = arguments.BBRestrictRouteUserList />
	</cffunction>

	<!--- BBRestrictRouteUserList getter --->
	<cffunction name="getBBRestrictRouteUserList" access="public" output="false" returntype="boolean">
		<cfreturn this.BBRestrictRouteUserList/>
	</cffunction>

	<!--- commonAccessURLPrefix setter --->
	<cffunction name="setCommonAccessURLPrefix" access="public" output="false">
		<cfargument name="commonAccessURLPrefix" type="string" required="true" default="0" />
		<cfset this.commonAccessURLPrefix = arguments.commonAccessURLPrefix />
	</cffunction>

	<!--- commonAccessURLPrefix getter --->
	<cffunction name="getCommonAccessURLPrefix" access="public" output="false" returntype="string">
		<cfreturn this.commonAccessURLPrefix/>
	</cffunction>

	<!--- pgmLikeProductCheckbox setter --->
	<cffunction name="setPgmLikeProductCheckbox" access="public" output="false">
		<cfargument name="pgmLikeProductCheckbox" type="boolean" required="true" default="0" />
		<cfset this.pgmLikeProductCheckbox = arguments.pgmLikeProductCheckbox />
	</cffunction>

	<!--- pgmLikeProductCheckbox getter --->
	<cffunction name="getPgmLikeProductCheckbox" access="public" output="false" returntype="boolean">
		<cfreturn this.pgmLikeProductCheckbox/>
	</cffunction>

	<!--- view_approved_margins_report setter --->
	<cffunction name="setviewapprovedmarginsreport" access="public" output="false">
		<cfargument name="view_approved_margins_report" type="boolean" required="true" default="0" />
		<cfset this.view_approved_margins_report = arguments.view_approved_margins_report />
	</cffunction>

	<!--- view_approved_margins_report getter --->
	<cffunction name="getviewapprovedmarginsreport" access="public" output="false" returntype="boolean">
		<cfreturn this.view_approved_margins_report/>
	</cffunction>

	<!--- pgmDisplayBothRateUOM setter --->
	<cffunction name="setPgmDisplayBothRateUOM" access="public" output="false">
		<cfargument name="pgmDisplayBothRateUOM" type="boolean" required="true" default="0" />
		<cfset this.pgmDisplayBothRateUOM = arguments.pgmDisplayBothRateUOM />
	</cffunction>

	<!--- pgmDisplayBothRateUOM getter --->
	<cffunction name="getPgmDisplayBothRateUOM" access="public" output="false" returntype="boolean">
		<cfreturn this.pgmDisplayBothRateUOM/>
	</cffunction>

	<!--- retain_original_RSP setter --->
	<cffunction name="setretainoriginalRSP" access="public" output="false">
		<cfargument name="retain_original_RSP" type="boolean" required="true" default="0" />
		<cfset this.retain_original_RSP = arguments.retain_original_RSP />
	</cffunction>

	<!--- pgmDisplayBothRateUOM getter --->
	<cffunction name="getretainoriginalRSP" access="public" output="false" returntype="boolean">
		<cfreturn this.retain_original_RSP/>
	</cffunction>

	<!--- retain_original_RSP_copy setter --->
	<cffunction name="setretainoriginalRSPcopy" access="public" output="false">
		<cfargument name="retain_original_RSP_copy" type="boolean" required="true" default="0" />
		<cfset this.retain_original_RSP_copy = arguments.retain_original_RSP_copy />
	</cffunction>

	<cffunction name="getretainoriginalRSPcopy" access="public" output="false" returntype="boolean">
		<cfreturn this.retain_original_RSP_copy/>
	</cffunction>

	<!--- Daily_RSP_Update setter --->
	<cffunction name="setDailyRSPUpdate" access="public" output="false">
		<cfargument name="dailyRSPUpdate" type="boolean" required="true" default="0" />
		<cfset this.dailyRSPUpdate = arguments.dailyRSPUpdate />
	</cffunction>

	<!--- Daily_RSP_Update getter --->
	<cffunction name="getDailyRSPUpdate" access="public" output="false" returntype="boolean">
		<cfreturn this.dailyRSPUpdate/>
	</cffunction>

	<!--- Mass_Pay_Billback setter --->
	<cffunction name="setMass_Pay_Billback" access="public" output="false">
		<cfargument name="Mass_Pay_Billback" type="boolean" required="true" default="0" />
		<cfset this.Mass_Pay_Billback = arguments.Mass_Pay_Billback />
	</cffunction>

	<!--- Mass_Pay_Billback getter --->
	<cffunction name="getMass_Pay_Billback" access="public" output="false" returntype="boolean">
		<cfreturn this.Mass_Pay_Billback/>
	</cffunction>

	<!--- ClaimMech_Popup getter --->
	<cffunction name="setClaimMech_Popup" access="public" output="false">
		<cfargument name="ClaimMech_Popup" required="true" default="0" />
		<cfset this.ClaimMech_Popup = arguments.ClaimMech_Popup />
	</cffunction>

	<!--- ClaimMech_Popup setter --->
	<cffunction name="getClaimMech_Popup" access="public" output="false">
		<cfreturn this.ClaimMech_Popup/>
	</cffunction>

	<!--- Display_Only_Assigned_Deductions getter --->
	<cffunction name="setDisplayOnlyAssignedDeductions" access="public" output="false">
		<cfargument name="Display_Only_Assigned_Deductions" required="true" default="0" />
		<cfset this.Display_Only_Assigned_Deductions = arguments.Display_Only_Assigned_Deductions />
	</cffunction>

	<!--- Display_Only_Assigned_Deductions setter --->
	<cffunction name="getDisplayOnlyAssignedDeductions" access="public" output="false">
		<cfreturn this.Display_Only_Assigned_Deductions/>
	</cffunction>

	<!--- Daily_RSP_Update setter --->
	<cffunction name="setcancelallprogramversions" access="public" output="false">
		<cfargument name="cancelallprogramversions" type="boolean" required="true" default="0" />
		<cfset this.cancelallprogramversions = arguments.cancelallprogramversions />
	</cffunction>

	<!--- Daily_RSP_Update getter --->
	<cffunction name="getcancelallprogramversions" access="public" output="false" returntype="boolean">
		<cfreturn this.cancelallprogramversions/>
	</cffunction>

	<!--- Document Path setter --->
	<cffunction name="setDocumentPath" access="public" output="false">
		<cfargument name="DocumentPath" type="string" required="true"  />
		<cfset this.DocumentPath = arguments.DocumentPath />
	</cffunction>

	<!--- Document Path getter --->
	<cffunction name="getDocumentPath" access="public" output="false" returntype="string">
		<cfif trim(this.DocumentPath) eq "">
			<cfreturn "#Application.AppPath#\Common_Documents">
		<cfelse>
			<cfreturn this.DocumentPath>
		</cfif>
	</cffunction>

	<!--- Show Mapping setter --->
	<cffunction name="setShowMapping" access="public" output="false">
		<cfargument name="ShowMapping" type="boolean" required="true" default="0" />
		<cfset this.ShowMapping = arguments.ShowMapping />
	</cffunction>

	<!--- Document Mapping getter --->
	<cffunction name="getShowMapping" access="public" output="false" returntype="boolean">
		<cfreturn this.ShowMapping />
	</cffunction>

	<!--- Document Mapping setter --->
	<cffunction name="setDocumentMapping" access="public" output="false">
		<cfargument name="DocumentMapping" type="string" required="true"  />
		<cfset this.DocumentMapping = arguments.DocumentMapping />
	</cffunction>

	<!--- Document Mapping getter --->
	<cffunction name="getDocumentMapping" access="public" output="false" returntype="string">
		<cfif trim(this.DocumentMapping) eq "">
			<cfreturn "/common_documents">
		<cfelse>
			<cfreturn this.DocumentMapping>
		</cfif>
	</cffunction>

	<!--- get/setter for AvoidSharedProductsinLumpSum --->
	<cffunction name="setAvoidSharedProductsinLumpSum" access="public" output="false">
		<cfargument name="Avoid_Shared_Products_in_LumpSum" type="numeric" required="true" default="0" />
		<cfset this.Avoid_Shared_Products_in_LumpSum = arguments.Avoid_Shared_Products_in_LumpSum />
	</cffunction>

	<cffunction name="getAvoidSharedProductsinLumpSum" access="public" output="false" returntype="numeric">
		<cfreturn this.Avoid_Shared_Products_in_LumpSum />
	</cffunction>

	<!--- get/setter for Remove_Help_Icon --->
	<cffunction name="setRemoveHelpIcon" access="public" output="false">
		<cfargument name="Remove_Help_Icon" type="numeric" required="true" default="0" />
		<cfset this.Remove_Help_Icon = arguments.Remove_Help_Icon />
	</cffunction>

	<cffunction name="getRemoveHelpIcon" access="public" output="false" returntype="numeric">
		<cfreturn this.Remove_Help_Icon />
	</cffunction>

	<!--- get/setter for display_clients_help_desk_info --->
	<cffunction name="setdisplayclientshelpdeskinfo" access="public" output="false">
		<cfargument name="display_clients_help_desk_info" type="numeric" required="true" default="0" />
		<cfset this.display_clients_help_desk_info = arguments.display_clients_help_desk_info />
	</cffunction>

	<cffunction name="getdisplayclientshelpdeskinfo" access="public" output="false" returntype="numeric">
		<cfreturn this.display_clients_help_desk_info />
	</cffunction>

	<!--- get/setter for clients_help_desk_info --->
	<cffunction name="setclientshelpdeskinfo" access="public" output="false">
		<cfargument name="clients_help_desk_info" type="string" required="true" default="0" />
		<cfset this.clients_help_desk_info = arguments.clients_help_desk_info />
	</cffunction>

	<cffunction name="getclientshelpdeskinfo" access="public" output="false" returntype="string">
		<cfreturn this.clients_help_desk_info />
	</cffunction>

	<!--- get/setter for User_Fax_Number --->
	<cffunction name="setUserFaxNumber" access="public" output="false">
		<cfargument name="User_Fax_Number" type="numeric" required="true" default="0" />
		<cfset this.User_Fax_Number = arguments.User_Fax_Number />
	</cffunction>

	<cffunction name="getUserFaxNumber" access="public" output="false" returntype="numeric">
		<cfreturn this.User_Fax_Number />
	</cffunction>

	<!--- Set Billbacks Sales Tax --->
	<cffunction name="setBillbacksSalesTax" access="public" output="false">
		<cfargument name="BillbacksSalesTax" type="boolean" required="true" default="0" />
		<cfset this.BillbacksSalesTax = arguments.BillbacksSalesTax />
	</cffunction>

	<!--- Get Billbacks Sales Tax --->
	<cffunction name="getBillbacksSalesTax" access="public" output="false" returntype="boolean">
		<cfreturn this.BillbacksSalesTax />
	</cffunction>

	<!--- Set direct_pricing_on --->
	<cffunction name="setdirectpricingon" access="public" output="false">
		<cfargument name="direct_pricing_on" type="boolean" required="true" default="0" />
		<cfset this.direct_pricing_on = arguments.direct_pricing_on />
	</cffunction>

	<!--- Get direct_pricing_on --->
	<cffunction name="getdirectpricingon" access="public" output="false" returntype="boolean">
		<cfreturn this.direct_pricing_on />
	</cffunction>

	<!--- Set revision_report_uom --->
	<cffunction name="setrevisionreportuom" access="public" output="false">
		<cfargument name="revision_report_uom" type="string" required="true" default="1" />
		<cfset this.revision_report_uom = arguments.revision_report_uom />
	</cffunction>

	<!--- Get revision_report_uom --->
	<cffunction name="getrevisionreportuom" access="public" output="false" returntype="string">
		<cfreturn this.revision_report_uom />
	</cffunction>

	<!--- Set display_zeros_view_program --->
	<cffunction name="setdisplayzerosviewprogram" access="public" output="false">
		<cfargument name="display_zeros_view_program" type="string" required="true" default="1" />
		<cfset this.display_zeros_view_program = arguments.display_zeros_view_program />
	</cffunction>

	<!--- Get display_zeros_view_program --->
	<cffunction name="getdisplayzerosviewprogram" access="public" output="false" returntype="string">
		<cfreturn this.display_zeros_view_program />
	</cffunction>

	<!--- Set Apply_RSP_Filters --->
	<cffunction name="setApplyRSPFilters" access="public" output="false">
		<cfargument name="Apply_RSP_Filters" type="string" required="true" default="1" />
		<cfset this.Apply_RSP_Filters = arguments.Apply_RSP_Filters />
	</cffunction>

	<!--- Get Apply_RSP_Filters --->
	<cffunction name="getApplyRSPFilters" access="public" output="false" returntype="string">
		<cfreturn this.Apply_RSP_Filters />
	</cffunction>

	<!--- Set pgmGrpLevel3IsExclusion Tax --->
	<cffunction name="setPgmGrpLevel3IsExclusion" access="public" output="false">
		<cfargument name="pgmGrpLevel3IsExclusion" type="boolean" required="true" default="0" />
		<cfset this.pgmGrpLevel3IsExclusion = arguments.pgmGrpLevel3IsExclusion />
	</cffunction>

	<!--- Get pgmGrpLevel3IsExclusion Tax --->
	<cffunction name="getPgmGrpLevel3IsExclusion" access="public" output="false" returntype="boolean">
		<cfreturn this.pgmGrpLevel3IsExclusion />
	</cffunction>

	<!--- Set ShowUploadAccrual Tax --->
	<cffunction name="setShowUploadAccrual" access="public" output="false">
		<cfargument name="ShowUploadAccrual" type="boolean" required="true" default="0" />
		<cfset this.ShowUploadAccrual = arguments.ShowUploadAccrual />
	</cffunction>

	<!--- Get ShowUploadAccrual Tax --->
	<cffunction name="getShowUploadAccrual" access="public" output="false" returntype="boolean">
		<cfreturn this.ShowUploadAccrual />
	</cffunction>

	<!--- Set bonusingrowthswitch --->
	<cffunction name="setBonusInGrowthSwitch" access="public" output="false" returntype="void">
		<cfargument name="bonusingrowthswitch" type="string" required="true" default="0" />
		<cfset this.bonusingrowthswitch = arguments.bonusingrowthswitch/>
	</cffunction>

	<!--- Get bonusingrowthswitch --->
	<cffunction name="getBonusInGrowthSwitch" access="public" output="false" returntype="boolean">
		<cfreturn this.bonusingrowthswitch />
	</cffunction>

	<!--- Set searchProductHierarchyExcludeList Tax --->
	<cffunction name="setSearchProductHierarchyExcludeList" access="public" output="false">
		<cfargument name="searchProductHierarchyExcludeList" type="string" required="true" default="0" />
		<cfset this.searchProductHierarchyExcludeList = arguments.searchProductHierarchyExcludeList />
	</cffunction>

	<!--- Get pgmGrpLevel3IsExclusion Tax --->
	<cffunction name="getSearchProductHierarchyExcludeList" access="public" output="false" returntype="string">
		<cfreturn this.searchProductHierarchyExcludeList />
	</cffunction>

	<!--- Set letters_company_logo_path--->
	<cffunction name="setletterscompanylogopath" access="public" output="false">
		<cfargument name="letters_company_logo_path" type="string" required="true" default="0" />
		<cfset this.letters_company_logo_path = arguments.letters_company_logo_path />
	</cffunction>

	<!--- Get letters_company_logo_path Tax --->
	<cffunction name="getletterscompanylogopath" access="public" output="false" returntype="string">
		<cfreturn this.letters_company_logo_path />
	</cffunction>

	<!--- Set payment_history_on--->
	<cffunction name="setpaymenthistoryon" access="public" output="false">
		<cfargument name="payment_history_on" type="string" required="true" default="0" />
		<cfset this.payment_history_on = arguments.payment_history_on />
	</cffunction>

	<!--- Get payment_history_on --->
	<cffunction name="getpaymenthistoryon" access="public" output="false" returntype="string">
		<cfreturn this.payment_history_on />
	</cffunction>

	<!--- Set BB_Allow_Vendor_Master_Search --->
	<cffunction name="setBBAllowVendorMasterSearch" access="public" output="false">
		<cfargument name="BB_Allow_Vendor_Master_Search" type="boolean" required="true" default="0" />
		<cfset this.BB_Allow_Vendor_Master_Search = arguments.BB_Allow_Vendor_Master_Search />
	</cffunction>

	<!--- Get BB_Allow_Vendor_Master_Search --->
	<cffunction name="getBBAllowVendorMasterSearch" access="public" output="false" returntype="boolean">
		<cfreturn this.BB_Allow_Vendor_Master_Search />
	</cffunction>

	<!--- Set Vendor_Search_In_BB_Payee_Page --->
	<cffunction name="setVendorSearchInBBPayeePage" access="public" output="false">
		<cfargument name="Vendor_Search_In_BB_Payee_Page" type="boolean" required="true" default="0" />
		<cfset this.Vendor_Search_In_BB_Payee_Page = arguments.Vendor_Search_In_BB_Payee_Page />
	</cffunction>

	<!--- Get Vendor_Search_In_BB_Payee_Page --->
	<cffunction name="getVendorSearchInBBPayeePage" access="public" output="false" returntype="boolean">
		<cfreturn this.Vendor_Search_In_BB_Payee_Page />
	</cffunction>

	<!--- Set BBAllowVendorCrossRefSearch --->
	<cffunction name="setBBAllowVendorCrossRefSearch" access="public" output="false">
		<cfargument name="BBAllowVendorCrossRefSearch" type="boolean" required="true" default="0" />
		<cfset this.BBAllowVendorCrossRefSearch = arguments.BBAllowVendorCrossRefSearch />
	</cffunction>

	<!--- Get BBAllowVendorCrossRefSearch --->
	<cffunction name="getBBAllowVendorCrossRefSearch" access="public" output="false" returntype="boolean">
		<cfreturn this.BBAllowVendorCrossRefSearch />
	</cffunction>

	<!--- Set DD_Reassign_Analyst_While_Changing_Pay_To --->
	<cffunction name="setDDReassignAnalystWhileChangingPayTo" access="public" output="false">
		<cfargument name="DD_Reassign_Analyst_While_Changing_Pay_To" type="boolean" required="true" default="0" />
		<cfset this.DD_Reassign_Analyst_While_Changing_Pay_To = arguments.DD_Reassign_Analyst_While_Changing_Pay_To />
	</cffunction>

	<!--- Get DD_Reassign_Analyst_While_Changing_Pay_To --->
	<cffunction name="getDDReassignAnalystWhileChangingPayTo" access="public" output="false" returntype="boolean">
		<cfreturn this.DD_Reassign_Analyst_While_Changing_Pay_To />
	</cffunction>

	<!--- Set DD_Assignment_Based_On_Shr_Ship_to --->
	<cffunction name="setDDAssignmentBasedOnShrShipto" access="public" output="false">
		<cfargument name="DDAssignmentBasedOnShrShipto" type="boolean" required="true" default="0" />
		<cfset this.DDAssignmentBasedOnShrShipto = arguments.DDAssignmentBasedOnShrShipto />
	</cffunction>

	<!--- Get DD_Assignment_Based_On_Shr_Ship_to --->
	<cffunction name="getDDAssignmentBasedOnShrShipto" access="public" output="false" returntype="boolean">
		<cfreturn this.DDAssignmentBasedOnShrShipto />
	</cffunction>

	<!--- Set DD_Allow_Negative_Amount_Credits --->
	<cffunction name="setDDAllowNegativeAmountCredits" access="public" output="false">
		<cfargument name="DDAllowNegativeAmountCredits" type="boolean" required="true" default="0" />
		<cfset this.DDAllowNegativeAmountCredits = arguments.DDAllowNegativeAmountCredits />
	</cffunction>

	<!--- Get DD_Allow_Negative_Amount_Credits --->
	<cffunction name="getDDAllowNegativeAmountCredits" access="public" output="false" returntype="boolean">
		<cfreturn this.DDAllowNegativeAmountCredits />
	</cffunction>

	<!--- Set DD_Change_Classification_Before_RFA --->
	<cffunction name="setDDChangeClassificationBeforeRFA" access="public" output="false">
		<cfargument name="DDChangeClassificationBeforeRFA" type="boolean" required="true" default="0" />
		<cfset this.DDChangeClassificationBeforeRFA = arguments.DDChangeClassificationBeforeRFA />
	</cffunction>

	<!--- Get DD_Change_Classification_Before_RFA --->
	<cffunction name="getDDChangeClassificationBeforeRFA" access="public" output="false" returntype="boolean">
		<cfreturn this.DDChangeClassificationBeforeRFA />
	</cffunction>

	<!--- Set DD_Allow_Write_Off--->
	<cffunction name="setDDAllowWriteOff" access="public" output="false">
		<cfargument name="DDAllowWriteOff" type="boolean" required="true" default="0" />
		<cfset this.DDAllowWriteOff = arguments.DDAllowWriteOff />
	</cffunction>

	<!--- Get DD_Allow_Write_Off --->
	<cffunction name="getDDAllowWriteOff" access="public" output="false" returntype="boolean">
		<cfreturn this.DDAllowWriteOff />
	</cffunction>

	<!--- Set DD_Sent_Reject_In_1510--->
	<cffunction name="setDDSentRejectIn1510" access="public" output="false">
		<cfargument name="DDSentRejectIn1510" type="boolean" required="true" default="0" />
		<cfset this.DDSentRejectIn1510 = arguments.DDSentRejectIn1510 />
	</cffunction>

	<!--- Get DD_Sent_Reject_In_1510 --->
	<cffunction name="getDDSentRejectIn1510" access="public" output="false" returntype="boolean">
		<cfreturn this.DDSentRejectIn1510 />
	</cffunction>

	<!--- Set DD_Close_With_Equal_BB_Amt --->
	<cffunction name="setDDCloseWithEqualBBAmt" access="public" output="false">
		<cfargument name="DDCloseWithEqualBBAmt" type="boolean" required="true" default="0" />
		<cfset this.DDCloseWithEqualBBAmt = arguments.DDCloseWithEqualBBAmt />
	</cffunction>

	<!--- Get DD_Close_With_Equal_BB_Amt --->
	<cffunction name="getDDCloseWithEqualBBAmt" access="public" output="false" returntype="boolean">
		<cfreturn this.DDCloseWithEqualBBAmt />
	</cffunction>

	<!--- Set PullBack_Start_Date --->
	<cffunction name="setPullBack_Start_Date" access="public" output="false">
		<cfargument name="PullBack_Start_Date" type="string" required="true" default="0" />
		<cfset this.PullBack_Start_Date = arguments.PullBack_Start_Date />
	</cffunction>

	<!--- Get PullBack_Start_Date --->
	<cffunction name="getPullBack_Start_Date" access="public" output="false" returntype="string">
		<cfreturn this.PullBack_Start_Date />
	</cffunction>

	<!--- Set Populate_180Day_From --->
	<cffunction name="setPopulate_180Day_From" access="public" output="false">
		<cfargument name="Populate_180Day_From" type="string" required="true" default="0" />
		<cfset this.Populate_180Day_From = arguments.Populate_180Day_From />
	</cffunction>

	<!--- Get Populate_180Day_From --->
	<cffunction name="getPopulate_180Day_From" access="public" output="false" returntype="string">
		<cfreturn this.Populate_180Day_From />
	</cffunction>

	<!--- Set BidRequest_Use_Price_ByDate --->
	<cffunction name="setBidRequestUsePriceByDate" access="public" output="false">
		<cfargument name="BidRequest_Use_Price_ByDate" type="string" required="true" default="0" />
		<cfset this.BidRequest_Use_Price_ByDate = arguments.BidRequest_Use_Price_ByDate />
	</cffunction>

	<!--- Get BidRequest_Use_Price_ByDate --->
	<cffunction name="getBidRequestUsePriceByDate" access="public" output="false" returntype="string">
		<cfreturn this.BidRequest_Use_Price_ByDate />
	</cffunction>

	<!--- Set BidRequest_Components_On --->
	<cffunction name="setBidRequestComponentsOn" access="public" output="false">
		<cfargument name="BidRequest_Components_On" type="boolean" required="true" default="0" />
		<cfset this.BidRequest_Components_On = arguments.BidRequest_Components_On />
	</cffunction>

	<!--- Get BidRequest_Components_On --->
	<cffunction name="getBidRequestComponentsOn" access="public" output="false" returntype="boolean">
		<cfreturn this.BidRequest_Components_On />
	</cffunction>

	<!--- Dev Note: KAL; D8067 --->
	<!--- Set Dont Allow Revise untill Success Ack from SAP --->
	<cffunction name="setDontReviseUntillSAPokAck" access="public" output="false">
		<cfargument name="DontRevise_Untill_SAP_OKack" type="boolean" required="true" default="0" />
		<cfset this.DontRevise_Untill_SAP_OKack = arguments.DontRevise_Untill_SAP_OKack />
	</cffunction>

	<!--- Get Dont Allow Revise untill Success Ack from SAP --->
	<cffunction name="getDontReviseUntillSAPokAck" access="public" output="false" returntype="boolean">
		<cfreturn this.DontRevise_Untill_SAP_OKack />
	</cffunction>
	<!--- End Note: KAL; D8067 --->

	<!--- Set LumpSum Distributors --->
	<cffunction name="setLumpSumDistributors" access="public" output="false">
		<cfargument name="LumpSumDistributors" type="boolean" required="true" default="0" />
		<cfset this.ShowLumpSumDistributors = arguments.LumpSumDistributors />
	</cffunction>

	<!--- Get LumpSum Distributors --->
	<cffunction name="getLumpSumDistributors" access="public" output="false" returntype="boolean">
		<cfreturn this.ShowLumpSumDistributors />
	</cffunction>

	<!--- Set Show_BB_Route --->
	<cffunction name="setShow_BB_Route" access="public" output="false">
		<cfargument name="Show_BB_Route" type="boolean" required="true" default="0" />
		<cfset this.Show_BB_Route = arguments.Show_BB_Route />
	</cffunction>

	<!--- Get LumpSum Distributors --->
	<cffunction name="getShow_BB_Route" access="public" output="false" returntype="boolean">
		<cfreturn this.Show_BB_Route />
	</cffunction>

	<!--- Set send_distributor_broker_email --->
	<cffunction name="setsenddistributorbrokeremail" access="public" output="false">
		<cfargument name="send_distributor_broker_email" type="boolean" required="true" default="0" />
		<cfset this.send_distributor_broker_email = arguments.send_distributor_broker_email />
	</cffunction>

	<!--- Get send_distributor_broker_email--->
	<cffunction name="getsenddistributorbrokeremail" access="public" output="false" returntype="boolean">
		<cfreturn this.send_distributor_broker_email />
	</cffunction>

	<!--- Set Requester / Approver --->
	<cffunction name="set_Requester_Approver" access="public" output="false">
		<cfargument name="Requester_Approver" type="boolean" required="true" default="0" />
		<cfset this.Display_Requester_Approver = arguments.Requester_Approver />
	</cffunction>

	<!--- Get Requester / Approver --->
	<cffunction name="get_Requester_Approver" access="public" output="false" returntype="boolean">
		<cfreturn this.Display_Requester_Approver />
	</cffunction>

	<!--- Set Requester / Approver Position --->
	<cffunction name="set_Requester_Approver_Position" access="public" output="false">
		<cfargument name="Requester_Approver_Position" type="boolean" required="true" default="0" />
		<cfset this.Display_Requester_Approver_Position = arguments.Requester_Approver_Position />
	</cffunction>

	<!--- Get Requester / Approver Position --->
	<cffunction name="get_Requester_Approver_Position" access="public" output="false" returntype="boolean">
		<cfreturn this.Display_Requester_Approver_Position />
	</cffunction>

	<!--- Set hide BSA Users --->
	<cffunction name="setHide_BSA_Users" access="public" output="false">
		<cfargument name="Hide_BSA_Users" type="boolean" required="true" default="0" />
		<cfset this.Hide_BSA_Users = arguments.Hide_BSA_Users />
	</cffunction>

	<!--- Get Hide BSA Users --->
	<cffunction name="getHide_BSA_Users" access="public" output="false" returntype="boolean">
		<cfreturn this.Hide_BSA_Users />
	</cffunction>

	<!--- Dev Note: KAL; 7916 --->
	<!--- NewPassword Setter --->
	<cffunction name="setNewPassword" access="public" output="false">
		<cfargument name="NewPassword" type="boolean" required="true" />
		<cfset this.NewPassword = arguments.NewPassword />
	</cffunction>

	<!--- NewPassword Getter --->
	<cffunction name="getNewPassword" access="public" returntype="boolean" output="false">
		<cfreturn this.NewPassword />
	</cffunction>

	<!--- TempPassword setter --->
	<cffunction name="setTempPassword" access="public" output="false">
		<cfargument name="TempPassword" type="boolean" required="true" />
		<cfset this.TempPassword = arguments.TempPassword />
	</cffunction>

	<!--- TempPassword Getter --->
	<cffunction name="getTempPassword" access="public" returntype="boolean" output="false">
		<cfreturn this.TempPassword />
	</cffunction>

	<!--- AdminPassword setter --->
	<cffunction name="setAdminPassword" access="public" output="false">
		<cfargument name="AdminPassword" type="boolean" required="true" />
		<cfset this.AdminPassword = arguments.AdminPassword />
	</cffunction>

	<!--- AdminPassword Getter --->
	<cffunction name="getAdminPassword" access="public" returntype="boolean" output="false">
		<cfreturn this.AdminPassword />
	</cffunction>

	<!--- Password Change Days setter --->
	<cffunction name="setPasswordChangeDays" access="public" output="false">
		<cfargument name="PasswordChangeDays" type="numeric" required="true" />
		<cfset this.PasswordChangeDays = arguments.PasswordChangeDays />
	</cffunction>

	<!--- Password Change Days Getter --->
	<cffunction name="getPasswordChangeDays" access="public" returntype="numeric" output="false">
		<cfreturn this.PasswordChangeDays />
	</cffunction>

	<!--- PasswordMinLen setter --->
	<cffunction name="setPasswordMinLen" access="public" output="false">
		<cfargument name="PasswordMinLen" type="numeric" required="true" />
		<cfset this.PasswordMinLen = arguments.PasswordMinLen />
	</cffunction>

	<!--- PasswordMinLen Getter --->
	<cffunction name="getPasswordMinLen" access="public" returntype="numeric" output="false">
		<cfreturn this.PasswordMinLen />
	</cffunction>

	<!--- PasswordHistory setter --->
	<cffunction name="setPasswordHistory" access="public" output="false">
		<cfargument name="PasswordHistory" type="numeric" required="true" />
		<cfset this.PasswordHistory = arguments.PasswordHistory />
	</cffunction>

	<!--- PasswordHistory Getter --->
	<cffunction name="getPasswordHistory" access="public" returntype="numeric" output="false">
		<cfreturn this.PasswordHistory />
	</cffunction>

	<!--- PasswordUpperChar setter --->
	<cffunction name="setPasswordUpperChar" access="public" output="false">
		<cfargument name="PasswordUpperChar" type="boolean" required="true" />
		<cfset this.PasswordUpperChar = arguments.PasswordUpperChar />
	</cffunction>

	<!--- PasswordUpperChar Getter --->
	<cffunction name="getPasswordUpperChar" access="public" returntype="boolean" output="false">
		<cfreturn this.PasswordUpperChar />
	</cffunction>

	<!--- PasswordLowerChar setter --->
	<cffunction name="setPasswordLowerChar" access="public" output="false">
		<cfargument name="PasswordLowerChar" type="boolean" required="true" />
		<cfset this.PasswordLowerChar = arguments.PasswordLowerChar />
	</cffunction>

	<!--- PasswordLowerChar Getter --->
	<cffunction name="getPasswordLowerChar" access="public" returntype="boolean" output="false">
		<cfreturn this.PasswordLowerChar />
	</cffunction>

	<!--- PasswordNumChar setter --->
	<cffunction name="setPasswordNumChar" access="public" output="false">
		<cfargument name="PasswordNumChar" type="boolean" required="true" />
		<cfset this.PasswordNumChar = arguments.PasswordNumChar />
	</cffunction>

	<!--- PasswordNumChar Getter --->
	<cffunction name="getPasswordNumChar" access="public" returntype="boolean" output="false">
		<cfreturn this.PasswordNumChar />
	</cffunction>

	<!--- PasswordSpecialChar setter --->
	<cffunction name="setPasswordSpecialChar" access="public" output="false">
		<cfargument name="PasswordSpecialChar" type="boolean" required="true" />
		<cfset this.PasswordSpecialChar = arguments.PasswordSpecialChar />
	</cffunction>

	<!--- PasswordSpecialChar Getter --->
	<cffunction name="getPasswordSpecialChar" access="public" returntype="boolean" output="false">
		<cfreturn this.PasswordSpecialChar />
	</cffunction>
	<!--- End Note: KAL; 7916 --->

	<!--- separateIdPasswordEmail Setter --->
	<cffunction name="setSeparateIdPasswordEmail" access="public" output="false">
		<cfargument name="separateIdPasswordEmail" type="boolean" required="true" />
		<cfset this.separateIdPasswordEmail = arguments.separateIdPasswordEmail />
	</cffunction>

	<!--- separateIdPasswordEmail Getter --->
	<cffunction name="getSeparateIdPasswordEmail" access="public" returntype="boolean" output="false">
		<cfreturn this.separateIdPasswordEmail />
	</cffunction>

	<!--- Dev Note: Clay 9254   --->
	<!--- defaultPasswordOn setter --->
	<cffunction name="setDefaultPasswordOn" access="public" output="false">
		<cfargument name="defaultPasswordOn" type="numeric" required="true" />
		<cfset this.defaultPasswordOn = arguments.defaultPasswordOn />
	</cffunction>

	<!--- defaultPasswordOn Getter --->
	<cffunction name="getDefaultPasswordOn" access="public" returntype="numeric" output="false">
		<cfreturn this.defaultPasswordOn />
	</cffunction>

	<!--- defaultPasswordForNewUser setter --->
	<cffunction name="setDefaultPasswordForNewUsers" access="public" output="false">
		<cfargument name="defaultPasswordForNewUsers" type="string" required="true" />
		<cfset this.defaultPasswordForNewUsers = arguments.defaultPasswordForNewUsers />
	</cffunction>

	<!--- defaultPasswordForNewUser Getter --->
	<cffunction name="getDefaultPasswordForNewUsers" access="public" returntype="string" output="false">
		<cfreturn this.DefaultPasswordForNewUsers />
	</cffunction>
	<!--- End Dev Note: Clay 9254   --->

	<!--- HQpositionsOn setter --->
	<cffunction name="setHQpositionsOn" access="public" output="false">
		<cfargument name="HQpositionsOn" type="boolean" required="true" />
		<cfset this.HQpositionsOn = arguments.HQpositionsOn />
	</cffunction>

	<!--- HQpositionsOn Getter --->
	<cffunction name="getHQpositionsOn" access="public" returntype="boolean" output="false">
		<cfreturn this.HQpositionsOn />
	</cffunction>
	<!--- End Note: GV; 8181 --->

	<!--- Dev Note: Milan; 8289 --->
	<!--- Set Payment History Report --->
	<cffunction name="set_Report_Payment_History" access="public" output="false">
		<cfargument name="Report_Payment_History" type="boolean" required="true" default="0" />
		<cfset this.Report_Payment_History = arguments.Report_Payment_History />
	</cffunction>

	<!--- Get Payment History Report --->
	<cffunction name="get_Report_Payment_History" access="public" output="false" returntype="boolean">
		<cfreturn this.Report_Payment_History />
	</cffunction>
	<!--- End Note: Milan; 8289 --->

	<!--- Dev Note: CPM 8275 --->
	<!--- Set Upload Document Privacy Off --->
	<cffunction name="setUploadDocumentPrivacyOff" access="public" output="false">
		<cfargument name="Upload_Document_Privacy_Off" type="boolean" required="true" default="0" />
		<cfset this.Upload_Document_Privacy_Off = arguments.Upload_Document_Privacy_Off />
	</cffunction>

	<!--- Get Upload Document Privacy Off --->
	<cffunction name="getUploadDocumentPrivacyOff" access="public" output="false" returntype="boolean">
		<cfreturn this.Upload_Document_Privacy_Off />
	</cffunction>
	<!--- End Note: CPM 8275 --->

	<!--- Set Divide_Pgm_Vol_4_Groups --->
	<cffunction name="setDivideProgramVolumeForGroups" access="public" output="false">
		<cfargument name="Divide_Pgm_Vol_4_Groups" type="numeric" required="true" default="0" />
		<cfset this.Divide_Pgm_Vol_4_Groups = arguments.Divide_Pgm_Vol_4_Groups />
	</cffunction>

	<!--- Get Divide_Pgm_Vol_4_Groups --->
	<cffunction name="getDivideProgramVolumeForGroups" access="public" output="false" returntype="numeric">
		<cfreturn this.Divide_Pgm_Vol_4_Groups />
	</cffunction>

	<!--- Set Pgm_Vol_Show_Groups --->
	<cffunction name="setProgramVolumeShowGroups" access="public" output="false">
		<cfargument name="Pgm_Vol_Show_Groups" type="boolean" required="true" default="0" />
		<cfset this.Pgm_Vol_Show_Groups = arguments.Pgm_Vol_Show_Groups />
	</cffunction>

	<!--- Get Pgm_Vol_Show_Groups --->
	<cffunction name="getProgramVolumeShowGroups" access="public" output="false" returntype="boolean">
		<cfreturn this.Pgm_Vol_Show_Groups />
	</cffunction>

	<!--- Set ShowManagerDetailsOnViewProgram --->
	<cffunction name="setShowManagerDetailsOnViewProgram" access="public" output="false">
		<cfargument name="ShowManagerDetailsOnViewProgram" type="boolean" required="true" default="0" />
		<cfset this.ShowManagerDetailsOnViewProgram = arguments.ShowManagerDetailsOnViewProgram />
	</cffunction>

	<!--- Get ShowManagerDetailsOnViewProgram --->
	<cffunction name="getShowManagerDetailsOnViewProgram" access="public" output="false" returntype="boolean">
		<cfreturn this.ShowManagerDetailsOnViewProgram />
	</cffunction>

	<!--- Dev Note: CPM 8223 --->
	<!--- Set ViewPgmSortBy --->
	<cffunction name="setViewPgmSortBy" access="public" output="false">
		<cfargument name="ViewPgmSortBy" type="numeric" required="true" default="0" />
		<cfset this.ViewPgmSortBy = arguments.ViewPgmSortBy />
	</cffunction>

	<!--- Get getViewPgmSortBy --->
	<cffunction name="getViewPgmSortBy" access="public" output="false" returntype="boolean">
		<cfreturn this.ViewPgmSortBy />
	</cffunction>

	<!--- Set crucibleOn --->
	<cffunction name="setCrucibleOn" access="public" output="false">
		<cfargument name="crucibleOn" type="numeric" required="true" default="0" />
		<cfset this.crucibleOn = arguments.crucibleOn />
	</cffunction>

	<!--- Get crucibleOn --->
	<cffunction name="getCrucibleOn" access="public" output="false" returntype="boolean">
		<cfreturn this.crucibleOn />
	</cffunction>

	<!--- Set brokerTradeQuestOn --->
	<cffunction name="setBrokerTradeQuestOn" access="public" output="false">
		<cfargument name="brokerTradeQuestOn" type="numeric" required="true" default="0" />
		<cfset this.brokerTradeQuestOn = arguments.brokerTradeQuestOn />
	</cffunction>

	<!--- Get brokerTradeQuestOn --->
	<cffunction name="getBrokerTradeQuestOn" access="public" output="false" returntype="boolean">
		<cfreturn this.brokerTradeQuestOn />
	</cffunction>

	<!--- Dev Note: Milan; 8452 --->
	<!--- Set Program Category --->
	<cffunction name="setProgramCategory" access="public" output="false">
		<cfargument name="Program_Category" type="boolean" required="true" default="0" />
		<cfset this.ShowProgramCategory = arguments.Program_Category />
	</cffunction>

	<!--- Get Program Category --->
	<cffunction name="getProgramCategory" access="public" output="false" returntype="boolean">
		<cfreturn this.ShowProgramCategory />
	</cffunction>
	<!--- End Note: Milan; 8452 --->

	<!--- Set PullbacksOn --->
	<cffunction name="setPullbacksOn" access="public" output="false">
		<cfargument name="PullbacksOn" type="boolean" required="true" default="0" />
		<cfset this.PullbacksOn = arguments.PullbacksOn />
	</cffunction>

	<!--- Get PullbacksOn --->
	<cffunction name="getPullbacksOn" access="public" output="false" returntype="boolean">
		<cfreturn this.PullbacksOn />
	</cffunction>

	<!--- Set pullbackLabel --->	<!--- Dev Note: DRK 9326 --->
	<cffunction name="setPullbackLabel" access="public" output="false">
		<cfargument name="pullbackLabel" type="string" required="true" default="0" />
		<cfset this.pullbackLabel = arguments.pullbackLabel />
	</cffunction>

	<!--- Get pullbackLabel --->
	<cffunction name="getPullbackLabel" access="public" output="false" returntype="string">
		<cfreturn this.pullbackLabel />
	</cffunction>

	<cffunction name="getPullbackLabelLower" access="public" output="false" returntype="string">
		<cfreturn LCase(this.pullbackLabel) />
	</cffunction>

	<!--- Set pgmPostApprovalStatus --->
	<cffunction name="setPgmPostApprovalStatus" access="public" output="false">
		<cfargument name="pgmPostApprovalStatus" type="numeric" required="true" default="0" />
		<cfset this.pgmPostApprovalStatus = arguments.pgmPostApprovalStatus />
	</cffunction>

	<!--- Get pgmPostApprovalStatus --->
	<cffunction name="getPgmPostApprovalStatus" access="public" output="false" returntype="boolean">
		<cfreturn this.pgmPostApprovalStatus />
	</cffunction>

	<!--- Set pgmPostApprovalStatusType --->  <!--- Dev Note: DRK 6122 --->
	<cffunction name="setPgmPostApprovalStatusType" access="public" output="false">
		<cfargument name="pgmPostApprovalStatusType" type="numeric" required="true" default="0" />
		<cfset this.pgmPostApprovalStatusType = arguments.pgmPostApprovalStatusType />
	</cffunction>

	<!--- Get pgmPostApprovalStatusType --->
	<cffunction name="getPgmPostApprovalStatusType" access="public" output="false" returntype="numeric">
		<cfreturn this.pgmPostApprovalStatusType />
	</cffunction>

	<!--- Dev Note: Milan; 8469 --->
	<!--- Set Confidentiality Agreement --->
	<cffunction name="setConfidentialityAgreementStatus" access="public" output="false">
		<cfargument name="Confidentiality_Agreement_Status" type="boolean" required="true" default="0" />
		<cfset this.ConfidentialityAgreement = arguments.Confidentiality_Agreement_Status />
	</cffunction>

	<!--- Get Program Category --->
	<cffunction name="getConfidentialityAgreementStatus" access="public" output="false" returntype="boolean">
		<cfreturn this.ConfidentialityAgreement />
	</cffunction>
	<!--- End Note: Milan; 8469 --->

	<!--- Dev Note: Milan 8482 --->
	<!--- Set Remote Events Email --->
	<cffunction name="setRemoteEventsEmail" access="public" output="false">
		<cfargument name="RemoteEventsEmail" type="string" required="true" />
		<cfset this.RemoteEventsEmail = arguments.RemoteEventsEmail />
	</cffunction>

	<!--- Get Remote Events Email --->
	<cffunction name="getRemoteEventsEmail" access="public" output="false" returntype="string">
		<cfif trim(this.RemoteEventsEmail) eq "">
			<cfreturn "remote_events@bigredflame.com">
		<cfelse>
			<cfreturn this.RemoteEventsEmail>
		</cfif>
	</cffunction>
	<!--- Dev Note: Milan 8482 --->

	<!--- Dev Note: Milan 8516 --->
	<!--- Set Program Scorecard values --->
	<cffunction name="setProgramScoreCard" access="public" output="false">
		<cfargument name="OperatorDistributor" type="string" required="true" default="0" />
		<cfset this.OperatorDistributorProgramScoreCard = arguments.OperatorDistributor />
	</cffunction>

	<!--- Get Program Scorecard values --->
	<cffunction name="getProgramScoreCard" access="public" output="false" returntype="string">
		<cfreturn this.OperatorDistributorProgramScoreCard>
	</cffunction>
	<!--- Dev Note: Milan 8516 --->

	<!--- Dev Note: Milan 8471 --->
	<!--- Set Number Of Days For Mini Item Master --->
	<cffunction name="setNumberOfDaysForMiniItemMaster" access="public" output="false">
		<cfargument name="NumberOfDaysForMiniItemMaster" type="numeric" required="true"/>
		<cfset this.NumberOfDaysForMiniItemMaster = arguments.NumberOfDaysForMiniItemMaster />
	</cffunction>

	<!--- Get Number Of Days For Mini Item Master --->
	<cffunction name="getNumberOfDaysForMiniItemMaster" access="public" output="false" returntype="numeric">
		<cfif trim(this.NumberOfDaysForMiniItemMaster) eq 0>
			<cfreturn 180>
		<cfelse>
			<cfreturn this.NumberOfDaysForMiniItemMaster>
		</cfif>
	</cffunction>
	<!--- Dev Note: Milan 8471 --->

	<!---- Set/Get Display Evaluation Notes : 8506 --->
	<cffunction name="setDisplayEvaluationNotes" access="public" output="false">
		<cfargument name="Display_Evaluation_Notes" type="numeric" required="true" />
		<cfset this.Display_Evaluation_Notes = arguments.Display_Evaluation_Notes />
	</cffunction>

	<cffunction name="getDisplayEvaluationNotes" access="public" output="false" returntype="numeric">
		<cfreturn this.Display_Evaluation_Notes>
	</cffunction>

	<!---- Set/Get Remove Broker Selection : 8536 --->
	<cffunction name="setRemoveBrokerSelection" access="public" output="false">
		<cfargument name="Remove_Broker_Selection" type="numeric" required="true" />
		<cfset this.Remove_Broker_Selection = arguments.Remove_Broker_Selection />
	</cffunction>

	<cffunction name="getRemoveBrokerSelection" access="public" output="false" returntype="numeric">
		<cfreturn this.Remove_Broker_Selection>
	</cffunction>

	<!---- Set/Get appErrorEmailLinkAlone --->
	<cffunction name="setAppErrorEmailLinkAlone" access="public" output="false">
		<cfargument name="appErrorEmailLinkAlone" type="numeric" required="true" />
		<cfset this.appErrorEmailLinkAlone = arguments.appErrorEmailLinkAlone />
	</cffunction>

	<cffunction name="getAppErrorEmailLinkAlone" access="public" output="false" returntype="numeric">
		<cfreturn this.appErrorEmailLinkAlone>
	</cffunction>

	<!--- Set BidRequest_Display_Allowance --->
	<cffunction name="setBidRequestDisplayAllowance" access="public" output="false">
		<cfargument name="BidRequest_Display_Allowance" type="boolean" required="true" default="0" />
		<cfset this.BidRequest_Display_Allowance = arguments.BidRequest_Display_Allowance />
	</cffunction>

	<!--- Get BidRequest_Display_Allowance --->
	<cffunction name="getBidRequestDisplayAllowance" access="public" output="false" returntype="boolean">
		<cfreturn this.BidRequest_Display_Allowance />
	</cffunction>

	<!--- Set modify_agree_progran --->
	<cffunction name="setmodifyagreeprogram" access="public" output="false">
		<cfargument name="modify_agree_program" type="boolean" required="true" default="0" />
		<cfset this.modify_agree_program = arguments.modify_agree_program />
	</cffunction>

	<!--- Get modify_agree_progran --->
	<cffunction name="getmodifyagreeprogram" access="public" output="false" returntype="boolean">
		<cfreturn this.modify_agree_program />
	</cffunction>

	<!--- Set use_cost_multiplier --->
	<cffunction name="setusecostmultiplier" access="public" output="false">
		<cfargument name="use_cost_multiplier" type="boolean" required="true" default="0" />
		<cfset this.use_cost_multiplier = arguments.use_cost_multiplier />
	</cffunction>

	<!--- Get use_cost_multiplier --->
	<cffunction name="getusecostmultiplier" access="public" output="false" returntype="boolean">
		<cfreturn this.use_cost_multiplier />
	</cffunction>

	<!--- Set Use_DC_SO_Base_sales --->
	<cffunction name="setUseDCSOBasesales" access="public" output="false">
		<cfargument name="Use_DC_SO_Base_sales" type="boolean" required="true" default="0" />
		<cfset this.Use_DC_SO_Base_sales = arguments.Use_DC_SO_Base_sales />
	</cffunction>

	<!--- Get Use_DC_SO_Base_sales --->
	<cffunction name="getUseDCSOBasesales" access="public" output="false" returntype="boolean">
		<cfreturn this.Use_DC_SO_Base_sales />
	</cffunction>

	<!---- Set/Get Display Eligible RSP : 7920 --->
	<cffunction name="setDisplayEligibleRSP" access="public" output="false">
		<cfargument name="Display_Eligible_RSP" type="numeric" required="true" />
		<cfset this.Display_Eligible_RSP = arguments.Display_Eligible_RSP />
	</cffunction>

	<cffunction name="getDisplayEligibleRSP" access="public" output="false" returntype="numeric">
		<cfreturn this.Display_Eligible_RSP>
	</cffunction>

	<!---- BBDisplayResubmit --->
	<cffunction name="setBBDisplayResubmit" access="public" output="false">
		<cfargument name="BBDisplayResubmit" type="numeric" required="true" />
		<cfset this.BBDisplayResubmit = arguments.BBDisplayResubmit />
	</cffunction>

	<cffunction name="getBBDisplayResubmit" access="public" output="false" returntype="numeric">
		<cfreturn this.BBDisplayResubmit>
	</cffunction>

	<!---- BBAllowReverse --->
	<cffunction name="setBBAllowReverse" access="public" output="false">
		<cfargument name="BBAllowReverse" type="numeric" required="true" />
		<cfset this.BBAllowReverse = arguments.BBAllowReverse />
	</cffunction>

	<cffunction name="getBBAllowReverse" access="public" output="false" returntype="numeric">
		<cfreturn this.BBAllowReverse>
	</cffunction>

	<!---- BBAllowReverse --->
	<cffunction name="setUseItemCustPrice" access="public" output="false">
		<cfargument name="Use_Item_Cust_Price" type="numeric" required="true" />
		<cfset this.Use_Item_Cust_Price = arguments.Use_Item_Cust_Price />
	</cffunction>

	<cffunction name="getUseItemCustPrice" access="public" output="false" returntype="numeric">
		<cfreturn this.Use_Item_Cust_Price>
	</cffunction>

	<!--- Dev Note: Milan 8521 --->
	<!--- Set status for Showing Billback Excel Report --->
	<cffunction name="setShowBBExcelReport" access="public" output="false">
		<cfargument name="ShowBBExcelReport" type="numeric" required="true"/>
		<cfset this.ShowBBExcelReport = arguments.ShowBBExcelReport />
	</cffunction>

	<!--- Get status for Showing Billback Excel Report --->
	<cffunction name="getShowBBExcelReport" access="public" output="false" returntype="numeric">
		<cfreturn this.ShowBBExcelReport>
	</cffunction>
	<!--- End Note: Milan 8521 --->

	<!--- set displayInterfaceFlagsSet1 --->
	<cffunction name="setDisplayInterfaceFlagsSet1" access="public" output="false">
		<cfargument name="displayInterfaceFlagsSet1" type="numeric" required="true"/>
		<cfset this.displayInterfaceFlagsSet1 = arguments.displayInterfaceFlagsSet1 />
	</cffunction>

	<!--- get displayInterfaceFlagsSet1 --->
	<cffunction name="getDisplayInterfaceFlagsSet1" access="public" output="false" returntype="numeric">
		<cfreturn this.displayInterfaceFlagsSet1>
	</cffunction>

	<!--- Dev Note: Milan 9165 --->
	<!--- set ManualBillback --->
	<cffunction name="setShowManualBillback" access="public" output="false">
		<cfargument name="ManualBillback" type="numeric" required="true"/>
		<cfset this.ShowManualBillBack = arguments.ManualBillback />
	</cffunction>

	<!--- get ManualBillback --->
	<cffunction name="getShowManualBillback" access="public" output="false" returntype="numeric">
		<cfreturn this.ShowManualBillback>
	</cffunction>

	<!--- set AutoBillback --->
	<cffunction name="setShowAutoBillback" access="public" output="false">
		<cfargument name="AutoBillback" type="numeric" required="true"/>
		<cfset this.ShowAutoBillBack = arguments.AutoBillback />
	</cffunction>

	<!--- get AutoBillback --->
	<cffunction name="getShowAutoBillback" access="public" output="false" returntype="numeric">
		<cfreturn this.ShowAutoBillback>
	</cffunction>

	<!--- Set AutoBillBackType --->
	<cffunction name="setAutoBillBackType" access="public" output="false">
		<cfargument name="AutoBillBackType" type="numeric" required="true" default="0" />
		<cfset this.AutoBillBackType = arguments.AutoBillBackType />
	</cffunction>

	<!--- Get AutoBillBackType --->
	<cffunction name="getAutoBillBackType" access="public" output="false" returntype="boolean">
		<cfreturn this.AutoBillBackType />
	</cffunction>
	<!--- End Note: Milan 9165 --->

	<!--- Set PriceList_displayed_Right_Click --->
	<cffunction name="setPriceListdisplayedRightClick" access="public" output="false">
		<cfargument name="PriceList_displayed_Right_Click" type="numeric" required="true" default="0" />
		<cfset this.PriceList_displayed_Right_Click = arguments.PriceList_displayed_Right_Click />
	</cffunction>

	<!--- Get PriceList_displayed_Right_Click --->
	<cffunction name="getPriceListdisplayedRightClick" access="public" output="false" returntype="boolean">
		<cfreturn this.PriceList_displayed_Right_Click />
	</cffunction>
	<!--- End Note: GV 9284 --->

	<!--- Set View_Trade_Checkbook --->
	<cffunction name="setView_Trade_Checkbook" access="public" output="false">
		<cfargument name="View_Trade_Checkbook" type="boolean" required="true" default="0" />
		<cfset this.View_Trade_Checkbook = arguments.View_Trade_Checkbook />
	</cffunction>

	<!--- Get View_Trade_Checkbook --->
	<cffunction name="getView_Trade_Checkbook" access="public" output="false" returntype="boolean">
		<cfreturn this.View_Trade_Checkbook />
	</cffunction>
	<!--- End Note: BJF 9313 --->

	<!--- Set View_Auto_Checkbook --->
	<cffunction name="setView_Auto_Checkbook" access="public" output="false">
		<cfargument name="View_Auto_Checkbook" type="boolean" required="true" default="0" />
		<cfset this.View_Auto_Checkbook = arguments.View_Auto_Checkbook />
	</cffunction>

	<!--- Get View_Trade_Checkbook --->
	<cffunction name="getView_Auto_Checkbook" access="public" output="false" returntype="boolean">
		<cfreturn this.View_Auto_Checkbook />
	</cffunction>
	<!--- End Note: BJF 9313 --->

	<!--- Set Email_Auto_Renewed_Programs --->
	<cffunction name="setEmail_Auto_Renewed_Programs" access="public" output="false">
		<cfargument name="Email_Auto_Renewed_Programs" type="boolean" required="true" default="0" />
		<cfset this.Email_Auto_Renewed_Programs = arguments.Email_Auto_Renewed_Programs />
	</cffunction>

	<!--- Get Email_Auto_Renewed_Programs --->
	<cffunction name="getEmail_Auto_Renewed_Programs" access="public" output="false" returntype="boolean">
		<cfreturn this.Email_Auto_Renewed_Programs />
	</cffunction>
	<!--- End Note: BJF 9316 --->

	<!--- Dev Note: Milan 65876 --->
	<!--- Set Notify_RSP_Only_NotAllHQUser --->
	<cffunction name="setNotify_RSP_Only_NotAllHQUser" access="public" output="false">
		<cfargument name="Notify_RSP_Only_NotAllHQUser" type="boolean" required="true" default="0" />
		<cfset this.Notify_RSP_Only_NotAllHQUser = arguments.Notify_RSP_Only_NotAllHQUser />
	</cffunction>

	<!--- Get Notify_RSP_Only_NotAllHQUser --->
	<cffunction name="getNotify_RSP_Only_NotAllHQUser" access="public" output="false" returntype="boolean">
		<cfreturn this.Notify_RSP_Only_NotAllHQUser />
	</cffunction>
	<!--- End Note: Milan 65876 --->

	<!--- Dev Note: Milan 76235 --->
	<cffunction name="setSend_RFA_Agree_Emails_To_CRA_Users" access="public" output="false">
		<cfargument name="Send_RFA_Agree_Emails_To_CRA_Users" type="boolean" required="true" default="0" />
		<cfset this.Send_RFA_Agree_Emails_To_CRA_Users = arguments.Send_RFA_Agree_Emails_To_CRA_Users />
	</cffunction>

	<cffunction name="getSend_RFA_Agree_Emails_To_CRA_Users" access="public" output="false" returntype="boolean">
		<cfreturn this.Send_RFA_Agree_Emails_To_CRA_Users />
	</cffunction>
	<!--- End Note: Milan 76235 --->

	<!--- Dev Note: Milan 9360 --->
	<!--- Set View Legacy ID --->
	<cffunction name="setView_Legacy_ID" access="public" output="false">
		<cfargument name="View_Legacy_ID" type="boolean" required="true" default="0" />
		<cfset this.View_Legacy_ID = arguments.View_Legacy_ID />
	</cffunction>

	<!--- Get View Legacy ID --->
	<cffunction name="getView_Legacy_ID" access="public" output="false" returntype="boolean">
		<cfreturn this.View_Legacy_ID />
	</cffunction>

	<!--- Set Modify Legacy ID --->
	<cffunction name="setModify_Legacy_ID" access="public" output="false">
		<cfargument name="Modify_Legacy_ID" type="boolean" required="true" default="0" />
		<cfset this.Modify_Legacy_ID = arguments.Modify_Legacy_ID />
	</cffunction>

	<!--- Get Modify Legacy ID --->
	<cffunction name="getModify_Legacy_ID" access="public" output="false" returntype="boolean">
		<cfreturn this.Modify_Legacy_ID />
	</cffunction>
	<!--- End Note: Milan 9360 --->

	<!--- Set RevisionTypesOn --->
	<cffunction name="setRevisionTypesOn" access="public" output="false">
		<cfargument name="RevisionTypesOn" type="boolean" required="true" default="0" />
		<cfset this.RevisionTypesOn = arguments.RevisionTypesOn />
	</cffunction>

	<!--- Get RevisionTypesOn --->
	<cffunction name="getRevisionTypesOn" access="public" output="false" returntype="boolean">
		<cfreturn this.RevisionTypesOn />
	</cffunction>
	<!--- End Note: GV 9391 --->

	<!--- Dev Note: Clay 9254   --->
	<!--- Set WelcomeLetterOn --->
	<cffunction name="setWelcomeLetterOn" access="public" output="false">
		<cfargument name="WelcomeLetterOn" type="boolean" required="true" default="0" />
		<cfset this.WelcomeLetterOn = arguments.WelcomeLetterOn />
	</cffunction>

	<!--- Get WelcomeLetterOn --->
	<cffunction name="getWelcomeLetterOn" access="public" output="false" returntype="boolean">
		<cfreturn this.WelcomeLetterOn />
	</cffunction>

	<!--- Get Password Key --->
	<cffunction name="getPasswordKey" access="public" output="false" returntype="string">
		<cfreturn this.passwordKey />
	</cffunction>

	<cffunction name="setPasswordKey" access="public" output="false">
		<cfargument name="passwordKey" type="string" required="true">
		<cfset this.passwordKey = arguments.passwordKey />
	</cffunction>
	<!--- End Note: Clay 9254 --->

	<!---Dev Note: DRK 9674 --->
	<cffunction name="setTemplateRestrictGroupLevel" access="public" output="false">
		<cfargument name="templateRestrictGroupLevel" type="boolean" required="true" default="0" />
		<cfset this.templateRestrictGroupLevel = arguments.templateRestrictGroupLevel />
	</cffunction>

	<!--- Get templateRestrictGroupLevel --->
	<cffunction name="getTemplateRestrictGroupLevel" access="public" output="false" returntype="boolean">
		<cfreturn this.templateRestrictGroupLevel />
	</cffunction>

	<!---Dev Note: DRK 9679 --->
	<cffunction name="setRestrictHierarchyLevelOnClassCode" access="public" output="false">
		<cfargument name="restrictHierarchyLevelOnClassCode" type="string" required="true" default="" />
		<cfset this.restrictHierarchyLevelOnClassCode = arguments.restrictHierarchyLevelOnClassCode />
	</cffunction>

	<!--- Get templateRestrictGroupLevel --->
	<cffunction name="getRestrictHierarchyLevelOnClassCode" access="public" output="false" returntype="string">
		<cfreturn this.restrictHierarchyLevelOnClassCode />
	</cffunction>

	<!--- Dev Note: GV; D9662  --->
	<!--- Set Margin_Display_LB --->
	<cffunction name="setMarginDisplayLB" access="public" output="false">
		<cfargument name="Margin_Display_LB" type="boolean" required="true" default="0" />
		<cfset this.Margin_Display_LB = arguments.Margin_Display_LB />
	</cffunction>

	<!--- Get Margin_Display_LB --->
	<cffunction name="getMarginDisplayLB" access="public" output="false" returntype="boolean">
		<cfreturn this.Margin_Display_LB />
	</cffunction>

	<!--- Set Margin_Display_CS --->
	<cffunction name="setMarginDisplayCS" access="public" output="false">
		<cfargument name="Margin_Display_CS" type="boolean" required="true" default="0" />
		<cfset this.Margin_Display_CS = arguments.Margin_Display_CS />
	</cffunction>

	<!--- Get Margin_Display_CS --->
	<cffunction name="getMarginDisplayCS" access="public" output="false" returntype="boolean">
		<cfreturn this.Margin_Display_CS />
	</cffunction>

	<!--- Set Margin_Display_EQ --->
	<cffunction name="setMarginDisplayEQ" access="public" output="false">
		<cfargument name="Margin_Display_EQ" type="boolean" required="true" default="0" />
		<cfset this.Margin_Display_EQ = arguments.Margin_Display_EQ />
	</cffunction>

	<!--- Get Margin_Display_LB --->
	<cffunction name="getMarginDisplayEQ" access="public" output="false" returntype="boolean">
		<cfreturn this.Margin_Display_EQ />
	</cffunction>

	<!--- Set Margin_Display_EQ --->
	<cffunction name="setMarginDisplayDefault" access="public" output="false">
		<cfargument name="Margin_Display_default" type="numeric" required="true" default="0" />
		<cfset this.Margin_Display_default = arguments.Margin_Display_default />
	</cffunction>

	<!--- Get Margin_Display_LB --->
	<cffunction name="getMarginDisplayDefault" access="public" output="false" returntype="numeric">
		<cfreturn this.Margin_Display_default />
	</cffunction>
	<!--- End Dev Note: GV; D9662  --->

	<!--- Dev Note: Milan; 9879  --->
	<!--- Set Password Requirements Status  --->
	<cffunction name="setPasswordRequirementsStatus" access="public" output="false">
		<cfargument name="PasswordRequirementsStatus" type="boolean" required="true" default="0" />
		<cfset this.PasswordRequirementsStatus = arguments.PasswordRequirementsStatus />
	</cffunction>

	<!--- Get Password Requirements Status  --->
	<cffunction name="getPasswordRequirementsStatus" access="public" output="false" returntype="boolean">
		<cfreturn this.PasswordRequirementsStatus />
	</cffunction>

	<!--- Change Password Screen Message setter --->
	<cffunction name="setChangePasswordScreenMsg" access="public" output="false">
		<cfargument name="changePasswordScreenMsg" type="string" required="true" default="1" />
		<cfset this.changePasswordScreenMsg = arguments.changePasswordScreenMsg />
	</cffunction>

	<!--- Change Password Screen Message getter --->
	<cffunction name="getChangePasswordScreenMsg" access="public" output="false">
		<cfreturn this.changePasswordScreenMsg />
	</cffunction>

	<!--- Set Login And Password Change Message --->
	<cffunction name="setLoginAndPasswordChangeMsg" access="public" output="false">
		<cfargument name="LoginAndPasswordChangeMsg" type="string" required="true" default="" />
		<cfset this.LoginAndPasswordChangeMsg = arguments.LoginAndPasswordChangeMsg />
	</cffunction>

	<!--- Get Password Requirements Message --->
	<cffunction name="getLoginAndPasswordChangeMsg" access="public" output="false" returntype="string">
		<cfreturn this.LoginAndPasswordChangeMsg />
	</cffunction>
	<!--- End Dev Note: Milan; 9879  --->

	<!---Dev Note: BJF 7963 & 10139 --->
	<!--- Use accrual log for trade checkbook  --->
	<cffunction name="setUse_AccrualLog_For_TC" access="public" output="false">
		<cfargument name="Use_AccrualLog_For_TC" type="boolean" required="true" default="0" />
		<cfset this.Use_AccrualLog_For_TC = arguments.Use_AccrualLog_For_TC />
	</cffunction>

	<!--- Get Use accrual log for trade checkbook --->
	<cffunction name="getUse_AccrualLog_For_TC" access="public" output="false" returntype="boolean">
		<cfreturn this.Use_AccrualLog_For_TC />
	</cffunction>

	<!--- Dev Note: Milan; 9956  --->
	<!--- Set Allow one component for pullbacks --->
	<cffunction name="setAllowOneComponentforPullbacks" access="public" output="false">
		<cfargument name="Allow_One_Component_for_Pullbacks" type="boolean" required="true" default="0" />
		<cfset this.Allow_One_Component_for_Pullbacks = arguments.Allow_One_Component_for_Pullbacks />
	</cffunction>

	<!--- Get Allow one component for pullbacks --->
	<cffunction name="getAllowOneComponentforPullbacks" access="public" output="false" returntype="boolean">
		<cfreturn this.Allow_One_Component_for_Pullbacks />
	</cffunction>
	<!--- End Dev Note: Milan; 9956  --->

	<!---Dev Note: DRK 10295 --->
	<cffunction name="setProgramSpecialRevisionFlag" access="public" output="false">
		<cfargument name="programSpecialRevisionFlag" type="boolean" required="true" default="" />
		<cfset this.programSpecialRevisionFlag = arguments.programSpecialRevisionFlag />
	</cffunction>

	<cffunction name="getProgramSpecialRevisionFlag" access="public" output="false" returntype="boolean">
		<cfreturn this.programSpecialRevisionFlag />
	</cffunction>

	<!---  Dev Note:  MarkS 10055 --->
	<cffunction name="setMultiDistributorBB" access="public" output="false">
		<cfargument name="MultiDistributorBB" type="boolean" required="true" default="0" />
		<cfset this.MultiDistributorBB = arguments.MultiDistributorBB />
	</cffunction>

	<cffunction name="getMultiDistributorBB" access="public" output="false" returntype="boolean">
		<cfreturn this.MultiDistributorBB/>
	</cffunction>

	<!--- BJF D10644 --->
	<cffunction name="setUse_Different_From_Address" access="public" output="false">
		<cfargument name="Use_Different_From_Address" type="boolean" required="true" default="0" />
		<cfset this.Use_Different_From_Address = arguments.Use_Different_From_Address />
	</cffunction>

	<cffunction name="getUse_Different_From_Address" access="public" output="false" returntype="boolean">
		<cfreturn this.Use_Different_From_Address/>
	</cffunction>

	<!--- BJF D10644 --->
	<cffunction name="setDifferent_From_Address" access="public" output="false">
		<cfargument name="Different_From_Address" type="string" required="true" default="0" />
		<cfset this.Different_From_Address = arguments.Different_From_Address />
	</cffunction>

	<cffunction name="getDifferent_From_Address" access="public" output="false" returntype="string">
		<cfreturn this.Different_From_Address/>
	</cffunction>

	<!---Dev Note: Kal 10343 --->
	<cffunction name="setGroupLevelBillback" access="public" output="false">
		<cfargument name="GroupLevelBillback" type="boolean" required="true" default="" />
		<cfset this.GroupLevelBillback = arguments.GroupLevelBillback />
	</cffunction>

	<cffunction name="getGroupLevelBillback" access="public" output="false" returntype="boolean">
		<cfreturn this.GroupLevelBillback />
	</cffunction>

	<!---Dev Note: Milan 10380 --->
	<cffunction name="setAllowUnKnownPayeeInBillback" access="public" output="false">
		<cfargument name="AllowUnKnownPayeeInBillback" type="boolean" required="true" default="" />
		<cfset this.Allow_UnKnown_Payee_In_Billback = arguments.AllowUnKnownPayeeInBillback />
	</cffunction>

	<cffunction name="getAllowUnKnownPayeeInBillback" access="public" output="false" returntype="boolean">
		<cfreturn this.Allow_UnKnown_Payee_In_Billback />
	</cffunction>

	<!---Dev Note: Milan 10433 --->
	<cffunction name="setHideInvalidComponentTypesInBillbacks" access="public" output="false">
		<cfargument name="HideInvalidComponentTypesInBillbacks" type="boolean" required="true" default="" />
		<cfset this.Hide_Invalid_Component_Types_In_Billbacks = arguments.HideInvalidComponentTypesInBillbacks />
	</cffunction>

	<cffunction name="getHideInvalidComponentTypesInBillbacks" access="public" output="false" returntype="boolean">
		<cfreturn this.Hide_Invalid_Component_Types_In_Billbacks />
	</cffunction>

	<!--- 10619 --->
	<cffunction name="setBillbackScorecardCache" access="public" output="false">
		<cfargument name="billbackScorecardCache" type="boolean" required="true" default="" />
		<cfset this.billbackScorecardCache = arguments.billbackScorecardCache />
	</cffunction>

	<cffunction name="getBillbackScorecardCache" access="public" output="false" returntype="boolean">
		<cfreturn this.billbackScorecardCache />
	</cffunction>

	<!--- 10548 --->
	<cffunction name="setProgramScorecardCache" access="public" output="false">
		<cfargument name="programScorecardCache" type="boolean" required="true" default="" />
		<cfset this.programScorecardCache = arguments.programScorecardCache />
	</cffunction>

	<cffunction name="getProgramScorecardCache" access="public" output="false" returntype="boolean">
		<cfreturn this.programScorecardCache />
	</cffunction>

	<!--- D17674 [begin] RBL 12/08/08 --->
	<cffunction name="setProjectScorecardCache" access="public" output="false">
		<cfargument name="projectScorecardCache" type="boolean" required="true" default="" />
		<cfset this.projectScorecardCache = arguments.projectScorecardCache />
	</cffunction>

	<cffunction name="getProjectScorecardCache" access="public" output="false" returntype="boolean">
		<cfreturn this.projectScorecardCache />
	</cffunction>
	<!--- D17674 [end] RBL 12/08/08 --->

	<!--- 10291 --->
	<cffunction name="setUse_Big_Billbacks" access="public" output="false">
		<cfargument name="Use_Big_Billbacks" type="boolean" required="true" default="" />
		<cfset this.Use_Big_Billbacks = arguments.Use_Big_Billbacks />
	</cffunction>

	<cffunction name="getUse_Big_Billbacks" access="public" output="false" returntype="boolean">
		<cfreturn this.Use_Big_Billbacks />
	</cffunction>

	<!--- Dev Note: Milan 10605 --->
	<cffunction name="setBillbackClosingMethod" access="public" output="false">
		<cfargument name="BillbackClosingMethod" type="boolean" required="true" default="" />
		<cfset this.Billback_Closing_Method = arguments.BillbackClosingMethod />
	</cffunction>

	<cffunction name="getBillbackClosingMethod" access="public" output="false" returntype="boolean">
		<cfreturn this.Billback_Closing_Method />
	</cffunction>

	<!--- Dev Note: BJF D10608 --->
	<cffunction name="setLost_Bids_Deviated" access="public" output="false">
		<cfargument name="Lost_Bids_Deviated" type="boolean" required="true" default="" />
		<cfset this.Lost_Bids_Deviated = arguments.Lost_Bids_Deviated />
	</cffunction>

	<cffunction name="getLost_Bids_Deviated" access="public" output="false" returntype="boolean">
		<cfreturn this.Lost_Bids_Deviated />
	</cffunction>

	<!--- Dev Note: CPM D10941 --->
	<cffunction name="setFreight_Calculator_On" access="public" output="false">
		<cfargument name="Freight_Calculator_On" type="boolean" required="true" default="0" />
		<cfset this.Freight_Calculator_On = arguments.Freight_Calculator_On />
	</cffunction>

	<cffunction name="getFreight_Calculator_On" access="public" output="false" returntype="boolean">
		<cfreturn this.Freight_Calculator_On />
	</cffunction>

	<!---   showfixedprice_additionalfields setter --->
	<cffunction name="setshowfixedpriceadditionalfields" access="public" output="false">
		<cfargument name="showfixedprice_additionalfields" type="boolean" required="true" default="" />
		<cfset this.showfixedprice_additionalfields = arguments.showfixedprice_additionalfields />
	</cffunction>

	<cffunction name="getshowfixedpriceadditionalfields" access="public" output="false" returntype="boolean">
		<cfreturn this.showfixedprice_additionalfields />
	</cffunction>

	<cffunction name="setshowrebateadditionalfields" access="public" output="false">
		<cfargument name="showrebate_additionalfields" type="boolean" required="true" default="" />
		<cfset this.showrebate_additionalfields = arguments.showrebate_additionalfields />
	</cffunction>

	<cffunction name="getshowrebateadditionalfields" access="public" output="false" returntype="boolean">
		<cfreturn this.showrebate_additionalfields />
	</cffunction>

	<!----- D10845 ----->
	<cffunction name="setLoginPageLogoPath" access="public" output="false">
		<cfargument name="loginPageLogoPath" type="string" required="true" />
		<cfset this.loginPageLogoPath = arguments.loginPageLogoPath />
	</cffunction>

	<cffunction name="getLoginPageLogoPath" access="public" output="false" returntype="string">
		<cfreturn this.loginPageLogoPath />
	</cffunction>

	<!---   showfixedprice_additionalfields setter --->
	<cffunction name="setappEZButtonOn" access="public" output="false">
		<cfargument name="app_EZButton_On" type="boolean" required="true" default="" />
		<cfset this.app_EZButton_On = arguments.app_EZButton_On />
	</cffunction>

	<cffunction name="getappEZButtonOn" access="public" output="false" returntype="boolean">
		<cfreturn this.app_EZButton_On />
	</cffunction>

	<!--- Dev Note: BDensmore 10788 --->
	<cffunction name="setOnePageClaimForm" access="public" output="false">
		<cfargument name="One_Page_Claim_form" type="boolean" required="true" />
		<cfset this.One_Page_Claim_form = arguments.One_Page_Claim_form />
	</cffunction>

	<cffunction name="getOnePageClaimForm" access="public" output="false" returntype="boolean">
		<cfreturn this.One_Page_Claim_form />
	</cffunction>

	<cffunction name="setSuppressGroupsZeroItems" access="public" output="false">
		<cfargument name="suppressGroupsZeroItems" type="string" required="true" />
		<cfset this.suppressGroupsZeroItems = arguments.suppressGroupsZeroItems />
	</cffunction>

	<cffunction name="getSuppressGroupsZeroItems" access="public" output="false" returntype="string">
		<cfreturn this.suppressGroupsZeroItems />
	</cffunction>

	<cffunction name="setSuppressBusinessConsiderations" access="public" output="false">
		<cfargument name="suppressBusinessConsiderations" type="string" required="true" />
		<cfset this.suppressBusinessConsiderations = arguments.suppressBusinessConsiderations />
	</cffunction>

	<cffunction name="getSuppressBusinessConsiderations" access="public" output="false" returntype="string">
		<cfreturn this.suppressBusinessConsiderations />
	</cffunction>

	<!--- Dev Note: CPM 11135 - Add To do on Doc Attach --->
	<cffunction name="setAddTodoOnDocAttach" access="public" output="false">
		<cfargument name="AddTodoOnDocAttach" type="numeric" required="Yes">
		<cfset this.AddTodoOnDocAttach = arguments.AddTodoOnDocAttach />
	</cffunction>

	<cffunction name="getAddTodoOnDocAttach" access="public" output="false" return="boolean">
		<cfreturn this.AddTodoOnDocAttach />
	</cffunction>

	<!--- Dev Note: CPM 11135 - Add To do on Doc Attach --->
	<cffunction name="setIncludeUsersEmailAuto" access="public" output="false">
		<cfargument name="IncludeUsersEmailAuto" type="numeric" required="Yes">
		<cfset this.IncludeUsersEmailAuto = arguments.IncludeUsersEmailAuto />
	</cffunction>

	<cffunction name="getIncludeUsersEmailAuto" access="public" output="false" return="boolean">
		<cfreturn this.IncludeUsersEmailAuto />
	</cffunction>

	<cffunction name="setProgramApprovalForInactiveOperators" access="public" output="false">
		<cfargument name="programApprovalForInactiveOperators" type="numeric" required="Yes">
		<cfset this.programApprovalForInactiveOperators = arguments.programApprovalForInactiveOperators />
	</cffunction>

	<cffunction name="getProgramApprovalForInactiveOperators" access="public" output="false" return="boolean">
		<cfreturn this.programApprovalForInactiveOperators />
	</cffunction>

	<!---  Dev Note:  MarkS 11287 --->
	<cffunction name="setDisableAutoLogin" access="public" output="false">
		<cfargument name="DisableAutoLogin" type="numeric" required="Yes">
		<cfset this.DisableAutoLogin = arguments.DisableAutoLogin />
	</cffunction>

	<cffunction name="getDisableAutoLogin" access="public" output="false" return="boolean">
		<cfreturn this.DisableAutoLogin />
	</cffunction>

	<!---  Dev Note:  MarkS 10729 --->
	<cffunction name="setDataIntViewer" access="public" output="false">
		<cfargument name="DataIntViewer" type="numeric" required="Yes">
		<cfset this.DataIntViewer = arguments.DataIntViewer />
	</cffunction>

	<cffunction name="getDataIntViewer" access="public" output="false" return="boolean">
		<cfreturn this.DataIntViewer />
	</cffunction>

	<!--- Dev Note: BSD D11414 --->
	<cffunction name="setLumpSumComponentInProgram" access="public" output="false">
		<cfargument name="LumpSumComponentInProgram" type="numeric" required="Yes">
		<cfset this.LumpSumComponentInProgram = arguments.LumpSumComponentInProgram />
	</cffunction>

	<cffunction name="getLumpSumComponentInProgram" access="public" output="false" return="boolean">
		<cfreturn this.LumpSumComponentInProgram />
	</cffunction>

	<cffunction name="setReleaseSettlement" access="public" output="false">
		<cfargument name="ReleaseSettlement" required="Yes" type="numeric">
		<cfset this.ReleaseSettlement = arguments.ReleaseSettlement />
	</cffunction>

	<cffunction name="getReleaseSettlement" access="public" output="false" returntype="numeric">
		<cfreturn this.ReleaseSettlement />
	</cffunction>

	<!--- Dev Note: CPM D11286 --->
	<cffunction name="setSend_Release_Settlement_Emailaddress" access="public" output="false">
		<cfargument name="Send_Release_Settlement_Emailaddress" required="Yes" type="string">
		<cfset this.Send_Release_Settlement_Emailaddress = arguments.Send_Release_Settlement_Emailaddress />
	</cffunction>

	<cffunction name="getSend_Release_Settlement_Emailaddress" access="public" output="false" returntype="string">
		<cfreturn this.Send_Release_Settlement_Emailaddress />
	</cffunction>

	<!--- Dev Note: BJF D11527 --->
	<cffunction name="setAllow_Percent_Operator_Programs" access="public" output="false">
		<cfargument name="Allow_Percent_Operator_Programs" type="numeric" required="Yes">
		<cfset this.Allow_Percent_Operator_Programs = arguments.Allow_Percent_Operator_Programs />
	</cffunction>

	<cffunction name="getAllow_Percent_Operator_Programs" access="public" output="false" return="boolean">
		<cfreturn this.Allow_Percent_Operator_Programs />
	</cffunction>

	<!--- Dev Note: BSD; 11439 --->
	<cffunction name="setMarginColHeader1" access="public" output="false">
		<cfargument name="marginColHeader1" type="string" required="Yes">
		<cfset this.MarginColHeader1 = arguments.MarginColHeader1 />
	</cffunction>

	<cffunction name="getMarginColHeader1" access="public" output="false" return="string">
		<cfreturn this.MarginColHeader1 />
	</cffunction>

	<cffunction name="setMarginColHeader2" access="public" output="false">
		<cfargument name="marginColHeader2" type="string" required="Yes">
		<cfset this.MarginColHeader2 = arguments.MarginColHeader2 />
	</cffunction>

	<cffunction name="getMarginColHeader2" access="public" output="false" return="string">
		<cfreturn this.MarginColHeader2 />
	</cffunction>

	<cffunction name="setMarginColHeader3" access="public" output="false">
		<cfargument name="marginColHeader3" type="string" required="Yes">
		<cfset this.MarginColHeader3 = arguments.MarginColHeader3 />
	</cffunction>

	<cffunction name="getMarginColHeader3" access="public" output="false" return="string">
		<cfreturn this.MarginColHeader3 />
	</cffunction>

	<cffunction name="setMarginColHeader4" access="public" output="false">
		<cfargument name="marginColHeader4" type="string" required="Yes">
		<cfset this.MarginColHeader4 = arguments.MarginColHeader4 />
	</cffunction>

	<cffunction name="getMarginColHeader4" access="public" output="false" return="string">
		<cfreturn this.MarginColHeader4 />
	</cffunction>

	<cffunction name="setMarginColHeader5" access="public" output="false">
		<cfargument name="marginColHeader5" type="string" required="Yes">
		<cfset this.MarginColHeader5 = arguments.MarginColHeader5 />
	</cffunction>

	<cffunction name="getMarginColHeader5" access="public" output="false" return="string">
		<cfreturn this.MarginColHeader5 />
	</cffunction>

	<cffunction name="setMarginColHeader6" access="public" output="false">
		<cfargument name="marginColHeader6" type="string" required="Yes">
		<cfset this.MarginColHeader6 = arguments.MarginColHeader6 />
	</cffunction>

	<cffunction name="getMarginColHeader6" access="public" output="false" return="string">
		<cfreturn this.MarginColHeader6 />
	</cffunction>

	<cffunction name="setMarginColHeader7" access="public" output="false">
		<cfargument name="marginColHeader7" type="string" required="Yes">
		<cfset this.MarginColHeader7 = arguments.MarginColHeader7 />
	</cffunction>

	<cffunction name="getMarginColHeader7" access="public" output="false" return="string">
		<cfreturn this.MarginColHeader7 />
	</cffunction>

	<cffunction name="setMarginColHeader8" access="public" output="false">
		<cfargument name="marginColHeader8" type="string" required="Yes">
		<cfset this.MarginColHeader8 = arguments.MarginColHeader8 />
	</cffunction>

	<cffunction name="getMarginColHeader8" access="public" output="false" return="string">
		<cfreturn this.MarginColHeader8 />
	</cffunction>

	<cffunction name="setMarginColHeader9" access="public" output="false">
		<cfargument name="marginColHeader9" type="string" required="Yes">
		<cfset this.MarginColHeader9 = arguments.MarginColHeader9 />
	</cffunction>

	<cffunction name="getMarginColHeader9" access="public" output="false" return="string">
		<cfreturn this.MarginColHeader9 />
	</cffunction>

	<cffunction name="setMarginColHeader10" access="public" output="false">
		<cfargument name="marginColHeader10" type="string" required="Yes">
		<cfset this.MarginColHeader10 = arguments.MarginColHeader10 />
	</cffunction>

	<cffunction name="getMarginColHeader10" access="public" output="false" return="string">
		<cfreturn this.MarginColHeader10 />
	</cffunction>

	<cffunction name="setMarginColHeader11" access="public" output="false">
		<cfargument name="marginColHeader11" type="string" required="Yes">
		<cfset this.MarginColHeader11 = arguments.MarginColHeader11 />
	</cffunction>

	<cffunction name="getMarginColHeader11" access="public" output="false" return="string">
		<cfreturn this.MarginColHeader11 />
	</cffunction>

	<cffunction name="setMarginColHeader12" access="public" output="false">
		<cfargument name="marginColHeader12" type="string" required="Yes">
		<cfset this.MarginColHeader12 = arguments.MarginColHeader12 />
	</cffunction>

	<cffunction name="getMarginColHeader12" access="public" output="false" return="string">
		<cfreturn this.MarginColHeader12 />
	</cffunction>

	<cffunction name="setMarginColHeader13" access="public" output="false">
		<cfargument name="marginColHeader13" type="string" required="Yes">
		<cfset this.MarginColHeader13 = arguments.MarginColHeader13 />
	</cffunction>

	<cffunction name="getMarginColHeader13" access="public" output="false" return="string">
		<cfreturn this.MarginColHeader13 />
	</cffunction>

	<cffunction name="setMarginColHeader14" access="public" output="false">
		<cfargument name="marginColHeader14" type="string" required="Yes">
		<cfset this.MarginColHeader14 = arguments.MarginColHeader14 />
	</cffunction>

	<cffunction name="getMarginColHeader14" access="public" output="false" return="string">
		<cfreturn this.MarginColHeader14 />
	</cffunction>

	<!--- 16314 [begin] --->
	<cffunction name="setMarginColHeader15" access="public" output="false">
		<cfargument name="marginColHeader15" type="string" required="Yes">
		<cfset this.MarginColHeader15 = arguments.MarginColHeader15 />
	</cffunction>

	<cffunction name="getMarginColHeader15" access="public" output="false" return="string">
		<cfreturn this.MarginColHeader15 />
	</cffunction>
	<!--- 16314 [end] --->

	<!--- Getter: MarginColHeader16 --->
	<cffunction name="getMarginColHeader16" returntype="string" access="public" output="false">
		<cfreturn this.MarginColHeader16 />
	</cffunction>

	<!--- Setter: MarginColHeader16 --->
	<cffunction name="setMarginColHeader16" access="public" output="false" >
		<cfargument  name="MarginColHeader16" required="true" type="string" />
		<cfset this.MarginColHeader16 = MarginColHeader16 />
	</cffunction>

	<!--- Getter: MarginColHeader17 --->
	<cffunction name="getMarginColHeader17" returntype="string" access="public" output="false">
		<cfreturn this.MarginColHeader17 />
	</cffunction>

	<!--- Setter: MarginColHeader17 --->
	<cffunction name="setMarginColHeader17" access="public" output="false" >
		<cfargument  name="MarginColHeader17" required="true" type="string" />
		<cfset this.MarginColHeader17 = MarginColHeader17 />
	</cffunction>

	<cffunction name="getMarginColHeader18" returntype="string" access="public" output="false">
		<cfreturn this.MarginColHeader18 />
	</cffunction>

	<cffunction name="setMarginColHeader18" access="public" output="false" >
		<cfargument  name="MarginColHeader18" required="true" type="string" />
		<cfset this.MarginColHeader18 = MarginColHeader18 />
	</cffunction>

	<cffunction name="getMarginColHeader19" returntype="string" access="public" output="false">
		<cfreturn this.MarginColHeader19 />
	</cffunction>

	<!--- Setter: MarginColHeader17 --->
	<cffunction name="setMarginColHeader19" access="public" output="false" >
		<cfargument  name="MarginColHeader19" required="true" type="string" />
		<cfset this.MarginColHeader19 = MarginColHeader19 />
	</cffunction>

	<cffunction name="getMarginColHeader20" returntype="string" access="public" output="false">
		<cfreturn this.MarginColHeader20 />
	</cffunction>

	<cffunction name="setMarginColHeader20" access="public" output="false" >
		<cfargument  name="MarginColHeader20" required="true" type="string" />
		<cfset this.MarginColHeader20 = MarginColHeader20 />
	</cffunction>

	<cffunction name="getMarginColHeader21" returntype="string" access="public" output="false">
		<cfreturn this.MarginColHeader21 />
	</cffunction>

	<cffunction name="setMarginColHeader21" access="public" output="false" >
		<cfargument  name="MarginColHeader21" required="true" type="string" />
		<cfset this.MarginColHeader21 = MarginColHeader21 />
	</cffunction>

	<cffunction name="getMarginColHeader22" returntype="string" access="public" output="false">
		<cfreturn this.marginColHeader22 />
	</cffunction>

	<cffunction name="setMarginColHeader22" access="public" output="false" >
		<cfargument  name="marginColHeader22" required="true" type="string" />
		<cfset this.marginColHeader22 = arguments.marginColHeader22 />
	</cffunction>

	<cffunction name="getMarginColHeader23" returntype="string" access="public" output="false">
		<cfreturn this.marginColHeader23 />
	</cffunction>

	<cffunction name="setMarginColHeader23" access="public" output="false" >
		<cfargument  name="marginColHeader23" required="true" type="string" />
		<cfset this.marginColHeader23 = arguments.marginColHeader23 />
	</cffunction>

    <!---65744 - CC - Move LaborOH cost to a different product cost field START--->
    <cffunction name="getMarginColHeader24" returntype="string" access="public" output="false">
		<cfreturn this.marginColHeader24 />
	</cffunction>

	<cffunction name="setMarginColHeader24" access="public" output="false" >
		<cfargument  name="marginColHeader24" required="true" type="string" />
		<cfset this.marginColHeader24 = arguments.marginColHeader24 />
	</cffunction>

    <cffunction name="getMarginColHeader25" returntype="string" access="public" output="false">
		<cfreturn this.marginColHeader25 />
	</cffunction>

	<cffunction name="setMarginColHeader25" access="public" output="false" >
		<cfargument  name="marginColHeader25" required="true" type="string" />
		<cfset this.marginColHeader25 = arguments.marginColHeader25 />
	</cffunction>
    <!---65744 - CC - Move LaborOH cost to a different product cost field END --->
<!---76537 :: Margin analysis to various targets START--->
   <cffunction name="getMarginColHeader26" returntype="string" access="public" output="false">
		<cfreturn this.marginColHeader26 />
	</cffunction>

	<cffunction name="setMarginColHeader26" access="public" output="false" >
		<cfargument  name="marginColHeader26" required="true" type="string" />
		<cfset this.marginColHeader26 = arguments.marginColHeader26 />
	</cffunction>
<!---76537 :: Margin analysis to various targets END--->
	<cffunction name="setMarginCostColHeader1" access="public" output="false">
		<cfargument name="marginCostColHeader1" type="string" required="Yes">
		<cfset this.marginCostColHeader1 = arguments.marginCostColHeader1 />
	</cffunction>

	<cffunction name="getMarginCostColHeader1" access="public" output="false" return="string">
		<cfreturn this.marginCostColHeader1 />
	</cffunction>

	<cffunction name="setMarginCostColHeader2" access="public" output="false">
		<cfargument name="marginCostColHeader2" type="string" required="Yes">
		<cfset this.marginCostColHeader2 = arguments.marginCostColHeader2 />
	</cffunction>

	<cffunction name="getMarginCostColHeader2" access="public" output="false" return="string">
		<cfreturn this.marginCostColHeader2 />
	</cffunction>

	<cffunction name="setMarginCostColHeader3" access="public" output="false">
		<cfargument name="marginCostColHeader3" type="string" required="Yes">
		<cfset this.marginCostColHeader3 = arguments.marginCostColHeader3 />
	</cffunction>

	<cffunction name="getMarginCostColHeader3" access="public" output="false" return="string">
		<cfreturn this.marginCostColHeader3 />
	</cffunction>

	<cffunction name="setMarginCostColHeader4" access="public" output="false">
		<cfargument name="marginCostColHeader4" type="string" required="Yes">
		<cfset this.marginCostColHeader4 = arguments.marginCostColHeader4 />
	</cffunction>

	<cffunction name="getMarginCostColHeader4" access="public" output="false" return="string">
		<cfreturn this.marginCostColHeader4 />
	</cffunction>

	<cffunction name="setMarginCostColHeader5" access="public" output="false">
		<cfargument name="marginCostColHeader5" type="string" required="Yes">
		<cfset this.marginCostColHeader5 = arguments.marginCostColHeader5 />
	</cffunction>

	<!---  Dev Note:  MarkS 11287 --->
	<cffunction name="setBBDeviationUseMaxPrice" access="public" output="false">
		<cfargument name="BBDeviationUseMaxPrice" type="numeric" required="Yes">
		<cfset this.BBDeviationUseMaxPrice = arguments.BBDeviationUseMaxPrice />
	</cffunction>

	<cffunction name="getBBDeviationUseMaxPrice" access="public" output="false" return="numeric">
		<cfreturn this.BBDeviationUseMaxPrice />
	</cffunction>

	<cffunction name="getMarginCostColHeader5" access="public" output="false" return="string">
		<cfreturn this.marginCostColHeader5 />
	</cffunction>

	<!--- Dev Note: KAL D11049  --->
	<cffunction name="setBillbackModifyAgree" access="public" output="false">
		<cfargument name="BillbackModifyAgree" type="numeric" required="Yes">
		<cfset this.BillbackModifyAgree = arguments.BillbackModifyAgree/>
	</cffunction>

	<cffunction name="getBillbackModifyAgree" access="public" output="false" return="boolean">
		<cfreturn this.BillbackModifyAgree />
	</cffunction>

	<cffunction name="setOnlyAccrualTPAPullbacks" access="public" output="false">
		<cfargument name="OnlyAccrualTPA_Pullbacks" type="string" required="Yes">
		<cfset this.OnlyAccrualTPA_Pullbacks = arguments.OnlyAccrualTPA_Pullbacks/>
	</cffunction>

	<cffunction name="getOnlyAccrualTPAPullbacks" access="public" output="false" return="string">
		<cfreturn this.OnlyAccrualTPA_Pullbacks />
	</cffunction>

	<!----- UOMEAAvailable ----->
	<cffunction name="setUOMEAAvailable" access="public" output="false">
		<cfargument name="UOMEAAvailable" type="boolean" required="Yes">
		<cfset this.UOMEAAvailable = arguments.UOMEAAvailable/>
	</cffunction>

	<cffunction name="getUOMEAAvailable" access="public" output="false" return="boolean">
		<cfreturn this.UOMEAAvailable />
	</cffunction>

	<!----- Position_Tree_Display_Distributor ----->
	<cffunction name="setPosition_Tree_Display_Distributor" access="public" output="false">
		<cfargument name="Position_Tree_Display_Distributor" type="boolean" required="Yes">
		<cfset this.Position_Tree_Display_Distributor = arguments.Position_Tree_Display_Distributor/>
	</cffunction>

	<cffunction name="getPosition_Tree_Display_Distributor" access="public" output="false" return="boolean">
		<cfreturn this.Position_Tree_Display_Distributor />
	</cffunction>

	<!----- BB_UPLOAD_UPDATED -----> <!--- removed with label 19746--->
	<cffunction name="setBB_UPLOAD_UPDATED" access="public" output="false">
		<cfargument name="BB_UPLOAD_UPDATED" type="boolean" required="Yes">
		<cfset this.BB_UPLOAD_UPDATED = arguments.BB_UPLOAD_UPDATED/>
	</cffunction>

	<cffunction name="getBB_UPLOAD_UPDATED" access="public" output="false" return="boolean">
		<cfreturn this.BB_UPLOAD_UPDATED />
	</cffunction>

	<!----- OperatorTPAInDistributorPrograms ----->
	<cffunction name="setOperatorTPAInDistributorPrograms" access="public" output="false">
		<cfargument name="OperatorTPAInDistributorPrograms" type="boolean" required="Yes">
		<cfset this.OperatorTPAInDistributorPrograms = arguments.OperatorTPAInDistributorPrograms/>
	</cffunction>

	<cffunction name="getOperatorTPAInDistributorPrograms" access="public" output="false" return="boolean">
		<cfreturn this.OperatorTPAInDistributorPrograms />
	</cffunction>

	<!--- Dev Note: BSD D11643 Turn Split Billbacks on or off --->
	<cffunction name="setSplitBillbacks" access="public" output="false">
		<cfargument name="SplitBillbacks" type="string" required="Yes">
		<cfset this.SplitBillbacks = arguments.SplitBillbacks/>
	</cffunction>

	<cffunction name="getSplitBillbacks" access="public" output="false" return="string">
		<cfreturn this.SplitBillbacks />
	</cffunction>

	<!----- BB Auto Report D11427 Auto Billabcks via Report Admin screen functionality----->
	<cffunction name="setBBAutoReport" access="public" output="false">
		<cfargument name="BB_Auto_report" type="boolean" required="Yes">
		<cfset this.BB_Auto_report = arguments.BB_Auto_report/>
	</cffunction>

	<cffunction name="getBBAutoReport" access="public" output="false" return="boolean">
		<cfreturn this.BB_Auto_report />
	</cffunction>

	<!----- BB Auto Report D18880 MWS: Auto Pay Looks in the Invoice table for buying_Group_id to figure out Group Membership----->
	<cffunction name="setBBAutoPayCustomerGroupInInvoice" access="public" output="false">
		<cfargument name="BB_Auto_Pay_Customer_Group_In_Invoice" type="boolean" required="Yes">
		<cfset this.BB_Auto_Pay_Customer_Group_In_Invoice = arguments.BB_Auto_Pay_Customer_Group_In_Invoice/>
	</cffunction>

	<cffunction name="getBBAutoPayCustomerGroupInInvoice" access="public" output="false" return="boolean">
		<cfreturn this.BB_Auto_Pay_Customer_Group_In_Invoice />
	</cffunction>

	<!----- BB Auto Report D18879  MWS: In auto pay program components, disable "Pay Each" option.  Necessary for clients with not Distributor/vendor relation----->
	<cffunction name="setBBAutoPayDisablePayEach" access="public" output="false">
		<cfargument name="BB_Auto_Pay_Disable_Pay_Each" type="boolean" required="Yes">
		<cfset this.BB_Auto_Pay_Disable_Pay_Each = arguments.BB_Auto_Pay_Disable_Pay_Each/>
	</cffunction>

	<cffunction name="getBBAutoPayDisablePayEach" access="public" output="false" return="boolean">
		<cfreturn this.BB_Auto_Pay_Disable_Pay_Each />
	</cffunction>

	<cffunction name="setBBAutoPaylumpSum" access="public" output="false">
		<cfargument name="BB_Auto_Pay_Lump_Sum" type="boolean" required="Yes">
		<cfset this.BB_Auto_Pay_Lump_Sum = arguments.BB_Auto_Pay_Lump_Sum/>
	</cffunction>

	<cffunction name="getBBAutoPaylumpSum" access="public" output="false" return="boolean">
		<cfreturn this.BB_Auto_Pay_Lump_Sum />
	</cffunction>

	<!----- BB Auto Report D19057  MWS: Allow Auto Pay to apply Adjustments Greater than the paid amount of the BB (creating a Negative BB)----->
	<cffunction name="setBBAutoPayAllowNegativePaidAmount" access="public" output="false">
		<cfargument name="BB_Auto_Pay_Allow_Negative_Paid_Amount" type="boolean" required="Yes">
		<cfset this.BB_Auto_Pay_Allow_Negative_Paid_Amount = arguments.BB_Auto_Pay_Allow_Negative_Paid_Amount/>
	</cffunction>

	<cffunction name="getBBAutoPayAllowNegativePaidAmount" access="public" output="false" return="boolean">
		<cfreturn this.BB_Auto_Pay_Allow_Negative_Paid_Amount />
	</cffunction>

	<!----- BB Auto Report 42982  Deepa: Allow manual auto pay even when full auto pay is ON ----->
	<cffunction name="setBBAutoReportAllowManual" access="public" output="false">
		<cfargument name="BB_Auto_Report_Allow_Manual" type="boolean" required="Yes">
		<cfset this.BBAutoReportAllowManual = arguments.BB_Auto_Report_Allow_Manual />
	</cffunction>

	<cffunction name="getBBAutoReportAllowManual" access="public" output="false" return="boolean">
		<cfreturn this.BBAutoReportAllowManual />
	</cffunction>

	<!----- BB Auto Report 42982  Deepa: Allow reverse inside auto pay ----->
	<cffunction name="setBBAutoReportAllowReverse" access="public" output="false">
		<cfargument name="BB_Auto_Report_Allow_Reverse" type="boolean" required="Yes">
		<cfset this.BBAutoReportAllowReverse = arguments.BB_Auto_Report_Allow_Reverse />
	</cffunction>

	<cffunction name="getBBAutoReportAllowReverse" access="public" output="false" return="boolean">
		<cfreturn this.BBAutoReportAllowReverse />
	</cffunction>

	<!----- 48168 Question on autopay calculation ----->
	<cffunction name="setPgmMarginRebateUseAutoPayPrice" access="public" output="false">
		<cfargument name="Pgm_Margin_Rebate_Use_Auto_Pay_Price" type="boolean" required="Yes">
		<cfset this.PgmMarginRebateUseAutoPayPrice = arguments.Pgm_Margin_Rebate_Use_Auto_Pay_Price />
	</cffunction>

	<cffunction name="getPgmMarginRebateUseAutoPayPrice" access="public" output="false" return="boolean">
		<cfreturn this.PgmMarginRebateUseAutoPayPrice />
	</cffunction>

	<cffunction name="setBBAutoReportisManuallyConfigured" access="public" output="false">
		<cfargument name="BBAutoReportisManuallyConfigured" type="boolean" required="Yes">
		<cfset this.BBAutoReportisManuallyConfigured = arguments.BBAutoReportisManuallyConfigured/>
	</cffunction>

	<cffunction name="getBBAutoReportisManuallyConfigured" access="public" output="false" return="boolean">
		<cfreturn this.BBAutoReportisManuallyConfigured />
	</cffunction>

	<!--- Dev Note: Milan D11495 Lamb Export - Sales Agreement Application --->
	<cffunction name="setShowExportPrograms" access="public" output="false">
		<cfargument name="ShowExportPrograms" type="string" required="Yes">
		<cfset this.ShowExportPrograms = arguments.ShowExportPrograms/>
	</cffunction>

	<cffunction name="getShowExportPrograms" access="public" output="false" return="string">
		<cfreturn this.ShowExportPrograms />
	</cffunction>

	<!--- Interface_BuyingGroup_As_Group_To_Client --->
	<cffunction name="setInterface_BuyingGroup_As_Group_To_Client" access="public" output="false">
		<cfargument name="Interface_BuyingGroup_As_Group_To_Client" type="string" required="Yes">
		<cfset this.Interface_BuyingGroup_As_Group_To_Client = arguments.Interface_BuyingGroup_As_Group_To_Client/>
	</cffunction>

	<cffunction name="getInterface_BuyingGroup_As_Group_To_Client" access="public" output="false" return="string">
		<cfreturn this.Interface_BuyingGroup_As_Group_To_Client />
	</cffunction>

	<!---  Dev Note:  MarkS 12498 --->
	<cffunction name="setBBExpectedRateGTClaimRate" access="public" output="false">
		<cfargument name="BB_Expected_Rate_GT_Claim_Rate" type="boolean" required="Yes">
		<cfset this.BB_Expected_Rate_GT_Claim_Rate = arguments.BB_Expected_Rate_GT_Claim_Rate/>
	</cffunction>

	<cffunction name="getBBExpectedRateGTClaimRate" access="public" output="false" return="boolean">
		<cfreturn this.BB_Expected_Rate_GT_Claim_Rate />
	</cffunction>

	<!---  Dev Note:  MarkS 12575 --->
	<cffunction name="setBBAutoReportStartDate" access="public" output="false">
		<cfargument name="BB_Auto_Report_Start_Date" type="date" required="Yes">
		<cfset this.BB_Auto_Report_Start_Date = arguments.BB_Auto_Report_Start_Date/>
	</cffunction>

	<cffunction name="getBBAutoReportStartDate" access="public" output="false" returntype="date">
		<cfreturn this.BB_Auto_Report_Start_Date />
	</cffunction>

	<!--- budgetsFunctionalityOn --->
	<cffunction name="setBudgetsFunctionalityOn" access="public" output="false">
		<cfargument name="budgetsFunctionalityOn" type="numeric" required="Yes">
		<cfset this.budgetsFunctionalityOn = arguments.budgetsFunctionalityOn/>
	</cffunction>

	<cffunction name="getBudgetsFunctionalityOn" access="public" output="false" return="numeric">
		<cfreturn this.budgetsFunctionalityOn />
	</cffunction>

	<!--- BudgetSelectionRequired --->
	<cffunction name="setBudgetSelectionRequired" access="public" output="false">
		<cfargument name="budgetSelectionRequired" type="numeric" required="Yes">
		<cfset this.budgetSelectionRequired = arguments.budgetSelectionRequired />
	</cffunction>

	<cffunction name="getBudgetSelectionRequired" access="public" output="false" return="numeric">
		<cfreturn this.budgetSelectionRequired />
	</cffunction>

	<!--- BudgetSingleLevelForFixed --->
	<cffunction name="setBudgetSingleLevelForFixed" access="public" output="false">
		<cfargument name="budgetSingleLevelForFixed" type="numeric" required="Yes">
		<cfset this.budgetSingleLevelForFixed = arguments.budgetSingleLevelForFixed />
	</cffunction>

	<cffunction name="getBudgetSingleLevelForFixed" access="public" output="false" return="numeric">
		<cfreturn this.budgetSingleLevelForFixed />
	</cffunction>

	<!--- BJF 11212 Distributor_Product_Integrity_On --->
	<cffunction name="setDistributor_Product_Integrity_On" access="public" output="false">
		<cfargument name="Distributor_Product_Integrity_On" type="numeric" required="Yes">
		<cfset this.Distributor_Product_Integrity_On = arguments.Distributor_Product_Integrity_On/>
	</cffunction>

	<cffunction name="getDistributor_Product_Integrity_On" access="public" output="false" return="numeric">
		<cfreturn this.Distributor_Product_Integrity_On />
	</cffunction>

	<!--- budgetsProgramApproveEmailAddress --->
	<cffunction name="setBudgetsProgramApproveEmailAddress" access="public" output="false">
		<cfargument name="budgetsProgramApproveEmailAddress" type="string" required="Yes">
		<cfset this.budgetsProgramApproveEmailAddress = arguments.budgetsProgramApproveEmailAddress/>
	</cffunction>

	<cffunction name="getBudgetsProgramApproveEmailAddress" access="public" output="false" return="string">
		<cfreturn this.budgetsProgramApproveEmailAddress />
	</cffunction>

	<!--- budgetsBillbackApproveEmailAddress --->
	<cffunction name="setBudgetsBillbackApproveEmailAddress" access="public" output="false">
		<cfargument name="budgetsBillbackApproveEmailAddress" type="string" required="Yes">
		<cfset this.budgetsBillbackApproveEmailAddress = arguments.budgetsBillbackApproveEmailAddress/>
	</cffunction>

	<cffunction name="getBudgetsBillbackApproveEmailAddress" access="public" output="false" return="string">
		<cfreturn this.budgetsBillbackApproveEmailAddress />
	</cffunction>

	<!--- D12937: Hide Claim Adj --->
	<cffunction name="setShowClaimAdjustment" access="public" output="false">
		<cfargument name="showClaimAdjustment" type="numeric" required="Yes">
		<cfset this.showClaimAdjustment = arguments.showClaimAdjustment/>
	</cffunction>

	<cffunction name="getShowClaimAdjustment" access="public" output="false" return="numeric">
		<cfreturn this.showClaimAdjustment />
	</cffunction>

	<!--- 13016: Item Margin Target OR Gross Margin For Price List --->
	<cffunction name="setItemMarginTargetORGrossMarginForPriceList" access="public" output="false">
		<cfargument name="ItemMarginTarget_OR_GrossMargin_For_PriceList" type="numeric" required="Yes">
		<cfset this.ItemMarginTarget_OR_GrossMargin_For_PriceList = arguments.ItemMarginTarget_OR_GrossMargin_For_PriceList/>
	</cffunction>

	<cffunction name="getItemMarginTargetORGrossMarginForPriceList" access="public" output="false" return="numeric">
		<cfreturn this.ItemMarginTarget_OR_GrossMargin_For_PriceList />
	</cffunction>

	<!--- 13395: Show Fixed/Freight 5.0 only--->
	<cffunction name="setShow_Fixed_Freight" access="public" output="false">
		<cfargument name="Show_Fixed_Freight" type="numeric" required="Yes">
		<cfset this.Show_Fixed_Freight = arguments.Show_Fixed_Freight/>
	</cffunction>

	<cffunction name="getShow_Fixed_Freight" access="public" output="false" return="numeric">
		<cfreturn this.Show_Fixed_Freight />
	</cffunction>

	<!--- 13397 5.0 only--->
	<cffunction name="setShow_Component_Accrual" access="public" output="false">
		<cfargument name="Show_Component_Accrual" type="numeric" required="Yes">
		<cfset this.Show_Component_Accrual = arguments.Show_Component_Accrual/>
	</cffunction>

	<cffunction name="getShow_Component_Accrual" access="public" output="false" return="numeric">
		<cfreturn this.Show_Component_Accrual />
	</cffunction>

	<cffunction name="setShow_Component_Floor_Pricing" access="public" output="false">
		<cfargument name="Show_Component_Floor_Pricing" type="numeric" required="Yes">
		<cfset this.Show_Component_Floor_Pricing = arguments.Show_Component_Floor_Pricing/>
	</cffunction>

	<cffunction name="getShow_Component_Floor_Pricing" access="public" output="false" return="numeric">
		<cfreturn this.Show_Component_Floor_Pricing />
	</cffunction>

	<!--- 13428 5.0 only --->
	<cffunction name="setGL_Account_On" access="public" output="false">
		<cfargument name="GL_Account_On" type="numeric" required="Yes">
		<cfset this.GL_Account_On = arguments.GL_Account_On/>
	</cffunction>

	<cffunction name="getGL_Account_On" access="public" output="false" return="numeric">
		<cfreturn this.GL_Account_On />
	</cffunction>

	<cffunction name="setGL_Account_Required_for_Comp" access="public" output="false">
		<cfargument name="GL_Account_Required_for_Comp" type="numeric" required="Yes">
		<cfset this.GL_Account_Required_for_Comp = arguments.GL_Account_Required_for_Comp/>
	</cffunction>

	<cffunction name="getGL_Account_Required_for_Comp" access="public" output="false" return="numeric">
		<cfreturn this.GL_Account_Required_for_Comp />
	</cffunction>

	<cffunction name="setExact_List_Matching_On" access="public" output="false">
		<cfargument name="Exact_List_Matching_On" type="numeric" required="Yes">
		<cfset this.Exact_List_Matching_On = arguments.Exact_List_Matching_On/>
	</cffunction>

	<cffunction name="getExact_List_Matching_On" access="public" output="false" return="numeric">
		<cfreturn this.Exact_List_Matching_On />
	</cffunction>

	<!--- Dev Note: KAL; D13469: Brokerage Application Settings --->
	<cffunction name="getBrokerage_Functionality_On" access="public" output="false" returntype="numeric">
		<cfreturn this.Brokerage_Functionality_On />
	</cffunction>

	<cffunction name="setBrokerage_Functionality_On" access="public" output="false" returntype="void">
		<cfargument name="Brokerage_Functionality_On" type="numeric" required="true" />
		<cfset this.Brokerage_Functionality_On = arguments.Brokerage_Functionality_On />
	</cffunction>

	<!--- Dev Note: KAL; D13469: Brokerage Application Settings --->
	<cffunction name="getAuto_BB_Create_Status_ID" access="public" output="false" returntype="numeric">
		<cfreturn this.Auto_BB_Create_Status_ID />
	</cffunction>

	<cffunction name="setAuto_BB_Create_Status_ID" access="public" output="false" returntype="void">
		<cfargument name="Auto_BB_Create_Status_ID" type="numeric" required="true" />
		<cfset this.Auto_BB_Create_Status_ID = arguments.Auto_BB_Create_Status_ID />
	</cffunction>

	<cffunction name="getBrokerage_Margin_Calculation" access="public" output="false" returntype="numeric">
		<cfreturn this.Brokerage_Margin_Calculation />
	</cffunction>

	<cffunction name="setBrokerage_Margin_Calculation" access="public" output="false" returntype="void">
		<cfargument name="Brokerage_Margin_Calculation" type="numeric" required="true" />
		<cfset this.Brokerage_Margin_Calculation = arguments.Brokerage_Margin_Calculation />
	</cffunction>

	<!--- Forced the BB Reference number to be uppercase --->
	<cffunction name="getBB_Reference_Uppercase" access="public" output="false" returntype="numeric">
		<cfreturn this.BB_Reference_Uppercase />
	</cffunction>

	<cffunction name="setBB_Reference_Uppercase" access="public" output="false" returntype="void">
		<cfargument name="BB_Reference_Uppercase" type="numeric" required="true" />
		<cfset this.BB_Reference_Uppercase = arguments.BB_Reference_Uppercase />
	</cffunction>

	<cffunction name="setSuppressBillbackBusinessConsiderations" access="public" output="false">
		<cfargument name="suppressBillbackBusinessConsiderations" type="string" required="true" />
		<cfset this.suppressBillbackBusinessConsiderations = arguments.suppressBillbackBusinessConsiderations />
	</cffunction>

	<cffunction name="getSuppressBillbackBusinessConsiderations" access="public" output="false" returntype="string">
		<cfreturn this.suppressBillbackBusinessConsiderations />
	</cffunction>

	<cffunction name="setDisplayDistributorOffInvoice" access="public" output="false">
		<cfargument name="DisplayDistributorOffInvoice" type="numeric" required="true" />
		<cfset this.DisplayDistributorOffInvoice = arguments.DisplayDistributorOffInvoice />
	</cffunction>

	<cffunction name="getDisplayDistributorOffInvoice" access="public" output="false" return="numeric">
		<cfreturn this.DisplayDistributorOffInvoice />
	</cffunction>

	<cffunction name="setDisplayProposal" access="public" output="false">
		<cfargument name="DisplayProposal" type="numeric" required="true" />
		<cfset this.DisplayProposal = arguments.DisplayProposal />
	</cffunction>

	<cffunction name="getDisplayProposal" access="public" output="false" return="numeric">
		<cfreturn this.DisplayProposal />
	</cffunction>

	<cffunction name="setDisplayUSDANOI" access="public" output="false">
		<cfargument name="DisplayUSDANOI" type="numeric" required="true" />
		<cfset this.DisplayUSDANOI = arguments.DisplayUSDANOI />
	</cffunction>

	<cffunction name="getDisplayUSDANOI" access="public" output="false" return="numeric">
		<cfreturn this.DisplayUSDANOI />
	</cffunction>

	<cffunction name="setDisableAddingComponentsOnRevision" access="public" output="false">
		<cfargument name="disableAddingComponentsOnRevision" type="numeric" required="true" />
		<cfset this.Disable_Adding_Components_On_Revision = arguments.disableAddingComponentsOnRevision />
	</cffunction>

	<cffunction name="getDisableAddingComponentsOnRevision" access="public" output="false" return="numeric">
		<cfreturn this.Disable_Adding_Components_On_Revision />
	</cffunction>

	<cffunction name="setViewDeleteRecords" access="public" output="false">
		<cfargument name="viewDeleteRecords" type="numeric" required="true" />
		<cfset this.View_Delete_Records = arguments.viewDeleteRecords />
	</cffunction>

	<cffunction name="getViewDeleteRecords" access="public" output="false" return="numeric">
		<cfreturn this.View_Delete_Records />
	</cffunction>

	<cffunction name="setDD_Negative_Splits" access="public" output="false">
		<cfargument name="DD_Negative_Splits" type="numeric" required="true" />
		<cfset this.DD_Negative_Splits = arguments.DD_Negative_Splits />
	</cffunction>

	<cffunction name="getDD_Negative_Splits" access="public" output="false" return="numeric">
		<cfreturn this.DD_Negative_Splits />
	</cffunction>

	<cffunction name="setProgramLockTypeID" access="public" output="false">
		<cfargument name="programLockTypeID" type="numeric" required="true" />
		<cfset this.Program_Lock_Type_ID = arguments.programLockTypeID />
	</cffunction>

	<cffunction name="getProgramLockTypeID" access="public" output="false" return="numeric">
		<cfreturn this.Program_Lock_Type_ID />
	</cffunction>

	<cffunction name="setLabelSets" access="public" output="false">
		<cfargument name="LabelSets" type="numeric" required="true" />
		<cfset this.Label_Sets = arguments.LabelSets />
	</cffunction>

	<cffunction name="getLabelSets" access="public" output="false" returntype="numeric">
		<cfreturn this.Label_Sets />
	</cffunction>

	<cffunction name="setProgramClaimRatesReportAvailable" access="public" output="false">
		<cfargument name="programClaimRatesReportAvailable" type="boolean" required="true" />
		<cfset this.programClaimRatesReportAvailable = arguments.programClaimRatesReportAvailable />
	</cffunction>

	<cffunction name="getProgramClaimRatesReportAvailable" access="public" output="false" returntype="boolean">
		<cfreturn this.programClaimRatesReportAvailable />
	</cffunction>

	<cffunction name="setProgramClaimRatesReportExcludeRegularPrices" access="public" output="false">
		<cfargument name="programClaimRatesReportExcludeRegularPrices" type="boolean" required="true" />
		<cfset this.programClaimRatesReportExcludeRegularPrices = arguments.programClaimRatesReportExcludeRegularPrices />
	</cffunction>

	<cffunction name="getProgramClaimRatesReportExcludeRegularPrices" access="public" output="false" returntype="boolean">
		<cfreturn this.programClaimRatesReportExcludeRegularPrices />
	</cffunction>

	<!--- Dev Note: Milan; 15415 --->
	<cffunction name="setShowReasonCodeOnBBApprovalScreen" access="public" output="false">
		<cfargument name="ShowReasonCodeOnBBApprovalScreen" type="boolean" required="true" />
		<cfset this.Show_Reason_Code_On_BB_Approval_Screen = arguments.ShowReasonCodeOnBBApprovalScreen />
	</cffunction>

	<cffunction name="getShowReasonCodeOnBBApprovalScreen" access="public" output="false" returntype="boolean">
		<cfreturn this.Show_Reason_Code_On_BB_Approval_Screen />
	</cffunction>

	<!--- BJF: D15741 --->
	<cffunction name="setHide_Billback_Adjustments" access="public" output="false">
		<cfargument name="Hide_Billback_Adjustments" type="boolean" required="true" />
		<cfset this.Hide_Billback_Adjustments = arguments.Hide_Billback_Adjustments />
	</cffunction>

	<cffunction name="getHide_Billback_Adjustments" access="public" output="false" returntype="boolean">
		<cfreturn this.Hide_Billback_Adjustments />
	</cffunction>

	<cffunction name="setSSL_On" access="public" output="false">
		<cfargument name="SSL_On" type="boolean" required="true" />
		<cfset this.SSL_On = arguments.SSL_On />
	</cffunction>

	<cffunction name="getSSL_On" access="public" output="false" returntype="boolean">
		<cfreturn this.SSL_On />
	</cffunction>

	<cffunction name="setSSL_On_All_Pages" access="public" output="false">
		<cfargument name="SSL_On_All_Pages" type="boolean" required="true" />
		<cfset this.SSL_On_All_Pages = arguments.SSL_On_All_Pages />
		<cfset application.HTTPVar = "http://">
		<cfif arguments.SSL_On_All_Pages>
			<cfset application.HTTPVar = "https://">
		</cfif>
	</cffunction>

	<cffunction name="getSSL_On_All_Pages" access="public" output="false" returntype="boolean">
		<cfreturn this.SSL_On_All_Pages />
	</cffunction>

	<!--- DAA: D15331 --->
	<cffunction name="setAuditTrailStorage" access="public" output="false">
		<cfargument name="AuditTrailStorage" type="Numeric" required="true" />
		<cfset this.AuditTrailStorage = arguments.AuditTrailStorage />
	</cffunction>

	<cffunction name="getAuditTrailStorage" access="public" output="false" returntype="numeric">
		<cfreturn this.AuditTrailStorage />
	</cffunction>

	<!--- DAA: D16859 --->
	<cffunction name="setAllowBidStatusEditAnytime" access="public" output="false">
		<cfargument name="AllowBidStatusEditAnytime" type="boolean" required="true" />
		<cfset this.AllowBidStatusEditAnytime = arguments.AllowBidStatusEditAnytime />
	</cffunction>

	<cffunction name="getAllowBidStatusEditAnytime" access="public" output="false" returntype="boolean">
		<cfreturn this.AllowBidStatusEditAnytime />
	</cffunction>

	<!--- DAA: D16974 --->
	<cffunction name="setReasonCodeinBillbackDED" access="public" output="false">
		<cfargument name="ReasonCodeinBillbackDED" type="boolean" required="true" />
		<cfset this.ReasonCodeinBillbackDED = arguments.ReasonCodeinBillbackDED />
	</cffunction>

	<cffunction name="getReasonCodeinBillbackDED" access="public" output="false" returntype="boolean">
		<cfreturn this.ReasonCodeinBillbackDED />
	</cffunction>

	<cffunction name="setDaysOfHistoricalDataForSpecialPriceList" access="public" output="false">
		<cfargument name="DaysOfHistoricalDataForSpecialPriceList" type="numeric" required="true" />
		<cfset this.DaysOfHistoricalDataForSpecialPriceList = arguments.DaysOfHistoricalDataForSpecialPriceList />
	</cffunction>

	<cffunction name="getDaysOfHistoricalDataForSpecialPriceList" access="public" output="false" returntype="numeric">
		<cfreturn this.DaysOfHistoricalDataForSpecialPriceList />
	</cffunction>

	<cffunction name="setShowPricingReport" access="public" output="false">
		<cfargument name="ShowPricingReport" type="boolean" required="true" />
		<cfset this.ShowPricingReport = arguments.ShowPricingReport />
	</cffunction>

	<cffunction name="getShowPricingReport" access="public" output="false" returntype="boolean">
		<cfreturn this.ShowPricingReport />
	</cffunction>

	<!--- DRK D16732 --->
	<cffunction name="setBBAllowResetAfterDEDInterface" access="public" output="false">
		<cfargument name="BBAllowResetAfterDEDInterface" type="boolean" required="true" />
		<cfset this.BBAllowResetAfterDEDInterface = arguments.BBAllowResetAfterDEDInterface />
	</cffunction>

	<cffunction name="getBBAllowResetAfterDEDInterface" access="public" output="false" returntype="boolean">
		<cfreturn this.BBAllowResetAfterDEDInterface />
	</cffunction>

	<!--- DRK D16732 --->
	<cffunction name="setBBAllowResetBeforePMTInterfacePRStatus" access="public" output="false">
		<cfargument name="BBAllowResetBeforePMTInterfacePRStatus" type="boolean" required="true" />
		<cfset this.BBAllowResetBeforePMTInterfacePRStatus = arguments.BBAllowResetBeforePMTInterfacePRStatus />
	</cffunction>

	<cffunction name="getBBAllowResetBeforePMTInterfacePRStatus" access="public" output="false" returntype="boolean">
		<cfreturn this.BBAllowResetBeforePMTInterfacePRStatus />
	</cffunction>

	<!--- DRK D13872 --->
	<cffunction name="setProductReplacementEnabled" access="public" output="false">
		<cfargument name="ProductReplacementEnabled" type="boolean" required="true" />
		<cfset this.ProductReplacementEnabled = arguments.ProductReplacementEnabled />
	</cffunction>

	<cffunction name="getProductReplacementEnabled" access="public" output="false" returntype="boolean">
		<cfreturn this.ProductReplacementEnabled />
	</cffunction>

	<!--- Tim Ford: Label 16888 - Approve_LS_Component_By_Profile setter/getter --->
	<cffunction name="setApproveLSComponentByProfile" access="public" output="false">
		<cfargument name="approveLSComponentByProfile" type="boolean" required="true" default="" />
		<cfset this.Approve_LS_Component_By_Profile = arguments.approveLSComponentByProfile />
	</cffunction>

	<cffunction name="getApproveLSComponentByProfile" access="public" output="false" returntype="boolean">
		<cfreturn this.Approve_LS_Component_By_Profile />
	</cffunction>

	<cffunction name="setBillbackAllowMultipleBudgets" access="public" output="false">
		<cfargument name="BillbackAllowMultipleBudgets" type="boolean" required="true" default="" />
		<cfset this.BillbackAllowMultipleBudgets = arguments.BillbackAllowMultipleBudgets />
	</cffunction>

	<cffunction name="getBillbackAllowMultipleBudgets" access="public" output="false" returntype="boolean">
		<cfreturn this.BillbackAllowMultipleBudgets />
	</cffunction>

	<cffunction name="setAllowBillbackToCreditMatching" access="public" output="false">
		<cfargument name="AllowBillbackToCreditMatching" type="boolean" required="true" default="" />
		<cfset this.AllowBillbackToCreditMatching = arguments.AllowBillbackToCreditMatching />
	</cffunction>

	<cffunction name="getAllowBillbackToCreditMatching" access="public" output="false" returntype="boolean">
		<cfreturn this.AllowBillbackToCreditMatching />
	</cffunction>

	<cffunction name="setMaxFutureDaysForClaimRatesORPricingExtract" access="public" output="false">
		<cfargument name="MaxFutureDaysForClaimRatesORPricingExtract" type="numeric" required="true" />
		<cfset this.MaxFutureDaysForClaimRatesORPricingExtract = arguments.MaxFutureDaysForClaimRatesORPricingExtract />
	</cffunction>

	<cffunction name="getMaxFutureDaysForClaimRatesORPricingExtract" access="public" output="false" returntype="numeric">
		<cfreturn this.MaxFutureDaysForClaimRatesORPricingExtract />
	</cffunction>

	<!--- Dev Note: Milan 17867  --->
	<cffunction name="setIsVantageOn" access="public" output="false">
		<cfargument name="IsVantageOn" type="boolean" required="true" default="" />
		<cfset this.IsVantageOn = arguments.IsVantageOn />
	</cffunction>

	<cffunction name="getIsVantageOn" access="public" output="false" returntype="boolean">
		<cfreturn this.IsVantageOn />
	</cffunction>

	<!--- Dev Note: Milan 17867  --->
	<cffunction name="setVantageDataSource" access="public" output="false">
		<cfargument name="VantageDataSource" type="string" required="true" />
		<cfset this.VantageDataSource = arguments.VantageDataSource />
	</cffunction>

	<cffunction name="getVantageDataSource" access="public" output="false" returntype="string">
		<cfreturn this.VantageDataSource />
	</cffunction>

	<!--- Dev Note: BJF 18081  --->
	<cffunction name="setSearch_Selection_Tracking_On" access="public" output="false">
		<cfargument name="Search_Selection_Tracking_On" type="boolean" required="true" default="" />
		<cfset this.Search_Selection_Tracking_On = arguments.Search_Selection_Tracking_On />
	</cffunction>

	<cffunction name="getSearch_Selection_Tracking_On" access="public" output="false" returntype="boolean">
		<cfreturn this.Search_Selection_Tracking_On />
	</cffunction>

	<!--- Dev Note: DRK 18668  --->
	<cffunction name="setExpiredRecentlyDays" access="public" output="false">
		<cfargument name="expiredRecentlyDays" type="numeric" required="true" default="" />
		<cfset this.expiredRecentlyDays = arguments.expiredRecentlyDays />
	</cffunction>

	<cffunction name="getExpiredRecentlyDays" access="public" output="false" returntype="numeric">
		<cfreturn this.expiredRecentlyDays />
	</cffunction>

	<!--- Dev Note: TSF 18682  --->
	<cffunction name="setPreActiveReplaceParent" access="public" output="false">
		<cfargument name="Pre_Active_Replace_Parent" type="numeric" required="true" default="" />
		<cfset this.Pre_Active_Replace_Parent = arguments.Pre_Active_Replace_Parent />
	</cffunction>

	<cffunction name="getPreActiveReplaceParent" access="public" output="false" returntype="numeric">
		<cfreturn this.Pre_Active_Replace_Parent />
	</cffunction>

	<!--- Dev Note: 18882  --->
	<cffunction name="setViewProgramVolumeUOM" access="public" output="false">
		<cfargument name="View_Program_Volume_UOM" type="numeric" required="true" default="" />
		<cfset this.View_Program_Volume_UOM = arguments.View_Program_Volume_UOM />
	</cffunction>

	<cffunction name="getViewProgramVolumeUOM" access="public" output="false" returntype="numeric">
		<cfreturn this.View_Program_Volume_UOM />
	</cffunction>

	<!--- Dev Note: 18882  --->
	<cffunction name="setViewProgramEstimatedAmount" access="public" output="false">
		<cfargument name="View_Program_Estimated_Amount" type="numeric" required="true" default="" />
		<cfset this.View_Program_Estimated_Amount = arguments.View_Program_Estimated_Amount />
	</cffunction>

	<cffunction name="getViewProgramEstimatedAmount" access="public" output="false" returntype="numeric">
		<cfreturn this.View_Program_Estimated_Amount />
	</cffunction>

	<!--- Dev Note: TSF 18940  --->
	<cffunction name="setFilterBusinessSegments" access="public" output="false">
		<cfargument name="Filter_Business_Segments" type="numeric" required="true" default="" />
		<cfset this.Filter_Business_Segments = arguments.Filter_Business_Segments />
	</cffunction>

	<cffunction name="getFilterBusinessSegments" access="public" output="false" returntype="numeric">
		<cfreturn this.Filter_Business_Segments />
	</cffunction>

	<!--- Dev Note: TSF 18950  --->
	<cffunction name="setProgramAlerts" access="public" output="false">
		<cfargument name="Program_Alerts" type="numeric" required="true" default="" />
		<cfset this.Program_Alerts = arguments.Program_Alerts />
	</cffunction>

	<cffunction name="getProgramAlerts" access="public" output="false" returntype="numeric">
		<cfreturn this.Program_Alerts />
	</cffunction>

	<!--- Dev Note: BJF 19170  --->
	<cffunction name="setReset_Won_Lost_On_Revision" access="public" output="false">
		<cfargument name="Reset_Won_Lost_On_Revision" type="numeric" required="true" default="" />
		<cfset this.Reset_Won_Lost_On_Revision = arguments.Reset_Won_Lost_On_Revision />
	</cffunction>

	<cffunction name="getReset_Won_Lost_On_Revision" access="public" output="false" returntype="numeric">
		<cfreturn this.Reset_Won_Lost_On_Revision />
	</cffunction>

	<!--- Dev Note: KAL; D19440: Approval Via Email --->
	<!--- Getter: ApprovalViaEmail --->
	<cffunction name="getApprovalViaEmail" returntype="numeric" access="public" output="false">
		<cfreturn this.ApprovalViaEmail />
	</cffunction>

	<!--- Setter: ApprovalViaEmail --->
	<cffunction name="setApprovalViaEmail" access="public" output="false" >
		<cfargument  name="local_ApprovalViaEmail" required="true" default="0" type="numeric" />
		<cfset this.ApprovalViaEmail = local_ApprovalViaEmail />
	</cffunction>

	<cffunction name="getPinMinLength" returntype="numeric" access="public" output="false">
		<cfreturn this.pinMinLength />
	</cffunction>

	<cffunction name="setPinMinLength" access="public" output="false" >
		<cfargument  name="local_pinMinLength" required="true" default="0" type="numeric" />
		<cfset this.pinMinLength = local_pinMinLength />
	</cffunction>

	<cffunction name="getEmailOutJobTime" returntype="string" access="public" output="false">
		<cfreturn this.emailOutJobTime />
	</cffunction>

	<cffunction name="setEmailOutJobTime" access="public" output="false" >
		<cfargument  name="local_emailOutJobTime" required="true" default="" type="string" />
		<cfset this.emailOutJobTime = local_emailOutJobTime />
	</cffunction>

	<cffunction name="getEmailOutJobSuccess" returntype="string" access="public" output="false">
		<cfreturn this.emailOutJobSuccess />
	</cffunction>

	<cffunction name="setEmailOutJobSuccess" access="public" output="false" >
		<cfargument  name="local_emailOutJobSuccess" required="true" default="" type="string" />
		<cfset this.emailOutJobSuccess = local_emailOutJobSuccess />
	</cffunction>

	<cffunction name="getEmailInJobInterval" returntype="numeric" access="public" output="false">
		<cfreturn this.emailInJobInterval />
	</cffunction>

	<cffunction name="setEmailInJobInterval" access="public" output="false" >
		<cfargument  name="local_emailInJobInterval" required="true" default="0" type="numeric" />
		<cfset this.emailInJobInterval = local_emailInJobInterval />
	</cffunction>

	<cffunction name="getEmailInJobSuccess" returntype="string" access="public" output="false">
		<cfreturn this.emailInJobSuccess />
	</cffunction>

	<cffunction name="setEmailInJobSuccess" access="public" output="false" >
		<cfargument  name="local_emailInJobSuccess" required="true" default="" type="string" />
		<cfset this.emailInJobSuccess = local_emailInJobSuccess />
	</cffunction>

	<cffunction name="getEmailApprovalInstructions" returntype="string" access="public" output="false">
		<cfreturn this.emailApprovalInstructions />
	</cffunction>

	<cffunction name="setEmailApprovalInstructions" access="public" output="false" >
		<cfargument  name="local_emailApprovalInstructions" required="true" default="" type="string" />
		<cfset this.emailApprovalInstructions = local_emailApprovalInstructions />
	</cffunction>
	<!--- End Note: KAL; D19440: Approval Via Email --->

	<!--- Dev Note: BJF 19297  --->
	<cffunction name="setDD_Restrict_ShipTo_For_BB" access="public" output="false">
		<cfargument name="DD_Restrict_ShipTo_For_BB" type="numeric" required="true" default="" />
		<cfset this.DD_Restrict_ShipTo_For_BB = arguments.DD_Restrict_ShipTo_For_BB />
	</cffunction>

	<cffunction name="getDD_Restrict_ShipTo_For_BB" access="public" output="false" returntype="numeric">
		<cfreturn this.DD_Restrict_ShipTo_For_BB />
	</cffunction>

	<!--- Dev Note: BJF  --->
	<cffunction name="setPrimary_Product_Attribute" access="public" output="false">
		<cfargument name="Primary_Product_Attribute" type="string" required="true" default="" />
		<cfset this.Primary_Product_Attribute = arguments.Primary_Product_Attribute />
	</cffunction>

	<cffunction name="getPrimary_Product_Attribute" access="public" output="false" returntype="string">
		<cfreturn this.Primary_Product_Attribute />
	</cffunction>

	<!--- Dev Note: BJF 19303  --->
	<cffunction name="setBB_Inserts_Credit_To_Invoices" access="public" output="false">
		<cfargument name="BB_Inserts_Credit_To_Invoices" type="numeric" required="true" default="" />
		<cfset this.BB_Inserts_Credit_To_Invoices = arguments.BB_Inserts_Credit_To_Invoices />
	</cffunction>

	<cffunction name="getBB_Inserts_Credit_To_Invoices" access="public" output="false" returntype="numeric">
		<cfreturn this.BB_Inserts_Credit_To_Invoices />
	</cffunction>

	<!--- Dev Note: BJF 19303  --->
	<cffunction name="setBB_Status_To_Insert_Credit" access="public" output="false">
		<cfargument name="BB_Status_To_Insert_Credit" type="numeric" required="true" default="" />
		<cfset this.BB_Status_To_Insert_Credit = arguments.BB_Status_To_Insert_Credit />
	</cffunction>

	<cffunction name="getBB_Status_To_Insert_Credit" access="public" output="false" returntype="numeric">
		<cfreturn this.BB_Status_To_Insert_Credit />
	</cffunction>

	<cffunction name="setShow_BB_Summary_Statement" access="public" output="false">
		<cfargument name="Show_BB_Summary_Statement" type="numeric" required="true" default="" />
		<cfset this.Show_BB_Summary_Statement = arguments.Show_BB_Summary_Statement />
	</cffunction>

	<cffunction name="getShow_BB_Summary_Statement" access="public" output="false" returntype="numeric">
		<cfreturn this.Show_BB_Summary_Statement />
	</cffunction>

	<!--- 27047 - ChrisN --->
	<cffunction name="setBillBack_Statement_Type" access="public" output="false">
		<cfargument name="value" type="string" required="true" default="" />
		<cfset this.BillBack_Statement_Type = arguments.value />
	</cffunction>

	<cffunction name="getBillBack_Statement_Type" access="public" output="false" returntype="string">
		<cfreturn this.BillBack_Statement_Type />
	</cffunction>

	<!--- Dev Note: Milan 19451 --->
	<cffunction name="setOperator_Creation_Fields_Required" access="public" output="false">
		<cfargument name="Operator_Creation_Fields_Required" type="boolean" required="true" />
		<cfset this.Operator_Creation_Fields_Required = arguments.Operator_Creation_Fields_Required />
	</cffunction>

	<cffunction name="getOperator_Creation_Fields_Required" access="public" output="false" returntype="boolean">
		<cfreturn this.Operator_Creation_Fields_Required />
	</cffunction>

	<!--- Start: Dev Notes: Anand Rao 19441 --->
	<cffunction name="getBB_Deviations_Override_Price" access="public" output="false" returntype="numeric">
		<cfreturn this.BB_Deviations_Override_Price />
	</cffunction>

	<cffunction name="setBB_Deviations_Override_Price" access="public" output="false" returntype="void">
		<cfargument name="BB_Deviations_Override_Price" type="boolean" required="true" />
		<cfset this.BB_Deviations_Override_Price = arguments.BB_Deviations_Override_Price />
	</cffunction>

	<cffunction name="getBB_Upload_III_P_Qty_Amt_Editable" access="public" output="false" returntype="numeric">
		<cfreturn this.BB_Upload_III_P_Qty_Amt_Editable />
	</cffunction>

	<cffunction name="setBB_Upload_III_P_Qty_Amt_Editable" access="public" output="false" returntype="void">
		<cfargument name="BB_Upload_III_P_Qty_Amt_Editable" type="boolean" required="true" />
		<cfset this.BB_Upload_III_P_Qty_Amt_Editable = arguments.BB_Upload_III_P_Qty_Amt_Editable />
	</cffunction>

	<cffunction name="getFlex_BB_Deviation" access="public" output="false" returntype="numeric">
		<cfreturn this.Flex_BB_Deviation />
	</cffunction>

	<cffunction name="setFlex_BB_Deviation" access="public" output="false" returntype="void">
		<cfargument name="Flex_BB_Deviation" type="boolean" required="true" />
		<cfset this.Flex_BB_Deviation = arguments.Flex_BB_Deviation />
	</cffunction>
	<!--- End: Dev Notes: Anand Rao 19441 --->

	<!--- Dev Notes: Ana - D24087 - BB Fractional Volumn --->
	<cffunction name="getBB_Fractional_Volume" access="public" output="false" returntype="numeric">
		<cfreturn this.BB_Fractional_Volume />
	</cffunction>

	<cffunction name="setBB_Fractional_Volume" access="public" output="false" returntype="void">
		<cfargument name="BB_Fractional_Volume" type="boolean" required="true" />
		<cfset this.BB_Fractional_Volume = arguments.BB_Fractional_Volume />
	</cffunction>
	<!--- Dev Notes: Ana - D24087 - BB Fractional Volumn --->

	<!--- Start: Dev Notes: 21185/Anand Rao/10-Nov-09  --->
	<cffunction name="getDisplay_Vendor_ID_Null_Form" access="public" output="false" returntype="numeric">
		<cfreturn this.Display_Vendor_ID_Null_Form />
	</cffunction>

	<cffunction name="setDisplay_Vendor_ID_Null_Form" access="public" output="false" returntype="void">
		<cfargument name="Display_Vendor_ID_Null_Form" type="boolean" required="true" />
		<cfset this.Display_Vendor_ID_Null_Form = arguments.Display_Vendor_ID_Null_Form />
	</cffunction>
	<!--- End: Dev Notes: 21185/Anand Rao/10-Nov-09  --->

	<!--- Dev Note: KAL; D20523: App setting to turn flex search tools on/off --->
	<!--- Getter: FlexProgramSearch --->
	<cffunction name="getFlexProgramSearch" returntype="numeric" access="public" output="false">
		<cfreturn this.FlexProgramSearch />
	</cffunction>

	<!--- Setter: FlexProgramSearch --->
	<cffunction name="setFlexProgramSearch" access="public" output="false" >
		<cfargument  name="FlexProgramSearch" required="true" default="0" type="numeric" /><!---D29074: changed Vollean to numeric --->
		<cfset this.FlexProgramSearch = FlexProgramSearch />
	</cffunction>

	<!--- START: 31505: App setting for Flex BB Module/Anand Rao/24-Apr-2012 --->
	<cffunction name="getBillbackModuleType" returntype="numeric" access="public" output="false">
		<cfreturn this.BillbackModuleType />
	</cffunction>

	<!--- Setter: BillbackModule --->
	<cffunction name="setBillbackModuleType" access="public" output="false" >
		<cfargument  name="BillbackModuleType" required="true" default="0" type="numeric" />
		<cfset this.BillbackModuleType = BillbackModuleType />
	</cffunction>
	<!--- END: 31505: App setting for Flex BB Module/Anand Rao/24-Apr-2012 --->

	<!--- Getter: FlexDistributorSearch --->
	<cffunction name="getFlexDistributorSearch" returntype="boolean" access="public" output="false">
		<cfreturn this.FlexDistributorSearch />
	</cffunction>

	<!--- Setter: FlexDistributorSearch --->
	<cffunction name="setFlexDistributorSearch" access="public" output="false" >
		<cfargument  name="local_FlexDistributorSearch" required="true" default="0" type="boolean" />
		<cfset this.FlexDistributorSearch = local_FlexDistributorSearch />
	</cffunction>

	<!--- Getter: FlexBrokerSearch --->
	<cffunction name="getFlexBrokerSearch" returntype="boolean" access="public" output="false">
		<cfreturn this.FlexBrokerSearch />
	</cffunction>

	<!--- Setter: FlexBrokerSearch --->
	<cffunction name="setFlexBrokerSearch" access="public" output="false" >
		<cfargument  name="local_FlexBrokerSearch" required="true" default="0" type="boolean" />
		<cfset this.FlexBrokerSearch = local_FlexBrokerSearch />
	</cffunction>

	<!--- Getter: FlexOperatorSearch --->
	<cffunction name="getFlexOperatorSearch" returntype="boolean" access="public" output="false">
		<cfreturn this.FlexOperatorSearch />
	</cffunction>

	<!--- Setter: FlexOperatorSearch --->
	<cffunction name="setFlexOperatorSearch" access="public" output="false" >
		<cfargument  name="local_FlexOperatorSearch" required="true" default="0" type="boolean" />
		<cfset this.FlexOperatorSearch = local_FlexOperatorSearch />
	</cffunction>

	<!--- Getter: FlexProductSearch --->
	<cffunction name="getFlexProductSearch" returntype="boolean" access="public" output="false">
		<cfreturn this.FlexProductSearch />
	</cffunction>

	<!--- Setter: FlexProductSearch --->
	<cffunction name="setFlexProductSearch" access="public" output="false" >
		<cfargument  name="local_FlexProductSearch" required="true" default="0" type="boolean" />
		<cfset this.FlexProductSearch = local_FlexProductSearch />
	</cffunction>
	<!--- End Note: KAL; D20523: App setting to turn flex search tools on/off --->

	<!--- Dev Note: Milan 20399 --->
	<cffunction name="setThirdPartyBBUpload" access="public" output="false">
		<cfargument name="ThirdPartyBBUpload" type="numeric" required="true" />
		<cfset this.ThirdPartyBBUpload = arguments.ThirdPartyBBUpload />
	</cffunction>

	<cffunction name="getThirdPartyBBUpload" access="public" output="false" returntype="numeric">
		<cfreturn this.ThirdPartyBBUpload />
	</cffunction>

	<!--- Dev Note: TSF 20454 --->
	<cffunction name="setBBShowModifyProgram" access="public" output="false">
		<cfargument name="BBShowModifyProgram" type="numeric" required="true" />
		<cfset this.BB_Show_Modify_Program = arguments.BBShowModifyProgram />
	</cffunction>

	<cffunction name="getBBShowModifyProgram" access="public" output="false" returntype="numeric">
		<cfreturn this.BB_Show_Modify_Program />
	</cffunction>

	<!--- Dev Note: Milan 20724 --->
	<!---
	<cffunction name="setDisplay_Hold_Release_Checkbox" access="public" output="false">
	<cfargument name="DisplayHoldReleaseCheckbox" type="boolean" required="true" />
	<cfset this.DisplayHoldReleaseCheckbox = arguments.DisplayHoldReleaseCheckbox />
	</cffunction>

	<cffunction name="getDisplay_Hold_Release_Checkbox" access="public" output="false" returntype="boolean">
	<cfreturn this.DisplayHoldReleaseCheckbox />
	</cffunction>
	--->

	<!--- Dev Note: KAL; D20537: Margin Approval - Trade as Percent of Gross Sales. Forge changes --->
	<!--- Getter: approvalMarginType --->
	<cffunction name="getApprovalMarginType" returntype="numeric" access="public" output="false">
		<cfreturn this.approvalMarginType />
	</cffunction>

	<!--- Setter: approvalMarginType --->
	<cffunction name="setApprovalMarginType" access="public" output="false" >
		<cfargument  name="approvalMarginType" required="true" type="numeric" />
		<cfset this.approvalMarginType = approvalMarginType />
	</cffunction>

	<!--- Dev Note: BJF D21595: Display option related to Kal's 20537 above' --->
	<!--- Getter: Display_Trade_Percent_on_Margin --->
	<cffunction name="getDisplay_Trade_Percent_on_Margin" returntype="boolean" access="public" output="false">
		<cfreturn this.Display_Trade_Percent_on_Margin />
	</cffunction>

	<!--- Setter: approvalMarginType --->
	<cffunction name="setDisplay_Trade_Percent_on_Margin" access="public" output="false" >
		<cfargument  name="Display_Trade_Percent_on_Margin" required="true" type="boolean" />
		<cfset this.Display_Trade_Percent_on_Margin = Display_Trade_Percent_on_Margin />
	</cffunction>

	<!--- Dev Notes: 23637/Anand Rao/08-Jun-10; Operating Income % calculation --->
	<cffunction name="getMarginOperatingIncomePercentType" returntype="numeric" access="public" output="false">
		<cfreturn this.marginOperatingIncomePercentType />
	</cffunction>

	<!--- Setter: approvalMarginType --->
	<cffunction name="setMarginOperatingIncomePercentType" access="public" output="false" >
		<cfargument  name="marginOperatingIncomePercentType" required="true" type="numeric" />
		<cfset this.marginOperatingIncomePercentType = marginOperatingIncomePercentType />
	</cffunction>

	<!--- Getter: DisplayCashDiscountMargin --->
	<cffunction name="getDisplayCashDiscountMargin" returntype="boolean" access="public" output="false">
		<cfreturn this.DisplayCashDiscountMargin />
	</cffunction>

	<!--- Setter: DisplayCashDiscountMargin --->
	<cffunction name="setDisplayCashDiscountMargin" access="public" output="false" >
		<cfargument  name="DisplayCashDiscountMargin" required="true" default="1" type="boolean" />
		<cfset this.DisplayCashDiscountMargin = DisplayCashDiscountMargin />
	</cffunction>

	<!--- Getter: BBAutoPayToOperatorUseInvoiceOprID --->
	<cffunction name="getBBAutoPayToOperatorUseInvoiceOprID" returntype="boolean" access="public" output="false">
		<cfreturn this.BBAutoPayToOperatorUseInvoiceOprID />
	</cffunction>

	<!--- Setter: BBAutoPayToOperatorUseInvoiceOprID --->
	<cffunction name="setBBAutoPayToOperatorUseInvoiceOprID" access="public" output="false" >
		<cfargument  name="BBAutoPayToOperatorUseInvoiceOprID" required="true" default="0" type="boolean" />
		<cfset this.BBAutoPayToOperatorUseInvoiceOprID = arguments.BBAutoPayToOperatorUseInvoiceOprID />
	</cffunction>

	<!--- Getter: BBProductAllowZeroVolume --->
	<cffunction name="getBBProductAllowZeroVolume" returntype="boolean" access="public" output="false">
		<cfreturn this.BB_Product_Allow_Zero_Volume />
	</cffunction>

	<!--- Setter: BBProductAllowZeroVolume --->
	<cffunction name="setBBProductAllowZeroVolume" access="public" output="false" >
		<cfargument  name="BB_Product_Allow_Zero_Volume" required="true" default="0" type="boolean" />
		<cfset this.BB_Product_Allow_Zero_Volume = arguments.BB_Product_Allow_Zero_Volume />
	</cffunction>

	<!--- Start: Dev Notes: 21923/Anand Rao/22-Jan-2010  --->
	<cffunction name="getUpdate_BB_Approve_Amt" access="public" output="false" returntype="numeric">
		<cfreturn this.Update_BB_Approve_Amt />
	</cffunction>

	<cffunction name="setUpdate_BB_Approve_Amt" access="public" output="false" returntype="void">
		<cfargument name="Update_BB_Approve_Amt" type="boolean" required="true" />
		<cfset this.Update_BB_Approve_Amt = arguments.Update_BB_Approve_Amt />
	</cffunction>

	<cffunction name="getBB_Approve_Expected_Rate_Less_Tolerance" access="public" output="false" returntype="numeric">
		<cfreturn this.BB_Approve_Expected_Rate_Less_Tolerance />
	</cffunction>

	<cffunction name="setBB_Approve_Expected_Rate_Less_Tolerance" access="public" output="false" returntype="void">
		<cfargument name="BB_Approve_Expected_Rate_Less_Tolerance" type="boolean" required="true" />
		<cfset this.BB_Approve_Expected_Rate_Less_Tolerance = arguments.BB_Approve_Expected_Rate_Less_Tolerance />
	</cffunction>

	<!--- End: Dev Notes: 21923/Anand Rao/22-Jan-2010  --->
	<cffunction name="getTPA_Includes_PreActive" access="public" output="false" returntype="numeric">
		<cfreturn this.TPA_Includes_PreActive />
	</cffunction>

	<cffunction name="setTPA_Includes_PreActive" access="public" output="false" returntype="void">
		<cfargument name="TPA_Includes_PreActive" type="boolean" required="true" />
		<cfset this.TPA_Includes_PreActive = arguments.TPA_Includes_PreActive />
	</cffunction>

	<cffunction name="getTPA_Includes_Active" access="public" output="false" returntype="numeric">
		<cfreturn this.TPA_Includes_Active />
	</cffunction>

	<cffunction name="setTPA_Includes_Active" access="public" output="false" returntype="void">
		<cfargument name="TPA_Includes_Active" type="boolean" required="true" />
		<cfset this.TPA_Includes_Active = arguments.TPA_Includes_Active />
	</cffunction>

	<cffunction name="getTPA_Includes_Expiring" access="public" output="false" returntype="numeric">
		<cfreturn this.TPA_Includes_Expiring />
	</cffunction>

	<cffunction name="setTPA_Includes_Expiring" access="public" output="false" returntype="void">
		<cfargument name="TPA_Includes_Expiring" type="boolean" required="true" />
		<cfset this.TPA_Includes_Expiring = arguments.TPA_Includes_Expiring />
	</cffunction>

	<cffunction name="getTPA_Includes_Program_Dates" access="public" output="false" returntype="boolean">
		<cfreturn this.TPA_Includes_Program_Dates />
	</cffunction>

	<cffunction name="setTPA_Includes_Program_Dates" access="public" output="false" returntype="void">
		<cfargument name="TPA_Includes_Program_Dates" type="boolean" required="true" />
		<cfset this.TPA_Includes_Program_Dates = arguments.TPA_Includes_Program_Dates />
	</cffunction>

	<!--- Start: Dev Notes: 19384/Anand Rao/05-Apr-10 Rebill Interface and changes --->
	<cffunction name="getIntegrated_Rebill" access="public" output="false" returntype="numeric">
		<cfreturn this.Integrated_Rebill />
	</cffunction>

	<cffunction name="setIntegrated_Rebill" access="public" output="false" returntype="void">
		<cfargument name="Integrated_Rebill" type="boolean" required="true" />
		<cfset this.Integrated_Rebill = arguments.Integrated_Rebill />
	</cffunction>
	<!--- End: Dev Notes: 19384/Anand Rao/05-Apr-10 Rebill Interface and changes --->

	<!--- Dev Notes: 21554/Anand Rao/30-Apr-10 HZ - Single sign on to application using LDAP --->
	<cffunction name="getLDAP_SSO_Enabled" access="public" output="false" returntype="numeric">
		<cfreturn this.LDAP_SSO_Enabled />
	</cffunction>

	<cffunction name="setLDAP_SSO_Enabled" access="public" output="false" returntype="void">
		<cfargument name="LDAP_SSO_Enabled" type="boolean" required="true" />
		<cfset this.LDAP_SSO_Enabled = arguments.LDAP_SSO_Enabled />
	</cffunction>
	<!--- Dev Notes: 21554/Anand Rao/30-Apr-10 HZ - Single sign on to application using LDAP --->

	<!--- WebserviceOn --->
	<cffunction name="setWebserviceOn" access="public" output="false">
		<cfargument name="WebserviceOn" type="numeric" required="Yes">
		<cfset this.WebserviceOn = arguments.WebserviceOn/>
	</cffunction>

	<cffunction name="getWebserviceOn" access="public" output="false" return="numeric">
		<cfreturn this.WebserviceOn />
	</cffunction>

	<!---setAllowReviseActiveWithPreActive --->
	<cffunction name="setAllowReviseActiveWithPreActive" access="public" output="false">
		<cfargument name="Allow_Revise_Active_With_Pre_Active" type="numeric" required="Yes">
		<cfset this.Allow_Revise_Active_With_Pre_Active = arguments.Allow_Revise_Active_With_Pre_Active />
	</cffunction>

	<!---getAllowReviseActiveWithPreActive --->
	<cffunction name="getAllowReviseActiveWithPreActive" access="public" output="false" return="numeric">
		<cfreturn this.Allow_Revise_Active_With_Pre_Active />
	</cffunction>

	<!--- CreditTypeIsDDReasonCode --->
	<cffunction name="setCreditTypeIsDDReasonCode" access="public" output="false">
		<cfargument name="CreditTypeIsDDReasonCode" type="boolean" required="Yes">
		<cfset this.Credit_Type_Is_DD_Reason_Code = arguments.CreditTypeIsDDReasonCode />
	</cffunction>

	<cffunction name="getCreditTypeIsDDReasonCode" access="public" output="false" return="boolean">
		<cfreturn this.Credit_Type_Is_DD_Reason_Code />
	</cffunction>

	<!---setAllowReviseActiveWithPreActive --->
	<cffunction name="setReasonCodeInBillbackDisplaySetting" access="public" output="false">
		<cfargument name="Reason_Code_in_Billback_Display_Setting" type="numeric" required="Yes">
		<cfset this.Reason_Code_in_Billback_Display_Setting = arguments.Reason_Code_in_Billback_Display_Setting />
	</cffunction>

	<!---getAllowReviseActiveWithPreActive --->
	<cffunction name="getReasonCodeInBillbackDisplaySetting" access="public" output="false" return="numeric">
		<cfreturn this.Reason_Code_in_Billback_Display_Setting />
	</cffunction>

	<!--- Search Inactive Products In Programs --->
	<cffunction name="setSearchInactiveProductsInPrograms" access="public" output="false">
		<cfargument name="SearchInactiveProductsInPrograms" type="boolean" required="Yes">
		<cfset this.Search_Inactive_Products_Programs = arguments.SearchInactiveProductsInPrograms />
	</cffunction>

	<cffunction name="getSearchInactiveProductsInPrograms" access="public" output="false" return="boolean">
		<cfreturn this.Search_inactive_products_programs />
	</cffunction>

	<!--- Search Inactive Distributors In Programs --->
	<cffunction name="setSearchInactiveDistributorsInPrograms" access="public" output="false">
		<cfargument name="SearchInactiveDistributorsInPrograms" type="boolean" required="Yes">
		<cfset this.Search_Inactive_Distributors_Programs = arguments.SearchInactiveDistributorsInPrograms />
	</cffunction>

	<cffunction name="getSearchInactiveDistributorsInPrograms" access="public" output="false" return="boolean">
		<cfreturn this.Search_Inactive_Distributors_Programs />
	</cffunction>

	<!--- Search Inactive Operators In Programs - 26199 2011/feb/23 --->
	<cffunction name="setSearchInactiveOperatorsInPrograms" access="public" output="false">
		<cfargument name="SearchInactiveDistributorsInPrograms" type="boolean" required="Yes">
		<cfset this.Search_Inactive_Operators_Programs = arguments.SearchInactiveDistributorsInPrograms />
	</cffunction>

	<cffunction name="getSearchInactiveOperatorsInPrograms" access="public" output="false" return="boolean">
		<cfreturn this.Search_Inactive_Operators_Programs />
	</cffunction>

	<!--- Dev Note: DRK 18668  --->
	<cffunction name="setDocumentPurgeAge" access="public" output="false">
		<cfargument name="documentPurgeAge" type="any" required="true" default="" />
		<cfset this.documentPurgeAge = arguments.documentPurgeAge />
	</cffunction>

	<cffunction name="getDocumentPurgeAge" access="public" output="false" returntype="any">
		<cfreturn this.documentPurgeAge />
	</cffunction>

	<!--- Dev Note: KAL; 7/22/2010; D23692: modifications to manage document settings page plus docs with prog/bb/ded --->
	<cffunction name="setFTPDocumentPath" access="public" output="false">
		<cfargument name="FTPDocumentPath" type="any" required="true" default="" />
		<cfset this.FTP_Document_Path = arguments.FTPDocumentPath />
	</cffunction>

	<cffunction name="getFTPDocumentPath" access="public" output="false" returntype="any">
		<cfreturn this.FTP_Document_Path />
	</cffunction>

	<!--- Dev Note: KAL; D23601: Margin Items Exclude  --->
	<cffunction name="setMarginItemsExclude" access="public" output="false">
		<cfargument name="marginItemsExclude" type="any" required="true" default="0" />
		<cfset this.marginItemsExclude = arguments.marginItemsExclude />
	</cffunction>

	<cffunction name="getMarginItemsExclude" access="public" output="false" returntype="any">
		<cfreturn this.marginItemsExclude />
	</cffunction>

	<!--- Dev Note: Anand/04-Oct-2010 24526: Planning Group Module  --->
	<cffunction name="setPlanningGroups" access="public" output="false">
		<cfargument name="planningGroups" type="any" required="true" default="0" />
		<cfset this.planningGroups = arguments.planningGroups />
	</cffunction>

	<cffunction name="getPlanningGroups" access="public" output="false" returntype="any">
		<cfreturn this.planningGroups />
	</cffunction>

	<!---24075  Billback_Module Deduction_Module --->
	<cffunction name="setBillback_Module" access="public" output="false">
		<cfargument name="Billback_Module" type="any" required="true" default="" />
		<cfset this.Billback_Module = arguments.Billback_Module />
	</cffunction>

	<cffunction name="getBillback_Module" access="public" output="false" returntype="any">
		<cfreturn this.Billback_Module />
	</cffunction>

	<cffunction name="setDeduction_Module" access="public" output="false">
		<cfargument name="Deduction_Module" type="any" required="true" default="" />
		<cfset this.Deduction_Module = arguments.Deduction_Module />
	</cffunction>

	<cffunction name="getDeduction_Module" access="public" output="false" returntype="any">
		<cfreturn this.Deduction_Module />
	</cffunction>

	<cffunction name="setBBReasonCodeAllowMultiple" access="public" output="false">
		<cfargument name="BB_Reason_Code_Allow_Multiple" type="boolean" required="true" />
		<cfset this.BB_Reason_Code_Allow_Multiple = arguments.BB_Reason_Code_Allow_Multiple />
	</cffunction>

	<cffunction name="getBBReasonCodeAllowMultiple" access="public" output="false" returntype="boolean">
		<cfreturn this.BB_Reason_Code_Allow_Multiple />
	</cffunction>

	<cffunction name="setSimpleClause" access="public" output="false">
		<cfargument name="Simple_Clause" type="boolean" required="true" />
		<cfset this.Simple_Clause = arguments.Simple_Clause />
	</cffunction>

	<cffunction name="getSimpleClause" access="public" output="false" returntype="boolean">
		<cfreturn this.Simple_Clause />
	</cffunction>

	<cffunction name="setBC_On_RFA_af_Reset" access="public" output="false">
		<cfargument name="BC_On_RFA_af_Reset" type="any" required="true" default="0" />
		<cfset this.BC_On_RFA_af_Reset = arguments.BC_On_RFA_af_Reset />
	</cffunction>

	<cffunction name="getBC_On_RFA_af_Reset" access="public" output="false" returntype="any">
		<cfreturn this.BC_On_RFA_af_Reset />
	</cffunction>

	<cffunction name="setRequire_Business_Considerations_On_New_Programs" access="public" output="false">
		<cfargument name="Require_Business_Considerations_On_New_Programs" type="any" required="true" default="0" />
		<cfset this.Require_Business_Considerations_On_New_Programs = arguments.Require_Business_Considerations_On_New_Programs />
	</cffunction>

	<cffunction name="getRequire_Business_Considerations_On_New_Programs" access="public" output="false" returntype="any">
		<cfreturn this.Require_Business_Considerations_On_New_Programs />
	</cffunction>

	<cffunction name="setDD_User_Reference" access="public" output="false">
		<cfargument name="DD_User_Reference" type="any" required="true" default="0" />
		<cfset this.DD_User_Reference = arguments.DD_User_Reference />
	</cffunction>

	<cffunction name="getDD_User_Reference" access="public" output="false" returntype="any">
		<cfreturn this.DD_User_Reference />
	</cffunction>

	<cffunction name="setBBCreatedRecentlyDays" access="public" output="false">
		<cfargument name="BBCreatedRecentlyDays" type="numeric" required="true" default="" />
		<cfset this.BBCreatedRecentlyDays = arguments.BBCreatedRecentlyDays />
	</cffunction>

	<cffunction name="getBBCreatedRecentlyDays" access="public" output="false" returntype="numeric">
		<cfreturn this.BBCreatedRecentlyDays />
	</cffunction>

	<cffunction name="setDisplayNotesFieldOnProgram" access="public" output="false">
		<cfargument name="Display_notes_field_on_program" type="numeric" required="true" default="" />
		<cfset this.Display_notes_field_on_program = arguments.Display_notes_field_on_program />
	</cffunction>

	<cffunction name="getDisplayNotesFieldOnProgram" access="public" output="false" returntype="numeric">
		<cfreturn this.Display_notes_field_on_program />
	</cffunction>

	<cffunction name="setUserAccountMiddleInitial" access="public" output="false">
		<cfargument name="User_Account_Middle_Initial" type="numeric" required="true" default="" />
		<cfset this.User_Account_Middle_Initial = arguments.User_Account_Middle_Initial />
	</cffunction>

	<cffunction name="getUserAccountMiddleInitial" access="public" output="false" returntype="numeric">
		<cfreturn this.User_Account_Middle_Initial />
	</cffunction>

	<cffunction name="setUseFixedPriceType" access="public" output="false">
		<cfargument name="Use_Fixed_Price_Type" type="numeric" required="true" default="" />
		<cfset this.Use_Fixed_Price_Type = arguments.Use_Fixed_Price_Type />
	</cffunction>

	<cffunction name="getUseFixedPriceType" access="public" output="false" returntype="numeric">
		<cfreturn this.Use_Fixed_Price_Type />
	</cffunction>

	<cffunction name="setDisplayQuoteLetter" access="public" output="false">
		<cfargument name="Display_Quote_Letter" type="numeric" required="true" default="" />
		<cfset this.Display_Quote_Letter = arguments.Display_Quote_Letter />
	</cffunction>

	<cffunction name="getDisplayQuoteLetter" access="public" output="false" returntype="numeric">
		<cfreturn this.Display_Quote_Letter />
	</cffunction>

	<cffunction name="setPriceListByTemplate" access="public" output="false">
		<cfargument name="Price_List_By_Template" type="numeric" required="true" default="" />
		<cfset this.Price_List_By_Template = arguments.Price_List_By_Template />
	</cffunction>

	<cffunction name="getPriceListByTemplate" access="public" output="false" returntype="numeric">
		<cfreturn this.Price_List_By_Template />
	</cffunction>

	<cffunction name="setShortcutNoRoutingAllowed" access="public" output="false">
		<cfargument name="Shortcut_No_Routing_Allowed" type="boolean" required="true" default="" />
		<cfset this.Shortcut_No_Routing_Allowed = arguments.Shortcut_No_Routing_Allowed />
	</cffunction>

	<cffunction name="getShortcutNoRoutingAllowed" access="public" output="false" returntype="boolean">
		<cfreturn this.Shortcut_No_Routing_Allowed />
	</cffunction>

	<!--- Dev Note: drachala; D28618: Position Drop Down Fields filtered based on Program Business Segment  START
	Added/Changed: Added New Setting Position Drop Down Fields filtered based on Program Segment--->
	<cffunction name="setPositionFieldsFilterOnProgramSegment" access="public" output="false">
		<cfargument name="Position_Fields_Filtered_Based_On_Program_Segment" type="boolean" required="true" default="" />
		<cfset this.Position_Fields_Filtered_Based_On_Program_Segment = arguments.Position_Fields_Filtered_Based_On_Program_Segment />
	</cffunction>

	<cffunction name="getPositionFieldsFilterOnProgramSegment" access="public" output="false" returntype="boolean">
		<cfreturn this.Position_Fields_Filtered_Based_On_Program_Segment />
	</cffunction>
	<!--- End Dev Note: drachala; D28618: Position Drop Down Fields filtered based on Program Business Segment  --->

	<!--- Dev Note: drachala; D28459: Change Base Sales program labels to custom label for Hormel  START
	Added/Changed: Added below 2 function to UPDATE and PULL values--->
	<cffunction name="setBaseSaleLabel" access="public" output="false">
		<cfargument name="Base_Sale_Label" type="string" required="true" />
		<cfset this.Base_Sale_Label = arguments.Base_Sale_Label />
	</cffunction>

	<cffunction name="getBaseSaleLabel" access="public" output="false" returntype="string">
		<cfreturn this.Base_Sale_Label />
	</cffunction>

	<cffunction name="setNetSaleLabel" access="public" output="false">
		<cfargument name="Net_Sale_Label" type="string" required="true" />
		<cfset this.Net_Sale_Label = arguments.Net_Sale_Label />
	</cffunction>

	<cffunction name="getNetSaleLabel" access="public" output="false" returntype="string">
		<cfreturn this.Net_Sale_Label />
	</cffunction>

	<!--- End Dev Note: drachala; D28459: Change Base Sales program labels to custom label for Hormel  --->
	<cffunction name="setDisplayOnlyBillbackParent" access="public" output="false">
		<cfargument name="Display_Only_Billback_Parent" type="boolean" required="true" default="0" />
		<cfset this.Display_Only_Billback_Parent = arguments.Display_Only_Billback_Parent />
	</cffunction>

	<cffunction name="getDisplayOnlyBillbackParent" access="public" output="false" returntype="boolean">
		<cfreturn this.Display_Only_Billback_Parent />
	</cffunction>

	<!--- D29482: mws Path to a server in client ERP to get .pdf files related to deductions --->
	<cffunction name="setErpDeductionDocPath" access="public" output="false">
		<cfargument name="ErpDeductionDocPath" type="string" required="true" default="" />
		<cfset this.ErpDeductionDocPath = arguments.ErpDeductionDocPath />
	</cffunction>

	<cffunction name="getErpDeductionDocPath" access="public" output="false" returntype="string">
		<cfreturn this.ErpDeductionDocPath />
	</cffunction>

	<!--- 29841  Multiple documents upload for billbacks--->
	<cffunction name="setDocumentsDisplayUploadForm" access="public" output="false">
		<cfargument name="Documents_Display_Upload_Form" type="boolean" required="true" default="0" />
		<cfset this.Documents_Display_Upload_Form = arguments.Documents_Display_Upload_Form />
	</cffunction>

	<cffunction name="getDocumentsDisplayUploadForm" access="public" output="false" returntype="boolean">
		<cfreturn this.Documents_Display_Upload_Form />
	</cffunction>

	<!---28345 Chris Added External Contacts--->
	<cffunction name="setExternal_Contacts" access="public" output="false">
		<cfargument name="External_Contacts_Option" type="boolean" required="true" default="0" />
		<cfset this.External_Contacts_Option = arguments.External_Contacts_Option />
	</cffunction>

	<cffunction name="getExternal_Contacts" access="public" output="false" returntype="boolean">
		<cfreturn this.External_Contacts_Option />
	</cffunction>

	<!---30417 Settings for product master edit feature--->
	<cffunction name="setEdit_Product_Master_Data" access="public" output="false">
		<cfargument name="Edit_Product_Master_Data" type="boolean" required="true" default="0" />
		<cfset this.Edit_Product_Master_Data = arguments.Edit_Product_Master_Data />
	</cffunction>

	<cffunction name="getEdit_Product_Master_Data" access="public" output="false" returntype="boolean">
		<cfreturn this.Edit_Product_Master_Data />
	</cffunction>

	<!--- D29997: Update Items proposal status based on approved billback/Anand Rao/15-Feb-2012  --->
	<cffunction name="setPrgWonLostOnBBApproval" access="public" output="false">
		<cfargument name="PrgWonLostOnBBApproval" type="numeric" required="true" default="0" />
		<cfset this.PrgWonLostOnBBApproval = arguments.PrgWonLostOnBBApproval />
	</cffunction>

	<cffunction name="getPrgWonLostOnBBApproval" access="public" output="false" returntype="numeric">
		<cfreturn this.PrgWonLostOnBBApproval />
	</cffunction>

	<!--- D30750:Create app setting to use invoice cost from invoice file START --->
	<cffunction name="setInvoiceCostForVantage" access="public" output="false">
		<cfargument name="InvoiceCostForVantage" type="boolean" required="true" default="0" />
		<cfset this.InvoiceCostForVantage = arguments.InvoiceCostForVantage />
	</cffunction>

	<cffunction name="getInvoiceCostForVantage" access="public" output="false" returntype="boolean">
		<cfreturn this.InvoiceCostForVantage />
	</cffunction>
	<!--- D30750:Create app setting to use invoice cost from invoice file END --->

	<!--- D30486: Multiple AR numbers to 1 Account(Customer)-UI START --->
	<cffunction name="setMultipleBillTosForShipTo" access="public" output="false">
		<cfargument name="multipleBillTosForShipTo" type="boolean" required="true" default="0" />
		<cfset this.Multiple_BillTos_For_ShipTo = arguments.multipleBillTosForShipTo />
	</cffunction>

	<cffunction name="getMultipleBillTosForShipTo" access="public" output="false" returntype="boolean">
		<cfreturn this.Multiple_BillTos_For_ShipTo />
	</cffunction>
	<!--- D30486: Multiple AR numbers to 1 Account(Customer)-UI END --->

	<!--- D25219: SOW - Enable mass paying of payables START --->
	<cffunction name="setBillbackQuickPay" access="public" output="false">
		<cfargument name="BillbackQuickPay" type="numeric" required="true" default="0" />
		<cfset this.BillbackQuickPay = arguments.BillbackQuickPay />
	</cffunction>

	<cffunction name="getBillbackQuickPay" access="public" output="false" returntype="numeric">
		<cfreturn this.BillbackQuickPay />
	</cffunction>
	<!--- D25219: SOW - Enable mass paying of payables END --->

	<!--- D30065:LUMP SUM DOLLAR ALLOCATION ON CASE VOLUME BASIS START --->
	<cffunction name="setLS_Allocation" access="public" output="false">
		<cfargument name="LS_Allocation" type="numeric" required="true" default="2" />
		<cfset this.LS_Allocation = arguments.LS_Allocation />
	</cffunction>

	<cffunction name="getLS_Allocation" access="public" output="false" returntype="numeric">
		<cfreturn this.LS_Allocation />
	</cffunction>
	<!--- D30065:LUMP SUM DOLLAR ALLOCATION ON CASE VOLUME BASIS END --->

	<cffunction name="setDDClosedBBStatus" access="public" output="false">
		<cfargument name="DD_Closed_BB_Status" type="boolean" required="true" default="0" />
		<cfset this.DD_Closed_BB_Status = arguments.DD_Closed_BB_Status />
	</cffunction>

	<cffunction name="getDDClosedBBStatus" access="public" output="false" returntype="boolean">
		<cfreturn this.DD_Closed_BB_Status />
	</cffunction>

	<cffunction name="setBBResetUnacknowledgedInterface" access="public" output="false">
		<cfargument name="BB_Reset_Unacknowledged_Interface" type="boolean" required="true" default="0" />
		<cfset this.BB_Reset_Unacknowledged_Interface = arguments.BB_Reset_Unacknowledged_Interface />
	</cffunction>

	<cffunction name="getBBResetUnacknowledgedInterface" access="public" output="false" returntype="boolean">
		<cfreturn this.BB_Reset_Unacknowledged_Interface />
	</cffunction>

	<cffunction name="setBBReinterfaceUnacknowledgedInterface" access="public" output="false">
		<cfargument name="BB_Reinterface_Unacknowledged_Interface" type="boolean" required="true" default="0" />
		<cfset this.BB_Reinterface_Unacknowledged_Interface = arguments.BB_Reinterface_Unacknowledged_Interface />
	</cffunction>

	<cffunction name="getBBReinterfaceUnacknowledgedInterface" access="public" output="false" returntype="boolean">
		<cfreturn this.BB_Reinterface_Unacknowledged_Interface />
	</cffunction>

	<cffunction name="setBillbackDisplayAllProgramComponents" access="public" output="false">
		<cfargument name="Billback_Display_All_Program_Components" type="boolean" required="true" default="0" />
		<cfset this.Billback_Display_All_Program_Components = arguments.Billback_Display_All_Program_Components />
	</cffunction>

	<cffunction name="getBillbackDisplayAllProgramComponents" access="public" output="false" returntype="boolean">
		<cfreturn this.Billback_Display_All_Program_Components />
	</cffunction>

	<!--- 31616 -Add favorite icon to URL address line --->
	<cffunction name="setFaviconPath" access="public" output="false">
		<cfargument name="faviconPath" type="string" required="true" default="" />
		<cfset this.Favicon_Path = arguments.faviconPath />
	</cffunction>

	<cffunction name="getFaviconPath" access="public" output="false" returntype="string">
		<cfreturn this.Favicon_Path />
	</cffunction>

	<!--- 31769 - Billback Deviation Grid --->
	<cffunction name="setBB_LS_Claimed_Rebate_Expected" access="public" output="false">
		<cfargument name="BB_LS_Claimed_Rebate_Expected" required="true" type="boolean" />
		<cfset this.BB_LS_Claimed_Rebate_Expected = arguments.BB_LS_Claimed_Rebate_Expected />
	</cffunction>

	<cffunction name="getBB_LS_Claimed_Rebate_Expected" access="public" output="false" returntype="boolean">
		<cfreturn this.BB_LS_Claimed_Rebate_Expected />
	</cffunction>

	<!---  D32585 Approval e-mails sending to all TL's START--->
	<cffunction name="setCRAConsiderAnalyst" access="public" output="false">
		<cfargument name="CRAConsiderAnalyst" required="true" type="boolean" />
		<cfset this.CRAConsiderAnalyst = arguments.CRAConsiderAnalyst />
	</cffunction>

	<cffunction name="getCRAConsiderAnalyst" access="public" output="false" returntype="boolean">
		<cfreturn this.CRAConsiderAnalyst />
	</cffunction>
	<!---  D32585 Approval e-mails sending to all TL's END--->

	<!--- D33041: Add 'base sales price' to the billback rate pop up window (CF) --->
	<cffunction name="setBillback_Display_Base_Sales_in_Rate_Dev" access="public" output="false">
		<cfargument name="Billback_Display_Base_Sales_in_Rate_Dev" type="boolean" required="true" default="0" />
		<cfset this.Billback_Display_Base_Sales_in_Rate_Dev = arguments.Billback_Display_Base_Sales_in_Rate_Dev />
	</cffunction>

	<cffunction name="getBillback_Display_Base_Sales_in_Rate_Dev" access="public" output="false" returntype="boolean">
		<cfreturn this.Billback_Display_Base_Sales_in_Rate_Dev />
	</cffunction>

	<!---  D29947 Update billback upload for SO/DC START--->
	<cffunction name="setBillback_Upload_Business_Segment" access="public" output="false">
		<cfargument name="Billback_Upload_Business_Segment" type="boolean" required="true" default="0" />
		<cfset this.Billback_Upload_Business_Segment = arguments.Billback_Upload_Business_Segment />
	</cffunction>

	<cffunction name="getBillback_Upload_Business_Segment" access="public" output="false" returntype="boolean">
		<cfreturn this.Billback_Upload_Business_Segment />
	</cffunction>
	<!---  D29947 Update billback upload for SO/DC END--->

	<!--- START: D33957  Modify standard billback upload to one file --->
	<cffunction name="setBillbackFileUploadType" access="public" output="false">
		<cfargument name="BillbackFileUploadType" type="numeric" required="true" />
		<cfset this.BillbackFileUploadType = arguments.BillbackFileUploadType />
	</cffunction>

	<cffunction name="getBillbackFileUploadType" access="public" output="false" returntype="numeric">
		<cfreturn this.BillbackFileUploadType />
	</cffunction>
	<!--- END: D33957  Modify standard billback upload to one file --->

	<!--- 34665 --->
	<cffunction name="setBB_Count_Indicator" access="public" output="false">
		<cfargument name="BB_Count_Indicator" type="string" required="true"/>
		<cfset this.BB_Count_Indicator = arguments.BB_Count_Indicator />
	</cffunction>

	<cffunction name="getBB_Count_Indicator" access="public" output="false" returntype="string">
		<cfreturn this.BB_Count_Indicator />
	</cffunction>

	<cffunction name="setTemplateMultipleProductAttrGroups" access="public" output="false">
		<cfargument name="Template_Multiple_Product_Attr_Groups" type="boolean" required="true"/>
		<cfset this.Template_Multiple_Product_Attr_Groups = arguments.Template_Multiple_Product_Attr_Groups />
	</cffunction>

	<cffunction name="getTemplateMultipleProductAttrGroups" access="public" output="false" returntype="boolean">
		<cfreturn this.Template_Multiple_Product_Attr_Groups />
	</cffunction>

	<!--- D36542 prof model -- new internal application setting  --->
	<cffunction name="setProfitabilityModel" access="public" output="false">
		<cfargument name="Profitability_Model" type="boolean" required="true"/>
		<cfset this.Profitability_Model = arguments.Profitability_Model />
	</cffunction>

	<cffunction name="getProfitabilityModel" access="public" output="false" returntype="boolean">
		<cfreturn this.Profitability_Model />
	</cffunction>
	<!--- D36542 prof model -- new internal application setting  --->

	<!--- 36812 app setting called Mass Copy --->
	<cffunction name="setMassCopy" access="public" output="false">
		<cfargument name="MassCopy" type="numeric" required="true" />
		<cfset this.Mass_Copy = arguments.MassCopy />
	</cffunction>

	<cffunction name="getMassCopy" access="public" output="false" returntype="numeric">
		<cfreturn this.Mass_Copy />
	</cffunction>

	<!--- 37007 Auto Renew sending wrong program email attachments --->
	<cffunction name="setAutoRenewScheduled" access="public" output="false">
		<cfargument name="autoRenewScheduled" type="numeric" required="true" />
		<cfset this.autoRenewScheduled = arguments.autoRenewScheduled />
	</cffunction>

	<cffunction name="getAutoRenewScheduled" access="public" output="false" returntype="numeric">
		<cfreturn this.autoRenewScheduled />
	</cffunction>

	<!---  D37022 BB Auto Approve Logic - CF work START  --->
	<cffunction name="setBBAutoApproveLogic" access="public" output="false">
		<cfargument name="BB_Auto_Approve_Logic" type="numeric" required="true" />
		<cfset this.BB_Auto_Approve_Logic = arguments.BB_Auto_Approve_Logic />
	</cffunction>

	<cffunction name="getBBAutoApproveLogic" access="public" output="false" returntype="numeric">
		<cfreturn this.BB_Auto_Approve_Logic />
	</cffunction>
	<!---  D37022 BB Auto Approve Logic - CF work END  --->

	<!-- 36746: Billback Deviation & Summary - Add Operator to the display --->
	<cffunction name="setViewOperatorinBillbackDeviation" access="public" output="false">
		<cfargument name="ViewOperatorinBillbackDeviation" type="numeric" required="true" />
		<cfset this.View_Operator_in_Billback_Deviation = arguments.ViewOperatorinBillbackDeviation />
	</cffunction>

	<cffunction name="getViewOperatorinBillbackDeviation" access="public" output="false" returntype="numeric">
		<cfreturn this.View_Operator_in_Billback_Deviation />
	</cffunction>

	<cffunction name="setBBOverlapDeviationBasedOnOperator" access="public" output="false">
		<cfargument name="BBOverlapDeviationBasedOnOperator" type="numeric" required="true" />
		<cfset this.BB_Overlap_Deviation_Based_On_Operator = arguments.BBOverlapDeviationBasedOnOperator />
	</cffunction>

	<cffunction name="getBBOverlapDeviationBasedOnOperator" access="public" output="false" returntype="numeric">
		<cfreturn this.BB_Overlap_Deviation_Based_On_Operator />
	</cffunction>

	<cffunction name="setBBDefaultProgramRetryProcess" access="public" output="false">
		<cfargument name="BBDefaultProgramRetryProcess" type="numeric" required="true" />
		<cfset this.BB_Default_Program_Retry_Process = arguments.BBDefaultProgramRetryProcess />
	</cffunction>

	<cffunction name="getBBDefaultProgramRetryProcess" access="public" output="false" returntype="numeric">
		<cfreturn this.BB_Default_Program_Retry_Process />
	</cffunction>

	<cffunction name="setBBDefaultProgramRetryAlsoCallDeviation" access="public" output="false">
		<cfargument name="BBDefaultProgramRetryAlsoCallDeviation" type="numeric" required="true" />
		<cfset this.BB_Default_Program_Retry_Also_Call_Deviation = arguments.BBDefaultProgramRetryAlsoCallDeviation />
	</cffunction>

	<cffunction name="getBBDefaultProgramRetryAlsoCallDeviation" access="public" output="false" returntype="numeric">
		<cfreturn this.BB_Default_Program_Retry_Also_Call_Deviation />
	</cffunction>

	<!--- Allow Negative Rebate Rates --->
	<cffunction name="setProgram_Allow_Negative_Rebate_Rates" access="public" output="false">
		<cfargument name="Program_Allow_Negative_Rebate_Rates" type="numeric" required="true" default="" />
		<cfset this.Program_Allow_Negative_Rebate_Rates = arguments.Program_Allow_Negative_Rebate_Rates />
	</cffunction>

	<cffunction name="getProgram_Allow_Negative_Rebate_Rates" access="public" output="false">
		<cfreturn trim(this.Program_Allow_Negative_Rebate_Rates) />
	</cffunction>

	<cffunction name="setAllowableOverlapPeriod" access="public" output="false">
		<cfargument name="AllowableOverlapPeriod" type="numeric" required="true" default="" />
		<cfset this.AllowableOverlapPeriod = arguments.AllowableOverlapPeriod />
	</cffunction>

	<!---D40749 :: Allowable Overlap Period setting --->
	<cffunction name="getAllowableOverlapPeriod" access="public" output="false" returntype="numeric">
		<cfreturn trim(this.AllowableOverlapPeriod) />
	</cffunction>

	<cffunction name="setBB_Inserts_Credit_To_Invoices_GT" access="public" output="false">
		<cfargument name="BB_Inserts_Credit_To_Invoices_GT" type="string" required="true" default="" />
		<cfset this.BB_Inserts_Credit_To_Invoices_GT = arguments.BB_Inserts_Credit_To_Invoices_GT />
	</cffunction>

	<cffunction name="getBB_Inserts_Credit_To_Invoices_GT" access="public" returntype="string" output="false">
		<cfreturn trim(this.BB_Inserts_Credit_To_Invoices_GT) />
	</cffunction>

	<!--- D38043  :: Program revision dates - View Program --->
	<cffunction name="setProgram_search_dates" access="public" output="false">
		<cfargument name="Program_search_dates" type="boolean" required="true" default="" />
		<cfset this.Program_search_dates = arguments.Program_search_dates />
	</cffunction>

	<cffunction name="getProgram_search_dates" access="public" output="false" returntype="boolean">
		<cfreturn this.Program_search_dates />
	</cffunction>

	<!--- D38043  :: Program revision dates - View Program --->
	<cffunction name="setUNIPRO_450" access="public" output="false">
		<cfargument name="UNIPRO_450" type="numeric" required="true" default="" />
		<cfset this.UNIPRO_450 = arguments.UNIPRO_450 />
	</cffunction>

	<cffunction name="getUNIPRO_450" access="public" output="false" returntype="numeric">
		<cfreturn this.UNIPRO_450 />
	</cffunction>

	<cffunction name="setDeviationGridAllowManualValuesGTClaimed" access="public" output="false">
		<cfargument name="DeviationGridAllowManualValuesGTClaimed" type="numeric" required="true" />
		<cfset this.Deviation_Grid_Allow_Manual_Values_GT_Claimed = arguments.DeviationGridAllowManualValuesGTClaimed />
	</cffunction>

	<cffunction name="getDeviationGridAllowManualValuesGTClaimed" access="public" output="false" returntype="numeric">
		<cfreturn this.Deviation_Grid_Allow_Manual_Values_GT_Claimed />
	</cffunction>

	<cffunction name="setBBPayeeBrokerShipToReq" access="public" output="false">
		<cfargument name="BBPayeeBrokerShipToReq" type="numeric" required="true" default="" />
		<cfset this.BB_Payee_Broker_Ship_To_Req = arguments.BBPayeeBrokerShipToReq />
	</cffunction>

	<cffunction name="getBBPayeeBrokerShipToReq" access="public" output="false" returntype="numeric">
		<cfreturn this.BB_Payee_Broker_Ship_To_Req />
	</cffunction>

	<cffunction name="setEditableClaimedDollarsQuantity" access="public" output="false">
		<cfargument name="EditableClaimedDollarsQuantity" type="numeric" required="true" default="" />
		<cfset this.Editable_Claimed_Dollars_Quantity = arguments.EditableClaimedDollarsQuantity />
	</cffunction>

	<cffunction name="getEditableClaimedDollarsQuantity" access="public" output="false" returntype="numeric">
		<cfreturn this.Editable_Claimed_Dollars_Quantity />
	</cffunction>

	<cffunction name="setDDReopenParent" access="public" output="false">
		<cfargument name="DDReopenParent" type="numeric" required="true" />
		<cfset this.DDReopenParent = arguments.DDReopenParent />
	</cffunction>

	<cffunction name="getDDReopenParent" access="public" output="false" returntype="numeric">
		<cfreturn this.DDReopenParent />
	</cffunction>

	<cffunction name="setOperatorQBrandLegacy" access="public" output="false">
		<cfargument name="Operator_Q_Brand_Legacy" type="boolean" required="true" />
		<cfset this.Operator_Q_Brand_Legacy = arguments.Operator_Q_Brand_Legacy />
	</cffunction>

	<cffunction name="getOperatorQBrandLegacy" access="public" output="false" returntype="boolean">
		<cfreturn this.Operator_Q_Brand_Legacy />
	</cffunction>

	<!--- D35165 :: LW ENHANCEMENT REQUEST:  Auto Close programs with no claims for 5 months START--->
	<cffunction name="setCancelPgmNoBBMonths" access="public" output="false">
		<cfargument name="CancelPgmNoBBMonths" type="numeric" required="true"  default="" />
		<cfset this.CancelPgmNoBBMonths = arguments.CancelPgmNoBBMonths/>
	</cffunction>

	<cffunction name="getCancelPgmNoBBMonths" access="public" output="false" returntype="numeric">
		<cfreturn trim(this.CancelPgmNoBBMonths) />
	</cffunction>

	<!--- D35165 :: LW ENHANCEMENT REQUEST:  Auto Close programs with no claims for 5 months END--->
	<cffunction name="setShowBrandOnViewProgram" access="public" output="false">
		<cfargument name="ShowBrandOnViewProgram" type="numeric" required="true"  default="" />
		<cfset this.ShowBrandOnViewProgram = arguments.ShowBrandOnViewProgram/>
	</cffunction>

	<cffunction name="getShowBrandOnViewProgram" access="public" output="false" returntype="numeric">
		<cfreturn this.ShowBrandOnViewProgram />
	</cffunction>

	<!---D42028	Cost fields in Huhtamaki stage: re-label and remove ones not using --->
	<cffunction name="setMarginCostColHeader6" access="public" output="false">
		<cfargument name="marginCostColHeader6" type="string" required="Yes">
		<cfset this.marginCostColHeader6 = arguments.marginCostColHeader6 />
	</cffunction>

	<cffunction name="getMarginCostColHeader6" access="public" output="false" return="string">
		<cfreturn this.marginCostColHeader6 />
	</cffunction>

	<cffunction name="setMarginCostColHeader7" access="public" output="false">
		<cfargument name="marginCostColHeader7" type="string" required="Yes">
		<cfset this.marginCostColHeader7 = arguments.marginCostColHeader7 />
	</cffunction>

	<cffunction name="getMarginCostColHeader7" access="public" output="false" return="string">
		<cfreturn this.marginCostColHeader7 />
	</cffunction>

	<cffunction name="setMarginCostColHeader8" access="public" output="false">
		<cfargument name="marginCostColHeader8" type="string" required="Yes">
		<cfset this.marginCostColHeader8 = arguments.marginCostColHeader8 />
	</cffunction>

	<cffunction name="getMarginCostColHeader8" access="public" output="false" return="string">
		<cfreturn this.marginCostColHeader8 />
	</cffunction>

	<!---
	<cffunction name="getMarginCostColStatus" access="public" output="false" return="boolean">
		<cfargument name="marginCostColHeader" type="string" required="Yes">
		<cfquery name="get_status" datasource="#application.datasource#" >
			SELECT #arguments.marginCostColHeader#
			FROM _Application_settings
		</cfquery>
		<cfset get_status =  evaluate('get_status.#arguments.marginCostColHeader#')>
		<cfreturn get_status />
	</cffunction>
	--->

	<cffunction name="setMarginCostColHeader1_delete" access="public" output="false">
		<cfargument name="marginCostColHeader1_delete" type="string" required="Yes">
		<cfset this.marginCostColHeader1_delete = arguments.marginCostColHeader1_delete />
	</cffunction>

	<cffunction name="getMarginCostColHeader1_delete" access="public" output="false" return="string">
		<cfreturn this.marginCostColHeader1_delete />
	</cffunction>

	<cffunction name="setMarginCostColHeader2_delete" access="public" output="false">
		<cfargument name="marginCostColHeader2_delete" type="string" required="Yes">
		<cfset this.marginCostColHeader2_delete = arguments.marginCostColHeader2_delete />
	</cffunction>

	<cffunction name="getMarginCostColHeader2_delete" access="public" output="false" return="string">
		<cfreturn this.marginCostColHeader2_delete />
	</cffunction>

	<cffunction name="setMarginCostColHeader3_delete" access="public" output="false">
		<cfargument name="marginCostColHeader3_delete" type="string" required="Yes">
		<cfset this.marginCostColHeader3_delete = arguments.marginCostColHeader3_delete />
	</cffunction>

	<cffunction name="getMarginCostColHeader3_delete" access="public" output="false" return="string">
		<cfreturn this.marginCostColHeader3_delete />
	</cffunction>

	<cffunction name="setMarginCostColHeader4_delete" access="public" output="false">
		<cfargument name="marginCostColHeader4_delete" type="string" required="Yes">
		<cfset this.marginCostColHeader4_delete = arguments.marginCostColHeader4_delete />
	</cffunction>

	<cffunction name="getMarginCostColHeader4_delete" access="public" output="false" return="string">
		<cfreturn this.marginCostColHeader4_delete />
	</cffunction>

	<cffunction name="setMarginCostColHeader5_delete" access="public" output="false">
		<cfargument name="marginCostColHeader5_delete" type="string" required="Yes">
		<cfset this.marginCostColHeader5_delete = arguments.marginCostColHeader5_delete />
	</cffunction>

	<cffunction name="getMarginCostColHeader5_delete" access="public" output="false" return="string">
		<cfreturn this.marginCostColHeader5_delete />
	</cffunction>

	<cffunction name="setMarginCostColHeader6_delete" access="public" output="false">
		<cfargument name="marginCostColHeader6_delete" type="string" required="Yes">
		<cfset this.marginCostColHeader6_delete = arguments.marginCostColHeader6_delete />
	</cffunction>

	<cffunction name="getMarginCostColHeader6_delete" access="public" output="false" return="string">
		<cfreturn this.marginCostColHeader6_delete />
	</cffunction>

	<cffunction name="setMarginCostColHeader7_delete" access="public" output="false">
		<cfargument name="marginCostColHeader7_delete" type="string" required="Yes">
		<cfset this.marginCostColHeader7_delete = arguments.marginCostColHeader7_delete />
	</cffunction>

	<cffunction name="getMarginCostColHeader7_delete" access="public" output="false" return="string">
		<cfreturn this.marginCostColHeader7_delete />
	</cffunction>

	<cffunction name="setMarginCostColHeader8_delete" access="public" output="false">
		<cfargument name="marginCostColHeader8_delete" type="string" required="Yes">
		<cfset this.marginCostColHeader8_delete = arguments.marginCostColHeader8_delete />
	</cffunction>

	<cffunction name="getMarginCostColHeader8_delete" access="public" output="false" return="string">
		<cfreturn this.marginCostColHeader8_delete />
	</cffunction>

	<!--- D42028	Cost fields in Huhtamaki stage: re-label and remove ones not using --->
	<cffunction name="setEnableGroupMembershipDates" access="public" output="false">
		<cfargument name="Enable_Group_Membership_Dates" type="numeric" required="true" />
		<cfset this.Enable_Group_Membership_Dates = arguments.Enable_Group_Membership_Dates />
	</cffunction>

	<cffunction name="getEnableGroupMembershipDates" access="public" output="false" returntype="numeric">
		<cfreturn this.Enable_Group_Membership_Dates />
	</cffunction>

	<!--- D42284 :: Rebill vs closed deduction reopened START--->
	<cffunction name="getDD_Reopen_Interface" access="public" returntype="boolean" output="false">
		<cfreturn this.DD_Reopen_Interface />
	</cffunction>

	<cffunction name="setDD_Reopen_Interface" access="public" output="false">
		<cfargument name="DD_Reopen_Interface" type="boolean" required="true" />
		<cfset this.DD_Reopen_Interface = arguments.DD_Reopen_Interface />
	</cffunction>

	<!--- D42284 :: Rebill vs closed deduction reopened END--->
	<cffunction name="setSequentialNetSalesOperatingMargin" access="public" output="false">
		<cfargument name="Sequential_Net_Sales_Operating_Margin" type="boolean" required="true" default="0" />
		<cfset this.Sequential_Net_Sales_Operating_Margin = arguments.Sequential_Net_Sales_Operating_Margin />
	</cffunction>

	<cffunction name="getSequentialNetSalesOperatingMargin" access="public" output="false" returntype="boolean">
		<cfreturn this.Sequential_Net_Sales_Operating_Margin />
	</cffunction>

	<!--- D42846 :: Deduction tool upgrades START--->
	<cffunction name="setDeductionQuickUpdate" access="public" output="false">
		<cfargument name="DeductionQuickUpdate" type="numeric" required="true"  default="" />
		<cfset this.DeductionQuickUpdate = arguments.DeductionQuickUpdate/>
	</cffunction>

	<cffunction name="getDeductionQuickUpdate" access="public" output="false" returntype="numeric">
		<cfreturn trim(this.DeductionQuickUpdate) />
	</cffunction>
	<!--- D42846 :: Deduction tool upgrades END--->

	<!--- D42590 :: auto approve products on revision START--->
	<cffunction name="setAutoApproveProductsOnRevision" access="public" output="false">
		<cfargument name="AutoApproveProductsOnRevision" type="numeric" required="true"  default="" />
		<cfset this.AutoApproveProductsOnRevision = arguments.AutoApproveProductsOnRevision />
	</cffunction>

	<cffunction name="getAutoApproveProductsOnRevision" access="public" output="false" returntype="numeric">
		<cfreturn trim(this.AutoApproveProductsOnRevision) />
	</cffunction>
	<!--- D42590:: auto approve products on revision END--->

	<!--- START: 43155: Billback Program Change --->
	<cffunction name="setBBPowerpunch" access="public" output="false">
		<cfargument name="BB_Powerpunch" type="numeric" required="true" />
		<cfset this.BB_Powerpunch = arguments.BB_Powerpunch />
	</cffunction>

	<cffunction name="getBBPowerpunch" access="public" output="false" returntype="numeric">
		<cfreturn this.BB_Powerpunch />
	</cffunction>
	<!--- END: 43155: Billback Program Change --->

	<cffunction name="setShowHoldingPen" access="public" output="false">
		<cfargument name="Show_Holding_Pen" type="numeric" required="true" />
		<cfset this.Show_Holding_Pen = arguments.Show_Holding_Pen />
	</cffunction>

	<cffunction name="getShowHoldingPen" access="public" output="false" returntype="numeric">
		<cfreturn this.Show_Holding_Pen />
	</cffunction>

	<!--- 43559 BB Pymt Req Hold/Release START--->
	<cffunction name="setBBPaymentRequestHoldRelease" access="public" output="false">
		<cfargument name="BBPaymentRequestHoldRelease" type="numeric" required="true"  default="" />
		<cfset this.BBPaymentRequestHoldRelease = arguments.BBPaymentRequestHoldRelease />
	</cffunction>

	<cffunction name="getBBPaymentRequestHoldRelease" access="public" output="false" returntype="numeric">
		<cfreturn trim(this.BBPaymentRequestHoldRelease) />
	</cffunction>
	<!--- 43559 BB Pymt Req Hold/Release END--->

	<!--- 43559: BB Pymt Amt Within Profile’s Total Approval Amt = Approved Status START--->
	<cffunction name="setApproveBBBasedOnProfileTotalApprovalAmount" access="public" output="false">
		<cfargument name="ApproveBBBasedOnProfileTotalApprovalAmount" type="numeric" required="true"  default="" />
		<cfset this.ApproveBBBasedOnProfileTotalApprovalAmount = arguments.ApproveBBBasedOnProfileTotalApprovalAmount />
	</cffunction>

	<cffunction name="getApproveBBBasedOnProfileTotalApprovalAmount" access="public" output="false" returntype="numeric">
		<cfreturn trim(this.ApproveBBBasedOnProfileTotalApprovalAmount) />
	</cffunction>
	<!--- 43559: BB Pymt Amt Within Profile’s Total Approval Amt = Approved Status END--->

	<!---D43661 :: Program RFA status - disable pages and require user to Reset to make any changes START--->
	<!--- Set disable_pages_in_rfa --->
	<cffunction name="setdisablepagesinrfa" access="public" output="false">
		<cfargument name="disable_pages_in_rfa" type="boolean" required="true" default="0" />
		<cfset this.disable_pages_in_rfa = arguments.disable_pages_in_rfa />
	</cffunction>

	<!--- Get disable_pages_in_rfa --->
	<cffunction name="getdisablepagesinrfa" access="public" output="false" returntype="boolean">
		<cfreturn this.disable_pages_in_rfa />
	</cffunction>
	<!---D43661 :: Program RFA status - disable pages and require user to Reset to make any changes END--->

	<!--- D41881 :: Auto adjust of DST Weights START--->
	<cffunction name="setAutoWeightDistributorsProgramRevision" access="public" output="false">
		<cfargument name="Auto_Weight_Distributors_Program_Revision" type="boolean" required="true"/>
		<cfset this.Auto_Weight_Distributors_Program_Revision = arguments.Auto_Weight_Distributors_Program_Revision />
	</cffunction>

	<cffunction name="getAutoWeightDistributorsProgramRevision" access="public" output="false" returntype="string">
		<cfreturn this.Auto_Weight_Distributors_Program_Revision />
	</cffunction>
	<!--- D41881 :: Auto adjust of DST Weights END--->

	<!--- START: D44724 Billback Approval Automation --->
	<cffunction name="setDateTolerance" access="public" output="false">
		<cfargument name="DateTolerance" type="numeric" required="true"  default="" />
		<cfset this.DateTolerance = arguments.DateTolerance/>
	</cffunction>

	<cffunction name="getDateTolerance" access="public" output="false" returntype="numeric">
		<cfreturn trim(this.DateTolerance) />
	</cffunction>
	<!--- END: D44724 Billback Approval Automation--->

	<cffunction name="setRFA_Notification_1_Case" access="public" output="false">
		<cfargument name="RFA_Notification_1_Case" type="boolean" required="true"/>
		<cfset this.RFA_Notification_1_Case = arguments.RFA_Notification_1_Case />
	</cffunction>

	<cffunction name="getRFA_Notification_1_Case" access="public" output="false" returntype="string">
		<cfreturn this.RFA_Notification_1_Case />
	</cffunction>

	<!--- 45235 :: Bid flags not flipping correctly--->
	<cffunction name="setDontSetBidProductStatusRevise" access="public" output="false">
		<cfargument name="Dont_Set_Bid_Product_Status_on_Revise" type="boolean" required="true"/>
		<cfset this.Dont_Set_Bid_Product_Status_on_Revise = arguments.Dont_Set_Bid_Product_Status_on_Revise />
	</cffunction>

	<cffunction name="getDontSetBidProductStatusRevise" access="public" output="false" returntype="string">
		<cfreturn this.Dont_Set_Bid_Product_Status_on_Revise />
	</cffunction>

	<!--- D45263 :: Create table to store max rates by template/profile START--->
	<cffunction name="setCustomMaxRate" access="public" output="false">
		<cfargument name="Custom_Max_Rate" type="boolean" required="true"/>
		<cfset this.Custom_Max_Rate = arguments.Custom_Max_Rate />
	</cffunction>

	<cffunction name="getCustomMaxRate" access="public" output="false" returntype="string">
		<cfreturn this.Custom_Max_Rate />
	</cffunction>
	<!--- D45263 :: Create table to store max rates by template/profile END--->

	<cffunction name="setMassChangePreactive" access="public" output="false">
		<cfargument name="Mass_Change_Preactive" type="boolean" required="true"/>
		<cfset this.Mass_Change_Preactive = arguments.Mass_Change_Preactive />
	</cffunction>

	<cffunction name="getMassChangePreactive" access="public" output="false" returntype="string">
		<cfreturn this.Mass_Change_Preactive />
	</cffunction>

	<!---D45778 :Auto Reconcile BB's closed to deduction in 1500 --->
	<cffunction name="setAuto_Reconcile_Match_Central_BB" access="public" output="false">
		<cfargument name="Auto_Reconcile_Match_Central_BB" type="boolean" required="true"/>
		<cfset this.Auto_Reconcile_Match_Central_BB = arguments.Auto_Reconcile_Match_Central_BB />
	</cffunction>

	<cffunction name="getAuto_Reconcile_Match_Central_BB" access="public" output="false" returntype="string">
		<cfreturn this.Auto_Reconcile_Match_Central_BB />
	</cffunction>

	<!--- 45864 :: JRS - Expected rate calculation [LTL, Redi] Bypass--->
	<cffunction name="setByPassExpectedRateCalculationEnhancement" access="public" output="false">
		<cfargument name="By_Pass_Expected_Rate_Calculation_Enhancement" type="boolean" required="true"/>
		<cfset this.By_Pass_Expected_Rate_Calculation_Enhancement = arguments.By_Pass_Expected_Rate_Calculation_Enhancement />
	</cffunction>

	<cffunction name="getByPassExpectedRateCalculationEnhancement" access="public" output="false" returntype="string">
		<cfreturn this.By_Pass_Expected_Rate_Calculation_Enhancement />
	</cffunction>

	<!--- 45076 :: Establish payee from the planning groups --->
	<cffunction name="setPayeeFromPlanningGroups" access="public" output="false">
		<cfargument name="Payee_From_Planning_Groups" type="boolean" required="true"/>
		<cfset  this.Payee_From_Planning_Groups = arguments.Payee_From_Planning_Groups />
	</cffunction>

	<cffunction name="getPayeeFromPlanningGroups" access="public" output="false" returntype="numeric">
		<cfreturn  this.Payee_From_Planning_Groups />
	</cffunction>

	<!--- D46525: Make BB Reference Field Required/Anand Rao/25-Nov-2014 --->
	<cffunction name="setBBReferenceNumRequired" access="public" output="false">
		<cfargument name="BB_ReferenceNum_Required" type="boolean" required="true"/>
		<cfset  this.BB_ReferenceNum_Required = arguments.BB_ReferenceNum_Required />
	</cffunction>

	<cffunction name="getBBReferenceNumRequired" access="public" output="false" returntype="numeric">
		<cfreturn  this.BB_ReferenceNum_Required />
	</cffunction>

	<!--- D48049: Count / Dont Count Volume based on Program Component --->
	<cffunction name="setAllow_BB_Dont_Count_From_Program" access="public" output="false">
		<cfargument name="Allow_BB_Dont_Count_From_Program" type="numeric" required="true"/>
		<cfset  this.Allow_BB_Dont_Count_From_Program = arguments.Allow_BB_Dont_Count_From_Program />
	</cffunction>

	<cffunction name="getAllow_BB_Dont_Count_From_Program" access="public" output="false" returntype="numeric">
		<cfreturn  this.Allow_BB_Dont_Count_From_Program />
	</cffunction>

	<!--- 49540: App Setting - Use_Invoice_Market --->
	<cffunction name="setUseInvoiceMarket" access="public" output="false">
		<cfargument name="Use_Invoice_Market" type="boolean" required="true"/>
		<cfset  this.Use_Invoice_Market = arguments.Use_Invoice_Market />
	</cffunction>

	<cffunction name="getUseInvoiceMarket" access="public" output="false" returntype="numeric">
		<cfreturn  this.Use_Invoice_Market />
	</cffunction>

	<!---  D49837:CAG PROD - BB LH link EDI Download --->
	<cffunction name="setEnableEDIUploadRawDataViewer" access="public" output="false">
		<cfargument name="Enable_EDI_Upload_Raw_Data_Viewer" type="boolean" required="true"/>
		<cfset  this.Enable_EDI_Upload_Raw_Data_Viewer = arguments.Enable_EDI_Upload_Raw_Data_Viewer />
	</cffunction>

	<cffunction name="getEnableEDIUploadRawDataViewer" access="public" output="false" returntype="numeric">
		<cfreturn  this.Enable_EDI_Upload_Raw_Data_Viewer />
	</cffunction>

	<!--- 2015 jan 23 - chrisn: introduced new _SETTINGS table with multiple rows feature --->
	<cffunction name="get_Setting" access="public" output="false" hint="Return interal setting value.">
		<cfargument name="setting_input_name" required="true" type="string" hint="this is the setting input name in the database and also in the form">
		<!------------------------------------------------------------------------------------------------
		Call get_Setting() in InternalSettings.cfc
		-------------------------------------------------------------------------------------------------->
		<cfset local.InternalSettings = createObject("component", "components.settings.InternalSettings") />
		<cfreturn local.InternalSettings.get_Setting(arguments.setting_input_name) />
	</cffunction>

	<!--- D48816 :: Single Sign On field needed to hold Username START --->
	<cffunction name="setSingleSignOnOverrideUserId" access="public" output="false">
		<cfargument name="SingleSignOnOverrideUserId" type="boolean" required="true" />
		<cfset this.SingleSignOnOverrideUserId = arguments.SingleSignOnOverrideUserId />
	</cffunction>

	<cffunction name="getSingleSignOnOverrideUserId" access="public" returntype="numeric" output="false">
		<cfreturn this.SingleSignOnOverrideUserId />
	</cffunction>
	<!--- D48816 :: Single Sign On field needed to hold Username END --->

	<!--- D49844 :: Create new app setting called �?Trade Eligibility Report�? with ON/OFF options START --->
	<cffunction name="setTradeEligibilityReport" access="public" output="false">
		<cfargument name="TradeEligibilityReport" type="boolean" required="true" />
		<cfset this.TradeEligibilityReport = arguments.TradeEligibilityReport />
	</cffunction>

	<cffunction name="getTradeEligibilityReport" access="public" returntype="numeric" output="false">
		<cfreturn this.TradeEligibilityReport />
	</cffunction>
	<!--- D49844 :: Create new app setting called �?Trade Eligibility Report�? with ON/OFF options END --->

	<!--- START: D49855 :: Win/Loss Bid - Create new app setting called “Update Program won/loss based on Off invoice Record�? --->
	<cffunction name="setPrgWonLostOnOffInvoiceRecord" access="public" output="false">
		<cfargument name="PrgWonLostOnOffInvoiceRecord" type="boolean" required="true" />
		<cfset this.PrgWonLostOnOffInvoiceRecord  = arguments.PrgWonLostOnOffInvoiceRecord />
	</cffunction>

	<cffunction name="getPrgWonLostOnOffInvoiceRecord" access="public" returntype="numeric" output="false">
		<cfreturn this.PrgWonLostOnOffInvoiceRecord  />
	</cffunction>

	<!--- END: D49855 :: Win/Loss Bid - Create new app setting called “Update Program won/loss based on Off invoice Record�? --->
	<!---D50074 :: Viewing and Editing prior program versions START--->
	<cffunction name="setModifyExpiredPrograms" access="public" output="false">
		<cfargument name="ModifyExpiredPrograms" type="boolean" required="true" />
		<cfset this.ModifyExpiredPrograms  = arguments.ModifyExpiredPrograms />
	</cffunction>

	<cffunction name="getModifyExpiredPrograms" access="public" returntype="numeric" output="false">
		<cfreturn this.ModifyExpiredPrograms  />
	</cffunction>
	<!---D50074 :: Viewing and Editing prior program versions END--->

	<!---50324 :: Add Dollars and volume for program search START--->
	<cffunction name="setProgramSearchDollarsAndVolume" access="public" output="false">
		<cfargument name="ProgramSearchDollarsAndVolume" type="boolean" required="true" />
		<cfset this.Program_Search_Dollars_And_Volume  = arguments.ProgramSearchDollarsAndVolume />
	</cffunction>

	<cffunction name="getProgramSearchDollarsAndVolume" access="public" returntype="numeric" output="false">
		<cfreturn this.Program_Search_Dollars_And_Volume  />
	</cffunction>
	<!---50324 :: Add Dollars and volume for program search END--->

	<!---50324 ::  "Payment history dollars" include "Off Invoice" Dollars START--->
	<cffunction name="setPymtHistoryDollarsIncludeOffInvoiceDollars" access="public" output="false">
		<cfargument name="PymtHistoryDollarsIncludeOffInvoiceDollars" type="boolean" required="true" />
		<cfset this.Pymt_history_Dollars_Include_OffInvoice_Dollars  = arguments.PymtHistoryDollarsIncludeOffInvoiceDollars />
	</cffunction>

	<cffunction name="getPymtHistoryDollarsIncludeOffInvoiceDollars" access="public" returntype="numeric" output="false">
		<cfreturn this.Pymt_history_Dollars_Include_OffInvoice_Dollars  />
	</cffunction>
	<!---50324 ::  "Payment history dollars" include "Off Invoice" Dollars. END--->

	<!--- 51607 New Duplicate BB Logic - Appsetting Changes START--->
	<cffunction name="setCheckAllBBDuplicate" access="public" output="false">
		<cfargument name="CheckAllBBDuplicate" type="boolean" required="true" />
		<cfset this.Check_All_BB_Duplicate  = arguments.CheckAllBBDuplicate />
	</cffunction>

	<cffunction name="getCheckAllBBDuplicate" access="public" returntype="numeric" output="false">
		<cfreturn this.Check_All_BB_Duplicate  />
	</cffunction>
	<!--- 51607 New Duplicate BB Logic - Appsetting Changes  END--->

	<!--- D52449 :: Create new app settings to control Orphan Pop up Alert START --->
	<cffunction name="setDisplayOrphanAlertProgramRevise" access="public" output="false">
		<cfargument name="DisplayOrphanAlertProgramRevise" type="boolean" required="true" />
		<cfset this.DisplayOrphanAlertProgramRevise = arguments.DisplayOrphanAlertProgramRevise />
	</cffunction>

	<cffunction name="getDisplayOrphanAlertProgramRevise" access="public" returntype="numeric" output="false">
		<cfreturn this.DisplayOrphanAlertProgramRevise />
	</cffunction>
	<!--- D52449 :: Create new app settings to control Orphan Pop up Alert END --->

	<!--- D50884 :: Improvements to the Rebate Page inside a Program 8.0 Release... START --->
	<cffunction name="setProgramAlertOnRFARate0" access="public" output="false">
		<cfargument name="ProgramAlertOnRFARate0" type="boolean" required="true" />
		<cfset this.ProgramAlertOnRFARate0 = arguments.ProgramAlertOnRFARate0 />
	</cffunction>

	<cffunction name="getProgramAlertOnRFARate0" access="public" returntype="numeric" output="false">
		<cfreturn this.ProgramAlertOnRFARate0 />
	</cffunction>
	<!--- D50884 :: Improvements to the Rebate Page inside a Program 8.0 Release...  END --->
	<!--- D57447 :: Create and modify vendor recordss START--->
      <cffunction name="setModifyVendorRecords" access="public" output="false">
        <cfargument name="ModifyVendorRecords" type="boolean" required="true" />
        <cfset this.Modify_Vendor_Records  = arguments.ModifyVendorRecords />
      </cffunction>

      <cffunction name="getModifyVendorRecords" access="public" returntype="numeric" output="false">
        <cfreturn this.Modify_Vendor_Records  />
      </cffunction>
	<!--- D57447 :: Create and modify vendor records  END--->

	<!--- D65744 - CC - Move LaborOH cost to a different product cost field START --->

</cfcomponent>
