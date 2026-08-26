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
				"message_status" = "2",
				"close_date" = "#now()#"
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
			Message_Status = 2,
			Close_Date = GetDate()
		WHERE
			Route_Recipient.Route_Recipient_ID = #this_Route_Recipient_ID#
			AND
			Route_Recipient.Route_Message_ID = #FORM.Message_ID#
	</CFQUERY>
</cfif>
	
		</CFOUTPUT>
</CFLOOP>

	<!------
<CFSET redirect_URL="">
	<CFSWITCH EXPRESSION="#FORM.Document_Type#">
		<CFCASE VALUE="1">
			<CFIF Len(FORM.Document_ID) GT 0>
				<CFSET redirect_URL="/Billbacks/common/bb_route_sent.cfm?BBID=#FORM.Document_ID#">
			<CFELSE>
				<CFSET redirect_URL="/Route/Sent.cfm">
			</CFIF>
		</CFCASE>
		<CFDEFAULTCASE>
			<CFSET redirect_URL="/Manufacturers/Home.cfm">
		</CFDEFAULTCASE>
	</CFSWITCH>

	<CFLOCATION URL="#redirect_URL#" ADDTOKEN="No">

	----->
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
