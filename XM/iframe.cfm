<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>xxxxxxxxxxxxxxxxxxxxxxxxx</TITLE>
	<META HTTP-EQUIV="Refresh" CONTENT="5">

		<STYLE>
			body
				{
					scrollbar-face-color: #96A096;
					scrollbar-shadow-color: #96A096;
					scrollbar-highlight-color: #96A096;
					scrollbar-3dlight-color: #9AB6C4;
					scrollbar-darkshadow-color: #20253A;
					scrollbar-track-color: #738278;
					scrollbar-arrow-color: #000000;
		
				}
		</STYLE>

</HEAD>
<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->




<CFPARAM NAME="URL.ID" DEFAULT="0">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the last 20 messages exchanged between the current user and the selected user				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Messages" datasource="#application.datasource#" MAXROWS=20>
Select			XM_Date, DateDiff("d", XM_Date, GetDate()) AS daysOld,
				XMessenger.XM_Message,
				_Users.Name_First,
				_Users.Name_Last,
				(SELECT 
				CASE 
					WHEN MAX(XM_LastMessage_ID) >= XM_ID THEN
						0
					ELSE
						1
				END AS someval
				FROM 	XMConnect
				WHERE	
					(
					XM_Sender_ID 	= '#request.AccessStructure.User_ID#'
					AND
					XM_Receiver_ID	= '#URL.ID#'
					)
					OR
					(
					XM_Receiver_ID 	= '#request.AccessStructure.User_ID#'
					AND
					XM_Sender_ID	= '#URL.ID#'
					)
				) AS isNew

	From		XMessenger,
				_Users

	Where		(
					(
						XM_Sender_ID	=	'#request.AccessStructure.User_ID#'
						AND
						XM_Receiver_ID	=	'#URL.ID#'
					)
					OR
					(
						XM_Sender_ID	=	'#URL.ID#'
						AND
						XM_Receiver_ID	=	'#request.AccessStructure.User_ID#'
					)
				)

				AND

				XMessenger.XM_Sender_ID = _Users.User_ID

	Order by	XM_Date desc
</CFQUERY>

<!--- 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Messages displayed via a text area ...														 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CENTER>
&nbsp;
<TEXTAREA COLS="" ROWS=""  NAME="XM_History" STYLE="width: 390px; height: 220px; background: #E1FFE1; color: #0000ff; border: solid 0" READONLY>
<CFOUTPUT QUERY="Get_Messages">&curren;&curren;&curren; #Name_First# #Name_Last# &curren;&curren;&curren; &##10;#XM_Message#&##10;&##10;</CFOUTPUT>
</TEXTAREA>		
</CENTER>
 --->

 
<BR> 
<TABLE CELLPADDING="0" CELLSPACING="0" WIDTH="95%" ALIGN="center">
<CFOUTPUT QUERY="Get_Messages" GROUP="daysOld">
<CFOUTPUT GROUP="isNew">
<TR VALIGN="top">
	<CFIF NOT isNew>
	<TD COLSPAN="3">
	<FONT COLOR="Gray"><b>#DateFormat(XM_Date,"mm/dd/yyyy")#<!------ #TimeFormat(XM_Date,"hh:mm:ss tt")#-----></b></FONT>
	</TD>
	</CFIF>
</TR>
<CFOUTPUT>
<TR VALIGN="top">
	<TD NOWRAP><FONT <CFIF isNew>COLOR="Red"<CFELSE>COLOR="Silver"</CFIF>><B>#left(Name_First,1)#.#Name_Last#:</B></FONT></TD>
	<TD>&nbsp;</TD>
	<TD WIDTH="100%"><FONT <CFIF isNew>COLOR="Navy"<CFELSE>COLOR="Silver"</CFIF>>#Replace(XM_Message,"#chr(10)##chr(13)#","<br>","All")#</FONT></TD>
</TR>
</CFOUTPUT>
</CFOUTPUT>
</CFOUTPUT>
</TABLE>

 


<!--- 
 
