<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\Common_Files\exportAll.cfm
      Date:
      Author:   Chris Nguyen
      Purpose:

      Parameters:

        1. URL.type = required,
        2. URL.friendlyFileName = optional, current date-time stamp is appended automatically

----------------------------------------------------------------------------------------------------------------------->
<cfparam name="url.type" default="">
<cfparam name="form.type" default="">
<!--- 62230 :: In Settings have distributor, operator & product searches with no filters  START--->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfsetting requestTimeOut = "9000" />
<!--- 62230 :: In Settings have distributor, operator & product searches with no filters  END--->
<cfoutput>
<cfscript>
    if ( !structKeyExists(URL, "friendlyFileName") )
        URL.friendlyFileName = "Export All";

    // postfix friendly file name with current date-time stamp to prevent duplicates
    URL.friendlyFileName = URL.friendlyFileName & " #application.util.dateTime.dateTimeFormat(now())#";

    // generate a unique output file name
    variables.outputFileName = application.Doc_Path & "\temp_files\" & "exportAll" & getTickCount() & ".csv";

    // call appropriate function to gather data based on URL.type parameter
    switch(url.type){
    case "dd_search":
        // url.savedSearch has the name of the objectsave() file which includes all search criteria in it
        variables.textResult = dd_search( url.savedSearch );
        break;

    case "billback_search":
        // url.savedSearch has the name of the objectsave() file which includes all search criteria in it
				variables.textResult = billback_search( url.savedSearch);
        break;

    case "budgetCommitted":
        variables.textResult = application.util.query.queryToCSV( budgetCommitted( URL.budget_id ) );
        break;

    case "budgetActual":
        variables.textResult = application.util.query.queryToCSV( budgetActual( URL.budget_id ) );
        break;
    case "getMarginTargetsData":
        variables.textResult = getMarginTargetsData();
        break;

    case "getProgramAccrualData":
        variables.textResult = call_getProgramAccrualData( URL.contract_number,URL.contractId );
        break;	   
//D60306 ::Exporting All Pages from Budgets and Volume Forecasts START
	case "productsDetail":
        variables.textResult = call_getProdcutsForVolumeForecast( URL.v451 );
        break;	 
	case "listBudgets":
        variables.textResult = call_getBudgetslist( url.segmentIsOn, url.userBusinessSegments, url.byClassIDs, url.sSearch);
        break;	 
//D60306 ::Exporting All Pages from Budgets and Volume Forecasts END	   
//D62230 :: 8.0 - In Settings have distributor, operator & product searches with no filters START
 	case "CustomerMasterData":
        variables.textResult = call_CustomerMasterData( );
        break;
  	case "ProductMasterData":
        variables.textResult = call_ProdcutMasterData( );
        break;
 	case "OperatorMasterData":
        variables.textResult = call_OperatorMasterData( );
        break;
 	case "VendorMasterData":
        variables.textResult = call_VendorMasterData( );
        break;
//D62230 :: 8.0 - In Settings have distributor, operator & product searches with no filters END

		case "DropOffReport":
        variables.textResult = call_getDropOffReport();
        break;
    // this happens when the URL.type has an unexpected value
    default:
        variables.qData = queryNew("Exception", "varchar");
        queryAddRow(variables.qData);
        querySetCell(variables.qData, "Exception", "Unexpected URL.Type value '" & url.type & "'");
        variables.textResult = application.util.query.queryToCSV( variables.qData );
        break;
    }
        /* When we need to pass data by FORM, instead of URL. */
	if (structKeyExists(FORM, "friendlyFileName") ){
		URL.friendlyFileName = FORM.friendlyFileName;

		// postfix friendly file name with current date-time stamp to prevent duplicates
		URL.friendlyFileName = URL.friendlyFileName & " #application.util.dateTime.dateTimeFormat(now())#";
	}
	
        // call appropriate function to gather data based on form.type parameter.
    /* Note: "form.type" has been added below, because the data passed to the URL exceeded a certain limit. */
    switch(form.type){
    case "getProgramAccrualDistributorItemData":
				variables.textResult = call_getProgramAccrualDistributorItemData(contractNumber=form.contract_number, contractMainID=form.ContractId, distributorComponentList=form.distributorComponentList, selectedProductAttribute=form.selectedProductAttribute, selectedProductAttributeText = form.selectedProductAttributeText );
				break;

		case "getProgramAccrualDistributorFiscalPeriodData":
				variables.textResult = call_getProgramAccrualDistributorFiscalPeriodData(contractNumber=form.contract_number, contractMainID=form.ContractId, distributorComponentList=form.distributorComponentList, distributorIdList = form.distributorIdList  );
				break;
	}
</cfscript>
</cfoutput>

<!--- Write the spreadsheet to a file, replacing any existing file. --->
<cffile action="write"
    file = "#variables.outputFileName#"
    nameconflict = "overwrite"
    output="#variables.textResult#"/>

<cfheader name="Content-Disposition" value="attachment;filename=#URL.friendlyFileName#.csv"  />
<cfcontent type="application/csv" file="#variables.outputFileName#"  />

<cfabort>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="dd_search" returntype="string">
  <cfargument name="savedFormFileName" type="string" required="true">
    <!---
    // restore form variables from objectSave() file
    --->
    <cfscript>
        local.searchCriteria = objectLoad(arguments.savedFormFileName);
        structAppend(form, local.searchCriteria, true);
    </cfscript>

    <cfinclude template="\deductions\search_screens\ded_search_query.cfm">

    <!--- pull display data (similar logic in \DEDUCTIONS\search_screens\Ded_Advanced_Search_Result.cfm) from query --->
    <cfscript>
        local.buffer  = createObject( "java", "java.lang.StringBuffer" ).Init();
        local.newLine = chr(13) & chr(10);

        // column heading row :: use Java string functions for optimum performance see bennadel.com site for information
        local.buffer.append(javaCast("string", "Deduction ##, Reference ##, Status,Updated By,Amount,Distributor,Reason Code,Classification,Date,Check ##,Age,Action,Broker,Region,Analyst"
                                                & local.newLine));
    </cfscript>
    <!--- body content --->
    <cfloop query="get_data">
        <!--- append row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
        <cfset local.buffer.append(javaCast("string",     '"'  & get_data.DD_DedID_SP_Number & '"'
                                                        & ',"' & get_data.DD_Reference & '"'
                                                        & ',"' & get_data.DD_Status_Description & '"'
                                                        & ',"' & get_data.DD_UPDATE & '"'
                                                        & ',"' & dollarFormat(get_data.DD_Amount) & '"'
                                                        & ',"' & get_data.Distributor_Name & '"'
                                                        & ',"' & get_data.DD_Reason_Code & ' ' & get_data.DD_Reason_Code_Description & '"'
                                                        & ',"' & get_data.DD_Classification_ID & ' ' & get_data.DD_Classification_Desc & '"'
                                                        & ',"' & dateFormat(get_data.DD_Date, 'm/d/yyyy') & '"'
                                                        & ',"' & get_data.DD_Check_Number & '"'
                                                        & ',"' & get_data.NumberOfDays & ' days"'
                                                        & ',"' & get_data.DD_Stage_Description & '"'
                                                        & ',"' & get_data.Broker_Name & '"'
                                                        & ',"' & get_data.Region_Name & '"'
                                                        & ',"' & get_data.Name_First & ' ' & get_data.Name_last & '"'
                                                        & local.newLine  ))>
    </cfloop>
    <cfreturn local.buffer>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="billback_search" returntype="string">
  <cfargument name="savedRequestFileName" type="string" required="true">

		<CFIF appSettings.getOneProgramPerBillback()>
			 <cfset program_columns = ",Program,Program Title,Program Template"> 
		<CFELSE>
				<cfset program_columns = "">
		</CFIF>
				
	 <!---
		// restore request variables from objectSave() file
		--->
		<cfscript>
				request.stSearch = objectLoad(arguments.savedRequestFileName);
				request.stSearch.forDownload = 1;
				local.aStatus = [   'Work In progress',
                            'Request For Approval',
                            'Approved',
                            'Payment Request',
                            'Paid',
                            'Pending Fund Update',
                            'Pending Vendor ID',
                            'Approved - VOID',       
							'Manual Reject'
							];

        if (application.returned_customer_setting.Customer_Keyword EQ "Mccain") {
            deviation_heading  = "VAR";
            deviation_desc  = "Claim Variance";
        }
        else {
            deviation_heading  =  "DEV";
            deviation_desc  = "Deviation";
        }

        local.businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager");
        local.businessSegmentsOn = local.businessSegManager.isEnabled() ? 1 : 0;

        local.buffer  = createObject( "java", "java.lang.StringBuffer" ).Init();
        local.newLine = chr(13) & chr(10);

        // column heading row :: use Java string functions for optimum performance see bennadel.com site for information
        local.buffer.append(javaCast("string", "Status,Type,Dev,Payable ##,Date,Billback ##,Reference ##,Payee ID,Payee,Title,Start Date,End Date,Claimed $,Expected $,Approved $,Closing Method,Analyst#program_columns#"
                                                & (local.businessSegmentsOn ? ',Segment' : '') & ",BB Sent to ERP,Payment Date"
                                                & local.newLine                                     ));
    </cfscript>


		<cfinvoke
				component="#application.oBillbackSearch#"
				method="searchBillbacks"
				argumentcollection="#request.stSearch#"
				returnvariable="local.billbacks">
		</cfinvoke>

    <!--- body content --->
    <cfloop query="local.billbacks">
	<CFIF appSettings.getOneProgramPerBillback()>
        <!--- append row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
        <cfset local.buffer.append(javaCast("string",     '"'   & local.aStatus[local.billbacks.billback_status_id] & '"'
											& ',"'  & local.billbacks.Abbreviation & '"'
											& ',"'  & (local.billbacks.deviated eq 1 ? deviation_heading : '') & '"'
											& ',"'  & local.billbacks.BB_Code & '"'
											& ',"'  & dateFormat(local.billbacks.BB_Date, "m/dd/yyyy") & '"'
											& ',"'  & local.billbacks.BB_Reference & '"'
											& ',"'  & local.billbacks.referenceNum & '"'       <!--- 51325 --->
											& ',"'  & local.billbacks.Payee_ID & '"'
											& ',"'  & local.billbacks.Payee_Name & '"'
											& ',"'  & local.billbacks.BB_Title & '"'
											& ',"'  & dateFormat(local.billbacks.BB_Start_Date, "m/dd/yyyy") & '"'
											& ',"'  & dateFormat(local.billbacks.BB_End_Date, "m/dd/yyyy") & '"'
											& ',"' & dollarFormat(local.billbacks.BB_Amount) & '"'
											& ',"' & dollarFormat(local.billbacks.BB_Expected_Amount) & '"'
											& ',"' & dollarFormat(local.billbacks.BB_Approved_Amount) & '"'
											& ',"'  & local.billbacks.vchBillback_Closing_Method_Desc & '"'
											& ',"'  & local.billbacks.BBanalyst_Name_First & ' ' & local.billbacks.BBanalyst_Name_Last & '"'
											<!--- Dev Note(70491)- ADDITIONAL COLUMNS (START)--->
											& ',"'  & local.billbacks.Contract_Number & '"'
											& ',"'  & local.billbacks.Contract_Title & '"'
											& ',"'  & local.billbacks.Created_Type & '"' 
											<!--- NEW COLUMNS (END)--->
											& (local.businessSegmentsOn ? ',"' & local.billbacks.business_unit_desc & '"' : '')
											& ',"' & dateFormat(local.billbacks.BB_Payment_Request_Sent_On, "m/dd/yyyy") & ' ' & timeFormat(local.billbacks.BB_Payment_Request_Sent_On, "h:mm:ss tt") & '"'
											& ',"' & dateFormat(local.billbacks.Check_Date, "m/dd/yyyy") & '"'
											& local.newLine  ))>
	<CFELSE>
        <cfset local.buffer.append(javaCast("string",     '"'   & local.aStatus[local.billbacks.billback_status_id] & '"'
											& ',"'  & local.billbacks.Abbreviation & '"'
											& ',"'  & (local.billbacks.deviated eq 1 ? deviation_heading : '') & '"'
											& ',"'  & local.billbacks.BB_Code & '"'
											& ',"'  & dateFormat(local.billbacks.BB_Date, "m/dd/yyyy") & '"'
											& ',"'  & local.billbacks.BB_Reference & '"'
											& ',"'  & local.billbacks.referenceNum & '"'       <!--- 51325 --->
											& ',"'  & local.billbacks.Payee_ID & '"'
											& ',"'  & local.billbacks.Payee_Name & '"'
											& ',"'  & local.billbacks.BB_Title & '"'
											& ',"'  & dateFormat(local.billbacks.BB_Start_Date, "m/dd/yyyy") & '"'
											& ',"'  & dateFormat(local.billbacks.BB_End_Date, "m/dd/yyyy") & '"'
											& ',"' & dollarFormat(local.billbacks.BB_Amount) & '"'
											& ',"' & dollarFormat(local.billbacks.BB_Expected_Amount) & '"'
											& ',"' & dollarFormat(local.billbacks.BB_Approved_Amount) & '"'
											& ',"'  & local.billbacks.vchBillback_Closing_Method_Desc & '"'
											& ',"'  & local.billbacks.BBanalyst_Name_First & ' ' & local.billbacks.BBanalyst_Name_Last & '"'
											& (local.businessSegmentsOn ? ',"' & local.billbacks.business_unit_desc & '"' : '')
											& ',"' & dateFormat(local.billbacks.BB_Payment_Request_Sent_On, "m/dd/yyyy") & ' ' & timeFormat(local.billbacks.BB_Payment_Request_Sent_On, "h:mm:ss tt") & '"'
											& ',"' & dateFormat(local.billbacks.Check_Date, "m/dd/yyyy") & '"'
											& local.newLine  ))>
	</CFIF>
    </cfloop>
    <cfreturn local.buffer>
