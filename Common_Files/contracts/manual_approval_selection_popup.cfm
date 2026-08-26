<!---
	Name:          	manual_approval_selection_popup.cfm
	Copyright:     	Copyright (c) 2011 Blacksmith Applications, Inc.
	Created Date:  	01/13/2015
	Created By:    	Tim Ford
	Description:   	Page to display for Manual Approval Profile Selection
	Usage:
--->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Manual Approval Selection</title>
	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
</head>

<body>

<script>
function check_all( element ) {
  $('.cbox').attr('checked', element.checked);
}

function check_all2( element ) {
  $('.cbox2').attr('checked', element.checked);
}

function submitForm()
{
	document.selectProfiles.saveProfiles.value = 1;
	document.selectProfiles.submit();
}
</script>


<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = application.appSettingsGet>
<CFINCLUDE TEMPLATE="/Get_Access_Profile.cfm">

<cfset objProgram = CreateObject("component", "components.programs.Program") />
<cfset programManager = CreateObject("component", "components.programs.ProgramManager") />
<cfset ApprovalManager = CreateObject("component", "components.programs.Approval.ApprovalManager") />
<cfset userManager = CreateObject("component", "components.user.UserManager").init() />
<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />
<cfset objWorkflowManager = createObject("component", "components.workflow.WorkFlowManager") />


<cfsetting showdebugoutput="yes" />

<cfparam name="url.templateID"			default="" />
<cfparam name="url.programID"			default="" />
<cfparam name="form.templateID"			default="#url.templateID#" />
<cfparam name="form.programID"			default="#url.programID#" />
<cfparam name="form.saveProfiles"		default="0" />
<cfparam name="form.User_ID"			default="" />


<cfset qGetProgramData = objProgram.getProgramInfo(form.programID) />
<cfset displayAuthoritySequence = objWorkflowManager.displayAuthoritySequence() />

<!---
<cfquery name="qCallPopulateProgramApprovablePositions" datasource="#application.datasource#">
	EXEC Populate_Program_Approvable_Positions '#form.programID#'
</cfquery>
--->
<!---Tim Ford - WR D97740 - Approve beyond budget: Adding code to filter out users based on the following criteria:
	1. A budget exists for the program
	2. The trade amount is not within the budgeted amount
	3. The user does not have approval rights beyond budget
  --->
<cfquery NAME="qCheckBudgetDollarForProgram" datasource="#application.datasource#">
	IF OBJECT_ID('tempdb..##tmp_comm_upd_program_budget_selection') IS NOT NULL
	DROP TABLE ##tmp_comm_upd_program_budget_selection

	create table ##tmp_comm_upd_program_budget_selection (
		contract_main_id int,
		Budget_Class_ID int, Budget_Class_Desc varchar(200),
		start_date datetime, end_date datetime,
		allocation_start_date datetime, allocation_end_date datetime,
		Budget_ID int, Budget_Desc varchar(200),
		Budget_Contribution_Factor_Type_ID smallint, Allocation_Position_Level smallint,
		user_position_id int,
		position_label  varchar(200),
		bsa_foodservice_customers_id uniqueidentifier,
		shr_ship_to varchar(50),
		distributor_name  varchar(200),
		Budget_Dollar decimal(20, 0),
		Committed_Dollar decimal(20, 0),
		Actual_Dollar decimal(20, 0),
		Revision_Committed_Adjustment decimal(20, 2),
		Budget_Balance decimal(20, 0),
		Program_Trade_Spend_Dollar_LS decimal(20, 2),
		Program_Trade_Spend_Dollar_Non_LS decimal(20, 2),
		Program_Trade_Spend_Dollar decimal(20, 2),
		Budget_Balance_After_Approval decimal(20, 2) NULL DEFAULT ((0.0))
	)

	insert into ##tmp_comm_upd_program_budget_selection
	EXEC ADV_BUDGET_GET_AVAIL_FOR_PGM #form.programID#

	select	*
	from	##tmp_comm_upd_program_budget_selection
	order by allocation_end_date
</cfquery>

