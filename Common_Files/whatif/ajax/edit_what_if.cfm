<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\whatif\ajax\edit_what_if.cfm
      Date:     2014 Oct
      Author:   Chris Nguyen
      Purpose:  aJax processing for edit what if

      Remarks:  Columns information ( position starts with zero due to javaScript/aJax )
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
    form.sSearch_2 = trim(form.sSearch_2);
    form.sSearch_3 = trim(form.sSearch_3);
    form.sSearch_4 = trim(form.sSearch_4);
    form.sSearch_5 = trim(form.sSearch_5);
    form.sSearch_6 = trim(form.sSearch_6);

    tmp.words = reMatch("[[:word:]]+", form.sSearch);   // parse filtering string into an array of words
  </cfscript>

  <cfoutput>
  <cfquery name="tmp.qItems" datasource="#application.datasource#">
     SELECT
            <cfif tmp.end_row neq -1> TOP #tmp.end_row# </cfif>
              b.BSA_Foodservice_Items_Master_ID
             ,b.Item
             ,b.Description
             ,br.Brand_Name
             ,qb.q_Brand
             ,d.Type_Code_desc
             ,g.Type_Group_desc
        FROM BSA_FOODSERVICE_ITEMS_MASTER b
             INNER JOIN TYPE_GROUP_DESC g ON g.Type_Group_desc_Id = b.Type_Group_desc_Id
             INNER JOIN TYPE_CODE_DESC d ON d.Type_Code_desc_Id = b.Type_Code_desc_Id
             LEFT JOIN BRAND br ON b.Brand = br.Brand_Id AND br.Deleted = 0
             LEFT JOIN Q_BRAND_DESC qb ON b.q_Brand_Id = qb.q_Brand_Id AND qb.Deleted = 0
       WHERE b.Deleted = 0
             AND b.Item IS NOT NULL
             AND b.Active_Code = 'A'
             <cfif len(form.sSearch)>
                AND (    b.Item LIKE '%#arrayToList(tmp.words, "%")#%'
                      OR b.Description LIKE '%#arrayToList(tmp.words, "%")#%')
             </cfif>

             <!--- filtering by Type Code --->
             <cfif len(form.sSearch_3)>
                AND d.Type_Code_desc = '#form.sSearch_3#'
             </cfif>
              <!--- filtering by Type Group --->
              <cfif len(form.sSearch_4)>
                AND g.Type_Group_desc = '#form.sSearch_4#'
             </cfif>
              <!--- filtering by Brand --->
              <cfif len(form.sSearch_5)>
                AND br.brand_name = '#form.sSearch_5#'
             </cfif>
              <!--- filtering by Q Brand --->
              <cfif len(form.sSearch_6)>
                AND qb.q_Brand = '#form.sSearch_6#'
             </cfif>

             <cfswitch expression="#form.iSortCol_0#">
               <cfcase value='1'> ORDER BY b.Item  #form.sSortDir_0#</cfcase>
               <cfcase value='2'> ORDER BY b.Description  #form.sSortDir_0#</cfcase>
               <cfcase value='3'> ORDER BY d.Type_Code_desc  #form.sSortDir_0#, b.Description</cfcase>
               <cfcase value='4'> ORDER BY g.Type_Group_desc  #form.sSortDir_0#, b.Description</cfcase>
               <cfcase value='5'> ORDER BY br.Brand_Name  #form.sSortDir_0#, b.Description</cfcase>
               <cfcase value='6'> ORDER BY qb.q_Brand  #form.sSortDir_0#, b.Description</cfcase>
             </cfswitch>
  </cfquery>
  </cfoutput>

  <!---get total number of records BEFORE filtering--->
  <cfquery name="totalBeforeFilter" datasource="#application.datasource#">
      SELECT COUNT(1) AS rownbr
        FROM BSA_FOODSERVICE_ITEMS_MASTER b
             INNER JOIN TYPE_GROUP_DESC g ON g.Type_Group_desc_Id = b.Type_Group_desc_Id
             INNER JOIN TYPE_CODE_DESC d ON d.Type_Code_desc_Id = b.Type_Code_desc_Id
        WHERE b.Deleted = 0
             AND b.Item IS NOT NULL
             AND b.Active_Code = 'A'
  </cfquery>

  <cfset reply.iTotalRecords        = totalBeforeFilter.rownbr>
  <cfset reply.iTotalDisplayRecords = totalBeforeFilter.rownbr>

  <cfif len(form.sSearch)
     OR len(form.sSearch_3)
     OR len(form.sSearch_4)
     OR len(form.sSearch_5)
     OR len(form.sSearch_6)>
    <cfquery name="totalAfterFilter" datasource="#application.datasource#">
      SELECT COUNT(1) as rownbr
        FROM BSA_FOODSERVICE_ITEMS_MASTER b
             INNER JOIN TYPE_GROUP_DESC g ON g.Type_Group_desc_Id = b.Type_Group_desc_Id
             INNER JOIN TYPE_CODE_DESC d ON d.Type_Code_desc_Id = b.Type_Code_desc_Id
             LEFT JOIN BRAND br ON b.Brand = br.Brand_Id AND br.Deleted = 0
             LEFT JOIN Q_BRAND_DESC qb ON b.q_Brand_Id = qb.q_Brand_Id AND qb.Deleted = 0
       WHERE b.Deleted = 0
             AND b.Item IS NOT NULL
             AND b.Active_Code = 'A'
             <cfif len(form.sSearch)>
                AND (    b.Item LIKE '%#arrayToList(tmp.words, "%")#%'
                      OR b.Description LIKE '%#arrayToList(tmp.words, "%")#%')
             </cfif>
             <cfif len(form.sSearch_3)>
                AND d.Type_Code_desc = '#form.sSearch_3#'
             </cfif>
              <!--- filtering by Type Group --->
              <cfif len(form.sSearch_4)>
                AND g.Type_Group_desc = '#form.sSearch_4#'
             </cfif>
              <!--- filtering by Brand --->
              <cfif len(form.sSearch_5)>
                AND br.brand_name = '#form.sSearch_5#'
             </cfif>
              <!--- filtering by Q Brand --->
              <cfif len(form.sSearch_6)>
                AND qb.q_Brand = '#form.sSearch_6#'
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
       variables.checked = (listFindNoCase(form.checkedBoxes, tmp.qItems.BSA_Foodservice_Items_Master_ID) gt 0 ? 'checked=checked' : '');

       arrayAppend(dArrayTmp, "<input type='checkbox' #variables.checked# class=cb value='#tmp.qItems.BSA_Foodservice_Items_Master_ID#'>");

       arrayAppend(dArrayTmp, tmp.qItems.Item);
       arrayAppend(dArrayTmp, tmp.qItems.Description);
       arrayAppend(dArrayTmp, tmp.qItems.Type_Code_Desc);
       arrayAppend(dArrayTmp, tmp.qItems.Type_Group_Desc);
       arrayAppend(dArrayTmp, tmp.qItems.Brand_Name);
       arrayAppend(dArrayTmp, tmp.qItems.q_Brand);

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















