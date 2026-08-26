<!----
	Filename:	C:\Work\Code\base\AwayX\settings\Planning_Groups\ajax\Operator_PG_Info_Query.cfm
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

      <cfscript>
            tmp.columnArray = ["Group_Desc","Group_Number","Group_Name","Inclusion_Exclusion"];
	  </cfscript>


<!--- BELOW IS THE QUERY WILL PULLS RECORDS --->

	<cfstoredproc procedure="Get_Operator_Group_Info_For_PG" datasource="#application.datasource#">
	    <cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@PG_Operator_Category_ID" value = "#url.ID#" null="no">
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@Keyword" value = "#url.sSearch#" null="no">
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@OrderByField" value="Group_Name" null="no">
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@OrderBy" value="ASC" null="no">
		<cfprocresult name="qryPGOperatorCategoryDefinitionByID">
	</cfstoredproc>

<cfquery name="qppg" dbtype="Query">
		SELECT *
		FROM qryPGOperatorCategoryDefinitionByID
		ORDER BY #tmp.columnArray[url.iSortCol_0 + 1]# #url.sSortDir_0#
</cfquery>
<!--- CREATED NEW QUERY WITH ONLY SPECIFIED COLUMNS ABOVE --->

	<cfset tmp.qppg = QueryNew("Group_Desc, Group_Number, Group_Name, Inclusion_Exclusion","varchar,varchar,varchar,varchar") />

   <cfloop query="qppg">

   		<cfif ((qppg.Operator_Group_Level_ID LT 2000) AND qppg.Group_Desc NEQ "Operator")>
			<!--- <cfset grpName = "<a href='##' onclick=""NewWindow('/Common_Files/contracts/Groups/group_items.cfm?Group_ID=#qppg.Distributor_Group_ID#&Group_Level_ID=#qppg.Distributor_Group_Level_ID#', 'Group_Items', 800, 600, 'yes', 'yes');"">#qppg.Group_Name#</a>&nbsp;" /> --->
			<cfset grpName = "#Trim(qppg.Group_Name)#&nbsp;" />
		<cfelseif (qppg.Operator_Group_Level_ID GTE 2000 AND  qppg.Group_Desc NEQ "Operator")>
			<cfset grpName = "<a href='##' onclick=""NewWindow('/settings/Planning_Groups/Operator_PG_Info.cfm?ID=#qppg.Operator_Group_ID#&calledFrom=operAddEdit', 'Group_Items', 800, 600, 'yes', 'yes');""> #Trim(qppg.Group_Name)#</a>&nbsp;" />
		<cfelse>
			<cfset grpName = "#Trim(qppg.Group_Name)#&nbsp;" />
		</cfif>
		
      <cfset QueryAddRow(tmp.qppg) />

      <cfset QuerySetCell(tmp.qppg, "Group_Desc", "#Group_Desc#") />
      <cfset QuerySetCell(tmp.qppg, "Group_Number", "#Group_Number#") />
      <cfset QuerySetCell(tmp.qppg, "Group_Name", "#grpName#") />
	  <cfif Inclusion_Exclusion EQ "true">
      <cfset QuerySetCell(tmp.qppg, "Inclusion_Exclusion", "Included")/>
	  <cfelseif Inclusion_Exclusion Eq "false">
	  <cfset QuerySetCell(tmp.qppg, "Inclusion_Exclusion", "Excluded")/>
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
