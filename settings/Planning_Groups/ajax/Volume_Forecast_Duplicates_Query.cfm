<!---
	Copyright (c)2012 Blacksmith Applications, Inc.       
	Filename:		C:\Work\base\AwayX\settings\Planning_Groups\ajax\Volume_Forecast_Duplicates_Query.cfm
	Created:		8/14/2012
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
<cfif (url.category eq 1) OR (url.category eq 2)>
	 <cfif url.BusinessSegEnabled > 
			<cfscript>
					tmp.columnArray = ["VF_Plan_Desc", "VF_Class_Desc", "Business_Unit_Desc", "pg1", "pg2", "Item", "Description"];
			</cfscript> 
	<cfelse>
			<cfscript>
					tmp.columnArray = ["VF_Plan_Desc", "VF_Class_Desc", "pg1", "pg2", "Item", "Description"];
			</cfscript> 
	</cfif>
<cfelseif url.category eq 0>
			<cfscript>
					tmp.columnArray = ["Shr_Ship_To", "Name", "Item", "Description", "Plan1",  "product_pg1", "distributor_pg1", "Plan2", "product_pg2", "distributor_pg2"];
			</cfscript> 
</cfif>
<!--- BELOW IS THE QUERY WILL PULLS RECORDS --->
<cfquery name="qppg" datasource="#application.datasource#">
						IF OBJECT_ID('tempdb..##tmp_dups') IS NOT NULL
						DROP TABLE ##tmp_dups
						IF OBJECT_ID('tempdb..##tmp_plan_products') IS NOT NULL
						DROP TABLE ##tmp_plan_products
						IF OBJECT_ID('tempdb..##tmp_plan_product_dups') IS NOT NULL
						DROP TABLE ##tmp_plan_product_dups
						IF OBJECT_ID('tempdb..##tmp_plan_products_distributors') IS NOT NULL
						DROP TABLE ##tmp_plan_products_distributors
						IF OBJECT_ID('tempdb..##tmp_plan_product_dist_dups_final') IS NOT NULL
						DROP TABLE ##tmp_plan_product_dist_dups_final
