<cfsetting showDebugOutput="no">
<cfsetting enablecfoutputonly="true">
<!---
  * ==================================================================================================== 
  *    @File: Deployment\Redistribution\ajax\reprocess_corrections.cfm
  *  @Author: Chris Nguyen
  *    @Date: 2019 May - 85971
  * 
  * @Remarks: Reprocess selected corrections and reload 
  *  
  * ==================================================================================================== 
--->
<cfscript>
    objRediDAO     = createObject("component","mvc.Models.Admin.Redi.RediDAO");
    objRediManager = createObject("component","mvc.Models.Admin.Redi.RediManager");
    selected       = createObject("component","mvc.Models.Admin.Redi.vos.RediCorrectionHeader");

    // save selected header ids into a property so it can be used as query parameter
    selected.header_ids_filter = form.ids_list;

    qSelectedData     = objRediDAO.getRediHeaderData( selected );
    header_objects    = objRediManager.getRediCorrectionHeaderObj( qSelectedData );
    reprocess_results = objRediManager.reprocessRediCorrection( header_objects );
    outcome           = { messages:[], columns:[], rows:"" };
</cfscript>

<!--- gather all result messages --->
<cfloop from="1" to="#arrayLen(reprocess_results.arrInvNum)#" index="counter">
    <cfscript>
        correction = reprocess_results.arrInvNum[counter];
        message    = correction.invoiceNumber contains "error" or trim(correction.errorMessage) gt ''
                        ? correction.errorMessage & "."
                        : "invoice " & correction.invoiceNumber & " created.";

        arrayAppend(outcome.messages, reprocess_results.arrId[counter] & " - " & message);
    </cfscript>
</cfloop>

<cfscript>
    qCorrections    = objRediDAO.getRediHeaderData( caller = "redistribution.cfm" );
    outcome.columns = [   "UploadID"                   // 00
                        ,"SourceType"                 // 01
                        ,"SourceTypeDesc"             // 02
                        ,"InvoiceNumber"              // 03
                        ,"InvoiceDate"                // 04
                        ,"OriginalCustomerAliasName"  // 05
                        ,"OriginalCustomerShipto"     // 06
                        ,"FinalCustomeraliasname"     // 07
                        ,"FinalCustomerAliasShipto"   // 08
                        ,"PoNum"                      // 09
                        ,"InvCases"                   // 10
                        ,"InvDollars"                 // 11
                        ,"ErrorMessage"               // 12
                        ,"rediCorrectionHeaderId"     // 13 - hidden
                    ];
</cfscript>

<cfquery dbtype="query" name="qCorrections">
    SELECT * FROM qCorrections WHERE bReprocess = 1
</cfquery>

<cfset outcome.rows = application.util.query.toDtJSON(qCorrections, arrayToList( outcome.columns ))>
<cfif qCorrections.RecordCount>
<cfoutput>{"ROWS":#outcome.rows#, "MESSAGES":"#arrayToList(outcome.messages, '<br>')#"}</cfoutput>
<cfelse>
<cfoutput>{"ROWS":[], "MESSAGES":"#arrayToList(outcome.messages, '<br>')#"}</cfoutput>
</cfif>

