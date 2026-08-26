


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

	WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	AND		Deleted = 0
</CFQUERY>
<CFQUERY NAME="DeleteFromDetails" DATASOURCE="#Application.Datasource#">
	UPDATE 	Billback_Product_Detail

	SET 	Deleted = 1

	WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	AND		Deleted = 0
</CFQUERY>
<CFIF ISDefined("FORM.Get_All_Items")>
	<CFQUERY NAME="DeletedAny" DATASOURCE="#Application.Datasource#">
		UPDATE Billback_Auto_Any_Option

		SET 	Deleted = 1

		WHERE	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND		Deleted = 0
	</CFQUERY>
</CFIF>

<CFIF IsDefined("FORM.Program_List")>
	<CFSET ProgramList = FORM.Program_List>
<CFELSE>
	<CFQUERY NAME="GetProgList" DATASOURCE="#Application.Datasource#">
		SELECT 	Program_ID

		FROM 	Billback_Program

		WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND		Deleted = 0
	</CFQUERY>
	<CFSET ProgramList = VALUELIST(GetProgList.Program_ID)>
</CFIF>

<CFQUERY NAME="BBProgramID" DATASOURCE="#Application.Datasource#">
	SELECT 	Billback_Program_ID

	FROM 	Billback_Program

	WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	AND		Program_ID = <cfqueryparam value="#ProgramList#" cfsqltype="CF_SQL_VARCHAR">
	AND		Deleted = 0
</CFQUERY>

<cfset useLakebaseForTET = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_settings")>
<cfif useLakebaseForTET>
	<cftry>
		<cfset TET = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_settings", {
				"select" = "bb_tolerance_tet"
			}), "bb_tolerance_tet"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForTET = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForTET>
<CFQUERY NAME="TET" DATASOURCE="#Application.Datasource#">
	SELECT 	BB_Tolerance_TET
	FROM 	Billback_Settings
</CFQUERY>
</cfif>

<CFQUERY NAME="GetContractNumber" DATASOURCE="#Application.Datasource#">
	SELECT 	Contract_Number,Contract_Quantity_UOM_IDX
	FROM 	Contract_main
	WHERE 	Contract_Main_ID = <cfqueryparam value="#ProgramList#" cfsqltype="CF_SQL_VARCHAR">
</CFQUERY>
<CFSET ThisProgramUOM = GetContractNumber.Contract_Quantity_UOM_IDX>

<cfquery name="PopulateTables" datasource="#application.datasource#">
	EXEC BB_D_Program_Detail <cfqueryparam value="#ProgramList#" cfsqltype="CF_SQL_VARCHAR">
</cfquery>

<CFQUERY NAME="GetProgramSpan" DATASOURCE="#Application.Datasource#">
	SELECT 	MIN(Approval_start_Date) ProgSpanStartDate,
			MAX(Approval_End_Date) ProgSpanEndDate

	FROM 	BB_Program_Info
	WHERE 	Contract_Number = <cfqueryparam value="#GetContractNumber.Contract_Number#" cfsqltype="CF_SQL_VARCHAR">
	AND 	Deleted = 0
</CFQUERY>
<!--- GetBBStartEndDate
<CFDUMP VAR="#GetBBStartEndDate#">
GetProgramSpan
<CFDUMP VAR="#GetProgramSpan#"> --->

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
		EXEC TC_PROGRAM_PRODUCT_DETAIL @@A_ID = <cfqueryparam value="#Contract_Main_ID#" cfsqltype="CF_SQL_VARCHAR">, @@CUSTOMER_ID = <cfqueryparam value="#FORM.Distributor_List#" cfsqltype="CF_SQL_VARCHAR">
	</CFQUERY>
</CFLOOP>

<CFQUERY NAME="GetProducts" DATASOURCE="#Application.Datasource#">
	SELECT 	DISTINCT BSA_Foodservice_Items_Master_ID
	FROM 	Contract_Products
	WHERE	Contract_Main_ID IN (<cfqueryparam value="#ContractIDList#" cfsqltype="CF_SQL_INTEGER" list="Yes">) AND
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
					Invoice_Header.BSA_Foodservice_Customers_ID = <cfqueryparam value="#FORM.Distributor_List#" cfsqltype="CF_SQL_VARCHAR">
		AND
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
	<CFOUTPUT>
	<CFLOCATION URL="/billbacks/capture/billback_summary.cfm?BBID=#Billback_ID#" ADDTOKEN="No">
	</CFOUTPUT>
	<CFABORT>
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
	<!--- ThisProductInvoice
	<CFDUMP VAR="#ThisProductInvoice#"> --->


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


		<!--- InvoiceBelongsTo
		<CFDUMP VAR="#InvoiceBelongsTo#"> --->


		<CFQUERY NAME="GetInfoFromProg" DATASOURCE="#Application.Datasource#">
			SELECT 		Product_Type_ID,
						Contract_Products.BSA_Foodservice_Items_Master_ID,
						Contract_Products_ID,
						Net_Weight

			FROM 		Contract_Products

			INNER JOIN 	BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID AND
						BSA_Foodservice_Items_Master.Deleted = 0

			WHERE
			<cfif InvoiceBelongsTo.recordcount GT 0 and InvoiceBelongsTo.Contract_Main_ID NEQ "">
			Contract_Main_ID = <cfqueryparam value="#InvoiceBelongsTo.Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER">
			<cfelse>
			Contract_Main_ID = 0
			</cfif>
			AND			Contract_Products.BSA_Foodservice_Items_Master_ID = <cfqueryparam value="#BSA_Foodservice_Items_Master_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND			Contract_Products.Deleted = 0
		</CFQUERY>
		<!--- GetInfoFromProg
		<CFDUMP VAR="#GetInfoFromProg#"> --->

		<!--- for rebate Cal where UMO is % --->
		<CFQUERY NAME="InvoiceInfoForRebate" DBTYPE="QUERY">
			SELECT 	SUM(LB_Unit_Price * Pounds_Invoiced) TotalAmount,
					SUM(Pounds_Invoiced) TotalVolume,
					SUM(Gross_Sales_Dollars) GrossTotalAmunt


			FROM 	GetInvoiceDetails

			WHERE	BSA_Foodservice_Items_Master_ID = <cfqueryparam value="#BSA_Foodservice_Items_Master_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND
					<CFIF TET.BB_Tolerance_TET IS 1>
						(	Invoice_Date >= '#ThisProgramSpanStart#' AND
							Invoice_Date <= '#ThisProgramSpanEnd#'	)
					<CFELSE>
						(	Ship_Date >= '#ThisProgramSpanStart#' AND
							Ship_Date <= '#ThisProgramSpanEnd#'	)
					</CFIF>
		</CFQUERY>

		<!--- InvoiceInfoForRebate
		<CFDUMP VAR="#InvoiceInfoForRebate#"> --->


		<CFLOOP QUERY="GetInfoFromProg">
			<CFIF Product_Type_ID EQ 1>
				<CFQUERY NAME="GetFixedRate" DATASOURCE="#Application.Datasource#">
					SELECT 	<CFIF ThisProgramUOM EQ 1>
								Rate_CS Rate
							<CFELSEIF ThisProgramUOM EQ 2>
								Rate_LB Rate
							</CFIF>

					FROM 	TC_Fixed_Price_Product
					WHERE 	Contract_Main_ID = <cfqueryparam value="#InvoiceBelongsTo.Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER">
					AND		Product_ID = <cfqueryparam value="#BSA_Foodservice_Items_Master_ID#" cfsqltype="CF_SQL_VARCHAR">
					AND		Unit_Of_Measure_ID IS NOT NULL
					AND		Deleted = 0
				</CFQUERY>

				<!--- GetRate
				<CFDUMP VAR="#GetFixedRate#">
				<CFOUTPUT>--- ThisProgramUOM #ThisProgramUOM# Pounds_Invoiced #Invoice_LB# Cases_Invoiced #Invoice_CS#---</CFOUTPUT>
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

					WHERE 		Program_Rebates_Product_Data.Program_ID = <cfqueryparam value="#InvoiceBelongsTo.Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER">
					AND			Contract_Products_ID = <cfqueryparam value="#GetInfoFromProg.Contract_Products_ID#" cfsqltype="CF_SQL_INTEGER">
					AND			Program_Rebates_Product_Data.Deleted = 0
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
					WHERE 	Contract_Main_ID = <cfqueryparam value="#InvoiceBelongsTo.Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER">
					AND		Product_ID = <cfqueryparam value="#BSA_Foodservice_Items_Master_ID#" cfsqltype="CF_SQL_VARCHAR">
					AND		Deleted = 0
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


