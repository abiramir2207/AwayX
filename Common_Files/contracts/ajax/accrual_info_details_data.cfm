<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\contracts\ajax\accrual_info_details_data.cfm
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
<cfparam name="form.Fiscal_Period"	default="">

<!--- value of dropdown filter on column 7 and so on (column numbers start with 0 on the data grid) --->
<cfparam name="form.sSearch_7"		default="">
<cfparam name="form.sSearch_8"		default="">
<cfparam name="form.sSearch_9"		default="">
<cfparam name="form.sSearch_10"		default="">
<cfparam name="form.sSearch_11"		default="">
<cfparam name="form.sSearch_12"		default="">
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
<cfset getDeductionAccountExist = PaymentHistoryManager.getDeductionAccountExist(form.contractNumber, form.contractId, plannerId)>
<cfset getPaymentAccountExist = PaymentHistoryManager.getPaymentAccountExist(contractNumber, ContractId, plannerId)>
<cfset getGLAccountExist = PaymentHistoryManager.getGLAccountExist(contractNumber, ContractId, plannerId)>
	
<cfset filterDeductionAccount = "" />
<cfset filterPaymentAccount = "" />
<cfset filterGLAccount = "" />
<cfset filterExternalID = "" />
<cfset filterComponentName = "" />
<cfset filterRateUOM = "" />
<cfset filterProductGroup = "" />
<cfset filterContractNumber = "" />
<cfset filterShipTo = "" />
<cfset filterShipToText = "" />
<cfset filterItem = "" />
<cfset filterItemDescription = "" />


<!--- Contract Number --->
<cfif plannerId neq 0>
	<cfset filterContractNumber = form.sSearch_0 />
</cfif>

<!---If we have a planner id then we are displaying the contract number in the grid as the first searchable column. 
Because of this we have to handle for the ship to column number. If we have a planner id then it has to be 2 otherwise it will be 1.
--->
<cfparam name="nextPosition" default="0" />

<cfif plannerId neq 0>
	<cfset nextPosition = 1 />
</cfif>

<!--- Item--->
<cfset filterItem = Evaluate("form.sSearch_#nextPosition#") />
<cfset nextPosition = nextPosition + 1  />

<!--- Item Description--->
<cfset filterItemDescription = Evaluate("form.sSearch_#nextPosition#") />
<cfset nextPosition = nextPosition + 1  />

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

<cfset nextPosition = nextPosition + 3 /> <!--- There are 3 columns in between Cases, Accrual $, Rate --->

<!--- Rate UOM --->
<cfset filterRateUOM = Evaluate("form.sSearch_#nextPosition#") />
<cfset nextPosition = nextPosition + 1 />

