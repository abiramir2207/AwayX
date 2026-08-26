<!---
       Name:          upload_history_data.cfm
       Copyright:     Copyright (c) 2019 Blacksmith Applications, Inc.
       Created Date:  15-Nov-2019
       Created By:    Anand Rao
       Label:		  
       Description:   Getting the Data for the Upload History page
--->


<cfsetting showDebugOutput="no">
<cfsilent>

<cfset uploadUtility = CreateObject("component","components.Billback.BillbackUploadUtility") />

<cfif NOT isDefined("form.UploadMonthYear")>
<cfset FORM.UploadMonthYear = now() />
</cfif>
<cfset qUploadHistoryData = uploadUtility.getHistoricUploadLogData(datepart("m",form.UploadMonthYear),datepart("yyyy",form.UploadMonthYear),FORM, DeserializeJSON(form.searchFilters),form.startRow,form.endRow,form.sortColumn,form.sortOrder) />

 
<cfinclude template="../upload_history_columns.cfm">
</cfsilent>
<cfoutput>#application.util.query.toDtJSON(qUploadHistoryData, arrayToList( uploadHistory_columns_arr ))#</cfoutput>