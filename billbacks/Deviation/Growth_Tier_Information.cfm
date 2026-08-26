<!------- Growth_Tier_Information.cfm ---->

<cfset Get_Tier_Info = bbDeviationManager.getGrowthTiers(This_Program_Growth_Component_ID, tierReached)>
<cfif Not IsDefined("GrowthComp")>
	<cfset GrowthComp =  CreateObject("component", "components.programs.Growth.GrowthComponent") />
</cfif>
<!--- Volume or Percent (1 is volume and 2 is percent) --->
<cfset GrowthTierUOM =  GrowthComp.GetGrowthTierPercentUOM(This_Program_Growth_Component_ID)>
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
If component UOM = 3 
	- Get prior year settings
	- Find prior year start and ed date
	- Get sum of volume for prior year
	- Translate the tiers to pound tiers
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<CFIF Component_UOM EQ 3>
	<!------ Get prior year settings ----->
	<!------ Prior_Yr_Comparison_Type ----->
	<!------ Prior_Yr_Sample_Period ----->
	<CFIF Prior_Yr_Comparison_Type EQ 2>
		<CFSET Prior_Year_End_Date 		= DateAdd("d", -1, Program_Start_Date)>
		<CFSET Prior_Year_Start_Date 	= DateAdd("d", Evaluate(Prior_Yr_Sample_Period * -1), Prior_Year_End_Date)>					
	<CFELSE>
		<CFSET Prior_Year_Start_Date 	= DateAdd("yyyy", -1, Program_Start_Date)>
		<CFSET Prior_Year_End_Date 		= DateAdd("yyyy", -1, Program_End_Date)>
	</CFIF>
	
	<CFQUERY  dataSource="#application.datasource#" NAME="Get_Prior_Year_Volume_Info">
		SELECT	DISTINCT 
				ROUND(SUM(CAST(IsNull(Pounds_Invoiced, 0) AS FLOAT)), 0) AS Sum_Pounds_Invoiced, ROUND(SUM(CAST(IsNull(Sales_Dollars, 0) AS FLOAT)), 0) AS Sum_Sales_Dollars
		FROM							
			Program_Growth_Component_Product_Data							
			INNER JOIN	Contract_Products
			ON
			(
				(Contract_Products.Contract_Products_ID = Program_Growth_Component_Product_Data.Contract_Products_ID)
				AND
				(Contract_Products.Deleted = 0)								
			)
			INNER JOIN	BSA_Foodservice_Items_Master
			ON
			(
				(BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID)								
			)								
			LEFT JOIN Invoice_Header
			ON
			(
				(Invoice_Header.BSA_Foodservice_Customers_ID = '#Payee_ID#')
				AND
				(DATEDIFF(d, #CreateODBCDate(Prior_Year_Start_Date)#, #check_Date#) >= 0)
				AND
				(DATEDIFF(d, #check_Date#, #CreateODBCDate(Prior_Year_End_Date)#) >= 0)
				AND
				(Invoice_Header.Deleted = 0)
			)
			LEFT JOIN	Invoice_Detail
			ON 
			(
				(Invoice_Detail.Invoice_Header_ID = Invoice_Header.Invoice_Header_ID)
				AND
				(Contract_Products.BSA_Foodservice_Items_Master_ID = Invoice_Detail.BSA_Foodservice_Items_Master_ID)
				AND
				(Invoice_Detail.Deleted = 0)
				AND	ISNULL(Invoice_Detail.FOB_PRICE_IND, 'N') IN (#ListQualify(Fob_Price_Indicator, "'", ",")#)
				<cfif appSettings.getCheckOrderClass()>
				AND Invoice_Detail.Order_Class IN (#ListQualify(appSettings.getOrderClassValue(), "'", ",")#)
				</cfif>
			)				
		WHERE	
			(
				(Program_Growth_Component_Product_Data.Program_Growth_Component_ID = '#Volume_Program_Growth_Component_ID#')
				AND
				(Program_Growth_Component_Product_Data.Deleted = 0)

			)					
	</CFQUERY>
	<CFSET Prior_Year_Volume = Get_Prior_Year_Volume_Info.Sum_Pounds_Invoiced>
	<CFSET Prior_Year_Volume_Percent = Prior_Year_Volume / 100>
	<CFSET Prior_Year_Sales_Dollars = Get_Prior_Year_Volume_Info.Sum_Sales_Dollars>
	<CFSET Prior_Year_Sales_Dollars_Percent = Prior_Year_Sales_Dollars / 100>

	
	<CFQUERY NAME="Get_Translated_Tiers" DATASOURCE="#application.datasource#">
		SELECT	
				Program_Growth_Component_Tiers.Tier_Number, 
				Program_Growth_Component_Tiers.Range_Start, 
				Program_Growth_Component_Tiers.Range_End,
				CASE
				WHEN C2.Range_End = '*' THEN
					C2.Range_End <!------/*would not be used*/----->
				WHEN C2.Program_Growth_Component_ID IS NULL THEN
					ROUND(CAST(Program_Growth_Component_Tiers.Range_Start AS FLOAT) * #Prior_Year_Volume_Percent# , 0) <!------ First Tier ----->					
				ELSE
					ROUND((CAST(C2.Range_End AS FLOAT) * #Prior_Year_Volume_Percent#) + 1 , 0) <!----- Remaining Tiers ------>
				END AS Pound_Range_Start,
				CASE
				WHEN C2.Program_Growth_Component_ID IS NULL THEN
					ROUND(CAST(Program_Growth_Component_Tiers.Range_Start AS FLOAT) * #Prior_Year_Sales_Dollars_Percent# , 0) <!------ First Tier ----->					
				ELSE
					ROUND((CAST(C2.Range_End AS FLOAT) * #Prior_Year_Sales_Dollars_Percent#) + 1 , 0) <!----- Remaining Tiers ------>
				END AS Sales_Dollars_Range_Start,
				CASE 
				WHEN Program_Growth_Component_Tiers.Range_End = '*' THEN
					Program_Growth_Component_Tiers.Range_End
				ELSE
					CAST(CAST(ROUND(CAST(Program_Growth_Component_Tiers.Range_End AS FLOAT) * #Prior_Year_Volume_Percent#, 0) AS DECIMAL(20, 0)) AS NVARCHAR(50))
				END AS Pound_Range_End,
				CASE
				WHEN Program_Growth_Component_Tiers.Range_End = '*' THEN
					Program_Growth_Component_Tiers.Range_End
				ELSE
					CAST(CAST(ROUND(CAST(Program_Growth_Component_Tiers.Range_End AS FLOAT) * #Prior_Year_Sales_Dollars_Percent#, 0) AS DECIMAL(20, 0)) AS NVARCHAR(50))
				END AS Sales_Dollars_Range_End
		FROM	Program_Growth_Component_Tiers
				LEFT JOIN Program_Growth_Component_Tiers C2
				ON
				C2.Program_Growth_Component_ID = Program_Growth_Component_Tiers.Program_Growth_Component_ID
				AND
				C2.Deleted = 0
				AND
				CAST(C2.Tier_Number AS INT) = (CAST(Program_Growth_Component_Tiers.Tier_Number AS INT) - 1)							
		WHERE
				Program_Growth_Component_Tiers.Program_Growth_Component_ID = '#Program_Growth_Component_ID#'
				AND Program_Growth_Component_Tiers.Deleted = 0
		ORDER BY Program_Growth_Component_Tiers.Tier_Number
	</CFQUERY>
	
<cfif GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID eq 2>
	<cfset Get_Translated_Tiers_For_Calc = bbDeviationManager.getGrowthPercentTiersAttained(Program_Growth_Component_ID, Total_Invoice_Statistics_In_Pgm_UOM, Prior_Year_Sales_Dollars_Percent, 1)>
			<cfset Growth_Comparison_Period_UOM = "Sales">
<cfelse>
	<cfset Get_Translated_Tiers_For_Calc = bbDeviationManager.getGrowthPercentTiersAttained(Program_Growth_Component_ID, Total_Invoice_Statistics_In_Pgm_UOM, Prior_Year_Volume_Percent, 1)>
			<cfset Growth_Comparison_Period_UOM = "Volume">
</cfif>

	<CFIF NOT FromLumpSum>
	<!---- Display translated triers ---->
	<CFOUTPUT>
	<TABLE ALIGN="center" CLASS="MainTable" CELLPADDING="2" CELLSPACING="0" BORDER="0" WIDTH="#Evaluate(Table_Width-200)#">
		<TR CLASS="MaintableTHEAD">
			<TD COLSPAN="100%">
			Previous year invoice #Growth_Comparison_Period_UOM# span = #DateFormat(Prior_Year_Start_Date, "mm/dd/yyyy")# - #DateFormat(Prior_Year_End_Date, "mm/dd/yyyy")#
			<BR>Previous year #Growth_Comparison_Period_UOM# 
			= <cfif GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID eq 2>#Prior_Year_Sales_Dollars#<cfelse>#Prior_Year_Volume#</cfif>
			</TD>
		</TR>
		<TR CLASS="MaintableTHEAD">
			<TD COLSPAN="2" BGCOLOR="FFCE84">#Growth_Comparison_Period_UOM# Range (%)</TD>
			<TD BGCOLOR="FFCE84"></TD>
			<TD COLSPAN="2" BGCOLOR="FFCE84">#Growth_Comparison_Period_UOM# Range <cfif GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID neq 2>(LB)</cfif></TD>
		</TR>
		<CFLOOP QUERY="Get_Translated_Tiers">
		<TR>
			<TD WIDTH="100">#Range_Start#</TD>
			<TD WIDTH="100">#Range_End#</TD>
			<TD WIDTH="30%" STYLE="border:none;font-family:'Courier New'font-weight:bold;color:blue;" ALIGN="center"> <B>----></B> </TD>
			<TD WIDTH="100"><cfif GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID eq 2>#Sales_Dollars_Range_Start#<cfelse>#Pound_Range_Start#</cfif></TD>
			<TD WIDTH="100"><cfif GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID eq 2>#Sales_Dollars_Range_End#<cfelse>#Pound_Range_End#</cfif></TD>
		</TR>
		</CFLOOP>
	</TABLE><BR></CFOUTPUT>
	</CFIF>
	<CFSET Get_Tier_Range_Info = Get_Translated_Tiers_For_Calc>			
	<CFSET Attained_Tier_ColumnVals = RepeatString("0,", Get_Tier_Range_Info.RecordCount)>
	<CFSET Attained_Tier_ColumnValsArr = ListToArray(Attained_Tier_ColumnVals , ",")>
	<CFSET D_Temp = QueryAddColumn(Get_Tier_Range_Info, "TIER_ATTAINED", Attained_Tier_ColumnValsArr)>
	<CFSET D_Temp = QueryAddColumn(Get_Tier_Range_Info, "TIER_ATTAINED_MULTI", Attained_Tier_ColumnValsArr)>
	
	<cfif Min_Purchase_Req_Failed EQ 0>
		<CFQUERY NAME="Get_Max_Tier" DBTYPE="query">
			SELECT MAX(Tier_Number) AS Max_Tier_Number
			FROM	Get_Tier_Range_Info
		</CFQUERY>
		<CFSET Max_Tier = Get_Max_Tier.Max_Tier_Number>
		<CFQUERY NAME="Get_Attained_Tier" DBTYPE="query">
			SELECT	Tier_Number
			FROM	Get_Tier_Range_Info
			WHERE
					RANGE_START <=
						#Total_Invoice_Statistics_In_Pgm_UOM#
					AND
					(
						EFFECTIVE_RANGE_END >= #Total_Invoice_Statistics_In_Pgm_UOM#
						OR
						Tier_Number = #Max_Tier#
					)
		</CFQUERY>
		<CFIF Get_Attained_Tier.RecordCount GT 0>
			<CFSET D_Temp = QuerySetCell(Get_Tier_Range_Info, "TIER_ATTAINED", 1, Get_Attained_Tier.Tier_Number)>
		</CFIF>	
		<CFQUERY NAME="Get_Attained_Tier_Multi" DBTYPE="query">
			SELECT	Tier_Number
			FROM	Get_Tier_Range_Info
			WHERE
					RANGE_START <= 	#Total_Invoice_Statistics_In_Pgm_UOM#
		</CFQUERY>
		<CFLOOP QUERY="Get_Attained_Tier_Multi">
			<CFSET D_Temp = QuerySetCell(Get_Tier_Range_Info, "TIER_ATTAINED_MULTI", 1, Get_Attained_Tier_Multi.Tier_Number)>
		</CFLOOP>
	</cfif>
	
<CFELSE>
	<CFQUERY NAME="Get_Tier_Range_Info" DATASOURCE="#application.datasource#">
		SELECT	Growth_Amount, 
				CAST(Tier_Number AS INT) Tier_Number,
				CASE 
				WHEN Range_End  = '*' THEN #Total_Invoice_Statistics_In_Pgm_UOM#
				WHEN 
					#Total_Invoice_Statistics_In_Pgm_UOM# < CAST(Range_End AS FLOAT) THEN #Total_Invoice_Statistics_In_Pgm_UOM#
				ELSE
					Range_End
				END AS Effective_Range_End
				, Range_Start
				, Range_End
				<cfif Min_Purchase_Req_Failed EQ 1>
				, 0 AS Tier_Attained
				, 0 AS Tier_Attained_Multi
				<cfelse>
				,CASE
				WHEN #Total_Invoice_Statistics_In_Pgm_UOM# >= CAST(Range_Start AS FLOAT) THEN
					CASE
					WHEN Range_End = '*' THEN
						1					
					WHEN #Total_Invoice_Statistics_In_Pgm_UOM# <= CAST(Range_End AS FLOAT) THEN
						1
					WHEN #Total_Invoice_Statistics_In_Pgm_UOM# > CAST(Range_End AS FLOAT) AND (Tier_Number = (SELECT MAX(Tiers.Tier_Number) FROM Program_Growth_Component_Tiers Tiers WHERE Tiers.Program_Growth_Component_ID = Program_Growth_Component_Tiers.Program_Growth_Component_ID)) THEN
						1
					ELSE
						0
					END
				ELSE
					0
				END AS Tier_Attained
				,CASE
				WHEN #Total_Invoice_Statistics_In_Pgm_UOM# >= CAST(Range_Start AS FLOAT) THEN
					1
				ELSE
					0
				END AS Tier_Attained_Multi
				</cfif>						
		FROM	Program_Growth_Component_Tiers
		WHERE
				Program_Growth_Component_Tiers.Program_Growth_Component_ID = '#This_Program_Growth_Component_ID#'								
				AND
				Program_Growth_Component_Tiers.Deleted = 0
		ORDER BY Tier_Number
	</CFQUERY>
</CFIF>