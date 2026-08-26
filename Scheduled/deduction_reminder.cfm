<!---Emails selected reminders to the deduction analyst assigned to the deduction that has the reminder the night before the reminder is set to come due--->

<!---Gets correct "From" address--->
<cfinclude template="/get_Contact_Admin_Email_Address.cfm">

<cfquery name="RemindersToBeSent" datasource="#application.datasource#">
SELECT Deductions.Analyst_User_ID, DD_Reminders.DD_Reminder_Date, DD_Reminders.DD_Reminder_ID, DD_Reminders.Others_To_Email, _users.Name_First, _users.Name_Last, _users.User_Email, DD_Reminder_Type.DD_Type_Name, DD_Reminders.DD_Reminder, Deductions.DD_Amount, Deductions.DD_Date, BSA_Foodservice_Customers.Name AS Distributor_Name, DD_Stage.DD_Stage_Description, Deductions.DD_DedID
FROM DD_Reminders
	INNER JOIN DD_Reminder_Type
	ON DD_Reminder_Type.DD_Reminder_Type_ID = DD_Reminders.DD_Reminder_Type
	INNER JOIN Deductions
	ON DD_Reminders.Deduction_ID = Deductions.Deduction_ID
	LEFT JOIN _users
	ON Deductions.Analyst_User_ID = _users.User_ID
	LEFT JOIN BSA_Foodservice_Customers
	ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Deductions.Distributor_ID 
	INNER JOIN DD_Stage
	ON DD_Stage.DD_Stage_ID = Deductions.DD_Stage
WHERE Email_Reminder = 1
AND DD_Reminders.Reminder_Sent = 0
AND DD_Reminders.DD_Reminder_Date <= #DateAdd('d', 1, Now())#
AND DD_Reminders.Deleted = 0
AND (Deductions.DD_Status < 4 OR Deductions.DD_Status = 7)
</cfquery>
<cfdump var="#RemindersToBeSent#">
<cfoutput>
	<cfloop query="RemindersToBeSent">

	<cfset UserEmail = User_Email>
	<!--- If the Analyst does not exist for a deduction, then send the email to the default Analyst. If
				the default Analyst does not exist, then send the email to no one --->
	<cfif UserEmail eq "">
			<cfquery name="Default_Analyst" datasource="#application.datasource#">
					SELECT _Users.User_Email 
					FROM DD_Analyst INNER JOIN _Users
					ON DD_Analyst.Analyst_User_ID = _Users.User_ID
					WHERE DD_Analyst.Default_Analyst = 1 
					AND DD_Analyst.DELETED = 0
			</cfquery>
			<cfset UserEmail = Default_Analyst.User_Email>
	</cfif>

	<cfif UserEmail neq "">
		 <CF_EMAILWRAPPER 
		to="#UserEmail#"
		cc="#Others_To_Email#"
		from="#Contact_Admin_Email_Address#"
		subject=" Deduction Reminder for #dateformat(DD_Reminder_Date, 'MM/DD/YYYY')#"
		type="html"
		messagetype="1"
		generatedby="1"
		apparea="13">
		<strong>Reminder Date:</strong> #dateformat(DD_Reminder_Date, 'MM/DD/YYYY')#<br>
		<strong>Reminder Type:</strong>#DD_Type_Name#<br>
		<strong>Reminder Text:</strong> #DD_Reminder#<br>
		
		<strong>Deduction Info:</strong><br>
		Deduction Number: #DD_DedID#<br>
		#application.returned_customer_setting.distributor_label_singular#: #Distributor_Name#<br>
		Date the deduction was created: #dateformat(DD_Date, 'MM/DD/YYYY')#<br>
		Deduction Amount: #lscurrencyformat(DD_Amount)#<br>
		Current Action: #DD_Stage_Description#<br>
		
		 </CF_EMAILWRAPPER>
			
	
		 <!---Update Reminder to say that it has been sent--->
		<cfquery name="UpdateReminder" datasource="#application.datasource#">
		UPDATE DD_Reminders
		SET Reminder_Sent = 1
		WHERE DD_Reminder_ID = '#DD_Reminder_ID#'
		</cfquery> 
	</cfif>

	</cfloop>
</cfoutput>
