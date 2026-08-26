<cfsilent>
<!---
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   Template: \Common_files\contracts\GPO_One_Page_Programm.cfm
   Author: Mark Saunderss
   Date: 3/4/2019
 
   Usage: Main Entry for One Page Program Creation.  Custom feature.
       
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
--->
</cfsilent>
<cfset userManager = CreateObject("component", "components.user.UserManager") />

<!---Gets application settings--->

<cfset appSettings = application.appsettingsGet />

<cfset programManager = CreateObject("component", "components.programs.ProgramManager").init()>
<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />
<cfset OPPManager = CreateObject("component", "mvc.Models.Program.OnePageProgramManager").init() />

<cfset variables.labelComp 	= CreateObject("component", "components.settings.labels.labels").init() />

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<CFIF Get_Profile_Settings.Cont_Prog_View_Create_Program EQ 0 OR (appSettings.getUserNumberRestrict() EQ 1 AND userManager.getUserNumberExists(request.AccessStructure.User_ID) EQ 0)>
	<CFLOCATION URL="#application.HomePage#" ADDTOKEN="No">
</CFIF>

<!--- <cfinclude template="/actionFormat.cfm">
<cfinclude template="/common_files/general_labels.cfm"> --->

<!------ get user positions id ----->
<cfset This_User_Positions_ID = userManager.getPositionId(request.AccessStructure.User_ID, 1) />
<!---import the custom tag lib--->
<!--- <cfimport prefix="layout" taglib="/CustomTags"> --->
<cfparam name="form.Do_Revise_Copy" default="0">
<cfparam name="form.IsExclusionRevision" default="0">
<!---default params for business segments--->
<!---  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx    TEMP FOR DEV   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
<!---  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx    TEMP FOR DEV   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
<CFPARAM name="FORM.Business_Segment_ID" default="0"> 
<cfset FORM.Business_Segment_ID = 15 />      
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
				<cfif businessSegManager.isEnabled()>
					<cfset form.businessSegmentsOn = 1 />
				</cfif>
<!---  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx    TEMP FOR DEV   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
<!---  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx    TEMP FOR DEV   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
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


<CFSET PAGE_TITLE="One Page Program">
<CFSET GROUP="Contracts">

<CFPARAM name="URL.CID" default="">
<CFPARAM NAME="EncrypCID" DEFAULT="">
<cfparam name="Form.Performance_Start_Date" default="" />
<cfparam name="Form.Performance_End_Date" default="" />
<cfparam name="variables.operatorCategoryLabel" default="Operator Category" />
<cfparam name="variables.operatorPriorityLabel" default="Operator Priority" />
<cfparam name="Form.TemplateFiltersId" default="0" />
<cfparam name="Form.currency_conversion_factor" default="" />
<cfparam name="Form.Program_Most_Favored_Nation" default="0" />
<cfparam name="form.Best_Plan_Program" default="0"><!---60308--->
<cfparam name="Form.Is_Blanket_Bid" default="0">
<cfparam name="variables.ContractMainID" default="0">
<CFSET Program_ID_To_Replicate = 0 />

<cfset revisionOfProgramWithOtherRevisions = 0 />

<CFIF form.Do_Revise_Copy EQ 0>  <!--- NOT A COPY/REVISE ********************************************************************************************************************************************
														 ********************************************************************************************************************************************
														 ********************************************************************************************************************************************   --->

		<CFIF len(trim(URL.CID)) GT 0>  <!--- EXISTING PROGRAM --->

				<CF_CRYP type="de" string="#trim(URL.CID)#" key="#request.key#">
				<cfset variables.ContractMainID = cryp.value />
				<cfquery name="GetContractInfo" datasource="#application.datasource#">
				            SELECT	*,Contract_Main_Aux_Data.*
				            FROM	Contract_Main
				            INNER JOIN Contract_Main_Aux_Data
				            ON Contract_Main.Contract_Main_ID = Contract_Main_Aux_Data.Contract_Main_ID
				            WHERE 	Contract_Main.Contract_Main_ID = '#variables.ContractMainID#'
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
				<CFPARAM name="FORM.Incremental_Sales" 				default="#GetContractInfo.Fixed_Rebate_Amount#">
				<CFPARAM name="FORM.Override_Price_List_Id" 		default="#GetContractInfo.Override_Price_List_Id#">
				<CFPARAM name="FORM.Gpo_Price_List_Id"				default="#GetContractInfo.Gpo_Price_List_Id#">
				<CFPARAM name="FORM.NonGpo_Price_List_Id" 			default="#GetContractInfo.NonGpo_Price_List_Id#">
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
				<CFPARAM name="FORM.ProgramType" 					default="">
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
		<CFELSE>  <!--- NEW PROGRAM --->

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

				<cfset useLakebaseForgetDiscNumber = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options") AND application.oLakebase.isTableMigrated("discount_identifier")>
