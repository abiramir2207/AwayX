<cfset useLakebaseForIaASupervisor = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_analyst")>
<cfif useLakebaseForIaASupervisor>
	<cftry>
		<cfset IaASupervisor = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_analyst", {
				"analyst_user_id" = "eq.#request.AccessStructure.User_ID#",
				"is_supervisor" = "eq.1",
				"supervisor_id" = "is.null",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForIaASupervisor = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForIaASupervisor>
<CFQUERY NAME="IaASupervisor" DATASOURCE="#Application.Datasource#">
	SELECT * FROM DD_Analyst 	
	WHERE 	Analyst_User_ID = '#request.AccessStructure.User_ID#' AND
			Is_Supervisor = 1 AND Supervisor_ID IS NULL AND 
			(LEN(LTRIM(RTRIM(Supervisor_ID))) = 0 OR LEN(LTRIM(RTRIM(Supervisor_ID))) IS NULL) AND 
			Deleted = 0 
</CFQUERY>
</cfif>
<CFIF IaASupervisor.RecordCount GT 0>
	<CFQUERY NAME="GetAnalystUnderMe" DATASOURCE="#Application.Datasource#">
		SELECT * FROM DD_Analyst 
		WHERE 	Supervisor_ID = '#request.AccessStructure.User_ID#' <CFIF IaASupervisor.Is_Default_Supervisor EQ 1>OR (LEN(LTRIM(RTRIM(Supervisor_ID))) = 0 OR LEN(LTRIM(RTRIM(Supervisor_ID))) IS NULL)</CFIF> AND
				Is_Supervisor = 0 AND
				Deleted = 0
	</CFQUERY>
	<CFSET AnalystUnderMe_List = VALUELIST(GetAnalystUnderMe.Analyst_User_ID)>
	<CFSET AnalystUnderMe_List = ListAppend(AnalystUnderMe_List, request.AccessStructure.User_ID)>
</CFIF>

<CFSET UserIsASupervisor = 0>
<CFIF IaASupervisor.RecordCount GT 0 AND GetAnalystUnderMe.RecordCount GT 0>
	<CFSET UserIsASupervisor = 1>
</CFIF>

<cfset useLakebaseForHQPosition = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("user_positions")>
<cfif useLakebaseForHQPosition>
	<cftry>
		<cfset HQPosition = application.oLakebase.toQuery(
			application.oLakebase.selectRows("user_positions", {
				"select" = "user_positions_id",
				"service_zone_id" = "is.null",
				"service_region_id" = "is.null",
				"service_market_id" = "is.null",
				"deleted" = "eq.0"
			}),
			"user_positions_id"
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForHQPosition = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForHQPosition>
<CFQUERY NAME="HQPosition" DATASOURCE="#Application.Datasource#">
	SELECT 	User_Positions_ID 
	FROM 	User_Positions 
	WHERE 	Service_Zone_ID IS NULL AND 
			Service_Region_ID IS NULL AND 
			Service_Market_ID IS NULL AND 
			Deleted = 0
</CFQUERY>
</cfif>