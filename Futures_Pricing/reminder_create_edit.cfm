<cfoutput>

<!---if we have a reminder object then set it, otherwise clear the reminder and create and empty one--->
<cfif ArrayLen(requestObj.getReminder()) and form.reminderId>
	<cfset reminder = requestObj.getReminder() />
<cfelse>
	<cfset reminderObj = CreateObject("component", "components.futures_pricing.Reminder").init() />
	<cfset ArrayClear(requestObj.reminder) />
	<cfset requestObj.setReminder(reminderObj) />
</cfif>

<!---set the reminder object --->
<cfset reminder = requestObj.getReminder() />

<br>
<B><FONT SIZE="4" COLOR="##000080">Add/Edit Reminder</FONT></B>&nbsp;&nbsp;&nbsp;
<hr color="##000080">
<form action="#thisPage#?command=sReminder&id=#requestObj.getId()#" method="post" name="#formName#">

<table border="0" cellpadding="2" cellspacing="0">
	<tr>
		<td><span id="Date_Err_Sp"></span>Reminder Date:</td>
		<td>		
			<CF_EASYDATE 
				FORMNAME="#formName#" 
				FIELDNAME="Reminder_Date" 
				FORMAT="mm/dd/yyyy" 
				DEFAULT="#DateFormat(reminder[1].getReminderDate(), "mm/dd/yyyy")#">
		</td>
	</tr>
	<tr>
		<td>Email Notification?</td>
		<td>		
			Yes&nbsp;<input name="Email_Reminder" type="radio" value="1" <cfif reminder[1].getEmailReminder()>checked</cfif>>
			No&nbsp;<input name="Email_Reminder" type="radio" value="0" <cfif not reminder[1].getEmailReminder()>checked</cfif>>
		</td>
	</tr>
	<tr>
		<td>Mark private?</td>
		<td><input name="isPrivate" type="checkbox" value="1" <cfif reminder[1].getIsPrivate()>checked</cfif> /></td>
	</tr>
</table>
<br>
<table border="0" cellpadding="0" cellspacing="0">
	<tr><td><span id="Remind_Err_Sp"></span>Reminder:</td></tr>
	<tr>
		<td colspan="100%"><textarea name="Reminder_Desc" cols="75" rows="5">#reminder[1].getDesc()#</textarea></td>
	</tr>
</table>
<br>
<CF_smallLink 
	title = "save" 
	url = "##"
	parameters = "onClick=""JavaScript: return submitForm('#formName#','sReminder');"""
>
<CF_smallLink 
	title = "cancel" 
	url = "#thisPage#?command=dReminder&id=#requestObj.getId()#"
>

<INPUT NAME="createdBy" TYPE="Hidden" VALUE="#request.AccessStructure.User_Id#" />
<INPUT NAME="command" TYPE="Hidden" value="#form.command#" />
<INPUT NAME="id" TYPE="Hidden" VALUE="#requestObj.getId()#" />
<INPUT NAME="reminderId" TYPE="Hidden" VALUE="#reminder[1].getId()#" />
<INPUT NAME="Today_Date" TYPE="Hidden" VALUE="#DateFormat(Now(), "mm/dd/yyyy")#" />
<INPUT NAME="reminderDisplay" TYPE="Hidden" VALUE="#form.reminderDisplay#" />

</form>

<cf_MessageWindow />
</cfoutput>
