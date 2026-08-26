<!---
  * ==================================================================================================== 
  *    @File: Developer/ajax/excel_info.cfm
  *  @Author: Chris Nguyen
  *    @Date: 2019-04-24 10:38:43
  * 
  * @Remarks: Display information in an Excel file
  *  
  * ==================================================================================================== 
--->
<cfsetting showDebugOutput="no">
<cfsetting enableCFoutputOnly="yes">
<cffile action="upload" destination="#expandPath('/common_documents/data_files/uploaded/')#" nameconflict="overwrite" result="upload"/>
<cfset theFile = "#(upload.serverDirectory & '\' & upload.serverFileName & '.' & upload.serverFileExt)#">
<cfoutput>#serializeJSON({STATUS=200, MESSAGE="#inspect(theFile)#"})#</cfoutput>
<cfreturn>


<cffunction name="inspect">
    <cfargument name="expand_path_file" required="true">

    <cfsavecontent variable="local.result">
        <cfset local.errors = []>
        <cftry>
            <cfif !FileExists(arguments.expand_path_file)>
                <cfset arrayAppend(local.errors, "Sorry, for some unknown reasons we could not locate the file.")>
            <cfelseif !IsSpreadsheetFile(arguments.expand_path_file)>
                <cfset arrayAppend(local.errors, "Sorry, the file is not a spreadsheet.")>
            <cfelse>
                <cfspreadsheet action="read" src="#arguments.expand_path_file#" name="local.excelInfo">
                <cfdump var="#local.excelInfo.summaryInfo#" label="Excel Summary Information">

                <h2>Total number of sheets is <cfoutput>#local.excelInfo.summaryInfo.sheets#</cfoutput></h2>
                <br>
                <cfloop from="1" to="#local.excelInfo.summaryInfo.sheets#" index="counter">
                    <cfspreadsheet action="read" src="#theFile#" query="excelSheet" sheet="#counter#" columnnames="A,B,C,D,E,F,G,H,I,K,L,M,N,O,P,Q,R,S,T,V,X,Y,Z">  

                    <h2><cfoutput>###counter#. The sheet name is '#listGetAt(local.excelInfo.SummaryInfo.SheetNames, counter)#'</cfoutput></h2>

                    <cfif excelSheet.recordCount>
                        <cfdump var="#excelSheet#">
                    <cfelse>
                        <p>This sheet is empty.</p>
                    </cfif>
                </cfloop>    
            </cfif>

            <cfcatch type="any">
                <cfset arrayAppend(local.errors, "Sorry, for some unknown reasons we could not read the file.")>
            </cfcatch>
        </cftry>

        <cfif arrayLen(local.errors)>
            <p class="error"><cfoutput>The Excel input file is [#arguments.expand_path_file#].<br><br>#arrayToList(local.errors, "<br>")#</cfoutput></p>
        </cfif>        
    </cfsavecontent>

    <cfreturn ( application.util.string.compress(local.result) )>
</cffunction>

