<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\ajax\listActAdjustment.cfm
      Date:     2014 Jan
      Author:   Chris Nguyen
      Purpose:  aJax processing for list of act adjustments

      Remarks:  Columns information ( position starts with zero due to javaScript/aJax )
                   0 = Adj Date
                   1 = Start Date
                   2 = End Date
                   3 = Program
                   4 = Lump sum
                   5 = Account
                   6 = Adj Amount
                   7 = Notes
----------------------------------------------------------------------------------------------------------------------->
<cfsetting showDebugOutput="no">
<cfprocessingdirective suppresswhitespace="yes">
<cfsilent>
  <cfparam name="url.iDisplayStart"   default="0">
  <cfparam name="url.iDisplayLength"  default="250">
  <cfparam name="url.sEcho"           default="10">
  <cfparam name="url.iSortCol_0"      default="">
  <cfparam name="url.contractnumber"  default="">
  <cfparam name="url.plannerID"  	  default="0">
  <cfparam name="url.PaymentHistory"  default="no">
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
    variables.unknown = 'unknown';
    variables.dSearch = ( isDate(url.sSearch) ? dateFormat(parseDateTime(url.sSearch),'short') : variables.unknown );

    // parse search string into an array of words
    if ( len(url.sSearch) ) {
      variables.arrayOfWords = reMatch( "[[:word:]]+", url.sSearch );
    }
    else {
      variables.arrayOfWords = [];
    }   
    // concatenate array of words into a long string delimited by % ( for SQL LIKE condition )
    variables.listOfWords = arrayToList(variables.arrayOfWords, "%");    
  </cfscript>
