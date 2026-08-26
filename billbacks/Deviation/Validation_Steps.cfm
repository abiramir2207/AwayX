<!------
Validation_Steps.cfm
----->

	<!------------ Step level ----------------->
	
	<cfparam name="Call_From_DeviationDotCfm" 	default=0>
	<cfparam name="URL.STEP_LEVEL" 	default=1>
	<CFIF URL.STEP_LEVEL EQ "" OR NOT IsNumeric(URL.STEP_LEVEL)>
		<CFSET URL.STEP_LEVEL = 1>
	</CFIF>

	<CFSET STEP_LEVEL=URL.STEP_LEVEL>

	<CFSET Validation_Step_Version = 2>
	<CFSET Step_Discount_Type_List="Fixed Price, #Application.RebateLabel#, , Growth, Formula Price,6,7,8,9,10,Bid Request">


	<!------------------- Build Validation Steps ---------------------------->
	<CFIF Validation_Step_Version EQ 1>
		<CFIF NOT Deviation_Show_Expected_Values>					
			<CFSET VALIDATION_STEPS="1,2,3">
			<CFSET VALIDATION_STEPS_DESC="Known and Authorized Products,Known Program &##44; Authorized Payee and Date Match,Known Payee and Product level Date Overlap">
			
			<CFSET FIXED_STEP_LEVEL=STEP_LEVEL>
			<CFQUERY  dataSource="#application.datasource#" NAME="Check_Discount_Type">
				SELECT	Count(Billback.BB_Code) AS this_Count, Billback_Product_Detail.BB_Product_Type_ID, Program_Control_Panel_Options.Generic_Type
				<!--- The billback may have an associated distributor when the payee is an operator OR broker. --->
				,CASE billback.Billback_Payee_Type_ID
					WHEN 2
						THEN 
							Billback_Operator.Associated_Ship_to
					WHEN 3
						THEN				
							Billback_Broker.Associated_Ship_to
					ELSE
						NULL					
					END

				As Associated_Ship_to

				FROM	
						Billback
						INNER JOIN Billback_Program
						ON
						(
							(Billback_Program.Billback_ID = Billback.Billback_ID)
							AND
							(Billback_Program.Deleted = 0)
						)				
						INNER JOIN 	Billback_product
						ON
						(  (Billback_Product.Billback_ID = '#Billback_ID#') 
							AND
							(Billback_product.Billback_Program_ID = Billback_Program.Billback_Program_ID)
							AND
							(Billback_product.Deleted = 0)
						)
						INNER JOIN Billback_Product_Detail
						ON
						(    Billback_Product_Detail.Billback_ID = '#Billback_ID#' 
								AND
							(Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID)
							AND
							(Billback_Product_Detail.Deleted = 0)
							AND
							(Billback_Product_Detail.BB_Rate IS NOT NULL)
							AND
							(LEN(Billback_Product_Detail.BB_Rate) > 0)
							AND
							(ISNUMERIC(Billback_Product_Detail.BB_Rate) = 1)
							AND
							(CAST(Billback_Product_Detail.BB_Rate AS Float) <> 0)
							AND
							(Billback_Product_Detail.BB_Product_Type_ID IN (1,2,5,11))
						)
						LEFT JOIN Contract_Main
						ON
						(
							(Contract_main.Contract_Main_ID = Billback_Program.Program_ID)
						)
						LEFT JOIN	Program_Control_Panel_Options
						ON
						(
							(Program_Control_Panel_Options.ProgramControl_Panel_Options_ID  = Contract_Main.ProgramType_ID)
						)	
					LEFT JOIN Billback_Operator
					  ON
						(
						 Billback.Billback_ID = Billback_Operator.Billback_ID
							AND Billback_Operator.Deleted = 0
						)
						
					LEFT JOIN Billback_Broker
					  ON
						(
						 Billback.Billback_ID = Billback_Broker.Billback_ID
							AND Billback_Broker.Deleted = 0
						)
					WHERE
						Billback.Billback_ID = '#Billback_ID#'				
					GROUP BY Program_Control_Panel_Options.Generic_Type, Billback_Product_Detail.BB_Product_Type_ID
					ORDER BY Billback_Product_Detail.BB_Product_Type_ID
			</CFQUERY>
			<!------
			BB_D_GROWTH_RATE_DEV
			saru says:
			BB_D_GROWTH_VOLUME_DEV
			----->
			<CFSET Fixed_Step_Count = ListLen(VALIDATION_STEPS, ",")>
			<CFOUTPUT QUERY="Check_Discount_Type" GROUP="BB_Product_Type_ID">
				<CFIF this_Count GT 0>
					<CFSET thisRebateType = ListGetAt(Step_Discount_Type_List, BB_Product_Type_ID)>
					<CFIF LEN(Trim(thisRebateType)) GT 0>
						<CFSET rate_Step=Fixed_Step_Count + ((BB_Product_Type_ID - 1) * 2) + 1>
						<CFSET vol_Step=Fixed_Step_Count + ((BB_Product_Type_ID - 1) * 2) + 2>
						
						<CFSET VALIDATION_STEPS = ListAppend(VALIDATION_STEPS, rate_Step , ",")>			
						<CFIF BB_Product_Type_ID EQ 4>
							<CFSET VALIDATION_STEPS_DESC= ListAppend(VALIDATION_STEPS_DESC, "Growth Amount", ",")>
						<CFELSE>
							<CFSET VALIDATION_STEPS_DESC= ListAppend(VALIDATION_STEPS_DESC, "#thisRebateType# Rate", ",")>
							<CFSET added_Volume=0>			
							<CFOUTPUT>
								<CFIF NOT added_Volume>
									<CFIF Generic_Type EQ DEVIATION_CONSTANTS_Trade_Shelter OR ListFindNoCase(DEVIATION_CONSTANTS_Operator_Deviated, Generic_Type) NEQ 0 OR (Associated_Ship_TO NEQ "" AND Associated_Ship_TO NEQ "00000000-0000-0000-0000-000000000000")>
										<CFIF BB_Product_Type_ID EQ 4 AND Generic_Type EQ DEVIATION_CONSTANTS_Trade_Shelter>
											<CFSET VALIDATION_STEPS = ListAppend(VALIDATION_STEPS, vol_Step , ",")>
											<CFSET VALIDATION_STEPS_DESC= ListAppend(VALIDATION_STEPS_DESC, "#thisRebateType# Volume", ",")>
											<CFSET added_Volume=1>
										<CFELSEIF BB_Product_Type_ID NEQ 4>
											<CFSET VALIDATION_STEPS = ListAppend(VALIDATION_STEPS, vol_Step , ",")>
											<CFSET VALIDATION_STEPS_DESC= ListAppend(VALIDATION_STEPS_DESC, "#thisRebateType# Volume", ",")>
											<CFSET added_Volume=1>
										</CFIF>
										
									</CFIF>
								</CFIF>
							</CFOUTPUT>						
						</CFIF>
					</CFIF>
				</CFIF>
			</CFOUTPUT>
		
			<CFIF Get_Program_Growth.recordCount GT 0>
				<CFSET VALIDATION_STEPS = ListAppend(VALIDATION_STEPS, 14 , ",")>
				<CFSET VALIDATION_STEPS_DESC= ListAppend(VALIDATION_STEPS_DESC, "Total Growth Amount", ",")>
			</CFIF>
		
		
			<CFIF Get_Program_Lumpsum.recordCount GT 0>
				<CFSET VALIDATION_STEPS = ListAppend(VALIDATION_STEPS, 15 , ",")>
				<CFSET VALIDATION_STEPS_DESC= ListAppend(VALIDATION_STEPS_DESC, "Total #Application.LumpsumLabel# Amount", ",")>
			</CFIF>
			
			<CFSET THIS_STEP_LEVEL_IN_LIST=ListFindNoCase(VALIDATION_STEPS, STEP_LEVEL, ",")>
			<CFSET MAX_LEVEL=ListLen(VALIDATION_STEPS, ",")>
			<CFIF THIS_STEP_LEVEL_IN_LIST GT MAX_LEVEL>
				<CFSET STEP_LEVEL = 1>
			</CFIF>
			<CFIF BB_Status GT 2>
				<CFSET STEP_LEVEL=ListGetAt(VALIDATION_STEPS, MAX_LEVEL, ",")>
				<CFSET FIXED_STEP_LEVEL=ListGetAt(VALIDATION_STEPS, MAX_LEVEL, ",")>
			</CFIF>
			
			<CFSET THIS_STEP_LEVEL_IN_LIST=ListFindNoCase(VALIDATION_STEPS, STEP_LEVEL, ",")>
			<CFSET FIXED_STEP_LEVEL=STEP_LEVEL>
		</CFIF><!---------- <CFIF NOT Deviation_Show_Expected_Values>		 ------------------->
		
		
		
		
		
		<CFIF (NOT Deviation_Show_Expected_Values) AND (BB_UP NEQ 1)>
		<!--------------------- call stored proc -------------------------------->
			<CFSWITCH EXPRESSION="#FIXED_STEP_LEVEL#">
				<CFCASE VALUE="0">
					<CFIF RUN_ROUTINES>
					<CFQUERY  dataSource="#application.datasource#" NAME="SP_1">
						EXEC BB_D_PRODUCT_DEVIATION '#Billback_ID#'
					</CFQUERY>
					</CFIF>
					
					<CFSET SHOW_PAYEE_UNKNOWN=0>
					<CFSET SHOW_PROGRAM_PNF=0>
					<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=0>
					<CFSET SHOW_PROGRAM_DATE_MISMATCH=0>
					<CFSET SHOW_PRODUCT_UNKNOWN=1>
					<CFSET SHOW_DISCOUNT_UN_AUTH=1>
					<CFSET SHOW_DISCOUNT_RATE=0>
					<CFSET SHOW_DISCOUNT_VOLUME=0>
					<CFSET SHOW_DISCOUNT_DATE_OVERLAP=0>
					<CFSET SHOW_DISCOUNT_RATE="">
					<CFSET SHOW_DISCOUNT_VOLUME="">
				</CFCASE>
				<CFCASE VALUE="2">
					<CFIF RUN_ROUTINES>
					<CFQUERY  dataSource="#application.datasource#" NAME="SP_2">
					EXEC BB_D_PROGRAM_DEVIATION '#Billback_ID#'
					</CFQUERY>
					</CFIF>
					
					<CFSET SHOW_PAYEE_UNKNOWN=0>
					<CFSET SHOW_PROGRAM_PNF=1>
					<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
					<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
					<CFSET SHOW_PRODUCT_UNKNOWN=1>
					<CFSET SHOW_DISCOUNT_UN_AUTH=1>
					<CFSET SHOW_DISCOUNT_RATE=0>
					<CFSET SHOW_DISCOUNT_VOLUME=0>
					<CFSET SHOW_DISCOUNT_DATE_OVERLAP=0>
					<CFSET SHOW_DISCOUNT_RATE="">
					<CFSET SHOW_DISCOUNT_VOLUME="">
				</CFCASE>
				<CFCASE VALUE="3">
					<CFIF RUN_ROUTINES>
					<CFQUERY  dataSource="#application.datasource#" NAME="SP_3">
					EXEC BB_D_OVERLAP_DEVIATION '#Billback_ID#'
					</CFQUERY>
					</CFIF>
					
					<CFSET SHOW_PAYEE_UNKNOWN=1>
					<CFSET SHOW_PROGRAM_PNF=1>
					<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
					<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
					<CFSET SHOW_PRODUCT_UNKNOWN=1>
					<CFSET SHOW_DISCOUNT_UN_AUTH=1>
					<CFSET SHOW_DISCOUNT_RATE=0>
					<CFSET SHOW_DISCOUNT_VOLUME=0>
					<CFSET SHOW_DISCOUNT_DATE_OVERLAP=1>
					<CFSET SHOW_DISCOUNT_RATE="">
					<CFSET SHOW_DISCOUNT_VOLUME="">
				</CFCASE>
				<CFCASE VALUE="4">		
					<CFIF RUN_ROUTINES>
					<CFQUERY  dataSource="#application.datasource#" NAME="SP_3">
					EXEC BB_D_FIXED_RATE_DEV '#Billback_ID#'
					</CFQUERY>
					</CFIF>
					
					<CFSET SHOW_PAYEE_UNKNOWN=1>
					<CFSET SHOW_PROGRAM_PNF=1>
					<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
					<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
					<CFSET SHOW_PRODUCT_UNKNOWN=1>
					<CFSET SHOW_DISCOUNT_UN_AUTH=1>
					<CFSET SHOW_DISCOUNT_RATE=0>
					<CFSET SHOW_DISCOUNT_VOLUME=0>
					<CFSET SHOW_DISCOUNT_DATE_OVERLAP=1>
					<CFSET SHOW_DISCOUNT_RATE="1">
					<CFSET SHOW_DISCOUNT_VOLUME="">
				</CFCASE>
				<CFCASE VALUE="5">
					<CFIF RUN_ROUTINES>
					<CFQUERY  dataSource="#application.datasource#" NAME="SP_3">
					EXEC BB_D_FIXED_VOLUME_DEV '#Billback_ID#'
					</CFQUERY>
					</CFIF>
					
					<CFSET SHOW_PAYEE_UNKNOWN=1>
					<CFSET SHOW_PROGRAM_PNF=1>
					<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
					<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
					<CFSET SHOW_PRODUCT_UNKNOWN=1>
					<CFSET SHOW_DISCOUNT_UN_AUTH=1>
					<CFSET SHOW_DISCOUNT_RATE=0>
					<CFSET SHOW_DISCOUNT_VOLUME=0>
					<CFSET SHOW_DISCOUNT_DATE_OVERLAP=1>
					<CFSET SHOW_DISCOUNT_RATE="1">
					<CFSET SHOW_DISCOUNT_VOLUME="1">
				</CFCASE>
				<CFCASE VALUE="6">
					<CFIF RUN_ROUTINES>
					<CFQUERY  dataSource="#application.datasource#" NAME="SP_3">
					EXEC BB_D_REBATE_RATE_DEV '#Billback_ID#'
					</CFQUERY>
					</CFIF>
					
					<CFSET SHOW_PAYEE_UNKNOWN=1>
					<CFSET SHOW_PROGRAM_PNF=1>
					<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
					<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
					<CFSET SHOW_PRODUCT_UNKNOWN=1>
					<CFSET SHOW_DISCOUNT_UN_AUTH=1>
					<CFSET SHOW_DISCOUNT_RATE=0>
					<CFSET SHOW_DISCOUNT_VOLUME=0>
					<CFSET SHOW_DISCOUNT_DATE_OVERLAP=1>
					<CFSET SHOW_DISCOUNT_RATE="1,2">
					<CFSET SHOW_DISCOUNT_VOLUME="1">
				</CFCASE>
				<CFCASE VALUE="7">
					<CFIF RUN_ROUTINES>
					<CFQUERY  dataSource="#application.datasource#" NAME="SP_3">
					EXEC BB_D_REBATE_VOLUME_DEV '#Billback_ID#'
					</CFQUERY>
					</CFIF>
					
					<CFSET SHOW_PAYEE_UNKNOWN=1>
					<CFSET SHOW_PROGRAM_PNF=1>
					<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
					<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
					<CFSET SHOW_PRODUCT_UNKNOWN=1>
					<CFSET SHOW_DISCOUNT_UN_AUTH=1>
					<CFSET SHOW_DISCOUNT_RATE=0>
					<CFSET SHOW_DISCOUNT_VOLUME=0>
					<CFSET SHOW_DISCOUNT_DATE_OVERLAP=1>
					<CFSET SHOW_DISCOUNT_RATE="1,2">
					<CFSET SHOW_DISCOUNT_VOLUME="1,2">
				</CFCASE>	
				<CFCASE VALUE="12">
					<CFIF RUN_ROUTINES>
					<CFQUERY  dataSource="#application.datasource#" NAME="SP_3">
					EXEC BB_D_FORMULA_RATE_DEV '#Billback_ID#'
					</CFQUERY>
					</CFIF>
					
					<CFSET SHOW_PAYEE_UNKNOWN=1>
					<CFSET SHOW_PROGRAM_PNF=1>
					<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
					<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
					<CFSET SHOW_PRODUCT_UNKNOWN=1>
					<CFSET SHOW_DISCOUNT_UN_AUTH=1>
					<CFSET SHOW_DISCOUNT_RATE=0>
					<CFSET SHOW_DISCOUNT_VOLUME=0>
					<CFSET SHOW_DISCOUNT_DATE_OVERLAP=1>
					<CFSET SHOW_DISCOUNT_RATE="1,2,5">
					<CFSET SHOW_DISCOUNT_VOLUME="1,2">
				</CFCASE>
				<CFCASE VALUE="13">
					<CFIF RUN_ROUTINES>
					<CFQUERY  dataSource="#application.datasource#" NAME="SP_3">
					EXEC BB_D_FORMULA_VOLUME_DEV '#Billback_ID#'
					</CFQUERY>
					</CFIF>
					
					<CFSET SHOW_PAYEE_UNKNOWN=1>
					<CFSET SHOW_PROGRAM_PNF=1>
					<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
					<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
					<CFSET SHOW_PRODUCT_UNKNOWN=1>
					<CFSET SHOW_DISCOUNT_UN_AUTH=1>
					<CFSET SHOW_DISCOUNT_RATE=0>
					<CFSET SHOW_DISCOUNT_VOLUME=0>
					<CFSET SHOW_DISCOUNT_DATE_OVERLAP=1>
					<CFSET SHOW_DISCOUNT_RATE="1,2,4,5">
					<CFSET SHOW_DISCOUNT_VOLUME="1,2,4,5">
				</CFCASE>
				<CFCASE VALUE="14">
					<CFIF RUN_ROUTINES>
					<CFQUERY  dataSource="#application.datasource#" NAME="SP_3">
					EXEC BB_D_GROWTH_RATE_DEV '#Billback_ID#'
					</CFQUERY>
					</CFIF>
					
					<CFSET SHOW_PAYEE_UNKNOWN=1>
					<CFSET SHOW_PROGRAM_PNF=1>
					<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
					<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
					<CFSET SHOW_PRODUCT_UNKNOWN=1>
					<CFSET SHOW_DISCOUNT_UN_AUTH=1>
					<CFSET SHOW_DISCOUNT_RATE=0>
					<CFSET SHOW_DISCOUNT_VOLUME=0>
					<CFSET SHOW_DISCOUNT_DATE_OVERLAP=1>
					<CFSET SHOW_DISCOUNT_RATE="1,2,5">
					<CFSET SHOW_DISCOUNT_VOLUME="1,2,5">
					<CFSET SHOW_GROWTH=1>
					
					
					<!---------------------- Get All Growth ----------------------------->
					<CFQUERY  dataSource="#application.datasource#" NAME="Get_Program_Growth">
						SELECT	SUM(CAST(Billback_Product_Detail.BB_Rate AS FLOAT)) AS Total_Growth, 
								Billback_Program.Billback_Program_ID,
								CASE
								WHEN BB_Growth_Program.Deviated_Amount IS NULL THEN
									NULL
								WHEN (BB_Growth_Program.Deviated_Amount * -1) > SUM(CAST(Billback_Product_Detail.BB_Rate AS FLOAT)) THEN
									SUM(CAST(Billback_Product_Detail.BB_Rate AS FLOAT))
								WHEN BB_Growth_Program.Deviated_Amount < 0 THEN
									BB_Growth_Program.Deviated_Amount * -1
								ELSE
									0
								END AS Growth_Deviation,
								CASE
								WHEN BB_Growth_Program.Deviated_Amount IS NULL THEN
									NULL
								WHEN (BB_Growth_Program.Deviated_Amount * -1) > SUM(CAST(Billback_Product_Detail.BB_Rate AS FLOAT)) THEN
									100
								WHEN BB_Growth_Program.Deviated_Amount < 0 THEN
									(BB_Growth_Program.Deviated_Amount * -1 * 100) / SUM(CAST(Billback_Product_Detail.BB_Rate AS FLOAT))
								ELSE
									0
								END AS Growth_Deviation_Percent,
								ISNull(Expected_Amount, 0) AS Expected_Amount,
								ISNull(BB_Growth_Amount, 0) AS BB_Growth_Amount,
								Approved_Amount AS BB_Approved_Amount,
								ISNull(Manual_Growth_Amount, 0) AS Manual_Growth_Amount
						FROM	
								Billback
								INNER JOIN Billback_Program
								ON
								(
									(Billback_Program.Billback_ID = Billback.Billback_ID)
									AND
									(Billback_Program.Deleted = 0)
								)			
								INNER JOIN 	Billback_product
								ON
								(  (Billback_Product.Billback_ID = '#Billback_ID#') 
									AND
									(Billback_product.Billback_Program_ID = Billback_Program.Billback_Program_ID)
									AND
									(Billback_product.Deleted = 0)
								)
								INNER JOIN Billback_Product_Detail
								ON
								(   Billback_Product_Detail.Billback_ID = '#Billback_ID#' 
										AND
									(Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID)
									AND
									(Billback_Product_Detail.Deleted = 0)
									AND
									(Billback_Product_Detail.BB_Rate IS NOT NULL)
									AND
									(LEN(Billback_Product_Detail.BB_Rate) > 0)
									AND
									(ISNUMERIC(Billback_Product_Detail.BB_Rate) = 1)
									AND
									(CAST(Billback_Product_Detail.BB_Rate AS Float) <> 0)
									AND
									(Billback_Product_Detail.BB_Product_Type_ID = 4)
								)
								LEFT JOIN BB_Growth_Program
								ON
								(
									(BB_Growth_Program.Billback_Program_ID = Billback_Program.Billback_Program_ID)
									AND
									(BB_Growth_Program.Deleted = 0)
								)			
							WHERE
								Billback.Billback_ID = '#Billback_ID#'				
							GROUP BY Billback_Program.Billback_Program_ID, BB_Growth_Program.Deviated_Amount
									, Expected_Amount, BB_Growth_Amount, Approved_Amount, Manual_Growth_Amount
					</CFQUERY>
				</CFCASE>	
				<CFCASE VALUE="15">
					<CFIF RUN_ROUTINES>
					<CFQUERY  dataSource="#application.datasource#" NAME="SP_3">
					EXEC BB_D_LUMPSUM_DEV '#Billback_ID#'
					</CFQUERY>
					</CFIF>
					
					<CFSET SHOW_PAYEE_UNKNOWN=1>
					<CFSET SHOW_PROGRAM_PNF=1>
					<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
					<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
					<CFSET SHOW_PRODUCT_UNKNOWN=1>
					<CFSET SHOW_DISCOUNT_UN_AUTH=1>
					<CFSET SHOW_DISCOUNT_RATE=0>
					<CFSET SHOW_DISCOUNT_VOLUME=0>
					<CFSET SHOW_DISCOUNT_DATE_OVERLAP=1>
					<CFSET SHOW_DISCOUNT_RATE="1,2,4,5">
					<CFSET SHOW_DISCOUNT_VOLUME="1,2,4,5">
					<CFSET SHOW_GROWTH=1>
					<CFSET SHOW_LUMPSUM=1>		
					
					
				<!---------------------- LumpsUm --------------------------->
					<cfquery name="Get_Program_Lumpsum" datasource="#application.datasource#">
					SELECT     	Billback_Program_Lumpsum_Component.Billback_Program_ID
								, SUM(CAST(Amount AS FLOAT)) Total_Program_Lumpsum_Amount
								, CASE
								WHEN BB_Lump_Sums.Lump_Sum_Deviation IS NULL THEN
									NULL
								WHEN (BB_Lump_Sums.Lump_Sum_Deviation * -1) > SUM(CAST(Amount AS FLOAT)) THEN
									SUM(CAST(Amount AS FLOAT))
								WHEN BB_Lump_Sums.Lump_Sum_Deviation < 0 THEN
									BB_Lump_Sums.Lump_Sum_Deviation * -1
								ELSE
									0
								END AS Lumpsum_Deviation,
								CASE
								WHEN BB_Lump_Sums.Lump_Sum_Deviation IS NULL THEN
									NULL
								WHEN (BB_Lump_Sums.Lump_Sum_Deviation * -1) > SUM(CAST(Amount AS FLOAT)) THEN
									100
								WHEN BB_Lump_Sums.Lump_Sum_Deviation < 0 THEN
									(BB_Lump_Sums.Lump_Sum_Deviation * -1 * 100) / SUM(CAST(Amount AS FLOAT))
								ELSE
									0
								END AS Lumpsum_Deviation_Percent,
								ISNull(BB_Lump_Sums.LS_Expected_Amount, 0) AS Expected,
								ISNull(LS_Billback_Amount, 0) AS Billback,
								LS_Approved_Amount AS Approved,
								ISNull(BB_Lump_Sums.LS_Manual_Amount, 0) AS Manual
					FROM       Billback_Program_Lumpsum_Component						
								LEFT JOIN BB_Lump_Sums
								ON
								(
									(BB_Lump_Sums.Billback_Program_ID = Billback_Program_Lumpsum_Component.Billback_Program_ID)
								)
					WHERE 
							(Billback_Program_Lumpsum_Component.Amount IS NOT NULL)
							AND
							(LEN(Billback_Program_Lumpsum_Component.Amount) > 0)
							AND
							(ISNUMERIC(Billback_Program_Lumpsum_Component.Amount) = 1)
							AND
							(CAST(Billback_Program_Lumpsum_Component.Amount AS Float) > 0)
							AND
							Billback_Program_Lumpsum_Component.Billback_ID 		= '#Billback_ID#'
							AND
							Billback_Program_Lumpsum_Component.Deleted 			= 0
					GROUP BY Billback_Program_Lumpsum_Component.Billback_Program_ID, BB_Lump_Sums.Lump_Sum_Deviation
							, BB_Lump_Sums.LS_Expected_Amount, LS_Billback_Amount, LS_Approved_Amount, BB_Lump_Sums.LS_Manual_Amount
					ORDER BY Billback_Program_Lumpsum_Component.Billback_Program_ID
					</CFQUERY>
					
				</CFCASE>
				<CFCASE VALUE="24">
					<CFIF RUN_ROUTINES>
					<CFQUERY  dataSource="#application.datasource#" NAME="SP_3">
					EXEC BB_D_BID_REQUEST_RATE_DEV '#Billback_ID#'
					</CFQUERY>
					</CFIF>
					
					<CFSET SHOW_PAYEE_UNKNOWN=1>
					<CFSET SHOW_PROGRAM_PNF=1>
					<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
					<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
					<CFSET SHOW_PRODUCT_UNKNOWN=1>
					<CFSET SHOW_DISCOUNT_UN_AUTH=1>
					<CFSET SHOW_DISCOUNT_RATE=0>
					<CFSET SHOW_DISCOUNT_VOLUME=0>
					<CFSET SHOW_DISCOUNT_DATE_OVERLAP=1>
					<CFSET SHOW_DISCOUNT_RATE="1,2,5,11">
					<CFSET SHOW_DISCOUNT_VOLUME="1,2,5">
					<CFSET SHOW_GROWTH=1>
					<CFSET SHOW_LUMPSUM=1>
				</CFCASE>
				<CFCASE VALUE="25">
					<CFIF RUN_ROUTINES>
					<CFQUERY  dataSource="#application.datasource#" NAME="SP_3">
					EXEC BB_D_BID_REQUEST_VOLUME_DEV '#Billback_ID#'
					</CFQUERY>
					</CFIF>
					
					<CFSET SHOW_PAYEE_UNKNOWN=1>
					<CFSET SHOW_PROGRAM_PNF=1>
					<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
					<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
					<CFSET SHOW_PRODUCT_UNKNOWN=1>
					<CFSET SHOW_DISCOUNT_UN_AUTH=1>
					<CFSET SHOW_DISCOUNT_RATE=0>
					<CFSET SHOW_DISCOUNT_VOLUME=0>
					<CFSET SHOW_DISCOUNT_DATE_OVERLAP=1>
					<CFSET SHOW_DISCOUNT_RATE="1,2,4,5,11">
					<CFSET SHOW_DISCOUNT_VOLUME="1,2,4,5,11">
					<CFSET SHOW_GROWTH=1>
					<CFSET SHOW_LUMPSUM=1>
				</CFCASE>
				<CFDEFAULTCASE>
					<CFABORT>
				</CFDEFAULTCASE>
			</CFSWITCH>		
		<CFELSEIF BB_UP NEQ 1>
			<CFSET SHOW_PAYEE_UNKNOWN=1>
			<CFSET SHOW_PROGRAM_PNF=1>
			<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
			<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
			<CFSET SHOW_PRODUCT_UNKNOWN=1>
			<CFSET SHOW_DISCOUNT_UN_AUTH=1>
			<CFSET SHOW_DISCOUNT_RATE=0>
			<CFSET SHOW_DISCOUNT_VOLUME=0>
			<CFSET SHOW_DISCOUNT_DATE_OVERLAP=1>
			<CFSET SHOW_DISCOUNT_RATE="1,2,4,5,11">
			<CFSET SHOW_DISCOUNT_VOLUME="1,2,4,5,11">
			<CFSET SHOW_GROWTH=1>
			<CFSET SHOW_LUMPSUM=1>	
		</CFIF>
	<CFELSEIF Validation_Step_Version EQ 2>
		<CFIF NOT Deviation_Show_Expected_Values>					
			<CFSET VALIDATION_STEPS="1,2">
			<CFSET VALIDATION_STEPS_DESC="Known and Authorized Products&##44; Known Program&##44; Authorized Payee and Date Match,Known Payee and Product level Date Overlap">
			
			<CFSET Validation_Rate_List = "">
			<CFSET Validation_Volume_List = "">
			
			
			<CFSET FIXED_STEP_LEVEL=STEP_LEVEL>
			<CFQUERY  dataSource="#application.datasource#" NAME="Check_Discount_Type">
				SELECT	Count(Billback.BB_Code) AS this_Count, Billback_Product_Detail.BB_Product_Type_ID, Program_Control_Panel_Options.Generic_Type
				<!--- The billback may have an associated distributor when the payee is an operator OR broker. --->
				,CASE Billback.Billback_Payee_Type_ID
					WHEN 2
						THEN 
							Billback_Operator.Associated_Ship_to
					WHEN 3
						THEN				
							Billback_Broker.Associated_Ship_to
					ELSE
						NULL
					END

				As Associated_Ship_to

				FROM	
						Billback
						INNER JOIN Billback_Program
						ON
						(
							(Billback_Program.Billback_ID = Billback.Billback_ID)
							AND
							(Billback_Program.Deleted = 0)
						)				
						INNER JOIN 	Billback_product
						ON
						(   (Billback_Product.Billback_ID = '#Billback_ID#') 
							AND
							(Billback_product.Billback_Program_ID = Billback_Program.Billback_Program_ID)
							AND
							(Billback_product.Deleted = 0)
						)
						INNER JOIN Billback_Product_Detail
						ON
						(  Billback_Product_Detail.Billback_ID = '#Billback_ID#' 
								AND
							(Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID)
							AND
							(Billback_Product_Detail.Deleted = 0)
							AND
							(Billback_Product_Detail.BB_Rate IS NOT NULL)
							AND
							(LEN(Billback_Product_Detail.BB_Rate) > 0)
							AND
							(ISNUMERIC(Billback_Product_Detail.BB_Rate) = 1)
							AND
							(CAST(Billback_Product_Detail.BB_Rate AS Float) <> 0)
							AND
							(Billback_Product_Detail.BB_Product_Type_ID IN (1,2,5,11))
						)
						LEFT JOIN Contract_Main
						ON
						(
							(Contract_main.Contract_Main_ID = Billback_Program.Program_ID)
						)
						LEFT JOIN	Program_Control_Panel_Options
						ON
						(
							(Program_Control_Panel_Options.ProgramControl_Panel_Options_ID  = Contract_Main.ProgramType_ID)
						)		
						LEFT JOIN Billback_Operator
						ON
						(
							Billback.Billback_ID = Billback_Operator.Billback_ID
							AND Billback_Operator.Deleted = 0
						)
						LEFT JOIN Billback_Broker
						ON
						(
							Billback.Billback_ID = Billback_Broker.Billback_ID
							AND Billback_Broker.Deleted = 0
						)
					WHERE
						Billback.Billback_ID = '#Billback_ID#'				
					GROUP BY Program_Control_Panel_Options.Generic_Type, Billback_Product_Detail.BB_Product_Type_ID, Billback.Billback_Payee_Type_ID, 
					Billback_Operator.Associated_Ship_to, Billback_Broker.Associated_Ship_to
					ORDER BY  Billback_Product_Detail.BB_Product_Type_ID
			</CFQUERY>
				
			<CFSET Fixed_Step_Count = ListLen(VALIDATION_STEPS, ",")>
			<CFOUTPUT QUERY="Check_Discount_Type" GROUP="BB_Product_Type_ID">
				<CFIF this_Count GT 0>
					<CFSET thisRebateType = ListGetAt(Step_Discount_Type_List, BB_Product_Type_ID)>
					<CFIF LEN(Trim(thisRebateType)) GT 0>
						<CFSET rate_Step=Fixed_Step_Count + ((BB_Product_Type_ID - 1) * 2) + 1>
						<CFSET vol_Step=Fixed_Step_Count + ((BB_Product_Type_ID - 1) * 2) + 2>
						
						<CFSET VALIDATION_STEPS = ListAppend(VALIDATION_STEPS, rate_Step , ",")>			
						<CFIF BB_Product_Type_ID EQ 4>
							<CFSET VALIDATION_STEPS_DESC= ListAppend(VALIDATION_STEPS_DESC, "Growth Amount", ",")>
						<CFELSE>
							
							<CFSET added_Volume=0>			
							<CFOUTPUT>
								<CFIF NOT added_Volume>
									<CFIF Generic_Type EQ DEVIATION_CONSTANTS_Trade_Shelter OR ListFindNoCase(DEVIATION_CONSTANTS_Operator_Deviated, Generic_Type) NEQ 0 OR (Associated_Ship_TO NEQ "" AND Associated_Ship_TO NEQ "00000000-0000-0000-0000-000000000000")>
										<CFIF BB_Product_Type_ID NEQ 4>
											<CFSET Validation_Volume_List = ListAppend(Validation_Volume_List, BB_Product_Type_ID, ",")>
											<CFSET added_Volume=1>
										</CFIF>										
									</CFIF>
								</CFIF>
							</CFOUTPUT>
							<CFIF added_Volume>
								<CFSET VALIDATION_STEPS_DESC= ListAppend(VALIDATION_STEPS_DESC, "#thisRebateType# Rate and Volume", ",")>
							<CFELSE>
								<CFSET VALIDATION_STEPS_DESC= ListAppend(VALIDATION_STEPS_DESC, "#thisRebateType# Rate", ",")>
							</CFIF>
						</CFIF>
					</CFIF>
				</CFIF>
			</CFOUTPUT>
		
		
			<CFIF Get_Program_Growth.recordCount GT 0>
				<CFSET VALIDATION_STEPS = ListAppend(VALIDATION_STEPS, 14 , ",")>
				<CFSET VALIDATION_STEPS_DESC= ListAppend(VALIDATION_STEPS_DESC, "Total Growth Amount", ",")>
			</CFIF>
		
		
				<CFIF Get_Program_Lumpsum.recordCount GT 0>
				<CFSET VALIDATION_STEPS = ListAppend(VALIDATION_STEPS, 15 , ",")>
				<CFSET VALIDATION_STEPS_DESC= ListAppend(VALIDATION_STEPS_DESC, "Total #Application.LumpsumLabel# Amount", ",")>
			</CFIF>
			
			<CFSET THIS_STEP_LEVEL_IN_LIST=ListFindNoCase(VALIDATION_STEPS, STEP_LEVEL, ",")>
			<CFSET MAX_LEVEL=ListLen(VALIDATION_STEPS, ",")>
			<CFIF THIS_STEP_LEVEL_IN_LIST GT MAX_LEVEL>
				<CFSET STEP_LEVEL = 1>
			</CFIF>
			<CFIF Deviation_Ran_Date NEQ "" OR (BB_Status GT 2 OR SHOW_PRINT_VERSION OR SHOW_FAX_EMAIL_VERSION)>
				<CFSET STEP_LEVEL=ListGetAt(VALIDATION_STEPS, MAX_LEVEL, ",")>
				<CFSET FIXED_STEP_LEVEL=ListGetAt(VALIDATION_STEPS, MAX_LEVEL, ",")>
			</CFIF>
			
			<CFSET THIS_STEP_LEVEL_IN_LIST=ListFindNoCase(VALIDATION_STEPS, STEP_LEVEL, ",")>
			<CFSET FIXED_STEP_LEVEL=STEP_LEVEL>
		</CFIF><!---------- <CFIF NOT Deviation_Show_Expected_Values>		 ------------------->
		
		
		<CFIF isDefined("SHOW_STEP_PROGRESS")>
			<CFOUTPUT>			
			<TABLE HEIGHT="100%" ALIGN="center">
			<TR>
			<TD VALIGN="top" ALIGN="center">
				<TABLE ALIGN="center" CELLPADDING="4">
				<CFLOOP INDEX="i" FROM="1" TO="#MAX_LEVEL#">
					<TR>
						<TD STYLE="font-weight:bold;font-size:12px;">#i#.</TD>
						<TD STYLE="font-weight:bold;font-size:12px;">#ListGetAt(VALIDATION_STEPS_DESC, i, ",")#</TD>
						<TD>
						<CFIF THIS_STEP_LEVEL_IN_LIST LTE i>
							<IMG SRC="/Images/question_small.gif" BORDER="0">
						<CFELSE>
							<IMG SRC="/Images/yes_small.gif" BORDER="0">
						</CFIF>
						</TD>
					</TR>
				</CFLOOP>
				</TABLE>
			</TD>
			</TR>
			</TABLE>
			</CFOUTPUT>
			<CFFLUSH>
		</CFIF>
		
		
		<CFIF (NOT Deviation_Show_Expected_Values) AND (BB_UP NEQ 1)>
		<!--------------------- call stored proc -------------------------------->
			<CFSWITCH EXPRESSION="#FIXED_STEP_LEVEL#">		
				<CFCASE VALUE="0">
					<CFSET SHOW_PAYEE_UNKNOWN=1>
					<CFSET SHOW_PROGRAM_PNF=1>
					<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
					<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
					<CFSET SHOW_PRODUCT_UNKNOWN=1>
					<CFSET SHOW_DISCOUNT_UN_AUTH=1>
					<CFSET SHOW_DISCOUNT_RATE=0>
					<CFSET SHOW_DISCOUNT_VOLUME=0>
					<CFSET SHOW_DISCOUNT_DATE_OVERLAP=1>
					<CFSET SHOW_DISCOUNT_RATE="1,2,4,5,11">
					<CFSET SHOW_DISCOUNT_VOLUME="1,2,4,5,11">
					<CFSET SHOW_GROWTH=1>
					<CFSET SHOW_LUMPSUM=1>	
				</CFCASE>		
				<CFCASE VALUE="1">
					<CFIF RUN_ROUTINES AND Call_From_DeviationDotCfm EQ 0>
						<!--- <cftry> Try the routine twice --->
							<CFQUERY  dataSource="#application.datasource#" NAME="SP_2">
								EXEC BB_D_PRODUCT_DEVIATION '#Billback_ID#'
								EXEC BB_D_PROGRAM_DEVIATION '#Billback_ID#'
							</CFQUERY>
							<!--- since usually this is a timing issue, Transaction blocks have been added to SQl
							So lets try again
							<cfcatch type="database">
								<CFQUERY  dataSource="#application.datasource#" NAME="SP_2">
									EXEC BB_D_PRODUCT_DEVIATION '#Billback_ID#'
									EXEC BB_D_PROGRAM_DEVIATION '#Billback_ID#'
								</CFQUERY>
							
							</cfcatch>
						</cftry> --->
					</CFIF>
					
					<CFSET SHOW_PAYEE_UNKNOWN=0>
					<CFSET SHOW_PROGRAM_PNF=1>
					<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
					<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
					<CFSET SHOW_PRODUCT_UNKNOWN=1>
					<CFSET SHOW_DISCOUNT_UN_AUTH=1>
					<CFSET SHOW_DISCOUNT_RATE=0>
					<CFSET SHOW_DISCOUNT_VOLUME=0>
					<CFSET SHOW_DISCOUNT_DATE_OVERLAP=0>
					<CFSET SHOW_DISCOUNT_RATE="">
					<CFSET SHOW_DISCOUNT_VOLUME="">
				</CFCASE>
				<CFCASE VALUE="2">					
					<CFIF RUN_ROUTINES AND Call_From_DeviationDotCfm EQ 0>
					<CFQUERY  dataSource="#application.datasource#" NAME="SP_3">
					EXEC BB_D_OVERLAP_DEVIATION '#Billback_ID#'
					</CFQUERY>
					</CFIF>
					
					<CFSET SHOW_PAYEE_UNKNOWN=1>
					<CFSET SHOW_PROGRAM_PNF=1>
					<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
					<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
					<CFSET SHOW_PRODUCT_UNKNOWN=1>
					<CFSET SHOW_DISCOUNT_UN_AUTH=1>
					<CFSET SHOW_DISCOUNT_RATE=0>
					<CFSET SHOW_DISCOUNT_VOLUME=0>
					<CFSET SHOW_DISCOUNT_DATE_OVERLAP=1>
					<CFSET SHOW_DISCOUNT_RATE="">
					<CFSET SHOW_DISCOUNT_VOLUME="">
				</CFCASE>
				<CFCASE VALUE="3">		
					<!----- ((n * 2) - 1) + 2 ----->
					<CFIF RUN_ROUTINES AND Call_From_DeviationDotCfm EQ 0>
						<CFQUERY  dataSource="#application.datasource#" NAME="SP_3">
							EXEC BB_D_FIXED_RATE_DEV '#Billback_ID#'
						</CFQUERY>
						<CFIF ListFindNoCase(Validation_Volume_List, "1", ",")>
							<CFQUERY  dataSource="#application.datasource#" NAME="SP_3">
								EXEC BB_D_FIXED_VOLUME_DEV '#Billback_ID#'
							</CFQUERY>
						</CFIF>
					</CFIF>
					
					<CFSET SHOW_PAYEE_UNKNOWN=1>
					<CFSET SHOW_PROGRAM_PNF=1>
					<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
					<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
					<CFSET SHOW_PRODUCT_UNKNOWN=1>
					<CFSET SHOW_DISCOUNT_UN_AUTH=1>
					<CFSET SHOW_DISCOUNT_RATE=0>
					<CFSET SHOW_DISCOUNT_VOLUME=0>
					<CFSET SHOW_DISCOUNT_DATE_OVERLAP=1>
					<CFSET SHOW_DISCOUNT_RATE="1">
					<CFSET SHOW_DISCOUNT_VOLUME="1">
				</CFCASE>				
				<CFCASE VALUE="5">
					<!----- ((n * 2) - 1) + 2 ----->
					<CFIF RUN_ROUTINES AND Call_From_DeviationDotCfm EQ 0>
						<CFQUERY  dataSource="#application.datasource#" NAME="SP_3">
							EXEC BB_D_REBATE_RATE_DEV '#Billback_ID#'
						</CFQUERY>
						<CFIF ListFindNoCase(Validation_Volume_List, "2", ",")>
							<CFQUERY  dataSource="#application.datasource#" NAME="SP_3">
								EXEC BB_D_REBATE_VOLUME_DEV '#Billback_ID#'
							</CFQUERY>
						</CFIF>
					</CFIF>
					
					<CFSET SHOW_PAYEE_UNKNOWN=1>
					<CFSET SHOW_PROGRAM_PNF=1>
					<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
					<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
					<CFSET SHOW_PRODUCT_UNKNOWN=1>
					<CFSET SHOW_DISCOUNT_UN_AUTH=1>
					<CFSET SHOW_DISCOUNT_RATE=0>
					<CFSET SHOW_DISCOUNT_VOLUME=0>
					<CFSET SHOW_DISCOUNT_DATE_OVERLAP=1>
					<CFSET SHOW_DISCOUNT_RATE="1,2">
					<CFSET SHOW_DISCOUNT_VOLUME="1,2">
				</CFCASE>				
				<CFCASE VALUE="11">
					<!----- ((n * 2) - 1) + 2 ----->
					<CFIF RUN_ROUTINES AND Call_From_DeviationDotCfm EQ 0>
						<CFQUERY  dataSource="#application.datasource#" NAME="SP_3">
							EXEC BB_D_FORMULA_RATE_DEV '#Billback_ID#'
						</CFQUERY>
						<CFIF ListFindNoCase(Validation_Volume_List, "5", ",")>
							<CFQUERY  dataSource="#application.datasource#" NAME="SP_3">
								EXEC BB_D_FORMULA_VOLUME_DEV '#Billback_ID#'
							</CFQUERY>
						</CFIF>
					</CFIF>
					
					<CFSET SHOW_PAYEE_UNKNOWN=1>
					<CFSET SHOW_PROGRAM_PNF=1>
					<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
					<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
					<CFSET SHOW_PRODUCT_UNKNOWN=1>
					<CFSET SHOW_DISCOUNT_UN_AUTH=1>
					<CFSET SHOW_DISCOUNT_RATE=0>
					<CFSET SHOW_DISCOUNT_VOLUME=0>
					<CFSET SHOW_DISCOUNT_DATE_OVERLAP=1>
					<CFSET SHOW_DISCOUNT_RATE="1,2,5">
					<CFSET SHOW_DISCOUNT_VOLUME="1,2,5">
				</CFCASE>		
				<CFCASE VALUE="14">
					<CFIF RUN_ROUTINES AND Call_From_DeviationDotCfm EQ 0>
					<CFQUERY  dataSource="#application.datasource#" NAME="SP_3">
					EXEC BB_D_GROWTH_RATE_DEV '#Billback_ID#'
					</CFQUERY>
					</CFIF>
					
					<CFSET SHOW_PAYEE_UNKNOWN=1>
					<CFSET SHOW_PROGRAM_PNF=1>
					<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
					<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
					<CFSET SHOW_PRODUCT_UNKNOWN=1>
					<CFSET SHOW_DISCOUNT_UN_AUTH=1>
					<CFSET SHOW_DISCOUNT_RATE=0>
					<CFSET SHOW_DISCOUNT_VOLUME=0>
					<CFSET SHOW_DISCOUNT_DATE_OVERLAP=1>
					<CFSET SHOW_DISCOUNT_RATE="1,2,5">
					<CFSET SHOW_DISCOUNT_VOLUME="1,2,5">
					<CFSET SHOW_GROWTH=1>
					
					
					<!---------------------- Get All Growth ----------------------------->
					<CFQUERY  dataSource="#application.datasource#" NAME="Get_Program_Growth">
						SELECT	SUM(CAST(Billback_Product_Detail.BB_Rate AS FLOAT)) AS Total_Growth, 
								Billback_Program.Billback_Program_ID,
								CASE
								WHEN BB_Growth_Program.Deviated_Amount IS NULL THEN
									NULL
								WHEN (BB_Growth_Program.Deviated_Amount * -1) > SUM(CAST(Billback_Product_Detail.BB_Rate AS FLOAT)) THEN
									SUM(CAST(Billback_Product_Detail.BB_Rate AS FLOAT))
								WHEN BB_Growth_Program.Deviated_Amount < 0 THEN
									BB_Growth_Program.Deviated_Amount * -1
								ELSE
									0
								END AS Growth_Deviation,
								CASE
								WHEN BB_Growth_Program.Deviated_Amount IS NULL THEN
									NULL
								WHEN (BB_Growth_Program.Deviated_Amount * -1) > SUM(CAST(Billback_Product_Detail.BB_Rate AS FLOAT)) THEN
									100
								WHEN BB_Growth_Program.Deviated_Amount < 0 THEN
									(BB_Growth_Program.Deviated_Amount * -1 * 100) / SUM(CAST(Billback_Product_Detail.BB_Rate AS FLOAT))
								ELSE
									0
								END AS Growth_Deviation_Percent,
								ISNull(Expected_Amount, 0) AS Expected_Amount,
								ISNull(BB_Growth_Amount, 0) AS BB_Growth_Amount,
								Approved_Amount AS BB_Approved_Amount,
								ISNull(Manual_Growth_Amount, 0) AS Manual_Growth_Amount
						FROM	
								Billback
								INNER JOIN Billback_Program
								ON
								(
									(Billback_Program.Billback_ID = Billback.Billback_ID)
									AND
									(Billback_Program.Deleted = 0)
								)			
								INNER JOIN 	Billback_product
								ON
								( (Billback_Product.Billback_ID = '#Billback_ID#') 
									AND
									(Billback_product.Billback_Program_ID = Billback_Program.Billback_Program_ID)
									AND
									(Billback_product.Deleted = 0)
								)
								INNER JOIN Billback_Product_Detail
								ON
								(	(Billback_Product_Detail.Billback_ID = '#Billback_ID#') 
									AND
									(Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID)
									AND
									(Billback_Product_Detail.Deleted = 0)
									AND
									(Billback_Product_Detail.BB_Rate IS NOT NULL)
									AND
									(LEN(Billback_Product_Detail.BB_Rate) > 0)
									AND
									(ISNUMERIC(Billback_Product_Detail.BB_Rate) = 1)
									AND
									(CAST(Billback_Product_Detail.BB_Rate AS Float) <> 0)
									AND
									(Billback_Product_Detail.BB_Product_Type_ID = 4)
								)
								LEFT JOIN BB_Growth_Program
								ON
								(
									(BB_Growth_Program.Billback_Program_ID = Billback_Program.Billback_Program_ID)
									AND
									(BB_Growth_Program.Deleted = 0)
								)			
							WHERE
								Billback.Billback_ID = '#Billback_ID#'				
							GROUP BY Billback_Program.Billback_Program_ID, BB_Growth_Program.Deviated_Amount
									, Expected_Amount, BB_Growth_Amount, Approved_Amount, Manual_Growth_Amount
					</CFQUERY>
				</CFCASE>	
				<CFCASE VALUE="15">
					<CFIF RUN_ROUTINES AND Call_From_DeviationDotCfm EQ 0>
					<CFQUERY  dataSource="#application.datasource#" NAME="SP_3">
					EXEC BB_D_LUMPSUM_DEV '#Billback_ID#'
					</CFQUERY>
					</CFIF>
					
					<CFSET SHOW_PAYEE_UNKNOWN=1>
					<CFSET SHOW_PROGRAM_PNF=1>
					<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
					<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
					<CFSET SHOW_PRODUCT_UNKNOWN=1>
					<CFSET SHOW_DISCOUNT_UN_AUTH=1>
					<CFSET SHOW_DISCOUNT_RATE=0>
					<CFSET SHOW_DISCOUNT_VOLUME=0>
					<CFSET SHOW_DISCOUNT_DATE_OVERLAP=1>
					<CFSET SHOW_DISCOUNT_RATE="1,2,4,5">
					<CFSET SHOW_DISCOUNT_VOLUME="1,2,4,5">
					<CFSET SHOW_GROWTH=1>
					<CFSET SHOW_LUMPSUM=1>		
					
					
				<!---------------------- LumpsUm --------------------------->
					<cfquery name="Get_Program_Lumpsum" datasource="#application.datasource#">
					SELECT     	Billback_Program_Lumpsum_Component.Billback_Program_ID
								, SUM(CAST(Amount AS FLOAT)) Total_Program_Lumpsum_Amount
								, CASE
								WHEN BB_Lump_Sums.Lump_Sum_Deviation IS NULL THEN
									NULL
								WHEN (BB_Lump_Sums.Lump_Sum_Deviation * -1) > SUM(CAST(Amount AS FLOAT)) THEN
									SUM(CAST(Amount AS FLOAT))
								WHEN BB_Lump_Sums.Lump_Sum_Deviation < 0 THEN
									BB_Lump_Sums.Lump_Sum_Deviation * -1
								ELSE
									0
								END AS Lumpsum_Deviation,
								CASE
								WHEN BB_Lump_Sums.Lump_Sum_Deviation IS NULL THEN
									NULL
								WHEN (BB_Lump_Sums.Lump_Sum_Deviation * -1) > SUM(CAST(Amount AS FLOAT)) THEN
									100
								WHEN BB_Lump_Sums.Lump_Sum_Deviation < 0 THEN
									(BB_Lump_Sums.Lump_Sum_Deviation * -1 * 100) / SUM(CAST(Amount AS FLOAT))
								ELSE
									0
								END AS Lumpsum_Deviation_Percent,
								ISNull(BB_Lump_Sums.LS_Expected_Amount, 0) AS Expected,
								ISNull(LS_Billback_Amount, 0) AS Billback,
								LS_Approved_Amount AS Approved,
								ISNull(BB_Lump_Sums.LS_Manual_Amount, 0) AS Manual
					FROM       Billback_Program_Lumpsum_Component
								LEFT JOIN BB_Lump_Sums
								ON
								(
									(BB_Lump_Sums.Billback_Program_ID = Billback_Program_Lumpsum_Component.Billback_Program_ID)
								)
					WHERE 
							(Billback_Program_Lumpsum_Component.Amount IS NOT NULL)
							AND
							(LEN(Billback_Program_Lumpsum_Component.Amount) > 0)
							AND
							(ISNUMERIC(Billback_Program_Lumpsum_Component.Amount) = 1)
							AND
							(CAST(Billback_Program_Lumpsum_Component.Amount AS Float) > 0)
							AND
							Billback_Program_Lumpsum_Component.Billback_ID 		= '#Billback_ID#'
							AND
							Billback_Program_Lumpsum_Component.Deleted 			= 0
					GROUP BY Billback_Program_Lumpsum_Component.Billback_Program_ID, BB_Lump_Sums.Lump_Sum_Deviation
							, BB_Lump_Sums.LS_Expected_Amount, LS_Billback_Amount, LS_Approved_Amount, BB_Lump_Sums.LS_Manual_Amount
					ORDER BY Billback_Program_Lumpsum_Component.Billback_Program_ID
					</CFQUERY>
					
				</CFCASE>
				<CFCASE VALUE="23">
					<!----- ((n * 2) - 1) + 2 ----->
					<CFIF RUN_ROUTINES AND Call_From_DeviationDotCfm EQ 0>
						<CFQUERY  dataSource="#application.datasource#" NAME="SP_3">
							EXEC BB_D_BID_REQUEST_RATE_DEV '#Billback_ID#'
						</CFQUERY>
						<CFIF ListFindNoCase(Validation_Volume_List, "11", ",")>
							<CFQUERY  dataSource="#application.datasource#" NAME="SP_3">
								EXEC BB_D_BID_REQUEST_VOLUME_DEV '#Billback_ID#'
							</CFQUERY>
						</CFIF>
					</CFIF>
					
					<CFSET SHOW_PAYEE_UNKNOWN=1>
					<CFSET SHOW_PROGRAM_PNF=1>
					<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
					<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
					<CFSET SHOW_PRODUCT_UNKNOWN=1>
					<CFSET SHOW_DISCOUNT_UN_AUTH=1>
					<CFSET SHOW_DISCOUNT_RATE=0>
					<CFSET SHOW_DISCOUNT_VOLUME=0>
					<CFSET SHOW_DISCOUNT_DATE_OVERLAP=1>
					<CFSET SHOW_DISCOUNT_RATE="1,2,5,11">
					<CFSET SHOW_DISCOUNT_VOLUME="1,2,5,11">
					<CFSET SHOW_GROWTH=1>
					<CFSET SHOW_LUMPSUM=1>
				</CFCASE>
				<CFDEFAULTCASE>
					<CFABORT>
				</CFDEFAULTCASE>
			</CFSWITCH>		
		<CFELSEIF BB_UP NEQ 1>
			<CFSET SHOW_PAYEE_UNKNOWN=1>
			<CFSET SHOW_PROGRAM_PNF=1>
			<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
			<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
			<CFSET SHOW_PRODUCT_UNKNOWN=1>
			<CFSET SHOW_DISCOUNT_UN_AUTH=1>
			<CFSET SHOW_DISCOUNT_RATE=0>
			<CFSET SHOW_DISCOUNT_VOLUME=0>
			<CFSET SHOW_DISCOUNT_DATE_OVERLAP=1>
			<CFSET SHOW_DISCOUNT_RATE="1,2,4,5,11">
			<CFSET SHOW_DISCOUNT_VOLUME="1,2,4,5,11">
			<CFSET SHOW_GROWTH=1>
			<CFSET SHOW_LUMPSUM=1>	
		</CFIF>
	</CFIF>
	
	
	<CFIF VALIDATION_SHOW_ALL>
		<CFSET SHOW_PAYEE_UNKNOWN=1>
		<CFSET SHOW_PROGRAM_PNF=1>
		<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
		<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
		<CFSET SHOW_PRODUCT_UNKNOWN=1>
		<CFSET SHOW_DISCOUNT_UN_AUTH=1>
		<CFSET SHOW_DISCOUNT_RATE=0>
		<CFSET SHOW_DISCOUNT_VOLUME=0>
		<CFSET SHOW_DISCOUNT_DATE_OVERLAP=1>
		<CFSET SHOW_DISCOUNT_RATE="1,2,4,5,11">
		<CFSET SHOW_DISCOUNT_VOLUME="1,2,4,5,11">
		<CFSET SHOW_GROWTH=1>
		<CFSET SHOW_LUMPSUM=1>	
	</CFIF>