<cfquery name="qGetProfileUsers" datasource="#application.datasource#">
	SELECT 	DISTINCT
			_Users.User_ID,
			Profiles.Profiles_ID,
			Profiles.Profiles_Short_Desc,
			Profiles.Profiles_Desc,
			_Users.Name_First + ' ' + _Users.Name_Last User_Full_Name,
			User_Positions.Position_Label,
			ISNULL(Authority_Sequence.Authority_Sequence_Name, '') AS Authority_Sequence_Name
	FROM 	Profiles
			INNER JOIN Profiles_Settings ON Profiles_Settings.Profiles_ID = Profiles.Profiles_ID
			<cfif appSettings.get_Setting('GPO_One_Page_Program_Creation') EQ 0>
				AND Profiles_Settings.Cont_Prog_Approval_Rights = 1
				AND Profiles_Settings.Cont_Prog_View_Margins = 1
			</cfif>
			AND Profiles_Settings.Deleted = 0
			INNER JOIN Profile_Forbidden_Template on Profile_Forbidden_Template.Profile_ID = Profiles.Profiles_ID
				AND Profile_Forbidden_Template.Deleted = 0
				AND Profile_Forbidden_Template.Forbid_Type = 0
				<cfif appSettings.get_Setting('GPO_One_Page_Program_Creation') EQ 0>
					AND Profile_Forbidden_Template.Forbid_Access_Type = 2
				<cfelse>
					AND Profile_Forbidden_Template.Forbid_Access_Type IN (5,2)
				</cfif>
				AND	Profile_Forbidden_Template.Template_ID = '#form.templateID#'
			INNER JOIN _Users on _Users.Profiles_ID = Profiles_Settings.Profiles_ID and _Users.Deleted = 0
			INNER JOIN User_Position_Holders on User_Position_Holders.User_ID = _Users.User_ID and User_Position_Holders.User_Position_Type = 'P' and User_Position_Holders.deleted = 0
			INNER JOIN User_Positions on User_Positions.User_Positions_ID = User_Position_Holders.User_Positions_ID AND User_Positions.Deleted = 0
			LEFT JOIN Authority_Sequence ON Authority_Sequence.Authority_Sequence_ID = _Users.Authority_Sequence_ID and Authority_Sequence.Deleted = 0
	WHERE	Profiles.Deleted = 0
	AND		_Users.User_ID NOT IN (SELECT Approved_By_User_ID FROM Program_Approval_By_Profile WHERE ProgramControl_Panel_Options_ID = '#form.templateID#' AND Program_ID = '#form.programID#')
	<cfif appSettings.get_Setting('GPO_One_Page_Program_Creation') EQ 0>
		AND		Profiles.Profiles_ID NOT IN (SELECT Profile_ID from Profile_Forbidden_Template where Template_ID = '#form.templateID#' and Forbid_Type = 0 and Forbid_Access_Type = 5)
	<cfelse>
		AND _Users.User_ID NOT IN (SELECT User_Id FROM Program_Agree WHERE ProgramId = '#form.programID#' AND user_Agree = 1)
	</cfif>
	<!---Tim Ford - WR D97740 - Approve beyond budget: Validation for budgets --->
	<cfif qCheckBudgetDollarForProgram.recordCount>
	AND		(#qCheckBudgetDollarForProgram.Budget_Contribution_Factor_Type_ID# = 3
	or #qCheckBudgetDollarForProgram.Budget_Contribution_Factor_Type_ID# = 1
	or #val(qCheckBudgetDollarForProgram.Budget_Balance_After_Approval)# >= 0
	or Profiles_Settings.Approve_Pgm_Beyond_Budget = 1)
	</cfif>
	ORDER BY Profiles_Desc, User_Full_Name

</cfquery>

