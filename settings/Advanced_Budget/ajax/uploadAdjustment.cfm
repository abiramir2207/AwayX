<!---------------------------------------------------------------------------------------------------------------------
      Template: 
      Date:     Aug 22, 2012
      Author:   Chris Nguyen
      Purpose:  
      
      Notes:  This template returns a JSON structure with 2 elements:
                - STATUS:  200 (success)  
                           500 (failure)
                - MESSAGE:  Name of uploaded file when upload was a success 
                            or error message when failure occurs
----------------------------------------------------------------------------------------------------------------------->
<cfsetting showDebugOutput="No">
<cftry>
  <cffile action="upload" destination="#budgetFolder()#" nameconflict="MakeUnique" result="main.upload"/>

	<!---<cfmail to="cnguyen@bigredflame.com" from="cnguyen@bigredflame.com" subject="cfdump from #cgi.server_name#" type="html"> 
	  <cfdump var="#main#" label="main" format="html" showudfs="false" metainfo="true" > 
	</cfmail>--->
  
  <!---send success status back--->
  <cfoutput>#serializeJSON( {STATUS=200, MESSAGE=main.upload.serverFile} )#</cfoutput>
  
	<cfcatch type="any">
	  <cfoutput>#serializeJSON( {STATUS=500, MESSAGE=JSStringFormat(cfcatch.detail) })#</cfoutput>
	</cfcatch>
</cftry>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="budgetFolder" output="false" hint="Creates/returns Excel statement upload folder.">
  <cfset var xlsFolder = ExpandPath('/common_documents/data_files/uploaded/budgets')>

  <!---create new folder to upload Excel budgets--->
  <cfif not DirectoryExists(xlsFolder)>
    <cfdirectory directory = "#xlsFolder#" action = "create">
  </cfif>

  <cfreturn xlsFolder>
</cffunction>

