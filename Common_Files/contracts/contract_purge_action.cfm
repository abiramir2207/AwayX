<cf_cryp type="de" string ="#FORM.Program_ID#" key="#request.key#">

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfif appsettings.getsend_to_sap()>
  <cfset useLakebaseForupdatecontractmain = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForupdatecontractmain>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_main",
			{
				"contract_main_id" = "eq.#cryp.value#",
				"deleted" = "eq.0"
			},
			{
				"sent_to_external_client" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdatecontractmain = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdatecontractmain>
<CFQUERY NAME="updatecontractmain" datasource="#application.datasource#">
		update contract_main
		set Sent_To_External_Client = 1
		where contract_main_id = #cryp.value#
		and deleted = 0
	</CFQUERY>
</cfif>
 	 <div align="center"><font size="2" color="red"> SENDING DATA TO SAP, PLEASE CHECK LATER!!!!.</font> </div>

	<cfset PathToExe 	= ExpandPath("\Utils\BSA_HTTP.exe")>
	<cfset outputpath 	= ExpandPath("\Utils\Output\#cryp.value#.html")>
	<cfset InputFile="url=http://#appSettings.getWebserverInternalIPAddress()#/Scheduled/send_cancelled_program_SAP.cfm?program_id=#cryp.value#&user_id=#request.AccessStructure.user_id#&delete=2&SMPROFILE=NO outputpath=#outputpath#">
	<cfexecute
	      name="#PathToExe#"
	      arguments="#InputFile#">
	</cfexecute>

<cfelse>

	<cfset program = CreateObject("component", "components.programs.program") />
	<cfset programsettings =  program.getprogramsettings(cryp.value)>

<cfif programsettings.Date_Exclusions_ON EQ 1>
<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />
<CFSET ContractIDList = GenProgramManager.ChildProgramIDs(cryp.value,0)>
<cfset ChildProgramIDList = ValueList(ContractIDList.Revision_Program_ID)>
<cfif ListLen(ChildProgramIDList) neq 0>
				 <cfloop list="#ChildProgramIDList#" index="ContractID">
					<cfset deleteSuccess = program.deleteProgram(ContractID, request.AccessStructure.User_ID, request.AccessStructure.User_ID) />
				 </cfloop>
</cfif>
</cfif>

	<cfset program.purgeProgram(cryp.value, request.AccessStructure.User_ID) />

</cfif>

<script language="javascript">
if(window.opener){
	<cfif appSettings.getFlexProgramSearch() EQ 2 OR appSettings.getFlexProgramSearch() EQ 3>
	window.opener.location.href='/flex/search/ProgramSearchFx.cfm?Reload=1';
	<cfelseif appSettings.getFlexProgramSearch() EQ 4 OR appSettings.getFlexProgramSearch() EQ 5>
	window.opener.location.href='/programs/program_search.cfm';
	</cfif>
	window.close();
}
else
{
	window.location.href='/scorecard/scorecard1.cfm';
}
</script>
