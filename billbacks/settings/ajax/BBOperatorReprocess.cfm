<!---------------------------------------------------------------------------------------------------------------------
      Template: \billbacks\settings\ajax\BBOperatorReprocess.cfm
      Date:     2014 April
      Author:   Chris Nguyen
      Purpose:  aJax processing for re-process operator

      Remarks:  Columns information ( position starts with zero due to javaScript/aJax )
      
                   0 = BB Code
                   1 = Operator
                   2 = Planning Group
                   
      Parameters:
                  form.selectClass = select class name
                  form.planningGroups = list of all selected values. Each value consists of 3 elements:
                                          a.  bill back id
                                          b.  operator id
                                          c.  planning group category id
                  form.keyDelimiter = a delimiter used in the above form.planningGroups
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

  <cfset useLakebaseForvariables_qPlanningGroups = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pg_operator_category")>
<cfif useLakebaseForvariables_qPlanningGroups>
	<cftry>
		<cfset variables.qPlanningGroups = application.oLakebase.toQuery(
			application.oLakebase.selectRows("pg_operator_category", {
				"deleted" = "eq.0",
				"active" = "eq.1",
				"order" = "pg_operator_category_name.asc",
				"select" = "pg_operator_category_id,pg_operator_category_code,pg_operator_category_name"
			}), "pg_operator_category_id,pg_operator_category_code,pg_operator_category_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForvariables_qPlanningGroups = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForvariables_qPlanningGroups>
<cfquery name="variables.qPlanningGroups" datasource="#application.datasource#">
    SELECT PG_Operator_Category_ID,
            PG_Operator_Category_Code,
            PG_Operator_Category_Name
      FROM PG_OPERATOR_CATEGORY
     WHERE Deleted = 0 AND Active = 1
           ORDER BY PG_Operator_Category_Name
  </cfquery>
</cfif>

  <cfquery name="variables.qRows" datasource="#application.datasource#">
      DECLARE @Default_Program int
      SELECT @Default_Program = Default_Program
        FROM  Billback_Settings

      IF OBJECT_ID('tempdb..##tmp_dummy_pgm_list') IS NOT NULL
        DROP TABLE ##tmp_dummy_pgm_list

      SELECT Contract_Main_ID, Contract_Number
        INTO  ##tmp_dummy_pgm_list
        FROM  Contract_Main
       WHERE Contract_Number = (SELECT Contract_Number
                                  FROM Contract_Main
                                WHERE Contract_Main_ID = @Default_Program)

      SELECT      DISTINCT
                  BB.Billback_ID,
                  BB.BB_Code,
                  BB.referenceNum,
                  BPR.Program_ID,
                  dum.contract_Number,
                  BP.Operator_ID ,
                  BSAO.Legacy_ID,
                  BSAO.Operator_Name,
                  pgo.PG_Operator_Category_Code,
                  pgo.PG_Operator_Category_Name
      FROM  Billback BB
      INNER JOIN Billback_Program BPR
      ON          BPR.Billback_ID = BB.Billback_ID
      AND         BPR.Deleted = 0
      INNER JOIN ##tmp_dummy_pgm_list dum
      ON          dum.contract_main_ID = BPR.Program_ID
      INNER JOIN  Billback_Product BP
      ON          BP.Billback_ID = bb.billback_ID
      AND         BP.Billback_Program_ID = bpr.Billback_Program_ID
      AND         BP.Deleted = 0
      INNER  JOIN BSA_Operator BSAO
      ON          BSAO.BSA_Operator_ID = BP.Operator_ID
      LEFT JOIN  PG_operator_members pgom
      ON          pgom.BSA_Operator_ID = BSAO.BSA_Operator_ID
      AND         pgom.Deleted = 0
      LEFT JOIN   PG_Operator_Category pgo
      ON            pgo.PG_Operator_Category_ID = pgom.PG_Operator_Category_ID
      AND         pgo.deleted = 0
      AND         pgo.active = 1 

      WHERE BB.Uploaded_Billback = 3
      AND         BB.Deleted = 0
      AND         BB.Billback_Status_ID <=2
             <cfif len(form.sSearch)>
                AND (    BB.BB_Code LIKE '%#variables.listOfWords#%'
                      OR BSAO.Operator_Name LIKE '%#variables.listOfWords#%'
                      OR BSAO.Legacy_ID LIKE '%#variables.listOfWords#%'
                      OR BB.referenceNum LIKE '%#variables.listOfWords#%'
                      OR pgo.PG_Operator_Category_Name LIKE '%#variables.listOfWords#%'
                    )
             </cfif>
    <cfswitch expression="#form.iSortCol_0#">
      <cfcase value=0> ORDER BY BB.BB_Code #form.sSortDir_0# </cfcase>
      <cfcase value=1> ORDER BY BSAO.Operator_Name #form.sSortDir_0#, BB.BB_Code </cfcase>
      <cfcase value=2> ORDER BY BB.referenceNum #form.sSortDir_0#, BB.BB_Code </cfcase>
      <cfcase value=3> ORDER BY pgo.PG_Operator_Category_Name #form.sSortDir_0#, BB.BB_Code </cfcase>
    </cfswitch>
  </cfquery>
  </cfoutput>

  <!---get total number of records BEFORE filtering--->
  <cfif len(form.sSearch) eq 0>
    <!--- no filtering so grap the count from existing query --->
    <cfset variables.reply.iTotalRecords = variables.qRows.recordCount>
  <cfelse>
    <cfquery name="variables.totalBeforeFilter" datasource="#application.datasource#">
      DECLARE @Default_Program int
      SELECT @Default_Program = Default_Program
        FROM  Billback_Settings

      IF OBJECT_ID('tempdb..##tmp_dummy_pgm_list') IS NOT NULL
        DROP TABLE ##tmp_dummy_pgm_list

      SELECT Contract_Main_ID, Contract_Number
        INTO  ##tmp_dummy_pgm_list
        FROM  Contract_Main
       WHERE Contract_Number = (SELECT Contract_Number
                                  FROM Contract_Main
                                WHERE Contract_Main_ID = @Default_Program)

      SELECT COUNT(1) AS rownbr
        FROM (
              SELECT DISTINCT
                          BB.Billback_ID,
                          BB.BB_Code,
                          BB.referenceNum,
                          BPR.Program_ID,
                          dum.contract_Number,
                          BP.Operator_ID ,--should not be null (upload should populate the BA operator ID),
                          --below operator legacy id and name comes in the file
                          --BP.Operator_Legacy_ID, -- (if operator_ID is null then this field will have value - which means the legacy operator in this field did not exists in BA)
                          --BP.Operator_Name ---- (if operator_ID is null then this field will have value - which means the legacy operator name in this field did not exists in BA)
                          BSAO.Legacy_ID,
                          BSAO.Operator_Name,
                          pgo.PG_Operator_Category_Code,
                          pgo.PG_Operator_Category_Name
              FROM  Billback BB
              INNER JOIN Billback_Program BPR
              ON          BPR.Billback_ID = BB.Billback_ID
              AND         BPR.Deleted = 0
              INNER JOIN ##tmp_dummy_pgm_list dum
              ON          dum.contract_main_ID = BPR.Program_ID
              INNER JOIN  Billback_Product BP
              ON          BP.Billback_ID = bb.billback_ID
              AND         BP.Billback_Program_ID = bpr.Billback_Program_ID
              AND         BP.Deleted = 0
              INNER  JOIN BSA_Operator BSAO
              ON          BSAO.BSA_Operator_ID = BP.Operator_ID
              LEFT JOIN  PG_operator_members pgom
              ON          pgom.BSA_Operator_ID = BSAO.BSA_Operator_ID
              AND         pgom.Deleted = 0
              LEFT JOIN   PG_Operator_Category pgo
              ON            pgo.PG_Operator_Category_ID = pgom.PG_Operator_Category_ID
              AND         pgo.deleted = 0
              AND         pgo.active = 1 ---not sure whther we need this ;check whether other pg queries has this condition
        
              WHERE BB.Uploaded_Billback = 3
              AND         BB.Deleted = 0
              AND         BB.Billback_Status_ID <=2
              ) foo
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

      arrayAppend(variables.dArrayTmp, variables.qRows.BB_Code);
      arrayAppend(variables.dArrayTmp, variables.qRows.Operator_Name & " (" & variables.qRows.Legacy_ID & ")");
      arrayAppend(variables.dArrayTmp, variables.qRows.referenceNum);
    </cfscript>

    <!--- form.planningGroups is a comma-delimited list of selected bill back, operator and planning group 
          each entry in the list consists of 3 elements separated by form.keyDelimiter (passed in value):
          
            1. billback id
            2. operator id
            3. pg category id         
            
          notes: no hard-coded value is used here, everything is passed from parent file
                 to debug you would need to separate the content with newlines and then remove newlines after 
                 you are done with debugging for better performance
    --->
    <cfsavecontent variable="variables.cellContent"><cfif ( variables.qRows.PG_Operator_Category_Name neq "" or form.inEditMode eq 0 )> &nbsp; #variables.qRows.PG_Operator_Category_Name#<cfelse><select name='#variables.qRows.Billback_ID##form.keyDelimiter##variables.qRows.Operator_ID#' class='#form.selectClass#'><option value='0'></option><cfloop query='variables.qPlanningGroups'><option value='#variables.qPlanningGroups.PG_Operator_Category_ID#' <cfif listFindNoCase(form.planningGroups, '#variables.qRows.Billback_ID##form.keyDelimiter##variables.qRows.Operator_ID##form.keyDelimiter##variables.qPlanningGroups.PG_Operator_Category_ID#')>selected=selected</cfif>>#variables.qPlanningGroups.Pg_Operator_Category_Name#<cfif len(variables.qPlanningGroups.PG_Operator_Category_Code)>(#variables.qPlanningGroups.PG_Operator_Category_Code#)</cfif></option></cfloop></select></cfif></cfsavecontent>

    <cfscript>
      arrayAppend(variables.dArrayTmp, variables.cellContent);
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








