<!------ Track_Session_ID.cfm ----->
<cfparam name="attributes.id" 	default="">

<cfquery name="" datasource="#application.datasource#">
	INSERT INTO Track_Session (User_ID, Session_ID, IP, Location)
	VALUES ('#attributes.id#', '#Session.SessionID#', '#CGI.Remote_Addr#', '#CGI.SCRIPT_NAME#')
</cfquery>