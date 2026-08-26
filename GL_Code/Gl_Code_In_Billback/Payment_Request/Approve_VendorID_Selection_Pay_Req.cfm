 

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<cfparam name="url.NextAction" default="">
<html>
<head>
	<title>Untitled</title>
</head>

<body>
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

<CFOUTPUT>

<CFQUERY NAME="BB_Info" DATASOURCE="#Application.Datasource#">
	SELECT 		Round(BB_Approved.Paid_Amount,2) ApprovedAmt,
				ISNULL(ROUND(Billback.TotalTaxAmount,2),0) TotalTaxAmount,
				Round(BB_Approved.Paid_Amount,2)+ISNULL(ROUND(Billback.TotalTaxAmount,2),0) AmountToPay, 
				DD_Reason_Code.DD_Reason_Code_Description, 
			Billback.*, BB_Approved.*, Vendor_Master.*, DD_Reason_Code.*, 
			ISNULL(bcm.Closing_Method_Type, Billback.BB_Closing_Method) as Closing_Method_Type
	FROM 		Billback 
	INNER JOIN 	BB_Approved ON BB_Approved.Billback_ID = Billback.Billback_ID
	INNER JOIN 	Vendor_Master ON BB_Approved.Vendor_Master_ID = Vendor_Master.Vendor_Master_ID
	LEFT JOIN   	DD_Reason_Code ON BB_Approved.BB_Reason_Code_ID = DD_Reason_Code.DD_Reason_Code_ID
	LEFT JOIN 	Billback_Closing_Methods bcm ON bcm.iBillback_Closing_Method_ID = Billback.BB_Closing_Method
	WHERE 		Billback.Billback_ID = '#Billback_ID#'
</CFQUERY>

