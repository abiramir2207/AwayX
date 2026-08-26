<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\edit_master_data\Ajax\productCosts.cfm
      Date:     2013 Sep
      Author:   Chris Nguyen
      Purpose:  aJax processing for product costs

      Remarks:  Columns information ( position starts with zero due to javaScript/aJax )
                   0 = Item Number
                   1 = Description
                   2 = Type Code
                   3 = Type Group
                   4 = Brand
                   5 = Q Brand
                   6 = Active Code
                   7 = Cost
                   8 = Cs/Lb

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
    url.sSearch_2 = trim(url.sSearch_2);
    url.sSearch_3 = trim(url.sSearch_3);
    url.sSearch_4 = trim(url.sSearch_4);
    url.sSearch_5 = trim(url.sSearch_5);
    url.sSearch_6 = trim(url.sSearch_6);

    tmp.words = reMatch("[[:word:]]+", url.sSearch);   // parse filtering string into an array of words
  </cfscript>

  <cfoutput>
  <cfquery name="tmp.qItems" datasource="#application.datasource#">
     SELECT
            <cfif tmp.end_row neq -1> TOP #tmp.end_row# </cfif>
              b.BSA_Foodservice_Items_Master_ID
             ,b.Item
             ,b.Description
             ,b.Active_Code
             ,b.Curr_Cost AS Cost_Per_Lb
             ,CASE b.CS_Curr_Cost WHEN '0.001' THEN '0' ELSE b.CS_Curr_Cost END AS Cost_Per_Cs
             ,br.Brand_Name
             ,qb.q_Brand
             ,d.Type_Code_desc
             ,g.Type_Group_desc
        FROM BSA_FOODSERVICE_ITEMS_MASTER b
             INNER JOIN TYPE_GROUP_DESC g ON g.Type_Group_desc_Id = b.Type_Group_desc_Id
             INNER JOIN TYPE_CODE_DESC d ON d.Type_Code_desc_Id = b.Type_Code_desc_Id
             LEFT JOIN BRAND br ON b.Brand_Id = br.Brand_Id AND br.Deleted = 0
             LEFT JOIN Q_BRAND_DESC qb ON b.q_Brand_Id = qb.q_Brand_Id AND qb.Deleted = 0
       WHERE b.Deleted = 0
             AND b.Item IS NOT NULL
             <cfif len(url.sSearch)>
                AND (    b.Item LIKE '%#arrayToList(tmp.words, "%")#%'
                      OR b.Description LIKE '%#arrayToList(tmp.words, "%")#%')
             </cfif>
              <!--- filtering by Type Code --->
              <cfif len(url.sSearch_2)>
                AND d.Type_Code_desc = '#url.sSearch_2#'
             </cfif>
              <!--- filtering by Type Group --->
              <cfif len(url.sSearch_3)>
                AND g.Type_Group_desc = '#url.sSearch_3#'
             </cfif>
              <!--- filtering by Brand --->
              <cfif len(url.sSearch_4)>
                AND br.Brand_Name = '#url.sSearch_4#'
             </cfif>
              <!--- filtering by Q Brand --->
              <cfif len(url.sSearch_5)>
                AND qb.q_Brand = '#url.sSearch_5#'
             </cfif>
              <!--- filtering by Active Code --->
              <cfif len(url.sSearch_6)>
                AND b.Active_Code = '#url.sSearch_6#'
             </cfif>
             <cfif url.withoutCost eq '1'>
               AND ( b.Curr_Cost IS NULL or b.Curr_Cost = '0' or b.Curr_Cost = '0.000')
               AND ( b.CS_Curr_Cost IS NULL or b.CS_Curr_Cost = 0 )
             </cfif>

             <cfswitch expression="#url.iSortCol_0#">
               <cfcase value='0'> ORDER BY b.Item  #url.sSortDir_0#</cfcase>
               <cfcase value='1'> ORDER BY b.Description  #url.sSortDir_0#</cfcase>
               <cfcase value='3'> ORDER BY d.Type_Code_desc  #url.sSortDir_0#, b.Description</cfcase>
               <cfcase value='4'> ORDER BY g.Type_Group_desc  #url.sSortDir_0#, b.Description</cfcase>
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
             <cfif url.withoutCost eq '1'>
               AND ( b.Curr_Cost IS NULL or b.Curr_Cost = '0' or b.Curr_Cost = '0.000')
               AND ( b.CS_Curr_Cost IS NULL or b.CS_Curr_Cost = 0 )
             </cfif>
  </cfquery>

  <cfset reply.iTotalRecords        = totalBeforeFilter.rownbr>
  <cfset reply.iTotalDisplayRecords = totalBeforeFilter.rownbr>

  <cfif len(url.sSearch)
     OR len(url.sSearch_2)
     OR len(url.sSearch_3)
     OR len(url.sSearch_4)
     OR len(url.sSearch_5)
     OR len(url.sSearch_6)>
    <cfquery name="totalAfterFilter" datasource="#application.datasource#">
      SELECT COUNT(1) as rownbr
        FROM BSA_FOODSERVICE_ITEMS_MASTER b
             INNER JOIN TYPE_GROUP_DESC g ON g.Type_Group_desc_Id = b.Type_Group_desc_Id
             INNER JOIN TYPE_CODE_DESC d ON d.Type_Code_desc_Id = b.Type_Code_desc_Id
             LEFT JOIN BRAND br ON b.Brand = br.Brand_Id AND br.Deleted = 0
             LEFT JOIN Q_BRAND_DESC qb ON b.q_Brand_Id = qb.q_Brand_Id AND qb.Deleted = 0
       WHERE b.Deleted = 0
             AND b.Item IS NOT NULL
             <cfif len(url.sSearch)>
                AND (    b.Item LIKE '%#arrayToList(tmp.words, "%")#%'
                      OR b.Description LIKE '%#arrayToList(tmp.words, "%")#%')
             </cfif>
              <!--- filtering by Type Code --->
              <cfif len(url.sSearch_2)>
                AND d.Type_Code_desc = '#url.sSearch_2#'
             </cfif>
              <!--- filtering by Type Group --->
              <cfif len(url.sSearch_3)>
                AND g.Type_Group_desc = '#url.sSearch_3#'
             </cfif>
              <!--- filtering by Brand --->
              <cfif len(url.sSearch_4)>
                AND br.Brand_Name = '#url.sSearch_4#'
             </cfif>
              <!--- filtering by Q Brand --->
              <cfif len(url.sSearch_5)>
                AND qb.q_Brand = '#url.sSearch_5#'
             </cfif>
              <!--- filtering by Active Code --->
              <cfif len(url.sSearch_6)>
                AND b.Active_Code = '#url.sSearch_6#'
             </cfif>
             <cfif url.withoutCost eq '1'>
               AND ( b.Curr_Cost IS NULL or b.Curr_Cost = '0' or b.Curr_Cost = '0.000')
               AND ( b.CS_Curr_Cost IS NULL or b.CS_Curr_Cost = 0 )
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
       arrayAppend(dArrayTmp, tmp.qItems.Item);
       arrayAppend(dArrayTmp, tmp.qItems.Description);
       arrayAppend(dArrayTmp, tmp.qItems.Type_Code_Desc);
       arrayAppend(dArrayTmp, tmp.qItems.Type_Group_Desc);
       arrayAppend(dArrayTmp, tmp.qItems.Brand_Name);
       arrayAppend(dArrayTmp, tmp.qItems.q_Brand);
       arrayAppend(dArrayTmp, tmp.qItems.Active_Code);

       // add item master ID suffix to all three data entry input element names ( cost, per cs, per lb )
       // we need to use the item master ID to find the row to update

       arrayAppend(dArrayTmp, "<input type='text' style='width:95%;' class='cost' name='cost_#tmp.qItems.BSA_Foodservice_Items_Master_ID#' value='#(tmp.qItems.Cost_Per_Cs)#'>" );
       arrayAppend(dArrayTmp, "<input type='radio' name='uom_#tmp.qItems.BSA_Foodservice_Items_Master_ID#' class='uom' value='cs' checked>cs<br><input type='radio' name='uom_#tmp.qItems.BSA_Foodservice_Items_Master_ID#' class='uom' value='lb'>lb");
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















