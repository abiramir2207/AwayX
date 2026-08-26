<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\contracts\ajax\volume_item_details.cfm
      Date:     2016 January
      Author:   Milan Mushran
      Purpose:  AJAX processing for loading and searching volume item details
----------------------------------------------------------------------------------------------------------------------->
<cfsetting showDebugOutput="no">
<cfprocessingdirective suppresswhitespace="yes">
<cfparam name="url.iDisplayStart"		default="0">
<cfparam name="url.iDisplayLength"	default="100">
<cfparam name="url.sEcho"			default="10">
<cfparam name="url.iSortCol_0"		default="0">
<cfparam name="url.SSORTDIR_0"		default="asc">
<cfparam name="url.contract_number"	default="">
<cfparam name="url.contractId"	default="">

  <cfscript>
    variables.reply = {};

    variables.page_size   = val(url.iDisplayLength);
    if ( variables.page_size eq -1) {
      variables.start_row   = 1;
      variables.end_row     = -1;
    }
    else {
      variables.start_row   = url.iDisplayStart + 1;
      variables.end_row     = url.iDisplayStart + variables.page_size;
    }
    url.sSearch = trim(url.sSearch);

    // parse search string into an array of words
    if ( len(url.sSearch) ) {
      variables.arrayOfWords = reMatch( "[[:word:]]+", url.sSearch );
    }
    else {
      variables.arrayOfWords = [];
    }
    // concatenate array of words into a long string delimited by % ( for SQL LIKE condition )
    variables.listOfWords = arrayToList(variables.arrayOfWords, "%");

    url.iSortCol_0 = val(url.iSortCol_0);
  </cfscript>

<cfset PaymentHistoryManager = CreateObject("component","components.programs.paymenthistory.PaymentHistoryManager") />

<cfset structItemDetails = PaymentHistoryManager.getProgramEstimatedAndForecastedToGoAndActualVolumeItems(contractNumber=url.contractNumber,contractId=url.contractId,
																				listOfWords=variables.listOfWords,column_sequence_number=url.iSortCol_0,
																				sort_order=url.SSORTDIR_0,startRow=variables.start_row,displayLength=url.iDisplayLength)>

 <!--- Generate JSON from Query --->
  <cfset variables.reply.aaData = [] >

    <cfoutput>	
		  <cfloop query="structItemDetails.filteredResults">
		    <cfscript>
			 variables.dArrayTmp = [];

			arrayAppend(variables.dArrayTmp, structItemDetails.filteredResults.Item);
			arrayAppend(variables.dArrayTmp, structItemDetails.filteredResults.Description);
			arrayAppend(variables.dArrayTmp, NumberFormat(structItemDetails.filteredResults.Estimated_Volume, "_,___,___,___,___"));
			arrayAppend(variables.dArrayTmp, NumberFormat(structItemDetails.filteredResults.Actual_Volume, "_,___,___,___,___"));
			arrayAppend(variables.dArrayTmp, NumberFormat(structItemDetails.filteredResults.Forecasted_To_Go_Volume, "_,___,___,___,___"));
			arrayAppend(variables.dArrayTmp, NumberFormat(structItemDetails.filteredResults.variance, "_,___,___,___,___"));
			 
			 arrayAppend(variables.reply.aaData, variables.dArrayTmp);
		    </cfscript>
		  </cfloop>	
  </cfoutput>

	<cfset variables.reply.TotalEstimatedVolume = structItemDetails.TotalFilteredEstimatedVolume>
	<cfset variables.reply.TotalActualVolume = structItemDetails.TotalFilteredActualVolume>
	<cfset variables.reply.TotalForecastedToGoVolume = structItemDetails.TotalFilteredForecastedToGoVolume>
	<cfset variables.reply.TotalVarianceVolume = structItemDetails.TotalFilteredVarianceVolume>
  
	<cfset variables.reply.iTotalRecords = structItemDetails.recordTotal>
	<cfset variables.reply.iTotalDisplayRecords = structItemDetails.filteredTotal>
	<cfset variables.reply.sEcho  = javacast('int', url.sEcho)>
	<cfset variables.sOut = SerializeJSON( variables.reply )>


  <!--- Since SerializeJSON capitalize the content which is case-sensitive let's reset it the correct way --->
  <cfset variables.sOut = Replace (variables.sOut, 'SECHO', 'sEcho', 'one')>
  <cfset variables.sOut = Replace (variables.sOut, 'ITOTALRECORDS', 'iTotalRecords', 'one')>
  <cfset variables.sOut = Replace (variables.sOut, 'ITOTALDISPLAYRECORDS', 'iTotalDisplayRecords', 'one')>
  <cfset variables.sOut = Replace (variables.sOut, 'AADATA', 'aaData', 'one')>

<!---send JSON data back to client--->
<cfoutput>#variables.sOut#</cfoutput>

</cfprocessingdirective>