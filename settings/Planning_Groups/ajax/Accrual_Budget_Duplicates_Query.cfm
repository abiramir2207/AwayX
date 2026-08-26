<!---
	Copyright (c)2012 Blacksmith Applications, Inc.       
	Filename:		C:\Work\base\AwayX\settings\Planning_Groups\ajax\Accrual_Budget_Duplicates_Query.cfm
	Created:		8/15/2012
	Developer:		drachala
	Description:	<brief description of what the file is used for>
	Usage:			<templates that depend on this file>
	Tip:			<gotchas>
--->
<cfsetting showDebugOutput="no">
<cfparam name="url.category" default="1">
<cfparam name="url.BusinessSegEnabled" default="1">
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
	 <cfif url.BusinessSegEnabled > 
			<cfscript>
					tmp.columnArray = ["Budget_Desc", "Budget_Class_Desc", "Business_Unit_Desc", "pg1", "pg2", "Item", "Description"];
			</cfscript> 
	<cfelse>
			<cfscript>
					tmp.columnArray = ["Budget_Desc", "Budget_Class_Desc", "pg1", "pg2", "Item", "Description"];
			</cfscript> 
	</cfif>
<!--- BELOW IS THE QUERY WILL PULLS RECORDS --->
<cfquery name="qppg" datasource="#application.datasource#">
						IF OBJECT_ID('tempdb..##tmp_dups') IS NOT NULL
						DROP TABLE ##tmp_dups
						IF OBJECT_ID('tempdb..##tmp_budget_distributors') IS NOT NULL
						DROP TABLE ##tmp_budget_distributors
<cfif url.category eq 1>
					SELECT	b.Budget_ID, 
									b.Budget_Desc, 
									c.Budget_Class_Desc,
									bs.Business_Unit_Desc,
									bpr.Product_Group_ID as PG_Product_Category_ID, 
									pgpm.BSA_Foodservice_Items_Master_ID
					INTO	##tmp_dups
					FROM	Budget b
					INNER JOIN  Budget_Class c
					ON			b.Budget_Class_ID = c.Budget_Class_ID
					AND		c.Deleted = 0
					AND		c.Active = 1
					LEFT JOIN Business_Segment bs
					ON			bs.Business_Segment_ID = b.Business_Segment_ID
					INNER JOIN Budget_Product_Rate bpr
					ON			bpr.Budget_ID = b.Budget_ID
					INNER JOIN PG_Product_Members pgpm
					ON			pgpm.PG_Product_Category_ID = bpr.Product_Group_ID
					AND		pgpm.Deleted = 0
					INNER JOIN (
					
						SELECT	b.Budget_ID, pgpm.BSA_Foodservice_Items_Master_ID, COUNT(*) as cnt
						FROM		Budget b
						INNER JOIN  Budget_Class c
						ON			b.Budget_Class_ID = c.Budget_Class_ID
						AND		c.Deleted = 0
						AND		c.Active = 1 
						INNER JOIN Budget_Product_Rate bpr 
						ON			bpr.Budget_ID = b.Budget_ID
						INNER JOIN PG_Product_Members pgpm
						ON			pgpm.PG_Product_Category_ID = bpr.Product_Group_ID
						AND		pgpm.Deleted = 0
						WHERE	b.Deleted = 0
						GROUP BY b.Budget_ID, pgpm.BSA_Foodservice_Items_Master_ID
						HAVING COUNT(*) > 1
						
						) AS 	Duplicates
					ON			Duplicates.Budget_ID = b.Budget_ID
					AND		Duplicates.BSA_Foodservice_Items_Master_ID = pgpm.BSA_Foodservice_Items_Master_ID
					WHERE	b.Deleted = 0


					SELECT	dup1.Budget_ID, 
									dup1.Budget_Desc,
									dup1.Budget_Class_Desc,
									dup1.Business_Unit_Desc,
									pg1.PG_Product_Category_Name AS PG1,
									pg2.PG_Product_Category_Name AS PG2,
									im.Item,
									im.Description
					FROM	##tmp_dups dup1
					INNER JOIN ##tmp_dups dup2
					ON		dup1.Budget_ID = dup2.Budget_ID
					AND		dup1.BSA_Foodservice_Items_Master_ID = dup2.BSA_Foodservice_Items_Master_ID
					AND		CAST(dup1.PG_Product_Category_ID as varchar(50)) > CAST(dup2.PG_Product_Category_ID as varchar(50))
					INNER JOIN BSA_Foodservice_Items_Master im
					ON		im.BSA_Foodservice_Items_Master_ID = dup1.BSA_Foodservice_Items_Master_ID
					INNER JOIN PG_Product_Category pg1
					ON		pg1.PG_Product_Category_ID = dup1.PG_Product_Category_ID
					INNER JOIN PG_Product_Category pg2
					ON		pg2.PG_Product_Category_ID = dup2.PG_Product_Category_ID
					----ORDER BY dup1.Budget_Desc, pg1.PG_Product_Category_Name, im.Item
								<cfif StructKeyExists(url, "sSearch") and len(trim(url.sSearch))>
									WHERE ( 
																(dup1.Budget_Desc like '%#url.sSearch#%') 
														OR 	(dup1.Budget_Class_Desc like '%#url.sSearch#%') 
														OR 	(pg1.PG_Product_Category_Name like '%#url.sSearch#%' )
														OR 	(pg2.PG_Product_Category_Name like '%#url.sSearch#%' )
														OR 	(im.Item like '%#url.sSearch#%' )
														OR 	(im.Description like '%#url.sSearch#%' )
													)	
								</cfif>
													
