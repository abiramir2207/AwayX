<!---
44315 - Allow special characters (french accent marks) in Program Title field
NOTE: When editing this file make sure the accent characters for JS variable varREX, line 2790, are are below
ÀàáÂâÄäÇçÈèÉéÊêËëíÎîÏïóÔôÙùúÛûÜüÿ
--->
<cfset userManager = CreateObject("component", "components.user.UserManager") />

<!---Gets application settings--->
<!--- <cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() /> --->
<cfset appSettings = application.appsettingsGet />

<cfset programManager = CreateObject("component", "components.programs.ProgramManager").init()>
<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />

<cfset variables.labelComp 	= CreateObject("component", "components.settings.labels.labels").init() />

<!--- Dev Note: Clay 11105 Biz Segment & Spending Category (Operating Group)  --->
<cfif appSettings.getOperatingGroupOn()>
	<cfset operatingGroupManager 		= CreateObject("component", "components.operating_group.OperatingGroupManager").init() />
	<cfset programLevel1Level 				= operatingGroupManager.getProgramLevel1Level() />
	<cfset programLevel1LevelLabel 		= operatingGroupManager.getLabel(programLevel1Level) />
	<cfset programLevel2Level 				= operatingGroupManager.getProgramLevel2Level() />
	<cfset programLevel2LevelLabel 		= operatingGroupManager.getLabel(programLevel2Level) />
	<!-----
	<cfparam name="form.Operating_Group_Level_1_ID" default="0" />
	<cfparam name="form.Operating_Group_Level_2_ID" default="0" />
	 ----->
</cfif>
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<CFIF Get_Profile_Settings.Cont_Prog_View_Create_Program EQ 0 OR (appSettings.getUserNumberRestrict() EQ 1 AND userManager.getUserNumberExists(request.AccessStructure.User_ID) EQ 0)>
	<CFLOCATION URL="#application.HomePage#" ADDTOKEN="No">
</CFIF>

<cfinclude template="/actionFormat.cfm"><!--- D37492  --->
<cfinclude template="/common_files/general_labels.cfm">

<!------ get user positions id ----->
<cfset This_User_Positions_ID = userManager.getPositionId(request.AccessStructure.User_ID, 1) />

<!---import the custom tag lib--->
<cfimport prefix="layout" taglib="/CustomTags">

<!---Should show discount identifier--->
<cfset useLakebaseForgetGeneralSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("general_settings")>
<cfif useLakebaseForgetGeneralSettings>
	<cftry>
		<cfset getGeneralSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("general_settings", {
				"limit" = "1",
				"select" = "use_discount_id"
			}), "use_discount_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetGeneralSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetGeneralSettings>
<cfquery name="getGeneralSettings" datasource="#application.datasource#">
	SELECT 	TOP 1 Use_Discount_ID
	FROM 	General_Settings
</cfquery>
</cfif>

<cfparam name="form.Do_Revise_Copy" default="0">
<cfparam name="form.IsExclusionRevision" default="0">
<!---default params for business segments--->
<CFPARAM name="FORM.Business_Segment_ID" default="0">
<CFPARAM name="FORM.Line_Of_Business_ID" default="">
<CFPARAM name="form.businessSegmentsOn" default="0">
<CFPARAM name="form.Program_Date_Type" default="1">
<!--- Dev Note: Clay 10613   --->
<CFPARAM name="form.NewSearchSequence" default="0">
<CFPARAM name="form.New_Business_Segment" default="0">
<CFPARAM name="form.New_Spending_Category" default="0">
<CFPARAM name="form.suppressProductsDistributors" default="0">

<CFPARAM NAME="FORM.ISREVISIONOFEXISTINGCONTRACT" DEFAULT="0">
<CFPARAM NAME="FORM.Limited_Revise" DEFAULT="0">
<CFPARAM NAME="FORM.IsRollOver" DEFAULT="0">
<CFPARAM NAME="FORM.IsCopyProgram" DEFAULT="0">
<cfparam name="application.returned_customer_setting.Program_Number_Label"  default="Program Number" />
<CFPARAM NAME="FORM.parentStartDate" DEFAULT="#DateFormat(now(),'mm/dd/yyyy')#">
<CFPARAM NAME="FORM.checkParentStartDate" DEFAULT="0">


<CFSET PAGE_TITLE="Basic Program Information">
<CFSET GROUP="Contracts">

<CFPARAM name="URL.CID" default="">
<CFPARAM NAME="EncrypCID" DEFAULT="">
<cfparam name="Form.Performance_Start_Date" default="" />
<cfparam name="Form.Performance_End_Date" default="" />
<cfparam name="variables.operatorCategoryLabel" default="Operator Category" />
<cfparam name="variables.operatorPriorityLabel" default="Operator Priority" />
<cfparam name="Form.TemplateFiltersId" default="0" />
<cfparam name="Form.currency_conversion_factor" default="" />
<cfparam name="form.Best_Plan_Program" default="0"><!---60308--->
<cfparam name="Form.Is_Blanket_Bid" default="0">
<cfparam name="startDateDisabled" default="0">
<cfparam name="EndDateDisabled" default="0">
<cfparam name="FORM.check_program_uom" default="1">
<cfparam name="FORM.Planner_Perf_Types_ID" default="0" />

<CFSET Program_ID_To_Replicate = 0 />

<cfset revisionOfProgramWithOtherRevisions = 0 />

<CFIF form.Do_Revise_Copy EQ 0>

	<CFIF len(trim(URL.CID)) GT 0>

		<CF_CRYP type="de" string="#URL.CID#" key="#request.key#">

		<cfquery name="GetContractInfo" datasource="#application.datasource#">
		            SELECT	*,Contract_Main_Aux_Data.*
		            FROM	Contract_Main
		            INNER JOIN Contract_Main_Aux_Data
		            ON Contract_Main.Contract_Main_ID = Contract_Main_Aux_Data.Contract_Main_ID
		            WHERE 	Contract_Main.Contract_Main_ID = '#cryp.value#'
		</cfquery>
		<cfset useLakebaseForProgram_Auto_Renew = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_auto_renew")>
<cfif useLakebaseForProgram_Auto_Renew>
	<cftry>
		<cfset Program_Auto_Renew = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_auto_renew", {
				"program_id" = "eq.#GetContractInfo.Contract_Main_ID#",
				"deleted" = "eq.0",
				"select" = "program_auto_renew_id,ar_notification_date,ar_start_date,ar_end_date,ar_renewal_type,renewal_lead_time,renewed"
			}), "program_auto_renew_id,ar_notification_date,ar_start_date,ar_end_date,ar_renewal_type,renewal_lead_time,renewed"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForProgram_Auto_Renew = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForProgram_Auto_Renew>
<cfquery name="Program_Auto_Renew" datasource="#application.datasource#">
			SELECT 	Program_Auto_Renew_ID,
					AR_Notification_Date,
					AR_Start_Date,
					AR_End_Date,
					AR_Renewal_Type,
					Renewal_Lead_Time,
					Renewed
			FROM 	Program_Auto_Renew
			WHERE 	Program_ID = #GetContractInfo.Contract_Main_ID#
			AND		Deleted = 0

		</cfquery>
</cfif>

		<!--- D26803 : Revise Active/Pre-active PGM's
		Find if users are allowed to change dates --->
		<cfif appSettings.getAllowReviseActiveWithPreActive()>

			<cfset revisionOfProgramWithOtherRevisions = programManager.getParentHasPreviousRevisions(
					parentProgramId = GetContractInfo.Revision_Of_Contract_Main_ID,
					currentProgramId = GetContractInfo.Contract_Main_ID) />
		</cfif>

		<!--- Set original currency as a variable so the user can confirm the change. --->
		<cfset origCurrency = GetContractInfo.Currency>
		<!--- D50074 :: Viewing and Editing prior program versions START --->
			<!---
				D50630:Anand Rao:: Corrected the below query to refer to GetContractInfo, it was earlier referring to CSLGetContractInfo
				which did not exist.
			--->
		<cfif len(GetContractInfo.Contract_Main_ID)>
			<cfset ModifyDeletedPrograms = CreateObject("component","components.programs.program").ModifyDeletedProgram(GetContractInfo.Contract_Main_ID,Get_Profile_Settings.Modify_Expired_Programs) />
		<cfelse>
			<cfset ModifyDeletedPrograms = 0>
		</cfif>
		<!--- D50074 :: Viewing and Editing prior program versions END --->
		<!--- Do not show the tabs if the contract is approved --->
		<CFIF GetContractInfo.Contract_Status_Type_IDX GT 2 AND ModifyDeletedPrograms EQ 0><!--- D50074 :: Viewing and Editing prior program versions --->
			<script>
				history.back();
			</script>
			<CFABORT>
		</CFIF>
		<!--- decide if this program is a revision of an existing one --->
		<CFIF len(trim(GetContractInfo.Parent_Revised_Contract_Main_ID)) NEQ 0 AND len(trim(GetContractInfo.Revision_of_Contract_Main_ID)) NEQ 0 OR GetContractInfo.IsExclusionRevision EQ 1>
			<CFSET FORM.ISREVISIONOFEXISTINGCONTRACT = 1>
		</CFIF>

		<cfif GetContractInfo.IsExclusionRevision EQ 1>
			<cfset form.IsExclusionRevision = 1>
		</cfif>

		<CFSET EncrypCID = URL.CID>
		<CFSET URL.CID = cryp.value>

		<CFPARAM name="FORM.Business_Segment_ID" 			default="#GetContractInfo.Business_Segment_ID#">
		<CFPARAM name="FORM.Line_Of_Business_ID" 			default="#GetContractInfo.Line_Of_Business_ID#">

		<!--- Dev Note: Clay 10613 --->
		<CFIF FORM.NEWSEARCHSEQUENCE EQ 0>
			<CFSET FORM.Search_Sequence_ID = GetContractInfo.Search_Sequence_ID />
		<CFELSE>
			<CFSET FORM.Search_Sequence_ID = Form.NewSearchSequence />
		</CFIF>

		<CFPARAM name="FORM.Affect_Broker_Commission" 		default="#GetContractInfo.Affect_Broker_Commission#">
		<CFPARAM name="FORM.Affect_Broker_Commission_Type" 	default="#GetContractInfo.Affect_Broker_Commission_Type#">
		<CFPARAM name="FORM.Affect_Shelter" 				default="#GetContractInfo.Affect_Shelter#">
		<CFPARAM name="FORM.Affect_Shelter_Type" 			default="#GetContractInfo.Affect_Shelter_Type#">

		<CFPARAM name="FORM.Contract_Reference_Number" 		default="#GetContractInfo.Contract_Reference_Number#">
		<CFPARAM name="FORM.Contract_Reference_Number_2" 		default="#GetContractInfo.Contract_Reference_Number_2#"><!--- 77539 --->
		<cfif isDefined("GetContractInfo.LEGACY_DEAL_ID")>
			<CFPARAM name="FORM.legacy_id" default="#GetContractInfo.LEGACY_DEAL_ID#">
		</cfif>
		<CFPARAM name="FORM.legacy_id" default="">
		<cfif isDefined("GetContractInfo.BID_NUMBER")>
			<CFPARAM name="FORM.bid_id" default="#GetContractInfo.BID_NUMBER#">
		</CFIF>

		<!--- Dev Note: Clay 11105 Biz Segment & Spending Category (Operating Group)  --->
		<CFIF appSettings.getOperatingGroupOn()>
			<CFIF Form.New_Business_Segment NEQ 0>
				<CFPARAM name="FORM.Operating_Group_Level_1_ID" 	default="#Form.New_Business_Segment#">
			<CFELSE>
				<cfparam name="FORM.Operating_Group_Level_1_ID" 	default="#operatingGroupManager.getProgramOperatingGroupID(level=programLevel1Level, programId=URL.CID)#">
			</CFIF>

			<CFIF FORM.NEW_Spending_Category NEQ 0>
				<CFPARAM name="FORM.Operating_Group_Level_2_ID" 	default="#FORM.NEW_Spending_Category#">
			<CFELSE>
				<cfparam name="FORM.Operating_Group_Level_2_ID" 	default="#operatingGroupManager.getProgramOperatingGroupID(level=programLevel2Level, programId=URL.CID)#">
			</CFIF>
		</CFIF>


		<CFPARAM name="FORM.bid_id" default="">
		<CFPARAM name="FORM.Contract_Title" 				default="#GetContractInfo.Contract_Title#">
		<CFPARAM name="FORM.Planner_Perf_Types_ID" 				default="#GetContractInfo.Planner_Perf_Type_ID#">
		<CFPARAM name="FORM.Operator_List" 				default="#GetContractInfo.Alternate_Payment_Recipient#"> <!--- D38189::Alternate Payment Recipient --->
		<CFPARAM name="FORM.fiscal_year" 					default="#GetContractInfo.fiscal_year#">
		<CFPARAM name="FORM.start_date" 					default="#DateFormat(GetContractInfo.Contract_Start_Date, 'mm/dd/yyyy')#">
		<CFPARAM name="FORM.end_date" 						default="#DateFormat(GetContractInfo.Contract_End_Date, 'mm/dd/yyyy')#">
		<CFPARAM name="FORM.Quantity" 						default="#GetContractInfo.Contract_Quantity#">
		<CFPARAM name="FORM.Contract_Quantity_UOM_IDX" 		default="#GetContractInfo.Contract_Quantity_uom_IDX#">
		<CFPARAM name="FORM.Fixed_Rebate_Amount"	 		default="#GetContractInfo.Fixed_Rebate_Amount#">
		<CFPARAM name="FORM.Discount_Type_ID"		 		default="#GetContractInfo.Discount_Type_ID#">

		<CFPARAM name="FORM.Dist_Brand_Eligibility"	 		default="#GetContractInfo.Dist_Brand_Eligibility#">
		<CFPARAM name="FORM.Contract_Number"		 		default="#GetContractInfo.Contract_Number#">
		<CFPARAM name="FORM.button_caption"					default="save">
		<CFPARAM name="FORM.Like_Product_Exist"				default="#trim(GetContractInfo.Like_Product_Exist)#">
		<CFPARAM name="FORM.Is_Awarded"						default="#trim(GetContractInfo.Is_Awarded)#">
		<CFPARAM name="FORM.Notes"							default="#trim(GetContractInfo.Notes)#">
		<CFPARAM name="FORM.Competitive_Info_Notes"							default="#trim(GetContractInfo.Competitive_Info_Notes)#">

		<!---Payable To--->
		<CFPARAM name="FORM.Pay_To_Distributor"				default="#GetContractInfo.Pay_To_Distributor#">
		<CFPARAM name="FORM.Payable_Company"				default="#GetContractInfo.Payable_Company#">
		<CFPARAM name="FORM.Payable_Attention"				default="#GetContractInfo.Payable_Attention#">
		<CFPARAM name="FORM.Payable_Address_1"				default="#GetContractInfo.Payable_Address_1#">
		<CFPARAM name="FORM.Payable_Address_2"				default="#GetContractInfo.Payable_Address_2#">
		<CFPARAM name="FORM.Payable_City"					default="#GetContractInfo.Payable_City#">
		<CFPARAM name="FORM.Payable_State"					default="#GetContractInfo.Payable_State#">
		<CFPARAM name="FORM.Payable_Zip"					default="#GetContractInfo.Payable_Zip#">
		<CFPARAM name="FORM.Payable_Comments"				default="#GetContractInfo.Payable_Comments#">

		<!---Send Payment To--->
		<CFPARAM name="FORM.Send_To_Broker"					default="#GetContractInfo.Send_To_Broker#">
		<CFPARAM name="FORM.Send_Company"					default="#GetContractInfo.Send_Company#">
		<CFPARAM name="FORM.Send_Attention"					default="#GetContractInfo.Send_Attention#">
		<CFPARAM name="FORM.Send_Address_1"					default="#GetContractInfo.Send_Address_1#">
		<CFPARAM name="FORM.Send_Address_2"					default="#GetContractInfo.Send_Address_2#">
		<CFPARAM name="FORM.Send_City"						default="#GetContractInfo.Send_City#">
		<CFPARAM name="FORM.Send_State"						default="#GetContractInfo.Send_State#">
		<CFPARAM name="FORM.Send_Zip"						default="#GetContractInfo.Send_Zip#">

		<CFPARAM name="FORM.RenewNeutral" 					default="#GetContractInfo.RenewNeutral#">
		<CFPARAM name="FORM.ProgramType" 					default="#GetContractInfo.ProgramType_ID#">
		<CFPARAM name="FORM.ProgramType_ID"					default="#GetContractInfo.ProgramType_ID#">
		<CFPARAM name="FORM.On_Release_Contract_Status_Type_IDX"	default="#GetContractInfo.On_Release_Contract_Status_Type_IDX#">
		<CFPARAM name="Form.Responsible_User_Id_Position_Id" 	default="#GetContractInfo.Creating_User_Position_ID#_#GetContractInfo.Responsible_User_Id#">

		<CFPARAM name="FORM.Equipment_Placement"				default="#GetContractInfo.Equipment_Placement#">
		<CFPARAM name="FORM.Equipment_Placement_Note"			default="#GetContractInfo.Equipment_Placement_Note#">
		<CFPARAM name="FORM.Pullback_From_This_Program"			default="#GetContractInfo.Pullback_From_This_Program#">
		<!--- Commented out 1.89 Clay-Budgets
		<!--- Dev Note: Budgets --->
		<CFPARAM name="FORM.budget_reference_id"			default="#GetContractInfo.budget_reference_id#">

		<cfif FORM.ProgramType_ID EQ 0>
			<h1>THIS PROGRAM DOES NOT HAVE ALL THE APPROPIATE INFORMATION TO BE OF ANY USE</h1>
			<cfabort>
		</cfif>
		--->
		<CFPARAM name="FORM.Created_Type" 						default="#GetContractInfo.Created_Type#">

		<!--- Auto Renew Data --->
		<CFPARAM name="FORM.AUTO_RENEW"							default="#GetContractInfo.Auto_Renew#">
		<CFPARAM name="FORM.AR_Notification_Date"				default="#Program_Auto_Renew.AR_Notification_Date#">
		<CFPARAM name="FORM.AR_Start_Date" 						default="#Program_Auto_Renew.AR_Start_Date#">
		<CFPARAM name="FORM.AR_End_Date" 						default="#Program_Auto_Renew.AR_End_Date#">
		<CFPARAM name="FORM.AR_Renewal_Type" 					default="#Program_Auto_Renew.AR_Renewal_Type#">
		<CFPARAM name="FORM.Renewal_Lead_Time" 					default="#Program_Auto_Renew.Renewal_Lead_Time#">

		<!--- Payment Cycle --->
		<CFPARAM name="FORM.PaymentCycle"						default="#GetContractInfo.PaymentCycle#">
		<!--- Currency --->
		<CFPARAM name="FORM.Currency"							default="#GetContractInfo.Currency#">
		<!--- Controllable --->
		<CFPARAM name="FORM.Controllable_Volume"				default="#GetContractInfo.Controllable_Volume#">
		<!--- Growth Inclusion --->
		<CFPARAM name="FORM.Growth_Inclusion"					default="#GetContractInfo.Growth_Inclusion#">
		<!--- Claim Mechanics --->
		<CFPARAM name="FORM.ClaimMechanicOption"				default="#GetContractInfo.ClaimMechanics#">
		<CFPARAM name="FORM.BldUpInvoice" 						default="#GetContractInfo.BldUpInvoice#">
		<!--- Advanced Spending --->
		<!--- <CFPARAM name="FORM.Adv_Spending_Amount"				default="#GetContractInfo.Adv_Spending_Amount#"> --->
		<CFPARAM name="FORM.Adv_Spending_Amount"				default="#replace(GetContractInfo.Adv_Spending_Amount, ',','', 'ALL')#">
		<!--- Global GL Assignment --->
		<CFPARAM name="FORM.Global_GL_Assign_Choice"			default="#GetContractInfo.GL_Assignment#">
		<cfif appSettings.getUse_Accounting_Program_Type() EQ 1>
		<CFPARAM name="FORM.Accounting_Program_Type_ID"			default="#GetContractInfo.Accounting_Program_Type_ID#">
		</cfif>
		<cfif appSettings.getProgramCategory() EQ 1>
		<CFPARAM name="FORM.Program_Category_ID"				default="#GetContractInfo.Program_Category_ID#"> <!--- Dev Note: Milan - D6321 --->
		</cfif>
		<cfset Form.Performance_Start_Date = GetContractInfo.Performance_Start_Date />
		<cfset Form.Performance_End_Date = GetContractInfo.Performance_End_Date />
		<cfif (appSettings.PRICE_LIST_BY_TEMPLATE EQ 1)>
			<CFPARAM name="FORM.Effective_Date_for_Price"	default="#GetContractInfo.Effective_Date_for_Price#">
				<CFPARAM name="FORM.Price_Protection_Date"	default="#dateformat(GetContractInfo.Price_Protection_Date, "mm/dd/yyyy")#"><!--- D32776:Effective Price Date Changed on all Bid Programs --->
		<cfelse>
			<CFPARAM name="FORM.Effective_Date_for_Price"	default="">
				<CFPARAM name="FORM.Price_Protection_Date"	default=""><!--- D32776:Effective Price Date Changed on all Bid Programs --->
		</cfif>
		<!--- -- D38942 :: Program Blackout Period on Frontend START --->
		<cfparam name="form.Program_Start_Zero" default="#GetContractInfo.Program_Start_Zero#" />
		<cfparam name="form.Program_Future_zero" default="#GetContractInfo.Program_Future_Zero#" />
		<!--- -- D38942 :: Program Blackout Period on Frontend START --->
		<cfset Form.currency_conversion_factor = GetContractInfo.Currency_Conversion_Factor>
		<!--- 42349 - Most Favored Nations - setup and alert --->
		<cfset FORM.Program_Most_Favored_Nation = GetContractInfo.Program_Most_Favored_Nation />
		<cfset FORM.contract_period_start_date = GetContractInfo.contract_period_start_date />
		<cfset FORM.contract_period_end_date = GetContractInfo.contract_period_end_date />
		<cfset form.Best_Plan_Program = GetContractInfo.Best_Plan_Program><!--- 60308--->
		<cfset Form.Is_Blanket_Bid = GetContractInfo.Is_Blanket_Bid>
	<CFELSE>

		<!--- unlock this users contracts --->
		<cfstoredproc procedure="USP_Contract_Lock_Unlock" datasource="#application.datasource#">
			<cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@User_ID" value="#request.AccessStructure.User_ID#">
			<cfprocparam type="In" cfsqltype="cf_sql_bit" dbVarName="@Unlock" value="1">
			<cfprocparam type="In" cfsqltype="cf_sql_bit" dbVarName="@Lock" value="0">
			<cfprocparam type="In" cfsqltype="cf_sql_integer" dbVarName="@Lock_Program_ID" value="0">
			<cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@Lock_Program_Number" value="">
			<cfprocparam type="In" cfsqltype="cf_sql_integer" dbVarName="@Unlock_Program_ID" value="0">
			<cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@Unlock_Program_Number" value="">
		</cfstoredproc>


		<cfinclude template="contract_number_generator.cfm">

		<CFIF Form.New_Business_Segment NEQ 0>
			<CFPARAM name="FORM.Operating_Group_Level_1_ID" 	default="#Form.New_Business_Segment#">
		</CFIF>
		<CFIF FORM.NEW_Spending_Category NEQ 0>
			<CFPARAM name="FORM.Operating_Group_Level_2_ID" 	default="#FORM.NEW_Spending_Category#">
		</CFIF>


		<CFPARAM name ="FORM.Contract_Reference_Number" 		default="">
		<CFPARAM name="FORM.Contract_Reference_Number_2" 		default=""><!--- 77539 --->
		<CFPARAM name ="FORM.LEGACY_ID" 						default="">
		<CFPARAM name ="FORM.BID_Id" 						default="">
		<CFPARAM name ="FORM.Contract_Title" 				default="">
		<CFPARAM name ="FORM.Planner_Perf_Types_ID" 		default="0">

		<CFPARAM name="FORM.Operator_List" 				default=""><!--- D38189::Alternate Payment Recipient --->
		<CFPARAM name="FORM.start_date" 					default="">
		<CFPARAM name="FORM.end_date" 						default="">
		<CFPARAM name="FORM.fiscal_year" 					default="">
		<CFPARAM name="FORM.Quantity" 						default="0">
		<CFPARAM name="FORM.Contract_Quantity_UOM_IDX"	 	default="">
		<CFPARAM name="FORM.Fixed_Rebate_Amount"	 		default="">
		<CFPARAM name="FORM.Discount_Type_ID"		 		default="1">
		<CFPARAM name="FORM.Dist_Brand_Eligibility"	 		default="0">
		<CFPARAM name="FORM.Contract_Number"		 		default="#generator_contract_number#">
		<CFPARAM name="FORM.button_caption"					default="save">
		<CFPARAM name="FORM.Like_Product_Exist"				default="0">
		<CFPARAM name="FORM.Is_Awarded"						default="0">
		<CFPARAM name="FORM.Notes"							default="">
		<CFPARAM name="Form.Competitive_Info_Notes"			default="">
		<CFPARAM name="FORM.ClaimMechanics" 				default="0">
		<CFPARAM name="FORM.BldUpInvoice" 					default="0">
		<CFPARAM name="FORM.RenewNeutral" 					default="0">
	 	<CFPARAM name="FORM.CommunicateTo" 					default="">
		<CFPARAM name="FORM.PaymentCycle" 					default="0">
		<CFPARAM name="FORM.Currency"						default="0">
		<cfparam name="FORM.ProgramType"					default="">
		<cfparam name="FORM.ProgramType_ID"					default="#trim(form.programtype)#">
		<CFPARAM name="FORM.Created_Type" 					default="">

		<!---Payable To--->
		<CFPARAM name="FORM.Pay_To_Distributor"				default="">
		<CFPARAM name="FORM.Payable_Company"				default="">
		<CFPARAM name="FORM.Payable_Attention"				default="">
		<CFPARAM name="FORM.Payable_Address_1"				default="">
		<CFPARAM name="FORM.Payable_Address_2"				default="">
		<CFPARAM name="FORM.Payable_City"					default="">
		<CFPARAM name="FORM.Payable_State"					default="">
		<CFPARAM name="FORM.Payable_Zip"					default="">
		<CFPARAM name="FORM.Payable_Comments"				default="">
		<!---Send payment To--->
		<CFPARAM name="FORM.Send_To_Broker"					default="">
		<CFPARAM name="FORM.Send_Company"					default="">
		<CFPARAM name="FORM.Send_Attention"					default="">
		<CFPARAM name="FORM.Send_Address_1"					default="">
		<CFPARAM name="FORM.Send_Address_2"					default="">
		<CFPARAM name="FORM.Send_City"						default="">
		<CFPARAM name="FORM.Send_State"						default="">
		<CFPARAM name="FORM.Send_Zip"						default="">

		<!--- Communication Settings DATA--->
		<CFPARAM name="FORM.CommRecip_1" 					default="0">
		<CFPARAM name="FORM.CommRecip_2" 					default="0">
		<CFPARAM name="FORM.CommRecip_3" 					default="0">
		<CFPARAM name="FORM.CommRecip_4" 					default="0">
		<!--- Auto Renew Data --->
		<CFPARAM name="FORM.AR_Renewal_Type" 				default="">
		<CFPARAM name="FORM.Auto_Renew" 					default="0">
		<CFPARAM name="FORM.AR_Notification_Date"			default="">
		<CFPARAM name="FORM.AR_Start_Date" 					default="">
		<CFPARAM name="FORM.AR_End_Date" 					default="">
		<CFPARAM name="Form.Renewal_Lead_Time" 				default="">
		<!--- Payment Cycle --->
		<CFPARAM name="FORM.Payment_Cycle"					default="0">
		<!--- Payment Cycle --->
		<CFPARAM name="FORM.Currency"						default="0">
		<!--- Controllable --->
		<CFPARAM name="FORM.Controllable_Volume"			default="0">
		<!--- Growth Inclusion --->
		<CFPARAM name="FORM.Growth_Inclusion"				default="0">
		<!--- Claim Mechanics --->
		<CFPARAM name="FORM.ClaimMechanicOption"			default="0">
		<CFPARAM name="FORM.BldUpInvoice" 					default="0">
		<!--- Advanced Spending --->
		<CFPARAM name="FORM.Adv_Spending_Amount"					default="EMPTY">
		<!--- Global GL Assignment --->
		<CFPARAM name="FORM.Global_GL_Assign_Choice"				default="0">
		<CFPARAM name="FORM.On_Release_Contract_Status_Type_IDX"	default="2">
		<CFPARAM name="Form.Responsible_User_Id_Position_Id" 		default="#This_User_Positions_ID#_#request.AccessStructure.User_Id#">
		<CFPARAM name="FORM.Equipment_Placement"					default="">
		<CFPARAM name="FORM.Equipment_Placement_Note"				default="">
		<cfif appSettings.getUse_Accounting_Program_Type() EQ 1>
		<CFPARAM name="FORM.Accounting_Program_Type_ID"				default="">
		</cfif>
		<CFPARAM name="FORM.Search_Sequence_ID" 					default="">
		<CFPARAM name="FORM.Affect_Broker_Commission" 				default="">
		<CFPARAM name="FORM.Affect_Broker_Commission_Type" 			default="">
		<CFPARAM name="FORM.Affect_Shelter" 						default="">
		<CFPARAM name="FORM.Affect_Shelter_Type" 					default="">
		<cfif appSettings.getProgramCategory() EQ 1>
		<CFPARAM name="FORM.Program_Category_ID"					default="0"><!--- Dev Note: Milan - D6321 --->
		</cfif>
		<cfparam name="Form.Pullback_From_This_Program" 			default="1">
		<CFPARAM name="FORM.Effective_Date_for_Price"				default="">
		<CFPARAM name="FORM.Price_Protection_Date"	default=""><!--- D32776:Effective Price Date Changed on all Bid Programs --->
		<!--- -- D38942 :: Program Blackout Period on Frontend START --->
		<cfparam name="form.Program_Start_Zero" default="" />
		<cfparam name="form.Program_Future_zero" default="" />
		<!--- -- D38942 :: Program Blackout Period on Frontend START --->
		<!--- 42349 - Most Favored Nations - setup and alert --->
		<CFPARAM name="FORM.Program_Most_Favored_Nation" default="0">
		<CFPARAM name="FORM.contract_period_start_date" default="">
		<CFPARAM name="FORM.contract_period_end_date" default="">
		<CFPARAM name="form.Best_Plan_Program" default="0"><!--- 60308--->
		<CFPARAM name="form.Is_Blanket_Bid" default="0">
	</CFIF>


<CFELSE>
<!--- ******************************************************************************* --->
<!--- *************************** COPY / REVISE - START ***************************** --->
<!--- ******************************************************************************* --->
	<!---
	D22578: CAG - mass copy a program
	We no longer will be using replicate_program.cfm for copy / revise
	Instead when user clicks save in the basic info page, we will call routine USP_Copy_Program which will do the copy
	--->



	<cf_cryp type="de" string ="#FORM.Program_ID#" key="#request.key#">

	<CFSET Program_ID_To_Replicate = cryp.value>

	<!---  34150 - pull auto renew information from parent program  --->
	<cfquery name="vars.Program_Auto_Renew" datasource="#application.datasource#">
		SELECT 	Program_Auto_Renew_ID,
				AR_Notification_Date,
				AR_Start_Date,
				AR_End_Date,
				AR_Renewal_Type,
				Renewal_Lead_Time,
				Renewed
		FROM 	Program_Auto_Renew
				INNER JOIN Contract_Main ON Contract_Main.Contract_Main_ID = Program_Auto_Renew.Program_ID
				AND Contract_Main.Auto_Renew = 1
		WHERE 	Program_ID = #cryp.value#
		AND		Program_Auto_Renew.Deleted = 0
	</cfquery>

	<!--- Load Data From Packet --->
	<cfinclude template="load_basic_information_struct.cfm" />

	<CFIF FORM.ISREVISIONOFEXISTINGCONTRACT EQ 1>
		<!---- Revision ---->
		<CFPARAM name="FORM.Affect_Broker_Commission" 		default="#Program_Packet.Basic_Information.Affect_Broker_Commission#">
		<CFPARAM name="FORM.Affect_Broker_Commission_Type" 	default="#Program_Packet.Basic_Information.Affect_Broker_Commission_Type#">
		<CFPARAM name="FORM.Affect_Shelter" 				default="#Program_Packet.Basic_Information.Affect_Shelter#">
		<CFPARAM name="FORM.Affect_Shelter_Type" 			default="#Program_Packet.Basic_Information.Affect_Shelter_Type#">
		<CFPARAM name="FORM.fiscal_year" 						default="#Program_Packet.Basic_Information.fiscal_year#">
		<CFSET FORM.check_program_uom = "#Program_Packet.Basic_Information.check_program_uom#">

		<cfif Program_Packet.Basic_Information.currency_conversion_factor neq "NULL">
			<cfset form.currency_conversion_factor = Program_Packet.Basic_Information.currency_conversion_factor>      <!--- 39257 --->
		</cfif>

		<cfif form.IsExclusionRevision EQ 0>

			<CFSET FORM.Contract_Number = "#Program_Packet.Basic_Information.Contract_Number#">
			<CFSET FORM.start_date = "#Program_Packet.Basic_Information.Contract_Start_Date#">
			<CFSET FORM.end_date = "#Program_Packet.Basic_Information.Contract_End_Date#">
			<CFSET FORM.Performance_Start_Date = "#Program_Packet.Basic_Information.Performance_Start_Date#">
			<CFSET FORM.Performance_End_Date = "#Program_Packet.Basic_Information.Performance_End_Date#">
			<CFSET FORM.Adv_Spending_Amount ="">

		<cfelse>

			<cfset useLakebaseForgetExclusionInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_exclusions")>
