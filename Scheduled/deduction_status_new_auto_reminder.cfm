<!------ /scheduled/deduction_status_new_auto_reminder.cfm ----->

<!------ Initialise ----->
<cfset deductionManager = CreateObject("component", "components.deduction.DeductionManager").init() />
<cfset deductionSettingsManager = CreateObject("component", "components.deduction.settings.DeductionSettingsManager").init() />
<cfset newToOpenLagTime = deductionSettingsManager.get().getDDNewAddReminderAfterDays() />

<cfif newToOpenLagTime GT 0>

	<!------ Get the deduction type for typeOfReminderType = 3 ----->
	<cfset reminderType = deductionManager.getReminderTypeId(3) />
	<cfset newStatusDesc = LCase(deductionManager.getReminderStatusDesc(1)) />
	
	<!------ 
	Find out if there are any deduction which has not been opened fro x days and do not have the 'new deduction' reminder, if so add a reminder to the Analyst
	----->
	
	<cfquery name="qGetNewDeductions" datasource="#application.datasource#">
		SELECT	Deductions.Deduction_ID, Deductions.DD_DedID, DateDiff(d, Deductions.Created_Date, GetDate()) Days_Since_Creation
		FROM	Deductions
		
		WHERE	Deductions.Deleted = 0
		AND		Deductions.DD_Status = 1<!------ New ----->
		AND		DateDiff(d, Deductions.Created_Date, GetDate()) >= #newToOpenLagTime#
		AND		Deductions.Deduction_ID NOT IN
		(
			SELECT	DISTINCT Deduction_ID
			FROM	DD_Reminders
			WHERE	Deleted = 0
			AND		DD_Reminder_Type = <cfqueryparam value="#reminderType#" cfsqltype="CF_SQL_INTEGER">
		)	
	</cfquery>
	
	<cfloop query="qGetNewDeductions">
	
		<cfset deductionManager.addReminder(
					deductionId = Deduction_ID,
					reminderType = reminderType,
					reminderMessage = "Deduction #Trim(DD_DedID)# is in #newStatusDesc# status for more than #newToOpenLagTime# days",
					reminderDate = "#Now()#",
					emailReminder = 1)	>
					
	</cfloop>

</cfif>