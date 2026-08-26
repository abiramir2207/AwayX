<cfquery name="qError" datasource="#application.datasource#">
    SELECT *
      FROM Cfml_Error_Log 
     WHERE Cfml_Error_Log_ID = #url.id#
</cfquery>

<cfoutput>#qError.File_Structure#</cfoutput>