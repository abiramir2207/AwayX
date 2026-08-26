
<cfparam name="request.AccessStructure.User_ID"   default="0">
<cfparam name="FileLineNumberCurrent"   default="0">
<cfparam name="linesBeInserted"   default="0">

<cfset LastLineNumber_previous =0>

<!--- ------------------------------------------------------------------------------ 
------ If the default SP dosen't work, setup this manual one.
------ check the daily backup batch code for mailsent_ files, manually update below FileExists path and remove <!--- from above line
<cfquery name="truncateAppTables" datasource="#application.datasource#">
	truncate table Message_Log_CF_Admin	
</cfquery> 


<cfif FileExists("D:\inetpub\log\emailLog_sent\mailsent_#DateFormat(now(), 'yyyymmdd')#.log")>
	<cfset l = "D:\inetpub\log\emailLog_sent\mailsent_#DateFormat(now(), 'yyyymmdd')#.log">

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

<cfquery name="updateSent_Date" datasource="#application.datasource#">
	update Message_Log
	set Message_Log.Sent_Date = Message_Log_CF_Admin.Message_Sent_Date
	from Message_Log
	inner JOIN Message_Log_CF_Admin on Message_Log.Message_From =  Message_Log_CF_Admin.MessageFrom
	and convert(varchar(max),Message_Log.Message_To) =  Message_Log_CF_Admin.MessageTo
	and Message_Log.Message_Subject =  Message_Log_CF_Admin.MessageSubject
	and convert(varchar(10),Message_Log.Created_Date,101) =  convert(varchar(10),Message_Log_CF_Admin.Message_Sent_Date,101)
	and DATEPART(hour,Message_Log.Created_Date) - DATEPART(hour,Message_Log_CF_Admin.Message_Sent_Date)  < 4
	where Message_Log.deleted = 0
	and Message_Log.Sent_Date is NULL
</cfquery>

<br> updated Message_Log.Sent_Date - done<br>

------------------------------------------------------------------------------ --->