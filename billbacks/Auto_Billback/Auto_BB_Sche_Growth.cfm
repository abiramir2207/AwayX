<CFOUTPUT>BBID: #Billback_ID#</CFOUTPUT>----


<!--- Products --->
<CFQUERY NAME="GetBBStartEndDate" DATASOURCE="#Application.Datasource#">
	SELECT 	BB_Start_Date,
			BB_End_Date 
			
	FROM 	Billback 
	
	WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
</CFQUERY>
<CFSET TrimBB_Start_Date = DateFormat(GetBBStartEndDate.BB_Start_Date,"mm/dd/yyyy")>
<CFSET TrimBB_End_Date = DateFormat(GetBBStartEndDate.BB_End_Date,"mm/dd/yyyy")>


<CFQUERY NAME="DeletedProducts" DATASOURCE="#Application.Datasource#">
	UPDATE 	Billback_Product
	SET 	Deleted = 1
	
	WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND
			Deleted = 0
</CFQUERY>
<CFQUERY NAME="DeleteFromDetails" DATASOURCE="#Application.Datasource#">
	UPDATE 	Billback_Product_Detail
	
	SET 	Deleted = 1
	
	WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND
			Deleted = 0
</CFQUERY>
<CFIF ISDefined("FORM.Get_All_Items")>
	<CFQUERY NAME="DeletedAny" DATASOURCE="#Application.Datasource#">
		UPDATE Billback_Auto_Any_Option
		
		SET 	Deleted = 1
		
		WHERE	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND
				Deleted = 0		
	</CFQUERY>
</CFIF>

<CFIF IsDefined("FORM.Program_List")>
	<CFSET ProgramList = FORM.Program_List>
<CFELSE>
	<CFQUERY NAME="GetProgList" DATASOURCE="#Application.Datasource#">
		SELECT 	Program_ID 
		
		FROM 	Billback_Program 
		
		WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND 
				Deleted = 0
	</CFQUERY>
	<CFSET ProgramList = VALUELIST(GetProgList.Program_ID)>
</CFIF>

<CFQUERY NAME="BBProgramID" DATASOURCE="#Application.Datasource#">
	SELECT 	Billback_Program_ID 
	
	FROM 	Billback_Program 
	
	WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND
			Program_ID = <cfqueryparam value="#ProgramList#" cfsqltype="CF_SQL_INTEGER"> AND 				
			Deleted = 0
</CFQUERY>

<CFQUERY NAME="TET" DATASOURCE="#Application.Datasource#">
	SELECT 	BB_Tolerance_TET
	FROM 	Billback_Settings
</CFQUERY>
	
<CFQUERY NAME="GetContractNumber" DATASOURCE="#Application.Datasource#">
	SELECT 	Contract_Number,Contract_Quantity_UOM_IDX
	FROM 	Contract_main 
	WHERE 	Contract_Main_ID = <cfqueryparam value="#ProgramList#" cfsqltype="CF_SQL_INTEGER">
</CFQUERY>
<CFSET ThisProgramUOM = GetContractNumber.Contract_Quantity_UOM_IDX>

<cfquery name="PopulateTables" datasource="#application.datasource#">
	EXEC BB_D_Program_Detail <cfqueryparam value="#ProgramList#" cfsqltype="CF_SQL_INTEGER">
</cfquery>

<CFQUERY NAME="GetProgramSpan" DATASOURCE="#Application.Datasource#">
	SELECT 	MIN(Approval_start_Date) ProgSpanStartDate, 
			MAX(Approval_End_Date) ProgSpanEndDate

	FROM 	BB_Program_Info
	WHERE 	Contract_Number = <cfqueryparam value="#GetContractNumber.Contract_Number#" cfsqltype="CF_SQL_VARCHAR">
	AND 	Deleted = 0
</CFQUERY>

<CFSET GrowthStartDateForInvoice = GetProgramSpan.ProgSpanStartDate>

<CFSET CompareStartDate = DateCompare(TrimBB_Start_Date, GetProgramSpan.ProgSpanStartDate,"d")> 
	
<CFSET StartDateForInvoice = TrimBB_Start_Date>
<CFIF CompareStartDate LT 0>
	<CFSET StartDateForInvoice = GetProgramSpan.ProgSpanStartDate>		
</CFIF>

<CFSET CompareEndDate = DateCompare(TrimBB_End_Date,GetProgramSpan.ProgSpanEndDate,"d")>

<CFSET EndDateForInvoice = TrimBB_End_Date>
<CFIF CompareEndDate GT 0>
	<CFSET EndDateForInvoice = GetProgramSpan.ProgSpanEndDate>
</CFIF>