</cffunction>

<cffunction name="getMarginTargetsData" output="false" returntype="string">

	<CFINCLUDE TEMPLATE="/settings/margin_targets/margin_target_queries.cfm">

		<cfset local.buffer  = createObject( "java", "java.lang.StringBuffer" ).Init()>
		<cfset local.newLine = chr(13) & chr(10)>

		<!--- The business entire business logic for this function comes from "settings\margin_targets\index.cfm" --->

		<!--- column heading row --->
		<cfset local.buffer.append(javaCast("string", " #approvalGroupType.Label#, Margin % - Dist Programs"))>
                            <cfset local.buffer.append(javaCast("string", ",Margin % - Oper Programs"))>
		<cfif appSettings.getApprovalStandardOn()>
			<cfset local.buffer.append(javaCast("string", ",$ Spend"))>
		</cfif>
		<cfif appSettings.getApprovalMarginType() eq 2>
			<cfset local.buffer.append(javaCast("string", ",Rate"))>
		</cfif>
		<cfif listlen(costvariableslist) GT 0>
			<cfloop query="getcostvariables">
				<cfset local.buffer.append(javaCast('string', ',#getcostvariables.cost_sequence_name#'))>
			</cfloop>
		</cfif>

		<cfset local.buffer.append(javaCast("string", local.newLine))>

		<!--- body content --->
		<cfoutput query="getAllCodes">

		<!--- append row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
		<cfset local.buffer.append(javaCast("string",     '="'  & Replace(getAllCodes.Name,',',' ') & '"'
                                                        & ',"' & trim(numberformat(getAllCodes.Target_Margin, '_-___.____')) & '"'
                                                        & ',"' & trim(numberformat(getAllCodes.Target_Margin_Operator, '_-___.____')) & '"'))>
		<cfif appSettings.getApprovalStandardOn()>
			<cfset local.buffer.append(javaCast("string", ',"' & trim(numberformat(getAllCodes.spend_dollar, '_-___.____')) & '"'))>
		</cfif>

		<cfif appSettings.getApprovalMarginType() eq 2>
			<cfset local.buffer.append(javaCast("string",  ',"' & trim(numberformat(getAllCodes.Target_Case_Rate, '_-___.__')) & '"'))>

				<cfif getAllCodes.Target_Case_Rate_UOM EQ 1>
					<cfset local.buffer.append(javaCast("string", ',"' & 'CS' & '"'))>
				<cfelseif getAllCodes.Target_Case_Rate_UOM EQ 2>
					<cfset local.buffer.append(javaCast("string", ',"' & 'LB' & '"'))>
				</cfif>
		</cfif>

		<cfif listlen(costvariableslist) GT 0>
			<cfloop list="#costvariableslist#" index = "cost_id">

				<cfset id_rate = "getAllCodes.cost"&"#cost_id#"&"_rate">
				<cfset id_uom = "getAllCodes.cost"&"#cost_id#"&"_uom">

					<cfset local.buffer.append(javaCast("string", ',"' & evaluate(id_rate) & '"'))>

					<cfif evaluate(id_uom) EQ 1>
						<cfset local.buffer.append(javaCast("string", ',"' & 'CS' & '"'))>
					<cfelseif evaluate(id_uom) EQ 2>
						<cfset local.buffer.append(javaCast("string", ',"' & 'LB' & '"'))>
					<cfelseif evaluate(id_uom) EQ 3>
						<cfset local.buffer.append(javaCast("string", ',"' & '%' & '"'))>
					</cfif>
			</cfloop>
		</cfif>

		<cfset local.buffer.append(javaCast("string", local.newLine))>

		</cfoutput>

  <cfreturn local.buffer>
</cffunction>
<cffunction name="call_getProgramAccrualData" output="false" returntype="string">
	<cfargument name="contractNumber" required="true" type="string" />
	<cfargument name="contractMainID" required="true" type="string" />
	
	<cfinvoke
		component="components.programs.paymenthistory.PaymentHistoryManager"
		method="getProgramAccrualData"
		returnvariable="qGetProgramAccrualData">

		<cfinvokeargument name="contractNumber" value="#arguments.contractNumber#">
		<cfinvokeargument name="contractMainID" value="#arguments.contractMainID#">
    </cfinvoke>

	<cfinvoke
		component="components.programs.paymenthistory.PaymentHistoryManager"
		method="getDeductionAccountExist"
		returnvariable="getDeductionAccountExist">

		<cfinvokeargument name="contract_Number" value="#arguments.contractNumber#">
		<cfinvokeargument name="contractMainID" value="#arguments.contractMainID#">
	</cfinvoke>
        <cfscript>
        local.buffer  = createObject( "java", "java.lang.StringBuffer" ).Init();
        local.newLine = chr(13) & chr(10);

	// column heading row
	local.buffer.append(javaCast("string", "#application.returned_customer_setting.distributor_label_singular#, #application.returned_customer_setting.distributor_label_singular# Name,"));
	if(getDeductionAccountExist eq 1){
		local.buffer.append(javaCast("string", "Deduction Acct,"));
	}
	local.buffer.append(javaCast("string", "Payment Acct, GL Acct, Component ID, Component, Cases, Accrual $, Spent $, Rem $, Rem %" & local.newLine));
	</cfscript>

    <!--- body content --->
        <cfloop query="qGetProgramAccrualData.filteredResults">

        <!--- append row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
        <cfset local.buffer.append(javaCast("string",     '="'  & Ship_To & '"'
                                                        & ',"' & Ship_To_Name & '"'
                                                        & ',"' & NumberFormat(Cases_Invoiced, "_,___,___,___,___") & '"'
                                                        & ',"' & DollarFormat(Amount) & '"'
                                                        & ',"' & Deduction_Account & '"'
                                                        & ',"' & Payment_Account & '"'
                                                        & ',"' & External_ID & '"'
                                                        & ',"' & Component_Name & '"'
                                                        & local.newLine  ))>
        </cfloop>
    <cfreturn local.buffer>
</cffunction>
<cffunction name="call_getProgramAccrualDistributorItemData" output="false" returntype="string">
	<cfargument name="contractNumber" required="true" type="string" />
	<cfargument name="contractMainID" required="true" type="string" />
	<cfargument name="distributorComponentList" required="true" type="string" />

	<cfinvoke
		component="components.programs.paymenthistory.PaymentHistoryManager"
		method="getProgramAccrualDistributorItemData"
		returnvariable="qGetProgramAccrualDistributorItemData">

		<cfinvokeargument name="contractNumber" value="#arguments.contractNumber#">
		<cfinvokeargument name="contractMainID" value="#arguments.contractMainID#">
		<cfinvokeargument name="distributorComponentList" value="#arguments.distributorComponentList#">
	</cfinvoke>

        <cfscript>
        local.buffer  = createObject( "java", "java.lang.StringBuffer" ).Init();
        local.newLine = chr(13) & chr(10);

        // column heading row
		local.buffer.append(javaCast("string", "#application.returned_customer_setting.distributor_label_singular#, #application.returned_customer_setting.distributor_label_singular# Name,"));
		local.buffer.append(javaCast("string", "#application.returned_customer_setting.item_label#, #application.returned_customer_setting.item_label# Desc, Cases, Amount, Rate, Rate UOM,"));
		local.buffer.append(javaCast("string", "Deduction Account, Payment Account, Component ID, Component, Profit Center" & local.newLine));
    </cfscript>

    <!--- body content --->
        <cfloop query="qGetProgramAccrualDistributorItemData.filteredResults">

		<!--- PERCENT --->
		<cfif trim(Rate_UOM) eq "%">
			<cfset rateDisplay = Rate>
		<!---CASES OR POUNDS --->
		<cfelse>
			<cfset rateDisplay = DollarFormat(Rate)>
		</cfif>

        <!--- append row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
        <cfset local.buffer.append(javaCast("string",     '="'  & Ship_To & '"'
                                                        & ',"' & Ship_To_Name & '"'
                                                        & ',="' & Item & '"'
                                                        & ',"' & Item_Description & '"'
                                                        & ',"' & NumberFormat(Cases_Invoiced, "_,___,___,___,___") & '"'
                                                        & ',"' & DollarFormat(Amount) & '"'
                                                        & ',"' & rateDisplay & '"'
                                                        & ',"' & Rate_UOM & '"'
                                                        & ',"' & Deduction_Account & '"'
                                                        & ',"' & Payment_Account & '"'
                                                        & ',"' & External_ID & '"'
                                                        & ',"' & Component_Name & '"'
                                                        & ',"' & Profit_Center & '"'
                                                        & local.newLine  ))>
        </cfloop>
    <cfreturn local.buffer>
