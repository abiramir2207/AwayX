<cfcomponent hint="Futures Pricing Raw Material Manager" extends="components.futures_pricing.RequestManager">
	
	<cffunction name="init" output="false" returntype="components.futures_pricing.ReminderManager">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="getReminders" output="false" returntype="components.futures_pricing.Request">
	
		<cfargument name="id" type="numeric" required="false" default="0" />
		<cfargument name="pagePhase" type="numeric" required="false" default="0" />
		<cfargument name="reminderId" type="numeric" required="false" default="0" />
		<cfargument name="justToday" type="numeric" required="false" default="0" hint="1 = just get todays reminders, 2 = get all reminders for this request" />
		
		<cfset this.get(arguments.id, arguments.pagePhase)>
		<cfset this.getRemindersFromDB(arguments.id, arguments.reminderId, arguments.justToday) />

		<cfreturn this.request	/>
	
	</cffunction>
	
	<cffunction name="getRemindersFromDB" output="false">
		
		<cfargument name="id" type="numeric" required="false" default="0" />
		<cfargument name="reminderId" type="numeric" required="false" default="0" />
		<cfargument name="justToday" type="numeric" required="false" default="0" hint="1 = just get todays reminders, 2 = get all reminders for this request" />
		
		<cfquery name="qGetReminders" datasource="#application.datasource#">
		
			SELECT 	FP_Reminder_ID,
					FP_Request_Master_ID,
					Reminder_Desc,
					Email_Reminder,
					Reminder_Date,
					IsPrivate,
					Created_By,
					Created_Date
			FROM	FP_Reminder
			WHERE	Deleted = 0
			AND		FP_Request_Master_ID = #arguments.id#
			<cfif arguments.reminderId>
			AND		FP_Reminder_ID = #arguments.reminderId#
			</cfif>
			<cfif arguments.justToday eq 1 and not arguments.reminderId>
			AND		Reminder_Date = <cfqueryparam value="#DateFormat(Now(), "yyyy-mm-dd")#" cfsqltype="CF_SQL_DATE" />
			</cfif>
			
		</cfquery>		
		
		<cfloop query="qGetReminders">
			
			<!---create an instance of the Reminder object--->
			<cfset reminderObj = CreateObject("component", "components.futures_pricing.Reminder") />
			<cfset reminderObj.setId(FP_Reminder_ID) />
			<cfset reminderObj.setRequestId(FP_Request_Master_ID) />
			<cfset reminderObj.setDesc(Reminder_Desc) />
			<cfset reminderObj.setEmailReminder(Email_Reminder) />
			<cfset reminderObj.setReminderDate(Reminder_Date) />
			<cfset reminderObj.setIsPrivate(IsPrivate) />
			<cfset reminderObj.setCreatedBy(Created_By) />
			<cfset reminderObj.setCreatedDate(Created_Date) />

			<cfset this.request.setReminder(reminderObj)	/>
			
		</cfloop>
		
	</cffunction>
	
	<cffunction name="set" output="false" returntype="components.futures_pricing.Reminder">
		
		<cfargument name="stData" type="struct" required="false" default="" />		
		<cfparam name="arguments.stData.isPrivate" default=0 />
		
		<!---create an instance of the Reminder object--->
		<cfset reminderObj = CreateObject("component", "components.futures_pricing.Reminder") />
		<cfset reminderObj.setId(arguments.stData.reminderId) />
		<cfset reminderObj.setRequestId(arguments.stData.id) />
		<cfset reminderObj.setDesc(arguments.stData.Reminder_Desc) />
		<cfset reminderObj.setEmailReminder(arguments.stData.Email_Reminder) />
		<cfset reminderObj.setReminderDate(arguments.stData.Reminder_Date) />
		<cfset reminderObj.setIsPrivate(arguments.stData.isPrivate) />
		<cfset reminderObj.setCreatedBy(arguments.stData.createdBy) />
			
		<cfreturn reminderObj />
		
	</cffunction>
	
	<cffunction name="save" output="false">
		
		<cfargument name="reminderObj" required="true" default="" type="components.futures_pricing.Reminder" />
		
		<!---if we have an id then update--->
		<cfif arguments.reminderObj.getId()>
			
			<cfquery name="qUpdateReminder" datasource="#application.datasource#">
			
				UPDATE 	FP_Reminder
				SET		Reminder_Desc = <cfqueryparam value="#trim(arguments.reminderObj.getDesc())#" cfsqltype="CF_SQL_VARCHAR">, 
						Email_Reminder = <cfqueryparam value="#arguments.reminderObj.getEmailReminder()#" cfsqltype="CF_SQL_NUMERIC">, 
						Reminder_Date = <cfqueryparam value="#arguments.reminderObj.getReminderDate()#" cfsqltype="CF_SQL_DATE">, 
						IsPrivate = <cfqueryparam value="#arguments.reminderObj.getIsPrivate()#" cfsqltype="CF_SQL_BIT">
				WHERE	FP_Reminder_ID = <cfqueryparam value="#arguments.reminderObj.getId()#" cfsqltype="CF_SQL_NUMERIC">
				AND		Deleted = 0
		
			</cfquery>
			
		<!---otherwise insert--->
		<cfelse>
		
			<cfquery name="qInsertReminder" datasource="#application.datasource#">
			
				INSERT INTO FP_Reminder
					(FP_Request_Master_ID, Reminder_Desc, Email_Reminder, Reminder_Date, IsPrivate, Created_By)
				VALUES
					(
						<cfqueryparam value="#arguments.reminderObj.getRequestId()#" cfsqltype="CF_SQL_NUMERIC">,
						<cfqueryparam value="#arguments.reminderObj.getDesc()#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#arguments.reminderObj.getEmailReminder()#" cfsqltype="CF_SQL_NUMERIC">,
						<cfqueryparam value="#arguments.reminderObj.getReminderDate()#" cfsqltype="CF_SQL_DATE">,
						<cfqueryparam value="#arguments.reminderObj.getIsPrivate()#" cfsqltype="CF_SQL_BIT">,
						<cfqueryparam value="#arguments.reminderObj.getCreatedBy()#" cfsqltype="CF_SQL_VARCHAR">
					)
		
			</cfquery>
		
		</cfif>
		
	</cffunction>
	
	<cffunction name="runReminders" output="true">
		
		<!---create instance of RequestManager--->
		<cfset requestManager = CreateObject("component", "components.futures_pricing.RequestManager") />

		<!---get reminders to run--->
		<cfset qGetRemindersToRun = this.getReminderQuery(1,1) />
		
		<cfset emailUserIds = "" />
		<cfset prevRequestId = 0 />
		
		<cfloop query="qGetRemindersToRun">
			
			<!---if it's private then only send email to who created it--->
			<cfif IsPrivate>
				<cfset toEmail = Created_By_Email />
			<!---otherwise send reminder emails to all users in this request--->
			<cfelse>
				
				<!---if the previous request is not equal to the current request then get the email list--->
				<cfif prevRequestId neq FP_Request_Master_ID>
					<cfset emailUserIds = requestManager.getRequestUserEmails(FP_Request_Master_ID, FP_Status_ID) />
				</cfif>
				
				<cfset toEmail = emailUserIds />
				
			</cfif>
			
			<!---if the person who created the reminder isn't in the to list then add them--->
			<cfif not ListFindNoCase(toEmail, Created_By_Email)>
				<cfset toEmail = ListAppend(toEmail, Created_By_Email) />
			</cfif>

			<!---send email--->
			<cf_EmailWrapper
				to="#toEmail#"
				from="#Created_By_Email#"
				subject="! Reminder from Future Pricing Request - #FP_Request_Title#"
				messageType="1"
				generatedBy="1"
				appArea="14"
			>
				#Reminder_Desc#
			</cf_EmailWrapper>
			
			<!---mark as sent--->
			<cfset useLakebaseForqSetReminderSent = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("fp_reminder")>
