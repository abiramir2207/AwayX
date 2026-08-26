<cfif isdefined("url.programid")>
<cfset form.programid = url.programid>
</cfif>
<cf_cryp type="de" string ="#form.programid#" key="#request.key#">
<cfset program_id = cryp.value>
<cfset FORM.ApproveContract = form.programid>
<cfparam name="FORM.Program_Is_A_Revision" default="0">
	 
	 <cfset LayeredProgramManager = CreateObject("component","components.programs.Approval.layered_program_approval") />
<cfset getThisProgramsStatus = LayeredProgramManager.getThisProgramsStatus(Program_ID)>

<CFQUERY NAME="ApproveContract" datasource="#application.datasource#">
			UPDATE Contract_Main
			Set Approval_Date = getdate(), 
			Approved = 1, 
			Approved_By_User_ID = '#request.AccessStructure.User_ID#'
			<CFIF FORM.Program_Is_A_Revision EQ 1>
			,Contract_Start_Date = '#FORM.start_date#',
			Contract_End_Date= '#FORM.end_date#'
			</CFIF>
			,Is_Manual_Revision = Is_A_Revision
			WHERE Contract_Main_Id = #program_id#
		</CFQUERY>

		<CFIF len(getThisProgramsStatus.Revision_Of_Contract_Main_ID) GT 0>
			<cfset checkParentStats = LayeredProgramManager.checkParentStats(getThisProgramsStatus.Revision_Of_Contract_Main_ID)>
			<CFIF checkParentStats.Contract_Status_Type_IDX EQ getThisProgramsStatus.Contract_Status_Type_IDX>
				<cfset useLakebaseFordeleteParent = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseFordeleteParent>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_main",
			{
				"contract_main_id" = "eq.#checkParentStats.Contract_Main_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseFordeleteParent = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeleteParent>
<CFQUERY NAME="deleteParent" datasource="#application.datasource#">
					UPDATE Contract_main
					SET deleted = 1
					where contract_main_id = '#checkParentStats.Contract_Main_ID#'
				</CFQUERY>
</cfif>
			</CFIF>
		</CFIF>

		
		<CFSET generateReleaseProgramID = form.programid>
		<cfset contract_main_id = program_id>
	
		 <cfinclude template="generate_approve_email.cfm"> 

