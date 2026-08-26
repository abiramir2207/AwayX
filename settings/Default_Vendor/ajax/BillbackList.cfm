<!-----------------------------------------------------------------------------

FILE NAME:		BillbackList.cfm
DESCRIPTION:	Displays the list of BB that relates to the given Shr_Ship_TO
CREATED BY:		???
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	07-Jul-2015	 

------------------------------------------------------------------------------> 
 <cfsetting showDebugOutput="no">
<cfprocessingdirective suppresswhitespace="yes">
<cfsilent>
	<cfparam name="URL.src" default="" />
	<cfparam name="URL.shrShipTo" default="" />
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
	<cfif URL.src EQ "Dist">
 		<cfquery name="variables.qRows" datasource="#application.datasource#">
			SELECT BB.BB_Code,BB.BB_Title,BB.Billback_ID, CM.Ship_To,CM.Default_Vendor_ID,CM.Default_Billback_Closing_Method_ID
			FROM Billback BB
			INNER JOIN	Billback_Distributor bd  
			ON			bd.Billback_ID = BB.Billback_ID  
			AND			bd.Deleted = 0  
			INNER JOIN	BSA_Foodservice_Customers cm  
			ON			cm.BSA_Foodservice_Customers_ID = bd.Distributor_ID   
			WHERE BB.Deleted = 0
			AND BB.Billback_Payee_Type_ID = 1  
			AND CM.Ship_To = '#URL.shrShipTo#'
			<cfswitch expression="#url.iSortCol_0#">
				<cfcase value='0'> ORDER BY BB.BB_Code #url.sSortDir_0# </cfcase>
     			<cfcase value='1'> ORDER BY BB.BB_Title #url.sSortDir_0# </cfcase>
			</cfswitch>
		</cfquery>
	<cfelseif URL.src EQ "Opr">
		<cfquery name="variables.qRows" datasource="#application.datasource#">
			SELECT BB.BB_Code,BB.BB_Title,BB.Billback_ID , BSAOP.Legacy_ID,BSAOP.Default_Vendor_ID,BSAOP.Default_Billback_Closing_Method_ID
			FROM Billback BB
			INNER JOIN	Billback_Operator BO
			ON			BO.Billback_ID = BB.Billback_ID  
			AND			BO.Deleted = 0  
			INNER JOIN	BSA_Operator BSAOP  
			ON			BSAOP.BSA_Operator_ID = BO.Operator_ID  
			WHERE BB.Deleted = 0
			AND BB.Billback_Payee_Type_ID = 2
			AND BSAOP.Legacy_ID = '#URL.shrShipTo#'
			<cfswitch expression="#url.iSortCol_0#">
				<cfcase value='0'> ORDER BY BB.BB_Code #url.sSortDir_0# </cfcase>
     			<cfcase value='1'> ORDER BY BB.BB_Title #url.sSortDir_0# </cfcase>
			</cfswitch>	

		</cfquery>
	</cfif>
</cfoutput> 

  <cfif len(url.sSearch) eq 0>
    <!--- no filtering so grap the count from existing query --->
    <cfset variables.reply.iTotalRecords = variables.qRows.recordCount>
  <cfelse>
	  <cfif URL.src EQ "Dist">
		  	<cfquery name="variables.totalBeforeFilter" datasource="#application.datasource#">
		          SELECT COUNT(1) AS rownbr
		            FROM Billback BB
					INNER JOIN	Billback_Distributor bd  
					ON			bd.Billback_ID = BB.Billback_ID  
					AND			bd.Deleted = 0  
					INNER JOIN	BSA_Foodservice_Customers cm  
					ON			cm.BSA_Foodservice_Customers_ID = bd.Distributor_ID   
					WHERE BB.Deleted = 0
					AND BB.Billback_Payee_Type_ID = 1  
					AND CM.Ship_To = '#URL.shrShipTo#'
		    </cfquery>
		    <cfset variables.reply.iTotalRecords = variables.totalBeforeFilter.rownbr>
		<cfelseif URL.src EQ "Opr">
			<cfquery name="variables.totalBeforeFilter" datasource="#application.datasource#">
				SELECT COUNT(1) AS rownbr
				FROM Billback BB
				INNER JOIN	Billback_Operator BO
				ON			BO.Billback_ID = BB.Billback_ID  
				AND			BO.Deleted = 0  
				INNER JOIN	BSA_Operator BSAOP  
				ON			BSAOP.BSA_Operator_ID = BO.Operator_ID  
				WHERE BB.Deleted = 0
				AND BB.Billback_Payee_Type_ID = 2
				AND BSAOP.Legacy_ID = '#URL.shrShipTo#'
			</cfquery>
			<cfset variables.reply.iTotalRecords = variables.totalBeforeFilter.rownbr>
		</cfif>
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
		    arrayAppend(dArrayTmp, variables.qRows.BB_Code);
		    arrayAppend(dArrayTmp, variables.qRows.BB_Title);
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

