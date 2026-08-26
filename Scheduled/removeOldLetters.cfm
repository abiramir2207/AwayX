<!---
  This scheduled task remove letters where:
  a.	They are associated to a program version that is Deleted = 1 [e.g., the program version has been replaced by a subsequent program version]
  AND
  b.	They are associated to a program version that was approved N days ago or greater [app setting to determine how long ago is N]
--->

<cfset useLakebaseForrsAppSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_application_settings")>
<cfif useLakebaseForrsAppSettings>
	<cftry>
		<cfset rsAppSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_application_settings", {
				"limit" = "1",
				"select" = "letter_removal_min_age_in_days"
			}), "letter_removal_min_age_in_days"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForrsAppSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForrsAppSettings>
<cfquery name="rsAppSettings" datasource="#application.datasource#">
  SELECT TOP 1 Letter_Removal_Min_Age_In_Days
    FROM _Application_Settings
</cfquery>
</cfif>

<cfscript>
  ApprovalMininumAgeinDays = rsAppSettings.Letter_Removal_Min_Age_In_Days;
  
  liveSite = 1;    //TODO:  set this to 1 before checking in the file to CVS
  if ( liveSite eq 1 )
    LogStatus_Level = 0;
  else
    LogStatus_Level = 9;
  
  ApprovalCutOffDate = DateAdd('d', -ApprovalMininumAgeinDays, now());
  TIMEOUT_SECONDS = 360;
</cfscript>

<cfsetting requesttimeout=#TIMEOUT_SECONDS#>

<cfset LogStatus("Starting removal of old letters...")>

<cfif ApprovalMininumAgeinDays lt 30>
  <cfset LogStatus("Approval mininum age in days is " & ApprovalMininumAgeinDays & ". It does not seems right!")>
  <cfset LogStatus("Stopping removal of old letters...")>
  <cfabort>
</cfif>

<cfquery name="rsDeletedPrograms" datasource="#application.datasource#">
  SELECT Contract_Main_ID
    FROM CONTRACT_MAIN CM 
   WHERE <!---select deleted programs--->
         CM.Deleted = 1
         <!---with approval date is older than the cut off date--->
         AND CM.Approval_Date < <cfqueryparam cfsqltype="cf_sql_date" value="#ApprovalCutOffDate#">
         <!---and only select program with letters--->
         AND EXISTS (SELECT TOP 1 1 
                       FROM PROGRAM_LETTERS PL 
                      WHERE PL.Program_ID = CM.Contract_Main_ID)
</cfquery>

<cfset LogStatus("## of deleted programs with letters = " & rsDeletedPrograms.recordCount)>

<cfset objLetterManager = CreateObject("component", "mvc.Models.LetterManager") />

<cfloop query="rsDeletedPrograms">
  <cfquery name="rsLetters" datasource="#application.datasource#" result="rsResult">
    SELECT PL.Program_Letters_ID
      FROM PROGRAM_LETTERS PL 
     WHERE PL.Program_ID = #rsDeletedPrograms.Contract_Main_ID#
  </cfquery>
  
  <cfloop query="rsLetters">
    <!---remove old letter--->
  	<cfinvoke 
  		component = #objLetterManager#
  		method    = "deletePDFLetterInDBandFile"
  		program_letter_id = #rsLetters.Program_Letters_ID# >
    <cfset LogStatus("delete letter [" & rsLetters.Program_Letters_ID & "] for program ID [" 
                      & rsDeletedPrograms.Contract_Main_ID & "]")>
  </cfloop>
</cfloop>

<cfset LogStatus("Ending removal of old letters...")>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="LogStatus" output="true" returntype="void" hint="Log status to a log file.">
  <cfargument name="status" type="string" required="true" hint="">

  <cfscript>
    var logFile = "removeOldLetters";
  </cfscript>
  
  <!---is logging enabled?--->
  <cfif LogStatus_Level neq 0>
    <!---is there anything to log?--->
    <cfif len(trim(arguments.status))>
      <cflog file="#logFile#" text="#arguments.status#">
    </cfif>
  </cfif>
</cffunction>
