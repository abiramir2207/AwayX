<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<BODY LEFTMARGIN="12" TOPMARGIN="12" RIGHTMARGIN="12">


<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
	<CFSET FORM.Lock_Status = 1>
	<CFINCLUDE TEMPLATE="/Billbacks/Multi_BB_Payment/Lock_BB.cfm">
</CFIF>

<CFPARAM NAME="Fixed" DEFAULT="">
<CFPARAM NAME="Rebate" DEFAULT="">
<CFPARAM NAME="Lump_Sum" DEFAULT="">
<CFPARAM NAME="Growth" DEFAULT="">
<CFPARAM NAME="Formula" DEFAULT="">
<CFPARAM NAME="Other" DEFAULT="">
<CFPARAM NAME="UnKnown" DEFAULT="">

<CFSET BBID_List = BBID>

<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
	<cfset useLakebaseForGetBBID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pay_multi_billbacks_list")>
<cfif useLakebaseForGetBBID>
	<cftry>
		<cfset GetBBID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("pay_multi_billbacks_list", {
				"pay_multi_billbacks_id" = "eq.#Pay_Multi_Billbacks_ID#",
				"deleted" = "eq.0",
				"select" = "billback_id"
			}), "billback_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetBBID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetBBID>
<CFQUERY NAME="GetBBID" DATASOURCE="#Application.Datasource#">
		SELECT 	Billback_ID 
		FROM 	Pay_Multi_Billbacks_List
		WHERE 	Pay_Multi_Billbacks_ID = '#Pay_Multi_Billbacks_ID#' AND 
				Deleted = 0
	</CFQUERY>
</cfif>
	<CFSET BBID_List = VALUELIST(GetBBID.Billback_ID)>
</CFIF>



