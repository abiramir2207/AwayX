<cfsetting showDebugOutput="no">
<cfprocessingdirective suppresswhitespace="yes">
<cfsilent>
  <cfparam name="url.iDisplayStart"   default="0">
  <cfparam name="url.iDisplayLength"  default="2000">
  <cfparam name="url.sEcho"           default="10">

  <cfscript>
    tmp   = {};
    reply = {};
    
    tmp.page_size   = val(url.iDisplayLength);
    if ( tmp.page_size eq -1) {
	    tmp.start_row   = 1;
	    tmp.end_row     = -1;
    }
    else {
	    tmp.start_row   = url.iDisplayStart + 1;
	    tmp.end_row     = url.iDisplayStart + tmp.page_size;
	  }
		tmp.words = reMatch("[[:word:]]+", url.sSearch);   // parse filtering string into an array of words	  
  </cfscript>

	<cfoutput>
  <cfquery name="tmp.qOperators" datasource="#application.datasource#">
					SELECT 
		 				<cfif tmp.end_row neq -1>	TOP #tmp.end_row# </cfif>
					       a.Prof_Model_Operator_Classifications_Id
					      ,c.Classification_Name
					      ,b.Operator_Name
					      ,b.Legacy_ID
					      ,b.Operator_Location_Type
					      ,b.Display_Code as Active_Code
					  FROM Prof_Model_Operator_Classifications a 
					       INNER JOIN Bsa_Operator b ON a.bsa_Operator_Id = b.bsa_Operator_Id 
					                                    AND b.Deleted = 0
					       LEFT JOIN Prof_Model_Classification c ON a.Prof_Model_Classification_Id = c.Prof_Model_Classification_Id                             
					                                    AND c.Deleted = 0
					 WHERE a.Deleted = 0
  						<cfif StructKeyExists(url, "sSearch") and len(trim(url.sSearch))>
               AND ( b.Operator_Name LIKE '%#arrayToList(tmp.words, "%")#%' OR b.Legacy_ID LIKE '%#arrayToList(tmp.words, "%")#%' )
            </cfif>
  					 <!--- filtering by Location Type --->
  					 <cfif StructKeyExists(url, "sSearch_3") and len(trim(url.sSearch_3))>
               AND b.Operator_Location_Type = '#url.sSearch_3#'
            </cfif>            
  					 <!--- filtering by Active Code --->
  					 <cfif StructKeyExists(url, "sSearch_4") and len(trim(url.sSearch_4))>
               AND b.Display_Code = '#url.sSearch_4#'
            </cfif>            
					 
					 <cfswitch expression="#url.iSortCol_0#">
			       	<cfcase value='1'> ORDER BY b.Operator_Name #url.sSortDir_0# </cfcase>
			       	<cfcase value='2'> ORDER BY b.Legacy_ID  #url.sSortDir_0#</cfcase>
			       	<cfcase value='5'> ORDER BY c.Classification_Name  #url.sSortDir_0#</cfcase>
			       </cfswitch>
	</cfquery>
  </cfoutput>
  
  <!---get total number of records BEFORE filtering--->
  <cfquery name="totalBeforeFilter" datasource="#application.datasource#">
      SELECT COUNT(1) AS rownbr
  		  FROM Prof_Model_Operator_Classifications a 
					       INNER JOIN Bsa_Operator b ON a.bsa_Operator_Id = b.bsa_Operator_Id 
					                                    AND b.Deleted = 0
			  WHERE a.Deleted = 0
  </cfquery>

  <cfset reply.iTotalRecords        = totalBeforeFilter.rownbr>
  <cfset reply.iTotalDisplayRecords = totalBeforeFilter.rownbr>

	<cfif (StructKeyExists(url, "sSearch") and len(trim(url.sSearch)))
	   OR (StructKeyExists(url, "sSearch_3") and len(trim(url.sSearch_3)))
	   OR (StructKeyExists(url, "sSearch_4") and len(trim(url.sSearch_4)))>
    <cfquery name="totalAfterFilter" datasource="#application.datasource#">
      SELECT COUNT(1) as rownbr
					  FROM Prof_Model_Operator_Classifications a 
					       INNER JOIN Bsa_Operator b ON a.bsa_Operator_Id = b.bsa_Operator_Id 
					                                    AND b.Deleted = 0
			  WHERE a.Deleted = 0
  						<cfif StructKeyExists(url, "sSearch") and len(trim(url.sSearch))>
               AND ( b.Operator_Name LIKE '%#arrayToList(tmp.words, "%")#%' OR b.Legacy_ID LIKE '%#arrayToList(tmp.words, "%")#%' )
            </cfif>
  					 <!--- filtering by Location Type --->
  					 <cfif StructKeyExists(url, "sSearch_3") and len(trim(url.sSearch_3))>
               AND b.Operator_Location_Type = '#url.sSearch_3#'
            </cfif>            
  					 <!--- filtering by Active Code --->
  					 <cfif StructKeyExists(url, "sSearch_4") and len(trim(url.sSearch_4))>
               AND b.Display_Code = '#url.sSearch_4#'
            </cfif>            
    </cfquery>
    <!---get total no. of records AFTER filtering--->
    <cfset reply.iTotalDisplayRecords = totalAfterFilter.rownbr>
  </cfif>

  <!--- Generate JSON from Query --->
  <cfset reply.aaData = [] >
  <cfif tmp.end_row eq -1>
  	<cfset tmp.start_row = 1>
  	<cfset tmp.end_row   = tmp.qOperators.recordCount>
  <cfelse>
  	<cfset tmp.end_row   = min(tmp.end_row, tmp.qOperators.recordCount)>
  </cfif>
  
  <cfoutput>
  <cfloop query="tmp.qOperators" startRow="#tmp.start_row#" endRow="#tmp.end_row#">
    <cfscript>
    		dArrayTmp = [];
    		// tmp.checked = tmp.qOperators.Is_Excluded ? 'checked=checked' : '';
       arrayAppend(dArrayTmp, "<input type='checkbox' name='i#tmp.qOperators.Prof_Model_Operator_Classifications_Id#' class='cbox'>");
       arrayAppend(dArrayTmp, tmp.qOperators.Operator_Name);
       arrayAppend(dArrayTmp, tmp.qOperators.Legacy_ID);
       arrayAppend(dArrayTmp, tmp.qOperators.Operator_Location_Type);
       arrayAppend(dArrayTmp, tmp.qOperators.Active_Code);
       arrayAppend(dArrayTmp, tmp.qOperators.Classification_Name);
       arrayAppend(reply.aaData, dArrayTmp);
    </cfscript>
  </cfloop>
	</cfoutput>
	
  <cfset reply.sEcho  = javacast('int', url.sEcho)>
  <cfset tmp.sOut = SerializeJSON( reply )>

  <!--- Since SerializeJSON capitalize the content which is case-sensitive let's reset it the correct way --->
  <cfset tmp.sOut = Replace (tmp.sOut, 'SECHO', 'sEcho', 'one')>
  <cfset tmp.sOut = Replace (tmp.sOut, 'ITOTALRECORDS', 'iTotalRecords', 'one')>
  <cfset tmp.sOut = Replace (tmp.sOut, 'ITOTALDISPLAYRECORDS', 'iTotalDisplayRecords', 'one')>
  <cfset tmp.sOut = Replace (tmp.sOut, 'AADATA', 'aaData', 'one')>
</cfsilent>

<!---send JSON data back to client--->
<cfoutput>#tmp.sOut#</cfoutput>
</cfprocessingdirective>















