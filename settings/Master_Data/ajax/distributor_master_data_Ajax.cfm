<!----
	Filename:	AwayX\settings\Master_Data\ajax\distributor_master_data_Ajax.cfm
	Created:	3/7/2012
 	Developer:	drachala
	Copyright (c) 2012 Blacksmith Applications, Inc.

	Description:
		USED TO MAKE AJAX CALLS TO DB FOR TYPE PLANNING GROUPS
	Usage:
		SETTING>>ADMINISTRATOR>>PLANNING GROUPS.
---->
<cfsetting showDebugOutput="no">

<cfprocessingdirective suppresswhitespace="yes">
<cfsilent>
<cfparam name="url.iDisplayStart"   default="0">
<cfparam name="url.iDisplayLength"  default="500">
<cfparam name="url.sEcho"           default="10">
<cfparam name="url.iSortCol_0"		default="2">
<cfparam name="url.sSortDir_0"		default="ASC">

<cfscript>
    tmp             = structnew();
    reply           = structnew();
    tmp.page_size   = val(url.iDisplayLength);
    tmp.page_number = int(val(url.iDisplayStart) / tmp.page_size) + 1;

    // columns list which should match to info pulling from below query. using url variable active to determine which section user looking
    if (isDefined('url.type'))
		tmp.columnArray = ["Shr_Ship_To", "Customer_Name", "Address","PG_Type_Code","PG_Type_Name","PG_Customer_Category_Code","PG_Customer_Category_Name" ,"Active_Code", "Deleted"];
    else
		tmp.columnArray = ["Shr_Ship_To", "Customer_Name", "Address", "Active_Code", "Deleted"];

    genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init();
    appSettings        = genSettingsManager.get();
    businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager");

    if (businessSegManager.isEnabledForDistributor())
        arrayAppend(tmp.columnArray, "Business_Unit_Desc");
</cfscript>

<cfquery NAME="qDistList" datasource="#application.datasource#">
	SELECT l.Distributor_Group_Level_ID, l.Group_Level_Desc, l.Distributor_Group_Attribute_Table,
	              l.Distributor_Group_Attribute_ID_Field, l.Distributor_Group_Attribute_Master_ID_Field,
	              l.Distributor_Group_Attribute_Number_Field, l.Distributor_Group_Attribute_Name_Field
	FROM   Distributor_group_level l
	WHERE  l.Deleted = 0
	AND     l.Distributor_Group_Level_Type_ID NOT IN (23, 24, 25, 26)
	AND     l.Active = 1
	AND     l.Is_PG = 0
	AND     l.Distributor_Group_Attribute_Table IS NOT NULL
</cfquery>

<cfoutput query="qDistList">
    <cfset arrayAppend(tmp.columnArray, "#Distributor_Group_Attribute_Name_Field#")>
</cfoutput>

