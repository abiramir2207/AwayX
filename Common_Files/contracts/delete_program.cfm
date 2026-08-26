<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<cf_cryp type="de" key="#request.key#" string = "#FORM.Program_ID#">

<cfset deleteProgramId = cryp.value>
<cfinclude template="/scorecard/delete_program_common.cfm">

<cfset program = CreateObject("component", "components.programs.program") />
<!------ unlock program ----->	
<cfset program.setLockStatus(deleteProgramId, 0)>

<script language="javascript">
<cfif appSettings.getFlexProgramSearch() EQ 1>
		window.location.href='/scorecard/scorecard1.cfm';
<cfelseif appSettings.getFlexProgramSearch() EQ 2 OR appSettings.getFlexProgramSearch() EQ 3>
	if(window.opener){
		window.opener.location.href='/flex/search/ProgramSearchFx.cfm?Reload=1';
		}
	else{
		window.location.href='/flex/search/ProgramSearchFx.cfm?Reload=1';
	}
<cfelseif appSettings.getFlexProgramSearch() EQ 4 OR appSettings.getFlexProgramSearch() EQ 5>
	if(window.opener){
		window.opener.location.href='/programs/program_search.cfm';
		}
	else{
		window.location.href='/programs/program_search.cfm';
	}	
<cfelse>
	window.location.href='/scorecard/scorecard1.cfm';
</cfif>

if(window.opener){
	window.close();
}
</script>