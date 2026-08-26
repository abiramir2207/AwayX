<!----
	Filename:	C:\Work\Code\base\AwayX\settings\Planning_Groups\ajax\Type_PG_Info_Query.cfm
	Created:	10/1/2012
 	Developer:	drachala
	Copyright (c) 2012 Blacksmith Applications, Inc.

	Description:
		USED TO MAKE AJAX CALLS TO DB FOR PRODUCT PLANNING GROUPS
	Usage:
		SETTING>>ADMINISTRATOR>>PLANNING GROUPS.
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
<cfif #url.PGGroup# EQ 1>
      <cfscript>
            tmp.columnArray = [ "PG_Product_Category_Code", "PG_Product_Category_Name", "Include_In_Other_PG"];
	  </cfscript>
<cfelseif #url.PGGroup# EQ 2>
      <cfscript>
            tmp.columnArray = [ "PG_Customer_Category_Code", "PG_Customer_Category_Name", "Include_In_Other_PG"];
	  </cfscript>
<cfelseif #url.PGGroup# EQ 3>
      <cfscript>
            tmp.columnArray = [ "PG_Operator_Category_Code", "PG_Operator_Category_Name", "Include_In_Other_PG"];
	  </cfscript>
</cfif>

<!--- BELOW IS THE QUERY WILL PULLS RECORDS --->
<cfquery name="qppg" datasource="#application.datasource#">
<cfif #url.PGGroup# EQ 1>
	SELECT
        PG_Product_Category_ID,
        PG_Type_ID,
        PG_Product_Category_Code AS PG_ID,
        PG_Product_Category_Name AS PG_Name,
        Active,
        Deleted,
        Created_Date,
        Updated_Date,
        Created_By,
        Updated_BY,
        Include_In_Other_PG
    FROM PG_Product_Category
    WHERE Active = 1 AND
          		Deleted = 0 AND
          		PG_Type_ID = <cfqueryparam value="#url.PGTypeID#" cfsqltype="cf_sql_integer"/>
		  <cfif StructKeyExists(url, "sSearch") and len(trim(url.sSearch))>
		  	  AND ((PG_Product_Category_Code like '%#url.sSearch#%') OR (PG_Product_Category_Name like '%#url.sSearch#%'))
		  </cfif>
	ORDER BY #tmp.columnArray[url.iSortCol_0 + 1]# #url.sSortDir_0#
<cfelseif #url.PGGroup# EQ 2>
	SELECT
        PG_Customer_Category_ID,
        PG_Type_ID,
        PG_Customer_Category_Code AS PG_ID,
        PG_Customer_Category_Name AS PG_Name,
        Active,
        Deleted,
        Created_Date,
        Updated_Date,
        Created_By,
        Updated_BY,
        Include_In_Other_PG
    FROM PG_Customer_Category
    WHERE Active = 1 AND
        		Deleted = 0 AND
        		PG_Type_ID = <cfqueryparam value="#url.PGTypeID#" cfsqltype="cf_sql_integer"/>
		  <cfif StructKeyExists(url, "sSearch") and len(trim(url.sSearch))>
		  	  AND ((PG_Customer_Category_Code like '%#url.sSearch#%') OR (PG_Customer_Category_Name like '%#url.sSearch#%'))
		  </cfif>
	ORDER BY #tmp.columnArray[url.iSortCol_0 + 1]# #url.sSortDir_0#
<cfelseif #url.PGGroup# EQ 3>
	SELECT
        PG_Operator_Category_ID,
        PG_Type_ID,
        PG_Operator_Category_Code AS PG_ID,
        PG_Operator_Category_Name AS PG_Name,
        Active,
        Deleted,
        Created_Date,
        Updated_Date,
        Created_By,
        Updated_BY,
        Include_In_Other_PG
    FROM PG_Operator_Category
    WHERE Active = 1 AND
        		Deleted = 0 AND
        		PG_Type_ID = <cfqueryparam value="#url.PGTypeID#" cfsqltype="cf_sql_integer"/>
		  <cfif StructKeyExists(url, "sSearch") and len(trim(url.sSearch))>
		  	  AND ((PG_Operator_Category_Code like '#url.sSearch#%') OR (PG_Operator_Category_Name like '#url.sSearch#%'))
		  </cfif>
	ORDER BY #tmp.columnArray[url.iSortCol_0 + 1]# #url.sSortDir_0#
</cfif>
</cfquery>
<!--- CREATED NEW QUERY WITH ONLY SPECIFIED COLUMNS ABOVE --->

<cfif #url.PGGroup# EQ 1>
	<cfset tmp.qppg = QueryNew("PG_Product_Category_Code, PG_Product_Category_Name, Include_In_Other_PG","varchar,varchar,varchar") />
<cfelseif #url.PGGroup# EQ 2>
	<cfset tmp.qppg = QueryNew("PG_Customer_Category_Code,PG_Customer_Category_Name,Include_In_Other_PG","varchar,varchar,varchar") />
<cfelseif #url.PGGroup# EQ 3>
	<cfset tmp.qppg = QueryNew("PG_Operator_Category_Code,PG_Operator_Category_Name,Include_In_Other_PG","varchar,varchar,varchar") />
</cfif>

   <cfloop query="qppg">
      <cfset QueryAddRow(tmp.qppg) />

<cfif Include_In_Other_PG>
	<cfset IncludePG = "Included">
<cfelse>
	<cfset IncludePG = "Excluded">
</cfif>

<cfif #url.PGGroup# EQ 1>
      <cfset QuerySetCell(tmp.qppg, "PG_Product_Category_Code", "#PG_ID#") />
      <cfset QuerySetCell(tmp.qppg, "PG_Product_Category_Name", "#PG_Name#") />
      <cfset QuerySetCell(tmp.qppg, "Include_In_Other_PG", "#IncludePG#") />
<cfelseif #url.PGGroup# EQ 2>
      <cfset QuerySetCell(tmp.qppg, "PG_Customer_Category_Code", "#PG_ID#") />
      <cfset QuerySetCell(tmp.qppg, "PG_Customer_Category_Name", "#PG_Name#") />
      <cfset QuerySetCell(tmp.qppg, "Include_In_Other_PG", "#IncludePG#") />
<cfelseif #url.PGGroup# EQ 3>
      <cfset QuerySetCell(tmp.qppg, "PG_Operator_Category_Code", "#PG_ID#") />
      <cfset QuerySetCell(tmp.qppg, "PG_Operator_Category_Name", "#PG_Name#") />
      <cfset QuerySetCell(tmp.qppg, "Include_In_Other_PG", "#IncludePG#") />
</cfif>


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
