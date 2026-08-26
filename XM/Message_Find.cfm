<cfheader name="Cache-Control" value="no-store">


<cfparam name="Form.XM_Connect_ID" default=0>
<cfparam name="Form.IgnoreConnection" default=false>
<CFIF Form.IgnoreConnection>
<CFIF ISNumeric(Form.XM_Connect_ID)>
	<CFIF Form.XM_Connect_ID GT 0>		
		<CFQUERY NAME="set_Ignore" datasource="#application.datasource#">
			UPDATE	XMConnect
			SET		XM_Connect=0
			WHERE	XM_Connect_ID=#Form.XM_Connect_ID#
		</CFQUERY>
		<CFLOCATION addtoken="No" url="Message_Find.cfm">
	</CFIF>
</CFIF>
</CFIF>


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

<CFQUERY NAME="Session_Timeout" DATASOURCE="#application.datasource#">
SELECT	CEILING(Session_Expiration_Length * (24.00*60.00*60.00)) AS In_Seconds
FROM	General_Settings
</CFQUERY>
<CFSET Refresh_Time = 1000000>
<CFIF Session_Timeout.RecordCount GT 0>
	<CFIF IsNumeric(Session_Timeout.In_Seconds)>
		<CFSET Refresh_Time = Session_Timeout.In_Seconds>
	</CFIF>
</CFIF>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>xxxxxxxxxxxxxxxxxxxxxxxxx</TITLE>
	<CFIF Get_Connection_Status.recordCount LTE 0>
		<CFIF Refresh_Time LTE 315360000>
			<META HTTP-EQUIV="Refresh" CONTENT="<CFOUTPUT>#Refresh_Time#</CFOUTPUT>">
		</CFIF>
	</CFIF>
	<META HTTP-EQUIV="Cache-Control" CONTENT="no-store">
</HEAD>
<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" RIGHTMARGIN="0" BOTTOMMARGIN="0" STYLE="margin:0; border: 0px; background-color:transparent" allowTransparency="true">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

 <CFIF Get_Connection_Status.recordCount GT 0>
 	<SCRIPT>
		var shouldReload = false;
	</SCRIPT>
 	<!---------------------------- show blinking ------------------------------------>
	<CFOUTPUT>
	<!-----<A HREF="javascript:void(0);" OnClick="javaScript:document.frmAcknowledge.submit();window.location.reload();"></A>	------->
	<!-----alert('');window.location.reload();------->
	<!-----ListLast(Get_Connection_Status.senderName," ")------->
	<FORM ID="frmAcknowledge" NAME="frmAcknowledge" METHOD="POST" TARGET="#Replace(Get_Connection_Status.senderName," ","_","All")#" ACTION="Acknowledge.cfm" onSubmit="javaScript:NewWindow('',this.target,'480','410','No', 'No');">	
	<INPUT TYPE="HIDDEN" ID="XM_Connect_ID" NAME="XM_Connect_ID" VALUE="#Get_Connection_Status.XM_Connect_ID#">
	<INPUT TYPE="HIDDEN" ID="XM_Sender_ID" NAME="XM_Sender_ID" VALUE="#Get_Connection_Status.XM_Sender_ID#">

<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" height="100%">
<TR>
	<TD valign="middle"><INPUT TYPE="image" WIDTH="50" HEIGHT="35" SRC="/images/icon_chat1.gif" BORDER="0" TITLE="[#DateFormat(Get_Connection_Status.XM_Connect_Date,"mm/dd/yy")# #TimeFormat(Get_Connection_Status.XM_Connect_Date,"hh:mm:ss tt")#]#chr(13)##chr(10)##Get_Connection_Status.senderName# is calling you..."></TD>
	<TD valign="middle">&nbsp;&nbsp;<A HREF="javaScript:document.frmIgnore.submit();" STYLE="TEXT-DECORATION:NONE" TITLE="Click here to ignore..."><FONT COLOR="ffffff"><b>x</b></FONT></A></TD>
</TR>
</TABLE>
	
	</FORM>
	
	<!-----<BR><BR><BR><A HREF="javascript:void(0);" OnClick="javaScript:document.frmIgnore.submit();window.location.reload();"><IMG SRC="" BORDER="0" ALT="Ignore"></A>------->
	
	<FORM ID="frmIgnore" NAME="frmIgnore" METHOD="POST" ACTION="Message_Find.cfm">
	<INPUT TYPE="HIDDEN" ID="XM_Connect_ID" NAME="XM_Connect_ID" VALUE="#Get_Connection_Status.XM_Connect_ID#">
	<INPUT TYPE="HIDDEN" ID="IgnoreConnection" NAME="IgnoreConnection" VALUE="true"><!-----<INPUT TYPE="image" SRC="" BORDER="0" ALT="Ignore">-------></FORM>
	<SCRIPT language="JavaScript">
		document.body.onload= new Function("blinkPage();");
		var intevalID;
		function blinkPage()
		{
			window.parent.focus();
		}
		/*
		function blinkPage()
		{
			intevalID = setInterval("blinkPage2()",1000);
		}
		function blinkPage2()
		{
			window.parent.focus();
		}
		window.onfocus = new Function("clearInterval(intevalID);");		
		*/
	</SCRIPT>
	</CFOUTPUT>
 <CFELSE>
 	<SCRIPT>
		var shouldReload = true;
	</SCRIPT>
 	<!---------------------------- show greyed ------------------------------------>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" height="100%">
	<TR>
	<TD valign="middle">
	<A HREF="/xm/index.cfm" onclick="NewWindow(this.href,'XMessenger','480','410','No', 'No');return false;"><IMG SRC="/images/icon_chat2.gif" BORDER="0" TITLE="Access the XMessenger..."></A>
	</TD>
	</TABLE>
 </CFIF>
 
 <SCRIPT language="JavaScript">
 	function newMessageReload()
	{
		if(shouldReload)
		{
			window.location.reload();
		}
	}
 </SCRIPT>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>
