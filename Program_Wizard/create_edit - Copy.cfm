<!----
/Program_Wizard/create_edit.cfm

Created By: Brenda Flynn
			bflynn@awayx.com
Created On: May 2, 2003
Modified By: Anand Rao - for D18996
Last Modified On: 15-May-09

-----------------------------
This allows a user to create a new program type from a generic type they selected on the previous page.

IMPORTANT NOTE:
If you added a new setting to this file, please also add the new setting to below file accordingly.
1: settings/Settings_Management/Settings_ProgramTemplate.cfm
2: Settings_List.sql
--->

<cfparam name="fromSettings_management" default=0>
<cfif fromSettings_management neq 1>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">

<cfsilent>
<cfparam name="pullback_template_type" 	default="0">
<!---Find out if they have discount identifiers--->
<cfset useLakebaseForgetGeneralSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("general_settings")>
<cfif useLakebaseForgetGeneralSettings>
	<cftry>
		<cfset getGeneralSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("general_settings", {
				"limit" = "1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetGeneralSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetGeneralSettings>
<cfquery name="getGeneralSettings" datasource="#application.datasource#">
	SELECT TOP 1 *
	FROM General_Settings
</cfquery>
</cfif>

<cfquery name="GetUserSettings" datasource="#application.datasource#">
	SELECT * FROM _Users_Settings
	WHERE User_ID = <cfqueryparam value="#request.AccessStructure.Company_Main_ID#" cfsqltype="cf_sql_idstamp">
</cfquery>


<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<CFIF Get_Profile_Settings.Settings_Panel LT 1>
	<CFLOCATION URL="/Manufacturers/home.cfm" ADDTOKEN="yes">
</CFIF>
<CFIF Get_Profile_Settings.Cont_Prog_View_Create_Program EQ 0>
	<CFLOCATION URL="#application.HomePage#" ADDTOKEN="No">
</CFIF>


<!---Gets application settings--->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset forbidType = appSettings.getForbidAllowProfilesInTemplates() />
<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />

<!---initialize business segment manager--->
<cfset variables.businessSegmentManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />

<!---Scopes url variables--->
<cfif IsDefined("url.Generic_Type")>
	<cfset Generic_Type = url.Generic_Type>
<cfelseif isDefined("form.Generic_Type")>
	<cfset Generic_Type = form.Generic_Type>
</cfif>
<cfif IsDefined("url.Action")>
	<cfset Action = url.Action>
<cfelseif isDefined("form.Action")>
	<cfset Action = form.Action>
</cfif>
<cfif IsDefined("url.ID")>
	<cfset ID = url.ID>
<cfelseif isDefined("form.ID")>
	<cfset ID = form.ID>
<cfelse>
	<cfset ID = 0>
</cfif>


<cfparam name="Active" default="">

<!---Interprets Generic Types--->
<cfif Generic_Type IS "DOI">
	<cfset Generic_Type="Distributor Off-Invoice">
<cfelseif Generic_Type IS "DTS">
	<cfset Generic_Type="Distributor Trade/Shelter">
<cfelseif Generic_Type IS "FE">
	<cfset Generic_Type="Field Execution">
<cfelseif Generic_Type IS "ODHQ">
	<cfset Generic_Type="Operator Direct or HQ Programs">
<cfelseif Generic_Type IS "ODP">
	<cfset Generic_Type="Operator-Deviated Pricing">
<cfelseif Generic_Type IS "DP">
	<cfset Generic_Type="Direct Pricing">
<!--- <cfelseif Generic_Type IS "LSAutoPay">
	<cfset Generic_Type="Lump Sum Auto Pay"> --->
<cfelse>
	<cfset Generic_Type = Generic_Type>
</cfif>


<cfif (Generic_Type EQ "Operator Direct or HQ Programs" OR Generic_Type EQ "Operator-Deviated Pricing")>
	<cfset pullback_template_type = 2>
<cfelseif Generic_Type EQ "Distributor Trade/Shelter">
	<cfset pullback_template_type = 1>
<cfelse>
	<cfset pullback_template_type = 0>
</cfif>


<cfquery name="qCheckOptions" datasource="#application.datasource#">
	SELECT 	TOP 1 *
	FROM 	Program_Control_Panel_Options
</cfquery>

<cfset lumpSumCapMin = 0>
<cfset approvalGroupManager = CreateObject("component", "components.settings.ApprovalGroupManager").init() />
<cfset approvalGroupType = approvalGroupManager.getGroupTypeInfo(productGroupLevelId=appSettings.getTemplateRestrictGroupLevel()) />
<cfparam name="Form.price_protection_on" 		default="0">

<!---Queries if the record is being edited or copied--->
<cfif ListFindNoCase("Edit,Copy", Action)>
	<cfquery name="SelectBasic" datasource="#application.datasource#">
		SELECT	*
		FROM 	Program_Control_Panel_Options
		WHERE 	ProgramControl_Panel_Options_ID = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">
	</cfquery>

	<cfif (SelectBasic.Generic_Type EQ "Operator Direct or HQ Programs" OR SelectBasic.Generic_Type EQ "Operator-Deviated Pricing")>
		<cfset pullback_template_type = 2>
	<cfelseif SelectBasic.Generic_Type EQ "Distributor Trade/Shelter">
		<cfset pullback_template_type = 1>
	<cfelse>
		<cfset pullback_template_type = 0>
	</cfif>

	<cfset Active = SelectBasic.Active>
	<cfset Generic_Type = SelectBasic.Generic_Type>
	<cfset form.dupAction = SelectBasic.Duplicate_Program_Action>
	<CFSET Saved_AR_FY_String = "#TRIM(SelectBasic.AR_From_Fiscal_Year)#_#TRIM(SelectBasic.A_R)#">
	<!--- <cfset lumpSumCapMin = templateManager.getLumpSumTotal(ID)> --->
	<!---if coming from copy then reset the Created Type and Description values to empty strings --->
	<cfif action eq "Copy">
		<cfparam name="Form.Created_Type" 						default="">
		<cfparam name="Form.Program_Description" 				default="">
	<cfelse>
		<cfparam name="Form.Created_Type" 						default="#SelectBasic.Created_Type#">
		<cfparam name="Form.Program_Description" 				default="#SelectBasic.Program_Description#">
	</cfif>
	<cfparam name="Form.Discount_Identifier_ID" 			default="#SelectBasic.Discount_Identifier_ID#">
	<cfparam name="Form.Allocation_Method" 					default="#SelectBasic.Allocation_Method#">
	<cfparam name="Form.GroupLevelBB" 						default="#SelectBasic.GroupLevelBB#">
	<cfparam name="Form.Include_Trade" 						default="#SelectBasic.Include_Trade#">
	<cfparam name="Form.Trade_Blurb" 						default="#SelectBasic.Trade_Blurb#">
	<cfparam name="Form.Broker_Trade_Question" 				default="#SelectBasic.Broker_Trade_Question#">
	<cfparam name="Form.Max_Duration" 						default="#SelectBasic.Max_Duration#">
	<cfparam name="Form.Max_Duration_Length" 				default="#SelectBasic.Max_Duration_Length#">
	<cfparam name="Form.Min_Duration" 						default="#SelectBasic.Min_Duration#">
	<cfparam name="Form.Min_Duration_Length" 				default="#SelectBasic.Min_Duration_Length#">
	<cfparam name="Form.Max_Global_Volume" 					default="#SelectBasic.Max_Global_Volume#">
	<cfparam name="Form.Max_Global_Volume_Size_LBS" 		default="#SelectBasic.Max_Global_Volume_Size_LBS#">
	<cfparam name="Form.Max_Global_Volume_Size_CS" 			default="#SelectBasic.Max_Global_Volume_Size_CS#">
	<cfparam name="Form.Min_Global_Volume" 					default="#SelectBasic.Min_Global_Volume#">
	<cfparam name="Form.Min_Global_Volume_Size_LBS" 		default="#SelectBasic.Min_Global_Volume_Size_LBS#">
	<cfparam name="Form.Min_Global_Volume_Size_CS" 			default="#SelectBasic.Min_Global_Volume_Size_CS#">
	<cfparam name="Form.Min_Lump_Sum" 						default="#SelectBasic.Min_Lump_Sum#">
	<cfparam name="Form.Max_Lump_Sum" 						default="#SelectBasic.Max_Lump_Sum#">
	<cfparam name="Form.Lump_Sum_Cap" 						default="#SelectBasic.Lump_Sum_Cap#">
	<cfparam name="Form.Allow_Retro_Create" 				default="#SelectBasic.Allow_Retro_Create#">
	<cfparam name="Form.Allow_Retro_Create_Max" 			default="#SelectBasic.Allow_Retro_Create_Max#">
	<cfparam name="Form.No_Negative_OI" 					default="#SelectBasic.No_Negative_OI#">
	<cfparam name="Form.Revision_Not_Allowed" 				default="#SelectBasic.Revision_Not_Allowed#">
	<cfparam name="Form.Allow_Retro_Revision" 				default="#SelectBasic.Allow_Retro_Revision#">
	<cfparam name="Form.Allow_Retro_Revision_Span" 			default="#SelectBasic.Allow_Retro_Revision_Span#">
	<cfparam name="Form.Auto_Renew_Option" 					default="#SelectBasic.Auto_Renew_Option#">
	<cfparam name="Form.Allow_AR_Modification" 				default="#SelectBasic.Allow_AR_Modification#">
	<cfparam name="Form.Billback_date" 						default="#SelectBasic.Billback_date#">
	<cfparam name="Form.Billback_Date_Span" 				default="#SelectBasic.Billback_Date_Span#">
	<cfparam name="Form.Payable_To" 						default="#SelectBasic.Payable_To#">
	<cfparam name="Form.Required_Payable_To" 				default="#SelectBasic.Payable_To_Required#">

	<!--- Dev Note: Drachala; D27241: Remove Pay To Distributor Check Box on Basic Info Page START--->
	<cfparam name="Form.Pay_To_Distributor"                 default="#selectBasic.Pay_To_Distributor#">
	<!--- Dev Note: Drachala; D27241: Remove Pay To Distributor Check Box on Basic Info Page END--->

	<cfparam name="Form.Send_Payment_To" 					default="#SelectBasic.Send_Payment_To#">
	<cfparam name="Form.Required_Send_Payment_To" 			default="#SelectBasic.Send_Payment_To_Required#">
	<cfparam name="Form.Customer_Acceptance" 				default="#SelectBasic.Customer_Acceptance#">
	<cfparam name="Form.Currency_Conversion_Factor" 				default="#SelectBasic.Currency_Conversion_Factor#">
	<cfparam name="Form.Adv_Spend" 							default="#SelectBasic.Adv_Spend#">
	<cfparam name="Form.Zero_Volume" 						default="#SelectBasic.Zero_Volume#">
	<cfparam name="Form.Controllable_Volume" 				default="#SelectBasic.Controllable_Volume#">
	<cfparam name="Form.Specify_Distributors" 				default="#SelectBasic.Specify_Distributors#">
	<cfparam name="Form.Require_Distributor" 				default="#SelectBasic.Require_Distributor#">
	<cfparam name="Form.One_Distributor" 					default="#SelectBasic.One_Distributor#">
	<cfparam name="Form.Specify_Distributor_Groups" 		default="#SelectBasic.Specify_Distributor_Groups#">
	<cfparam name="Form.Specify_Operator_Groups" 			default="#SelectBasic.Specify_Operator_Groups#"><!--- D31561: Operator Groups Search --->
	<cfparam name="Form.Specify_Operators" 					default="#SelectBasic.Specify_Operators#">
	<cfparam name="Form.Require_Operator" 					default="#SelectBasic.Require_Operator#">
	<cfparam name="Form.One_Operator" 						default="#SelectBasic.One_Operator#">
	<cfparam name="Form.Alternate_Payment_Recipient" 						default="#SelectBasic.Alternate_Payment_Recipient#"><!--- D37492  --->
	<cfparam name="Form.Specify_Brokers" 					default="#SelectBasic.Specify_Brokers#">
	<cfparam name="Form.Allow_Only_One_Broker" 					default="#SelectBasic.Allow_Only_One_Broker#"><!---D37702 :: Brokerage template type doesn't allow vendor select --->
	<cfparam name="Form.One_Discount_Mandated" 				default="#SelectBasic.One_Discount_Mandated#">
	<cfparam name="Form.Allow_Only_One_Discount" 				default="#SelectBasic.Allow_Only_One_Discount#">
 	<cfparam name="Form.Equipment_Placement" 				default="#SelectBasic.Equipment_Placement#">
	<cfparam name="Form.Volume_Cap" 						default="#SelectBasic.Volume_Cap#">
<!--- 	<cfparam name="Form.Allow_Add_All_Products" 			default="#SelectBasic.Allow_Add_All_Products#"> ---><!--- 10406 --->
	<cfparam name="Form.Include_In_Catalog" 				default="#SelectBasic.Include_In_Catalog#">
	<cfparam name="Form.Show_Awarded_in_Catalog"			default="#SelectBasic.Show_Awarded_in_Catalog#">
	<cfparam name="Form.Catalog_Type" 						default="#SelectBasic.Catalog_Type#">
	<cfparam name="Form.Include_Program" 					default="#SelectBasic.Include_Program#">
	<cfparam name="Form.Dynamic_Static_Groups" 				default="#SelectBasic.Dynamic_Static_Groups#">
	<cfparam name="Form.Restrict_Product_Group_Level" 		default="#SelectBasic.Restrict_Product_Group_Level#">
	<cfif Form.Restrict_Product_Group_Level EQ 1><!------ otherwise it will be set to default below ----->
		<cfparam name="Form.Allow_Product_Group_Level" 		default="#templateManager.getTemplateAllowProductGroupLevelList(ID)#">
		<cfparam name="Form.Allow_Lower_Pricing_Level" 		default="#SelectBasic.Allow_Lower_Pricing_Level#">
	</cfif>
	<cfparam name="Form.Check_Duplicate_Program" 			default="#SelectBasic.Check_Duplicate_Program#">
	<cfparam name="Form.Restrict_On_Approval_Group" 		default="#SelectBasic.Restrict_On_Approval_Group#">
	<cfparam name="Form.Performace_Min_Claims"				default="#SelectBasic.Performace_Min_Claims#">
	<cfparam name="Form.Performace_Min_Days"				default="#SelectBasic.Performace_Min_Days#">
	<cfparam name="Form.Date_Exclusions_ON" 				default="#SelectBasic.Date_Exclusions_ON#">
	<cfparam name="Form.Sysco_Report_ON" 					default="#SelectBasic.Sysco_Report_ON#">
	<cfparam name="Form.exclude_sig_products" 				default="#SelectBasic.exclude_sig_products#">
	<cfif NOT isDefined("Form.Allow_Approval_group")>
		<cfset qGetTemplateAllowApprovalGroups = approvalGroupManager.getTemplateAllowApprovalGroups(ID) />
		<cfset Form.Allow_Approval_group = ValueList(qGetTemplateAllowApprovalGroups.Group_ID)>
	</cfif>
	<cfparam name="Form.Group_Deal" 						default="#SelectBasic.Group_Deal#">
	<cfparam name="Form.Program_Date_Type" 					default="#SelectBasic.Program_Date_Type#">
	<CFPARAM NAME="Form.Days_Before_Auto_Renew"				DEFAULT="#SelectBasic.Days_Before_Auto_Renew#">
	<CFPARAM NAME="Expiring_Notification_Span"				DEFAULT="#SelectBasic.Expiring_Notification_Span#">
	<CFPARAM NAME="Days_For_Reminder"						DEFAULT="#SelectBasic.Days_For_Reminder#">
	<cfparam name="Form.apply_rebate_rates" 				default="#SelectBasic.apply_rebate_rates#">
	<cfparam name="Form.mass_billback_pay" 					default="#SelectBasic.mass_billback_pay#">
	<cfparam name="Form.Competitive_Information_On" 		default="#SelectBasic.Competitive_Information_On#">
	<cfparam name="Form.Program_Start_Day" 					default="#SelectBasic.Program_Start_Day#">
	<cfparam name="Form.Program_End_Day" 					default="#SelectBasic.Program_End_Day#">
	<cfparam name="Form.Program_Min_Start_Date" 			default="#SelectBasic.Program_Min_Start_Date#">
	<cfparam name="Form.Program_Max_End_Date" 				default="#SelectBasic.Program_Max_End_Date#">
	<cfparam name="Form.Pullbacks_on" 						default="#SelectBasic.Pullbacks_on#">
	<cfparam name="Form.Recapture_Pays_To_Id" 				default="#SelectBasic.Recapture_Pays_To_Id#">
	<cfparam name="Form.is_pullback_corporate_deal" 		default="#SelectBasic.is_pullback_corporate_deal#">
	<cfparam name="Form.pullback_from_corporate" 			default="#SelectBasic.pullback_from_corporate#">
	<cfparam name="Form.Pullback_Include_RediVolume" 		default="#SelectBasic.Pullback_Include_RediVolume#">
	<cfparam name="Form.Pullback_redi_volume_percent" 		default="#SelectBasic.Pullback_redi_volume_percent#">
	<cfparam name="Form.Include_Open_Date" 					default="#SelectBasic.Include_Open_Date#">
	<cfparam name="Form.Include_Date_Needed_by" 			default="#SelectBasic.Include_Date_Needed_by#">
	<cfparam name="Form.Include_Reply_Date" 				default="#SelectBasic.Include_Reply_Date#">
	<cfparam name="Form.Include_Competitive_Data_Tracking" 	default="#SelectBasic.Include_Competitive_Data_Tracking#">
	<cfparam name="Form.display_basesales_Competitive_Data" default="#SelectBasic.display_basesales_Competitive_Data#">
	<cfparam name="Form.display_bid_info_page" 				default="#SelectBasic.display_bid_info_page#">
	<cfparam name="Form.line_number" 						default="#SelectBasic.line_number#">
	<cfparam name="Form.BidRequestStatusOn" 				default="#SelectBasic.BidRequestStatusOn#">
	<cfparam name="Form.BidRequestStatusChangePgmStatus" 	default="#SelectBasic.BidRequestStatusChangePgmStatus#">
	<!---<cfparam name="Form.Volume_Related_Message" 			default="#SelectBasic.Volume_Related_Message#">--->
	<cfparam name="Form.Include_Template_In_Deals_IF" 		default="#SelectBasic.Include_Template_In_Deals_IF#">
	<cfparam name="Form.Include_Treatment_Basis_Code" 		default="#SelectBasic.Include_Treatment_Basis_Code#">
	<cfparam name="Form.Exclude_Same_Spending_Cat_From_TPA" default="#SelectBasic.Exclude_Same_Spending_Cat_From_TPA#">
	<cfparam name="Form.ByPass_Margin_Evaluation" 			default="#SelectBasic.ByPass_Margin_Evaluation#">
  <cfparam name="Form.ByPass_Margin_Evaluation_Options" default="#SelectBasic.ByPass_Margin_Evaluation_Options#">
	<cfparam name="Form.EZButton_On" 						default="#SelectBasic.EZButton_On#">
	<cfparam name="Form.BB_D_Template_Overrides_Deviation_Tolerances" 						default="#SelectBasic.BB_D_Template_Overrides_Deviation_Tolerances#">
	<cfparam name="Form.BB_D_Purchase_Period_OverRide"		default="#SelectBasic.BB_D_Purchase_Period_OverRide#">
	<cfparam name="Form.BB_D_Purchase_Period_OverRide_Rate"		default="#SelectBasic.BB_D_Purchase_Period_OverRide_Rate#">
	<cfparam name="Form.BB_D_Aggregation_Period_OverRide"		default="#SelectBasic.BB_D_Aggregation_Period_OverRide#">
	<cfparam name="Form.ReleaseSettlement"					default="#SelectBasic.Release_Settlement#">
	<cfparam name="Form.RS_DaysToClaim"						default="#SelectBasic.RS_DaysToClaim#">
	<cfparam name="Form.Performance_Dates_On"				default="#SelectBasic.Retail_Performance_Dates#">
	<cfset Form.price_protection_on = SelectBasic.price_protection_on >
	<cfparam name="Form.distribution_channel"               default="#SelectBasic.Distribution_Channel#" />
    <cfparam name="Form.division"                           default="#SelectBasic.Division_Num#" />
	<cfparam name="Form.Interface_On_Approval"              default="#SelectBasic.Interface_On_Approval#" />
	<cfparam name="Form.Track_Price_Comp"                   default="#SelectBasic.Track_Price_Comp#" />
	<cfparam name="Form.Retailer_Info_On"                   default="#SelectBasic.Retailer_Info_On#" />
	<cfparam name="Form.Send_RFA_Email"                   	default="#SelectBasic.Send_RFA_Email#" />
	<cfparam name="Form.Distributor_Product_Integrity_Rule_ID" 	default="#SelectBasic.Distributor_Product_Integrity_Rule_ID#">
	<cfparam name="Form.Freight_Approval_Reqd" 	default="#SelectBasic.Freight_Approval_Required#">
	<cfparam name="Form.Freight_accrual_considers_cash_discount" 	default="#SelectBasic.Freight_accrual_considers_cash_discount#">
	<cfparam name="Form.Use_Fixed_Price_As_Base_Sales" 		default="#SelectBasic.Use_Fixed_Price_As_Base_Sales#">
	<cfparam name="Form.Template_UPC_Display" 				default="#SelectBasic.Template_UPC_Display#">
  <cfparam name="FORM.DiscountRebateMaxRateOn" default="#SelectBasic.Discount_Rebate_Max_Rate_On#">
  <cfparam name="FORM.EzButtonUpdateWithLatestTemplateSettingsOnRevise" default="#SelectBasic.EzButton_Update_With_Latest_Template_Settings_On_Revise#">
  	<!---************** BEGIN New Settings for Bid Programs Competitive Data ******************** --->
	<cfparam name="FORM.Won_By" 					default="#SelectBasic.Won_By#" />
	<cfparam name="FORM.Won_Rate" 					default="#SelectBasic.Won_Rate#" />
	<cfparam name="FORM.Won_UOM" 					default="#SelectBasic.Won_UOM#" />
	<cfparam name="FORM.Delivery_Type" 				default="#SelectBasic.Delivery_Type#" />
	<cfparam name="FORM.Category" 					default="#SelectBasic.Category#" />
	<cfparam name="FORM.Package" 					default="#SelectBasic.Package#" />
	<cfparam name="FORM.Shared" 					default="#SelectBasic.Shared#" />
	<cfparam name="FORM.Incremental" 				default="#SelectBasic.Incremental#" />
	<cfparam name="FORM.Source" 					default="#SelectBasic.Source#" />
	<cfparam name="FORM.Source_Type" 				default="#SelectBasic.Source_Type#" />
	<cfparam name="FORM.Date_Source_Received" 		default="#SelectBasic.Date_Source_Received#" />
	<cfparam name="FORM.Download_Comp_Data_History"	default="#SelectBasic.Download_Comp_Data_History#" />
	<cfparam name="FORM.Specd"						default="#SelectBasic.Specd#" />
	<cfparam name="Form.Display_Reminder_Comp_Data_Page" default="#SelectBasic.Display_Reminder_Comp_Data_Page#">
	<cfparam name="FORM.Opportunity_Volume" 		default="#SelectBasic.Opportunity_Volume#" />
	<cfparam name="FORM.Include_Time_Of_Open_Date" 	default="#SelectBasic.Include_Time_Of_Open_Date#" />
	<!---<cfparam name="FORM.Update_Program_Distributors_Approved_Billbacks" 	default="#SelectBasic.Update_Program_Distributors_Approved_Billbacks#" />--->
	<!---************** END New Settings for Bid Programs Competitive Data ******************** --->
	<cfparam name="FORM.Single_Component_Per_Discount_Type" 	default="#SelectBasic.Single_Component_Per_Discount_Type#" />
	<cfparam name="FORM.Item_Fixed_Rebate_Paid_To_Dup_Message" 	default="#SelectBasic.Item_Fixed_Rebate_Paid_To_Dup_Message#" />
	<cfparam name="FORM.AutoAdd_Distributor_ThirdPartyClaims" 	default="#SelectBasic.AutoAdd_Distributor_ThirdPartyClaims#" />
	<cfparam name="FORM.Ignore_Billback_Volume_Deviation" 	default="#SelectBasic.Ignore_Billback_Volume_Deviation#" />
	<cfparam name="FORM.Ignore_Date_Overlap_Deviation" 	default="#SelectBasic.Ignore_Date_Overlap_Deviation#" /><!---D36368 --->
	<cfparam name="FORM.Auto_Volume" 	default="#SelectBasic.Auto_Volume#" />
	<cfparam name="FORM.Blackout_Periods" 				default="#SelectBasic.Blackout_Periods#" /><!---D38942 :: Program Blackout Period on Frontend --->
	<cfparam name="FORM.Start_Zero" 				default="#SelectBasic.Start_Zero#" /><!---D38942 :: Program Blackout Period on Frontend --->
	<cfparam name="FORM.Future_Zero" 				default="#SelectBasic.Future_Zero#" /><!---D38942 :: Program Blackout Period on Frontend --->
	<cfparam name="FORM.Auto_Actual" 	default="#SelectBasic.Auto_Actual#" />
	<cfparam name="FORM.Auto_Future" 	default="#SelectBasic.Auto_Future#" />
	<cfparam name="FORM.Clear_Lumpsum" 	default="#SelectBasic.Clear_Lumpsum#" />
	<cfparam name="FORM.Base_Sales_Equal_To_Lowest_Bracket" 	default="#SelectBasic.Base_Sales_Equal_To_Lowest_Bracket#" />
	<cfparam name="FORM.Margin_Price_List_Header_ID" 		default="#SelectBasic.Margin_Price_List_Header_ID#" />
	<cfparam name="FORM.Base_Sales_based_on_Prg_Start_Date" 	default="#SelectBasic.Base_Sales_based_on_Prg_Start_Date#" />
	<cfparam name="FORM.Select_Effective_Date_for_Price" 		default="#SelectBasic.Select_Effective_Date_for_Price#" />
	<cfparam name="FORM.BB_Tolerance_DVT" 		default="#SelectBasic.BB_Tolerance_DVT#" />
	<cfparam name="FORM.BB_Tolerance_ERT" 		default="#SelectBasic.BB_Tolerance_ERT#" />
	<cfparam name="FORM.Cannot_Exceed_Percent" 		default="#SelectBasic.Cannot_Exceed_Percent#" />
	<cfparam name="FORM.Cannot_Exceed_Dollar" 		default="#SelectBasic.Cannot_Exceed_Dollar#" />
	<cfparam name="FORM.Maximum_Dollar_Amount_Checked" 		default="#SelectBasic.Maximum_Dollar_Amount_Checked#" />
	<cfparam name="FORM.Maximum_Dollar_Amount" 		default="#SelectBasic.Maximum_Dollar_Amount#" />
	<cfparam name="FORM.Billback_Status_For_Max_Dollar_Amt" 		default="#SelectBasic.Billback_Status_For_Max_Dollar_Amt#" />
	<cfparam name="FORM.Auto_Deviation_Inc_Manual_BB" 		default="#SelectBasic.Auto_Deviation_Inc_Manual_BB#" />
	<cfparam name="First_Parent_ID"  		default="#SelectBasic.First_Parent_ID#" />
	<cfparam name="FORM.Default_rate_equal_to_zero"  		default="#SelectBasic.Default_rate_equal_to_zero#" />   <!--- D36963 --->
	<cfparam name="form.Claim_Rates_ConFig_Id"  default="#SelectBasic.Claim_Rates_ConFig_Id#"/>
	<cfparam name="Form.ItemMarked_Lost_Program_Volume_Automation" 	default="#SelectBasic.ItemMarked_Lost_Program_Volume_Automation#">
	<cfparam name="Form.ItemMarked_Lost_Budget_Committed_Dollars" 	default="#SelectBasic.ItemMarked_Lost_Budget_Committed_Dollars#">
	<cfparam name="form.Payment_Notification"  default="#SelectBasic.Payment_Notification#" />
	<cfparam name="form.Payment_Notification_Span"  default="#SelectBasic.Payment_Notification_Span#" />
</cfif>

<cfparam name="Form.Created_Type" 						default="">
<cfparam name="Form.Program_Description" 				default="">
<cfparam name="Form.Allocation_Method" 					default="">
<cfparam name="Form.GroupLevelBB" 						default="0">
<cfparam name="Form.Include_Trade" 						default="1">
<cfparam name="Form.Trade_Blurb" 						default="">
<cfparam name="Form.Broker_Trade_Question" 				default="0">
<cfparam name="Form.Max_Duration" 						default="">
<cfparam name="Form.Max_Duration_Length" 				default="">
<cfparam name="Form.Min_Duration" 						default="">
<cfparam name="Form.Min_Duration_Length" 				default="">
<cfparam name="Form.Max_Global_Volume" 					default="">
<cfparam name="Form.Max_Global_Volume_Size_LBS" 		default="">
<cfparam name="Form.Max_Global_Volume_Size_CS" 			default="">
<cfparam name="Form.Min_Global_Volume" 					default="">
<cfparam name="Form.Min_Global_Volume_Size_LBS" 		default="">
<cfparam name="Form.Min_Global_Volume_Size_CS" 			default="">
<cfparam name="Form.Min_Lump_Sum" 						default="">
<cfparam name="Form.Max_Lump_Sum" 						default="">
<cfparam name="Form.Lump_Sum_Cap" 						default="">
<cfparam name="Form.Allow_Retro_Create" 				default="">
<cfparam name="Form.Allow_Retro_Create_Max" 			default="">
<cfparam name="Form.No_Negative_OI" 					default="">
<cfparam name="Form.Revision_Not_Allowed" 				default="">
<cfparam name="Form.Allow_Retro_Revision" 				default="">
<cfparam name="Form.Allow_Retro_Revision_Span" 			default="">
<cfparam name="Form.Auto_Renew_Option" 					default="">
<cfparam name="Form.Allow_AR_Modification" 				default="">
<cfparam name="Form.Billback_date" 						default="">
<cfparam name="Form.Billback_Date_Span" 				default="">
<cfparam name="Form.Payable_To" 						default="">
<cfparam name="Form.Required_Payable_To" 				default="">
	<!--- Dev Note: Drachala; D27241: Remove Pay To Distributor Check Box on Basic Info Page START--->
	<cfparam name="Form.Pay_To_Distributor"             default="1">
	<!--- Dev Note: Drachala; D27241: Remove Pay To Distributor Check Box on Basic Info Page END--->
<cfparam name="Form.Send_Payment_To" 					default="">
<cfparam name="Form.Required_Send_Payment_To" 			default="">
<cfparam name="Form.Customer_Acceptance" 				default="">
<cfparam name="Form.Currency_Conversion_Factor" 	default="0">
<cfparam name="Form.Adv_Spend" 							default="">
<cfparam name="Form.Zero_Volume" 						default="">
<cfparam name="Form.Controllable_Volume" 				default="">
<cfparam name="Form.Specify_Distributors" 				default="">
<cfparam name="Form.Require_Distributor" 				default="">
<cfparam name="Form.One_Distributor" 					default="">
<cfparam name="Form.Specify_Distributor_Groups" 		default="">
<cfparam name="Form.Specify_Operator_Groups" 			default=""><!--- D31561: Operator Groups Search --->
<cfparam name="Form.Specify_Operators" 					default="">
<cfparam name="Form.Require_Operator" 					default="">
<cfparam name="Form.One_Operator" 						default="">
<cfparam name="Form.Alternate_Payment_Recipient" 						default=""><!--- D37492  --->
<cfparam name="Form.Specify_Brokers" 					default="">
<cfparam name="Form.Allow_Only_One_Broker" 					default=""><!---D37702 :: Brokerage template type doesn't allow vendor select --->
<cfparam name="Form.One_Discount_Mandated" 				default="">
<cfparam name="Form.Allow_Only_One_Discount" default="">
<cfparam name="Form.Equipment_Placement" 				default="">
<cfparam name="Form.Volume_Cap" 						default="">
<!--- <cfparam name="Form.Allow_Add_All_Products" 			default=""> --->
<cfparam name="Form.Include_In_Catalog" 				default="">
<cfparam name="Form.Show_Awarded_in_Catalog"			default="">
<cfparam name="Form.Catalog_Type" 						default="">
<cfparam name="Form.Include_Program" 					default="">
<cfparam name="Form.Dynamic_Static_Groups" 				default="">
<cfparam name="Form.Restrict_Product_Group_Level" 		default="">
<cfparam name="Form.Allow_Product_Group_Level" 			default="">
<cfparam name="Form.Allow_Lower_Pricing_Level" 			default="1">
<cfparam name="Form.Check_Duplicate_Program" 			default="">
<cfparam name="Form.Restrict_On_Approval_Group" 		default="">
<cfparam name="Form.Allow_Approval_group" 				default="">
<cfparam name="Form.Group_Deal" 						default="">
<cfparam name="Form.Date_Exclusions_ON" 				default="0">
<cfparam name="Form.Sysco_Report_ON" 					default="0">
<cfparam name="Form.Program_Date_Type" 					default="1">
<CFPARAM NAME="Days_Before_Auto_Renew"					DEFAULT="0">
<CFPARAM NAME="Expiring_Notification_Span" 				DEFAULT="#GetUserSettings.Contract_Expiration_Range#">
<CFPARAM NAME="Days_For_Reminder"						DEFAULT="#GetUserSettings.Days_For_Reminder_Email#">
<cfparam name="Form.exclude_sig_products" 				default="0">
<cfparam name="displayheader" 							default ="1">
<cfparam name="PriceProtection" 						default ="0">
<cfparam name="Form.apply_rebate_rates" 				default ="0">
<cfparam name="Form.mass_billback_pay" 					default ="0">
<cfparam name="Form.Competitive_Information_On" 		default ="0">
<cfparam name="Form.Program_Start_Day" 					default ="0">
<cfparam name="Form.Program_End_Day" 					default ="0">
<cfparam name="Form.Program_Min_Start_Date" 			default="">
<cfparam name="Form.Program_Max_End_Date" 				default="">
<cfparam name="Form.Include_Open_Date" 					default="0">
<cfparam name="Form.Include_Date_Needed_by" 			default="0">
<cfparam name="Form.Include_Reply_Date" 				default="0">
<cfparam name="Form.Include_Competitive_Data_Tracking" 	default="0">
<cfparam name="Form.display_basesales_Competitive_Data" default="0">
<cfparam name="Form.display_bid_info_page" 				default="0">
<cfparam name="Form.line_number" 						default="0">
<cfparam name="Form.BidRequestStatusOn" 				default="0">
<cfparam name="Form.BidRequestStatusChangePgmStatus" 	default="0">
<cfparam name="Form.Pullbacks_on" 						default="0">
<cfparam name="Form.is_pullback_corporate_deal" 		default="0">
<cfparam name="Form.pullback_from_corporate" 			default="0">
<cfparam name="Form.Pullback_Include_RediVolume" 		default="0">
<cfparam name="Form.Pullback_redi_volume_percent" 		default="">
<!---<cfparam name="Form.Volume_Related_Message" 			default="">--->
<cfparam name="Form.Include_Template_In_Deals_IF" 		default="">
<cfparam name="Form.Include_Treatment_Basis_Code" 		default="">
<cfparam name="Form.Exclude_Same_Spending_Cat_From_TPA"	default="1">
<cfparam name="Form.ByPass_Margin_Evaluation" 			default="0">
<cfparam name="Form.ByPass_Margin_Evaluation_Options" default="1">
<cfparam name="Form.EZButton_On" 						default="0">
<cfparam name="Form.BB_D_Template_Overrides_Deviation_Tolerances" default="0">
<cfparam name="Form.BB_D_Purchase_Period_OverRide"		default="0">
<cfparam name="Form.BB_D_Purchase_Period_OverRide_Rate"		default="0">
<cfparam name="Form.BB_D_Aggregation_Period_OverRide"		default="0">
<cfparam name="Form.ReleaseSettlement"					default="0">
<cfparam name="Form.RS_DaysToClaim"						default="0">
<cfparam name="Form.Performance_Dates_On"				default="0">
<cfparam name="Form.distribution_channel"               default="" />
<cfparam name="Form.division"                           default="" />
<cfparam name="Form.Interface_On_Approval"              default="1" />
<cfparam name="Form.Track_Price_Comp"                   default="1" />
<cfparam name="Form.Retailer_Info_On"                   default="0" />
<cfparam name="Form.Send_RFA_Email"                   	default="1" />
<cfparam name="Form.Distributor_Product_Integrity_Rule_ID"	default="" />
<cfparam name="Form.Freight_Approval_Reqd"	default="0" />
<cfparam name="Form.Freight_accrual_considers_cash_discount"	default="1" />
<cfparam name="Form.Use_Fixed_Price_As_Base_Sales"		default="0" />
<cfparam name="Form.Template_UPC_Display"				default="0" />
<!---************** BEGIN New Settings for Bid Programs Competitive Data ******************** --->
<cfparam name="FORM.Won_By" 					default="0" />
<cfparam name="FORM.Won_Rate" 					default="0" />
<cfparam name="FORM.Won_UOM" 					default="0" />
<cfparam name="FORM.Delivery_Type" 				default="0" />
<cfparam name="FORM.Category" 					default="0" />
<cfparam name="FORM.Package" 					default="0" />
<cfparam name="FORM.Shared" 					default="0" />
<cfparam name="FORM.Incremental" 				default="0" />
<cfparam name="FORM.Source" 					default="0" />
<cfparam name="FORM.Source_Type" 				default="0" />
<cfparam name="FORM.Date_Source_Received" 			default="0" />
<cfparam name="FORM.Download_Comp_Data_History"			default="0" />
<cfparam name="FORM.Specd"					default="0" />
<cfparam name="Form.Display_Reminder_Comp_Data_Page" 		default="0">
<cfparam name="FORM.Opportunity_Volume" 			default="0" />
<cfparam name="FORM.Include_Time_Of_Open_Date" 			default="0" />
<cfparam name="FORM.Update_Program_Distributors_Approved_Billbacks" 	default="0" />
<!---************** END New Settings for Bid Programs Competitive Data ******************** --->
<cfparam name="FORM.Single_Component_Per_Discount_Type" 		default="0" />
<cfparam name="FORM.Item_Fixed_Rebate_Paid_To_Dup_Message" 		default="0" />
<cfparam name="FORM.AutoAdd_Distributor_ThirdPartyClaims" 	default="0" />
<cfparam name="FORM.Ignore_Billback_Volume_Deviation" 	default="0" />
<cfparam name="FORM.Ignore_Date_Overlap_Deviation" 	default="0" /><!---D36368 --->
<cfparam name="FORM.Auto_Volume" 				default="0" />
<cfparam name="FORM.Blackout_Periods" 			default="0" /><!---D38942 :: Program Blackout Period on Frontend --->
<cfparam name="FORM.Auto_Actual" 				default="0" />
<cfparam name="FORM.Auto_Future" 				default="0" />
<cfparam name="FORM.Future_Zero" 				default="0" />
<cfparam name="FORM.Start_Zero" 			default="0" /><!---D38942 :: Program Blackout Period on Frontend --->
<cfparam name="FORM.Clear_Lumpsum" 				default="0" />
<cfparam name="FORM.Base_Sales_Equal_To_Lowest_Bracket" 	default="0" />
<cfparam name="FORM.Margin_Price_List_Header_ID" 		default="" />
<cfparam name="FORM.Base_Sales_based_on_Prg_Start_Date" default="0" />
<cfparam name="FORM.Select_Effective_Date_for_Price" 	default="0" />

<cfparam name="FORM.BB_Tolerance_DVT" 		default=0 />
<cfparam name="FORM.BB_Tolerance_ERT" 		default=0 />
<cfparam name="FORM.Cannot_Exceed_Percent" 		default="" />
<cfparam name="FORM.Cannot_Exceed_Dollar" 		default="" />
<cfparam name="FORM.Maximum_Dollar_Amount_Checked" 		default=0 />
<cfparam name="FORM.Maximum_Dollar_Amount" 		default="" />
<cfparam name="FORM.Billback_Status_For_Max_Dollar_Amt" 		default=0 />
<cfparam name="FORM.Auto_Deviation_Inc_Manual_BB" 		default=0 />
<cfparam name="First_Parent_ID" 		default=0 />
<cfparam name="form.Claim_Rates_ConFig_Id"  default="0"/>
<cfparam name="form.ItemMarked_Lost_Program_Volume_Automation"  default="1"/>
<cfparam name="form.ItemMarked_Lost_Budget_Committed_Dollars"  default="1"/>
<cfparam name="form.Payment_Notification"  default="0" />
<cfparam name="form.Payment_Notification_Span"  default="" />

<!---Queries if the record is being edited--->

<cfparam name="FormStatus" 								default="">

</cfsilent>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<cfset PAGE_TITLE = "Create or Edit a Program Type">

<CFSET PAGETITLE = "PROGRAM TEMPLATES: BASIC INFORMATION">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!---
<html>
<head>
	<title><cfoutput>#PAGE_TITLE#</cfoutput></title>
	 --->
	<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	#header {font-size: 12px;}
<!---
	.showOptions { visibility: visible; }
	.hideOptions { visibility: hidden; }
	--->
	.showOptions { display: ; }
	.hideOptions { display: none; }
	.requiredFieldsIndicator {font-size: 22px;color:red;font-weight:bold;}
	.retroFieldsIndicator {font-size: 22px;color:green;font-weight:bold;vertical-align:middle;}

	</style>

	<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
	<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
	<SCRIPT language="JavaScript" src="/script/javascript/string_functions.js"></SCRIPT>
	<SCRIPT language="JavaScript" src="/script/javascript/format_functions.js"></SCRIPT>
	<SCRIPT language="JavaScript" src="/Common_Files/scripts/allowonlytwodecimalplaces.js"></SCRIPT>

	<script type='text/javascript'>
		_ajaxConfig = {'_cfscriptLocation':'/components/programs/template/TemplateManagerAJAX.cfc', '_jsscriptFolder':'/Script/javascript/Ajax_JS','debug':false};
	</script>
	<script type='text/javascript' src='/Script/javascript/Ajax_JS/ajax.js'></script>

<!------ Operating Group ----->
<cfset operatingGroupManager 			= CreateObject("component", "components.Operating_Group.OperatingGroupManager").init() />
<cfset templateMapLevel 				= operatingGroupManager.getTemplateMapLevel() />
<cfset templateMapLevelLabel 			= operatingGroupManager.getLabel(templateMapLevel) />

<cfset SettingsManagerTemplate = CreateObject("component", "components.settings.settings_management.TemplateSettingsManager").getTemplateSettings(Generic_Type,ID)>

<cfset LabelComp 			= Createobject("component", "components.settings.labels.labels").init() />
<cfset qGetWonByLabel 	= LabelComp.getGeneralLabels('Won By') />
<cfset qGetCategoryLabel 	= LabelComp.getGeneralLabels('Category') />
<cfset qGetPackageLabel 	= LabelComp.getGeneralLabels('Package') />
<cfset qGetSourceLabel		= LabelComp.getGeneralLabels('Source') />
<cfset qGetSourceTypeLabel	= LabelComp.getGeneralLabels('Source Type') />

<script>

var ErrorCount = 0;
function confirmCompletion(disableClickedButton, disableClickedButtonName1,disableClickedButtonName2)
{
	var ErrorCount = 0;

<!--- Program Type Name --->
		if(document.all.Created_Type.value.length == 0)
		{
			ErrorCount++;
			queueMessage("You must enter a Program Type Name", document.all.error_Created_Type);
		}
		else
		{
			clearQueue(document.all.error_Created_Type);
		}
		<CFIF application.returned_customer_setting.Show_Fund_Settings EQ 1 AND application.returned_customer_setting.Upload_GL_Code EQ 1>
		if (isAnyARSelected())
		{
			clearQueue(document.all.error_AR);
		}
		else
		{
			ErrorCount++;
			queueMessage("You must select an A/R with Fiscal Year", document.all.error_AR);
		}
		/*if(document.all.BelongsTo_A_R.value == "")
		{
			ErrorCount++;
			queueMessage("You must select an A/R with Fiscal Year", document.all.error_AR);
		}	*/
		</CFIF>
<!---Program Type Description--->
		if(document.all.Program_Description.value == 0)
		{
			ErrorCount++;
			queueMessage("You must enter a Program Description", document.all.error_Program_Description);
		}
		else
		{
			clearQueue(document.all.error_Program_Description);
		}

<!---Program Type Description--->
		if(document.all.Program_Description.value.length > 254)
		{
			ErrorCount++;
			queueMessage("The program description cannot be longer than 250 characters. It is currently " +  document.all.Program_Description.value.length + " characters", document.all.error_Program_Description);
		}
		else
		{
			clearQueue(document.all.error_Program_Description);
		}

		<!--- 28271 Template settings for Price List selection --->
		<cfif appSettings.getPriceListByTemplate() EQ 1>
		if(document.all.Margin_Price_List_Header_ID.value == 0)
		{
			ErrorCount++;
			queueMessage("You must select a price list", document.all.error_Margin_Price_List_Header_ID);
		}
		else
		{
			clearQueue(document.all.error_Margin_Price_List_Header_ID);
		}
		</CFIF>
<cfif Generic_Type IS NOT "LSAutoPay">
<!--- Duration Maximum --->
		if(document.all.Max_Duration.checked == true && document.all.Max_Duration_Length.value.length == 0)
		{
			ErrorCount++;
			queueMessage("If you choose to have a maximum duration, you must enter a duration amount", document.all.error_Max_Duration);
		}
		else
		{
			clearQueue(document.all.error_Max_Duration);
		}

		if(document.all.Max_Duration.checked == false && document.all.Max_Duration_Length.value.length != 0)
		{
			ErrorCount++;
			queueMessage("If you enter a duration amount, you must check maximum duration", document.all.error_Max_Duration2);
		}
		else
		{
			clearQueue(document.all.error_Max_Duration2);
		}

<!--- Duration Minimum --->
		if(document.all.Min_Duration.checked == true && document.all.Min_Duration_Length.value.length == 0)
		{
			ErrorCount++;
			queueMessage("If you choose to have a minimum duration, you must enter a duration amount", document.all.error_Min_Duration);
		}
		else
		{
			clearQueue(document.all.error_Min_Duration);
		}

		if(document.all.Min_Duration.checked == false && document.all.Min_Duration_Length.value.length != 0)
		{
			ErrorCount++;
			queueMessage("If you enter a duration amount, you must check minimum duration", document.all.error_Min_Duration2);
		}
		else
		{
			clearQueue(document.all.error_Min_Duration2);
		}
</cfif>
<cfif NOT(Generic_Type IS "Distributor Off-Invoice" OR Generic_Type IS "Brokerage" )>
<!------ Lump Sum Cap ----->
		<cfoutput>
		<!--- <cfif lumpSumCapMin NEQ 0> --->
		//var lumpSumCapMin = #lumpSumCapMin#;
		var lumpSumCapMin = parseInt(document.all.Lump_Sum_Cap_Min.value);
		var lumpSumCap = parseInt(document.all.Lump_Sum_Cap.value);
		if(lumpSumCap < lumpSumCapMin)
		{
			ErrorCount++;
			queueMessage("#Application.LumpsumLabel# cap cannot be less than " + formatDollar(lumpSumCapMin, 2, 1, 3), document.all.error_Lump_Sum_Cap);
		}
		else
		{
			clearQueue(document.all.error_Lump_Sum_Cap);
		}
		<!--- </cfif> --->
		</cfoutput>
	<cfif Generic_Type IS NOT "LSAutoPay">
	<!--- Volume Maximum --->
			if(document.all.Max_Global_Volume.checked == true )
			{
				if(document.all.Max_Global_Volume_Size_CS.value.length == 0 || document.all.Max_Global_Volume_Size_LBS.value.length == 0)
				{
					ErrorCount++;
					queueMessage("If you choose to have a maximum volume, you must enter a maximum amount in both cases and pounds", document.all.error_Max_Global_Volume);
				}
				else
				{
					clearQueue(document.all.error_Max_Global_Volume);
				}
			}
			else
			{
				clearQueue(document.all.error_Max_Global_Volume);
			}

			if(document.all.Max_Global_Volume.checked == false && (document.all.Max_Global_Volume_Size_CS.value.length != 0 || document.all.Max_Global_Volume_Size_LBS.value.length != 0))
			{
				ErrorCount++;
				queueMessage("If you enter a volume amount, you must check maximum volume", document.all.error_Max_Global_Volume2);
			}
			else
			{
				clearQueue(document.all.error_Max_Global_Volume2);
			}

<!--- D18996 --->
<cfif generic_type EQ "Bid Request" OR generic_type EQ "Operator-Deviated Pricing" or generic_type EQ "Operator Direct or HQ Programs">
    if(document.all.BB_D_Template_Overrides_Deviation_Tolerances.checked == true )
			{
				if(document.all.BB_D_Purchase_Period_OverRide.value.length == 0 || document.all.BB_D_Purchase_Period_OverRide.value < 0)
				{
          			ErrorCount++;
          			queueMessage("If 'Template Overrides Deviation Tolerances' is checked 'Billback Purchase Period Over Ride for Volume' should be between 0 and 9999", document.all.error_BB_D_Purchase_Period_OverRide);
        		}
        		else
			  	{
          			clearQueue(document.all.error_BB_D_Purchase_Period_OverRide);
			  	}
				if(document.all.BB_D_Purchase_Period_OverRide_Rate.value.length == 0 || document.all.BB_D_Purchase_Period_OverRide_Rate.value < 0)
				{
          			ErrorCount++;
          			queueMessage("If 'Template Overrides Deviation Tolerances' is checked 'Billback Purchase Period Over Ride for Rate' should be between 0 and 9999", document.all.error_BB_D_Purchase_Period_OverRide_Rate);
        		}
        		else
			  	{
          			clearQueue(document.all.error_BB_D_Purchase_Period_OverRide_Rate);
			  	}

        if(document.all.BB_D_Aggregation_Period_OverRide.value.length == 0 || document.all.BB_D_Aggregation_Period_OverRide.value < 0)
				{
          ErrorCount++;
          queueMessage("If 'Template Overrides Deviation Tolerances' is checked 'Billback Aggregation Period Over Ride' should be between 0 and 9999", document.all.error_BB_D_Aggregation_Period_OverRide);
			  }
			  else
			  {
      	  clearQueue(document.all.error_BB_D_Aggregation_Period_OverRide);
			  }
}
</cfif>

	<!--- D18996 end --->
	<!--- Volume Minimum --->
			if(document.all.Min_Global_Volume.checked == true )
			{
				if(document.all.Min_Global_Volume_Size_CS.value.length == 0 || document.all.Min_Global_Volume_Size_LBS.value.length == 0)
				{
					ErrorCount++;
					queueMessage("If you choose to have a minimum volume, you must enter a minimum amount in both cases and pounds", document.all.error_Min_Global_Volume);
				}
				else
				{
					clearQueue(document.all.error_Min_Global_Volume);
				}
			}
			else
			{
				clearQueue(document.all.error_Min_Global_Volume);
			}

			if(document.all.Min_Global_Volume.checked == false && (document.all.Min_Global_Volume_Size_CS.value.length != 0 || document.all.Min_Global_Volume_Size_LBS.value.length != 0))
			{
				ErrorCount++;
				queueMessage("If you enter a volume amount, you must check minimum volume", document.all.error_Min_Global_Volume2);
			}
			else
			{
				clearQueue(document.all.error_Min_Global_Volume2);
			}
	</cfif>		<!--- END Generic_Type IS NOT "LSAutoPay" --->
</cfif>

<cfif Generic_Type IS NOT "Brokerage">
<!--- Last date to claim --->
		if(document.all.Billback_Date.checked == true && document.all.Billback_Date_Span.value.length == 0)
		{
			ErrorCount++;
			queueMessage("If you choose to have a last date to claim, you must specify a number days after the end of the program.", document.all.error_Billback_Expiration);
		}
		else
		{
			clearQueue(document.all.error_Billback_Date_Span);
		}

		if(document.all.Billback_Date.checked == false && document.all.Billback_Date_Span.value != 0)
		{
			ErrorCount++;
			queueMessage("If you enter a number of days, you must check the last date to claim option.", document.all.error_Billback_Date);
		}
		else
		{
			clearQueue(document.all.error_Allow_Retro_Create2);
		}
</cfif>
<!--- Allow Retroactive Creation --->
		if(document.all.Allow_Retro_Create.checked == true && document.all.Allow_Retro_Create_Max.value.length == 0)
		{
			ErrorCount++;
			queueMessage("If you choose to allow retroactively created programs, you must specify how far in the past they can be created", document.all.error_Allow_Retro_Create);
		}
		else
		{
			clearQueue(document.all.error_Allow_Retro_Create);
		}

		if(document.all.Allow_Retro_Create.checked == false && document.all.Allow_Retro_Create_Max.value != 0)
		{
			ErrorCount++;
			queueMessage("If you enter a retroactive duration, you must check retroactive creation", document.all.error_Allow_Retro_Create2);
		}
		else
		{
			clearQueue(document.all.error_Allow_Retro_Create2);
		}

<!--- Allow Retroactive Revision Creation --->
		if(document.all.Allow_Retro_Revision.checked == true && (document.all.Allow_Retro_Revision_Span.value.length == 0 || document.all.Allow_Retro_Revision_Span.value <= 0))
		{
			ErrorCount++;
			queueMessage("If you choose Allow Retroactive Revisions, you must specify a number of retroactive days greater than zero", document.all.error_Allow_Retro_Revision);
		}
		else
		{
			clearQueue(document.all.error_Allow_Retro_Revision);
		}

		if(document.all.Allow_Retro_Revision.checked == false && document.all.Allow_Retro_Revision_Span.value != 0)
		{
			ErrorCount++;
			queueMessage("If you enter a retroactive revision duration, you must check Allow Retroactive Revisions", document.all.error_Allow_Retro_Revision2);
		}
		else
		{
			clearQueue(document.all.error_Allow_Retro_Revision2);
		}


<!---Payable to and Send_payment_To validation!--->
<cfif Generic_Type IS NOT "Brokerage" AND Generic_Type IS NOT "LSAutoPay">
		if(document.all.Required_Payable_To[1].checked && document.all.Payable_To.checked == false)
		{
			document.all.Payable_To.checked = true;
		}
		if(document.all.Required_Send_Payment_To[1].checked && document.all.Send_Payment_To.checked == false)
		{
			document.all.Send_Payment_To.checked = true;
		}
</cfif>
<!------ Operating Group ----->
	<cfif appSettings.getOperatingGroupOn() EQ 1>
		<cfoutput>
		if(!Any_Object_Like_Name_Checked("Operating_Group_"))
		{
			ErrorCount++;
			queueMessage("You have to select at least one #templateMapLevelLabel#", document.all.err_Operating_Group);
		}
		else
		{
			clearQueue(document.all.err_Operating_Group);
		}
		</cfoutput>
	</cfif>
<!------ Search Sequence ----->
	<cfif appSettings.getSearchSequenceOn() EQ 1>
		<cfoutput>
		if(!Any_Object_Like_Name_Checked("Search_Sequence_"))
		{
			ErrorCount++;
			queueMessage("You have to select at least one search sequence", document.all.err_Search_Sequence);
		}
		else
		{
			clearQueue(document.all.err_Search_Sequence);
		}
		</cfoutput>
	</cfif>
	//if Restrict_On_Approval_Group is checked Allow_Approval_group should not be empty
	<cfoutput>
	<cfif len(Form.Allow_Approval_group) EQ 0>
	if(document.all.Restrict_On_Approval_Group.checked)
	{
		ErrorCount++;
		queueMessage("You have to have at least one #approvalGroupType.label# selected", document.all.err_Restrict_On_Approval_Group);
	}
	else
	{
		clearQueue(document.all.err_Restrict_On_Approval_Group);
	}
	</cfif>
	</cfoutput>
	<cfif appSettings.getSearchSequenceOn() EQ 0>
	// if Restrict_Product_Group_Level is checked,  Allow_Product_Group_Level should not be empty
	if(document.all.Restrict_Product_Group_Level)
	{
		if(document.all.Restrict_Product_Group_Level.checked)
		{
			if(Any_Object_Checked(document.all.Allow_Product_Group_Level))
			{
				clearQueue(document.all.err_Restrict_Product_Group_Level);
			}
			else
			{
				ErrorCount++;
				queueMessage("You should allow at least one group level", document.all.err_Restrict_Product_Group_Level);
			}
		}
	}
	</cfif>
	<cfoutput>
	<cfif variables.businessSegmentManager.isEnabled() and appSettings.getFilterBusinessSegments()>
		// if Business Segments are enabled then at least one business segment should be selected
		if(Any_Object_Checked(document.all.Template_Business_Segment_ID))
		{
			clearQueue(document.all.err_Template_Business_Segment);
		}
		else
		{
			ErrorCount++;
			queueMessage("You should allow at least one #appSettings.getbusiness_segment_label()#", document.all.err_Template_Business_Segment);
		}
	</cfif>
	</cfoutput>
	<!--- Program Start/End Day --->
		if(document.all.Program_Start_Day.value != 0 || document.all.Program_End_Day.value != 0)
		{
			if(document.all.Program_Start_Day.value != 1)
			{
			ErrorCount++;
			queueMessage("Please select Sunday as the program start day", document.all.error_Program_Start_Day);
			}
			else
			{
			clearQueue(document.all.error_Program_Start_Day);
			}

			if(document.all.Program_End_Day.value != 7)
			{
			ErrorCount++;
			queueMessage("Please select Saturday as the program end day", document.all.error_Program_End_Day);
			}
			else
			{
			clearQueue(document.all.error_Program_End_Day);
			}
		}
		
	<cfif pullback_template_type EQ 2>
	//alert(document.all.Recapture_Pays_To_Id.value);
		if(document.all.Recapture_Pays_To_Id.value == 0)
		{
			ErrorCount++;
			queueMessage("Please select a <cfoutput>#appSettings.getPullbackLabel()#</cfoutput> creates Pullbacks for Pays to Id.", document.all.err_Recapture_Pays_To_Id);
		}
		else
		{
			clearQueue(document.all.err_Recapture_Pays_To_Id);
		}
	
	</cfif>

	<!---  removed with 25700 Price Protection
	<cfif Generic_Type IS  "Operator Direct or HQ Programs" or Generic_Type IS  "Operator-Deviated Pricing">
		if (document.all.price_protection_on.checked && !document.all.Require_Operator.checked)
		{
		ErrorCount++;
		queueMessage("If price protection is on, operator is required", document.all.err_Operator_Required);
		}
		else
		{
		clearQueue(document.all.err_Operator_Required);
		}
	</cfif>
	--->

	if(document.all.Payment_Notification.checked == true )
	{
		if(document.all.Payment_Notification_Span.value.length == 0)
		{
			ErrorCount++;
			queueMessage("If you select Payment Notification, you must enter number of days.", document.all.error_Payment_Notification);
		}
		else
		{
			clearQueue(document.all.error_Payment_Notification);
		}
	}

	if(document.all.Payment_Notification.checked == false && (document.all.Payment_Notification_Span.value.length != 0))
	{
		ErrorCount++;
		queueMessage("You must select Payment Notification if you enter number of days.", document.all.error_Payment_Notification);
	}
	else
	{
		clearQueue(document.all.error_Payment_Notification);
	}
<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
	if(ErrorCount == 0)
	{
		BasicInfo.action = "create_edit_action.cfm"
		BasicInfo.submit()
		if(disableClickedButton)
		{
			disableButton(disableClickedButtonName1, true, false);
			disableButton(disableClickedButtonName2, true, false);
		}

	}
	else
	{
		showMessageWindow()
	}
}

function checkallowoperators()
{
	if (document.all.Require_Operator.checked || document.all.One_Operator.checked)
	{
	document.all.Specify_Operators.checked = true;
	}
}

function uncheckoperators()
{
if (!document.all.Specify_Operators.checked)
{
document.all.Require_Operator.checked = false;
document.all.One_Operator.checked = false;
}
}
function checkallowdistributors()
{
	if (document.all.Require_Distributor.checked || document.all.One_Distributor.checked)
	{
	document.all.Specify_Distributors.checked = true;
	}
}

function uncheckdistributors()
{
if (!document.all.Specify_Distributors.checked)
{
document.all.Require_Distributor.checked = false;
document.all.One_Distributor.checked = false;
}
}

function changeDisableOtherCheckBoxes(thisObj, OtherObj, actionType)
{
	var bChangeEnable = 1;
	if(actionType == 1)
	{
		OtherObj.checked = thisObj.checked;
	}
	else
	{
		if(OtherObj.bDisable)
		{
			bChangeEnable = 0;
		}

		if(bChangeEnable)
		{
			OtherObj.disabled = !(thisObj.checked);
		}
	}
}
function keepChecked(thisObj, OtherObj)
{
	if(OtherObj.checked && !thisObj.checked)
	{
		thisObj.checked = true;
	}
}
	<!--- Removed with label 19409
	function checkDynStat()
	{

		var groupDealChBx = document.all.Group_Deal;
		var dynGroupDealChBx = document.all.Dynamic_Static_Groups;

		//handle for group deal checkbox
		//if it's checked then enable dynamic static group checkbox
		if (groupDealChBx.checked == true)
		{
			dynGroupDealChBx.disabled = false;
		}

		//if it's not checked then uncheck disable dynamic static group checkbox and disable
		if (groupDealChBx.checked == false)
		{
			dynGroupDealChBx.checked = false;
			dynGroupDealChBx.disabled = true;
		}
	}
	--->
	//function will disable min and max duration form fields based on program_date_type selection
	function programDateType()
	{

		var progDateSel = document.all.Program_Date_Type.options[document.all.Program_Date_Type.selectedIndex].value;

		//if it's fixed then disable duration fields
		if (progDateSel == 2)
		{
			document.all.Max_Duration.disabled = true;
			document.all.Max_Duration_Length.disabled = true;
			document.all.Min_Duration.disabled = true;
			document.all.Min_Duration_Length.disabled = true;
		}
		else
		{
			document.all.Max_Duration.disabled = false;
			document.all.Max_Duration_Length.disabled = false;
			document.all.Min_Duration.disabled = false;
			document.all.Min_Duration_Length.disabled = false;
		}
	}

	function showHideObject(thisObj, displayObj)
	{
		var trObjStyle = displayObj.style;
		if(thisObj.checked)
		{
			trObjStyle.display = "";
		}
		else
		{
			trObjStyle.display = "none";
		}
	}

function checkpullbackfromcorporate(thisvalue)
{
	for (var i=0; i < document.all.is_pullback_corporate_deal.length; i++)
	{
		if (document.all.is_pullback_corporate_deal[i].checked)
		{
			var rad_val = document.all.is_pullback_corporate_deal[i].value;
		}
	}
	if(rad_val == 0)
	{
		document.all.sp_pullback_from_corporate.style.display='';
	}
}

function pullbackOnClick(thisObj)
{
	if(thisObj.checked)
	{
	<cfif pullback_template_type EQ 1> <!------ Distributor ----->
		document.all.is_pullback_corporate.style.display='';
		checkpullbackfromcorporate(thisObj.checked);
		/*document.all.pullback_approval_header.style.display='';
		document.all.pullback_approval_needed.value = 1;
		document.all.pullback_approval.style.display='';*/
	<cfelse> <!------ Operator ----->
		/*document.all.pullback_approval_header.style.display='';
		document.all.pullback_approval.style.display='';
		document.all.pullback_approval_needed.value = 1;*/
	</cfif>
	}
	else
	{
	<cfif pullback_template_type EQ 1> <!------ Distributor ----->
		document.all.is_pullback_corporate.style.display='none';
		document.all.sp_pullback_from_corporate.style.display='none';

		<!------ by default 'Corporate Deal' should be yes ----->
		/*document.all.is_pullback_corporate_deal[0].checked = true;
		document.all.is_pullback_corporate_deal[1].checked = false;
		is_pullback_corporate_deal_on_click(document.all.is_pullback_corporate_deal[0]);*/

	<cfelse> <!------ Operator ----->
		/*document.all.pullback_approval_header.style.display='none';
		document.all.pullback_approval.style.display='none';
		document.all.pullback_approval_needed.value = 0;*/
	</cfif>
	}
}

function is_pullback_corporate_deal_on_click(thisObj)
{
	if(thisObj.checked)
	{
		document.all.sp_pullback_from_corporate.style.display='none';
		<!------ by default 'pullback from Corporate' should be no ----->
		document.all.pullback_from_corporate[0].checked = false;
		document.all.pullback_from_corporate[1].checked = true;
		pullback_from_corporate_off_click(document.all.pullback_from_corporate[1]);
		/*document.all.pullback_approval_header.style.display='';
		document.all.pullback_approval.style.display='';
		document.all.pullback_approval_needed.value = 1;*/

	}
}

function is_pullback_corporate_deal_off_click(thisObj)
{
	if(thisObj.checked)
	{
		document.all.sp_pullback_from_corporate.style.display='';
		/*document.all.pullback_approval_header.style.display='none';
		document.all.pullback_approval.style.display='none';
		document.all.pullback_approval_needed.value = 0;*/
	}
}
	function showHideRestrictOnApproalGroup(thisObj)
	{
		var trObj = document.all.tr_Restrict_on_approal_Group.style;
		if(thisObj.checked)
		{
			trObj.display = "";
		}
		else
		{
			trObj.display = "none";
		}
	}
	function showSearchWindow(sUrl, FieldName)
	{
		<cfoutput>
		NewWindow(sUrl + '?FormName=BasicInfo&groupLevelId=#appSettings.getTemplateRestrictGroupLevel()#&FieldName=' + FieldName , 'select_restrict_group_level_value' , 600 , 500 , 'yes' , 'yes');
		return false;
		</cfoutput>
	}
function pullback_from_corporate_on_click(thisObj)
{
	if(thisObj.checked)
	{
		/*document.all.pullback_approval_header.style.display='';
		document.all.pullback_approval.style.display='';
		document.all.pullback_approval_needed.value = 1;*/
	}
}

function pullback_from_corporate_off_click(thisObj)
{
	if(thisObj.checked)
	{
		/*document.all.pullback_approval_header.style.display='none';
		document.all.pullback_approval.style.display='none';
		document.all.pullback_approval_needed.value = 0;*/
	}
}

function getLumpSumCapAmount()
{
	document.all.lumpSumAmountSpan.style.color = "#FF0000";
	document.all.lumpSumAmountSpan.innerHTML = "&nbsp;Loading...";
	DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'getLumpSumTotalAJAXCall', '<cfoutput>#id#</cfoutput>', doLumpSumCapAmountResult);
}

// call back function
function doLumpSumCapAmountResult (r)
{
	document.all.Lump_Sum_Cap.disabled = false;
	document.all.Lump_Sum_Cap_Min.value = r;
	r = formatDollar(r, 2, 1, 3);
	document.all.lumpSumAmountSpan.innerHTML = '<font color="red">(Min Amount: ' + r + ')</font>';
}
function expandTable(objectID)
{
			var object = document.getElementById("TB_"+objectID);
			tempVar = eval("document.all.TB_"+objectID);
			if (object.style.display =='block') {
				object.style.display='none';
			}
			else {
				object.style.display='block';
			}
			return;
}
</SCRIPT>

<CF_MessageWindow>

<!--- </head>

<body leftmargin="0" topmargin="0" bottommargin="0" rightmargin="0">

<cfinclude template="/includes/header.cfm"> --->

<cfoutput>

<!------ display header ----->
<cfset pageName = "basicinfo">
<cfinclude template="header.cfm">

<cfif LockedBy_Current_User NEQ 1>
	<cfset FormStatus = "disabled">
</cfif>

<form action="create_edit.cfm" method="post" name="BasicInfo" style="display:inline;">
<table width="90%" align="center" cellspacing="0" cellpadding="1"  border="0">
	<tr valign="middle">
		<td nowrap class="requiredFieldsIndicator">*</td>
		<td nowrap>&nbsp;&nbsp; Required fields</td>
		<td width="30%">&nbsp;</td>
		<td nowrap class="retroFieldsIndicator">*</td>
		<td nowrap>&nbsp;&nbsp; Fields which will be saved retroactively for all previous versions</td>
		<td width="100%" align="right"><!--- Dev Note: KAL - D7952 : Lock/Unlock Template: Displaying save option if current user locks the template for editing --->
			<cfif LockedBy_Current_User EQ 1>
				<CF_button
							button_name		=	"save1"
							button_caption	=	"Save and Continue"
							button_action	=	"confirmCompletion(1, 'save1_table','save2_table');"
							button_type		=	"javascript_link"
							button_width	=	"250"
							button_color	=	"Navy"
							button_tip		=	"Save and Continue"
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
							>
			</cfif>
		</td>
	</tr>
</table>
</cfoutput>
</cfif> <!--- end :: cfif fromSettings_management neq 1 :: 1--->

<cfoutput>
<CFIF fromSettings_management neq 1>
<table width="90%" align="center" cellspacing="0" cellpadding="1"  border="1" bordercolor="navy">
<tr>
<!---Left side--->
<td width="50%" valign="top">
	<table width="100%" align="center" cellspacing="1" cellpadding="0" border="0">
	<tr><Th colspan="100%" bgcolor="##93BEE2">Basic Information</TH></tr>
	<!---Program Name--->
	<tr>
		<td align="right" nowrap valign="top"><font class="requiredFieldsIndicator">*</font><strong>Program Type Name</strong></td>
			<td>&nbsp; <span id="error_Created_Type"></span></td>

			<td>&nbsp; </td>
		<td align="left" valign="center"><input type="text" size="30" maxlength="255" name="Created_Type" value="#Form.Created_Type#" #FormStatus# ></td>
	</tr>
	<!---Program Description--->
	<tr>
		<td align="right" nowrap valign="top"><font class="requiredFieldsIndicator">*</font><strong>Program Type<br> Description</strong></td>
			<td>&nbsp; <span id="error_Program_Description"></span></td>
			<td>&nbsp; </td>
		<td align="left" valign="center">
		<textarea name="Program_Description" rows="4" cols="32" #FormStatus# >#Form.Program_Description#</textarea>
		</td>
	</tr>
</CFIF>
	<CFIF fromSettings_management eq 1>
			<tr><Th colspan="100%" bgcolor="##93BEE2">Basic Information</TH></tr>
   	</CFIF>
	<!---Distributor--->
	<cfif NOT (Generic_Type IS "Brokerage" OR Generic_Type IS "LSAutoPay")>
		<cfset distributorIdRequired = 0>
		<cfset distributorIdRequired = Generic_Type IS "Distributor Off-Invoice" OR Generic_Type IS "Distributor Trade/Shelter">
		<CFIF fromSettings_management eq 1>
			<cfif distributorIdRequired>
				<tr>
					<td align="right" nowrap valign="top"><strong>Allow #application.returned_customer_setting.distributor_label_plural#</strong></td>
					<td align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
						<input type="radio" name="Specify_Distributors" value="1" checked disabled> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<input type="radio" name="Specify_Distributors" value="0" disabled> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					</td>
					<td>&nbsp;</td>
   				</tr>
			<cfelse>
				<cfset SettingsTemplateForm(NameField="Specify_Distributors",NameFieldDesc="Allow #application.returned_customer_setting.distributor_label_plural#")>
			</cfif>
  		<CFELSE>
		<tr <cfif SettingsManagerTemplate.Specify_Distributors EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><strong>Allow #application.returned_customer_setting.distributor_label_plural#</strong></td>
				<td>&nbsp; </td>
				<td>&nbsp; </td>
			<td align="left" valign="top">
			<!---Must Specify Distributor(s)--->
			<cfif distributorIdRequired>
			<input type="hidden" name="Specify_Distributors" value="1">
			<input type="checkbox" checked disabled>
			<cfelse>
			<input type="checkbox" name="Specify_Distributors" <cfif Form.Specify_Distributors IS 1>checked</cfif> value="1" onclick="uncheckdistributors();" #FormStatus# >
			</cfif>
			&nbsp; &nbsp; <input type="checkbox" name="Require_Distributor" onclick="checkallowdistributors();" value="1"<cfif Form.Require_Distributor IS 1>checked</cfif> #FormStatus# >Required
			<!---Restrict to one distributor--->
			&nbsp; &nbsp; <input type="checkbox" name="One_Distributor" onclick="checkallowdistributors();" value="1" <cfif Form.One_Distributor IS 1>checked</cfif> #FormStatus# >Allow only one

			</td>
		</tr>
		</CFIF>
	<cfelseif Generic_Type IS "LSAutoPay">
		<input type="hidden" name="Specify_Distributors" value="1">
		<input type="hidden" name="One_Distributor" value="1" >
	</cfif>

	<cfif NOT(Generic_Type IS "Distributor Trade/Shelter" OR Generic_Type IS "Brokerage" OR Generic_Type IS "LSAutoPay")>
		<!---Must Specify Operator(s)--->
		<CFIF fromSettings_management eq 1>
			<cfset SettingsTemplateForm(NameField="Specify_Operators",NameFieldDesc="Allow #application.returned_customer_setting.operator_label_plural#")>
  		<CFELSE>
		<tr <cfif SettingsManagerTemplate.Specify_Operators EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><strong>Allow #application.returned_customer_setting.operator_label_plural#</strong></td>
				<td><span id="err_Operator_Required"></span></td>
				<td>&nbsp; </td>
			<td align="left" valign="top">
			<!---TSF: Modification Bid Request--->
			<!---if it's a bid request then don't give them the option of not selecting an operator--->
			<cfif trim(Generic_Type) eq "Bid Request">
				<cfset Form.Specify_Operators = 1 />
			</cfif>
			<input type="checkbox" name="Specify_Operators" <cfif Form.Specify_Operators IS 1>checked</cfif> value="1" onclick="uncheckoperators();" #FormStatus# >
			&nbsp; &nbsp; <input type="checkbox" name="Require_Operator" onclick="checkallowoperators();" value="1"<cfif Form.Require_Operator IS 1>checked</cfif> #FormStatus# >Required
			<!---Restrict to one distributor--->
			&nbsp; &nbsp; <input type="checkbox" name="One_Operator" onclick="checkallowoperators();" value="1" <cfif Form.One_Operator IS 1>checked</cfif> #FormStatus# >Allow only one
			</td>
		</tr>
		</CFIF>
	<!---Not a trade program--->
	<cfelseif Generic_Type IS "LSAutoPay">
		<input type="hidden" name="One_Operator" value="1" >
		<input type="Hidden" name="Specify_Operators" value="1" >
	</cfif>
<!---  D37492   --->
		<CFIF fromSettings_management eq 1>
			<cfset SettingsTemplateForm(NameField="Alternate_Payment_Recipient",NameFieldDesc="Alternate Payment Recipient")>
  		<CFELSE>
		<tr>
			<td align="right" nowrap valign="top"><strong>Alternate Payment Recipient</strong></td>
				<td>&nbsp;</td>
				<td>&nbsp; </td>
			<td align="left" valign="top">
			<input type="checkbox" name="Alternate_Payment_Recipient"  value="1" <cfif Form.Alternate_Payment_Recipient IS 1>checked</cfif> #FormStatus# >
			</td>
		</tr>
		</CFIF>

<!--- D37492  --->


	<cfif NOT(Generic_Type IS "LSAutoPay")>
	<!---Must Specify Broker(s)--->
	<CFIF fromSettings_management eq 1>
		<cfset SettingsTemplateForm(NameField="Specify_Brokers",NameFieldDesc="Allow #application.returned_customer_setting.broker_label_plural#")>
   	<CFELSE>
	<tr <cfif SettingsManagerTemplate.Specify_Brokers EQ 0> style="display:none"</cfif>>
		<td align="right" nowrap valign="top"><strong>Allow #application.returned_customer_setting.broker_label_plural#</strong></td>
			<td>&nbsp; </td>
			<td>&nbsp; </td>
		<td align="left" valign="top">
		<input type="checkbox" name="Specify_Brokers" <cfif Form.Specify_Brokers IS 1>checked</cfif> value="1" #FormStatus# >Required &nbsp; &nbsp;
		<input type="checkbox" name="Allow_Only_One_Broker" <cfif Form.Allow_Only_One_Broker IS 1>checked</cfif> value="1" #FormStatus# >Allow only one<!---D37702 :: Brokerage template type doesn't allow vendor select --->
	</tr>
	</CFIF>
	<cfelseif Generic_Type IS "LSAutoPay">
		<input type="hidden" name="One_Broker" value="1" >
		<input type="Hidden" name="Specify_Brokers" value="1" >
		<input type="Hidden" name="Allow_Only_One_Broker" value="0" >
	</cfif>

	<cfif NOT(Generic_Type IS "LSAutoPay")>
	<!---Must include at least one discount--->
	<CFIF fromSettings_management eq 1>
		<cfset SettingsTemplateForm(NameField="One_Discount_Mandated",NameFieldDesc="Discount Type")>
  	<CFELSE>
	<tr <cfif SettingsManagerTemplate.One_Discount_Mandated EQ 0> style="display:none"</cfif>>
		<td align="right" nowrap valign="top"><strong><!--- Require at least one discount --->Discount Type</strong></td>
			<td>&nbsp; </td>
			<td>&nbsp; </td>
		<td align="left" valign="top">
		<input type="checkbox" name="One_Discount_Mandated" <cfif Form.One_Discount_Mandated IS 1>checked</cfif> value="1" #FormStatus# >Required &nbsp; &nbsp;
    	<input type="checkbox" name="Allow_Only_One_Discount" onclick="checkallowoperators();" value="1" <cfif Form.Allow_Only_One_Discount IS 1>checked</cfif> #FormStatus# >Allow only one


    </td>
	</tr>
	</CFIF>
	<cfelseif Generic_Type IS "LSAutoPay">
		<input type="hidden" name="One_Discount_Mandated" value="1" />
    <input type="hidden" name="Allow_Only_One_Discount" value="0" />
	</cfif>

	<!--- Dev Note: 9955 Clay - If Pullbacks is On, Always include trade --->
	<cfif appSettings.getPullbacksOn()>
			<!--- If Pullbacks app setting is on, replace visible controls with hidden ones --->
			<input type="hidden" name="Include_Trade" value="1">
			<input type="hidden" name="Trade_Blurb" value="">
	<cfelseif NOT(Generic_Type IS "LSAutoPay")>
			<!---Include Trade--->
		<CFIF fromSettings_management eq 1>
			<cfset SettingsTemplateForm(NameField="Include_Trade",NameFieldDesc="Include Trade")>
  		<CFELSE>
			<tr <cfif SettingsManagerTemplate.Include_Trade EQ 0> style="display:none"</cfif>>
				<td align="right" nowrap valign="top"><strong>Include Trade</strong></td>
					<td>&nbsp; </td>
					<td>&nbsp; </td>
				<td align="left" valign="top">
				<input type="radio" name="Include_Trade" value="1" <cfif Form.Include_Trade IS 1>checked</cfif> #FormStatus# >Include Trade&nbsp; &nbsp;
				<input type="radio" name="Include_Trade" value="0" <cfif Form.Include_Trade IS 0>checked</cfif> #FormStatus# >Do Not Include Trade
				</td>
			</tr>
		</CFIF>
			<!--- Trade Message --->
		<CFIF fromSettings_management eq 1>
			<cfset SettingsTemplateForm(NameField="Trade_Blurb",NameFieldDesc="Exclude Trade Explanation")>
  		<CFELSE>
			<tr <cfif SettingsManagerTemplate.Trade_Blurb EQ 0> style="display:none"</cfif>>
				<td align="right" nowrap valign="top"><strong>Exclude Trade Explanation</strong></td>
					<td>&nbsp; </td>
					<td>&nbsp; </td>
				<td align="left" valign="top">

				<textarea name="Trade_Blurb" cols="40" rows="3" #FormStatus# ><cfif len(trim(Form.Trade_Blurb)) GT 0>#trim(Form.Trade_Blurb)#</cfif></textarea>
			</tr>
		</CFIF>
	</cfif>
	<CFIF fromSettings_management neq 1>
	<input type="hidden" name="Use_Discount_ID" value="#getGeneralSettings.Use_Discount_ID#" #FormStatus# >
	</CFIF>
	<!---Discount Type ID--->
	<cfif getGeneralSettings.Use_Discount_ID IS 1>

	<!---Gets values to populate pull down--->
	<cfquery name="GetsDiscountIDTypes" datasource="#application.datasource#">
		SELECT 		Discount_Identifier_Desc, Discount_Identifier_ID, Discount_Identifier_Number, isDefault
		FROM 		Discount_Identifier
		WHERE 		Deleted = 0
					AND Active = 1
		ORDER BY 	IsDefault Desc
	</cfquery>
	<CFIF fromSettings_management eq 1>
		<cfset SettingsTemplateForm(NameField="Discount_Identifier_ID",NameFieldDesc="Discount Identifier")>
  	<CFELSE>
	<tr <cfif SettingsManagerTemplate.Discount_Identifier_ID EQ 0> style="display:none"</cfif>>
		<td align="right" nowrap valign="top"><strong>Discount Identifier</strong></td>
			<td>&nbsp; </td>
			<td>&nbsp; </td>
		<td align="left" valign="top">
		<select name="Discount_Identifier_ID" #FormStatus# >
			<cfloop query="GetsDiscountIDTypes">
			<option value="#Discount_Identifier_ID#" <cfif isDefined("Form.Discount_Identifier_ID")>
														<cfif Discount_Identifier_ID eq Form.Discount_Identifier_ID>
															selected
														</cfif>
													<cfelseif isDefault eq 1>
														selected
													</cfif>>#Discount_Identifier_Number# (#left(Discount_Identifier_Desc, 25)#)
			</option>
			</cfloop>
		</select>
		</td>
	</tr>
	</CFIF>
	</cfif>
	<!--- Dev Note: BSD  --->
	<!--- If Template is Active then these next 2 fields can not be edited --->
		<!--- TSF - Label 18943: Removing Division and Distribution Channel as part of the spec for the new Business Unit Structure but keeping them as a hidden field
	<tr>
	 <td align="right" nowrap valign="top"><strong>Distribution Channel</strong></td>
	 <td>&nbsp;</td>
	 <td>&nbsp;</td>
	<td align="left" valign="top">
	 <input type="text" name="distribution_channel" value="#form.distribution_channel#" size="3" maxlength="4" <cfif Active eq 1>disabled="true"</cfif> #FormStatus# />
	</td>
	</tr>

	<!--- Dev Note: BSD  --->
	<tr>
	 <td align="right" nowrap valign="top"><strong>Division</strong></td>
	 <td>&nbsp;</td>
	 <td>&nbsp;</td>
	<td align="left" valign="top">
	 <input type="text" name="division" size="3" maxlength="2" value="#form.division#" <cfif Active eq 1>disabled="false"</cfif> #FormStatus# />
	</td>
	</tr>
	--->
	<CFIF fromSettings_management neq 1>
	<input type="hidden" name="distribution_channel" 	value="#form.distribution_channel#" <cfif Active eq 1>disabled="true"</cfif> />
	<input type="hidden" name="division"				value="#form.division#" <cfif Active eq 1>disabled="true"</cfif> />
	</CFIF>


<cfif NOT(Generic_Type IS "LSAutoPay")>
	<CFIF application.returned_customer_setting.Show_Fund_Settings EQ 1 AND application.returned_customer_setting.Upload_GL_Code EQ 1>
		<CFQUERY NAME="ActiveFiscalYear" DATASOURCE="#Application.Datasource#">
			SELECT * FROM GL_Code_Fund_Setting WHERE AR_Status = 1 AND Deleted = 0 ORDER BY CAST(AR_From_Fiscal_Year AS numeric)
		</CFQUERY>
		<CFSET ActiveFisYearList = VALUELIST(ActiveFiscalYear.AR_From_Fiscal_Year)>
		<CFIF fromSettings_management eq 1>
			<cfset SettingsTemplateForm(NameField="Show_Fund_Settings",NameFieldDesc="Fiscal Year, A/R and Allocation")>
  		<CFELSE> <!--- ELSE :: CFIF fromSettings_management eq 1 :: Fiscal Year, A/R and Allocation --->
		<TR <cfif SettingsManagerTemplate.Show_Fund_Settings EQ 0> style="display:none"</cfif>>
			<TD align="right" nowrap valign="top"><font class="requiredFieldsIndicator">*</font><B>Fiscal Year, A/R and Allocation</B></TD>
			<TD valign="top">&nbsp;</TD>
			<TD valign="top"><span id="error_AR"></span>&nbsp;</TD>
			<TD align="left" valign="top">
				<CFLOOP QUERY="ActiveFiscalYear">
					<CFIF ID NEQ "">
						<CFQUERY NAME="GetAR" DATASOURCE="#Application.Datasource#">
							SELECT * FROM GL_Code_AR_For_ProgTemp
							WHERE Template_ID = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">
							AND Fiscal_Year = <cfqueryparam value="#AR_From_Fiscal_Year#" cfsqltype="cf_sql_varchar">
							AND Deleted = 0
						</CFQUERY>
						<CFSET ThisFYsAR = VALUELIST(GetAR.A_R)>
						<CFPARAM NAME="FORM.SelectedAR_#AR_From_Fiscal_Year#" DEFAULT="#ThisFYsAR#">
					</CFIF>
					<B><FONT COLOR="Red" SIZE="2">[ </FONT><A HREF="/GL_Code/GL_Code_In_Program/AR_List.cfm?Fiscal_year=#AR_From_Fiscal_Year#" ONCLICK="NewWindow(this.href,'ARList','400','600','Yes', 'No');return false;" TITLE="Click to select A/R's from list of A/R from fiscal year #AR_From_Fiscal_Year#.">#ActiveFiscalYear.AR_From_Fiscal_Year#</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B>
					<CFSET SelectedAR = "">
					<CFIF IsDefined("FORM.SelectedAR_#AR_From_Fiscal_Year#")>
						<CFSET SelectedAR = EVALUATE("FORM.SelectedAR_#AR_From_Fiscal_Year#")>
					</CFIF>

					<CFIF SelectedAR NEQ "">
						<CFQUERY NAME="GetSeleted" DATASOURCE="#Application.Datasource#">
							SELECT 		DISTINCT 	A_R,
										A_R_DESCRIPTION
							FROM 		GL_Code_Activation
							INNER JOIN 	GL_Code_Upload ON GL_Code_Upload.GL_Code_Upload_ID = GL_Code_Activation.GL_Code_Upload_ID
										AND GL_Code_Upload.Deleted = 0
							WHERE 		GL_Code_Activation.Deleted = 0 AND
										<!--- GL_Code_Activation.Current_Active_Data = 1 AND --->
										DATEDIFF(d,getdate(),GL_Code_Upload.Activation_Date) <= 0
										AND GL_Code_Upload.Fiscal_Year = <cfqueryparam value="#AR_From_Fiscal_Year#" cfsqltype="cf_sql_varchar">
										AND	A_R IN (#LISTQUALIFY(SelectedAR,"'",",","All")#)
							ORDER BY	A_R
						</CFQUERY>
						<CFSET ThisLoopFiscalYear = AR_From_Fiscal_Year>
						<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="0">
							<CFLOOP QUERY="GetSeleted">
							<TR TITLE="#A_R_DESCRIPTION#" BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
								<TD WIDTH="20" ID="undoRedoImg_#ThisLoopFiscalYear#_#A_R#"><A Href="##" OnClick="Javascript: undoRedoAR(#ThisLoopFiscalYear#,#A_R#,1);return false;"><img  src="/Images/scissor.gif" width="14" height="9" title="Delete this AR." border="0"></A></TD>
								<TD STYLE="Border-Bottom: 1px solid C9D6F8" ID="TD_#ThisLoopFiscalYear#_#A_R#"><B>#A_R#</B> - </TD>
								<CFSET ARDescDisp = A_R_DESCRIPTION>
								<CFSET LenDesc = LEN(ARDescDisp)>
								<CFIF LenDesc GT 20>
									<CFSET ARDescDisp = LEFT(ARDescDisp,20)>
									<CFSET ARDescDisp = "#ARDescDisp#...">
								</CFIF>
								<TD STYLE="Border-Bottom: 1px solid C9D6F8" ID="TD_Desc_#ThisLoopFiscalYear#_#A_R#">#ARDescDisp#</TD>
							</TR>
							<CFQUERY NAME="CheckSaved" DATASOURCE="#Application.Datasource#">
								SELECT * FROM GL_Code_AR_For_ProgTemp
								WHERE Template_ID = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">
								AND Fiscal_Year = <cfqueryparam value="#ThisLoopFiscalYear#" cfsqltype="cf_sql_varchar">
								AND A_R = <cfqueryparam value="#A_R#" cfsqltype="cf_sql_varchar">
								AND Allocation_Method IS NOT NULL AND Deleted = 0
							</CFQUERY>
							<CFSET ThisARsAllocation = 1>
							<CFIF CheckSaved.RecordCount GT 0>
								<CFSET ThisARsAllocation = CheckSaved.Allocation_Method>
							</CFIF>
							<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
								<TD STYLE="Border-Bottom: solid 93BEE2 1px">&nbsp;</TD>
								<TD STYLE="Border-Bottom: solid 93BEE2 1px" COLSPAN="2">
									<INPUT TYPE="Radio" NAME="Allocation_Method_#ThisLoopFiscalYear#_#A_R#" VALUE="1" <CFIF ThisARsAllocation EQ 1>CHECKED</CFIF> #FormStatus# >Item
									<INPUT TYPE="Radio" NAME="Allocation_Method_#ThisLoopFiscalYear#_#A_R#" VALUE="2" <CFIF ThisARsAllocation EQ 2>CHECKED</CFIF> #FormStatus# >Fixed
									<INPUT TYPE="Radio" NAME="Allocation_Method_#ThisLoopFiscalYear#_#A_R#" VALUE="3" <CFIF ThisARsAllocation EQ 3>CHECKED</CFIF> #FormStatus# >Fund
								</TD>
							</TR>
							</CFLOOP>
						</TABLE>
					<CFELSE>
					<BR>
					</CFIF>
					<INPUT TYPE="Hidden" NAME="SelectedAR_#AR_From_Fiscal_Year#" <CFIF IsDefined("FORM.SelectedAR_#AR_From_Fiscal_Year#")>VALUE="#SelectedAR#"<CFELSE>VALUE=""</CFIF>>
					<INPUT TYPE="Hidden" NAME="DeletedAR_#AR_From_Fiscal_Year#" VALUE="">
				</CFLOOP>
			</TD>
		</TR>
		</CFIF> <!--- end :: CFIF fromSettings_management eq 1 :: Fiscal Year, A/R and Allocation --->
	</CFIF>
</CFIF><!---  LSAUTOPAY --->
	<!--- D8409: Broker and Trade Question --->
	<cfif appSettings.getBrokerTradeQuestOn() EQ 1 AND NOT(Generic_Type IS "LSAutoPay")>
		<CFIF fromSettings_management eq 1>
			<cfset SettingsTemplateForm(NameField="Broker_Trade_Question",NameFieldDesc="Enable Broker and Trade Questions")>
  		<CFELSE>
		<tr <cfif SettingsManagerTemplate.Broker_Trade_Question EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><strong>Enable Broker and Trade Questions</strong></td>
				<td>&nbsp; </td>
				<td>&nbsp; </td>
			<td align="left" valign="top">
			<input type="Checkbox" name="Broker_Trade_Question" value="1" <cfif Form.Broker_Trade_Question EQ 1>checked</cfif> #FormStatus# />
			</td>
		</tr>
		</CFIF>
	</cfif>
	<!---Check for Duplicate Program --->
	<cfparam name="check_label" default="Check for Duplicate Programs">
	<cfparam name="continue_label" default="Allow Duplicates of Approved Programs with a Warning">
	<cfparam name="stop_label" default="Prevent Duplicates of Approved Programs">
	<cfparam name="form.dupAction" default="2">
	<cfif NOT(Generic_Type IS "LSAutoPay")>
	<CFIF fromSettings_management eq 1>
		<cfset SettingsTemplateForm(NameField="Check_Duplicate_Program",NameFieldDesc="#check_label#")>
  	<CFELSE>
	<tr <cfif SettingsManagerTemplate.Check_Duplicate_Program EQ 0> style="display:none"</cfif>>
		<td align="right" nowrap valign="top"><strong>#check_label#</strong></td>
		<td>&nbsp; </td>
		<td>&nbsp; </td>
		<td align="left" valign="top" nowrap><input onClick="javascript:handleOptions(this.checked,'optionGrp');" type="checkbox" name="allow_dup_programs" <cfif Form.Check_Duplicate_Program IS 1>checked</cfif> value="1" #FormStatus# /></td>
	</tr>

	<tr <cfif SettingsManagerTemplate.Check_Duplicate_Program EQ 0> style="display:none"</cfif>>
		<td colspan="4"><DIV align="left" id="optionGrp" class="<cfif Form.Check_Duplicate_Program IS 1>showOptions<cfelse>hideOptions</cfif>">
				&nbsp; &nbsp; &nbsp; &nbsp;   <input type="radio" name="dupAction"  value="1"	<cfif form.dupAction EQ 1>checked</cfif> #FormStatus# />
				  #continue_label#<BR>
				&nbsp; &nbsp; &nbsp; &nbsp;   <input type="radio" name="dupAction"  value="2" <cfif form.dupAction EQ 2>checked</cfif> #FormStatus# />
				  #stop_label# </DIV>
		</td>
	</tr>
	</CFIF>
	<cfelse>
		<input type="hidden" name="dupAction" value="1">
		<input type="hidden" name="allow_dup_programs" value="1">
	</cfif>

	<CFIF fromSettings_management eq 1>
		<cfset SettingsTemplateForm(NameField="Claim_Rates_ConFig_Id",NameFieldDesc="Claim Rates Setting")>
  	<CFELSE>
	<tr <cfif SettingsManagerTemplate.Claim_Rates_ConFig_Id EQ 0> style="display:none"</cfif>>
		<td align="right" nowrap valign="top"><font class="requiredFieldsIndicator">*</font><strong>Claim Rates Setting</strong></td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td align="left" valign="top">
			<cfscript>
				 vars = {};
				 vars.claimRateCFC = createObject("component", "components.programs.claimRates");
				 vars.claimRateSettings = vars.claimRateCFC.getClaimRates();
			</cfscript>
			<select name="Claim_Rates_ConFig_Id" #FormStatus#>     <!---34596--->
				<option value="0">OFF</option>
				<cfloop query="vars.claimRateSettings">
					<option <cfif structKeyExists(form, 'Claim_Rates_ConFig_Id') and form.Claim_Rates_ConFig_Id eq vars.claimRateSettings.config_id>selected=selected</cfif> value="#vars.claimRateSettings.config_id#">#vars.claimRateSettings.config_name#</option>
				</cfloop>
		  </select>
		</td>
	</tr>
	</CFIF>

	<!--- XXXXXXXXXXXXXXXXXXXXXX   RESTRICTIONS	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<!--- XXXXXXXXXXXXXXXXXXXXXX   DATE RULES	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<tr id="daterules_heading"><Th colspan="100%" bgcolor="##93BEE2">Date Rules</TH></tr>
	<cfif NOT(Generic_Type IS "LSAutoPay")>
		<!---Maximum Duration--->
		<CFIF fromSettings_management eq 1>
			<cfset SettingsTemplateForm(NameField="Max_Duration",NameFieldDesc="Maximum Duration")>
  		<CFELSE>
		<tr class="daterules" <cfif SettingsManagerTemplate.Max_Duration EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><strong>Maximum Duration</strong></td>
				<td>&nbsp; <span id="error_Max_Duration"></span><span id="error_Max_Duration2"></span></td>
				<td>&nbsp; </td>
			<td align="left" valign="top">
			<input type="checkbox" name="Max_Duration" <cfif Form.Max_Duration IS 1>checked</cfif> value="1" <cfif form.Program_Date_Type eq 2>disabled</cfif> #FormStatus# >&nbsp; &nbsp;
			<input type="text" name="Max_Duration_Length" size="5" maxlength="10" <cfif form.Program_Date_Type eq 2>disabled</cfif> <cfif Form.Max_Duration_Length IS NOT 0> value="#Form.Max_Duration_Length#"</cfif> onKeyUp="clenseText(this, '0123456789')" #FormStatus# > Days
			</td>
		</tr>
		</CFIF>

		<!---Minimum Duration--->
		<CFIF fromSettings_management eq 1>
			<cfset SettingsTemplateForm(NameField="Min_Duration",NameFieldDesc="Minimum Duration")>
  		<CFELSE>
		<tr class="daterules" <cfif SettingsManagerTemplate.Min_Duration EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><strong>Minimum Duration</strong></td>
				<td>&nbsp; <span id="error_Min_Duration"></span><span id="error_Min_Duration2"></span></td>
				<td>&nbsp; </td>
			<td align="left" valign="top">
			<input type="checkbox" name="Min_Duration" <cfif form.Program_Date_Type eq 2>disabled</cfif> <cfif Form.Min_Duration IS 1>checked</cfif> value="1" #FormStatus# >&nbsp; &nbsp;
			<input type="text" name="Min_Duration_Length" size="5" maxlength="10" <cfif form.Program_Date_Type eq 2>disabled</cfif> <cfif Form.Min_Duration_Length IS NOT 0> value="#Form.Min_Duration_Length#"</cfif> onKeyUp="clenseText(this, '0123456789')" #FormStatus# > Days
			</td>
		</tr>
		</CFIF>
	<cfelse>
		<input type="hidden" name="Max_Duration" value="0" />
		<input type="hidden" name="Max_Duration_Length" value="0" />
		<input type="hidden" name="Min_Duration" value="0" />
		<input type="hidden" name="Min_Duration_Length" value="0" />
	</cfif><!--- 	LSAUTOPAY end --->
	<!---Program Date Types--->
	<CFIF fromSettings_management eq 1>
		<cfset SettingsTemplateForm(NameField="Program_Date_Type",NameFieldDesc="Program Date Type")>
  	<CFELSE>
	<tr  class="daterules" <cfif SettingsManagerTemplate.Program_Date_Type EQ 0> style="display:none"</cfif>>
		<td align="right" nowrap valign="top"><strong>Program Date Type</strong></td>
		<td>&nbsp;</td>
		<td>&nbsp; </td>
		<TD align="left" valign="top">
			<SELECT NAME="Program_Date_Type" onChange="programDateType();"  #FormStatus# >
				<OPTION VALUE="1">Free Form</OPTION>
				<OPTION VALUE="2" <cfif form.Program_Date_Type eq 2>selected</cfif>>Fixed Date</OPTION>
			</SELECT>
		</TD>
	</tr>
	</CFIF>
	<cfif NOT(Generic_Type IS "LSAutoPay")>
	<!--- Dev Note: Milan; 6117 --->
		<!---Program Start Day restriction--->
		<CFIF fromSettings_management eq 1>
			<cfset SettingsTemplateForm(NameField="Program_Start_Day",NameFieldDesc="Program Start Day")>
  		<CFELSE>
		<tr class="daterules" <cfif SettingsManagerTemplate.Program_Start_Day EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><strong>Program Start Day</strong></td>
			<td>&nbsp;<span id="error_Program_Start_Day"></span></td>
			<td>&nbsp; </td>
			<TD align="left" valign="top">
				<SELECT NAME="Program_Start_Day" id="Program_Start_Day" #FormStatus# >
						<OPTION VALUE="0">**None**</OPTION>
					<cfloop from="1" to="7" index="num">
						<OPTION VALUE="#num#" <cfif form.program_start_day eq num>selected</cfif>>#DateFormat(num,"dddd")#</OPTION>
					</cfloop>
				</SELECT>
			</TD>
		</tr>
		</CFIF>
	<!---Program End Day restriction--->
		<CFIF fromSettings_management eq 1>
			<cfset SettingsTemplateForm(NameField="Program_End_Day",NameFieldDesc="Program Start Day")>
  		<CFELSE>
		<tr class="daterules" <cfif SettingsManagerTemplate.Program_End_Day EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><strong>Program End Day</strong></td>
			<td>&nbsp;<span id="error_Program_End_Day"></span></td>
			<td>&nbsp; </td>
			<TD align="left" valign="top">
				<SELECT NAME="Program_End_Day" id="Program_End_Day" #FormStatus# >
						<OPTION VALUE="0">**None**</OPTION>
					<cfloop from="1" to="7" index="num">
						<OPTION VALUE="#num#" <cfif form.program_end_day eq num>selected</cfif>>#DateFormat(num,"dddd")#</OPTION>
					</cfloop>
				</SELECT>
			</TD>
		</tr>
		</CFIF>
		<!--- End Note: Milan; 6117 --->
		<!--- D11447: MFS budgets --->
		<!--- 1. Program start date cannot start before:  xx/xx/xxxx --->
		<CFIF fromSettings_management eq 1>
			<cfset SettingsTemplateForm(NameField="Program_Min_Start_Date",NameFieldDesc="Program start date cannot start before")>
  		<CFELSE>
		<tr class="daterules" <cfif SettingsManagerTemplate.Program_Min_Start_Date EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><strong>Program start date cannot <br>start before</strong></td>
			<td>&nbsp;<span id="error_Program_Min_Start_Date"></span></td>
			<td>&nbsp; </td>
			<TD align="left" valign="top">
				<CF_EASYDATE FORMNAME="BasicInfo" FIELDNAME="Program_Min_Start_Date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.Program_Min_Start_Date#">
			</TD>
		</tr>
		</CFIF>
		<!--- 2. Program end date cannot end after: xx/xx/xxxx --->
		<CFIF fromSettings_management eq 1>
			<cfset SettingsTemplateForm(NameField="Program_Max_End_Date",NameFieldDesc="Program start date cannot start before")>
  		<CFELSE>
		<tr class="daterules" <cfif SettingsManagerTemplate.Program_Max_End_Date EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><strong>Program end date cannot <br>end after</strong></td>
			<td>&nbsp;<span id="error_Program_Max_End_Date"></span></td>
			<td>&nbsp; </td>
			<TD align="left" valign="top">
				<CF_EASYDATE FORMNAME="BasicInfo" FIELDNAME="Program_Max_End_Date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.Program_Max_End_Date#">
			</TD>
		</tr>
		</CFIF>
	</cfif>
	<!---Allow Retroactive--->
	<CFIF fromSettings_management eq 1>
		<cfset SettingsTemplateForm(NameField="Allow_Retro_Create",NameFieldDesc="Allow Retroactive Programs")>
  	<CFELSE>
	<tr class="daterules" <cfif SettingsManagerTemplate.Allow_Retro_Create EQ 0> style="display:none"</cfif>>
		<td align="right" nowrap valign="top"><font class="retroFieldsIndicator">*</font><strong>Allow Retroactive Programs</strong></td>
		<td>&nbsp; <span id="error_Allow_Retro_Create"></span><span id="error_Allow_Retro_Create2"></span></td>
		<td>&nbsp; </td>
		<td align="left" valign="top">
			<input type="checkbox" name="Allow_Retro_Create" <cfif Form.Allow_Retro_Create IS 1>checked</cfif> value="1" #FormStatus# >&nbsp; &nbsp;
			<input type="text" name="Allow_Retro_Create_Max" size="5" maxlength="10" <cfif Form.Allow_Retro_Create_Max IS NOT 0>  value="#Form.Allow_Retro_Create_Max#"</cfif> onKeyUp="clenseText(this, '0123456789')" #FormStatus# > Days
		</td>
	</tr>
	</CFIF>
	<!--- Dev Note Kal - D8026 - Allow Revisions Check Box --->
	<!---Do Not Allow Revisions--->
	<cfif NOT(Generic_Type IS "LSAutoPay")>
		<CFIF fromSettings_management eq 1>
   			<cfset SettingsTemplateForm(NameField="Revision_Not_Allowed",NameFieldDesc="Do Not Allow Revisions")>
  		<CFELSE>
			<tr <cfif SettingsManagerTemplate.Revision_Not_Allowed EQ 0> style="display:none"</cfif>>
				<td align="right" nowrap valign="top"><B>Do Not Allow Revisions</B></td>
				<td>&nbsp;<span id="err_Revision_Not_Allowed"></span> </td>
				<td>&nbsp; </td>
				<td align="left" valign="top">
					<input onclick="javaScript:showHideRetroRevisions(this)" type="checkbox" name="Revision_Not_Allowed" <cfif Form.Revision_Not_Allowed IS 1>checked</cfif> value="1" #FormStatus# >
				</td>
			</tr>
		</CFIF>
			<script language="JavaScript">
			function showHideRetroRevisions(thisObj)
			{
				var trObj 		= 	document.all.tr_Allow_Retro_Revision;
				var formObj1	= 	document.all.Allow_Retro_Revision;
				var formObj2 	= 	document.all.Allow_Retro_Revision_Span;

				if(thisObj.checked)
				{
					formObj1.checked = false;
					formObj2.value = '';
					formObj1.disabled = true;
					formObj2.disabled = true;
					trObj.disabled = true;
				}
				else
				{
					formObj1.disabled = false;
					formObj2.disabled = false;
					trObj.disabled = false;
				}
			}
			</script>
			<!---Allow Retroactive Revisions--->
		<CFIF fromSettings_management eq 1>
			<cfset SettingsTemplateForm(NameField="Allow_Retro_Revision",NameFieldDesc="Allow Retroactive Revisions")>
  		<CFELSE>
			<tr class="daterules" id="tr_Allow_Retro_Revision" <cfif SettingsManagerTemplate.Allow_Retro_Revision EQ 0> style="display:none"</cfif>>
				<td align="right" nowrap valign="top"><font class="retroFieldsIndicator">*</font><strong>Allow Retroactive Revisions</strong></td>
					<td>&nbsp; <span id="error_Allow_Retro_Revision"></span><span id="error_Allow_Retro_Revision2"></span></td>
					<td>&nbsp; </td>
				<td align="left" valign="top">
					<input type="checkbox" name="Allow_Retro_Revision" <cfif Form.Allow_Retro_Revision IS 1>checked</cfif> value="1" #FormStatus# >&nbsp; &nbsp;
					<input type="text" name="Allow_Retro_Revision_Span" size="5" maxlength="10" value="#Form.Allow_Retro_Revision_Span#" onKeyUp="clenseText(this, '0123456789')" #FormStatus# > Days
				</td>
			</tr>

			<cfif Form.Revision_Not_Allowed EQ 1>
				<script>showHideRetroRevisions(document.all.Revision_Not_Allowed)</script>
			</cfif>
			<!--- End: Dev Note Kal - D8026 - Allow Revisions Check Box --->
		</CFIF>
			<!---Auto Renewal--->
		<CFIF fromSettings_management eq 1>
			<cfset SettingsTemplateForm(NameField="Auto_Renew_Option",NameFieldDesc="Allow Auto Renewal")>
  		<CFELSE>
			<tr class="daterules" <cfif SettingsManagerTemplate.Auto_Renew_Option EQ 0> style="display:none"</cfif>>
				<td align="right" nowrap valign="top"><strong>Allow Auto Renewal</strong></td>
					<td>&nbsp; <span id="error_Auto_Renew_Option"></span></td>
					<td>&nbsp; </td>
				<td align="left" valign="top">
				<input type="checkbox" name="Auto_Renew_Option" <cfif Form.Auto_Renew_Option IS 1>checked</cfif> value="1" #FormStatus# >&nbsp; &nbsp;
				</td>
			</tr>
		</CFIF>
			<!---This app setting says whether auto renew is set in program wizard or in particular program--->

				<cfif AppSettings.AutoRenewSpaninPW IS 1>

			<!---Can user overwrite program wizard setting?--->
		<CFIF fromSettings_management eq 1>
			<cfset SettingsTemplateForm(NameField="Allow_AR_Modification",NameFieldDesc="User can modify Auto Renew Span")>
  		<CFELSE>
			<tr class="daterules" <cfif SettingsManagerTemplate.Allow_AR_Modification EQ 0> style="display:none"</cfif>>
				<td align="right" nowrap valign="top"><strong>User can modify Auto Renew Span</strong></td>
					<td>&nbsp; <span id="error_Allow_AR_Modification"></span></td>
					<td>&nbsp; </td>
				<td align="left" valign="top">
				<input type="checkbox" name="Allow_AR_Modification" <cfif Form.Allow_AR_Modification IS 1>checked</cfif> value="1" #FormStatus# >&nbsp; &nbsp;
				</td>
			</tr>
		</CFIF>

			<!---Weeks before Expiring to Auto Renew--->
			<CFIF fromSettings_management eq 1>
				<cfset SettingsTemplateForm(NameField="Days_Before_Auto_Renew",NameFieldDesc="Auto Renew lead time (days) before new start date")>
  			<CFELSE>
			<tr class="daterules" <cfif SettingsManagerTemplate.Days_Before_Auto_Renew EQ 0> style="display:none"</cfif>>
				<td align="right" nowrap valign="top"><strong>Auto Renew lead time (days) before new start date</strong></td>
					<td>&nbsp; <span id="error_Days_Before_Auto_Renew"></span></td>
					<td>&nbsp; </td>
				<td align="left" valign="top">
				<input type="text" size="10" maxlength="10" name="Days_Before_Auto_Renew" value="#Days_Before_Auto_Renew#" onKeyUp="clenseText(this, '0123456789')" #FormStatus# >&nbsp; &nbsp;
				</td>
			</tr>
			</CFIF>

			<!---Check box indicating whether or not to apply lead time to all existing programs--->
			<CFIF fromSettings_management eq 1>
				<cfset SettingsTemplateForm(NameField="Apply_Lead_Time_To_All",NameFieldDesc="Apply Auto Renew lead time to all")>
  			<CFELSE>
				<tr class="daterules" <cfif SettingsManagerTemplate.Days_Before_Auto_Renew EQ 0> style="display:none"</cfif>>
					<td align="right" nowrap valign="top"><strong>Apply Auto Renew lead time to all</strong></td>
						<td>&nbsp; <span id="error_Apply_Lead_Time_To_All"></span></td>
						<td>&nbsp; </td>
						<td align="left" valign="top">
							<input type="checkbox" name="Apply_Lead_Time_To_All" value="1" #FormStatus# />&nbsp; &nbsp;
						</td>
				</tr>
			</CFIF>


			</cfif>
	<cfelse>
		<input type="hidden" name="Allow_Retro_Revision" value="0">
		<input type="hidden" name="Allow_Retro_Revision_Span" value="0">
	</cfif><!--- 	LSAUTOPAY end --->
		<!---Days after RFA for--->
	<CFIF fromSettings_management eq 1>
		<cfset SettingsTemplateForm(NameField="Days_For_Reminder",NameFieldDesc="Days After RFA to Send Approval Reminder")>
  	<CFELSE>
	<tr class="daterules" <cfif SettingsManagerTemplate.Days_For_Reminder EQ 0> style="display:none"</cfif>>
		<td align="right" nowrap valign="top"><strong>Days After RFA to <br>Send Approval Reminder </strong></td>
			<td>&nbsp; <span id="error_Days_For_Reminder"></span></td>
			<td>&nbsp; </td>
		<td align="left" valign="top">
		<input type="text" size="10" maxlength="10" name="Days_For_Reminder" value="#Days_For_Reminder#" onKeyUp="clenseText(this, '0123456789')" #FormStatus# >&nbsp; &nbsp;
		</td>
	</tr>
	</CFIF>

	<!---Days before Expiring to mark as expiring--->
	<CFIF fromSettings_management eq 1>
		<cfset SettingsTemplateForm(NameField="Expiring_Notification_Span",NameFieldDesc="Weeks Before End of Program to Mark as Expiring")>
   	<CFELSE>
	<tr class="daterules" <cfif SettingsManagerTemplate.Expiring_Notification_Span EQ 0> style="display:none"</cfif>>
		<td align="right" nowrap valign="top"><strong>Weeks Before End of Program to <br>Mark as Expiring</strong></td>
			<td>&nbsp; <span id="error_Expiring_Notification_Span"></span></td>
			<td>&nbsp; </td>
		<td align="left" valign="top">
		<input type="text" size="10" maxlength="10" name="Expiring_Notification_Span" value="#Expiring_Notification_Span#" onKeyUp="clenseText(this, '0123456789')" #FormStatus# >&nbsp; &nbsp;
		</td>
	</tr>
	</CFIF>

	<!--- Dev Note: BSD D11656 --->
	<cfif NOT (Generic_Type IS "Brokerage" OR Generic_Type IS "LSAutoPay")>
		<CFIF fromSettings_management eq 1>
   			<cfset SettingsTemplateForm(NameField="Retail_Performance_Dates",NameFieldDesc="Performance Dates On")>
  		<CFELSE>
		<tr class="daterules" <cfif SettingsManagerTemplate.Retail_Performance_Dates EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><strong>Performance Dates On</strong></td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td align="left" valign="top">
				<input type="checkbox" name="Performance_Dates_On" value="1" <cfif Form.Performance_Dates_On IS 1>checked</cfif> #FormStatus# />
			</td>
		</tr>
		</CFIF>
	</cfif>
	<cfif Generic_Type IS NOT 'Brokerage' AND NOT(Generic_Type IS "LSAutoPay")>
		<CFIF fromSettings_management eq 1>
  			<cfset SettingsTemplateForm(NameField="Include_Open_Date",NameFieldDesc="Include Open Date")>
			<!--- Include_Time_Of_Open_Date is related to  Include_Open_Date --->
  		<CFELSE>
			<tr class="daterules" <cfif SettingsManagerTemplate.Include_Open_Date EQ 0> style="display:none"</cfif>>
				<td align="right" valign="top"><strong>Include Open Date </strong></td>
					<td>&nbsp; </td>
					<td>&nbsp; </td>
				<td align="left" valign="top">
					<input type="checkbox" name="Include_Open_Date" <cfif Form.Include_Open_Date IS 1>checked</cfif> value="1" onclick="if(this.checked) {document.all.idInclude_Time_Of_Open_Date.style.display=''} else  {document.all.idInclude_Time_Of_Open_Date.style.display='none'} " #FormStatus# >
				</td>
			</tr>
			<tr id="idInclude_Time_Of_Open_Date" class="daterules" <cfif SettingsManagerTemplate.Include_Open_Date EQ 0> style="display:none"<cfelse> style="display:<cfif Form.Include_Open_Date IS 1>''<cfelse> none</cfif>;"</cfif>>
				<td align="right" valign="top"><strong>Include Time of Open Date</strong></td>
					<td>&nbsp; </td>
					<td>&nbsp; </td>
				<td align="left" valign="top">
					<input type="checkbox" name="Include_Time_Of_Open_Date" <cfif Form.Include_Time_Of_Open_Date IS 1>checked</cfif> value="1" #FormStatus# >
				</td>
			</tr>
		</CFIF>
		<CFIF fromSettings_management eq 1>
			<cfset SettingsTemplateForm(NameField="Include_Date_Needed_by",NameFieldDesc="Include Date Needed By")>
  		<CFELSE>
			<tr class="daterules" <cfif SettingsManagerTemplate.Include_Date_Needed_by EQ 0> style="display:none"</cfif>>
				<td align="right" valign="top"><strong>Include Date Needed By </strong></td>
					<td>&nbsp; </td>
					<td>&nbsp; </td>
				<td align="left" valign="top">
				<input type="checkbox" name="Include_Date_Needed_by" <cfif Form.Include_Date_Needed_by IS 1>checked</cfif> value="1" #FormStatus# >
				</td>
			</tr>
		</CFIF>
		<CFIF fromSettings_management eq 1>
   			<cfset SettingsTemplateForm(NameField="Include_Reply_Date",NameFieldDesc="Include Expected Reply Date")>
  		<CFELSE>
			<tr class="daterules" <cfif SettingsManagerTemplate.Include_Reply_Date EQ 0> style="display:none"</cfif>>
				<td align="right" valign="top"><strong>Include Expected Reply Date </strong></td>
					<td>&nbsp; </td>
					<td>&nbsp; </td>
				<td align="left" valign="top">
				<input type="checkbox" name="Include_Reply_Date" <cfif Form.Include_Reply_Date IS 1>checked</cfif> value="1" #FormStatus# >
				</td>
			</tr>
		</CFIF>
	</cfif>
	<!--- XXXXXXXXXXXXXXXXXXXXXX   VOLUME RULES	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<tr id="volumerules_heading"><Th colspan="100%" bgcolor="##93BEE2">Volume Rules</TH></tr>
	<cfif NOT(Generic_Type IS "LSAutoPay")>
			<cfif Generic_Type IS "Distributor Off-Invoice" or Generic_Type IS "Brokerage">
				<input type="hidden" name="Controllable_Volume" value="0">
				<input type="hidden" name="Adv_Spend" value="0">
				<cfif Generic_Type IS "Brokerage"><input type="hidden" name="Zero_Volume" value="1"></cfif>
			<cfelse>
				<CFIF fromSettings_management eq 1>
					<cfset SettingsTemplateForm(NameField="Zero_Volume",NameFieldDesc="Allow Zero Volume")>
  				<CFELSE>
				<!----Zero Volume--->
				<tr class="volumerules" <cfif SettingsManagerTemplate.Zero_Volume EQ 0> style="display:none"</cfif>>
					<td align="right" nowrap valign="top"><strong>Allow Zero Volume</strong></td>
					<td>&nbsp; </td>
					<td>&nbsp; </td>
					<td align="left" valign="top">
						<input type="checkbox" name="Zero_Volume" <cfif Form.Zero_Volume IS 1>checked</cfif> value="1" #FormStatus# >
					</td>
				</tr>
				</CFIF>
			</cfif>
	</cfif><!--- 	LSAUTOPAY end --->

	<cfif NOT(Generic_Type IS "Distributor Off-Invoice" OR Generic_Type IS "Brokerage") >
		<cfif NOT(Generic_Type IS "LSAutoPay")>
			<!---Maximum Volume--->
			<CFIF fromSettings_management eq 1>
   				<cfset SettingsTemplateForm(NameField="Max_Global_Volume",NameFieldDesc="Maximum Total Volume")>
  			<CFELSE>
			<tr class="volumerules" <cfif SettingsManagerTemplate.Max_Global_Volume EQ 0> style="display:none"</cfif>>
				<td align="right" nowrap valign="top"><strong>Maximum Total Volume</strong></td>
					<td>&nbsp; <span id="error_Max_Global_Volume"></span><span id="error_Max_Global_Volume2"></span></td>
					<td>&nbsp; </td>
				<td align="left" valign="top">
				<input type="checkbox" name="Max_Global_Volume" <cfif Form.Max_Global_Volume IS 1>checked</cfif> value="1" #FormStatus# >&nbsp; &nbsp;
				<input type="text" name="Max_Global_Volume_Size_LBS" size="5" maxlength="10" <cfif Form.Max_Global_Volume_Size_LBS IS NOT 0> value="#Form.Max_Global_Volume_Size_LBS#"</cfif> onKeyUp="clenseText(this, '0123456789')" #FormStatus# > Pounds
				<br><input type="checkbox" style="visibility:hidden"><!--- dummy checkbox to adjust alignment --->&nbsp; &nbsp;
				<input type="text" name="Max_Global_Volume_Size_CS" size="5" maxlength="10" <cfif Form.Max_Global_Volume_Size_CS IS NOT 0> value="#Form.Max_Global_Volume_Size_CS#"</cfif> onKeyUp="clenseText(this, '0123456789')" #FormStatus# > Cases
				</td>
			</tr>
			</CFIF>

			<!---Minimum Volume--->
			<CFIF fromSettings_management eq 1>
   					<cfset SettingsTemplateForm(NameField="Min_Global_Volume",NameFieldDesc="Minimum Total Volume")>
  			<CFELSE>
			<tr class="volumerules" <cfif SettingsManagerTemplate.Min_Global_Volume EQ 0> style="display:none"</cfif>>
				<td align="right" nowrap valign="top"><strong>Minimum Total Volume</strong></td>
					<td>&nbsp; <span id="error_Min_Global_Volume"></span><span id="error_Min_Global_Volume2"></span></td>
					<td>&nbsp; </td>
				<td align="left" valign="top">
				<input type="checkbox" name="Min_Global_Volume" <cfif Form.Min_Global_Volume IS 1>checked</cfif> value="1" #FormStatus# >&nbsp; &nbsp;
				<input type="text" name="Min_Global_Volume_Size_LBS" size="5" maxlength="10" <cfif Form.Min_Global_Volume_Size_LBS IS NOT 0> value="#Form.Min_Global_Volume_Size_LBS#"</cfif> onKeyUp="clenseText(this, '0123456789')" #FormStatus# > Pounds
				<br><input type="checkbox" style="visibility:hidden"><!--- dummy checkbox to adjust alignment --->&nbsp; &nbsp;
				<input type="text" name="Min_Global_Volume_Size_CS" size="5" maxlength="10" <cfif Form.Min_Global_Volume_Size_CS IS NOT 0> value="#Form.Min_Global_Volume_Size_CS#"</cfif> onKeyUp="clenseText(this, '0123456789')" #FormStatus# > Cases
				</td>
			</tr>
			</CFIF>

			<!--- Volume Cap --->
			<CFIF fromSettings_management eq 1>
   					<cfset SettingsTemplateForm(NameField="Volume_Cap",NameFieldDesc="Volume Cap")>
  			<CFELSE>
			<tr class="volumerules" <cfif SettingsManagerTemplate.Volume_Cap EQ 0> style="display:none"</cfif>>
				<td align="right" nowrap valign="top"><strong>Volume Cap</strong></td>
					<td>&nbsp; </td>
					<td>&nbsp; </td>
				<td align="left" valign="top">
				<input type="checkbox" name="Volume_Cap" <cfif Form.Volume_Cap IS 1>checked</cfif> value="1" #FormStatus# >
				</td>
			</tr>
			</CFIF>
		<cfelse>
			<input type="hidden" name="Max_Global_Volume" value="0" />
			<input type="hidden" name="Max_Global_Volume_Size_LBS" value="0" />
			<input type="hidden" name="Max_Global_Volume_Size_CS" value="0" />
			<input type="hidden" name="Min_Global_Volume" value="0" />
			<input type="hidden" name="Min_Global_Volume_Size_LBS" value="0" />
			<input type="hidden" name="Min_Global_Volume_Size_CS" value="0" />
			<input type="hidden" name="Volume_Cap" value="0" />
		</cfif><!--- 	LSAUTOPAY end --->
	</cfif>
	<!--- Automate volume 28114 --->
	<CFIF fromSettings_management eq 1>
   			<cfset SettingsTemplateForm(NameField="Auto_Volume",NameFieldDesc="Automate Volume")>
  	<CFELSE>
	<tr class="volumerules" <cfif SettingsManagerTemplate.Auto_Volume EQ 0> style="display:none"</cfif>>
		<td align="right" nowrap valign="top">
			<font class="retroFieldsIndicator">*</font><strong>Automate Volume</strong>
		<!--- D38942 :: Program Blackout Period on Frontend--->
			<CF_SmallHelp
			width="900"
			displayShifyX = "-200"
			imgPath="/Images/i.gif"
			imgWidth="12"
			imgHeight="11"
			dropdownCheck="0"
			>
			<div style="text-align: left;">
				<B>a.</B> Define blackout periods -- Template or Program.   <br>
				&nbsp;&nbsp;&nbsp;&nbsp;The option to set the blackout periods at the template or program level.   <br>
				&nbsp;&nbsp;&nbsp;&nbsp;Note:  If you initially selected program level and then change to template level, Blacksmith will overwrite any program level values with the template values.<br>
				<B>b.</B> Weeks after start date to ignore for volume automation:  <br>
				&nbsp;&nbsp;&nbsp;&nbsp;Number of weeks after the program's start date to ignore volume.  <br>
				&nbsp;&nbsp;&nbsp;&nbsp;This is the Blackout Period.   For example, you may not want to count the first 3 weeks of volume in the volume automation calculations.<br>
				<B>c.</B> Weeks before end date to ignore for volume automation:  <br>
				&nbsp;&nbsp;&nbsp;&nbsp;Number of weeks before the program's end date to ignore volume.   <br>
				&nbsp;&nbsp;&nbsp;&nbsp;This is the Blackout Period.   For example, you may not want to count the last 3 weeks of volume in the volume automation calculations.<br>
				<B>d.</B> Weeks after start date to update actual - The number of weeks after the start date to begin the automation of the volume.  <br>
				&nbsp;&nbsp;&nbsp;&nbsp;For example, something like 13 weeks for operator based program to provide enough time for some claims to come through.  <br>
				&nbsp;&nbsp;&nbsp;&nbsp;Assuming we are at 13, then, the application will update 13 weeks of the original estimate and replace it with the actual run rate.  <br>
				&nbsp;&nbsp;&nbsp;&nbsp;For billbacks, the run rate is the total span of the min start and max end of the billbacks so far.  So, for example, if we have two months of billbacks after 13 weeks, we would have 8 weeks of activity.  <br>
				&nbsp;&nbsp;&nbsp;&nbsp;The weekly average of those billbacks will become 13 weeks of the estimate.<br>
				<B>e.</B> Weeks after start date to automate future volume - 	Future volume will replace the "To Go" element of the original forecast with the run rate.  <br>
				&nbsp;&nbsp;&nbsp;&nbsp;At the "N" week point, the original forecast becomes obsolete altogether to be replaced by the weekly run rate so far.
			</div>
			</CF_SmallHelp>
		<!--- D38942 :: Program Blackout Period on Frontend--->
		</td>
		<td>&nbsp; </td>
		<td>&nbsp; </td>
		<td align="left" valign="top">
			<input type="radio" name="Auto_Volume" value="0" checked onclick="document.all.ItemMarkedLostProgramVolumeAutomation.className ='hideOptions';"	#FormStatus#  >Off
			<!---
			<br><input type="radio" name="Auto_Volume" value="2" <cfif Form.Auto_Volume IS 2>checked</cfif> #FormStatus#>Daily
			<br><input type="radio" name="Auto_Volume" value="3" <cfif Form.Auto_Volume IS 3>checked</cfif> #FormStatus#>Weekly
			 --->
			<br><input type="radio" name="Auto_Volume" value="4" <cfif Form.Auto_Volume NEQ 0>checked</cfif> onclick="if(document.all.BidRequestStatusOn.checked){document.all.ItemMarkedLostProgramVolumeAutomation.className='showOptions';}" #FormStatus#>On
		</td>
	</tr>
	</CFIF>
<!--- D38942 :: Program Blackout Period on Frontend--->
<CFIF fromSettings_management eq 1>
	<cfset SettingsTemplateForm(NameField="blackout_periods",NameFieldDesc="Define blackout periods")>
<CFELSE>
	<tr class="volumerules" <cfif SettingsManagerTemplate.Blackout_Periods EQ 0> style="display:none"</cfif>>
		<td align="right" nowrap valign="top">
			<font class="retroFieldsIndicator">*</font><strong>Define Blackout Periods</strong>
		</td>
		<td>&nbsp; </td>
		<td>&nbsp; </td>
		<td align="left" valign="top">
			<input type="radio" name="blackout_periods" value="1" <cfif FORM.blackout_periods is 1>checked</cfif> onclick="show('blackout_after','blackout_before')" #FormStatus#  >Template
		<br>
			<input type="radio" name="blackout_periods" value="2" <cfif FORM.blackout_periods is 2>checked</cfif> onclick="hide('blackout_after','blackout_before')" #FormStatus#>Program
		</td>
	</tr>
</CFIF>

<CFIF fromSettings_management eq 1>
		<cfset SettingsTemplateForm(NameField="start_zero",NameFieldDesc="Weeks after start date to ignore for volume automation")>
<CFELSE>
		<cfif SettingsManagerTemplate.start_zero><!---blackout_weeks_after --->
		<tr id="blackout_after" <cfif FORM.blackout_periods EQ 2 OR FORM.blackout_periods EQ 0>style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><font class="retroFieldsIndicator">*</font><strong>Weeks after start date to ignore for volume automation</strong></td>
			<td>&nbsp; </td>
			<td>&nbsp; </td>
			<td align="left" valign="top">
				<input type="text" name="start_zero" size="5" maxlength="3"  value="#Form.Start_Zero#" onKeyUp="clenseText(this, '0123456789')"  #FormStatus# >
			</td>
		</tr>
		</cfif>
</CFIF>

<CFIF fromSettings_management eq 1>
		<cfset SettingsTemplateForm(NameField="future_zero",NameFieldDesc="Weeks before end date to ignore for volume automation")>
<CFELSE>
	<cfif SettingsManagerTemplate.future_zero>
			<tr id="blackout_before" <cfif FORM.blackout_periods EQ 2 OR FORM.blackout_periods EQ 0>style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><font class="retroFieldsIndicator">*</font><strong>Weeks before end date to ignore for volume automation</strong></td>
			<td>&nbsp; </td>
			<td>&nbsp; </td>
			<td align="left" valign="top">
				<input type="text" name="future_zero" size="5" maxlength="3"  value="#Form.Future_Zero#" onKeyUp="clenseText(this, '0123456789')"  #FormStatus# >
			</td>
		</tr>
	</cfif>
</CFIF>

<!---D38942 :: Program Blackout Period on Frontend --->
	<!---- Auto_Actual 28114 --->
	<CFIF fromSettings_management eq 1>
   			<cfset SettingsTemplateForm(NameField="Auto_Actual",NameFieldDesc="Weeks after start date to update actual")>
  	<CFELSE>
	<tr class="volumerules" <cfif SettingsManagerTemplate.Auto_Actual EQ 0> style="display:none"</cfif>>
		<td align="right" nowrap valign="top"><font class="retroFieldsIndicator">*</font><strong>Weeks after start date to update actual</strong></td>
		<td>&nbsp; </td>
		<td>&nbsp; </td>
		<td align="left" valign="top">
		<input type="text" name="Auto_Actual" size="5" maxlength="3"  value="#Form.Auto_Actual#" onKeyUp="clenseText(this, '0123456789')"  #FormStatus# >
		</td>
	</tr>
	</CFIF>
	<!---- Auto_Future 28114 --->
	<CFIF fromSettings_management eq 1>
   			<cfset SettingsTemplateForm(NameField="Auto_Future",NameFieldDesc="Weeks after start date to automate future volume")>
  	<CFELSE>
	<tr class="volumerules" <cfif SettingsManagerTemplate.Auto_Future EQ 0> style="display:none"</cfif>>
		<td align="right" nowrap valign="top"><font class="retroFieldsIndicator">*</font><strong>Weeks after start date to automate future volume</strong></td>
		<td>&nbsp; </td>
				<td>&nbsp; </td>
			<td align="left" valign="top">
			<input type="text" name="Auto_Future" size="5" maxlength="3"  value="#Form.Auto_Future#" onKeyUp="clenseText(this, '0123456789')"  #FormStatus# >
			</td>
	</tr>
	</CFIF>

	<!--- XXXXXXXXXXXXXXXXXXXXXX   COMPONENT RULES	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<tr id="componentrules_heading"><Th colspan="100%" bgcolor="##93BEE2">Component Rules</TH></tr>
	<!--- 	EZ Button Code added by Gayathri --->
	<cfif appSettings.getSearchSequenceOn() EQ 0 AND appsettings.app_EZButton_On EQ 1 and (generic_type EQ "Distributor Trade/Shelter" OR generic_type EQ "Operator-Deviated Pricing") >
	<CFIF fromSettings_management eq 1>
   			<cfset SettingsTemplateForm(NameField="EZButton_On",NameFieldDesc="EZ Button")>
  	<CFELSE>
		<tr class="componentrules" <cfif SettingsManagerTemplate.EZButton_On EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><strong>EZ Button</strong></td>
				<td>&nbsp; </td>
				<td>&nbsp; </td>
			<td align="left" valign="top">
			<input type="checkbox" name="EZButton_On" <cfif Form.EZButton_On IS 1>checked</cfif>  onclick="if(!this.checked){if (!confirm('Disabling the EZ Button function will remove all products and rates established for this template.  Are you sure you want to continue?')){return false;};}" value="1" #FormStatus# >
			</td>
		</tr>
  	</CFIF>
	</cfif>
	<cfif NOT(Generic_Type IS "Distributor Off-Invoice" OR Generic_Type IS "Brokerage") >
		<!---- Minimum lump sum--->
		<CFIF fromSettings_management eq 1>
   			<cfset SettingsTemplateForm(NameField="Min_Lump_Sum",NameFieldDesc="Minimum #Application.LumpsumLabel#")>
  		<CFELSE>
		<tr class="componentrules" <cfif SettingsManagerTemplate.Min_Lump_Sum EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><strong>Minimum #Application.LumpsumLabel#</strong></td>
				<td>&nbsp; </td>
				<td>&nbsp; </td>
			<td align="left" valign="top">
			<input type="text" name="Min_Lump_Sum" size="5" maxlength="10" <cfif Form.Min_Lump_Sum IS NOT 0> value="#Form.Min_Lump_Sum#"</cfif> onKeyUp="clenseText(this, '0123456789')"  #FormStatus# > Dollars
			</td>
		</tr>
		</CFIF>

		<!---- Maximum lump sum--->
		<CFIF fromSettings_management eq 1>
   			<cfset SettingsTemplateForm(NameField="Max_Lump_Sum",NameFieldDesc="Maximum #Application.LumpsumLabel#")>
  		<CFELSE>
		<tr class="componentrules" <cfif SettingsManagerTemplate.Max_Lump_Sum EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><strong>Maximum #Application.LumpsumLabel#</strong></td>
				<td>&nbsp;</td>
				<td>&nbsp; </td>
			<td align="left" valign="top">
			<input type="text" name="Max_Lump_Sum" size="5" maxlength="10" <cfif Form.Max_Lump_Sum IS NOT 0> value="#Form.Max_Lump_Sum#"</cfif> onKeyUp="clenseText(this, '0123456789')"  #FormStatus# > Dollars
			</td>
		</tr>
		</CFIF>
		<!---- Lump sum cap --->
		<cfif NOT(Generic_Type IS "LSAutoPay")>
		<CFIF fromSettings_management eq 1>
   			<cfset SettingsTemplateForm(NameField="Lump_Sum_Cap",NameFieldDesc="#Application.LumpsumLabel# cap")>
  		<CFELSE>
		<tr class="componentrules" <cfif SettingsManagerTemplate.Lump_Sum_Cap EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><strong>#Application.LumpsumLabel# cap</strong></td>
				<td>&nbsp;<span id="error_"></span></td>
				<td>&nbsp; </td>
			<td align="left" valign="top">
				<cfif trim(FormStatus) eq "disabled">
					<cfset smallLinkParams = "onClick=""javascript: return false;""" />
					<cfset smallLinkEnable = 0>
				<cfelse>
					<cfset smallLinkParams = "onClick=""javascript: getLumpSumCapAmount(); return false;""" />
					<cfset smallLinkEnable = 1>
				</cfif>
				<input type="text" name="Lump_Sum_Cap" size="5" maxlength="10" <cfif IsNumeric(Form.Lump_Sum_Cap) AND Form.Lump_Sum_Cap NEQ 0> value="#Form.Lump_Sum_Cap#"</cfif> onKeyUp="clenseText(this, '0123456789')" disabled="disabled"> Dollars
				<input name="Lump_Sum_Cap_Min" type="hidden" value="0" />
				<span id="lumpSumAmountSpan">
					<CF_smallLink
						title = "Get Min Amount"
						url = "##"
						parameters = "#smallLinkParams#"
						enabled="#smallLinkEnable#"
					>
				</span>
			<!--- <cfif lumpSumCapMin NEQ 0> <font color="red">(Min Amount: #DollarFormat(lumpSumCapMin)#)</font></cfif> --->
			</td>
		</tr>
		</CFIF>
		<Cfelse>
			<input name="Lump_Sum_Cap_Min" type="hidden" value="0" />
			<input name="Lump_Sum_Cap" type="hidden" value="0" />
		</cfif>
		<!---Not off invoice--->
	<cfelse>
		<input name="Lump_Sum_Cap_Min" type="hidden" value="0" />
		<input name="Lump_Sum_Cap" type="hidden" value="0" />
	</cfif>

	<cfif Generic_Type IS "Distributor Off-Invoice">
		<CFIF fromSettings_management eq 1>
   			<cfset SettingsTemplateForm(NameField="No_Negative_OI",NameFieldDesc="Only allow price decrease OI")>
  		<CFELSE>
		<tr class="componentrules" <cfif SettingsManagerTemplate.No_Negative_OI EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><strong>Only allow price decrease OI</strong></td>
				<td>&nbsp; </td>
				<td>&nbsp; </td>
			<td align="left" valign="top">
				<input type="checkbox" name="No_Negative_OI" <cfif Form.No_Negative_OI IS 1>checked</cfif> value="1"  #FormStatus# >&nbsp; &nbsp;
			</td>
		</tr>
		</CFIF>
	<cfelse>
		<CFIF fromSettings_management neq 1>
		<input type="hidden" name="Allow_Negative_OI" value="0">
		</CFIF>
	</cfif>
	<!--- Price Protection --- D25700 hide Price Protection --->
	<cfif Generic_Type IS  "Operator Direct or HQ Programs" or Generic_Type IS  "Operator-Deviated Pricing">
		<tr style="display:none">
			<td align="right" nowrap valign="top"><strong>Price Protection On</strong></td>
				<td>&nbsp; </td>
				<td>&nbsp; </td>
			<td align="left" valign="top">
			<input type="checkbox" name="price_protection_on" <cfif Form.price_protection_on IS 1>checked</cfif> value="1" #FormStatus# >
			</td>
		</tr>
	</cfif>
	<cfif NOT(Generic_Type IS "LSAutoPay")>
		<CFIF fromSettings_management eq 1>
   			<cfset SettingsTemplateForm(NameField="Use_Fixed_Price_As_Base_Sales",NameFieldDesc="Use Fixed Price as Base Sales")>
  		<CFELSE>
		<tr class="componentrules" <cfif SettingsManagerTemplate.Use_Fixed_Price_As_Base_Sales EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><font class="retroFieldsIndicator">*</font><strong>Use Fixed Price as Base Sales</strong>
			<CF_SmallHelp
				width="300"
				displayShifyX = "-200"
				imgPath="/Images/i.gif"
				imgWidth="12"
				imgHeight="11"
				dropdownCheck="0"
				>
			<div style="text-align: left;">
			The margin evaluation will replace the existing base sales value <br>with the program fixed price only if there is one.
			<br>Otherwise, the existing base sales scheme will be used.
			</div>
			</CF_SmallHelp>
			</td>
			<td>&nbsp; </td>
			<td>&nbsp; </td>
			<td align="left" valign="top">
			<input type="checkbox" name="Use_Fixed_Price_As_Base_Sales"  value="1" <cfif Form.Use_Fixed_Price_As_Base_Sales>CHECKED</cfif> #FormStatus# >
			</td>
		</tr>
		</CFIF>
	</cfif>

	<!--- 	Single component per discount type 28112--->
	<CFIF fromSettings_management eq 1>
   			<cfset SettingsTemplateForm(NameField="Single_Component_Per_Discount_Type",NameFieldDesc="Single Component per Discount Type")>
  	<CFELSE>
	<tr class="componentrules" <cfif SettingsManagerTemplate.Single_Component_Per_Discount_Type EQ 0> style="display:none"</cfif>>
		<td align="right" nowrap valign="top"><strong>Single Component per Discount Type</strong></td>
		<td>&nbsp; </td>
		<td>&nbsp; </td>
		<td align="left" valign="top">
			<input type="checkbox" name="Single_Component_Per_Discount_Type" <cfif Form.Single_Component_Per_Discount_Type IS 1>checked</cfif> value="1" #FormStatus# >
		</td>
	</tr>
	</CFIF>
	<!--- D28559: Warning / Prevent - Identical FIXED PRICE / REBATE / PAID TO --->
		<CFIF fromSettings_management eq 1>
   			<cfset SettingsTemplateForm(NameField="Item_Fixed_Rebate_Paid_To_Dup_Message",NameFieldDesc="Identify items having rebate and fixed price for same paid to")>
  	<CFELSE>
	<tr class="componentrules" <cfif SettingsManagerTemplate.Item_Fixed_Rebate_Paid_To_Dup_Message EQ 0> style="display:none"</cfif>>
		<td align="right" nowrap valign="top"><font class="retroFieldsIndicator">*</font><strong>Identify items having rebate and fixed price for same paid to</strong></td>
		<td>&nbsp; </td>
		<td>&nbsp; </td>
		<td align="left" valign="top">
			  	<input type="radio" name="Item_Fixed_Rebate_Paid_To_Dup_Message" value="0" checked #FormStatus# >Off
			<br><input type="radio" name="Item_Fixed_Rebate_Paid_To_Dup_Message" value="2" <cfif Form.Item_Fixed_Rebate_Paid_To_Dup_Message IS 2>checked</cfif> #FormStatus#>Warning
			<br><input type="radio" name="Item_Fixed_Rebate_Paid_To_Dup_Message" value="3" <cfif Form.Item_Fixed_Rebate_Paid_To_Dup_Message IS 3>checked</cfif> #FormStatus#>Prevent
		</td>
	</tr>
	</CFIF>
	<!--- 	Base Sales equal to lowest bracket 27180--->
	<cfif appSettings.getUseFixedPriceType() EQ 1>
  		<CFIF fromSettings_management eq 1>
   			<cfset SettingsTemplateForm(NameField="Base_Sales_Equal_To_Lowest_Bracket",NameFieldDesc="Base Sales Equal to Lowest Bracket")>
  		<CFELSE>
		<tr class="componentrules" <cfif SettingsManagerTemplate.Base_Sales_Equal_To_Lowest_Bracket EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><strong>Base Sales Equal to Lowest Bracket</strong></td>
			<td>&nbsp; </td>
			<td>&nbsp; </td>
			<td align="left" valign="top">
				<input type="checkbox" name="Base_Sales_Equal_To_Lowest_Bracket" <cfif Form.Base_Sales_Equal_To_Lowest_Bracket IS 1>checked</cfif> value="1" #FormStatus# >
			</td>
		</tr>
		</CFIF>
	</cfif>

	<!--- 28271 Template settings for Price List selection --->
	<cfif appSettings.getPriceListByTemplate() EQ 1>
		<cfquery name="GetPriceList" datasource="#application.datasource#">
               		select      price_list_header_id, Price_List_ID + '-' + Price_List_Description as Price_List_Diplay_Desc
			from        price_list_header
			where       deleted = 0
			order by    Price_List_Description
		</cfquery>
		<CFIF fromSettings_management eq 1>
   			<cfset SettingsTemplateForm(NameField="Margin_Price_List_Header_ID",NameFieldDesc="Margin Price List")>
  		<CFELSE>
		<tr class="componentrules" <cfif SettingsManagerTemplate.Margin_Price_List_Header_ID EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><font class="requiredFieldsIndicator">*</font><font class="retroFieldsIndicator">*</font><strong>Margin Price List</strong></td>
			<td>&nbsp;<span id="error_Margin_Price_List_Header_ID"></span></td>
			<td>&nbsp; </td>
			<TD align="left" valign="top">
				<SELECT NAME="Margin_Price_List_Header_ID" id="Margin_Price_List_Header_ID" #FormStatus# >
					<OPTION VALUE="0">**Select Price List**</OPTION>
					<cfloop query="GetPriceList">
						<OPTION VALUE="#GetPriceList.price_list_header_id#" <cfif form.Margin_Price_List_Header_ID eq GetPriceList.price_list_header_id>selected</cfif>>#GetPriceList.Price_List_Diplay_Desc#</OPTION>
					</cfloop>
				</SELECT>
			</TD>
		</tr>
		</CFIF>

		<!--- D29125: Base Sales for a program ::Starts here::: --->
		<CFIF fromSettings_management eq 1>
   				<cfset SettingsTemplateForm(NameField="Base_Sales_based_on_Prg_Start_Date",NameFieldDesc="Base Sales based on Prg Start Date")>
  		<CFELSE>
			<cfif SettingsManagerTemplate.Base_Sales_based_on_Prg_Start_Date EQ 0>
					<input type="hidden" name="Base_Sales_based_on_Prg_Start_Date" value="#Form.Base_Sales_based_on_Prg_Start_Date#" />
					<input type="hidden" name="Select_Effective_Date_for_Price" value="#Form.Select_Effective_Date_for_Price#" />
			<cfelse>
				<tr class="componentrules" <cfif SettingsManagerTemplate.Base_Sales_based_on_Prg_Start_Date EQ 0> style="display:none"</cfif>>
					<td align="right" nowrap valign="top"><strong>Base Sales based on Prg Start Date</strong></td>
					<td>&nbsp; </td>
					<td>&nbsp; </td>
					<td align="left" valign="top">
					<input type="checkbox" name="Base_Sales_based_on_Prg_Start_Date" <cfif Form.Base_Sales_based_on_Prg_Start_Date IS 1>checked</cfif> value="1" onclick="if(this.checked) {document.all.tr_Select_Effective_Date_for_Price.style.display=''} else  {document.all.tr_Select_Effective_Date_for_Price.style.display='none'}" #FormStatus# >
					</td>
				</tr>

				<tr <cfif Form.Base_Sales_based_on_Prg_Start_Date EQ 0> style="display:none"</cfif> id="tr_Select_Effective_Date_for_Price">
					<!--- <td colspan="100%" align="center">
					<table align="left" border="0" style="width:40%;margin-left:200px;<cfif SettingsManagerTemplate.Select_Effective_Date_for_Price EQ 0> display:none;</cfif>">
					<tr>
						<td align="left" valign="top" width="160"> --->
						<td align="right" nowrap valign="top">
							Select Effective Date for Price
							<CF_SmallHelp
								width = "260"
								displayShifyX = "-300"
								displayShifyY = "-80"
								imgPath="/Images/i.gif"
								imgWidth="12"
								imgHeight="11">
								<center style="text-align: justify;">
								Users will be able to manually type in an effective date<br> for price on the program's Basic Info page. On the margin<br> page, the base sales value for the item will be based<br> on the effective date entered. If the field Select<br> Effective Date for Price" is left blank, then the base <br>sales value will be based on the program's start date.
								</center>
								</CF_SmallHelp>

							<td>&nbsp; </td>
					<td>&nbsp; </td>
					<td align="left" valign="top">
							<input type="checkbox" name="Select_Effective_Date_for_Price" <cfif Form.Select_Effective_Date_for_Price IS 1>checked</cfif> value="1" #FormStatus# >
						<!--- </td>
					</tr>
					</table> --->
				</td>
				</tr>
 			</cfif>
		</CFIF>


		<!--- D29125: Base Sales for a program  :: ends here --->
	</cfif>

	<!---- Clear_Lumpsum 28115 --->
	<CFIF fromSettings_management eq 1>
   			<cfset SettingsTemplateForm(NameField="Clear_Lumpsum",NameFieldDesc="Days after expiration to clear open lump sums")>
  	<CFELSE>
	<tr class="componentrules" <cfif SettingsManagerTemplate.Clear_Lumpsum EQ 0> style="display:none"</cfif>>
		<td align="right" nowrap valign="top"><strong>Days after expiration to clear open lump sums</strong>
			<CF_SmallHelp
				width="400"
				displayShifyX = "-200"
				imgPath="/Images/i.gif"
				imgWidth="12"
				imgHeight="11"
				dropdownCheck="0"
				>
			<div style="text-align: left;">
			When the setting is turned ON, it will update the program's lump sum dollar amount <br>to be the actual dollar amount paid out via billbacks.
			<br>** Note:  If the budget module is turned ON, this will also update the program's lump sum <br>committed dollars based on the actual dollar amount paid out via billbacks. **
			</div>
			</CF_SmallHelp>
		</td>
		<td>&nbsp; </td>
		<td>&nbsp; </td>
		<td align="left" valign="top">
			<input type="text" name="Clear_Lumpsum" size="5" maxlength="3" <cfif Form.Clear_Lumpsum IS NOT 0> value="#Form.Clear_Lumpsum#"</cfif> onKeyUp="clenseText(this, '0123456789')"  #FormStatus# >
		</td>
	</tr>
	</CFIF>
	<cfif GENERIC_TYPE IS NOT "Brokerage" AND NOT(Generic_Type IS "LSAutoPay")>
			<!--- 	If anyone wants to add anything please add above this pullback section. --->
			<cfif appSettings.getPullbacksOn() EQ 1>
			<!--- XXXXXXXXXXXXXXXXXXXXXX   RECAPTURE RULES	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
				<tr id="recapturerules_heading"><Th colspan="100%" bgcolor="##93BEE2">Recapture Rules</TH></tr>
				<CFIF fromSettings_management eq 1>
   					<cfset SettingsTemplateForm(NameField="Pullbacks_On",NameFieldDesc="#appSettings.getPullbackLabel()# On")>
  				<CFELSE>
				<tr class="recapturerules" <cfif SettingsManagerTemplate.Pullbacks_On EQ 0> style="display:none"</cfif>>
					<td align="right" nowrap valign="top"><strong>#appSettings.getPullbackLabel()# On</strong></td>
					<td>&nbsp; </td>
					<td>&nbsp; </td>
					<td align="left" valign="top">
					<input type="checkbox" name="Pullbacks_On" <cfif Form.Pullbacks_On IS 1>checked</cfif> value="1" onclick="pullbackOnClick(this);" #FormStatus# >
					</td>
				</tr>
				</CFIF>
				<cfif pullback_template_type EQ 2>
					<CFIF fromSettings_management eq 1>
   						<cfset SettingsTemplateForm(NameField="Recapture_Pays_To_Id",NameFieldDesc="#appSettings.getPullbackLabel()# are created for this Pays To Only:")>
  					<CFELSE>
					<tr class="recapturerules" display:<cfif Form.Pullbacks_On IS 1><cfelse> none</cfif> >
						<td align="right" valign="top"><strong>#appSettings.getPullbackLabel()# are created for this Pays To Only: </strong></td>
						<td>&nbsp;<span id="err_Recapture_Pays_To_Id"></span></td>
						<td>&nbsp; </td>
						<td align="left" valign="top">
							<SELECT NAME="Recapture_Pays_To_Id" id="Recapture_Pays_To_Id" #FormStatus# >
					<OPTION VALUE="0">**Select Pays To**</OPTION>
						<OPTION VALUE="1" <cfif Form.Recapture_Pays_To_Id eq 1>selected</cfif>>Distributor</OPTION>
						<OPTION VALUE="2" <cfif Form.Recapture_Pays_To_Id eq 2>selected</cfif>>Operator</OPTION>
					</SELECT>
						</td>
					</tr>
					</CFIF>
				</cfif>
				<cfif pullback_template_type EQ 1>
					<CFIF fromSettings_management eq 1>
   						<cfset SettingsTemplateForm(NameField="is_pullback_corporate_deal",NameFieldDesc="Corporate Deal")>
  					<CFELSE>
					<cfif SettingsManagerTemplate.is_pullback_corporate_deal EQ 0>
						<input type="hidden" name="is_pullback_corporate_deal" value="#Form.is_pullback_corporate_deal#" />
					<cfelse>
					<tr id="is_pullback_corporate" style="display:<cfif Form.Pullbacks_On IS 1><cfelse> none</cfif>">
						<td align="right" nowrap valign="top"><strong>Corporate Deal</strong></td>
						<td>&nbsp; </td>
						<td>&nbsp; </td>
						<td align="left" valign="top">
						<input type="radio" name="is_pullback_corporate_deal" <cfif Form.is_pullback_corporate_deal IS 1>checked</cfif> value="1" onclick="is_pullback_corporate_deal_on_click(this);" #FormStatus# >Yes
						<input type="radio" name="is_pullback_corporate_deal" <cfif Form.is_pullback_corporate_deal IS 0>checked</cfif> value="0" onclick="is_pullback_corporate_deal_off_click(this);" #FormStatus# >No
						</td>
					</tr>
					</cfif>
					</CFIF>
					<CFIF fromSettings_management eq 1>
   						<cfset SettingsTemplateForm(NameField="pullback_from_corporate",NameFieldDesc="#appSettings.getPullbackLabel()# from Corporate")>
  					<CFELSE>
					<cfif SettingsManagerTemplate.pullback_from_corporate EQ 0>
						<input type="hidden" name="pullback_from_corporate" value="#Form.pullback_from_corporate#">
					<cfelse>
					<tr id="sp_pullback_from_corporate" style="display:<cfif Form.is_pullback_corporate_deal IS 0 and  form.Pullbacks_On is 1><cfelse> none</cfif>;">
						<td align="right" nowrap valign="top"><strong>#appSettings.getPullbackLabel()# from Corporate</strong></td>

						<td>&nbsp; </td>
						<td>&nbsp; </td>
						<td align="left" valign="top">
						<input type="radio" name="pullback_from_corporate" <cfif Form.pullback_from_corporate IS 1>checked</cfif> value="1" onclick="pullback_from_corporate_on_click(this);" #FormStatus# >Yes
						<input type="radio" name="pullback_from_corporate" <cfif Form.pullback_from_corporate IS 0>checked</cfif> value="0" onclick="pullback_from_corporate_off_click(this);" #FormStatus# >No
						</td>
					</tr>
					</cfif>
					</CFIF>
				</cfif>
				<!--- 	<tr id="sp_default_pullback_rate" style="display: <cfif (Form.is_pullback_corporate_deal IS 1 and Form.pullback_from_corporate IS 0 and  form.Pullbacks_On is 1) OR (pullback_template_type EQ 2 and  form.Pullbacks_On is 1)><cfelse>none</cfif>;">
					<td align="right" nowrap valign="top"><strong>Default #appSettings.getPullbackLabelLower()# Rate</strong></td>
						<td>&nbsp; </td>
						<td>&nbsp; </td>
					<td align="left" valign="top">
					<input type="textbox" name="default_pullback_rate" size="5" maxsize="4" value="#Form.default_pullback_rate#" onKeyUp="clenseText(this, '0123456789')" style="backgroundColor:red" <cfif Form.Pullbacks_On IS 0>disabled</cfif> #FormStatus# >%
					</td>
				</tr>	 --->
				<cfif pullback_template_type EQ 1>
					<CFIF fromSettings_management eq 1>
   						<cfset SettingsTemplateForm(NameField="Pullback_Include_RediVolume",NameFieldDesc="Include Redi Volume in Distributor Trade payments")>
  					<CFELSE>
					<tr class="recapturerules" <cfif SettingsManagerTemplate.Pullback_Include_RediVolume EQ 0> style="display:none"</cfif>>
						<td align="right" valign="top"><strong>Include Redi Volume in Distributor Trade payments </strong></td>
						<td>&nbsp; </td>
						<td>&nbsp; </td>
						<td align="left" valign="top">
						<input type="checkbox" name="Pullback_Include_RediVolume" <cfif Form.Pullback_Include_RediVolume IS 1>checked</cfif> value="1" onpropertychange="changeDisableOtherObjects(this, this.form.Pullback_redi_volume_percent);" #FormStatus# >
						</td>
					</tr>
					</CFIF>
					<CFIF fromSettings_management eq 1>
   						<cfset SettingsTemplateForm(NameField="Pullback_redi_volume_percent",NameFieldDesc="What percent of gross price should be used when calculating earnings for redi volume?")>
  					<CFELSE>
					<tr class="recapturerules" <cfif SettingsManagerTemplate.Pullback_redi_volume_percent EQ 0> style="display:none"</cfif>>
						<td align="right" valign="top"><strong>What percent of gross price should be used when calculating earnings for redi volume? </strong></td>
						<td>&nbsp; </td>
						<td>&nbsp; </td>
						<td align="left" valign="top">
							<input type="textbox" name="Pullback_redi_volume_percent" size="5" maxsize="4" value="#Form.Pullback_redi_volume_percent#" onKeyUp="clenseText(this, '0123456789')" style="backgroundColor:red" <cfif Form.Pullback_Include_RediVolume IS 0>disabled</cfif> #FormStatus# >%
						</td>
					</tr>
					</CFIF>
				</cfif>
			</cfif>
		</cfif>
<CFIF fromSettings_management neq 1>
	</table>
</td>
<!---End left side--->

<!---End center--->
<!---Right side--->
<td width="50%" valign="top">
	<table width="100%" align="center" cellspacing="1" cellpadding="0" border="0">
</CFIF>
	<!---<tr><Th colspan="100%" bgcolor="##93BEE2">Options</TH></tr>--->

<cfset onClickFnForGroups = "" />
<!--- <cfif appSettings.getSearchSequenceOn()>
	<cfset Form.Group_Deal = 1 />
	<cfset Form.Dynamic_Static_Groups = 1 />
	<cfset Form.Specify_Distributor_Groups = 1 />
	<cfset onClickFnForGroups = " onClick=""javaScript:return false;""" />
</cfif> --->

	<!--- XXXXXXXXXXXXXXXXXXXXXX   PRODUCT AND CUSTOMER RULES	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<tr id="productAndCustomerRules_heading"><Th colspan="100%" bgcolor="##93BEE2">Product and Customer Rules</TH></tr>
	<cfif NOT(Generic_Type IS "LSAutoPay")>
		<!---FILTER: Group Deal--->
		<cfif isDefined("application.returned_customer_setting.group_deals") and application.returned_customer_setting.group_deals eq 1>

			<!---display groups if it's defined in the control panel options table--->
			<cfif isDefined("qCheckOptions.Group_Deal")>
				<CFIF fromSettings_management eq 1>
   						<cfset SettingsTemplateForm(NameField="Group_Deal",NameFieldDesc="Select Products by Groups")>
  				<CFELSE>
				<tr class="productAndCustomerRules" <cfif SettingsManagerTemplate.Group_Deal EQ 0> style="display:none"</cfif>>
					<td align="right" nowrap valign="top"><strong>Select Products by Groups</strong></td>
					<td>&nbsp;</td>
					<td>&nbsp; </td>
					<td align="left" valign="top">
						<cfif application.appSettingsGet.getTemplateMultipleProductAttrGroups() EQ 1 AND (isDefined("Template.Active") AND Template.Active EQ 1) >
				   	   			<input type="checkbox" name="Group_Deal_Disabled" <cfif Form.Group_Deal IS 1>checked</cfif> value="1"  disabled title="The Template is active so Product Group selections can not be modified." >
						 		<input type="hidden"  name="Group_Deal" value="#Form.Group_Deal#"/>
						 <cfelse>
					  			<input type="checkbox" name="Group_Deal" <cfif Form.Group_Deal IS 1>checked</cfif> value="1"  #FormStatus# >
						  </cfif>

					</td>
				</tr>
				</CFIF>
			</cfif>

			<!--- Removed with label 19409, set DEFAULT TO OFF
			<!----Dynamic Groups--->
			<!---display  groups if it's defined in the control panel options table--->
			<cfif isDefined("qCheckOptions.Dynamic_Static_Groups")>
				<tr>
					<td align="right" nowrap valign="top">
						<strong>Dynamic Groups</strong><br>
						(only applies to groups)
					</td>
					<td>&nbsp;</td>
					<td>&nbsp; </td>
					<td align="left" valign="top">
						<input name="Dynamic_Static_Groups" type="checkbox" value="1" <cfif Form.Dynamic_Static_Groups IS 1>checked</cfif> <cfif Form.Group_Deal neq 1>disabled="true"</cfif> #onClickFnForGroups# #FormStatus# >
					</td>
				</tr>
			</cfif>
			--->
			<!------ DEV NOTE: 9595 DRK : restrict group level - START ----->
			<!--- ************************************************************************************
					START: THE BELOW PART IS REMOVED AS THIS SAME FUNCTIONALITY HAS BEEN MOVED INTO THE FILTERS
					COMMENTED BY: ANAND RAO
					DATE: 16-FEB-2011

			************************************************************************************ --->
			<!--- <cfif appSettings.getSearchSequenceOn() EQ 0>
			<tr <cfif SettingsManagerTemplate.Restrict_Product_Group_Level EQ 0> style="display:none"</cfif>>
				<td align="right" nowrap valign="top">
					<font class="retroFieldsIndicator">*</font><B>Restrict group level</B>
				</td>
				<td>&nbsp;<span id="err_Restrict_Product_Group_Level"></span> </td>
				<td>&nbsp; </td>
				<td align="left" valign="top">
					<input onclick="javaScript:showHideObject(this, document.all.tr_Allow_Product_Group_Level);showHideObject(this, document.all.tr_Allow_Lower_Pricing_Level);" type="checkbox" name="Restrict_Product_Group_Level" <cfif Form.Restrict_Product_Group_Level IS 1>checked</cfif> value="1" #FormStatus# >
				</td>
			</tr>
			<!------ Get the hroup level data ----->
			<cfset GroupDataManager = CreateObject("component", "components.products.Group.DataManager") />
			<cfset qGetGroupLevels = GroupDataManager.getProductGroupsData() />
			<!------ Get pricing level descriptions ----->
			<cfset qGetPricingLevel = GroupDataManager.getPricingLevel() />
			<cfset arPricingLevel = ListToArray(ValueList(qGetPricingLevel.Pricing_Level_Desc, ","), ",") />

			<cfif SettingsManagerTemplate.Allow_Lower_Pricing_Level EQ 0>
					<input type="hidden" name="Allow_Lower_Pricing_Level" value="#Form.Allow_Lower_Pricing_Level#">
			<cfelse>
			<tr id="tr_Allow_Lower_Pricing_Level" <cfif Form.Restrict_Product_Group_Level NEQ 1> style="display:none"</cfif>>
				<td align="right" nowrap valign="top">
					<font class="retroFieldsIndicator">*</font><B>#arPricingLevel[2]# / #arPricingLevel[3]# allowed</B>
				</td>
				<td>&nbsp;</td>
				<td>&nbsp; </td>
				<td align="left" valign="top">
					<input type="checkbox" name="Allow_Lower_Pricing_Level" <cfif Form.Allow_Lower_Pricing_Level IS 1>checked</cfif> value="1" #FormStatus# >
				</td>
			</tr>
			</cfif>
			<cfif SettingsManagerTemplate.Allow_Product_Group_Level NEQ 0>
			<tr id="tr_Allow_Product_Group_Level" <cfif Form.Restrict_Product_Group_Level NEQ 1> style="display:none"</cfif>>
				<td align="left" valign="top" colspan="4" style="border-top:1px solid navy;border-bottom:1px solid navy;">
					<font class="retroFieldsIndicator">*</font><B>Allow group levels</B><br>
					<cfset iMaxCols = 2>
					<table cellpadding="0" cellspacing="1" border="0" width="100%"><tr>
						<cfloop query="qGetGroupLevels">
						<cfset currentValueSelected = 0 />
							<cfif ListFindNoCase(Form.Allow_Product_Group_Level, Product_Group_Level_ID)><cfset currentValueSelected = 1 /></cfif>
							<td bgcolor="eeeeee"><input type="checkbox" name="Allow_Product_Group_Level" value="#Product_Group_Level_ID#" <cfif currentValueSelected>checked</cfif> #FormStatus# />#Group_Level_Desc#</td>
							<cfif NOT (currentRow mod iMaxCols)></tr><tr></tr></cfif>
						</cfloop>
					</table>
				</td>
			</tr>
			</cfif>
		</cfif> --->

		<!------ DEV NOTE: 9595 DRK : restrict group level - END ----->
	</cfif>
	<!--- <cfif NOT(Generic_Type IS "LSAutoPay")>
		<!------ template product group restriction ----->
		<tr class="productAndCustomerRules" <cfif SettingsManagerTemplate.Restrict_On_Approval_Group EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top">
				<font class="retroFieldsIndicator">*</font><B>Restrict on #approvalGroupType.label#</B>
			</td>
			<td>&nbsp;<span id="err_Restrict_On_Approval_Group"></span> </td>
			<td>&nbsp; </td>
			<td align="left" valign="top">
				<input onclick="javaScript:showHideRestrictOnApproalGroup(this)" type="checkbox" name="Restrict_On_Approval_Group" <cfif Form.Restrict_On_Approval_Group IS 1>checked</cfif> value="1" #FormStatus# >
			</td>
		</tr>

		<cfif SettingsManagerTemplate.Allow_Approval_group EQ 0>
			<input type="Hidden" name="Allow_Approval_group" value="#Form.Allow_Approval_group#">
		<cfelse>
		<tr id="tr_Restrict_on_approal_Group" <cfif Form.Restrict_On_Approval_Group NEQ 1> style="display:none"</cfif>>
			<td align="right" nowrap valign="top">
				<font class="retroFieldsIndicator">*</font><B>Allow #approvalGroupType.label#</B><br>
				<!------
				>>>>>>>>
				Deamweaver editor users, make sure the following line is never changed automatically....
				<<<<<<<
				----->
				<cfset extraParameter = " onClick=""javascript: return showSearchWindow('/Search_Screens/ApprovalGroup_Search.cfm', 'Allow_Approval_group');""" />
		 		<CF_smallLink
					title = "select"
					url = "##"
					parameters = "#extraParameter#"
					>
			</td>
			<td>&nbsp;</td>
			<td>&nbsp; </td>
			<td align="left" valign="top">
				<cfif Len(Form.Allow_Approval_group) GT 0>
					<cfset qGetApprovalGroups = approvalGroupManager.getApprovalGroups(Form.Allow_Approval_group)>
					<cfset maxCols = 3>
					<table cellpadding="2" cellspacing="2" width="100%"><tr>
					<cfloop query="qGetApprovalGroups">
					<td bgcolor="eeeeee">#Group_Name #</td>
					<cfif not currentRow mod maxCols and currentRow neq recordCount></tr><tr></tr></cfif>
					</cfloop>
					</table>
				<cfelse>&nbsp;&nbsp;None
				</cfif>
				<input type="Hidden" name="Allow_Approval_group" value="#Form.Allow_Approval_group#">
			</td>
		</tr>
		</cfif>
		<!--- BJF: D11212 Distributor Product Integrity --->
		<cfif appsettings.getDistributor_Product_Integrity_On() IS 1>
		<tr class="productAndCustomerRules" <cfif SettingsManagerTemplate.Distributor_Product_Integrity_Rule_ID EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><strong>#application.returned_customer_setting.distributor_label_singular#/Product Integrity Rule</strong><br>(Optional)</td>
			<td>&nbsp;</td>
			<td>&nbsp; </td>
			<TD align="left" valign="top">

			<cfset useLakebaseForGetRules = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("distributor_product_integrity_rule")>
<cfif useLakebaseForGetRules>
	<cftry>
		<cfset GetRules = application.oLakebase.toQuery(
			application.oLakebase.selectRows("distributor_product_integrity_rule", {
				"deleted" = "eq.0",
				"order" = "rule_name.asc",
				"select" = "distributor_product_integrity_rule_id,rule_name"
			}), "distributor_product_integrity_rule_id,rule_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetRules = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetRules>
<cfquery name="GetRules" datasource="#application.datasource#">
				SELECT Distributor_Product_Integrity_Rule_ID, Rule_Name
				FROM Distributor_Product_Integrity_Rule
				WHERE Deleted = 0
				ORDER BY Rule_Name
			</cfquery>
</cfif>

			<select name="Distributor_Product_Integrity_Rule_ID" #FormStatus# >
				<option value="" <cfif len(trim(form.Distributor_Product_Integrity_Rule_ID)) IS 0>selected</cfif>>None</option>
			<cfloop query="GetRules">
				<option value="#GetRules.Distributor_Product_Integrity_Rule_ID#" <cfif GetRules.Distributor_Product_Integrity_Rule_ID EQ Form.Distributor_Product_Integrity_Rule_ID>selected</cfif>>#left(GetRules.Rule_Name, 50)#
			</cfloop>
			</select>
			</TD>
		</tr>
		</cfif>
	<cfelse>
		<input type="hidden" name="Restrict_On_Approval_Group" value="0">
	</cfif> --->
	<!--- 	LSAUTOPAY end --->
		<input type="hidden" name="Restrict_On_Approval_Group" value="0">
<!--- ************************************************************************************
END: THE BELOW PART IS REMOVED AS THIS SAME FUNCTIONALITY HAS BEEN MOVED INTO THE FILTERS
************************************************************************************ --->
	<!--- Exclude signature products--->
	<cfif NOT(Generic_Type IS "LSAutoPay")>
		<CFIF fromSettings_management eq 1>
   			<cfset SettingsTemplateForm(NameField="exclude_sig_products",NameFieldDesc="Exclude signature products")>
  		<CFELSE>
		<tr class="productAndCustomerRules" <cfif SettingsManagerTemplate.exclude_sig_products EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><strong>Exclude signature products</strong></td>
			<td>&nbsp; </td>
			<td>&nbsp; </td>
			<td align="left" valign="top">
			<input type="checkbox" name="exclude_sig_products" <cfif Form.exclude_sig_products IS 1>checked</cfif> value="1" #FormStatus# >
			</td>
		</tr>
		</CFIF>
	</cfif>
	<!---FILTER: Group Deal--->
	<cfif isDefined("application.returned_customer_setting.group_deals") and application.returned_customer_setting.group_deals eq 1>

		<!----DISTRIBUTOR GROUPS--->
		<!---display distributor groups if it's defined in the control panel options table--->
		<cfif isDefined("qCheckOptions.Specify_Distributor_Groups")>
			<CFIF fromSettings_management eq 1>
   				<cfset SettingsTemplateForm(NameField="Specify_Distributor_Groups",NameFieldDesc="Select #application.returned_customer_setting.distributor_label_plural# by Groups")>
  			<CFELSE>
				<tr class="productAndCustomerRules" <cfif SettingsManagerTemplate.Specify_Distributor_Groups EQ 0> style="display:none"</cfif>>
					<td align="right" nowrap valign="top">
							<strong>Select #application.returned_customer_setting.distributor_label_plural# by Groups</strong>
					</td>

					<td>&nbsp; </td>
					<td>&nbsp; </td>
					<td align="left" valign="top">
						<input type="checkbox" name="Specify_Distributor_Groups" <cfif Form.Specify_Distributor_Groups IS 1>checked</cfif> value="1" #onClickFnForGroups# #FormStatus# >
					</td>
				</tr>
			</CFIF>
		</cfif>
	</cfif>
	<!--- end product and customer rules --->
	<!--- D31561: Operator Groups Search START--->
		<CFIF fromSettings_management eq 1>
   				<cfset SettingsTemplateForm(NameField="Specify_Operator_Groups",NameFieldDesc="Select Operator by Groups")>
  		<CFELSE>
		<tr class="productAndCustomerRules" <cfif SettingsManagerTemplate.Specify_Operator_Groups EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><strong>Select Operator by Groups</strong></td>
			<td>&nbsp;</td>
			<td>&nbsp; </td>
			<td align="left" valign="top">
				<input type="checkbox" name="Specify_Operator_Groups" <cfif Form.Specify_Operator_Groups IS 1>checked</cfif> value="1"  #FormStatus# >
			</td>
		</tr>
		</CFIF>
	<!--- D31561: Operator Groups Search END--->
			<!---
			<!------ Allow Add All Products ----->
			<tr>
				<td align="right" nowrap valign="top"><strong>Allow Add All Products</strong></td>
					<td>&nbsp; </td>
					<td>&nbsp; </td>
					<td align="left" valign="top">
					<input type="checkbox" name="Allow_Add_All_Products" <cfif Form.Allow_Add_All_Products IS 1>checked</cfif> value="1" #FormStatus# >
					</td>
			</tr>
		 --->
</cfif><!--- 	LSAUTOPAY end --->

	<!--- XXXXXXXXXXXXXXXXXXXXXX   Status Rules	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<tr id="statusrules_heading"><Th colspan="100%" bgcolor="##93BEE2">Status Rules</TH></tr>

	<!---TSF: Label 10245 - Added checkbox for the require margin evaluateion template setting --->
	<cfif NOT(Generic_Type IS "LSAutoPay")>
		<CFIF fromSettings_management eq 1>
   			<cfset SettingsTemplateForm(NameField="ByPass_Margin_Evaluation",NameFieldDesc="Does not require margin evaluation")>
  		<CFELSE>
		<tr class="statusrules" <cfif SettingsManagerTemplate.ByPass_Margin_Evaluation EQ 0> style="display:none"</cfif>>
			<td align="right" valign="top"><strong>Does not require margin evaluation</strong></td>
			<td>&nbsp; </td>
			<td>&nbsp; </td>
			<td align="left" valign="top">
				<input name="ByPass_Margin_Evaluation" type="checkbox" value="1"  onClick="javascript:handleOptions(this.checked,'optMarginEval');"
						<cfif form.ByPass_Margin_Evaluation OR Generic_Type IS "Brokerage">checked</cfif>
						<cfif Generic_Type IS "Brokerage">disabled</cfif>
						#FormStatus# />
			</td>
		</tr>
    	<tr class="statusrules" <cfif SettingsManagerTemplate.ByPass_Margin_Evaluation EQ 0> style="display:none"</cfif>>
		  	<td colspan="4" align="right"><DIV align="left" style="width:250px;" id="optMarginEval" class="<cfif form.ByPass_Margin_Evaluation OR Generic_Type IS 'Brokerage'>showOptions<cfelse>hideOptions</cfif>">
				&nbsp; &nbsp; &nbsp; &nbsp;   <input type="radio" name="ByPass_Margin_Evaluation_Options"  value="1"	<cfif FORM.ByPass_Margin_Evaluation_Options EQ 1>checked</cfif> #FormStatus# />
				  All Programs <BR>
				&nbsp; &nbsp; &nbsp; &nbsp;   <input type="radio" name="ByPass_Margin_Evaluation_Options"  value="2" <cfif FORM.ByPass_Margin_Evaluation_Options EQ 2>checked</cfif> #FormStatus# />
				  Programs With Lump Sum </DIV>
			</td>
		</tr>
		</CFIF>
	<cfelse>
		<CFIF fromSettings_management neq 1>
		<input name="ByPass_Margin_Evaluation" type="hidden" value="1" />
    <input name="ByPass_Margin_Evaluation_Options" type="hidden" value="1" />
		</CFIF>
	</cfif>

	<cfif appSettings.getShow_Fixed_Freight() AND NOT(Generic_Type IS "LSAutoPay")>
		<CFIF fromSettings_management eq 1>
   				<cfset SettingsTemplateForm(NameField="Freight_Approval_Reqd",NameFieldDesc="Freight Approval Required")>
  		<CFELSE>
		<tr class="statusrules" <cfif SettingsManagerTemplate.Freight_Approval_Reqd EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><strong>Freight Approval Required</strong></td>
			<td>&nbsp; </td>
			<td>&nbsp; </td>
			<td align="left" valign="top">
			<input type="checkbox" name="Freight_Approval_Reqd"  value="1" <cfif Form.Freight_Approval_Reqd>CHECKED</cfif> #FormStatus# >
			</td>
		</tr>
		</CFIF>
		<CFIF fromSettings_management eq 1>
   				<cfset SettingsTemplateForm(NameField="Freight_accrual_considers_cash_discount",NameFieldDesc="Freight accrual considers cash discount")>
  		<CFELSE>
		<tr class="statusrules" <cfif SettingsManagerTemplate.Freight_accrual_considers_cash_discount EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><font class="retroFieldsIndicator">*</font><strong>Freight accrual considers cash discount</strong></td>
			<td>&nbsp; </td>
			<td>&nbsp; </td>
			<td align="left" valign="top">
			<input type="checkbox" name="Freight_accrual_considers_cash_discount"  value="1" <cfif Form.Freight_accrual_considers_cash_discount>CHECKED</cfif> #FormStatus# >
			</td>
		</tr>
		</CFIF>
	</cfif>

	<cfif Generic_Type IS NOT "Brokerage" AND NOT(Generic_Type IS "LSAutoPay") >
	<!------ Include in Catalog ----->
		<CFIF fromSettings_management eq 1>
   				<cfset SettingsTemplateForm(NameField="Catalog_Type",NameFieldDesc="Include in Catalog")>
  		<CFELSE>
		<tr class="statusrules" <cfif SettingsManagerTemplate.Catalog_Type EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><font class="retroFieldsIndicator">*</font><strong>Include in Catalog</strong></td>
			<td>&nbsp; </td>
			<td>&nbsp; </td>
			<td align="left" valign="top">
				<input onpropertychange="changeDisableOtherObjects(this, this.form.Catalog_Type);changeDisableOtherObjects(this, this.form.Show_Awarded_In_Catalog);" type="checkbox" name="Include_In_Catalog" <cfif Form.Include_In_Catalog IS 1>checked</cfif> value="1" #FormStatus# >
				<!------ summary ----->
				<br><input type="radio" name="Catalog_Type" value="1" <cfif Form.Include_In_Catalog EQ 0 OR len(trim(Form.Include_In_Catalog)) EQ 0>disabled</cfif> <cfif Form.Catalog_Type NEQ 2>checked</cfif> #FormStatus# >Summary
				<!------ detail ----->
				<br><input type="radio" name="Catalog_Type" value="2" <cfif Form.Include_In_Catalog EQ 0 OR len(trim(Form.Include_In_Catalog)) EQ 0>disabled</cfif> <cfif Form.Catalog_Type EQ 2>checked</cfif> #FormStatus# >Detail
			</td>
		</tr>
		</CFIF>
		<CFIF fromSettings_management eq 1>
   				<cfset SettingsTemplateForm(NameField="Show_Awarded_In_Catalog",NameFieldDesc="Include awarded in Catalog")>
  		<CFELSE>
		<tr class="statusrules" <cfif SettingsManagerTemplate.Show_Awarded_In_Catalog EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><strong>Include awarded in Catalog</strong></td>
			<td>&nbsp; </td>
			<td>&nbsp; </td>
			<td align="left" valign="top">
				<input type="checkbox" name="Show_Awarded_In_Catalog" <cfif Form.Include_In_Catalog EQ 0 OR len(trim(Form.Include_In_Catalog)) EQ 0>disabled</cfif> <cfif Form.Show_Awarded_In_Catalog IS 1>checked</cfif> value="1" #FormStatus# ></td>
		</tr>
		</CFIF>
	</cfif>
	<cfif Generic_Type IS NOT 'Brokerage' AND NOT(Generic_Type IS "LSAutoPay")>
		<!------ D8399: Post-Approval Status ----->
		<cfif appSettings.getPgmPostApprovalStatus() EQ 1>
			<cfset ProgramPostApprovalStatusManager = CreateObject("component", "components.programs.ProgramPostApprovalStatusManager").init() />
			<cfset qGetTemplateProgramPostApprovalStatus = ProgramPostApprovalStatusManager.getTemplateProgramPostApprovalStatus(templateId=ID) />
			<CFIF fromSettings_management eq 1>
				<cfset sTemplateProgramPostApprovalStatus ="">
				<cfloop query="qGetTemplateProgramPostApprovalStatus">
					<cfset sTemplateProgramPostApprovalStatus = "#sTemplateProgramPostApprovalStatus# in #Program_Post_Approval_Status_Desc#<br>">
				</cfloop>
   				<cfset SettingsTemplateForm(NameField="TemplateProgramPostApprovalStatus",NameFieldDesc="#sTemplateProgramPostApprovalStatus#")>
  			<CFELSE>
			<cfloop query="qGetTemplateProgramPostApprovalStatus">
				<cfparam name="Form.TemplateProgramPostApprovalStatus_#Program_Post_Approval_Status_ID#" 	default="#Template_Selected_ID#">
				<cfset currentFormVar_TemplateProgramPostApprovalStatus = Evaluate("Form.TemplateProgramPostApprovalStatus_#Program_Post_Approval_Status_ID#") />
				<tr class="statusrules" <cfif SettingsManagerTemplate.TemplateProgramPostApprovalStatus EQ 0> style="display:none"</cfif>>
					<td align="right" nowrap valign="top"><strong>Include in #Program_Post_Approval_Status_Desc#</strong></td>
					<td>&nbsp; </td>
					<td>&nbsp; </td>
					<td align="left" valign="top">
					<input type="checkbox" name="TemplateProgramPostApprovalStatus_#Program_Post_Approval_Status_ID#" <cfif currentFormVar_TemplateProgramPostApprovalStatus EQ Program_Post_Approval_Status_ID>checked</cfif> value="#Program_Post_Approval_Status_ID#" #FormStatus# >
					</td>
				</tr>
			</cfloop>
			</CFIF>
		</cfif>
	</cfif>
	<cfif Generic_Type IS NOT 'Brokerage' AND NOT(Generic_Type IS "LSAutoPay")>
		<CFIF fromSettings_management eq 1>
   				<cfset SettingsTemplateForm(NameField="BidRequestStatusOn",NameFieldDesc="Proposal Status On")>
  		<CFELSE>
			<tr class="statusrules" <cfif SettingsManagerTemplate.BidRequestStatusOn EQ 0> style="display:none"</cfif>>
				<td align="right" valign="top"><strong>Proposal Status On </strong></td>
				<td>&nbsp; </td>
				<td>&nbsp; </td>
				<td align="left" valign="top">
				<input type="checkbox" name="BidRequestStatusOn" <cfif Form.BidRequestStatusOn IS 1>checked</cfif> value="1"  onclick="if(document.all.BidRequestStatusOn.checked) {document.all.BidRequestStatusChangePgmStatus.disabled=false;document.all.approvalInterface.className='showOptions';document.all.Track_PriceInterface.className='showOptions';if( getRadioVal(Auto_Volume) > 0){document.all.ItemMarkedLostProgramVolumeAutomation.className='showOptions';}	document.all.ItemMarkedLostBudgetCommittedDollars.className='showOptions' } else  {document.all.ItemMarked_Lost_Budget_Committed_Dollars.checked=false;document.all.ItemMarked_Lost_Program_Volume_Automation.checked=false;document.all.BidRequestStatusChangePgmStatus.checked=false;document.all.BidRequestStatusChangePgmStatus.disabled=true;document.all.approvalInterface.className='hideOptions';document.all.Track_PriceInterface.className='hideOptions';document.all.ItemMarkedLostProgramVolumeAutomation.className ='hideOptions';document.all.ItemMarkedLostBudgetCommittedDollars.className='hideOptions';}" #FormStatus# >
				</td>
			</tr>
		</CFIF>
		<CFIF fromSettings_management eq 1>
   				<cfset SettingsTemplateForm(NameField="ItemMarked_Lost_Budget_Committed_Dollars",NameFieldDesc="Include items marked as lost in Budget Committed Dollars")>
  		<CFELSE>
			<cfif appSettings.getBudgetsFunctionalityOn() eq 1>
			<tr id="ItemMarkedLostBudgetCommittedDollars"  <cfif SettingsManagerTemplate.ItemMarked_Lost_Budget_Committed_Dollars EQ 0> style="display:none" <cfelse> class="<cfif form.BidRequestStatusOn EQ 1>showOptions<cfelse>hideOptions</cfif>" </cfif>>
				<td align="right" valign="top"><strong>Include items marked as lost in Budget Committed Dollars </strong></td>
				<td>&nbsp; </td>
				<td>&nbsp; </td>
				<td align="left" valign="top">
				<input type="checkbox" name="ItemMarked_Lost_Budget_Committed_Dollars" <cfif Form.ItemMarked_Lost_Budget_Committed_Dollars IS 1>checked</cfif> value="1" #FormStatus# >
				</td>
			</tr>
			<cfelse>
				<span id ="ItemMarkedLostBudgetCommittedDollars"></span>
				<input type="hidden" name="ItemMarked_Lost_Budget_Committed_Dollars" value="#Form.ItemMarked_Lost_Budget_Committed_Dollars#">
			</cfif>
		</CFIF>
		<CFIF fromSettings_management eq 1>
   				<cfset SettingsTemplateForm(NameField="ItemMarked_Lost_Program_Volume_Automation",NameFieldDesc="Include items marked as lost in Program Volume Automation")>
  		<CFELSE>
			<tr id="ItemMarkedLostProgramVolumeAutomation"  <cfif SettingsManagerTemplate.ItemMarked_Lost_Program_Volume_Automation EQ 0> style="display:none" <cfelse> class="<cfif form.BidRequestStatusOn EQ 1 AND form.Auto_Volume GT 0>showOptions<cfelse>hideOptions</cfif>" </cfif>>
				<td align="right" valign="top" nowrap><strong>Include items marked as lost in Program Volume Automation </strong></td>
				<td>&nbsp; </td>
				<td>&nbsp; </td>
				<td align="left" valign="top">
				<input type="checkbox" name="ItemMarked_Lost_Program_Volume_Automation" <cfif Form.ItemMarked_Lost_Program_Volume_Automation IS 1>checked</cfif> value="1"  #FormStatus# >
				</td>
			</tr>
		</CFIF>
		<CFIF fromSettings_management eq 1>
   				<cfset SettingsTemplateForm(NameField="BidRequestStatusChangePgmStatus",NameFieldDesc="Proposal Status Affects Program Status")>
  		<CFELSE>
			<tr class="statusrules" <cfif SettingsManagerTemplate.BidRequestStatusChangePgmStatus EQ 0> style="display:none"</cfif>>
				<td align="right" valign="top"><strong>Proposal Status Affects Program Status </strong></td>
				<td>&nbsp; </td>
				<td>&nbsp; </td>
				<td align="left" valign="top">
				<input type="checkbox" name="BidRequestStatusChangePgmStatus"
					<cfif Form.BidRequestStatusOn EQ 1>
						<cfif Form.BidRequestStatusChangePgmStatus IS 1>checked</cfif>
					<cfelse>
						Disabled="true"
					</cfif>
					value="1" #FormStatus# >
				</td>
			</tr>
		</CFIF>
		<CFIF fromSettings_management neq 1>
			<cfif SettingsManagerTemplate.BidRequestStatusOn EQ 0>
				<input type="hidden" name="Interface_On_Approval" value="#Form.Interface_On_Approval#">
			<cfelse>
			<tr id="approvalInterface" class="<cfif form.BidRequestStatusOn EQ 1>showOptions<cfelse>hideOptions</cfif>">
				<td align="left" valign="top" colspan="4">
				<input type="radio" name="Interface_On_Approval" <cfif Form.Interface_On_Approval IS 1>checked</cfif> value="1"  #FormStatus# /><strong>Interface on Program Approval</strong><br />
				<input type="radio" name="Interface_On_Approval" <cfif Form.Interface_On_Approval IS 0>checked</cfif> value="0" #FormStatus# /><strong>Interface on "won" status</strong>
			   </td>
			</tr>
			</cfif>
		</CFIF>
		</cfif> <!--- from 1975 Generic_Type IS NOT 'Brokerage' AND NOT(Generic_Type IS "LSAutoPay") --->
		<CFIF fromSettings_management eq 1>
   				<cfset SettingsTemplateForm(NameField="Send_RFA_Email",NameFieldDesc="Send Email On RFA")>
  		<CFELSE>
		<tr class="statusrules" <cfif SettingsManagerTemplate.Send_RFA_Email EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><strong>Send Email On RFA</strong></td>
			<td>&nbsp; </td>
			<td>&nbsp; </td>
			<td align="left" valign="top">
				<input type="checkbox" name="Send_RFA_Email"  value="1" <cfif Form.Send_RFA_Email>CHECKED</cfif> #FormStatus# >
			</td>
		</tr>
		</CFIF>
	<!--- XXXXXXXXXXXXXXXXXXXXXX   Competitive Information	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<tr id="competitive_heading"><Th colspan="100%" bgcolor="##93BEE2">Competitive Information</TH></tr>
	<cfif Generic_Type IS 'Direct Pricing'>
		<CFIF fromSettings_management eq 1>
   				<cfset SettingsTemplateForm(NameField="Competitive_Information_On",NameFieldDesc="Competitive Information")>
  		<CFELSE>
		<tr class="competitive" <cfif SettingsManagerTemplate.Competitive_Information_On EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><strong>Competitive Information</strong></td>
			<td>&nbsp; </td>
			<td>&nbsp; </td>
			<td align="left" valign="top">
			<input type="checkbox" name="Competitive_Information_On" <cfif Form.Competitive_Information_On IS 1>checked</cfif> value="1" #FormStatus# >
			</td>
		</tr>
		</CFIF>
	</cfif>
	<cfif Generic_Type IS NOT 'Brokerage' AND NOT(Generic_Type IS "LSAutoPay")>
		<CFIF fromSettings_management eq 1>
   				<cfset SettingsTemplateForm(NameField="Include_Competitive_Data_Tracking",NameFieldDesc="Include Competitive Data Tracking")>
  		<CFELSE>
			<tr class="competitive" <cfif SettingsManagerTemplate.Include_Competitive_Data_Tracking EQ 0> style="display:none"</cfif>>
				<td align="right" valign="top"><strong>Include Competitive Data Tracking </strong></td>
					<td>&nbsp; </td>
					<td>&nbsp; </td>
				<td align="left" valign="top">
					<input type="checkbox" name="Include_Competitive_Data_Tracking" <cfif Form.Include_Competitive_Data_Tracking IS 1>checked</cfif> value="1" onclick="expandTable('BidProgCompetitive'); if(this.checked) {document.all.sp_display_basesales.style.display=''} else  {document.all.sp_display_basesales.style.display='none'} if(this.checked) {document.all.sp_display_bidinfopage.style.display=''} else  {document.all.sp_display_bidinfopage.style.display='none'}"; id="chkToBeInvoiced"; #FormStatus# >
				</td>
			</tr>


			<tr>


			<td colspan="100%">
			<table width="100%" align="center" cellspacing="1" cellpadding="0" border="0" id="TB_BidProgCompetitive" style="display:<cfif Form.Include_Competitive_Data_Tracking IS 1> block<cfelse> none</cfif>;">
			<!---************** BEGIN New Settings for Bid Programs Competitive Data ******************** --->
			<!-------------------------------- Competitive Data Page Section -------------------------------->
			<tr class="competitive" <cfif SettingsManagerTemplate.Include_Competitive_Data_Tracking EQ 0> style="display:none"</cfif>>
				<td colspan="100%" align="center">
				 <!--- 27164 3C Check attached document in Label--->
<table align="left" border="0" style="margin-left:175px;<cfif SettingsManagerTemplate.Include_Competitive_Data_Tracking EQ 0> display:none;</cfif>">
<tr>
<td align="left" valign="top">Direct User To Competitive Data Page&nbsp;&nbsp;</td>
<td>
<CF_SmallHelp
width = "300"
displayShifyX = "-350"
displayShifyY = "-100"
imgPath="/Images/help_small.gif"
imgWidth="14"
imgHeight="14">
<center style="text-align: justify;">
Users are automatically directed to the competitive data page when they set the proposal status as either Split or Lost so they can fill out additional details.
But we do not do this for a proposal status of Won.  Turn this setting ON, if you want the user to be automatically directed to the competitive data page when
they set the proposal status as Won so they can fill out additional details.
</center>
</CF_SmallHelp>&nbsp;
</td>
<td align="left" valign="top"><input type="checkbox" name="Display_reminder_Comp_Data_Page" <cfif Form.Display_Reminder_Comp_Data_Page IS 1>checked</cfif> value="1" #FormStatus# />
</td>
</tr>
</table>

            <!--- 27164 3C Check attached Document in Label--->



			   </td>
			</tr>
			<tr class="competitive" <cfif SettingsManagerTemplate.Include_Competitive_Data_Tracking EQ 0> style="display:none"</cfif>>
				<td align="right" valign="top"><strong>Competitive Data Page</strong>&nbsp;&nbsp;&nbsp;&nbsp;</td>
				<td colspan="2">&nbsp;</td>
				<td align="left" valign="top">&nbsp;&nbsp;&nbsp;&nbsp;<strong>Include</strong></td>
			</tr>

			<tr class="competitive" <cfif SettingsManagerTemplate.Include_Competitive_Data_Tracking EQ 0> style="display:none"</cfif>>
				<td align="right" valign="top">#qGetSourceLabel.General_Labels_Label#&nbsp;&nbsp;&nbsp;&nbsp;</td>
				<td colspan="2">&nbsp;</td>
				<td align="left" valign="top">
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" name="Source" <cfif Form.Source IS 1>checked</cfif> value="1" #FormStatus# />
				</td>
			</tr>
			<tr class="competitive" <cfif SettingsManagerTemplate.Include_Competitive_Data_Tracking EQ 0> style="display:none"</cfif>>
				<td align="right" valign="top">#qGetSourceTypeLabel.General_Labels_Label#&nbsp;&nbsp;&nbsp;&nbsp;</td>
				<td colspan="2">&nbsp;</td>
				<td align="left" valign="top">
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" name="Source_Type" <cfif Form.Source_Type IS 1>checked</cfif> value="1" #FormStatus# />
				</td>
			</tr>
			<tr class="competitive" <cfif SettingsManagerTemplate.Include_Competitive_Data_Tracking EQ 0> style="display:none"</cfif>>
				<td align="right" valign="top">Date Source Rec'd&nbsp;&nbsp;&nbsp;&nbsp;</td>
				<td colspan="2">&nbsp;</td>
				<td align="left" valign="top">
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" name="Date_Source_Received" <cfif Form.Date_Source_Received IS 1>checked</cfif> value="1" #FormStatus# />
				</td>
			</tr>

			<!--- 2013 oct 7, per Paul always include these 3 column (won by, rate, uom) » chris --->
			<tr class="competitive" <cfif SettingsManagerTemplate.Include_Competitive_Data_Tracking EQ 0> style="display:none"</cfif>>
				<td align="right" valign="top">#qGetWonByLabel.General_Labels_Label#&nbsp;&nbsp;&nbsp;&nbsp;</td>
				<td colspan="2">&nbsp;</td>
				<td align="left" valign="top">
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" name="Won_By" disabled=disabled <cfif SettingsManagerTemplate.Include_Competitive_Data_Tracking EQ 1>checked</cfif> value="1" #FormStatus# />
				</td>
			</tr>
			<tr class="competitive" <cfif SettingsManagerTemplate.Include_Competitive_Data_Tracking EQ 0> style="display:none"</cfif>>
				<td align="right" valign="top">Won Rate&nbsp;&nbsp;&nbsp;&nbsp;</td>
				<td colspan="2">&nbsp;</td>
				<td align="left" valign="top">
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" name="Won_Rate" disabled=disabled <cfif SettingsManagerTemplate.Include_Competitive_Data_Tracking IS 1>checked</cfif> value="1" #FormStatus# />
				</td>
			</tr>
			<tr class="competitive" <cfif SettingsManagerTemplate.Include_Competitive_Data_Tracking EQ 0> style="display:none"</cfif>>
				<td align="right" valign="top">Won UOM&nbsp;&nbsp;&nbsp;&nbsp;</td>
				<td colspan="2">&nbsp;</td>
				<td align="left" valign="top">
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" name="Won_UOM" disabled=disabled <cfif SettingsManagerTemplate.Include_Competitive_Data_Tracking IS 1>checked</cfif> value="1" #FormStatus# />
				</td>
			</tr>

			<tr class="competitive" <cfif SettingsManagerTemplate.Include_Competitive_Data_Tracking EQ 0> style="display:none"</cfif>>
				<td align="right" valign="top">Delivery Type&nbsp;&nbsp;&nbsp;&nbsp;</td>
				<td colspan="2">&nbsp;</td>
				<td align="left" valign="top">
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" name="Delivery_Type" <cfif Form.Delivery_Type IS 1>checked</cfif> value="1" #FormStatus# />
				</td>
			</tr>
			<tr class="competitive" <cfif SettingsManagerTemplate.Include_Competitive_Data_Tracking EQ 0> style="display:none"</cfif>>
				<td align="right" valign="top">#qGetCategoryLabel.General_Labels_Label#&nbsp;&nbsp;&nbsp;&nbsp;</td>
				<td colspan="2">&nbsp;</td>
				<td align="left" valign="top">
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" name="Category" <cfif Form.Category IS 1>checked</cfif> value="1" #FormStatus# />
				</td>
			</tr>
			<tr class="competitive" <cfif SettingsManagerTemplate.Include_Competitive_Data_Tracking EQ 0> style="display:none"</cfif>>
				<td align="right" valign="top">#qGetPackageLabel.General_Labels_Label#&nbsp;&nbsp;&nbsp;&nbsp;</td>
				<td colspan="2">&nbsp;</td>
				<td align="left" valign="top">
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" name="Package" <cfif Form.Package IS 1>checked</cfif> value="1" #FormStatus# />
				</td>
			</tr>
			<tr class="competitive" <cfif SettingsManagerTemplate.Include_Competitive_Data_Tracking EQ 0> style="display:none"</cfif>>
				<td align="right" valign="top">Shared&nbsp;&nbsp;&nbsp;&nbsp;</td>
				<td colspan="2">&nbsp;</td>
				<td align="left" valign="top">
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" name="Shared" <cfif Form.Shared IS 1>checked</cfif> value="1" #FormStatus# />
				</td>
			</tr>
			<tr class="competitive" <cfif SettingsManagerTemplate.Include_Competitive_Data_Tracking EQ 0> style="display:none"</cfif>>
				<td align="right" valign="top">Incremental&nbsp;&nbsp;&nbsp;&nbsp;</td>
				<td colspan="2">&nbsp;</td>
				<td align="left" valign="top">
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" name="Incremental" <cfif Form.Incremental IS 1>checked</cfif> value="1" #FormStatus# />
				</td>
			</tr>

			<tr class="competitive" <cfif SettingsManagerTemplate.Include_Competitive_Data_Tracking EQ 0> style="display:none"</cfif>>
				<td align="right" valign="top">Download Comp Data History&nbsp;&nbsp;&nbsp;&nbsp;</td>
				<td colspan="2">&nbsp;</td>
				<td align="left" valign="top">
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" name="Download_Comp_Data_History" <cfif Form.Download_Comp_Data_History IS 1>checked</cfif> value="1" #FormStatus# />
				</td>
			</tr>

			<tr class="competitive" <cfif SettingsManagerTemplate.Include_Competitive_Data_Tracking EQ 0> style="display:none"</cfif>>
				<td align="right" valign="top">Spec'd&nbsp;&nbsp;&nbsp;&nbsp;</td>
				<td colspan="2">&nbsp;</td>
				<td align="left" valign="top">
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" name="specd" <cfif Form.Specd IS 1>checked</cfif> value="1" #FormStatus# />
				</td>
			</tr>

			<!-------------------------------- Volume Page Section -------------------------------->
			<tr class="competitive" <cfif SettingsManagerTemplate.Include_Competitive_Data_Tracking EQ 0> style="display:none"</cfif>>
				<td colspan="100%">&nbsp;</td>
			</tr>
			<tr class="competitive" <cfif SettingsManagerTemplate.Include_Competitive_Data_Tracking EQ 0> style="display:none"</cfif>>
				<td align="right" valign="top"><strong>Volume Page</strong>&nbsp;&nbsp;&nbsp;&nbsp;</td>
				<td colspan="2">&nbsp;</td>
				<td align="left" valign="top">&nbsp;&nbsp;&nbsp;&nbsp;<strong>Include</strong></td>
			</tr>
			<tr class="competitive" <cfif SettingsManagerTemplate.Include_Competitive_Data_Tracking EQ 0> style="display:none"</cfif>>
				<td align="right" valign="top">Opportunity Volume&nbsp;&nbsp;&nbsp;&nbsp;</td>
				<td colspan="2">&nbsp;</td>
				<td align="left" valign="top">
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" name="Opportunity_Volume" <cfif Form.Opportunity_Volume IS 1>checked</cfif> value="1" #FormStatus# />
				</td>
			</tr>
			<tr class="competitive" <cfif SettingsManagerTemplate.Include_Competitive_Data_Tracking EQ 0> style="display:none"</cfif>>
				<td colspan="100%">&nbsp;</td>
			</tr>
			<!---************** END New Settings for Bid Programs Competitive Data ******************** --->
			</table>
			</td>
			</tr>
			</CFIF>
			<CFIF fromSettings_management eq 1>
   				<cfset SettingsTemplateForm(NameField="Track_Price_Comp",NameFieldDesc="Track Price and Competitor on lost programs?")>
  			<CFELSE>

			<tr id="Track_PriceInterface"  <cfif SettingsManagerTemplate.Track_Price_Comp EQ 0>style="display:none" <cfelse> class="<cfif form.BidRequestStatusOn EQ 1>showOptions<cfelse>hideOptions</cfif>"</cfif>>
				<td align="right" valign="top"><strong>Track Price and Competitor on lost programs?</strong></td>
				<td>&nbsp; </td>
				<td>&nbsp; </td>
				<td align="left" valign="top">
				<input type="checkbox" name="Track_Price_Comp"
					<cfif Form.Track_Price_Comp EQ 1>
						checked</cfif>
					value="1" #FormStatus# />
				</td>
			</tr>
			</CFIF>
		</cfif> <!--- from 1975 Generic_Type IS NOT 'Brokerage' AND NOT(Generic_Type IS "LSAutoPay") --->
<!--- 	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX	 --->
		<cfif NOT(Generic_Type IS "LSAutoPay")>
				<!---
				<tr>
					<td align="right" nowrap valign="top"><font class="retroFieldsIndicator">*</font><strong>Message on Volume Page</strong></td>
					<td colspan="3">&nbsp;</td>
				</tr>
				<tr>
					<td align="center" nowrap valign="top" colspan="4">
					<textarea name="Volume_Related_Message" rows="4" cols="40" onPaste="javaScript: return textareaChecklength(200, this);"  onkeyPress="javaScript: return textareaChecklength(200, this);" #FormStatus# >#Form.Volume_Related_Message#</textarea></td>
				</tr>
				--->
				<CFIF fromSettings_management eq 1>
   				 	<cfset SettingsTemplateForm(NameField="display_basesales_Competitive_Data",NameFieldDesc="Display Base Sales in Competitive Data")>
  				<CFELSE>
				<cfif SettingsManagerTemplate.display_basesales_Competitive_Data EQ 0>
					<input type="hidden" name="display_basesales_Competitive_Data" value="#Form.display_basesales_Competitive_Data#" />
				<cfelse>
				<tr id="sp_display_basesales" style="display:<cfif Form.Include_Competitive_Data_Tracking IS 1>''<cfelse> none</cfif>;">
					<td align="right" nowrap valign="top"><strong>Display Base Sales in Competitive Data</strong></td>
					<td>&nbsp; </td>
					<td>&nbsp; </td>
					<td align="left" valign="top">
					<input type="checkbox" name="display_basesales_Competitive_Data" <cfif Form.display_basesales_Competitive_Data IS 1>checked</cfif> value="1" #FormStatus# >
					</td>
				</tr>
				</cfif>
				</CFIF>
		</cfif>		<!--- Generic_Type IS "LSAutoPay" --->

		<!---- START: 28354/Anand Rao/08-Nov-2011  ---->
		<CFIF fromSettings_management eq 1>
   				<cfset SettingsTemplateForm(NameField="display_bid_info_page",NameFieldDesc="Display Bid Info Page")>
  		<CFELSE>
		<cfif SettingsManagerTemplate.display_bid_info_page EQ 0>
					<input type="hidden" name="display_bid_info_page" value="#Form.display_bid_info_page#" />
					<input type="hidden" name="line_number" value="#Form.line_number#" />
				<cfelse>
				<tr class="competitive" id="sp_display_bidinfopage" style="display:<cfif Form.Include_Competitive_Data_Tracking IS 1>''<cfelse> none</cfif>;">
					<td align="right" nowrap valign="top"><strong>Display Bid Info Page</strong></td>
					<td>&nbsp; </td>
					<td>&nbsp; </td>
					<td align="left" valign="top">
					<input type="checkbox" name="display_bid_info_page" <cfif Form.display_bid_info_page IS 1>checked</cfif> value="1" onclick="if(this.checked) {document.all.tr_lineNumber.style.display=''} else  {document.all.tr_lineNumber.style.display='none'}" #FormStatus# >
					</td>
				</tr>

<tr <cfif Form.display_bid_info_page EQ 0> style="display:none"</cfif> id="tr_lineNumber">
				<td colspan="100%" align="center">
				 <!--- 27164 3C Check attached document in Label--->
<table align="left" border="0" style="margin-left:380px;<cfif SettingsManagerTemplate.display_bid_info_page EQ 0> display:none;</cfif>">
<tr>
<td align="left" valign="top" width="70">
Line ##&nbsp;</td>
<td colspan="2">&nbsp;</td>
<td>
<input type="checkbox" name="line_number" <cfif Form.line_number IS 1>checked</cfif> value="1" #FormStatus# >
</td>
</tr>
</table>
</td>
</tr>


				</cfif>
				</CFIF>





		<!----END: 28354/Anand Rao/08-Nov-2011 ---->
	<!--- XXXXXXXXXXXXXXXXXXXXXX  Settlement Rules	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<tr id="settlementrules_heading"><Th colspan="100%" bgcolor="##93BEE2">Settlement Rules</TH></tr>
	<!---MWS: Label 11062 - Added Purchase Period override. If value greater than 0, the number will be used to calculate
			the nuber of days back from the program end date to look for invoice data during BB Deviations --->
	<cfif generic_type EQ 'Bid Request' OR generic_type EQ "Operator-Deviated Pricing" or generic_type EQ 'Operator Direct or HQ Programs' or generic_type EQ 'Field Execution'>


<!-----------------------------------------------------------------------------
Dev Notes: D18996
    Added two fields BB_D_Template_Overrides_Deviation_Tolerances and
    BB_D_Aggregation_Period_OverRide and corresponding validation for these
    -Anand Rao/15-May-09
------------------------------------------------------------------------------>
	<CFIF fromSettings_management eq 1>
   		<!---<cfset SettingsTemplateForm(NameField="BB_D_Template_Overrides_Deviation_Tolerances",NameFieldDesc="Template Overrides Deviation Tolerances")>--->
		<tr>
			<td align="right" valign="top"><strong>Template Overrides Deviation Tolerances</strong></td>
			<td align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_D_Template_Overrides_Deviation_Tolerances" value="1" id="BB_D_Template_Overrides_Deviation_Tolerances_1" <cfif templateSettings.BB_D_Template_Overrides_Deviation_Tolerances EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_D_Template_Overrides_Deviation_Tolerances" value="0" id="BB_D_Template_Overrides_Deviation_Tolerances_0" <cfif templateSettings.BB_D_Template_Overrides_Deviation_Tolerances EQ 0>checked</cfif> onclick="javascript:hideTemplateOverridesDeviation();"> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</td>
			<cfif strException_Active.BB_D_Template_Overrides_Deviation_Tolerances EQ 0>
				<cfset LinkExceptions = "Select Exceptions">
			<cfelse>
				<cfset LinkExceptions = "Update Exceptions">
			</cfif>
			<td>
				<CF_smallLink
					title = "#LinkExceptions#"
					url = "##"
					parameters = "onClick=""javascript: return AddExceptions('#Generic_Type#','#SettingIDs.BB_D_Template_Overrides_Deviation_Tolerances#','BB_D_Template_Overrides_Deviation_Tolerances');"""
				>
				<span id="picon_#SettingIDs.BB_D_Template_Overrides_Deviation_Tolerances#"></span>
				<font>&nbsp;</font>
			</td>
   		</tr>
  	<CFELSE>
    	<tr class="settlementrules" <cfif SettingsManagerTemplate.BB_D_Template_Overrides_Deviation_Tolerances EQ 0> style="display:none"</cfif>>
			<td align="right" valign="top"><font class="retroFieldsIndicator">*</font><strong>Template Overrides Deviation Tolerances</strong></td>
			<td>&nbsp; </td>
			<td>&nbsp; </td>
			<td align="left" valign="top">
			<CFQUERY NAME="qGetBillbackStatus" DATASOURCE="#Application.Datasource#">
				SELECT	Billback_Status_ID,BB_Status_Description
				FROM	Billback_Status
				WHERE 	Billback_Status_ID NOT IN (1,5,6,7,8)
				ORDER BY Status_Order_Number
			</CFQUERY>
			<CFIF fromSettings_management neq 1>
				<cfquery NAME="qGetClosingMethods" datasource="#application.datasource#">
					SELECT  Billback_Closing_Methods.iBillback_Closing_Method_ID,vchBillback_Closing_Method_Desc,isnull(Billback_Closing_Methods_Template.Auto_Dev_BB_Status_Below,0) as Auto_Dev_BB_Status_Below , isnull(Billback_Closing_Methods_Template.Auto_Dev_BB_Status_Exceed,0) as Auto_Dev_BB_Status_Exceed
					FROM  	Billback_Closing_Methods
					LEFT JOIN Billback_Closing_Methods_Template on Billback_Closing_Methods.iBillback_Closing_Method_ID = Billback_Closing_Methods_Template.iBillback_Closing_Method_ID and Billback_Closing_Methods_Template.First_Parent_ID = #First_Parent_ID#
					WHERE	bEnabled = 1
					ORDER BY vchBillback_Closing_Method_Desc
				</cfquery>
			</CFIF>

      <!---39939 Conflict with Jquery, hard coded  JS---> 
      <script language="JavaScript1.2">
      function toggleVal(obj){
       {
          if (obj.checked == true){
            document.BasicInfo.BB_D_Purchase_Period_OverRide.disabled = false;
            document.BasicInfo.BB_D_Purchase_Period_OverRide_Rate.disabled = false;
            document.BasicInfo.BB_D_Aggregation_Period_OverRide.disabled = false;
            document.BasicInfo.BB_Tolerance_DVT.disabled = false;
            document.BasicInfo.BB_Tolerance_ERT.disabled = false;
            document.BasicInfo.Cannot_Exceed_Percent.disabled = false;
            document.BasicInfo.Cannot_Exceed_Dollar.disabled = false;
            bbPeriodOverrides.style.display='block';
            opPeriodOverrides.style.display='block';
            bbPeriodOverrideRate.style.display='block';
            tr_BB_Tolerance_DVT.style.display='block';
            tr_BB_Tolerance_ERT.style.display='block';
            tr_Cannot_Exceed_Percent.style.display='block';
            tr_Cannot_Exceed_Dollar.style.display='block';
            tr_Maximum_Dollar_Amount_Checked.style.display='block';
            tr_Billback_Status_if_Below_Deviation.style.display='block';
            tr_Billback_Status_if_Exceeds_Deviation.style.display='block';
            tr_Auto_Deviation_Inc_Manual_BB.style.display='block';
            <cfloop query="qGetClosingMethods">
				tr_Exceed_#iBillback_Closing_Method_ID#.style.display='block';
				tr_Below_#iBillback_Closing_Method_ID#.style.display='block';
            </cfloop>
          }
          else{
          //  document.BasicInfo.BB_D_Purchase_Period_OverRide.value= = "0";
          //  document.BasicInfo.BB_D_Aggregation_Period_OverRide.value = "0";
            document.BasicInfo.BB_D_Purchase_Period_OverRide.disabled = true;
            document.BasicInfo.BB_D_Purchase_Period_OverRide_Rate.disabled = true;
            document.BasicInfo.BB_D_Aggregation_Period_OverRide.disabled = true;
            document.BasicInfo.BB_Tolerance_DVT.disabled = true;
            document.BasicInfo.BB_Tolerance_ERT.disabled = true;
            document.BasicInfo.Cannot_Exceed_Percent.disabled = true;
            document.BasicInfo.Cannot_Exceed_Dollar.disabled = true;
            bbPeriodOverrides.style.display='none';
            opPeriodOverrides.style.display='none';
            bbPeriodOverrideRate.style.display='none';
            tr_BB_Tolerance_DVT.style.display='none';
            tr_BB_Tolerance_ERT.style.display='none';
            tr_Cannot_Exceed_Percent.style.display='none';
            tr_Cannot_Exceed_Dollar.style.display='none';
            tr_Maximum_Dollar_Amount_Checked.style.display='none';
            tr_Billback_Status_if_Below_Deviation.style.display='none';
            tr_Billback_Status_if_Exceeds_Deviation.style.display='none';
            tr_Auto_Deviation_Inc_Manual_BB.style.display='none';
            <cfloop query="qGetClosingMethods">
				tr_Exceed_#iBillback_Closing_Method_ID#.style.display='none';
				tr_Below_#iBillback_Closing_Method_ID#.style.display='none';
            </cfloop>
          }
        }
      }
      </script>
				<input type="Checkbox" name="BB_D_Template_Overrides_Deviation_Tolerances" <cfif FORM.BB_D_Template_Overrides_Deviation_Tolerances IS 1>checked</cfif> value="1" #FormStatus#  onclick="toggleVal(this);"/>
				<input type="hidden" name="Billback_Closing_Method_ID_List" value="#ValueList(qGetClosingMethods.iBillback_Closing_Method_ID)#" />
		</td>
	</tr>
	</CFIF>
  <!--- <div id="divPeriodOverrides"> --->
  	<CFIF fromSettings_management eq 1>
   			<cfset SettingsTemplateForm(NameField="BB_D_Purchase_Period_OverRide",NameFieldDesc="Billback Purchase Period Over Ride for Volume<br>(Days from billback end date to capture invoice data)")>
  	<CFELSE>
  	<cfif SettingsManagerTemplate.BB_D_Purchase_Period_OverRide EQ 0>
			<span id="bbPeriodOverrides"></span><input type="hidden" name="BB_D_Purchase_Period_OverRide" value="#Form.BB_D_Purchase_Period_OverRide#" />
	<cfelse>
		<tr id="bbPeriodOverrides" <cfif FORM.BB_D_Template_Overrides_Deviation_Tolerances IS 0>style="display:none"</cfif>>
			<td align="right" valign="top"><font class="retroFieldsIndicator">*</font><strong>Billback Purchase Period Over Ride for Volume<br>(Days from billback end date to capture invoice data)</strong></td>
			<td>&nbsp; </td>
			<td>&nbsp; </td>
			<td align="left" valign="top">
				<span id="error_BB_D_Purchase_Period_OverRide"></span><input name="BB_D_Purchase_Period_OverRide" type="textbox"  size="5" maxlength="4" value="#Form.BB_D_Purchase_Period_OverRide#" onKeyUp="clenseText(this, '0123456789')" style="backgroundColor:red" #FormStatus#  <cfif FORM.BB_D_Template_Overrides_Deviation_Tolerances IS 0>disabled</cfif> />Days
			</td>
		</tr>
	</cfif>
	</CFIF>
	<CFIF fromSettings_management eq 1>
   		<cfset SettingsTemplateForm(NameField="BB_D_Purchase_Period_OverRide_Rate",NameFieldDesc="Billback Purchase Period Over Ride for Rate<br>(Days from billback end date to capture invoice data)")>
  	<CFELSE>
	<cfif SettingsManagerTemplate.BB_D_Purchase_Period_OverRide_Rate EQ 0>
			<span id="bbPeriodOverrideRate"></span><input type="hidden" name="BB_D_Purchase_Period_OverRide_Rate" value="#Form.BB_D_Purchase_Period_OverRide_Rate#" />
	<cfelse>
		<tr id="bbPeriodOverrideRate" <cfif FORM.BB_D_Template_Overrides_Deviation_Tolerances IS 0>style="display:none"</cfif>>
			<td align="right" valign="top"><font class="retroFieldsIndicator">*</font><strong>Billback Purchase Period Over Ride for Rate<br>(Days from billback end date to capture invoice data)</strong></td>
			<td>&nbsp; </td>
			<td>&nbsp; </td>
			<td align="left" valign="top">
				<span id="error_BB_D_Purchase_Period_OverRide_Rate"></span><input name="BB_D_Purchase_Period_OverRide_Rate" type="textbox"  size="5" maxlength="4" value="#Form.BB_D_Purchase_Period_OverRide_Rate#" onKeyUp="clenseText(this, '0123456789')" style="backgroundColor:red" #FormStatus#  <cfif FORM.BB_D_Template_Overrides_Deviation_Tolerances IS 0>disabled</cfif> />Days
			</td>
		</tr>
    </cfif>
	</CFIF>
	<CFIF fromSettings_management eq 1>
   			<cfset SettingsTemplateForm(NameField="BB_D_Aggregation_Period_OverRide",NameFieldDesc="Billback Aggregation Period Over Ride<br>(Days from BB end date to capture other operator billbacks)")>
  	<CFELSE>
	<cfif SettingsManagerTemplate.BB_D_Aggregation_Period_OverRide EQ 0>
			<span id="opPeriodOverrides"></span><input type="hidden" name="BB_D_Aggregation_Period_OverRide" value="#Form.BB_D_Aggregation_Period_OverRide#" />
	<cfelse>
	  	<tr id="opPeriodOverrides" <cfif FORM.BB_D_Template_Overrides_Deviation_Tolerances IS 0> style="display:none"</cfif>>
			<td align="right" valign="top"><font class="retroFieldsIndicator">*</font><strong>Billback Aggregation Period Over Ride<br>(Days from BB end date to capture other operator billbacks)</strong></td>
			<td>&nbsp; </td>
			<td>&nbsp; </td>
			<td align="left" valign="top">
				<span id="error_BB_D_Aggregation_Period_OverRide"></span><input name="BB_D_Aggregation_Period_OverRide" type="textbox"  size="5" maxlength="4" value="#Form.BB_D_Aggregation_Period_OverRide#" onKeyUp="clenseText(this, '0123456789')" style="backgroundColor:red" #FormStatus# <cfif FORM.BB_D_Template_Overrides_Deviation_Tolerances IS 0>disabled</cfif>/>Days
			</td>
		</tr><!--- </div> --->
	</cfif>
	</CFIF>

	<!--- 30418 Settings for deviations by template :: start --->
	<CFIF fromSettings_management eq 1>
   			<cfset SettingsTemplateForm(NameField="BB_Tolerance_DVT",NameFieldDesc="Distributor Volume Tolerance (Whole percent difference)")>
  	<CFELSE>
		<cfif SettingsManagerTemplate.BB_Tolerance_DVT EQ 0 OR SettingsManagerTemplate.BB_D_Template_Overrides_Deviation_Tolerances EQ 0 >
			<span id="tr_BB_Tolerance_DVT"></span><input type="hidden" name="BB_Tolerance_DVT" value="#Form.BB_Tolerance_DVT#" />
		<cfelse>
	  		<tr id="tr_BB_Tolerance_DVT" <cfif  FORM.BB_D_Template_Overrides_Deviation_Tolerances IS 0> style="display:none"</cfif>>
				<td align="right" valign="center"><font class="retroFieldsIndicator">*</font><strong>Distributor Volume Tolerance (Whole percent difference)</strong></td>
				<td>&nbsp; </td>
				<td>&nbsp; </td>
				<td align="left" valign="top">
				<span id="error_BB_Tolerance_DVT"></span><input name="BB_Tolerance_DVT" type="textbox"  size="5" maxlength="4" value="#Form.BB_Tolerance_DVT#" onKeyUp="clenseText(this, '0123456789')" style="backgroundColor:red" #FormStatus# />%
				</td>
			</tr>
		</cfif>
	</CFIF>
	<CFIF fromSettings_management eq 1>
   			<cfset SettingsTemplateForm(NameField="BB_Tolerance_ERT",NameFieldDesc="Rate Tolerance(Whole percent)")>
  	<CFELSE>
		<cfif SettingsManagerTemplate.BB_Tolerance_ERT EQ 0 OR SettingsManagerTemplate.BB_D_Template_Overrides_Deviation_Tolerances EQ 0>
			<span id="tr_BB_Tolerance_ERT"></span><input type="hidden" name="BB_Tolerance_ERT" value="#Form.BB_Tolerance_ERT#" />
		<cfelse>
			<tr id="tr_BB_Tolerance_ERT" <cfif SettingsManagerTemplate.BB_Tolerance_ERT EQ 0 OR SettingsManagerTemplate.BB_D_Template_Overrides_Deviation_Tolerances EQ 0 OR FORM.BB_D_Template_Overrides_Deviation_Tolerances IS 0> style="display:none"</cfif>>
				<td align="right" valign="top"><font class="retroFieldsIndicator">*</font><strong>Rate Tolerance (Whole percent)</strong></td>
				<td>&nbsp; </td>
				<td>&nbsp; </td>
				<td align="left" valign="top">
					<span id="error_BB_Tolerance_ERT"></span><input name="BB_Tolerance_ERT" type="textbox"  size="5" maxlength="4" value="#Form.BB_Tolerance_ERT#" onKeyUp="clenseText(this, '0123456789')" style="backgroundColor:red" #FormStatus# />%
				</td>
			</tr>
		</cfif>
	</CFIF>
	<CFIF fromSettings_management eq 1>
   			<cfset SettingsTemplateForm(NameField="Cannot_Exceed_Percent",NameFieldDesc="Deviation Cannot Exceed %")>
  	<CFELSE>
		<cfif SettingsManagerTemplate.Cannot_Exceed_Percent EQ 0 OR SettingsManagerTemplate.BB_D_Template_Overrides_Deviation_Tolerances EQ 0>
			<span id="tr_Cannot_Exceed_Percent"></span><input type="hidden" name="Cannot_Exceed_Percent" value="#Form.Cannot_Exceed_Percent#" />
		<cfelse>
	  		<tr id="tr_Cannot_Exceed_Percent" <cfif FORM.BB_D_Template_Overrides_Deviation_Tolerances IS 0 OR SettingsManagerTemplate.Cannot_Exceed_Percent EQ 0 OR SettingsManagerTemplate.BB_D_Template_Overrides_Deviation_Tolerances EQ 0> style="display:none"</cfif>>
				<td align="right" valign="top"><font class="retroFieldsIndicator">*</font><strong>Deviation Cannot Exceed %</strong></td>
				<td>&nbsp; </td>
				<td>&nbsp; </td>
				<td align="left" valign="top">
					<span id="error_Cannot_Exceed_Percent"></span><input type="textbox" name="Cannot_Exceed_Percent" value="#Form.Cannot_Exceed_Percent#" size="5" ONKEYUP="clenseText(this,'0123456789.')"  style="backgroundColor:red" #FormStatus#/>
				</td>
			</tr>
		</cfif>
	</CFIF>
	<CFIF fromSettings_management eq 1>
   			<cfset SettingsTemplateForm(NameField="Cannot_Exceed_Dollar",NameFieldDesc="Deviation Cannot Exceed $")>
  	<CFELSE>
		<cfif SettingsManagerTemplate.Cannot_Exceed_Dollar EQ 0 OR SettingsManagerTemplate.BB_D_Template_Overrides_Deviation_Tolerances EQ 0>
			<span id="tr_Cannot_Exceed_Dollar"></span><input type="hidden" name="Cannot_Exceed_Dollar" value="#Form.Cannot_Exceed_Dollar#" />
		<cfelse>
	  		<tr class="settlementrules" id="tr_Cannot_Exceed_Dollar" <cfif FORM.BB_D_Template_Overrides_Deviation_Tolerances IS 0 OR SettingsManagerTemplate.Cannot_Exceed_Dollar EQ 0 OR SettingsManagerTemplate.BB_D_Template_Overrides_Deviation_Tolerances EQ 0> style="display:none"</cfif>>
				<td align="right" valign="top"><font class="retroFieldsIndicator">*</font><strong>Deviation Cannot Exceed $</strong></td>
				<td>&nbsp; </td>
				<td>&nbsp; </td>
				<td align="left" valign="top">
					<span id="error_Cannot_Exceed_Dollar"></span><input name="Cannot_Exceed_Dollar" type="textbox"  size="5"  value="#Form.Cannot_Exceed_Dollar#" onKeyUp="clenseText(this, '0123456789.')" style="backgroundColor:red" #FormStatus# />
				</td>
			</tr>
		</cfif>
	</CFIF>
	<CFIF fromSettings_management eq 1>
   			<cfset SettingsTemplateForm(NameField="Billback_Status_if_Below_Deviation",NameFieldDesc="Billback Status if Below Deviation")>
  	<CFELSE>
		<cfif SettingsManagerTemplate.Billback_Status_if_Below_Deviation EQ 0 OR SettingsManagerTemplate.BB_D_Template_Overrides_Deviation_Tolerances EQ 0>
			<span id="tr_Billback_Status_if_Below_Deviation"></span>
			<cfloop query="qGetClosingMethods">
				<span id="tr_Below_#iBillback_Closing_Method_ID#"></span>
				<input type="hidden" name="#iBillback_Closing_Method_ID#_Auto_Dev_BB_Status_Below" value="#qGetClosingMethods.Auto_Dev_BB_Status_Below#" />
			</cfloop>
		<cfelse>
	  		<tr class="settlementrules" id="tr_Billback_Status_if_Below_Deviation" <cfif FORM.BB_D_Template_Overrides_Deviation_Tolerances IS 0 OR SettingsManagerTemplate.Billback_Status_if_Below_Deviation EQ 0 OR SettingsManagerTemplate.BB_D_Template_Overrides_Deviation_Tolerances EQ 0> style="display:none"</cfif>>
				<td valign="top" align="center" colspan="4"><font class="retroFieldsIndicator">*</font><strong>Billback Status if Below Deviation:</strong></td>
			</tr>
			<cfloop query="qGetClosingMethods">
				<tr id="tr_Below_#iBillback_Closing_Method_ID#"" <cfif FORM.BB_D_Template_Overrides_Deviation_Tolerances IS 0 OR SettingsManagerTemplate.Billback_Status_if_Below_Deviation EQ 0 OR SettingsManagerTemplate.BB_D_Template_Overrides_Deviation_Tolerances EQ 0> style="display:none"</cfif>>
					<td align="right" valign="top"><font class="retroFieldsIndicator">*</font><strong>#qGetClosingMethods.vchBillback_Closing_Method_Desc#</strong></td>
					<td>&nbsp; </td>
					<td>&nbsp; </td>
					<td align="left" valign="top">
					<span id="error_#iBillback_Closing_Method_ID#_Auto_Dev_BB_Status_Below"></span>
					<select name="#iBillback_Closing_Method_ID#_Auto_Dev_BB_Status_Below" #FormStatus#>
						<option value="0" <cfif qGetClosingMethods.Auto_Dev_BB_Status_Below eq 0>selected</cfif>>Select Billback Status</option>
								<cfloop query="qGetBillbackStatus">
									<option value="#Billback_Status_ID#" <cfif qGetClosingMethods.Auto_Dev_BB_Status_Below eq Billback_Status_ID>selected</cfif>>#BB_Status_Description#</option>
								</cfloop>
					</select>
					</td>
				</tr>
			</cfloop>
		</cfif>
	</CFIF>
	<CFIF fromSettings_management eq 1>
   			<cfset SettingsTemplateForm(NameField="Billback_Status_if_Exceeds_Deviation",NameFieldDesc="Billback Status if Exceeds Deviation")>
  	<CFELSE>
		<cfif SettingsManagerTemplate.Billback_Status_if_Exceeds_Deviation EQ 0 OR SettingsManagerTemplate.BB_D_Template_Overrides_Deviation_Tolerances EQ 0>
			<span id="tr_Billback_Status_if_Exceeds_Deviation"></span>
			<cfloop query="qGetClosingMethods">
				<span id="tr_Exceed_#iBillback_Closing_Method_ID#"></span>
				<input type="hidden" name="#iBillback_Closing_Method_ID#_Auto_Dev_BB_Status_Exceed" value="#qGetClosingMethods.Auto_Dev_BB_Status_Exceed#" />
			</cfloop>
		<cfelse>
		  	<tr id="tr_Billback_Status_if_Exceeds_Deviation" <cfif FORM.BB_D_Template_Overrides_Deviation_Tolerances IS 0 OR SettingsManagerTemplate.Billback_Status_if_Exceeds_Deviation EQ 0 OR SettingsManagerTemplate.BB_D_Template_Overrides_Deviation_Tolerances EQ 0> style="display:none"</cfif>>
				<td valign="top" align="center" colspan="4"><font class="retroFieldsIndicator">*</font><strong>Billback Status if Exceeds Deviation:</strong></td>
			</tr>
			<cfloop query="qGetClosingMethods">
				<tr class="settlementrules" id="tr_Exceed_#iBillback_Closing_Method_ID#" <cfif FORM.BB_D_Template_Overrides_Deviation_Tolerances IS 0 OR SettingsManagerTemplate.Billback_Status_if_Exceeds_Deviation EQ 0 OR SettingsManagerTemplate.BB_D_Template_Overrides_Deviation_Tolerances EQ 0> style="display:none"</cfif>>
					<td align="right" valign="top"><font class="retroFieldsIndicator">*</font><strong>#qGetClosingMethods.vchBillback_Closing_Method_Desc#</strong></td>
					<td>&nbsp; </td>
					<td>&nbsp; </td>
					<td align="left" valign="top">
					<span id="error_#iBillback_Closing_Method_ID#_Auto_Dev_BB_Status_Exceed"></span>
						<select name="#iBillback_Closing_Method_ID#_Auto_Dev_BB_Status_Exceed" #FormStatus#>
							<option value="0" <cfif qGetClosingMethods.Auto_Dev_BB_Status_Exceed eq 0>selected</cfif>>Select Billback Status</option>
							<cfloop query="qGetBillbackStatus">
								<option value="#Billback_Status_ID#" <cfif qGetClosingMethods.Auto_Dev_BB_Status_Exceed eq Billback_Status_ID>selected</cfif>>#BB_Status_Description#</option>
							</cfloop>
						</select>
					</td>
				</tr>
			</cfloop>
		</cfif>
	</CFIF>
	<CFIF fromSettings_management eq 1>
   		<cfset SettingsTemplateForm(NameField="Maximum_Dollar_Amount_Checked",NameFieldDesc="Include Max Dollar Amt")>
  	<CFELSE>
		<cfif SettingsManagerTemplate.Maximum_Dollar_Amount_Checked EQ 0 OR SettingsManagerTemplate.BB_D_Template_Overrides_Deviation_Tolerances EQ 0>
			<span id="tr_Maximum_Dollar_Amount_Checked"></span><input type="hidden" name="Maximum_Dollar_Amount_Checked" value="#Form.Maximum_Dollar_Amount_Checked#" />
			<span id="tr_Maximum_Dollar_Amount"></span><input type="hidden" name="Maximum_Dollar_Amount" value="#Form.Maximum_Dollar_Amount#" />
			<span id="tr_Billback_Status_For_Max_Dollar_Amt"></span><input type="hidden" name="Billback_Status_For_Max_Dollar_Amt" value="#Form.Billback_Status_For_Max_Dollar_Amt#" />
		<cfelse>
			<tr class="settlementrules" id="tr_Maximum_Dollar_Amount_Checked" <cfif SettingsManagerTemplate.Maximum_Dollar_Amount_Checked EQ 0 OR FORM.BB_D_Template_Overrides_Deviation_Tolerances IS 0 OR SettingsManagerTemplate.BB_D_Template_Overrides_Deviation_Tolerances EQ 0> style="display:none"</cfif>>
				<td align="right" nowrap valign="top"><font class="retroFieldsIndicator">*</font><strong>Include Max Dollar Amt</strong></td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td align="left" valign="bottom">
					<span id="error_Maximum_Dollar_Amount_Checked"></span>
					<input onclick="javaScript:showHideObject(this, document.all.tr_Maximum_Dollar_Amount);showHideObject(this, document.all.tr_Billback_Status_For_Max_Dollar_Amt);" type="checkbox" name="Maximum_Dollar_Amount_Checked"  value="1" <cfif Form.Maximum_Dollar_Amount_Checked>CHECKED</cfif> #FormStatus# /></td>
			</tr>
			<tr class="settlementrules" id="tr_Maximum_Dollar_Amount" <cfif SettingsManagerTemplate.Maximum_Dollar_Amount_Checked EQ 0 OR Form.Maximum_Dollar_Amount_Checked EQ 0 OR FORM.BB_D_Template_Overrides_Deviation_Tolerances IS 0 OR SettingsManagerTemplate.BB_D_Template_Overrides_Deviation_Tolerances EQ 0> style="display:none"</cfif>>
				<td align="right" nowrap valign="top"><font class="retroFieldsIndicator">*</font><strong>Claim dollars cannot equal or exceed $</strong></td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td align="left" valign="bottom">
					<span id="error_Maximum_Dollar_Amount"></span>
					<input name="Maximum_Dollar_Amount" type="textbox"   size="6" value="#Form.Maximum_Dollar_Amount#" onKeyUp="clenseText(this, '0123456789 ')" style="backgroundColor:red" #FormStatus# />
				</td>
			</tr>
			<tr class="settlementrules" id="tr_Billback_Status_For_Max_Dollar_Amt" <cfif SettingsManagerTemplate.Maximum_Dollar_Amount_Checked EQ 0 OR Form.Maximum_Dollar_Amount_Checked EQ 0 OR FORM.BB_D_Template_Overrides_Deviation_Tolerances IS 0 OR SettingsManagerTemplate.BB_D_Template_Overrides_Deviation_Tolerances EQ 0> style="display:none"</cfif>>
				<td align="right" nowrap valign="top"><font class="retroFieldsIndicator">*</font><strong>If Claim Equals or Exceeds maximum, set status to</strong></td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td align="left" valign="bottom">
				<span id="error_Billback_Status_For_Max_Dollar_Amt"></span>
					<select name="Billback_Status_For_Max_Dollar_Amt"  #FormStatus# >
						<option value="0" <cfif Form.Billback_Status_For_Max_Dollar_Amt eq 0>selected</cfif>>Select Billback Status</option>
						<cfloop query="qGetBillbackStatus">
							<cfif Billback_Status_ID eq 2>
								<option value="#Billback_Status_ID#" <cfif Form.Billback_Status_For_Max_Dollar_Amt eq Billback_Status_ID>selected</cfif>>#BB_Status_Description#</option>
							</cfif>
						</cfloop>
					</select>
				</td>
			</tr>
		</cfif>
	</CFIF>
	<CFIF fromSettings_management eq 1>
   		<cfset SettingsTemplateForm(NameField="Auto_Deviation_Inc_Manual_BB",NameFieldDesc="Include manually entered billbacks in auto processing")>
  	<CFELSE>
		<cfif SettingsManagerTemplate.Auto_Deviation_Inc_Manual_BB EQ 0 OR SettingsManagerTemplate.BB_D_Template_Overrides_Deviation_Tolerances EQ 0>
			<span id="tr_Auto_Deviation_Inc_Manual_BB"></span><input type="hidden" name="Auto_Deviation_Inc_Manual_BB" value="#Form.Auto_Deviation_Inc_Manual_BB#" />
		<cfelse>
			<tr class="settlementrules" id="tr_Auto_Deviation_Inc_Manual_BB" <cfif SettingsManagerTemplate.Auto_Deviation_Inc_Manual_BB EQ 0 OR FORM.BB_D_Template_Overrides_Deviation_Tolerances IS 0 OR SettingsManagerTemplate.BB_D_Template_Overrides_Deviation_Tolerances EQ 0> style="display:none"</cfif>>
				<td align="right" nowrap valign="top"><font class="retroFieldsIndicator">*</font><strong>Include manually entered billbacks in auto processing</strong></td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td align="left" valign="bottom">
					<span id="error_Auto_Deviation_Inc_Manual_BB"></span><input type="checkbox" name="Auto_Deviation_Inc_Manual_BB"  value="1" <cfif Form.Auto_Deviation_Inc_Manual_BB>CHECKED</cfif> #FormStatus# /></td>
			</tr>
		</cfif>
	</CFIF>
	<!--- 30418 Settings for deviations by template :: end --->
	</cfif> <!--- end :: <cfif generic_type EQ 'Bid Request' OR generic_type EQ "Operator-Deviated Pricing" or generic_type EQ 'Operator Direct or HQ Programs'> --->

	<cfif NOT(Generic_Type IS "LSAutoPay")>
		<!---Billback Due Date--->
		<cfif Generic_Type IS NOT "Brokerage">
			<CFIF fromSettings_management eq 1>
   				<cfset SettingsTemplateForm(NameField="Billback_Date",NameFieldDesc="Last Date to Claim")>
  			<CFELSE>
			<tr class="settlementrules" <cfif SettingsManagerTemplate.Billback_Date EQ 0> style="display:none"</cfif>>
				<td align="right" nowrap valign="top"><strong>Last Date to Claim</strong></td>
					<td>&nbsp; <span id="error_Billback_Expiration"></span><span id="error_Billback_Expiration_Span"></span></td>
					<td>&nbsp; </td>
				<td align="left" valign="top">
				<input type="checkbox" name="Billback_Date" <cfif Form.Billback_date IS 1>checked</cfif> value="1" #FormStatus# >&nbsp; &nbsp;
				<input type="text" name="Billback_Date_Span" size="5" maxlength="10" <cfif Form.Billback_Date_Span IS NOT 0>  value="#Form.Billback_Date_Span#"</cfif> onKeyUp="clenseText(this, '0123456789')" #FormStatus# > Days
				</td>
			</tr>
			</CFIF>
		</cfif>
	<cfelse>
		<CFIF fromSettings_management neq 1>
		<input type="hidden" name="Billback_Date" value="0">
		<input type="hidden" name="Billback_Date_Span" value="#Billback_Date_Span#">
		<input type="hidden" name="Restrict_On_Approval_Group" value="0">
		<input type="hidden" name="Program_Min_Start_Date" value="#FORM.Program_Min_Start_Date#">
		<input type="hidden" name="Program_Max_End_Date" value="#FORM.Program_Max_End_Date#">
		<input type="hidden" name="Program_End_Day" value="#form.program_End_day#">
		<input type="hidden" name="Program_Start_Day" value="#form.program_start_day#">
		</CFIF>
	</cfif><!--- 	LSAUTOPAY end --->
	<cfif appSettings.getReleaseSettlement() and Generic_type IS NOT "Brokerage" AND NOT(Generic_Type IS "LSAutoPay")>
		<CFIF fromSettings_management eq 1>
   				<cfset SettingsTemplateForm(NameField="Release_Settlement",NameFieldDesc="Release Settlement")>
  		<CFELSE>
		<tr  class="settlementrules" <cfif SettingsManagerTemplate.Release_Settlement EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><strong>Release Settlement</strong></td>
				<td>&nbsp; </td>
				<td>&nbsp; </td>
			<td align="left" valign="top">
			<input type="checkbox" name="ReleaseSettlement"  value="1" <cfif Form.ReleaseSettlement NEQ 0>CHECKED</cfif> #FormStatus# >
			</td>
		</tr>
		</CFIF>
		<CFIF fromSettings_management eq 1>
   				<cfset SettingsTemplateForm(NameField="RS_DaysToClaim",NameFieldDesc="Days after Program end date to send <br>release settlement")>
  		<CFELSE>
		<tr class="settlementrules" <cfif SettingsManagerTemplate.RS_DaysToClaim EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><strong>Days after Program end date to send <br>release settlement</strong></td>
				<td>&nbsp; </td>
				<td>&nbsp; </td>
			<td align="left" valign="top">
			<input type="Text" name="RS_DaysToClaim"  value="<cfif Form.RS_DaysToClaim NEQ 0>#Form.RS_DaysToClaim#<cfelse>0</cfif>" onKeyUp="clenseText(this, '0123456789');" #FormStatus# size="2" maxlength="5"> Days
			</td>
		</tr>
		</CFIF>
	</cfif>
	<cfif appsettings.Mass_Pay_Billback IS NOT 0 AND NOT(Generic_Type IS "LSAutoPay")>
		<CFIF fromSettings_management eq 1>
   				<cfset SettingsTemplateForm(NameField="mass_billback_pay",NameFieldDesc="Allow mass payment on billbacks")>
  		<CFELSE>
		<tr class="settlementrules" <cfif SettingsManagerTemplate.mass_billback_pay EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><strong>Allow mass payment on billbacks</strong></td>
			<td>&nbsp; </td>
			<td>&nbsp; </td>
			<td align="left" valign="top">
			<input type="checkbox" name="mass_billback_pay" <cfif Form.mass_billback_pay IS 1>checked</cfif> value="1" #FormStatus# >
			</td>
		</tr>
		</CFIF>
	<cfelse>
		<CFIF fromSettings_management neq 1>
		<input type="hidden" name="mass_billback_pay" value="#Form.mass_billback_pay#" #FormStatus# >
		</CFIF>
	</cfif>

	<cfif Generic_Type IS NOT 'Brokerage' AND NOT(Generic_Type IS "LSAutoPay")>
	<CFIF fromSettings_management eq 1>
   		<cfset SettingsTemplateForm(NameField="apply_rebate_rates",NameFieldDesc="Apply default rates for #lcase(Application.RebateLabel)#")>
  	<CFELSE>
	<tr class="settlementrules" <cfif SettingsManagerTemplate.apply_rebate_rates EQ 0> style="display:none"</cfif>>
		<td align="right" nowrap valign="top"><strong>Apply default rates for #lcase(Application.RebateLabel)#</strong></td>
		<td>&nbsp; </td>
		<td>&nbsp; </td>
		<td align="left" valign="top">
		<input type="checkbox" name="apply_rebate_rates" <cfif Form.apply_rebate_rates IS 1>checked</cfif> value="1" #FormStatus# >
		</td>
	</tr>
	</CFIF>
	</cfif>

	<!--- removed by 28113
	<tr <cfif SettingsManagerTemplate.Update_Program_Distributors_Approved_Billbacks EQ 0> style="display:none"</cfif>>
		<td align="right" nowrap valign="top"><strong>Updated Distributors on Program <br> based on Approved Billbacks</strong></td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td align="left" valign="bottom">
			<input type="checkbox" name="Update_Program_Distributors_Approved_Billbacks"  value="1" <cfif Form.Update_Program_Distributors_Approved_Billbacks>CHECKED</cfif> #FormStatus# />
		</td>
	</tr>
	--->
	<CFIF fromSettings_management eq 1>
   		<cfset SettingsTemplateForm(NameField="AutoAdd_Distributor_ThirdPartyClaims",NameFieldDesc="Update Distributors on Program based on 3<sup>rd</sup> Party Billbacks")>
  	<CFELSE>
	<tr class="settlementrules" <cfif SettingsManagerTemplate.AutoAdd_Distributor_ThirdPartyClaims EQ 0> style="display:none"</cfif>>
		<td align="right" nowrap valign="top"><strong>Update Distributors on Program based on 3<sup>rd</sup> Party Billbacks</strong></td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td align="left" valign="bottom">
			<input type="checkbox" name="AutoAdd_Distributor_ThirdPartyClaims"  value="1" <cfif Form.AutoAdd_Distributor_ThirdPartyClaims>CHECKED</cfif> #FormStatus# />
		</td>
	</tr>
	</CFIF>

	<CFIF fromSettings_management eq 1>
   		<cfset SettingsTemplateForm(NameField="Ignore_Billback_Volume_Deviation",NameFieldDesc="Ignore billback volume deviation")>
  	<CFELSE>
	<tr class="settlementrules" <cfif SettingsManagerTemplate.Ignore_Billback_Volume_Deviation EQ 0> style="display:none"</cfif>>
		<td align="right" nowrap valign="top"><strong>Ignore billback volume deviation</strong></td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td align="left" valign="bottom">
			<input type="checkbox" name="Ignore_Billback_Volume_Deviation"  value="1" <cfif Form.Ignore_Billback_Volume_Deviation>CHECKED</cfif> #FormStatus# />
		</td>
	</tr>
	</CFIF>
<!---D36368--->
	<CFIF fromSettings_management eq 1>
   		<cfset SettingsTemplateForm(NameField="Ignore_Date_Overlap_Deviation",NameFieldDesc="Ignore date overlap deviation")>
  	<CFELSE>
	<tr class="settlementrules" <cfif SettingsManagerTemplate.Ignore_Date_Overlap_Deviation EQ 0> style="display:none"</cfif>>
		<td align="right" nowrap valign="top"><strong>Ignore date overlap deviation</strong></td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td align="left" valign="bottom">
			<input type="checkbox" name="Ignore_Date_Overlap_Deviation"  value="1" <cfif Form.Ignore_Date_Overlap_Deviation eq '1'>CHECKED</cfif> #FormStatus# />
		</td>
	</tr>
	</CFIF>
<!---D36368--->
	<!---Label D36513 - TOPOP Reminder - no payment over 90 days START--->
	<CFIF fromSettings_management eq 1>
   		<cfset SettingsTemplateForm(NameField="Payment_Notification",NameFieldDesc="Payment Notification")>
	<CFELSE>
		<tr class="settlementrules" <cfif SettingsManagerTemplate.Payment_Notification EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><strong>Payment Notification</strong></td>
					<td>&nbsp; <span id="error_Payment_Notification"></span></td>
					<td>&nbsp; </td>
				<td align="left" valign="top">
				<input type="checkbox" name="Payment_Notification" <cfif Form.Payment_Notification IS 1>checked</cfif> value="1" #FormStatus# >&nbsp; &nbsp;
				<input type="text" name="Payment_Notification_Span" size="5" maxlength="10" <cfif Form.Payment_Notification_Span IS NOT 0>  value="#Form.Payment_Notification_Span#"</cfif> onKeyUp="clenseText(this, '0123456789')" #FormStatus# > Days
				</td>
			</tr>
	</CFIF>
	<!---Label D36513 - TOPOP Reminder - no payment over 90 days END --->
	<!--- XXXXXXXXXXXXXXXXXXXXXX  Miscellaneous Settings	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<tr id="miscellaneousSettings_heading"><Th colspan="100%" bgcolor="##93BEE2">Miscellaneous Settings</TH></tr>
	<cfif Generic_Type IS NOT "Brokerage" AND NOT(Generic_Type IS "LSAutoPay")>
		<!--- Payable To --->
		<CFIF fromSettings_management eq 1>
   					<cfset SettingsTemplateForm(NameField="Payable_To",NameFieldDesc="Payable To")>
  		<CFELSE>
		<tr class="miscellaneousSettings" <cfif SettingsManagerTemplate.Payable_To EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><strong>Payable To</strong></td>
				<td>&nbsp; </td>
				<td>&nbsp; </td>
			<td align="left" valign="top">
				<input type="checkbox" name="Payable_To" <cfif Form.Payable_To IS 1>checked</cfif> value="1" #FormStatus# >
				<br><input type="radio" name="Required_Payable_To" value="0" checked #FormStatus# >Not Required
				<br><input type="radio" name="Required_Payable_To" value="1" <cfif Form.Required_Payable_To IS 1>checked</cfif> #FormStatus# >Required
				<br><input type="checkbox" name="Pay_To_Distributor" value="1" <cfif Form.Pay_To_Distributor IS 1>checked</cfif> #FormStatus#> Display "Pay To Distributor"
			</td>
		</tr>
		</CFIF>
		<!--- Send Payment To --->
		<CFIF fromSettings_management eq 1>
   				<cfset SettingsTemplateForm(NameField="Send_Payment_To",NameFieldDesc="Send Payment To")>
  		<CFELSE>
		<tr class="miscellaneousSettings" <cfif SettingsManagerTemplate.Send_Payment_To EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><strong>Send Payment To</strong></td>
				<td>&nbsp; </td>
				<td>&nbsp; </td>
			<td align="left" valign="top">
				<input type="checkbox" name="Send_Payment_To" <cfif Form.Send_Payment_To IS 1>checked</cfif> value="1" #FormStatus# >
				<br><input type="radio" name="Required_Send_Payment_To" value="0" checked #FormStatus# >Not Required
				<br><input type="radio" name="Required_Send_Payment_To" value="1" <cfif Form.Required_Send_Payment_To IS 1>checked</cfif> #FormStatus#>Required
			</td>
		</tr>
		</CFIF>

		<!--- BJF 14531 Remove payee from template --->
		<!--- Customer Acceptance --->
		<CFIF fromSettings_management eq 1>
   				<cfset SettingsTemplateForm(NameField="Customer_Acceptance",NameFieldDesc="Customer Acceptance Block")>
  		<CFELSE>
		<tr class="miscellaneousSettings" <cfif SettingsManagerTemplate.Customer_Acceptance EQ 0> style="display:none"</cfif>>
			<td align="right" nowrap valign="top"><strong>Customer Acceptance Block</strong></td>
				<td>&nbsp; </td>
				<td>&nbsp; </td>
			<td align="left" valign="top">
			<input type="checkbox" name="Customer_Acceptance" <cfif Form.Customer_Acceptance IS 1>checked</cfif> value="1" #FormStatus# >
			</td>
		</tr>
		</CFIF>
	</cfif>

		<CFIF fromSettings_management eq 1>
			<cfset SettingsTemplateForm(NameField="Currency_Conversion_Factor",NameFieldDesc="Currency Conversion Factor")>
 		<CFELSE>
			<tr class="miscellaneousSettings" <cfif SettingsManagerTemplate.Currency_Conversion_Factor EQ 0> style="display:none"</cfif>>
				<td align="right" nowrap valign="top"><strong>Currency Conversion Factor</strong></td>
					<td>&nbsp; </td>
					<td>&nbsp; </td>
				<td align="left" valign="top">
				<input type="checkbox" name="Currency_Conversion_Factor" <cfif Form.Currency_Conversion_Factor IS 1>checked</cfif> value="1" #FormStatus# >
				</td>
			</tr>
		</CFIF>


	<CFIF fromSettings_management eq 1>
   		<cfset SettingsTemplateForm(NameField="Template_UPC_Display",NameFieldDesc="Display UPC")>
  	<CFELSE>
	<tr class="miscellaneousSettings" <cfif SettingsManagerTemplate.Template_UPC_Display EQ 0> style="display:none"</cfif>>
		<td align="right" nowrap valign="top"><font class="retroFieldsIndicator">*</font><strong>Display UPC</strong></td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td align="left" valign="top">
			<input type="checkbox" name="Template_UPC_Display"  value="1" <cfif Form.Template_UPC_Display>CHECKED</cfif> #FormStatus#>
		</td>
	</tr>
	</CFIF>

	<!---Equipment and Dispenser Placements--->
		<cfif Generic_Type IS NOT "Brokerage" AND NOT(Generic_Type IS "LSAutoPay") >
			<cfif appSettings.getEquipment_Placement() IS 1>
				<CFIF fromSettings_management eq 1>
   					<cfset SettingsTemplateForm(NameField="Equipment_Placement",NameFieldDesc="Equipment and Dispenser Placement")>
  				<CFELSE>
				<tr class="miscellaneousSettings" <cfif SettingsManagerTemplate.Equipment_Placement EQ 0> style="display:none"</cfif>>
					<td align="right" nowrap valign="top"><strong>Equipment and Dispenser <br>Placement</strong></td>
						<td>&nbsp; </td>
						<td>&nbsp; </td>
					<td align="left" valign="top">
					<input type="checkbox" name="Equipment_Placement" <cfif Form.Equipment_Placement IS 1>checked</cfif> value="1" #FormStatus# >
					</td>
				</tr>
				</CFIF>
			</cfif>
		</cfif>
	<!--- BSD: 11655 Added checkbox for Retail Information screen --->
	<cfif GENERIC_TYPE IS NOT "Brokerage" AND NOT(Generic_Type IS "LSAutoPay")>
		<CFIF fromSettings_management eq 1>
   			<cfset SettingsTemplateForm(NameField="Retailer_Info_On",NameFieldDesc="Retailer Information On")>
  		<CFELSE>
		<tr class="miscellaneousSettings" <cfif SettingsManagerTemplate.Retailer_Info_On EQ 0> style="display:none"</cfif>>
			<td align="right" valign="top"><strong>Retailer Information On </strong></td>
			<td>&nbsp; </td>
			<td>&nbsp; </td>
			<td align="left" valign="top">
				<input name="Retailer_Info_On" type="checkbox" value="1" <cfif form.Retailer_Info_On>checked</cfif> #FormStatus# />
			</td>
		</tr>
		</CFIF>
	</cfif>
	<cfset distributorProgram = Generic_Type IS "Distributor Off-Invoice" OR Generic_Type IS "Distributor Trade/Shelter">
		<cfif distributorProgram AND appSettings.getDisplayInterfaceFlagsSet1()>
			<CFIF fromSettings_management eq 1>
   				<cfset SettingsTemplateForm(NameField="Include_Template_In_Deals_IF",NameFieldDesc="Include in deals interface")>
  			<CFELSE>
			<tr class="miscellaneousSettings" <cfif SettingsManagerTemplate.Include_Template_In_Deals_IF EQ 0> style="display:none"</cfif>>
				<td align="right" nowrap valign="top"><font class="retroFieldsIndicator">*</font><strong>Include in deals interface</strong></td>
				<td>&nbsp; </td>
				<td>&nbsp; </td>
				<td align="left" valign="top">
				<input type="checkbox" name="Include_Template_In_Deals_IF" <cfif Form.Include_Template_In_Deals_IF IS 1>checked</cfif> value="1" #FormStatus# >
				</td>
			</tr>
			</CFIF>
		</cfif>
		<cfif appSettings.getOperatingGroupOn() AND NOT(Generic_Type IS "LSAutoPay")>
			<CFIF fromSettings_management eq 1>
   				<cfset SettingsTemplateForm(NameField="Include_Treatment_Basis_Code",NameFieldDesc="Include treatment code and basis code")>
  			<CFELSE>
			<tr class="miscellaneousSettings" <cfif SettingsManagerTemplate.Include_Treatment_Basis_Code EQ 0> style="display:none"</cfif>>
				<td align="right" nowrap valign="top"><font class="retroFieldsIndicator">*</font><strong>Include treatment code and basis code</strong></td>
				<td>&nbsp; </td>
				<td>&nbsp; </td>
				<td align="left" valign="top">
				<input type="checkbox" name="Include_Treatment_Basis_Code" <cfif Form.Include_Treatment_Basis_Code IS 1>checked</cfif> value="1" #FormStatus# >
				</td>
			</tr>
			</CFIF>
			<CFIF fromSettings_management eq 1>
   					<cfset SettingsTemplateForm(NameField="Exclude_Same_Spending_Cat_From_TPA",NameFieldDesc="Exclude same spending category programs from TPA")>
  			<CFELSE>
			<tr class="miscellaneousSettings" <cfif SettingsManagerTemplate.Exclude_Same_Spending_Cat_From_TPA EQ 0> style="display:none"</cfif>>
				<td align="right" nowrap valign="top"><font class="retroFieldsIndicator">*</font><strong>Exclude same spending category programs from TPA</strong></td>
				<td>&nbsp; </td>
				<td>&nbsp; </td>
				<td align="left" valign="top">
				<input type="checkbox" name="Exclude_Same_Spending_Cat_From_TPA" <cfif Form.Exclude_Same_Spending_Cat_From_TPA IS 1>checked</cfif> value="1" #FormStatus# >
				</td>
			</tr>
			</CFIF>
		</cfif>
	<cfif appsettings.getsysco_report_on() AND Generic_Type IS "Operator-Deviated Pricing">
		<CFIF fromSettings_management eq 1>
   				<cfset SettingsTemplateForm(NameField="Sysco_Report_ON",NameFieldDesc="Sysco Report")>
  		<CFELSE>
	<tr class="miscellaneousSettings" <cfif SettingsManagerTemplate.Sysco_Report_ON EQ 0> style="display:none"</cfif>>
		<td align="right" nowrap valign="top"><strong>Sysco Report</strong></td>
		<td>&nbsp; </td>
		<td>&nbsp; </td>
		<td align="left" valign="top" nowrap>
			<input type="checkbox" name="Sysco_Report_ON" <cfif Form.Sysco_Report_ON IS 1>checked</cfif> value="1" #FormStatus# >
		</td>
	</tr>
		</CFIF>
	</cfif>
	<cfif NOT(Generic_Type IS "LSAutoPay")>

		<!---Allow group BB's if appsetting is turned on--->
		<cfif AppSettings.GroupLevelBillback IS 1>
				<CFSET CheckThis = "">
				<CFIF FORM.GroupLevelBB EQ 1>
					<CFSET CheckThis = "Checked">
				</CFIF>
				<CFIF fromSettings_management eq 1>
   				<cfset SettingsTemplateForm(NameField="GroupLevelBB",NameFieldDesc="Group Level Billback")>
  				<CFELSE>
				<TR class="miscellaneousSettings" <cfif SettingsManagerTemplate.GroupLevelBB EQ 0> style="display:none"</cfif>>
					<TD align="right" nowrap valign="top"><B>Group Level Billback</B></TD>
					<TD>&nbsp;</TD>
					<TD>&nbsp;</TD>
					<TD align="left" valign="top"><INPUT TYPE="CheckBox" VALUE="1" NAME="GroupLevelBB" #CheckThis# #FormStatus# ></TD>
				</TR>
				</CFIF>
		</cfif>
	</cfif>

</td>
<!---End right side--->
</tr>

</table>
</td></tr>

</table>

</cfoutput>
<cfif fromSettings_management neq 1>
<cfoutput>
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Accounting Program Type /////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<br>&nbsp;
<!---Profile section--->
<cfif appSettings.getUse_Accounting_Program_Type() EQ 1>
<cfset AccountingProgramTypeManager = CreateObject("component","components.programs.Accounting_Program_Type.AccountingProgramTypeManager").init() />
&nbsp;
<!---Which accounting types go with this program?--->
<table width="90%" cellpadding="1" cellspacing="0" border="1" bordercolor="navy" align="center">
	<tr>
		<td colspan="3">
		<B>
		Program Labels
		</B>
		</td>

	</tr>
	<tr valign="top">
	<cfquery name="GetAPTsforthisTemplate" datasource="#application.datasource#">
		SELECT * FROM APT_Template_Mapping WHERE Template_ID = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">
	</cfquery>

		<td align="left" bgcolor="##eeeeee">
		&nbsp;<span id="err_Accounting_Program_Type"></span>
		<cfset GetAPTs = AccountingProgramTypeManager.getAccountingProgramTypes() />

		<cfset iMaxCols = 9>
		<table cellpadding="0" cellspacing="0" border="0"><tr>
		<cfloop query="GetAPTs">
			<cfset ShouldThisBeChecked = 0>
			<cfif action IS "Edit">

				<cfquery name="ShouldBeChecked" dbtype="query">
					SELECT * FROM GetAPTsforthisTemplate
					WHERE Accounting_Program_Type_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#GetAPTs.Accounting_Program_Type_ID#" />
				</cfquery>

				<cfif ShouldBeChecked.recordcount GT 0>
					<cfset ShouldThisBeChecked = 1>
				</cfif>
			</cfif>

			<cfparam name="Form.Accounting_Program_Type_#GetAPTs.Accounting_Program_Type_ID#" 	default="#ShouldThisBeChecked#">
			<cfset ShouldThisBeChecked = Evaluate("Form.Accounting_Program_Type_#GetAPTs.Accounting_Program_Type_ID#")>
			<td><input type="checkbox" name="Accounting_Program_Type_#GetAPTs.Accounting_Program_Type_ID#" <cfif ShouldThisBeChecked Is 1>checked</cfif> value="1" #FormStatus# > #GetAPTs.APT_Name#&nbsp; &nbsp; </td>			<!--- onpropertychange="changeDisableOtherCheckBoxes(this, this.form.Forbid_Profile_Approve_#Profiles_ID#, #forbidType#);changeDisableOtherCheckBoxes(this, this.form.Forbid_Profile_Lumpsum_#Profiles_ID#, #forbidType#);" --->
			<cfif NOT (currentRow mod iMaxCols)>
				</tr><tr>
			</tr>
			</cfif>
		</cfloop>
		</table>
		</td>

	</tr>

</table>

<!---<cfif appSettings.getUse_Accounting_Program_Type() EQ 1>--->
</cfif>

<!--- Dev Note: Milan - D6321 --->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Program Category ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<br>&nbsp;
<cfif appSettings.getProgramCategory() EQ 1>
&nbsp;
<!---Which categories go with this program?--->
<table width="90%" cellpadding="1" cellspacing="0" border="1" bordercolor="navy" align="center">


	<tr>
		<td colspan="3">
		<B>
		Program Category
		</B>
		</td>

	</tr>
	<tr valign="top">


	<cfquery name="GetCategoriesforthisTemplate" datasource="#application.datasource#">
	SELECT * FROM Category_Template_Mapping WHERE Template_ID = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">
	</cfquery>

		<td align="left" bgcolor="##eeeeee">
		&nbsp;<span id="err_Category"></span>
		<cfset useLakebaseForGetCategories = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_category")>
<cfif useLakebaseForGetCategories>
	<cftry>
		<cfset GetCategories = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_category", {
				"deleted" = "eq.0",
				"select" = "program_category_id,program_category"
			}), "program_category_id,program_category"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetCategories = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetCategories>
<cfquery name="GetCategories" datasource="#application.datasource#">
			SELECT	Program_Category_ID, Program_Category
			FROM	Program_Category
			WHERE	Deleted = 0
		</cfquery>
</cfif>

		<cfset iMaxCols = 9>
		<table cellpadding="0" cellspacing="0" border="0"><tr>
		<cfloop query="GetCategories">
			<cfset ShouldThisBeChecked = 0>
			<cfif action IS "Edit">

				<cfquery name="ShouldBeChecked" dbtype="query">
					SELECT * FROM GetCategoriesforthisTemplate
					WHERE Program_Category_ID = #GetCategories.Program_Category_ID#
					AND	Deleted = 0
				</cfquery>

				<cfif ShouldBeChecked.recordcount GT 0>
					<cfset ShouldThisBeChecked = 1>
				</cfif>

			</cfif>

			<cfparam name="Form.Program_Category_#GetCategories.Program_Category_ID#" 	default="#ShouldThisBeChecked#">
			<cfset ShouldThisBeChecked = Evaluate("Form.Program_Category_#GetCategories.Program_Category_ID#")>
			<td><input type="checkbox" name="Program_Category_#GetCategories.Program_Category_ID#" <cfif ShouldThisBeChecked Is 1>checked</cfif> value="1" #FormStatus# > #GetCategories.Program_Category#&nbsp; &nbsp; </td>
			<cfif NOT (currentRow mod iMaxCols)>
				</tr><tr>
			</tr></cfif>
		</cfloop>
		</table>
		</td>

	</tr>

</table>

</cfif>
<!--- End Note: Milan - D6321 --->

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Operating Group ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<br>&nbsp;
<cfif appSettings.getOperatingGroupOn() EQ 1>

<cfset qOperatingGroupTemplateSettings = operatingGroupManager.getOperatingGroupTemplateSettings(templateMapLevel, ID) />
<table width="90%" cellpadding="1" cellspacing="0" border="1" bordercolor="navy" align="center">
	<tr>
		<td colspan="3"><font class="requiredFieldsIndicator">*</font><B>#templateMapLevelLabel#</B>&nbsp;<span id="err_Operating_Group"></span></td>
	</tr>
	<tr valign="top">
	<td align="left" bgcolor="##eeeeee">
		<cfset iMaxCols = 5>
		<table cellpadding="0" cellspacing="0" border="0"><tr>
		<cfloop query="qOperatingGroupTemplateSettings">
			<cfparam name="Form.Operating_Group_#Operating_Group_ID#" 	default="#Template_Checked#">
			<cfset ShouldThisBeChecked = Evaluate("Form.Operating_Group_#Operating_Group_ID#")>
			<td><input type="checkbox" name="Operating_Group_#Operating_Group_ID#" <cfif ShouldThisBeChecked NEQ 0>checked</cfif> value="1" #FormStatus# > #Operating_Group_Desc#&nbsp; &nbsp; </td>
			<cfif NOT (currentRow mod iMaxCols)>
				</tr><tr>
			</tr></cfif>
		</cfloop>
		</table>
	</td>
	</tr>
</table>
&nbsp;
<br>
</cfif>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Search Sequence ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<br>&nbsp;
<cfif appSettings.getSearchSequenceOn() EQ 1>
	<cfset searchSequenceManager 			= CreateObject("component", "components.Search_Sequence.SearchSequenceManager").init() />
	<cfset qSearchSequenceTemplateSettings 	= searchSequenceManager.getSearchSequenceTemplateSettings(ID) />
	<table width="90%" cellpadding="1" cellspacing="0" border="1" bordercolor="navy" align="center">
		<tr>
			<td colspan="3"><font class="requiredFieldsIndicator">*</font><B>Search Sequence</B>&nbsp;<span id="err_Search_Sequence"></span></td>
		</tr>
		<tr valign="top">
		<td align="left" bgcolor="##eeeeee">
			<cfset iMaxCols = 5>
			<table cellpadding="0" cellspacing="0" border="0"><tr>
			<cfloop query="qSearchSequenceTemplateSettings">
				<cfparam name="Form.Search_Sequence_#Search_Sequence_ID#" 	default="#Template_Checked#">
				<cfset ShouldThisBeChecked = Evaluate("Form.Search_Sequence_#Search_Sequence_ID#")>
				<td><input type="checkbox" name="Search_Sequence_#Search_Sequence_ID#" <cfif ShouldThisBeChecked NEQ 0>checked</cfif> value="1" #FormStatus# > #Search_Sequence_Legacy# #Search_Sequence_Desc#&nbsp; &nbsp; </td>
				<cfif NOT (currentRow mod iMaxCols)>
					</tr><tr>
				</tr></cfif>
			</cfloop>
			</table>
		</td>
		</tr>
	</table>
&nbsp;
<br>
</cfif>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Business Segments ///////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<br>&nbsp;
<cfif variables.businessSegmentManager.isEnabled() and appSettings.getFilterBusinessSegments()>

	<!---Get the list of active business segments--->
	<cfset variables.qBusinessSegments			= variables.businessSegmentManager.getActiveClasscodes() />
	<cfset variables.qTemplateBusinessSegments 	= variables.businessSegmentManager.getBusinessSegmentTemplateSettings(ID) />
	<table width="90%" cellpadding="1" cellspacing="0" border="1" bordercolor="navy" align="center">
		<tr>
			<td colspan="3">
				<font class="requiredFieldsIndicator">*</font><B>#appSettings.getbusiness_segment_label()#</B>&nbsp;<span id="err_Template_Business_Segment"></span>
			</td>
		</tr>
		<tr valign="top">
			<td align="left" bgcolor="##eeeeee">
				<cfset variables.maxColSpan = 5>
				<table cellpadding="0" cellspacing="0" border="0">
					<tr>
						<cfloop query="variables.qBusinessSegments">
							<td>
								<input type="checkbox" name="Template_Business_Segment_ID" value="#Business_Segment_ID#" <cfif listFindNoCase(valueList(variables.qTemplateBusinessSegments.Business_Segment_ID), Business_Segment_ID)>checked</cfif> #FormStatus#>#Business_Unit_Desc#&nbsp; &nbsp;
							</td>
							<cfif NOT (currentRow mod variables.maxColSpan)>
								</tr><tr>
								</tr>
							</cfif>
						</cfloop>
				</table>
			</td>
		</tr>
	</table>
&nbsp;
<br>
</cfif>

&nbsp;
<br>
<BR>
<!--- Dev Note: KAL - D7952 : Lock/Unlock Template: Displaying save option if current user locks the template for editing --->
<cfif LockedBy_Current_User EQ 1>
<br>&nbsp;
<div align="center"><CF_button
			button_name		=	"save2"
			button_caption	=	"Save and Continue"
			button_action	=	"confirmCompletion(1, 'save2_table', 'save1_table');"
			button_type		=	"javascript_link"
			button_width	=	"250"
			button_color	=	"Navy"
			button_tip		=	"Save and Continue"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>	</div>
</cfif>

<input type="hidden" name="ID" value="#ID#">
<input type="hidden" name="Action" value="#Action#">
<input type="hidden" name="Generic_Type" value="#Generic_Type#">
<input type="hidden" name="Active" value="#Active#">
<input type="hidden" name="pullback_template_type" value="#pullback_template_type#">
<cfif active eq 1>
<input type="hidden" name="division" value="#form.division#" />
<input type="hidden" name="distribution_channel" value="#form.distribution_channel#" />
<input type="hidden" name="Default_rate_equal_to_zero" value="#form.Default_rate_equal_to_zero#" />    <!--- D36963 --->
</cfif>
</form>


</cfoutput>

<cfinclude template="/common_files/jQuery.cfm">
<script>
if ( $('.daterules:visible').length == 0 ) {
  $('#daterules_heading').hide();
}
if ( $('.volumerules:visible').length == 0 ) {
  $('#volumerules_heading').hide();
}
if ( $('.componentrules:visible').length == 0 ) {
  $('#componentrules_heading').hide();
}
if ( $('.recapturerules:visible').length == 0 ) {
  $('#recapturerules_heading').hide();
}
if ( $('.productAndCustomerRules:visible').length == 0 ) {
  $('#productAndCustomerRules_heading').hide();
}
if ( $('.statusrules:visible').length == 0 ) {
  $('#statusrules_heading').hide();
}
if ( $('.competitive:visible').length == 0 ) {
  $('#competitive_heading').hide();
}
if ( $('.settlementrules:visible').length == 0 ) {
  $('#settlementrules_heading').hide();
}
if ( $('.miscellaneousSettings:visible').length == 0 ) {
  $('#miscellaneousSettings_heading').hide();
}
</script>

<CFIF application.returned_customer_setting.Show_Fund_Settings EQ 1 AND application.returned_customer_setting.Upload_GL_Code EQ 1>
<SCRIPT language="JavaScript">

function isAnyARSelected()
{
	var allFisYear = "<CFOUTPUT>#ActiveFisYearList#</CFOUTPUT>";
	var SelectedAR = "";
	var AnySelectedTrue = 0;
	var FisYearArray = new Array();
	FisYearArray = allFisYear.split(",");

	for (i=0; i<FisYearArray.length; i++)
	{
		SelectedAR = "";
		SelectedAR = eval("document.all.SelectedAR_"+FisYearArray[i]+".value")
		if (SelectedAR != "")
		{
			AnySelectedTrue = 1;
			break;
		}

	}
	if (AnySelectedTrue == 1)
	{
		return true;
	}
	else
	{
		return false;
	}
}
function undoRedoAR(FY,AR,undoRedoBit)
{
	var selObj = eval("document.all.SelectedAR_"+FY)
	var delObj = eval("document.all.DeletedAR_"+FY)
	var imgObj = eval("document.all.undoRedoImg_"+FY+"_"+AR)
	//alert(imgObj)
	var arObj = eval("document.all.TD_"+FY+"_"+AR)

	var descObj = eval("document.all.TD_Desc_"+FY+"_"+AR)

	var finalValue,deleteHigh,selFinalValue;
	if (undoRedoBit == 1)
	{
		undoRedoBit = 0;
		selFinalValue = DeleteThis(selObj.value,",",AR)
		finalValue = ListAppendItem(delObj.value,",",AR)
		imgObj.innerHTML = "<A HREF=\"Javascript: undoRedoAR("+FY+","+AR+","+undoRedoBit+")\"><img src='/images/undo.gif' title='Restore this AR.' border='0'></A>";
		arObj.style.textDecoration = "line-through";
		descObj.style.textDecoration = "line-through";
	}
	else
	{
		undoRedoBit = 1;
		selFinalValue = ListAppendItem(selObj.value,",",AR)
		finalValue = DeleteThis(delObj.value,",",AR)
		imgObj.innerHTML = "<A HREF=\"Javascript: undoRedoAR("+FY+","+AR+","+undoRedoBit+")\"><img src='/Images/scissor.gif' width='14' height='9' title='Delete this AR.' border='0'></A>";
		arObj.style.textDecoration = "none";
		descObj.style.textDecoration = "none";
	}
	selObj.value = selFinalValue;
	delObj.value = finalValue;
	//alert(eval("document.all.DeletedAR_"+FY+".value"))

}

function DeleteThis(sList, delimiter, deleteItem)
{
	var resultString = sList;
	var Arr = sList.split(delimiter);
	var i, arrLen;
	arrLen = Arr.length;
	for(i=0;i<arrLen;i++)
	{
		if(trim(Arr[i]) == deleteItem)
		{
			Arr.splice(i, 1);
			resultString = Arr.join(delimiter);
			return trim(resultString);
		}
	}
	return resultString;
}
</SCRIPT>
</CFIF>
<!--- Passing the divName now to make this function generic --->
<script>
function getRadioVal(RadioN) {
	var radioVal = $("input[type='radio'][name='Auto_Volume']:checked").val();
	return radioVal;
}

function handleOptions(isChecked,divName)
{
	if (isChecked)
		document.all.item(divName).className = 'showOptions';
	else
		document.all.item(divName).className = 'hideOptions';

}
</script>
</cfif> <!--- end :: cfif fromSettings_management neq 1 :: 2--->

<!--- D38942 :: Program Blackout Period on Frontend--->
<script>
	function show(id1, id2){
		<cfif fromSettings_management neq 1 AND SettingsManagerTemplate.start_zero>
			document.getElementById(id1).style.display='block';
		</cfif>
		<cfif fromSettings_management neq 1 AND SettingsManagerTemplate.future_zero>
			document.getElementById(id2).style.display='block';
		</cfif>
	}
	function hide(id1, id2){
		document.getElementById(id1).style.display='none';
		document.getElementById(id2).style.display='none';
	}
</script>
<!--- D38942 :: Program Blackout Period on Frontend--->


<cffunction name="SettingsTemplateForm">
	<cfargument name="NameField" type="string" required="true" default="">
	<cfargument name="NameFieldDesc" type="string" required="true" default="">

	<cfoutput>
		<tr>
			<td align="right" nowrap valign="top"><strong>#arguments.NameFieldDesc#</strong></td>
			<td align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="#arguments.NameField#" value="1" id="#arguments.NameField#_1" <cfif templateSettings[arguments.NameField] EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="#arguments.NameField#" value="0" id="#arguments.NameField#_0" <cfif templateSettings[arguments.NameField] EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</td>
			<cfif strException_Active[arguments.NameField] EQ 0>
				<cfset LinkExceptions = "Select Exceptions">
			<cfelse>
				<cfset LinkExceptions = "Update Exceptions">
			</cfif>
			<td>
				<CF_smallLink
					title = "#LinkExceptions#"
					url = "##"
					parameters = "onClick=""javascript: return AddExceptions('#Generic_Type#','#SettingIDs[arguments.NameField]#','#arguments.NameField#');"""
				>
				<span id="picon_#SettingIDs[arguments.NameField]#"></span>
				<font>&nbsp;</font>
			</td>
  		</tr>
	</cfoutput>
</cffunction>