<CFLOOP LIST="#BBID_List#" INDEX="BB_Item">

	<CFQUERY NAME="Delete_Previous" DATASOURCE="#Application.Datasource#">
		UPDATE GL_QBrand_Rate_Calculation SET Deleted=1 WHERE Billback_ID= <CFOUTPUT>'#BB_Item#'</CFOUTPUT><!--- {2FC3D871-B2E5-4A52-9B76-59A1D4AAF0DE} --->
	</CFQUERY>
	
	<CFQUERY NAME="Discounts_involved" DATASOURCE="#Application.Datasource#">
		SELECT 	distinct(bb_product_Type_ID) bb_product_Type_ID
		FROM 	Billback_Product_Detail
		WHERE   Billback_ID = <CFOUTPUT>'#BB_Item#'</CFOUTPUT>
				AND	Billback_Product_Detail.BB_Rate IS NOT NULL
				AND Deleted = 0
	</CFQUERY>
	<CFOUTPUT QUERY="Discounts_involved">
		<CFIF bb_product_Type_ID EQ 1>
			<CFSET Fixed = 1>
		<CFELSEIF bb_product_Type_ID EQ 2>
			<CFSET Rebate = 1>
		<CFELSEIF bb_product_Type_ID EQ 3>
			<CFSET Lump_Sum = 1>
		<CFELSEIF bb_product_Type_ID EQ 4>
			<CFSET Growth = 1>
		<CFELSEIF bb_product_Type_ID EQ 5>
			<CFSET Formula = 1>
		<CFELSEIF bb_product_Type_ID EQ 6>
			<CFSET Other = 1>
		<CFELSEIF bb_product_Type_ID EQ 7>
			<CFSET UnKnown = 1>
		</CFIF>
	</CFOUTPUT>
	
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- To get Q_brand and Paid Amount for Fixed, Rebate and Formula --->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFIF Fixed EQ 1 OR Rebate EQ 1 OR Formula EQ 1>
		<CFQUERY NAME="Get_QBrand" DATASOURCE="#Application.Datasource#">
			SELECT 			Billback.Billback_ID,
							CASE 
								WHEN Billback_Product.BB_Product_UOM = 1 THEN
									BB_Item_Final.Item_Volume_Paid_CS * BB_Item_Final_Detail.Paid_Rate_CS 
								WHEN Billback_Product.BB_Product_UOM = 2 THEN
									BB_Item_Final.Item_Volume_Paid_LB * BB_Item_Final_Detail.Paid_Rate_LB
							END AS Amount, 
							BB_Product_Type,
							BB_Item_Final.Billback_Product_ID, 
							Billback_Product.Product_ID , 
							Product_Q_Brand_Desc.Q_Brand_ID, 
							Q_Brand_Desc.Q_Brand
							
							
			FROM 			Billback 
			
			INNER JOIN 		BB_Item_Final ON Billback.Billback_ID = BB_Item_Final.Billback_ID
							AND Billback.Deleted= 0 AND BB_Item_Final.Deleted=0
							
			INNER JOIN 		BB_Item_Final_Detail ON BB_Item_Final.BB_Item_Final_ID = BB_Item_Final_Detail.BB_Item_Final_ID
			
			INNER JOIN 		Billback_Product ON BB_Item_Final.Billback_Product_ID = Billback_Product.Billback_Product_ID		
			
			INNER JOIN		BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = 	Billback_Product.Product_ID AND
							BSA_Foodservice_Items_Master.Deleted = 0 
			<!--- 			
			INNER JOIN 		Line_Of_Business ON Line_Of_Business.Line_Of_Business_ID = BSA_Foodservice_Items_Master.Line_Of_Business_ID AND
							Line_Of_Business.Deleted = 0 
			 --->				
			LEFT JOIN 		Product_Q_Brand_Desc ON	Billback_Product.Product_ID = Product_Q_Brand_Desc.BSA_Foodservice_Items_Master_ID AND
							Product_Q_Brand_Desc.Line_Of_Business_ID = BSA_Foodservice_Items_Master.Line_Of_Business_ID AND 
							Product_Q_Brand_Desc.Deleted = 0
							
			LEFT JOIN 		Q_Brand_Desc ON Q_Brand_Desc.Q_Brand_ID = Product_Q_Brand_Desc.Q_Brand_ID AND	
							Q_Brand_Desc.Deleted = 0
										 	
			WHERE 			Billback.Billback_ID = <CFOUTPUT>'#BB_Item#'</CFOUTPUT>
			ORDER BY 		Q_Brand_Desc.Q_Brand
		</CFQUERY>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->	
		
	
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- If there is any record insert it into GL_QBrand_Rate_Calculation. If there is no matching GL_QBrand replace it with f/s natural.--->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<CFIF Get_QBrand.recordcount GT 0>
			<CFOUTPUT QUERY="Get_QBrand">						
				<CFQUERY NAME="Match_QBrand" DATASOURCE="#Application.Datasource#">
					SELECT DISTINCT Q_Brand_ID,Q_brand_Description FROM GL_CODE WHERE 1=2 <CFIF Q_Brand_ID NEQ "">OR Q_Brand_ID = '#Q_Brand_ID#' AND Deleted=0 </CFIF>
				</CFQUERY>
				
				<CFIF Match_QBrand.recordcount EQ 0>
					<CFQUERY NAME="Match_QBrand" DATASOURCE="#Application.Datasource#">
						SELECT Q_brand_ID FROM Q_Brand_Desc WHERE Q_Brand = 'F/S Natural' AND Deleted=0                  
					</CFQUERY>				
				</CFIF>
				<CFQUERY NAME="Insert_QB_Calculated_Amount" DATASOURCE="#Application.Datasource#">
					INSERT INTO 		GL_QBrand_Rate_Calculation
										(	Billback_ID,
											<CFIF Product_ID NEQ "">
											Product_ID,
											</CFIF>
											<CFIF Q_Brand_ID NEQ "">
											Q_Brand_ID,	
											</CFIF>								
											GL_Match_QBrand_ID,
											Calculated_Amount,
											Pay_Multi_Billbacks_ID										
										)																																											
					VALUES										
										(	'#Billback_ID#',
											<CFIF Product_ID NEQ "">
											'#Product_ID#',
											</CFIF>
											<CFIF Q_Brand_ID NEQ "">
											'#Q_Brand_ID#',			
											</CFIF>						
											'#Match_QBrand.Q_brand_ID#',										
											#Amount#,
											<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
											'#Pay_Multi_Billbacks_ID#'
											<CFELSE>
											NULL
											</CFIF>
										)	
				</CFQUERY>			
			</CFOUTPUT>
		</CFIF> 
	</CFIF>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx Fixed, Rebate, Formula End xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	
	
	
	
	
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- Get QBrand and Rate for Growth products --->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFIF Growth EQ 1>
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<!--- Get the paid amount and no of programs involved in that Billback --->
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<CFQUERY NAME="Get_Paid_Rate_per_Program" DATASOURCE="#Application.Datasource#">
			SELECT    	BB_Growth_Program.Billback_ID,Paid_Amount,Program_ID
			
			FROM       	BB_Growth_Program 
			
			INNER JOIN 	Billback_Program 		ON Billback_Program.Billback_Program_ID = BB_Growth_Program.Billback_Program_ID					
							
			WHERE     	BB_Growth_Program.Billback_ID = <CFOUTPUT>'#BB_Item#'</CFOUTPUT>
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
				
				WHERE 		Billback_ID = <CFOUTPUT>'#BB_Item#'</CFOUTPUT>
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
					<CFQUERY NAME ="Get_Products_QBrand" DATASOURCE="#Application.Datasource#">
						SELECT 		DISTINCT(BB_Growth_Final_RateCheck.Product_ID) Product_ID,
									Product_Q_Brand_Desc.Q_Brand_ID Q_Brand_ID,
									Q_Brand_Desc.Q_Brand Q_Brand
							
						FROM 		BB_Growth_Final_RateCheck
						
						
						INNER JOIN 	BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = BB_Growth_Final_RateCheck.Product_ID AND
									BSA_Foodservice_Items_Master.Deleted = 0 
								
						LEFT JOIN 	Product_Q_Brand_Desc ON	BB_Growth_Final_RateCheck.Product_ID = Product_Q_Brand_Desc.BSA_Foodservice_Items_Master_ID AND
									Product_Q_Brand_Desc.Line_Of_Business_ID = BSA_Foodservice_Items_Master.Line_Of_Business_ID AND 
									Product_Q_Brand_Desc.Deleted = 0
						
						LEFT JOIN 	Q_Brand_Desc ON Q_Brand_Desc.Q_Brand_ID = Product_Q_Brand_Desc.Q_Brand_ID AND	
									Q_Brand_Desc.Deleted = 0
				
						
						<!--- 				
						LEFT JOIN  	Product_Q_Brand_Desc ON BB_Growth_Final_RateCheck.Product_ID = Product_Q_Brand_Desc.BSA_Foodservice_Items_Master_ID
									AND Product_Q_Brand_Desc.Line_Of_Business_ID = (SELECT Line_Of_Business_ID FROM Line_Of_Business WHERE Line_Of_Business = 'F' AND DELETED = 0)				
						LEFT JOIN  	Q_Brand_Desc ON Q_Brand_Desc.Q_Brand_ID = Product_Q_Brand_Desc.Q_Brand_ID
						 --->
						WHERE 		Billback_ID = '#BB_Item#'
									AND Program_Growth_Component_ID='#Program_Growth_Component_ID#'
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
					<CFSET Paid_Rate_Per_Product = Paid_Rate_per_Component/Get_Products_QBrand.recordcount>				
					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
					
					
					<CFLOOP QUERY="Get_Products_QBrand">
					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
					<!--- If not matching qbrand in GL_Code repalce with F/S Natural. INSERT into table.  --->
					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->				
						<CFQUERY NAME="Match_QBrand" DATASOURCE="#Application.Datasource#">
							SELECT DISTINCT Q_Brand_ID,Q_brand_Description FROM GL_CODE WHERE 1=2 <CFIF Q_Brand_ID NEQ "">OR Q_Brand_ID = '#Q_Brand_ID#' AND Deleted=0 </CFIF>
						</CFQUERY>
						<CFIF Match_QBrand.recordcount EQ 0>
							<CFQUERY NAME="Match_QBrand" DATASOURCE="#Application.Datasource#">
								SELECT Q_brand_ID FROM Q_Brand_Desc WHERE Q_Brand = 'F/S Natural'                   
							</CFQUERY>						
						</CFIF>
						
						<CFQUERY NAME="Insert_Growth_Details" DATASOURCE="#Application.Datasource#">
							INSERT INTO 		GL_QBrand_Rate_Calculation
												(	Billback_ID,
													<CFIF Product_ID NEQ "">
													Product_ID,
													</CFIF>
													<CFIF Q_Brand_ID NEQ "">
													Q_Brand_ID,				
													</CFIF>								
													GL_Match_QBrand_ID,
													Calculated_Amount,
													Pay_Multi_Billbacks_ID
													
												)																																											
							VALUES		
												(	'#Get_Paid_Rate_per_Program.Billback_ID#',
													<CFIF Product_ID NEQ "">	
													'#Product_ID#',
													</CFIF>
													<CFIF Q_Brand_ID NEQ "">
													'#Q_Brand_ID#',
													</CFIF>
													'#Match_QBrand.Q_brand_ID#',
													#Paid_Rate_Per_Product#,
													<CFIF Isdefined("Pay_Multi_Billbacks_ID")>
													'#Pay_Multi_Billbacks_ID#'
													<CFELSE>
													NULL
													</CFIF>
												)	
						</CFQUERY>
					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->								
					</CFLOOP>
					</CFOUTPUT>	
				<CFELSE>
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				<!--- If there is no records its not a valid program or product. So just insert the F/S Natural value --->
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
					<CFQUERY NAME="Reset_QBrand" DATASOURCE="#Application.Datasource#">
						SELECT * FROM Q_Brand_Desc WHERE Q_Brand = 'F/S Natural' AND Deleted=0                   
					</CFQUERY>
					<CFQUERY NAME="Insert_Growth_Details" DATASOURCE="#Application.Datasource#">
						INSERT INTO 		GL_QBrand_Rate_Calculation
											(	Billback_ID,
												GL_Match_QBrand_ID,
												Calculated_Amount,
												Pay_Multi_Billbacks_ID											
											)																																											
						VALUES		
											(	'#Get_Paid_Rate_per_Program.Billback_ID#',	
												'#Reset_QBrand.Q_Brand_ID#',
												#Paid_Amount_For_This_Program#,
												<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
												'#Pay_Multi_Billbacks_ID#'
												<CFELSE>
												NULL
												</CFIF>
											)	
					</CFQUERY>
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->				
				</CFIF>
			
			</CFIF>
		</CFLOOP>	
	</CFIF>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxx Growth End xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	
	
	
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- Get Qbrnd and Rate for Lumpsum Products--->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	
		<CFQUERY NAME="Get_Lumpsum_Program" DATASOURCE="#Application.Datasource#">
			SELECT 			Billback_ID,
							LS_Paid_Amount,
							Billback_Program_ID
							
			FROM			BB_Lump_Sums 								
			
			WHERE			Billback_ID = <CFOUTPUT>'#BB_Item#'</CFOUTPUT>
		</CFQUERY>
		
		<CFOUTPUT QUERY="Get_Lumpsum_Program">
	
			<CFIF LS_Paid_Amount NEQ "" AND LS_Paid_Amount NEQ 0>
			<CFSET Amount_Paid_For_This_Program = LS_Paid_Amount>
			<CFQUERY NAME="Get_Items_Climed_for_BB_Program" DATASOURCE="#Application.Datasource#">
				SELECT 			BB_Item_Final.Billback_Product_ID,
								Item_Volume_Paid_LB,
								Product_ID,
								Product_Q_Brand_Desc.Q_Brand_ID,
								Q_Brand_Desc.Q_Brand
								
				FROM 			BB_Item_Final
				
				INNER JOIN 		Billback_Product ON Billback_Product.Billback_Product_ID = BB_Item_Final.Billback_Product_ID 
				
				INNER JOIN 		BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Billback_Product.Product_ID AND
								BSA_Foodservice_Items_Master.Deleted = 0 
						
				LEFT JOIN 		Product_Q_Brand_Desc ON	Billback_Product.Product_ID = Product_Q_Brand_Desc.BSA_Foodservice_Items_Master_ID AND
								Product_Q_Brand_Desc.Line_Of_Business_ID = BSA_Foodservice_Items_Master.Line_Of_Business_ID AND 
								Product_Q_Brand_Desc.Deleted = 0
				
				LEFT JOIN 		Q_Brand_Desc ON Q_Brand_Desc.Q_Brand_ID = Product_Q_Brand_Desc.Q_Brand_ID AND	
								Q_Brand_Desc.Deleted = 0			
				<!--- 
				INNER JOIN 		Product_Q_Brand_Desc ON Product_Q_Brand_Desc.BSA_Foodservice_Items_Master_ID = Billback_Product.Product_ID
								AND Product_Q_Brand_Desc.Line_Of_Business_ID = (SELECT Line_Of_Business_ID FROM Line_Of_Business WHERE Line_Of_Business = 'F' AND DELETED = 0)				
				INNER JOIN 		Q_Brand_Desc ON Q_Brand_Desc.Q_Brand_ID = Product_Q_Brand_Desc.Q_Brand_ID
	 			--->
				WHERE 			BB_Item_Final.Billback_ID = '#BB_Item#'
								AND BB_Item_Final.Billback_Program_ID = '#Billback_Program_ID#'
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
					<CFQUERY NAME="Match_QBrand" DATASOURCE="#Application.Datasource#">
						SELECT DISTINCT Q_Brand_ID,Q_brand_Description FROM GL_CODE WHERE 1=2 <CFIF Q_Brand_ID NEQ "">OR Q_Brand_ID = '#Q_Brand_ID#' AND Deleted=0 </CFIF>
					</CFQUERY>
					<CFIF Match_QBrand.recordcount EQ 0>
						<CFQUERY NAME="Match_QBrand" DATASOURCE="#Application.Datasource#">
							SELECT Q_brand_ID FROM Q_Brand_Desc WHERE Q_Brand = 'F/S Natural'                   
						</CFQUERY>						
					</CFIF>

					<CFQUERY NAME="Insert_Growth_Details" DATASOURCE="#Application.Datasource#">
						INSERT INTO 		GL_QBrand_Rate_Calculation
											(	Billback_ID,
												<CFIF Product_ID NEQ "">
												Product_ID,
												</CFIF>
												<CFIF Q_Brand_ID NEQ "">
												Q_Brand_ID,				
												</CFIF>							
												GL_Match_QBrand_ID,
												Calculated_Amount,
												Pay_Multi_Billbacks_ID
												
											)																																											
						VALUES		
											(	'#Get_Lumpsum_Program.Billback_ID#',
												<CFIF Product_ID NEQ "">	
												'#Product_ID#',
												</CFIF>
												<CFIF Q_Brand_ID NEQ "">
												'#Q_Brand_ID#',
												</CFIF>
												'#Match_QBrand.Q_brand_ID#',
												#Paid_Rate_Per_Product#,
												<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
												'#Pay_Multi_Billbacks_ID#'
												<CFELSE>
												NULL
												</CFIF>
											)	
					</CFQUERY>
				
				</CFLOOP>
			<CFELSE>
				<CFQUERY NAME="Match_QBrand" DATASOURCE="#Application.Datasource#">
					SELECT * FROM Q_Brand_Desc WHERE Q_Brand = 'F/S Natural' AND Deleted=0                   
				</CFQUERY>
				<CFQUERY NAME="Insert_Growth_Details" DATASOURCE="#Application.Datasource#">
					INSERT INTO 		GL_QBrand_Rate_Calculation
										(	Billback_ID,																					
											GL_Match_QBrand_ID,
											Calculated_Amount,
											Pay_Multi_Billbacks_ID
											
										)																																											
					VALUES		
										(	'#Get_Lumpsum_Program.Billback_ID#',	
											'#Match_QBrand.Q_brand_ID#',
											#Amount_Paid_For_This_Program#,
											<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
											'#Pay_Multi_Billbacks_ID#'
											<CFELSE>
											NULL
											</CFIF>
										)	
				</CFQUERY>
		
			</CFIF>
			</CFIF>
		</CFOUTPUT>		
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxx Lumpsum End xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFQUERY NAME="Test" DATASOURCE="#Application.Datasource#">
		SELECT * FROM GL_QBrand_Rate_Calculation WHERE Billback_ID = '#BB_Item#' AND Deleted = 0
	</CFQUERY>
	
