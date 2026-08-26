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
    SELECT  Contact_ID
				, First_Name + ' ' + Last_Name as Name
				, Title
				, Company_Code
				, Company_Name
				, Address
				, City
				, _States.State_code
				, Zip
				, Phone
				, Ext
				, Fax
				, Email
				, Notes
    FROM External_Contacts
    LEFT JOIN _states
    ON _states.State_ID = External_Contacts.State
    WHERE Deleted = 0
             <cfif len(url.sSearch)>
                AND (  First_Name LIKE '%#variables.listOfWords#%'
                        OR Last_Name LIKE '%#variables.listOfWords#%'
                        OR Company_Code LIKE '%#variables.listOfWords#%'
                        OR Company_Name LIKE '%#variables.listOfWords#%'
                        OR Email LIKE '%#variables.listOfWords#%'
						OR Address LIKE '%#variables.listOfWords#%'
						OR City LIKE '%#variables.listOfWords#%'
						OR _States.State_code LIKE '%#variables.listOfWords#%'
						OR Zip LIKE '%#variables.listOfWords#%'
						OR Title LIKE '%#variables.listOfWords#%'
                    )
             </cfif>
	<cfif (url.allowToEdit eq '1')>
       <cfswitch expression="#url.iSortCol_0#">
         <cfcase value='1'> ORDER BY First_Name #url.sSortDir_0# </cfcase>
         <cfcase value='2'> ORDER BY Company_Code #url.sSortDir_0# </cfcase>
		 <cfcase value='3'> ORDER BY Title #url.sSortDir_0# </cfcase>
         <cfcase value='4'> ORDER BY Address #url.sSortDir_0# </cfcase>
         <cfcase value='5'> ORDER BY Phone #url.sSortDir_0# </cfcase>
         <cfcase value='6'> ORDER BY Email #url.sSortDir_0# </cfcase>
      </cfswitch>
    <cfelse>
       <cfswitch expression="#url.iSortCol_0#">
         <cfcase value='0'> ORDER BY First_Name #url.sSortDir_0# </cfcase>
         <cfcase value='1'> ORDER BY Company_Code #url.sSortDir_0# </cfcase>
		 <cfcase value='2'> ORDER BY Title #url.sSortDir_0# </cfcase>
         <cfcase value='3'> ORDER BY Address #url.sSortDir_0# </cfcase>
         <cfcase value='4'> ORDER BY Phone #url.sSortDir_0# </cfcase>
         <cfcase value='5'> ORDER BY Email #url.sSortDir_0# </cfcase>
      </cfswitch>
    </cfif>
  </cfquery>
  </cfoutput>

  <!---get total number of records BEFORE filtering--->
  <cfif len(url.sSearch) eq 0>
    <!--- no filtering so grap the count from existing query --->
    <cfset variables.reply.iTotalRecords = variables.qRows.recordCount>
  <cfelse>
    <cfquery name="variables.totalBeforeFilter" datasource="#application.datasource#">
          SELECT COUNT(1) AS rownbr
            FROM External_Contacts
           WHERE Deleted = 0
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
	  	<cfif len(variables.qRows.phone) OR len(variables.qRows.ext)>
  	  		<cfset phoneno = '('&#Left(variables.qRows.phone, 3)#&')'&' '&#right(left(variables.qRows.phone,6),3)#&' - '&#right(variables.qRows.phone,4)#&' Ext: '&#variables.qRows.ext#>
		<cfelse>
			<cfset phoneno = ' '>
		</cfif>
	  	<cfif len(variables.qRows.fax)>
			<cfset faxno = '('&#Left(variables.qRows.fax, 3)#&')'&' '&#right(left(variables.qRows.fax,6),3)#&' - '&#right(variables.qRows.fax,4)#>
		<cfelse>
			<cfset faxno = ' '>
		</cfif>

		<cfset Strippedname = #replace(variables.qRows.Name,'''','',"ALL")#>
		<cfset Delete 	= '<img src="/images/trash.png" onclick="removed('& '''#variables.qRows.Contact_ID#''' &','&'''#Strippedname#'''&');">' />   <!--- 52788 --->

    <cfscript>
       dArrayTmp = [];
       if (url.allowToEdit eq '1') {
         arrayAppend(dArrayTmp, '<img class="edit" src="/images/user/001a.png" contactId="#variables.qRows.Contact_ID#">');
         arrayAppend(dArrayTmp, '<a href="" contactId="#variables.qRows.Contact_ID#">#trim(variables.qRows.Name)#</a>');
       }
       else {
         arrayAppend(dArrayTmp, trim(variables.qRows.Name));
       }
       arrayAppend(dArrayTmp, '#trim(variables.qRows.Company_Code)# <br> #trim(variables.qRows.Company_Name)#');
	    arrayAppend(dArrayTmp, trim(variables.qRows.Title));
	   if (trim(variables.qRows.address) neq '' AND trim(variables.qRows.City) NEQ ''  AND trim(variables.qRows.State_code) NEQ '' AND trim(variables.qRows.Zip) NEQ '')
	   {
	       arrayAppend(dArrayTmp, '#trim(variables.qRows.address)#<br>#trim(variables.qRows.City)#,#trim(variables.qRows.State_code)#,#trim(variables.qRows.Zip)#');
       }
	   else
	   {
			arrayAppend(dArrayTmp, '#trim(variables.qRows.address)#<br>#trim(variables.qRows.City)#&nbsp;#trim(variables.qRows.State_code)#&nbsp;#trim(variables.qRows.Zip)#');
	   }
	   arrayAppend(dArrayTmp, 'Phone:#trim(phoneno)#<br>Fax:#trim(faxno)#');
       arrayAppend(dArrayTmp, trim(variables.qRows.Email));
       arrayAppend(dArrayTmp, trim(variables.qRows.Notes));
       arrayAppend(dArrayTmp, '#delete#' );

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















