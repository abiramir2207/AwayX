<!----
	Filename:	C:\Work\Code\base\AwayX\settings\Planning_Groups\ajax\Customer_PG_Query.cfm
	Created:	3/7/2012
 	Developer:	drachala
	Copyright (c) 2012 Blacksmith Applications, Inc.

	Description:
		USED TO MAKE AJAX CALLS TO DB FOR TYPE PLANNING GROUPS
	Usage:
		SETTING>>ADMINISTRATOR>>PLANNING GROUPS.
---->
<cfsetting showDebugOutput="no">
<!--- <cfsetting requestTimeOut = "9000" /> --->
<cfprocessingdirective suppresswhitespace="yes">

  <cfsilent>

	<cfparam name="url.iDisplayStart"   default="0">
	<cfparam name="url.iDisplayLength"  default="100">
	<cfparam name="url.sEcho"           default="10">
	<cfparam name="url.iSortCol_0"		default="2">
	<cfparam name="url.sSortDir_0"		default="ASC">
  <cfscript>
	  tmp   = structnew();
	  reply = structnew();
	  tmp.page_size   = val(url.iDisplayLength);
	  tmp.page_number = int(val(url.iDisplayStart) / tmp.page_size) + 1;
  </cfscript>

	<cfquery NAME="qItemList" datasource="#application.datasource#">
		SELECT PGL.Product_Group_Level_ID,PGL.Group_Internal_Label,PGL.Group_Level_Desc,PGA.Product_Group_Attribute_Table
		,PGA.Product_Group_Attribute_ID_Field,PGA.Product_Group_Attribute_Master_ID_Field,PGA.Product_Group_Attribute_Name_Field,PGA.Product_Group_Attribute_Number_Field
		FROM dbo.Product_Group_Level PGL
		INNER JOIN dbo.Product_Group_Attribute PGA
		ON PGA.Product_Group_Level_ID = PGL.Product_Group_Level_ID
		WHERE PGL.Deleted = 0
		AND PGL.Active = 1
		AND PGL.Is_PG = 0
		ORDER BY PGL.Group_Internal_Label ASC
	</cfquery>

<!--- COLUMNS LIST WHICH SHOULD MATCH TO INFO PULLING FROM BELOW QUERY. USING URL VARIABLE ACTIVE TO DETERMINE WHICH SECTION USER LOOKING--->
<cfif isDefined('url.type')>
	<cfscript>
		tmp.columnArray = ["Item", "Description", "GTIN", "PG_Type_Code","PG_Type_Name","PG_Product_Category_Code","PG_Product_Category_Name" ,"Active_Code", "Deleted"];
	</cfscript>
<cfelse>
	   <cfscript>
			tmp.columnArray = ["Item", "Description", "GTIN", "Active_Code", "Deleted"];
	   </cfscript>
</cfif>

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />

<cfif businessSegManager.isEnabledForProduct()>
	<cfset arrayAppend(tmp.columnArray, "Business_Unit_Desc")>
</cfif>

<cfoutput query="qItemList">
	<cfset arrayAppend( tmp.columnArray, "#Product_Group_Attribute_Name_Field#")>
</cfoutput>

<!--- BELOW IS THE QUERY WILL PULLS RECORDS --->
<cfquery name="qppg" datasource="#application.datasource#">

