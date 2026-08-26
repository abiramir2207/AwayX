
	<cfset sSelect="distinct cs.Contract_Status_Type_Desc,cs.Contract_Status_Type_ID,pt.Created_Type,cm.Contract_Number,cm.Contract_Title,cm.Contract_Quantity,uom.Abbreviation,cm.Contract_Start_Date,cm.Contract_End_Date,cm.Contract_Main_ID">
	<cfset sWhereClause="">
	<cfset sJoinClause="">
	<cfset sJoinClauseBeginBraces="">
	
	<!--------------------Generate groupList like status,p---->
	<cfset sGroupByList="">
	<cfif Len(rSortBy) GT 0>
		<cfloop index="i" list="#rSortBy#" delimiters=",">
			<cfif i NEQ "-1">
			<cfif NOT ListFindNoCase(sGroupByList, i,",")>				
				<cfset sGroupByList=ListAppend(sGroupByList,i,",")>
			</cfif>
			</cfif>
		</cfloop>
	</cfif>
	<!--------------------End Generate groupList like status,p---->
	
	<!--------------------Add typegroup/qbrand/typecode/brand to groupList---->
	<cfif rFilterItems NEQ "none">
	<cfif Len(sGroupByList) GT 0>	
		<cfset sGroupByList=ListInsertAt(sGroupByList, 1,"#rFilterItems#",",")>
	<cfelse>
		<cfset sGroupByList="#rFilterItems#">
	</cfif>
	</cfif>
	<!--------------------End Add typegroup/qbrand/typecode/brand to groupList---->
	
	
	<!-------------Find field name corresponding to fFilter --------------------------------->
    <cfset sFilterField="">
	<cfswitch expression="#rFilterItems#">
		<cfcase value="typegroup">
			<cfset sFilterField="tg.Type_Group_Desc">
		</cfcase>
		<cfcase value="qbrand">
			<cfset sFilterField="Q_Brand_Legacy, qb.Q_Brand">
		</cfcase>						
		<cfcase value="typecode">
			<cfset sFilterField="tc.Type_Code_Desc">
		</cfcase>
		<cfcase value="brand">
			<cfset sFilterField="b.Brand_Name">
		</cfcase>
		<cfcase value="productGroup">
			<cfset sFilterField="pg.Product_Group_Desc">
		</cfcase>
		<cfcase value="product">
			<cfset sFilterField="pcla.Description">
		</cfcase>
	</cfswitch>
	<!-------------End Find field name corresponding to fFilter--------------------------------->
	
	<!--------------------Make exact group By clause 'sGroupBy' from groupList---->
	<cfset sGroupBy=sGroupByList>
	
	<cfset iIndex=ListFindNoCase(sGroupBy, "status",",")>	
	<cfif iIndex GT 0>
		<!-----<cfset sGroupBy=ListSetAt(sGroupBy, iIndex, "cs.Contract_Status_Type_Desc",",")>------->
		<cfset sGroupBy=ListSetAt(sGroupBy, iIndex, "cs.Contract_Status_Type_ID",",")>
	</cfif>
	<cfset iIndex=ListFindNoCase(sGroupBy, "programtype",",")>	
	<cfif iIndex GT 0>
		<cfset sGroupBy=ListSetAt(sGroupBy, iIndex, "pt.Created_Type",",")>
	</cfif>
	<cfset iIndex=ListFindNoCase(sGroupBy, "typegroup",",")>	
	<cfif iIndex GT 0>
		<!----sFilterField is the specific field corresponding to rFilter --------->
		<!----Type Group/Q Brand/Type Code/Brand--------->
		<cfset sGroupBy=ListSetAt(sGroupBy, iIndex, sFilterField,",")>
	</cfif>
	<cfset iIndex=ListFindNoCase(sGroupBy, "qbrand",",")>	
	<cfif iIndex GT 0>
		<!----sFilterField is the specific field corresponding to rFilter --------->
		<!----Type Group/Q Brand/Type Code/Brand--------->
		<cfset sGroupBy=ListSetAt(sGroupBy, iIndex, sFilterField,",")>
	</cfif>
	<cfset iIndex=ListFindNoCase(sGroupBy, "typecode",",")>	
	<cfif iIndex GT 0>
		<!----sFilterField is the specific field corresponding to rFilter --------->
		<!----Type Group/Q Brand/Type Code/Brand--------->
		<cfset sGroupBy=ListSetAt(sGroupBy, iIndex, sFilterField,",")>
	</cfif>
	<cfset iIndex=ListFindNoCase(sGroupBy, "brand",",")>	
	<cfif iIndex GT 0>
		<!----sFilterField is the specific field corresponding to rFilter --------->
		<!----Type Group/Q Brand/Type Code/Brand--------->
		<cfset sGroupBy=ListSetAt(sGroupBy, iIndex, sFilterField,",")>
	</cfif>
	<cfset iIndex=ListFindNoCase(sGroupBy, "productGroup",",")>	
	<cfif iIndex GT 0>
		<!----sFilterField is the specific field corresponding to rFilter --------->
		<!----Type Group/Q Brand/Type Code/Brand--------->
		<cfset sGroupBy=ListSetAt(sGroupBy, iIndex, sFilterField,",")>
	</cfif>
	<cfset iIndex=ListFindNoCase(sGroupBy, "product",",")>	
	<cfif iIndex GT 0>
		<!----sFilterField is the specific field corresponding to rFilter --------->
		<!----Type Group/Q Brand/Type Code/Brand--------->
		<cfset sGroupBy=ListSetAt(sGroupBy, iIndex, sFilterField,",")>
	</cfif>

	
	<!----
	<cfset sHeaderIDList=sGroupByList>
	<cfset sHeaderNameList=sGroupBy>	
	----->
	<cfset sHeaderIDList="">
	<cfset sHeaderNameList="">
	
	<cfif Len(sGroupBy) GT 0>	
		<cfset sGroupBy="Order By #sGroupBy#">
	</cfif>
	<!--------------------End Make exact group By clause 'sGroupBy' from groupList---->
	
	
	
	<!--------------------Make group By fields 'sGroupFieldList' from groupList---->
	<cfset sGroupFieldList=sGroupByList>
	<cfset iIndex=ListFindNoCase(sGroupFieldList, "status",",")>	
	<cfif iIndex GT 0>
		<cfset sGroupFieldList=ListSetAt(sGroupFieldList, iIndex, "Contract_Status_Type_Desc",",")>
	</cfif>
	<cfset iIndex=ListFindNoCase(sGroupFieldList, "programtype",",")>	
	<cfif iIndex GT 0>
		<cfset sGroupFieldList=ListSetAt(sGroupFieldList, iIndex, "Created_Type",",")>
	</cfif>
	<cfset iIndex=ListFindNoCase(sGroupFieldList, "typegroup",",")>	
	<cfif iIndex GT 0>
		<!----sFilterField is the specific field corresponding to rFilter --------->
		<!-------Get the fieldname part from it ('broker_name' from 'b.broker_name')----->
		<!----Type Group/Q Brand/Type Code/Brand--------->
		<cfif ListLen(sFilterField,".") GT 1>
			<cfset sGroupFieldList=ListSetAt(sGroupFieldList, iIndex, ListGetAt(sFilterField,2,"."),",")>
		<cfelse>
			<cfset sGroupFieldList=ListSetAt(sGroupFieldList, iIndex, sFilterField,",")>
		</cfif>
	</cfif>

	<cfset iIndex=ListFindNoCase(sGroupFieldList, "qbrand",",")>	
	<cfif iIndex GT 0>				
		<cfif ListLen(sFilterField,".") GT 1>
		<!----sFilterField is the specific field corresponding to rFilter --------->
		<!-------Get the fieldname part from it ('broker_name' from 'b.broker_name')----->
		<!----Type Group/Q Brand/Type Code/Brand--------->
			<cfset sGroupFieldList=ListSetAt(sGroupFieldList, iIndex, ListGetAt(sFilterField,2,"."),",")>
		<cfelse>
			<cfset sGroupFieldList=ListSetAt(sGroupFieldList, iIndex, sFilterField,",")>
		</cfif>
	</cfif>
	<cfset iIndex=ListFindNoCase(sGroupFieldList, "typecode",",")>	
	<cfif iIndex GT 0>
		<cfif ListLen(sFilterField,".") GT 1>
		<!----sFilterField is the specific field corresponding to rFilter --------->
		<!-------Get the fieldname part from it ('broker_name' from 'b.broker_name')----->
		<!----Type Group/Q Brand/Type Code/Brand--------->
			<cfset sGroupFieldList=ListSetAt(sGroupFieldList, iIndex, ListGetAt(sFilterField,2,"."),",")>
		<cfelse>
			<cfset sGroupFieldList=ListSetAt(sGroupFieldList, iIndex, sFilterField,",")>
		</cfif>
	</cfif>
	<cfset iIndex=ListFindNoCase(sGroupFieldList, "brand",",")>	
	<cfif iIndex GT 0>
		<cfif ListLen(sFilterField,".") GT 1>
		<!----sFilterField is the specific field corresponding to rFilter --------->
		<!-------Get the fieldname part from it ('broker_name' from 'b.broker_name')----->
		<!----Type Group/Q Brand/Type Code/Brand--------->
			<cfset sGroupFieldList=ListSetAt(sGroupFieldList, iIndex, ListGetAt(sFilterField,2,"."),",")>
		<cfelse>
			<cfset sGroupFieldList=ListSetAt(sGroupFieldList, iIndex, sFilterField,",")>
		</cfif>
	</cfif>
	<cfset iIndex=ListFindNoCase(sGroupFieldList, "productGroup",",")>	
	<cfif iIndex GT 0>
		<cfif ListLen(sFilterField,".") GT 1>
		<!----sFilterField is the specific field corresponding to rFilter --------->
		<!-------Get the fieldname part from it ('broker_name' from 'b.broker_name')----->
		<!----Type Group/Q Brand/Type Code/Brand--------->
			<cfset sGroupFieldList=ListSetAt(sGroupFieldList, iIndex, ListGetAt(sFilterField,2,"."),",")>
		<cfelse>
			<cfset sGroupFieldList=ListSetAt(sGroupFieldList, iIndex, sFilterField,",")>
		</cfif>
	</cfif>
	<cfset iIndex=ListFindNoCase(sGroupFieldList, "product",",")>	
	<cfif iIndex GT 0>
		<cfif ListLen(sFilterField,".") GT 1>
		<!----sFilterField is the specific field corresponding to rFilter --------->
		<!-------Get the fieldname part from it ('broker_name' from 'b.broker_name')----->
		<!----Type Group/Q Brand/Type Code/Brand--------->
			<cfset sGroupFieldList=ListSetAt(sGroupFieldList, iIndex, ListGetAt(sFilterField,2,"."),",")>
		<cfelse>
			<cfset sGroupFieldList=ListSetAt(sGroupFieldList, iIndex, sFilterField,",")>
		</cfif>
	</cfif>
	<!--------------------End Make group By fields 'sGroupFieldList' from groupList---->
	
	<!--------------Populate sHeaderIDList and sHeaderNameList --------------------------------->
	<!-----	
	sHeaderIDList and sHeaderNameList already have the groupsBy Columns
	<cfset sHeaderIDList=sGroupByList>
	<cfset sHeaderNameList=sGroupBy>
	--->
	<cfset productColumnHeaderID=fProductColumnHeaderID>
	<cfset productColumnFields=fProductColumnFields>	
	<cfloop index="i" list="#rColumnHeaderID#" delimiters=",">
		<cfif NOT ListFindNoCase(sGroupByList,i,",")>
			<cfset iIndex=ListFindNoCase(productColumnHeaderID,i,",")>
			<cfif iIndex>
				<cfset sHeaderIDList=ListAppend(sHeaderIDList,ListGetAt(productColumnHeaderID,iIndex,","))>
				<cfset sHeaderNameList=ListAppend(sHeaderNameList,ListGetAt(productColumnFields,iIndex,","))>
			</cfif>
		</cfif>
	</cfloop>
	
	<!--------------End Populate sHeaderIDList and sHeaderNameList ---------------------------------->
	
	
	<cfif Len(sFilterField) GT 0>
		<cfif NOT ListFindNoCase(sSelect,sFilterField,",")>
			<cfset sSelect=ListAppend(sSelect,sFilterField,",")>
		</cfif>
		<!---<cfset sSelect="#sSelect#,#sFilterField#">--->
	</cfif>
	
	<!--------------Check whether all user selected column headers are there in select list----------------->
	<cfloop index="i" list="#sHeaderNameList#" delimiters=",">
		<cfif NOT ListFindNoCase(sSelect,i,",")>
			<cfset sSelect=ListAppend(sSelect,i,",")>
		</cfif>
	</cfloop>
	<!--------------End Check whether all user selected column headers are there in select list----------------->
	
	<!----------------Remove "tablename." from column header lsit------------------>
	<cfloop index="i" list="#sHeaderNameList#" delimiters=",">	
		<cfif ListLen(i,".") GT 1>
			<cfset sHeaderNameList=ListSetAt(sHeaderNameList, ListFindNoCase(sHeaderNameList,i,","), ListGetAt(i,2,"."),",")>			
		</cfif>
	</cfloop>
	<!----------------End Remove "tablename." from column header lsit------------------>
	
	<!--------------------Get FromClause according to Item Level Filtering--------------->
	
	<!-----<cfset sFromClause="">------->
	<CFSET MainFiscalValuesQuery_Extra = "">
	<cfif NOT ListFindNoCase(rStatus,"-1",",") OR NOT ListFindNoCase(rGenericTypes,"-1",",")>
		<CFOUTPUT>
		<CFSAVECONTENT variable="MainFiscalValuesQuery_Extra">
		INNER JOIN Contract_Main
		ON
		Contract_Main.Contract_Main_ID = cp.Contract_Main_ID
		<cfif NOT ListFindNoCase(rStatus,"-1",",")>
		INNER JOIN Contract_Status_Types
		ON
		Contract_Status_Types.Contract_Status_Type_ID = Contract_Main.Contract_Status_Type_IDX
		AND
		Contract_Status_Types.Contract_Status_Type_ID in (#rStatus#)
		</cfif>
		<cfif NOT ListFindNoCase(rGenericTypes,"-1",",")>
		INNER JOIN  Program_Control_Panel_Options 
		ON 
		Program_Control_Panel_Options.ProgramControl_Panel_Options_ID=Contract_Main.ProgramType_ID
		INNER JOIN  Generic_Type 
		ON 
		Generic_Type.Generic_Type=Program_Control_Panel_Options.Generic_Type
		AND
		Generic_Type.Generic_Type_ID in (#rGenericTypes#)
		</cfif>
		</CFSAVECONTENT>
		</CFOUTPUT>				
	</cfif>
	
	
	<CFSET MainFiscalValuesQuery = "">
	<cfif rTypeGroups NEQ "">	
		<cfset sJoinClause="#sJoinClause# INNER JOIN  Type_Group_Desc tg ON pcla.Type_Group_Desc_ID=tg.Type_Group_Desc_ID) ">
		<cfset sJoinClauseBeginBraces="#sJoinClauseBeginBraces#(">
		
		
		<cfset sWhereClause="#sWhereClause# and tg.Deleted=0 and cp.Deleted=0">
		
		<cfif rTypeGroups NEQ "-1">
			<cfset sWhereClause="#sWhereClause# and	tg.Type_Group_Desc_ID='#rTypeGroups#'">
		</cfif>
		<cfset sSelect="#sSelect#,tg.Type_Group_Desc,tg.Type_Group_Desc_ID">
		
		<CFOUTPUT><cfsavecontent variable="sSelect">
		#sSelect#,
		0.00 AS VolumePerDay,
		0.00 AS ExpensePerDay,		
		0.00 AS MarginAverage,
		0.00 AS FiscalMarginDollar
		</cfsavecontent></CFOUTPUT>
		<CFOUTPUT><cfsavecontent variable="MainFiscalValuesQuery">
		SELECT cp.Contract_Main_ID, tg.Type_Group_Desc_ID,
				CAST(SUM(isNull(FPV_LB,0)+isNull(REV_LB,0)+isNull(GRV_LB,0))  AS FLOAT)/CAST(7 AS FLOAT) AS VolumePerDay,
				CAST(SUM(isNull(FPE,0)+isNull(REE,0)+isNull(GEE,0))  AS FLOAT)/CAST(7 AS FLOAT) AS ExpensePerDay,
				CAST(SUM(isNull(FPM,0)+isNull(REM,0)+isNull(GRM,0))/COUNT(cp.Contract_Products_ID)  AS FLOAT)/CAST(7 AS FLOAT) AS MarginAverage,
				CAST(SUM(isNull(FMW,0)+isNull(RMW,0)+isNull(GMW,0))  AS FLOAT)/CAST(7 AS FLOAT) AS FiscalMarginDollar
				FROM 	contract_product_margin cpm
						INNER JOIN Contract_Products cp
						ON
						(cpm.Contract_Product_ID=cp.Contract_Products_ID AND cp.Deleted = 0)
						#MainFiscalValuesQuery_Extra#
						INNER JOIN product_category_active pcla
						ON
						(cp.BSA_Foodservice_Items_Master_ID=pcla.BSA_Foodservice_Items_Master_ID)				
						INNER JOIN Type_Group_Desc tg
						ON
						pcla.Type_Group_Desc_ID=tg.Type_Group_Desc_ID
						<cfif rTypeGroups NEQ "-1">
							and	tg.Type_Group_Desc_ID='#rTypeGroups#'
						</cfif>
				WHERE 			
						cpm.Deleted=0
				Group By tg.Type_Group_Desc_ID, cp.Contract_Main_ID
		</cfsavecontent></CFOUTPUT>
	</cfif>
	<cfif rQBrands NEQ "">
		<!------
		<cfset sJoinClause="#sJoinClause# INNER JOIN (Q_Brand_Desc qb INNER JOIN Product_Q_Brand_Desc pqb ON pqb.Q_Brand_ID=qb.Q_Brand_ID and pqb.LOB='F' and pqb.Deleted=0) ON pcla.BSA_Foodservice_Items_Master_ID=pqb.BSA_Foodservice_Items_Master_ID) ">
		------------>
		
		<!------
		<cfset sJoinClause="#sJoinClause# INNER JOIN Product_Q_Brand_Desc pqb ON (pcla.BSA_Foodservice_Items_Master_ID=pqb.BSA_Foodservice_Items_Master_ID AND pqb.LOB='F') INNER JOIN Q_Brand_Desc qb ON (pqb.Q_Brand_ID=qb.Q_Brand_ID)) ">
		----------------->
		
		<cfsavecontent variable="q_brand_report_join_clause">
			<cfinclude template="#Application.Doc_Mapping#/data_files/created/#application.returned_customer_setting.qry_q_brand_report_join_clause#">
		</cfsavecontent>
		<cfset sJoinClause="#sJoinClause# #q_brand_report_join_clause#) ">
		
		<cfset sJoinClauseBeginBraces="#sJoinClauseBeginBraces#(">
		
		
		<cfset sWhereClause="#sWhereClause# and qb.Deleted=0 and cp.Deleted=0">
		<cfif rQBrands NEQ "-1">
			<cfset sWhereClause="#sWhereClause# and	qb.Q_Brand_ID='#rQBrands#'">
		</cfif>
		
		
		<CFSET Q_Brand_Join_Clause = q_brand_report_join_clause>
		<CFSET Q_Brand_Join_Clause = Replace(Q_Brand_Join_Clause, " pqb", " pqb1", "ALL")>
		<CFSET Q_Brand_Join_Clause = Replace(Q_Brand_Join_Clause, " qb", " qb1", "ALL")>
		<CFSET Q_Brand_Join_Clause = Replace(Q_Brand_Join_Clause, "pqb.", "pqb1.", "ALL")>
		<CFSET Q_Brand_Join_Clause = Replace(Q_Brand_Join_Clause, "qb.", "qb1.", "ALL")>
		
		<cfset sSelect="#sSelect#,qb.Q_Brand,qb.Q_Brand_ID">
		
		<CFOUTPUT><cfsavecontent variable="sSelect">
		#sSelect#,
		0.00 AS VolumePerDay,
		0.00 AS ExpensePerDay,		
		0.00 AS MarginAverage,
		0.00 AS FiscalMarginDollar
		</cfsavecontent></CFOUTPUT>
		<CFOUTPUT><cfsavecontent variable="MainFiscalValuesQuery">
		SELECT cp.Contract_Main_ID, qb.Q_Brand_ID,
				CAST(SUM(isNull(FPV_LB,0)+isNull(REV_LB,0)+isNull(GRV_LB,0))  AS FLOAT)/CAST(7 AS FLOAT) AS VolumePerDay,
				CAST(SUM(isNull(FPE,0)+isNull(REE,0)+isNull(GEE,0))  AS FLOAT)/CAST(7 AS FLOAT) AS ExpensePerDay,
				CAST(SUM(isNull(FPM,0)+isNull(REM,0)+isNull(GRM,0))/COUNT(cp.Contract_Products_ID)  AS FLOAT)/CAST(7 AS FLOAT) AS MarginAverage,
				CAST(SUM(isNull(FMW,0)+isNull(RMW,0)+isNull(GMW,0))  AS FLOAT)/CAST(7 AS FLOAT) AS FiscalMarginDollar
				FROM 	contract_product_margin cpm
						INNER JOIN Contract_Products cp
						ON
						(cpm.Contract_Product_ID=cp.Contract_Products_ID AND cp.Deleted = 0)
						#MainFiscalValuesQuery_Extra#
						INNER JOIN product_category_active pcla
						ON
						(cp.BSA_Foodservice_Items_Master_ID=pcla.BSA_Foodservice_Items_Master_ID)				
						#q_brand_report_join_clause#
				WHERE 			
						cpm.Deleted=0
						<cfif rQBrands NEQ "-1">
							and	qb.Q_Brand_ID='#rQBrands#'
						</cfif>
				Group By qb.Q_Brand_ID, cp.Contract_Main_ID
		</cfsavecontent></CFOUTPUT>
	</cfif>
	<cfif rTypeCodes NEQ "">
		
		<cfset sJoinClause="#sJoinClause# INNER JOIN  Type_Code_Desc tc ON pcla.Type_Code_Desc_ID=tc.Type_Code_Desc_ID) ">
		<cfset sJoinClauseBeginBraces="#sJoinClauseBeginBraces#(">
	
		
		<cfset sWhereClause="#sWhereClause#  and tc.Deleted=0 and cp.Deleted=0">
		<cfif rTypeCodes NEQ "-1">
			<cfset sWhereClause="#sWhereClause# and	tc.Type_Code_Desc_ID='#rTypeCodes#'">
		</cfif>
		<cfset sSelect="#sSelect#,tc.Type_Code_Desc,tc.Type_Code_Desc_ID">
		
		
		<CFOUTPUT><cfsavecontent variable="sSelect">
		#sSelect#,
		0.00 AS VolumePerDay,
		0.00 AS ExpensePerDay,		
		0.00 AS MarginAverage,
		0.00 AS FiscalMarginDollar
		</cfsavecontent></CFOUTPUT>
		<CFOUTPUT><cfsavecontent variable="MainFiscalValuesQuery">
		SELECT cp.Contract_Main_ID, tc.Type_Code_Desc_ID,
				CAST(SUM(isNull(FPV_LB,0)+isNull(REV_LB,0)+isNull(GRV_LB,0))  AS FLOAT)/CAST(7 AS FLOAT) AS VolumePerDay,
				CAST(SUM(isNull(FPE,0)+isNull(REE,0)+isNull(GEE,0))  AS FLOAT)/CAST(7 AS FLOAT) AS ExpensePerDay,
				CAST(SUM(isNull(FPM,0)+isNull(REM,0)+isNull(GRM,0))/COUNT(cp.Contract_Products_ID)  AS FLOAT)/CAST(7 AS FLOAT) AS MarginAverage,
				CAST(SUM(isNull(FMW,0)+isNull(RMW,0)+isNull(GMW,0))  AS FLOAT)/CAST(7 AS FLOAT) AS FiscalMarginDollar
				FROM 	contract_product_margin cpm
						INNER JOIN Contract_Products cp
						ON
						(cpm.Contract_Product_ID=cp.Contract_Products_ID AND cp.Deleted = 0)
						#MainFiscalValuesQuery_Extra#
						INNER JOIN product_category_active pcla
						ON
						(cp.BSA_Foodservice_Items_Master_ID=pcla.BSA_Foodservice_Items_Master_ID)				
						INNER JOIN Type_Code_Desc tc
						ON
						pcla.Type_Code_Desc_ID=tc.Type_Code_Desc_ID
						<cfif rTypeCodes NEQ "-1">
							and	tc.Type_Code_Desc_ID='#rTypeCodes#'
						</cfif>
				WHERE 			
						cpm.Deleted=0
				Group By tc.Type_Code_Desc_ID, cp.Contract_Main_ID
		</cfsavecontent></CFOUTPUT>
	</cfif>
	<cfif rBrands NEQ "">
		
		<cfset sJoinClause="#sJoinClause# INNER JOIN  Brand b ON pcla.Brand_ID=b.Brand_ID) ">
		<cfset sJoinClauseBeginBraces="#sJoinClauseBeginBraces#(">

		
		<cfset sWhereClause="#sWhereClause# and b.Deleted=0 and cp.Deleted=0">
		<cfif rBrands NEQ "-1">
			<cfset sWhereClause="#sWhereClause# and	b.Brand_ID='#rBrands#'">
		</cfif>
		<cfset sSelect="#sSelect#,b.Brand_Name,b.Brand_ID">
		
		
		<CFOUTPUT><cfsavecontent variable="sSelect">
		#sSelect#,
		0.00 AS VolumePerDay,
		0.00 AS ExpensePerDay,		
		0.00 AS MarginAverage,
		0.00 AS FiscalMarginDollar
		</cfsavecontent></CFOUTPUT>
		<CFOUTPUT><cfsavecontent variable="MainFiscalValuesQuery">
		SELECT cp.Contract_Main_ID, b.Brand_ID,
				CAST(SUM(isNull(FPV_LB,0)+isNull(REV_LB,0)+isNull(GRV_LB,0))  AS FLOAT)/CAST(7 AS FLOAT) AS VolumePerDay,
				CAST(SUM(isNull(FPE,0)+isNull(REE,0)+isNull(GEE,0))  AS FLOAT)/CAST(7 AS FLOAT) AS ExpensePerDay,
				CAST(SUM(isNull(FPM,0)+isNull(REM,0)+isNull(GRM,0))/COUNT(cp.Contract_Products_ID)  AS FLOAT)/CAST(7 AS FLOAT) AS MarginAverage,
				CAST(SUM(isNull(FMW,0)+isNull(RMW,0)+isNull(GMW,0))  AS FLOAT)/CAST(7 AS FLOAT) AS FiscalMarginDollar
				FROM 	contract_product_margin cpm
						INNER JOIN Contract_Products cp
						ON
						(cpm.Contract_Product_ID=cp.Contract_Products_ID AND cp.Deleted = 0)
						#MainFiscalValuesQuery_Extra#
						INNER JOIN product_category_active pcla
						ON
						(cp.BSA_Foodservice_Items_Master_ID=pcla.BSA_Foodservice_Items_Master_ID)				
						INNER JOIN Brand b
						ON
						pcla.Brand_ID=b.Brand_ID
						<cfif rBrands NEQ "-1">
							and	b.Brand_ID='#rBrands#'
						</cfif>
				WHERE 			
						cpm.Deleted=0
				Group By b.Brand_ID, cp.Contract_Main_ID
		</cfsavecontent></CFOUTPUT>
	</cfif>
	<cfif rProductgroups NEQ "">
		
		<cfset sJoinClause="#sJoinClause# INNER JOIN  BSA_Product_Group pg ON pcla.BSA_Product_Group_ID=pg.BSA_Product_Group_ID) ">
		<cfset sJoinClauseBeginBraces="#sJoinClauseBeginBraces#(">

		
		<cfset sWhereClause="#sWhereClause# and pg.Deleted=0 and cp.Deleted=0">
		<cfif rProductgroups NEQ "-1">
			<cfset sWhereClause="#sWhereClause# and	pg.BSA_Product_Group_ID='#rProductgroups#'">
		</cfif>
		<cfset sSelect="#sSelect#,pg.Product_Group_Desc,pg.BSA_Product_Group_ID">
		
		
		<CFOUTPUT><cfsavecontent variable="sSelect">
		#sSelect#,
		0.00 AS VolumePerDay,
		0.00 AS ExpensePerDay,		
		0.00 AS MarginAverage,
		0.00 AS FiscalMarginDollar
		</cfsavecontent></CFOUTPUT>
		<CFOUTPUT><cfsavecontent variable="MainFiscalValuesQuery">
		SELECT cp.Contract_Main_ID, pg.BSA_Product_Group_ID,
				CAST(SUM(isNull(FPV_LB,0)+isNull(REV_LB,0)+isNull(GRV_LB,0))  AS FLOAT)/CAST(7 AS FLOAT) AS VolumePerDay,
				CAST(SUM(isNull(FPE,0)+isNull(REE,0)+isNull(GEE,0))  AS FLOAT)/CAST(7 AS FLOAT) AS ExpensePerDay,
				CAST(SUM(isNull(FPM,0)+isNull(REM,0)+isNull(GRM,0))/COUNT(cp.Contract_Products_ID)  AS FLOAT)/CAST(7 AS FLOAT) AS MarginAverage,
				CAST(SUM(isNull(FMW,0)+isNull(RMW,0)+isNull(GMW,0))  AS FLOAT)/CAST(7 AS FLOAT) AS FiscalMarginDollar
				FROM 	contract_product_margin cpm
						INNER JOIN Contract_Products cp
						ON
						(cpm.Contract_Product_ID=cp.Contract_Products_ID AND cp.Deleted = 0)
						#MainFiscalValuesQuery_Extra#
						INNER JOIN product_category_active pcla
						ON
						(cp.BSA_Foodservice_Items_Master_ID=pcla.BSA_Foodservice_Items_Master_ID)				
						INNER JOIN BSA_Product_Group pg
						ON
						pcla.BSA_Product_Group_ID=pg.BSA_Product_Group_ID
						<cfif rProductgroups NEQ "-1">
							and	pg.BSA_Product_Group_ID='#rProductgroups#'
						</cfif>
				WHERE 			
						cpm.Deleted=0
				Group By pg.BSA_Product_Group_ID, cp.Contract_Main_ID
		</cfsavecontent></CFOUTPUT>
	</cfif>
	<cfif rProducts NEQ "">
		
		<cfset sWhereClause="#sWhereClause# and cp.Deleted=0">
		<cfset sSelect="#sSelect#,pcla.Description,pcla.BSA_Foodservice_Items_Master_ID">
		
		
		<CFOUTPUT><cfsavecontent variable="sSelect">
		#sSelect#,
		0.00 AS VolumePerDay,
		0.00 AS ExpensePerDay,		
		0.00 AS MarginAverage,
		0.00 AS FiscalMarginDollar
		</cfsavecontent></CFOUTPUT>
		<CFOUTPUT><cfsavecontent variable="MainFiscalValuesQuery">
		SELECT cp.Contract_Main_ID, pcla.BSA_Foodservice_Items_Master_ID,
				CAST(SUM(isNull(FPV_LB,0)+isNull(REV_LB,0)+isNull(GRV_LB,0))  AS FLOAT)/CAST(7 AS FLOAT) AS VolumePerDay,
				CAST(SUM(isNull(FPE,0)+isNull(REE,0)+isNull(GEE,0))  AS FLOAT)/CAST(7 AS FLOAT) AS ExpensePerDay,
				CAST(SUM(isNull(FPM,0)+isNull(REM,0)+isNull(GRM,0))/COUNT(cp.Contract_Products_ID)  AS FLOAT)/CAST(7 AS FLOAT) AS MarginAverage,
				CAST(SUM(isNull(FMW,0)+isNull(RMW,0)+isNull(GMW,0))  AS FLOAT)/CAST(7 AS FLOAT) AS FiscalMarginDollar
				FROM 	contract_product_margin cpm
						INNER JOIN Contract_Products cp
						ON
						(cpm.Contract_Product_ID=cp.Contract_Products_ID AND cp.Deleted = 0)
						#MainFiscalValuesQuery_Extra#
						INNER JOIN product_category_active pcla
						ON
						(cp.BSA_Foodservice_Items_Master_ID=pcla.BSA_Foodservice_Items_Master_ID)
				WHERE 			
						cpm.Deleted=0
				Group By pcla.BSA_Foodservice_Items_Master_ID, cp.Contract_Main_ID
		</cfsavecontent></CFOUTPUT>
	</cfif>
	<!--------------------End Get FromClause according to Item Level Filtering--------------->

	
	<!------------------------------------ Add the variables fields to list ---------------------------->
	<cfset anyVariableFields=false>
	<cfset productColumnHeaderID=ListAppend(vProductColumnHeaderID,",")>
	<cfset productColumnFields=ListAppend(vProductColumnFields,",")>	
	<cfloop index="i" list="#rColumnHeaderID#" delimiters=",">
		<cfif NOT ListFindNoCase(sGroupByList,i,",")>
			<cfset iIndex=ListFindNoCase(productColumnHeaderID,i,",")>
			<cfif iIndex>
				<cfset sHeaderIDList=ListAppend(sHeaderIDList,ListGetAt(productColumnHeaderID,iIndex,","))>
				<cfset tempVal=ListGetAt(productColumnFields,iIndex,",")>
				<cfif ListLen(tempVal,".") GT 1>
					<cfset tempVal=ListGetAt(tempVal,2,".")>
				</cfif>
				<cfset sHeaderNameList=ListAppend(sHeaderNameList,tempVal)>
				<cfset anyVariableFields=true>
			</cfif>
		</cfif>
	</cfloop>
	<!------------------------------------ End Add the variables fields to list ---------------------------->
	
	<cfif anyVariableFields>
	<CFOUTPUT><cfsavecontent variable="sJoinClause">
						#sJoinClause# 
						--LEFT JOIN Fiscal_Year fy 
						LEFT JOIN Fiscal_Next_Year fy
						ON 
						(DATEDIFF(day,GetDate(),fy.End_Date) >= 0
						AND fy.Deleted=0
						)
	</cfsavecontent></CFOUTPUT>
	
	<CFOUTPUT><cfsavecontent variable="sSelect">
	#sSelect#, 
	fy.end_date as fyEndDate, fy.start_date as fyStartDate,
	fy.Position as fyPosition,
	CASE 
	   WHEN (DATEDIFF(Day,cm.Contract_Start_Date,fy.start_date) >= 0) AND (DATEDIFF(Day,cm.Contract_End_Date,fy.end_date) >= 0) THEN
		CASE 
		   WHEN (DATEDIFF(Day,fy.start_date,cm.Contract_End_Date) + 1) >= 0 THEN
			(DATEDIFF(Day,fy.start_date,cm.Contract_End_Date) + 1)	   
		END
	   WHEN (DATEDIFF(Day,cm.Contract_Start_Date,fy.start_date) >= 0) AND (DATEDIFF(Day,cm.Contract_End_Date,fy.end_date) < 0) THEN
		CASE 
		   WHEN (DATEDIFF(Day,fy.start_date,fy.end_date) + 1) >= 0 THEN
			(DATEDIFF(Day,fy.start_date,fy.end_date) + 1)	   
		END
	   WHEN (DATEDIFF(Day,cm.Contract_Start_Date,fy.start_date) < 0) AND (DATEDIFF(Day,cm.Contract_End_Date,fy.end_date) >= 0) THEN
		CASE 
		   WHEN (DATEDIFF(Day,cm.Contract_Start_Date,cm.Contract_End_Date) + 1) >= 0 THEN
			(DATEDIFF(Day,cm.Contract_Start_Date,cm.Contract_End_Date) + 1)	   
		END
	   WHEN (DATEDIFF(Day,cm.Contract_Start_Date,fy.start_date) < 0) AND (DATEDIFF(Day,cm.Contract_End_Date,fy.end_date) < 0) THEN
		CASE 
		   WHEN (DATEDIFF(Day,cm.Contract_Start_Date,fy.end_date) + 1) >= 0 THEN
			(DATEDIFF(Day,cm.Contract_Start_Date,fy.end_date) + 1)
		END
	END AS PeriodLength
	</cfsavecontent></CFOUTPUT>
	</cfif>
	

	
	<cfset sSelect="Select #sSelect#">	
	<cfset sWhereClause="#sWhereClause# and DATEDIFF(day,cm.Contract_Start_Date,cm.Contract_End_Date) >= 0">
	
	<cfset DescSeparator=", ">
	<cfinclude template="schReportDescription.cfm">

	<cfswitch expression="#rFilter#">		
		<cfcase value="none">	
			<CFIF Len(MainFiscalValuesQuery) GT 0>
			<CFQUERY NAME="MainFiscalValues" DATASOURCE="#application.datasource#">
			#PreserveSingleQuotes(MainFiscalValuesQuery)#
			</CFQUERY>
			</CFIF>
			<CFQUERY NAME="q_getReport" datasource="#application.datasource#">
				#PreserveSingleQuotes(sSelect)#
				From 	
				#sJoinClauseBeginBraces#(((((Contract_Status_Types cs INNER JOIN Contract_Main cm ON  cs.Contract_Status_Type_ID=cm.Contract_Status_Type_IDX)	 
				INNER JOIN  Program_Control_Panel_Options pt ON pt.ProgramControl_Panel_Options_ID=cm.ProgramType_ID)
				INNER JOIN  Generic_Type ON Generic_Type.Generic_Type=pt.Generic_Type
				INNER JOIN  Units_of_Measure uom ON uom.Unit_Of_Measure_ID=cm.Contract_Quantity_UOM_IDX)
				LEFT JOIN  	Contract_Products cp ON cp.Contract_Main_ID=cm.Contract_Main_ID)
				LEFT JOIN	contract_product_margin ON contract_product_margin.Contract_Product_ID = cp.Contract_Products_ID AND contract_product_margin.Deleted=0
				--LEFT JOIN  product_category_lob_active pcla ON pcla.BSA_Foodservice_Items_Master_ID=cp.BSA_Foodservice_Items_Master_ID)					
				LEFT JOIN  product_category_active pcla ON pcla.BSA_Foodservice_Items_Master_ID=cp.BSA_Foodservice_Items_Master_ID)
				#PreserveSingleQuotes(sJoinClause)#
				Where cm.Deleted=0
				and		cm.Flagged_As_Purged=0
				and 	pt.Deleted=0
				and		cs.Contract_Status_Type_ID > 3
				--and		cs.Contract_Status_Type_ID <> 1
				--and		cs.Contract_Status_Type_ID <> 3
				and
				(
					((cm.Parent_Revised_Contract_Main_ID IS NULL) AND (cm.Revision_of_Contract_Main_ID IS NULL))
					OR
					(NOT(cm.Parent_Revised_Contract_Main_ID IS NULL) AND NOT(cm.Revision_of_Contract_Main_ID IS NULL) AND cs.Contract_Status_Type_ID > 4)
				)
				#PreserveSingleQuotes(sWhereClause)#
				<cfif NOT ListFindNoCase(rStatus,"-1",",")>
				and		cs.Contract_Status_Type_ID in (#rStatus#)
				</cfif>
				<cfif NOT ListFindNoCase(rBusinessSegment,"-1",",")>
				and		cm.Business_Segment_ID in (#rBusinessSegment#)
				</cfif>
				<cfif NOT ListFindNoCase(rDiscountIdentifier,"-1",",")>
				and		pt.Discount_Identifier_ID in (#rDiscountIdentifier#)
				</cfif>
				<cfif NOT ListFindNoCase(rGenericTypes,"-1",",")>
				and		Generic_Type_ID in (#rGenericTypes#)
				</cfif>
				<cfif NOT ListFindNoCase(rProducts,"-1",",") AND rProducts NEQ "">
				and		pcla.BSA_Foodservice_Items_Master_ID in (#ListQualify(rProducts, "'", ",")#)
				</cfif>
				<cfif rOutputStartDate NEQ "" AND rOutputStartDateOperatorSymbol NEQ "">
				and		DateDiff(d, '#rOutputStartDate#', cm.Contract_Start_Date) #rOutputStartDateOperatorSymbol# 0
				</cfif>
				<cfif rOutputEndDate NEQ "" AND rOutputEndDateOperatorSymbol NEQ "">
				and		DateDiff(d, '#rOutputEndDate#', cm.Contract_End_Date) #rOutputEndDateOperatorSymbol# 0
				</cfif>
				#sGroupBy#
			</CFQUERY>
			<cfset srqueryname="q_getReport">
			<!-----<cfinclude template="schSendProductReport.cfm">------->
		</cfcase>
		<cfdefaultcase>
		errror
		</cfdefaultcase>
	</cfswitch>