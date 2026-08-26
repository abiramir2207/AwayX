<!---
##  Action form for index_main.cfm
##	Updates report access levels for the Reports Central main page.
##
--->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<cfif Get_Profile_Settings.Reports_Access_Level GTE 4> <!--- only Admin user make updates --->
	<cfloop list="#form.fieldnames#" index="fName">
	
			<cfif fName NEQ "submit">
				<cfquery name="qGetRCAModule" datasource="#application.datasource#">
					SELECT *  
					FROM Report_Central_Access
					WHERE report_id = '#fName#'
				</cfquery>
				
				<cfif qGetRCAModule.recordcount gt 0>
				    <cfset fVar = "form."&fName>
				    <cfset level = evaluate(fVar)>
					<cfquery name="qUpdRCAModule" datasource="#application.datasource#">
						Update Report_Central_Access
						set level_code = #level#
						WHERE report_id = '#fName#'
					</cfquery>
				
				</cfif>
			</cfif>
	
	</cfloop>
</cfif>

<p><br /><br /><a href="index_main.cfm">The settings have been saved.</a></p>

<cflocation url="index_main.cfm">
