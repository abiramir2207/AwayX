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
		case "program_volume":
				variables.textResult = application.util.query.queryToCSV( program_volume( url.program_id, url.contract_span ) );
				break;

		case "commodity":
				variables.textResult = application.util.query.queryToCSV( getCommodity( URL ) );
				break;

		case "dd_search":
				// url.savedSearch has the name of the objectsave() file which includes all search criteria in it
				variables.textResult = dd_search( url.savedSearch );
				break;

		case "billback_search":
				// url.savedSearch has the name of the objectsave() file which includes all search criteria in it
				variables.textResult = billback_search( url.savedSearch );
				break;

		case "budgetCommitted":
				variables.textResult = application.util.query.queryToCSV( budgetCommitted( URL.budget_id ) );
				break;

		case "budgetActual":
				variables.textResult = application.util.query.queryToCSV( budgetActual( URL.budget_id ) );
				break;
	/* We need to show item level data and so we will call the "getPaymentHistoryItemLevelData" function and not the "getPaymentHistoryByDate"" function */
		case "getPaymentHistoryByDate":
				variables.textResult = Call_getPaymentHistoryItemLevelData( contract_number = URL.contract_number, contractId = URL.contractId, type_code_desc_id = URL.type_code_desc_id, type = URL.payment_type,
												payee = URL.payee, settlement_id = URL.settlement_id,start_date_operator=URL.start_date_operator,
												end_date_operator=URL.end_date_operator, date_criteria_start=URL.date_criteria_start, date_criteria_end=URL.date_criteria_end, plannerId = URL.plannerId );
				break;

		case "getPaymentHistoryItemLevelData":
				variables.textResult = Call_getPaymentHistoryItemLevelData( contract_number = URL.contract_number, contractId = URL.contractId, yearMonthList = URL.yearMonthList,
													type_code_desc_id = URL.type_code_desc_id, type = URL.payment_type, payee = URL.payee, settlement_id = URL.settlement_id, plannerId = URL.plannerId );
				break;

		case "getOperatorOffInvoiceByDate":
				variables.textResult = Call_getOperatorOffInvoiceDataDetails( contract_number=URL.contract_number, contractMainID=URL.contractMainID, payee=URL.payee, offinvoice_number=URL.offinvoice_number, item_number=URL.item_number,
						start_date_operator=URL.start_date_operator, end_date_operator=URL.end_date_operator, date_criteria_start=URL.date_criteria_start, date_criteria_end=URL.date_criteria_end, filteredInvoices=URL.filteredInvoices, plannerId = URL.plannerId );
				break;

		case "getOperatorOffInvoiceDataDetails":
				variables.textResult = Call_getOperatorOffInvoiceDataDetails( contract_number=URL.contract_number, contractMainID=URL.contractMainID, yearMonthList = URL.yearMonthList,payee=URL.payee,
													offinvoice_number=URL.offinvoice_number,item_number=URL.item_number, plannerId = URL.plannerId );
				break;

		case "getProgramPayeesNotClaimingOrPurchasing":
				variables.textResult = application.util.query.queryToCSV( call_getProgramPayeesNotClaimingOrPurchasing( URL.contract_number,URL.contractId ), 'Payee_Type, Payee_ID, Payee_Name');
				break;

		case "getItemsOnProgramNotClaimedOrPurchased":
				variables.textResult = call_getItemsOnProgramNotClaimedOrPurchased( URL.contract_number,URL.contractId );
				break;

		case "getPaymentHistoryItemsClaimedNotOnProgram":
				variables.textResult = call_getPaymentHistoryItemsClaimedNotOnProgram( URL.contract_number,URL.contractId );
				break;

		case "getpaymentdetails":
				variables.textResult = call_getpaymentdetails( URL.contract_number,URL.contractMainID,URL.type_code_desc_id,URL.payee,URL.start_date_operator,URL.end_date_operator,URL.date_criteria_start,URL.date_criteria_end,
										 URL.settlement_id,URL.billback_search,URL.productID,URL.filteredBB,URL.plannerId );
				break;

		case "getMarginTargetsData":
				variables.textResult = getMarginTargetsData();
				break;

		case "getProgramEstimatedAndForecastedToGoAndActualVolumeItems":
				variables.textResult = call_getProgramEstimatedAndForecastedToGoAndActualVolumeItems( URL.contract_number,URL.contractId,URL.program_uom );
				break;

		case "getProgramAccrualData":
				variables.textResult = call_getProgramAccrualData( URL.contract_number,URL.contractId, URL.plannerId );
				break;
		case "getOpenPayPeriods":
				variables.textResult = call_getOpenPayPeriods( URL.search_Start_Date,URL.search_End_Date );
				break;
//D60306 ::Exporting All Pages from Budgets and Volume Forecasts START
	case "productsDetail":
				variables.textResult = call_getProdcutsForVolumeForecast( URL.v451 );
				break;
	case "listBudgets":
				variables.textResult = call_getBudgetslist( url.segmentIsOn, url.userBusinessSegments, url.byClassIDs, url.sSearch , url.byBudgetCodes , url.byGroupIDs , url.byBudgetTypeIDs , url.bySegmentIDs);
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

				case "CustomerSystemMasterData":
				variables.textResult = call_CustomerSystemMasterData( );
				break;
				case "ProductSystemMasterData":
				variables.textResult = call_ProdcutSystemMasterData( );
				break;
				case "OperatorSystemMasterData":
				variables.textResult = call_OperatorSystemMasterData( );
				break;

		case "DropOffReport":
				variables.textResult = call_getDropOffReport();
				break;

		case "getAvailableDistributors":
				variables.textResult = call_getAvailableDistributors();
				break;

		case "Component_Report":
				variables.textResult = application.util.query.queryToCSV( Component_Report( url.CompType ) );
				break;

		case "Segment_Report":
				variables.textResult = application.util.query.queryToCSV( Segment_Report( ) );
				break;

		case "getBlanketBidInfo":
				variables.textResult = call_getBlanketBidInfo( contract_main_id=URL.contract_main_id, uom_type=URL.uom_type, margin_version = URL.margin_version,contract_status=URL.contract_status);
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
				variables.textResult = call_getProgramAccrualDistributorItemData(contractNumber=form.contract_number, contractMainID=form.ContractId, distributorComponentList=form.distributorComponentList, selectedProductAttribute=form.selectedProductAttribute, selectedProductAttributeText = form.selectedProductAttributeText, plannerId=form.plannerId );
				break;

		case "getProgramAccrualDistributorFiscalPeriodData":
				variables.textResult = call_getProgramAccrualDistributorFiscalPeriodData(contractNumber=form.contract_number, contractMainID=form.ContractId, distributorComponentList=form.distributorComponentList, distributorIdList = form.distributorIdList, plannerId=form.plannerId  );
				break;

		case "getpaymentitemleveldetails":
				variables.textResult = call_getpaymentitemleveldetails( form.paymentIds, form.contract_number, form.ContractId, form.total_rate, form.total_vol_lb, form.total_vol_cs, form.plannerId );
				break;

		case "getProgramsData":
				variables.textResult = call_getProgramsData();
				break;

		case "getSettlementsData":
				variables.textResult = application.util.query.queryToCSV(call_getSettlementsData(stForm = form));
				break;
		case "getAliasData":
				if(isStruct(form.filterModel)){
					variables.filter_model = DeserializeJSON(form.filterModel);
				}
				else{
					variables.filter_model = #StructNew()#;
				}
				variables.textResult = call_getAliasData(entityType = form.entity_type, sourceType = form.source_type, sourceID = form.source_id, filterModel =  variables.filter_model);
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

<cffunction name="getCommodity" returntype="query" output="false">
	<cfargument name="info" required="true" type="struct">

	<cfscript>
		// parse search string into an array of words
		if ( len(info.searchString) ) {
				tmp.arrayOfWords = reMatch( "[[:word:]]+", info.searchString );
		}
		else {
				tmp.arrayOfWords = [];
		}

		// concatenate array of words into a long string delimited by % ( for SQL LIKE condition )
		tmp.listOfWords = arrayToList(tmp.arrayOfWords, "%");
	</cfscript>

	<!--- this query was copied from ajaxSearchCommodityPrices.cfm :: any changes in this query should go to the other file as well --->
	<cfquery name="local.qCommodities" datasource="#application.datasource#">
		SELECT
				Symbol,
				replace(cs.Symbol_Description, cs.Symbol + ':', '') as Symbol_Description,
				Comm_Last,
				Comm_High,
				Comm_Low,
				C.Comm_Open as Comm_Wtd_Avg,
				CONVERT(Varchar(10),Comm_Datetime,101) AS Comm_Datetime,
				Category_Name,
				Sub_Category_Name,
				CED.Exchange_Detail_Abrev,
				Exchange_Detail_Name
		FROM    Commodities_Symbol CS
		INNER JOIN Commodities C ON
				C.Commodities_Symbol_ID = cs.Commodities_Symbol_ID
		-- INNER JOIN Commodities_Report_Log L On
		-- 		l.Report_Date = C.Comm_Datetime AND
		-- 		L.Exchange_Detail_ID = CS.Exchange_Detail_ID
		LEFT JOIN Commodities_Sub_Category CSC ON
				C.Sub_Category_ID = CSC.Sub_Category_ID
		INNER JOIN Commodities_Category CC ON
				CC.Category_ID = C.Category_ID
		INNER JOIN Commodities_Exchange_Detail CED ON
				CED.Exchange_Detail_ID = CS.Exchange_Detail_ID
		WHERE C.Comm_Datetime
						<cfif len(info.commDate)>
								= '#info.commDate#'
						<cfelse>
								> DATEADD(DAY,-712,getdate())
						</cfif>
							<!--- quick search at the top left --->
							<cfif len( tmp.listOfWords )>
																AND (    Symbol LIKE '%#tmp.listOfWords#%'
																			OR Comm_Last LIKE '%#tmp.listOfWords#%'
																			OR Sub_Category_Name LIKE '%#tmp.listOfWords#%'
																			OR Comm_High LIKE '%#tmp.listOfWords#%'
																			OR Comm_Low LIKE '%#tmp.listOfWords#%'
																			OR Comm_Datetime LIKE '%#tmp.listOfWords#%'
																			OR Category_Name LIKE '%#tmp.listOfWords#%'
																			OR CED.Exchange_Detail_Abrev LIKE '%#tmp.listOfWords#%'
																			OR Exchange_Detail_Name LIKE '%#tmp.listOfWords#%'
																			OR Symbol_Description LIKE '%#tmp.listOfWords#%'
																		)
							</cfif>
							<cfif len( info.Symbol )>
																AND (    Symbol LIKE '%#info.Symbol#%' OR Symbol_Description LIKE '%#info.Symbol#%' )
									</cfif>
									<cfif len( info.Sub_Category_Name )>
																		AND (    Sub_Category_Name LIKE '%#info.Sub_Category_Name#%'  )
									</cfif>
									<cfif len( info.Exchange_Detail_Abrev )>
																		AND (    CED.Exchange_Detail_Abrev LIKE '%#info.Exchange_Detail_Abrev#%'  )
									</cfif>
			ORDER BY  C.Comm_Datetime DESC

							<!--- NOT SURE WHY THIS WAS HERE.  NO "order_direction" IS IMPLEMENTED.
							<cfswitch expression="#listFirst(info.order_direction)#">
								<cfcase value='0'> ORDER BY  Symbol      #listLast(info.order_direction)# </cfcase>
								<cfcase value='1'> ORDER BY  Comm_Last   #listLast(info.order_direction)# </cfcase>
								<cfcase value='2'> ORDER BY  Comm_High   #listLast(info.order_direction)# </cfcase>
								<cfcase value='3'> ORDER BY  Comm_Low    #listLast(info.order_direction)# </cfcase>
								<cfcase value='4'> ORDER BY  C.Comm_Datetime   #listLast(info.order_direction)# </cfcase>
								<cfcase value='5'> ORDER BY  Category_Name     #listLast(info.order_direction)# </cfcase>
								<cfcase value='6'> ORDER BY  Sub_Category_Name #listLast(info.order_direction)# </cfcase>
								<cfcase value='7'> ORDER BY  CED.Exchange_Detail_Abrev #listLast(info.order_direction)# </cfcase>
								<cfcase value='8'> ORDER BY  Exchange_Detail_Name      #listLast(info.order_direction)# </cfcase>
								<cfdefaultcase> ORDER BY C.Comm_Datetime desc</cfdefaultcase>
							 </cfswitch> --->
	</cfquery>

	<cfreturn local.qCommodities>
