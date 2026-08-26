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
					tmp.columnArray = ["Contract_Number", "Contract_Title", "Business_Unit_Desc", "Created_Type", "Item", "Description", "PG_Product_Category_Name"];
			</cfscript> 
	<cfelse>
			<cfscript>
					tmp.columnArray = ["Contract_Number", "Contract_Title", "Created_Type", "Item", "Description", "PG_Product_Category_Name"];
			</cfscript> 
	</cfif>
<!--- BELOW IS THE QUERY WILL PULLS RECORDS --->
<cfquery name="qppg" datasource="#application.datasource#">
						IF OBJECT_ID('tempdb..##tmp_program_template_info') IS NOT NULL
						DROP TABLE ##tmp_program_template_info
<cfif url.category eq 1>
					SELECT	cm.Contract_Main_ID, 
									cm.Contract_Number,
									cm.Contract_Title,
									cm.Business_Segment_ID,
									bs.Business_Unit_Desc,
									t.Created_Type,
									pgts.Product_Group_Level_ID,
									pgts.Product_Group_ID,
									pgpc.PG_Product_Category_Name
					INTO		##tmp_program_template_info
					FROM		Contract_Main cm
					INNER JOIN Business_Segment bs
					ON			bs.Business_Segment_ID = cm.Business_Segment_ID
					INNER JOIN Program_Control_Panel_Options t
					ON			t.ProgramControl_Panel_Options_ID = cm.ProgramType_ID
					INNER JOIN Group_Template gt
					ON			gt.Template_ID =  t.First_Parent_ID
					AND		gt.Active = 1 
					AND		gt.Deleted = 0 
					AND		gt.PG_Group_Type = 1
					AND		gt.Allow_Filter = 1 -- If template is filtered on a group
					AND		gt.PG_Flag = 1
					INNER JOIN PG_Type pg
					ON			pg.PG_Type_ID = gt.Group_Level_ID
					AND 		pg.Is_System = 1
					INNER JOIN Template_Filters tf
					ON			tf.Template_Filters_Id = cm.Template_Filters_Id
					INNER JOIN Product_Group_Template_Selection pgts
					ON			pgts.Template_ID = t.First_Parent_ID
					AND		pgts.Template_Filters_Id = cm.Template_Filters_Id
					AND		pgts.Product_Group_Level_ID = gt.Group_Level_ID
					AND		pgts.Active = 1 
					AND		pgts.Deleted = 0
					AND		pgts.Product_Group_ID != 'undefined'
					INNER JOIN PG_Product_Category pgpc
					ON			pgpc.PG_Product_Category_ID = pgts.Product_Group_ID
					AND		pgpc.Deleted = 0
					WHERE	cm.Deleted = 0
					AND		cm.Manual_Cancel = 0
					AND		cm.Contract_Status_Type_IDX NOT IN (7, 8)-- -- Expired, Lost
					
					SELECT	p.Contract_Number,
									p.Contract_Title,
									p.Business_Unit_Desc,
									p.Created_Type,
									i.Item,
									i.Description,
									p.PG_Product_Category_Name
					FROM	##tmp_program_template_info p
					INNER JOIN Contract_Products cp
					ON			cp.Contract_Main_ID = p.Contract_Main_ID
					AND		cp.Deleted = 0
					AND		cp.Is_Group = 0 ---- only individual products
					INNER JOIN BSA_Foodservice_Items_Master i
					ON			i.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
					LEFT JOIN PG_Product_Members m
					ON			m.PG_Product_Category_ID = p.Product_Group_ID
					AND		m.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
					AND		m.Deleted = 0
					WHERE  ( (	m.PG_Product_Category_ID IS NULL )
								<cfif StructKeyExists(url, "sSearch") and len(trim(url.sSearch))>
									
													AND(	
																		(p.Contract_Number like '%#url.sSearch#%') 
																OR 	(p.Contract_Title like '%#url.sSearch#%') 
																OR 	(p.Created_Type like '%#url.sSearch#%' )
																<cfif url.BusinessSegEnabled > 
																OR 	(p.Business_Unit_Desc like '%#url.sSearch#%' )
																</cfif>
																OR 	(i.Item like '%#url.sSearch#%' )
																OR 	(i.Description like '%#url.sSearch#%' )
														)
														
								</cfif>
								)
