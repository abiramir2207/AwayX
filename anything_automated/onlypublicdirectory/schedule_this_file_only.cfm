<!--- 
	Schedule only this file to fire the following system generated emails:
	
	expiring programs
	expired programs
	
 --->
<!------ Get application settings ----->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfset useLakebaseForgetCompany = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("company_main")>
<cfif useLakebaseForgetCompany>
	<cftry>
		<cfset getCompany = application.oLakebase.toQuery(
			application.oLakebase.selectRows("company_main", {
				"deleted" = "eq.0",
				"select" = "company_main_id"
			}), "company_main_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetCompany = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetCompany>
<cfquery name="getCompany" datasource="#application.datasource#">
	select company_main_id
	from company_main
	where deleted = 0
</cfquery>
</cfif>
<CFSET request.AccessStructure.company_main_id = getCompany.company_main_id>
<CFSET request.AccessStructure.user_id = "999-999-999">
<cfset useLakebaseForgetGSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("general_settings")>
<cfif useLakebaseForgetGSettings>
	<cftry>
		<cfset getGSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("general_settings", {
				"select" = "send_daily_expiring_email,send_daily_expired_email,send_daily_active_email,send_daily_aging_billback_email,send_broker_email,use_discount_id,number_of_days_for_summarized_weekly_expiring_email,send_program_starting_email,number_of_days_for_program_start"
			}), "send_daily_expiring_email,send_daily_expired_email,send_daily_active_email,send_daily_aging_billback_email,send_broker_email,use_discount_id,number_of_days_for_summarized_weekly_expiring_email,send_program_starting_email,number_of_days_for_program_start"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetGSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetGSettings>
<cfquery name="getGSettings" datasource="#application.datasource#">
	SELECT
		send_daily_expiring_email,
		send_daily_expired_email,
		send_daily_active_email,
		send_daily_aging_billback_email,
		send_broker_email,
		Use_Discount_ID,
		Number_Of_Days_For_Summarized_Weekly_Expiring_Email,
		Send_Program_Starting_Email,
		Number_Of_Days_For_Program_Start
	FROM
		General_Settings
</cfquery>
</cfif>

<cfset get_profile_settings.approve_freight_programs 	= 0 />
<cfset get_profile_settings.freight_view_create 		= 0 />

<cfset thisGetGSettings = getGSettings />

<cfset userManager = CreateObject("component", "components.user.UserManager") />
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset businessSegmentsOn = 0 />
<cfif businessSegManager.isEnabled()>
	<cfset businessSegmentsOn = 1 />
</cfif>


<!--- active programs --->
<cfif thisGetGSettings.send_daily_active_email EQ 1>
	<cfinclude template="\anything_automated\email\active_programs_emailer.cfm">
</cfif>

<!--- Programs about to start in Pending status --->
<cfif thisGetGSettings.Send_Program_Starting_Email EQ 1>
    <cfinclude template="\anything_automated\email\program_start_pending_emailer.cfm">
</cfif>
<!--- expiring programs --->
<cfif thisGetGSettings.send_daily_expiring_email EQ 1 OR thisGetGSettings.Number_Of_Days_For_Summarized_Weekly_Expiring_Email GTE 1>
	<cfinclude template="\anything_automated\email\expiring_programs_emailer.cfm">
</cfif>

<!--- expired programs --->
<cfif thisGetGSettings.send_daily_expired_email EQ 1>
	<cfinclude template="\anything_automated\email\expired_programs_emailer.cfm">
</cfif>

<!--- aging billbacks--->
<cfif thisGetGSettings.send_daily_aging_billback_email EQ 1>
	<cfinclude template="\anything_automated\email\danger_of_deduction_billbacks_emailer.cfm">
</cfif>

<!--- reminders for programs that have requested approval, but haven't been approved --->
<!---check to see if you should send is in the include--->
	<cfinclude template="\anything_automated\email\rfa_program_reminder_email.cfm">

	<!--- 
			38586: Simplot ENH - Fuel Surcharge Expiring.   CF WORK / Anand Rao / 30-Jul-2013
			-- Send Summarized weekly notification of fuel surcharge expiring
	--->
	<cfinclude template="\anything_automated\email\Program_Freight_Surcharge_Expiry_Notification.cfm">

<!--- retail planner notifications--->
<cfif appSettings.get_Setting('Retail_Planner') EQ '1'>
	<cfinclude template="\anything_automated\email\rfa_planner_program_reminder_email.cfm">
</cfif>	
	