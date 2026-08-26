<!---------------------------------------------------------------------------------------------------------------------
      Template: \CustomTags\ajax\choose_distributor.cfm
      Date:     2014 Oct
      Author:   Chris Nguyen
      Purpose:  aJax processing for list active distributors

      Remarks:  Input parameters come in the FORM scope to handle possible large volume of selected distributors

                Columns information ( position starts with zero due to javaScript/aJax )
                   0 = Selected?
                   1 = Item Number
                   2 = Description
                   3 = Type Code
                   4 = Type Group
                   5 = Brand
                   6 = Q Brand

                IMPORTANT: When column order is changed remember to search & change the related logic for:
                              A.  form.sSearch_[0|1|2|3|..]
                              B.  form.iSortCol_[0|1|2|3|..]

      Additional Input:
                FORM.checkedboxes = required, list of selected distributors delimited by commas
----------------------------------------------------------------------------------------------------------------------->
<cfsetting showDebugOutput="no">
<cfprocessingdirective suppresswhitespace="yes">
<cfsilent>
  <cfparam name="form.iDisplayStart"   default="0">
  <cfparam name="form.iDisplayLength"  default="2000">
  <cfparam name="form.sEcho"           default="10">

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
    form.sSearch   = trim(form.sSearch);
    form.sSearch_2 = trim(form.sSearch_2);
    form.sSearch_3 = trim(form.sSearch_3);
    form.sSearch_4 = trim(form.sSearch_4);
    form.sSearch_5 = trim(form.sSearch_5);
    form.sSearch_6 = trim(form.sSearch_6);

    variables.words = reMatch("[[:word:]]+", form.sSearch);   // parse filtering string into an array of words
  </cfscript>

  <cfoutput>
  <cfquery name="variables.qItems" datasource="#application.datasource#">
        <cfset variables.words_list = arrayToList(variables.words, "%")>

        SELECT <cfif variables.end_row neq -1> TOP #variables.end_row# </cfif>
                a.Name
               ,a.shr_Ship_To
               ,a.Address_1
               ,a.City
               ,a.State
               ,a.ZipCode
               ,a.Country_Code
               ,f.Family_Name
               ,b.Buying_Group_Name
               ,a.bsa_FoodService_Customers_Id
        FROM bsa_FoodService_Customers a
            INNER JOIN Distributor_Family f ON a.Family_Id = f.Family_Id
            INNER JOIN Distributor_Buying_Groups b ON a.Buying_Group_Id = b.Buying_Group_Id
        WHERE a.Deleted = 0
              AND a.Active_Code = 'A'
             <cfif len(form.sSearch)>
                AND (    a.Name LIKE '%#variables.words_list#%'
                      OR a.Address_1 LIKE '%#variables.words_list#%'
                      OR a.City LIKE '%#variables.words_list#%'
                      OR a.ZipCode LIKE '%#variables.words_list#%'
                      OR a.shr_Ship_To LIKE '%#variables.words_list#%'
                      )
             </cfif>

            <!--- filtering by Brand --->
            <cfif len(form.sSearch_5)>
                AND f.family_name = '#form.sSearch_5#'
            </cfif>
            <!--- filtering by Q Brand --->
            <cfif len(form.sSearch_6)>
                AND b.Buying_Group_Name = '#form.sSearch_6#'
            </cfif>

             <cfswitch expression="#form.iSortCol_0#">
               <cfcase value='1'> ORDER BY a.Name  #form.sSortDir_0#</cfcase>
               <cfcase value='2'> ORDER BY a.shr_Ship_To  #form.sSortDir_0#</cfcase>
               <cfcase value='3'> ORDER BY a.Address_1  #form.sSortDir_0#</cfcase>
               <cfcase value='4'> ORDER BY a.City + a.State + a.ZipCode #form.sSortDir_0#</cfcase>
               <cfcase value='5'> ORDER BY f.Family_Name #form.sSortDir_0#</cfcase>
               <cfcase value='6'> ORDER BY b.Buying_Group_Name #form.sSortDir_0#</cfcase>
             </cfswitch>
  </cfquery>
  </cfoutput>

  <!---get total number of records BEFORE filtering--->
  <cfquery name="totalBeforeFilter" datasource="#application.datasource#">
      SELECT COUNT(1) AS rownbr
        FROM bsa_FoodService_Customers a
            INNER JOIN Distributor_Family f ON a.Family_Id = f.Family_Id
            INNER JOIN Distributor_Buying_Groups b ON a.Buying_Group_Id = b.Buying_Group_Id
        WHERE a.Deleted = 0
              AND a.Active_Code = 'A'
  </cfquery>

  <cfset variables.reply.iTotalRecords        = totalBeforeFilter.rownbr>
  <cfset variables.reply.iTotalDisplayRecords = totalBeforeFilter.rownbr>

  <cfif len(form.sSearch)
     OR len(form.sSearch_5)
     OR len(form.sSearch_6)>
    <cfquery name="totalAfterFilter" datasource="#application.datasource#">
      SELECT COUNT(1) as rownbr
        FROM bsa_FoodService_Customers a
            INNER JOIN Distributor_Family f ON a.Family_Id = f.Family_Id
            INNER JOIN Distributor_Buying_Groups b ON a.Buying_Group_Id = b.Buying_Group_Id
        WHERE a.Deleted = 0
              AND a.Active_Code = 'A'
             <cfif len(form.sSearch)>
                AND (    a.Name LIKE '%#variables.words_list#%'
                      OR a.Address_1 LIKE '%#variables.words_list#%'
                      OR a.City LIKE '%#variables.words_list#%'
                      OR a.ZipCode LIKE '%#variables.words_list#%'
                      OR a.shr_Ship_To LIKE '%#variables.words_list#%'
                      )
             </cfif>
            <!--- filtering by Brand --->
            <cfif len(form.sSearch_5)>
                AND f.family_name = '#form.sSearch_5#'
            </cfif>
            <!--- filtering by Q Brand --->
            <cfif len(form.sSearch_6)>
                AND b.Buying_Group_Name = '#form.sSearch_6#'
            </cfif>
    </cfquery>
    <!---get total no. of records AFTER filtering--->
    <cfset variables.reply.iTotalDisplayRecords = totalAfterFilter.rownbr>
  </cfif>


  <!--- Generate JSON from Query --->
  <cfset variables.reply.aaData = [] >
  <cfif variables.end_row eq -1>
    <cfset variables.start_row = 1>
    <cfset variables.end_row   = variables.qItems.recordCount>
  <cfelse>
    <cfset variables.end_row   = min(variables.end_row, variables.qItems.recordCount)>
  </cfif>

  <cfoutput>
  <cfloop query="variables.qItems" startRow="#variables.start_row#" endRow="#variables.end_row#">
    <cfscript>
        dArrayTmp = [];

        variables.checked = (listFindNoCase(form.checkedBoxes, variables.qItems.shr_Ship_To) gt 0 ? 'checked=checked' : '');

        if ( form.multiple_selection eq '1' ) {
            arrayAppend(dArrayTmp, "<input type='checkbox' #variables.checked# class=cb value='#variables.qItems.shr_Ship_To#'>");
        }
        else {
            arrayAppend(dArrayTmp, "<input type='radio' name='foo27' #variables.checked# class=cb value='#variables.qItems.shr_Ship_To#'>");
        }

        arrayAppend(dArrayTmp, variables.qItems.Name);
        arrayAppend(dArrayTmp, variables.qItems.shr_Ship_To);
        arrayAppend(dArrayTmp, variables.qItems.Address_1);
        arrayAppend(dArrayTmp, variables.qItems.City & ' ' & variables.qItems.State & ' ' & variables.qItems.ZipCode);
        arrayAppend(dArrayTmp, variables.qItems.Family_Name);
        arrayAppend(dArrayTmp, variables.qItems.Buying_Group_Name);

        arrayAppend(variables.reply.aaData, dArrayTmp);
    </cfscript>
  </cfloop>
  </cfoutput>

  <cfset variables.reply.sEcho  = javacast('int', form.sEcho)>
  <cfset variables.sOut = SerializeJSON( reply )>

  <!--- Since SerializeJSON capitalize the content which is case-sensitive let's reset it the correct way --->
  <cfset variables.sOut = Replace (variables.sOut, 'SECHO', 'sEcho', 'one')>
  <cfset variables.sOut = Replace (variables.sOut, 'ITOTALRECORDS', 'iTotalRecords', 'one')>
  <cfset variables.sOut = Replace (variables.sOut, 'ITOTALDISPLAYRECORDS', 'iTotalDisplayRecords', 'one')>
  <cfset variables.sOut = Replace (variables.sOut, 'AADATA', 'aaData', 'one')>
</cfsilent>

<!---send JSON data back to client--->
<cfoutput>#variables.sOut#</cfoutput>
</cfprocessingdirective>















