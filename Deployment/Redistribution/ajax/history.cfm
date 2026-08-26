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
  *
  * 
  *  
  * ==================================================================================================== 
--->
<cfscript>
    cfc        = createObject("component", "mvc.models.admin.redi.RediDAO");
    qHistories = cfc.getRediHistoryData( caller = "redistribution.cfm" );
</cfscript>

<cfif qHistories.recordCount eq 0>
    <cfoutput>{"ROWS":[]}</cfoutput>
<cfelse>
    <cfset returned_columns = [
                                "uploadId"
                                ,"sourceType"
                                ,"sourceTypeDesc"
                                ,"headerCount"
                                ,"headerFailed"
                                ,"headerLoaded"
                                ,"detailCount"
                                ,"detailFailed"
                                ,"detailLoaded"
                                ,"fileName"
                                ,"runDate"
                            ]>
    <cfoutput>{"ROWS":#application.util.query.toDtJSON(qHistories, arrayToList(returned_columns))#}</cfoutput>
</cfif>
