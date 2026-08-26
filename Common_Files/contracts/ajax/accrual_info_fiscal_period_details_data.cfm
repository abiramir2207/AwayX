<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\contracts\ajax\accrual_info_fiscal_period_details_data.cfm
      Date:     2016 February
      Author:   Milan Mushran
      Purpose:  AJAX processing for loading and searching/filtering accrual data at a "distributor and item" combination level
----------------------------------------------------------------------------------------------------------------------->
<cfsetting showDebugOutput="no">
<cfprocessingdirective suppresswhitespace="yes">
<cfparam name="form.iDisplayStart"		default="0">
<cfparam name="form.iDisplayLength"	default="100">
<cfparam name="form.sEcho"			default="10">
<cfparam name="form.iSortCol_0"		default="0">
<cfparam name="form.SSORTDIR_0"		default="asc">
<cfparam name="form.contract_number"	default="">
<cfparam name="form.distributorComponentList"	default="">
<cfparam name="form.Product_Group_Level_ID"	default="0">
<cfparam name="form.distributorId"	default="">
<cfparam name="form.Fiscal_Period"	default="">
<cfparam name="form.Component_Name"	default="">

<!--- value of dropdown filter on column 7 and so on (column numbers start with 0 on the data grid) --->
<cfparam name="form.sSearch_7"		default="">
<cfparam name="form.sSearch_8"		default="">
<cfparam name="form.sSearch_9"		default="">
<cfparam name="form.sSearch_10"		default="">
<cfparam name="form.sSearch_11"		default="">
<cfparam name="form.sSearch_12"		default="">
<cfparam name="form.contractId"		default="">
<cfparam name="form.plannerId"		default="">

  <cfscript>
    variables.reply = {};

    variables.page_size   = val(form.iDisplayLength);
    if ( variables.page_size eq -1) {
      variables.start_row   = 1;
      variables.end_row     = -1;
    }
    else {
      variables.start_row   = form.iDisplayStart + 1;
      variables.end_row     = form.iDisplayStart + variables.page_size;
    }
    form.sSearch = trim(form.sSearch);

    // parse search string into an array of words
    if ( len(form.sSearch) ) {
      variables.arrayOfWords = reMatch( "[[:word:]]+", form.sSearch );
    }
    else {
      variables.arrayOfWords = [];
    }
    // concatenate array of words into a long string delimited by % ( for SQL LIKE condition )
    variables.listOfWords = arrayToList(variables.arrayOfWords, "%");

    form.iSortCol_0 = val(form.iSortCol_0);
  </cfscript>

<cfset PaymentHistoryManager = CreateObject("component","components.programs.paymenthistory.PaymentHistoryManager") />

<cfset filterDeductionAccount = "" />
<cfset filterPaymentAccount = "" />
<cfset filterGLAccount = "" />
<cfset filterExternalID = "" />
<cfset filterComponentName = "" />
<cfset filterRateUOM = "" />
<cfset nextPosition = 4 />

<!--- Rate UOM --->
<cfset filterRateUOM = Evaluate("form.sSearch_#nextPosition#") />
<cfset nextPosition = nextPosition + 1 />
	
