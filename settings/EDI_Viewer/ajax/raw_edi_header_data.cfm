<cfsetting showDebugOutput="no">
<cfsilent>
<cfset BBUploadManager  = CreateObject("component","mvc.Models.Billback.BillbackUploadManager") />
<cfset qRawEDIHeaderData = BBUploadManager.getRawEDIHeaderData(DeserializeJSON(form.searchFilters),form.startRow,form.endRow,form.sortColumn,form.sortOrder)>
<cfinclude template="../edi_viewer_columns.cfm">
</cfsilent>
<cfoutput>#application.util.query.toDtJSON(qRawEDIHeaderData, arrayToList( edi_columns_arr ))#</cfoutput>