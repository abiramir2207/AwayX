<!---  
       Name:          BusinessConsiderationsReminder.cfc              
       Copyright:     Copyright (c) 2006 Blacksmith Applications, Inc.       
       Created Date:  10/30/2006
       Created By:    Clarence Morse
       Description:   Primary DAO for business consideration reminders.
--->

<cfcomponent displayname="BusinessConsiderationsReminder" hint="Contains Functions for Accessing Business Consideration Reminders">

	<cffunction name="get" access="public" hint="returns Business Considerations Reminders" returntype="query">
		<cfset useLakebaseForqGetBizConReminders = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("business_considerations_reminders")>
<cfif useLakebaseForqGetBizConReminders>
	<cftry>
		<cfset qGetBizConReminders = application.oLakebase.toQuery(
			application.oLakebase.selectRows("business_considerations_reminders", {
				"limit" = "1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetBizConReminders = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetBizConReminders>
<cfquery name="qGetBizConReminders" datasource="#application.datasource#">
			SELECT TOP 1 * from business_considerations_reminders
		</cfquery>
</cfif>
		
		<cfreturn qGetBizConReminders />
	</cffunction>
	
	<cffunction name="set" access="public" hint="Sets Business Considerations Reminders" returntype="any">
		<cfargument name="business_considerations_reminders_on" required="yes" type="numeric">
		<cfargument name="last_saved_by" required="yes" type="string">
		<cfargument name="business_considerations_reminders_txt" required="No" type="string" default="">
	
		<cfquery name="setReminders" datasource="#application.datasource#">
		IF ((SELECT count(*) FROM business_considerations_reminders) > 0 )
			update 	business_considerations_reminders
			set 	business_considerations_reminders_on = '#arguments.business_considerations_reminders_on#',
				last_saved_by = '#arguments.last_saved_by#',
				business_considerations_reminders_txt = '#arguments.business_considerations_reminders_txt#',		
				last_updated_on = getdate()
		ELSE
			INSERT business_considerations_reminders (business_considerations_reminders_on,last_saved_by,business_considerations_reminders_txt,last_updated_on)
			VALUES ('#arguments.business_considerations_reminders_on#','#arguments.last_saved_by#','#arguments.business_considerations_reminders_txt#',getdate())
		</cfquery>
		
		<cfreturn />
	</cffunction>

</cfcomponent>