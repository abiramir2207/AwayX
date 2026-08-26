<!---
	FILENAME:	Program_Alert_Email.cfm
	Copyright:	(c) 2008 Blacksmith Applications, Inc.
	CREATED BY:	Tim Ford
--->

<CFQUERY NAME="qProgramAlertsSP" DATASOURCE="#Application.Datasource#">
	EXEC USP_PROGRAM_ALERTS
</CFQUERY>

<cfoutput>
<cfquery name="qGetAlertingPrograms" datasource="#application.datasource#">
	SELECT	User_Name,
			User_Email,
			Distributor_Contract_Number,
			Distributor_Contract_Title,
			Message,
			Alerting_User_Email
	FROM	Program_Alert_Operator_Programs
	WHERE	Sent = 0
	GROUP BY User_Name, User_Email, Distributor_Contract_Number, Distributor_Contract_Title, Message, Alerting_User_Email
	ORDER BY User_Name, User_Email, Distributor_Contract_Number
</cfquery>

<cfloop query="qGetAlertingPrograms">
	
	<cfset variables.userName 					= qGetAlertingPrograms.User_Name />
	<cfset variables.userEmail 					= qGetAlertingPrograms.User_Email />
	<cfset variables.distributorContractNumber 	= qGetAlertingPrograms.Distributor_Contract_Number />
	<cfset variables.distributorContractTitle	= qGetAlertingPrograms.Distributor_Contract_Title />
	<cfset variables.message 					= qGetAlertingPrograms.Message />
	<cfset variables.alertingUserEmail 			= qGetAlertingPrograms.Alerting_User_Email />
	
	<cfquery name="qGetProgramsToAlertByUser" datasource="#application.datasource#">
		SELECT	Program_Alert_Operator_Programs_ID,
				Operator_Contract_Number,
				Operator_Contract_Title
		FROM	Program_Alert_Operator_Programs
		WHERE	Distributor_Contract_Number = <cfqueryparam value="#variables.distributorContractNumber#" cfsqltype="CF_SQL_VARCHAR" />
		AND		User_Email = <cfqueryparam value="#variables.userEmail#" cfsqltype="CF_SQL_VARCHAR" />
		AND		Sent = 0
		ORDER BY Operator_Contract_Number
	</cfquery>
	
	<cfsavecontent variable="variables.programAlertEmail">
	<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	<style>
		.tableheaders
		{
			font-size:13px;
			font-weight:bold;
			border-bottom:thin ##FFFFFF 0px; 
				
		}	
		BODY, TD, .normal
		{
			font-family : Arial;
			font-size : 8pt;
			color : Black;
		}
		TABLE.Maintable TD 
		{
			border-bottom:solid ##93BEE2 1px; font-size : 10px;
		}
		.normal
		{
			font-family : Arial;
			font-size : 8pt;
			color : Black;
		}	
	</style>
	<title>Program Alert</title>
	</head>
	<body>
		<p>
			<span style="FONT-SIZE: 12pt; FONT-FAMILY: 'Century Gothic'">
				Program Alert Notification
			</span>
			<br>
			<span style="FONT-SIZE: 10pt; FONT-FAMILY: 'Century Gothic'">
				Please be advised that program #variables.distributorContractNumber# has been approved and an alert is being sent on behalf of 
				this program. The message from #variables.distributorContractNumber# is: #variables.message#.
			</span>
		</p>
		<table cellspacing="0" cellpadding="3" width="700">
			<tr>
				<td width="100"><span class="tableheaders">Program</span></td>
				<td width="300"><span class="tableheaders">Title</span></td>
			</tr>
			<cfloop query="qGetProgramsToAlertByUser">
				<tr>
					<td width="100">#Operator_Contract_Number#</td>
					<td width="300">#Operator_Contract_Title#</td>
				</tr>
				
				<cfquery datasource="#application.datasource#">
					UPDATE	Program_Alert_Operator_Programs
					SET		Sent = 1
					WHERE	Program_Alert_Operator_Programs_ID = #Program_Alert_Operator_Programs_ID#
				</cfquery>
				
			</cfloop>
		</table>	
	</body>
	</html>
	</cfsavecontent>

	<CF_EMAILWRAPPER  	
		TO 			= "#variables.userEmail#"
		FROM		= "#variables.alertingUserEmail#"
		SUBJECT		= "Program Alert: #variables.distributorContractNumber# - #variables.distributorContractTitle#"
		TYPE		= "html" 
		messagetype	= "1" 
		generatedby	= "1"
		appArea		= "1"
	>
		#variables.programAlertEmail#
	</CF_EMAILWRAPPER>

</cfloop>
</cfoutput>
