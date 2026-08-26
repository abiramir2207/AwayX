<CFINCLUDE TEMPLATE="Message_Number.cfm">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Billback</TITLE>
	<STYLE>
	TR.blueBottomBorder TD
	{
		border-bottom:solid #93BEE2 1px;
	}
	TD.blueBottomBorder
	{
		border-bottom:solid #aaaaaa 1px;
	}
	</STYLE>
	
</HEAD>
<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- This is the Route In Message  																 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<SCRIPT LANGUAGE="JavaScript">
	function check_all(check_name, thisObj)
	{
		var i;
		var chColl = thisObj.form.Route_Recipient_ID;
		var check_Val = thisObj.checked;
		if(chColl)
		{
			if(chColl.length)
			{
				for(i=0;i<chColl.length;i++)
				{
					chColl[i].checked = check_Val;
				}			
			}
			else
			{
				chColl.checked = check_Val;
			}
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
	SELECT	Route_Message.Route_Message_ID, Route_Message.Subject, Route_Message.Message_Body, Route_Message.Message_Date, _Users.Name_First + ' ' + _Users.Name_Last AS Full_Name, _Users.User_Email, Route_Recipient.Message_Status, Route_Recipient.Reply_Message, Route_Recipient.Recipient_ID, Route_Recipient.Route_Recipient_ID, Route_Message.Document_ID, Route_Message.Document_Type_ID
		,CASE
		WHEN Route_Recipient.Message_Status = 0 THEN	
			Route_Message.Message_Date
		WHEN Route_Recipient.Message_Status = 1 THEN	
			Route_Recipient.Reply_Date
		WHEN Route_Recipient.Close_Date = 2 THEN	
			Route_Recipient.Close_Date
		END AS MessageDate
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
		Route_Recipient
			ON (
				(Route_Message.Route_Message_ID = Route_Recipient.Route_Message_ID)
				AND
				(Route_Recipient.Deleted = 0)
				)
	LEFT JOIN
		_Users
			ON (Route_Recipient.Recipient_ID = _Users.User_ID)
	WHERE
			Route_Message.Sender_ID = '#request.AccessStructure.User_ID#'
			AND
			Route_Message.Deleted = 0
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
	ORDER BY 	Route_Recipient.Recipient_ID
</CFQUERY>

<SCRIPT LANGUAGE="JavaScript">
function ChangeToDelete()
{
	MyForm.action = "/Route/Route_Delete_Action.cfm";
	MyForm.submit();
}
</SCRIPT>
<BR>
<FORM ACTION="/Route/Route_Close_Action.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
<BLOCKQUOTE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2">Message Details:</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFIF Get_This_Message.recordCount GT 0>
		<CFOUTPUT>		
		
			<TABLE WIDTH="90%" BGCOLOR="FFFFFF">
				<TR VALIGN="top">
					<TD><B>Message ##</B></TD>
					<TD>
					#Get_Message_Number(Get_This_Message.Route_Message_ID)#
					</TD>
				</TR>
				<TR>
					<TD><B>#Route_Document_Name# ##</B></TD>
					<TD>
					<CFSET Route_Document_ID=Get_This_Message.Document_ID>
					<!----
					<CFIF Get_This_Message.Document_Type_ID EQ 1>
						<CFINCLUDE TEMPLATE="Billback_Access.cfm">
					</CFIF>
					<CFIF ListFindNoCase(Route_Document_Access,"'#Get_This_Message.Document_ID#'",",")><A TARGET="_parent" HREF="/Billbacks/capture/index.cfm?BBID=#Route_Document_ID#&MESSAGE_ID=#Get_This_Message.Route_Message_ID#">#Get_This_Message.Document_Number#</A>
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
					<TD>#request.AccessStructure.Name_First#&nbsp;#request.AccessStructure.Name_Last#</TD>
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
				</CFOUTPUT>
				<TR>
					<TD COLSPAN="2">
					<CFOUTPUT>
					
					<INPUT NAME="Message_ID" TYPE="hidden" VALUE="#FORM.Message_ID#">
					<INPUT NAME="Document_ID" TYPE="hidden" VALUE="#Route_Document_ID#">
					<INPUT NAME="Document_Type" TYPE="hidden" VALUE="#Route_Document_Type#">
					</CFOUTPUT>
					<CFSET Message_Status_Text="New,Acknowledged,Closed">
					<TABLE WIDTH="100%" CELLSPACING="0" CELLPADDING="2">
						<THEAD BGCOLOR="#FFCE84">
							<TD ALIGN="LEFT"><INPUT TYPE="CHECKBOX" OnClick="JavaScript: check_all('Message_ID', this)"></TH>
							<TD><B>Recipient</B></TD>
							<TD><B>Status</B></TD>
						</THEAD>
						<CFSET how_many_Message=0>
						<CFOUTPUT QUERY="Get_This_Message" GROUP="Recipient_ID">
							<CFIF Get_This_Message.Recipient_ID NEQ "">
								<CFSET how_many_Message=how_many_Message+1>
								<CFSET BGCOLOR="#IIf(Get_This_Message.Message_Status EQ 0, DE('FFF7E5'), DE('ffffff'))#">
								<CFSET second_Row= Get_This_Message.Message_Status GT 0 AND Get_This_Message.Reply_Message NEQ "">
								<TR BGCOLOR="#BGCOLOR#"<CFIF NOT second_Row> CLASS="blueBottomBorder"</CFIF>>
									<TD><INPUT TYPE="CHECKBOX" ID="Route_Recipient_ID" NAME="Route_Recipient_ID" VALUE="#Route_Recipient_ID#"></TD>
									<TD CLASS="blueBottomBorder">
									#Get_This_Message.Full_Name#									
									</TD>
									<TD CLASS="blueBottomBorder">
									#ListGetAt(Message_Status_Text,Get_This_Message.Message_Status+1,",")#
									<BR>#DateFormat(MessageDate, "MM/DD/YYYYY")# #TimeFormat(MessageDate, "hh:mm tt")#
									</TD>
								</TR>
								<CFIF second_Row>
									<TR BGCOLOR="#BGCOLOR#" CLASS="blueBottomBorder">
										<TD>&nbsp;</TD>
										<TD COLSPAN="2">
										#Replace(Get_This_Message.Reply_Message,"#chr(13)##chr(10)#","<br>","All")#&nbsp;
										</TD>
									</TR>
								</CFIF>
							</CFIF>
						</CFOUTPUT>
						<CFIF how_many_Message GT 0>
							<TR>
								<TD></TD>
								<TD ALIGN="CENTER">
								<CF_button
									button_name		=	""
									button_caption	=	"close messages"
									button_action	=	"MyForm.submit();"
									button_type		=	"javascript_link"
									button_width	=	"150"
									button_color	=	"Navy"
									button_tip		=	"Click here to close this message..."
									font_color		=	"White"
									font_size		=	"12"
									font_weight		=	"bold">
								</TD>
								<TD ALIGN="CENTER">
								<CF_button
									button_name		=	""
									button_caption	=	"delete messages"
									button_action	=	"ChangeToDelete();"
									button_type		=	"javascript_link"
									button_width	=	"150"
									button_color	=	"Navy"
									button_tip		=	"Click here to close this message..."
									font_color		=	"White"
									font_size		=	"12"
									font_weight		=	"bold">
								</TD>
							</TR>
						</CFIF>
						</TABLE>
					</TD>
				</TR>
			</TABLE>
		
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

 