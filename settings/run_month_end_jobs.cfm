<!---
	Copyright (c)2014 Blacksmith Applications, Inc.       
	Filename:		C:\Work\base\AwayX\settings\run_month_end_jobs.cfm
	Created:		8/6/2014
	Developer:	drachala
	Usage:			Execute month end jobs.
--->
<CFSET URL.PageTitle="Administration: Run Month End Jobs">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<cfparam name="form.runjobs" default="0" >
	<table bgcolor="white" cellpadding="3" cellspacing="0">
		<tr>
			<td style="border-color:red;border-style:solid;font-size:13px;font-weight:bold;">
					At the completion of the jobs, an email will sent out to you indicating its success or failure.
			</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
	</table>

	<cfoutput>
		<cfif form.runjobs>
			<cfstoredproc procedure="SP_RUN_MONTH_END_JOBS" datasource="#application.datasource#">	</cfstoredproc>
			<span title="Month end job is running" style="cursor:hand;">#application.util.string.actionLinkFormat("run month end jobs")#</span>
		<cfelse>
			<a onclick="check()" style="cursor:hand;">#application.util.string.actionLinkFormat("run month end jobs")#</a>
		</cfif>
	</cfoutput>

	<form id="checkpermission" action="run_month_end_jobs.cfm" method="post">
		<input type="hidden" name="runjobs" value="0" id="runjobs"/>
	</form>

<script type="text/javascript">
	function check(){
	    if(confirm("Are you sure you want to run the month-end jobs?"))
			{
				document.getElementById('runjobs').value = 1;
				document.getElementById('checkpermission').submit();
		    }
	}
</script>