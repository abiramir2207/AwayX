<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
	<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
</head>

<body>
<CFQUERY NAME="CheckForSplit" DATASOURCE="#Application.Datasource#">
	SELECT Top 1 * FROM Billback WHERE BB_parent_ID = '#Billback_ID#' AND Deleted = 0
</CFQUERY>

<CFQUERY NAME="BBInfoForSplit" DATASOURCE="#Application.Datasource#">
	SELECT * FROM Billback WHERE Billback_ID = '#Billback_ID#'
</CFQUERY>

<CFIF CheckForSplit.RecordCount GT 0>
	<CFLOCATION URL="/billbacks/Approval/Split_BB_History.cfm?Billback_ID=#Billback_ID#" ADDTOKEN="No">
</CFIF>

<CFQUERY NAME="GetAllocation" DATASOURCE="#Application.Datasource#">
	SELECT 		DISTINCT Billback_Program.Allocation_Method AS FinalAllocationDisplay,
				ISNULL(LumpSum_Amt,0) AS LumpSum_Amt,
				LumpSum_Only
				--DISTINCT 	Billback_Program.Allocation_Method AS FinalAllocationDisplay
	
	FROM 		Billback_Program 
	<!--- 
	INNER JOIN 	Contract_Main ON Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
	INNER JOIN 	Program_Latest_Template_ID ON Program_Latest_Template_ID.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
	INNER JOIN 	Program_Control_Panel_Options aaa ON aaa.ProgramControl_Panel_Options_ID = Program_Latest_Template_ID.Latest
	 --->
	WHERE 		Billback_ID = '#Billback_ID#' AND Billback_Program.Deleted = 0
	ORDER BY 	Billback_Program.Allocation_Method
</CFQUERY>

<CFQUERY NAME="CheckSaved" DATASOURCE="#Application.Datasource#">
	SELECT Top 1 * 
	FROM GL_Code_Allocation 
	WHERE Billback_ID='#Billback_ID#' AND 
	Deleted = 0
</CFQUERY>
<CFSET SavedAlready = CheckSaved.Allocation_Saved>

<CFLOOP QUERY="GetAllocation">	

	<CFIF FinalAllocationDisplay EQ 1 AND LumpSum_Only EQ 0>
		<CFINCLUDE TEMPLATE = "Display_Item_Allocation.cfm">
	</CFIF>
	<CFIF FinalAllocationDisplay EQ 2>
		<CFINCLUDE TEMPLATE="Display_Fixed_Allocation.cfm">
	</CFIF>
	<CFIF FinalAllocationDisplay EQ 3 OR (LumpSum_Amt NEQ 0 AND FinalAllocationDisplay EQ 1)>		
		<CFINCLUDE TEMPLATE="Final_Fund_Display.cfm">	
	</CFIF>
</CFLOOP>

<CFQUERY NAME="BBApprovedAmt" DATASOURCE="#Application.Datasource#">
	SELECT 	Round(Paid_Amount,2) ApprovedAmt 
	FROM 	BB_Approved
	WHERE 	Billback_ID = '#Billback_ID#'
</CFQUERY>

<CFQUERY NAME="GetAllocatedTot" DATASOURCE="#Application.Datasource#">
	SELECT 	Round(SUM(Allocated_Amount),2) AllocatedAmt 
	FROM 	Gl_Code_Allocation
	WHERE 	Billback_ID = '#Billback_ID#' AND
			Deleted = 0
</CFQUERY>
<CFSET AllocatedTotForJS = 0>
<CFIF GetAllocatedTot.AllocatedAmt NEQ "">
	<CFSET AllocatedTotForJS = GetAllocatedTot.AllocatedAmt>	
</CFIF>
<CFSET VariationAmt = BBApprovedAmt.ApprovedAmt - AllocatedTotForJS>
<CFSET BBTotForJS = BBApprovedAmt.ApprovedAmt>

<STYLE>
A.headerLink , A.headerLink:LINK, A.headerLink:VISITED , A.headerLink:FOCUS,A.headerLink:HOVER
{
	color : white;
	text-decoration : none;
}

</STYLE>

<CFOUTPUT>

