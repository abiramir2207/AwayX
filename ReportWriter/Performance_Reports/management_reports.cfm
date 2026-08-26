<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Reports</title>
</head>

<BODY BACKGROUND="" BGCOLOR="WhiteSmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" ONLOAD="" ONBEFOREUNLOAD="">
<CFSET PageTitle="CONTRACT MANAGEMENT PERFORMANCE METRICS">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<cfset useLakebaseForGet_Reports = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("management_report_details")>
<cfif useLakebaseForGet_Reports>
	<cftry>
		<cfset Get_Reports = application.oLakebase.toQuery(
			application.oLakebase.selectRows("management_report_details", {
				"deleted" = "eq.0",
				"select" = "report_id,report_name,report_path"
			}), "report_id,report_name,report_path"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Reports = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Reports>
<CFQUERY NAME="Get_Reports" DATASOURCE="#application.datasource#">
select report_id,report_name,Report_Path
from management_report_details
where deleted = 0
</CFQUERY>
</cfif>
<CFQUERY NAME="GetLastupdatedby" DATASOURCE="#application.datasource#" maxrows="1">
Select		management_report_details.Last_Changed_Date,
					management_report_details.Updated_User_id,
					_Users.Name_First,
					_Users.Name_Last
		From		management_report_details,
					_Users
		Where		management_report_details.Updated_User_id	=	_Users.User_ID
		order by management_report_details.Last_Changed_Date desc
</CFQUERY>
<CFIF GetLastupdatedby.RecordCount GT 0>
<CFOUTPUT>
<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
<TR>
<TD>
	<FONT SIZE="2"><B>The settings were last updated on <CFOUTPUT>#dateformat(GetLastupdatedby.Last_Changed_Date, 'm/d/yyy')# #timeformat(GetLastupdatedby.Last_Changed_Date, 'h:mm:ss TT')# by #GetLastupdatedby.name_first# #GetLastupdatedby.name_last#</CFOUTPUT></B></FONT>	</TD>
</TD>
</TR>
</TABLE>
</CFOUTPUT>
<br><br>
</CFIF>

<table cellpadding="2" cellspacing="4" border="0" width="500">
<cfoutput query="Get_Reports">
<tr>
<td align="right"><b>#Get_Reports.currentRow#.</b></td>
<td align="left">
	<A href="#Get_Reports.Report_Path#"><b>#Get_Reports.Report_Name#</b></A>
</td>
<td><B><FONT COLOR="Red">[ </FONT><A HREF="javascript: void(0);" onClick="javaScript: showScheduleWindow('#Get_Reports.report_id#','#Get_Reports.Report_Name#');">Click here to schedule</A><FONT COLOR="Red"> ]</FONT></B></td>
</tr>
</cfoutput>
</table>

<script>
function showScheduleWindow(report_id,report_name) {
NewWindow('/reportwriter/performance_reports/schedule_management_report.cfm?report_id='+report_id, 'report_name', 800, 600, "yes", "yes")
		}
</script>

</body>
</html>