<cfif url.category eq 1>
										SELECT	p.VF_Plan_ID, 
														p.VF_Plan_Desc, 
														c.VF_Class_Desc,
														bs.Business_Unit_Desc,
														vfpg.PG_Product_Category_ID, 
														pgpm.BSA_Foodservice_Items_Master_ID
										INTO		##tmp_dups
										FROM		VF_Plan p
										INNER JOIN  VF_Class c
										ON			c.VF_Class_ID = p.VF_Plan_Class_ID
										AND		c.Deleted = 0
										AND		c.Active = 1 --- Only for active class
										LEFT JOIN Business_Segment bs
										ON			bs.Business_Segment_ID = p.VF_Plan_Segment_ID
										INNER JOIN VF_Planning_Groups vfpg
										ON			vfpg.VF_Plan_ID = p.VF_Plan_ID
										AND		vfpg.Deleted = 0
										INNER JOIN PG_Product_Members pgpm
										ON			pgpm.PG_Product_Category_ID = vfpg.PG_Product_Category_ID
										AND		pgpm.Deleted = 0
						
										INNER JOIN (
						
										SELECT	p.VF_Plan_ID, pgpm.BSA_Foodservice_Items_Master_ID, COUNT(*) as cnt
										FROM		VF_Plan p
										INNER JOIN  VF_Class c
										ON			c.VF_Class_ID = p.VF_Plan_Class_ID
										AND		c.Deleted = 0
										AND		c.Active = 1 -- Only for active class
										INNER JOIN VF_Planning_Groups vfpg -- For distributor replace with VF_Distributor_Planning_Groups
										ON			vfpg.VF_Plan_ID = p.VF_Plan_ID
										AND		vfpg.Deleted = 0
										INNER JOIN PG_Product_Members pgpm
										ON			pgpm.PG_Product_Category_ID = vfpg.PG_Product_Category_ID
										AND		pgpm.Deleted = 0
										WHERE	p.Deleted = 0
										GROUP BY p.VF_Plan_ID, pgpm.BSA_Foodservice_Items_Master_ID
										HAVING COUNT(*) > 1
										
										) AS 	Duplicates
										
									ON			Duplicates.VF_Plan_ID = p.VF_Plan_ID
									AND		Duplicates.BSA_Foodservice_Items_Master_ID = pgpm.BSA_Foodservice_Items_Master_ID
									WHERE	p.Deleted = 0
									
									
									SELECT	dup1.VF_Plan_ID, 
													dup1.VF_Plan_Desc,
													dup1.VF_Class_Desc,
													dup1.Business_Unit_Desc,
													pg1.PG_Product_Category_Name AS pg1,
													pg2.PG_Product_Category_Name AS pg2,
													im.Item,
													im.Description
									FROM		##tmp_dups dup1
									INNER JOIN ##tmp_dups dup2
									ON			dup1.VF_Plan_ID = dup2.VF_Plan_ID
									AND		dup1.BSA_Foodservice_Items_Master_ID = dup2.BSA_Foodservice_Items_Master_ID
									AND		CAST(dup1.PG_Product_Category_ID as varchar(50)) > CAST(dup2.PG_Product_Category_ID as varchar(50))
									INNER JOIN BSA_Foodservice_Items_Master im
									ON			im.BSA_Foodservice_Items_Master_ID = dup1.BSA_Foodservice_Items_Master_ID
									INNER JOIN PG_Product_Category pg1
									ON			pg1.PG_Product_Category_ID = dup1.PG_Product_Category_ID
									INNER JOIN PG_Product_Category pg2
									ON			pg2.PG_Product_Category_ID = dup2.PG_Product_Category_ID
									-----ORDER BY dup1.VF_Plan_Desc, pg1.PG_Product_Category_Name, im.Item	
								<cfif StructKeyExists(url, "sSearch") and len(trim(url.sSearch))>
									WHERE ( 
																(dup1.VF_Plan_Desc like '%#url.sSearch#%') 
														OR 	(dup1.VF_Class_Desc like '%#url.sSearch#%') 
														OR 	(pg1.PG_Product_Category_Name like '%#url.sSearch#%' )
														OR 	(pg2.PG_Product_Category_Name like '%#url.sSearch#%' )
														OR 	(im.Item like '%#url.sSearch#%' )
														OR 	(im.Description like '%#url.sSearch#%' )
													)	
								</cfif>
													
