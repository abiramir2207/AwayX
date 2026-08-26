
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfparam name="request.AccessStructure.User_ID"   default="0">
<cfparam name="FileLineNumberCurrent"   default="0">
<cfparam name="linesBeInserted"   default="0">

<cfset LastLineNumber_previous=0>

<cfset useLakebaseForGet_AppDocument_path = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_application_settings")>
<cfif useLakebaseForGet_AppDocument_path>
	<cftry>
		<cfset Get_AppDocument_path = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_application_settings", {
				"select" = "document_path"
			}), "document_path"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_AppDocument_path = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_AppDocument_path>
<CFQUERY NAME="Get_AppDocument_path" datasource="#application.datasource#">
	select document_path
	from _application_settings
</CFQUERY>
</cfif>

<cfset currentPath = getCurrentTemplatePath()>
<cfset currentDirectory = getDirectoryFromPath(currentPath)>

<cfset DocumentPath = Replace(currentDirectory, "settings\", "common_documents")>
<!--- D40718 :: Event error when clicking on email log--->
<cfif (request.AccessStructure.Company_Name NEQ "Simplot") AND (Left(Get_AppDocument_path.document_path, 2) eq "\\")>
	<cfset DocumentPath = Replace(currentDirectory, "settings\", "common_documents")>
<cfelse>
	<cfset DocumentPath = appSettings.getDocumentPath()>	
</cfif>

<cfif  FileExists("#Server.ColdFusion.RootDir#\logs\mailsent.log")>
	<cffile action="copy"	source="#Server.ColdFusion.RootDir#\logs\mailsent.log" destination="#DocumentPath#\Cf_Email_Log\mailsent_log_#request.AccessStructure.User_ID#.txt">
</cfif>

<cfif FileExists("#DocumentPath#\Cf_Email_Log\LastLineNumber.txt")>
	<cffile action="read" file="#DocumentPath#\Cf_Email_Log\LastLineNumber.txt" variable="LastLineNumber_previous" >
	<cfset LastLineNumber_previous = val(LastLineNumber_previous)/><!--- D34595 :EVENT ERROR:  SELECTING EMAIL LOG --->
</cfif>

<cfif FileExists("#DocumentPath#\Cf_Email_Log\mailsent_log_#request.AccessStructure.User_ID#.txt")>
	<cfset l = "#DocumentPath#\Cf_Email_Log\mailsent_log_#request.AccessStructure.User_ID#.txt">

	<cfset lines = []>
	<cfloop index="l" file="#l#">
		<cfset arrayAppend(lines,l)>
	</cfloop>
	<cfset FileLineNumberCurrent = #arrayLen(lines)# />

	<cffile action="write" file="#request.app_general_functions.Get_Document_Path()#\Cf_Email_Log\LastLineNumber.txt" output="#FileLineNumberCurrent#" >
	
	<cfset linesBeInserted = #arrayLen(lines)#-#LastLineNumber_previous# />
	<cfif  #linesBeInserted# lt -5000>
		<cfset LastLineNumber_previous = 0>
		<cfset linesBeInserted = #arrayLen(lines)#>
	</cfif>

	<cfif  #linesBeInserted#  gt 0>
		<cfset tail = []>
		<cfloop index="x" from="#max(LastLineNumber_previous+1,1)#" to="#arrayLen(lines)#"  step="1">
		<cfset lenStr = #len(lines[x])# />
		<cfset Mail_pos = #find(',"Mail: ', lines[x])#>
		<cfif Mail_pos gt 12>
			<cfset cfMessage = #right(lines[x], lenStr-Mail_pos-8)#>
			<cfset cfTime = #left(lines[x], Mail_pos-3)#>

			<cfset lenStrcfMessage = #len(cfMessage)# />
			<cfset From_pos = #find("' From:'", cfMessage)#>
			
			<cfset cfSubjectTemp = #left(cfMessage, From_pos-1)#>
			<cfset cfSubject = #replace(cfSubjectTemp,'""','"','All')#>
			<cfset cfFromTo = #right(cfMessage, lenStrcfMessage-From_pos-7)#>

			<cfset lenStrcfFromTo = #len(cfFromTo)# />
			<cfset To_pos = #find("' To:'", cfFromTo)#>
			<cfset cfFrom = #left(cfFromTo, To_pos-1)#>
			<cfset cfTo = #right(cfFromTo, lenStrcfFromTo-To_pos-5)#>

			<cfset ToRemove_pos = #find("' was successfully sent using ", cfTo )#>
			<cfset cfToTemp = #left(cfTo, ToRemove_pos-1)#>
			<cfset cfTo = #replace(cfToTemp," ","","All")#>

			<cfset lenStrcfTime = #len(cfTime)# />
			<cfset cfTime1_pos = #find('",', cfTime)#>
			<cfset cfTime2_pos = #Find('",', cfTime, cfTime1_pos + 1)#>
			<cfset cfTime = #right(cfTime, lenStrcfTime-cfTime2_pos-2)#>
			<cfset cfTime = #replace( cfTime, '","', ' ')# />

			<cfoutput>
			<cfquery name="InsertCFLog" datasource="#application.datasource#">
				INSERT INTO	Message_Log_CF_Admin
				(MessageTo,MessageFrom,MessageSubject,Message,Message_Sent_Date)
				Values		('#cfTo#','#cfFrom#','#cfSubject#','#lines[x]#',#createodbcdatetime(cfTime)#)
			</cfquery>
			</cfoutput>

			<!---<cfset arrayPrepend(tail, lines[x])>--->
		</cfif>
		</cfloop>
	</cfif>
</cfif>



