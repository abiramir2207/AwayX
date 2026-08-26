<!---
	Name: profile_list_users.cfm        
	Copyright (c) 2006 Blacksmith Applications, Inc.       
             
	Description:
		Displays Users and Templates associated to this profile.
	Usage:
		Access by clicking on the 'list' link on the Profile Management Console.
--->	

<html>
<head>
<cfparam name="url.pid" default="0">
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

<!--- Query for Users related to Profile --->
<cfquery name="getUsers" datasource="#application.datasource#">
SELECT     UPPER(Name_First + ' ' + Name_Last) [Name], 
	(
		select (CAST(Authority_Sequence_Order AS VARCHAR(25)) + ' - ' + Authority_Sequence_Name)
		from Authority_Sequence 
		where Authority_Sequence.Authority_Sequence_ID = _Users.Authority_Sequence_ID
		and deleted = 0
	) [Authority_Sequence_Name],

	(	
		select (CAST(HQ_Positions.HQ_Position_ID AS VARCHAR(25)) + ' - ' + HQ_Positions.HQ_Position_Name)
		from HQ_Positions INNER JOIN Authority_Sequence 
		on HQ_Positions.HQ_Position_ID = Authority_Sequence.HQ_Position_ID
		where Authority_Sequence.Authority_Sequence_ID = _Users.Authority_Sequence_ID
		and HQ_Positions.deleted = 0
	) [HQ_Position],
  CASE 
    WHEN (
		select count(*) 
		from user_position_holders 
		where User_Position_Holders.User_ID = _users.user_id 
		AND User_Position_Holders.User_Positions_ID <> 0
		AND user_position_holders.deleted = 0
	 ) > 1 
    THEN 'Multiple' 
    WHEN (
		select count(*) 
		from user_position_holders 
		where User_Position_Holders.User_ID = _users.user_id 
		AND User_Position_Holders.User_Positions_ID <> 0
		AND User_Position_Holders.deleted = 0
	) > 0 
    THEN (
		select (CAST(user_positions.user_positions_id AS VARCHAR(25)) + ' - ' + position_label) [Position_Label] 
		from user_positions inner join User_Position_Holders 
	  	on User_Position_Holders.User_Positions_ID = User_Positions.User_Positions_ID
	  	and User_Position_Holders.User_ID = _Users.User_ID 
		where User_Position_Holders.User_Positions_ID <> 0
		AND User_Position_Holders.deleted = 0
		AND User_Positions.deleted = 0
	)
  END [Position_Label]
from _users
where Profiles_ID = '#url.pid#' AND
 _users.deleted = 0
ORDER BY Name_Last ASC
</cfquery>

<!------ Get profile settings ----->
<cfset profile = CreateObject("component","components.user.Profile").init() />
<cfset Get_Profile_Settings = profile.getProfileSettings(url.pid)>

<!--- The following queries select templates associated to this profile. --->
<cfquery name="templateProgramAccess" datasource="#application.datasource#">
DECLARE @ForbidAllowProfilesInTemplates Bit

select	@ForbidAllowProfilesInTemplates = ForbidAllowProfilesInTemplates
from	_Application_Settings

SELECT	UPPER(Created_Type) [Created_Type], @ForbidAllowProfilesInTemplates [Forbid]
FROM	Program_Control_Panel_Options
WHERE	Deleted = 0
AND	IsDominant = 1
AND
( 
	(
		@ForbidAllowProfilesInTemplates = 0 AND ProgramControl_Panel_Options_ID IN
		(
			select	UPPER(Template_ID) [Template_ID]
			from	Profile_Forbidden_Template
			where	Deleted = 0
			and	Profile_ID = #url.pid#
			and	Forbid_Type = @ForbidAllowProfilesInTemplates
			and	Forbid_Access_Type = 1
		)
	)
OR 
	(
		@ForbidAllowProfilesInTemplates = 1 AND ProgramControl_Panel_Options_ID NOT IN
		( 	
			select	UPPER(Template_ID) [Template_ID]
			from	Profile_Forbidden_Template
			where	Deleted = 0
			and	Profile_ID = #url.pid#
			and	Forbid_Type = @ForbidAllowProfilesInTemplates
			and	Forbid_Access_Type = 1
		)
	)
)
ORDER BY Created_Type
</cfquery>

