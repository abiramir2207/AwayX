<!---
##  Action form for index_main.cfm
##	Updates report access levels for the Reports Central main page.
##
--->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<cfif Get_Profile_Settings.Reports_Access_Level GTE 4> <!--- only Admin user make updates --->
	<cfloop list="#form.fieldnames#" index="fName">
	
			<cfif fName NEQ "submit">
				<cfset useLakebaseForqGetRCAModule = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("report_central_access")>
<cfif useLakebaseForqGetRCAModule>
	<cftry>
		<cfset qGetRCAModule = application.oLakebase.toQuery(
			application.oLakebase.selectRows("report_central_access", {
				"report_id" = "eq.#fName#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetRCAModule = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetRCAModule>
<cfquery name="qGetRCAModule" datasource="#application.datasource#">
					SELECT *  
					FROM Report_Central_Access
					WHERE report_id = '#fName#'
				</cfquery>
</cfif>
				
				<cfif qGetRCAModule.recordcount gt 0>
				    <cfset fVar = "form."&fName>
				    <cfset level = evaluate(fVar)>
					<cfset useLakebaseForqUpdRCAModule = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("report_central_access")>
<cfif useLakebaseForqUpdRCAModule>
	<cftry>
		<cfset application.oLakebase.updateRows("report_central_access",
			{
				"report_id" = "eq.#fName#"
			},
			{
				"level_code" = "#level#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqUpdRCAModule = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqUpdRCAModule>
<cfquery name="qUpdRCAModule" datasource="#application.datasource#">
						Update Report_Central_Access
						set level_code = #level#
						WHERE report_id = '#fName#'
					</cfquery>
</cfif>
				
				</cfif>
			</cfif>
	
	</cfloop>
</cfif>

<p><br /><br /><a href="index_main.cfm">The settings have been saved.</a></p>

<cflocation url="index_main.cfm">
