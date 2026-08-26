<!------ bb_email_info.cfm ----->
<html>
<head>
	<title>email</title>
</head>

<body>
<style>
	.CONFIDENTIALITY_statement_td {
		width: 600px;
		background-color:WhiteSmoke;
		text-align: left;
		font-size: 12px;
		border: thin solid Red;
		
	}

	.email_title_td {
		font-size: 20px;
		font-weight: bold;
		color: Red;
		
	}
	
	.informative_sentence {
		font-weight: bold;
		font-size: 13px;
		
	}

	.informative_sentence_critical_info {
		font-weight: bold;
		font-size: 13px;
		color: red;
		
	}
	
	.tableheaders {
		font-size:13px;
		font-weight:bold;
		border-bottom:thin #FFFFFF 0px; 
			
	}	
	BODY, TD, .normal
	{
		font-family : Arial;
		font-size : 8pt;
		color : Black;
	}
	
	
	TABLE.Maintable TD 
	{
		border-bottom:solid #93BEE2 1px; font-size : 10px;
	}
	
	.normal
	{
		font-family : Arial;
		font-size : 8pt;
		color : Black;
	}	
</style>

<cfoutput>
<table cellspacing="0" cellpadding="0" align="center">
	<tr>
		<td class="email_title_td" align="center">#Message_Title#</td>
	</tr>
</table>
<hr width="600" color="Orange">
<div align="center">
<span class=""informative_sentence"">#Message_Description#</span>.
</div>
<BR><BR>
<table cellspacing="0" cellpadding="3" align="center" width="700">
	<tr BGCOLOR="FFE083">
		<td width="100"><span class="tableheaders">Payable ##</span></td>
		<td width="100"><span class="tableheaders">Billback ##</span></td>
		<td><span class="tableheaders">Date</span></td>
		<td width="300"><span class="tableheaders">Payee Name</span></td>
		<td><span class="tableheaders">Start</span></td>
		<td><span class="tableheaders">-</span></td>
		<td><span class="tableheaders">End</span></td>
		<td><span class="tableheaders">Amount</span></td>
	</tr>
	
		<tr>
			<td><b>#BB_Code#</b></td>
			<td><b>#BB_Reference#</b></td>
			<td><b>#dateformat(BB_Date, 'mm/dd/yyyy')#</b></td>
			<td><b>#BB_Title#</b></td>
			<td><b>#dateformat(BB_Start_Date, 'mm/dd/yyyy')#</b></td>
			<td><b>-</b></td>
			<td><b>#dateformat(BB_End_Date, 'mm/dd/yyyy')#</b></td>
			<td><b>#trim(numberformat(BB_Amount, '___,___,___,___,___.__'))#</b></td>
		</tr>
	
</table>

<hr width="600" color="Orange">

<BR><BR>

<table cellspacing="3" cellpadding="10" align="center">
	<tr>
		<td class="CONFIDENTIALITY_statement_td">
			#application.returned_customer_setting.CONFIDENTIALITY_CONTENT#
		</td>
	</tr>
</table>
<div align="center">this information is current as of #timeformat(Now(), 'h:m:ss tt')# on #dateformat(Now(), 'm/d/yyyy')#</div>
</cfoutput>

</body>
</html>