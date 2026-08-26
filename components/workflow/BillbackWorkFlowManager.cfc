<!---
Name: 		BillbackWorkFlowManager.cfc
Copyright:	(c) 2011 Blacksmith Applications, Inc.
Description:	I am the interface to billback workflow data.
Parameters:	N/A
Usage:		N/A
--->

<cfcomponent name="BillbackWorkFlowManager" displayname="BillbackWorkFlowManager" extends="components.Billback.BillbackManager">

<cfscript>
	variables.settingsService = createObject("component","mvc.Models.SettingsService");
</cfscript>

	<cffunction name="getWorkFlowData" output="false" returntype="query" hint="function to return billback workflow data">
		
		<cfargument name="BillbackID" type="string" required="true" />
		<cfargument name="getTimeZoneOffSet" type="boolean" required="false" default="1" />
		<cfargument name="callFromCF" type="boolean" required="false" default="0" />

		<cfscript>
			//set local variables
			var sBillbackID				= "";
			var qWorkflowData			= "";
			var qWorkflowDataRet		= "";
			var DiffLocalTimeZoneAndEST	= 0;
			var useDayLightSavingsTime	= 0;
			var preserveTimeFormat		= 0;
			var bGetTimeZoneOffSet		= 1;
			var bSelectQuery			= 1;
			var bCalledFromCF			= 0;

			//assign local variables
			sBillbackID 		= arguments.BillbackID;
			bGetTimeZoneOffSet	= arguments.getTimeZoneOffSet;
			bCalledFromCF		= arguments.callFromCF;	

			//set these values when not calling from CF
			if (!bCalledFromCF)
			{
				DiffLocalTimeZoneAndEST = variables.settingsService.DiffLocalTimeZoneAndEST();
				// Without using "INT", the value is 'YES' without single quotes, causing issues.
				useDayLightSavingsTime = int(request.AccessStructure.useDayLightSavingsTime);
			}
			preserveTimeFormat = 1;
		</cfscript>
		
		<cfstoredproc procedure="USP_Get_Billback_Workflow_Data" datasource="#application.datasource#">
		
			<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@@Billback_ID" value = "#sBillbackID#" null="no" />
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER"	dbVarName = "@@DiffLocalTimeZoneAndEST" value = "#DiffLocalTimeZoneAndEST#" null="no" />
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER"	dbVarName = "@@UseDayLightSavingsTime" value = "#useDayLightSavingsTime#" null="no" />
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER"	dbVarName = "@@PreserveTimeFormat" value = "#preserveTimeFormat#" null="no" />
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER"	dbVarName = "@@GetTimeZoneOffSet" value = "#bGetTimeZoneOffSet#" null="no" />
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER"	dbVarName = "@@SelectQuery" value = "#bSelectQuery#" null="no" />
			<cfprocresult name="qWorkflowData" />
			
		</cfstoredproc>
		
		<cfset qWorkflowDataRet = qWorkflowData />
		
		<cfreturn qWorkflowDataRet />
		
	</cffunction>

	<cffunction name="saveBillbackAgreeReason" output="true" hint="function to save a list of reasons why a user could only agree">
		
		<cfargument name="BillbackID"	type="string" 	required="true" />
		<cfargument name="userId" 	type="string" 	required="true" />
		<cfargument name="lAgreeResons"	type="string" 	required="true" />
		
		<cfscript>
			//set local variables
			var sBillbackID		= "";
			var sUserID		= "";
			var lAgreeReasons	= "";
			var indx		="";
	
			//assign local variables
			sBillbackID 		= arguments.BillbackID;
			sUserID 		= arguments.userId;
			lAgreeReasons 		= arguments.lAgreeResons;
	
		</cfscript>
	
		<!--- first delete any entries for this user/Billback combination --->
		<cfquery name="qDeleteBillbackAgreeReason" datasource="#application.datasource#">
		
			DELETE	FROM Billback_Agree_Reason
			WHERE	User_Id = <cfqueryparam value="#sUserID#" cfsqltype="CF_SQL_VARCHAR" />
			AND		Billback_ID = <cfqueryparam value="#sBillbackID#" cfsqltype="CF_SQL_VARCHAR" />
			
		</cfquery>
		
		<!--- now loop over the list of agree reasons and save them --->
		<cfloop list="#lAgreeReasons#" index="indx" delimiters="|">
			<cfquery name="qDeleteBillbackAgreeReason" datasource="#application.datasource#">
			
				INSERT INTO Billback_Agree_Reason
					(User_Id, Billback_ID, Agree_Reason)
				VALUES
					(<cfqueryparam value="#sUserID#" cfsqltype="CF_SQL_VARCHAR" />, <cfqueryparam value="#sBillbackID#" cfsqltype="CF_SQL_VARCHAR" />, <cfqueryparam value="#indx#" cfsqltype="CF_SQL_VARCHAR" />)
				
			</cfquery>
		</cfloop>
		
	</cffunction>

	<cffunction name="getBillbackAgreeReason" output="false" returntype="query" hint="function to get a list of reasons why a user could only agree">
		
		<cfargument name="BillbackID"	type="string" 	required="true" />
		<cfargument name="userId" 	type="string" 	required="true" />
		
		<cfscript>
			//set local variables
			var sBillbackID		= "";
			var sUserID		= "";
	
			//assign local variables
			sBillbackID 		= arguments.BillbackID;
			sUserID 		= arguments.userId;
	
		</cfscript>
	
		<!--- get the agree reasons for a given user --->
		<cfquery name="qGetBillbackAgreeReason" datasource="#application.datasource#">
		
			SELECT	Agree_Reason
			FROM 	Billback_Agree_Reason
			WHERE	User_Id = <cfqueryparam value="#sUserID#" cfsqltype="CF_SQL_VARCHAR" />
			AND		Billback_ID = <cfqueryparam value="#sBillbackID#" cfsqltype="CF_SQL_VARCHAR" />
			
		</cfquery>
		
		<cfreturn qGetBillbackAgreeReason />
		
	</cffunction>
	

	<!--- Get the next approvable user list for billback. Most of this query is from "components\Billback\BillbackManager.cfc" --->
	<cffunction name="getNextApprovableUsers" output="true" returntype="query">
	
		<cfargument name="billbackId" type="string" required="true" />
		
		<!------ 
		Different conditions to check for
		
		- User not in approve forbid list or user in allow list
		- user not in agreed list
		- user has approval rights
		
		 ----->
		 
		<!------ Get application settings ----->
		<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
		<cfset appSettings = genSettingsManager.get()>
		
		<cfset forbidType = appSettings.getForbidAllowProfilesInTemplates() />
		
		<!------ Get Billback Workflow ----->
		<cfquery name="qGetApprovalbleUsers" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmp_CRA') IS NOT NULL
			DROP TABLE ##tmp_CRA

			SELECT	TOP 1 *
			INTO	##tmp_CRA
			FROM	BillbackApprovablePositions
			WHERE	BillbackApprovablePositions.Billback_ID = '#arguments.billbackId#'
						AND NOT EXISTS
						(	SELECT DISTINCT BB_Agreed_Info.User_Position_ID
						FROM       	BB_Agreed_Info
						LEFT JOIN	Authority_Sequence
						ON			Authority_Sequence.Authority_Sequence_ID = BB_Agreed_Info.Authority_Sequence_ID
						WHERE      	BB_Agreed_Info.Billback_ID = BillbackApprovablePositions.Billback_ID
									AND		BB_Agreed_Info.Deleted = 0
									AND 	User_Position_ID IS NOT NULL
									AND		BillbackApprovablePositions.User_Positions_ID = BB_Agreed_Info.User_Position_ID
									AND		ISNULL(BillbackApprovablePositions.Authority_Sequence_Order, 0) = ISNULL(Authority_Sequence.Authority_Sequence_Order, 0)
						)
			ORDER BY BillbackApprovablePositions.Service_Market_ID DESC, BillbackApprovablePositions.Service_Region_ID DESC, BillbackApprovablePositions.Service_Zone_ID DESC, BillbackApprovablePositions.Authority_Sequence_Order DESC

			
			SELECT	DISTINCT
					Position_To_Approve.User_Positions_ID,
					Approve_Authority_Sequence.Authority_Sequence_Name,
					Approve_Authority_Sequence.Authority_Sequence_ID,
					_Users.Name_First + ' ' + _Users.Name_Last User_Full_Name,
					ltrim(rtrim(_Users.User_Email)) User_Email,
					Profiles.Profiles_Desc,
					Position_To_Approve.Position_Label,
					Position_To_Approve.Service_Zone_ID,
					Position_To_Approve.Service_Region_ID,
					Position_To_Approve.Service_Market_ID,
					Approve_Authority_Sequence.Authority_Sequence_Order
			FROM	Billback
					INNER JOIN Billback_Approvable_Positions ON Billback_Approvable_Positions.Billback_ID =  Billback.Billback_ID
					LEFT JOIN Billback_Program ON Billback_Program.Deleted = 0 AND	Billback_Program.Billback_ID = Billback.Billback_ID
					LEFT JOIN Contract_Main ON Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
					INNER JOIN User_Positions Position_To_Approve ON Position_To_Approve.User_Positions_ID = Billback_Approvable_Positions.User_positions_ID
					/*
					INNER JOIN User_Positions Position_To_Approve
					ON 	Position_To_Approve.User_Positions_ID = 
					(
					SELECT	TOP 1 User_positions_ID
					FROM	BillbackApprovablePositions
					WHERE	BillbackApprovablePositions.Billback_ID = Billback.Billback_ID
					ORDER BY BillbackApprovablePositions.Service_Market_ID DESC, BillbackApprovablePositions.Service_Region_ID DESC, BillbackApprovablePositions.Service_Zone_ID DESC, BillbackApprovablePositions.Authority_Sequence_Order DESC
					)
					*/
					INNER JOIN User_Position_Holders ON User_Position_Holders.Deleted = 0 AND User_Position_Holders.User_Positions_ID = Position_To_Approve.User_Positions_ID
					INNER JOIN _Users ON _Users.Deleted = 0 AND	_Users.User_ID = User_Position_Holders.User_ID
					<!------ User not in forbid list/in allow list ----->
					AND	_Users.Profiles_ID 
					<cfif forbidType EQ 1>not </cfif><!------ forbit type=1, forbid, 0=allow ----->
					IN 
					(	
						SELECT 	DISTINCT profile_id 
						FROM 	Profile_Forbidden_Template 
						WHERE 	Deleted = 0
						AND 	Forbid_Type = #forbidType#
						AND		Forbid_Access_Type = 4<!------ 4=approve billback ----->
						AND 	template_id = Contract_Main.ProgramType_ID
					)					
					
					<!------ user not in agreed list ----->
					AND	_Users.User_ID NOT IN 
					(
						SELECT	DISTINCT BB_Agreed_Info.User_ID
						FROM	BB_Agreed_Info							
						WHERE	BB_Agreed_Info.Billback_ID = Billback.Billback_ID
						AND		BB_Agreed_Info.Deleted = 0
					)

					INNER JOIN Profiles ON Profiles.Profiles_ID = _Users.Profiles_ID
					<!------ D10310: [Deepa] The LEFT JOIN on BB_Analyst was in the wrong place, moved it down from inside the _users join ----->
					<!------ Analyst ----->
					LEFT JOIN BB_Analyst ON	BB_Analyst.Deleted = 0 AND BB_Analyst.Analyst_User_ID = _Users.User_ID
					INNER JOIN Profiles_Settings ON	Profiles_Settings.Deleted = 0 AND Profiles_Settings.Profiles_ID = _Users.Profiles_ID
					<!------ user has approval rights ----->
					INNER JOIN BB_Profiles_Settings ON BB_Profiles_Settings.Deleted = 0 AND	BB_Profiles_Settings.Profiles_ID = _Users.Profiles_ID AND BB_Profiles_Settings.BB_Approve = 1
					LEFT JOIN Authority_Sequence Approve_Authority_Sequence ON Approve_Authority_Sequence.Authority_Sequence_ID = _Users.Authority_Sequence_ID								
			WHERE	Billback.Billback_ID = '#arguments.billbackId#'
			AND		Billback.Billback_Status_ID = 2 <!--- Only display CRA when billback is in RFA status --->
			<!--- 
			If Billback_Approvable_Positions.Authority_Sequence_Order is 0, user also should not have authority sequence (Approve_Authority_Sequence.Authority_Sequence_Order = NULL)
			-- If Billback_Approvable_Positions.Authority_Sequence_Order is not 0, user should have same authority sequence
			--->
			AND		ISNULL(Approve_Authority_Sequence.Authority_Sequence_Order, 0) = Billback_Approvable_Positions.Authority_Sequence_Order
			<!---- Not in CRA ---->
			AND		NOT EXISTS ( -- Not in CRA
				SELECT	1
				FROM	##tmp_CRA t
				WHERE	t.User_Positions_ID = Billback_Approvable_Positions.User_positions_ID
				<cfif application.appSettingsGet.getAuthority_Sequence_For_HQ_Only()>
					<!--- a)This position is not HQ or b)Position is HQ and Authority Sequence matches  --->
					AND	(t.Service_Zone_ID IS NOT NULL OR t.Authority_Sequence_Order = Billback_Approvable_Positions.Authority_Sequence_Order)
				<cfelse>
					AND t.Authority_Sequence_Order = Billback_Approvable_Positions.Authority_Sequence_Order
				</cfif>
			)
			ORDER BY Position_To_Approve.Service_Zone_ID DESC, Position_To_Approve.Service_Region_ID DESC, Position_To_Approve.Service_Market_ID DESC, Approve_Authority_Sequence.Authority_Sequence_Order DESC
		</cfquery>
		
		<cfreturn qGetApprovalbleUsers />
		
	</cffunction>
	
	<!--- D28386: BB CRA Analysis Report/Anand Rao/14-Mar-2012 --->
	
	<cffunction name="getUsersAboveBillback" output="true" returntype="query">
		<cfargument name="BillbackID" type="string" required="true" />
		<cfargument name="sortBy" type="string" required="true" />
		
		<cfquery name="qGetUsersAboveBillback" datasource="#application.datasource#">
		
			declare @Hide_BSA_Users bit
	
			SELECT	@Hide_BSA_Users			= Hide_BSA_Users
			FROM	_Application_Settings
			
			select	BB_Creator_User_Position_ID, Above_UP.position_label, _users.user_id, _users.name_first + ' ' + _users.name_last as user_full_name,
					authority_sequence.authority_sequence_order, authority_sequence.authority_sequence_name,
					profiles.profiles_desc
			from	Billback
			
			inner join User_Positions
			on	User_Positions.User_Positions_id = Billback.BB_Creator_User_Position_ID
			
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
			
			where	Billback.Billback_ID = <cfqueryparam value="#arguments.BillbackID#" cfsqltype="CF_SQL_VARCHAR" />
			<cfif arguments.sortBy eq "Name">
				order by user_full_name, Above_UP.Service_Zone_ID, Above_UP.Service_Region_ID, Above_UP.Service_Market_ID, authority_sequence.authority_sequence_order, profiles.profiles_desc
			<cfelseif arguments.sortBy eq "Profile">
				order by profiles.profiles_desc, Above_UP.Service_Zone_ID, Above_UP.Service_Region_ID, Above_UP.Service_Market_ID, authority_sequence.authority_sequence_order, user_full_name
			<cfelse>
				order by Above_UP.Service_Zone_ID, Above_UP.Service_Region_ID, Above_UP.Service_Market_ID, authority_sequence.authority_sequence_order, profiles.profiles_desc, user_full_name
			</cfif>
	 
		</cfquery>
		
		<cfreturn qGetUsersAboveBillback />
		
	</cffunction>
	<cffunction name="getBBCRAAnalysisReport" output="false" returntype="query">
	
		<cfargument name="BillbackId" type="string" required="true" />
		<cfargument name="lUsers" type="string" required="no" />
		
		<cfquery name="qGetBBCRAAnalysisReport" datasource="#application.datasource#">
		
			IF OBJECT_ID('tempdb..##Temp_Billback_CRA_Users') IS NOT NULL
			DROP TABLE ##Temp_Billback_CRA_Users

			CREATE TABLE ##Temp_Billback_CRA_Users
			(
				User_ID nvarchar(50)
			)

			<cfloop index="indx" list="#arguments.lUsers#">
			
				INSERT INTO ##Temp_Billback_CRA_Users (User_ID) values ('#indx#')
				
			</cfloop>
			
			EXEC Billback_CRA_Analysis_Report '#arguments.BillbackId#'
			
			IF OBJECT_ID('tempdb..##Temp_Billback_CRA_Users') IS NOT NULL
			DROP TABLE ##Temp_Billback_CRA_Users

		</cfquery>
		
		<cfreturn qGetBBCRAAnalysisReport />
		
	</cffunction>	
	
	<cffunction name="displayAuthoritySequence" output="false" returntype="boolean">
	
		<cfset authoritySequenceManager = CreateObject("component", "components.user.AuthoritySequenceManager").init() />
		<cfset qAuthoritySequence = authoritySequenceManager.getAll()>
		<cfreturn qAuthoritySequence.recordCount />
	
	</cffunction>

	<!--- get the Auto approval analysis info --->
	<cffunction name="getAutoApprovalAnalysisInfo" access="public" returntype="query">
		<cfargument name="billbackID" type="string" required="true">

		<cfset var qgetAutoApprovalAnalysisInfo = "" />	
		<cfstoredproc procedure="BB_Auto_Approve_Analysis" datasource="#application.datasource#">
			<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName="@billback_id" value="#arguments.billbackID#" null="no">
			<cfprocresult name = "qgetAutoApprovalAnalysisInfo">
		</cfstoredproc>

		<cfreturn qgetAutoApprovalAnalysisInfo />
	</cffunction>
	
</cfcomponent>