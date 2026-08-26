<!------
home_Inbox.cfm
----->


<CFSILENT>
<CFQUERY NAME="New_Message_Count" DATASOURCE="#application.datasource#">
	SELECT	Count(Route_Message.Route_Message_ID) AS New_Message
	FROM	
		Route_Message		
		LEFT JOIN
				Billback
				ON (Route_Message.Document_ID = Billback.Billback_ID)
		INNER JOIN
		Route_Recipient
			ON (
				(Route_Message.Route_Message_ID = Route_Recipient.Route_Message_ID)
				AND
				(Route_Recipient.Message_Status = 0)
				AND
				(Route_Recipient.Deleted = 0)
				AND
				(Route_Recipient.Recipient_ID = '#request.AccessStructure.User_ID#')
				)
	WHERE		
		Route_Message.Deleted = 0
		AND
		(
			Billback.Billback_ID IS NOT NULL
			OR
			Route_Message.Document_Type_ID <> 1
		)
</CFQUERY>
<CFQUERY NAME="Ack_Message_Count" DATASOURCE="#application.datasource#">
SELECT	
	Count(Route_Message.Route_Message_ID) AS Ack_Message	
FROM	
	Route_Message		
	LEFT JOIN
			Billback
			ON (Route_Message.Document_ID = Billback.Billback_ID)
	INNER JOIN
	Route_Recipient
		ON (
			(Route_Message.Route_Message_ID = Route_Recipient.Route_Message_ID)
			AND
			(Route_Recipient.Message_Status = 1)
			AND
			(Route_Recipient.Deleted = 0)
			)
WHERE
	Route_Message.Sender_ID = '#request.AccessStructure.User_ID#'
	AND
	Route_Message.Deleted = 0
	AND
	(
		Billback.Billback_ID IS NOT NULL
		OR
		Route_Message.Document_Type_ID <> 1
	)
</CFQUERY>
<CFSET Ack_Message=0>
<CFIF Ack_Message_Count.recordCount GT 0>
	<CFSET Ack_Message=Ack_Message_Count.Ack_Message>
</CFIF>

<CFSET New_Message=0>
<CFIF New_Message_Count.recordCount GT 0>
	<CFSET New_Message=New_Message_Count.New_Message>
</CFIF>
</CFSILENT>
<CFOUTPUT>


<!---
	D43181 :: Route Summary
	<B><FONT COLOR="Red">[</FONT></B>&nbsp;<a href="\Route\Inbox.cfm" TARGET="_parent"><B>Inbox</B><CFIF New_Message GT 0><IMG SRC="/Images/mail.gif" BORDER="0" TITLE="#New_Message# new messages"> </CFIF>&nbsp;<B>(#New_Message#)</B></a>&nbsp;<B><FONT COLOR="Red">]</FONT></B>
&nbsp;&nbsp;&nbsp;<B><FONT COLOR="Red">[</FONT></B>&nbsp;<a href="\Route\Sent.cfm" TARGET="_parent"><B>Acknowledged</B><CFIF Ack_Message GT 0><IMG SRC="/Images/mail.gif" BORDER="0" TITLE="#Ack_Message# new messages"> </CFIF>&nbsp;<B>(#Ack_Message#)</B></a>&nbsp;<B><FONT COLOR="Red">]</FONT></B>
--->

</CFOUTPUT>
<!-----------
	<CFIF (New_Message+Ack_Message) GT 0> 
		<IMG SRC="/Images/mail.gif" BORDER="0" ALT="<CFIF New_Message GT 0><CFOUTPUT>#New_Message#</CFOUTPUT> New Message(s)</CFIF><CFIF (New_Message GT 0) AND (Ack_Message GT 0)><CFOUTPUT>#chr(13)#</CFOUTPUT></CFIF><CFIF Ack_Message GT 0><CFOUTPUT>#Ack_Message#</CFOUTPUT> Acknowledged Message(s)</CFIF>"><CFIF New_Message GT 0> (<CFOUTPUT>#New_Message#</CFOUTPUT>)</CFIF><CFIF Ack_Message GT 0>&nbsp;<A HREF="/Route/Sent.cfm" TITLE="<CFOUTPUT>#Ack_Message#</CFOUTPUT> Acknowledged Message(s)" TARGET="_parent">(<CFOUTPUT>#Ack_Message#</CFOUTPUT>)</A></CFIF><CFELSE>(0)</CFIF>
		---------->