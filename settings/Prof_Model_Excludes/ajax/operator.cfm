<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Prof_Model_Excludes\ajax\operator.cfm
      Date:     2013 Mar
      Author:   Chris Nguyen
      Purpose:  aJax processing for profitability model operator excludes

			Remarks:  Columns information ( position starts with zero due to javaScript/aJax ) 
			             0 = Is Excluded?                  
			             1 = Operator Name
			             2 = Operator ID
			             3 = Location Type
			             4 = Active Code
			             
			          IMPORTANT: When column order is changed remember to search & change the related logic for:
			          							A.  url.sSearch_[0|1|2|3|..]
			          							B.  url.iSortCol_[0|1|2|3|..]
----------------------------------------------------------------------------------------------------------------------->
<cfsetting showDebugOutput="no">
<cfprocessingdirective suppresswhitespace="yes">
<cfsilent>
  <cfparam name="url.iDisplayStart"   default="0">
  <cfparam name="url.iDisplayLength"  default="200">
  <cfparam name="url.sEcho"           default="10">

  <cfscript>
    tmp   = {};
    reply = {};
    tmp.seeAll = -1;
    
    tmp.page_size   = val(url.iDisplayLength);
    if ( tmp.page_size eq tmp.seeAll) {    // users want to see all 
      tmp.start_row   = 1;
      tmp.end_row     = tmp.seeAll;
    }
    else {
      tmp.start_row   = url.iDisplayStart + 1;
      tmp.end_row     = url.iDisplayStart + tmp.page_size;
    }
    
		url.sSearch   = trim(url.sSearch);
		url.sSearch_3 = trim(url.sSearch_3);
    url.sSearch_4 = trim(url.sSearch_4);

    tmp.words = reMatch("[[:word:]]+", url.sSearch);   // parse filtering string into an array of words
  </cfscript>

  <cfoutput>
  <cfquery name="tmp.qOperators" datasource="#application.datasource#">
    SELECT 
          <cfif tmp.end_row neq tmp.seeAll> TOP #tmp.end_row# </cfif>
           a.Prof_Model_Operator_Excludes_Id
          ,a.Is_Excluded
          ,b.Operator_Name
          ,b.Legacy_ID
          ,b.Operator_Location_Type
          ,b.Display_Code as Active_Code
      FROM Prof_Model_Operator_Excludes a 
           INNER JOIN Bsa_Operator b ON a.bsa_Operator_Id = b.bsa_Operator_Id 
                                        AND b.Deleted = 0
     WHERE a.Deleted = 0
	          <!--- quick search at the top left --->
	          <cfif StructKeyExists(url, "sSearch") and len(url.sSearch)>
							AND ( b.Operator_Name LIKE  '%#arrayToList(tmp.words, "%")#%' OR b.Legacy_ID LIKE  '%#arrayToList(tmp.words, "%")#%' )
	          </cfif>
	          
           	<!--- column filtering by Location Type --->
           	<cfif StructKeyExists(url, "sSearch_3") and len(url.sSearch_3)>
							AND b.Operator_Location_Type = '#url.sSearch_3#'
						</cfif>      
						      
           	<!--- column filtering by Active Code --->
           	<cfif StructKeyExists(url, "sSearch_4") and len(url.sSearch_4)>
							AND b.Display_Code = '#url.sSearch_4#'
						</cfif>            
         
	         	<cfswitch expression="#url.iSortCol_0#">
	            <cfcase value='0'> ORDER BY a.Is_Excluded   #url.sSortDir_0# </cfcase>
	            <cfcase value='1'> ORDER BY b.Operator_Name #url.sSortDir_0# </cfcase>
	            <cfcase value='2'> ORDER BY b.Legacy_ID     #url.sSortDir_0# </cfcase>
	           </cfswitch>
  </cfquery>
  </cfoutput>
  
  <!---get total number of records BEFORE filtering--->
  <cfquery name="totalBeforeFilter" datasource="#application.datasource#">
      SELECT COUNT(1) AS rownbr
        FROM Prof_Model_Operator_Excludes a 
                 INNER JOIN Bsa_Operator b ON a.bsa_Operator_Id = b.bsa_Operator_Id 
                                              AND b.Deleted = 0
        WHERE a.Deleted = 0
  </cfquery>

  <cfset reply.iTotalRecords        = totalBeforeFilter.rownbr>
  <cfset reply.iTotalDisplayRecords = totalBeforeFilter.rownbr>

  <cfif ( StructKeyExists(url, "sSearch")   and len(url.sSearch)   )
     OR ( StructKeyExists(url, "sSearch_3") and len(url.sSearch_3) )
     OR ( StructKeyExists(url, "sSearch_4") and len(url.sSearch_4) )>
    <cfquery name="totalAfterFilter" datasource="#application.datasource#">
      SELECT COUNT(1) as rownbr
				FROM Prof_Model_Operator_Excludes a 
             INNER JOIN Bsa_Operator b ON a.bsa_Operator_Id = b.bsa_Operator_Id 
                                              AND b.Deleted = 0
       WHERE a.Deleted = 0
							<cfif StructKeyExists(url, "sSearch") and len(url.sSearch)>
								AND ( b.Operator_Name LIKE  '%#arrayToList(tmp.words, "%")#%' OR b.Legacy_ID LIKE  '%#arrayToList(tmp.words, "%")#%' )
							</cfif>
							<!--- filtering by Location Type --->
             	<cfif StructKeyExists(url, "sSearch_3") and len(url.sSearch_3)>
               	AND b.Operator_Location_Type = '#url.sSearch_3#'
            	</cfif>            
             	<!--- filtering by Active Code --->
             	<cfif StructKeyExists(url, "sSearch_4") and len(url.sSearch_4)>
               	AND b.Display_Code = '#url.sSearch_4#'
            	</cfif>            
    </cfquery>
    <!---get total no. of records AFTER filtering--->
    <cfset reply.iTotalDisplayRecords = totalAfterFilter.rownbr>
  </cfif>

  <!--- Generate JSON from Query --->
  <cfscript>
  	reply.aaData = [];
  	if ( tmp.end_row eq tmp.seeAll ) {
    	tmp.start_row = 1;
    	tmp.end_row   = tmp.qOperators.recordCount;
   	}
  	else {
    	 tmp.end_row   = min(tmp.end_row, tmp.qOperators.recordCount);
    }
  </cfscript>
  
  <cfoutput>
  <cfloop query="tmp.qOperators" startRow="#tmp.start_row#" endRow="#tmp.end_row#">
    <cfscript>
       dArrayTmp = [];
       tmp.checked = tmp.qOperators.Is_Excluded ? 'checked=checked' : '';
       arrayAppend(dArrayTmp, "<input type='checkbox' name='i#tmp.qOperators.Prof_Model_Operator_Excludes_Id#' changed=0 #tmp.checked# class='exclude'>");
       arrayAppend(dArrayTmp, tmp.qOperators.Operator_Name);
       arrayAppend(dArrayTmp, tmp.qOperators.Legacy_ID);
       arrayAppend(dArrayTmp, tmp.qOperators.Operator_Location_Type);
       arrayAppend(dArrayTmp, tmp.qOperators.Active_Code);
       arrayAppend(reply.aaData, dArrayTmp);
    </cfscript>
  </cfloop>
  </cfoutput>
  
  <cfscript>
	  reply.sEcho  = javacast('int', url.sEcho);
	  tmp.sOut     = serializeJSON( reply );
	
	  // Since SerializeJSON capitalize the content which is case-sensitive let's reset it the correct way
	  tmp.sOut = replace (tmp.sOut, 'SECHO', 'sEcho', 'one');
	  tmp.sOut = replace (tmp.sOut, 'ITOTALRECORDS', 'iTotalRecords', 'one');
	  tmp.sOut = replace (tmp.sOut, 'ITOTALDISPLAYRECORDS', 'iTotalDisplayRecords', 'one');
	  tmp.sOut = replace (tmp.sOut, 'AADATA', 'aaData', 'one');
	</cfscript>
</cfsilent>

<!---send JSON data back to client--->
<cfoutput>#tmp.sOut#</cfoutput>
</cfprocessingdirective>















