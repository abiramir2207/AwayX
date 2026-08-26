<cfparam name="form.Payment_Cycle" default ="">
<cfparam name="form.Accounting_Specialist" default ="">
<cfparam name="form.ClaimAmount" default ="">
<cfparam name="form.Start_Date" default ="">
<cfparam name="form.End_Date" default ="">
<cfparam name="form.Amount_Operator" default="">
<cfparam name="form.Distributor_Name" default="">
<cfparam name="form.Distributor_List" default="">
<cfparam name="form.ReportType" default="">

<cfif form.ReportType eq 2>
		<cfcontent type="application/unknown">
				<cfheader name="Content-Disposition" value="attachment;filename=Payment_History.xls">
</cfif>

<style>
	.heading
	{
		font-family: verdana,arial,helvetica;
		font-size: 11px;
		font-weight: bold;
	}

	.ColumnHeaders
	{
		font-family:Verdana, Arial, Helvetica, sans-serif;
		font-size:11px;
		font-weight:bold;
		background: #FFB062;
		text-align:center;
	}

	.SectionHeaders
	{
		font-family:Verdana, Arial, Helvetica, sans-serif;
		font-size:12px;
		font-weight:bold;
		color:brown;
		vertical-align:top;
	}

	.ReportContent
	{
		font-family:Verdana, Arial, Helvetica, sans-serif;
		font-size:10px;
		text-align:center;
	}

	.BaseColumnHeader
	{
		font-family:Verdana, Arial, Helvetica, sans-serif;
		font-size:11px;
		font-weight:bold;
	}

</style>


<div class="heading" align="left">
	<cfoutput>
	From: #form.Start_Date# to #form.End_Date# <br />
	Run Date: #DateFormat(now(), "MM/DD/YYYY")# #TimeFormat(now(), "hh:mm tt") #<br />
	Report ID: BARPT007<br />
	</cfoutput>
	Report Title: Payment History / Metrics
</div>

<cfset AccountingSpecialistobj = CreateObject("component", "components.settings.AccountingSpecialists.AccountingSpecialists") />

	<cfif Form.Accounting_Specialist neq "">
		<cfset AllAccountingSpecialists = QueryNew("User_ID")>
		<cfset QueryAddRow(AllAccountingSpecialists, 1)>
		<cfset QuerySetCell(AllAccountingSpecialists,"User_ID",form.Accounting_Specialist,1)>
	<cfelse>
		<cfset AllAccountingSpecialists = AccountingSpecialistobj.get(Isdeleted=1)>
	</cfif>

<!--- Call sp get_payment_history --->

<cfif Form.Accounting_Specialist eq "">
	<cfset Form.Accounting_Specialist = "NULL">
</cfif>

<cfif Form.Distributor_List eq "">
	<cfset Form.Distributor_List = "NULL">
</cfif>

<cfif Form.ClaimAmount eq "">
	<cfset Form.ClaimAmount = "0.00">
</cfif>

<table border="0" cellspacing="0" cellpadding="3" align="center">
			<tr>
				<td class="ColumnHeaders">Rebate Recipient</td>
				<td class="ColumnHeaders">Prog Child</td>
				<td class="ColumnHeaders">Prog Name</td>
				<td class="ColumnHeaders">Prog Manager</td>
				<td class="ColumnHeaders">Claim Mechanism</td>
				<td class="ColumnHeaders">Disc Identifier</td>
				<td class="ColumnHeaders">Check Amt</td>
				<td class="ColumnHeaders">Payment Cycle</td>
				<td class="ColumnHeaders">Date Approved</td>
				<td class="ColumnHeaders">Approval Submission</td>
				<td class="ColumnHeaders">Payment due date</td>
				<td class="ColumnHeaders">Payout Period</td>
				<td class="ColumnHeaders">Payment Submitted</td>
				<!--- <td class="ColumnHeaders">Billback Setup</td> --->
				<td class="ColumnHeaders">Approval Duration</td>
				<td class="ColumnHeaders">SAP Payment Duration</td>
			</tr>