</cffunction>

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
			 <cfset program_columns = ",Program,Program Title,Program Template, Operator ID">
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
											& ',"'  & local.billbacks.BBOperator_ID & '"'
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

<cffunction name="call_getItemsOnProgramNotClaimedOrPurchased" returntype="string">
	<cfargument name="contract_number" required="true">
	<cfargument name="contractMainID" required="true" type="string" />

	<cfinvoke
		component="components.programs.paymenthistory.PaymentHistoryManager"
		method="getItemsOnProgramNotClaimedOrPurchased"
		returnvariable="qGetItemsOnProgramNotClaimedOrPurchased">

		<cfinvokeargument name="contract_number" 	value="#arguments.contract_number#">
		<cfinvokeargument name="contractMainID"	value="#arguments.contractMainID#">
		</cfinvoke>

		<cfscript>
				local.buffer  = createObject( "java", "java.lang.StringBuffer" ).Init();
				local.newLine = chr(13) & chr(10);

				// column heading row
				local.buffer.append(javaCast("string", "#application.util.string.fcase(application.returned_customer_setting.item_label)#, Description"
																								& local.newLine));
		</cfscript>
		<!--- body content --->

		<cfloop query="qGetItemsOnProgramNotClaimedOrPurchased">
				<!--- append row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
				<cfset local.buffer.append(javaCast("string",     '="'  & Item & '"'
																												& ',"' & Description & '"'
																												& local.newLine  ))>
		</cfloop>
		<cfreturn local.buffer>
</cffunction>


<cffunction name="call_getAvailableDistributors" returntype="string">

	<cfinvoke component="components.billback.BillbackAssignmentManager" method="getAvailableDistributors" returnvariable="qGetAvailableDistributors"></cfinvoke>

		<cfscript>
				local.buffer  = createObject( "java", "java.lang.StringBuffer" ).Init();
				local.newLine = chr(13) & chr(10);
				// column heading row
				local.buffer.append(javaCast("string", "Distributor ID, Name" & local.newLine));
		</cfscript>
		<!--- body content --->

		<cfloop query="qGetAvailableDistributors">
				<!--- append row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
				<cfset local.buffer.append(javaCast("string",     '="'  & Ship_To & '"' & ',"' & name & '"' 	& local.newLine  ))>
		</cfloop>
		<cfreturn local.buffer>
</cffunction>


<cffunction name="call_getPaymentHistoryItemsClaimedNotOnProgram" returntype="string">
	<cfargument name="contract_number" required="true">
	<cfargument name="contractMainID" required="true" type="string" />

	<cfinvoke
		component="components.programs.paymenthistory.PaymentHistoryManager"
		method="getPaymentHistoryItemsClaimedNotOnProgram"
		returnvariable="qGetPaymentHistoryItemsClaimedNotOnProgram">

		<cfinvokeargument name="contract_number"	value="#arguments.contract_number#">
		<cfinvokeargument name="contractMainID"	value="#arguments.contractMainID#">
	</cfinvoke>

		<cfscript>
				local.buffer  = createObject( "java", "java.lang.StringBuffer" ).Init();
				local.newLine = chr(13) & chr(10);

				// column heading row
				local.buffer.append(javaCast("string", "#application.util.string.fcase(application.returned_customer_setting.item_label)#, Description, Dollars, Cases, Pounds"
																								& local.newLine));
		</cfscript>
		<!--- body content --->

		<cfloop query="qGetPaymentHistoryItemsClaimedNotOnProgram">
				<!--- append row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
				<cfset local.buffer.append(javaCast("string",     '="'  & Item & '"'
																												& ',"' & Description & '"'
																												& ',"' & NumberFormat(Sales_Dollars,"(___,___,___.__)") & '"'
																												& ',"' & NumberFormat(Volume_Cs,"(___,___,___,___)") & '"'
																												& ',"' & NumberFormat(Volume_Lb,"(___,___,___,___)") & '"'
																												& local.newLine  ))>
		</cfloop>
		<cfreturn local.buffer>
</cffunction>


<cffunction name="call_getpaymentdetails" returntype="string">
	<cfargument name="contract_number" required="true" type="string" />
	<cfargument name="contractMainID" required="true" type="string" />
	<cfargument name="type_code_desc_id" type="string" required="false" />
	<cfargument name="payee" type="string" required="false" />
	<cfargument name="start_date_operator" type="string" required="false" />
	<cfargument name="end_date_operator" type="string" required="false" />
	<cfargument name="date_criteria_start" type="string" required="false" />
	<cfargument name="date_criteria_end" type="string" required="false" />
	<cfargument name="settlement_id" type="string" required="false" />
	<cfargument name="billback_search" type="string" required="false" />
	<cfargument name="productID" type="string" required="false" default="" />
	<cfargument name="filteredBB" type="string" required="false" default="" />
	<cfargument name="plannerID" type="string" required="false" default="0" />

	<cfinvoke
		component="components.programs.paymenthistory.PaymentHistoryManager"
		method="getpaymentdetails"
		returnvariable="qGetpaymentdetails">

		<cfinvokeargument name="contract_number"	value="#arguments.contract_number#">
		<cfinvokeargument name="contractMainID"	value="#arguments.contractMainID#">
		<cfinvokeargument name="type_code_desc_id"	value="#arguments.type_code_desc_id#">
		<cfinvokeargument name="payee"			value="#arguments.payee#">
		<cfinvokeargument name="start_date_operator"	value="#arguments.start_date_operator#">
		<cfinvokeargument name="end_date_operator"	value="#arguments.end_date_operator#">
		<cfinvokeargument name="date_criteria_start"	value="#arguments.date_criteria_start#">
		<cfinvokeargument name="date_criteria_end"	value="#arguments.date_criteria_end#">
		<cfinvokeargument name="settlement_id"		value="#arguments.settlement_id#">
		<cfinvokeargument name="billback_search"	value="#arguments.billback_search#">
		<cfinvokeargument name="productID"			value="#arguments.productID#">
		<cfinvokeargument name="filteredBB"          value="#arguments.filteredBB#">
		<cfinvokeargument name="plannerID"          value="#arguments.plannerID#">
	</cfinvoke>

		<cfscript>
				local.buffer  = createObject( "java", "java.lang.StringBuffer" ).Init();
				local.newLine = chr(13) & chr(10);

				// column heading row
		local.buffer.append(javaCast("string", "#billbackLabel# ##,#billbackLabel# Title,Payable ##,Payee Name,Payee ##,Start Date,End Date,Paid $,Settlement ID,"));
		local.buffer.append(javaCast("string", "Date Paid,Pounds, Avg Rate (Pounds),Cases, Avg Rate (Cases)" & local.newLine));

		</cfscript>
		<!--- body content --->

		<cfloop query="qGetpaymentdetails.queryResults">
				<!--- append row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
				<cfset local.buffer.append(javaCast("string",     '"'  & BB_Reference & '"'
																												& ',"' & BB_Title & '"'
																												& ',"' & BB_Code & '"'
																												& ',"' & Payee_Name & '"'
																												& ',="' & payee_id & '"'
																												& ',"' & dateformat(BB_start_date,"mm/dd/yyyy") & '"'
																												& ',"' & dateformat(BB_End_date,"mm/dd/yyyy") & '"'
																												& ',"' & NumberFormat(paid_amount,"(___,___,___.__)") & '"'
																												& ',"' & Check_Number & '"'
																												& ',"' & dateformat(check_date,"mm/dd/yy") & '"'
																												& ',"' & numberformat(volume_lb,'_,') & '"'
																												& ',"' & numberformat(avg_rate_lb,'(_,.____') & '"'
																												& ',"' & numberformat(volume_cs,'_,') & '"'
																												& ',"' & numberformat(avg_rate_cs,'(_,.____') & '"'
																												& local.newLine  ))>
		</cfloop>
		<cfreturn local.buffer>
</cffunction>

<cffunction name="call_getpaymentitemleveldetails" returntype="string">
	<cfargument name="paymentIDs" required="true">
	<cfargument name="contract_number" required="true">
	<cfargument name="ContractId" required="true">
	<cfargument name="total_rate" required="true">
	<cfargument name="total_vol_lb" required="true">
	<cfargument name="total_vol_cs" required="true">
	<cfargument name="plannerID" type="string" required="false" default="0" />

	<cfinvoke
		component="components.programs.paymenthistory.PaymentHistoryManager"
		method="getpaymentitemleveldetails"
		returnvariable="qGetpaymentitemleveldetails">

		<cfinvokeargument name="paymentIDs"	value="#arguments.paymentIDs#">
		<cfinvokeargument name="contract_number"	value="#arguments.contract_number#">
		<cfinvokeargument name="contractMainID"	value="#arguments.ContractId#">
		<cfinvokeargument name="plannerID"          value="#arguments.plannerID#">

	</cfinvoke>

		<cfscript>
				local.buffer  = createObject( "java", "java.lang.StringBuffer" ).Init();
				local.newLine = chr(13) & chr(10);

				// column heading row
				local.buffer.append(javaCast("string", "#application.util.string.fcase(application.returned_customer_setting.item_label)#, Description, Tot Dollars, % of Tot Dollars, Tot #Application.UOMPoundPlural#,"));
				local.buffer.append(javaCast("string", "% of Tot #Application.UOMPoundPlural#, Tot #Application.UOMCasePlural#, % of Tot #Application.UOMCasePlural#" & local.newLine));
		</cfscript>
		<!--- body content --->

<cfif arguments.total_vol_lb EQ 0>
	<cfset arguments.total_vol_lb = 1>
</cfif>
<cfif arguments.total_vol_cs EQ 0>
	<cfset arguments.total_vol_cs = 1>
</cfif>

		<cfloop query="qGetpaymentitemleveldetails">

		<cfif (arguments.total_rate neq 0 and arguments.total_rate neq "")>
			<cfset percent_tot_dollars = numberFormat(qGetpaymentitemleveldetails.rate / arguments.total_rate * 100, "_,")>
		<cfelse>
			cfset percent_tot_dollars = "">
		</cfif>

		<cfif (arguments.total_rate neq 0 and arguments.total_vol_lb neq "")>
			<cfset percent_tot_pounds = numberFormat(qGetpaymentitemleveldetails.volume_lb / arguments.total_vol_lb * 100, "_,")>
		<cfelse>
			cfset percent_tot_pounds = "">
		</cfif>

		<cfif (arguments.total_rate neq 0 and arguments.total_vol_cs neq "")>
			<cfset percent_tot_cases = numberFormat(qGetpaymentitemleveldetails.volume_cs / arguments.total_vol_cs * 100, "_,")>
		<cfelse>
			cfset percent_tot_cases = "">
		</cfif>

				<!--- append row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
				<cfset local.buffer.append(javaCast("string",     '="'  & Item & '"'
																												& ',"' & Description & '"'
																												& ',"' & NumberFormat(qGetpaymentitemleveldetails.rate,"(______________.__)") & '"'
																												& ',"' & percent_tot_dollars & '"'
																												& ',"' & numberFormat(qGetpaymentitemleveldetails.volume_lb, "_,") & '"'
																												& ',"' & percent_tot_pounds & '"'
																												& ',"' & numberFormat(qGetpaymentitemleveldetails.volume_cs, "_,") & '"'
																												& ',"' & percent_tot_cases & '"'
																												& local.newLine  ))>
		</cfloop>
		<cfreturn local.buffer>
