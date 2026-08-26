<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Balance Report</title>
<STYLE>
	.sectionHead
	{
		font-weight:bold;
		font-size:15px;
		color:red;
		border-bottom:2px solid #0000CD;
	}
	.displayRow td 
	{
		border-left:none;
		border-top:none;
		border-bottom:none;
		display : block;
		text-align:right;
	}
	.headerRow td 
	{
		border-left:none;
		border-top:none;
		display : block;
		text-align:right;
	}
	.totalRow td 
	{
		border-left:none;
		border-bottom:none;
		display : block;
		text-align:right;
	}
	.endCell
	{
		border:none;
	}
	.noIndent
	{
		border-left:none;
		border-right:none;
		border-top:none;
		text-align:left;
	}
	.totalCell
	{
		border-right:none;
		text-align:left;
	}
</STYLE>
</head>
<!---initialize BalanceReport component--->
<cfset BalanceReport = CreateObject("component","components.reports.BalanceReport").init() />

<cfparam name="FORM.Type" default="bb" />
<cfparam name="FORM.Date" default="" />

<!---get balance summary--->
<cfset qBalanceSummary = BalanceReport.getBillbackSummary(FORM.Date) />
<body>
<cfoutput>
<form name="SearchForm" action="balance_report.cfm" method="post">
<table width="100%">
	<TR VALIGN="TOP">
		<TD COLSPAN="100%" CLASS="sectionHead"><strong>Balance Report</strong></TD>
	</TR>
</table>
<table cellpadding="5" cellspacing="0">
	<tr>
		<td>
			<b>Report Type</b>
		</td>
		<td>
			<b>Date</b>
		</td>
	</tr>
	<tr>
		<td>
			<select name="type">
				<option value="bb" <cfif form.type eq "bb">selected</cfif>>Billback</option>
				<option value="dd" <cfif form.type eq "dd">selected</cfif>>Deduction</option>
			</select>
		</td>
		<td>
			<CF_EASYDATE FORMNAME="SearchForm" FIELDNAME="Date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.Date#">
		</td>
	</tr>
	<tr>
		<td colspan="100%">
			<CF_button
				button_name		=	""
				button_caption	=	"generate report"
				button_action	=	"document.SearchForm.submit();"
				button_type		=	"javascript_link"
				button_width	=	"50"
				button_color	=	"Navy"
				button_tip		=	"generate report"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
		</td>
	</tr>
</table>
<br>
<cfloop query="qBalanceSummary">
<table border="1" cellpadding="2" cellspacing="0" width="100%">
	<tr bgcolor="##FFFFCC">
		<td colspan="100%" style="border-top:none;border-left:none;border-right:none;">
			Billback:<b>#BB_Code#</b>&nbsp;&nbsp;
			Vendor Name:<b>#Vendor_Name#</b>&nbsp;&nbsp;
			Vendor ID:<b>#Vendor_ID#</b>&nbsp;&nbsp;
			Distributor:<b>#Name#</b>
		</td>
	</tr>
	<tr class="headerRow">
		<td style="border-right:none">&nbsp;</td>
		<td><b>910 Amount</b></td>
		<td><b>910 Fund Number</b></td>
		<cfif form.type eq "bb">
			<td><b>700 Amount</b></td>
			<td><b>700 Fund Number</b></td>
		<cfelse>
			<td><b>1700 Amount</b></td>
			<td><b>1700 Fund Number</b></td>
		</cfif>
		<td class="endCell"><b>900 Amount</b></td>
	</tr>
	<cfif form.type eq "bb">
		<cfset qBBDetail = BalanceReport.getBillbackDetail(Billback_ID) />
	<cfelse>
		<cfset qBBDetail = BalanceReport.getDeductionDetail(Billback_ID) />
	</cfif>
	<cfif qBBDetail.RecordCount>
		<cfloop query="qBBDetail">
			<tr class="displayRow">
				<td style="border-right:none">&nbsp;</td>
				<td>#DollarFormat(Approved_Amount)#</td>
				<td><cfif not Len(trim(Fund_Number))>N/A</cfif>#Fund_Number#</td>
				<td>#DollarFormat(Allocated_Amount)#</td>
				<td><cfif not Len(trim(SCOA_Fund_Number))>N/A</cfif>#SCOA_Fund_Number#</td>
				<td class="endCell">&nbsp;</td>
			</tr>
		</cfloop>
	<cfelse>
		<tr class="displayRow">
			<td style="border:none">&nbsp;</td>
			<td>N/A</td>
			<td>N/A</td>
			<td>N/A</td>
			<td>N/A</td>
			<td class="endCell">&nbsp;</td>
		</tr>
	</cfif>
	<cfif form.type eq "bb">
		<cfset qBBTotal = BalanceReport.getBillbackTotal(Billback_ID) />
	<cfelse>
		<cfset qBBTotal = BalanceReport.getDeductionTotal(Billback_ID) />
	</cfif>
	<tr class="totalRow">
		<td class="totalCell"><b>Total:</b></td>
		<td><b>#DollarFormat(qBBTotal.Approved_Amount)#</b></td>
		<td style="border-right:none">&nbsp;</td>
		<td><b>#DollarFormat(qBBTotal.Allocated_Sum)#</b></td>
		<td style="border-right:none">&nbsp;</td>
		<td style="border-right:none"><b>#DollarFormat(qBBTotal.Approved_Sum)#</b></td>
	</tr>
</table>
<br><br>
</cfloop>

</form>
</cfoutput>
</body>
</html>
