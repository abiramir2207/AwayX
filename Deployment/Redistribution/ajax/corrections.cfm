<cfsetting showDebugOutput="no">
<cfsetting enablecfoutputonly="true">
<!---
  * ==================================================================================================== 
  *    @File: Deployment\Redistribution\ajax\corrections.cfm
  *  @Author: Chris Nguyen
  *    @Date: 2019 May - 85971
  * 
  * @Remarks: Pull corrections from database and return it in JSON format
  *  
  * ==================================================================================================== 
--->
<cfparam name="form.action"   default="">
<cfparam name="form.ids_list" default="">
<cfparam name="form.only_reprocess" default="0">

<cfif form.action is "delete">
    <cfif listLen(form.ids_list)>
        <cfquery datasource="#application.datasource#">
            <cfloop list="#form.ids_list#" index="local.id">
                DELETE FROM D
                       FROM REDI_EC_Header H INNER JOIN REDI_EC_Detail D ON D.Redi_H_Id = H.Redi_H_Id
                 WHERE REDI_EC_HEADER_ID = <cfqueryparam value="#local.id#">

                DELETE FROM REDI_EC_Header 
                 WHERE REDI_EC_HEADER_ID = <cfqueryparam value="#local.id#">
            </cfloop>
        </cfquery>
    </cfif>
</cfif>

<cfscript>
    objRediDAO     = createObject( "component", "mvc.Models.Admin.Redi.RediDAO" );
    qCorrections   = objRediDAO.getRediHeaderData( caller = "redistribution.cfm" );
    return_columns = [   "UploadID"                   // 00
                        ,"SourceType"                 // 01
                        ,"SourceTypeDesc"             // 02
                        ,"InvoiceNumber"              // 03
                        ,"invoiceDateYYYYMMDD"        // 04
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
    SELECT 
            <cfoutput>#arrayToList(return_columns)#</cfoutput>
      FROM qCorrections 
    <cfif form.only_reprocess eq "1">
        WHERE bReprocess = 1
    </cfif>
</cfquery>

<cfif qCorrections.recordCount eq 0>
    <cfoutput>{"ROWS":[]}</cfoutput>
<cfelse>
    <cfoutput>{"ROWS":#application.util.query.toDtJSON(qCorrections, arrayToList(return_columns))#}</cfoutput>
</cfif>
