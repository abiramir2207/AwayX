<cfset useLakebaseForgetExistingWDDXPacketLocations = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("session_variable_storage")>
<cfif useLakebaseForgetExistingWDDXPacketLocations>
	<cftry>
		<cfset getExistingWDDXPacketLocations = application.oLakebase.toQuery(
			application.oLakebase.selectRows("session_variable_storage", {
				"user_id" = "eq.#request.AccessStructure.User_ID#",
				"order" = "timestamp_of_save.desc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetExistingWDDXPacketLocations = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetExistingWDDXPacketLocations>
<cfquery name="getExistingWDDXPacketLocations" datasource="#application.datasource#" maxrows="1">
	SELECT *
	FROM Session_Variable_Storage
	WHERE User_Id = '#request.AccessStructure.User_ID#'
	ORDER BY Timestamp_Of_Save DESC
</cfquery>
</cfif>

<cfif getExistingWDDXPacketLocations.recordcount EQ 1>
	<cffile action="READ" file="#getExistingWDDXPacketLocations.WDDXPacket_File_Location#" variable="SerializedWDDXPacket">

<cfwddx action="WDDX2CFML" input="#SerializedWDDXPacket#" output="NewSessionStucture">

<CFIF isdefined("Session.Programs")>HELLO</CFIF>
<cfoutput>#NewSessionStucture.SESSIONID# - #Session.SessionID#</cfoutput>
</cfif>
