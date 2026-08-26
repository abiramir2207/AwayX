



<CFIF IsDefined("FORM.Get_All_Items")>
	
	<CFSET IsAnyDiscountAvailable = 0>
	<CFSET FinalFixedRateForAny = 0>
	<CFSET FinalRebateRateForAny = 0>
	<CFSET FinalFormulaRateForAny = 0>
	
	<CFQUERY NAME="GetProductType" DATASOURCE="#Application.Datasource#">
		SELECT 	DISTINCT(BB_Product_Type_ID)
		
		FROM 	Billback_Auto_Any_Option 
		
		WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND 			
				Deleted = 0
	</CFQUERY>
	
	
	
	<CFLOOP QUERY="GetProductType">
		<CFIF BB_Product_Type_ID EQ 1>
			<CFSET IsAnyDiscountAvailable = 1>
			<CFQUERY NAME="GetFixedRateCount" DATASOURCE="#Application.Datasource#">
				SELECT		Count(*) RateRepetition,
							Unit_Rate 
				
				FROM 		Billback_Auto_Any_Option
				
				WHERE 		Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND 	
							BB_Product_Type_ID = 1 AND						
							Deleted = 0
							
				GROUP BY	Unit_Rate
				
				ORDER BY 	RateRepetition DESC
			</CFQUERY>
			
			<CFSET FixedMaxRepetition = GetFixedRateCount.RateRepetition>
			
			<CFQUERY NAME="GetMinRate" DBTYPE="QUERY">
				SELECT MIN(Unit_Rate) FinalFixedRate
				
				FROM GetFixedRateCount
				
				WHERE RateRepetition = <cfqueryparam value="#FixedMaxRepetition#" cfsqltype="CF_SQL_INTEGER">
			</CFQUERY>
			
			<CFSET FinalFixedRateForAny = GetMinRate.FinalFixedRate>
		
		
		<CFELSEIF BB_Product_Type_ID EQ 2>
			<CFSET IsAnyDiscountAvailable = 1>
			<CFQUERY NAME="GetRebateRateCount" DATASOURCE="#Application.Datasource#">
				SELECT		Count(*) RateRepetition,
							Unit_Rate 
				
				FROM 		Billback_Auto_Any_Option
				
				WHERE 		Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND 	
							BB_Product_Type_ID = 2 AND						
							Deleted = 0
							
				GROUP BY	Unit_Rate
				
				ORDER BY 	RateRepetition DESC
			</CFQUERY>
			
			<CFSET RebateMaxRepetition = GetRebateRateCount.RateRepetition>
			
			<CFQUERY NAME="GetMinRate" DBTYPE="QUERY">
				SELECT MIN(Unit_Rate) FinalRebateRate
				
				FROM GetRebateRateCount
				
				WHERE RateRepetition = <cfqueryparam value="#RebateMaxRepetition#" cfsqltype="CF_SQL_INTEGER">
			</CFQUERY>
			
			<CFSET FinalRebateRateForAny = GetMinRate.FinalRebateRate>
			
		<CFELSEIF BB_Product_Type_ID EQ 5>	
			<CFSET IsAnyDiscountAvailable = 1>
			<CFQUERY NAME="GetFormulaRateCount" DATASOURCE="#Application.Datasource#">
				SELECT		Count(*) RateRepetition,
							Unit_Rate 
				
				FROM 		Billback_Auto_Any_Option
				
				WHERE 		Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND
							BB_Product_Type_ID = 5 AND						
							Deleted = 0
							
				GROUP BY	Unit_Rate
				
				ORDER BY 	RateRepetition DESC
			</CFQUERY>
			
			<CFSET FormulaMaxRepetition = GetFormulaRateCount.RateRepetition>
			
			<CFQUERY NAME="GetMinRate" DBTYPE="QUERY">
				SELECT MIN(Unit_Rate) FinalFormulaRate
				
				FROM GetFormulaRateCount
				
				WHERE RateRepetition = <cfqueryparam value="#FormulaMaxRepetition#" cfsqltype="CF_SQL_INTEGER">
			</CFQUERY>
			
			<CFSET FinalFormulaRateForAny = GetMinRate.FinalFormulaRate>
		</CFIF>
	</CFLOOP>

	<CFIF IsAnyDiscountAvailable EQ 1>
		<CFQUERY NAME="ForAnyGetInvoiceDetails" DATASOURCE="#Application.Datasource#">
			SELECT 		Invoice_Detail.BSA_Foodservice_Items_Master_ID ,
						CAST(Invoice_Detail.Pounds_Invoiced AS Float) Pounds_Invoiced, 
						CAST(Invoice_Detail.Cases_Invoiced AS Float) Cases_Invoiced, 
						Invoice_Header.Invoice_Date,
						Invoice_Header.Ship_Date,
						CAST(Invoice_Detail.LB_Unit_Price AS Float) LB_Unit_Price,
						CAST(Invoice_Detail.CS_Unit_Price AS Float) CS_Unit_Price
						
			FROM 		Invoice_Header
			
			INNER JOIN 	Invoice_Detail ON Invoice_Header.Invoice_Header_ID = Invoice_Detail.Invoice_Header_ID
			
			WHERE 		Invoice_Detail.BSA_Foodservice_Items_Master_ID NOT IN (	SELECT 	DISTINCT BSA_Foodservice_Items_Master_ID
																					FROM 	Contract_Products
																					WHERE	Contract_Main_ID IN (#ContractIDList#) AND 
																							Product_Type_ID NOT IN (3,8) AND
																							Deleted = 0									) AND 
						Invoice_Header.BSA_Foodservice_Customers_ID = <cfqueryparam value="#Distributor_List#" cfsqltype="CF_SQL_VARCHAR"> AND 
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
		
		<CFIF ForAnyGetInvoiceDetails.RecordCount GT 0>
		
			<CFQUERY NAME="DistinctProductForAny" DBTYPE="QUERY">
				SELECT 	DISTINCT(BSA_Foodservice_Items_Master_ID) AnyProductID
				FROM 	ForAnyGetInvoiceDetails
			</CFQUERY>
			
			
			<CFLOOP QUERY="DistinctProductForAny">

				<CFSET AnySumPoundsInvoiced = 0>
				<CFSET AnySumCasesInvoiced = 0>
				<CFSET AnyFixedRateOfThisProduct = 0>
				<CFSET AnyFixedVolOfThisProduct = 0>
				<CFSET AnyRebateRateOfThisProduct = 0>
				<CFSET AnyRebateVolOfThisProduct = 0>
				<CFSET AnyFormulaRateOfThisProduct = 0>
				<CFSET AnyFormulaVolOfThisProduct = 0>
				
				<CFQUERY NAME="ThisAnyProductInvoice" DBTYPE="QUERY">
					SELECT 	*	
					FROM 	ForAnyGetInvoiceDetails		
					WHERE 	BSA_Foodservice_Items_Master_ID = <cfqueryparam value="#AnyProductID#" cfsqltype="CF_SQL_VARCHAR">
				</CFQUERY>
				
				
				<CFLOOP QUERY="ThisAnyProductInvoice">
					<CFSET AnyInvoice_LB = Pounds_Invoiced>
					<CFSET AnyInvoice_CS = Cases_Invoiced>
					<CFSET AnyLBUnitPrice = LB_Unit_Price>
					<CFSET AnyCSUnitPrice = CS_Unit_Price>	
					<CFSET AnySumPoundsInvoiced = AnySumPoundsInvoiced + AnyInvoice_LB>
					<CFSET AnySumCasesInvoiced = AnySumCasesInvoiced + AnyInvoice_CS>
					
					
					<CFIF FinalFixedRateForAny GT 0>
						<CFIF ThisProgramUOM EQ 1>
							<CFSET AnyRateDiff = AnyCSUnitPrice - FinalFixedRateForAny>
							<CFSET AnyThisInvoiceRate = AnyRateDiff * AnyInvoice_CS>
							<CFSET AnyThisInvoiceVol = AnyInvoice_CS>
						<CFELSEIF ThisProgramUOM EQ 2>
							<CFSET AnyRateDiff = AnyLBUnitPrice - FinalFixedRateForAny>
							<CFSET AnyThisInvoiceRate = AnyRateDiff * AnyInvoice_LB>
							<CFSET AnyThisInvoiceVol = AnyInvoice_LB>
						</CFIF>
						
						<CFSET 	AnyFixedRateOfThisProduct = AnyFixedRateOfThisProduct + AnyThisInvoiceRate>
						<CFSET 	AnyFixedVolOfThisProduct = AnyFixedVolOfThisProduct + AnyThisInvoiceVol>	
					</CFIF>
					
					<CFIF FinalRebateRateForAny GT 0>
						<CFIF ThisProgramUOM EQ 1>
							<CFSET AnyInvoiceRebateRate = FinalRebateRateForAny * AnyInvoice_CS>
							<CFSET AnyInvoiceRebateVolume = AnyInvoice_CS>
						<CFELSEIF ThisProgramUOM EQ 2>
							<CFSET AnyInvoiceRebateRate = FinalRebateRateForAny * AnyInvoice_LB>
							<CFSET AnyInvoiceRebateVolume = AnyInvoice_LB>
						</CFIF>
						
						<CFSET AnyRebateRateOfThisProduct = AnyRebateRateOfThisProduct + AnyInvoiceRebateRate>
						<CFSET AnyRebateVolOfThisProduct = AnyRebateVolOfThisProduct + AnyInvoiceRebateVolume>
					</CFIF>
					
					<CFIF FinalFormulaRateForAny GT 0>
						<CFIF ThisProgramUOM EQ 1>
							<CFSET AnyRateDiff = AnyCSUnitPrice - FinalFormulaRateForAny>
							<CFSET AnyInvoiceFormulaRate = AnyRateDiff * AnyInvoice_CS>
							<CFSET AnyInvoiceFormulaVol = AnyInvoice_CS>
						<CFELSEIF ThisProgramUOM EQ 2>
							<CFSET AnyRateDiff = AnyLBUnitPrice - FinalFormulaRateForAny>
							<CFSET AnyInvoiceFormulaRate = AnyRateDiff * AnyInvoice_LB>
							<CFSET AnyInvoiceFormulaVol = AnyInvoice_LB>
						</CFIF>
						
						<CFSET AnyFormulaRateOfThisProduct = AnyFormulaRateOfThisProduct + AnyInvoiceFormulaRate>
						<CFSET AnyFormulaVolOfThisProduct = AnyFormulaRateOfThisProduct + AnyInvoiceFormulaVol>
					</CFIF>
					
				</CFLOOP>
				
				
				<CFSET BSA_Foodservice_Items_Master_ID = AnyProductID>
				<CFIF AnyFixedVolOfThisProduct GT 0 OR AnyRebateVolOfThisProduct GT 0 OR AnyFormulaVolOfThisProduct GT 0>
					<CFIF ThisProgramUOM EQ 1>		
						<CFSET FinalVolume = AnySumCasesInvoiced>
					<CFELSEIF ThisProgramUOM EQ 2>
						<CFSET FinalVolume = AnySumPoundsInvoiced>
					</CFIF>
					<CFSET InsertProduct = 1>
					<CFINCLUDE TEMPLATE="Product_Data_Insert.cfm">	
					<CFSET InsertProduct = 0>
				</CFIF>
				
				<CFIF AnyFixedVolOfThisProduct GT 0>
					<CFSET FinalRate = AnyFixedRateOfThisProduct>
					<CFSET BB_Product_Type_ID = 1>
					
					<CFINCLUDE TEMPLATE="Product_Data_Insert.cfm">		
				</CFIF>
				
				<CFIF AnyRebateVolOfThisProduct GT 0>
					<CFSET FinalRate = AnyRebateRateOfThisProduct>
					<CFSET BB_Product_Type_ID = 2>
					
					<CFINCLUDE TEMPLATE="Product_Data_Insert.cfm">
				</CFIF>
				
				<CFIF AnyFormulaVolOfThisProduct GT 0>
					<CFSET FinalRate = AnyFormulaRateOfThisProduct>
					<CFSET BB_Product_Type_ID = 5>
					
					<CFINCLUDE TEMPLATE="Product_Data_Insert.cfm">
				</CFIF>
				
			</CFLOOP>
			
		</CFIF> 
	</CFIF>
</CFIF>

 
 
 
 
 

<!--- Delete all Billback_Product_Detail entries and Billback_product entries (if necessary) that has 0 rate --->
<CFQUERY NAME="GetRateZero" DATASOURCE="#Application.Datasource#">
	SELECT 	DISTINCT 	Billback_Product_ID
	FROM 				Billback_Product_Detail 
	WHERE 				Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND
						CAST(BB_Rate AS Float) <= 0 AND 
						Deleted = 0
</CFQUERY>

<CFQUERY NAME="DeleteAllRateZeros" DATASOURCE="#Application.Datasource#">
	UPDATE 	Billback_Product_Detail
	
	SET 	Deleted = 1
	
	WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND
			CAST(BB_Rate AS Float) <= '0' AND 
			Deleted = 0
</CFQUERY>


<CFLOOP QUERY="GetRateZero">	
	<CFQUERY NAME="CheckOtherProductTypeFortheSameID" DATASOURCE="#Application.Datasource#">
		SELECT 	* 
		
		FROM 	Billback_Product_Detail 
		
		WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND 
				Billback_Product_ID = <cfqueryparam value="#Billback_Product_ID#" cfsqltype="CF_SQL_VARCHAR"> AND
				Deleted = 0
	</CFQUERY>


	<CFIF CheckOtherProductTypeFortheSameID.RecordCount EQ 0>
		<CFQUERY NAME="DeleteThisProductFromBBProduct" DATASOURCE="#Application.Datasource#">
			UPDATE 	Billback_Product
			
			SET 	Deleted = 1
			
			WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND
					Billback_Product_ID = <cfqueryparam value="#Billback_Product_ID#" cfsqltype="CF_SQL_VARCHAR"> AND
					Deleted = 0
		</CFQUERY>
	</CFIF>	
</CFLOOP>


<!--- Check for volume Zero and less than zero --->
<CFQUERY NAME="GetZeroVolume" DATASOURCE="#Application.Datasource#">
	SELECT  Billback_Product_ID
	FROM    Billback_Product
	WHERE  	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND 
			(CAST(BB_Product_Quantity as Float) <= '0') AND
			Deleted = 0
</CFQUERY>
<CFSET ProductsWithZeroVol = VALUELIST(GetZeroVolume.Billback_Product_ID)>
<CFIF ProductsWithZeroVol NEQ "">
	<CFQUERY NAME="DeleteFromDetails" DATASOURCE="#Application.Datasource#">
		UPDATE 	Billback_Product_Detail
		
		SET 	Deleted = 1
		
		WHERE 	Billback_Product_ID IN (	SELECT  Billback_Product_ID
											FROM    Billback_Product
											WHERE  	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND 
													(CAST(BB_Product_Quantity as Float) <= '0') AND
													Deleted = 0										) AND 
				Deleted = 0 
	</CFQUERY>
	
	<CFQUERY NAME="DeleteFrom" DATASOURCE="#Application.Datasource#">
		Update Billback_Product
		
		SET Deleted = 1
		
		WHERE 	Billback_Product_ID IN (	SELECT  Billback_Product_ID
											FROM    Billback_Product
											WHERE  	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND 
													(CAST(BB_Product_Quantity as Float) <= '0') AND
													Deleted = 0										) AND 
				Deleted = 0 
	</CFQUERY>
</CFIF>

<CFLOCATION URL="Select_DiscountType.cfm?BBID=#Billback_ID#" ADDTOKEN="No">
