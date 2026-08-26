<!--- 
##  Action form for Settings_Frame_mainWindow.cfm
##	Updates access levels for the settings panel
##
 --->

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<!--- SAVE UPDATED BY TO SEE WHO LAST UPDATED THE CONTROL PANEL ACCESS LEVELS --->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get(0) />
<cfset appSettings.setUpdatedBy(request.AccessStructure.User_ID) />
<cfset genSettingsManager.save(14) />

	<cfquery name="qDelSPAModule" datasource="#application.datasource#">
		DELETE FROM Settings_Panel_Access_Modules_Profiles
		WHERE Profiles_Id IN (#listQualify(form.profile_id,"'")#)
	</cfquery>

	<cfloop list="#form.fieldnames#" index="fName">
		<cfquery name="qGetSPAModule" datasource="#application.datasource#">
			SELECT Settings_Panel_Access_Modules_ID 
			FROM Settings_Panel_Access_Modules
			WHERE Module_name = '#fName#'
		</cfquery>

		<cfset SettingsPanelAccessModulesID = qGetSPAModule.Settings_Panel_Access_Modules_ID>
		
		<cfif qGetSPAModule.recordcount gt 0>
			<cfset status = form[fname]>	
			<cfif status eq 1>
				<cfloop list="#form.profile_id#" index="i">
					<cfset useLakebaseForqInsSPAModule = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("settings_panel_access_modules_profiles")>
<cfif useLakebaseForqInsSPAModule>
	<cftry>
		<cfset application.oLakebase.insertRow("settings_panel_access_modules_profiles", {
			"settings_panel_access_modules_id" = "#SettingsPanelAccessModulesID#",
			"profiles_id" = "#i#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqInsSPAModule = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqInsSPAModule>
<cfquery name="qInsSPAModule" datasource="#application.datasource#">
						INSERT INTO Settings_Panel_Access_Modules_Profiles(Settings_Panel_Access_Modules_ID,Profiles_ID)
						VALUES('#SettingsPanelAccessModulesID#','#i#')
					</cfquery>
</cfif>
				</cfloop>
			</cfif>
		</cfif>
	</cfloop>

<!--- When a user edits access rights for a specific profile from the profiles page, then after clicking on "update access rights", the user should go back
to the edit page and should see the saved options for the same user.
--->
<cfset Url.maint = 1>
<cfset Url.profileId = form.Original_profileId>
<cfset Url.AdminUserFromProfilesPage = 1>
<cfinclude template="settings_frame_mainwindow.cfm">
