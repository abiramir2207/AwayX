<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Printer Friendly Rebill Notification</TITLE>
</HEAD>

<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>
<CFFLUSH>
<SCRIPT LANGUAGE="JavaScript">
function hide_PleaseWaitMessage()
{
 document.all.PleaseWaitMessage.style.display='none';
}
hide_PleaseWaitMessage();
//document.body.onload=new Function ("hide_PleaseWaitMessage();");

function printPage()
{
 window.print();
}
</SCRIPT>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- This is the printer friendly page																 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<div align="center">
<cfoutput>#Summary_Content#</cfoutput>
</div>
<!-------------------- Add this for Print Help Window ----------------------------------------->
 
<!---  <CFINCLUDE template="/Common_Files/Printer_Friendly_Script.cfm"> 
 --->
<style type="text/css" media="print"> 
.DONT_PRINT 
{ 
display:none; 
} 
</style>

<cfset useLakebaseForUpdateDeduction = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForUpdateDeduction>
	<cftry>
		<cfset application.oLakebase.updateRows("deductions",
			{ "deduction_id" = "eq.#Deduction_ID#" },
			{
				"dd_date_closed" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss"),
				"dd_closed_by" = request.AccessStructure.User_ID,
				"dd_resolution_code" = ReasonCode,
				"dd_status" = 4,
				"dd_closure_method" = 2
			}
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForUpdateDeduction = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateDeduction>
	<cfquery name="UpdateDeduction" datasource="#application.datasource#">
	UPDATE Deductions
	SET DD_Date_Closed = getdate(),
		DD_Closed_By = '#request.AccessStructure.User_ID#',
		DD_Resolution_Code = '#ReasonCode#',
		DD_Status = 4,
		DD_Closure_Method = 2
	WHERE Deduction_ID = '#Deduction_ID#'
	</cfquery>
</cfif>

<!---Close any reminders associated with this--->
<cfset useLakebaseForCloseReminders = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_reminders")>
<cfif useLakebaseForCloseReminders>
	<cftry>
		<cfset application.oLakebase.updateRows("dd_reminders",
			{ "deduction_id" = "eq.#Deduction_ID#" },
			{ "dd_reminder_status" = 1 }
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForCloseReminders = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCloseReminders>
	<cfquery name="CloseReminders" datasource="#application.datasource#">
	UPDATE DD_Reminders
	SET DD_Reminder_Status = 1
	WHERE Deduction_ID = '#Deduction_ID#'
	</cfquery>
</cfif>

<cfoutput><div align="center" style="DONT_PRINT">
<p></p>
<B><FONT SIZE="2" COLOR="Red">[</FONT> <A HREF="##" onClick="javaScript: printPage();">print document</A> <FONT SIZE="2" COLOR="Red">]</FONT></B>  <B><FONT SIZE="2" COLOR="Red">[</FONT> <A HREF="/deductions/deduction.cfm?Deduction_ID=#Deduction_ID#" target="_parent">return to dedutions home</A> <FONT SIZE="2" COLOR="Red">]</FONT></B>
</div></cfoutput>

</BODY>
</HTML>

