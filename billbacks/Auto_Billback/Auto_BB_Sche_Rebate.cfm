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
			Product_Type_ID IN (2) AND
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
																					Product_Type_ID IN (2) AND
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

<CFLOOP QUERY="GetProducts">
	
	<CFSET FixedRateOfThisProduct = 0>
	<CFSET FixedVolOfThisProduct = 0>
	<CFSET RebateRateOfThisProduct = 0>
	<CFSET RebateVolOfThisProduct = 0>
	<CFSET FormulaRateOfThisProduct = 0>
	<CFSET FormulaVolOfThisProduct = 0>
	<CFSET SumPoundsInvoiced = 0>
	<CFSET SumCasesInvoiced = 0>
	<CFSET FixedRateForAny = 0>
	<CFSET RebateRateForAny = 0>
	<CFSET RebateLoopCountForAny = 0>	
	<CFSET FormulaRateForAny = 0>
	
	<CFQUERY NAME="ThisProductInvoice" DBTYPE="QUERY">
		SELECT 	*	
		FROM 	GetInvoiceDetails		
		WHERE 	BSA_Foodservice_Items_Master_ID = <cfqueryparam value="#BSA_Foodservice_Items_Master_ID#" cfsqltype="CF_SQL_VARCHAR">
	</CFQUERY>
	
	<CFLOOP QUERY="ThisProductInvoice">	
		
		<CFSET SumPoundsInvoiced = SumPoundsInvoiced + Pounds_Invoiced>
		<CFSET SumCasesInvoiced = SumCasesInvoiced + Cases_Invoiced>
		<CFSET Invoice_LB = Pounds_Invoiced>
		<CFSET Invoice_CS = Cases_Invoiced>
		<CFSET LBUnitPrice = LB_Unit_Price>
		<CFSET CSUnitPrice = CS_Unit_Price>	
		
		<CFQUERY NAME="InvoiceBelongsTo" DATASOURCE="#Application.Datasource#">
			SELECT 	Contract_Main_ID,
					Approval_Start_Date,
					Approval_End_Date
					
			FROM 	BB_Program_Info
			WHERE 	Contract_Main_ID IN (#ContractIDList#) AND
					Approval_Start_Date <= '#dateformat(Invoice_Date)#' AND
					Approval_End_Date >= '#dateformat(Invoice_Date)#'
		</CFQUERY>
		
		<CFSET ThisProgramSpanStart = InvoiceBelongsTo.Approval_Start_Date>
		<CFSET ThisProgramSpanEnd = InvoiceBelongsTo.Approval_End_Date>
		
		<CFQUERY NAME="GetInfoFromProg" DATASOURCE="#Application.Datasource#">
			SELECT 		Product_Type_ID,
						Contract_Products.BSA_Foodservice_Items_Master_ID,
						Contract_Products_ID,
						Net_Weight
										
			FROM 		Contract_Products			

			INNER JOIN 	BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID AND
						BSA_Foodservice_Items_Master.Deleted = 0

			WHERE 		Contract_Main_ID = <cfqueryparam value="#InvoiceBelongsTo.Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER"> AND 
						Contract_Products.BSA_Foodservice_Items_Master_ID = <cfqueryparam value="#BSA_Foodservice_Items_Master_ID#" cfsqltype="CF_SQL_VARCHAR"> AND
						Contract_Products.Deleted = 0 AND
						Product_Type_ID = 2
		</CFQUERY>
		
		<!--- for rebate Cal where UMO is % --->
		<CFQUERY NAME="InvoiceInfoForRebate" DBTYPE="QUERY">
			SELECT 	SUM(LB_Unit_Price * Pounds_Invoiced) TotalAmount,
					SUM(Pounds_Invoiced) TotalVolume,					 
					SUM(Gross_Sales_Dollars) GrossTotalAmunt
										 
				
			FROM 	GetInvoiceDetails 
			
			WHERE	BSA_Foodservice_Items_Master_ID = <cfqueryparam value="#BSA_Foodservice_Items_Master_ID#" cfsqltype="CF_SQL_VARCHAR"> AND
					<CFIF TET.BB_Tolerance_TET IS 1>
						(	Invoice_Date >= '#ThisProgramSpanStart#' AND
							Invoice_Date <= '#ThisProgramSpanEnd#'	)
					<CFELSE>
						(	Ship_Date >= '#ThisProgramSpanStart#' AND
							Ship_Date <= '#ThisProgramSpanEnd#'	)
					</CFIF>
		</CFQUERY>		
		
		<CFLOOP QUERY="GetInfoFromProg">
			<CFIF Product_Type_ID EQ 1>
				<CFQUERY NAME="GetFixedRate" DATASOURCE="#Application.Datasource#">
					SELECT 	<CFIF ThisProgramUOM EQ 1>
								Rate_CS Rate
							<CFELSEIF ThisProgramUOM EQ 2>
								Rate_LB Rate
							</CFIF>
							
					FROM 	TC_Fixed_Price_Product
					WHERE 	Contract_Main_ID = <cfqueryparam value="#InvoiceBelongsTo.Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER"> AND
							Product_ID = <cfqueryparam value="#BSA_Foodservice_Items_Master_ID#" cfsqltype="CF_SQL_VARCHAR"> AND
							Unit_Of_Measure_ID IS NOT NULL AND
							Deleted = 0
				</CFQUERY>
				
				<!--- GetRate
				 --->
				<CFIF GetFixedRate.Rate LT 0>
					<CFSET Rate = 0>
				<CFELSE>
					<CFSET Rate = GetFixedRate.Rate>
				</CFIF>
				<CFSET FixedRateForAny = Rate>
				
				<CFIF ThisProgramUOM EQ 1>
					<CFSET RateDiff = CSUnitPrice - Rate>
					<CFSET ThisInvoiceRate = RateDiff * Invoice_CS>
					<CFSET ThisInvoiceVol = Invoice_CS>
				<CFELSEIF ThisProgramUOM EQ 2>
					<CFSET RateDiff = LBUnitPrice - Rate>
					<CFSET ThisInvoiceRate = RateDiff * Invoice_LB>
					<CFSET ThisInvoiceVol = Invoice_LB>
				</CFIF>		
				<CFSET 	FixedRateOfThisProduct = FixedRateOfThisProduct + ThisInvoiceRate>
				<CFSET 	FixedVolOfThisProduct = FixedVolOfThisProduct + ThisInvoiceVol>				
				<!--- <CFOUTPUT>---ThisInvoiceRate #ThisInvoiceRate# FixedRateOfThisProduct #FixedRateOfThisProduct# FixedVolOfThisProduct #FixedVolOfThisProduct#---</CFOUTPUT> --->
			</CFIF>	
			
			<CFIF Product_Type_ID EQ 2>
				<CFSET RebateLoopCountForAny = RebateLoopCountForAny + 1>
				
				<CFQUERY NAME="GetRateUOM" DATASOURCE="#Application.Datasource#">
					SELECT 		Program_Rebates_Component_Data.Unit_Of_Measure_ID,
								Rate,
								Program_Rebates_Component_Name.Rebate_Percent_Option_ID
					
					FROM 		Program_Rebates_Product_Data
					
					INNER JOIN	Program_Rebates_Component_Data ON Program_Rebates_Component_Data.Program_Rebates_Product_Data_ID = Program_Rebates_Product_Data.Program_Rebates_Product_Data_ID AND
								Program_Rebates_Product_Data.Deleted = 0
								
					INNER JOIN 	Program_Rebates_Component ON Program_Rebates_Component.Program_Rebates_Component_ID = Program_Rebates_Component_Data.Program_Rebates_Component_ID AND
								Program_Rebates_Component.Deleted = 0
								
					INNER JOIN 	Program_Rebates_Component_Name ON Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID = Program_Rebates_Component.Program_Rebates_Component_Name_ID AND
								Program_Rebates_Component_Name.Deleted = 0
								
					WHERE 		Program_Rebates_Product_Data.Program_ID = <cfqueryparam value="#InvoiceBelongsTo.Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER"> AND
								Contract_Products_ID = <cfqueryparam value="#GetInfoFromProg.Contract_Products_ID#" cfsqltype="CF_SQL_INTEGER"> AND	
								Program_Rebates_Product_Data.Deleted = 0			
				</CFQUERY>
				<!--- GetRateUOM
				<CFDUMP VAR="#GetRateUOM#"> --->
				
				<CFSET NetWeight = Net_Weight>
				<!--- <CFOUTPUT>--- Product ID #BSA_Foodservice_Items_Master_ID# ---<BR></CFOUTPUT> --->
				<CFLOOP QUERY="GetRateUOM">
				
					<CFSET RebateRate = Rate>
					<CFIF Unit_Of_Measure_ID EQ 1>						
						<CFIF ThisProgramUOM EQ 2>
							<CFSET 	RebateRate = Rate / NetWeight>
						</CFIF>
					<CFELSEIF Unit_Of_Measure_ID EQ 2>
						<CFIF ThisProgramUOM EQ 1>
							<CFSET RebateRate = Rate * NetWeight>
						</CFIF>
					<CFELSEIF Unit_Of_Measure_ID EQ 3>
						<CFIF Rebate_Percent_Option_ID EQ 2>
							<CFSET InvoiceRate = InvoiceInfoForRebate.GrossTotalAmunt / InvoiceInfoForRebate.TotalVolume>							
						<CFELSE>
							<CFSET InvoiceRate = InvoiceInfoForRebate.TotalAmount / InvoiceInfoForRebate.TotalVolume>
						</CFIF>
						<CFSET RebateRate = (Rate / 100) * InvoiceRate>
						<CFIF ThisProgramUOM EQ 1>
							<CFSET RebateRate = RebateRate * NetWeight>					
						</CFIF>
					</CFIF>
					
					<CFIF RebateLoopCountForAny EQ 1>
						<CFSET RebateRateForAny = RebateRateForAny + RebateRate>						
					</CFIF>
					
					<CFIF ThisProgramUOM EQ 1>
						<CFSET InvoiceRebateRate = RebateRate * Invoice_CS>
						<CFSET InvoiceRebateVolume = Invoice_CS>
					<CFELSEIF ThisProgramUOM EQ 2>
						<CFSET InvoiceRebateRate = RebateRate * Invoice_LB>
						<CFSET InvoiceRebateVolume = Invoice_LB>
					</CFIF>
					
					<CFSET RebateRateOfThisProduct = RebateRateOfThisProduct + InvoiceRebateRate>
					<CFSET RebateVolOfThisProduct = RebateVolOfThisProduct + InvoiceRebateVolume>
					
				</CFLOOP>					
			</CFIF>	
							
			<!--- <CFELSEIF Product_Type_ID EQ 4> --->
				
			<CFIF Product_Type_ID EQ 5>
				<CFQUERY NAME="GetFormulaRate" DATASOURCE="#Application.Datasource#">
					SELECT 	<CFIF ThisProgramUOM EQ 1>
								Rate_CS Rate
							<CFELSEIF ThisProgramUOM EQ 2>
								Rate_LB Rate
							</CFIF>
							
					FROM 	TC_Formula_Product
					WHERE 	Contract_Main_ID = <cfqueryparam value="#InvoiceBelongsTo.Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER"> AND
							Product_ID = <cfqueryparam value="#BSA_Foodservice_Items_Master_ID#" cfsqltype="CF_SQL_VARCHAR"> AND
							Deleted = 0
				</CFQUERY>
				
				<CFIF GetFormulaRate.Rate LT 0>
					<CFSET Rate = 0>
				<CFELSE>
					<CFSET Rate = GetFormulaRate.Rate>
				</CFIF>
				
				<CFSET FormulaRateForAny = Rate>
				
				<CFIF ThisProgramUOM EQ 1>
					<CFSET RateDiff = CSUnitPrice - Rate>
					<CFSET InvoiceFormulaRate = RateDiff * Invoice_CS>
					<CFSET InvoiceFormulaVol = Invoice_CS>
				<CFELSEIF ThisProgramUOM EQ 2>
					<CFSET RateDiff = LBUnitPrice - Rate>
					<CFSET InvoiceFormulaRate = RateDiff * Invoice_LB>
					<CFSET InvoiceFormulaVol = Invoice_LB>
				</CFIF>
				
				<CFSET FormulaRateOfThisProduct = FormulaRateOfThisProduct + InvoiceFormulaRate>
				<CFSET FormulaVolOfThisProduct = FormulaRateOfThisProduct + InvoiceFormulaVol>
			</CFIF>	
			
		</CFLOOP>
			
	</CFLOOP>

	<CFIF FixedVolOfThisProduct GT 0 OR RebateVolOfThisProduct GT 0 OR FormulaVolOfThisProduct GT 0>
		<CFIF ThisProgramUOM EQ 1>		
			<CFSET FinalVolume = SumCasesInvoiced>
		<CFELSEIF ThisProgramUOM EQ 2>
			<CFSET FinalVolume = SumPoundsInvoiced>
		</CFIF>
		<CFSET InsertProduct = 1>
		<CFINCLUDE TEMPLATE="Product_Data_Insert.cfm">	
		<CFSET InsertProduct = 0>
	</CFIF>
	
	<CFIF FixedVolOfThisProduct GT 0>
		<CFSET FinalRate = FixedRateOfThisProduct>
		<CFSET BB_Product_Type_ID = 1>
		
		<CFINCLUDE TEMPLATE="Product_Data_Insert.cfm">		
	</CFIF>
	
	<CFIF RebateVolOfThisProduct GT 0>
		<CFSET FinalRate = RebateRateOfThisProduct>
		<CFSET BB_Product_Type_ID = 2>
		
		<CFINCLUDE TEMPLATE="Product_Data_Insert.cfm">
	</CFIF>
	
	<CFIF FormulaVolOfThisProduct GT 0>
		<CFSET FinalRate = FormulaRateOfThisProduct>
		<CFSET BB_Product_Type_ID = 5>
		
		<CFINCLUDE TEMPLATE="Product_Data_Insert.cfm">
	</CFIF>
	
	<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
	<!--- Collect Data For Any Option --->
	<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
	<CFIF ISDefined("FORM.Get_All_Items")>				
		<CFIF FixedRateForAny GT 0>
			<CFSET ProductTypeForAny = 1>
			<CFSET RateForAny = FixedRateForAny>
			<CFINCLUDE TEMPLATE="OptionAny_Data_Insert.cfm">			
		</CFIF>
		
		<CFIF RebateRateForAny GT 0>
			<CFSET ProductTypeForAny = 2>
			<CFSET RateForAny = RebateRateForAny>
			<CFINCLUDE TEMPLATE="OptionAny_Data_Insert.cfm">			
		</CFIF>
		
		<CFIF FormulaRateForAny GT 0>
			<CFSET ProductTypeForAny = 5>
			<CFSET RateForAny = FormulaRateForAny>
			<CFINCLUDE TEMPLATE="OptionAny_Data_Insert.cfm">				
		</CFIF>
	</CFIF>
	<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->	
</CFLOOP>