<cfif useLakebaseForgetExclusionInfo>
	<cftry>
		<cfset getExclusionInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_exclusions", {
				"revision_program_id" = "eq.#GetContractInfo.Contract_Main_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetExclusionInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetExclusionInfo>
<cfquery name="getExclusionInfo" datasource="#application.datasource#">
				SELECT 	*
				FROM 	Program_Exclusions
				WHERE 	Revision_Program_ID = '#GetContractInfo.Contract_Main_ID#'
				AND 	Deleted = 0
			</cfquery>
</cfif>

			<CFSET FORM.Contract_Number = "#Program_Packet.Basic_Information.Contract_Number#">
			<CFSET FORM.start_date = "#dateformat(getExclusionInfo.Start_Date, 'mm/dd/yyyy')#">
			<CFSET FORM.end_date = "#dateformat(getExclusionInfo.End_Date, 'mm/dd/yyyy')#">
			<CFSET FORM.Performance_Start_Date = "#dateformat(Program_Packet.Basic_Information.Performance_Start_Date, 'mm/dd/yyyy')#">
			<CFSET FORM.Performance_End_Date = "#dateformat(Program_Packet.Basic_Information.Performance_End_Date, 'mm/dd/yyyy')#">
			<CFSET FORM.Adv_Spending_Amount = "">
		</cfif>

		<!--- D26803 : Revise Active/Pre-active PGM's
		Find if users are allowed to change dates --->
		<cfif appSettings.getAllowReviseActiveWithPreActive()>
			<cfset revisionOfProgramWithOtherRevisions = programManager.getParentHasPreviousRevisions(
						parentProgramId = Program_ID_To_Replicate,
						currentProgramId = 0,
						bGrandParentHasPreviousRevision = getContractInfo.Parent_Has_Previous_Revision) />
		</cfif>

	<CFELSE>

		<cfinclude template="contract_number_generator.cfm">

		<CFPARAM NAME="FORM.Contract_Number"				default="#generator_contract_number#">
		<CFPARAM name="FORM.start_date" 					default="">
		<CFPARAM name="FORM.end_date" 						default="">
		<CFPARAM name="FORM.fiscal_year" 					default="">
		<CFPARAM name="FORM.Adv_Spending_Amount" 			default="">
	</CFIF>

	<CFPARAM name="FORM.Is_Blanket_Bid"				default="0">

	<cfif FORM.IsCopyProgram EQ 1 OR FORM.ISREVISIONOFEXISTINGCONTRACT EQ 1>
		<cfset FORM.Is_Blanket_Bid = Program_Packet.Basic_Information.Is_Blanket_Bid>
	</cfif>

	<!---60308	Best Plans Enhancement START--->
	<!--- The dates need to carry over on Copy for Best Plan programs --->
	<cfif form.IsCopyProgram AND Program_Packet.Basic_Information.Best_Plan_Program>
		<CFSET FORM.start_date = "#dateformat(Program_Packet.Basic_Information.Contract_Start_Date, 'mm/dd/yyyy')#">
		<CFSET FORM.end_date = "#dateformat(Program_Packet.Basic_Information.Contract_End_Date, 'mm/dd/yyyy')#">
	</cfif>
	<!---60308	Best Plans Enhancement END--->


<CFIF FORM.IsCopyProgram EQ 1>
	<cfif appSettings.getretainoriginalRSPcopy() EQ 0 OR Program_Packet.Basic_Information.Best_Plan_Program>
		<CFPARAM name="FORM.Responsible_User_Id_Position_Id" 	default="#This_User_Positions_ID#_#request.AccessStructure.User_Id#">
	<cfelse>
			<CFPARAM name="FORM.Responsible_User_Id_Position_Id" 	default="#Program_Packet.Basic_Information.Creating_User_Position_ID#_#Program_Packet.Basic_Information.Responsible_User_Id#">
	</cfif>
<CFELSE>
	<cfif isdefined("FORM.Responsible_User_Id_Position_Id") and appSettings.getretainoriginalRSP() EQ 0>
		<CFPARAM name="FORM.Responsible_User_Id_Position_Id" 		default="#FORM.Responsible_User_Id_Position_Id#">
	<cfelse>

			<CFPARAM name="FORM.Responsible_User_Id_Position_Id" 	default="#Program_Packet.Basic_Information.Creating_User_Position_ID#_#Program_Packet.Basic_Information.Responsible_User_Id#">

	</cfif>
</CFIF>
	<CFPARAM name="FORM.Business_Segment_ID" 			default="#Program_Packet.Basic_Information.Business_Segment_ID#">
	<CFPARAM name="FORM.Line_Of_Business_ID" 			default="#Program_Packet.Basic_Information.Line_Of_Business_ID#">
	<!--- Dev Note: Clay 10613   --->
	<CFPARAM NAME="FORM.NEWSEARCHSEQUENCE" Default="0">
	<CFIF FORM.NEWSEARCHSEQUENCE EQ 0>
			<CFPARAM name="FORM.Search_Sequence_ID" 			default="#Program_Packet.Basic_Information.Search_Sequence_ID#">
	<CFELSE>
			<CFPARAM name="FORM.Search_Sequence_ID" 			default="#Form.NewSearchSequence#"/>
	</CFIF>

	<!--- Dev Note: Clay 11105 Biz Segment & Spending Category (Operating Group)  --->
	<CFIF appSettings.getOperatingGroupOn()>
	<CFIF Form.New_Business_Segment EQ 0>
		<CFSET FORM.Operating_Group_Level_1_ID = Program_Packet.Basic_Information.Operating_Group_Level_1_ID />
	<CFELSE>
		<CFPARAM name="FORM.Operating_Group_Level_1_ID" 	default="#Form.New_Business_Segment#">
	</CFIF>
	<CFIF FORM.NEW_Spending_Category EQ 0>
		<CFSET FORM.Operating_Group_Level_2_ID = Program_Packet.Basic_Information.Operating_Group_Level_2_ID />
	<CFELSE>
		<CFPARAM name="FORM.Operating_Group_Level_2_ID" 	default="#FORM.NEW_Spending_Category#">
	</CFIF>
	</CFIF>


	<CFPARAM name="FORM.Affect_Broker_Commission" 		default="">
	<CFPARAM name="FORM.Affect_Broker_Commission_Type" 	default="">
	<CFPARAM name="FORM.Affect_Shelter" 				default="">
	<CFPARAM name="FORM.Affect_Shelter_Type" 			default="">


	<cfif FORM.ISREVISIONOFEXISTINGCONTRACT EQ 1>
		<cfset FORM.Contract_Reference_Number = Program_Packet.Basic_Information.Contract_Reference_Number>
		<cfset FORM.LEGACY_ID = Program_Packet.Basic_Information.LEGACY_DEAL_ID>
		<cfset FORM.Contract_Reference_Number_2 ="#GetContractInfo.Contract_Reference_Number_2#"><!--- 77539 --->
	</cfif>

	<CFPARAM name="FORM.Contract_Reference_Number" 		default="">
	<CFPARAM name="FORM.Contract_Reference_Number_2" 		default=""><!--- 77539 --->
	<CFPARAM name="FORM.LEGACY_ID" 						default="">
	<CFPARAM name="FORM.BID_ID" 						default="#Program_Packet.Basic_Information.BID_NUMBER#">
	<CFPARAM name="FORM.Contract_Title" 				default="#Program_Packet.Basic_Information.Contract_Title#">
	<CFPARAM name="FORM.Planner_Perf_Types_ID" 			default="#Program_Packet.Basic_Information.Planner_Perf_Type_ID#" />	
	<CFPARAM name="FORM.Operator_List" 				default="#Program_Packet.Basic_Information.Alternate_Payment_Recipient#">	<!--- D38189::Alternate Payment Recipient --->
	<CFPARAM name="FORM.Quantity" 						default="#Program_Packet.Basic_Information.Contract_Quantity#">
	<CFPARAM name="FORM.Contract_Quantity_UOM_IDX" 		default="#Program_Packet.Basic_Information.Contract_Quantity_uom_IDX#">
	<CFPARAM name="FORM.Fixed_Rebate_Amount"	 		default="#Program_Packet.Basic_Information.Fixed_Rebate_Amount#">
	<CFPARAM name="FORM.Discount_Type_ID"		 		default="#Program_Packet.Basic_Information.Discount_Type_ID#">

	<CFPARAM name="FORM.Dist_Brand_Eligibility"	 		default="#Program_Packet.Basic_Information.Dist_Brand_Eligibility#">
	<CFPARAM name="FORM.Contract_Number"		 		default="#Program_Packet.Basic_Information.Contract_Number#">
	<CFPARAM name="FORM.button_caption"					default="save">
	<CFPARAM name="FORM.Like_Product_Exist"				default="#trim(Program_Packet.Basic_Information.Like_Product_Exist)#">
	<CFPARAM name="FORM.Is_Awarded"						default="#trim(Program_Packet.Basic_Information.Is_Awarded)#">
	<CFPARAM name="FORM.Notes"							default="#trim(Program_Packet.Basic_Information.Notes)#">
	<CFPARAM name="FORM.Competitive_Info_Notes"						default="#trim(Program_Packet.Basic_Information.Competitive_Info_Notes)#">
	<CFPARAM name="FORM.RenewNeutral" 					default="#Program_Packet.Basic_Information.RenewNeutral#">
	<CFPARAM name="FORM.ProgramType" 					default="#Program_Packet.Basic_Information.ProgramType_ID#">
	<CFPARAM name="FORM.ProgramType_ID"					default="#Program_Packet.Basic_Information.ProgramType_ID#">

	<CFPARAM name="FORM.Created_Type" 					default="#Program_Packet.Basic_Information.Created_Type#">

	<!--- Communication Settings --->
	<CFPARAM name="FORM.CommRecip_1" 					default="#Program_Packet.Basic_Information.CommRecip_1#">
	<CFPARAM name="FORM.CommRecip_2" 					default="#Program_Packet.Basic_Information.CommRecip_2#">
	<CFPARAM name="FORM.CommRecip_3" 					default="#Program_Packet.Basic_Information.CommRecip_3#">
	<CFPARAM name="FORM.CommRecip_4" 					default="#Program_Packet.Basic_Information.CommRecip_4#">

	<!---Payable To--->
	<CFPARAM name="FORM.Pay_To_Distributor"			default="#Program_Packet.Basic_Information.Pay_To_Distributor#">
	<CFPARAM name="FORM.Payable_Company"			default="#Program_Packet.Basic_Information.Payable_Company#">
	<CFPARAM name="FORM.Payable_Attention"			default="#Program_Packet.Basic_Information.Payable_Attention#">
	<CFPARAM name="FORM.Payable_Address_1"			default="#Program_Packet.Basic_Information.Payable_Address_1#">
	<CFPARAM name="FORM.Payable_Address_2"			default="#Program_Packet.Basic_Information.Payable_Address_2#">
	<CFPARAM name="FORM.Payable_City"				default="#Program_Packet.Basic_Information.Payable_City#">
	<CFPARAM name="FORM.Payable_State"				default="#Program_Packet.Basic_Information.Payable_State#">
	<CFPARAM name="FORM.Payable_Zip"				default="#Program_Packet.Basic_Information.Payable_Zip#">
	<CFPARAM name="FORM.Payable_Comments"			default="#Program_Packet.Basic_Information.Payable_Comments#">

	<!---Send payment to--->
	<CFPARAM name="FORM.Send_To_Broker"				default="#Program_Packet.Basic_Information.Send_To_Broker#">
	<CFPARAM name="FORM.Send_Company"				default="#Program_Packet.Basic_Information.Send_Company#">
	<CFPARAM name="FORM.Send_Attention"				default="#Program_Packet.Basic_Information.Send_Attention#">
	<CFPARAM name="FORM.Send_Address_1"				default="#Program_Packet.Basic_Information.Send_Address_1#">
	<CFPARAM name="FORM.Send_Address_2"				default="#Program_Packet.Basic_Information.Send_Address_2#">
	<CFPARAM name="FORM.Send_City"					default="#Program_Packet.Basic_Information.Send_City#">
	<CFPARAM name="FORM.Send_State"					default="#Program_Packet.Basic_Information.Send_State#">
	<CFPARAM name="FORM.Send_Zip"					default="#Program_Packet.Basic_Information.Send_Zip#">

	<!--- Auto Renew Data --->
	<CFPARAM name="FORM.AUTO_RENEW"						default="#Program_Packet.Basic_Information.Auto_Renew#">
	<CFPARAM name="FORM.Equipment_Placement"  default="#Program_Packet.Basic_Information.Equipment_Placement#">
	<CFPARAM name="FORM.Equipment_Placement_Note"  default="#Program_Packet.Basic_Information.Equipment_Placement_Note#">
	<CFPARAM name="FORM.Pullback_From_This_Program"			default="#Program_Packet.Basic_Information.Pullback_From_This_Program#">

	<!--- Commented out 1.89 D10573
	<!--- Dev Note: Budgets --->
	<cfif appSettings.getBudgetsOn()
		  AND appSettings.getSelectBudgetsOn() EQ 1
		  AND appSettings.getBudgetRelationshipToPrograms() EQ 1>
		<CFPARAM name="Form.budget_reference_id" default="#Program_Packet.Basic_Information.Budget_Reference_ID#">
	</cfif>
	--->
	<cfparam name="form.Program_Most_Favored_Nation" default="#Program_Packet.Basic_Information.Program_Most_Favored_Nation#" /> <!---42349 --->
	<CFPARAM name="form.Best_Plan_Program" default="0"><!--- 60308--->
	<cfparam name="Program_Packet.Auto_Renew.Recordcount" default="0">
	<!---  34150 - pull auto renew information from parent program  --->
	<cfif vars.Program_Auto_Renew.recordCount gt 0>
		<!--- Auto Renew Data --->
		<cfscript>
			Form.Auto_Renew            = 1;
			Form.AR_Notification_Date  = vars.Program_Auto_Renew.AR_Notification_Date;
			Form.AR_Start_Date 				 = vars.Program_Auto_Renew.AR_Start_Date;
			Form.AR_End_Date					 = vars.Program_Auto_Renew.AR_End_Date;
			Form.AR_Renewal_Type   		 = vars.Program_Auto_Renew.AR_Renewal_Type;
			Form.Renewal_Lead_Time  	 = vars.Program_Auto_Renew.Renewal_Lead_Time;
		</cfscript>
	<cfelseif Program_Packet.Auto_Renew.Recordcount GT 0>

		<CFPARAM name="FORM.AR_Notification_Date"			default="#Program_Packet.Auto_Renew.AR_Notification_Date#">
		<CFPARAM name="FORM.AR_Start_Date" 	default="#Program_Packet.Auto_Renew.AR_Start_Date#">
		<CFPARAM name="FORM.AR_End_Date" 	default="#Program_Packet.Auto_Renew.AR_End_Date#">
		<CFPARAM name="Form.Renewal_Lead_Time" default="#Program_Packet.Auto_Renew.Renewal_Lead_Time#">
		<CFPARAM name="Form.AR_Renewal_Type" default="#Program_Packet.Auto_Renew.AR_Renewal_Type#">

	<cfelse>

		<CFPARAM name="FORM.AR_Renewal_Type" 				default="">
		<CFPARAM name="FORM.Auto_Renew" 					default="0">
		<CFPARAM name="FORM.AR_Notification_Date"			default="">
		<CFPARAM name="FORM.AR_Start_Date" 					default="">
		<CFPARAM name="FORM.AR_End_Date" 					default="">
		<CFPARAM name="Form.Renewal_Lead_Time" 				default="">

	</cfif>

	<!--- Payment Cycle --->
	<CFPARAM name="FORM.PaymentCycle"							default="#Program_Packet.Basic_Information.PaymentCycle#">
	<!--- Currency --->
	<CFPARAM name="FORM.Currency"								default="#Program_Packet.Basic_Information.Currency#">
	<!--- Controllable --->
	<CFPARAM name="FORM.Controllable_Volume"					default="#Program_Packet.Basic_Information.Controllable_Volume#">
	<!--- Growth Inclusion --->
	<CFPARAM name="FORM.Growth_Inclusion"						default="#Program_Packet.Basic_Information.Growth_Inclusion#">
	<!--- Claim Mechanics --->
	<CFPARAM name="FORM.ClaimMechanicOption"					default="#Program_Packet.Basic_Information.ClaimMechanics#">
	<CFPARAM name="FORM.BldUpInvoice" 							default="#Program_Packet.Basic_Information.BldUpInvoice#">
	<!--- Advanced Spending --->
	<CFPARAM name="FORM.Adv_Spending_Amount"					default="#Program_Packet.Basic_Information.Adv_Spending_Amount#">
	<!--- Global GL Assignment --->
	<CFPARAM name="FORM.Global_GL_Assign_Choice"				default="#Program_Packet.Basic_Information.GL_Assignment#">
	<CFPARAM name="FORM.On_Release_Contract_Status_Type_IDX"	default="#Program_Packet.Basic_Information.On_Release_Contract_Status_Type_IDX#">

	<cfif appSettings.getUse_Accounting_Program_Type() EQ 1>
	<CFPARAM name="FORM.Accounting_Program_Type_ID"				default="#Program_Packet.Basic_Information.Accounting_Program_Type_ID#">
	</cfif>

	<cfif appSettings.getProgramCategory() EQ 1>
	<CFPARAM name="FORM.Program_Category_ID"					default="#Program_Packet.Basic_Information.Accounting_Program_Type_ID#"><!--- Dev Note: Milan - D6321 --->
	</cfif>

	<cfif FORM.ISREVISIONOFEXISTINGCONTRACT EQ 1>
		<CFPARAM name="FORM.Effective_Date_for_Price"	default="#GetContractInfo.Effective_Date_for_Price#">
			<CFPARAM name="FORM.Price_Protection_Date"	default="#dateformat(GetContractInfo.Price_Protection_Date, "mm/dd/yyyy")#"><!--- D32776:Effective Price Date Changed on all Bid Programs --->
	<cfelse>
 	<CFPARAM name="FORM.Effective_Date_for_Price"	default="">
 		<CFPARAM name="FORM.Price_Protection_Date"	default=""><!--- D32776:Effective Price Date Changed on all Bid Programs --->
	</cfif>

<!--- -- D38942 :: Program Blackout Period on Frontend START --->
<cfif ISREVISIONOFEXISTINGCONTRACT>
	<cfparam name="form.Program_Start_Zero" default="#Program_Packet.Basic_Information.Program_Start_Zero#" />
	<cfparam name="form.Program_Future_zero" default="#Program_Packet.Basic_Information.Program_Future_Zero#" />
<cfelse>
	<cfparam name="form.Program_Start_Zero" default="0" />
	<cfparam name="form.Program_Future_zero" default="0" />
</cfif>
<!--- -- D38942 :: Program Blackout Period on Frontend START --->
<cfif FORM.ISREVISIONOFEXISTINGCONTRACT EQ 1>
	<cfparam name="FORM.contract_period_start_date" default="#Program_Packet.Basic_Information.contract_period_start_date#">
	<cfparam name="FORM.contract_period_end_date" default="#Program_Packet.Basic_Information.contract_period_end_date#">
<cfelse>
	<cfparam name="FORM.contract_period_start_date" default="">
	<cfparam name="FORM.contract_period_end_date" default="">
</cfif>
</CFIF>

<cfif FORM.ProgramType_ID EQ 0 OR len(trim(ProgramType_ID)) IS 0>

	<div align="center">
		<strong>
			<h1>No template has been selected for this program</h1><br>
			Please return to the <a href="/common_files/select_new_program_type.cfm">program template selection page</a>.
		</strong>
	</div>
	<cfabort>

</cfif>

<!--- LOAD SETTINGS --->
<cfquery name="getFieldSettings" datasource="#application.datasource#">
	SELECT *
	FROM Program_Control_Panel_Options
	WHERE ProgramControl_Panel_Options_ID = <cfqueryparam value='#FORM.ProgramType_ID#'>
</cfquery>

<!---60410 :  Fiscal Year Selection and Auto Renew START--->
	<cfquery name="AutoRenewOptions" datasource="#application.datasource#">
		SELECT Auto_Renew_Option_ID
		FROM Template_Auto_Renew_Options TARO
		INNER JOIN Program_Control_Panel_Options PCPO
		ON PCPO.First_Parent_ID = TARO.Template_First_Parent_ID
		WHERE PCPO.ProgramControl_Panel_Options_ID = <cfqueryparam value="#getFieldSettings.first_parent_id#" cfsqltype="cf_sql_integer">
		AND TARO.Deleted = 0
	</cfquery>
<!---60410 :  Fiscal Year Selection and Auto Renew END--->
<cfif NOT(appSettings.PRICE_LIST_BY_TEMPLATE EQ 1 AND getFieldSettings.Base_Sales_based_on_Prg_Start_Date EQ 1 AND getFieldSettings.Select_Effective_Date_for_Price EQ 1)>
	<cfset FORM.Effective_Date_for_Price = "" />
	<cfset FORM.Price_Protection_Date="" /><!--- D32776:Effective Price Date Changed on all Bid Programs --->
</cfif>

<!---If the setting for auto renew span comes from the program wizard, it will always be the PW value--->
<cfif appSettings.AutoRenewSpaninPW IS 1>
	<cfset FORM.Renewal_Lead_Time	=	"#getFieldSettings.Days_Before_Auto_Renew#">
</cfif>


<!--- AUTO RENEW --->
<CFPARAM name="FORM.AUTO_RENEW_Setting"				default="#valuelist(AutoRenewOptions.Auto_Renew_Option_ID)#"><!---60410 --->
<CFPARAM name="FORM.Allow_AR_Modification"			default="#getFieldSettings.Allow_AR_Modification#">
<!---PayableTo--->
<CFPARAM name="FORM.Payable_To"						default="#getFieldSettings.Payable_To#">
<CFPARAM name="FORM.Send_Payment_To"				default="#getFieldSettings.Send_Payment_To#">
<CFPARAM name="FORM.Payable_To_Required"			default="#getFieldSettings.Payable_To_Required#">
<CFPARAM name="FORM.Send_Payment_To_Required"		default="#getFieldSettings.Send_Payment_To_Required#">
<!---Trade Blurb--->
<CFPARAM name="FORM.Trade_Blurb"					default="#getFieldSettings.Trade_Blurb#">
<!---Customer Acceptance--->
<CFPARAM name="FORM.Customer_Acceptance"			default="#getFieldSettings.Customer_Acceptance#">

<!--- Payment Cycle --->
<CFPARAM name="FORM.PaymentCycle_Setting"			default="#getFieldSettings.PayCycleDefaultOption#">
<!--- Currency --->
<CFPARAM name="FORM.Currency_Default_Setting"		default="#getFieldSettings.CurrencyDefaultOption#">
<!--- Controllable --->
<CFPARAM name="FORM.Controllable_Volume_Setting"	default="#getFieldSettings.Controllable_Volume#">
<!--- Growth Inclusion --->
<CFPARAM name="FORM.Growth_Inclusion_Setting"		default="#getFieldSettings.Growth_Inclusion#">

<CFPARAM name="FORM.ClaimMechDefaultOption_Setting"	default="#getFieldSettings.ClaimMechDefaultOption#">
<!--- Advanced Spending --->
<CFPARAM name="FORM.Adv_Spend_Setting" 				default="#getFieldSettings.Adv_Spend#">
<!--- Retro Creation --->
<CFPARAM name="FORM.Allow_retro_Create_Setting" 	default="#getFieldSettings.Allow_Retro_Create#">
<CFPARAM name="FORM.Allow_Retro_Create_Max_Setting" default="#getFieldSettings.Allow_Retro_Create_Max#">
<!--- Retro Revision --->
<CFPARAM name="FORM.Allow_Retro_Revision" 			default="#getFieldSettings.Allow_Retro_Revision#">
<CFPARAM name="FORM.Allow_Retro_Revision_Span" 		default="#getFieldSettings.Allow_Retro_Revision_Span#">
<!--- Max Duration --->
<CFPARAM name="FORM.Max_Duration_Setting" 			default="#getFieldSettings.Max_Duration#">
<CFPARAM name="FORM.Max_Duration_Length_Setting" 	default="#getFieldSettings.Max_Duration_Length#">
<!--- Max Duration --->
<CFPARAM name="FORM.Min_Duration_Setting" 			default="#getFieldSettings.Min_Duration#">
<CFPARAM name="FORM.Min_Duration_Length_Setting" 	default="#getFieldSettings.Min_Duration_Length#">
<!--- Rate Types --->
<CFPARAM name="FORM.RateTypeOption_1_Setting"		default="#getFieldSettings.RateTypeOption_1#">
<CFPARAM name="FORM.RateTypeOption_2_Setting" 		default="#getFieldSettings.RateTypeOption_2#">
<CFPARAM name="FORM.RateTypeOption_3_Setting" 		default="#getFieldSettings.RateTypeOption_3#">
<CFPARAM name="FORM.RateTypeOption_4_Setting" 		default="#getFieldSettings.RateTypeOption_4#">
<CFPARAM name="FORM.RateTypeOption_5_Setting" 		default="#getFieldSettings.RateTypeOption_5#">
<CFPARAM name="FORM.RateTypeOption_6_Setting" 		default="#getFieldSettings.RateTypeOption_6#">
<CFPARAM name="FORM.RateTypeOption_7_Setting" 		default="#getFieldSettings.RateTypeOption_7#">
<CFPARAM name="FORM.RateTypeOption_8_Setting" 		default="#getFieldSettings.RateTypeOption_8#">
<!--- Dev Note: Get UOM from the app setting and not from the template. We use this app setting on the program
summary page and also on the program flex grid's column (volume).
--->
<CFPARAM name="FORM.ViewProgramVolumeUOM" 		default="#appSettings.getViewProgramVolumeUOM()#">
<!--- Payment Cycles --->
<CFPARAM name="FORM.PayCycleOption_1_Setting" 		default="#getFieldSettings.PayCycleOption_1#">
<CFPARAM name="FORM.PayCycleOption_2_Setting" 		default="#getFieldSettings.PayCycleOption_2#">
<CFPARAM name="FORM.PayCycleOption_3_Setting" 		default="#getFieldSettings.PayCycleOption_3#">
<CFPARAM name="FORM.PayCycleOption_4_Setting" 		default="#getFieldSettings.PayCycleOption_4#">
<CFPARAM name="FORM.PayCycleOption_5_Setting" 		default="#getFieldSettings.PayCycleOption_5#">
<CFPARAM name="FORM.PayCycleOption_6_Setting" 		default="#getFieldSettings.PayCycleOption_6#">
<CFPARAM name="FORM.PayCycleOption_7_Setting" 		default="#getFieldSettings.PayCycleOption_7#">
<CFPARAM name="FORM.PayCycleDefaultOption_Setting" 	default="#getFieldSettings.PayCycleDefaultOption#">
<!--- Max Global Volume --->
<CFPARAM name="FORM.Max_Global_Volume_Setting" 			default="#getFieldSettings.Max_Global_Volume#">
<CFPARAM name="FORM.Max_Global_Volume_Size_CS_Setting" 	default="#getFieldSettings.Max_Global_Volume_Size_CS#">
<CFPARAM name="FORM.Max_Global_Volume_Size_LBS_Setting" default="#getFieldSettings.Max_Global_Volume_Size_LBS#">

<!--- Min Global Volume --->
<CFPARAM name="FORM.Min_Global_Volume_Setting" 			default="#getFieldSettings.Min_Global_Volume#">
<CFPARAM name="FORM.Min_Global_Volume_Size_CS_Setting" 	default="#getFieldSettings.Min_Global_Volume_Size_CS#">
<CFPARAM name="FORM.Min_Global_Volume_Size_LBS_Setting" default="#getFieldSettings.Min_Global_Volume_Size_LBS#">

<!--- Globabl GL Assignment --->
<CFPARAM name="FORM.Global_GL_Assign_Setting" 			default="#getFieldSettings.Global_GL_Assign#">
<CFPARAM name="FORM.Global_GL_Assign_Choice_Setting" 	default="#getFieldSettings.Global_GL_Assign_Choice#">
<!--- Rebate Types --->
<CFPARAM name="FORM.Rebate_Basic_Setting" 				default="#getFieldSettings.Rebate_Basic#">
<CFPARAM name="FORM.Fixed_Price_Setting" 				default="#getFieldSettings.Fixed_Price#">
<CFPARAM name="FORM.Delivered_Price_Setting" 			default="#getFieldSettings.Delivered_Price#">
<CFPARAM name="FORM.FOB_Price_Setting" 					default="#getFieldSettings.FOB_Price#">
<CFPARAM name="FORM.Equipment_Placement" 				default="#getFieldSettings.Equipment_Placement#">

<!--- Program start/end day --->
<CFPARAM name="FORM.Program_Start_Day_Number" 					default="#val(getFieldSettings.Program_Start_Day)#">
<CFPARAM name="FORM.Program_End_Day_Number" 				default="#val(getFieldSettings.Program_End_Day)#">

<CFPARAM name="FORM.Include_Open_Date" 					default="#val(getFieldSettings.Include_Open_Date)#">
<CFPARAM name="FORM.Include_Date_Needed_by" 				default="#val(getFieldSettings.Include_Date_Needed_by)#">
<CFPARAM name="FORM.Include_Reply_Date" 				default="#val(getFieldSettings.Include_Reply_Date)#">
<!--- D10573
<!--- Dev Note: Budgets --->
<cfparam name="Form.budget_reference_id" 				default="">
--->
<!--- END LOAD SETTINGS --->

