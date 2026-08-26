<cfset finalTime = "">
<cfset autoemailflag = 1>
<cfif form.i_agree_status EQ 1>
	<cfset finalTime = createodbctime(timeformat("#form.sum_email_time_hour#:#form.sum_email_time_minute# #form.sum_email_time_ampm#", 'hh:mm:ss tt'))>
	<cfschedule action = "update"
	  task = "NOI Daily Email - #application.companyname#"
	  operation = "HTTPRequest"
	  startDate = "#DateAdd('d',-1,Now())#"
	  startTime = "#finalTime#"
	  url = "http://#cgi.http_host#/Scheduled/NOI_Emailer.cfm"
	  publish = "No"
	  interval = "Daily">
<cfelse>
	<cfschedule action = "delete" task = "NOI Daily Email - #application.companyname#">
</cfif>

<cfquery name="saveChanges" datasource="#application.datasource#">
	UPDATE general_Settings
	SET 
		USDANOI_I_Agree_Enabled = '#form.i_agree_status#',
		<cfif len(trim(finalTime)) GT 0>
			USDANOI_Summary_Time = #finalTime#,
		</cfif>
		USDANOI_Summary_Email	=	'#form.Recipient_Email_Address#'

</cfquery>

<cflocation url="index.cfm">