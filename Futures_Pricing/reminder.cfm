	<!------ reminder ----->
<cfoutput>
<!------ set defaults ----->
<cfset formName = "dataForm">
<cfparam name="form.state" default="0" />
<cfparam name="url.reminderId" default="0" />
<cfparam name="form.reminderId" default="#url.reminderId#" />
<cfparam name="url.reminderDisplay" default="1" />
<cfparam name="form.reminderDisplay" default="#url.reminderDisplay#" />


<!---initialize the components we need--->
<cfset reminderManager = CreateObject("component", "components.futures_pricing.ReminderManager") />

<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---////////////////////////////////////////////////// Controller Section //////////////////////////////////////////////////////////////--->
<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->

<!---if the command is sReminder then save and relocate--->
<cfif form.command eq "sReminder">
	
	<cfset requestObj = reminderManager.getReminders(form.id,0) />
	<cfset reminderObj = reminderManager.set(form) />
	<cfset reminderManager.save(reminderObj) />
	<cflocation addtoken="No" url="#thisPage#?command=dReminder&id=#requestObj.getId()#&reminderDisplay=#form.reminderDisplay#">

<cfelse>
	
	<cfset requestObj =  reminderManager.getReminders(form.id,0,form.reminderId,form.reminderDisplay) />	
	
</cfif>

<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---////////////////////////////////////////////////// End Controller Section //////////////////////////////////////////////////////////--->
<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->

<SCRIPT>
	
	function submitForm(formName, command) 
	{
		//set variables we need
		var formName = eval("document." + formName);
		
		//return boolean value
		var returnVal = true;
	
		//close the window if the command is close
		if (command == 'close')
		{
			window.close();
			returnVal = false;
		}
		else
		{
			//set variables we need
			var todayDate = formName.Today_Date.value;
			var reminderDate = formName.Reminder_Date.value;
			var reminderVal = formName.Reminder_Desc.value;
			
			//error spans
			var dateErrObj = document.all.Date_Err_Sp;
			var remindErrObj = document.all.Remind_Err_Sp;
			
			//do validation
			if (trim(reminderDate) == "")
			{
				queueMessage("Please provide a Reminder Date.", dateErrObj);
				returnVal = false;
			}
			else if (reminderDate <= todayDate)
			{
				queueMessage("Reminder date must be greater than today.", dateErrObj);
				returnVal = false;
			}
			else
			{
				clearQueue(dateErrObj);
			}
			
			if (trim(reminderVal) == "")
			{
				queueMessage("Please provide a reminder.", remindErrObj);
				returnVal = false;
			}
			else
			{
				clearQueue(remindErrObj);
			}
			
			//if returnVal is true then we know form is valid so we can submit
			if (returnVal)
			{
				formName.command.value = command;
				formName.submit();
				returnVal = false;
			}
			//otherwise show error message
			else
			{
				showMessageWindow();
			}
		}
		
		return returnVal;
	}
	
</SCRIPT>

<cfif form.command EQ "ceReminder">
	<cfinclude template="reminder_create_edit.cfm">
<cfelse>
	<cfinclude template="reminder_display.cfm">
</cfif>

</cfoutput>