<cfif form.saveProfiles eq 1>

	<cfset qSaveProgramRetQuery = ApprovalManager.saveProgramApprovalByProfile(form.programID, form.templateID, form.User_ID) />

	<cfset qGetThisProgramData = ApprovalManager.getProgramInfo(form.programID) />

	<cfset fromUserEmail = userManager.getUserEmail(request.AccessStructure.User_ID) />
	<cfset fromUserName = userManager.getUserName(request.AccessStructure.User_ID) />

	<cfloop query="qSaveProgramRetQuery">

		<!--- prevent problem in including this template more than once --->
		<cfif not (isDefined("EmailSubject") and isCustomFunction(EmailSubject))>
			<cfinclude template="/Common_Files/Programs/emailsubject.cfm"/>
		</cfif>

		<CF_EMAILWRAPPER
			TO 			=	"#User_Email#"
			FROM		=	"#fromUserEmail#"
			subject		=	"#EmailSubject(	qGetThisProgramData.Contract_Number
												,qGetThisProgramData.Contract_Title
												,'is in need of approval')#"
			TYPE		=	"html"
			messagetype	=	"1"
			generatedby	=	"2"
			appArea		=	"1"
			>
				<TABLE>
					<TR>
						<TD VALIGN="top">
							<cfoutput>
							Program [#qGetThisProgramData.Contract_Number#] "#qGetThisProgramData.Contract_Title#" is in need of approval.<br>
							Requested Approval by: #fromUserName#<br>
							Requested Approval on: #DateFormat(now(), "mm/dd/yyyy")#
							</cfoutput>
						</TD>
					</TR>
				</TABLE>

		</CF_EMAILWRAPPER>

		<cfset useLakebaseForQFlagAsSent = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_approval_by_profile")>
		<cfif useLakebaseForQFlagAsSent>
			<cftry>
				<cfset application.oLakebase.updateRows("program_approval_by_profile",
					{ "program_approval_by_profile_id" = "eq.#qSaveProgramRetQuery.Program_Approval_By_Profile_ID#" },
					{ "email_sent" = 1 }
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForQFlagAsSent = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForQFlagAsSent>
		<cfquery name="qFlagAsSent" datasource="#application.datasource#">
			UPDATE	Program_Approval_By_Profile
			SET		Email_Sent = 1
			WHERE	Program_Approval_By_Profile_ID = '#qSaveProgramRetQuery.Program_Approval_By_Profile_ID#'
		</cfquery>
		</cfif>

		<cfquery name="qSetRFAEmailBit" datasource="#application.datasource#">
			UPDATE	Contract_Main_Aux_Data
			SET 	RFA_Email_Sent = 1
			WHERE 	Contract_Main_ID = <cfqueryparam value="#form.programID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

	</cfloop>

	<script>
		window.opener.location.reload();
		window.close();
	</script>
</cfif>

<cfoutput>
<form action="manual_approval_selection_popup.cfm" METHOD="post" NAME="selectProfiles">

<CAPTION align="left">
	<B>
		<FONT COLOR="Navy">Select users to approve:</FONT>
	</B>
	<HR COLOR="Navy">
</CAPTION>

<table>
	<tr>
		<td>
			<CF_button
				button_name		=	"save"
				button_caption	=	"save"
				button_action	=	"submitForm()"
				button_type		=	"javascript_link"
				button_width	=	"150"
				button_color	=	"Navy"
				button_tip		=	"continue with the application"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
		</td>
		<td align="right" valign="top">
			<CF_smallLink
				title = "close window"
				url = "JavaScript:window.close();"
				parameters = ""
			>
		</td>
	</tr>
</table>

<table class="datagrid" id="datagrid">
	<thead>
	<tr>
		<th>
			<INPUT TYPE="checkbox" NAME="allbox" ONCLICK="javaScript: check_all(this);">
		</th>
		<th>
			<b>Name</b>
		</th>
		<th>
			<b>Profile</b>
		</th>
		<th>
			<b>Position</b>
		</th>
		<cfif displayAuthoritySequence>
		<th>
			<b>Authority Sequence</b>
		</th>
		</cfif>
	</tr>
	</thead>
	<tbody>
		<cfloop QUERY="qGetProfileUsers">
		<tr>
			<td>
				<input name="User_ID" value="#User_ID#" type="checkbox" class="cbox">
			</td>
			<td>
				#User_Full_Name#
			</td>
			<td>
				#Profiles_Desc#
			</TD>
			<td>
				#Position_Label#
			</td>
			<cfif displayAuthoritySequence>
			<td>
				<cfif len(trim(Authority_Sequence_Name))>#trim(Authority_Sequence_Name)#<cfelse>N/A</cfif>
			</td>
			</cfif>
		</tr>
		</cfloop>
	</tbody>
</table>

<table>
	<tr>
		<td>
			<CF_button
				button_name		=	"save"
				button_caption	=	"save"
				button_action	=	"submitForm()"
				button_type		=	"javascript_link"
				button_width	=	"150"
				button_color	=	"Navy"
				button_tip		=	"continue with the application"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
		</td>
		<td align="right" valign="top">
			<CF_smallLink
				title = "close window"
				url = "JavaScript:window.close();"
				parameters = ""
			>
		</td>
	</tr>
</table>

<input name="templateID"	type="hidden"	value="#form.templateID#" />
<input name="programID"		type="hidden"	value="#form.programID#" />
<input name="saveProfiles"	type="hidden"	value="#form.saveProfiles#" />
</form>
</cfoutput>

<cfinclude template="/common_files/jQuery.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables.min.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script>
var grid = $('table#datagrid').dataTable({
     "bAutoWidth": true
    ,"bPaginate": false
    ,"bSortClasses": false
    ,"bScrollCollapse": false
    ,"sDom": 'ti'
	,"sScrollXInner": "100%"    <!--- value should equal to total of all aoColumns --->
    ,"aaSorting": [[ 2, "asc" ]] <!--- sort on group name column --->

  }).fnSetFilteringDelay();

<!--- hovering background color switching --->
$('table#datagrid tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });
</script>
</body>
</html>