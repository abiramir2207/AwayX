<script SRC="/script/javascript/fixed_popup.js"></script>

<script language="javascript">
function ErrorLog()
{
			window.close();
}

function CheckFrm()
{
	if(window.Error_frm.Steps_To_Reproduce.value=='' && window.Error_frm.Comments.value=='')
	{
		alert("Please provide us with information before saving.");
		return false;
	}

	else
	{
		document.Error_frm.submit();
		window.close();
	}
}
</script>

<cfparam name="form.saveData" default="0">
<cfparam name="CFML_Error_Log_ID" default="">
<cfparam name="Program_ID" default="0">
<cfparam name="Billback_ID" default="0">
<cfparam name="Deduction_ID" default="0">

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<!--- Start [Save the Error Information] --->
<cfif form.saveData eq 1>
	<cfquery name="saveErrorReason" datasource="#application.datasource#">
		UPDATE CFML_Error_Log
		SET Comments = <CFQUERYPARAM VALUE="#form.comments#" />,
		Steps_To_Reproduce = <CFQUERYPARAM VALUE="#form.Steps_To_Reproduce#" />
		WHERE CFML_Error_Log_ID = '#CFML_Error_Log_ID#'
	</cfquery>

<!--- Only for Program ID's --->
<cfif Program_ID neq 0 AND IsNumeric(Program_ID)>
	<cfquery name="getProgramInfo" datasource="#application.datasource#">
		SELECT Contract_Number
		FROM Contract_Main
		WHERE Contract_Main_id = <CFQUERYPARAM VALUE="#Program_ID#" />
	</cfquery>
		<cfset Program_ID = getProgramInfo.Contract_Number>
</cfif>

<cfif Billback_ID neq 0 AND len(trim(Billback_ID)) GT 0>
	<cfquery name="getBillbackInfo" datasource="#application.datasource#">
		SELECT BB_Code
		FROM Billback
		WHERE Billback_id = <CFQUERYPARAM VALUE="#Billback_ID#" />
	</cfquery>
		<cfset Billback_ID = getBillbackInfo.BB_Code>
</cfif>

<cfif Deduction_ID neq 0 AND len(trim(Deduction_ID)) GT 0>
	<cfquery name="getDeductionInfo" datasource="#application.datasource#">
		SELECT DD_DedID
		FROM Deductions
		WHERE Deduction_id = <CFQUERYPARAM VALUE="#Deduction_ID#" />
	</cfquery>
		<cfset Deduction_ID = getDeductionInfo.DD_DedID>
</cfif>

<cfquery name="getUserInfo" datasource="#application.datasource#">
	SELECT	u.Name_First + ' ' + u.Name_Last As Full_Name,u.User_Code
	,u.User_Email,u.Work_Phone_1 + '-' + u.Work_Phone_2 + '-' + u.Work_Phone_3 As User_Phone
	,CASE uph.User_Position_Type
	WHEN  'P' THEN
	'PRIMARY'
	ELSE
	'SECONDARY'
	END
	As User_Position_Type
	,p.Profiles_Desc,up.Position_Label,asq.Authority_Sequence_Name
	FROM		_Users u
	INNER JOIN	User_Position_Holders uph
	ON 			u.User_ID = uph.User_ID
	INNER JOIN	User_Positions up
	ON 			uph.User_Positions_ID = up.User_Positions_ID
	INNER JOIN  Profiles p
	ON p.Profiles_ID = u.Profiles_ID
	LEFT JOIN Authority_Sequence asq
	ON asq.Authority_Sequence_ID = u.Authority_Sequence_ID
	WHERE u.User_ID  = <cfqueryparam value="#User_ID#" cfsqltype="CF_SQL_VARCHAR">
	AND up.Deleted = 0
	AND uph.deleted = 0
	ORDER BY uph.User_Position_Type
</cfquery>