<cfif isDefined('url.type')>
	SELECT IM.item, REPLACE(IM.Description,',',' ') AS Description,IM.GTIN,
	t.PG_Type_Code, t.PG_Type_Name, pg.PG_Product_Category_Code, pg.PG_Product_Category_Name,
	CASE WHEN IM.Active_Code = 'A' THEN 'YES ' ELSE 'NO ' END AS Active_Code,
	CASE WHEN IM.Deleted = 0 THEN 'NO ' ELSE 'YES ' END AS Deleted
	<cfif businessSegManager.isEnabledForProduct()>
	, Business_Unit_Desc
	</cfif>
	<CFLOOP Query="qItemList">
	, attr#Product_Group_Level_ID#.#Product_Group_Attribute_Name_Field#
	</CFLOOP>
	FROM   PG_Type t
	INNER JOIN PG_Product_Category pg
	ON            pg.PG_Type_ID = t.PG_Type_ID
	AND           pg.Deleted = 0
	INNER JOIN PG_Product_Members m
	ON            m.PG_Product_Category_ID = pg.PG_Product_Category_ID
	AND           m.Deleted = 0
	INNER JOIN BSA_Foodservice_Items_Master IM
	ON            IM.BSA_Foodservice_Items_Master_ID = m.BSA_Foodservice_Items_Master_ID
	<CFLOOP Query="qItemList">
	LEFT JOIN #Product_Group_Attribute_Table# as attr#Product_Group_Level_ID#
	ON       attr#Product_Group_Level_ID#.#Product_Group_Attribute_ID_Field# = IM.#Product_Group_Attribute_Master_ID_Field#
	</CFLOOP>
	<cfif businessSegManager.isEnabledForProduct()>
	LEFT JOIN Business_Segment BS
	ON BS.Business_Segment_ID = IM.Business_Segment_ID
	</cfif>
	WHERE  t.Deleted = 0
	AND           t.PG_Group_Type = 1
	AND           t.Is_System = 1

<cfelse>
	SELECT IM.item, REPLACE(IM.Description,',',' ') AS Description, IM.GTIN,
	CASE WHEN IM.Active_Code = 'A' THEN 'YES ' ELSE 'NO ' END AS Active_Code,
	CASE WHEN IM.Deleted = 0 THEN 'NO ' ELSE 'YES ' END AS Deleted
	<cfif businessSegManager.isEnabledForProduct()>
	, Business_Unit_Desc
	</cfif>
	<CFLOOP Query="qItemList">
	, attr#Product_Group_Level_ID#.#Product_Group_Attribute_Name_Field#
	</CFLOOP>
	FROM   BSA_Foodservice_Items_Master IM
	<CFLOOP Query="qItemList">
	LEFT JOIN #Product_Group_Attribute_Table# as attr#Product_Group_Level_ID#
	ON       attr#Product_Group_Level_ID#.#Product_Group_Attribute_ID_Field# = IM.#Product_Group_Attribute_Master_ID_Field#
	</CFLOOP>
	<cfif businessSegManager.isEnabledForProduct()>
	LEFT JOIN Business_Segment BS
	ON BS.Business_Segment_ID = IM.Business_Segment_ID
	</cfif>
	WHERE IM.item is not null
</cfif>

	<cfif StructKeyExists(url, "sSearch") and len(trim(url.sSearch))>
	AND (
			(IM.item like '%#url.sSearch#%')
		OR (IM.Description like '%#url.sSearch#%')
		OR  (IM.GTIN like '%#url.sSearch#%')
		<cfif isDefined('url.type')>
			OR (t.PG_Type_Code like '%#url.sSearch#%')
			OR (t.PG_Type_Name like '%#url.sSearch#%')
			OR (pg.PG_Product_Category_Code like '%#url.sSearch#%')
			OR (pg.PG_Product_Category_Name like '%#url.sSearch#%')
		</cfif>
		<CFLOOP Query="qItemList">
		OR (attr#Product_Group_Level_ID#.#Product_Group_Attribute_Number_Field# like '%#url.sSearch#%')
		</CFLOOP>
	)
	</cfif>
	ORDER BY #tmp.columnArray[url.iSortCol_0 + 1]# #url.sSortDir_0#
</cfquery>

<cfset reply.iTotalRecords        = #qppg.recordcount#>
	<cfset reply.iTotalDisplayRecords = #qppg.recordcount#>

	<cfset start = url.iDisplaystart>
	<cfset end 	= url.iDisplaystart + 100>
	<cfif start EQ 0>
		<cfset start = 1>
	</cfif>

	<!--- Generate JSON from Query --->
	<cfset tmp.dArray = ArrayNew(1) >
	<cfloop query="qppg" startrow="#start#" endrow="#end#">
	  <cfset dArrayTmp = arraynew(1)>
	  <cfloop array="#tmp.columnArray#" index="tmp.columnName">
		<cfset ArrayAppend(dArrayTmp, (qppg[tmp.columnName][qppg.currentRow]))>
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