<cfif useLakebaseForgetDiscNumber>
	<cftry>
		<cfset getDiscNumber = application.oLakebase.toQuery(
			application.oLakebase.selectRowsJoin("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#Form.ProgramType_Id#",
				"select" = "discount_identifier_id"
			}, "discount_identifier_id", "discount_identifier", "discount_identifier_id", "discount_identifier_desc,discount_identifier_number"), "discount_identifier_desc,discount_identifier_number"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetDiscNumber = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetDiscNumber>
<cfquery NAME="getDiscNumber" datasource="#application.datasource#">
					SELECT Disc.Discount_Identifier_Number,
							Disc.Discount_Identifier_Desc
					FROM Program_Control_Panel_Options PCPO
					INNER JOIN Discount_Identifier Disc ON 
							Disc.Discount_Identifier_ID = PCPO.Discount_Identifier_ID
					where PCPO.ProgramControl_Panel_Options_ID = '#Form.ProgramType_Id#'
				</cfquery>
</cfif>

				<cfinclude template="/Common_Files/contracts/contract_number_generator.cfm">

				<CFIF Form.New_Business_Segment NEQ 0>
					<CFPARAM name="FORM.Operating_Group_Level_1_ID" 	default="#Form.New_Business_Segment#">
				</CFIF>
				<CFIF FORM.NEW_Spending_Category NEQ 0>
					<CFPARAM name="FORM.Operating_Group_Level_2_ID" 	default="#FORM.NEW_Spending_Category#">
				</CFIF>
				<CFPARAM name="FORM.Incremental_Sales" 	default="">
				<CFPARAM name="FORM.Override_Price_List_Id" default="">
				<CFPARAM name="FORM.Gpo_Price_List_Id" default="">
				<CFPARAM name="FORM.NonGpo_Price_List_Id" default="">
				<CFPARAM name =	"Form.New_Business_Segment" default="">
				<CFPARAM name="FORM.Business_Segment_ID" default="15">       <!---  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx    TEMP FOR DEV   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
				<CFPARAM name ="FORM.Contract_Reference_Number" 		default="">
				<CFPARAM name="FORM.Contract_Reference_Number_2" 		default=""><!--- 77539 --->
				<CFPARAM name ="FORM.LEGACY_ID" 						default="">
				<CFPARAM name ="FORM.BID_Id" 						default="">
				<CFPARAM name ="FORM.Contract_Title" 				default="#getDiscNumber.Discount_Identifier_Number#">
				<CFPARAM name="FORM.Operator_List" 				default=""><!--- D38189::Alternate Payment Recipient --->
				<CFPARAM name="FORM.start_date" 					default="#now()#">
				<CFPARAM name="FORM.end_date" 						default="#DateAdd('d', 30,now())#">
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


<CFELSE>  <!---  IS COPY/REVISE ********************************************************************************************************************************************
								********************************************************************************************************************************************
								********************************************************************************************************************************************   --->
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
		<cfinclude template="/Common_Files/contracts/load_basic_information_struct.cfm" />

		<CFIF FORM.ISREVISIONOFEXISTINGCONTRACT EQ 1>
			<!---- Revision ---->
			<CFPARAM name="FORM.Affect_Broker_Commission" 		default="#Program_Packet.Basic_Information.Affect_Broker_Commission#">
			<CFPARAM name="FORM.Affect_Broker_Commission_Type" 	default="#Program_Packet.Basic_Information.Affect_Broker_Commission_Type#">
			<CFPARAM name="FORM.Affect_Shelter" 				default="#Program_Packet.Basic_Information.Affect_Shelter#">
			<CFPARAM name="FORM.Affect_Shelter_Type" 			default="#Program_Packet.Basic_Information.Affect_Shelter_Type#">
			<CFPARAM name="FORM.fiscal_year" 						default="#Program_Packet.Basic_Information.fiscal_year#">

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

			<cfinclude template="/Common_Files/contracts/contract_number_generator.cfm">

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
</CFIF>   <!--- END IS COPY/REVISE  ********************************************************************************************************************************************
									********************************************************************************************************************************************
									********************************************************************************************************************************************   --->

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
<cfset useLakebaseForgetFieldSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForgetFieldSettings>
	<cftry>
		<cfset getFieldSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#FORM.ProgramType_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetFieldSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetFieldSettings>
