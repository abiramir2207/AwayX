<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>email</title>
</head>

<body>

<cfinclude template="#Application.Doc_Mapping#\data_files\created\settings\customer_settings\Memory_Data\Data\application_include.cfm">
<cfinclude template="\application_datasource.cfm">

<cfparam name="ep.cid" default="0">

<cfquery name="getProgramInfo" datasource="#application.datasource#">
	SELECT
		Contract_Number,
		Contract_Title,
		Contract_Start_Date,
		Contract_End_Date
	FROM
		Contract_Main
	WHERE
		Contract_Main_ID IN(#ep.cid#)
	ORDER BY
		Contract_Number
</cfquery>

<cfif not isnumeric(Contract_Expiration_Range)>
	<!--- there is a program misconfiguration, put email code to admin here --->
	<cfabort>
<cfelse>
	<cfset ExpirationDate = dateformat(Now(), 'mm/dd/yyyy')>
	<cfset informative_sentence = "<span class=""informative_sentence"">Please be advised this program has expired today </span> <span class=""informative_sentence_critical_info"">on #ExpirationDate#</span>.">
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
		<td class="email_title_td" align="center">Program Expiration Notification</td>
	</tr>
</table>
<hr width="600" color="Orange">
<div align="center">#informative_sentence#</div>
<BR><BR>
<table cellspacing="0" cellpadding="3" align="center" width="700">
	<tr BGCOLOR="FFE083">
		<td width="100"><span class="tableheaders">Program</span></td>
		<td width="300"><span class="tableheaders">Title</span></td>
		<td><span class="tableheaders">Start</span></td>
		<td><span class="tableheaders">-</span></td>
		<td><span class="tableheaders">End</span></td>
	</tr>
	<cfloop query="getProgramInfo">
		<tr>
			<td><b>#getProgramInfo.Contract_Number#</b></td>
			<td><b>#getProgramInfo.Contract_Title#</b></td>
			<td><b>#dateformat(getProgramInfo.Contract_Start_Date, 'mm/dd/yyyy')#</b></td>
			<td><b>-</b></td>
			<Td><b>#dateformat(getProgramInfo.Contract_End_Date, 'mm/dd/yyyy')#</b></TD>
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