<cfquery name="templateProgramApproval" datasource="#application.datasource#">
DECLARE @ForbidAllowProfilesInTemplates Bit

select	@ForbidAllowProfilesInTemplates = ForbidAllowProfilesInTemplates
from	_Application_Settings

SELECT	UPPER(Created_Type) [Created_Type], @ForbidAllowProfilesInTemplates [Forbid]
FROM	Program_Control_Panel_Options
WHERE	Deleted = 0
AND	IsDominant = 1
AND
( 
	(
		@ForbidAllowProfilesInTemplates = 0 AND ProgramControl_Panel_Options_ID IN
		(
			select	UPPER(Template_ID) [Template_ID]
			from	Profile_Forbidden_Template
			where	Deleted = 0
			and	Profile_ID = #url.pid#
			and	Forbid_Type = @ForbidAllowProfilesInTemplates
			and	Forbid_Access_Type = 2
		)
	)
OR 
	(
		@ForbidAllowProfilesInTemplates = 1 AND ProgramControl_Panel_Options_ID NOT IN
		( 	
			select	UPPER(Template_ID) [Template_ID]
			from	Profile_Forbidden_Template
			where	Deleted = 0
			and	Profile_ID = #url.pid#
			and	Forbid_Type = @ForbidAllowProfilesInTemplates
			and	Forbid_Access_Type = 2
		)
	)
)
ORDER BY Created_Type
</cfquery>

<cfquery name="templateProgramAgreeOnly" datasource="#application.datasource#">
DECLARE @ForbidAllowProfilesInTemplates Bit

select	@ForbidAllowProfilesInTemplates = ForbidAllowProfilesInTemplates
from	_Application_Settings

SELECT	UPPER(Created_Type) [Created_Type], @ForbidAllowProfilesInTemplates [Forbid]
FROM	Program_Control_Panel_Options
WHERE	Deleted = 0
AND	IsDominant = 1
AND
( 
	(
		@ForbidAllowProfilesInTemplates = 0 AND	ProgramControl_Panel_Options_ID IN
		(
			select	UPPER(Template_ID) [Template_ID]
			from	Profile_Forbidden_Template
			where	Deleted = 0
			and	Profile_ID = #url.pid#
			and	Forbid_Type = @ForbidAllowProfilesInTemplates
			and	Forbid_Access_Type = 5
		)
	)
OR 
	(
		@ForbidAllowProfilesInTemplates = 1 AND	ProgramControl_Panel_Options_ID NOT IN
		( 	
			select	UPPER(Template_ID) [Template_ID]
			from	Profile_Forbidden_Template
			where	Deleted = 0
			and	Profile_ID = #url.pid#
			and	Forbid_Type = @ForbidAllowProfilesInTemplates
			and	Forbid_Access_Type = 5
		)
	)
)
ORDER BY Created_Type
</cfquery>

<cfquery name="templateBillbackApprove" datasource="#application.datasource#">
DECLARE @ForbidAllowProfilesInTemplates Bit

select	@ForbidAllowProfilesInTemplates = ForbidAllowProfilesInTemplates
from	_Application_Settings

SELECT	UPPER(Created_Type) [Created_Type], @ForbidAllowProfilesInTemplates [Forbid]
FROM	Program_Control_Panel_Options
WHERE	Deleted = 0
AND	IsDominant = 1
AND
( 
	(
		@ForbidAllowProfilesInTemplates = 0 AND	ProgramControl_Panel_Options_ID IN
		(
			select	UPPER(Template_ID) [Template_ID]
			from	Profile_Forbidden_Template
			where	Deleted = 0
			and	Profile_ID = #url.pid#
			and	Forbid_Type = @ForbidAllowProfilesInTemplates
			and	Forbid_Access_Type = 4
		)
	)
OR 
	(
		@ForbidAllowProfilesInTemplates = 1 AND	ProgramControl_Panel_Options_ID NOT IN
		( 	
			select	UPPER(Template_ID) [Template_ID]
			from	Profile_Forbidden_Template
			where	Deleted = 0
			and	Profile_ID = #url.pid#
			and	Forbid_Type = @ForbidAllowProfilesInTemplates
			and	Forbid_Access_Type = 4
		)
	)
)
ORDER BY Created_Type
</cfquery>

