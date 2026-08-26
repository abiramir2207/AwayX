<!-----------------------------------------------------------------------------

FILE NAME:		Email_Log_data.cfm
DESCRIPTION:
CREATED BY:		Anand Rao/09-Jun-2016
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

			Anand Rao	09-Jun-2016	Created

------------------------------------------------------------------------------>
<cfsetting showDebugOutput="no">
<cfprocessingdirective suppresswhitespace="yes">
<cfparam name="form.iDisplayStart"		default="0">
<cfparam name="form.iDisplayLength"	default="100">
<cfparam name="form.sEcho"			default="10">
<cfparam name="form.iSortCol_0"		default="0">
<cfparam name="form.SSORTDIR_0"		default="asc">
<cfparam name="form.contract_number"	default="">
<cfparam name="form.sSearch_1"		default="">
<cfparam name="form.sSearch_Type"		default="">
<cfparam name="form.contractId"		default="">

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

	<cfset objProgram = CreateObject("component", "components.programs.Program") />
	<cfset structGetEmailLog = objProgram.getEmailLog(
											contractId= form.contractId,
											listOfWords=variables.listOfWords,
											startRow=variables.start_row,
											endRow=variables.end_row,
											sType=form.sSearch_1,		
											column_sequence_number = form.iSortCol_0,
											sort_order=form.SSORTDIR_0								
											)>
 	<!--- Generate JSON from Query --->
	<cfset variables.reply.aaData = [] >
    <cfoutput>	
		  <cfloop query="structGetEmailLog.filteredResults">
		    <cfscript>
			 variables.dArrayTmp = [];		
			arrayAppend(variables.dArrayTmp, structGetEmailLog.filteredResults.Message_Log_ID);	// ID
			if (structGetEmailLog.filteredResults.App_Area_ID == 15 )							// Type
				{
					arrayAppend(variables.dArrayTmp,'Letters');
				}
			else if (structGetEmailLog.filteredResults.App_Area_ID == 16)
				{	
					arrayAppend(variables.dArrayTmp,'Claim Rates');
				}

			else if (structGetEmailLog.filteredResults.App_Area_ID == 17)
				{	
					arrayAppend(variables.dArrayTmp,'Claim Rates & Letters');
				}
			arrayAppend(variables.dArrayTmp, structGetEmailLog.filteredResults.Message_From);
			arrayAppend(variables.dArrayTmp, Replace(structGetEmailLog.filteredResults.Message_To,',',',<br>','ALL'));
			arrayAppend(variables.dArrayTmp, structGetEmailLog.filteredResults.Message_Subject);
			arrayAppend(variables.dArrayTmp, '<a href="##" style="cursor:hand;"  onclick="showMessage(#structGetEmailLog.filteredResults.Message_Log_ID#)"  title="#structGetEmailLog.filteredResults.Message#">[view]</a>');
				letter_name_pdf = trim(structGetEmailLog.filteredResults.Letter_Name) & '.pdf';
			if (structGetEmailLog.filteredResults.App_Area_ID == 15 OR structGetEmailLog.filteredResults.App_Area_ID == 17)
			{
				if (structGetEmailLog.filteredResults.letter_type EQ 1)
				{ 
					arrayAppend(variables.dArrayTmp, '<a href="##" onclick="fnDownload(''/GetDocument.cfm?FilePath=data_files/created/contracts/letters/output/operators/#form.ContractId#/#letter_name_pdf#'')" border="0" title="#structGetEmailLog.filteredResults.Letter_Name#"><img src="Letters/images/icon_PDF.gif" title="#structGetEmailLog.filteredResults.Letter_Name#" border="0"/></a>');
				}
				else if (structGetEmailLog.filteredResults.letter_type == 2)
				{
					arrayAppend(variables.dArrayTmp, '<a href="##" onclick="fnDownload(''/GetDocument.cfm?FilePath=data_files/created/contracts/letters/output/distributors/#form.ContractId#/#letter_name_pdf#'')" border="0" title="#structGetEmailLog.filteredResults.Letter_Name#"><img src="Letters/images/icon_PDF.gif" title="#structGetEmailLog.filteredResults.Letter_Name#" border="0"/></a>');
				}
				else
				{
					arrayAppend(variables.dArrayTmp, '-None-');
				}
			}	
			else
			{
				arrayAppend(variables.dArrayTmp, '-None-');
			}		 
			arrayAppend(variables.dArrayTmp,'#DateFormat(structGetEmailLog.filteredResults.Created_Date, "mm/dd/yyyy")# <br>#TimeFormat(structGetEmailLog.filteredResults.Created_Date, "hh:mm tt")#');
			 arrayAppend(variables.dArrayTmp, structGetEmailLog.filteredResults.Contract_Revision_Number); // Program version
			 arrayAppend(variables.reply.aaData, variables.dArrayTmp);
		    </cfscript>
		  </cfloop>	
  	</cfoutput>
	
	<cfset variables.reply.iTotalRecords = structGetEmailLog.recordTotal>
	<cfset variables.reply.iTotalDisplayRecords = structGetEmailLog..filteredTotal>
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