
<cfparam name="Disagreed" default="0">
<cfoutput>
<cfparam name="Form.Disagreed" default= #Disagreed#>
</cfoutput>

<CFIF Form.Disagreed eq 1>
	<cf_cryp type="de" key="#request.key#" string="#URL.CID#">
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>

	<cfset CreateObject("component", "components.programs.Program").resetProgram(programID = #cryp.value#,userId = request.AccessStructure.User_ID,Mode=9)/>

	<cfif appSettings.getFlexProgramSearch()>
		<cfset targetpage = "winSummary_" & #cryp.value#>
	<cfelse>
		<cfset targetpage = "mywindowname">
	</cfif>

	<cfinclude template="send_email_to_creator.cfm">
		<cfoutput><form name="FrmApproveAction" target="#targetpage#" action="contract_edit_menu.cfm?CID=#FORM.programid#&emailFax=1" method="post"></form></cfoutput>
	<script>
		FrmApproveAction.submit();
		window.close();
	</script>
<CFELSE>

<Cf_cryp type="de" key="#request.key#" string="#form.Program_ID#">
<cfparam name="Form.LSAutoPay" default="0">
<cfquery name="deleteagreedtypecodes" datasource="#application.datasource#">
	DELETE from Program_Type_Code_Approval_Info
	where program_id = <cfqueryparam value="#cryp.value#" cfsqltype="CF_SQL_INTEGER">
</CFQUERY>


<CFQUERY NAME="resetprogramagreements" datasource="#application.datasource#">
	DELETE from Program_agree
	where 	programid = <cfqueryparam value="#cryp.value#" cfsqltype="CF_SQL_INTEGER">
	delete from Program_agree_All_Group
	where 	programid = <cfqueryparam value="#cryp.value#" cfsqltype="CF_SQL_INTEGER">
</CFQUERY>

<CFQUERY NAME="resetprogramagreements" datasource="#application.datasource#">
	update 	Contract_Main_Aux_Data
	set 	program_revisiontype_executed = 0
	<!---Milan (19850) Missing freight start date and end date on Reset which causes the following issue -
	when the contract dates change on revision, we do not get this message on the freight page -
	"BELOW FREIGHT WAS CALCULATED USING DATE SPAN...... as the freight dates dont get repopulated
	again. Resetting these dates is not a requirement for freight and so I have commented it.
	--->
	<!---,
		Freight_Contract_Start_Date = NULL,
		Freight_Contract_End_Date = NULL
	--->
	where 	Contract_Main_ID = <cfqueryparam value="#cryp.value#" cfsqltype="CF_SQL_INTEGER">
</CFQUERY>

<cfset objProgramFreight = CreateObject("component", "components.freight.ProgramFreight").init() />

<!--- Reset Freight --->
<!--- Dev Note: KAL; 11/9/2010; D25227: Freight Adjustment; Dont reset Freight info on reset to WIP --->
<!--- <cfset objProgramFreight.ResetFreightInfo(programId = cryp.value) /> --->

<!--- Reset Freight Approval --->
<!--- D28526: do not reset <cfset objProgramFreight.resetFreightApproval(
						programID = cryp.value,
						userId = request.AccessStructure.User _ID,
						comments = 'Reset Program to WIP') />--->

<cfset useLakebaseForDeleteProgramApprovalByProfile = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_approval_by_profile")>
<cfif useLakebaseForDeleteProgramApprovalByProfile>
	<cftry>
		<cfset application.oLakebase.deleteRows("program_approval_by_profile", { "program_id" = "eq.#cryp.value#" })>
		<cfcatch type="any">
			<cfset useLakebaseForDeleteProgramApprovalByProfile = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeleteProgramApprovalByProfile>
	<CFQUERY NAME="deleteProgramApprovalByProfile" datasource="#application.datasource#">
		DELETE 	FROM Program_Approval_By_Profile
		WHERE	Program_ID = <cfqueryparam value="#cryp.value#" cfsqltype="CF_SQL_INTEGER">

	</CFQUERY>
</cfif>

<CFQUERY NAME="kickbackToWIP" datasource="#application.datasource#">
	UPDATE contract_main
	SET
		Broker_Approved 			= 0,
		Broker_Approved_Date 		= NULL,
		Broker_User_ID 				= NULL,
		<cfif Form.LSAutoPay EQ 1> <!--- LS AUTO Pay allows reset until the Program is auto payed --->
			Approved					= 0,
			Approval_Date				= NULL,
			Approved_By_User_ID			= NULL,
		</cfif>
		Contract_Status_Type_IDX 	= 1,
		edit_agreed_program  =  0,
		modifying_program = 0,
		modifying_user_id = NULL,
		Reset_Date = GetDate(),
		Reset_User_ID = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="cf_sql_varchar">
	WHERE Contract_Main_ID = <cfqueryparam value="#cryp.value#" cfsqltype="CF_SQL_INTEGER">
</CFQUERY>

<CFLOCATION URL="contract_Edit_menu.cfm?CID=#form.Program_ID#">

</CFIF>