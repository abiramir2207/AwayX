
<cfparam name="PunchID"	default="">
<cfparam name="WR_ID"	default="0">
<cfoutput>
<cfset useLakebaseForUpdate_WR = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("work_request")>
<cfif useLakebaseForUpdate_WR>
	<cftry>
		<cfset application.oLakebase.updateRows("work_request",
			{
				"work_request_id" = "eq.#WR_ID#",
				"ba_ticket_number" = "is.null"
			},
			{
				"ba_ticket_number" = "#PunchID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdate_WR = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdate_WR>
<cfquery name="Update_WR" datasource="#application.datasource#">
	update work_request
	set BA_Ticket_Number = #PunchID#
	where work_request_ID = #WR_ID#
	and BA_Ticket_Number is NULL
</cfquery>
</cfif>
update work_request<br>
set BA_Ticket_Number = #PunchID#<br>
where work_request_ID = #WR_ID#<br>
and BA_Ticket_Number is NULL<br>
</cfoutput>