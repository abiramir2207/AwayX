<!---LumpSumComponentProfile.cfc--->
<cfcomponent displayname="LumpSum Component Profile" hint="Component used to handle Profiles for LumpSum Components">

	<cffunction name="get" output="false">

		<cfargument name="compNameId" required="false" default="" />
		<cfargument name="profilesId" required="false" default="" />
		
		<!---get all profiles for this component--->
		<cfquery name="qGetCompProfiles" datasource="#application.datasource#">
			SELECT 	Profiles_ID, Allow_User_To_View
			FROM		Program_LumpSum_Component_Profile
			WHERE	Deleted = 0
			AND		Program_LumpSum_Component_Name_ID = #arguments.compNameId#
			<cfif len(arguments.profilesId)>
			AND 		Profiles_ID = #arguments.profilesId#
			</cfif>
		</cfquery>
		
		<cfreturn qGetCompProfiles/>
		
	</cffunction>
	
	<cffunction name="add" output="false">
	
		<cfargument name="lProfileId" required="false" default="" />
		<cfargument name="compNameId" required="false" default="" />
		<cfargument name="visibility" required="false" default="" />
				
		<!---set deleted to 1 for all comp/profile combination--->
		<cfquery name="qUpdate" datasource="#application.datasource#">
			UPDATE	Program_LumpSum_Component_Profile
			SET			Deleted = 1
			WHERE	Deleted = 0
			AND		Program_LumpSum_Component_Name_ID = #arguments.compNameId#
		</cfquery>

		<!---loop over the list of profile id's and insert for each profile/component combination--->
		<cfloop index="profIndx" list="#arguments.lProfileId#">
			<cfif listfind(visibility, profIndx)>
				<cfset profilevisibility = 1/>
			<cfelse>
				<cfset profilevisibility = 0/>
			</cfif>
			<!---insert for each record--->
			<cfquery name="qInsert" datasource="#application.datasource#">
				INSERT INTO	Program_LumpSum_Component_Profile
										(Profiles_ID, Allow_User_To_View, Program_LumpSum_Component_Name_ID)
				VALUES			(#profIndx#, #profilevisibility#, #arguments.compNameId#)
			</cfquery>

		</cfloop>
		
	</cffunction>

	<cffunction name="getProfiles" output="false">
		
		<!---get all profiles --->
		<cfquery name="qGetProfiles" datasource="#application.datasource#">
			SELECT 	DISTINCT Profiles_ID, Profiles_Desc 
			FROM 		Profiles 
			WHERE 	Deleted = 0
		</cfquery>
		
		<cfreturn qGetProfiles />
		
	</cffunction>
	
	<cffunction name="restrictCompByProfile" output="false">
		
		<cfargument name="compNameId" required="false" default="" />
		
		<cfparam name="bCompHasProfiles" default="0" />
		
		<!---check to see if there are any components by profile --->
		<cfset useLakebaseForqCheckCompProfile = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_lumpsum_component_profile")>
<cfif useLakebaseForqCheckCompProfile>
	<cftry>
		<cfset qCheckCompProfile = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_lumpsum_component_profile", {
				"deleted" = "eq.0",
				"program_lumpsum_component_name_id" = "eq.#arguments.compNameId#",
				"select" = "program_lumpsum_component_profile_id"
			}), "program_lumpsum_component_profile_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckCompProfile = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckCompProfile>
<cfquery name="qCheckCompProfile" datasource="#application.datasource#">
		
			SELECT 	Program_LumpSum_Component_Profile_ID
			FROM 		Program_LumpSum_Component_Profile
			WHERE	Deleted = 0
			AND		Program_LumpSum_Component_Name_ID = #arguments.compNameId#
			
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
			SELECT DISTINCT  PLCP.Program_LumpSum_Component_Name_ID
			FROM 	Program_Lump_Sum_Name PLCN
			INNER JOIN Program_LumpSum_Component_Profile PLCP 
			ON			PLCP.Program_LumpSum_Component_Name_ID = PLCN.Program_Lump_Sum_Name_ID
			WHERE 	PLCN.Deleted = 0
			AND		PLCN.Active = 1
		</cfquery>
		
		<!---now loop over and check to see if any comps have profile restrictions--->
		<cfloop query="qGetComps">
		
			<!---if the comp has a restriction check to see if the profile is restricted--->
			<!--- <cfif this.restrictCompByProfile(Program_LumpSum_Component_Name_ID)> --->
			
				<!---it the profile isn't in the list then it's restricted so append the id to the list to return--->
				<cfif ListFindNoCase(this.get(Program_LumpSum_Component_Name_ID).Profiles_ID, arguments.profileId)>
					<cfset lCompIdsToFilter = ListAppend(lCompIdsToFIlter, Program_LumpSum_Component_Name_ID) />
				</cfif>
				
			<!--- </cfif> --->

		</cfloop>
		
		<cfreturn lCompIdsToFilter />
		
	</cffunction>
	
</cfcomponent>