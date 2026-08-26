<!---------------------------------------------------------------------------------------------------------------------
      Template: \GL_Code\Vendor_Management\ajax\vendorBatching.cfm
      Date:     2013 Aug
      Author:   Chris Nguyen
      Purpose:  aJax processing for vendor batching

			Remarks:  Columns information ( position starts with zero due to javaScript/aJax ) 
			             0 = ID
			             1 = Vendor Name
			             2 = Vendor Address
			             3 = City, State Zip
			             4 = Batched?
			             
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
  	
  	// parse search string into an array of words
  	if ( StructKeyExists(url, "sSearch") and len(url.sSearch) ) {
  		tmp.arrayOfWords = reMatch( "[[:word:]]+", url.sSearch );
  	}
  	else {
  		tmp.arrayOfWords = [];
  	}  	
  	
  	// concatenate array of words into a long string delimited by % ( for SQL LIKE condition )
 		tmp.listOfWords = arrayToList(tmp.arrayOfWords, "%");
  </cfscript>

  <cfoutput>
  <cfquery name="tmp.qVendors" datasource="#application.datasource#">
    SELECT 
          <cfif tmp.end_row neq tmp.seeAll> TOP #tmp.end_row# </cfif>
           Vendor_ID
          ,Vendor_Name
          ,Address_1
          ,City
          ,State
          ,Zipcode
          ,Is_Batched
          ,vendor_master_id
      FROM VENDOR_MASTER
     WHERE Deleted = 0
     				 <cfif url.batched eq "yes">
     				 		AND Is_Batched = 1
            <cfelseif url.batched eq "no">
              AND Is_Batched = 0
            </cfif>
	          <!--- quick search at the top left --->
	          <cfif len( tmp.listOfWords )>
								AND (    Vendor_ID LIKE '%#tmp.listOfWords#%' 
								      OR Vendor_Name LIKE '%#tmp.listOfWords#%' 
								      OR Address_1 LIKE '%#tmp.listOfWords#%' 
								      OR City LIKE '%#tmp.listOfWords#%' 
								      OR State LIKE '%#tmp.listOfWords#%' 
								      OR Zipcode LIKE '%#tmp.listOfWords#%' 
								    )
	          </cfif>
	              
	         	<cfswitch expression="#url.iSortCol_0#">
	            <cfcase value='0'> ORDER BY  Vendor_ID   #url.sSortDir_0# </cfcase>
	            <cfcase value='1'> ORDER BY  Vendor_Name #url.sSortDir_0# </cfcase>
	            <cfcase value='2'> ORDER BY  Address_1   #url.sSortDir_0# </cfcase>
	            <cfcase value='3'> ORDER BY  City        #url.sSortDir_0# </cfcase>
	           </cfswitch>
  </cfquery>
  </cfoutput>
  
  <!---get total number of records BEFORE filtering--->
  <cfquery name="totalBeforeFilter" datasource="#application.datasource#">
      SELECT COUNT(1) AS rownbr
        FROM VENDOR_MASTER
        WHERE Deleted = 0
     				 <cfif url.batched eq "yes">
     				 		AND Is_Batched = 1
            <cfelseif url.batched eq "no">
              AND Is_Batched = 0
            </cfif>
  </cfquery>

  <cfset reply.iTotalRecords        = totalBeforeFilter.rownbr>
  <cfset reply.iTotalDisplayRecords = totalBeforeFilter.rownbr>

  <cfif ( StructKeyExists(url, "sSearch")   and len(trim(url.sSearch)) )>
    <cfquery name="totalAfterFilter" datasource="#application.datasource#">
      SELECT COUNT(1) as rownbr
	      FROM VENDOR_MASTER
	     WHERE Deleted = 0
     				 <cfif url.batched eq "yes">
     				 		AND Is_Batched = 1
            <cfelseif url.batched eq "no">
              AND Is_Batched = 0
            </cfif>
		          <!--- quick search at the top left --->
	          	 <cfif len( tmp.listOfWords )>
								AND (    Vendor_ID LIKE '%#tmp.listOfWords#%' 
								      OR Vendor_Name LIKE '%#tmp.listOfWords#%' 
								      OR Address_1 LIKE '%#tmp.listOfWords#%' 
								      OR City LIKE '%#tmp.listOfWords#%' 
								      OR State LIKE '%#tmp.listOfWords#%' 
								      OR Zipcode LIKE '%#tmp.listOfWords#%' 
								    )
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
    	tmp.end_row   = tmp.qVendors.recordCount;
   	}
  	else {
    	 tmp.end_row   = min(tmp.end_row, tmp.qVendors.recordCount);
    }
  </cfscript>
  
  <cfoutput>
  <cfloop query="tmp.qVendors" startRow="#tmp.start_row#" endRow="#tmp.end_row#">
    <cfscript>
       dArrayTmp = [];
       tmp.checked = tmp.qVendors.is_batched ? 'checked' : '';
       arrayAppend(dArrayTmp, tmp.qVendors.Vendor_ID);
       arrayAppend(dArrayTmp, tmp.qVendors.Vendor_Name);
       arrayAppend(dArrayTmp, tmp.qVendors.Address_1);
       arrayAppend(dArrayTmp, tmp.qVendors.City & ' ' & tmp.qVendors.State & ' ' & tmp.qVendors.Zipcode);
       arrayAppend(dArrayTmp, "<input type='checkbox' updated=0 class='batched' name='batched_#tmp.qVendors.vendor_master_id#' #tmp.checked#>");
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