<cfparam name="ShowLumpSum" 		default="0">
<cfparam name="ShowRebate" 			default="0">
<cfparam name="ShowFixed"			default="0">
<cfparam name="ShowFormula" 		default="0">
<cfparam name="ShowGrowth"	 		default="0">
<cfparam name="ShowReimbursements" 	default="0">
<cfparam name="ShowDeductions"	 	default="0">

<!--- This condition is to avoid an error in the queries below --->
<cfif ProgramNumber eq "">
	<cfset ProgramNumber = 'NULL'>
</cfif>

<!---Figures out which discount types are on the program, so as to only display information on discount types that actually should have information--->
 <cfquery name="GetDiscountsforProgram" datasource="#application.datasource#">
SELECT Program_Lump_Sums.Program_Lump_Sum_ID AS Lump_Sum, Program_Rebates_Component.Program_Rebates_Component_ID AS Rebate, Program_Fixed_Component.Program_Fixed_Component_ID AS Fixed, Program_Growth_Components.Program_Growth_Component_ID AS Growth, Program_Formula_Pricing_Rules.Program_Formula_Pricing_Rule_ID AS Formula
	FROM Contract_Main
		LEFT JOIN Program_Lump_Sums
		ON Program_Lump_Sums.Program_ID = Contract_Main.Contract_Main_ID
		AND Program_Lump_Sums.Deleted = 0
		LEFT JOIN Program_Rebates_Component
		ON Program_Rebates_Component.Program_ID = Contract_Main.Contract_Main_ID
		AND Program_Rebates_Component.Deleted = 0
		LEFT JOIN Program_Fixed_Component
		ON Program_Fixed_Component.Program_ID = Contract_Main.Contract_Main_ID
		AND Program_Fixed_Component.Deleted = 0
		LEFT JOIN Program_Formula_Pricing_Rules
		ON Program_Formula_Pricing_Rules.Program_ID = Contract_Main.Contract_Main_ID
		AND Program_Formula_Pricing_Rules.Deleted = 0
		LEFT JOIN Program_Growth_Components
		ON Program_Growth_Components.Program_ID = Contract_Main.Contract_Main_ID
		AND Program_Growth_Components.Deleted = 0
	WHERE Contract_Main.Contract_Main_ID IN (#preservesinglequotes(ProgramNumber)#)
</cfquery>

<!---Checks to see if there are billbacks
NOTE: It is possible to have a billback for a discount type even though the program doesn't have that discount type in it.
--->
<cfquery name="GetAllBillbacks" datasource="#application.datasource#">
SELECT DISTINCT BB_Product_Type_ID
FROM BB_Program_Paid
WHERE Distributor_ID = '#DistributorNumber#'
AND Program_ID IN (#preservesinglequotes(ProgramNumber)#)
AND Billback_Status_ID >= 3
</cfquery>

<!---Show deductions--->
<cfif UseDeductions IS 1>
	<cfquery name="GetDeductions" datasource="#application.datasource#">
	SELECT Deductions.DD_Amount, Deductions.Cleared_Amount, Deductions.DD_DedID, Deductions.DD_DedID_Line, Deductions.DD_Reference, Deductions.Deduction_ID, Deductions.DD_Date, DD_Reason_Code.DD_Reason_Code, DD_Reason_Code.DD_Reason_Code_Description
	FROM Deductions
		INNER JOIN DD_Reason_Code
		ON Deductions.DD_Resolution_Code = DD_Reason_Code.DD_Reason_Code_ID
	WHERE Deductions.Program_ID IN (#preservesinglequotes(ProgramNumber)#)
	AND Deductions.Deleted = 0 
	AND Deductions.DD_Status > 3 
	AND Deductions.DD_Status <> 7
	</cfquery>
	
	<!---Use cleared amount?--->
	<cfquery name="DeductionSettings" datasource="#application.datasource#">
	SELECT Use_Cleared_Amount FROM Deduction_Settings
	</cfquery>
</cfif>

<!---Show reimbursements--->
<cfif UseReimbursements IS 1>
	
	<cfquery name="GetReimbursements" datasource="#application.datasource#">
	SELECT BB_Reimbursement.Reimbursement_Date, BB_Reimbursement.Reimbursement_Amount, BB_Reimbursement.Reimbursement_Comments, BB_Reimbursement.Reimbursement_Number, BB_Reimbursement_Type.Reimbursement_Type_Description, BB_Reimbursement.BB_Reimbursement_ID 
	FROM BB_Reimbursement
		INNER JOIN BB_Reimbursement_Type
		ON BB_Reimbursement_Type_ID = BB_Reimbursement.Reimbursement_Type
	WHERE BB_Reimbursement.Contract_Main_ID IN (#preservesinglequotes(ProgramNumber)#)
	AND BB_Reimbursement.Distributor_ID = '#DistributorNumber#'
	AND  BB_Reimbursement.Deleted = 0
	</cfquery>

</cfif>

<cfset DiscountsWithBillback = listqualify(valuelist(GetAllBillbacks.BB_Product_Type_ID), chr(39))>

<!----Sets bits on whether or not to display line at all--->

<!---Lump Sum--->
<cfif len(trim(GetDiscountsforProgram.Lump_Sum)) GT 0 OR ListContains(DiscountsWithBillback, "3")>
	<cfset ShowLumpSum = 1>
</cfif>

<!---Rebate--->
<cfif len(trim(GetDiscountsforProgram.Rebate)) GT 0 OR ListContains(DiscountsWithBillback, "2")>
	<cfset ShowRebate = 1>
</cfif>

<!---Fixed--->
<cfif len(trim(GetDiscountsforProgram.Fixed)) GT 0 OR ListContains(DiscountsWithBillback, "1")>
	<cfset ShowFixed = 1>
</cfif>

<!---Formula--->
<cfif len(trim(GetDiscountsforProgram.Formula)) GT 0 OR ListContains(DiscountsWithBillback, "5")>
	<cfset ShowFormula = 1>
</cfif>

<!---Growth--->
<cfif len(trim(GetDiscountsforProgram.Growth)) GT 0 OR ListContains(DiscountsWithBillback, "4")>
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