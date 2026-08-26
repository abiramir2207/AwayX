<!---Update everything with the universal information--->
<!---General updated settings--->
<cfparam name="Last_Changed_Date" 						default="#now()#">
<cfparam name="Last_Changed_User_ID" 					default="#request.AccessStructure.User_ID#">
<!---Above are updated in without a "where" statement--->

<cfquery name="GetAllProfiles" datasource="#application.datasource#">
    SELECT Profiles_ID
    FROM Profiles
    WHERE Deleted = 0
	<!--- Dev Note: drachala; D28010: Profile Setting modifications
	What For: Check weather user selected any profiles if so we run Query OF Query on getprofiles query.--->
	<cfif isdefined("url.profile_id") AND len(url.profile_id) GT 0>
	AND Profiles_id IN ( <cfqueryparam value="#trim(url.profile_id)#" cfsqltype="CF_SQL_INTEGER" list="yes"	/>	)
	</cfif>
	<!--- End Dev Note: drachala; D28010: Profile Setting modifications  --->
    <cfif UserSetting.Settings_Panel LT 5>
    	AND Profiles_id NOT IN (select distinct  Profiles_ID from Profiles_Settings where Settings_Panel = 5 and Profiles_Settings.deleted = 0)
    </cfif>
    ORDER BY Profiles_ID
</cfquery>

<cfscript>
	templateManager = CreateObject("component", "components.programs.template.TemplateManager").init();
	oProfiles = CreateObject("component", "components.settings.profiles.profile");
	// <!--- Create object to use for creating the XML log. --->
	createLog = createObject("component", "components.settings.AuditTrail.AuditTrail").init();
</cfscript>

