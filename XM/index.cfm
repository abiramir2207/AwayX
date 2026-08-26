<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>XMessenger</TITLE>
</HEAD>
<BODY onLoad="document . MyForm . XM_Message . focus ();if(window.opener)window.opener.location.reload();" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="10" TOPMARGIN="10">


<style>
	 .input
		{
			width: 400px;
		}
</style>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the list of users logged to the system													 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Active_Users" datasource="#application.datasource#">
	Select		DateDiff("n", Session_Date_Time_Stamp, GetDate()) AS idleMinutes,
				Session_Tracker.Session_User_ID,
				_Users.Name_First,
				_Users.Name_Last

	From		Session_Tracker,
				_Users

	Where		(Session_Tracker.Session_ID <> 'NULL')
				AND
				(Session_Tracker.Session_User_ID	=	_Users.User_ID	)
				AND
				(Session_Tracker.Session_User_ID	<>	'#request.AccessStructure.User_ID#'	)
				AND
				DateDiff(n, Session_Date_Time_Stamp, GetDate()) < 
						(Select  TOP 1 Session_Expiration_Length * 24 * 60 	From	General_Settings)
	Order by	_Users.Name_First
</CFQUERY>

<CFPARAM NAME="URL.ID" DEFAULT="0">

<!--- variable to be used for help (It is being used in (/helpsystem/help_link.cfm) --->
<cfset GetHelpURL = 1>

<MAP NAME="xxxxxxxxxx">
<AREA TITLE="Close XMessenger" SHAPE="CIRCLE" COORDS="7,6,6" HREF="javascript:window.close();">
</MAP>


<FORM ACTION="send_message.cfm" NAME="MyForm" TARGET="XM_History" METHOD="post" ONSUBMIT="javaScript:submitForm(this);">

<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">

<cfoutput>		
<MAP NAME="MyMap">
<AREA TITLE="" COORDS="67,11,151,1" HREF="#URLLink#" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;">
</MAP>
</cfoutput>
		
<TABLE WIDTH=469 BORDER=0 CELLPADDING=0 CELLSPACING=0>
	<TR>
		<TD>
			<IMG SRC="/images/XMessenger/index_01.jpg" WIDTH=9 HEIGHT=8 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_02.jpg" WIDTH=18 HEIGHT=8 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_03.jpg" WIDTH=16 HEIGHT=8 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_04.jpg" WIDTH=164 HEIGHT=8 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_05.jpg" WIDTH=37 HEIGHT=8 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_06.jpg" WIDTH=162 HEIGHT=8 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_07.jpg" WIDTH=21 HEIGHT=8 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_08.jpg" WIDTH=42 HEIGHT=8 TITLE=""></TD>
	</TR>
	<TR>
		<TD>
			<IMG SRC="/images/XMessenger/index_09.jpg" WIDTH=9 HEIGHT=11 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_10.jpg" WIDTH=18 HEIGHT=11 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_11.jpg" WIDTH=16 HEIGHT=11 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_12.jpg" WIDTH=164 HEIGHT=11 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_13.jpg" WIDTH=37 HEIGHT=11 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_14.jpg" WIDTH=162 HEIGHT=11 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_15.jpg" WIDTH=21 HEIGHT=11 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_16.jpg" WIDTH=42 HEIGHT=11 TITLE=""></TD>
	</TR>
	<TR>
		<TD>
			<IMG SRC="/images/XMessenger/index_17.jpg" WIDTH=9 HEIGHT=20 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_18.jpg" WIDTH=18 HEIGHT=20 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_19.jpg" WIDTH=16 HEIGHT=20 TITLE=""></TD>
		<TD><INPUT TYPE="image" ID="connectUser" NAME="connectUser" SRC="/images/XMessenger/index_20.jpg"></TD><!--- Connect button --->
		<TD>
			<IMG SRC="/images/XMessenger/index_21.jpg" WIDTH=37 HEIGHT=20 TITLE=""></TD>
		<TD><IMG SRC="/images/xmessenger/index_22a.jpg" WIDTH="162" HEIGHT="20" BORDER="0" USEMAP="#MyMap"></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_23.jpg" WIDTH=21 HEIGHT=20 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_24.jpg" WIDTH=42 HEIGHT=20 TITLE=""></TD>
	</TR>
	<TR>
		<TD>
			<IMG SRC="/images/XMessenger/index_25.jpg" WIDTH=9 HEIGHT=13 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_26.jpg" WIDTH=18 HEIGHT=13 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_27.jpg" WIDTH=16 HEIGHT=13 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_28.jpg" WIDTH=164 HEIGHT=13 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_29.jpg" WIDTH=37 HEIGHT=13 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_30.jpg" WIDTH=162 HEIGHT=13 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_31.jpg" WIDTH=21 HEIGHT=13 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_32a.jpg" WIDTH=42 HEIGHT=13 TITLE="" BORDER="0" USEMAP="#xxxxxxxxxx"></TD>
	</TR>
	<TR>
		<TD>
			<IMG SRC="/images/XMessenger/index_33.jpg" WIDTH=9 HEIGHT=282 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_34.jpg" WIDTH=18 HEIGHT=282 TITLE=""></TD>
		<TD COLSPAN=5 BGCOLOR="#E1FFE1">


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Users connected...																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SELECT  NAME="XM_Receiver_ID" STYLE="width: 400px;  background: #E1FFE1; color: #0000ff;">
	<OPTION VALUE="0" SELECTED>Please select a user...</OPTION>
	<CFOUTPUT QUERY="Get_Active_Users">
	<CFIF URL.ID EQ Session_User_ID><CFSET Selected="Selected"><CFELSE><CFSET Selected=""></CFIF>
	<OPTION VALUE="#Session_User_ID#"#Selected#>#Name_First# #Name_Last#<cfif idleMinutes GT 1440> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(Idle for #NumberFormat(Evaluate(idleMinutes/1440),"_____________")# Days)<cfelseif idleMinutes GT 60> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(Idle for #NumberFormat(Evaluate(idleMinutes/60),"_____________")# Hours)<cfelseif idleMinutes GT 3> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(Idle for #NumberFormat(idleMinutes,"_____________")# Minutes)</cfif></OPTION></CFOUTPUT>
</SELECT>
<CFOUTPUT>
<INPUT TYPE="HIDDEN" ID="allLoginUsers" NAME="allLoginUsers" VALUE="#ValueList(Get_Active_Users.Session_User_ID,",")#">

<IFRAME SRC="iframe.cfm?ID=#URL.ID#" NAME="XM_History" ID="XM_History" WIDTH="400" HEIGHT="226" MARGINWIDTH="0" MARGINHEIGHT="0" SCROLLING="Yes"></IFRAME>
</CFOUTPUT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Message to send...																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TEXTAREA COLS="" ROWS="" NAME="XM_Message" STYLE="width: 400px;    background: #FFFFFF; color: #0000ff;" onKeyPress="messageKeyPress(this)"></TEXTAREA>	


<SCRIPT LANGUAGE="JavaScript">

function submitForm(thisObj)
{
	thisObj.XM_Message2.value=thisObj.XM_Message.value;
	thisObj.XM_Message.value=''
}

function messageKeyPress(thisObj)
{
	if(event.keyCode == 13)
	{
		if(event.shiftKey)
		{
			addExtraLine(thisObj);
		}
		else
		{
			event.returnValue = false;
			submitForm(thisObj.form);
			thisObj.form.submit();
		}
	}
	else if(event.keyCode == 10)
	{
		addExtraLine(thisObj);
	}
}

function addExtraLine(thisObj)
{
	thisObj.value = thisObj.value + "\r\n";
	thisObj.focus();
}
 
</SCRIPT>
<INPUT TYPE="hidden" NAME="XM_Message2" VALUE="">


		
		
		</TD><!--- <IMG SRC="/images/XMessenger/index_35.gif" WIDTH=400 HEIGHT=282 TITLE=""> --->
		<TD>
			<IMG SRC="/images/XMessenger/index_36.jpg" WIDTH=42 HEIGHT=282 TITLE=""></TD>
	</TR>
	<TR>
		<TD>
			<IMG SRC="/images/XMessenger/index_37.jpg" WIDTH=9 HEIGHT=11 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_38.jpg" WIDTH=18 HEIGHT=11 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_39.jpg" WIDTH=16 HEIGHT=11 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_40.jpg" WIDTH=164 HEIGHT=11 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_41.jpg" WIDTH=37 HEIGHT=11 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_42.jpg" WIDTH=162 HEIGHT=11 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_43.jpg" WIDTH=21 HEIGHT=11 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_44.jpg" WIDTH=42 HEIGHT=11 TITLE=""></TD>
	</TR>
	<TR>
		<TD>
			<IMG SRC="/images/XMessenger/index_45.jpg" WIDTH=9 HEIGHT=19 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_46.jpg" WIDTH=18 HEIGHT=19 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_47.jpg" WIDTH=16 HEIGHT=19 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_48.jpg" WIDTH=164 HEIGHT=19 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_49.jpg" WIDTH=37 HEIGHT=19 TITLE=""></TD>
		<TD><INPUT TYPE="image" ID="sendMessage" NAME="sendMessage" SRC="/images/XMessenger/index_50.jpg"></TD><!--- Send message button --->
		<TD>
			<IMG SRC="/images/XMessenger/index_51.jpg" WIDTH=21 HEIGHT=19 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_52.jpg" WIDTH=42 HEIGHT=19 TITLE=""></TD>
	</TR>
	<TR>
		<TD>
			<IMG SRC="/images/XMessenger/index_53.jpg" WIDTH=9 HEIGHT=33 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_54.jpg" WIDTH=18 HEIGHT=33 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_55.jpg" WIDTH=16 HEIGHT=33 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_56.jpg" WIDTH=164 HEIGHT=33 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_57.jpg" WIDTH=37 HEIGHT=33 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_58.jpg" WIDTH=162 HEIGHT=33 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_59.jpg" WIDTH=21 HEIGHT=33 TITLE=""></TD>
		<TD>
			<IMG SRC="/images/XMessenger/index_60.jpg" WIDTH=42 HEIGHT=33 TITLE=""></TD>
	</TR>
</TABLE>




















</FORM>


</BODY>
</HTML>