<cfif appSettings.getPullbacksOn()>
<cfquery name="templatePullbackApprove" datasource="#application.datasource#">
DECLARE @ForbidAllowProfilesInTemplates Bit

select	@ForbidAllowProfilesInTemplates = ForbidAllowProfilesInTemplates
from	_Application_Settings

SELECT	UPPER(Created_Type) [Created_Type], @ForbidAllowProfilesInTemplates [Forbid]
FROM	Program_Control_Panel_Options
WHERE	Deleted = 0
<CFIF Get_Profile_Settings.Approve_Pullback EQ 1>
AND	IsDominant = 1
AND
( 
	(
		@ForbidAllowProfilesInTemplates = 0 AND	ProgramControl_Panel_Options_ID IN
		(
			select	UPPER(Template_ID) [Template_ID]
			from	Profile_Forbidden_Template
			where	Deleted = 0
			and	Profile_ID = #url.pid#
			and	Forbid_Type = @ForbidAllowProfilesInTemplates
			and	Forbid_Access_Type = 6
		)
	)
OR 
	(
		@ForbidAllowProfilesInTemplates = 1 AND	ProgramControl_Panel_Options_ID NOT IN
		( 	
			select	UPPER(Template_ID) [Template_ID]
			from	Profile_Forbidden_Template
			where	Deleted = 0
			and	Profile_ID = #url.pid#
			and	Forbid_Type = @ForbidAllowProfilesInTemplates
			and	Forbid_Access_Type = 6
		)
	)
)
<CFELSE>
AND		1=2
</CFIF>
ORDER BY Created_Type
</cfquery>
</cfif>

<title>Profile Detail</title></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

<SCRIPT type="text/javascript" language="JavaScript">
	function centerWindow()
	{
		var centerHeight = 0;
		var centerWidth = 0;
			
		centerHeight = ((parseInt(screen.availHeight) / 2) - (parseInt(document.body.clientHeight) / 2));
		centerWidth = ((parseInt(screen.availWidth) / 2) - (parseInt(document.body.clientWidth) / 2));
		
		if (centerHeight < 0)
			centerHeight = 0;
		if (centerWidth < 0)
			centerWidth = 0;
		window.moveTo(centerHeight,centerWidth);
	}
</SCRIPT>

<style type="text/css">
table {border-collapse:collapse;border: 1px solid RGB(00,00,00);}
th, td  {border: 1px solid RGB(00,00,00);padding-left:4px;}
/*Formatting of Central Header*/
.header {font-size:10pt;font-weight:bold;font-family:verdana;padding:5px;text-align:left;background-color: RGB(0,0,153);color: RGB(255,255,255);}

/*Formatting for Sub Section Headers*/
td.minorheader, th.minorheader {font-weight:bold;font-family:verdana;padding:3px;background-color: RGB(221,187,132);color: RGB(255,255,255);}
</style>
</head>