<cfset structItemDetails = PaymentHistoryManager.getProgramAccrualDistributorItemData(
	   			contractNumber=form.contractNumber,contractMainID=form.contractId,
	   			distributorComponentList=form.distributorComponentList,
				listOfWords=variables.listOfWords,
				column_sequence_number=form.iSortCol_0,sort_order=form.SSORTDIR_0,
				startRow=variables.start_row,endRow=variables.end_row,
				deductionAccount=filterDeductionAccount,paymentAccount=filterPaymentAccount,
				glAccount=filterGLAccount,externalID=filterExternalID,componentName=filterComponentName,
				rateUOM=filterRateUOM,productAttribute=form.filter_ProductAttribute,selectedProductAttribute=form.Product_Group_Level_ID, 
				plannerId=form.plannerId, contractNumberFilter=filterContractNumber, shipTo=filterShipTo, shipToText=filterShipToText,
				item=filterItem, itemDescription=filterItemDescription)>
	

 <!--- Generate JSON from Query --->
  <cfset variables.reply.aaData = [] >

	<!--- Data holder for dropdown filters (start) --->
  <cfset variables.reply.AllUOM = [] >
  <cfset variables.reply.AllDeductionAccount = [] >
  <cfset variables.reply.AllPaymentAccount = [] >
  <cfset variables.reply.AllExternalID = [] >
  <cfset variables.reply.AllComponentName = [] >
  <cfset variables.reply.AllGLAccount = [] >
  <cfset variables.reply.AllProductAttributes = [] >
  <cfset variables.reply.ALLCONTRACTNUMBER = [] >
  <cfset variables.reply.ALLSHIPTO = [] >
  <cfset variables.reply.ALLITEM = [] >
  <cfset variables.reply.ALLITEMDESCRIPTIOM = [] >
  
  <!--- Data holder for dropdown filters (end) --->

    <cfoutput>	
		  <cfloop query="structItemDetails.filteredResults">
		    <cfscript>
			 variables.dArrayTmp = [];
			 if(plannerId neq 0){
				arrayAppend(variables.dArrayTmp, structItemDetails.filteredResults.contract_number);
			}
			arrayAppend(variables.dArrayTmp, structItemDetails.filteredResults.Item);
			arrayAppend(variables.dArrayTmp, structItemDetails.filteredResults.Item_Description);
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
			/* If it is an adjustment */
			if(trim(structItemDetails.filteredResults.Rate_UOM) eq ""){
				arrayAppend(variables.dArrayTmp, "");
			}
			else{
				arrayAppend(variables.dArrayTmp, NumberFormat(structItemDetails.filteredResults.Cases_Invoiced, "_,___,___,___,___"));
			}
			arrayAppend(variables.dArrayTmp, DollarFormat(structItemDetails.filteredResults.Amount));
			/* If it is an adjustment */
			if(trim(structItemDetails.filteredResults.Rate_UOM) eq ""){
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

	<cfif getDeductionAccountExist eq 1>
	 <cfloop query="structItemDetails.qGetUniqueDeductionAccount">
		 <cfscript>
			 variables.dArrayTmp = [];
			arrayAppend(variables.dArrayTmp, Deduction_Account);
						 
			arrayAppend(variables.reply.AllDeductionAccount, variables.dArrayTmp);
		</cfscript>
	</cfloop>
	</cfif>	
	 
	<cfif getPaymentAccountExist eq 1>
	 <cfloop query="structItemDetails.qGetUniquePaymentAccount">
		 <cfscript>
			 variables.dArrayTmp = [];
			arrayAppend(variables.dArrayTmp, Payment_Account);
						 
			arrayAppend(variables.reply.AllPaymentAccount, variables.dArrayTmp);
		</cfscript>
	 </cfloop>
	</cfif>	

	 <cfloop query="structItemDetails.qGetUniqueExternalID">
		 <cfscript>
			 variables.dArrayTmp = [];
			arrayAppend(variables.dArrayTmp, External_ID);
						 
			arrayAppend(variables.reply.AllExternalID, variables.dArrayTmp);
		</cfscript>
	 </cfloop>

	 <cfloop query="structItemDetails.qGetUniqueComponentName">
		 <cfscript>
			 variables.dArrayTmp = [];
			arrayAppend(variables.dArrayTmp, Component_Name);
						 
			arrayAppend(variables.reply.AllComponentName, variables.dArrayTmp);
		</cfscript>
	 </cfloop>

	<cfif getGLAccountExist eq 1>
	<cfloop query="structItemDetails.qGetUniqueGLAccount">
		 <cfscript>
			 variables.dArrayTmp = [];
			arrayAppend(variables.dArrayTmp, GL_Account_Desc);
						 
			arrayAppend(variables.reply.AllGLAccount, variables.dArrayTmp);
		</cfscript>
	</cfloop>
	</cfif>	
	
	<cfloop query="structItemDetails.qGetUniqueProductAttribute">
		 <cfscript>
			 variables.dArrayTmp = [];
			arrayAppend(variables.dArrayTmp, SelectedProductAttribute);
						 
			arrayAppend(variables.reply.AllProductAttributes, variables.dArrayTmp);
		</cfscript>
	 </cfloop>
	<cfif plannerId neq 0>
		<cfloop query="structItemDetails.qGetUniqueContractNumber">
			<cfscript>
				variables.dArrayTmp = [];
				arrayAppend(variables.dArrayTmp, contract_number);
							
				arrayAppend(variables.reply.ALLCONTRACTNUMBER, variables.dArrayTmp);
			</cfscript>
		</cfloop>
	</cfif>
	<cfloop query="structItemDetails.qGetUniqueItem">
		 <cfscript>
			 variables.dArrayTmp = [];
			arrayAppend(variables.dArrayTmp, Item);
						 
			arrayAppend(variables.reply.ALLITEM, variables.dArrayTmp);
		</cfscript>
	</cfloop>
	
	<cfloop query="structItemDetails.qGetUniqueItemDescription">
		 <cfscript>
			 variables.dArrayTmp = [];
			arrayAppend(variables.dArrayTmp, Item_Description);
						 
			arrayAppend(variables.reply.ALLITEMDESCRIPTIOM, variables.dArrayTmp);
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