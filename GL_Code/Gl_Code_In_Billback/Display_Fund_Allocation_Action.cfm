

<CFSET FundAllocation_Tot = 0>
<CFLOOP LIST="#Program_List_Input#" INDEX="ProgramSubList">
	<CFSET ThisProgTot = EVALUATE("FORM.TotAmountOF_#ProgramSubList#")>
	<CFSET FundAllocation_Tot = FundAllocation_Tot + ThisProgTot>
	<CFSET EvalFundNo = EVALUATE("FORM.Fund_List_Input_#ProgramSubList#")>
	<CFSET ThisProgramSubList = ProgramSubList>
	<CFSET FirstProgram = LISTFIRST(ProgramSubList,"_")>
	<CFSET CommaSeperatedProg = REPLACE(ProgramSubList,"_",",","All")>
	
	
	<CFLOOP LIST="#EvalFundNo#" INDEX="FundLoop">
		<CFSET ThisAmount = "">
		<CFSET ThisAmount = EVALUATE("FORM.Allocated_Amount_For_#ThisProgramSubList#_#FundLoop#")>

		<CFQUERY NAME="UpdateAmount" DATASOURCE="#Application.Datasource#">
			UPDATE 	GL_Code_Fixed_Fund_Allocation_Cal 
			SET 	Allocated_Fund_Amount = <CFIF ThisAmount EQ "">
											NULL
											<CFELSE>
											#ThisAmount#
											</CFIF>
			WHERE 	Billback_ID = '#FORM.Billback_ID#' AND
					Program_ID = #FirstProgram# AND
					Fund_Number = '#FundLoop#' AND
					Allocation_Method = 3 AND
					Deleted = 0
		</CFQUERY>
		<CFQUERY NAME="UpdatePaidPrograms" DATASOURCE="#Application.Datasource#">
			UPDATE 	GL_Code_Fixed_Fund_Allocation_Cal 
			SET 	Allocated_To_Program = #FirstProgram#
			WHERE 	Billback_ID = '#FORM.Billback_ID#' AND
					Program_ID IN (#CommaSeperatedProg#) AND
					Fund_Number = '#FundLoop#' AND
					Allocation_Method = 3 AND
					Deleted = 0
		</CFQUERY>
	</CFLOOP>
</CFLOOP>
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<!--- makeup difference --->
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<CFQUERY NAME="RoundFundAmount" DATASOURCE="#Application.Datasource#">
	UPDATE 	GL_Code_Fixed_Fund_Allocation_Cal
	SET 	Allocated_Fund_Amount = ROUND(Allocated_Fund_Amount,2)
	WHERE 	Billback_ID = '#Billback_ID#' AND 
			Allocated_Fund_Amount Is Not Null AND Allocated_Fund_Amount <> '' AND
			Allocation_Method = 3 AND
			Deleted = 0
</CFQUERY>
			
<CFQUERY NAME="ValidFundAllocation" DATASOURCE="#Application.Datasource#">
	SELECT 	ISNULL(SUM(Allocated_Fund_Amount), 0) CheckTot <!--- added isnull in case of lump sum --->
	FROM 	GL_Code_Fixed_Fund_Allocation_Cal
	WHERE 	Billback_ID = '#FORM.Billback_ID#' AND
			Allocated_Fund_Amount Is Not Null AND Allocated_Fund_Amount <> '' AND
			Allocation_Method = 3 AND
			Deleted = 0
</CFQUERY>

<CFSET TotFundAmtDiff = FundAllocation_Tot - ValidFundAllocation.CheckTot>

<CFIF TotFundAmtDiff NEQ 0>
	<CFQUERY NAME="UpdateAmt" DATASOURCE="#Application.Datasource#">
		UPDATE 	GL_Code_Fixed_Fund_Allocation_Cal
		SET 	Allocated_Fund_Amount = Allocated_Fund_Amount + #TotFundAmtDiff#
		WHERE 	Billback_ID = '#FORM.Billback_ID#' AND
				Allocation_Method = 3 AND
				Deleted = 0 AND
				GL_Code_Fixed_Fund_Allocation_ID = (
														SELECT TOP 1 GL_Code_Fixed_Fund_Allocation_ID
														FROM GL_Code_Fixed_Fund_Allocation_Cal
														WHERE Billback_ID = '#FORM.Billback_ID#' AND
																Allocation_Method = 3 AND
																Deleted = 0 AND
																Allocated_Fund_Amount = ( 
																							SELECT 	MAX(Allocated_Fund_Amount)
																							FROM 	GL_Code_Fixed_Fund_Allocation_Cal
																							WHERE 	Billback_ID = '#FORM.Billback_ID#' AND
																									Allocation_Method = 3 AND
																									Deleted = 0
																						)
													)			
	</CFQUERY>
</CFIF>
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<CFQUERY NAME="DeletePrevious" DATASOURCE="#Application.Datasource#">
	UPDATE 	Gl_Code_Allocation
	SET 	Deleted = 1
	WHERE 	Billback_ID = '#FORM.Billback_ID#' AND			
			Allocation_Method = 3 AND
			Deleted = 0
</CFQUERY>
<CFQUERY NAME="InsertDundDetail" DATASOURCE="#Application.Datasource#">
	INSERT INTO 
	Gl_Code_Allocation	(	Billback_ID,
							Allocation_Method,
							Tot_Allocation_Amount,
							Allocated_Amount,
							Fund_Number,
							Fund_Description,
							A_R,
							Fiscal_Year,
							Surrogate_Item			)
							
	SELECT 				'#FORM.Billback_ID#',
						3,
						'#FundAllocation_Tot#',
						Allocated_Fund_Amount,
						Fund_Number,
						Fund_Description,
						A_R,
						Fiscal_Year,
						Surrogate_Item			
							
	FROM 				GL_Code_Fixed_Fund_Allocation_Cal
	WHERE				Billback_ID = '#FORM.Billback_ID#' AND
						Allocated_Fund_Amount Is Not Null AND Allocated_Fund_Amount <> '' AND
						Allocation_Method = 3 AND
						Deleted = 0
</CFQUERY>



<CFQUERY NAME="GetSCOAStr" DATASOURCE="#Application.Datasource#">
	SELECT 		Gl_Code_Allocation.Fund_Number,
				COMPANY+'_'+LOCATION+'_'+COST_CENTER+'_'+NATURAL_ACCT+'_'+CHANNEL+'_'+PRODUCT_GROUP+'_'+CAST(a.FUND_NUMBER AS varchar(50)) AS SCOAStr,
				Gl_Code_Allocation.A_R,
				Gl_Code_Allocation.Fiscal_Year

	FROM 		Gl_Code_Allocation
	INNER JOIN 	GL_Code_Activation a ON a.Fiscal_Year = Gl_Code_Allocation.Fiscal_Year AND
				a.A_R = Gl_Code_Allocation.A_R AND
				a.Fund_Number = Gl_Code_Allocation.Fund_Number AND
				a.Current_Active_Data = 1 AND
				a.deleted = 0
				
	WHERE 		Billback_ID = '#FORM.Billback_ID#' AND			
				Allocation_Method = 3 AND
				Gl_Code_Allocation.Deleted = 0
</CFQUERY>

<CFLOOP QUERY="GetSCOAStr">
	<CFQUERY NAME="SCOAUPDATE" DATASOURCE="#Application.Datasource#">
		UPDATE 	Gl_Code_Allocation
		SET 	SCOA = '#SCOAStr#'
		WHERE 		Billback_ID = '#FORM.Billback_ID#' AND			
					Allocation_Method = 3 AND
					Fiscal_Year = '#Fiscal_Year#' AND
					Fund_Number = '#Fund_Number#' AND
					A_R = '#A_R#' AND				
					Deleted = 0
	</CFQUERY>		
</CFLOOP>

<CFIF IsDefined("fromSplitBillbackPage") AND fromSplitBillbackPage EQ 1>
	<!------ Do not redirect ----->
<CFELSEIF IsDefined("Deduction_ID")>
	<CFLOCATION URL="Allocation_Layout.cfm?Billback_ID=#Billback_ID#&Deduction_ID=#Deduction_ID#" ADDTOKEN="No">
<CFELSE>
	<CFLOCATION URL="Allocation_Layout.cfm?Billback_ID=#Billback_ID#" ADDTOKEN="No">
</CFIF>
