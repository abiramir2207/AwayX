<!---
	Copyright (c)2012 Blacksmith Applications, Inc.       
	Filename:		C:\Work\base\AwayX\settings\Planning_Groups\ajax\PG_NoMembers_Query.cfm
	Created:		8/13/2012
	Developer:		drachala
	Description:	<brief description of what the file is used for>
	Usage:			<templates that depend on this file>
	Tip:			<gotchas>
--->
<cfsetting showDebugOutput="no">
<cfparam name="url.category" default="1">
<cfparam name="url.active" default="1">
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
		<cfif url.category eq 1>
			<cfscript>
					tmp.columnArray = ["PG_Type_Code", "PG_Type_Name", "PG_Group_Type", "PG_Product_Category_Name"];
			</cfscript> 
		<cfelseif url.category eq 2>
			<cfscript>
					tmp.columnArray = ["PG_Type_Code", "PG_Type_Name", "PG_Group_Type", "PG_Customer_Category_Name"];
			</cfscript> 
		<cfelseif url.category eq 3>
			<cfscript>
					tmp.columnArray = ["PG_Type_Code", "PG_Type_Name", "PG_Group_Type", "PG_Operator_Category_Name"];
			</cfscript> 
		</cfif>
<!--- BELOW IS THE QUERY WILL PULLS RECORDS --->
<cfquery name="qppg" datasource="#application.datasource#">
<cfif url.category eq 1>
							SELECT     	 	PG_Type_Code, PG_Type_Name, PG_Group_Type, PG_Type.Active, PG_Product_Category.PG_Product_Category_Name
							FROM  	  		PG_Type
							INNER JOIN 	PG_Product_Category
							ON          		PG_Type.PG_Type_ID = PG_Product_Category.PG_Type_ID
							AND         		PG_Product_Category.Deleted = 0
							LEFT JOIN 		PG_Product_Members
							ON          			PG_Product_Members.PG_Product_Category_ID = PG_Product_Category.PG_Product_Category_ID
							AND         		PG_Product_Members.Deleted = 0
							WHERE 			PG_Type.Deleted = 0
							AND         		PG_Product_Members.PG_Product_Category_ID is null
							<cfif StructKeyExists(url, "sSearch") and len(trim(url.sSearch))>
							AND ( (PG_Type_Code like '%#url.sSearch#%') OR (PG_Type_Name like '%#url.sSearch#%') OR (PG_Product_Category_Name like '%#url.sSearch#%' ))	
							</cfif>		
<cfelseif url.category eq 2>
							SELECT      PG_Type_Code, PG_Type_Name, PG_Group_Type, PG_Type.Active, PG_Customer_Category.PG_Customer_Category_Name
							FROM  PG_Type
							inner join PG_Customer_Category
							on          PG_Type.PG_Type_ID = PG_Customer_Category.PG_Type_ID
							and         PG_Customer_Category.Deleted = 0
							left join PG_Customer_Members
							on          PG_Customer_Members.PG_Customer_Category_ID = PG_Customer_Category.PG_Customer_Category_ID
							and         PG_Customer_Members.Deleted = 0
							where PG_Type.Deleted = 0
							and         PG_Customer_Members.PG_Customer_Category_ID is null	
							<cfif StructKeyExists(url, "sSearch") and len(trim(url.sSearch))>
							AND ( (PG_Type_Code like '%#url.sSearch#%') OR (PG_Type_Name like '%#url.sSearch#%') OR (PG_Customer_Category_Name like '%#url.sSearch#%' ))	
							</cfif>		
<cfelseif url.category eq 3>
							SELECT      PG_Type_Code, PG_Type_Name, PG_Group_Type, PG_Type.Active, PG_Operator_Category.PG_Operator_Category_Name
							FROM  PG_Type
							inner join PG_Operator_Category
							on          PG_Type.PG_Type_ID = PG_Operator_Category.PG_Type_ID
							and         PG_Operator_Category.Deleted = 0
							left join PG_Operator_Members
							on          PG_Operator_Members.PG_Operator_Category_ID = PG_Operator_Category.PG_Operator_Category_ID
							and         PG_Operator_Members.Deleted = 0
							where PG_Type.Deleted = 0
							and         PG_Operator_Members.PG_Operator_Category_ID is null
							<cfif StructKeyExists(url, "sSearch") and len(trim(url.sSearch))>
							AND ( (PG_Type_Code like '%#url.sSearch#%') OR (PG_Type_Name like '%#url.sSearch#%') OR (PG_Operator_Category_Name like '%#url.sSearch#%' ))	
							</cfif>		
</cfif>
AND PG_Type.Active = #url.active#
ORDER BY #tmp.columnArray[url.iSortCol_0 + 1]# #url.sSortDir_0#
</cfquery>
<!--- PGT.PG_Type_Name CREATED NEW QUERY WITH ONLY SPECIFIED COLUMNS ABOVE --->
<cfif url.category eq 1>
		 <cfset tmp.qppg = QueryNew("PG_Type_Code, PG_Type_Name, PG_Group_Type, PG_Product_Category_Name", "varchar,varchar,varchar,varchar") />
<cfelseif url.category eq 2>
		 <cfset tmp.qppg = QueryNew("PG_Type_Code, PG_Type_Name, PG_Group_Type, PG_Customer_Category_Name", "varchar,varchar,varchar,varchar") />
<cfelseif url.category eq 3>
		 <cfset tmp.qppg = QueryNew("PG_Type_Code, PG_Type_Name, PG_Group_Type, PG_Operator_Category_Name", "varchar,varchar,varchar,varchar") />
</cfif>
<cfloop query="qppg">
      <cfset QueryAddRow(tmp.qppg) />
      <cfset QuerySetCell(tmp.qppg, "PG_Type_Code", "#PG_Type_Code#") />
      <cfset QuerySetCell(tmp.qppg, "PG_Type_Name", "#PG_Type_Name#") />
	  <cfif PG_Group_Type EQ "1">
        	<cfset PGTypeCategory = application.returned_customer_setting.Item_Label />
      <cfelseif PG_Group_Type EQ "2">
        	<cfset PGTypeCategory = application.returned_customer_setting.distributor_label_singular />
      <cfelseif PG_Group_Type EQ "3">
        	<cfset PGTypeCategory = application.returned_customer_setting.Operator_Label_Singular  />
      </cfif>
      		<cfset QuerySetCell(tmp.qppg, "PG_Group_Type", "#PGTypeCategory#") />
		<cfif url.category eq 1>
			 <cfset QuerySetCell(tmp.qppg, "PG_Product_Category_Name", "#PG_Product_Category_Name#")>
		<cfelseif url.category eq 2>
			<cfset QuerySetCell(tmp.qppg, "PG_Customer_Category_Name", "#PG_Customer_Category_Name#")>
		<cfelseif url.category eq 3>
			<cfset QuerySetCell(tmp.qppg, "PG_Operator_Category_Name", "#PG_Operator_Category_Name#")>
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
 