<cfsetting showDebugOutput="no">
<cfsilent>
<cfset ObjDeviationManager  = CreateObject("component","mvc.models.Billback.BillbackDevAppManager") />
<cfset qGetDeviationData = ObjDeviationManager.getBillbackData(BBID = form.BBID)>
<cfinclude template="../deviation_columns.cfm">
</cfsilent>
<cfoutput>#application.util.query.toDtJSON(qGetDeviationData, arrayToList( deviation_columns_arr ))#</cfoutput>