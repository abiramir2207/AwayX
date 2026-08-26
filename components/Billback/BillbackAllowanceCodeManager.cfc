<cfcomponent hint="Billback AllowanceCode Manager" extends="components.Base">

	<cffunction name="init" output="false" returntype="components.Billback.BillbackAllowanceCodeManager">
	
		<cfreturn this />
		
	</cffunction>
	<!--- BBItemFinal ---->
	<cfset variables.BillbackID = "" />
	

	<!---- getter BillbackID ---->
	<cffunction name="getBillbackID" returntype="string" access="public">
		<cfreturn variables.billbackID/>
	</cffunction>
	
	<!---- setter BillbackID ---->
	<cffunction name="setBillbackID" returntype="void"  access="package">
		<cfargument name="billbackID" required="true" type="string">
		<cfset variables.billbackID = arguments.billbackID />
	</cffunction>
	
	<cffunction name="allowanceCodeAllocation" output="true" returntype="void">	
		<cfargument name="billbackID" type="string" required="true" />
		<CFQUERY NAME="qEligibleDiscountType" DATASOURCE="#Application.Datasource#">
			SELECT 		DISTINCT BB_Product_Type
			FROM 		BB_Item_Final_Detail 
			INNER JOIN 	BB_Item_Final ON BB_Item_Final.BB_Item_Final_ID = BB_Item_Final_Detail.BB_Item_Final_ID AND BB_Item_Final.Deleted = 0 
			WHERE 		Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND BB_Item_Final_Detail.Deleted = 0
		</CFQUERY>
		<CFLOOP QUERY="qEligibleDiscountType">
			<CFIF qEligibleDiscountType.BB_Product_Type EQ 2>
				<CFSET AllocateRebateAmount(arguments.billbackID)>
			<CFELSEIF qEligibleDiscountType.BB_Product_Type EQ 1>
				<CFSET AllocateFixedPriceAmount(arguments.billbackID)>	
			<CFELSEIF qEligibleDiscountType.BB_Product_Type EQ 11>	
				<CFSET AllocateBidAmount(arguments.billbackID)>				
			</CFIF>
		</CFLOOP>
		<CFQUERY NAME="CheckLumpsum" DATASOURCE="#Application.Datasource#">
			SELECT * FROM BB_Lump_Sums WHERE Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND Deleted = 0
		</CFQUERY>
		
		<CFIF CheckLumpsum.RecordCount GT 0>
			<CFSET AllocateLumpSumAmount(arguments.billbackID)>
		</CFIF>
		
		<CFQUERY NAME="CheckGrowth" DATASOURCE="#Application.Datasource#">
			SELECT * FROM BB_Growth_Program	WHERE Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND Deleted = 0					
		</CFQUERY>
		<CFIF CheckGrowth.RecordCount GT 0>
			<CFSET AllocateGrowthAmount(arguments.billbackID)>
		</CFIF>		
		<CFQUERY NAME="SumAtAllowanceCode" DATASOURCE="#Application.Datasource#">
			INSERT INTO BB_AllowanceCode_Allocation_Summary (Billback_ID,Allowance_Code_ID,AllowanceCode_level_Sum,Allocated_Amount)
			SELECT Billback_ID,Allowance_Code_ID,1,SUM(Allocated_Amount)
			FROM BB_AllowanceCode_Allocation_Summary 
			WHERE Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND Deleted = 0 AND Allocated_Amount <> 0
			GROUP BY Billback_ID,Allowance_Code_ID
		</CFQUERY>
		<CFQUERY NAME="RoundAllocatedAmt" DATASOURCE="#Application.Datasource#">
			UPDATE BB_AllowanceCode_Allocation_Summary
			SET Allocated_Amount = (
			Allocated_Amount + (CAST(Paid_Amount AS Decimal(18,2)) - 
			(
			SELECT SUM(Allocated_Amount)
			FROM BB_AllowanceCode_Allocation_Summary BAAS1
			WHERE BAAS1.Billback_ID = BAAS.Billback_ID AND AllowanceCode_level_Sum = 1 AND Deleted = 0
			)))
			FROM BB_AllowanceCode_Allocation_Summary BAAS
			INNER JOIN BB_Approved ON BB_Approved.Billback_ID = BAAS.Billback_ID
			WHERE BAAS.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND AllowanceCode_level_Sum = 1 AND Deleted = 0 AND
			BAAS.BB_AllowanceCode_Allocation_Summary_ID = (SELECT TOP 1(BB_AllowanceCode_Allocation_Summary_ID)
			FROM BB_AllowanceCode_Allocation_Summary BAAS2 WHERE BAAS2.Billback_ID = BAAS.Billback_ID AND BAAS2.AllowanceCode_level_Sum = 1 AND 
			BAAS2.Deleted = 0 AND Allocated_Amount = (SELECT MAX(Allocated_Amount) FROM BB_AllowanceCode_Allocation_Summary BAAS3
			WHERE BAAS3.Billback_ID = BAAS2.Billback_ID AND BAAS3.AllowanceCode_level_Sum = 1 AND 
			BAAS3.Deleted = 0)
			)
		</CFQUERY>
		<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
		<cfif appSettings.getBillbacksSalesTax()>
			<CFSET AllocateTaxAmount(arguments.billbackID)>
		</cfif>
		
		<cfif appSettings.getPullbacksOn()>
			<CFQUERY NAME="CheckIfPulledBack" DATASOURCE="#Application.Datasource#">
				SELECT * FROM Pullbacks_Log
				INNER JOIN BB_Approved ON BB_Approved.Billback_ID = Pullbacks_Log.pullback_applied_to_billback_id
				WHERE Pullback_Applied_To_Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND
				Pullback_Applied = 1 AND Deleted = 0
			</CFQUERY>
			<CFIF CheckIfPulledBack.RecordCount GT 0 AND CheckIfPulledBack.Pullback_applied_Amount GT 0.00>
				<CFQUERY NAME="UPD_IfPulledBack" DATASOURCE="#Application.Datasource#">
					UPDATE BB_AllowanceCode_Allocation_Summary
					SET Allocated_Amount = Allocated_Amount - #CheckIfPulledBack.Pullback_applied_Amount#
					WHERE BB_AllowanceCode_Allocation_Summary_ID = 
					(SELECT TOP 1 BB_AllowanceCode_Allocation_Summary_ID FROM BB_AllowanceCode_Allocation_Summary 
					WHERE BB_AllowanceCode_Allocation_Summary.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND 
					AllowanceCode_level_Sum = 1 AND Allocated_Amount <> 0 AND BB_AllowanceCode_Allocation_Summary.Deleted = 0 )
				</CFQUERY>
			</CFIF>
		</cfif>
	</cffunction>
		
	<cffunction name="AllocateTaxAmount" output="false" returntype="void">	
		<cfargument name="billbackID" type="string" required="true" />
		<CFQUERY NAME="TaxAllocation" DATASOURCE="#Application.Datasource#">
			UPDATE BB_AllowanceCode_Allocation_Summary
			SET
			Tax_Code_1_Amount = (BB_Tax_Info.Tax_Code_1_Domestic_Amount * Allocated_Amount)/Paid_Amount,
			Tax_Code_1_Taxable_Amount = (BB_Tax_Info.Tax_Code_1_Domestic_Taxable_Amount * Allocated_Amount)/Paid_Amount,
			Tax_Code_2_Amount = (BB_Tax_Info.Tax_Code_2_Domestic_Amount * Allocated_Amount)/Paid_Amount,
			Tax_Code_2_Taxable_Amount = (BB_Tax_Info.Tax_Code_2_Domestic_Taxable_Amount * Allocated_Amount)/Paid_Amount,
			Tax_Code_3_Amount = (BB_Tax_Info.Tax_Code_3_Domestic_Amount * Allocated_Amount)/Paid_Amount,
			Tax_Code_3_Taxable_Amount = (BB_Tax_Info.Tax_Code_3_Domestic_Taxable_Amount * Allocated_Amount)/Paid_Amount
			
			FROM BB_AllowanceCode_Allocation_Summary BAAS
			INNER JOIN BB_Tax_Info ON BB_Tax_Info.Billback_ID = BAAS.Billback_ID AND BB_Tax_Info.Deleted = 0
			INNER JOIN BB_Approved ON BB_Approved.Billback_ID = BAAS.Billback_ID 
			WHERE BAAS.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND AllowanceCode_level_Sum = 1 AND BAAS.Deleted = 0	
		</CFQUERY>
		<CFQUERY NAME="RoundTax_Code_1_Amount" DATASOURCE="#Application.Datasource#">
			UPDATE BB_AllowanceCode_Allocation_Summary 
			SET Tax_Code_1_Amount = 
			(Tax_Code_1_Amount + (Tax_Code_1_Domestic_Amount - (SELECT SUM(Tax_Code_1_Amount) FROM BB_AllowanceCode_Allocation_Summary BAAS1  
			WHERE BAAS1.Billback_ID = BAAS.Billback_ID AND BAAS1.AllowanceCode_level_Sum = BAAS.AllowanceCode_level_Sum AND BAAS1.Deleted = 0
			)))
			FROM BB_AllowanceCode_Allocation_Summary BAAS 
			INNER JOIN BB_Tax_Info ON BB_Tax_Info.Billback_ID = BAAS.Billback_ID AND BB_Tax_Info.Deleted = 0
			WHERE BAAS.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND AllowanceCode_level_Sum = 1 AND BAAS.Deleted = 0
			AND BAAS.BB_AllowanceCode_Allocation_Summary_ID = (SELECT TOP 1 BB_AllowanceCode_Allocation_Summary_ID FROM BB_AllowanceCode_Allocation_Summary BAAS2
			WHERE BAAS2.Billback_ID = BAAS.Billback_ID AND BAAS2.AllowanceCode_level_Sum = BAAS.AllowanceCode_level_Sum AND BAAS2.Deleted = 0 AND
			Tax_Code_1_Amount = (SELECT MAX(Tax_Code_1_Amount) FROM BB_AllowanceCode_Allocation_Summary BAAS3
			WHERE BAAS3.Billback_ID = BAAS2.Billback_ID AND BAAS3.AllowanceCode_level_Sum = BAAS2.AllowanceCode_level_Sum AND BAAS3.Deleted = 0)
			)
		</CFQUERY>
		<CFQUERY NAME="RoundTax_Code_1_Taxable_Amount" DATASOURCE="#Application.Datasource#">
			UPDATE BB_AllowanceCode_Allocation_Summary 
			SET Tax_Code_1_Taxable_Amount = 
			(Tax_Code_1_Taxable_Amount + (Tax_Code_1_Domestic_Taxable_Amount - (SELECT SUM(Tax_Code_1_Taxable_Amount) FROM BB_AllowanceCode_Allocation_Summary BAAS1  
			WHERE BAAS1.Billback_ID = BAAS.Billback_ID AND BAAS1.AllowanceCode_level_Sum = BAAS.AllowanceCode_level_Sum AND BAAS1.Deleted = 0
			)))
			FROM BB_AllowanceCode_Allocation_Summary BAAS 
			INNER JOIN BB_Tax_Info ON BB_Tax_Info.Billback_ID = BAAS.Billback_ID AND BB_Tax_Info.Deleted = 0
			WHERE BAAS.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND AllowanceCode_level_Sum = 1 AND BAAS.Deleted = 0
			AND BAAS.BB_AllowanceCode_Allocation_Summary_ID = (SELECT TOP 1 BB_AllowanceCode_Allocation_Summary_ID FROM BB_AllowanceCode_Allocation_Summary BAAS2
			WHERE BAAS2.Billback_ID = BAAS.Billback_ID AND BAAS2.AllowanceCode_level_Sum = BAAS.AllowanceCode_level_Sum AND BAAS2.Deleted = 0 AND
			Tax_Code_1_Taxable_Amount = (SELECT MAX(Tax_Code_1_Taxable_Amount) FROM BB_AllowanceCode_Allocation_Summary BAAS3
			WHERE BAAS3.Billback_ID = BAAS2.Billback_ID AND BAAS3.AllowanceCode_level_Sum = BAAS2.AllowanceCode_level_Sum AND BAAS3.Deleted = 0)
			)
		</CFQUERY>
		
		<CFQUERY NAME="RoundTax_Code_2_Amount" DATASOURCE="#Application.Datasource#">
			UPDATE BB_AllowanceCode_Allocation_Summary 
			SET Tax_Code_2_Amount = 
			(Tax_Code_2_Amount + (Tax_Code_2_Domestic_Amount - (SELECT SUM(Tax_Code_2_Amount) FROM BB_AllowanceCode_Allocation_Summary BAAS1  
			WHERE BAAS1.Billback_ID = BAAS.Billback_ID AND BAAS1.AllowanceCode_level_Sum = BAAS.AllowanceCode_level_Sum AND BAAS1.Deleted = 0
			)))
			FROM BB_AllowanceCode_Allocation_Summary BAAS 
			INNER JOIN BB_Tax_Info ON BB_Tax_Info.Billback_ID = BAAS.Billback_ID AND BB_Tax_Info.Deleted = 0
			WHERE BAAS.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND AllowanceCode_level_Sum = 1 AND BAAS.Deleted = 0
			AND BAAS.BB_AllowanceCode_Allocation_Summary_ID = (SELECT TOP 1 BB_AllowanceCode_Allocation_Summary_ID FROM BB_AllowanceCode_Allocation_Summary BAAS2
			WHERE BAAS2.Billback_ID = BAAS.Billback_ID AND BAAS2.AllowanceCode_level_Sum = BAAS.AllowanceCode_level_Sum AND BAAS2.Deleted = 0 AND
			Tax_Code_2_Amount = (SELECT MAX(Tax_Code_2_Amount) FROM BB_AllowanceCode_Allocation_Summary BAAS3
			WHERE BAAS3.Billback_ID = BAAS2.Billback_ID AND BAAS3.AllowanceCode_level_Sum = BAAS2.AllowanceCode_level_Sum AND BAAS3.Deleted = 0)
			)
		</CFQUERY>
		
		<CFQUERY NAME="RoundTax_Code_2_Taxable_Amount" DATASOURCE="#Application.Datasource#">
			UPDATE BB_AllowanceCode_Allocation_Summary 
			SET Tax_Code_2_Taxable_Amount = 
			(Tax_Code_2_Taxable_Amount + (Tax_Code_2_Domestic_Taxable_Amount - (SELECT SUM(Tax_Code_2_Taxable_Amount) FROM BB_AllowanceCode_Allocation_Summary BAAS1  
			WHERE BAAS1.Billback_ID = BAAS.Billback_ID AND BAAS1.AllowanceCode_level_Sum = BAAS.AllowanceCode_level_Sum AND BAAS1.Deleted = 0
			)))
			FROM BB_AllowanceCode_Allocation_Summary BAAS 
			INNER JOIN BB_Tax_Info ON BB_Tax_Info.Billback_ID = BAAS.Billback_ID AND BB_Tax_Info.Deleted = 0
			WHERE BAAS.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND AllowanceCode_level_Sum = 1 AND BAAS.Deleted = 0
			AND BAAS.BB_AllowanceCode_Allocation_Summary_ID = (SELECT TOP 1 BB_AllowanceCode_Allocation_Summary_ID FROM BB_AllowanceCode_Allocation_Summary BAAS2
			WHERE BAAS2.Billback_ID = BAAS.Billback_ID AND BAAS2.AllowanceCode_level_Sum = BAAS.AllowanceCode_level_Sum AND BAAS2.Deleted = 0 AND
			Tax_Code_2_Taxable_Amount = (SELECT MAX(Tax_Code_2_Taxable_Amount) FROM BB_AllowanceCode_Allocation_Summary BAAS3
			WHERE BAAS3.Billback_ID = BAAS2.Billback_ID AND BAAS3.AllowanceCode_level_Sum = BAAS2.AllowanceCode_level_Sum AND BAAS3.Deleted = 0)
			)
		</CFQUERY>
		
		<CFQUERY NAME="RoundTax_Code_3_Amount" DATASOURCE="#Application.Datasource#">
			UPDATE BB_AllowanceCode_Allocation_Summary 
			SET Tax_Code_3_Amount = 
			(Tax_Code_3_Amount + (Tax_Code_3_Domestic_Amount - (SELECT SUM(Tax_Code_3_Amount) FROM BB_AllowanceCode_Allocation_Summary BAAS1  
			WHERE BAAS1.Billback_ID = BAAS.Billback_ID AND BAAS1.AllowanceCode_level_Sum = BAAS.AllowanceCode_level_Sum AND BAAS1.Deleted = 0
			)))
			FROM BB_AllowanceCode_Allocation_Summary BAAS 
			INNER JOIN BB_Tax_Info ON BB_Tax_Info.Billback_ID = BAAS.Billback_ID AND BB_Tax_Info.Deleted = 0
			WHERE BAAS.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND AllowanceCode_level_Sum = 1 AND BAAS.Deleted = 0
			AND BAAS.BB_AllowanceCode_Allocation_Summary_ID = (SELECT TOP 1 BB_AllowanceCode_Allocation_Summary_ID FROM BB_AllowanceCode_Allocation_Summary BAAS2
			WHERE BAAS2.Billback_ID = BAAS.Billback_ID AND BAAS2.AllowanceCode_level_Sum = BAAS.AllowanceCode_level_Sum AND BAAS2.Deleted = 0 AND
			Tax_Code_3_Amount = (SELECT MAX(Tax_Code_3_Amount) FROM BB_AllowanceCode_Allocation_Summary BAAS3
			WHERE BAAS3.Billback_ID = BAAS2.Billback_ID AND BAAS3.AllowanceCode_level_Sum = BAAS2.AllowanceCode_level_Sum AND BAAS3.Deleted = 0)
			)
		</CFQUERY>
		
		<CFQUERY NAME="RoundTax_Code_3_Taxable_Amount" DATASOURCE="#Application.Datasource#">			
			UPDATE BB_AllowanceCode_Allocation_Summary 
			SET Tax_Code_3_Taxable_Amount = 
			(Tax_Code_3_Taxable_Amount + (Tax_Code_3_Domestic_Taxable_Amount - (SELECT SUM(Tax_Code_3_Taxable_Amount) FROM BB_AllowanceCode_Allocation_Summary BAAS1  
			WHERE BAAS1.Billback_ID = BAAS.Billback_ID AND BAAS1.AllowanceCode_level_Sum = BAAS.AllowanceCode_level_Sum AND BAAS1.Deleted = 0
			)))
			FROM BB_AllowanceCode_Allocation_Summary BAAS 
			INNER JOIN BB_Tax_Info ON BB_Tax_Info.Billback_ID = BAAS.Billback_ID AND BB_Tax_Info.Deleted = 0
			WHERE BAAS.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND AllowanceCode_level_Sum = 1 AND BAAS.Deleted = 0
			AND BAAS.BB_AllowanceCode_Allocation_Summary_ID = (SELECT TOP 1 BB_AllowanceCode_Allocation_Summary_ID FROM BB_AllowanceCode_Allocation_Summary BAAS2
			WHERE BAAS2.Billback_ID = BAAS.Billback_ID AND BAAS2.AllowanceCode_level_Sum = BAAS.AllowanceCode_level_Sum AND BAAS2.Deleted = 0 AND
			Tax_Code_3_Taxable_Amount = (SELECT MAX(Tax_Code_3_Taxable_Amount) FROM BB_AllowanceCode_Allocation_Summary BAAS3
			WHERE BAAS3.Billback_ID = BAAS2.Billback_ID AND BAAS3.AllowanceCode_level_Sum = BAAS2.AllowanceCode_level_Sum AND BAAS3.Deleted = 0)
			)
		</CFQUERY>
	</cffunction>
	
	<cffunction name="AllocateBidAmount" output="false" returntype="void">	
		<cfargument name="billbackID" type="string" required="true" />
		<CFQUERY NAME="InsBid" DATASOURCE="#Application.Datasource#">
			EXEC BB_BID_ALLOWANCECODE_ALLOCATION <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR">
		</CFQUERY>
		<CFQUERY NAME="UpdComponents_Rate_Sum" DATASOURCE="#Application.Datasource#">
			--- Ana - D15502 - below temp table is for handling Multi distributors with same product
			IF OBJECT_ID('tempdb..##Temp_Program_Rate') IS NOT NULL
						DROP TABLE ##Temp_Program_Rate
			
			SELECT 	DISTINCT Billback_ID,Product_Type_ID,Product_ID,Program_Bidrequest_Component_ID,Program_Rate
			INTO	##Temp_Program_Rate
			FROM 	BB_AllowanceCode_Allocation 
			WHERE 	Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND 
					Product_Type_ID = 11 AND
					Deleted = 0
		
			UPDATE 	BB_AllowanceCode_Allocation
			SET 	Components_Rate_Sum = (	SELECT SUM(Program_Rate) FROM  ##Temp_Program_Rate BAA1 
											WHERE BAA1.Product_ID = BAA.Product_ID AND BAA1.Product_Type_ID = BAA.Product_Type_ID AND 
											BAA1.Billback_ID = BAA.Billback_ID AND Deleted = 0)
			FROM 	BB_AllowanceCode_Allocation BAA 
			WHERE 	BAA.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND 
					BAA.Product_Type_ID = 11 AND BAA.Deleted = 0 
		</CFQUERY>
		<CFQUERY NAME="UpdAllocated_Amount_ProdLevel" DATASOURCE="#Application.Datasource#">
			UPDATE 	BB_AllowanceCode_Allocation
			SET 	Allocated_Amount_ProdLevel = 
					CASE 
					WHEN Components_Rate_Sum = 0 THEN
						BB_Paid_Amt / (SELECT COUNT(*) FROM  BB_AllowanceCode_Allocation BAA1 
						WHERE BAA1.Product_ID = BAA.Product_ID AND BAA1.Product_Type_ID = BAA.Product_Type_ID AND 
						BAA1.Billback_ID = BAA.Billback_ID AND Deleted = 0)					
					ELSE
						(BB_Paid_Amt * Program_Rate) / Components_Rate_Sum 
					END 
			
			FROM 	BB_AllowanceCode_Allocation BAA WHERE BAA.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND 
					BAA.Product_Type_ID = 11 AND BAA.Deleted = 0
		</CFQUERY>
		
		<CFQUERY NAME="HandleRounding" DATASOURCE="#Application.Datasource#">
			UPDATE 	BB_AllowanceCode_Allocation 
			SET		Allocated_Amount_ProdLevel = (Allocated_Amount_ProdLevel + 
					(BAA.BB_Paid_Amt - (SELECT SUM(ISNULL(Allocated_Amount_ProdLevel,0)) FROM BB_AllowanceCode_Allocation BAA1
					WHERE BAA1.Billback_ID = BAA.Billback_ID AND BAA1.BB_Item_Final_Detail_ID = BAA.BB_Item_Final_Detail_ID AND BAA1.Product_Type_ID = BAA.Product_Type_ID AND BAA1.Deleted = 0)))			
					
			FROM 	BB_AllowanceCode_Allocation BAA
			WHERE 	BAA.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND 
					BAA.Product_Type_ID = 11 AND BAA.Deleted = 0 AND
					BAA.BB_AllowanceCode_Allocation_ID = (SELECT TOP 1 BAA3.BB_AllowanceCode_Allocation_ID FROM BB_AllowanceCode_Allocation BAA3
					WHERE BAA3.Billback_ID = BAA.Billback_ID AND BAA3.BB_Item_Final_Detail_ID = BAA.BB_Item_Final_Detail_ID AND BAA3.Product_Type_ID = BAA.Product_Type_ID AND
					BAA3.Allocated_Amount_ProdLevel = (SELECT Max(BAA4.Allocated_Amount_ProdLevel) FROM BB_AllowanceCode_Allocation BAA4
					WHERE BAA4.Billback_ID = BAA3.Billback_ID AND BAA4.BB_Item_Final_Detail_ID = BAA3.BB_Item_Final_Detail_ID AND BAA4.Product_Type_ID = BAA3.Product_Type_ID AND BAA4.Deleted = 0) AND
					BAA3.Deleted = 0)				
		</CFQUERY>
		
		<CFQUERY NAME="InsAllocationSummary" DATASOURCE="#Application.Datasource#">
			INSERT INTO BB_AllowanceCode_Allocation_Summary 
			(Billback_ID,Program_ID,Product_Type_ID,Component_Int_ID,Allowance_Code_ID,Allocated_Amount)
			
			SELECT 		Billback_ID,Program_ID,Product_Type_ID,Program_BidRequest_Component_Name_ID,Allowance_Code_ID,
						SUM(Allocated_Amount_ProdLevel)
			FROM 		BB_AllowanceCode_Allocation BAA WHERE Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND 
						Product_Type_ID = 11 AND Deleted = 0
			GROUP BY 	Billback_ID,Program_ID,Product_Type_ID,Program_BidRequest_Component_Name_ID,Allowance_Code_ID
			ORDER BY 	Billback_ID,Program_ID,Product_Type_ID,Program_BidRequest_Component_Name_ID,Allowance_Code_ID
		</CFQUERY>
	</cffunction>
	
	
	<cffunction name="AllocateFixedPriceAmount" output="false" returntype="void">	
		<cfargument name="billbackID" type="string" required="true" />
		
		<CFQUERY NAME="InsFixed" DATASOURCE="#Application.Datasource#">
			EXEC BB_FIXED_ALLOWANCECODE_ALLOCATION <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR">
		</CFQUERY>
		<CFQUERY NAME="UpdComponents_Rate_Sum" DATASOURCE="#Application.Datasource#">
			--- Ana - D15502 - below temp table is for handling Multi distributors with same product
			IF OBJECT_ID('tempdb..##Temp_Program_Rate') IS NOT NULL
						DROP TABLE ##Temp_Program_Rate
			
			SELECT 	DISTINCT Billback_ID,Product_Type_ID,Product_ID,Program_Fixed_Component_ID,Program_Rate
			INTO	##Temp_Program_Rate
			FROM 	BB_AllowanceCode_Allocation 
			WHERE 	Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND 
					Product_Type_ID = 1 AND
					Deleted = 0
		
			UPDATE 	BB_AllowanceCode_Allocation
			SET 	Components_Rate_Sum = (	SELECT SUM(Program_Rate) FROM  ##Temp_Program_Rate BAA1 
											WHERE BAA1.Product_ID = BAA.Product_ID AND BAA1.Product_Type_ID = BAA.Product_Type_ID AND 
											BAA1.Billback_ID = BAA.Billback_ID AND Deleted = 0)
			FROM 	BB_AllowanceCode_Allocation BAA 
			WHERE 	BAA.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND 
					BAA.Product_Type_ID = 1 AND BAA.Deleted = 0 
		</CFQUERY>
		<CFQUERY NAME="UpdAllocated_Amount_ProdLevel" DATASOURCE="#Application.Datasource#">
			UPDATE 	BB_AllowanceCode_Allocation
			SET 	Allocated_Amount_ProdLevel = 
					CASE 
					WHEN Components_Rate_Sum = 0 THEN
						BB_Paid_Amt / (SELECT COUNT(*) FROM  BB_AllowanceCode_Allocation BAA1 
						WHERE BAA1.Product_ID = BAA.Product_ID AND BAA1.Product_Type_ID = BAA.Product_Type_ID AND 
						BAA1.Billback_ID = BAA.Billback_ID AND Deleted = 0)					
					ELSE
						(BB_Paid_Amt * Program_Rate) / Components_Rate_Sum 
					END 
			
			FROM 	BB_AllowanceCode_Allocation BAA WHERE BAA.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND 
					BAA.Product_Type_ID = 1 AND BAA.Deleted = 0
		</CFQUERY>
		
		<CFQUERY NAME="HandleRounding" DATASOURCE="#Application.Datasource#">
			UPDATE 	BB_AllowanceCode_Allocation 
			SET		Allocated_Amount_ProdLevel = (Allocated_Amount_ProdLevel + 
					(BAA.BB_Paid_Amt - (SELECT SUM(ISNULL(Allocated_Amount_ProdLevel,0)) FROM BB_AllowanceCode_Allocation BAA1
					WHERE BAA1.Billback_ID = BAA.Billback_ID AND BAA1.BB_Item_Final_Detail_ID = BAA.BB_Item_Final_Detail_ID AND BAA1.Product_Type_ID = BAA.Product_Type_ID AND BAA1.Deleted = 0)))			
					
			FROM 	BB_AllowanceCode_Allocation BAA
			WHERE 	BAA.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND 
					BAA.Product_Type_ID = 1 AND BAA.Deleted = 0 AND
					BAA.BB_AllowanceCode_Allocation_ID = (SELECT TOP 1 BAA3.BB_AllowanceCode_Allocation_ID FROM BB_AllowanceCode_Allocation BAA3
					WHERE BAA3.Billback_ID = BAA.Billback_ID AND BAA3.BB_Item_Final_Detail_ID = BAA.BB_Item_Final_Detail_ID AND BAA3.Product_Type_ID = BAA.Product_Type_ID AND
					BAA3.Allocated_Amount_ProdLevel = (SELECT Max(BAA4.Allocated_Amount_ProdLevel) FROM BB_AllowanceCode_Allocation BAA4
					WHERE BAA4.Billback_ID = BAA3.Billback_ID AND BAA4.BB_Item_Final_Detail_ID = BAA3.BB_Item_Final_Detail_ID AND BAA4.Product_Type_ID = BAA3.Product_Type_ID AND BAA4.Deleted = 0) AND
					BAA3.Deleted = 0)				
		</CFQUERY>
		
		<CFQUERY NAME="InsAllocationSummary" DATASOURCE="#Application.Datasource#">
			INSERT INTO BB_AllowanceCode_Allocation_Summary 
			(Billback_ID,Program_ID,Product_Type_ID,Component_Int_ID,Allowance_Code_ID,Allocated_Amount)
			
			SELECT 		Billback_ID,Program_ID,Product_Type_ID,Program_Fixed_Component_Name_ID,Allowance_Code_ID,
						SUM(Allocated_Amount_ProdLevel)
			FROM 		BB_AllowanceCode_Allocation BAA WHERE Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND 
						Product_Type_ID = 1 AND Deleted = 0
			GROUP BY 	Billback_ID,Program_ID,Product_Type_ID,Program_Fixed_Component_Name_ID,Allowance_Code_ID
			ORDER BY 	Billback_ID,Program_ID,Product_Type_ID,Program_Fixed_Component_Name_ID,Allowance_Code_ID
		</CFQUERY>
	</cffunction>
	
	<cffunction name="allocateRebateAmount" output="true" returntype="void">	
		<cfargument name="billbackID" type="string" required="true" />
				
		<CFQUERY NAME="RebProdLevelAllocation" DATASOURCE="#Application.Datasource#">
			EXEC BB_REBATE_ALLOWANCECODE_ALLOCATION <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR">
		</CFQUERY>		
		
		<CFQUERY NAME="UpdComponents_Rate_Sum" DATASOURCE="#Application.Datasource#">
			--- Ana - D15502 - below temp table is for handling Multi distributors with same product
			IF OBJECT_ID('tempdb..##Temp_Program_Rate') IS NOT NULL
						DROP TABLE ##Temp_Program_Rate
			
			SELECT 	DISTINCT Billback_ID,Product_Type_ID,Product_ID,Program_Rebates_Component_ID,Program_Rate
			INTO	##Temp_Program_Rate
			FROM 	BB_AllowanceCode_Allocation 
			WHERE 	Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND 
					Product_Type_ID = 2 AND
					Deleted = 0
		
			UPDATE 	BB_AllowanceCode_Allocation
			SET 	Components_Rate_Sum = (	SELECT SUM(Program_Rate) FROM  ##Temp_Program_Rate BAA1 
											WHERE BAA1.Product_ID = BAA.Product_ID AND BAA1.Product_Type_ID = BAA.Product_Type_ID AND 
											BAA1.Billback_ID = BAA.Billback_ID AND Deleted = 0)
			FROM 	BB_AllowanceCode_Allocation BAA 
			WHERE 	BAA.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND 
					BAA.Product_Type_ID = 2 AND BAA.Deleted = 0 
		</CFQUERY>
		<CFQUERY NAME="UpdAllocated_Amount_ProdLevel" DATASOURCE="#Application.Datasource#">
			UPDATE 	BB_AllowanceCode_Allocation
			SET 	Allocated_Amount_ProdLevel = 
					CASE 
					WHEN Components_Rate_Sum = 0 THEN
						BB_Paid_Amt / (SELECT COUNT(*) FROM  BB_AllowanceCode_Allocation BAA1 
						WHERE BAA1.Product_ID = BAA.Product_ID AND BAA1.Product_Type_ID = BAA.Product_Type_ID AND 
						BAA1.Billback_ID = BAA.Billback_ID AND Deleted = 0)					
					ELSE
						(BB_Paid_Amt * Program_Rate) / Components_Rate_Sum 
					END 
			
			FROM 	BB_AllowanceCode_Allocation BAA WHERE BAA.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND 
					BAA.Product_Type_ID = 2 AND BAA.Deleted = 0
		</CFQUERY>
		
		<CFQUERY NAME="HandleRounding" DATASOURCE="#Application.Datasource#">
			UPDATE 	BB_AllowanceCode_Allocation 
			SET		Allocated_Amount_ProdLevel = (Allocated_Amount_ProdLevel + 
					(BAA.BB_Paid_Amt - (SELECT SUM(ISNULL(Allocated_Amount_ProdLevel,0)) FROM BB_AllowanceCode_Allocation BAA1
					WHERE BAA1.Billback_ID = BAA.Billback_ID AND BAA1.BB_Item_Final_Detail_ID = BAA.BB_Item_Final_Detail_ID AND BAA1.Product_Type_ID = BAA.Product_Type_ID AND BAA1.Deleted = 0)))			
					
			FROM 	BB_AllowanceCode_Allocation BAA
			WHERE 	BAA.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND 
					BAA.Product_Type_ID = 2 AND BAA.Deleted = 0 AND
					BAA.BB_AllowanceCode_Allocation_ID = (SELECT TOP 1 BAA3.BB_AllowanceCode_Allocation_ID FROM BB_AllowanceCode_Allocation BAA3
					WHERE BAA3.Billback_ID = BAA.Billback_ID AND BAA3.BB_Item_Final_Detail_ID = BAA.BB_Item_Final_Detail_ID AND BAA3.Product_Type_ID = BAA.Product_Type_ID AND
					BAA3.Allocated_Amount_ProdLevel = (SELECT Max(BAA4.Allocated_Amount_ProdLevel) FROM BB_AllowanceCode_Allocation BAA4
					WHERE BAA4.Billback_ID = BAA3.Billback_ID AND BAA4.BB_Item_Final_Detail_ID = BAA3.BB_Item_Final_Detail_ID AND BAA4.Product_Type_ID = BAA3.Product_Type_ID AND BAA4.Deleted = 0) AND
					BAA3.Deleted = 0)				
		</CFQUERY>
		
		<CFQUERY NAME="InsAllocationSummary" DATASOURCE="#Application.Datasource#">
			INSERT INTO BB_AllowanceCode_Allocation_Summary 
			(Billback_ID,Program_ID,Product_Type_ID,Component_Int_ID,Allowance_Code_ID,Allocated_Amount)
			
			SELECT 		Billback_ID,Program_ID,Product_Type_ID,Program_Rebates_Component_Name_ID,Allowance_Code_ID,
						SUM(Allocated_Amount_ProdLevel)
			FROM 		BB_AllowanceCode_Allocation BAA WHERE Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND 
						Product_Type_ID = 2 AND Deleted = 0
			GROUP BY 	Billback_ID,Program_ID,Product_Type_ID,Program_Rebates_Component_Name_ID,Allowance_Code_ID
			ORDER BY 	Billback_ID,Program_ID,Product_Type_ID,Program_Rebates_Component_Name_ID,Allowance_Code_ID
		</CFQUERY>
		
	</cffunction>
	
	<cffunction name="allocateLumpSumAmount" output="false" returntype="void">	
		<cfargument name="billbackID" type="string" required="true" />
				
		<CFQUERY NAME="InsAllocationData" DATASOURCE="#Application.Datasource#">
			INSERT INTO BB_AllowanceCode_Allocation (Billback_ID,
						Program_ID,Product_Type_ID,Program_Lump_Sum_ID,
						Allowance_Code_ID,BB_Paid_Amt,Program_Rate)
			SELECT 		BPLC.Billback_ID,Billback_Program.Program_ID,3,BPLC.Program_Lump_Sum_ID,
						Allowance_Code_ID,LS_Paid_Amount,Lump_Sum_Amount
			FROM 		Billback_Program_Lumpsum_Component BPLC
			INNER JOIN 	Billback_Program ON Billback_Program.Billback_Program_ID = BPLC.Billback_Program_ID
			INNER JOIN 	BB_Lump_Sums ON BB_Lump_Sums.Billback_ID = BPLC.Billback_ID AND BB_Lump_Sums.Deleted = 0
			INNER JOIN 	Program_Lump_Sums ON Program_Lump_Sums.Program_Lump_Sum_ID = BPLC.Program_Lump_Sum_ID AND Program_Lump_Sums.Deleted = 0
			INNER JOIN 	Program_Lump_Sum_Name ON Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID AND
						Program_Lump_Sum_Name.Deleted = 0
			WHERE BPLC.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND BPLC.Component_Type_ID = 1 AND BPLC.Deleted = 0
		</CFQUERY>
		
		<CFQUERY NAME="UPDCompRateSum" DATASOURCE="#Application.Datasource#">
			UPDATE 	BB_AllowanceCode_Allocation 
			SET 	Components_Rate_Sum = 
					(SELECT SUM(Program_Rate) FROM  BB_AllowanceCode_Allocation BAA1 
					WHERE BAA1.Product_Type_ID = BAA.Product_Type_ID AND 
					BAA1.Billback_ID = BAA.Billback_ID AND Deleted = 0)
		 	FROM 	BB_AllowanceCode_Allocation BAA WHERE BAA.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND BAA.Product_Type_ID = 3 AND BAA.Deleted = 0
		</CFQUERY>
		
		<CFQUERY NAME="ISBBAmountApproved" DATASOURCE="#Application.Datasource#">
			SELECT Top 1 LS_Paid_Amount,LS_Billback_Amount FROM BB_Lump_Sums WHERE Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND Deleted = 0
		</CFQUERY>
		
		<CFIF ISBBAmountApproved.LS_Paid_Amount NEQ ISBBAmountApproved.LS_Billback_Amount>
			<CFQUERY NAME="UPDAlloAmt" DATASOURCE="#Application.Datasource#">
				UPDATE 	BB_AllowanceCode_Allocation 
				SET 	Allocated_Amount_CompLevel = 
						(BB_Paid_Amt * Program_Rate) / Components_Rate_Sum 
				WHERE 	Program_Rate IS NOT NULL AND Program_Rate <> 0 AND 
				Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND Product_Type_ID = 3 AND Deleted = 0
			</CFQUERY>
		<CFELSE>
			<CFQUERY NAME="UPDAlloAmt" DATASOURCE="#Application.Datasource#">
				UPDATE 	BB_AllowanceCode_Allocation
				SET 	Allocated_Amount_CompLevel = Amount
				FROM 	BB_AllowanceCode_Allocation
				INNER JOIN 	Billback_Program_Lumpsum_Component BPLC ON BPLC.Billback_ID = BB_AllowanceCode_Allocation.Billback_ID AND 
							BPLC.Program_Lump_Sum_ID = BB_AllowanceCode_Allocation.Program_Lump_Sum_ID AND BPLC.Deleted = 0
				WHERE 	BB_AllowanceCode_Allocation.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND Product_Type_ID = 3 AND BB_AllowanceCode_Allocation.Deleted = 0
			</CFQUERY>
		</CFIF>
		
		<CFQUERY NAME="HandleRounding" DATASOURCE="#Application.Datasource#">
			UPDATE 	BB_AllowanceCode_Allocation
			SET 	ALLOCATED_Amount_CompLevel = (ALLOCATED_Amount_CompLevel +
					(BAA.BB_Paid_Amt - (SELECT SUM(ALLOCATED_Amount_CompLevel) FROM BB_AllowanceCode_Allocation BAA1 
					WHERE BAA1.Billback_ID = BAA.Billback_ID AND 
					BAA1.Product_Type_ID = BAA.Product_Type_ID AND
					BAA1.Deleted = 0) ))
			FROM 	BB_AllowanceCode_Allocation BAA
			WHERE 	BAA.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND 
					BAA.Product_Type_ID = 3 AND BAA.Deleted = 0 AND
					BAA.BB_AllowanceCode_Allocation_ID =
					(SELECT TOP 1 BAA3.BB_AllowanceCode_Allocation_ID FROM BB_AllowanceCode_Allocation BAA3
					WHERE BAA3.Billback_ID = BAA.Billback_ID AND BAA3.Product_Type_ID = BAA.Product_Type_ID AND
					BAA3.Allocated_Amount_CompLevel = (SELECT Max(BAA4.Allocated_Amount_CompLevel) FROM BB_AllowanceCode_Allocation BAA4
					WHERE BAA4.Billback_ID = BAA3.Billback_ID AND BAA4.Product_Type_ID = BAA3.Product_Type_ID AND BAA4.Deleted = 0) AND
					BAA3.Deleted = 0)				
		</CFQUERY>
		
		<CFQUERY NAME="InsSummary" DATASOURCE="#Application.Datasource#">
			INSERT INTO BB_AllowanceCode_Allocation_Summary 
			(Billback_ID,Program_ID,Product_Type_ID,Component_GUID_ID,Allowance_Code_ID,Allocated_Amount)
			
			SELECT 		Billback_ID,Program_ID,Product_Type_ID,Program_Lump_Sum_ID,Allowance_Code_ID,
						Allocated_Amount_CompLevel
			FROM 		BB_AllowanceCode_Allocation WHERE Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND 
						Product_Type_ID = 3 AND Deleted = 0
		</CFQUERY>

	</cffunction>
	
	
	<cffunction name="AllocateGrowthAmount" output="false" returntype="void">	
		<cfargument name="billbackID" type="string" required="true" />
		<CFQUERY NAME="Get_Paid_Rate_per_Program" DATASOURCE="#Application.Datasource#">
			SELECT    	Paid_Amount,Program_ID			
			FROM       	BB_Growth_Program 			
			INNER JOIN 	Billback_Program ON Billback_Program.Billback_Program_ID = BB_Growth_Program.Billback_Program_ID AND
						Billback_Program.Deleted = 0												
			WHERE     	BB_Growth_Program.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND
						BB_Growth_Program.Deleted = 0					
		</CFQUERY>
		<CFLOOP QUERY="Get_Paid_Rate_per_Program">
			<CFIF Paid_Amount NEQ "" AND Paid_Amount NEQ 0>
				<CFSET Program_ID = Program_ID>		
				<CFSET Paid_Amount_For_This_Program = Paid_Amount>
				<CFSET Total_Component_Volume = 0>
						
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				<!--- Get the components and there volumn. Using the result find total --->	
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				<CFQUERY NAME="Get_Component_Volume" DATASOURCE="#Application.Datasource#">
					SELECT 		DISTINCT Program_Growth_Component_ID,
								TC_Volume_LB 					
					FROM 		BB_Growth_Final_RateCheck					
					WHERE 		Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR">
								<CFIF Program_ID NEQ "">
								AND Actual_Program_ID = <CFOUTPUT>#Program_ID#</CFOUTPUT>
								<CFELSE>
								AND Actual_Program_ID IS NULL
								</CFIF>
				</CFQUERY>
			
				<CFOUTPUT QUERY="Get_Component_Volume">			
					<CFSET Total_Component_Volume = Total_Component_Volume + TC_Volume_LB>			
				</CFOUTPUT>
			
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		
				<CFIF Get_Component_Volume.recordcount GT 0>
					<CFOUTPUT QUERY="Get_Component_Volume">								
					
					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
					<!--- If there is records(valid programs,valid growth component) --->
					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
					<CFQUERY NAME ="Get_Products" DATASOURCE="#Application.Datasource#">
						SELECT 		DISTINCT(BB_Growth_Final_RateCheck.Product_ID)
						FROM 		BB_Growth_Final_RateCheck											
						INNER JOIN 	BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = BB_Growth_Final_RateCheck.Product_ID AND
									BSA_Foodservice_Items_Master.Deleted = 0 							 			
						WHERE 		BB_Growth_Final_RateCheck.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND
									Program_Growth_Component_ID='#Program_Growth_Component_ID#' AND
									BB_Growth_Final_RateCheck.Deleted = 0
					</CFQUERY>
					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
					
					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
					<!--- Calculate the rate for each component and the for products in each components --->
					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
					<CFIF Total_Component_Volume GT 0>
						<CFSET Paid_Rate_per_Component = (Paid_Amount_For_This_Program / Total_Component_Volume)*TC_Volume_LB>
					<CFELSE>
						<CFSET Paid_Rate_per_Component = Paid_Amount_For_This_Program>
					</CFIF>
					
					<CFQUERY NAME="CompAlloCode" DATASOURCE="#Application.Datasource#">
						SELECT PGCN.Allowance_Code_ID
						FROM Program_Growth_Components PGC
						INNER JOIN Program_Growth_Components_Name PGCN ON PGCN.Program_Growth_Components_Name_ID = PGC.Program_Growth_Components_Name_ID
						WHERE PGC.Program_Growth_Component_ID = '#Program_Growth_Component_ID#' AND PGC.Program_ID = #Program_ID# AND PGC.Deleted = 0
					</CFQUERY>
					<cfset useLakebaseForInsGrowthData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_allowancecode_allocation")>
