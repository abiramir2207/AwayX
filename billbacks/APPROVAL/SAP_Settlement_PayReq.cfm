<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<CFQUERY NAME="CheckForLump" DATASOURCE="#Application.Datasource#">
	SELECT * FROM BB_Lump_Sums WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND Deleted = 0
</CFQUERY>

<cfset useLakebaseForqSchedBB = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForqSchedBB>
	<cftry>
		<cfset qSchedBB = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#Billback_ID#",
				"deleted" = "eq.0",
				"select" = "scheduled_auto_bb"
			}), "scheduled_auto_bb"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqSchedBB = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqSchedBB>
<CFQUERY NAME="qSchedBB" DATASOURCE="#Application.Datasource#">
	SELECT Scheduled_Auto_BB FROM Billback WHERE Billback_ID = '#Billback_ID#' AND Deleted = 0
</CFQUERY>
</cfif>
<CFIF CheckForLump.RecordCount GT 0>
	<CFQUERY NAME="CheckAlreadySaved" DATASOURCE="#Application.Datasource#">
		SELECT Top 1 * FROM BB_Lump_Sum_Allocation WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND Deleted = 0
	</CFQUERY>
	
	<CFIF CheckAlreadySaved.RecordCount EQ 0>
		<CFLOCATION URL="SAP_LumpSum_Allocation.cfm?Billback_ID=#Billback_ID#" ADDTOKEN="No">
	</CFIF>
</CFIF>



<CFIF IsDefined("URL.PayReqApprove")>
	<!--- --->
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>
	<cfset PaymentService = CreateObject("component","components.Billback.SAPSubmitSettlement") />
	<cfset sendPaymentRequest = PaymentService.ProcessPayment(URL.Billback_Id, request.AccessStructure.User_ID) />
	<BR><BR><BR>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">		
		<TR>
			<TD><B><FONT COLOR="Red" SIZE="3">Payment Request Status: <cfoutput>#sendPaymentRequest#</cfoutput></FONT></B></TD>
		</TR>
	</TABLE>
	
	<!--- <SCRIPT language="JavaScript">
	function RelocateThis()
	{
		window.location.href = "/Billbacks/capture/billback_summary.cfm?BBID=<CFOUTPUT>#URL.billback_ID#</CFOUTPUT>";
	}
	window.setTimeout('RelocateThis()', 2000);	
	</SCRIPT> --->
	<CFABORT>
</CFIF>

<CFPARAM NAME="FORM.FormSubmitted" DEFAULT="0">

<CFQUERY NAME="GetPaymentDetail" DATASOURCE="#Application.Datasource#">
	SELECT 		Paid_Amount,
				Actual_Approved_Amt,
				BB_Approved.Billback_ID,
				BB_Settlement.Billback_ID SET_Billback_ID,
	 			Settlement_Number,
				WithHold_Amt,
				WithHold_Amt_Processed,
				BB_Settlement.BB_ShortPay_Reason_ID,
				Apply_To_Reference,
				SP_Reason_Code,
				SP_Reason_Description,
				Pay_Req_Approved,
				Comments
				
	FROM 		BB_Approved
	LEFT JOIN	BB_Settlement ON BB_Settlement.Billback_ID = BB_Approved.Billback_ID
	LEFT JOIN  	BB_ShortPay_Reason ON BB_ShortPay_Reason.BB_ShortPay_Reason_ID = BB_Settlement.BB_ShortPay_Reason_ID
	WHERE 		BB_Approved.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
</CFQUERY>


