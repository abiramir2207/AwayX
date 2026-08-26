<!------ 
Document		:	/GL_Code/GL_Code_IN_Billback/Fund_Allocation_For_Split_Child.cfm
Author			:	Deepa Kunnath
Date Created	:	June 22, 2005
Purpose			:	When splitting a billback, use the percentage of the allocated amount and distribute 
					the gl code allocation values for fund allocation alone.
					Only fund allocation is user entered.
					We don't have to do this for item allocation and fixed allocation because it is already system calculated value
Arguments		:	Parent_ID
Called from		: 
					/Billbacks/Approval/Split_BB.cfm

----->

<!------ for each child version created, loop thru and do the fund allocation inserts ----->
<cfquery name="qGetAllChildBillbacks" datasource="#application.datasource#">
	SELECT	Billback_ID Child_BB_ID, BB_Amount, BB_Code
	FROM	Billback
	WHERE	Deleted = 0
	AND		BB_Parent_ID = '#Parent_ID#'
	Order By BB_Code desc
</cfquery>
<cfquery name="qGetParentAmount" datasource="#application.datasource#">
	SELECT	BB_Amount
	FROM	Billback
	WHERE	Deleted = 0
	AND		Billback_ID = '#Parent_ID#'
</cfquery>

<cfset fromSplitBillbackPage = 1 />
<!------ Keep the variable value to be reset at the bottom of the page ----->
<cfif isDefined("Billback_ID")>
	<cfset currentBillback_IDInVarScope = Billback_ID />
