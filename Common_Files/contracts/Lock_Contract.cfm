<cfparam name="url.CID" default="">
<cfparam name="url.ModifyDeletedPrograms" default="0">
<!---TSF: Label 9673 - Fixed check for URL.CID--->
<CFIF not len(trim(URL.CID)) AND isdefined("FORM.CID")>
	<CFSET URL.CID = FORM.CID>
</CFIF>

<cfif URL.CID NEQ "" and URL.CID NEQ 0>
	<CF_Cryp type="de" key="#request.key#" string="#URL.CID#">
	<CFSET CTLKR_Contract_Main_ID = cryp.value>

	<CFQUERY NAME="CSLGetContractInfo" datasource="#application.datasource#">
		SELECT Contract_Main.ProgramType_ID,
			   Contract_Main.Contract_Number,
			   Contract_Main.Contract_Status_type_Idx
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
				"programcontrol_panel_options_id" = "eq.#CSLGetContractInfo.ProgramType_ID#",
				"select" = "date_exclusions_on,market_price"
			}), "date_exclusions_on,market_price"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetSettings>
<cfquery name="GetSettings" datasource="#application.datasource#">
		SELECT Date_Exclusions_ON, Market_Price
		  FROM Program_Control_Panel_Options
		 WHERE ProgramControl_Panel_Options_ID = '#CSLGetContractInfo.ProgramType_ID#'
	</cfquery>
</cfif>

	<cfset variables.contract_number = ''>
	<!--- If the Program has Date Exclusions turned on --->
	<cfif GetSettings.Date_Exclusions_ON EQ 1>
		<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />

		<!--- Get the Parent contract Information --->
		<cfset getParentContractInfo = GenProgramManager.ParentProgramInfo(CTLKR_Contract_Main_ID)>

		<!--- If the current Contract (Contract being worked on) is the Parent contract, Append the Parent Program ID to the Child Program ID's
			Here 0 (Zero) in the function means that it does not have any parent contracts --->
		<cfif getParentContractInfo.RecordCount eq 0>
			<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(CTLKR_Contract_Main_ID,0)>
		<cfelse>
			<!--- If the current Contract(Contract being worked on) is the child contract, Append the Parent Program ID to the Child Program ID's
			Here 1 (one) in the function means that it has a parent contract --->
			<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(getParentContractInfo.Contract_Main_ID,1)>
		</cfif>

		<cfset variables.contract_number = (getDateExclusionprogramIDs.RecordCount gt 0 ? CSLGetContractInfo.Contract_Number : '')>
	</cfif>

	<!--- If it is a Date Exclusion Program, UnLock all the programs (Parent and Child), else just that particular contract --->
	<!--- trap any deadlock errors --->
	<cftry>
		<cfstoredproc procedure="USP_Contract_Lock_Unlock" datasource="#application.datasource#">
			<cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@User_ID" value="#request.AccessStructure.user_id#">
			<cfprocparam type="In" cfsqltype="cf_sql_bit"     dbVarName="@Unlock"  value="1">
			<cfprocparam type="In" cfsqltype="cf_sql_bit"     dbVarName="@Lock"    value="1">
			<cfprocparam type="In" cfsqltype="cf_sql_integer" dbVarName="@Lock_Program_ID"       value="#CTLKR_Contract_Main_ID#">
			<cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@Lock_Program_Number"   value="#variables.contract_number#">
			<cfprocparam type="In" cfsqltype="cf_sql_integer" dbVarName="@Unlock_Program_ID"     value="0">
			<cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@Unlock_Program_Number" value="">
			<cfprocparam type="In" cfsqltype="cf_sql_bit"     dbVarName="@ModifyDeletedPrograms"    value="#url.ModifyDeletedPrograms#">
		</cfstoredproc>
		<!--- ingore any deadlock error --->
		<cfcatch type="any">
		</cfcatch>
	</cftry>

	<!--- read the latest program status --->
	<cfquery name="variables.program" datasource="#application.datasource#">
		SELECT Contract_Is_Locked
		       ,Contract_Locked_By_User_ID
		  FROM Contract_Main
		 WHERE Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#CTLKR_Contract_Main_ID#">
	</cfquery>

	<!--- turn edit mode on when program has been locked by current logged in user --->
	<cfset this.editMode = ( variables.program.Contract_Locked_By_User_ID eq request.AccessStructure.User_ID ? 1 : 0 )/>

	<!---MARKET PRICE UPDATE market_price--->
	<cfscript>
		//if MP, And it is editable, And it is not approved, make sure the Market Price Rates are up to date
		if(GetSettings.Market_Price && this.editMode EQ 1 && CSLGetContractInfo.Contract_Status_type_Idx LT 3){
			objMarketPriceManager	= CreateObject("component","mvc.Models.Template.MarketPriceManager");
			objMarketPriceManager.MarketPriceUpdateProcess(CTLKR_Contract_Main_ID);
		}
	</cfscript>

	<cflocation url="/common_files/contracts/Contract_Edit_Menu.cfm?CID=#URL.CID#&editMode=#this.editMode#" addtoken="no">
</cfif>
