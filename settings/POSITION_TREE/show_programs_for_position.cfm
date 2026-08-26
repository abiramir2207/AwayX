<cfparam name="URL.Creating_User_position_ID" default="">

<cfquery name="GetProgramsInPosition" datasource="#application.datasource#">
SELECT DISTINCT cm.contract_number
FROM Contract_Main cm
WHERE Creating_User_position_ID = <cfqueryparam value="#URL.Creating_User_position_ID#" cfsqltype="cf_sql_integer">
AND cm.deleted = 0
ORDER BY cm.contract_number
</cfquery>

<cfquery name="GetPositionName" datasource="#application.datasource#">
SELECT Position_Label
FROM User_Positions
WHERE User_positions_ID = <cfqueryparam value="#URL.Creating_User_position_ID#" cfsqltype="cf_sql_integer">
</cfquery>

<!--- Show Programs under a specific position --->
<cfif GetProgramsInPosition.Recordcount GT 0>
<table border="0" cellpadding="2" cellspacing="0">
<tr><td><strong>Programs under <cfoutput>#GetPositionName.Position_Label#</cfoutput></strong></td></tr>
<cfoutput query="GetProgramsInPosition">
	<tr>
		<td>#Contract_Number#</td>
	</tr>
</cfoutput>
</table>
</cfif>
