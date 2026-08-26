<!----
	Filename:	C:\Work\Code\base\AwayX\common_files\contracts\bid_request\Ajax\ItemWonLost_Query.cfm
	Created:	8/3/2012
 	Developer:	drachala        
	Copyright (c) 2012 Blacksmith Applications, Inc.       
             
	Description: USED TO MAKE AJAX CALLS TO DB FOR GROUP ITEMS STATUS
	LABEL:  D33201: Competitive Data-Incorrectly Marks Products as Won
---->
<cfsetting showDebugOutput="no">

<cfprocessingdirective suppresswhitespace="yes">

  <cfsilent>

    <cfparam name="url.iDisplayStart"   default="0">
    <cfparam name="url.iDisplayLength"  default="20">
    <cfparam name="url.sEcho"           default="10">
	<cfparam name="url.iSortCol_0"		default="2">
	<cfparam name="url.sSortDir_0"		default="ASC">
  <cfscript>
      tmp   = structnew();
      reply = structnew();
      tmp.page_size   = val(url.iDisplayLength);
      tmp.page_number = int(val(url.iDisplayStart) / tmp.page_size) + 1;
  </cfscript>
<!--- COLUMNS LIST WHICH SHOULD MATCH TO INFO PULLING FROM BELOW QUERY. USING URL VARIABLE ACTIVE TO DETERMINE WHICH SECTION USER LOOKING--->
      <cfscript>
            tmp.columnArray = ["Item", "Description",   "Type_Code_Legacy" , "Type_Code_Desc",  "Status"];
	  </cfscript>   

   

<!--- BELOW IS THE QUERY WILL PULLS RECORDS --->
<cfquery name="qppg" datasource="#application.datasource#">
	SELECT  DISTINCT BSA.Item, BSA.Description, 'Status' = CASE BID.Won WHEN 0 THEN 'Lost' WHEN 1 THEN 'Won'  ELSE 'Pending' END , CODE.Type_Code_Legacy , CODE.Type_Code_Desc                                              
	FROM    BSA_Foodservice_Items_Master BSA
	INNER JOIN Contract_Products 
	ON Contract_Products.BSA_Foodservice_Items_Master_ID = BSA.BSA_Foodservice_Items_Master_ID
	AND Contract_Products.Contract_Main_ID = #trim(url.Contract_Main_ID)#
	AND Contract_Products.Deleted = 0
	AND Contract_Products.Is_Group = 0
	and contract_products.product_type_id = '2'
	LEFT JOIN Program_product_bid_info BID
	ON BID.Product_ID = BSA.BSA_Foodservice_Items_Master_ID
	AND BID.Deleted = 0
	AND BID.Program_ID = Contract_Products.Contract_Main_ID
	INNER JOIN Type_Code_Desc CODE
	ON CODE.Type_Code_Desc_ID = BSA.Type_Code_Desc_ID
	WHERE Contract_Products.Product_Group_ID =  '#trim(url.groupId)#'
<cfif StructKeyExists(url, "sSearch") and len(trim(url.sSearch))>
	AND ( (BSA.Item like '%#url.sSearch#%') OR (BSA.Description like '%#url.sSearch#%') OR (CODE.Type_Code_Legacy like '%#url.sSearch#%')  OR (CODE.Type_Code_Desc like '%#url.sSearch#%'))	
</cfif>
    ORDER BY #tmp.columnArray[url.iSortCol_0 + 1]# #url.sSortDir_0#
</cfquery>
<!--- PGT.PG_Type_Name CREATED NEW QUERY WITH ONLY SPECIFIED COLUMNS ABOVE --->

   <cfset tmp.qppg = QueryNew("Item, Description, Type_Code_Legacy, Type_Code_Desc, Status", "varchar,varchar,varchar,varchar,varchar") />

   <cfloop query="qppg">
   	<cfset QueryAddRow(tmp.qppg) />
      <cfset QuerySetCell(tmp.qppg, "Item", "#Item#") />
      <cfset QuerySetCell(tmp.qppg, "Description", "#Description#") />
      <cfset QuerySetCell(tmp.qppg, "Type_Code_Legacy", "#Type_Code_Legacy#") />
      <cfset QuerySetCell(tmp.qppg, "Type_Code_Desc", "#Type_Code_Desc#") />
      <cfset QuerySetCell(tmp.qppg, "Status", "#Status#") />
   </cfloop>




    <cfset reply.iTotalRecords        = #tmp.qppg.recordcount#>
    <cfset reply.iTotalDisplayRecords = #tmp.qppg.recordcount#>

    
	<cfset start = url.iDisplaystart>
	<cfset end 	= url.iDisplaystart + 20>
	<cfif start EQ 0>
		<cfset start = 1>
	</cfif>
	
    <!--- Generate JSON from Query --->
    <cfset tmp.dArray = ArrayNew(1) >
    <cfloop query="tmp.qppg" startrow="#start#" endrow="#end#">
      <cfset dArrayTmp = arraynew(1)>
      <cfloop array="#tmp.columnArray#" index="tmp.columnName">
        <cfset ArrayAppend(dArrayTmp, (tmp.qppg[tmp.columnName][tmp.qppg.currentRow]))>
      </cfloop>
      <cfset ArrayAppend(tmp.dArray, dArrayTmp) >
    </cfloop>

    <cfset reply.aaData = tmp.dArray>
    <cfset reply.sEcho  = javacast('int', url.sEcho)>

    <cfset tmp.sOut = SerializeJSON( reply )>

    <!--- Since SerializeJSON capitalize the content which is case-sensitive let's reset it the correct way --->
    <cfset tmp.sOut = Replace (tmp.sOut, 'SECHO', 'sEcho')>
    <cfset tmp.sOut = Replace (tmp.sOut, 'ITOTALRECORDS', 'iTotalRecords')>
    <cfset tmp.sOut = Replace (tmp.sOut, 'ITOTALDISPLAYRECORDS', 'iTotalDisplayRecords')>
    <cfset tmp.sOut = Replace (tmp.sOut, 'AADATA', 'aaData')>
  </cfsilent>


  <!---send JSON data back to client--->
  <cfoutput>#tmp.sOut#</cfoutput>
</cfprocessingdirective>
 