<cfelseif url.category eq 2>
									SELECT	p.VF_Plan_ID, 
													p.VF_Plan_Desc, 
													c.VF_Class_Desc,
													bs.Business_Unit_Desc,
													vfpg.PG_Customer_Category_ID, 
													pgpm.BSA_Foodservice_Customers_ID
									INTO		##tmp_dups
									FROM		VF_Plan p
									INNER JOIN  VF_Class c
									ON			c.VF_Class_ID = p.VF_Plan_Class_ID
									AND		c.Deleted = 0
									AND		c.Active = 1 
									LEFT JOIN Business_Segment bs
									ON			bs.Business_Segment_ID = p.VF_Plan_Segment_ID
									INNER JOIN VF_Distributor_Planning_Groups vfpg 
									ON			vfpg.VF_Plan_ID = p.VF_Plan_ID
									AND		vfpg.Deleted = 0
									INNER JOIN PG_Customer_Members pgpm
									ON			pgpm.PG_Customer_Category_ID = vfpg.PG_Customer_Category_ID
									AND		pgpm.Deleted = 0
									INNER JOIN (
									SELECT	p.VF_Plan_ID, pgpm.BSA_Foodservice_Customers_ID, COUNT(*) as cnt
									FROM		VF_Plan p
									INNER JOIN  VF_Class c
									ON			c.VF_Class_ID = p.VF_Plan_Class_ID
									AND		c.Deleted = 0
									AND		c.Active = 1 -- Only for active class
									INNER JOIN VF_Distributor_Planning_Groups vfpg 
									ON			vfpg.VF_Plan_ID = p.VF_Plan_ID
									AND		vfpg.Deleted = 0
									INNER JOIN PG_Customer_Members pgpm
									ON			pgpm.PG_Customer_Category_ID = vfpg.PG_Customer_Category_ID
									AND		pgpm.Deleted = 0
									WHERE	p.Deleted = 0
									GROUP BY p.VF_Plan_ID, pgpm.BSA_Foodservice_Customers_ID
									HAVING COUNT(*) > 1
									
									) AS 	Duplicates
								ON			Duplicates.VF_Plan_ID = p.VF_Plan_ID
								AND		Duplicates.BSA_Foodservice_Customers_ID = pgpm.BSA_Foodservice_Customers_ID
								WHERE	p.Deleted = 0
							
							
								SELECT	dup1.VF_Plan_ID, 
												dup1.VF_Plan_Desc,
												dup1.VF_Class_Desc,
												dup1.Business_Unit_Desc,
												pg1.PG_Customer_Category_Name AS pg1,
												pg2.PG_Customer_Category_Name AS pg2,
												c.Shr_Ship_To AS Item,
												c.Name AS Description
								FROM	##tmp_dups dup1
								INNER JOIN ##tmp_dups dup2
								ON			dup1.VF_Plan_ID = dup2.VF_Plan_ID
								AND		dup1.BSA_Foodservice_Customers_ID = dup2.BSA_Foodservice_Customers_ID
								AND		CAST(dup1.PG_Customer_Category_ID as varchar(50)) > CAST(dup2.PG_Customer_Category_ID as varchar(50))
								INNER JOIN BSA_Foodservice_Customers c
								ON			c.BSA_Foodservice_Customers_ID = dup1.BSA_Foodservice_Customers_ID
								INNER JOIN PG_Customer_Category pg1
								ON			pg1.PG_Customer_Category_ID = dup1.PG_Customer_Category_ID
								INNER JOIN PG_Customer_Category pg2
								ON			pg2.PG_Customer_Category_ID = dup2.PG_Customer_Category_ID
								----ORDER BY dup1.VF_Plan_Desc, pg1.PG_Customer_Category_Name, c.Shr_Ship_To
								<cfif StructKeyExists(url, "sSearch") and len(trim(url.sSearch))>
									WHERE ( 
															(dup1.VF_Plan_Desc like '%#url.sSearch#%') 
													OR 	(dup1.VF_Class_Desc like '%#url.sSearch#%') 
													OR 	(pg1.PG_Customer_Category_Name like '%#url.sSearch#%' ) 
													OR 	(pg2.PG_Customer_Category_Name like '%#url.sSearch#%' ) 
													OR 	(c.Shr_Ship_To like '%#url.sSearch#%' ) 
													OR 	(c.Name like '%#url.sSearch#%' )
												)	
								</cfif>