<cfset Closing_Method_Type = BB_Info.Closing_Method_Type />

 <CFIF BB_Info.BB_Payment_Request_Prepared NEQ 1>
	<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	Allocate the dollar amount to the allowance code if the corresponding app switch is on.
	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
	<!--- 9093,9892 --->
	<!--- IGNORE (The app setting was created for Mccain only.)--->
	<CFIF appSettings.getOperatingGroupOn()>	
		<CFQUERY NAME="DeletePre" DATASOURCE="#Application.Datasource#">
			UPDATE BB_AllowanceCode_Allocation SET Deleted = 1 WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</CFQUERY>
		<CFQUERY NAME="DelPre" DATASOURCE="#Application.Datasource#">
			UPDATE BB_AllowanceCode_Allocation_Summary SET Deleted = 1 WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</CFQUERY>
	
		<cfset BillbackAllowanceCodeManager = CreateObject("component", "components.Billback.BillbackAllowanceCodeManager").init() /> 	
		
		<CFQUERY NAME="CheckIfChild" DATASOURCE="#Application.Datasource#">
			SELECT * FROM Billback 
			INNER JOIN 	BB_Approved ON BB_Approved.Billback_ID = BB_Approved.Billback_ID	
			WHERE Billback.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</CFQUERY>
				
		<!--- Do the allocation for the parent first if it is not available --->
		<CFIF CheckIfChild.BB_Is_Child EQ 1>
			<CFQUERY NAME="GetParentInfo" DATASOURCE="#Application.Datasource#">
				SELECT Paid_Amount FROM BB_Approved 
				WHERE Billback_ID = <cfqueryparam value="#CheckIfChild.BB_Parent_ID#" cfsqltype="CF_SQL_VARCHAR">
			</CFQUERY>
			<CFQUERY NAME="CheckForParentRecords" DATASOURCE="#Application.Datasource#">
				SELECT 		SUM(CAST(Allocated_Amount AS Decimal(18,2))) Allocated_Amount,CAST(BB_Approved.Paid_Amount AS Decimal(18,2)) Paid_Amount FROM BB_AllowanceCode_Allocation_Summary 
				INNER JOIN 	BB_Approved ON BB_Approved.Billback_ID = BB_AllowanceCode_Allocation_Summary.Billback_ID
				WHERE 		BB_AllowanceCode_Allocation_Summary.Billback_ID = '#CheckIfChild.BB_Parent_ID#'  AND 
							AllowanceCode_level_Sum = 1 AND Deleted = 0
				GROUP BY 	BB_AllowanceCode_Allocation_Summary.Billback_ID,BB_Approved.Paid_Amount
			</CFQUERY>
			<CFIF CheckForParentRecords.RecordCount EQ 0 OR CheckForParentRecords.Allocated_Amount NEQ CheckForParentRecords.Paid_Amount>
				<CFQUERY NAME="DeletePre" DATASOURCE="#Application.Datasource#">
					UPDATE BB_AllowanceCode_Allocation SET Deleted = 1 WHERE Billback_ID = <cfqueryparam value="#CheckIfChild.BB_Parent_ID#" cfsqltype="CF_SQL_VARCHAR">
				</CFQUERY>
				<CFQUERY NAME="DelPre" DATASOURCE="#Application.Datasource#">
					UPDATE BB_AllowanceCode_Allocation_Summary SET Deleted = 1 WHERE Billback_ID = <cfqueryparam value="#CheckIfChild.BB_Parent_ID#" cfsqltype="CF_SQL_VARCHAR">
				</CFQUERY>
				<CFSET BillbackAllowanceCodeManager.AllowanceCodeAllocation(CheckIfChild.BB_Parent_ID) />
			</CFIF>
		
			<CFQUERY NAME="InsBAAS" DATASOURCE="#Application.Datasource#">
				INSERT INTO BB_AllowanceCode_Allocation_Summary (Billback_ID,
				Allowance_Code_ID,AllowanceCode_level_Sum,
				Allocated_Amount)
				SELECT '#Billback_ID#',
				Allowance_Code_ID,AllowanceCode_level_Sum,
				(Allocated_Amount * #CheckIfChild.Paid_Amount#)/#GetParentInfo.Paid_Amount#
				FROM BB_AllowanceCode_Allocation_Summary BAAS
				WHERE BAAS.Billback_ID = <cfqueryparam value="#CheckIfChild.BB_Parent_ID#" cfsqltype="CF_SQL_VARCHAR">
				AND AllowanceCode_level_Sum = 1 AND Deleted = 0
			</CFQUERY>				
			
			<CFQUERY NAME="AllocatedAmt_Rounding" DATASOURCE="#Application.Datasource#">
				UPDATE BB_AllowanceCode_Allocation_Summary
				SET Allocated_Amount = (
				Allocated_Amount + (CAST(Paid_Amount AS Decimal(18,2)) - 
				(
				SELECT SUM(Allocated_Amount)
				FROM BB_AllowanceCode_Allocation_Summary BAAS1
				WHERE BAAS1.Billback_ID = BAAS.Billback_ID AND AllowanceCode_level_Sum = 1 AND Deleted = 0
				)))
				FROM BB_AllowanceCode_Allocation_Summary BAAS
				INNER JOIN BB_Approved ON BB_Approved.Billback_ID = BAAS.Billback_ID
				WHERE BAAS.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND AllowanceCode_level_Sum = 1 AND Deleted = 0 AND
				BAAS.BB_AllowanceCode_Allocation_Summary_ID = (SELECT TOP 1(BB_AllowanceCode_Allocation_Summary_ID)
				FROM BB_AllowanceCode_Allocation_Summary BAAS2 WHERE BAAS2.Billback_ID = BAAS.Billback_ID AND BAAS2.AllowanceCode_level_Sum = 1 AND 
				BAAS2.Deleted = 0 AND Allocated_Amount = (SELECT MAX(Allocated_Amount) FROM BB_AllowanceCode_Allocation_Summary BAAS3
				WHERE BAAS3.Billback_ID = BAAS2.Billback_ID AND BAAS3.AllowanceCode_level_Sum = 1 AND 
				BAAS3.Deleted = 0)
				)
			</CFQUERY>
			<!---
			<cfif appSettings.getBillbacksSalesTax()>
				<CFSET BillbackAllowanceCodeManager.AllocateTaxAmount(Billback_ID) />
			</cfif>
			--->
		<CFELSE>
			<CFSET BillbackAllowanceCodeManager.AllowanceCodeAllocation(Billback_ID) />
		</CFIF>

	
	
		<CFQUERY NAME="ValidateAllocation" DATASOURCE="#Application.Datasource#">
			SELECT 		SUM(CAST(Allocated_Amount AS Decimal(18,2))) Allocated_Amount,CAST(BB_Approved.Paid_Amount AS Decimal(18,2)) Paid_Amount FROM BB_AllowanceCode_Allocation_Summary 
			INNER JOIN 	BB_Approved ON BB_Approved.Billback_ID = BB_AllowanceCode_Allocation_Summary.Billback_ID
			WHERE 		BB_AllowanceCode_Allocation_Summary.Billback_ID = '#Billback_ID#'  AND 
						AllowanceCode_level_Sum = 1 AND Deleted = 0
			GROUP BY 	BB_AllowanceCode_Allocation_Summary.Billback_ID,BB_Approved.Paid_Amount
		</CFQUERY>
	
		<CFIF ValidateAllocation.RecordCount NEQ 0 AND ValidateAllocation.Allocated_Amount EQ ValidateAllocation.Paid_Amount>		
			<CFQUERY NAME="Approve_Pay_Req" DATASOURCE="#Application.Datasource#">
				UPDATE Billback
				SET BB_Payment_Request_Prepared = 1,
					BB_Payment_Request_Prepared_By = '#request.AccessStructure.User_ID#',
					BB_Payment_Request_Prepared_Date = getdate()
				WHERE Billback_ID = '#Billback_ID#'
			</CFQUERY>
		<CFELSE>
			<BR><BR><BR><BR>
		
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
				<TR>
					<TD><B><FONT COLOR="Red" SIZE="3">All or part of the Billback dollars could not be allocated properly to an allowance code, the payment request will not be saved.</FONT></B></TD>
				</TR>
			</TABLE>
			<CFABORT>
		</CFIF>
	<CFELSE>
		<!--- 13611 (This is for all clients)--->
		<CFQUERY NAME="Approve_Pay_Req" DATASOURCE="#Application.Datasource#">
			UPDATE Billback
			SET BB_Payment_Request_Prepared = 1,
				BB_Payment_Request_Prepared_By = '#request.AccessStructure.User_ID#',
				BB_Payment_Request_Prepared_Date = getdate()
			WHERE Billback_ID = '#Billback_ID#'
		</CFQUERY>
	</CFIF>
	<!--- 9093,9892 --->
</CFIF> 

<!--- Dev Note: 44393/60998. - In the condition (Closing_Method_Type EQ 1) AND appSettings.getSkipVendorSelectionOnBBApproval() eq 1)
the code is applicable for payment only and the objective is to be redirected to the "billback_summary.cfm" page, when "bb payment hold/release"
app setting is ON - appSettings.getBBPaymentRequestHoldRelease().

