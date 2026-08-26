<!---
layered_margin_calculation_mass_approve.cfm
--->
<cfparam name="url.UoT" default="0">
<CF_Cryp type="de" key="#request.key#" string ="#URL.CID#">
<CFSET contract_main_id = cryp.value>

<cfset ProgramMarginLog = CreateObject("component","components.programs.MarginLog") />
<cfset MarginCalculatedDate = Now() />
<cfif Get_Profile_Settings.program_margin_approval_method IS 5>
	<cftry>
		<CFSTOREDPROC PROCEDURE="GET_PROFIT_MARGIN_LAYERED" datasource="#application.datasource#">
			<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_INTEGER" VARIABLE="CA_ID" VALUE="#trim(contract_main_id)#" NULL="No">
		</CFSTOREDPROC>
		<cfcatch>
			<cfset ProgramMarginLog.DeleteMarginLogInfo(trim('#contract_main_id#'))>
			<cfset ProgramMarginLog.DeleteMarginLogStatusInfo(trim('#contract_main_id#'))>
			<cfrethrow />
		</cfcatch>
	</cftry>
	<cfset ProgramMarginLog.UpdateMarginLogStatusInfo(trim(contract_main_id),'2')>

	<cfif ! url.UoT>
		<cfset useLakebaseForGet_Settings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users_settings")>
<cfif useLakebaseForGet_Settings>
	<cftry>
		<cfset Get_Settings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users_settings", {
				"user_id" = "eq.#request.AccessStructure.Company_Main_ID#",
				"select" = "margin_uot_id"
			}), "margin_uot_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Settings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Settings>
<CFQUERY NAME="Get_Settings" datasource="#application.datasource#">
			Select		Margin_UOT_ID
			From		_Users_Settings
			Where		User_ID		=		'#request.AccessStructure.Company_Main_ID#'
		</CFQUERY>
</cfif>
		<cfset url.UoT = Get_Settings.Margin_UOT_ID>
	</cfif>
	<!---Tell layered_approval_include.cfm that we are coming from mass approve. This will bypass the cf_loader function which can't handle the buffer size when mass approving. --->
	<cfset massApprove = 1 />
    <cfif application.util.query.get_Setting("margin_display_style") is "custom_h">
        <cfinclude template="layered_approval_include_hm.cfm">
    <cfelse>
        <cfinclude template="layered_approval_include.cfm">
    </cfif>

<cfelse>
	<!--- TODO: STANDARD, DO NOTHING, SHOW MESSAGE TO USER --->
</cfif>



