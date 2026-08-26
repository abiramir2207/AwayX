<!---
	You must pass in: Contract_Main_ID (only one, if you have multiple, loop through the include
	This page is called from: 	
	- /common_files/contract/program_post_approval_status_change.cfm
--->
<cfinclude template="#Application.Doc_Mapping#\data_files\created\settings\customer_settings\Memory_Data\Data\application_include.cfm">
<cfinclude template="\application_datasource.cfm">
<cfset didWeSendEmail = 0 />

<cfparam name="LocationFrom" default="Auto">	
	
	<!--- <!--- <!--- <!--- <!--- STATUS CHANGE NOTIFICATION EMAIL ---> ---> ---> ---> --->		
		
	<cfif NOT isDefined("appSettings")>
		<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
		<cfset appSettings = genSettingsManager.get()>
	</cfif>

	<cfquery name="getProgramInfo" datasource="#application.datasource#">
		SELECT
			Contract_Number,
			Contract_Title,
			Contract_Start_Date,
			Contract_End_Date
		FROM
			Contract_Main
		WHERE
			Contract_Main_ID IN(#Contract_Main_ID#)
		ORDER BY
			Contract_Number
	</cfquery>

	<!--- Dev Note: Clay 8967  --->

	<cfquery name="GetFromUserEmail" datasource="#application.datasource#">
		SELECT 	Top 1 U.user_email
		FROM	_users U 
		INNER JOIN Profile_Post_Approval_Status P ON U.Profiles_ID = P.Profiles_ID
		WHERE 	1 = 1
			and P.Deleted = 0 
			and P.Program_Post_Approval_Status_ID = 1
			and U.Deleted = 0
			and U.User_Email IS NOT NULL
			and len(U.User_Email) > 3
			and U.User_Email NOT LIKE '%bigredflame%'
		order by U.User_Email ASC
	</cfquery>

	<cfquery name="GetToUserEmails" datasource="#application.datasource#">
		SELECT 	DISTINCT U.user_email
		FROM	_users U 
		INNER JOIN Profile_Post_Approval_Status P ON U.Profiles_ID = P.Profiles_ID
		WHERE 	1 = 1
			and P.Deleted = 0 
			and P.Program_Post_Approval_Status_ID = 2
			and U.Deleted = 0
			and U.User_Email IS NOT NULL
			and len(U.User_Email) > 3
			and U.User_Email NOT LIKE '%bigredflame%'
		order by U.User_Email ASC
	</cfquery>
	
	<cfset EmailList = "">		
	<cfset EmailList = valuelist(GetToUserEmails.User_Email)>
	
	<cfoutput>		
			<cfset AlreadySentTo = "">
			<cfloop index="EAddr" list="#EmailList#">
			
			<cfif EAddr IS NOT GetFromUserEmail.User_Email AND ListContains(AlreadySentTo, EAddr) IS False>
				<cfset AlreadySentTo = listappend(AlreadySentTo,EAddr)> 
	
				<CF_EMAILWRAPPER 
					TO			=	"#EAddr#"
					FROM		=	"#GetFromUserEmail.User_Email#"
					SUBJECT		=	"Research for Program #getProgramInfo.Contract_Number# is Complete."
					TYPE		=	"html" 
					messagetype="1" 
					generatedby="2"
					appArea="1">
					<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
					
					<html>
					<head>
						<title>email</title>
					</head>
					
					<body>
					<cfset ActiveDate = dateformat(now(), 'mm/dd/yyyy') >
					<cfset informative_sentence = "<span class=""informative_sentence"">Research for this program is complete </span> <span class=""informative_sentence_critical_info"">as of #ActiveDate#</span>.">
					
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
					
					<cfoutput>
					<table cellspacing="0" cellpadding="0" align="center">
						<tr>
							<td class="email_title_td" align="center">Program Research Completed Notification</td>
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
				</CF_EMAILWRAPPER>
				
				</cfif>
			</cfloop>
			<cfset didWeSendEmail = 1 />
		</cfoutput>