<CFQUERY NAME="GetAllContractID" DATASOURCE="#Application.Datasource#">
	SELECT 	Contract_Main_ID
	FROM 	BB_Program_Info
	WHERE 	Contract_Number = <cfqueryparam value="#GetContractNumber.Contract_Number#" cfsqltype="CF_SQL_VARCHAR">
	AND 	Deleted = 0
</CFQUERY>
<CFSET ContractIDList = VALUELIST(GetAllContractID.Contract_Main_ID)>

<CFLOOP QUERY="GetAllContractID">
	<CFQUERY NAME="PopulateTCTables" DATASOURCE="#application.datasource#">
		EXEC TC_PROGRAM_PRODUCT_DETAIL @@A_ID = <cfqueryparam value="#Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER">, @@CUSTOMER_ID = <cfqueryparam value="#FORM.Distributor_List#" cfsqltype="CF_SQL_VARCHAR">
	</CFQUERY>
</CFLOOP>

<CFQUERY NAME="GetProducts" DATASOURCE="#Application.Datasource#">
	SELECT 	DISTINCT BSA_Foodservice_Items_Master_ID
	FROM 	Contract_Products
	WHERE	Contract_Main_ID IN (#ContractIDList#) AND 
			Product_Type_ID NOT IN (3,8) AND
			Deleted = 0
</CFQUERY>
<CFSET ItemsList = VALUELIST(GetProducts.BSA_Foodservice_Items_Master_ID)>
<!--- <CFDUMP VAR="#GetProducts#"> --->

<CFIF ItemsList NEQ "">
	<CFQUERY NAME="GetInvoiceDetails" DATASOURCE="#Application.Datasource#">
		SELECT 		Invoice_Detail.BSA_Foodservice_Items_Master_ID ,
					CAST(Invoice_Detail.Pounds_Invoiced AS Float) Pounds_Invoiced, 
					CAST(Invoice_Detail.Cases_Invoiced AS Float) Cases_Invoiced, 
					Invoice_Header.Invoice_Date,
					Invoice_Header.Ship_Date,
					CAST(Invoice_Detail.LB_Unit_Price AS Float) LB_Unit_Price,
					CAST(Invoice_Detail.CS_Unit_Price AS Float) CS_Unit_Price,
					Invoice_Detail.Gross_Sales_Dollars,
					Gross_Sales_Dollars
					
		FROM 		Invoice_Header
		
		INNER JOIN 	Invoice_Detail ON Invoice_Header.Invoice_Header_ID = Invoice_Detail.Invoice_Header_ID
		
		WHERE 		Invoice_Detail.BSA_Foodservice_Items_Master_ID IN (	SELECT 	DISTINCT BSA_Foodservice_Items_Master_ID
																			FROM 	Contract_Products
																			WHERE	Contract_Main_ID IN (#ContractIDList#) AND 
																					Product_Type_ID NOT IN (3,8) AND
																					Deleted = 0									) AND 
					Invoice_Header.BSA_Foodservice_Customers_ID = <cfqueryparam value="#FORM.Distributor_List#" cfsqltype="CF_SQL_VARCHAR"> AND 
					<cfif TET.BB_Tolerance_TET IS 1>
						(	
							Invoice_Header.Invoice_Date >= '#dateformat(StartDateForInvoice)#' AND
							Invoice_Header.Invoice_Date <= '#dateformat(EndDateForInvoice)#'		
						)
					<cfelse>
						(	
							Invoice_Header.Ship_Date >= '#dateformat(StartDateForInvoice)#' AND
							Invoice_Header.Ship_Date <= '#dateformat(EndDateForInvoice)#'
						)
					</cfif> AND
					Invoice_Header.Order_Status = 'I' AND
					Invoice_Header.Deleted = 0 AND
					Invoice_Detail.Deleted = 0
					
		ORDER BY BSA_Foodservice_Items_Master_ID,Invoice_Header.Invoice_Date DESC
	</CFQUERY> 
<CFELSE>
	<CFIF IsDefined("FromScheduledAutoBB")>
		<CFINCLUDE template="Autoo_BB_Scheduled_Without_Invoice.cfm">
	<CFELSE>
		<CFOUTPUT>
		<CFLOCATION URL="/billbacks/capture/billback_summary.cfm?BBID=#Billback_ID#" ADDTOKEN="No">
		</CFOUTPUT>
		<CFABORT>
	</CFIF>
</CFIF>

<!--- GetInvoiceDetails
<CFDUMP VAR="#GetInvoiceDetails#"> --->


 
<!--- Growth, Growth LumpSum And LumpSum --->
<CFQUERY NAME="DeleteGrowth" DATASOURCE="#Application.Datasource#">
	UPDATE Billback_Program_Lumpsum_Component
	SET	Deleted = 1
	WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND Deleted = 0
</CFQUERY>

<CFLOOP LIST="#ProgramList#" INDEX="Item">
	<CFQUERY NAME="CallThisStoredProcedure" DATASOURCE="#Application.Datasource#">
		EXEC BB_D_Program_Detail <cfqueryparam value="#Item#" cfsqltype="CF_SQL_VARCHAR">
	</CFQUERY>
	
	<CFQUERY NAME="GetContractNumber" DATASOURCE="#Application.Datasource#">
		SELECT Contract_Number FROM Contract_Main WHERE Contract_Main_ID = <cfqueryparam value="#Item#" cfsqltype="CF_SQL_INTEGER">
	</CFQUERY>
	
	<CFQUERY  NAME="GetProgramEndDate" DATASOURCE="#application.datasource#">
		SELECT 	MAX(Approval_End_Date) AS Program_End_Date
		
		FROM 	BB_Program_Info 

		WHERE	BB_Program_Info.Contract_Number = <cfqueryparam value="#GetContractNumber.Contract_Number#" cfsqltype="CF_SQL_VARCHAR">
		AND		BB_Program_Info.Deleted = 0				
	</CFQUERY>
	<CFSET Program_End_Date = GetProgramEndDate.Program_End_Date>
	
	<CFIF DATEDIFF("d", Program_End_Date, TrimBB_End_Date) GTE 0>
		<CFSET Lumpsum_End_Date = Program_End_Date>
	<CFELSE>
		<CFSET Lumpsum_End_Date = TrimBB_End_Date>
	</CFIF>

	<CFQUERY NAME="GetBBProgram_ID" DATASOURCE="#Application.Datasource#">
		SELECT 	Billback_Program_ID 
		FROM 	Billback_Program 
		WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND
				Program_ID = <cfqueryparam value="#Item#" cfsqltype="CF_SQL_INTEGER"> AND 				
				Deleted = 0
	</CFQUERY>
	
	
	<!--- GrowthLumpSum --->
	<CFQUERY NAME="GetComponentID" DATASOURCE="#Application.Datasource#">
		SELECT		Program_Growth_Component_ID,
					Component_UOM, 
					Comparison_Type, 
					Sample_Period, 
					Rate_Type,
					Contract_Main.Contract_Main_ID ForGrowthContractMain
					
		
		FROM		Contract_Main
		
		INNER JOIN	BB_Program_Info ON BB_Program_Info.Contract_Main_ID = Contract_Main.Contract_Main_ID AND					
					DATEDIFF(d, Approval_Start_Date, #createodbcdate(Lumpsum_End_Date)#) >= 0 AND
					DATEDIFF(d, #createodbcdate(Lumpsum_End_Date)#, Approval_End_Date) >= 0 AND
					BB_Program_Info.Deleted = 0
									
		INNER JOIN	Program_Growth_Components ON Program_Growth_Components.Program_ID = Contract_Main.Contract_Main_ID AND
					Program_Growth_Components.Deleted = 0		
					
		WHERE		Contract_Main.Contract_Number = <cfqueryparam value="#GetContractNumber.Contract_Number#" cfsqltype="CF_SQL_VARCHAR">
	</CFQUERY>

	<!--- GetComponentID --->
<!--- 	<CFDUMP VAR="#GetComponentID#"> --->
	
	<CFIF GetComponentID.Recordcount GT 0>
		<CFLOOP QUERY="GetComponentID">
			
			<CFSET ComponentUOM = Component_UOM>
			<CFSET ProgramGrowthComponentID = Program_Growth_Component_ID>
			<CFSET RateType = Rate_Type>
			<CFSET ComponentVolume = 0>
			
			<CFQUERY NAME="GetItemsInComponent" DATASOURCE="#Application.Datasource#">
				SELECT  	BSA_Foodservice_Items_Master_ID, 
	                    	Program_Growth_Component_Product_Data_ID, 
	                    	Program_Growth_Component_ID
						
				FROM		Program_Growth_Component_Product_Data 
				INNER JOIN  Contract_Products ON Program_Growth_Component_Product_Data.Contract_Products_ID = dbo.Contract_Products.Contract_Products_ID
						
				WHERE     	Program_Growth_Component_ID = <cfqueryparam value="#Program_Growth_Component_ID#" cfsqltype="CF_SQL_VARCHAR"> AND
							Contract_Products.Deleted = 0 AND 
							Program_Growth_Component_Product_Data.Deleted = 0 
			</CFQUERY>
			<CFSET ItemSIDList = VALUELIST(GetItemsInComponent.BSA_Foodservice_Items_Master_ID)>
			
			<CFIF ItemSIDList NEQ "">
				<CFQUERY NAME="GetInvoiceDetails" DATASOURCE="#Application.Datasource#">
					SELECT 		Invoice_Detail.BSA_Foodservice_Items_Master_ID ,
								CAST(Invoice_Detail.Pounds_Invoiced AS Float) Pounds_Invoiced, 
								CAST(Invoice_Detail.Cases_Invoiced AS Float) Cases_Invoiced, 
								Invoice_Header.Invoice_Date,
								Invoice_Header.Ship_Date,
								CAST(Invoice_Detail.LB_Unit_Price AS Float) LB_Unit_Price,
								CAST(Invoice_Detail.CS_Unit_Price AS Float) CS_Unit_Price
								
					FROM 		Invoice_Header
					
					INNER JOIN 	Invoice_Detail ON Invoice_Header.Invoice_Header_ID = Invoice_Detail.Invoice_Header_ID
					
					WHERE 		Invoice_Detail.BSA_Foodservice_Items_Master_ID IN (	SELECT  	BSA_Foodservice_Items_Master_ID
																			                    	
																						FROM		Program_Growth_Component_Product_Data 
																						INNER JOIN  Contract_Products ON Program_Growth_Component_Product_Data.Contract_Products_ID = dbo.Contract_Products.Contract_Products_ID
																								
																						WHERE     	Program_Growth_Component_ID = '#Program_Growth_Component_ID#' AND
																									Contract_Products.Deleted = 0 AND 
																									Program_Growth_Component_Product_Data.Deleted = 0) AND 
								Invoice_Header.BSA_Foodservice_Customers_ID = <cfqueryparam value="#FORM.Distributor_List#" cfsqltype="CF_SQL_VARCHAR"> AND 
								<cfif TET.BB_Tolerance_TET IS 1>
									(	
										Invoice_Header.Invoice_Date >= '#dateformat(GrowthStartDateForInvoice)#' AND
										Invoice_Header.Invoice_Date <= '#dateformat(EndDateForInvoice)#'		
									)
								<cfelse>
									(	
										Invoice_Header.Ship_Date >= '#dateformat(StartDateForInvoice)#' AND
										Invoice_Header.Ship_Date <= '#dateformat(EndDateForInvoice)#'
									)
								</cfif> AND
								Invoice_Header.Order_Status = 'I' AND
								Invoice_Header.Deleted = 0 AND
								Invoice_Detail.Deleted = 0
								
					ORDER BY BSA_Foodservice_Items_Master_ID,Invoice_Header.Invoice_Date DESC
				</CFQUERY> 
			</CFIF>
			
			<!--- <CFDUMP VAR="#GetInvoiceDetails#"> --->

			<CFIF  ComponentUOM EQ 3>
				
				<CFQUERY NAME="DateRange" DATASOURCE="#Application.Datasource#">
					SELECT 	MIN(Approval_start_Date) Contract_Start_Date, 
							MAX(Approval_End_Date) Contract_End_Date
				
					FROM 	BB_Program_Info
					WHERE 	Contract_Number = '#GetContractNumber.Contract_Number#' AND Deleted = 0
				</CFQUERY>
				<!--- <CFDUMP VAR="#DateRange#"> --->
				
				<CFIF Comparison_Type EQ 2>
					<cfif IsLeapYear(Year(DateRange.Contract_Start_Date)) AND Month(DateRange.Contract_Start_Date) EQ 12 AND Day(DateRange.Contract_Start_Date) EQ 31>
                    	<CFSET TierEndDateForInvoice = DateAdd("yyyy", -1, DateAdd("d", -1, DateRange.Contract_Start_Date))>
                    <cfelse>
                    	<CFSET TierEndDateForInvoice = DateAdd("yyyy", -1, DateRange.Contract_Start_Date)>
                    </cfif>
					
					<cfif IsLeapYear(Year(TierEndDateForInvoice)) AND Month(TierEndDateForInvoice) EQ 12 AND Day(TierEndDateForInvoice) EQ 31>
                    	<CFSET TierStartDateForInvoice = DateAdd("yyyy", Evaluate(Sample_Period * -1), DateAdd("d", -1, TierEndDateForInvoice))>
                    <cfelse>
                    	<CFSET TierStartDateForInvoice = DateAdd("yyyy", Evaluate(Sample_Period * -1), TierEndDateForInvoice)>
                    </cfif>
				<CFELSE>					
					<cfif IsLeapYear(Year(DateRange.Contract_Start_Date)) AND Month(DateRange.Contract_Start_Date) EQ 12 AND Day(DateRange.Contract_Start_Date) EQ 31>
                    	<CFSET TierStartDateForInvoice = DateAdd("yyyy", -1, DateAdd("d", -1, DateRange.Contract_Start_Date))>
                    <cfelse>
                    	<CFSET TierStartDateForInvoice = DateAdd("yyyy", -1, DateRange.Contract_Start_Date)>
                    </cfif>
					
					<cfif IsLeapYear(Year(DateRange.Contract_End_Date)) AND Month(DateRange.Contract_End_Date) EQ 12 AND Day(DateRange.Contract_End_Date) EQ 31>
                    	<CFSET TierEndDateForInvoice = DateAdd("yyyy", -1, DateAdd("d", -1, DateRange.Contract_End_Date))>
                    <cfelse>
                    	<CFSET TierEndDateForInvoice = DateAdd("yyyy", -1, DateRange.Contract_End_Date)>
                    </cfif>
				</CFIF>
				
				<CFQUERY NAME="InvoiceToCalTier" DATASOURCE="#Application.Datasource#">
					SELECT 		ROUND(SUM(CAST(IsNull(Invoice_Detail.Pounds_Invoiced,0) AS Float)),0) SUMPounds_Invoiced
								
					FROM 		Invoice_Header
					
					INNER JOIN 	Invoice_Detail ON Invoice_Header.Invoice_Header_ID = Invoice_Detail.Invoice_Header_ID
					
					WHERE 		Invoice_Detail.BSA_Foodservice_Items_Master_ID IN (	SELECT  	BSA_Foodservice_Items_Master_ID
																			                    	
																						FROM		Program_Growth_Component_Product_Data 
																						INNER JOIN  Contract_Products ON Program_Growth_Component_Product_Data.Contract_Products_ID = dbo.Contract_Products.Contract_Products_ID
																								
																						WHERE     	Program_Growth_Component_ID = '#Program_Growth_Component_ID#' AND
																									Contract_Products.Deleted = 0 AND 
																									Program_Growth_Component_Product_Data.Deleted = 0 					) AND 
								Invoice_Header.BSA_Foodservice_Customers_ID = <cfqueryparam value="#FORM.Distributor_List#" cfsqltype="CF_SQL_VARCHAR"> AND 
								<cfif TET.BB_Tolerance_TET IS 1>
									(	
										Invoice_Header.Invoice_Date >= '#dateformat(TierStartDateForInvoice)#' AND
										Invoice_Header.Invoice_Date <= '#dateformat(TierEndDateForInvoice)#'		
									)
								<cfelse>
									(	
										Invoice_Header.Ship_Date >= '#dateformat(TierStartDateForInvoice)#' AND
										Invoice_Header.Ship_Date <= '#dateformat(TierEndDateForInvoice)#'
									)
								</cfif> AND
								Invoice_Header.Order_Status = 'I' AND
								Invoice_Header.Deleted = 0 AND
								Invoice_Detail.Deleted = 0													
				</CFQUERY>

				<CFSET TierCalComponentTotal = InvoiceToCalTier.SUMPounds_Invoiced>
				<CFIF TierCalComponentTotal EQ "">
					<CFSET TierCalComponentTotal = 0>
				</CFIF>
			</CFIF>

			
			<CFSET ItemVolume = 0>
			<CFQUERY NAME="GetItemsInvoiceVolume" DBTYPE="QUERY">
				SELECT 	SUM(Cases_Invoiced) Cases_Invoiced,
						SUM(Pounds_Invoiced) Pounds_Invoiced,
						BSA_Foodservice_Items_Master_ID 
						
				FROM 	GetInvoiceDetails
				
				GROUP BY BSA_Foodservice_Items_Master_ID
			</CFQUERY>
				
			<CFQUERY NAME="GetCompVolume" DBTYPE="Query">
				SELECT 	SUM(Cases_Invoiced) ComponentSUM_Cases,
						SUM(Pounds_Invoiced) ComponentSUM_Pounds
						
				FROM 	GetItemsInvoiceVolume				
			</CFQUERY>						
			
			
			<CFSET ItemCount = 0>
			<CFLOOP QUERY="GetItemsInvoiceVolume">			
				
				<CFSET ItemCount = ItemCount + 1>
				
								
				<CFIF ComponentUOM EQ 1>
					<CFSET ItemsFinalVolume = Cases_Invoiced>
					<CFSET ComponentTotal = GetCompVolume.ComponentSUM_Cases>
				<CFELSEIF ComponentUOM EQ 2>
					<CFSET ItemsFinalVolume = Pounds_Invoiced>
					<CFSET ComponentTotal = GetCompVolume.ComponentSUM_Pounds>
				<CFELSEIF ComponentUOM EQ 3>
					<CFSET ItemsFinalVolume = Pounds_Invoiced>
					<CFSET ComponentTotal = GetCompVolume.ComponentSUM_Pounds>
				</CFIF>	
				
				<CFSET Allocation = ItemsFinalVolume / ComponentTotal>
				
				<CFQUERY NAME="GetGrowthProductID" DBTYPE="QUERY">
					SELECT 	Program_Growth_Component_Product_Data_ID
							 
					FROM 	GetItemsInComponent
					
					WHERE 	BSA_Foodservice_Items_Master_ID = <cfqueryparam value="#BSA_Foodservice_Items_Master_ID#" cfsqltype="CF_SQL_VARCHAR">
				</CFQUERY>
				
				
				
				
				<CFQUERY NAME="GetNetWeight" DATASOURCE="#Application.Datasource#">
					SELECT 	BSA_Foodservice_Items_Master_ID,
							Net_Weight 
							
					FROM 	BSA_Foodservice_Items_Master 
					WHERE 	BSA_Foodservice_Items_Master_ID = <cfqueryparam value="#BSA_Foodservice_Items_Master_ID#" cfsqltype="CF_SQL_VARCHAR">
					AND		Deleted = 0
				</CFQUERY>
				
				
			
				<CFQUERY NAME="GetItemsTierInfo" DATASOURCE="#Application.Datasource#">
					SELECT 		Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID,
								Tier_Number,
					 			Range_Start,
								Range_End,
								<CFIF ComponentUOM NEQ 3>
								CASE
									WHEN Range_End <> '*' THEN								
										(CAST(Range_End AS Float) - CAST(Range_Start AS Float) + 1)
									ELSE
										(#ComponentTotal# - CAST(Range_Start AS Float) + 1)
								END Delta,
								</CFIF>
								Rate,
								Unit_Of_Measure_ID,
								Growth_Amount								
							
					FROM 		Program_Growth_Component_Tiers 
					
					INNER JOIN 	Program_Growth_Component_Product_Tier_Data ON Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Tier_ID = Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID AND
								Program_Growth_Component_Product_Data_ID = '#GetGrowthProductID.Program_Growth_Component_Product_Data_ID#' AND 
								Program_Growth_Component_Product_Tier_Data.Deleted = 0
										
					WHERE 		Program_Growth_Component_ID = <cfqueryparam value="#ProgramGrowthComponentID#" cfsqltype="CF_SQL_VARCHAR"> AND
								<CFIF ComponentUOM NEQ 3>
								CAST(Range_Start AS Float) <= <cfqueryparam value="#ComponentTotal#" cfsqltype="CF_SQL_FLOAT"> AND
								</CFIF>								
								Program_Growth_Component_Tiers.Deleted = 0
								
					ORDER BY 	Tier_Number
				</CFQUERY>	
			<!--- 	<CFDUMP VAR="#GetItemsTierInfo#"> --->
				<CFIF ComponentUOM EQ 3>
					<CFSET BreakLoop = 0>

					<!--- <CFSET ComponentTotal = 33700>  --->
					<CFLOOP QUERY="GetItemsTierInfo">						

						<CFIF BreakLoop EQ 0>
							<CFIF Tier_Number EQ 1>
								<CFSET StartRangeVolumeInLB = (TierCalComponentTotal * Range_Start / 100)>	
								<CFSET StartRangeVolumeInLB = ROUND(StartRangeVolumeInLB)>
							<CFELSE>
								<CFSET StartRangeVolumeInLB = (PreviousEnd + 1)>
							</CFIF>
							
							<CFIF Range_End NEQ "*">
								<CFSET EndRangeVolumeInLB = (TierCalComponentTotal * Range_End / 100)>
								<CFSET EndRangeVolumeInLB = ROUND(EndRangeVolumeInLB)>
								<CFSET PreviousEnd = EndRangeVolumeInLB>	
							<CFELSE>
								<CFSET EndRangeVolumeInLB = "*">
							</CFIF>
							
							<CFIF IsNumeric(EndRangeVolumeInLB)>
								<CFIF EndRangeVolumeInLB GTE ComponentTotal>
									<CFSET BreakLoop = 1>
									<CFSET TierReachedUOM3 = Tier_Number>
									<CFSET RateOfTierReached = Rate>
									<CFSET UOMOfTierReached = Unit_Of_Measure_ID>
									
									<CFIF StartRangeVolumeInLB GT ComponentTotal>
										<CFSET TierReachedUOM3 = Tier_Number - 1>
										<CFSET RateOfTierReached = 0>
										<CFSET UOMOfTierReached = 0>
									</CFIF>
									
								</CFIF>
							<CFELSEIF EndRangeVolumeInLB EQ "*">
								<CFSET BreakLoop = 1>
								<CFSET TierReachedUOM3 = Tier_Number>
								<CFSET RateOfTierReached = Rate>
								<CFSET UOMOfTierReached = Unit_Of_Measure_ID>							
							</CFIF>																	
							
						</CFIF>								
						
					</CFLOOP>
					
				<CFELSE>
					<CFIF RateType EQ 1>
						<CFQUERY NAME="TierReached" DATASOURCE="#Application.Datasource#">
							SELECT 		Tier_Number,
										Rate,
										Unit_Of_Measure_ID
																
									
							FROM 		Program_Growth_Component_Tiers 
							
							INNER JOIN 	Program_Growth_Component_Product_Tier_Data ON Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Tier_ID = Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID AND
										Program_Growth_Component_Product_Data_ID = '#GetGrowthProductID.Program_Growth_Component_Product_Data_ID#' AND 
										Program_Growth_Component_Product_Tier_Data.Deleted = 0
												
							WHERE 		Program_Growth_Component_ID = <cfqueryparam value="#ProgramGrowthComponentID#" cfsqltype="CF_SQL_VARCHAR"> AND
										((ISNumeric(Range_End) = 1 AND CAST(Range_End AS FLOAT) >= '#ComponentTotal#') OR Range_End = '*') AND									
										Program_Growth_Component_Tiers.Deleted = 0
										
							ORDER BY 	Tier_Number
						</CFQUERY>
					</CFIF>	
				</CFIF>
							
				<CFSET ItemsTotalGrowth = 0>
				<CFSET BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master_ID>
								
				<CFLOOP QUERY="GetItemsTierInfo">	
								
					<CFIF ItemCount EQ 1>	
						<CFIF ComponentUOM NEQ 3>
							<CFQUERY NAME="InsertGrowthLumpsum" DATASOURCE="#Application.Datasource#">
								INSERT INTO 
								Billback_Program_Lumpsum_Component	(	Billback_ID,
																		Billback_Program_ID,
																		Component_Type_ID,
																		Program_Lump_Sum_ID,
																		Program_Growth_Component_Tier_ID,
																		Amount)
																		
								VALUES								( 	<cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">,
																		<cfqueryparam value="#GetBBProgram_ID.Billback_Program_ID#" cfsqltype="CF_SQL_VARCHAR">,
																		3,
																		<cfqueryparam value="#ProgramGrowthComponentID#" cfsqltype="CF_SQL_VARCHAR">,
																		<cfqueryparam value="#Program_Growth_Component_Tier_ID#" cfsqltype="CF_SQL_VARCHAR">,
																		<cfqueryparam value="#Growth_Amount#" cfsqltype="CF_SQL_FLOAT">)
							</CFQUERY>	
						<CFELSE>
							<CFIF Tier_Number LTE TierReachedUOM3>
								<CFQUERY NAME="InsertGrowthLumpsum" DATASOURCE="#Application.Datasource#">
									INSERT INTO 
									Billback_Program_Lumpsum_Component	(	Billback_ID,
																			Billback_Program_ID,
																			Component_Type_ID,
																			Program_Lump_Sum_ID,
																			Program_Growth_Component_Tier_ID,
																			Amount)
																			
									VALUES								( 	<cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">,
																			<cfqueryparam value="#GetBBProgram_ID.Billback_Program_ID#" cfsqltype="CF_SQL_VARCHAR">,
																			3,
																			<cfqueryparam value="#ProgramGrowthComponentID#" cfsqltype="CF_SQL_VARCHAR">,
																			<cfqueryparam value="#Program_Growth_Component_Tier_ID#" cfsqltype="CF_SQL_VARCHAR">,
																			<cfqueryparam value="#Growth_Amount#" cfsqltype="CF_SQL_FLOAT">)
								</CFQUERY>
							</CFIF>
						</CFIF>					
					</CFIF>
					
					
					
					
					<CFIF RateType EQ 1>
						<CFIF ComponentUOM NEQ 3>
							<CFSET TierRate = TierReached.Rate>
							<CFSET TierUOM = TierReached.Unit_Of_Measure_ID>
						<CFELSE>
							<CFSET TierRate = RateOfTierReached>
							<CFSET TierUOM = UOMOfTierReached>
						</CFIF>
					<CFELSEIF RateType EQ 2>
						<CFSET TierRate = Rate>
						<CFSET TierUOM = Unit_Of_Measure_ID>
					</CFIF>
					
					<CFIF ComponentUOM EQ 3 OR TierUOM EQ 3>
						<CFQUERY NAME="ConvertPercent" DBTYPE="QUERY">
							SELECT 	SUM(LB_Unit_Price * Pounds_Invoiced) LB_TotalAmount,
									SUM(CS_Unit_Price * Cases_Invoiced) CS_TotalAmount,
									SUM(Pounds_Invoiced) LB_TotalVolume,
									SUM(Cases_Invoiced) CS_TotalVolume,
									SUM(LB_Unit_Price * Pounds_Invoiced) / SUM(Pounds_Invoiced) LBInvoiceRate,
									SUM(CS_Unit_Price * Cases_Invoiced) / SUM(Cases_Invoiced) CSInvoiceRate
									
							FROM 	GetInvoiceDetails
							WHERE 	BSA_Foodservice_Items_Master_ID = <cfqueryparam value="#BSA_Foodservice_Items_Master_ID#" cfsqltype="CF_SQL_VARCHAR">
						</CFQUERY>
					</CFIF>
					
					<CFIF ComponentUOM EQ TierUOM>
						<CFIF ComponentUOM EQ 3>
							<CFSET FinalTierRate = (TierRate / 100) * ConvertPercent.LBInvoiceRate>
						<CFELSE>
							<CFSET FinalTierRate = TierRate>
						</CFIF>						
					<CFELSEIF ComponentUOM EQ 1 AND TierUOM EQ 2>
						<CFSET FinalTierRate = TierRate * GetNetWeight.Net_Weight>
					<CFELSEIF ComponentUOM EQ 2 AND TierUOM EQ 1>
						<CFSET FinalTierRate = TierRate / GetNetWeight.Net_Weight>
					<CFELSEIF ComponentUOM EQ 1 AND TierUOM EQ 3>						
						<CFSET FinalTierRate = (TierRate / 100) * ConvertPercent.CSInvoiceRate>
						<CFSET FinalTierRate = FinalTierRate * GetNetWeight.Net_Weight>
					<CFELSEIF ComponentUOM EQ 2 AND TierUOM EQ 3>						
						<CFSET FinalTierRate = (TierRate / 100) * ConvertPercent.LBInvoiceRate>
					<CFELSEIF ComponentUOM EQ 3 AND TierUOM EQ 1>
						<CFSET FinalTierRate = TierRate / GetNetWeight.Net_Weight>
					<CFELSEIF ComponentUOM EQ 3 AND TierUOM EQ 2>
						<CFSET FinalTierRate = TierRate>
					</CFIF>
					
					<CFIF ComponentUOM NEQ 3>
						<CFSET ThisTierRate = Delta * Allocation * FinalTierRate>
						<CFSET ItemsTotalGrowth = ItemsTotalGrowth + ThisTierRate>
					<CFELSE>
						<CFIF Tier_Number LTE TierReachedUOM3>
							<CFIF Tier_Number EQ 1>
								<CFSET StartRangeVolumeInLB = (TierCalComponentTotal * Range_Start / 100)>	
								<CFSET StartRangeVolumeInLB = ROUND(StartRangeVolumeInLB)>
							<CFELSE>
								<CFSET StartRangeVolumeInLB = (PreviousEnd + 1)>
							</CFIF>
							
							<CFIF Range_End NEQ "*">		
								<CFSET EndRangeVolumeInLB = (TierCalComponentTotal * Range_End / 100)>
								<CFSET EndRangeVolumeInLB = ROUND(EndRangeVolumeInLB)>
								<CFSET PreviousEnd = EndRangeVolumeInLB>	
							<CFELSE>
								<CFSET EndRangeVolumeInLB = ComponentTotal>
							</CFIF>
							
							<CFIF Tier_Number EQ TierReachedUOM3>
								<CFSET EndRangeVolumeInLB = ComponentTotal>
							</CFIF>
							
							<CFSET UOM3Delta = EndRangeVolumeInLB - StartRangeVolumeInLB + 1>
							<CFSET ThisTierRate = UOM3Delta * Allocation * FinalTierRate>
							<CFSET ItemsTotalGrowth = ItemsTotalGrowth + ThisTierRate>
														
						</CFIF>												
					</CFIF>
					
				</CFLOOP>
				

				
				<CFQUERY NAME="CheckItemExist" DATASOURCE="#Application.Datasource#">
					SELECT 	* 
					FROM 	Billback_Product
					WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND
							Product_ID = <cfqueryparam value="#BSA_Foodservice_Items_Master_ID#" cfsqltype="CF_SQL_VARCHAR"> AND
							Billback_Program_ID = <cfqueryparam value="#BBProgramID.Billback_Program_ID#" cfsqltype="CF_SQL_VARCHAR"> AND
							Deleted = 0
				</CFQUERY>
				
				<CFIF CheckItemExist.RecordCount GT 0>
					<CFSET InsertProduct = 0>
					<CFSET BB_Product_ID = CheckItemExist.Billback_Product_ID>
					<CFSET FinalRate = ItemsTotalGrowth>
					<CFSET BB_Product_Type_ID = 4>
					<CFINCLUDE TEMPLATE="Product_Data_Insert.cfm">					
				<CFELSE>
					<CFIF ThisProgramUOM EQ 1>
						<CFSET FinalVolume = Cases_Invoiced>
					<CFELSEIF ThisProgramUOM EQ 2>
						<CFSET FinalVolume = Pounds_Invoiced>
					</CFIF>
					<CFSET InsertProduct = 1>
					<CFINCLUDE TEMPLATE="Product_Data_Insert.cfm">
					
					<CFSET InsertProduct = 0>					
					<CFSET FinalRate = ItemsTotalGrowth>
					<CFSET BB_Product_Type_ID = 4>
					<CFINCLUDE TEMPLATE="Product_Data_Insert.cfm">
					
				</CFIF>
			</CFLOOP>

		</CFLOOP>
	</CFIF>

</CFLOOP>

