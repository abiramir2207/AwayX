<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>xxxxxxxxxxxxxxxxxxxxxxxxx</TITLE>
</HEAD>
<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BLOCKQUOTE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Save message to the DB --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<CFIF IsDefined("Form.CONNECTUSER.X") AND Form.XM_Receiver_ID NEQ 0>	 
	<!----- <CFQUERY NAME="set_Ignore" datasource="#application.datasource#">
			DECLARE @SameUsersID Int
			SELECT @SameUsersID	= Null
			SELECT	@SameUsersID	= XM_Connect_ID
			FROM	XMConnect
			WHERE	
					XM_Sender_ID	=	'#request.AccessStructure.User_ID#'
					AND
					XM_Receiver_ID	=	'#Form.XM_Receiver_ID#'
			IF @SameUsersID IS Null
			   BEGIN
			   		INSERT INTO	XMConnect
					(XM_Sender_ID,XM_Receiver_ID,XM_Connect)
					VALUES
					('#request.AccessStructure.User_ID#', '#Form.XM_Receiver_ID#', 1)
			   END
			ELSE
			   BEGIN
					UPDATE XMConnect
					SET 
						XM_Connect	=	1
					WHERE	XM_Connect_ID = @SameUsersID					
			   END
	</CFQUERY>------->
		<CFQUERY NAME="set_Ignore" datasource="#application.datasource#">
			DECLARE @SameUsersID Int
			SELECT @SameUsersID	= Null
			SELECT	@SameUsersID	= XM_Connect_ID
			FROM	XMConnect
			WHERE	
					XM_Sender_ID	=	'#request.AccessStructure.User_ID#'
					AND
					XM_Receiver_ID	=	'#Form.XM_Receiver_ID#'					
			IF @SameUsersID IS Null
			   BEGIN
			   		INSERT INTO	XMConnect
					(XM_Sender_ID,XM_Receiver_ID,XM_Connect,XM_LastMessage_ID, XM_Connect_Date)
					SELECT 	'#request.AccessStructure.User_ID#', '#Form.XM_Receiver_ID#', 1, MAX(XM_ID) , GetDate()
					FROM 	XMessenger
					WHERE	
						(
						XM_Sender_ID 	= '#request.AccessStructure.User_ID#'
						AND
						XM_Receiver_ID	= '#Form.XM_Receiver_ID#'
						)
						OR
						(
						XM_Receiver_ID 	= '#request.AccessStructure.User_ID#'
						AND
						XM_Sender_ID	= '#Form.XM_Receiver_ID#'
						)
					
			   END
			ELSE
			   BEGIN
					UPDATE XMConnect
					SET 
						XM_Connect			=	1,
						XM_Connect_Date		= 	GetDate(),
						XM_LastMessage_ID	=
							(SELECT 	MAX(XM_ID) 
							FROM 	XMessenger
							WHERE	
								(
								XM_Sender_ID 	= '#request.AccessStructure.User_ID#'
								AND
								XM_Receiver_ID	= '#Form.XM_Receiver_ID#'
								)
								OR
								(
								XM_Receiver_ID 	= '#request.AccessStructure.User_ID#'
								AND
								XM_Sender_ID	= '#Form.XM_Receiver_ID#'
								))
					WHERE	XM_Connect_ID = @SameUsersID					
			   END
	</CFQUERY>
</CFIF>



<CFIF (trim(XM_Message2) EQ '') OR (Form.XM_Receiver_ID EQ 0)>
	<CFLOCATION URL="iframe.cfm?ID=#Form.XM_Receiver_ID#" ADDTOKEN="No">
</CFIF>


<CFQUERY NAME="Save_Message" datasource="#application.datasource#">
	Insert into	XMessenger
			(
				XM_Sender_ID,
				XM_Receiver_ID,
				XM_Message
			)
	Values
			(
				'#request.AccessStructure.User_ID#',
				'#Form.XM_Receiver_ID#',
				'#Form.XM_Message2#'
			)
</CFQUERY>


<CFLOCATION URL="iframe.cfm?ID=#Form.XM_Receiver_ID#" ADDTOKEN="No">

</BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>