<cfelseif url.category eq 2>

									SELECT	b.Budget_ID, 
													pgcm.BSA_Foodservice_Customers_ID,
													bd.Distributor_Group_Level_ID,
													bd.Distributor_Group_ID
									INTO	##tmp_budget_distributors
									FROM		Budget b
									INNER JOIN  Budget_Class c
									ON			b.Budget_Class_ID = c.Budget_Class_ID
									AND		c.Deleted = 0
									AND		c.Active = 1 
									INNER JOIN Budget_Distributor bd 
									ON			bd.Budget_ID = b.Budget_ID
									AND		bd.Deleted = 0
									INNER JOIN PG_Customer_Members pgcm
									ON			pgcm.PG_Customer_Category_ID = bd.Distributor_Group_ID
									AND		pgcm.Deleted = 0
									WHERE	b.Deleted = 0
									UNION
									SELECT	b.Budget_ID, 
													bd.Distributor_Group_ID as BSA_Foodservice_Customers_ID,
													bd.Distributor_Group_Level_ID,
													bd.Distributor_Group_ID
									FROM		Budget b
									INNER JOIN  Budget_Class c
									ON			b.Budget_Class_ID = c.Budget_Class_ID
									AND		c.Deleted = 0
									AND		c.Active = 1 
									INNER JOIN Budget_Distributor bd 
									ON			bd.Budget_ID = b.Budget_ID
									AND		bd.Deleted = 0
									AND		bd.Distributor_Group_Level_ID = 0
									WHERE	b.Deleted = 0
															
										
									SELECT	b.Budget_ID, 
													b.Budget_Desc, 
													c.Budget_Class_Desc,
													bs.Business_Unit_Desc,
													bd.Distributor_Group_ID as PG_Customer_Category_ID, 
													bd.BSA_Foodservice_Customers_ID
									INTO	##tmp_dups
									FROM	Budget b
									INNER JOIN  Budget_Class c
									ON			b.Budget_Class_ID = c.Budget_Class_ID
									AND		c.Deleted = 0
									AND		c.Active = 1 
									LEFT JOIN 	Business_Segment bs
									ON				bs.Business_Segment_ID = b.Business_Segment_ID
									INNER JOIN ##tmp_budget_distributors bd 
									ON		bd.Budget_ID = b.Budget_ID
									INNER JOIN (
											SELECT	Distributors.Budget_ID, Distributors.BSA_Foodservice_Customers_ID, COUNT(*) as cnt
											FROM	##tmp_budget_distributors as Distributors
											Group By Distributors.Budget_ID, Distributors.BSA_Foodservice_Customers_ID
											HAVING COUNT(*) > 1
										
										) AS Duplicates
									ON			Duplicates.Budget_ID = b.Budget_ID
									AND		Duplicates.BSA_Foodservice_Customers_ID = bd.BSA_Foodservice_Customers_ID
									WHERE	b.Deleted = 0
									
									SELECT	dup1.Budget_ID, 
													dup1.Budget_Desc,
													dup1.Budget_Class_Desc,
													dup1.Business_Unit_Desc,
													ISNULL(pg1.PG_Customer_Category_Name, '**Individual distributor') as PG1,
													ISNULL(pg2.PG_Customer_Category_Name, '**Individual distributor') as PG2,
													im.Shr_Ship_To AS Item,
													im.Name AS Description
									FROM	##tmp_dups dup1
									INNER JOIN ##tmp_dups dup2
									ON			dup1.Budget_ID = dup2.Budget_ID
									AND		dup1.BSA_Foodservice_Customers_ID = dup2.BSA_Foodservice_Customers_ID
									AND		ISNULL(CAST(dup1.PG_Customer_Category_ID as varchar(50)), '') > ISNULL(CAST(dup2.PG_Customer_Category_ID as varchar(50)), '')
									INNER JOIN BSA_Foodservice_Customers im
									ON		im.BSA_Foodservice_Customers_ID = dup1.BSA_Foodservice_Customers_ID
									LEFT JOIN PG_Customer_Category pg1
									ON		pg1.PG_Customer_Category_ID = dup1.PG_Customer_Category_ID
									LEFT JOIN PG_Customer_Category pg2
									ON		pg2.PG_Customer_Category_ID = dup2.PG_Customer_Category_ID
									----ORDER BY dup1.Budget_Desc, pg1.PG_Customer_Category_Name, im.Shr_Ship_To									
								<cfif StructKeyExists(url, "sSearch") and len(trim(url.sSearch))>
									WHERE ( 
															(dup1.Budget_Desc like '%#url.sSearch#%') 
													OR 	(dup1.Budget_Class_Desc like '%#url.sSearch#%') 
													OR 	(pg1.PG_Customer_Category_Name like '%#url.sSearch#%' ) 
													OR 	(pg2.PG_Customer_Category_Name like '%#url.sSearch#%' ) 
													OR 	(im.Shr_Ship_To like '%#url.sSearch#%' ) 
													OR 	(im.Name like '%#url.sSearch#%' )
												)	
								</cfif>
