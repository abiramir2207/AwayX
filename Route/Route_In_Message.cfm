<CFINCLUDE TEMPLATE="Message_Number.cfm">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Billback</TITLE>
</HEAD>
<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- This is the Route In Message  																 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<SCRIPT>
	function checklength(maxLen, thisObj)
	{
		var bStop = 0;
		var clipBoardText = "";
		switch(event.type.toLowerCase())
		{
			case "paste":
				if(window.clipboardData)
				{
					clipBoardText = window.clipboardData.getData("Text");
				}
				
				if(thisObj.value.length >= maxLen)
				{
					bStop = 1;
				}
				else if((thisObj.value.length + clipBoardText.length) >= maxLen)
				{
					 bStop = 2;
				}
			case "keypress":
				if(thisObj.value.length >= maxLen)
				{
					bStop = 1;
				}
				break;			
		}
		
		
		if(bStop == 2)
		{
			var fieldValue = thisObj.value + clipBoardText;
			fieldValue = fieldValue.substr(0, maxLen);
			
			var lastColon = fieldValue.lastIndexOf(";");
			if(lastColon > 0)
			{
				fieldValue = fieldValue.substring(0, lastColon);
			}
			thisObj.value = fieldValue;
		}
		
		if(bStop == 0)
		{
			return true;
		}
		else
		{
			window.event.returnValue = false;
			window.event.cancelBubble = true;
			return false;			
		}
	}
	
</SCRIPT>

<cfparam name="FORM.Message_ID" 	default="">
<cfparam name="FORM.Document_Type" 	default="">
<cfparam name="FORM.Document_ID" 	default="">

<CFSWITCH expression="#FORM.Document_Type#">
	<CFCASE value="1">
		<CFSET Route_Document_Name					=	"Billback">
		<CFSET Route_Document_ID					=	FORM.Document_ID>
		<CFSET Route_Document_Type					=	FORM.Document_Type>
		<CFIF Len(Route_Document_ID) EQ 0>								
			<!------
<CFINCLUDE TEMPLATE="Billback_Access.cfm">
----->	
		<CFELSE>
			<cfset Route_Document_Access				=	"'#FORM.Document_ID#'">
		</CFIF>
	</CFCASE>
	<CFDEFAULTCASE>
		<CFABORT>
	</CFDEFAULTCASE>
</CFSWITCH>


<CFSET this_URL="#CGI.SCRIPT_NAME#">
<CFSET queryString="">
<CFLOOP COLLECTION=#URL# ITEM="thisURLItem">
	<CFIF UCase(thisURLItem) NEQ "sort_by">
		<CFSET queryString=ListAppend(queryString, "#thisURLItem#=#STRUCTFIND(URL, thisURLItem)#", "&")>
	</CFIF>
</CFLOOP>


<CFQUERY NAME="Get_This_Message" DATASOURCE="#application.datasource#">
	SELECT	Route_Message.Route_Message_ID, Route_Message.Subject, Route_Message.Message_Body, Route_Message.Message_Date, _Users.Name_First + ' ' + _Users.Name_Last AS Full_Name, _Users.User_Email, Route_Recipient.Message_Status, Route_Recipient.Reply_Message, Route_Message.Document_ID, Route_Message.Document_Type_ID
		<CFSWITCH EXPRESSION="#Route_Document_Type#">
			<CFCASE VALUE="1">
			, Billback.BB_Code
			</CFCASE>
			<CFDEFAULTCASE>
			, ''
			</CFDEFAULTCASE>
		</CFSWITCH>
		AS Document_Number
	FROM	
		(Route_Message
		<CFSWITCH EXPRESSION="#Route_Document_Type#">
			<CFCASE VALUE="1">			
				INNER JOIN
				Billback
				ON (Route_Message.Document_ID = Billback.Billback_ID)
		</CFCASE>
		</CFSWITCH>
		)
		
	LEFT JOIN
		_Users
			ON (Route_Message.Sender_ID = _Users.User_ID)
	LEFT JOIN
		Route_Recipient
			ON (Route_Message.Route_Message_ID = Route_Recipient.Route_Message_ID)
	WHERE
			Route_Recipient.Deleted = 0
			AND
			Route_Message.Deleted = 0
			AND
			Route_Recipient.Recipient_ID = '#request.AccessStructure.User_ID#'
			AND
			Route_Message.Route_Message_ID = #FORM.Message_ID#
			<CFIF Route_Document_Type GT 0>
			AND
			Route_Message.Document_Type_ID = #Route_Document_Type#
			</CFIF>
			<CFIF Len(Route_Document_ID) GT 0>
			AND
			Route_Message.Document_ID = '#Route_Document_ID#'
			</CFIF>
</CFQUERY>