</cffunction>

<cffunction name="Call_getOperatorOffInvoiceDataDetails" output="false" returntype="string">
	<cfargument name="contract_number" required="true">
	<cfargument name="contractMainID" required="true" type="string" />
	<cfargument name="yearMonthList" type="string" required="false" default="" />
	<cfargument name="payee" type="string" required="false"  default=""/>/>
	<cfargument name="offinvoice_number" type="string" required="false"  default="" />
	<cfargument name="item_number" type="string" required="false" default="" />
	<cfargument name="start_date_operator" type="string" required="false" default="" />
	<cfargument name="end_date_operator" type="string" required="false" default="" />
	<cfargument name="date_criteria_start" type="string" required="false" default="" />
	<cfargument name="date_criteria_end" type="string" required="false" default="" />
	<cfargument name="filteredInvoices" type="string" required="false" default="" />
	<cfargument name="plannerID" type="string" required="false" default="0" />

<!--- "filteredResults" from the returned structure contains the query results. --->
	<cfinvoke
		component="components.programs.paymenthistory.PaymentHistoryManager"
		method="getOperatorOffInvoiceDataDetails"
		returnvariable="qGetOperatorOffInvoiceDataDetails">

		<cfinvokeargument name="contract_number" 	value="#arguments.contract_number#">
		<cfinvokeargument name="contractMainID" 	value="#arguments.contractMainID#">
		<cfinvokeargument name="yearMonthList"	value="#arguments.yearMonthList#">
		<cfinvokeargument name="payee" 	value="#arguments.payee#">
		<cfinvokeargument name="offinvoice_number" 	value="#arguments.offinvoice_number#">
		<cfinvokeargument name="item_number" 	value="#arguments.item_number#">
		<!--- These 4 arguments below are for the csv report which gets created from the OffInvoice history
		summary report screen (main offinvoice screen).
		--->
		<cfinvokeargument name="start_date_operator"	value="#arguments.start_date_operator#">
		<cfinvokeargument name="end_date_operator" 	value="#arguments.end_date_operator#">
		<cfinvokeargument name="date_criteria_start"	value="#arguments.date_criteria_start#">
		<cfinvokeargument name="date_criteria_end" value="#arguments.date_criteria_end#">
		<cfinvokeargument name="filteredInvoices"          value="#arguments.filteredInvoices#">
		<cfinvokeargument name="plannerID"          value="#arguments.plannerID#">
		</cfinvoke>

		<cfscript>
				local.buffer  = createObject( "java", "java.lang.StringBuffer" ).Init();
				local.newLine = chr(13) & chr(10);

				// column heading row
		local.buffer.append(javaCast("string", "Invoice Number, Invoice Date, #application.returned_customer_setting.item_label#, Description, Dollars, Cases, Pounds,"));
		local.buffer.append(javaCast("string", "#application.returned_customer_setting.distributor_label_singular#, Name" & local.newLine));


		</cfscript>
		<!--- body content --->

		<cfloop query="qGetOperatorOffInvoiceDataDetails.filteredResults">
				<!--- append row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
				<cfset local.buffer.append(javaCast("string",     '"'  & Invoice_number & '"'
																												& ',"' & Invoice_Date & '"'
																												& ',="' & Item & '"'
																												& ',"' & Description & '"'
																												& ',"' & NumberFormat(Sales_Dollars,"(___,___,___.__)") & '"'
																												& ',"' & NumberFormat(Volume_CS, "_,___,___,___,___") & '"'
																												& ',"' & NumberFormat(Volume_LB, "_,___,___,___,___") & '"'
																												& ',="' & Shr_ship_to & '"'
																												& ',"' & Ship_to_name & '"'
																												& local.newLine  ))>
		</cfloop>
		<cfreturn local.buffer>
</cffunction>

<cffunction name="Call_getPaymentHistoryItemLevelData" output="false" returntype="string">
	<cfargument name="contract_number" required="true">
	<cfargument name="contractId" required="true">
	<cfargument name="yearMonthList" type="string" required="false" default="" />
	<cfargument name="type_code_desc_id" type="string" required="false"  default=""/>
	<cfargument name="type" type="string" required="false"  default="" />
	<cfargument name="payee" type="string" required="false" default="" />
	<cfargument name="settlement_id" type="string" required="false" default="" />
	<cfargument name="start_date_operator" type="string" required="false" default="" />
	<cfargument name="end_date_operator" type="string" required="false" default="" />
	<cfargument name="date_criteria_start" type="string" required="false" default="" />
	<cfargument name="date_criteria_end" type="string" required="false" default="" />
	<cfargument name="plannerId" type="string" required="false" default="0" />

	<cfinvoke
		component="components.programs.paymenthistory.PaymentHistoryManager"
		method="getPaymentHistoryItemLevelData"
		returnvariable="qGetPaymentHistoryItemLevelData">

		<cfinvokeargument name="contract_number"	value="#arguments.contract_number#">
		<cfinvokeargument name="contractId"	value="#arguments.contractId#">
		<cfinvokeargument name="yearMonthList"	value="#arguments.yearMonthList#">
		<cfinvokeargument name="type_code_desc_id" 	value="#arguments.type_code_desc_id#">
		<cfinvokeargument name="type" 	value="#arguments.type#">
		<cfinvokeargument name="payee" 	value="#arguments.payee#">
		<cfinvokeargument name="settlement_id" 	value="#arguments.settlement_id#">
		<!---  These 4 arguments below are for the csv report which gets created from the
		main payment history summary report screen (default payment hostory screen).
		--->
		<cfinvokeargument name="start_date_operator"	value="#arguments.start_date_operator#">
		<cfinvokeargument name="end_date_operator" 	value="#arguments.end_date_operator#">
		<cfinvokeargument name="date_criteria_start"	value="#arguments.date_criteria_start#">
		<cfinvokeargument name="date_criteria_end" value="#arguments.date_criteria_end#">
		<cfinvokeargument name="plannerId" value="#arguments.plannerId#">
		</cfinvoke>

		<cfscript>
				local.buffer  = createObject( "java", "java.lang.StringBuffer" ).Init();
				local.newLine = chr(13) & chr(10);

				// column heading row
		local.buffer.append(javaCast("string", "#application.returned_customer_setting.item_label#, Description, Dollars, Cases, Pounds,"));
		local.buffer.append(javaCast("string", "#application.returned_customer_setting.item_label# on program" & local.newLine));
		</cfscript>
		<!--- body content --->

		<cfloop query="qGetPaymentHistoryItemLevelData">
		<cfif Item_not_On_program eq 0>
			<cfset ItemNotOnProgram = 'Yes'>

		<cfelseif Item_not_On_program eq 1>
			<cfset ItemNotOnProgram = 'No'>

		<cfelseif Item_not_On_program eq "">
			<cfset ItemNotOnProgram = 'N/A'>
		</cfif>

				<!--- append row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
				<cfset local.buffer.append(javaCast("string",     '="'  & Item & '"'
																												& ',"' & Description & '"'
																												& ',"' & NumberFormat(Sales_Dollars,"(___,___,___.__)") & '"'
																												& ',"' & NumberFormat(Volume_CS, "_,___,___,___,___") & '"'
																												& ',"' & NumberFormat(Volume_LB, "_,___,___,___,___") & '"'
																												& ',"' & ItemNotOnProgram & '"'
																												& local.newLine  ))>
		</cfloop>
		<cfreturn local.buffer>
</cffunction>

<cffunction name="call_getProgramPayeesNotClaimingOrPurchasing" output="false" returntype="query">
	<cfargument name="contract_number" required="true">
	<cfargument name="contractMainID" required="true" type="string" />

	<cfinvoke
		component="components.programs.paymenthistory.PaymentHistoryManager"
		method="getProgramPayeesNotClaimingOrPurchasing"
		returnvariable="qGetProgramPayeesNotClaimingOrPurchasing">

		<cfinvokeargument name="contract_number" 	value="#arguments.contract_number#">
		<cfinvokeargument name="contractMainID" 	value="#arguments.contractMainID#">
		</cfinvoke>

	<cfreturn qGetProgramPayeesNotClaimingOrPurchasing>
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

<cffunction name="call_getProgramEstimatedAndForecastedToGoAndActualVolumeItems" output="false" returntype="string">
	<cfargument name="contractNumber" required="true" type="string" />
	<cfargument name="contractId" required="true" type="string" />
	<cfargument name="programUOM" required="true" type="string" />

	<cfinvoke
		component="components.programs.paymenthistory.PaymentHistoryManager"
		method="getProgramEstimatedAndForecastedToGoAndActualVolumeItems"
		returnvariable="qGetProgramEstimatedAndForecastedToGoAndActualVolumeItems">

		<cfinvokeargument name="contractNumber" value="#arguments.contractNumber#">
		<cfinvokeargument name="contractId" value="#arguments.contractId#">
		</cfinvoke>

				<cfscript>
				local.buffer  = createObject( "java", "java.lang.StringBuffer" ).Init();
				local.newLine = chr(13) & chr(10);

				// column heading row
		local.buffer.append(javaCast("string", "#application.returned_customer_setting.item_label#, Description, Original estimated volume (#trim(arguments.programUOM)#), Actual volume (#trim(arguments.programUOM)#),"));
		local.buffer.append(javaCast("string", "Forecasted to go volume (#trim(arguments.programUOM)#), Volume variance (#trim(arguments.programUOM)#)" & local.newLine));
		</cfscript>

		<!--- body content --->
				<cfloop query="qGetProgramEstimatedAndForecastedToGoAndActualVolumeItems.filteredResults">

				<!--- append row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
				<cfset local.buffer.append(javaCast("string",     '="'  & Item & '"'
																												& ',"' & Description & '"'
																												& ',"' & NumberFormat(Estimated_Volume, "_,___,___,___,___") & '"'
																												& ',"' & NumberFormat(Actual_Volume, "_,___,___,___,___") & '"'
																												& ',"' & NumberFormat(Forecasted_To_Go_Volume, "_,___,___,___,___") & '"'
																												& ',"' & NumberFormat(variance, "_,___,___,___,___") & '"'
																												& local.newLine  ))>
				</cfloop>
		<cfreturn local.buffer>
</cffunction>