</CFLOOP>

	
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Make up the rounding difference --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Sum_GL_Rate" DATASOURCE="#Application.Datasource#">
	SELECT 		GL_Match_QBrand_ID,
				SUM(Calculated_Amount) Tot_Amount
				
	FROM 		GL_QBrand_Rate_Calculation 
	
	WHERE 		<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
					Pay_Multi_Billbacks_ID = '#Pay_Multi_Billbacks_ID#' AND
				<CFELSE>
					Billback_ID = <CFOUTPUT>'#BBID#'</CFOUTPUT> AND
				</CFIF>
				Deleted = 0
	GROUP BY 	GL_Match_QBrand_ID
</CFQUERY>
<CFSET GL_Total = 0>
<CFOUTPUT QUERY="Sum_GL_Rate">
	<CFSET Round_Amount = Tot_Amount * 100>
	<CFSET Round_Amount = round(Round_Amount)>
	<CFSET Round_Amount = Round_Amount / 100>
	<CFSET GL_Total=GL_Total + Round_Amount>	
</CFOUTPUT>

<CFIF BBID NEQ "">
	<CFQUERY NAME="Actual_Approved_Amount" DATASOURCE="#Application.Datasource#">
		SELECT 	Paid_Amount
		
		FROM 	BB_Approved
		
		WHERE	Billback_ID = <CFOUTPUT>'#BBID#'</CFOUTPUT>			
	</CFQUERY>
