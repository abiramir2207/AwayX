<!---
Name: 			WorkFlowManager.cfc
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Description:	I am the interface to workflow data.
Parameters:		N/A
Usage:			N/A
--->

<cfcomponent name="WorkFlowManager" displayname="WorkFlowManager" extends="components.programs.ProgramManager">

<cfscript>
	variables.settingsService = createObject("component","mvc.Models.SettingsService");
</cfscript>

	<cffunction name="getWorkFlowData" output="false" returntype="query" hint="function to return workflow data">
		<cfargument name="programId" type="Numeric" required="true">

		<cfstoredproc procedure="USP_Get_Workflow_Data" datasource="#application.datasource#">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER"	dbVarName = "@@Program_ID" value = "#arguments.programId#" null="no">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER"	dbVarName = "@@DiffLocalTimeZoneAndEST" value = "0" null="no">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER"	dbVarName = "@@UseDayLightSavingsTime" value = "#int(request.AccessStructure.useDayLightSavingsTime)#" null="no">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER"	dbVarName = "@@PreserveTimeFormat" value = "1" null="no">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER"	dbVarName = "@@GetTimeZoneOffSet" value = "0" null="no">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER"	dbVarName = "@@SelectQuery" value = "1" null="no">
			<cfprocresult name="qWorkflowData">
		</cfstoredproc>

		<cfreturn qWorkflowData>
	</cffunction>

	<cffunction name="saveProgramAgreeReason" output="true" hint="function to save a list of reasons why a user could only agree">

		<cfargument name="programId"	type="Numeric" 	required="true" />
		<cfargument name="userId" 		type="string" 	required="true" />
		<cfargument name="lAgreeResons"	type="string" 	required="true" />

		<cfscript>
			//set local variables
			var nProgramID			= "";
			var sUserID				= "";
			var lAgreeReasons		= "";
			var indx				="";

			//assign local variables
			nProgramID 				= arguments.programId;
			sUserID 				= arguments.userId;
			lAgreeReasons 			= arguments.lAgreeResons;

		</cfscript>

		<!--- first delete any entries for this user/program combination --->
		<cfquery name="qDeleteProgramAgreeReason" datasource="#application.datasource#">

			DELETE	FROM Program_Agree_Reason
			WHERE	User_Id = <cfqueryparam value="#sUserID#" cfsqltype="CF_SQL_VARCHAR" />
			AND		Program_ID = <cfqueryparam value="#nProgramID#" cfsqltype="CF_SQL_INTEGER" />

		</cfquery>

		<!--- now loop over the list of agree reasons and save them --->
		<cfloop list="#lAgreeReasons#" index="indx" delimiters="|">
			<cfquery name="qDeleteProgramAgreeReason" datasource="#application.datasource#">

				INSERT INTO Program_Agree_Reason
					(User_Id, Program_ID, Agree_Reason)
				VALUES
					(<cfqueryparam value="#sUserID#" cfsqltype="CF_SQL_VARCHAR" />, <cfqueryparam value="#nProgramID#" cfsqltype="CF_SQL_INTEGER" />, <cfqueryparam value="#indx#" cfsqltype="CF_SQL_VARCHAR" />)

			</cfquery>
		</cfloop>

	</cffunction>

	<cffunction name="getProgramAgreeReason" output="false" returntype="query" hint="function to get a list of reasons why a user could only agree">

		<cfargument name="programId"	type="Numeric" 	required="true" />
		<cfargument name="userId" 		type="string" 	required="true" />

		<cfscript>
			//set local variables
			var nProgramID			= "";
			var sUserID				= "";

			//assign local variables
			nProgramID 				= arguments.programId;
			sUserID 				= arguments.userId;

		</cfscript>

		<!--- get the agree reasons for a given user --->
		<cfquery name="qGetProgramAgreeReason" datasource="#application.datasource#">

			SELECT	Agree_Reason
			FROM 	Program_Agree_Reason
			WHERE	User_Id = <cfqueryparam value="#sUserID#" cfsqltype="CF_SQL_VARCHAR" />
			AND		Program_ID = <cfqueryparam value="#nProgramID#" cfsqltype="CF_SQL_INTEGER" />

		</cfquery>

		<cfreturn qGetProgramAgreeReason />

	</cffunction>

	<cffunction name="getNextApprovableUsers" output="false" returntype="query">

		<cfargument name="programId" type="numeric" required="true" />
		<cfargument name="businessSegmentsOn" type="numeric" required="false" default="0" />
		<cfargument name="responsibleUserId" type="string" required="false" default="" />
		<cfargument name="checkMassApprove" type="numeric" required="false" default="0" />
		<cfargument name="checkRFANotificationEmail" type="numeric" required="false" default="0" />
		<cfargument name="checkRemoteApprovalOption" type="numeric" required="false" default="0" />
		<cfargument name="plannerId" type="numeric" required="false" default="0" />

		<cfif arguments.programId NEQ 0 AND application.appSettingsget.get_Setting('GPO_One_Page_Program_Creation') EQ 1>
			<!--- Check if Manual_Selection_Of_Approvers = 1 --->
			<cfquery name="qGetTemplate" datasource="#application.datasource#">
				SELECT	Program_Control_Panel_Options.Manual_Selection_Of_Approvers, Program_Control_Panel_Options.Created_Type
				FROM	Contract_Main
				INNER JOIN Program_Control_Panel_Options
				ON		Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
				WHERE	Contract_Main.Contract_Main_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
			<cfif qGetTemplate.Manual_Selection_Of_Approvers EQ '1'>
				<cfquery name="qGetNextApprovalbleUsers" datasource="#application.datasource#">
					SELECT	UP.Position_Label,
							UP.Service_Zone_ID,
							UP.Service_Region_ID,
							UP.Service_Market_ID,
							UP.User_Positions_ID,
							Profiles.Profiles_ID,
							Profiles.Profiles_Desc,
							U.User_ID,
							U.Name_First + ' ' + U.Name_Last as User_Full_Name,
							U.User_Code,
							ltrim(rtrim(U.User_Email)) User_Email,
							U.RFA_Notification_Email,
							U.Remote_Approval_Option,
							Contract_Main.Contract_Main_ID,
							Contract_Main.Contract_Number,
							Contract_Main.Contract_Title,
							Contract_Main.Broker_User_ID,
							Contract_Main.Broker_Approved_Date,
							Contract_Main.Contract_Start_Date,
							Contract_Main.Contract_End_Date,
							Contract_Main.ProgramType_ID,
							Contract_Main.Notes,
							Authority_Sequence.Authority_Sequence_Order,
							Authority_Sequence.Authority_Sequence_ID,
							Authority_Sequence.Authority_Sequence_Name,
							'#qGetTemplate.Created_Type#' as Created_Type
					FROM	Contract_Main
					INNER JOIN Program_Approval_By_Profile PA ON
						PA.Program_ID = Contract_Main.Contract_Main_ID AND
						PA.Approved_By_User = 0 AND
						pa.Deleted = 0
					INNER JOIN _users U ON
						PA.Approved_by_User_Id = U.User_Id
					INNER JOIN Profiles ON
						Profiles.Profiles_ID = U.Profiles_ID
					INNER JOIN User_Position_Holders UPH ON
						UPH.User_id = u.user_id AND
						UPH.User_Position_Type = 'P'
					INNER JOIN User_Positions UP ON
						UP.User_Positions_ID = UPH.User_Positions_ID
					LEFT JOIN Authority_Sequence ON
						Authority_Sequence.Authority_Sequence_ID = U.Authority_Sequence_ID
					WHERE	Contract_Main.Contract_Main_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">

				</cfquery>
				<cfreturn qGetNextApprovalbleUsers />
			</cfif>
		</cfif>

		<!---
		Different conditions to check for
			- User not in forbid list or user in allow list
			- user not in agreed list
			- Check Business Segment/Class Code restriction if applicable
			- GDW4 Approval if the users approval is base don layered or disposal
		 --->
		<!--- D31726:CRA/NRA accounts for user segments START --->
		<!--- from flex is it possible we are not passing this argument --->
		<cfif arguments.businessSegmentsOn eq 0>
			<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
			<cfset arguments.businessSegmentsOn = businessSegManager.isEnabled()/>
		</cfif>
		<!--- D31726:CRA/NRA accounts for user segments END --->

		<!--- Get application settings --->
		<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
		<cfset appSettings = genSettingsManager.get()>

		<cfset approvalGroupManager = CreateObject("component", "components.settings.ApprovalGroupManager").init() />
		<cfset approvalGroupType = approvalGroupManager.getGroupTypeInfo() />

		<cfset forbidType = appSettings.getForbidAllowProfilesInTemplates() />

		<cfquery name="temp_Table_Drop" datasource="#application.datasource#">
		      if object_id('tempdb..##Tmp_Program_NRA_List') is not null
		      drop table ##Tmp_Program_NRA_List
		</cfquery>

		<!--- Get Program --->
		<cfquery name="qGetNextApprovalbleUsers" datasource="#application.datasource#">

			SELECT	DISTINCT
					Contract_Main.Contract_Main_ID,
					Contract_Main.Contract_Number,
					Contract_Main.Contract_Title,
					Contract_Main.Broker_User_ID,
					Contract_Main.Broker_Approved_Date,
					Contract_Main.Contract_Start_Date,
					Contract_Main.Contract_End_Date,
					Contract_Main.ProgramType_ID,
					Contract_Main.Notes,
					User_Positions.User_Positions_ID,
					Authority_Sequence.Authority_Sequence_Order,
					Authority_Sequence.Authority_Sequence_ID,
					Authority_Sequence.Authority_Sequence_Name,
					_Users.User_ID,
					_Users.Name_First + ' ' + _Users.Name_Last User_Full_Name,
					_Users.User_Code,
					ltrim(rtrim(_Users.User_Email)) User_Email,
					_Users.RFA_Notification_Email,
					_Users.Remote_Approval_Option,
					Profiles.Profiles_Desc,
					User_Positions.Position_Label,
					User_Positions.Service_Zone_ID,
					User_Positions.Service_Region_ID,
					User_Positions.Service_Market_ID,
					Profiles.Profiles_ID,
					Program_Control_Panel_Options.Created_Type
            INTO     ##Tmp_Program_NRA_List
            FROM	Contract_Main
					LEFT JOIN Planners
					ON  Planners.Planner_ID = Contract_Main.Planner_ID
					INNER JOIN Contract_Main_Aux_Data ON
					Contract_Main_Aux_Data.Contract_Main_ID = Contract_Main.Contract_Main_ID
					INNER JOIN Program_Control_Panel_Options
					ON	Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
					INNER JOIN Program_Approvable_Positions ON
					Program_Approvable_Positions.Contract_Main_ID = Contract_Main.Contract_Main_ID
					INNER JOIN User_Positions ON
					User_Positions.User_Positions_ID = Program_Approvable_Positions.User_positions_ID
					INNER JOIN User_Position_Holders ON
					User_Position_Holders.Deleted = 0 AND
					User_Position_Holders.User_Positions_ID = User_Positions.User_Positions_ID AND
					User_Position_Holders.User_Positions_ID = Program_Approvable_Positions.User_Positions_ID
					INNER JOIN _Users ON
					_Users.Deleted = 0 AND
					_Users.User_ID = User_Position_Holders.User_ID
					<cfif appsettings.getDisplayEligibleRSP() EQ 1>
					AND	_Users.Is_Eligible_RSP = 1 <!--- D12096: Filter CRA list to only show eligible RSP's --->
					</cfif>
					<!--- Dev Note: KAL; 7/2/2010; D23915: Single Instance Remote Approval --->
					<cfif arguments.checkRFANotificationEmail>
					AND	_Users.RFA_Notification_Email = 1
					</cfif>
					<cfif arguments.checkRemoteApprovalOption>
					AND	_Users.Remote_Approval_Option > 0
					</cfif>
					<!--- End Note: KAL; 7/2/2010; D23915: Single Instance Remote Approval --->
					<!--- Don't show BSA users --->
					<cfif appSettings.getHide_BSA_Users() IS 1>
					AND (_Users.User_Rights_ID IS NULL OR _Users.User_Rights_ID != 9999)
					</cfif>
					<!--- user not in agreed list --->
					AND	_Users.User_ID NOT IN
					(
						SELECT	DISTINCT Program_Agree.User_ID
						FROM	Program_Agree_All_Group Program_Agree
						WHERE	Program_Agree.ProgramId = Contract_Main.Contract_Main_ID
					)
					<!--- Manual Selection of Approvers --->
					AND (
						Program_Control_Panel_Options.Manual_Selection_Of_Approvers = 0
						<!--- Only apply this logic is table has any entry --->
						OR	NOT EXISTS (
							SELECT	1
							FROM	Program_Approval_By_Profile l
							WHERE	l.Program_ID = Contract_Main.Contract_Main_ID
							AND		l.Deleted = 0
							)
						OR	_Users.User_ID IN (
							SELECT	Approved_By_User_ID
							FROM	Program_Approval_By_Profile l
							WHERE	l.Program_ID = Contract_Main.Contract_Main_ID
							AND		l.Approved_By_User = 0
							AND		l.Deleted = 0
							)
					)
					INNER JOIN Profiles ON
					Profiles.Profiles_ID = _Users.Profiles_ID
					--Profiles.Profiles_ID NOT IN (SELECT Profile_ID FROM Program_Approvable_Profiles WHERE Contract_Main_ID = Contract_Main.Contract_Main_ID)
					INNER JOIN Profiles_Settings ON
					Profiles_Settings.Deleted = 0 AND
					Profiles_Settings.Profiles_ID = _Users.Profiles_ID
					<!--- Dev Note: KAL; D19440/20199: Approval via email: List Users with Mass Approval Rights --->
					<cfif arguments.checkMassApprove>
					AND	Profiles_Settings.Mass_RFA_Program_Approve = 1
					</cfif>
					<!--- User not in forbid list/in allow list --->
					AND
					(
						_Users.Profiles_ID
						<cfif forbidType EQ 1> NOT </cfif><!--- forbit type=1, forbid, 0=allow --->
						IN
						(	SELECT 	DISTINCT Profile_ID
							FROM 	Profile_Forbidden_Template
							WHERE 	Deleted = 0
							AND 	Forbid_Type = #forbidType#
							AND		Forbid_Access_Type = 2<!--- 1=access, 2=approve --->
							AND 	Template_ID = Contract_Main.ProgramType_ID
						)
						<cfif appSettings.getShow_Fixed_Freight() eq 1>
						OR 	(Contract_Main_Aux_Data.Freight_Component_Type <> 0	AND	Profiles_Settings.Approve_Freight_Programs = 1)
						</cfif>
					)

					<!--- check for profile level approval right --->
					AND
					(
						(Profiles_Settings.Cont_Prog_View_Margins = 1 AND Profiles_Settings.Cont_Prog_Approval_Rights = 1)
						<cfif appSettings.getShow_Fixed_Freight() eq 1>
						OR 	(Contract_Main_Aux_Data.Freight_Component_Type <> 0	AND	Profiles_Settings.Approve_Freight_Programs = 1)
						</cfif>
					)
					<!--- Check Business Segment/Class Code restriction --->
					<cfif arguments.businessSegmentsOn>
						<cfif this.businessSegManager.getClassCodesOn()>
							<cfset ContractClassCodeList = "" />
							<cfsilent>
							<cfif arguments.responsibleUserId NEQ "">
								<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
								<cfset qGetUserClassCodes = businessSegManager.getActiveClassCodes(arguments.responsibleUserId, 0) />
								<cfset ContractClassCodeList = ValueList(qgetUserClassCodes.class_code_id)>
							</cfif>
							</cfsilent>
							INNER JOIN Class_Code
							ON	Class_Code.Business_Segment_ID = Contract_Main.Business_Segment_ID
							INNER JOIN User_Class_Code
							ON	User_Class_Code.Deleted = 0
							AND	Class_Code.Class_Code_ID = User_Class_Code.Class_Code_ID
							AND	User_Class_Code.User_ID = _Users.User_ID
							AND
							(
								1=2
								<cfloop list="#ContractClassCodeList#" index="thisClassCode">
								OR Class_Code.Class_Code_ID = #thisClassCode#
								</cfloop>
							)
						<cfelse>
							INNER JOIN User_Business_Segment
							ON	User_Business_Segment.Deleted = 0
							AND	User_Business_Segment.Business_Segment_ID = Contract_Main.Business_Segment_ID
							AND	User_Business_Segment.User_ID = _Users.User_ID
						</cfif>
					</cfif>
					LEFT JOIN Authority_Sequence ON
					<cfif appSettings.getAuthority_Sequence_For_HQ_Only()>
						User_Positions.Service_Market_ID IS NULL AND
						User_Positions.Service_Region_ID IS NULL AND
						User_Positions.Service_Zone_ID IS NULL AND
					</cfif>
					Authority_Sequence.Deleted = 0 AND
					Authority_Sequence.Authority_Sequence_Order = Program_Approvable_Positions.Authority_Sequence_Order
			WHERE	Contract_Main.Contract_Status_Type_IDX = 2
			<!--- Dev Note: When "Custom_Deduction_workflow" app setting is ON, do not show NRA.
			Kerry does want to see NRA and so we used the app setting which is being used for Kerry only.
			--->
			<cfif appSettings.get_Setting('Custom_Deduction_workflow') eq '1'>
			AND 1 = 0
			</cfif>
			AND		Contract_Main.Deleted = 0
			AND 	NOT EXISTS
					(
						SELECT Profile_ID
						FROM   Program_Approvable_Profiles
						WHERE	Program_Approvable_Profiles.Contract_Main_ID = Contract_Main.Contract_Main_ID
						AND		Program_Approvable_Profiles.Authority_Sequence_Order = Program_Approvable_Positions.Authority_Sequence_Order
						AND     Program_Approvable_Profiles.User_Positions_ID = Program_Approvable_Positions.User_Positions_ID
					)

			<cfif arguments.programId NEQ 0>
			AND		Contract_Main.Contract_Main_ID = #arguments.programId#
			</cfif>
            <cfif arguments.plannerId NEQ 0>
			AND		(Contract_Main.Planner_ID = #arguments.plannerId# OR Planners.Parent_Planner_ID = #arguments.plannerId#)
            </cfif>
			AND		(Authority_Sequence.Authority_Sequence_ID IS NULL OR Authority_Sequence.Authority_Sequence_ID = _Users.Authority_Sequence_ID)

            SELECT  *
            FROM    ##Tmp_Program_NRA_List
            <cfif arguments.programId NEQ 0>
			ORDER BY Service_Zone_ID DESC, Service_Region_ID DESC, Service_Market_ID DESC, Authority_Sequence_Order DESC
			<cfelse>
			ORDER BY Service_Zone_ID DESC, Service_Region_ID DESC, Service_Market_ID DESC, Authority_Sequence_Order DESC
			</cfif>
		</cfquery>

		<cfreturn qGetNextApprovalbleUsers />

	</cffunction>

	<cffunction name="getUsersAboveProgram" output="true" returntype="query">
		<cfargument name="programId" type="numeric" required="true" />
		<cfargument name="sortBy" type="string" required="true" />

		<cfquery name="qGetUsersAboveProgram" datasource="#application.datasource#">

			declare @Hide_BSA_Users bit

			SELECT	@Hide_BSA_Users			= Hide_BSA_Users
			FROM	_Application_Settings

			select	creating_user_position_id, Above_UP.position_label, _users.user_id, _users.name_first + ' ' + _users.name_last as user_full_name,
					authority_sequence.authority_sequence_order, authority_sequence.authority_sequence_name,
					profiles.profiles_desc
			from	contract_main

			inner join User_Positions
			on	User_Positions.User_Positions_id = contract_main.creating_user_position_id

			-- get user positions above
			inner JOIN	dbo.User_Positions Above_UP
			ON 	Above_UP.Deleted = 0
			AND
			(
				-- Get HQ
				(
					Above_UP.Service_Zone_ID IS NULL -- HQ
				)
				OR
				-- Get Zone
				(
					Above_UP.Service_Zone_ID = dbo.User_Positions.Service_Zone_ID -- Is zone
				AND 	Above_UP.Service_Region_ID IS NULL -- Is zone
				AND	User_Positions.Service_Zone_ID IS NOT NULL -- I am zone or below
				)
				OR
				-- Get Region
				(
					Above_UP.Service_Region_ID = dbo.User_Positions.Service_Region_ID
				AND 	Above_UP.Service_Market_ID IS NULL -- Is region
				AND	User_Positions.Service_Region_ID IS NOT NULL -- I am region or below
				)
				OR
				-- Get Market
				(
					Above_UP.Service_Market_ID = dbo.User_Positions.Service_Market_ID
				AND	User_Positions.Service_Market_ID IS NOT NULL -- I am market
				)
			)

			-- get users from the user positions above
			inner join user_position_holders
			on	user_position_holders.User_Positions_ID = Above_UP.User_Positions_ID
			and	user_position_holders.deleted = 0

			inner join _users
			on	_users.user_id = user_position_holders.user_id
			and	_users.deleted = 0
			AND 	(@Hide_BSA_Users = 0 OR _users.User_Rights_ID IS NULL OR _users.User_Rights_ID != 9999)

			left join authority_sequence
			on	authority_sequence.authority_sequence_id = _users.authority_sequence_id
			<cfif application.appSettingsGet.getAuthority_Sequence_For_HQ_Only()>
			AND		Above_UP.Service_Market_ID IS NULL
			AND		Above_UP.Service_Region_ID IS NULL
			AND		Above_UP.Service_Zone_ID IS NULL
			</cfif>

			inner join profiles
			on	profiles.profiles_id = _users.profiles_id

			where	contract_main.contract_main_id = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer" />
			<cfif arguments.sortBy eq "Name">
				order by user_full_name, Above_UP.Service_Zone_ID, Above_UP.Service_Region_ID, Above_UP.Service_Market_ID, authority_sequence.authority_sequence_order, profiles.profiles_desc
			<cfelseif arguments.sortBy eq "Profile">
				order by profiles.profiles_desc, Above_UP.Service_Zone_ID, Above_UP.Service_Region_ID, Above_UP.Service_Market_ID, authority_sequence.authority_sequence_order, user_full_name
			<cfelse>
				order by Above_UP.Service_Zone_ID, Above_UP.Service_Region_ID, Above_UP.Service_Market_ID, authority_sequence.authority_sequence_order, profiles.profiles_desc, user_full_name
			</cfif>



		</cfquery>

		<cfreturn qGetUsersAboveProgram />

	</cffunction>

	<cffunction name="getCRAAnalysisReport" output="false" returntype="query">

		<cfargument name="programId" type="numeric" required="true" />
		<cfargument name="lUsers" type="string" required="no" />

		<cfquery name="qGetCRAAnalysisReport" datasource="#application.datasource#">

			IF OBJECT_ID('tempdb..##Temp_CRA_Users') IS NOT NULL
			DROP TABLE ##Temp_CRA_Users

			CREATE TABLE ##Temp_CRA_Users
			(
				User_ID nvarchar(50)
			)

			<cfloop index="indx" list="#arguments.lUsers#">

				INSERT INTO ##Temp_CRA_Users (User_ID) values ('#indx#')

			</cfloop>

			EXEC Program_CRA_Analysis_Report #arguments.programId#

			IF OBJECT_ID('tempdb..##Temp_CRA_Users') IS NOT NULL
			DROP TABLE ##Temp_CRA_Users

		</cfquery>

		<cfreturn qGetCRAAnalysisReport />

	</cffunction>
	<cffunction name="displayAuthoritySequence" output="false" returntype="boolean">

		<cfset authoritySequenceManager = CreateObject("component", "components.user.AuthoritySequenceManager").init() />
		<cfset qAuthoritySequence = authoritySequenceManager.getAll()>
		<cfreturn qAuthoritySequence.recordCount />

	</cffunction>

</cfcomponent>