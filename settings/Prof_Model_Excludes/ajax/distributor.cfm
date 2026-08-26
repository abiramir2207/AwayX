<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Prof_Model_Excludes\ajax\distributor.cfm
      Date:     2013 Mar
      Author:   Chris Nguyen
      Purpose:  aJax processing for profitability model distributor excludes

      Remarks:  Columns information ( position starts with zero due to javaScript/aJax ) 
                   0 = Is Excluded?
                   1 = Name
                   2 = Ship To
                   3 = Family Name
                   4 = Buying Group Name
                   5 = Active Code
                   
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
    url.sSearch_5 = trim(url.sSearch_5);
    
    tmp.words = reMatch("[[:word:]]+", url.sSearch);   // parse filtering string into an array of words
  </cfscript>

  <cfoutput>
  <cfquery name="tmp.qDistributors" datasource="#application.datasource#">
    SELECT 
          <cfif tmp.end_row neq tmp.seeAll> TOP #tmp.end_row# </cfif>
           a.Prof_Model_Distributor_Excludes_Id
          ,a.Is_Excluded
          ,b.Ship_To
          ,b.Name
          ,b.Family_Name
          ,b.Buying_Group_Name
          ,b.Active_Code
     FROM Prof_Model_Distributor_Excludes a 
          INNER JOIN Bsa_Foodservice_Customers b ON a.bsa_FoodService_Customers_Id = b.bsa_FoodService_Customers_Id 
                                                        AND b.Deleted = 0
            <!--- quick search at the top left --->
            <cfif StructKeyExists(url, "sSearch") and len(url.sSearch)>
              AND ( b.Name LIKE  '%#arrayToList(tmp.words, "%")#%' OR b.Ship_To LIKE  '%#arrayToList(tmp.words, "%")#%' )
            </cfif>
            
            <!--- column filtering by Family Name --->
            <cfif StructKeyExists(url, "sSearch_3") and len(url.sSearch_3)>
              AND b.Family_Name = '#url.sSearch_3#'
            </cfif>      
                  
            <!--- column filtering by Buying Group Name --->
            <cfif StructKeyExists(url, "sSearch_4") and len(url.sSearch_4)>
              AND b.Buying_Group_Name = '#url.sSearch_4#'
            </cfif>      
                  
            <!--- column filtering by Active Code --->
            <cfif StructKeyExists(url, "sSearch_5") and len(url.sSearch_5)>
              AND b.Active_Code = '#url.sSearch_5#'
            </cfif>            
         
            <cfswitch expression="#url.iSortCol_0#">
              <cfcase value='0'> ORDER BY a.Is_Excluded #url.sSortDir_0#, b.Name </cfcase>
              <cfcase value='1'> ORDER BY b.Name          #url.sSortDir_0# </cfcase>
              <cfcase value='2'> ORDER BY b.Ship_To       #url.sSortDir_0# </cfcase>
             </cfswitch>
  </cfquery>
  </cfoutput>
  
  <!---get total number of records BEFORE filtering--->
  <cfquery name="totalBeforeFilter" datasource="#application.datasource#">
      SELECT COUNT(1) AS rownbr
        FROM Prof_Model_Distributor_Excludes a 
             INNER JOIN Bsa_Foodservice_Customers b ON a.bsa_FoodService_Customers_Id = b.bsa_FoodService_Customers_Id 
                                                          AND b.Deleted = 0
        WHERE a.Deleted = 0
  </cfquery>

  <cfset reply.iTotalRecords        = totalBeforeFilter.rownbr>
  <cfset reply.iTotalDisplayRecords = totalBeforeFilter.rownbr>

  <cfif ( StructKeyExists(url, "sSearch")   and len(trim(url.sSearch))   )
     OR ( StructKeyExists(url, "sSearch_3") and len(trim(url.sSearch_3)) )
     OR ( StructKeyExists(url, "sSearch_4") and len(trim(url.sSearch_4)) )>
    <cfquery name="totalAfterFilter" datasource="#application.datasource#">
      SELECT COUNT(1) as rownbr
        FROM Prof_Model_Distributor_Excludes a 
             INNER JOIN Bsa_Foodservice_Customers b ON a.bsa_FoodService_Customers_Id = b.bsa_FoodService_Customers_Id 
                                                          AND b.Deleted = 0
       WHERE a.Deleted = 0
	            <!--- quick search at the top left --->
	            <cfif StructKeyExists(url, "sSearch") and len(url.sSearch)>
	              AND ( b.Name LIKE '%#arrayToList(tmp.words, "%")#%' OR b.Ship_To LIKE '%#arrayToList(tmp.words, "%")#%' )
	            </cfif>

	            <!--- column filtering by Family Name --->
	            <cfif StructKeyExists(url, "sSearch_3") and len(url.sSearch_3)>
	              AND b.Family_Name = '#url.sSearch_3#'
	            </cfif>      

	            <!--- column filtering by Buying Group Name --->
	            <cfif StructKeyExists(url, "sSearch_4") and len(url.sSearch_4)>
	              AND b.Buying_Group_Name = '#url.sSearch_4#'
	            </cfif>      
	                  
	            <!--- column filtering by Active Code --->
	            <cfif StructKeyExists(url, "sSearch_5") and len(url.sSearch_5)>
	              AND b.Active_Code = '#url.sSearch_5#'
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
      tmp.end_row   = tmp.qDistributors.recordCount;
    }
    else {
       tmp.end_row   = min(tmp.end_row, tmp.qDistributors.recordCount);
    }
  </cfscript>
  
  <cfoutput>
  <cfloop query="tmp.qDistributors" startRow="#tmp.start_row#" endRow="#tmp.end_row#">
    <cfscript>
       dArrayTmp = [];
       tmp.checked = tmp.qDistributors.Is_Excluded ? 'checked=checked' : '';
       arrayAppend(dArrayTmp, "<input type='checkbox' name='i#tmp.qDistributors.Prof_Model_Distributor_Excludes_Id#' changed=0 #tmp.checked# class='exclude'>");
       arrayAppend(dArrayTmp, tmp.qDistributors.Name);
       arrayAppend(dArrayTmp, tmp.qDistributors.Ship_To);
       arrayAppend(dArrayTmp, tmp.qDistributors.Family_Name);
       arrayAppend(dArrayTmp, tmp.qDistributors.Buying_Group_Name);
       arrayAppend(dArrayTmp, tmp.qDistributors.Active_Code);
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















