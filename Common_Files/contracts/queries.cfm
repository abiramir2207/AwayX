<!--- <cfdump var="#form#" output="c:\dump.log"/> --->
<cfset scale.currency_conversion_factor = 5>                 <!---34302: this represents no. of decimal digits for currency conversion factor, it should match with db schema --->
<cfparam name="form.currency_conversion_factor" default="">  <!---34302--->
<CFPARAM name="FORM.ShowCid" default="0">
<CFPARAM name="Form.Scheduled" default="0">
<CFPARAM name="Form.Currency" default="1">
<CFPARAM name="FORM.Document_ID" default="">
<CFPARAM name="FORM.ClaimMechanics" default="0">
<CFPARAM name="FORM.BldUpInvoice" default="0">
<CFPARAM name="FORM.Comments" default="">
<CFPARAM name="FORM.Competitive_Info_Notes" default="">
<CFPARAM name="FORM.Like_Product_Exist" default=0>
<CFPARAM name="FORM.Is_Awarded" default=0>
<CFPARAM name="Form.Contract_Title" 	default="">
<CFPARAM name="displayinactiveprodustspopup" default=0>
<cfparam name="FORM.Dev_Fob" default="0">
<!--- <cfparam name="FORM.selectedBudget" default="">--->
<cfparam name="form.EZTemplate" default="0">
<cfparam name="Form.suppressProductsDistributors" default="0">
<CFPARAM name="form.Program_Date_Type" default="1">
<CFPARAM name="FORM.Contract_Quantity_UOM_IDX" default="1" />
<!---default a business segment id--->
<cfparam name="FORM.Business_Segment_ID" default="0">
<cfparam name="FORM.LOB_ID" default="NULL">
<cfparam name="form.businessSegmentsOn" default="0">

<cfparam name="FORM.Contract_Reference_Number" default="">
<cfparam name="FORM.Contract_Reference_Number_2" default=""><!---77539--->
<CFPARAM name="FORM.FIXED_REBATE_AMOUNT" default="0">
<CFPARAM name="FORM.Adv_Spend_Amount" default="">

<CFPARAM name="FORM.bid_request_status" default="">
<CFPARAM name="FORM.Planner_Perf_Types_ID" default="0" /> 
<CFSET FORM.Adv_Spend_Amount = replace(FORM.Adv_Spend_Amount, ",", "", 'ALL')>
<cfif NOT IsNumeric(FORM.Adv_Spend_Amount)><cfset FORM.Adv_Spend_Amount = 0 /></cfif>

<!--- Communication Settings --->
<CFPARAM name="FORM.CommRecip_1" 					default="0">
<CFPARAM name="FORM.CommRecip_2" 					default="0">
<CFPARAM name="FORM.CommRecip_3" 					default="0">
<CFPARAM name="FORM.CommRecip_4" 					default="0">

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
<cfparam name="form.Operator_List" default="null"><!--- D38189::Alternate Payment Recipient --->
<!---Send Payment To--->
<CFPARAM name="FORM.Send_To_Broker"					default="">
<CFPARAM name="FORM.Send_Company"					default="">
<CFPARAM name="FORM.Send_Attention"					default="">
<CFPARAM name="FORM.Send_Address_1"					default="">
<CFPARAM name="FORM.Send_Address_2"					default="">
<CFPARAM name="FORM.Send_City"						default="">
<CFPARAM name="FORM.Send_State"						default="">
<CFPARAM name="FORM.Send_Zip"						default="">

<CFPARAM name="FORM.Equipment_Placement"			default="0">
<CFPARAM name="FORM.Equipment_Placement_Note"		default="">
<CFPARAM name="FORM.Pullback_From_This_Program"			default="0">
<!---Performance Requirements--->
<CFPARAM NAME="PerfRequirements"					default="">
<CFPARAM NAME="NoPerfRequirements"					default="">

<!--- Auto Renew Settings --->
<CFPARAM name="FORM.Auto_Renew" 						default="0">
<CFPARAM name="FORM.Auto_Renewal_Fixed_Variable_Margin" default="0">
<!--- Claim Mechanics --->
<CFPARAM name="FORM.ClaimMechOption" 				default="0">
<CFPARAM name="FORM.ClaimMechOptionsBUI" 			default="0">
<!--- Controllable Volume --->
<CFPARAM name="FORM.Controllable_Flag" 				default="0">
<!--- Growth Inclusion --->
<CFPARAM name="FORM.Growth_Inclusion_Flag" 			default="0">

<CFPARAM NAME="FORM.GL_Assignment_ID" DEFAULT="0">

<CFPARAM NAME="FORM.CONTRACT_RENEWAL_PACKETS_ID" DEFAULT="0">
<CFPARAM NAME="FORM.Do_Revise_Copy" DEFAULT="0">
<CFPARAM NAME="FORM.Program_ID_To_Replicate" DEFAULT="0">

<!---Auto renew information--->
<cfparam name="Form.Start_Date" 				default="">
<cfparam name="Form.End_Date" 				default="">
<cfparam name="Form.Fiscal_Year" 				default="">
<cfparam name="Form.Auto_Renew"			default="0">
<cfparam name="Form.AR_RENEWAL_TYPE"		default="0">
<cfparam name="Form.Renewal_Lead_Time"		default="0">
<CFPARAM name="Form.Is_AutoRenew" 			default="0">
<CFPARAM name="Form.IsAutoRevision" 			default="0">
<CFPARAM name="Form.Date_Method" 			default="0">
<CFPARAM NAME="Form.ForceFreightOnAutoCopy" 	default="0">  <!--- Dev Note: KAL; 16694 --->

<CFPARAM name="Form.Accounting_Program_Type_ID" default="">
<CFPARAM name="Form.Program_Category_ID" default="0">
<CFPARAM name="Form.Search_Sequence_ID" default="0">
<CFPARAM name="Form.Affect_Broker_Commission" default="0">
<CFPARAM name="Form.Affect_Broker_Commission_Type" default="0">
<CFPARAM name="Form.Affect_Shelter" default="0">
<CFPARAM name="Form.Affect_Shelter_Type" default="0">
<CFIF Form.Affect_Broker_Commission NEQ 1>
	<CFSET Form.Affect_Broker_Commission_Type = 0 />
</CFIF>
<CFPARAM name="Form.Open_Date" default="">
<CFPARAM name="Form.Open_Time" default="">
<CFPARAM name="Form.Expected_Reply_Date" default="">
<CFPARAM name="Form.Date_Needed" default="">
<CFPARAM name="form.Program_Bid_Request_ID" default="0">
<CFIF Form.Affect_Shelter NEQ 1>
	<CFSET Form.Affect_Shelter_Type = 0 />
</CFIF>
<CFPARAM name="Form.Pullback_From_This_Program" default="0">
<CFPARAM name="Form.applied_pullbacks" default="0">
<cfparam name="FORM.Legacy_ID" default="">
<cfparam name="Form.Performance_Start_Date" default="" />
<cfparam name="Form.Performance_End_Date" default="" />
<cfparam name="Form.TemplateFiltersId" default="0" />
<cfparam name="form.CompetitorSourceID" default="0" />
<cfparam name="form.CompetitorSourceType" default="0" />
<cfparam name="form.CompetitorSourceOther" default="" />
<cfparam name="form.CompetitorSourceOtherID" default="" />
<cfparam name="form.Effective_Date_for_Price" default="" />
<!--- -- D38942 :: Program Blackout Period on Frontend START --->
<cfparam name="form.Program_Start_Zero" default="0" />
<cfparam name="form.Program_Future_zero" default="0" />
<!--- -- D38942 :: Program Blackout Period on Frontend START --->
<cfparam name="form.Program_Most_Favored_Nation" default="0">  <!---42349--->
<cfparam name="FORM.contract_period_start_date" default="">
<cfparam name="FORM.contract_period_end_date" default="">
<cfparam name="FORM.Best_Plan_Program" default="0"><!---60308--->
<cfparam name="FORM.Is_Blanket_Bid" default="0">
<cfparam name="FORM.Limited_Revise" default="0"><!--- 68969--->
<cfparam name="FORM.check_program_uom" default="1">

<cfset objProgram = CreateObject("component", "components.programs.Program") />
<cfset objProgramFreight = CreateObject("component", "components.freight.ProgramFreight") />
<CFSET productGroupDataManager = CreateObject("component", "components.products.group.DataManager")>

<cfif NOT isDefined("Form.Responsible_User_Id_Position_Id") OR Form.Responsible_User_Id_Position_Id IS "NULL" OR ListLast(FORM.Responsible_User_Id_Position_Id, "_") IS "NULL">
	<cfset This_User_Positions_ID = CreateObject("component", "components.user.UserManager").getPositionId(request.AccessStructure.User_ID)>
	<cfset Form.Responsible_User_Id_Position_Id = "#This_User_Positions_ID#_#request.AccessStructure.User_ID#">
</cfif>
<CFSET This_User_Position_ID = ListFirst(FORM.Responsible_User_Id_Position_Id, "_")>
<cfset FORM.Responsible_User_Id = ListLast(FORM.Responsible_User_Id_Position_Id, "_")>

<cfset editBidId = isDefined("form.bid_id")>

<cfset ProductGroupManager = CreateObject("component", "components.programs.products.ProductGroupManager").init() />
<cfset clauseProgramManager = CreateObject("component", "components.clause_library.ClauseProgramManager").init() />
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

 <!--- Dev Note: Milan 9360 --->
<CFIF appSettings.getModify_Legacy_ID() EQ 1>
	<CFSET LegacyDealID = Legacy_ID />
</CFIF>

<!--- Milan ; 17037. We require this for cf_sql_date. If the type is not date, then store the data as NULL --->
<cfif IsDate(Form.Performance_Start_Date) EQ 0 OR IsDate(Form.Performance_End_Date) EQ 0>
	<cfset Is_Performance_Date_Null = 'yes'>
<cfelse>
	<cfset Is_Performance_Date_Null = 'no'>
</cfif>

<cfif IsDate(Form.Effective_Date_for_Price) EQ 0>
	<cfset Effective_Date_for_Price_Null = 'yes'>
<cfelse>
	<cfset Effective_Date_for_Price_Null = 'no'>
</cfif>

<cfif IsDate(FORM.contract_period_start_date) EQ 0>
	<cfset Contract_period_start_date_Null = 'yes'>
<cfelse>
	<cfset Contract_period_start_date_Null = 'no'>
</cfif>

<cfif IsDate(FORM.contract_period_end_date) EQ 0>
	<cfset Contract_period_end_date_Null = 'yes'>
<cfelse>
	<cfset Contract_period_end_date_Null = 'no'>
</cfif>

<!---Get Program Span--->
<cfset useLakebaseForgetTemplateSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForgetTemplateSettings>
	<cftry>
		<cfset getTemplateSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#FORM.ProgramType_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetTemplateSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetTemplateSettings>
<cfquery name="getTemplateSettings" datasource="#application.datasource#">
	SELECT *
	FROM Program_Control_Panel_Options
	WHERE ProgramControl_Panel_Options_ID = '#FORM.ProgramType_ID#'
