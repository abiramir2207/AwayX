<cfcomponent displayname="OperatingGroupManager" hint="Operating Group Manager" extends="components.Base">

	<cfset this.appSettings = "" />
	<cfset this.operatingGroupOnVar = 0 />

	<cffunction name="init" returntype="components.Operating_Group.OperatingGroupManager" output="false">
		<cfset this.operatingGroupOnVar = application.oApplicationAppSettingsManager.getApplicationAppSettings().getOperatingGroupOn() />
		<cfreturn this />
	</cffunction>
	
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Operating Group Settings ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->

	<cffunction name="operatingGroupOn" output="false" returntype="numeric">
		
		<cfreturn this.operatingGroupOnVar />
		
	</cffunction>
	
	<cffunction name="getParentLevelId" output="false" returntype="numeric">
		<cfargument name="level" type="numeric" required="true" />
		
		<cfreturn arguments.level - 1 />
		
	</cffunction>
	
	<cffunction name="applyAllowanceCode" output="false" returntype="numeric">
		<cfargument name="level" type="numeric" required="true" />	
		
		<cfif arguments.level EQ getAllowanceCodeLevel()>
			<cfreturn 1 />
		</cfif>
		
		<cfreturn 0 />
		
	</cffunction>
	
	<cffunction name="getProfileRestrictionLevel" output="false" returntype="numeric">
		
		<cfreturn 1 />
		
	</cffunction>
	
	<cffunction name="getAllowanceCodeLevel" output="false" returntype="numeric">
		
		<cfreturn 0 />
		
	</cffunction>
	
	<cffunction name="componentMapLevel" output="false" returntype="numeric">
		
		<cfreturn 3 />
		
	</cffunction>
	
	<cffunction name="getTemplateMapLevel" output="false" returntype="numeric">
		
		<cfreturn 1 />
		
	</cffunction>
	
	<cffunction name="getProgramLevel1Level" output="false" returntype="numeric">
		
		<cfreturn 1 />
		
	</cffunction>
	
	<cffunction name="getProgramLevel2Level" output="false" returntype="numeric">
		
		<cfreturn 2 />
		
	</cffunction>
	
	<cffunction name="enableEditAtProgramLevel" output="false" returntype="boolean">
		
		<cfreturn 0 />
		
	</cffunction>
	
	<cffunction name="getProductGroupSelectLevel" output="false" returntype="boolean">
		
		<cfreturn 1 />
		
	</cffunction>
	
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Operating Group Level Selects ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->


	<cffunction name="getLabel" output="false" returntype="string">
		<cfargument name="level" type="numeric" required="true" />	
		
		<!--- get the Operating Groups --->
		<cfset qGetOperatingGroupLevels = getOperatingGroupLevels(arguments.level) />		
		
		<cfreturn qGetOperatingGroupLevels.Operating_Group_Level_Desc />
		
	</cffunction>
	
	<cffunction name="getOperatingGroupLevels" output="false" returntype="query">
		<cfargument name="level" type="numeric" required="false" default="0" />	
		
		<!--- get the Operating Groups --->
		<cfquery name="qGetOperatingGroupLevels" datasource="#application.datasource#">			
			SELECT 	Operating_Group_Level_ID,
					Operating_Group_Level_Desc
			FROM 	Operating_Group_Level
			WHERE	1 = 1
			<cfif arguments.level NEQ 0>
			AND		Operating_Group_Level_ID = <cfqueryparam value="#arguments.level#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
			Order by Operating_Group_Level_ID
		</cfquery>
		
		<cfreturn qGetOperatingGroupLevels />
		
	</cffunction>
	
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Operating Group Selects ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->


	<cffunction name="getOperatingGroupDesc" output="false" returntype="string">
		<cfargument name="id" type="numeric" required="true" />
		
		<cfif arguments.id EQ 0>
			<cfreturn "None" />			
		<cfelse>
			<!--- get the Operating Groups --->
			<cfset qGetThisOperatingGroups = get(0, arguments.id) />		
			<cfreturn qGetThisOperatingGroups.Operating_Group_Desc />
		</cfif>
		
	</cffunction>
	
	<cffunction name="getOperatingGroupLevel" output="false" returntype="numeric">
		<cfargument name="id" type="numeric" required="true" />
		
		<cfif arguments.id EQ 0>
			<cfreturn 0 />
		<cfelse>
			<!--- get the Operating Groups --->
			<cfset qGetThisOperatingGroups = get(0, arguments.id) />
			<cfif isnumeric(qGetThisOperatingGroups.Operating_Group_Level_ID)>		
				<cfreturn qGetThisOperatingGroups.Operating_Group_Level_ID />
			<cfelse>
				<cfreturn 0 />
			</cfif>
		</cfif>
		
	</cffunction>
	
	<cffunction name="get" output="false" returntype="query">
		<cfargument name="level" type="numeric" required="true" />	
		<cfargument name="id" type="numeric" required="false" default="0" />
		<cfargument name="sort_by_fields" type="string" required="false" default="" />
		<cfargument name="active" type="numeric" required="false" default="-1" />

		<!--- get the Operating Groups --->
		<cfquery name="qGetOperatingGroups" datasource="#application.datasource#">
			SELECT 	Operating_Group.Operating_Group_ID,
					Operating_Group.Operating_Group_Number,
					Operating_Group.Operating_Group_Desc,
					Operating_Group.Operating_Group_Level_ID,
					Operating_Group.Parent_Operating_Group_ID,
					Operating_Group.Active,
					ISNULL(Operating_Group.Allowance_Code_ID, 0) Allowance_Code_ID,
					Allowance_Code_Desc,
					Allowance_Code_Number,
					----Business Segment
					OG.Operating_Group_Desc AS Parent_Operating_Group_Desc,
					OG.Operating_Group_Number AS Parent_Operating_Group_Number
			FROM 	Operating_Group
			Left Join Operating_Group OG
					on OG.Operating_Group_ID = Operating_Group.Parent_Operating_Group_ID
			Left Join Allowance_Code 
					on Allowance_Code.Allowance_Code_ID = Operating_Group.Allowance_Code_ID
					and Allowance_Code.Deleted = 0
			WHERE	Operating_Group.Deleted = 0
			<cfif arguments.id NEQ 0>
				AND	Operating_Group.Operating_Group_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
			<cfif arguments.active NEQ -1>
				AND	Operating_Group.Active = <cfqueryparam value="#arguments.active#" cfsqltype="CF_SQL_BIT">
			</cfif>
			<cfif arguments.level NEQ 0>
				AND	Operating_Group.Operating_Group_Level_ID = <cfqueryparam value="#arguments.level#" cfsqltype="CF_SQL_INTEGER">
			</cfif> 
			<cfif arguments.sort_by_fields neq "">
				order by #trim(arguments.sort_by_fields)#
			</cfif>
		</cfquery>
		<cfreturn qGetOperatingGroups />
	</cffunction>
	
	<cffunction name="getOperatingGroupWithFilters" output="false" returntype="query">
		<cfargument name="level" type="numeric" required="true" />	
		<cfargument name="profileId" type="numeric" required="false" default="0" />
		<cfargument name="templateId" type="numeric" required="false" default="0" />
		<cfargument name="active" type="numeric" required="false" default="-1" />
		
		<!--- get the Operating Groups --->
		<cfquery name="qGetOperatingGroupWithFilters" datasource="#application.datasource#">			
			SELECT 	Operating_Group.Operating_Group_ID,
					Operating_Group.Operating_Group_Number,
					Operating_Group.Operating_Group_Desc,
					Operating_Group.Parent_Operating_Group_ID,
					Operating_Group.Allowance_Code_ID,
					Operating_Group.Active
			FROM 	Operating_Group
			
			<cfset currentOperatingGroupFromClause = "Operating_Group" />
			<cfset compareProfileAgainst = currentOperatingGroupFromClause />
			<cfset compareTemplateAgainst = currentOperatingGroupFromClause />
			
			<!------ If the profile restriction and 
			template restriction is at a different level than the arguments.level,
			we have to go up until we reach the place where we can compare against
			 ----->
			<cfset minLevel = getProfileRestrictionLevel() />
			<cfif getTemplateMapLevel() LT minLevel>
				<cfset minLevel = getTemplateMapLevel() />
			</cfif>
			<cfif arguments.level GT minLevel>
				<cfloop index="currentLevel" from="#Evaluate(arguments.level-1)#" to="#minLevel#" step="-1">
					INNER JOIN Operating_Group Operating_Group_#currentLevel#
					ON		Operating_Group_#currentLevel#.Deleted = 0
					AND		Operating_Group_#currentLevel#.Operating_Group_ID = #currentOperatingGroupFromClause#.Parent_Operating_Group_ID
					
					<cfset currentOperatingGroupFromClause = "Operating_Group_#currentLevel#" />
					<cfif currentLevel EQ getProfileRestrictionLevel()>
						<cfset compareProfileAgainst = currentOperatingGroupFromClause />
					</cfif>
					<cfif currentLevel EQ getTemplateMapLevel()>
						<cfset compareTemplateAgainst = currentOperatingGroupFromClause />
					</cfif>
				</cfloop>
			</cfif>
			
			WHERE	Operating_Group.Deleted = 0
			<cfif arguments.profileId NEQ 0>
			AND		#compareProfileAgainst#.Operating_Group_ID IN
			(
				SELECT 	DISTINCT Operating_Group_ID
				FROM	Operating_Group_Profile_Map
				WHERE	Deleted = 0
				AND		Profiles_ID = <cfqueryparam value="#arguments.profileId#" cfsqltype="CF_SQL_INTEGER">
			)			 
			</cfif>
			<cfif arguments.templateId NEQ 0>
			AND		#compareTemplateAgainst#.Operating_Group_ID IN
			(
				SELECT 	DISTINCT Operating_Group_ID
				FROM	Template_Operating_Group
				WHERE	Deleted = 0
				AND		Template_ID = <cfqueryparam value="#arguments.templateId#" cfsqltype="CF_SQL_INTEGER">
			)			 
			</cfif>
			<cfif arguments.level NEQ 0>
			AND		Operating_Group.Operating_Group_Level_ID = <cfqueryparam value="#arguments.level#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
			<cfif arguments.active GTE 0>
			AND		Operating_Group.Active = <cfqueryparam value="#arguments.active#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
		</cfquery>
		
		<cfreturn qGetOperatingGroupWithFilters />
		
	</cffunction>
	
	
	<cffunction name="getOperatingGroupsWithFilters" output="false" returntype="query">
		<cfargument name="level1" type="numeric" required="true" />	
		<cfargument name="level2" type="numeric" required="true" />	
		<cfargument name="profileId" type="numeric" required="false" default="0" />
		<cfargument name="templateId" type="numeric" required="false" default="0" />
		<cfargument name="active" type="numeric" required="false" default="-1" />
		
		<cfset currentLevel = arguments.level2 />
		<!--- get the Operating Groups --->
		<cfquery name="qGetOperatingGroupWithFilters" datasource="#application.datasource#">			
			SELECT 	Operating_Group_#arguments.level1#.Operating_Group_ID Operating_Group_#arguments.level1#_ID,
					Operating_Group_#arguments.level1#.Operating_Group_Desc Operating_Group_#arguments.level1#_Desc,
					Operating_Group_#arguments.level2#.Operating_Group_ID Operating_Group_#arguments.level2#_ID,
					Operating_Group_#arguments.level2#.Operating_Group_Desc Operating_Group_#arguments.level2#_Desc
			FROM 	Operating_Group Operating_Group_#currentLevel#
			
			<cfset currentOperatingGroupFromClause = "Operating_Group_#arguments.level2#" />
			<cfset compareProfileAgainst = currentOperatingGroupFromClause />
			<cfset compareTemplateAgainst = currentOperatingGroupFromClause />
			
			<!------ If the profile restriction and 
			template restriction is at a different level than the arguments.level,
			we have to go up until we reach the place where we can compare against
			 ----->
			<cfset minLevel = getProfileRestrictionLevel() />
			<cfif getTemplateMapLevel() LT minLevel>
				<cfset minLevel = getTemplateMapLevel() />
			</cfif>
			<cfif arguments.level1 LT minLevel>
				<cfset minLevel = arguments.level1 />
			</cfif>
			<cfif arguments.level2 GT minLevel>
				<cfloop index="currentLevel" from="#Evaluate(arguments.level2-1)#" to="#minLevel#" step="-1">
					INNER JOIN Operating_Group Operating_Group_#currentLevel#
					ON		Operating_Group_#currentLevel#.Deleted = 0
					AND		Operating_Group_#currentLevel#.Operating_Group_ID = #currentOperatingGroupFromClause#.Parent_Operating_Group_ID
					
					<cfset currentOperatingGroupFromClause = "Operating_Group_#currentLevel#" />
					<cfif currentLevel EQ getProfileRestrictionLevel()>
						<cfset compareProfileAgainst = currentOperatingGroupFromClause />
					</cfif>
					<cfif currentLevel EQ getTemplateMapLevel()>
						<cfset compareTemplateAgainst = currentOperatingGroupFromClause />
					</cfif>
				</cfloop>
			</cfif>
			
			WHERE	Operating_Group_#arguments.level2#.Deleted = 0
			<cfif arguments.profileId NEQ 0>
			AND		#compareProfileAgainst#.Operating_Group_ID IN
			(
				SELECT 	DISTINCT Operating_Group_ID
				FROM	Operating_Group_Profile_Map
				WHERE	Deleted = 0
				AND		Profiles_ID = <cfqueryparam value="#arguments.profileId#" cfsqltype="CF_SQL_INTEGER">
			)			 
			</cfif>
			<cfif arguments.templateId NEQ 0>
			AND		#compareTemplateAgainst#.Operating_Group_ID IN
			(
				SELECT 	DISTINCT Operating_Group_ID
				FROM	Template_Operating_Group
				WHERE	Deleted = 0
				AND		Template_ID = <cfqueryparam value="#arguments.templateId#" cfsqltype="CF_SQL_INTEGER">
			)			 
			</cfif>
			<cfif arguments.level1 NEQ 0>
			AND		Operating_Group_#arguments.level1#.Operating_Group_Level_ID = <cfqueryparam value="#arguments.level1#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
			<cfif arguments.level2 NEQ 0>
			AND		Operating_Group_#arguments.level2#.Operating_Group_Level_ID = <cfqueryparam value="#arguments.level2#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
			<cfif arguments.active GTE 0>
			AND		Operating_Group_#arguments.level2#.Active = <cfqueryparam value="#arguments.active#" cfsqltype="CF_SQL_INTEGER">
			AND		Operating_Group_#arguments.level1#.Active = <cfqueryparam value="#arguments.active#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
			ORDER BY Operating_Group_#arguments.level1#_ID, Operating_Group_#arguments.level2#_ID
		</cfquery>
		
		<cfreturn qGetOperatingGroupWithFilters />
		
	</cffunction>
	
	<cffunction name="getOperatingGroupsForThisOperatingGroup" output="false" returntype="query">
		<cfargument name="level1Id" type="numeric" required="true" />	
		<cfargument name="level1" type="numeric" required="true" />
		<cfargument name="level2" type="numeric" required="true" />
		
		<cfset currentLevel = arguments.level2 />
		<!--- get the Operating Groups --->
		<cfquery name="qGetOperatingGroupsForThisOperatingGroup" datasource="#application.datasource#">			
			SELECT Operating_Group_#arguments.level2#.Operating_Group_ID,
					Operating_Group_#arguments.level2#.Operating_Group_Desc
			FROM 	Operating_Group Operating_Group_#currentLevel#
			
			<cfset currentOperatingGroupFromClause = "Operating_Group_#arguments.level2#" />
			
			<!------ If the profile restriction and 
			template restriction is at a different level than the arguments.level,
			we have to go up until we reach the place where we can compare against
			 ----->
			<cfset minLevel = arguments.level1 />
			<cfif arguments.level2 GT minLevel>
				<cfloop index="currentLevel" from="#Evaluate(arguments.level2-1)#" to="#minLevel#" step="-1">
					INNER JOIN Operating_Group Operating_Group_#currentLevel#
					ON		Operating_Group_#currentLevel#.Deleted = 0
					AND		Operating_Group_#currentLevel#.Operating_Group_ID = #currentOperatingGroupFromClause#.Parent_Operating_Group_ID
					
					<cfset currentOperatingGroupFromClause = "Operating_Group_#currentLevel#" />					
				</cfloop>
			</cfif>
			
			WHERE	Operating_Group_#arguments.level2#.Deleted = 0
			
			<cfif arguments.level1Id NEQ 0>
			AND		Operating_Group_#arguments.level1#.Operating_Group_ID = <cfqueryparam value="#arguments.level1Id#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
			<cfif arguments.level1 NEQ 0>
			AND		Operating_Group_#arguments.level1#.Operating_Group_Level_ID = <cfqueryparam value="#arguments.level1#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
			<cfif arguments.level2 NEQ 0>
			AND		Operating_Group_#arguments.level2#.Operating_Group_Level_ID = <cfqueryparam value="#arguments.level2#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
			ORDER BY Operating_Group_#arguments.level2#.Operating_Group_ID
		</cfquery>
		
		<cfreturn qGetOperatingGroupsForThisOperatingGroup />
		
	</cffunction>
	
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Allowance Code Selects ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->

	<cffunction name="getUsedAllowanceCodes" output="false" returntype="string">
		
		<!--- get the Allowance Codes --->
		<cfquery name="qGetAllowanceCodes" datasource="#application.datasource#">			
			SELECT 	DISTINCT Allowance_Code_ID
			FROM 	Operating_Group			
			WHERE	Deleted = 0
		</cfquery>
		
		<cfreturn ValueList(qGetAllowanceCodes.Allowance_Code_ID) />
		
	</cffunction>
	
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Profile level restriction ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getOperatingGroupProfileSettings" output="false" returntype="query">
		<cfargument name="level" type="numeric" required="true" />
		<cfargument name="profileId" type="numeric" required="false" default="0" />
		<cfargument name="returnCheckedOnly" type="boolean" required="false" default="0" />
			<!--- Dev Note: drachala; D28010: Profile Setting modifications 
						  what For: Check weather user selected any profiles if so we are passing argument into getprofiles query.	--->
		<cfargument name="profile_id" type="string" required="no" default="">
		<cfargument name="userSettingPanel" type="numeric" required="false" default="5" />
 
				
		<!--- get the Operating Groups --->
		<cfquery name="qGetOperatingGroupProfileSettings" datasource="#application.datasource#">			
			SELECT 	Operating_Group.Operating_Group_ID,
					Operating_Group.Operating_Group_Number,
					Operating_Group.Operating_Group_Desc,
					Operating_Group.Parent_Operating_Group_ID,
					Operating_Group.Allowance_Code_ID,
					Operating_Group.Active,
					Profiles.Profiles_Desc,
					Profiles.Profiles_ID,
					Operating_Group_Profile_Map.Operating_Group_Profile_Map_ID
			FROM 	Operating_Group	
			
			INNER JOIN Profiles
			ON		Profiles.Deleted = 0
			<cfif (arguments.profileId NEQ 0) OR (len(arguments.profile_id) GT 0)>
			AND		Profiles.Profiles_ID IN ( <cfqueryparam value="#arguments.profile_id#" cfsqltype="CF_SQL_INTEGER" list="yes"	/>	) 
			</cfif>		
				<!--- End Dev Note: drachala; D28010: Profile Setting modifications  --->
 
			<cfif  arguments.userSettingPanel LT 5>
				AND Profiles.Profiles_ID NOT IN (select distinct  Profiles_ID from Profiles_Settings where Settings_Panel = 5 and Profiles_Settings.deleted = 0)
			</cfif>
			<cfif arguments.returnCheckedOnly>INNER<cfelse>LEFT</cfif> JOIN Operating_Group_Profile_Map
			ON		Operating_Group_Profile_Map.Deleted = 0
			AND		Operating_Group_Profile_Map.Profiles_ID = Profiles.Profiles_ID
			AND		Operating_Group_Profile_Map.Operating_Group_ID = Operating_Group.Operating_Group_ID			
			
			WHERE	Operating_Group.Deleted = 0
			<cfif arguments.level NEQ 0>
			AND		Operating_Group.Operating_Group_Level_ID = <cfqueryparam value="#arguments.level#" cfsqltype="CF_SQL_INTEGER">
			</cfif>

			ORDER BY Operating_Group.Operating_Group_ID, Profiles.Profiles_ID
		</cfquery>
		
		<cfreturn qGetOperatingGroupProfileSettings />
		
	</cffunction>
	
	<cffunction name="deleteOperatingGroupProfileSettings" output="false" returntype="void">
		
		<!------ Delete ----->
		<cfset useLakebaseForDeleteAllPriorOperatingGroupProfileSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("operating_group_profile_map")>
