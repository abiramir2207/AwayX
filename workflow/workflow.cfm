<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Workflow</title>
</head>

<body RIGHTMARGIN="8" LEFTMARGIN="8">

<style>
	tr.nobottomborder TD
	{
		border-bottom:none;
	}
</style>
<cfparam name="url.Program_ID" default="0" />

<cfset objWorkflowManager = createObject("component", "components.workflow.WorkFlowManager") />
<cfset objProgram = createObject("component", "components.programs.Program") />
<cfset qGetProgramData = objProgram.getProgramInfo(url.Program_ID) />
<cfset qWorkFlowData = objWorkflowManager.getWorkFlowData(url.Program_ID, 0) />
<cfset qWorkFlowApprovableUsers = objWorkflowManager.getApprovableUsers(programId = url.Program_ID, responsibleUserId = qGetProgramData.Responsible_User_ID) />
<cfif qWorkFlowApprovableUsers.recordCount>
	<cfset qWorkFlowNextApprovableUsers = objWorkflowManager.getNextApprovableUsers(url.Program_ID) />
</cfif>

<cfset displayAuthoritySequence = objWorkflowManager.displayAuthoritySequence() />

<cfinclude template="/common_files/programTranslate.cfm">    <!--- french translation --->

<cfinclude template="/get_access_profile.cfm" />
<cfoutput>
<table border="0" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td>
			<table border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td colspan="100%" bgcolor="">
						<cfinclude template="#Application.Doc_Mapping#/data_files/created/#application.returned_customer_setting.qry_customer_name_font_start#">
						#application.returned_customer_setting.company_name#</DIV>
						<B><font size="+1" color="Navy">[#qGetProgramData.Contract_Number#] - #qGetProgramData.Contract_Title#</FONT></B>
					</td>
				</tr>
			</table>
		</td>
		<td align="right" valign="top">
			<cfif Get_Profile_Settings.View_Workflow_Report_Data eq 1>
				<CF_smallLink
					title = "CRA analysis report"
					url = "CRA_Analysis_Report.cfm?Program_ID=#url.Program_ID#"
					parameters = ""
				>
			</cfif>
			<CF_smallLink
				title = "close window"
				url = "JavaScript:window.close();"
				parameters = ""
			>
		</td>

	</tr>
</table>
</cfoutput>
<br>
<TABLE width="100%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
	<CAPTION align="left"><B><FONT SIZE="2" COLOR="Navy">Workflow</FONT></B>&nbsp;<HR COLOR="Navy"></CAPTION>

	<!---- HEAD ----->
	<TR ID="HEADER" BGCOLOR="#FFCE84">
		<TD STYLE="font-size:11px;" valign="top">
			<b>Action</b>
		</TD>
		<TD STYLE="font-size:11px;" valign="top">
			<b>Name</b>
		</TD>
		<TD STYLE="font-size:11px;" valign="top">
			<b>ID</b>
		</TD>
		<TD STYLE="font-size:11px;" valign="top">
			<b>Position</b>
		</TD>
		<TD STYLE="font-size:11px;" valign="top">
			<b>Profile</b>
		</TD>
		<cfif displayAuthoritySequence>
		<TD STYLE="font-size:11px;" valign="top">
			<b>Authority Sequence</b>
		</TD>
		</cfif>
		<TD STYLE="font-size:11px;" valign="top">
			<b>Date</b>
		</TD>

	</TR>
	<CFOUTPUT QUERY="qWorkFlowData">
	<cfif Action_Type eq 3>
		<cfset qGetAgreeReason = objWorkflowManager.getProgramAgreeReason(url.Program_ID, Action_User_ID) />
	</cfif>
	<TR <cfif Action_Type eq 3 and qGetAgreeReason.RecordCount>class="nobottomborder"</cfif> <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF> HEIGHT="21">
		<TD>
			#Action#
		</TD>
		<TD>
			#Name#
		</TD>
		<TD>
			#ID#
		</TD>
		<TD>
			#Position#
		</TD>
		<TD>
			#Profiles_Desc#
		</TD>
		<cfif displayAuthoritySequence>
		<TD>
			<cfif len(trim(Authority_Sequence_Name))>#trim(Authority_Sequence_Name)#<cfelse>N/A</cfif>
		</TD>
		</cfif>
		<TD>
			#DateFormat(Action_Date, "mm/dd/yyyy")#&nbsp;#TimeFormat(Action_Date, "short")#
		</td>
	</tr>
	<cfif Action_Type eq 3 and qGetAgreeReason.RecordCount>
		<TR>
			<td align="left" colspan="100%" <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF>>
				<CF_openLayer
					Border="Yes"
					BorderSize="1"
					BorderColor="orange"
					Image="/images/plus2.gif"
					ImageOpen="/images/minus2.gif"
					Title="Agree Reasons"
					TitleClosed="Agree Reasons"
					TitleTooltip="Click to Show/Hide"
					TitleFont="font"
					TitleColor="Blue"
					TitleSize="8"
					IsClosed="Yes"
					Width="100%">
				<cfloop query="qGetAgreeReason">
					#replace(Agree_Reason, "#chr(13)##chr(10)#", "<br/>","ALL")# <br/> 
				</cfloop>
				</CF_openLayer>
			</td>
		</TR>
	</cfif>
	</CFOUTPUT>
</TABLE>
<br>
<cfif qWorkFlowApprovableUsers.RecordCount>
<!----- CRA ----->
<CAPTION align="left"><B><FONT SIZE="2" COLOR="Navy">CRA&nbsp;&nbsp;[currently responsible for approval]</FONT></B><HR COLOR="Navy"></CAPTION>
<TABLE width="100%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
	<!---- HEAD ----->
	<TR ID="HEADER" BGCOLOR="#FFCE84">
		<TD STYLE="font-size:11px;" valign="top" width="25%">
			<b>Name</b>
		</TD>
		<TD STYLE="font-size:11px;" valign="top" width="25%">
			<b>Position</b>
		</TD>
		<TD STYLE="font-size:11px;" valign="top" width="25%">
			<b>Profile</b>
		</TD>
		<cfif displayAuthoritySequence>
		<TD STYLE="font-size:11px;" valign="top" width="25%">
			<b>Authority Sequence</b>
		</TD>
		</cfif>
	</TR>
	<CFOUTPUT QUERY="qWorkFlowApprovableUsers">
	<TR <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF> HEIGHT="21">
		<TD>
			#User_Full_Name#
		</TD>
		<td>
			#Position_Label#
		</td>
		<TD>
			#Profiles_Desc#
		</TD>
		<cfif displayAuthoritySequence>
		<TD>
			<cfif len(trim(Authority_Sequence_Name))>#trim(Authority_Sequence_Name)#<cfelse>N/A</cfif>
		</TD>
		</cfif>
	</tr>
	</CFOUTPUT>
</TABLE>

<br>
<!----- NRA ----->
<cfif qWorkFlowNextApprovableUsers.RecordCount and qGetProgramData.Manual_Selection_Of_Approvers neq 1>
<CAPTION align="left"><B><FONT SIZE="2" COLOR="Navy">NRA -</B> after the above person(s) take action, below is a list of person(s) that may need to take approval action.</FONT><HR COLOR="Navy"></CAPTION>
<TABLE width="100%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
	<!---- HEAD ----->
	<TR ID="HEADER" BGCOLOR="#FFCE84">
		<TD STYLE="font-size:11px;" valign="top" width="25%">
			<b>Name</b>
		</TD>
		<TD STYLE="font-size:11px;" valign="top" width="25%">
			<b>Position</b>
		</TD>
		<TD STYLE="font-size:11px;" valign="top" width="25%">
			<b>Profile</b>
		</TD>
		<cfif displayAuthoritySequence>
		<TD STYLE="font-size:11px;" valign="top" width="25%">
			<b>Authority Sequence</b>
		</TD>
		</cfif>
	</TR>
	<CFOUTPUT QUERY="qWorkFlowNextApprovableUsers">
	<TR <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF> HEIGHT="21">
		<TD>
			#User_Full_Name#
		</TD>
		<td>
			#Position_Label#
		</td>
		<TD>
			#Profiles_Desc#
		</TD>
		<cfif displayAuthoritySequence>
		<TD>
			<cfif len(trim(Authority_Sequence_Name))>#trim(Authority_Sequence_Name)#<cfelse>N/A</cfif>
		</TD>
		</cfif>
	</tr>
	</CFOUTPUT>
</TABLE>
</cfif>
</cfif>
<!----- NRA ----->
<cfif application.appSettingsget.get_Setting('GPO_One_Page_Program_Creation') EQ 1 and qGetProgramData.Manual_Selection_Of_Approvers eq 1>

	<cfquery name="qManualNextApprovableUsers" datasource="#application.datasource#">
		SELECT	UP.Position_Label, 
				Profiles.Profiles_Desc , 
				U.Name_First + ' ' + U.Name_Last as User_Full_Name
		FROM	Program_Approval_By_Profile PA
		INNER JOIN _users U ON 
			PA.Approved_by_User_Id = U.User_Id
		INNER JOIN Profiles ON
			Profiles.Profiles_ID = U.Profiles_ID
		INNER JOIN User_Position_Holders UPH ON
			UPH.User_id = u.user_id AND
			UPH.User_Position_Type = 'P' 
		INNER JOIN User_Positions UP ON
			UP.User_Positions_ID = UPH.User_Positions_ID
		WHERE	Program_ID = #url.Program_ID# AND
			Approved_By_User = 0 AND
			pa.Deleted = 0
	</cfquery>

	<CAPTION align="left"><B><FONT SIZE="2" COLOR="Navy">NRA -</B> The next users have been manually selected to take approval action.</FONT><HR COLOR="Navy"></CAPTION>
	<TABLE width="100%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
		<!---- HEAD ----->
		<TR ID="HEADER" BGCOLOR="#FFCE84">
			<TD STYLE="font-size:11px;" valign="top" width="25%">
				<b>Name</b>
			</TD>
			<TD STYLE="font-size:11px;" valign="top" width="25%">
				<b>Position</b>
			</TD>
			<TD STYLE="font-size:11px;" valign="top" width="25%">
				<b>Profile</b>
			</TD>
			<!--- <cfif displayAuthoritySequence>
			<TD STYLE="font-size:11px;" valign="top" width="25%">
				<b>Authority Sequence</b>
			</TD>
			</cfif> --->
		</TR>
		<CFOUTPUT QUERY="qManualNextApprovableUsers">
		<TR <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF> HEIGHT="21">
			<TD>
				#User_Full_Name#
			</TD>
			<td>
				#Position_Label#
			</td>
			<TD>
				#Profiles_Desc#
			</TD>
			<!--- <cfif displayAuthoritySequence>
			<TD>
				<cfif len(trim(Authority_Sequence_Name))>#trim(Authority_Sequence_Name)#<cfelse>N/A</cfif>
			</TD>
			</cfif> --->
		</tr>
		</CFOUTPUT>
	</TABLE>
</cfif>
<br>
<CF_smallLink
	title = "close"
	url = "JavaScript:window.close();"
	parameters = ""
>&nbsp;
</body>
</html>