<cfset appSettings = application.appSettingsGet />
  <cfoutput>
  <cfquery name="variables.qRows" datasource="#application.datasource#">
    SELECT baa.Adjustment_Date
           ,baa.Adjustment_Dollar
           ,baa.Adjustment_Notes
           ,lsname.Program_Lump_Sum_Name
           ,ls.Lump_Sum_Amount
           ,cm.Contract_Number
           ,cm.Contract_Title
           ,c.Name AS distributor_name
           ,c.shr_Ship_To
           ,baa.Start_Date
           ,baa.End_Date
	FROM BUDGET_ACTUAL_ADJUSTMENT baa
	INNER JOIN CONTRACT_MAIN cm 
	ON cm.Contract_Main_Id = baa.Contract_Main_Id
	INNER JOIN PROGRAM_LUMP_SUMS ls 
	ON ls.Program_Lump_Sum_Id = baa.Program_Lump_Sum_Id
	AND ls.Deleted = 0
	LEFT JOIN PROGRAM_LUMP_SUM_NAME lsname 
	ON lsname.Program_Lump_Sum_Name_Id = ls.Program_Lump_Sum_Name_Id
	LEFT JOIN BSA_FOODSERVICE_CUSTOMERS c 
	ON c.bsa_FoodService_Customers_Id = baa.bsa_FoodService_Customers_Id
    WHERE 1 = 1
             <cfif len(url.sSearch)>
                AND (    
                    <cfif url.PaymentHistory NEQ 'yes'>
                      cm.Contract_Number LIKE '%#variables.listOfWords#%' OR
                    </cfif>
                      c.shr_Ship_To LIKE '%#variables.listOfWords#%' 
                      OR c.Name LIKE '%#variables.listOfWords#%' 
                      OR lsname.Program_Lump_Sum_Name LIKE '%#variables.listOfWords#%' 
                      OR baa.Adjustment_Notes LIKE '%#variables.listOfWords#%' 

                      <cfif variables.dSearch neq variables.unknown>
                        OR baa.Adjustment_Date = '#variables.dSearch#'
                        OR baa.Start_Date = '#variables.dSearch#'
                        OR baa.End_Date = '#variables.dSearch#'
                      </cfif> )
             </cfif>
             <cfif url.PaymentHistory EQ 'yes'>
				<cfif val(plannerID)>
					AND	 CM.Planner_ID = #val(plannerID)#
				<cfelseif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
					AND  CM.Contract_Main_ID = '#url.contractMainID#'
				<cfelse>
					AND  CM.Contract_Number = '#url.contractnumber#'
				</cfif>
             </cfif>
   <cfswitch expression="#url.iSortCol_0#">
     <cfcase value='0'> ORDER BY baa.Adjustment_Date #url.sSortDir_0# </cfcase>
     <cfcase value='1'> ORDER BY baa.Start_Date #url.sSortDir_0# </cfcase>
     <cfcase value='2'> ORDER BY baa.End_Date #url.sSortDir_0# </cfcase>
     <cfcase value='3'> ORDER BY cm.Contract_Number #url.sSortDir_0# </cfcase>
     <cfdefaultcase> ORDER BY baa.Created_date DESC </cfdefaultcase>
   </cfswitch>
  </cfquery>
  </cfoutput>

  <!---get total number of records BEFORE filtering--->
  <cfif len(url.sSearch) eq 0>
    <!--- no filtering so grap the count from existing query --->
    <cfset variables.reply.iTotalRecords = variables.qRows.recordCount>
  <cfelse>
    <cfquery name="variables.totalBeforeFilter" datasource="#application.datasource#">
          SELECT COUNT(1) AS rownbr
          FROM BUDGET_ACTUAL_ADJUSTMENT baa
               INNER JOIN CONTRACT_MAIN cm ON cm.Contract_Main_Id = baa.Contract_Main_Id
               INNER JOIN PROGRAM_LUMP_SUMS ls ON ls.Program_Lump_Sum_Id = baa.Program_Lump_Sum_Id
                                                  AND ls.Deleted = 0
               LEFT JOIN PROGRAM_LUMP_SUM_NAME lsname ON lsname.Program_Lump_Sum_Name_Id = ls.Program_Lump_Sum_Name_Id
               LEFT JOIN BSA_FOODSERVICE_CUSTOMERS c ON c.bsa_FoodService_Customers_Id = baa.bsa_FoodService_Customers_Id
    </cfquery>
    <cfset variables.reply.iTotalRecords = variables.totalBeforeFilter.rownbr>
  </cfif>
  <cfset variables.reply.iTotalDisplayRecords = variables.qRows.recordCount>

  <!--- Generate JSON from Query --->
  <cfset variables.reply.aaData = [] >
  <cfif variables.end_row eq -1>
    <cfset variables.start_row = 1>
    <cfset variables.end_row   = variables.qRows.recordCount>
  <cfelse>
    <cfset variables.end_row   = min(variables.end_row, variables.qRows.recordCount)>
  </cfif>

  <cfoutput>
  <cfloop query="variables.qRows" startRow="#variables.start_row#" endRow="#variables.end_row#">
    <cfscript>
       dArrayTmp = [];
       /* arrayAppend(dArrayTmp, dateFormat(variables.qRows.adjustment_date, 'm/d/yyyy')); */
       arrayAppend(dArrayTmp, dateFormat(variables.qRows.start_date, 'm/d/yyyy'));
       arrayAppend(dArrayTmp, dateFormat(variables.qRows.end_date, 'm/d/yyyy'));
       arrayAppend(dArrayTmp, variables.qRows.contract_number & " &raquo;");
       arrayAppend(dArrayTmp, variables.qRows.Program_Lump_Sum_Name & " " & dollarFormat(variables.qRows.Lump_Sum_Amount));
       arrayAppend(dArrayTmp, (len(variables.qRows.Shr_Ship_To) ? variables.qRows.Distributor_Name & " [" & variables.qRows.Shr_Ship_To & "]" : ''));
       arrayAppend(dArrayTmp, NumberFormat(variables.qRows.adjustment_dollar, "$,.99" ));
       arrayAppend(dArrayTmp, variables.qRows.adjustment_notes);

       arrayAppend(dArrayTmp, variables.qRows.Contract_Title);  // to be used as title attribute for column four 

       arrayAppend(variables.reply.aaData, dArrayTmp);
    </cfscript>
  </cfloop>
  </cfoutput>

  <cfset variables.reply.sEcho  = javacast('int', url.sEcho)>
  <cfset variables.sOut = SerializeJSON( variables.reply )>

  <!--- Since SerializeJSON capitalize the content which is case-sensitive let's reset it the correct way --->
  <cfset variables.sOut = Replace (variables.sOut, 'SECHO', 'sEcho', 'one')>
  <cfset variables.sOut = Replace (variables.sOut, 'ITOTALRECORDS', 'iTotalRecords', 'one')>
  <cfset variables.sOut = Replace (variables.sOut, 'ITOTALDISPLAYRECORDS', 'iTotalDisplayRecords', 'one')>
  <cfset variables.sOut = Replace (variables.sOut, 'AADATA', 'aaData', 'one')>
</cfsilent>

<!---send JSON data back to client--->
<cfoutput>#variables.sOut#</cfoutput>
</cfprocessingdirective>















