<!-----------------------------------------------------------------------------

FILE NAME:		showEmailMessage.cfm
DESCRIPTION:
CREATED BY:		Anand Rao/16-Jun-2016
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

			Anand Rao	16-Jun-2016	Created

------------------------------------------------------------------------------>

<cfparam name="URL.Message_Log_ID" default="">

<cfoutput>
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

