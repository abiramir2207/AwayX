<!-----------------------------------------------------------------------------

FILE NAME:		showEmailMessage.cfm
DESCRIPTION:
CREATED BY:		Anand Rao/16-Jun-2016
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

			Anand Rao	16-Jun-2016	Created

------------------------------------------------------------------------------>

<cfparam name="URL.Message_Log_ID" default="">

<cfoutput>
	<cfset useLakebaseForqgetEmailMessage = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("message_log")>
<cfif useLakebaseForqgetEmailMessage>
	<cftry>
		<cfset qgetEmailMessage = application.oLakebase.toQuery(
			application.oLakebase.selectRows("message_log", {
				"message_log_id" = "eq.#URL.Message_Log_ID#",
				"select" = "message_log_id,message_type_id,message_to,message_from,message_subject,message,message_generated_by_id,app_area_id,user_id,deleted,created_date,app_area_identifier,message_cc,sent_date,app_area_sub_identifier"
			}), "message_log_id,message_type_id,message_to,message_from,message_subject,message,message_generated_by_id,app_area_id,user_id,deleted,created_date,app_area_identifier,message_cc,sent_date,app_area_sub_identifier"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetEmailMessage = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetEmailMessage>
<cfquery name="qgetEmailMessage" datasource="#application.datasource#">
		SELECT 
			Message_Log_Id,	
			Message_Type_Id,	
			Message_To,
			Message_From,	
			Message_Subject,	
			Message,	
			Message_Generated_By_ID,	
			App_Area_ID,	
			User_Id,
			Deleted,	
			Created_Date,	
			App_Area_Identifier,	
			Message_CC,	
			Sent_Date,	
			App_Area_Sub_Identifier
	 	FROM 
			Message_Log
		WHERE Message_Log_ID = #URL.Message_Log_ID#
	</cfquery>
</cfif>	

<CFSET URL.PageTitle="Email Message">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<strong>Message:</strong>
<br>
<br>
#qgetEmailMessage.Message#
</cfoutput>	
<br>
<br>
<div align="center">
	<input type="button" onclick="javascript:window.close();" title="Close window" value="Close window" style="align:center;">
</div>