<CFIF IsDefined("FinalAllocationDisp")>
	<CFSET ConsiderThisassociatedDistributorToBeThePayee = "" />
	<CFIF PayeeType EQ 4><!------ If payee = other, check i distributor is associated ----->	
		<cfset Get_Dist_Info = CreateObject("component", "components.billback.BillbackDeviationManager").getBillbackDistributor(Billback_ID, 4) />
		<CFSET ConsiderThisassociatedDistributorToBeThePayee = Get_Dist_Info.BSA_Foodservice_Customers_ID />
	</CFIF>

	<CFIF PayeeType EQ 1> 
		<CFQUERY NAME="GetPayeeInfo" DATASOURCE="#Application.Datasource#">
			SELECT 		BSA_Foodservice_Customers.Name PayeeName,
						Vendor_ID,						
						Shr_Ship_To
						
			FROM 		BB_Approved 
			INNER JOIN 	Billback_Distributor ON Billback_Distributor.Billback_ID = BB_Approved.Billback_ID AND
						Billback_Distributor.Deleted = 0
			INNER JOIN 	BSA_Foodservice_Customers ON Billback_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID 
			LEFT JOIN 	Vendor_Master ON Vendor_Master.Vendor_Master_ID = BB_Approved.Vendor_Master_ID 
			WHERE 		BB_Approved.Billback_ID = '#Billback_ID#'
		</CFQUERY>
		<!--- 
		<CFQUERY NAME="GetPayeeInfo" DATASOURCE="#Application.Datasource#">		
			SELECT 		BSA_Foodservice_Customers.Name 	PayeeName,
						Vendor_Dist_Oper.Vendor_Dist_Oper_ID,
						Vendor_ID,
						BSA_Foodservice_Customers_ID,
						Legacy_ID,
						Shr_Ship_To
						
			FROM 		Vendor_Dist_Oper
			
			INNER JOIN 	Billback_Distributor ON Billback_Distributor.Distributor_ID = Vendor_Dist_Oper.Distributor_ID 
			INNER JOIN 	BSA_Foodservice_Customers ON Billback_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID 
			INNER JOIN	BB_Approved ON BB_Approved.Billback_ID = Billback_Distributor.Billback_ID AND 
						BB_Approved.Vendor_Dist_Oper_ID = Vendor_Dist_Oper.Vendor_Dist_Oper_ID
			LEFT JOIN 	BSA_Operator ON BSA_Operator.BSA_Operator_ID = Vendor_Dist_Oper.Operator_ID AND 
						BSA_Operator.Deleted = 0
			
			WHERE 		Billback_Distributor.Billback_ID = '#Billback_ID#' AND
						Billback_Distributor.Deleted = 0 AND
						Vendor_Dist_Oper.Deleted = 0
		</CFQUERY>
		 --->
	<CFELSEIF PayeeType EQ 2>	
		<CFQUERY NAME="GetPayeeInfo" DATASOURCE="#Application.Datasource#">
			SELECT 		Operator_Name PayeeName,
						Vendor_ID,
						BSA_Operator_ID,
						Legacy_ID
						
			FROM 		BB_Approved 
			INNER JOIN	Billback_Operator ON Billback_Operator.Billback_ID = BB_Approved.Billback_ID AND 
						Billback_Operator.Deleted = 0
			INNER JOIN	BSA_Operator ON Billback_Operator.Operator_ID = BSA_Operator.BSA_Operator_ID 
			INNER JOIN 	Vendor_Master ON Vendor_Master.Vendor_Master_ID = BB_Approved.Vendor_Master_ID AND Vendor_Master.Deleted=0 AND Vendor_Master.Active_Code = 'A'	
			WHERE 		BB_Approved.Billback_ID = '#Billback_ID#'
		</CFQUERY>
		
		<!--- 
		<CFQUERY NAME="GetPayeeInfo" DATASOURCE="#Application.Datasource#">
			SELECT 		Operator_Name	PayeeName,
						Vendor_Dist_Oper.Vendor_Dist_Oper_ID,
						Vendor_ID,
						BSA_Operator_ID,
						Legacy_ID,
						Shr_Ship_To
	
			FROM 		Vendor_Dist_Oper
		
			INNER JOIN 	Billback_Operator ON Billback_Operator.Operator_ID = Vendor_Dist_Oper.Operator_ID 
			INNER JOIN 	BSA_Operator ON Billback_Operator.Operator_ID = BSA_Operator.BSA_Operator_ID 
			INNER JOIN	BB_Approved ON BB_Approved.Billback_ID = Billback_Operator.Billback_ID AND 
						BB_Approved.Vendor_Dist_Oper_ID = Vendor_Dist_Oper.Vendor_Dist_Oper_ID
			LEFT JOIN 	BSA_Foodservice_Customers ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Vendor_Dist_Oper.Distributor_ID
			
			WHERE 		Billback_Operator.Billback_ID = '#Billback_ID#' AND						
						Billback_Operator.Deleted = 0 AND
						Vendor_Dist_Oper.Deleted = 0
		</CFQUERY>
		 --->
	<CFELSEIF PayeeType EQ 3>
		<CFQUERY NAME="GetPayeeInfo" DATASOURCE="#Application.Datasource#">
			SELECT 
						Brk.Broker_Name PayeeName,
						V.Vendor_ID,
						Brk.BSA_Foodservice_Brokers_ID,
						Broker_Shard
			FROM Billback_Broker BB
			INNER JOIN 	BSA_Foodservice_Brokers Brk ON 
				BB.Broker_ID  = Brk.BSA_Foodservice_Brokers_ID 
			INNER JOIN 	BB_Approved A ON A.Billback_ID = BB.Billback_ID
			INNER JOIN	Vendor_Master V ON 
					V.Vendor_Master_ID = A.Vendor_Master_ID AND 
					V.Deleted=0 AND 
					V.Active_Code = 'A'	
			WHERE BB.Billback_ID = '#Billback_ID#' AND
				BB.Deleted = 0
		</CFQUERY>	 
	<CFELSEIF PayeeType EQ 4 AND ConsiderThisassociatedDistributorToBeThePayee NEQ "">		
		<CFQUERY NAME="GetPayeeInfo" DATASOURCE="#Application.Datasource#">
			SELECT 		BB_UP_Name	PayeeName,
						Vendor_Dist_Oper.Vendor_Dist_Oper_ID,
						Vendor_ID
	
			FROM 		Vendor_Dist_Oper
		
			INNER JOIN 	Billback_Unidentified_Payee ON Vendor_Dist_Oper.Distributor_ID = '#ConsiderThisassociatedDistributorToBeThePayee#'
			AND			Billback_Unidentified_Payee.Billback_ID = '#Billback_ID#'
			AND			Billback_Unidentified_Payee.Deleted = 0
			INNER JOIN	BB_Approved ON BB_Approved.Billback_ID = Billback_Unidentified_Payee.Billback_ID AND 
						BB_Approved.Vendor_Dist_Oper_ID = Vendor_Dist_Oper.Vendor_Dist_Oper_ID
			LEFT JOIN 	BSA_Foodservice_Customers ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Vendor_Dist_Oper.Distributor_ID
			
			WHERE 		Vendor_Dist_Oper.Deleted = 0
		</CFQUERY>
	<CFELSE>
		<BR><BR><BR>
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
			<TR>
				<TD><B><FONT COLOR="Red" SIZE="3">Payee is not a #application.returned_customer_setting.distributor_label_singular# and not a #application.returned_customer_setting.operator_label_singular#...</FONT></B></TD>
			</TR>
		</TABLE>	
		<CFABORT>
	</CFIF>
