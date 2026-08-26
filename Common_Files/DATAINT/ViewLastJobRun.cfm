<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
<!--- <cfparam name="num" default="1"> --->
<cfparam name="ymd" default="#dateFormat(now(),"ddd. mmmm d, yyyy")#">
	<title>Last Data Integration Job Run  ::  <cfoutput>#ymd# #TimeFormat(now(), 'h:mm:ss tt')#</cfoutput></title>
	<STYLE TYPE="text/css">		<!--
		.datatitle
		{
			color: Navy;
			font-size: 12px;
			font-weight: bold;
			border-bottom: Solid 1px red;
			border-top: Solid 2px red;

		}
		.errorText
		{
			color: Navy;
			font-size: 12px;
		}

		.datatext
		{
			color: Black;
			font-size: 12px;
			text-align : center;
		}
		.datatextred
		{
			color: red;
			font-size: 12px;
			text-align : center;
			font-style : italic;
		}
		.toptext
		{
			color: Navy;
			font-size: 12px;
			text-align : center;
		}
			A, A:LINK, A:VISITED
		{
			color : Blue;
			text-decoration : none;
		}

			A:FOCUS,A:HOVER
		{
			color : Red;
			- text-decoration : underline; -
		}
		.xltext {
			color: Navy;
			font-size: 12px;
			font-weight: bold;
		}
		-->
</STYLE>
<script> 
function sync() 
{ 
var lft = document.all("dvData").scrollLeft 
document.all("dvheader").style.width=1024+lft 
document.all("dvheader").style.left= -lft 
} 
</script>
	
</head>

<cfquery datasource="#application.datasource#" name="qAllJobs">
		SELECT      distinct dij.job_name, isnull(isInbox,3) as isInbox, dij.Action_To_Take_On_Error
		FROM         Data_integration_Jobs DIJ
			Join msdb.dbo.sysjobs j on dij.job_name = j.name
			Join msdb.dbo.sysjobhistory jh on jh.job_id = j.job_id
</cfquery>

<cfquery datasource="#application.datasource#" name="qNoHistJobs">
		SELECT      distinct dij.job_name, isInbox
		FROM         Data_integration_Jobs DIJ
		where job_name not in(SELECT      distinct dij.job_name
		FROM         Data_integration_Jobs DIJ
			Join msdb.dbo.sysjobs j on dij.job_name = j.name
			Join msdb.dbo.sysjobhistory jh on jh.job_id = j.job_id)
</cfquery>


	<cfset dvHeaderHt = 50>
	<cfset dvTotHt = 630>
<body onLoad="window.focus()">
<div id="dvheader" style="position:absolute; left:0; top:0; height:<cfoutput>#dvHeaderHt#</cfoutput>; width:100%; overflow:hidden">
<table width="100%" cellpadding="2" cellspacing="0" id="tblstats">
<tr>
	<td width="45%"><span class="toptext">Last Data Integration Job Run  ::  <cfoutput>#ymd# #TimeFormat(now(), 'h:mm:ss tt')#</cfoutput></span></td>
	<td align="left"><FONT COLOR="#FF0000"><B>[ </B></FONT>
				<a href="javascript:(void);" onClick="javascript:window.open('ViewLastJobRun.cfm','ViewJobs','toolbar=no,width=1024,height=660,location=no,menubar=yes,resizable=no,scrollbars=no');return false"><strong>Refresh View</strong></a>
		<FONT COLOR="#FF0000"><B> ]</B></FONT></td> 
</tr>
</table>

<cfset totwidth = 950> <!--- 1000 max --->
<table border="0" cellpadding="0" cellspacing="0"  id="tblheader" width="<cfoutput>#totwidth#</cfoutput>">
	<tr class="header">
		<th align="center" class="datatitle" width="50">In/Out</th>
		<th align="center" class="datatitle" width="150">Last Run</th>
		<th align="center" class="datatitle" width="225">Job</th>
		<th align="center" class="datatitle" width="150">Last Step</th>
		<th align="center" class="datatitle" width="250">Outcome</th>
		<th align="center" class="datatitle" width="125">Action</th>
		<!--- <th align="center" class="datatitle" width="250">Last Step Outcome</th> --->
	</tr>
</table>
</div>


<div id="dvData" style="position:absolute; left:0; top:<cfoutput>#dvHeaderHt#</cfoutput>;height:<cfoutput>#dvTotHt#</cfoutput>; width:1024;overflow:auto" onscroll="sync()">

