<!---
  * ====================================================================================================
  *    @File: \planners\create\planner_send_email.cfm
  *  @Author: Deepa Kunnath
  *    @Date: August 2020
  *
  * @Remarks: Planner Targets Approval
  *
  * ====================================================================================================
--->

<cfif local.emailAction neq "">

	<cfset userManager = createobject("component", "components.user.userManager") />
	<cfset qCurrentUserInfo = userManager.getUser(request.AccessStructure.User_ID) />
	<cfset uName = trim(qCurrentUserInfo.User_Full_Name) />
	<cfset uEmail = trim(qCurrentUserInfo.User_Email) />

	<cfset useLakebaseForqSystemAdmin = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForqSystemAdmin>
	<cftry>
		<cfset qSystemAdmin = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"is_system_administrator" = "eq.1",
				"deleted" = "eq.0",
				"limit" = "1",
				"select" = "user_email"
			}), "user_email"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqSystemAdmin = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqSystemAdmin>
<cfquery name="qSystemAdmin" datasource="#application.datasource#">
		SELECT	TOP 1 User_Email
		FROM  	_Users
		WHERE 	Is_System_Administrator = 1
		AND		Deleted = 0
	</cfquery>
</cfif>

	<cfset fromEmailAddress = trim(qSystemAdmin.User_Email) />

	<cfif len(fromEmailAddress) and len(uName)>

		<!--- prevent problem in including this template more than once --->
		<cfif not (isDefined("EmailSubject") and isCustomFunction(EmailSubject))>
			<cfinclude template="/Common_Files/Programs/emailsubject.cfm"/>   <!--- 30738 --->
		</cfif>

		<cfif local.emailAction eq "Agree">

			<!---- send email to CRA --->

			<cfset qCRA = plannerManager.getApprovableUsers(form.id) />
			<cfset AlreadySentTo = "">

			<cfloop query="qCRA">
				<cfif User_Email IS NOT uEmail AND ListContains(AlreadySentTo, User_Email) IS False>
					<cfset AlreadySentTo = listappend(AlreadySentTo,User_Email)>

					<CF_EMAILWRAPPER
						TO			= "#User_Email#"
						FROM		= "#fromEmailAddress#"
						subject		= "#EmailSubject(qPlanner.Planner_Number, qPlanner.Planner_Title, 'is in need of approval')#"
						TYPE		= "html"
						messagetype	= "1"
						generatedby	= "2"
						appArea		= "1"
					>
						<TABLE>
						<TR>
						<TD VALIGN="top">
						<cfoutput>
						Programs in #Application.PlannerLabel# [#qPlanner.Planner_Number#] "#qPlanner.Planner_Title#" is in need of approval.<br>
						Agreed by: #uName#<br>
						Agreed on: #DateFormat(Now(), "mm/dd/yyyy")#
						</cfoutput>
						</TD>
						</TR>
						</TABLE>
					</CF_EMAILWRAPPER>

				</cfif>
			</cfloop>

		<cfelseif local.emailAction eq "Approve">

			<!---- send email to RSP --->
			<cfif qPlanner.RSP_User_Email IS NOT uEmail>

				<CF_EMAILWRAPPER
					TO			= "#qPlanner.RSP_User_Email#"
					FROM		= "#fromEmailAddress#"
					SUBJECT 	= "#EmailSubject(qPlanner.Planner_Number, qPlanner.Planner_Title, 'has been approved')#"
					TYPE		= "html"
					messagetype	= "1"
					generatedby	= "2"
					appArea		= "1"
				>
						<TABLE>
						<TR>
						<TD VALIGN="top">
						<cfoutput>
						Programs in #Application.PlannerLabel# [#qPlanner.Planner_Number#] "#qPlanner.Planner_Title#" has been approved.<br>
						Approved by: #uName#<br>
						Approved on: #DateFormat(Now(), "mm/dd/yyyy")#
						</cfoutput>
						</TD>
						</TR>
						</TABLE>
				</CF_EMAILWRAPPER>

			</cfif>

		<cfelseif local.emailAction eq "disagree">

			<!---- send email to RSP --->
			<cfif qPlanner.RSP_User_Email IS NOT uEmail>

				<CF_EMAILWRAPPER
					TO			= "#qPlanner.RSP_User_Email#"
					FROM		= "#fromEmailAddress#"
					SUBJECT 	= "#EmailSubject(qPlanner.Planner_Number, qPlanner.Planner_Title, 'has been disagreed to')#"
					TYPE		= "html"
					messagetype	= "1"
					generatedby	= "2"
					appArea		= "1"
				>
						<TABLE>
						<TR>
						<TD VALIGN="top">
						<cfoutput>
						Programs in #Application.PlannerLabel# [#qPlanner.Planner_Number#] "#qPlanner.Planner_Title#" has been disagreed to.<br>
						Disagreed by: #uName#<br>
						Disagreed on: #DateFormat(Now(), "mm/dd/yyyy")#
						</cfoutput>
						</TD>
						</TR>
						</TABLE>
				</CF_EMAILWRAPPER>


			</cfif>
		<cfelseif local.emailAction eq "Reset">

			<!---- send email to RSP --->
			<cfif qPlanner.RSP_User_Email IS NOT uEmail>

				<CF_EMAILWRAPPER
					TO			= "#qPlanner.RSP_User_Email#"
					FROM		= "#fromEmailAddress#"
					SUBJECT 	= "#EmailSubject(qProgramInfo.Contract_Number, qProgramInfo.Contract_Title, 'has been reset')#"
					TYPE		= "html"
					messagetype	= "1"
					generatedby	= "2"
					appArea		= "1"
				>
						<TABLE>
						<TR>
						<TD VALIGN="top">
						<cfoutput>
						Below #Application.PlannerPrgLabel# in #Application.PlannerLabel# [#qPlanner.Planner_Number#] "#qPlanner.Planner_Title#" has been reset.<br>
						#Application.PlannerPrgLabel# Number : #qProgramInfo.Contract_Number# <br>
						#Application.PlannerPrgLabel# Title : #qProgramInfo.Contract_Title#<br>
						Reset by: #uName#<br>
						Reset on: #DateFormat(Now(), "mm/dd/yyyy")#
						</cfoutput>
						</TD>
						</TR>
						</TABLE>
				</CF_EMAILWRAPPER>

			</cfif>
		</cfif>

	</cfif>

</cfif>