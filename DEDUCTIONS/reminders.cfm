<HTML>

<HEAD>
<META http-equiv="Content-Language" content="en-us">
<META http-equiv="Content-Type" content="text/html; charset=windows-1252">
<TITLE>Deduction Reminders</TITLE>
</HEAD>

<BODY bgcolor="#FFFFEA">

<STYLE>
	body,td
		{
			font-family:	Arial, Helvetica, sans-serif;
			font-size:		12px;
		}
	li
		{
			font-size:		12px;
		}
</STYLE>

<CFPARAM NAME="URL.ShowAll" DEFAULT="0">

<cfset useLakebaseForDeductionsForUser = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForDeductionsForUser>
	<cftry>
		<cfset DeductionsForUser = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions", {
				"select" = "deduction_id",
				"analyst_user_id" = "eq.#request.AccessStructure.User_ID#",
				"deleted" = "eq.0"
			}),
			"deduction_id"
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForDeductionsForUser = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeductionsForUser>
<cfquery name="DeductionsForUser" datasource="#application.datasource#">
SELECT Deduction_ID FROM Deductions WHERE Analyst_User_ID LIKE '#request.AccessStructure.User_ID#'
AND Deductions.Deleted = 0
</cfquery>
</cfif>

<cfset UserDeductions = listqualify(valuelist(DeductionsForUser.Deduction_ID), chr(39))>
<cfquery name="Reminders" datasource="#application.datasource#">
SELECT *, DateDiff(d, GetDate(), DD_Reminder_Date) AS Difference FROM DD_Reminders
WHERE DD_Reminders.Deleted = 0 
 AND Deduction_ID IN (SELECT Deduction_ID FROM Deductions WHERE Analyst_User_ID LIKE '#request.AccessStructure.User_ID#'
AND Deductions.Deleted = 0 AND DD_Rejected=0)
</cfquery>

<cfquery name="Past_Due" dbtype="query">
SELECT * FROM Reminders
WHERE 	Difference < 0 
		<CFIF URL.ShowAll EQ 0>
			AND DD_Reminder_Status = 0		
		</CFIF>
</cfquery>

<cfquery name="Today" dbtype="query">
SELECT * FROM Reminders
WHERE 	Difference = 0
		<CFIF URL.ShowAll EQ 0>
			AND DD_Reminder_Status = 0		
		</CFIF>
</cfquery>

<cfquery name="Tomorrow" dbtype="query">
SELECT * FROM Reminders
WHERE 	Difference = 1
		<CFIF URL.ShowAll EQ 0>
			AND DD_Reminder_Status = 0		
		</CFIF>
</cfquery>

<cfquery name="Future" dbtype="query">
SELECT * FROM Reminders
WHERE 	Difference > 1
		<CFIF URL.ShowAll EQ 0>
			AND DD_Reminder_Status = 0		
		</CFIF>
</cfquery>




<B>Today</B> 
<HR noshade color="#FFE083" size="1">
	<cfif Today.RecordCount LT 1>
	No reminders for today
	</cfif>
	<cfoutput query="Today">
	<LI><strong><a href="/deductions/reminders/reminder_details.cfm?Deduction_ID=#Deduction_ID#&DD_Reminder_ID=#DD_Reminder_ID#&From=Main"><cfif len(trim(DD_Reminder)) GT 30>#left(DD_Reminder, 27)#...<cfelse>#DD_Reminder#</cfif></A></strong></LI>
	</cfoutput>
<br><Br>
<B>Tomorrow</B> 
<HR noshade color="#FFE083" size="1">
	<cfif Tomorrow.RecordCount LT 1>
	No reminders for tomorrow
	</cfif>
	<cfoutput query="Tomorrow">
	<LI><strong><a href="/deductions/reminders/reminder_details.cfm?Deduction_ID=#Deduction_ID#&DD_Reminder_ID=#DD_Reminder_ID#&From=Main"><cfif len(trim(DD_Reminder)) GT 30>#left(DD_Reminder, 27)#...<cfelse>#DD_Reminder#</cfif></A></strong></LI>
	</cfoutput>
<Br><Br>
<B>Future</B> 
<HR noshade color="#FFE083" size="1">
	<cfif Future.RecordCount LT 1>
	No reminders for future
	</cfif>
	<cfoutput query="Future">
	<LI><strong><a href="/deductions/reminders/reminder_details.cfm?Deduction_ID=#Deduction_ID#&DD_Reminder_ID=#DD_Reminder_ID#&From=Main"><cfif len(trim(DD_Reminder)) GT 30>#left(DD_Reminder, 27)#...<cfelse>#DD_Reminder#</cfif></A></strong></LI>
	</cfoutput>

	
<Br><Br>	
<B>Past due</B>
<HR noshade color="#FFE083" size="1">
	<cfif Past_Due.RecordCount LT 1>
	No past due reminders
	</cfif>
	<cfoutput query="Past_Due">
	<LI><strong><a href="/deductions/reminders/reminder_details.cfm?Deduction_ID=#Deduction_ID#&DD_Reminder_ID=#DD_Reminder_ID#&From=Main"><cfif len(trim(DD_Reminder)) GT 30>#left(DD_Reminder, 27)#...<cfelse>#DD_Reminder#</cfif></A></strong></LI>
	</cfoutput>
	
</BODY>

</HTML>