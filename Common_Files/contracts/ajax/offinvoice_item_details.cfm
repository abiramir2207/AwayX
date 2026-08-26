<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\contracts\ajax\offinvoice_item_details.cfm
      Date:     2015 December
      Author:   Milan Mushran
      Purpose:  AJAX processing for searching off-invoice details
----------------------------------------------------------------------------------------------------------------------->
<cfsetting showDebugOutput="no">
<cfprocessingdirective suppresswhitespace="yes">
<cfparam name="form.iDisplayStart"		default="0">
<cfparam name="form.iDisplayLength"	default="100">
<cfparam name="form.sEcho"			default="10">
<cfparam name="form.iSortCol_0"		default="0">
<cfparam name="form.SSORTDIR_0"		default="asc">
<cfparam name="form.contract_number"	default="">
<cfparam name="form.yearMonthList" default="">
<cfparam name="form.payee"			default="">
<cfparam name="form.offinvoice_number"	default="">
<cfparam name="form.item_number"		default="">
<cfparam name="form.plannerID"		default="0">

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

<cfset structItemDetails = PaymentHistoryManager.getOperatorOffInvoiceDataDetails(contract_number=form.contract_number,contractMainID=form.ContractId,yearMonthList=form.yearMonthList,
																payee=form.payee,offinvoice_number=form.offinvoice_number,item_number=form.item_number,
																listOfWords=variables.listOfWords,column_sequence_number=form.iSortCol_0,sort_order=form.SSORTDIR_0,
																startRow=variables.start_row,endRow=variables.end_row,plannerID=plannerID)>
 <!--- Generate JSON from Query --->
  <cfset variables.reply.aaData = [] >

<!--- NOT SHOWING THE COLUMNS TOTAL AS THERE MIGHT BE DIFFERENCE IN THE TOTAL FROM THE MAIN SUMMARY PAGE DUE TO DECIMAL ISSUES.
EVEN IF THE TOTAL MATCHES, THE TOTAL WOULD NOT MATCH THE INDIVIDUAL ENTRIES AS THE INDIVIDUAL ENTRIES USE NUMERICFORMAT.
--->
  <cfoutput>
		  <cfloop query="structItemDetails.filteredResults">
		    <cfscript>
			 variables.dArrayTmp = [];

			 arrayAppend(variables.dArrayTmp, '<a href="##" onclick="viewDetails(''#structItemDetails.filteredResults.Invoice_number#'',''#structItemDetails.filteredResults.Invoice_Date#'')" border="0">#structItemDetails.filteredResults.Invoice_number#</a>');
			 arrayAppend(variables.dArrayTmp, structItemDetails.filteredResults.Invoice_Date);
			 arrayAppend(variables.dArrayTmp, structItemDetails.filteredResults.Item);
			 arrayAppend(variables.dArrayTmp, structItemDetails.filteredResults.Description);
			 arrayAppend(variables.dArrayTmp, DollarFormat(structItemDetails.filteredResults.Sales_Dollars));
			 arrayAppend(variables.dArrayTmp, NumberFormat(structItemDetails.filteredResults.Volume_CS, "_,___,___,___,___"));
			 arrayAppend(variables.dArrayTmp, NumberFormat(structItemDetails.filteredResults.Volume_LB, "_,___,___,___,___"));
			 arrayAppend(variables.dArrayTmp, structItemDetails.filteredResults.Shr_ship_to);
			 arrayAppend(variables.dArrayTmp, structItemDetails.filteredResults.Ship_to_name);

			 arrayAppend(variables.reply.aaData, variables.dArrayTmp);
		    </cfscript>
		  </cfloop>
  </cfoutput>

  <cfset variables.reply.TotalAmount = structItemDetails.TotalAmount>
  <cfset variables.reply.TotalCasesInvoiced = structItemDetails.TotalCasesInvoiced>
  <cfset variables.reply.TotalPoundsInvoiced = structItemDetails.TotalPoundsInvoiced>

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