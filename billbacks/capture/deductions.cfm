<!------ deductions.cfm ----->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<cfparam name="FORM.Deduction_ID" 	default="">
<cfparam name="FORM.state" 			default="0">

<cfif FORM.state EQ 0>
	<!------ Get the stored deduction id ----->
	<cfset useLakebaseForgetAssociatedDeductionID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForgetAssociatedDeductionID>
	<cftry>
		<cfset getAssociatedDeductionID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions", {
				"dd_closure_id" = "eq.#URL.BBID#",
				"dd_closure_type" = "eq.1",
				"select" = "deduction_id"
			}), "deduction_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetAssociatedDeductionID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetAssociatedDeductionID>
<cfquery name="getAssociatedDeductionID" datasource="#application.datasource#">
		SELECT	Deductions.Deduction_ID
		FROM	Deductions
		WHERE	DD_Closure_ID = '#URL.BBID#'
		AND		DD_Closure_Type = 1
	</cfquery>
</cfif>
	<cfset FORM.Deduction_ID = ValueList(getAssociatedDeductionID.Deduction_ID) />	
</cfif>

<cfset useLakebaseForGetPayee = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_distributor")>
<cfif useLakebaseForGetPayee>
	<cftry>
		<cfset GetPayee = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_distributor", {
				"billback_id" = "eq.#URL.BBID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetPayee = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetPayee>
<CFQUERY NAME="GetPayee" DATASOURCE="#Application.Datasource#">
		SELECT * FROM Billback_Distributor WHERE Billback_ID = '#URL.BBID#' AND Deleted = 0
</CFQUERY>
</cfif>
<!------ Get Billback Approved for Payment Amount ----->
<cfquery name="getBBApprovedAmount" datasource="#application.datasource#">
	SELECT		BB_Approved.Paid_Amount,Billback.BB_Closing_Method
	FROM		BB_Approved
	INNER JOIN 	Billback ON Billback.Billback_ID = BB_Approved.Billback_ID
	WHERE		BB_Approved.Billback_ID = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#URL.BBID#" />
</cfquery>
<cfset bbApprovedAmount = getBBApprovedAmount.Paid_Amount />

<CFQUERY NAME="qGetVendorInfo" DATASOURCE="#Application.Datasource#">
	SELECT 		BB_Approved.Vendor_Master_ID, Vendor_Master.Vendor_ID, Vendor_Master.Vendor_Name						
	FROM 		BB_Approved 
	LEFT JOIN 	Vendor_Master ON Vendor_Master.Vendor_Master_ID = BB_Approved.Vendor_Master_ID 
	WHERE 		BB_Approved.Billback_ID = '#url.BBID#'
</CFQUERY>

<CFQUERY NAME="BBInfo" DATASOURCE="#Application.Datasource#">
	SELECT BB_Associated_To_DD
	FROM Billback 
	WHERE Billback_ID = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#URL.BBID#" />
</CFQUERY>

<cfoutput>
<script language="JavaScript">
function showDeductionSearchWindow(frmName)
{
	NewWindow("/deductions/search_screens/deduction_search_popup.cfm?SelectedDeduction=#FORM.Deduction_ID#&BBApprovedAmt=#bbApprovedAmount#&Dist_ID=#GetPayee.Distributor_ID#&Filter_Distributor=1&Formname=" + frmName + "&FieldName=Deduction_ID", "deductionsearchwindow", 750, 600, "yes", "yes", true);
	return false;
}
function saveDeduction(frmName)
{
	var oForm = eval("document." + frmName);
	oForm.action = "deductions_action.cfm";
	oForm.submit();
	return false;
}
</script>
<CFSET InfoBar_BBID = URL.BBID>
<cfinclude template="billback_load_infobar.cfm" />
<FORM name="frm_deduction_search_popup" action="" method="post">
	<INPUT type="Hidden" name="Deduction_ID" value="#FORM.Deduction_ID#" />
	<INPUT type="Hidden" name="BBID" value="#URL.BBID#" />
	<INPUT type="Hidden" name="state" value="1" />
	<INPUT type="Hidden" name="Cleared_Amount" value="#bbApprovedAmount#" />
	<INPUT TYPE="Hidden" NAME="ClosingAction" VALUE="Approve">
</FORM>
<br><br><br>
<TABLE CELLPADDING="2" CELLSPACING="0" WIDTH="70%" align="center">
<tr><td>
<B>Billback Approved Amount: #NumberFormat(bbApprovedAmount, "$_.__")#</B>
</td></tr>
</table>

<cfif FORM.Deduction_ID NEQ "">
	<!------ Display deduction information ----->
	<cfset DeductionManager = CreateObject("component", "components.deduction.DeductionManager").init() />
	<cfset qGetDeduction = DeductionManager.getDeduction(FORM.Deduction_ID) />
	<TABLE CELLPADDING="2" CELLSPACING="0" WIDTH="70%" CLASS="MainTable" align="center">
	<TR BGCOLOR="##ffce84">
		<TD ID="Header"><B>Deduction ##</B></TD>
		<TD ID="Header"><B>Amount</B></TD>
		<TD ID="Header"><B>#application.returned_customer_setting.distributor_label_singular#</B></TD>
		<TD ID="Header"><B>Analyst</B></TD>
	</TR>
	<cfloop query="qGetDeduction">
	<TR BGCOLOR="#IIF(currentrow Mod 2, DE('FFFFFF'),DE('CCFFCC'))#">
		<TD>#DD_DedID_SP_Number#</TD>
		<TD>#DollarFormat(DD_Amount)#</TD>
		<TD>#Name#</TD>
		<TD>#Anlayst#</TD>
	</TR>
	</cfloop>
	</table>
<cfelse>
	<CFIF getBBApprovedAmount.BB_Closing_Method EQ 3 OR getBBApprovedAmount.BB_Closing_Method EQ 4>
		<BR><BR><center><font color="red"><B>Closing method of this payable is <CFIF  getBBApprovedAmount.BB_Closing_Method EQ 3>Off-Invoice<CFELSE>Adjustment</CFIF>. This payable can't be associated to a deduction.</B></font></center>
	<CFELSE>
		<center><font color="red"><B>No deduction selected</B></font></center>
	</CFIF>
</cfif>

<cfif BBInfo.BB_Associated_To_DD eq 0>
<br>
<CFIF getBBApprovedAmount.BB_Closing_Method NEQ 3 AND getBBApprovedAmount.BB_Closing_Method NEQ 4>
<div align="center">
<table>
<tr>
<td>
<CF_smallLink 
		title = "select deduction" 
		url = "##"
		parameters = "onClick=""javascript: return showDeductionSearchWindow('frm_deduction_search_popup');"""
	>
</td>

<td>
	<cfif application.returned_customer_setting.Upload_GL_Code EQ 1 AND qGetVendorInfo.Vendor_Master_ID EQ "">
		You must select a vendor to associate a deduction.<br>

		<CF_smallLink 
		title = "select vendor" 
		url = "/GL_code/GL_Code_In_Billback/Payment_Request/VendorID_Selection.cfm?Billback_ID=#url.BBID#"
		parameters = ""
	>	
	<cfelse>
	<CF_smallLink 
		title = "save and approve deduction" 
		url = "##"
		parameters = "onClick=""javascript: return saveDeduction('frm_deduction_search_popup');"""
	>
	</cfif>
</td>
</tr>
</cfif>

</table>
</div>
</CFIF>

</cfoutput>
<!--- BSD 11544  --->
<script>
	try { window.parent.dyniframesize(); } catch (err) { };
</script>
</body>
</html>