<cfif useLakebaseForqSetReminderSent>
	<cftry>
		<cfset application.oLakebase.updateRows("fp_reminder",
			{
				"fp_reminder_id" = "eq.#FP_Reminder_ID#"
			},
			{
				"reminder_sent" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqSetReminderSent = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqSetReminderSent>
<cfquery name="qSetReminderSent" datasource="#application.datasource#">
				UPDATE 	FP_Reminder
				SET  	Reminder_Sent = 1
				WHERE	FP_Reminder_ID = #FP_Reminder_ID#
			</cfquery>
</cfif>
			
			<!---set the previous id to this id--->
			<cfset prevRequestId = FP_Request_Master_ID />
			
		</cfloop>

	</cffunction>
	
	<cffunction name="getReminderQuery" output="false" returntype="query">
		
		<cfargument name="justEmailReminders" type="boolean" required="false" default="0" />
		<cfargument name="todayReminders" type="boolean" required="false" default="0" />
		<cfargument name="requestId" type="boolean" required="false" default="0" />
		<cfargument name="privateByUserId" type="string" required="false" default="" />
		
		<cfquery name="qGetReminders" datasource="#application.datasource#">
			
			SELECT 	FP_Reminder.FP_Reminder_ID,	
					FP_Reminder.FP_Request_Master_ID,	
					FP_Reminder.Reminder_Desc,
					FP_Reminder.IsPrivate,
					FP_Reminder.Created_By,
					_Users.User_Email as Created_By_Email,
					FP_Request_Master.FP_Status_ID,
					FP_Request_Master.FP_Request_Title
			FROM 	FP_Reminder
					INNER JOIN _Users ON
					_Users.User_ID = FP_Reminder.Created_By
					AND _Users.Deleted = 0
					INNER JOIN FP_Request_Master ON
					FP_Request_Master.FP_Request_Master_ID = FP_Reminder.FP_Request_Master_ID
					AND _Users.Deleted = 0
			WHERE	FP_Reminder.Deleted = 0
			<cfif arguments.justEmailReminders>
			AND		FP_Reminder.Email_Reminder = 1
			AND		FP_Reminder.Reminder_Sent = 0
			</cfif>
			<cfif arguments.todayReminders>
			AND		FP_Reminder.Reminder_Date = <cfqueryparam value="#DateFormat(Now(), "yyyy-mm-dd")#" cfsqltype="CF_SQL_DATE" />
			<cfelse>
			AND		FP_Reminder.Reminder_Date >= <cfqueryparam value="#DateFormat(Now(), "yyyy-mm-dd")#" cfsqltype="CF_SQL_DATE" />
			</cfif>
			<cfif arguments.requestId>
			AND		FP_Reminder.FP_Request_Master_ID = #arguments.requestId#
			</cfif>		
			<cfif arguments.privateByUserId NEQ "">
			AND
				(
					IsPrivate = 0
					OR
					Created_By = '#arguments.privateByUserId#'
				)
			</cfif>
			ORDER BY FP_Reminder.FP_Request_Master_ID
		
		</cfquery>
		
		<cfreturn qGetReminders />
		
	</cffunction>
	
	<cffunction name="getReminderCount" output="false">
	
		<cfargument name="userID" required="false" default="" />
		<cfargument name="requestId" required="false" default="" />
		
		<!---count to increment based on whether the reminder is private or not--->
		<cfset rCount = 0 />
		
		<!---get the reminders for today--->
		<cfset qGetReminderForCount = this.getReminderQuery(0,1,arguments.requestId) />
		
		<cfset rCount = qGetReminderForCount.recordCount />
		
		<!---loop over each reminder and increment count based on private or not--->
		<!------ 
		<cfloop query="qGetReminderForCount">
			
			<!---if the reminder is private then increment only if the user id's match--->
			<cfif IsPrivate>
		
				<cfif arguments.userId eq Created_By>
					<cfset rCount = rCount + 1 />
				</cfif>
				
			<cfelse>
				<cfset rCount = rCount + 1 />
			</cfif>
			
		</cfloop> 
		----->
		
		<cfreturn rCount />
		
	</cffunction>
	
</cfcomponent>
