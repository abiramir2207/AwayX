<cfparam name="Close" default="0">

<cfif Close IS 1>
	<cfset useLakebaseForCloseReminder = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_reminders")>
	<cfif useLakebaseForCloseReminder>
		<cftry>
			<cfset application.oLakebase.updateRows("dd_reminders",
				{ "dd_reminder_id" = "eq.#DD_Reminder_ID#" },
				{ "dd_reminder_status" = 1 }
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForCloseReminder = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForCloseReminder>
	<cfquery name="CloseReminder" datasource="#application.datasource#">
	UPDATE DD_Reminders
	SET DD_Reminder_Status = 1
	WHERE DD_Reminder_ID = '#DD_Reminder_ID#'
	</cfquery>
	</cfif>
	
	<script>
		if (window.opener)
		{
			window.opener.location.reload();
		}
		window.close();
		/*window.close()		
		opener.document.all.Refresh.submit()*/
	</script>
	<cfabort>

</cfif>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Reminder Details</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/fixed_popup.js"></SCRIPT>
</head>

<body onload = "mytimer = setTimeout('fcsOnMe()', 25);">

<cfoutput>

<cfset useLakebaseForDeductionInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForDeductionInfo>
	<cftry>
		<cfset DeductionInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions", {
				"select" = "dd_dedid,sp_number",
				"deduction_id" = "eq.#Deduction_ID#"
			}),
			"dd_dedid,sp_number"
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForDeductionInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeductionInfo>
<cfquery name="DeductionInfo" datasource="#application.datasource#">
SELECT Deductions.DD_DedID,Deductions.SP_Number
FROM Deductions
WHERE Deduction_ID = '#Deduction_ID#'
</cfquery>
</cfif>

<!---Reminder data--->
<cfquery name="Reminder" datasource="#application.datasource#">
SELECT DD_Reminders.* , DD_Reminder_Type.DD_Type_Name
FROM DD_Reminders 
	INNER JOIN DD_Reminder_Type
	ON DD_Reminder_Type.DD_Reminder_Type_ID = DD_Reminders.DD_Reminder_Type
WHERE DD_Reminder_ID = '#DD_Reminder_ID#'
</cfquery>

<cfquery name="GetBroker" datasource="#application.datasource#">
SELECT BSA_Foodservice_Brokers.*
FROM Deductions
	INNER JOIN BSA_Foodservice_Brokers
	ON BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Deductions.Broker_ID
WHERE Deduction_ID = '#Deduction_ID#'
</cfquery>

<cfquery name="GetDistributor" datasource="#application.datasource#">
SELECT BSA_Foodservice_Customers.*
FROM Deductions
	INNER JOIN BSA_Foodservice_Customers
	ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Deductions.Distributor_ID
WHERE Deduction_ID = '#Deduction_ID#'
</cfquery>


<div align="center">

<table width="90%" align="center"><tr><Td valign="Center">
<strong><font size="+1" color="navy">Reminder for Deduction ###DeductionInfo.DD_DedID# <CFIF DeductionInfo.SP_Number NEQ ""> - #DeductionInfo.SP_Number#<CFELSE>- 000</CFIF></font></strong></td><td valign="Center" align="right"><CFIF Not Isdefined("FromReminderEFC")><img src="/images/reminder2.gif">&nbsp; &nbsp; &nbsp; </CFIF></TD></tr>

</table>

<table border="0" cellpadding="2" cellspacing="0" width="90%" align="center" style="border-left:solid navy 2px;	border-right:solid navy 2px; border-top:solid navy 2px; border-bottom:solid navy 2px;">

<tr>
	<td>Reminder Type:</td>
	<td colspan="2">#Reminder.DD_Type_Name#</td>
</tr>
<tr>
	<td>Reminder Date:</td>
	<td colspan="2">#dateformat(Reminder.DD_Reminder_Date, 'MM/DD/YYYY')#</td>
</tr>
<tr>
	<td valign="top">Reminder:</td>
	<td colspan="2">#Reminder.DD_Reminder#</td>
</tr>
<cfif Reminder.Email_Reminder IS 1>
<tr>
	<td>&nbsp; </td>
	<td valign="top" colspan="2">An email will be sent regarding this reminder.</td>
</tr>
<tr>
	<td valign="top">Others emailed:</td><Td colspan="2">#Reminder.Others_To_Email#</td>
</tr>
<cfelse>
<tr>
	<td>&nbsp; </td>
	<td valign="top" colspan="2">No one will be emailed regarding this reminder.</td>
</tr>

</cfif>
<tr><td colspan="3" STYLE="border-bottom: 1px solid lightsteelblue;"><strong>Broker Information</strong></td></tr>
<tr>
	<td valign="top">Broker Name:</td>
	<td colspan="2">#GetBroker.Broker_Name#</td>
</tr>
<tr>
	<td valign="top">Account Executive:</td>
	<td colspan="2">#GetBroker.Account_Exec#</td>
