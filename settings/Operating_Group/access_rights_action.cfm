
<cfset operatingGroupManager 			= CreateObject("component", "components.Operating_Group.OperatingGroupManager").init() />
<cfset profileRestrictionLevel 			= operatingGroupManager.getProfileRestrictionLevel() />
<cfset profileRestrictionLevelLabel 	= operatingGroupManager.getLabel(profileRestrictionLevel) />


<cfset operatingGroupManager.deleteOperatingGroupProfileSettings() />

	<!--- Dev Note: drachala; D28010: Profile Setting modifications 
				  what For: Check weather user selected any profiles if so we are passing argument into getprofiles query.	--->

<cfset qOperatingGroupProfileSettings 	= operatingGroupManager.getOperatingGroupProfileSettings(level = profileRestrictionLevel, profile_id = profile_id,UserSettingPanel=UserSetting.Settings_Panel)>

					<!--- End Dev Note: drachala; D28010: Profile Setting modifications  ---> 

<cfoutput query="qOperatingGroupProfileSettings" group="Operating_Group_ID">
	<!------ <hr>#Operating_Group_ID# #Operating_Group_Desc# ----->
	<cfoutput>
	<cfset thisFieldName = "Operating_Group_Profile_#Profiles_ID#_#Operating_Group_ID#" />
	<cfparam name="form.#thisFieldName#" default="0">
	<cfif Evaluate("form.#thisFieldName#") EQ 1>		
		<cfset operatingGroupManager.addOperatingGroupProfileSettings(Operating_Group_ID, Profiles_ID) />		
	</cfif>
	</cfoutput>
</cfoutput>
<!------ <cfabort> ----->