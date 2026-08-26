<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Upgrade Utility</title>
</head>

<body>
<!--- handle ajax request for refreshing the application utility --->
<cfif structKeyExists(url, "resetUtil")>
	<cfabort>
</cfif>
<cfset url_domain = "#application.HTTPVar##CGI.SERVER_NAME#" />

<!------ sometimes the web server does not know about #url_domain# when URL is used, so it is better to include ----->
<!------
<cfhttp url="#url_domain#/settings/customer_settings/Memory_Data/Render_Files.cfm" method="get" resolveurl="no">
 ----->
<cfinclude template="/settings/customer_settings/Memory_Data/Render_Files.cfm" />


<cfinclude template="/Application_AppsettingsMan.cfm">
<br><br>
<center>
<font color="#0000ff" size="+1">
	Application settings Reloaded...
</font>
</center>

<cfset displayClearRebateFilesStatus = 0 />
<cfinclude template="/scheduled/clear_rebate_files.cfm" />

<!--- <cfinclude template="/scheduled/Set_Document_Path_UNC.cfm" /> --->
<cfinclude template="/scheduled/inc_full_Common_Documents_Path.cfm" />

<!--- writes the direcotry watcher config and also creates schdeuled job to monitor the attachments. --->
<cfinclude template="/scheduled/Write_DirWatcher_Config.cfm" />

<!---
<cfhttp url="#url_domain#/scheduled/clear_rebate_files.cfm" method="get" resolveurl="no">
--->

<!---
<cfschedule action = "update"
    task = "Nightly Scheduled Task (#CGI.SERVER_NAME#)"
    operation = "HTTPRequest"
    url = "#url_domain#/scheduled/scheduled_tasks.cfm"
    startDate = "#DateFormat(Now(), "mm/dd/yyyy")#"
    startTime = "03:00 AM"
    interval = "Daily"
    resolveURL = "Yes"
    publish = "Yes"
    file = "scheduled_tasks.log"
    path = "#APPLICATIONPATH#\Scheduled\"
    requestTimeOut = "600">
 --->

<!--- MATCH CENTRAL FILE PURGE/DD, CR, AND BB UNLOCKING/BILLBACK SEARCH OBJECT DELETE --->
<cfset oMatchCentral = createObject("component", "components.Match_Central.MatchCentral") />

	<!--- delete billback search object --->
	<cfset structDelete(application,"oBillbackSearch")>

  <!--- delete letter manager object --->
  <cfset structDelete(application,"oLetterManager")>

	<!--- purge all xml files --->
	<cfset oMatchCentral.xmlFilePurge() />

	<!--- unlock all items that have been locked by match central --->
	<cfset oMatchCentral.unlockMatchCentralLocks() />
<!--- END: MATCH CENTRAL FILE PURGE/DD, CR, AND BB UNLOCKING/BILLBACK SEARCH OBJECT DELETE --->

<!--- CREATE THE Flex gateway used to Push data to flex clients --->
<cfscript>
			variables.objBBUploadMan = CreateObject("component","mvc.Models.Billback.BillbackUploadManager");
			objBBUploadMan.createFlexGateway();
</cfscript>
<br><br>
<center>
<font color="#0000ff" size="+1">
	Customer Settings have been refreshed...
</font>
</center>

<script>
	var request = new XMLHttpRequest();
	request.open('GET', 'upgrade.cfm?resetUtil', true);
	request.send();
</script>
</body>
</html>
