<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Failed DataBase Jobs Viewer</title>

<!--- <cfparam name="num" default="1"> --->

<cfparam name="m" default="#datepart("m",now())#">
<cfparam name="d" default="#datepart("d",now())#">
<cfparam name="y" default="#datepart("yyyy",now())#">
<cfparam name="ymd" default="#dateFormat(CreateDate(y, m, d),"ddd. mmmm d, yyyy")#">
<cfparam name="mdy" default="#dateFormat(CreateDate(y, m, d),"mmddyyyy")#">
<cfparam name="rd" default="#dateFormat(CreateDate(y, m, d),"yyyymmdd")#">
	
</head>
<cfquery datasource="#application.datasource#" name="qFailedJobs">
	DECLARE @dbname varchar(35)

	SET @dbname = (select TOP 1 TABLE_CATALOG  from INFORMATION_SCHEMA.TABLES)

	SELECT	distinct(name) as Job_name, ISNULL(CAST(IsInbox AS int), 3)  as IsInbox,j.*, jh.*,
		LEFT(RIGHT('000000' + CAST(run_time AS VARCHAR(10)),6),2)+ 
		SUBSTRING(RIGHT('000000' + CAST(run_time AS VARCHAR(10)),6),3,2)+ 
		RIGHT(RIGHT('000000' + CAST(run_time AS VARCHAR(10)),6),2) as run_time1, DIJ.Action_To_Take_On_Error
	FROM	msdb.dbo.sysjobs j
	Full 	outer Join  Data_integration_Jobs DIJ on dij.job_name = j.name
		Join msdb.dbo.sysjobhistory jh on jh.job_id = j.job_id
	WHERE	jh.run_date = #rd#	<!--- <cfqueryparam value="#rd#" cfsqltype="CF_SQL_INTEGER"> --->
	and 	step_id = 0
	and 	run_status = 0
	and 	j.name LIKE '%' + @DBName + '%'
</cfquery>


<body>
<cfset pagetitle = "Failed DataBase Jobs  ::  #ymd#">
<div style="width:99%"><CFINCLUDE TEMPLATE="/settings/settings_title.cfm"></div>

<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<table class="datagrid">
<thead>
	<th class="header">In/Out</th>
	<th class="header">Run Date</th>
	<th class="header">Job</th>
	<th class="header">Last Step</th>
	<th class="header">Outcome</th>
	<th class="header">Last Step Outcome</th>
	<th class="header">Action</th>

</thead>

<tbody>
<cfoutput query="qFailedJobs">
	<cfset num = (qFailedJobs.instance_id - 1)>
		<!---  use run_time1...it is formatted --->
 	<cfif len(run_time1) eq 5>
 		<cfset rtime = CreateTime(left(run_time1,1), mid(run_time1,2,2), right(run_time1,2))>
 	<cfelse>
 		<cfset rtime = CreateTime(left(run_time1,2), mid(run_time1,3,2), right(run_time1,2))>
 	</cfif>
	<cfquery datasource="#application.datasource#" name="qFailedstep">
		SELECT      *
		FROM    msdb.dbo.sysjobhistory
		WHERE	instance_id = <cfqueryparam value="#num#">
	</cfquery> 

	<tr>
		<td><cfif qFailedJobs.isinbox eq 1><span style="color: ##265736;font-weight: bold;">Forge In</span><cfelseif qFailedJobs.isinbox eq 0><span style="color: ##054483; font-weight: bold;">Forge Out</span><cfelse><span style="color: ##FF6600; font-weight: bold;">Forge Maint</span></cfif></td>
		<td>#dateFormat(CreateDate(left(run_date,4), mid(run_date,5,2), right(run_date,2)),"ddd. mmmm d, yyyy")# #TimeFormat(rTime, 'h:mm:ss tt')#</td>
		<td><strong>#replace(job_name,"_"," ","All")#</strong></td>
		<td><span style="color: red; font-weight: bold;">#replace(qFailedstep.step_name,"_"," ","All")#</span></td>
		<td><#replace(message,"_"," ","All")#</td>
		<td>#replace(qFailedstep.message,"_"," ","All")#</td>
		<td><cfif  qFailedJobs.run_status eq 1>#qFailedJobs.Action_To_Take_on_Error#<cfelse>None</cfif></td>

	</tr>
</cfoutput>
</tbody>
</table>


<cfset datatables.version = "1.10.15">
<cfset jQuery.version = '1.12.4'>
<cfinclude template="/common_files/jQuery.cfm">
<cfinclude template="/common_files/dataTables2.cfm">

<script>
	var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? .85 : .85) * windowHeight;
	oTable = $('.datagrid').DataTable({
	"filter": true
	,"bAutoWidth": true
	,"bPaginate": false
	,"bSortClasses": false
	,"sDom":  'ft'
	,"sScrollY": sScrollY
   	, "aaSorting": []
	,"aoColumns": [
		{"bSearchable": false,  "bSortable":false}
		,{"bSearchable": true, 	"bSortable":false}
		,{"bSearchable": true, 	"bSortable":false}
		,{"bSearchable": true, 	"bSortable":false}
		,{"bSearchable": true, 	"bSortable":false}
		,{"bSearchable": true, 	"bSortable":false}
		,{"bSearchable": false, "bSortable":false}
	] 
	})
</script>

</body>
</html>
