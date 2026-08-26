 <!----------------------------------------------------------------------------------
Name         :  AwayX/Scheduled/inc_full_Common_Documents_Path.cfm
Copyright    :  (c) 2017 Blacksmith Applications, Inc.
Created Date :  06-Oct-2017
Created By   :  Anand Rao
Description  :  Update the _Application_Settings.full_Common_Documents_Path
---------------------------------------------------------------------------------->

<cfset sWebServerName = application.WebServerName />
<cfset sRelativePath =  Replace(Application.Doc_Path, ":", "$") />
<cfset sUNCPath = "\\" & sWebServerName & "\" & sRelativePath />
 
<CFQUERY NAME="setUNCPath" DATASOURCE="#Application.Datasource#">
	UPDATE 	_Application_Settings 
	SET 	Full_Common_Documents_Path = '#sUNCPath#'
</CFQUERY>