<cfelseif url.category eq 0>

								SELECT	p.VF_Plan_ID, 
												p.VF_Plan_Desc, 
												p.Forecast_Level,
												c.VF_Class_ID,
												c.VF_Class_Desc,
												bs.Business_Segment_ID,
												bs.Business_Unit_Desc,
												vfpg.PG_Product_Category_ID, 
												pg.PG_Product_Category_Name,
												pgpm.BSA_Foodservice_Items_Master_ID
								INTO	##tmp_plan_products
								FROM	VF_Plan p
								INNER JOIN  VF_Class c
								ON			c.VF_Class_ID = p.VF_Plan_Class_ID
								AND		c.Deleted = 0
								AND		c.Active = 1 -- Only for active class
								LEFT JOIN Business_Segment bs
								ON			bs.Business_Segment_ID = p.VF_Plan_Segment_ID
								INNER JOIN VF_Planning_Groups vfpg -- For distributor replace with VF_Distributor_Planning_Groups
								ON			vfpg.VF_Plan_ID = p.VF_Plan_ID
								AND		vfpg.Deleted = 0
								INNER JOIN PG_Product_Members pgpm
								ON			pgpm.PG_Product_Category_ID = vfpg.PG_Product_Category_ID
								AND		pgpm.Deleted = 0
								INNER JOIN PG_Product_Category pg
								ON			pg.PG_Product_Category_ID = vfpg.PG_Product_Category_ID
								AND		pg.Deleted = 0
								WHERE	p.Deleted = 0

								-- Find if any plan is a duplicate for class/segment/product
								SELECT	VF_Class_ID, Business_Segment_ID, BSA_Foodservice_Items_Master_ID, COUNT(DISTINCT VF_Plan_ID) as cnt
								INTO		##tmp_plan_product_dups
								FROM		##tmp_plan_products
								GROUP BY VF_Class_ID, Business_Segment_ID, BSA_Foodservice_Items_Master_ID
								HAVING COUNT(DISTINCT VF_Plan_ID) > 1

								SELECT	p.*,
												CAST(0 as bit) as Distributor_Filter,
												CAST(NULL as uniqueidentifier) as PG_Customer_Category_ID,
												CAST('ALL' as nvarchar(100)) as PG_Customer_Category_Name,
												CAST(NULL as uniqueidentifier) as BSA_Foodservice_Customers_ID
								INTO		##tmp_plan_products_distributors
								FROM		##tmp_plan_products p
								INNER JOIN ##tmp_plan_product_dups dup
								ON			dup.VF_Class_ID = p.VF_Class_ID
								AND		dup.Business_Segment_ID = p.Business_Segment_ID
								AND		dup.BSA_Foodservice_Items_Master_ID = p.BSA_Foodservice_Items_Master_ID
								WHERE	p.Forecast_Level != 4
								AND 	NOT EXISTS(
																		SELECT 	vfdg.VF_Plan_ID
																		FROM	VF_Distributor_Planning_Groups  vfdg
																		WHERE 	vfdg.VF_Plan_ID = P.VF_Plan_ID
																		AND		vfdg.Deleted = 0
																)
	
								INSERT INTO ##tmp_plan_products_distributors	
								SELECT	p.*,
												CAST(1 as bit) as Distributor_Filter,
												vfdg.PG_Customer_Category_ID,
												pg.PG_Customer_Category_Name,
												pgcm.BSA_Foodservice_Customers_ID
								FROM		##tmp_plan_products p
								INNER JOIN ##tmp_plan_product_dups dup
								ON			dup.VF_Class_ID = p.VF_Class_ID
								AND		dup.Business_Segment_ID = p.Business_Segment_ID
								AND		dup.BSA_Foodservice_Items_Master_ID = p.BSA_Foodservice_Items_Master_ID
								INNER JOIN VF_Distributor_Planning_Groups  vfdg
								ON			vfdg.VF_Plan_ID = P.VF_Plan_ID
								AND		vfdg.Deleted = 0
								INNER JOIN PG_Customer_Members pgcm
								ON    		pgcm.PG_Customer_Category_ID = vfdg.PG_Customer_Category_ID
								AND		pgcm.Deleted = 0
								INNER JOIN PG_Customer_Category pg
								ON			pg.PG_Customer_Category_ID = vfdg.PG_Customer_Category_ID
								AND		pg.Deleted = 0

----- Find if any plan is a duplicate for class/segment/product for records without distributor
								SELECT	r1.*,
												r2.VF_Plan_ID as VF_Plan_ID2,
												r2.VF_Plan_Desc as VF_Plan_Desc2,
												r2.PG_Product_Category_ID as PG_Product_Category_ID2,
												r2.PG_Product_Category_Name as PG_Product_Category_Name2,
												r2.PG_Customer_Category_ID as PG_Customer_Category_ID2,
												r2.PG_Customer_Category_Name as PG_Customer_Category_Name2,
												r2.BSA_Foodservice_Customers_ID as BSA_Foodservice_Customers_ID2
								INTO		##tmp_plan_product_dist_dups_final
								FROM		##tmp_plan_products_distributors r1
								INNER JOIN ##tmp_plan_products_distributors r2
								ON			r1.VF_Plan_ID != r2.VF_Plan_ID
								AND		(r2.Distributor_Filter = 1 OR r1.VF_Plan_ID < r2.VF_Plan_ID)
								AND		r1.VF_Class_ID = r2.VF_Class_ID
								AND		r1.Business_Segment_ID = r2.Business_Segment_ID
								AND		r1.BSA_Foodservice_Items_Master_ID = r2.BSA_Foodservice_Items_Master_ID
								WHERE	r1.Distributor_Filter = 0