<table border="0" cellpadding="15" cellspacing="0" name="tblData" id="tblData" width="<cfoutput>#totwidth#</cfoutput>">
<cfset i = 1>
<cfloop query="qAllJobs">
	<cfquery datasource="#application.datasource#" name="qRunningJob">
			SELECT      max(instance_id) as instance_id
			FROM   msdb.dbo.sysjobhistory sh
			Join msdb.dbo.sysjobs j on sh.job_id = j.job_id
			where name = '#qAllJobs.job_name#'
	</cfquery>
	<cfset inst_id = "#qRunningJob.instance_id#">
	<cfquery datasource="#application.datasource#" name="qJobDetail">
			SELECT     *
			FROM   msdb.dbo.sysjobhistory sh
			Join msdb.dbo.sysjobs j on sh.job_id = j.job_id
			where instance_id  = #inst_id#
	</cfquery>
	<cfset num = (qJobDetail.instance_id - 1)>
	<cfquery datasource="#application.datasource#" name="qFailedstep">
		SELECT      step_name
		FROM    msdb.dbo.sysjobhistory
		WHERE	instance_id = <cfqueryparam value="#num#">
	</cfquery> 
	<cfset nextstep = qJobDetail.step_id + 1>
	<cfquery datasource="#application.datasource#" name="qRunStep">
		SELECT      j.step_name
		FROM   msdb.dbo.sysjobsteps j
			Join msdb.dbo.sysjobhistory sh on sh.job_id = j.job_id
		WHERE	instance_id = <cfqueryparam value="#inst_id#">
		and j.step_id = #nextstep#
	</cfquery>
	<cfset isinbox = qAllJobs.isinbox>
	<cfoutput query="qJobDetail">
			
			<!--- <cfif qJobDetail.run_date eq ""><cfset run_date = now()></cfif> --->
			 <cfif len(run_time) eq 5>
			 	<cfset rtime = CreateTime(left(run_time,1), mid(run_time,2,2), right(run_time,2))>
			 <cfelseif len(run_time) eq 6>
			 	<cfset rtime = CreateTime(left(run_time,2), mid(run_time,3,2), right(run_time,2))>
			<cfelseif len(run_time) eq 4>
			 	<cfset rtime = CreateTime(left("00",2), left(run_time,2), right(run_time,2))>
			<cfelse>
				<cfset rtime = timeformat(now()) />
			 </cfif>
			 <cfset rdate = CreateDate(left(run_date,4), mid(run_date,5,2), right(run_date,2))>
			  <cfset rdatetime = "#dateformat(rdate)# #timeformat(rtime)#">
			 <cfif datediff("h",rdatetime,now()) gt 25><cfset dclass = "datatextred"><cfelse><cfset dclass = "datatext"></cfif>
			 
				<tr bgcolor="###Iif(((i MOD 2) is 0),de('FFFFFF'),de('EAFFEA'))#">
					<td align="center" class="datatext" width="50"><cfif isinbox eq 1><span style="color: ##265736;font-weight: bold;">Forge In</span><cfelseif isinbox eq 0><span style="color: ##054483; font-weight: bold;">Forge Out</span><cfelse><span style="color: ##FF6600; font-weight: bold;">Forge Maint</span></cfif></td>
					<td align="center" class="#dclass#" width="150">#dateFormat(rdate,"ddd. mmmm d, yyyy")#<br>#TimeFormat(rTime, 'h:mm:ss tt')#</td>
					<td align="center" class="datatext" width="225">#qJobDetail.name#</td>
					<td align="center" class="datatext" width="150"><cfif qJobDetail.step_id eq "0" and qJobDetail.run_status eq "1"><span style="color: Green; font-weight: bold;">Successful<br>Completion</span><cfelseif qJobDetail.step_id gt 0><span style="color: ##FFA500; font-weight: bold;">Still Running<br>#qRunStep.step_name#</span><cfelseif qJobDetail.step_id eq "0" and qJobDetail.run_status eq "0"><span style="color: red; font-weight: bold;">Job Failed<br>#qFailedstep.step_name#</span></cfif></td>
					<td align="center" class="datatext" width="250">#qJobDetail.message#</td>
					<td align="center" class="datatext" width="125"><cfif qJobDetail.run_status eq 0>#qAllJobs.Action_To_Take_On_Error#<cfelse>None</cfif></td>
					<!--- <td align="center" class="datatext" width="250">#qFailedstep.message#</td> --->
				</tr>
				<!--- <cfset run_date = ""> --->
	</cfoutput>
	<cfset i = i +1>
</cfloop>
<tr>
<cfoutput><td width="35%" colspan="5" width="#totwidth#" class="datatitle">Jobs with No History Available</td></cfoutput>
</tr>
<cfif qNoHistJobs.recordcount gt 0>
<cfloop query="qNoHistJobs">
<tr><td style="color: Black; font-size: 12px;" colspan="5" align="left"><cfoutput>#qNoHistJobs.job_name#</cfoutput></td></tr>

</cfloop>
</cfif>
<tr><td colspan="5"><br></td></tr>
</table>


</div>

</body>
</html>