</cfif>
<!------ loog thru each child billback ----->
<cfloop query="qGetAllChildBillbacks">

	<cfset Billback_ID = Child_BB_ID />
	<!------ the percentage of allocation for child billback is the percentage of the amount to the parent amount ----->
	<cfset childPercentage = request.app_general_functions.roundDecimalPlaces(qGetAllChildBillbacks.BB_Amount/qGetParentAmount.BB_Amount, 2) />	
	
	<!------ Set the form variables so that a fake form submit can be made to reuse the action page ----->
	<cfset FORM.Billback_ID = Billback_ID />
	<cfset FORM.FundSubmit = 1 />
	<cfset AppendVar_List = "" />
	<!------ Delete previous entries, new entries will be inserted below ----->
	<CFQUERY NAME="DeletePrevious" DATASOURCE="#Application.Datasource#">
		UPDATE 	GL_Code_Fixed_Fund_Allocation_Cal
		SET 	Deleted = 1
		WHERE 	Billback_ID = '#Billback_ID#' 
		AND		Allocation_Method = 3 
		AND 	Deleted = 0
	</CFQUERY>
	
	<CFQUERY NAME="DeleteAllo" DATASOURCE="#Application.Datasource#">
		UPDATE 	Gl_Code_Allocation
		SET 	Deleted = 1
		WHERE 	Billback_ID = '#Billback_ID#' 
		AND		Allocation_Method = 3
		AND 	Deleted = 0
	</CFQUERY>
	
	<!------ this query will be used in the file /GL_Code/GL_Code_IN_Billback/Fixed_Fund_Allocation_Cal.cfm ----->
	<CFQUERY NAME="CheckIsChild" DATASOURCE="#Application.Datasource#">
		SELECT 		* 
		FROM 		Billback 
		INNER JOIN 	BB_Approved ON BB_Approved.Billback_ID = Billback.Billback_ID
		WHERE 		Billback.Billback_ID = '#Billback_ID#'
	</CFQUERY>
	
	<CFQUERY NAME="GetARDetails3" DATASOURCE="#Application.Datasource#">
		SELECT 		DISTINCT 	Billback_Program.A_R,
								Billback_Program.AR_From_Fiscal_Year
											
		FROM 		Billback_Program 
		WHERE 		Billback_ID = '#Billback_ID#' AND Billback_Program.Deleted = 0 AND
					(Billback_Program.Allocation_Method = 3 OR ISNULL(Billback_Program.LumpSum_Amt,0) > 0)
		ORDER BY 	Billback_Program.AR_From_Fiscal_Year,Billback_Program.A_R
	</CFQUERY>
	
	<!------ loop thru each program in this billback ----->
	<CFSET ThisRecordCount = 0>
	<CFLOOP QUERY="GetARDetails3">
		<CFSET ThisRecordCount = ThisRecordCount + 1>
		<CFQUERY NAME="GetProgramForEachAR3" DATASOURCE="#Application.Datasource#">
			SELECT 		Billback_Program.Program_ID,
						Allocation_Method,
						ISNULL(LumpSum_Amt,0) AS LumpSum_Amt,
						LumpSum_Only
			FROM 		Billback_Program 
			WHERE 		Billback_ID = '#Billback_ID#' AND 
						Billback_Program.A_R = '#A_R#' AND 
						Billback_Program.AR_From_Fiscal_Year = '#AR_From_Fiscal_Year#' AND 
						(Billback_Program.Allocation_Method = 3  OR ISNULL(Billback_Program.LumpSum_Amt,0) > 0)AND
						Billback_Program.Deleted = 0
		</CFQUERY>
		<CFSET Program_List = VALUELIST(GetProgramForEachAR3.Program_ID)>
		<CFSET FundProgram_List = Program_List>
		<cfloop query="GetProgramForEachAR3">
			<cfset MainProgID = Program_ID />
			<!------ call Fixed_Fund_Allocation_Cal.cfm to get values inserted into fund and gl_code_allocation tables  ----->
			<CFINCLUDE TEMPLATE="/GL_Code/GL_Code_IN_Billback/Fixed_Fund_Allocation_Cal.cfm">
		</cfloop>
		
		<!------ the folloing is exactly same as /GL_Code/GL_Code_IN_Billback/Display_Fund_Allocation.cfm,
		but instead of giving a form and asking the user to input values, we calculate it using the parent allocation values,
		and set it to form variables, and then call the action page, so that it will process the request exactly like it was to process a form submit
		 ----->
		<CFQUERY NAME="DistinctARFYFund" DATASOURCE="#Application.Datasource#">
			SELECT 		DISTINCT	GL_Code_Fixed_Fund_Allocation_Cal.A_R,
									GL_Code_Fixed_Fund_Allocation_Cal.Fiscal_Year,
									GL_Code_Activation.A_R_DESCRIPTION
									
			FROM 		GL_Code_Fixed_Fund_Allocation_Cal 
			
			INNER JOIN 	GL_Code_Activation ON GL_Code_Activation.A_R = GL_Code_Fixed_Fund_Allocation_Cal.A_R AND
						GL_Code_Activation.Fiscal_Year = GL_Code_Fixed_Fund_Allocation_Cal.Fiscal_year AND
						GL_Code_Activation.Current_Active_Data = 1 AND
						GL_Code_Activation.Deleted = 0
						
			WHERE 		Billback_ID = '#Billback_ID#' AND 
						Program_ID IN (#Program_List#) AND 
						Allocation_Method = 3 AND
						GL_Code_Fixed_Fund_Allocation_Cal.Deleted = 0
			ORDER BY 	GL_Code_Fixed_Fund_Allocation_Cal.Fiscal_Year,GL_Code_Fixed_Fund_Allocation_Cal.A_R
		</CFQUERY>
		
		<CFLOOP QUERY="DistinctARFYFund">			
			
			<CFQUERY NAME="GetProgramsFund" DATASOURCE="#Application.Datasource#">
				SELECT 	DISTINCT Program_ID
				FROM	GL_Code_Fixed_Fund_Allocation_Cal
				WHERE 	Billback_ID = '#Billback_ID#' AND 
						Program_ID IN (#Program_List#) AND 
						Allocation_Method = 3 AND
						A_R = '#A_R#' AND
						Fiscal_Year = '#Fiscal_Year#' AND
						Deleted = 0
			</CFQUERY>
		
			<CFSET SameARProgs = VALUELIST(GetProgramsFund.Program_ID)>
			<cfset Current_Program_ID = GetProgramsFund.Program_ID />
			<CFSET AppendVar = VALUELIST(GetProgramsFund.Program_ID,"_")>
			<CFIF Not IsDefined("AppendVar_List") AND AppendVar_List NEQ "">
				<CFSET AppendVar_List = TRIM(AppendVar)>
			<CFELSE>
				<CFSET AppendVar_List = "#AppendVar_List#,#TRIM(AppendVar)#">
			</CFIF>		
			<CFSET DistAR = A_R>
			<CFSET DISTFY = Fiscal_Year>		
			<CFSET TotBBAmountFund = 0>
			
			<CFQUERY NAME="ProgramDetailsForFund" DATASOURCE="#Application.Datasource#">
				SELECT 		DISTINCT Contract_Title,Contract_Number
				FROM 		Contract_Main 
				WHERE		Contract_Main_ID IN (#SameARProgs#)
			</CFQUERY>
			
			<CFLOOP QUERY="GetProgramsFund">
				<CFQUERY NAME="GetBBAmountFund" DATASOURCE="#Application.Datasource#">
					SELECT 	Top 1 * 
					FROM 	GL_Code_Fixed_Fund_Allocation_Cal
					WHERE 	Billback_ID = '#Billback_ID#' AND 
							Program_ID = #Program_ID# AND 
							Allocation_Method = 3 AND
							A_R = '#DistAR#' AND
							Fiscal_Year = '#DISTFY#' AND
							Deleted = 0
				</CFQUERY>
				
				<CFSET TotBBAmountFund = TotBBAmountFund + GetBBAmountFund.Approved_Amount>
			</CFLOOP>
			
			<!------ Set the form variables so that a fake form submit can be made to reuse the action page ----->
			<cfset "FORM.TotAmountOF_#AppendVar#" = TotBBAmountFund />

			<CFQUERY NAME="FundDistinctFund" DATASOURCE="#Application.Datasource#">
				SELECT 	DISTINCT Fund_Number
				FROM 	GL_Code_Fixed_Fund_Allocation_Cal
				WHERE 	Billback_ID = '#Billback_ID#' AND 
						Program_ID IN (#SameARProgs#) AND 
						Allocation_Method = 3 AND
						A_R = '#DistAR#' AND
						Fiscal_Year = '#DISTFY#' AND
						Deleted = 0
			</CFQUERY>
			<CFSET FundNumber_List = VALUELIST(FundDistinctFund.Fund_Number)>
			<!------ Set the form variables so that a fake form submit can be made to reuse the action page ----->
			<cfset "FORM.Fund_List_Input_#AppendVar#" = FundNumber_List />
			
			<CFSET CheckPercentTot = 0>
			<CFLOOP QUERY="FundDistinctFund">				
				<CFQUERY NAME="GetARFund" DATASOURCE="#Application.Datasource#">
					SELECT 		*
					FROM 		GL_Code_Activation
					WHERE 		A_R = '#DistAR#' AND
								Fiscal_Year = '#DISTFY#' AND
								Fund_Number = '#Fund_Number#' AND
								Current_Active_Data = 1 AND
								deleted = 0
				</CFQUERY>
				
				<CFSET SOCA_Fund = "#GetARFund.COMPANY#-#GetARFund.LOCATION#-#GetARFund.COST_CENTER#-#GetARFund.NATURAL_ACCT#-#GetARFund.CHANNEL#-#GetARFund.PRODUCT_GROUP#-#GetARFund.FUND_NUMBER#">
				
				<!------ Get the allocated value from parent ----->
				<cfquery name="qGetParentAllocationValue" datasource="#application.datasource#">
					SELECT	Allocated_Fund_Amount
					FROM	GL_Code_Fixed_Fund_Allocation_Cal
					WHERE 	Billback_ID = '#Parent_ID#'
					AND		Program_ID = #Current_Program_ID# 
					AND		Fund_Number = '#Fund_Number#' 
					AND		Allocation_Method = 3 
					AND		Deleted = 0
				</cfquery>
				<cfset parentAllocationValue = qGetParentAllocationValue.Allocated_Fund_Amount />
				<cfset childAllocationValue = parentAllocationValue * childPercentage />
				
				<!------ Set the form variables so that a fake form submit can be made to reuse the action page ----->
				<cfset "Form.Allocated_Amount_For_#AppendVar#_#Fund_Number#" = childAllocationValue />
						
			</CFLOOP>		
		</CFLOOP>
	</CFLOOP>
	<!------ Set the form variables so that a fake form submit can be made to reuse the action page ----->
	<cfset FORM.Program_List_Input = AppendVar_List />
	
	<!------ all the necessary form variables are populated, now we can call the action page which will process teh form values ----->
	<cfinclude template="/GL_Code/GL_Code_IN_Billback/Display_Fund_Allocation_Action.cfm" />
	
	<CFQUERY NAME="UpdateSaved" DATASOURCE="#Application.Datasource#">
		UPDATE 	Gl_Code_Allocation
		SET 	Allocation_Saved = 1
		WHERE 	Billback_ID = '#Billback_ID#'
		AND		Deleted = 0	
	</CFQUERY>	
	
</cfloop>
<cfif isDefined("currentBillback_IDInVarScope")>
	<cfset Billback_ID = currentBillback_IDInVarScope />
</cfif>

