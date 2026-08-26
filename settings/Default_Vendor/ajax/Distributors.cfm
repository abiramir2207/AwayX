<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Default_Vendor\ajax\Distributors.cfm
      Date:     2014 Jan
      Author:   Chris Nguyen
      Purpose:  aJax processing for default vendor/bb closing method for distributors

      Remarks:  Columns information ( position starts with zero due to javaScript/aJax )
                   0 = Name
                   1 = ID
                   2 = Vendor ID
                   3 = Vendor Name
                   4 = BB Closing Meth
                   5 = Updated By
                   6 = Updated Date

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
  <cfparam name="url.iSortCol_0"      default="">

  <cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
  <cfif  businessSegManager.isEnabledForDistributor()>
	<cfset Distributor_Segment_On = 1>
	<cfquery datasource="#application.datasource#" name="getUsrBusSeg">
		SELECT UBS.Business_Segment_ID FROM User_Business_Segment UBS WHERE UBS.User_ID =  '#request.accessStructure.User_Id#' AND UBS.deleted = 0 
	</cfquery>
	<cfset BusSegBBs = ValueList(getUsrBusSeg.Business_Segment_ID) />
  <cfelse>
    <cfset Distributor_Segment_On = 0 />
	<cfset BusSegBBs = 0 />
  </cfif>

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
  <cfquery name="variables.bbClosingMethods" datasource="#application.datasource#">
    SELECT  vchBillback_Closing_Method_Desc,iBillback_Closing_Method_ID
     FROM BILLBACK_CLOSING_METHODS
     WHERE Deleted = 0
     AND iBillback_Closing_Method_ID IN (1, 2, 5, 8, 3, 12)
 	 ORDER BY vchBillback_Closing_Method_Desc
  </cfquery>
<!--- D45757 :: Claim rates report - primary source settings panel START --->
	<cfquery name="variables.bbClaimSourceXREF" datasource="#application.datasource#">
		SELECT		BCSX.Source_Type_Description + ' (' +BCSX.Source_Code+ ')' AS Source_Type_Description, BCSX.BB_Claim_Source_XREF_ID
		FROM			BB_Claim_Source_XREF BCSX
		WHERE		BCSX.Deleted = 0
		AND			BCSX.Active = 1
		ORDER BY 	BCSX.Source_Type_Description
	</cfquery>
