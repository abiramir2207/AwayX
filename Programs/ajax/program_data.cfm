<cfsetting showDebugOutput="no">
<cfsilent>
<cfset ObjPgManager  = CreateObject("component","mvc.Models.Program.ProgramManager") />
<cfset qGetProgramsData = ObjPgManager.getProgramsData()>
<cfinclude template="../program_columns.cfm">
</cfsilent>
<cfoutput>#application.util.query.toDtJSON(qGetProgramsData, arrayToList( program_columns_arr ))#</cfoutput>