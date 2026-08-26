<!------ Message_Check.cfm ----->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Check the bit of this user																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Connection_Status" datasource="#application.datasource#">
SELECT		TOP 1 XM_Connect_ID, XM_Sender_ID, _USERS.Name_First + ' ' + _USERS.Name_Last as senderName, XM_Connect_Date
FROM		XMConnect, _USERS
WHERE		
			XM_Receiver_ID	=	'#request.AccessStructure.User_ID#'
			AND
			_USERS.USER_ID	=	XM_Sender_ID
			AND
			XM_Connect=1
ORDER BY 	XM_Connect_Date
</CFQUERY>
 <CFIF Get_Connection_Status.recordCount GT 0>
 	<!------ Reload message window ----->
	<SCRIPT language="JavaScript">
		reloadXMWindow();
		function reloadXMWindow()
		{
			var xmWin = window.parent.header_new
			if(xmWin)
			{
				xmWin = xmWin.oIframe;
				if(xmWin)
				{
					xmWin.newMessageReload();
				}
			}
		}		
	</SCRIPT>
 </CFIF>