----- Find if any plan is a duplicate for class/segment/product/distributor
								INSERT INTO ##tmp_plan_product_dist_dups_final
								SELECT	r1.*,
												r2.VF_Plan_ID as VF_Plan_ID2,
												r2.VF_Plan_Desc as VF_Plan_Desc2,
												r2.PG_Product_Category_ID as PG_Product_Category_ID2,
												r2.PG_Product_Category_Name as PG_Product_Category_Name2,
												r2.PG_Customer_Category_ID as PG_Customer_Category_ID2,
												r2.PG_Customer_Category_Name as PG_Customer_Category_Name2,
												r2.BSA_Foodservice_Customers_ID as BSA_Foodservice_Customers_ID2
								FROM		##tmp_plan_products_distributors r1
								INNER JOIN ##tmp_plan_products_distributors r2
								ON			r1.VF_Plan_ID < r2.VF_Plan_ID
								AND		r1.VF_Class_ID = r2.VF_Class_ID
								AND		r1.Business_Segment_ID = r2.Business_Segment_ID
								AND		r1.BSA_Foodservice_Items_Master_ID = r2.BSA_Foodservice_Items_Master_ID
								AND		r1.BSA_Foodservice_Customers_ID = r2.BSA_Foodservice_Customers_ID

								SELECT	COALESCE(c1.Shr_Ship_To, c2.Shr_Ship_To, 'ALL') as Shr_Ship_To,
												COALESCE(c1.Name, c2.Name, 'ALL') as Name,
												i.Item,
												i.Description,
												f.VF_Plan_Desc as Plan1,
												f.PG_Product_Category_Name as Product_PG1,
												f.PG_Customer_Category_Name as Distributor_PG1,
												f.VF_Plan_Desc2 as Plan2,
												f.PG_Product_Category_Name2 as Product_PG2,
												f.PG_Customer_Category_Name2 as Distributor_PG2
								FROM		##tmp_plan_product_dist_dups_final f
								LEFT JOIN BSA_Foodservice_Customers c1
								ON			c1.BSA_Foodservice_Customers_ID = f.BSA_Foodservice_Customers_ID
								LEFT JOIN BSA_Foodservice_Customers c2
								ON			c2.BSA_Foodservice_Customers_ID = f.BSA_Foodservice_Customers_ID2
								INNER JOIN BSA_Foodservice_Items_Master i
								ON			i.BSA_Foodservice_Items_Master_ID = f.BSA_Foodservice_Items_Master_ID
								<cfif StructKeyExists(url, "sSearch") and len(trim(url.sSearch))>
									WHERE ( 
															(c1.Shr_Ship_To like '%#url.sSearch#%') 
													OR 	(c2.Shr_Ship_To like '%#url.sSearch#%') 
													OR 	(c1.Name like '%#url.sSearch#%' ) 
													OR 	(c2.Name like '%#url.sSearch#%' ) 
													OR 	(i.Item like '%#url.sSearch#%' ) 
													OR 	(i.Description like '%#url.sSearch#%' )
													OR 	(f.VF_Plan_Desc like '%#url.sSearch#%' ) 
													OR 	(f.PG_Product_Category_Name like '%#url.sSearch#%' ) 
													OR 	(f.PG_Customer_Category_Name like '%#url.sSearch#%' ) 
													OR 	(f.VF_Plan_Desc2 like '%#url.sSearch#%' ) 
													OR 	(f.PG_Product_Category_Name2 like '%#url.sSearch#%' ) 
													OR 	(f.PG_Customer_Category_Name2 like '%#url.sSearch#%' ) 
												)	
								</cfif>
