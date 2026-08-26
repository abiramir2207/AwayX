<cfcomponent displayname="uploadMarginTargets" hint="Component used to handle upload margin targets." >
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<cffunction name="getAllTargets" output="true" returntype="any" hint="this function used to show all existing margin target data.">
			<cfargument name="download" type="boolean" default="0">
		    <cfquery name="qMTInfo" datasource="#application.datasource#">
					SELECT MTU.*, BSA.Description, BSA.Prod_Var_A_ID, BSA.Type_Code_Desc_ID, BSA.Type_Group_Desc_ID, BSA.Brand_ID, BSA.Q_Brand_ID
					FROM Margin_Targets_Upload MTU
					INNER JOIN BSA_Foodservice_Items_Master BSA
					ON BSA.BSA_Foodservice_Items_Master_ID = MTU.BSA_Foodservice_Items_Master_ID
					ORDER BY item ASC
		    </cfquery>
	
	<cfif arguments.download>

	<cfset q = queryNew("#application.returned_customer_setting.item_label#,Description,DistributionChannel,#replace(application.returned_customer_setting.type_code_label_singular,' ','','all')#,NetSalesTarget,NetSalesFloor,GrossMarginTarget,GrossMarginFloor", "cf_sql_varchar,cf_sql_varchar,cf_sql_varchar,cf_sql_varchar,cf_sql_varchar,cf_sql_varchar,cf_sql_varchar,cf_sql_varchar")> 

		<cfloop query="qMTInfo">

			<cfset queryAddRow(q)>
			<cfset querySetCell(q, "#application.returned_customer_setting.item_label#", #item#)>
			<cfset querySetCell(q, "Description", #description#)>
			<cfset querySetCell(q, "DistributionChannel", #Distribution_Channel#)>
			<cfset querySetCell(q, "#replace(application.returned_customer_setting.type_code_label_singular,' ','','all')#",#Type_Code_Desc#)>
			<cfset querySetCell(q, "NetSalesTarget", #NumberFormat(Net_Sales_Target_Value,'$(9.99999)')#)>
			<cfset querySetCell(q, "NetSalesFloor",#NumberFormat(Net_Sales_Floor_Value,'$(9.99999)')#)>
			<cfset querySetCell(q, "GrossMarginTarget", #NumberFormat(GM_Target_Value,'$(9.99999)')#)>
			<cfset querySetCell(q, "GrossMarginFloor", #NumberFormat(GM_Floor_Value,'$(9.99999)')#)>

		</cfloop>
		
			<cfset fname = 'Current_'&#appSettings.getMarginColHeader26()#&'.xls'>
			<cfset filename = expandPath("./#fname#")>
			<!--- Make a spreadsheet object --->
			<cfset s = spreadsheetNew()>
			<!--- Add header row --->
				<cfset spreadsheetAddRow(s, "#application.returned_customer_setting.item_label#,Description,DistributionChannel,#replace(application.returned_customer_setting.type_code_label_singular,' ','','all')#,NetSalesTarget,NetSalesFloor,GrossMarginTarget,GrossMarginFloor")>
			<!--- Add query --->
			<cfset spreadsheetAddRows(s, q)>
	
			<cfheader name="content-disposition" value="attachment; filename=#fname#">
			<cfcontent type="application/msexcel" variable="#spreadsheetReadBinary(s)#" reset="true">
	    	
		 <cfelse>
		    <cfreturn qMTInfo/>
	    </cfif>
</cffunction>

<cffunction name="MarginMatrix" output="true" returntype="query" hint="this function used to display margin targets to program.">
	
	<cfargument name="contract_main_id" type="numeric" required="true">
	<cfargument name="contract_start_date" type="date" required="true">
	<cfargument name="contract_end_date" type="date" required="true">
	<cfargument name="contract_number" type="any" required="true">
	<cfargument name="contract_status" type="numeric" required="true">
	<cfargument name="price_type" type="numeric" required="true">
	<cfargument name="uom_type" type="numeric" required="true">
	<cfargument name="margin_version" type="string" required="false" default="current">

		 <cfquery name="deleteTmpTables" datasource="#application.datasource#">
				IF OBJECT_ID('tempdb..##tmp_margin') IS NOT NULL
				DROP TABLE ##tmp_margin

				IF OBJECT_ID('tempdb..##tmp_margin_result') IS NOT NULL
				DROP TABLE ##tmp_margin_result

				IF OBJECT_ID('tempdb..##tmp_other_net_sales') IS NOT NULL
				DROP TABLE ##tmp_other_net_sales

				IF OBJECT_ID('tempdb..##tmp_other_net_sales_avg') IS NOT NULL
				DROP TABLE ##tmp_other_net_sales_avg
		</cfquery>				

    <cfquery name="qGetMTData" datasource="#application.datasource#">
		DECLARE 	@margin_multiplier INT,
						@margin_uot INT,
						@Contract_Main_ID INT = <cfqueryparam value="#arguments.contract_main_id#" cfsqltype="cf_sql_integer" />,
						@Contract_Start DATE = <cfqueryparam value="#arguments.Contract_Start_Date#" cfsqltype="cf_sql_date" />,
						@Contract_End DATE = <cfqueryparam value="#arguments.Contract_End_Date#" cfsqltype="cf_sql_date" />,
						@Contract_Number varchar(20) = <cfqueryparam value="#arguments.Contract_Number#" cfsqltype="cf_sql_varchar" />

		
		SELECT @margin_multiplier = Volume_UOT.Unit_Multiplier, @margin_uot = Margin_UOT_ID
		FROM   _Users_Settings 
		INNER JOIN Volume_UOT 
		ON Volume_UOT.Volume_UOT_ID = Margin_UOT_ID
		WHERE  User_ID = (SELECT Company_Main_ID FROM Company_Main WHERE Deleted = 0)

		SELECT m.Product_Id
			<cfif arguments.UOM_Type EQ 1>
			, Product_Program_Volume_CS AS Product_Program_Volume
			, Net_Sales_CS AS Net_Sales
			<cfelse>
			, Product_Program_Volume_LB AS Product_Program_Volume
			, Net_Sales_LB AS Net_Sales
		</cfif>
		
		, Operating_Income_CS
		, Operating_Income_LB
		, CASE @margin_uot WHEN 1 THEN (DATEDIFF(d, Contract_Start_Date, Contract_End_Date) + 1) ELSE @margin_multiplier END as margin_multiplier

		INTO   ##tmp_margin
		FROM   Contract_Product_Margin m
		WHERE  m.Contract_Main_ID = @Contract_Main_ID

		SELECT BSA.BSA_Foodservice_Items_Master_ID
							, BSA.Item
							, BSA.description
							, BSA.Prod_Var_A_ID
							, BSA.Type_Code_Desc_ID
							, BSA.Type_Group_Desc_ID
							, BSA.Brand_ID
							, BSA.Q_Brand_ID
							, MTU.Type_Code_Desc
							, MTU.Type_Group_Desc
							<cfif arguments.UOM_Type EQ 1>
								<cfif arguments.Price_Type EQ 0>
									<cfif arguments.Contract_Status GTE 3 AND arguments.margin_version eq "Approved">
										, CPMA.Cust_T_Target * BSA.Net_Weight  AS Target_Value
										, CPMA.Cust_T_Floor * BSA.Net_Weight  AS Floor_Value
									<cfelse>							
										, CASE WHEN LEN(MTU.Net_Sales_Target_Value) = 0 THEN  MTU.GM_Target_Value * BSA.Net_Weight ELSE MTU.Net_Sales_Target_Value * BSA.Net_Weight END AS Target_Value
										, CASE WHEN LEN(MTU.Net_Sales_Floor_Value) = 0 THEN MTU.GM_Floor_Value * BSA.Net_Weight ELSE MTU.Net_Sales_Floor_Value * BSA.Net_Weight END AS Floor_Value
									</cfif>
									, CASE WHEN LEN(MTU.Net_Sales_Floor_Value) = 0 THEN 'GM' ELSE 'NS' END AS PriceType
								<cfelseif arguments.Price_Type EQ 1>
									<cfif arguments.Contract_Status GTE 3 AND arguments.margin_version eq "Approved">
										, CPMA.Cust_T_Target * BSA.Net_Weight  AS Target_Value
										, CPMA.Cust_T_Floor * BSA.Net_Weight  AS Floor_Value
									<cfelse>				
									, MTU.Net_Sales_Target_Value * BSA.Net_Weight  AS Target_Value
									, MTU.Net_Sales_Floor_Value * BSA.Net_Weight  AS Floor_Value
									</cfif>
									, 'NS' AS PriceType
								<cfelse>
									<cfif arguments.Contract_Status GTE 3 AND arguments.margin_version eq "Approved">
										, CPMA.Cust_GM_Target * BSA.Net_Weight  AS Target_Value
										, CPMA.Cust_GM_Floor * BSA.Net_Weight  AS Floor_Value
									<cfelse>				
									, MTU.GM_Target_Value * BSA.Net_Weight  AS Target_Value
									, MTU.GM_Floor_Value * BSA.Net_Weight  AS Floor_Value
									</cfif>
									 , 'GM' AS PriceType
								</cfif>
							<cfelse>
									<cfif arguments.Price_Type EQ 0>
										<cfif arguments.Contract_Status GTE 3 AND arguments.margin_version eq "Approved">
											, CPMA.Cust_T_Target AS Target_Value
											, CPMA.Cust_T_Floor  AS Floor_Value
										<cfelse>		
											, CASE WHEN LEN(MTU.Net_Sales_Target_Value) = 0 THEN  MTU.GM_Target_Value ELSE MTU.Net_Sales_Target_Value END AS Target_Value
											, CASE WHEN LEN(MTU.Net_Sales_Floor_Value) = 0 THEN MTU.GM_Floor_Value ELSE MTU.Net_Sales_Floor_Value END AS Floor_Value
										</cfif>
										, CASE WHEN LEN(MTU.Net_Sales_Floor_Value) = 0 THEN 'GM' ELSE 'NS' END AS PriceType
									<cfelseif arguments.Price_Type EQ 1>
										<cfif arguments.Contract_Status GTE 3 AND arguments.margin_version eq "Approved">
											, CPMA.Cust_T_Target AS Target_Value
											, CPMA.Cust_T_Floor  AS Floor_Value
										<cfelse>		
											, MTU.Net_Sales_Target_Value  AS Target_Value
											, MTU.Net_Sales_Floor_Value  AS Floor_Value
											</cfif>
											, 'NS' AS PriceType
									<cfelse>
										<cfif arguments.Contract_Status GTE 3 AND arguments.margin_version eq "Approved">
											, CPMA.Cust_GM_Target AS Target_Value
											, CPMA.Cust_GM_Floor  AS Floor_Value
										<cfelse>		
											, MTU.GM_Target_Value  AS Target_Value
											, MTU.GM_Floor_Value  AS Floor_Value
											</cfif>
											 , 'GM' AS PriceType
									</cfif>
							</cfif>
							,##tmp_margin.Product_Id
						, Product_Program_Volume
						, cast(Product_Program_Volume * 365.00 / margin_multiplier AS decimal(20,0)) as Annual_Volume									
						, cast(1 as decimal(20, 5)) as Net_Sales_Index
					<cfif arguments.Price_Type EQ 2> <!--- GM --->
					   <cfif arguments.Contract_Status GTE 3 AND arguments.margin_version eq "Approved">
 					      <cfif arguments.UOM_Type EQ 1>
					       , CPMA.Operating_Income_CS AS Net_Sales
					       <cfelse>
					       , CPMA.Operating_Income_LB AS Net_Sales
					       </cfif>
					   <cfelse>
					       <cfif arguments.UOM_Type EQ 1>
					       , ##tmp_margin.Operating_Income_CS AS Net_Sales
					       <cfelse>
					       , ##tmp_margin.Operating_Income_LB AS Net_Sales
					       </cfif>
					   </cfif>
					<cfelse>
					   <cfif arguments.Contract_Status GTE 3 AND arguments.margin_version eq "Approved">
					       <cfif arguments.UOM_Type EQ 1>
					           , CPMA.Net_Sales_CS AS Net_Sales
					       <cfelse>
					           , CPMA.Net_Sales_LB AS Net_Sales
					       </cfif>
					   <cfelse>
						, Net_Sales AS Net_Sales	
					   </cfif>
					</cfif>

		INTO ##tmp_margin_result
		FROM   ##tmp_margin
		
		INNER JOIN BSA_Foodservice_Items_Master BSA
		ON BSA.BSA_Foodservice_Items_Master_ID = ##tmp_margin.Product_Id
		
		<cfif arguments.Contract_Status GTE 3 AND arguments.margin_version eq "Approved">
		INNER JOIN Contract_Product_Margin_Approved CPMA
		ON CPMA.Product_ID = ##tmp_margin.Product_Id
		AND CPMA.Contract_Main_ID = @Contract_Main_ID
		</cfif>

		LEFT JOIN Margin_Targets_Upload MTU
		ON MTU.BSA_Foodservice_Items_Master_ID  = ##tmp_margin.Product_Id

			<cfif arguments.Price_Type EQ 3>
					<!--- Execute below logic only when user selects net sales --->

					SELECT CM.Contract_Number
							, CM.Contract_Main_ID
							, cpm.Product_Id
							, <cfif arguments.UOM_Type EQ 1>cpm.Net_Sales_CS AS Net_Sales<cfelse>cpm.Net_Sales_LB AS Net_Sales</cfif>
							, ROW_NUMBER() Over (Partition By CM.Contract_Number,  CPM.Product_Id Order By (case when @Contract_End >= CM.Contract_Start_Date AND @Contract_Start >= CM.Contract_End_Date then 1 else 0 end)
							, CM.Contract_Start_Date) as Row_ID
					INTO  ##tmp_other_net_sales
					FROM  ##tmp_margin_result t
					INNER JOIN Contract_Product_Margin CPM
					ON CPM.Product_Id = t.Product_Id
					INNER JOIN Contract_Main CM
					ON CM.Contract_Main_ID = CPM.Contract_Main_ID
					AND CM.Deleted = 0
					AND CM.Contract_Status_Type_IDX in (4, 5)
					AND CM.Contract_Number != @Contract_Number

					SELECT Product_Id, Avg(Net_Sales) as Avg_Net_Sales
					INTO   ##tmp_other_net_sales_avg
					FROM   ##tmp_other_net_sales
					WHERE  Row_ID = 1
					GROUP BY Product_Id

					UPDATE t
					SET Net_Sales_Index = t.Net_Sales / ns.Avg_Net_Sales
					FROM ##tmp_margin_result t
					INNER JOIN ##tmp_other_net_sales_avg ns
					ON   ns.Product_Id = t.Product_Id
					AND ns.Avg_Net_Sales != 0

					<!--- Execute above logic only when user selects net sales --->


			</cfif>

				SELECT * FROM ##tmp_margin_result ORDER BY Item ASC
    </cfquery>
    <cfreturn qGetMTData>
</cffunction>

<cffunction name="downloadFile" output="true" returntype="any" hint="this function used to download margin targets of the program.">
		<cfargument name="Contract_Main_ID" type="numeric" required="true">
		<cfargument name="price_type" type="numeric" required="true">
		<cfargument name="uom_type" type="numeric" required="true">
		<cfargument name="margin_version" type="string" required="false" default="current">

<cfset programInfo = CreateObject("component", "components.programs.programManager").getProgramInfoComplete(arguments.contract_main_id) />
<cfset qGetMTData = this.MarginMatrix(#arguments.contract_main_id#,'#programInfo.Contract_Start_Date#','#programInfo.Contract_End_Date#','#programInfo.Contract_Number#',#programInfo.contract_Status_Type_IDX#,#arguments.Price_Type#,#arguments.uom_type#,#arguments.margin_version#)>

<cfif arguments.Price_Type EQ 3>
	<cfset q = queryNew("#application.returned_customer_setting.item_label#,Description,#replace(application.returned_customer_setting.type_code_label_singular,' ','','all')#,#replace(application.returned_customer_setting.type_group_label_singular,' ','','all')#,AnnualVolume,ProgramVolume,#application.returned_customer_setting.item_label#_Net_Sales_Value,#application.returned_customer_setting.item_label#_Net_Sales_Index", "cf_sql_varchar,cf_sql_varchar,cf_sql_varchar,cf_sql_varchar,cf_sql_varchar,cf_sql_varchar,cf_sql_varchar,cf_sql_varchar")> 
<cfelse>
	<cfset q = queryNew("#application.returned_customer_setting.item_label#,Description,#replace(application.returned_customer_setting.type_code_label_singular,' ','','all')#,#replace(application.returned_customer_setting.type_group_label_singular,' ','','all')#,Type,AnnualVolume,ProgramVolume,Program,Target,TargetVar,TargetVarPercentage,Floor, FloorVar, FloorVarPercentage", "cf_sql_varchar,cf_sql_varchar,cf_sql_varchar,cf_sql_varchar,cf_sql_varchar,cf_sql_varchar,cf_sql_varchar,cf_sql_varchar,cf_sql_varchar,cf_sql_varchar,cf_sql_varchar,cf_sql_varchar,cf_sql_varchar,cf_sql_varchar")> 
</cfif>

		<cfloop query="qGetMTData">
			<cfif (Floor_Value EQ "")>
				<cfset FloorValue = 0 />
			<cfelse>
				<cfset FloorValue = Floor_Value />
			</cfif>
			<cfif (Target_Value EQ "")>
				<cfset TargetValue = 0 />
			<cfelse>
				<cfset TargetValue = Target_Value />
			</cfif>
			<cfif (Net_Sales EQ "")>
				<cfset NetSales = 0 />
			<cfelse>
				<cfset NetSales = Net_Sales />
			</cfif>
			
			<cfset TartgetVar = NetSales - TargetValue>
			<cfset FloorVar = NetSales - FloorValue>

			<cfif (NetSales NEQ "" AND Val(TargetValue) NEQ 0)>
					<cfset TartgetVarPer = #NumberFormat(((( NetSales * 100)/TargetValue) - 100),'(9.99999)')# & '%'>
			<cfelse>
					<cfset TartgetVarPer = 'N/A'>
			</cfif>
						
			<cfif (NetSales NEQ "" AND Val(FloorValue) NEQ 0)>
					<cfset FloorVarPer = #NumberFormat((((NetSales * 100)/FloorValue) - 100),'(9.99999)')# & '%'>
			<cfelse>
					<cfset FloorVarPer = 'N/A'>
			</cfif>

			<cfset queryAddRow(q)>
			<cfset querySetCell(q, "#application.returned_customer_setting.item_label#", #item#)>
			<cfset querySetCell(q, "Description", #description#)>
			<cfset querySetCell(q, "#replace(application.returned_customer_setting.type_code_label_singular,' ','','all')#",#Type_Code_Desc#)>
			<cfset querySetCell(q, "#replace(application.returned_customer_setting.type_group_label_singular,' ','','all')#", #Type_Group_Desc#)>
		<cfif arguments.Price_Type NEQ 3>
			<cfset querySetCell(q, "Type", #PriceType#)>
		</cfif>
			<cfset querySetCell(q, "AnnualVolume", #Annual_Volume#)>
			<cfset querySetCell(q, "ProgramVolume", #Product_Program_Volume#)>
		<cfif arguments.Price_Type EQ 3>
			<cfset querySetCell(q, "#application.returned_customer_setting.item_label#_Net_Sales_Value", #NumberFormat(Net_Sales,'$(9.99999)')#)>
			<cfset querySetCell(q, "#application.returned_customer_setting.item_label#_Net_Sales_Index",#NumberFormat(Net_Sales_Index,'$(9.99999)')#)>			
		<cfelse>
			<cfset querySetCell(q, "Program", #NumberFormat(Net_Sales,'$(9.99999)')#)>
			<cfset querySetCell(q, "Target",#NumberFormat(Target_Value,'$(9.99999)')#)>
			<cfset querySetCell(q, "TargetVar", #NumberFormat(TartgetVar,'$(9.99999)')#)>
			<cfset querySetCell(q, "TargetVarPercentage", #TartgetVarPer#)>
			<cfset querySetCell(q, "Floor", #NumberFormat(FloorVar,'(9.99999)')#)>
			<cfset querySetCell(q, "FloorVar", #NumberFormat(FloorVar,'$(9.99999)')#)>
			<cfset querySetCell(q, "FloorVarPercentage",#FloorVarPer#)>
		</cfif>

		</cfloop>
			<cfset fname = #programInfo.contract_number#&'_Margin_Targets.xls'>
			<cfset filename = expandPath("./#fname#")>
			<!--- Make a spreadsheet object --->
			<cfset s = spreadsheetNew()>
			<!--- Add header row --->
			<cfif arguments.Price_Type EQ 3>
				<cfset spreadsheetAddRow(s, "#application.returned_customer_setting.item_label#,Description,#replace(application.returned_customer_setting.type_code_label_singular,' ','','all')#,#replace(application.returned_customer_setting.type_group_label_singular,' ','','all')#,AnnualVolume,ProgramVolume,#application.returned_customer_setting.item_label#_Net_Sales_Value,#application.returned_customer_setting.item_label#_Net_Sales_Index")>
			<cfelse>
				<cfset spreadsheetAddRow(s, "#application.returned_customer_setting.item_label#,Description,#replace(application.returned_customer_setting.type_code_label_singular,' ','','all')#,#replace(application.returned_customer_setting.type_group_label_singular,' ','','all')#,Type,AnnualVolume,ProgramVolume,Program,Target,TargetVar, TargetVarPercentage,Floor, FloorVar, FloorVarPercentage")>
			</cfif>
			<!--- Add query --->
			<cfset spreadsheetAddRows(s, q)>
	
			<cfheader name="content-disposition" value="attachment; filename=#fname#">
			<cfcontent type="application/msexcel" variable="#spreadsheetReadBinary(s)#" reset="true">

</cffunction>

<cffunction name="Attach2Program" output="true" returntype="boolean" hint="this function used to add margin targets to program.">
		<cfargument name="Contract_Main_ID" type="numeric" required="true">
		<cfargument name="price_type" type="numeric" required="true">
		<cfargument name="uom_type" type="numeric" required="true">
		<cfargument name="margin_version" type="string" required="false" default="current">

	<cfset added = 0>
	<cfset programInfo = CreateObject("component", "components.programs.programManager").getProgramInfoComplete(arguments.contract_main_id) />
	
	<!--- Dev Note(79426) - For "blanket bid price" --->
	<cfif arguments.price_type eq 4>
		<cfset objProgram = CreateObject("component", "components.programs.program") />
		<cfset qGetBlanketBidInfo = objProgram.getBlanketBidInfo(arguments.contract_main_id,arguments.uom_type,arguments..margin_version,programInfo.contract_Status_Type_IDX)>
		<cfset local.fileContents = objProgram.getBlanketBidInfoCSV(qGetBlanketBidInfo)>
		<cfset fname = #programInfo.contract_number#&'_'&#TimeFormat(now(), "HH_nn_ss")#&'_Blanket_Bid.csv'>
		<cfset fdesc = #programInfo.contract_number#&' Blanket Bid File'>
	<cfelse>
		<cfset qGetMTData = this.MarginMatrix(#arguments.contract_main_id#,'#programInfo.Contract_Start_Date#','#programInfo.Contract_End_Date#','#programInfo.Contract_Number#',#programInfo.contract_Status_Type_IDX#,#arguments.Price_Type#,#arguments.uom_type#,#arguments.margin_version#)>
		<cfset fname = #programInfo.contract_number#&'_'&#TimeFormat(now(), "HH_nn_ss")#&'_Margin_Targets.xls'>
		<cfset fdesc = #programInfo.contract_number#&' Margin Targets File'>
	</cfif>
	
	<!--- path and file name of the file to write the data to --->
	<cfset pathFileName = "#Application.Doc_Path#\Data_Files\Uploaded\Documents\Uploaded_Doc\#fname#" />
	
	<!--- Dev Note(79426) - For "blanket bid price" --->
	<cfif arguments.price_type eq 4> 
		<cffile action="write" file = "#pathFileName#" nameconflict = "overwrite" output="#local.fileContents#"/>
	<cfelse>
		<!--- Write the string buffer to the file, convert to String ---->
		<cfspreadsheet action="write" filename="#pathFileName#" query="qGetMTData" overwrite="true">
	</cfif>

	<cfquery name="qSave" datasource="#application.datasource#">
		DECLARE @newDocID UNIQUEIDENTIFIER
											
		  SET @newDocID = NewID()
			INSERT INTO	Document_Details(	
																																Doc_ID,
																																Doc_Uni_Name,
																																Doc_Title,
																																Doc_Description,
																																Uploaded_Date,
																																Uploaded_By,
																																Doc_File_Name,
																																Doc_Size,
																																Public_View
																														)
			VALUES	(	
							@newDocID
							,' #fname#'
							,' #fdesc#'
							,' #fdesc#'
							,#now()#
							,'#request.AccessStructure.user_id#'
							,' #fname#'
							,' 1'
							,0
					)

			INSERT INTO Contract_Attachments ( Program_ID, Doc_ID )	VALUES ( '#arguments.contract_main_id#',	@newDocID )
	</cfquery>

<cfset added = 1>
<cfreturn added>
</cffunction>

<cffunction name="ProductFilters" output="true" returntype="query" hint="this function used to display all attributes for products to filter">
	<cfargument name="Contract_Main_ID" required="false" default="0">
	<cfargument name="FirstParentID" required="false" default="0">
	<cfargument name="fromMTC" required="false" default="1">

		<cfquery name="qTemplateFilters" datasource="#application.datasource#">
			SELECT PGL.Group_Internal_Label
			FROM		Group_Template GT
			INNER JOIN Product_Group_Level PGL
			ON PGL.Product_Group_Level_ID = GT.Group_Level_ID
			WHERE GT.Deleted = 0
			AND GT.Active = 1
			AND GT.Template_ID = #arguments.FirstParentID#
			AND GT.PG_Group_Type = 1
			AND (Allow_In_Search = 1 OR Allow_In_Group_Search = 1)
			AND PGL.Group_Internal_Label in ('Type Group','Class Code','Q Brand','Type Code','Brand','Prod Var A')
		</cfquery>	
			
	<cfset templateFilters = valuelist(qTemplateFilters.Group_Internal_Label)>
	
	<cfquery name="qProductFilters" datasource="#application.datasource#">
		
			SELECT DISTINCT TCD.Type_Code_Desc_ID AS ID, TCD.Type_Code_Desc AS Description, PGL.Group_Level_Desc AS Category, PGL.Display_Sequence
			FROM Type_Code_Desc TCD
			INNER JOIN BSA_Foodservice_Items_Master BSA
			ON BSA.Type_Code_Desc_ID = TCD.Type_Code_Desc_ID
			<cfif arguments.fromMTC>
			INNER JOIN Margin_Targets_Upload MTU
			ON BSA.BSA_Foodservice_Items_Master_ID = MTU.BSA_Foodservice_Items_Master_ID
			</cfif>
			<cfif arguments.Contract_Main_ID>
			INNER JOIN Contract_Products CP
			ON CP.BSA_Foodservice_Items_Master_ID = BSA.BSA_Foodservice_Items_Master_ID
			AND CP.Contract_Main_id = #arguments.contract_main_id#
			</cfif>
			INNER JOIN Product_Group_Level PGL
			ON PGL.Group_Internal_Label = 'Type Code'
			WHERE BSA.Deleted = 0
			AND TCD.Deleted = 0
			<cfif arguments.FirstParentID AND ! LISTFIND(templateFilters,'Type Code')>AND 1 = 2 </cfif>
			
			UNION 			
		
			SELECT DISTINCT TGD.Type_Group_Desc_ID AS ID, TGD.Type_Group_Desc AS Description,  PGL.Group_Level_Desc AS Category, PGL.Display_Sequence
			FROM Type_Group_Desc TGD
			INNER JOIN BSA_Foodservice_Items_Master BSA
			ON BSA.Type_Group_Desc_ID = TGD.Type_Group_Desc_ID
			<cfif arguments.fromMTC>
			INNER JOIN Margin_Targets_Upload MTU
			ON BSA.BSA_Foodservice_Items_Master_ID = MTU.BSA_Foodservice_Items_Master_ID
			</cfif>
			<cfif arguments.Contract_Main_ID>
			INNER JOIN Contract_Products CP
			ON CP.BSA_Foodservice_Items_Master_ID = BSA.BSA_Foodservice_Items_Master_ID
			AND CP.Contract_Main_id = #arguments.contract_main_id#
			</cfif>	
			INNER JOIN Product_Group_Level PGL
			ON PGL.Group_Internal_Label = 'Type Group'
			WHERE BSA.Deleted = 0
			AND TGD.Deleted = 0
			<cfif arguments.FirstParentID AND ! LISTFIND(templateFilters,'Type Group')> AND 1 = 2 </cfif>
			
			UNION 			
		
			SELECT DISTINCT B.Brand_ID AS ID,  B.Brand_Name AS Description, PGL.Group_Level_Desc AS Category, PGL.Display_Sequence
			FROM Brand B
			INNER JOIN BSA_Foodservice_Items_Master BSA
			ON BSA.Brand_ID = B.Brand_ID
			<cfif arguments.fromMTC>
			INNER JOIN Margin_Targets_Upload MTU
			ON BSA.BSA_Foodservice_Items_Master_ID = MTU.BSA_Foodservice_Items_Master_ID
			</cfif>
			<cfif arguments.Contract_Main_ID>
			INNER JOIN Contract_Products CP
			ON CP.BSA_Foodservice_Items_Master_ID = BSA.BSA_Foodservice_Items_Master_ID
			AND CP.Contract_Main_id = #arguments.contract_main_id#
			</cfif>		
			INNER JOIN Product_Group_Level PGL
			ON PGL.Group_Internal_Label = 'Brand'
			WHERE BSA.Deleted = 0
			AND B.Deleted = 0
			<cfif arguments.FirstParentID AND ! LISTFIND(templateFilters,'Brand')> AND 1 = 2 </cfif>
			
			UNION 
				
			SELECT DISTINCT QBD.Q_Brand_ID AS ID,  QBD.Q_Brand AS Description, PGL.Group_Level_Desc AS Category, PGL.Display_Sequence
			FROM Q_Brand_Desc QBD
			INNER JOIN BSA_Foodservice_Items_Master BSA
			ON BSA.Q_Brand_ID = QBD.Q_Brand_ID
			<cfif arguments.fromMTC>
			INNER JOIN Margin_Targets_Upload MTU
			ON BSA.BSA_Foodservice_Items_Master_ID = MTU.BSA_Foodservice_Items_Master_ID
			</cfif>
			<cfif arguments.Contract_Main_ID>
			INNER JOIN Contract_Products CP
			ON CP.BSA_Foodservice_Items_Master_ID = BSA.BSA_Foodservice_Items_Master_ID
			AND CP.Contract_Main_id = #arguments.contract_main_id#
			</cfif>		
			INNER JOIN Product_Group_Level PGL
			ON PGL.Group_Internal_Label = 'Q Brand'	
			WHERE BSA.Deleted = 0
			AND QBD.Deleted = 0
			<cfif arguments.FirstParentID AND ! LISTFIND(templateFilters,'Q Brand')>	AND 1 = 2 </cfif>
			
			UNION 

			SELECT PVA.Prod_Var_A_ID AS ID,  PVA.Prod_Var_A_Desc AS Description, PGL.Group_Level_Desc AS Category, PGL.Display_Sequence
			FROM Prod_Var_A PVA
			INNER JOIN BSA_Foodservice_Items_Master BSA
			ON BSA.Prod_Var_A_ID = PVA.Prod_Var_A_ID
			<cfif arguments.fromMTC>
			INNER JOIN Margin_Targets_Upload MTU
			ON BSA.BSA_Foodservice_Items_Master_ID = MTU.BSA_Foodservice_Items_Master_ID
			</cfif>
			<cfif arguments.Contract_Main_ID>
			INNER JOIN Contract_Products CP
			ON CP.BSA_Foodservice_Items_Master_ID = BSA.BSA_Foodservice_Items_Master_ID
			AND CP.Contract_Main_id = #arguments.contract_main_id#
			</cfif>		
			INNER JOIN Product_Group_Level PGL
			ON PGL.Group_Internal_Label = 'Prod Var A'
			WHERE BSA.Deleted = 0
			AND PVA.Deleted = 0
			<cfif arguments.FirstParentID AND ! LISTFIND(templateFilters,'Prod Var A')>AND 1 = 2 </cfif>
			<cfif appSettings.get_Setting('Product_Group_Sequencing') eq '1'>
				ORDER BY PGL.Display_Sequence 
			<cfelse>
				ORDER BY 3
			</cfif>
	</cfquery>
	<cfreturn qProductFilters>
</cffunction>

</cfcomponent>