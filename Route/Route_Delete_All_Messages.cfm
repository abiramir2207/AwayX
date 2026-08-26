<!------
Route_Close_Action.cfm
----->

<cfparam name="FORM.Document_ID" 	default="">
<cfparam name="FORM.Document_Type" 	default=0>
<cfparam name="FORM.Message_ID" 	default="">

<CFLOOP LIST="#FORM.Message_ID#" INDEX="this_Message_ID">
	<CFOUTPUT>
	<cfset useLakebaseForUpdate_As_Closed = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("route_message")>
<cfif useLakebaseForUpdate_As_Closed>
	<cftry>
		<cfset application.oLakebase.updateRows("route_message",
			{
				"route_message_id" = "eq.#this_Message_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdate_As_Closed = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdate_As_Closed>
<CFQUERY NAME="Update_As_Closed" DATASOURCE="#application.datasource#">
		UPDATE	Route_Message
		SET
			Deleted = 1
		WHERE
			Route_Message.Route_Message_ID = #this_Message_ID#
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
	
	<FORM ACTION="#FORM.redirect_URL#" METHOD="post" NAME="frm_show_Message" ID="frm_show_Message">
	<INPUT NAME="Document_ID" TYPE="hidden" VALUE="#FORM.Document_ID#">
	<INPUT NAME="Document_Type" TYPE="hidden" VALUE="#FORM.Document_Type#">
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
