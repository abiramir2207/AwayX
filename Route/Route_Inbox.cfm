
<CFINCLUDE TEMPLATE="Message_Number.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- This is the Route Inbox page  																 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfparam name="Route_Document_Type" 	default=0>
<cfparam name="Document_ID" 	default="">


<CFSWITCH expression="#Route_Document_Type#">
	<CFCASE value="1">
		<cfparam name="Billback_ID" 			default="">
		<cfparam name="Route_Area_Type" 		default=0>
		<CFSET Route_Document_Name					=	"Billback">
		<CFSET Route_Document_ID					=	Document_ID>
		<CFSET Route_Document_Type					=	Route_Document_Type>
		<CFSET Route_Sent_URL						=	"Sent.cfm">
		<CFIF Len(Route_Document_ID) GT 0>
			<CFSET Route_Sent_URL						=	"bb_route_sent.cfm?BBID=#Route_Document_ID#">
			<cfset Route_Document_Access				=	"'#Route_Document_ID#'">
			<!-----Don't show document link if inside the Document ---->
			<cfset Route_Document_Access				=	"">
		<CFELSEIF NOT IsDefined("Route_Document_Access")>
			<CFINCLUDE TEMPLATE="Billback_Access.cfm">
		</CFIF>
	</CFCASE>
	<CFDEFAULTCASE>
		<CFABORT>
	</CFDEFAULTCASE>
</CFSWITCH>


<CFSET this_URL="#CGI.SCRIPT_NAME#">
<CFSET queryString="">
<CFLOOP COLLECTION=#URL# ITEM="thisURLItem">
	<CFIF (LCase(thisURLItem) NEQ "sort_by") AND (UCase(thisURLItem) NEQ "sort_order")>
		<CFIF Len(STRUCTFIND(URL, thisURLItem)) GT 0>
			<CFSET queryString=ListAppend(queryString, "#thisURLItem#=#STRUCTFIND(URL, thisURLItem)#", "&")>
		</CFIF>
	</CFIF>
</CFLOOP>


<!--------------------------------------------------------------------
Add Sort By
--------------------------------------------------------------------->

<cfparam name="URL.sort_by" 	default="">
<cfparam name="Form.sort_by" 	default="#URL.sort_by#">




<CFSET sql_Sort_By="Message_Date">
<CFSWITCH expression="#Form.sort_by#">
	
	<CFCASE value="Message Number">
		<CFSET sql_Sort_By="Route_Message.Route_Message_ID">
	</CFCASE>	
	<CFCASE value="Billback Number">
		<CFSET sql_Sort_By="BB_Code">
	</CFCASE>	
	<CFCASE value="Sender">
		<CFSET sql_Sort_By="Name_First">
	</CFCASE>	
	<CFCASE value="Date">
		<CFSET sql_Sort_By="Message_Date">
	</CFCASE>
	<CFCASE value="Subject">
		<CFSET sql_Sort_By="Subject">
	</CFCASE>
	<CFCASE value="Message">
		<CFSET sql_Sort_By="Message_Body">
	</CFCASE>
	<CFCASE value="Status">
		<CFSET sql_Sort_By="Message_Status">
	</CFCASE>
	<CFDEFAULTCASE>
		<CFSET Form.sort_by = "Date">
	</CFDEFAULTCASE>
</CFSWITCH>


<cfparam name="URL.Sort_Order" 	default="">
<CFSET Sort_Order="DESC">
<CFIF URL.Sort_Order EQ "ASC">
	<CFSET Sort_Order="ASC">
</CFIF>

<!--------------------------------------------------------------------
Add Sort By
--------------------------------------------------------------------->

<cfparam name="URL.ShowAll" 	default="">
<CFQUERY NAME="Get_Messages" DATASOURCE="#application.datasource#">
	SELECT	Route_Message.Route_Message_ID, Route_Message.Subject, Route_Message.Message_Body, Route_Message.Message_Date, _Users.Name_First + ' ' + _Users.Name_Last AS Full_Name, _Users.User_Email, Route_Recipient.Message_Status, Route_Message.Document_ID
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
			<CFIF URL.ShowAll EQ "">
			AND
			Route_Recipient.Message_Status < 2
			</CFIF>
			AND			
			Route_Recipient.Recipient_ID = '#request.AccessStructure.User_ID#'
			<CFIF Route_Document_Type GT 0>
			AND
			Route_Message.Document_Type_ID = #Route_Document_Type#
			</CFIF>
			<CFIF Len(Route_Document_ID) GT 0>
			AND
			Route_Message.Document_ID = '#Route_Document_ID#'
			</CFIF>
	ORDER BY #sql_Sort_By# #Sort_Order#
