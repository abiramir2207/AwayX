<cfsetting showDebugOutput="no">
<cfsetting enablecfoutputonly="true">
<!---
  * ==================================================================================================== 
  *    @File: 
  *  @Author: Chris Nguyen
  *    @Date: 
  * 
  * @Remarks: 
  *  
  * ==================================================================================================== 
--->
<cfparam name="form.sql"   default="">

<cfset max_rows = val(application.util.query.get_setting("queryDatabase_maxrows", 0))>
<cfset max_rows = max_rows eq 0 ? 5000 : max_rows>

<cfquery name="qData" datasource="#application.datasource#" maxrows="#max_rows#">
    <cfoutput>#PreserveSingleQuotes(FORM.sql)#</cfoutput>
</cfquery>

<cfif qData.recordCount eq 0>
    <cfoutput>{"ROWS":[]}</cfoutput>
<cfelse>
    <cfoutput>{"ROWS":#application.util.query.toDtJSON(qData, arrayToList(qData.getColumnList()))#}</cfoutput>
</cfif>