<cffunction name="call_getProgramAccrualData" output="false" returntype="string">
	<cfargument name="contractNumber" required="true" type="string" />
	<cfargument name="contractMainID" required="true" type="string" />
	<cfargument name="plannerId" required="false" type="string" default="0" />

	<cfset columnSequenceNumber = 1 />

	<cfinvoke
		component="components.programs.paymenthistory.PaymentHistoryManager"
		method="getProgramAccrualData"
		returnvariable="qGetProgramAccrualData">
		<cfinvokeargument name="contractNumber" value="#arguments.contractNumber#">
		<cfinvokeargument name="contractMainID" value="#arguments.contractMainID#">
		<cfinvokeargument name="plannerId" value="#arguments.plannerId#">
		<cfinvokeargument name="column_sequence_number" value="#columnSequenceNumber#">


	</cfinvoke>

	<cfinvoke
		component="components.programs.paymenthistory.PaymentHistoryManager"
		method="getDeductionAccountExist"
		returnvariable="getDeductionAccountExist">
		<cfinvokeargument name="contract_Number" value="#arguments.contractNumber#">
		<cfinvokeargument name="contractMainID" value="#arguments.contractMainID#">
		<cfinvokeargument name="plannerId" value="#arguments.plannerId#">
	</cfinvoke>

	<cfinvoke
		component="components.programs.paymenthistory.PaymentHistoryManager"
		method="getPaymentAccountExist"
		returnvariable="getPaymentAccountExist">
		<cfinvokeargument name="contract_Number" value="#arguments.contractNumber#">
		<cfinvokeargument name="contractMainID" value="#arguments.contractMainID#">
		<cfinvokeargument name="plannerId" value="#arguments.plannerId#">
	</cfinvoke>

	<cfinvoke
		component="components.programs.paymenthistory.PaymentHistoryManager"
		method="getGLAccountExist"
		returnvariable="getGLAccountExist">
		<cfinvokeargument name="contract_Number" value="#arguments.contractNumber#">
		<cfinvokeargument name="contractMainID" value="#arguments.contractMainID#">
		<cfinvokeargument name="plannerId" value="#arguments.plannerId#">
	</cfinvoke>

	<cfscript>
	local.buffer  = createObject( "java", "java.lang.StringBuffer" ).Init();
	local.newLine = chr(13) & chr(10);

	// column heading row
	local.buffer.append(javaCast("string", "Program,"));

	local.buffer.append(javaCast("string", "#application.returned_customer_setting.distributor_label_singular#, #application.returned_customer_setting.distributor_label_singular# Name,"));
	if(getDeductionAccountExist eq 1){
		local.buffer.append(javaCast("string", "Ded Acct,"));
	}
	if(getPaymentAccountExist eq 1){
		local.buffer.append(javaCast("string", "Pymt Acct,"));
	}
	if(getGLAccountExist eq 1){
		local.buffer.append(javaCast("string", "GL Acct,"));
	}
	local.buffer.append(javaCast("string", "Comp ID, Component, Cases, Accrual $" & local.newLine));
	</cfscript>

	<!--- body content --->
	<cfloop query="qGetProgramAccrualData.filteredResults">
		<!--- append row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
		<cfset local.buffer.append(javaCast("string",   '="' & contract_number & '"'))>
		<cfset local.buffer.append(javaCast("string",     ',="'  & Ship_To & '"'
															& ',"' & Ship_To_Name & '"'))>

		<cfif getDeductionAccountExist eq 1>
				<cfset local.buffer.append(javaCast("string",   ',="' & Deduction_Account & '"'))>
		</cfif>
		<cfif getPaymentAccountExist eq 1>
				<cfset local.buffer.append(javaCast("string",   ',="' & Payment_Account & '"'))>
		</cfif>
		<cfif getGLAccountExist eq 1>
				<cfset local.buffer.append(javaCast("string",   ',="' & GL_Account_Desc & '"'))>
		</cfif>

		<cfset local.buffer.append(javaCast("string",   ',"' & External_ID & '"'
																& ',"' & Component_Name & '"'
																& ',"' & NumberFormat(Cases_Invoiced, "_,___,___,___,___") & '"'
																& ',"' & DollarFormat(Amount) & '"'
															& local.newLine  ))>
	</cfloop>
		<cfreturn local.buffer>
</cffunction>


<cffunction name="call_getProgramAccrualDistributorItemData" output="false" returntype="string">
	<cfargument name="contractNumber" required="true" type="string" />
	<cfargument name="contractMainID" required="true" type="string" />
	<cfargument name="distributorComponentList" required="true" type="string" />
	<cfargument name="selectedProductAttribute" required="true" type="string" />
	<cfargument name="selectedProductAttributeText" required="true" type="string" />
	<cfargument name="plannerId" required="false" type="string" default="0" />

	<cfinvoke
		component="components.programs.paymenthistory.PaymentHistoryManager"
		method="getProgramAccrualDistributorItemData"
		returnvariable="qGetProgramAccrualDistributorItemData">
		<cfinvokeargument name="contractNumber" value="#arguments.contractNumber#">
		<cfinvokeargument name="contractMainID" value="#arguments.contractMainID#">
		<cfinvokeargument name="distributorComponentList" value="#arguments.distributorComponentList#">
		<cfinvokeargument name="selectedProductAttribute" value="#arguments.selectedProductAttribute#">
		<cfinvokeargument name="plannerID" value="#arguments.plannerID#">

	</cfinvoke>

	<cfinvoke
		component="components.programs.paymenthistory.PaymentHistoryManager"
		method="getDeductionAccountExist"
		returnvariable="getDeductionAccountExist">
		<cfinvokeargument name="contract_Number" value="#arguments.contractNumber#">
		<cfinvokeargument name="contractMainID" value="#arguments.contractMainID#">
		<cfinvokeargument name="plannerID" value="#arguments.plannerID#">
	</cfinvoke>

	<cfinvoke
		component="components.programs.paymenthistory.PaymentHistoryManager"
		method="getPaymentAccountExist"
		returnvariable="getPaymentAccountExist">
		<cfinvokeargument name="contract_Number" value="#arguments.contractNumber#">
		<cfinvokeargument name="contractMainID" value="#arguments.contractMainID#">
		<cfinvokeargument name="plannerID" value="#arguments.plannerID#">
	</cfinvoke>

	<cfinvoke
		component="components.programs.paymenthistory.PaymentHistoryManager"
		method="getGLAccountExist"
		returnvariable="getGLAccountExist">
		<cfinvokeargument name="contract_Number" value="#arguments.contractNumber#">
		<cfinvokeargument name="contractMainID" value="#arguments.contractMainID#">
		<cfinvokeargument name="plannerID" value="#arguments.plannerID#">
	</cfinvoke>

	<cfscript>
	local.buffer  = createObject( "java", "java.lang.StringBuffer" ).Init();
	local.newLine = chr(13) & chr(10);

	// column heading row
	if(arguments.plannerID neq 0){
		local.buffer.append(javaCast("string", "Program,"));
	}

	local.buffer.append(javaCast("string", "#application.returned_customer_setting.item_label#, #application.returned_customer_setting.item_label# Desc,"));
	if(getDeductionAccountExist eq 1){
		local.buffer.append(javaCast("string", "Ded Acct,"));
	}
	if(getPaymentAccountExist eq 1){
		local.buffer.append(javaCast("string", "Pymt Acct, "));
	}
	if(getGLAccountExist eq 1){
		local.buffer.append(javaCast("string", "GL Acct, "));
	}
	local.buffer.append(javaCast("string", "Comp ID, Component, Cases, Accrual $, Rate, Rate UOM"  & local.newLine));
	//local.buffer.append(javaCast("string", selectedProductAttributeText & local.newLine));

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
	<cfif arguments.plannerID neq 0>
    	<cfset local.buffer.append(javaCast("string",   '="' & Contract_Number & '",'))>
    </cfif>

        <cfset local.buffer.append(javaCast("string", csvFormat(    '=' & qGetProgramAccrualDistributorItemData.filteredResults.Item
                                                                    ,qGetProgramAccrualDistributorItemData.filteredResults.Item_Description )) )>

        <cfset local.buffer.append(javaCast("string",   ','))>

		<cfif getDeductionAccountExist eq 1>
            <cfset local.buffer.append(javaCast("string",   '="' & Deduction_Account & '",'))>
        </cfif>
		<cfif getPaymentAccountExist eq 1>
            <cfset local.buffer.append(javaCast("string",   '="' & Payment_Account & '",'))>
        </cfif>
		<cfif getGLAccountExist eq 1>
            <cfset local.buffer.append(javaCast("string",   '="' & GL_Account_Desc & '",'))>
        </cfif>

        <cfset local.buffer.append(javaCast("string", csvFormat( qGetProgramAccrualDistributorItemData.filteredResults.External_ID
																,qGetProgramAccrualDistributorItemData.filteredResults.Component_Name
																,NumberFormat(qGetProgramAccrualDistributorItemData.filteredResults.Cases_Invoiced, "_,___")
																,DollarFormat(qGetProgramAccrualDistributorItemData.filteredResults.Amount)
																,rateDisplay
																,qGetProgramAccrualDistributorItemData.filteredResults.Rate_UOM
                                                                )))>
        <cfset local.buffer.append(javaCast("string", local.newLine))>
	</cfloop>

		<cfreturn local.buffer>
</cffunction>

<cffunction name="call_getProgramAccrualDistributorFiscalPeriodData" output="false" returntype="string">
	<cfargument name="contractNumber" required="true" type="string" />
	<cfargument name="contractMainID" required="true" type="string" />
	<cfargument name="distributorComponentList" required="true" type="string" />
	<cfargument name="distributorIdList" required="true" type="string" />
	<cfargument name="plannerId" required="false" type="string" default="0" />

	<cfinvoke
		component="components.programs.paymenthistory.PaymentHistoryManager"
		method="getProgramAccrualDistributorFiscalPeriodData"
		returnvariable="qGetProgramAccrualDistributorFiscalPeriodData">
		<cfinvokeargument name="contractNumber" value="#arguments.contractNumber#">
		<cfinvokeargument name="contractMainID" value="#arguments.contractMainID#">
		<cfinvokeargument name="distributorComponentList" value="#arguments.distributorComponentList#">
		<cfinvokeargument name="distributorIdList" value="#arguments.distributorIdList#">
		<cfinvokeargument name="plannerId" value="#arguments.plannerId#">
	</cfinvoke>

	<cfinvoke
		component="components.programs.paymenthistory.PaymentHistoryManager"
		method="getDeductionAccountExist"
		returnvariable="getDeductionAccountExist">
		<cfinvokeargument name="contract_Number" value="#arguments.contractNumber#">
		<cfinvokeargument name="contractMainID" value="#arguments.contractMainID#">
		<cfinvokeargument name="plannerID" value="#arguments.plannerID#">
	</cfinvoke>

	<cfinvoke
		component="components.programs.paymenthistory.PaymentHistoryManager"
		method="getPaymentAccountExist"
		returnvariable="getPaymentAccountExist">
		<cfinvokeargument name="contract_Number" value="#arguments.contractNumber#">
		<cfinvokeargument name="contractMainID" value="#arguments.contractMainID#">
		<cfinvokeargument name="plannerID" value="#arguments.plannerID#">
	</cfinvoke>

	<cfinvoke
		component="components.programs.paymenthistory.PaymentHistoryManager"
		method="getGLAccountExist"
		returnvariable="getGLAccountExist">
		<cfinvokeargument name="contract_Number" value="#arguments.contractNumber#">
		<cfinvokeargument name="contractMainID" value="#arguments.contractMainID#">
		<cfinvokeargument name="plannerID" value="#arguments.plannerID#">
	</cfinvoke>

	<cfscript>
	local.buffer  = createObject( "java", "java.lang.StringBuffer" ).Init();
	local.newLine = chr(13) & chr(10);

	// column heading row
	local.buffer.append(javaCast("string", "Fiscal Period,"));

	if(arguments.distributorIdList neq "")
	{
		local.buffer.append(javaCast("string", "#application.returned_customer_setting.distributor_label_singular#, #application.returned_customer_setting.distributor_label_singular# Name,"));
	}

	local.buffer.append(javaCast("string", "Cases, Accrual $, Rate, Rate UOM" & local.newLine));
	</cfscript>

	<!--- body content --->
	<cfloop query="qGetProgramAccrualDistributorFiscalPeriodData.filteredResults">

	<!--- PERCENT --->
	<cfif trim(Rate_UOM) eq "%">
		<cfset rateDisplay = Rate>
	<!---CASES OR POUNDS --->
	<cfelse>
		<cfset rateDisplay = DollarFormat(Rate)>
	</cfif>

	<!--- append row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
	<cfset local.buffer.append(javaCast("string", '"' & Fiscal_Period & '"'))>

	<cfif arguments.distributorIdList neq "">
			<cfset local.buffer.append(javaCast("string",   ',="' & Ship_To & '"'
															& ',"' & Ship_To_Name & '"'))>
	</cfif>

			<cfset local.buffer.append(javaCast("string",   ',"' & NumberFormat(Cases_Invoiced, "_,___,___,___,___") & '"'
															& ',"' & DollarFormat(Amount) & '"'
															& ',"' & rateDisplay & '"'
															& ',"' & Rate_UOM & '"'
															& local.newLine  ))>
	</cfloop>

		<cfreturn local.buffer>