</cfif>

ORDER BY #tmp.columnArray[url.iSortCol_0 + 1]# #url.sSortDir_0#
						IF OBJECT_ID('tempdb..##tmp_dups') IS NOT NULL
						DROP TABLE ##tmp_dups
						IF OBJECT_ID('tempdb..##tmp_budget_distributors') IS NOT NULL
						DROP TABLE ##tmp_budget_distributors
</cfquery>
<!--- PGT.PG_Type_Name CREATED NEW QUERY WITH ONLY SPECIFIED COLUMNS ABOVE --->
<cfif (url.BusinessSegEnabled AND url.category EQ 1) OR (url.BusinessSegEnabled AND url.category EQ 2)>
		 <cfset tmp.qppg = QueryNew("Budget_Desc,Budget_Class_Desc,Business_Unit_Desc,pg1,pg2,Item,Description", "varchar,varchar,varchar,varchar,varchar,varchar,varchar") />
<cfelse>
		 <cfset tmp.qppg = QueryNew("Budget_Desc,Budget_Class_Desc,pg1,pg2,Item,Description", "varchar,varchar,varchar,varchar,varchar,varchar") />
</cfif>
<cfloop query="qppg">
      <cfset QueryAddRow(tmp.qppg) />
      <cfset QuerySetCell(tmp.qppg, "Budget_Desc", "#Budget_Desc#") />
      <cfset QuerySetCell(tmp.qppg, "Budget_Class_Desc", "#Budget_Class_Desc#") />
<cfif (url.BusinessSegEnabled AND url.category EQ 1) OR (url.BusinessSegEnabled AND url.category EQ 2)> 
     <cfset QuerySetCell(tmp.qppg, "Business_Unit_Desc", "#Business_Unit_Desc#") />
</cfif>
      <cfset QuerySetCell(tmp.qppg, "pg1", "#pg1#") />
      <cfset QuerySetCell(tmp.qppg, "pg2", "#pg2#") />
      <cfset QuerySetCell(tmp.qppg, "Item", "#Item#") />
      <cfset QuerySetCell(tmp.qppg, "Description", "#Description#") />
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
 