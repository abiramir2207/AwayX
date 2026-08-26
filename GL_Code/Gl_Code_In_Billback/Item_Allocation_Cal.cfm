

<!--- 
<CFQUERY NAME="UpdateAllocation" DATASOURCE="#Application.Datasource#">
	UPDATE 	Billback_Program
	SET 	Allocation_Method = 1
	WHERE 	Program_ID IN (#Program_List#) AND 
			Billback_ID = '#Billback_ID#' AND 
			Deleted = 0
</CFQUERY>
 --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- To get Paid Amount for Fixed, Rebate and Formula --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFQUERY NAME="ItemAllocationAmount" DATASOURCE="#Application.Datasource#">
	SELECT 			CAST(
					<CFIF CheckIsChild.Auto_Billback EQ 1> <!--- We don't want to round the values if it is auto billback. auto billback does not go in 900/910 --->
						BB_Item_Final.Item_Volume_Paid_CS * 
						BB_Item_Final_Detail.Paid_Rate_CS 
					<CFELSE>
					CASE 
						WHEN Billback_Product.BB_Product_UOM <> 2 THEN
							CAST(BB_Item_Final.Item_Volume_Paid_CS as decimal(30, 10)) * 
							CAST(BB_Item_Final_Detail.Paid_Rate_CS as decimal(30, 10)) 
						ELSE
							CAST(BB_Item_Final.Item_Volume_Paid_LB as decimal(30, 10)) * 
							CAST(BB_Item_Final_Detail.Paid_Rate_LB as decimal(30, 10))
					END
					</CFIF> 
					as decimal(20, 2)) AS Amount, 
					BB_Product_Type,
					BB_Item_Final.Billback_Product_ID, 
					Billback_Product.Product_ID,
					Billback_Product.Billback_Product_ID,
					Billback_Program.Program_ID				
					
	FROM 			BB_Item_Final 
					
	INNER JOIN 		BB_Item_Final_Detail ON 
					BB_Item_Final.BB_Item_Final_ID = BB_Item_Final_Detail.BB_Item_Final_ID
	
	INNER JOIN 		Billback_Program  ON
					Billback_Program.Billback_ID = BB_Item_Final.Billback_ID AND
					Billback_Program.Billback_Program_ID = BB_Item_Final.Billback_Program_ID AND 
					Billback_Program.Deleted = 0
					
	INNER JOIN 		Billback_Product ON 
					BB_Item_Final.Billback_ID = Billback_Product.Billback_ID AND	
					BB_Item_Final.Billback_Product_ID = Billback_Product.Billback_Product_ID		
	
	INNER JOIN		BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = 	Billback_Product.Product_ID
								 	
	WHERE 			BB_Item_Final.Billback_ID = <CFIF CheckIsChild.BB_Is_Child EQ 1>'#CheckIsChild.BB_Parent_ID#'<CFELSE>'#Billback_ID#'</CFIF> AND
					Billback_Program.Billback_ID = <CFIF CheckIsChild.BB_Is_Child EQ 1>'#CheckIsChild.BB_Parent_ID#'<CFELSE>'#Billback_ID#'</CFIF> AND
					Billback_Program.Program_ID IN (#Program_List#) AND
					BB_Item_Final.Deleted=0
</CFQUERY>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->	



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- If there is any record insert it into GL_Code_Item_Allocation_Cal. If there is no matching GL_QBrand replace it with f/s natural.--->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFIF ItemAllocationAmount.recordcount GT 0>
	<CFOUTPUT QUERY="ItemAllocationAmount">						
		<cfif ItemAllocationAmount.Amount EQ "">
			<cfset Amt = 0.00 />
		<cfelse>
			<Cfset Amt = ItemAllocationAmount.Amount />
		</cfif>
		<cfset useLakebaseForInsert_QB_Calculated_Amount = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_item_allocation_cal")>
<cfif useLakebaseForInsert_QB_Calculated_Amount>
	<cftry>
		<cfset application.oLakebase.insertRow("gl_code_item_allocation_cal", {
			"billback_id" = "#Billback_ID#",
			"program_id" = "#ItemAllocationAmount.Program_ID#",
			"product_id" = "#ItemAllocationAmount.Product_ID#",
			"billback_product_id" = "#ItemAllocationAmount.Billback_Product_ID#",
			"approved_amount" = "#Amt#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsert_QB_Calculated_Amount = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsert_QB_Calculated_Amount>
<CFQUERY NAME="Insert_QB_Calculated_Amount" DATASOURCE="#Application.Datasource#">
			INSERT INTO 		GL_Code_Item_Allocation_Cal
								(	Billback_ID,
									Program_ID,									
									Product_ID,
									Billback_Product_ID,
									Approved_Amount							
								)																																											
			VALUES										
								(	'#Billback_ID#',
									#ItemAllocationAmount.Program_ID#,									
									'#ItemAllocationAmount.Product_ID#',
									'#ItemAllocationAmount.Billback_Product_ID#',
								 	#Amt# 
								)	
		</CFQUERY>
</cfif>			
	</CFOUTPUT>
</CFIF>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx Fixed, Rebate, Formula End xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get Rate for Growth products --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFQUERY NAME="Get_Paid_Rate_per_Program" DATASOURCE="#Application.Datasource#">
	SELECT    	Paid_Amount,Program_ID
	
	FROM       	BB_Growth_Program 
	
	INNER JOIN 	Billback_Program ON Billback_Program.Billback_Program_ID = BB_Growth_Program.Billback_Program_ID AND
				Billback_Program.Deleted = 0					
					
	WHERE     	BB_Growth_Program.Billback_ID = <CFIF CheckIsChild.BB_Is_Child EQ 1>'#CheckIsChild.BB_Parent_ID#'<CFELSE>'#Billback_ID#'</CFIF> AND
				BillBack_Program.Program_ID IN (#Program_List#) AND
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
			
			WHERE 		Billback_ID = <CFIF CheckIsChild.BB_Is_Child EQ 1>'#CheckIsChild.BB_Parent_ID#'<CFELSE>'#Billback_ID#'</CFIF>
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
			<!--- If there is records(valid programs,valid growth component),Get the Product,QBrand_ID and look for matching QBrand in GL_code --->
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			<CFQUERY NAME ="Get_Products" DATASOURCE="#Application.Datasource#">
				SELECT 		DISTINCT(BB_Growth_Final_RateCheck.Product_ID) <!--- Product_ID,
							Billback_Product.Billback_Product_ID --->
							
				FROM 		BB_Growth_Final_RateCheck
									
				INNER JOIN 	BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = BB_Growth_Final_RateCheck.Product_ID AND
							BSA_Foodservice_Items_Master.Deleted = 0 							 			
							
				<!--- 
				INNER JOIN 	Billback_Product ON Billback_Product.Product_ID = BB_Growth_Final_RateCheck.Product_ID AND 
							Billback_Product.Billback_ID = '#Billback_ID#' AND 
							Billback_Program_ID = ( SELECT 	Billback_Program_ID 
													FROM 	Billback_Program 
													WHERE 	Billback_ID = '#Billback_ID#' AND
															Program_ID = '#Program_ID#' AND
															Deleted = 0	) AND
							Billback_Product.Deleted = 0 
				--->
				
				WHERE 		BB_Growth_Final_RateCheck.Billback_ID = <CFIF CheckIsChild.BB_Is_Child EQ 1>'#CheckIsChild.BB_Parent_ID#'<CFELSE>'#Billback_ID#'</CFIF> AND
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
			<CFSET Paid_Rate_Per_Product = Paid_Rate_per_Component/Get_Products.recordcount>				
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
						
			<CFLOOP QUERY="Get_Products">
				<cfset useLakebaseForInsert_Growth_Details = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_item_allocation_cal")>
<cfif useLakebaseForInsert_Growth_Details>
	<cftry>
		<cfset application.oLakebase.insertRow("gl_code_item_allocation_cal", {
			"billback_id" = "#Billback_ID#",
			"program_id" = "#Program_ID#",
			"product_id" = "#Product_ID#",
			"approved_amount" = "#Paid_Rate_Per_Product#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsert_Growth_Details = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsert_Growth_Details>
<CFQUERY NAME="Insert_Growth_Details" DATASOURCE="#Application.Datasource#">
					INSERT INTO 		GL_Code_Item_Allocation_Cal
										(	Billback_ID,
											Program_ID,									
											Product_ID,																					
											Approved_Amount														
										)																																											
					VALUES		
										(	'#Billback_ID#',	
											#Program_ID#,											
											'#Product_ID#',													
											'#Paid_Rate_Per_Product#'										
										)	
				</CFQUERY>
</cfif><!--- Billback_Product_ID,	 '#Billback_Product_ID#',--->
			</CFLOOP>
			</CFOUTPUT>		
		<CFELSE>
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			<!--- If there is no records its not a valid program or product. So just insert the F/S Natural value --->
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			
			<CFQUERY NAME="GetGrowthProduct" DATASOURCE="#Application.Datasource#">
				SELECT 		Billback_Product.Billback_Product_ID,
							Billback_Product.Product_ID,
							Billback_Product_Detail.BB_Rate 
				
				FROM 		Billback_Program
				INNER JOIN 	Billback_Product ON Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID AND
							Billback_Product.Deleted = 0
				INNER JOIN	Billback_Product_Detail ON Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID AND
							BB_Product_Type_ID = 4 AND
							BB_Rate IS NOT NULL AND
							LTRIM(RTRIM(BB_Rate)) <> '' AND
							Billback_Product_Detail.Deleted = 0
														
				WHERE 		Billback_Program.Billback_ID = <CFIF CheckIsChild.BB_Is_Child EQ 1>'#CheckIsChild.BB_Parent_ID#'<CFELSE>'#Billback_ID#'</CFIF> AND
							Billback_Program.Program_ID = '#Program_ID#' AND 
							Billback_Program.Deleted = 0
			</CFQUERY>
			
			<CFLOOP QUERY="GetGrowthProduct">
				<CFQUERY NAME="Insert_Growth_Details" DATASOURCE="#Application.Datasource#">
					INSERT INTO 		GL_Code_Item_Allocation_Cal
										(	Billback_ID,
											Program_ID,
											Product_ID,
											Billback_Product_ID,
											Approved_Amount
										)																																											
					VALUES		
										(	'#Billback_ID#',	
											#Program_ID#,
											'#Product_ID#',
											'#Billback_Product_ID#',
											#BB_Rate#												
										)	
				</CFQUERY>
			</CFLOOP>			
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->				
		</CFIF>
	</CFIF>
</CFLOOP>	

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxx Growth End xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



<!--- 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get Qbrnd and Rate for Lumpsum Products--->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFQUERY NAME="Get_Lumpsum_Program" DATASOURCE="#Application.Datasource#">
	SELECT 			LS_Paid_Amount,
					Billback_Program_ID,
					Program_ID
					
	FROM			BB_Lump_Sums 								
	
	WHERE			Billback_ID = <CFIF CheckIsChild.BB_Is_Child EQ 1>'#CheckIsChild.BB_Parent_ID#'<CFELSE>'#Billback_ID#'</CFIF> AND
					Program_ID IN (#Program_List#) AND
					BB_Lump_Sums.Deleted = 0
</CFQUERY>

<CFOUTPUT QUERY="Get_Lumpsum_Program">
	
	<CFIF LS_Paid_Amount NEQ "" AND LS_Paid_Amount NEQ 0>	
		<CFSET VarProgram_ID = Program_ID>
		<CFSET Amount_Paid_For_This_Program = LS_Paid_Amount>		

		<CFQUERY NAME="Get_Items_Climed_for_BB_Program" DATASOURCE="#Application.Datasource#">
			SELECT 			BB_Item_Final.Billback_Product_ID,
							Item_Volume_Paid_LB,
							Product_ID						
							
			FROM 			BB_Item_Final
			
			INNER JOIN 		Billback_Product ON Billback_Product.Billback_Product_ID = BB_Item_Final.Billback_Product_ID AND
							Billback_Product.Deleted = 0
			
			INNER JOIN 		BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Billback_Product.Product_ID AND
							BSA_Foodservice_Items_Master.Deleted = 0 
			
			WHERE 			BB_Item_Final.Billback_ID = <CFIF CheckIsChild.BB_Is_Child EQ 1>'#CheckIsChild.BB_Parent_ID#'<CFELSE>'#Billback_ID#'</CFIF> AND
							BB_Item_Final.Billback_Program_ID = '#Billback_Program_ID#' AND
							BB_Item_Final.Deleted = 0
		</CFQUERY>
	
		<CFIF Get_Items_Climed_for_BB_Program.recordcount GT 0>
	
			<CFSET Tot_Vol_Of_Items = 0>
			<CFLOOP QUERY="Get_Items_Climed_for_BB_Program">
				<CFSET Tot_Vol_Of_Items = Tot_Vol_Of_Items + Item_Volume_Paid_LB>
			</CFLOOP> 
			
			<CFLOOP QUERY="Get_Items_Climed_for_BB_Program">
				<CFIF Tot_Vol_Of_Items NEQ 0>
					<CFSET Paid_Rate_Per_Product = (Amount_Paid_For_This_Program / Tot_Vol_Of_Items) * Item_Volume_Paid_LB>
				<CFELSEIF RecordCount GT 0>
					<CFSET Paid_Rate_Per_Product = (Amount_Paid_For_This_Program / RecordCount)>
				<CFELSE>
					<CFSET Paid_Rate_Per_Product = Amount_Paid_For_This_Program >
				</CFIF>

				<CFQUERY NAME="Insert_Growth_Details" DATASOURCE="#Application.Datasource#">
					INSERT INTO 		GL_Code_Item_Allocation_Cal
										(	Billback_ID,
											Product_ID,
											Program_ID,
											Billback_Product_ID,									
											Approved_Amount													
										)																																											
					VALUES		
										(	'#Billback_ID#',
											'#Product_ID#',
											#VarProgram_ID#,
											'#Billback_Product_ID#',
											#Paid_Rate_Per_Product#
										)	
				</CFQUERY>
			
			</CFLOOP>		
		<CFELSE>				
			<CFQUERY NAME="Insert_Growth_Details" DATASOURCE="#Application.Datasource#">
				INSERT INTO 		GL_Code_Item_Allocation_Cal
									(	Billback_ID,																					
										Program_ID,
										Approved_Amount
									)																																											
				VALUES		
									(	'#Billback_ID#',	
										'#VarProgram_ID#',
										#Amount_Paid_For_This_Program#										
									)	
			</CFQUERY>
		</CFIF>
	</CFIF>
</CFOUTPUT>		
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxx Lumpsum End xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Claim Adjust --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFQUERY NAME="GetClaimAdjust" DATASOURCE="#Application.Datasource#">
	SELECT 		Billback_Program.Program_ID,
				Billback_Product.Product_ID,
				Billback_Product_Detail.BB_Rate

	FROM 		Billback_Product_Detail

	INNER JOIN 	Billback_Product ON Billback_Product.Billback_Product_ID = Billback_Product_Detail.Billback_Product_ID
	INNER JOIN 	Billback_Program ON Billback_Program.Billback_Program_ID = Billback_Product.Billback_Program_ID

	WHERE 		Billback_Product_Detail.Billback_ID = <CFIF CheckIsChild.BB_Is_Child EQ 1>'#CheckIsChild.BB_Parent_ID#'<CFELSE>'#Billback_ID#'</CFIF> AND	
				Program_ID IN (#Program_List#) AND
				CAST(BB_Rate AS Float) < 0 AND
				Billback_Product_Detail.Deleted = 0 AND
				Billback_Product.Deleted = 0 AND
				Billback_Program.Deleted = 0			
				AND Billback_Product_Detail.BB_Product_Type_ID = 10		
</CFQUERY>

<CFSET ClaimAdjustTot = 0>
<CFLOOP QUERY="GetClaimAdjust">
	<CFSET ClaimAdjustTot = ClaimAdjustTot + BB_Rate>
	<CFQUERY NAME="Insert_Growth_Details" DATASOURCE="#Application.Datasource#">
			INSERT INTO 		GL_Code_Item_Allocation_Cal
								(	Billback_ID,
									Program_ID,									
									Product_ID,																					
									Approved_Amount														
								)																																											
			VALUES		
								(	'#Billback_ID#',	
									#Program_ID#,											
									'#Product_ID#',													
									'#BB_Rate#'										
								)	
		</CFQUERY>
</CFLOOP>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx End claim Ajust xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Difference MakeUp --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFQUERY NAME="RoundAmount" DATASOURCE="#Application.Datasource#">
	UPDATE 	GL_Code_Item_Allocation_Cal
	SET 	Approved_Amount = ROUND(Approved_Amount,2)
	WHERE 	Billback_ID = '#Billback_ID#' AND
			Program_ID IN (#Program_List#) AND					
			Deleted = 0
</CFQUERY>

<!--- <CFQUERY NAME="DispRound" DATASOURCE="#Application.Datasource#">
	SELECT * FROM 	GL_Code_Item_Allocation_Cal

	WHERE 	Billback_ID = '#Billback_ID#' AND
			Program_ID IN (#Program_List#) AND					
			Deleted = 0
</CFQUERY>
<CFDUMP VAR="#DispRound#"> --->

<CFQUERY NAME="ItemAllocationCal" DATASOURCE="#Application.Datasource#">
	SELECT 	SUM(Approved_Amount) CalAmount
	
	FROM 	GL_Code_Item_Allocation_Cal
	
	WHERE 	Billback_ID = '#Billback_ID#' AND
			Program_ID IN (#Program_List#) AND					
			Deleted = 0
</CFQUERY>

<CFSET AllocatedAmount = 0>
<CFIF ItemAllocationCal.CalAmount NEQ "">
<CFSET AllocatedAmount = ItemAllocationCal.CalAmount>
</CFIF>

<CFQUERY NAME="Fix_Reb_For" DATASOURCE="#Application.Datasource#">
	SELECT 			CASE 
						WHEN Billback_Product.BB_Product_UOM = 1 THEN
							BB_Item_Final.Item_Volume_Paid_CS * BB_Item_Final_Detail.Paid_Rate_CS 
						WHEN Billback_Product.BB_Product_UOM = 2 THEN
							BB_Item_Final.Item_Volume_Paid_LB * BB_Item_Final_Detail.Paid_Rate_LB
					END AS Amount				
					
	FROM 			BB_Item_Final 
					
	INNER JOIN 		BB_Item_Final_Detail ON 
					BB_Item_Final.BB_Item_Final_ID = BB_Item_Final_Detail.BB_Item_Final_ID
	
	INNER JOIN 		Billback_Program  ON 
					Billback_Program.Billback_ID = BB_Item_Final.Billback_ID AND
					Billback_Program.Billback_Program_ID = BB_Item_Final.Billback_Program_ID AND 
					Billback_Program.Deleted = 0
					
	INNER JOIN 		Billback_Product ON 
					Billback_Product.Billback_ID = <CFIF CheckIsChild.BB_Is_Child EQ 1>'#CheckIsChild.BB_Parent_ID#'<CFELSE>'#Billback_ID#'</CFIF> AND
					BB_Item_Final.Billback_Product_ID = Billback_Product.Billback_Product_ID						
	
	WHERE 			BB_Item_Final.Billback_ID = <CFIF CheckIsChild.BB_Is_Child EQ 1>'#CheckIsChild.BB_Parent_ID#'<CFELSE>'#Billback_ID#'</CFIF> AND
					Billback_Program.Billback_ID = <CFIF CheckIsChild.BB_Is_Child EQ 1>'#CheckIsChild.BB_Parent_ID#'<CFELSE>'#Billback_ID#'</CFIF> AND
					Billback_Program.Program_ID IN (#Program_List#) AND
					BB_Item_Final.Deleted=0
</CFQUERY>

<CFSET FRF_Tot = 0>
<CFLOOP QUERY="Fix_Reb_For">
	<CFIF Amount NEQ "">
	<CFSET FRF_Tot = FRF_Tot + Amount>
	</CFIF>
</CFLOOP>

<CFQUERY NAME="GrowthAmount" DATASOURCE="#Application.Datasource#">
	SELECT    	Paid_Amount
	
	FROM       	BB_Growth_Program 
	
	INNER JOIN 	Billback_Program ON Billback_Program.Billback_Program_ID = BB_Growth_Program.Billback_Program_ID AND
				Billback_Program.Deleted = 0					
					
	WHERE     	BB_Growth_Program.Billback_ID = <CFIF CheckIsChild.BB_Is_Child EQ 1>'#CheckIsChild.BB_Parent_ID#'<CFELSE>'#Billback_ID#'</CFIF> AND
				BillBack_Program.Program_ID IN (#Program_List#) AND
				BB_Growth_Program.Deleted = 0	
</CFQUERY>

<CFSET Growth_Tot = 0>
<CFLOOP QUERY="GrowthAmount">
	<CFIF Paid_Amount NEQ "">
	<CFSET Growth_Tot = Growth_Tot + Paid_Amount>
	</CFIF>
</CFLOOP>
 
<CFSET LumpSum_Tot = 0>

<CFQUERY NAME="CheckLump" DATASOURCE="#Application.Datasource#">
	SELECT 	ISNULL(Lumpsum_Amt,0) Lumpsum_Amt,
			Lumpsum_Only
			
	FROM 	Billback_Program 
	WHERE 	Billback_ID = '#Billback_ID#' AND 
			Program_ID IN (#Program_List#) AND 
			Deleted = 0
</CFQUERY>

<!----- D13513: HZQA7 (HZPROD45) PENDING FUND UPDATE STATUS --->
<!----- total should be the paid amount --->
<CFSET Item_Allocation_Tot = CheckIsChild.Paid_Amount />
<CFIF CheckLump.Lumpsum_Amt GT 0 AND CheckLump.Lumpsum_Only NEQ 1>
	<CFSET Item_Allocation_Tot = Item_Allocation_Tot - CheckLump.Lumpsum_Amt>
</CFIF>
<cfif (Item_Allocation_Tot EQ "")>
	<cfset Item_Allocation_Tot = 0.00 />
</cfif>

<CFIF CheckIsChild.BB_Is_Child NEQ 1>
	<CFQUERY NAME="UpdateProgs_Sum_Amt" DATASOURCE="#Application.Datasource#">
		UPDATE 	GL_Code_Item_Allocation_Cal 
		
		SET 	Progs_Sum_Amt = #Item_Allocation_Tot#
		
		WHERE 	Billback_ID = '#Billback_ID#' AND
				Program_ID IN (#Program_List#) AND					
				Deleted = 0
	</CFQUERY>
</CFIF>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Split calculation makeup --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFIF CheckIsChild.BB_Is_Child EQ 1>	
	<CFIF CheckLump.Lumpsum_Amt GT 0 AND CheckLump.Lumpsum_Only NEQ 1>
		<CFSET CheckIsChild.Paid_Amount = CheckIsChild.Paid_Amount - CheckLump.Lumpsum_Amt>
	</CFIF>
	<!-----
	D16932: HZPROD171 Split BB and 1700 GL interface
	Issue: On split billbacks the total paid amount from the parent billback is allocated among the items
	and then one of the item is asjusted (large variation) so that the sum adds up to the split paid amount.
	Eg: Parent BB ($600)
	P1 $200
	P2 $400
	And this billback was split into 2
	BB Split 1 ($300) which is 50% of of 600   
	BB Split 2 ($300) which is 50% of of 600
	Each splits should have below
	P1 $100
	P2 $200
	But instead it is allocating as below
	P1 $200
	P2 $400 first, then will set it to 400-300 = $100
	The reason for this issue is, even though we have code to allocate the percentage among items for split billbacks, 
	the variables used have wrong values
	The math is (Approved_Amount * #CheckIsChild.Paid_Amount#) / #Item_Allocation_Tot# 
	so that it doing the math (200 * 300) / 300
	instead of  (200 * 300) / 600
	variable Item_Allocation_Tot is holding the child paid amount.
	Fix: Find the parent paid amount and set ti to a new variable which can be used in the calcualtion so that we can allocate the appropriate percentage per each item
	------>
	<cfset useLakebaseForGetParentPaidAmount = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_approved")>
<cfif useLakebaseForGetParentPaidAmount>
	<cftry>
		<cfset GetParentPaidAmount = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bb_approved", {
				"billback_id" = "eq.#CheckIsChild.BB_Parent_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetParentPaidAmount = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetParentPaidAmount>
<CFQUERY NAME="GetParentPaidAmount" DATASOURCE="#Application.Datasource#">
		SELECT 		* 
		FROM 		BB_Approved 
		WHERE 		Billback_ID = '#CheckIsChild.BB_Parent_ID#'
	</CFQUERY>
</cfif>
	<cfset ParentPaidAmount = GetParentPaidAmount.Paid_Amount />
	<cfif NOT IsNumeric(ParentPaidAmount) OR ParentPaidAmount EQ 0>
		<cfset ParentPaidAmount = 1 /> <!---- we don't want divide by 0 error or cannot convert from string error when it is NULL ---->
	</cfif>
	<CFQUERY NAME="UpdateAmount" DATASOURCE="#Application.Datasource#">
		UPDATE 	GL_Code_Item_Allocation_Cal
		
		SET 	Approved_Amount = ROUND(((Approved_Amount * #CheckIsChild.Paid_Amount#) / #ParentPaidAmount#),2),
				Progs_Sum_Amt = #CheckIsChild.Paid_Amount#
				
		WHERE 	Billback_ID = '#Billback_ID#' AND
				Deleted = 0
	</CFQUERY>
	<CFQUERY NAME="ItemAllocationCal" DATASOURCE="#Application.Datasource#">
		SELECT 	SUM(Approved_Amount) CalAmount
		
		FROM 	GL_Code_Item_Allocation_Cal
		
		WHERE 	Billback_ID = '#Billback_ID#' AND
				Program_ID IN (#Program_List#) AND					
				Deleted = 0
	</CFQUERY>
	
	<CFSET AllocatedAmount = 0>
	<CFIF ItemAllocationCal.CalAmount NEQ "">
		<CFSET AllocatedAmount = ItemAllocationCal.CalAmount>
	</CFIF>
	
	<CFSET Item_Allocation_Tot = CheckIsChild.Paid_Amount>
</CFIF>
<!--- xxxxxxxxxxxxxxxxxxxx End Split Calculation Makeup xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFSET Tot_Difference = Item_Allocation_Tot - AllocatedAmount>
<CFIF Tot_Difference NEQ 0>
	<CFQUERY NAME="MakeUpDiff" DATASOURCE="#Application.Datasource#">
		UPDATE GL_Code_Item_Allocation_Cal
		SET Approved_Amount = Approved_Amount + #Tot_Difference#
		WHERE GL_Code_Item_Allocation_ID = (	
												SELECT 	Top 1 GL_Code_Item_Allocation_ID 
												FROM 	GL_Code_Item_Allocation_Cal
												WHERE 	Billback_ID = '#Billback_ID#' AND
														Approved_Amount IN (	
																				SELECT MAX(Approved_Amount)
																				FROM GL_Code_Item_Allocation_Cal
																				WHERE Billback_ID = '#Billback_ID#' AND
																				Deleted = 0	
																			) AND
														Deleted = 0
											)
	</CFQUERY>
</CFIF>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFIF NOT IsDefined("FromCommomSplitInsert")>
	
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- Update A_R, Fiscal_year, Prod Grp, Pref Prod Grp and Fund Number --->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	
	
	<!--- <CFSET TemplateManager = CreateObject("component","components.programs.template.TemplateManager")> --->
	<CFLOOP LIST = "#Program_List#" INDEX = "Item">
		<!--- <CFQUERY NAME="GetProTemplate" DATASOURCE="#Application.Datasource#">
			SELECT ProgramType_ID 
			FROM Contract_main
			WHERE Contract_Main_ID = '#Item#'
		</CFQUERY>
	
		<CFSET TemplateID = TemplateManager.getLatestTemplateId(GetProTemplate.ProgramType_ID )> --->
		 <cfset useLakebaseForGetARFY = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program")>
<cfif useLakebaseForGetARFY>
	<cftry>
		<cfset GetARFY = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_program", {
				"billback_id" = "eq.#Billback_ID#",
				"program_id" = "eq.#item#",
				"deleted" = "eq.0",
				"select" = "ar_from_fiscal_year,a_r"
			}), "ar_from_fiscal_year,a_r"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetARFY = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetARFY>
<CFQUERY NAME="GetARFY" DATASOURCE="#Application.Datasource#">
			SELECT 	AR_From_Fiscal_Year,
					A_R
			FROM 	Billback_Program
			WHERE 	Billback_ID = '#Billback_ID#' AND Program_ID = '#item#' AND Deleted = 0 
		</CFQUERY>
</cfif>
		
		<!--- <CFQUERY NAME="GetARFY" DATASOURCE="#Application.Datasource#">
			SELECT AR_From_Fiscal_Year,A_R
			FROM Program_Control_Panel_Options 
			WHERE ProgramControl_Panel_Options_ID = '#TemplateID#'
		</CFQUERY> --->
		
		<cfset useLakebaseForUpdateFYA_R = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_item_allocation_cal")>
<cfif useLakebaseForUpdateFYA_R>
	<cftry>
		<cfset application.oLakebase.updateRows("gl_code_item_allocation_cal",
			{
				"billback_id" = "eq.#Billback_ID#",
				"program_id" = "eq.#item#",
				"deleted" = "eq.0"
			},
			{
				"fiscal_year" = "#GetARFY.AR_From_Fiscal_Year#",
				"a_r" = "#GetARFY.A_R#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateFYA_R = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateFYA_R>
<CFQUERY NAME="UpdateFYA_R" DATASOURCE="#Application.Datasource#">
			UPDATE 	GL_Code_Item_Allocation_Cal
			SET 	Fiscal_Year = '#GetARFY.AR_From_Fiscal_Year#',
					A_R = '#GetARFY.A_R#'
			WHERE 	Billback_ID = '#Billback_ID#' AND 
					Program_ID = '#item#' AND
					Deleted = 0
		</CFQUERY>
</cfif>
	</CFLOOP>
	
	
	<CFQUERY NAME="UpdateProdGrp" DATASOURCE="#Application.Datasource#">
		UPDATE 	GL_Code_Item_Allocation_Cal
		SET 	Prod_Grp = ( SELECT Prod_Grp FROM BSA_Foodservice_Items_Master WHERE BSA_Foodservice_Items_Master_ID = Product_ID )
		WHERE 	Billback_ID = '#Billback_ID#' AND 
				Program_ID IN (#Program_List#) AND
				Deleted = 0
	</CFQUERY>
	
	
	<CFQUERY NAME="UpdatePrefProdGrp" DATASOURCE="#Application.Datasource#">
		UPDATE GL_Code_Item_Allocation_Cal
		SET Pref_Prod_Grp = (	SELECT 	Top 1 Pref_Prod_Grp 
								FROM	GL_Code_Pro_Group_Mapping
								WHERE	Prod_Grp = GL_Code_Item_Allocation_Cal.Prod_Grp AND 
										Fiscal_Year = GL_Code_Item_Allocation_Cal.Fiscal_Year AND 
										Active_Data = 1 AND
										Deleted = 0	)
		WHERE 	Billback_ID = '#Billback_ID#' AND 
				Program_ID IN (#Program_List#) AND
				Deleted = 0
	</CFQUERY>
	
	<CFQUERY NAME="UpdateFundNumber" DATASOURCE="#Application.Datasource#">
		UPDATE GL_Code_Item_Allocation_Cal
		SET Fund_Number = (	SELECT 	Top 1 Fund_Number
							FROM 	GL_Code_Activation
							WHERE	PRODUCT_GROUP = Pref_Prod_Grp AND 
									A_R = GL_Code_Item_Allocation_Cal.A_R AND
									Fiscal_Year = GL_Code_Item_Allocation_Cal.Fiscal_Year AND 
									Current_Active_Data = 1 AND
									Deleted = 0	)
							
		WHERE 	Billback_ID = '#Billback_ID#' AND 
				Program_ID IN (#Program_List#) AND
				Deleted = 0
	</CFQUERY>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</CFIF>