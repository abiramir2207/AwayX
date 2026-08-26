<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>email</title>
</head>

<body>

<cfinclude template="#Application.Doc_Mapping#\data_files\created\settings\customer_settings\Memory_Data\Data\application_include.cfm">
<cfinclude template="\application_datasource.cfm">

<cfparam name="userid" default="">

<cfif len(userid) NEQ 0>

<cfquery name="getProgramInfo" datasource="#application.datasource#">
	SELECT
		Contract_Number,
		Contract_Reference_Number,
		(_Users.Name_Last + ', ' + _Users.Name_First) AS Released_By_UserName,
		Released_Date,
		Released_Ack_Date
	FROM
		Contract_Main
	LEFT JOIN
		_Users
		On Contract_Main.Released_By = _Users.User_ID
	WHERE
		Released_By = <cfqueryparam cfsqltype="cf_sql_varchar" value="#userid#" >
		AND released_ack_date IS NOT NULL
		AND released = 1
		AND datediff(day,released_ack_date,getdate())  = 1
	ORDER BY
		Contract_Number
</cfquery>

<cfset ActiveDate = dateformat(now(), 'mm/dd/yyyy') >
<cfset informative_sentence = "<span class=""informative_sentence"">All included programs have been released and acknowledged by the ERP </span> <span class=""informative_sentence_critical_info"">as of #ActiveDate#</span>.">

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
		color: Navy;

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
<table cellspacing="0" cellpadding="0" align="center" >
	<tr>
		<td class="email_title_td" align="center">Release Settlement Acknowledgement Notification</td>
	</tr>
</table>

<hr width="600" color="Orange">
<div align="center">#informative_sentence#</div>
<BR><BR>
<table cellspacing="0" cellpadding="3" align="center" width="900" border=1 style="border-collapse:collapsed;border:1px solid black;">
	<tr BGCOLOR="FFE083">
		<td width="120"><span class="tableheaders">Program</span></td>
		<td width="120"><span class="tableheaders">SAP Agreement ID</span></td>
		<td width="300"><span class="tableheaders">Released By</span></td>
		<td width="120"><span class="tableheaders">Released Date</span></td>
		<td width="170"><span class="tableheaders">Acknowledgement Date</span></td>
	</tr>
	<cfloop query="getProgramInfo">
		<tr>
			<td><b>#getProgramInfo.Contract_Number#&nbsp;</b></td>
			<td><b>#getProgramInfo.Contract_Reference_Number#&nbsp;</b></td>
			<td><b>#getProgramInfo.Released_By_UserName#&nbsp;</b></td>
			<td><b>#dateformat(getProgramInfo.Released_Date, 'mm/dd/yyyy')#&nbsp;</b></td>
			<Td><b>#dateformat(getProgramInfo.Released_Ack_Date, 'mm/dd/yyyy')#&nbsp;</b></TD>
		</tr>
	</cfloop>
</table>

<hr width="600" color="Orange">

<BR><BR>

<table cellspacing="3" cellpadding="10" align="center">
	<tr>
		<td class="CONFIDENTIALITY_statement_td">
			#application.returned_customer_setting.confidentiality_content#
		</td>
	</tr>
</table>
<div align="center">this information is current as of #timeformat(Now(), 'h:m:ss tt')# on #dateformat(Now(), 'm/d/yyyy')#</div>
</cfoutput>

</body>
</html>
</cfif>