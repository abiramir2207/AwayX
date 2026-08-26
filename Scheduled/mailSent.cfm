<!---------------------------------------------------------------------------------------------------------------------
      Template: \Scheduled\mailSent.cfm
      Date:     November 2013
      Author:   Chris Nguyen
      Purpose:  Populate MESSAGE_LOG.Sent date based on mailsent.log file and its archived files

      Notes:    Debug can be turned on by URL parameter 'debug'

                Debug log file name = mailSentDebug.log, location = CF logs folder
----------------------------------------------------------------------------------------------------------------------->

<cfoutput>
  <!--- debug can be turned on with url parameter debug --->
  <cfset variables.debug = (structKeyExists(url, "debug") ? 1 : 0)>
  <cfset variables.startTime = now()>

  <cfset writeDebug("starting mailsent scheduled task")>

  <!--- Step 1. archive mailsent.log file --->
  <cfset variable.logfolder = archiveMailSent()>

  <cfsetting requesttimeout=300>         <!--- reserves number of seconds to run this task, if timing out occurs increase this value --->

  <cfset variables.uploadUtility = CreateObject("component","components.billback.billbackuploadutility") />
  <cfset variables.uploadFilePath = variables.uploadUtility.getUploadPath() />

  <!---
  //////////////////////////////////////////////////
  //  if billback upload is not configured bail out
  //////////////////////////////////////////////////
  --->
  <cfif len(trim(variables.uploadFilePath.File_Path)) eq 0>
    <cfabort>
  </cfif>

  <cfif not DirectoryExists(variables.uploadFilePath.File_Path)>
      <cfdirectory directory="#variables.uploadFilePath.File_Path#" action="create">
  </cfif>

  <cfquery name="variables.dbQuery" datasource="#application.datasource#">
      SELECT TOP 1 Table_Catalog db_name
      FROM INFORMATION_SCHEMA.TABLES
  </cfquery>

  <!--- define a unique file name --->
  <cfset variables.bigLogFile = variables.uploadFilePath.File_Path & "\mailSentLog_" & getTickCount() & "_" & lcase(variables.dbQuery.db_name) & ".log"/>
  <!--- delete if big log file exists ( not likely ) --->
  <cfif fileExists( variables.bigLogFile )>
    <cffile action="delete" file="#variables.bigLogFile#">
  </cfif>

  <!--- Step 2. combine all archived mailsent.log.n files into one big log file --->
  <cfloop from="1" to="100" index="variables.counter">

    <!--- define archived log file name --->
    <cfset variables.logFile = "#variable.logfolder#\mailsent.log.#variables.counter#">
    <cfif fileExists( variables.logFile )>
          <cfset writeDebug("processing #variables.logFile#.#variables.counter#")>
          <!--- concatenate all archived files into one big log file --->
          <cffile action="read" file="#variables.logFile#" variable="variables.logContent">
          <cffile action="append" file="#variables.bigLogFile#" output="#variables.logContent#">
          <cffile action="rename" source="#variables.logFile#" destination="#variables.logFile#.done">
          <cfset writeDebug("done with #variables.logFile#.#variables.counter#")>
    </cfif>

  </cfloop>   <!--- from="1" to="100" index="variables.counter"> --->

  <cfset writeDebug("passing #variables.bigLogFile# to SQL stored procedure to process")>

  <!--- Step 3. pass the combined log file to SQL to perform the db update --->

  <cfif fileExists( variables.bigLogFile )>

  <cfstoredproc procedure="Upload_Email_Message_Log" datasource="#application.datasource#">
    <cfprocparam type="In" cfsqltype="cf_sql_varchar" value = "#variables.bigLogFile#">
  </cfstoredproc>

  <cffile action="delete" file="#variables.bigLogFile#">

  </cfif>
  <cfset writeDebug("ending mailsent scheduled task, elapsed time is #dateDiff('s', variables.startTime, now())# seconds")>

</cfoutput>
<cfabort>
<!---------------------------------------------------------------------------------------------------------------------->

<cffunction name="writeDebug" output="true">
    <cfargument name="text" required="true">
    <!--- detect if debug mode is on --->
      <cfif variables.debug>
          <cflog file="mailSentDebug" text="#arguments.text#">
      </cfif>
</cffunction>
<!---------------------------------------------------------------------------------------------------------------------->
<cffunction name="archiveMailSent" output="false">
    <cfscript>
          local.adminObj = createObject("component","cfide.adminapi.administrator");
		  local.cf_admin = application.util.query.cf_admin();
		  if ( local.adminObj.login( local.cf_admin.password, local.cf_admin.username ) ) {
                local.myObj = createObject("component","cfide.adminapi._servermanager.servermanager");
                local.myObj.archiveLogFile( "mailSent.log" );
                local.debugger = createObject("component", "cfide.adminapi.debugging");
                local.logfolder = local.debugger.getLogProperty("logdirectory");
            	return(local.logfolder);
          }
          	return('');
    </cfscript>
</cffunction>
