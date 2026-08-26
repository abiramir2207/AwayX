<!---RebateComponentProfile.cfc--->
<cfcomponent displayname="Rebate Component Profile" hint="Component used to handle Profiles for Rebate Components">

	<cffunction name="get" output="false">

		<cfargument name="compNameId" required="false" default="" />
		<cfargument name="profilesId" required="false" default="" />
				
		<!---get all profiles for this component--->
		<cfquery name="qGetCompProfiles" datasource="#application.datasource#">
			SELECT 	Profiles_ID, Allow_User_To_View
			FROM		Program_Fixed_Component_Profile
			WHERE	Deleted = 0
			AND		Program_Fixed_Component_Name_ID = '#arguments.compNameId#'
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
			UPDATE	Program_Fixed_Component_Profile
			SET		Deleted = 1
			WHERE	Deleted = 0
			AND		Program_Fixed_Component_Name_ID = '#arguments.compNameId#'
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
				INSERT INTO	Program_Fixed_Component_Profile
										(Profiles_ID, Allow_User_To_View, Program_Fixed_Component_Name_ID)
				VALUES			('#profIndx#', #profilevisibility#, '#arguments.compNameId#')
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
		<cfquery name="qCheckCompProfile" datasource="#application.datasource#">
		
			SELECT 	Program_Fixed_Component_Profile_ID
			FROM 	Program_Fixed_Component_Profile
			WHERE	Deleted = 0
			AND		Program_Fixed_Component_Name_ID = #arguments.compNameId#
			
		</cfquery>
		
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
			SELECT 	Program_Fixed_Component_Name_ID
			FROM 	Program_Fixed_Component_Name
			WHERE 	Deleted = 0
			AND		Active = 1
		</cfquery>
		
		<!---now loop over and check to see if any comps have profile restrictions--->
		<cfloop query="qGetComps">
		
			<!---if the comp has a restriction check to see if the profile is restricted--->
			<cfif this.restrictCompByProfile(Program_Fixed_Component_Name_ID)>
			<cfset q = this.get(Program_Fixed_Component_Name_ID)/><!--- D45239 recent update changed the return type of get() from a list to a query --->
			<cfset profileList = ValueList(q.Profiles_ID) />
				<!---it the profile isn't in the list then it's restricted so append the id to the list to return--->
				<cfif ListFindNoCase(profileList, arguments.profileId)>
					<cfset lCompIdsToFilter = ListAppend(lCompIdsToFIlter, Program_Fixed_Component_Name_ID) />
				</cfif>
				
			</cfif>

		</cfloop>
		
		<cfreturn lCompIdsToFilter />
		
	</cffunction>
	
</cfcomponent>