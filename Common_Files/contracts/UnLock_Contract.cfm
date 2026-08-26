<!--- Dev Note: drachala; D28431: Close on RFA and unlock  START
Added/Changed: Added this variable--->
<cfparam name="close_window" default="0">
<!--- End Dev Note: drachala; D28431: Close on RFA and unlock  --->
<cfparam name="url.close" default="0" >

<CF_Cryp type="de" key="#request.key#" string="#URL.CID#">
<CFSET CTLKR_Contract_Main_ID = cryp.value>

<CFQUERY NAME="CSLGetContractInfo" datasource="#application.datasource#">
	SELECT Program_Control_Panel_Options.Created_Type, Contract_Main.*, dbo.Program_Control_Panel_Options.Generic_Type,Program_Control_Panel_Options.revision_not_allowed
	FROM Contract_Main
		INNER JOIN	Program_Control_Panel_Options
		ON (Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID)
	WHERE Contract_Main_ID = '#CTLKR_Contract_Main_ID#'
</CFQUERY>

<cfset useLakebaseForGetSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForGetSettings>
	<cftry>
		<cfset GetSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#CSLGetContractInfo.ProgramType_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetSettings>
<cfquery name="GetSettings" datasource="#application.datasource#">
	SELECT *
	FROM 
		Program_Control_Panel_Options
	WHERE 
		ProgramControl_Panel_Options_ID = '#CSLGetContractInfo.ProgramType_ID#'
</cfquery>
</cfif>

<cfset useLakebaseForisContractCurrentlyLocked = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForisContractCurrentlyLocked>
	<cftry>
		<cfset isContractCurrentlyLocked = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#CTLKR_Contract_Main_ID#",
				"select" = "contract_is_locked,contract_locked_by_user_id"
			}), "contract_is_locked,contract_locked_by_user_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForisContractCurrentlyLocked = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForisContractCurrentlyLocked>
<cfquery name="isContractCurrentlyLocked" datasource="#application.datasource#">
	SELECT Contract_Is_Locked, Contract_Locked_By_User_ID
	FROM Contract_Main
	WHERE Contract_Main_ID ='#CTLKR_Contract_Main_ID#'
</cfquery>
</cfif>


<!--- If the Program has Date Exclusions turned on --->
<cfif GetSettings.Date_Exclusions_ON EQ 1>

	<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />
	
<!--- Get the Parent contract Information --->			
	<cfset getParentContractInfo = GenProgramManager.ParentProgramInfo(CTLKR_Contract_Main_ID)>
	
<!--- If the current Contract (Contract being worked on) is the Parent contract, Append the Parent Program ID to the Child Program ID's 
		Here 0 (Zero) in the function means that it does not have any parent contracts --->
		<cfif getParentContractInfo.RecordCount eq 0>
		<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(CTLKR_Contract_Main_ID,0)>
			<cfset List_Of_Contract_Main_IDs = QuotedvalueList(getDateExclusionprogramIDs.Revision_Program_ID) & ',''' & CTLKR_Contract_Main_ID & ''''>
		<cfelse>
		
<!--- If the current Contract(Contract being worked on) is the child contract, Append the Parent Program ID to the Child Program ID's
	Here 1 (one) in the function means that it has a parent contract --->
		<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(getParentContractInfo.Contract_Main_ID,1)>
			<cfset List_Of_Contract_Main_IDs = QuotedvalueList(getDateExclusionprogramIDs.Revision_Program_ID) & ',' & QuotedvalueList(getParentContractInfo.Contract_Main_ID)>
		</cfif>
		
<!--- If there are no Date Exclusion Contracts(as yet), even though it is has Date Exclusion Enabled --->
	<cfif getDateExclusionprogramIDs.RecordCount eq 0>	
		<cfset List_Of_Contract_Main_IDs ="'"&CTLKR_Contract_Main_ID&"'">
	</cfif>
</cfif>

<!--- If it is a Date Exclusion Program, UnLock all the programs (Parent and Child), else just that particular contract --->		
<CFIF isContractCurrentlyLocked.Contract_Is_Locked EQ 1>
	<CFQUERY NAME="unlockContractFromOtherUsers" datasource="#application.datasource#">
		UPDATE Contract_Main
		Set Contract_Is_Locked = 0, Contract_Locked_By_User_ID = '#request.AccessStructure.User_ID#'
		<cfif GetSettings.Date_Exclusions_ON EQ 1>
		WHERE Contract_Main_ID IN(#PreserveSingleQuotes(List_Of_Contract_Main_IDs)#)
		<cfelse>
		WHERE Contract_Main_ID = '#CTLKR_Contract_Main_ID#'
		</cfif>
	</CFQUERY>
</CFIF>

<!--- Dev Note: drachala; D28431: Close on RFA and unlock  START
Added/Changed: IF Condition to Check if we should close window based on access rights or redirect to main page--->
<cfif close_window OR url.close>
	<script>
		window.close();
	</script>
<cfelse>
<CFLOCATION url="/common_files/contracts/Contract_Edit_Menu.cfm?CID=#URL.CID#" ADDTOKEN="No">
</cfif>
<!--- End Dev Note: drachala; D28431: Close on RFA and unlock  --->