<cfquery name="getFieldSettings" datasource="#application.datasource#">
	SELECT *
	FROM Program_Control_Panel_Options
	WHERE ProgramControl_Panel_Options_ID = '#FORM.ProgramType_ID#'
</cfquery>
</cfif>

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
		<cfset uomIdListForGetUOMs = "0">
		<cfif FORM.RateTypeOption_1_Setting EQ 1><cfset uomIdListForGetUOMs = uomIdListForGetUOMs & ",2"></cfif>
		<cfif FORM.RateTypeOption_2_Setting EQ 1><cfset uomIdListForGetUOMs = uomIdListForGetUOMs & ",1"></cfif>
		<cfset GetUOMs = application.oLakebase.toQuery(
			application.oLakebase.selectRows("units_of_measure", { "unit_of_measure_id" = "in.(#uomIdListForGetUOMs#)" })
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
<cfset useLakebaseForqryUsersSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users_settings")>
<cfif useLakebaseForqryUsersSettings>
	<cftry>
		<cfset qryUsersSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users_settings", {
				"select" = "max_program_title_length,pullback_modify_corporate_program_rates"
			}), "max_program_title_length,pullback_modify_corporate_program_rates"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryUsersSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryUsersSettings>
<CFQUERY NAME="qryUsersSettings" datasource="#application.datasource#">
SELECT 	Max_Program_Title_Length, Pullback_Modify_Corporate_Program_Rates
FROM	_Users_Settings
</CFQUERY>
</cfif>

<CFPARAM NAME="Form.Document_ID" DEFAULT="ContractGeneralInfo">

<cfset labelnotes = appSettings.getLabelNotes()>

<!doctype html>
<html lang="en">
<head>
	<title>Program Editor</title>
	<cfsavecontent variable="head_content">
	<style>
		html, body {
			margin: 0;
            padding: 0;
            width: 99.5%;
            /* height: 95%; */
        }

        legend {
            font-size: 11px;
            font-weight: 600;
        }

        /* Section headers have blue dot, name, then horizontal line */
        .sectionHeader {
            overflow: hidden;
            font-weight: normal;
            margin-bottom: 5px;
        }
        .sectionHeader:before {
            /* blue dot */
            content: "";
            display: block;
            background: #222A97;
            width: 9px;
            height: 9px;
            border-radius: 50%;
            float: left;
            margin: 1px 6px 0 0;
        }
        .sectionHeader:after {
            /* h line */
            display: inline-block;
            position: relative;
            vertical-align: middle;
            margin-left: 6px;
            height: 1px;
            content: "";
            text-shadow: none;
            background-color: #d8d9dd;
            margin-right: -100%;
            width: 100%; 
        }
        .sectionContents {
            margin-left: 10px;
        }

        .fieldGroup {
			background-color: #edeef2;
			border: 1px solid #c4c5c7;
			border-radius: 8px;
			margin-top: 3px;
		}
	.formGrayOut{
          background: #ccc;
       }
 
	</style>
    </cfsavecontent>
	<cfhtmlhead text="#application.util.string.compress( head_content )#">
</HEAD>

