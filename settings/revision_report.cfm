<!----
	Filename:	C:\Work\Code\base\AwayX\settings\revision_report.cfm
	Created:	2/10/2012
 	Developer:	drachala        
	Copyright (c) 2012 Blacksmith Applications, Inc.       
             
	Description:
		USE TO RUN THE REVISIONS REPORT
	Usage:
		settings / programs / settings
---->

<cfquery name="revision_report" datasource="#application.datasource#" >
		DECLARE @dbName NVARCHAR(50),
           		@jobName NVARCHAR(250) 

      	SET @dbName = (select TOP 1 TABLE_CATALOG  from INFORMATION_SCHEMA.TABLES)
      	SET @jobName = 'BA_' + @dbName + '_Revision_Report_Nightly_Job'

      	IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = @jobName)
      	BEGIN
             EXEC msdb..sp_start_job @job_name = @jobName
             SELECT 1 as Is_Job
      	END
      	ELSE
      	BEGIN
             EXEC SP_Revision_Report_Nightly
             SELECT 0 as Is_Job
      	END
</cfquery>

<cfif revision_report.Is_Job>
<div style="color:green;font-size:12px;" align="center"><b>Job has started, it will take a while to finish this job. This window will close automatically in 2 seconds.<b/></div>	
<cfelse>
<div style="color:green;font-size:12px;" align="center"><b>Revision Report has ran successfully. This window will close automatically in 2 seconds.<b/></div>
</cfif>
<script>
	setTimeout("closewindow()",2000);
	function closewindow(){
		self.close();
	}
</script> 
