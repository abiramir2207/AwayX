<cfif checkcolheader is "fiscalvolume">
	<cfset dSelect="distinct cm.Contract_Number,cm.Contract_Main_ID,id.Invoice_Date, CAST(id.Pounds_Invoiced AS FLOAT)as Pounds_Invoiced, CAST(id.LB_Unit_Price AS FLOAT)*Pounds_Invoiced as Price">
	<cfset oSelect="distinct cm.Contract_Number,cm.Contract_Main_ID,bb.Item_Volume_Paid_LB,bb.BB_Start_Date,bb.BB_End_Date,CASE WHEN ((DATEDIFF(Day, bb.BB_start_date, bb.BB_End_Date) + 1) >= 0 AND bb.Item_Volume_Paid_LB IS NOT NULL) THEN (bb.Item_Volume_paid_LB / (DATEDIFF(Day, bb.BB_start_date, bb.BB_End_Date) + 1)) END AS VolumePerday,cm.product_id">
<cfelseif checkcolheader is "fiscalexpense">
	<cfset dSelect="distinct cm.Contract_Number,cm.Contract_Main_ID,id.Invoice_Date,  (cm.Price * CAST(id.Pounds_Invoiced AS FLOAT))as Price_Invoiced,id.BSA_Foodservice_Items_Master_ID,cm.Product_Type_ID">
	<cfset oSelect="distinct cm.Contract_Number,cm.Contract_Main_ID,bb.Item_Total_Paid,bb.BB_Start_Date,bb.BB_End_Date,CASE WHEN ((DATEDIFF(Day, bb.BB_start_date, bb.BB_End_Date) + 1) >= 0 AND bb.Item_Total_Paid IS NOT NULL) THEN (bb.Item_Total_Paid / (DATEDIFF(Day, bb.BB_start_date, bb.BB_End_Date) + 1)) END AS PricePerday">
<cfelse>
	<cfset oSelect="">
	<cfset dSelect="">
</cfif>

<!--- 
<cfoutput>#dSelect#</cfoutput><cfabort> --->

<cfif checkcolheader is "fiscalmargin">
	<cfset sSelect="cm.Contract_Status_Type_Desc,cm.Contract_Status_Type_IDX,cm.Created_Type,cm.Generic_Type_Id,cm.Contract_Number,cm.Contract_Title,cm.Contract_Start_Date,cm.Contract_End_Date,cm.Contract_Main_ID">
<cfelse>
	<cfset sSelect=" cm.Contract_Status_Type_Desc,cm.Contract_Status_Type_IDX,cm.Created_Type,cm.Generic_Type_Id,cm.Contract_Number,cm.Contract_Title,cm.Contract_Start_Date,cm.Contract_End_Date,cm.Contract_Main_ID,cm.PTEC as programExpense,((itemvolume/7) * (DATEDIFF(Day, cm.Approval_Start_Date, cm.Approval_End_Date) + 1)) as itemvolume,cm.product_id,CAST(cm.PTEC AS FLOAT) as programExpense">
</cfif>


<!--- <cfset groupbyselect = "distinct cm.Contract_Status_Type_Desc,cm.Contract_Status_Type_IDX,cm.Generic_Type,cm.Generic_Type_Id,cm.Contract_Number,cm.Contract_Title,cm.Contract_Start_Date,cm.Contract_End_Date,cm.Contract_Main_ID,cm.Volume_LB as programVolume,cm.PTEC as programExpense,cm.Program_Weight,cm.customer_id,cm.product_id"> --->

<cfset dList = "">
<cfset oList = "">
<cfif rgenerictypes NEQ "-1">
	<cfloop list="#rgenerictypes#" index="i" delimiters=",">
		<cfif i IS 1 or i is 5>
			<cfset dList = ListAppend(dList,i,",")>
		</cfif>
		<cfif i IS 2 or i is 3 or i is 4>
			<cfset oList = ListAppend(oList,i,",")>
		</cfif>
	</cfloop>
<cfelse>
	<cfset dList = "1,5">
	<cfset oList = "2,3,4">

