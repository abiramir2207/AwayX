<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\contracts\ajax\accrual_info_data.cfm
      Date:     2016 February
      Author:   Milan Mushran
      Purpose:  AJAX processing for loading and searching/filtering accrual data at a distributor level
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
<!--- value of dropdown filter on column 4 and so on (column numbers start with 0 on the data grid) --->
<cfparam name="form.sSearch_4"		default="">
<cfparam name="form.sSearch_5"		default="">
<cfparam name="form.sSearch_6"		default="">
<cfparam name="form.sSearch_7"		default="">
<cfparam name="form.contractId"		default="">
<cfparam name="form.plannerId" 		default="0">

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
<cfset getDeductionAccountExist = PaymentHistoryManager.getDeductionAccountExist(form.contractNumber, form.contractMainID, plannerId)>
<cfset getPaymentAccountExist = PaymentHistoryManager.getPaymentAccountExist(contractNumber, ContractId, plannerId)>
<cfset getGLAccountExist = PaymentHistoryManager.getGLAccountExist(contractNumber, ContractId, plannerId)>
	
<cfset filterDeductionAccount = "" />
<cfset filterPaymentAccount = "" />
<cfset filterGLAccount = "" />
<cfset filterExternalID = "" />
<cfset filterComponentName = "" />
<cfset filterContractNumber = "" />
<cfset filterShipTo = "" />

<cfset nextPosition = 2 />

<!--- Contract Number --->
<cfset filterContractNumber = form.sSearch_0 />

<!---If we have a planner id then we are displaying the contract number in the grid as the first searchable column. 
Because of this we have to handle for the ship to column number. If we have a planner id then it has to be 2 otherwise it will be 1.
--->
<cfparam name="shipToColumnNumber" default="0" />
<cfset shipToColumnNumber = 1 />
<!--- Ship To--->
<cfset filterShipTo = Evaluate("form.sSearch_#shipToColumnNumber#") />
<cfset shipToColumnNumber = shipToColumnNumber + 1  />

<cfset filterShipToText = Evaluate("form.sSearch_#shipToColumnNumber#") />
<cfset nextPosition = nextPosition + 1 />

<cfif getDeductionAccountExist>
	<cfset filterDeductionAccount = Evaluate("form.sSearch_#nextPosition#") />
	<cfset nextPosition = nextPosition + 1 />
</cfif>
	
<cfif getPaymentAccountExist>
	<cfset filterPaymentAccount = Evaluate("form.sSearch_#nextPosition#") />
	<cfset nextPosition = nextPosition + 1 />
</cfif>
	
<cfif getGLAccountExist>
	<cfset filterGLAccount = Evaluate("form.sSearch_#nextPosition#") />
	<cfset nextPosition = nextPosition + 1 />
</cfif>

<!--- External ID --->
<cfset filterExternalID = Evaluate("form.sSearch_#nextPosition#") />
<cfset nextPosition = nextPosition + 1 />
	