<body>
    <cfset verb="CREATE"/>      <!--- could be CREATE, EDIT, or VIEW --->
    <cfset request.noty_version = "3">
	<cf_include files="/common_files/tailwind-css.cfm, /common_files/noty.cfm">
	<cfset jQuery.version ="1.12.4">
	<cfset jQueryUI.widgets = "tooltip,datepicker">
	<cfset jQueryUI.widgets = "all">
	<cfset jQueryUI.version = "1.11">
    <cfset request.ag_grid_theme = "ba-ag-theme-balham">
	<cfset request.ag_grid_version = "21">

    <cf_include files=#arrayToList( [ "/common_files/jQuery.cfm",
                                       "/common_Files/ag-Grid.cfm",
                                       "/styles/css-loader.css",
                                       "/styles/font-awesome.min.css" 
                                        ] )#>
                                        <!--- "/common_files/contracts/GPO_One_Page/opp_grids.cfm" --->
    <script src="/script/javascript/jQueryUI_1_11/datepicker.js"></script>
	<cf_include files="/script/javascript/jQueryUI_1_11/jquery-ui.css">
	<cf_include files="/script/javascript/chosen/chosen.jquery.min.js, /styles/chosen/chosen.css">
 <style>
        <!--- override the ag-grid styles included above --->
		.ag-theme-balham {
			font-size: 11px;
		}
		.ag-header {
			font-size: 11px !important;
		}
		.ag-theme-balham .ag-cell {
			/* padding-left: 4px; */
			padding-right: 2px;
        }
        .ag-theme-balham .ag-header-cell-label {
			width: 100%;	/* work around ag-grid bug #2328 which leaves space for menu icon */
		}
        .ag-theme-balham .ag-header-cell {
            padding-left: 6px;  /* get checkbox to line up */
        }
  		.ag-theme-balham .ag-row-selected {
    		border-bottom-color: #b5b5b5; /* don't hide lines when selected */
		}
		.ag-theme-balham .ag-selection-checkbox span {
		    left: 2px; /* center the checkbox */
    	}
    	.number-cell {
	        text-align: right;
	    }
    </style>