</cfif>

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
	
	<!--- <cfoutput>#rFilterItems#</cfoutput><cfabort> --->
	<!--------------------End Add typegroup/qbrand/typecode/brand to groupList---->
	
	
	<!-------------Find field name corresponding to fFilter --------------------------------->
	<cfset sFilterField="">
	<cfswitch expression="#rFilterItems#">
		<cfcase value="typegroup">
			<cfset sFilterField="cm.Type_Group_Desc">
		</cfcase>
		<cfcase value="qbrand">
			<!--- <cfset sFilterField="Q_Brand_Legacy, qb.Q_Brand"> --->
			<cfset sFilterField="Q_Brand_Legacy,cm.Q_Brand_Desc">
		</cfcase>						
		<cfcase value="typecode">
			<cfset sFilterField="cm.Type_Code_Desc">
		</cfcase>
		<cfcase value="brand">
			<cfset sFilterField="cm.Brand_Name">
		</cfcase>
		<cfcase value="product">
			<cfset sFilterField="cm.Description">
		</cfcase>
	</cfswitch>
	<!-------------End Find field name corresponding to fFilter--------------------------------->
	
	<!--------------------Make exact group By clause 'sGroupBy' from groupList---->
	<cfset sGroupBy=sGroupByList>
	
	<cfset iIndex=ListFindNoCase(sGroupBy, "status",",")>	
	<cfif iIndex GT 0>
		<!-----<cfset sGroupBy=ListSetAt(sGroupBy, iIndex, "cs.Contract_Status_Type_Desc",",")>------->
		<cfset sGroupBy=ListSetAt(sGroupBy, iIndex, "cm.Contract_Status_Type_IDX",",")>
	</cfif>
	<cfset iIndex=ListFindNoCase(sGroupBy, "programtype",",")>	
	<cfif iIndex GT 0>
		<cfset sGroupBy=ListSetAt(sGroupBy, iIndex, "cm.Created_Type",",")>
	</cfif>
	<cfset iIndex=ListFindNoCase(sGroupBy, "typegroup",",")>	
	<cfif iIndex GT 0>
		<!----sFilterField is the specific field corresponding to rFilter --------->
		<!----Type Group/Q Brand/Type Code/Brand--------->
		<cfset sGroupBy=ListSetAt(sGroupBy, iIndex, sFilterField,",")>
	</cfif>
	
	<cfset nonegroupbylist = sGroupBy>
	
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
<CFSET fProductColumnFields="cm.Created_Type,cm.Contract_Number,cm.Contract_Title,cm.Contract_Start_Date,cm.Contract_End_Date">
	<cfset productColumnHeaderID=fproductColumnHeaderID>
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
	
	
	<cfif rQBrands NEQ "">
		<cfset sSelect="#sSelect#,cm.Q_Brand_Desc,cm.Q_Brand_id">
		<cfset dselect = "#dSelect#,cm.Q_Brand_id">
		<cfset oselect = "#oSelect#,cm.Q_Brand_id">
		<cfif rQBrands NEQ "-1">
			<cfset sWhereClause="#sWhereClause# and	cm.Q_Brand_id='#rQBrands#'">
		</cfif>
	</cfif>
	
	<cfif rBrands NEQ "">
		<cfset sSelect="#sSelect#,cm.Brand_Name,cm.Brand_id">
		<cfset dselect = "#dSelect#,cm.Brand_id">
		<cfset oselect = "#oSelect#,cm.Brand_id">
		<cfif rBrands NEQ "-1">
			<cfset sWhereClause="#sWhereClause# and	cm.Brand_id='#rBrands#'">
		</cfif>
	</cfif>
	

	<cfif rTypeCodes NEQ "">
		<cfset sSelect="#sSelect#,Type_Code_Desc,cm.Type_Code_Desc_id">
		<cfset dselect = "#dSelect#,cm.Type_Code_Desc_id">
		<cfset oselect = "#oSelect#,cm.Type_Code_Desc_id">
		<cfif rTypeCodes NEQ "-1">
			<cfset sWhereClause="#sWhereClause# and	cm.Type_Code_Desc_id='#rTypeCodes#'">
		</cfif>
	</cfif>
	
	<cfif rTypeGroups NEQ "">
		<cfset sSelect="#sSelect#,Type_Group_Desc,cm.Type_Group_Desc_id">
		<cfset dselect = "#dSelect#,cm.Type_Group_Desc_id">
		<cfset oselect = "#oSelect#,cm.Type_Group_Desc_id">
		<cfif rTypeGroups NEQ "-1">
			<cfset sWhereClause="#sWhereClause# and	cm.Type_Group_Desc_id='#rTypeGroups#'">
			</cfif>
	</cfif>
	<cfif rProducts NEQ "">
		<cfset sSelect="#sSelect#,Description,cm.Product_id">
		<cfset dselect = "#dSelect#,cm.Product_id">
		<cfset oselect = "#oSelect#,cm.Product_id">
		<cfif rProducts NEQ "-1">
			<cfset sWhereClause="#sWhereClause# and	cm.Product_id='#rProducts#'">
			</cfif>
	</cfif>
	
	<cfif Len(sFilterField) GT 0>
		<cfif NOT ListFindNoCase(sSelect,sFilterField,",")>
			<cfset sSelect=ListAppend(sSelect,sFilterField,",")>
		</cfif>
	</cfif>
	
	<!--------------------End Get FromClause according to Item Level Filtering--------------->
	
	
	<!------------------------------------ Add the variables fields to list ---------------------------->
	<cfset anyVariableFields=false>
	<cfset productColumnHeaderID=vproductColumnHeaderID>
	<cfset productColumnFields=vproductColumnFields>
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
	
	<!--- <cfoutput>#sHeaderIDList#,#productColumnHeaderID#</cfoutput> --->
	<!------------------------------------ End Add the variables fields to list ---------------------------->
	<cfset mselect = sSelect>
	<cfset sSelect="Select distinct #sSelect#">	
	
	
	<cfset DescSeparator=", ">
	<cfinclude template="schReportDescription.cfm">
	<cfif rFilterItems is "none">
		<CFQUERY NAME="q_getReport" datasource="#application.datasource#">
			Select distinct 
				cm.Contract_Status_Type_Desc,cm.Contract_Status_Type_IDX,
				cm.Created_Type,cm.Generic_Type_Id,cm.Contract_Number,cm.Contract_Title,
				cm.Contract_Start_Date,cm.Contract_End_Date,cm.Contract_Main_ID
			From	program_join_products cm
			WHERE  0=0
			<cfif NOT ListFindNoCase(rStatus,"-1",",")>
				and cm.Contract_Status_Type_IDX in (#rStatus#)
			</cfif>
			<cfif NOT ListFindNoCase(rBusinessSegment,"-1",",")>
				and cm.Business_Segment_ID in (#rBusinessSegment#)
			</cfif>
			<cfif NOT ListFindNoCase(rDiscountIdentifier,"-1",",")>
				AND	cm.Discount_Identifier_ID IN (#rDiscountIdentifier#)
			</cfif>
			<cfif NOT ListFindNoCase(rGenericTypes,"-1",",")>
				and		Generic_Type_ID in (#rGenericTypes#)
			</cfif>
			<cfif NOT ListFindNoCase(rProducts,"-1",",") AND rProducts NEQ "">
			and		cm.BSA_Foodservice_Items_Master_ID in (#ListQualify(rProducts, "'", ",")#)
			</cfif>
			and 
			(
				(cm.Approval_Start_Date BETWEEN '#StartDate#' AND '#EndDate#') 
				OR
				(cm.Approval_End_Date BETWEEN '#StartDate#' AND '#EndDate#') 
				OR
				(cm.Approval_Start_Date < '#StartDate#') AND (cm.Approval_End_Date > '#EndDate#')
			)
			<cfif Len(nonegroupbylist) GT 0>
			order by #nonegroupbylist# 
			</cfif>
		</cfquery>
		<cfset srqueryname="q_getReport">
	<cfelse>
	
		<CFQUERY NAME="q_getReport" datasource="#application.datasource#">
		#PreserveSingleQuotes(sSelect)#
				<cfif checkcolheader is "fiscalmargin">
				,CAST(SUM(isNull(cpm.FMW,0)+isNull(cpm.RMW,0)+isNull(cpm.GMW,0))  AS FLOAT)/CAST(7 AS FLOAT) AS FiscalMarginDollar
				</cfif>
		From	program_join_products cm
				<cfif checkcolheader is "fiscalmargin">
				INNER JOIN
				dbo.Contract_Product_Margin cpm ON cm.Contract_Main_ID = cpm.Contract_Main_ID
				</cfif>
		WHERE  0=0
				<cfif NOT ListFindNoCase(rStatus,"-1",",")>
				and cm.Contract_Status_Type_IDX in (#rStatus#)
				</cfif>
				<cfif NOT ListFindNoCase(rBusinessSegment,"-1",",")>
				and cm.Business_Segment_ID in (#rBusinessSegment#)
				</cfif>
				<cfif NOT ListFindNoCase(rDiscountIdentifier,"-1",",")>
				AND	cm.Discount_Identifier_ID IN (#rDiscountIdentifier#)
				</cfif>
				<cfif NOT ListFindNoCase(rGenericTypes,"-1",",")>
				and		Generic_Type_ID in (#rGenericTypes#)
				</cfif>
				<cfif NOT ListFindNoCase(rProducts,"-1",",") AND rProducts NEQ "">
				and		cm.BSA_Foodservice_Items_Master_ID in (#ListQualify(rProducts, "'", ",")#)
				</cfif>
				and 
				(
				(cm.Approval_Start_Date BETWEEN '#StartDate#' AND '#EndDate#') 
				OR
				(cm.Approval_End_Date BETWEEN '#StartDate#' AND '#EndDate#') 
				OR
				(cm.Approval_Start_Date < '#StartDate#') AND (cm.Approval_End_Date > '#EndDate#')
				)
				#PreserveSingleQuotes(sWhereClause)#	
				<cfif checkcolheader is "fiscalmargin">
					group by #PreserveSingleQuotes(mSelect)#
				</cfif>
				#sGroupBy#
		</cfquery>
		<cfset srqueryname="q_getReport">
		
		<cfif len(checkcolheader) GT 0>
			<cfif checkcolheader is "fiscalvolume">
				<cfif listlen(dlist) GT 0>
					<CFQUERY NAME="dgetReport" datasource="#application.datasource#">
						select 	#PreserveSingleQuotes(dSelect)#
						From	program_join_products cm 
						INNER JOIN INVOICE_JOIN_DETAIL id
						ON
						id.BSA_Foodservice_Customers_ID = cm.Customer_Id
						AND
						cm.Product_Id = id.BSA_Foodservice_Items_Master_ID
						AND
						(( id.Invoice_Date >= '#StartDate#') AND (id.Invoice_Date <= '#EndDate#'))
						WHERE  0=0
						<cfif NOT ListFindNoCase(rStatus,"-1",",")>
							and cm.Contract_Status_Type_IDX in (#rStatus#)				
						</cfif>
						<cfif NOT ListFindNoCase(rBusinessSegment,"-1",",")>
							and cm.Business_Segment_ID in (#rBusinessSegment#)
						</cfif>
						<cfif NOT ListFindNoCase(rDiscountIdentifier,"-1",",")>
							AND	cm.Discount_Identifier_ID IN (#rDiscountIdentifier#)
						</cfif>
						<cfif NOT ListFindNoCase(rProducts,"-1",",") AND rProducts NEQ "">
						and		cm.BSA_Foodservice_Items_Master_ID in (#ListQualify(rProducts, "'", ",")#)
						</cfif>
						and		cm.Generic_Type_ID in (#dlist#)
						and 
						(
							(cm.Approval_Start_Date BETWEEN '#StartDate#' AND '#EndDate#') 
							OR
							(cm.Approval_End_Date BETWEEN '#StartDate#' AND '#EndDate#') 
							OR
							(cm.Approval_Start_Date < '#StartDate#') AND (cm.Approval_End_Date > '#EndDate#')
						)
						#PreserveSingleQuotes(sWhereClause)#		
					</CFQUERY>
					<cfset dqueryname = "dgetReport">
				</cfif>
				<cfif listlen(olist) GT 0>
					<CFQUERY NAME="ogetReport" datasource="#application.datasource#">
						select 	#PreserveSingleQuotes(oSelect)#
						From	#sJoinClauseBeginBraces# program_join_products cm 
								INNER JOIN Billback_Info bb
								ON
								bb.program_id = cm.contract_main_id
								and cm.product_id = bb.billback_product_id
								AND
								(
									(bb.BB_Start_Date BETWEEN '#StartDate#' AND '#EndDate#') 
									OR
									(bb.BB_End_Date BETWEEN '#StartDate#' AND '#EndDate#') 
									OR
									(bb.BB_Start_Date < '#StartDate#') AND (bb.BB_End_Date > '#EndDate#')
								)
						WHERE  0=0
								<cfif NOT ListFindNoCase(rStatus,"-1",",")>
									and cm.Contract_Status_Type_IDX in (#rStatus#)
								</cfif>
								<cfif NOT ListFindNoCase(rBusinessSegment,"-1",",")>
									and cm.Business_Segment_ID in (#rBusinessSegment#)
								</cfif>
								<cfif NOT ListFindNoCase(rDiscountIdentifier,"-1",",")>
									AND	cm.Discount_Identifier_ID IN (#rDiscountIdentifier#)
								</cfif>
								<cfif NOT ListFindNoCase(rProducts,"-1",",") AND rProducts NEQ "">
								and		cm.BSA_Foodservice_Items_Master_ID in (#ListQualify(rProducts, "'", ",")#)
								</cfif>
								and		cm.Generic_Type_ID in (#olist#)
								and 
								(
									(cm.Approval_Start_Date BETWEEN '#StartDate#' AND '#EndDate#') 
									OR
									(cm.Approval_End_Date BETWEEN '#StartDate#' AND '#EndDate#') 
									OR
									(cm.Approval_Start_Date < '#StartDate#') AND (cm.Approval_End_Date > '#EndDate#')
								)
								#PreserveSingleQuotes(sWhereClause)# 
					</CFQUERY>
					<cfset oqueryname = "ogetReport">
				</cfif>
			<cfelseif checkcolheader is "fiscalexpense">
				<cfif listlen(dlist) GT 0>
					<CFQUERY NAME="dgetReport" datasource="#application.datasource#">
						select 	#PreserveSingleQuotes(dSelect)#
						From	#sJoinClauseBeginBraces#	PROGRAM_PRODUCTS_2 cm 
								INNER JOIN INVOICE_JOIN_DETAIL id
								ON
								id.BSA_Foodservice_Customers_ID = cm.Customer_Id
								AND
								cm.Product_Id = id.BSA_Foodservice_Items_Master_ID
								AND
								(( id.Invoice_Date >= '#StartDate#') AND (id.Invoice_Date <= '#EndDate#'))
						WHERE  0=0
								<cfif NOT ListFindNoCase(rStatus,"-1",",")>
									and cm.Contract_Status_Type_IDX in (#rStatus#)
								</cfif>
								<cfif NOT ListFindNoCase(rBusinessSegment,"-1",",")>
									and cm.Business_Segment_ID in (#rBusinessSegment#)
								</cfif>
								<cfif NOT ListFindNoCase(rDiscountIdentifier,"-1",",")>
								AND	cm.Discount_Identifier_ID IN (#rDiscountIdentifier#)
								</cfif>
								<cfif NOT ListFindNoCase(rProducts,"-1",",") AND rProducts NEQ "">
								and		cm.BSA_Foodservice_Items_Master_ID in (#ListQualify(rProducts, "'", ",")#)
								</cfif>
								and		cm.Generic_Type_ID in (#dlist#)
								and 
								(
									(cm.Approval_Start_Date BETWEEN '#StartDate#' AND '#EndDate#') 
									OR
									(cm.Approval_End_Date BETWEEN '#StartDate#' AND '#EndDate#') 
									OR
									(cm.Approval_Start_Date < '#StartDate#') AND (cm.Approval_End_Date > '#EndDate#')
								)
						#PreserveSingleQuotes(sWhereClause)#		
					</CFQUERY>
					<cfset dqueryname = "dgetReport">
				</cfif>
				
				<cfif listlen(olist) GT 0>
					<CFQUERY NAME="ogetReport" datasource="#application.datasource#">
						select 	#PreserveSingleQuotes(oSelect)#
						From	#sJoinClauseBeginBraces#	program_join_products cm 
								INNER JOIN Billback_Info bb
								ON
								bb.program_id = cm.contract_main_id
								and cm.product_id = bb.billback_product_id
								AND
								(
									(bb.BB_Start_Date BETWEEN '#StartDate#' AND '#EndDate#') 
									OR
									(bb.BB_End_Date BETWEEN '#StartDate#' AND '#EndDate#') 
									OR
									(bb.BB_Start_Date < '#StartDate#') AND (bb.BB_End_Date > '#EndDate#')
								)
						WHERE  0=0
								<cfif NOT ListFindNoCase(rStatus,"-1",",")>
									and cm.Contract_Status_Type_IDX in (#rStatus#)
								</cfif>
								<cfif NOT ListFindNoCase(rGenericTypes,"-1",",")>
									and		Generic_Type_ID in (#rGenericTypes#)
								</cfif>
								<cfif NOT ListFindNoCase(rDiscountIdentifier,"-1",",")>
								AND	cm.Discount_Identifier_ID IN (#rDiscountIdentifier#)
								</cfif>
								<cfif NOT ListFindNoCase(rProducts,"-1",",") AND rProducts NEQ "">
								and		cm.BSA_Foodservice_Items_Master_ID in (#ListQualify(rProducts, "'", ",")#)
								</cfif>
								and		cm.Generic_Type_ID in (#olist#)
								and 
								(
									(cm.Approval_Start_Date BETWEEN '#StartDate#' AND '#EndDate#') 
									OR
									(cm.Approval_End_Date BETWEEN '#StartDate#' AND '#EndDate#') 
									OR
									(cm.Approval_Start_Date < '#StartDate#') AND (cm.Approval_End_Date > '#EndDate#')
								)
						#PreserveSingleQuotes(sWhereClause)# 
					</CFQUERY>
					<cfset oqueryname = "ogetReport">
				</cfif>
			</cfif>
		</cfif>
	</cfif>