</CFIF>

<CFQUERY NAME="qGetVendorInfo" DATASOURCE="#Application.Datasource#">
	SELECT 		BB_Approved.Vendor_Master_ID, Vendor_Master.Vendor_ID, Vendor_Master.Vendor_Name						
	FROM 		BB_Approved 
	LEFT JOIN 	Vendor_Master ON Vendor_Master.Vendor_Master_ID = BB_Approved.Vendor_Master_ID 
	WHERE 		BB_Approved.Billback_ID = '#Billback_ID#'
</CFQUERY>

<CFIF Not IsDefined("FromPaid")>
	<CFIF Not IsDefined("FinalAllocationDisp")>
	<script language="JavaScript">
	function RequestPayment(sUrl, thisObj)
	{
		window.location.href = sUrl;
		disableA(thisObj);
	}
	</script>
	<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" WIDTH="800" ALIGN="Center">
		<TR BGCOLOR="A257BD">
			<TD><FONT SIZE="3" COLOR="White"><B><A class="headerLink" Href="##" ONCLICK="Javascript: return ConfirmFundReallocation()">Edit</A></B></FONT></TD>
			<CFIF VariationAmt EQ 0 AND application.appSettingsGet.getSplitBillbacks()>
			<TD><FONT SIZE="3" COLOR="White"><B>
				<CFIF BBInfoForSplit.BB_Associated_To_DD EQ 1 OR CheckForSplit.RecordCount GT 0>&nbsp;
				<CFELSEIF application.returned_customer_setting.Upload_GL_Code EQ 1 AND BBInfoForSplit.BB_Closing_Method EQ 2 AND qGetVendorInfo.Vendor_Master_ID EQ ""><span style="color:black;" title="Vendor selection is required">Split</span>
				<CFELSE><A class="headerLink" Href="/billbacks/Approval/Split_BB.cfm?Billback_ID=#Billback_ID#">Split</A></CFIF></B></FONT></TD>
			</CFIF>
			<!--- Vendor Selection Page ---->
			<CFIF BBInfoForSplit.BB_Closing_Method EQ 2>
			<TD ALIGN="Right">
			<FONT SIZE="3" COLOR="White"><B><A class="headerLink" Href="/GL_code/GL_Code_In_Billback/Payment_Request/VendorID_Selection.cfm?Billback_ID=#Billback_ID#">Vendor</A></B></FONT>
			</TD>
			</CFIF>
			<TD ALIGN="Right">
				<FONT SIZE="3"><B>
				<CFIF VariationAmt NEQ 0>				
					<FONT SIZE="3">STATUS: Pending Fund Update&nbsp;&nbsp;</FONT>
				<CFELSE>		
					<CFIF BBInfoForSplit.BB_Closing_Method EQ 2>
						<CFIF BBInfoForSplit.BB_Associated_To_DD EQ 1>
							<FONT SIZE="3">Closed with Deduction</FONT>
						<CFELSEIF application.returned_customer_setting.Upload_GL_Code EQ 1 AND qGetVendorInfo.Vendor_Master_ID EQ "">
							<span title="Vendor selection is required">Close with Deduction</span>
						<CFELSE>
							<FONT SIZE="3" COLOR="White"><A class="headerLink" Href="/Deductions/search_screens/Ded_Advanced_Search.cfm" TARGET="_parent">Close with Deduction</A></FONT>
						</CFIF>
					<CFELSEIF CheckForSplit.RecordCount EQ 0>					
						<FONT SIZE="3" COLOR="White">
						<CFIF IsDefined("Deduction_ID")>				
							<A class="headerLink" href="##" onclick="RequestPayment('/GL_Code/GL_Code_In_billback/Payment_Request/Allocation_Completed.cfm?Billback_ID=#Billback_ID#&Deduction_ID=#Deduction_ID#', this);return false;">Click Here To Request Payment</A>
						<CFELSE>
							<A class="headerLink" href="##" onclick="RequestPayment('/GL_Code/GL_Code_In_billback/Payment_Request/Allocation_Completed.cfm?Billback_ID=#Billback_ID#', this);return false;">Click Here To Request Payment</A>
						</CFIF>
						</FONT>
					</CFIF>
				</CFIF>
				</B>
				</FONT>
			</TD>
			<!--- <TD ALIGN="Right" <CFIF VariationAmt NEQ 0>WIDTH="270"<CFELSE>WIDTH="300"</CFIF>><!---  STYLE="font-size:16px;color=white;" --->
				<CFIF VariationAmt NEQ 0>
					<B>STATUS: Pending Fund Update</B>&nbsp;&nbsp;
				<CFELSE>
					<FONT SIZE="3" COLOR="White"><B><A class="headerLink" HREF="/GL_Code/GL_Code_In_billback/Payment_Request/Allocation_Completed.cfm?Billback_Id=#Billback_ID#">Click Here To Request For Payment</A></B></FONT>&nbsp;&nbsp;
				</CFIF>
			</TD> --->
		</TR>	
		<CFIF IsDefined("Deduction_ID") AND VariationAmt NEQ 0>
		<TR>
			<TD COLSPAN="100%" ALIGN="Center"><B><FONT COLOR="Red" SIZE="2">[ </FONT><A HREF="/deductions/deduction.cfm?Deduction_ID=#Deduction_ID#" TARGET="_parent">back to deduction</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B></TD>
		</TR>
		</CFIF>
	</TABLE>
	<CFELSE>
		<CFQUERY NAME="CheckStatus" DATASOURCE="#Application.Datasource#">
			SELECT Top 1 Approved 
			FROM Gl_Code_Allocation 
			WHERE Billback_ID = '#Billback_ID#' AND Deleted = 0
		</CFQUERY>
		<script language="JavaScript">
		function ApprovePaymentRequest(sUrl, thisObj)
		{
			var HoldIt = 0
			if (HoldThis.HoldThis.checked)
				HoldIt = 1;
			sUrl = sUrl + "&HoldStatus=" + HoldIt;			
			window.location.href = sUrl;
			disableA(thisObj);
		}
		</script>
		
			<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" WIDTH="800" ALIGN="Center" STYLE="Border-Bottom: 2px solid Navy;Border-Left: 2px solid Navy;Border-Right: 2px solid Navy;Border-Top: 2px solid Navy;">
				<TR>
					<TD><FONT SIZE="3"><B><CFIF CheckStatus.Approved NEQ 1>Payment Request<CFELSE>Payment Request - Approved<CFIF BBInfoForSplit.BB_Payment_Request_Approved EQ 0> - Hold<CFELSE> - Released</CFIF></CFIF></B></FONT></TD>
					<CFIF CheckStatus.Approved NEQ 1>
						<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
						<CFSET Permit_Approval = 0>
						<CFIF Get_Profile_Settings.BB_Pay_Req_Approval_Amount NEQ "*">
							<CFIF BBApprovedAmt.ApprovedAmt LTE Get_Profile_Settings.BB_Pay_Req_Approval_Amount>
								<CFSET Permit_Approval = 1>
							<CFELSE>
								<CFSET Permit_Approval = 0>
							</CFIF>
						<CFELSE>
							<CFSET Permit_Approval = 1>
						</CFIF>
						
						<form name="HoldThis">
						<TD ALIGN="Right">
							<CFIF Permit_Approval EQ 1>
								<FONT SIZE="3"><B>								
								<CFIF IsDefined("Deduction_ID")>
									<A href="##" onclick="ApprovePaymentRequest('/GL_Code/GL_Code_In_Billback/Payment_Request/Payment_Request_Display.cfm?Billback_ID=#Billback_ID#&ApproveThisPR=1&PayeeType=#PayeeType#&Deduction_ID=#Deduction_ID#', this);return false;">Click Here To Approve This Payment Request</A>
								<CFELSE>				
									<A href="##" onclick="ApprovePaymentRequest('/GL_Code/GL_Code_In_Billback/Payment_Request/Payment_Request_Display.cfm?Billback_ID=#Billback_ID#&ApproveThisPR=1&PayeeType=#PayeeType#', this);return false;">Click Here To Approve This Payment Request</A>
								</CFIF>						
								</B></FONT>
								<br>
									<input type="checkbox" name="HoldThis" value="1"> Set this to hold instead of release
								
							<CFELSE>
								<FONT SIZE="2" COLOR="Red"><B>Your Approval limit is low to approve this Pay. Req.</B></FONT>
							</CFIF>
						</TD>		
						</form>		
					</CFIF>
				</TR>	
			</TABLE>
		
	</CFIF>
</CFIF>
<CFIF IsDefined("Deduction_ID") AND VariationAmt NEQ 0>
<CFELSE>
<BR><BR>
</CFIF>

<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" WIDTH="800" ALIGN="Center">
	<TR>
		<TD BGCOLOR="FFE083"><B><FONT SIZE="3">Allocation Summary:</FONT></B></TD>
	</TR>
	<TR>
		<TD> <BR><BR>
			<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" STYLE="Border-top: 1px Solid Navy;Border-left: 1px Solid Navy;Border-Bottom: 1px Solid Navy;Border-right: 1px Solid Navy;">
				<CFIF IsDefined("FinalAllocationDisp")>
					<TR>
						<TD><FONT COLOR="Navy" SIZE="2"><B>Payee Type:</B></FONT></TD>
						<TD><FONT COLOR="Navy" SIZE="2"><B><CFIF PayeeType EQ 1>#application.returned_customer_setting.distributor_label_singular#<CFELSEIF PayeeType EQ 2>#application.returned_customer_setting.operator_label_singular#<CFELSEIF PayeeType EQ 4>OTHER</CFIF></FONT></B></TD>
					</TR>
					<TR>
						<TD><FONT COLOR="Navy" SIZE="2"><B>Payee Name:</B></FONT></TD>
						<TD><FONT COLOR="Navy" SIZE="2"><B>#GetPayeeInfo.PayeeName#</B></FONT></TD>
					</TR>
					<CFIF PayeeType EQ 1 OR PayeeType EQ 2>
					<TR>
						<TD><FONT COLOR="Navy" SIZE="2"><B><CFIF PayeeType EQ 1>#application.returned_customer_setting.Shard_Ship_To_Label#<CFELSEIF PayeeType EQ 2><CFIF GetPayeeInfo.Legacy_ID NEQ "">Operator ID<CFELSE>BSA Operator ID</CFIF></CFIF>:</B></FONT></TD>
						<TD><FONT COLOR="Navy" SIZE="2"><B><CFIF PayeeType EQ 1>#GetPayeeInfo.Shr_Ship_To#<CFELSEIF PayeeType EQ 2><CFIF GetPayeeInfo.Legacy_ID NEQ "">#GetPayeeInfo.Legacy_ID#<CFELSE>#GetPayeeInfo.BSA_Operator_ID#</CFIF></CFIF></FONT></B></TD>
					</TR>
					</CFIF>					
				</CFIF>
				<CFIF IsDefined("FinalAllocationDisp") OR BBInfoForSplit.BB_Closing_Method EQ 2>
				<TR>
					<TD><FONT COLOR="Navy" SIZE="2"><B>Vendor ID:</B></FONT></TD>
					<TD><FONT COLOR="Navy" SIZE="2"><B>#qGetVendorInfo.Vendor_ID#</B></FONT></TD>
				</TR>
				<TR>
					<TD><FONT COLOR="Navy" SIZE="2"><B>Vendor Name:</B></FONT></TD>
					<TD><FONT COLOR="Navy" SIZE="2"><B>#qGetVendorInfo.Vendor_Name#</B></FONT></TD>
				</TR>
				</CFIF>
				<TR>
					<TD WIDTH="180"><FONT COLOR="Navy" SIZE="2"><B>Approved Billback Amount:</B></FONT></TD>
					<TD><FONT COLOR="Red" SIZE="2"><B>#DollarFormat(BBApprovedAmt.ApprovedAmt)#</B></FONT></TD>
				</TR>
				<TR>
					<TD><FONT COLOR="Navy" SIZE="2"><B>Total Allocated Amount:</B></FONT></TD>
					<TD ID="AlloTot"><FONT COLOR="Red" SIZE="2"><B>#DOLLARFORMAT(AllocatedTotForJS)#</B></FONT></TD>
				</TR>
				<TR>
					<TD><FONT COLOR="Navy" SIZE="2"><B>Variation:</B></FONT></TD>		
					<TD ID="DiffBoth"><FONT COLOR="Red" SIZE="2"><B>#DOLLARFORMAT(VariationAmt)#</B></FONT></TD>
				</TR>
			</TABLE>
		</TD>
	</TR>
</TABLE>


<BR><BR>
</CFOUTPUT>
<CFSET RecalFundValidation = 0>
<CFLOOP QUERY="GetAllocation">	
	<CFIF FinalAllocationDisplay EQ 1 AND LumpSum_Only EQ 0>
		<CFOUTPUT>#ItemContent#</CFOUTPUT>
	</CFIF>
	<CFIF FinalAllocationDisplay EQ 2>
		<CFOUTPUT>#FixedContent#</CFOUTPUT>
	</CFIF>
	<CFIF FinalAllocationDisplay EQ 3 OR (LumpSum_Amt NEQ 0 AND FinalAllocationDisplay EQ 1)>
		<CFSET RecalFundValidation = 1>
		<CFOUTPUT>#FundContent#</CFOUTPUT>
	</CFIF>
</CFLOOP>

<CFIF Not IsDefined("FinalAllocationDisp")>
<CFIF VariationAmt EQ 0>
	<CFQUERY NAME="UpdateStatus" DATASOURCE="#Application.Datasource#">
		UPDATE Billback
		SET Billback_Status_ID = 3
		WHERE Billback_ID = '#Billback_ID#'
	</CFQUERY>
	<CFQUERY NAME="UpdateSaved" DATASOURCE="#Application.Datasource#">
		UPDATE 	Gl_Code_Allocation
		SET 	Allocation_Saved = 1
		WHERE 	Billback_ID = '#Billback_ID#' AND
				Deleted = 0	
	</CFQUERY>	
<CFELSE>
	<CFQUERY NAME="UpdateStatus" DATASOURCE="#Application.Datasource#">
		UPDATE Billback
		SET Billback_Status_ID = 6
		WHERE Billback_ID = '#Billback_ID#'
	</CFQUERY>
</CFIF>
</CFIF>
<!--- 
<SCRIPT language="JavaScript">
function dispTotAndDiff()
{
	var BBTot = "<CFOUTPUT>#BBTotForJS#</CFOUTPUT>";
	var AlloTot = "<CFOUTPUT>#AllocatedTotForJS#</CFOUTPUT>";
	var DiffOFThese; 
	BBTot = Math.round(BBTot*100)/100;
	AlloTot = Math.round(AlloTot*100)/100;
	DiffOFThese = BBTot - AlloTot;
	DiffOFThese = Math.round(DiffOFThese*100)/100;
	
	document.all.AlloTot.innerHTML= "<B>$ " + AlloTot + "</B>";	
	document.all.AlloTot.style.color = "red";		
	document.all.DiffBoth.innerHTML= "<B>$ " + DiffOFThese + "</B>";	
	document.all.DiffBoth.style.color = "red";	
}
document.body.onload = new Function("dispTotAndDiff()");
</SCRIPT>
 --->
 
<SCRIPT language="JavaScript">
function ConfirmFundReallocation()
{	
	var CheckFund = "<CFOUTPUT>#RecalFundValidation#</CFOUTPUT>";
	<CFIF IsDefined("Deduction_ID")>
		window.location.href="Allocation.cfm?Billback_ID=<CFOUTPUT>#Billback_ID#</CFOUTPUT>&Recal_Fund=1&Deduction_ID=<CFOUTPUT>#Deduction_ID#</CFOUTPUT>";
	<CFELSE>
		window.location.href="Allocation.cfm?Billback_ID=<CFOUTPUT>#Billback_ID#</CFOUTPUT>&Recal_Fund=1";
	</CFIF>
	/*if (CheckFund == 1)
	{
		if (confirm("Do you want to reallocation fund also?"))
		{
			<CFIF IsDefined("Deduction_ID")>
				window.location.href="Allocation.cfm?Billback_ID=<CFOUTPUT>#Billback_ID#</CFOUTPUT>&Recal_Fund=1&Deduction_ID=<CFOUTPUT>#Deduction_ID#</CFOUTPUT>";
			<CFELSE>
				window.location.href="Allocation.cfm?Billback_ID=<CFOUTPUT>#Billback_ID#</CFOUTPUT>&Recal_Fund=1";
			</CFIF>
		}
		else
		{
			<CFIF IsDefined("Deduction_ID")>
				window.location.href="Allocation.cfm?Billback_ID=<CFOUTPUT>#Billback_ID#</CFOUTPUT>&Recal_Fund=0&Deduction_ID=<CFOUTPUT>#Deduction_ID#</CFOUTPUT>";
			<CFELSE>
				window.location.href="Allocation.cfm?Billback_ID=<CFOUTPUT>#Billback_ID#</CFOUTPUT>&Recal_Fund=0";
			</CFIF>
		}
	}
	else
	{
		<CFIF IsDefined("Deduction_ID")>
			window.location.href="Allocation.cfm?Billback_ID=<CFOUTPUT>#Billback_ID#</CFOUTPUT>&Recal_Fund=0&Deduction_ID=<CFOUTPUT>#Deduction_ID#</CFOUTPUT>";
		<CFELSE>
			window.location.href="Allocation.cfm?Billback_ID=<CFOUTPUT>#Billback_ID#</CFOUTPUT>&Recal_Fund=0";
		</CFIF>
	}*/
	return false;
}

	if(window.parent.payment_tab)
	{
		window.parent.current_menu_item = "payment";
		window.parent.assignActiveTab();
		window.parent.buildMenu();
	}
	try { window.parent.dyniframesize(); } catch (err) { };
</SCRIPT>
</body>
</html>
