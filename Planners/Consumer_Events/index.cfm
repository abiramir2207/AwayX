<!-------------------------------------------------------------------------------------------------------------------------------
	   File Name:  Planners/Consumer_Events/index.cfm
	Created Date:  2017 October
	  Created By:  Chris Nguyen
	 Description:
--------------------------------------------------------------------------------------------------------------------------------->

<cfquery name="qTypes" datasource="#application.datasource#">
	SELECT 1
	  FROM Planner_Event_Type
	  WHERE Deleted = 0
</cfquery>
<cfset request.script_name = ( qTypes.recordCount ? "/planners/consumer_events/events/list.cfm" : "/planners/consumer_events/types/list.cfm" )>
<cfoutput><cfinclude template="#request.script_name#"></cfoutput>

