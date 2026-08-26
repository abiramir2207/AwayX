<cfsilent>
<cfset ShowLumpSum 			= 		0>
<cfset ShowRebate 			= 		0>
<cfset ShowFixed 			= 		0>
<cfset ShowFormula 			= 		0>
<cfset ShowGrowth 			= 		0>
<cfset ShowReimbursements 	= 		0>
<cfset ShowDeductions 		= 		0>

<cfquery name="GetDiscountsforProgram" datasource="#application.datasource#">
SELECT DISTINCT Discount_Type_ID FROM Accrual_Log WHERE Program_ID IN (#preservesinglequotes(ContractMainList)#)
</cfquery>

<cfset ProgramDiscounts = listqualify(valuelist(GetDiscountsforProgram.Discount_Type_ID), chr(39))>

<!---Checks to see if there are billbacks
NOTE: It is possible to have a billback for a discount type even though the program doesn't have that discount type in it.
--->

<cfquery name="GetAllBillbacks" datasource="#application.datasource#">
SELECT DISTINCT BB_Product_Type_ID
FROM BB_Program_Paid
WHERE Distributor_ID = '#DistributorNumber#'
AND Program_ID IN (#preservesinglequotes(ContractMainList)#)
AND Billback_Status_ID >= 3
</cfquery>

<!---Show deductions--->
<cfif UseDeductions IS 1>
	<cfquery name="GetDeductions" datasource="#application.datasource#">
	SELECT Deductions.DD_Amount, Deductions.Cleared_Amount, Deductions.DD_DedID, Deductions.DD_DedID_Line, Deductions.DD_Reference, Deductions.Deduction_ID, Deductions.DD_Date, DD_Reason_Code.DD_Reason_Code, DD_Reason_Code.DD_Reason_Code_Description
	FROM Deductions
		INNER JOIN DD_Reason_Code
		ON Deductions.DD_Resolution_Code = DD_Reason_Code.DD_Reason_Code_ID
	WHERE Deductions.Program_ID IN (#preservesinglequotes(ContractMainList)#)
	AND Deductions.Distributor_ID = '#DistributorNumber#'
	AND Deductions.Deleted = 0 
	AND Deductions.DD_Status > 3 
	AND Deductions.DD_Status <> 7
	</cfquery>
	
	</cfif>

<!---Show reimbursements--->
<cfif UseReimbursements IS 1>
	
	<cfquery name="GetReimbursements" datasource="#application.datasource#">
	SELECT BB_Reimbursement.Reimbursement_Date, BB_Reimbursement.Reimbursement_Amount, BB_Reimbursement.Reimbursement_Comments, BB_Reimbursement.Reimbursement_Number, BB_Reimbursement_Type.Reimbursement_Type_Description, BB_Reimbursement.BB_Reimbursement_ID 
	FROM BB_Reimbursement
		INNER JOIN BB_Reimbursement_Type
		ON BB_Reimbursement_Type_ID = BB_Reimbursement.Reimbursement_Type
	WHERE BB_Reimbursement.Contract_Main_ID IN (#preservesinglequotes(ContractMainList)#)
	AND BB_Reimbursement.Distributor_ID = '#DistributorNumber#'
	AND  BB_Reimbursement.Deleted = 0
	</cfquery>

</cfif>

<cfset DiscountsWithBillback = listqualify(valuelist(GetAllBillbacks.BB_Product_Type_ID), chr(39))>

<!----Sets bits on whether or not to display line at all--->

<!---Lump Sum--->
<cfif ListContains(ProgramDiscounts, "3") OR ListContains(DiscountsWithBillback, "3")>
	<cfset ShowLumpSum = 1>
</cfif>

<!---Rebate--->
<cfif ListContains(ProgramDiscounts, "2") OR ListContains(DiscountsWithBillback, "2")>
	<cfset ShowRebate = 1>
</cfif>

<!---Fixed--->
<cfif ListContains(ProgramDiscounts, "1") OR ListContains(DiscountsWithBillback, "1")>
	<cfset ShowFixed = 1>
</cfif>

<!---Formula--->
<cfif ListContains(ProgramDiscounts, "5") OR ListContains(DiscountsWithBillback, "5")>
	<cfset ShowFormula = 1>
</cfif>

<!---Growth--->
<cfif ListContains(ProgramDiscounts, "4") OR ListContains(DiscountsWithBillback, "4")>
	<cfset ShowGrowth = 1>
</cfif>

<cfif UseDeductions IS 1>
<!---Deductions--->
<cfif GetDeductions.Recordcount GT 0>
	<cfset ShowDeductions = 1>
</cfif>
</cfif>

<cfif UseReimbursements IS 1>
<!---Reimbursements--->
<cfif GetReimbursements.RecordCount GT 0>
	<cfset ShowReimbursements = 1>
</cfif>
</cfif>
</cfsilent>