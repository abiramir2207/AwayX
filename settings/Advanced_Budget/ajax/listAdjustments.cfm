<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\ajax\listAdjustmentS.cfm
      Date:     2014 Jan
      Author:   Chris Nguyen
      Purpose:  aJax processing for list of fixed adjustments

      Remarks:  Columns information ( position starts with zero due to javaScript/aJax )
                   0 = Customer
                   1 = Amount
                   2 = Type
                   3 = Start Date
                   4 = End Date
                   5 = Created By
                   6 = Created Date
                   7 = Notes

                IMPORTANT: When column order is changed remember to search & change the related logic for:
                              A.  url.sSearch_[0|1|2|3|..]
                              B.  url.iSortCol_[0|1|2|3|..]
----------------------------------------------------------------------------------------------------------------------->
<cfsetting showDebugOutput="no">
<cfprocessingdirective suppresswhitespace="yes">
<cfsilent>
  <cfparam name="url.iDisplayStart"   default="0">
  <cfparam name="url.iDisplayLength"  default="100">
  <cfparam name="url.sEcho"           default="10">
  <cfparam name="url.iSortCol_0"      default="">
    
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

  <cfoutput>
  <cfquery name="variables.qRows" datasource="#application.datasource#">
    SELECT  a.Adjustment_Dollar
           ,a.Created_Date
           ,a.Adjustment_Notes
           ,Customer_Position = CASE
                                  WHEN (a.BSA_Foodservice_Customers_ID IS NOT NULL) THEN c.Name
                                  WHEN (a.User_Positions_ID > 0) THEN d.Position_Label
                                  ELSE ''
                                END
           ,Adjustment_Type = b.description
           ,Created_By = e.name_first + ' ' + e.name_last
           ,c.Ship_To
           ,a.Start_Date
           ,a.End_Date
      FROM Budget_Adjustment a
           INNER JOIN Budget_Adjustment_Type b ON a.Budget_Adjustment_Type_Id = b.Budget_Adjustment_Type_Id
           LEFT JOIN BSA_Foodservice_Customers c ON c.BSA_Foodservice_Customers_ID = a.BSA_Foodservice_Customers_ID
           LEFT JOIN User_Positions d ON d.User_Positions_Id = a.User_Positions_ID
           LEFT JOIN _Users e ON e.User_ID = a.Created_By
     WHERE a.Budget_Id = <cfqueryparam value="#url.Budget_Id#" cfsqltype="cf_sql_integer">
           AND a.Deleted = 0
             <cfif len(url.sSearch)>
                AND (  e.name_first + ' ' + e.name_last LIKE '%#variables.listOfWords#%'
                        OR b.description LIKE '%#variables.listOfWords#%'
                        OR a.Adjustment_Notes LIKE '%#variables.listOfWords#%'
                        OR c.Name LIKE '%#variables.listOfWords#%'
                        OR d.Position_Label LIKE '%#variables.listOfWords#%'

                      <cfif variables.dSearch neq variables.unknown>
                        OR CAST(a.Created_Date AS DATE) = '#variables.dSearch#'
                        OR CAST(a.Start_Date AS DATE) = '#variables.dSearch#'
                        OR CAST(a.End_Date AS DATE) = '#variables.dSearch#'
                      </cfif> )
             </cfif>
   <cfswitch expression="#url.iSortCol_0#">
     <cfcase value='0'> ORDER BY CASE
                                  WHEN (a.BSA_Foodservice_Customers_ID IS NOT NULL) THEN c.Name
                                  WHEN (a.User_Positions_ID > 0) THEN d.Position_Label
                                  ELSE ''
                                END #url.sSortDir_0# </cfcase>
     <cfcase value='1'> ORDER BY a.Adjustment_Dollar #url.sSortDir_0# </cfcase>
     <cfcase value='2'> ORDER BY b.description #url.sSortDir_0# </cfcase>
     <cfcase value='3'> ORDER BY a.Start_Date #url.sSortDir_0# </cfcase>
     <cfcase value='4'> ORDER BY a.End_Date #url.sSortDir_0# </cfcase>
     <cfcase value='5'> ORDER BY e.name_first + ' ' + e.name_last #url.sSortDir_0# </cfcase>
     <cfcase value='6'> ORDER BY a.Created_date #url.sSortDir_0# </cfcase>
     <cfdefaultcase> ORDER BY a.Created_date DESC </cfdefaultcase>
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
            FROM Budget_Adjustment a
                 INNER JOIN Budget_Adjustment_Type b ON a.Budget_Adjustment_Type_Id = b.Budget_Adjustment_Type_Id
                 LEFT JOIN BSA_Foodservice_Customers c ON c.BSA_Foodservice_Customers_ID = a.BSA_Foodservice_Customers_ID
                 LEFT JOIN User_Positions d ON d.User_Positions_Id = a.User_Positions_ID
                 LEFT JOIN _Users e ON e.User_ID = a.Created_By
           WHERE a.Budget_Id = <cfqueryparam value="#url.Budget_Id#" cfsqltype="cf_sql_integer">
                 AND a.Deleted = 0
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
       arrayAppend(dArrayTmp, variables.qRows.Customer_Position & " (" & variables.qRows.Ship_To & ")");
       arrayAppend(dArrayTmp, dollarFormat(variables.qRows.adjustment_dollar));
       arrayAppend(dArrayTmp, variables.qRows.Adjustment_Type);
       arrayAppend(dArrayTmp, dateFormat(variables.qRows.start_date, 'm/d/yyyy'));
       arrayAppend(dArrayTmp, dateFormat(variables.qRows.end_date, 'm/d/yyyy'));
       arrayAppend(dArrayTmp, variables.qRows.Created_By);
       arrayAppend(dArrayTmp, dateFormat(variables.qRows.created_date, 'm/d/yyyy'));
       arrayAppend(dArrayTmp, variables.qRows.adjustment_notes);

       arrayAppend(variables.reply.aaData, dArrayTmp);
    </cfscript>
  </cfloop>
  </cfoutput>

  <cfset variables.reply.sEcho  = javacast('int', url.sEcho)>
  <cfset variables.reply.listOfWords = variables.listOfWords>

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















