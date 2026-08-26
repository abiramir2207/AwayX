<cfparam name="Form.XM_Connect_ID" default=0>
<CFIF ISNumeric(Form.XM_Connect_ID)>
	<CFIF Form.XM_Connect_ID GT 0>		
		<CFQUERY NAME="set_Ignore" datasource="#application.datasource#">
			UPDATE	XMConnect
			SET		XM_Connect=0
			WHERE	XM_Connect_ID=#Form.XM_Connect_ID#;
			Insert into	XMessenger
			(
				XM_Sender_ID,
				XM_Receiver_ID,
				XM_Message
			)
			Values
			(
				'#request.AccessStructure.User_ID#',
				'#Form.XM_Sender_ID#',
				'#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last# has acknowledged your request.'
			)			
		</CFQUERY>
		<CFLOCATION ADDTOKEN="No" URL="index.cfm?ID=#Form.XM_Sender_ID#">
	</CFIF>
</CFIF>
