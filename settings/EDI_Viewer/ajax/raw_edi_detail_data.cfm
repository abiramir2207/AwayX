<cfsetting showDebugOutput="no">
<cfsilent>
<cfset BBUploadManager  = CreateObject("component","mvc.Models.Billback.BillbackUploadManager") />
<cfset qRawEDIDetailData = BBUploadManager.getRawEDIDetailDataQuery(form.UploadID,form.BBUploadIIIPHID,DeserializeJSON(form.filterModel),form.startRow,form.endRow,form.sortColumn,form.sortOrder)>
<cfinclude template="../edi_viewer_columns.cfm">
</cfsilent>
<cfoutput>#application.util.query.toDtJSON(qRawEDIDetailData, arrayToList( edi_details_columns_arr ))#</cfoutput>