</cffunction>


<cffunction name="call_getOpenPayPeriods" output="false" returntype="String">
	<cfargument name="search_Start_Date" required="true" type="string" />
	<cfargument name="search_End_Date" required="true" type="string" />

		<cfinvoke
			component="components.Billback.BBAutoReportGet"
			method="getOpenPayPeriods"
			returnvariable="qGetOpenPayPeriods">

			<cfinvokeargument name="search_Start_Date" value="#arguments.search_Start_Date#">
			<cfinvokeargument name="search_End_Date" value="#arguments.search_End_Date#">
		</cfinvoke>

		<cfscript>
		local.buffer  = createObject( "java", "java.lang.StringBuffer" ).Init();
		local.newLine = chr(13) & chr(10);

		local.buffer.append(javaCast("string", "#application.returned_customer_setting.Program_Number_Label#, Title, Start Date, End Date, Time Frame Start, Time Frame End" & local.newLine));
		</cfscript>

		<cfloop query = "qGetOpenPayPeriods">

		<cfset EffectiveStartDate = DateFormat(Effective_Start_Date, "mm/dd/yyyy")>
		<cfset EffectiveEndDate = DateFormat(Effective_End_Date, "mm/dd/yyyy")>
		<cfset StartDate = DateFormat(start_date, "mm/dd/yyyy")>
		<cfset EndDate = DateFormat(end_date, "mm/dd/yyyy")>

		<!--- append row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
				<cfset local.buffer.append(javaCast("string",     '="' & Contract_Number & '"'
																												& ',"' & Contract_Title & '"'
																												& ',"' & EffectiveStartDate & '"'
																												& ',"' & EffectiveEndDate & '"'
																												& ',"' & StartDate & '"'
																												& ',"' & EndDate & '"'
																												& local.newLine  ))>
		</cfloop>

		<cfreturn local.buffer>
</cffunction>

<cffunction name="call_getProgramsData" output="false" returntype="String">
	<cfscript>
	objSearchProgram  = CreateObject("component", "mvc.Models.Program.Search_Program");
	objProgramManager  = CreateObject("component", "mvc.Models.Program.programmanager");

	stProgramSettings = objSearchProgram.getProgramSettingsObject(request.AccessStructure.user_id);
	qGetSearchGridColumnSizeInfo = objSearchProgram.getSearchGridColumnSizeInfo(userId=request.AccessStructure.user_id,ignoreColumnList='moreInfo');

	form.user_id = request.AccessStructure.user_id;
	form.profiles_id = request.AccessStructure.profiles_id;

	qGetProgramsAllData = objProgramManager.getProgramsData();
	</cfscript>

	<cfset local.buffer  = createObject( "java", "java.lang.StringBuffer" ).Init()>
	<cfset local.newLine = chr(13) & chr(10)>

	<cfoutput>
	<!--- SET THE COLUMN HEADERS --->
	<cfloop query="qGetSearchGridColumnSizeInfo">
		<cfset local.colLabel = "">

		<cfswitch expression="#ColName#">
			<cfcase value="PROGRAM"><cfset local.colLabel = "Program"></cfcase>
			<cfcase value="STATUS"><cfset local.colLabel = "Status"></cfcase>
			<cfcase value="RFAAGE"><cfset local.colLabel = "RFA Age"></cfcase>
			<cfcase value="TITLE"><cfset local.colLabel = "Title"></cfcase>
			<cfcase value="TYPE"><cfset local.colLabel = "Type"></cfcase>
			<cfcase value="STARTDATE"><cfset local.colLabel = "Start Date"></cfcase>
			<cfcase value="ENDDATE"><cfset local.colLabel = "End Date"></cfcase>
			<cfcase value="RSP"><cfset local.colLabel = "RSP"></cfcase>
			<cfcase value="VOLUME"><cfset local.colLabel = "#stProgramSettings.volumeLabel#"></cfcase>
			<cfcase value="BUSINESSSEGMENT"><cfset local.colLabel = "#application.appSettingsget.getbusiness_segment_label()#"></cfcase>
			<cfcase value="TRADEDOLLARS"><cfset local.colLabel = "#stProgramSettings.TradeDollarsLabel#"></cfcase>
			<cfcase value="PAYMENTDOLLARS"><cfset local.colLabel = "#stProgramSettings.PaymentDollarsLabel#"></cfcase>
		</cfswitch>
		<!--- iF THE COLUMN IS "VIEWABLE" FOR THE USER, THEN ADD IT TO THE HEADER --->
		<cfif local.colLabel neq "" AND qGetSearchGridColumnSizeInfo.ColViewable eq 1>
			<cfset local.buffer.append(javaCast("string", "#local.colLabel#,"))>
		</cfif>
	</cfloop>

	<cfif form.Include_Operator_In_CSV eq 1 AND stProgramSettings.userProgram.Display_Operator_Info eq 1>
		<cfset local.buffer.append(javaCast("string", "#application.returned_customer_setting.operator_label_singular# ID,"))>
		<cfset local.buffer.append(javaCast("string", "#application.returned_customer_setting.operator_label_singular# Name,"))>
	</cfif>

	<!--- Add a new line --->
	<cfset local.buffer.append(javaCast("string", local.newLine  ))>

	<!--- GET THE DATA --->
	<cfloop query = "qGetProgramsAllData">
		<!--- GET THE DATA FOR WHAT COLUMNS AND IN WHAT ORDER TO DISPLAY --->
		<cfloop query="qGetSearchGridColumnSizeInfo">
			<cfif  qGetSearchGridColumnSizeInfo.ColViewable eq 1>
				<!--- NO COMMA FOR ROW 1--->
				<cfif qGetSearchGridColumnSizeInfo.currentrow eq 1>
					<cfset local.buffer.append(javaCast("string", '"' & qGetProgramsAllData['#qGetSearchGridColumnSizeInfo.colName#'][qGetProgramsAllData.currentrow] & '"'))>

				<cfelseif qGetSearchGridColumnSizeInfo.colName eq "volume">
					<cfset local.buffer.append(javaCast("string", ',"' & NumberFormat(qGetProgramsAllData['#qGetSearchGridColumnSizeInfo.colName#'][qGetProgramsAllData.currentrow], "_,___,___,___,___")  & '"'))>

				<cfelseif qGetSearchGridColumnSizeInfo.colName eq "paymentDollars" OR qGetSearchGridColumnSizeInfo.colName eq "tradeDollars">
					<cfset local.buffer.append(javaCast("string", ',"' & DollarFormat(qGetProgramsAllData['#qGetSearchGridColumnSizeInfo.colName#'][qGetProgramsAllData.currentrow])  & '"'))>

				<cfelseif qGetSearchGridColumnSizeInfo.colName eq "startdate" OR qGetSearchGridColumnSizeInfo.colName eq "enddate">
					<cfset local.buffer.append(javaCast("string", ',"' & DateFormat(qGetProgramsAllData['#qGetSearchGridColumnSizeInfo.colName#'][qGetProgramsAllData.currentrow],"mm/dd/yyyy")  & '"'))>

				<cfelse>
					<!--- ADD COMMA FOR ROWS 2 AND ABOVE --->
					<cfset local.buffer.append(javaCast("string", ',"' & qGetProgramsAllData['#qGetSearchGridColumnSizeInfo.colName#'][qGetProgramsAllData.currentrow]  & '"'))>
				</cfif>
			</cfif>
		</cfloop>

	<cfif form.Include_Operator_In_CSV eq 1 AND stProgramSettings.userProgram.Display_Operator_Info eq 1>
		<cfset local.buffer.append(javaCast("string", ',"' & qGetProgramsAllData.OperatorID & '"'))>
		<cfset local.buffer.append(javaCast("string", ',"' & qGetProgramsAllData.OperatorName & '"'))>
	</cfif>

		<cfset local.buffer.append(javaCast("string", local.newLine  ))>
	</cfloop>
	</cfoutput>

		<cfreturn local.buffer>
</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="call_getSettlementsData" returntype="query">
	<cfargument name="stForm" required="true" default="" type="any" />

	<cfscript>
		GetProgramDetails = CreateObject("component", "MVC.Models.OnePageBillback.OPBManager").getAllPrograms(stForm = FORM);
	</cfscript>

	<cfquery name="qGetProgramDetails" dbtype="query">
		SELECT  Planner_Number, Program_Number, Program_Title AS Title, Customer_ID, Customer_Name, Delivery_Start_Date AS Start_Date, Delivery_End_Date AS End_Date, Item_Number AS Item
										,Item_Description AS Description, Discount_Type AS Discount,
										<cfif GetProgramDetails.Component_Paid_To EQ 1>
											'Distributor'
										<cfelse>
											'Operator'
										</cfif>
										AS Paid_To,
										Component_Name, Program_Rate AS Rate, Rebate_UOM AS UOM, Operator_Name AS Indirect, Accrued, Settled, Balance
		FROM GetProgramDetails
	</cfquery>
		<cfreturn qGetProgramDetails>
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
		qProducts = application.oVfManager.getProducts( arguments.v451 );

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

	<cfargument name="byBudgetCodes" required="false" default=""/>
	<cfargument name="byGroupIDs" required="false" default=""/>
	<cfargument name="byBudgetTypeIDs" required="false" default=""/>
	<cfargument name="bySegmentIDs" required="false" default=""/>

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

		  <cfif len(trim(url.byBudgetCodes)) AND url.byBudgetCodes NEQ 'NULL'>
		 		AND b.Budget_Code in ( <cfqueryparam value="#url.byBudgetCodes#" cfsqltype="cf_sql_varchar" list="yes"> )
		  </cfif>

			<cfif len(trim(url.byGroupIDs))  AND url.byGroupIDs NEQ 'NULL'>
			  AND bg.Budget_Group_ID in ( <cfqueryparam value="#url.byGroupIDs#" cfsqltype="cf_sql_integer" list="yes"> )
			</cfif>

			<cfif len(trim(url.byBudgetTypeIDs)) AND url.byBudgetTypeIDs NEQ 'NULL'>
			  AND bcft.Budget_Contribution_Factor_Type_ID in ( <cfqueryparam value="#url.byBudgetTypeIDs#" cfsqltype="cf_sql_integer" list="yes"> )
			</cfif>

			<cfif len(trim(url.bySegmentIDs)) AND url.bySegmentIDs NEQ 'NULL'>
			  AND bs.Business_Segment_ID in ( <cfqueryparam value="#url.bySegmentIDs#" cfsqltype="cf_sql_integer" list="yes"> )
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
<!--- D62230 :: 8.0 - In Settings have distributor, operator & product searches with no filters START --->
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
	SELECT IM.item, IM.Description, IM.GTIN, CASE WHEN IM.Active_Code = 'A' THEN 'YES' ELSE 'NO' END AS Active_Code, CASE WHEN IM.Deleted = 0 THEN 'NO' ELSE 'YES' END AS Deleted
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

