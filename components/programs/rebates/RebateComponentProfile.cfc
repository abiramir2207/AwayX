<!---RebateComponentProfile.cfc--->
<cfcomponent displayname="Rebate Component Profile" hint="Component used to handle Profiles for Rebate Components">

	<cffunction name="get" output="false">

		<cfargument name="compNameId" required="false" default="" />
		<cfargument name="profilesId" required="false" default="" />
		
		<!---get all profiles for this component--->
		<cfquery name="qGetCompProfiles" datasource="#application.datasource#">
			SELECT 	Profiles_ID, Allow_User_To_View
			FROM		Program_Rebates_Component_Profile
			WHERE	Deleted = 0
			AND		Program_Rebates_Component_Name_ID = #arguments.compNameId#
			<cfif len(arguments.profilesId)>
			AND 		Profiles_ID = #arguments.profilesId#
			</cfif>
		</cfquery>
		
		<cfreturn qGetCompProfiles>
		
	</cffunction>
	
	<cffunction name="add" output="false">
	
		<cfargument name="lProfileId" required="false" default="" />
		<cfargument name="compNameId" required="false" default="" />
		<cfargument name="visibility" required="false" default="" />
		
		<!---set deleted to 1 for all comp/profile combination--->
		<cfquery name="qUpdate" datasource="#application.datasource#">
			UPDATE	Program_Rebates_Component_Profile
			SET		Deleted = 1
			WHERE	Deleted = 0
			AND		Program_Rebates_Component_Name_ID = #arguments.compNameId#
		</cfquery>

		<!---loop over the list of profile id's and insert for each profile/component combination--->
		<cfloop index="profIndx" list="#arguments.lProfileId#">
			<cfif listfind(visibility, profIndx)>
				<cfset profilevisibility = 1/>
			<cfelse>
				<cfset profilevisibility = 0/>
			</cfif>
			<!---insert for each record--->
			<cfset useLakebaseForqInsert = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_rebates_component_profile")>
<cfif useLakebaseForqInsert>
	<cftry>
		<cfset application.oLakebase.insertRow("program_rebates_component_profile", {
			"profiles_id" = "#profIndx#",
			"allow_user_to_view" = "#profilevisibility#",
			"program_rebates_component_name_id" = "#arguments.compNameId#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqInsert = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqInsert>
<cfquery name="qInsert" datasource="#application.datasource#">
				INSERT INTO	Program_Rebates_Component_Profile
										(Profiles_ID, Allow_User_To_View, Program_Rebates_Component_Name_ID)
				VALUES			(#profIndx#, #profilevisibility#, #arguments.compNameId#)
			</cfquery>
</cfif>

		</cfloop>
		
	</cffunction>

	<cffunction name="getProfiles" output="false">
		
		<!---get all profiles --->
		<cfset useLakebaseForqGetProfiles = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("profiles")>
<cfif useLakebaseForqGetProfiles>
	<cftry>
		<cfset qGetProfiles = application.oLakebase.toQuery(
			application.oLakebase.selectRows("profiles", {
				"deleted" = "eq.0",
				"select" = "profiles_id,profiles_desc"
			}), "profiles_id,profiles_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetProfiles = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetProfiles>
<cfquery name="qGetProfiles" datasource="#application.datasource#">
			SELECT 	DISTINCT Profiles_ID, 
					Profiles_Desc 
			FROM 	Profiles 
			WHERE 	Deleted = 0
		</cfquery>
</cfif>
		
		<cfreturn qGetProfiles />
		
	</cffunction>
	
	<cffunction name="restrictCompByProfile" output="false">
		
		<cfargument name="compNameId" required="false" default="" />
		
		<cfparam name="bCompHasProfiles" default="0" />
		
		<!---check to see if there are any components by profile --->
		<cfset useLakebaseForqCheckCompProfile = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_rebates_component_profile")>
<cfif useLakebaseForqCheckCompProfile>
	<cftry>
		<cfset qCheckCompProfile = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_rebates_component_profile", {
				"deleted" = "eq.0",
				"program_rebates_component_name_id" = "eq.#arguments.compNameId#",
				"select" = "program_rebates_component_profile_id"
			}), "program_rebates_component_profile_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckCompProfile = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckCompProfile>
<cfquery name="qCheckCompProfile" datasource="#application.datasource#">
		
			SELECT 	Program_Rebates_Component_Profile_ID
			FROM 	Program_Rebates_Component_Profile
			WHERE	Deleted = 0
			AND		Program_Rebates_Component_Name_ID = #arguments.compNameId#
			
		</cfquery>
</cfif>
		
		<!---if we get a recordcount back then we know we have profiles--->
		<cfif qCheckCompProfile.RecordCount>
			<cfset bCompHasProfiles = 1 />
		</cfif>
		
		<cfreturn bCompHasProfiles />
		
	</cffunction>
	
	<cffunction name="compIdsToFilter" output="false">
		
		<cfargument name="profileId" required="false" default="" />
		
		<cfparam name="lCompIdsToFilter" default="" />
		
		<!---get active components --->
		<cfquery name="qGetComps" datasource="#application.datasource#">
			SELECT DISTINCT  PRCN.Program_Rebates_Component_Name_ID 
			FROM 	Program_Rebates_Component_Name PRCN
			INNER JOIN Program_Rebates_Component_Profile PRCP ON
				PRCP.Program_Rebates_Component_Name_ID = PRCN.Program_Rebates_Component_Name_ID
			WHERE 	PRCN.Deleted = 0
			AND		PRCN.Active = 1
		</cfquery>
		
		<!---now loop over and check to see if any comps have profile restrictions--->
		<cfloop query="qGetComps">
		
		<cfset lProfileInfo = this.get(Program_Rebates_Component_Name_ID)>
		<cfset ProfileIds = valuelist(lProfileInfo.Profiles_ID)>
			<!---if the comp has a restriction check to see if the profile is restricted--->
			<!--- <cfif this.restrictCompByProfile(Program_Rebates_Component_Name_ID)> --->
			
				<!---it the profile isn't in the list then it's restricted so append the id to the list to return--->
				<cfif ListFindNoCase(ProfileIds, arguments.profileId)>
					<cfset lCompIdsToFilter = ListAppend(lCompIdsToFIlter, Program_Rebates_Component_Name_ID) />
				</cfif>
				
			<!--- </cfif> --->

		</cfloop>
		
		<cfreturn lCompIdsToFilter />
		
	</cffunction>
	
</cfcomponent>