<cfif getUserInfo.Recordcount GT 0>
<cfsavecontent variable="UserInfo">
	<cfoutput>
		<span style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size:14px;font-weight:bold;color:brown;">
		<cfif Deduction_ID neq 0>DEDUCTION:<cfelseif Billback_ID neq 0>Billback:<cfelseif Program_ID neq 0>PROGRAM:</cfif></span>
		<cfif Deduction_ID neq 0>#Deduction_ID#<P><cfelseif Billback_ID neq 0>#Billback_ID#<P><cfelseif Program_ID neq 0>#Program_ID#<P></cfif>
		<span style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size:14px;font-weight:bold;color:brown;">NAME:</span>
		<cfif getUserInfo.Full_Name neq "">#getUserInfo.Full_Name#<cfelse>No Information</cfif><P>
		<span style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size:14px;font-weight:bold;color:brown;">EMAIL:</span>
		<cfif getUserInfo.user_email neq "">#getUserInfo.user_email#<cfelse>No Information</cfif><P>
		<span style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size:14px;font-weight:bold;color:brown;">PHONE:</span>
		<cfif getUserInfo.user_phone neq "">#getUserInfo.user_phone#<cfelse>No Information</cfif><P>
		<span style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size:14px;font-weight:bold;color:brown;">USER CODE:</span>
		<cfif getUserInfo.user_code neq "">#getUserInfo.user_code#<cfelse>No Information</cfif><P>
		<span style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size:14px;font-weight:bold;color:brown;">PROFILE:</span>
		<cfif getUserInfo.Profiles_Desc neq "">#getUserInfo.Profiles_Desc#<cfelse>No Information</cfif><P>
		<span style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size:14px;font-weight:bold;color:brown;">AUTHORITY SEQUENCE:</span>
		<cfif getUserInfo.Authority_Sequence_Name neq "">#getUserInfo.Authority_Sequence_Name#<cfelse>No Information</cfif><P>
	</cfoutput>
	<cfset Position_List_For_User = "">
	<cfoutput query="getUserInfo">
		<cfif ListFindNoCase(Position_List_For_User,User_Position_Type) eq 0>
			<span style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size:14px;font-weight:bold;color:brown;">#User_Position_Type#&nbsp;POSITION:</span>
		<cfelse>
		#chr(44)#
		</cfif>
		<cfif getUserInfo.Position_Label neq "">#getUserInfo.Position_Label#<cfelse>No Information</cfif>
		<cfif User_Position_Type eq 'PRIMARY'>
		<P>
		</cfif>
		<cfset Position_List_For_User = ListAppend(Position_List_For_User,User_Position_Type)>
	</cfoutput>
</cfsavecontent>
<!--- the user id didn't get passed --->
<cfelse>
	<cfsavecontent variable="UserInfo">
		We were unable to find user information for the user who created this error.
	</cfsavecontent>
</cfif>

<!--- If the user has entered either comments OR steps to reproduce the error, send the email #appSettings.getRemoteEventsEmail()#--->
	<cfif LTRIM(RTRIM(form.comments)) neq "" OR LTRIM(RTRIM(form.Steps_To_Reproduce)) neq "">
        <CFMAIL to = "#appSettings.getRemoteEventsEmail()#"
                from = "#appSettings.getDifferent_From_Address()#"
                subject = "Event #CFML_Error_Log_ID# (Additional Error Info)"
                type = "HTML">
					<span style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size:14px;font-weight:bold;color:brown;">STEPS TO REPRODUCE:</span><br />
					<cfif form.Steps_To_Reproduce neq "">#Replace(EncodeForHTML(form.Steps_To_Reproduce),"#chr(13)##chr(10)#","<br />", "ALL")#<cfelse>No Information provided</cfif>
					<p>
					<span style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size:14px;font-weight:bold;color:brown;">COMMENTS:</span><br />
					<cfif form.comments neq "">#Replace(EncodeForHTML(form.comments),"#chr(13)##chr(10)#","<br />", "ALL")#<cfelse>No Information provided</cfif>
					<p>
					#UserInfo#
		</CFMAIL>
	</cfif>
</cfif>
<!--- End [Save the Error Information] --->


<body onload = "mytimer = setTimeout('fcsOnMe()', 25);">

<!--- Form for the user --->
<form method="post" action="Error_Reason_Frm.cfm" name="Error_frm">
<cfoutput>
	<input type="hidden" name="Program_ID" value="#EncodeForHTMLAttribute(Program_ID)#">
	<input type="hidden" name="Billback_ID" value="#EncodeForHTMLAttribute(Billback_ID)#">
	<input type="hidden" name="Deduction_ID" value="#EncodeForHTMLAttribute(Deduction_ID)#">
</cfoutput>
<table>
		<tr>
			<td align="center"><B>To help us research the error, please enter any information below</B></td>
		</tr>
		<tr>
			<td align="right"><B><FONT COLOR="Red" SIZE="2">[ </FONT><a href="#" onClick="ErrorLog()">close<a><FONT COLOR="Red" SIZE="2"> ]</FONT></B></td>
		</tr>
		<tr>
			<td bgcolor="FFCC99"><b>User Comments/Description:</b></td>
		</tr>
		<tr>
			<td><textarea name="Comments" rows="7" cols="80" onfocus="skipcycle=true" onblur="skipcycle=false"></textarea></td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td bgcolor="FFCC99"><b>Steps To Reproduce:</b></td>
		</tr>
		<tr>
			<td><textarea name="Steps_To_Reproduce" rows="7" cols="80" onfocus="skipcycle=true" onblur="skipcycle=false"></textarea></td>
		</tr>

		<tr>
			<td align="center">
				<input type="hidden" name="saveData" value="1">
				<cfoutput><input type="hidden" name="CFML_Error_Log_ID" value="#CFML_Error_Log_ID#"></cfoutput>
					<span style="font-weight:bold;color:red"> [ </span>
						<a href="#" OnClick="javascript:CheckFrm();" style="font-weight:bold;">save</a>
					<span style="font-weight:bold;color:red"> ] </span>
			</td>
		</tr>

</table>
</form>
</body>