<cfelseif url.category eq 2>
					SELECT	cm.Contract_Main_ID, 
									cm.Contract_Number,
									cm.Contract_Title,
									cm.Business_Segment_ID,
									bs.Business_Unit_Desc,
									t.Created_Type,
									cgts.Distributor_Group_Level_ID,
									cgts.Distributor_Group_ID,
									pgcc.PG_Customer_Category_Name
					INTO		##tmp_program_template_info
					FROM		Contract_Main cm
					INNER JOIN Business_Segment bs
					ON			bs.Business_Segment_ID = cm.Business_Segment_ID
					INNER JOIN Program_Control_Panel_Options t
					ON			t.ProgramControl_Panel_Options_ID = cm.ProgramType_ID
					INNER JOIN Group_Template gt
					ON			gt.Template_ID =  t.First_Parent_ID
					AND		gt.Active = 1 
					AND		gt.Deleted = 0 
					AND		gt.PG_Group_Type = 2
					AND		gt.Allow_Filter = 1 -- If template is filtered on a group
					AND		gt.PG_Flag = 1
					INNER JOIN PG_Type pg
					ON			pg.PG_Type_ID = gt.Group_Level_ID
					AND		pg.Is_System = 1
					INNER JOIN Template_Filters tf
					ON			tf.Template_Filters_Id = cm.Template_Filters_Id
					INNER JOIN Customer_Group_Template_Selection cgts
					ON			cgts.Template_ID = t.First_Parent_ID
					AND		cgts.Template_Filters_Id = cm.Template_Filters_Id
					AND		cgts.Distributor_Group_Level_ID = gt.Group_Level_ID
					AND		cgts.Active = 1 
					AND		cgts.Deleted = 0
					AND		cgts.Distributor_Group_ID != 'undefined'
					INNER JOIN PG_Customer_Category pgcc
					ON			pgcc.PG_Customer_Category_ID = cgts.Distributor_Group_ID
					AND		pgcc.Deleted = 0
					WHERE	cm.Deleted = 0
					AND		cm.Manual_Cancel = 0
					AND		cm.Contract_Status_Type_IDX NOT IN (7, 8) -- Expired, Lost

					SELECT	p.Contract_Number,
									p.Contract_Title,
									p.Business_Unit_Desc,
									p.Created_Type,
									c.Shr_Ship_To,
									c.Name,
									p.PG_Customer_Category_Name
					FROM	##tmp_program_template_info p
					INNER JOIN Contract_Distributors cd
					ON			cd.Contract_Main_ID = p.Contract_Main_ID
					AND		cd.Deleted = 0
					AND		cd.Is_Group = 0 -- only individual distributors
					INNER JOIN BSA_Foodservice_Customers c
					ON			c.BSA_Foodservice_Customers_ID = cd.BSA_Foodservice_Customers_ID
					LEFT JOIN PG_Customer_Members m
					ON			m.PG_Customer_Category_ID = p.Distributor_Group_ID
					AND		m.BSA_Foodservice_Customers_ID = cd.BSA_Foodservice_Customers_ID
					AND		m.Deleted = 0
					WHERE  ( (	m.PG_Customer_Category_ID IS NULL)
								<cfif StructKeyExists(url, "sSearch") and len(trim(url.sSearch))>
									
													AND(	
																		(p.Contract_Number like '%#url.sSearch#%') 
																OR 	(p.Contract_Title like '%#url.sSearch#%') 
																OR 	(p.Created_Type like '%#url.sSearch#%' )
																<cfif url.BusinessSegEnabled > 
																OR 	(p.Business_Unit_Desc like '%#url.sSearch#%' )
																</cfif>
																OR 	(i.Item like '%#url.sSearch#%' )
																OR 	(i.Description like '%#url.sSearch#%' )
														)
														
								</cfif>
								)

</cfif>

ORDER BY #tmp.columnArray[url.iSortCol_0 + 1]# #url.sSortDir_0#
						IF OBJECT_ID('tempdb..##tmp_program_template_info') IS NOT NULL
						DROP TABLE ##tmp_program_template_info
</cfquery>
<!--- PGT.PG_Type_Name CREATED NEW QUERY WITH ONLY SPECIFIED COLUMNS ABOVE --->
<cfif (url.BusinessSegEnabled AND url.category EQ 1) OR (url.BusinessSegEnabled AND url.category EQ 2)>
		 <cfset tmp.qppg = QueryNew("Contract_Number,Contract_Title,Business_Unit_Desc,Created_Type,PG_Product_Category_Name,Item,Description", "varchar,varchar,varchar,varchar,varchar,varchar,varchar") />
<cfelse>
		 <cfset tmp.qppg = QueryNew("Contract_Number,Contract_Title,Created_Type,PG_Product_Category_Name,Item,Description", "varchar,varchar,varchar,varchar,varchar,varchar") />
</cfif>
<cfloop query="qppg">
      <cfset QueryAddRow(tmp.qppg) />
      <cfset QuerySetCell(tmp.qppg, "Contract_Number", "#Contract_Number#") />
      <cfset QuerySetCell(tmp.qppg, "Contract_Title", "#Contract_Title#") />
<cfif (url.BusinessSegEnabled AND url.category EQ 1) OR (url.BusinessSegEnabled AND url.category EQ 2)> 
     <cfset QuerySetCell(tmp.qppg, "Business_Unit_Desc", "#Business_Unit_Desc#") />
</cfif>
      <cfset QuerySetCell(tmp.qppg, "Created_Type", "#Created_Type#") />
<cfif url.category EQ 1>    
      <cfset QuerySetCell(tmp.qppg, "PG_Product_Category_Name", "#PG_Product_Category_Name#") />
<cfelseif url.category EQ 2>
	  <cfset QuerySetCell(tmp.qppg, "PG_Product_Category_Name", "#PG_Customer_Category_Name#") />
</cfif> 
<!--- D34715:: Planning Group :: Research Tool --->
<cfif url.category EQ 1>    
      <cfset QuerySetCell(tmp.qppg, "Item", "#Item#") />
      <cfset QuerySetCell(tmp.qppg, "Description", "#Description#") />
<cfelseif url.category EQ 2>
	  <cfset QuerySetCell(tmp.qppg, "Item", "#Shr_Ship_To#") />
      <cfset QuerySetCell(tmp.qppg, "Description", "#Name#") />
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
 