- When the user approves payment request by clicking on the "Approve payment request" link, the "Approve" variable is passed in the URL.
Since we are using the "getSkipVendorSelectionOnBBApproval" app setting and skipping the "Save vendor", "Save payment request" and "Approve payment request"
screens, we need to either set the BB to "hold" or "release" status without user interaction.

The rules are as follows (For "payment" closing method)
- When "bb payment hold/release" app setting is ON and “Skip vendor selection on approval, if BB already has vendor associated to it" app setting is ON. set BB to "HOLD".
- When "bb payment hold/release" app setting is OFF and “Skip vendor selection on approval, if BB already has vendor associated to it" app setting is ON. set BB to "RELEASE".
--->
<CFIF (
		(IsDefined("URL.Approve") OR url.NextAction IS "Approve"))
		OR 
		(appSettings.getBBPaymentRequestHoldRelease() eq 1 
		AND (Closing_Method_Type EQ 1 AND appSettings.getSkipVendorSelectionOnBBApproval() eq 1
		)
	)>
		<CFIF IsDefined("URL.Approve") OR url.NextAction IS "Approve">
			<CFQUERY NAME="Approve_Pay_Req" DATASOURCE="#Application.Datasource#">
				UPDATE Billback
				SET BB_Payment_Request_Approved = 1,
					BB_Payment_Request_Approved_By = '#request.AccessStructure.User_ID#',
					BB_Payment_Request_Approved_Date = getdate()
				WHERE Billback_ID = '#Billback_ID#'
			</CFQUERY>
		</CFIF>
			<!--- Dev Note: (70529) - Use below code so that the left NAV links on index.cfm are activated. --->
			<script>
				window.parent.location.href = "/Billbacks/capture/index.cfm?BBID=#Billback_ID#&modifyagree=1";
			</script>
			<cfabort>
