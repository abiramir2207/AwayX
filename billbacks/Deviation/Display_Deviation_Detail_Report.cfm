<!------
/billbacks/deviation/Display_Deviation_Detail_Report.cfm
---->
<cfparam name="deviationReportFileName" default="Deviations.csv">
<cfsilent>
<cfoutput>
<cfscript>
	// <!--- file string --->
	csvstr = createObject("java","java.lang.StringBuffer");

	// <!--- report header --->
	csvstr.append("BA PAYABLE ##" & ",");
	csvstr.append("BILLBACK REF ##" & ",");
	csvstr.append("PROGRAM NUMBER" & ",");
	csvstr.append("PROGRAM TITLE" & ",");
	csvstr.append("COMPONENT TYPE" & ",");

	csvstr.append("COMPONENT NAME" & ",");
	csvstr.append("ITEM NUMBER" & ",");
	csvstr.append("ITEM DESCRIPTION" & ",");
	csvstr.append("DISTRIBUTOR FOB PRICE PER CASE" & ",");
	csvstr.append("INBOUND FREIGHT PER CASE" & ",");

	csvstr.append("OUTBOUND FREIGHT PER CASE" & ",");
	csvstr.append("DISTRIBUTOR FINAL PRICE PER CASE" & ",");
	csvstr.append("OPERATOR CONTRACT PRICE PER CASE" & ",");
	csvstr.append("EXPECTED FIXED PRICE CLAIM RATE PER CASE" & ",");
	csvstr.append("EXPECTED DOLLAR REBATE RATE PER CASE" & ",");

	csvstr.append("CLAIM DOLLAR RATE PER CASE" & ",");
	csvstr.append("APPROVED DOLLAR RATE PER CASE" & ",");
	csvstr.append("CLAIMED CASES" & ",");
	csvstr.append("EXPECTED CASES" & ",");
	csvstr.append("APPROVED CASES" & ",");

	csvstr.append("CLAIMED EXTENDED DOLLAR AMOUNT" & ",");
	csvstr.append("EXPECTED EXTENDED DOLLAR AMOUNT" & ",");
	csvstr.append("APPROVED EXTENDED DOLLAR AMOUNT" & ",");
	csvstr.append("VARIATION - DOLLARS CLAIMED VS. EXPECTED [EXTENDED]" & ",");
	csvstr.append("VARIATION - DOLLARS CLAIMED VS. APPROVED [EXTENDED]" & ",");

	csvstr.append("DEVIATION - PROGRAM DATES" & ",");
	csvstr.append("DEVIATION - BILLBACK OVERLAP" & ",");
	csvstr.append("DEVIATION - AUTHORIZED PRODUCT" & ",");
	csvstr.append("DEVIATION - RATE" & ",");
	csvstr.append("DEVIATION - VOLUME" & ",");

	csvstr.append("OPERATOR ID" & ",");
	csvstr.append("OPERATOR NAME" & ",");
	csvstr.append("DISTRIBUTOR ID" & ",");
	csvstr.append("DISTRIBUTOR NAME" & ",");
	csvstr.append("BUYING GROUP ID" & ",");

	csvstr.append("BUYING GROUP NAME" & ",");
	csvstr.append("#Application.GLAccountLabel# CODE" & ",");
	csvstr.append("DEVIATION ACTION" & ",");
	csvstr.append("DEVIATION APPLIED AGAINST" & ",");
	csvstr.append(Chr(13) & Chr(10));
</cfscript>
</cfoutput>

<!--- report detail --->
<cfloop query="qDeviationDetailReport">
	<cfscript>
		csvstr.append(	application.util.string.csvFormat(BB_Code) & ","
						& application.util.string.csvFormat(BB_Reference) & ','
						& application.util.string.csvFormat(Contract_Number) & ","
						& application.util.string.csvFormat(Contract_Title) & ",");
		csvstr.append(	application.util.string.csvFormat(Component_Type) & ","
						& application.util.string.csvFormat(Component_Name) & ","
						& application.util.string.csvFormat(Item) & ','
						& application.util.string.csvFormat(Item_Description) & ",");
		csvstr.append(	application.util.string.csvFormat(Invoice_Price_Cs) & ","
						& application.util.string.csvFormat(Ibf_Rate_Cs) & ','
						& application.util.string.csvFormat(Obf_Rate_Cs) & ","
						& application.util.string.csvFormat(Final_Invoice_Price_Cs) & ",");
		csvstr.append(	application.util.string.csvFormat(Program_Product_Price_Cs) & ","
						& application.util.string.csvFormat(Fixed_E_Rate_Cs) & ","
						& application.util.string.csvFormat(Rebate_E_Rate_Cs) & ","
						& application.util.string.csvFormat(Claimed_Rate_Cs) & ",");
		csvstr.append(	application.util.string.csvFormat(Paid_Rate_Cs) & ","
						& application.util.string.csvFormat(Claimed_Volume_Cs) & ","
						& application.util.string.csvFormat(E_Volume_Cs) & ","
						& application.util.string.csvFormat(Item_Volume_Paid_Cs) & ",");
		csvstr.append(	application.util.string.csvFormat(Claimed_Amount) & ","
						& application.util.string.csvFormat(Expected_Amount) & ","
						& application.util.string.csvFormat(Paid_Amount) & ","
						& application.util.string.csvFormat(Variation_Claim_Expected) & ",");
		csvstr.append(	application.util.string.csvFormat(Variation_Claim_Paid) & ","
						& application.util.string.csvFormat(Deviation_Program_Dates) & ","
						& application.util.string.csvFormat(Deviation_Billback_Overlap) & ","
						& application.util.string.csvFormat(Deviation_Unauthorized_Product) & ",");
		csvstr.append(	application.util.string.csvFormat(Deviation_Rate) & ","
						& application.util.string.csvFormat(Deviation_Volume) & ","
						& application.util.string.csvFormat(Operator_Id) & ","
						& application.util.string.csvFormat(Operator_Name) & ',');
		csvstr.append(	application.util.string.csvFormat(Distributor_Number) & ","
						& application.util.string.csvFormat(Distributor_Name) & ','
						& application.util.string.csvFormat(Buying_Group_Number) & ","
						& application.util.string.csvFormat(Buying_Group_Name) & ",");
		csvstr.append(	application.util.string.csvFormat(Gl_Account) & ","
						& application.util.string.csvFormat(Deviation_Action) & ","
						& application.util.string.csvFormat(Adjustment_Deducted_From_BB) & ",");
		csvstr.append(Chr(13) & Chr(10));
	</cfscript>
</cfloop>
</cfsilent>
<!--- output report --->
<cfoutput>#csvstr.ToString()#</cfoutput>