<cfif useLakebaseForInsGrowthData>
	<cftry>
		<cfset application.oLakebase.insertRow("bb_allowancecode_allocation", {
			"billback_id" = "#arguments.billbackID#",
			"program_id" = "#Program_ID#",
			"product_type_id" = "4",
			"program_growth_component_id" = "#Program_Growth_Component_ID#",
			"allowance_code_id" = "#CompAlloCode.Allowance_Code_ID#",
			"allocated_amount_complevel" = "#Paid_Rate_per_Component#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsGrowthData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsGrowthData>
<CFQUERY NAME="InsGrowthData" DATASOURCE="#Application.Datasource#">
						INSERT INTO 
						BB_AllowanceCode_Allocation 
								(Billback_ID,Program_ID,Product_Type_ID,Program_Growth_Component_ID,
								Allowance_Code_ID,Allocated_Amount_CompLevel)
						VALUES 	('#arguments.billbackID#',#Program_ID#,4,'#Program_Growth_Component_ID#',
								#CompAlloCode.Allowance_Code_ID#,'#Paid_Rate_per_Component#')
					</CFQUERY>
</cfif>	
					
					<CFQUERY NAME="InsSummary" DATASOURCE="#Application.Datasource#">
						INSERT INTO 
						BB_AllowanceCode_Allocation_Summary 
								(Billback_ID,Program_ID,Product_Type_ID,Component_GUID_ID,Allowance_Code_ID,Allocated_Amount)
						VALUES	('#arguments.billbackID#',#Program_ID#,4,'#Program_Growth_Component_ID#',
								#CompAlloCode.Allowance_Code_ID#,'#Paid_Rate_per_Component#')
					</CFQUERY>				
					</CFOUTPUT>						
				</CFIF>
			</CFIF>
		</CFLOOP>
	</cffunction>
	
</cfcomponent>