<cfoutput query="AllAccountingSpecialists">

	<!--- sp to get the payment history --->
	<cfstoredproc procedure = "get_payment_history" dataSource = "#application.datasource#">
		<cfprocparam type = "IN" CFSQLType ="CF_SQL_DATE" value = "#TRIM(Form.Start_Date)#"  dbVarName = "@Start_Date">
		<cfprocparam type = "IN" CFSQLType ="CF_SQL_DATE" value = "#TRIM(Form.End_Date)#"  dbVarName = "@End_Date">
		<cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR" value = "#TRIM(AllAccountingSpecialists.User_ID)#"  dbVarName = "@Accounting_Specialist">
		<cfprocparam type = "IN" CFSQLType ="cf_sql_integer" value = "#TRIM(Form.Payment_Cycle)#"  dbVarName = "@Payment_Cycle">
		<cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR" value = "#TRIM(Form.Distributor_List)#"  dbVarName = "@Rebate_Recipient">
		<cfprocparam type = "IN" CFSQLType ="CF_SQL_FLOAT" value = "#TRIM(Form.ClaimAmount)#"  dbVarName = "@Claim_Amount">
		<cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR" value = "#TRIM(Form.Amount_Operator)#"  dbVarName = "@GTE_Operator_symbols">

			<cfprocresult name = "Payment_History" resultset="1">
			<cfprocresult name = "Payment_History_Average" resultset="2">
	</cfstoredproc>


	<cfset Acc_Specialist = AllAccountingSpecialists.User_ID>
		<cfloop query ="Payment_History">
			<cfif Acc_Specialist eq Accounting_Specialist_UserID AND Payment_History.currentrow eq 1>
				<tr>
					<td colspan="100%">&nbsp;</td>
				</tr>
				<tr>
					<td colspan="100%" class="SectionHeaders"><u>#Accounting_Specialist#</u></td>
				</tr>
			</cfif>

				<tr>
					<td class="ReportContent">#Rebate_Recipient#</td>
					<td class="ReportContent">#BSA_Program_ID#</td>
					<td class="ReportContent">#Contract_Title#</td>
					<td class="ReportContent">#Program_Manager#</td>
					<td class="ReportContent">#Payment_Type_Name#</td>
					<td class="ReportContent">#Discount_Identifier_Number#</td>
					<td class="ReportContent">
						<cfif Paid_Amount neq "" AND WithHold_Amt neq "">
										#Evaluate(Paid_Amount - WithHold_Amt)#
						<cfelseif Paid_Amount neq "">
										#Paid_Amount#
						<cfelse>
										N/A
						</cfif>
					</td>
					<td class="ReportContent">#Payment_Cycle#</td>
					<td class="ReportContent"><cfif Trim(Date_Approved) neq "">#DateFormat(Date_Approved, "MM/DD/YYYY")#<cfelse> N/A</cfif></td>
					<td class="ReportContent"><cfif Trim(BB_Request_Approval_Date) neq "">#DateFormat(BB_Request_Approval_Date, "MM/DD/YYYY")#<cfelse>N/A</cfif></td>
					<td class="ReportContent"><cfif Trim(BB_Create_Date) neq "">#DateFormat(BB_Create_Date, "MM/DD/YYYY")#<cfelse>N/A</cfif></td>
					<td class="ReportContent"><cfif Trim(Payment_Start_Date) neq "">#DateFormat(Payment_Start_Date, "MM/DD/YYYY")#<br />#DateFormat(Payment_End_Date, "MM/DD/YYYY")#<cfelse>N/A</cfif></td>
					<td class="ReportContent"><cfif Trim(Approved_on) neq "">#DateFormat(Approved_on, "MM/DD/YYYY")#<cfelse>N/A</cfif></td>
					<!--- <td class="ReportContent"><cfif Trim(Billback_Setup_Duration) neq "">#Billback_Setup_Duration#<cfelse>N/A</cfif></td> --->
					<td class="ReportContent"><cfif Trim(Approval_Duration) neq "">#Approval_Duration#<cfelse>N/A</cfif></td>
					<td class="ReportContent"><cfif Trim(SAP_Payment_Preprocess_Duration) neq "">#SAP_Payment_Preprocess_Duration#<cfelse>N/A</cfif></td>
				</tr>


			<cfif Acc_Specialist eq Accounting_Specialist_UserID AND Payment_History.currentrow eq Payment_History.recordcount>
				<tr>
					<td class="BaseColumnHeader" colspan="3"><b>Avg Approval</b></td>
					<td colspan="10">&nbsp;</td>
					<!--- <td class="ReportContent"><b><cfif Trim(Payment_History_Average.Avg_Billback_Setup_Duration) neq "">#Payment_History_Average.Avg_Billback_Setup_Duration#<cfelse>N/A</cfif></b></td> --->
					<td class="ReportContent"><b><cfif Trim(Payment_History_Average.Avg_Approval_Duration) neq "">#Payment_History_Average.Avg_Approval_Duration#<cfelse>N/A</cfif></b></td>
					<td class="ReportContent"><b><cfif Trim(Payment_History_Average.Avg_SAP_Payment_Preprocess_Duration) neq "">#Payment_History_Average.Avg_SAP_Payment_Preprocess_Duration#<cfelse>N/A</cfif></b></td>
				</tr>
			</cfif>
		</cfloop>
</cfoutput>
</table>