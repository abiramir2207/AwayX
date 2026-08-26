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
	<cfif rFilter NEQ "none">
		<cfif Len(sGroupByList) GT 0>	
			<cfset sGroupByList=ListInsertAt(sGroupByList, 1,"#rFilter#",",")>
		<cfelse>
			<cfset sGroupByList="#rFilter#">
		</cfif>
	</cfif>
	
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
		<cfcase value="family">
			<cfset sFilterField="f.Family_Name">
		</cfcase>
		<cfcase value="buyinggroup">
			<cfset sFilterField="bg.Buying_Group_Name">
		</cfcase>
		<cfcase value="distributor">
			<cfset sFilterField="cla.Name">
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
	
	<cfset iIndex=ListFindNoCase(sGroupBy, "family",",")>	
	<cfif iIndex GT 0>
		<cfset sGroupBy=ListSetAt(sGroupBy, iIndex, sFilterField,",")>
	</cfif>
	<cfset iIndex=ListFindNoCase(sGroupBy, "buyinggroup",",")>	
	<cfif iIndex GT 0>
		<cfset sGroupBy=ListSetAt(sGroupBy, iIndex, sFilterField,",")>
	</cfif>
	<cfset iIndex=ListFindNoCase(sGroupBy, "distributor",",")>	
	<cfif iIndex GT 0>
		<cfset sGroupBy=ListSetAt(sGroupBy, iIndex, sFilterField,",")>
	</cfif>
	
	<cfset iIndex=ListFindNoCase(sGroupBy, "zone",",")>	
	<cfif iIndex GT 0>
		<cfset sGroupBy=ListSetAt(sGroupBy, iIndex, "sz.zone_name",",")>
	</cfif>
	<cfset iIndex=ListFindNoCase(sGroupBy, "region",",")>	
	<cfif iIndex GT 0>
		<cfset sGroupBy=ListSetAt(sGroupBy, iIndex, "sr.region_name",",")>
	</cfif>
	<cfset iIndex=ListFindNoCase(sGroupBy, "broker",",")>	
	<cfif iIndex GT 0>
		<cfset sGroupBy=ListSetAt(sGroupBy, iIndex, "bla.broker_name",",")>
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
	<cfset iIndex=ListFindNoCase(sGroupFieldList, "family",",")>	
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
	
	<cfset iIndex=ListFindNoCase(sGroupFieldList, "buyinggroup",",")>	
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
	<cfset iIndex=ListFindNoCase(sGroupFieldList, "distributor",",")>	
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
	
	<cfset iIndex=ListFindNoCase(sGroupFieldList, "zone",",")>	
	<cfif iIndex GT 0>
		<cfset sGroupFieldList=ListSetAt(sGroupFieldList, iIndex, "zone_name",",")>		
	</cfif>
	<cfset iIndex=ListFindNoCase(sGroupFieldList, "region",",")>	
	<cfif iIndex GT 0>
		<cfset sGroupFieldList=ListSetAt(sGroupFieldList, iIndex, "region_name",",")>		
	</cfif>
	<cfset iIndex=ListFindNoCase(sGroupFieldList, "broker",",")>
	<cfif iIndex GT 0>
		<cfset sGroupFieldList=ListSetAt(sGroupFieldList, iIndex, "broker_name",",")>		
	</cfif>
	
	
	<!--------------------End Make group By fields 'sGroupFieldList' from groupList---->
	
	<!--------------Populate sHeaderIDList and sHeaderNameList --------------------------------->
	<!-----	
	sHeaderIDList and sHeaderNameList already have the groupsBy Columns
	<cfset sHeaderIDList=sGroupByList>
	<cfset sHeaderNameList=sGroupBy>
	--->
	
	<!-----<cfset programColumnHeaderID=ListAppend(fProgramColumnHeaderID,vProgramColumnHeaderID,",")>
	<cfset programColumnFields=ListAppend(fProgramColumnFields,vProgramColumnFields,",")>------->	
	<cfset programColumnHeaderID=fProgramColumnHeaderID>
	<cfset programColumnFields=fProgramColumnFields>
	<cfloop index="i" list="#rColumnHeaderID#" delimiters=",">
		<cfif NOT ListFindNoCase(sGroupByList,i,",")>
			<cfset iIndex=ListFindNoCase(programColumnHeaderID,i,",")>
			<cfif iIndex>
				<cfset sHeaderIDList=ListAppend(sHeaderIDList,ListGetAt(programColumnHeaderID,iIndex,","))>
				<cfset sHeaderNameList=ListAppend(sHeaderNameList,ListGetAt(programColumnFields,iIndex,","))>
			</cfif>
		</cfif>
	</cfloop>
	
	<!--------------End Populate sHeaderIDList and sHeaderNameList ---------------------------------->
	
	
	
	<!------------------------------ check for fiscalvolume ------------------------------------------>
	<cfloop index="i" list="#rColumnHeaderID#" delimiters=",">
		<cfif NOT ListFindNoCase(sGroupByList,i,",")>
			<cfset iIndex=ListFindNoCase(vProgramColumnHeaderID,i,",")>
			<cfif iIndex>
				<cfswitch expression="#ListGetAt(vProgramColumnHeaderID,iIndex,",")#">
					<cfcase value="fiscalvolume">
						<!-----<CFOUTPUT><cfsavecontent variable="sSelect">
						#sSelect#,
						CASE 
				            WHEN (DATEDIFF(day,cm.Contract_Start_Date,cm.Contract_End_Date) = 0) THEN			
					   	CAST(cm.Contract_Quantity AS FLOAT)
				            ELSE
				            	CAST(cm.Contract_Quantity AS FLOAT)/CAST(DATEDIFF(day,cm.Contract_Start_Date,cm.Contract_End_Date) AS FLOAT)
					    END AS VolumePerDay
						 
						</cfsavecontent></CFOUTPUT>------->
						<!-----<CFOUTPUT><cfsavecontent variable="sSelect">
						#sSelect#,						
				        CAST(cm.Contract_Quantity AS FLOAT)/CAST((DATEDIFF(day,cm.Contract_Start_Date,cm.Contract_End_Date) + 1) AS FLOAT)
					    AS VolumePerDay
						 
						</cfsavecontent></CFOUTPUT>------->
						
						<CFOUTPUT><cfsavecontent variable="sSelect">
						#sSelect#,						
				        (SELECT 
						CAST(SUM(isNull(FPV_LB,0)+isNull(REV_LB,0)+isNull(GRV_LB,0)+isNull(KPV_LB,0))  AS FLOAT)/CAST(7 AS FLOAT)
						--FROM contract_product_margin cpm,Contract_Products cp,product_category_lob_active pcla
						FROM contract_product_margin cpm,Contract_Products cp,product_category_active pcla
						WHERE 	cpm.Contract_Product_ID=cp.Contract_Products_ID
						and cp.BSA_Foodservice_Items_Master_ID=pcla.BSA_Foodservice_Items_Master_ID
						and  cpm.Contract_Main_ID=cm.Contract_Main_ID
						and  cpm.Deleted=0
						) as VolumePerDay
						 
						</cfsavecontent></CFOUTPUT>
					</cfcase>
					<cfcase value="fiscalexpense">
						<!-----<cfset sSelect="#sSelect#,PTEC">------->
						<!-----<CFOUTPUT><cfsavecontent variable="sSelect">
						#sSelect#,						
				        CAST(cm.PTEC AS FLOAT)/CAST((DATEDIFF(day,cm.Contract_Start_Date,cm.Contract_End_Date) + 1) AS FLOAT)
					    AS PTECPerDay
						 
						</cfsavecontent></CFOUTPUT>------->
						
						<!------<CFOUTPUT><cfsavecontent variable="sSelect">
						#sSelect#,						
				        CAST(cm.PTEC AS FLOAT)/CAST(7 AS FLOAT)
					    AS PTECPerDay
						 
						</cfsavecontent></CFOUTPUT>----->
						
						<CFOUTPUT><cfsavecontent variable="sSelect">
						#sSelect#,						
				        CAST(cm.PTEC AS FLOAT)/CAST((DATEDIFF(day,cm.Contract_Start_Date,cm.Contract_End_Date) + 1) AS FLOAT)
					    AS PTECPerDay
						 
						</cfsavecontent></CFOUTPUT>
					</cfcase>
					<cfcase value="fiscalmargin">
						<!-----<cfset sSelect="#sSelect#,PTTM">------->
						<!-----<CFOUTPUT><cfsavecontent variable="sSelect">
						#sSelect#,						
				        CAST(cm.PTTM AS FLOAT)/CAST((DATEDIFF(day,cm.Contract_Start_Date,cm.Contract_End_Date) + 1) AS FLOAT)
					    AS PTTMPerDay
						 
						</cfsavecontent></CFOUTPUT>------->
						<!------<CFOUTPUT><cfsavecontent variable="sSelect">
						#sSelect#,						
				        CAST(cm.PTTM AS FLOAT)/CAST(7 AS FLOAT)
					    AS PTTMPerDay
						 
						</cfsavecontent></CFOUTPUT>----->
						<CFOUTPUT><cfsavecontent variable="sSelect">
						#sSelect#,						
				        CAST(cm.PTTM AS FLOAT)/CAST((DATEDIFF(day,cm.Contract_Start_Date,cm.Contract_End_Date) + 1) AS FLOAT)
					    AS PTTMPerDay
						 
						</cfsavecontent></CFOUTPUT>
					</cfcase>
				</cfswitch>
			</cfif>
		</cfif>
	</cfloop>
	
	<!------------------------------ check for fiscalvolume ------------------------------------------>
	
	
	
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
	
	
	<cfif rFamilys NEQ "">	
		<cfset sJoinClause="#sJoinClause# LEFT JOIN  Distributor_Family f ON (cla.family_ID=f.family_ID) AND (f.Deleted=0)) ">
		<cfset sJoinClauseBeginBraces="#sJoinClauseBeginBraces#(">
		
		<!-----<cfset sWhereClause="#sWhereClause# and f.Deleted=0 and cd.Deleted=0">------->
		<!-----<cfset sWhereClause="#sWhereClause# and cd.Deleted=0">------->
		 
		<cfif rFamilys NEQ "-1">
			<cfset sWhereClause="#sWhereClause# and	f.family_ID='#rFamilys#'">			
		</cfif>
		<!------<cfset sWhereClause="#sWhereClause# and cd.BSA_FoodService_Customers_ID = cla.BSA_FoodService_Customers_ID">----->
		<cfset sSelect="#sSelect#,f.Family_Name">		
	</cfif>
	<cfif rBuyingGroups NEQ "">		
		<cfset sJoinClause="#sJoinClause# LEFT JOIN  Distributor_Buying_Groups bg ON (cla.Buying_Group_ID=bg.Buying_Group_ID) AND (bg.Deleted=0)) ">
		<cfset sJoinClauseBeginBraces="#sJoinClauseBeginBraces#(">
	
		<!-----<cfset sWhereClause="#sWhereClause#  and bg.Deleted=0 and cd.Deleted=0">------->
		<!-----<cfset sWhereClause="#sWhereClause#  and cd.Deleted=0">------->
		<cfif rBuyingGroups NEQ "-1">
			<cfset sWhereClause="#sWhereClause# and	bg.Buying_Group_ID='#rBuyingGroups#'">			
		</cfif>
		<!------<cfset sWhereClause="#sWhereClause# and cd.BSA_FoodService_Customers_ID = cla.BSA_FoodService_Customers_ID">----->
		<cfset sSelect="#sSelect#,bg.Buying_Group_Name">
	</cfif>
	<cfif rDistributors NEQ "">		
		<!-----<cfset sWhereClause="#sWhereClause#  and cd.Deleted=0">------->
		<cfif rDistributors NEQ "-1">
			<cfset sWhereClause="#sWhereClause# and	cla.BSA_FoodService_Customers_ID='#rDistributors#'">			
		</cfif>
		<!------<cfset sWhereClause="#sWhereClause# and cd.BSA_FoodService_Customers_ID = cla.BSA_FoodService_Customers_ID">----->
		<cfset sSelect="#sSelect#,cla.Name">
	</cfif>
	<!--------------------End Get FromClause according to Item Level Filtering--------------->
	
	
	
	<!------------------------------------ Add the variables fields to list ---------------------------->
	<cfset anyVariableFields=false>
	<cfset programColumnHeaderID=vProgramColumnHeaderID>
	<cfset programColumnFields=vProgramColumnFields>
	<cfloop index="i" list="#rColumnHeaderID#" delimiters=",">
		<cfif NOT ListFindNoCase(sGroupByList,i,",")>
			<cfset iIndex=ListFindNoCase(programColumnHeaderID,i,",")>
			<cfif iIndex>
				<cfset sHeaderIDList=ListAppend(sHeaderIDList,ListGetAt(programColumnHeaderID,iIndex,","))>
				<cfset tempVal=ListGetAt(programColumnFields,iIndex,",")>
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
						(
						DATEDIFF(day,GetDate(),fy.End_Date) >= 0
						AND 
						fy.Deleted=0
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
	<!-----<cfset sGroupBy=ListAppend(sGroupBy,"fyEndDate",",")>------->
	
	<cfset sWhereClause="#sWhereClause# and DATEDIFF(day,cm.Contract_Start_Date,cm.Contract_End_Date) >= 0">
	
	<cfset sSelect="Select #sSelect#">	
	
	
	<cfset DescSeparator=", ">
	<cfinclude template="schReportDescription.cfm">
	
	<cfswitch expression="#rFilter#">
		<cfcase value="zone">
			<CFQUERY NAME="q_getReport" datasource="#application.datasource#">
				#sSelect#,sz.zone_name
				From 	
				#sJoinClauseBeginBraces#
				Contract_Status_Types cs 
				INNER JOIN Contract_Main cm ON  cs.Contract_Status_Type_ID=cm.Contract_Status_Type_IDX
				INNER JOIN  Program_Control_Panel_Options pt ON pt.ProgramControl_Panel_Options_ID=cm.ProgramType_ID
				INNER JOIN  Generic_Type ON Generic_Type.Generic_Type=pt.Generic_Type
				INNER JOIN  Units_of_Measure uom ON uom.Unit_Of_Measure_ID=cm.Contract_Quantity_UOM_IDX
				LEFT JOIN  	Contract_Distributors cd ON (cd.Contract_Main_ID=cm.Contract_Main_ID) AND (cd.Deleted=0)
				LEFT JOIN 	Contract_Brokers cb ON (cb.Contract_Main_ID=cm.Contract_Main_ID AND cb.Deleted = 0)
				/*
				LEFT JOIN  	(customer_active cla FULL JOIN (broker_active bla INNER JOIN Service_Zones sz ON bla.Service_Zone_ID=sz.Service_Zone_ID) ON cla.BSA_Foodservice_Brokers_ID=bla.BSA_Foodservice_Brokers_ID)				
				ON (cla.BSA_FoodService_Customers_ID=cd.BSA_FoodService_Customers_ID) OR (bla.BSA_Foodservice_Brokers_ID = cb.BSA_Foodservice_Brokers_ID)
				*/
				LEFT JOIN  	customer_active cla ON (cla.BSA_FoodService_Customers_ID=cd.BSA_FoodService_Customers_ID)
				LEFT JOIN 	broker_active bla ON
				(
					bla.BSA_Foodservice_Brokers_ID = cb.BSA_Foodservice_Brokers_ID
					OR
					cla.BSA_Foodservice_Brokers_ID=bla.BSA_Foodservice_Brokers_ID
				)
				LEFT JOIN Service_Zones sz ON bla.Service_Zone_ID=sz.Service_Zone_ID
				#sJoinClause#
				Where cm.Deleted=0
				and		cm.Flagged_As_Purged=0
				and 	pt.Deleted=0
				and		cs.Contract_Status_Type_ID > 3
				and
				(
					((cm.Parent_Revised_Contract_Main_ID IS NULL) AND (cm.Revision_of_Contract_Main_ID IS NULL))
					OR
					(NOT(cm.Parent_Revised_Contract_Main_ID IS NULL) AND NOT(cm.Revision_of_Contract_Main_ID IS NULL) AND cs.Contract_Status_Type_ID > 4)
				)
				#PreserveSingleQuotes(sWhereClause)#
				<cfif rZones NEQ "-1">
				and		sz.Service_Zone_ID='#rZones#'				
				</cfif>
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
				<cfif rOutputStartDate NEQ "" AND rOutputStartDateOperatorSymbol NEQ "">
				and		DateDiff(d, '#rOutputStartDate#', cm.Contract_Start_Date) #rOutputStartDateOperatorSymbol# 0
				</cfif>
				<cfif rOutputEndDate NEQ "" AND rOutputEndDateOperatorSymbol NEQ "">
				and		DateDiff(d, '#rOutputEndDate#', cm.Contract_End_Date) #rOutputEndDateOperatorSymbol# 0
				</cfif>
				#sGroupBy#
			</CFQUERY>
			<cfset srqueryname="q_getReport">
		</cfcase>
 		<cfcase value="region">
			<CFQUERY NAME="q_getReport" datasource="#application.datasource#">
				#sSelect#,sr.region_name
				From 	
				#sJoinClauseBeginBraces#
				Contract_Status_Types cs 
				INNER JOIN Contract_Main cm ON  cs.Contract_Status_Type_ID=cm.Contract_Status_Type_IDX
				INNER JOIN  Program_Control_Panel_Options pt ON pt.ProgramControl_Panel_Options_ID=cm.ProgramType_ID
				INNER JOIN  Generic_Type ON Generic_Type.Generic_Type=pt.Generic_Type
				INNER JOIN  Units_of_Measure uom ON uom.Unit_Of_Measure_ID=cm.Contract_Quantity_UOM_IDX
				LEFT JOIN  	Contract_Distributors cd ON (cd.Contract_Main_ID=cm.Contract_Main_ID) AND (cd.Deleted=0)
				LEFT JOIN 	Contract_Brokers cb ON (cb.Contract_Main_ID=cm.Contract_Main_ID and cb.Deleted=0)
				/*
				LEFT JOIN  	(customer_active cla FULL JOIN (broker_active bla INNER JOIN Service_Regions sr ON bla.Service_Region_ID=sr.Service_Region_ID) ON cla.BSA_Foodservice_Brokers_ID=bla.BSA_Foodservice_Brokers_ID)								
				ON (cla.BSA_FoodService_Customers_ID=cd.BSA_FoodService_Customers_ID) OR (bla.BSA_Foodservice_Brokers_ID = cb.BSA_Foodservice_Brokers_ID)
				*/
				LEFT JOIN  	customer_active cla ON (cla.BSA_FoodService_Customers_ID=cd.BSA_FoodService_Customers_ID)
				LEFT JOIN 	broker_active bla ON
				(
					bla.BSA_Foodservice_Brokers_ID = cb.BSA_Foodservice_Brokers_ID
					OR
					cla.BSA_Foodservice_Brokers_ID=bla.BSA_Foodservice_Brokers_ID
				)
				LEFT JOIN Service_Regions sr ON bla.Service_Region_ID=sr.Service_Region_ID
				#sJoinClause#
				Where cm.Deleted=0
				and		cm.Flagged_As_Purged=0
				and 	pt.Deleted=0				
				and		cs.Contract_Status_Type_ID > 3
				and
				(
					((cm.Parent_Revised_Contract_Main_ID IS NULL) AND (cm.Revision_of_Contract_Main_ID IS NULL))
					OR
					(NOT(cm.Parent_Revised_Contract_Main_ID IS NULL) AND NOT(cm.Revision_of_Contract_Main_ID IS NULL) AND cs.Contract_Status_Type_ID > 4)
				)
				#PreserveSingleQuotes(sWhereClause)#
				<cfif rRegions NEQ "-1">
				and		sr.Service_Region_ID='#rRegions#'				
				</cfif>
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
				<cfif rOutputStartDate NEQ "" AND rOutputStartDateOperatorSymbol NEQ "">
				and		DateDiff(d, '#rOutputStartDate#', cm.Contract_Start_Date) #rOutputStartDateOperatorSymbol# 0
				</cfif>
				<cfif rOutputEndDate NEQ "" AND rOutputEndDateOperatorSymbol NEQ "">
				and		DateDiff(d, '#rOutputEndDate#', cm.Contract_End_Date) #rOutputEndDateOperatorSymbol# 0
				</cfif>
				#sGroupBy#				
			</CFQUERY>
			<cfset srqueryname="q_getReport">
		</cfcase>
		<cfcase value="broker">
			<CFQUERY NAME="q_getReport" datasource="#application.datasource#">
				#sSelect#,bla.broker_name
				From 	
				#sJoinClauseBeginBraces#
				Contract_Status_Types cs 
				INNER JOIN Contract_Main cm ON  cs.Contract_Status_Type_ID=cm.Contract_Status_Type_IDX
				INNER JOIN  Program_Control_Panel_Options pt ON pt.ProgramControl_Panel_Options_ID=cm.ProgramType_ID
				INNER JOIN  Generic_Type ON Generic_Type.Generic_Type=pt.Generic_Type
				INNER JOIN  Units_of_Measure uom ON uom.Unit_Of_Measure_ID=cm.Contract_Quantity_UOM_IDX
				LEFT JOIN  	Contract_Distributors cd ON (cd.Contract_Main_ID=cm.Contract_Main_ID) AND (cd.Deleted=0)
				LEFT JOIN 	Contract_Brokers cb ON (cb.Contract_Main_ID=cm.Contract_Main_ID and cb.Deleted=0)
				/*
				LEFT JOIN  	(customer_active cla FULL JOIN broker_active bla ON cla.BSA_Foodservice_Brokers_ID=bla.BSA_Foodservice_Brokers_ID)								
				ON (cla.BSA_FoodService_Customers_ID=cd.BSA_FoodService_Customers_ID) OR (bla.BSA_Foodservice_Brokers_ID = cb.BSA_Foodservice_Brokers_ID)
				*/
				LEFT JOIN  	customer_active cla ON (cla.BSA_FoodService_Customers_ID=cd.BSA_FoodService_Customers_ID)
				LEFT JOIN 	broker_active bla ON
				(
					bla.BSA_Foodservice_Brokers_ID = cb.BSA_Foodservice_Brokers_ID
					OR
					cla.BSA_Foodservice_Brokers_ID=bla.BSA_Foodservice_Brokers_ID
				)
				#sJoinClause#
				Where cm.Deleted=0
				and		cm.Flagged_As_Purged=0
				and 	pt.Deleted=0				
				and		cs.Contract_Status_Type_ID > 3
				and
				(
					((cm.Parent_Revised_Contract_Main_ID IS NULL) AND (cm.Revision_of_Contract_Main_ID IS NULL))
					OR
					(NOT(cm.Parent_Revised_Contract_Main_ID IS NULL) AND NOT(cm.Revision_of_Contract_Main_ID IS NULL) AND cs.Contract_Status_Type_ID > 4)
				)
				#PreserveSingleQuotes(sWhereClause)#
				<cfif rBrokers NEQ "-1">
				and		bla.BSA_Foodservice_Brokers_ID='#rBrokers#' 				
				</cfif>
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
				<cfif rOutputStartDate NEQ "" AND rOutputStartDateOperatorSymbol NEQ "">
				and		DateDiff(d, '#rOutputStartDate#', cm.Contract_Start_Date) #rOutputStartDateOperatorSymbol# 0
				</cfif>
				<cfif rOutputEndDate NEQ "" AND rOutputEndDateOperatorSymbol NEQ "">
				and		DateDiff(d, '#rOutputEndDate#', cm.Contract_End_Date) #rOutputEndDateOperatorSymbol# 0
				</cfif>
				#sGroupBy#
			</CFQUERY>
			<cfset srqueryname="q_getReport">
		</cfcase>
		<cfcase value="none">
			<CFQUERY NAME="q_getReport" datasource="#application.datasource#">
				#sSelect#
				From
				#sJoinClauseBeginBraces#
				Contract_Status_Types cs 
				INNER JOIN Contract_Main cm ON  cs.Contract_Status_Type_ID=cm.Contract_Status_Type_IDX
				INNER JOIN  Program_Control_Panel_Options pt ON pt.ProgramControl_Panel_Options_ID=cm.ProgramType_ID
				INNER JOIN  Generic_Type ON Generic_Type.Generic_Type=pt.Generic_Type
				INNER JOIN  Units_of_Measure uom ON uom.Unit_Of_Measure_ID=cm.Contract_Quantity_UOM_IDX
				<CFIF sFilterField NEQ "">
				LEFT JOIN  	Contract_Distributors cd ON (cd.Contract_Main_ID=cm.Contract_Main_ID) AND (cd.Deleted=0)
				LEFT JOIN 	Contract_Brokers cb ON (cb.Contract_Main_ID=cm.Contract_Main_ID and cb.Deleted=0)
				LEFT JOIN  	customer_active cla ON (cla.BSA_FoodService_Customers_ID=cd.BSA_FoodService_Customers_ID)
				/*
				LEFT JOIN  	(customer_active cla FULL JOIN broker_active bla ON cla.BSA_Foodservice_Brokers_ID=bla.BSA_Foodservice_Brokers_ID)
				ON (cla.BSA_FoodService_Customers_ID=cd.BSA_FoodService_Customers_ID) OR (bla.BSA_Foodservice_Brokers_ID = cb.BSA_Foodservice_Brokers_ID)
				*/
				</CFIF>
				#sJoinClause#
				Where cm.Deleted=0
				and		cm.Flagged_As_Purged=0
				and 	pt.Deleted=0
				and		cs.Contract_Status_Type_ID > 3
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
				<cfif rOutputStartDate NEQ "" AND rOutputStartDateOperatorSymbol NEQ "">
				and		DateDiff(d, '#rOutputStartDate#', cm.Contract_Start_Date) #rOutputStartDateOperatorSymbol# 0
				</cfif>
				<cfif rOutputEndDate NEQ "" AND rOutputEndDateOperatorSymbol NEQ "">
				and		DateDiff(d, '#rOutputEndDate#', cm.Contract_End_Date) #rOutputEndDateOperatorSymbol# 0
				</cfif>
				#sGroupBy#
			</CFQUERY>
			<cfset srqueryname="q_getReport">
		</cfcase>
		<cfdefaultcase>
		errror
		</cfdefaultcase>
	</cfswitch>