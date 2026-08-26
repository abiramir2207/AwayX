<cfset useLakebaseForsch_Test = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("sch_test")>
<cfif useLakebaseForsch_Test>
	<cftry>
		<cfset application.oLakebase.insertRow("sch_test", {
			"insert_time_stamp" = "#createodbcdatetime(Now())#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForsch_Test = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForsch_Test>
<CFQUERY NAME="sch_Test" datasource="#application.datasource#">
INSERT INTO sch_Test
(insert_time_stamp)
VALUES
(#createodbcdatetime(Now())#)
</CFQUERY>
</cfif>