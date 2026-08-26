<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dhtml.js"></SCRIPT>
<cfparam name="DD_Reminder_Date" default="">
<cfparam name="DD_Reminder" default="">
<cfparam name="DD_Reminder_Type" default="1">
<cfparam name="Edit" default="0">

<cfif isDefined("blnSubmit")>

<cfif len(trim(Others_To_Email)) GT 0>
<cfset Email_Reminder = 1>
</cfif>

<cfset deductionManager = CreateObject("component", "components.deduction.DeductionManager").init() />

<cfif Edit IS 1>
	<cfset useLakebaseForUpdateReminder = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_reminders")>
	<cfif useLakebaseForUpdateReminder>
		<cftry>
			<cfset application.oLakebase.updateRows("dd_reminders",
				{ "dd_reminder_id" = "eq.#DD_Reminder_ID#" },
				{
					"dd_reminder" = DD_Reminder,
					"dd_reminder_type" = DD_Reminder_Type,
					"dd_reminder_date" = DD_Date_for_Reminder,
					"dd_reminder_status" = DD_Reminder_Status,
					"email_reminder" = Email_Reminder,
					"others_to_email" = Others_To_Email
				}
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForUpdateReminder = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForUpdateReminder>
	<cfquery name="UpdateReminder" datasource="#application.datasource#">
	UPDATE DD_Reminders
	Set DD_Reminder = '#DD_Reminder#',
		DD_Reminder_Type = #DD_Reminder_Type#,
		DD_Reminder_Date = '#DD_Date_for_Reminder#',
		DD_Reminder_Status = #DD_Reminder_Status#,
		Email_Reminder = #Email_Reminder#,
		Others_To_Email = '#Others_To_Email#'
	WHERE DD_Reminder_ID = '#DD_Reminder_ID#'
	</cfquery>
	</cfif>

<cfelse>
	<cfset deductionManager.addReminder(
				deductionId 		= Form.Deduction_ID,
				reminderMessage 	= DD_Reminder,
				reminderDate 		= DD_Date_for_Reminder,
				emailReminder 		= Email_Reminder,
				reminderType 		= DD_Reminder_Type,
				reminderStatus 		= DD_Reminder_Status,
				extraEmailAddress 	= Others_To_Email)	>

</cfif>
	<script>
		if (window.opener)
		{
			//window.opener.location.reload();
			window.opener.location.href = "../deduction.cfm?Deduction_ID=<cfoutput>#Form.Deduction_ID#</cfoutput>";
		}
		window.close();
		/*window.close()
		opener.document.all.Refresh.submit()*/
	</script>
</cfif>

<cfoutput>
<form action="/deductions/reminders/create_reminder.cfm" method="post" name="Reminder">

<cfif IsDefined("DD_Reminder_ID")>
	<cfset Edit = 1>
</cfif>

<cfif Edit IS 1>
<cfset useLakebaseForGetReminder = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_reminders")>
<cfif useLakebaseForGetReminder>
	<cftry>
		<cfset GetReminder = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_reminders", {
				"dd_reminder_id" = "eq.#DD_Reminder_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetReminder = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetReminder>
<cfquery name="GetReminder" datasource="#application.datasource#">
SELECT *
FROM DD_Reminders
WHERE DD_Reminder_ID = '#DD_Reminder_ID#'
</cfquery>
</cfif>
</cfif>

<!--- reminder date --->
<cfif Edit IS 1 and GetReminder.recordCount gt 0>
	<cfset reminderDate = GetReminder.DD_Reminder_Date />
<cfelse>
	<cfset reminderDate = dateadd('d', 1, now()) />
</cfif>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Create a Reminder</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/fixed_popup.js"></SCRIPT>
</head>

<body onload = "mytimer = setTimeout('fcsOnMe()', 25);">
<table width="90%" align="center"><tr><Td valign="Center">
<strong><font size="+1" color="navy">Create a Reminder</font></strong></td><td valign="Center" align="right"><img src="/images/reminder2.gif">&nbsp; &nbsp; &nbsp; </TD></tr>

</table>



<table width="90%" align="center" style="border-left:solid navy 2px;	border-right:solid navy 2px;		border-top:solid navy 2px; border-bottom:solid navy 2px;">
<tr>
	<td>Date to be reminded: <div id="error_DD_Reminder_Date">&nbsp;</div></td>
	<td> <CF_EASYDATE FORMNAME="Reminder" FIELDNAME="DD_Date_for_Reminder" FORMAT="mm/dd/yyyy" DEFAULT="#reminderDate#"></td>
</tr>
<tr>
	<td>Reminder Type:  </td>
	<td>

	<cfset useLakebaseForGetTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_reminder_type")>
<cfif useLakebaseForGetTypes>
	<cftry>
		<cfset GetTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_reminder_type", {
				"deleted" = "eq.0",
				"order" = "dd_type_name.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetTypes>
<cfquery name="GetTypes" datasource="#application.datasource#">
	SELECT * From DD_Reminder_Type
	WHERE Deleted = 0
	ORDER BY DD_Type_Name
	</cfquery>
</cfif>

		<select name="DD_Reminder_Type" onfocus="skipcycle=true" onblur="skipcycle=false">
			<cfloop query="GetTypes">
			<option value="#DD_Reminder_Type_ID#" <cfif EDIT IS 1><cfif GetReminder.DD_Reminder_Type IS GetTypes.DD_Reminder_Type_ID> selected</cfif></cfif>>#DD_Type_Name#</option>
			</cfloop>
		</select>
	</td>
</tr>
<tr>
	<td>Email this reminder the night before?:  </td>
	<td>
	<input type="radio" name="Email_Reminder" value="0" checked> No&nbsp; &nbsp; &nbsp; <input type="radio" name="Email_Reminder" value="1" <cfif EDIT IS 1><cfif #GetReminder.Email_Reminder# IS 1>checked</cfif></cfif>> Yes
	</td>
</tr>

<tr>
	<td colspan="2">Email others -- in addition to deduction owner:
	<br>(separate emails with commas)  </td>
</tr>
<tr>
	<Td>&nbsp; </TD>
	<td>
	<input type="text" size="43" name="Others_To_Email" <cfif Edit IS 1>value="#GetReminder.Others_To_Email#"</cfif> maxlength="500" onfocus="skipcycle=true" onblur="skipcycle=false">
	</td>
</tr>
<tr>
	<td valign="top">Reminder Text: <div id="error_DD_Reminder">&nbsp;</div> </td>
	<td>
	<textarea name="DD_Reminder" cols="45" rows="4" onPaste="javaScript: return textareaChecklength('500', this);"  onkeyPress="javaScript: return textareaChecklength('500', this);" onfocus="skipcycle=true" onblur="skipcycle=false"><cfif Edit IS 1>#GetReminder.DD_Reminder#</cfif></textarea>
	</td>
</tr>

</table>

<input type="hidden" name="Deduction_ID" value="#Deduction_ID#">
<input type="hidden" name="DD_Reminder_Status" value="0">
<input type="hidden" name="blnSubmit" value="1">
<input type="hidden" name="Edit" value="#Edit#">
<cfif Edit IS 1>
	<input type="hidden" name="DD_Reminder_ID" value="#DD_Reminder_ID#">
</cfif>
<br>
<div align="center">
<a href="##" onClick="confirmCompletion();"><strong><font color="navy">[ save reminder ]</font></strong></a>

</div>
</form>



<CF_MessageWindow>
<SCRIPT SRC="/Script/javascript/date_functions.js"></SCRIPT>
<script>

/*
Seems like this function is not being used. So, commented it.
function popGLWindow() {
		selectedGLCode = parseInt(document.all.GL_Assignment_ID.value);
		vReturnValue = window.showModalDialog("/common_files/contracts/GL_Codes.cfm",selectedGLCode,"dialogHeight: 500px; dialogWidth: 700px; dialogTop: px; dialogLeft: px; edge: Raised; center: Yes; help: No; resizable: No; status: No;");
		if(vReturnValue !=null)	{
			document.all.GL_Text.value = vReturnValue.GL_Name;
			document.all.GL_Assignment_ID.value = vReturnValue.value;
			selectedGLCode = vReturnValue.value
		}
	}
*/

function confirmCompletion(){

	ErrorCount = 0

	<!--- Dates --->
		if(document.all.DD_Date_for_Reminder.value.length == 0)	{
			ErrorCount++;
			queueMessage("You must enter a reminder date.", document.all.error_DD_Reminder_Date);
		}
		else
		{
			clearQueue(document.all.error_DD_Reminder_Date);
		}

		ReminderDate = new Date(document.all.DD_Date_for_Reminder.value);
		Today = new Date(#year(now())#, #evaluate(month(now()) -1)#, #day(now())#);
		IsOlder = days_between(ReminderDate, Today)

	 	if(IsOlder < 0)	{

			ErrorCount++;
			queueMessage("The reminder date must be today or later.", document.all.error_DD_Reminder_Date);
		}
		else
		{
			clearQueue(document.all.error_DD_Reminder_Date);
		}

		if( jQuery("textarea[name=DD_Reminder]").val() == 0)	{  //  hromeFix  document.all.DD_Reminder.value.length
			ErrorCount++;
			queueMessage("You must enter reminder text.", document.all.error_DD_Reminder);
		}
		else
		{
			clearQueue(document.all.error_DD_Reminder);
		}


			<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
			if(ErrorCount == 0) {
					Reminder.submit()
			}
			else {
				showMessageWindow()
			}

		}
</script>

</cfoutput>
</body>
</html>