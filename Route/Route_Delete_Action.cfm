<!------
Route_Close_Action.cfm
----->

<cfparam name="FORM.Document_ID" 	default="">
<cfparam name="FORM.Document_Type" 	default=0>
<cfparam name="FORM.Route_Recipient_ID" 	default="">

<CFLOOP LIST="#FORM.Route_Recipient_ID#" INDEX="this_Route_Recipient_ID">
	<CFOUTPUT>
	<cfset useLakebaseForUpdate_As_Acknowledged = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("route_recipient")>
<cfif useLakebaseForUpdate_As_Acknowledged>
	<cftry>
		<cfset application.oLakebase.updateRows("route_recipient",
			{
				"route_recipient_id" = "eq.#this_Route_Recipient_ID#",
				"route_message_id" = "eq.#FORM.Message_ID#"
			},
			{
				"deleted" = "1"
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
			Deleted = 1
		WHERE
			Route_Recipient.Route_Recipient_ID = #this_Route_Recipient_ID#
			AND
			Route_Recipient.Route_Message_ID = #FORM.Message_ID#
	</CFQUERY>
</cfif>
	
		</CFOUTPUT>
</CFLOOP>

	<CFOUTPUT>
	
	<FORM ACTION="/Route/Route_Sent_Message.cfm" METHOD="post" NAME="frm_show_Message" ID="frm_show_Message">
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