<cfset commonVariables = "Item,Description,GTIN,Active_Code,Deleted">

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
												& ',="' & GTIN & '"'
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
		<cfif businessSegManager.isEnabledForVendorType()>
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

		IF OBJECT_ID ('tempdb..##tmp_dropoff_rpt_adjustments') IS NOT NULL
		DROP TABLE ##tmp_dropoff_rpt_adjustments

		IF OBJECT_ID ('tempdb..##tmp_distinct_list') IS NOT NULL
		DROP TABLE ##tmp_distinct_list

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
				cast(0 AS decimal(20, 2)) AS Drop_Off,
				cast(0 AS decimal(20, 2)) AS Adjustment_Dollar
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
				cast(0 as decimal(20, 2)) as Drop_Off,
				cast(0 AS decimal(20, 2)) AS Adjustment_Dollar
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


		-- Get accrual adjustment dollar
		IF OBJECT_ID ('tempdb..##tmp_dropoff_rpt_adjustments') IS NOT NULL
		DROP TABLE ##tmp_dropoff_rpt_adjustments

		select	b.Budget_Code,
				c.Shr_Ship_To as Ship_To, c.Name as Distributor_Name,
				adj.BSA_Foodservice_Customers_ID,
				p.Period, p.Period_Start, p.Period_End,
				sum(adj.Adjustment_Dollar) as Adjustment_Dollar
		into	##tmp_dropoff_rpt_adjustments
		from	Budget_Adjustment adj
		inner join Budget b
		on		b.Budget_ID = adj.Budget_Id
		and		b.deleted = 0
		AND		b.Is_Perpetual = 1
		INNER JOIN ##tmp_Periods p
		ON		p.Period_Start = adj.Start_Date
		INNER JOIN BSA_Foodservice_Customers c
		ON		c.BSA_Foodservice_Customers_ID = adj.BSA_Foodservice_Customers_ID
		where	adj.Adjustment_Dollar != 0
		Group BY b.Budget_Code,
				c.Shr_Ship_To, c.Name,
				adj.BSA_Foodservice_Customers_ID,
				p.Period, p.Period_Start, p.Period_End

		-- Include adjustment dollar in drop off report
		update	##tmp_Combined
		set		Adjustment_Dollar = adj.Adjustment_Dollar
		from	##tmp_dropoff_rpt_adjustments adj
		inner join ##tmp_Combined
		on		##tmp_Combined.Budget_Code = adj.Budget_Code
		and		##tmp_Combined.BSA_Foodservice_Customers_ID = adj.BSA_Foodservice_Customers_ID
		and		##tmp_Combined.Period_Start = adj.Period_Start


		UPDATE	##tmp_Combined
		SET		Drop_Off =
						CASE
							WHEN Budget_Amount + Adjustment_Dollar > Payments_Applied THEN Budget_Amount + Adjustment_Dollar - Payments_Applied
							WHEN Budget_Amount + Adjustment_Dollar < 0 THEN Budget_Amount + Adjustment_Dollar - Payments_Applied
						ELSE 0
						END
		WHERE	Period_Start < @period_start

		insert into ##tmp_Combined (
				Budget_Code,
				Ship_To, Distributor_Name,
				BSA_Foodservice_Customers_ID,
				Period, Period_Start, Period_End,
				Budget_Amount, Payments_Applied, Total_Payments, Drop_Off,
				Adjustment_Dollar)
		select	Budget_Code,
				Ship_To, Distributor_Name,
				BSA_Foodservice_Customers_ID,
				Period, Period_Start, Period_End,
				0 as Budget_Amount, 0 as Payments_Applied, 0 as Total_Payments, 0 as Drop_Off,
				Adjustment_Dollar
		from	##tmp_dropoff_rpt_adjustments adj
		WHERE   not exists (
								SELECT  1
								FROM    ##tmp_Combined b
								WHERE   adj.Budget_Code = b.Budget_Code
								AND     adj.BSA_Foodservice_Customers_ID = b.BSA_Foodservice_Customers_ID
								AND     adj.Period_Start = b.Period_Start
							)

		IF OBJECT_ID ('tempdb..##tmp_Log_5000_Budgets_Perpetual_Report') IS NOT NULL
		DROP TABLE ##tmp_Log_5000_Budgets_Perpetual_Report

		SELECT	*, Budget_Amount - Drop_Off + Adjustment_Dollar AS Final_Budget_Amount,(Budget_Amount - Drop_Off + Adjustment_Dollar) - Total_Payments AS Balance
		INTO	##tmp_Log_5000_Budgets_Perpetual_Report
		FROM	##tmp_Combined

		IF OBJECT_ID ('tempdb..##tmp_distinct_list') IS NOT NULL
		DROP TABLE ##tmp_distinct_list

		select	Budget_Code, Ship_To, Distributor_Name, BSA_Foodservice_Customers_ID, min(Period_Start) as Min_Start
		into	##tmp_distinct_list
		from	##tmp_Log_5000_Budgets_Perpetual_Report
		group by Budget_Code, Ship_To, Distributor_Name, BSA_Foodservice_Customers_ID


		insert into ##tmp_Log_5000_Budgets_Perpetual_Report (
				Budget_Code, Ship_To, Distributor_Name, BSA_Foodservice_Customers_ID,
				Period, Period_Start, Period_End,
				Budget_Amount, Payments_Applied, Total_Payments,
				Drop_Off, Adjustment_Dollar, Final_Budget_Amount, Balance
		)
		select	l.Budget_Code, l.Ship_To, l.Distributor_Name, l.BSA_Foodservice_Customers_ID,
				p.Period, p.Period_Start, p.Period_End,
				0 as Budget_Amount, 0 as Payments_Applied, 0 as Total_Payments,
				0 as Drop_Off, 0 as Adjustment_Dollar, 0 as Final_Budget_Amount, 0 as Balance
		from	##tmp_distinct_list l
		inner join ##tmp_Periods p
		on		p.Period_Start >= l.Min_Start
		where	not exists (
			select	1
			from	##tmp_Log_5000_Budgets_Perpetual_Report rpt
			where	rpt.Ship_To = l.Ship_To
			and		rpt.Budget_Code = l.Budget_Code
			and		rpt.Period_Start = p.Period_Start
		)

		SELECT	Budget_Code
			,Period
			,Period_Start
			,Period_End
			,Budget_Amount
			,Drop_Off
			,Adjustment_Dollar
			,Final_Budget_Amount
			,Total_Payments as Payments_Applied
			,Balance
			,Ship_To
			,Distributor_Name
		FROM	##tmp_Log_5000_Budgets_Perpetual_Report
		ORDER BY Budget_Code, Distributor_Name, Period_Start
	</cfquery>
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

		IF OBJECT_ID ('tempdb..##tmp_dropoff_rpt_adjustments') IS NOT NULL
		DROP TABLE ##tmp_dropoff_rpt_adjustments

		IF OBJECT_ID ('tempdb..##tmp_distinct_list') IS NOT NULL
		DROP TABLE ##tmp_distinct_list

		IF OBJECT_ID('tempdb..##tmp_Log_5000_Budgets_Perpetual_Report') IS NOT NULL
		DROP TABLE ##tmp_Log_5000_Budgets_Perpetual_Report
	</cfquery>
	<cfset ClientVariables = "Budget Code, Period, Period Start, Period End, Gross Budget Amount, Drop Off Amount, Adjustment Amount, Final Budget Amount, Payments, Balance, Customer Number, Customer Name">
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
								& ',="' & Adjustment_Dollar & '"'
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

