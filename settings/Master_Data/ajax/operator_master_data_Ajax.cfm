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

<cfprocessingdirective suppresswhitespace="yes">

  <cfsilent>

	<cfparam name="url.iDisplayStart"   default="0">
	<cfparam name="url.iDisplayLength"  default="500">
	<cfparam name="url.sEcho"           default="10">
	<cfparam name="url.iSortCol_0"		default="2">
	<cfparam name="url.sSortDir_0"		default="ASC">
  <cfscript>
	  tmp   = structnew();
	  reply = structnew();
	  tmp.page_size   = val(url.iDisplayLength);
	  tmp.page_number = int(val(url.iDisplayStart) / tmp.page_size) + 1;
  </cfscript>

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfscript>
	if (businessSegManager.isEnabledForOperator()) {
		local.business_segment_label = replace(appSettings.getbusiness_segment_label(), " ", "_");
	}
</cfscript>


	<!--- COLUMNS LIST WHICH SHOULD MATCH TO INFO PULLING FROM BELOW QUERY. USING URL VARIABLE ACTIVE TO DETERMINE WHICH SECTION USER LOOKING--->
	<cfif businessSegManager.isEnabledForOperator()>
		<cfif isDefined('url.type')>
			<cfscript>
				tmp.columnArray = ["BSA_Operator_ID", "Legacy_ID", "Operator_Name", "PG_Type_Code", "PG_Type_Name", "PG_Operator_Category_Code", "PG_Operator_Category_Name", "Active", "Deleted", "#local.business_segment_label#", "Operator_City", "Operator_State", "Operator_Location_Type", "Category_Label", "Priority_Label", "Operator_Type"];
			</cfscript>
		<cfelse>
			<cfscript>
				tmp.columnArray = ["BSA_Operator_ID", "Legacy_ID", "Operator_Name", "Active", "Deleted", "#local.business_segment_label#", "Operator_City", "Operator_State", "Operator_Location_Type", "Category_Label", "Priority_Label", "Operator_Type"];
			</cfscript>
		</cfif>
	<cfelse>
		<cfif isDefined('url.type')>
			<cfscript>
				tmp.columnArray = ["BSA_Operator_ID", "Legacy_ID", "Operator_Name", "PG_Type_Code", "PG_Type_Name", "PG_Operator_Category_Code", "PG_Operator_Category_Name", "Active", "Deleted", "Operator_City", "Operator_State", "Operator_Location_Type", "Category_Label", "Priority_Label", "Operator_Type"];
			</cfscript>
		<cfelse>
			<cfscript>
				tmp.columnArray = ["BSA_Operator_ID", "Legacy_ID", "Operator_Name", "Active", "Deleted", "Operator_City", "Operator_State", "Operator_Location_Type", "Category_Label", "Priority_Label", "Operator_Type"];
			</cfscript>
		</cfif>
	</cfif>
<!--- BELOW IS THE QUERY WILL PULLS RECORDS --->
	<cfquery name="qppg" datasource="#application.datasource#">

	<cfif isDefined('url.type')>
		SELECT O.BSA_Operator_ID, O.Legacy_ID , O.Operator_Name,t.PG_Type_Code, t.PG_Type_Name, pg.PG_Operator_Category_Code, pg.PG_Operator_Category_Name,
					 CASE WHEN O.Deleted = 0 THEN 'Yes ' ELSE 'No ' END as Active,
					CASE WHEN O.Display_Code = 'A' THEN 'No ' ELSE 'Yes ' END as Deleted,
				<cfif businessSegManager.isEnabledForOperator()>
					Business_Unit_Desc AS #local.business_segment_label#,
				</cfif>
					Operator_City, Operator_State, Operator_Location_Type,
					c.Category_Label, p.Priority_Label,Operator_Type
		FROM   PG_Type t
		INNER JOIN PG_Operator_Category pg
		ON            pg.PG_Type_ID = t.PG_Type_ID
		AND           pg.Deleted = 0
		INNER JOIN PG_Operator_Members M
		ON            M.PG_Operator_Category_ID = pg.PG_Operator_Category_ID
		AND           M.Deleted = 0
		INNER JOIN dbo.BSA_Operator O
		ON            O.BSA_Operator_ID = M.BSA_Operator_ID
		LEFT JOIN Operator_Category c ON c.Operator_Category_ID = O.Operator_Category_ID
		LEFT JOIN Operator_Priority p ON p.Operator_Priority_ID = O.Operator_Priority_ID
		<cfif businessSegManager.isEnabledForOperator()>
			LEFT JOIN Business_Segment BS
			ON BS.Business_Segment_ID = O.Business_Segment_ID
		</cfif>
		WHERE  t.Deleted = 0
		AND           t.PG_Group_Type = 3
		AND           t.Is_System = 1
	<cfelse>
		SELECT o.BSA_Operator_ID, o.Legacy_ID , o.Operator_Name,
					CASE WHEN o.Deleted = 0 THEN 'Yes ' ELSE 'No ' END as Active,
					CASE WHEN o.Display_Code = 'A' THEN 'No ' ELSE 'Yes ' END as Deleted,
						<cfif businessSegManager.isEnabledForOperator()>
						 	Business_Unit_Desc AS #local.business_segment_label#,
						</cfif>
					Operator_City, Operator_State, Operator_Location_Type,
					c.Category_Label, p.Priority_Label,Operator_Type
		FROM  BSA_Operator o
		LEFT JOIN Operator_Category c ON c.Operator_Category_ID = o.Operator_Category_ID
		LEFT JOIN Operator_Priority p ON p.Operator_Priority_ID = o.Operator_Priority_ID
		<cfif businessSegManager.isEnabledForOperator()>
			LEFT JOIN Business_Segment BS
			ON BS.Business_Segment_ID = o.Business_Segment_ID
		</cfif>
		WHERE 1 = 1
	</cfif>
	 <cfif StructKeyExists(url, "sSearch") and len(trim(url.sSearch))>
		AND (
				  (o.BSA_Operator_ID like '%#url.sSearch#%')
			  OR (o.Legacy_ID like '%#url.sSearch#%')
			  OR (o.Operator_Name like '%#url.sSearch#%')
			  OR (Operator_City like '%#url.sSearch#%')
			  OR (Operator_State like '%#url.sSearch#%')
			  OR (Operator_Location_Type like '%#url.sSearch#%')
			  OR (c.Category_Label like '%#url.sSearch#%')
			  OR (p.Priority_Label like '%#url.sSearch#%')
			  OR (Operator_Type like '%#url.sSearch#%')
			  <cfif isDefined('url.type')>
			  OR (t.PG_Type_Code like '%#url.sSearch#%')
			  OR (t.PG_Type_Name  like '%#url.sSearch#%')
			  OR (pg.PG_Operator_Category_Code  like '%#url.sSearch#%')
			  OR (pg.PG_Operator_Category_Name like '%#url.sSearch#%')
			  </cfif>
		)
	</cfif>
		ORDER BY #tmp.columnArray[url.iSortCol_0 + 1]# #url.sSortDir_0#
	</cfquery>

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