<cfloop query="GetAllProfiles">
	<!---loopCount now equals the profile ID--->
	<cfset loopCount = GetAllProfiles.profiles_id>

	<!---Per profile settings--->
	<cfparam name="form.Cont_Prog_Approval_Rights_#loopCount#" 					default="0">
	<cfparam name="form.Prevent_short_cut_routing_#loopCount#" 					default="0">  <!---D39479 :: Short Cut Routing profile switch --->
	<cfparam name="form.Limited_Revise_#loopCount#"								default="0">  <!---D38941 :: New Limited User Profile Edit Functionality --->
	<cfparam name="form.Approve_Pullback_#loopCount#" 							default="0"> <!--- Dev Note: DRK 9326 --->
	<cfparam name="form.Approve_All_Products_Program_#loopCount#" 				default="0">
	<cfparam name="form.Approve_Revision_Types_A_#loopCount#"	 				default="0">
	<cfparam name="form.Approve_Revision_Types_B_#loopCount#"	 				default="0">
	<cfparam name="form.Approve_Revision_Types_C_#loopCount#"	 				default="0">
	<cfparam name="form.Approve_Growth_Programs_#loopCount#" 					default="0">
	<cfparam name="form.Approve_Upfront_Payments_#loopCount#" 					default="0">
	<cfparam name="form.Cont_Prog_View_Margins_#loopCount#" 					default="0">
	<cfparam name="form.Cont_Prog_View_Approved_Margins_#loopCount#" 			default="0">
	<cfparam name="form.Cont_Prog_View_Brokerage_Margins_#loopCount#" 			default="0">
	<cfparam name="form.Cont_Prog_View_Create_Program_#loopCount#" 				default="0">
	<cfparam name="form.Approve_Duplicate_Programs_#loopCount#" 				default="0">
	<cfparam name="form.Approve_Sysco_Deals_#loopCount#" 						default="0">
	<cfparam name="form.Reassign_Program_Access_#loopCount#" 					default="0">
	<cfparam name="form.Special_Price_List_Access_#loopCount#" 					default="0">
	<cfparam name="form.Reimbursement_Update_#loopCount#" 						default="0">
	<cfparam name="form.RFA_Agreed_#loopCount#" 								default="0">
	<cfparam name="form.View_Broker_List_#loopCount#" 							default="0">
	<cfparam name="form.Commodity_Settings_#loopCount#" 						default="0">
	<cfparam name="form.Commodity_Price_Rule_View_#loopCount#" 					default="0">
	<cfparam name="form.Commodity_Price_Rule_Create_Edit_#loopCount#" 			default="0">
	<cfparam name="form.Report_Scheduler_#loopCount#" 							default="0">
	<cfparam name="form.Settings_Panel_#loopCount#" 							default="0">
	<cfparam name="form.PM_Access_#loopCount#" 									default="0">
	<!---BJF D10010 Client Work Request --->
	<cfparam name="form.Submit_Work_Request_#loopCount#" 						default="0">
	<cfparam name="form.Reassign_Project_Access_#loopCount#" 					default="0">
	<cfparam name="form.Clause_Library_Access_#loopCount#" 						default="0">
	<cfparam name="form.Clause_Program_Edit_Remove_#loopCount#" 				default="0">
	<cfparam name="form.program_margin_approval_method_#loopCount#"				default="0">
	<cfparam name="form.Approve_Group_Deals_#loopCount#"						default="0">
	<cfparam name="form.Mass_RFA_Program_Approve_#loopCount#" 					default="0">
	<cfparam name="form.Approve_Below_Floor_#loopCount#" 						default=0>
	<cfparam name="form.Approve_Below_Floor_Amount_#loopCount#" 				default="0">
	<cfparam name="form.Approve_Equipment_Placement_#loopCount#"				default="0">
	<cfparam name="form.Approve_Roll_Over_Programs_#loopCount#"					default="0">
	<cfparam name="form.Read_Only_Catalog_Access_#loopCount#"					default="0">
	<cfparam name="form.Max_Approval_Volume_#loopCount#"						default="0">
	<cfparam name="form.Max_Approval_Volume_Uom_#loopCount#"					default="0">
	<cfparam name="form.Min_Approval_Volume_#loopCount#"						default="0">
	<cfparam name="form.Min_Approval_Volume_Uom_#loopCount#"					default="0">
	<cfparam name="form.Margin_Display_UOM_LB_#loopCount#"						default="0">
	<cfparam name="form.Margin_Display_UOM_CS_#loopCount#"						default="0">
	<cfparam name="form.Margin_Display_UOM_EQ_#loopCount#"						default="0">
	<cfparam name="form.Margin_Target_Variation_#loopCount#"					default="0">
	<cfparam name="form.Max_Opr_Margin_#loopCount#"								default="0">
	<cfparam name="form.View_Operating_Income_#loopCount#"						default="0">
	<cfparam name="form.View_Cost_#loopCount#"									default="0">
	<cfparam name="form.View_Target_Margins_#loopCount#"						default="0">
	<cfparam name="form.View_Additional_Margins_Targets_#loopCount#"						default="0"><!---76537--->
	<cfparam name="form.Base_View_#loopCount#"									default="0">
	<cfparam name="form.Lumpsum_Approval_Amount_#loopCount#"					default="0">
	<cfparam name="form.Max_Net_Sales_Dollar_#loopCount#"						default="*">
	<cfif  appSettings.getApproveLSComponentByProfile() EQ 0>
	<cfparam name="form.Total_LS_Approval_Amount_#loopCount#"					default="0">
	<cfparam name="form.Inactive_LS_Approval_Amount_#loopCount#"				default="0">
	<cfparam name="form.Lump_Sum_Approval_Amount_#loopCount#"					default="0">
	</cfif>
	<cfparam name="form.Approve_Beyond_Annual_Case_Rate_#loopCount#"			default="0">
	<cfparam name="form.Approve_Lumpsum_#loopCount#"							default="0">
	<cfparam name="form.Program_Scorecard_Restrict_Created_By_#loopCount#"		default="0">
	<cfparam name="form.Access_Price_List_#loopCount#"							default="0">
	<cfparam name="form.Executive_Agreement_#loopCount#"						default="0">
	<cfparam name="form.Delete_Program_Access_#loopCount#"						default="0">
	<cfparam name="form.See_Awarded_In_Catalog_#loopCount#"						default="0">
	<cfparam name="form.View_TPA_#loopCount#"									default="0">
	<cfparam name="form.View_Net_Sales_#loopCount#"								default="0">
	<cfparam name="form.Approve_Zero_Product_Cost_#loopCount#"					default="0">
	<cfparam name="form.Approve_Zero_Product_Price_#loopCount#"					default="0">
	<cfparam name="form.Show_Trade_Checkbook_#loopCount#"						default="0">

	<!---Above are verified as actually being used--->
	<!---Below don't seem to show up in pages--->
	<cfparam name="form.Cont_Prog_Minimum_Lineitem_Margin_#loopCount#" 			default="0">
	<cfparam name="form.Cont_Prog_Maximum_Lineitem_Margin_#loopCount#" 			default=0>
	<cfparam name="form.Pay_Bill_Approval_Rights_#loopCount#" 					default="0">
	<cfparam name="form.Pay_Bill_Minimum_Aggregate_Deviation_#loopCount#" 		default="0">
	<cfparam name="form.Pay_Bill_Maximum_Aggregate_Deviation_#loopCount#" 		default="0">
	<cfparam name="form.Pay_Bill_View_Expected_Rate_#loopCount#" 				default="0">
	<cfparam name="form.Pay_Ded_Approval_Rights_#loopCount#" 					default="0">
	<cfparam name="form.Pay_Ded_Minimum_Deduction_Amount_#loopCount#" 			default="0">
	<cfparam name="form.Pay_Ded_Maximum_Deduction_Amount_#loopCount#" 			default="0">
	<cfparam name="form.Pda_Download_#loopCount#" 								default="0">
	<cfparam name="form.Rep_Run_Reports_#loopCount#" 							default="0">
	<cfparam name="form.Com_Tools_CreateEdit_Pricing_Formula_#loopCount#" 		default="0">
	<cfparam name="form.Com_Tools_View_Pricing_Formula_#loopCount#" 			default="0">
	<cfparam name="form.Com_Tools_View_Market_Data_#loopCount#" 				default="0">
	<cfparam name="form.Use_Set_User_Password_#loopCount#" 						default="0">
	<cfparam name="form.Use_Set_Email_Message_#loopCount#" 						default="0">
	<cfparam name="form.Use_Set_Tickler_#loopCount#" 							default="0">
	<cfparam name="form.Comm_Fax_#loopCount#" 									default="0">
	<cfparam name="form.Comm_Email_#loopCount#" 								default="0">
	<cfparam name="form.Comm_Print_#loopCount#" 								default="0">
	<cfparam name="form.Admin_Data_Purging_#loopCount#" 						default="0">
	<cfparam name="form.Admin_Data_Exceptions_#loopCount#" 						default="0">
	<cfparam name="form.Admin_Data_Integ_Schedule_#loopCount#" 					default="0">
	<cfparam name="form.Admin_Profile_Maintenance_#loopCount#" 					default="0">
	<cfparam name="form.Admin_AddDelete_Users_#loopCount#" 						default="0">
	<cfparam name="form.Ctr_Pnl_Programs_#loopCount#" 							default="0">
	<cfparam name="form.Ctr_Pnl_Payables_#loopCount#" 							default="0">
	<cfparam name="form.Ctr_Pnl_Commod_Pricing_#loopCount#" 					default="0">
	<cfparam name="form.Admin_Control_Panels_#loopCount#" 						default="0">
	<cfparam name="form.Geographic_Access_#loopCount#" 							default="0">
	<cfparam name="form.Deduction_Analyst_#loopCount#" 							default="0">
	<cfparam name="form.Fund_Setting_Access_#loopCount#" 						default="0">
	<cfparam name="form.Payment_Processor_#loopCount#" 							default="0">
	<cfparam name="form.Reports_Access_Level_#loopCount#" 						default="0">
	<cfparam name="form.Create_Operator_Access_#loopCount#" 					default="0">
	<cfparam name="form.Max_Program_Spend_#loopCount#" 							default="*">
	<cfparam name="form.Internal_Notes_#loopCount#" 							default="0">
	<cfparam name="form.PAYMENT_HISTORY_ALERT_#loopCount#" 						default="0">
	<cfparam name="form.View_Invoices_#loopCount#" 								default="0">
	<cfparam name="form.Install_Patch_#loopCount#" 								default="0">
	<cfparam name="form.ReleaseSettlement_#loopCount#"							default="0">
	<cfparam name="form.Approve_Export_Agreements_#loopCount#"					default="0">
	<cfparam name="form.Create_Export_Agreements_#loopCount#"					default="0">
	<cfparam name="form.Create_Approve_Export_Agreements_#loopCount#"			default="0">
	<cfparam name="form.Create_New_Export_Customer_#loopCount#"					default="0">
	<cfparam name="form.Credit_Manager_#loopCount#"								default="0">
	<cfparam name="form.Create_Budget_#loopCount#"								default="0">
	<cfparam name="form.Approve_Pgm_Beyond_Budget_#loopCount#"					default="0">
	<cfparam name="form.Freight_View_Create_#loopCount#"						default="0">
	<cfparam name="form.Approve_Freight_Programs_#loopCount#"					default="0">
	<cfparam name="form.Approve_Freight_Adjustment_Programs_#loopCount#"		default="0">
	<cfparam name="form.Search_Documents_#loopCount#"							default="0">
	<cfparam name="form.View_Private_Documents_#loopCount#"						default="0">
	<cfparam name="form.View_Prog_In_Duplicate_Check_Window_#loopCount#"		default="0">
	<cfparam name="form.Volume_Details_Tab_Display_#loopCount#"					default="0">
	<cfparam name="form.View_LH_Pane_Budget_Link_#loopCount#"					default="0">
	<cfparam name="form.Market_Price_Variance_#loopCount#"						default="0">
	<cfparam name="form.Delete_Pages_Program_Letter_#loopCount#"				default="0">
	<cfparam name="form.View_Workflow_Report_Data_#loopCount#"					default="0">
	<cfparam name="form.search_inactive_products_programs_#loopCount#"			default="0">   <!---26199--->
	<cfparam name="form.Search_Inactive_Distributors_Programs_#loopCount#"		default="0">   <!---26199--->
	<cfparam name="form.Search_Inactive_Operators_Programs_#loopCount#"			default="0">   <!---26199--->
	<cfparam name="form.Re_instate_deleted_programs_#loopCount#"				default="0">   		 <!---26488--->
	<cfparam name="form.EzButton_Approve_Beyond_MaxRate_#loopCount#"			default="0">	<!--- 25709: EZ Button ---->
	<cfparam name="form.Volume_Forecast_#loopCount#"							default="0">
	<cfparam name="form.Edit_Price_Bracket_#loopCount#"							default="0">	<!--- 27180 ---->
	<cfparam name="form.Generate_Program_letters_#loopCount#"					default="0">
	<cfparam name="form.Dashboard_UOM_#loopCount#"								default="0"><!--- D29929: Dashboard Settings --->
	<cfparam name="form.Dashboard_Remote_Access_#loopCount#"					default="0"><!--- D29929: Dashboard Settings --->
	<cfparam name="form.Edit_Product_MasterData_#loopCount#"					default="0">
	<cfparam name="form.Budgets_Actual_Adjustment_#loopCount#"					default="0"><!--- D33473:Budget Actual Adjustments  --->
	<cfparam name="form.Create_Budget_Forecast_#loopCount#"						default="0"><!--- D64200 :: Create new accrual budget forecast process  --->
	<cfparam name="form.ProgramView_WIPPositionsBelowMe_#loopCount#"			default="0"><!---33158 - WIP below me --->
	<cfparam name="form.Edit_Volume_FC_Below_Me_#loopCount#"					default="0"><!---35751--->
	<cfparam name="form.Profitability_Model_#loopCount#"						default="0"><!---D36549 --->
	<cfparam name="form.Redistribution_#loopCount#"								default="0"><!---D39875 --->
	<cfparam name="form.Re_instate_deleted_billbacks_#loopCount#"				default="0"><!---D40664 :: Settings page to show Deleted Billbacks --->
	<cfparam name="form.Message_Center_Viewing_#loopCount#"						default="0"><!---D41568 --->
	<cfparam name="form.Message_Center_Administration_#loopCount#"				default="0"><!---D41568 --->
	<cfparam name="form.Competitive_Info_not_required_#loopCount#" 				default="0">  <!---D42287 :: Competitive Info not required by User Profile --->
	<cfparam name="form.View_LH_Pane_Recapture_Link_#loopCount#" 				default="0">  <!---D44346 :: Adding Recapture Link for user profile --->
	<cfparam name="form.View_LH_pane_Vertical_P_L_#loopCount#" 					default="0">
	<cfparam name="form.View_LH_pane_What_If_P_L_#loopCount#" 					default="0">
	<cfparam name="form.Browse_BBDoc_Server_Files_#loopCount#" 					default="0">
	<cfparam name="form.Mass_Change_Program_Date_#loopCount#" 					default="0">
	<cfparam name="form.What_If_From_Scratch_#loopCount#" 						default="0">
	<cfparam name="form.Manually_Select_Approvers_#loopCount#"					default="0">  <!--- 47065: Change Order Program Approvals --->
	<cfparam name="form.Vendor_Hold_Research_#loopCount#" 						default="0">
	<cfparam name="form.Modify_Expired_Programs_#loopCount#" 					default="0"><!--- D50074 :: Viewing and Editing prior program versions --->
	<cfparam name="form.manual_reject_billback_#loopCount#" 					default="0">   <!--- 55551 --->
	<cfparam name="form.View_LH_Pane_Duplicate_Checker_Link_#loopCount#" 		default="0">   <!--- 56440 --->
	<cfparam name="form.Modify_Vendors_VendorManagement_#loopCount#" 			default="0"> <!--- D57447 :: Create and modify vendor records  --->
	<cfparam name="form.Best_Plan_Program_#loopCount#" 							default="0"><!--- D66995 :: Rework - Best Plans --->
	<cfparam name="form.Analytics_SSO_#loopCount#" 					default="0"><!--- 71460:: - Analytics SSO --->
	<!---Param everything so all fields have values--->
	<cfparam name="form.Max_Approval_Annual_Volume_#loopCount#"							default="0"> <!--- 72497 --->
	<cfparam name="form.Max_Approval_Annual_Volume_Uom_#loopCount#"							default="0">
    <cfparam name="form.Upload_Programs_#loopCount#"							default="0"><!--- D81335 --->
    <cfparam name="form.RFP_Freight_View_Create_#loopCount#"					default="0">
    <cfparam name="form.RFP_Freight_FOB_Delivered_View_Create_#loopCount#"					default="0">
    <cfparam name="form.DoubleDipReport_#loopCount#"							default="0"><!--- D103971 --->
    <cfparam name="form.RFP_Page_Edit_RFA_#loopCount#"							default="0">

	<!---Should we update floor pricing or not?--->
	<cfparam name="form.Ember_Access_#loopCount#" 					default="0"><!--- 76021 --->


	<cfscript>
		param name="form.View_Margin_Percent_#loopCount#" default="0";
		param name="form.View_Target_NUC_#loopCount#"     default="0";
		param name="form.View_NUC_#loopCount#"            default="0";
		param name="form.View_Target_NUC_Var_#loopCount#" default="0";

		genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init();
		appSettings = application.appSettingsGet;
	</cfscript>


	<cftransaction>

	<CFQUERY NAME="getLSValues" DATASOURCE="#application.datasource#">
	    SELECT Profiles_Desc, ps.*
		FROM Profiles_Settings  ps
		INNER JOIN Profiles p on ps.profiles_id  = p.profiles_id 
		WHERE ps.Profiles_ID = #loopCount# AND ps.deleted = 0 and p.deleted = 0
	</CFQUERY>
	<!--- USED FOR AUDITING - GET Current data --->
	<cfset variables.qOriginal = getLSValues>

	 <CFQUERY NAME="Save_Data" DATASOURCE="#application.datasource#">
		DELETE
		FROM		Profiles_Settings
		WHERE		Profiles_ID = #loopCount#;

		INSERT INTO
		Profiles_Settings
		(	Profiles_ID,
			Cont_Prog_Approval_Rights,
			Approve_Pullback,
			Approve_All_Products_Program,
			Approve_Revision_Types_A,
			Approve_Revision_Types_B,
			Approve_Revision_Types_C,
			Cont_Prog_View_Margins,
			Cont_Prog_View_Approved_Margins,
			Cont_Prog_View_Brokerage_Margins,
			Cont_Prog_View_Create_Program,
			Approve_Duplicate_Programs,
			Approve_Sysco_Deals,
			Reassign_Program_Access,
			Special_Price_List_Access,
			Reimbursement_Update,
			RFA_Agreed,
			View_Broker_List,
			Commodity_Settings,
			Commodity_Price_Rule_View,
			Commodity_Price_Rule_Create_Edit,
			Report_Scheduler,
			Settings_Panel,
			PM_Access,
			Submit_Work_Request,
			Reassign_Project_Access,
			Clause_Library_Access,
			Clause_Program_Edit_Remove,
			program_margin_approval_method,
			Approve_Group_Deals,
			Mass_RFA_Program_Approve,
			Approve_Growth_Programs,
			Approve_Upfront_Payments,
			<CFIF application.returned_customer_setting.Show_Fund_Settings EQ 1>
			Fund_Setting_Access,
			</CFIF>
			<cfif appSettings.getFloorPrice() IS 1>
			Approve_Below_Floor,
			Approve_Below_Floor_Amount,</cfif>
			Approve_Equipment_Placement,
			Approve_Roll_Over_Programs,
			Read_Only_Catalog_Access,
			Max_Approval_Volume,
			Max_Approval_Volume_Uom,
			Min_Approval_Volume,
			Min_Approval_Volume_Uom,
			Margin_Display_UOM_LB,
			Margin_Display_UOM_CS,
			Margin_Display_UOM_EQ,
			Margin_Target_Variation,
  			Max_Net_Sales_Dollar,
			Max_Opr_Margin,
			View_Target_Margins,
			View_Additional_Margins_Targets,<!---76537 :: Margin analysis to various targets--->
			View_Cost,
			View_Operating_Income,
			Base_View,
			Total_LS_Approval_Amount,<!--- From the query above --->
			Inactive_LS_Approval_Amount,<!--- From the query above --->
			Lump_Sum_Approval_Amount,<!--- From the query above --->
			Approve_Lumpsum,
			Approve_Beyond_Annual_Case_Rate,
			Program_Scorecard_Restrict_Created_By,
			Access_Price_List,
			Executive_Agreement,
			Delete_Program_Access,
			See_Awarded_In_Catalog,
			Lumpsum_Approval_Amount,
			Payment_Processor,
			Reports_Access_Level,
			Create_Operator_Access,
			Max_Program_Spend,
			Internal_Notes,
			Payment_History_Alert,
			View_TPA,
			View_Net_Sales,
			Approve_Zero_Product_Cost,
			Approve_Zero_Product_Price,
			Show_Trade_Checkbook,
			View_Invoices,
			Install_Patch,
			Create_Budget,
			Approve_Pgm_Beyond_Budget
			<cfif appSettings.getReleaseSettlement()>
			,Release_Settlement
			</cfif>
			<cfif appSettings.getShow_Fixed_Freight()>
			,Freight_View_Create
			,Approve_Freight_Programs
			,Approve_Freight_Adjustment_Programs
			</cfif>
			<!--- (Start) Only if the Export Program App Setting is turned on --->
			<cfif appSettings.getShowExportPrograms() >
			,Approve_Export_Agreements
			,Create_Export_Agreements
			,Create_Approve_Export_Agreements
			,Create_New_Export_Customer
			,Credit_Manager
			</cfif>
			<!--- (End) Only if the Export Program App Setting is turned on --->
			,Search_Documents
  			,View_Private_Documents
			,View_Prog_In_Duplicate_Check_Window
  			,Volume_Details_Tab_Display
  			,View_LH_Pane_Budget_Link
  			,Market_Price_Variance
				,Delete_Pages_Program_Letter
			,View_Workflow_Report_Data
			,Search_Inactive_Products_Programs       <!---26199 settings for searching inactive items --->
			,Search_Inactive_Distributors_Programs   <!---26199--->
			,Search_Inactive_Operators_Programs      <!---26199--->
			,Re_instate_deleted_programs
			,EzButton_Approve_Beyond_MaxRate <!--- 25709: EZ Button --->
			,Volume_Forecast
			,Edit_Price_Bracket
			,Generate_Program_letters
			,Dashboard_UOM<!--- D29929: Dashboard Settings --->
			,Dashboard_Remote_Access<!--- D29929: Dashboard Settings --->
			,Edit_Product_MasterData
			,Budgets_Actual_Adjustment <!--- D33473:Budget Actual Adjustments --->
			,Budget_Forecast<!---D64200 :: Create new accrual budget forecast process --->
			,ProgramView_WIPPositionsBelowMe
			,Edit_Volume_FC_Below_Me
			,Profitability_Model<!--- D36549 --->
			,Prevent_short_cut_routing<!---D39479 :: Short Cut Routing profile switch --->
			,Limited_Revise <!---D38941 :: New Limited User Profile Edit Functionality --->
			,Redistribution<!---D39875 --->
			,Re_instate_deleted_billbacks <!---D40664 :: Settings page to show Deleted Billbacks --->
			,Message_Center_Viewing
			,Message_Center_Administration
			,Competitive_Info_not_required <!---D42287 :: Competitive Info not required by User Profile --->
			,View_LH_Pane_Recapture_Link <!---D44346 :: Adding Recapture Link for user profile --->
			,View_LH_pane_Vertical_P_L
			,View_LH_pane_What_If_P_L
			,Browse_BBDoc_Server_Files
			,Mass_Change_Program_Date <!--- 44077: User can modify program date after program approval from the settings panel --->
			,What_If_From_Scratch
			,Manually_Select_Approvers <!--- 47065: Change Order Program Approvals --->
			,Vendor_Hold_Research
			,Modify_Expired_Programs<!---D50074 :: Viewing and Editing prior program versions --->
			,Manual_Reject_Billback
			,View_LH_Pane_Duplicate_Checker_Link
			,Modify_Vendors_VendorManagement <!--- D57447 :: Create and modify vendor records  --->
			,Best_Plan_Program<!--- D66995 :: Rework - Best Plans --->
			,Analytics_SSO<!--- 71460:: - Analytics SSO --->
			,Max_Approval_Annual_Volume<!--- 72497 --->
			,Max_Approval_Annual_Volume_UOM <!--- 72497 --->
			,Ember_Access<!---76021--->
			,Upload_Programs <!--- 81335 --->
			,Planning_Groups_Create
            ,RFP_Freight_View_Create
            ,RFP_Freight_FOB_Delivered_View_Create
			,DoubleDipReport
            ,RFP_Page_Edit_RFA
		)
		VALUES
		(
			#loopCount#,
			'#form[ "Cont_Prog_Approval_Rights_" & loopCount ]#',
			'#form[ "Approve_Pullback_" & loopCount ]#',
			'#form[ "Approve_All_Products_Program_" & loopCount ]#',
			'#form[ "Approve_Revision_Types_A_" & loopCount ]#',
			'#form[ "Approve_Revision_Types_B_" & loopCount ]#',
			'#form[ "Approve_Revision_Types_C_" & loopCount ]#',
			'#form[ "Cont_Prog_View_Margins_" & loopCount ]#',
			'#form[ "Cont_Prog_View_Approved_Margins_" & loopCount ]#',
			'#form[ "Cont_Prog_View_Brokerage_Margins_" & loopCount ]#',
			'#form[ "Cont_Prog_View_Create_Program_" & loopCount ]#',
			'#form[ "Approve_Duplicate_Programs_" & loopCount ]#',
			'#form[ "Approve_Sysco_Deals_" & loopCount ]#',
			'#form[ "Reassign_Program_Access_" & loopCount ]#',
			'#form[ "Special_Price_List_Access_" & loopCount ]#',
			'#form[ "Reimbursement_Update_" & loopCount ]#',
			'#form[ "RFA_Agreed_" & loopCount ]#',
			'#form[ "View_Broker_List_" & loopCount ]#',
			'#form[ "Commodity_Settings_" & loopCount ]#',
			'#form[ "Commodity_Price_Rule_View_" & loopCount ]#',
			'#form[ "Commodity_Price_Rule_Create_Edit_" & loopCount ]#',
			'#form[ "Report_Scheduler_" & loopCount ]#',
			'#form[ "Settings_Panel_" & loopCount ]#',
			'#form[ "PM_Access_" & loopCount ]#',
			'#form[ "Submit_Work_Request_" & loopCount ]#',
			'#form[ "Reassign_Project_Access_" & loopCount ]#',
			'#form[ "Clause_Library_Access_" & loopCount ]#',
			'#form[ "Clause_Program_Edit_Remove_" & loopCount ]#',
			'#form[ "program_margin_approval_method_" & loopCount ]#',
			'#form[ "Approve_Group_Deals_" & loopCount ]#',
			'#form[ "Mass_RFA_Program_Approve_" & loopCount ]#',
			'#form[ "Approve_Growth_Programs_" & loopCount ]#',
			'#form[ "Approve_Upfront_Payments_" & loopCount ]#',
			<CFIF application.returned_customer_setting.Show_Fund_Settings EQ 1>
			'#form[ "Fund_Setting_Access_" & loopCount ]#',
			</CFIF>
			<cfif appSettings.getFloorPrice() IS 1>
				<cfif form[ "Approve_Below_Floor_" & loopCount ] IS 0>
					0,
				<cfelseif form[ "Approve_Below_Floor_" & loopCount ] IS "0.000">
					1,
				<cfelse>
					'#form[ "Approve_Below_Floor_" & loopCount ]#',
				</cfif>
				'#form["Approve_Below_Floor_Amount_" & loopCount ]#',
			</cfif>
			'#form[ "Approve_Equipment_Placement_" & loopCount ]#',
			'#form[ "Approve_Roll_Over_Programs_" & loopCount ]#',
			'#form[ "Read_Only_Catalog_Access_" & loopCount ]#',
			'#form[ "Max_Approval_Volume_" & loopCount ]#',
			'#form[ "Max_Approval_Volume_Uom_" & loopCount ]#',
			'#form[ "Min_Approval_Volume_" & loopCount ]#',
			'#form[ "Min_Approval_Volume_Uom_" & loopCount ]#',
			'#form[ "Margin_Display_UOM_LB_" & loopCount ]#',
			'#form[ "Margin_Display_UOM_CS_" & loopCount ]#',
			'#form[ "Margin_Display_UOM_EQ_" & loopCount ]#',
			'#form[ "Margin_Target_Variation_" & loopCount ]#',
			'#form[ "Max_Net_Sales_Dollar_" & loopCount ]#',
			'#form[ "Max_Opr_Margin_" & loopCount ]#',
			'#form[ "View_Target_Margins_" & loopCount ]#',
			'#form[ "View_Additional_Margins_Targets_" & loopCount ]#',<!---76537--->
			'#form[ "View_Cost_" & loopCount ]#',
			'#form[ "View_Operating_Income_" & loopCount ]#',
			'#form[ "Base_View_" & loopCount ]#',
			<cfif  appSettings.getApproveLSComponentByProfile() EQ 0>
				'#form[ "Total_LS_Approval_Amount_" & loopCount ]#',
				'#form[ "Inactive_LS_Approval_Amount_" & loopCount ]#',
				'#form[ "Lump_Sum_Approval_Amount_" & loopCount ]#',
			<cfelse>
				'#getLSValues.Total_LS_Approval_Amount#',<!--- From the query above --->
				'#getLSValues.Inactive_LS_Approval_Amount#',<!--- From the query above --->
				'#getLSValues.Lump_Sum_Approval_Amount#',<!--- From the query above --->
			</cfif>
			'#form[ "Approve_Lumpsum_" & loopCount ]#',
			'#form[ "Approve_Beyond_Annual_Case_Rate_" & loopCount ]#',
			'#form[ "Program_Scorecard_Restrict_Created_By_" & loopCount ]#',
			'#form[ "Access_Price_List_" & loopCount ]#',
			'#form[ "Executive_Agreement_" & loopCount ]#',
			'#form[ "Delete_Program_Access_" & loopCount ]#',
			'#form[ "See_Awarded_In_Catalog_" & loopCount ]#',
			'#form[ "Lumpsum_Approval_Amount_" & loopCount ]#',
			'#form[ "Payment_Processor_" & loopCount ]#',
			'#form[ "Reports_Access_Level_" & loopCount ]#',
			'#form[ "Create_Operator_Access_" & loopCount ]#',
			'#form[ "Max_Program_Spend_" & loopCount ]#',
			'#form[ "Internal_Notes_" & loopCount ]#',
			'#form[ "PAYMENT_HISTORY_ALERT_" & loopCount ]#',
			'#form[ "View_TPA_" & loopCount ]#',
			'#form[ "View_Net_Sales_" & loopCount ]#',
			'#form[ "Approve_Zero_Product_Cost_" & loopCount ]#',
			'#form[ "Approve_Zero_Product_Price_" & loopCount ]#',
			'#form[ "Show_Trade_Checkbook_" & loopCount ]#',
			'#form[ "View_Invoices_" & loopCount ]#',
			'#form[ "Install_Patch_" & loopCount ]#',
			'#form[ "Create_Budget_" & loopCount ]#',
			'#form[ "Approve_Pgm_Beyond_Budget_" & loopCount ]#'
			<cfif appSettings.getReleaseSettlement()>
				,'#form[ "ReleaseSettlement_" & loopCount ]#'
			</cfif>
			<cfif appSettings.getShow_Fixed_Freight()>
				,'#form[ "Freight_View_Create_" & loopCount ]#'
				,'#form[ "Approve_Freight_Programs_" & loopCount ]#'
				,'#form[ "Approve_Freight_Adjustment_Programs_" & loopCount ]#'
			</cfif>
			<!--- (Start) Only if the Export Program App Setting is turned on --->
			<cfif appSettings.getShowExportPrograms() >
				,'#form[ "Approve_Export_Agreements_" & loopCount ]#'
				,'#form[ "Create_Export_Agreements_" & loopCount ]#'
				,'#form[ "Create_Approve_Export_Agreements_" & loopCount ]#'
				,'#form[ "Create_New_Export_Customer_" & loopCount ]#'
				,'#form[ "Credit_Manager_" & loopCount ]#'
			</cfif>
			<!--- (End) Only if the Export Program App Setting is turned on --->
			,'#form[ "Search_Documents_" & loopCount ]#'
			,'#form[ "View_Private_Documents_" & loopCount ]#'
			,'#form[ "View_Prog_In_Duplicate_Check_Window_" & loopCount ]#'
				,'#form[ "Volume_Details_Tab_Display_" & loopCount ]#'
				,'#form[ "View_LH_Pane_Budget_Link_" & loopCount ]#'
			<cfif form[ "Market_Price_Variance_" & loopCount ] EQ "*">
				,99999
			<cfelse>
				,'#form[ "Market_Price_Variance_" & loopCount ]#'
			</cfif>

			,'#form[ "Delete_Pages_Program_Letter_" & loopCount ]#'
			,'#form[ "View_Workflow_Report_Data_" & loopCount ]#'
			,'#form[ "Search_Inactive_Products_Programs_" & loopCount ]#'       <!---26199 settings for searching inactive items --->
			,'#form[ "Search_Inactive_Distributors_Programs_" & loopCount ]#'   <!---26199--->
			,'#form[ "Search_Inactive_Operators_Programs_" & loopCount ]#'      <!---26199--->
  			,'#form[ "Re_instate_deleted_programs_" & loopCount ]#'
  			,'#form[ "EzButton_Approve_Beyond_MaxRate_" & loopCount ]#'  <!--- 25709: EZ Button --->
			,'#form[ "Volume_Forecast_" & loopCount ]#'
			,'#form[ "Edit_Price_Bracket_" & loopCount ]#'
			,'#form[ "Generate_Program_letters_" & loopCount ]#'
			,'#form[ "Dashboard_UOM_" & loopCount ]#'<!--- D29929: Dashboard Settings --->
			,'#form[ "Dashboard_Remote_Access_" & loopCount ]#'<!--- D29929: Dashboard Settings --->
			,'#form[ "Edit_Product_MasterData_" & loopCount ]#'
			,'#form[ "Budgets_Actual_Adjustment_" & loopCount ]#'<!--- D33473:Budget Actual Adjustments  --->
			,'#form[ "Create_Budget_Forecast_" & loopCount ]#'<!--- D64200 :: Create new accrual budget forecast process  --->
			,'#form[ "ProgramView_WIPPositionsBelowMe_" & loopCount ]#'
			,'#form[ "Edit_Volume_FC_Below_Me_" & loopCount ]#'
			,'#form[ "Profitability_Model_" & loopCount ]#' <!--- D36549 --->
			,'#form[ "Prevent_short_cut_routing_" & loopCount ]#'<!---D39479 :: Short Cut Routing profile switch --->
			,'#form[ "Limited_Revise_" & loopCount ]#' <!---D38941 :: New Limited User Profile Edit Functionality --->
			,'#form[ "Redistribution_" & loopCount ]#'<!---D39875 :: Redistribution Module - Profile Setting --->
			,'#form[ "Re_instate_deleted_billbacks_" & loopCount ]#'<!---D40664 :: Settings page to show Deleted Billbacks --->
			,'#form[ "Message_Center_Viewing_" & loopCount ]#'
			,'#form[ "Message_Center_Administration_" & loopCount ]#'
			,'#form[ "Competitive_Info_not_required_" & loopCount ]#' <!---D42287 :: Competitive Info not required by User Profile --->
			,'#form[ "View_LH_Pane_Recapture_Link_" & loopCount ]#' <!---D44346 :: Adding Recapture Link for user profile --->
			,'#form[ "View_LH_pane_Vertical_P_L_" & loopCount ]#'
			,'#form[ "View_LH_pane_What_If_P_L_" & loopCount ]#'
			,'#form[ "Browse_BBDoc_Server_Files_" & loopCount ]#'
			,'#form[ "Mass_Change_Program_Date_" & loopCount ]#'  <!--- 44077: User can modify program date after program approval from the settings panel --->
			,'#form[ "What_If_From_Scratch_" & loopCount ]#'
			,'#form[ "Manually_Select_Approvers_" & loopCount ]#'  <!--- 47065: Change Order Program Approvals --->
			,'#form[ "Vendor_Hold_Research_" & loopCount ]#'
			,'#form[ "Modify_Expired_Programs_" & loopCount ]#' <!---D50074 :: Viewing and Editing prior program versions --->
			,'#form[ "Manual_Reject_Billback_" & loopCount ]#'
			,'#form[ "View_LH_Pane_Duplicate_Checker_Link_" & loopCount ]#' <!--- 56440: 'Duplicate Check' link inside a program/Anand Rao/04-Jan-2016 --->
			,'#form[ "Modify_Vendors_VendorManagement_" & loopCount ]#' <!--- D57447 :: Create and modify vendor records  --->
			,'#form[ "Best_Plan_Program_" & loopCount ]#'<!--- D66995 :: Rework - Best Plans --->
			,'#form[ "Analytics_SSO_" & loopCount ]#'<!--- 71460:: - Analytics SSO --->
			,'#form[ "Max_Approval_Annual_Volume_" & loopCount ]#' <!--- 72497 --->
			,'#form[ "Max_Approval_Annual_Volume_Uom_" & loopCount ]#' <!--- 72497 --->
			,'#form[ "Ember_Access_" & loopCount ]#' <!--- 76021 --->
			,'#form[ "Upload_Programs_" & loopCount ]#' <!--- 81335 --->
			,'#form[ "Planning_Groups_Create_" & loopCount ]#' <!--- 96464 --->
			,'#form[ "RFP_Freight_View_Create_" & loopCount ]#'
			,'#form[ "RFP_Freight_FOB_Delivered_View_Create_" & loopCount ]#'
			,'#form[ "DoubleDipReport_" & loopCount ]#'
			,'#form[ "RFP_Page_Edit_RFA_" & loopCount ]#'
		)
		/*
		-----------------------------------------------------------------------------
		-- populate new columns here to avoid having a very lengthy insert statement
		-----------------------------------------------------------------------------
		*/
		UPDATE Profiles_Settings
		   SET  View_Margin_Percent = '#form[ "View_Margin_Percent_" & loopCount ]#',
				View_Target_NUC     = '#form[ "View_Target_NUC_" & loopCount ]#',
				View_NUC            = '#form[ "View_NUC_" & loopCount ]#',
				View_Target_NUC_Var = '#form[ "View_Target_NUC_Var_" & loopCount ]#'
		 WHERE Profiles_ID = #loopCount#
	</CFQUERY>

	</cftransaction>

	<cfset Approve_Pullback = form[ "Approve_Pullback_" & loopCount ]>
	<cfif Approve_Pullback EQ 0>
		<!------ remove all template entry for the current profile for pullback approval ----->
		<cfset templateManager.deleteProfileTemplates(
					profileId = loopCount,
					templateId = -1,
					forbidAccessType = 6) />
	</cfif>

	<!--- make sure each profile has atleast one UOM selected --->
	<cfset oProfiles.setMarginUOMDefaultSelect(profileId = GetAllProfiles.profiles_id) />
	<!--- AUDITING - CAPTURE CHANGES --->
	<cfquery name="variables.qUpdated" datasource="#application.datasource#">
		SELECT Profiles_Desc, ps.*
		FROM Profiles_Settings  ps
		INNER JOIN Profiles p on ps.profiles_id  = p.profiles_id 
		WHERE ps.Profiles_ID = #loopCount# AND ps.deleted = 0 and p.deleted = 0
	</cfquery>
	<cfscript>
		variables.udf = createObject( "component", "components.udf" );
		variables.udf.WriteSettingsAudit( variables.qOriginal, variables.qUpdated, "Profiles_Settings", loopCount, "#variables.qUpdated.Profiles_Desc#", "Lock_Date,Locked_By_User_ID,Is_Locked,Last_Changed_Date,Last_Changed_User_ID,profiles_id,Profiles_Settings_ID" );
	</cfscript>
</cfloop>

<cfquery name="UpdateGeneralInformation" datasource="#application.datasource#">
	UPDATE Profiles_Settings
	SET Last_Changed_Date		= #Last_Changed_Date#,
		Last_Changed_User_ID	= '#Last_Changed_User_ID#'
</cfquery>

<!--- ||||||||||||||| CREATE XML LOG OF CHANGES |||||||||||||||
<cfif appSettings.getAuditTrailStorage() NEQ 0>
	<cfscript>
		createLog.createXMLlog("Profiles_Settings",2);
		createLog.createXMLlog("Deductions_Profiles_Settings",2);
		createLog.createXMLlog("BB_Profiles_Settings",2);
	</cfscript>
</cfif>
 ||||||||||||||| CREATE XML LOG OF CHANGES ||||||||||||||| --->
