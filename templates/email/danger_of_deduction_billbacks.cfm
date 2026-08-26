<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>email</title>
</head>

<body>

<cfinclude template="#Application.Doc_Mapping#\data_files\created\settings\customer_settings\Memory_Data\Data\application_include.cfm">
<cfinclude template="\application_datasource.cfm">

<cfparam name="db.bbid" default="0">

<cfset db.bbid = listqualify(db.bbid, "'")>

<cfquery name="getBillbackInfo" datasource="#application.datasource#">
	SELECT
		BB_Title,
		BB_Date,
		BB_Start_Date,
		BB_End_Date,
		Billback_ID,
		BB_Amount,
		BB_Reference,
		BB_Code
	FROM
		dbo.Billback
	WHERE
		Billback_ID IN(#preservesinglequotes(db.bbid)#)
</cfquery>

<cfquery name="getBBAgedate" datasource="#application.datasource#">
SELECT     BB_Danger_Range
FROM         dbo.Billback_Settings
</cfquery>

<cfset Billback_Danger_Range = getBBAgedate.BB_Danger_Range>

<cfif not isnumeric(Billback_Danger_Range)>
	<!--- there is a program misconfiguration, put email code to admin here --->
	<cfabort>
<cfelse>
	<cfset ExpirationDate = dateformat(DateAdd('d', Billback_Danger_Range, Now()), 'mm/dd/yyyy')>
	<cfif Billback_Danger_Range EQ 1>
		<cfset informative_sentence = "<span class=""informative_sentence"">Please be advised this payable will be</span> <span class=""informative_sentence_critical_info"">#Billback_Danger_Range# day old on #ExpirationDate# and has not yet been paid</span>.">
	<cfelse>
		<cfset informative_sentence = "<span class=""informative_sentence"">Please be advised this payable will be</span> <span class=""informative_sentence_critical_info"">#Billback_Danger_Range# days old on #ExpirationDate# and has not yet been paid</span>.">
	</cfif>
</cfif>

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
		<td class="email_title_td" align="center">Payable Deduction Warning</td>
	</tr>
</table>
<hr width="600" color="Orange">
<div align="center">#informative_sentence#</div>
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
	<cfloop query="getBillbackInfo">
		<tr>
			<td><b>#getBillbackInfo.BB_Code#</b></td>
			<td><b>#getBillbackInfo.BB_Reference#</b></td>
			<td><b>#dateformat(getBillbackInfo.BB_Date, 'mm/dd/yyyy')#</b></td>
			<td><b>#getBillbackInfo.BB_Title#</b></td>
			<td><b>#dateformat(getBillbackInfo.BB_Start_Date, 'mm/dd/yyyy')#</b></td>
			<td><b>-</b></td>
			<td><b>#dateformat(getBillbackInfo.BB_End_Date, 'mm/dd/yyyy')#</b></td>
			<td><b>#trim(numberformat(getBillbackInfo.BB_Amount, '___,___,___,___,___.__'))#</b></td>
		</tr>
	</cfloop>
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