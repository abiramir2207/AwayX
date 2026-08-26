<!------ /scorecard/delete_program_common.cfm ----->

<cfparam name="plannerProgram" default="0">
<cfset sendDeleteEmail = 0>
<!------ Find out if we need to send mail because this program is getting deleted ----->

<cfset userManager = CreateObject("component", "components.user.UserManager") />
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset businessSegmentsOn = 0 />
<cfif businessSegManager.isEnabled()>
	<cfset businessSegmentsOn = 1 />
</cfif>

<!------ Get application settings ----->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfif appSettings.getDeleteIsCancelAutoRenew() AND appSettings.getCancelProgramEmail()>
	<!------ Find if program was autorenew program ----->
	<cfquery name="qGetProgramInfo" datasource="#application.datasource#">
		SELECT	Is_AutoRenew
		FROM	Contract_Main
		WHERE	Contract_Main_ID = <cfqueryparam value="#deleteProgramId#" cfsqltype="CF_SQL_INTEGER">
				AND NOT EXISTS<!------ and there is no other valid version for it ----->
				(
				SELECT 	CM.Contract_Main_ID
				FROM	Contract_Main CM
				WHERE	CM.Deleted = 0
						AND CM.Force_Expiration_Flag = 0
						AND CM.Contract_Number = Contract_Main.Contract_Number
						AND CM.Contract_Main_ID <> Contract_Main.Contract_Main_ID
				)
	</cfquery>
	<cfif qGetProgramInfo.recordCount>
		<cfif qGetProgramInfo.Is_AutoRenew EQ 1>
			<cfset sendDeleteEmail = 1>
		</cfif>
	</cfif>
</cfif>	

<cfset program = CreateObject("component", "components.programs.program") />		
<cfset programsettings =  program.getprogramsettings(deleteProgramId)>

<cfif programsettings.Date_Exclusions_ON EQ 1>
<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />	
<CFSET ContractIDList = GenProgramManager.ChildProgramIDs(deleteProgramId,0)>
<cfset ChildProgramIDList = ValueList(ContractIDList.Revision_Program_ID)>
<cfif ListLen(ChildProgramIDList) neq 0>
				 <cfloop list="#ChildProgramIDList#" index="ContractID">
					<cfset deleteSuccess = program.deleteProgram(ContractID, request.AccessStructure.User_ID, request.AccessStructure.User_ID) />
				 </cfloop>
</cfif>
</cfif>

<cfset deleteSuccess = program.deleteProgram(deleteProgramId, request.AccessStructure.User_ID, request.AccessStructure.User_ID, plannerProgram) />

<cfif sendDeleteEmail>	
	<cfset send_Cancel_Email_Now = 1>
	<cfset send_Email_Program_ID = deleteProgramId>
	<cfinclude template="\anything_automated\email\cancelled_programs_emailer.cfm">
</cfif>