</CFIF>

<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
	<CFQUERY NAME="Actual_Approved_Amount" DATASOURCE="#Application.Datasource#">
		SELECT 		SUM(BB_Approved.Paid_Amount) Paid_Amount
		
		FROM 		BB_Approved
		
		INNER JOIN 	Pay_Multi_Billbacks_List ON Pay_Multi_Billbacks_List.Billback_ID = BB_Approved.Billback_ID AND
					Pay_Multi_Billbacks_List.Deleted = 0
					
		WHERE 		Pay_Multi_Billbacks_ID = '#Pay_Multi_Billbacks_ID#'
	</CFQUERY>
</CFIF>


	<CFSET Round_Paid_Amount = Actual_Approved_Amount.Paid_Amount * 100>
	<CFSET Round_Paid_Amount = round(Round_Paid_Amount)>
	<CFSET Approved_Amount = Round_Paid_Amount / 100>



<CFIF GL_Total NEQ Approved_Amount>

	<CFIF GL_Total GT Approved_Amount>
		<CFSET Difference = GL_Total - Approved_Amount>		
	<CFELSE>	
		<CFSET Difference = Approved_Amount - GL_Total>
	</CFIF>

	<CFQUERY NAME="Get_Max_Amount" DATASOURCE="#Application.Datasource#">
		SELECT 	Calculated_Amount,GL_QBrand_Rate_ID
		
		FROM 	GL_QBrand_Rate_Calculation 
		
		WHERE 	<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
					Pay_Multi_Billbacks_ID = '#Pay_Multi_Billbacks_ID#' AND
				<CFELSE>
					Billback_ID = <CFOUTPUT>'#BBID#'</CFOUTPUT> AND 
				</CFIF>
				Deleted=0 AND
				Calculated_Amount =(SELECT 	Max(Calculated_Amount)
								FROM 	GL_QBrand_Rate_Calculation 
								WHERE 	<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
											Pay_Multi_Billbacks_ID = '#Pay_Multi_Billbacks_ID#' AND
										<CFELSE>
											Billback_ID = <CFOUTPUT>'#BBID#'</CFOUTPUT> AND 
										</CFIF>
										Deleted=0	)
	</CFQUERY>

	<CFIF GL_Total GT Approved_Amount>
		<CFSET reset_Amount = Get_Max_Amount.Calculated_Amount - Difference>
	<CFELSE>
		<CFSET reset_Amount = Get_Max_Amount.Calculated_Amount + Difference>
	</CFIF>
	
	
	<CFQUERY NAME="Update_Diff" DATASOURCE="#Application.DAtasource#">
		UPDATE		GL_QBRAND_Rate_Calculation
		
		SET			Calculated_Amount =	#reset_Amount#
		
		WHERE		<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
						Pay_Multi_Billbacks_ID = '#Pay_Multi_Billbacks_ID#' AND
					<CFELSE>
						Billback_ID	= <CFOUTPUT>'#BBID#'</CFOUTPUT> AND 
					</CFIF>
					Deleted=0 AND
					GL_QBrand_Rate_ID=<CFOUTPUT>#Get_Max_Amount.GL_QBrand_Rate_ID#</CFOUTPUT>
	</CFQUERY>		
	
