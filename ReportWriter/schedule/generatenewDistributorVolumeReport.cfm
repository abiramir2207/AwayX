<cfset dSelect="distinct cm.Contract_Number,cm.Contract_Main_ID,id.Invoice_Date, CAST(id.Pounds_Invoiced AS FLOAT)as Pounds_Invoiced, CAST(id.LB_Unit_Price AS FLOAT)*Pounds_Invoiced as Price">

<cfset oSelect="distinct cm.Contract_Number,cm.Contract_Main_ID,bb.Item_Volume_Paid_LB,bb.BB_Start_Date,bb.BB_End_Date,CASE WHEN ((DATEDIFF(Day, bb.BB_start_date, bb.BB_End_Date) + 1) >= 0 AND bb.Item_Volume_Paid_LB IS NOT NULL) THEN (bb.Item_Volume_paid_LB / (DATEDIFF(Day, bb.BB_start_date, bb.BB_End_Date) + 1)) END AS VolumePerday">

<cfset sSelect="distinct cm.Contract_Status_Type_Desc,cm.Contract_Status_Type_IDX,cm.Created_Type,cm.Generic_Type_ID,cm.Contract_Number,cm.Contract_Title,cm.Contract_Start_Date,cm.Contract_End_Date,cm.Contract_Main_ID,cm.cust_des,cm.PTEC as programExpense,cm.Program_Weight,((programvolume/7) * (DATEDIFF(Day, cm.Approval_Start_Date, cm.Approval_End_Date) + 1)) as programvolume">

