<!--- 
<CFQUERY NAME="UpdateAllocation" DATASOURCE="#Application.Datasource#">
	UPDATE 	Billback_Program
	SET 	Allocation_Method = #Allocation_Method#
	WHERE 	Program_ID = #MainProgID# AND 
			Billback_ID = '#Billback_ID#' AND 
			Deleted = 0
</CFQUERY>
 --->

<cfset useLakebaseForGetLumpInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program")>
<cfif useLakebaseForGetLumpInfo>
	<cftry>
		<cfset GetLumpInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_program", {
				"program_id" = "eq.#MainProgID#",
				"billback_id" = "eq.#Billback_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetLumpInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetLumpInfo>
<CFQUERY NAME="GetLumpInfo" DATASOURCE="#Application.Datasource#">
	SELECT * FROM Billback_Program WHERE Program_ID = #MainProgID# AND Billback_ID = '#Billback_ID#' AND Deleted = 0
</CFQUERY>
</cfif>

<CFSET DontGoIntoThisIteration = 0>
<CFIF ISDefined("GetProgramForEachAR3.LumpSum_Amt") AND GetProgramForEachAR3.LumpSum_Amt NEQ 0 AND GetLumpInfo.Allocation_Method NEQ 2>
	<CFSET DontGoIntoThisIteration = 1>
</CFIF>

<CFIF CheckIsChild.BB_Is_Child NEQ 1 AND DontGoIntoThisIteration EQ 0 AND (GetLumpInfo.Allocation_Method EQ 3 OR GetLumpInfo.Allocation_Method EQ 2)>

<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<!--- Fixed, Rebate and Formula --->
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<CFSET Fix_Reb_For_Amount = 0>
<CFQUERY NAME="GetAmount" DATASOURCE="#Application.Datasource#">
	SELECT 		CASE 
				WHEN d.BB_Product_UOM = 1 THEN 
					a.Item_Volume_Paid_CS * b.Paid_Rate_CS
				WHEN d.BB_Product_UOM = 2 THEN
					a.Item_Volume_Paid_LB * b.Paid_Rate_LB
				END AS RFF_Amount
				
	FROM 		BB_Item_Final a
	INNER JOIN 	BB_Item_Final_Detail b ON b.BB_Item_Final_ID = a.BB_Item_Final_ID AND
				b.Deleted = 0
	INNER JOIN 	Billback_Program c ON c.Billback_Program_ID = a.Billback_Program_ID AND 
				c.Deleted = 0
	INNER JOIN 	Billback_Product d ON a.Billback_Product_ID = d.Billback_Product_ID AND 
				d.Deleted = 0
	
	WHERE 		a.Billback_ID = '#Billback_ID#' AND 
				c.Program_ID = #MainProgID# AND
				a.Deleted = 0 
</CFQUERY>

<CFLOOP QUERY="GetAmount">
	<CFSET Fix_Reb_For_Amount = Fix_Reb_For_Amount + RFF_Amount>		
</CFLOOP>
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->

	
	
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<!--- Growth --->
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<CFSET GrowthAmount = 0>
<CFQUERY NAME="GetGrowth" DATASOURCE="#Application.Datasource#">		
	SELECT 		Paid_Amount
	FROM 		BB_Growth_Program a
	INNER JOIN 	Billback_Program b ON b.Billback_Program_ID = a.Billback_Program_ID AND 
				b.Deleted = 0
	WHERE 		a.Billback_ID = '#Billback_ID#' AND
				b.Program_ID = #MainProgID# AND
				a.Deleted = 0
</CFQUERY>
<CFIF GetGrowth.RecordCount GT 0>
	<CFSET GrowthAmount = GetGrowth.Paid_Amount>
</CFIF> 

<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->


<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<!--- Lump Sum --->
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<CFSET LumpSumAmount = 0>

