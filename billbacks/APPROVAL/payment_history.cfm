<!---BJF: So far this page will only be used by Pactiv, but if other clients use the same data structure --->

<cfset Billback_ID = url.BBID>

<!---Get data to display --->

<cfquery name="DataToDisplay" datasource="#application.datasource#">
SELECT Payment.*
FROM BB_Payment_Confirmation Payment
INNER JOIN Contract_Main 
	ON Contract_Main.Contract_Number LIKE '%' + right(left(Payment.Rebate_ID, 10), 7) 
	INNER JOIN Billback_Program 
	ON Billback_Program.Program_ID = Contract_Main.Contract_Main_ID 
	AND Billback_Program.Deleted = 0
	AND Billback_Program.Billback_ID = '#Billback_ID#'
ORDER BY Contract_Number
</cfquery>

<html>
<head>
	<title>Payment History</title>
</head>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="5" TOPMARGIN="5">

<cfinclude template="/billbacks/capture/iframe_style.cfm">
<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

<font color="navy" size="4">Payment History</font>

<table width="100%" cellpadding="2" cellspacing="0" class="Maintable">

<tr bgcolor="orange">
	<td><strong>Description</strong></td>
	<td><strong>Check Number</strong></td>
	<td><strong>Check Date</strong></td>
	<td><strong>Check Amount</strong></td>
	<td><strong>Credit Memo</strong></td>
	<td><strong>Credit Memo Date</strong></td>
	<td><strong>Credit Amount</strong></td>
</tr>

<CFSET currentrowIndex = 0>

<cfoutput query="DataToDisplay">

<CFSET currentrowIndex = currentrowIndex + 1>

<cfset DiscountType = Right(Left(Rebate_ID, 13), 2)>

<cfif DiscountType IS "RR">
	<cfset DiscountType = "Rebate">
</cfif>
<cfif DiscountType IS "GR">
	<cfset DiscountType = "Growth">
</cfif>
<cfif DiscountType IS "LU">
	<cfset DiscountType = Application.LumpsumLabel>
</cfif>
<cfset DiscountNumber = Right(Left(Rebate_ID, 14), 1)>
<cfset PaymentCycle = Right(Rebate_ID, 3)>
<cfset PaymentCycle = "Payment Cycle ##" & numberformat(PaymentCycle)>

<tr <CFIF currentrowIndex mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
	
	<td>#DiscountType# #DiscountNumber#, #PaymentCycle#</td>
	<td>#Check_Number#</td>
	<td>#dateformat(Payment_Date, 'MM/DD/YYYY')#</td>
	<td>#lscurrencyformat(Amount)#</td>
	<td>#Billing_Doc_Num#</td>
	<td>#dateformat(Billing_Date, 'MM/DD/YYYY')#</td>
	<td>#lscurrencyformat(Credit_Amount)#</td>
</tr>
</cfoutput>

</table>

</body>
</html>