<!--- <cfset groupbyselect = "distinct cm.Contract_Status_Type_Desc,cm.Contract_Status_Type_IDX,cm.Generic_Type,cm.Generic_Type_Id,cm.Contract_Number,cm.Contract_Title,cm.Contract_Start_Date,cm.Contract_End_Date,cm.Contract_Main_ID,cm.Volume_LB as programVolume,cm.PTEC as programExpense,cm.Program_Weight,cm.customer_id,cm.product_id"> --->

	<cfset dList = "">
	<cfset oList = "">
	<cfif rgenerictypes NEQ "-1">
		<cfloop list="#rgenerictypes#" index="i" delimiters=",">
			<!------ Distributor Templates ----->
			<cfif i IS 1 or i is 5>
				<cfset dList = ListAppend(dList,i,",")>
			</cfif>
			<!------ Operator Templates ----->
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
	
	<!--- <cfoutput>#rFilterItems#</cfoutput><cfabort> --->
	<!--------------------End Add typegroup/qbrand/typecode/brand to groupList---->
	
	
	<!-------------Find field name corresponding to fFilter --------------------------------->
	<cfset sFilterField="">
	<cfswitch expression="#rFilterItems#">
		<cfcase value="family">
			<cfset sFilterField="cm.Family_Name">
		</cfcase>
		<cfcase value="buyinggroup">
			<cfset sFilterField="cm.Buying_Name">
		</cfcase>
		<cfcase value="distributor">
			<cfset sFilterField="cm.Cust_Des">
		</cfcase><cfcase value="operator">
			<cfset sFilterField="cm.operator_name">
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
	<cfset iIndex=ListFindNoCase(sGroupBy, "operator",",")>	
	<cfif iIndex GT 0>
		<cfset sGroupBy=ListSetAt(sGroupBy, iIndex, sFilterField,",")>
	</cfif>
	<cfset iIndex=ListFindNoCase(sGroupBy, "zone",",")>	
	<cfif iIndex GT 0>
		<cfset sGroupBy=ListSetAt(sGroupBy, iIndex, "cm.zone_name",",")>
	</cfif>
	<cfset iIndex=ListFindNoCase(sGroupBy, "region",",")>	
	<cfif iIndex GT 0>
		<cfset sGroupBy=ListSetAt(sGroupBy, iIndex, "cm.region_name",",")>
	</cfif>
	<cfset iIndex=ListFindNoCase(sGroupBy, "broker",",")>	
	<cfif iIndex GT 0>
		<cfset sGroupBy=ListSetAt(sGroupBy, iIndex, "cm.broker_name",",")>
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
	<cfset iIndex=ListFindNoCase(sGroupFieldList, "operator",",")>	
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
	<CFSET fProgramColumnFields="cm.Created_Type,cm.Contract_Number,cm.Contract_Title,cm.Contract_Start_Date,cm.Contract_End_Date">
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
		<!--- 	<cfset sSelect="#sSelect#,cm.Family_Name,cm.family_id,(select sum(cm1.Program_Weight) from new_program_join_detail  cm1 where cm.contract_main_id = cm1.contract_main_id and cm.family_Id = cm1.family_Id and cm1.product_id = (select top 1 cm2.product_id from NEW_PROGRAM_JOIN_DETAIL cm2 where cm2.contract_main_id = cm1.contract_main_id and cm2.family_Id = cm1.family_Id order by cm2.product_id)) as program_fweight "> --->
		<cfset sSelect="#sSelect#,cm.Family_Name,cm.family_id,(select sum(cm1.Program_Weight) from new_program_join_detail  cm1 where cm.contract_main_id = cm1.contract_main_id and cm.family_Id = cm1.family_Id and cm1.product_id = (select top 1 cm2.product_id from NEW_PROGRAM_JOIN_DETAIL cm2 where cm2.contract_main_id = cm1.contract_main_id and cm2.family_Id = cm1.family_Id order by cm2.product_id) and  (cm1.BSA_foodservice_brokers_id IS NULL OR cm1.BSA_foodservice_brokers_id = (select top 1 cm2.BSA_foodservice_brokers_id  from NEW_PROGRAM_JOIN_DETAIL cm2 where cm2.contract_main_id = cm1.contract_main_id and cm2.family_Id = cm1.family_Id order by cm2.BSA_foodservice_brokers_id))) as program_fweight ">
		<cfset dselect = "#dSelect#,cm.family_id">
		<cfset oselect = "#oSelect#,cm.family_id">
		<cfif rFamilys NEQ "-1">
			<cfset sWhereClause="#sWhereClause# and	cm.family_ID='#rFamilys#'">	
			<!--- <cfset sSelect="#sSelect#,(select sum(cm1.Program_Weight) from new_program_join_detail  cm1 where cm.contract_main_id = cm1.contract_main_id and cm1.family_Id ='#rFamilys#' and cm1.product_id = (select top 1 cm2.product_id from NEW_PROGRAM_JOIN_DETAIL cm2 where cm2.contract_main_id = cm1.contract_main_id and cm2.family_Id = cm1.family_Id order by cm2.product_id)) as program_fweight "> --->
			<cfset sSelect="#sSelect#,(select sum(cm1.Program_Weight) from new_program_join_detail  cm1 where cm.contract_main_id = cm1.contract_main_id and cm1.family_Id ='#rFamilys#' and cm1.product_id = (select top 1 cm2.product_id from NEW_PROGRAM_JOIN_DETAIL cm2 where cm2.contract_main_id = cm1.contract_main_id and cm2.family_Id = cm1.family_Id order by cm2.product_id) and  (cm1.BSA_foodservice_brokers_id IS NULL OR cm1.BSA_foodservice_brokers_id = (select top 1 cm2.BSA_foodservice_brokers_id  from NEW_PROGRAM_JOIN_DETAIL cm2 where cm2.contract_main_id = cm1.contract_main_id and cm2.family_Id = cm1.family_Id order by cm2.BSA_foodservice_brokers_id))) as program_fweight ">	
			<cfset dSelect="#dSelect#,cm.family_id">	
			<cfset oSelect="#oSelect#,cm.family_id">	
		</cfif>
		
		
		<!--- <cfset groupbyselect = "#groupbyselect#,cm.Family_Name,cm.family_id"> --->
	</cfif>
	<cfif rBuyingGroups NEQ "">		
		<!--- 	<cfset sSelect="#sSelect#,cm.Buying_Name,cm.buying_id,cm.Buying_Name,cm.buying_id,(select sum(cm1.Program_Weight) from new_program_join_detail  cm1 where cm.contract_main_id = cm1.contract_main_id and cm.buying_id = cm1.buying_id and cm1.product_id = (select top 1 cm2.product_id from NEW_PROGRAM_JOIN_DETAIL cm2 where cm2.contract_main_id = cm1.contract_main_id and cm2.buying_id = cm1.buying_id order by cm2.product_id)) as program_bweight"> --->
	 	<cfset sSelect="#sSelect#,cm.Buying_Name,cm.buying_id,cm.Buying_Name,cm.buying_id,(select sum(cm1.Program_Weight) from new_program_join_detail  cm1 where cm.contract_main_id = cm1.contract_main_id and cm.buying_id = cm1.buying_id and cm1.product_id = (select top 1 cm2.product_id from NEW_PROGRAM_JOIN_DETAIL cm2 where cm2.contract_main_id = cm1.contract_main_id and cm2.buying_id = cm1.buying_id order by cm2.product_id) and  (cm1.BSA_foodservice_brokers_id IS NULL OR cm1.BSA_foodservice_brokers_id = (select top 1 cm2.BSA_foodservice_brokers_id  from NEW_PROGRAM_JOIN_DETAIL cm2 where cm2.contract_main_id = cm1.contract_main_id and cm2.buying_id = cm1.buying_id order by cm2.BSA_foodservice_brokers_id))) as program_bweight">
		<cfset dSelect="#dSelect#,cm.buying_id">
		<cfset oSelect="#oSelect#,cm.buying_id">
		<cfif rBuyingGroups NEQ "-1">
			<cfset sWhereClause="#sWhereClause# and	cm.Buying_ID='#rBuyingGroups#'">
			<!--- <cfset sSelect="#sSelect#,(select sum(cm1.Program_Weight) from new_program_join_detail  cm1 where cm.contract_main_id = cm1.contract_main_id and cm1.buying_id = '#rBuyingGroups#' and cm1.product_id = (select top 1 cm2.product_id from NEW_PROGRAM_JOIN_DETAIL cm2 where cm2.contract_main_id = cm1.contract_main_id and cm2.buying_id = cm1.buying_id order by cm2.product_id)) as program_bweight"> --->
			<cfset sSelect="#sSelect#,(select sum(cm1.Program_Weight) from new_program_join_detail  cm1 where cm.contract_main_id = cm1.contract_main_id and cm1.buying_id = '#rBuyingGroups#' and cm1.product_id = (select top 1 cm2.product_id from NEW_PROGRAM_JOIN_DETAIL cm2 where cm2.contract_main_id = cm1.contract_main_id and cm2.buying_id = cm1.buying_id order by cm2.product_id) and  (cm1.BSA_foodservice_brokers_id IS NULL OR cm1.BSA_foodservice_brokers_id = (select top 1 cm2.BSA_foodservice_brokers_id  from NEW_PROGRAM_JOIN_DETAIL cm2 where cm2.contract_main_id = cm1.contract_main_id and cm2.buying_id = cm1.buying_id order by cm2.BSA_foodservice_brokers_id))) as program_bweight">
			<cfset dSelect="#dSelect#,cm.buying_id">	
			<cfset oSelect="#oSelect#,cm.buying_id">		
		</cfif>
		
		
		<!--- <cfset groupbyselect = "#groupbyselect#,cm.Buying_Name,cm.buying_id"> --->
	</cfif>
	<cfif rDistributors NEQ "">		
		<cfif rDistributors NEQ "-1">
			<cfset sWhereClause="#sWhereClause# and	cm.Customer_ID='#rDistributors#'">			
		</cfif>
		<cfset sSelect="#sSelect#,cm.Cust_Des,cm.customer_id">
		<cfset dSelect="#dSelect#,cm.customer_id">
		<cfset oSelect="#oSelect#,cm.customer_id">
	</cfif>
	<cfif rOperators NEQ "">	
			<cfif rOperators NEQ "-1">
				<cfset sWhereClause="#sWhereClause# and	cm.Operator_ID='#rOperators#'">			
		</cfif>	
		<cfset sSelect="#sSelect#,cm.Operator_name,cm.operator_id">
		<cfset oSelect="#oSelect#,cm.operator_id">
	</cfif>
	<cfif Len(sFilterField) GT 0>
		<cfif NOT ListFindNoCase(sSelect,sFilterField,",")>
			<cfset sSelect=ListAppend(sSelect,sFilterField,",")>
		</cfif>
	</cfif>
	

	<cfif rZones NEQ "">	
		<cfif rZones NEQ "-1">
			<cfset sWhereClause="#sWhereClause# and	cm.Service_Zone_ID='#rZones#'">			
		</cfif>
		<cfset sSelect="#sSelect#,cm.Zone_Name">
		<!--- <cfset groupbyselect = "#groupbyselect#,cm.Zone_Name"> --->
	</cfif>
	<cfif rRegions NEQ "">		
		<cfif rRegions NEQ "-1">
			<cfset sWhereClause="#sWhereClause# and	cm.Service_Region_ID='#rRegions#'">			
		</cfif>
		<cfset sSelect="#sSelect#,cm.Region_Name">
		<!--- <cfset groupbyselect = "#groupbyselect#,cm.Region_Name"> --->
	</cfif>
	<cfif rBrokers NEQ "">		
		<cfif rBrokers NEQ "-1">
			<cfset sWhereClause="#sWhereClause# and	cm.BSA_Foodservice_Brokers_ID='#rBrokers#'">			
		</cfif>
		<cfset sSelect="#sSelect#,cm.Broker_Name">
		<!--- <cfset groupbyselect = "#groupbyselect#,cm.Broker_Name"> --->
	</cfif>
	
	<cfif Len(sFilterField) GT 0>
		<cfif NOT ListFindNoCase(sSelect,sFilterField,",")>
			<cfset sSelect=ListAppend(sSelect,sFilterField,",")>
		</cfif>
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
	
	<cfset sSelect="Select #sSelect#">	
	

	<cfset DescSeparator=", ">
	<cfinclude template="schReportDescription.cfm">
	
	<!------ Get report ----->
	 <CFQUERY NAME="q_getReport" datasource="#application.datasource#">
		#PreserveSingleQuotes(sSelect)#
		From	#sJoinClauseBeginBraces#	NEW_PROGRAM_JOIN_DETAIL cm				
		WHERE  	0=0
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
					<cfif rOperators NEQ "">
						and  cm.Generic_Type_ID in (#oList#)
					<cfelse>
						and	cm.Generic_Type_ID in (#rGenericTypes#)
					</cfif>
				<cfelseif ListFindNoCase(rGenericTypes,"-1",",") and rOperators NEQ "">
					and  cm.Generic_Type_ID in (#oList#)
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
		#sGroupBy#		
	</CFQUERY>

	<!------  get distributor info? ----->
	<cfif listlen(dlist) GT 0 and  rOperators EQ "">
		<CFQUERY NAME="dgetReport" datasource="#application.datasource#">
			select 	#PreserveSingleQuotes(dSelect)#
			From	NEW_PROGRAM_JOIN_DETAIL cm 
					INNER JOIN INVOICE_JOIN_DETAIL id
					ON	id.BSA_Foodservice_Customers_ID = cm.Customer_Id
					AND	cm.Product_Id = id.BSA_Foodservice_Items_Master_ID
					AND	(( id.Invoice_Date >= '#StartDate#') AND (id.Invoice_Date <= '#EndDate#'))
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
	
	<!------  get operator info? ----->
	<cfif listlen(olist) GT 0>
		<CFQUERY NAME="ogetReport" datasource="#application.datasource#">
			select 	#PreserveSingleQuotes(oSelect)#
			From	#sJoinClauseBeginBraces#
					NEW_PROGRAM_JOIN_DETAIL cm 
					INNER JOIN Billback_dis_opr_info bb
					ON	bb.program_id = cm.contract_main_id
					AND	bb.Distributor_ID = cm.customer_id
					AND	
					(
					(bb.BB_Start_Date BETWEEN '#StartDate#' AND '#EndDate#') OR
					(bb.BB_End_Date BETWEEN '#StartDate#' AND '#EndDate#') OR
					(bb.BB_Start_Date < '#StartDate#') AND (bb.BB_End_Date > '#EndDate#')
					)
			WHERE  	0=0
					<cfif NOT ListFindNoCase(rStatus,"-1",",")>
					and cm.Contract_Status_Type_IDX in (#rStatus#)
					</cfif>
					<cfif NOT ListFindNoCase(rBusinessSegment,"-1",",")>
					and cm.Business_Segment_ID in (#rBusinessSegment#)
					</cfif>
					<cfif NOT ListFindNoCase(rDiscountIdentifier,"-1",",")>
					AND	cm.Discount_Identifier_ID IN (#rDiscountIdentifier#)
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
				<cfif rOperators NEQ "">
					<cfif rOperators NEQ "-1">
						and	cm.Operator_ID='#rOperators#'
					<cfelse>
						and	cm.Operator_ID is not null
					</cfif>					
				</cfif>	
		</CFQUERY>
		<cfset oqueryname = "ogetReport">
	</cfif>

	<cfset srqueryname="q_getReport">
	