<TABLE CELLPADDING="0" CELLSPACING="0" WIDTH="99%" ALIGN="center">
<CFOUTPUT QUERY="Get_Messages">
<TR VALIGN="top">
	<TD NOWRAP><FONT <CFIF isNew>COLOR="Red"<CFELSE>COLOR="Silver"</CFIF>><B>#left(Name_First,1)#. #Name_Last#:</B></FONT></TD>
	<TD>&nbsp;</TD>
	<TD WIDTH="100%"><FONT <CFIF isNew>COLOR="Navy"<CFELSE>COLOR="Silver"</CFIF>>#Replace(XM_Message,"#chr(10)##chr(13)#","<br>","All")#</FONT></TD>
</TR>
</CFOUTPUT>
</TABLE>

 ---> 
 
 
 
 
 
<CFQUERY NAME="GetNewUsers" datasource="#application.datasource#">
	SELECT	
			DateDiff(n, Session_Date_Time_Stamp, GetDate()) AS idleMinutes,
			st.Session_User_ID, u.Name_First + ' ' + u.Name_Last as newUser
	FROM	Session_Tracker st,
			_Users u
	WHERE	(st.Session_ID 		<> 	'NULL')
			AND
			(st.Session_User_ID	=	u.User_ID	)
			AND
			(st.Session_User_ID	<>	'#request.AccessStructure.User_ID#'	)			
			AND
			DateDiff(n, Session_Date_Time_Stamp, GetDate()) < 
				(Select  TOP 1 Session_Expiration_Length * 24 * 60 	From	General_Settings)
	Order by	u.Name_First	
</CFQUERY>
 
<SCRIPT LANGUAGE="JavaScript">
	var usersLen = 0;
	var userIDList = new Array();
	var userNameList = new Array();
	var listUserIDList = '<CFOUTPUT>#ValueList(GetNewUsers.Session_User_ID)#</CFOUTPUT>';
<CFOUTPUT QUERY="GetNewUsers">
	userIDList[usersLen] = '#GetNewUsers.Session_User_ID#';
	<cfif GetNewUsers.idleMinutes GT 1440> 
		<CFSET extraDesc="      (Idle for #NumberFormat(Evaluate(GetNewUsers.idleMinutes/1440),"_____")# Days)">
	<cfelseif GetNewUsers.idleMinutes GT 60> 
		<CFSET extraDesc="      (Idle for #NumberFormat(Evaluate(GetNewUsers.idleMinutes/60),"_____")# Hours)">
	<cfelseif GetNewUsers.idleMinutes GT 3> 
		<CFSET extraDesc="      (Idle for #NumberFormat(GetNewUsers.idleMinutes,"_____")# Minutes)">
	<cfelse>
		<CFSET extraDesc="">
	</cfif>
	userNameList[usersLen] = '#GetNewUsers.newUser##extraDesc#';
	usersLen = usersLen + 1;
</CFOUTPUT>

	function addUsersList()
	{
		var oOption, optLen;
		var oAllLoginUsers	= window.parent.document.all.allLoginUsers;
		var oXM_Receiver_ID	= window.parent.document.all.XM_Receiver_ID;
		for(var i=0;i<userIDList.length;i++)
		{
			if(oAllLoginUsers.value.indexOf(userIDList[i]) < 0)
			{
				oOption 		= new Option();
				oOption.value	= userIDList[i];				
				oOption.text	= userNameList[i];
				oXM_Receiver_ID.options[oXM_Receiver_ID.options.length] = oOption;
				if(oAllLoginUsers.value.length > 0)
				{
					oAllLoginUsers.value	= oAllLoginUsers.value + "," + userIDList[i];
				}
				else
				{
					oAllLoginUsers.value	= userIDList[i];
				}
			}
		}
		
		//return;
		
		var allUsersValue = "";
		var addUser = "";
		for(var i=oXM_Receiver_ID.options.length-1;i>=0;i--)
		{
			addUser = oXM_Receiver_ID.options[i].value;
			if(listUserIDList.indexOf(oXM_Receiver_ID.options[i].value) < 0)
			{
				if(oXM_Receiver_ID.selectedIndex != i)
				{
					oXM_Receiver_ID.remove(i);
					addUser = "";
				}
			}
			
			if(addUser.length > 0)
			{
				if(allUsersValue.length > 0)
				{
					allUsersValue = allUsersValue + addUser + ",";
				}
				else
				{
					allUsersValue = addUser;
				}
			}
		}
		oAllLoginUsers.value = allUsersValue;		
	}
	document.body.onload=new Function ("addUsersList();");
</SCRIPT>

 
 
 

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>



