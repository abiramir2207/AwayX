<cfquery name="RelevantBBInfo" datasource="#application.datasource#">
SELECT BB_Code, BB_Title, Billback_Status.BB_Status_Description
FROM Billback 
	LEFT JOIN Billback_Status
	ON Billback_Status.Billback_Status_ID = Billback.Billback_Status_ID
WHERE Billback_ID = '#url.Billback_ID#'
</cfquery>
<cfoutput>
<html>
<head>
	<title>Billback Acknowledgements -- #RelevantBBInfo.BB_Code# #RelevantBBInfo.BB_Title#</title>
</head>

</html>



<cfquery name="GetRoutingData" datasource="#application.datasource#">
SELECT Route_Message.*, _Users.Name_First, _Users.Name_Last, _USers.User_Email 
FROM Route_Message
	LEFT JOIN _Users ON Route_Message.Sender_ID = _Users.User_ID
WHERE Document_ID = '#url.Billback_ID#'
AND Document_Type_ID = 1
AND Route_Message.Deleted = 0
ORDER BY Message_Date
</cfquery>



<table cellpadding="2" cellspacing="0" border="0" width="90%" align="center" >

<tr bgcolor="Orange"><td><font size="2" color="navy"><strong>#RelevantBBInfo.BB_Code# </strong></font></td><td> <font size="2" color="navy"><strong>#RelevantBBInfo.BB_Title# </strong></font></td><td><font size="2" color="navy"><strong>(#RelevantBBInfo.BB_Status_Description#)</strong></font></td></tr>

<tr bgcolor="lightsteelblue">
	<td><strong>Date</strong></td>
	<td><strong>Creator</strong></td>
	<td><strong>Message</strong></td>
</tr>

<cfloop query="GetRoutingData">

<tr>
	<Td valign="top">#dateformat(GetRoutingData.Message_Date, 'MM/DD/YYYY')#</TD>
	<td valign="top">#GetRoutingData.Name_First# #GetRoutingData.Name_Last# (#GetRoutingData.User_Email#)</td>
	<td valign="top">#GetRoutingData.Message_Body#</td>
</tr>

	<cfquery name="GetReplies" datasource="#application.datasource#">
	SELECT Route_Recipient.*, _Users.Name_First, _Users.Name_Last, _Users.User_Email FROM Route_Recipient
		LEFT JOIN _Users ON Route_Recipient.Recipient_ID = _Users.User_ID
	WHERE Route_Recipient.Route_Message_ID = #GetRoutingData.Route_Message_ID#
	AND Route_Recipient.Message_Status > 0
	ORDER BY Reply_Date
	</cfquery>
	<cfloop query="GetReplies">
	<tr>
		<Td align="right" valign="top" style="border-top: 1px solid navy;">#dateformat(GetReplies.Reply_Date, 'MM/DD/YYYY')#</TD>
		<td align="right" valign="top" style="border-top: 1px solid navy;">#GetReplies.Name_First# #GetRoutingData.Name_Last# (#GetReplies.User_Email#)</td>
		<td align="right" valign="top" style="border-top: 1px solid navy;">#GetReplies.Reply_Message#</td>
	</tr>
	</cfloop>
	
	<tr><td colspan="3"><hr color="orange"></td></tr>

</cfloop>

</table>

<div align="center"><font color="red"><strong>[</strong></font> <font color="navy"><strong><a href="##" onclick="window.close()">close window</a></strong></font> <font color="red"><strong>]</strong></font></div>

</cfoutput>