<cfset useLakebaseForGetUOMs = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("units_of_measure")>
<cfif useLakebaseForGetUOMs>
	<cftry>
		<cfset GetUOMsFilterList = "0">
		<cfif FORM.RateTypeOption_1_Setting EQ 1><cfset GetUOMsFilterList = ListAppend(GetUOMsFilterList, "2")></cfif>
		<cfif FORM.RateTypeOption_2_Setting EQ 1><cfset GetUOMsFilterList = ListAppend(GetUOMsFilterList, "1")></cfif>
		<cfset GetUOMs = application.oLakebase.toQuery(
			application.oLakebase.selectRows("units_of_measure", { "unit_of_measure_id" = "in.(#GetUOMsFilterList#)" })
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetUOMs = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetUOMs>
	<cfquery name="GetUOMs" datasource="#application.datasource#">
		SELECT 	*
		FROM 	Units_Of_Measure
		WHERE 	Unit_Of_Measure_ID IN(0<cfif FORM.RateTypeOption_1_Setting EQ 1>,2</cfif><cfif FORM.RateTypeOption_2_Setting EQ 1>,1</cfif>)
	</cfquery>
</cfif>

<!--- Max Length for Program Title --->
<CFQUERY NAME="qryUsersSettings" datasource="#application.datasource#">
SELECT 	Max_Program_Title_Length, Pullback_Modify_Corporate_Program_Rates
FROM	_Users_Settings
</CFQUERY>

<CFPARAM NAME="Form.Document_ID" DEFAULT="ContractGeneralInfo">

<cfset labelnotes = appSettings.getLabelNotes()>
<!--- Commented out 1.89 1.105 D10573
<!---Dev Note: CPM  Budgets --->
<cfif appSettings.getBudgetsOn() >
	<cfset budgetsFromTemplate = createobject("component","components.programs.budgets.programbudgetmanager").getBudgetsFromTemplate(FORM.ProgramType_ID) />
</cfif>
--->


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<SCRIPT language="JavaScript" src="/Common_Files/scripts/numberValidation.js"></SCRIPT>
	<SCRIPT language="JavaScript" src="/Common_Files/scripts/requiredFields.js"></SCRIPT>
	<SCRIPT language="JavaScript" src="/Common_Files/scripts/allowonlytwodecimalplaces.js"></SCRIPT>
	<SCRIPT language="JavaScript" src="/Common_Files/scripts/formattotwodecimals.js"></SCRIPT>
	<SCRIPT language="JavaScript" src="/script/javascript/string_functions.js"></SCRIPT>
	<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
	<SCRIPT SRC="/common_files/scripts/Date_Difference.js"></SCRIPT>
	<SCRIPT SRC="/Script/javascript/validateFormUtils.js"></SCRIPT>
	<SCRIPT SRC="/Script/javascript/date_functions.js"></SCRIPT>
	<SCRIPT SRC="/Script/javascript/time.js"></SCRIPT>
	<script>

		<!--- <CFINCLUDE TEMPLATE="/script/javascript/string_functions.js"> --->
		window.thisURL="contract_create_1_form.cfm";

		<cfif GETFIELDSETTINGS.Date_Exclusions_On EQ 1>
			var showExclusionWarning = 1;
			function warnOfExclusionDelete()
			{
				if(showExclusionWarning == 1)
				{
					if(confirm("If you modify the start or end date of this program any existing exclusion dates and their programs will be deleted. Press OK to suppress further warnings."))
					{
						showExclusionWarning = 0;
					}
				}
			}
		</cfif>

	</script>

</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" onLoad="">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "gi">

<cfif application.programlayout EQ 1>

	<div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 1; left: 10px; top: 0px;">
		<CFINCLUDE TEMPLATE="contract_status_legend.cfm">
	</div>

<cfelse>

	<CFINCLUDE TEMPLATE="contract_status_legend.cfm">

</cfif>

<!---if Program_Date_Type is defined in the GetSettings query then set it--->
<cfif isDefined("GetSettings.Program_Date_Type")>
	<cfset form.Program_Date_Type = GetSettings.Program_Date_Type />
</cfif>

<!--- <BLOCKQUOTE> --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!------<CFSET helpfilenumber= 3>
	<CFINCLUDE TEMPLATE="/help_files/help_link.cfm">----->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfparam name="form.Program_ID" default="">
<cfif form.Program_ID neq "">
	<CF_CRYP type="de" string="#form.Program_ID#" key="#request.key#" return="ProgramID">
	<cfset RevisionSettingsInfo = RevisionSettingsManager.getRevisionInfo(ProgramID.value)>
<cfelseif URL.CID neq "">
	<cfset ParentProgramInfo = programManager.getParentProgramInfo(URL.CID)>
	<cfset RevisionSettingsInfo = RevisionSettingsManager.getRevisionInfo(ParentProgramInfo.Revision_of_Contract_Main_ID)>
</cfif>

<!---TSF - Label 14692: Throw an alert if this is a revision with auto pay components in the parent and the start date of the revision is before the
start date of the parent.
-- form.ISREVISIONOFEXISTINGCONTRACT = 1
-- parent contract_main_id
-- call function to see if the parent has any auto pay components
-- RevisionSettingsInfo.Contract_Start_Date
--->
<cfif form.ISREVISIONOFEXISTINGCONTRACT and programManager.programHasAutoPayComponents(RevisionSettingsInfo.Contract_Main_ID)>
	<!---Tim Ford - Label 14893: Removed since the logic changed from checking the parent start date to checking todays date--->
	<!--- <cfset FORM.parentStartDate = RevisionSettingsInfo.Contract_Start_Date /> --->
	<cfset FORM.checkParentStartDate = 1 />
</cfif>

<cfif RevisionSettings.Apply_to_All eq 1 OR (RevisionSettings.Apply_to_All eq 2 AND Form.Contract_Reference_Number neq "")>
	<cfset Revision_Settings_Allowed = 1>
</cfif>

<cfset IsRevision = 0>
	<cfif  (RevisionStatus.Is_A_Revision eq 1 OR FORM.IsRevisionOfExistingContract EQ 1) AND Revision_Settings_Allowed eq 1>
		<cfset IsRevision  = 1>
	</cfif>
<BR><BR>
<!--- <CFPARAM name="FORM.Distributor_List" default=""> --->
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/dhtml.js" />
<cfoutput>
<cfif application.programlayout EQ 1>
 <div id="Layer1" style="position:relative; width:200px; z-index:1; left: 150px; top: 10px;"> </cfif>
<cfset FORM.Responsible_User_Id = ListLast(FORM.Responsible_User_Id_Position_Id, "_")>

<FORM ACTION="Contract_Create_1_form.cfm?CID=#EncrypCID#" METHOD="post" NAME="MyForm">
<!--- <INPUT TYPE="Text" NAME="Distributor_List" VALUE="#FORM.Distributor_List#"> --->

	<TABLE BORDER="0" CELLSPACING="10" CELLPADDING="0" width="750">
		<TR>
			<TD align="right" nowrap><B><!--- Program Number --->#application.returned_customer_setting.Program_Number_Label#:</B></TD>
			<TD rowspan="100%" bgcolor="0000CC">&nbsp;</TD>
			<TD>

				<CFIF len(URL.CID) GT 0>
					<FONT SIZE="+1">#FORM.Contract_Number#</FONT>
				<CFELSE>
					<FONT SIZE="+1">#FORM.Contract_Number#</FONT>
					<!--- <FONT SIZE="+1"><CFSET temp = randrange(11111111,99999999)><INPUT TYPE="hidden" NAME="Contract_Number" VALUE="<CFOUTPUT>#temp#</CFOUTPUT>"><CFOUTPUT>#temp#</CFOUTPUT></FONT> --->
				</CFIF>
				<INPUT TYPE="hidden" NAME="Contract_Number" VALUE="<CFOUTPUT>#FORM.Contract_Number#</CFOUTPUT>">
				<INPUT TYPE="hidden" NAME="TemplateFiltersId" VALUE="<CFOUTPUT>#FORM.TemplateFiltersId#</CFOUTPUT>">
			</TD>
		</TR>
		<!------ Operating Group ----->
		<cfif appSettings.getOperatingGroupOn()>
			<!------ Get responsible user's profile ----->
			<cfset qUser = userManager.getUser(FORM.Responsible_User_Id) />
			<cfset rspProfileID = qUser.profiles_id >

			<!------ Get the operating groups available for the responsible sales person profile and this template ----->
			<cfset operatingGroupManager 			= CreateObject("component", "components.Operating_Group.OperatingGroupManager").init() />

			<cfset programLevel1Level 				= operatingGroupManager.getProgramLevel1Level() />
			<cfset programLevel1LevelLabel 			= operatingGroupManager.getLabel(programLevel1Level) />

			<cfset programLevel2Level 				= operatingGroupManager.getProgramLevel2Level() />
			<cfset programLevel2LevelLabel 			= operatingGroupManager.getLabel(programLevel2Level) />

			<cfset allowOpGrpSelection = 1 />
			<cfif (len(URL.CID) GT 0 AND CSLGetContractInfo.Contract_Status_Type_IDX GTE 3) OR FORM.ISREVISIONOFEXISTINGCONTRACT IS 1 >
				<cfset allowOpGrpSelection = 0 />
			</cfif>
			<TR>
				<TD align="right" nowrap>
					<B><span id="error_Operating_Group_1"></span>#programLevel1LevelLabel#:</B><br><br>
					<B><span id="error_Operating_Group_2"></span>#programLevel2LevelLabel#:</B>
				</TD>
				<TD>
				<!---
					Dev Note: Clay 11105 - Make Operating Groups a part of Search Sequence Copy
				 --->
				<cfif allowOpGrpSelection>
					<cfset qOperatingGroupForTemplateProfile = operatingGroupManager.getOperatingGroupsWithFilters(level1=programLevel1Level, level2=programLevel2Level, profileId=rspProfileID, templateId=FORM.ProgramType_ID, active=1) />
					<cfquery dbtype="query" name="operatingGrp1">
						select distinct Operating_Group_1_ID
						from qOperatingGroupForTemplateProfile
					</cfquery>
					<cfif operatingGrp1.recordCount eq 1>
						<cfset passedText = "" >
					<cfelse>
						<cfset passedText = "Select #programLevel1LevelLabel#" >
					</cfif>

					<cfif len(url.cid) GT 0>
						<cfset validationstring = "SearchSequenceCopy();"/>
					<cfelse>
						<cfset validationstring = ""/>
					</cfif>

					<cfparam name="form.Operating_Group_Level_1_ID" default="0" />
					<cfparam name="form.Operating_Group_Level_2_ID" default="0" />

					<cfif URL.CID GT 0 OR (FORM.NEW_BUSINESS_SEGMENT GT 0 OR FORM.NEW_SPENDING_CATEGORY GT 0)>

					<!--- Dev Note: Clay 11232: WIP   --->

					<!--- If URL.CID IS 0, Need to Use Copied Program_ID to get OperGrp Values --->

					<cfif IsDefined("ProgramID.value")>
						<cfset tempCID = ProgramID.value />
					<cfelseif IsDefined("URL.CID")>
						<cfset tempCID = Url.CID />
					<cfelse>
						<cfset tempCID = 0 />
					</cfif>

					<!--- Get OprGrp Values --->

					<cfif form.New_Business_Segment>
						<cfset FORM.Operating_Group_Level_1_ID = Form.New_Business_Segment >
					<cfelse>
						<cfset FORM.Operating_Group_Level_1_ID = operatingGroupManager.getProgramOperatingGroupID(level=programLevel1Level, programId=tempCID) />
					</cfif>

					<cfif form.New_Spending_Category>
						<cfset FORM.Operating_Group_Level_2_ID = form.New_Spending_Category>
					<cfelse>
						<cfset FORM.Operating_Group_Level_2_ID = operatingGroupManager.getProgramOperatingGroupID(level=programLevel2Level, programId=tempCID) />
					</cfif>

					<cfset passedText2 = operatingGroupManager.getOperatingGroupDesc(FORM.Operating_Group_Level_2_ID) />
					<cfif len(passedText2) EQ 0>
						<cfset passedText2 = "Select #programLevel2LevelLabel#"/>
					</cfif>
								<cfparam name="form.Operating_Group_1" default="#form.Operating_Group_Level_1_ID#"/>
								<cfparam name="form.Operating_Group_2" default="#form.Operating_Group_Level_2_ID#"/>
								<CF_TwoSelectsRelated
									QUERY="qOperatingGroupForTemplateProfile"
									NAME1="Operating_Group_1"
									NAME2="Operating_Group_2"
									ForceWidth1="275"
									ForceWidth2="275"
									DISPLAY1="Operating_Group_#programLevel1Level#_Desc"
									DISPLAY2="Operating_Group_#programLevel2Level#_Desc"
									VALUE1="Operating_Group_#programLevel1Level#_ID"
									VALUE2="Operating_Group_#programLevel2Level#_ID"
									SIZE1="1"
									SIZE2="1"
									EmptyText1="#passedText#"
									EmptyText2="#passedText2#"
									HTMLBETWEEN="<br><br>"
									AUTOSELECTFIRST="Yes"
									PassedValue1="#FORM.Operating_Group_1#"
									PassedValue2="#FORM.Operating_Group_2#"
									OnChange="#validationstring#"
									FORMNAME="MyForm">
						<cfelse>
								<cfparam name="form.Operating_Group_1" default="#form.Operating_Group_Level_1_ID#"/>
								<cfparam name="form.Operating_Group_2" default="#form.Operating_Group_Level_2_ID#"/>
								<CF_TwoSelectsRelated
									QUERY="qOperatingGroupForTemplateProfile"
									NAME1="Operating_Group_1"
									NAME2="Operating_Group_2"
									ForceWidth1="275"
									ForceWidth2="275"
									DISPLAY1="Operating_Group_#programLevel1Level#_Desc"
									DISPLAY2="Operating_Group_#programLevel2Level#_Desc"
									VALUE1="Operating_Group_#programLevel1Level#_ID"
									VALUE2="Operating_Group_#programLevel2Level#_ID"
									SIZE1="1"
									SIZE2="1"
									EmptyText1="#passedText#"
									EmptyText2="Select #programLevel2LevelLabel#"
									PassedValue1="#FORM.Operating_Group_1#"
									PassedValue2="#FORM.Operating_Group_2#"
									HTMLBETWEEN="<br><br>"
									AUTOSELECTFIRST="Yes"
									FORMNAME="MyForm">
					</cfif>
				<cfelse>
					<cfif NOT isDefined("FORM.CONTRACT_RENEWAL_PACKETS_ID")>
						<cfparam name="FORM.Operating_Group_Level_1_ID" 	default="#operatingGroupManager.getProgramOperatingGroupID(level=programLevel1Level, programId=URL.CID)#">
						<cfparam name="FORM.Operating_Group_Level_2_ID" 	default="#operatingGroupManager.getProgramOperatingGroupID(level=programLevel2Level, programId=URL.CID)#">
					</cfif>
					<cfparam name="form.Operating_Group_Level_1_ID" default="0" />
					<cfparam name="form.Operating_Group_Level_2_ID" default="0" />
					<cfset operatingGroupProgramLevel1Desc = operatingGroupManager.getOperatingGroupDesc(FORM.Operating_Group_Level_1_ID) />
					<cfset operatingGroupProgramLevel2Desc = operatingGroupManager.getOperatingGroupDesc(FORM.Operating_Group_Level_2_ID) />
					#operatingGroupProgramLevel1Desc#<br><br>
					#operatingGroupProgramLevel2Desc#
					<input type="Hidden" name="Operating_Group_1" value="#FORM.Operating_Group_Level_1_ID#" />
					<input type="Hidden" name="Operating_Group_2" value="#FORM.Operating_Group_Level_2_ID#" />
				</cfif>
				</TD>
			</TR>
		</cfif>

		<!---FILTER: business segments--->
		<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
		<cfif businessSegManager.isEnabled()>
			<cfset form.businessSegmentsOn = 1 />
		</cfif>

		<!---show business segments if it's enabled--->
		<cfif form.businessSegmentsOn eq 1>

			<!---get the list of business segments--->
			<cfif appSettings.getFilterBusinessSegments()>
				<cfset qGetBusSegments = businessSegManager.getActive(Form.Responsible_User_Id, FORM.ProgramType_ID) />
			<cfelse>
				<cfset qGetBusSegments = businessSegManager.getActive(Form.Responsible_User_Id) />
			</cfif>
			<cfset qSegmentChange =  businessSegManager.getEnabled() />
			<TR>
				<TD align="right" nowrap valign="top"><B><span id="error_BusinessSegment"></span>#appSettings.getbusiness_segment_label()#:</B></TD>
				<TD>
						<cfset CONTRACTMAINID = ''>
						<CFIF len(URL.CID) GT 0>
							<cfset CONTRACTMAINID = URL.CID>
						<cfelseif isdefined('Program_Packet.Basic_Information.CONTRACT_MAIN_ID')>
							<cfset CONTRACTMAINID =Program_Packet.Basic_Information.CONTRACT_MAIN_ID>
						</cfif>
						<cfif len(CONTRACTMAINID)>
							<cfset busSegIdForProgram = businessSegManager.getSegmentIdByProgram(CONTRACTMAINID) />
							<cfset qGetThisBusSegment = businessSegManager.get(busSegIdForProgram) />
							<cfset FORM.Business_Segment_ID = qGetThisBusSegment.Business_Segment_ID />
						</cfif>

					<CFIF ! qSegmentChange.Allow_Segment_Change AND len(CONTRACTMAINID)>
						#qGetThisBusSegment.Business_Unit_Desc#
						<INPUT TYPE="hidden" NAME="Business_Segment_ID" VALUE="#FORM.Business_Segment_ID#">
					<CFELSE>
						<cfif qGetBusSegments.recordCount EQ 1>
							#qGetBusSegments.Business_Unit_Desc#
							<INPUT TYPE="hidden" NAME="Business_Segment_ID" VALUE="#qGetBusSegments.Business_Segment_ID#">
						<cfelse>
						<span id="err_Business_Segment_ID"></span>
							<!--- 64860 :: Update Segments selection on programs --->

							<cfif businessSegManager.getEnabled().Allow_Multiple_Segment>
							<cfset rowMax = 4>
							 <table cellpadding="0" cellspacing="0" width="100%" border="0">
          						<tr>
									<cfloop query="qGetBusSegments">
										<td>
											<INPUT name="Business_Segment_ID" type="checkbox" value="#Business_Segment_ID#" <CFIF Business_Segment_ID EQ FORM.Business_Segment_ID >checked</CFIF>>#Business_Unit_Desc#
										</td>
									 	<cfoutput><cfif (qGetBusSegments.currentRow mod rowMax) eq 0> </tr> <cfif qGetBusSegments.currentRow lt qGetBusSegments.recordCount> <tr> </cfif> </cfif></cfoutput>
									</cfloop>
							</table>
							<cfelse>
								<select name="Business_Segment_ID">
									<option value="0">Choose</option>
									<cfloop query="qGetBusSegments">
										<option value="#Business_Segment_ID#" <CFIF Business_Segment_ID EQ FORM.Business_Segment_ID >Selected</CFIF>>#Business_Unit_Desc#</option>
									</cfloop>
								</select>
							</cfif>
						</cfif>
					</CFIF>
				</TD>
			</TR>
		</cfif>

		<!---Search sequences--->
		<cfif appSettings.getSearchSequenceOn()>
			<cfset searchSequenceManager = CreateObject("component", "components.Search_Sequence.SearchSequenceManager").init() />
			<cfset SearchSequence = searchSequenceManager.getSelectedSearchSequenceForTemplate(FORM.ProgramType_ID) />
			<cfif SearchSequence.Recordcount GT 0>
			<TR>
				<TD align="right" nowrap><B><span id="error_SearchSequence"></span>Search Sequence:</B></TD>
				<TD>
				<!------ If the search sequence is defined, contract is not a revision, and contract is not approved. ----->
				<CFIF 		CSLGetContractInfo.Contract_Status_Type_IDX LT 3 AND
							(len(URL.CID) GT 0 AND FORM.ISREVISIONOFEXISTINGCONTRACT IS 0)
							AND Len(trim(form.Search_Sequence_ID)) GT 0
							AND form.Search_Sequence_ID IS NOT "Null">
					<select name="Search_Sequence_ID" onChange="SearchSequenceCopy(this.options[this.selectedIndex].value);">
						<cfloop query="SearchSequence">
							<option value="#Search_Sequence_ID#" <cfif Search_Sequence_ID IS Form.Search_Sequence_ID>selected</cfif>>#Search_Sequence_Legacy# #Search_Sequence_Desc#</option>
						</cfloop>
					</select>
				<!--- If the search sequence is selected and contract is a revision or has been approved. --->
				<CFELSEIF 	(len(URL.CID) GT 0 OR FORM.ISREVISIONOFEXISTINGCONTRACT IS 1)
						AND Len(trim(form.Search_Sequence_ID)) GT 0
						AND form.Search_Sequence_ID IS NOT "Null">
					<cfset Search_Sequence_Name = searchSequenceManager.getSearchSequenceInfo(form.Search_Sequence_ID) />
					#Search_Sequence_Name.Search_Sequence_Legacy# #Search_Sequence_Name.Search_Sequence_Desc#
					<input type="hidden" name="Search_Sequence_ID" value="#form.Search_Sequence_ID#">
				<CFELSE>
					<select name="Search_Sequence_ID">
						<cfloop query="SearchSequence">
							<option value="#Search_Sequence_ID#" <cfif Search_Sequence_ID IS Form.Search_Sequence_ID>selected<cfelseif Search_Sequence_ID IS Form.NewSearchSequence>selected</cfif>>#Search_Sequence_Legacy# #Search_Sequence_Desc#</option>
						</cfloop>
					</select>
				</CFIF>
				</TD>
			</TR>
			<!---There were results returned for search sequence--->
			</CFIF>
		</cfif>
		<!---End Search Sequence--->

		<cfif appSettings.getSalesOrgOn()>
			<cfset LOBManager = CreateObject("component", "components.programs.business_segment.LOBManager") />
			<!---get the list of business segments--->
			<cfset qGetLOB = LOBManager.getActiveLOB(Form.Responsible_User_Id) />
			<TR>
				<TD align="right" nowrap><B><span id="error_LOB"></span>#application.returned_customer_setting.lob_label_plural#:</B></TD>
				<TD>
					<CFIF len(URL.CID) GT 0>
						<!---if the program has already been saved then let's get the name of the business segment--->
						<cfset LOBIdForProgram = LOBManager.getLOBIdByProgram(URL.CID) />
					<cfif LOBIdForProgram NEQ "">
						<cfset qGetThisLOB = LOBManager.get(LOBIdForProgram) />
						<cfset FORM.LOB_ID = qGetThisLOB.Line_Of_Business_ID />
						#qGetThisLOB.Line_Of_Business_Name#
					<cfelse>
						<cfset FORM.LOB_ID = "">
						No #application.returned_customer_setting.lob_label_plural#
					</cfif>
						<INPUT TYPE="hidden" NAME="LOB_ID" VALUE="#FORM.LOB_ID#">
					<cfelseif isDefined("FORM.CONTRACT_RENEWAL_PACKETS_ID")>
						<cfset LOBIdForProgram = LOBManager.getLOBIdByProgram(Program_Packet.Basic_Information.CONTRACT_MAIN_ID) />
					<cfif LOBIdForProgram NEQ "">
						<cfset qGetThisLOB = LOBManager.get(LOBIdForProgram) />
						<cfset FORM.LOB_ID = qGetThisLOB.Line_Of_Business_ID />
						#qGetThisLOB.Line_Of_Business_Name#
					<cfelse>
						<cfset FORM.LOB_ID = "">
						No #application.returned_customer_setting.lob_label_plural#
					</cfif>
						<INPUT TYPE="hidden" NAME="LOB_ID" VALUE="#FORM.LOB_ID#">
					<cfelse>
						<cfif qGetLOB.recordCount EQ 1>
							#qGetLOB.Line_Of_Business_Name#
							<INPUT TYPE="hidden" NAME="LOB_ID" VALUE="#qGetLOB.Line_Of_Business_ID#">
						<cfelse>
						<span id="err_LOB_ID"></span>
							<select name="LOB_ID">
								<option value="0">Choose</option>
								<cfloop query="qGetLOB">
									<option value="#Line_Of_Business_ID#" <CFIF IsDefined("FORM.LOB_ID")><CFIF Line_Of_Business_ID EQ FORM.LOB_ID>SELECTED</CFIF></CFIF>>#Line_Of_Business_Name#</option>
								</cfloop>
							</select>
						</cfif>
					</CFIF>
				</TD>
			</TR>
		</cfif>

		<!---Only display if there are discount identifiers--->
		<cfset Discount_Identifier_Number = ''>
		<cfif getGeneralSettings.Use_Discount_ID IS 1 AND len(trim(getFieldSettings.Discount_Identifier_ID)) GT 0>
			<cfset useLakebaseForGetDiscountIdentifier = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("discount_identifier")>
<cfif useLakebaseForGetDiscountIdentifier>
	<cftry>
		<cfset GetDiscountIdentifier = application.oLakebase.toQuery(
			application.oLakebase.selectRows("discount_identifier", {
				"discount_identifier_id" = "eq.#getFieldSettings.Discount_Identifier_ID#",
				"select" = "discount_identifier_number,discount_identifier_desc"
			}), "discount_identifier_number,discount_identifier_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetDiscountIdentifier = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetDiscountIdentifier>
<cfquery name="GetDiscountIdentifier" datasource="#application.datasource#">
			SELECT Discount_Identifier_Number, Discount_Identifier_Desc
			FROM Discount_Identifier
			WHERE Discount_Identifier_ID = '#getFieldSettings.Discount_Identifier_ID#'
			</cfquery>
</cfif>
			<cfset Discount_Identifier_Number = GetDiscountIdentifier.Discount_Identifier_Number>
			<TR>
				<TD align="right" nowrap valign="top"><B>Discount Identifier:</B></TD>
				<TD>
					#GetDiscountIdentifier.Discount_Identifier_Number#<br>#GetDiscountIdentifier.Discount_Identifier_Desc#
				</TD>
			</TR>
		</cfif>

		<!---Only display for Accounting Program Types--->
		<cfif appSettings.getUse_Accounting_Program_Type() EQ 1>
			<cfquery name="GetTypesfromTemplate" datasource="#application.datasource#">
			SELECT DISTINCT Accounting_Program_Type.Accounting_Program_Type_ID, APT_Name, APT_Reference_Number, APT_Use_For_TPA
			FROM Accounting_Program_Type
				INNER JOIN APT_Template_Mapping
				ON Accounting_Program_Type.Accounting_Program_Type_ID = APT_Template_Mapping.Accounting_Program_Type_ID
				AND APT_Template_Mapping.Template_ID = '#FORM.ProgramType_ID#'
			</cfquery>

			<cfif GetTypesfromTemplate.Recordcount GT 0>
			<TR>
			<TD align="right" nowrap><B>Program Label:</B></TD>
			<TD>
				<cfif GetTypesfromTemplate.Recordcount IS 1>
				<input type="hidden" name="Accounting_Program_Type_ID" value="#GetTypesfromTemplate.Accounting_Program_Type_ID#">
				#GetTypesfromTemplate.APT_Name# <cfif len(trim(GetTypesfromTemplate.APT_Reference_Number)) GT 0> - #GetTypesfromTemplate.APT_Reference_Number#</cfif>
				<cfelse>
				<select name="Accounting_Program_Type_ID">
					<cfloop query="GetTypesfromTemplate">
					<option value="#GetTypesfromTemplate.Accounting_Program_Type_ID#" <cfif Form.Accounting_Program_Type_ID IS GetTypesfromTemplate.Accounting_Program_Type_ID>selected</cfif>>#GetTypesfromTemplate.APT_Name# <cfif len(trim(GetTypesfromTemplate.APT_Reference_Number)) GT 0>(#GetTypesfromTemplate.APT_Reference_Number#)</cfif></option>
					</cfloop>
				</select>
				</cfif>
			</TD>
		</TR>
			<!---At least there's one--->
			</cfif>
		</cfif>


		<TR>
			<TD align="right" nowrap><B><span id="error_ContractNumber"></span>#application.returned_customer_setting.reference_number_label#:</B></TD>
			<TD>
			<cfif application.returned_customer_setting.reference_number_editable>
			<INPUT MAXLENGTH="200" type="text" name="Contract_Reference_Number" size="15" VALUE="#FORM.Contract_Reference_Number#">
			<cfelse>
			<INPUT MAXLENGTH="200" type="text" size="15" VALUE="#FORM.Contract_Reference_Number#" style="color:silver; border:1px solid silver;" disabled>
			<INPUT MAXLENGTH="200" type="hidden" name="Contract_Reference_Number" size="15" VALUE="#FORM.Contract_Reference_Number#">
			</cfif>
			</TD>
		</TR>

<!--- 77539 :: Program Basic Info - additional field for reference # START--->
<cfif GetSettings.allow_Reference_2 EQ 1>
		<TR>
			<TD align="right" nowrap><B><span id="error_Contract_Reference_Number_2"></span>#application.returned_customer_setting.reference_number_2_label#:</B></TD>
			<TD>
			<cfif application.returned_customer_setting.reference_number_2_editable>
			<INPUT MAXLENGTH="200" type="text" name="Contract_Reference_Number_2" size="15" VALUE="#FORM.Contract_Reference_Number_2#">
			<cfelse>
			<INPUT MAXLENGTH="200" type="text" size="15" VALUE="#FORM.Contract_Reference_Number_2#" style="color:silver; border:1px solid silver;" disabled>
			<INPUT MAXLENGTH="200" type="hidden" name="Contract_Reference_Number_2" size="15" VALUE="#FORM.Contract_Reference_Number_2#">
			</cfif>
			</TD>
		</TR>
</cfif>
<!--- 77539 :: Program Basic Info - additional field for reference # END--->
		<!----Display legacy id if it's on--->
		 <!--- Dev Note: Milan 9360 --->
		<cfif appSettings.getView_Legacy_ID() EQ 1>
			<cfset variables.legacyIDLabel 	= labelComp.GetGeneralLabels('Legacy ID').General_Labels_Label />
			<cfif FORM.legacy_id eq "NULL">
					<cfset FORM.legacy_id = "">
			</cfif>
			<TR>
			<TD align="right" nowrap><B>#variables.legacyIDLabel#:</B></TD>
			<TD><INPUT MAXLENGTH="50" type="text" name="legacy_id" size="15" VALUE="<cfoutput>#FORM.legacy_id#</cfoutput>" <cfif appSettings.getModify_Legacy_ID() EQ 0>style="color:silver; border:1px solid silver;" disabled</cfif>></TD>
		</TR>
		</cfif>

		<!----Display bid id if it's on--->
		<cfif application.returned_customer_setting.display_bid_id>
			<cfset bidIdEditable = false>
			<cfset qComp = CreateObject("component", "components.programs.discount_identifier.DiscountIdentifier").getComp(getFieldSettings.Discount_Identifier_ID) />
			<cfif qComp.Discount_Identifier_Number EQ "BDS" AND application.returned_customer_setting.bid_id_editable EQ 1>
				<cfset bidIdEditable = true>
			</cfif>
			<TR>
			<TD align="right" nowrap><B>Bid ID:</B></TD>
			<TD><INPUT MAXLENGTH="50" type="text" name="bid_id" size="15" VALUE="<cfoutput>#FORM.bid_id#</cfoutput>" <cfif not bidIdEditable> style="color:silver; border:1px solid silver;" disabled</cfif>></TD>
		</TR>
		</cfif>

		<cfif application.returned_customer_setting.responsible_person>
			<cfset userManager = CreateObject("component", "components.user.UserManager") />
			<cfset Users = userManager.getUser(FORM.Responsible_User_Id) />
		<TR>
			<TD align="right" nowrap><B>Responsible Sales Person:</B></TD>
			<TD>#Users.User_Full_Name#
			<input type="Hidden" name="Responsible_User_Id_Position_Id" value="#Form.Responsible_User_Id_Position_Id#">
			</TD>
		</TR>
		</cfif>
		<TR>
			<TD align="right" nowrap VALIGN="top"><span id="error_ContractTitle"></span>&nbsp;<B>Program Title/Description:</B></TD>
			<TD>
				<CFSET Contract_Title_Max_Length = qryUsersSettings.Max_Program_Title_Length>
				<TEXTAREA COLS="57" ROWS="3" NAME="Contract_Title" onPaste="javaScript: return textareaChecklength(#Contract_Title_Max_Length#, this);"  onkeyPress="javaScript: return textareaChecklength(#Contract_Title_Max_Length#, this);" <cfif IsRevision EQ 1 AND RevisionSettings.Title_Changes eq 2> DISABLED STYLE="background-color: cccccc" </cfif>>#FORM.Contract_Title#</TEXTAREA>

				<cfif IsRevision EQ 1 AND RevisionSettings.Title_Changes eq 2>
					<input type="hidden" name="Contract_Title" value="#FORM.Contract_Title#">
				</cfif>
			</TD>
		</TR>
</cfoutput>

<cfif isDefined("FORM.CONTRACT_RENEWAL_PACKETS_ID")>
	<cfset Contract_ID = Program_Packet.Basic_Information.CONTRACT_MAIN_ID>
<cfelseif isDefined("CSL_Contract_Main_ID")>
	<cfset Contract_ID = CSL_Contract_Main_ID>
<cfelse>
	<cfset Contract_ID = 0>
</cfif>

		<cfquery name="GetPerfReqsforTemplate" datasource="#application.datasource#">
			SELECT 	DISTINCT PPR.Requirement_Name,
							PPR.Program_Perf_Req_ID,
							PPR.PR_Operator_Category,
							PPR.PR_Operator_Priority,
							PPR.PR_Date_Range,
							PPM.Program_Perf_Req_Checked,
							PPR.Allow_Change_On_Revision,
							PPR.List_Features
			FROM 	Program_Perf_Mapping PPM
			INNER JOIN Program_Perf_Req PPR
			ON PPR.Program_Perf_Req_ID = PPM.Program_Perf_Req_ID
			WHERE 	PPM.Template_ID = '#FORM.ProgramType_ID#'
			AND PPR.List_Features = 0
		</cfquery>
		<cfquery name="PerformanceRequirementLabels" datasource="#application.datasource#">
			SELECT DISTINCT PPRL.Perf_Req_Label
			FROM 	Program_Perf_Mapping PPM
			INNER JOIN Program_Perf_Req PPR
			ON PPR.Program_Perf_Req_ID = PPM.Program_Perf_Req_ID
			INNER Join Program_Perf_Req_Labels PPRL
			ON PPRL.Program_Perf_Req_ID = PPM.Program_Perf_Req_ID
			AND PPRL.Perf_Req_Label_ID = PPM.Program_Perf_Req_Checked
			WHERE PPM.Template_ID = '#FORM.ProgramType_ID#'
			AND PPR.List_Features <>0
		</cfquery>
		<cfquery name="ThisProgramsRequirements" datasource="#application.datasource#">
			SELECT	Program_Perf_Req_ID,
					ISNULL(Operator_Category_ID, 0) AS Operator_Category_ID,
					ISNULL(Operator_Priority_ID, 0) AS Operator_Priority_ID,
					PR_Start_Date,
					PR_End_Date
			FROM	One_Program_Perf_Mapping
			WHERE	Contract_Main_ID = '#Contract_ID#'
			AND		Checked = 1
		</cfquery>
		<cfset useLakebaseForNotProgramsRequirements = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("one_program_perf_mapping")>
<cfif useLakebaseForNotProgramsRequirements>
	<cftry>
		<cfset NotProgramsRequirements = application.oLakebase.toQuery(
			application.oLakebase.selectRows("one_program_perf_mapping", {
				"contract_main_id" = "eq.#Contract_ID#",
				"checked" = "eq.0",
				"select" = "program_perf_req_id"
			}), "program_perf_req_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForNotProgramsRequirements = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForNotProgramsRequirements>
<cfquery name="NotProgramsRequirements" datasource="#application.datasource#">
			SELECT 	Program_Perf_Req_ID
			FROM 	One_Program_Perf_Mapping
			WHERE 	Contract_Main_ID = '#Contract_ID#'
			AND 	Checked = 0
		</cfquery>
</cfif>
		<cfif isDefined("FORM.CONTRACT_RENEWAL_PACKETS_ID") AND NOT ISREVISIONOFEXISTINGCONTRACT>
			<cfset AllRequirements = "">
			<cfset NotRequirements = "">
		<cfelse>
			<cfset AllRequirements = listqualify(valuelist(ThisProgramsRequirements.Program_Perf_Req_ID), chr(39))>
			<cfset NotRequirements = listqualify(valuelist(NotProgramsRequirements.Program_Perf_Req_ID), chr(39))>
		</cfif>

		<cfif GetPerfReqsforTemplate.Recordcount GT 0 OR PerformanceRequirementLabels.Recordcount GT 0>
		<!--- <cfif appsettings.get_Setting('GPO_One_Page_Program_Creation') NEQ 1 OR Discount_Identifier_Number NEQ "CPA"> ---> <!--- Hide it if it is CPA --->
		<!---TSF - Label 19919: Performance Requirements Enhancements--->
		<cfset qGetCategories	= CreateObject("component", "components.customer.operator.Category").getCategory() />
		<cfset qGetPrioritys 	= CreateObject("component", "components.customer.operator.Priority").getPriority() />

		<cfset variables.operatorCategoryLabel 	= labelComp.GetGeneralLabels('Operator Category').General_Labels_Label />
		<cfset variables.operatorPriorityLabel 	= labelComp.GetGeneralLabels('Operator Priority').General_Labels_Label />

		<cfif isDefined("FORM.CONTRACT_RENEWAL_PACKETS_ID") AND NOT ISREVISIONOFEXISTINGCONTRACT>
			<!--- Loop over any saved requirements and set the values if it's copied --->
			<cfoutput query="ThisProgramsRequirements">
				<cfset "form.PerfReq_Category_#Program_Perf_Req_ID#"	= 0 />
				<cfset "form.PerfReq_Priority_#Program_Perf_Req_ID#"	= 0 />
				<cfset "form.PerfReq_Start_Date_#Program_Perf_Req_ID#"	= "" />
				<cfset "form.PerfReq_End_Date_#Program_Perf_Req_ID#"	= "" />
			</cfoutput>
		<cfelse>
		<!--- Loop over any saved requirements and set the values if it's not copied --->
			<cfoutput query="ThisProgramsRequirements">
				<cfset "form.PerfReq_Category_#Program_Perf_Req_ID#"	= #Operator_Category_ID# />
				<cfset "form.PerfReq_Priority_#Program_Perf_Req_ID#"	= #Operator_Priority_ID# />
				<cfset "form.PerfReq_Start_Date_#Program_Perf_Req_ID#"	= #PR_Start_Date# />
				<cfset "form.PerfReq_End_Date_#Program_Perf_Req_ID#"	= #PR_Start_Date# />

			</cfoutput>
		</cfif>
		<tr>
			<TD ALIGN="right" VALIGN="top">
				<span id="error_PerfRequirement"></span>
				<B>Requirements:</B>
			</TD>
			<td>
				<table>
				<cfif PerformanceRequirementLabels.Recordcount>
				<cfoutput query="PerformanceRequirementLabels">
					<tr>
						<td>
						<a onclick="NewWindow('Performance_Requirements.cfm?Contract_Main_ID=#Contract_ID#&ProgramType_ID=#form.ProgramType_ID#&Perf_Req_Label=#PerformanceRequirementLabels.Perf_Req_Label#','Performance_Requirements','500','500','Yes', 'No');">
							#application.util.string.actionLinkFormat2('Select #Perf_Req_Label#')#
						</a>
							<span id="error_PerfRequirementCategory_#Perf_Req_Label#"></span>
							<cfset useLakebaseForselectedPR = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("one_program_perf_mapping")>
<cfif useLakebaseForselectedPR>
	<cftry>
		<cfset selectedPR = application.oLakebase.toQuery(
			application.oLakebase.selectRows("one_program_perf_mapping", {
				"contract_main_id" = "eq.#Contract_ID#",
				"program_perf_req_label" = "eq.#Perf_Req_Label#",
				"checked" = "eq.1",
				"select" = "program_perf_req_id"
			}), "program_perf_req_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForselectedPR = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForselectedPR>
<cfquery name="selectedPR" datasource="#application.datasource#">
								SELECT Program_Perf_Req_ID
								FROM One_Program_Perf_Mapping
								WHERE  Contract_Main_ID = #Contract_ID#
								AND Program_Perf_Req_Label = '#Perf_Req_Label#'
								AND checked = 1
							</cfquery>
</cfif>
							<input type="hidden" name="#Perf_Req_Label#" id="#Perf_Req_Label#" value="#valuelist(selectedPR.Program_Perf_Req_ID)#"/>
						</td>
					</tr>
				</cfoutput>
				</cfif>
				<cfoutput query="GetPerfReqsforTemplate">

					<cfparam name="form.PerfReq_Category_#Program_Perf_Req_ID#" 	default="0" />
					<cfparam name="form.PerfReq_Priority_#Program_Perf_Req_ID#" 	default="0" />
					<cfparam name="form.PerfReq_Start_Date_#Program_Perf_Req_ID#" 	default="" />
					<cfparam name="form.PerfReq_End_Date_#Program_Perf_Req_ID#" 	default="" />

				<cfset ReqDisabled = "" />
				<cfif (FORM.ISREVISIONOFEXISTINGCONTRACT EQ 1 AND GetPerfReqsforTemplate.Allow_Change_On_Revision eq 0) OR (appsettings.get_Setting('GPO_One_Page_Program_Creation') EQ 1 AND Discount_Identifier_Number EQ "CPA")>
					<cfset ReqDisabled = "disabled" />
				</cfif>
				<cfset rdoCheckedYes = "" />
				<cfset rdoCheckedNo = "" />
				<cfif listContains(AllRequirements, GetPerfReqsforTemplate.Program_Perf_Req_ID) or ((Contract_ID eq 0 or (isDefined("FORM.CONTRACT_RENEWAL_PACKETS_ID") AND NOT ISREVISIONOFEXISTINGCONTRACT)) and ((Program_Perf_Req_Checked eq 1) or (Program_Perf_Req_Checked eq 3)))>
					<cfset rdoCheckedYes = "checked"/>
				<cfelseif listContains(NotRequirements, GetPerfReqsforTemplate.Program_Perf_Req_ID) or ((Contract_ID eq 0 or (isDefined("FORM.CONTRACT_RENEWAL_PACKETS_ID") AND NOT ISREVISIONOFEXISTINGCONTRACT)) and  ((Program_Perf_Req_Checked eq 2) or (Program_Perf_Req_Checked eq 4)))>
					<cfset rdoCheckedNo = "checked"/>
				<cfelseif appsettings.get_Setting('GPO_One_Page_Program_Creation') EQ 1 AND Discount_Identifier_Number EQ "CPA">
					<cfset rdoCheckedNo = "checked"/>
				</cfif>
				<!-----------------------------------------------------------------------------
				Dev Notes: D19196
				The above condition would work for the New contract but when we are trying
				to revise a program and in the scenario when the template has been changed
				so that new Performance requirement has been added or the existing ones
				changed, then the below condition would pick up the default values from
				the Program Template.  If none has changed in the Performance requirement,
				then the code will pick up these values from the parent program version.
				-Anand Rao/03-Jun-09
				------------------------------------------------------------------------------>
				<cfif (rdoCheckedNo EQ "" AND rdoCheckedYes EQ "")>
					<cfif ((Program_Perf_Req_Checked EQ 1) OR (Program_Perf_Req_Checked EQ 3))>
						<cfset rdoCheckedYes = "checked" />
					<cfelseif  ((Program_Perf_Req_Checked EQ 2) OR (Program_Perf_Req_Checked EQ 4))>
						<cfset rdoCheckedNo = "checked" />
					</cfif>
				</cfif>
				<cfif Program_Perf_Req_Checked EQ 3>
					<cfset rdoCheckedYes = "checked" />
					<cfset rdoCheckedNo = "" />
				</cfif>
				<cfif Program_Perf_Req_Checked EQ 4>
					<cfset rdoCheckedYes = "" />
					<cfset rdoCheckedNo = "checked" />
				</cfif>
				<!--- if rdoCheckedYes is an empty string then we have to disable the other performance requirement controls--->
				<cfset variables.disableControls = 0 />
				<cfif not Len(trim(rdoCheckedYes))>
					<cfset variables.disableControls = 1 />
				</cfif>
				<tr>
				<td>
				<table border="0" cellspacing="0" cellpadding="2" align="left">
				<tr>
					<td nowrap="nowrap"><b>#Requirement_Name#:</b></td>
					<td nowrap>
					<cfif Program_Perf_Req_Checked EQ 4>
						<font color="##E6E6E6">yes</font>
					<cfelse>
						yes
					</cfif>
						<input type="radio" name="PerfReq_#Program_Perf_Req_ID#" value="1" id="PerfReq_#Program_Perf_Req_ID#" #rdoCheckedYes# onClick="javascript:notifyPerfReqControls(#Program_Perf_Req_ID#)"  <cfif Program_Perf_Req_Checked EQ 4>Disabled<cfelse>#ReqDisabled#</cfif> />
					<cfif Program_Perf_Req_Checked EQ 3>
						<font color="##E6E6E6">&nbsp;no</font>
					<cfelse>
						&nbsp;no
					</cfif>
						<input type="radio" name="PerfReq_#Program_Perf_Req_ID#" value="0" id="PerfReq_#Program_Perf_Req_ID#" #rdoCheckedNo# onClick="javascript:notifyPerfReqControls(#Program_Perf_Req_ID#)" <cfif Program_Perf_Req_Checked EQ 3>Disabled<cfelse>#ReqDisabled#</cfif> />
						<cfif (FORM.ISREVISIONOFEXISTINGCONTRACT EQ 1 AND GetPerfReqsforTemplate.Allow_Change_On_Revision eq 0) OR (appsettings.get_Setting('GPO_One_Page_Program_Creation') EQ 1 AND Discount_Identifier_Number EQ "CPA")>
							<input TYPE="hidden" name="PerfReq_#Program_Perf_Req_ID#" id="PerfReq_#Program_Perf_Req_ID#" value= <cfif len(rdoCheckedYes) GT 0>"1"<cfelse>"0"</cfif>>
						</cfif>
					</td>
				</tr>
				<tr>
					<!--- display if Category is on from setting --->
					<cfif PR_Operator_Category eq 1>
					<td>&nbsp;</td>
					<td>
						<SPAN Class="SP_PerfReq_#Program_Perf_Req_ID#">
							<span id="error_PerfRequirementCategory#Program_Perf_Req_ID#"></span>
						<select name="PerfReq_Category_#Program_Perf_Req_ID#" <cfif variables.disableControls>disabled</cfif>>
							<option value="0" <cfif len(ReqDisabled) GT 0 AND evaluate("form.PerfReq_Category_#GetPerfReqsforTemplate.Program_Perf_Req_ID#") GT 0> disabled </cfif>>Choose #variables.operatorCategoryLabel#</option>
							<cfloop query="qGetCategories">
								<option value="#Operator_Category_ID#" <cfif evaluate("form.PerfReq_Category_#GetPerfReqsforTemplate.Program_Perf_Req_ID#") eq Operator_Category_ID> selected <cfelse><cfif len(ReqDisabled) GT 0> disabled </cfif></cfif>>#trim(Category_Label)#</option>
							</cfloop>
						</select>
						</SPAN>
					</td>
					</cfif>
				</tr>
				<tr>
					<!--- display if Priority is on from setting--->
					<cfif PR_Operator_Priority eq 1>
					<td>&nbsp;</td>
					<td>
						<SPAN Class="SP_PerfReq_#Program_Perf_Req_ID#">
							<span id="error_PerfRequirementPriority#Program_Perf_Req_ID#"></span>
							<select name="PerfReq_Priority_#Program_Perf_Req_ID#" <cfif variables.disableControls>disabled</cfif>>
								<option value="0" <cfif len(ReqDisabled) GT 0 AND evaluate("form.PerfReq_Priority_#GetPerfReqsforTemplate.Program_Perf_Req_ID#") GT 0> disabled </cfif>>Choose #variables.operatorPriorityLabel#</option>
								<cfloop query="qGetPrioritys">
									<option value="#Operator_Priority_ID#" <cfif evaluate("form.PerfReq_Priority_#GetPerfReqsforTemplate.Program_Perf_Req_ID#") eq Operator_Priority_ID> selected <cfelse><cfif len(ReqDisabled) GT 0> disabled </cfif></cfif>>#trim(Priority_Label)#</option>
								</cfloop>
							</select>
						</SPAN>
					</td>
					</cfif>
				</tr>
				<tr>
					<!--- display if Date is on from setting--->
					<cfif PR_Date_Range eq 1>
					<td>&nbsp;</td>
					<td>
					<SPAN Class="SP_PerfReq_#Program_Perf_Req_ID#">
						<span id="error_PerfRequirementDate#Program_Perf_Req_ID#"></span>
						<table>
						<tr>
							<cfif len(ReqDisabled) GT 0>
								<td><CF_EASYDATE FORMNAME="MyForm" FIELDNAME="reqStart_Date" FORMAT="mm/dd/yyyy" DEFAULT="#evaluate("form.PerfReq_Start_Date_#Program_Perf_Req_ID#")#" DisableObject="1"></td>
								<td><CF_EASYDATE FORMNAME="MyForm" FIELDNAME="reqEnd_Date" FORMAT="mm/dd/yyyy" DEFAULT="#evaluate("form.PerfReq_End_Date_#Program_Perf_Req_ID#")#" DisableObject="1"></td>
									<input TYPE="hidden" name="PerfReq_Start_Date_#Program_Perf_Req_ID#"  value="#evaluate("form.PerfReq_Start_Date_#Program_Perf_Req_ID#")#" >
									<input TYPE="hidden" name="PerfReq_End_Date_#Program_Perf_Req_ID#"  value="#evaluate("form.PerfReq_Start_Date_#Program_Perf_Req_ID#")#" >
							<cfelse>
								<td>
									<CF_EASYDATE FORMNAME="MyForm" FIELDNAME="PerfReq_Start_Date_#Program_Perf_Req_ID#" FORMAT="mm/dd/yyyy" DEFAULT="#evaluate("form.PerfReq_Start_Date_#Program_Perf_Req_ID#")#" DisableObject="#variables.disableControls#">
								</td>
								<td>
									<CF_EASYDATE FORMNAME="MyForm" FIELDNAME="PerfReq_End_Date_#Program_Perf_Req_ID#" FORMAT="mm/dd/yyyy" DEFAULT="#evaluate("form.PerfReq_End_Date_#Program_Perf_Req_ID#")#" DisableObject="#variables.disableControls#">
								</td>
							</cfif>
						</tr>
						</table>
					</SPAN>
					</td>
					</cfif>
				</tr>
				</table>
				</td>
				</tr>
			</cfoutput>
			</table>
			</td>
		</tr>
		<!--- </cfif> ---> <!--- Hide if it is CPA --->
		</cfif>
		<input type="hidden" name="PerfRequirements" id="PerfRequirements" value="" />
		<input type="hidden" name="NoPerfRequirements" id="NoPerfRequirements" value="" />
<!--- START:: 116758: Performance Type for non-retail programs / Anand Rao / 25-Aug-2022 --->
		<cfquery name="qGetPlannerPerfTypes" datasource="#application.datasource#">
			SELECT  PPT.Planner_Perf_Types_ID ,
			        PPT.Description ,
			        PPT.Sort_Order ,
			        PPT.TPO_Name ,
			        PPT.Created_Date ,
			        PPT.Created_By
			FROM    dbo.Planner_Perf_Types PPT
			        INNER JOIN Template_Planner_Settings_Perf_Types TPSPT ON PPT.Planner_Perf_Types_ID = TPSPT.Planner_Perf_Types_ID
			WHERE   TPSPT.Deleted = 0
			        AND TPSPT.First_Parent_ID = ( SELECT    First_Parent_ID
			                                      FROM      Program_Control_Panel_Options
			                                      WHERE     ProgramControl_Panel_Options_ID = '#FORM.ProgramType_ID#'
			                                    )
			        AND PPT.Active = 1
			        AND PPT.Deleted = 0
			        AND TPSPT.Deleted = 0
			ORDER BY PPT.Description
			</cfquery> 	<!--- <cfdump var="#qGetPlannerPerfTypes#" /> <cfdump var="#FORM#" /><cfabort> --->	
			<cfset useLakebaseForqGetPrgPerfType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForqGetPrgPerfType>
	<cftry>
		<cfset qGetPrgPerfType = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#Contract_ID#",
				"select" = "planner_perf_type_id,contract_status_type_idx"
			}), "planner_perf_type_id,contract_status_type_idx"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetPrgPerfType = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetPrgPerfType>
<cfquery name="qGetPrgPerfType" datasource="#application.datasource#">
				SELECT Planner_Perf_Type_ID,Contract_Status_Type_IDX  FROM Contract_Main WHERE Contract_main_ID = #Contract_ID#
			</cfquery>
</cfif>
			<cfif (isDefined("qGetPrgPerfType")	AND (qGetPrgPerfType.Contract_Status_Type_IDX GTE 3) AND NOT IsRevision)>
				<cfset perfDisabled = "Disabled"/>
			<cfelse>
				<cfset perfDisabled = ""/>
			</cfif>
			<cfset FORM.Planner_Perf_Types_ID = qGetPrgPerfType.Planner_Perf_Type_ID />
 			<cfif (isDefined("qGetPlannerPerfTypes") AND qGetPlannerPerfTypes.RecordCount NEQ 0)>
				<TR>
				<TD align="right" nowrap><span id="err_Planner_Perf_Types_ID"></span><B>Performance Type:</B></TD>
				<TD>
				<cfoutput>
					<select name="Planner_Perf_Types_ID"  #perfDisabled# >
						<option value="0">Choose a Performance Type</option>
						<cfloop query="qGetPlannerPerfTypes">
							<option value="#qGetPlannerPerfTypes.Planner_Perf_Types_ID#" <cfif FORM.Planner_Perf_Types_ID EQ qGetPlannerPerfTypes.Planner_Perf_Types_ID> selected </cfif>>#trim(qGetPlannerPerfTypes.Description)#</option>
						</cfloop>
					</select>
				</cfoutput>			
				</TD>
				</TR>
			<cfelse>
				<input type="Hidden" name="Planner_Perf_Types_ID" value="0">
			</cfif>
 <!--- END:: 116758: Performance Type for non-retail programs / Anand Rao / 25-Aug-2022 --->		
		
		<!---Equipment Placement--->
		<cfif GetFieldSettings.Equipment_Placement IS 1>
			<cfif FORM.Equipment_Placement_Note EQ 'NULL'>
				<cfset FORM.Equipment_Placement_Note = "">
			</cfif>
		<tr>
			<TD ALIGN="right" VALIGN="top">
				<B>Equipment/Dispenser Placement:</B>
			</TD>
			<td>
				<input type="checkbox" name="Equipment_Placement"  value="1" onClick="Check_Equipment_Placement('Equipment_Placement_Note');" style="vertical-align:top;"<cfif FORM.Equipment_Placement IS 1> checked</cfif>><nobr />
				<textarea name="Equipment_Placement_Note" rows="3" cols="52" id="Equipment_Placement_Note"  <cfif FORM.Equipment_Placement_Note eq "">style="display:none;"<cfelse>style="display:'';"</cfif> onPaste="javaScript: return textareaChecklength('125', this);"  onkeyPress="javaScript: return textareaChecklength('125', this);"><cfoutput>#FORM.Equipment_Placement_Note#</cfoutput></textarea>
			</td>
		</tr>
		</cfif>

				<!---Equipment Placement--->
		<cfif appSettings.getPullbacksOn() EQ 1>
				<cfif GetFieldSettings.generic_type EQ "Distributor Trade/Shelter" and GetFieldSettings.pullbacks_on EQ 1 and GetFieldSettings.is_pullback_corporate_deal EQ 1>
						<cfif qryUsersSettings.Pullback_Modify_Corporate_Program_Rates EQ 1>
								<tr>
									<TD ALIGN="right" VALIGN="top">
										<B><cfoutput>#appSettings.getPullbackLabel()#</cfoutput> from this program:</B>
									</TD>
									<td>
										<input type="checkbox" name="Pullback_From_This_Program"  value="1" <cfif FORM.Pullback_From_This_Program IS 1> checked</cfif>>
									</td>
								</tr>
						<cfelse>
									<input type="hidden" name="Pullback_From_This_Program"  value="1" /><!---D35392 --->
						</cfif>
				</cfif>
		</cfif>


<input type="hidden" name="Dist_Brand_Eligibility" value="1">
<!---60410 :  Fiscal Year Selection and Auto Renew START--->
<cfif GetFieldSettings.Optional_Dates_Program>
	<cfquery name="OptinalDates" datasource="#application.datasource#">
		SELECT CONVERT(VARCHAR(24), Start_Date,101) AS OptionalStartDate, CONVERT(VARCHAR(24), End_Date,101) AS OptionalEndDate, Description
		FROM Template_Optional_dates
		WHERE first_parent_id = #GetFieldSettings.First_Parent_ID#
		AND Deleted = 0
	</cfquery>
	<TR>
		<TD align="right" nowrap VALIGN="top">&nbsp;<B>Optional Dates:</B></TD>
		<TD>
			<select name="Optional_dates" style="width:300px;" id="Optional_dates">
				<option value="">Start Date&nbsp;-&nbsp;End Date&nbsp;-&nbsp;Description</option>
				<cfoutput query="OptinalDates">
					<cfset optionalDatesValue = OptionalStartDate&'-'&OptionalEndDate&'-'&Description>
					<option value="#optionalDatesValue#">#optionalDatesValue#</option>
				</cfoutput>
			</select>
		</TD>
	</TR>
<script type="text/javascript">
    var Optionaldates = document.getElementById('Optional_dates');
    Optionaldates.onchange = function(){
    	var dates = this.value.split(/-/);
      document.MyForm.start_date.value = dates[0];
      document.MyForm.end_date.value = dates[1];
    }
</script>
</cfif>
<!---60410 :  Fiscal Year Selection and Auto Renew END--->
		<!--- DATE SPAN --->
		<TR>
			<TD align="right" nowrap VALIGN="top">
				<span id="error_ContractSpan"></span>
				<!--- Dev Note: Milan (20715) - "error_ContractStartDateChange" exists twice in the code. I am not sure whether to
				remove this one from here or not, and that is why I am using the condition (<cfif form.Program_Date_Type eq 2>). This way
				error_ContractStartDateChange" wont appear twice as the other one is appearing in the other condition
				(<cfif form.Program_Date_Type eq 1>)
				--->
				<cfif form.Program_Date_Type eq 2>
				<span id="error_ContractStartDateChange"></span>
				</cfif>
				<span id="error_ContractStartDaySpan"></span>
				<span id="error_ContractEndDaySpan"></span>
				<span id="error_ContractMinStartDate"></span>
				<span id="error_ContractMaxEndDate"></span>
				&nbsp;<B><cfoutput>#general_labels[ delivery_period ]#</cfoutput>:</B><br>   <!--- variables defined in general_labels.cfm --->
            </TD>

			<TD>
				<input type="hidden" name="Program_Date_Type" value="<cfoutput>#Program_Date_Type#</cfoutput>">
				<!---if the Program_Date_Type is fixed (2) then display fixed date drop down--->

				<cfif form.Program_Date_Type eq 2>
					<!---layout is just a namespace for the custom tag lib--->
					<layout:section name="views.programs.dateMethod" REVISIONSTATUS="#IsRevision#" REVISIONSETTINGS="#RevisionSettings.Date_Changes#">
				<cfelse>

					<!--- If the Program has formula periods (dates) set up,program dates are locked --->
					<cfquery NAME="checkFormulaPeriod" datasource="#application.datasource#">
						SELECT Program_Formula_Pricing_Period_Id FROM Program_Formula_Pricing_Periods
						WHERE Program_Id = #contract_Id# AND
						Deleted = 0
					</cfquery>
					<cfset title="Click here to get a calendar" />
					<cfif checkFormulaPeriod.recordCount GT 0>
						<cfset title="Contract dates are not editable when the program has formula period dates configured" />
					</cfif>
					<cfif (IsRevision EQ 1 AND RevisionSettings.Date_Changes eq 0) OR checkFormulaPeriod.recordCount GT 0 OR revisionOfProgramWithOtherRevisions EQ 1 OR ModifyDeletedPrograms>
						<cfset startDateDisabled = 1 />
					</cfif>
					<cfif (IsRevision EQ 1 AND RevisionSettings.Date_Changes_End eq 0) OR checkFormulaPeriod.recordCount GT 0 OR revisionOfProgramWithOtherRevisions EQ 1 OR ModifyDeletedPrograms>
						<cfset EndDateDisabled = 1 />
					</cfif>

					<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" width="400">
					<TR id="cellWithDateSpan" <cfif GETFIELDSETTINGS.Date_Exclusions_On EQ 1 AND len(trim(URL.CID)) GT 0><cfif  IsRevision EQ 1 AND RevisionSettings.Date_Changes eq 2>onclick="warnOfExclusionDelete();"</cfif></cfif>>

							<TD>
								From:<span id="error_ContractStartDateChange"></span>
										 <span id="error_ContractStartDateValidity"></span><br>
								<cfif form.IsExclusionRevision EQ 0>
									<CF_EASYDATE FORMNAME="MyForm" title="#title#" FIELDNAME="start_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.start_date#"  REVISIONSTATUS="#IsRevision#" REVISIONSETTINGS="#RevisionSettings.Date_Changes#" DisableObject="#startDateDisabled#" >
								<cfif  (IsRevision eq 1 AND RevisionSettings.Date_Changes eq 2) OR startDateDisabled eq 1>
									<INPUT NAME="start_date" TYPE="Hidden" VALUE="<CFOUTPUT>#FORM.start_date#</CFOUTPUT>" id="start_date">
								</cfif>
								<CFELSE>
									<INPUT NAME="start_date_display" TYPE="Text" SIZE="10" DISABLED <cfif startDateDisabled>STYLE="background-color: cccccc" </cfif>VALUE="<CFOUTPUT>#FORM.start_date#</CFOUTPUT>">
									<INPUT NAME="start_date" TYPE="Hidden" VALUE="<CFOUTPUT>#FORM.start_date#</CFOUTPUT>">
								</cfif>
							</TD>
							<TD></TD>
							<TD>
								To:<span id="error_ContractEndDateChange"></span>
									<span id="error_ContractEndDateValidity"></span><br>
								<cfif form.IsExclusionRevision EQ 0>
									<CF_EASYDATE FORMNAME="MyForm" title="#title#" FIELDNAME="end_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.end_date#"  REVISIONSTATUS="#IsRevision#" REVISIONSETTINGS="#RevisionSettings.Date_Changes_End#" DisableObject="#EndDateDisabled#" >
								<cfif  (IsRevision eq 1 AND RevisionSettings.Date_Changes_End eq 2) OR EndDateDisabled eq 1>
									<INPUT NAME="end_date" TYPE="Hidden" VALUE="<CFOUTPUT>#FORM.end_date#</CFOUTPUT>" id="end_date">
								</cfif>
								<cfelse>
										<INPUT NAME="end_date_display" TYPE="Text" SIZE="10" DISABLED <cfif EndDateDisabled>STYLE="background-color: cccccc" </cfif>VALUE="<CFOUTPUT>#FORM.end_date#</CFOUTPUT>">
										<INPUT NAME="end_date" TYPE="Hidden" VALUE="<CFOUTPUT>#FORM.end_date#</CFOUTPUT>">
								</cfif>
							</TD>
							<cfif appSettings.get_Setting('Date_Format_Notification') EQ "1">
								<TD>
									<strong><font color="blue">Date Format <br>MM/DD/YYYY</font></strong>
								</TD>
							</cfif>
						</TR>
					</TABLE>
				</cfif>
			</TD>
		</TR>
		<cfif GetSettings.show_Contract_Dates eq 1>
		<!--- CONTRACT PERIOD SPAN
		Dev Note:(64090)"contract_period_start_date" and "contract_period_end_date".
		NOTE:THIS IS NOT CONTRACT START AND END DATE (DELIVERY DATES).
		--->
		<TR>
			<TD align="right" nowrap VALIGN="top">
			<span id="error_ContractPeriodSpan"></span>
				&nbsp;<B>Contract Period:</B><br>
			</TD>
			<TD>
				<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" width="300">
				<TR>
						<TD>
							From:<br>
								<CF_EASYDATE FORMNAME="MyForm" FIELDNAME="contract_period_start_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.contract_period_start_date#">
						</TD>
						<TD></TD>
						<TD>
							To:<br>
								<CF_EASYDATE FORMNAME="MyForm" title="#title#" FIELDNAME="contract_period_end_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.contract_period_end_date#">
						</TD>
					</TR>
				</TABLE>
			</TD>
		</TR>
		</cfif>
	<!--- START: Dev Notes: Anand Rao/18-Nov-2011/D29125: Base Sales for a program--->
<cfif (appSettings.PRICE_LIST_BY_TEMPLATE EQ 1 AND getFieldSettings.Base_Sales_based_on_Prg_Start_Date EQ 1 AND getFieldSettings.Select_Effective_Date_for_Price EQ 1)>
		<tr>
			<TD ALIGN="right" VALIGN="top">
				<B>Effective Date for Price: <CF_SmallHelp
								width = "300"
								displayShifyX = "-200"
								displayShifyY = "-90"
								imgPath="/Images/i.gif"
								imgWidth="12"
								imgHeight="11"
								dropdownCheck="0"
								>
				This is an optional field.  If a date is typed in then on the margin page,
				the base sales value for the item will be based on the effective date entered.
				If a date is not typed into this field and it is left blank,
				then the base sales value will be based on the program's start date.
			</CF_SmallHelp></B>
			</TD>
			<td><span id="error_EffectiveDateforPrice"></span>
				 <cf_easydate FormName="MyForm"
				 			  FieldName="Effective_Date_for_Price"
				 			  Format="mm/dd/yyyy"
				 			  Default="#FORM.Effective_Date_for_Price#">
				</td>
		</tr>
<!--- D32776:Effective Price Date Changed on all Bid Programs START--->
	<tr>
		<TD ALIGN="right" VALIGN="top">
			<B>Price Protection Date: </B>
		</TD>
		<td style="width:95px;font-size:13px;border:none;"><cfoutput>#form.Price_Protection_Date#<input type="hidden" name="Price_Protection_Date" value="#form.Price_Protection_Date#" readonly ></cfoutput></td>
	</tr>
<!--- D32776:Effective Price Date Changed on all Bid Programs END --->
<cfelse>
<input type="hidden" value="" name="Effective_Date_for_Price" />
<input type="hidden" value="" name="Price_Protection_Date" />
</cfif>
	<!--- END: Dev Notes: Anand Rao/18-Nov-2011/D29125: Base Sales for a program--->
	  <cfif getFieldSettings.Retail_Performance_Dates EQ 1>
	  <cfset variables.PerformanceDatesLabel 	= labelComp.GetGeneralLabels('Performance Dates').General_Labels_Label />
	     	<tr>
			<td align="right" valign="top">
				<span id="error_PerformanceSpan"></span>
				<span id="error_PerformanceDateSpan"></span>
				&nbsp;<B><cfoutput>#variables.PerformanceDatesLabel#:</cfoutput></B></TD>
			<td>
		      <table border="0" cellpadding="0" cellspacing="0" width="300">
			   <tr id="cellWithDateSpan">
				 <td>From: <span id="error_PerformanceStartDateValidity"></span><br>
				 <cf_easydate FormName="MyForm"
				 			  FieldName="Performance_Start_Date"
				 			  Format="mm/dd/yyyy"
				 			  Default="#Form.Performance_Start_Date#">
				</td>
				<td></td>
				<td>To: <span id="error_PerformanceEndDateValidity"></span><br>
				<cf_easydate FormName="MyForm"
							 FieldName="Performance_End_Date"
							 format="mm/dd/yyyy"
							 default="#Form.Performance_End_Date#">
				</td>
			   </tr>
			  </table>
			</td>
		  </tr>
		</cfif>
<!---60308 :: Best Plans Enhancement START--->
<cfif GetSettings.allow_Best_Plan_Programs EQ 1>
	<TR>
		<TD align="right" nowrap VALIGN="top">&nbsp;<B>Best Plan Program:</B></TD>
		<TD><input type="checkbox" name="Best_Plan_Program" value="1" <cfif FORM.Best_Plan_Program EQ 1> checked </cfif>> Best Plan Program?</TD>
	</TR>
</cfif>
<!---60308 :: Best Plans Enhancement END--->

		<!--- Dev Note(79426) - For "blanket bid" feature --->
		<cfif GetSettings.Display_Blanket_Bid EQ 1>
			<TR>
				<TD align="right" nowrap VALIGN="top">&nbsp;<B>Is Blanket Bid:</B></TD>
				<TD><input type="checkbox" name="Is_Blanket_Bid" value="1" <cfif FORM.Is_Blanket_Bid EQ 1> checked </cfif>></TD>
			</TR>
		</cfif>
		<!---60410 :  Fiscal Year Selection and Auto Renew START--->
		<CFIF listlen(FORM.AUTO_RENEW_Setting) GTE 1>
		<tr>
			<TD ALIGN="right" VALIGN="top"><span id="error_AutoRenewal"></span><span id="error_Renewal_Lead_Time"></span><span id="error_AR_Renewal_Type"></span><span id="error_MultiYearContractSpan"></span>&nbsp;<B>Auto Renewal:</B><a href="##" border="0" onclick="window.open('autoRenewalHelp.cfm', 'AutoRenewal', 'height=260,width=500,location=0,toolbar=no,scrollbars=auto,resizable=yes,titlebar=no')"><img src="/images/help_small.gif" border="0" title="Click for Help"></a></TD>
			<td>

  				<input type="checkbox" name="Auto_Renew" value="1" <cfif FORM.Auto_Renew EQ 1> checked </cfif> <cfif appSettings.AutoRenewSpaninPW IS 0 OR Allow_AR_Modification IS 1> onclick="if(this.checked) {document.all.spAutoRenew.style.display='';document.all.AutoRenew.style.display='';document.all.AutoRenew2.style.display='';document.all.AutoRenew3.style.display='';document.all.AutoRenew4.style.display='';document.all.AutoRenew5.style.display='';document.all.AutoRenew6.style.display='';} else if(this.checked==false) {document.all.spAutoRenew.style.display='none';document.all.AutoRenew.style.display='none';document.all.AutoRenew2.style.display='none';document.all.AutoRenew3.style.display='none';document.all.AutoRenew4.style.display='none';document.all.AutoRenew5.style.display='none';}"<cfelse>onclick="if(this.checked) {document.all.spAutoRenew.style.display='';document.all.AutoRenew3.style.display='';document.all.AutoRenew4.style.display='';document.all.AutoRenew5.style.display='';document.all.AutoRenew6.style.display='';} else if(this.checked==false) {document.all.spAutoRenew.style.display='none';document.all.AutoRenew3.style.display='none';document.all.AutoRenew4.style.display='none';document.all.AutoRenew5.style.display='none';document.all.AutoRenew6.style.display='none';}"</cfif>> Automatically Renew?

				<span id="spAutoRenew" <cfif FORM.Auto_Renew NEQ 1>style="display:none;"</cfif>>
				<table border="0" cellpadding="2" cellspacing="0">
				<cfif appSettings.AutoRenewSpaninPW IS 0 OR Allow_AR_Modification IS 1>
					<!---Do you want to automatically renew?--->
					<!--- <tr>
						<td colspan="2"></td>
					</tr> --->
					<!---When do you want it entered as a work in progress?--->
					<!------ same condition to be used in javascript too ----->
					<tr>
						<td><span id="AutoRenew" <cfif FORM.Auto_Renew NEQ 1>style="display:none;"</cfif>>
						<input type="text" name="Renewal_Lead_Time" value="<cfoutput>#Form.Renewal_Lead_Time#</cfoutput>" size="2" onKeyUp="clenseText(this, '0123456789');" maxlength="2">
						</span>
					</td>
					<Td><span id="AutoRenew2" <cfif FORM.Auto_Renew NEQ 1>style="display:none;"</cfif>>&nbsp; Auto Renew lead time (days) before new start date </span></TD>
					</tr>
				<cfelse>
					<cfif Form.Renewal_Lead_Time EQ "">
						<cfset Form.Renewal_Lead_Time = 0 />
					</cfif>
					<input type="hidden" name="Renewal_Lead_Time" value="<cfoutput>#Form.Renewal_Lead_Time#</cfoutput>">
				</cfif>
			<!---What kind of auto renewal is it?--->

				<TR id="AutoRenew3" <cfif FORM.Auto_Renew NEQ 1>style="display:none;"</cfif>> <TD NOWRAP colspan="2">
				<cfif  listfind(FORM.AUTO_RENEW_Setting, 1 )>
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<input type="radio" name="AR_Renewal_Type" value="1" <cfif Form.AR_Renewal_Type IS 1 OR (listlen(FORM.AUTO_RENEW_Setting) EQ 1 AND listfind(FORM.AUTO_RENEW_Setting, 1 ))>checked</cfif>>Renew Annually
				<cfelse>
					<input type="radio" name="AR_Renewal_Type" value="1" style="display:none;">
				</cfif>
				</TD>
				</TR>
				<TR id="AutoRenew4" <cfif FORM.Auto_Renew NEQ 1>style="display:none;"</cfif>><TD NOWRAP colspan="2">
				<cfif listfind(FORM.AUTO_RENEW_Setting, 2 )>
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<input type="radio" name="AR_Renewal_Type" value="2" <cfif Form.AR_Renewal_Type IS 2 OR (listlen(FORM.AUTO_RENEW_Setting) EQ 1 AND listfind(FORM.AUTO_RENEW_Setting, 2 ))>checked</cfif>>Renew Concurrently (after this one has completed)
				<cfelse>
					<input type="radio" name="AR_Renewal_Type" value="2" style="display:none;">
				</cfif>
				</TD>
				</TR>
				<TR id="AutoRenew5" <cfif FORM.Auto_Renew NEQ 1>style="display:none;"</cfif>><TD NOWRAP colspan="2">
				<cfif listfind(FORM.AUTO_RENEW_Setting, 3 )>
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<input type="radio" name="AR_Renewal_Type" value="3" <cfif Form.AR_Renewal_Type IS 3 OR (listlen(FORM.AUTO_RENEW_Setting) EQ 1 AND listfind(FORM.AUTO_RENEW_Setting, 3 ))>checked</cfif>>Renew Monthly (calendar - after this one has completed)
				<cfelse>
					<input type="radio" name="AR_Renewal_Type" value="3" style="display:none;">
				</cfif>
				</TD>
				</TR>
				<TR id="AutoRenew6" <cfif FORM.Auto_Renew NEQ 1> style="display:none;"</cfif>><TD NOWRAP colspan="2">
				<cfif listfind(FORM.AUTO_RENEW_Setting, 4 )>
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<input type="radio" name="AR_Renewal_Type" value="4" <cfif Form.AR_Renewal_Type IS 4 OR (listlen(FORM.AUTO_RENEW_Setting) EQ 1 AND listfind(FORM.AUTO_RENEW_Setting, 4 ))>checked</cfif>>Renew Fiscal Year
				<cfelse>
					<input type="radio" name="AR_Renewal_Type" value="4" style="display:none;">
				</cfif>
				</TD>
				</TR>
				<!---60410 :  Fiscal Year Selection and Auto Renew END--->
			</table>
			</span>
			</td>
		</tr>
		</CFIF>
<!--- D38942 :: Program Blackout Period on Frontend START --->
<cfif getFieldSettings.Blackout_Periods EQ 2 AND (form.ISCOPYPROGRAM EQ 0)>
	<cfoutput>
		<tr>
			<TD ALIGN="right" VALIGN="top">
				<span id="error_WeeksAfter"></span>
				&nbsp;<B>Weeks after start date to ignore for volume automation:</B>
			</TD>
		<TD ALIGN="left" VALIGN="middle">
			<input name="Program_Start_Zero" id="WeeksAfter" type="text" value="#form.Program_Start_Zero#" onKeyUp="clenseText(this, '0123456789')" maxlength="3"  >
		</TD>
		</tr>
		<tr>
			<TD ALIGN="right" VALIGN="top">
				<span id="error_WeeksBefore"></span>
				&nbsp;<B>Weeks before end date to ignore for volume automation:</B>
			</TD>
		<TD ALIGN="left" VALIGN="middle">
			<input name="Program_Future_zero" id="WeeksBefore" type="text" value="#form.Program_Future_zero#" onKeyUp="clenseText(this, '0123456789')" maxlength="3"  >
		</TD>
		</tr>
	</cfoutput>
</cfif>
<!--- D38942 :: Program Blackout Period on Frontend END --->
		<!--- read setting into var is var prior value is zero --->
			<tr>
			<cfif getFieldSettings.Generic_Type IS NOT "Distributor Off-Invoice" AND NOT appSettings.getPaymentCycleAtDiscountType()>
				<TD ALIGN="right" VALIGN="top">
						<span id="error_PaymentCycle"></span>&nbsp;<B>Payment Cycle:</B>
				</TD>
				<TD VALIGN="top" nowrap="true">
					<!---
					D22774: LW CA - Currency incorrect on new programs/Anand Rao/18-Mar-10
					Set the currency to the Defualt and active one, only if we have only one active currency
					--->
					<cfset useLakebaseForqryCurrency = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("currency")>
<cfif useLakebaseForqryCurrency>
	<cftry>
		<cfset qryCurrency = application.oLakebase.toQuery(
			application.oLakebase.selectRows("currency", {
				"active" = "eq.1",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryCurrency = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryCurrency>
<cfquery name="qryCurrency" datasource="#application.datasource#">
						SELECT * FROM Currency WHERE Active = 1 and Deleted = 0
					</cfquery>
</cfif>
					<cfoutput>
						<cfif (qryCurrency.RecordCount EQ 1)>
							<input type="hidden" name="Currency" value="#qryCurrency.Currency_ID#">
						<cfelseif isDefined("FORM.ProgramType_ID")>
							<cfset useLakebaseForqryCurrencyTemplate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForqryCurrencyTemplate>
	<cftry>
		<cfset qryCurrencyTemplate = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#FORM.ProgramType_ID#",
				"select" = "currencydefaultoption,*"
			}), "currencydefaultoption,*"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryCurrencyTemplate = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryCurrencyTemplate>
<CFQUERY NAME="qryCurrencyTemplate" datasource="#application.datasource#">
								SELECT CurrencyDefaultOption,*
								FROM Program_Control_Panel_Options
								WHERE ProgramControl_Panel_Options_ID ='#FORM.ProgramType_ID#'
							</cfquery>
</cfif>
							<input type="hidden" name="Currency" value="#qryCurrencyTemplate.CurrencyDefaultOption#">
						<cfelse>
							<input type="hidden" name="Currency" value="0">
						</cfif>
					</cfoutput>
					<cfif FORM.PaymentCycle EQ 0>
						<cfset FORM.PaymentCycle = FORM.PaymentCycle_Setting>
					</cfif>
					<cf_payment_cycle_selection
						Template_ID = "#FORM.ProgramType_ID#"
						Program_ID = "0"
						Selected_Payment_Cycle_ID = "#FORM.PaymentCycle#"
						isRevision = "#ISREVISIONOFEXISTINGCONTRACT#"
					>
                </TD>
			<cfelse>
				<cfif RevisionSettings.Currency_Change EQ 2>
					<cfset currencyDisable = 1>
				<cfelse>
					<cfset currencyDisable = 0>
				</cfif>
				<TD ALIGN="right" VALIGN="top">
					<input type="hidden" name="PaymentCycle" value="0">
					<cfif FORM.Currency EQ 0 OR FORM.Currency EQ "">
						<cfset FORM.Currency = FORM.Currency_Default_Setting>
					</cfif>
					&nbsp; <span id="error_Currency"></span><B> Currency:</B>
				</TD>
				<TD VALIGN="top" nowrap="true">
					<cf_currency_selection
					Default_Currency_Selection = "#FORM.Currency_Default_Setting#"
					Template_ID = "#FORM.ProgramType_ID#"
					Edit_Selection = "#FORM.Currency#"
					isRevision = "#ISREVISIONOFEXISTINGCONTRACT#"
					disabled = "#currencyDisable#"
					>
				</TD>
			</cfif>
			</tr>

			<!--- 34302 --->
			<cfoutput>
			<cfif getFieldSettings.currency_conversion_factor neq "1">
				<input name="currency_conversion_factor" type="hidden" value="">
			<cfelse>
				<tr>
					<td align="right" valign="top">&nbsp; <span id="error_currency_conversion_factor"></span><B> Currency Conversion Factor:</B></td>
					<td valign="top"><input name="currency_conversion_factor" id="currency_conversion_factor" class="numeric102" type="text" value="#form.currency_conversion_factor#"></td>
				</tr>
			</cfif>
			</cfoutput>

		<cfif Len(URL.CID) gt 0>
			<cfset SelectedQuantityID = FORM.Contract_Quantity_UOM_IDX>
		<cfelse>
			<CFIF isdefined("FORM.CONTRACT_RENEWAL_PACKETS_ID")>
				<cfset SelectedQuantityID = FORM.Contract_Quantity_UOM_IDX>
			<CFELSEIF FORM.Contract_Quantity_UOM_IDX NEQ "" AND FORM.Contract_Quantity_UOM_IDX NEQ FORM.ViewProgramVolumeUOM>
				<CFSET SelectedQuantityID = FORM.Contract_Quantity_UOM_IDX>
			<CFELSE>
				<cfset SelectedQuantityID = FORM.ViewProgramVolumeUOM>
			</CFIF>
		</cfif>

		<!--- 	ooooooooooooooooooooooooooooooooooooooooooo
				Flag that says this is a LSAutoPay template
				Set in Common_Queries.cfm 	bHideFromLSAutoPay
				ooooooooooooooooooooooooooooooooooooooooooo	--->
		<!--- 	D19668: Volume Applicator Upgrade - misc changes
				1. Hide the volume from basic info page, by default save UOM as case/pound
		 --->
		<!---
		<cfif NOT bHideFromLSAutoPay>
		<TR>
			<TD align="right" nowrap><span id="error_ContractQuantity"></span>&nbsp;<B>Program Quantity:</B></TD>
			<TD  id="rowWithVolumeField" nowrap>
				<INPUT type="text" name="Quantity" size="15" maxlength="12" VALUE="<cfif len(Form.Quantity) NEQ 0><cfoutput>#trim(val(Form.Quantity))#</cfoutput></cfif>" onKeyUp="clenseText(this, '0123456789');">
				<cf_uom_dropdown
					company_main_id			=	""
					default_option_on		=	"1"
					default_option_text		=	"Choose"
					default_option_value	=	"0"
					dropdown_name			=	"Contract_Quantity_UOM_IDX"
					option_text_abbreviated	=	""
					product_type_id			=	""
					program_template_id		=	"#FORM.ProgramType_ID#"
					selected_uom_id			=	"#SelectedQuantityID#"
					text_before_tag_close	=	"STYLE=""width: 195px;"""
					uom_id_exclusion_list	=	"3"
					<!---uom_id_inclusion_list	=	""--->>

			</TD>
		</TR>
		<cfelse>
			<input type="hidden" name="Quantity" value="0">
			<input type="hidden" name="Contract_Quantity_UOM_IDX" value="2">
		</cfif>
		--->
		<input type="hidden" name="Quantity" value="<cfif len(Form.Quantity) NEQ 0><cfoutput>#trim(val(Form.Quantity))#</cfoutput><cfelse>0</cfif>">
		<input type="hidden" name="Contract_Quantity_UOM_IDX" value="<cfoutput><cfif SelectedQuantityID EQ "2">2<cfelse>1</cfif></cfoutput>">

		<!--- CONTROLLABLE FLAG --->
		<CFIF FORM.Controllable_Volume_Setting EQ 1>
			<TR>
				<TD align="right" nowrap><span id="error_Controllable"></span>&nbsp;<B>Controllable:</B></TD>
				<TD><input type="radio" name="controllable_flag" value="1" <cfif FORM.Controllable_Volume EQ 1>checked</cfif>>Yes<input type="radio" name="controllable_flag" value="0"<cfif FORM.Controllable_Volume EQ 0>checked</cfif>>No</TD>
			</TR>
		</CFIF>
		<!--- GROWTH INCLUSION --->
		<CFIF FORM.Growth_Inclusion_Setting EQ 1>
			<TR>
				<TD align="right" nowrap><span id="error_GrowthInclusion"></span>&nbsp;<B>Growth Inclusion:</B></TD>
				<TD valign="middle"><input type="radio" name="Growth_Inclusion_Flag" value="1" <cfif FORM.Growth_Inclusion EQ 1>checked</cfif>>Yes<input type="radio" name="Growth_Inclusion_Flag" value="0" <cfif FORM.Growth_Inclusion EQ 0>checked</cfif>>No</TD>
			</TR>
		</CFIF>
		<cfsilent>
		<!---
		<!---Dev Note: CPM Budgets --->

			<!---
				budgets on (0-off, 1-on),
				budget select on (1-programs, 2-billbacks),
				and budget relationships to program (1-programs, 2-discount types)
			--->
			<cfif appSettings.getBudgetsOn()
				  AND appSettings.getSelectBudgetsOn() EQ 1
				  AND appSettings.getBudgetRelationshipToPrograms() EQ 1>
				<tr>
				<td align="right" nowrap><span id="error_ProgramBudget"></span>&nbsp;<B>Program Budget:</B></td>
					<td>
						<!--- If there is one budget associated to template, don't force user to select --->
						<cfif budgetsFromTemplate.recordCount EQ 1>
							<input type="hidden" value="#budgetsFromTemplate.budget_reference_id#" name="selectedBudget"> #budgetsFromTemplate.budget_name#
						<!--- Have user select the budget --->
						<cfelseif budgetsFromTemplate.recordCount GT 1>
						<select name="selectedBudget">
								<option value="0">Select Budget</option>
							<cfoutput query="budgetsFromTemplate">
								<option value="#budgetsFromTemplate.budget_reference_id#" <cfif form.budget_reference_id EQ budgetsFromTemplate.budget_reference_id>SELECTED</cfif> >#budgetsFromTemplate.budget_name#</option>
							</cfoutput>
						</select>
						<!--- No Budgets Associated with Template --->
						<cfelse>
							<i>No Budgets Are Associated with this Template</i>
						</cfif>
					</td>
				</tr>
			</cfif>
			--->
		<!---GetPaymenttypesforTemplate in Discount_Queries.cfm--->
		</cfsilent>
		<cfif 	GetPaymentTypesforTemplate.Recordcount GT 0>
		<cfsilent>
		<!--- Remove payment type from basic information label 13399 --->
		<!--- <tr>
			<td align="right" valign="top"><span id="error_ClaimMechanics"></span>&nbsp;<b>Claim Mechanism:</b></td>
			<TD>


			<cfoutput> --->

			<cfif IsDefined("FORM.ClaimMechOption") AND FORM.ClaimMechOption IS NOT 0>
				<cfset PaymentOptionSelected = FORM.ClaimMechOption>
			<CFELSEIF FORM.ClaimMechanicOption IS NOT 0>
				<CFSET PaymentOptionSelected = FORM.ClaimMechanicOption>
			<cfelse>
				<cfset PaymentOptionSelected = form.ClaimMechDefaultOption_Setting>
			</cfif>

			<!--- <table border="0" cellspacing="0" cellpadding="0" align="left">
				<select name="ClaimMechOption">
				<cfloop query="GetPaymentTypesforTemplate">
					<option value="#Payment_Type_ID#" <cfif PaymentOptionSelected IS Payment_Type_ID>selected</cfif>>#Payment_Type_Name#</option>
				</cfloop>
				</select>
			</table>
			</cfoutput>
			</TD>
		</tr> --->
		</cfsilent>
		<input type="hidden" name="ClaimMechOption" value="<cfoutput>#PaymentOptionSelected#</cfoutput>">
		<cfelse>
			<input type="hidden" name="ClaimMechOption" value="0">
		</cfif>

		<!--- BJF Remove rebate recipient/payee with 14531 --->

		<!--- ADVANCED SPENDING --->
		<CFIF FORM.Adv_Spend_Setting EQ 1>
			<cfif NOT IsNumeric(FORM.Adv_Spending_Amount)><cfset FORM.Adv_Spending_Amount = 0 /></cfif>
			<TR>
				<TD align="right" nowrap><span id="error_AdvancedSpending"></span>&nbsp;<B>Advanced Spending Amount:</B></TD>
				<CFOUTPUT>
					<cfset tmpAdvSpndAmt = '' >
					<cfif FORM.Adv_Spending_Amount NEQ "EMPTY" AND len(trim(FORM.Adv_Spending_Amount)) NEQ 0>
						<cfset tmpAdvSpndAmt = trim(numberformat(FORM.Adv_Spending_Amount, '___,___,___,___.__')) >
					</cfif>
					<TD>
						<input type="text" size="15" name="Adv_Spend_Amount" value="#tmpAdvSpndAmt#" onKeyUp="clenseText(this, '.0123456789'); allowonlytwodecimalplaces(this);">
					</TD>
				</CFOUTPUT>
			</TR>
		</CFIF>

		<!--- D8409: Broker and Trade Question --->
		<cfif appSettings.getBrokerTradeQuestOn() EQ 1 AND GetSettings.Broker_Trade_Question EQ 1>
		<CFOUTPUT>
		<script language="JavaScript">

		function BrokerQuestionRadioChange(chObjs, trObj)
		{

			if(chObjs[0].checked)
			{
				trObj.style.visibility = "visible";
			}
			else
			{
				trObj.style.visibility = "hidden";
			}

		}

		</script>

		<CFSET AffectBrokerCommissionList = "1,2,3" />
		<TR>
			<TD align="right" nowrap><span id="error_AffectBrokerCommission"></span>&nbsp;<B>Is #LCase(application.returned_customer_setting.broker_label_singular)#'s commission affected <br>by this #LCase(Application.RebateLabel)#/billback?:</B></TD>
			<TD valign="bottom">
			<table border="0" width="100%" cellpadding="0" cellspacing="0">
			<cfloop list="#AffectBrokerCommissionList#" index="currentValue">
			<td width="33%"><input type="Radio" name="Affect_Broker_Commission" value="#currentValue#" <cfif Form.Affect_Broker_Commission EQ currentValue>checked</cfif> onChange="javaScript: BrokerQuestionRadioChange(document.all.Affect_Broker_Commission, document.all.tr_AffectBrokerCommissionType)"> #programManager.getAffectBrokerCommission(currentValue)#</td>
			</cfloop>
			</table>
			</TD>
		</TR>

		<CFSET AffectBrokerCommissionTypeList = "1,2,3" />
		<TR id="tr_AffectBrokerCommissionType" <cfif Form.Affect_Broker_Commission NEQ 1>style="visibility: hidden;"</cfif>>
			<TD align="right" nowrap><span id="error_AffectBrokerCommissionType"></span>&nbsp;<B>The commission should be:</B></TD>
			<TD valign="bottom">
			<table border="0" width="100%" cellpadding="0" cellspacing="0">
			<cfloop list="#AffectBrokerCommissionTypeList#" index="currentValue">
			<td width="33%"><input type="Radio" name="Affect_Broker_Commission_Type" value="#currentValue#" <cfif Form.Affect_Broker_Commission_Type EQ currentValue>checked</cfif>> #programManager.getAffectBrokerCommissionType(currentValue)#</td>
			</cfloop>
			</table>
			</TD>
		</TR>

		<CFSET AffectShelterList = "1,2,3" />
		<TR>
			<TD align="right" nowrap><span id="error_AffectShelter"></span>&nbsp;<B>Is Shelter affected?:</B></TD>
			<TD valign="bottom">
			<table border="0" width="100%" cellpadding="0" cellspacing="0">
			<cfloop list="#AffectShelterList#" index="currentValue">
			<td width="33%"><input type="Radio" name="Affect_Shelter" value="#currentValue#" <cfif Form.Affect_Shelter EQ currentValue>checked</cfif> onChange="javaScript: BrokerQuestionRadioChange(document.all.Affect_Shelter, document.all.tr_AffectShelterType)"> #programManager.getAffectShelter(currentValue)#</td>
			</cfloop>
			</table>
			</TD>
		</TR>

		<CFSET AffectShelterTypeList = "1,2" />
		<TR id="tr_AffectShelterType" <cfif Form.Affect_Shelter NEQ 1>style="visibility: hidden;"</cfif>>
			<TD align="right" nowrap><span id="error_AffectShelterType"></span>&nbsp;<B>Shelter affects:</B></TD>
			<TD valign="bottom">
			<table border="0" width="100%" cellpadding="0" cellspacing="0">
			<cfloop list="#AffectShelterTypeList#" index="currentValue">
			<td width="33%"><input type="Checkbox" name="Affect_Shelter_Type" value="#currentValue#" <cfif ListFindNoCase(Form.Affect_Shelter_Type, currentValue) NEQ 0>checked</cfif>> #programManager.getAffectShelterType(currentValue)#</td>
			</cfloop>
			</table>
			</TD>
		</TR>

		</CFOUTPUT>
		</cfif>

		<cfif Form.Payable_To IS 1>
		<!----Payable To--->

		<TR>
			<TD ALIGN="right" VALIGN="top"><span id="error_Payable_To"></span>&nbsp;<B>Payable To:</B></TD>
			<td>
				<cfoutput>
				<table border="0" cellpadding="0" cellspacing="0">
					<!--- Dev Note: Drachala; D27241: Remove Pay To Distributor Check Box on Basic Info Page START--->
				<cfif GetSettings.Pay_To_Distributor EQ 1>
				<TR>
					<TD>Pay to #application.returned_customer_setting.distributor_label_singular#:</TD>
					<TD>
						<CFIF FORM.Pay_To_Distributor EQ 1>
							<CFSET PayChecked = 1>
						<CFELSE>
							<CFSET PayChecked = 0>
						</CFIF>
						<INPUT TYPE="CheckBox" NAME="Pay_To_Distributor" VALUE="1" <CFIF PayChecked EQ 1>CHECKED</CFIF> ONCLICK="Javascript: payDistributor()">
					</TD>
				</TR>
				<cfelse>
				<INPUT TYPE="CheckBox" NAME="Pay_To_Distributor" VALUE="1" style="display:none;">
				<CFSET PayChecked = 0>
				</cfif>
				<!--- Dev Note: Drachala; D27241: Remove Pay To Distributor Check Box on Basic Info Page END--->
				<tr>
					<td  width="120">Company Name:<span id="error_Payable_Company"></span></td><td><input type="text" size="30" maxlength="50" name="Payable_Company" value="#replacenocase(Form.Payable_Company, "NULL", "")#" <CFIF PayChecked EQ 1>DISABLED STYLE="background-color: cccccc"</CFIF>></td>
				</tr>
				<tr>
					<td>Attention:</td><td><input type="text" size="30" maxlength="50" name="Payable_Attention" value="#replacenocase(Form.Payable_Attention, "NULL", "")#" <CFIF PayChecked EQ 1>DISABLED STYLE="background-color: cccccc"</CFIF>></td>
				</tr>
				<tr>
					<td>Address 1:<span id="error_Payable_Address_1"></span></td><td><input type="text" size="30" maxlength="50" name="Payable_Address_1" value="#replacenocase(Form.Payable_Address_1, "NULL", "")#" <CFIF PayChecked EQ 1>DISABLED STYLE="background-color: cccccc"</CFIF>></td>
				</tr>
				<tr>
					<td>Address 2:</td><td><input type="text" size="30" maxlength="50" name="Payable_Address_2" value="#replacenocase(Form.Payable_Address_2, "NULL", "")#" <CFIF PayChecked EQ 1>DISABLED STYLE="background-color: cccccc"</CFIF>></td>
				</tr>
				<cfset useLakebaseForGetStates = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_states")>
<cfif useLakebaseForGetStates>
	<cftry>
		<cfset GetStates = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_states", {
				"order" = "state_code.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetStates = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetStates>
<cfquery name="GetStates" datasource="#application.datasource#">
				SELECT * FROM _states
				ORDER BY State_Code
				</cfquery>
</cfif>
				<tr>
					<td>City, State and Postal:<span id="error_Payable_City"></span><span id="error_Payable_Zip"></span></td><td><input type="text" size="30" maxlength="50" name="Payable_City" value="#replacenocase(Form.Payable_City, "NULL", "")#" <CFIF PayChecked EQ 1>DISABLED STYLE="background-color: cccccc"</CFIF>><select name="Payable_State" <CFIF PayChecked EQ 1>DISABLED STYLE="background-color: cccccc"</CFIF>><cfloop query="GetStates"><option value="#State_Code#" <cfif Form.Payable_State IS State_Code>selected</cfif>>#State_Code#</option></cfloop></select> <input type="text" size="5" maxlength="10" name="Payable_Zip" value="#replacenocase(Form.Payable_Zip, "NULL", "")#" <CFIF PayChecked EQ 1>DISABLED STYLE="background-color: cccccc"</CFIF>></td> <!--- onKeyUp="clenseText(this, '0123456789');" --->
				</tr>
				<tr>
					<td valign="top" >Payable-To Comments:</td><td><textarea name="Payable_Comments" cols="55" rows="3" <CFIF PayChecked EQ 1>DISABLED STYLE="background-color: cccccc"</CFIF>>#trim(replacenocase(Form.Payable_Comments, "NULL", ""))#</textarea></td>
				</tr>
				<tr><td colspan="2">&nbsp; </td></tr>
				</table>
				</cfoutput>

		</cfif>

		<cfif Form.Send_Payment_To IS 1>
		<!----Payable To--->
		<TR>
			<TD ALIGN="right" VALIGN="top"><span id="error_Payable_To"></span>&nbsp;<B>Send Payment To:</B></TD>
			<td>
				<cfoutput><table border="0" cellpadding="0" cellspacing="0">
				<TR>
					<TD>Send to Broker:</TD>
					<TD>
						<CFIF FORM.Send_To_Broker EQ 1>
							<CFSET SendChecked = 1>
						<CFELSE>
							<CFSET SendChecked = 0>
						</CFIF>
						<INPUT TYPE="CheckBox" NAME="Send_To_Broker" VALUE="1" <CFIF SendChecked EQ 1>CHECKED</CFIF> ONCLICK="Javascript: SendToBroker();">
					</TD>
				</TR>
				<cfif Form.Send_Payment_To IS 1 AND Form.Payable_To IS 1>
				<tr><td width="120">Same as Payable To:</td><td><input type="checkbox" name="SameAsPayable" value="0" OnClick="javascript:PayabletoSameAsSendPaymentTo(this.form);" <CFIF SendChecked EQ 1>DISABLED STYLE="background-color: cccccc"</CFIF>></td></tr>
				</cfif>
				<tr>
					<td  width="120">Company Name:<span id="error_Send_Company"></span></td><td><input type="text" size="30" maxlength="50" name="Send_Company" value="#replacenocase(Form.Send_Company, "NULL", "")#" <CFIF SendChecked EQ 1>DISABLED STYLE="background-color: cccccc"</CFIF>></td>
				</tr>
				<tr>
					<td>Attention:</td><td><input type="text" size="30" maxlength="50" name="Send_Attention" value="#replacenocase(Form.Send_Attention, "NULL", "")#" <CFIF SendChecked EQ 1>DISABLED STYLE="background-color: cccccc"</CFIF>></td>
				</tr>
				<tr>
					<td>Address 1:<span id="error_Send_Address_1"></span></td><td><input type="text" size="30" maxlength="50" name="Send_Address_1" value="#replacenocase(Form.Send_Address_1, "NULL", "")#" <CFIF SendChecked EQ 1>DISABLED STYLE="background-color: cccccc"</CFIF>></td>
				</tr>
				<tr>
					<td>Address 2:</td><td><input type="text" size="30" maxlength="50" name="Send_Address_2" value="#replacenocase(Form.Send_Address_2, "NULL", "")#" <CFIF SendChecked EQ 1>DISABLED STYLE="background-color: cccccc"</CFIF>></td>
				</tr>
				<cfquery name="GetStates" datasource="#application.datasource#">
					Select s.*, c.Country_Sort_Order
					from _states s
					join _country c on s.Country_ID = c.Country_ID
					ORDER BY  isnull(c.Country_Sort_Order, c.country_id) ASC
				</cfquery>
				<tr>
					<td>City, State and Postal:<span id="error_Send_City"></span><span id="error_Send_Zip"></span></td><td><input type="text" size="30" maxlength="50" name="Send_City" value="#replacenocase(Form.Send_City, "NULL", "")#" <CFIF SendChecked EQ 1>DISABLED STYLE="background-color: cccccc"</CFIF>><select name="Send_State" <CFIF SendChecked EQ 1>DISABLED STYLE="background-color: cccccc"</CFIF>><cfloop query="GetStates"><option value="#State_Code#" <cfif Form.Send_State IS State_Code>selected</cfif>>#State_Code#</option></cfloop></select> <input type="text" size="5" maxlength="10" name="Send_Zip" value="#replacenocase(Form.Send_Zip, "NULL", "")#" <CFIF SendChecked EQ 1>DISABLED STYLE="background-color: cccccc"</CFIF>></td>   <!--- onKeyUp="clenseText(this, '0123456789');" --->
				</tr>
				<tr><td colspan="2">&nbsp; </td></tr>
				</table>
				</cfoutput>

		</cfif>
		<cfoutput>
		<!---TSF: MODIFICATION--->
		<!---FILTER: if the template/program type is Bid Request, then get,set and display for Bid Request--->
		<!---************************************ BID REQUEST ************************************************--->

			<!---get bid request--->
			<cfset bidReqObj = CreateObject("component", "components.programs.bid_request.BidRequestManager").getBidRequest(Contract_ID) />
<cfif GetFieldSettings.Include_Open_Date IS 1>
			<TR>
				<TD align="right" nowrap><B><span id="error_OpenDate"></span>Open Date:</B></TD>
				<TD>
					<cfparam name="form.Open_Date" default="" />
					<cfset form.Open_Date = bidReqObj.getOpenDate() />
					<!--- Tim Ford - WR 51030 - BID template dates missing: form.isRevisionOfExistingContract if statement causing saved dates to not display
					<cfif form.isRevisionOfExistingContract eq 1>
						<cfset form.Open_Date = bidReqObj.getOpenDate() />
					</cfif>
					--->
					<CF_EASYDATE FORMNAME="MyForm" FIELDNAME="Open_Date" FORMAT="mm/dd/yyyy" DEFAULT="#form.Open_Date#">
				</TD>
			</TR>
</cfif>
<cfif GetFieldSettings.Include_Time_Of_Open_Date IS 1>
			<TR>
				<TD align="right" nowrap><B><span id="error_OpenTime"></span>Time Of Open Date:</B></TD>
				<TD>
					<input name="Open_Time" type="text" value="#bidReqObj.getOpenTime()#" />
				</TD>
			</TR>
</cfif>
<cfif GetFieldSettings.Include_Date_Needed_by IS 1>
			<TR>
				<TD align="right" nowrap><B><span id="error_DateNeeded"></span>Date Needed:</B></TD>
				<TD>
					<cfparam name="form.Date_Needed" default="" />
					<cfset form.Date_Needed = bidReqObj.getDateNeeded() />
					<!--- Tim Ford - WR 51030 - BID template dates missing: form.isRevisionOfExistingContract if statement causing saved dates to not display
					<cfif form.isRevisionOfExistingContract eq 1>
						<cfset form.Date_Needed = bidReqObj.getDateNeeded() />
					</cfif>
					--->
					<CF_EASYDATE FORMNAME="MyForm" FIELDNAME="Date_Needed" FORMAT="mm/dd/yyyy" DEFAULT="#form.Date_Needed#">
				</TD>
			</TR>
</cfif>
<cfif GetFieldSettings.Include_Reply_Date IS 1>
			<tr>
				<TD align="right" nowrap><B><span id="error_ExpectedReplyDate"></span>Program Award Date:</B></TD>
				<TD>
					<cfparam name="form.Expected_Reply_Date" default="" />
					<cfset form.Expected_Reply_Date = bidReqObj.getExpectedReplyDate() />
					<!--- Tim Ford - WR 51030 - BID template dates missing: form.isRevisionOfExistingContract if statement causing saved dates to not display
					<cfif form.isRevisionOfExistingContract eq 1>
						<cfset form.Expected_Reply_Date = bidReqObj.getExpectedReplyDate() />
					</cfif>
					--->
					<CF_EASYDATE FORMNAME="MyForm" FIELDNAME="Expected_Reply_Date" FORMAT="mm/dd/yyyy" DEFAULT="#form.Expected_Reply_Date#">
				</TD>
			</TR>
</cfif>
	<cfif getFieldSettings.BidRequestStatusOn eq 1>
			<tr>
				<TD align="right" nowrap><B>Line Item:</B></TD>
				<TD valign="top">
					<cfif getFieldSettings.Bid_Line_Item_Option IS NOT 2>
					<b>On:</b><input name="Line_Item" type="radio" value="1" <cfif bidReqObj.getLineItem() IS 1 OR getFieldSettings.Bid_Line_Item_Option_Default IS 1>checked</cfif> />
					</cfif>
					<cfif getFieldSettings.Bid_Line_Item_Option IS NOT 1>
					<b>Off:</b><input name="Line_Item" type="radio" value="0" <cfif  (bidReqObj.getLineItem() IS 0 AND len(trim(URL.CID)) GT 0) OR (getFieldSettings.Bid_Line_Item_Option_Default IS 2  AND bidReqObj.getLineItem() NEQ  1)>checked</cfif> />
					</cfif>
				</TD>
			</TR>
		</cfif>
		<input name="Program_Bid_Request_ID" type="hidden" value="#trim(bidReqObj.getId())#" />
		</cfoutput>

		<cfset vars.source 						= 0 />
		<cfset vars.sourceRequired 				= 0 />
		<cfset vars.sourceType					= 0 />
		<cfset vars.sourceTypeRequired 			= 0 />
		<cfset vars.dateSourceReceivedRequired 	= 0 />

		<!--- Dev Note: Milan (28153) --->
		<!--- display Competitor Source and Type if "Use Fixed Price Type" app setting is ON --->
		<cfif appsettings.getUseFixedPriceType()>
			<!--- Check whether the template contains fixed price components which have "fixed price type" turned ON for Competitive date. These types for Deviated price (meets competition) and combination (blended) --->
			<cfset qCompetitiveInfoFixedPriceTypeComponentList = templateManager.getAllTemplateDiscountComponents(templateId=FORM.ProgramType_ID, discountTypeList=1, returnSelected=1, fixedPriceType=1)>
			<cfif qCompetitiveInfoFixedPriceTypeComponentList.recordcount>
				<!--- Get all active source --->
				<cfset useLakebaseForqgetTopOneCompRow = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qcompetitiveinfofixedpricetypecomponentlist")>
<cfif useLakebaseForqgetTopOneCompRow>
	<cftry>
		<cfset qgetTopOneCompRow = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qcompetitiveinfofixedpricetypecomponentlist", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetTopOneCompRow = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetTopOneCompRow>
<cfquery name="qgetTopOneCompRow" dbType="query" maxrows="1">
					SELECT * FROM	qCompetitiveInfoFixedPriceTypeComponentList
				</cfquery>
</cfif>
				<cfset vars.source 						= qgetTopOneCompRow.Source />
				<cfset vars.sourceRequired 				= qgetTopOneCompRow.Source_Required />
				<cfset vars.sourceType					= qgetTopOneCompRow.Source_Type />
				<cfset vars.sourceTypeRequired 			= qgetTopOneCompRow.Source_Type_Required />
				<cfset vars.dateSourceReceivedRequired 	= qgetTopOneCompRow.Date_Source_Received_Required />
				<cfset qCompetitorSource = ProgramManager.getCompetitorSource(1)>

				<cfif vars.source EQ 1 AND vars.sourceType EQ 1>
					<cfset OtherOptionSelected = 0>
					<!--- If the user had selected the "Other" option from the "Competitor Source" option --->
					<cfif bidReqObj.ID neq 0 AND ListFindNoCase(ValueList(qCompetitorSource.Program_Bid_Source_ID),bidReqObj.getSourceID()) eq 0>
						<cfset OtherOptionSelected = 1>
					</cfif>
					<TR>
						<TD align="right" nowrap><span id="error_CompetitorSourceID"></span>&nbsp;<B>Competitor Source:</B></TD>
						<TD>
						<cfoutput>
						<select name="CompetitorSourceID" id="CompetitorSourceID" onChange="showCompetitorSource_Other()">
							<option value="0">****SELECT****</option>
							<cfloop query="qCompetitorSource">
							<option value="#qCompetitorSource.Program_Bid_Source_ID#" <cfif bidReqObj.getSourceID() IS qCompetitorSource.Program_Bid_Source_ID>selected</cfif>>#qCompetitorSource.Program_Bid_Source_Description#</option>
							</cfloop>
							<option value="-1" <cfif OtherOptionSelected eq 1>selected</cfif>>Other</option>
						</select>
						<input type="hidden" name="Source" 					value="#vars.source#" />
						<input type="hidden" name="Source_Type" 			value="#vars.sourceType#" />
						<input type="hidden" name="Source_Required" 		value="#vars.sourceRequired#" />
						<input type="hidden" name="Source_Type_Required" 	value="#vars.sourceTypeRequired#" />
						<input type="hidden" name="Date_Source_Received_Required" value="#vars.dateSourceReceivedRequired#" />
						</cfoutput>
						</TD>
					</TR>

					<!--- If the user had selected the "Other" option from the "Competitor Source" option --->
					<cfif OtherOptionSelected eq 1>
						<cfset ShowSourceOther = "block">
					<cfelse>
						<cfset ShowSourceOther = "none">
					</cfif>

					<!--- Get all Inactive source. The "Other" option will be saved as "Inactive". --->
					<cfset qCompetitorSourceInactive = ProgramManager.getCompetitorSource(0)>

					<cfset SelectedInactiveSourceCode = "">

					<cfloop query="qCompetitorSourceInactive">
						<cfif bidReqObj.getSourceID() IS qCompetitorSourceInactive.Program_Bid_Source_ID>
							<!--- Get the source description for the Inactive source --->
							<cfset SelectedInactiveSourceCode = qCompetitorSourceInactive.Program_Bid_Source_Code>
							<cfbreak>
						</cfif>
					</cfloop>

					<TR>	<cfoutput>
						<TD align="right" id="CompetitorSourceOtherLabel"  style="display:#ShowSourceOther#" nowrap><span id="error_CompetitorSourceOtherLabel"></span>&nbsp;<B>Other Competitor Source:</B></TD>
						<TD> <input type="text" name="CompetitorSourceOther" id="CompetitorSourceOther" value="#SelectedInactiveSourceCode#" style="display:#ShowSourceOther#" maxlength="25" /></TD>
						<!--- This condition is very important. We need to pass "CompetitorSourceOtherID" as blank when the user had not selected the "Other Option" earlier.
						      It is possible for the user to change the source to "other" from an active source. In this case, we need to pass a blank CompetitorSourceOtherID,
						      otherwise an existing ID will be updated with the valeu in "CompetitorSourceOtherID".
						--->
						<cfif OtherOptionSelected eq 1>
							<input type="hidden" name="CompetitorSourceOtherID" value="#bidReqObj.getSourceID()#" />
						<cfelse>
							<input type="hidden" name="CompetitorSourceOtherID" value="" />
						</cfif>
						</cfoutput>
					</TR>
					<cfset qCompetitorSourceType = ProgramManager.getCompetitorSourceType()>
					<TR>
						<TD align="right" nowrap><span id="error_CompetitorSourceType"></span>&nbsp;<B>Competitor Source Type:</B></TD>
						<TD>
						<cfoutput>
						<select name="CompetitorSourceType" id="CompetitorSourceType">
							<option value="0">****SELECT****</option>
							<cfloop query="qCompetitorSourceType">
							<option value="#qCompetitorSourceType.Program_Bid_Source_Type_ID#" <cfif bidReqObj.getSourceType() IS qCompetitorSourceType.Program_Bid_Source_Type_ID>selected</cfif>>#qCompetitorSourceType.Program_Bid_Source_Type_Description#</option>
							</cfloop>
						</select>
						</cfoutput>
						</TD>
					</TR>
				</cfif><!--- <cfif vars.source EQ 1 AND vars.sourceType EQ 1> --->
			</cfif>
		</cfif>
	<!--- End Note: Milan (28153) --->

	<!--- Dev Note: Milan - D6321 --->
	<!--- Only display for Program Categories --->
		<cfif appSettings.getProgramCategory() EQ 1>
			<cfset GetCategoriesfromTemplate = templateManager.getProgramCategories(FORM.ProgramType_ID)>
			<cfif GetCategoriesfromTemplate.Recordcount GT 0>
			<TR>
				<TD align="right" nowrap><span id="err_Program_Category_ID"></span>&nbsp;<B>Program Category:</B></TD>
				<TD>
				<cfoutput>
				<select name="Program_Category_ID">
				<cfif GetCategoriesfromTemplate.Recordcount NEQ 1>
					<option value="0">Choose</option>
				</cfif>
					<cfloop query="GetCategoriesfromTemplate">
					<option value="#GetCategoriesfromTemplate.Program_Category_ID#" <cfif Form.Program_Category_ID IS GetCategoriesfromTemplate.Program_Category_ID>selected</cfif>>#GetCategoriesfromTemplate.Program_Category#</option>
					</cfloop>
				</select>
				</cfoutput>
				</TD>
			</TR>
			</cfif>
		</cfif>
	<!--- End Note: Milan - D6321 --->
		<cfif appSettings.getPgmLikeProductCheckbox()>
		<cfset Like_Product_Exist_Msg = "Please enter the similar product information in the business considerations field" />
		<TR>
			<TD align="right" nowrap><B>Similar product exist:</B></TD>
			<TD valign="top">
				<cfoutput>
				<input name="Like_Product_Exist" type="checkbox" value="1" <cfif FORM.Like_Product_Exist>checked</cfif> title="#Like_Product_Exist_Msg#" onClick="javaScript: if(this.checked){alert('#Like_Product_Exist_Msg#');}" />
				</cfoutput>
			</TD>
		</TR>
		</cfif>
		<!---BJF -- If this is checked, and a user has permissions, the program will appear in the catalog--->
		<cfif getFieldSettings.Show_Awarded_in_Catalog>
		<TR>
			<TD align="right" nowrap><B>Awarded:</B></TD>
			<TD valign="top">
				<cfoutput>
				<input name="Is_Awarded" type="checkbox" value="1" <cfif FORM.Is_Awarded>checked</cfif>  />
				</cfoutput>
			</TD>
		</TR>
		</cfif>
<!--- D37492 /D38189::Alternate Payment Recipient --->
<cfif getFieldSettings.alternate_payment_recipient>
	<cfif len(form.Operator_List)>
			<cfquery name="operatorinfo" datasource="#application.datasource#">
				SELECT Operator_Name + '(' + isnull(Legacy_ID, BSA_Operator_ID) +')' AS Operator_info
				FROM BSA_Operator
				WHERE BSA_Operator_ID = #trim(form.Operator_List)#
			</cfquery>
				<cfset Alternate_Payee = #Operatorinfo.Operator_info#>
	<cfelse>
			<cfset Alternate_Payee = " ">
	</cfif>
		<TR>
				<TD ALIGN="right" VALIGN="top"><B>Alternate Payment Recipient</B></TD>
				<TD>
	<cfoutput>
				<a href="/billbacks/search_screens/pm_select_operators.cfm?CID=#EncryptedCID#&alternate_payment_recipient=1"  onClick="NewWindow(this.href,'help','850','650','Yes', 'No');return false">
					#LCase(ActionText("search " & application.returned_customer_setting.operator_label_plural))#
				</a>
				<br>
				#Alternate_Payee#
				<br>
		<input type="hidden" name="Operator_List" value="#form.Operator_List#">
	</cfoutput>
		</TR>
</cfif>
<!--- D37492 /D38189::Alternate Payment Recipient --->

		<!--- START: 42349 - Most Favored Nations - setup and alert --->
		<cfif GetSettings.Most_Favored_Nation EQ 1>
		<TR>
			<TD ALIGN="right" VALIGN="top"><B>Most Favored Nation:</B></TD>
			<TD>
				<input type="checkbox" name="Program_Most_Favored_Nation" value="1" <cfif FORM.Program_Most_Favored_Nation>checked</cfif>>
			</TD>
		</TR>
		</cfif>
		<!--- END 42349 - Most Favored Nations - setup and alert --->
		<cfif appSettings.getDisplayNotesFieldOnProgram() EQ 1>
		<TR>
			<TD ALIGN="right" VALIGN="top"><span id="error_Notes"></span><span id="error_Notes_Change"></span>&nbsp;<B><cfoutput>#labelnotes#</cfoutput>:</B><br>(Max chars = 2000)</TD>
			<TD>
				<CFSET notes_Max_Length = 2000>
				<CF_SCALABLETEXTAREA
					NAME="notes"
					ID="notes"
					COLS="57"
					ROWS="5"
					onPaste="javaScript: return textareaChecklength(#notes_Max_Length#, this);"
					onkeyPress="javaScript: return textareaChecklength(#notes_Max_Length#, this);"
					incrementlabel="<IMG SRC=""/images/bigger.gif"" BORDER=""0"" TITLE=""Bigger"">"
					decrementLabel="<IMG SRC=""/images/smaller.gif"" BORDER=""0"" TITLE=""Smaller"">"><CFOUTPUT>#replacenocase(Form.Notes, "NULL", "")#</CFOUTPUT></CF_SCALABLETEXTAREA>
			<!--- <cf_scalabletextarea NAME="notes"><CFOUTPUT>#Form.Notes#</CFOUTPUT></cf_scalabletextarea> --->
			</TD>
		</TR>
		<cfelse>
			<input type="hidden" name="notes" value="<cfoutput>#replacenocase(Form.Notes, "NULL", "")#</cfoutput>" />
		</cfif>


		<cfif trim(getFieldSettings.Generic_Type) eq "Direct Pricing">
		<TR>
			<TD ALIGN="right" VALIGN="top"><span id="error_Competitive_Info_Notes"></span><span id="error_Competitive_Info_Notes_Change"></span>&nbsp;<B><cfoutput>Competitive Information</cfoutput>:</B></TD>
			<TD>
				<CFSET notes_Max_Length = 2000>
				<CF_SCALABLETEXTAREA
					NAME="Competitive_Info_Notes"
					ID="Competitive_Info_Notes"
					COLS="57"
					ROWS="5"
					onPaste="javaScript: return textareaChecklength(#notes_Max_Length#, this);"
					onkeyPress="javaScript: return textareaChecklength(#notes_Max_Length#, this);"
					incrementlabel="<IMG SRC=""/images/bigger.gif"" BORDER=""0"" TITLE=""Bigger"">"
					decrementLabel="<IMG SRC=""/images/smaller.gif"" BORDER=""0"" TITLE=""Smaller"">"><CFOUTPUT>#replacenocase(Form.Competitive_Info_Notes, "NULL", "")#</CFOUTPUT></CF_SCALABLETEXTAREA>
			</TD>
		</TR>
		</cfif>
	</TABLE>
<BR><BR>
<TABLE ALIGN="Center" BORDER="0" width="800">
<TR>
	<TD align="center"><FONT SIZE="2" COLOR="Red"><B>You MUST save to be able to enter the remainder of the program's contents</B></FONT><br></TD></tr>
<tr><td align="center">
<CF_button
		button_name		=	"save"
		button_caption	=	"#FORM.button_caption#"
		button_action	=	"confirmCompletion(1, 'save_table');"
		button_type		=	"javascript_link"
		button_width	=	"175"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	></td>
</TR>
</TABLE>

<TABLE width="800">
<TR>
	<TD>

	</TD>
<!--- 	<TD>
	<CF_button
		button_name		=	""
		button_caption	=	"load from template"
		button_action	=	"contract_select_template.cfm"
		button_type		=	"link"
		button_width	=	"175"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>
	</TD> --->
</TR>
</TABLE>
<cfif application.programlayout EQ 1></div></cfif>


<!---
<div align="center"><INPUT TYPE="button" value="<CFOUTPUT>#FORM.button_caption#</CFOUTPUT>" onclick="confirmCompletion()"></div>
 --->

<cfoutput>


<CF_CRYP type="en" string="#URL.CID#" key="#request.key#">
<CFIF len(trim(URL.CID)) GT 0><CFSET URL.CID = cryp.value><input type="hidden" name="CID" value="#cryp.value#"><CFELSE><input type="hidden" name="CID" value=""></CFIF>
<input type="hidden" name="Document_ID" value="contract_create_1_form">

<!---this code will tell queries.cfm whether to insert or update--->
<CFIF len(trim(URL.CID)) EQ 0>
	<input type="hidden" name="Query_Type" value="INSERT">
	<input type="hidden" name="ProgramType_ID" value="#FORM.ProgramType_ID#">

<CFELSE>
	<input type="hidden" name="Query_Type" value="UPDATE">
	<input type="hidden" name="ProgramType_ID" value="#FORM.ProgramType_ID#">
</CFIF>

 <cfif FORM.Created_Type neq "">
	<input type="hidden" name="Created_Type" id="Created_Type" value="#FORM.Created_Type#">
<cfelse>
	<input type="hidden" name="Created_Type" id="Created_Type" value="">
</cfif>

<INPUT TYPE="hidden" NAME="On_Release_Contract_Status_Type_IDX" ID="On_Release_Contract_Status_Type_IDX" VALUE="#FORM.On_Release_Contract_Status_Type_IDX#">


<!--- if the GL is high then use the DB data --->
<Cfif FORM.Global_GL_Assign_Setting EQ 1>
<input name="GL_Assignment_ID" type="hidden" value="#FORM.Global_GL_Assign_Choice_Setting#">
</CFIF>
<CFIF isdefined("FORM.CONTRACT_RENEWAL_PACKETS_ID")>
	<input name="CONTRACT_RENEWAL_PACKETS_ID" type="hidden" value="#FORM.CONTRACT_RENEWAL_PACKETS_ID#">
</CFIF>
<INPUT TYPE="Hidden" NAME="Do_Revise_Copy" value="#form.Do_Revise_Copy#">
<INPUT TYPE="Hidden" NAME="Program_ID_To_Replicate" value="#Program_ID_To_Replicate#">
<INPUT TYPE="hidden" NAME="Program_ID" VALUE="#form.Program_ID#" ><!--- D50711 Program Date Changes  --->
<!---if we are coming from Trade Planner then set variables needed--->
<cfif isDefined("form.bIsFromTradePlan") and form.bIsFromTradePlan>
	<INPUT TYPE="Hidden" NAME="tpFileName" VALUE="#Form.tpFileName#">
	<INPUT TYPE="Hidden" NAME="bIsFromTradePlan" VALUE="#FORM.bIsFromTradePlan#">
	<INPUT TYPE="Hidden" NAME="tradePlanId" VALUE="#Form.tradePlanId#">
</cfif>

<!--- revision indicator --->
<input name="ISREVISIONOFEXISTINGCONTRACT"	type="hidden" value="#FORM.ISREVISIONOFEXISTINGCONTRACT#">
<input name="parentStartDate" 				type="hidden" value="#DateFormat(form.parentStartDate,'mm/dd/yyyy')#">
<input name="checkParentStartDate" 			type="hidden" value="#form.checkParentStartDate#">
<INPUT name="Limited_Revise" type="hidden" value="#form.Limited_Revise#" >
<!--- rollover indicator --->
<input name="IsRollOver" type="hidden" value="#FORM.IsRollOver#">
<input name="businessSegmentsOn" type="hidden" value="#form.businessSegmentsOn#">
<input name="EZTemplate" type="hidden" value="#getFieldSettings.EZButton_on#">
<input name="check_program_uom" type="hidden" value="#FORM.check_program_uom#">

<!--- Copied Search Sequence Indicators --->
	<INPUT TYPE="hidden" NAME="NewSearchSequence" VALUE="#Form.NewSearchSequence#" >
	<INPUT TYPE="hidden" NAME="suppressProductsDistributors" VALUE="#Form.suppressProductsDistributors#">
</cfoutput>

</FORM>



<!--- <SCRIPT SRC="/common_files/scripts/Date_Difference.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/validateFormUtils.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/date_functions.js"></SCRIPT> --->

<cfinclude template="/common_files/jQuery.cfm">
<cf_include files="/styles/css-loader.css">

<SCRIPT>
	var ErrorCount = 0;
	var vReturnValue = null;
	var selectedGLCode = null

	<!--- <cfinclude template="/common_files/scripts/Date_Difference.js"> --->

	/*
	Commented it as it is probably not being used.
	function popGLWindow() {
		selectedGLCode = parseInt(document.all.GL_Assignment_ID.value);
		vReturnValue = window.showModalDialog("/common_files/contracts/GL_Codes.cfm",selectedGLCode,"dialogHeight: 500px; dialogWidth: 700px; dialogTop: px; dialogLeft: px; edge: Raised; center: Yes; help: No; resizable: No; status: No;");
		if(vReturnValue !=null)	{
			document.all.GL_Text.value = vReturnValue.GL_Name;
			document.all.GL_Assignment_ID.value = vReturnValue.value;
			selectedGLCode = vReturnValue.value
		}
	}
	*/

	function Check_Equipment_Placement(UniqueID)
	{
		var Answer;
		var DisplayObject;

		/* Get the row's ID */
		DisplayObject = document.getElementById(UniqueID);

		/* If the Equipment_Placement check box is unchecked */
		if(document.MyForm.Equipment_Placement.checked ==0){
			if(document.MyForm.Equipment_Placement_Note.value != ''){
					 Answer = confirm('The message associated with the equipment will be deleted. Do you want to uncheck the equipment selection?')
						if(Answer == 1){
								document.MyForm.Equipment_Placement_Note.value = '';
								DisplayObject.style.display = 'none';
						}
				else{
					document.MyForm.Equipment_Placement.checked = 1;
					DisplayObject.style.display = '';
				}
			}
		else{
			DisplayObject.style.display = 'none';
				}
		}
		else{
			DisplayObject.style.display = '';
		}
	}

	/* Makes sure that SalesOrg and Distribution  Channel fields are required (Business_segment_ID AND LOB_ID).
		Also, pass those values in the URL to the popup window for Pactiv */
	function CriteriaCheck()
	{
		var sBS = 0;
		var sLOB = 0;
		var ErrorCount =0;
		<cfif form.businessSegmentsOn eq 1>

			 var oBS = document.all.Business_Segment_ID;

            	if(oBS.type == "hidden")
				{
					sBS = oBS.value;
				}
            	else
				{
					sBS = oBS.options[oBS.selectedIndex].value;
				}

				 if(sBS == 0){
					ErrorCount++;
					queueMessage("You must select a Business segment.", document.all.err_Business_Segment_ID);
	            }
				else
				{
					clearQueue(document.all.err_Business_Segment_ID);
	            }

		</cfif>

		<cfif appSettings.getSalesOrgOn()>

				var oLOB = document.all.LOB_ID;

				if(oLOB.type == "hidden")
				{
					sLOB = oLOB.value;
				}
				else
				{
					sLOB = oLOB.options[oLOB.selectedIndex].value;
				}

				if(sLOB == 0){
					ErrorCount++;
					queueMessage("You must select a Line of Business.", document.all.err_LOB_ID);
				}
				else
				{
					clearQueue(document.all.err_LOB_ID);
				}

		</cfif>

			if(ErrorCount != 0)
			{
			showMessageWindow();
			}

			return false;
	}

	function showCompetitorSource_Other()
	{

		if(document.all.CompetitorSourceID.value == '-1')
		{
		 document.all.CompetitorSourceOther.style.display = "block";
		 document.all.CompetitorSourceOtherLabel.style.display = "block";
		}
		else
		{
		 document.all.CompetitorSourceOther.style.display = "none";
		 document.all.CompetitorSourceOtherLabel.style.display = "none";
		}
	}

	function confirmCompletion(disableClickedButton, disableClickedButtonName)
	{

		ErrorCount = 0;

		//Business segment validation
		//if businessSegmentsOn is on then do validation
		if(document.all.businessSegmentsOn.value == 1)
		{
			//if id is zero then segment wasn't selected
			if (document.all.Business_Segment_ID.value == 0)
			{
				ErrorCount++;
				queueMessage("You must select a Business Segment.", document.all.error_BusinessSegment);
			}
			else
			{
				clearQueue(document.all.error_BusinessSegment);
			}
		}

		<cfif appSettings.getSalesOrgOn()>
			//if id is zero then segment wasn't selected
			if (document.all.LOB_ID.value == 0)
			{
				ErrorCount++;
				queueMessage("You must select a Sales Organisation.", document.all.error_LOB);
			}
			else
			{
				clearQueue(document.all.error_LOB);
			}
		</cfif>
		<!------ Validate Operating Group ----->
		<cfif appSettings.getOperatingGroupOn() AND allowOpGrpSelection>
			//if id is zero then OperatingGroup wasn't selected
			<cfoutput>
			if (document.all.Operating_Group_1.value == "" || document.all.Operating_Group_1.value == "0")
			{
				ErrorCount++;
				queueMessage("You must select a #LCase(programLevel1LevelLabel)#.", document.all.error_Operating_Group_1);
			}
			else
			{
				clearQueue(document.all.error_Operating_Group_1);
			}
			if (document.all.Operating_Group_2.value == "" || document.all.Operating_Group_2.value == "0")
			{
				ErrorCount++;
				queueMessage("You must select a #LCase(programLevel2LevelLabel)#.", document.all.error_Operating_Group_2);
			}
			else
			{
				clearQueue(document.all.error_Operating_Group_2);
			}
			</cfoutput>
		</cfif>

	<!--- Contract Title Validation --->
//Below line will have the special characters that is not allowed you can add if you want more for some characters you need to add escape sequence
var  varREX = new RegExp("[`'~!@#$%^:;&*(){}?+-=_|/.,<>0-9a-zA-ZÀàáÂâÄäÇçÈèÉéÊêËëíÎîÏïóÔôÙùúÛûÜüŸÿ \r]", "g");
//m = document.all.Contract_Title.value;
// chromefix WR 56796 - Chrome - Programs create - not able to clear text fields using x
m = jQuery("textarea[name=Contract_Title]").val();
var error = 0;
var v1 = '"';
var v2='\\';
var v3='[';
var v4=']';


	//if(document.all.Contract_Title.disabled == false)
	// chromefix WR 56796 - Chrome - Programs create - not able to clear text fields using x
	if(jQuery("textarea[name=Contract_Title]").prop("disabled") == false)
	{

			//if(document.all.Contract_Title.value.length == 0)	{
			// chromefix WR 56796 - Chrome - Programs create - not able to clear text fields using x
			//if(jQuery("textarea[name=Contract_Title]").val().length == 0)	{

			var strContTitle = jQuery("textarea[name=Contract_Title]").val();
			if(strContTitle.length == 0)	{
				ErrorCount++;
				queueMessage("You must enter a program title.", document.all.error_ContractTitle);
			}
			else if(strContTitle.length > <CFOUTPUT>#Contract_Title_Max_Length#</CFOUTPUT>)	{
				ErrorCount++;
				queueMessage("The program title cannot be longer than <CFOUTPUT>#Contract_Title_Max_Length#</CFOUTPUT> characters.", document.all.error_ContractTitle);
			}
		  else
		  {
			  for (i = 0; i < m.length; i++)
        {
          if ((m.substring(i,i+1)).match(varREX) == null)
          {
            // since the regular expression  was not working right for the chars ",\ a separate we are doing a check for those
            // characters here
            if (!((m.substring(i,i+1)== v1) || (m.substring(i,i+1)== v2) || (m.substring(i,i+1)== v3) || (m.substring(i,i+1)== v4)))
            {
              error = error +  1;
              break;
            }
          }
        }

      if (error > 0)
      {
        ErrorCount++;
        queueMessage("Some of the special characters entered are not supported, please change them!", document.all.error_ContractTitle);
      }
      else
      {
        clearQueue(document.all.error_ContractTitle);
      }
		}
	}

	<cfif (isDefined("qGetPlannerPerfTypes") AND qGetPlannerPerfTypes.RecordCount NEQ 0)>
	 	var oPTId = document.all.Planner_Perf_Types_ID;

            	if(oPTId.type == "hidden")
				{
					sPTId = 1;// oPTId.value;
				}
            	else
				{
					sPTId = oPTId.options[oPTId.selectedIndex].value;
				}

				 if(sPTId == 0){
					ErrorCount++;
					queueMessage("You must select a Performance Type.", document.all.err_Planner_Perf_Types_ID);
	            }
				else
				{
					clearQueue(document.all.err_Planner_Perf_Types_ID);
	            }
	
	</cfif>
	
		<!--- Contract Title Validation --->
		if(document.all.MyForm.Contract_Reference_Number.value.length >  200)	{
			ErrorCount++;
			queueMessage("The program reference number cannot be longer than 200 characters.", document.all.error_ContractNumber);
		}
		else
		{
			clearQueue(document.all.error_ContractNumber);
		}
<cfif GetSettings.allow_Reference_2 EQ 1>
		if(document.all.MyForm.Contract_Reference_Number_2.value.length >  200)	{
			ErrorCount++;
			queueMessage("The program reference number cannot be longer than 200 characters.", document.all.error_Contract_Reference_Number_2);
		}
		else
		{
			clearQueue(document.all.error_Contract_Reference_Number_2);
		}
</cfif>
		DateRequirementMet = 0;

<cfif  (IsRevision eq 1 AND RevisionSettings.Date_Changes eq 2) OR startDateDisabled eq 1>
	FromDate = new Date(<CFOUTPUT>'#FORM.start_date#'</CFOUTPUT>);
<cfelse>
	FromDate = new Date(document.MyForm.start_date.value);
</cfif>

		ToDate = new Date(document.MyForm.end_date.value);

		<!--- Date Validation --->
		// When date type is fixed they have to select a fiscal year first.
		<cfif form.Program_Date_Type eq 2>
			if(document.MyForm.fiscal_year.disabled == false){
				if(document.MyForm.fiscal_year.value.length == 0 || document.MyForm.fiscal_year.value == 'Year')
				{
					ErrorCount++;
					queueMessage("You must select a fiscal year to pick the program start and end dates.", document.all.error_ContractFiscalYear);
				}
				else{
					clearQueue(document.all.error_ContractFiscalYear);
				}
			}
		</cfif>

		if(document.MyForm.start_date.disabled == false)
		{
			<!--- Start Date ---><!--- Dev Note: Milan: 10932 --->
	   		var RegExPattern = /^(?=\d)(?:(?:(?:(?:(?:0?[13578]|1[02])(\/)31)\1|(?:(?:0?[1,3-9]|1[0-2])(\/)(?:29|30)\2))(?:(?:1[6-9]|[2-9]\d)?\d{4})|(?:0?2(\/)29\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))|(?:(?:0?[1-9])|(?:1[0-2]))(\/)(?:0?[1-9]|1\d|2[0-8])\4(?:(?:1[6-9]|[2-9]\d)?\d{4}))($|\ (?=\d)))?(((0?[1-9]|1[012])(:[0-5]\d){0,2}(\ [AP]M))|([01]\d|2[0-3])(:[0-5]\d){1,2})?$/;
			if ((document.MyForm.start_date.value.match(RegExPattern)) && (document.MyForm.start_date.value !=''))
			{
	       		clearQueue(document.all.error_ContractStartDateValidity);
	    	} else {
	       		ErrorCount++;
					queueMessage("You must enter a valid start date in MM/DD/YYYY format.",  document.all.error_ContractStartDateValidity);
	    	}

			<!--- End Date --->
		    if ((document.MyForm.end_date.value.match(RegExPattern)) && (document.MyForm.end_date.value !=''))
				{
		       	clearQueue(document.all.error_ContractEndDateValidity);
		    } else {
		       ErrorCount++;
						queueMessage("You must enter an valid end date in MM/DD/YYYY format.",  document.all.error_ContractEndDateValidity);
		    }
		}
		<!--- End Note: Milan: 10932 --->

//		if(document.MyForm.start_date.disabled == false)
//		{
			<cfif IsRevision eq 1 AND RevisionSettings.Start_Date_Change eq 2>
				var Parent_Program_Start_Date = new Date(<cfoutput>"#DateFormat(RevisionSettingsInfo.Contract_Start_Date,'mm/dd/yyyy')#"</cfoutput>);
				var rev_start_date = new Date(document.MyForm.start_date.value);
				if(Parent_Program_Start_Date < rev_start_date)
				{
					ErrorCount++;
					queueMessage("The program start date cannot be later than the original program start date.", document.all.error_ContractStartDateChange);
				}
			</cfif>

			<cfif IsRevision eq 1 AND RevisionSettings.End_Date_Change eq 2>
				var Parent_Program_Start_Date = new Date(<cfoutput>"#DateFormat(RevisionSettingsInfo.Contract_Start_Date,'mm/dd/yyyy')#"</cfoutput>);
				var rev_end_date = new Date(document.MyForm.end_date.value);

				if(Parent_Program_Start_Date > rev_end_date)
				{
					ErrorCount++;
					queueMessage("The program end date cannot be earlier than the original program start date.", document.all.error_ContractEndDateChange);
				}
			</cfif>

			if((document.MyForm.start_date.disabled == false && document.MyForm.start_date.value.length == 0) || (document.MyForm.end_date.disabled == false && document.MyForm.end_date.value.length == 0))
			{
				ErrorCount++;
				queueMessage("You must enter both a program start date and a program end date.", document.all.error_ContractSpan);
			}
			else
				{
				if(ToDate < FromDate){
					ErrorCount++;
					queueMessage("The program end date must be after the program start date.", document.all.error_ContractSpan);
				}
				else{
					clearQueue(document.all.error_ContractSpan);
					DateRequirementMet=1;
				}
			}
//		}
		/* Dev Note:(64090)"contract_period_start_date" and "contract_period_end_date" validation.
		NOTE:THIS IS NOT CONTRACT START AND END DATE (DELIVERY DATES).
		*/
		<cfif GetSettings.show_Contract_Dates eq 1>
		if(document.MyForm.contract_period_start_date.value.length == 0 || document.MyForm.contract_period_end_date.value.length == 0){
			ErrorCount++;
			queueMessage("You must enter both a contract period start date and a contract period end date.", document.all.error_ContractPeriodSpan);
		}
		else{
			FromContractPeriodDate = new Date(document.MyForm.contract_period_start_date.value);
			ToContractPeriodDate = new Date(document.MyForm.contract_period_end_date.value);
			if(ToContractPeriodDate < FromContractPeriodDate){
				ErrorCount++;
				queueMessage("The contract period end date must be after the contract period start date.", document.all.error_ContractPeriodSpan);
			}
			else{
				clearQueue(document.all.error_ContractPeriodSpan);
			}
		}
		</cfif>
		<cfoutput>

	<!--- Dev Note: Milan; 6117 --->
	 <!--- Program Start/End Days --->
		var StartDayNum;
		var EndDayNum;
		<!--- Get the template settings for the day of the week (start and end) --->
		var Program_Start_Day_Num = <cfoutput>#FORM.Program_Start_Day_Number#</cfoutput>;
		var Program_End_Day_Num = <cfoutput>#FORM.Program_End_Day_Number#</cfoutput>;

		<!--- Convert Week Day Numbers from "0-6" to "1-7" to match JS and CF Week Day Numbers
			 This is the reason why the week day nums were increased by 1 --->

		StartDayNum = FromDate.getDay() + 1;
		EndDayNum = ToDate.getDay() + 1;

	<cfif form.Program_Date_Type eq 1>
		<!--- If the user has entered a date and the template forces a week day --->
			if(isNaN(StartDayNum) == false && Program_Start_Day_Num != 0)
			{
					if(Program_Start_Day_Num != StartDayNum)
					{
						ErrorCount++;
						queueMessage("The program start day must be a " + WeekDayInWords(Program_Start_Day_Num)+".", document.all.error_ContractStartDaySpan);
					}
					else
					{
						clearQueue(document.all.error_ContractStartDaySpan);
					}
			}

		<!--- If the user has entered a date and the template forces a week day --->
			if(isNaN(EndDayNum) == false && Program_End_Day_Num != 0)
			{
					if(Program_End_Day_Num != EndDayNum)
					{
						ErrorCount++;
						queueMessage("The program end day must be a " + WeekDayInWords(Program_End_Day_Num)+".", document.all.error_ContractEndDaySpan);
					}
					else
					{
						clearQueue(document.all.error_ContractEndDaySpan);
					}
			}
	</cfif>

		<!--- 1 is Sunday, 7 is Saturday --->
		function WeekDayInWords(Day_Num)
		{
				var dayofweek

						switch (Day_Num) {
						case 1:
						dayofweek="Sunday"
						break;
						case 2:
						dayofweek="Monday"
						break;
						case 3:
						dayofweek="Tuesday"
						break;
						case 4:
						dayofweek="Wednesday"
						break;
						case 5:
						dayofweek="Thursday"
						break;
						case 6:
						dayofweek="Friday"
						break;
						case 7:
						dayofweek="Saturday"
						break;
						//default:
						//dayofweek="error"
						}
					return dayofweek
				}
		<!--- End Note: Milan; 6117 --->

		<!--- control panel setting check for duration --->
		<cfif trim(FORM.Max_Duration_Setting) EQ 1 >
		if(DateRequirementMet) {
			numberOfDays = days_between(FromDate,ToDate)
			numberOfDays = numberOfDays + 1;
			if(numberOfDays > parseInt(#trim(listgetat(FORM.Max_Duration_Length_Setting, 1, "."))#)) {
				ErrorCount++;
				queueMessage("The length of the program cannot be more than #listgetat(trim(FORM.Max_Duration_Length_Setting), 1, ".")# day(s).", document.all.error_ContractSpan)
			}
			else{
				clearQueue(document.all.error_ContractSpan);
			}
		}
		</cfif>

		<cfif len(trim(application.returned_customer_setting.Program_Start_Date)) GT 0>
		StartDate = new Date(document.MyForm.start_date.value);
		<cfset AllowedStartDate = dateformat(application.returned_customer_setting.Program_Start_Date, 'mm/dd/yyyy')>
		AllowedStartDate = new Date("#AllowedStartDate#");

		if(StartDate < AllowedStartDate)
		{
			ErrorCount++;
			queueMessage("The start date for this program cannot be before #AllowedStartDate#.",  document.all.error_ProgramStart);
		}
		else
		{
				clearQueue(document.all.error_ProgramStart);
		}
		</cfif>

		<!--- control panel setting check for duration --->
		<cfif trim(FORM.Min_Duration_Setting) EQ 1>
		if(DateRequirementMet) {
			numberOfDays =	days_between(FromDate,ToDate)
			if(numberOfDays < #trim(listgetat(FORM.Min_Duration_Length_Setting, 1, "."))#){
				ErrorCount++;
				let delivery_period_label = "#general_labels[ delivery_period ]#";
				queueMessage("The " + delivery_period_label + " must be longer than #trim(listgetat(FORM.Min_Duration_Length_Setting, 1, "."))# days(s).",document.all.error_ContractSpan)
			}
			else{
					clearQueue(document.all.error_ContractSpan);
			}
		}
		</cfif>

		<CFIF FORM.ISREVISIONOFEXISTINGCONTRACT EQ 0>
		<!--- Allow RetroActive --->
		if(DateRequirementMet)
			{
				DateToday = new Date()
				DateToday = new Date(DateToday.getFullYear(), DateToday.getMonth(),DateToday.getDate())
				<cfif trim(FORM.Allow_retro_Create_Setting) EQ 0>
					if(FromDate < DateToday)
						{
							ErrorCount++;
							queueMessage("The start date of this program cannot be in the past.", document.all.error_ContractSpan)
						}
					else
						{
							clearQueue(document.all.error_ContractSpan);
						}
				<cfelse>
					if(FromDate < DateToday)
						{
							differenceInDays=days_between(FromDate,DateToday)

							if(differenceInDays > #trim(FORM.Allow_Retro_Create_Max_Setting)#)
								{
									ErrorCount++;
									queueMessage("The start date of this program cannot be more than " + parseInt(#trim(FORM.Allow_Retro_Create_Max_Setting)#) + " day(s) in the past.", document.all.error_ContractSpan)
								}
							else
								{
									clearQueue(document.all.error_ContractSpan);
								}
						}
				</cfif>
			}
		<CFELSE>
		if(DateRequirementMet)
			{
				DateToday = new Date()
				DateToday = new Date(DateToday.getFullYear(), DateToday.getMonth(),DateToday.getDate())
				<cfif trim(FORM.Allow_Retro_Revision) EQ 0>
					if(FromDate < DateToday)
						{
							ErrorCount++;
							queueMessage("The start date of this program cannot be in the past.", document.all.error_ContractSpan)
						}
					else
						{
							clearQueue(document.all.error_ContractSpan);
						}
				<cfelse>
					if(FromDate < DateToday)
						{
							differenceInDays=days_between(FromDate,DateToday)

							if(differenceInDays > #trim(FORM.Allow_Retro_Revision_Span)#)
								{
									ErrorCount++;
									queueMessage("The start date of this program cannot be more than " + parseInt(#trim(FORM.Allow_Retro_Revision_Span)#) + " day(s) in the past.", document.all.error_ContractSpan)
								}
							else
								{
									clearQueue(document.all.error_ContractSpan);
								}
						}
				</cfif>
			}
		</CFIF>

		<!--- control panel setting check for min start day "1. Program start date cannot start before:  xx/xx/xxxx" --->
		<cfif IsDate(getFieldSettings.Program_Min_Start_Date)><!--- if NULL no need to check --->
			var pgmStartDate = new Date(document.MyForm.start_date.value);
			<cfset minStartDate = dateformat(getFieldSettings.Program_Min_Start_Date, 'mm/dd/yyyy')>
			var minStartDate = new Date("#minStartDate#");

			if(pgmStartDate < minStartDate)
			{
				ErrorCount++;
				queueMessage("The start date of this program cannot be before #minStartDate#.",  document.all.error_ContractMinStartDate);
			}
			else
			{
					clearQueue(document.all.error_ContractMinStartDate);
			}
		</cfif>

		<!--- control panel setting check for max end day "2. Program end date cannot end after: xx/xx/xxxx" --->
		<cfif IsDate(getFieldSettings.Program_Max_End_Date)><!--- if NULL no need to check --->
			var pgmEndDate = new Date(document.MyForm.end_date.value);
			<cfset minEndDate = dateformat(getFieldSettings.Program_Max_End_Date, 'mm/dd/yyyy')>
			var minEndDate = new Date("#minEndDate#");

			if(pgmEndDate > minEndDate)
			{
				ErrorCount++;
				queueMessage("The end date of this program cannot be after #minEndDate#.",  document.all.error_ContractMaxEndDate);
			}
			else
			{
					clearQueue(document.all.error_ContractMaxEndDate);
			}
		</cfif>
		<!--- D38942 :: Program Blackout Period on Frontend START--->
		<cfif getFieldSettings.Blackout_Periods EQ 2 AND (form.ISCOPYPROGRAM EQ 0)>
		if (document.all.Program_Start_Zero.value == '')
			{
			ErrorCount++;
			queueMessage("Weeks after start date to ignore for volume automation cannot be empty.", document.all.error_WeeksAfter);
			}
			else
			{
			clearQueue(document.all.error_WeeksAfter);
			}
		if (document.all.Program_Future_zero.value == '')
			{
			ErrorCount++;
			queueMessage("Weeks before end date to ignore for volume automation cannot be empty.", document.all.error_WeeksBefore);
			}
			else
			{
			clearQueue(document.all.error_WeeksBefore);
			}
		</cfif>
		<!--- D38942 :: Program Blackout Period on Frontend END--->
		<cfif Form.Auto_renew_setting GTE 1>
		<!---Auto renewal--->

				if(document.all.Auto_Renew.checked)
				{
					var arSDate = null;
					//60410
					if(! $("input[name='AR_Renewal_Type']:checked").val())
					{
						ErrorCount++;
						queueMessage("You must select a renewal type.", document.all.error_AR_Renewal_Type);
					}
					else
					{
						clearQueue(document.all.error_AR_Renewal_Type);
						if ( ! $('input[name=start_date]').is(':disabled') ) {
							if(document.MyForm.start_date.value.length > 0 && document.MyForm.end_date.value.length > 0)
							{	//65635
								/* get the index of the selected option */
								var radioButtons = $("input:radio[name='AR_Renewal_Type']");
								var selectedIndex_AR_Renewal_Type = radioButtons.index(radioButtons.filter(':checked')) + 1;

								var HowManyDays = 0;
								/* We need to figure out whether the lead time entered is a valid one. For that purpose, we get
								the start date of the renewed program and compare it with the current date.
								Note: The AJAX call is only required for the "Renew Fiscal Year" option ,but since it is being used for that
								purpose, we are using AJAX for other options too. If any new option is added in the future, this JS code should
								work without any modification.
								*/
								$.ajax({
									url: "/components/programs/Program.cfc"
									,type: "post"
									,data: {
										method: "getAutoRenewDatesJSON"
										,autoRenewType: selectedIndex_AR_Renewal_Type
										,programDateType: <cfoutput>#form.Program_Date_Type#</cfoutput>
										,startDate: $('input[name=start_date]').val()
										,endDate: $('input[name=end_date]').val()
									}
									,dataType: "json"
									,async: false
									,timeout: 60000
									,error: function(jqXHR, textStatus, errorThrown) {
										alert('An unexpected problem has occurred');
										//console.log(errorThrown);
									}
									/* The crux of the code is called below (ON SUCCESS)*/
									,success: function(data) {
										arSDate = data;

										var arSDate = new Date(arSDate);
										var HowManyDays = 0;
										if(arSDate)
										{
											var date1 = new Date();
											HowManyDays = days_between(date1, arSDate);
										}

										<cfif appSettings.AutoRenewSpaninPW IS 0 OR Allow_AR_Modification IS 1>
										if(document.all.Renewal_Lead_Time.value.length == 0)
										{
											ErrorCount++;
											queueMessage("You must enter an activation date", document.all.error_Renewal_Lead_Time)
										}
										else if(document.all.Renewal_Lead_Time.value > HowManyDays)
										{
											ErrorCount++;
											queueMessage("You cannot enter a lead time greater than " + HowManyDays + " days.", document.all.error_Renewal_Lead_Time)
										}
										else
										{
											clearQueue(document.all.error_Renewal_Lead_Time);
										}
										</cfif>

										var prgDateSpanInDays = days_between(FromDate,ToDate);
										if(prgDateSpanInDays > 365 && document.all.AR_Renewal_Type[0].checked == true)
										{
											ErrorCount++;
											queueMessage('For multi year programs, you must select Renew Concurrently.', document.all.error_MultiYearContractSpan);
										}
										else
										{
											clearQueue(document.all.error_MultiYearContractSpan);
										}

									}
								})
							}
						}
					}

				}
				</cfif>


		<!--- PAYMENT CYCLE --->
		if(document.all.PaymentCycle.selectedIndex == 0)
		{
			ErrorCount++;
			queueMessage("Select a payment cycle.", document.all.error_PaymentCycle)
		}
		else
		{
			clearQueue(document.all.error_PaymentCycle)
		}

		<!--- CURRENCY VALIDATION --->

		<cfif FORM.currency IS "NULL" or FORM.Currency IS "">
			<cfset FORM.currency = 0>
			<cfif getFieldSettings.Generic_Type EQ "Distributor Off-Invoice" OR appSettings.getPaymentCycleAtDiscountType()>
				if(document.all.Currency.selectedIndex != #LCase(FORM.Currency)#) {
					var answer = confirm("** YOU HAVE SELECTED A NEW CURRENCY."
									+ "\n\n There are two possible challenges with this:"
									+ "\n 1. Your selection does not match the default setting."
									+ "\n 2. You are editing the currency of this program."
									+ "\n\n *Please note - Editing the program's currency may cause unwanted"
									+ "\n results as currency rates differ and may have to be recalculated."
									+ "\n\nAre you sure you want to change the currency?");
				} else {
					var answer = true;
				}

			<cfelse>
				var answer = true;
			</cfif>
		<cfelse>
			var answer = true;
		</cfif>

		if (answer == true) {
			if(document.all.Currency.selectedIndex == 0)
			{
				ErrorCount++;
				queueMessage("Select a currency.", document.all.error_Currency)
			}
			else
			{
				clearQueue(document.all.error_Currency)
			}
		} else {
			return false;
		}

		<!--- control panel setting global volume --->
		<!---
		if(document.all.Quantity.value.length == 0) {
			ErrorCount++;
			queueMessage("You must enter a volume amount.", document.all.error_ContractQuantity)
		}
		else {

			if(document.all.Contract_Quantity_UOM_IDX.selectedIndex == 0)
				{
					ErrorCount++;
					queueMessage("You must select a unit of measure for volume.", document.all.error_ContractQuantity)
				}
			else
				{
					clearQueue(document.all.error_ContractQuantity);
					<cfif trim(FORM.Max_Global_Volume_Setting) EQ 1>
						userSuppliedVolume=parseInt(document.all.Quantity.value)

						maxGlobalVolumeUOM = document.all.Contract_Quantity_UOM_IDX.options[document.all.Contract_Quantity_UOM_IDX.selectedIndex].value
						maxGlobalVolumeUOMText = document.all.Contract_Quantity_UOM_IDX.options[document.all.Contract_Quantity_UOM_IDX.selectedIndex].innerText

						switch(maxGlobalVolumeUOM){
							//Cases
							case "1":
								maxGlobalVolume = parseInt(#FORM.Max_Global_Volume_Size_CS_Setting#)
							break;
							//Pounds
							case "2":
								maxGlobalVolume = parseInt(#FORM.Max_Global_Volume_Size_LBS_Setting#)
							break;
							//Gallons

						}

						if(userSuppliedVolume > maxGlobalVolume){
							ErrorCount++;
							tmpErrorMessage = "The volume of this program cannot be greater than " + maxGlobalVolume + " " + maxGlobalVolumeUOMText
							queueMessage(tmpErrorMessage, document.all.error_ContractQuantity)
						}
						else{
							clearQueue(document.all.error_ContractQuantity)
						}
					</cfif>

					<!--- control panel setting global volume --->
					<cfif trim(FORM.Min_Global_Volume_Setting) EQ 1>
					userSuppliedVolume=parseInt(document.all.Quantity.value)

					minGlobalVolumeUOM = document.all.Contract_Quantity_UOM_IDX.options[document.all.Contract_Quantity_UOM_IDX.selectedIndex].value
					minGlobalVolumeUOMText = document.all.Contract_Quantity_UOM_IDX.options[document.all.Contract_Quantity_UOM_IDX.selectedIndex].innerText

					switch(minGlobalVolumeUOM){
						//Cases
						case "1":
							minGlobalVolume = parseInt(#FORM.Min_Global_Volume_Size_CS_Setting#)
						break;
						//Pounds
						case "2":
							minGlobalVolume = parseInt(#FORM.Min_Global_Volume_Size_LBS_Setting#)
						break;
						//Gallons

					}

					if(userSuppliedVolume < minGlobalVolume){
						ErrorCount++;
						tmpErrorMessage = "The volume of this program must be greater than: " + minGlobalVolume + " " + minGlobalVolumeUOMText
						queueMessage(tmpErrorMessage,document.all.error_ContractQuantity)
					}
					else{
						clearQueue(document.all.error_ContractQuantity)
					}
					</cfif>
				}
			}
			--->

<!--- 		<CFIF FORM.Fixed_Price_Setting EQ 1>
			var theRadioButton = new Object();

			if(window.document.all.FRA_GNFP[1] == null)
				{

					theRadioButton = document.all.FRA_GNFP;
				}
			else
				{
					theRadioButton = document.all.FRA_GNFP[1];
				}
				if(theRadioButton.value){
					if(document.all.DEV_FOB[0].checked == false && document.all.DEV_FOB[1].checked == false)
						{
							ErrorCount++
							queueMessage("Select whether this is delivered or FOB",document.all.error_DiscountType)
						}
					else
						{
							clearQueue(document.all.error_DiscountType);
						}
				}

		</CFIF>
 --->

  		<!--- D8409: Broker and Trade Question - Validation --->
		<cfif appSettings.getBrokerTradeQuestOn() EQ 1 AND GetSettings.Broker_Trade_Question EQ 1>
			if(document.all.Affect_Shelter[0].checked)
			{
				if(!Any_Object_Checked(document.all.Affect_Shelter_Type))
				{
					ErrorCount++;
					queueMessage("You must specify what shelter affects", document.all.error_AffectShelterType);
				}
				else
				{
					clearQueue(document.all.error_AffectShelterType);
				}

			}
		</cfif>

 		<!---Checks to see if Payable_To and Send_Payment_To fields are required, and if they are, requires them.--->
		<!---Must include Payable_To--->
		<cfif form.Payable_To_Required IS 1 AND form.Payable_To IS 1>
		if (!(document.all.Pay_To_Distributor.checked))
		{
			<!---Company Name--->
			if(document.all.Payable_Company.value.length == 0)	{
				ErrorCount++;
				queueMessage("You must enter the name of the company who should be paid.", document.all.error_Payable_Company);
			}
			else{
				clearQueue(document.all.error_Payable_Company);
			}

			<!---Address 1--->
			if(document.all.Payable_Address_1.value.length == 0)	{
				ErrorCount++;
				queueMessage("You must enter the address of the company who should be paid.", document.all.error_Payable_Address_1);
			}
			else{
				clearQueue(document.all.error_Payable_Address_1);
			}

			<!---City--->
			if(document.all.Payable_City.value.length == 0)	{
				ErrorCount++;
				queueMessage("You must enter the city of the company who should be paid.", document.all.error_Payable_City);
			}
			else{
				clearQueue(document.all.error_Payable_City);
			}

			<!---Zip Code--->
			if(document.all.Payable_Zip.value.length < 5)	{
				ErrorCount++;
				queueMessage("You must enter the Postal code of the company who should be paid.", document.all.error_Payable_Zip);
			}
			else{
				clearQueue(document.all.error_Payable_Zip);
			}
		}
		</cfif>

		<!---Must include Send_Payment_To--->
		<cfif form.Send_Payment_To_Required IS 1 AND form.Send_Payment_To IS 1>

		if ((document.all.Send_To_Broker.checked = false) || (document.all.SameAsPayable.checked = false))
		{
			<!---Company Name--->
			if(document.all.Send_Company.value.length == 0)	{
				ErrorCount++;
				queueMessage("You must enter the name of the company to send the check to.", document.all.error_Send_Company);
			}
			else{
				clearQueue(document.all.error_Send_Company);
			}

			<!---Address 1--->
			if(document.all.Send_Address_1.value.length == 0)	{
				ErrorCount++;
				queueMessage("You must enter the address of the company to send the check to.", document.all.error_Send_Address_1);
			}
			else{
				clearQueue(document.all.error_Send_Address_1);
			}

			<!---City--->
			if(document.all.Send_City.value.length == 0)	{
				ErrorCount++;
				queueMessage("You must enter the city of the company to send the check to.", document.all.error_Send_City);
			}
			else{
				clearQueue(document.all.error_Send_City);
			}

			<!---Zip Code--->
			if(document.all.Send_Zip.value.length < 5)	{
				ErrorCount++;
				queueMessage("You must enter the Postal code of the company to send the check to.", document.all.error_Send_Zip);
			}
			else{
				clearQueue(document.all.error_Send_Zip);
			}
		}
		</cfif>

		<cfif GetFieldSettings.Include_Open_Date IS 1>
			<!---Open Date--->
			if(document.all.Open_Date.value.length == 0)	{
				ErrorCount++;
				queueMessage("You must enter an open date.", document.all.error_OpenDate);
			}
			else{
				clearQueue(document.all.error_OpenDate);
			}
		</cfif>

		<!--- Check whether "Use Fixed Price Type" app setting is ON AND check whether the template contains fixed price components which have "fixed price type" turned ON for Competitive date. These types for Deviated price (meets competition) and combination (blended) --->
		<cfif appsettings.getUseFixedPriceType() AND qCompetitiveInfoFixedPriceTypeComponentList.recordcount AND vars.source EQ 1 AND vars.sourceType EQ 1>
			<!--- Competitor Source ID --->
			if(document.all.CompetitorSourceID.value == 0 && document.all.Source_Required.value == 1)	{
				ErrorCount++;
				queueMessage("You must select the Competitor Source", document.all.error_CompetitorSourceID);
			}
			else{
				clearQueue(document.all.error_CompetitorSourceID);
			}

			<!--- Competitor Source Type --->
			if(document.all.CompetitorSourceType.value == 0 && document.all.Source_Type_Required.value == 1) {
				ErrorCount++;
				queueMessage("You must select the Competitor Type.", document.all.error_CompetitorSourceType);
			}
			else{
				clearQueue(document.all.error_CompetitorSourceType);
			}

			<!--- Confirm whether Source is entered for "Other" Source  --->
			if(document.all.CompetitorSourceID.value == -1 && document.all.Source_Type_Required.value == 1 &&  document.all.CompetitorSourceOther.value == '')	{
				ErrorCount++;
				queueMessage("You must enter Competitor Source", document.all.error_CompetitorSourceOtherLabel);
			}
			else{
				clearQueue(document.all.error_CompetitorSourceOtherLabel);
			}


		</cfif>

		<cfif GetFieldSettings.Include_Time_Of_Open_Date IS 1>
			<!---Open Time--->
			if(document.all.Open_Time.value.length > 0)	{
				if(IsValidTime(document.all.Open_Time.value) == false)
				{
					ErrorCount++;
					queueMessage("You must enter an valid time in HH:MM AM/PM format.", document.all.error_OpenTime);
				}
			}
			else{
				clearQueue(document.all.error_OpenTime);
			}
		</cfif>
			<!---Date Needed--->
		<cfif GetFieldSettings.Include_Date_Needed_by IS 1>
			if(document.all.Date_Needed.value.length == 0)	{
				ErrorCount++;
				queueMessage("You must enter a date needed.", document.all.error_DateNeeded);
			}
			else{
				clearQueue(document.all.error_DateNeeded);
			}
		</cfif>
			<!---Program Award Date--->
		<cfif GetFieldSettings.Include_Reply_Date IS 1>
			if(document.all.Expected_Reply_Date.value.length == 0)	{
				ErrorCount++;
				queueMessage("You must enter an Program Award Date.", document.all.error_ExpectedReplyDate);
			}
			else{
				clearQueue(document.all.error_ExpectedReplyDate);
			}
		</cfif>

<!--- Dev Note: Milan - D6321 --->
		<cfif appSettings.getProgramCategory() EQ 1>
			if(document.all.Program_Category_ID)
			{
					if(document.all.Program_Category_ID.value == 0)
					{
						ErrorCount++;
						queueMessage("You must select a Program_Category.", document.all.err_Program_Category_ID);
					}
					else
					{
						clearQueue(document.all.err_Program_Category_ID);
					}
			}
		</cfif>
<!--- End Note: Milan - D6321 --->

	var strNotes = jQuery("textarea[name=notes]").val();
	<!---Private Notes Revision Setting --->
		<cfif IsRevision EQ 1 AND RevisionSettings.Require_Public_Notes_Changed eq 1>
			// chromefix WR 56796 - Chrome - Programs create - not able to clear text fields using x
			//if((document.all.notes.value != '' && (document.all.notes.value.length ==  #Len(RevisionSettingsInfo.Notes)#))
				//|| document.all.notes.value == '') {

			if((strNotes != '' && (strNotes.length ==  #Len(RevisionSettingsInfo.Notes)#))
				|| strNotes == '') {
				ErrorCount++;
				queueMessage("You must enter the notes for the current revision",  document.all.error_Notes_Change);
			}
			else{
				clearQueue(document.all.error_Notes_Change);
			}
		</cfif>

		<cfif appSettings.getDisplayNotesFieldOnProgram() EQ 1>
		<!--- moved down so that the error message numbers are in order --->
		<!--- Note Validation --->
		if(strNotes.length > <CFOUTPUT>#notes_Max_Length#</CFOUTPUT>)	{
			ErrorCount++;
			queueMessage("Notes cannot be longer than <CFOUTPUT>#notes_Max_Length#</CFOUTPUT> characters.", document.all.error_Notes);
		}
		else{
			clearQueue(document.all.error_Notes);
		}
		<!--- Note Validation --->
		</cfif>

		if(<cfoutput>#appSettings.getprogramnotesrequired()#</cfoutput>)
		{
		if(strNotes.length == 0)	{
			ErrorCount++;
			queueMessage("You must enter <cfoutput>#labelnotes#</cfoutput>.", document.all.error_Notes);
		}
		else{
			clearQueue(document.all.error_Notes);
		}

		}

<!--- Performance Dates check --->
		  <cfif getFieldSettings.Retail_Performance_Dates EQ 1 AND getFieldSettings.Retail_Performance_Dates_Required EQ 1>
		   var performanceStartDate = new Date(document.MyForm.Performance_Start_Date.value);
		   var performanceEndDate = new Date(document.MyForm.Performance_End_Date.value);


    		if ((document.MyForm.Performance_Start_Date.value.match(RegExPattern)) && (document.MyForm.Performance_Start_Date.value !=''))
		    {
       			clearQueue(document.all.error_PerformanceStartDateValidity);
            }
            else
            {
       			ErrorCount++;
				queueMessage("You must enter a valid start date in MM/DD/YYYY format.",  document.all.error_PerformanceStartDateValidity);
            }
            if ((document.MyForm.Performance_End_Date.value.match(RegExPattern)) && (document.MyForm.Performance_End_Date.value !=''))
		    {
       			clearQueue(document.all.error_PerformanceEndDateValidity);
            }
            else
            {
       			ErrorCount++;
				queueMessage("You must enter a valid start date in MM/DD/YYYY format.",  document.all.error_PerformanceEndDateValidity);
            }


		   if(document.MyForm.Performance_Start_Date.value.length == 0 || document.MyForm.Performance_End_Date.value.length == 0)
			{
				ErrorCount++;
				queueMessage("You must enter both a performance start date and a performance end date.", document.all.error_PerformanceSpan);
			}
			else
			{
				clearQueue(document.all.error_PerformanceSpan);
			}


				if(performanceEndDate < performanceStartDate){
					ErrorCount++;
					queueMessage("The performance end date must be after the performance start date.", document.all.error_PerformanceDateSpan);
				}
				else{
					clearQueue(document.all.error_PerformanceDateSpan);

				}
		  </cfif>

<!--- Performance Requirement Check. Program Wizard determines
		      how many options can be selected --->
		<!---TSF - Label 19919: Performance Requirements Enhancements--->
	<cfif getFieldSettings.MaxPerfRequirements EQ '*'>
		<cfset PRMaxPerfRequirements = 9999>
	<cfelse>
		<cfset PRMaxPerfRequirements = getFieldSettings.MaxPerfRequirements>
	</cfif>

		<cfloop query="PerformanceRequirementLabels">
			var string = document.getElementById('#Perf_Req_Label#').value ;
			var stringArray = string.split(",").filter(Boolean);//Removes empty string from array
				if(stringArray.length < #getFieldSettings.MinPerfRequirements# ||stringArray.length > #PRMaxPerfRequirements# ){
					ErrorCount++;
					queueMessage("You must select minimum #getFieldSettings.MinPerfRequirements# or maximum #getFieldSettings.MaxPerfRequirements# performance Requirements for #Perf_Req_Label#",  document.all.error_PerfRequirementCategory_#Perf_Req_Label#);
				}
				else{
					clearQueue(document.all.error_PerfRequirementCategory_#Perf_Req_Label#);
				}
		</cfloop>

		<cfif GetPerfReqsforTemplate.Recordcount GT 0>
		<!---<cfif appsettings.get_Setting('GPO_One_Page_Program_Creation') NEQ 1 OR Discount_Identifier_Number NEQ "CPA">  Hide it if it is CPA --->
			var minRequirements = '#getFieldSettings.MinPerfRequirements#';
			var maxRequirements = '#getFieldSettings.MaxPerfRequirements#';
			var totRequirements = '#GetPerfReqsforTemplate.Recordcount#'
			var checkBox_counter = 0;
			var boxChecked = 0;
			document.MyForm.PerfRequirements.value = '';
			document.MyForm.NoPerfRequirements.value = '';
			<cfset loop = 0 />
			<cfloop query="GetPerfReqsforTemplate">
				<cfset tmpReqID = GetPerfReqsforTemplate.Program_Perf_Req_ID />
				<cfset loop = Loop + 1 />

				<cfif PR_Operator_Category eq 1>
					clearQueue(document.all.error_PerfRequirementCategory#tmpReqID#);
				</cfif>
				<cfif PR_Operator_Priority eq 1>
					clearQueue(document.all.error_PerfRequirementPriority#tmpReqID#);
				</cfif>
				<cfif PR_Date_Range eq 1>
					clearQueue(document.all.error_PerfRequirementDate#tmpReqID#);
				</cfif>
				<!--- alert('xxxx #tmpReqID# ::  document.MyForm.PerfReq_#tmpReqID#.checked :: ' + document.MyForm.PerfReq_#tmpReqID#.value); --->
				for (var i=0; i < document.MyForm.PerfReq_#tmpReqID#.length; i++)
				{
					if (document.MyForm.PerfReq_#tmpReqID#[i].checked)
					{
						var rad_val = document.MyForm.PerfReq_#tmpReqID#[i].value;

						if (rad_val == '0')
						{
							boxChecked = boxChecked + 1;
							if(document.MyForm.NoPerfRequirements.value == '')
							{
								document.MyForm.NoPerfRequirements.value = '#tmpReqID#';
							}
							else
							{
								document.MyForm.NoPerfRequirements.value = document.MyForm.NoPerfRequirements.value + ',#tmpReqID#';
							}

						}
						else if (rad_val == '1')
						{
							checkBox_counter = checkBox_counter + 1;
							if(document.MyForm.PerfRequirements.value == '')
							{
								document.MyForm.PerfRequirements.value = '#tmpReqID#';
							}
							else
							{
								document.MyForm.PerfRequirements.value = document.MyForm.PerfRequirements.value + ',#tmpReqID#';
							}
							<!---TSF - Label 19919: Performance Requirements Enhancements--->
							<cfif PR_Operator_Category eq 1>
								var oThisCat = document.MyForm.PerfReq_Category_#tmpReqID#;
								var bCategorySelect = oThisCat.options[oThisCat.selectedIndex].value;
								if(bCategorySelect < 1)
								{

									ErrorCount++;
			    					queueMessage("You must select a #variables.operatorCategoryLabel# if Performance Requirements is YES",  document.all.error_PerfRequirementCategory#tmpReqID#);
								}
							</cfif>

							<cfif PR_Operator_Priority eq 1>
								var oThisPri = document.MyForm.PerfReq_Priority_#tmpReqID#;
								var bPrioritySelect = oThisPri.options[oThisPri.selectedIndex].value;
								if(bPrioritySelect < 1)
								{
									ErrorCount++;
			    					queueMessage("You must select a #variables.operatorPriorityLabel# if Performance Requirements is YES",  document.all.error_PerfRequirementPriority#tmpReqID#);
								}
							</cfif>

							<cfif PR_Date_Range eq 1>
								var perfReqStartDateValue = document.MyForm.PerfReq_Start_Date_#tmpReqID#.value;
								var perfReqEndDateValue = document.MyForm.PerfReq_End_Date_#tmpReqID#.value;
								if(perfReqStartDateValue.length == 0 || perfReqEndDateValue.length == 0)
								{
									ErrorCount++;
			    					queueMessage("You must select a From and To Date if Performance Requirements is YES",  document.all.error_PerfRequirementDate#tmpReqID#);
								}
								else
								{
									var perfReqStartDate = new Date(perfReqStartDateValue);
									var perfReqEndDate = new Date(perfReqEndDateValue);

									if (perfReqStartDate > perfReqEndDate)
									{
										ErrorCount++;
			    						queueMessage("The Performance Requirement From Date must be less than the To Date",  document.all.error_PerfRequirementDate#tmpReqID#);
									}
									else if (FromDate > perfReqStartDate || ToDate < perfReqEndDate)
									{
										ErrorCount++;
			    						queueMessage("The Performance Requirement Dates must be within the Program Dates",  document.all.error_PerfRequirementDate#tmpReqID#);
									}
								}
							</cfif>

						}
					}
				}
			</cfloop>

			if(checkBox_counter + boxChecked < totRequirements)
			{
				ErrorCount++;
			    queueMessage("You must select YES or NO for all Performance Requirements",  document.all.error_PerfRequirement);
			}
			if (boxChecked == totRequirements && minRequirements != '0')
			{
				ErrorCount++;
			    queueMessage("You must select YES for at least one Performance Requirement",  document.all.error_PerfRequirement);
		     }
		    else
			{
				clearQueue(document.all.error_PerfRequirement);
			}

			if (maxRequirements == '*')
			{
			}
			else
			{
				if (checkBox_counter > maxRequirements)
				{
					ErrorCount++;
					queueMessage("You can not select YES for more than " + maxRequirements + " Performance Requirements",  document.all.error_PerfRequirement);
				}
				else
				{
					clearQueue(document.all.error_PerfRequirement);
				}
			}
		<!---</cfif>   Hide it if it is CPA --->
		</cfif> <!--- End of Performance Requirements Check --->
		<!--- D29125: Base Sales for a program --->
		<cfif (appSettings.PRICE_LIST_BY_TEMPLATE EQ 1 AND getFieldSettings.Base_Sales_based_on_Prg_Start_Date EQ 1 AND getFieldSettings.Select_Effective_Date_for_Price AND  FORM.ISREVISIONOFEXISTINGCONTRACT NEQ 1)>
			if(document.MyForm.Effective_Date_for_Price.value == "")
			{
				/* if(confirm("Reminder: The field 'Effective Date for Price' is blank.  If necessary, please fill it out."))
					{
							ErrorCount++;
							queueMessage("Please enter a value for 'Effective Date for Price'",  document.all.error_EffectiveDateforPrice);
					}
					else
					{
						clearQueue(document.all.error_EffectiveDateforPrice);
					}
				*/
				alert("Reminder: The field 'Effective Date for Price' is blank.");
			}
			else
			{

				// check for a valid date:
				var RegExPattern = /^(?=\d)(?:(?:(?:(?:(?:0?[13578]|1[02])(\/)31)\1|(?:(?:0?[1,3-9]|1[0-2])(\/)(?:29|30)\2))(?:(?:1[6-9]|[2-9]\d)?\d{4})|(?:0?2(\/)29\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))|(?:(?:0?[1-9])|(?:1[0-2]))(\/)(?:0?[1-9]|1\d|2[0-8])\4(?:(?:1[6-9]|[2-9]\d)?\d{4}))($|\ (?=\d)))?(((0?[1-9]|1[012])(:[0-5]\d){0,2}(\ [AP]M))|([01]\d|2[0-3])(:[0-5]\d){1,2})?$/;
				if ((document.MyForm.Effective_Date_for_Price.value.match(RegExPattern)) && (document.MyForm.Effective_Date_for_Price.value !=''))
				{

					var EffectiveDateforPriceDate = new Date(document.MyForm.Effective_Date_for_Price.value);
 					FromDate = new Date(document.MyForm.start_date.value);
					ToDate = new Date(document.MyForm.end_date.value);
					var Date_Today  = new Date();
					Date_Today = new Date(Date_Today.getFullYear(), Date_Today.getMonth(),Date_Today.getDate());
 					var prgAlreadyEffective = 0;
					var datesAreSame = !(Date_Today - FromDate);

					if (datesAreSame)
					{
						prgAlreadyEffective = 2;
					}
					else if (FromDate < Date_Today)
					{
						prgAlreadyEffective = 1;
					}
					else
					{
						prgAlreadyEffective = 0;
					}

					/*
						33352: Effective Price for Date Requiring Today's Date/Anand Rao/14-Aug-2012
						a)	Program Start date: Today or In the past
						b)	Created Date: Today
						c)	Validation(New): Effective date should be Prior to or equal to the created date(Meaning Effective Date can be less than or equal to the created date )
					*/
					if ((prgAlreadyEffective == 1) || (prgAlreadyEffective == 2))
					{
						// check the date range
						if (!(EffectiveDateforPriceDate <= Date_Today))
						{
							ErrorCount++;
							queueMessage("'Effective Date for Price' should be less than or equal to today's date",  document.all.error_EffectiveDateforPrice);
						}
						else
						{
							clearQueue(document.all.error_EffectiveDateforPrice);
						}
					}
		    	clearQueue(document.all.error_EffectiveDateforPrice);
				} else
				{
		       		ErrorCount++;
					queueMessage("You must enter a valid for 'Effective Date for Price' in MM/DD/YYYY format.",  document.all.error_EffectiveDateforPrice);
	    		}
			}
		</cfif>

		/* 34302 */
		<cfif getFieldSettings.currency_conversion_factor eq "1">
			var testFailed = false;
			var testValue = $("##currency_conversion_factor").val();
			var CurrencySelection = $("##Currency").val();
			if ( testValue || CurrencySelection == 2  ) {
				if ( !$.IsNumeric(testValue) ) {
					testFailed = true;
				}
				// value must be non-zero and positive :: allows for 5 decimal digits
				else if ( testValue < 0.00001 ) {
					testFailed = true;
				}
			}
			if ( testFailed ) {
				ErrorCount++;
				queueMessage("Please enter a valid currency conversion factor.",  document.all.error_currency_conversion_factor);
			}
			else {
				clearQueue(document.all.error_currency_conversion_factor);
			}
		</cfif>
		</cfoutput>

			<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
			if(ErrorCount == 0)
			{
				//show auto pay components in parent program confirmation if logic was met
				if (document.MyForm.checkParentStartDate.value == 1)
				{
					var startDateEntered = new Date(document.MyForm.start_date.value);
					var parentStartDate = new Date(document.MyForm.parentStartDate.value);

					if(startDateEntered < parentStartDate)
					{
						NewWindow('/common_files/contracts/auto_pay_revise_message.cfm', 'AutoPayRevisionMessage','400','400','No', 'No');
					}
				}
				document.MyForm.action="queries.cfm";
				MyForm.submit();
				if(disableClickedButton)
				{
					disableButton(disableClickedButtonName, true, false);
				}
				// D73994 SAH - After validations are done show progress message.
				show_loader("SAVING PROGRAM, PLEASE WAIT...");
			}
			else {
				showMessageWindow();
			}

		}


	//load the name of the select boxes to hide
	findselectboxes();

	function notifyPerfReqControls(perfRegID)
	{

		var perfReqDivName = "SP_PerfReq_" + perfRegID;
		var bDisable = (event.srcElement.value == 0)? true: false;
		disablePerfReqDiv(perfReqDivName, bDisable);
	}

	function disablePerfReqDiv(divName,bDis)
	{
		/* Get elements by className */
		oDiv =	$( "."+divName);

		if(oDiv)
		{

			oDiv.disabled = bDis;

			/* $(oDiv).find('*') is equivalent to "oDiv.all". ".all" for objects has been removed from IE 11 onwards. */
			$(oDiv).find('*').each(function() {

			$(this).attr('disabled', bDis);

			/* If this is an input box */
			if($(this).is("input"))
			{
				if(bDis){
					/* Note: "input" below needs to be in lower case. */
					$(this).css("background-color","cccccc");
				}
				else{
					$(this).css("background-color","ffffff");
				}
			}

			/* If this is an select box */
			if($(this).is("select"))
			{
				if(bDis){
					$(this).css("background-color","cccccc");
					$(this).prop('selectedIndex', 0);
				}
				else{
					$(this).css("background-color","ffffff");

						if($(this).children('option').length > 0)
						{
							$(this).prop('selectedIndex', 0);
						}
				}
			}
			});

		}
	}
</SCRIPT>

<CF_MessageWindow>
<!--- <cfinclude template="pre_populate_form.cfm"> --->
<!--- </BLOCKQUOTE> --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<script>
	<CFIF FORM.AUTO_RENEW_Setting GTE 1>
		if(document.all.Auto_Renew != null && document.all.Auto_Renew.checked == true){
			/* true or false based on browser - IE 10 and above or IE 9 and below.
			'1' as an argument below means "true". */
			document.all.Auto_Renew.checked = checkOrUncheckBeforeFireEvent(1);
			callfireEvent(document,document.all.Auto_Renew,'Click');
		}
	</CFIF>

	<!--- initalize the radios--->
	<!--- if(document.all.ClaimMechOption)
	{
		if(document.all.ClaimMechOption.length)
		{
			for(var x=0;x<document.all.ClaimMechOption.length;x++){
				document.all.ClaimMechOption[x].fireEvent("onclick");
			}
		}
		else
		{
			document.all.ClaimMechOption.fireEvent("onclick");
		}

	} --->

	/*
	function discountTypeCop()
	{
		<!--- 2 DT options --->
		if(document.all.FRA_GNFP[0] != null){
			if(document.all.FRA_GNFP[0].checked){
				if(document.all.DEV_FOB[0] != null){
					document.all.DEV_FOB[0].disabled = true;
					document.all.DEV_FOB[1].disabled = true;
				}
			}
			else{
				if(document.all.DEV_FOB[0] != null){
					document.all.DEV_FOB[0].disabled = false;
					document.all.DEV_FOB[1].disabled = false;
				}
			}
		}
		else{ //one DT option
			if(window.document.all.DEV_FOB != null){
				document.all.DEV_FOB.checked = true;
			}
		}
	}

	discountTypeCop();
	*/

	var Shipping_FirstName = "";
	var Shipping_LastName = "";
	var Shipping_Company = "";
	var Shipping_Address = "";
	var Shipping_Address2 = "";
	var Shipping_City = "";
	var Shipping_State = "";
	var Shipping_State_Other = "";
	var Shipping_Zip = "";
	var Shipping_Country = "";

	function payDistributor()
	{
		var isChecked = document.all.Pay_To_Distributor;
		if (isChecked.checked)
		{
			document.all.Payable_Company.style.backgroundColor='cccccc';
			document.all.Payable_Company.disabled = true;
			document.all.Payable_Address_1.style.backgroundColor='cccccc';
			document.all.Payable_Address_1.disabled = true;
			document.all.Payable_Address_2.style.backgroundColor='cccccc';
			document.all.Payable_Address_2.disabled = true;
			document.all.Payable_City.style.backgroundColor='cccccc';
			document.all.Payable_City.disabled = true;
			document.all.Payable_State.style.backgroundColor='cccccc';
			document.all.Payable_State.disabled = true;
			document.all.Payable_Zip.style.backgroundColor='cccccc';
			document.all.Payable_Zip.disabled = true;
			document.all.Payable_Attention.style.backgroundColor='cccccc';
			document.all.Payable_Attention.disabled = true;
			document.all.Payable_Comments.style.backgroundColor='cccccc';
			document.all.Payable_Comments.disabled = true;
		}
		else
		{
			document.all.Payable_Company.style.backgroundColor='ffffff';
			document.all.Payable_Company.disabled = false;
			document.all.Payable_Address_1.style.backgroundColor='ffffff';
			document.all.Payable_Address_1.disabled = false;
			document.all.Payable_Address_2.style.backgroundColor='ffffff';
			document.all.Payable_Address_2.disabled = false;
			document.all.Payable_City.style.backgroundColor='ffffff';
			document.all.Payable_City.disabled = false;
			document.all.Payable_State.style.backgroundColor='ffffff';
			document.all.Payable_State.disabled = false;
			document.all.Payable_Zip.style.backgroundColor='ffffff';
			document.all.Payable_Zip.disabled = false;
			document.all.Payable_Attention.style.backgroundColor='ffffff';
			document.all.Payable_Attention.disabled = false;
			document.all.Payable_Comments.style.backgroundColor='ffffff';
			document.all.Payable_Comments.disabled = false;
		}
	}

	function SendToBroker()
	{
		var isChecked = document.all.Send_To_Broker;
		if (isChecked.checked)
		{
			if(document.all.SameAsPayable)
			{
			document.all.SameAsPayable.style.backgroundColor='cccccc';
			document.all.SameAsPayable.disabled = true;
			}
			document.all.Send_Company.style.backgroundColor='cccccc';
			document.all.Send_Company.disabled = true;
			document.all.Send_Attention.style.backgroundColor='cccccc';
			document.all.Send_Attention.disabled = true;
			document.all.Send_Address_1.style.backgroundColor='cccccc';
			document.all.Send_Address_1.disabled = true;
			document.all.Send_Address_2.style.backgroundColor='cccccc';
			document.all.Send_Address_2.disabled = true;
			document.all.Send_City.style.backgroundColor='cccccc';
			document.all.Send_City.disabled = true;
			document.all.Send_State.style.backgroundColor='cccccc';
			document.all.Send_State.disabled = true;
			document.all.Send_Zip.style.backgroundColor='cccccc';
			document.all.Send_Zip.disabled = true;
		}
		else
		{
			if(document.all.SameAsPayable)
			{
			document.all.SameAsPayable.style.backgroundColor='ffffff';
			document.all.SameAsPayable.disabled = false;
			}
			document.all.Send_Company.style.backgroundColor='ffffff';
			document.all.Send_Company.disabled = false;
			document.all.Send_Attention.style.backgroundColor='ffffff';
			document.all.Send_Attention.disabled = false;
			document.all.Send_Address_1.style.backgroundColor='ffffff';
			document.all.Send_Address_1.disabled = false;
			document.all.Send_Address_2.style.backgroundColor='ffffff';
			document.all.Send_Address_2.disabled = false;
			document.all.Send_City.style.backgroundColor='ffffff';
			document.all.Send_City.disabled = false;
			document.all.Send_State.style.backgroundColor='ffffff';
			document.all.Send_State.disabled = false;
			document.all.Send_Zip.style.backgroundColor='ffffff';
			document.all.Send_Zip.disabled = false;
		}
	}

	function InitSaveVariables(form)
	{
		Send_Company = form.Send_Company.value;
		Send_Attention = form.Send_Attention.value;
		Send_Address_1 = form.Send_Address_1.value;
		Send_Address_2 = form.Send_Address_2.value;
		Send_City = form.Send_City.value;
		Send_State = form.Send_State.value;
		Send_Zip = form.Send_Zip.value;
	}

	function PayabletoSameAsSendPaymentTo(form)
	{
		if (form.SameAsPayable.checked)
		{

			 if (document.all.Pay_To_Distributor.checked)
			 {
			 	document.all.Send_Company.style.backgroundColor='cccccc';
				document.all.Send_Company.disabled = true;
				document.all.Send_Address_1.style.backgroundColor='cccccc';
				document.all.Send_Address_1.disabled = true;
				document.all.Send_Address_2.style.backgroundColor='cccccc';
				document.all.Send_Address_2.disabled = true;
				document.all.Send_City.style.backgroundColor='cccccc';
				document.all.Send_City.disabled = true;
				document.all.Send_State.style.backgroundColor='cccccc';
				document.all.Send_State.disabled = true;
				document.all.Send_Zip.style.backgroundColor='cccccc';
				document.all.Send_Zip.disabled = true;
				document.all.Send_Attention.style.backgroundColor='cccccc';
				document.all.Send_Attention.disabled = true;

			 }
			else
			{
				InitSaveVariables(form);
				document.all.Send_Company.style.backgroundColor='ffffff';
				document.all.Send_Company.disabled = false;
				document.all.Send_Address_1.style.backgroundColor='ffffff';
				document.all.Send_Address_1.disabled = false;
				document.all.Send_Address_2.style.backgroundColor='ffffff';
				document.all.Send_Address_2.disabled = false;
				document.all.Send_City.style.backgroundColor='ffffff';
				document.all.Send_City.disabled = false;
				document.all.Send_State.style.backgroundColor='ffffff';
				document.all.Send_State.disabled = false;
				document.all.Send_Zip.style.backgroundColor='ffffff';
				document.all.Send_Zip.disabled = false;
				document.all.Send_Attention.style.backgroundColor='ffffff';
				document.all.Send_Attention.disabled = false;

				form.Send_Company.value = form.Payable_Company.value;
				form.Send_Attention.value = form.Payable_Attention.value;
				form.Send_Address_1.value = form.Payable_Address_1.value;
				form.Send_Address_2.value = form.Payable_Address_2.value;
				form.Send_City.value = form.Payable_City.value;
				form.Send_State.value = form.Payable_State.value;
				form.Send_Zip.value = form.Payable_Zip.value;

			}
		}
		else
		{
			form.Send_Company.value = Send_Company;
			form.Send_Attention.value = Send_Attention;
			form.Send_Address_1.value = Send_Address_1;
			form.Send_Address_2.value = Send_Address_2;
			form.Send_City.value = Send_City;
			form.Send_State.value = Send_State;
			form.Send_Zip.value = Send_Zip;
			document.all.Send_Company.style.backgroundColor='ffffff';
			document.all.Send_Company.disabled = false;
			document.all.Send_Address_1.style.backgroundColor='ffffff';
			document.all.Send_Address_1.disabled = false;
			document.all.Send_Address_2.style.backgroundColor='ffffff';
			document.all.Send_Address_2.disabled = false;
			document.all.Send_City.style.backgroundColor='ffffff';
			document.all.Send_City.disabled = false;
			document.all.Send_State.style.backgroundColor='ffffff';
			document.all.Send_State.disabled = false;
			document.all.Send_Zip.style.backgroundColor='ffffff';
			document.all.Send_Zip.disabled = false;
			document.all.Send_Attention.style.backgroundColor='ffffff';
			document.all.Send_Attention.disabled = false;

		}
	}
<!--- Dev Note: Clay 10613 --->
	function SearchSequenceCopy()
	{
		var warnmsg = 'Revising the Search Sequence will remove all products, rates, distributors and volume estimates. Select OK to proceed or CANCEL to keep the current selection.'
		if(confirm(warnmsg))
			{
				document.all.RenewForm.NewSearchSequence.value = document.MyForm.Search_Sequence_ID.options[document.MyForm.Search_Sequence_ID.selectedIndex].value;
				<cfif appSettings.getView_Legacy_ID() EQ 1>
					document.all.RenewForm.legacy_id.value = document.MyForm.legacy_id.value;
				</cfif>
				<cfif appSettings.getOperatingGroupOn()>
					document.all.RenewForm.New_Business_Segment.value = document.MyForm.Operating_Group_1.options[document.MyForm.Operating_Group_1.selectedIndex].value;
					document.all.RenewForm.New_Spending_Category.value = document.MyForm.Operating_Group_2.options[document.MyForm.Operating_Group_2.selectedIndex].value;
				</cfif>
				document.all.RenewForm.Contract_Reference_Number.value = document.MyForm.Contract_Reference_Number.value;
				document.all.RenewForm.Contract_Reference_Number_2.value = document.MyForm.Contract_Reference_Number_2.value;
				document.all.RenewForm.start_date.value = document.MyForm.start_date.value;
				document.all.RenewForm.end_date.value = document.MyForm.end_date.value;
				document.all.RenewForm.submit();
			}
			else
			{
				document.MyForm.reset();
				return false;
			}
	}

//  End -->
</script>

<!---
Dev Note: Clay 10613
Copied from Contract Edit Menu
Form with the data needed to copy the contract
--->

<FORM ACTION="contract_renewal_action.cfm" METHOD="post" NAME="RenewForm" ID="RenewForm">
	<INPUT TYPE="hidden" NAME="Program_ID" VALUE="<CFOUTPUT>#EncrypCID#</CFOUTPUT>" >
	<INPUT TYPE="hidden" NAME="IsRevisionOfExistingContract" VALUE="0" >
	<INPUT TYPE="hidden" NAME="IsRollOver" VALUE="0" >
	<INPUT TYPE="hidden" NAME="NewSearchSequence" VALUE="0" >
	<INPUT TYPE="hidden" NAME="suppressProductsDistributors" VALUE="1">
	<INPUT TYPE="hidden" NAME="New_Business_Segment" VALUE="0">
	<INPUT TYPE="hidden" NAME="New_Spending_Category" VALUE="0">
	<INPUT TYPE="hidden" NAME="Contract_Reference_Number" VALUE="">
	<INPUT TYPE="hidden" NAME="Contract_Reference_Number_2" VALUE="">
	<cfif appSettings.getView_Legacy_ID() EQ 1>
		<INPUT TYPE="hidden" NAME="legacy_id" value="">
	</cfif>
	<INPUT TYPE="hidden" NAME="start_date" value="">
	<INPUT TYPE="hidden" NAME="end_date" value="">
</FORM>

<cf_include files="/script/javascript/jquery.numeric.js, /script/javascript/jquery.cfjs.min.js">

<cfif application.util.query.get_setting("custom_rfp_process", 0) eq 1>
    <!--- RFP custom setting - auto populate program end date is configured for this program template --->
    <cfif getfieldsettings.Allow_Auto_Populate_Program_End_Date and val(getfieldsettings.Auto_Populate_Program_End_Date)>
        <cf_include files="/script/javascript/moment.min.js">
        <script>
            /* override the same function defined in Easy_Date custom tag */
            function start_dateValidateDate(strDate) {
                if(strDate.length == 0) //strDate='x'
                    return;
                arryDate = start_dateSplitDate(strDate);	// Split the date up into a month day year array

                //TSF: 10379 - handle if they enter the year in yy format
                var aDate = new Date();
                aDate.setYear(arryDate[2]);
                if(aDate.getFullYear() < 1970)
                {
                    arryDate[2] = arryDate[2] + 2000;
                }
                //End TSF: 10379

                if (strDate.length && (isNaN(parseInt(arryDate[2])) || arryDate[2] > 9999 || arryDate[2] < 1000 || isNaN(parseInt(arryDate[0])) || arryDate[0] > 12 || arryDate[0] < 1 || isNaN(parseInt(arryDate[1])) || arryDate[1] < 1 || arryDate[1] > start_datedaysInMonth(arryDate[0] - 1,arryDate[2]))) {
                    let today = new Date();
                    arryDate[0] = today.getMonth();
                    arryDate[1] = today.getDate();
                    arryDate[2] = today.getFullYear();
                }
                document.MyForm.start_date.value = start_dateJoinDate(arryDate);

                let end_date = $("input[name=end_date]");
                /* populate default program end date */
                if (end_date && end_date.val() == '') {
                    let end_date_default = moment(document.MyForm.start_date.value)
                                            .add(<cfoutput>#getfieldsettings.Auto_Populate_Program_End_Date#</cfoutput>, "months")
                                            .add(-1, "days")
                                            .format("MM/DD/YYYY");
                    end_date.val( end_date_default );
                }
            }
        </script>
    </cfif>
</cfif>

<script>
    $(".numeric102").numeric( { negative: false } );
</script>
<cfinclude template="/common_files/focus.cfm">
</BODY>
</HTML>
