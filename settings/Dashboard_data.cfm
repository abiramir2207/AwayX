<!----
	Filename:	C:\Work\Code\base\AwayX\settings\Dashboard_Data.cfm
	Created:	4/23/2012
 	Developer:	drachala
	Copyright (c) 2012 Blacksmith Applications, Inc.

	Description:
		USE TO RUN DASHBOARD DATA
	Usage:
		settings / programs / settings
---->

<table>
	<tr>
		<td><img src="/images/loading_red.gif" border="0"></td>
		<td style="color:green;font-size:12px;font-weight:bold;" align="center">Processing..............we will send an email after job is done.</td>
	</tr>
</table>
<cfflush>
<cfquery name="Dashboard_Data" datasource="#application.datasource#" >

 	EXEC DASHBOARD_BUDGET_DATA
	EXEC DASHBOARD_VOLUME_FORECAST_DATA
 	SELECT 1 as Done

</cfquery>

<cfif Dashboard_Data.Done>
<cfoutput>
    <cfmail to="#request.AccessStructure.user_email#"
            from="forgetrade@bigredflame.com"
            subject="Dashboard Data"
            type="text" >
            Dashboard process have completed successfully.
	</cfmail>
</cfoutput>
</cfif>
<script>
	setTimeout("closewindow()",2000);
	function closewindow(){
		self.close();
	}
</script>
