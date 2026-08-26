<!---
  Name: app_settings_2.cfm
  Copyright (c) 2006 Blacksmith Applications, Inc.
  Description:  Management screen for the application's internal settings.
  Modified By:  Clarence Morse 3/24/2006
				  Anand Rao      5/15/2009  Added "Update programs to use latest template settings"
  Purpose:    Enhancements for welcome letter.
--->

<cfsavecontent variable="head_content">
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<cf_include files="/styles/jQueryUI_18/jquery.multiselect.css, /styles/jQueryUI_18/jquery-ui-1.8.14.custom.css, /styles/css-loader.css">
<style>
.saving { font-weight: bold; color: #00529B; font-size: 1.15em; }
.dropdown { width:180px; display:none; }
#actions { text-align:center; }
input[type=text] { width:88%; }
select { width:90%; }
textarea { width:96%; }
table.s9i td { padding:3px 6px; }
.t7h { background-color2:#FFF5EE}
.t3h { background-color2:#F0F8FF}
.t1h { background-color2:#FFFFF0}
.t2h { background-color2:#FFF0F5}
.t4h { background-color2:#FFF5EE}
.t6h { background-color2:#FFF5EE}
table.t107 tr:hover {background-color:#e6bf9b;}
table.t107 tr:hover td {
	background-color: transparent;
	color: blue;
}
tr.divider { background-color: white !important; }
tr.divider > td { font-weight: bold; font-size:15px; letter-spacing: 1px; text-transform: uppercase; text-shadow: 4px 4px 4px #aaa; color:red; }
#saveLink{
	position:fixed;
	right:5px;
	bottom:10px;
}
div.mark {
  position:fixed;
  bottom:50px;
  right:5px;
  text-align: right;
}
input[name=mark_text]{
  width:75px;
  height: 18px;
	outline: none;
	border-color: #9ecaed;
	box-shadow: 0 0 10px #9ecaed;
	background-color: #FFFE9D;
}
mark {
  background: yellow;
}
mark.current {
  background: orange;
}
input[readonly] {
  border-style: dotted;
  cursor: not-allowed;
  color: #777;
}
</style>
</cfsavecontent>
<!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
<cfhtmlhead text="#application.util.string.compress( head_content )#">

<cfoutput>
<cfsetting showdebugoutput="false" />

<cfset request.custom_rfp_process = application.util.query.get_Setting('Custom_RFP_Process',0)>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset qBBAliasSourceType = genSettingsManager.getBBAliasSourceType() />
<cfset BBClaimSourceXrefIDs = ValueList(qBBAliasSourceType.BB_Claim_Source_Xref_ID,",")>
<cfset LabelComp 			= Createobject("component", "components.settings.labels.labels").init() />
<cfset qGetBSVar2Label		= LabelComp.getGeneralLabels('BS_Var_2') />

<!---get product group types--->
<cfset qGetProductGroupTypes = CreateObject("component","components.products.Group.DataManager").getProductGroupsData() />

<!--- get all Billback status  --->
<cfset qGetBillbackStatus = CreateObject("component","components.reports.claimReportManager").getClaimReportProgramStatus() />

<!--- get Program Lock Types  --->
<cfset qGetProgramLockTypes = CreateObject("component","components.programs.ProgramLockType").getProgramLockType() />
<cfset qGenericTypes = CreateObject("component","components.programs.template.TemplateManager").getGenericType() />

<cfquery name="qProductGroups" datasource="#application.datasource#">
  SELECT  Product_Group_Level.Product_Group_Level_ID
		 ,Product_Group_Level.Group_Level_Desc
		 ,Product_Group_Level.Group_Internal_Label
  FROM    Product_Group_Level
  WHERE   Product_Group_Level.Active = 1
		  AND Product_Group_Level.Is_PG = 0
		  AND Product_Group_Level.Product_Group_Level_ID <> 1
				ORDER BY Product_Group_Level.Group_Level_Desc
</cfquery>

<cfquery name="qDistributorGroups" datasource="#application.datasource#">
	SELECT  Distributor_Group_Level.Distributor_Group_Level_ID
			,Distributor_Group_Level.Group_Level_Desc
			,Distributor_Group_Level.Group_Level_Desc_Internal
			,Distributor_Group_Level.Is_PG
	FROM    Distributor_Group_Level
	WHERE   Distributor_Group_Level.Active = 1
			AND Distributor_Group_Level.Deleted = 0
	ORDER BY Distributor_Group_Level.Group_Level_Desc
</cfquery>

<cfquery name="EachInfo" datasource="#application.datasource#">
  SELECT Unit_Of_Measure_Desc,Abbreviation,Unit_of_Measure_Desc_Singular
  FROM Units_of_Measure
  WHERE Unit_Of_Measure_ID= 5
</cfquery>

<!---if state is true then we know that we have to save--->
<cfif form.state>

<!---
BJF: August 16, 2005
The following variables will now be updated at:
/settings/notifications/index.cfm
send_secondary_email
send_auto_attachments
send_approved_programs_emailadress
cancel_program_email
rfa_email_event
bb_agree_email
send_distributor_broker_email

Variable which turn emails on and off, or which specify which email should be send or to whom, should also be included in the notifications page, not here. (Assuming client administrators should be allowed to update them.)
 --->

  <cfparam name="form.programInterfaceBuffer"   default="0">
  <cfparam name="form.Send_Report_To"       default="0">
  <cfparam name="form.Report_Run_Days"      default="0">
  <cfparam name="form.awaitingactiondays"     default="0">
  <cfparam name="form.DollarGrowth"         default="0">
  <cfparam name="form.UseXMaterial"         default="0">
  <cfparam name="form.UseProductGroup1"       default="0">
  <cfparam name="form.UseProductGroup2"       default="0">
  <cfparam name="form.UseProductGroup3"       default="0">
  <cfparam name="form.UseProductGroup4"       default="0">
  <cfparam name="form.UseProductGroup5"       default="0">
  <cfparam name="form.UseProductHierarchy"    default="0">
  <cfparam name="form.searchProductHierarchyExcludeList"    default="">
  <cfparam name="form.appSettingsOnForAll"    default="0">
  <cfparam name="form.AutoBroker"         default="0">
  <cfparam name="form.RFAAgree"           default="0">
  <cfparam name="form.Customertype"         default="0">
  <cfparam name="form.RestrictProductUOM"     default="0">
  <cfparam name="form.RebateMaxComponents"    default="1">
  <cfparam name="form.AllowNavigate"        default="0">
  <cfparam name="form.LabelNotes"         default="">
  <cfparam name="form.FloorPrice"         default="0">
  <cfparam name="form.LumpMultipleProducts"     default="0">
  <cfparam name="form.programnotesrequired"     default="0">
  <cfparam name="form.Equipment_Placement"    default="0">
  <cfparam name="form.Classcodes_On"        default="0">
  <cfparam name="form.GrowthExpansion1"       default="1">
  <cfparam name="form.fixedcomponents_on"     default="1"> <!--- 19409 DEFAULT TO ON --->
  <cfparam name="form.rolloverprograms_on"    default="0">
  <cfparam name="form.forbidAllowProfilesInTemplates" default="0">
  <cfparam name="form.uploadmargintargets_on"   default="0">
  <cfparam name="form.RestrictAccessOnGroup"    default="0">
  <cfparam name="form.businessconsiderations_on"  default="0">
  <cfparam name="form.custid_on"          default="0">
  <cfparam name="form.singlesign_on"        default="0">
  <cfparam name="form.BB_Fixed_Calc_Types_On"   default="0">
  <cfparam name="form.claimAutoPrint"       default="0">
  <cfparam name="form.billback_statement_type"  default="pdf-v1">
  <cfparam name="form.allowAllDistributors"     default="0">
  <cfparam name="form.maxProfileCount"      default="0">
  <cfparam name="form.distributorMultiPosition" default="0">
  <cfparam name="form.operatorSearchRestrict"   default="0">
  <cfparam name="form.SalesOrgOn"         default="0">
  <cfparam name="form.DistributionChannelOn"    default="0">
  <cfparam name="form.DeleteProgramMessage"   default="">
  <cfparam name="form.DeleteIsCancelAutoRenew"  default="0">
  <cfparam name="form.PaymentCycleAtDiscountType" default="0">
  <cfparam name="form.Settlement_SAP_Business"  default="0">
  <cfparam name="form.Sysco_Report_On"      default="0">
  <cfparam name="form.Allow_Multi_Level_Groups" default="0">
  <cfparam name="form.ProgramAgreeEscalate"   default="0">
  <cfparam name="form.CheckOrderClass"      default="0">
  <cfparam name="form.OrderClassValue"      default="">
  <cfparam name="form.Business_Segment_Label"   default="">
  <cfparam name="form.Integation_Instance_ID"   default="">
  <cfparam name="form.BB_Ref_Num_Max_Length"    default="30">
  <cfparam name="form.BB_2Ref_Num_Max_Length"   default="30">
  <cfparam name="form.LOB_Label"          default="">
  <cfparam name="form.send_to_sap"        default="0">
  <cfparam name="form.templatecodes_on"       default="0">
  <cfparam name="form.BB_Payee_Operator_Ship_To_Req"      default="0">
  <cfparam name="form.Vendor_Selection_Pay_Req"   default="0">
  <cfparam name="form.Billback_Payment_Request_Without_Vendor_Selection"  default="0">
  <cfparam name="form.Skip_Vendor_Selection_On_BB_Approval"  default="0">
  <cfparam name="form.Multiple_BB_Per_Deduction"  default="0">
  <cfparam name="form.Allow_Negative_Billback"  default="0">
  <cfparam name="form.BB_Allow_Off_Invoice_Closing_Method"  default="0">
  <cfparam name="form.Interface_700_To_Client"  default="0">
  <cfparam name="form.DD_Show_reassign"   default="0">
  <cfparam name="form.Auto_Deviation_On"  default="0">
  <cfparam name="form.DD_Show_Classification"   default="0">
  <cfparam name="form.DD_Show_DeductionType"  default="0">    <!---26487--->
  <cfparam name="form.DD_Show_Edit_Customer_Num"  default="0">
  <cfparam name="form.DD_Allow_Non_Trade"  default="0"> <!--- D29481:Non trade deductions --->
  <cfparam name="form.DD_Reopen_Interface"  default="0">  <!---D42284 :: Rebill vs closed deduction reopened --->
  <!--- <cfparam name="form.DD_Show_Write_Off"  default="0"> --->
  <cfparam name="form.DD_Show_Create_Adjustment"  default="0">
  <cfparam name="form.DD_Show_Delete"   default="0">
  <cfparam name="form.DD_Show_ReOpen"   default="0">
  <cfparam name="form.DD_Show_Reject"   default="0">
  <cfparam name="form.DD_Show_Program"  default="0">
  <cfparam name="form.DD_Show_Invoices"   default="0">
  <cfparam name="form.ERP_Deal_ID_PopUp"  default="0">
  <cfparam name="form.BB_Allow_UnKnow_Program_Creation"   default="0">
  <cfparam name="form.BB_Pay_Req_Dup_Check"   default="0">
  <!--- <cfparam name="form.Template_Notes_Availability"  default="0">   ---> <!--- BJF: Removed with label 13333  --->
  <cfparam name="form.Match_BB_DD_Based_On_Same_ReferenceNum"   default="0">
  <cfparam name="form.Restrict_DD_Reason_Code_By_Closing_method"  default="0">
  <cfparam name="form.userNumberRestrict"     default="0">
  <cfparam name="form.USDANOIEnabled"       default="0">
  <cfparam name="form.productSearchGetProductByProgramOn" default="0">
  <cfparam name="form.disableGroupProductSearchINproductSearch" default="0">
  <cfparam name="form.startAutoRenewAtRFA"    default="0">
  <cfparam name="form.distSearchGetDistByProgramOn" default="0">
  <cfparam name="form.invoiceBrokerFilterRestrict" default="0">
  <cfparam name="form.viewProgramProductGroupType" default="0">
  <cfparam name="form.print_includeheader"    default="0">
  <cfparam name="form.pricing_template_list"    default="">
  <cfparam name="form.ShowProjectsScoreCard"    default="0">
  <cfparam name="form.Check_All_Duplicate_Program" default="0">
  <cfparam name="form.Mass_Pay_Billback"      default="0">
  <cfparam name="form.Display_Eligible_RSP"     default="0">
  <cfparam name="form.One_Page_Claim_Form" default="0" /><!--- Dev Note: BDensmore 10788 --->

  <cfif NOT isNumeric(form.viewProgramProductGroupType)>
	<cfset form.viewProgramProductGroupType = 0 />
  </cfif>
  <cfparam name="form.CustsearchRebaterecipientOn" default="0">
  <cfparam name="form.One_Program_Per_Billback"   default="0">
  <cfparam name="form.programBudgetOn"      default="0">
  <cfparam name="form.SpendingCapVersion"     default="0">
  <cfparam name="form.GrowthDecimal4PercentTier"  default="0">
  <cfparam name="form.Capture_Groups_On_Save"   default="1">
  <cfparam name="form.ForInvoicesDisplayOI"     default="0">
  <cfparam name="form.Bid_Request_Price_List_ID"  default="0">
  <cfparam name="form.BBCheckPayTo"         default="0">
  <cfparam name="form.AppErrorAddToPunchlist"   default="0">
  <cfparam name="form.disableBBAddProgram"    default="0">
  <cfparam name="form.pgmLumpsumDetailedDisplay"  default="0">
  <cfparam name="form.Renew_expired_programs"   default="0">
  <cfparam name="form.Use_Accounting_Program_Type"default="0">
  <cfparam name="form.BB_PP_Manual_Discount"    default="0">
  <cfparam name="form.BBDateDevInExpectedVol"   default="0">
  <cfparam name="form.Show_BSA_Operators"     default="0">
  <cfparam name="form.BidRequestAvailable"    default="0">
  <cfparam name="form.FuturesPricingAvailable"  default="0">
  <cfparam name="form.ExternalWebserviceURL"    default="">
  <cfparam name="form.WebserverInternalIPAddress" default="">
  <cfparam name="form.AutoRenewSpaninPW"      default="0">
  <cfparam name="form.Deviation_Label"      default="">
  <cfparam name="form.Program_Allow_Null_Rate"  default="0">
  <cfparam name="form.Claims_at_Comp_Level"   default="1"> <!--- 19409, set DEFAULT TO ON --->
  <cfparam name="form.pgmDisableEditWhileSendingToClient"     default="0">
  <cfparam name="form.operatingGroupOn"     default="0">
  <cfparam name="form.lettersavailable"       default="0">
  <cfparam name="form.letterssubject"         default="">
  <cfparam name="form.lettersemailfrom"       default="">
  <cfparam name="form.searchSequenceOn"     default="0">
  <cfparam name="form.Display_Cash_Discount_Margin"     default="0">
  <cfparam name="form.localcostvariables"     default="0">
  <cfparam name="form.customerbasedcosts"     default="0">
  <cfparam name="form.maxlocalcostvars"     default="0">
  <cfparam name="form.pgmGrpsOnlyProdAtLowerLevel"default="0">
  <cfparam name="form.Group_By_Group_Type"    default="0">
  <cfparam name="form.pgmScorecardRevisionReport" default="0">
  <cfparam name="form.invoicePositionRestriction" default="0">
  <cfparam name="form.Operator_Letter_Name"   default="">
  <cfparam name="form.Distributor_Letter_Name"  default="">
  <cfparam name="form.RemoveMarketFromPgmSearchPage" default="0">
  <cfparam name="form.pgmViewDisplaySPRAddress2"  default="0">
  <cfparam name="form.Authority_Sequence_For_HQ_Only"   default="0">
  <cfparam name="form.Bid_Request_Hierarchy_Level" default="">
  <cfparam name="form.Show_OR_Hide_Groups_In_View_Margin" default="0">
  <cfparam name="form.tradeplanneroff" default="0">
  <cfparam name="form.approvalmatrixoff" default="0">
  <cfparam name="form.Allowed_to_Add_Operator" default="0">
  <cfparam name="form.Created_Operators_Default_Active" default="0">
  <!--- <cfparam name="form.pgmEmailPricingAdmin" default="0"> ---> <!---removed with label 18746 --->
  <cfparam name="form.Letters_Accepted_By" default="">
  <cfparam name="form.Letters_Address" default="">
  <cfparam name="form.BBRestrictRouteUserList" default="0">
  <cfparam name="form.commonAccessURLPrefix" default="">
  <cfparam name="form.pgmLikeProductCheckbox" default=0>
  <cfparam name="form.view_approved_margins_report" default="0">
  <cfparam name="form.pgmDisplayBothRateUOM" default="0">
  <cfparam name="form.retain_original_RSP" default="0">
  <cfparam name="form.DailyRSPUpdate" default="0">
  <cfparam name="form.cancelallprogramversions" default="0">
  <cfparam name="form.ClaimMech_Popup" default="0">
  <cfparam name="form.Display_Only_Assigned_Deductions" default="0">
  <cfparam name="form.ShowMapping" default="0">
  <cfparam name="form.Avoid_Shared_Products_in_LumpSum" default="0">
  <cfparam name="form.remove_help_icon" default="1"> <!--- Modified With 19969--->
  <cfparam name="form.display_clients_help_desk_info" default="0">
  <cfparam name="form.clients_help_desk_info" default="">
  <cfparam name="form.User_Fax_Number" default="0">
  <cfparam name="form.Billbacks_Sales_Tax" default="0">
  <cfparam name="form.direct_pricing_on" default="0">
  <cfparam name="form.revision_report_uom" default="1">
  <cfparam name="form.display_zeros_view_program" default="0">
  <cfparam name="form.Apply_RSP_Filters" default="0">
  <cfparam name="form.pgmGrpLevel3IsExclusion" default="1">
  <cfparam name="form.ShowUploadAccrual" default="0">
  <cfparam name="form.bonusingrowthswitch" default="0">
  <cfparam name="form.letters_company_logo_path" default="0">
  <cfparam name="form.payment_history_on" default="0">
  <cfparam name="form.BB_Allow_Vendor_Master_Search" default="0">
  <cfparam name="form.Vendor_Search_In_BB_Payee_Page" default="0">
  <cfparam name="form.BB_Allow_Vendor_Cross_Ref_Search" default="0">
  <cfparam name="form.DD_Reassign_Analyst_While_Changing_Pay_To" default="0">
  <cfparam name="form.DD_Assignment_Based_On_Shr_Ship_to" default="0">
  <cfparam name="form.DD_Allow_Negative_Amount_Credits" default="0">
  <cfparam name="form.DD_Change_Classification_Before_RFA" default="0">
  <cfparam name="form.DD_Allow_Write_Off" default="0">
  <cfparam name="form.DD_Sent_Reject_In_1510" default="0">
  <cfparam name="form.DD_Close_With_Equal_BB_Amt" default="0">
  <cfparam name="form.PullBack_Start_Date" default="">
  <cfparam name="form.Populate_180Day_From" default="0">
  <cfparam name="form.BidRequest_Use_Price_ByDate" default="0">
  <cfparam name="form.BidRequest_Components_On" default="0">
  <cfparam name="form.DontRevise_Untill_SAP_OKack" default="0"> <!--- Dev Note: KAL; D8067 --->
  <cfparam name="form.Lumpsum_Distributors" default="0">
  <cfparam name="form.Show_BB_Route" default="0">
  <cfparam name="form.Requester_Approver" default="0">
  <cfparam name="form.Requester_Approver_Position" default="0">
  <cfparam name="form.Hide_BSA_Users"       default="0">
  <cfparam name="form.HQpositionsOn"      default="0">
  <cfparam name="form.Report_Payment_History"       default="0">
  <cfparam name="form.Upload_Document_Privacy_Off" default="0"> <!--- Dev Note: CPM D8275 --->
  <cfparam name="form.DivideProgramVolumeForGroups" default="0">
  <cfparam name="form.ProgramVolumeShowGroups" default="0">
  <cfparam name="form.ShowManagerDetailsOnViewProgram" default="0">
  <cfparam name="form.ViewPgmSortBy" default="0"> <!--- Dev Note: CPM 8223 --->
  <cfparam name="form.crucibleOn" default="0">
  <cfparam name="form.brokerTradeQuestOn" default="0">
  <cfparam name="form.ProgramCategory" default="0"> <!--- Dev Note: Milan 8452 --->
  <cfparam name="form.PullbacksOn" default="0">
  <cfparam name="form.pullbackLabel" default="0"> <!--- Dev Note: DRK 9326 --->
  <cfparam name="form.pgmPostApprovalStatus" default="0">
  <cfparam name="form.pgmPostApprovalStatusType" default="0"><!--- Dev Note: DRK 6122 --->
  <cfparam name="form.ConfidentialityAgreementStatus" default="0"> <!--- Dev Note: Milan 8469 --->
  <cfparam name="form.RemoteEventsEmail" default=""> <!--- Dev Note: Milan 8482 --->
  <cfparam name="form.show_operator_distributor" default="0"> <!--- Dev Note: Milan 8516 --->
  <cfparam name="form.NumberOfDaysForMiniItemMaster" default="0"> <!--- Dev Note: Milan 8471 --->
  <cfparam name="form.Display_Evaluation_Notes" default="0">
  <cfparam name="form.appErrorEmailLinkAlone" default="0">
  <cfparam name="form.BidRequest_Display_Allowance" default="0">
  <cfparam name="form.modify_agree_program" default="0">
  <cfparam name="form.Remove_Broker_Selection" default="0">
  <cfparam name="form.Use_Item_Cust_Price" default="0">
  <cfparam name="form.BBDisplayResubmit" default="0">
  <cfparam name="form.BBAllowReverse" default="0">
  <cfparam name="form.Show_BB_Excel_Report" default="0"> <!--- Dev Note: Milan 8521 --->
  <cfparam name="form.displayInterfaceFlagsSet1" default="0">
  <cfparam name="form.ShowManualBillback" default="0"> <!--- Dev Note: Milan 9165 --->
  <cfparam name="form.ShowAutoBillback" default="0"> <!--- Dev Note: Milan 9165 --->
  <cfparam name="form.AutoBillbackType" default="0"> <!--- Dev Note: Milan 9165 --->
  <cfparam name="form.PriceList_displayed_Right_Click" default="0"> <!--- Dev Note: GV 9284  --->
  <cfparam name="form.View_Trade_Checkbook" default="0"><!--- Dev Note: BJF 9313 --->
  <cfparam name="form.View_Auto_Checkbook" default="0"><!--- Dev Note: BJF 9313 --->
  <cfparam name="form.ViewLegacyID" default="0"><!--- Dev Note: Milan 9360 --->
  <cfparam name="form.ModifyLegacyID" default="0"><!--- Dev Note: Milan 9360 --->
  <cfparam name="form.RevisionTypesOn" default="0"><!--- Dev Note: GV D9391  --->
  <cfparam name="form.WelcomeLetterOn" default="0"><!--- Dev Note: Clay 9254   --->
  <cfparam name="form.templateRestrictGroupLevel" default="0"><!---Dev Note: DRK 9674 --->
  <cfparam name="form.restrictHierarchyLevelOnClassCode" default="0"><!---Dev Note: DRK 9679 --->
  <cfparam name="form.PasswordRequirementsStatus" default="0"><!---Dev Note: Milan 9879 --->
  <cfparam name="form.Use_AccrualLog_For_TC" default="0"><!---Dev Note: BJF 7963 & 10139 --->
  <cfparam name="form.Allow_One_Component_for_Pullbacks" default="0"><!---Dev Note:Milan 9956 --->
  <cfparam name="form.programSpecialRevisionFlag" default="0"><!---Dev Note: DRK 10295 --->
  <cfparam name="form.GroupLevelBillback" default="0"><!---Dev Note: Kal 10343 --->
  <cfparam name="form.Allow_UnKnown_Payee_In_Billback"  default="0"><!---Dev Note: Milan 10380 --->
  <cfparam name="form.Hide_Invalid_Component_Types_In_Billbacks"  default="0"><!---Dev Note: Milan 10433 --->
  <cfparam name="form.billbackScorecardCache"   default="0"><!--- 10619 --->
  <cfparam name="form.programScorecardCache"  default="0"><!--- 10548 --->
  <!--- D17674 [begin] RBL 12/08/08 --->
  <cfparam name="form.projectScorecardCache"  default="0">
  <!--- D17674 [end] RBL 12/08/08 --->

  <cfparam name="form.Multi_Distributor_BB"   default="0"> <!--- D10055 --->
  <cfparam name="form.Use_Different_From_Address"   default="0"> <!--- BJF D10644 --->
  <cfparam name="form.Different_From_Address"   default=""> <!--- BJF D10644 --->
  <cfparam name="form.Use_Big_Billbacks"      default=0><!--- BJF D10291 --->
  <cfparam name="form.Billback_Closing_Method"  default="0"><!---Dev Note: Milan 10605 --->
  <cfparam name="form.Lost_Bids_Deviated"   default="0"><!---Dev Note: BJF  D10608 --->
  <cfparam name="form.showfixedprice_additionalfields"  default="0">
  <cfparam name="form.showrebate_additionalfields"  default="0">
  <cfparam name="form.Freight_Calculator_On" default="0">
  <cfparam name="form.loginPageLogoPath"  default="0"><!----- D10845 ----->
  <cfparam name="form.app_EZButton_On"  default="0">
  <cfparam name="form.suppress_groups_zero_items"   default="0">
  <cfparam name="form.suppress_business_considerations"   default="0">
  <cfparam name="form.AddTodoOnDocAttach" default="0"> <!--- Dev Note: CPM 11135 --->
  <cfparam name="form.IncludeUsersEmailAuto" default="0"> <!--- Dev Note: CPM 11137 --->
  <cfparam name="form.Program_Approval_For_Inactive_Operators" default="0">
  <cfparam name="form.ReleaseSettlement" default="0">
  <cfparam name="form.Disable_Auto_Login" default="0"> <!---  Dev Note:  MarkS 11287 --->
  <cfparam name="form.Component_Product_Restrictions_On" default="0"><!--- Dev note: BJF 11147 --->
  <cfparam name="form.Data_Int_Viewer" default="0"> <!---  Dev Note:  MarkS 10729 --->
	<cfparam name="form.same_lump_sum_component_in_program" default="0" /><!--- Dev Note: BSD D11414 --->
  <cfparam name="form.Allow_Percent_Operator_Programs" default="0" /><!--- Dev Note: BJF D11527 --->
  <cfparam name="form.BB_Deviation_Use_Max_Price" default="0"> <!---  Dev Note:  MarkS 11127 --->
  <cfparam name="form.Billback_Modify_Agree" default="0"><!--- Dev Note: GV D11049  --->
  <cfparam name="form.OnlyAccrualTPA_Pullbacks" default="0">
  <cfparam name="form.UOMEAAvailable"   default="0"><!----- D11545: Create a new Rebate Type for Scan Programs ----->
  <cfparam name="form.Position_Tree_Display_Distributor"  default="0"> <!----- D12004: Remove distributors from tree ----->
  <cfparam name="form.BB_UPLOAD_UPDATED"  default="1"><!---  removed with label 18746 --->
  <cfparam name="form.Split_Billbacks"  default="0"><!--- Dev Note: BSD D11643 Turn Split Billbacks on or off --->
  <cfparam name="form.BB_Auto_Report"   default="0"><!--- Dev Note: D11427 BB Auto Report--->
  <cfparam name="form.BB_Auto_Report_Start_Date" default="#now()#" /> <!---  Dev Note:  MarkS 12575 --->
  <cfparam name="form.BB_Auto_Pay_Customer_Group_In_Invoice"  default="0"><!--- Dev Note: D18880--->
  <cfparam name="form.BB_Auto_Pay_Disable_Pay_Each"   default="0"><!--- Dev Note: D18879--->
  <cfparam name="form.BB_Auto_Pay_Lump_Sum"   default="0">
  <cfparam name="form.BB_Auto_Pay_Allow_Negative_Paid_Amount" default="0"><!--- Dev Note: D18879--->
  <cfparam name="form.BBAutoReportisManuallyConfigured"   default="0">
  <cfparam name="form.BBAutoReportAllowManual"   default="0">
  <cfparam name="form.BBAutoReportAllowReverse"   default="0">
  <cfparam name="form.PgmMarginRebateUseAutoPayPrice"   default="0">
  <cfparam name="form.BB_Auto_Pay_To_Operator_Use_Invoice_Opr_ID" default="0"><!--- Dev Note: D20848--->
  <cfparam name="form.Show_Export_Programs"   default="0"><!--- Dev Note: Milan D11495 Lamb Export - Sales Agreement Application --->
  <cfparam name="form.Interface_BuyingGroup_As_Group_To_Client"   default="0"> <!--- Ana D12320  --->

  <cfparam name="form.BB_Expected_Rate_GT_Claim_Rate"   default="0"><!--- Dev Note: D12498 deviations expected rate should equal program rate (not less)--->
  <cfparam name="form.BudgetsFunctionalityOn"   default="0"><!--- D11447: Budgets   --->
  <cfparam name="form.BudgetSelectionRequired"   default="0"><!--- D32318   --->
  <cfparam name="form.BudgetSingleLevelForFixed"   default="0"><!--- D43536    --->
  <cfparam name="form.Distributor_Product_Integrity_On"   default="0"><!--- D11212: Distributor Product Integrity   --->
  <cfparam name="form.Show_Claim_Adjustment"  default="0"><!--- D12937: Hide Claim Adj --->
  <cfparam name="form.ItemMarginTarget_OR_GrossMargin_For_PriceList"  default="0"><!--- Dev Note: Milan; 13016 --->
  <cfparam name="form.Show_Fixed_Freight"   default="0"><!--- Dev Note: BJF 13395 5.0 only --->
  <!--- 13397 5.0 only--->
  <cfparam name="form.Show_Component_Accrual"     default="0">
  <cfparam name="form.Show_Component_Floor_Pricing"   default="0">
  <!--- 13428 5.0 only --->
  <cfparam name="form.GL_Account_On"          default="0">
  <cfparam name="form.GL_Account_Required_for_Comp"   default="0">
  <cfparam name="form.Exact_List_Matching_On"   default="0">
  <!--- Dev Note: KAL; D13469: Brokerage Application Settings --->
  <cfparam name="form.Brokerage_Functionality_On" default="0">
  <cfparam name="form.Auto_BB_Create_Status_ID" default="4">
  <cfparam name="form.Brokerage_Margin_Calculation" default="0">
  <cfparam name="form.BB_Reference_Uppercase" default="0">
  <cfparam name="form.Suppress_Billback_Business_Considerations" default="0">
  <cfparam name="form.DD_Restrict_ShipTo_For_BB" default=0>
  <cfparam name="form.Primary_Product_Attribute" default="">
  <cfparam name="form.BB_Show_Modify_Program" default="0">



  <!--- 5.0 Only --->
  <cfparam name="form.Enable_csrPath" default="0" />
  <cfparam name="form.DisplayDistributorOffInvoice" default="0" /><!--- Dev Note: Milan 14314 5.0 only --->
  <cfparam name="form.DisplayProposal" default="0" /><!--- Dev Note: Milan 14314 5.0 only --->
  <cfparam name="form.DisplayUSDANOI" default="0" /><!--- Dev Note: Milan 14314 5.0 only --->
  <cfparam name="form.Disable_Adding_Components_On_Revision" default="0" />
  <cfparam name="form.View_Delete_Records" default="0" />
  <cfparam name="Form.DD_Negative_Splits" default="0">
  <cfparam name="form.Program_Lock_Type_ID" default="0" />
  <cfparam name="form.Label_Sets" default="0" />
  <cfparam name="form.Program_Claim_Rates_Report_Available" default="0" />
  <cfparam name="form.Program_Claim_Rates_Report_Exclude_Regular_Prices" default="0" />
  <cfparam name="form.Show_Reason_Code_On_BB_Approval_Screen" default="0" />
  <cfparam name="form.Hide_Billback_Adjustments" default="0" />
  <cfparam name="form.SSL_On" default="0" />
  <cfparam name="form.SSL_On_All_Pages" default="0">
  <cfparam name="form.AuditTrailStorage" default="0">
  <cfparam name="form.AllowBidStatusEditAnytime" default="0">
  <cfparam name="form.ReasonCodeinBillbackDED" default="0">
  <cfparam name="form.BB_Reason_Code_Allow_Multiple" default="0">
  <cfparam name="form.ShowPricingReport" default="0">
  <cfparam name="form.DaysOfHistoricalDataForSpecialPriceList" default="0">
  <cfparam name="form.BBAllowResetAfterDEDInterface" default="0">
  <cfparam name="form.BBAllowResetBeforePMTInterfacePRStatus" default="0">
  <cfparam name="form.ProductReplacementEnabled" default="0">
  <cfparam name="form.BillbackAllowMultipleBudgets" default="0">
  <cfparam name="form.AllowBillbackToCreditMatching" default="0">
  <cfparam name="form.MaxFutureDaysForClaimRatesORPricingExtract" default="0">
  <cfparam name="form.IsVantageOn" default="0">
  <cfparam name="form.VantageDataSource" default="">
  <cfparam name="form.Search_Selection_Tracking_On" default=0>
  <cfparam name="form.Expired_Recently_Days" default=0>
  <cfparam name="form.Pre_Active_Replace_Parent" default=0>
  <cfparam name="form.View_Program_Volume_UOM" default=3>
  <cfparam name="form.View_Program_Estimated_Amount" default=0>
  <cfparam name="form.Filter_Business_Segments" default=0>
  <cfparam name="form.Program_Alerts" default=0>
  <cfparam name="form.Reset_Won_Lost_On_Revision" default=0>
  <cfparam name="form.Approval_Via_Email" default=0>
  <cfparam name="form.BB_Inserts_Credit_To_Invoices" default=0>
  <cfparam name="form.BB_Status_To_Insert_Credit" default=5>
  <cfparam name="form.OperatorCreationFieldsRequired" default=0>
  <cfparam name="form.Third_Party_BB_Upload" default=0>
  <!--- 19441 --->
  <cfparam name="form.BB_Deviations_Override_Price" default=0>
  <cfparam name="form.BB_Upload_III_P_Qty_Amt_Editable" default=0>
  <cfparam name="form.BB_Product_Allow_Zero_Volume" default=0>
  <cfparam name="form.Flex_BB_Deviation" default=0>

  <cfparam name="form.BB_Fractional_Volume" default=0>

  <!---Dev Note: 21185/Anand Rao/10-Nov-09 App Setting for displaying vendor ID NULL form  --->
  <cfparam name="form.Display_Vendor_ID_Null_Form" default=0>

  <!--- Dev Note: KAL; D20523: App setting to turn flex search tools on/off --->
  <cfparam name="form.Flex_Program_Search"    default=0>
  <cfparam name="form.Flex_Distributor_Search"  default=0>
  <cfparam name="form.Flex_Broker_Search"     default=0>
  <cfparam name="form.Flex_Operator_Search"     default=0>
  <cfparam name="form.Flex_Product_Search"    default=0>
  <cfparam name="form.Third_Party_BB_Upload" default=0>
  <!--- <cfparam name="form.Display_Hold_Release_Checkbox" default=0> --->
  <cfparam name="form.Show_BB_Summary_Statement"  default=0> <!--- BJF 20743 --->
  <cfparam name="form.Update_BB_Approve_Amt" default=0> <!--- 21923/Anand Rao/22-Jan-2010 --->
  <cfparam name="form.BB_Approve_Expected_Rate_Less_Tolerance" default=0> <!--- 21923/Anand Rao/22-Jan-2010 --->
  <cfparam name="form.Integrated_Rebill" default=0> <!--- 19384/Anand Rao/05-Apr-2010 --->
  <cfparam name="form.LDAP_SSO_Enabled" default=0>   <!--- 21554/Anand Rao/30-Apr-10 --->
  <cfparam name="form.Document_Purge_Age" default=0>   <!--- D23692/Anand Rao/28-Jun-10 --->
  <cfparam name="form.FTP_Document_Path" default="">   <!--- D23692/KAL/22-Jul-2010 --->

  <cfparam name="form.Allow_Revise_Active_With_Pre_Active" default=0> <!--- 19386/Tim Ford/04/29/2010 --->
  <cfparam name="form.Credit_Type_Is_DD_Reason_Code" default=0><!--- D23133 / Deepa Kunnath / 21-Apr-2010 --->
  <cfparam name="FORM.Reason_Code_in_Billback_Display_Setting" default=1><!---  Dev Notes: D23639/Anand Rao/14-Jun-10 BB reason codes--->
  <cfparam name="form.Search_Inactive_Products_Programs" default=0><!--- 23330 / Milan / 11-May-2010 --->
  <cfparam name="form.Search_Inactive_Distributors_Programs" default=0><!--- 23330 / Milan / 11-May-2010 --->
  <cfparam name="form.Search_Inactive_Operators_Programs" default=0><!--- 26199 / Chris / 23-Feb-2011 --->
  <cfparam name="form.retain_original_RSP_copy" default="0"> <!--- 23442 / Jane / 18-May-2010 --->
  <cfparam name="form.marginItemsExclude" default="0"> <!--- 23601 / Kal / 13-Sep-2010 --->
  <cfparam name="form.planningGroups" default="0"><!---   Dev Notes: D24526/Anand Rao/04-Oct-10 Planning Groups --->
  <cfparam name="form.Simple_Clause" default="0"> <!--- 25647 / Milan / 12-Dec-2010 --->
  <cfparam name="form.BC_On_RFA_af_Reset" default="0"> <!--- 25712 / Jane / 26-Jan-2011 --->
  <cfparam name="form.Require_Business_Considerations_On_New_Programs" default="0"> <!--- 45264 / Anand / 30-Sep-2014 --->
  <cfparam name="form.DD_User_Reference" default="0"> <!--- 26488 /jane/ 03/09/2011 --->
  <cfparam name="form.BB_Created_Recently_Days" default="0"> <!--- 27210 /Milan/ 30-June-2011 --->
  <cfparam name="form.Display_notes_field_on_program" default="0"> <!--- 27171 /Jane/ 10-Aug-2011 --->
  <cfparam name="form.User_Account_Middle_Initial" default="0"> <!--- 28107 /Jane/ 10-Aug-2011 --->
  <cfparam name="form.Use_Fixed_Price_Type" default="0">
  <cfparam name="form.Display_Quote_Letter" default="0">
  <cfparam name="form.Price_List_By_Template" default="0"> <!--- 28271 /Jane/ 08-Sep-2011 --->
  <cfparam name="form.Shortcut_No_Routing_Allowed" default="0"> <!--- D28558  /Deepa / 9/22/2011  --->
  <cfparam name="form.Position_Fields_Filtered_Based_On_Program_Segment" default=0><!--- D28618 Drachala: Position Drop Down Fields filtered based on Program Business Segment --->
  <cfparam name="form.Base_sale_label" default=""><!--- D28459: Change Base Sales program labels to custom label for Hormel --->
  <cfparam name="form.Net_sale_label" default=""><!---  D28459: Change Base Sales program labels to custom label for Hormel --->
  <cfparam name="form.Display_Only_Billback_Parent" default="0"><!--- D28595: app setting to only show parent BB in BB search results --->
  <cfparam name="form.Erp_Deduction_Doc_Path" default="">
  <cfparam name="form.Documents_Display_Upload_Form" default="0"><!--- 29841: Multiple documents upload for billbacks --->
  <cfparam name="form.InvoiceCostForVantage"   default="0"> <!--- D30750:Create app setting to use invoice cost from invoice file --->
  <cfparam name="form.BB_Quick_Pay" default="0">
  <cfparam name="form.Multiple_BillTos_For_ShipTo"   default="0"> <!--- D30486: Multiple AR numbers to 1 Account(Customer)-UI --->
  <cfparam name="form.BBAliasSourceType"   default="0">
  <cfparam name="form.BBAliasSourceTypeIDs"   default="0">
  <cfparam name="form.DD_Closed_BB_Status"   default="0">
  <cfparam name="form.BB_Reset_Unacknowledged_Interface"   default="0">
  <cfparam name="form.BB_Reinterface_Unacknowledged_Interface"   default="0">
  <cfparam name="form.Billback_Display_All_Program_Components"   default="0"> <!--- D31378:Add Program w/o Payee Components don't display --->
  <cfparam name="forml.Billback_Module_Type" default = "1">
  <cfparam name="form.Favicon_Path" default = ""> <!--- 31616 -Add favorite icon to URL address line --->
  <cfparam name="form.BB_LS_Claimed_Rebate_Expected" default = "0"> <!--- 31769 - Billback Deviation Grid --->
  <cfparam name="form.CRA_Consider_Analyst" default="0"> <!--- D32585 Approval e-mails sending to all TL's --->
  <cfparam name="form.Billback_Display_Base_Sales_in_Rate_Dev" default="0">
  <cfparam name="form.Billback_Upload_Business_Segment" default="0"><!--- D29947 Update billback upload for SO/DC --->
  <cfparam name="form.Billback_File_Upload_Type" default=2> <!--- D33957  Modify standard billback upload to one file --->
  <cfparam name="form.Template_Multiple_Product_Attr_Groups" default="0">
  <cfparam name="form.Profitability_Model" default="0"><!--- D36542 prof model -- new internal application setting--->
  <cfparam name="form.BB_Auto_Approve_Logic" default="0"><!--- D37022 BB Auto Approve Logic - CF work --->
  <cfparam name="form.Mass_Copy" default="0">
  <cfparam name="form.View_Operator_in_Billback_Deviation" default="0"><!--- D36746: Billback Deviation & Summary - Add Operator to the display  --->
  <cfparam name="form.BB_Overlap_Deviation_Based_On_Operator" default="0"><!--- D36746: Billback Deviation & Summary - Add Operator to the display  --->
  <cfparam name="form.BB_Default_Program_Retry_Process" default="0">
  <cfparam name="form.BB_Default_Program_Retry_Also_Call_Deviation" default="0">
  <cfparam name="form.Program_Allow_Negative_Rebate_Rates"  default="0">
  <cfparam name="form.Allowable_Overlap_Period"  default="0">
  <cfparam name="form.BB_Inserts_Credit_To_Invoices_GT"  default="">
  <cfparam name="form.Program_search_dates"  default="0"><!--- D38043  :: Program revision dates - View Program --->
  <cfparam name="form.UNIPRO_450"  default="0">
  <cfparam name="form.Deviation_Grid_Allow_Manual_Values_GT_Claimed" default="0">
  <cfparam name="form.BB_Payee_Broker_Ship_To_Req"  default="0">
  <cfparam name="form.Editable_Claimed_Dollars_Quantity" default="0">
  <cfparam name="form.DD_Reopen_Parent"  default="0">
  <cfparam name="form.Operator_Q_Brand_Legacy"  default="0">
  <cfparam name="form.Cancel_Pgm_No_BB_Months"  default="0"><!--- D35165 :: LW ENHANCEMENT REQUEST:  Auto Close programs with no claims for 5 months --->
  <cfparam name="form.Show_Brand_On_View_Program"  default="0">
  <cfparam name="form.Enable_Group_Membership_Dates"  default="0">
  <cfparam name="form.deduction_Quick_Update"  default="0"><!--- D42846 :: Deduction tool upgrades --->
  <cfparam name="form.Auto_Approve_Products_On_Revision"  default="0"><!--- 42590 Auto approve products on revision--->
  <cfparam name="form.BB_Powerpunch"  default="0"> <!--- 43155: Billback Program Change --->
  <cfparam name="form.BB_Payment_Request_Hold_Release"  default="0"> <!--- 43559 BB Pymt Req Hold/Release --->
  <cfparam name="form.Approve_BB_Based_On_Profile_Total_Approval_Amount"  default="0"> <!--- 43559: BB Pymt Amt Within Profile’s Total Approval Amt = Approved Status --->
  <cfparam name="form.disable_pages_in_rfa"  default="0"><!---D43661--->
  <cfparam name="form.Auto_Weight_Distributors_Program_Revision"  default="0">  <!---D41881 :: Auto adjust of DST Weights  --->
  <cfparam name="form.RFA_Notification_1_Case"  default="0">
  <cfparam name="form.Dont_Set_Bid_Product_Status_on_Revise"  default="0"> <!--- 45235 :: Bid flags not flipping correctly--->
  <cfparam name="form.Custom_Max_Rate"  default="0"><!---D45263 :: Create table to store max rates by template/profile --->
  <cfparam name="form.Show_Holding_Pen"  default="0"> <!--- 44787: Show Holding Pen --->
  <cfparam name="form.Date_Tolerance"  default="0"><!---   D44724 Billback Approval Automation --->
  <cfparam name="form.Mass_Change_Preactive"  default="0"><!---   44077 Mass change preactive dates --->
  <cfparam name="form.Auto_Reconcile_Match_Central_BB"  default="0"><!---  D45778 :Auto Reconcile BB's closed to deduction in 1500 --->
  <cfparam name="form.Payee_From_Planning_Groups"  default="0"><!---  45076 :Establish payee from the planning groups --->
  <cfparam name="form.BB_ReferenceNum_Required"  default="0"><!---  D46525 Make BB Reference Field Required / Anand Rao/ 25-Nov-2014 --->
  <cfparam name="form.Allow_BB_Dont_Count_From_Program"  default="0"><!--- D48049: Count / Dont Count Volume based on Program Component --->
  <cfparam name="form.Use_Invoice_Market"  default="0"><!--- 49540: App Setting - Use_Invoice_Market / Anand Rao/ 17-Apr-2015 --->
  <cfparam name="form.SingleSignOnOverrideUserId" default="0"><!--- D48816 :: Single Sign On field needed to hold Username --->
  <cfparam name="form.Enable_EDI_Upload_Raw_Data_Viewer" default="0"><!--- D49837:CAG PROD - BB LH link EDI Download / Anand Rao/ 29-Apr-2015 --->
  <cfparam name="form.TradeEligibilityReport" default="0"><!---D49844 :: Create new app setting called �?Trade Eligibility Report�? with ON/OFF options--->
 <cfparam name="form.Update_Program_Won_Lost_Based_On_OI" default="0"><!--- D49855 :: Win/Loss Bid - Create new app setting called “Update Program won/loss based on Off invoice Record�? --->
 <cfparam name="form.Modify_Expired_Programs" default="0">
 <cfparam name="form.Program_Search_Dollars_And_Volume" default="0"><!--- 50324: Add Dollars and volume --->
 <cfparam name="form.Pymt_history_Dollars_Include_OffInvoice_Dollars" default="0"><!--- 50324 - "Payment history dollars" include  "Off Invoice" Dollars. --->
<cfparam name="form.Check_All_BB_Duplicate" default="0"> <!--- 51607 New Duplicate BB Logic - Appsetting Changes --->
<cfparam name="form.Display_Orphan_Alert_Program_Revise" default="0"><!--- D52449 :: Create new app settings to control Orphan Pop up Alert --->
<cfparam name="form.Program_Alert_On_RFA_Rate_0" default="0"><!--- D50884 :: Improvements to the Rebate Page inside a Program 8.0 Release...  --->
<cfparam name="form.Modify_Vendors_VendorManagement" default="0"><!--- D57447 :: Create and modify vendor records --->

  <cfparam name="form.non_blended_delivered_freight_matrix_excel_export" default="0">
  <cfparam name="form.blended_delivered_freight_matrix_excel_export" default="0">
  <cfparam name="form.escalator_excel_export" default="0">
  <cfparam name="form.Custom_RFP_Letter" default="0">
	<cfparam name="form.Home_Page_Dashboards" default="0">

  <cfscript>
	appSettings = genSettingsManager.get(0);
	appSettings.setDollarGrowth(form.DollarGrowth);
	appSettings.setUseXMaterial(form.UseXMaterial);
	appSettings.setUseProductGroup1(form.UseProductGroup1);
	appSettings.setUseProductGroup2(form.UseProductGroup2);
	appSettings.setUseProductGroup3(form.UseProductGroup3);
	appSettings.setUseProductGroup4(form.UseProductGroup4);
	appSettings.setUseProductGroup5(form.UseProductGroup5);
	appSettings.setUseProductHierarchy(form.UseProductHierarchy);
	appSettings.setSearchProductHierarchyExcludeList(form.searchProductHierarchyExcludeList);
	appSettings.setAppSettingsOnForAll(form.appSettingsOnForAll);
  // ---   appSettings.setSendAutoAttachments(form.SendAutoAttachments); ---;
	appSettings.setAutoBroker(form.AutoBroker);
	appSettings.setRFAAgree(form.RFAAgree);
	appSettings.setCustomertype(form.Customertype);
	appSettings.setRestrictProductUOM(form.RestrictProductUOM);
	appSettings.setRebateMaxComponents(form.RebateMaxComponents);
	appSettings.setLabelNotes(form.LabelNotes);
	appSettings.setFloorPrice(form.FloorPrice);
	appSettings.setAllowNavigate(form.AllowNavigate);
	appSettings.setLumpMultipleProducts(form.LumpMultipleProducts);
	appSettings.setprogramnotesrequired(form.programnotesrequired);
	appSettings.setEquipment_Placement(form.Equipment_Placement);
  // ---   appSettings.setsendsecondaryemail(form.send_secondary_email); ---;
	appSettings.setfixedcomponents_on(form.fixedcomponents_on);
	appSettings.setrolloverprograms_on(form.rolloverprograms_on);
  // ---   appSettings.setSendApprovedProgramsEmailAdress(form.Send_Approved_Programs_EmailAdress); ---;
	appSettings.setClasscodesOn(form.Classcodes_On);
	appSettings.setGrowthExpansion1(form.GrowthExpansion1);
	appSettings.setForbidAllowProfilesInTemplates(form.forbidAllowProfilesInTemplates);
	appSettings.setuploadmargintargets_on(form.uploadmargintargets_on);
	appSettings.setRestrictAccessOnGroup(form.RestrictAccessOnGroup);
	appSettings.setbusinessconsiderations_on(form.businessconsiderations_on);
	appSettings.setcustid_on(form.custid_on);
	appSettings.setBBFixedCalcTypesOn(form.BB_Fixed_Calc_Types_On);
	appSettings.setClaimAutoPrint(form.claimAutoPrint);
	appSettings.setBillBack_Statement_Type(form.billback_statement_type);   // 27047
	appSettings.setAllowAllDistributors(form.allowAllDistributors);
	appSettings.setMaxProfileCount(form.maxProfileCount);
	appSettings.setsinglesign_on(form.singlesign_on);
	appSettings.setDistributorMultiPosition(form.distributorMultiPosition);
	appSettings.setOperatorSearchRestrict(form.operatorSearchRestrict);
	appSettings.setSalesOrgOn(form.SalesOrgOn);
	appSettings.setDistributionChannelOn(form.DistributionChannelOn);
	appSettings.setDeleteProgramMessage(form.DeleteProgramMessage);
	appSettings.setDeleteIsCancelAutoRenew(form.DeleteIsCancelAutoRenew);
  // ---   appSettings.setCancelProgramEmail(form.CancelProgramEmail); ---;
	appSettings.setPaymentCycleAtDiscountType(form.PaymentCycleAtDiscountType);
	appSettings.setSettlement_SAP_Business(form.Settlement_SAP_Business);
	appSettings.setSysco_Report_On(form.Sysco_Report_On);
	appSettings.setAllowMultiLevelGroups(form.Allow_Multi_Level_Groups);
	appSettings.setProgramAgreeEscalate(form.ProgramAgreeEscalate);
	appSettings.setCheckOrderClass(form.CheckOrderClass);
	appSettings.setOrderClassValue(form.OrderClassValue);
	appSettings.setBusiness_Segment_Label(form.Business_Segment_Label);
	appSettings.setIntegation_Instance_ID(form.Integation_Instance_ID);
	appSettings.setBB_Ref_Num_Max_Length(form.BB_Ref_Num_Max_Length);
	appSettings.setBB_2Ref_Num_Max_Length(form.BB_2Ref_Num_Max_Length);
	appSettings.setLOB_Label(form.LOB_Label);
	appSettings.setsend_to_sap(form.send_to_sap);
	appSettings.settemplatecodes_on(form.templatecodes_on);
	appSettings.setBB_Payee_Operator_Ship_To_Req(form.BB_Payee_Operator_Ship_To_Req);
	appSettings.setVendor_Selection_Pay_Req(form.Vendor_Selection_Pay_Req);
	appsettings.setBillback_Payment_Request_Without_Vendor_Selection(form.Billback_Payment_Request_Without_Vendor_Selection);
	appsettings.setSkipVendorSelectionOnBBApproval(form.Skip_Vendor_Selection_On_BB_Approval);
	appSettings.setMultiple_BB_Per_Deduction(form.Multiple_BB_Per_Deduction);
	appSettings.setAllow_Negative_Billback(form.Allow_Negative_Billback);
	appSettings.setBB_Allow_Off_Invoice_Closing_Method(form.BB_Allow_Off_Invoice_Closing_Method);
	appSettings.setInterface_700_To_Client(form.Interface_700_To_Client);
	appSettings.setDD_Show_reassign(form.DD_Show_reassign);
	appSettings.setAuto_Deviation_On(form.Auto_Deviation_On);
	appSettings.setDD_Show_Classification(form.DD_Show_Classification);
	appSettings.setDD_Show_DeductionType(form.DD_Show_DeductionType);    // ---26487---;
	appSettings.setDD_Show_Edit_Customer_Num(form.DD_Show_Edit_Customer_Num);
	appSettings.setDD_Allow_Non_Trade(form.DD_Allow_Non_Trade);//D29481:Non trade deductions
  // ---   appSettings.setDD_Show_Write_Off(form.DD_Show_Write_Off); ---;
	appSettings.setDD_Show_Create_Adjustment(form.DD_Show_Create_Adjustment);
	appSettings.setDD_Show_Delete(form.DD_Show_Delete);
	appSettings.setDD_Show_ReOpen(form.DD_Show_ReOpen);
	appSettings.setDD_Show_Reject(form.DD_Show_Reject);
	appSettings.setDD_Show_Program(form.DD_Show_Program);
	appSettings.setDD_Show_Invoices(form.DD_Show_Invoices);
	appSettings.setERP_Deal_ID_PopUp(form.ERP_Deal_ID_PopUp);
	appSettings.setBB_Allow_UnKnow_Program_Creation(form.BB_Allow_UnKnow_Program_Creation);
	appSettings.setBB_Pay_Req_Dup_Check(form.BB_Pay_Req_Dup_Check);
  // ---   appSettings.setTemplate_Notes_Availability(form.Template_Notes_Availability); ---;    // --- BJF: Removed with label 13333  ---;
	appSettings.setMatch_BB_DD_Based_On_Same_ReferenceNum(form.Match_BB_DD_Based_On_Same_ReferenceNum);
	appSettings.setRestrict_DD_Reason_Code_By_Closing_method(form.Restrict_DD_Reason_Code_By_Closing_method);
	appSettings.setUserNumberRestrict(form.userNumberRestrict);
	appSettings.setUSDANOIEnabled(form.USDANOIEnabled);
	appSettings.setProductSearchGetProductByProgramOn(form.productSearchGetProductByProgramOn);
	appSettings.setDisableGroupProductSearchINproductSearch(form.disableGroupProductSearchINproductSearch);
	appSettings.setStartAutoRenewAtRFA(form.startAutoRenewAtRFA);
	appSettings.setDistSearchGetDistByProgramOn(form.distSearchGetDistByProgramOn);
	appSettings.setInvoiceBrokerFilterRestrict(form.invoiceBrokerFilterRestrict);
	appSettings.setViewProgramProductGroupType(form.viewProgramProductGroupType);
	appSettings.setCustsearchRebaterecipientOn(form.CustsearchRebaterecipientOn);
	appSettings.setOneProgramPerBillback(form.One_Program_Per_Billback);
	appSettings.setProgramBudgetOn(form.programBudgetOn);
	appSettings.setSpendingCapVersion(form.SpendingCapVersion);
	appSettings.setGrowthDecimal4PercentTier(form.GrowthDecimal4PercentTier);
	appSettings.setCaptureGroupsOnSave(form.Capture_Groups_On_Save);
	appSettings.setForInvoicesDisplayOI(form.ForInvoicesDisplayOI);
	appSettings.setBidRequestPriceListId(form.Bid_Request_Price_List_ID);
  // ---   appSettings.setRFAEmailEvent(form.RFAEmailEvent);
  // appSettings.setBBAgreeEmail(form.BBAgreeEmail); --->
	appSettings.setBBCheckPayTo(form.BBCheckPayTo);
	appSettings.setAppErrorAddToPunchlist(form.AppErrorAddToPunchlist);
	appSettings.setdisableBBAddProgram(form.disableBBAddProgram);
	appSettings.setPgmLumpsumDetailedDisplay(form.pgmLumpsumDetailedDisplay);
	appSettings.setRenew_expired_programs(form.Renew_expired_programs);
	appSettings.setUse_Accounting_Program_Type(form.Use_Accounting_Program_Type);
	appSettings.setBB_PP_Manual_Discount(form.BB_PP_Manual_Discount);
	appSettings.setBBDateDevInExpectedVol(form.BBDateDevInExpectedVol);
	appSettings.setShowBSAOperators(form.Show_BSA_Operators);
	appSettings.setBidRequestAvailable(form.BidRequestAvailable);
	appSettings.setFuturesPricingAvailable(form.FuturesPricingAvailable);
	appSettings.setExternalWebserviceURL(form.ExternalWebserviceURL);
	appSettings.setWebserverInternalIPAddress(form.WebserverInternalIPAddress);
	appSettings.setAutoRenewSpaninPW(form.AutoRenewSpaninPW);
	appSettings.setDeviationLabel(form.Deviation_Label);
	appSettings.setProgram_Allow_Null_Rate(form.Program_Allow_Null_Rate);
	appSettings.setClaims_at_Comp_Level(form.Claims_at_Comp_Level);
	appSettings.setPgmDisableEditWhileSendingToClient(form.pgmDisableEditWhileSendingToClient);
	appSettings.setOperatingGroupOn(form.operatingGroupOn);
	appSettings.setlettersavailable(form.lettersavailable);
	appSettings.setletterssubject(form.letterssubject);
	appSettings.setlettersfromemail(form.LETTERSFROMEMAIL);
	appSettings.setSearchSequenceOn(form.searchSequenceOn);
	appSettings.setDisplayCashDiscountMargin(form.Display_Cash_Discount_Margin);
	appSettings.setlocalcostvariables(form.localcostvariables);
	appSettings.setcustomerbasedcosts(form.customerbasedcosts);
	appSettings.setmaxlocalcostvars(form.maxlocalcostvars);
	appSettings.setPgmGrpsOnlyProdAtLowerLevel(form.pgmGrpsOnlyProdAtLowerLevel);
	appSettings.setGroupByGroupType(form.Group_By_Group_Type);
  // ------   appSettings.setAppNumberingScheme(form.appNumberingScheme); -----;
	appSettings.setprintincludeheader(form.print_includeheader);
	appSettings.setpricingtemplatelist(form.pricing_template_list);
	appSettings.setShowProjectsScoreCard(form.ShowProjectsScoreCard);
	appSettings.setPgmScorecardRevisionReport(form.pgmScorecardRevisionReport);
	appSettings.setInvoicePositionRestriction(form.invoicePositionRestriction);
	appSettings.setDistributorLetterName(form.Distributor_Letter_Name);
	appSettings.setOperatorLetterName(form.Operator_Letter_Name);
	appSettings.setRemoveMarketFromPgmSearchPage(form.RemoveMarketFromPgmSearchPage);
	appSettings.setCheckAllDuplicateProgram(form.Check_All_Duplicate_Program);
	appSettings.setMass_Pay_Billback(form.Mass_Pay_Billback);
	appSettings.setPgmViewDisplaySPRAddress2(form.pgmViewDisplaySPRAddress2);
	appSettings.setAuthority_Sequence_For_HQ_Only(form.Authority_Sequence_For_HQ_Only);
	appSettings.setBidRequestHierarchyLevel(form.Bid_Request_Hierarchy_Level);
	appSettings.setShowORHideGroupsInViewMargin(form.Show_OR_Hide_Groups_In_View_Margin);
	appSettings.settradeplanneroff(form.tradeplanneroff);
	appSettings.setapprovalmatrixoff(form.approvalmatrixoff);
	appSettings.setAllowed_to_Add_Operator(form.Allowed_to_Add_Operator);
	appSettings.setCreated_Operators_Default_Active(form.Created_Operators_Default_Active);
  // ---  appSettings.setPgmEmailPricingAdmin(form.pgmEmailPricingAdmin); ---; // --- removed with label 18746 ---;
	appSettings.setLettersAcceptedBy(form.Letters_Accepted_By);
	appSettings.setLettersAddress(form.Letters_Address);
	appSettings.setBBRestrictRouteUserList(form.BBRestrictRouteUserList);
	appSettings.setCommonAccessURLPrefix(form.commonAccessURLPrefix);
	appSettings.setPgmLikeProductCheckbox(form.pgmLikeProductCheckbox);
	appSettings.setviewapprovedmarginsreport(form.view_approved_margins_report);
	appSettings.setPgmDisplayBothRateUOM(form.pgmDisplayBothRateUOM);
	appSettings.setretainoriginalRSP(form.retain_original_RSP);
	appSettings.setDailyRSPUpdate(form.DailyRSPUpdate);
	appSettings.setcancelallprogramversions(form.cancelallprogramversions);
	appSettings.setClaimMech_Popup(form.ClaimMech_Popup);
	appSettings.setDisplayOnlyAssignedDeductions(form.Display_Only_Assigned_Deductions);
	appSettings.setShowMapping(form.ShowMapping);
	appSettings.setAvoidSharedProductsinLumpSum(form.Avoid_Shared_Products_in_LumpSum);
	appSettings.setRemoveHelpIcon(form.Remove_Help_Icon);
	appSettings.setdisplayclientshelpdeskinfo(form.display_clients_help_desk_info);
	appSettings.setclientshelpdeskinfo(form.clients_help_desk_info);
	appSettings.setUserFaxNumber(form.User_Fax_Number);
	appSettings.setBillbacksSalesTax(form.Billbacks_Sales_Tax);
	appSettings.setdirectpricingon(form.direct_pricing_on);
	appSettings.setrevisionreportuom(form.revision_report_uom);
	appSettings.setdisplayzerosviewprogram(form.display_zeros_view_program);
	appSettings.setApplyRSPFilters(form.Apply_RSP_Filters);
	appSettings.setPgmGrpLevel3IsExclusion(form.pgmGrpLevel3IsExclusion);
	appSettings.setShowUploadAccrual(form.ShowUploadAccrual);
	appSettings.setBonusInGrowthSwitch(form.bonusingrowthswitch);
	appSettings.setletterscompanylogopath(form.letters_company_logo_path);
	appSettings.setpaymenthistoryon(form.payment_history_on);
	appSettings.setBBAllowVendorMasterSearch(form.BB_Allow_Vendor_Master_Search);
	appSettings.setVendorSearchInBBPayeePage(form.Vendor_Search_In_BB_Payee_Page);
	appSettings.setBBAllowVendorCrossRefSearch(form.BB_Allow_Vendor_Cross_Ref_Search);
	appSettings.setDDReassignAnalystWhileChangingPayTo(form.DD_Reassign_Analyst_While_Changing_Pay_To);
	appSettings.setDDAssignmentBasedOnShrShipto(form.DD_Assignment_Based_On_Shr_Ship_to);
	appSettings.setDDAllowNegativeAmountCredits(form.DD_Allow_Negative_Amount_Credits);
	appSettings.setDDChangeClassificationBeforeRFA(form.DD_Change_Classification_Before_RFA);
	appSettings.setDDAllowWriteOff(form.DD_Allow_Write_Off);
	appSettings.setDDSentRejectIn1510(form.DD_Sent_Reject_In_1510);
	appSettings.setDDCloseWithEqualBBAmt(form.DD_Close_With_Equal_BB_Amt);
	appSettings.setPullBack_Start_Date(form.PullBack_Start_Date);
	appSettings.setPopulate_180Day_From(form.Populate_180Day_From);
	appSettings.setBidRequestUsePriceByDate(form.BidRequest_Use_Price_ByDate);
	appSettings.setBidRequestComponentsOn(form.BidRequest_Components_On);
	appSettings.setDontReviseUntillSAPokAck(form.DontRevise_Untill_SAP_OKack); // --- Dev Note: KAL; D8067 ---;
	appSettings.setLumpSumDistributors(form.Lumpsum_Distributors);
	appSettings.setShow_BB_Route(form.Show_BB_Route);
	appSettings.setUploadDocumentPrivacyOff(form.Upload_Document_Privacy_Off); // --- Dev Note: CPM 8275 ---;
	appSettings.setDivideProgramVolumeForGroups(form.DivideProgramVolumeForGroups);
	appSettings.setProgramVolumeShowGroups(form.ProgramVolumeShowGroups);
	appSettings.setShowManagerDetailsOnViewProgram(form.ShowManagerDetailsOnViewProgram);
	appSettings.setViewPgmSortBy(form.ViewPgmSortBy);
	appSettings.setCrucibleOn(form.crucibleOn);
	appSettings.setBrokerTradeQuestOn(form.brokerTradeQuestOn);
	appSettings.setProgramCategory(form.ProgramCategory); // --- Dev Note: Milan 8452 ---;
	appSettings.setPullbacksOn(form.PullbacksOn);
	appSettings.setPullbackLabel(form.pullbackLabel);
	appSettings.setPgmPostApprovalStatus(form.pgmPostApprovalStatus);
	appSettings.setPgmPostApprovalStatusType(form.pgmPostApprovalStatusType); // --- Dev Note: DRK 6122 ---;
	appSettings.setConfidentialityAgreementStatus(form.ConfidentialityAgreementStatus);// --- Dev Note: Milan 8469 ---;
	appSettings.setRemoteEventsEmail(form.RemoteEventsEmail);// --- Dev Note: Milan 8482 ---;
	appSettings.setProgramScoreCard(form.show_operator_distributor);// --- Dev Note: Milan 8516 ---;
	appSettings.setNumberOfDaysForMiniItemMaster(form.NumberOfDaysForMiniItemMaster);// --- Dev Note: Milan 8471 ---;
	appSettings.setDisplayEvaluationNotes(form.Display_Evaluation_Notes);
	appSettings.set_Requester_Approver(form.Requester_Approver);
	appSettings.set_Requester_Approver_Position(form.Requester_Approver_Position);
	appSettings.setHide_BSA_Users(form.Hide_BSA_Users);
	appSettings.setHQpositionsOn(form.HQpositionsOn);
	appSettings.set_Report_Payment_History(form.Report_Payment_History);
	appSettings.setAppErrorEmailLinkAlone(form.appErrorEmailLinkAlone);
	appSettings.setBidRequestDisplayAllowance(form.BidRequest_Display_Allowance);
	appSettings.setmodifyagreeprogram(form.modify_agree_program);
	appSettings.setRemoveBrokerSelection(form.Remove_Broker_Selection);
	appSettings.setDisplayEligibleRSP(form.Display_Eligible_RSP);
	appSettings.setUseItemCustPrice(form.Use_Item_Cust_Price);
	appSettings.setBBDisplayResubmit(form.BBDisplayResubmit);
	appSettings.setBBAllowReverse(form.BBAllowReverse);
	appSettings.setShowBBExcelReport(form.Show_BB_Excel_Report); // --- Dev Note: Milan 8521 ---;
	appSettings.setDisplayInterfaceFlagsSet1(form.displayInterfaceFlagsSet1);
	appSettings.setShowManualBillback(form.ShowManualBillback); // --- Dev Note: Milan 9165 ---;
	appSettings.setShowAutoBillback(form.ShowAutoBillback); // --- Dev Note: Milan 9165 ---;
	appSettings.setAutoBillBackType(form.AutoBillBackType); // --- Dev Note: Milan 9165 ---;
	appSettings.setPriceListDisplayedRightClick(form.PriceList_displayed_Right_Click);
	appSettings.setView_Trade_Checkbook(form.View_Trade_Checkbook);// --- Dev Note: BJF 9313 ---;
	appSettings.setView_Auto_Checkbook(form.View_Auto_Checkbook);// --- Dev Note: BJF 9313 ---;
	appSettings.setView_Legacy_ID(form.ViewLegacyID);// --- Dev Note: BJF 9360 ---;
	appSettings.setModify_Legacy_ID(form.ModifyLegacyID);// --- Dev Note: BJF 9360 ---;
	appSettings.setRevisionTypesOn(form.RevisionTypesOn);// --- Dev Note: GV 9391 ---;
	appSettings.setWelcomeLetterOn(form.WelcomeLetterOn);// --- Dev Note: Clay 9254   ---;
	appSettings.setTemplateRestrictGroupLevel(form.templateRestrictGroupLevel);// ---Dev Note: DRK 9674 ---;
	appSettings.setRestrictHierarchyLevelOnClassCode(form.restrictHierarchyLevelOnClassCode);// ---Dev Note: DRK 9679 ---;
	appSettings.setPasswordRequirementsStatus(form.PasswordRequirementsStatus);// ---Dev Note: Milan 9879 ---;
	appSettings.setUse_AccrualLog_For_TC(form.Use_AccrualLog_For_TC);// ---Dev Note: BJF 7963 & 10139 ---;
	appSettings.setAllowOneComponentforPullbacks(form.Allow_One_Component_for_Pullbacks);// ---Dev Note: Milan 9956 ---;
	appSettings.setProgramSpecialRevisionFlag(form.programSpecialRevisionFlag);// ---Dev Note: DRK 10295 ---;
	appSettings.setGroupLevelBillback(form.GroupLevelBillback);// ---Dev Note: Kal 10343 ---;
	appSettings.setAllowUnKnownPayeeInBillback(form.Allow_UnKnown_Payee_In_Billback);// ---Dev Note: Milan 10380 ---;
	appSettings.setHideInvalidComponentTypesInBillbacks(form.Hide_Invalid_Component_Types_In_Billbacks);// ---Dev Note: Milan 10433 ---;
	appSettings.setProgramScorecardCache(form.programScorecardCache);
	appSettings.setBillbackScorecardCache(form.billbackScorecardCache);
	appSettings.setMultiDistributorBB(form.Multi_Distributor_BB);
	appSettings.setUse_Different_From_Address(form.Use_Different_From_Address);// --- BJF D10644 ---;
	appSettings.setDifferent_From_Address(form.Different_From_Address);// --- BJF D10644 ---;
	appSettings.setUse_Big_Billbacks(form.Use_Big_Billbacks);// --- BJF D10291 ---;
	appSettings.setBillbackClosingMethod(form.Billback_Closing_Method);// ---Dev Note: Milan 10605 ---;
	appSettings.setshowfixedpriceadditionalfields(form.showfixedprice_additionalfields);
	appSettings.setshowrebateadditionalfields(form.showrebate_additionalfields);
	appSettings.setLost_Bids_Deviated(form.Lost_Bids_Deviated);// ---Dev Note: BJF D10608 ---;
	appSettings.setFreight_Calculator_On(form.Freight_Calculator_On);// --- Dev Note: CPM 10941 ---;
	appSettings.setLoginPageLogoPath(form.loginPageLogoPath);// ---Dev Note: BJF D10608 ---;
	appSettings.setappEZButtonOn(form.app_EZButton_On);
	appSettings.setOnePageClaimForm(form.One_Page_Claim_Form);// ---Dev Note: BDensmore 10788 ---;
	appSettings.setSuppressGroupsZeroItems(form.suppress_groups_zero_items);
	appSettings.setSuppressBusinessConsiderations(form.suppress_business_considerations);
	appSettings.setAddTodoOnDocAttach(form.AddTodoOnDocAttach);// --- Dev Note: CPM 11135 ---;
	appSettings.setIncludeUsersEmailAuto(form.IncludeUsersEmailAuto);// --- Dev Note: CPM 11137 ---;
	appSettings.setProgramApprovalForInactiveOperators(form.Program_Approval_For_Inactive_Operators);
	appSettings.setReleaseSettlement(form.ReleaseSettlement);
	appSettings.setDisableAutoLogin(form.Disable_Auto_Login);
	appSettings.setComponent_Product_Restrictions_On(form.Component_Product_Restrictions_On);// ---D11147 BJF ---;
	appsettings.setDataIntViewer(form.Data_Int_Viewer);// ---  Dev Note:  MarkS 10729 ---;
	appSettings.setUpdatedBy(request.AccessStructure.User_ID);
	appSettings.setLumpSumComponentInProgram(form.same_lump_sum_component_in_program);// --- Dev Note: BSD D11414 ---;
	appSettings.setAllow_Percent_Operator_Programs(form.Allow_Percent_Operator_Programs);// --- Dev Note: BJF D11527 ---;
	appsettings.setBBDeviationUseMaxPrice(form.BB_Deviation_Use_Max_Price);// ---  Dev Note:  MarkS 11127 ---;
	appSettings.setBillbackModifyAgree(form.Billback_Modify_Agree); // --- Dev Note: KAL D11049  ---;
	appSettings.setOnlyAccrualTPAPullbacks(form.OnlyAccrualTPA_Pullbacks);
	appSettings.setUOMEAAvailable(form.UOMEAAvailable);
	appSettings.setPosition_Tree_Display_Distributor(form.Position_Tree_Display_Distributor);
	appSettings.setBB_UPLOAD_UPDATED(form.BB_UPLOAD_UPDATED);// ---  removed with label 18746 ---;
	appSettings.setSplitBillbacks(form.Split_Billbacks);// --- Dev Note: BSD D11643 Turn Split Billbacks on or off ---;
	appsettings.setBBAutoReport(form.BB_Auto_Report);// ---  Dev Note:  MarkS 11427 ---;
	appsettings.setBBAutoPayCustomerGroupInInvoice(form.BB_Auto_Pay_Customer_Group_In_Invoice);// --- Dev Note: D18880---;
	appsettings.setBBAutoPayDisablePayEach(form.BB_Auto_Pay_Disable_Pay_Each);// --- Dev Note: D18879---;
	appsettings.setBBAutoPayLumpSum(form.BB_Auto_Pay_Lump_Sum);
	appsettings.setBBAutoPayAllowNegativePaidAmount(form.BB_Auto_Pay_Allow_Negative_Paid_Amount);// --- Dev Note: D19057---;
	appsettings.setBBAutoReportisManuallyConfigured(form.BBAutoReportisManuallyConfigured);
	appsettings.setBBAutoReportAllowManual(form.BBAutoReportAllowManual);
	appsettings.setBBAutoReportAllowReverse(form.BBAutoReportAllowReverse);
	appsettings.setPgmMarginRebateUseAutoPayPrice(form.PgmMarginRebateUseAutoPayPrice);
	appsettings.setBBAutoPayToOperatorUseInvoiceOprID(form.BB_Auto_Pay_To_Operator_Use_Invoice_Opr_ID);
	appSettings.setShowExportPrograms(form.Show_Export_Programs);// --- Dev Note: Milan D11495 Lamb Export - Sales Agreement Application ---;
	appSettings.setInterface_BuyingGroup_As_Group_To_Client(form.Interface_BuyingGroup_As_Group_To_Client);
	appsettings.setBBExpectedRateGTClaimRate(form.BB_Expected_Rate_GT_Claim_Rate);// ---  Dev Note:  MarkS 12498 ---;
	appsettings.setBBAutoReportStartDate(form.BB_Auto_Report_Start_Date);// ---  Dev Note:  MarkS 12498 ---;
	appSettings.setBudgetsFunctionalityOn(form.BudgetsFunctionalityOn);// --- D11447: Budgets   ---;
	appSettings.setBudgetSelectionRequired(form.BudgetSelectionRequired);// --- D32318 : Budgets   ---;
	appSettings.setBudgetSingleLevelForFixed(form.BudgetSingleLevelForFixed);// --- D43536 : Budgets   ---;
	appSettings.setDistributor_Product_Integrity_On(form.Distributor_Product_Integrity_On);// --- D11212: Distributor Product Integrity   ---;
	appSettings.setShowClaimAdjustment(form.Show_Claim_Adjustment);
	appSettings.setItemMarginTargetORGrossMarginForPriceList(form.ItemMarginTarget_OR_GrossMargin_For_PriceList);// --- Dev Note: Milan; 13016 ---;
	appSettings.setShow_Fixed_Freight(form.Show_Fixed_Freight);// --- Dev Note: BJF 13395 5.0 only ---;
  // --- 13397 5.0 only ---;
	appSettings.setShow_Component_Accrual(form.Show_Component_Accrual);
	appSettings.setShow_Component_Floor_Pricing(form.Show_Component_Floor_Pricing);
  // --- 13428 5.0 only ---;
	appSettings.setGL_Account_On(form.GL_Account_On);
	appSettings.setGL_Account_Required_for_Comp(form.GL_Account_Required_for_Comp);
	appSettings.setExact_List_Matching_On(form.Exact_List_Matching_On);
  // --- Dev Note: KAL; D13469: Brokerage Application Settings ---;
	appSettings.setBrokerage_Functionality_On(form.Brokerage_Functionality_On);
	appSettings.setAuto_BB_Create_Status_ID(form.Auto_BB_Create_Status_ID);
	appSettings.setBrokerage_Margin_Calculation(form.Brokerage_Margin_Calculation);
	appSettings.setBB_Reference_Uppercase(form.BB_Reference_Uppercase);
  // ---   appSettings.setEnable_csrPath(form.Enable_csrPath) ; ---;
	appSettings.setSuppressBillbackBusinessConsiderations(form.Suppress_Billback_Business_Considerations);
	appSettings.setDisplayDistributorOffInvoice(form.DisplayDistributorOffInvoice);
	appSettings.setDisplayProposal(form.DisplayProposal);
	appSettings.setDisplayUSDANOI(form.DisplayUSDANOI);
	appSettings.setDisableAddingComponentsOnRevision(form.Disable_Adding_Components_On_Revision);
	appSettings.setViewDeleteRecords(form.View_Delete_Records);
	appSettings.setDD_Negative_Splits(form.DD_Negative_Splits);
	appSettings.setProgramLockTypeID(form.Program_Lock_Type_ID);
	appSettings.setLabelSets(form.Label_Sets);
	appSettings.setProgramClaimRatesReportAvailable(form.Program_Claim_Rates_Report_Available);
	appSettings.setProgramClaimRatesReportExcludeRegularPrices(form.Program_Claim_Rates_Report_Exclude_Regular_Prices);
	appSettings.setShowReasonCodeOnBBApprovalScreen(form.Show_Reason_Code_On_BB_Approval_Screen);// --- Dev Note: Milan; 15415 ---;
	appSettings.setHide_Billback_Adjustments(form.Hide_Billback_Adjustments);// --- Dev Note: Milan; D15741  ---;
	appSettings.setSSL_On(form.SSL_On);
	appSettings.setSSL_On_All_Pages(form.SSL_On_All_Pages);
	appSettings.setAuditTrailStorage(form.AuditTrailStorage);
	appSettings.setAllowBidStatusEditAnytime(form.AllowBidStatusEditAnytime);
	appSettings.setReasonCodeinBillbackDED(form.ReasonCodeinBillbackDED);
	appSettings.setBBReasonCodeAllowMultiple(form.BB_Reason_Code_Allow_Multiple);
	appSettings.setShowPricingReport(form.ShowPricingReport);
	appSettings.setDaysOfHistoricalDataForSpecialPriceList(form.DaysOfHistoricalDataForSpecialPriceList);
	appSettings.setBBAllowResetAfterDEDInterface(form.BBAllowResetAfterDEDInterface);
	appSettings.setBBAllowResetBeforePMTInterfacePRStatus(form.BBAllowResetBeforePMTInterfacePRStatus);
	appSettings.setProductReplacementEnabled  (form.ProductReplacementEnabled);
	appSettings.setBillbackAllowMultipleBudgets(form.BillbackAllowMultipleBudgets);
	appSettings.setAllowBillbackToCreditMatching(form.AllowBillbackToCreditMatching);
	appSettings.setMaxFutureDaysForClaimRatesORPricingExtract(form.MaxFutureDaysForClaimRatesORPricingExtract);
	appSettings.setIsVantageOn(form.IsVantageOn);
	appSettings.setVantageDataSource(form.VantageDataSource);
	appSettings.setSearch_Selection_Tracking_On(form.Search_Selection_Tracking_On);
	appSettings.setExpiredRecentlyDays(form.Expired_Recently_Days);
	appSettings.setPreActiveReplaceParent(form.Pre_Active_Replace_Parent);
	appSettings.setViewProgramVolumeUOM(form.View_Program_Volume_UOM);
	appSettings.setViewProgramEstimatedAmount(form.View_Program_Estimated_Amount);
	appSettings.setFilterBusinessSegments(form.Filter_Business_Segments);
	appSettings.setProgramAlerts(form.Program_Alerts);
	appSettings.setReset_Won_Lost_On_Revision(form.Reset_Won_Lost_On_Revision);
	appSettings.setApprovalViaEmail(form.Approval_Via_Email) ;
	appSettings.setDD_Restrict_ShipTo_For_BB(form.DD_Restrict_ShipTo_For_BB);
	appSettings.setPrimary_Product_Attribute(form.Primary_Product_Attribute);
	appSettings.setBB_Inserts_Credit_To_Invoices(form.BB_Inserts_Credit_To_Invoices);
	appSettings.setBB_Status_To_Insert_Credit(form.BB_Status_To_Insert_Credit);
	appSettings.setOperator_Creation_Fields_Required(form.OperatorCreationFieldsRequired);
	appSettings.setThirdPartyBBUpload(form.Third_Party_BB_Upload);
	appSettings.setShow_BB_Summary_Statement(form.Show_BB_Summary_Statement);
	appSettings.setBBShowModifyProgram(form.BB_Show_Modify_Program);
	appSettings.setBB_Deviations_Override_Price(form.BB_Deviations_Override_Price) ;
	appSettings.setBB_Upload_III_P_Qty_Amt_Editable(form.BB_Upload_III_P_Qty_Amt_Editable) ;
	appSettings.setBBProductAllowZeroVolume(form.BB_Product_Allow_Zero_Volume) ;
	appSettings.setFlex_BB_Deviation(form.Flex_BB_Deviation) ;
	appSettings.setBB_Fractional_Volume(form.BB_Fractional_Volume) ;

  // --- Dev Notes: 21185/Anand Rao/10-Nov-09 Setting for displaying Vendor ID Null form ---;
	appSettings.setDisplay_Vendor_ID_Null_Form(form.Display_Vendor_ID_Null_Form) ;

  // ---   appSettings.setDisplay_Hold_Release_Checkbox(form.Display_Hold_Release_Checkbox) ; ---;

  // --- Dev Note: KAL; D20523: App setting to turn flex search tools on/off ---;
	appSettings.setFlexProgramSearch(form.Flex_Program_Search) ;
	appSettings.setFlexDistributorSearch(form.Flex_Distributor_Search) ;
	appSettings.setFlexBrokerSearch(form.Flex_Broker_Search) ;
	appSettings.setFlexOperatorSearch(form.Flex_Operator_Search) ;
	appSettings.setFlexProductSearch(form.Flex_Product_Search) ;

  // --- 21923/Anand Rao/22-Jan-2010 ---;
	appSettings.setUpdate_BB_Approve_Amt(form.Update_BB_Approve_Amt) ;
	appSettings.setBB_Approve_Expected_Rate_Less_Tolerance(form.BB_Approve_Expected_Rate_Less_Tolerance) ;
  // --- 19384/Anand Rao/05-Apr-2010 ---;
	appSettings.setIntegrated_Rebill(form.Integrated_Rebill) ;
  // --- Dev Notes: 21554/Anand Rao/30-Apr-10 ---;
	appSettings.setLDAP_SSO_Enabled(form.LDAP_SSO_Enabled) ;
  // --- Dev Notes: D23692/Anand Rao/28-Jun-10 ---;
	appSettings.setDocumentPurgeAge(form.Document_Purge_Age);
  // --- Dev Notes: D23692/KAL/22-Jul-2010 ---;
	appSettings.setFTPDocumentPath(form.FTP_Document_Path);

	appSettings.setAllowReviseActiveWithPreActive(form.Allow_Revise_Active_With_Pre_Active) ;
	appSettings.setCreditTypeIsDDReasonCode(form.Credit_Type_Is_DD_Reason_Code) ;
  // ---  Dev Notes: D23639/Anand Rao/14-Jun-10 BB reason codes ---;
	appSettings.setReasonCodeInBillbackDisplaySetting(FORM.Reason_Code_in_Billback_Display_Setting) ;

  // ---  23330 / Milan / 11-May-2010 ---;
	appSettings.setSearchInactiveProductsInPrograms(form.Search_Inactive_Products_Programs) ;
	appSettings.setSearchInactiveDistributorsInPrograms(form.Search_Inactive_Distributors_Programs) ;
	appSettings.setSearchInactiveOperatorsInPrograms(form.Search_Inactive_Operators_Programs) ;   // ---26199---;
	appSettings.setretainoriginalRSPcopy(form.retain_original_RSP_copy);
	appSettings.setBillback_Module(form.Billback_Module);
	appSettings.setDeduction_Module(form.Deduction_Module);
	appSettings.setMarginItemsExclude(form.marginItemsExclude);
	appSettings.setPlanningGroups(form.PlanningGroups);
	appSettings.setSimpleClause(form.Simple_Clause);
	appSettings.setBC_On_RFA_af_Reset(form.BC_On_RFA_af_Reset);
	appSettings.setRequire_Business_Considerations_On_New_Programs(form.Require_Business_Considerations_On_New_Programs);
	appSettings.setDD_User_Reference(form.DD_User_Reference);
	appSettings.setBBCreatedRecentlyDays(form.BB_Created_Recently_Days);
	appSettings.setDisplayNotesFieldOnProgram(form.Display_notes_field_on_program);
	appSettings.setUserAccountMiddleInitial(form.User_Account_Middle_Initial);
	appSettings.setUseFixedPriceType(form.Use_Fixed_Price_Type);
	appSettings.setDisplayQuoteLetter(form.Display_Quote_Letter);
	appSettings.setPriceListByTemplate(form.Price_List_By_Template);
	appSettings.setShortcutNoRoutingAllowed(form.Shortcut_No_Routing_Allowed);
	appSettings.setPositionFieldsFilterOnProgramSegment(form.Position_Fields_Filtered_Based_On_Program_Segment);//D28618 Drachala: Position Drop Down Fields filtered based on Program Business Segment
	appSettings.setBaseSaleLabel(form.base_sale_label);//D28459: Change Base Sales program labels to custom label for Hormel
	appSettings.setNetSaleLabel(form.net_sale_label);//D28459: Change Base Sales program labels to custom label for Hormel
  appSettings.setDisplayOnlyBillbackParent(form.Display_Only_Billback_Parent);
  appSettings.setErpDeductionDocPath(form.Erp_Deduction_Doc_Path);
	appSettings.setDocumentsDisplayUploadForm(form.Documents_Display_Upload_Form);
	appSettings.setExternal_Contacts(form.External_Contacts_Option);  //28345
	appSettings.setEdit_Product_Master_Data(form.Edit_Product_Master_Data);
  appSettings.setPrgWonLostOnBBApproval(FORM.PrgWonLostOnBBApproval);
  appSettings.setInvoiceCostForVantage(FORM.InvoiceCostForVantage);//D30750:Create app setting to use invoice cost from invoice file
  appSettings.setBillbackQuickPay(form.BB_Quick_Pay);
  appSettings.setMultipleBillTosForShipTo(form.Multiple_BillTos_For_ShipTo);//D30486: Multiple AR numbers to 1 Account(Customer)-UI
	appSettings.setDDClosedBBStatus(form.DD_Closed_BB_Status);
	appSettings.setBBResetUnacknowledgedInterface(form.BB_Reset_Unacknowledged_Interface);
	appSettings.setBBReinterfaceUnacknowledgedInterface(form.BB_Reinterface_Unacknowledged_Interface);
  appSettings.setBillbackDisplayAllProgramComponents(form.Billback_Display_All_Program_Components); //D31378:Add Program w/o Payee Components don't display
  appSettings.setBillbackModuleType(form.Billback_Module_Type);
  appSettings.setFaviconPath(form.Favicon_Path); //31616 -Add favorite icon to URL address line
  appSettings.setBB_LS_Claimed_Rebate_Expected(form.BB_LS_Claimed_Rebate_Expected); //31769 - Billback Deviation Grid
  appSettings.setCRAConsiderAnalyst(form.CRA_Consider_Analyst);//D32585 Approval e-mails sending to all TL's
  appSettings.setBillback_Display_Base_Sales_in_Rate_Dev(form.Billback_Display_Base_Sales_in_Rate_Dev);
	appSettings.setBillback_Upload_Business_Segment(form.Billback_Upload_Business_Segment);//D29947 Update billback upload for SO/DC
  appSettings.setBillbackFileUploadType(form.Billback_File_Upload_Type);//D33957  Modify standard billback upload to one file
	appSettings.setBB_Count_Indicator(form.BB_Count_Indicator); //34665
	appSettings.setTemplateMultipleProductAttrGroups(form.Template_Multiple_Product_Attr_Groups); //35295
	appSettings.setProfitabilityModel(form.Profitability_Model); //36542
	appSettings.setBBAutoApproveLogic(form.BB_Auto_Approve_Logic);//37022
	appSettings.setMassCopy(form.Mass_Copy);
  appSettings.setViewOperatorinBillbackDeviation(form.View_Operator_in_Billback_Deviation);
  appSettings.setBBOverlapDeviationBasedOnOperator(form.BB_Overlap_Deviation_Based_On_Operator);
  appSettings.setBBDefaultProgramRetryProcess(form.BB_Default_Program_Retry_Process);
  appSettings.setBBDefaultProgramRetryAlsoCallDeviation(form.BB_Default_Program_Retry_Also_Call_Deviation);
	appSettings.setProgram_Allow_Negative_Rebate_Rates(form.Program_Allow_Negative_Rebate_Rates);
	appSettings.setAllowableOverlapPeriod(form.AllowableOverlapPeriod);
	appSettings.setBB_Inserts_Credit_To_Invoices_GT(BB_Inserts_Credit_To_Invoices_GT);
	appSettings.setProgram_search_dates(form.Program_search_dates);//D38043  :: Program revision dates - View Program
	appSettings.setUNIPRO_450(UNIPRO_450);
  appSettings.setDeviationGridAllowManualValuesGTClaimed(Deviation_Grid_Allow_Manual_Values_GT_Claimed);
	appSettings.setBBPayeeBrokerShipToReq(BB_Payee_Broker_Ship_To_Req);
  appSettings.setEditableClaimedDollarsQuantity(Editable_Claimed_Dollars_Quantity);
	appSettings.setDDReopenParent(form.DD_Reopen_Parent);
	appSettings.setOperatorQBrandLegacy(form.Operator_Q_Brand_Legacy);
	appSettings.setCancelPgmNoBBMonths(form.Cancel_Pgm_No_BB_Months);//D35165 :: LW ENHANCEMENT REQUEST:  Auto Close programs with no claims for 5 months
	appSettings.setShowBrandOnViewProgram(form.Show_Brand_On_View_Program);
	appSettings.setEnableGroupMembershipDates(form.Enable_Group_Membership_Dates);
  appSettings.setDeductionQuickUpdate(form.deduction_Quick_Update);//D42846:: Deduction tool upgrades
  appSettings.setAutoApproveProductsOnRevision(form.Auto_Approve_Products_On_Revision);//42590 Auto approve products on revision
  appSettings.setBBPowerpunch(form.BB_Powerpunch);
  appSettings.setBBPaymentRequestHoldRelease(form.BB_Payment_Request_Hold_Release);//43559 BB Pymt Req Hold/Release
  appSettings.setApproveBBBasedOnProfileTotalApprovalAmount(form.Approve_BB_Based_On_Profile_Total_Approval_Amount);//43559 BB Pymt Amt Within Profile’s Total Approval Amt = Approved Status
	appSettings.setdisablepagesinrfa(form.disable_pages_in_rfa);//D43661
  appSettings.setShowHoldingPen(form.Show_Holding_Pen);
	appSettings.setDD_Reopen_Interface(form.DD_Reopen_Interface);//D42284 :: Rebill vs closed deduction reopened
	appSettings.setAutoWeightDistributorsProgramRevision(form.Auto_Weight_Distributors_Program_Revision);//D41881
  appSettings.setDateTolerance(form.Date_Tolerance);// D44724
	appSettings.setRFA_Notification_1_Case(form.RFA_Notification_1_Case);
  appSettings.setDontSetBidProductStatusRevise(form.Dont_Set_Bid_Product_Status_on_Revise); //D45235
  appSettings.setCustomMaxRate(form.Custom_Max_Rate);//D45263 :: Create table to store max rates by template/profile
  appSettings.setMassChangePreactive(form.Mass_Change_Preactive);//44077 :: Mass change preactive programs
  appSettings.setAuto_Reconcile_Match_Central_BB(form.Auto_Reconcile_Match_Central_BB); //  D45778 :Auto Reconcile BB's closed to deduction in 1500
  appSettings.setPayeeFromPlanningGroups(form.Payee_From_Planning_Groups); // 45076 :Establish payee from the planning groups
  appSettings.setBBReferenceNumRequired(form.BB_ReferenceNum_Required); // D46525: Make BB Reference Field Required
  appSettings.setAllow_BB_Dont_Count_From_Program(form.Allow_BB_Dont_Count_From_Program); // D48049: Count / Dont Count Volume based on Program Component
  appSettings.setUseInvoiceMarket(form.Use_Invoice_Market); // 49540: App Setting - Use_Invoice_Market
	appSettings.setSingleSignOnOverrideUserId(form.SingleSignOnOverrideUserId); //D48816 :: Single Sign On field needed to hold Username
  appSettings.setEnableEDIUploadRawDataViewer(form.Enable_EDI_Upload_Raw_Data_Viewer); //D49837:CAG PROD - BB LH link EDI Download
	appSettings.setTradeEligibilityReport(form.TradeEligibilityReport);//D49844 :: Create new app setting called �?Trade Eligibility Report�? with ON/OFF options
	appSettings.setPrgWonLostOnOffInvoiceRecord(form.Update_Program_Won_Lost_Based_On_OI);//D49855 :: Win/Loss Bid - Create new app setting called “Update Program won/loss based on Off invoice Record�?
	appSettings.setModifyExpiredPrograms(form.Modify_Expired_Programs);//D50074 :: Viewing and Editing prior program versions
  appSettings.setProgramSearchDollarsAndVolume(form.Program_Search_Dollars_And_Volume); //50324: Add Dollars and volume
  appSettings.setPymtHistoryDollarsIncludeOffInvoiceDollars(form.Pymt_history_Dollars_Include_OffInvoice_Dollars); //50324 - "Payment history dollars" include "Off Invoice" Dollars.
  appSettings.setCheckAllBBDuplicate(form.Check_All_BB_Duplicate); //51607: New Duplicate BB Logic - Appsetting Changes
  appSettings.setDisplayOrphanAlertProgramRevise(form.Display_Orphan_Alert_Program_Revise);//D52449 :: Create new app settings to control Orphan Pop up Alert
  appSettings.setProgramAlertOnRFARate0(form.Program_Alert_On_RFA_Rate_0);// D50884 :: Improvements to the Rebate Page inside a Program 8.0 Release...
	appSettings.setModifyVendorRecords(form.Modify_Vendors_VendorManagement);//D57447 :: Create and modify vendor records
	genSettingsManager.save(2);
	genSettingsManager.saveBBAliasSourceType(BBAliasSourceTypeList=form.BBAliasSourceTypeIDs,settingsBBAliasSourceType=form.BBAliasSourceType);
  </cfscript>

  <cflocation addtoken="No" url="#thisPage#">

  <cfabort>

</cfif>

<cfset appSettings = genSettingsManager.get(1, 2, 1)>

<!--- retrieve all settings and place them into request.settings variable --->
<cfset application.util.query.request_settings()>

<style>
  .appSettingsInput
  {
	text-align:right;
	width:50px;
  }
  label.flex {
      margin-right: 10px;
  }
  label.flex > span {
      position: relative;
      top: -3px;
  }
</style>

<script SRC="/Script/javascript/string_functions.min.js"></script>
<script SRC="/Script/javascript/date_Parse.js"></script>
<script language="JavaScript">

function validateAndSubmit(thisForm)
{
  var isValid = true;
  var ErrorCount = 0;

  if((document.all.Flex_Program_Search.value==2 || document.all.Flex_Program_Search.value==3 || document.all.Flex_Program_Search.value==4 || document.all.Flex_Program_Search.value==5)
  && (document.all.Expired_Recently_Days.value=='' || document.all.Expired_Recently_Days.value==0))
  {
	ErrorCount++;
	queueMessage("No. of days for recently expired programs has to be greater than 0 (zero) days", document.all.err_sp_ExpiredRecentlyDays);
  }
  else
  {
	clearQueue(document.all.err_sp_ExpiredRecentlyDays);
  }

  if(document.all.BB_Created_Recently_Days.value==0)
  {
	ErrorCount++;
	queueMessage("No. of days for recently created billbacks has to be greater than 0 (zero) days", document.all.err_sp_BBCreatedRecentlyDays);
  }
  else
  {
	clearQueue(document.all.err_sp_BBCreatedRecentlyDays);
  }

  if(isValid && ErrorCount == 0)
  {
	  if ($("input[name=Retail_Planner]").is(":checked")) {
		var elem = $("select[name=retail_target_product_group]");
		if (elem.val() == "") {
		  elem.focus();
		  alert("Please select a target product group under the Retail <CFOUTPUT>#Application.PlannerLabel#</CFOUTPUT> section.");
		  return false;
		}
	  }

  show_loader("SAVING CHANGES, PLEASE WAIT...");
  zeroCheckBoxes();
  submitForm(thisForm, "Settings2");
  }
  else
  {
	showMessageWindow();
  }
}

function permanentlyDeleteAllBBAnalysts()
{
  if(confirm("Do you want to permanently delete the billback analysts?  \n\nNOTE:  THIS IS PERMANENT AND WILL DELETE ALL EXISTING BILLBACK ASSIGNMENTS."))
  {
	NewWindow('/settings/delete_all_BB_analysts_permanent.cfm','','10','10','Yes', 'Yes');
  }
}

</script>
<br>
<div class="mark">
<input type="text" name="mark_text" value=""><br>
<a class="secondary hand find_first">#application.util.string.linkFormat("first", "", "<i class='ui-icon ui-icon-search'></i>")#</a><br><br>
<a class="secondary hand find_next">#application.util.string.linkFormat("next", "", "<i class='ui-icon ui-icon-seek-next'></i>")#</a><br><br>
<a class="secondary hand find_prev">#application.util.string.linkFormat("prev", "", "<i class='ui-icon ui-icon-seek-prev'></i>")#</a>
</div>
<cfif Len(appSettings.getUpdatedByUserName()) GT 0>
<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0" align="center">
<TR>
<TD>
  <FONT SIZE="2"><B>The settings were last updated on #dateformat(appSettings.getUpdatedOn(), 'medium')# #timeformat(appSettings.getUpdatedOn(), 'hh:mm:ss TT')# by #appSettings.getUpdatedByUserName()#</B></FONT> </TD>
</TD>
</TR>
</TABLE>
<br>
</cfif>

<cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( [4, 0.15, 4] )>

<table cellpadding="2" cellspacing="0" border="0" width="96%">
<tr>
<td width="50%" valign="top">
<table cellpadding="2" cellspacing="0" border="0" style='table-layout:fixed' class="s9i t107">
  <cfloop array="#variables.columnSizes#" index="variables.columnPercentage">
	<cfoutput><col width="#variables.columnPercentage#%"></cfoutput>
  </cfloop>
  <tr>
	<td>Permit Dollar Option for Growth:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="DollarGrowth" <Cfif appSettings.getDollarGrowth() IS 1>checked</CFIF>></td>
  </tr>
  <tr>
	<td>Use X Material:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="UseXMaterial" <Cfif appSettings.getUseXMaterial() IS 1>checked</CFIF>></td>
  </tr>
  <tr>
	<td>App Settings On For All:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="AppSettingsOnForAll" <Cfif appSettings.getAppSettingsOnForAll() IS 1>checked</CFIF>></td>
  </tr>
  <!--- <tr>
	<td>Send Auto Attachments:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="SendAutoAttachments" <Cfif appSettings.getSendAutoAttachments() IS 1>checked</CFIF>></td>
  </tr> --->
  <tr>
	<td>Auto Broker:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="AutoBroker" <Cfif appSettings.getAutoBroker() IS 1>checked</CFIF>></td>
  </tr>
  <tr>
	<td>RFA Agree:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="RFAAgree" <Cfif appSettings.getRFAAgree() IS 1>checked</CFIF>></td>
  </tr>
  <tr>
	<td>Restrict Rate UOM on Product UOM:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="RestrictProductUOM" <cfif appSettings.getRestrictProductUOM() IS 1>checked</CFIF>></td>
  </tr>
  <tr>
	<td>Rebate Max Components:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="text" size="1" maxlength="1" name="RebateMaxComponents" value="#appSettings.getRebateMaxComponents()#"></td>
  </tr>
  <!--- Removed with label 19969, Default to OFF
  <tr>
	<td>Restrict Navigation:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1"  name="AllowNavigate" <cfif appSettings.getAllowNavigate() IS 1>checked</CFIF>></td>
  </tr>
  --->
  <tr>
	<td>Lumpsum - allow multiple products:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1"  name="LumpMultipleProducts" <cfif appSettings.getLumpMultipleProducts() IS 1>checked</CFIF>></td>
  </tr>

  <tr>
	<td>ClassCodes On:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1"  name="ClassCodes_On" <cfif appSettings.getClassCodesOn() IS 1>checked</CFIF>></td>
  </tr>
<!---   <tr>
	<td>Send Email to Secondary Positions:<br>(Status change Notification)</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1"  name="send_secondary_email" <cfif appSettings.getsendsecondaryemail() IS 1>checked</CFIF>></td>
  </tr> --->

  <tr style="display:none"> <!--- hidden by 43234 Growth Template Settings --->
	<td>Display Growth options in template (e.g. bracket rate, retroactive rate, seperate volume pool) Note: When this app setting is ON & the app setting called "Switch for bonus field in growth" is also ON, users will see LumpSum field in growth</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1"  name="GrowthExpansion1" <cfif appSettings.getGrowthExpansion1() IS 1>checked</CFIF>></td>
  </tr>
  <tr valign="top" style="display:none"> <!--- hidden by 43234 Growth Template Settings --->
	<td>Switch for Bonus field in Growth</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="bonusingrowthswitch" <cfif appSettings.getBonusInGrowthSwitch()>checked</cfif>></td>
  </tr>

  <tr>
	<td>Roll Over Programs On:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="rolloverprograms_on" <Cfif appSettings.getrolloverprograms_on() IS 1>checked</CFIF>></td>
  </tr>
  <tr>
	<td>Margin Targets On:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="uploadmargintargets_on" <Cfif appSettings.getuploadmargintargets_on() IS 1>checked</CFIF>></td>
  </tr>
  <tr>
	<td>Business Considerations On:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="businessconsiderations_on" <Cfif appSettings.getbusinessconsiderations_on() IS 1>checked</CFIF>></td>
  </tr>
  <tr>
	<td>Display Business Considerations on RFA after a program was reset:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="BC_On_RFA_af_Reset" <Cfif appSettings.getBC_On_RFA_af_Reset() IS 1>checked</CFIF>></td>
  </tr>
  <tr>
	<td>Require Business Considerations on new programs:</td>
	<td>&nbsp; </td>
  <td align="left"><input type="checkbox" value="1" name="Require_Business_Considerations_On_New_Programs" <Cfif appSettings.getRequire_Business_Considerations_On_New_Programs() IS 1>checked</CFIF>></td>
  </tr>
  <!---
  <tr>
	<td>Allow All <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput>:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="allowAllDistributors" <Cfif appSettings.getAllowAllDistributors() IS 1>checked</CFIF>></td>
  </tr>
   --->
  <tr>
    <td>Display Business Considerations all the time:</td>
    <td>&nbsp; </td>
    <td align="left"><input type="checkbox" value="1" name="Business_Considerations_All_Time" <cfif request.settings.Business_Considerations_All_Time eq '1'>checked</CFIF>></td>
  </tr>
  <tr>
    <td>Business Considerations Required when uploading documents:</td>
    <td>&nbsp; </td>
    <td align="left"><input type="checkbox" value="1" name="Business_Consideration_Req_Doc_Upload" <cfif request.settings.Business_Consideration_Req_Doc_Upload eq '1'>checked</CFIF>></td>
  </tr>
  <tr>
	<td>Max Profile Count:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="text" size="3" maxlength="2" value="#appSettings.getMaxProfileCount()#" name="maxProfileCount"></td>
  </tr>
  <tr>
	<td>Line of Business (Product & Distributor):</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" <Cfif appSettings.getSalesOrgOn() IS 1>checked</CFIF> value="1" name="SalesOrgOn"></td>
  </tr>
  <tr>
	<td>Type Code (Product & <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>):
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="DistributionChannelOn" <cfif appSettings.getDistributionChannelOn() IS 1>checked</cfif>></td>
  </tr>
  <tr>
	<td>Settlement - SAP Business:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="Settlement_SAP_Business" <cfif appSettings.getSettlement_SAP_Business() IS 1>checked</cfif>></td>
  </tr>
  <tr>
	<td>Payment Cycle At Discount Type:(default = 0)</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="PaymentCycleAtDiscountType" <cfif appSettings.getPaymentCycleAtDiscountType() IS 1>checked</CFIF>></td>
  </tr>
  <tr>
	<td>Sysco Report On:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="Sysco_report_on" <cfif appSettings.getSysco_report_on() IS 1>checked</CFIF>></td>
  </tr>
  <!--- <tr>
	<td>Business Segment Label:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="text" value="#appSettings.getbusiness_segment_label()#" name="business_segment_label"></td>
  </tr>
  <!--- Dev Note: drachala; D28459: Change Base Sales program labels to custom label for Hormel  START
  Added/Changed: Added This two Settings--->
  <tr>
	<td>Base Sales Label:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="text" value="#appSettings.getBaseSaleLabel()#" name="base_sale_label"></td>
  </tr>
  <tr class="b0304">
	<td>Net Sales Label:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="text" value="#appSettings.getNetSaleLabel()#" name="net_sale_label"></td>
  </tr> --->
  <!--- End Dev Note: drachala; D28459: Change Base Sales program labels to custom label for Hormel  --->
  <tr>
	<td>Send Data to SAP:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="Send_to_SAP" <cfif appSettings.getSend_to_SAP() IS 1>checked</CFIF>></td>
  </tr>
  <tr>
	<td>Ship To is required for billback with operator as payee:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="BB_Payee_Operator_Ship_To_Req" <cfif appSettings.getBB_Payee_Operator_Ship_To_Req() IS 1>checked</CFIF>></td>
  </tr>
  <tr>
 <tr>
	<td>Ship To is required for billback with broker as payee:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="BB_Payee_Broker_Ship_To_Req" <cfif appSettings.getBBPayeeBrokerShipToReq() IS 1>checked</CFIF>></td>
  </tr>
  <tr>
	<td>Program Agree Escalate:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="ProgramAgreeEscalate" <cfif appSettings.getProgramAgreeEscalate()>checked</cfif>></td>
  </tr>
  <tr>
	<td>Restrict program creation on User Number:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="userNumberRestrict" <cfif appSettings.getUserNumberRestrict()>checked</cfif>></td>
  </tr>
  <!--- <cfset renderDivider()> --->
  <!--- to turn off the "get distributors by program" function in distributor search --->
  <!--- Removed with label 19409, set DEFAULT TO OFF
  <tr>
	<td>Get Products By Program in Product Search On:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="productSearchGetProductByProgramOn" <cfif appSettings.getProductSearchGetProductByProgramOn()>checked</cfif>></td>
  </tr>
  <!--- to turn off the "get products by program" function in product search --->
  <tr>
	<td>Get <cfoutput>#application.returned_customer_setting.distributor_label_plural# By Program in #application.returned_customer_setting.distributor_label_singular#</cfoutput> Search On:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="distSearchGetDistByProgramOn" <cfif appSettings.getDistSearchGetDistByProgramOn()>checked</cfif>></td>
  </tr>
  --->
  <tr valign="top">
	<td>Product Group to be displayed in View Program: -1=none, 0=pack size, 1=type code, 3=Q Brand, 4=Brand, 8=BSA Product Group</td>
	<td>&nbsp; </td>
	<td align="left"><input type="text" size="2" name="viewProgramProductGroupType" value="#appSettings.getViewProgramProductGroupType()#"></td>
  </tr>
  <!--- programBudgetOn --->
	<!--- Dev Note: drachala; D28958: Internal App Setting 'Program Budget On', hide this setting  START
	  Added/Changed: Commented out this TR --->
<!---  <tr>
	<td>Program Budget On:
	(default = 0)
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="programBudgetOn" <cfif appSettings.getProgramBudgetOn()>checked</cfif>></td>
  </tr>--->
  <!--- End Dev Note: drachala; D28958: Internal App Setting 'Program Budget On', hide this setting  --->
  <!--- GrowthDecimal4PercentTier --->
  <tr>
	<td>Growth - Allow Decimal for Tiers: (default = 0, Off)
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="GrowthDecimal4PercentTier" <cfif appSettings.getGrowthDecimal4PercentTier()>checked</cfif>></td>
  </tr>

<!--- START: 77405	Consolidated Growth View -- Anand Rao/13-Jun-2018 --->
  <tr>
	<td>Growth - Consolidated View</td>
	<td>&nbsp; </td>
	<td><input type="checkbox" value="1" name="Growth_Consolidated_View" <cfif request.settings.Growth_Consolidated_View eq '1'>checked</cfif>></td>
  </tr>
<!--- END: 77405	Consolidated Growth View -- Anand Rao/13-Jun-2018 --->

  <!--- Drop down for the bid request price list id --->
  <tr>
	<td>Proposal Price List ID:
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <cfset qGetPriceListIds = genSettingsManager.getPriceListIds() />

	  <select name="Bid_Request_Price_List_ID">
		<cfloop query="qGetPriceListIds">
		  <option value="#Price_List_ID#" <cfif appSettings.getBidRequestPriceListId() eq Price_List_ID>selected</cfif>>#Price_List_ID#</option>
		</cfloop>
	  </select>
	</td>
  </tr>
  <!--- <tr valign="top">
	<td>When should we send out RFA email:<br>
	1=on RFA, 2=on agree, 3=both
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="text" size="2" name="RFAEmailEvent" value="#appSettings.getRFAEmailEvent()#"></td>
  </tr> --->
  <!--- <tr valign="top">
	<td>Billback - Send email on agree:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="BBAgreeEmail" <cfif appSettings.getBBAgreeEmail()>checked</cfif>></td>
  </tr> --->
  <tr valign="top">
	<td>App Error: Add To Punchlist (leave unchecked if the application is installed somewhere else)</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="AppErrorAddToPunchlist" <cfif appSettings.getAppErrorAddToPunchlist()>checked</cfif>></td>
  </tr>
  <tr class="t7h">
	<td>App Error: Email link alone (leave unchecked if the application is installed somewhere else)
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="appErrorEmailLinkAlone" <cfif appSettings.getAppErrorEmailLinkAlone()>checked</cfif>></td>
  </tr>
  <tr class="t7h">
	<td>BB Add programs where payee is not on program
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="disableBBAddProgram" <cfif appSettings.getdisableBBAddProgram()>checked</cfif>></td>
  </tr>
  <tr class="t7h">
	<td>Use Program Label
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Use_Accounting_Program_Type" <cfif appSettings.getUse_Accounting_Program_Type()>checked</cfif>></td>
  </tr>


  <tr class="t7h">
	<td>Disable Group Selection In Product Search
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="disableGroupProductSearchINproductSearch" <cfif appSettings.getDisableGroupProductSearchINproductSearch()>checked</cfif>> </td>
  </tr>
  <tr class="t7h">
	<td  >Start Auto Renew at RFA - RFA=On (default), WIP=Off</td>
	<td>&nbsp; </td>
	<td align="left" valign="top"><input value="1" type="checkbox" name="startAutoRenewAtRFA" <cfif appSettings.getStartAutoRenewAtRFA()>checked</cfif> ></td>
  </tr>
  <tr class="t7h">
	<td>BB - Apply date deviation percentage in expected Volume calculation</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="BBDateDevInExpectedVol" <cfif appSettings.getBBDateDevInExpectedVol()>checked</cfif>></td>
  </tr>
	<tr class="t7h">
	  <td>BB - Rebate rate deviation UOM %, consider associated distributors:<span onmouseout="popUpTip(event,'tBBRateDeviation');" onmouseover="popUpTip(event,'tBBRateDeviation');"><img src="/images/help_small.gif" /></span></td>
		<td>&nbsp;
				<div id="tBBRateDeviation" class="tip" style="width: 425px">
				This app setting should be OFF  for all clients except CMI. See WR 104639 for details.<br>
				The reasons this should be OFF for clients:<br>
				A) When this logic is 'on', it causes major performance issues in the billback deviation routine causing it to run 10x slower.<br>
				B) This logic relates to Rebate rate deviation when UOM is %. Most clients will have their distributor programs with rebate % paid out via auto pay and would not be going inside the billback deviation grid to review the rebate calculations.
				</div>
		</td>
	  <td>
		<input value="1" type="checkbox" name="BB_Rebate_Percent_Calc_Per_Assoc_Dist"  <cfif request.settings.BB_Rebate_Percent_Calc_Per_Assoc_Dist eq '1'>checked</cfif>>
	  </td>
  </tr>
  <tr class="t7h">
	<td>Proposals (bid requests) Available</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="BidRequestAvailable" <cfif appSettings.getBidRequestAvailable()>checked</cfif>></td>
  </tr>
  <tr class="t7h">
	<td>Futures Pricing Available</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="FuturesPricingAvailable" <cfif appSettings.getFuturesPricingAvailable()>checked</cfif>></td>
  </tr>
  <!--- <tr class="t7h">
	<td>
	  Deviation Label
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input type="text" size="25" maxlength="100" value="#appSettings.getDeviationLabel()#" name="Deviation_Label">
	</td>
  </tr> --->
  <tr class="t7h">
	<td>Allow Null Rate in Components (Fixed, Rebate)
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Program_Allow_Null_Rate" <cfif appSettings.getProgram_Allow_Null_Rate()>checked</cfif>></td>
  </tr>
  <tr class="t7h">
	<td>Allow Negative Rebate Rates
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Program_Allow_Negative_Rebate_Rates" <cfif appSettings.getProgram_Allow_Negative_Rebate_Rates()>checked</cfif>></td>
  </tr>
  <!--- Removed with label 19409, set DEFAULT TO ON
  <tr valign="top">
	<td>Allow Claims at Component Level -- must be turned on for 4.3+<br><!--- BJF mandatory on with label 13399 --->
	<a href="updateClaims.cfm" target="_blank">Click here to update components with claim from program</a><br>(Run once after turning this on for the first time)
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="hidden" name="Claims_at_Comp_Level" ></td>
  </tr>
  --->
  <cfif request.custom_rfp_process>
    <tr class="t7h">
        <td>Non Blended Delivered Freight Matrix Excel Export</td>
        <td> </td>
        <td><input type="checkbox" value="1" name="non_blended_delivered_freight_matrix_excel_export" <cfif request.settings.non_blended_delivered_freight_matrix_excel_export eq "1">checked</cfif>></td>
    </tr>
    <tr class="t7h">
        <td>Blended Delivered Freight Matrix Excel Export</td>
        <td> </td>
        <td><input type="checkbox" value="1" name="blended_delivered_freight_matrix_excel_export" <cfif request.settings.blended_delivered_freight_matrix_excel_export eq "1">checked</cfif>></td>
    </tr>
    <tr class="t7h">
        <td>Escalator Excel Export</td>
        <td> </td>
        <td><input type="checkbox" value="1" name="escalator_excel_export" <cfif request.settings.escalator_excel_export eq "1">checked</cfif>></td>
    </tr>
</cfif>
  <tr class="t7h">
	<td><span onmouseout="popUpTip(event,'tlettersavailable');" onmouseover="popUpTip(event,'tlettersavailable');">
		  <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>/<cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Letters Available: <img src="/images/help_small.gif" />
		  </span>
	</td>
	<td>&nbsp;
	<div id="tlettersavailable" class="tip">
		"Standard" letters was originally done for Simplot<br />
		"Custom 1" letters is for GM<br />
		"Custom 2" letters is for Hormel<br />
		"Custom 3" letters was originally done for Kraft
        <cfif request.custom_rfp_process>
            <br>"Custom RFP" letters is for Huhtamaki
        </cfif>
	</div>
	</td>
	<td align="left">
        <cfset current_letter = appSettings.getlettersavailable()>
  <select name="lettersavailable">
            <option value="1" <cfif current_letter eq 1>selected</cfif>>Standard</option>
            <option value="2" <cfif current_letter eq 2>selected</cfif>>Custom 1</option>
            <option value="3" <cfif current_letter eq 3>selected</cfif>>Custom 2</option>  <!---Hormel quote letter --->
            <option value="4" <cfif current_letter eq 4>selected</cfif>>Custom 3</option>  <!---Kraft quote letter--->
            <cfif request.custom_rfp_process>
                <option value="5" <cfif current_letter eq 5>selected</cfif>>Custom RFP</option>  <!---Huhtamaki letter--->
            </cfif>
            <option value="0" <cfif current_letter  eq 0 OR current_letter eq "">selected</cfif>>None</option>
  </select>
  </td>
  </tr>
  <tr class="t7h">
	<td>Subject for Letters(Email)
	</td>
	<td>&nbsp; </td>
	<td align="left"><input size="25" type="text" name="letterssubject" value="#appSettings.getletterssubject()#"></td>
  </tr>
  <tr class="t7h">
	<td>From Address for Letters</td>
	<td>&nbsp;</td>
	<td align="left"><input size="25" type="text" name="lettersfromemail" value="#appSettings.getlettersfromemail()#"    <cfif (request.accessstructure.user_rights_id NEQ 9999 OR request.accessstructure.Blacksmith_User NEQ 1)>readonly</cfif>></td>
  </tr>
  <tr class="t7h">
	<td>Display Cash Discount on Margin page
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Display_Cash_Discount_Margin" <cfif appSettings.getDisplayCashDiscountMargin()>checked</cfif>></td>
  </tr>
  <tr class="t7h">
	<td>Cash Discount
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="0" type="radio" name="localcostvariables" <cfif appSettings.getlocalcostvariables() eq 0>checked</cfif>> Margin target upload<br>
	  <input value="1" type="radio" name="localcostvariables" <cfif appSettings.getlocalcostvariables() eq 1>checked</cfif>> Local Cost Variables<br>
	  <input value="2" type="radio" name="localcostvariables" <cfif appSettings.getlocalcostvariables() eq 2>checked</cfif>> Customer Master
	</td>
  </tr>
  <tr class="t7h">
	<td>Customer Based Costs On
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="customerbasedcosts" <cfif appSettings.getcustomerbasedcosts()>checked</cfif>></td>
  </tr>
  <tr class="t7h">
	<td>Maximum Local Cost Vars</td>
	<td>&nbsp; </td>
	<td align="left"><input size="1" maxlength="2" type="text" name="maxlocalcostvars" value="#appSettings.getmaxlocalcostvars()#" onKeyUp="clenseText(this, '0123456789.');"></td>
  </tr>
  <tr class="t7h">
  <td>Include header while printing programs</td>
  <td>&nbsp; </td>
  <td align="left"><input  value="1" type="checkbox"  name="print_includeheader" <cfif appSettings.getprintincludeheader()>checked</cfif>></td>
</tr>
 <!--- D36100 :: MOVE 'Letters Accepted By text' SETTING TO BE AT THE TEMPLATE LEVEL
  <tr valign="top">
	<td><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Letter Name:<br>
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="text" size="25" value="#appSettings.getOperatorLetterName()#" name="Operator_Letter_Name"></td>
  </tr>
  <tr valign="top">
	<td><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Letter Name:<br>
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="text" size="25" value="#appSettings.getDistributorLetterName()#" name="Distributor_Letter_Name"></td>
  </tr>--->
  <tr class="t7h">
	<td>Display Quote Letter
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Display_Quote_Letter" <cfif appSettings.getDisplayQuoteLetter()>checked</cfif>></td>
  </tr>
  <tr class="t7h">
	<td>Remove #application.returned_customer_setting.market_label_singular# From Prgm SearchPage:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="RemoveMarketFromPgmSearchPage" <Cfif appSettings.getRemoveMarketFromPgmSearchPage() IS 1>checked</CFIF>></td>
  </tr>
  <tr class="t7h">
	<td>Check all duplicate program instance</td>
	<td>&nbsp; </td>
	<td align="left"><input  value="1" type="checkbox"  name="Check_All_Duplicate_Program" <cfif appSettings.getCheckAllDuplicateProgram()>checked</cfif>></td>
  </tr>
  <tr class="t7h">
	<td>Authority Sequence for HQ Only:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="Authority_Sequence_For_HQ_Only" <Cfif appSettings.getAuthority_Sequence_For_HQ_Only() IS 1>checked</CFIF>></td>
  </tr>
  <tr class="t7h">
	<td>Show OR Hide Groups In View Margin</td>
	<td>&nbsp; </td>
	<td align="left"><input  value="1" type="checkbox"  name="show_or_hide_groups_in_view_margin" <cfif appSettings.getShowORHideGroupsInViewMargin()>checked</cfif>></td>
  </tr>

  <tr class="t7h">
	<td>Turn off Trade #Application.PlannerLabel#</td>
	<td>&nbsp; </td>
	<td align="left"><input  value="1" type="checkbox"  name="tradeplanneroff" <cfif appSettings.gettradeplanneroff()>checked</cfif>></td>
  </tr>
  <tr class="t7h">
	<td>Turn off Approval Matrix</td>
	<td>&nbsp; </td>
	<td align="left"><input  value="1" type="checkbox"  name="approvalmatrixoff" <cfif appSettings.getapprovalmatrixoff()>checked</cfif>></td>
  </tr>
  <tr class="t7h">
	<td>Can they add/edit operators directly to our database from within Programs?(Yes = Updates database, No = Sends e-mail to op admin, Both = Does both)</td>
	<td>&nbsp; </td>
	<td align="left">
	<input value="1" type="radio" name="Allowed_to_Add_Operator" <cfif appSettings.getAllowed_to_Add_Operator() eq 1>checked</cfif>>Yes &nbsp;&nbsp;<input value="0" type="radio" name="Allowed_to_Add_Operator" <cfif appSettings.getAllowed_to_Add_Operator() eq 0>checked</cfif>>No &nbsp;&nbsp;<input value="2" type="radio" name="Allowed_to_Add_Operator" <cfif appSettings.getAllowed_to_Add_Operator() eq 2>checked</cfif>>Both
  </tr>
  <tr class="t7h">
	<td>Manually created operators are active by default?</td>
	<td>&nbsp; </td>
	<td align="left"> <select name="Created_Operators_Default_Active">
		<option value="0" <cfif appSettings.getCreated_Operators_Default_Active() EQ 0>selected</cfif>>NO</option>
		<option value="1" <cfif appSettings.getCreated_Operators_Default_Active() EQ 1>selected</cfif>>YES</option>
	  </select></td>
  </tr>
  <!--- moved below setting to email notification settings with label 18746
  <tr valign="top">
	<td>Program: Provide option to email Pricing Admin</td>
	<td>&nbsp; </td>
	<td align="left"><input  value="1" type="checkbox"  name="pgmEmailPricingAdmin" <cfif appSettings.getPgmEmailPricingAdmin()>checked</cfif>></td>
  </tr>
  --->
  <!--- Removed with label 19409, set DEFAULT TO OFF
  <tr valign="top">
	<td>Billback: Restrict route user list based on position</td>
	<td>&nbsp; </td>
	<td align="left"><input  value="1" type="checkbox"  name="BBRestrictRouteUserList" <cfif appSettings.getBBRestrictRouteUserList()>checked</cfif>></td>
  </tr>
  --->
  <tr class="t7h">
	<td>Common Access URL Prefix (default: leave empty)</td>
	<td>&nbsp; </td>
	<td align="left"><input type="text" size="25" maxlength="225" value="#appSettings.getCommonAccessURLPrefix()#" name="commonAccessURLPrefix"></td>
  </tr>
  <tr class="t7h">
	<td>Program: 'Like' product available</td>
	<td>&nbsp; </td>
	<td align="left"><input  value="1" type="checkbox"  name="pgmLikeProductCheckbox" <cfif appSettings.getPgmLikeProductCheckbox()>checked</cfif>></td>
  </tr>
  <tr class="t7h">
	<td> <span onmouseout="popUpTip(event,'tRetainRSPcopy');" onmouseover="popUpTip(event,'tRetainRSPcopy');">
	  Retain original RSP for copy <img src="/images/help_small.gif" />
	</span></td>
	<td>&nbsp; <div id="tRetainRSPcopy" class="tip">
		   This setting applies to Copy.  This setting will not control the logic for Mass Copy.
	</div></td>
	<td align="left"><input value="1" type="checkbox" name="retain_original_RSP_copy" <cfif appSettings.getretainoriginalRSPcopy()>checked</cfif>></td>
  </tr>
  <tr class="t7h">
	<td>Retain original RSP for revisions & roll overs
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="retain_original_RSP" <cfif appSettings.getretainoriginalRSP()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>Update RSP Daily
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="DailyRSPUpdate" <cfif appSettings.getDailyRSPUpdate()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>Show Billback Claim Mechanic popup (1 = show popup, 2 = in basic info, 0 = neither)
	</td>
	<td>&nbsp; </td>
	<td align="left">
	<input type="text" size="2" name="ClaimMech_Popup" value="#appSettings.getClaimMech_Popup()#">
	</td>
  </tr>

  <tr valign="top">
	<td>Integration Instance ID
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="#appSettings.getIntegation_Instance_ID()#" type="text" name="Integation_Instance_ID"></td>
  </tr>
  <!--- Removed with label 19969, set DEFAULT TO ON
  <tr valign="top">
	<td>Remove Help Icon
	</td>
	<td>&nbsp; </td>
		<td align="left"><input value="1" type="checkbox" name="Remove_Help_Icon" <cfif appSettings.getRemoveHelpIcon()>checked</cfif>></td>
  </tr>

  <tr valign="top">
	<td>User Fax Number
	</td>
	<td>&nbsp; </td>
		<td align="left"><input value="1" type="checkbox" name="User_Fax_Number" <cfif appSettings.getUserFaxNumber()>checked</cfif>></td>
  </tr>
  --->
  <!--- Removed with label 19409, set DEFAULT TO OFF
  <tr valign="top">
	<td>Direct Pricing On
	</td>
	<td>&nbsp; </td>
		<td align="left"><input value="1" type="checkbox" name="direct_pricing_on" <cfif appSettings.getdirectpricingon()>checked</cfif>></td>
  </tr>
  --->
  <tr valign="top">
	<td>Vendor Selection as first and final step in payment request
	</td>
	<td>&nbsp; </td>
		<td align="left"><input value="1" type="checkbox" name="Vendor_Selection_Pay_Req" <cfif appSettings.getVendor_Selection_Pay_Req()>checked</cfif>></td>
  </tr>

  <tr valign="top">
	<td>Billback: skip vendor selection on approval, if BB already has vendor associated to it.</td>
	<td>&nbsp; </td>
		<td align="left"><input value="1" type="checkbox" name="Skip_Vendor_Selection_On_BB_Approval" <cfif appSettings.getSkipVendorSelectionOnBBApproval()>checked</cfif>></td>
  </tr>

  <tr valign="top">
	<td>Billback: Payment Request without vendor selection
	</td>
	<td>&nbsp; </td>
		<td align="left"><input value="1" type="checkbox" name="Billback_Payment_Request_Without_Vendor_Selection" <cfif appSettings.getBillback_Payment_Request_Without_Vendor_Selection()>checked</cfif>></td>
  </tr>
<!--- 76132 Enhancement: Set BB to Paid after Prepare Check Request START --->
  <tr valign="top">
  <td>Billback: Set to paid after approved
  </td>
  <td>&nbsp; </td>
    <td align="left"><input value="1" type="checkbox" name="Billback_Set_Paid_After_Approved"  <cfif request.settings.Billback_Set_Paid_After_Approved eq '1'>checked</cfif>></td>
  </tr>
<!--- 76132 Enhancement: Set BB to Paid after Prepare Check Request END --->
  <tr valign="top">
	<td>Vendor Batching
	</td>
	<td>&nbsp; </td>
		<td align="left"><input value="1" type="checkbox" name="Vendor_Batching" <cfif request.settings.Vendor_Batching eq '1'>checked</cfif>></td>
  </tr>

	<!--- Removed with label 19409, set DEFAULT TO OFF   --->
	<!--- D32285 : Manually Set BB Status to Paid --->
  <tr valign="top">
	<td>Mass Billback Payment Options (0 = off, 1 = payment request to paid, 2 = request for approval to paid, 3 = RFA and approved to paid)<br>
	NOTE: 2 & 3 does not execute deviations, send emails, check for vendor settings, or check for other permissions before paying. Do not use with robust billback applications. Also, do not use for any billback installation that executes payment. This only updates status.
	</td>
	<td>&nbsp; </td>
	<td align="left">
	<input type="text" size="2" name="Mass_Pay_Billback" value="#appSettings.getMass_Pay_Billback()#">
	</td>
  </tr>

<!---  <input type="hidden" name="Mass_Pay_Billback" value="#appSettings.getMass_Pay_Billback()#">--->

  <tr valign="top">
	<td>Billback Quick Pay</td>
	<td>&nbsp;</td>
	<td>
	  <select name="BB_Quick_Pay">
		<option value="0" <cfif appSettings.getBillbackQuickPay() EQ 0>SELECTED</cfif>>OFF</option>
		<option value="1" <cfif appSettings.getBillbackQuickPay() EQ 1>SELECTED</cfif>>RFA</option>
		<option value="2" <cfif appSettings.getBillbackQuickPay() EQ 2>SELECTED</cfif>>Approved</option>
		<option value="3" <cfif appSettings.getBillbackQuickPay() EQ 3>SELECTED</cfif>>RFA & Approved</option>
	  </select>
	</td>
  </tr>
  <tr valign="top">
	<td>Apply RSP Filters:<br>
	RSP = Responsible Sales Person
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Apply_RSP_Filters" <cfif appSettings.getApplyRSPFilters()>checked</cfif>></td>
  </tr>
  <!--- D19668: Volume Applicator Upgrade - misc changes
  Program Groups: Level 3 is exclusion, Level 3 products will not be included in volume
  Will be defaulted to 1 and will no longer be editable
  --->
  <!---
  <tr valign="top">
	<td>Program Groups: Level 3 is exclusion:<br>
	Level 3 products will not be included in volume
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="pgmGrpLevel3IsExclusion" <cfif appSettings.getPgmGrpLevel3IsExclusion()>checked</cfif>></td>
  </tr>
  --->

  <tr valign="top">
	<td>Billback Reference Number Max Length
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="#appSettings.getBB_Ref_Num_Max_Length()#" type="text" name="BB_Ref_Num_Max_Length"></td>
  </tr>

  <tr valign="top">
	<td>Billback Second Reference Number (non unique) Max Length
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="#appSettings.getBB_2Ref_Num_Max_Length()#" type="text" name="BB_2Ref_Num_Max_Length"></td>
  </tr>


	<tr valign="top">
	<td>Populate 180 Day Table From
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <select name="Populate_180Day_From">
		<option value="0" <cfif appSettings.getPopulate_180Day_From() eq 0>selected</cfif>>Invoice</option>
		<option value="1" <cfif appSettings.getPopulate_180Day_From() eq 1>selected</cfif>>Item Master</option>
	  </select>
	</td>
  </tr>
  <tr valign="top">
	<td>Letters Company Logo Path
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="#appSettings.getletterscompanylogopath()#" type="text" name="letters_company_logo_path"></td>
  </tr>
  <tr valign="top">
	<td>Reassign Analyst while Changing the Pay-To:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="DD_Reassign_Analyst_While_Changing_Pay_To" <cfif appSettings.getDDReassignAnalystWhileChangingPayTo()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>Proposal Components On:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="BidRequest_Components_On" <cfif appSettings.getBidRequestComponentsOn()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>Allow DD Assignment Based On Ship To:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="DD_Assignment_Based_On_Shr_Ship_to" <cfif appSettings.getDDAssignmentBasedOnShrShipto()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>Allow Credits (Deductions with negative Amount):
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="DD_Allow_Negative_Amount_Credits" <cfif appSettings.getDDAllowNegativeAmountCredits()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>Show Lumpsum Distributors:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Lumpsum_Distributors" <cfif appSettings.getLumpSumDistributors()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>HQ positions On:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="HQpositionsOn" <cfif appSettings.getHQpositionsOn()>checked</cfif>></td>
  </tr>
  <!--- Removed with label 19409, set DEFAULT TO OFF
  <tr valign="top">
	<td>Show Billback Routing information:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Show_BB_Route" <cfif appSettings.getShow_BB_Route()>checked</cfif>></td>
  </tr>
  --->
  <tr valign="top">
	<td>Change default Classification before RFA a Deduction:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="DD_Change_Classification_Before_RFA" <cfif appSettings.getDDChangeClassificationBeforeRFA()>checked</cfif>></td>
  </tr>
  <!--- Removed with label 20876, no longer use it with our new volume tool in 6.0 release
  <tr valign="top">
	<td>Program Volume: Divide program volume between products/groups for group programs:
	<br>(0 = Manually spread vol, 1 = Auto div vol, min 1 UOM/prod, 2 = 2 options for vol allocation and option for product/group level)
	</td>
	<td>&nbsp; </td> <!--- Dev Note: KAL; 8337 --->
	<td align="left"><input type="text" size="2" maxlength="1" name="DivideProgramVolumeForGroups" value="#appSettings.getDivideProgramVolumeForGroups()#" onkeypress="javaScript: return Allow_Key_List('012');"></td>
  </tr>
  --->
  <!---
  <tr valign="top">
	<td>Program Volume: Show groups for group program:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="ProgramVolumeShowGroups" <cfif appSettings.getProgramVolumeShowGroups()>checked</cfif>></td>
  </tr>
  --->
  <tr valign="top">
	<td>GAUGE<SUP style="font-size:10px">SM</SUP> (Crucible) On:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="crucibleOn" <cfif appSettings.getCrucibleOn()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>Broker and Trade Questions:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="brokerTradeQuestOn" <cfif appSettings.getBrokerTradeQuestOn()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>Show Program Category:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="ProgramCategory" <cfif appSettings.getProgramCategory()>checked</cfif>></td>
  </tr>
	<tr valign="top">
	<td>Pullbacks On:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="PullbacksOn" <cfif appSettings.getPullbacksOn()>checked</cfif>></td>
  </tr>
  <!--- <tr valign="top">
	<td>Pullbacks Label:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="text" name="pullbackLabel" value="#appSettings.getPullbackLabel()#" maxlength="50"></td>
  </tr> --->
    <tr valign="top">
    <td>Recapture By Operator (multiple lists) & template selection</td>
    <td>&nbsp; </td>
    <td align="left"><input value="1" type="checkbox" name="Recapture_By_Operator_For_Multiple_Lists"  <cfif request.settings.Recapture_By_Operator_For_Multiple_Lists eq '1'>checked</cfif>></td>
   </tr>
  <!--- Dev Note: Milan; 8469/9879  --->
  <!--- Removed with label 19409, set DEFAULT TO OFF
  <tr valign="top">
	<td>Turn Off Login & Password Change Screens:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="ConfidentialityAgreementStatus" <cfif appSettings.getConfidentialityAgreementStatus()>checked</cfif>></td>
  </tr>
  --->
  <!--- Removed with label 19969, set DEFAULT TO OFF
  <!--- Dev Note: Milan; 9879 --->
  <tr valign="top">
	<td>Turn Off Password Requirements Message:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="PasswordRequirementsStatus" <cfif appSettings.getPasswordRequirementsStatus()>checked</cfif>></td>
  </tr>
  --->
  <!--- Dev Note: Milan; 8482 --->
  <tr valign="top">
	<td>Remote Events Email:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="#appSettings.getRemoteEventsEmail()#" type="text" name="RemoteEventsEmail"></td>
  </tr>
  <!--- Dev Note: Milan; 8516 --->
  <!--- Removed with label 19409, set DEFAULT TO OFF
  <tr valign="top">
	<td>Operator/Distributor on Program ScoreCard:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="0" type="radio" name="show_operator_distributor" <cfif appSettings.getProgramScoreCard() eq 0>checked</cfif>>None &nbsp;&nbsp;<input value="1" type="radio" name="show_operator_distributor" <cfif appSettings.getProgramScoreCard() eq 1>checked</cfif>>Operator &nbsp;&nbsp;<input value="2" type="radio" name="show_operator_distributor" <cfif appSettings.getProgramScoreCard() eq 2>checked</cfif>>Operator & Distributor</td>
  </tr>
  --->
  <!--- Dev Note: Milan; 8521 --->
  <!--- Removed with label 19409, set DEFAULT TO OFF
  <tr valign="top">
	<td>Show Billback Excel Report:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Show_BB_Excel_Report" <cfif appSettings.getShowBBExcelReport()>checked</cfif>></td>
  </tr>
  --->
  <tr valign="top">
	<td>Manual Billback:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="ShowManualBillback" <cfif appSettings.getShowManualBillback()>checked</cfif>></td>
  </tr>
  <!--- Removed with label 19409, set DEFAULT TO OFF
  <tr valign="top">
	<td>Auto BillBack:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="ShowAutoBillback" onClick="if(this.checked == true){document.all.AutoBBType.style.display=''}else{document.all.AutoBBType.style.display='none'}"<cfif appSettings.getShowAutoBillback()>checked</cfif>></td>
  </tr>
  --->
  <tr valign="top" ID="AutoBBType" <cfif appSettings.getShowAutoBillback() eq 0>style="display:none"</cfif>>
	<td>Auto BillBack Type:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="0" type="radio" name="AutoBillbackType" <cfif appSettings.getAutoBillBackType() eq 0>checked</cfif>> Partial Auto&nbsp;&nbsp;<input value="1" type="radio" name="AutoBillbackType" <cfif appSettings.getAutoBillBackType() eq 1>checked</cfif>> Full Auto</td>
  </tr>
  <tr valign="top">
	<td>Display Interface Flags Set 1 (Mccain):
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="displayInterfaceFlagsSet1" <cfif appSettings.getDisplayInterfaceFlagsSet1()>checked</cfif>></td>
  </tr>
  <tr valign="top"><!--- Dev Note: KAL; 9688 --->
	<td>Price List displayed in Right Click:<BR>
	( 0 = Off, 1 = for products, 2 = for groups and products)
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="text" name="PriceList_displayed_Right_Click" value="#appSettings.getPriceListdisplayedRightClick()#" size="2" maxlength="1" onkeypress="javaScript: return Allow_Key_List('012');"></td>
  </tr>
 <!--- REMOVED Clear Program Files,Clear Temp Files, Clear Cache, Update programs to use latest template settings for here to SETTINGS/PROGRAMS/SETTINGS Label #29226--->
  <!--- Start 18994 --->

  <tr valign="top">
	<td>View Legacy ID
	</td>
	<td>&nbsp; </td>
	<td  colspan="3"><input value="1" type="checkbox" name="ViewLegacyID" <cfif appSettings.getView_Legacy_ID()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>Modify Legacy ID
	</td>
	<td>&nbsp; </td>
	<td  colspan="3"><input value="1" type="checkbox" name="ModifyLegacyID" <cfif appSettings.getModify_Legacy_ID()>checked</cfif>></td>
  </tr>

  <!--- <tr valign="top">
	<td>Allow user to create UnKnown Programs in Billback
	</td>
	<td>&nbsp; </td>
	<td  colspan="3"><input value="1" type="checkbox" name="BB_Allow_UnKnow_Program_Creation" <cfif appSettings.getBB_Allow_UnKnow_Program_Creation()>checked</cfif>></td>
  </tr> --->

  <!--- BJF D10724 - this option permanently turned off for everyone --->
  <input type="hidden" name="BB_Allow_UnKnow_Program_Creation" value="0">

  <tr valign="top">
	<td>Template: Restrict on group level:
	</td>
	<td>&nbsp; </td>
	<td align="left">
	<!------ Get the hroup level data ----->
	<cfset GroupDataManager = CreateObject("component", "components.products.Group.DataManager") />
	<cfset qGetGroupLevels = GroupDataManager.getProductGroupsData() />
	<select name="templateRestrictGroupLevel">
	  <cfloop query="qGetGroupLevels">
	  <option value="#Product_Group_Level_ID#" <cfif appSettings.getTemplateRestrictGroupLevel() eq Product_Group_Level_ID> selected</cfif>>#Group_Level_Desc#</option>
	  </cfloop>
	</select>
	</td>
  </tr>
  <tr valign="top">
	<td>Restrict hierarchy levels on class code:(eg: 5,6)
	</td>
	<td>&nbsp; </td>
	<td align="left"><input  type="text" name="restrictHierarchyLevelOnClassCode" value="#appSettings.getRestrictHierarchyLevelOnClassCode()#" /></td>
  </tr>

  <!---BJF D10783 -- option permanently turned off for everyone --->
  <!--- <tr valign="top">
	<td>Allow UnKnown Payee In Billback
	</td>
	<td>&nbsp; </td>
	<td  colspan="3"><input value="1" type="checkbox" name="Allow_UnKnown_Payee_In_Billback" <cfif appSettings.getAllowUnKnownPayeeInBillback()>checked</cfif>></td>
  </tr> --->

  <input type="hidden" name="Allow_UnKnown_Payee_In_Billback" value="0">

  <tr valign="top">
	<td>Hide invalid component types within Billbacks
	</td>
	<td>&nbsp; </td>
	<td  colspan="3"><input value="1" type="checkbox" name="Hide_Invalid_Component_Types_In_Billbacks" <cfif appSettings.getHideInvalidComponentTypesInBillbacks()>checked</cfif>></td>
  </tr>

  <!---  D31378:Add Program w/o Payee Components don't display --->
	<tr valign="top">
	 <td>Billback - display all components (regardless of pays to):</td>
	  <td>&nbsp; </td>
	  <td align="left">
		<input value="1" type="checkbox" name="Billback_Display_All_Program_Components" <cfif appSettings.getBillbackDisplayAllProgramComponents() EQ 1>checked</cfif>>
	  </td>
	</tr>

  <tr valign="top">
	<td>Billback scorecard cache on (default=on)
	</td>
	<td>&nbsp; </td>
	<td  colspan="3"><input value="1" type="checkbox" name="billbackScorecardCache" <cfif appSettings.getBillbackScorecardCache()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>Deduction scorecard cache on (default=on)
	</td>
	<td>&nbsp; </td>
	<td  colspan="3"><input value="1" type="checkbox" name="deductionScorecardCache" <cfif request.settings.deductionScorecardCache eq '1'>checked</cfif>></td>
  </tr>

  <tr class="t2h">
	<td>Program scorecard cache on (default=on)
	</td>
	<td>&nbsp; </td>
	<td  colspan="3"><input value="1" type="checkbox" name="programScorecardCache" <cfif appSettings.getProgramScorecardCache()>checked</cfif>></td>
  </tr>
	<!--- D17674 [begin] RBL 12/08/08 --->
  <tr class="t2h">
	<td>Project scorecard cache on (default=on)
	</td>
	<td>&nbsp; </td>
	<td  colspan="3"><input value="1" type="checkbox" name="projectScorecardCache" <cfif appSettings.getProjectScorecardCache()>checked</cfif>></td>
  </tr>
	<!--- D17674 [end] RBL 12/08/08 --->

  <tr class="t2h">
	<td>Should we use a different address to send emails? If yes, what?
	    <br>
	    <br>
	    Use this email for Program Letters
	</td>
	<td>&nbsp; </td>
    <td colspan="3">
        <input value="1" type="checkbox" name="Use_Different_From_Address"   <cfif appSettings.getUse_Different_From_Address()>checked</cfif> <cfif (request.accessstructure.user_rights_id NEQ 9999 OR request.accessstructure.Blacksmith_User NEQ 1)> readonly onclick="return false;"</cfif>>
	    <br>
	    <input type="text" name="Different_From_Address" value="#appSettings.getDifferent_From_Address()#" <cfif (request.accessstructure.user_rights_id NEQ 9999 OR request.accessstructure.Blacksmith_User NEQ 1)> readonly onclick="return false;"</cfif>>
		<span id="email_program_letter_2">
	    <br>
	    <input value="1" type="checkbox" name="Use_this_email_for_Program_Letters" <cfif request.settings.Use_this_email_for_Program_Letters eq '1'>checked</cfif> <cfif (request.accessstructure.user_rights_id NEQ 9999 OR request.accessstructure.Blacksmith_User NEQ 1)> readonly onclick="return false;"</cfif>>
	    </span>
	</td>
  </tr>

  <tr class="t2h">
	<td>Turn on Big Billbacks
	</td>
	<td>&nbsp; </td>
	<td  colspan="3"><input value="1" type="checkbox" name="Use_Big_Billbacks" <cfif appSettings.getUse_Big_Billbacks()>checked</cfif>>

</td>
  </tr>

  <tr class="t2h">
	<td>Billback Closing Method is Deduction By Default
	</td>
	<td>&nbsp; </td>
	<td  colspan="3"><input value="1" type="checkbox" name="Billback_Closing_Method" <cfif appSettings.getBillbackClosingMethod()>checked</cfif>></td>
  </tr>
  <tr class="t2h">
	<td>Show additional fields on fixed price page (List Price, Discount,Discount %)
	</td>
	<td>&nbsp; </td>
	<td  colspan="3"><input value="1" type="checkbox" name="showfixedprice_additionalfields" <cfif appSettings.getshowfixedpriceadditionalfields()>checked</cfif>></td>
  </tr>
  <tr class="t2h">
	<td>Show additional fields on rebate page (List Price, Discount,Discount %)
	</td>
	<td>&nbsp; </td>
	<td  colspan="3"><input value="1" type="checkbox" name="showrebate_additionalfields" <cfif appSettings.getshowrebateadditionalfields()>checked</cfif>></td>
  </tr>
  <tr class="t2h">
	<td>Enable View Program Page ERP Deal ID Pop Up Link
	</td>
	<td>&nbsp; </td>
	<td  colspan="3"><input value="1" type="checkbox" name="ERP_Deal_ID_PopUp" <cfif appSettings.getERP_Deal_ID_PopUp()>checked</cfif>></td>
  </tr>
  <tr class="t2h">
	<td>EZ Button On
	</td>
	<td>&nbsp; </td>
	<td  colspan="3"><input value="1" type="checkbox" name="app_EZButton_On" <cfif appSettings.getappEZButtonOn()>checked</cfif>></td>
  </tr>
  <tr class="t2h">
	<td>Suppress Groups With Zero Items
	</td>
	<td>&nbsp; </td>
	<td  colspan="3"><input value="1" type="checkbox" name="suppress_groups_zero_items" <cfif appSettings.getSuppressGroupsZeroItems()>checked</cfif>></td>
  </tr>
  <tr class="t2h">
	<td>
	  Suppress Business Considerations:
	  <span style="font-style:italic">
		Don't display Business Considerations during<br />
		approval if they don't exist.
	  </span>
	</td>
	<td>&nbsp; </td>
	<td  colspan="3">
	  <input value="1" type="checkbox" name="suppress_business_considerations" <cfif appSettings.getSuppressBusinessConsiderations()>checked</cfif>>&nbsp;For Programs<br />
	  <input value="1" type="checkbox" name="Suppress_Billback_Business_Considerations" <cfif appSettings.getSuppressBillbackBusinessConsiderations()>checked</cfif>>&nbsp;For Billbacks
	</td>
  </tr>
  <tr class="t2h">
	<td>DD_Show_reassign:
	</td>
	<td>&nbsp; </td>
	<td  colspan="3"><input value="1" type="checkbox" name="DD_Show_reassign" <cfif appSettings.getDD_Show_reassign()>checked</cfif>></td>
  </tr>

  <tr class="t2h">
	<td>DD_Show_Classification:
	</td>
	<td>&nbsp; </td>
	<td  colspan="3"><input value="1" type="checkbox" name="DD_Show_Classification" <cfif appSettings.getDD_Show_Classification()>checked</cfif>></td>
  </tr>
  <!---26487--->
  <tr class="t2h">
	<td>DD_Show_DeductionType:
	</td>
	<td>&nbsp; </td>
	<td  colspan="3"><input value="1" type="checkbox" name="DD_Show_DeductionType" <cfif appSettings.getDD_Show_DeductionType()>checked</cfif>></td>
  </tr>
  <tr class="t2h">
	<td>DD_Show_User_References
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="DD_User_Reference" <cfif appSettings.getDD_User_Reference()>checked</cfif>></td>
  </tr>
  <tr class="t2h">
	<td>DD_Show_Edit_Customer_Num:
	</td>
	<td>&nbsp; </td>
	<td  colspan="3"><input value="1" type="checkbox" name="DD_Show_Edit_Customer_Num" <cfif appSettings.getDD_Show_Edit_Customer_Num()>checked</cfif>></td>
  </tr>
  <!---
  <tr valign="top">
	<td>DD_Show_Write_Off:
	</td>
	<td>&nbsp; </td>
	<td  colspan="3"><input value="1" type="checkbox" name="DD_Show_Write_Off" <cfif appSettings.getDD_Show_Write_Off()>checked</cfif>></td>
  </tr> --->
  <tr class="t2h">
	<td>DD_Show_Create_Adjustment:
	</td>
	<td>&nbsp; </td>
	<td  colspan="3"><input value="1" type="checkbox" name="DD_Show_Create_Adjustment" <cfif appSettings.getDD_Show_Create_Adjustment()>checked</cfif>></td>
  </tr>

  <!--- D29481:Non trade deductions START --->
  <tr class="t2h">
	<td>DD_Allow_Non_Trade:
	</td>
	<td>&nbsp; </td>
	<td  colspan="3"><input value="1" type="checkbox" name="DD_Allow_Non_Trade" <cfif appSettings.getDD_Allow_Non_Trade()>checked</cfif>></td>
  </tr>
	<!--- D29481:Non trade deductions END --->

  <!--- D75545 :: Create new app setting to make reference field in deductions editable START --->
  <tr class="t2h">
    <td>DD_Edit_Reference: </td>
    <td>&nbsp; </td>
    <td  colspan="3">
      <input value="1" type="checkbox" name="DD_Edit_Reference" <cfif request.settings.DD_Edit_Reference eq '1'>checked</cfif>>
    </td>
  </tr>
  <!--- D75545 :: Create new app setting to make reference field in deductions editable END --->

<tr class="t2h">
	<td>Deduction - "Keep it Open" available in match central:</td>
	<td>&nbsp; </td>
	<td  colspan="3"><input value="1" type="checkbox" name="DD_Match_Central_Keep_It_Open" <cfif request.settings.DD_Match_Central_Keep_It_Open eq "1">checked</cfif>></td>
  </tr>
	<!--- 98259 :: Auto Reconcile Logic - Update to Match Central Write-off Feature START--->
	<tr class="t2h">
		<td>Deduction - "Write Off" available in match central:</td>
		<td>&nbsp; </td>
		<td  colspan="3"><input value="1" type="checkbox" name="DD_Match_Central_Write_Off" <cfif request.settings.DD_Match_Central_Write_Off eq "1">checked</cfif>></td>
	</tr>
	<!--- 98259 :: Auto Reconcile Logic - Update to Match Central Write-off Feature END--->
	<!---  D45778 :Auto Reconcile BB's closed to deduction in 1500  --->
	<tr valign="top">
		<td><span onmouseout="popUpTip(event,'tAuto_Reconcile_Match_Central_BB');" onmouseover="popUpTip(event,'tAuto_Reconcile_Match_Central_BB');">
	 Auto Reconcile BB's closed to Deduction in Match central:<img src="/images/help_small.gif" />
			 </span></td>
	 <td>&nbsp; <div id="tAuto_Reconcile_Match_Central_BB" class="tip">
			 This setting requires "Split Billbacks" to be ON.  When "Auto reconcile" is enabled, Billbacks that are closed to deductions in Match central will get reconciled to the Deductions that are getting closed so that the BB amount equals the Deduction Amount.  The result is that no remainder is left on the BB.
	 </div></td>
	 <td align="left"><input value="1" type="checkbox" name="Auto_Reconcile_Match_Central_BB" <cfif appSettings.getAuto_Reconcile_Match_Central_BB()>checked</cfif>></td>
	 </tr>
<!--- D42284 :: Rebill vs closed deduction reopened START--->

  <tr class="t2h">
	<td><span onmouseout="popUpTip(event,'tReOpenInterface');" onmouseover="popUpTip(event,'tReOpenInterface');"> Reopen does not interface:  <img src="/images/help_small.gif" /> </span></td>
	<td>&nbsp; <div id="tReOpenInterface" class="tip">When "Reopen does not interface" is OFF: Deduction will be locked after reopen until the deduction reopen has interfaced successfully and is acknowledged.<br>When "Reopen does not interface" is ON: Deduction will remain editable after reopen. </div>
 </td>
	<td  colspan="3"><input value="1" type="checkbox" name="DD_Reopen_Interface" <cfif appSettings.getDD_Reopen_Interface()>checked</cfif>></td>
  </tr>

<!--- D42284 :: Rebill vs closed deduction reopened END --->

  <!--- BJF D11908 - hide this setting and permanently turn off --->
   <!--- 29338/Anand Rao/28-Nov-2011 - UnHide the appsetting as per Karen --->
  <tr class="t2h">
	<td>
	  Allow programs to be submitted for approval if Operator ID is not active:
	</td>
	<td>&nbsp;</td>
	<td  colspan="3"> <input value="1" type="checkbox" name="Program_Approval_For_Inactive_Operators" <cfif appSettings.getProgramApprovalForInactiveOperators()>checked</cfif>>
	<!--- <input value="0" type="hidden" name="Program_Approval_For_Inactive_Operators"> --->
  </td>
  </tr>
  <!---BJF D11147 --->
  <tr class="t2h">
	<td>
	  Restrict components by product criteria:
	</td>
	<td>&nbsp;</td>
	<td  colspan="3">
	<select name="Component_Product_Restrictions_On">
		<option value="0" <cfif appSettings.getComponent_Product_Restrictions_On() EQ 0>selected</cfif>>OFF</option>
		<option value="1" <cfif appSettings.getComponent_Product_Restrictions_On() EQ 1>selected</cfif>>ON</option>
	  </select>
	</td>
  </tr>
  <tr class="t2h">
	<td>Display Data Integration Viewer:</td> <!---  Dev Note:  MarkS 10729 --->
	<td>&nbsp; </td>
	<td  colspan="3"><input value="1" type="checkbox" name="Data_Int_Viewer" <cfif appSettings.getDataIntViewer()>checked</cfif>></td>
  </tr>
  <tr class="t2h">
	<td>Billback Fixed Price Deviation Uses Lower Of Invoice And Price List:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="BB_Fixed_Calc_Types_On" <Cfif appSettings.getBBFixedCalcTypesOn() IS 1>checked</CFIF>></td>
  </tr>
  <tr class="t2h">
	<td>Billback Fixed Price Deviation Use Invoice Price:</td> <!---  Dev Note:  MarkS 11127 --->
	<td>&nbsp; </td>
	<td  colspan="3">
	  <input value="0" type="radio" name="BB_Deviation_Use_Max_Price" <cfif appSettings.getBBDeviationUseMaxPrice() eq 0>checked</cfif>>Default
	  <input value="1" type="radio" name="BB_Deviation_Use_Max_Price" <cfif appSettings.getBBDeviationUseMaxPrice() eq 1>checked</cfif>>Max
	  <input value="2" type="radio" name="BB_Deviation_Use_Max_Price" <cfif appSettings.getBBDeviationUseMaxPrice() eq 2>checked</cfif>>Min
	</td>
  </tr>
  <tr class="t2h">
	<td>Modify Agree Billback:</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Billback_Modify_Agree" <cfif appSettings.getBillbackModifyAgree()>checked</cfif>></td>
  </tr>
  <!---77242 :: BB - Disable pages in RFA, reset to make changes--->
  <tr class="t2h">
  <td>Billback - Disable pages in RFA, reset to make changes:</td>
  <td>&nbsp; </td>
  <td align="left"><input value="1" type="checkbox" name="Billback_Disable_Pages_RFA" <cfif request.settings.Billback_Disable_Pages_RFA eq '1'>checked</cfif>></td>
  </tr>
  <!---77242 :: BB - Disable pages in RFA, reset to make changes--->
  <!--- Removed with label 19409, set DEFAULT TO OFF
  <tr valign="top"> <!--- Dev Note: KAL D11049  --->
	<td>Apply only Accrual Programs for #appsettings.getPullbackLabel()#:</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="OnlyAccrualTPA_Pullbacks" <cfif appSettings.getOnlyAccrualTPAPullbacks()>checked</cfif>></td>
  </tr>
  --->
  <tr class="t2h">
	<td>Interface 700 to client:(default=off)</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Interface_700_To_Client" <cfif appSettings.getInterface_700_To_Client()>checked</cfif>></td>
  </tr>
  <!--- Dev Note: Milan D11495 Lamb Export - Sales Agreement Application --->
  <tr class="t2h">
	<td>Show Export Programs:</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Show_Export_Programs" <cfif appSettings.getShowExportPrograms()>checked</cfif>></td>
  </tr>
  <tr class="t2h">
	<td>Allow BB Closing Method - Off Invoice:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="BB_Allow_Off_Invoice_Closing_Method" <cfif appSettings.getBB_Allow_Off_Invoice_Closing_Method()>checked</cfif>></td>
  </tr>
  <tr class="t2h">
	<td>Interface Buying Group as a group to the client:</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Interface_BuyingGroup_As_Group_To_Client" <cfif appSettings.getInterface_BuyingGroup_As_Group_To_Client()>checked</cfif>></td>
  </tr>
  <tr class="t2h">
	<td>Budgets Functionality On:</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="BudgetsFunctionalityOn" <cfif appSettings.getBudgetsFunctionalityOn()>checked</cfif>></td>
  </tr>
  <tr class="t2h">
	<td>Budget selection required in program:</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="BudgetSelectionRequired" <cfif appSettings.getBudgetSelectionRequired()>checked</cfif>></td>
  </tr>
  <tr class="t2h">
	<td>Budget - Single position level for fixed budget:</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="BudgetSingleLevelForFixed" <cfif appSettings.getBudgetSingleLevelForFixed()>checked</cfif>></td>
  </tr>
   <!--- START: 49540: App Setting - Use_Invoice_Market/Anand Rao/17-Apr-2015 --->
  <tr class="t2h">
	  <td>
	 <span onmouseout="popUpTip(event,'tInvMarket');" onmouseover="popUpTip(event,'tInvMarket');">
	Use Invoice Market for Budget Calculations: <img src="/images/help_small.gif" /></span></td>
	  <td>&nbsp; <div id="tInvMarket" class="tip">
		  <strong>When this app setting is ON</strong> - budget procedure is using the market from invoice.  The budget procedure goes to the invoice the table and for each invoice, goes to the item level and finds the market each item's invoice dollars are associated to.  Once we know which market (sales hierarchy position) the invoice dollars are credited to, we use that in calculating the budget accrual dollars for the budget the market is associated to.<br><br>
	  <strong>When this app setting is OFF</strong> - budget procedure is not using the market on the invoice, instead it finds the distributor on the invoice and determines which sales hierarchy position they roll up to (market, region, zone). Once we know which market (sales hierarchy position) the invoice dollars are credited to, those invoice dollars are used in calculating the budget accrual dollars for the budget the market is associated to.

		 </div></td>
	  <td align="left">
	<input value="1" type="checkbox" name="Use_Invoice_Market" <cfif appSettings.getUseInvoiceMarket() EQ 1>checked</cfif>>
	  </td>
  </tr>
  <!--- END: 49540: App Setting - Use_Invoice_Market--->
  <tr class="t2h">
	<td>Budget - Participation:</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Budget_Participation" <cfif request.settings.Budget_Participation eq '1'>checked</cfif>></td>
  </tr>
  <tr class="t2h">
	<td>Budget - Overlay:</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Budget_Overlay" <cfif request.settings.Budget_Overlay eq '1'>checked</cfif>></td>
  </tr>
  <tr class="t2h">
	<td>
	  Billback: Allow Multiple Budgets
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="BillbackAllowMultipleBudgets" <cfif appSettings.getBillbackAllowMultipleBudgets()>checked</cfif>>
	</td>
  </tr>
  <!---64149 :: Create new accrual budget process START--->
    <tr class="t2h">
	<td>
	  Accrual budgets calculation by client
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="Accrual_Budgets_Calculation_By_Client" <cfif request.settings.Accrual_Budgets_Calculation_By_Client eq '1'>checked</cfif>>
	</td>
  </tr>
 <!--- 64149 :: Create new accrual budget process END--->
  <tr class="t2h">
	<td>Populate Item Margin Target (IMT) OR Gross Margin (GM) using Price List:</td>
	<td>&nbsp; </td>
	<td align="left">
	  <select name="ItemMarginTarget_OR_GrossMargin_For_PriceList">
		  <option value="4" <cfif appSettings.getItemMarginTargetORGrossMarginForPriceList() eq 4>selected</cfif>>Both (IMT from default price list only)</option>
		  <option value="3" <cfif appSettings.getItemMarginTargetORGrossMarginForPriceList() eq 3>selected</cfif>>Both</option>
		  <option value="2" <cfif appSettings.getItemMarginTargetORGrossMarginForPriceList() eq 2>selected</cfif>>Item Margin Target</option>
		  <option value="1" <cfif appSettings.getItemMarginTargetORGrossMarginForPriceList() eq 1>selected</cfif>>Gross Margin</option>
		  <option value="0" <cfif appSettings.getItemMarginTargetORGrossMarginForPriceList() eq 0>selected</cfif>>None</option>
	  </select></td>
  </tr>

  <!--- 13428 5.0 only --->
  <tr class="t2h">
	<td>#Application.GLAccountLabel# On:</td><!--- D42774 --->
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="GL_Account_On" <Cfif appSettings.getGL_Account_On() IS 1>checked</CFIF>></td>
  </tr>
  <tr class="t2h">
	<td>#Application.GLAccountLabel# Required for Comp:</td><!---D42774 --->
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="GL_Account_Required_for_Comp" <Cfif appSettings.getGL_Account_Required_for_Comp() IS 1>checked</CFIF>></td>
  </tr>

  <tr class="t2h">
	<td>Require exact match for list tool results:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="Exact_List_Matching_On" <Cfif appSettings.getExact_List_Matching_On() IS 1>checked</CFIF>></td>
  </tr>
  <tr class="t2h">
	<td>Auto Deviation (run all) On:
	</td>
	<td>&nbsp; </td>
	<td  colspan="3"><input value="1" type="checkbox" name="Auto_Deviation_On" <cfif appSettings.getAuto_Deviation_On()>checked</cfif>></td>
  </tr>
  <tr class="t2h">
	<td>
	  Don't allow new components to be added on revision:
	</td>
	<td>&nbsp;</td>
	<td  colspan="3"><input value="1" type="checkbox" name="Disable_Adding_Components_On_Revision" <cfif appSettings.getDisableAddingComponentsOnRevision()>checked</cfif>></td>
  </tr>
  <tr class="t2h">
	<td>
	  View Delete Records:
	</td>
	<td>&nbsp;</td>
	<td  colspan="3"><input value="1" type="checkbox" name="View_Delete_Records" <cfif appSettings.getViewDeleteRecords()>checked</cfif>></td>
  </tr>
  <tr class="t2h">
	<td>
	  Program: Claim rates report available:
	</td>
	<td>&nbsp;</td>
	<td  colspan="3"><input value="1" type="checkbox" name="Program_Claim_Rates_Report_Available" <cfif appSettings.getProgramClaimRatesReportAvailable()>checked</cfif>></td>
  </tr>
  <tr class="t2h">
	<td>
	  Program: Claim rates report - exclude regular prices (exclude regular price list and item margin targets):
	</td>
	<td>&nbsp;</td>
	<td  colspan="3"><input value="1" type="checkbox" name="Program_Claim_Rates_Report_Exclude_Regular_Prices" <cfif appSettings.getProgramClaimRatesReportExcludeRegularPrices()>checked</cfif>></td>
  </tr>
  <tr class="t2h">
	  <td>
	 <span onmouseout="popUpTip(event,'tClaimRatesAggRebateRates');" onmouseover="popUpTip(event,'tClaimRatesAggRebateRates');">
	Program: Claim rates report - Aggregate rebate rates at product level <img src="/images/help_small.gif" /></span></td>
	  <td>&nbsp; <div id="tClaimRatesAggRebateRates" class="tip">
	   As an example – <br />
	Program has 1 rebate product and 2 rebate components. <br />
	If the rate for component 1 is $1 and component 2 is $2, only 1 entry would be shown where rebate rate is $3 ($1 + $2).
	</div></td>
	<td  colspan="3"><input value="1" type="checkbox" name="Prg_Claim_Rates_Report_Agg_Rates_At_Product_Level" <cfif val(request.settings.Prg_Claim_Rates_Report_Agg_Rates_At_Product_Level)>checked</cfif>></td>
  </tr>
  <tr class="t7h">
	<td>BB Payee page, display these payee types
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="BB_display_distributor_payee" <cfif val(request.settings.BB_display_distributor_payee)>checked</cfif>> Distributor<br>
	  <input value="1" type="checkbox" name="BB_display_operator_payee" <cfif val(request.settings.BB_display_operator_payee)>checked</cfif>> Operator<br>
	  <input value="1" type="checkbox" name="BB_display_broker_payee" <cfif val(request.settings.BB_display_broker_payee)>checked</cfif>> Broker
	</td>
  </tr>
  <tr valign="top">
	<td>
	  <!--- DEV NOTE: DAA; D16974: CHANGED FROM 'BB Approval Screen will display reason code:' --->
	  BB Approval Screen, display reason code when BB closing method - pmt:
	</td>
	<td>&nbsp;</td>
	<td  colspan="3"><input value="1" type="checkbox" name="Show_Reason_Code_On_BB_Approval_Screen" <cfif appSettings.getShowReasonCodeOnBBApprovalScreen()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>
	  BB Approval Screen, display reason code when BB closing method - ded:
	  <em style="color:red;">(Do not use if Deduction Module is on)</em>
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="ReasonCodeinBillbackDED" <cfif appSettings.ReasonCodeinBillbackDED>checked</cfif>>
	</td>
  </tr>
  <!--- Dev Notes: D23639/Anand Rao/14-Jun-10; BB reason codes --->
	<tr valign="top">
	<td>
	  BB Approval Screen, display reason code setting
	</td>
	<td>&nbsp; </td>
	<td align="left">
	<input value="1" type="radio" name="Reason_Code_in_Billback_Display_Setting" <cfif appSettings.getReasonCodeInBillbackDisplaySetting() eq 1>checked</cfif>>Always <br><input value="2" type="radio" name="Reason_Code_in_Billback_Display_Setting" <cfif appSettings.getReasonCodeInBillbackDisplaySetting() eq 2>checked</cfif>>When payment $ less than claimed $
	</td>
  </tr>
  <tr valign="top">
	<td>
	  Billback reason code: allow multiple selection:
	</td>
	<td>&nbsp;</td>
	<td  colspan="3"><input value="1" type="checkbox" name="BB_Reason_Code_Allow_Multiple" <cfif appSettings.getBBReasonCodeAllowMultiple()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>
	  Show Pricing Report:
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="ShowPricingReport" <cfif appSettings.ShowPricingReport>checked</cfif>>
	</td>
  </tr>
  <tr valign="top">
	<td>
	  BB Pymt Req Hold/Release
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="BB_Payment_Request_Hold_Release" <cfif appSettings.getBBPaymentRequestHoldRelease() eq 1>checked</cfif>>
	</td>
  </tr>
  <tr valign="top">
	<td>
	  BB Pymt Amt Within Profile’s Total Approval Amt = Approved Status
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="Approve_BB_Based_On_Profile_Total_Approval_Amount" <cfif appSettings.getApproveBBBasedOnProfileTotalApprovalAmount() eq 1>checked</cfif>>
	</td>
  </tr>
  <tr valign="top">
	<td>
	  No. of days of historical data for Special Price List:<br />
	  (This setting applies to Claim Rates, when the template setting "Fixed Price Populates Special Price List" is ON. The default value is 730 days)
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input type="text" name="DaysOfHistoricalDataForSpecialPriceList" value="#appSettings.getDaysOfHistoricalDataForSpecialPriceList()#" size="3" maxlength="3" onkeypress="javaScript: return Allow_Key_List('0123456789');" onblur="if(isNaN(parseInt(this.value)))this.value=730;if(this.value > 730){alert('You cannot enter a value higher than 730');this.focus();}">
	</td>
  </tr>
  <tr valign="top">
	<td>
	  Billback: allow reset in payment request status <U>before</U> it has interfaced in payment interface
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="BBAllowResetBeforePMTInterfacePRStatus" <cfif appSettings.getBBAllowResetBeforePMTInterfacePRStatus()>checked</cfif>>
	</td>
  </tr>
  <tr valign="top">
	<td>
	  Billback: allow reset <U>after</U> it has interfaced in deduction interface
	  <br> (Before turning this switch on, make sure there is reversal logic inside deduction interface)
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="BBAllowResetAfterDEDInterface" <cfif appSettings.getBBAllowResetAfterDEDInterface()>checked</cfif>>
	</td>
  </tr>
  <tr valign="top">
	<td>
	  Billback:  allow user to re- interface if it has been interfaced but not yet acknowledged
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="BB_Reinterface_Unacknowledged_Interface" <cfif appSettings.getBBReinterfaceUnacknowledgedInterface()>checked</cfif>>
	</td>
  </tr>
  <tr valign="top">
	<td>
	  Billback:  allow user to reset if it has been interfaced but not yet acknowledged
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="BB_Reset_Unacknowledged_Interface" <cfif appSettings.getBBResetUnacknowledgedInterface()>checked</cfif>>
	</td>
  </tr>
  <tr valign="top">
	<td>
	  Billback: set to paid status when deduction is closed
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="DD_Closed_BB_Status" <cfif appSettings.getDDClosedBBStatus()>checked</cfif>>
	</td>
  </tr>
<!---D32585 Approval e-mails sending to all TL's START --->
<tr>
  <td>BB cra considers BB assignment</td>
  <td>&nbsp; </td>
  <td><input value="1" type="checkbox" name="CRA_Consider_Analyst" <cfif appSettings.getCRAConsiderAnalyst()>checked</cfif>></td>
</tr>
<!--- D32585 Approval e-mails sending to all TL's END --->
<!---77024 :: BB Assignment - by template START--->
<tr>
  <td>BB Assignment - by template</td>
  <td>&nbsp; </td>
  <td><input value="1" type="checkbox" name="BB_Assignment_By_Template" <cfif val(request.settings.BB_Assignment_By_Template) EQ 1>checked</cfif>></td>
</tr>
<!---77024 :: BB Assignment - by template END--->
  <!--- Removed with label 19969, set DEFAULT TO OFF
  <tr valign="top">
	<td>
	  Search Selection Tracking On
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="Search_Selection_Tracking_On" <cfif appSettings.getSearch_Selection_Tracking_On()>checked</cfif>>
	</td>
  </tr>
  --->
  <tr>
	<td>
	  Pre-active program replaces parent version - except for Price Protection programs:
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="Pre_Active_Replace_Parent" <cfif appSettings.getPreActiveReplaceParent()>checked</cfif>>
	</td>
  </tr>
  <tr>
	<td>
	  Business Segments on Template:
	</td>
	<td>&nbsp;</td>
	<td align="left">
	  <input value="1" type="checkbox" name="Filter_Business_Segments" <cfif appSettings.getFilterBusinessSegments()>checked</cfif>>
	</td>
  </tr>
  <tr>
	<td>
	  Mass Copy:
	</td>
	<td>&nbsp;</td>
	<td align="left">
	  <input value="1" type="checkbox" name="Mass_Copy" <cfif appSettings.getMassCopy()>checked</cfif>>
	</td>
  </tr>
  <tr>
	<td>
	  Program Alerts:
	</td>
	<td>&nbsp;</td>
	<td align="left">
	  <input value="1" type="checkbox" name="Program_Alerts" <cfif appSettings.getProgramAlerts()>checked</cfif>>
	</td>
  </tr>
  <!--- D52449 :: Create new app settings to control Orphan Pop up Alert START--->
   <tr>
	<td>Display orphan alert on program revise : </td>
	<td>&nbsp;</td>
	<td align="left">
	  <input value="1" type="checkbox" name="Display_Orphan_Alert_Program_Revise" <cfif appSettings.getDisplayOrphanAlertProgramRevise()>checked</cfif>>
	</td>
  </tr>
   <!--- D52449 :: Create new app settings to control Orphan Pop up Alert END --->
	<!--- D50884 :: Improvements to the Rebate Page inside a Program 8.0 Release...  START--->
   <tr>
	<td>Display alert on RFA if program has 0 rate : </td>
	<td>&nbsp;</td>
	<td align="left">
	  <input value="1" type="checkbox" name="Program_Alert_On_RFA_Rate_0" <cfif appSettings.GetProgramAlertOnRFARate0()>checked</cfif>>
	</td>
  </tr>
   <!--- D50884 :: Improvements to the Rebate Page inside a Program 8.0 Release...  END --->
  <tr>
	<td>
	  Reset Won/Lost on program revision: (Default off)
	</td>
	<td>&nbsp;</td>
	<td align="left">
	  <input value="1" type="checkbox" name="Reset_Won_Lost_On_Revision" <cfif appSettings.getReset_Won_Lost_On_Revision()>checked</cfif>>
	</td>
  </tr>

  <tr>
	<td>
	  DD - Restrict Ship To for Billbacks: (Default off)
	</td>
	<td>&nbsp;</td>
	<td align="left">
	  <input value="1" type="checkbox" name="DD_Restrict_ShipTo_For_BB" <cfif appSettings.getDD_Restrict_ShipTo_For_BB()>checked</cfif>>
	</td>
  </tr>
  <tr>
	<td>
	  Operator Creation Fields Required
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="OperatorCreationFieldsRequired" <cfif appSettings.getOperator_Creation_Fields_Required() EQ 1>checked</cfif>>
	</td>
  </tr>
  <tr>
	<td>
	  Default display attribute
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <cfquery name="Product_Group_Attributes" datasource="#application.datasource#">
		  SELECT PGL.Group_Level_Desc, PGL.Product_Group_Level_ID
		  FROM Product_Group_Level PGL
			INNER JOIN Product_Group_Attribute PGA
			ON PGA.Product_Group_Level_ID = PGL.Product_Group_Level_ID
		  WHERE Product_Group_Attribute_Table IN
		  ('Type_Group_desc','Q_Brand_Desc','Type_Code_desc','Brand')
		  ORDER BY PGL.Group_Level_Desc
	  </cfquery>
	  <select name="Primary_Product_Attribute">
		<cfloop query="Product_Group_Attributes">
		  <option value="#Product_Group_Attributes.Product_Group_Level_ID#" <cfif appSettings.getPrimary_Product_Attribute() EQ Product_Group_Attributes.Product_Group_Level_ID>selected</cfif>>#Group_Level_Desc#</option>
		</cfloop>
	  </select>
	</td>
  </tr>
  <tr valign="top">
	<td>
	  Program Remote Approval via Email, including Mobile Device
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="Approval_Via_Email" <cfif appSettings.getApprovalViaEmail() EQ 1>checked</cfif>>
	</td>
  </tr>
  <tr valign="top">
	<td>
	  Billback Remote Approval via Email, including Mobile Device
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="BB_Approval_Via_Email"  <cfif request.settings.BB_Approval_Via_Email eq '1'>checked</cfif>>
	</td>
  </tr>

  <cfset renderDivider("Show Flex Search Tools")>
  <!--- Dev Note: drachala; D29074 : Add option to program search to allow user to search on GL Account  START
  Added/Changed: Took out textbox added Select--->
  <tr valign="top">
	<td  class2="topl"><span onmouseout="popUpTip(event,'tProgramSearchType');" onmouseover="popUpTip(event,'tProgramSearchType');"> Program Search <img src="/images/help_small.gif" /></span></td>
	<td class2="topm">&nbsp;
		<div id="tProgramSearchType" class="tip">
			CF = original CF program search tool <br />
			Flex = Flex program search tool. The Flex tool will be retired & should not be used after 2020 <br />
			Both = 2 search links will display:  Program Search (Flex tool) and Advance Program Search (original CF tool) <br />
			CF 2020 = Updated program search tool, replaces Flex tool <br />
			Both CF & CF 2020 =  2 search links will display: Program Search (CF 2020) and Advance Program Search (original CF tool)
		</div>
	</td>
	<td align="left" class2="topr">
	 <select name="Flex_Program_Search" onchange="showER(document.all.Flex_Program_Search.value);">
	<option value="1" <cfif appSettings.getFlexProgramSearch() EQ 1>selected</cfif>>CF</option>
	<option value="2" <cfif appSettings.getFlexProgramSearch() EQ 2>selected</cfif>>Flex</option>
	<option value="3" <cfif appSettings.getFlexProgramSearch() EQ 3>selected</cfif>>Both</option>
	<option value="4" <cfif appSettings.getFlexProgramSearch() EQ 4>selected</cfif>>CF 2020</option>
	<option value="5" <cfif appSettings.getFlexProgramSearch() EQ 5>selected</cfif>>Both CF & CF 2020</option>
   </select>
	</td>
  </tr>


  <cfset render_flex_setting( "Alias_Management_Format", "Alias Management" )>
  <cfset render_flex_setting( "BB_Deviation_Format", "Billback Deviation" )>
  <cfset render_flex_setting( "Edit_Volume_Format", "Edit Volume" )>
  <cfset render_flex_setting( "Redistribution_Format", "Redistribution" )>
  <cfset render_flex_setting( "Program_Rate_Format", "Program Rates" )>
  <cfset render_flex_setting( "EDI_Viewer_Format", "EDI Viewer",1 )>

  <!--- End Dev Note: drachala; D29074: Add option to program search to allow user to search on GL Account  --->
  <tr valign="top" id="ExpiredRecently_ID" <cfif appSettings.getFlexProgramSearch() EQ 1>style="display: none;"</cfif>>
	<td class2="left" colspan="1">
	  Expired Recently: include programs that have an end date within the last N days
	</td>
	<td>&nbsp;</td>
	<td colspan="1" align="left" class2="right"><span id="err_sp_ExpiredRecentlyDays"></span>
	  <input type="text" name="Expired_Recently_Days" id="Expired_Recently_Days" value="#appSettings.getExpiredRecentlyDays()#" size="3" maxlength="4" onkeypress="javaScript: return Allow_Key_List('0123456789');">
	</td>
  </tr>
 <!---D38043  :: Program revision dates - View Program --->
	<tr valign="top">
	<td  class2="left"> Program Search Dates</td>
	<td class="top">&nbsp; </td>
	<td align="left" class2="right">
	 <select name="Program_Search_Dates">
	<option value="0" <cfif appSettings.getProgram_search_dates() EQ 0>selected</cfif>>Version Date</option>
	<option value="1" <cfif appSettings.getProgram_search_dates() EQ 1>selected</cfif>>Delivery Date</option>
   </select>
	</td>
  </tr>
 <!---D57639 :: View all versions of programs in program search START--->
  <tr valign="top">
	<td class2="left">
		Display all versions in program search<br>
		<em style="color:red;">(*** <b>NOTE:</b> *** This will display deleted versions with Effective dates.)</em>
	</td>
	<td class="top">&nbsp; </td>
	<td align="left" class2="right"><input value="1" type="checkbox" name="Display_PGR_Versions_In_search" <cfif val(request.settings.Display_PGR_Versions_In_search) EQ 1>checked</cfif>></td>
  </tr>
<!---D57639 :: View all versions of programs in program search END--->
  <!--- 50324: Add Dollars and volume for program search --->
	<tr valign="top">
	<td  class2="left"> Program Search - Trade $/Pymt $/Vol</td>
	<td>&nbsp; </td>
	<td align="left" class2="right">
	  <input value="1" type="checkbox" name="Program_Search_Dollars_And_Volume" id="Program_Search_Dollars_And_Volume" <cfif appSettings.getProgramSearchDollarsAndVolume() EQ 1>checked</cfif>>
	</td>
  </tr>
 <!---D38043  :: Program revision dates - View Program --->
  <tr valign="top">
	<td  class2="left"> Distributor Search in Flex </td>
	<td>&nbsp; </td>
	<td align="left" class2="right">
	  <input value="1" type="checkbox" name="Flex_Distributor_Search" <cfif appSettings.getFlexDistributorSearch() EQ 1>checked</cfif>>
	</td>
  </tr>
  <tr valign="top">
	<td  class2="left"> Broker Search in Flex </td>
	<td>&nbsp; </td>
	<td align="left" class2="right">
	  <input value="1" type="checkbox" name="Flex_Broker_Search" <cfif appSettings.getFlexBrokerSearch() EQ 1>checked</cfif>>
	</td>
  </tr>
  <tr valign="top">
	<td  class2="left"> Operator Search in Flex </td>
	<td>&nbsp; </td>
	<td align="left" class2="right">
	  <input value="1" type="checkbox" name="Flex_Operator_Search" <cfif appSettings.getFlexOperatorSearch() EQ 1>checked</cfif>>
	</td>
  </tr>
  <tr valign="top">
	<td  class2="left"> Product Search in Flex </td>
	<td>&nbsp; </td>
	<td align="left" class2="right">
	  <input value="1" type="checkbox" name="Flex_Product_Search" <cfif appSettings.getFlexProductSearch() EQ 1>checked</cfif>>
	</td>
  </tr>
  <!--- End Note: KAL; D20523: App setting to turn flex search tools on/off --->
  <!--- START: 31505: App setting for Flex BB Module/Anand Rao/24-Apr-2012 --->
  <tr valign="top">
	<td  class2="left"><span onmouseout="popUpTip(event,'tBillbackModuleType');" onmouseover="popUpTip(event,'tBillbackModuleType');"> Billback Module Type <img src="/images/help_small.gif" /> </span></td>
	<td>
		&nbsp; <div id="tBillbackModuleType" class="tip">
		CF -- The standard CF billback module.  Billback pages display in CF.<br>
		GM -- The new CF billback module, to replace the custom Flex module.  This is used by General Mills.<br>
		Both -- *Do not use.  This option is only for BA Internal Use.  It was developed so we could test the billback counts between Flex and CF pages*
		</div>
	</td>
	<td align="left" class2="right">
	 <select name="Billback_Module_Type">
	<option value="1" <cfif appSettings.getBillbackModuleType() EQ 1>selected</cfif>>CF</option>
	<option value="2" <cfif appSettings.getBillbackModuleType() EQ 2>selected</cfif>>GM</option>
	<option value="3" <cfif appSettings.getBillbackModuleType() EQ 3>selected</cfif>>Both</option>
   </select>
	</td>
  </tr>
  <!--- END: 31505: App setting for Flex BB Module/Anand Rao/24-Apr-2012 --->

  <cfset renderDivider()>

  <!--- End 19441 --->

  <tr valign="top">
	<td>3rd party bb upload:</td>
	<td>&nbsp; </td>
	<td  colspan="3">
	  <select name="Third_Party_BB_Upload">
		<option value="0" <cfif appSettings.getThirdPartyBBUpload() eq 0>selected</cfif>>None</option>
		<option value="3" <cfif appSettings.getThirdPartyBBUpload() eq 3>selected</cfif>>Combo</option>
		<option value="1" <cfif appSettings.getThirdPartyBBUpload() eq 1>selected</cfif>>Instill</option>
		<option value="2" <cfif appSettings.getThirdPartyBBUpload() eq 2>selected</cfif>>Tibersoft</option>
	  </select>
	</td>
  </tr>

  <tr class="t6h">
	<td>
	  BB - Show Modify Program:
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="BB_Show_Modify_Program" <cfif appSettings.getBBShowModifyProgram() EQ 1>checked</cfif>>
	</td>
  </tr>

  <tr class="t6h">
	<td>
	  BB - Show DD LH Link:
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="BB_Show_DD_Link" <cfif request.settings.BB_Show_DD_Link eq '1'>checked</cfif>>
	</td>
  </tr>

  <tr class="t6h">
	<td>BB uploaded via 3rd party upload job:  Editable claimed dollars and quantity</td>
	<td>&nbsp; </td>
	<td align="left">
	  <select name="BB_Upload_III_P_Qty_Amt_Editable">
		<option value="0" <cfif appSettings.getBB_Upload_III_P_Qty_Amt_Editable() EQ 0>selected</cfif>>OFF</option>
		<option value="1" <cfif appSettings.getBB_Upload_III_P_Qty_Amt_Editable() EQ 1>selected</cfif>>ON</option>
	  </select>
	</td>
  </tr>

 <!--- End 19441 --->
   <!--- Dev Notes: 21185/Anand Rao/10-Nov-09 Setting for displaying Vendor ID Null form --->
  <tr class="t6h">
	  <td>Display Vendor ID Null Form:</td>
	  <td>&nbsp; </td>
	  <td align="left">
		<select name="Display_Vendor_ID_Null_Form">
		  <option value="0" <cfif appSettings.getDisplay_Vendor_ID_Null_Form () EQ 0>selected</cfif>>OFF</option>
		  <option value="1" <cfif appSettings.getDisplay_Vendor_ID_Null_Form () EQ 1>selected</cfif>>ON</option>
		</select>
	  </td>
	</tr>
	<!--- End 21185 --->
	<!--- Dev Notes: 21923/Anand Rao/22-Jan-2010 Settings for BB Deviation Grid --->
  <tr class="t6h">
	  <td>Update BB Approve Amount:<br />
	  <em style="color:red;">(Do not turn this ON before verifying client's configuration and interface logic)</em>
	  </td>
	  <td>&nbsp; </td>
	  <td align="left">
		<select name="Update_BB_Approve_Amt">
		  <option value="0" <cfif appSettings.getUpdate_BB_Approve_Amt () EQ 0>selected</cfif>>OFF</option>
		  <option value="1" <cfif appSettings.getUpdate_BB_Approve_Amt () EQ 1>selected</cfif>>ON</option>
		</select>
	  </td>
	</tr>
  <tr class="t6h">
	  <td>BB Approve Expected Rate Less Tolerance:<br />
	  <em style="color:red;">(If <strong>"BB Deviations Override Price"</strong> is ON, this setting will be ignored)</em>

	  </td>
	  <td>&nbsp; </td>
	  <td align="left">
		<select name="BB_Approve_Expected_Rate_Less_Tolerance">
		  <option value="0" <cfif appSettings.getBB_Approve_Expected_Rate_Less_Tolerance () EQ 0>selected</cfif>>OFF</option>
		  <option value="1" <cfif appSettings.getBB_Approve_Expected_Rate_Less_Tolerance () EQ 1>selected</cfif>>ON</option>
		</select>
	  </td>
	</tr>
	<!--- End 21923 --->
	<!--- Start 19441 --->
  <tr class="t6h">
	<td>BB Deviations Override Price:</td>
	<td>&nbsp; </td>
	<td align="left">
	  <select name="BB_Deviations_Override_Price">
		<option value="0" <cfif appSettings.getBB_Deviations_Override_Price() EQ 0>selected</cfif>>OFF</option>
		<option value="1" <cfif appSettings.getBB_Deviations_Override_Price() EQ 1>selected</cfif>>ON</option>
	  </select>
	</td>
  </tr>
  <!--- Tim Ford - Label 31769: Billback Deviation Grid --->
  <tr class="t6h">
	<td>BB Deviation Grid – upon loading default to:</td>
	<td>&nbsp; </td>
	<td align="left">
	  <select name="BB_LS_Claimed_Rebate_Expected">
		<option value="0" <cfif appSettings.getBB_LS_Claimed_Rebate_Expected () EQ 0>selected</cfif>>Expected</option>
		<option value="1" <cfif appSettings.getBB_LS_Claimed_Rebate_Expected () EQ 1>selected</cfif>>LS as Claimed & Rebate as Expected</option>
	  </select>
	</td>
  </tr>
<!--- START: 77469	Display Dist Channel at BB_Program Distributor Level   [ CF work ]   --->
  <tr class="t6h">

	<td>BB Display #qGetBSVar2Label.General_Labels_Label# Per Program/Distributor :</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="BB_Display_Dist_Channel_Per_Program_Distributor"  <cfif request.settings.BB_Display_Dist_Channel_Per_Program_Distributor eq '1'>checked</cfif>></td>
  </tr>

  <tr class="t6h">
		<td>Redistributor default Segment BS_Var_2</td>
		<td>&nbsp; </td>
		<td><input type="text" name="Redistributor_default_Segment_BS_Var_2" value="#request.settings.Redistributor_default_Segment_BS_Var_2#" style="width:50px;"></td>
  </tr>
<!--- END: 77469	Display Dist Channel at BB_Program Distributor Level   [ CF work ]   --->
  <tr class="t6h">
	<td>Search inactive products in programs</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="Search_Inactive_Products_Programs" <cfif appSettings.getSearchInactiveProductsInPrograms() EQ 1>checked</cfif>>
	</td>
  </tr>
  <tr class="t6h">
	<td>Search inactive distributors in programs</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="Search_Inactive_Distributors_Programs" <cfif appSettings.getSearchInactiveDistributorsInPrograms() EQ 1>checked</cfif>>
	</td>
  </tr>
  <!---26199 2011/feb/23 ChrisN--->
  <tr class="t6h">
	<td>Search inactive operators in programs</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="Search_Inactive_Operators_Programs" <cfif appSettings.getSearchInactiveOperatorsInPrograms() EQ 1>checked</cfif>>
	</td>
  </tr>
  <tr class="t6h">   <!--- 51726 --->
	<td>Copy Distributors to Vendors table:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Copy_Distributors_to_Vendors" <cfif request.settings.Copy_Distributors_to_Vendors eq '1'>checked</cfif>></td>
  </tr>
  <tr class="t6h">   <!--- 51726 --->
	<td>Copy Operators to Vendors table:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Copy_Operators_to_Vendors" <cfif request.settings.Copy_Operators_to_Vendors eq '1'>checked</cfif>></td>
  </tr>
  <!--- 48459  Updated app setting name  --->
  <tr class="t6h">
	<td>Revision Types On for Approval (short cut approval)
	</td>
	<td>&nbsp; </td>
	<td  colspan="3"><input value="1" type="checkbox" name="RevisionTypesOn" <cfif appSettings.getRevisionTypesOn()>checked</cfif>></td>
  </tr>
  <!--- D28558 9/22/2011 Deepa --->
  <tr class="t6h">
	<td>Short cut approval - No routing allowed</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="Shortcut_No_Routing_Allowed" <cfif appSettings.getShortcutNoRoutingAllowed() EQ 1>checked</cfif>>
	</td>
  </tr>

  <!---28345 Chris Added External Contacts--->
  <tr class="t6h">
	<td>External Contacts:</td>
	<td>&nbsp; </td>
	<td align="left">
	  <select name="External_Contacts_Option">
		<option value="0" <cfif appSettings.getExternal_Contacts() EQ 0>selected</cfif>>OFF</option>
		<option value="1" <cfif appSettings.getExternal_Contacts() EQ 1>selected</cfif>>Automated Upload</option>
		<option value="2" <cfif appSettings.getExternal_Contacts() EQ 2>selected</cfif>>User Managed</option>
	  </select>
	</td>
  </tr>

  <!---  29997:  Update Items proposal status based on approved billback Update Items proposal status based on approved billback/Anand Rao/22-Feb-2012 --->
  <tr class="t6h">
	<td>Update Program won/lost based on billback approval:</td>
	<td>&nbsp; </td>
	<td align="left">
	  <select name="PrgWonLostOnBBApproval">
		<option value="0" <cfif appSettings.getPrgWonLostOnBBApproval() EQ 0>selected</cfif>>OFF</option>
		<option value="1" <cfif appSettings.getPrgWonLostOnBBApproval() EQ 1>selected</cfif>>On BB Approve Status</option>
		<option value="2" <cfif appSettings.getPrgWonLostOnBBApproval() EQ 2>selected</cfif>>On BB Paid Status</option>
	  </select>
	</td>
  </tr>
  <!--- START: D49855 :: Win/Loss Bid - Create new app setting called “Update Program won/loss based on Off invoice Record�? --->
  <tr class="t6h">
	  <td>Update Program won/loss based on Off invoice Record : <span onmouseout="popUpTip(event,'Off_invoice_logic');" onmouseover="popUpTip(event,'Off_invoice_logic');"><img src="/images/help_small.gif" /></span>
	<div id="Off_invoice_logic" class="tip">Off Invoice records are typically received via the Interface called "666 Off Invoice"</div>
	</td>
	  <td>&nbsp; </td>
	  <td align="left">
		<input value="1" type="checkbox" name="Update_Program_Won_Lost_Based_On_OI" <cfif appSettings.getPrgWonLostOnOffInvoiceRecord()>checked</cfif>>
	  </td>
  </tr>
  <!--- END: D49855 :: Win/Loss Bid - Create new app setting called “Update Program won/loss based on Off invoice Record�? --->
  <!---  D30486: Multiple AR numbers to 1 Account(Customer)-UI --->
  <tr class="t6h">
	  <td>Multiple Bill To’s for a Ship To:</td>
	  <td>&nbsp; </td>
	  <td align="left">
		<input value="1" type="checkbox" name="Multiple_BillTos_For_ShipTo" <cfif appSettings.getMultipleBillTosForShipTo() EQ 1>checked</cfif>>
	  </td>
	</tr>

<!--- D36542 prof model -- new internal application setting --->
  <tr class="t6h">
	  <td>Profitability Model:</td>
	  <td>&nbsp; </td>
	  <td align="left">
		<input value="1" type="checkbox" name="Profitability_Model" <cfif appSettings.getProfitabilityModel() EQ 1>checked</cfif>>
	  </td>
	</tr>
<!--- D36542 prof model -- new internal application setting --->

<!--- D37022 BB Auto Approve Logic - CF work START --->
  <tr class="t6h">
	<td>BB Auto Approve Logic:<span onmouseout="popUpTip(event,'bbaa_logic');" onmouseover="popUpTip(event,'bbaa_logic');"><img src="/images/help_small.gif" /></span>

		<div id="bbaa_logic" class="tip">
		Standard - based on settings that are selected on the billback auto approve page.
		</div>
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <select name="BB_Auto_Approve_Logic">
		<option value="0" <cfif appSettings.getBBAutoApproveLogic() EQ 0>selected</cfif>>Standard</option>
		<option value="1" <cfif appSettings.getBBAutoApproveLogic() EQ 1>selected</cfif>>Based on Closing Method</option>
	<option value="2" <cfif appSettings.getBBAutoApproveLogic() EQ 2>selected</cfif>>Based on Disc Identifier</option>
	  </select>
	</td>
  </tr>
<!--- D37022 BB Auto Approve Logic - CF work END--->
<!--- START: 36746: Billback Deviation & Summary - Add Operator to the display --->
  <tr class="t6h">
	  <td>Display Operator in Billback Deviation:</td>
	  <td>&nbsp; </td>
	  <td align="left">
		<input value="1" type="checkbox" name="View_Operator_in_Billback_Deviation" <cfif appSettings.getViewOperatorinBillbackDeviation() EQ 1>checked</cfif>>
	  </td>
  </tr>

  <tr class="t6h">
	  <td>BB Default Program Retry Process:</td>
	  <td>&nbsp; </td>
	  <td align="left">
		<input value="1" type="checkbox" name="BB_Default_Program_Retry_Process" <cfif appSettings.getBBDefaultProgramRetryProcess() EQ 1>checked</cfif>>
	  </td>
  </tr>
<!--- END: 36746: Billback Deviation & Summary - Add Operator to the display --->
<!--- START: D39421: Deviations Grid - Allow Manual values greater than Claimed/ Anand Rao/24-Sep-2013 --->
  <tr class="t6h">
	  <td>BB Deviations Grid - Allow Manual values Greater than Claimed :</td>
	  <td>&nbsp; </td>
	  <td align="left">
		<input value="1" type="checkbox" name="Deviation_Grid_Allow_Manual_Values_GT_Claimed" <cfif appSettings.getDeviationGridAllowManualValuesGTClaimed() EQ 1>checked</cfif>>
	  </td>
  </tr>
<!--- END: D39421: Deviations Grid - Allow Manual values greater than Claimed/ Anand Rao/24-Sep-2013 --->

<!--- D35165 :: LW ENHANCEMENT REQUEST:  Auto Close programs with no claims for 5 months START--->
  <tr class="t6h">
	  <td>Auto cancel programs with no claims for period of (months):</td>
	  <td>&nbsp; </td>
	  <td align="left">
		<input value="#appSettings.getCancelPgmNoBBMonths()#" type="text" name="Cancel_Pgm_No_BB_Months" size="3" maxlength="2" onkeypress="javaScript: return Allow_Key_List('0123456789');">
	  </td>
  </tr>
<!---D35165 :: LW ENHANCEMENT REQUEST:  Auto Close programs with no claims for 5 months END --->

  <tr class="t6h">
	  <td>Enable group membership dates:</td>
	  <td>&nbsp; </td>
	  <td align="left">
	  <input value="1" type="checkbox" name="Enable_Group_Membership_Dates" <cfif appSettings.getEnableGroupMembershipDates() EQ 1>checked</cfif>>
	  </td>
  </tr>

<tr class="t6h">
  <td  class="t6h">
	<span onmouseout="popUpTip(event,'tAutoApproveProductsOnRevision');" onmouseover="popUpTip(event,'tAutoApproveProductsOnRevision');">
	<!---
	  D48293 :: Update short cut routing and auto approve product settings
	  On Program Revision, auto approve products without any changes (no rate change, no new products added): --->
	On Program Revision, auto approve products without any changes (no rate change, no new products added, no date change, no operator added)<img src="/images/help_small.gif" />
	</span>
  </td>
  <td>&nbsp;
  <div id="tAutoApproveProductsOnRevision" class="tip">
	Currently, this feature is applicable for Fixed and Rebate Only:<br />
	At this time, the logic for this setting is based on Kraft requirements.<br/>
	When this setting is ON, it will route a program revision with a product rate change or a new product to the appropriate users when there is a product rate change,new product,date change or operator added.
	<br /><br />Example:  Program has the items:  Cereal and Ham. <br />
	The Cereal item must be approved by the Marketing Cereal user.<br />
	The Ham item must be approved by the Marketing Ham user.<br />
	A user revises the program and only changes the rate on the Ham item.<br />
	The program revision should only route to the Marketing Ham user, it should not route to the Marketing Cereal user.<br />
  </div>
  </td>
  <td align="left">
	<input value="1" type="checkbox" name="Auto_Approve_Products_On_Revision" <cfif appSettings.getAutoApproveProductsOnRevision() EQ 1>checked</cfif>>
  </td>
</tr>
  <tr class="t6h">
	  <td>BB Powerpunch:</td>
	  <td>&nbsp; </td>
	  <td align="left">
	  <input value="1" type="checkbox" name="BB_Powerpunch" <cfif appSettings.getBBPowerpunch() EQ 1>checked</cfif>>
	  </td>
  </tr>
 <tr class="t6h">
	  <td>Show Holding Pen:</td>
	  <td>&nbsp; </td>
	  <td align="left">
	  <input value="1" type="checkbox" name="Show_Holding_Pen" <cfif appSettings.getShowHoldingPen() EQ 1>checked</cfif>>
	  </td>
  </tr>
<!--- START: D44724 Billback Approval Automation --->
  <tr class="t6h">
	  <td>Date Tolerance :</td>
	  <td>&nbsp; </td>
	  <td align="left">
		<input value="#appSettings.getDateTolerance()#" type="text" name="Date_Tolerance" size="3" maxlength="2" onkeypress="javaScript: return Allow_Key_List('0123456789');">
	  </td>
  </tr>
<!--- END: D44724 Billback Approval Automation --->
  <tr class="t6h">
	  <td>Establish payee from the planning groups :</td>
	  <td>&nbsp; </td>
	  <td align="left">
	<input value="1" type="checkbox" name="Payee_From_Planning_Groups" <cfif appSettings.getPayeeFromPlanningGroups() EQ 1>checked</cfif>>
	  </td>
  </tr>
  <!--- START: D46525: Make BB Reference Field Required/Anand Rao/25-Nov-2014 --->
  <tr class="t6h">
	  <td>BB Reference Number is Required:</td>
	  <td>&nbsp; </td>
	  <td align="left">
	<input value="1" type="checkbox" name="BB_ReferenceNum_Required" <cfif appSettings.getBBReferenceNumRequired() EQ 1>checked</cfif>>
	  </td>
  </tr>
  <!--- END: D46525: Make BB Reference Field Required --->
  <!--- START: D49837 - CAG PROD - BB LH link EDI Download/Anand Rao/29-Apr-2015 --->
  <tr class="t6h">
	  <td>Enable EDI and Upload raw data viewer:</td>
	  <td>&nbsp; </td>
	  <td align="left">
	<input value="1" type="checkbox" name="Enable_EDI_Upload_Raw_Data_Viewer" <cfif appSettings.getEnableEDIUploadRawDataViewer() EQ 1>checked</cfif>>
	  </td>
  </tr>
  <!--- END: D49837 - CAG PROD - BB LH link EDI Download --->

  <!--- removed by 50194 Move Trade Eligibility link to Report Central
  <!--- START: D49844 :: Create new app setting called �?Trade Eligibility Report�? with ON/OFF options --->
  <tr>
	  <td>Trade Eligibility Report</td>
	  <td>&nbsp; </td>
	  <td align="left">
		<input value="1" type="checkbox" name="TradeEligibilityReport" <cfif appSettings.getTradeEligibilityReport()>checked</cfif>>
	  </td>
  </tr>
  <!--- END: D49844 :: Create new app setting called �?Trade Eligibility Report�? with ON/OFF options --->
  --->

  <!---D51056 Create app setting for Dashboards to turn on/off--->
  <tr class="t6h">
	  <td>Dashboards</td>
	  <td>&nbsp; </td>
	  <td align="left">
		<select name="Dashboards">
		  <option value="0" <cfif request.settings.Dashboards eq '0'>selected</cfif>>OFF</option>
		  <option value="1" <cfif request.settings.Dashboards eq '1'>selected</cfif>>ON</option>
		</select>
	</td>
  </tr>

   <!---50324 - "Payment history dollars" include "Off Invoice" Dollars. --->
  <tr class="t6h">
		<td>Pymt History Dollars include Off Invoice Dollars</td>
		<td>&nbsp; </td>
		<td align="left">
		<input value="1" type="checkbox" name="Pymt_history_Dollars_Include_OffInvoice_Dollars" <cfif appSettings.getPymtHistoryDollarsIncludeOffInvoiceDollars() EQ 1>checked</cfif>>
		</td>
  </tr>

  <cfset renderDivider("RETAIL PLANNER")>

	<tr>
		<td>Retail #Application.PlannerLabel# Module</td>
		<td>&nbsp; </td>
		<td>
		<input value="1" type="checkbox" name="Retail_Planner" <cfif request.settings.Retail_Planner eq '1'>checked</cfif>>
		</td>
	</tr>

  <tr>
	  <td>Retail #Application.PlannerLabel# Week Start:
	  </td>
	  <td>&nbsp; </td>
	  <td>
	  <cfset qGetWeekdays = CreateObject("component","mvc.Models.Planner.PlannerSettingsManager").getWeekDays() />
		  <select name="Retail_Planner_Week_Start">
		<option value="0">Select a Weekday</option>
			<cfloop query="qGetWeekdays">
			  <option value="#Weekdays_Id#" <cfif request.settings.Retail_Planner_Week_Start eq Weekdays_Id>selected</cfif>>#Weekday#</option>
			</cfloop>
	  </select>
	  </td>
  </tr>

  <tr>
	  <td>Retail volume plan: How many weeks in advance should the forecast generate?</td>
	  <td>&nbsp; </td>
	  <td>
		<input value="#request.settings.Retail_Planner_Vol_Forcast_Weeks#" type="text" name="Retail_Planner_Vol_Forcast_Weeks" size="3" maxlength="2" onkeypress="javaScript: return Allow_Key_List('0123456789');"> wks
	  </td>
  </tr>

  <tr style="margin-bottom:5px">
	  <td>Target Product Group:</td>
	  <td>&nbsp;</td>
	  <td>
		<cfparam name="form.retail_target_product_group" default="#request.settings.retail_target_product_group#">
		<select name="retail_target_product_group">
		  <option></option>
		  <option value="9" #(form.retail_target_product_group eq 9 ? "selected" : "")#>#application.returned_customer_setting.item_label#</option>
		  <cfloop query="qProductGroups">
			<option value="#qProductGroups.Product_Group_Level_ID#" #(form.retail_target_product_group eq qProductGroups.Product_Group_Level_ID ? "selected" : "")#>#qProductGroups.Group_Level_Desc# - #qProductGroups.Group_Internal_Label#</option>
		  </cfloop>
		</select>
	  </td>
  </tr>

  <tr style="margin-bottom:5px">
	  <td>Margin Sub Total Product Group:</td>
	  <td>&nbsp;</td>
	  <td>
		<cfparam name="form.Retail_Margin_Sub_Total_Group" default="#request.settings.Retail_Margin_Sub_Total_Group#">
		<select name="Retail_Margin_Sub_Total_Group">
		  <option></option>
		  <option value="9" #(form.Retail_Margin_Sub_Total_Group eq 9 ? "selected" : "")#>#application.returned_customer_setting.item_label#</option>
		  <cfloop query="qProductGroups">
			<option value="#qProductGroups.Product_Group_Level_ID#" #(form.Retail_Margin_Sub_Total_Group eq qProductGroups.Product_Group_Level_ID ? "selected" : "")#>#qProductGroups.Group_Level_Desc# - #qProductGroups.Group_Internal_Label#</option>
		  </cfloop>
		</select>
	  </td>
  </tr>

  <tr style="margin-bottom:5px">
	  <td>Consumer Events Product Group:</td>
	  <td>&nbsp;</td>
	  <td>
		<cfparam name="form.Retail_Consumer_Events_Group" default="#request.settings.Retail_Consumer_Events_Group#">
		<select name="Retail_Consumer_Events_Group">
		  <option></option>
		  <option value="9" #(form.Retail_Consumer_Events_Group eq 9 ? "selected" : "")#>#application.returned_customer_setting.item_label#</option>
		  <cfloop query="qProductGroups">
			<option value="#qProductGroups.Product_Group_Level_ID#" #(form.Retail_Consumer_Events_Group eq qProductGroups.Product_Group_Level_ID ? "selected" : "")#>#qProductGroups.Group_Level_Desc# - #qProductGroups.Group_Internal_Label#</option>
		  </cfloop>
		</select>
	  </td>
  </tr>
  <tr>
    <td>Retail base volume basis:</td>
    <td>&nbsp; </td>
    <td>
    <input value="#request.settings.Retail_Base_Volume_Basis#" type="text" name="Retail_Base_Volume_Basis" size="3" maxlength="2" onkeypress="javaScript: return Allow_Key_List('0123456789');"> wks
    </td>
  </tr>

  <tr>
	<td>
	  Demand Plan
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="Retail_Demand_Plan_Enabled" <cfif request.settings.Retail_Demand_Plan_Enabled eq "1">checked</cfif>>
	</td>
  </tr>

  <tr>
	<td>
	  Demand Plan is source for Latest FCST
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="Retail_Demand_Plan_Populate_Latest_FCST" <cfif request.settings.Retail_Demand_Plan_Populate_Latest_FCST eq "1">checked</cfif>>
	</td>
  </tr>

  <tr>
	<td>
	  Demand Plan UOM
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <cfset valRetail_Demand_Plan_Interface_UOM = request.settings.Retail_Demand_Plan_Interface_UOM />
	  <select name="Retail_Demand_Plan_Interface_UOM">
		<option value="2" <cfif valRetail_Demand_Plan_Interface_UOM eq 2>selected</cfif>>LB</option>
		<option value="1" <cfif valRetail_Demand_Plan_Interface_UOM eq 1>selected</cfif>>CS</option>
	  </select>
	</td>
  </tr>

  <tr>
	<td>
	  #Application.PlannerLabel# Margin Approval Type: <span onmouseout="popUpTip(event,'tPlannerMarginApprovalType');" onmouseover="popUpTip(event,'tPlannerMarginApprovalType');"><img src="/images/help_small.gif" />
	</td>
	<td>&nbsp; </td>
	<td align="left">
  <div id="tPlannerMarginApprovalType" class="tip" style="width: 650px">
	<ol>
	<li>
	Margin and Max Trade spend:
		<ul>
		<li>When #Application.PlannerLabel# total spend < Profile [Planner Max Total Spend], ignore margin and allow user to approve all type codes that he has approval rights for</li>
		<li>When #Application.PlannerLabel# total spend > Profile [Planner Max Total Spend], review margin to determine approve vs agree</li>
		</ul>
	</li>
	<li>
	Margin:
		<ul>
		<li>Use margin alone to evaluate #Application.PlannerLabel# approval.</li>
		<li>Margin Type that is used is defined in Settings / Administration / Application Setting / approval settings tab</li>
		</ul>
	</li>
	<li>
	Max Trade Spend
		<ul>
		<li>When #Application.PlannerLabel# total spend < Profile [Planner Max Total Spend], allow user to approve all type codes that he has approval rights for</li>
		<li>When #Application.PlannerLabel# total spend > Profile [Planner Max Total Spend], user will only be allowed to agree to the #Application.PlannerLabel#</li>
		</ul>
	</li>
	</ol>
  </div>
	  <cfset valPlanner_Margin_Approval_Type = request.settings.Planner_Margin_Approval_Type />
	  <select name="Planner_Margin_Approval_Type">
		<option value="1" <cfif valPlanner_Margin_Approval_Type eq 1>selected</cfif>>Margin and Max Trade Spend [default]</option>
		<option value="2" <cfif valPlanner_Margin_Approval_Type eq 2>selected</cfif>>Margin</option>
		<option value="3" <cfif valPlanner_Margin_Approval_Type eq 3>selected</cfif>>Max Trade Spend</option>
	  </select>
	</td>
  </tr>

  <tr>
	<td>
	  #Application.PlannerLabel# Case Count Source
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <cfset valPlanner_Case_Count_Source = request.settings.Planner_Case_Count_Source />
	  <select name="Planner_Case_Count_Source">
		<option value="1" <cfif valPlanner_Case_Count_Source eq 1>selected</cfif>>Item Master</option>
		<option value="2" <cfif valPlanner_Case_Count_Source eq 2>selected</cfif>>NUC Targets</option>
	  </select>
	</td>
  </tr>
  <tr>
	<td>
	  #Application.PlannerLabel# Targets - Enabled
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="Planner_Targets_Enabled" <cfif request.settings.Planner_Targets_Enabled eq "1">checked</cfif>>
	</td>
  </tr>
  <tr style="margin-bottom:5px">
	  <td>#Application.PlannerLabel# Targets - Business Unit (distributor):</td>
	  <td>&nbsp;</td>
	  <td>
		<cfparam name="form.Planner_Target_Main_Dist_Group_Type" default="#request.settings.Planner_Target_Main_Dist_Group_Type#">
		<select name="Planner_Target_Main_Dist_Group_Type">
		  <option></option>
		  <cfloop query="qDistributorGroups">
			<option value="#qDistributorGroups.Distributor_Group_Level_ID#" #(form.Planner_Target_Main_Dist_Group_Type eq qDistributorGroups.Distributor_Group_Level_ID ? "selected" : "")#>#qDistributorGroups.Group_Level_Desc# - <cfif qDistributorGroups.Is_PG>Planning Group<cfelse>#qDistributorGroups.Group_Level_Desc_Internal#</cfif></option>
		  </cfloop>
		</select>
	  </td>
  </tr>
	<cfquery name="qPTProductGroups" datasource="#application.datasource#">
		SELECT  Product_Group_Level.Product_Group_Level_ID
		,Product_Group_Level.Group_Level_Desc
		,Product_Group_Level.Group_Internal_Label
		FROM    Product_Group_Level
		WHERE   Product_Group_Level.Active = 1
		AND Product_Group_Level.Product_Group_Level_ID <> 1
		ORDER BY Product_Group_Level.Group_Level_Desc
	</cfquery>
  <tr style="margin-bottom:5px">
	  <td>#Application.PlannerLabel# Targets - Initial Sales Targets (product):</td>
	  <td>&nbsp;</td>
	  <td>
		<cfparam name="form.Planner_Target_Main_Prod_Group_Type" default="#request.settings.Planner_Target_Main_Prod_Group_Type#">
		<select name="Planner_Target_Main_Prod_Group_Type">
		  <option></option>
		  <cfloop query="qPTProductGroups">
			<option value="#qPTProductGroups.Product_Group_Level_ID#" #(form.Planner_Target_Main_Prod_Group_Type eq qPTProductGroups.Product_Group_Level_ID ? "selected" : "")#>#qPTProductGroups.Group_Level_Desc# - #qPTProductGroups.Group_Internal_Label#</option>
		  </cfloop>
		</select>
	  </td>
  </tr>
  <tr style="margin-bottom:5px">
	  <td>#Application.PlannerLabel# Targets - Trade Rate/Demo (product):</td>
	  <td>&nbsp;</td>
	  <td>
		<cfparam name="form.Planner_Target_Sub_Prod_Group_Type" default="#request.settings.Planner_Target_Sub_Prod_Group_Type#">
		<select name="Planner_Target_Sub_Prod_Group_Type">
		  <option></option>
		  <cfloop query="qPTProductGroups">
			<option value="#qPTProductGroups.Product_Group_Level_ID#" #(form.Planner_Target_Sub_Prod_Group_Type eq qPTProductGroups.Product_Group_Level_ID ? "selected" : "")#>#qPTProductGroups.Group_Level_Desc# - #qPTProductGroups.Group_Internal_Label#</option>
		  </cfloop>
		</select>
	  </td>
  </tr>
  <tr style="margin-bottom:5px">
	  <td>#Application.PlannerLabel# Targets - Trade Rate/Demo (distributor):</td>
	  <td>&nbsp;</td>
	  <td>
		<cfparam name="form.Planner_Target_Sub_Dist_Group_Type" default="#request.settings.Planner_Target_Sub_Dist_Group_Type#">
		<select name="Planner_Target_Sub_Dist_Group_Type">
		  <option></option>
		  <cfloop query="qDistributorGroups">
			<option value="#qDistributorGroups.Distributor_Group_Level_ID#" #(form.Planner_Target_Sub_Dist_Group_Type eq qDistributorGroups.Distributor_Group_Level_ID ? "selected" : "")#>#qDistributorGroups.Group_Level_Desc# - <cfif qDistributorGroups.Is_PG>Planning Group<cfelse>#qDistributorGroups.Group_Level_Desc_Internal#</cfif></option>
		  </cfloop>
		</select>
	  </td>
  </tr>
  <tr style="margin-bottom:5px">
	  <td>#Application.PlannerLabel# Targets - Slotting (hierarchy level):</td>
	  <td>&nbsp;</td>
	  <td>
		<cfparam name="form.Planner_Target_Slotting_Position_Type" default="#request.settings.Planner_Target_Slotting_Position_Type#">
		<select name="Planner_Target_Slotting_Position_Type">
		  <option></option>
		  <option value="0" #(form.Planner_Target_Slotting_Position_Type eq 0 ? "selected" : "")#>Headquarters</option>
		  <option value="1" #(form.Planner_Target_Slotting_Position_Type eq 1 ? "selected" : "")#>#application.returned_customer_setting.zone_label_plural#</option>
		  <option value="2" #(form.Planner_Target_Slotting_Position_Type eq 2 ? "selected" : "")#>#application.returned_customer_setting.region_label_singular#</option>
		  <option value="3" #(form.Planner_Target_Slotting_Position_Type eq 3 ? "selected" : "")#>#application.returned_customer_setting.market_label_singular#</option>
		</select>
	  </td>
  </tr>


  <tr style="margin-bottom:5px">
	  <td>#Application.PlannerLabel# Direct/Indirect Allocation - Direct Customer Type:</td>
	  <td>&nbsp;</td>
	  <td>
		<cfparam name="form.Planner_Direct_Indirect_Allocation_Direct_Customer_Type" default="#request.settings.Planner_Direct_Indirect_Allocation_Direct_Customer_Type#">
		<select name="Planner_Direct_Indirect_Allocation_Direct_Customer_Type">
		  <option></option>
		  <cfloop query="qDistributorGroups">
		  	<cfif qDistributorGroups.Distributor_Group_Level_ID gte 23 and qDistributorGroups.Distributor_Group_Level_ID lte 26>
			  	<!--- exclude it --->
			<cfelse>
				<option value="#qDistributorGroups.Distributor_Group_Level_ID#" #(form.Planner_Direct_Indirect_Allocation_Direct_Customer_Type eq qDistributorGroups.Distributor_Group_Level_ID ? "selected" : "")#>#qDistributorGroups.Group_Level_Desc# - <cfif qDistributorGroups.Is_PG>Planning Group<cfelse>#qDistributorGroups.Group_Level_Desc_Internal#</cfif></option>
			</cfif>
		  </cfloop>
		</select>
	  </td>
  </tr>

  <tr style="margin-bottom:5px">
	  <td>#Application.PlannerLabel# Direct/Indirect Allocation - Indirect Customer Type:</td>
	  <td>&nbsp;</td>
	  <td>
		<cfparam name="form.Planner_Direct_Indirect_Allocation_InDirect_Customer_Type" default="#request.settings.Planner_Direct_Indirect_Allocation_InDirect_Customer_Type#">
		<cfquery name="qCustomerTypes" datasource="#application.datasource#">
			SELECT  PG_Type_ID   AS Operator_Type_ID
				   ,PG_Type_Name AS Operator_Type_Name
			  FROM  PG_Type
			 WHERE  PG_Group_Type = 3
			        AND  Deleted       = 0
			UNION
			SELECT   0 AS Operator_Type_ID
			       , '#application.returned_customer_setting.operator_label_plural#' AS Operator_Type_Name
		</cfquery>
		<select name="Planner_Direct_Indirect_Allocation_InDirect_Customer_Type">
		  <option></option>
		  <cfloop query="qCustomerTypes">
		  	<option value="#qCustomerTypes.Operator_Type_ID#" #(form.Planner_Direct_Indirect_Allocation_InDirect_Customer_Type eq qCustomerTypes.Operator_Type_ID ? "selected" : "")# > #qCustomerTypes.Operator_Type_Name# </option>
		  </cfloop>
		</select>
	  </td>
  </tr>

  <tr style="margin-bottom:5px">
	  <td>#Application.PlannerLabel# Direct/Indirect Allocation - Product Type:</td>
	  <td>&nbsp;</td>
	  <td>
		<cfparam name="form.Planner_Direct_Indirect_Allocation_Product_Type" default="#request.settings.Planner_Direct_Indirect_Allocation_Product_Type#">
		<select name="Planner_Direct_Indirect_Allocation_Product_Type">
		  <option></option>
		  <cfloop query="qPTProductGroups">
			<option value="#qPTProductGroups.Product_Group_Level_ID#" #(form.Planner_Direct_Indirect_Allocation_Product_Type eq qPTProductGroups.Product_Group_Level_ID ? "selected" : "")#>#qPTProductGroups.Group_Level_Desc# - #qPTProductGroups.Group_Internal_Label#</option>
		  </cfloop>
		</select>
	  </td>
  </tr>


<!--- 113334 :: STAGE2 Planner Segment START --->
  <tr style="margin-bottom:5px">
	  <td>Display Segment inside #Application.PlannerLabel# #Application.PlannerPrgLabel#:</td>
	  <td>&nbsp;</td>
	  <td>
			<input value="1" type="checkbox" name="Display_Segment_Planner_Program" <cfif request.settings.Display_Segment_Planner_Program eq "1">checked</cfif>>
	  </td>
  </tr>

  <tr style="margin-bottom:5px">
	  <td>Require Everyday Unit Retail:</td>
	  <td>&nbsp;</td>
	  <td>
			<input value="1" type="checkbox" name="Require_Everyday_Unit_Retail" <cfif request.settings.Require_Everyday_Unit_Retail eq "1">checked</cfif>>
	  </td>
  </tr>

 <!--- 113334 :: STAGE2 Planner Segment END --->
  <cfset renderDivider()>
</table>
</td>
<!---
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXX          COLUMN 2 STARTS HERE        XXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXX                          XXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--->

<td width="50%" valign="top">
<cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( [5, 1, 5] )>
<table cellpadding="2" cellspacing="0" border="0" style='table-layout:fixed' class="s9i t107">
  <cfloop array="#variables.columnSizes#" index="variables.columnPercentage">
	<cfoutput><col width="#variables.columnPercentage#%"></cfoutput>
  </cfloop>
  <tr class="t3h">
	<td>Use Product Group 1 (Brand):</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="UseProductGroup1" <Cfif appSettings.getUseProductGroup1() IS 1>checked</CFIF>></td>
  </tr>
  <tr class="t3h">
	<td>Use Product Group 2 (Q-Brand):</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="UseProductGroup2" <Cfif appSettings.getUseProductGroup2() IS 1>checked</CFIF>></td>
  </tr>
  <tr class="t3h">
	<td>Use Product Group 3 (Type Group):</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="UseProductGroup3" <Cfif appSettings.getUseProductGroup3() IS 1>checked</CFIF>></td>
  </tr>
  <tr class="t3h">
	<td>Use Product Group 4 (Type Code):</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="UseProductGroup4" <Cfif appSettings.getUseProductGroup4() IS 1>checked</CFIF>></td>
  </tr>
  <tr class="t3h">
	<td>Use Product Group 5 (Class Code):</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="UseProductGroup5" <Cfif appSettings.getUseProductGroup5() IS 1>checked</CFIF>></td>
  </tr>
  <tr class="t3h">
	<td>Use Product Hierarchy:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="UseProductHierarchy" <Cfif appSettings.getUseProductHierarchy() IS 1>checked</CFIF>></td>
  </tr>
  <tr class="t3h">
	<td>Product Search: Exlude product hierarhcy list:
	<br>(comma separated list eg:4,5)
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="text" value="#appSettings.getSearchProductHierarchyExcludeList()#" name="searchProductHierarchyExcludeList" onkeypress="javaScript: return Allow_Key_List('0123456789,');" maxlength="50"></td>
  </tr>
  <tr class="t3h">
	<td>Customer Type Is On:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="Customertype" <Cfif appSettings.getCustomerType() IS 1>checked</CFIF>></td>
  </tr>
  <!--- <tr class="t3h">
	<td>Label Notes:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="text" size="25" name="LabelNotes" value="#appSettings.getLabelNotes()#"></td>
  </tr> --->
  <tr class="t3h">
	<td>Display Notes Field on Program:</td>
	<td>&nbsp;</td>
	<td align="left"><input value="1" type="checkbox" name="Display_notes_field_on_program" <cfif appSettings.getDisplayNotesFieldOnProgram() IS 1>checked</cfif>></td>
  </tr>
  <tr class="t3h">
	<td>Use Floor Pricing:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="FloorPrice" <Cfif appSettings.getFloorPrice() IS 1>checked</CFIF>></td>
  </tr>
  <!--- Removed with label 19409, set DEFAULT TO OFF
  <tr>
	<td>Program notes required:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="programnotesrequired" <Cfif appSettings.getprogramnotesrequired() IS 1>checked</CFIF>></td>
  </tr>
  --->
  <tr class="t3h">
	<td>Equipment and Dispenser Placement:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="Equipment_Placement" <Cfif appSettings.getEquipment_Placement() IS 1>checked</CFIF>></td>
  </tr>
  <!--- removed with label 18746
  <tr>
	<td>Send Approved Programs EmailAddress:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="text" size="25" name="Send_Approved_Programs_EmailAdress" value="#appSettings.getSendApprovedProgramsEmailAdress()#"></td>
  </tr>
  --->
  <!--- Removed with label 19409, set DEFAULT TO ON
  <tr>
	<td>Fixed Components On:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="fixedcomponents_on" <Cfif appSettings.getfixedcomponents_on() IS 1>checked</CFIF>></td>
  </tr>
  --->
  <tr class="t3h">
	<td>Program Template - Forbid/allow profiles:
	<br>1=forbid, 0=allow
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="forbidAllowProfilesInTemplates" <Cfif appSettings.getForbidAllowProfilesInTemplates() IS 1>checked</CFIF>></td>
  </tr>
  <tr class="t3h">
	<cfset approvalGroupType = CreateObject("component", "components.settings.ApprovalGroupManager").getGroupTypeInfo() />
	<td>Restrict Program & product Access On #approvalGroupType.Label#
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="RestrictAccessOnGroup" <Cfif appSettings.getRestrictAccessOnGroup() IS 1>checked</CFIF>></td>
  </tr>
  <tr class="t3h">
	<td>Customer ID On:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="custid_on" <Cfif appSettings.getcustid_on() IS 1>checked</CFIF>></td>
  </tr>
  <tr class="t3h">
	<td>Claim Auto Print:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="claimAutoPrint" id="claimautoprint" <Cfif appSettings.getClaimAutoPrint() IS 1>checked</CFIF>></td>
  </tr>
  <!--- 27047 ChrisN Added billback statement type --->
  <tr class="t3h">
	<td>Billback Statement Type: <span onmouseout="popUpTip(event,'bbstmt_type');" onmouseover="popUpTip(event,'bbstmt_type');"><img src="/images/help_small.gif" /></span></td>
	<td>&nbsp; <div id="bbstmt_type" class="tip"><ul style="margin:10px 0 10px 19px;"><li><b>Statement V1 PDF</b> includes fields at item level for distributor name & payable.</li>
<li><b>Summary Statement V2 PDF</b> includes a rejected section and deviation codes at item level.</li>
<li><b>Statement V3 Excel</b> is a combination of V2 & V3 in an Excel format.</li>
<li><b>Claim Summary</b> is available when Claim Auto Print is on (not a recommended selection)</li></ul></div></td>
	<td align="left">
	<select name="billback_statement_type" id="billback_statement_type">
	  <option value="None" <cfif appSettings.getBillBack_Statement_Type() eq "None">selected</cfif>
		title="Hide the Link Statement in the Billback LHS">None</option>
	  <option value="pdf-v1" <cfif appSettings.getBillBack_Statement_Type() eq "pdf-v1">selected</cfif>
		title="Includes fields at item level for distributor name & payable">Statement V1 PDF</option>
	  <option value="pdf-v2" <cfif appSettings.getBillBack_Statement_Type() eq "pdf-v2">selected</cfif>
		title="Includes a rejected section and deviation codes at item level.">Summary Statement V2 PDF</option>
	  <option value="excel-v3"      <cfif appSettings.getBillBack_Statement_Type() eq "excel-v3">selected</cfif>
		title="A combination of V2 & V3 in an Excel format">Statement V3 Excel</option>
	  <cfif appSettings.getClaimAutoPrint() IS 1>
		<option value="claim-summary" id="claim-summary" <cfif appSettings.getBillBack_Statement_Type() eq "claim-summary">selected</cfif>
		title="Available when Claim Auto Print is on (not a recommended selection).">Claim Summary</option>
	  </cfif>
	</select>
	</td>
  </tr>
  <tr class="t3h">
	<td>Allow Multiple Position for <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>:
	<br>(default = 0)
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="distributorMultiPosition" <Cfif appSettings.getDistributorMultiPosition() IS 1>checked</CFIF>></td>
  </tr>
  <tr class="t3h">
	<td><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Search Restriction on filter selection:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="operatorSearchRestrict" <cfif appSettings.getOperatorSearchRestrict() IS 1>checked</cfif>></td>
  </tr>

<!--- Dev Note: drachala; D28618: Position Drop Down Fields filtered based on Program Business Segment  START
Added/Changed: Added New Setting Position Drop Down Fields filtered based on Program Segment--->
  <tr class="t3h">
	<td>Position Drop Down Fields filtered based on Program Segment</td>
  <td>&nbsp; </td>
  <td align="left"><input type="checkbox" value="1" name="Position_Fields_Filtered_Based_On_Program_Segment" <Cfif appSettings.getPositionFieldsFilterOnProgramSegment() IS 1>checked</CFIF>></td>
  </tr>
<!--- End Dev Note: drachala; D28618: Position Drop Down Fields filtered based on Program Business Segment  --->
  <tr class="t3h">
	<td>Display message on delete program:
	<br>(default = leave empty)
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="text" size="25" maxlength="225" value="#appSettings.getDeleteProgramMessage()#" name="DeleteProgramMessage"></td>
  </tr>
  <tr class="t3h">
	<td>delete autorenewed program = cancel:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="DeleteIsCancelAutoRenew" <cfif appSettings.getDeleteIsCancelAutoRenew() IS 1>checked</cfif>></td>
  </tr>
  <!--- <tr>
	<td>Send email for cancel program:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="CancelProgramEmail" <cfif appSettings.getCancelProgramEmail() IS 1>checked</cfif>></td>
  </tr>  --->
  <tr class="t3h">
	<td>Allow multi level group deals:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="Allow_Multi_Level_Groups" <cfif appSettings.getAllowMultiLevelGroups()>checked</cfif>></td>
  </tr>
  <!--- <tr class="t3h">
	<td>LOB Label:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="text" value="#appSettings.getLOB_label()#" name="LOB_label"></td>
  </tr> --->
  <tr class="t3h">
	<td>Check Order Class:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="CheckOrderClass" <cfif appSettings.getCheckOrderClass()>checked</cfif>></td>
  </tr>
  <tr class="t3h">
	<td>Order Class Value:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="text" value="#appSettings.getOrderClassValue()#" name="OrderClassValue"></td>
  </tr>
  <tr class="t3h">
	<td>Template Codes On:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="templatecodes_on" <cfif appSettings.gettemplatecodes_on()>checked</cfif>></td>
  </tr>
  <!--- Removed with label 19409, set DEFAULT TO OFF
  <tr>
	<td>Show USDANOI Report info:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="USDANOIEnabled" <cfif appSettings.getUSDANOIEnabled()>checked</cfif>></td>
  </tr>
  --->
  <tr class="t3h">
	<td>Invoice - Restrict search on broker filter:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="invoiceBrokerFilterRestrict" <cfif appSettings.getInvoiceBrokerFilterRestrict()>checked</cfif>></td>
  </tr>
  <tr class="t3h">
	<td>Customer search Rebate Recipient On:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="CustsearchRebaterecipientOn" <cfif appSettings.getCustsearchRebaterecipientOn()>checked</cfif>></td>
  </tr>
  <!--- Billback program restriction --->
  <tr class="t3h">
	<td>Restrict one program per billback:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="One_Program_Per_Billback" <cfif appSettings.getOneProgramPerBillback()>checked</cfif>></td>
  </tr>
<!--- D68872 :: Restricting only one component per billback in upload and manual process START --->
  <tr valign="top">
	<td><span onmouseout="popUpTip(event,'tRestrict_One_Component_Per_Billback');" onmouseover="popUpTip(event,'tRestrict_One_Component_Per_Billback');">Restrict one component per billback:<img src="/images/help_small.gif" />
		  </span></td>
	<td>&nbsp; <div id="tRestrict_One_Component_Per_Billback" class="tip">
		  When this setting is ON, the application treats the above setting "Restrict one program per billback" as ON and will not allow the user to add more than one program in the billback.
	</div> </td>
	<td align="left"><input value="1" type="checkbox" name="Restrict_One_Component_Per_Billback"  <cfif request.settings.Restrict_One_Component_Per_Billback eq '1'>checked</cfif>></td>
  </tr>
 <!--- D68872 :: Restricting only one component per billback in upload and manual process END --->

  <tr class="t3h">
	<td>Spending Cap Version:<br>
	(default=0) 0=old scheme, 1=new scheme where spending cap scheme will display products at a group level
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="text" value="#appSettings.getSpendingCapVersion()#" name="SpendingCapVersion" size="1" maxlength="1" onkeypress="javaScript: return Allow_Key_List('0123456789');" onblur="if(isNaN(parseInt(this.value)))this.value=0;"></td>
  </tr>
  <!--- Removed with label 19409, set DEFAULT TO ON
  <tr valign="top">
	<td>Capture Groups On Save:<br>
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="Capture_Groups_On_Save" <cfif appSettings.getCaptureGroupsOnSave()>checked</cfif>></td>
  </tr>
  --->
  <!--- Removed with label 19409, set DEFAULT TO OFF
	<tr valign="top">
	<td>Invoices, Display OI:<br>
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="ForInvoicesDisplayOI" <cfif appSettings.getForInvoicesDisplayOI()>checked</cfif>></td>
  </tr>
  --->
  <tr class="t3h">
	<td>Billback: Check Pay To:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="BBCheckPayTo" <cfif appSettings.getBBCheckPayTo()>checked</cfif>></td>
  </tr>
  <tr class="t3h">
	<td>Program Lump sum: Display  customers and products in view program (default=0)
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="pgmLumpsumDetailedDisplay" <cfif appSettings.getPgmLumpsumDetailedDisplay()>checked</cfif>></td>
  </tr>

  <tr valign="top">
	<td>Allow users to revise expired programs <Br>(not tested with Billbacks)
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="Renew_expired_programs" <cfif appSettings.getRenew_expired_programs()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>Manual selection for power punch discount type
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="BB_PP_Manual_Discount" <cfif appSettings.getBB_PP_Manual_Discount()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>Show BSA Operators:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox" value="1" name="Show_BSA_Operators" <cfif appSettings.getShowBSAOperators()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>External Webservice URL:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="text" size="25" maxlength="225" value="#appSettings.getExternalWebserviceURL()#" name="ExternalWebserviceURL"></td>
  </tr>
  <tr valign="top">
	<td>Webserver&nbsp;-&nbsp;Internal IP Address or Name:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="text" size="25" maxlength="50" value="#appSettings.getWebserverInternalIPAddress()#" name="WebserverInternalIPAddress"></td>
  </tr>
  <tr valign="top">
	<td>Set days before auto renew in program wizard:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="checkbox"  value="1" name="AutoRenewSpaninPW" <cfif appSettings.getAutoRenewSpaninPW() IS 1>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>Program: Disable edit while sending to client
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="pgmDisableEditWhileSendingToClient" <cfif appSettings.getPgmDisableEditWhileSendingToClient()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>Operating Group On
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="operatingGroupOn" <cfif appSettings.getOperatingGroupOn()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>Search Sequence On
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="searchSequenceOn" <cfif appSettings.getSearchSequenceOn()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>Program: If pricing level 1 = groups, <br/>allow only products at lower level
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="pgmGrpsOnlyProdAtLowerLevel" <cfif appSettings.getPgmGrpsOnlyProdAtLowerLevel()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>Group By Group Type:
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <select name="Group_By_Group_Type">
		<cfloop query="qGetProductGroupTypes">
		  <option value="#Product_Group_Level_Type#" <cfif appSettings.getGroupByGroupType() eq Product_Group_Level_Type>selected</cfif>>#Group_Level_Desc#</option>
		</cfloop>
	  </select>
	</td>
  </tr>
  <!------ <tr>
	<td>App Numbering Scheme: (default = 0)<br>
	0 = Regular(000), 1 = new scheme
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="text" size="1" maxlength="1" name="appNumberingScheme" value="#appSettings.getAppNumberingScheme()#" size="1" maxlength="1" onkeypress="javaScript: return Allow_Key_List('0123456789');" onblur="if(isNaN(parseInt(this.value)))this.value=0;"></td>
  </tr> ----->
  <tr valign="top">
	<td>Pricing Docs List (for not sending email):
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="text" size="25" value="#appSettings.getpricingtemplatelist()#" name="pricing_template_list"></td>
  </tr>
  <tr valign="top">
	<td>Show Projects ScoreCard:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="ShowProjectsScoreCard" <cfif appSettings.getShowProjectsScoreCard()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>Show Revision Report in Program Scorecard:<br>Will replace the application var
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="pgmScorecardRevisionReport" <cfif appSettings.getPgmScorecardRevisionReport()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>Restrict invoice search result based on user position
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="invoicePositionRestriction" <cfif appSettings.getInvoicePositionRestriction()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>View/Create Program: Display Company Name
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="pgmViewDisplaySPRAddress2" <cfif appSettings.getPgmViewDisplaySPRAddress2()>checked</cfif>></td>
  </tr>
  <!---option for which hierarchy levels to display in bid request reporting --->
  <!---get the number of Hierarchy levels--->
  <cfset numOfHierLevels = CreateObject("component", "components.products.Group.DataManager").getNumberHierarchyLevels() />
  <cfif  numOfHierLevels GT 0>
  <tr valign="top">
	<td>
	  Proposal Hierarchy Levels:
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <select name="Bid_Request_Hierarchy_Level" multiple>
		<cfloop index="hierIndx" from="1" to="#numOfHierLevels#">
		  <option value="#hierIndx#" <cfif ListFindNoCase(appSettings.getBidRequestHierarchyLevel(), hierIndx)>selected</cfif>>Hierarchy Level #hierIndx#</option>
		</cfloop>
	  </select>
	</td>
  </tr>
  </cfif>
<!---  D36100 :: MOVE 'Letters Accepted By text' SETTING TO BE AT THE TEMPLATE LEVEL
  <tr valign="top">
	<td>Letters Accepted By text:<br>
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="text" size="25" value="#appSettings.getLettersAcceptedBy()#" name="Letters_Accepted_By"></td>
  </tr><br>--->
  <tr valign="top">
	<td>From Address for letters (do not use):</td>
	<td>&nbsp;</td>
	<td><textarea name="Letters_Address" cols="50" rows="5">#appSettings.getLettersAddress()#</textarea></td>
  </tr>
  <tr valign="top">
	<td>View Edited Approved Program Margins Report:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="view_approved_margins_report" <cfif appSettings.getviewapprovedmarginsreport()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>View Program: Display both rate UOM
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="pgmDisplayBothRateUOM" <cfif appSettings.getPgmDisplayBothRateUOM()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>Cancel all program versions:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="cancelallprogramversions" <cfif appSettings.getcancelallprogramversions()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>Display Only Assigned Deductions:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Display_Only_Assigned_Deductions" <cfif appSettings.getDisplayOnlyAssignedDeductions()>checked</cfif>></td>
  </tr>

  <tr valign="top">
	<td>Show Document Mapping
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="ShowMapping" <cfif appSettings.getShowMapping()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>Avoid Shared Products in LumpSum:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Avoid_Shared_Products_in_LumpSum" <cfif appSettings.getAvoidSharedProductsinLumpSum()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>Display Clients Help Desk Info:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="display_clients_help_desk_info" <cfif appSettings.getdisplayclientshelpdeskinfo()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>Clients Help Desk Info:</td>
	<td>&nbsp;</td>
	<td><textarea name="Clients_Help_Desk_Info" cols="50" rows="3">#appSettings.getClientsHelpDeskInfo()#</textarea></td>
  </tr>
  <tr valign="top">
	<td>Add Sales Tax on Billbacks:
	</td>
	<td>&nbsp; </td>
	<td align="left">
	<select name="Billbacks_Sales_Tax">
		<option value="0" <cfif appSettings.getBillbacksSalesTax() EQ 0>selected</cfif>>No</option>
		<option value="1" <cfif appSettings.getBillbacksSalesTax() EQ 1>selected</cfif>>Optional</option>
		<option value="2" <cfif appSettings.getBillbacksSalesTax() EQ 2>selected</cfif>>Required</option>
	</select>
	</td>
  </tr>
  <tr valign="top">
	<td>Revision Report UOM:
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="radio" name="revision_report_uom" <cfif appSettings.getrevisionreportuom() eq 1>checked</cfif>>CS &nbsp;&nbsp;
	<input value="2" type="radio" name="revision_report_uom" <cfif appSettings.getrevisionreportuom() eq 2>checked</cfif>>LB &nbsp;&nbsp;<!---28326--->
	<input value="3" type="radio" name="revision_report_uom" <cfif appSettings.getrevisionreportuom() eq 3>checked</cfif>>Program UOM</td>
	<td>&nbsp; </td>
  </tr>
  <tr valign="top">
	<td>Display zeros on View Program Page:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="display_zeros_view_program" <cfif appSettings.getdisplayzerosviewprogram()>checked</cfif>></td>
  </tr>

  <tr valign="top">
	<td>Show links for CDP & Accrual:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="ShowUploadAccrual" <cfif appSettings.getShowUploadAccrual()>checked</cfif>></td>
  </tr>

  <!--- Removed with label 19409, set DEFAULT TO OFF
  <tr valign="top"><!---Dev Note: BJF 7963 & 10139 --->
	<td>Use Accrual Log for Trade Checkbook<br>Check with developer to ensure Accrual Log is active:
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <select name="Use_AccrualLog_For_TC">
		<option value="0" <cfif appSettings.getUse_AccrualLog_For_TC() EQ 0>selected</cfif>>OFF</option>
		<option value="1" <cfif appSettings.getUse_AccrualLog_For_TC() EQ 1>selected</cfif>>ON</option>
	  </select>
	</td>
  </tr>
  --->

  <tr valign="top">
	<td>Payment History On:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="payment_history_on" <cfif appSettings.getpaymenthistoryon()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>Allow Vendor Search in BB Payee page:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Vendor_Search_In_BB_Payee_Page" <cfif appSettings.getVendorSearchInBBPayeePage()>checked</cfif>></td>
  </tr>
  <tr class="t1h">
	<td>App level Allow Vendor Master Search:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="BB_Allow_Vendor_Master_Search" <cfif appSettings.getBBAllowVendorMasterSearch()>checked</cfif>></td>
  </tr>
  <tr class="t1h">
	<td>App level Allow Vendor Xref Search:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="BB_Allow_Vendor_Cross_Ref_Search" <cfif appSettings.getBBAllowVendorCrossRefSearch()>checked</cfif>></td>
  </tr>
  <tr class="t1h">
	<td>Proposal Use Price By Date:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="BidRequest_Use_Price_ByDate" <cfif appSettings.getBidRequestUsePriceByDate()>checked</cfif>></td>
  </tr>
  <tr class="t1h">
	<td>Do not Allow Revisions Untill Success Acknowledgement from SAP:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="DontRevise_Untill_SAP_OKack" <cfif appSettings.getDontReviseUntillSAPokAck()>checked</cfif>></td>
  </tr>
  <tr class="t1h">
	<td>Close Deduction with Same distributor and Equal Amount BillBack:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="DD_Close_With_Equal_BB_Amt" <cfif appSettings.getDDCloseWithEqualBBAmt()>checked</cfif>></td>
  </tr>
  <!--- removed with label 18746
  <tr valign="top">
	<td>Upon approval, email all users associated to the ship to:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="send_distributor_broker_email" <cfif appSettings.getsenddistributorbrokeremail()>checked</cfif>></td>
  </tr>
  --->
  <!--- Removed with label 19969, set DEFAULT TO OFF
  <tr valign="top">
	<td>Display Requester/Approver:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Requester_Approver" <cfif appSettings.get_Requester_Approver()>checked</cfif>></td>
  </tr>

  <tr valign="top">
	<td>Display Requester/Approver Position:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Requester_Approver_Position" <cfif appSettings.get_Requester_Approver_Position()>checked</cfif>></td>
  </tr>
  --->
  <cfif request.AccessStructure.User_Rights_ID EQ 9999>
  <tr class="t1h">
	<td>Hide BSA Users:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Hide_BSA_Users" <cfif appSettings.getHide_BSA_Users()>checked</cfif>></td>
  </tr>
  </cfif>
<!--- Ben[11/06/07] - Removed --->
<!---   <tr valign="top">
	<td>Show Payment History Report:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Report_Payment_History" <cfif appSettings.get_Report_Payment_History()>checked</cfif>></td>
  </tr> --->
  <tr class="t1h">
	<td>Allow Write-Off in Deductions Tool:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="DD_Allow_Write_Off" <cfif appSettings.getDDAllowWriteOff()>checked</cfif>></td>
  </tr>
  <tr class="t1h">
	<td>Set Default Uploaded Document Privacy to Off:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Upload_Document_Privacy_Off" <cfif appSettings.getUploadDocumentPrivacyOff()>checked</cfif>></td> <!--- Dev Note: CPM 8275 --->
  </tr>
  <tr class="t1h">
	<td>Documents, Display Upload Form:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Documents_Display_Upload_Form" <cfif appSettings.getDocumentsDisplayUploadForm()>checked</cfif>></td>
  </tr>
  <tr class="t1h">
	<td>Show Manager Details On View Program Page:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="ShowManagerDetailsOnViewProgram" <cfif appSettings.getShowManagerDetailsOnViewProgram()>checked</cfif>></td> <!--- Dev Note: CPM 8275 --->
  </tr>

  <tr class="t1h">
	<td>Send DD Reject in 1510:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="DD_Sent_Reject_In_1510" <cfif appSettings.getDDSentRejectIn1510()>checked</cfif>></td>
  </tr>
  <tr class="t1h">
	<td>View Program Sort By: <i>Applicable for rebates section of display_view_program_html.cfm</i> ("PricingLevel,Item"=0;"Description"=1)</td>
	<td>&nbsp; </td>
	<td align="left">
	  <select name="ViewPgmSortBy">
		<option value="0" name="ViewPgmSortBy" <cfif appSettings.getViewPgmSortBy() EQ 0>selected</cfif>>PricingLevel,Item</option>
		<option value="1" name="ViewPgmSortBy" <cfif appSettings.getViewPgmSortBy() EQ 1>selected</cfif>>Description</option>
	  </select></td>
  </tr>
  <tr class="t1h">
	<td>Program Post-approval Status in Use and Add Legacy ID to Approved Programs:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="pgmPostApprovalStatus" <cfif appSettings.getPgmPostApprovalStatus()>checked</cfif>></td> <!--- Dev Note: CPM 8275 --->
  </tr>
  <tr class="t1h">
	<td>Program Post-approval Status Type:
	<br>(0 = orginal logic, both status available &nbsp;1 = status 2 not available)
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="text" size="1" maxlength="1" name="pgmPostApprovalStatusType" value="#appSettings.getPgmPostApprovalStatusType()#"></td>
  </tr>
  <tr class="t1h">
	<td>Number of days for Mini Item Master:</td>
	<td>&nbsp; </td>
	<td align="left"><input value="#appSettings.getNumberOfDaysForMiniItemMaster()#" type="text" name="NumberOfDaysForMiniItemMaster"></td> <!--- Dev Note: Milan 8471 --->
  </tr><!--- Dev Note: Milan 8471 --->
  <tr class="t1h">
	<td>Display Evaluation Notes:</td>
	<td>&nbsp; </td>
	<td align="left">
	  <select name="Display_Evaluation_Notes">
		<option value="0" <cfif appSettings.getDisplayEvaluationNotes() EQ 0>selected</cfif>>OFF</option>
		<option value="1" <cfif appSettings.getDisplayEvaluationNotes() EQ 1>selected</cfif>>ON</option>
	  </select>
	</td>
  </tr>
  <tr class="t1h">
	<td>BidRequest - Display Allowance on View Program:</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="BidRequest_Display_Allowance" <cfif appSettings.getBidRequestDisplayAllowance()>checked</cfif>></td> <!--- Dev Note: CPM 8275 --->
  </tr>
  <tr class="t1h">
	<td>Modify Agree Program:</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="modify_agree_program" <cfif appSettings.getmodifyagreeprogram()>checked</cfif>></td>
  </tr>
 <!---D50074 :: Viewing and Editing prior program versions START--->
  <tr class="t1h">
	<td>Modify Expired Programs
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Modify_Expired_Programs" <cfif appSettings.getModifyExpiredPrograms()>checked</cfif>></td>
  </tr>
<!---D50074 :: Viewing and Editing prior program versions END--->
 <!---D43661 :: Program RFA status - disable pages and require user to Reset to make any changes START--->
  <tr class="t1h">
	<td>Program - Disable pages in RFA, reset to make changes:</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="disable_pages_in_rfa" <cfif appSettings.getdisablepagesinrfa()>checked</cfif>></td>
  </tr>
 <!---D43661 :: Program RFA status - disable pages and require user to Reset to make any changes END--->
  <tr class="t1h">
	<td>Remove Broker Selection:
	</td>
	<td>&nbsp; </td>
	<td align="left"><select name="Remove_Broker_Selection">
		<option value="0" <cfif appSettings.getRemoveBrokerSelection() EQ 0>selected</cfif>>OFF</option>
		<option value="1" <cfif appSettings.getRemoveBrokerSelection() EQ 1>selected</cfif>>ON</option>
	  </select>
	</td>
  </tr>
  <tr class="t1h">
	<td>Display Eligible RSP:
	</td>
	<td>&nbsp; </td>
	<td align="left"><select name="Display_Eligible_RSP">
		<option value="0" <cfif appSettings.getDisplayEligibleRSP() EQ 0>selected</cfif>>OFF</option>
		<option value="1" <cfif appSettings.getDisplayEligibleRSP() EQ 1>selected</cfif>>ON</option>
	  </select>
	</td>
  </tr>
  <tr class="t1h">
	<td>BidRequest - Use Item-Customer Pricing:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Use_Item_Cust_Price" <cfif appSettings.getUseItemCustPrice()>checked</cfif>></td> <!--- Dev Note: CPM 8275 --->
  </tr>
  <tr class="t1h">
	<td>Billback: Display Resubmit Link:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="BBDisplayResubmit" <cfif appSettings.getBBDisplayResubmit()>checked</cfif>></td>
  </tr>
  <tr class="t1h">
	<td>Billback Manual Void:   <!--- 30916 --->
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="BBAllowReverse" <cfif appSettings.getBBAllowReverse()>checked</cfif>></td>
  </tr>
  <tr class="t1h"> <!--- D86006 Billback - manual void when billback has DD attached to it --->
	<td>Billback Manual Void ? detach DD:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="BB_Manual_VOID_Detach_DD" <cfif request.settings.BB_Manual_VOID_Detach_DD eq '1'>checked</cfif>></td>
  </tr>
  <tr class="t1h">   <!--- 48779 --->
	<td>Manual Void Credit Request:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Manual_Void_Credit_Request" <cfif request.settings.Manual_Void_Credit_Request eq '1'>checked</cfif>></td>
  </tr>
  <tr class="t1h">
	<td>Allow Multiple Billback association per Deduction:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Multiple_BB_Per_Deduction" <cfif appSettings.getMultiple_BB_Per_Deduction()>checked</cfif>></td>
  </tr>
  <tr class="t1h">
	<td>Deduction - Billback Association Based on Same Reference Num:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Match_BB_DD_Based_On_Same_ReferenceNum" <cfif appSettings.getMatch_BB_DD_Based_On_Same_ReferenceNum()>checked</cfif>></td>
  </tr>
  <tr class="t1h">
	<td>Deduction - Restrict Reason Code By Closing_method
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Restrict_DD_Reason_Code_By_Closing_method" <cfif appSettings.getRestrict_DD_Reason_Code_By_Closing_method()>checked</cfif>></td>
  </tr>
   <tr class="t1h">
	<td>Deduction Distributor selection only allows Ship To's that are Associated with the Bill To:</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Deduction_Ship_To_Bill_To_Association_Required" <cfif request.settings.Deduction_Ship_To_Bill_To_Association_Required eq '1'>checked</cfif>></td>
  </tr>

  <!--- Removed with label 19969, set DEFAULT TO OFF
  <!--- Dev Note: BJF 9313 --->
  <tr valign="top">
	<td>View Trade Checkbook:
	</td>
	<td>&nbsp; </td>
	<td align="left"><select name="View_Trade_Checkbook">
		<option value="0" <cfif appSettings.getView_Trade_Checkbook() EQ 0>selected</cfif>>OFF</option>
		<option value="1" <cfif appSettings.getView_Trade_Checkbook() EQ 1>selected</cfif>>ON</option>
	  </select>
	</td>
  </tr>


  <!--- Dev Note: BJF 9313 --->
  <tr valign="top">
	<td>View Auto Checkbook:
	</td>
	<td>&nbsp; </td>
	<td align="left"><select name="View_Auto_Checkbook">
		<option value="0" <cfif appSettings.getView_Auto_Checkbook() EQ 0>selected</cfif>>OFF</option>
		<option value="1" <cfif appSettings.getView_Auto_Checkbook() EQ 1>selected</cfif>>ON</option>
	  </select>
	</td>
  </tr>
  --->
  <!--- Removed with label 19409, set DEFAULT TO OFF
  <!--- Dev Note: Clay 9254 --->
  <tr valign="top" title="This feature enables sending an attached Welcome Letter to newly created users.">
	<td>Welcome Letter On:
	</td>
	<td>&nbsp; </td>
	<td align="left">
		<input name="WelcomeLetterOn" type="checkbox" value="1" <cfif appSettings.getWelcomeLetterOn()>checked</cfif> >On
	</td>
  </tr>
  --->
  <tr class="t1h">
	<td>BB Payment Request Duplicate Check <br/>(Vendor_ID & BB_Reference Unique):
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="BB_Pay_Req_Dup_Check" <cfif appSettings.getBB_Pay_Req_Dup_Check()>checked</cfif>></td>
  </tr>
<!---   <tr valign="top">
	<td>Template Notes Availability:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Template_Notes_Availability" <cfif appSettings.getTemplate_Notes_Availability()>checked</cfif>></td>
  </tr>
   ---> <!--- BJF: Removed with label 13333  --->
  <!--- Dev Note: Clay 8606   --->
  <!----
  <tr valign="top">
	<td>Budget:Budgets On:
	</td>
	<td>&nbsp; </td>
	<td align="left">
		<input type="checkbox" name="BudgetsOn" value="1" <cfif appSettings.getBudgetsOn() EQ 1>Checked</cfif>>On
	</td>
  </tr>

  <tr valign="top">
	<td>Budget Relationship to Programs:
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <select name="budgetRelationshipToPrograms">
		<option value="1" <cfif appSettings.getBudgetRelationshipToPrograms() EQ 1>SELECTED</cfif>>Program Level</option>
		<option value="2" <cfif appSettings.getBudgetRelationshipToPrograms() EQ 2>SELECTED</cfif>>Discount Type Level</option>
	  </select>
	</td>
  </tr>
  <tr valign="top">
	<td>Budget: Claim Allocation Method:
	</td>
	<td>&nbsp; </td>
	<td align="left">
		<input type="checkbox" name="claimAllocationMethodItem" value="1" <cfif appSettings.getClaimAllocationMethodItem() EQ 1>CHECKED</cfif>>Item Allocation (Volumetric)<br>
		<input type="checkbox" name="claimAllocationMethodFixed" value="1" <cfif appSettings.getClaimAllocationMethodFixed() EQ 1>CHECKED</cfif>>Fixed Allocation (Predetermined)<br>
		<input type="checkbox" name="claimAllocationMethodFund" value="1" <cfif appSettings.getClaimAllocationMethodFund() EQ 1>CHECKED</cfif>>Fund Allocation (Freeform)<br>
	</td>
  </tr>
	<tr valign="top">
	<td>Budget:Select Budgets On:
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <select name="selectBudgetsOn">
		<option value="1" <cfif appSettings.getSelectBudgetsOn() EQ 1>SELECTED</cfif>>Commitments</option>
		<option value="2" <cfif appSettings.getSelectBudgetsOn() EQ 2>SELECTED</cfif>>Settlements</option>
	  </select>
	</td>
  </tr>
  ---->
  <!--- Removed with label 19409, set DEFAULT TO OFF
  <tr valign="top"><!--- Dev Note: Milan 9956   --->
	<td>Allow one component for pullbacks:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Allow_One_Component_for_Pullbacks" <cfif appSettings.getAllowOneComponentforPullbacks()>checked</cfif>></td>
  </tr><!--- End Note: Milan 9956   --->
  --->
  <tr class="t1h">
	<td>Program: Special Revision Flag: (default=0)
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="programSpecialRevisionFlag" <cfif appSettings.getProgramSpecialRevisionFlag()>checked</cfif>></td>
  </tr>
  <!--- Removed with label 19409, set DEFAULT TO OFF
  <tr valign="top">
	<td>Display Group Level Billback in Templates: (default=off) <BR><em>Pactiv specific as it custom for their product hierarchies</em>
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="GroupLevelBillback" <cfif appSettings.getGroupLevelBillback()>checked</cfif>></td>
  </tr>
  --->
  <tr class="t1h">
	<td>Allow Negative Billbacks:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Allow_Negative_Billback" <cfif appSettings.getAllow_Negative_Billback()>checked</cfif>></td>
  </tr>
  <tr class="t1h">
	<td>Allow Multi Distributor Billbacks:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Multi_Distributor_BB" <cfif appSettings.getMultiDistributorBB()>checked</cfif>></td>
  </tr>
  <!--- BJF D10608 --->
  <tr class="t1h">
	<td>Claims against "lost" bid request items are deviated:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Lost_Bids_Deviated" <cfif appSettings.getLost_Bids_Deviated()>checked</cfif>></td>
  </tr>

  <!--- CPM 10941 --->
  <tr class="t1h">
	<td>Freight Calculator On:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Freight_Calculator_On" <cfif appSettings.getFreight_Calculator_On()>checked</cfif>></td>
  </tr>
  <!--- BDensmore 10788 --->
  <tr class="t1h">
	<td>Show One Page Claim Form:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="One_Page_Claim_Form" <cfif appSettings.getOnePageClaimForm()>checked</cfif>></td>
  </tr>
  <tr class="t1h">
	<td>Login Page Logo Path:(default = /images/Logon_Blacksmith/index_02.gif)
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="text" maxlength="150" name="loginPageLogoPath" value="#appSettings.getLoginPageLogoPath()#"></td>
  </tr>
  <!--- 31616 -Add favorite icon to URL address line --->
  <tr class="t1h">
	<td>Favicon Path:(default = /Images/favicon/favicon.ico)
	</td>
	<td>&nbsp; </td>
	<td align="left"><input type="text" maxlength="150" name="Favicon_Path" value="#appSettings.getFaviconPath()#"></td>
  </tr>

  <tr class="t1h">
	<td>DD_Show_Delete:</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="DD_Show_Delete" <cfif appSettings.getDD_Show_Delete()>checked</cfif>></td>
  </tr>
  <tr class="t1h">
	<td>DD_Show_ReOpen:</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="DD_Show_ReOpen" <cfif appSettings.getDD_Show_ReOpen()>checked</cfif>></td>
  </tr>
 <!--- D42846 :: Deduction tool upgrades START --->
   <tr class="t1h">
	<td>Allow deduction Quick Update functionality for Closed DD:</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="deduction_Quick_Update" <cfif appSettings.getDeductionQuickUpdate()>checked</cfif>></td>
  </tr>
 <!--- D42846 :: Deduction tool upgrades END --->
   <tr class="t1h">
	<td>Allow deduction Quick Update functionality for New, Open, RFA DD:</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="deduction_Quick_Update_For_New_Open_RFA" <cfif request.settings.deduction_Quick_Update_For_New_Open_RFA eq '1'>checked</cfif>></td>
  </tr>
  <tr class="t1h">
	<td>Reopen parent or child on split deduction:(This should be based on which record gets interfaced)
	</td>
	<td>&nbsp; </td>
	<td align="left">
	<select name="DD_Reopen_Parent">
	  <option value="0" <cfif appSettings.getDDReopenParent() eq 0>selected</cfif>>Child</option>
	  <option value="1" <cfif appSettings.getDDReopenParent() eq 1>selected</cfif>>Parent</option>
	</select>
  </td>
  </tr>
  <tr>
	<td>DD_Show_Reject:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="DD_Show_Reject" <cfif appSettings.getDD_Show_Reject()>checked</cfif>></td>
  </tr>
  <tr>
	<td>DD_Show_Program:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="DD_Show_Program" <cfif appSettings.getDD_Show_Program()>checked</cfif>></td>
  </tr>
  <tr>
	<td>DD_Show_Invoices:
	</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="DD_Show_Invoices" <cfif appSettings.getDD_Show_Invoices()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>Create a task in the DD Analyst's To Do List when attachment added to a DD:</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="AddTodoOnDocAttach" <cfif appSettings.getAddTodoOnDocAttach()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>Include user's email in the CC line:</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="IncludeUsersEmailAuto" <cfif appSettings.getIncludeUsersEmailAuto()>checked</cfif>></td>
  </tr>
  <tr>
	<td>Release Settlement On:</td>
	<td>&nbsp;</td>
	<td><input value="1" type="Checkbox" name="ReleaseSettlement" <cfif appSettings.getReleaseSettlement()>checked</cfif> > </td>
  </tr>
  <!--- 66094 :: Release Settlement:  Update condition requiring OI Program Ack START--->
  <tr>
	<td>Release Settlement Program Availability:</td>
	<td>&nbsp;</td>
	<td>
		<select name="Release_Settlement_Availability">
			<option value="1" <cfif request.settings.Release_Settlement_Availability eq '1'>SELECTED</CFIF>>Only after ack</option>
			<option value="2" <cfif request.settings.Release_Settlement_Availability eq '2'>SELECTED</CFIF>>Always</option>
		</select>
	</td>
  </tr>

  <tr>
    <td>Release Settlement - allow revision after release:</td>
    <td>&nbsp;</td>
    <td>
      <input value="1" type="Checkbox" name="release_settlement_allow_revision" <cfif request.settings.release_settlement_allow_revision eq '1'>checked</cfif> >
    </td>
  </tr>

  <!--- 66094 :: Release Settlement:  Update condition requiring OI Program Ack END--->
  <tr valign="top">
	<td>Disable AutoComplete on Login:</td><!---  Dev Note:  MarkS 11287 --->
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Disable_Auto_Login" <cfif appSettings.getDisableAutoLogin()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>Forbid Same Lump Sum Component in Program:</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="same_lump_sum_component_in_program" <cfif appSettings.getLumpSumComponentInProgram()>checked</cfif>></td>
  </tr>
<!--- D96452 HF Bundle - Restrict from Selecting Comp Twice --->
  <tr valign="top">
	<td>Forbid Same Component / Same Pays To in Program:</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Forbid_Same_Component_Same_Pays_To_In_Program" <cfif request.settings.Forbid_Same_Component_Same_Pays_To_In_Program eq '1'>checked</cfif>></td>
  </tr>

  <!--- Dev Note: BJF D11527 --->
  <tr valign="top">
	<td>Allow Percent Operator Programs:(not recommended)</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Allow_Percent_Operator_Programs" <cfif appSettings.getAllow_Percent_Operator_Programs()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>UOM #UCASE(EachInfo.Unit_of_Measure_Desc_Singular)#(#UCASE(EachInfo.Abbreviation)#) Available:(default=off)</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="UOMEAAvailable" <cfif appSettings.getUOMEAAvailable()>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>Display distributors in position tree:(default=on)</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Position_Tree_Display_Distributor" <cfif appSettings.getPosition_Tree_Display_Distributor()>checked</cfif>></td>
  </tr>
  <!--- removed with label  18746
  <tr valign="top">
	<td>Use Updated Billback Upload:<Br>(default=off)</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="BB_UPLOAD_UPDATED" <cfif appSettings.getBB_UPLOAD_UPDATED()>checked</cfif>></td>
  </tr>
  --->
	<!--- Dev Note: BSD D11643 Turn Split Billbacks on or off --->
	<tr valign="top">
	<input value="#appSettings.getBB_UPLOAD_UPDATED()#" type="hidden" name="BB_UPLOAD_UPDATED">
	<td>Split Billbacks:</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Split_Billbacks" <cfif appSettings.getSplitBillbacks()>checked</cfif>></td>
  </tr>

	<!--- Dev Note: Tim Ford 28595 Turn Split Billbacks on or off --->
	<tr valign="top">
	<td> BB Search Flex - only display parent billback in search results:</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Display_Only_Billback_Parent" <cfif appSettings.getDisplayOnlyBillbackParent()>checked</cfif>></td>
  </tr>

  <!---
	43997: App Setting 'UNIPRO_450 Auto Pay" displays multiple times/Anand Rao/21-Jul-2014
	This has been moved to its own alias source screen under administration.

  <tr valign="top">
	<td  class="topl" align="center">BB Alias Source Type</td>
	<td class="topm">&nbsp; </td>
	<td class="topr">&nbsp; </td>
  </tr>
  <cfset i = 0 />
  <cfloop query = "qBBAliasSourceType">
	<tr valign="top">
	  <cfif i eq 0>
	  <td class="topl">#qBBAliasSourceType.Source_Code_Display# </td>
	  <td align="left" class="topm">&nbsp; </td>
	  <td align="left" class="topr">
	  <cfelse>
		<td class2="left"> #qBBAliasSourceType.Source_Code_Display# </td>
	  <td class="top">&nbsp; </td>
	  <td align="left" class2="right">
	</cfif>
	  <input value="#qBBAliasSourceType.BB_Claim_Source_Xref_ID#" type="checkbox" name="BBAliasSourceType" <cfif qBBAliasSourceType.active EQ 1>checked</cfif>>
	</td>
	</tr>
	<cfset i = i+1 />
  </cfloop>
  <input type="hidden" name="BBAliasSourceTypeIDs" value="#BBClaimSourceXrefIDs#"> --->

  <cfset renderDivider("Auto Pay Specific Labels")>

<!---   <tr valign="top">
	<td  class="topl" align="center">Auto Pay Specific Labels </td>
	<td  class="topm">&nbsp; </td>
	<td align="left"  class="topr">&nbsp; </td>
  </tr> --->
	<!--- Dev Note: D11427 --->
  <tr valign="top">
	<td  class2="topl"><span onmouseout="popUpTip(event,'tBB_Auto_report');" onmouseover="popUpTip(event,'tBB_Auto_report');">
	  Auto Pay Report Process:<img src="/images/help_small.gif" />
		  </span></td>
	<td  class2="topm">&nbsp; <div id="tBB_Auto_report" class="tip">
		  Turn Auto Pay Features On or Off.  This Also requires at least one Template to be configured with an "is Auto Pay" payment type (Claim Mechanic).
	</div></td>
	<td align="left"  class2="topr"><input value="1" type="checkbox" name="BB_Auto_report" <cfif appSettings.getBBAutoReport()>checked</cfif>></td>
  </tr>

  <tr valign="top">
	<td class2="left"><span onmouseout="popUpTip(event,'tBBAutoReportisManuallyConfigured');" onmouseover="popUpTip(event,'tBBAutoReportisManuallyConfigured');">
	Billback Auto Report Is Manually Configured:<img src="/images/help_small.gif" />
		  </span></td>
	<td>&nbsp; <div id="tBBAutoReportisManuallyConfigured" class="tip">
		  "Auto Pay Light".  This setting configures Auto pay so that the user must manually select Programs and Start & End dates for Auto Pay to calculate payments against.  The Above Switch "Auto Pay Report Process" must be on as well.
	</div></td>
	<td align="left" class2="right"><input value="1" type="checkbox" name="BBAutoReportisManuallyConfigured" <cfif appSettings.getBBAutoReportisManuallyConfigured()>checked</cfif>></td>
  </tr>

  <tr valign="top">
	<td class2="left"><span onmouseout="popUpTip(event,'tBBAutoReportAllowManual');" onmouseover="popUpTip(event,'tBBAutoReportAllowManual');">
	Auto Pay - Allow Manual along with full auto:<img src="/images/help_small.gif" />
		  </span></td>
	<td>&nbsp; <div id="tBBAutoReportAllowManual" class="tip">
		  This setting allows users to create manual Auto pay even when "Auto Pay Light" is OFF.
	</div></td>
	<td align="left" class2="right"><input value="1" type="checkbox" name="BBAutoReportAllowManual" <cfif appSettings.getBBAutoReportAllowManual()>checked</cfif>></td>
  </tr>

	<!--- Dev Note: D12575 --->
  <tr valign="top">
	<td class2="left"><span onmouseout="popUpTip(event,'tBB_Auto_Report_Start_Date');" onmouseover="popUpTip(event,'tBB_Auto_Report_Start_Date');">
	Auto Pay Report Start Date (mm/dd/yyyy):<img src="/images/help_small.gif" />
		  </span></td>
	<td>&nbsp; <div id="tBB_Auto_Report_Start_Date" class="tip">
		  This is the Hard start date to Auto Pay.  Invoices prior to this date are not considered.  This helps performance and is useful for "go live" if payments have already been made outside of Auto pay and we do not want to overpay.
	</div></td>
	<td align="left" class2="right"><input type="text" name="BB_Auto_Report_Start_Date" value="#dateformat(appSettings.getBBAutoReportStartDate(),'mm/dd/yyyy')#" onblur="if(isDate(this.value,'mm/dd/yyyy')==0){alert('Please enter a date (mm/dd/yyyy)');this.focus();}"></td>
  </tr>

	  <!--- Dev Note: D18880 --->
  <tr valign="top">
	<td  class2="left"><span onmouseout="popUpTip(event,'tBB_Auto_Pay_Customer_Group_In_Invoice');" onmouseover="popUpTip(event,'tBB_Auto_Pay_Customer_Group_In_Invoice');">Auto Pay Customer Group In Invoice:<img src="/images/help_small.gif" /> </span></td>
	<td>&nbsp; <div id="tBB_Auto_Pay_Customer_Group_In_Invoice" class="tip">Auto Pay Looks for the Buying Group Id in the Invoice_Header table to deterrmine Customer Group membership.  When this is Off, Auto Pay looks in Contract_Distributors to get group membership.</div></td>
	<td align="left" class2="right"><input value="1" type="checkbox" name="BB_Auto_Pay_Customer_Group_In_Invoice" <cfif appSettings.getBBAutoPayCustomerGroupInInvoice()>checked</cfif>></td>
  </tr>

	  <!--- Dev Note: D18879 --->
  <tr valign="top">
	<td class2="left"><span onmouseout="popUpTip(event,'tBB_Auto_Pay_Disable_Pay_Each');" onmouseover="popUpTip(event,'tBB_Auto_Pay_Disable_Pay_Each');">
		  Auto Pay Disable "Pay Each":<img src="/images/help_small.gif" />
		  </span></td>
	<td>&nbsp;  <div id="tBB_Auto_Pay_Disable_Pay_Each" class="tip">
		This setting Disables the "Pay Each" Option In Program Component Creation.  When the user selects an Auto Pay claim mechanic, they must specify a Payee (a vendor to send the check to).  This is necessary for clients that can not provide a Distributor/Vendor mapping.  The pay each option uses the mapping to find the vendor for each distributor.
		<cfif appsettings.getPayeeFromPlanningGroups()><br><br>Note: When this setting is ON, both - "Pay each entity individually" and "Pay each planning groups" options are not available.</cfif>
	</div></td>
	<td align="left" class2="right"><input value="1" type="checkbox" name="BB_Auto_Pay_Disable_Pay_Each" <cfif appSettings.getBBAutoPayDisablePayEach()>checked</cfif>></td>
  </tr>

	  <!--- Dev Note: D72014 --->
  <tr valign="top">
	<td class2="left"><span onmouseout="popUpTip(event,'tBB_Auto_Pay_Disable_Pay_Each_Entity_Individually');" onmouseover="popUpTip(event,'tBB_Auto_Pay_Disable_Pay_Each_Entity_Individually');">
		  Auto Pay Disable "Pay each entity individually":<img src="/images/help_small.gif" />
		  </span></td>
	<td>&nbsp;  <div id="tBB_Auto_Pay_Disable_Pay_Each_Entity_Individually" class="tip">
		This setting Disables the "Pay each entity individually" Option only In Program Component Creation.  When the user selects an Auto Pay claim mechanic, they must specify a Payee (a vendor to send the check to).  This is necessary for clients that can not provide a Distributor/Vendor mapping.  The pay each option uses the mapping to find the vendor for each distributor.
		<br><br>Note: When this setting is ON, "Pay each entity individually" Option is not available.
	</div></td>
	<td align="left" class2="right"><input value="1" type="checkbox" name="BB_Auto_Pay_Disable_Pay_Each_Entity_Individually" <cfif request.settings.BB_Auto_Pay_Disable_Pay_Each_Entity_Individually eq '1'>checked</cfif>></td>
  </tr>

		<!--- Dev Note: D20848 --->
  <tr valign="top">
	<td class2="left"><span onmouseout="popUpTip(event,'tBB_Auto_Pay_To_Operator_Use_Invoice_Opr_ID');" onmouseover="popUpTip(event,'tBB_Auto_Pay_To_Operator_Use_Invoice_Opr_ID');">
		  Auto Pay Use Operator Id in Invoice Detail When paid To =  Operator:<img src="/images/help_small.gif" />
		  </span></td>
	<td>&nbsp;  <div id="tBB_Auto_Pay_To_Operator_Use_Invoice_Opr_ID" class="tip">
		This setting Tells Auto Pay to use the BSA_Operator_Id in the Invoice Detail Table when determining earnings for Components where the "Paid To" =  Operator (@Component_Paid_To = 2).  When this is off, Auto pay will use the distributors on the program.  Which would result in the Operator getting paid for all of the volume from the distributors on the program.
	</div></td>
	<td align="left" class2="right"><input value="1" type="checkbox" name="BB_Auto_Pay_To_Operator_Use_Invoice_Opr_ID" <cfif appSettings.getBBAutoPayToOperatorUseInvoiceOprID()>checked</cfif>></td>
  </tr>

	<tr valign="top">
	<td class2="left"><span onmouseout="popUpTip(event,'tBB_Auto_Pay_Lump_Sum');" onmouseover="popUpTip(event,'tBB_Auto_Pay_Lump_Sum');">
		  Auto Pay Lump Sum Components<img src="/images/help_small.gif" />
		  </span></td>
	<td>&nbsp;  <div id="tBB_Auto_Pay_Lump_Sum" class="tip">
		This setting Tells Auto Pay whether to include Lump Sum Components when generating Auto Pay Reports.  It also updates the Lump Sum Component to include pay cycle and vendor selection.
	</div></td>
	<td align="left" class2="right"><input value="1" type="checkbox" name="BB_Auto_Pay_Lump_Sum" <cfif appSettings.getBBAutoPayLumpSum()>checked</cfif>></td>
  </tr>


	  <!--- Dev Note: D18879 --->
  <tr valign="top">
	<td class2="left"><span onmouseout="popUpTip(event,'tBB_Auto_Pay_Allow_Negative_Paid_Amount');" onmouseover="popUpTip(event,'tBB_Auto_Pay_Allow_Negative_Paid_Amount');">
		  Auto Pay Allow Negative BB when applying adjustments:<img src="/images/help_small.gif" />
		  </span></td>
	<td>&nbsp;  <div id="tBB_Auto_Pay_Allow_Negative_Paid_Amount" class="tip">
		Determines whether we can apply adjustments to an Auto PAY BB that are greater than the amount of the BB. If selected, then Negative BB paid Amounts are possible.
	</div></td>
	<td align="left" class2="right"><input value="1" type="checkbox" name="BB_Auto_Pay_Allow_Negative_Paid_Amount" <cfif appSettings.getBBAutoPayAllowNegativePaidAmount()>checked</cfif>></td>
  </tr>

  <!--- 42982 Autopay - Reverse --->
  <tr valign="top">
	<td class2="left"><span onmouseout="popUpTip(event,'tBBAutoReportAllowReverse');" onmouseover="popUpTip(event,'tBBAutoReportAllowReverse');">
	Auto Pay - Allow Reverse:<img src="/images/help_small.gif" />
		  </span></td>
	<td>&nbsp; <div id="tBBAutoReportAllowReverse" class="tip">
		  This setting allows users to reverse billbacks inside Auto pay provided they have profile access.
	</div></td>
	<td align="left" class2="right"><input value="1" type="checkbox" name="BBAutoReportAllowReverse" <cfif appSettings.getBBAutoReportAllowReverse()>checked</cfif>></td>
  </tr>

  <tr valign="top">
	<td class2="left"><span onmouseout="popUpTip(event,'tPgmMarginRebateUseAutoPayPrice');" onmouseover="popUpTip(event,'tPgmMarginRebateUseAutoPayPrice');">
	Auto Pay program use auto pay price in margin page:<img src="/images/help_small.gif" />
		  </span></td>
	<td>&nbsp; <div id="tPgmMarginRebateUseAutoPayPrice" class="tip">
		  Program margin will use auto pay price for rebate percentage when program has auto pay component and volume automation has run
	</div></td>
	<td align="left" class2="right"><input value="1" type="checkbox" name="PgmMarginRebateUseAutoPayPrice" <cfif appSettings.getPgmMarginRebateUseAutoPayPrice()>checked</cfif>></td>
  </tr>

  <tr valign="top">
	<td class2="left"><span onmouseout="popUpTip(event,'tAutoPayUseCalendarMonths');" onmouseover="popUpTip(event,'tAutoPayUseCalendarMonths');">
	Auto Pay - Use Calendar Months:<img src="/images/help_small.gif" />
		  </span></td>
	<td>&nbsp; <div id="tAutoPayUseCalendarMonths" class="tip">
		When this setting "Use Calendar Months" is ON, auto pay will use calendar months. <br>
		When this setting "Use Calendar Months" is OFF, auto pay will use fiscal months.
	</div></td>
	<td align="left" class2="right"><input value="1" type="checkbox" name="Auto_Pay_Use_Calendar_Months" <cfif request.settings.Auto_Pay_Use_Calendar_Months eq '1'>checked</cfif>></td>
  </tr>

<!--- 76307 Auto pay updates for BB number and BB Reference number START--->
  <tr valign="top">
  <td class2="left"> Auto Pay - Enable Billback Number</td>
  <td>&nbsp;</td>
  <td align="left" class2="right"><input value="1" type="checkbox" name="BB_Auto_Pay_enable_BB_Number" <cfif request.settings.BB_Auto_Pay_enable_BB_Number eq '1'>checked</cfif>></td>
  </tr>

  <tr valign="top">
  <td class2="left">Auto Pay - Enable Reference Number</td>
  <td>&nbsp;</td>
  <td align="left" class2="right"><input value="1" type="checkbox" name="BB_Auto_Pay_enable_Ref_Number" <cfif request.settings.BB_Auto_Pay_enable_Ref_Number eq '1'>checked</cfif>></td>
  </tr>
<!--- 76307 Auto pay updates for BB number and BB Reference number END--->

  <tr valign="top">
	<td class2="bottoml"><span onmouseout="popUpTip(event,'tUNIPRO_450');" onmouseover="popUpTip(event,'tUNIPRO_450');">
		  UNIPRO 450:<img src="/images/help_small.gif" />
		  </span></td>
	<td class2="bottomm">&nbsp;  <div id="tUNIPRO_450" class="tip">
		Custom Auto Pay report per Unipro specifications.
	</div></td>
	<td align="left" class2="bottomr"><input value="1" type="checkbox" name="UNIPRO_450" <cfif appSettings.getUNIPRO_450() IS 1>checked</cfif>></td>
  </tr>
  <cfset renderDivider()>


	<!--- Dev Note: D12498 --->
	<tr valign="top">
	<td>Allow BB expected rate to exceed claim rate:</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="BB_Expected_Rate_GT_Claim_Rate" <cfif appSettings.getBBExpectedRateGTClaimRate()>checked</cfif>></td>
  </tr>

  <!--- Dev Note: 48449 --->
  <tr valign="top">
	<td>Allow Distributor BB expected rate to exceed claim rate:</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="BB_Expected_Rate_GT_Claim_Rate_Distributor" <cfif request.settings.BB_Expected_Rate_GT_Claim_Rate_Distributor eq '1'>checked</cfif> ></td>
  </tr>

  <tr valign="top">
	<td>Allow BB expected rate to exceed claim rate for fixed price:</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="BB_Expected_Rate_GT_Claim_Rate_Fixed_Price" <cfif request.settings.BB_Expected_Rate_GT_Claim_Rate_Fixed_Price eq '1'>checked</cfif> ></td>
  </tr>

  <tr valign="top">
	<td>Claim less than expected is a deviation:</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Claim_Less_Than_Expected_Deviation" <cfif request.settings.Claim_Less_Than_Expected_Deviation eq '1'>checked</cfif> ></td>
  </tr>

  <tr valign="top">
	<td>Turn on Distributor Product Integrity:
	</td>
	<td>&nbsp; </td>
	<td align="left"><select name="Distributor_Product_Integrity_On">
		<option value="0" <cfif appSettings.getDistributor_Product_Integrity_On() EQ 0>selected</cfif>>OFF</option>
		<option value="1" <cfif appSettings.getDistributor_Product_Integrity_On() EQ 1>selected</cfif>>ON</option>
	  </select>
	</td>
  </tr>

	<!--- Dev Note: D12498 --->
	<tr valign="top">
	<td>Billback: Show claim adjustment: (default=on)</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Show_Claim_Adjustment" <cfif appSettings.getShowClaimAdjustment()>checked</cfif>></td>
  </tr>


	<!--- Dev Note: BJF D13395 5.0 only --->
  <tr valign="top">
	<td>Show Fixed Freight</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Show_Fixed_Freight" <cfif appSettings.getShow_Fixed_Freight()>checked</cfif>></td>
  </tr>
  <!--- Dev Note: BJF 13397 5.0 only --->

  <tr valign="top">
	<td>Accruals  <span onmouseout="popUpTip(event,'Show_Component_Accrual_msg');" onmouseover="popUpTip(event,'Show_Component_Accrual_msg');"><img src="/images/help_small.gif" /></span></td>
	<td>&nbsp;
	<div id="Show_Component_Accrual_msg" class="tip">This used to be called 'show component accrual'. The app setting name has been updated so it more accurately reflects if the client is using accruals in the application.</div>
	</td>
	<td align="left"><input value="1" type="checkbox" name="Show_Component_Accrual" <cfif appSettings.getShow_Component_Accrual()>checked</cfif>></td>
  </tr>

  <tr valign="top">
	<td>Show Component Floor Pricing</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Show_Component_Floor_Pricing" <cfif appSettings.getShow_Component_Floor_Pricing()>checked</cfif>></td>
  </tr>
  <!--- Dev Note: KAL; D13469: Brokerage Application Settings --->
  <tr valign="top">
	<td>Brokerage Functionality:</td>
	<td>&nbsp; </td>
	<td align="left">
	  <select name="Brokerage_Functionality_On">
		<option value="0" <cfif appSettings.getBrokerage_Functionality_On() EQ 0>selected</cfif>>OFF</option>
		<option value="1" <cfif appSettings.getBrokerage_Functionality_On() EQ 1>selected</cfif>>ON</option>
	  </select>
	</td>
  </tr>
  <tr valign="top">
	<td>Auto Created Billback Status:</td>
	<td>&nbsp; </td>
	<td>
	  <select name="Auto_BB_Create_Status_ID">
		<cfloop query="qGetBillbackStatus">
		  <option value="#Billback_Status_ID#" <cfif appSettings.getAuto_BB_Create_Status_ID() eq Billback_Status_ID>selected</cfif>>#BB_Status_Description#</option>
		</cfloop>
	  </select>
	</td>
  </tr>
  <tr valign="top">
	<td>Brokerage Margin Calculation:</td>
	<td>&nbsp; </td>
	<td align="left">
	  <select name="Brokerage_Margin_Calculation">
		<option value="0" <cfif appSettings.getBrokerage_Margin_Calculation() EQ 0>selected</cfif>>OFF</option>
		<option value="1" <cfif appSettings.getBrokerage_Margin_Calculation() EQ 1>selected</cfif>>ON</option>
	  </select>
	</td>
  </tr>

  <tr valign="top">
	<td>Billback Reference Must Be Uppercase:</td>
	<td>&nbsp; </td>
	<td align="left">
	  <select name="BB_Reference_Uppercase">
		<option value="0" <cfif appSettings.getBB_Reference_Uppercase() EQ 0>selected</cfif>>OFF</option>
		<option value="1" <cfif appSettings.getBB_Reference_Uppercase() EQ 1>selected</cfif>>ON</option>
	  </select>
	</td>
  </tr>

  <tr valign="top">
	<td>Display Distributor Off Invoice generic type:</td>
	<td>&nbsp; </td>
	<td align="left">
	  <select name="DisplayDistributorOffInvoice">
		<option value="0" <cfif appSettings.getDisplayDistributorOffInvoice() EQ 0>selected</cfif>>OFF</option>
		<option value="1" <cfif appSettings.getDisplayDistributorOffInvoice() EQ 1>selected</cfif>>ON</option>
	  </select>
	</td>
  </tr>

  <tr valign="top">
	<td>Display Proposal generic type:</td>
	<td>&nbsp; </td>
	<td align="left">
	  <select name="DisplayProposal">
		<option value="0" <cfif appSettings.getDisplayProposal() EQ 0>selected</cfif>>OFF</option>
		<option value="1" <cfif appSettings.getDisplayProposal() EQ 1>selected</cfif>>ON</option>
	  </select>
	</td>
  </tr>
  <!--- Removed with label 19409, set DEFAULT TO OFF
  <tr valign="top">
	<td>Display USDANOI generic type:</td>
	<td>&nbsp; </td>
	<td align="left">
	  <select name="DisplayUSDANOI">
		<option value="0" <cfif appSettings.getDisplayUSDANOI() EQ 0>selected</cfif>>OFF</option>
		<option value="1" <cfif appSettings.getDisplayUSDANOI() EQ 1>selected</cfif>>ON</option>
	  </select>
	</td>
  </tr>
  --->
  <tr valign="top">
	<td>Allow DD splits with negative amounts:</td>
	<td>&nbsp; </td>
	<td align="left">
	  <select name="DD_Negative_Splits">
		<option value="0" <cfif appSettings.getDD_Negative_Splits() EQ 0>selected</cfif>>OFF</option>
		<option value="1" <cfif appSettings.getDD_Negative_Splits() EQ 1>selected</cfif>>ON</option>
	  </select>
	</td>
  </tr>

  <tr valign="top">
	<td>Select Program Lock Type:</td>
	<td>&nbsp; </td>
	<td>
	  <select name="Program_Lock_Type_ID">
		<cfloop query="qGetProgramLockTypes">
		  <option value="#Program_Lock_Type_ID#" <cfif appSettings.getProgramLockTypeID() EQ Program_Lock_Type_ID>selected</cfif>>#trim(Description)#</option>
		</cfloop>
	  </select>
	</td>
  </tr>
  <tr class="t4h">
	<td>Program Summary Label Sets:</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Label_Sets" <cfif appSettings.getLabelSets() EQ 1>checked</cfif>></td>
  </tr>

  <tr class="t4h">
	<td>Hide billback adjustments/exclusions in billback payment page (will still be recorded):</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Hide_Billback_Adjustments" <cfif appSettings.getHide_Billback_Adjustments() EQ 1>checked</cfif>></td>
  </tr>

  <tr class="t4h">
	<td>Switch SSL setting (currently <Cfif appSettings.getSSL_On() EQ 1>on<cfelse>off</CFIF>) MAKE SURE environment has an SSL certificate before clicking on this!:</td>
	<td>&nbsp; </td>
	<td align="left"><input type="button" value="Click here to change" onClick="NewWindow('/settings/update_SSL.cfm','SSl','600','400','Yes', 'Yes'); return false;"></td>
  </tr>

  <tr class="t4h">
	<td>Turn SSL on for all pages MAKE SURE environment has an SSL certificate before clicking on this! The "Switch SSL Setting" should be on if you enable this</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="SSL_On_All_Pages" <cfif appSettings.getSSL_On_All_Pages() EQ 1>checked</cfif>></td>
  </tr>

  <tr class="t4h">
	<td>
	  Audit Trail Storage:
	  Select the number of weeks to store settings audit information.
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <select name="AuditTrailStorage">
		<option value="0">Off</option>
		<cfloop from="60" to="112" index="i" step="4">
		  <cfswitch expression="#i#">
			<cfcase value="60"><cfset mnthNum = "14"></cfcase>
			<cfcase value="112"><cfset mnthNum = "26"></cfcase>
			<cfdefaultcase><cfset mnthNum = ""></cfdefaultcase>
		  </cfswitch>
		  <option value="#i#" <cfif appSettings.getAuditTrailStorage() EQ i>selected</cfif>>
			#i# <cfif mnthNum NEQ "">(#mnthNum# months)</cfif>
		  </option>
		</cfloop>
	  </select>
	</td>
  </tr>
  <tr class="t4h">
	<td>
	  Allow user to edit bid status anytime.
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="AllowBidStatusEditAnytime" <cfif appSettings.AllowBidStatusEditAnytime>checked</cfif>>
	</td>
  </tr>
  <tr class="t4h">
	<td>
	  Product replacement enabled
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="ProductReplacementEnabled" <cfif appSettings.getProductReplacementEnabled()>checked</cfif>>
	</td>
  </tr>

  <tr class="t4h">
	<td>
	  Allow billback-to-credit matching
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="AllowBillbackToCreditMatching" <cfif appSettings.getAllowBillbackToCreditMatching()>checked</cfif>>
	</td>
  </tr>

  <tr class="t4h">
	<td>
	Max future days for Claim Rate or Pricing Extract
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input type="text" name="MaxFutureDaysForClaimRatesORPricingExtract" value="#appSettings.getMaxFutureDaysForClaimRatesORPricingExtract()#" size="3" maxlength="3" onkeypress="javaScript: return Allow_Key_List('0123456789');" onblur="if(isNaN(parseInt(this.value))){this.value=45;this.focus();}">
	</td>
  </tr>

  <tr class="t4h">
	<td>
	  Turn On Vantage<br />
	  (If you turn this On, you have to set up a datasource in Coldfusion Admin, and fill in the datasource in the textbox below.)
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="IsVantageOn" <cfif appSettings.getIsVantageOn()>checked</cfif> onClick="if(this.checked == true && document.all.VantageDataSource.value == ''){alert('Please set up the coldfusion datasource first');this.checked = false;}">
	</td>
  </tr>

  <tr class="t4h">
	<td>
	Set Vantage DataSource<br />
	(The value here should also be a datasource in Coldfusion Admin. Please set that up first.)
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input type="text" name="VantageDataSource" ID = "VantageDataSource" value="#appSettings.getVantageDataSource()#" size="5" onBlur="if(document.all.VantageDataSource.value != '' && confirm('Have you set up a datasource in Coldfusion?')){return true}else{document.all.VantageDataSource.value = ''}">
	</td>
  </tr>

<!--- D30750:Create app setting to use invoice cost from invoice file START--->
  <tr class="t4h">
	<td>
	  Get Cost from Invoice File for Vantage
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="InvoiceCostForVantage" <cfif appSettings.getInvoiceCostForVantage()>checked</cfif>>
	</td>
  </tr>
<!--- D30750:Create app setting to use invoice cost from invoice file END --->

	<!--- Not Yet Implemented <tr valign="top">
	<td>Enable Claim Summary Path</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="enable_csrPath" <cfif appSettings.getEnable_csrPath()>checked</cfif>></td>
  </tr>  --->
  <tr class="t4h">
	<td>
	  View Program / BB Summary UOM
	</td>
	<td>&nbsp; </td>

	<td align="left"><input value="1" type="radio" name="View_Program_Volume_UOM" <cfif appSettings.getViewProgramVolumeUOM() eq 1>checked</cfif>>CS &nbsp;&nbsp;<input value="2" type="radio" name="View_Program_Volume_UOM" <cfif appSettings.getViewProgramVolumeUOM() eq 2>checked</cfif>>LB &nbsp;&nbsp;<input value="3" type="radio" name="View_Program_Volume_UOM" <cfif appSettings.getViewProgramVolumeUOM() eq 3>checked</cfif>>Both</td>
  </td>
  </tr>
  <tr class="t4h">
	<td><span onmouseout="popUpTip(event,'tPlanner_Program_Volume_UOM');" onmouseover="popUpTip(event,'tPlanner_Program_Volume_UOM');">
	#Application.PlannerLabel# #Application.PlannerPrgLabel# Volume UOM:<img src="/images/help_small.gif" />
	</span>
	</td>
	<td>&nbsp; <div id="tPlanner_Program_Volume_UOM" class="tip">
		This is the Volume UOM that will display in the #Application.PlannerLabel# Scorecard - program search results section.
	</div></td>
	<td align="left"><input value="1" type="radio" name="Planner_Program_Volume_UOM" <cfif request.settings.Planner_Program_Volume_UOM neq '2'>checked</cfif>>CS &nbsp;&nbsp;<input value="2" type="radio" name="Planner_Program_Volume_UOM" <cfif request.settings.Planner_Program_Volume_UOM eq '2'>checked</cfif>>LB</td>
  </td>
  </tr>
  <tr class="t4h">
	<td>
	  View Program Displays Estimated $
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="View_Program_Estimated_Amount" <cfif appSettings.getViewProgramEstimatedAmount() EQ 1>checked</cfif>>
	</td>
  </tr>
  <tr class="t4h">
	<td>
	  Billback Inserts Credit into Invoices
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="BB_Inserts_Credit_To_Invoices" <cfif appSettings.getBB_Inserts_Credit_To_Invoices() EQ 1>checked</cfif>>
	</td>
  </tr>

  <tr class="t4h">
	<td>
	  Billback Inserts Credit into Invoices - Generic Types
	</td>
	<td>&nbsp; </td>
	<td align="left">
  <select name="BB_Inserts_Credit_To_Invoices_GT"  id="BB_Inserts_Credit_To_Invoices_GT" class="dropdown" multiple="multiple">
	<cfloop QUERY="qGenericTypes">
	  <OPTION VALUE="#Generic_Type#" <CFIF  appSettings.getBB_Inserts_Credit_To_Invoices_GT() contains qGenericTypes.Generic_Type>SELECTED</CFIF>>#Generic_Type#</OPTION>
	</cfloop>
  </select>
	</td>
  </tr>

  <tr class="t4h">
	<td>
	  Billback Status to Insert Credit (Default = Paid)
	</td>
	<td>&nbsp; </td>
	<td align="left">

	<cfquery name="GetBBStatuses" datasource="#application.datasource#">
	SELECT *
	FROM Billback_Status
	WHERE Status_Order_Number > 2
	ORDER BY Status_Order_Number
	</cfquery>
	  <SELECT Name="BB_Status_To_Insert_Credit">
		<cfloop query="GetBBStatuses">
		  <option value="#Billback_Status_ID#" <cfif Billback_Status_ID EQ appSettings.getBB_Status_To_Insert_Credit()>selected</cfif>>#BB_Status_Description#</option>
		</cfloop>
	  </SELECT>
	</td>
  </tr>
  <!---27047---> <input value="1" type="hidden" name="Show_BB_Summary_Statement" <cfif appSettings.getShow_BB_Summary_Statement() EQ 1>checked</cfif>>
  <tr class="t4h">
	<td>
	  PullBack Start Date (Pullback begins with BB Start Date equal to or later than this date)
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  #DATEFORMAT(appSettings.getPullBack_Start_Date(), 'mm/dd/yyyy')#
	</td>
  </tr>
  <tr class="t4h">
	<td>Allow Billback Products to have 0 volume <br/>(Uploaded BB's require this):</td>
	<td>&nbsp; </td>
	<td align="left">
	  <select name="BB_Product_Allow_Zero_Volume">
		<option value="0" <cfif appSettings.getBBProductAllowZeroVolume() EQ 0>selected</cfif>>OFF</option>
		<option value="1" <cfif appSettings.getBBProductAllowZeroVolume() EQ 1>selected</cfif>>ON</option>
	  </select>
	</td>
  </tr>
<!--- <tr valign="top">
	<td>
	  Display hold/release in BB pymt request tab
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="Display_Hold_Release_Checkbox" <cfif appSettings.getDisplay_Hold_Release_Checkbox() EQ 1>checked</cfif>>
	</td>
  </tr>
--->
  <tr class="t4h">
	<td>Integrated Rebill:<br>
	<em style="color:red;">(Do not enable this feature without advanced planning)</em>
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <select name="Integrated_Rebill">
		<option value="0" <cfif appSettings.getIntegrated_Rebill() EQ 0>selected</cfif>>OFF</option>
		<option value="1" <cfif appSettings.getIntegrated_Rebill() EQ 1>selected</cfif>>ON</option>
	  </select>
	</td>
  </tr>
  <tr class="t4h">
	<td> Single Sign On: </td>
	<td>&nbsp; </td>
	<td align="left">
	  <select name="singlesign_on">
		<option value="0" <cfif appSettings.getSingleSign_on() EQ 0>selected</cfif>>OFF</option>
		<option value="1" <cfif appSettings.getSingleSign_on() EQ 1>selected</cfif>>SSO-[Pactiv]</option>
		<option value="2" <cfif appSettings.getSingleSign_on() EQ 2>selected</cfif>>SSO-[ADFS]</option>
	  </select>
	</td>
  </tr>
<!---START 83599 : FORGE Analytics:  SSO From FORGE Application --->
  <tr>
  	<td>Ember SSO Document URL:</td>
  	<td>&nbsp; </td>
  	<td align="left">
      <input type="text" name="Ember_OpenDocument_URL" value="#request.settings.Ember_OpenDocument_URL#" size="50">
    </td>
  </tr>

  <tr>
    <td>Ember SSO Logon URL:</td>
    <td>&nbsp; </td>
    <td align="left">
      <input type="text" name="Ember_Logon_URL" value="#request.settings.Ember_Logon_URL#" size="50">
    </td>
  </tr>

  <tr>
    <td>Analytics SSO Document URL:</td>
    <td>&nbsp; </td>
    <td align="left">
      <input type="text" name="Analytics_OpenDocument_URL" value="#request.settings.Analytics_OpenDocument_URL#" size="50">
    </td>
  </tr>

  <tr>
    <td>Analytics SSO Logon URL:</td>
    <td>&nbsp; </td>
    <td align="left">
      <input type="text" name="Analytics_Logon_URL" value="#request.settings.Analytics_Logon_URL#" size="50">
    </td>
  </tr>
  <!---END  83599 : FORGE Analytics:  SSO From FORGE Application --->
  <!--- D48816 :: Single Sign On field needed to hold Username START--->
  <tr class="t4h">
	<td> Single Sign On Override User Id :</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="SingleSignOnOverrideUserId" <cfif appSettings.getSingleSignOnOverrideUserId() EQ 1>checked</cfif>>
	</td>
  </tr>
  <!--- D48816 :: Single Sign On field needed to hold Username END--->
  <tr class="t4h">
	<td>
	  Enable LDAP/SSO Authentication
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <select name="LDAP_SSO_Enabled">
		<option value="0" <cfif appSettings.getLDAP_SSO_Enabled() EQ 0>selected</cfif>>OFF</option>
		<option value="1" <cfif appSettings.getLDAP_SSO_Enabled() EQ 1>selected</cfif>>ON</option>
	  </select>
	</td>
  </tr>

  <tr class="t4h">
	<td>
	  Revise Active Programs when Pre Active Exists:
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input value="1" type="checkbox" name="Allow_Revise_Active_With_Pre_Active" <cfif appSettings.getAllowReviseActiveWithPreActive() EQ 1>checked</cfif>>
	</td>
  </tr>
  <tr class="t4h">
	<td>
	  Credit types are same as deduction reason codes
	</td>
	<td>&nbsp; </td>
	<td align="left">
	<input value="1" type="checkbox" name="Credit_Type_Is_DD_Reason_Code" <cfif appSettings.getCreditTypeIsDDReasonCode() EQ 1>checked</cfif>>
	</td>
  </tr>
  <!--- Dev Note: KAL; 7/22/2010; D23692: modifications to manage document settings page plus docs with prog/bb/ded --->
  <tr class="t4h">
	<td>
	  FTP Document Mapping:
	</td>
	<td>&nbsp;</td>
	<td align="left"><input name="FTP_Document_Path" type="text" value="#appSettings.getFTPDocumentPath()#" size="50"></td>
  </tr>
  <!--- D23692/Anand Rao/28-Jun-2010; Modifications to manage document settings page plus docs with prog/bb/ded --->
  <tr class="t4h">
	<td>
	  Document Purge
	</td>
	<td>&nbsp; </td>
	<td align="left" >
	  <input type="text" name="Document_Purge_Age" id="Document_Purge_Age" value="#appSettings.getDocumentPurgeAge()#" size="3" maxlength="4" onkeypress="javaScript: return Allow_Key_List('0123456789');"> Days
	</td>
  </tr>
  <tr class="t4h">
	<td>
	  Billback Module
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <select name="Billback_Module">
		<option value="1" <cfif appSettings.getBillback_Module() EQ 1>selected</cfif>>ON</option>
		<option value="0" <cfif appSettings.getBillback_Module() EQ 0>selected</cfif>>OFF</option>
	  </select>
	</td>
  </tr>
  <tr class="t4h">
	<td>
	  Deduction Module
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <select name="Deduction_Module">
		<option value="1" <cfif appSettings.getDeduction_Module() EQ 1>selected</cfif>>ON</option>
		<option value="0" <cfif appSettings.getDeduction_Module() EQ 0>selected</cfif>>OFF</option>
	  </select>
	</td>
  </tr>
  <tr class="t4h">
	<td>
	  Billback - Allow Fractional Volume
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <select name="BB_Fractional_Volume">
		<option value="1" <cfif appSettings.getBB_Fractional_Volume() EQ 1>selected</cfif>>ON</option>
		<option value="0" <cfif appSettings.getBB_Fractional_Volume() EQ 0>selected</cfif>>OFF</option>
	  </select>
	</td>
  </tr>
  <tr class="t4h">
	<td>
	  Exclude Items from Margin
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <select name="marginItemsExclude">
		<option value="1" <cfif appSettings.getMarginItemsExclude() EQ 1>selected</cfif>>ON</option>
		<option value="0" <cfif appSettings.getMarginItemsExclude() EQ 0>selected</cfif>>OFF</option>
	  </select>
	</td>
  </tr>
  <tr valign="top">
	<td>
	  Simple Clause<br />
	  <em style="color=red">(This setting is NOT editable and should NOT be modified. It should not be changed from ON to OFF, but to change from OFF to ON, please refer to label 25647 first)</em>
	</td>
	<td>&nbsp; </td>
	<td align="left">
	<cfif appSettings.getSimpleClause() EQ 1>ON</cfif>
	<cfif appSettings.getSimpleClause() EQ 0>OFF</cfif>
	</td>
  </tr>
  <tr valign="top">
	<td>
	  Planning Groups
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <select name="planningGroups">
		<option value="1" <cfif appSettings.getPlanningGroups() EQ 1>selected</cfif>>ON</option>
		<option value="0" <cfif appSettings.getPlanningGroups() EQ 0>selected</cfif>>OFF</option>
	  </select>
	</td>
  </tr>
  <tr valign="top" id="BBCreatedRecently_ID">
	<td>Billbacks Created Recently:  include billbacks in current view that have a created date within the last N days</td>
	<td>&nbsp; </td>
	<td align="left" class="right2"><span id="err_sp_BBCreatedRecentlyDays"></span>
	  <input type="text" name="BB_Created_Recently_Days" id="BB_Created_Recently_Days" value="#appSettings.getBBCreatedRecentlyDays()#" size="3" maxlength="4" onkeypress="javaScript: return Allow_Key_List('0123456789');">
	</td>
  </tr>
  <tr>
	<td>User account requires middle initial:</td>
	<td>&nbsp;</td>
	<td align="left"><input value="1" type="checkbox" name="User_Account_Middle_Initial" <cfif appSettings.getUserAccountMiddleInitial() IS 1>checked</cfif>></td>
  </tr>

  <tr>
	<td>Use Fixed Price Type:</td>
	<td>&nbsp;</td>
	<td align="left"><input value="1" type="checkbox" name="Use_Fixed_Price_Type" <cfif appSettings.getUseFixedPriceType() IS 1>checked</cfif>></td>
  </tr>

  <tr>
	<td>Price List by Template:</td>
	<td>&nbsp;</td>
	<td align="left"><input value="1" type="checkbox" name="Price_List_By_Template" <cfif appSettings.getPriceListByTemplate() IS 1>checked</cfif>></td>
  </tr>

	<!--- 117279 - JBS - Price list by Currency START --->
	<tr>
		<td>Price List by Currency:</td>
		<td>&nbsp;</td>
		<td align="left"><input value="1" type="checkbox" name="Price_List_By_Currency" <cfif request.settings.Price_List_By_Currency EQ '1'>checked</cfif>></td>
	</tr>
	<!--- 117279 - JBS - Price list by Currency END --->

 <!--- D29482: mws Path to a server in client ERP to get .pdf files related to deductions --->
  <tr valign="top">
	<td><span onmouseout="popUpTip(event,'tErp_Deduction_Doc_Path');" onmouseover="popUpTip(event,'tErp_Deduction_Doc_Path');">
	Set Erp Deduction Document Path:<img src="/images/help_small.gif" />
		  </span></td>
	<td>&nbsp; <div id="tErp_Deduction_Doc_Path" class="tip">
		This is the URL for the remote (client ERP) server that holds deduction documents.  These are accesssed on the left nav of view deductions.
	</div></td>
	<td align="left">
	  <input type="text" name="Erp_Deduction_Doc_Path" ID = "Erp_Deduction_Doc_Path" value="#appSettings.getErpDeductionDocPath()#" size="50">
	</td>
  </tr>

 <!---30417 Settings for product master edit feature--->
  <tr valign="top">
	<td>Edit Product Master Data:</td>
	<td>&nbsp; </td>
	<td align="left">
	  <select name="Edit_Product_Master_Data">
		<option value="0" <cfif appSettings.getEdit_Product_Master_Data() EQ 0>selected</cfif>>OFF</option>
		<option value="1" <cfif appSettings.getEdit_Product_Master_Data() EQ 1>selected</cfif>>ON</option>
	  </select>
	</td>
  </tr>
  <!--- D33041: Add 'base sales price' to the billback rate pop up window (CF) --->
  <tr valign="top">
	  <td>Billback: display Base Sales in Rate Dev pop up:</td>
	  <td>&nbsp; </td>
	  <td align="left">
		<select name="Billback_Display_Base_Sales_in_Rate_Dev">
		  <option value="0" <cfif appSettings.getBillback_Display_Base_Sales_in_Rate_Dev() EQ 0>selected</cfif>>OFF</option>
		  <option value="1" <cfif appSettings.getBillback_Display_Base_Sales_in_Rate_Dev() EQ 1>selected</cfif>>ON</option>
		</select>
	  </td>
	</tr>
<!--- D29947 Update billback upload for SO/DC START --->
  <tr valign="top">
	  <td>Billback: Business Segment for manual upload:</td>
	  <td>&nbsp; </td>
	  <td align="left">
		 <input value="1" type="checkbox" name="Billback_Upload_Business_Segment" <cfif appSettings.getBillback_Upload_Business_Segment() IS 1>checked</cfif>>
	  </td>
	</tr>
<!--- D29947 Update billback upload for SO/DC END --->

<!--- START: D33957: Modify standard billback upload to one file --->
<tr valign="top">
	<td>Billback File Upload Type:</td>
	<td>&nbsp; </td>
	<td  colspan="3">
	  <select name="Billback_File_Upload_Type">
		<option value="1" <cfif appSettings.getBillbackFileUploadType() eq 1>selected</cfif>>One</option>
	<option value="3" <cfif appSettings.getBillbackFileUploadType() eq 3>selected</cfif>>One File with Alias Fixer</option>
		<option value="2" <cfif appSettings.getBillbackFileUploadType() eq 2>selected</cfif>>Two</option>

	  </select>
	</td>
  </tr>
<!--- END: D33957: Modify standard billback upload to one file --->

  <!--- 34665 --->
  <tr valign="top">
	<td>BB count indicator default</td>
	<td>&nbsp;</td>
	<td align="left">
	  <cfparam name="form.BB_Count_Indicator" default="#appSettings.getBB_Count_Indicator()#">
	  <select name="BB_Count_Indicator">
		<option <cfif form.BB_Count_Indicator eq "Distributor">selected</cfif>>Distributor</option>
		<option <cfif form.BB_Count_Indicator eq "Operator">selected</cfif>>Operator</option>
	  </select>
	</td>
  </tr>

<!--- END: D33957: Modify standard billback upload to one file --->

<!--- START: D48049: Count / Don't Count Volume based on Program Component --->
  <tr valign="top">
    <td>Count / Don't Count:</td>
    <td>&nbsp;</td>
    <td align="left">
      <cfparam name="form.Allow_BB_Dont_Count_From_Program" default="#appSettings.getAllow_BB_Dont_Count_From_Program()#">
      <select name="Allow_BB_Dont_Count_From_Program">
        <option <cfif form.Allow_BB_Dont_Count_From_Program eq "1">selected</cfif> value="1">Component Override Only</option>
        <option <cfif form.Allow_BB_Dont_Count_From_Program eq "0">selected</cfif> value="0">Standard</option>
        <option <cfif form.Allow_BB_Dont_Count_From_Program eq "2">selected</cfif> value="2">Standard & Component Override</option>
      </select>
    </td>
  </tr>
<!--- END: D48049: Count / Don't Count Volume based on Program Component --->

  <!--- 35295 --->
  <tr valign="top">
	<td>Template Filter Setting "Allow In Group Search" Drives Product Groups. Groups may be defined by multiple Product Attributes</td>
	<td>&nbsp;</td>
	<td align="left">
	  <input value="1" type="checkbox" name="Template_Multiple_Product_Attr_Groups" <cfif appSettings.getTemplateMultipleProductAttrGroups() IS 1>checked</cfif>>
	</td>
  </tr>

<!--- D37022 BB Auto Approve Logic - CF work END--->
<!--- START: 36746: Billback Deviation & Summary - Add Operator to the display --->
  <tr valign="top">
	  <td>BB Overlap Deviation Based On Operator:</td>
	  <td>&nbsp; </td>
	  <td align="left">
		<input value="1" type="checkbox" name="BB_Overlap_Deviation_Based_On_Operator" <cfif appSettings.getBBOverlapDeviationBasedOnOperator() EQ 1>checked</cfif>>
	  </td>
  </tr>

  <tr valign="top">
	  <td>BB Default Program Retry Also Call Deviation:</td>
	  <td>&nbsp; </td>
	  <td align="left">
		<input value="1" type="checkbox" name="BB_Default_Program_Retry_Also_Call_Deviation" <cfif appSettings.getBBDefaultProgramRetryAlsoCallDeviation() EQ 1>checked</cfif>>
	  </td>
  </tr>
<!--- END: 36746: Billback Deviation & Summary - Add Operator to the display --->
  <tr valign="top">
	<td>
	  Allowable Overlap Period:
	</td>
	<td>&nbsp; </td>
	<td align="left">
	  <input type="text" name="AllowableOverlapPeriod" value="#appSettings.getAllowableOverlapPeriod()#" size="3" maxlength="3" onkeypress="javaScript: return Allow_Key_List('0123456789');">
	</td>
  </tr>

 <tr valign="top">
	  <td>BB Uploaded via user upload job - Editable claimed dollars and quantity:</td>
	  <td>&nbsp; </td>
	  <td align="left">
		<input value="1" type="checkbox" name="Editable_Claimed_Dollars_Quantity" <cfif appSettings.getEditableClaimedDollarsQuantity() EQ 1>checked</cfif>>
	  </td>
  </tr>

 <tr valign="top">
	  <td>Operator Q Brand Legacy:</td>
	  <td>&nbsp; </td>
	  <td align="left">
		<input value="1" type="checkbox" name="Operator_Q_Brand_Legacy" <cfif appSettings.getOperatorQBrandLegacy() EQ 1>checked</cfif>>
	  </td>
  </tr>

 <tr valign="top">
	  <td>Show Brand on view program:</td>
	  <td>&nbsp; </td>
	  <td align="left">
		<input value="1" type="checkbox" name="Show_Brand_On_View_Program" <cfif appSettings.getShowBrandOnViewProgram() EQ 1>checked</cfif>>
	  </td>
  </tr>
  <tr valign="bottom">
	  <td colspan="3">
  <table cellpadding="0" cellspacing="0" border="0">
	<tr>
	<td  class="topl">! Permanently delete all the billback analysts, default analyst, and the analysts that are associated to all billbacks. </td>
	<td class="topr"></td>
	</tr>
	<tr valign="top">
	<td  class="bottoml" align="right"><input type="button" value="Delete All Billback Analysts" onClick="javascript:permanentlyDeleteAllBBAnalysts(); return false;"></td>
	<td align="right" class="bottomr"></td>
	</tr>
  </table>
	  </td>
  </tr>
  <!--- D41881 :: Auto adjust of DST Weights START--->
  <tr valign="top">
	  <td>
	  Auto Weight Distributors &nbsp;<span onmouseout="popUpTip(event,'tAutoWeightDistributors');" onmouseover="popUpTip(event,'tAutoWeightDistributors');"><img src="/images/help_small.gif" />
	  </span>
	  </td>
	  <td>&nbsp;
	  <div id="tAutoWeightDistributors" class="tip">
		- When this setting is ON, on importing distributors, the auto weight gets applied and the user is taken to the next page.<br />
		- When this setting is OFF, on importing distributors, the auto weight still gets applied but the user stays on the distributor weight page.
	  </div>
	  </td>
	  <td align="left">
		<input value="1" type="checkbox" name="Auto_Weight_Distributors_Program_Revision" <cfif appSettings.getAutoWeightDistributorsProgramRevision() EQ 1>checked</cfif>>
	  </td>
  </tr>
  <!--- D41881 :: Auto adjust of DST Weights END--->
  <tr valign="top">
	  <td>RFA Notification 1 Case Volume</td>
	  <td>&nbsp; </td>
	  <td align="left">
		<input value="1" type="checkbox" name="RFA_Notification_1_Case" <cfif appSettings.getRFA_Notification_1_Case() EQ 1>checked</cfif>>
	  </td>
  </tr>

  <!--- 45235 :: Bid flags not flipping correctly--->
  <tr valign="top">
	  <td>
	  Don't Set Bid Product Status on Revise:<br />
	<em>(Newly added bid products won't get set to the programs bid status for revised programs when this is on)</em>
	</td>
	  <td>&nbsp; </td>
	  <td align="left">
		<input value="1" type="checkbox" name="Dont_Set_Bid_Product_Status_on_Revise" <cfif appSettings.getDontSetBidProductStatusRevise() EQ 1>checked</cfif>>
	  </td>
  </tr>

  <!---D45263 :: Create table to store max rates by template/profile --->
  <tr valign="top">
	  <td>Max rate from Internal table</td>
	  <td>&nbsp; </td>
	  <td align="left">
		<input value="1" type="checkbox" name="Custom_Max_Rate" <cfif appSettings.getCustomMaxRate() EQ 1>checked</cfif>>
	  </td>
  </tr>
 <!---D45263 :: Create table to store max rates by template/profile --->

 <!---44077 :: Note: When we change dates on a program, it needs to be interfaced.
 Not all clients can use this feature because different clients have different interface values to be set
 and there is also some additional logic for some clients which needs to be added.
 Disabling this app setting so that no one turns it ON from the appplication.
 --->
<tr valign="top">
	  <td>
	  Mass Change Pre-active <br />(<span style="color:red;font-weight:bold;">SPECIAL USE ONLY -  <i>Refer to label 44077<i></span>)</td>
	  <td>&nbsp; </td>
	  <td align="left">
		<input value="1" type="checkbox" name="Mass_Change_Preactive" disabled ="1" <cfif appSettings.getMassChangePreactive() EQ 1>checked</cfif>>
		<input type="hidden" name="Mass_Change_Preactive" value="#appSettings.getMassChangePreactive()#" >
	  </td>
</tr>

 <!---D51607 New Duplicate BB Logic - Appsetting Changes --->
  <tr valign="top">
	  <td>Check all BB Duplicates</td>
	  <td>&nbsp; </td>
	  <td align="left">
		<input value="1" type="checkbox" name="Check_All_BB_Duplicate" <cfif appSettings.getCheckAllBBDuplicate() EQ 1>checked</cfif>>
	  </td>
  </tr>
 <!---D51607 New Duplicate BB Logic - Appsetting Changes --->

<tr valign="top">
	<td>% of List Price:</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Percentage_Of_List_Price" <cfif request.settings.Percentage_Of_List_Price eq '1'>checked</cfif>></td>
  </tr>
<tr valign="top">
	<td>Margin page - Use net price for net rebate:</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Margin_Use_Net_Price_For_Net_Rebate" <cfif request.settings.Margin_Use_Net_Price_For_Net_Rebate eq '1'>checked</cfif>></td>
  </tr>

<!---   55718: Check to see if deduction exists for billback and update closing method --->
  <tr valign="top">
	  <td>Update BB to DD closing method if matching DD exists:</td>
	  <td>&nbsp; </td>
	  <td align="left"><input value="1" type="checkbox" name="Update_BB_To_DD_CM_If_DD_Exists" <cfif request.settings.Update_BB_To_DD_CM_If_DD_Exists eq '1'>checked</cfif>></td>
  </tr>

<!---   57075 Deviation settings and trade templates --->
  <tr valign="top">
	  <td>Distributor Trade/Shelter - Allow Deviation Tolerance Override: <span onmouseout="popUpTip(event,'disttrade_Allow_Dev_Tol_Override');" onmouseover="popUpTip(event,'disttrade_Allow_Dev_Tol_Override');"><img src="/images/help_small.gif" /></span></td>
	  <td>&nbsp; <div id="disttrade_Allow_Dev_Tol_Override" class="tip">Do not turn this setting ON.  Logic is out dated.  Talk to Paul or Karen for reasoning.</div></td>
	  <td align="left"><input value="1" type="checkbox" name="Dist_Trade_Deviation_Tolerance_Override" <cfif request.settings.Dist_Trade_Deviation_Tolerance_Override eq '1'>checked</cfif>></td>
  </tr>
	<tr valign="top">
		<td>Modify Vendors from Vendor Management :</td>
		<td>&nbsp; </td>
		<td align="left"><input value="1" type="checkbox" name="Modify_Vendors_VendorManagement" <cfif appSettings.getModifyVendorRecords() >checked</cfif>></td>
	</tr>

	<!--- 49429: APF Enhancement: INCLUDE OI TRANSACTIONS IN BB VALIDATION --->
	<tr valign="top">
		<td>Billback Deviation - Include Invoices with an Operator ID :</td>
		<td>&nbsp; </td>
		<td align="left"><input value="1" type="checkbox" name="BB_Deviation_Include_Invoices_With_Operator_ID"  <cfif request.settings.BB_Deviation_Include_Invoices_With_Operator_ID eq '1'>checked</cfif>></td>
	</tr>
  <!--- 62343 8.0 - Blended Rate, CF START--->
  <tr valign="top">
	<td>Blended Rate :</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Blended_Rate"  <cfif request.settings.Blended_Rate eq '1'>checked</cfif>></td>
  </tr>
  <!--- 62343 8.0 - Blended Rate, CF END--->
 <!--- D64427 Deducton matching issue - bill-to / payer relationship defined in bbk START --->
  <tr valign="top">
	<td>Deduction match using bill to  = vendor :</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Deduction_match_using_bill_to_vendor"  <cfif request.settings.Deduction_match_using_bill_to_vendor eq '1'>checked</cfif>></td>
  </tr>
 <!--- D64427 Deducton matching issue - bill-to / payer relationship defined in bbk END --->

 <!--- D65603:  Hiding Item no. and Shr_ship to changesSTART --->
  <tr valign="top">
	<td>Display Item No. :</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Display_Item_No"  <cfif request.settings.Display_Item_No eq '1'>checked</cfif>></td>
  </tr>

  <tr valign="top">
	<td>Display Distributor ID:</td>
	<td>&nbsp; </td>
	<td align="left">
	   <select name="Display_Distributor_ID">
		<option <cfif request.settings.Display_Distributor_ID eq '1'>selected</cfif> value="1">Shared_Ship_To (Default)</option>
		<option <cfif request.settings.Display_Distributor_ID eq '0' OR request.settings.Display_Distributor_ID eq ''>selected</cfif> value="0">Ship_To</option>
	  </select>
  </tr>
 <!--- D65603:  Hiding Item no. and Shr_ship to changes END --->
  <tr valign="top">
	<td>Claims Input Accelerator Module:</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="OCR_Upload_ON"  <cfif request.settings.OCR_Upload_ON eq '1'>checked</cfif>></td>
  </tr>
  <tr valign="top">
	<td>ABBYY Install Date (For CIA PDF Processing): </td>
	<td>&nbsp; </td>
	<td><input type="text" name="ABBYY_Install_Date" value="#request.settings.ABBYY_Install_Date#" style="width:80px;"></td>
  </tr>

    <!--- D65603:  Hiding Item no. and Shr_ship to changes END --->
  <!--- Assign 9999 rights (Only a person with "9999" access rights, can assign "9999" access rights to another user) --->
  <cfif Request.AccessStructure.User_Rights_ID eq "9999">
  <tr valign="top">
	<td>Assign 9999 access rights</td>
	<td>&nbsp; </td>
	<td><input type="button" value="Click here to assign 9999 access rights" onClick="javascript:window.location.href='/views/settings/list_users.cfm?upateAccessRights=1'; return false;">
	</td>
  </tr>
  </cfif>
 <!--- D64200 :: Create new accrual budget forecast process START --->
  <tr valign="top">
	<td>Annual Budget Forecast :</td>
	<td>&nbsp; </td>
	<td align="left"><input value="1" type="checkbox" name="Annual_Budget_Forecast"  <cfif request.settings.Annual_Budget_Forecast eq '1'>checked</cfif>></td>
  </tr>
 <!--- D64200 :: Create new accrual budget forecast process END --->
 <!--- 70923 :: Create new feature for deduction workflow START --->
  <tr valign="top">
  <td>Custom Deduction workflow :</td>
  <td>&nbsp; </td>
  <td align="left"><input value="1" type="checkbox" name="Custom_Deduction_workflow"  <cfif request.settings.Custom_Deduction_workflow eq '1'>checked</cfif>></td>
  </tr>
 <!--- 70923 :: Create new feature for deduction workflow END --->
 <!--- 72305 :: Do not show Claim rates on program letters START --->
  <tr valign="top">
  <td>Do not show "Claim rates" on program letters :</td>
  <td>&nbsp; </td>
  <td align="left"><input value="1" type="checkbox" name="Dont_Show_Claim_Rates_On_Program_Letters"  <cfif request.settings.Dont_Show_Claim_Rates_On_Program_Letters eq '1'>checked</cfif>></td>
  </tr>
 <!--- 70923 ::Do not show Claim rates on program letters END --->
  <tr valign="top">
  <td>
  	Quick Pay in Program Search :<span onmouseout="popUpTip(event,'tQuickPayProgramSearch');" onmouseover="popUpTip(event,'tQuickPayProgramSearch');"><img src="/images/help_small.gif" />
  </span>
  </td>
  <td>&nbsp;
	<div id="tQuickPayProgramSearch" class="tip" style="width: 350px">
		<B>Orginal</B><br><hr>
		This feature has custom logic built for Smithfield as it relates to accruals, Billback creation with specific items and dollars.
		Prior to turning this setting On for another client, discuss internally at Blacksmith.<br><br>
    Rules for this feature:
    <br>1. Quick Pay link will display for a program that is approved and has at least one component where claim mechanic is Payment or Check
    <br>2. User will enter:  BB Number, Title, Delivery Period Start/End, Amount, Select component, Payee, Closing Method and Vendor (if for payment)
    <br>3. Logic will allocate the Quick Pay dollars based on item's accrued shared % of total program accrual dollars. See WR 75896 for details.
    <br>4. Billback is set to RFA status.
		<br>5. User must go inside Billback to approve it so it will interface

		<hr>
		<B>Advanced</B><br><hr>
		Advanced Quick Pay has additional features that will make it easier to clear deductions.
		<br>	Advanced Quick Pay can be controlled by the remaining dollars for the Accrual, Budget or Program Trade Estimate.
		<br>	The user can either go to the program and select a deduction (s) to clear.  Or go to the deduction and select program(s) to use in clearing the deduction.
		<br>	In both scenarios, a  billback will be generated for each deduction in order to clear it.
		<br>	To control how much deduction monies can be cleared, we will use either the Accrual / Budget / Program Trade Est remaining dollars plus the user profile’s threshold for ‘Advance QP Max Overspend’.
		<hr>
		<br>
  </div>
	<td align="left">
		<!---<input value="1" type="checkbox" name="Quick_Pay_in_Program_Search"  <cfif request.settings.Quick_Pay_in_Program_Search eq '1'>checked</cfif>>--->
		<select name="Quick_Pay_in_Program_Search" onchange="AQPxtrafields(this.value)">
			<option <cfif request.settings.Quick_Pay_in_Program_Search eq '0'>selected</cfif> value="0">None</option>
			<option <cfif request.settings.Quick_Pay_in_Program_Search eq '1'>selected</cfif> value="1">Orginal</option>
			<option <cfif request.settings.Quick_Pay_in_Program_Search eq '2'>selected</cfif> value="2">Advanced</option>
		</select>
	</td>
	</tr>
	<!---97929 :: Quick Pay START--->
  <tr id="AQPControl" valign="top" <cfif request.settings.Quick_Pay_in_Program_Search neq '2'>style="display:none;"</cfif>>
		<td>Advanced Quick Pay is controlled by</td>
		<td>&nbsp;</td>
		<td align="left">
			<select name="Advance_Quick_Pay_Control">
				<option <cfif request.settings.Advance_Quick_Pay_Control eq '1'>selected</cfif> value="1">Accrual</option>
				<option <cfif request.settings.Advance_Quick_Pay_Control eq '2'>selected</cfif> value="2">Budget</option>
				<option <cfif request.settings.Advance_Quick_Pay_Control eq '3'>selected</cfif> value="3">Accrual & Budget</option>
				<option <cfif request.settings.Advance_Quick_Pay_Control eq '4'>selected</cfif> value="4">Program Trade Estimate</option>
			</select>
		</td>
	</tr>
  <tr id="DDForge" valign="top" <cfif request.settings.Quick_Pay_in_Program_Search neq '2'>style="display:none;"</cfif>>
		<td>Are DD's in Forge</td>
		<td>&nbsp;</td>
		<td align="left">
			<select name="DD_In_Forge">
				<option <cfif request.settings.DD_In_Forge eq '0'>selected</cfif> value="0">OFF</option>
				<option <cfif request.settings.DD_In_Forge eq '1'>selected</cfif> value="1">ON</option>
			</select>
		</td>
	</tr>
	<!---97929 :: Quick Pay END--->
	<!---76380 :: Decimals to display START--->
	<tr valign="top">
		<td>Decimals to display for LB</td>
		<td>&nbsp; </td>
		<td><input type="text" name="Decimal_display_for_LB" value="#request.settings.Decimal_display_for_LB#" style="width:25px;"></td>
	</tr>
	<tr valign="top">
		<td>Decimals to display for CS</td>
		<td>&nbsp; </td>
		<td><input type="text" name="Decimal_display_for_CS" value="#request.settings.Decimal_display_for_CS#" style="width:25px;"></td>
	</tr>
	<tr valign="top">
		<td>Decimals to display for #EachInfo.Abbreviation#</td>
		<td>&nbsp; </td>
		<td><input type="text" name="Decimal_display_for_EA" value="#request.settings.Decimal_display_for_EA#" style="width:25px;"></td>
	</tr>
	<tr valign="top">
		<td>Decimals to display for %</td>
		<td>&nbsp; </td>
		<td><input type="text" name="Decimal_display_for_Percentage" value="#request.settings.Decimal_display_for_Percentage#" style="width:25px;"></td>
	</tr>
	<tr valign="top">
		<td>Decimals to display for CWT</td>
		<td>&nbsp; </td>
		<td><input type="text" name="Decimal_display_for_CWT" value="#request.settings.Decimal_display_for_CWT#" style="width:25px;"></td>
	</tr>
	<!---76380 :: Decimals to display END--->
	<!---116682 :: Formula Pricing - Add new setting to round final formula price by UOM START--->
	<tr valign="top">
		<td>Formula pricing - round decimals for CS</td>
		<td>&nbsp; </td>
		<td><input type="text" name="Formula_Pricing_Round_For_CS" value="#request.settings.Formula_Pricing_Round_For_CS#" style="width:25px;"></td>
	</tr>
	<tr valign="top">
		<td>Formula pricing - round decimals for LB</td>
		<td>&nbsp; </td>
		<td><input type="text" name="Formula_Pricing_Round_For_LB" value="#request.settings.Formula_Pricing_Round_For_LB#" style="width:25px;"></td>
	</tr>
	<!---116682 :: Formula Pricing - Add new setting to round final formula price by UOM END--->
	<tr valign="top">
		<td>Product Group Sequencing :</td>
		<td>&nbsp; </td>
		<td align="left"><input value="1" type="checkbox" name="Product_Group_Sequencing"  <cfif request.settings.Product_Group_Sequencing eq '1'>checked</cfif>></td>
	</tr>
	<tr valign="top">
		<td>
  			Lump sum programs that pay to vendor :<span onmouseout="popUpTip(event,'tLumpSumsProgramsPaidToVendor');" onmouseover="popUpTip(event,'tLumpSumsProgramsPaidToVendor');"><img src="/images/help_small.gif" /></span>
		</td>
		<td>&nbsp;
		  <div id="tLumpSumsProgramsPaidToVendor" class="tip" style="width: 375px">
:				Referred to as MAP/MDF.   Enables lump sum programs to require a vendor only.
		  </div>
		</td>
		<td align="left"><input value="1" type="checkbox" name="Lump_Sums_Programs_Paid_To_Vendor"  <cfif request.settings.Lump_Sums_Programs_Paid_To_Vendor eq '1'>checked</cfif>></td>
	</tr>
	<!--- 76536: BB Oper Location Level - dup check --->
	<tr valign="top">
		<td>
  			BB Operator Location Level - Duplicate Checker :<!--- <span onmouseout="popUpTip(event,'tBBOperLocationLeveldupcheck');" onmouseover="popUpTip(event,'tBBOperLocationLeveldupcheck');"><img src="/images/help_small.gif" /></span> --->
		</td>
		<td>&nbsp;
		  <!--- <div id="tBBOperLocationLeveldupcheck" class="tip" style="width: 375px">
 				"BB Operator Location Level - Duplicate Checker" displays separate screen before Deviation, where the user can Approve/Deny a location level Billback row based on location when there are duplicates/multiple locations per row.
		  </div> --->
		</td>
		<td align="left"><input value="1" type="checkbox" name="BB_Oper_Location_Level_Dup_Checker"  <cfif request.settings.BB_Oper_Location_Level_Dup_Checker eq '1'>checked</cfif>></td>
	</tr>
	<!--- START:	103971	Double Dip Report / Anand Rao / 17-Feb-2021    --->
	<tr valign="top">
		<td>
  			Double Dip Report:
		</td>
		<td>&nbsp;
		</td>
		<td align="left"><input value="1" type="checkbox" name="Double_Dip_Report"  <cfif request.settings.Double_Dip_Report eq '1'>checked</cfif> onClick="if(this.checked == true){document.all.trIIIpartyDD.style.display=''}else{document.all.trIIIpartyDD.style.display='none'}"></td>
	</tr>
	<!--- END:	103971	Double Dip Report / Anand Rao / 17-Feb-2021 --->
	<!--- START:  104862: 	Double Dip updates, 3rd party:  use operator from raw file or program / Anand Rao / 23-Mar-2021 --->
	<tr valign="top" ID="trIIIpartyDD" <cfif request.settings.Double_Dip_Report EQ 0 OR request.settings.Double_Dip_Report EQ ''>style="display:none"</cfif>>
		<td>3rd party double dip uses operator from:</td>
		<td>&nbsp; </td>
		<td align="left">
		   	<select name="III_Party_Use_Operator_From">
				<option <cfif request.settings.III_Party_Use_Operator_From EQ 'Program'>selected</cfif> value="Program">Program</option>
				<option <cfif request.settings.III_Party_Use_Operator_From EQ 'Raw_File' OR request.settings.III_Party_Use_Operator_From EQ ''>selected</cfif> value="Raw_File">Raw File</option>
		  	</select>
  	</tr>
	<!--- END: 104862: Double Dip updates, 3rd party:  use operator from raw file or program / Anand Rao / 23-Mar-2021 --->

	<tr valign="top">
		<td>Fixed Price/Rebate: include 2nd component feature :</td>
		<td>&nbsp; </td>
		<td align="left"><input value="1" type="checkbox" name="Include_Second_Component_Feature"  <cfif request.settings.Include_Second_Component_Feature eq '1'>checked</cfif>></td>
	</tr>
	<tr valign="top">
		<td>Establish effective date for planning groups :<span onmouseout="popUpTip(event,'tEffDatesPlanningGroups');" onmouseover="popUpTip(event,'tEffDatesPlanningGroups');"><img src="/images/help_small.gif" /></span></td>
		<td>&nbsp;
				<div id="tEffDatesPlanningGroups" class="tip" style="width: 375px">
					The effective date is not a functional value in  FORGE and does not affect dates applied within programs, claims or reporting.  It is purely an attribute to facilitate communication with other systems.
				</div>
		</td>
		<td align="left">
			<input value="1" type="checkbox" name="PG_Eff_Date_Product"  <cfif request.settings.PG_Eff_Date_Product eq '1'>checked</cfif> id="PG_Eff_Date_Product"> Product
			<input value="1" type="checkbox" name="PG_Eff_Date_Distributor"  <cfif request.settings.PG_Eff_Date_Distributor eq '1'>checked</cfif> id="PG_Eff_Date_Distributor"> Distributor
			<input value="1" type="checkbox" name="PG_Eff_Date_Operator"  <cfif request.settings.PG_Eff_Date_Operator eq '1'>checked</cfif> id="PG_Eff_Date_Operator"> Operator
		</td>
	</tr>

	<tr valign="top">
		<td>Effective Date Upload/Download :<span onmouseout="popUpTip(event,'tEffDatesUploadDownload');" onmouseover="popUpTip(event,'tEffDatesUploadDownload');"><img src="/images/help_small.gif" /></span></td>
		<td>&nbsp;
				<div id="tEffDatesUploadDownload" class="tip" style="width: 375px">
					When this app setting is 'ON' the effective dates will be hidden and cannot be edited inside a Planning group and the user will have the option to download the Members and edit the Effective dates and reupload the same file again.
				</div>
		</td>
		<td align="left">
			<input value="1" type="checkbox" name="PG_Effective_Date_Upload_Download"  <cfif (request.settings.PG_Effective_Date_Upload_Download EQ '1')>checked</cfif> id="PG_Effective_Date_Upload_Download">
		</td>
	</tr>

    <tr id="PGSNumber" <cfif request.settings.PG_Eff_Date_Product eq '0' AND request.settings.PG_Eff_Date_Distributor eq '0' AND request.settings.PG_Eff_Date_Operator eq '0'>style="display:none;"</cfif>>
    <td colspan="2">Planning Groups Number Sequence :</td>
    <td><input type="text" name="PG_Number_Sequence" value="#request.settings.PG_Number_Sequence#" style="width:75px;" onKeyUp="clenseText(this, '0123456789');"></td>
  </tr>
  <tr valign="top">
    <td colspan="2">REDI vendor/distributor REDI special rules:</td>
    <td align="left"><input value="1" type="checkbox" name="Oper_REDI_BB_Only_Include_REDI_Invoice"  <cfif request.settings.Oper_REDI_BB_Only_Include_REDI_Invoice eq '1'>checked</cfif>></td>
  </tr>
  <tr valign="top">
    <td colspan="2">ADL (Authorized Distribution List) enabled:</td>
    <td align="left"><input value="1" type="checkbox" name="Authorized_Distribution_List_Enabled"  <cfif request.settings.Authorized_Distribution_List_Enabled eq '1'>checked</cfif>></td>
  </tr>
  <tr style="margin-bottom:5px">
	  <td>ADL - Customer Dimension:</td>
	  <td>&nbsp;</td>
	  <td>
		<cfparam name="form.Authorized_Distribution_List_Dist_Group_Type" default="#request.settings.Authorized_Distribution_List_Dist_Group_Type#">
		<select name="Authorized_Distribution_List_Dist_Group_Type">
		  <option></option>
		  <cfloop query="qDistributorGroups">
			<option value="#qDistributorGroups.Distributor_Group_Level_ID#" #(form.Authorized_Distribution_List_Dist_Group_Type eq qDistributorGroups.Distributor_Group_Level_ID ? "selected" : "")#>#qDistributorGroups.Group_Level_Desc# - <cfif qDistributorGroups.Is_PG>Planning Group<cfelse>#qDistributorGroups.Group_Level_Desc_Internal#</cfif></option>
		  </cfloop>
		</select>
	  </td>
  </tr>
<!--- 112733 Forge Dashboards - CF settings START--->
	<tr style="margin-bottom:5px">
	  <td>Forge Home Page Dashboards</td>
	  <td>&nbsp;</td>
	  <td>
		<select name="Home_Page_Dashboards">
			<option value="0" <cfif request.settings.Home_Page_Dashboards EQ '0'>selected</cfif>>OFF</option>
			<option value="1" <cfif request.settings.Home_Page_Dashboards EQ '1'>selected</cfif>>ON</option>
			</select>
	  </td>
  </tr>
	<!--- 112733 Forge Dashboards - CF settings END--->
	<!--- Formula Price Item Level Config START--->
	<tr style="margin-bottom:5px">
		<td>Formula Price Item Level</td>
		<td>
			<td align="left"><input value="1" type="checkbox" name="Formula_Price_Item_Level_Config"  <cfif request.settings.Formula_Price_Item_Level_Config eq '1'>checked</cfif>></td>
		</td>
	</tr>
	<!--- Formula Price Item Level Config END--->	
	<!--- Display Commodity Maintenance Search Programs START--->
	<tr style="margin-bottom:5px">
		<td>Display Commodity Maintenance Search Programs</td>
		<td>
			<td align="left"><input value="1" type="checkbox" name="Display_Comm_Setting_Search_Programs"  <cfif request.settings.Display_Comm_Setting_Search_Programs eq '1'>checked</cfif>></td>
		</td>
	</tr>
	<!--- Display Commodity Maintenance Search Programs END--->
	<!--- 116810: Notification - date format START--->
	<tr style="margin-bottom:5px">
		<td>Date format notification</td>
		<td>
			<td align="left"><input value="1" type="checkbox" name="Date_Format_Notification"  <cfif request.settings.Date_Format_Notification eq '1'>checked</cfif>></td>
		</td>
	</tr>
	<!--- 116810: Notification - date format END--->
	<!--- 116462: SOW for Volume Allocation START--->
	<tr style="margin-bottom:5px">
		<td>Program Volume Allocation - wtd average :<span onmouseout="popUpTip(event,'tPrgVolAllocationwtdAverage');" onmouseover="popUpTip(event,'tPrgVolAllocationwtdAverage');"><img src="/images/help_small.gif" /></span></td>
		<td>&nbsp;
				<div id="tPrgVolAllocationwtdAverage" class="tip" style="width: 160px">
					This is custom for Ruiz, WR 116462
				</div>
		</td>
			<td align="left"><input value="1" type="checkbox" name="Program_Volume_Allocation_wtd_average"  <cfif request.settings.Program_Volume_Allocation_wtd_average eq '1'>checked</cfif>></td>
		</td>
	</tr>
	<!--- 116462: SOW for Volume Allocation END--->
	<!--- 116648 Final Settle logic for Indirect Accruals START --->
	<tr style="margin-bottom:5px">
		<td>Indirect Accruals - Final Settle :<!--- <span onmouseout="popUpTip(event,'tPrgVolAllocationwtdAverage');" onmouseover="popUpTip(event,'tPrgVolAllocationwtdAverage');"><img src="/images/help_small.gif" /></span> ---></td>
		<td>&nbsp;
				<!--- <div id="tPrgVolAllocationwtdAverage" class="tip" style="width: 160px">
					This is custom for Ruiz, WR 116462
				</div> --->
		</td>
		<td align="left"><input value="1" type="checkbox" name="Indirect_Accruals_Final_Settle"  <cfif request.settings.Indirect_Accruals_Final_Settle eq '1'>checked</cfif>></td>
	</tr>
	<!--- 116648 Final Settle logic for Indirect Accruals END --->	
	<!--- D132487 - Update customer access to punchlist to point to salesforce - START --->
	<tr style="margin-bottom:5px">
		<td>Use SalesForce to create WR :</td>
		<td>&nbsp;</td>
		<td align="left"><input value="1" type="checkbox" name="SalesForce_Ticket_For_WR"  <cfif request.settings.SalesForce_Ticket_For_WR eq '1'>checked</cfif>></td>
	</tr>
	<tr style="margin-bottom:5px">
		<td>SalesForece Ticketing System URL: </td>
		<td>&nbsp;</td>
		<td align="left"><input name="SalesForce_Ticket_URL" type="text" value="#request.settings.SalesForce_Ticket_URL#" size="50"></td>
	</tr>
	<!--- D132487 - Update customer access to punchlist to point to salesforce - END --->
</table>
</td>
</tr>
</table>
<!---
  D57114: BSA Analysts are not able to open attachments in Smucker's prod/Anand Rao/3-Feb-2016
--->
<input type="hidden" name = "BB_Doc_Server_Folder" value="#request.settings.BB_Doc_Server_Folder#"]

<br><br><br>
<div align="center">
  <a href="" id="saveLink" class="primary">#application.util.string.LinkFormat("save")#</a>
</div>
</cfoutput>
<!--- D29074:Add option to program search to allow user to search on GL Account --->
 <cfoutput>
  <script>
	  function showER(id){
	  if ((id == 2) || (id == 3) || (id == 4) || (id == 5)){
		 document.getElementById("ExpiredRecently_ID").style.display = "block";
		 document.all.Expired_Recently_Days.value = "#appSettings.getExpiredRecentlyDays()#";
	  }
	  else{
		document.all.Expired_Recently_Days.value = 0;
		document.getElementById("ExpiredRecently_ID").style.display = "none";
	  }
	}
  </script>
</cfoutput>

<!------------------------------------------------------------------------------------------------------------>

<cffunction name="renderDivider" hint="Render section header with a title and section footer (without a title)">
	<cfargument name="title" required="false" default="" hint="do not pass anything to render a section footer">

	<tr class="divider">
		<td colspan="3">
			<hr class="six">
			<cfoutput>#arguments.title#</cfoutput>
			<hr class="four">
		</td>
	</tr>
</cffunction>

<!------------------------------------------------------------------------------------------------------------>

<cffunction name="render_flex_setting" hint="Renders non flash/flash settings">
    <cfargument name="setting_name" required="true" type="string" hint="Match to Input_Name column in _Settings table">
    <cfargument name="setting_label" required="true" type="string" hint="UI label on page">
	<cfargument name="include_none" required="false" type="boolean" default="0" hint="'None' option on page">

    <cfoutput>
    <tr>
        <td>#arguments.setting_label#</td>
        <td>&nbsp;</td>
        <td>
            <cfset local.setting_value = request.settings[arguments.setting_name]>
            <!--- CF 2020 option --->
            <label class="flex">
                <input type="radio" name="#arguments.setting_name#" value="CF 2020" <cfif local.setting_value eq "CF 2020">checked</cfif>><span>CF 2020</span>
            </label>
            <!--- Flex default option --->
            <label class="flex">
                <input type="radio" name="#arguments.setting_name#" value="Flex" <cfif local.setting_value neq "CF 2020" AND local.setting_value neq "None">checked</cfif>><span>Flex</span>
            </label>
            <cfif include_none>
            <!--- Nonw option --->
            <label class="flex">
                <input type="radio" name="#arguments.setting_name#" value="None" <cfif local.setting_value eq "None">checked</cfif>><span>None</span>
            </label>
            </cfif>
        </td>
    </tr>
    </cfoutput>
</cffunction>

<!------------------------------------------------------------------------------------------------------------>



<!--- D29074:Add option to program search to allow user to search on GL Account --->

<!--- 27047 ChrisN Added billback statement type --->
<!--- <script type="text/javascript" src="/Script/javascript/Ajax_JS/jquery-1.5.1-min.js"></script> --->
<cfinclude template="/common_files/jQuery.cfm">
<script type="text/javascript" src="/Script/javascript/Ajax_JS/jqueryui-1.8.10.min.js"></script>
<script type="text/javascript" src="/Script/javascript/jQueryUI_18/jquery.multiselect.min.js"></script>
<cf_include files="/script/javascript/jquery.mark.min.js">

<script>
$('#saveLink').click(function(e) {
  e.preventDefault();
  validateAndSubmit(<cfoutput>document.#formName#</cfoutput>);
  return false;
});
$('#claimautoprint').change(function() {
  // claim auto print is checked, add claim summary to billback statement type drop-down
  if ( $('#claimautoprint:checked').val() ) {
	if ( $('#billback_statement_type option[value="claim-summary"]').length == 0 ) {
	  $('#billback_statement_type').append('<option value="claim-summary" id="claim-summary" title="Available when Claim Auto Print is on (not a recommended selection).">Claim Summary</option>');
	}
  }
  else {
	// claim auto print is not checked, remove claim summary from billback statement type drop-down
	$('#billback_statement_type option[value="claim-summary"]').remove();
  }
 });
  $('.dropdown').multiselect({
	 checkAllText:"Select All"
	,uncheckAllText:"Unselect All"
	,selectedText: function(numChecked, numTotal, checkedItems){
		  if (numChecked == numTotal) {
			return 'Selected All';
		  }
		  else {
			return numChecked + ' of ' + numTotal + ' selected';
		  }
	   }
});

/* clicking on setting label toggles the checkbox, makes input/select dropdown in focused */
$("table.t107 tr").click(function(e){
	if (e.target.nodeName.toLowerCase()	=== "td") {
  		var cb = $(this).find("input[type=checkbox]");
  		cb.attr("checked", !cb.attr("checked"));

  		$(this).find("input[type=text]").focus();
  		$(this).find("select").focus();
	}
});

// the input field
  var $input = $("input[name=mark_text]"),
	// the context where to search
	$content = $("table.t107"),
	// jQuery object to save <mark> elements
	$results = $("foo"),
	// the class that will be appended to the current
	// focused element
	currentClass = "current",
	// top offset for the jump (the search bar)
	offsetTop = 50,
	// the current index of the focused element
	currentIndex = -1;

$("a.find_first").click(function(){
  if ($input.val()) {
   $content.unmark().mark($input.val(), {
	  separateWordSearch: false,
	  done: function() {
		$results = $content.find("mark");
		currentIndex = 0;
		jumpTo();
	  }
	});
  }
});

/**
   * Jumps to the element matching the currentIndex
   */
  function jumpTo() {
	if ($results.length) {
	  var position,
		$current = $results.eq(currentIndex);
	  $results.removeClass(currentClass);
	  if ($current.length) {
		$current.addClass(currentClass);
		position = $current.offset().top - offsetTop;
		window.scrollTo(0, position);
	  }
	}
  }

  /**
   * Next and previous search jump to
   */
  $("a.find_next").click(function() {
	if ($results.length) {
	  currentIndex += 1;
	  if (currentIndex > $results.length - 1) {
		currentIndex = 0;
	  }
	  jumpTo();
	}
  });

  $("a.find_prev").click(function() {
	if ($results.length) {
	  currentIndex -= 1;
	  if (currentIndex < 0) {
		currentIndex = $results.length - 1;
	  }
	  jumpTo();
	}
  });
  $("#PG_Eff_Date_Product, #PG_Eff_Date_Distributor, #PG_Eff_Date_Operator").click(function(){
    if($('input[name="PG_Eff_Date_Product"]').is(':checked') || $('input[name="PG_Eff_Date_Distributor"]').is(':checked') ||$('input[name="PG_Eff_Date_Operator"]').is(':checked')){
      $("#PGSNumber").show()
    }
    else{
      $("#PGSNumber").hide()
    }
  });

/*97929 :: Advanced Quick Pay*/
	function AQPxtrafields(opt){
		if(opt ==2){
			$("#AQPControl").show()
			$("#DDForge").show()
		}else{
			$("#AQPControl").hide()
			$("#DDForge").hide()
		}
	}
</script>