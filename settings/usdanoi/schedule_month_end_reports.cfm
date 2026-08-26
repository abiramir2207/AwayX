<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<script>
function schedulejob()
{
	var error = 0
	if(document.all.monthend_report_job_name.value.length == 0)
	{
		alert("Please enter a Job Title");
		error = 1;
	}
	if(document.all.Start_date.value.length == 0)
	{
		alert("Please enter Invoice Start date");
		error = 1;
	}
	
	if(document.all.End_date.value.length == 0)
	{
		alert("Please enter Invoice End date");
		error = 1;
	}
	
	if(document.all.Schedule_Date.value.length == 0)
	{
		alert("Please enter Schedule date");
		error = 1;
	}
	if (error == 0)
	{
		document.all.savejob.value = 1;
		SearchForm.submit();
	}
	else
	{
	return false;
	}
}

function CancelJob(jobid)
{
	if(confirm("Are you sure you want to delete this job"))
	{
		document.DeleteForm.job_id.value = jobid;
		DeleteForm.submit();
	}
}
</script>

<cfparam name="form.savejob" default="0">
<cfparam name="form.job_id" default="0">
<cfparam name="form.deletejob" default="0">
<cfset ReportManager = CreateObject("component", "components.settings.NOI_Month_End_Reports.report_manager")>
<cfif form.savejob EQ 1>
		<cfset checkifjobschedule = ReportManager.checkifjobschedule(form)>
		<cfif checkifjobschedule.recordcount EQ 0>
		<cfset ReportManager.saveScheduledJob(form)>
		<cfelse>
		<script>
		alert("A job is already scheduled for <cfoutput>#form.Schedule_Date#</cfoutput>, Please select a different schedule date");
		</script>
		</cfif>
		<cfset form.savejob = 0>
	
</cfif>
<cfif form.deletejob EQ 1>
<cfset ReportManager.deleteScheduledJob(form.job_id)>
</cfif>
<table>
<FORM ACTION="/settings/usdanoi/schedule_month_end_reports.cfm" METHOD="post" NAME="SearchForm" ID="SearchForm" style="display:inline">
<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Schedule Month End Reports</LEGEND><br>
<TR>			
		<td><span ID="searchItemLabel"><B>Job Title</B></span><BR> 
			<input type="text" name="monthend_report_job_name" value=""></td>
			<TD>
			<span ID="searchItemLabel"><B>Invoice Start Date</B></span><BR>
				<CFOUTPUT>
				<TABLE CELLPADDING="0" CELLSPACING="0">
				<TR>
				<TD>
				<CFPARAM NAME="FORM.Start_date" DEFAULT="#Now()#">
				<SPAN ID="SP_Start_date">
				<CF_EASYDATE FORMNAME="SearchForm" FIELDNAME="Start_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.Start_date#">
				</SPAN>
				</TD>
			</TR></TABLE>
				</CFOUTPUT>
			</TD>
			<TD>
			<span ID="searchItemLabel"><B>Invoice End Date</B></span><BR>
			<CFOUTPUT>
			<TABLE CELLPADDING="0" CELLSPACING="0">
				<TR>
				<TD>
				<CFPARAM NAME="FORM.End_date" DEFAULT="#Now()#">
				<SPAN ID="SP_End_date">
				<CF_EASYDATE FORMNAME="SearchForm" FIELDNAME="End_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.End_date#">
				</SPAN>
				</TD>
				</TR></TABLE>
			</CFOUTPUT>			
			</TD>
			<td><CFPARAM NAME="FORM.Schedule_Date" DEFAULT="#Now()#">
			<span ID="searchItemLabel"><B>Job Schedule Date</B></span><BR><CF_EASYDATE FORMNAME="SearchForm" FIELDNAME="Schedule_Date" FORMAT="mm/dd/yyyy" DEFAULT="#form.Schedule_Date#"></td>
<tr>
			<td style="font-size:12px;font-weight:bold"><CF_smallLink 
		title = "schedule job" 
		url = "##"
		parameters = "onClick=""javascript: return schedulejob();"""
	></td>
</tr>
</table>
<INPUT type="Hidden" name="savejob" value="0">
</form>
<br><br>
<table width="90%" cellpadding="2" cellspacing="0" border="0" class="maintable">
<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Scheduled Reports</LEGEND><br>
<tr>
	<td bgcolor="FFE083"><b>Job Name</b></td>
	<td bgcolor="FFE083"><b>Invoice Start Date</b></td>
	<td bgcolor="FFE083"><b>Invoice End Date</b></td>
	<td bgcolor="FFE083"><b>Scheduled Date</b></td>
	<td bgcolor="FFE083"><b>Created Date</b></td>
	<td bgcolor="FFE083"><b>Cancel Job</b></td>
	<td colspan="100%" bgcolor="FFE083">&nbsp;</td>
</tr>
<cfset getscheduledjobs =  ReportManager.getscheduledjobs()>
<cfif getscheduledjobs.recordcount GT 0>
<cfoutput query="getscheduledjobs">
<tr BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
	<td>#job_name#</td>
	<td>#dateformat(invoice_start_date,"mm/dd/yyyy")#</td>
	<td>#dateformat(invoice_end_date,"mm/dd/yyyy")#</td>
	<td>#dateformat(Job_scheduled_Date,"mm/dd/yyyy")#</td>
	<td>#dateformat(created_date,"mm/dd/yyyy")#</td>
	<td><A STYLE="cursor:pointer;"
ONCLICK="CancelJob('#getscheduledjobs.NOI_Month_End_Reports_Schedule_id#')">Cancel</A></td>
	<td colspan="100%">&nbsp;</td>
</tr>
</cfoutput>
<cfelse>
<tr><td colspan="100%">No reports scheduled.</td></tr>
</cfif>
</table>
<!--- Form with the data needed to delete the contract --->
<cfoutput>
<FORM ACTION="/settings/usdanoi/schedule_month_end_reports.cfm" METHOD="post" NAME="DeleteForm" ID="DeleteForm">
	<INPUT TYPE="hidden" NAME="job_id" VALUE="" >
	<INPUT TYPE="hidden" NAME="deletejob" VALUE="1" >
</FORM>
</cfoutput>
</body>
</html>