<BR>
<FORM ACTION="/Route/Route_Acknowledge_Action.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
<BLOCKQUOTE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2">Message Details:</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFIF Get_This_Message.recordCount GT 0>
		<CFOUTPUT>		
		<CFSET BGCOLOR="#IIf(Get_This_Message.Message_Status EQ 0, DE('FFF7E5'), DE('ffffff'))#">
			<TABLE WIDTH="90%" BGCOLOR="#BGCOLOR#">
				<TR VALIGN="top">
					<TD><B>Message ##</B></TD>
					<TD>
					#Get_Message_Number(Get_This_Message.Route_Message_ID)#
					</TD>
				</TR>
				<TR VALIGN="top">
					<TD><B>Message Status</B></TD>
					<TD>
					<CFSET Message_Status_Text="New,Acknowledged,Closed">
					#ListGetAt(Message_Status_Text,Get_This_Message.Message_Status+1,",")#
					</TD>
				</TR>
				<TR>
					<TD><B>#Route_Document_Name# ##</B></TD>
					<TD>
					<CFSET Route_Document_ID=Get_This_Message.Document_ID>
					<!-----
					<CFIF Get_This_Message.Document_Type_ID EQ 1>
						<CFINCLUDE TEMPLATE="Billback_Access.cfm">
					</CFIF>
					<CFIF ListFindNoCase(Route_Document_Access,"'#Get_This_Message.Document_ID#'",",")><A TARGET="_parent" HREF="/Billbacks/capture/index.cfm?BBID=#Get_This_Message.Document_ID#&MESSAGE_ID=#Get_This_Message.Route_Message_ID#">#Get_This_Message.Document_Number#</A>
					<CFELSE>
					#Get_This_Message.Document_Number#
					</CFIF>
					---->
					#Get_This_Message.Document_Number#
					</TD>
				</TR>
				<TR VALIGN="top">
					<TD><B>Date</B></TD>
					<TD>#DateFormat(Get_This_Message.Message_Date,"mm/dd/yyyy")#&nbsp;#TimeFormat(Get_This_Message.Message_Date,"hh:mm:ss tt")#</TD>
				</TR>
				<TR VALIGN="top">
					<TD><B>Sender</B></TD>
					<TD>#Get_This_Message.Full_Name#&nbsp;</TD>
				</TR>
				<TR VALIGN="top">
					<TD><B>Subject</B></TD>
					<TD>#Get_This_Message.Subject#&nbsp;</TD>
				</TR>
				<TR VALIGN="top">
					<TD COLSPAN="2">
					<B>Message</B>
					<HR COLOR="Navy">
					</TD>
				</TR>
				<TR VALIGN="top">
					<TD COLSPAN="2">
					#Replace(Get_This_Message.Message_Body,"#chr(13)##chr(10)#","<br>","All")#&nbsp;
					</TD>
				</TR>
				<TR>
					<TD COLSPAN="2">
					<CFIF Get_This_Message.Message_Status EQ 0>
						<HR COLOR="Navy">
						<TABLE WIDTH="100%">
							<TR>
								<TD>							
								<TEXTAREA NAME="Reply_Message" STYLE="WIDTH:300;" COLS="150" ROWS="4" SIZE="5" onPaste="javaScript: return checklength(4000, this);" onkeyPress="javaScript: return checklength(4000, this);"></TEXTAREA>
								<INPUT ID="Message_ID" NAME="Message_ID" TYPE="hidden" VALUE="#FORM.Message_ID#">
								<INPUT NAME="Document_ID" TYPE="hidden" VALUE="#Route_Document_ID#">
								<INPUT NAME="Document_Type" TYPE="hidden" VALUE="#Route_Document_Type#">
								</TD>
								<TD>
						<CF_button
							button_name		=	""
							button_caption	=	"acknowledge"
							button_action	=	"if(document.MyForm.Reply_Message.value.length > 0){MyForm.submit();}else{alert('Enter Reply Message');}"
							button_type		=	"javascript_link"
							button_width	=	"150"
							button_color	=	"Navy"
							button_tip		=	"Click here to acknowledge..."
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold">
							</TD>
							</TR>
							</TABLE>
						<CFELSE>
							<B>Reply Message</B>
							<HR COLOR="Navy">
							#Replace(Get_This_Message.Reply_Message,"#chr(13)##chr(10)#","<br>","All")#&nbsp;
							<DIV ALIGN="CENTER">
							<CF_button
							button_name		=	""
							button_caption	=	"close"
							button_action	=	"window.close();"
							button_type		=	"javascript_link"
							button_width	=	"150"
							button_color	=	"Navy"
							button_tip		=	"Click here to close this window..."
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold">
							</DIV>
						</CFIF>
					</TD>
				</TR>
			</TABLE>
		</CFOUTPUT>
</CFIF>

<BR>

<BR CLEAR="ALL">
<BR>

 </BLOCKQUOTE>
</FORM>
<CFOUTPUT>
</CFOUTPUT>
</BODY>
</HTML>

 