<cfif useLakebaseForDeleteAllPriorOperatingGroupProfileSettings>
	<cftry>
		<cfset application.oLakebase.updateRows("operating_group_profile_map",
			{
				"deleted" = "eq.0"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDeleteAllPriorOperatingGroupProfileSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeleteAllPriorOperatingGroupProfileSettings>
<cfquery name="DeleteAllPriorOperatingGroupProfileSettings" datasource="#application.datasource#">
			UPDATE	Operating_Group_Profile_Map
			SET		Deleted = 1
			WHERE	Deleted = 0
		</cfquery>
</cfif>
		
	</cffunction>
	
	<cffunction name="addOperatingGroupProfileSettings" output="false" returntype="void">
		<cfargument name="id" type="numeric" required="true" />
		<cfargument name="profileId" type="numeric" required="true" />
		
		<!------ Insert ----->
		<cfquery name="qInsertOperatingGroupProfileSettings" datasource="#application.datasource#">
			INSERT INTO Operating_Group_Profile_Map 
			(
				Profiles_ID,
				Operating_Group_ID
			)
			VALUES
			(
				<cfqueryparam value="#arguments.profileId#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
			)
		</cfquery> 
		
	</cffunction>
	
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Template level restriction ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getOperatingGroupTemplateSettings" output="false" returntype="query">
		<cfargument name="level" type="numeric" required="true" />
		<cfargument name="templateId" type="numeric" required="true" />
		
		<!--- get the Operating Groups --->
		<cfquery name="qGetOperatingGroupProfileSettings" datasource="#application.datasource#">			
			SELECT 	Operating_Group.Operating_Group_ID,
					Operating_Group.Operating_Group_Number,
					Operating_Group.Operating_Group_Desc,
					Operating_Group.Parent_Operating_Group_ID,
					Operating_Group.Allowance_Code_ID,
					Operating_Group.Active,
					ISNULL(Template_Operating_Group.Template_Operating_Group_ID, 0) Template_Checked
			FROM 	Operating_Group	
			
			LEFT JOIN Template_Operating_Group
			ON		Template_Operating_Group.Deleted = 0
			AND		Template_Operating_Group.Template_ID = <cfqueryparam value="#arguments.templateId#" cfsqltype="CF_SQL_INTEGER">
			AND		Template_Operating_Group.Operating_Group_ID = Operating_Group.Operating_Group_ID
					
			WHERE	Operating_Group.Deleted = 0
			<cfif arguments.level NEQ 0>
			AND		Operating_Group.Operating_Group_Level_ID = <cfqueryparam value="#arguments.level#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
			ORDER BY Operating_Group.Operating_Group_ID
		</cfquery>
		
		<cfreturn qGetOperatingGroupProfileSettings />
		
	</cffunction>
	
	<cffunction name="deleteOperatingGroupTemplateSettings" output="false" returntype="void">
		<cfargument name="templateId" type="numeric" required="true" />
		
		<!------ Delete ----->
		<cfquery name="DeleteAllPriorOperatingGroupTemplateSettings" datasource="#application.datasource#">
			UPDATE	Template_Operating_Group
			SET		Deleted = 1
			WHERE	Deleted = 0
			AND		Template_Operating_Group.Template_ID = <cfqueryparam value="#arguments.templateId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		
	</cffunction>
	
	<cffunction name="addOperatingGroupTemplateSettings" output="false" returntype="void">
		<cfargument name="id" type="numeric" required="true" />
		<cfargument name="templateId" type="numeric" required="true" />
		
		<!------ Insert ----->
		<cfquery name="qInsertOperatingGroupTemplateSettings" datasource="#application.datasource#">
			INSERT INTO Template_Operating_Group 
			(
				Template_ID,
				Operating_Group_ID
			)
			VALUES
			(
				<cfqueryparam value="#arguments.templateId#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
			)
		</cfquery> 
		
	</cffunction>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Program level Selection ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->

	<cffunction name="getProgramOperatingGroup" output="false" returntype="query">
		<cfargument name="level" type="numeric" required="true" />
		<cfargument name="programId" type="numeric" required="true" />
		
		<!------ Get saved id for this level for this program ----->
		<cfquery name="qGetProgramOperatingGroup" datasource="#application.datasource#">
			SELECT	Operating_Group.Operating_Group_ID
			
			FROM	Program_Operating_Group
			
			INNER JOIN Operating_Group
			ON		Operating_Group.Operating_Group_ID = Program_Operating_Group.Operating_Group_ID
			AND		Operating_Group.Operating_Group_Level_ID = <cfqueryparam value="#arguments.level#" cfsqltype="CF_SQL_INTEGER">
			
			WHERE	Program_Operating_Group.Deleted = 0
			AND		Program_Operating_Group.Program_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		
		<cfreturn qGetProgramOperatingGroup />
		
	</cffunction>
	
	<cffunction name="getProgramOperatingGroupDesc" output="false" returntype="string">
		<cfargument name="level" type="numeric" required="true" />
		<cfargument name="programId" type="numeric" required="true" />
		
		<cfset qGetProgramOperatingGroup = getProgramOperatingGroup(arguments.level, arguments.programId) />
		
		<cfif qGetProgramOperatingGroup.Operating_Group_ID EQ "">
			<cfreturn "None" />
		<cfelse>
			<cfreturn getOperatingGroupDesc(qGetProgramOperatingGroup.Operating_Group_ID) />
		</cfif>
		
	</cffunction>
	
	<cffunction name="getProgramOperatingGroupID" output="false" returntype="numeric">
		<cfargument name="level" type="numeric" required="true" />
		<cfargument name="programId" type="numeric" required="true" />
		
		<cfset qGetProgramOperatingGroup = getProgramOperatingGroup(arguments.level, arguments.programId) />
		
		<cfif qGetProgramOperatingGroup.recordCount AND qGetProgramOperatingGroup.Operating_Group_ID NEQ "">
			<cfreturn qGetProgramOperatingGroup.Operating_Group_ID />
		<cfelse>
			<cfreturn 0 />
		</cfif>
		
	</cffunction>
	
	<cffunction name="updateOperatingGroupProgram" output="false" returntype="void">
		<cfargument name="id" type="numeric" required="true" />
		<cfargument name="level" type="numeric" required="true" />
		<cfargument name="programId" type="numeric" required="true" />
		
		<!------ Update already saved id for this level for this program, to deleted = 1 ----->
		<cfquery name="qUpdateAlreadySaved" datasource="#application.datasource#">
			UPDATE	Program_Operating_Group
			SET		Program_Operating_Group.Deleted = 1
			
			FROM	Program_Operating_Group
			
			INNER JOIN Operating_Group
			ON		Operating_Group.Operating_Group_ID = Program_Operating_Group.Operating_Group_ID
			AND		Operating_Group.Operating_Group_Level_ID = <cfqueryparam value="#arguments.level#" cfsqltype="CF_SQL_INTEGER">
			
			WHERE	Program_Operating_Group.Deleted = 0
			AND		Program_Operating_Group.Program_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		
		<cfif arguments.id NEQ 0>
		
			<!------ Insert new record ----->
			<cfquery name="qInsertNew" datasource="#application.datasource#">
				INSERT INTO Program_Operating_Group 
				(
				Operating_Group_ID, 
				Program_ID
				)
				VALUES 
				(
				<cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
				)
			</cfquery>
		
		</cfif>
		
	</cffunction>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Components  ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getComponents" output="false" returntype="query">
		<cfargument name="id" type="numeric" required="true" />
		<cfargument name="discountTypeId" type="numeric" required="true" />
		
		<cfset checkComponentOperatingGroupId = arguments.id />
		<cfset iOperatingGroupLevel = getOperatingGroupLevel(arguments.id) />
		<cfif iOperatingGroupLevel LT componentMapLevel()>
			<!------ Get the lower level ids under this operating group ----->
			<cfset qGetOperatingGroupsForThisOperatingGroup = getOperatingGroupsForThisOperatingGroup(arguments.id, iOperatingGroupLevel, componentMapLevel()) />
			<cfset checkComponentOperatingGroupId = ValueList(qGetOperatingGroupsForThisOperatingGroup.Operating_Group_ID) />			
		</cfif>
		
		<!------ Get the components for this operating group ----->
		<cfswitch expression="#arguments.discountTypeId#">
			<cfcase value="1"><!------ Fixed ----->
				<cfquery name="qGetComponents" datasource="#application.datasource#">
					SELECT	Program_Fixed_Component_Name_ID Component_ID
					FROM 	Program_Fixed_Component_Name
					WHERE 	Deleted = 0
					<cfif checkComponentOperatingGroupId NEQ "">
					AND		Operating_Group_ID IN (<cfqueryparam value="#checkComponentOperatingGroupId#" cfsqltype="CF_SQL_INTEGER" list="true" separator=",">)
					<cfelse>
					AND		1=2
					</cfif>
				</cfquery>
			</cfcase>
			<cfcase value="2"><!------ Rebate ----->
				<cfquery name="qGetComponents" datasource="#application.datasource#">
					SELECT	Program_Rebates_Component_Name_ID Component_ID
					FROM 	Program_Rebates_Component_Name
					WHERE 	Deleted = 0
					<cfif checkComponentOperatingGroupId NEQ "">
					AND		Operating_Group_ID IN (<cfqueryparam value="#checkComponentOperatingGroupId#" cfsqltype="CF_SQL_INTEGER" list="true" separator=",">)
					<cfelse>
					AND		1=2
					</cfif>
				</cfquery>
			</cfcase>
			<cfcase value="3"><!------ Lump Sum ----->
				<cfquery name="qGetComponents" datasource="#application.datasource#">
					SELECT	Program_Lump_Sum_Name_ID Component_ID
					FROM 	Program_Lump_Sum_Name
					WHERE 	Deleted = 0
					<cfif checkComponentOperatingGroupId NEQ "">
					AND		Operating_Group_ID IN (<cfqueryparam value="#checkComponentOperatingGroupId#" cfsqltype="CF_SQL_INTEGER" list="true" separator=",">)
					<cfelse>
					AND		1=2
					</cfif>
				</cfquery>
			</cfcase>
			<cfcase value="4"><!------ grwoth ----->
				<cfquery name="qGetComponents" datasource="#application.datasource#">
					SELECT	Program_Growth_Components_Name_Id Component_ID
					FROM 	program_growth_components_name
					WHERE 	Deleted = 0
					<cfif checkComponentOperatingGroupId NEQ "">
					AND		Operating_Group_ID IN (<cfqueryparam value="#checkComponentOperatingGroupId#" cfsqltype="CF_SQL_INTEGER" list="true" separator=",">)
					<cfelse>
					AND		1=2
					</cfif>
				</cfquery>
			</cfcase>
			<cfcase value="8"><!------ off-invoice ----->
				<cfquery name="qGetComponents" datasource="#application.datasource#">
					SELECT	Program_OffInvoice_Component_Name_Id Component_ID
					FROM 	Program_OffInvoice_Component_Name
					WHERE 	Deleted = 0
					<cfif checkComponentOperatingGroupId NEQ "">
					AND		Operating_Group_ID IN (<cfqueryparam value="#checkComponentOperatingGroupId#" cfsqltype="CF_SQL_INTEGER" list="true" separator=",">)
					<cfelse>
					AND		1=2
					</cfif>
				</cfquery>
			</cfcase>			
			<cfcase value="10"><!------ Bid Request ----->
				<cfquery name="qGetComponents" datasource="#application.datasource#">
					SELECT	Program_BidRequest_Component_Name_Id Component_ID
					FROM 	Program_BidRequest_Component_Name
					WHERE 	Deleted = 0
					<cfif checkComponentOperatingGroupId NEQ "">
					AND		Operating_Group_ID IN (<cfqueryparam value="#checkComponentOperatingGroupId#" cfsqltype="CF_SQL_INTEGER" list="true" separator=",">)
					<cfelse>
					AND		1=2
					</cfif>
				</cfquery>
			</cfcase>
		</cfswitch>
		
		<cfreturn qGetComponents />
		
	</cffunction>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Operating Group - Product Group Groups  ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->

	<cffunction name="getProductGroupSelection" output="false" returntype="query">
	
		<cfargument name="operatingGroupId" type="numeric" required="true" />
		<cfargument name="productGroupLevelId" type="numeric" required="false" default="0" />
		
		<cfquery name="qGetProductGroupSelection" datasource="#application.datasource#">
			SELECT	Operating_Group_ID, Product_Group_Level_ID, Group_ID
			
			FROM	Operating_Group_Product_Group_Detail
			
			INNER JOIN Operating_Group_Product_Group
			ON		Operating_Group_Product_Group.Deleted = 0
			AND		Operating_Group_Product_Group.Operating_Group_Product_Group_ID = Operating_Group_Product_Group_Detail.Operating_Group_Product_Group_ID
			AND		Operating_Group_ID = <cfqueryparam value="#arguments.operatingGroupId#" cfsqltype="CF_SQL_INTEGER">
			<cfif arguments.productGroupLevelId>
			AND		Product_Group_Level_ID = <cfqueryparam value="#arguments.productGroupLevelId#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
			
			WHERE	Operating_Group_Product_Group_Detail.Deleted = 0	
			
			ORDER BY Operating_Group_ID, Product_Group_Level_ID, Group_ID
		</cfquery>
		
		<cfreturn qGetProductGroupSelection />
		
	</cffunction>
	
	<cffunction name="convertProductGroupSelectionToArray" output="false" returntype="array">
	
		<cfargument name="qGetProductGroupSelection" type="query" required="true" />
		<cfargument name="includeProductGroupType" type="numeric" required="false" default="0" />
		
		<cfset returnArray = ArrayNew(1) />
		<cfset ProductGroupAttributeManager = CreateObject("component", "components.products.group.ProductGroupAttributeManager").init() />

		<cfoutput query="qGetProductGroupSelection" group="Product_Group_Level_ID">
			<cfset sGroup_ID 				= "" />
			<cfoutput>
				<cfset sGroup_ID 				= ListAppend(sGroup_ID, Group_ID) />
			</cfoutput>
			<cfset ArrayAppend(returnArray, ProductGroupAttributeManager.getProductGroupSelectionStruct(Product_Group_Level_ID, sGroup_ID, arguments.includeProductGroupType)) />
		</cfoutput>
		
		<cfreturn returnArray />
		
	</cffunction>
	
	<cffunction name="deleteProductGroupSelection" output="false" returntype="void">
	
		<cfargument name="id" type="numeric" required="true" />
		
		<cfif arguments.id>
		
			<cfquery name="qDeleteExisting" datasource="#application.datasource#">
				UPDATE	Operating_Group_Product_Group_Detail
				SET		Operating_Group_Product_Group_Detail.Deleted = 1
				
				FROM	Operating_Group_Product_Group_Detail
				
				INNER JOIN Operating_Group_Product_Group
				ON		Operating_Group_Product_Group.Deleted = 0
				AND		Operating_Group_Product_Group.Operating_Group_Product_Group_ID = Operating_Group_Product_Group_Detail.Operating_Group_Product_Group_ID
				AND		Operating_Group_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
				
				WHERE	Operating_Group_Product_Group_Detail.Deleted = 0				
			</cfquery>
			
			<cfquery name="qDeleteExisting" datasource="#application.datasource#">
				UPDATE	Operating_Group_Product_Group
				SET		Deleted = 1
				WHERE	Deleted = 0
				AND		Operating_Group_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
		
		</cfif>
		
	</cffunction>
	
	<cffunction name="addProductGroupSelection" output="false" returntype="void">
	
		<cfargument name="operatingGroupId" type="numeric" required="true" />
		<cfargument name="productGroupLevelId" type="numeric" required="true" />
		<cfargument name="groupIdList" type="string" required="true" />
		
		<cfif arguments.groupIdList NEQ "">
		
			<!------ Insert into Operating_Group_Product_Group - Table 1 ----->
			<cfquery name="qInsertOperatingGroupProductGroup" datasource="#application.datasource#">
				SET NOCOUNT ON
				INSERT INTO Operating_Group_Product_Group (Operating_Group_ID, Product_Group_Level_ID)
				VALUES (
					<cfqueryparam value="#arguments.operatingGroupId#" cfsqltype="CF_SQL_INTEGER">, 
					<cfqueryparam value="#arguments.productGroupLevelId#" cfsqltype="CF_SQL_VARCHAR">)
				SELECT Operating_Group_Product_Group_ID = @@IDENTITY
				SET NOCOUNT OFF
			</cfquery>
			
			<cfset Operating_Group_Product_Group_ID = qInsertOperatingGroupProductGroup.Operating_Group_Product_Group_ID />
			<cfloop list="#arguments.groupIdList#" index="groupId">
				<!------ Insert into Operating_Group_Product_Group_Detail - Table 2 ----->
				<cfquery name="qInsertOperatingGroupProductGroupDetail" datasource="#application.datasource#">
					INSERT INTO Operating_Group_Product_Group_Detail (Operating_Group_Product_Group_ID, Group_ID)
					VALUES (
						<cfqueryparam value="#Operating_Group_Product_Group_ID#" cfsqltype="CF_SQL_INTEGER">, 
						<cfqueryparam value="#groupId#" cfsqltype="CF_SQL_VARCHAR">)				
				</cfquery>
			</cfloop>
		
		</cfif>
		
	</cffunction>
	
	<cffunction name="validateProductGroups" output="false" returntype="string">
	
		<cfargument name="operatingGroupId" type="numeric" required="true" />
		<cfargument name="productGroupLevelId" type="numeric" required="true" />
		<cfargument name="groupIdList" type="string" required="true" />
		
		<!--- get the product group/attribute filters for this operating group/bus seg --->
		<cfset qGetProductGroupSelection = getProductGroupSelection(arguments.operatingGroupId) />
		<cfset arrayOperatingGroupProductGroupSelection		= convertProductGroupSelectionToArray(qGetProductGroupSelection, 1) />

		<!--- get the metadata for the product group/attribute selected by the user in the search groups page --->
		<cfset ProductGroupAttributeManager = CreateObject("component", "components.products.group.ProductGroupAttributeManager").init() />
		<cfset stGroupTypeInfo = ProductGroupAttributeManager.getGroupTypeInfo(groupLevelId=arguments.productGroupLevelId) />

		<cfquery name="qGetValidGroupIDList" datasource="#application.datasource#">
			SELECT	DISTINCT #stGroupTypeInfo.MasterIDField# as Group_ID
			FROM	BSA_Foodservice_Items_master
			WHERE	Deleted = 0
			AND		BSA_Foodservice_Items_master.#stGroupTypeInfo.MasterIDField# IN (#ListQualify(groupIdList, "'", ",")#)
			<cfset operatingGroupProductGroupFilterArrayLen = ArrayLen(arrayOperatingGroupProductGroupSelection) />
			<cfloop index="counter" from="1" to="#operatingGroupProductGroupFilterArrayLen#">
				<cfset thisOperatingGroupProductGroupFilter = arrayOperatingGroupProductGroupSelection[counter] />
				<cfif thisOperatingGroupProductGroupFilter.Group_ID EQ "">AND 1=2
				<cfelse>						
				AND BSA_Foodservice_Items_master.#thisOperatingGroupProductGroupFilter.productGroupType.MasterIDField# IN (#ListQualify(thisOperatingGroupProductGroupFilter.Group_ID, "'", ",")#)
				</cfif>
			</cfloop>
		</cfquery>
		
		<cfreturn ValueList(qGetValidGroupIDList.Group_ID) />
	
	</cffunction>
	
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Operating Group Settings ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	
	<cffunction name="save" output="false" returntype="numeric">
	
		<cfargument name="level" type="numeric" required="true" />
		<cfargument name="id" type="numeric" required="true" />
		<cfargument name="number" type="string" required="true" />
		<cfargument name="desc" type="string" required="true" />
		<cfargument name="parentId" type="numeric" required="true" />
		<cfargument name="allowanceCodeId" type="numeric" required="true" />
		
		<cfif arguments.id>
		<!------ Update ----->
			<cfquery name="qUpdateOperatingGroup" datasource="#application.datasource#">
				UPDATE	Operating_Group
				SET		Operating_Group_Number = <cfqueryparam value="#arguments.number#" cfsqltype="CF_SQL_VARCHAR">,
						Operating_Group_Desc = <cfqueryparam value="#arguments.desc#" cfsqltype="CF_SQL_VARCHAR">,
						Parent_Operating_Group_ID = <cfqueryparam value="#arguments.parentId#" cfsqltype="CF_SQL_INTEGER">,
						Allowance_Code_ID = <cfqueryparam value="#arguments.allowanceCodeId#" cfsqltype="CF_SQL_INTEGER" null="#arguments.allowanceCodeId EQ 0#">
						
				WHERE	Operating_Group_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
				AND		Operating_Group_Level_ID = <cfqueryparam value="#arguments.level#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
		<cfelse>
		<!------ Insert ----->
			<cfquery name="qInsertOperatingGroup" datasource="#application.datasource#">
				SET NOCOUNT ON
				INSERT INTO Operating_Group (Operating_Group_Level_ID, Operating_Group_Number, Operating_Group_Desc, Parent_Operating_Group_ID, Allowance_Code_ID)
				VALUES (
					<cfqueryparam value="#arguments.level#" cfsqltype="CF_SQL_INTEGER">, 
					<cfqueryparam value="#arguments.number#" cfsqltype="CF_SQL_VARCHAR">, 
					<cfqueryparam value="#arguments.desc#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.parentId#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#arguments.allowanceCodeId#" cfsqltype="CF_SQL_INTEGER" null="#arguments.allowanceCodeId EQ 0#">)
				SELECT Operating_Group_ID = @@IDENTITY
				SET NOCOUNT OFF
			</cfquery>
			<cfset arguments.id = qInsertOperatingGroup.Operating_Group_ID />
		</cfif>
		
		<cfreturn arguments.id />
	
	</cffunction>
	
	<cffunction name="activateDeactivate" output="false" returntype="void">
	
		<cfargument name="id" type="numeric" required="true" />
		<cfargument name="active" type="numeric" required="true" />
		
		<cfif arguments.id>
		<!------ Update ----->
			<cfquery name="qUpdateOperatingGroup" datasource="#application.datasource#">
				UPDATE	Operating_Group
				SET		Active = <cfqueryparam value="#arguments.active#" cfsqltype="CF_SQL_INTEGER">
				WHERE	Operating_Group_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
		</cfif>
	
	</cffunction>	
	
	
</cfcomponent>