<!--- <CFIF Allocation_Method EQ 3> --->
<CFQUERY NAME="GetLumpSum" DATASOURCE="#Application.Datasource#">		
	SELECT 		LS_Paid_Amount 
	FROM 		BB_Lump_Sums a
	INNER JOIN 	Billback_Program b ON b.Billback_Program_ID = a.Billback_Program_ID AND 
				b.Deleted = 0
	WHERE 		a.Billback_ID = '#Billback_ID#' AND
				b.Program_ID = #MainProgID# AND
				a.Deleted = 0	
</CFQUERY>	

<CFIF GetLumpSum.RecordCount GT 0>
	<CFSET LumpSumAmount = GetLumpSum.LS_Paid_Amount>
</CFIF> 
<!--- </CFIF> --->

<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->

<CFSET Prog_ID_TotAmt = Fix_Reb_For_Amount + GrowthAmount + LumpSumAmount>

<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<!--- Claim Adjustment --->
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->

<CFQUERY NAME="GetClaimTot" DATASOURCE="#Application.Datasource#">
	SELECT 		SUM(CAST(BB_Rate AS Float)) Claim_Tot
	FROM 		Billback_Product_Detail
	INNER JOIN 	Billback_Product ON Billback_Product.Billback_Product_ID = Billback_Product_Detail.Billback_Product_ID
	INNER JOIN 	Billback_Program ON Billback_Program.Billback_Program_ID = Billback_Product.Billback_Program_ID
	WHERE 		Billback_Product_Detail.Billback_ID = '#Billback_ID#' AND	
				Program_ID = #MainProgID# AND
				CAST(BB_Rate AS Float) < 0 AND
				Billback_Product_Detail.Deleted = 0 AND
				Billback_Product.Deleted = 0 AND
				Billback_Program.Deleted = 0								
</CFQUERY>
<CFIF GetClaimTot.Claim_Tot EQ "">
	<CFSET GetClaimTot.Claim_Tot = 0>
</CFIF>
<CFSET Prog_ID_TotAmt = Prog_ID_TotAmt + GetClaimTot.Claim_Tot>

<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->

	
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<!--- Log Allocation --->
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<!---
<CFSET TemplateManager = CreateObject("component","components.programs.template.TemplateManager")>

<CFQUERY NAME="GetProTemplate" DATASOURCE="#Application.Datasource#">
	SELECT 	ProgramType_ID 
	FROM 	Contract_main
	WHERE 	Contract_Main_ID = '#MainProgID#'
</CFQUERY>

<CFSET TemplateID = TemplateManager.getLatestTemplateId(GetProTemplate.ProgramType_ID )>


 <CFQUERY NAME="GetARFY" DATASOURCE="#Application.Datasource#">
	SELECT 	AR_From_Fiscal_Year,
			A_R
	FROM 	Program_Control_Panel_Options 
	WHERE 	ProgramControl_Panel_Options_ID = '#TemplateID#'
</CFQUERY>
 --->

<CFELSE>
	<CFIF CheckIsChild.BB_Is_Child EQ 1 AND DontGoIntoThisIteration EQ 0 AND (GetLumpInfo.Allocation_Method EQ 3 OR GetLumpInfo.Allocation_Method EQ 2)>
		<CFIF GetLumpInfo.Lumpsum_Amt NEQ 0 AND GetLumpInfo.Lumpsum_Only NEQ 1>
			<CFSET Prog_ID_TotAmt = CheckIsChild.Paid_Amount - GetLumpInfo.Lumpsum_Amt>
		<CFELSE>
			<CFSET Prog_ID_TotAmt = CheckIsChild.Paid_Amount>
		</CFIF>
	<CFELSEIF GetLumpInfo.LumpSum_Amt NEQ 0>
		<CFSET Prog_ID_TotAmt = GetLumpInfo.LumpSum_Amt>
	</CFIF>
	<!--- 
	<CFIF GetLumpInfo.LumpSum_Amt GT 0 >
	it should be here in second time 
		<CFSET Prog_ID_TotAmt = GetLumpInfo.LumpSum_Amt>
	<CFELSE>
		<CFSET Prog_ID_TotAmt = CheckIsChild.Paid_Amount>
	</CFIF>
	 --->
