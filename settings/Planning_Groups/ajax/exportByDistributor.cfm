<!---------------------------------------------------------------------------------------------------------------------
      Template:
      Date:     2015 Mar
      Author:   Chris Nguyen
      Purpose:  aJax processing for

      Remarks:  Columns information ( position starts with zero due to javaScript/aJax )
                   0 = Is Included?
                   1 = Product
                   2 = Description
                   3 = Type Code
                   4 = Type Group
                   5 = Active Code

                IMPORTANT: When column order is changed remember to search & change the related logic for:
                              A.  form.sSearch_[0|1|2|3|..]
                              B.  form.iSortCol_[0|1|2|3|..]
----------------------------------------------------------------------------------------------------------------------->
<cfsetting showDebugOutput="no">
<cfprocessingdirective suppresswhitespace="yes">
<cfsilent>
  <cfparam name="form.iDisplayStart"   default="0">
  <cfparam name="form.iDisplayLength"  default="2000">
  <cfparam name="form.sEcho"           default="10">

  <cfscript>
    tmp   = {};
    reply = {};

    tmp.page_size   = val(form.iDisplayLength);
    if ( tmp.page_size eq -1) {
	    tmp.start_row   = 1;
	    tmp.end_row     = -1;
    }
    else {
	    tmp.start_row   = form.iDisplayStart + 1;
	    tmp.end_row     = form.iDisplayStart + tmp.page_size;
	  }
    form.sSearch   = trim(form.sSearch);
    form.sSearch_3 = trim(form.sSearch_3);
    form.sSearch_4 = trim(form.sSearch_4);
    form.sSearch_5 = trim(form.sSearch_5);

    tmp.words = reMatch("[[:word:]]+", form.sSearch);   // parse filtering string into an array of words
  </cfscript>

	<cfoutput>
  <cfquery name="tmp.qDistributors" datasource="#application.datasource#">
    SELECT
          <cfif tmp.end_row neq -1> TOP #tmp.end_row# </cfif>
           b.Ship_To
          ,b.bsa_FoodService_Customers_Id
          ,b.Name
          ,b.Family_Name
          ,b.Buying_Group_Name
          ,b.Active_Code
     FROM Bsa_Foodservice_Customers b
     WHERE b.Deleted = 0
            <!--- quick search at the top left --->
            <cfif StructKeyExists(form, "sSearch") and len(form.sSearch)>
              AND ( b.Name LIKE  '%#arrayToList(tmp.words, "%")#%' OR b.Ship_To LIKE  '%#arrayToList(tmp.words, "%")#%' )
            </cfif>

            <!--- column filtering by Family Name --->
            <cfif StructKeyExists(form, "sSearch_3") and len(form.sSearch_3)>
              AND b.Family_Name = '#form.sSearch_3#'
            </cfif>

            <!--- column filtering by Buying Group Name --->
            <cfif StructKeyExists(form, "sSearch_4") and len(form.sSearch_4)>
              AND b.Buying_Group_Name = '#form.sSearch_4#'
            </cfif>

            <!--- column filtering by Active Code --->
            <cfif StructKeyExists(form, "sSearch_5") and len(form.sSearch_5)>
              AND b.Active_Code = '#form.sSearch_5#'
            </cfif>

            <cfswitch expression="#form.iSortCol_0#">
              <cfcase value='0'> </cfcase>
              <cfcase value='1'> ORDER BY b.Name          #form.sSortDir_0# </cfcase>
              <cfcase value='2'> ORDER BY b.Ship_To       #form.sSortDir_0# </cfcase>
             </cfswitch>
	</cfquery>
  </cfoutput>

  <!---get total number of records BEFORE filtering--->
  <cfquery name="totalBeforeFilter" datasource="#application.datasource#">
      SELECT COUNT(1) AS rownbr
			   FROM Bsa_Foodservice_Customers b
			  WHERE b.Deleted = 0
  </cfquery>

  <cfset reply.iTotalRecords        = totalBeforeFilter.rownbr>
  <cfset reply.iTotalDisplayRecords = totalBeforeFilter.rownbr>

	<cfif (StructKeyExists(form, "sSearch") and len(form.sSearch))
	   OR (StructKeyExists(form, "sSearch_3") and len(form.sSearch_3))
	   OR (StructKeyExists(form, "sSearch_4") and len(form.sSearch_4))
	   OR (StructKeyExists(form, "sSearch_5") and len(form.sSearch_5))>
    <cfquery name="totalAfterFilter" datasource="#application.datasource#">
      SELECT COUNT(1) as rownbr
        FROM Bsa_Foodservice_Customers b
       WHERE b.Deleted = 0
              <!--- quick search at the top left --->
              <cfif StructKeyExists(form, "sSearch") and len(form.sSearch)>
                AND ( b.Name LIKE '%#arrayToList(tmp.words, "%")#%' OR b.Ship_To LIKE '%#arrayToList(tmp.words, "%")#%' )
              </cfif>

              <!--- column filtering by Family Name --->
              <cfif StructKeyExists(form, "sSearch_3") and len(form.sSearch_3)>
                AND b.Family_Name = '#form.sSearch_3#'
              </cfif>

              <!--- column filtering by Buying Group Name --->
              <cfif StructKeyExists(form, "sSearch_4") and len(form.sSearch_4)>
                AND b.Buying_Group_Name = '#form.sSearch_4#'
              </cfif>

              <!--- column filtering by Active Code --->
              <cfif StructKeyExists(form, "sSearch_5") and len(form.sSearch_5)>
                AND b.Active_Code = '#form.sSearch_5#'
              </cfif>
    </cfquery>
    <!---get total no. of records AFTER filtering--->
    <cfset reply.iTotalDisplayRecords = totalAfterFilter.rownbr>
  </cfif>

  <!--- Generate JSON from Query --->
  <cfset reply.aaData = [] >
  <cfif tmp.end_row eq -1>
  	<cfset tmp.start_row = 1>
  	<cfset tmp.end_row   = tmp.qDistributors.recordCount>
  <cfelse>
  	<cfset tmp.end_row   = min(tmp.end_row, tmp.qDistributors.recordCount)>
  </cfif>

  <cfoutput>
  <cfloop query="tmp.qDistributors" startRow="#tmp.start_row#" endRow="#tmp.end_row#">
    <cfscript>
    	 dArrayTmp = [];
    	 tmp.checked = (listFindNoCase(form.checkedBoxes, tmp.qDistributors.bsa_FoodService_Customers_Id) gt 0 ? 'checked=checked' : '');
       arrayAppend(dArrayTmp, "<input type='checkbox' value='#tmp.qDistributors.bsa_FoodService_Customers_Id#' #tmp.checked# name=distributor_id class='include'>");
       arrayAppend(dArrayTmp, tmp.qDistributors.Name);
       arrayAppend(dArrayTmp, tmp.qDistributors.Ship_To);
       arrayAppend(dArrayTmp, tmp.qDistributors.Family_Name);
       arrayAppend(dArrayTmp, tmp.qDistributors.Buying_Group_Name);
       arrayAppend(dArrayTmp, tmp.qDistributors.Active_Code);
       arrayAppend(reply.aaData, dArrayTmp);
    </cfscript>
  </cfloop>
	</cfoutput>

  <cfset reply.sEcho  = javacast('int', form.sEcho)>
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