<!--- D45757 :: Claim rates report - primary source settings panel END --->
  <cfquery name="variables.qRows" datasource="#application.datasource#">
				SELECT <cfif variables.end_row gt 0>
                TOP #variables.end_row#
               </cfif>
                 BSA_FOODSERVICE_CUSTOMERS.BSA_Foodservice_Customers_ID AS BSA_Foodservice_Customers_ID
								,Name
								,Shr_ship_to
								,Bsa_foodservice_customers.Default_Vendor_ID
								,Bsa_foodservice_customers.Deduct_TimeFrame
								,isnull(nullif(Bsa_foodservice_customers.Default_Billback_Closing_Method_ID,''),0) AS Default_Billback_Closing_Method_ID
								,Vendor_Master.Vendor_Name
								,Billback_Closing_Methods.vchBillback_Closing_Method_Desc
								,Bsa_foodservice_customers.Default_Billback_Closing_Method_ID
								,Manually_Updated_Date AS Updated_Date
								,u.Name_First + ' ' + u.Name_Last AS Updated_By
								,Bsa_foodservice_customers.Primary_BB_Claim_Source_XREF_ID
								,Bsa_foodservice_customers.Business_Segment_ID
				FROM Bsa_foodservice_customers
				LEFT JOIN Vendor_Master
				ON Bsa_foodservice_customers.Default_Vendor_ID = Vendor_Master.Vendor_ID
				AND Vendor_Master.Deleted = 0
				LEFT JOIN Billback_Closing_Methods
				ON Bsa_foodservice_customers.Default_Billback_Closing_Method_ID = Billback_Closing_Methods.iBillback_Closing_Method_ID
				LEFT JOIN _USERS u
				ON Bsa_foodservice_customers.Manually_Updated_By = u.User_ID
				WHERE Bsa_foodservice_customers.Deleted = 0
				AND Bsa_foodservice_customers.Ship_To <> 'group'
				<cfif len(url.sSearch)>
				AND (
							Name LIKE '%#variables.listOfWords#%'
							OR Shr_ship_to LIKE '%#variables.listOfWords#%'
							OR Default_Vendor_ID LIKE '%#variables.listOfWords#%'
							OR Vendor_Master.Vendor_Name LIKE '%#variables.listOfWords#%'
	                    )
             </cfif>
			 <cfif (Distributor_Segment_On EQ 1)>
			 	AND Bsa_foodservice_customers.Business_Segment_ID in (#BusSegBBs#)
			 </cfif>
   <cfswitch expression="#url.iSortCol_0#">
     <cfcase value='0'> ORDER BY Name #url.sSortDir_0# </cfcase>
     <cfcase value='1'> ORDER BY Shr_ship_to #url.sSortDir_0# </cfcase>
     <cfcase value='2'> ORDER BY Default_Vendor_ID #url.sSortDir_0# </cfcase>
     <cfcase value='3'> ORDER BY Vendor_Master.Vendor_Name #url.sSortDir_0# </cfcase>
     <cfcase value='4'> ORDER BY Billback_Closing_Methods.vchBillback_Closing_Method_Desc #url.sSortDir_0# </cfcase>
   </cfswitch>
  </cfquery>
  </cfoutput>

  <!---get total number of records BEFORE filtering--->
  <cfquery name="variables.totalBeforeFilter" datasource="#application.datasource#">
        SELECT COUNT(1) AS rownbr
          FROM Bsa_foodservice_customers
          LEFT JOIN Vendor_Master ON Bsa_foodservice_customers.Default_Vendor_ID = Vendor_Master.Vendor_ID
                 AND Vendor_Master.Deleted = 0
          LEFT JOIN Billback_Closing_Methods ON Bsa_foodservice_customers.Default_Billback_Closing_Method_ID = Billback_Closing_Methods.iBillback_Closing_Method_ID
          LEFT JOIN _USERS u ON Bsa_foodservice_customers.Manually_Updated_By = u.User_ID
         WHERE Bsa_foodservice_customers.Deleted = 0
           AND Bsa_foodservice_customers.Ship_To <> 'group'
		    <cfif (Distributor_Segment_On EQ 1)>
			 	AND Bsa_foodservice_customers.Business_Segment_ID in (#BusSegBBs#)
			 </cfif>
  </cfquery>
  <cfset variables.reply.iTotalRecords = variables.totalBeforeFilter.rownbr>
  <!---get total number of records AFTER filtering--->
  <cfquery name="variables.totalAfterFilter" datasource="#application.datasource#">
        SELECT COUNT(1) AS rownbr
          FROM Bsa_foodservice_customers
          LEFT JOIN Vendor_Master ON Bsa_foodservice_customers.Default_Vendor_ID = Vendor_Master.Vendor_ID
                 AND Vendor_Master.Deleted = 0
          LEFT JOIN Billback_Closing_Methods ON Bsa_foodservice_customers.Default_Billback_Closing_Method_ID = Billback_Closing_Methods.iBillback_Closing_Method_ID
          LEFT JOIN _USERS u ON Bsa_foodservice_customers.Manually_Updated_By = u.User_ID
         WHERE Bsa_foodservice_customers.Deleted = 0
           AND Bsa_foodservice_customers.Ship_To <> 'group'
        <cfif len(url.sSearch)>
        AND (
              Name LIKE '%#variables.listOfWords#%'
              OR Shr_ship_to LIKE '%#variables.listOfWords#%'
              OR Default_Vendor_ID LIKE '%#variables.listOfWords#%'
              OR Vendor_Master.Vendor_Name LIKE '%#variables.listOfWords#%'
                      )
             </cfif>
			 <cfif (Distributor_Segment_On EQ 1)>
			 	AND Bsa_foodservice_customers.Business_Segment_ID in (#BusSegBBs#)
			 </cfif>	 
  </cfquery>
  <cfset variables.reply.iTotalDisplayRecords = variables.totalAfterFilter.rownbr>

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
  	<!--- <cfset variables.reply.iTotalRecords = 0 /> --->
  	<cfquery name="variables.qBillBacks" datasource="#application.datasource#">
		          SELECT COUNT(1) AS rownbr
		            FROM Billback BB
					INNER JOIN	Billback_Distributor bd
					ON			bd.Billback_ID = BB.Billback_ID
					AND			bd.Deleted = 0
					INNER JOIN	BSA_Foodservice_Customers cm
					ON			cm.BSA_Foodservice_Customers_ID = bd.Distributor_ID
					WHERE BB.Deleted = 0
					AND BB.Billback_Payee_Type_ID = 1
					AND CM.Ship_To = '#variables.qRows.Shr_ship_to#'
			 <cfif (Distributor_Segment_On EQ 1)>
			 	AND cm.Business_Segment_ID in (#BusSegBBs#)
			 </cfif>					
		    </cfquery>
		    <cfset variables.BB_count = variables.qBillBacks.rownbr>

    <cfsavecontent variable="variables.Options"><cfloop query="variables.bbClosingMethods"> <option value="#variables.bbClosingMethods.iBillback_Closing_Method_ID#" #(variables.qRows.Default_billback_closing_method_id eq variables.bbClosingMethods.iBillback_Closing_Method_ID ? "selected=selected" : "")#>#variables.bbClosingMethods.vchBillback_Closing_Method_Desc#</option></cfloop></cfsavecontent>
 <!--- D45757 :: Claim rates report - primary source settings panel START --->
 	<cfsavecontent variable="variables.ClaimSourceOptions"><cfloop query="variables.bbClaimSourceXREF"> <option value="#variables.bbClaimSourceXREF.BB_Claim_Source_XREF_ID#" #(variables.qRows.Primary_BB_Claim_Source_XREF_ID eq variables.bbClaimSourceXREF.BB_Claim_Source_XREF_ID ? "selected=selected" : "")#>#variables.bbClaimSourceXREF.Source_Type_Description#</option></cfloop></cfsavecontent>
<!--- D45757 :: Claim rates report - primary source settings panel END --->
    <cfscript>
       dArrayTmp = [];
       arrayAppend(dArrayTmp, variables.qRows.Name);
       arrayAppend(dArrayTmp, variables.qRows.Shr_ship_to);
       arrayAppend(dArrayTmp, '<input type="text" name="vendor_id_#variables.qRows.currentRow#" class="vendor_id" id="vendor_id" value="#variables.qRows.Default_Vendor_ID#"><input type="hidden" name="row_#variables.qRows.currentRow#" class="row_id" changed="0" value="#variables.qRows.BSA_Foodservice_Customers_ID#"> <input type="hidden" name="busSegID_#variables.qRows.Business_Segment_ID#" class="Business_Segment_ID" id="Business_Segment_ID" value="#variables.qRows.Business_Segment_ID#"> <img class="find" src="/images/searchtool.gif" width="16" height="16"/>');
       arrayAppend(dArrayTmp, '<input name="vendor_name_#variables.qRows.currentRow#" class="vendor_name" value="#variables.qRows.Vendor_Name#" disabled>');
       arrayAppend(dArrayTmp, '<select name="closing_method_id_#variables.qRows.currentRow#" class="closing_method"> <option></option> #variables.Options#</select>');
       arrayAppend(dArrayTmp, '<select name="claim_source_xref_id_#variables.qRows.currentRow#" class="claim_source_method"> <option></option> #variables.ClaimSourceOptions#</select>');//D45757
	   arrayAppend(dArrayTmp, '<input type="text" name="deduct_TimeFrame_#variables.qRows.currentRow#" class="deduct_TimeFrame" id="deduct_TimeFrame"  value="#variables.qRows.Deduct_TimeFrame#">');
       arrayAppend(dArrayTmp, variables.qRows.Updated_By);
       arrayAppend(dArrayTmp, dateFormat(variables.qRows.Updated_Date, 'm/d/yyyy'));
	   arrayAppend(dArrayTmp, '<a href="##" onclick="viewBBList(''#variables.qRows.Shr_ship_to#'')" border="0" title="#variables.BB_count# BBs have this ID"><strong>(#variables.BB_count#)</strong></a>');
// <img src="/images/info.png" border="0">
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