<CFIF FORM.FormSubmitted EQ 1>
	<CFIF FORM.WithHold_Amt EQ "">
		<CFSET FORM.WithHold_Amt = 0>
	</CFIF>
	<CFSET PaidAmt = GetPaymentDetail.Actual_Approved_Amt - FORM.WithHold_Amt>
	<CFQUERY NAME="UpdateAmt" DATASOURCE="#Application.Datasource#">
		UPDATE BB_Approved
		SET Paid_Amount = ROUND(#PaidAmt#,2)
		WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	</CFQUERY>
	<CFIF GetPaymentDetail.SET_Billback_ID EQ "">
		<CFQUERY NAME="SaveData" DATASOURCE="#Application.Datasource#">
			INSERT INTO 
			BB_Settlement 	(	Billback_ID,
								Settlement_Number,
								WithHold_Amt,
								WithHold_Amt_Processed,
								BB_ShortPay_Reason_ID,
								Apply_To_Reference,
								Created_Updated_User_ID,
								Comments				)
								
			VALUES			(	<cfqueryparam value="#FORM.Billback_ID#" cfsqltype="CF_SQL_VARCHAR">,
								<CFIF FORM.Settlement_Number NEQ "">
								<cfqueryparam value="#FORM.Settlement_Number#" cfsqltype="CF_SQL_VARCHAR">,
								<CFELSE>
								NULL,
								</CFIF>
								<CFIF FORM.WithHold_Amt NEQ "">
								<cfqueryparam value="#FORM.WithHold_Amt#" cfsqltype="CF_SQL_FLOAT">,
								<CFELSE>
								NULL,
								</CFIF>
								1,
								<CFIF FORM.BB_ShortPay_Reason_ID NEQ "">
								<cfqueryparam value="#FORM.BB_ShortPay_Reason_ID#" cfsqltype="CF_SQL_INTEGER">,
								<CFELSE>
								NULL,
								</CFIF>
								<CFIF FORM.Apply_To_Reference NEQ "">
								<cfqueryparam value="#FORM.Apply_To_Reference#" cfsqltype="CF_SQL_VARCHAR">,
								<CFELSE>
								NULL,
								</CFIF>
								<cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#FORM.Comments#" cfsqltype="CF_SQL_LONGVARCHAR">				)
			
		</CFQUERY>
		
		<CFQUERY NAME="UpdateStatus" DATASOURCE="#Application.Datasource#">
			UPDATE Billback
			SET Billback_Status_ID = 4,
			BB_Payment_Request_Prepared = 1,
			BB_Payment_Request_Prepared_By = '#request.AccessStructure.User_ID#',
			BB_Payment_Request_Prepared_Date = getdate()
			WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</CFQUERY>
	<CFELSE>
		<CFQUERY NAME="UpdateData" DATASOURCE="#Application.Datasource#">
			UPDATE BB_Settlement
			
			SET 	Settlement_Number 		=	<CFIF FORM.Settlement_Number NEQ ""><cfqueryparam value="#FORM.Settlement_Number#" cfsqltype="CF_SQL_VARCHAR"><CFELSE>NULL</CFIF>,
					WithHold_Amt			=	<CFIF FORM.WithHold_Amt NEQ ""><cfqueryparam value="#FORM.WithHold_Amt#" cfsqltype="CF_SQL_FLOAT"><CFELSE>NULL</CFIF>,
					WithHold_Amt_Processed	=	1,
					BB_ShortPay_Reason_ID 	=	<CFIF FORM.BB_ShortPay_Reason_ID NEQ ""><cfqueryparam value="#FORM.BB_ShortPay_Reason_ID#" cfsqltype="CF_SQL_INTEGER"><CFELSE>NULL</CFIF>,
					Apply_To_Reference		=	<CFIF FORM.Apply_To_Reference NEQ ""><cfqueryparam value="#FORM.Apply_To_Reference#" cfsqltype="CF_SQL_VARCHAR"><CFELSE>NULL</CFIF>,
					Created_Updated_User_ID	=	<cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">,
					Comments				=	<cfqueryparam value="#FORM.Comments#" cfsqltype="CF_SQL_LONGVARCHAR">
					
			WHERE	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</CFQUERY>
		<CFQUERY NAME="UpdateStatus" DATASOURCE="#Application.Datasource#">
			UPDATE Billback
			SET BB_Payment_Request_Prepared = 1,
			BB_Payment_Request_Prepared_By = '#request.AccessStructure.User_ID#',
			BB_Payment_Request_Prepared_Date = getdate()
			WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</CFQUERY>
	</CFIF>
	<CFQUERY NAME="GetPaymentDetail" DATASOURCE="#Application.Datasource#">
		SELECT 		Paid_Amount,
					Actual_Approved_Amt,
					BB_Approved.Billback_ID,
					BB_Settlement.Billback_ID SET_Billback_ID,
		 			Settlement_Number,
					WithHold_Amt,
					WithHold_Amt_Processed,
					BB_Settlement.BB_ShortPay_Reason_ID,
					Apply_To_Reference,
					SP_Reason_Code,
					SP_Reason_Description,
					Pay_Req_Approved,
					Comments
					
		FROM 		BB_Approved
		LEFT JOIN	BB_Settlement ON BB_Settlement.Billback_ID = BB_Approved.Billback_ID
		LEFT JOIN  	BB_ShortPay_Reason ON BB_ShortPay_Reason.BB_ShortPay_Reason_ID = BB_Settlement.BB_ShortPay_Reason_ID
		WHERE 		BB_Approved.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	</CFQUERY>
</CFIF>


<CFIF GetPaymentDetail.SET_Billback_ID EQ "" AND FORM.FormSubmitted NEQ 1>
	<CFQUERY NAME="UpdateAmt" DATASOURCE="#Application.Datasource#">
		UPDATE 	BB_Approved 
		SET 	Actual_Approved_Amt = Paid_Amount
		WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	</CFQUERY>	
</CFIF>

<cfset useLakebaseForGetReasonCode = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_shortpay_reason")>
<cfif useLakebaseForGetReasonCode>
	<cftry>
		<cfset GetReasonCode = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bb_shortpay_reason", {
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetReasonCode = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetReasonCode>
<CFQUERY NAME="GetReasonCode" DATASOURCE="#Application.Datasource#">
	SELECT 	* 
	FROM 	BB_ShortPay_Reason
	WHERE 	Deleted = 0
</CFQUERY>
</cfif>

<CFIF GetPaymentDetail.SET_Billback_ID EQ "">
	<CFSET Paid_Amount = GetPaymentDetail.Paid_Amount>
<CFELSE>
	<CFSET Paid_Amount = GetPaymentDetail.Actual_Approved_Amt>
</CFIF>

<CFIF GetPaymentDetail.Pay_Req_Approved EQ 1>
	<CFSET FORM.FormSubmitted = 1>
	<CFSET DontShoeLinks = 1>
<CFELSEIF IsDefined("URL.PayRequested")>
	<CFSET FORM.FormSubmitted = 1>
</CFIF>
<BR><BR><BR>
<CFOUTPUT>
<FORM NAME="PayRequest" ACTION="SAP_Settlement_PayReq.cfm" METHOD="POST">
<INPUT TYPE="hidden" NAME="FormSubmitted" VALUE="0">
<INPUT TYPE="hidden" NAME="Billback_ID" VALUE="#Billback_ID#">	
	
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center" WIDTH="510">
		<TR>
			<TD><cfif not qSchedBB.Scheduled_Auto_BB>
					<B><FONT COLOR="Red" SIZE"2">[ </FONT><A Href="SAP_LumpSum_Allocation.cfm?Billback_ID=#Billback_ID#&Edit=1">reallocate Lump sum</A><FONT COLOR="Red" SIZE"2"> ]</FONT></B>
				</cfif>
				<BR><BR>	
			</TD>
			<TD ALIGN="Right">
				<CFIF FORM.FormSubmitted EQ 1>	
				<CFIF Not IsDefined("DontShoeLinks")>
				<B><FONT COLOR="Red" SIZE"2">[ </FONT><A Href="SAP_Settlement_PayReq.cfm?Billback_ID=#Billback_ID#">edit</A><FONT COLOR="Red" SIZE"2"> ]</FONT></B>&nbsp;&nbsp;
				<B><FONT COLOR="Red" SIZE"2">[ </FONT><A Href="SAP_Settlement_PayReq.cfm?Billback_ID=#Billback_ID#&PayReqApprove=1">approve</A><FONT COLOR="Red" SIZE"2"> ]</FONT></B>
				</CFIF></CFIF>&nbsp;<BR><BR>
			</TD>
		</TR>
		<TR>
			<TD COLSPAN="100%">
				<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" ALIGN="Center" STYLE="Border-Bottom: 2px solid navy; Border-Left: 2px solid navy; Border-Right: 2px solid navy; Border-Top: 2px solid navy;">		
					<TR>
						<TD COLSPAN="2" ALIGN="Center"><B><FONT COLOR="navy" SIZE="2">Rebate Settlement Screen</FONT></B><HR COLOR="Orange"></TD>
					</TR>
					<TR>
						<TD><B>Rebate:</B></TD>
						<TD><CFIF FORM.FormSubmitted EQ 1>#GetPaymentDetail.Settlement_Number#<CFELSE><INPUT TYPE="Text" NAME="Settlement_Number" VALUE="#GetPaymentDetail.Settlement_Number#"></CFIF></TD>
					</TR>
					<TR>
						<TD><B>Settlement Total:</B></TD>
						<TD>#DOLLARFORMAT(Paid_Amount)#</TD>
					</TR>
					<TR>
						<TD><B>Amount to withhold <CFIF FORM.FormSubmitted EQ 1>($)</CFIF>:</B></TD>
						<TD><CFIF FORM.FormSubmitted EQ 1>#DOLLARFORMAT(GetPaymentDetail.WithHold_Amt)#<CFELSE><INPUT TYPE="Text" NAME="WithHold_Amt" VALUE="#GetPaymentDetail.WithHold_Amt#" Onchange="Javascript: ChangePayTot()" onKeyUp="clenseText(this, '0123456789.');"></CFIF></TD>
					</TR>
					<TR>
						<TD><B>Amount to Pay:</B></TD>
						<TD ID="DispTot"><B><FONT COLOR="Red"><CFIF FORM.FormSubmitted EQ 1>#DOLLARFORMAT(GetPaymentDetail.Paid_Amount)#<CFELSEIF GetPaymentDetail.WithHold_Amt NEQ "">#DOLLARFORMAT(GetPaymentDetail.Paid_Amount)#</CFIF></FONT></B></TD>
					</TR>
					<TR>
						<TD><B>Withhold Reason:</B></TD>
						<TD>
							<CFIF FORM.FormSubmitted EQ 1>
								<CFIF GetPaymentDetail.SP_Reason_Description NEQ "">
									#GetPaymentDetail.SP_Reason_Description# (#GetPaymentDetail.SP_Reason_Code#)
								</CFIF>
							<CFELSE>
							<SELECT NAME="BB_ShortPay_Reason_ID">
								<OPTION VALUE="">
								<CFLOOP QUERY="GetReasonCode">
									<OPTION VALUE="#BB_ShortPay_Reason_ID#" <CFIF BB_ShortPay_Reason_ID EQ GetPaymentDetail.BB_ShortPay_Reason_ID>SELECTED</CFIF>>#SP_Reason_Description# (#SP_Reason_Code#)</OPTION>
								</CFLOOP>
							</SELECT>
							</CFIF>
						</TD>
					</TR>
					<TR>
						<TD><B>Apply to reference ##:</B></TD>
						<TD><CFIF FORM.FormSubmitted EQ 1>#GetPaymentDetail.Apply_To_Reference#<CFELSE><INPUT TYPE="Text" NAME="Apply_To_Reference" VALUE="#GetPaymentDetail.Apply_To_Reference#"></CFIF></TD>
					</TR>					
				</TABLE>
			</TD>
		</TR>
		<TR>
			<TD COLSPAN="100%"><BR>
				<B>Comments:</B>
				<CFIF FORM.FormSubmitted EQ 1>
					&nbsp;&nbsp;#GetPaymentDetail.Comments#
				<CFELSE>
				<BR>
				<TEXTAREA NAME="Comments" COLS="96" ROWS="4">#GetPaymentDetail.Comments#</TEXTAREA>
				</CFIF>
			</TD>
		</TR>
		<TR>
			<TD COLSPAN="100%	" ALIGN="Center"><BR>
					<CFIF FORM.FormSubmitted NEQ 1>
					<CF_button
					button_name	=	""
					button_caption	=	"Payment Request"
					button_action	=	"Validate()"
					button_type		=	"javascript_link"
					button_width	=	"100"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight	=	"bold"
								>
					</CFIF>
			</TD>
		</TR>
	</TABLE>

	
</FORM>
</CFOUTPUT>

<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<SCRIPT language="JavaScript">
function ChangePayTot()
{
	var ActualTot = "<CFOUTPUT>#Paid_Amount#</CFOUTPUT>";	
	var ShortPay = document.all.WithHold_Amt.value;

	ActualTot = Math.round(ActualTot*100)/100;
	ShortPay = Math.round(ShortPay*100)/100;	
	
	if (ShortPay > ActualTot)
	{
		alert("'Amount to withhold' can't be more than 'Settlement Total'.")
		document.all.WithHold_Amt.focus()
		return;
	}
	else
	{			
		FinalPayTot = ActualTot - ShortPay;
		FinalPayTot = Math.round(FinalPayTot*100)/100;
		DispTot.innerHTML = "<B> $ " + FinalPayTot + "</B>";	
		DispTot.style.color = "Red";
	}
}
function Validate()
{	
	var submit_OK = 1;
	
	if (document.all.WithHold_Amt.value != "")
	{
		if (parseFloat(document.all.WithHold_Amt.value) != 0)
		{
			if(document.all.BB_ShortPay_Reason_ID.value == "")
			{
				alert("Please select a short pay reason code.")
				document.all.BB_ShortPay_Reason_ID.focus()
				submit_OK = 0;
				return;
			}
		}
	}
	if (submit_OK == 1)
	{
		document.all.FormSubmitted.value = 1;
		document.PayRequest.submit()
	}
}
</SCRIPT>
<script>
	if(window.parent.payment_tab)
	{
		window.parent.current_menu_item = "payment";
		window.parent.assignActiveTab();
		window.parent.buildMenu();
	}
		// BSD D11544   	
    try { window.parent.dyniframesize(); } catch (err) { };
</script>
</body>
</html>
