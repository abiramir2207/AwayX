<!-------------------------------------------------------------------------------------------------------------------------------
	   File Name:  Planners/Consumer_Events/index.cfm
	Created Date:  2017 October
	  Created By:  Chris Nguyen
	 Description:
--------------------------------------------------------------------------------------------------------------------------------->

<cfset useLakebaseForqTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("planner_event_type")>
<cfif useLakebaseForqTypes>
	<cftry>
		<cfset qTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("planner_event_type", {
				"deleted" = "eq.0",
				"select" = "1"
			}), "1"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqTypes>
<cfquery name="qTypes" datasource="#application.datasource#">
	SELECT 1
	  FROM Planner_Event_Type
	  WHERE Deleted = 0
</cfquery>
</cfif>
<cfset request.script_name = ( qTypes.recordCount ? "/planners/consumer_events/events/list.cfm" : "/planners/consumer_events/types/list.cfm" )>
<cfoutput><cfinclude template="#request.script_name#"></cfoutput>

