<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Prof_Model_Excludes\ajax\item.cfm
      Date:     2013 Mar
      Author:   Chris Nguyen
      Purpose:  aJax processing for profitability model product excludes

      Remarks:  Columns information ( position starts with zero due to javaScript/aJax ) 
                   0 = Is Excluded?
                   1 = Product
                   2 = Description
                   3 = Type Code
                   4 = Type Group
                   5 = Active Code
                   
                IMPORTANT: When column order is changed remember to search & change the related logic for:
                              A.  url.sSearch_[0|1|2|3|..]
                              B.  url.iSortCol_[0|1|2|3|..]
----------------------------------------------------------------------------------------------------------------------->
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
    url.sSearch   = trim(url.sSearch);
    url.sSearch_3 = trim(url.sSearch_3);
    url.sSearch_4 = trim(url.sSearch_4);
    url.sSearch_5 = trim(url.sSearch_5);

    tmp.words = reMatch("[[:word:]]+", url.sSearch);   // parse filtering string into an array of words   
  </cfscript>

	<cfoutput>
  <cfquery name="tmp.qItems" datasource="#application.datasource#">
		 SELECT
		 				<cfif tmp.end_row neq -1>	TOP #tmp.end_row# </cfif>
		         a.Prof_Model_Item_Excludes_Id
			       ,a.Is_Excluded
			       ,b.Item
			       ,b.Description
			       ,d.Type_Code_desc
			       ,g.Type_Group_desc
			       ,b.Active_Code
			  FROM PROF_MODEL_ITEM_EXCLUDES a
			       INNER JOIN BSA_FOODSERVICE_ITEMS_MASTER b ON a.bsa_FoodService_Items_Master_Id = b.bsa_FoodService_Items_Master_Id
			                                                    AND b.Deleted = 0
			                                                    AND b.Item IS NOT NULL
						 INNER JOIN TYPE_GROUP_DESC g ON g.Type_Group_desc_Id = b.Type_Group_desc_Id			                                                    
						 INNER JOIN TYPE_CODE_DESC d ON d.Type_Code_desc_Id = b.Type_Code_desc_Id
			 WHERE a.Deleted = 0
  						<cfif StructKeyExists(url, "sSearch") and len(url.sSearch)>
               AND (    b.Item LIKE  '%#arrayToList(tmp.words, "%")#%' 
                     OR b.Description LIKE  '%#arrayToList(tmp.words, "%")#%' )
            </cfif>
  					 <!--- filtering by Type Code --->
  					 <cfif StructKeyExists(url, "sSearch_3") and len(url.sSearch_3)>
               AND d.Type_Code_desc = '#url.sSearch_3#'
            </cfif>            
  					 <!--- filtering by Type Group --->
  					 <cfif StructKeyExists(url, "sSearch_4") and len(url.sSearch_4)>
               AND g.Type_Group_desc = '#url.sSearch_4#'
            </cfif>            
  					 <!--- filtering by Active Code --->
  					 <cfif StructKeyExists(url, "sSearch_5") and len(url.sSearch_5)>
               AND b.Active_Code = '#url.sSearch_5#'
            </cfif>            
			 ORDER BY 
			       <cfswitch expression="#url.iSortCol_0#">
			       	<cfcase value='0'> a.Is_Excluded #url.sSortDir_0#, b.Description </cfcase>
			       	<cfcase value='1'> b.Item  #url.sSortDir_0#</cfcase>
			       	<cfcase value='2'> b.Description  #url.sSortDir_0#</cfcase>
			       	<cfcase value='3'> d.Type_Code_desc  #url.sSortDir_0#, b.Description</cfcase>
			       	<cfcase value='4'> g.Type_Group_desc  #url.sSortDir_0#, b.Description</cfcase>
			       </cfswitch>
	</cfquery>
  </cfoutput>
  
  <!---get total number of records BEFORE filtering--->
  <cfquery name="totalBeforeFilter" datasource="#application.datasource#">
      SELECT COUNT(1) AS rownbr
			   FROM PROF_MODEL_ITEM_EXCLUDES a
			        INNER JOIN BSA_FOODSERVICE_ITEMS_MASTER b ON a.bsa_FoodService_Items_Master_Id = b.bsa_FoodService_Items_Master_Id
			                                                    AND b.Deleted = 0
			                                                    AND b.Item IS NOT NULL
						 INNER JOIN TYPE_GROUP_DESC g ON g.Type_Group_desc_Id = b.Type_Group_desc_Id			                                                    
						 INNER JOIN TYPE_CODE_DESC d ON d.Type_Code_desc_Id = b.Type_Code_desc_Id
			  WHERE a.Deleted = 0
  </cfquery>

  <cfset reply.iTotalRecords        = totalBeforeFilter.rownbr>
  <cfset reply.iTotalDisplayRecords = totalBeforeFilter.rownbr>

	<cfif (StructKeyExists(url, "sSearch") and len(url.sSearch))
	   OR (StructKeyExists(url, "sSearch_3") and len(url.sSearch_3))
	   OR (StructKeyExists(url, "sSearch_4") and len(url.sSearch_4))
	   OR (StructKeyExists(url, "sSearch_5") and len(url.sSearch_5))>
    <cfquery name="totalAfterFilter" datasource="#application.datasource#">
      SELECT COUNT(1) as rownbr
			  FROM PROF_MODEL_ITEM_EXCLUDES a
			       INNER JOIN BSA_FOODSERVICE_ITEMS_MASTER b ON a.bsa_FoodService_Items_Master_Id = b.bsa_FoodService_Items_Master_Id
			                                                    AND b.Deleted = 0
			                                                    AND b.Item IS NOT NULL
						 INNER JOIN TYPE_GROUP_DESC g ON g.Type_Group_desc_Id = b.Type_Group_desc_Id			                                                    
						 INNER JOIN TYPE_CODE_DESC d ON d.Type_Code_desc_Id = b.Type_Code_desc_Id
			  WHERE a.Deleted = 0
							<cfif StructKeyExists(url, "sSearch") and len(url.sSearch)>
             	AND ( b.Item LIKE '%#arrayToList(tmp.words, "%")#%' OR b.Description LIKE '%#arrayToList(tmp.words, "%")#%' )
            </cfif>
  					 <!--- filtering by Type Code --->
  					 <cfif StructKeyExists(url, "sSearch_3") and len(url.sSearch_3)>
               AND d.Type_Code_desc = '#url.sSearch_3#'
            </cfif>            
  					 <!--- filtering by Type Group --->
  					 <cfif StructKeyExists(url, "sSearch_4") and len(url.sSearch_4)>
               AND g.Type_Group_desc = '#url.sSearch_4#'
            </cfif>            
  					 <!--- filtering by Active Code --->
  					 <cfif StructKeyExists(url, "sSearch_5") and len(url.sSearch_5)>
               AND b.Active_Code = '#url.sSearch_5#'
            </cfif>            
    </cfquery>
    <!---get total no. of records AFTER filtering--->
    <cfset reply.iTotalDisplayRecords = totalAfterFilter.rownbr>
  </cfif>

  <!--- Generate JSON from Query --->
  <cfset reply.aaData = [] >
  <cfif tmp.end_row eq -1>
  	<cfset tmp.start_row = 1>
  	<cfset tmp.end_row   = tmp.qItems.recordCount>
  <cfelse>
  	<cfset tmp.end_row   = min(tmp.end_row, tmp.qItems.recordCount)>
  </cfif>
  
  <cfoutput>
  <cfloop query="tmp.qItems" startRow="#tmp.start_row#" endRow="#tmp.end_row#">
    <cfscript>
    		dArrayTmp = [];
    		tmp.checked = tmp.qItems.Is_Excluded ? 'checked=checked' : '';
       arrayAppend(dArrayTmp, "<input type='checkbox' name='i#tmp.qItems.Prof_Model_Item_Excludes_Id#' #tmp.checked# changed=0 class='exclude'>");
       arrayAppend(dArrayTmp, tmp.qItems.Item);
       arrayAppend(dArrayTmp, tmp.qItems.Description);
       arrayAppend(dArrayTmp, tmp.qItems.Type_Code_Desc);
       arrayAppend(dArrayTmp, tmp.qItems.Type_Group_Desc);
       arrayAppend(dArrayTmp, tmp.qItems.Active_Code);
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















