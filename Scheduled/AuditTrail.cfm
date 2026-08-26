<!--- CREATE THE AUDIT TRAIL COMPONENT AS AN OBJECT TO CALL METHODS BELOW ON THIS PAGE --->
<cfset logObj = createObject("component", "components.settings.AuditTrail.AuditTrail").init()>

<!--- GET AN OUTPUT OF THE XML LOG DIRECTORY --->
<cfdirectory action="list" name="xmlFileList" directory="#expandPath('/logs/xml')#">
<!--- CREATE LIST OF FILE NAMES --->
<cfset nameList = valueList(xmlFileList.name)>

<!--- CREATE DATE FOR YESTERDAY TO PROCESS ALL CHANGES THAT HAPPENED YESTERDAY --->
<cfset dateNow = dateformat(Now()-1,"MM/DD/YYYY")>

<!--- LOOP OVER FILENAME LIST TO CREATE DB DATA --->
<cfloop list="#nameList#" index="fileName">
	
	<!--- REMOVE FILE EXTENSION --->
	<cfset logFileName = removechars(fileName,len(fileName)-3,4)>
	
	<!--- REMOVE 'AuditTrail_' FROM BEGINNING OF FILENAME STRING --->
	<cfset logFileName = removechars(logFileName,1,11)>
	
	<!--- PROCESS THE LOG AND ENTER DATA INTO THE DATABASE --->
	<cfset XMLLog = logObj.createXMLLogDBTables(logFileName,dateNow)>
	<cfoutput>#XMLLog#<br></cfoutput>
</cfloop>