</cfif>

ORDER BY #tmp.columnArray[url.iSortCol_0 + 1]# #url.sSortDir_0#
						IF OBJECT_ID('tempdb..##tmp_dups') IS NOT NULL
						DROP TABLE ##tmp_dups
						IF OBJECT_ID('tempdb..##tmp_plan_products') IS NOT NULL
						DROP TABLE ##tmp_plan_products
						IF OBJECT_ID('tempdb..##tmp_plan_product_dups') IS NOT NULL
						DROP TABLE ##tmp_plan_product_dups
						IF OBJECT_ID('tempdb..##tmp_plan_products_distributors') IS NOT NULL
						DROP TABLE ##tmp_plan_products_distributors
						IF OBJECT_ID('tempdb..##tmp_plan_product_dist_dups_final') IS NOT NULL
						DROP TABLE ##tmp_plan_product_dist_dups_final
</cfquery>
<!--- PGT.PG_Type_Name CREATED NEW QUERY WITH ONLY SPECIFIED COLUMNS ABOVE --->
<cfif (url.category eq 1) OR (url.category eq 2)>
	 <cfif url.BusinessSegEnabled > 
			<cfset tmp.qppg = QueryNew("VF_Plan_Desc,VF_Class_Desc,Business_Unit_Desc,pg1,pg2,Item,Description", "varchar,varchar,varchar,varchar,varchar,varchar,varchar") />
	<cfelse>
			 <cfset tmp.qppg = QueryNew("VF_Plan_Desc,VF_Class_Desc,pg1,pg2,Item,Description", "varchar,varchar,varchar,varchar,varchar,varchar") />
	</cfif>
<cfelseif url.category eq 0>
			 <cfset tmp.qppg = QueryNew("Shr_Ship_to,Name,Item,Description,Plan1,Product_pg1,Distributor_pg1,Plan2,Product_pg2,Distributor_pg2,", "varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar") /> 
</cfif>
<cfloop query="qppg">
      <cfset QueryAddRow(tmp.qppg) />
		<cfif (url.category eq 1) OR (url.category eq 2)>	
						      <cfset QuerySetCell(tmp.qppg, "VF_Plan_Desc", "#VF_Plan_Desc#") />
						      <cfset QuerySetCell(tmp.qppg, "VF_Class_Desc", "#VF_Class_Desc#") />
						<cfif (url.BusinessSegEnabled AND url.category EQ 1) OR (url.BusinessSegEnabled AND url.category EQ 2)> 
						     <cfset QuerySetCell(tmp.qppg, "Business_Unit_Desc", "#Business_Unit_Desc#") />
						</cfif>
						      <cfset QuerySetCell(tmp.qppg, "pg1", "#pg1#") />
						      <cfset QuerySetCell(tmp.qppg, "pg2", "#pg2#") />
						      <cfset QuerySetCell(tmp.qppg, "Item", "#Item#") />
						      <cfset QuerySetCell(tmp.qppg, "Description", "#Description#") />
		<cfelseif url.category eq 0>
						      <cfset QuerySetCell(tmp.qppg, "Shr_Ship_to", "#Shr_Ship_To#") />
						      <cfset QuerySetCell(tmp.qppg, "Name", "#Name#") />
						      <cfset QuerySetCell(tmp.qppg, "Item", "#Item#") />
						      <cfset QuerySetCell(tmp.qppg, "Description", "#Description#") />
						      <cfset QuerySetCell(tmp.qppg, "Plan1", "#Plan1#") />
						      <cfset QuerySetCell(tmp.qppg, "Product_pg1", "#Product_PG1#") />
						      <cfset QuerySetCell(tmp.qppg, "Distributor_pg1", "#Distributor_PG1#") />
						      <cfset QuerySetCell(tmp.qppg, "Plan2", "#Plan2#") />
						      <cfset QuerySetCell(tmp.qppg, "Product_pg2", "#Product_PG2#") />
						      <cfset QuerySetCell(tmp.qppg, "Distributor_pg2", "#Distributor_PG2#") />
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
 