<cfset structItemDetails = PaymentHistoryManager.getProgramAccrualDistributorFiscalPeriodData(contractNumber=form.contractNumber,
															contractMainID=form.contractId,distributorComponentList=form.distributorComponentList,
															column_sequence_number=form.iSortCol_0,sort_order=form.SSORTDIR_0,
															startRow=variables.start_row,endRow=variables.end_row,
															deductionAccount=filterDeductionAccount,paymentAccount=filterPaymentAccount,
															glAccount=filterGLAccount,externalID=filterExternalID,componentName=form.Component_Name,
															rateUOM=filterRateUOM,fiscalPeriod=form.Fiscal_Period,distributorIdList=form.distributorId, plannerId=form.plannerId)>


 <!--- Generate JSON from Query --->
  <cfset variables.reply.aaData = [] >

  <!--- Data holder for dropdown filters (start) --->
  <cfset variables.reply.AllUOM = [] >
  <cfset variables.reply.AllComponentName = [] >
  <cfset variables.reply.AllFiscalPeriod = [] >
  <!--- Data holder for dropdown filters (end) --->

    <cfoutput>	
			<cfset variables.arrProdAttribute = []>
		  <cfloop query="structItemDetails.filteredResults">
		    <cfscript>
			 variables.dArrayTmp = [];
			 /* If it is an adjustment and it outside the program dates (after the program ends) */
			 if(structItemDetails.filteredResults.Adjustment_Created_Date neq "" AND structItemDetails.filteredResults.Outside_Program_Dates eq 1){
				arrayAppend(variables.dArrayTmp,structItemDetails.filteredResults.Fiscal_Period & ' ' & 'Outside fiscal period.' & ' Created ' & DateFormat(structItemDetails.filteredResults.Adjustment_Created_Date, 'mm/dd/yyyy'));
			 }
			 else{
				arrayAppend(variables.dArrayTmp,structItemDetails.filteredResults.Fiscal_Period);
			 }
			 /* If it is an adjustment */
			 if(structItemDetails.filteredResults.Adjustment_Created_Date neq ""){
				arrayAppend(variables.dArrayTmp, '');
			 }
			 else{
				arrayAppend(variables.dArrayTmp, NumberFormat(structItemDetails.filteredResults.Cases_Invoiced, "_,___,___,___,___"));
			}
			arrayAppend(variables.dArrayTmp, DollarFormat(structItemDetails.filteredResults.Amount));
			 /* If it is an adjustment */
			 if(structItemDetails.filteredResults.Adjustment_Created_Date neq ""){
				arrayAppend(variables.dArrayTmp, '');
			 }
			 else{
				/* PERCENT */
				if(trim(structItemDetails.filteredResults.Rate_UOM) eq "%"){
					arrayAppend(variables.dArrayTmp, structItemDetails.filteredResults.Rate);
				}
				/* CASES OR POUNDS */
				else{
				/* Dev Note(71429) - We need to show 4 decimal places and so cannot use the "DollarFormat" function */
					arrayAppend(variables.dArrayTmp, "$" & structItemDetails.filteredResults.Rate);
				}
			}
			arrayAppend(variables.dArrayTmp, structItemDetails.filteredResults.Rate_UOM);
				
						 
			arrayAppend(variables.reply.aaData, variables.dArrayTmp);
		    </cfscript>
		  </cfloop>	
  </cfoutput>

	<cfset variables.reply.TotalCasesInvoiced = structItemDetails.TotalFilteredCasesInvoiced>
	<cfset variables.reply.TotalAmount = structItemDetails.TotalFilteredAmount>
	<cfset variables.reply.TotalRate = structItemDetails.TotalFilteredAmount / structItemDetails.TotalFilteredCasesInvoiced>

	<!--- POPULATE DATA FOR THE FILTER DROPDOWNS (START) --->
	<cfloop query="structItemDetails.qGetUniqueRateUOM">
		 <cfscript>
			 variables.dArrayTmp = [];
			arrayAppend(variables.dArrayTmp, Rate_UOM);
						 
			arrayAppend(variables.reply.AllUOM, variables.dArrayTmp);
		</cfscript>
	 </cfloop>
	<cfloop query="structItemDetails.qGetUniqueFiscalPeriod">
		 <cfscript>
			 variables.dArrayTmp = [];
			arrayAppend(variables.dArrayTmp, Fiscal_Period);
						 
			arrayAppend(variables.reply.AllFiscalPeriod, variables.dArrayTmp);
		</cfscript>
	</cfloop>
	
	 <cfloop query="structItemDetails.qGetUniqueComponentName">
		 <cfscript>
			 variables.dArrayTmp = [];
			arrayAppend(variables.dArrayTmp, Component_Name);
						 
			arrayAppend(variables.reply.AllComponentName, variables.dArrayTmp);
		</cfscript>
	 </cfloop>
	<!--- POPULATE DATA FOR THE FILTER DROPDOWNS (END) --->

	<cfset variables.reply.iTotalRecords = structItemDetails.recordTotal>
	<cfset variables.reply.iTotalDisplayRecords = structItemDetails.filteredTotal>
	<cfset variables.reply.sEcho  = javacast('int', form.sEcho)>
	<cfset variables.sOut = SerializeJSON( variables.reply )>


  <!--- Since SerializeJSON capitalize the content which is case-sensitive let's reset it the correct way --->
  <cfset variables.sOut = Replace (variables.sOut, 'SECHO', 'sEcho', 'one')>
  <cfset variables.sOut = Replace (variables.sOut, 'ITOTALRECORDS', 'iTotalRecords', 'one')>
  <cfset variables.sOut = Replace (variables.sOut, 'ITOTALDISPLAYRECORDS', 'iTotalDisplayRecords', 'one')>
  <cfset variables.sOut = Replace (variables.sOut, 'AADATA', 'aaData', 'one')>

<!---send JSON data back to client--->
<cfoutput>#variables.sOut#</cfoutput>

</cfprocessingdirective>