</CFIF>

<CFSET PayeeType = BB_Info.Billback_Payee_Type_ID>
<CFIF PayeeType EQ 1>
	<CFQUERY NAME="Payee_Info" DATASOURCE="#Application.Datasource#">
		SELECT 		Name Payee_Name,
					Shr_Ship_To Payee_Number,
					Address_1+','+Address_2 AS Address,
					City Payee_City,
					State Payee_State,
					ZipCode Payee_Zip
					
		FROM 		Billback_Distributor 
		INNER JOIN 	BSA_Foodservice_Customers ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Billback_Distributor.Distributor_ID
		WHERE 		Billback_ID = '#Billback_ID#' AND Billback_Distributor.Deleted = 0
	</CFQUERY>
<CFELSEIF PayeeType EQ 2>  
	<CFQUERY NAME="Payee_Info" DATASOURCE="#Application.Datasource#">
		SELECT 		Operator_Name Payee_Name,
					Legacy_ID Payee_Number,
					Operator_Address +','+ Operator_Address2 AS Address,
					Operator_City Payee_City,
					Operator_State Payee_State,
					Operator_Zip Payee_Zip
					
		FROM 		Billback_Operator
		INNER JOIN 	BSA_Operator ON BSA_Operator.BSA_Operator_ID = Billback_Operator.Operator_ID
		WHERE 		Billback_ID = '#Billback_ID#' AND Billback_Operator.Deleted = 0
	</CFQUERY>
<CFELSEIF PayeeType EQ 3>  
	<CFQUERY NAME="Payee_Info" DATASOURCE="#Application.Datasource#">
		SELECT 		Broker_Name Payee_Name,
					Broker_Shard Payee_Number,
					Address +','+ Address_2 AS Address,
					City Payee_City,
					State Payee_State,
					Zip Payee_Zip
		FROM Billback_Broker BB
		INNER JOIN 	BSA_Foodservice_Brokers Brk ON 
				BB.Broker_ID  = Brk.BSA_Foodservice_Brokers_ID
		WHERE 	BB.Billback_ID = '#Billback_ID#' AND 
				BB.Deleted = 0
	</CFQUERY>
<CFELSEIF PayeeType EQ 4>
	<CFQUERY NAME="Payee_Info" DATASOURCE="#Application.Datasource#">
		SELECT 	BB_UP_Name Payee_Name,
				BB_UP_Address1 +','+ BB_UP_Address2 AS Address,
				BB_UP_City Payee_City, 
				BB_UP_State Payee_State,
				BB_UP_Zipcode Payee_Zip
				
		FROM 	Billback_Unidentified_Payee
		WHERE 	Billback_ID = '#Billback_ID#' AND Deleted = 0
	</CFQUERY>
<CFELSE>
<B><FONT COLOR="Red" SIZE="3">No payee has been found</font></b>
<cfabort>
</CFIF>