</cffunction>	
<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="budgetCommitted" returntype="query">
  <cfargument name="budget_id" required="true">

  <cfscript>
    local.variable_budget = 3;
    local.customers = 4;
  </cfscript>

  <cfquery name="local.qBudget" datasource="#application.datasource#">
    SELECT  Budget_desc,
        Budget_Code,
        Budget_Id,
        Budget_Contribution_Factor_Type_ID,
        Allocation_Position_Level,
        Budget_Class_Desc
    FROM  Budget
          INNER JOIN Budget_Class ON Budget_Class.Budget_Class_ID = Budget.Budget_Class_ID
       WHERE Budget.Budget_Id = <cfqueryparam value="#arguments.budget_id#" cfsqltype="cf_sql_integer">
  </cfquery>

  <cfquery datasource="#application.datasource#" name="local.result">
   <cfif (local.qBudget.Budget_Contribution_Factor_Type_ID neq local.variable_budget)
       and (local.qBudget.Allocation_Position_Level eq local.customers)>
      IF Object_id( 'tempdb..##tmp_budget_program_committed' ) IS NOT NULL
        DROP TABLE ##tmp_Budget_Program_Committed

      SELECT bsa_FoodService_Customers.bsa_FoodService_Customers_Id
             , bsa_FoodService_Customers.shr_Ship_To
             , bsa_FoodService_Customers.Name
             , Sum( Budget_Distributor_Program.Committed_Dollar ) AS Committed_Dollar
             , Sum( Budget_Distributor_Program.Actual_Dollar ) AS Actual_Dollar
             , Max( Contract_Main_Id )                            AS Max_Contract_Main_Id
        INTO ##tmp_Budget_Program_Committed
        FROM Budget_Distributor_Program
             LEFT JOIN bsa_FoodService_Customers
               ON bsa_FoodService_Customers.bsa_FoodService_Customers_Id = Budget_Distributor_Program.bsa_FoodService_Customers_Id
       WHERE Budget_Id = <cfqueryparam value="#arguments.Budget_Id#" cfsqltype="cf_sql_integer">
       GROUP BY bsa_FoodService_Customers.bsa_FoodService_Customers_Id
                , bsa_FoodService_Customers.shr_Ship_To
                , bsa_FoodService_Customers.Name
                , Budget_Distributor_Program.Contract_Number

      SELECT
             Contract_Main.Contract_Number AS Program
             , Contract_Main.Contract_Title AS Title
             , Template = Program_control_panel_options.created_type
             , CONVERT(VARCHAR(12), Contract_Main.Contract_Start_Date, 107) AS Start_Date
             , CONVERT(VARCHAR(12), Contract_Main.Contract_End_Date, 107) AS End_Date
             , Rsp = _Users.Name_First + ' ' + _Users.Name_Last
             , Customer = Bsa_FoodService_Customers.Name +' '+ '(' + bsa_FoodService_Customers.shr_Ship_To + ')'
             , Committed_Dollar AS Committed
             , Actual_Dollar AS Actual
             ---, Contract_Main.Manual_Cancel
        FROM ##tmp_Budget_Program_Committed
             LEFT JOIN Contract_Main
               ON Contract_Main.Contract_Main_Id = ##tmp_Budget_Program_Committed.Max_Contract_Main_Id
             LEFT JOIN Bsa_FoodService_Customers
               ON Bsa_FoodService_Customers.bsa_FoodService_Customers_Id = ##tmp_Budget_Program_Committed.bsa_FoodService_Customers_Id
             LEFT JOIN _Users
               ON _Users.User_ID = Contract_Main.Responsible_User_ID
             LEFT JOIN Program_control_panel_options
               ON Program_control_panel_options.programcontrol_panel_options_id = contract_main.programtype_id
       WHERE (Contract_Main.Manual_Cancel = 0 OR ##tmp_Budget_Program_Committed.Actual_Dollar != 0)
    <cfelse>
      IF Object_id( 'tempdb..##tmp_budget_program_committed' ) IS NOT NULL
        DROP TABLE ##tmp_Budget_Program_Committed

      SELECT Budget_Position_Program.User_Position_Id
             , User_Positions.Position_Label
             , Sum( Budget_Position_Program.Committed_Dollar ) AS Committed_Dollar
             , Sum( Budget_Position_Program.Actual_Dollar ) AS Actual_Dollar
             , Max( Contract_Main_Id )                         AS Max_Contract_Main_Id
        INTO ##tmp_Budget_Program_Committed
        FROM Budget_Position_Program
             LEFT JOIN User_Positions
               ON User_Positions.User_Positions_Id = Budget_Position_Program.User_Position_Id
       WHERE Budget_Id = <cfqueryparam value="#arguments.Budget_Id#" cfsqltype="cf_sql_integer">
       GROUP BY Budget_Position_Program.User_Position_Id
                , User_Positions.Position_Label
                , Budget_Position_Program.Contract_Number

      SELECT
             Contract_Main.Contract_Number AS Program
             , Contract_Main.Contract_Title AS Title
             , Template = Program_control_panel_options.created_type
             , CONVERT(VARCHAR(12), Contract_Main.Contract_Start_Date, 107) AS Start_Date
             , CONVERT(VARCHAR(12), Contract_Main.Contract_End_Date, 107) AS End_Date
             , Rsp = _Users.Name_First + ' ' + _Users.Name_Last
             , Position = Position_Label
             , Committed_Dollar AS Committed
             , Actual_Dollar AS Actual
             ---, Contract_Main.Manual_Cancel
        FROM ##tmp_Budget_Program_Committed
             LEFT JOIN Contract_Main
               ON Contract_Main.Contract_Main_Id = ##tmp_Budget_Program_Committed.Max_Contract_Main_Id
             LEFT JOIN _Users
               ON _Users.User_ID = Contract_Main.Responsible_User_ID
             LEFT JOIN Program_control_panel_options
               ON Program_control_panel_options.programcontrol_panel_options_id = contract_main.programtype_id
       WHERE (Contract_Main.Manual_Cancel = 0 OR ##tmp_Budget_Program_Committed.Actual_Dollar != 0)
   </cfif>
  </cfquery>

  <cfreturn local.result>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="budgetActual" returntype="query">
  <cfargument name="budget_id" required="true">

  <cfscript>
    local.variable_budget = 3;
    local.customers = 4;
  </cfscript>

  <cfquery name="local.qBudget" datasource="#application.datasource#">
    SELECT  Budget_desc,
        Budget_Code,
        Budget_Id,
        Budget_Contribution_Factor_Type_ID,
        Allocation_Position_Level,
        Budget_Class_Desc
    FROM  Budget
          INNER JOIN Budget_Class ON Budget_Class.Budget_Class_ID = Budget.Budget_Class_ID
       WHERE Budget.Budget_Id = <cfqueryparam value="#arguments.budget_id#" cfsqltype="cf_sql_integer">
  </cfquery>

  <cfquery datasource="#application.datasource#" name="local.result">
   <cfif (local.qBudget.Budget_Contribution_Factor_Type_ID neq local.variable_budget)
       and (local.qBudget.Allocation_Position_Level eq local.customers)>
        SELECT
          Contract_Main.Contract_Number AS Program
        , Contract_Main.Contract_Title AS Program_Title
        , Program_control_panel_options.created_type AS Template
        , ISNULL(Billback.BB_Code, 'N/A') as Payable_Number
        , CASE Budget_Distributor_Billback.Billback_ID
          WHEN '00000000-0000-0000-0000-000000000000' THEN 'Off-Invoice'
          WHEN '00000000-0000-0000-0000-000000000001' THEN 'Adjustment'
          ELSE Billback.BB_Title
          END as BB_Title
        , CONVERT(VARCHAR(12), Billback.BB_Start_Date, 107) AS Start_Date
        , CONVERT(VARCHAR(12), Billback.BB_End_Date, 107) AS End_date
        , Bsa_FoodService_Customers.Name + ' '+  '(' + Bsa_FoodService_Customers.shr_Ship_To + ')' AS Customer
        , Budget_Distributor_Billback.Actual_Dollar AS Actual
      FROM Budget_Distributor_Billback
      LEFT JOIN Billback
      ON  Billback.Billback_ID = Budget_Distributor_Billback.Billback_ID
      INNER JOIN Contract_Main
      ON  Contract_Main.Contract_Main_ID = Budget_Distributor_Billback.Contract_Main_ID
      LEFT JOIN Program_control_panel_options
               ON Program_control_panel_options.programcontrol_panel_options_id = contract_main.programtype_id
      LEFT JOIN Bsa_FoodService_Customers
      ON  Bsa_FoodService_Customers.Bsa_FoodService_Customers_ID = Budget_Distributor_Billback.Bsa_FoodService_Customers_ID
      WHERE Budget_Id = <cfqueryparam value="#arguments.Budget_Id#" cfsqltype="cf_sql_integer">
    <cfelse>
      SELECT
          Contract_Main.Contract_Number AS Program
        , Contract_Main.Contract_Title AS Program_Title
        , Program_control_panel_options.created_type AS Template
        , ISNULL(Billback.BB_Code, 'N/A') as Payable_Number
        , CASE Budget_Position_Billback.Billback_ID
          WHEN '00000000-0000-0000-0000-000000000000' THEN 'Off-Invoice'
          WHEN '00000000-0000-0000-0000-000000000001' THEN 'Adjustment'
          ELSE Billback.BB_Title
          END as BB_Title
        , CONVERT(VARCHAR(12), Billback.BB_Start_Date, 107) AS Start_Date
        , CONVERT(VARCHAR(12), Billback.BB_End_Date, 107) AS End_date
        , User_Positions.Position_Label AS Position
        , Budget_Position_Billback.Actual_Dollar AS Actual
      FROM Budget_Position_Billback
      LEFT JOIN Billback
      ON  Billback.Billback_ID = Budget_Position_Billback.Billback_ID
      INNER JOIN Contract_Main
      ON  Contract_Main.Contract_Main_ID = Budget_Position_Billback.Contract_Main_ID
      LEFT JOIN Program_control_panel_options
               ON Program_control_panel_options.programcontrol_panel_options_id = contract_main.programtype_id
      LEFT JOIN User_Positions
      ON  User_Positions.User_Positions_Id = Budget_Position_Billback.User_Position_Id
      WHERE Budget_Id = <cfqueryparam value="#arguments.Budget_Id#" cfsqltype="cf_sql_integer">
   </cfif>
   </cfquery>

  <cfreturn local.result>
</cffunction>

<!---D60306 ::Exporting All Pages from Budgets and Volume Forecasts START --->
<cffunction name="call_getProdcutsForVolumeForecast" output="false" returntype="string">
	<cfargument name="v451" required="true" type="string" />

	<cfscript>
		application.oController.getObject(path="mvc.models.volumeforecast.vfmanager", name="vfmanager", bReload=1);
		qProducts = application.oVfManager.getProducts( arguments.v451,  application.returned_customer_setting.type_group_label_singular, application.returned_customer_setting.item_label );

        local.buffer  = createObject( "java", "java.lang.StringBuffer" ).Init();
        local.newLine = chr(13) & chr(10);

        // column heading row
		local.buffer.append(javaCast("string", "#application.returned_customer_setting.type_group_label_singular#, #application.returned_customer_setting.item_label#, Description" & local.newLine));
    </cfscript>

    <!--- body content --->
        <cfloop query="qProducts">

        <!--- append row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
        <cfset local.buffer.append(javaCast("string",     '="'  & pg_Product_Category_Name & '"'
                                                        & ',"' & Item & '"'
                                                        & ',"' & Description & '"'
                                                        & local.newLine  ))>
        </cfloop>
    <cfreturn local.buffer>
</cffunction>

<cffunction name="call_getBudgetslist" output="false" returntype="string">
	<cfargument name="segmentIsOn" required="true" type="boolean" />
	<cfargument name="userBusinessSegments" required="true" type="boolean" />
	<cfargument name="byClassIDs" required="false" default=""/>
	<cfargument name="sSearch" required="false" default=""/>
	
	<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />

	 <cfquery name="variables.qRows" datasource="#application.datasource#">
		SELECT  DISTINCT 
		         b.Budget_Code AS Code
		       , b.Budget_Desc AS Description
		       , bc.Budget_Class_Desc AS Class
		       , bg.Budget_Group_Desc AS Groups
		       , bcft.Contribution_Factor_Type AS Budget_Type
		       , bs.Business_Unit_Desc AS Segment
		       , FORMAT(ISNULL(b.Budget_Dollar, 0), 'C', 'en-us') AS Budget
		       , FORMAT(ISNULL(b.Committed_Dollar, 0), 'C', 'en-us') AS Committed_Dollar
		       , FORMAT(ISNULL(b.Committed_Dollar, 0) - ISNULL(b.Actual_Dollar, 0), 'C', 'en-us') AS Committed_Balance
		       , FORMAT(ISNULL(b.Actual_Dollar, 0), 'C', 'en-us') AS Actual_Dollar
		       , FORMAT(ISNULL(b.Budget_Dollar, 0) - ISNULL(b.Actual_Dollar, 0), 'C', 'en-us') AS Actual_Balance
		 FROM Budget b
		 <cfif businessSegManager.getClassCodesOn()>  
			INNER JOIN Class_Code 
			ON b.business_segment_id  = Class_Code.Business_Segment_ID 
			INNER JOIN User_Class_Code 
			ON Class_Code.Class_Code_ID = User_Class_Code.Class_Code_Id
			AND User_Class_Code.User_ID = '#request.AccessStructure.User_ID#'
			AND User_Class_Code.Deleted = 0
		<cfelseif arguments.segmentIsOn eq '1' and arguments.userBusinessSegments eq '1'>
			INNER JOIN User_Business_Segment ubs
			ON ubs.Business_Segment_Id = b.Business_Segment_Id
			AND ubs.Deleted = 0
			AND ubs.User_Id = '#request.AccessStructure.User_ID#'
		</cfif>
		LEFT JOIN Budget_Class bc 
		ON b.Budget_Class_ID = bc.Budget_Class_ID
		LEFT JOIN Budget_Contribution_Factor_Type bcft 
		ON b.Budget_Contribution_Factor_Type_ID = bcft.Budget_Contribution_Factor_Type_ID
		LEFT JOIN Budget_Group bg 
		ON b.Budget_Group_ID = bg.Budget_Group_ID
		LEFT JOIN Business_Segment bs 
		ON b.business_segment_id = bs.business_segment_id
		WHERE b.Deleted = 0
		<cfif len(trim(arguments.byClassIDs))>
		 AND b.budget_Class_ID in ( <cfqueryparam value="#arguments.byClassIDs#" cfsqltype="cf_sql_integer" list="yes"> )
		</cfif>		
        <cfif len(arguments.sSearch)>
            AND (    	b.Budget_Code LIKE '%#arguments.sSearch#%'
	                  OR b.Budget_Desc LIKE '%#arguments.sSearch#%'
	                  OR bc.Budget_Class_Desc LIKE '%#arguments.sSearch#%'
	                  OR bg.Budget_Group_Desc LIKE '%#arguments.sSearch#%'
	                  OR bcft.Contribution_Factor_Type LIKE '%#arguments.sSearch#%'
                  <cfif arguments.segmentIsOn eq '1'>
                      OR bs.Business_Unit_Desc LIKE '%#arguments.sSearch#%'
                  </cfif>
                )
         </cfif>
	</cfquery>

	<cfscript>
        local.buffer  = createObject( "java", "java.lang.StringBuffer" ).Init();
        local.newLine = chr(13) & chr(10);
        // column heading row
        	if(segmentIsOn EQ 1){
				local.buffer.append(javaCast("string", "Code,Description,Class,Group,Budget Type,Segment,Budget,Committed Dollar,Committed Balance,Actual Dollar,Actual Balance" & local.newLine));
			}
			else{
				local.buffer.append(javaCast("string", "Code,Description,Class,Group,Budget Type,Budget,Committed Dollar,Committed Balance,Actual Dollar,Actual Balance" & local.newLine));	
			}
    </cfscript>

    <!--- body content --->
    <cfif segmentIsOn>
        <cfloop query="variables.qRows"> 
        <!--- append row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
        <cfset local.buffer.append(javaCast("string",     '="'  & Code & '"'
														& ',"' & Description & '"'
														& ',"' & Class & '"'
														& ',"' & Groups & '"'
														& ',"' & Budget_Type & '"'
														& ',"' & Segment & '"'
														& ',"' & Budget & '"'
														& ',"' & Committed_Dollar & '"'
														& ',"' & Committed_Balance & '"'
														& ',"' & Actual_Dollar & '"'
														& ',"' & Actual_Balance & '"'
                                                        & local.newLine  ))>
        </cfloop>
     <cfelse>
         <cfloop query="variables.qRows"> 
        <!--- append row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
        <cfset local.buffer.append(javaCast("string",     '="'  & Code & '"'
														& ',"' & Description & '"'
														& ',"' & Class & '"'
														& ',"' & Groups & '"'
														& ',"' & Budget_Type & '"'
														& ',"' & Budget & '"'
														& ',"' & Committed_Dollar & '"'
														& ',"' & Committed_Balance & '"'
														& ',"' & Actual_Dollar & '"'
														& ',"' & Actual_Balance & '"'
                                                        & local.newLine  ))>
        </cfloop>     
    </cfif>
    <cfreturn local.buffer>
</cffunction>

<!---D60306 ::Exporting All Pages from Budgets and Volume Forecasts END --->
<!--- START: 64451: Search Feature on Home page / 21-Feb-2017 / Anand Rao --->
<cffunction name="call_CustomerMasterData" output="false" returntype="string">
<cfquery NAME="qDistList" datasource="#application.datasource#">
	SELECT l.Distributor_Group_Level_ID, l.Group_Level_Desc, l.Distributor_Group_Attribute_Table,
	              l.Distributor_Group_Attribute_ID_Field, l.Distributor_Group_Attribute_Master_ID_Field,
	              l.Distributor_Group_Attribute_Number_Field, l.Distributor_Group_Attribute_Name_Field, l.Group_Level_Desc_Internal
	FROM   Distributor_group_level l
	WHERE  l.Deleted = 0
	AND     l.Distributor_Group_Level_Type_ID NOT IN (23, 24, 25, 26)
	AND     l.Active = 1
	AND     l.Is_PG = 0
</cfquery>


<!--- BELOW IS THE QUERY WILL PULLS RECORDS --->
<cfquery name="CustomerMasterData" datasource="#application.datasource#">
	SELECT c.Shr_Ship_To , c.Name
            , c.Address_1+CASE WHEN LEN(c.Address_2) > 0 THEN ','+c.Address_2+',' ELSE ',' END +c.City+','+c.State+','+c.ZipCode AS Address
            , CASE WHEN c.Active_Code = 'A' THEN 'YES' ELSE 'NO' END AS Active_Code, CASE WHEN c.Deleted = 0 THEN 'NO' ELSE 'YES' END AS Deleted
	<cfif businessSegManager.isEnabledForDistributor()>
	, Business_Unit_Desc
	</cfif>
	<CFLOOP Query="qDistList">
		, attr#Distributor_Group_Level_ID#.#Distributor_Group_Attribute_Name_Field# +'  ('+attr#Distributor_Group_Level_ID#.#Distributor_Group_Attribute_Number_Field#+')'AS 	#Distributor_Group_Attribute_Number_Field#
	</CFLOOP>
	FROM   BSA_Foodservice_Customers c
	<CFLOOP Query="qDistList">
	LEFT JOIN #Distributor_Group_Attribute_Table# as attr#Distributor_Group_Level_ID#
	ON       attr#Distributor_Group_Level_ID#.#Distributor_Group_Attribute_ID_Field# = c.#Distributor_Group_Attribute_Master_ID_Field#
	</CFLOOP>
	<cfif businessSegManager.isEnabledForDistributor()>
	LEFT JOIN Business_Segment BS
	ON BS.Business_Segment_ID = c.Business_Segment_ID
	</cfif>
	WHERE c.Ship_To != 'Group'
    ORDER BY c.Name
</cfquery>

	
<cfset commonVariables = "Shr_Ship_To,Name,Address,Active_Code,Deleted">
	<cfif businessSegManager.isEnabledForDistributor()>
		<cfset commonVariables = listappend(commonVariables,appSettings.getbusiness_segment_label()) >
	</cfif>
<cfset clientVariables = listappend(commonVariables,ValueList(qDistList.Group_Level_Desc)) >
<cfset bsaVairables =  listappend(commonVariables,ValueList(qDistList.Group_Level_Desc_Internal))>
	
<cfset clientVariables = replace(clientVariables, '_',' ', 'ALL')>
<cfset bsaVairables =   replace(bsaVairables, '_',' ', 'ALL')>	
	
	<cfscript>
		local.buffer  = createObject( "java", "java.lang.StringBuffer" ).Init();
		local.newLine = chr(13) & chr(10);
		// column heading row
		local.buffer.append(javaCast("string", "#clientVariables#" & local.newLine));
		local.buffer.append(javaCast("string", "#bsaVairables#" & local.newLine));
	</cfscript>

    <!--- body content --->
        <!--- append BSA VARIABLES row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
         <cfloop query="CustomerMasterData">
        <!--- append row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->			 
			 <cfset csvString = '="'  & Shr_Ship_To & '"' & ',="' & replace(Name,',',' ','ALL') & '"' & ',="' & replace(Address,',',' ','ALL') & '"' & ',="' & Active_Code & '"' & ',="' & Deleted & '"' />

			 <cfif businessSegManager.isEnabledForDistributor()>
				 <cfset csvString = csvString & ',="' & Business_Unit_Desc & '"' />
			 </cfif>
		 
			 <cfloop Query="qDistList">
				 <cfset csvString = csvString & ',="' & #replace(Evaluate("CustomerMasterData.#Distributor_Group_Attribute_Number_Field#"),',',' ','ALL')# & '"' />
			 </cfloop>
			 
			 <cfset csvString = csvString & local.newLine />
			 <cfset local.buffer.append(javaCast("string",  csvString))>

        </cfloop>
    <cfreturn local.buffer>
</cffunction>
<cffunction name="call_ProdcutMasterData" output="false" returntype="string">
	<cfquery NAME="qItemList" datasource="#application.datasource#">
		SELECT PGL.Product_Group_Level_ID,PGL.Group_Internal_Label,PGL.Group_Level_Desc,PGA.Product_Group_Attribute_Table
		,PGA.Product_Group_Attribute_ID_Field,PGA.Product_Group_Attribute_Master_ID_Field,PGA.Product_Group_Attribute_Name_Field,PGA.Product_Group_Attribute_Number_Field
		FROM dbo.Product_Group_Level PGL
		INNER JOIN dbo.Product_Group_Attribute PGA
		ON PGA.Product_Group_Level_ID = PGL.Product_Group_Level_ID
		WHERE PGL.Deleted = 0
		AND PGL.Active = 1
		AND PGL.Is_PG = 0
	</cfquery>

<!--- BELOW IS THE QUERY WILL PULLS RECORDS --->
<cfquery name="ProdcutMasterData" datasource="#application.datasource#">
	SELECT IM.item, IM.Description, CASE WHEN IM.Active_Code = 'A' THEN 'YES' ELSE 'NO' END AS Active_Code, CASE WHEN IM.Deleted = 0 THEN 'NO' ELSE 'YES' END AS Deleted
	<cfif businessSegManager.isEnabledForProduct()>
	, Business_Unit_Desc
	</cfif>
	<CFLOOP Query="qItemList">
	, attr#Product_Group_Level_ID#.#Product_Group_Attribute_Name_Field# +'  ('+attr#Product_Group_Level_ID#.#Product_Group_Attribute_Number_Field#+')'AS #Product_Group_Attribute_Number_Field#
	</CFLOOP>
	FROM   BSA_Foodservice_Items_Master IM
	<CFLOOP Query="qItemList">
	LEFT JOIN #Product_Group_Attribute_Table# as attr#Product_Group_Level_ID#
	ON       attr#Product_Group_Level_ID#.#Product_Group_Attribute_ID_Field# = IM.#Product_Group_Attribute_Master_ID_Field#
	</CFLOOP>
	<cfif businessSegManager.isEnabledForProduct()>
	LEFT JOIN Business_Segment BS
	ON BS.Business_Segment_ID = IM.Business_Segment_ID
	</cfif>
	WHERE IM.item is not null
    ORDER BY IM.Description
</cfquery>

<cfset commonVariables = "Item,Description,Active_Code,Deleted">

<cfif businessSegManager.isEnabledForProduct()>
	<cfset commonVariables = listappend(commonVariables,'#appSettings.getbusiness_segment_label()#') >
</cfif>

<cfset clientVariables = listappend(commonVariables,ValueList(qItemList.Group_Level_Desc)) >
<cfset bsaVairables =  listappend(commonVariables,ValueList(qItemList.Group_Internal_Label))>
	
<cfset clientVariables = replace(clientVariables, '_',' ', 'ALL')>
<cfset bsaVairables =   replace(bsaVairables, '_',' ', 'ALL')>		

	<cfscript>
		local.buffer  = createObject( "java", "java.lang.StringBuffer" ).Init();
		local.newLine = chr(13) & chr(10);
		// column heading row
		local.buffer.append(javaCast("string", "#clientVariables#" & local.newLine));
		local.buffer.append(javaCast("string", "#bsaVairables#" & local.newLine));
	</cfscript>

    <!--- body content --->
        <!--- append BSA VARIABLES row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
         <cfloop query="ProdcutMasterData">
        <!--- append row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
		 
			 <cfset csvString = '="'  & Item & '"'
												& ',="' & replace(Description,',',' ','ALL') & '"'
												& ',="' & Active_Code & '"'
												& ',="' & Deleted & '"' />
			 
			 <cfif businessSegManager.isEnabledForDistributor()>
				 <cfset csvString = csvString & ',="' & Business_Unit_Desc & '"' />
			 </cfif>
		 
			 <cfloop Query="qItemList">
				 <cfset csvString = csvString & ',="' & #replace(Evaluate("ProdcutMasterData.#Product_Group_Attribute_Number_Field#"),',',' ','ALL')# & '"' />
			 </cfloop>
			 
			 <cfset csvString = csvString & local.newLine />
			 <cfset local.buffer.append(javaCast("string",  csvString))>		 

        </cfloop>
    <cfreturn local.buffer>
</cffunction>
<cffunction name="call_OperatorMasterData" output="false" returntype="string">

<!--- BELOW IS THE QUERY WILL PULLS RECORDS --->
<cfquery name="BsaOperator" datasource="#application.datasource#">
	SELECT  o.BSA_Operator_ID, o.Legacy_ID , o.Operator_Name,
	            CASE WHEN o.Deleted = 0 THEN 'Yes' ELSE 'No' END as Active,
	            CASE WHEN o.Display_Code = 'A' THEN 'No' ELSE 'Yes' END as Deleted,
		        <cfif businessSegManager.isEnabledForOperator()>
					Business_Unit_Desc,
				</cfif>
				Operator_City, Operator_State, Operator_Location_Type,
	            c.Category_Label, p.Priority_Label,Operator_Type
	FROM  BSA_Operator o
	LEFT JOIN Operator_Category c ON c.Operator_Category_ID = o.Operator_Category_ID
	LEFT JOIN Operator_Priority p ON p.Operator_Priority_ID = o.Operator_Priority_ID
<cfif businessSegManager.isEnabledForOperator()>
	LEFT JOIN Business_Segment BS
	ON BS.Business_Segment_ID = o.Business_Segment_ID
</cfif>
	WHERE o.Deleted = 0
    ORDER BY o.Operator_Name
</cfquery>

<cfset LabelComp 			    = Createobject("component", "components.settings.labels.labels").init() />
<cfset qGetOperatorTypeLabel 	  = LabelComp.getGeneralLabels('Operator Type') />
<cfset qGetOperatorTypeLabel 	  = LabelComp.getGeneralLabels('Operator Type') />
<cfset qGetLocationTypeLabel 	= LabelComp.getGeneralLabels('Location Type') />
<cfset qGetOperatorCategoryLabel 	= LabelComp.getGeneralLabels('Operator Category') />
<cfset qGetOperatorPriorityLabel 	= LabelComp.getGeneralLabels('Operator Priority') />

<cfif businessSegManager.isEnabledForOperator()>
	<cfset BSAVariables = "Operator ID,Legacy ID,Operator Name,Active,Deleted,#appSettings.getbusiness_segment_label()#,City,State,Location Type,Category,Priority,Type">
	<cfset ClientVariables = "#application.returned_customer_setting.operator_label_singular# ID,Legacy ID,#application.returned_customer_setting.operator_label_singular# Name,Active,Deleted,#appSettings.getbusiness_segment_label()#,City,State,#qGetLocationTypeLabel.GENERAL_LABELS_LABEL#,#qGetOperatorCategoryLabel.GENERAL_LABELS_LABEL#,#qGetOperatorPriorityLabel.GENERAL_LABELS_LABEL#,#qGetOperatorTypeLabel.GENERAL_LABELS_LABEL#">
<cfelse>
	<cfset BSAVariables = "Operator ID,Legacy ID,Operator Name,Active,Deleted,City,State,Location Type,Category,Priority, Type">
	<cfset ClientVariables = "#application.returned_customer_setting.operator_label_singular# ID,Legacy ID,#application.returned_customer_setting.operator_label_singular# Name,Active,Deleted,City,State,#qGetLocationTypeLabel.GENERAL_LABELS_LABEL#,#qGetOperatorCategoryLabel.GENERAL_LABELS_LABEL#,#qGetOperatorPriorityLabel.GENERAL_LABELS_LABEL#,#qGetOperatorTypeLabel.GENERAL_LABELS_LABEL#">
</cfif>

	<cfscript>
		local.buffer  = createObject( "java", "java.lang.StringBuffer" ).Init();
		local.newLine = chr(13) & chr(10);
		// column heading row
		local.buffer.append(javaCast("string", "#ClientVariables#" & local.newLine));
		local.buffer.append(javaCast("string", "#BSAVariables#" & local.newLine));
	</cfscript>

    <!--- body content --->
        <!--- append BSA VARIABLES row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
         <cfloop query="BsaOperator">
        <!--- append row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
			 
			<cfset csvString =   '="'  & BSA_Operator_ID & '"'
													& ',="' & Legacy_ID & '"'
													& ',="' &  replace(Operator_Name,',',' ','ALL') & '"'
													& ',="' & Active & '"' 
													& ',="' & Deleted & '"'/>

			<cfif businessSegManager.isEnabledForOperator()>
				<cfset csvString = csvString & ',="' & Business_Unit_Desc & '"' />
			</cfif>

			<cfset csvString = csvString & ',="' & Operator_City & '"' />
			<cfset csvString = csvString & ',="' & Operator_State & '"' />
			<cfset csvString = csvString & ',="' & Operator_Location_Type & '"' />
			<cfset csvString = csvString & ',="' & Category_Label & '"' />
			<cfset csvString = csvString & ',="' & Priority_Label & '"' />
			<cfset csvString = csvString & ',="' & Operator_Type & '"' />

			<cfset csvString = csvString & local.newLine />
			<cfset local.buffer.append(javaCast("string",  csvString))>			 

        </cfloop>
    <cfreturn local.buffer>
</cffunction>
<!--- D62230 :: 8.0 - In Settings have distributor, operator & product searches with no filters END --->
<!--------------------------------------------------------------------------------------------------------------------->
<!--- START: 64451: Search Feature on Home page / 21-Feb-2017 / Anand Rao --->
<cffunction name="call_VendorMasterData" output="false" returntype="string">

	<cfquery name="BsaVendor" datasource="#application.datasource#">
		SELECT RTRIM(VM.Vendor_ID) as Vendor_ID
				,VM.Vendor_Name as VendorName
				,VM.Address_1 + 
					+ CASE WHEN LEN(VM.Address_2) > 0 THEN ', ' + REPLACE(REPLACE( VM.Address_2, char(10), ' '), char(13), ' ') ELSE '' END
					+ ISNULL(', '+VM.City,'n/a')  
					+ ISNULL(', '+VM.state,'n/a')  
					+ ISNULL(', '+VM.zipcode,'n/a') AS Address
					<cfif businessSegManager.isEnabledForVendorType()>
					 	,BS.Business_Unit_Desc 
					</cfif>
				,CASE WHEN VM.Active_Code = 'A' THEN ' Yes ' ELSE ' No ' END as Active
				,CASE WHEN VM.Deleted = 0 THEN ' No ' ELSE ' Yes ' END as Deleted
		FROM 		Vendor_Master VM
		<cfif businessSegManager.isEnabledForVendorType()>
			LEFT JOIN Business_Segment BS
			ON BS.Business_Segment_ID = VM.Business_Segment_ID
		</cfif>
		WHERE (VM.Deleted = 0 OR VM.Deleted = 1)
	</cfquery>
	
	<cfif businessSegManager.isEnabledForVendorType() EQ 1>
		<cfset BSAVariables = "Vendor ID, Vendor Name, Vendor Address, #appSettings.getbusiness_segment_label()#, Active, Deleted">
	<cfelse>
		<cfset BSAVariables = "Vendor ID, Vendor Name, Vendor Address, Active, Deleted">
	</cfif>
	
	<cfscript>
		local.buffer  = createObject( "java", "java.lang.StringBuffer" ).Init();
		local.newLine = chr(13) & chr(10);
		local.buffer.append(javaCast("string", "#BSAVariables#" & local.newLine));
	</cfscript>
    
	<cfloop query="BsaVendor">
    	<cfset csvString =   '="'  & Vendor_ID & '"'
						   & ',="' &  replace(VendorName,',',' ','ALL') & '"'/>
		<cfset csvString = csvString & ',="' &  replace(Address,',',' ','ALL') & '"' />						   
		<cfif businessSegManager.isEnabledForOperator()>
			<cfset csvString = csvString & ',="' & Business_Unit_Desc & '"' />
		</cfif>
			<cfset csvString = csvString & ',="' & Active & '"' />
		<cfset csvString = csvString & ',="' & Deleted & '"' />
		<cfset csvString = csvString & local.newLine />
		<cfset local.buffer.append(javaCast("string",  csvString))>			 
	</cfloop>
    <cfreturn local.buffer>
</cffunction>	
<!--- END: 64451: Search Feature on Home page / 21-Feb-2017 / Anand Rao --->

<cffunction name="call_CustomerSystemMasterData" output="false" returntype="string">
<cfquery NAME="qDistList" datasource="#application.datasource#">
    SELECT l.Distributor_Group_Level_ID, l.Group_Level_Desc, l.Distributor_Group_Attribute_Table,
                  l.Distributor_Group_Attribute_ID_Field, l.Distributor_Group_Attribute_Master_ID_Field,
                  l.Distributor_Group_Attribute_Number_Field, l.Distributor_Group_Attribute_Name_Field, l.Group_Level_Desc_Internal
    FROM   Distributor_group_level l
    WHERE  l.Deleted = 0
    AND     l.Distributor_Group_Level_Type_ID NOT IN (23, 24, 25, 26)
    AND     l.Active = 1
    AND     l.Is_PG = 0
</cfquery>


<!--- BELOW IS THE QUERY WILL PULLS RECORDS --->
<cfquery name="CustomerSystemMasterData" datasource="#application.datasource#">
    SELECT  c.Shr_Ship_To, c.Name,t.PG_Type_Code, t.PG_Type_Name, pg.PG_Customer_Category_Code, pg.PG_Customer_Category_Name
            , c.Address_1+CASE WHEN LEN(c.Address_2) > 0 THEN ','+c.Address_2+',' ELSE ',' END +c.City+','+c.State+','+c.ZipCode AS Address
            , CASE WHEN c.Active_Code = 'A' THEN 'YES ' ELSE 'NO ' END AS Active_Code
            , CASE WHEN c.Deleted = 0 THEN 'NO ' ELSE 'YES ' END AS Deleted
    <cfif businessSegManager.isEnabledForDistributor()>
    , Business_Unit_Desc AS #appSettings.getbusiness_segment_label()#
    </cfif>
    <CFLOOP Query="qDistList">
    , attr#Distributor_Group_Level_ID#.#Distributor_Group_Attribute_Name_Field#
    </CFLOOP>
    FROM   PG_Type t
    INNER JOIN PG_Customer_Category pg
    ON            pg.PG_Type_ID = t.PG_Type_ID
    AND           pg.Deleted = 0
    INNER JOIN PG_Customer_Members m
    ON            m.PG_Customer_Category_ID = pg.PG_Customer_Category_ID
    AND           m.Deleted = 0
    INNER JOIN BSA_Foodservice_Customers c
    ON            c.BSA_Foodservice_Customers_ID = m.BSA_Foodservice_Customers_ID
    <CFLOOP Query="qDistList">
    LEFT JOIN #Distributor_Group_Attribute_Table# as attr#Distributor_Group_Level_ID#
    ON       attr#Distributor_Group_Level_ID#.#Distributor_Group_Attribute_ID_Field# = c.#Distributor_Group_Attribute_Master_ID_Field#
    </CFLOOP>
    <cfif businessSegManager.isEnabledForDistributor()>
    LEFT JOIN Business_Segment BS
    ON BS.Business_Segment_ID = c.Business_Segment_ID
    </cfif>
    WHERE  t.Deleted = 0
    AND           t.PG_Group_Type = 2
    AND           t.Is_System = 1
    ORDER BY c.Name
</cfquery>


<cfset commonVariables = "Shr_Ship_To,Name,Address,PG_Type_Code,PG_Type_Name,PG_Customer_Category_Code,PG_Customer_Category_Name,Active_Code,Deleted">
    <cfif businessSegManager.isEnabledForDistributor()>
        <cfset commonVariables = listappend(commonVariables,appSettings.getbusiness_segment_label()) >
    </cfif>
<cfset clientVariables = listappend(commonVariables,ValueList(qDistList.Group_Level_Desc)) >
<cfset bsaVairables =  listappend(commonVariables,ValueList(qDistList.Group_Level_Desc_Internal))>

<cfset clientVariables = replace(clientVariables, '_',' ', 'ALL')>
<cfset bsaVairables =   replace(bsaVairables, '_',' ', 'ALL')>

    <cfscript>
        local.buffer  = createObject( "java", "java.lang.StringBuffer" ).Init();
        local.newLine = chr(13) & chr(10);
        // column heading row
        local.buffer.append(javaCast("string", "#clientVariables#" & local.newLine));
        local.buffer.append(javaCast("string", "#bsaVairables#" & local.newLine));
    </cfscript>

    <!--- body content --->
        <!--- append BSA VARIABLES row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
         <cfloop query="CustomerSystemMasterData">
        <!--- append row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
             <cfset csvString = '="'  & Shr_Ship_To & '"'
                                                        & ',="' & replace(Name,',',' ','ALL') & '"'
                                                        & ',="' & replace(Address,',',' ','ALL') & '"'
                                                        & ',="' & PG_Type_Code & '"'
                                                        & ',="' & PG_Type_Name & '"'
                                                        & ',="' & PG_Customer_Category_Code & '"'
                                                        & ',="' & PG_Customer_Category_Name & '"'
                                                        & ',="' & Active_Code & '"'
                                                        & ',="' & Deleted & '"' />

             <cfif businessSegManager.isEnabledForDistributor()>
                 <cfset csvString = csvString & ',="' & Business_Unit_Desc & '"' />
             </cfif>

             <cfloop Query="qDistList">
                 <cfset csvString = csvString & ',="' & #replace(Evaluate("CustomerSystemMasterData.#Distributor_Group_Attribute_Number_Field#"),',',' ','ALL')# & '"' />
             </cfloop>

             <cfset csvString = csvString & local.newLine />
             <cfset local.buffer.append(javaCast("string",  csvString))>

        </cfloop>
    <cfreturn local.buffer>
</cffunction>
<cffunction name="call_ProdcutSystemMasterData" output="false" returntype="string">
    <cfquery NAME="qItemList" datasource="#application.datasource#">
        SELECT PGL.Product_Group_Level_ID,PGL.Group_Internal_Label,PGL.Group_Level_Desc,PGA.Product_Group_Attribute_Table
        ,PGA.Product_Group_Attribute_ID_Field,PGA.Product_Group_Attribute_Master_ID_Field,PGA.Product_Group_Attribute_Name_Field,PGA.Product_Group_Attribute_Number_Field
        FROM dbo.Product_Group_Level PGL
        INNER JOIN dbo.Product_Group_Attribute PGA
        ON PGA.Product_Group_Level_ID = PGL.Product_Group_Level_ID
        WHERE PGL.Deleted = 0
        AND PGL.Active = 1
        AND PGL.Is_PG = 0
    </cfquery>

<!--- BELOW IS THE QUERY WILL PULLS RECORDS --->
<cfquery name="ProdcutMasterData" datasource="#application.datasource#">
    SELECT IM.item, REPLACE(IM.Description,',',' ') AS Description, t.PG_Type_Code, t.PG_Type_Name, pg.PG_Product_Category_Code, pg.PG_Product_Category_Name,
    CASE WHEN IM.Active_Code = 'A' THEN 'YES ' ELSE 'NO ' END AS Active_Code,
    CASE WHEN IM.Deleted = 0 THEN 'NO ' ELSE 'YES ' END AS Deleted
    <cfif businessSegManager.isEnabledForProduct()>
    , Business_Unit_Desc AS #appSettings.getbusiness_segment_label()#
    </cfif>
    <CFLOOP Query="qItemList">
    , attr#Product_Group_Level_ID#.#Product_Group_Attribute_Name_Field#
    </CFLOOP>
    FROM   PG_Type t
    INNER JOIN PG_Product_Category pg
    ON            pg.PG_Type_ID = t.PG_Type_ID
    AND           pg.Deleted = 0
    INNER JOIN PG_Product_Members m
    ON            m.PG_Product_Category_ID = pg.PG_Product_Category_ID
    AND           m.Deleted = 0
    INNER JOIN BSA_Foodservice_Items_Master IM
    ON            IM.BSA_Foodservice_Items_Master_ID = m.BSA_Foodservice_Items_Master_ID
    <CFLOOP Query="qItemList">
    LEFT JOIN #Product_Group_Attribute_Table# as attr#Product_Group_Level_ID#
    ON       attr#Product_Group_Level_ID#.#Product_Group_Attribute_ID_Field# = IM.#Product_Group_Attribute_Master_ID_Field#
    </CFLOOP>
    <cfif businessSegManager.isEnabledForProduct()>
    LEFT JOIN Business_Segment BS
    ON BS.Business_Segment_ID = IM.Business_Segment_ID
    </cfif>
    WHERE  t.Deleted = 0
    AND           t.PG_Group_Type = 1
    AND           t.Is_System = 1
    ORDER BY IM.Description
</cfquery>

<cfset commonVariables = "Item,Description,PG_Type_Code,PG_Type_Name,PG_Product_Category_Code,PG_Product_Category_Name,Active_Code,Deleted">

<cfif businessSegManager.isEnabledForProduct()>
    <cfset commonVariables = listappend(commonVariables,'#appSettings.getbusiness_segment_label()#') >
</cfif>

<cfset clientVariables = listappend(commonVariables,ValueList(qItemList.Group_Level_Desc)) >
<cfset bsaVairables =  listappend(commonVariables,ValueList(qItemList.Group_Internal_Label))>

<cfset clientVariables = replace(clientVariables, '_',' ', 'ALL')>
<cfset bsaVairables =   replace(bsaVairables, '_',' ', 'ALL')>

    <cfscript>
        local.buffer  = createObject( "java", "java.lang.StringBuffer" ).Init();
        local.newLine = chr(13) & chr(10);
        // column heading row
        local.buffer.append(javaCast("string", "#clientVariables#" & local.newLine));
        local.buffer.append(javaCast("string", "#bsaVairables#" & local.newLine));
    </cfscript>

    <!--- body content --->
        <!--- append BSA VARIABLES row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
         <cfloop query="ProdcutMasterData">
        <!--- append row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->

             <cfset csvString = '="'  & Item & '"'
                                                & ',="' & replace(Description,',',' ','ALL') & '"'
                                                & ',="' & PG_Type_Code & '"'
                                                & ',="' & PG_Type_Name & '"'
                                                & ',="' & PG_Product_Category_Code & '"'
                                                & ',="' & PG_Product_Category_Name & '"'
                                                & ',="' & Active_Code & '"'
                                                & ',="' & Deleted & '"' />

             <cfif businessSegManager.isEnabledForDistributor()>
                 <cfset csvString = csvString & ',="' & Business_Unit_Desc & '"' />
             </cfif>

             <cfloop Query="qItemList">
                 <cfset csvString = csvString & ',="' & #replace(Evaluate("ProdcutMasterData.#Product_Group_Attribute_Number_Field#"),',',' ','ALL')# & '"' />
             </cfloop>

             <cfset csvString = csvString & local.newLine />
             <cfset local.buffer.append(javaCast("string",  csvString))>

        </cfloop>
    <cfreturn local.buffer>
</cffunction>
<cffunction name="call_OperatorSystemMasterData" output="false" returntype="string">

<!--- BELOW IS THE QUERY WILL PULLS RECORDS --->
<cfquery name="BsaOperator" datasource="#application.datasource#">
        SELECT o.BSA_Operator_ID, o.Legacy_ID , o.Operator_Name,t.PG_Type_Code, t.PG_Type_Name, pg.PG_Operator_Category_Code, pg.PG_Operator_Category_Name,
                     CASE WHEN o.Deleted = 0 THEN 'Yes ' ELSE 'No ' END as Active,
                    CASE WHEN o.Display_Code = 'A' THEN 'No ' ELSE 'Yes ' END as Deleted,
                        <cfif businessSegManager.isEnabledForOperator()>
                            Business_Unit_Desc AS #appSettings.getbusiness_segment_label()#,
                        </cfif>
                    Operator_City, Operator_State, Operator_Location_Type,
                    c.Category_Label, p.Priority_Label,Operator_Type
        FROM   PG_Type t
        INNER JOIN PG_Operator_Category pg
        ON            pg.PG_Type_ID = t.PG_Type_ID
        AND           pg.Deleted = 0
        INNER JOIN PG_Operator_Members M
        ON            m.PG_Operator_Category_ID = pg.PG_Operator_Category_ID
        AND           m.Deleted = 0
        INNER JOIN dbo.BSA_Operator O
        ON            O.BSA_Operator_ID = M.BSA_Operator_ID
        LEFT JOIN Operator_Category c ON c.Operator_Category_ID = o.Operator_Category_ID
        LEFT JOIN Operator_Priority p ON p.Operator_Priority_ID = o.Operator_Priority_ID
        <cfif businessSegManager.isEnabledForOperator()>
            LEFT JOIN Business_Segment BS
            ON BS.Business_Segment_ID = o.Business_Segment_ID
        </cfif>
        WHERE  t.Deleted = 0
        AND      t.PG_Group_Type = 3
        AND      t.Is_System = 1
    ORDER BY o.Operator_Name
</cfquery>

<cfset LabelComp                = Createobject("component", "components.settings.labels.labels").init() />
<cfset qGetOperatorTypeLabel      = LabelComp.getGeneralLabels('Operator Type') />
<cfset qGetOperatorTypeLabel      = LabelComp.getGeneralLabels('Operator Type') />
<cfset qGetLocationTypeLabel    = LabelComp.getGeneralLabels('Location Type') />
<cfset qGetOperatorCategoryLabel    = LabelComp.getGeneralLabels('Operator Category') />
<cfset qGetOperatorPriorityLabel    = LabelComp.getGeneralLabels('Operator Priority') />

<cfif businessSegManager.isEnabledForOperator()>
  <cfif isDefined('url.type')>
    <cfset BSAVariables = "Operator ID, Legacy ID, Operator Name, PG Type Code, PG Type Name, PG Operator Category Code, PG Operator Category Name, Active, Deleted, #appSettings.getbusiness_segment_label()#,City, State, Location Type, Category, Priority, Type">
    <cfset ClientVariables = "#application.returned_customer_setting.operator_label_singular# ID, Legacy ID, #application.returned_customer_setting.operator_label_singular# Name, <cfif isDefined('url.type')>PG Type Code, PG Type Name, PG Operator Category Code, PG Operator Category Name,</cfif> Active, Deleted, #appSettings.getbusiness_segment_label()#,City, State, #qGetLocationTypeLabel.GENERAL_LABELS_LABEL#, #qGetOperatorCategoryLabel.GENERAL_LABELS_LABEL#, #qGetOperatorPriorityLabel.GENERAL_LABELS_LABEL#, #qGetOperatorTypeLabel.GENERAL_LABELS_LABEL#">
  <cfelse>
    <cfset BSAVariables = "Operator ID, Legacy ID, Operator Name, Active, Deleted, City, State, Location Type, Category, Priority, Type">
    <cfset ClientVariables = "#application.returned_customer_setting.operator_label_singular# ID, Legacy ID, #application.returned_customer_setting.operator_label_singular# Name, Active, Deleted, City, State, #qGetLocationTypeLabel.GENERAL_LABELS_LABEL#, #qGetOperatorCategoryLabel.GENERAL_LABELS_LABEL#, #qGetOperatorPriorityLabel.GENERAL_LABELS_LABEL#, #qGetOperatorTypeLabel.GENERAL_LABELS_LABEL#">
  </cfif>
<cfelse>
  <cfif isDefined('url.type')>
    <cfset BSAVariables = "Operator ID, Legacy ID, Operator Name, PG Type Code, PG Type Name, PG Operator Category Code, PG Operator Category Name, Active, Deleted, City, State, Location Type, Category, Priority, Type">
    <cfset ClientVariables = "#application.returned_customer_setting.operator_label_singular# ID, Legacy ID, #application.returned_customer_setting.operator_label_singular# Name, <cfif isDefined('url.type')>PG Type Code, PG Type Name, PG Operator Category Code, PG Operator Category Name,</cfif> Active, Deleted, City, State, #qGetLocationTypeLabel.GENERAL_LABELS_LABEL#, #qGetOperatorCategoryLabel.GENERAL_LABELS_LABEL#, #qGetOperatorPriorityLabel.GENERAL_LABELS_LABEL#, #qGetOperatorTypeLabel.GENERAL_LABELS_LABEL#">
  <cfelse>
    <cfset BSAVariables = "Operator ID, Legacy ID, Operator Name, Active, Deleted, City, State, Location Type, Category, Priority, Type">
    <cfset ClientVariables = "#application.returned_customer_setting.operator_label_singular# ID, Legacy ID, #application.returned_customer_setting.operator_label_singular# Name, Active, Deleted, City, State, #qGetLocationTypeLabel.GENERAL_LABELS_LABEL#, #qGetOperatorCategoryLabel.GENERAL_LABELS_LABEL#, #qGetOperatorPriorityLabel.GENERAL_LABELS_LABEL#, #qGetOperatorTypeLabel.GENERAL_LABELS_LABEL#">
  </cfif>
</cfif>

    <cfscript>
        local.buffer  = createObject( "java", "java.lang.StringBuffer" ).Init();
        local.newLine = chr(13) & chr(10);
        // column heading row
        local.buffer.append(javaCast("string", "#ClientVariables#" & local.newLine));
        local.buffer.append(javaCast("string", "#BSAVariables#" & local.newLine));
    </cfscript>

    <!--- body content --->
        <!--- append BSA VARIABLES row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
         <cfloop query="BsaOperator">
        <!--- append row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->

            <cfset csvString =   '="'  & BSA_Operator_ID & '"'
                                                    & ',="' & Legacy_ID & '"'
                                                    & ',="' &  replace(Operator_Name,',',' ','ALL') & '"'
                                                    & ',="' & PG_Type_Code & '"'
                                                    & ',="' & PG_Type_Name & '"'
                                                    & ',="' & PG_Operator_Category_Code & '"'
                                                    & ',="' & PG_Operator_Category_Name & '"'
                                                    & ',="' & Active & '"'
                                                    & ',="' & Deleted & '"'/>

            <cfif businessSegManager.isEnabledForOperator()>
                <cfset csvString = csvString & ',="' & Business_Unit_Desc & '"' />
            </cfif>

            <cfset csvString = csvString & ',="' & Operator_City & '"' />
            <cfset csvString = csvString & ',="' & Operator_State & '"' />
            <cfset csvString = csvString & ',="' & Operator_Location_Type & '"' />
            <cfset csvString = csvString & ',="' & Category_Label & '"' />
            <cfset csvString = csvString & ',="' & Priority_Label & '"' />
            <cfset csvString = csvString & ',="' & Operator_Type & '"' />

            <cfset csvString = csvString & local.newLine />
            <cfset local.buffer.append(javaCast("string",  csvString))>

        </cfloop>
    <cfreturn local.buffer>
</cffunction>
<cffunction name="call_getDropOffReport" output="false" returntype="string">
	
	<cfquery name="DropTempTables" datasource="#application.datasource#">
		IF OBJECT_ID ('tempdb..##tmp_budget_fiscal_dates_per') IS NOT NULL
		DROP TABLE ##tmp_budget_fiscal_dates_per
				
		IF OBJECT_ID ('tempdb..##tmp_Periods') IS NOT NULL
		DROP TABLE ##tmp_Periods
		
		IF OBJECT_ID ('tempdb..##tmp_Budget_Cust_Sum_1') IS NOT NULL
		DROP TABLE ##tmp_Budget_Cust_Sum_1
		
		IF OBJECT_ID('tempdb..##tmp_Log_5000_Budgets_Perpetual_Report_5000_Customer') IS NOT NULL
		DROP TABLE ##tmp_Log_5000_Budgets_Perpetual_Report_5000_Customer
		
		IF OBJECT_ID ('tempdb..##tmp_Budget_Cust_Sum') IS NOT NULL
		DROP TABLE ##tmp_Budget_Cust_Sum
		
		IF OBJECT_ID ('tempdb..##tmp_Budget_Cust_Payments') IS NOT NULL
		DROP TABLE ##tmp_Budget_Cust_Payments
		
		IF OBJECT_ID ('tempdb..##tmp_Combined') IS NOT NULL
		DROP TABLE ##tmp_Combined
		
		IF OBJECT_ID('tempdb..##tmp_Log_5000_Budgets_Perpetual_Report') IS NOT NULL
		DROP TABLE ##tmp_Log_5000_Budgets_Perpetual_Report
	</cfquery>
	
	<!--- BELOW IS THE QUERY WILL PULLS RECORDS --->
	<cfquery name="DropOffReport" datasource="#application.datasource#">
		DECLARE	@Period_Start datetime,	@End_date datetime

		SELECT	@period_start = Accrual_Range_Start, @End_date = Accrual_Range_End
		FROM	Log_5000_Budgets_Temp_Dates

		SELECT	bc.Start_Date, bc.End_Date,b.Budget_Code
		INTO	##tmp_budget_fiscal_dates_per
		FROM	Budget b
		INNER JOIN budget_class bc
		ON		bc.Budget_Class_ID = b.Budget_Class_ID
		WHERE	b.deleted = 0
		AND		b.Is_Perpetual = 1

		SELECT	cast(d.Fiscal_Year AS varchar(20)) + '-' + Right('0' + cast(d.Fiscal_Month AS varchar(20)), 2) AS Period,
				Min(CAST(d.Fiscal_Month_Start_Date AS DATE)) AS Period_Start,
				Max(CAST(d.Fiscal_Month_End_Date AS DATE)) AS Period_End
		INTO	##tmp_Periods
		FROM	RDB_Fiscal_Dates d
		WHERE	d.Day >= '9/26/2016' <!--- No need to change this date --->
		AND		d.Day <= @End_date
		GROUP BY cast(d.Fiscal_Year as varchar(20)) + '-' + Right('0' + cast(d.Fiscal_Month AS varchar(20)), 2)

		SELECT	l.Budget_ID AS Budget_Code, l.Customer_Number, 
				CAST('' AS varchar(200)) AS Ship_To,
				CAST('' AS varchar(200)) AS Distributor_Name,
				CAST('00000000-0000-0000-0000-000000000000' AS uniqueidentifier) AS BSA_Foodservice_Customers_ID,
				p.Period, p.Period_Start, p.Period_End,
				SUM(CAST(l.Amount AS DECIMAL(20,2))) AS Budget_Amount
		INTO	##tmp_Budget_Cust_Sum_1
		FROM	##tmp_Periods p
		INNER JOIN Log_5000_Budgets_Week l
		ON		CAST(l.Start_Date AS DATE) BETWEEN p.Period_Start AND p.Period_End
		AND		CAST(l.Start_Date AS DATE) <= CAST(l.End_Date AS DATE)
		INNER JOIN	##tmp_budget_fiscal_dates_per B
		ON		B.Budget_Code = l.Budget_ID
		GROUP BY l.Budget_ID, l.Customer_Number, p.Period, p.Period_Start, p.Period_End

		UPDATE	t
		SET		t.BSA_Foodservice_Customers_ID = cm.BSA_Foodservice_Customers_ID,
				Ship_To = cm.Shr_Ship_To,
				Distributor_Name = cm.Name
		FROM	##tmp_Budget_Cust_Sum_1 t
		INNER JOIN	SHIPTO_INVOICE_RELATION S
		ON		S.SHIPTO_INVOICE_RELATION = t.Customer_Number
		INNER JOIN  BSA_Foodservice_Customers cm
		ON			s.Ship_To = cm.Ship_To

		SELECT	*
		INTO	##tmp_Log_5000_Budgets_Perpetual_Report_5000_Customer
		FROM	##tmp_Budget_Cust_Sum_1

		SELECT	Budget_Code, Ship_To
				, Distributor_Name
				, BSA_Foodservice_Customers_ID
				, Period, Period_Start
				, Period_End
				, SUM(Budget_Amount) AS Budget_Amount
		INTO	##tmp_Budget_Cust_Sum
		FROM	##tmp_Budget_Cust_Sum_1
		GROUP BY Budget_Code, Ship_To, Distributor_Name, BSA_Foodservice_Customers_ID,Period, Period_Start, Period_End

		SELECT	l.Budget_Code, l.BSA_Foodservice_Customers_ID, 
				l.Fiscal_Month_Start_Date,
				l.Fiscal_Month_End_Date,
				SUM(Payments_Applied) AS Payments_Applied,
				SUM(Payments_Applied) + sum(isnull(Not_Applied_For_Period, 0)) as Total_Payments
		INTO	##tmp_Budget_Cust_Payments
		FROM	Log_5000_Budgets_Payments_Applied l
		INNER JOIN	##tmp_budget_fiscal_dates_per B
		ON		B.Budget_Code = l.Budget_Code
		GROUP BY l.Budget_Code, l.BSA_Foodservice_Customers_ID, l.Fiscal_Month_Start_Date, l.Fiscal_Month_End_Date

		SELECT	b.*,
				ISNULL(p.Payments_Applied, 0) AS Payments_Applied,
				ISNULL(p.Total_Payments, 0) as Total_Payments,
				cast(0 AS decimal(20, 2)) AS Drop_Off
		INTO	##tmp_Combined
		FROM	##tmp_Budget_Cust_Sum b
		LEFT JOIN ##tmp_Budget_Cust_Payments p
		ON		p.Budget_Code = b.Budget_Code
		AND		p.BSA_Foodservice_Customers_ID = b.BSA_Foodservice_Customers_ID
		AND		p.Fiscal_Month_Start_Date = b.Period_Start
										
		UNION ALL
		
		SELECT  pmt.Budget_Code,
				c.Shr_Ship_To as Ship_To, c.Name as Distributor_Name,
				pmt.BSA_Foodservice_Customers_ID,
				p.Period, p.Period_Start, p.Period_End, 0 as Budget_Amount,
				ISNULL(pmt.Payments_Applied, 0) as Payments_Applied,
				ISNULL(pmt.Total_Payments, 0) as Total_Payments,
				cast(0 as decimal(20, 2)) as Drop_Off
		FROM    ##tmp_Budget_Cust_Payments pmt
		INNER JOIN ##tmp_Periods p 
		ON p.Period_Start = pmt.Fiscal_Month_Start_Date
		INNER JOIN BSA_Foodservice_Customers c 
		ON c.BSA_Foodservice_Customers_ID = pmt.BSA_Foodservice_Customers_ID
		WHERE   not exists (
								SELECT  1
								FROM    ##tmp_Budget_Cust_Sum b
								WHERE   pmt.Budget_Code = b.Budget_Code
								AND     pmt.BSA_Foodservice_Customers_ID = b.BSA_Foodservice_Customers_ID
								AND     pmt.Fiscal_Month_Start_Date = b.Period_Start
							)

		UPDATE	##tmp_Combined
		SET		Drop_Off = 
						CASE
						WHEN Budget_Amount > Payments_Applied THEN Budget_Amount - Payments_Applied
						WHEN Budget_Amount < 0 THEN Budget_Amount - Payments_Applied
						ELSE 0
						END
		WHERE	Period_Start < @period_start

		SELECT	*, Budget_Amount - Drop_Off AS Final_Budget_Amount,(Budget_Amount - Drop_Off) - Total_Payments AS Balance
		INTO	##tmp_Log_5000_Budgets_Perpetual_Report
		FROM	##tmp_Combined

		SELECT	Budget_Code
			,Period
			,Period_Start
			,Period_End
			,Budget_Amount
			,Drop_Off
			,Final_Budget_Amount
			,Total_Payments as Payments_Applied
			,Balance
			,Ship_To
			,Distributor_Name
		FROM	##tmp_Log_5000_Budgets_Perpetual_Report
		ORDER BY Budget_Code, Distributor_Name, Period_Start		
	</cfquery>	
	<cfset ClientVariables = "Budget Code, Period, Period Start, Period End, Gross Budget Amount, Drop Off Amount, Final Budget Amount, Payments, Balance, Customer Number, Customer Name">
	<cfscript>
		local.buffer  = createObject( "java", "java.lang.StringBuffer" ).Init();
		local.newLine = chr(13) & chr(10);
		// column heading row
		local.buffer.append(javaCast("string", "#ClientVariables#" & local.newLine));
	</cfscript>

	<!--- body content --->
	 <cfloop query="DropOffReport">
	<!--- append row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
		<cfset csvString =   '="' & Budget_Code & '"'
								& ',="' & Period & '"'
								& ',="' & Period_Start & '"'
								& ',="' & Period_End & '"'
								& ',="' & Budget_Amount & '"'
								& ',="' & Drop_Off & '"'
								& ',="' & Final_Budget_Amount & '"'
								& ',="' & Payments_Applied & '"'
								& ',="' & Balance & '"'
								& ',="' & Ship_To & '"'
								& ',="' & Distributor_Name & '"'/>

		<cfset csvString = csvString & local.newLine />
		<cfset local.buffer.append(javaCast("string",  csvString))>
	</cfloop>
			
	<cfreturn local.buffer>
</cffunction>