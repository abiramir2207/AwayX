<!------
Route_Acknowledge_Action.cfm
----->

<!------
Update the following values

Message_Status
Reply_Message
Reply_Date
----->


<cfparam name="FORM.Reply_Message" 	default="">
<cfparam name="FORM.Message_ID" 	default="">
<cfparam name="FORM.Document_ID" 	default="">
<cfparam name="FORM.Document_Type" 	default="">

<CFIF FORM.Message_ID NEQ "">
	<CFQUERY NAME="Update_As_Acknowledged" DATASOURCE="#application.datasource#">
		UPDATE	Route_Recipient
		SET
			Message_Status = 1,
			Reply_Message = '#FORM.Reply_Message#',
			Reply_Date = GetDate()
		WHERE
			Route_Recipient.Recipient_ID = '#request.AccessStructure.User_ID#'
			AND
			Route_Recipient.Route_Message_ID = #FORM.Message_ID#
	</CFQUERY>
	
	<!------
<CFSET redirect_URL="">
	<CFSWITCH EXPRESSION="#FORM.Document_Type#">
		<CFCASE VALUE="1">
			<CFSET redirect_URL="/Billbacks/common/bb_route_inbox.cfm?BBID=#FORM.Document_ID#">
		</CFCASE>
		<CFDEFAULTCASE>
			<CFSET redirect_URL="/Manufacturers/Home.cfm">
		</CFDEFAULTCASE>
	</CFSWITCH>
	<CFLOCATION URL="#redirect_URL#" ADDTOKEN="No">
----->
	
	<CFOUTPUT>
	
	<FORM ACTION="/Route/Route_In_Message.cfm" METHOD="post" NAME="frm_show_Message" ID="frm_show_Message">
	<INPUT NAME="Document_ID" TYPE="hidden" VALUE="#FORM.Document_ID#">
	<INPUT NAME="Document_Type" TYPE="hidden" VALUE="#FORM.Document_Type#">
	<INPUT ID="Message_ID" NAME="Message_ID" TYPE="hidden" VALUE="#FORM.Message_ID#">
	</FORM>
	<SCRIPT LANGUAGE="JavaScript">	
	show_Message();
	function show_Message()
	{
		try
		{
			if(window.opener)
			{
				window.opener.location.reload();
				window.close();
			}
			else
			{
				document.frm_show_Message.submit();
			}
		}
		catch(e)
		{
			document.frm_show_Message.submit();
		}	
		return false;
	}
	</SCRIPT>
	</CFOUTPUT>
	
	
<CFELSE>
	<SPAN CLASS="Title2">Invalid Message ID<SPAN>
</CFIF>