<!--- Growth, Growth LumpSum And LumpSum --->
<CFQUERY NAME="DeleteGrowth" DATASOURCE="#Application.Datasource#">
	UPDATE 	Billback_Program_Lumpsum_Component
	SET		Deleted = 1
	WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	AND 	Deleted = 0
</CFQUERY>

<!---
<cfset useLakebaseForDeleteLumpsum = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program_lumpsum_component")>
<cfif useLakebaseForDeleteLumpsum>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_program_lumpsum_component",
			{
				"billback_id" = "eq.#Billback_ID#",
				"component_type_id" = "eq.1",
				"deleted" = "eq.0"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDeleteLumpsum = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeleteLumpsum>
<CFQUERY NAME="DeleteLumpsum" DATASOURCE="#Application.Datasource#">
	UPDATE Billback_Program_Lumpsum_Component
	SET	Deleted = 1
	WHERE Billback_ID = '#Billback_ID#' AND Component_Type_ID = 1 AND Deleted = 0
</CFQUERY>
</cfif>
 --->
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
		WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND		Program_ID = <cfqueryparam value="#Item#" cfsqltype="CF_SQL_INTEGER">
		AND		Deleted = 0
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

				WHERE     	Program_Growth_Component_ID = <cfqueryparam value="#Program_Growth_Component_ID#" cfsqltype="CF_SQL_VARCHAR">
				AND			Contract_Products.Deleted = 0
				AND			Program_Growth_Component_Product_Data.Deleted = 0
			</CFQUERY>
			<CFSET ItemSIDList = VALUELIST(GetItemsInComponent.BSA_Foodservice_Items_Master_ID)>
			<!--- GetItemsInComponent
			<CFDUMP VAR="#GetItemsInComponent#"> --->




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
								Invoice_Header.BSA_Foodservice_Customers_ID = <cfqueryparam value="#FORM.Distributor_List#" cfsqltype="CF_SQL_VARCHAR">
					AND
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
					WHERE 	Contract_Number = <cfqueryparam value="#GetContractNumber.Contract_Number#" cfsqltype="CF_SQL_VARCHAR">
					AND 	Deleted = 0
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
								Invoice_Header.BSA_Foodservice_Customers_ID = <cfqueryparam value="#FORM.Distributor_List#" cfsqltype="CF_SQL_VARCHAR">
					AND
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
				<!--- <CFDUMP VAR="#InvoiceToCalTier#">	 --->
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

					WHERE 		Program_Growth_Component_ID = <cfqueryparam value="#ProgramGrowthComponentID#" cfsqltype="CF_SQL_VARCHAR">
					AND
								<CFIF ComponentUOM NEQ 3>
								CAST(Range_Start AS Float) <= '#ComponentTotal#' AND
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

							WHERE 		Program_Growth_Component_ID = <cfqueryparam value="#ProgramGrowthComponentID#" cfsqltype="CF_SQL_VARCHAR">
							AND
										((ISNumeric(Range_End) = 1 AND CAST(Range_End AS FLOAT) >= '#ComponentTotal#') OR Range_End = '*') AND
										Program_Growth_Component_Tiers.Deleted = 0

							ORDER BY 	Tier_Number
						</CFQUERY>
					</CFIF>
				</CFIF>

				<CFSET ItemsTotalGrowth = 0>
				<CFSET BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master_ID>

				<!--- GetItemsTierInfo
				<CFDUMP VAR="#GetItemsTierInfo#"> --->
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
					WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
					AND		Product_ID = <cfqueryparam value="#BSA_Foodservice_Items_Master_ID# " cfsqltype="CF_SQL_VARCHAR">
					AND		Billback_Program_ID = <cfqueryparam value="#BBProgramID.Billback_Program_ID#" cfsqltype="CF_SQL_VARCHAR">
					AND		Deleted = 0
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



	<!--- LumpSum --->

	<CFQUERY NAME="GetLumpsumAmount" DATASOURCE="#Application.Datasource#">
		SELECT		Program_Lump_Sums.Program_Lump_Sum_ID,
					Program_Lump_Sums.Program_ID,
					Lump_Sum_Amount

		FROM		Contract_Main

		INNER JOIN	BB_Program_Info ON BB_Program_Info.Contract_Main_ID = Contract_Main.Contract_Main_ID AND
					DATEDIFF(d, Approval_Start_Date, #createodbcdate(Lumpsum_End_Date)#) >= 0 AND
					DATEDIFF(d, #createodbcdate(Lumpsum_End_Date)#, Approval_End_Date) >= 0 AND
					BB_Program_Info.Deleted = 0

		INNER JOIN	Program_Lump_Sums ON Program_Lump_Sums.Program_ID = Contract_Main.Contract_Main_ID AND
					Program_Lump_Sums.Deleted = 0

		WHERE		Contract_Main.Contract_Number = <cfqueryparam value="#GetContractNumber.Contract_Number#" cfsqltype="CF_SQL_VARCHAR">
	</CFQUERY>

	<CFLOOP QUERY="GetLumpsumAmount">
		<CFQUERY NAME="InsertLumpSum" DATASOURCE="#Application.Datasource#">
			INSERT INTO

			Billback_Program_Lumpsum_Component 	(	Billback_ID,
													Billback_Program_ID,
													Component_Type_ID,
													Program_Lump_Sum_ID,
													Amount					)

			VALUES								(	<cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">,
													<cfqueryparam value="#GetBBProgram_ID.Billback_Program_ID#" cfsqltype="CF_SQL_VARCHAR">,
													1,
													<cfqueryparam value="#Program_Lump_Sum_ID#" cfsqltype="CF_SQL_VARCHAR">,
													<cfqueryparam value="#Lump_Sum_Amount#" cfsqltype="CF_SQL_FLOAT">)
		</CFQUERY>
	</CFLOOP>
</CFLOOP>

<CFSET Distributor = FORM.Distributor_List>

<CFSET IsAnyChecked = 0>
<CFIF IsDefined("FORM.Get_All_Items")>
	<CFSET IsAnyChecked = 1>
</CFIF>


<CFINCLUDE TEMPLATE="OptionAny_Cal_And_DeleteZeros.cfm">
<CFABORT>
<CFLOCATION URL="OptionAny_Cal_And_DeleteZeros.cfm?BBID=#Billback_ID#&IsAnyChecked=#IsAnyChecked#&ContractIDList=#ContractIDList#&Distributor_List=#Distributor#&StartDateForInvoice=#StartDateForInvoice#&EndDateForInvoice=#EndDateForInvoice#&ThisProgramUOM=#ThisProgramUOM#" ADDTOKEN="No">

<CFABORT>
<CFIF IsDefined("IncludedInAuto_Distributor_Program_ActionCFM")>
	<CFOUTPUT>
	<CFLOCATION URL="/billbacks/capture/billback_summary.cfm?BBID=#Billback_ID#" ADDTOKEN="No">
	</CFOUTPUT>
</CFIF>


<CFABORT>

<CFQUERY NAME="DeleteZeroVol" DATASOURCE="#Application.Datasource#">
	UPDATE 	Billback_Product
	SET 	BB_Product_Quantity = 10
	WHERE 	BillBack_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	AND 	BB_Product_Quantity = '0'
</CFQUERY>


<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<!--- Get Rates for all items --->
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->

<CFQUERY NAME="SetAutoBBFlagOn" DATASOURCE="#Application.Datasource#">
	UPDATE 	Billback
	SET 	Flag_Auto_Billback = 1
	WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	AND 	Deleted = 0
</CFQUERY>

<CFQUERY NAME="getThis" DATASOURCE="#Application.Datasource#">
	SELECT 	*
	FROM 	Billback
	WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	AND 	Deleted = 0
</CFQUERY>



<CFTRANSACTION ACTION="Begin">
<!---
<CFSTOREDPROC PROCEDURE="BB_D_PRODUCT_DEVIATION" datasource="#application.datasource#">
	<CFPROCPARAM TYPE="In" CFSQLTYPE="cf_sql_idstamp"	DBVARNAME="@@BILL_ID"		VALUE="#Billback_ID#">
</CFSTOREDPROC>
 --->
<CFQUERY NAME="SP_1" DATASOURCE="#Application.Datasource#">
	EXEC BB_D_PRODUCT_DEVIATION <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
</CFQUERY>

<CFQUERY NAME="SP_2" DATASOURCE="#Application.Datasource#">
	EXEC BB_D_PROGRAM_DEVIATION <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
</CFQUERY>

<CFQUERY NAME="SP_3" DATASOURCE="#Application.Datasource#">
	EXEC BB_D_OVERLAP_DEVIATION <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
</CFQUERY>

<!--- Check for fixed --->
<CFQUERY NAME="CheckFixed" DATASOURCE="#Application.Datasource#">
	SELECT 	Top 1 *

	FROM 	Billback_Product_Detail

	WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	AND 	BB_Product_Type_ID = 1
	AND 	Deleted = 0
</CFQUERY>

<CFIF CheckFixed.RecordCount GT 0>
	<CFQUERY NAME="SP_Fixed_Rate" DATASOURCE="#Application.Datasource#">
		EXEC BB_D_FIXED_RATE_DEV <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	</CFQUERY>

	<CFQUERY NAME="SP_Fixed_Vol" DATASOURCE="#Application.Datasource#">
		EXEC BB_D_FIXED_VOLUME_DEV <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	</CFQUERY>
</CFIF>

<!--- Check for rebate --->
<CFQUERY NAME="CheckRebate" DATASOURCE="#Application.Datasource#">
	SELECT 	Top 1 *

	FROM 	Billback_Product_Detail

	WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	AND		BB_Product_Type_ID = 2
	AND 	Deleted = 0
</CFQUERY>

<CFIF CheckRebate.RecordCount GT 0>
	<CFQUERY NAME="SP_Rebate_Rate" DATASOURCE="#Application.Datasource#">
		EXEC BB_D_REBATE_RATE_DEV <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	</CFQUERY>

	<CFQUERY NAME="SP_Rebate_Vol" DATASOURCE="#Application.Datasource#">
		EXEC BB_D_REBATE_VOLUME_DEV <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	</CFQUERY>
</CFIF>

<!--- Check for formula --->
<CFQUERY NAME="CheckFormula" DATASOURCE="#Application.Datasource#">
	SELECT 	Top 1 *

	FROM 	Billback_Product_Detail

	WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	AND 	BB_Product_Type_ID = 5
	AND 	Deleted = 0
</CFQUERY>

<CFIF CheckFormula.RecordCount GT 0>
	<CFQUERY NAME="SP_Formula_Rate" DATASOURCE="#Application.Datasource#">
		EXEC BB_D_FORMULA_RATE_DEV <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	</CFQUERY>
	<CFQUERY NAME="SP_Formula_Vol" DATASOURCE="#Application.Datasource#">
		EXEC BB_D_FORMULA_VOLUME_DEV <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	</CFQUERY>
</CFIF>


<!--- Check for Lumpsum --->
<CFQUERY NAME="CheckLumpSum" DATASOURCE="#Application.Datasource#">
	SELECT 	Top 1 *

	FROM 	Billback_Program_Lumpsum_Component

	WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	AND 	Component_Type_ID = 1
	AND 	Deleted = 0
</CFQUERY>

<CFIF CheckLumpSum.RecordCount GT 0>
	<CFQUERY NAME="SP_Lumpsum_Rate_Vol" DATASOURCE="#Application.Datasource#">
		EXEC BB_D_LUMPSUM_DEV <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	</CFQUERY>
</CFIF>

<!--- Check for Growth --->
<CFQUERY NAME="CheckGrowth" DATASOURCE="#Application.Datasource#">
	SELECT 	Top 1 *

	FROM 	Billback_Product_Detail

	WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	AND 	BB_Product_Type_ID = 4
	AND 	Deleted = 0
</CFQUERY>

<CFIF CheckGrowth.RecordCount GT 0>
	<CFQUERY NAME="SP_Growth_Rate_Vol" DATASOURCE="#Application.Datasource#">
		EXEC BB_D_GROWTH_RATE_DEV <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	</CFQUERY>
</CFIF>
<CFTRANSACTION ACTION="Commit">
</CFTRANSACTION>
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->



<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<!--- Update Rate and Volume --->
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->

<!--- Growth and Lumpsum --->


<CFQUERY NAME="GetPrograms" DATASOURCE="#Application.Datasource#">
	SELECT 	Billback_Program_ID,
			Program_ID

	FROM 	Billback_Program

	WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	AND 	Deleted = 0
</CFQUERY>

<!--- Growth --->
<CFLOOP QUERY="GetPrograms">
	<CFQUERY NAME="CheckUOM" DATASOURCE="#Application.Datasource#">
		SELECT Contract_Quantity_UOM_IDX
		FROM Contract_Main
		WHERE Contract_Main_ID = <cfqueryparam value="#Program_ID#" cfsqltype="CF_SQL_INTEGER">
	</CFQUERY>
	<CFSET ProgramUOM = CheckUOM.Contract_Quantity_UOM_IDX>
	<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
	<CFQUERY NAME="GetProducts" DATASOURCE="#Application.Datasource#">
		SELECT 	DISTINCT	Product_ID,
							Program_ID,
							Actual_Program_ID

		FROM 	BB_Growth_Tier_RateCheck

		WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND 	Actual_Program_ID = <cfqueryparam value="#Program_ID#" cfsqltype="CF_SQL_INTEGER">
		AND		Deleted = 0
	</CFQUERY>

	<CFSET BillbackProgramID = Billback_Program_ID>
	<!--- Insert Revision's New Productions --->


	<CFLOOP QUERY="GetProducts">

		<CFQUERY NAME="CheckForExistance" DATASOURCE="#Application.Datasource#">
			SELECT 		Product_ID,
						Billback_Product.Billback_Product_ID,
						BB_Product_Type_ID,
						Billback_Product.Deleted,
						Billback_Product_Detail.Deleted,
						Billback_Product_Detail.Billback_Product_ID DetailBBProductID

			FROM 		Billback_Product

			LEFT JOIN 	Billback_Product_Detail ON Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID AND
						Billback_Product_Detail.Billback_ID = Billback_Product.Billback_ID AND
						BB_Product_Type_ID = 4 AND
						Billback_Product_Detail.Deleted = 0

			WHERE 		Billback_Product.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND 		Billback_Program_ID = <cfqueryparam value="#BillbackProgramID#" cfsqltype="CF_SQL_VARCHAR">
			AND			Product_ID = <cfqueryparam value="#Product_ID# " cfsqltype="CF_SQL_VARCHAR">
			AND			Billback_Product.Deleted = 0
		</CFQUERY>



		<CFIF CheckForExistance.Recordcount EQ 0>
			<CFQUERY NAME="InsertNew" DATASOURCE="#Application.Datasource#">
				INSERT INTO

				Billback_Product	(	Billback_ID,
										Product_ID,
										Billback_Program_ID,
										BB_Product_UOM		)

				VALUES				(	<cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">,
										<cfqueryparam value="#Product_ID#" cfsqltype="CF_SQL_VARCHAR">,
										<cfqueryparam value="#BillbackProgramID#" cfsqltype="CF_SQL_VARCHAR">,
										<cfqueryparam value="#ProgramUOM#" cfsqltype="CF_SQL_VARCHAR">		)
			</CFQUERY>

			<CFSET BillBackProductID = InsertNew.Billback_Product_ID>

			<CFQUERY NAME="InsertNewDetail" DATASOURCE="#Application.Datasource#">
				INSERT INTO

				Billback_Product_Detail (	Billback_Product_ID,
											Billback_ID,
											BB_Product_Type_ID,
											BB_Rate					)

				VALUES					(	<cfqueryparam value="#BillBackProductID#" cfsqltype="CF_SQL_VARCHAR">,
											<cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">,
											4,
											0						)
			</CFQUERY>

		<CFELSEIF CheckForExistance.DetailBBProductID EQ "">
			<CFQUERY NAME="InsertNewDetail" DATASOURCE="#Application.Datasource#">
				INSERT INTO

				Billback_Product_Detail (	Billback_Product_ID,
											Billback_ID,
											BB_Product_Type_ID,
											BB_Rate					)

				VALUES					(	<cfqueryparam value="#CheckForExistance.Billback_Product_ID#" cfsqltype="CF_SQL_VARCHAR">,
											<cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">,
											4,
											0						)
			</CFQUERY>
		</CFIF>
	</CFLOOP>
	<!--- End Insert Revision's New Productions --->



	<!--- ******************************************************************** --->
	<!--- Fix this afterwards --->
	<!--- ******************************************************************** --->
	<!--- Delete Products not in Revision --->
	<CFSET Product_List = VALUELIST(GetProducts.Product_ID)>

	<CFQUERY NAME="CheckForExtraGrowth" DATASOURCE="#Application.Datasource#">
		SELECT 		Billback_Product.Billback_Product_ID, Product_ID,Billback_Program_ID
		FROM 		Billback_Product
		INNER JOIN 	Billback_Product_Detail ON Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID AND
					BB_Product_Type_ID = 4 AND
					Billback_Product_Detail.Deleted = 0

		WHERE 		Billback_Product.Billback_ID= <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND			Billback_Program_ID = <cfqueryparam value="#Billback_Program_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND
					<CFIF Product_List NEQ "">
					Product_ID NOT IN (#LISTQUALIFY(Product_List,"'",",","All")#) AND
					</CFIF>
					Billback_Product.Deleted = 0
	</CFQUERY>

	<CFIF CheckForExtraGrowth.Recordcount GT 0>
		<CFLOOP QUERY="CheckForExtraGrowth">
			<CFQUERY NAME="DeleteDetail" DATASOURCE="#Application.Datasource#">
				UPDATE 	Billback_Product_Detail
				SET 	Deleted = 1

				WHERE 	Billback_Product_ID = <cfqueryparam value="#Billback_Product_ID#" cfsqltype="CF_SQL_VARCHAR">
				AND 	BB_Product_Type_ID = 4
				AND		Deleted =0
			</CFQUERY>

			<CFQUERY NAME="CheckOtherProTypeForSameProduct" DATASOURCE="#Application.Datasource#">
				SELECT 	Top 1 *
				FROM 	Billback_Product_Detail
				WHERE 	Billback_Product_ID = <cfqueryparam value="#Billback_Product_ID#" cfsqltype="CF_SQL_VARCHAR">
				AND		Deleted =0
			</CFQUERY>

			<CFIF CheckOtherProTypeForSameProduct.RecordCount EQ 0>
				<CFQUERY NAME="DeleteFromBB_ProductToo" DATASOURCE="#Application.Datasource#">
					UPDATE 	Billback_Product
					SET 	Deleted = 1

					WHERE 	Billback_Product_ID = <cfqueryparam value="#Billback_Product_ID#" cfsqltype="CF_SQL_VARCHAR">
					AND		Deleted = 0
				</CFQUERY>
			</CFIF>
		</CFLOOP>
	</CFIF>
	<!--- End Delete Products not in Revision --->
	<!--- ******************************************************************** --->




	<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->

	<!--- Begin calculation --->
	<CFQUERY NAME="GetProgramTotal" DATASOURCE="#Application.Datasource#">
		SELECT  SUM(Tier_Amount) As Tier_Sum

		FROM 	BB_Growth_Tier_RateCheck

		WHERE   Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND 	Actual_Program_ID = <cfqueryparam value="#Program_ID#" cfsqltype="CF_SQL_INTEGER">
		AND 	Deleted = 0
	</CFQUERY>

	<CFQUERY NAME="ExpectedAmt" DATASOURCE="#Application.Datasource#">
		SELECT	Expected_Amount,
				Billback_Program_ID

		FROM 	BB_Growth_Program

		WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND 	Billback_Program_ID = <cfqueryparam value="#Billback_Program_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND 	Deleted = 0
	</CFQUERY>


	<CFSET GetRatio = 0>
	<CFSET SumOfAllProducts = GetProgramTotal.Tier_Sum>
	<CFSET ExpectedAmtOfThisProgram = ExpectedAmt.Expected_Amount>

	<CFIF SumOfAllProducts NEQ ExpectedAmtOfThisProgram>
		<CFSET GetRatio = 1>
	</CFIF>



	<CFLOOP QUERY="GetProducts">
		<CFQUERY NAME="ProductSum" DATASOURCE="#Application.Datasource#">
			SELECT 	SUM(Tier_Amount) SumOfTierAmount

			FROM 	BB_Growth_Tier_RateCheck

			WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND 	Actual_Program_ID = <cfqueryparam value="#Actual_Program_ID#" cfsqltype="CF_SQL_INTEGER">
			AND		Product_ID = <cfqueryparam value="#Product_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND		Deleted = 0
		</CFQUERY>

		<CFSET FinalRateOfThisProduct = ProductSum.SumOfTierAmount>

		<CFIF GetRatio EQ 1>
			<CFSET FinalRateOfThisProduct = (FinalRateOfThisProduct / SumOfAllProducts) * ExpectedAmtOfThisProgram>
		</CFIF>

		<CFQUERY NAME="ExpectedVolumeOfThisProduct" DATASOURCE="#Application.Datasource#">
			SELECT  Invoice_Volume_LB,
					Invoice_Volume_CS

			FROM    BB_Growth_Product_Component

			WHERE   Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND		Actual_Program_ID = <cfqueryparam value="#Actual_Program_ID#" cfsqltype="CF_SQL_INTEGER">
			AND		Product_ID = <cfqueryparam value="#Product_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND		Deleted = 0
		</CFQUERY>

		<CFIF CheckUOM.Contract_Quantity_UOM_IDX EQ 1>
			<CFSET FinalVolume = ExpectedVolumeOfThisProduct.Invoice_Volume_CS>
		<CFELSEIF CheckUOM.Contract_Quantity_UOM_IDX EQ 2>
			<CFSET FinalVolume = ExpectedVolumeOfThisProduct.Invoice_Volume_LB>
		</CFIF>

		<CFIF FinalRateOfThisProduct LT 0>
			<CFSET FinalRateOfThisProduct = 0>
		</CFIF>

		<CFQUERY NAME="UpdateVolume" DATASOURCE="#Application.Datasource#">
			UPDATE 	Billback_Product

			SET 	BB_Product_Quantity = <cfqueryparam value="#FinalVolume#" cfsqltype="CF_SQL_FLOAT">

			WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND		Billback_Program_ID = <cfqueryparam value="#BillbackProgramID#" cfsqltype="CF_SQL_VARCHAR">
			AND		Product_ID = <cfqueryparam value="#Product_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND		Deleted = 0
		</CFQUERY>

		<CFQUERY NAME="GetBBProductID" DATASOURCE="#Application.Datasource#">
			SELECT 	Billback_Product_ID

			FROM 	Billback_Product

			WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND		Billback_Program_ID = <cfqueryparam value="#BillbackProgramID#" cfsqltype="CF_SQL_VARCHAR">
			AND		Product_ID = <cfqueryparam value="#Product_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND		Deleted = 0
		</CFQUERY>

		<CFQUERY NAME="UpdateRate" DATASOURCE="#Application.Datasource#">
			UPDATE 	Billback_Product_Detail

			SET		BB_Rate = <cfqueryparam value="#FinalRateOfThisProduct#" cfsqltype="CF_SQL_FLOAT">

			WHERE	Billback_Product_ID = <cfqueryparam value="#GetBBProductID.Billback_Product_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND 	BB_Product_Type_ID = 4
			AND		Deleted = 0
		</CFQUERY>
	</CFLOOP>


	<!--- Lumpsum --->
	<CFQUERY NAME="GetContractNumber" DATASOURCE="#Application.Datasource#">
		SELECT Contract_Number FROM Contract_Main WHERE Contract_Main_ID = <cfqueryparam value="#Program_ID#" cfsqltype="CF_SQL_INTEGER">
	</CFQUERY>
	<CFQUERY  NAME="GetProgramEndDate" DATASOURCE="#application.datasource#">
		SELECT 	MAX(Approval_End_Date) AS Program_End_Date

		FROM 	BB_Program_Info

		WHERE	BB_Program_Info.Contract_Number = <cfqueryparam value="#GetContractNumber.Contract_Number#" cfsqltype="CF_SQL_VARCHAR">
		AND		BB_Program_Info.Deleted = 0
	</CFQUERY>
	<CFSET Program_End_Date = GetProgramEndDate.Program_End_Date >


	<CFIF DATEDIFF("d", Program_End_Date, TrimBB_End_Date) GTE 0>
		<CFSET Lumpsum_End_Date = Program_End_Date>
	<CFELSE>
		<CFSET Lumpsum_End_Date = TrimBB_End_Date>
	</CFIF>

	<CFQUERY NAME="GetLumpsumAmount" DATASOURCE="#Application.Datasource#">
		SELECT		Program_Lump_Sums.Lump_Sum_Amount,
					Program_Lump_Sums.Program_Lump_Sum_ID,
					Program_Lump_Sums.Program_ID

		FROM		Contract_Main

		INNER JOIN	BB_Program_Info ON BB_Program_Info.Contract_Main_ID = Contract_Main.Contract_Main_ID AND
					DATEDIFF(d, Approval_Start_Date, #createodbcdate(Lumpsum_End_Date)#) >= 0 AND
					DATEDIFF(d, #createodbcdate(Lumpsum_End_Date)#, Approval_End_Date) >= 0 AND
					BB_Program_Info.Deleted = 0

		INNER JOIN	Program_Lump_Sums ON Program_Lump_Sums.Program_ID = Contract_Main.Contract_Main_ID AND
					Program_Lump_Sums.Deleted = 0

		WHERE		Contract_Main.Contract_Number = <cfqueryparam value="#GetContractNumber.Contract_Number#" cfsqltype="CF_SQL_VARCHAR">
	</CFQUERY>



	<CFSET SumLumpsumAmount = 0>
	<CFOUTPUT QUERY="GetLumpsumAmount">
		<CFSET SumLumpsumAmount = SumLumpsumAmount + Lump_Sum_Amount>
	</CFOUTPUT>




	<CFQUERY NAME="GetComponent" DATASOURCE="#Application.Datasource#">
		SELECT 		a.Program_Growth_Component_ID,
					a.growth_amount,
					a.Tier_Number,
					Program_Growth_Component_Tier_ID

		FROM  		BB_Growth_Tier_RateCheck a

		INNER JOIN 	Program_Growth_Component_Tiers ON Program_Growth_Component_Tiers.Program_Growth_Component_ID = a.Program_Growth_Component_ID AND
					Program_Growth_Component_Tiers.Tier_Number = a.Tier_Number AND
					Program_Growth_Component_Tiers.Deleted = 0

		WHERE 		a.Actual_Program_ID = <cfqueryparam value="#Program_ID#" cfsqltype="CF_SQL_INTEGER">
					AND Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
					AND PRODUCT_ID = 	(	SELECT 	TOP 1 PRODUCT_ID
											FROM 	BB_Growth_Tier_RateCheck c
											WHERE 	c.Actual_program_id = a.Actual_program_id AND
													c.Billback_id = a.Billback_id AND
													c.program_growth_component_id =  a.program_growth_component_id AND
													Deleted = 0
										)
					AND a.Deleted = 0
	</CFQUERY>

	<CFSET TierID = VALUELIST(GetComponent.Program_Growth_Component_Tier_ID)>


	<CFOUTPUT QUERY="GetComponent">
		<CFSET SumLumpsumAmount = SumLumpsumAmount + growth_amount>
	</CFOUTPUT>


	<CFQUERY NAME="DeletedUnReachedTiers" DATASOURCE="#Application.Datasource#">
		UPDATE  Billback_Program_Lumpsum_Component

		SET 	Deleted = 1

		WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND		Billback_Program_ID = <cfqueryparam value="#Billback_Program_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND		Component_Type_ID = 3
		AND
				<CFIF TierID NEQ "">
					Program_Growth_Component_Tier_ID NOT IN (#LISTQUALIFY(TierID,"'",",","All")#) AND
				</CFIF>
				Deleted = 0
	</CFQUERY>

	<CFQUERY NAME="GetExpectedLumpSum" DATASOURCE="#Application.Datasource#">
		SELECT 	*
		FROM 	BB_Lump_Sums
		WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND 	Billback_Program_ID = <cfqueryparam value="#Billback_Program_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND		Deleted = 0
	</CFQUERY>

	<CFIF GetExpectedLumpSum.LS_Expected_Amount EQ "">
		<CFSET ExpectedLumpsumAmount = 0>
	<CFELSE>
		<CFSET ExpectedLumpsumAmount = GetExpectedLumpSum.LS_Expected_Amount>
	</CFIF>


	<CFSET LumpsumRatio = 0>
	<CFIF SumLumpsumAmount NEQ ExpectedLumpsumAmount>

		<CFSET LumpsumRatio = 1>
	</CFIF>


	<CFSET BBProgramID = Billback_Program_ID>

	<CFLOOP QUERY="GetLumpsumAmount">

		<CFIF LumpsumRatio EQ 0>
			<CFSET FinalLumpsumAmount = Lump_Sum_Amount>
		<CFELSE>
			<CFSET FinalLumpsumAmount = (Lump_Sum_Amount / SumLumpsumAmount) * ExpectedLumpsumAmount>
		</CFIF>

		<CFQUERY NAME="UpdateLumpAmt" DATASOURCE="#Application.Datasource#">
			UPDATE 	Billback_Program_Lumpsum_Component

			SET 	Amount = 	<cfqueryparam value="#FinalLumpsumAmount#" cfsqltype="CF_SQL_FLOAT">

			WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND		Billback_Program_ID = <cfqueryparam value="#BBProgramID#" cfsqltype="CF_SQL_VARCHAR">
			AND		Program_Lump_Sum_ID = <cfqueryparam value="#Program_Lump_Sum_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND		Component_Type_ID = 1
			AND		Deleted = 0
		</CFQUERY>
	</CFLOOP>

	<CFLOOP QUERY="GetComponent">

		<CFIF LumpsumRatio EQ 0>
			<CFSET FinalGrowthLumpAmt = growth_amount>
		<CFELSE>
			<CFSET FinalGrowthLumpAmt = (growth_amount / SumLumpsumAmount) * ExpectedLumpsumAmount>
		</CFIF>

		<CFQUERY NAME="UpdateGrowthLump" DATASOURCE="#Application.Datasource#">
			UPDATE 	Billback_Program_Lumpsum_Component

			SET 	Amount = 	<cfqueryparam value="#FinalGrowthLumpAmt#" cfsqltype="CF_SQL_FLOAT">

			WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND		Billback_Program_ID = <cfqueryparam value="#BBProgramID#" cfsqltype="CF_SQL_VARCHAR">
			AND		Program_Lump_Sum_ID = <cfqueryparam value="#Program_Growth_Component_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND		Program_Growth_Component_Tier_ID = <cfqueryparam value="#Program_Growth_Component_Tier_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND		Component_Type_ID = 3
			AND		Deleted = 0
		</CFQUERY>
	</CFLOOP>
</CFLOOP>






<!--- Fixed --->
<CFQUERY NAME="GetItemsRate" DATASOURCE="#Application.Datasource#">
	SELECT 		BB_Fixed_Product_Rate.Billback_Product_ID,
				BB_Fixed_Product_Rate.Program_ID,
				BB_Volume_LB,
				BB_Volume_CS,
				E_Volume_LB,
				E_Volume_CS,
				BB_Rate_LB,
				BB_Rate_CS,
				E_Rate_LB,
				E_Rate_CS

	FROM 		BB_Fixed_Product_Rate
	INNER JOIN	BB_Fixed_Product_Volume ON BB_Fixed_Product_Volume.Billback_Product_ID = BB_Fixed_Product_Rate.Billback_Product_ID

	WHERE 		BB_Fixed_Product_Rate.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	AND			BB_Fixed_Product_Rate.Deleted = 0
	AND			BB_Fixed_Product_Volume.Deleted = 0
</CFQUERY>

<CFSET PreviousProgram = "">
<CFLOOP QUERY="GetItemsRate">

	<CFIF PreviousProgram NEQ Program_ID>
		<CFQUERY NAME="CheckUOM" DATASOURCE="#Application.Datasource#">
			SELECT 	Contract_Quantity_UOM_IDX
			FROM 	Contract_Main
			WHERE 	Contract_Main_ID = <cfqueryparam value="#Program_ID#" cfsqltype="CF_SQL_INTEGER">
		</CFQUERY>

		<CFIF CheckUOM.Contract_Quantity_UOM_IDX EQ 1>
			<CFSET UOM = 1>
		<CFELSEIF CheckUOM.Contract_Quantity_UOM_IDX EQ 2>
			<CFSET UOM = 2>
		</CFIF>
	</CFIF>


	<CFIF UOM EQ 1>
		<CFSET FinalVolume = E_Volume_CS>
		<CFSET FinalRate = E_Rate_CS>
	<CFELSEIF UOM EQ 2>
		<CFSET FinalVolume = E_Volume_LB>
		<CFSET FinalRate = E_Rate_LB>
	</CFIF>

	<CFIF FinalRate EQ "">
		<CFSET FinalRate = 0>
	</CFIF>

	<CFIF FinalVolume EQ "">
		<CFSET FinalVolume = 0>
	</CFIF>


	<CFSET FinalRate = 	FinalRate * FinalVolume>
	<CFIF FinalRate LT 0>
		<CFSET FinalRate = 0>
	</CFIF>

	<CFQUERY NAME="UpdateVolume" DATASOURCE="#Application.Datasource#">
		UPDATE 	Billback_Product

		SET 	BB_Product_Quantity = <cfqueryparam value="#FinalVolume#" cfsqltype="CF_SQL_FLOAT">

		WHERE 	Billback_Product_ID = <cfqueryparam value="#Billback_Product_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND		Deleted = 0
	</CFQUERY>

	<CFQUERY NAME="UpdateRate" DATASOURCE="#Application.Datasource#">
		UPDATE 	Billback_Product_Detail

		SET 	BB_Rate = <cfqueryparam value="#FinalRate#" cfsqltype="CF_SQL_FLOAT">

		WHERE 	Billback_Product_ID = <cfqueryparam value="#Billback_Product_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND		BB_Product_Type_ID = 1
		AND		Deleted = 0
	</CFQUERY>

	<CFSET PreviousProgram = Program_ID>
</CFLOOP>

<!--- Rebate --->
<CFQUERY NAME="GetRebateRateVol" DATASOURCE="#Application.Datasource#">
	SELECT 		BB_Rebate_Product_Rate.Billback_Product_ID,
				BB_Rebate_Product_Rate.Program_ID,
				BB_Volume_LB,
				BB_Volume_CS,
				E_Volume_LB,
				E_Volume_CS,
				BB_Rate_LB,
				BB_Rate_CS,
				E_Rate_LB,
				E_Rate_CS

	FROM 		BB_Rebate_Product_Rate
	INNER JOIN	BB_Rebate_Product_Volume ON BB_Rebate_Product_Volume.Billback_Product_ID = BB_Rebate_Product_Rate.Billback_Product_ID

	WHERE 		BB_Rebate_Product_Rate.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	AND			BB_Rebate_Product_Rate.Deleted = 0
	AND			BB_Rebate_Product_Volume.Deleted = 0
</CFQUERY>

<CFSET PreviousProgram = "">
<CFLOOP QUERY="GetRebateRateVol">

	<CFIF PreviousProgram NEQ Program_ID>
		<CFQUERY NAME="CheckUOM" DATASOURCE="#Application.Datasource#">
			SELECT 	Contract_Quantity_UOM_IDX
			FROM 	Contract_Main
			WHERE 	Contract_Main_ID = <cfqueryparam value="#Program_ID#" cfsqltype="CF_SQL_INTEGER">
		</CFQUERY>
		<CFIF CheckUOM.Contract_Quantity_UOM_IDX EQ 1>
			<CFSET UOM = 1>
		<CFELSEIF CheckUOM.Contract_Quantity_UOM_IDX EQ 2>
			<CFSET UOM = 2>
		</CFIF>
	</CFIF>
	<CFIF UOM EQ 1>
		<CFSET FinalVolume = E_Volume_CS>
		<CFSET FinalRate = E_Rate_CS>
	<CFELSEIF UOM EQ 2>
		<CFSET FinalVolume = E_Volume_LB>
		<CFSET FinalRate = E_Rate_LB>
	</CFIF>

	<CFIF FinalRate EQ "">
		<CFSET FinalRate = 0>
	</CFIF>

	<CFIF FinalVolume EQ "">
		<CFSET FinalVolume = 0>
	</CFIF>


	<CFSET FinalRate = FinalRate * FinalVolume>
	<CFIF FinalRate LT 0>
		<CFSET FinalRate = 0>
	</CFIF>

	<CFQUERY NAME="UpdateVolume" DATASOURCE="#Application.Datasource#">
		UPDATE 	Billback_Product

		SET 	BB_Product_Quantity = <cfqueryparam value="#FinalVolume#" cfsqltype="CF_SQL_FLOAT">

		WHERE 	Billback_Product_ID = <cfqueryparam value="#Billback_Product_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND		Deleted = 0
	</CFQUERY>

	<CFQUERY NAME="UpdateRate" DATASOURCE="#Application.Datasource#">
		UPDATE 	Billback_Product_Detail

		SET 	BB_Rate = <cfqueryparam value="#FinalRate#" cfsqltype="CF_SQL_FLOAT">

		WHERE 	Billback_Product_ID = <cfqueryparam value="#Billback_Product_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND		BB_Product_Type_ID = 2
		AND		Deleted = 0
	</CFQUERY>

	<CFSET PreviousProgram = Program_ID>
</CFLOOP>


<!--- Formula--->
<CFQUERY NAME="GetFormulaRateVol" DATASOURCE="#Application.Datasource#">
	SELECT 		BB_Formula_Product_Rate.Billback_Product_ID,
				BB_Formula_Product_Rate.Program_ID,
				BB_Volume_LB,
				BB_Volume_CS,
				E_Volume_LB,
				E_Volume_CS,
				BB_Rate_LB,
				BB_Rate_CS,
				E_Rate_LB,
				E_Rate_CS

	FROM 		BB_Formula_Product_Rate
	INNER JOIN	BB_Formula_Product_Volume ON BB_Formula_Product_Volume.Billback_Product_ID = BB_Formula_Product_Rate.Billback_Product_ID

	WHERE 		BB_Formula_Product_Rate.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	AND 		BB_Formula_Product_Rate.Deleted = 0
	AND 		BB_Formula_Product_Rate.Deleted = 0
</CFQUERY>


<CFSET PreviousProgram = "">
<CFLOOP QUERY="GetFormulaRateVol">

	<CFIF PreviousProgram NEQ Program_ID>
		<CFQUERY NAME="CheckUOM" DATASOURCE="#Application.Datasource#">
			SELECT 	Contract_Quantity_UOM_IDX
			FROM 	Contract_Main
			WHERE 	Contract_Main_ID = <cfqueryparam value="#Program_ID#" cfsqltype="CF_SQL_INTEGER">
		</CFQUERY>
		<CFIF CheckUOM.Contract_Quantity_UOM_IDX EQ 1>
			<CFSET UOM = 1>
		<CFELSEIF CheckUOM.Contract_Quantity_UOM_IDX EQ 2>
			<CFSET UOM = 2>
		</CFIF>
	</CFIF>

	<CFIF UOM EQ 1>
		<CFSET FinalVolume = E_Volume_CS>
		<CFSET FinalRate = E_Rate_CS>
	<CFELSEIF UOM EQ 2>
		<CFSET FinalVolume = E_Volume_LB>
		<CFSET FinalRate = E_Rate_LB>
	</CFIF>

	<CFIF FinalRate EQ "">
		<CFSET FinalRate = 0>
	</CFIF>

	<CFIF FinalVolume EQ "">
		<CFSET FinalVolume = 0>
	</CFIF>

	<CFSET FinalRate = FinalRate * FinalVolume>
	<CFIF FinalRate LT 0>
		<CFSET FinalRate = 0>
	</CFIF>


	<CFQUERY NAME="UpdateVolume" DATASOURCE="#Application.Datasource#">
		UPDATE 	Billback_Product

		SET 	BB_Product_Quantity = <cfqueryparam value="#FinalVolume#" cfsqltype="CF_SQL_FLOAT">

		WHERE 	Billback_Product_ID = <cfqueryparam value="#Billback_Product_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND		Deleted = 0
	</CFQUERY>

	<CFQUERY NAME="UpdateRate" DATASOURCE="#Application.Datasource#">
		UPDATE 	Billback_Product_Detail

		SET 	BB_Rate = <cfqueryparam value="#FinalRate#" cfsqltype="CF_SQL_FLOAT">

		WHERE 	Billback_Product_ID = <cfqueryparam value="#Billback_Product_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND		BB_Product_Type_ID = 5
		AND		Deleted = 0
	</CFQUERY>

	<CFSET PreviousProgram = Program_ID>
</CFLOOP>


<!--- Delete all Billback_Product_Detail entries and Billback_product entries (if necessary) that has 0 rate --->
<CFQUERY NAME="GetRateZero" DATASOURCE="#Application.Datasource#">
	SELECT 	DISTINCT 	Billback_Product_ID
	FROM 				Billback_Product_Detail
	WHERE 				Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	AND					BB_Rate = '0'
	AND					Deleted = 0
</CFQUERY>

<CFQUERY NAME="DeleteAllRateZeros" DATASOURCE="#Application.Datasource#">
	UPDATE 	Billback_Product_Detail

	SET 	Deleted = 1

	WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	AND		BB_Rate = '0'
	AND		Deleted = 0
</CFQUERY>


<CFLOOP QUERY="GetRateZero">
	<CFQUERY NAME="CheckOtherProductTypeFortheSameID" DATASOURCE="#Application.Datasource#">
		SELECT 	*

		FROM 	Billback_Product_Detail

		WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND 	Billback_Product_ID = <cfqueryparam value="#Billback_Product_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND		Deleted = 0
	</CFQUERY>


	<CFIF CheckOtherProductTypeFortheSameID.RecordCount EQ 0>
		<CFQUERY NAME="DeleteThisProductFromBBProduct" DATASOURCE="#Application.Datasource#">
			UPDATE 	Billback_Product

			SET 	Deleted = 1

			WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND		Billback_Product_ID = <cfqueryparam value="#Billback_Product_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND		Deleted = 0
		</CFQUERY>
	</CFIF>
</CFLOOP>


<!--- Check for volume Zero and less than zero --->
<CFQUERY NAME="GetZeroVolume" DATASOURCE="#Application.Datasource#">
	SELECT  Billback_Product_ID
	FROM    Billback_Product
	WHERE  	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	AND 	(CAST(BB_Product_Quantity as Float) <= '0')
	AND		Deleted = 0
</CFQUERY>
<CFSET ProductsWithZeroVol = VALUELIST(GetZeroVolume.Billback_Product_ID)>
<CFIF ProductsWithZeroVol NEQ "">
	<CFQUERY NAME="DeleteFromDetails" DATASOURCE="#Application.Datasource#">
		UPDATE 	Billback_Product_Detail

		SET 	Deleted = 1

		WHERE 	Billback_Product_ID IN (#LISTQUALIFY(ProductsWithZeroVol,"'",",","All")#) AND
				Deleted = 0
	</CFQUERY>

	<CFQUERY NAME="DeleteFrom" DATASOURCE="#Application.Datasource#">
		Update Billback_Product

		SET Deleted = 1

		WHERE 	Billback_Product_ID IN (#LISTQUALIFY(ProductsWithZeroVol,"'",",","All")#) AND
				Deleted = 0
	</CFQUERY>
</CFIF>

<CFQUERY NAME="DeleteZeroLump" DATASOURCE="#Application.Datasource#">
	UPDATE 	Billback_Program_Lumpsum_Component

	SET 	Deleted = 1

	WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	AND 	(Amount <= '0' OR Amount = '' OR Amount Is Null)
	AND		Deleted = 0
</CFQUERY>



<!--- Calculate Billback Amount --->
<CFQUERY NAME="ProductType1245" DATASOURCE="#Application.Datasource#">
	SELECT 	SUM(CAST(BB_Rate AS Float)) AS TotOf1245

	FROM  	Billback_Product_Detail

	WHERE   Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	AND		Deleted = 0
</CFQUERY>



<CFQUERY NAME="LumpSumAmount" DATASOURCE="#Application.Datasource#">
	SELECT  SUM(CAST(Amount AS Float)) TotOf3

	FROM 	Billback_Program_Lumpsum_Component

	WHERE   Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	AND		Deleted = 0
</CFQUERY>

<CFSET BB_Amount = 0>
<CFIF ProductType1245.RecordCount GT 0 AND ProductType1245.TotOf1245 NEQ "">
	<CFSET BB_Amount = ProductType1245.TotOf1245>
</CFIF>


<CFIF LumpSumAmount.RecordCount GT 0 AND LumpSumAmount.TotOf3 NEQ "">
	<CFSET BB_Amount = BB_Amount + LumpSumAmount.TotOf3>
</CFIF>




<!--- Update Billback Amount --->
<CFQUERY NAME="UpdateBB" DATASOURCE="#Application.Datasource#">
	UPDATE 	Billback

	SET 	BB_Amount = <cfqueryparam value="#BB_Amount#" cfsqltype="CF_SQL_FLOAT">,
			Flag_Auto_Billback = 0

	WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	AND		Deleted = 0
</CFQUERY>

<CFIF IsDefined("IncludedInAuto_Distributor_Program_ActionCFM")>
	<CFOUTPUT>
	<CFLOCATION URL="/billbacks/capture/billback_summary.cfm?BBID=#Billback_ID#" ADDTOKEN="No">
	</CFOUTPUT>
</CFIF>

<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->