<!--- Component Name --->
<cfset filterComponentName = Evaluate("form.sSearch_#nextPosition#") />
<cfset nextPosition = nextPosition + 1 />

	
<cfset structItemDetails = PaymentHistoryManager.getProgramAccrualData(
									contractNumber=form.contractNumber,
									contractMainID= form.contractMainID,
									listOfWords=variables.listOfWords,column_sequence_number=form.iSortCol_0,
									sort_order=form.SSORTDIR_0,startRow=variables.start_row,endRow=variables.end_row,
									deductionAccount=filterDeductionAccount,paymentAccount=filterPaymentAccount,
									glAccount=filterGLAccount,externalID=filterExternalID,componentName=filterComponentName,
									plannerID=plannerID, contractNumberFilter=filterContractNumber, shipTo=filterShipTo, shipToText=filterShipToText)>
	

 <!--- Generate JSON from Query --->
  <cfset variables.reply.aaData = [] >

  <!--- Data holder for dropdown filters (start) --->
  <cfset variables.reply.ALLDEDUCTIONACCOUNT = [] >
  <cfset variables.reply.ALLPAYMENTACCOUNT = [] >
  <cfset variables.reply.ALLEXTERNALID = [] >
  <cfset variables.reply.ALLCOMPONENTNAME = [] >
  <cfset variables.reply.ALLGLACCOUNT = [] >
  <cfset variables.reply.ALLCONTRACTNUMBER = [] >
  <cfset variables.reply.ALLSHIPTO = [] >

  <!--- Data holder for dropdown filters (end) --->

    <cfoutput>	
		  <cfloop query="structItemDetails.filteredResults">
		    <cfscript>
			 variables.dArrayTmp = [];		  
			arrayAppend(variables.dArrayTmp, structItemDetails.filteredResults.contract_number);
			arrayAppend(variables.dArrayTmp, structItemDetails.filteredResults.Ship_To);
			arrayAppend(variables.dArrayTmp, structItemDetails.filteredResults.Ship_To_Name);
			if(getDeductionAccountExist eq 1){
			arrayAppend(variables.dArrayTmp, structItemDetails.filteredResults.Deduction_Account);
			}
			if(getPaymentAccountExist eq 1){
			arrayAppend(variables.dArrayTmp, structItemDetails.filteredResults.Payment_Account);
			}
			if(getGLAccountExist eq 1){
			arrayAppend(variables.dArrayTmp, structItemDetails.filteredResults.GL_Account_Desc);
			}
		
			arrayAppend(variables.dArrayTmp, structItemDetails.filteredResults.External_ID);
			arrayAppend(variables.dArrayTmp, structItemDetails.filteredResults.Component_Name);
			arrayAppend(variables.dArrayTmp, NumberFormat(structItemDetails.filteredResults.Cases_Invoiced, "_,___,___,___,___"));
			arrayAppend(variables.dArrayTmp, DollarFormat(structItemDetails.filteredResults.Amount));
			arrayAppend(variables.reply.aaData, variables.dArrayTmp);
		    </cfscript>
		  </cfloop>	
  </cfoutput>

	<cfset variables.reply.TotalCasesInvoiced = structItemDetails.TotalFilteredCasesInvoiced>
	<cfset variables.reply.TotalAmount = structItemDetails.TotalFilteredAmount>
	<cfset variables.reply.TotalSpentDollars = structItemDetails.TotalFilteredSpentDollars>
	<cfset variables.reply.TotalRemainingDollars = structItemDetails.TotalFilteredRemainingDollars>
	<cfset variables.reply.TotalRemainingPercent = structItemDetails.TotalFilteredRemainingPercent / 100>

	<!--- POPULATE DATA FOR THE FILTER DROPDOWNS (START) --->
	<cfif getDeductionAccountExist eq 1>
	 <cfloop query="structItemDetails.qGetUniqueDeductionAccount">
		 <cfscript>
			 variables.dArrayTmp = [];
			arrayAppend(variables.dArrayTmp, Deduction_Account);
						 
			arrayAppend(variables.reply.ALLDEDUCTIONACCOUNT, variables.dArrayTmp);
		</cfscript>
	</cfloop>
	</cfif>

	<cfif getPaymentAccountExist eq 1>
	 <cfloop query="structItemDetails.qGetUniquePaymentAccount">
		 <cfscript>
			 variables.dArrayTmp = [];
			arrayAppend(variables.dArrayTmp, Payment_Account);
						 
			arrayAppend(variables.reply.ALLPAYMENTACCOUNT, variables.dArrayTmp);
		</cfscript>
	 </cfloop>
	</cfif>

	 <cfloop query="structItemDetails.qGetUniqueExternalID">
		 <cfscript>
			 variables.dArrayTmp = [];
			arrayAppend(variables.dArrayTmp, External_ID);
						 
			arrayAppend(variables.reply.ALLEXTERNALID, variables.dArrayTmp);
		</cfscript>
	 </cfloop>

	 <cfloop query="structItemDetails.qGetUniqueComponentName">
		 <cfscript>
			 variables.dArrayTmp = [];
			arrayAppend(variables.dArrayTmp, Component_Name);
						 
			arrayAppend(variables.reply.ALLCOMPONENTNAME, variables.dArrayTmp);
		</cfscript>
	 </cfloop>

	<cfif getGLAccountExist eq 1>
	<cfloop query="structItemDetails.qGetUniqueGLAccount">
		 <cfscript>
			 variables.dArrayTmp = [];
			arrayAppend(variables.dArrayTmp, GL_Account_Desc);
						 
			arrayAppend(variables.reply.ALLGLACCOUNT, variables.dArrayTmp);
		</cfscript>
	</cfloop>
	</cfif>


	<cfloop query="structItemDetails.qGetUniqueContractNumber">
		<cfscript>
			variables.dArrayTmp = [];
			arrayAppend(variables.dArrayTmp, contract_number);
						
			arrayAppend(variables.reply.ALLCONTRACTNUMBER, variables.dArrayTmp);
		</cfscript>
	</cfloop>


	 <cfloop query="structItemDetails.qGetUniqueShipTo">
		 <cfscript>
			 variables.dArrayTmp = [];
			arrayAppend(variables.dArrayTmp, Ship_To);
						 
			arrayAppend(variables.reply.ALLSHIPTO, variables.dArrayTmp);
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