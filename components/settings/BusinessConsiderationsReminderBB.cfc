
<cfcomponent displayname="BusinessConsiderationsReminderBB" hint="Contains Functions for Accessing Business Consideration Reminders">

	<cffunction name="get" access="public" hint="returns Business Considerations Reminders" returntype="query">
		<cfquery name="qGetBizConReminders" datasource="#application.datasource#">
			SELECT TOP 1 * from BB_business_considerations_reminders
		</cfquery>
		
		<cfreturn qGetBizConReminders />
	</cffunction>
	
	<cffunction name="set" access="public" hint="Sets Business Considerations Reminders" returntype="any">
		<cfargument name="business_considerations_reminders_on" required="yes" type="numeric">
		<cfargument name="last_saved_by" required="yes" type="string">
		<cfargument name="business_considerations_reminders_txt" required="No" type="string" default="">
		
		<cfquery name="setReminders" datasource="#application.datasource#">
		IF ((SELECT count(*) FROM BB_business_considerations_reminders) > 0 )
			update BB_business_considerations_reminders
			set business_considerations_reminders_on = '#arguments.business_considerations_reminders_on#',
				last_saved_by = '#arguments.last_saved_by#',
				business_considerations_reminders_txt = '#arguments.business_considerations_reminders_txt#',		
				last_updated_on = getdate()
		ELSE
			INSERT BB_business_considerations_reminders (business_considerations_reminders_on,last_saved_by,business_considerations_reminders_txt,last_updated_on)
			VALUES ('#arguments.business_considerations_reminders_on#','#arguments.last_saved_by#','#arguments.business_considerations_reminders_txt#',getdate())
		</cfquery>

		<cfreturn />
	</cffunction>

</cfcomponent>