<!--- BELOW IS THE QUERY WILL PULLS RECORDS --->
<cfquery name="qppg" datasource="#application.datasource#">

	<cfif isDefined('url.type')>
		SELECT  c.Shr_Ship_To, c.Name as Customer_Name,t.PG_Type_Code, t.PG_Type_Name
				, c.Address_1+CASE WHEN LEN(c.Address_2) > 0 THEN '<br>'+c.Address_2+',' ELSE '<br>' END +c.City+'<br>'+c.State+','+c.ZipCode AS Address
				, pg.PG_Customer_Category_Code, pg.PG_Customer_Category_Name
				, CASE WHEN c.Active_Code = 'A' THEN 'YES ' ELSE 'NO ' END AS Active_Code
				, CASE WHEN c.Deleted = 0 THEN 'NO ' ELSE 'YES ' END AS Deleted
		<cfif businessSegManager.isEnabledForDistributor()>
		, Business_Unit_Desc
		</cfif>
		<CFLOOP Query="qDistList">
		, attr#Distributor_Group_Level_ID#.#Distributor_Group_Attribute_Name_Field#
		</CFLOOP>
		FROM   PG_Type t
		INNER JOIN PG_Customer_Category pg
		ON            pg.PG_Type_ID = t.PG_Type_ID
		AND           pg.Deleted = 0
		INNER JOIN PG_Customer_Members m
		ON            m.PG_Customer_Category_ID = pg.PG_Customer_Category_ID
		AND           m.Deleted = 0
		INNER JOIN BSA_Foodservice_Customers c
		ON            c.BSA_Foodservice_Customers_ID = m.BSA_Foodservice_Customers_ID
		<CFLOOP Query="qDistList">
		LEFT JOIN #Distributor_Group_Attribute_Table# as attr#Distributor_Group_Level_ID#
		ON       attr#Distributor_Group_Level_ID#.#Distributor_Group_Attribute_ID_Field# = c.#Distributor_Group_Attribute_Master_ID_Field#
		</CFLOOP>
		<cfif businessSegManager.isEnabledForDistributor()>
		LEFT JOIN Business_Segment BS
		ON BS.Business_Segment_ID = c.Business_Segment_ID
		</cfif>
		WHERE  t.Deleted = 0
		AND           t.PG_Group_Type = 2
		AND           t.Is_System = 1

	<cfelse>

		SELECT c.Shr_Ship_To , c.Name as Customer_Name
		, c.Address_1+CASE WHEN LEN(c.Address_2) > 0 THEN '<br>'+c.Address_2+',' ELSE '<br>' END +c.City+'<br>'+c.State+','+c.ZipCode AS Address
		, CASE WHEN c.Active_Code = 'A' THEN 'YES ' ELSE 'NO ' END AS Active_Code, CASE WHEN c.Deleted = 0 THEN 'NO ' ELSE 'YES ' END AS Deleted
		<cfif businessSegManager.isEnabledForDistributor()>
		, Business_Unit_Desc
		</cfif>
		<CFLOOP Query="qDistList">
		, attr#Distributor_Group_Level_ID#.#Distributor_Group_Attribute_Name_Field#
		</CFLOOP>
		FROM   BSA_Foodservice_Customers c
		<CFLOOP Query="qDistList">
		LEFT JOIN #Distributor_Group_Attribute_Table# as attr#Distributor_Group_Level_ID#
		ON       attr#Distributor_Group_Level_ID#.#Distributor_Group_Attribute_ID_Field# = c.#Distributor_Group_Attribute_Master_ID_Field#
		</CFLOOP>
		<cfif businessSegManager.isEnabledForDistributor()>
		LEFT JOIN Business_Segment BS
		ON BS.Business_Segment_ID = c.Business_Segment_ID
		</cfif>
		WHERE c.Ship_To != 'Group'

	</cfif>
	<cfif StructKeyExists(url, "sSearch") and len(trim(url.sSearch))>
		AND (
				(c.Shr_Ship_To like '%#url.sSearch#%')
			OR (c.Name like '%#url.sSearch#%')
			OR (c.Address_1 like '%#url.sSearch#%')
			OR (c.Address_2 like '%#url.sSearch#%')
			OR (c.City like '%#url.sSearch#%')
			OR (c.State like '%#url.sSearch#%')
			OR (c.ZipCode like '%#url.sSearch#%')
			<cfif isDefined('url.type')>
			OR (t.PG_Type_Code like '%#url.sSearch#%')
			OR (t.PG_Type_Name like '%#url.sSearch#%')
			OR (pg.PG_Customer_Category_Code like '%#url.sSearch#%')
			OR (pg.PG_Customer_Category_Name like '%#url.sSearch#%')
			</cfif>
			<CFLOOP Query="qDistList">
			OR (attr#Distributor_Group_Level_ID#.#Distributor_Group_Attribute_Number_Field# like '%#url.sSearch#%')
			</CFLOOP>
		)
	</cfif>
       ORDER BY #tmp.columnArray[url.iSortCol_0 + 1]# #url.sSortDir_0#
</cfquery>
<!--- PGT.PG_Type_Name CREATED NEW QUERY WITH ONLY SPECIFIED COLUMNS ABOVE --->

    <cfset reply.iTotalRecords        = #qppg.recordcount#>
    <cfset reply.iTotalDisplayRecords = #qppg.recordcount#>
	<cfset start = url.iDisplaystart>
	<cfset end 	= url.iDisplaystart + 500>
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