</tr>
<tr>
	<td valign="top">Address:</td>
	<td colspan="2">#GetBroker.Address#
		<cfif len(trim(GetBroker.Address_2)) GT 0><br>#GetBroker.Address_2#</cfif>
		<br>#GetBroker.City#, #GetBroker.State# #GetBroker.Zip#
	</td>
</tr>
<tr>
	<td valign="top">Phone:</td>
	<td>(#GetBroker.Phone_1#) #GetBroker.Phone_2#-#GetBroker.Phone_3# <cfif len(trim(GetBroker.Phone_Ext)) GT 0> x#GetBroker.Phone_Ext#</cfif>
	</td>
	<td><CFIF Not Isdefined("FromReminderEFC")><a href="/deductions/communications/call_log.cfm?Deduction_ID=#Deduction_ID#">Call Log</a></CFIF></td>
</tr>
<tr>
	<td valign="top">Fax:</td>
	<td><cfif len(trim(GetBroker.Fax_1)) GT 0>(#GetBroker.Fax_1#) #GetBroker.Fax_2#-#GetBroker.Fax_3# <cfelse>No fax</cfif>
	<cfset BrokerFaxNumber = 1 & GetBroker.Fax_1 & GetBroker.Fax_2 & GetBroker.Fax_3>
	</td>
	<td><CFIF Not Isdefined("FromReminderEFC")><A href="##" onclick="FaxThis('#Deduction_ID#','#BrokerFaxNumber#')">Fax This</a></CFIF></td>
</tr>
<tr>
	<td valign="top">Email:</td>
	<td><cfif len(trim(GetBroker.E_Mail)) GT 0>#GetBroker.E_Mail#<cfelse>No email</cfif>
	</td>
	<td><CFIF Not Isdefined("FromReminderEFC")><A href="##" onclick="eMailThis('#Deduction_ID#','#GetBroker.E_Mail#')">Email</a></CFIF></td><!---  --->
</tr>
<cfif GetDistributor.Recordcount IS 1>
<tr><td colspan="3" STYLE="border-bottom: 1px solid lightsteelblue;"><strong>#application.returned_customer_setting.distributor_label_singular# Information</strong></td></tr>
<tr>
 <td valign="top">#application.returned_customer_setting.distributor_label_singular# Name:</td>
 	<td colspan="2">#GetDistributor.Name#</td>
</tr>
<tr>
	<td valign="top">Address:</td>
	<td colspan="2">#GetDistributor.Address_1#
		<cfif len(trim(GetDistributor.Address_2)) GT 0><br>#GetDistributor.Address_2#</cfif>
		<br>#GetDistributor.City#, #GetDistributor.State# #GetDistributor.ZipCode#
	</td>
</tr>
<tr>

	<td valign="top">Phone:</td>
	<td>(#left(GetDistributor.Phone, 3)#) #left(right(GetDistributor.Phone, 7), 3)#-#right(GetDistributor.Phone, 4)#
	</td>
	<td><CFIF Not Isdefined("FromReminderEFC")><a href="/deductions/communications/call_log.cfm?Deduction_ID=#Deduction_ID#">Call Log</a></CFIF></td>
</tr>

</cfif>
</table>
<CFIF Not Isdefined("FromReminderEFC")>
<table align="center">
<tr><td  align="center"><strong><A href="/deductions/reminders/reminder_details.cfm?DD_Reminder_ID=#DD_Reminder_ID#&Deduction_ID=#Deduction_ID#&Close=1"><font color="navy">[ dismiss reminder ]</font></A>

&nbsp; &nbsp; 
<a href="/deductions/reminders/create_reminder.cfm?Deduction_ID=#Deduction_ID#&DD_Reminder_ID=#DD_Reminder_ID#"><strong><font color="navy">[ edit reminder ]</font></strong></a>
</strong></td></tr>
</table>
</CFIF>
</div>
<!---Distributor contact info--->
</cfoutput>

<Script>

function eMailThis(Deduction_ID,Email_Address)
{	
	NewWindow('/deductions/Communications/Email_Fax_Print/Reminder_Email_Fax.cfm?Deduction_ID=<CFOUTPUT>#Deduction_ID#</CFOUTPUT>&DD_Reminder_ID=<CFOUTPUT>#DD_Reminder_ID#</CFOUTPUT>&From=Email', 'SendMail', 570, 350, 'Yes', 'No')
	//opener.I2.location="/deductions/Communications/Email_Fax_Print/DD_Attach_Option.cfm?Deduction_ID=" + Deduction_ID + "&Email_Address=" + Email_Address + "&from=Email";
	window.close();
}

function FaxThis(Deduction_ID,Email_Address)
{	
	NewWindow('/deductions/Communications/Email_Fax_Print/Reminder_Email_Fax.cfm?Deduction_ID=<CFOUTPUT>#Deduction_ID#</CFOUTPUT>&DD_Reminder_ID=<CFOUTPUT>#DD_Reminder_ID#</CFOUTPUT>&From=Fax', 'SendMail', 570, 350, 'Yes', 'No')
	window.close();
	
}

</SCRIPT>
</body>
</html>