</CFIF>
 <CFQUERY NAME="GetARFY" DATASOURCE="#Application.Datasource#">
	SELECT 	AR_From_Fiscal_Year,
			A_R
	FROM 	Billback_Program
	WHERE 	Billback_ID = '#Billback_ID#' AND Program_ID = '#MainProgID#' AND Deleted = 0 
</CFQUERY>


<CFQUERY NAME="InsertCal" DATASOURCE="#Application.Datasource#">
	INSERT INTO 
	GL_Code_Fixed_Fund_Allocation_Cal	(	Billback_ID,
											Program_ID,											
											Fiscal_Year,
											A_R,
											Allocation_Method,
											Approved_Amount,
											Fund_Number,
											Fund_Description,
											Allocation		)
											
	SELECT 									DISTINCT
											'#Billback_ID#',
											'#MainProgID#',
											'#GetARFY.AR_From_Fiscal_Year#',
											'#GetARFY.A_R#',
											#Allocation_Method#,
											#Prog_ID_TotAmt#,
											GL_Code_Activation.Fund_Number,
											GL_Code_Activation.DESCRIPTION,
											GL_Code_Activation.Allocation
																						
	FROM									GL_Code_Activation
	
	<!--- 
	LEFT JOIN 								GL_Code_Pro_Group_Mapping ON GL_Code_Pro_Group_Mapping.Pref_Prod_Grp = GL_Code_Activation.PRODUCT_GROUP AND
											GL_Code_Pro_Group_Mapping.Fiscal_Year = GL_Code_Activation.Fiscal_Year AND
											GL_Code_Pro_Group_Mapping.Active_Data = 1 AND 
											GL_Code_Pro_Group_Mapping.Deleted = 0
	 --->
	
	WHERE									GL_Code_Activation.Fiscal_Year = '#GetARFY.AR_From_Fiscal_Year#' AND
											GL_Code_Activation.A_R = '#GetARFY.A_R#' AND
											GL_Code_Activation.Current_Active_Data = 1 AND
											GL_Code_Activation.Deleted = 0
</CFQUERY>

<CFQUERY NAME="UpdateItem" DATASOURCE="#Application.Datasource#">
	UPDATE 	GL_Code_Fixed_Fund_Allocation_Cal
	SET 	Surrogate_Item = (	SELECT Top 1 Surrogate_Item 
								FROM GL_Code_Pro_Group_Mapping
								INNER JOIN GL_Code_Activation ON GL_Code_Pro_Group_Mapping.Pref_Prod_Grp = GL_Code_Activation.PRODUCT_GROUP AND
											GL_Code_Pro_Group_Mapping.Fiscal_Year = GL_Code_Activation.Fiscal_Year AND
											GL_Code_Pro_Group_Mapping.Active_Data = 1 AND 
											GL_Code_Pro_Group_Mapping.Deleted = 0
								WHERE 		GL_Code_Activation.Fiscal_Year = '#GetARFY.AR_From_Fiscal_Year#' AND
											GL_Code_Activation.A_R = '#GetARFY.A_R#' AND
											GL_Code_Activation.Current_Active_Data = 1 AND
											GL_Code_Activation.Fund_Number = GL_Code_Fixed_Fund_Allocation_Cal.Fund_Number AND
											GL_Code_Activation.Deleted = 0	)
	WHERE 	Billback_ID = '#Billback_ID#' AND
			Program_ID = '#MainProgID#' AND
			Fiscal_Year = '#GetARFY.AR_From_Fiscal_Year#' AND
			A_R = '#GetARFY.A_R#' AND
			Allocation_Method = #Allocation_Method# AND
			Deleted = 0
</CFQUERY>
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
