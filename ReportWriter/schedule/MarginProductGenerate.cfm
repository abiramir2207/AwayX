	<cfset sSelect			= "SELECT distinct cs.Contract_Status_Type_Desc,cm.Contract_Status_Type_IDX,pt.Created_Type,cm.Contract_Number,cm.Contract_Title,cm.Contract_Main_ID,pcla.Item, pcla.Description">
	<cfset sGroupBy			= "">
	<cfset sWhereClause		= "">
	<cfset sJoinClause		= "">
	<cfset sJoinClauseBeginBraces= "">
	
	
	
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	Generate groupList like status,p
	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
	<cfset sGroupByList		= "">
	<cfif Len(rSortBy) GT 0>
		<cfloop index="i" list="#rSortBy#" delimiters=",">
			<cfif i NEQ "-1">
			<cfif NOT ListFindNoCase(sGroupByList, i,",")>				
				<cfset sGroupByList=ListAppend(sGroupByList,i,",")>
			</cfif>
			</cfif>
		</cfloop>
	</cfif>
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	End Generate groupList like status,p
	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
	
	
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	Make exact group By clause 'sGroupBy' from groupList
	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->

	<cfset sGroupBy=sGroupByList>
	
	<cfif reportType EQ "Product_Based_Margin_Analysis">
		<cfset sGroupBy=ListPrepend(sGroupBy,"pcla.Item",",")>
		<cfset sGroupBy=ListAppend(sGroupBy,"cm.Contract_Number",",")>
	<cfelse>
		<cfset iIndex=ListFindNoCase(sGroupBy, "margin",",")>
		<cfif iIndex EQ 0>
			<cfset sGroupBy=ListAppend(sGroupBy,"cm.Contract_Number",",")>
		<cfelse>
			<cfset sGroupBy=ListInsertAt(sGroupBy,iIndex,"cm.Contract_Number",",")>
		</cfif>
		<cfset sGroupBy=ListAppend(sGroupBy,"pcla.Item",",")>
	</cfif>
	
	<cfset iIndex=ListFindNoCase(sGroupBy, "status",",")>	
	<cfif iIndex GT 0>
		<cfset sGroupBy=ListSetAt(sGroupBy, iIndex, "cm.Contract_Status_Type_IDX",",")>
	</cfif>
	<cfset iIndex=ListFindNoCase(sGroupBy, "programtype",",")>	
	<cfif iIndex GT 0>
		<cfset sGroupBy=ListSetAt(sGroupBy, iIndex, "pt.Created_Type",",")>
	</cfif>
	<cfset iIndex=ListFindNoCase(sGroupBy, "margin",",")>	
	<cfif iIndex GT 0>
		<cfset sGroupBy=ListSetAt(sGroupBy, iIndex, "MarginPerLB",",")>
	</cfif>
	
	<CFIF Len(sGroupBy) GT 0>
		<CFSET sGroupBy = " ORDER BY #sGroupBy#">
	</CFIF>
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	End Make exact group By clause 'sGroupBy' from groupList
	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
	
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	Make where clause from the filters
	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->	
	
	<CFSWITCH expression="#rFilterItem#">
		<CFCASE value="typegroup">
			<CFIF rTypeGroups NEQ "">
				<CFIF rTypeGroups NEQ "-1">
				<cfset sJoinClause="#sJoinClause# INNER JOIN  Type_Group_Desc tg ON ((pcla.Type_Group_Desc_ID=tg.Type_Group_Desc_ID)">				
					<cfset sJoinClause="#sJoinClause# AND (tg.Type_Group_Desc_ID='#rTypeGroups#')">				
				<cfset sJoinClause="#sJoinClause#))">				
				<cfset sJoinClauseBeginBraces="#sJoinClauseBeginBraces#(">
				</CFIF>
			</CFIF>
		</CFCASE>
		<CFCASE value="qbrand">
			<CFIF rQBrands NEQ "">
				<CFIF rQBrands NEQ "-1">
				<!-----
				<cfset sJoinClause="#sJoinClause# INNER JOIN (Q_Brand_Desc qb INNER JOIN Product_Q_Brand_Desc pqb ON ((pqb.Q_Brand_ID=qb.Q_Brand_ID) and (pqb.LOB='F') and (pqb.Deleted=0))) ON ((pcla.BSA_Foodservice_Items_Master_ID=pqb.BSA_Foodservice_Items_Master_ID) AND (qb.Deleted=0)">				
				---------->
				<cfsavecontent variable="q_brand_report_join_clause">
					<cfinclude template="#Application.Doc_mapping#/data_files/created/#application.returned_customer_setting.qry_q_brand_report_join_clause#">
				</cfsavecontent>
				<cfset sJoinClause="#sJoinClause# #q_brand_report_join_clause# ">
				
				<cfset sJoinClause="#sJoinClause# AND (qb.Q_Brand_ID='#rQBrands#')">				
				<cfset sJoinClause="#sJoinClause#)">
				<cfset sJoinClauseBeginBraces="#sJoinClauseBeginBraces#(">
				</CFIF>
			</CFIF>
		</CFCASE>
		<CFCASE value="typecode">
			<CFIF rTypeCodes NEQ "-1">
			<cfset sJoinClause="#sJoinClause# INNER JOIN  Type_Code_Desc tc ON ((pcla.Type_Code_Desc_ID=tc.Type_Code_Desc_ID)">			
				<cfset sJoinClause="#sJoinClause# AND (tc.Type_Code_Desc_ID='#rTypeCodes#')">			
			<cfset sJoinClause="#sJoinClause#)) ">
			<cfset sJoinClauseBeginBraces="#sJoinClauseBeginBraces#(">
			</CFIF>
		</CFCASE>
		<CFCASE value="brand">
			<CFIF rBrands NEQ "-1">
			<cfset sJoinClause="#sJoinClause# INNER JOIN  Brand b ON ((pcla.Brand_ID=b.Brand_ID)">			
				<cfset sJoinClause="#sJoinClause# AND (b.Brand_ID='#rBrands#')">			
			<cfset sJoinClause="#sJoinClause#)) ">
			<cfset sJoinClauseBeginBraces="#sJoinClauseBeginBraces#(">
			</CFIF>
		</CFCASE>
	</CFSWITCH>
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	End Make where clause from the filters
	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
	
	<cfset sWhereClause		= " AND 0=0 ">
	
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
build where clause using margin restrictions
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
	<CFOUTPUT>
	<CFSWITCH expression="#rMarginOption#">
		<CFCASE value="GT">		
			<CFIF IsNumeric(rMarginValue1)>
				<!------<CFSET sWhereClause	=	"#sWhereClause# AND (isNull(cpm.FPM,0) + isNull(cpm.REM,0) + isNull(cpm.GRM,0)) >= #rMarginValue1#">----->				
				<CFSAVECONTENT variable="sWhereClause">
				#sWhereClause#
				AND 
				(
					(cpm.FPM >= #rMarginValue1# AND cpm.Product_Type_ID = 1)
					OR
					(cpm.REM >= #rMarginValue1# AND cpm.Product_Type_ID = 2)
					OR
					(cpm.GRM >= #rMarginValue1# AND cpm.Product_Type_ID = 4)
				
				)
				</CFSAVECONTENT>
			</CFIF>
		</CFCASE>
		<CFCASE value="LT">
			<CFIF IsNumeric(rMarginValue1)>
				<!------<CFSET sWhereClause	=	"#sWhereClause# AND (isNull(cpm.FPM,0) + isNull(cpm.REM,0) + isNull(cpm.GRM,0)) <= #rMarginValue1#">----->
				<CFSAVECONTENT variable="sWhereClause">
				#sWhereClause#
				AND 
				(
					(cpm.FPM <= #rMarginValue1# AND cpm.Product_Type_ID = 1)
					OR
					(cpm.REM <= #rMarginValue1# AND cpm.Product_Type_ID = 2)
					OR
					(cpm.GRM <= #rMarginValue1# AND cpm.Product_Type_ID = 4)
				
				)
				</CFSAVECONTENT>
			</CFIF>
		</CFCASE>
		<CFCASE value="BTW">
			<CFIF IsNumeric(rMarginValue1) AND IsNumeric(rMarginValue2)>
				<CFIF rMarginValue1 GT rMarginValue2>
					<CFSET temp				=	rMarginValue2>
					<CFSET rMarginValue2	=	rMarginValue1>
					<CFSET rMarginValue1	=	temp>
				</CFIF>
				<!------<CFSET sWhereClause	=	"#sWhereClause# AND (isNull(cpm.FPM,0) + isNull(cpm.REM,0) + isNull(cpm.GRM,0)) >= #rMarginValue1# AND (isNull(cpm.FPM,0) + isNull(cpm.REM,0) + isNull(cpm.GRM,0)) <= #rMarginValue2#">----->
				<CFSAVECONTENT variable="sWhereClause">
				#sWhereClause#
				AND 
				(
					(cpm.FPM >= #rMarginValue1# AND cpm.FPM <= #rMarginValue2# AND cpm.Product_Type_ID = 1)
					OR
					(cpm.REM >= #rMarginValue1# AND cpm.REM <= #rMarginValue2# AND cpm.Product_Type_ID = 2)
					OR
					(cpm.GRM >= #rMarginValue1# AND cpm.GRM <= #rMarginValue2# AND cpm.Product_Type_ID = 4)
				
				)
				</CFSAVECONTENT>
			</CFIF>
		</CFCASE>
	</CFSWITCH>
	</CFOUTPUT>
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
build where clause using margin restrictions
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
	
	<cfset DescSeparator=", ">
	<cfinclude template="MarginReportDescription.cfm">
	
	<!------
<cfif reportFormatType EQ 1 OR reportFormatType EQ 2 OR reportFormatType EQ 3>
		<cfstoredproc procedure="get_Program_Margin_Check"  datasource="#application.datasource#">
		</cfstoredproc>
	</cfif>
----->
	
	
	<cfset sInnerJoinClause		= "">
	<cfset sInnerJoinClauseBeginBraces= "">
	<cfset innerWhereClause="">
	<CFSWITCH expression="#rFilterCust#">
		<CFCASE value="family">
			<CFIF rFamilys NEQ "">
				<CFIF rFamilys NEQ "-1">
					<CFOUTPUT><CFSAVECONTENT variable="innerWhereClause">
					AND EXISTS (
						SELECT 	TOP 1 cd1.BSA_Foodservice_Customers_ID
						FROM	
								(Contract_Distributors cd1
								INNER JOIN 
									(customer_lob_active cla1
									INNER JOIN Distributor_Family f
									ON(
										(cla1.family_ID=f.family_ID) AND (f.Deleted=0) AND (f.family_ID='#rFamilys#')
									))
								ON	(
								(cd1.BSA_Foodservice_Customers_ID = cla1.BSA_Foodservice_Customers_ID)
								))
						WHERE
								cd1.Contract_Main_ID = cm.Contract_Main_ID
								AND
								cd1.Deleted = 0
					)
					</CFSAVECONTENT></CFOUTPUT>
				</CFIF>
			</CFIF>					
		</CFCASE>
		<CFCASE value="buyinggroup">
			<CFIF rBuyingGroups NEQ "">
				<CFIF rBuyingGroups NEQ "-1">
					<CFOUTPUT><CFSAVECONTENT variable="innerWhereClause">
					AND EXISTS (
						SELECT 	TOP 1 cd1.BSA_Foodservice_Customers_ID
						FROM	
								(Contract_Distributors cd1
								INNER JOIN 
									(customer_lob_active cla1
									INNER JOIN Distributor_Buying_Groups bg
									ON(
										(cla1.Buying_Group_ID=bg.Buying_Group_ID) AND (bg.Deleted=0) AND (bg.Buying_Group_ID='#rBuyingGroups#')
									))
								ON	(
								(cd1.BSA_Foodservice_Customers_ID = cla1.BSA_Foodservice_Customers_ID)
								))
						WHERE
								cd1.Contract_Main_ID = cm.Contract_Main_ID
								AND
								cd1.Deleted = 0
					)
					</CFSAVECONTENT></CFOUTPUT>
				</CFIF>
			</CFIF>
		</CFCASE>
		<CFCASE value="distributor">
			<CFIF rDistributors NEQ "-1">
				<CFOUTPUT><CFSAVECONTENT variable="innerWhereClause">
					AND EXISTS (
						SELECT 	TOP 1 cd1.BSA_Foodservice_Customers_ID
						FROM	
								Contract_Distributors cd1
						WHERE
								cd1.Contract_Main_ID = cm.Contract_Main_ID
								AND
								cd1.Deleted = 0
								AND
								cd1.BSA_Foodservice_Customers_ID = '#rDistributors#'
					)
					</CFSAVECONTENT></CFOUTPUT>
			</CFIF>					
		</CFCASE>
	</CFSWITCH>
	
	<CFSWITCH expression="#reportFormatType#">
		<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
		Product and Margin only
		xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
		<CFCASE value="1">
			<CFQUERY NAME="q_getReport" datasource="#application.datasource#">
				#sSelect#
					, pcla.Item, pcla.Description
					, cpm.Product_Type_ID
					,CASE 
						WHEN	cpm.Product_Type_ID = 1 THEN
							cpm.FPM
						WHEN	cpm.Product_Type_ID = 2 THEN
							cpm.REM
						WHEN	cpm.Product_Type_ID = 4 THEN
							cpm.GRM
						WHEN	cpm.Product_Type_ID = 5 THEN
							cpm.KPM							
					END AS MarginPerLB					
				FROM
				#sJoinClauseBeginBraces#
				((((((Contract_Main cm 
				INNER JOIN  	Contract_Status_Types cs
							ON ((cs.Contract_Status_Type_ID = cm.Contract_Status_Type_IDX)
								<cfif NOT ListFindNoCase(rStatus,"-1",",")>
								AND		(cs.Contract_Status_Type_ID in (#rStatus#))
								</cfif>
								))
				INNER JOIN  	Program_Control_Panel_Options pt 
							ON ((pt.ProgramControl_Panel_Options_ID = cm.ProgramType_ID)
								<!------<cfif NOT ListFindNoCase(rProgramTypes,"-1",",")>
								AND		(pt.ProgramControl_Panel_Options_ID in (#rProgramTypes#))
								</cfif>----->								
								))
								INNER JOIN  Generic_Type ON Generic_Type.Generic_Type=pt.Generic_Type
								<cfif NOT ListFindNoCase(rGenericTypes,"-1",",")>
								and		Generic_Type_ID in (#rGenericTypes#)
								</cfif>
				INNER JOIN  	Units_of_Measure uom 
							ON uom.Unit_Of_Measure_ID = cm.Contract_Quantity_UOM_IDX)
				INNER JOIN	Contract_Products cp
							ON (cp.Contract_Main_ID = cm.Contract_Main_ID))
				INNER JOIN	product_category_lob_active pcla
							ON (pcla.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID))
				INNER JOIN	 Contract_Product_Margin cpm
							ON ((cp.Contract_Products_ID = cpm.Contract_Product_ID) AND (cpm.Contract_Main_ID = cm.Contract_Main_ID) AND (cpm.Deleted = 0)))
				#PreserveSingleQuotes(sJoinClause)#
				WHERE	
							cp.Deleted	=	0
					AND		cm.Deleted	=	0
					AND		cm.Flagged_As_Purged=0
					AND		
					cs.Contract_Status_Type_ID >= 5
					AND
					cs.Contract_Status_Type_ID <= 6
					AND
					(
						((cm.Parent_Revised_Contract_Main_ID IS NULL) AND (cm.Revision_of_Contract_Main_ID IS NULL))
						OR
						(NOT(cm.Parent_Revised_Contract_Main_ID IS NULL) AND NOT(cm.Revision_of_Contract_Main_ID IS NULL) AND cs.Contract_Status_Type_ID > 4)
					)
					#PreserveSingleQuotes(sWhereClause)#
					#PreserveSingleQuotes(innerWhereClause)#
				#sGroupBy#, cpm.Product_Type_ID
			</CFQUERY>
			<cfset srqueryname="q_getReport">
		</CFCASE>
		<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
		Cost Detail
		xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
		<CFCASE value="2">
			<CFQUERY NAME="q_getReport" datasource="#application.datasource#">
				#sSelect#
					, cpm.Product_Type_ID
					, 
					CASE 
						WHEN	cpm.Product_Type_ID = 1 THEN
							cpm.FPM
						WHEN	cpm.Product_Type_ID = 2 THEN
							cpm.REM
						WHEN	cpm.Product_Type_ID = 4 THEN
							cpm.GRM
						WHEN	cpm.Product_Type_ID = 5 THEN
							cpm.KPM
					END AS MarginPerLB
					, pcla.Item, pcla.Description
					, cpm.ACC, cpm.ICC, cpm.NCA, cpm.Product_Type_ID, cpm.TPA,
					CASE 
						WHEN	cpm.Product_Type_ID = 1 THEN
							cpm.FPR_LB
						WHEN	cpm.Product_Type_ID = 2 THEN
							cpm.RER_LB
						WHEN	cpm.Product_Type_ID = 4 THEN
							cpm.GRR_LB
						WHEN	cpm.Product_Type_ID = 5 THEN
							cpm.KPR_LB
					END AS ratePerLB
				FROM
				#sJoinClauseBeginBraces#
				((((((Contract_Main cm 
				INNER JOIN  	Contract_Status_Types cs
							ON ((cs.Contract_Status_Type_ID = cm.Contract_Status_Type_IDX)
								<cfif NOT ListFindNoCase(rStatus,"-1",",")>
								AND		(cs.Contract_Status_Type_ID in (#rStatus#))
								</cfif>
								))
				INNER JOIN  	Program_Control_Panel_Options pt 
							ON ((pt.ProgramControl_Panel_Options_ID = cm.ProgramType_ID)
								<!------<cfif NOT ListFindNoCase(rProgramTypes,"-1",",")>
								AND		(pt.ProgramControl_Panel_Options_ID in (#rProgramTypes#))
								</cfif>----->								
								))
								INNER JOIN  Generic_Type ON Generic_Type.Generic_Type=pt.Generic_Type
								<cfif NOT ListFindNoCase(rGenericTypes,"-1",",")>
								and		Generic_Type_ID in (#rGenericTypes#)
								</cfif>
				INNER JOIN  	Units_of_Measure uom 
							ON uom.Unit_Of_Measure_ID = cm.Contract_Quantity_UOM_IDX)
				INNER JOIN	Contract_Products cp
							ON (cp.Contract_Main_ID = cm.Contract_Main_ID))
				INNER JOIN	product_category_lob_active pcla
							ON (pcla.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID))
				INNER JOIN	 Contract_Product_Margin cpm
							ON ((cp.Contract_Products_ID = cpm.Contract_Product_ID) AND (cpm.Contract_Main_ID = cm.Contract_Main_ID) AND (cpm.Deleted = 0)))
				#PreserveSingleQuotes(sJoinClause)#
				WHERE	
							cp.Deleted	=	0
					AND		cm.Deleted	=	0
					AND		cm.Flagged_As_Purged=0
					AND		
					cs.Contract_Status_Type_ID >= 5
					AND
					cs.Contract_Status_Type_ID <= 6
					AND
					(
						((cm.Parent_Revised_Contract_Main_ID IS NULL) AND (cm.Revision_of_Contract_Main_ID IS NULL))
						OR
						(NOT(cm.Parent_Revised_Contract_Main_ID IS NULL) AND NOT(cm.Revision_of_Contract_Main_ID IS NULL) AND cs.Contract_Status_Type_ID > 4)
					)
					#PreserveSingleQuotes(sWhereClause)#
					#PreserveSingleQuotes(innerWhereClause)#
				#sGroupBy#, cpm.Product_Type_ID
			</CFQUERY>
			<cfset srqueryname="q_getReport">
		</CFCASE>
		<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
		Full Trade Detail
		xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
		<CFCASE value="3">
			
			
			
			
			<CFQUERY NAME="q_getReport" datasource="#application.datasource#">
				#sSelect#
					, 
					CASE 
						WHEN	cpm.Product_Type_ID = 1 THEN
							cpm.FPM
						WHEN	cpm.Product_Type_ID = 2 THEN
							cpm.REM
						WHEN	cpm.Product_Type_ID = 4 THEN
							cpm.GRM
						WHEN	cpm.Product_Type_ID = 5 THEN
							cpm.KPM
					END AS MarginPerLB
					, pcla.Item, pcla.Description
					, cpm.ACC, cpm.ICC, cpm.NCA
					, cpm.TPA
					, cpm.Product_Type_ID
					,CASE 
						WHEN	cpm.Product_Type_ID = 1 THEN
							cpm.FPR_LB
						WHEN	cpm.Product_Type_ID = 2 THEN
							cpm.RER_LB
						WHEN	cpm.Product_Type_ID = 4 THEN
							cpm.GRR_LB
						WHEN	cpm.Product_Type_ID = 5 THEN
							cpm.KPR_LB
					END AS ratePerLB
					, pt.Include_Trade
					, cla.Name, cla.ship_to, pdt.Rate
					, cd.Program_Weight
					, (CAST(cd.Program_Weight AS FLOAT)*CAST(pdt.Rate AS FLOAT)/100) AS WTPR
				FROM
				((
				#sJoinClauseBeginBraces#
				(((((Contract_Main cm 
				INNER JOIN  	Contract_Status_Types cs
							ON ((cs.Contract_Status_Type_ID = cm.Contract_Status_Type_IDX)
								<cfif NOT ListFindNoCase(rStatus,"-1",",")>
								AND		(cs.Contract_Status_Type_ID in (#rStatus#))
								</cfif>
								))
				INNER JOIN  	Program_Control_Panel_Options pt 
							ON ((pt.ProgramControl_Panel_Options_ID = cm.ProgramType_ID)
								<!------<cfif NOT ListFindNoCase(rProgramTypes,"-1",",")>
								AND		(pt.ProgramControl_Panel_Options_ID in (#rProgramTypes#))
								</cfif>----->								
								))
								INNER JOIN  Generic_Type ON Generic_Type.Generic_Type=pt.Generic_Type
								<cfif NOT ListFindNoCase(rGenericTypes,"-1",",")>
								and		Generic_Type_ID in (#rGenericTypes#)
								</cfif>
				INNER JOIN  	Units_of_Measure uom 
							ON uom.Unit_Of_Measure_ID = cm.Contract_Quantity_UOM_IDX)
				INNER JOIN	Contract_Products cp
							ON (cp.Contract_Main_ID = cm.Contract_Main_ID))
				INNER JOIN	product_category_lob_active pcla
							ON (pcla.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID))
				INNER JOIN	 Contract_Product_Margin cpm
							ON ((cp.Contract_Products_ID = cpm.Contract_Product_ID) AND (cpm.Contract_Main_ID = cm.Contract_Main_ID) AND (cpm.Deleted = 0)))
				#PreserveSingleQuotes(sJoinClause)#				
				LEFT JOIN ((Contract_Distributors cd 
							INNER JOIN Program_Distributors_Trade_Rate pdt
								ON (
								(pdt.BSA_Foodservice_Customers_ID = cd.BSA_Foodservice_Customers_ID) AND (pdt.Deleted = 0)
							))
							INNER JOIN customer_lob_active cla
							ON	(
							(cd.BSA_Foodservice_Customers_ID = cla.BSA_Foodservice_Customers_ID)
							))
					ON (cd.Contract_Main_ID=cm.Contract_Main_ID) AND (cd.Deleted=0) AND (pdt.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID)
				)
				WHERE	
							cp.Deleted	=	0
					AND		cm.Deleted	=	0
					AND		cm.Flagged_As_Purged=0
					AND		
					cs.Contract_Status_Type_ID >= 5
					AND
					cs.Contract_Status_Type_ID <= 6
					AND
					(
						((cm.Parent_Revised_Contract_Main_ID IS NULL) AND (cm.Revision_of_Contract_Main_ID IS NULL))
						OR
						(NOT(cm.Parent_Revised_Contract_Main_ID IS NULL) AND NOT(cm.Revision_of_Contract_Main_ID IS NULL) AND cs.Contract_Status_Type_ID > 4)
					)
					#PreserveSingleQuotes(sWhereClause)#
					#PreserveSingleQuotes(innerWhereClause)#
				#sGroupBy#, cpm.Product_Type_ID, cla.ship_to			
			</CFQUERY>
			<cfset srqueryname="q_getReport">			
</CFCASE>
	</CFSWITCH>
	
	
	