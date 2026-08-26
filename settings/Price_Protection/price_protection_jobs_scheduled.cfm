<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<cfparam name="type" default="0">

<cfif isDefined("url.type")>
	<cfset type = url.type >
<cfelse>
	<cfset type = form.type >
</cfif>

<script>
function ViewJobDetails(jobid)
{
	NewWindow('jobdetails.cfm?JOBID='+jobid+'&type='+<cfoutput>#type#</cfoutput>,'ViewJobDetails','800','600','Yes', 'Yes');
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
<cfset priceprotectionManager = CreateObject("component", "components.settings.price_protection.price_protection_manager")>

<cfparam name="url.type" default="1">
<cfparam name="form.deletejob" default="0">
<cfif form.deletejob EQ 1>
	<cfset priceprotectionManager.deletejob(form.job_id)>
</cfif>
<cfif url.type EQ 1>
	<cfset pageName = "jobsscheduled">
	<cfset displayvalue ="scheduled">
<cfelseif url.type EQ 2>
	<cfset pageName = "jobssuccessful">
	<cfset displayvalue ="successful">
<cfelseif url.type EQ 3>
	<cfset pageName = "jobsfailed">
	<cfset displayvalue ="failed">
</cfif> 

<cfinclude template="header.cfm">



<cfset getjobs = priceprotectionManager.getjobsscheduled(type)>
<table width="90%" cellpadding="2" cellspacing="0" border="0" class="maintable">
<tr>
	<td bgcolor="orange"><b>Job Name</b></td>
	<td bgcolor="orange"><b>Price Protection Rate</b></td>
	<td bgcolor="orange"><b>UOM</b></td>
	<td bgcolor="orange"><b>Created Date</b></td>
	<cfif url.type EQ 1>
	<td bgcolor="orange"><b>Cancel Job</b></td></cfif>
	<td colspan="100%" bgcolor="orange">&nbsp;</td>
</tr>
<cfif getjobs.recordcount GT 0>
<cfoutput query="getjobs">
<tr BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
	<td><A STYLE="cursor:pointer;"
ONCLICK="ViewJobDetails('#getjobs.Price_Protection_Schedule_id#');">#job_name#</A></td>
	<td>$#trim(numberformat(Price_Protection_Rate, '_-___.____'))#</td>
	<td><cfif Price_Protection_UOM EQ 1>CS<cfelse>LB</cfif></td>
	<td>#dateformat(created_date,"mm/dd/yyyy")#</td>
	<cfif url.type EQ 1>
	<td><A STYLE="cursor:pointer;"
ONCLICK="CancelJob('#getjobs.Price_Protection_Schedule_id#')">Cancel</A></td></cfif>
	<td colspan="100%">&nbsp;</td>
</tr>
</cfoutput>
<cfelse>
<tr><td colspan="100%">No jobs <cfoutput> #displayvalue#</cfoutput></td></tr>
</cfif>
</table>

<!--- Form with the data needed to delete the contract --->
<cfoutput>
<FORM ACTION="price_protection_jobs_scheduled.cfm" METHOD="post" NAME="DeleteForm" ID="DeleteForm">
	<INPUT TYPE="hidden" NAME="job_id" VALUE="" >
	<INPUT TYPE="hidden" NAME="deletejob" VALUE="1" >
	<input type="hidden" name="type" value="#url.type#">
</FORM>
</cfoutput>
</body>
</html>
