<CFSET PageTitle="#application.CompanyName#: Yesterday's Traffic">

<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">

<cfquery name="SuccessfulLogins" datasource="#Application.datasource#">
Select IP_Address, User_Code, Count(IP_Address) as CountIP
FROM LoginIP
WHERE DateDiff(D, Date_Time, GetDate()) = 1 AND Status = 1
GROUP BY User_Code, IP_Address
</cfquery>

<cfquery name="FailedLogins" datasource="#Application.datasource#">
Select IP_Address, User_Code, Count(IP_Address) as CountIP
FROM LoginIP
WHERE DateDiff(D, Date_Time, GetDate()) = 1 AND Status = 0
GROUP BY User_Code, IP_Address
</cfquery>

<cfoutput>
<table>
<tr><td colspan="3" align="center"><B>Successful Logins Yesterday</B></td></tr>
<tr><td>User Name:&nbsp; &nbsp; </td><td>IP Address:&nbsp; &nbsp; </td><td>Number of logins for that combination:</td></tr>

<cfloop query="SuccessfulLogins">

<tr><td>#SuccessfulLogins.User_Code#</td><td>#SuccessfulLogins.IP_Address#</td><td align="center">#SuccessfulLogins.CountIP#</td></tr>

</cfloop>
</table>
<p>&nbsp; </p>
<table>
<tr><td colspan="3" align="center"><B>Failed Logins Yesterday</B></td></tr>
<tr><td>User Name:&nbsp; &nbsp; </td><td>IP Address:&nbsp; &nbsp; </td><td>Number of logins for that combination:</td></tr>

<cfloop query="FailedLogins">

<tr><td>#FailedLogins.User_Code#</td><td>#FailedLogins.IP_Address#</td><td align="center">#FailedLogins.CountIP#</td></tr>

</cfloop>
</table>
</cfoutput>
