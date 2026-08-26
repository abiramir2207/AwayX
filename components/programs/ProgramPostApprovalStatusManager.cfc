<cfcomponent hint="Program Post Approval Status Manager" extends="components.Base">

	<cffunction name="init" output="false" returntype="components.programs.ProgramPostApprovalStatusManager">
	
		<cfreturn this />
		
	</cffunction>


	<cffunction name="getProgramPostApprovalStatus" output="false" returntype="query" hint="return the query with all non deleted status">
		
		<cfargument name="statusId" type="numeric" required="false" default="0" />
		
		<cfquery name="qGetProgramPostApprovalStatus" datasource="#application.datasource#">

			SELECT	Program_Post_Approval_Status.Program_Post_Approval_Status_ID, Program_Post_Approval_Status.Program_Post_Approval_Status_Desc,Program_Post_Approval_Status.Setting_Display_Value
			FROM	Program_Post_Approval_Status
			WHERE	Program_Post_Approval_Status.Deleted = 0
			<cfif arguments.statusId NEQ 0>
			AND		Program_Post_Approval_Status.Program_Post_Approval_Status_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.statusId#" />
			</cfif>
			<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getPgmPostApprovalStatusType() EQ 1><!------ ignore id=2 if appsettings value=1 ----->
			AND		Program_Post_Approval_Status.Program_Post_Approval_Status_ID <> 2
			</cfif>
			ORDER BY Program_Post_Approval_Status.Program_Post_Approval_Status_ID
			
		</cfquery>
		
		<cfreturn qGetProgramPostApprovalStatus />
		
	</cffunction>
	
	<cffunction name="getProgramPostApprovalStatusDesc" output="false" returntype="string">
		
		<cfargument name="statusId" type="numeric" required="true" />
		
		<cfset qGetProgramPostApprovalStatus = getProgramPostApprovalStatus(arguments.statusId) />
		
		<cfreturn qGetProgramPostApprovalStatus.Program_Post_Approval_Status_Desc />
		
	</cffunction>
	
	
	<cffunction name="getFakeStatusIdForProgramPostApprovalStatus" output="false" returntype="numeric">
		
		<!------ 2.5 so that it comes aftre RFA in the status order ----->
		<cfreturn 2.5 />
		
	</cffunction>
		
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Program functions ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	
	<cffunction name="getProgramPostApprovalStatusForProgram" output="false" returntype="numeric">
	
		<cfargument name="programId" type="numeric" required="true" />
		
		<cfquery name="qGetProgramPostApprovalStatus" datasource="#application.datasource#">
			SELECT	Program_Post_Approval_Status_ID
			FROM	Contract_Main
			WHERE	Contract_Main.Contract_Main_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.programId#" />
		</cfquery>
		
		<cfset returnValue = 0 />
		<cfif qGetProgramPostApprovalStatus.recordCount>
			<cfif IsNumeric(qGetProgramPostApprovalStatus.Program_Post_Approval_Status_ID)>
				<cfset returnValue = qGetProgramPostApprovalStatus.Program_Post_Approval_Status_ID />
			</cfif>
		</cfif>
		
		<cfreturn returnValue />
		
	</cffunction>
	
	<cffunction name="getProgramPostApprovalStatusHistory" output="false" returntype="query">
	
		<cfargument name="programId" type="numeric" required="true" />
		<cfargument name="postApprovalStatusId" type="numeric" required="true" />
		
		<!------ Insert History ----->
		<cfquery name="qGetProgramPostApprovalStatusHistory" datasource="#application.datasource#">
			SELECT	_Users.Name_First + ' ' + _Users.Name_Last Complete_User_Name, Program_Post_Approval_Status_History.Complete_Date, Program_Post_Approval_Status_History.Is_Complete
			FROM	Program_Post_Approval_Status_History
			
			LEFT JOIN _Users
			ON		_Users.User_ID = Program_Post_Approval_Status_History.Complete_User_ID
			
			WHERE	Program_Post_Approval_Status_History.Deleted = 0
			AND		Program_Post_Approval_Status_History.Contract_Main_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.programId#" />
			AND		Program_Post_Approval_Status_History.Program_Post_Approval_Status_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.postApprovalStatusId#" />						
			
			ORDER BY Program_Post_Approval_Status_History.Program_Post_Approval_Status_History_ID DESC
			<!------ to get latest at top ----->
		</cfquery>
		
		<cfreturn qGetProgramPostApprovalStatusHistory />
					
	</cffunction>	
	
	<cffunction name="setProgramPostApprovalStatusOnApproval" output="false" returntype="void">
	
		<cfargument name="programId" type="numeric" required="true" />
		<cfargument name="templateId" type="numeric" required="true" />
		<cfargument name="userId" type="string" required="true" />
		
		<cfset qGetSelectedTemplateProgramPostApprovalStatus = getSelectedTemplateProgramPostApprovalStatus(templateId = arguments.templateId) />
		<cfif qGetSelectedTemplateProgramPostApprovalStatus.recordCount><!------ If any status applies ----->
			<!------ get the first status ----->
			<cfset changePostApprovalStatusTo = qGetSelectedTemplateProgramPostApprovalStatus.Program_Post_Approval_Status_ID />
			<cfset setProgramPostApprovalStatus(
						programId = arguments.programId,
						postApprovalStatusId = changePostApprovalStatusTo,
						userId = arguments.userId) />
			
		</cfif>		
	
	</cffunction>
	
	<cffunction name="changeProgramPostApprovalStatus" output="false" returntype="void">
	
		<cfargument name="programId" type="numeric" required="true" />
		<cfargument name="fromStatusId" type="numeric" required="true" />
		<cfargument name="toStatusId" type="numeric" required="true" />
		<cfargument name="userId" type="string" required="true" />
		
		<cfif arguments.toStatusId GT arguments.fromStatusId>
			<!------ set old status to complete ----->
			<cfset setCompleteProgramPostApprovalStatusHistory(
						programId = arguments.programId,
						postApprovalStatusId = arguments.fromStatusId,
						userId = arguments.userId) />
		</cfif>
				
		<!------ set new status ----->
		<cfset setProgramPostApprovalStatus(
						programId = arguments.programId,
						postApprovalStatusId = arguments.toStatusId,
						userId = arguments.userId) />
			
	</cffunction>
	
	<cffunction name="setProgramPostApprovalStatus" output="false" returntype="void">
	
		<cfargument name="programId" type="numeric" required="true" />
		<cfargument name="postApprovalStatusId" type="numeric" required="true" />
		<cfargument name="userId" type="string" required="true" />
		
		<cfquery name="qUpdateProgramPostApprovalStatus" datasource="#application.datasource#">
			UPDATE	Contract_Main
			SET		Program_Post_Approval_Status_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.postApprovalStatusId#" null="#arguments.postApprovalStatusId EQ 0#" />
			WHERE	Contract_Main.Contract_Main_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.programId#" />
		</cfquery>
		
		<cfif arguments.postApprovalStatusId neq 0>
			<cfset addProgramPostApprovalStatusHistory(arguments.programId, arguments.postApprovalStatusId, arguments.userId) />
		</cfif>
					
	</cffunction>
	
	<cffunction name="setCompleteProgramPostApprovalStatusHistory" output="false" returntype="void">
	
		<cfargument name="programId" type="numeric" required="true" />
		<cfargument name="postApprovalStatusId" type="numeric" required="true" />
		<cfargument name="userId" type="string" required="true" />
		
		<!------ Insert History ----->
		<cfquery name="qUpdateCompleteProgramPostApprovalStatusHistory" datasource="#application.datasource#">
			UPDATE	Program_Post_Approval_Status_History
			SET		Is_Complete = 1,
					Complete_User_ID = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.userId#" />,
					Complete_Date = GetDate()
			WHERE	Deleted = 0
			AND		Is_Complete = 0
			AND		Contract_Main_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.programId#" />
			AND		Program_Post_Approval_Status_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.postApprovalStatusId#" />
		</cfquery>
					
	</cffunction>
	
	<cffunction name="addProgramPostApprovalStatusHistory" output="false" returntype="void">
	
		<cfargument name="programId" type="numeric" required="true" />
		<cfargument name="postApprovalStatusId" type="numeric" required="true" />
		<cfargument name="userId" type="string" required="true" />
		
		<!------ Insert History ----->
		<cfquery name="qInsertProgramPostApprovalStatusHistory" datasource="#application.datasource#">
			INSERT INTO Program_Post_Approval_Status_History(Contract_Main_ID, Program_Post_Approval_Status_ID, Status_Set_User_ID, Status_Set_Date)
			VALUES(
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.programId#" />,
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.postApprovalStatusId#" />,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.userId#" />,
				GetDate()
				)
		</cfquery>
					
	</cffunction>

	<cffunction name="getSelectedTemplateProgramPostApprovalStatus" output="false" returntype="query">
		
		<cfargument name="templateId" type="numeric" required="true" />
		<cfargument name="programPostApprovalStatusId" type="numeric" required="false" default="0" />
		
		<cfreturn getTemplateProgramPostApprovalStatus(
					templateId = arguments.templateId,
					programPostApprovalStatusId = arguments.programPostApprovalStatusId,
					bSelected = 1
					) />
		
	</cffunction>
	
	
	<cffunction name="getSelectedProfileProgramPostApprovalStatus" output="false" returntype="query">
		
		<cfargument name="profileId" type="numeric" required="true" />
		
		<cfreturn getProfileProgramPostApprovalStatus(
					profileId = arguments.profileId,
					bSelected = 1
					) />
		
	</cffunction>
	
	<cffunction name="getSelectedProfileProgramPostApprovalStatusArray" output="false" returntype="array">
		
		<cfargument name="profileId" type="numeric" required="true" />
		
		<cfset qGetProfileProgramPostApprovalStatus = getProfileProgramPostApprovalStatus(
					profileId = arguments.profileId
					) />
					
		<cfset returnArray = ArrayNew(2) />
		<cfloop query="qGetProfileProgramPostApprovalStatus">
			<cfif Profile_Selected_ID EQ "">
				<cfset returnArray[Program_Post_Approval_Status_ID][1] = 0 />
			<cfelse>
				<cfset returnArray[Program_Post_Approval_Status_ID][1] = 1 />
			</cfif>
			<cfset returnArray[Program_Post_Approval_Status_ID][2] = Program_Post_Approval_Status_Desc />
		</cfloop>
		
		<cfreturn returnArray />
		
	</cffunction>

	<cffunction name="getProfileProgramPostApprovalStatusChangeAccess" output="false" returntype="numeric">
		
		<cfargument name="profileId" type="numeric" required="true" />
		<cfargument name="programPostApprovalStatusId" type="numeric" required="true" />
		
		<cfset qGetProfileProgramPostApprovalStatus = getProfileProgramPostApprovalStatus(
					profileId = arguments.profileId,
					programPostApprovalStatusId = arguments.programPostApprovalStatusId,
					bSelected = 1
					) />
		<cfset returnValue = 0 />
		<cfif qGetProfileProgramPostApprovalStatus.recordCount>
			<cfif qGetProfileProgramPostApprovalStatus.Profile_Selected_ID NEQ "">
				<cfset returnValue = 1 />
			</cfif>
		</cfif>
		
		<cfreturn returnValue />
		
	</cffunction>
	

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Template functions ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	
			
	<cffunction name="getTemplateProgramPostApprovalStatus" output="false" returntype="query" hint="">
		
		<cfargument name="templateId" type="numeric" required="true" />
		<cfargument name="programPostApprovalStatusId" type="numeric" required="false" default="0" />
		<cfargument name="bSelected" type="numeric" required="false" default="0" />
		<cfargument name="ignoreTemplateId" type="numeric" required="false" default="0" />
		
		<cfquery name="qGetTemplateProgramPostApprovalStatus" datasource="#application.datasource#">

			SELECT	Program_Post_Approval_Status.Program_Post_Approval_Status_ID, Program_Post_Approval_Status.Program_Post_Approval_Status_Desc,
					Template_Post_Approval_Status.Program_Post_Approval_Status_ID Template_Selected_ID,
					Template_Post_Approval_Status.Template_ID
			FROM	Program_Post_Approval_Status
			LEFT JOIN	Template_Post_Approval_Status
			ON		Template_Post_Approval_Status.Deleted = 0
			AND		Template_Post_Approval_Status.Program_Post_Approval_Status_ID = Program_Post_Approval_Status.Program_Post_Approval_Status_ID
			<cfif arguments.ignoreTemplateId EQ 0>
			AND		Template_Post_Approval_Status.Template_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.templateId#" />
			</cfif>
			WHERE	Program_Post_Approval_Status.Deleted = 0
			<cfif arguments.programPostApprovalStatusId NEQ 0>
			AND		Program_Post_Approval_Status.Program_Post_Approval_Status_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.programPostApprovalStatusId#" />
			</cfif>
			<cfif arguments.bSelected>
			AND		Template_Post_Approval_Status.Program_Post_Approval_Status_ID IS NOT NULL
			</cfif>
			<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getPgmPostApprovalStatusType() EQ 1><!------ ignore id=2 if appsettings value=1 ----->
			AND		Program_Post_Approval_Status.Program_Post_Approval_Status_ID <> 2
			</cfif>
			ORDER BY Program_Post_Approval_Status.Program_Post_Approval_Status_ID
			
		</cfquery>
		
		<cfreturn qGetTemplateProgramPostApprovalStatus />
		
	</cffunction>
	
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Profile functions ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	
	<cffunction name="getProfileProgramPostApprovalStatus" output="false" returntype="query" hint="returns combination of status and profiles and selected status for each profile">
		<cfargument name="programPostApprovalStatusId" type="numeric" required="false" default="0" />
		<cfargument name="profileId" type="numeric" required="false" default="0" />
		<cfargument name="bSelected" type="numeric" required="false" default="0" />
		
		<cfquery name="qGetProfileProgramPostApprovalStatus" datasource="#application.datasource#">

			SELECT	Program_Post_Approval_Status.Program_Post_Approval_Status_ID, Program_Post_Approval_Status.Program_Post_Approval_Status_Desc,
					Profiles.Profiles_ID, Profile_Post_Approval_Status.Program_Post_Approval_Status_ID Profile_Selected_ID
			FROM	Program_Post_Approval_Status
			
			INNER JOIN Profiles
			ON		Profiles.Deleted = 0
		
			LEFT JOIN	Profile_Post_Approval_Status
			ON		Profile_Post_Approval_Status.Deleted = 0
			AND		Profile_Post_Approval_Status.Profiles_ID = Profiles.Profiles_ID
			AND		Profile_Post_Approval_Status.Program_Post_Approval_Status_ID = Program_Post_Approval_Status.Program_Post_Approval_Status_ID
			
			WHERE	Program_Post_Approval_Status.Deleted = 0
			<cfif arguments.programPostApprovalStatusId NEQ 0>
			AND		Program_Post_Approval_Status.Program_Post_Approval_Status_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.programPostApprovalStatusId#" />
			</cfif>
			<cfif arguments.profileId NEQ 0>
			AND		Profiles.Profiles_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.profileId#" />
			</cfif>
			<cfif arguments.bSelected>
			AND		Profile_Post_Approval_Status.Program_Post_Approval_Status_ID IS NOT NULL
			</cfif>
			<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getPgmPostApprovalStatusType() EQ 1><!------ ignore id=2 if appsettings value=1 ----->
			AND		Program_Post_Approval_Status.Program_Post_Approval_Status_ID <> 2
			</cfif>
			ORDER BY Program_Post_Approval_Status.Program_Post_Approval_Status_ID, Profiles.Profiles_ID
			
		</cfquery>
		
		<cfreturn qGetProfileProgramPostApprovalStatus />
		
	</cffunction>
		
	
</cfcomponent>