</cfquery>
</cfif>
<cfset templateFirstParentId = getTemplateSettings.First_Parent_ID />
<!--- D50711 Program Date Changes START --->
<cfset variables.check_Orphan = 0>
<cfif appSettings.getPreActiveReplaceParent() AND appSettings.getDisplayOrphanAlertProgramRevise()>
		<!---
		////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// 52059 -- Determine if program has price protection, if it does skip the check for orphaned bb/inv/budget
		////////////////////////////////////////////////////////////////////////////////////////////////////////////
		--->
		<cfquery name="variables.udf_pre_active_replace_parent" datasource="#application.datasource#">
		    SELECT DBO.udf_pre_active_replace_parent('#FORM.Contract_Number#', #appSettings.getPreActiveReplaceParent()#) as setting
		</cfquery>
		<cfset variables.check_Orphan = variables.udf_pre_active_replace_parent.Setting>
</cfif>

<!---
	50711  Program Date Changes START
	52059  Carry out orphaned logic only when program does NOT have price protection
--->
<cfif variables.check_Orphan eq 1>
	<cfset orphanedBillbacks = 0>
	<cfset orphanedOffInvoices = 0>
	<cfset budgetActualAjustment = 0>
	<cfset errorlist = "">
	<!--- Below query checks for orphaned billbacks for the program with new start date and end date.--->
	<cfquery name="checkBillbacks" datasource="#application.datasource#">
		SELECT  1
		FROM   Contract_Main
		INNER JOIN Billback_Program
		ON       Billback_Program.Program_ID = Contract_Main.Contract_Main_ID
		AND     Billback_Program.Deleted = 0
		INNER JOIN Billback
		ON       Billback.Billback_ID = Billback_Program.Billback_ID
		AND     Billback.Deleted = 0
		AND     Billback.Billback_Status_ID NOT IN (1, 2, 8)
		<!--- If BB is already orphan, do not allow user to reduce the program dates  --->
		AND (
		<!---  BB start is within program dates but changing program dates will create more orphan BB dates (BB start will become outside program dates) --->
		(Billback.BB_Start_Date BETWEEN Contract_Main.Contract_Start_Date AND Contract_Main.Contract_End_Date  AND Billback.BB_Start_Date NOT BETWEEN '#Form.Start_Date#' AND '#Form.End_Date#')
		<!---  BB end is within program dates but changing program dates will create more orphan BB dates (BB end will become outside program dates) --->
		OR (Billback.BB_End_Date BETWEEN Contract_Main.Contract_Start_Date AND Contract_Main.Contract_End_Date  AND Billback.BB_End_Date NOT BETWEEN '#Form.Start_Date#' AND '#Form.End_Date#')
		<!---  Currently orphan (BB start is before program start), BB overlaps with the program (Program start is between BB dates). 
						If program start is changed to be after current program start, it will create more orphan BB dates --->
		OR (Billback.BB_Start_Date < Contract_Main.Contract_Start_Date AND Billback.BB_End_Date >= Contract_Main.Contract_Start_Date AND '#Form.Start_Date#' > Contract_Main.Contract_Start_Date)
		<!---  Currently orphan (BB end is after program end), BB overlaps with the program (Program end is between BB dates). 
							If program end is changed to be before current program end, it will create more orphan BB dates --->
		OR (Billback.BB_End_Date > Contract_Main.Contract_End_Date AND Billback.BB_Start_Date <= Contract_Main.Contract_End_Date AND '#Form.End_Date#' < Contract_Main.Contract_End_Date)
		)
		WHERE Contract_Main.Contract_Number = '#FORM.Contract_Number#'
	</cfquery>

	<cfset orphanedBillbacks = checkBillbacks.recordcount>
	<cfif orphanedBillbacks>
		<cfset errorlist = ListAppend(errorlist,"Billbacks")>
	</cfif>
	<!--- Below query checks for orphaned offInvoices for the program with new start date and end date.--->
	<cfquery name="checkOffInvoice" datasource="#application.datasource#">
		SELECT  1
		FROM   Off_Invoice_Actual_Detail
		WHERE Off_Invoice_Actual_Detail.Contract_Number = '#FORM.Contract_Number#'
		AND     NOT (Invoice_Date BETWEEN '#Form.Start_Date#' AND '#Form.End_Date#')
	</cfquery>
	<cfset orphanedOffInvoices = checkOffInvoice.recordcount>
	<cfif orphanedOffInvoices>
		<cfset errorlist = ListAppend(errorlist," Off Invoice dollars ")>
	</cfif>
	<!--- Below query checks for budget actual adjustment dollars associated to the program with new start date and end date.--->
	<cfquery name="checkActualAjustment" datasource="#application.datasource#">
		SELECT  1
		FROM   Contract_Main
		INNER JOIN Budget_Actual_Adjustment
		ON       Budget_Actual_Adjustment. Contract_Main_ID = Contract_Main. Contract_Main_ID
		AND     NOT (Adjustment_Date BETWEEN '#Form.Start_Date#' AND '#Form.End_Date#')
		WHERE Contract_Main.Contract_Number = '#Form.Contract_Number#'
	</cfquery>
	<cfset budgetActualAjustment = checkActualAjustment.recordcount>
	<cfif budgetActualAjustment>
		<cfset errorlist = ListAppend(errorlist," Budget actual adjustment dollars")>
	</cfif>

	<cfif listlen(errorlist) GT 2>
		<cfset errorlist = Replace(errorlist, ',', 'and','all')>
		<cfset errorlist = Replace(errorlist, 'and', ',')>
	<cfelse>
		<cfset errorlist = Replace(errorlist, ',', ' and')>
	</cfif>

	<cfif orphanedBillbacks OR orphanedOffInvoices OR budgetActualAjustment>
		<cfset DisplayMessageAndRedirect("The dates entered will cause existing <cfoutput>#errorlist#</cfoutput> associated to this program to be orphaned.")>
	</cfif>
</cfif>
<!--- D50711 Program Date Changes END --->

<cfif form.Program_Date_Type eq 2>
		<cfset Form.start_date = Dateformat(Form.start_date,"mm/dd/YYYY")>
		<cfset Form.end_date = Dateformat(Form.end_date,"mm/dd/YYYY")>
</cfif>

	<!--- If the date is an invalid one (This is always due to the invalid number of days in that month), make it valid --->
	<cfif Not(IsDate(Form.start_date))>
		<cfset Start_Date_Month = ListgetAt(Form.start_date,1,"/")>
		<cfset Start_Date_Days = "1">
		<cfset Start_Date_Year = ListgetAt(Form.start_date,3,"/")>
		<!--- Set the invalid number of days in a month to 1 --->
		<cfset Form.start_date = Start_Date_Month & '/' & Start_Date_Days & '/' &  Start_Date_Year>
		<!--- Get the days in the month for the start date and set the start_date to have the valid number of days in that month --->
		<cfset Form.start_date =  Start_Date_Month & '/' & DaysInMonth(Form.start_date) & '/' &  Start_Date_Year>
	</cfif>

	<!--- If the date is an invalid one (This is always due to the invalid number of days in that month), make it valid --->
	<cfif Not(IsDate(Form.end_date))>
		<cfset End_Date_Month = ListgetAt(Form.end_date,1,"/")>
		<cfset End_Date_Days = "1">
		<cfset End_Date_Year = ListgetAt(Form.end_date,3,"/")>
		<!--- Set the invalid number of days in a month to 1 --->
		<cfset Form.end_date = End_Date_Month & '/' & End_Date_Days & '/' &  End_Date_Year>
		<!--- Get the days in the month for the end date and set the end_date to have the valid number of days in that month --->
		<cfset Form.end_date =  End_Date_Month & '/' & DaysInMonth(Form.end_date) & '/' &  End_Date_Year>
	</cfif>


<!---If they are auto renewing--->
<cfif Form.Auto_Renew IS 1>
	<!--- (WR-50746) If the renewal is "annual", do not allow a date of 2/29, as 2/29 will not be a valid date next year. --->
	<cfif Form.AR_RENEWAL_TYPE eq 1>
		<!---If it's leap year, reset it--->
		<cfif DatePart('m', Form.Start_Date) IS "02" AND DatePart('d', Form.Start_Date) IS "29">
			<cfset Form.Start_Date = DatePart('yyyy', Form.Start_Date) & "-02-28">
		</cfif>
		<cfif DatePart('m', Form.End_Date) IS "02" AND DatePart('d', Form.End_Date) IS "29">
			<cfset Form.End_Date = DatePart('yyyy', Form.End_Date) & "-02-28">
		</cfif>
	</cfif>

	<cfset stAutoRenewDates = objProgram.getAutoRenewDates(
					autoRenewType = AR_RENEWAL_TYPE,
					autoRenewalLeadTime = Renewal_Lead_Time,
					programDateType = getTemplateSettings.Program_Date_Type,
					startDate = Form.Start_Date,
					endDate = Form.End_Date) />

	<cfset AR_Start_Date = stAutoRenewDates.AR_Start_Date />
	<cfset AR_Start_Period = stAutoRenewDates.AR_Start_Period />
	<cfset AR_End_Date = stAutoRenewDates.AR_End_Date />
	<cfset AR_End_Period = stAutoRenewDates.AR_End_Period />
	<cfset AR_Notification_Date = stAutoRenewDates.AR_Notification_Date />
	<cfset AR_Fiscal_Year = stAutoRenewDates.AR_Fiscal_Year />


</cfif>

<CFSET FORM.Quantity = replace(val(FORM.Quantity), ",", "", 'ALL')>

<!------<cfset DayCount = datediff('d', start_date, end_date)>----->
<!---- days are both including ---->
<!---- and pls don't remove this --->
<cfset DayCount = datediff('d', start_date, end_date) + 1>
<cfif DayCount EQ 0><cfset DayCount = 1></cfif>
<CFSET DailyContractQuantity = FORM.Quantity/DayCount>

<CFIF FORM.Do_Revise_Copy NEQ 0>
	<CFSET FORM.Document_ID = "">
</CFIF>

<CFSWITCH expression="#FORM.Document_ID#">

	<!--- INSERT SECTION --->
	<CFCASE value="contract_create_1_form">

		<CFSWITCH expression="#FORM.Query_Type#">

			<CFCASE value="INSERT">

			<!------
			Before starting to process any thing, check the following first
			This page does both the insert and update, and it based on the variable FORM.Query_Type(INSERT,UPDATE)
			As we have some issues where different programs get created with same program number, if this page gets executed twice with FORM.Query_Type=INSERT for same FORM.Contract_Number,
			we have to check if this program number already exist in the database
			----->
			<!------ Query the database for same program number ----->
			<cfquery name="qCheckProgramNumber" datasource="#application.datasource#">
				SELECT TOP 1 Contract_Main_ID
				FROM	Contract_Main
				WHERE	Contract_Number = <cfqueryparam value="#FORM.Contract_Number#" cfsqltype="CF_SQL_VARCHAR">
				Order By Contract_Main_ID DESC
			</cfquery>
			<cfif qCheckProgramNumber.recordCount>
				<CFSET New_Contract_Main_ID = qCheckProgramNumber.Contract_Main_ID />
			<cfelse>

				<cfif isDefined("Scheduled") AND Scheduled IS 1>
					<!---If it is auto renew--->
					<cfset This_User_Position_ID = User_Position_ID>
				<cfelse>
					<!---If it is not auto renew, use the valye which is already set--->

				</cfif>

				<CFQUERY NAME="insert" datasource="#application.datasource#">
					SET NOCOUNT ON
					INSERT INTO Contract_Main
					(
						Contract_Number,
						Contract_Reference_Number,
						Contract_Reference_Number_2,<!--- 77539 --->
						Contract_Title,
						Contract_Start_Date,
						Contract_End_Date,
						Fiscal_Year,
						Contract_Quantity,
						Contract_Quantity_UOM_IDX,
						<!--- Discount_Type_ID, ---><!---  may not need to be here anymore --->
						Dist_Brand_Eligibility,
						Deleted,
						contract_status_type_IDX,
						fixed_rebate_amount,
						Creator_ID,
						Editor_ID,
						Owner_Company_ID,
						Notes,
						PaymentCycle,
						ProgramType,
						ProgramType_ID,
						Auto_Renew,
						ClaimMechanics,
						BldUpInvoice,
						Controllable_Volume,
						Growth_Inclusion,
						GL_Assignment,
						Contract_Daily_Volume,
						Adv_Spending_Amount,
						Creating_User_Position_ID,
						Contract_Is_Locked,
						Contract_Locked_By_User_ID,
						chkClaimPerfReq_1,
						chkClaimPerfReq_2,
						chkClaimPerfReq_3,
						chkClaimPerfReq_4,
						chkClaimPerfReq_5,
						chkClaimPerfReq_6,
						chkClaimPerfReq_7,
						chkClaimPerfReq_8,
						chkClaimPerfReq_9,
						Business_Segment_ID,
						Line_Of_Business_ID,
						Responsible_User_Id,
						Date_Method,
						Is_Awarded,
						Search_Sequence_ID,
						Pullback_From_This_Program
						<cfif appSettings.getBrokerTradeQuestOn()>
						,Affect_Broker_Commission
						,Affect_Broker_Commission_Type
						,Affect_Shelter
						,Affect_Shelter_Type
						</cfif>
						<cfif editBidId>
						,BID_NUMBER</cfif>
						<cfif appSettings.getModify_Legacy_ID() EQ 1>
						,Legacy_Deal_ID</cfif>
						<!--- removed Clay-Budget
						<cfif len(form.selectedBudget) GT 0
						  AND appSettings.getBudgetsOn()
						  AND appSettings.getSelectBudgetsOn() EQ 1
						  AND appSettings.getBudgetRelationshipToPrograms() EQ 1>
						,budget_reference_id
						</cfif>
						--->
						,Performance_Start_Date
						,Performance_End_Date
						,Currency
						,Template_Filters_Id
						,Effective_Date_for_Price
						,Currency_Conversion_Factor                <!---34302--->
						,Contract_period_start_date
						,Contract_period_end_date
						,Best_Plan_Program<!---60308 --->
						,Is_Blanket_Bid
						,Planner_Perf_Type_ID
					)
					VALUES
					(

						'#FORM.Contract_Number#',
						'#FORM.Contract_Reference_Number#',
						'#FORM.Contract_Reference_Number_2#',<!--- 77539 --->
						'#FORM.Contract_Title#',
						'#dateformat(FORM.start_date, 'm/d/yyyy')#',
						'#dateformat(FORM.end_date, 'm/d/yyyy')#',
						'#FORM.Fiscal_Year#',
						'#FORM.Quantity#',
						'#FORM.Contract_Quantity_UOM_IDX#' ,
						<!---<CFIF FORM.FRA_GNFP EQ 1>1<CFELSEIF FORM.FRA_GNFP EQ 5>5<CFELSE>'#FORM.DEV_FOB#'</CFIF>, --->
						#FORM.Dist_Brand_Eligibility#,
						0,
						1,
						'#FORM.fixed_rebate_amount#',
						'#request.AccessStructure.User_ID#',
						'#request.AccessStructure.User_ID#',
						'#request.AccessStructure.Company_Main_ID#',
						'#FORM.Notes#',
						#FORM.PaymentCycle#,
						'#FORM.Created_Type#',
						'#Form.ProgramType_ID#',
						#FORM.Auto_Renew#,
						#FORM.ClaimMechOption#,
						#FORM.ClaimMechOptionsBUI#,
						#FORM.Controllable_Flag#,
						#FORM.Growth_Inclusion_Flag#,
						#FORM.GL_Assignment_ID#,
						'#DailyContractQuantity#',
						'#FORM.Adv_Spend_Amount#',
						'#This_User_Position_ID#',
						1,
						'#request.AccessStructure.User_ID#',
						0,
						0,
						0,
						0,
						0,
						0,
						0,
						0,
						0,
						'#listFirst(form.Business_Segment_ID)#',
						<cfif form.LOB_ID EQ "NULL">
						#form.LOB_ID#,
						<cfelse>
						'#form.LOB_ID#',
						</cfif>
						'#form.Responsible_User_id#',
						#form.Date_Method#,
						#form.Is_Awarded#,
						'#form.Search_Sequence_ID#',
						'#FORM.Pullback_From_This_Program#'
						<cfif appSettings.getBrokerTradeQuestOn()>
						,'#form.Affect_Broker_Commission#'
						,'#form.Affect_Broker_Commission_Type#'
						,'#form.Affect_Shelter#'
						,'#form.Affect_Shelter_Type#'
						</cfif>
						<cfif editBidId>
						,'#form.bid_id#'
						</cfif>
						<cfif appSettings.getModify_Legacy_ID() EQ 1>
						,'#LegacyDealID#'
						</cfif>
						<!--- removed clay-budget
						<cfif len(form.selectedBudget) GT 0
						  AND appSettings.getBudgetsOn()
						  AND appSettings.getSelectBudgetsOn() EQ 1
						  AND appSettings.getBudgetRelationshipToPrograms() EQ 1>
							,#form.selectedBudget#
						</cfif>
						--->
						,<cfqueryparam cfsqltype="cf_sql_date" value="#Form.Performance_Start_Date#" null="#Is_Performance_Date_Null#"/>
						,<cfqueryparam cfsqltype="cf_sql_date" value="#Form.Performance_End_Date#" null="#Is_Performance_Date_Null#"/>
						,<cfqueryparam cfsqltype="cf_sql_integer" value="#Form.Currency#" />
						,<cfqueryparam cfsqltype="cf_sql_integer" value="#Form.TemplateFiltersId#" />
						,<cfqueryparam cfsqltype="cf_sql_date" value="#Form.Effective_Date_for_Price#" null="#Effective_Date_for_Price_Null#"/>
						,<cfif form.currency_conversion_factor eq "">NULL<cfelse><cfqueryparam cfsqltype="cf_sql_decimal" value="#form.currency_conversion_factor#" scale="#scale.currency_conversion_factor#"></cfif>     <!---34302--->
						,<cfqueryparam cfsqltype="cf_sql_date" value="#Form.contract_period_start_date#" null="#Contract_period_start_date_Null#"/>
						,<cfqueryparam cfsqltype="cf_sql_date" value="#Form.contract_period_end_date#" null="#Contract_period_end_date_Null#"/>
						,<cfqueryparam value="#form.Best_Plan_Program#" cfsqltype="cf_sql_bit" /><!---60308 --->
						,<cfqueryparam value="#form.Is_Blanket_Bid#" cfsqltype="cf_sql_bit" />
						,<cfqueryparam cfsqltype="cf_sql_integer" value="#Form.Planner_Perf_Types_ID#" />
					)
					--SELECT MAX(Contract_Main_ID) AS Contract_Main_ID FROM Contract_Main
					SELECT Contract_Main_ID = @@IDENTITY
					SET NOCOUNT OFF
				</CFQUERY>

				<cfquery name="delDupContractMain" datasource="#application.datasource#">
					update	Contract_Main
					set		Deleted = 1,
							Deleted_By = 'DUPLICATE',
							Deleted_Date = GETDATE()
					where	Contract_Number = '#FORM.Contract_Number#'
					and		Is_A_Revision = 0
					and		Renewal_of_Contract_Main_ID is null
					and		Revision_of_Contract_Main_ID is null
					and		Deleted = 0
					and		Contract_Main_ID < #insert.Contract_Main_ID#
				</cfquery>

			<!--- Add program owner info here --->
				<cfset useLakebaseForinsProgramOwner = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_owner")>
<cfif useLakebaseForinsProgramOwner>
	<cftry>
		<cfset application.oLakebase.insertRow("program_owner", {
			"contract_main_id" = "#insert.Contract_Main_ID#",
			"contract_number" = "#FORM.Contract_Number#",
			"responsible_user_id" = "#form.Responsible_User_id#",
			"creating_user_position_id" = "#This_User_Position_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForinsProgramOwner = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForinsProgramOwner>
<cfquery name="insProgramOwner" datasource="#application.datasource#">
				 INSERT INTO Program_Owner(Contract_Main_ID, Contract_Number, Responsible_User_ID, Creating_User_Position_ID)
				  VALUES('#insert.Contract_Main_ID#', '#FORM.Contract_Number#', '#form.Responsible_User_id#', '#This_User_Position_ID#')
				</cfquery>
</cfif>

			<!---Add performance requirements--->
				<!--- <cfloop index = "Requirement" list = "#PerfRequirements#"  delimiterS = ",">
					<cfquery name="InsertPerfReq" datasource="#application.datasource#">
					INSERT INTO One_Program_Perf_Mapping
					(
						Contract_Main_ID,
						Program_Perf_Req_ID
					)
					VALUES
					(
						'#insert.Contract_Main_ID#',
						#Requirement#
					)
					</cfquery>
				</cfloop> --->

		<!--- START: 25709: EZ Button/Anand Rao/28-Mar-2011 --->
		<!---
			No need to check for any record count as this will be called only once when the Program is created and will insert the
			products into contract_products table
		  --->

 	<!-----------------------------------------------------------------------------------------------------------------------------------------------
	 ------------------------------------------------------------------------------------------------------------------------------------------------
	 	--D40005
	 	--COMMENTED OUT MWS
	 	PRIOR TO 40005, EzButton_Default_Show_Item_Rates WAS ALWAYS 0.  EZ_BUTTON_SETTINGS.CFM HAD IT HARD CODED AS 0.  NOW THAT SETTING IS BEING USED TO DETERMINE IF
	 	THE EZ BUTTON RATE IS DISPLAYED ON THE REBATE PAGE (AS A DEFAULT).  WE DONT WANT TO INSERT ALL RATES THOUGH.  SINCE EzButton_Default_Show_Item_Rates HAS NEVER BEEN 1 WE ARE SAFE TO REMOVE
	 	THIS
	  ------------------------------------------------------------------------------------------------------------------------------------------------
	 	<cfif (getTemplateSettings.EzButton_On EQ 1 AND getTemplateSettings.EzButton_Default_Show_Item_Rates EQ 1)>

			<!---
			<cfquery name="qGetDummyContractID" datasource="#application.datasource#">
				SELECT TOP 1 Contract_Main_ID  FROM Contract_Main WHERE programType_ID = #Form.ProgramType_ID# AND contract_Number like 'TMP_PRG%'
			</cfquery>
			--->

			<cfquery name="qInsertComponent" datasource="#application.datasource#">
				INSERT INTO Program_Rebates_Component(
				Program_ID,
				Program_Rebates_Component_Name_ID,
				Component_Paid_To,
				Claim_Mechanics,
				Basis_Code_Master_ID,
				Treatment_Code_Master_ID,
				Effective_Margin_Flag,
				GL_Account_ID,
				Component_External_ID,
				Vendor_Master_ID,
				Vendor_Selection,
				Payee_Type,
				Parent_Program_Rebates_Component_ID
				)
				SELECT
				#insert.Contract_Main_ID#,
				Program_Rebates_Component_Name_ID,
				Component_Paid_To,
				Claim_Mechanics,
				Basis_Code_Master_ID,
				Treatment_Code_Master_ID,
				Effective_Margin_Flag,
				GL_Account_ID,
				Component_External_ID,
				Vendor_Master_ID,
				Vendor_Selection,
				Payee_Type,
				Program_Rebates_Component_ID
				FROM	Program_Rebates_Component
				WHERE	Program_ID = #getTemplateSettings.EZ_Contract_Id#
				AND		Deleted = 0
			</cfquery>

			<cfquery name="qInsertProgramPaymentCycle" datasource="#application.datasource#">
				INSERT INTO Program_Payment_Cycle
				(
				Program_ID,
				Discount_Type_ID,
				Payment_Cycle_ID,
				Component_ID
				)
				SELECT #insert.Contract_Main_ID#,
				       Program_Payment_Cycle.Discount_Type_ID,
				       Program_Payment_Cycle.Payment_Cycle_ID,
				       pgmComp.Program_Rebates_Component_ID
				FROM  Program_Payment_Cycle
				INNER JOIN Program_Rebates_Component tmplComp
				ON          tmplComp.Program_Rebates_Component_ID = Program_Payment_Cycle.Component_ID
				INNER JOIN Program_Rebates_Component pgmcomp
				ON          pgmComp.Parent_Program_Rebates_Component_ID = tmplComp.Program_Rebates_Component_ID
				AND         pgmComp.Program_ID = #insert.Contract_Main_ID#
				WHERE Program_Payment_Cycle.Program_ID = #getTemplateSettings.EZ_Contract_Id#
				AND         Program_Payment_Cycle.Deleted = 0
			</cfquery>

			<cfquery 	name="qGetProductFromDummy" datasource="#application.datasource#">
				SELECT CP.*,
				PRPD.Program_Rebates_Product_Data_ID,
				PRPD.Rebate_Value,
				PRPD.Volume,
				PRPD.Unit_OF_Measure_ID,
				PRPD.Is_Group,
				PRPD.Captured_From_Group
				FROM Contract_Products CP
				INNER JOIN Program_Rebates_Product_Data PRPD ON PRPD.Contract_Products_ID = CP.Contract_Products_ID
				AND PRPD.Deleted = 0
				LEFT JOIN BSA_FoodService_Items_Master BSAFSIM ON BSAFSIM.BSA_FoodService_Items_Master_ID = CP.BSA_FoodService_Items_Master_ID
				WHERE CP.Contract_Main_ID = '#getTemplateSettings.EZ_Contract_Id#' AND  CP.Deleted = 0
				<cfif form.businessSegmentsOn EQ 1>
					AND (CP.is_Group = 1 OR BSAFSIM.Business_Segment_ID = #FORM.Business_Segment_ID#)
				</cfif>
			</cfquery>

			<cfloop query="qGetProductFromDummy">
				<cfquery name="qInsProdFromTemplateDupProgram" datasource="#application.datasource#">
			  	DECLARE @Contract_Products_ID int
					INSERT INTO Contract_Products
					(
						BSA_Foodservice_Items_Master_ID,
						Product_UPC,
						Contract_Main_ID,
						Discount_Value,
						Deleted,
						Pricing_Rule,
						Creator_ID,
						Date_Created,
						Product_Type_ID,
						Product_Process_Flag,
						Product_Group_Level_ID,
						Product_Group_ID,
						Pricing_Level_ID,
						Is_Group,
						Dynamic_Static_Groups,
						Discounted_Item,
						Captured_From_Group,
						products_not_captured_flag,
						EZButton_On_Default,
						Include_In_Margin,
						EZ_Contract_Id,
						Include_In_Volume,
						Exclude_From_Margin,
						Copied_From_Contract_Product_ID
					)
					VALUES
					(
						'#qGetProductFromDummy.BSA_Foodservice_Items_Master_ID#',
						'#qGetProductFromDummy.Product_UPC#',
						#insert.Contract_Main_ID#,
						'#qGetProductFromDummy.Discount_Value#',
						0,
						<cfif qGetProductFromDummy.Pricing_Rule EQ "">NULL,</cfif>
						'#FORM.Responsible_User_id#',
						getDate(),
						#qGetProductFromDummy.Product_Type_ID#,
						#qGetProductFromDummy.Product_Process_Flag#,
						#qGetProductFromDummy.Product_Group_Level_ID#,
						'#qGetProductFromDummy.Product_Group_ID#',
						#qGetProductFromDummy.Pricing_Level_ID#,
						#qGetProductFromDummy.Is_Group#,
						#qGetProductFromDummy.Dynamic_Static_Groups#,
						#qGetProductFromDummy.Discounted_Item#,
						#qGetProductFromDummy.Captured_From_Group#,
						#qGetProductFromDummy.products_not_captured_flag#,
						#qGetProductFromDummy.EZButton_On_Default#,
						#qGetProductFromDummy.Include_In_Margin#,
						<cfif qGetProductFromDummy.EZ_Contract_Id EQ "">NULL,<cfelse>#qGetProductFromDummy.EZ_Contract_Id#,</cfif>
						#qGetProductFromDummy.Include_In_Volume#,
						<cfif qGetProductFromDummy.Exclude_From_Margin EQ "">NULL,<cfelse>#qGetProductFromDummy.Exclude_From_Margin#,</cfif>
						<cfif qGetProductFromDummy.Copied_From_Contract_Product_ID EQ "">NULL<cfelse>#qGetProductFromDummy.Copied_From_Contract_Product_ID#</cfif>
					)
				 SET @Contract_Products_ID = SCOPE_IDENTITY()
	       SELECT Contract_Products_ID = @Contract_Products_ID
				</cfquery>
				<cfset useLakebaseForqInsRebProdFromTemplateDupProgram = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_rebates_product_data")>
<cfif useLakebaseForqInsRebProdFromTemplateDupProgram>
	<cftry>
		<cfset application.oLakebase.insertRow("program_rebates_product_data", {
			"program_id" = "#insert.Contract_Main_ID#",
			"contract_products_id" = "#qInsProdFromTemplateDupProgram.Contract_Products_ID#",
			"rebate_value" = "#qGetProductFromDummy.Rebate_Value#",
			"volume" = "#qGetProductFromDummy.Volume#",
			"unit_of_measure_id" = "#qGetProductFromDummy.Unit_OF_Measure_ID#",
			"deleted" = "0",
			"is_group" = "#qGetProductFromDummy.Is_Group#",
			"created_date" = "#now()#",
			"captured_from_group" = "#qGetProductFromDummy.Captured_From_Group#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqInsRebProdFromTemplateDupProgram = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqInsRebProdFromTemplateDupProgram>
<cfquery name="qInsRebProdFromTemplateDupProgram" datasource="#application.datasource#">
					INSERT INTO Program_Rebates_Product_Data
					(
						Program_ID,
						Contract_Products_ID,
						Rebate_Value,
						Volume,
						Unit_Of_Measure_ID,
						Deleted,
						Is_Group,
						Created_Date,
						Captured_From_Group
					)
					VALUES
					(
						#insert.Contract_Main_ID#,
						#qInsProdFromTemplateDupProgram.Contract_Products_ID#,
						'#qGetProductFromDummy.Rebate_Value#',
						'#qGetProductFromDummy.Volume#',
						#qGetProductFromDummy.Unit_OF_Measure_ID#,
						0,
						#qGetProductFromDummy.Is_Group#,
						getDate(),
						#qGetProductFromDummy.Captured_From_Group#
					)
					SELECT SCOPE_IDENTITY()	as 	Program_Rebates_Product_Data_ID
				</cfquery>
</cfif>

				<!--- Insert all component rates from template for this product alone --->
				<cfquery name="qInsRebRateFromTemplateDupProgram" datasource="#application.datasource#">
					INSERT INTO Program_Rebates_Component_Data
					(
						Program_Rebates_Component_ID,
						Program_Rebates_Product_Data_ID,
						Rate,
						Unit_Of_Measure_ID,
						Program_Rebates_Component_Rule_ID,
						Is_Group,
						Captured_From_Group,
						Basis_Code_Quantity,
						Basis_Code_Quantity_UOM,
						Basis_Code_Free_Goods,
						Basis_Code_Free_Goods_UOM,
						Effective_Margin_Percent,
						Scan_Rate,
						Scan_Volume,
						Scan_Uom,
						EZ_Contract_Max_Rate
					)
					SELECT
						pgmComp.Program_Rebates_Component_ID,
						#qInsRebProdFromTemplateDupProgram.Program_Rebates_Product_Data_ID#,
						tmplRate.Rate,
						tmplRate.Unit_Of_Measure_ID,
						tmplRate.Program_Rebates_Component_Rule_ID,
						tmplRate.Is_Group,
						tmplRate.Captured_From_Group,
						tmplRate.Basis_Code_Quantity,
						tmplRate.Basis_Code_Quantity_UOM,
						tmplRate.Basis_Code_Free_Goods,
						tmplRate.Basis_Code_Free_Goods_UOM,
						tmplRate.Effective_Margin_Percent,
						tmplRate.Scan_Rate,
						tmplRate.Scan_Volume,
						tmplRate.Scan_Uom,
						tmplRate.Rate
					FROM	Program_Rebates_Component tmplComp
					INNER JOIN Program_Rebates_Component pgmComp
					ON		pgmcomp.Parent_Program_Rebates_Component_ID = tmplcomp.Program_Rebates_Component_ID
					AND		pgmcomp.Program_ID = #insert.Contract_Main_ID#
					INNER JOIN Program_Rebates_Component_Data tmplRate
					ON		tmplRate.Program_Rebates_Component_ID = tmplComp.Program_Rebates_Component_ID
					AND		tmplRate.Program_Rebates_Product_Data_ID = #qGetProductFromDummy.Program_Rebates_Product_Data_ID#
					AND		tmplRate.Deleted = 0
					WHERE	tmplComp.Program_ID = #getTemplateSettings.EZ_Contract_Id#
					and		tmplComp.Deleted = 0
				</cfquery>

			</cfloop>
		</cfif>--->
		<!---71858 Perm Req Enh V2 - Search bar within Lists, & Min. Requirement on each List START--->
		<cfset qryProgramInfo = objProgram.PerformanceRequirements(templateID=#Form.ProgramType_ID#,contractMainID=#insert.Contract_Main_ID#,Form=#form#)>
		<!---71858 Perm Req Enh V2 - Search bar within Lists, & Min. Requirement on each List END--->
			
		<!--- END: 25709: EZ Button/Anand Rao/28-Mar-2011 --->
			<cfloop index = "Requirement" list = "#PerfRequirements#"  delimiterS = ",">
					<cfoutput>
					<cfparam name="form.PerfReq_Category_#Requirement#" 	default="0" />
					<cfparam name="form.PerfReq_Priority_#Requirement#" 	default="0" />
					<cfparam name="form.PerfReq_Start_Date_#Requirement#" 	default="" />
					<cfparam name="form.PerfReq_End_Date_#Requirement#" 	default="" />
					#Requirement#
					</cfoutput>
					<cfquery name="InsertPerfReq" datasource="#application.datasource#">
						INSERT INTO One_Program_Perf_Mapping
						(
							Contract_Main_ID,
							Program_Perf_Req_ID,
							Operator_Category_ID,
							Operator_Priority_ID,
							PR_Start_Date,
							PR_End_Date,
							Checked
						)
						VALUES
						(
							<cfqueryparam value="#insert.Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER" />,
							<cfqueryparam value="#Requirement#" cfsqltype="CF_SQL_INTEGER" />,
							<cfqueryparam value="#evaluate("form.PerfReq_Category_#Requirement#")#" cfsqltype="CF_SQL_INTEGER" />,
							<cfqueryparam value="#evaluate("form.PerfReq_Priority_#Requirement#")#" cfsqltype="CF_SQL_INTEGER" />,
							<cfqueryparam value="#evaluate("form.PerfReq_Start_Date_#Requirement#")#" cfsqltype="CF_SQL_DATE" />,
							<cfqueryparam value="#evaluate("form.PerfReq_End_Date_#Requirement#")#" cfsqltype="CF_SQL_DATE" />,
							<cfqueryparam value="1" cfsqltype="cf_sql_bit" />
						)
					</cfquery>
				</cfloop>

				<cfloop index = "NoRequirement" list = "#NoPerfRequirements#"  delimiters = ",">
				<cfoutput>#NoRequirement#</cfoutput>
					<cfquery name="InsertPerfReq" datasource="#application.datasource#">
					INSERT INTO One_Program_Perf_Mapping
					(
						Contract_Main_ID,
						Program_Perf_Req_ID,
						checked
					)
					VALUES
					(
						'#insert.Contract_Main_ID#',
						#NoRequirement#,
						0
					)
					</cfquery>
				</cfloop>
				<!------ Save Operating Groups for this program ----->
				<cfif appSettings.getOperatingGroupOn()>
					<cfparam name="form.Operating_Group_1" 	default="0">
					<cfparam name="form.Operating_Group_2" 	default="0">
					<cfset operatingGroupManager 			= CreateObject("component", "components.Operating_Group.OperatingGroupManager").init() />
					<cfset operatingGroupManager.updateOperatingGroupProgram(id=form.Operating_Group_1, level=1, programId=insert.Contract_Main_ID) />
					<cfset operatingGroupManager.updateOperatingGroupProgram(id=form.Operating_Group_2, level=2, programId=insert.Contract_Main_ID) />
				</cfif>

				<!--- save comments --->
				<cfset useLakebaseForrecordCheck = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main_aux_data")>
<cfif useLakebaseForrecordCheck>
	<cftry>
		<cfset recordCheck = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main_aux_data", {
				"contract_main_id" = "eq.#insert.Contract_Main_ID#",
				"select" = "contract_main_id"
			}), "contract_main_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForrecordCheck = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForrecordCheck>
<cfquery name="recordCheck" datasource="#Application.Datasource#">
					SELECT Contract_Main_ID
					FROM Contract_Main_Aux_Data
					WHERE Contract_Main_ID = '#insert.Contract_Main_ID#'
				</cfquery>
</cfif>
				<CFIF recordCheck.recordcount EQ 0>
					<cfset useLakebaseForinsertRecord = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main_aux_data")>
<cfif useLakebaseForinsertRecord>
	<cftry>
		<cfset application.oLakebase.insertRow("contract_main_aux_data", {
			"contract_main_id" = "#insert.Contract_Main_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForinsertRecord = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForinsertRecord>
<cfquery name="insertRecord" datasource="#Application.Datasource#">
						INSERT INTO Contract_Main_Aux_Data
						(Contract_Main_ID)
						VALUES
						('#insert.Contract_Main_ID#')
					</cfquery>
</cfif>
				</CFIF>

				<cfquery name="saveAuxData" datasource="#Application.Datasource#">
					UPDATE Contract_Main_Aux_Data
					SET <cfif Form.Comments neq "">Comments = '#Form.Comments#',</cfif>
						<cfif Form.Competitive_Info_Notes neq "">Competitive_Info_Notes = '#Form.Competitive_Info_Notes#',</cfif>
						Like_Product_Exist = '#Form.Like_Product_Exist#',
						Pay_To_Distributor = '#FORM.Pay_To_Distributor#',
						Payable_Company = '#FORM.Payable_Company#',
						Payable_Attention = '#FORM.Payable_Attention#',
						Payable_Address_1 = '#FORM.Payable_Address_1#',
						Payable_Address_2 = '#FORM.Payable_Address_2#',
						Payable_City	  = '#FORM.Payable_City#',
						Payable_State	  = '#FORM.Payable_State#',
						Payable_Zip		  =	'#FORM.Payable_Zip#',
						Payable_Comments  = '#FORM.Payable_Comments#',
						Send_To_Broker	  = '#FORM.Send_To_Broker#',
						Send_Company 	  = '#FORM.Send_Company#',
						Send_Attention 	  = '#FORM.Send_Attention#',
						Send_Address_1    = '#FORM.Send_Address_1#',
						Send_Address_2    = '#FORM.Send_Address_2#',
						Send_City	      = '#FORM.Send_City#',
						Send_State	      = '#FORM.Send_State#',
						Send_Zip		  =	'#FORM.Send_Zip#',
						<cfif appSettings.getUse_Accounting_Program_Type() EQ 1>
						Accounting_Program_Type_ID = '#Form.Accounting_Program_Type_ID#',
						</cfif>
						<cfif appSettings.getProgramCategory() EQ 1>
						Program_Category_ID = '#Form.Program_Category_ID#',
						</cfif>

						Equipment_Placement = #FORM.Equipment_Placement#,
						Equipment_Placement_Note = '#Trim(FORM.Equipment_Placement_Note)#'
						<cfif len(trim(FORM.Operator_List))>
						,Alternate_Payment_Recipient = #trim(FORM.Operator_List)#<!--- D38189::Alternate Payment Recipient --->
						</cfif>
						,Program_Start_Zero = #FORM.Program_Start_Zero# <!--- D38942 :: Program Blackout Period on Frontend--->
						,Program_Future_zero = #FORM.Program_Future_zero#<!--- D38942 :: Program Blackout Period on Frontend--->
						,Program_Most_Favored_Nation = '#form.Program_Most_Favored_Nation#'<!---42349--->
						,Business_Segment_IDs = '#ListRest(form.Business_Segment_ID)#'				<!--- 64860 :: Update Segments selection on programs --->
					WHERE Contract_Main_ID = '#insert.Contract_Main_ID#'
				</cfquery>
				<!--- END comments --->

				<!---Save Auto-Renewal Data--->
				<cfif Form.Auto_Renew IS 1>

					<cfset useLakebaseForInsertAutoRenewData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_auto_renew")>
<cfif useLakebaseForInsertAutoRenewData>
	<cftry>
		<cfset application.oLakebase.insertRow("program_auto_renew", {
			"ar_notification_date" = "#dateFormat(AR_Notification_Date,"short")#",
			"ar_start_date" = "#dateFormat(AR_Start_Date,"short")#",
			"ar_end_date" = "#dateFormat(AR_End_Date,"short")#",
			"ar_renewal_type" = "#Form.AR_Renewal_Type#",
			"program_id" = "#insert.Contract_Main_ID#",
			"renewed" = "0",
			"renewal_lead_time" = "#Form.Renewal_Lead_Time#",
			"ar_start_period" = "#AR_Start_Period#",
			"ar_end_period" = "#AR_End_Period#",
			"ar_fiscal_year" = "#AR_Fiscal_Year#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsertAutoRenewData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsertAutoRenewData>
<cfquery name="InsertAutoRenewData" datasource="#application.datasource#">
						INSERT INTO Program_Auto_Renew
						(
							AR_Notification_Date,
							AR_Start_Date,
							AR_End_Date,
							AR_Renewal_Type,
							Program_ID,
							Renewed,
							Renewal_Lead_Time,
							AR_Start_Period,
							AR_End_Period,
							AR_Fiscal_Year
						)
						VALUES
						(
							'#dateFormat(AR_Notification_Date,"short")#',
							'#dateFormat(AR_Start_Date,"short")#',
							'#dateFormat(AR_End_Date,"short")#',
							'#Form.AR_Renewal_Type#',
							'#insert.Contract_Main_ID#',
							'0',
							'#Form.Renewal_Lead_Time#',
							'#AR_Start_Period#',
							'#AR_End_Period#',
							'#AR_Fiscal_Year#'
						)
					</cfquery>
</cfif>

				</cfif>

				<!------ Start Clause Code ----->
				<!------ 1. Bring all required generic clauses from the template ----->

				<cfset clauseProgramManager.importRequiredClause(Form.ProgramType_ID, insert.Contract_Main_ID, request.AccessStructure.User_ID, 1)>

				<!------ End  Clause Code ----->

				<!---TSF: Modification Bid Request--->
				<!---FILTER: if the template type is Bid Request then insert data for Bid Request--->
				<cfset getTemplateName = CreateObject("component", "components.programs.template.TemplateManager").get(form.ProgramType_ID) />

				<!---create an instance of BidRequestManager--->
				<cfset bidRequestManager = CreateObject("component", "components.programs.bid_request.BidRequestManager") />

				<!--- If the user selected the "other" from Competitor Source and the "Other Competitor Source" textbox is not blank --->
				<cfif form.CompetitorSourceID eq -1 AND form.CompetitorSourceOther neq "">
					<!--- Either Insert a new source or update an existing source. These sources have an "Inactive" status. --->
					<cfset bidRequestSourceOtherID = bidRequestManager.updProgramBidSourceOther(form.CompetitorSourceOtherID,form.CompetitorSourceOther,form.CompetitorSourceOther,0)>
					<!--- Set :"form.CompetitorSourceID" to either the new Source ID generated OR an existing one to be updated --->
					<cfset form.CompetitorSourceID = bidRequestSourceOtherID>
				</cfif>

				<cfif getTemplateSettings.BidRequestStatusOn eq 1>
					<cfparam name="form.Line_Item" default="0" />
					<cfset bidRequestObj = bidRequestManager.setBidRequest(bidRequestId = form.Program_Bid_Request_ID, programId = insert.Contract_Main_ID, openDate = form.Open_Date, dateNeeded = form.Date_Needed, expectedReplyDate = form.Expected_Reply_Date, lineItem = form.Line_Item, openTime = form.Open_Time, sourceID = form.CompetitorSourceID, sourceType = form.CompetitorSourceType) />
				<cfelse>
					<cfset bidRequestObj = bidRequestManager.setBidRequest(bidRequestId = 0, programId = insert.Contract_Main_ID, openDate = form.Open_Date, dateNeeded = form.Date_Needed, expectedReplyDate = form.Expected_Reply_Date, openTime = form.Open_Time, sourceID = form.CompetitorSourceID, sourceType = form.CompetitorSourceType) />
				</cfif>

				<cfset bidRequestManager.saveBidRequest(bidRequestObj) />

				<CFSET New_Contract_Main_ID = insert.Contract_Main_ID />
				<!--- END INSERT SECTION --->
				</CFIF>

				<CF_CRYP type="en" string="#New_Contract_Main_ID#" key="#request.key#">
				<cfset FORM.Contract_Main_ID = New_Contract_Main_ID>
				<CFSET redirector_Program_ID = Form.ProgramType_ID>
				<CFSET redirector_FromPage_ID = 1>
				<cfinclude template="internal_redirector_based_on_settings.cfm">


				<!---  redirect --->
				<CFLOCATION url="redirect.cfm?destination=#redirector_NextLocation#&CID=#cryp.value#&ShowCid=#Form.ShowCid#">

			</CFCASE>

			<CFCASE value="update">

				<CF_CRYP type="de" string="#FORM.CID#" key="#request.key#">

				<!---Save Auto-Renewal Data--->
				<cfif Form.Auto_Renew IS 1>

					<!----- check if we already have an entry in the auto renew queue table ----->
					<cfset useLakebaseForIsAutoRenewThere = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_auto_renew")>
<cfif useLakebaseForIsAutoRenewThere>
	<cftry>
		<cfset IsAutoRenewThere = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_auto_renew", {
				"program_id" = "eq.#cryp.value#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForIsAutoRenewThere = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForIsAutoRenewThere>
<cfquery name="IsAutoRenewThere" datasource="#application.datasource#">
						SELECT 	*
						FROM 		Program_Auto_Renew
						WHERE 	Program_ID = #cryp.value#
							AND 	Deleted = 0
					</cfquery>
</cfif>

					<!----- if no entry insert, else update ----->
					<cfif IsAutoRenewThere.Recordcount IS 0>

						<cfquery name="InsertAutoRenewData" datasource="#application.datasource#">
							INSERT INTO Program_Auto_Renew
							(
								AR_Notification_Date,
								AR_Start_Date,
								AR_End_Date,
								AR_Renewal_Type,
								Program_ID,
								Renewed,
								Renewal_Lead_Time,
								AR_Start_Period,
								AR_End_Period,
								AR_Fiscal_Year
							)
							VALUES
							(
								'#dateFormat(AR_Notification_Date,"short")#',
								'#dateFormat(AR_Start_Date,"short")#',
								'#dateFormat(AR_End_Date,"short")#',
								'#Form.AR_Renewal_Type#',
								'#cryp.value#',
								0,
								'#Form.Renewal_Lead_Time#',
								'#AR_Start_Period#',
								'#AR_End_Period#',
								'#AR_Fiscal_Year#'
							)
						</cfquery>

					<cfelseif IsAutoRenewThere.Recordcount IS 1>

						<cfset useLakebaseForUpdateAutoRenewData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_auto_renew")>
<cfif useLakebaseForUpdateAutoRenewData>
	<cftry>
		<cfset application.oLakebase.updateRows("program_auto_renew",
			{
				"program_id" = "eq.#cryp.value#"
			},
			{
				"ar_notification_date" = "#dateFormat(AR_Notification_Date,"short")#",
				"ar_start_date" = "#dateFormat(AR_Start_Date,"short")#",
				"ar_end_date" = "#dateFormat(AR_End_Date,"short")#",
				"ar_renewal_type" = "#Form.AR_Renewal_Type#",
				"renewal_lead_time" = "#Form.Renewal_Lead_Time#",
				"ar_start_period" = "#AR_Start_Period#",
				"ar_end_period" = "#AR_End_Period#",
				"ar_fiscal_year" = "#AR_Fiscal_Year#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateAutoRenewData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateAutoRenewData>
<cfquery name="UpdateAutoRenewData" datasource="#application.datasource#">
							UPDATE 	Program_Auto_Renew
							SET 		AR_Notification_Date = '#dateFormat(AR_Notification_Date,"short")#',
											AR_Start_Date = '#dateFormat(AR_Start_Date,"short")#',
											AR_End_Date = '#dateFormat(AR_End_Date,"short")#',
											AR_Renewal_Type = '#Form.AR_Renewal_Type#',
											Renewal_Lead_Time = '#Form.Renewal_Lead_Time#',
											AR_Start_Period = '#AR_Start_Period#',
											AR_End_Period = '#AR_End_Period#',
											AR_Fiscal_Year = '#AR_Fiscal_Year#'
							WHERE 	Program_ID = #cryp.value#
						</cfquery>
</cfif>

					</cfif>

				</cfif>

				<!--- lock checker --->
				<CFSET LockChecker_CID  = cryp.value>
				<CFINCLUDE TEMPLATE="LockChecker.cfm">
				<!--- lock checker --->

				<cfset useLakebaseForgetSDED = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForgetSDED>
	<cftry>
		<cfset getSDED = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#cryp.value#",
				"select" = "contract_start_date,contract_end_date"
			}), "contract_start_date,contract_end_date"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetSDED = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetSDED>
<cfquery name="getSDED" datasource="#application.datasource#">
					SELECT Contract_Start_Date, Contract_End_Date
					FROM Contract_Main
					WHERE Contract_Main_ID = '#cryp.value#'
				</cfquery>
</cfif>
				<CFSET oldSD = DateFormat(getSDED.Contract_Start_Date, 'mm/dd/yyyy')>
				<CFSET oldED = DateFormat(getSDED.Contract_End_Date, 'mm/dd/yyyy')>

				<CFSET newSD = DateFormat(form.start_date, 'mm/dd/yyyy')>
				<CFSET newED = DateFormat(form.end_date, 'mm/dd/yyyy')>

				<CFIF (oldSD NEQ newSD) OR (oldED NEQ newED)>
					<cfset useLakebaseForgetExclusionProgramID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_exclusions")>
<cfif useLakebaseForgetExclusionProgramID>
	<cftry>
		<cfset getExclusionProgramID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_exclusions", {
				"original_program_id" = "eq.#cryp.value#",
				"select" = "revision_program_id"
			}), "revision_program_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetExclusionProgramID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetExclusionProgramID>
<cfquery name="getExclusionProgramID" datasource="#application.datasource#">
						SELECT Revision_Program_ID
						 FROM Program_Exclusions
						 WHERE Original_Program_ID = '#cryp.value#'
					</cfquery>
</cfif>


					<cfquery name="deleteExclusionsAndPrograms" datasource="#application.datasource#">
						UPDATE Program_Exclusions
						SET Deleted = 1
						WHERE Original_Program_ID = '#cryp.value#'

						<cfif getExclusionProgramID.recordcount GT 0>
							UPDATE Contract_Main
							SET Deleted = 1
							WHERE Contract_Main_ID IN(#valueList(getExclusionProgramID.Revision_Program_ID)#)
						</cfif>
					</cfquery>
				</CFIF>

			<!--- (Start) - Reset Freight Approval, when the program dates have changed --->
				<cfset qryProgramInfo = objProgram.getProgramInfo(cryp.value)>

				<cfset Prog_Start_Date = qryProgramInfo.Contract_Start_Date>
				<cfset Prog_End_Date = qryProgramInfo.Contract_End_Date>
				<cfset Prog_Freight_Approved = qryProgramInfo.Freight_Approved>

				<cfset StartDateDayCount = datediff('d', Prog_Start_Date, form.Start_Date)>
				<cfset EndDateDayCount = datediff('d', Prog_End_Date, form.End_Date)>

				<cfif Prog_Freight_Approved eq 1>
					<cfif StartDateDayCount neq 0 OR EndDateDayCount neq 0>
						<cfset objProgramFreight.resetFreightApproval(cryp.value,request.AccessStructure.User_ID,'Reset Approval - Date Change')>
					</cfif>
				</cfif>
			<!--- (End) - Reset Freight Approval, when the program dates have changed --->

				<cfquery name="qGetProgramBeforeUpdateInfo" datasource="#application.datasource#">
					SELECT	DateDiff(d, Contract_Start_Date, Contract_End_Date) + 1 as Program_Span
					FROM	Contract_Main
					WHERE	Contract_Main_ID			=	'#cryp.value#'
				</cfquery>

				<cfquery name="UPDATETHETABLE" datasource="#application.datasource#">
					UPDATE contract_main
					SET
							Contract_Reference_Number	=	'#FORM.Contract_Reference_Number#', 
							Contract_Reference_Number_2=	'#FORM.Contract_Reference_Number_2#', <!--- 77539 --->
							Contract_Title			 	=	'#FORM.Contract_Title#',
							Contract_Start_Date			=	'#FORM.start_date#',
							Contract_End_Date			=	'#FORM.end_date#',
							Fiscal_Year						=	'#FORM.Fiscal_Year#',
							<!---Contract_Quantity			=	'#FORM.quantity#',--->
							Contract_Daily_Volume		=	'#DailyContractQuantity#',
							<!---Contract_Quantity_UOM_IDX	=	'#FORM.Contract_Quantity_UOM_IDX#',--->
							Fixed_Rebate_Amount			=	'#FORM.Fixed_Rebate_Amount#',
<!---						Discount_Type_ID			=	<CFIF FORM.FRA_GNFP EQ 1>1<CFELSEIF FORM.FRA_GNFP EQ 5>5<CFELSE>#FORM.DEV_FOB#</CFIF>, --->
							Dist_Brand_Eligibility		=	#FORM.Dist_Brand_Eligibility#,
							Notes						=	'#Form.Notes#',
							Editor_ID 					=	'#request.AccessStructure.User_ID#',
							PaymentCycle				= 	#FORM.PaymentCycle#,
							ProgramType					= 	'#FORM.Created_Type#',
							ProgramType_ID				=	'#FORM.ProgramType_ID#',
							chkClaimPerfReq_1			=	0,
							chkClaimPerfReq_2			=	0,
							chkClaimPerfReq_3			=	0,
							chkClaimPerfReq_4			=	0,
							chkClaimPerfReq_5			=	0,
							chkClaimPerfReq_6			=	0,
							chkClaimPerfReq_7			=	0,
							chkClaimPerfReq_8			=	0,
							chkClaimPerfReq_9			=	0,
							Auto_Renew					=	'#FORM.Auto_Renew#',
							ClaimMechanics				=	'#FORM.ClaimMechOption#',
							BldUpInvoice				=	'#FORM.ClaimMechOptionsBUI#',
							Controllable_Volume			=	'#FORM.Controllable_Flag#',
							Growth_Inclusion			=	'#FORM.Growth_Inclusion_Flag#',
							GL_Assignment				=	#FORM.GL_Assignment_ID#,
							Adv_Spending_Amount			=	'#FORM.Adv_Spend_Amount#',
							Pullback_From_This_Program  =   '#Form.Pullback_From_This_Program#',
							Responsible_User_Id          =   '#FORM.Responsible_User_Id#',
							Date_Method					=		#form.Date_Method#,
							Is_Awarded					=		#form.Is_Awarded#
							<cfif editBidId>
							,BID_NUMBER					=	'#form.bid_id#'
							</cfif>
							<cfif appSettings.getSearchSequenceOn() EQ 1>
							,Search_Sequence_ID = '#form.Search_Sequence_ID#'
							</cfif>
							<cfif appSettings.getBrokerTradeQuestOn() EQ 1>
							,Affect_Broker_Commission = '#form.Affect_Broker_Commission#'
							,Affect_Broker_Commission_Type = '#form.Affect_Broker_Commission_Type#'
							,Affect_Shelter = '#form.Affect_Shelter#'
							,Affect_Shelter_Type = '#form.Affect_Shelter_Type#'
							</cfif>
							<cfif appSettings.getModify_Legacy_ID() EQ 1>
							,Legacy_Deal_ID = '#LegacyDealID#'
							</cfif>
							<!--- removed Clay-budget
							<cfif len(form.selectedBudget) GT 0
							  AND appSettings.getBudgetsOn()
							  AND appSettings.getSelectBudgetsOn() EQ 1
							  AND appSettings.getBudgetRelationshipToPrograms() EQ 1>
							, budget_reference_id=#form.selectedBudget#</cfif> --->
							,Performance_Start_Date = <cfqueryparam cfsqltype="cf_sql_date" value="#Form.Performance_Start_Date#" null="#Is_Performance_Date_Null#"/>
						    ,Performance_End_Date = <cfqueryparam cfsqltype="cf_sql_date" value="#Form.Performance_End_Date#" null="#Is_Performance_Date_Null#"/>
						  	,Currency = <cfqueryparam cfsqltype="cf_sql_integer" value="#Form.Currency#" />
							,Effective_Date_for_Price = <cfqueryparam cfsqltype="cf_sql_date" value="#Form.Effective_Date_for_Price#" null="#Effective_Date_for_Price_Null#"/>
							,Currency_conversion_factor = <cfif form.currency_conversion_factor eq "">NULL<cfelse><cfqueryparam cfsqltype="cf_sql_decimal" value="#form.currency_conversion_factor#" scale="#scale.currency_conversion_factor#"></cfif>     <!---34302--->
							,contract_period_start_date = <cfqueryparam cfsqltype="cf_sql_date" value="#Form.contract_period_start_date#" null="#Contract_period_start_date_Null#"/>
							,contract_period_end_date = <cfqueryparam cfsqltype="cf_sql_date" value="#Form.contract_period_end_date#" null="#Contract_period_end_date_Null#"/>
							,Best_Plan_Program = <cfqueryparam value="#form.Best_Plan_Program#" cfsqltype="cf_sql_bit" /><!---60308 --->
							,Is_Blanket_Bid = <cfqueryparam value="#form.Is_Blanket_Bid#" cfsqltype="cf_sql_bit" />
							
							,Business_Segment_ID = #form.Business_Segment_ID#
							,Planner_Perf_Type_ID = #form.Planner_Perf_Types_ID#
					WHERE
							Contract_Main_ID			=	'#cryp.value#'
				</cfquery>

				<cfset ProductGroupManager.updateOtherAvgProductVolume(cryp.value) />

				<!--- 5.1. Update contract_main with volume based on current span  --->
				<!--- Update program_product_volume to have atleast 1 CS if the new span is smaller than old span --->
				<cfset Verify_Product_Volume = 0 />
				<cfif qGetProgramBeforeUpdateInfo.Program_Span GT (DateDiff("d", FORM.Start_Date, FORM.End_Date) + 1)>
					<cfset Verify_Product_Volume = 1 />
				</cfif>
				<CFSTOREDPROC PROCEDURE="Update_Contract_Quantity" datasource="#application.datasource#">
					<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_INTEGER "	DBVARNAME="@Contract_Main_ID"		VALUE="#cryp.value#">
					<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_INTEGER "	DBVARNAME="@Verify_Product_Volume"	VALUE="#Verify_Product_Volume#">
				</CFSTOREDPROC>

				<!---Add performance requirements--->	
		<!---71858 Perm Req Enh V2 - Search bar within Lists, & Min. Requirement on each List START--->
		<cfset qryProgramInfo = objProgram.PerformanceRequirements(templateID=#Form.ProgramType_ID#,contractMainID=#cryp.value#,Form=#form#)>
		<!---71858 Perm Req Enh V2 - Search bar within Lists, & Min. Requirement on each List END--->
						
			  <cfquery name="DeletePrior" datasource="#application.datasource#">
					DELETE FROM One_Program_Perf_Mapping
					WHERE Contract_Main_ID = '#cryp.value#'
					AND Program_Perf_Req_ID in (<cfqueryparam value="#PerfRequirements#" cfsqltype="CF_SQL_INTEGER" list="true"/>)
				</cfquery>

				<cfloop index = "Requirement" list = "#PerfRequirements#"  delimiterS = ",">
					<cfoutput>
					<cfparam name="form.PerfReq_Category_#Requirement#" 	default="0" />
					<cfparam name="form.PerfReq_Priority_#Requirement#" 	default="0" />
					<cfparam name="form.PerfReq_Start_Date_#Requirement#" 	default="" />
					<cfparam name="form.PerfReq_End_Date_#Requirement#" 	default="" />
					</cfoutput>
					<cfquery name="InsertPerfReq" datasource="#application.datasource#">
						INSERT INTO One_Program_Perf_Mapping(
							Contract_Main_ID,
							Program_Perf_Req_ID,
							Operator_Category_ID,
							Operator_Priority_ID,
							PR_Start_Date,
							PR_End_Date,
							Checked
						)VALUES(
							<cfqueryparam value="#cryp.value#" cfsqltype="CF_SQL_INTEGER" />,
							<cfqueryparam value="#Requirement#" cfsqltype="CF_SQL_INTEGER" />,
							<cfqueryparam value="#evaluate("form.PerfReq_Category_#Requirement#")#" cfsqltype="CF_SQL_INTEGER" />,
							<cfqueryparam value="#evaluate("form.PerfReq_Priority_#Requirement#")#" cfsqltype="CF_SQL_INTEGER" />,
							<cfqueryparam value="#evaluate("form.PerfReq_Start_Date_#Requirement#")#" cfsqltype="CF_SQL_DATE" />,
							<cfqueryparam value="#evaluate("form.PerfReq_End_Date_#Requirement#")#" cfsqltype="CF_SQL_DATE" />,
							<cfqueryparam value="1" cfsqltype="cf_sql_bit" />
						)
					</cfquery>
				</cfloop>

				<cfloop index = "NoRequirement" list = "#NoPerfRequirements#"  delimiterS = ",">
					<cfquery name="InsertPerfReq" datasource="#application.datasource#">
					INSERT INTO One_Program_Perf_Mapping(
						Contract_Main_ID,
						Program_Perf_Req_ID,
						checked
					)VALUES(
						'#cryp.value#',
						#NoRequirement#,
						0
					)
					</cfquery>
				</cfloop>
				<!------ Save Operating Groups for this program ----->
				<cfif appSettings.getOperatingGroupOn()>
					<cfset operatingGroupManager 			= CreateObject("component", "components.Operating_Group.OperatingGroupManager").init() />
					<cfif operatingGroupManager.enableEditAtProgramLevel()>
						<cfparam name="form.Operating_Group_1" 	default="0">
						<cfparam name="form.Operating_Group_2" 	default="0">
						<cfset operatingGroupManager.updateOperatingGroupProgram(id=form.Operating_Group_1, level=1, programId=cryp.value) />
						<cfset operatingGroupManager.updateOperatingGroupProgram(id=form.Operating_Group_2, level=2, programId=cryp.value) />
					</cfif>
				</cfif>

				<!--- save comments --->
				<cfquery name="recordCheck" datasource="#Application.Datasource#">
					SELECT Contract_Main_ID
					FROM Contract_Main_Aux_Data
					WHERE Contract_Main_ID = '#cryp.value#'
				</cfquery>
				<CFIF recordCheck.recordcount EQ 0>
					<cfquery name="insertRecord" datasource="#Application.Datasource#">
						INSERT INTO Contract_Main_Aux_Data
						(Contract_Main_ID)
						VALUES
						('#cryp.value#')
					</cfquery>
				</CFIF>
				<cfquery name="saveAuxData" datasource="#Application.Datasource#">
					UPDATE Contract_Main_Aux_Data
					SET <cfif form.Comments neq "">Comments = '#Form.Comments#',</cfif>
					<cfif form.Competitive_Info_Notes neq "">Competitive_Info_Notes = '#Form.Competitive_Info_Notes#',</cfif>
					Like_Product_Exist = '#Form.Like_Product_Exist#',
					Pay_To_Distributor = '#FORM.Pay_To_Distributor#',
					Payable_Company = '#FORM.Payable_Company#',
					Payable_Attention = '#FORM.Payable_Attention#',
					Payable_Address_1 = '#FORM.Payable_Address_1#',
					Payable_Address_2 = '#FORM.Payable_Address_2#',
					Payable_City	  = '#FORM.Payable_City#',
					Payable_State	  = '#FORM.Payable_State#',
					Payable_Zip		  =	'#FORM.Payable_Zip#',
					Send_To_Broker	  = '#FORM.Send_To_Broker#',
					Send_Company 	  = '#FORM.Send_Company#',
					Send_Attention 	  = '#FORM.Send_Attention#',
					Send_Address_1    = '#FORM.Send_Address_1#',
					Send_Address_2    = '#FORM.Send_Address_2#',
					Send_City	      = '#FORM.Send_City#',
					Send_State	      = '#FORM.Send_State#',
					Send_Zip		  =	'#FORM.Send_Zip#',
					<cfif appSettings.getUse_Accounting_Program_Type() EQ 1>
					Accounting_Program_Type_ID = '#Form.Accounting_Program_Type_ID#',
					</cfif>
					<cfif appSettings.getProgramCategory() EQ 1>
					Program_Category_ID = '#Form.Program_Category_ID#',
					</cfif>
					Equipment_Placement = '#FORM.Equipment_Placement#',
					Equipment_Placement_Note = '#Trim(FORM.Equipment_Placement_Note)#',
					Payable_Comments  = '#FORM.Payable_Comments#'
					,Alternate_Payment_Recipient = <cfif len(FORM.Operator_List)>#trim(FORM.Operator_List)#<cfelse>NULL</cfif><!--- D38189::Alternate Payment Recipient --->
					,Program_Start_Zero = #FORM.Program_Start_Zero# <!--- D38942 :: Program Blackout Period on Frontend--->
					,Program_Future_zero = #FORM.Program_Future_zero#<!--- D38942 :: Program Blackout Period on Frontend--->
					,Program_Most_Favored_Nation = '#form.Program_Most_Favored_Nation#'<!---42349--->
					WHERE Contract_Main_ID = '#cryp.value#'
				</cfquery>
				<!--- END comments --->

				<!---TSF: Modification Bid Request--->
				<!---FILTER: if the template type is Bid Request then insert data for Bid Request--->
			 	<cfset getTemplateName = CreateObject("component", "components.programs.template.TemplateManager").get(form.ProgramType_ID) />

				<!---create an instance of BidRequestManager--->
				<cfset bidRequestManager = CreateObject("component", "components.programs.bid_request.BidRequestManager") />

				<!--- If the user selected the "other" from Competitor Source and the "Other Competitor Source" textbox is not blank --->
				<cfif form.CompetitorSourceID eq -1 AND form.CompetitorSourceOther neq "">
					<!--- Either Insert a new source or update an existing source. These sources have an "Inactive" status. --->
					<cfset bidRequestSourceOtherID = bidRequestManager.updProgramBidSourceOther(form.CompetitorSourceOtherID,form.CompetitorSourceOther,form.CompetitorSourceOther,0)>
					<!--- Set :"form.CompetitorSourceID" to either the new Source ID generated OR an existing one to be updated --->
					<cfset form.CompetitorSourceID = bidRequestSourceOtherID>
				</cfif>

				<cfif getTemplateSettings.BidRequestStatusOn eq 1>
					<cfparam name="form.Line_Item" default="0" />
					<cfset bidRequestObj = bidRequestManager.setBidRequest(bidRequestId = form.Program_Bid_Request_ID, programId = cryp.value, openDate = form.Open_Date, dateNeeded = form.Date_Needed, expectedReplyDate = form.Expected_Reply_Date, lineItem = form.Line_Item, openTime = form.Open_Time, sourceID = form.CompetitorSourceID, sourceType = form.CompetitorSourceType) />
				<cfelse>
					<cfset bidRequestObj = bidRequestManager.setBidRequest(bidRequestId = form.Program_Bid_Request_ID, programId = cryp.value, openDate = form.Open_Date, dateNeeded = form.Date_Needed, expectedReplyDate = form.Expected_Reply_Date, openTime = form.Open_Time, sourceID = form.CompetitorSourceID, sourceType = form.CompetitorSourceType) />
				</cfif>
				<cfset bidRequestManager.saveBidRequest(bidRequestObj, 1) />

				<CFLOCATION url="redirect.cfm?destination=contract_edit_menu.cfm&CID=#FORM.CID#">

			</CFCASE>
		</CFSWITCH>
	</CFCASE>


	<!---  --->
	<CFCASE value="SELECT_PRODUCTS">
		<CFSWITCH expression="#FORM.Query_Type#">
			<CFCASE value="INSERT">
				<CFQUERY NAME="insert" datasource="#application.datasource#">
					SET NOCOUNT ON
					INSERT INTO Contract_Main
					(
						Contract_Number,
						Contract_Reference_Number,
						Contract_Reference_Number_2,<!--- 77539 --->
						Contract_Title,
						Contract_Start_Date,
						Contract_End_Date,
						Contract_Quantity,
						Contract_Quantity_UOM_IDX,
						Discount_Type_ID,
						Dist_Brand_Eligibility,
						Deleted,
						contract_status_type_IDX,
						fixed_rebate_amount,
						Author_ID,
						Owner_Company_ID
					)
					VALUES
					(
						'#FORM.Contract_Number#',
						'#FORM.Contract_Reference_Number#',
						'#FORM.Contract_Reference_Number_2#',<!--- 77539 --->
						'#FORM.Contract_Title#',
						'#FORM.start_date#',
						'#FORM.end_date#',
						'#FORM.Quantity#',
						'#FORM.Contract_Quantity_UOM_IDX#',
						<CFIF FORM.FRA_GNFP EQ 1>1<CFELSE>'#FORM.DEV_FOB#'</CFIF>,
						#FORM.Dist_Brand_Eligibility#,
						0,
						1,
						'#FORM.fixed_rebate_amount#',
						'#request.AccessStructure.User_ID#',
						'#request.AccessStructure.Company_Main_ID#'
					)
					SELECT Contract_Main_ID = @@IDENTITY
					SET NOCOUNT OFF
				</CFQUERY>

				<CFSET redirector_Program_ID = Form.ProgramType_ID>
				<CFSET redirector_FromPage_ID = 5>
				<cfinclude template="internal_redirector_based_on_settings.cfm">

				<CFLOCATION url="redirect.cfm?destination=#redirector_NextLocation#&ID=#insert.Contract_Main_ID#">

				<!--- <CFLOCATION url="redirect.cfm?destination=select_Products.cfm&ID=#insert.Contract_Main_ID#"> --->

			</CFCASE>

			<CFCASE value="update">
				<cfquery name="UPDATE" datasource="#application.datasource#">
					UPDATE Contract_Main
					SET
							Contract_Reference_Number	=	'#FORM.Contract_Reference_Number#',
							Contract_Reference_Number_2	=	'#FORM.Contract_Reference_Number_2#',<!--- 77539 --->
							Contract_Title			 	=	'#FORM.Contract_Title#',
							Contract_Start_Date			=	'#FORM.start_date#',
							Contract_End_Date			=	'#FORM.end_date#',
							Fiscal_Year						=	'#FORM.Fiscal_Year#',
							Contract_Quantity			=	'#FORM.quantity#',
							Contract_Quantity_UOM_IDX	=	'#FORM.Contract_Quantity_UOM_IDX#',
							Fixed_Rebate_Amount			=	'#FORM.Fixed_Rebate_Amount#',
							Discount_Type_ID			=	'<CFIF FORM.FRA_GNFP EQ 1>1<CFELSE>#FORM.DEV_FOB#</CFIF>',
							Dist_Brand_Eligibility		=	#FORM.Dist_Brand_Eligibility#
					WHERE
							Contract_Main_ID			=	'#FORM.Contract_Main_ID#'
				</cfquery>

				<CFSET redirector_Program_ID = Form.ProgramType_ID>
				<CFSET redirector_FromPage_ID = 5>
				<cfinclude template="internal_redirector_based_on_settings.cfm">

				<CFLOCATION url="redirect.cfm?destination=#redirector_NextLocation#&ID=#insert.Contract_Main_ID#">

				<!--- <CFLOCATION url="redirect.cfm?destination=select_Products.cfm&ID=#FORM.Contract_Main_ID#"> --->

			</CFCASE>
		</CFSWITCH>
	</CFCASE>
<CFDEFAULTCASE>

</CFDEFAULTCASE>
</CFSWITCH>


<!--- ******************************************************************************* --->
<!--- *************************** COPY / REVISE - START ***************************** --->
<!--- ******************************************************************************* --->
<CFIF FORM.Do_Revise_Copy NEQ 0 AND Form.Program_ID_To_Replicate NEQ 0><!--- EZ Button: on create will not add the products to the program --->
	<!---
	D22578: CAG - mass copy a program
	1. Get Parent Info
	2. If revision already exists, redirect
	3. Set legacy deal id
	4. Call routine USP_Copy_Program to make a copy of the program
	5. Update contract_main with data from basic info page
	6. Save performance requirements from basic info page
	7. Update contract_main_aux_data with data from basic info page
	8. Reset freight approval if dates have changed
	9. Save auto renew based on data from basic info page
	10. Formula - generate prices
	11. Market Price - Update fixed price rates with current MP rates (if necessary)
	12. Lock the program
	13. Redirect to view program page
	--->

	<cfif Scheduled NEQ 0>

		<cfset This_User_Position_ID = User_Position_ID>

	</cfif>

	<CFSET FORM.Renewal_Of_Contract_Main_ID = Form.Program_ID_To_Replicate />

	<!--- 1. Get Parent Info --->
	<cfquery name="qGetParentInfo" datasource="#application.datasource#">
		SELECT 	Contract_Main.Contract_Main_ID, Parent_Revised_Contract_Main_ID, applied_pullbacks, Pullback_From_This_Program, Forecast_ID,
				Contract_Main.LEGACY_DEAL_ID,Contract_Start_Date,Contract_End_Date,
				Contract_Main_Aux_Data.Forecast_ID
		FROM 	Contract_Main
		INNER JOIN Contract_Main_Aux_Data ON Contract_Main_Aux_Data.Contract_Main_ID = Contract_Main.Contract_Main_ID
		WHERE 	Contract_Main.Contract_Main_ID = '#Form.Program_ID_To_Replicate#'
		AND 	Contract_Main.Deleted = 0
	</cfquery>


<!--- D30233: Today's Price vs Requested Price START --->

<cfif appSettings.getUseFixedPriceType()>

	<cfset Current_Start_date = #qGetParentInfo.Contract_Start_Date#>


</cfif>

<!--- D30233: Today's Price vs Requested Price END --->


	<!---  contract is a revision so do some required work --->
	<CFIF FORM.ISREVISIONOFEXISTINGCONTRACT EQ 1>
		<!--- Dev Note: 12962; Milan (In a rare case, two people can sometimes edit/create at the same time
					while revising a program. If that's the case, take the user to the original revised program.) --->
		<cfquery name="getExistingRevision" datasource="#application.datasource#">
			SELECT Contract_Main_ID
			FROM Contract_Main
			WHERE Revision_of_Contract_Main_ID = '#Form.Program_ID_To_Replicate#'
			AND Deleted = 0
			<!---
			D26803: Revise Active/Pre-active PGM's
			When app switch "Revise Active Programs when Pre Active Exists" is ON it is ok to let user revise a version which already has approved revisions
			But a program cannot have more than one non-approved revision at a time.
			--->
			<cfif appSettings.getAllowReviseActiveWithPreActive()>
			AND Approved = 0
			</cfif>
		</cfquery>

		<!--- 2. If revision already exists, redirect --->
		<!--- Dev Note: KAL; D13777: Mass Price Change - To skip the redirect when auto-revising for preactive programs --->
		<cfif getExistingRevision.Recordcount neq 0 and form.IsAutoRevision neq 1>
			<CF_CRYP type="en" string="#getExistingRevision.Contract_Main_ID#" key="#request.key#">
			<CFLOCATION url="/common_files/contracts/contract_edit_menu.cfm?CID=#cryp.value#">
		</cfif>

		<cfif  qGetParentInfo.Parent_Revised_Contract_Main_ID EQ "">
			<CFSET FORM.Parent_Revised_Contract_Main_ID = qGetParentInfo.Contract_Main_ID>
		<CFELSE>
			<CFSET FORM.Parent_Revised_Contract_Main_ID = qGetParentInfo.Parent_Revised_Contract_Main_ID>
		</CFIF>

		<CFSET FORM.Revision_of_Contract_Main_ID = Form.Program_ID_To_Replicate />

		<cfif Form.IsRevisionOfExistingContract EQ 1>
			<CFSET FORM.applied_pullbacks = qGetParentInfo.applied_pullbacks />
		</cfif>
		<cfif (isDefined("qGetParentInfo.Pullback_From_This_Program") AND qGetParentInfo.Pullback_From_This_Program NEQ "")>
			<CFSET FORM.Pullback_From_This_Program = qGetParentInfo.Pullback_From_This_Program />
		</cfif>
	</CFIF>

	<!--- 3. Set legacy deal id	--->
	<CFIF appSettings.getModify_Legacy_ID() EQ 0>
		<CFIF FORM.ISREVISIONOFEXISTINGCONTRACT EQ 1>
			<cfset LegacyDealID = qGetParentInfo.LEGACY_DEAL_ID />
		<CFELSE>
			<cfset LegacyDealID = "" />
		</CFIF>
	</CFIF>

	<cfparam name="form.bIsFromTradePlan" 	default="0">

	<!------ Copy the forecast data ----->
	<!--- Below is outside the trasaction as nested trasaction is not allowed --->
	<CFSET objVolumeApplicator = CreateObject("component", "components.volume.VolumeApplicator")>
	<CFSET New_Forecast_ID = objVolumeApplicator.copyForecast(qGetParentInfo.Forecast_ID)>

	<CFTRANSACTION ACTION="BEGIN">

		<!--- 4. Call routine USP_Copy_Program to make a copy of the program --->
		<!--- call the routine to make an exact copy (or revise) of the program ---->
		<CFSTOREDPROC PROCEDURE="USP_Copy_Program" datasource="#application.datasource#">
			<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_INTEGER "	DBVARNAME="@Program_ID_To_Replicate"		VALUE="#Form.Program_ID_To_Replicate#">
			<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_VARCHAR "	DBVARNAME="@New_Contract_Number"			VALUE="#Form.Contract_Number#">
			<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@IsRevisionOfExistingContract"	VALUE="#FORM.ISREVISIONOFEXISTINGCONTRACT#">
			<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@ISROLLOVER"						VALUE="#FORM.ISRollOver#">
			<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@ForceFreightOnAutoCopy"			VALUE="#FORM.ForceFreightOnAutoCopy#">
			<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_INTEGER"	DBVARNAME="@User_Position_ID"				VALUE="#This_User_Position_ID#">
			<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_VARCHAR"	DBVARNAME="@Responsible_User_ID"			VALUE="#Form.Responsible_User_ID#">
			<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_VARCHAR"	DBVARNAME="@Current_User_ID"				VALUE="#request.AccessStructure.User_ID#">
			<CFPROCPARAM TYPE="Out"	CFSQLTYPE="CF_SQL_INTEGER"	DBVARNAME="@Contract_Main_ID"				VARIABLE="Renewed_Program_ID">
			<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@Is_Mass_Copy"					VALUE="0">
			<CFPROCPARAM TYPE="Out"	CFSQLTYPE="CF_SQL_INTEGER"	DBVARNAME="@Is_Group_Deal"					VARIABLE="Is_Group_Deal">
			<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@From_EZ_Template"				VALUE="0">
			<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@Is_AutoRenew"				   VALUE="0">
			<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_INTEGER"	DBVARNAME="@Copy_To_Planner_ID"		        VALUE="0">
			<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_DATE"	     DBVARNAME="@New_Start_Date"		        VALUE="#dateformat(FORM.start_date, 'm/d/yyyy')#">
			<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_DATE"	     DBVARNAME="@New_End_Date"		        VALUE="#dateformat(FORM.end_date, 'm/d/yyyy')#">
		</CFSTOREDPROC>

		<cfquery name="qGetProgramBeforeUpdateInfo" datasource="#application.datasource#">
			SELECT	DateDiff(d, Contract_Start_Date, Contract_End_Date) + 1 as Program_Span
			FROM	Contract_Main
			WHERE	Contract_Main_ID			=	<cfqueryparam cfsqltype="cf_sql_integer" value="#Renewed_Program_ID#" />
		</cfquery>
<!--- D30233: Today's Price vs Requested Price START --->
<cfif appSettings.getUseFixedPriceType()>

	<cfset New_Start_date = #dateformat(FORM.start_date, 'm/d/yyyy')#>
	<cfset New_End_date = #dateformat(FORM.end_date, 'm/d/yyyy')#>

	<cfif DateDiff("d", Current_Start_date, New_Start_date)>
		<cfscript>
			objProgram.setprice(
									Contract_Main_ID = #Renewed_Program_ID#
								);
		</cfscript>
	</cfif>

</cfif>
<!--- If it has a formula Component, Run the Calc --->
<cfscript>
	oFormula    = CreateObject("component", "mvc.Models.Program.Component.Formula");
	q = oFormula.getProgramFormulaComponent(#Renewed_Program_ID#);
</cfscript>
<!--- If it has a formula Component, Run the Calc --->
<CFIF appSettings.get_Setting('Formula_Price_Item_Level_Config',0) EQ 0>
	<cfscript>	
		if(q.Formula_Pricing == 1){
			//create a new storedproc service
		    spService = new storedproc();
		    //set attributes using implicit setters
		    spService.setDatasource("#application.datasource#");
		    spService.setProcedure("Formula_Price_Calculation");
		    //add procparams using addParam
		    spService.addParam(cfsqltype="cf_sql_numeric", type="in",value=Renewed_Program_ID);
		    //execute the stored procedure
		    result = spService.execute();
		}
	</cfscript>
<cfelseif appSettings.get_Setting('Formula_Price_Item_Level_Config',0) EQ 1 AND q.Formula_Pricing EQ 1>
    
	<!--- Handling for retroactive dates for this client --->
	<cfif appSettings.get_setting('Margin_Display_Style') EQ "CUSTOM_T">

	   <cfquery name="qGetContractStart" datasource="#application.datasource#">
	       select	Contract_Start_Date, Formula_Price_Rebate_Type as Schedule_ID
	       from	Contract_Main
	       where 	Contract_Main_ID = '#Renewed_Program_ID#'
	   </cfquery>

	   <cfset formulaCalcProcessDate = CreateObject("component", "mvc.Models.Program.FormulaItemLevel").getRetroactiveCalcProcDate(qGetContractStart.Contract_Start_Date, Val(qGetContractStart.Schedule_ID), '') />

	<cfelse>
	   <cfset formulaCalcProcessDate = "NULL" />
	</cfif>

	<cfquery name="recalcFormulaItemLevel" datasource="#application.datasource#">
			DECLARE 
			@tmp_Program_Formula_Pricing_Rule_ID uniqueidentifier,
			@price_date date = getDate()
			
			<cfif formulaCalcProcessDate NEQ "NULL">
				SET @price_date = '#DateFormat(formulaCalcProcessDate, "mm/dd/yyyy")#'
			</cfif>

			DECLARE tmp_cursor_Calc CURSOR LOCAL STATIC FORWARD_ONLY READ_ONLY FOR 
			SELECT Program_Formula_Pricing_Rule_ID
			FROM Program_Formula_Pricing_Rules R
			WHERE R.Program_ID = #Renewed_Program_ID# AND
					Deleted = 0

			OPEN tmp_cursor_Calc

			FETCH NEXT FROM tmp_cursor_Calc 
			INTO @tmp_Program_Formula_Pricing_Rule_ID

			WHILE @@FETCH_STATUS = 0
			BEGIN
			--Do Something
			 EXEC Formula_Price_Item_Calculation @tmp_Program_Formula_Pricing_Rule_ID,@price_date

					-- Get the next tmp.
				FETCH NEXT FROM tmp_cursor_Calc 
				INTO @tmp_Program_Formula_Pricing_Rule_ID
			END 
			CLOSE tmp_cursor_Calc
			DEALLOCATE tmp_cursor_Calc
	</cfquery>
</CFIF>
<!--- Custom RFP Update price list (Stock Item Bracket) based on new revision dates. --->
<CFIF appSettings.get_Setting('Custom_RFP_Process',0) EQ 1 and getTemplateSettings.RFP_Process EQ 1 AND FORM.ISREVISIONOFEXISTINGCONTRACT EQ 1>
	<cfscript>
		variables.rfp = {};
		variables.rfp.rfpManager 		= 	CreateObject("component", "mvc.Models.Program.RfpManager");
		variables.rfp.bracketId			=	variables.rfp.rfpManager.getStockItemBracket(Renewed_Program_ID);
		variables.rfp.updBracket		= 	variables.rfp.rfpManager.updStockItemBracket(Renewed_Program_ID,variables.rfp.bracketId);
		variables.rfp = {};
	</cfscript>
</CFIF>

<!---<cfdump var ="#form#" output="c:\dump.log"  > --->
	<cfif FORM.Pullback_From_This_Program eq "">
		<cfset FORM.Pullback_From_This_Program = 0 />
	</cfif>
<!--- D30233: Today's Price vs Requested Price END --->
		<!--- 5. Update contract_main with data from basic info page --->
		<CFQUERY NAME="updContractMain" datasource="#application.datasource#">
			UPDATE	Contract_Main
			SET		Contract_Reference_Number 	= 	<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.Contract_Reference_Number#" />,
			Contract_Reference_Number_2 	= 	<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.Contract_Reference_Number_2#" />,<!--- 77539 --->
					Contract_Title 				= 	<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.Contract_Title#" />,
					Contract_Start_Date 		= 	<cfqueryparam cfsqltype="cf_sql_date" value="#dateformat(FORM.start_date, 'm/d/yyyy')#" />,
					Contract_End_Date			= 	<cfqueryparam cfsqltype="cf_sql_date" value="#dateformat(FORM.end_date, 'm/d/yyyy')#" />,
					Fiscal_Year			= 	<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.Fiscal_Year#" />,
					<!---Contract_Quantity			= 	<cfqueryparam cfsqltype="cf_sql_numeric" value="#FORM.Quantity#" />,--->
					Contract_Quantity_UOM_IDX	= 	<cfqueryparam cfsqltype="cf_sql_numeric" value="#FORM.Contract_Quantity_UOM_IDX#" />,
					Dist_Brand_Eligibility		=	<cfqueryparam cfsqltype="cf_sql_bit" value="#FORM.Dist_Brand_Eligibility#" />,
					Deleted						= 	0,
					Notes						=	<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.Notes#" />,

					Creator_ID 					=	<cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#" />,
					Editor_ID 					=	<cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#" />,
					PaymentCycle				= 	<cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.PaymentCycle#" />,
					ProgramType					= 	<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.Created_Type#" />,
					ProgramType_ID				=	<cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.ProgramType_ID#" />,
					chkClaimPerfReq_1			=	0,
					chkClaimPerfReq_2			=	0,
					chkClaimPerfReq_3			=	0,
					chkClaimPerfReq_4			=	0,
					chkClaimPerfReq_5			=	0,
					chkClaimPerfReq_6			=	0,
					chkClaimPerfReq_7			=	0,
					chkClaimPerfReq_8			=	0,
					chkClaimPerfReq_9			=	0,

					Auto_Renew					=	<cfqueryparam cfsqltype="cf_sql_bit" value="#FORM.Auto_Renew#" />,
					ClaimMechanics				=	<cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.ClaimMechOption#" />,
					BldUpInvoice				=	<cfqueryparam cfsqltype="cf_sql_bit" value="#FORM.ClaimMechOptionsBUI#" />,
					Controllable_Volume			=	<cfqueryparam cfsqltype="cf_sql_bit" value="#FORM.Controllable_Flag#" />,
					Growth_Inclusion			=	<cfqueryparam cfsqltype="cf_sql_bit" value="#FORM.Growth_Inclusion_Flag#" />,
					GL_Assignment				=	<cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.GL_Assignment_ID#" />,
					Pullback_From_This_Program  =   <cfqueryparam cfsqltype="cf_sql_bit" value="#FORM.Pullback_From_This_Program#" />,

					Responsible_User_Id         =   <cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.Responsible_User_Id#" />,
					Creating_User_Position_ID	=	<cfqueryparam cfsqltype="cf_sql_integer" value="#This_User_Position_ID#" />,

					Date_Method					=	<cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.Date_Method#" />,
					Is_Awarded					=	<cfqueryparam cfsqltype="cf_sql_bit" value="#FORM.Is_Awarded#" />,
					fixed_rebate_amount			=	<cfqueryparam cfsqltype="cf_sql_numeric" value="#FORM.fixed_rebate_amount#" />,
					Owner_Company_ID			=	<cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.Company_Main_ID#" />,

					Auto_Renewal_Fixed_Variable_Margin = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.Auto_Renewal_Fixed_Variable_Margin#" />,

					Contract_Daily_Volume 		= 	<cfqueryparam cfsqltype="cf_sql_numeric" value="#DailyContractQuantity#" />,
					Adv_Spending_Amount			=	<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.Adv_Spend_Amount#" />,
					On_Release_Contract_Status_Type_IDX	= <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.On_Release_Contract_Status_Type_IDX#" />,
					Business_Segment_ID			=	<cfqueryparam cfsqltype="cf_sql_integer" value="#listFirst(FORM.Business_Segment_ID)#" />,
					Line_Of_Business_ID			=	<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.LOB_ID#" null="#NOT isNumeric(form.LOB_ID)#" />,

					<cfif editBidId>
					BID_NUMBER					=	<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.bid_id#" />,
					</cfif>

					<cfif appSettings.getSearchSequenceOn() EQ 1>
					Search_Sequence_ID			=	<cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.Search_Sequence_ID#" />,
					</cfif>

					Legacy_Deal_ID				=	<cfqueryparam cfsqltype="cf_sql_varchar" value="#LegacyDealID#" />,

					<cfif FORM.ISRollOver eq 1>
						<!--- If FORM.ISRollOver = 0 retain the value in the field Rollover_from_Contract_Main_ID --->
					Rollover_from_Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.Renewal_Of_Contract_Main_ID#" />,
					</cfif>

					<CFIF FORM.ISREVISIONOFEXISTINGCONTRACT EQ 0 and not form.bIsFromTradePlan>
					Renewal_Of_Contract_Main_ID = 	<cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.Renewal_Of_Contract_Main_ID#" />,
					IsRollOver					=	<cfqueryparam cfsqltype="cf_sql_bit" value="#FORM.ISRollOver#" />,
					<CFELSEIF isDefined("form.bIsFromTradePlan") and form.bIsFromTradePlan>
					Trade_Plan_Id				=	<cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.tradePlanId#" />,
					isFromTradePlan				=	<cfqueryparam cfsqltype="cf_sql_bit" value="#FORM.bIsFromTradePlan#" />,
					<CFELSE>
					Parent_Revised_Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.Parent_Revised_Contract_Main_ID#" />,
					Revision_of_Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.Revision_of_Contract_Main_ID#" />,
					Is_A_Revision				=	<cfqueryparam cfsqltype="cf_sql_bit" value="#FORM.ISREVISIONOFEXISTINGCONTRACT#" />,
					Is_Manual_Revision 			=	<cfqueryparam cfsqltype="cf_sql_bit" value="#FORM.ISREVISIONOFEXISTINGCONTRACT#" />,
					</CFIF>
					Limited_Revise				=    <cfqueryparam cfsqltype="cf_sql_bit" value="#FORM.Limited_Revise#" />,
					check_program_uom			=		<cfqueryparam cfsqltype="cf_sql_bit" value="#FORM.check_program_uom#" />,
					applied_pullbacks			=	<cfqueryparam cfsqltype="cf_sql_bit" value="#FORM.applied_pullbacks#" />,
					<cfif appSettings.getBrokerTradeQuestOn() EQ 1>
					Affect_Broker_Commission	=	<cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.Affect_Broker_Commission#" />,
					Affect_Broker_Commission_Type = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.Affect_Broker_Commission_Type#" />,
					Affect_Shelter				=	<cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.Affect_Shelter#" />,
					Affect_Shelter_Type			=	<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.Affect_Shelter_Type#" />,
					</cfif>

					Performance_Start_Date		=	<cfqueryparam cfsqltype="cf_sql_date" value="#Form.Performance_Start_Date#" null="#Is_Performance_Date_Null#" />,
					Performance_End_Date		=	<cfqueryparam cfsqltype="cf_sql_date" value="#Form.Performance_End_Date#" null="#Is_Performance_Date_Null#" />,
					Currency					=	<cfqueryparam cfsqltype="cf_sql_integer" value="#Form.Currency#" />,
					Effective_Date_for_Price	= 	<cfqueryparam cfsqltype="cf_sql_date" value="#Form.Effective_Date_for_Price#" null="#Effective_Date_for_Price_Null#"/>,
					Currency_conversion_factor = <cfif form.currency_conversion_factor eq "">NULL<cfelse><cfqueryparam cfsqltype="cf_sql_decimal" value="#form.currency_conversion_factor#" scale="#scale.currency_conversion_factor#"></cfif>,     <!---34302--->
					contract_period_start_date = <cfqueryparam cfsqltype="cf_sql_date" value="#Form.contract_period_start_date#" null="#Contract_period_start_date_Null#"/>,
					contract_period_end_date = <cfqueryparam cfsqltype="cf_sql_date" value="#Form.contract_period_end_date#" null="#Contract_period_end_date_Null#"/>,
					Best_Plan_Program = <cfqueryparam value="#form.Best_Plan_Program#" cfsqltype="cf_sql_bit" />,<!---60308 --->
					Is_Blanket_Bid = <cfqueryparam value="#form.Is_Blanket_Bid#" cfsqltype="cf_sql_bit" />
					
			WHERE	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Renewed_Program_ID#" />
		</CFQUERY>

		<!---create an instance of BidRequestManager--->
		<cfset bidRequestManager = CreateObject("component", "components.programs.bid_request.BidRequestManager") />

		<!--- If the user selected the "other" from Competitor Source and the "Other Competitor Source" textbox is not blank --->
		<cfif form.CompetitorSourceID eq -1 AND form.CompetitorSourceOther neq "">
			<!--- Either Insert a new source or update an existing source. These sources have an "Inactive" status. --->
			<cfset bidRequestSourceOtherID = bidRequestManager.updProgramBidSourceOther(form.CompetitorSourceOtherID,form.CompetitorSourceOther,form.CompetitorSourceOther,0)>
			<!--- Set :"form.CompetitorSourceID" to either the new Source ID generated OR an existing one to be updated --->
			<cfset form.CompetitorSourceID = bidRequestSourceOtherID>
		</cfif>

		<cfif getTemplateSettings.BidRequestStatusOn eq 1>
			<cfparam name="form.Line_Item" default="0" />
			<cfset bidRequestObj = bidRequestManager.setBidRequest(bidRequestId = form.Program_Bid_Request_ID, programId = Renewed_Program_ID, openDate = form.Open_Date, dateNeeded = form.Date_Needed, expectedReplyDate = form.Expected_Reply_Date, lineItem = form.Line_Item, openTime = form.Open_Time, sourceID = form.CompetitorSourceID, sourceType = form.CompetitorSourceType) />
		<cfelse>
			<cfset bidRequestObj = bidRequestManager.setBidRequest(bidRequestId = form.Program_Bid_Request_ID, programId = Renewed_Program_ID, openDate = form.Open_Date, dateNeeded = form.Date_Needed, expectedReplyDate = form.Expected_Reply_Date, openTime = form.Open_Time, sourceID = form.CompetitorSourceID, sourceType = form.CompetitorSourceType) />
		</cfif>
		<cfset bidRequestManager.saveBidRequest(bidRequestObj, 1) />

		<!------------ END Ana Dev Notes - D24851 - Bid program open dates not saving on copy --------------->


		<!--- 5.1. Update contract_main with volume based on current span  --->
		<!--- Update program_product_volume to have atleast 1 CS if the new span is smaller than old span --->
		<cfset Verify_Product_Volume = 0 />
		<cfif qGetProgramBeforeUpdateInfo.Program_Span GT (DateDiff("d", FORM.Start_Date, FORM.End_Date) + 1)>
			<cfset Verify_Product_Volume = 1 />
		</cfif>
		<CFSTOREDPROC PROCEDURE="Update_Contract_Quantity" datasource="#application.datasource#">
			<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_INTEGER "	DBVARNAME="@Contract_Main_ID"		VALUE="#Renewed_Program_ID#">
			<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_INTEGER "	DBVARNAME="@Verify_Product_Volume"	VALUE="#Verify_Product_Volume#">
		</CFSTOREDPROC>

		<!--- 6. Save performance requirements from basic info page --->
		<cfquery name="DeletePrior" datasource="#application.datasource#">
			DELETE FROM One_Program_Perf_Mapping
			WHERE Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Renewed_Program_ID#" />
		</cfquery>

		<!---71858 Perm Req Enh V2 - Search bar within Lists, & Min. Requirement on each List START--->
		<cfset qryProgramInfo = objProgram.PerformanceRequirements(templateID=#Form.ProgramType_ID#,contractMainID=#Renewed_Program_ID#,Form=#form#)>
		<!---71858 Perm Req Enh V2 - Search bar within Lists, & Min. Requirement on each List END--->				
				
		<cfloop index = "Requirement" list = "#PerfRequirements#"  delimiterS = ",">
			<cfoutput>
			<cfparam name="form.PerfReq_Category_#Requirement#" 	default="0" />
			<cfparam name="form.PerfReq_Priority_#Requirement#" 	default="0" />
			<cfparam name="form.PerfReq_Start_Date_#Requirement#" 	default="" />
			<cfparam name="form.PerfReq_End_Date_#Requirement#" 	default="" />
			#Requirement#C
			</cfoutput>
			<cfquery name="InsertPerfReq" datasource="#application.datasource#">
				INSERT INTO One_Program_Perf_Mapping
				(
					Contract_Main_ID,
					Program_Perf_Req_ID,
					Operator_Category_ID,
					Operator_Priority_ID,
					PR_Start_Date,
					PR_End_Date,
					Checked
				)
				VALUES
				(
					<cfqueryparam cfsqltype="cf_sql_integer" value="#Renewed_Program_ID#" />,
					<cfqueryparam value="#Requirement#" cfsqltype="CF_SQL_INTEGER" />,
					<cfqueryparam value="#evaluate("form.PerfReq_Category_#Requirement#")#" cfsqltype="CF_SQL_INTEGER" />,
					<cfqueryparam value="#evaluate("form.PerfReq_Priority_#Requirement#")#" cfsqltype="CF_SQL_INTEGER" />,
					<cfqueryparam value="#evaluate("form.PerfReq_Start_Date_#Requirement#")#" cfsqltype="CF_SQL_DATE" />,
					<cfqueryparam value="#evaluate("form.PerfReq_End_Date_#Requirement#")#" cfsqltype="CF_SQL_DATE" />,
					<cfqueryparam value="1" cfsqltype="cf_sql_bit" />
				)
			</cfquery>
		</cfloop>

		<cfloop index = "NoRequirement" list = "#NoPerfRequirements#"  delimiterS = ",">
			<cfoutput>#NoRequirement#C</cfoutput>
			<cfquery name="InsertPerfReq" datasource="#application.datasource#">
			INSERT INTO One_Program_Perf_Mapping
			(
				Contract_Main_ID,
				Program_Perf_Req_ID,
				checked
			)
			VALUES
			(
				'#Renewed_Program_ID#',
				#NoRequirement#,
				0
			)
			</cfquery>
		</cfloop>


		<!------ TODO: Save Operating Groups for this program ----->
		<!---
		<cfif appSettings.getOperatingGroupOn()>
			<cfparam name="form.Operating_Group_1" 	default="0">
			<cfparam name="form.Operating_Group_2" 	default="0">
			<cfset operatingGroupManager 			= CreateObject("component", "components.Operating_Group.OperatingGroupManager").init() />
			<cfset operatingGroupManager.updateOperatingGroupProgram(id=form.Operating_Group_1, level=1, programId=insert.Contract_Main_ID) />
			<cfset operatingGroupManager.updateOperatingGroupProgram(id=form.Operating_Group_2, level=2, programId=insert.Contract_Main_ID) />
		</cfif>
		--->

		<!--- 7. Update contract_main_aux_data with data from basic info page --->
		<cfquery name="saveAuxData" datasource="#Application.Datasource#">
			UPDATE Contract_Main_Aux_Data
			SET <cfif form.Comments neq "">Comments = '#Form.Comments#',</cfif>
				<cfif form.Competitive_Info_Notes neq "">Competitive_Info_Notes = '#Form.Competitive_Info_Notes#',</cfif>
				Like_Product_Exist = '#Form.Like_Product_Exist#',
				Forecast_ID = #New_Forecast_ID#,
				Pay_To_Distributor = '#FORM.Pay_To_Distributor#',
				Payable_Company = '#FORM.Payable_Company#',
				Payable_Attention = '#FORM.Payable_Attention#',
				Payable_Address_1 = '#FORM.Payable_Address_1#',
				Payable_Address_2 = '#FORM.Payable_Address_2#',
				Payable_City	  = '#FORM.Payable_City#',
				Payable_State	  = '#FORM.Payable_State#',
				Payable_Zip		  =	'#FORM.Payable_Zip#',
				Send_To_Broker	  = '#FORM.Send_To_Broker#',
				Send_Company 	  = '#FORM.Send_Company#',
				Send_Attention 	  = '#FORM.Send_Attention#',
				Send_Address_1    = '#FORM.Send_Address_1#',
				Send_Address_2    = '#FORM.Send_Address_2#',
				Send_City	      = '#FORM.Send_City#',
				Send_State	      = '#FORM.Send_State#',
				Send_Zip		  =	'#FORM.Send_Zip#',
				Equipment_Placement = '#FORM.Equipment_Placement#',
				Equipment_Placement_Note = '#Trim(FORM.Equipment_Placement_Note)#',
				<cfif appSettings.getUse_Accounting_Program_Type() EQ 1>
				Accounting_Program_Type_ID = '#Form.Accounting_Program_Type_ID#',
				</cfif>
				<cfif appSettings.getProgramCategory() EQ 1>
				Program_Category_ID = '#Form.Program_Category_ID#',
				</cfif>
				Payable_Comments  = '#FORM.Payable_Comments#'
				,Alternate_Payment_Recipient = #trim(FORM.Operator_List)#<!--- D38189::Alternate Payment Recipient --->
				,Program_Start_Zero = #FORM.Program_Start_Zero# <!--- D38942 :: Program Blackout Period on Frontend--->
				,Program_Future_zero = #FORM.Program_Future_zero#<!--- D38942 :: Program Blackout Period on Frontend--->
				,Program_Most_Favored_Nation = '#form.Program_Most_Favored_Nation#' <!--- 42349 --->
			WHERE Contract_Main_ID = '#Renewed_Program_ID#'


	<!---D60956 :: Version Specific Payment History: When prg is revised $ shows on new version with no payments START--->
	<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 0 AND FORM.ISREVISIONOFEXISTINGCONTRACT EQ 1>
				UPDATE CONTRACT_MAIN_AUX_DATA
				   SET Payment_History = ( CASE
				                             WHEN PAYMENT_HISTORY_DETAILS.Contract_Number IS NOT NULL THEN 1
				                             ELSE 0
				                           END )
				  FROM CONTRACT_MAIN
				       INNER JOIN CONTRACT_MAIN_AUX_DATA ON CONTRACT_MAIN_AUX_DATA.Contract_Main_Id = CONTRACT_MAIN.Contract_Main_Id
				       LEFT JOIN PAYMENT_HISTORY_DETAILS ON CONTRACT_MAIN.Contract_Number = PAYMENT_HISTORY_DETAILS.Contract_Number
				 WHERE CONTRACT_MAIN.Contract_Main_Id = '#Renewed_Program_ID#'
			</cfif>
	<!---D60956 :: Version Specific Payment History: When prg is revised $ shows on new version with no payments END--->
		</cfquery>


		<!--- 8. Reset freight approval if dates have changed --->
		<CFIF FORM.ISREVISIONOFEXISTINGCONTRACT EQ 1>

			<!--- (Start) - During creating revisions: Reset Freight Approval, when the program dates have changed --->
			<cfset qry_Parent_Program_Info = objProgram.getProgramInfo(Form.Program_ID_To_Replicate)>
			<cfset qry_Program_Info = objProgram.getProgramInfo('#Renewed_Program_ID#')>

			<!--- Get the parent program's dates --->
			<cfset Prog_Start_Date = qry_Parent_Program_Info.Contract_Start_Date>
			<cfset Prog_End_Date = qry_Parent_Program_Info.Contract_End_Date>

			<!--- Get the revised program's freight approval bit info --->
			<cfset Prog_Freight_Approved = qry_Program_Info.Freight_Approved>

			<cfset StartDateDayCount = datediff('d', Prog_Start_Date, form.Start_Date)>
			<cfset EndDateDayCount = datediff('d', Prog_End_Date, form.End_Date)>

			<cfif Prog_Freight_Approved eq 1>
				<cfif StartDateDayCount neq 0 OR EndDateDayCount neq 0>
					<cfset objProgramFreight.resetFreightApproval('#Renewed_Program_ID#',request.AccessStructure.User_ID,'Reset Approval - Date Change on Revision')>
				</cfif>
			</cfif>
		  <!--- (End) - During creating revisions: Reset Freight Approval, when the program dates have changed --->

		</CFIF>


		<CFIF FORM.ISREVISIONOFEXISTINGCONTRACT EQ 0>
			<cfset ParentCMID =  FORM.Renewal_Of_Contract_Main_ID>
		<CFELSE>
			<cfset ParentCMID = FORM.Revision_of_Contract_Main_ID>
		</CFIF>

		<!---  Auto Renew code for COPY / REVISE action --->
		<!--- Save Auto-Renewal Data --->

		<!--- 9. Save auto renew based on data from basic info page --->
		<cfif Form.Auto_Renew IS 1>

			<!----- check if we already have an entry in the auto renew queue table ----->
			<cfquery name="IsAutoRenewThere" datasource="#application.datasource#">
				SELECT 	*
				FROM 		Program_Auto_Renew
				WHERE 	Program_ID = #Renewed_Program_ID#
					AND 	Deleted = 0
			</cfquery>

			<cfset AutoRenewRecordActive = 1 />

			<CFIF FORM.ISREVISIONOFEXISTINGCONTRACT EQ 1>
				<!-----
				**** revision ****
				If there is entry in the IsAutoRenewThere table that means the parent program already has an entry in the auto renew queue,
				we used to update this record with the new child program ID
				D10567: But as we have the problem of the child program never getting approved or getting approved very late,
				so we are not going to update the existing record, but insert a new inactive record for the child program
				We will activate it when the child goes active.
				We need this inactive record for the child becaus eit is in this table where we store the values Form.AR_Renewal_Type and Form.Renewal_Lead_Time
				By default Active field gets a value of 1
				----->

				<cfquery name="IsParentAutoRenewThere" datasource="#application.datasource#">
					SELECT 	*
					FROM 		Program_Auto_Renew
					WHERE 	Program_ID = #ParentCMID#
						AND 	Deleted = 0
				</cfquery>

				<cfif IsParentAutoRenewThere.Recordcount IS 0>
					<!----- If parent did not have auto renew on, and now the user is turning it on for the child, that means the child record should be active ----->
					<cfset AutoRenewRecordActive = 1 />
				<cfelse>
					<cfset AutoRenewRecordActive = 0 />
				</cfif>

			</CFIF>

			<!----- if no entry insert, else update ----->
			<cfif IsAutoRenewThere.Recordcount IS 0>

				<cfquery name="InsertAutoRenewData" datasource="#application.datasource#">
					INSERT INTO Program_Auto_Renew
					(
						AR_Notification_Date,
						AR_Start_Date,
						AR_End_Date,
						AR_Renewal_Type,
						Program_ID,
						Renewed,
						Active,
						Renewal_Lead_Time,
						AR_Start_Period,
						AR_End_Period,
						AR_Fiscal_Year

					)
					VALUES
					(
						'#dateFormat(AR_Notification_Date,"short")#',
						'#dateFormat(AR_Start_Date,"short")#',
						'#dateFormat(AR_End_Date,"short")#',
						'#Form.AR_Renewal_Type#',
						'#Renewed_Program_ID#',
						'0',
						'#AutoRenewRecordActive#',
						'#Form.Renewal_Lead_Time#',
						'#AR_Start_Period#',
						'#AR_End_Period#',
						'#AR_Fiscal_Year#'
					)
				</cfquery>

			<cfelseif IsAutoRenewThere.Recordcount IS 1>

				<cfquery name="UpdateAutoRenewData" datasource="#application.datasource#">
					UPDATE 	Program_Auto_Renew
					SET 		AR_Notification_Date 	= 	'#dateFormat(AR_Notification_Date,"short")#',
									AR_Start_Date 				= 	'#dateFormat(AR_Start_Date,"short")#',
									AR_End_Date 					= 	'#dateFormat(AR_End_Date,"short")#',
									AR_Renewal_Type 			= 	'#Form.AR_Renewal_Type#',
									Active								=		'#AutoRenewRecordActive#',
									Renewal_Lead_Time			=  	'#Form.Renewal_Lead_Time#',
									AR_Start_Period				=		'#AR_Start_Period#',
									AR_End_Period					=		'#AR_End_Period#',
									AR_Fiscal_Year				=		'#AR_Fiscal_Year#'
					WHERE 	Program_ID 						=		#Renewed_Program_ID#
				</cfquery>

			</cfif>

		</cfif> <!--- <cfif Form.Auto_Renew IS 1> --->


		<!--- END save --->
	<!--- End Form.suppressProductsDistributors --->
	<CFTRANSACTION ACTION="COMMIT" />

	</CFTRANSACTION>



<cfif Form.suppressProductsDistributors EQ 0>

	<!--- 10. Formula - generate prices --->
	<CFIF getTemplateSettings.Discount_Formula_Pricing EQ 1>


		<cfset useLakebaseForqGetFormulaPricingProducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_formula_pricing_rule_products")>
<cfif useLakebaseForqGetFormulaPricingProducts>
	<cftry>
		<cfset qGetFormulaPricingProducts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_formula_pricing_rule_products", {
				"program_id" = "eq.#Renewed_Program_ID#",
				"limit" = "1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetFormulaPricingProducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetFormulaPricingProducts>
<cfquery name="qGetFormulaPricingProducts" datasource="#application.datasource#">
			SELECT 	top 1 *
			FROM 	Program_Formula_Pricing_Rule_Products
			WHERE 	Program_ID = #Renewed_Program_ID#
		</cfquery>
</cfif>

		<CFIF qGetFormulaPricingProducts.recordcount GT 0>
			<!----- Generate Formula Prices ---------->
			<CFSET generateReleaseProgramID = Renewed_Program_ID>
			<CFSET generateRelease_GeneratePrices = 1>
			<CFINCLUDE TEMPLATE="Contract_Formula_Pricing_Periods_Generate_Prices_For_Release.cfm">
		</CFIF>
	</cfif>



<cfif FORM.ISREVISIONOFEXISTINGCONTRACT EQ 0>

	<cfset displayinactiveprodustspopup = 1>

</cfif>




</CFIF><!--- Form.suppressProductsDistributors --->

<!--- 11. Market Price Update :: Market_Price
			** If it is a Market Price program, update product rates, and the saved MP rate with current MP rate when necessary.
			** The MP approval info gets updated in USP_Copy_Program --->
<cfscript>
		if(getTemplateSettings.Market_Price){//if MP make sure the Market Price Rates are up to date
			objMarketPriceManager	= CreateObject("component","mvc.Models.Template.MarketPriceManager");
			objMarketPriceManager.MarketPriceUpdateProcess(Renewed_Program_ID);
		}
</cfscript>

	<cfif Form.Scheduled IS NOT 1>
		<!--- 12. Lock the program and unlock the previous version --->
		<cfstoredproc procedure="USP_Contract_Lock_Unlock" datasource="#application.datasource#">
			<cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@User_ID" value="#request.AccessStructure.User_ID#">
			<cfprocparam type="In" cfsqltype="cf_sql_bit" dbVarName="@Unlock" value="1">
			<cfprocparam type="In" cfsqltype="cf_sql_bit" dbVarName="@Lock" value="1">
			<cfprocparam type="In" cfsqltype="cf_sql_integer" dbVarName="@Lock_Program_ID" value="#Renewed_Program_ID#">
			<cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@Lock_Program_Number" value="">
			<cfprocparam type="In" cfsqltype="cf_sql_integer" dbVarName="@Unlock_Program_ID" value="0">
			<cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@Unlock_Program_Number" value="">
		</cfstoredproc>

		<!--- 13. Redirect to view program page --->
		<!---  redirect --->
		<cfset this.editMode = 1 />
		<CF_Cryp type="en" key="#request.key#" string = "#Renewed_Program_ID#">
			<!--- 69705 Remove Copy pop-up if nothing removed START --->
		<CFQUERY NAME="qGetContractChanges" datasource="#application.datasource#">
			SELECT	Contract_Main_ID
			FROM	Program_Copy_Removed_Product
			WHERE	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Renewed_Program_ID#"> 
			
			UNION 
			
			SELECT	Contract_Main_ID
			FROM	Program_Copy_Removed_Distributor
			WHERE	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Renewed_Program_ID#"> 
			
			UNION 
			
			SELECT	Contract_Main_ID
			FROM	Program_Copy_Removed_Operator
			WHERE	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Renewed_Program_ID#"> 
		</CFQUERY>
			
			<cfif qGetContractChanges.recordCount>
				<cfset displayinactiveprodustspopup = 1>
			<cfelse>
				<cfset displayinactiveprodustspopup = 0>
			</cfif>
			<!--- 69705 Remove Copy pop-up if nothing removed END --->
		<CFLOCATION URL="contract_edit_menu.cfm?CID=#cryp.value#&editMode=#this.editMode#&inactiveprodpopup=#displayinactiveprodustspopup#">

	</cfif>


</CFIF>
<!--- ******************************************************************************* --->
<!--- *************************** COPY / REVISE - END ******************************* --->
<!--- ******************************************************************************* --->
<cffunction name="DisplayMessageAndRedirect" output="false" hint="I display a message, redirect users to a specific page.">
	<cfargument name="a_message" required="true">
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
	<cfoutput>
	<html lang="en">
	<head>
		<meta http-equiv="content-type" content="text/html; charset=utf-8">
	<title>Basic Program Information</title>
	<link rel="stylesheet" type="text/css" href="/common_files/impromptu.css">
	<script type="text/javascript" src="/script/javascript/ajax_js/jquery-1.6.1-min.js"></script>
	<script type="text/javascript" src="/Script/javascript/jquery-impromptu.3.1.min.js"></script>
	</head>
	<body>
	<CFOUTPUT>
		<FORM ACTION="contract_renewal_action.cfm" METHOD="post" NAME="RenewForm" ID="RenewForm">
			<INPUT TYPE="hidden" NAME="Program_ID" VALUE="#form.Program_ID#" >
			<INPUT TYPE="hidden" NAME="IsRevisionOfExistingContract" VALUE="1" >
			<INPUT TYPE="hidden" NAME="IsRollOver" VALUE="0" >
			<INPUT TYPE="hidden" NAME="IsCopyProgram" VALUE="0" >
			<INPUT TYPE="hidden" NAME="EZTemplate" VALUE="#form.EZTemplate#" >
			<input TYPE="hidden" name="contract_reference_number" value="">
			<input TYPE="hidden" name="contract_reference_number_2" value=""><!--- 77539 --->
			<INPUT TYPE="hidden" NAME="start_date" VALUE="#form.Start_Date#" >
			<INPUT TYPE="hidden" NAME="end_date" VALUE="#form.End_Date#" >
		</FORM>
	</CFOUTPUT>
	<script>
	 function redirect() {
	  	document.getElementById("RenewForm").submit();
	 }
	 $.prompt( "#arguments.a_message#", { callback:redirect } );
	</script>
	</body>
	</html>
	</cfoutput>
	<cfabort>
</cffunction>