</CFIF>


<!--- <CFQUERY NAME="Sum_GL_Rate" DATASOURCE="#Application.Datasource#">
	SELECT 		SUM(Calculated_Amount) Total_Amount 
	
	FROM 		GL_QBrand_Rate_Calculation
	
	WHERE 		Billback_ID = <CFOUTPUT>'#BBID#'</CFOUTPUT> AND Deleted=0
</CFQUERY>

<CFSET GL_Total = Sum_GL_Rate.Total_Amount>
<CFQUERY NAME="Actual_Approved_Amount" DATASOURCE="#Application.Datasource#">
	SELECT 	Paid_Amount
	
	FROM 	BB_Approved
	
	WHERE	Billback_ID = <CFOUTPUT>'#BBID#'</CFOUTPUT> 
</CFQUERY>
<CFSET Approved_Amount = Actual_Approved_Amount.Paid_Amount>

<CFIF GL_Total NEQ Approved_Amount>
	<CFIF GL_Total GT Approved_Amount>
		<CFSET Difference = GL_Total - Approved_Amount>		
	<CFELSE>
	
		<CFSET Difference = Approved_Amount - GL_Total>
	</CFIF>
	
	<CFQUERY NAME="Get_Max_Amount" DATASOURCE="#Application.Datasource#">
		SELECT 	Calculated_Amount,GL_QBrand_Rate_ID
		
		FROM 	GL_QBrand_Rate_Calculation 
		
		WHERE 	Billback_ID = <CFOUTPUT>'#BBID#'</CFOUTPUT> AND Deleted=0 
		AND Calculated_Amount =(SELECT Max(Calculated_Amount) FROM GL_QBrand_Rate_Calculation WHERE Billback_ID = <CFOUTPUT>'#BBID#'</CFOUTPUT> AND Deleted=0 )
	</CFQUERY>

	<CFIF GL_Total GT Approved_Amount>
		<CFSET reset_Amount = Get_Max_Amount.Calculated_Amount - Difference>
	<CFELSE>
		<CFSET reset_Amount = Get_Max_Amount.Calculated_Amount + Difference>
	</CFIF>
	
	<CFQUERY NAME="Update_Diff" DATASOURCE="#Application.DAtasource#">
		UPDATE		GL_QBRAND_Rate_Calculation
		
		SET			Calculated_Amount =	#reset_Amount#
		
		WHERE		Billback_ID	= <CFOUTPUT>'#BBID#'</CFOUTPUT> AND Deleted=0 
					AND GL_QBrand_Rate_ID=<CFOUTPUT>#Get_Max_Amount.GL_QBrand_Rate_ID#</CFOUTPUT>
	</CFQUERY>		
