<!---
Set_Document_Path_UNC.cfm
--->

<cfset sWebServerName = application.WebServerName />
<cfset sRelativePath =  Replace(Application.Doc_Path, ":", "$") />
<cfset sUNCPath = "\\" & sWebServerName & "\" & sRelativePath />


<CFQUERY NAME="setUNCPath" DATASOURCE="#Application.Datasource#">
	UPDATE 	_Application_Settings 
	SET 	Document_Path_UNC = '#sUNCPath#'
</CFQUERY>

