
<cfparam name="PunchID"	default="">
<cfparam name="WR_ID"	default="0">
<cfoutput>
<cfquery name="Update_WR" datasource="#application.datasource#">
	update work_request
	set BA_Ticket_Number = #PunchID#
	where work_request_ID = #WR_ID#
	and BA_Ticket_Number is NULL
</cfquery>
update work_request<br>
set BA_Ticket_Number = #PunchID#<br>
where work_request_ID = #WR_ID#<br>
and BA_Ticket_Number is NULL<br>
</cfoutput>