</CFQUERY>

<SCRIPT LANGUAGE="JavaScript">
	function check_all(check_name, thisObj)
	{
		var i;
		var chColl = thisObj.form.Message_ID;
		var check_Val = thisObj.checked;
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
	
	function show_Message(message_ID)
	{
		document.frm_show_Message.Message_ID.value = message_ID;
		NewWindow('', document.frm_show_Message.target, '800','550','Yes', 'Yes');
		document.frm_show_Message.submit();
		return false;
	}
</SCRIPT>

<BR>
<FORM ACTION="/Route/Route_Inbox_Action.cfm" METHOD="post" NAME="MyForm" ID="MyForm">


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFOUTPUT>
<CFSET thisQStr=ListAppend(queryString, "sort_by=#Form.sort_by#", "&")>
<CFSET ShowAll_Label="view open messages">
<CFSET this_page_Desc="All">
<CFIF URL.ShowAll EQ "">
	<CFSET thisQStr=ListAppend(thisQStr, "ShowAll=1", "&")>
	<CFSET ShowAll_Label="view all messages">
	<CFSET this_page_Desc="Open">
<CFELSE>
	<CFSET thisQStr=REReplaceNoCase(thisQStr, "ShowAll=.*?&", "")>
</CFIF>
		
<CFIF Len(thisQStr) GT 0>
	<CFSET thisQStr="?#thisQStr#">
</CFIF>


<TABLE WIDTH="92%" ALIGN="CENTER">
	<TR>
		<TD>
		<SPAN CLASS="title2">Inbox (#this_page_Desc#)</SPAN>
		</TD>
		<TD ALIGN=RIGHT>
		<B><FONT COLOR="Red">[</FONT>&nbsp;<A HREF="#this_URL##thisQStr#">#ShowAll_Label#</A>&nbsp;<FONT COLOR="Red">]</FONT></B>
		&nbsp;
		<B><FONT COLOR="Red">[</FONT>&nbsp;<A HREF="#Route_Sent_URL#">view sent messages</A>&nbsp;<FONT COLOR="Red">]</FONT></B>
		</TD>
	</TR>
</TABLE>
</CFOUTPUT>

<HR COLOR="Orange" WIDTH="92%">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFIF Get_Messages.recordCount GT 0>
	<CFSET Column_Headers="Message Number,Billback Number,Status,Sender,Date,Subject">
	<TABLE CLASS="Maintable" WIDTH="92%" CELLPADDING="2" CELLSPACING="0" ALIGN="CENTER">
	<THEAD BGCOLOR="#FFCE84" VALIGN="bottom">
		<CFOUTPUT>
		<!------
<TH ALIGN="LEFT"><INPUT TYPE="CHECKBOX" OnClick="JavaScript: check_all('Message_ID', this)"></TH>
----->
		<!--- <TH ID="header" ALIGN="LEFT">Message ##</TH> --->
		<!--- <TH ID="header" ALIGN="LEFT"><cfif Route_Document_Type IS 1><A HREF="#this_URL##thisQStr#"></cfif>#Route_Document_Name# ##<cfif Route_Document_Type IS 1></a></cfif></TH> --->
		<CFLOOP LIST="#Column_Headers#" INDEX="thisHeader">
			<CFSET thisQStr=ListAppend(queryString, "sort_by=#thisHeader#", "&")>
			<CFSET sortImage="">
			<CFIF thisHeader EQ Form.sort_by>
				<CFIF Sort_Order EQ "DESC">
					<CFSET New_Sort_Order="ASC">
					<CFSET sortImage="up_1.gif">
				<CFELSE>
					<CFSET New_Sort_Order="DESC">
					<CFSET sortImage="down_1.gif">
				</CFIF>
			<CFELSE>
				<CFSET New_Sort_Order="ASC">
			</CFIF>
			<CFSET thisQStr=ListAppend(thisQStr, "Sort_Order=#New_Sort_Order#", "&")>
			
			<CFIF Len(thisQStr) GT 0>
				<CFSET thisQStr="?#thisQStr#">
			</CFIF>
			<TH ID="header" ALIGN="LEFT"><A HREF="#this_URL##thisQStr#">#thisHeader#<CFIF Len(sortImage) GT 0> <IMG BORDER="0" SRC="/Images/#sortImage#"></CFIF></A></TH>
		</CFLOOP>
		</CFOUTPUT>
		<TH ID="">&nbsp;</TH>
	</THEAD>
		<CFSET Message_Status_Text="New,Acknowledged,Closed">
		<CFSET bgColors="FFF7E5,ffffff,dddddd">
		<CFOUTPUT QUERY="Get_Messages">
		
		<CFSET BGCOLOR=ListGetAt(bgColors,Get_Messages.Message_Status+1,",")>
		<!------
<CFIF (Get_Messages.currentRow mod 2) NEQ 0> 
			<CFSET MAIN_BGCOLOR="FFFFFF">
		<CFELSE>
			<CFSET MAIN_BGCOLOR="FFFFFF">
		</CFIF>
----->
		<TR BGCOLOR="#BGCOLOR#" VALIGN="top">
			<!------
<TD><INPUT TYPE="CHECKBOX" ID="Message_ID" NAME="Message_ID" VALUE="#Route_Message_ID#"></TD>
----->
			<TD STYLE="border-bottom:solid 93BEE2 0px;">
			<CFSET Message_Number = Get_Message_Number(Get_Messages.Route_Message_ID)>
			<A HREF="##" onClick="javaScript: return show_Message('#Get_Messages.Route_Message_ID#');" TITLE="Go to Message #Message_Number#...">
			#Message_Number#</A></TD>
			<TD ID="">
			<!------
#Get_Messages.Document_ID#--
			#Route_Document_Access#
----->
			<CFIF ListFindNoCase(Route_Document_Access,"'#Get_Messages.Document_ID#'",",")><A TARGET="_parent" HREF="/Billbacks/capture/index.cfm?BBID=#Get_Messages.Document_ID#&MESSAGE_ID=#Get_Messages.Route_Message_ID#" TITLE="Goto #Route_Document_Name# #Get_Messages.Document_Number#">#Get_Messages.Document_Number#</A>
			<CFELSE>
			#Get_Messages.Document_Number#
			</CFIF>			
			&nbsp;</TD>
			<TD ID="">			
			#ListGetAt(Message_Status_Text,Get_Messages.Message_Status+1,",")#
			</TD>
			<TD ID="">#Get_Messages.Full_Name#&nbsp;</TD>
			<TD ID="" NOWRAP>#DateFormat(Get_Messages.Message_Date,"mm/dd/yyyy")#&nbsp;#TimeFormat(Get_Messages.Message_Date,"hh:mm tt")#</TD>
			<TD ID="">#Get_Messages.Subject#&nbsp;</TD>
			<TD ID="">&nbsp;</TD>
		</TR>
		<TR BGCOLOR="#BGCOLOR#">
			<TD STYLE="border-bottom:solid blue 1px;">&nbsp;</TD>
			<TD COLSPAN="100%" TITLE="#Get_Messages.Message_Body#" STYLE="border-bottom:solid blue 1px;">			
			#Replace(Left(Get_Messages.Message_Body, 150), "#chr(13)##chr(10)#", "<br>","All")#...&nbsp;
			</TD>
		</TR>	
		</CFOUTPUT>
	</TABLE>
<CFELSE>
	<BLOCKQUOTE><SPAN CLASS="Title2">No Message Found</SPAN></BLOCKQUOTE>
</CFIF>

<BR>
<!------
javaScript: void(0);
----->
<INPUT NAME="Document_ID" TYPE="hidden" VALUE="<CFOUTPUT>#Route_Document_ID#</CFOUTPUT>">
<INPUT NAME="Document_Type" TYPE="hidden" VALUE="<CFOUTPUT>#Route_Document_Type#</CFOUTPUT>">

<BR CLEAR="ALL">
<BR>



<!------
<TABLE>
	<TR>
		<TD>
			<CF_button
				button_name		=	""
				button_caption	=	"send email package"
				button_action	=	"MyForm.submit();"
				button_type		=	"javascript_link"
				button_width	=	"150"
				button_color	=	"Navy"
				button_tip		=	"Click here to send..."
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold">
		</TD>
	</TR>
</TABLE>
----->

</FORM>

<FORM ACTION="/Route/Route_In_Message.cfm" METHOD="post" NAME="frm_show_Message" ID="frm_show_Message" TARGET="Commounication_Center">
	<INPUT NAME="Document_ID" TYPE="hidden" VALUE="<CFOUTPUT>#Route_Document_ID#</CFOUTPUT>">
	<INPUT NAME="Document_Type" TYPE="hidden" VALUE="<CFOUTPUT>#Route_Document_Type#</CFOUTPUT>">
	<INPUT ID="Message_ID" NAME="Message_ID" TYPE="hidden" VALUE="">
</FORM>