<BR><BR>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
	<CFIF BB_Info.BB_Payment_Request_Approved NEQ 1>
	<TR>
		<TD><B><FONT COLOR="Red">[ </FONT><A href="VendorID_Selection.cfm?Billback_ID=#Billback_ID#&PayeeType=#PayeeType#">Edit Vendor</A><FONT COLOR="Red"> ]</FONT></B><BR><BR></TD>		
	</TR>
	</CFIF>
	<TR>
		<TD>
			<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" STYLE="Border-Bottom: 2px Solid Navy;Border-Left: 2px Solid Navy;Border-Right: 2px Solid Navy;Border-Top: 2px Solid Navy;" ALIGN="Center">	
				
				<TR>
					<TD COLSPAN="100%" STYLE="font-Size:15px; color:Navy" ALIGN="Center"><B>Payment Request <CFIF BB_Info.BB_Payment_Request_Approved EQ 1>(Approved)</CFIF> Details</B><BR><HR COLOR="Orange"></TD>
				</TR>
				<TR>
					<TD VALIGN="Top" STYLE="font-Size:13px; color:red"><B>Payable ##:</B></TD>
					<TD STYLE="font-Size:13px; color:red"><B>#BB_Info.BB_Code#</B></TD>
				</TR>
				<TR>
					<TD VALIGN="Top"><B>Claimed Amt:</B></TD>
					<TD>#DOLLARFORMAT(BB_Info.BB_Amount)#</TD>
				</TR>
				<TR>
					<TD VALIGN="Top"><B>Approved Amt:</B></TD>
					<TD>#DOLLARFORMAT(BB_Info.ApprovedAmt)#</TD>
				</TR>
				<cfif appSettings.getBillbacksSalesTax() eq 1>
				<TR>
					<TD VALIGN="Top"><B>Tax Amt:</B></TD>
					<TD>#DOLLARFORMAT(BB_Info.TotalTaxAmount)#</TD>
				</TR>
				<TR>
					<TD VALIGN="Top"><B>Amount to Pay:</B></TD>
					<TD>#DOLLARFORMAT(BB_Info.AmountToPay)#</TD>
				</TR>
				</CFIF>
				<TR>
					<TD VALIGN="Top"><B>Payee:</B></TD>
					<TD>#Payee_Info.Payee_Name#<BR>#Payee_Info.Address#,<BR>#Payee_Info.Payee_City#,#Payee_Info.Payee_State#,#Payee_Info.Payee_Zip#</TD>
				</TR>
				<TR>
					<TD VALIGN="Top"><B>Vendor ##:</B></TD>
					<TD>#BB_Info.Vendor_ID#<BR>#BB_Info.Vendor_Name#<BR>#BB_Info.Address_1#,#BB_Info.Address_2#<cfif isDefined("BB_Info.Address_3") and BB_Info.Address_3 neq "" >,#BB_Info.Address_3#</cfif><BR>#BB_Info.City#,#BB_Info.State#,#BB_Info.Zipcode#</TD>
				</TR>
				<cfif appSettings.getShowReasonCodeOnBBApprovalScreen()>
				<TR>
					<TD VALIGN="Top"><B>Reason Code:</B></TD>
					<TD>
						<cfif NOT appSettings.getBBReasonCodeAllowMultiple()>
						#BB_Info.DD_Reason_Code_Description#
						<cfelse>
							<cfset qGetSavedBillbackClosingMethod = CreateObject("component", "components.billback.BillbackManager").getSavedBillbackClosingMethod(billbackID = Billback_ID) />
							<cfloop query="qGetSavedBillbackClosingMethod">
								#DD_Reason_Code_Description#<br>
							</cfloop>
						</cfif>
					</TD>
				</TR>
				</cfif>
				<CFIF BB_Info.BB_Payment_Request_Approved NEQ 1>
				<TR>
					<TD COLSPAN="100%" ALIGN="Center">					
					<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
					<CFSET Permit_Approval = 0>
					<CFIF Get_Profile_Settings.BB_Pay_Req_Approval_Amount NEQ "*">
						<CFIF BB_Info.ApprovedAmt LTE Get_Profile_Settings.BB_Pay_Req_Approval_Amount>
							<CFSET Permit_Approval = 1>
						<CFELSE>
							<CFSET Permit_Approval = 0>
						</CFIF>
					<CFELSE>
						<CFSET Permit_Approval = 1>
					</CFIF>
				
					<BR>
					
					<CFQUERY NAME="BB_Info" DATASOURCE="#Application.Datasource#">
					SELECT 		Round(BB_Approved.Paid_Amount,2) ApprovedAmt,
								ISNULL(ROUND(Billback.TotalTaxAmount,2),0) TotalTaxAmount,
								Round(BB_Approved.Paid_Amount,2)+ISNULL(ROUND(Billback.TotalTaxAmount,2),0) AmountToPay, 
								DD_Reason_Code.DD_Reason_Code_Description, * 
					FROM 		Billback 
					INNER JOIN 	BB_Approved ON BB_Approved.Billback_ID = Billback.Billback_ID
					INNER JOIN 	Vendor_Master ON BB_Approved.Vendor_Master_ID = Vendor_Master.Vendor_Master_ID
					LEFT JOIN   DD_Reason_Code ON BB_Approved.BB_Reason_Code_ID = DD_Reason_Code.DD_Reason_Code_ID
					WHERE 		Billback.Billback_ID = '#Billback_ID#'
				</CFQUERY>

				<CFQUERY NAME="qbillback" DATASOURCE="#Application.Datasource#">
				SELECT 	BB_Closing_Method
				FROM		Billback
				WHERE 	Billback.Billback_ID = '#Billback_ID#'
				</CFQUERY>
					<!--- Dev Note: 44393. - This code is applicable for "payment" only. On "VendorID_Selection.cfm", the JS code  is automatically called without user interaction and 
					the billback behavior is such as if the user is "saving" (column:  "BB_Payment_Request_Prepared") the payment request. So, the payment request is automatically 
					set to "HOLD:"
					From that file, the user finally comes to this page. Even thought the bilback's  "BB_Payment_Request_Prepared" is already set to 1, the code again uses cflocation,
					and by passing "Prepared=1" is doing the same thing as "saving payment request". (just in case the code missed it earlier).
					Note: WR(60998) -  Now there is modified logic where when "getBBPaymentRequestHoldRelease" app setting is ON, the BB will be set to HOLD, else it will be set to "Released"."
					Also, now a different app setting is being used below - "getSkipVendorSelectionOnBBApproval".
					--->

					<CFIF Closing_Method_Type EQ 1 AND appSettings.getSkipVendorSelectionOnBBApproval() eq 1>
						<cfif appSettings.getBBPaymentRequestHoldRelease() eq 1>
							<!--- PAYMENT REQUEST HOLD --->
							<CFLOCATION URL="Approve_VendorID_Selection_Pay_Req.cfm?Billback_ID=#Billback_ID#&Prepared=1">
						<cfelse>
							<!--- PAYMENT REQUEST RELEASE --->
							<CFLOCATION URL="Approve_VendorID_Selection_Pay_Req.cfm?Billback_ID=#Billback_ID#&Approve=1">
						</cfif>
					<CFELSEIF BB_Info.BB_Payment_Request_Prepared NEQ 1>
					<B><FONT COLOR="Red">[ </FONT><A Href="Approve_VendorID_Selection_Pay_Req.cfm?Billback_ID=#Billback_ID#&Prepared=1">Save Payment Request</A><FONT COLOR="Red"> ]</FONT></B>
					<CFELSEIF Permit_Approval EQ 1 AND BB_Info.BB_Payment_Request_Prepared EQ 1>
					 <B><FONT COLOR="Red">[ </FONT><A Href="Approve_VendorID_Selection_Pay_Req.cfm?Billback_ID=#Billback_ID#&Approve=1">Approve Payment Request</A><FONT COLOR="Red"> ]</FONT></B>
					 <CFELSE>
					 <B><FONT COLOR="Red">You do not have permission to request or approve payment requests.</FONT></B>
					</CFIF>
					</TD>
				</TR>
				</CFIF>
			</TABLE>		
		</TD>
	</TR>
</TABLE>

<cfif (url.NextAction IS "Save" AND BB_Info.BB_Payment_Request_Approved EQ 1)>
	<script>
		window.parent.location.href = "/Billbacks/capture/index.cfm?BBID=#Billback_ID#&modifyagree=1";
	</script>
<cfabort>
</cfif>

</CFOUTPUT>

<script>
	if(window.parent.payment_tab)
	{
		window.parent.current_menu_item = "payment";
		window.parent.assignActiveTab();
		window.parent.buildMenu();
	}
</script>
</body>
</html>
<script>

 try { window.parent.dyniframesize(); } catch (err) { };

</script>