<cffunction name="program_volume" output="false">
	<cfargument name="program_ID" required="true">
	<cfargument name="contract_span" required="true">

	<cfquery name="local.program_volume" datasource="#application.datasource#">
		DECLARE @Display_Item_No BIT
		SET @Display_Item_No = dbo.udf_GetAppSetting('Display_Item_No')

		SELECT  CASE
					WHEN @Display_Item_No = '1'
						THEN BSA_Foodservice_Items_Master.Item
					ELSE
						BSA_Foodservice_Items_Master.UPC
				END                         AS Product_Number
				,BSA_Foodservice_Items_Master.Description AS Description
				,CEILING( (ISNULL(Program_Product_Volume.Volume_CS, 0) / 7) * 365) AS Annual_Volume_Case
				,CEILING( (ISNULL(Program_Product_Volume.Volume_LB, 0) / 7) * 365) AS Annual_Volume_Pound
				,CEILING( (ISNULL(Program_Product_Volume.Volume_CS, 0) / 7) * #arguments.contract_span#) AS Program_Volume_Case
				,CEILING( (ISNULL(Program_Product_Volume.Volume_LB, 0) / 7) * #arguments.contract_span#) AS Program_Volume_Pound
		FROM     Program_Product_Volume
				INNER JOIN BSA_Foodservice_Items_Master
					ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Program_Product_Volume.BSA_Foodservice_Items_Master_ID
		WHERE    Program_Product_Volume.Deleted = 0
				AND Program_Product_Volume.Program_ID = <cfqueryparam value="#arguments.program_ID#" cfsqltype="cf_sql_integer">
				AND LEN(Program_Product_Volume.Volume_LB) > 0
				AND Program_Product_Volume.Is_Group = 0
				AND EXISTS
							(
								SELECT 1
								FROM   Contract_Products cp
								WHERE  cp.Contract_Main_ID = Program_Product_Volume.Program_ID
									AND cp.Deleted = 0
									AND cp.BSA_Foodservice_Items_Master_ID = Program_Product_Volume.BSA_Foodservice_Items_Master_ID
							)
		ORDER BY BSA_Foodservice_Items_Master.Item
	</cfquery>

	<cfreturn local.program_volume>
</cffunction>

<cffunction name="Component_Report" output="false">
	<cfargument name="Comp_Type" required="true">

	<cfquery name="qCompReport" datasource="#application.datasource#">

			IF OBJECT_ID('tempdb..##tmp_gl_account') IS NOT NULL
			DROP TABLE ##tmp_gl_account

			IF OBJECT_ID('tempdb..##tmp_template') IS NOT NULL
			DROP TABLE ##tmp_template

			IF OBJECT_ID('tempdb..##tmp_fob_dist_Y') IS NOT NULL
			DROP TABLE ##tmp_fob_dist_Y

			IF OBJECT_ID('tempdb..##tmp_fob_dist_N') IS NOT NULL
			DROP TABLE ##tmp_fob_dist_N

			IF OBJECT_ID('tempdb..##tmp_fob_dist_X') IS NOT NULL
			DROP TABLE ##tmp_fob_dist_X

			IF OBJECT_ID('tempdb..##tmp_fob_dist_C') IS NOT NULL
			DROP TABLE ##tmp_fob_dist_C

			IF OBJECT_ID('tempdb..##tmp_fob_dist_K') IS NOT NULL
			DROP TABLE ##tmp_fob_dist_K

			IF OBJECT_ID('tempdb..##tmp_fob_dist_B') IS NOT NULL
			DROP TABLE ##tmp_fob_dist_B

			select	glam.Discount_Type_ID, glam.Component_Name_ID, gla.GL_Account
			into	##tmp_gl_account
			from	GL_Account gla
			inner join GL_Component_Mapping glam
			on		glam.GL_Account_ID = gla.GL_Account_ID



			select	ptc.Discount_Type_ID, ptc.Component_ID, t.Created_Type as [Template]
			into	##tmp_template
			from	Program_Template_Component ptc
			inner join Program_Control_Panel_Options t
			on		t.ProgramControl_Panel_Options_ID = ptc.Template_ID
			and		t.IsDominant = 1
			where	ptc.Deleted = 0



			select	distinct fob.Discount_Type_ID, fob.Component_Name_ID
			into	##tmp_fob_dist_Y
			from	Program_Component_Fob_Price_Indicator fob
			where	fob.Payee_Type_ID = 1
			and		fob.Fob_Price_Indicator = 'Y'



			select	distinct fob.Discount_Type_ID, fob.Component_Name_ID
			into	##tmp_fob_dist_N
			from	Program_Component_Fob_Price_Indicator fob
			where	fob.Payee_Type_ID = 1
			and		fob.Fob_Price_Indicator = 'N'


			select	distinct fob.Discount_Type_ID, fob.Component_Name_ID
			into	##tmp_fob_dist_X
			from	Program_Component_Fob_Price_Indicator fob
			where	fob.Payee_Type_ID = 1
			and		fob.Fob_Price_Indicator = 'X'

			select	distinct fob.Discount_Type_ID, fob.Component_Name_ID
			into	##tmp_fob_dist_C
			from	Program_Component_Fob_Price_Indicator fob
			where	fob.Payee_Type_ID = 1
			and		fob.Fob_Price_Indicator = 'C'

			select	distinct fob.Discount_Type_ID, fob.Component_Name_ID
			into	##tmp_fob_dist_K
			from	Program_Component_Fob_Price_Indicator fob
			where	fob.Payee_Type_ID = 1
			and		fob.Fob_Price_Indicator = 'K'

			select	distinct fob.Discount_Type_ID, fob.Component_Name_ID
			into	##tmp_fob_dist_B
			from	Program_Component_Fob_Price_Indicator fob
			where	fob.Payee_Type_ID = 1
			and		fob.Fob_Price_Indicator = 'B'

			declare @Discount_Type_ID int

		<cfif arguments.Comp_Type EQ 2>
			/******************************************************************
			Rebate
			*******************************************************************/

			set @Discount_Type_ID = 2
			select	--cn.Program_Rebates_Component_Name_ID as [Component ID],
					cn.External_ID as [External ID], cn.Program_Rebates_Component_Name as [Component Name],
					rpo.Rebate_Percent_Option_Desc as [Gross/Net],
					CASE cn.Auto_Pay_Net_Of_Cash_Discount when 1 then 'Yes' else 'No' end as [Auto Pay net of CD],
					CASE cn.Auto_Pay_Net_Of_Freight_Allowance when 1 then 'Yes' else 'No' end as [Auto Pay net of freight allow],
					CASE cn.Auto_Pay_Exclude_Credit_Type when 1 then 'Yes' else 'No' end as [Auto Pay exclude credit type],
					rmpo.Rebate_Margin_Percent_Option_Desc as [% option in TPA/Margin],
					case cn.Rebate_Type
					when 0 then 'None'
					when 8 then 'Accrual Budget'
					when 6 then 'Add component value to invoice price'
					when 1 then 'Base Price Protection Rebate'
					when 7 then 'Blended Rate'
					when 3 then 'Exclude from margin calculation'
					when 5 then 'Express as cost in margin'
					when 2 then 'Price Protection Increase Rebate'
					when 4 then 'Variable/Fixed Combo'
					end as [Rebate Type],
					CASE cn.Alternate_Recapture_Rate when 1 then 'Yes' else 'No' end as [Alt recap],
					--CASE cn.Alternate_Recapture_By_Operator when 1 then 'Yes' else 'No' end as [Alt recap oper],
					CASE cn.Exclude_From_Recapture when 1 then 'Yes' else 'No' end as [Excl from Recap],
					CASE cn.Accrual_On when 1 then 'Yes' else 'No' end as [Accrual],
					CASE cn.Off_Invoice_On when 1 then 'Yes' else 'No' end as [Off_Invoice_On],
					cn.Payment_Account as [Pymt Acct],
					cn.Deduction_Account as [Ded Acct],
					gl.GL_Account as [GL],
					t.Template,
					CASE ISNULL(fobY1.Component_Name_ID, 0) when 0 then 'No' else 'Yes' end as [FOB Ind Y],
					CASE ISNULL(fobN1.Component_Name_ID, 0) when 0 then 'No' else 'Yes' end as [FOB Ind N],
					CASE ISNULL(fobN1.Component_Name_ID, 0) when 0 then 'No' else 'Yes' end as [FOB Ind X],
					CASE ISNULL(fobC1.Component_Name_ID, 0) when 0 then 'No' else 'Yes' end as [FOB Ind C],
					CASE ISNULL(fobK1.Component_Name_ID, 0) when 0 then 'No' else 'Yes' end as [FOB Ind K],
					CASE ISNULL(fobB1.Component_Name_ID, 0) when 0 then 'No' else 'Yes' end as [FOB Ind B]
			from	Program_Rebates_Component_Name cn
			left join Rebate_Percent_Option rpo on rpo.Rebate_Percent_Option_ID = cn.Rebate_Percent_Option_ID
			left join Rebate_Margin_Percent_Option rmpo on rmpo.Rebate_Margin_Percent_Option_ID = cn.Rebate_Margin_Percent_Option_ID
			left join ##tmp_gl_account gl on gl.Component_Name_ID = cn.Program_Rebates_Component_Name_ID and gl.Discount_Type_ID = @Discount_Type_ID
			left join ##tmp_template t on t.Component_ID = cn.Program_Rebates_Component_Name_ID and t.Discount_Type_ID = @Discount_Type_ID
			left join ##tmp_fob_dist_Y fobY1 on fobY1.Component_Name_ID = cn.Program_Rebates_Component_Name_ID and fobY1.Discount_Type_ID = @Discount_Type_ID
			left join ##tmp_fob_dist_N fobN1 on fobN1.Component_Name_ID = cn.Program_Rebates_Component_Name_ID and fobN1.Discount_Type_ID = @Discount_Type_ID
			left join ##tmp_fob_dist_X fobX1 on fobX1.Component_Name_ID = cn.Program_Rebates_Component_Name_ID and fobX1.Discount_Type_ID = @Discount_Type_ID
			left join ##tmp_fob_dist_C fobC1 on fobC1.Component_Name_ID = cn.Program_Rebates_Component_Name_ID and fobC1.Discount_Type_ID = @Discount_Type_ID
			left join ##tmp_fob_dist_K fobK1 on fobK1.Component_Name_ID = cn.Program_Rebates_Component_Name_ID and fobK1.Discount_Type_ID = @Discount_Type_ID
			left join ##tmp_fob_dist_B fobB1 on fobB1.Component_Name_ID = cn.Program_Rebates_Component_Name_ID and fobB1.Discount_Type_ID = @Discount_Type_ID
			where	cn.Deleted = 0
			and		cn.Active = 1
			order by [Component Name], Template

	<cfelseif arguments.Comp_Type EQ 1>
			/******************************************************************
			Fixed Price
			*******************************************************************/
			set @Discount_Type_ID = 1
			select	--cn.Program_Fixed_Component_Name_ID as [Component ID],
					cn.External_ID as [External ID], cn.Program_Fixed_Component_Name as [Component Name],
					dt.Delivery_Type_Desc as [Type],
					CASE cn.Accrual_On when 1 then 'Yes' else 'No' end as [Accrual],
					CASE cn.Off_Invoice_On when 1 then 'Yes' else 'No' end as [Off_Invoice_On],
					cn.Payment_Account as [Pymt Acct],
					cn.Deduction_Account as [Ded Acct],
					gl.GL_Account as [GL],
					t.Template,
					CASE ISNULL(fobY1.Component_Name_ID, 0) when 0 then 'No' else 'Yes' end as [FOB Ind Y],
					CASE ISNULL(fobN1.Component_Name_ID, 0) when 0 then 'No' else 'Yes' end as [FOB Ind N],
					CASE ISNULL(fobN1.Component_Name_ID, 0) when 0 then 'No' else 'Yes' end as [FOB Ind X],
					CASE ISNULL(fobC1.Component_Name_ID, 0) when 0 then 'No' else 'Yes' end as [FOB Ind C],
					CASE ISNULL(fobK1.Component_Name_ID, 0) when 0 then 'No' else 'Yes' end as [FOB Ind K],
					CASE ISNULL(fobB1.Component_Name_ID, 0) when 0 then 'No' else 'Yes' end as [FOB Ind B]
			from	Program_Fixed_Component_Name cn
			left join Delivery_Type dt on dt.Delivery_Type_ID = cn.Fixed_Component_Type
			left join ##tmp_gl_account gl on gl.Component_Name_ID = cn.Program_Fixed_Component_Name_ID and gl.Discount_Type_ID = @Discount_Type_ID
			left join ##tmp_template t on t.Component_ID = cn.Program_Fixed_Component_Name_ID and t.Discount_Type_ID = @Discount_Type_ID
			left join ##tmp_fob_dist_Y fobY1 on fobY1.Component_Name_ID = cn.Program_Fixed_Component_Name_ID and fobY1.Discount_Type_ID = @Discount_Type_ID
			left join ##tmp_fob_dist_N fobN1 on fobN1.Component_Name_ID = cn.Program_Fixed_Component_Name_ID and fobN1.Discount_Type_ID = @Discount_Type_ID
			left join ##tmp_fob_dist_X fobX1 on fobX1.Component_Name_ID = cn.Program_Fixed_Component_Name_ID and fobX1.Discount_Type_ID = @Discount_Type_ID
			left join ##tmp_fob_dist_C fobC1 on fobC1.Component_Name_ID = cn.Program_Fixed_Component_Name_ID and fobC1.Discount_Type_ID = @Discount_Type_ID
			left join ##tmp_fob_dist_K fobK1 on fobK1.Component_Name_ID = cn.Program_Fixed_Component_Name_ID and fobK1.Discount_Type_ID = @Discount_Type_ID
			left join ##tmp_fob_dist_B fobB1 on fobB1.Component_Name_ID = cn.Program_Fixed_Component_Name_ID and fobB1.Discount_Type_ID = @Discount_Type_ID
			where	cn.Deleted = 0
			and		cn.Active = 1
			order by [Component Name], Template

	<cfelseif arguments.Comp_Type EQ 3>
			/******************************************************************
			Lumpsum
			*******************************************************************/
			set @Discount_Type_ID = 3
			select	--cn.Program_Lump_Sum_Name_ID as [Component ID],
					cn.External_ID as [External ID], cn.Program_Lump_Sum_Name as [Component Name],
					CASE cn.Accrual_On when 1 then 'Yes' else 'No' end as [Accrual],
					CASE cn.Exclude_From_TPA when 1 then 'Yes' else 'No' end as [Exclude From TPA],
					case cn.Lump_Sum_Type
					when 0 then 'None'
					when 1 then 'Express as Cost in margin'
					end as [Type],
					cn.Payment_Account as [Pymt Acct],
					cn.Deduction_Account as [Ded Acct],
					gl.GL_Account as [GL],
					t.Template
			from	Program_Lump_Sum_Name cn
			left join ##tmp_gl_account gl on gl.Component_Name_ID = cn.Program_Lump_Sum_Name_ID and gl.Discount_Type_ID = @Discount_Type_ID
			left join ##tmp_template t on t.Component_ID = cn.Program_Lump_Sum_Name_ID and t.Discount_Type_ID = @Discount_Type_ID
			where	cn.Deleted = 0
			and		cn.Active = 1
			order by [Component Name], Template

	<cfelseif arguments.Comp_Type EQ 4>
			/******************************************************************
			Growth
			*******************************************************************/
			set @Discount_Type_ID = 4
			select	--cn.Program_Growth_Components_Name_Id as [Component ID],
					cn.External_ID as [External ID], cn.Program_Growth_Components_Name as [Component Name],
					rpo.Rebate_Percent_Option_Desc as [Gross/Net],
					CASE cn.Auto_Pay_Net_Of_Cash_Discount when 1 then 'Yes' else 'No' end as [Auto Pay net of CD],
					CASE cn.Auto_Pay_Net_Of_Freight_Allowance when 1 then 'Yes' else 'No' end as [Auto Pay net of freight allow],
					CASE cn.Auto_Pay_Exclude_Credit_Type when 1 then 'Yes' else 'No' end as [Auto Pay exclude credit type],
					CASE cn.Accrual_On when 1 then 'Yes' else 'No' end as [Accrual],
					cn.Payment_Account as [Pymt Acct],
					cn.Deduction_Account as [Ded Acct],
					gl.GL_Account as [GL],
					t.Template,
					CASE ISNULL(fobY1.Component_Name_ID, 0) when 0 then 'No' else 'Yes' end as [FOB Ind Y],
					CASE ISNULL(fobN1.Component_Name_ID, 0) when 0 then 'No' else 'Yes' end as [FOB Ind N],
					CASE ISNULL(fobN1.Component_Name_ID, 0) when 0 then 'No' else 'Yes' end as [FOB Ind X],
					CASE ISNULL(fobC1.Component_Name_ID, 0) when 0 then 'No' else 'Yes' end as [FOB Ind C],
					CASE ISNULL(fobK1.Component_Name_ID, 0) when 0 then 'No' else 'Yes' end as [FOB Ind K],
					CASE ISNULL(fobB1.Component_Name_ID, 0) when 0 then 'No' else 'Yes' end as [FOB Ind B]
			from	Program_Growth_Components_Name cn
			left join Rebate_Percent_Option rpo on rpo.Rebate_Percent_Option_ID = cn.Growth_Percent_Option_ID
			left join ##tmp_gl_account gl on gl.Component_Name_ID = cn.Program_Growth_Components_Name_Id and gl.Discount_Type_ID = @Discount_Type_ID
			left join ##tmp_template t on t.Component_ID = cn.Program_Growth_Components_Name_Id and t.Discount_Type_ID = @Discount_Type_ID
			left join ##tmp_fob_dist_Y fobY1 on fobY1.Component_Name_ID = cn.Program_Growth_Components_Name_Id and fobY1.Discount_Type_ID = @Discount_Type_ID
			left join ##tmp_fob_dist_N fobN1 on fobN1.Component_Name_ID = cn.Program_Growth_Components_Name_Id and fobN1.Discount_Type_ID = @Discount_Type_ID
			left join ##tmp_fob_dist_X fobX1 on fobX1.Component_Name_ID = cn.Program_Growth_Components_Name_Id and fobX1.Discount_Type_ID = @Discount_Type_ID
			left join ##tmp_fob_dist_C fobC1 on fobC1.Component_Name_ID = cn.Program_Growth_Components_Name_Id and fobC1.Discount_Type_ID = @Discount_Type_ID
			left join ##tmp_fob_dist_K fobK1 on fobK1.Component_Name_ID = cn.Program_Growth_Components_Name_Id and fobK1.Discount_Type_ID = @Discount_Type_ID
			left join ##tmp_fob_dist_B fobB1 on fobB1.Component_Name_ID = cn.Program_Growth_Components_Name_Id and fobB1.Discount_Type_ID = @Discount_Type_ID
			where	cn.Deleted = 0
			and		cn.Active = 1
			order by [Component Name], Template
	</cfif>
	</cfquery>
	<cfreturn qCompReport>
</cffunction>

<cffunction name="Segment_Report" output="false">
	<cfquery name="qSegmentReport" datasource="#application.datasource#">
		SELECT *
		FROM Business_Segment
	</cfquery>
	<cfreturn qSegmentReport>
</cffunction>

<cffunction name="call_getBlanketBidInfo" output="false" returntype="string">
		<cfargument name="Contract_Main_ID" type="numeric" required="true">
		<cfargument name="uom_type" type="numeric" required="true">
		<cfargument name="margin_version" type="string" required="false" default="current">
		<cfargument name="contract_status" type="string" required="true">

		<cfset objProgram = CreateObject("component", "components.programs.program") />
		<cfset qGetBlanketBidInfo = objProgram.getBlanketBidInfo(arguments.contract_main_id,arguments.uom_type,arguments..margin_version,arguments.contract_status)>

		<cfset local.buffer = objProgram.getBlanketBidInfoCSV(qGetBlanketBidInfo)>

		<cfreturn local.buffer>
</cffunction>

<cffunction name="call_getAliasData" output="false" returntype="string">
	<cfargument name="entityType" type="string" required="true">
	<cfargument name="sourceType" type="numeric" required="true">
	<cfargument name="sourceID" type="string" required="false" default="">
	<cfargument name="filterModel" type="any" required="false" default=#StructNew()#>

	<cfscript>
	local.buffer  = createObject( "java", "java.lang.StringBuffer" ).Init();
	local.newLine = chr(13) & chr(10);

	// column heading row
	local.buffer.append(javaCast("string", "Type,Alias,Alias Desc,ID,Desc,Source Type,Payee ID" & local.newLine));
	</cfscript>

	<cfset objAlias = createObject('component','mvc.Models.Admin.Alias.AliasManagerDAO') />

	<!--- If the user wants to download data for a single entity only (Either distributor or Item or program or operator) --->
	<cfif arguments.entityType neq "">
		<cfif arguments.entityType eq 0>
			<cfset local.sEntityType = '#application.returned_customer_setting.distributor_label_singular#'>
		<cfelseif arguments.entityType eq 1>
			<cfset local.sEntityType = '#application.returned_customer_setting.item_label#'>
		<cfelseif arguments.entityType eq 2>
			<cfset local.sEntityType = 'Program'>
		<cfelseif arguments.entityType eq 3>
			<cfset local.sEntityType = '#application.returned_customer_setting.operator_label_singular#'>
		</cfif>

		<!--- DISTRIBUTOR --->
		<cfif arguments.entityType eq 0>
			<cfset qGetAliasInfo = objAlias.getDistributorAliasDetails(sourceType = arguments.sourceType, sourceID = arguments.sourceID, filterModel = arguments.filterModel)>
		<!--- ITEM --->
		<cfelseif arguments.entityType eq 1>
			<cfset qGetAliasInfo = objAlias.getItemAliasDetails(sourceType = arguments.sourceType, sourceID = arguments.sourceID, filterModel = arguments.filterModel)>
		<!--- PROGRAM --->
		<cfelseif arguments.entityType eq 2>
			<cfset qGetAliasInfo = objAlias.getprogramAliasDetails(sourceType = arguments.sourceType, sourceID = arguments.sourceID, filterModel = arguments.filterModel)>
		<!--- OPERATOR --->
		<cfelseif arguments.entityType eq 3>
			<cfset qGetAliasInfo = objAlias.getOperatorAliasDetails(sourceType = arguments.sourceType, sourceID = arguments.sourceID, filterModel = arguments.filterModel)>
		</cfif>

		<!--- body content --->
		<cfloop query="qGetAliasInfo">
			<!--- append row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
			<cfset local.buffer.append(javaCast("string",  '="'	& local.sEntityType & '"'
																& ',="' & qGetAliasInfo.aliasID & '"'
																& ',="' & Replace(qGetAliasInfo.aliasDesc,',','','ALL') & '"'
																& ',="' & qGetAliasInfo.entityID & '"'
																& ',="' & Replace(qGetAliasInfo.entityDesc,',','','ALL') & '"'
																& ',="' & Replace(qGetAliasInfo.sourceTypeDesc,',','','ALL') & '"'
																& ',="' & qGetAliasInfo.payeeID & '"'
																& local.newLine  ))>
		</cfloop>
	<!---
	The user wants to download data for all the different entities - distributor,item,program and operator.
	If the user selects the "ALL ALIAS" option, then the entire alias data needs to be downlosded, otherwise only the entire data
	of the selected source needs to be downloaded.
	--->
	<cfelse>
		<!--- DISTRIBUTOR --->
		<cfset qGetAliasInfo = objAlias.getDistributorAliasDetails(sourceType = arguments.sourceType, sourceID = arguments.sourceID, filterModel = arguments.filterModel)>
		<cfset local.sEntityType = '#application.returned_customer_setting.distributor_label_singular#'>

		<!--- body content --->
		<cfloop query="qGetAliasInfo">
			<!--- append row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
			<cfset local.buffer.append(javaCast("string",  '="'	& local.sEntityType & '"'
																& ',="' & qGetAliasInfo.aliasID & '"'
																& ',="' & Replace(qGetAliasInfo.aliasDesc,',','','ALL') & '"'
																& ',="' & qGetAliasInfo.entityID & '"'
																& ',="' & Replace(qGetAliasInfo.entityDesc,',','','ALL') & '"'
																& ',="' & Replace(qGetAliasInfo.sourceTypeDesc,',','','ALL') & '"'
																& ',="' & qGetAliasInfo.payeeID & '"'
																& local.newLine  ))>
		</cfloop>

		<!--- ITEM --->
		<cfset qGetAliasInfo = objAlias.getItemAliasDetails(sourceType = arguments.sourceType, sourceID = arguments.sourceID, filterModel = arguments.filterModel)>
		<cfset local.sEntityType = '#application.returned_customer_setting.item_label#'>

		<!--- body content --->
		<cfloop query="qGetAliasInfo">
			<!--- append row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
			<cfset local.buffer.append(javaCast("string",  '="'	& local.sEntityType & '"'
																& ',="' & qGetAliasInfo.aliasID & '"'
																& ',="' & Replace(qGetAliasInfo.aliasDesc,',','','ALL') & '"'
																& ',="' & qGetAliasInfo.entityID & '"'
																& ',="' & Replace(qGetAliasInfo.entityDesc,',','','ALL') & '"'
																& ',="' & Replace(qGetAliasInfo.sourceTypeDesc,',','','ALL') & '"'
																& ',="' & qGetAliasInfo.payeeID & '"'
																& local.newLine  ))>
		</cfloop>

		<!--- PROGRAM --->
		<cfset qGetAliasInfo = objAlias.getprogramAliasDetails(sourceType = arguments.sourceType, sourceID = arguments.sourceID, filterModel = arguments.filterModel)>
		<cfset local.sEntityType = 'Program'>

		<!--- body content --->
		<cfloop query="qGetAliasInfo">
			<!--- append row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
			<cfset local.buffer.append(javaCast("string",  '="'	& local.sEntityType & '"'
																& ',="' & qGetAliasInfo.aliasID & '"'
																& ',="' & Replace(qGetAliasInfo.aliasDesc,',','','ALL') & '"'
																& ',="' & qGetAliasInfo.entityID & '"'
																& ',="' & Replace(qGetAliasInfo.entityDesc,',','','ALL') & '"'
																& ',="' & Replace(qGetAliasInfo.sourceTypeDesc,',','','ALL') & '"'
																& ',="' & qGetAliasInfo.payeeID & '"'
																& local.newLine  ))>
		</cfloop>

		<!--- OPERATOR --->
		<cfset qGetAliasInfo = objAlias.getOperatorAliasDetails(sourceType = arguments.sourceType, sourceID = arguments.sourceID, filterModel = arguments.filterModel)>
		<cfset local.sEntityType = '#application.returned_customer_setting.operator_label_singular#'>

		<!--- body content --->
		<cfloop query="qGetAliasInfo">
			<!--- append row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
			<cfset local.buffer.append(javaCast("string",  '="'	& local.sEntityType & '"'
																& ',="' & qGetAliasInfo.aliasID & '"'
																& ',="' & Replace(qGetAliasInfo.aliasDesc,',','','ALL') & '"'
																& ',="' & qGetAliasInfo.entityID & '"'
																& ',="' & Replace(qGetAliasInfo.entityDesc,',','','ALL') & '"'
																& ',="' & Replace(qGetAliasInfo.sourceTypeDesc,',','','ALL') & '"'
																& ',="' & qGetAliasInfo.payeeID & '"'
																& local.newLine  ))>
		</cfloop>
	</cfif>

	<cfreturn local.buffer>
</cffunction>
<cffunction name="csvFormat" output="false" hint="Sanitize passing arguments & return a comma-delimited list result">
    <!--- sanitize all passing arguments --->
    <cfloop from="1" to="#arrayLen(arguments)#" index="local.counter">
        <!--- replace double quotes --->
        <cfset arguments[local.counter] = replace( arguments[local.counter], '"', '', "all" )>

        <!--- prefix with an equal sign for values with equal sign in the front --->
        <cfif (arguments[local.counter] gt '' and left(trim(arguments[local.counter]), 1) is '=')>
            <cfset arguments[local.counter] = '="' & listDeleteAt(arguments[local.counter], 1, "=", true) & '"'>
        <cfelse>
            <cfset arguments[local.counter] = '"' & arguments[local.counter] & '"'>
        </cfif>
    </cfloop>

    <cfreturn arrayToList(arguments)>
</cffunction>