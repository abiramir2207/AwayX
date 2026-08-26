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
	<cfset useLakebaseForUpdate_As_Acknowledged = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("route_recipient")>
<cfif useLakebaseForUpdate_As_Acknowledged>
	<cftry>
		<cfset application.oLakebase.updateRows("route_recipient",
			{
				"recipient_id" = "eq.#request.AccessStructure.User_ID#",
				"route_message_id" = "eq.#FORM.Message_ID#"
			},
			{
				"message_status" = "1",
				"reply_message" = "#FORM.Reply_Message#",
				"reply_date" = "#now()#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdate_As_Acknowledged = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdate_As_Acknowledged>
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
</cfif>
	
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