<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "gi">
<!--------------------->
    <!------- HEADER ------>
    <!--------------------->
    <!--- <div class="page_title1"> <cfoutput>#verb#</cfoutput> PROGRAM </div> --->

    <div class="min-h-screen md:flex" style="padding-bottom: 10px;">
        
        <!--------------------->
        <!---- NAV SECTION ---->
        <!--------------------->
        <div id="navArea" class="flex-none w-full bg-grey-lightest  text-base text-black text-left" style="width:140px;padding-top: 6px;">
          <CFINCLUDE TEMPLATE="/Common_Files/contracts/contract_status_legend.cfm" />
          	<!--- <cf_layout_planner_program jQueryUI="1.11.4" page_title="Planner Program">
			<cf_include files="/Script/javascript/gridviewScroll.min.js"> --->
        </div>
     	<!--- =====================================================   UI AND Business LOGOC MIXED :(  =============================================== --->
		     	<!---if Program_Date_Type is defined in the GetSettings query then set it--->
				<cfif isDefined("GetSettings.Program_Date_Type")>
					<cfset form.Program_Date_Type = GetSettings.Program_Date_Type />
				</cfif>
		     	<cfparam name="form.Program_ID" default="">
				<cfset RevisionSettingsManager = CreateObject("component", "components.programs.Display_Program.revision_settings") />
				<cfif form.Program_ID neq "">
					<CF_CRYP type="de" string="#form.Program_ID#" key="#request.key#" return="ProgramID">
					<cfset RevisionSettingsInfo = RevisionSettingsManager.getRevisionInfo(ProgramID.value)>
				<cfelseif URL.CID neq "">
					<cfset ParentProgramInfo = programManager.getParentProgramInfo(URL.CID)>
					<cfset RevisionSettingsInfo = RevisionSettingsManager.getRevisionInfo(ParentProgramInfo.Revision_of_Contract_Main_ID)>
				</cfif>

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
		<!--- =====================================================   UI AND Business LOGOC MIXED :(  =============================================== --->
        <!--------------------->
        <!--- MAIN CONTENTS --->
        <!--------------------->
        <cfquery name="qGetPayTypes" datasource="#application.datasource#">
			SELECT DISTINCT PT.Payment_Type_Name, PT.Payment_Type_ID, PT.Is_Auto_pay,PT.Restrict_From_Billback,
				ISNULL(NULLIF(CM.ClaimMechanics,0),pcpo.ClaimMechDefaultOption) AS ClaimMechanics FROM Contract_Main CM
				INNER JOIN Payment_Template_Mapping PTM ON
					PTM.Template_ID = CM.ProgramType_ID
				INNER JOIN Payment_Type PT
					ON PT.Payment_Type_ID = PTM.Payment_Type_ID
				INNER JOIN Program_Control_Panel_Options pcpo on PCPO.ProgramControl_Panel_Options_Id = PTM.Template_Id
				WHERE CM.Contract_Main_ID = #variables.ContractMainID# 
		</CFQUERY>
		<cfquery name="qGetContract" datasource="#application.datasource#">
			SELECT ISNULL(CM.Formula_Price_Rebate_Type,0) AS Formula_Price_Rebate_Type
				FROM Contract_Main CM
				WHERE CM.Contract_Main_ID = #variables.ContractMainID# 
		</CFQUERY>
		
        <cfscript>
			isGPO = '1';
			isAdminFee = qGetContract.Formula_Price_Rebate_Type;
			if(GetDiscountIdentifier.Discount_Identifier_Number == 'CPA'){
				isGPO = '0';
			}
			oOPP		= CreateObject("component", "mvc.Models.Program.OnePageProgramManager");

		</cfscript>
        <div class="flex-1 bg-white mx-1 text-sm text-black">
            <section name="section_BasicInfo" class="mr-1" style="padding-top: 6px;">
            	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				 <CFINCLUDE template="/Common_Files/contracts/OPP/GPO_Basic_Info_Form.cfm" />
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
            </section>
            <br>

            <section name="section_Distributors" class="mr-1">
            	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				 <CFINCLUDE template="/Common_Files/contracts/OPP/GPO_Distributors_Form.cfm" />
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
            </section>
            <br>

            <section name="section_Operators" class="mr-1">
            	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				 <CFINCLUDE template="/Common_Files/contracts/OPP/GPO_Operators_Form.cfm" />
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
            </section>
            <br><br>
            <cfif isGPO EQ 0>
	            <section name="section_CPA_Components" class="mr-1">
	            	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
					 <CFINCLUDE template="/Common_Files/contracts/OPP/CPA_PriceList_Form.cfm" />
					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	            </section>
	            <br><br>
        	</cfif>

            <cfif isGPO EQ 1 and isAdminFee EQ 0>
	            <section name="section_Tiers" class="mr-1">
	            	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
					 <CFINCLUDE template="/Common_Files/contracts/OPP/GPO_Tiers_Form.cfm" />
					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	            </section>
	            <br><br>
        	</cfif>

        	<cfif isGPO EQ 0>
	            <section name="section_CPA_Components" class="mr-1">
	            	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
					 <CFINCLUDE template="/Common_Files/contracts/OPP/CPA_Components_Form.cfm" />
					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	            </section>
	            <br><br>
        	</cfif>
 			
 			<cfif isGPO EQ 1>
	            <section name="section_Products" class="mr-1">
	            	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
					 <CFINCLUDE template="/Common_Files/contracts/OPP/GPO_Products_Form.cfm" />
					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	            </section>
	        </cfif>

	        <cfif isGPO EQ 0>
	            <section name="section_CPA_Products" class="mr-1">
	            	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
					 <CFINCLUDE template="/Common_Files/contracts/OPP/CPA_Products_Form.cfm" />
					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	            </section>
	        </cfif>
        </div>
      </div>


    <!-------------------------------------------------------------------------------------->
    <!--------------------------------- SCRIPTS -------------------------------------------->
    <!-------------------------------------------------------------------------------------->
    <script>
    	// Currency formatter to use in cells
	const usdFormat = new Intl.NumberFormat('en-US', {
												style: 'currency',
												currency: 'USD',
												minimumFractionDigits: 2
											});
	// Grid Utilities, can be used by each section
	//
	// Use this to let ag-grid set the grid height dynamically
	// Don't use this if expecting lots of rows (>1000)
	function setAutoHeight(gridOptions, gridID) {
		gridOptions.api.setDomLayout('autoHeight');
		// auto height will get the grid to fill the height of the contents,
		// so the grid div should have no height set, the height is dynamic.
		document.querySelector(gridID).style.height = '';
	}

	// Use this when you want a specific grid height, or when there is no data, use with height ~ '70px' to center the "No Rows" text
	function setFixedHeight(gridOptions, gridID, height) {
		height = height || '100px';
		gridOptions.api.setDomLayout('normal');
		// when auto height is off, the grid has a fixed height, and then the grid
		// will provide scrollbars if the data does not fit into it.
		document.querySelector(gridID).style.height = height;
	}

	function setGridHeight(gridOptions, gridID, rows) {
		if (rows > 0) {
			setAutoHeight(gridOptions, gridID);
		} else {
			setFixedHeight(gridOptions, gridID, "70px");
		}
	}


	// Init Noty msgs
	Noty.overrideDefaults({
		closeWith: ["click", "button"],
		layout: "center",
		killer: true,
		theme: "metroui",
		timeout: false,
		type: "error"
	});

    </script>

	<cfinclude template="/Common_Files/focus.cfm">
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
</body>
<html>







