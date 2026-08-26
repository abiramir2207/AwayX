<!---------------------------------------------------------------------------------------------------------------------
      Template: \billbacks\settings\ajax\BBProgramReprocess.cfm
      Date:     2014 April
      Author:   Chris Nguyen
      Purpose:  aJax processing for re-process programs

      Remarks:  Columns information ( position starts with zero due to javaScript/aJax )
                   0 = Checkbox
                   1 = Payable
                   2 = Status
                   3 = Claim $
                   4 = Ref ##
                   5 = BB ##
                   6 = Payee ID / Name
                   7 = Created Date
----------------------------------------------------------------------------------------------------------------------->
<cfsetting showDebugOutput="no">
<cfprocessingdirective suppresswhitespace="yes">
<cfsilent>
  <cfparam name="form.iDisplayStart"   default="0">
  <cfparam name="form.iDisplayLength"  default="100">
  <cfparam name="form.sEcho"           default="10">
  <cfparam name="form.iSortCol_0"      default="0">
  <cfparam name="form.SSORTDIR_0"      default="asc">

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
    variables.unknown = 'unknown';
    variables.dSearch = ( isDate(form.sSearch) ? dateFormat(parseDateTime(form.sSearch),'short') : variables.unknown );

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

  <cfoutput>
  <cfquery name="variables.qRows" datasource="#application.datasource#">
	/* Get Dummy Program_IDs used currently and in the past */
       IF OBJECT_ID('tempdb..##Default_Program_ID') IS NOT NULL 
       DROP TABLE ##Default_Program_ID
       
	SELECT cm_num.Contract_Main_ID
    INTO ##Default_Program_ID
    FROM dbo.Contract_Main cm_num
    JOIN dbo.Contract_Main cm_id
          ON cm_id.Contract_Number = cm_num.Contract_Number
          AND cm_id.Contract_Main_ID = (SELECT Default_Program FROM Billback_Settings)

    SELECT BB.BB_Code,
           BBS.BB_Status_Description,
           BBS.BB_Status_Abbreviation,
           BB.BB_Reference,
           BB.Billback_Status_ID,
           CASE
            WHEN BB.Billback_Payee_Type_ID = 1 THEN ISNULL(BSAFC.Name, VM.Vendor_Name)
            WHEN BB.Billback_Payee_Type_ID = 2 THEN BSAO.Operator_Name
            WHEN BB.Billback_Payee_Type_ID = 3 THEN BSAB.Broker_Name
           END as Payee_Name,
           BB.referenceNum,
           BB.Created_Date,
           BB.BB_Amount,
           BB.Billback_ID
      FROM Billback BB
            INNER JOIN Billback_Program BP ON BP.Billback_ID = BB.Billback_ID
            /* INNER JOIN Billback_Settings BS ON BS.Default_Program = BP.Program_ID */
			INNER JOIN ##Default_Program_ID BS ON BS. Contract_Main_ID = BP.Program_ID
            INNER JOIN Billback_Status BBS ON BBS.Billback_Status_ID = BB.Billback_Status_ID
            INNER JOIN Billback_Allied BA ON BA.Billback_ID = BB.Billback_ID
            LEFT JOIN Billback_Distributor BD ON BD.Billback_ID = BB.Billback_ID AND BD.Deleted = 0 AND BB.Billback_Payee_Type_ID = 1
            LEFT JOIN BSA_Foodservice_Customers BSAFC ON BSAFC.BSA_Foodservice_Customers_ID = BD.Distributor_ID
            LEFT JOIN Billback_Operator BO ON BO.Billback_ID = BB.Billback_ID AND BO.Deleted = 0 AND BB.Billback_Payee_Type_ID = 2
            LEFT JOIN BSA_Operator BSAO ON BSAO.BSA_Operator_ID = BO.Operator_ID
            LEFT JOIN Billback_Broker BBR ON BBR.Billback_ID = BB.Billback_ID AND BBR.Deleted = 0 AND BB.Billback_Payee_Type_ID = 3
            LEFT JOIN BSA_Foodservice_Brokers BSAB ON BSAB.BSA_Foodservice_Brokers_ID = BBR.Broker_ID
            LEFT JOIN Vendor_Master VM ON VM.vendor_Master_Id = BD.Distributor_ID
    WHERE BB.Deleted = 0 AND BB.Billback_Status_ID <=2 AND BP.Deleted = 0
             <cfif len(form.sSearch)>
                AND (    BB.BB_Code LIKE '%#variables.listOfWords#%'
                      OR BBS.BB_Status_Description LIKE '%#variables.listOfWords#%'
                      OR BBS.BB_Status_Abbreviation LIKE '%#variables.listOfWords#%'
                      OR BB.referenceNum LIKE '%#variables.listOfWords#%'
                      OR BB.BB_Reference LIKE '%#variables.listOfWords#%'
                      OR CASE
                           WHEN BB.Billback_Payee_Type_ID = 1 THEN ISNULL(BSAFC.Name, VM.Vendor_Name)
                           WHEN BB.Billback_Payee_Type_ID = 2 THEN BSAO.Operator_Name
                           WHEN BB.Billback_Payee_Type_ID = 3 THEN BSAB.Broker_Name
                         END LIKE '%#variables.listOfWords#%'
                    )
             </cfif>
    <cfswitch expression="#form.iSortCol_0#">
      <cfcase value=0>  </cfcase>
      <cfcase value=1> ORDER BY BB.BB_Code #form.sSortDir_0# </cfcase>
      <cfcase value=2> ORDER BY BBS.BB_Status_Description #form.sSortDir_0#, BB.BB_Code </cfcase>
      <cfcase value=3> ORDER BY BB.BB_Amount #form.sSortDir_0#, BB.BB_Code </cfcase>
      <cfcase value=4> ORDER BY BB.referenceNum #form.sSortDir_0#, BB.BB_Code </cfcase>
      <cfcase value=5> ORDER BY BB.BB_Reference #form.sSortDir_0#, BB.BB_Code </cfcase>
      <cfcase value=6> ORDER BY Payee_Name #form.sSortDir_0#, BB.BB_Code </cfcase>
      <cfcase value=7> ORDER BY BB.Created_Date #form.sSortDir_0#, BB.BB_Code </cfcase>
    </cfswitch>
  </cfquery>
  </cfoutput>

  <!---get total number of records BEFORE filtering--->
  <cfif len(form.sSearch) eq 0>
    <!--- no filtering so grap the count from existing query --->
    <cfset variables.reply.iTotalRecords = variables.qRows.recordCount>
  <cfelse>
    <cfquery name="variables.totalBeforeFilter" datasource="#application.datasource#">
      SELECT COUNT(1) AS rownbr
        FROM Billback BB
              INNER JOIN Billback_Program BP ON BP.Billback_ID = BB.Billback_ID
              INNER JOIN Billback_Settings BS ON BS.Default_Program = BP.Program_ID
              INNER JOIN Billback_Status BBS ON BBS.Billback_Status_ID = BB.Billback_Status_ID
              INNER JOIN Billback_Allied BA ON BA.Billback_ID = BB.Billback_ID
              LEFT JOIN Billback_Distributor BD ON BD.Billback_ID = BB.Billback_ID AND BD.Deleted = 0 AND BB.Billback_Payee_Type_ID = 1
              LEFT JOIN BSA_Foodservice_Customers BSAFC ON BSAFC.BSA_Foodservice_Customers_ID = BD.Distributor_ID
              LEFT JOIN Billback_Operator BO ON BO.Billback_ID = BB.Billback_ID AND BO.Deleted = 0 AND BB.Billback_Payee_Type_ID = 2
              LEFT JOIN BSA_Operator BSAO ON BSAO.BSA_Operator_ID = BO.Operator_ID
              LEFT JOIN Billback_Broker BBR ON BBR.Billback_ID = BB.Billback_ID AND BBR.Deleted = 0 AND BB.Billback_Payee_Type_ID = 3
              LEFT JOIN BSA_Foodservice_Brokers BSAB ON BSAB.BSA_Foodservice_Brokers_ID = BBR.Broker_ID
              LEFT JOIN Vendor_Master VM ON VM.vendor_Master_Id = BD.Distributor_ID
      WHERE BB.Deleted = 0 AND BB.Billback_Status_ID <=2 AND BP.Deleted = 0
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
      variables.dArrayTmp = [];
      variables.checked   = (listFindNoCase(form.checkedBoxes, variables.qRows.Billback_ID) gt 0 ? 'checked=checked' : '');
      variables.disabled  = (form.inEditMode eq '1' ? '' : 'disabled=disabled');

      arrayAppend(variables.dArrayTmp, '<input type="checkbox" name="BB_ID" value="#variables.qRows.Billback_ID#" #variables.checked#  #disabled#  class="cb">');
      arrayAppend(variables.dArrayTmp, variables.qRows.BB_Code);
      arrayAppend(variables.dArrayTmp, variables.qRows.BB_Status_Description & " [" & variables.qRows.BB_Status_Abbreviation & "]");
      arrayAppend(variables.dArrayTmp, dollarFormat(variables.qRows.BB_Amount));
      arrayAppend(variables.dArrayTmp, variables.qRows.referenceNum);
      arrayAppend(variables.dArrayTmp, variables.qRows.BB_Reference);
      arrayAppend(variables.dArrayTmp, variables.qRows.Payee_Name);
      arrayAppend(variables.dArrayTmp, dateFormat(variables.qRows.Created_Date,'m/d/yyyy'));

      arrayAppend(variables.reply.aaData, variables.dArrayTmp);
    </cfscript>
  </cfloop>
  </cfoutput>

  <cfset variables.reply.sEcho  = javacast('int', form.sEcho)>
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