<body>
<table width="800px" border="1">
  <tr>
    <th colspan="100%" class="header">Users Associated with Profile</th>
  </tr>
  <!--- List Users Header --->
  <tr>
    <td class="minorheader">Name</td>
    <td class="minorheader">Position Label</td>
    <td class="minorheader">Authority Sequence</td>
	<td class="minorheader">HQ Position</td>
  </tr>
  <!--- Output Users Associated with this Profile --->
 <cfif getUsers.recordcount GTE 1>
  <cfoutput query="getUsers">
  <tr>
    <td>#getUsers.Name#</td>
    <td>#getUsers.Position_Label#&nbsp;</td>
    <td>#getUsers.Authority_Sequence_Name#&nbsp;</td>
	<td>#getUsers.HQ_Position#</td>
  </tr>
  </cfoutput>
  <cfelse>
  <tr><td colspan="100%" style="padding:10px;text-align:center;">There are no users associated to this profile.</td></tr>
  </cfif>
 <!--- Templates associated with this Profile ---> 
 <tr>
    <th colspan="100%"  class="header">Templates Associated with Profile</th>
 </tr>
 <tr>
 	<td colspan="100%" class="minorheader">Template Program Access</td>
 </tr> 
  <tr>
 	<cfif templateProgramAccess.recordcount GT 0>
		<cfset cellIndex = 0>
		<cfoutput query="templateProgramAccess">
		<cfif cellIndex EQ 0>
		<tr>
		</cfif>
			<td width="25%">#templateProgramAccess.created_type#</td>
			<cfset cellIndex = cellIndex + 1>
		<cfif cellIndex EQ 4>
			</tr>
			<cfset cellIndex = 0>
		</cfif>
		  </cfoutput>
	<cfelse>
	<td colspan="100%" style="padding:10px;text-align:center;">There are no templates associated with this profile.</td>
	</cfif>

 </tr> 
 <tr>
 	<td colspan="100%" class="minorheader">Template Program Approval</td>
 </tr> 
 <tr>
 	
	<cfif templateProgramApproval.recordcount GT 0>
		<cfset cellIndex = 0>
		<cfoutput query="templateProgramApproval">
		<cfif cellIndex EQ 0>
		<tr>
		</cfif>
			<td width="25%">#templateProgramApproval.created_type#</td>
			<cfset cellIndex = cellIndex + 1>
		<cfif cellIndex EQ 4>
			</tr>
			<cfset cellIndex = 0>
		</cfif>
		  </cfoutput>
	<cfelse>
	<td colspan="100%" style="padding:10px;text-align:center;">There are no templates associated with this profile.</td>
	</cfif>
	
 </tr>  

 <tr>
 	<td colspan="100%" class="minorheader" >Template Program Agree Only</td>
 </tr>
 <tr>	
	<cfif templateProgramAgreeOnly.recordcount GT 0>
		<cfset cellIndex = 0>
		<cfoutput query="templateProgramAgreeOnly">
		<cfif cellIndex EQ 0>
		<tr>
		</cfif>
			<td width="25%">#templateProgramAgreeOnly.created_type#</td>
			<cfset cellIndex = cellIndex + 1>
		<cfif cellIndex EQ 4>
			</tr>
			<cfset cellIndex = 0>
		</cfif>
		  </cfoutput>
	<cfelse>
		<td colspan="100%" style="padding:10px;text-align:center;">There are no templates associated with this profile.</td>
	</cfif>
	
 </tr>
 <tr>
 	<td colspan="100%" class="minorheader">Template Billback Approve</td>
 </tr>

 	
	<cfif templateBillbackApprove.recordcount GT 0>
		<cfset cellIndex = 0>
		<cfoutput query="templateBillbackApprove">
		<cfif cellIndex EQ 0>
		<tr>
		</cfif>
			<td width="25%">#templateBillbackApprove.created_type#</td>
			<cfset cellIndex = cellIndex + 1>
		<cfif cellIndex EQ 4>
			</tr>
			<cfset cellIndex = 0>
		</cfif>
		</cfoutput>
	<cfelse>
		<td colspan="100%" style="padding:10px;text-align:center;">There are no templates associated with this profile.</td>
	</cfif>
	
 </tr>
 
<cfif appSettings.getPullbacksOn()>
 <tr>
 	<td colspan="100%" class="minorheader"><cfoutput>Template #appSettings.getPullbackLabel()# Approve</cfoutput></td>
 </tr>

 	
	<cfif templatePullbackApprove.recordcount GT 0>
		<cfset cellIndex = 0>
		<cfoutput query="templatePullbackApprove">
		<cfif cellIndex EQ 0>
		<tr>
		</cfif>
			<td width="25%">#created_type#</td>
			<cfset cellIndex = cellIndex + 1>
		<cfif cellIndex EQ 4>
			</tr>
			<cfset cellIndex = 0>
		</cfif>
		</cfoutput>
	<cfelse>
		<td colspan="100%" style="padding:10px;text-align:center;">There are no templates associated with this profile.</td>
	</cfif>
	
 </tr> 
</cfif>
 
<tr >	
	<td colspan="100%" align="center">
		<FONT COLOR="Red" style="font-weight : bold; font-size: 12px;">[</FONT>&nbsp;
			<a href="javascript:(void);" onclick="javascript:window.close();return false"><span style="color: Blue; font-weight: bold; font-size: 11px;" onmouseover="javascript:this.style.textDecoration='underline';" onmouseout="javascript:this.style.textDecoration='none';" title="Close this window">Close this window</span></a>
		&nbsp;<FONT COLOR="Red" style="font-weight : bold;font-size: 12px;">]</FONT>
		</td></tr>
</table>
</body>
</html>