</CFIF>
  --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->




<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Dispalying results --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset useLakebaseForAll_GL_Type = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_type")>
<cfif useLakebaseForAll_GL_Type>
	<cftry>
		<cfset All_GL_Type = application.oLakebase.toQuery(
			application.oLakebase.selectRows("gl_type", {
				"order" = "gl_type_desc.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForAll_GL_Type = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForAll_GL_Type>
<CFQUERY NAME="All_GL_Type" DATASOURCE="#Application.Datasource#">
	SELECT * FROM GL_Type ORDER BY GL_Type_Desc
</CFQUERY>
</cfif>

<CFQUERY NAME="Sum_up_QBrand" DATASOURCE="#Application.Datasource#">
	SELECT 		GL_QBrand_Rate_Calculation.Billback_ID,
				BB_Code,
				GL_Match_QBrand_ID,
				SUM(Calculated_Amount) Tot_Amount
				
	FROM 		GL_QBrand_Rate_Calculation 
	INNER JOIN	Billback ON Billback.Billback_ID = GL_QBrand_Rate_Calculation.Billback_ID
	
	WHERE 		<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
					Pay_Multi_Billbacks_ID = '#Pay_Multi_Billbacks_ID#' AND
				<CFELSE>
					GL_QBrand_Rate_Calculation.Billback_ID = <CFOUTPUT>'#BBID#'</CFOUTPUT> AND 
				</CFIF>
				GL_QBrand_Rate_Calculation.Deleted = 0 AND
				Calculated_Amount > 0
				
	GROUP BY 	GL_QBrand_Rate_Calculation.Billback_ID,BB_Code,GL_Match_QBrand_ID

	ORDER BY	GL_QBrand_Rate_Calculation.Billback_ID,BB_Code	
</CFQUERY>

<CFSET GL_QBrand_ID = #VALUELIST(Sum_up_QBrand.GL_Match_QBrand_ID)#>
<CFSET GL_Tol_Amount = #VALUELIST(Sum_up_QBrand.Tot_Amount)#>


<SCRIPT LANGUAGE="JavaScript">
	function setRadioChecked(index)
	{
		event.returnValue = false;
		var mainChObj = null;
		var GL_Type_ID = "";
		var bChecked = false;
		var GL_Type_Desc_CheckObj = document.all.GL_Type_Desc_Check;
		var totalLen = 0;
		if(document.all.JS_GL_Type_Count)
		{
			totalLen = parseInt(document.all.JS_GL_Type_Count.value);
		}
		
		if(GL_Type_Desc_CheckObj)
		{
			if(GL_Type_Desc_CheckObj.length)
			{
				if(GL_Type_Desc_CheckObj.length >= index)
				{
					mainChObj = GL_Type_Desc_CheckObj[index-1];
				}
			}
			else if(index == 1)
			{
				mainChObj = GL_Type_Desc_CheckObj;
			}
			
			if(mainChObj)
			{
				bChecked = mainChObj.value;
				GL_Type_ID = mainChObj.GL_Type_ID;
				mainChObj.value = (bChecked==1?0:1);
				var i;		
				for(i=1;i<=totalLen;i++)
				{
					var chObj = eval("document.all.GL_Type_" + i);
					setCheckForThisID(chObj, index-1, GL_Type_ID, bChecked);			
				}
			}
		}
	}
	
	function setCheckForThisID(chObj, index, GL_Type_ID, bChecked)
	{
		var i;
		if(chObj.length)
		{
			for(i=0;i<chObj.length;i++)
			{
				if(chObj[i].value == GL_Type_ID)
				{
					chObj[i].checked = bChecked;
				}				
			}
		}
		else
		{			
			if(chObj.value == GL_Type_ID)
			{
				chObj.checked = bChecked;
			}
		}
	}
</SCRIPT>

<FORM NAME="Select_GL_Type" ACTION="GL_Type_Selection_Action.cfm" METHOD="Post">

<CFOUTPUT>
<INPUT TYPE="Hidden" NAME="BBID" VALUE="#URL.BBID#">
<INPUT TYPE="Hidden" NAME="RID" VALUE="#URL.RID#">
<INPUT TYPE="Hidden" NAME="GL_QBrand_ID" VALUE="#GL_QBrand_ID#">
<INPUT TYPE="Hidden" NAME="GL_Tol_Amount" VALUE="#GL_Tol_Amount#">
<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
<INPUT TYPE="Hidden" NAME="Pay_Multi_Billbacks_ID" VALUE="#Pay_Multi_Billbacks_ID#"> 
</CFIF>
</CFOUTPUT>

<BR><BR>
<!--- <FONT SIZE="2" COLOR="NAVY"><B>GL Type Selection</B></FONT>
<HR COLOR="Orange"> --->

<TABLE BORDER="0" <CFIF ISDefined("Pay_Multi_Billbacks_ID")>WIDTH="750" ALIGN="Center"<CFELSE>WIDTH="100%"</CFIF> CELLSPACING="0" CELLPADING="0">
	<TR>
		<TD COLSPAN="100%"><FONT SIZE="2" COLOR="NAVY"><B>GL Type Selection</B></FONT><HR COLOR="Orange"></TD>
	</TR>
	<TR BGCOLOR="ffce84">
		<TD NOWRAP STYLE="Border-bottom:solid aqua 1px;"><B>Q_Brand</B></TD>
		<TD NOWRAP WIDTH="6%" STYLE="Border-bottom:solid aqua 1px;"><B>Total $'S</B></TD>
		<TD NOWRAP  STYLE="Border-bottom:solid aqua 1px;">&nbsp;</TD>
		<CFOUTPUT QUERY="All_GL_Type">
			<TD NOWRAP ALIGN="Center"  STYLE="Border-bottom:solid aqua 1px;">
			<A HREF="void(0);" onClick="setRadioChecked(#CurrentRow#);return false;"><B>#UCASE(GL_Type_Desc)#</B></A>
			<INPUT TYPE="HIDDEN" NAME="GL_Type_Desc_Check" VALUE="0" GL_Type_ID="#GL_Type_ID#">
			</TD>
		</CFOUTPUT>
	</TR>
	
	<CFSET Count = 0>
	<CFSET Tol_Rounded_Amount = 0>
	<CFSET PreviousBB = "">
	
	<CFOUTPUT QUERY="Sum_up_QBrand">
	<INPUT TYPE="Hidden" NAME="MultiBBID" VALUE="#Billback_ID#">		
		<CFIF Tot_Amount NEQ 0>
			
			<CFSET ReplacedBillback_ID = REPLACE(Billback_ID,"-","_","All")>		
			<CFSET ThisBB = TRIM(BB_Code)>
			
			<CFQUERY NAME="Get_GL_Type" DATASOURCE="#Application.Datasource#">
				SELECT 		Q_Brand_ID,
							GL_Code.Descr Descr,
							GL_Code.GL_Type_ID,
							GL_Type.GL_Type_Desc 
							
				FROM 		GL_Code
				
				INNER JOIN 	GL_Type ON GL_Type.GL_Type_ID = GL_Code.GL_Type_ID
				WHERE 		Q_Brand_ID='#GL_Match_QBrand_ID#' AND GL_Code.Deleted=0
				ORDER BY 	GL_Type.GL_Type_ID 
			</CFQUERY>	
			<CFSET GL_Type_List = #VALUELIST(Get_GL_TYPE.GL_Type_ID)#>	
			<CFIF IsDefined("Pay_Multi_Billbacks_ID") AND PreviousBB NEQ ThisBB>
			<TR>
				<TD COLSPAN="100%" STYLE="border-bottom: 1px solid ##aaaaaa;"><BR><B>Billback: #ThisBB#</B></TD>
			</TR>
			</CFIF>
			<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
				<TD STYLE="Border-bottom:solid aqua 1px;">#Get_GL_Type.Descr#</TD>  

		
				<CFSET Round_Amount = Tot_Amount * 100>
				<CFSET Round_Amount = round(Round_Amount)>
				<CFSET Round_Amount = Round_Amount / 100>
				<CFSET Tol_Rounded_Amount=Tol_Rounded_Amount + Round_Amount>
				<TD ALIGN="Right" STYLE="Border-bottom:solid aqua 1px;">#NumberFormat(Round_Amount,"_.__")#</TD>		
				<CFSET Count = Count + 1>
				<CFSET QBrand_Desc = Get_GL_Type.Descr>
				<TD NOWRAP STYLE="Border-bottom:solid aqua 1px;"><SPAN ID="Err_SP_#Count#_#ReplacedBillback_ID#" Descr="#Get_GL_Type.Descr#">&nbsp;</SPAN></TD>
				<CFLOOP QUERY="All_GL_Type">			
					<CFSET Place_Radio = "">
					<CFSET Place_Radio = #LISTFIND(GL_Type_LIST,"#GL_Type_ID#")#>			
						<CFIF Place_Radio NEQ 0>				
							<TD WIDTH="6%" ALIGN="Center" STYLE="Border-bottom:solid aqua 1px;"><INPUT TYPE="Radio" NAME="GL_Type_#Count#_#ReplacedBillback_ID#" VALUE="#GL_Type_ID#"></TD>
						<CFELSE>
							<TD WIDTH="6%" STYLE="Border-bottom:solid aqua 1px;">&nbsp;</TD>
						</CFIF>
				</CFLOOP>	
			</TR>
			<CFSET PreviousBB = ThisBB>
		</CFIF>
	</CFOUTPUT>
	<INPUT TYPE="HIDDEN" NAME="JS_GL_Type_Count" VALUE="<CFOUTPUT>#Count#</CFOUTPUT>">
	<TR>
		<TD ALIGN="Right"><B>TOTAL</B></TD>
		<TD Align = "Right"><CFOUTPUT><B>#NumberFormat(Tol_Rounded_Amount,"_.__")#</B></CFOUTPUT></TD>
		<CFOUTPUT QUERY="All_GL_Type">
		<TD>&nbsp;</TD>
		</CFOUTPUT>
	</TR>
	<TR>
		<TD COLSPAN="100%"><HR COLOR="Orange"></TD>
	</TR>
</TABLE>
<BR><BR><BR>

<TABLE ALIGN="CENTER">
<TR>
	<TD>
		<CFOUTPUT>
				<CF_button
					button_name		=	""
					button_caption	=	"continue"
					button_action	=	"validate()"
					button_type		=	"javascript_link"
					button_width	=	"75"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
					>
			</CFOUTPUT>
	</TD>
</TR>
</TABLE>
</FORM>
<CF_MessageWindow>




</body>
</html>





<!--- <CFQUERY NAME="Programs_Involved" DATASOURCE="#Application.Datasource#">
	SELECT 		DISTINCT(Actual_Program_ID) Actual_Program_ID
	FROM 		BB_Growth_Final_RateCheck 
	WHERE 		Billback_ID = '{2FC3D871-B2E5-4A52-9B76-59A1D4AAF0DE}'
</CFQUERY>

<CFOUTPUT QUERY="Programs_Involved">
	<CFQUERY NAME="Get_Paid_Rate" DATASOURCE="#Application.Datasource#">
		SELECT    	Paid_Amount
		
		FROM       	BB_Growth_Program INNER JOIN Billback_Program 
		ON 			Billback_Program.Billback_Program_ID = BB_Growth_Program.Billback_Program_ID
					AND Billback_Program.Program_ID = #Actual_Program_ID#
						
		WHERE     	BB_Growth_Program.Billback_ID = '{2FC3D871-B2E5-4A52-9B76-59A1D4AAF0DE}'
	</CFQUERY>
	
	
	<CFQUERY NAME="Get_Component_Volume" DATASOURCE="#Application.Datasource#">
		SELECT 		DISTINCT Program_Growth_Component_ID,
					TC_Volume_LB 
					
		FROM 		BB_Growth_Final_RateCheck 
		WHERE 		Billback_ID = '{2FC3D871-B2E5-4A52-9B76-59A1D4AAF0DE}'
					Actual_Program_ID = #Actual_Program_ID#
	</CFQUERY>
	<CFOUTPUT QUERY="Get_Component_Volume">
		 <CFQUERY NAME="Get_Products_QBrand" DATASOURCE="#Application.Datasource#">
		 	SELECT 			DISTINCT (Product_ID),
							Q_Brand_Desc.Q_Brand_ID,
							Q_Brand_Desc.Q_Brand 
							
			FROM 			BB_Growth_Final_RateCheck 
			
			INNER JOIN 		Product_Q_Brand_Desc
			ON 				BB_Growth_Final_RateCheck.Product_ID = Product_Q_Brand_Desc.BSA_Foodservice_Items_Master_ID
							AND Product_Q_Brand_Desc.Line_Of_Business_ID = (SELECT Line_Of_Business_ID FROM Line_Of_Business WHERE Line_Of_Business = 'F' AND DELETED = 0)
							
			INNER JOIN 		Q_Brand_Desc 
			ON 				Q_Brand_Desc.Q_Brand_ID = Product_Q_Brand_Desc.Q_Brand_ID
			
			WHERE 			Billback_ID = '{2FC3D871-B2E5-4A52-9B76-59A1D4AAF0DE}' 
							AND Program_Growth_Component_ID = '#Program_Growth_Component_ID#'
		 </CFQUERY>
	</CFOUTPUT>
</CFOUTPUT> --->
<cfoutput>
<script src="/script/javascript/validations.js"></script>
<SCRIPT language="JavaScript">
var billbackIdList = "#ValueList(Sum_up_QBrand.Billback_ID, ",")#"
function validate()
{
	var bErr = false;
	var totalLen = 0;
	var bbIdArray = billbackIdList.split(",");
	if(document.all.JS_GL_Type_Count)
	{
		//totalLen = parseInt(document.all.JS_GL_Type_Count.value);
		totalLen = bbIdArray.length;
	}
	var i, bbId;		
	for(i=1;i<=totalLen;i++)
	{
		bbId = bbIdArray[i-1].replace(/-/ig, "_");
		var chObj = eval("document.all.GL_Type_" + i + "_" + bbId);
		var spObj = eval("document.all.Err_SP_" + i + "_" + bbId);
		
		if(AnyRadioChecked(chObj))
		{			
			clearQueue(spObj);
		}
		else
		{
			bErr = true;
			queueMessage("Select a GL Type for '" + spObj.Descr + "'", spObj);
		}
	}
	if(bErr)
	{
		showMessageWindow();
	}
	else	
	{
		document.Select_GL_Type.submit();
	}
}
</SCRIPT>
</cfoutput>