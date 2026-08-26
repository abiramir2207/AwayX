
<cfcomponent hint="User Manager" extends="components.base">

<!------ Get application settings ----->
		<cfset appSettings = application.appsettingsGet>

	<cffunction name="init" output="false" returntype="components.user.UserManager">

		<cfreturn this />

	</cffunction>

	<cffunction name="search" output="false" returntype="query">
	<!--- Dev Note: Milan - 11403. I had to change the argument name to SearchParam from search because when this function
		  was being called in a loop, CF threw an error (Entity has incorrect type for being called as a function),
		  I had to change the argument name to be different from the function name --->
		<cfargument name="searchParam" type="struct" required="false" default="#StructNew()#" />

		<cfset this.searchParam = arguments.searchParam>
		<cfparam name="this.searchParam.returnUserSecondaryPositionsForUser" 	default="">
		<cfparam name="this.searchParam.sortBy" 	default="_Users.Name_First">

		<cfparam name="this.searchParam.userPositionType" 	default="P">
		<cfif Trim(this.searchParam.userPositionType) EQ "">
			<cfset this.searchParam.userPositionType = "P,S" />
		</cfif>

		<cfquery name="qGetUsers" datasource="#application.datasource#">
			SELECT	_Users.User_ID, _Users.User_Code,
					_Users.Name_First + ' ' + _Users.Name_Last AS User_Full_Name,
					_Users.User_Email,
					_Users.Name_First, _Users.Name_Last,
					User_Position_Holders.User_Position_Type, User_Positions.User_Positions_ID, User_Positions.Position_Label,
					_Users.Profiles_ID,
					_Users.Work_Phone_1 + '-' + _Users.Work_Phone_2 + '-' + _Users.Work_Phone_3 As User_Work_Phone,
					_Users.Work_Phone_Ext, _Users.Company_Name,
					Position_Level = CASE
													WHEN User_Positions.Service_Market_Id IS NOT NULL THEN 3
													WHEN User_Positions.Service_Region_Id IS NOT NULL
															AND User_Positions.Service_Market_Id IS NULL THEN 2
													WHEN User_Positions.Service_Zone_Id IS NOT NULL
															AND User_Positions.Service_Region_Id IS NULL
															AND User_Positions.Service_Market_Id IS NULL THEN 1
													ELSE 0
												 END,
					_Users.User_Code
			FROM	_Users
					INNER JOIN User_Position_Holders
					ON
					User_Position_Holders.User_ID = _Users.User_ID
					AND
					(
					User_Position_Holders.User_Position_Type IN (#ListQualify(this.searchParam.userPositionType, "'", ",")#)
					<cfif Len(this.searchParam.returnUserSecondaryPositionsForUser) GT 0>
					OR _Users.User_ID = '#this.searchParam.returnUserSecondaryPositionsForUser#'
					</cfif>
					)
					<cfif Super.variableExist("this.searchParam.userId", "")>
					AND _Users.User_ID = '#this.searchParam.userId#'
					</cfif>
					<cfif Super.variableExist("this.searchParam.excludeUserIdList", "")>
					AND _Users.User_ID NOT IN (<cfqueryparam value="#this.searchParam.excludeUserIdList#" cfsqltype="CF_SQL_VARCHAR" list="true">)
					</cfif>
					AND User_Position_Holders.Deleted = 0
					AND	User_Position_Holders.User_Positions_ID <> 0
					<cfif Super.variableExist("this.searchParam.userPosition", "")>
					<cfif ListLen(this.searchParam.userPosition, ",") GT 0>
					AND User_Position_Holders.User_Positions_ID IN (#this.searchParam.userPosition#)
					</cfif>
					</cfif>
					INNER JOIN User_Positions
					ON
					User_Positions.Deleted = 0
					AND User_Positions.User_Positions_ID = User_Position_Holders.User_Positions_ID

					<cfif appSettings.getHide_BSA_Users() IS 1>
					AND (_Users.User_Rights_ID IS NULL
					OR _Users.User_Rights_ID != 9999)
					</cfif>
			WHERE
					_Users.Deleted = 0
					AND
					_Users.Profiles_ID IS NOT NULL<!--- D30834:Incorrect syntax near ')' --->
					AND Len(_Users.Name_First) > 0
					<cfif Super.variableExist("this.searchParam.excludeList", "")>
					AND	_Users.User_ID NOT IN (#ListQualify(this.searchParam.excludeList, "'", ",")#)
					</cfif>
					<cfif Super.variableExist("this.searchParam.eligible_rsp","")>
					AND _Users.Is_Eligible_RSP = 1
					</cfif>
					<cfif Super.variableExist("this.searchParam.Is_On_Behalf_Of","")>
					AND _Users.Is_On_Behalf_Of = <cfqueryparam value="#this.searchParam.Is_On_Behalf_Of#" null="No" cfsqltype="CF_SQL_BIT">
					</cfif>
					<cfif isDefined("this.searchParam.UserClassCodeList")>
					AND
					(
						1=2
						<cfloop list="#this.searchParam.UserClassCodeList#" index="thisClassCode">
						OR #thisClassCode# IN
						(SELECT User_Class_Code.Class_Code_Id
						FROM	User_Class_Code
						WHERE	User_Class_Code.Deleted = 0
								AND User_Class_Code.User_Id = _Users.User_ID)
						</cfloop>
					)
					<!--- Dev Note: Milan - 11403 Conagra wants to reassign a program when all the class codes for a program
						  match the reassigned RSP's class codes. --->
					<cfelseif isDefined("this.searchParam.CheckUserClassCodeList")>
						<cfloop list="#this.searchParam.CheckUserClassCodeList#" index="thisClassCode">
						AND #thisClassCode# IN
						(SELECT User_Class_Code.Class_Code_Id
						FROM	User_Class_Code
						WHERE	User_Class_Code.Deleted = 0
						AND User_Class_Code.User_Id = _Users.User_ID)
						</cfloop>
					</cfif>
					<!--- 	Tim Ford - 03/23/2015: WR 48820 - Reassign program filtering on Segment & Class Codes.
							If class codes are on then don't filter on Business Segments --->
					<cfif isDefined("this.searchParam.Contract_Business_Segment_ID") and not appSettings.getClassCodesOn()>
						AND _Users.User_ID IN
						(select User_Business_Segment.User_ID
						from User_Business_Segment
						where User_Business_Segment.Business_Segment_ID = '#this.searchParam.Contract_Business_Segment_ID#'
						and User_Business_Segment.deleted = 0)
					</cfif>
			ORDER BY #this.searchParam.sortBy#
		</cfquery>

		<cfreturn qGetUsers />

	</cffunction>

	<cffunction name="getPositionId" output="true" returntype="string">

		<cfargument name="userId" type="string" required="true" />
		<cfargument name="isPrimary" type="numeric" required="false" default="1" />
		<cfargument name="returnRawQueryIfLongList" type="numeric" required="false" default="0" />

		<cfset returnValue = 0 />

		<cfset var useLakebase = application.oLakebase.isEnabled()
				AND application.oLakebase.isTableMigrated("user_position_holders")
				AND application.oLakebase.isTableMigrated("user_positions")>

		<cfif useLakebase>
			<!--- Lakebase path: PostgREST has no ad-hoc INNER JOIN, so the join is done client-side
			      in two selectRows() calls instead of a single stored query. --->
			<cftry>
				<cfset var holderFilter = {
					"user_id"           = "eq.#arguments.userId#",
					"deleted"           = "eq.false",
					"user_positions_id" = "neq.0"
				}>
				<cfif arguments.isPrimary>
					<!--- User_Position_Type is a fixed-width column stored space-padded (e.g. "P   ");
					      use like.P* instead of eq.P so this doesn't depend on trailing-space comparison
					      semantics of the underlying Postgres column type. --->
					<cfset holderFilter["user_position_type"] = "like.P*">
				</cfif>
				<cfset var holders = application.oLakebase.selectRows("user_position_holders", holderFilter)>

				<cfset var candidateIds = []>
				<cfloop array="#holders#" index="h">
					<cfif NOT arrayFind(candidateIds, h.user_positions_id)>
						<cfset arrayAppend(candidateIds, h.user_positions_id)>
					</cfif>
				</cfloop>

				<cfset var validIds = []>
				<cfif arrayLen(candidateIds)>
					<cfset var positions = application.oLakebase.selectRows("user_positions", {
						"user_positions_id" = "in.(#arrayToList(candidateIds)#)",
						"deleted"            = "eq.false"
					})>
					<cfloop array="#positions#" index="p">
						<cfset arrayAppend(validIds, p.user_positions_id)>
					</cfloop>
				</cfif>

				<cfif arrayLen(validIds)>
					<cfset returnValue = arrayToList(validIds) />
				</cfif>

				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebase = false>
				</cfcatch>
			</cftry>
		</cfif>

		<cfif NOT useLakebase>
			<cfquery name="qGetPositionId" datasource="#application.datasource#">
				SELECT	DISTINCT User_Position_Holders.User_Positions_ID
				FROM	User_Position_Holders
					INNER JOIN User_Positions
					ON User_Positions.User_Positions_ID	= User_Position_Holders.User_Positions_ID
					AND User_Positions.Deleted = 0
				WHERE
						User_ID = '#arguments.userId#'
						<cfif arguments.isPrimary>
						AND  User_Position_Type = 'P'
						</cfif>
						AND	 User_Position_Holders.Deleted = 0
						AND	 User_Position_Holders.User_Positions_ID <> 0
			</cfquery>

			<cfif qGetPositionId.recordCount>
				<cfset returnValue = ValueList(qGetPositionId.User_Positions_ID, ",") />
			</cfif>
		</cfif>

		<cfif arguments.returnRawQueryIfLongList>
			<cfif Len(returnValue) GT 500>
				<cfset returnValue = getPositionIdString(arguments.userId) />
			</cfif>
		</cfif>

		<cfreturn returnValue />

	</cffunction>

	<cffunction name="getPositionIdString" output="true" returntype="string">

		<cfargument name="userId" type="string" required="true" />

		<cfset var returnValue1 = "" />
<!--- 		<cfsavecontent variable="returnValue1">
			SELECT	Position_Holder.User_Positions_ID
			FROM	User_Position_Holders Position_Holder
			WHERE
					Position_Holder.User_ID = '#arguments.userId#'
					AND	 Position_Holder.Deleted = 0
					AND	 Position_Holder.User_Positions_ID <> 0
		</cfsavecontent> --->
		<cfset returnValue1 = "SELECT Position_Holder.User_Positions_ID FROM User_Position_Holders Position_Holder WHERE Position_Holder.User_ID = '#arguments.userId#' AND	 Position_Holder.Deleted = 0 AND Position_Holder.User_Positions_ID <> 0" />

		<cfreturn returnValue1 />

	</cffunction>

	<cffunction name="getUser" output="false" returntype="query">

		<cfargument name="userId" type="string" required="true" />

		<cfquery name="qGetUsers" datasource="#application.datasource#">
			SELECT	_Users.User_ID, _Users.User_Email,
					_Users.Name_First + ' ' + _Users.Name_Last AS User_Full_Name,
					_Users.Name_First, _Users.Name_Last,
					_Users.Profiles_ID,
					_Users.Work_Phone_1 + '-' + _Users.Work_Phone_2 + '-' + _Users.Work_Phone_3 As User_Work_Phone,
					_Users.Work_Phone_Ext, _Users.Authority_Sequence_ID,
					_Users.Title, _Users.User_Number, User_Positions.Position_Label,
					_Users.Work_Address_1, _Users.Work_Address_2, _Users.Work_City, _Users.Work_State, _Users.Work_Zip, _Users.Company_Name,
					_Users.Crucible_File_Download, _states.State_Code,
					ISNULL(_Users.Is_Eligible_RSP, 0) as Is_Eligible_RSP, ISNULL(_Users.Is_On_Behalf_Of, 0) as Is_On_Behalf_Of,
				    Position_Level = CASE WHEN User_Positions.Service_Market_ID IS NOT NULL THEN 3
										  WHEN User_Positions.Service_Region_ID IS NOT NULL
											   AND User_Positions.Service_Market_ID IS NULL THEN 2
										  WHEN User_Positions.Service_Zone_ID IS NOT NULL
											   AND User_Positions.Service_Region_ID IS NULL
											   AND User_Positions.Service_Market_ID IS NULL THEN 1
										  ELSE 0
									 END,
					User_Position_Holders.User_Positions_ID,
					_Users.User_Code,
					_Users.Analytics_SSO_User_Name,
					_Users.Ember_Info
			FROM	_Users
					LEFT JOIN User_Position_Holders ON User_Position_Holders.User_ID = _Users.User_ID
						AND User_Position_Holders.User_Position_Type = 'P'
						AND User_Position_Holders.Deleted = 0
					LEFT JOIN User_Positions ON User_Positions.Deleted = 0
						AND User_Positions.User_Positions_ID = User_Position_Holders.User_Positions_ID
					LEFT JOIN _states ON _states.State_ID = _Users.Work_State
			WHERE
					_Users.Deleted = 0
					AND	_Users.User_ID = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

		<cfreturn qGetUsers />

	</cffunction>

	<cffunction name="getUserName" output="false" returntype="string">

		<cfargument name="userId" type="string" required="true" />

		<cfset userName = "" />

		<cfset qUser = getUser(arguments.userId) />
		<cfif qUser.recordCount>
			<cfset userName = qUser.User_Full_Name />
		</cfif>

		<cfreturn userName />

	</cffunction>

	<cffunction name="getUserEmail" output="false" returntype="string">

		<cfargument name="userId" type="string" required="true" />

		<cfset userEmail = "" />

		<cfset qUser = getUser(arguments.userId) />
		<cfif qUser.recordCount>
			<cfset userEmail = qUser.User_Email />
		<cfelse>
			 <cfset defaultAnalyst = createObject("component", "components.billback.BillbackAssignmentManager").getAnalysts(0,1,"") />
		<cfif defaultAnalyst.recordcount>
			 <cfset userEmail = defaultAnalyst.User_Email />
		</cfif>
		</cfif>

		<cfreturn userEmail />

	</cffunction>

	<cffunction name="getUserPosition" output="false" returntype="query">

		<cfargument name="userPositionId" type="numeric" required="true" />

		<cfset useLakebaseForqGetPosition = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("user_positions")>
<cfif useLakebaseForqGetPosition>
	<cftry>
		<cfset qGetPosition = application.oLakebase.toQuery(
			application.oLakebase.selectRows("user_positions", {
				"deleted" = "eq.0",
				"user_positions_id" = "eq.#arguments.userPositionId#",
				"select" = "*"
			}), "*"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetPosition = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetPosition>
<cfquery name="qGetPosition" datasource="#application.datasource#">
			SELECT	User_Positions.*
			FROM	User_Positions
			WHERE
					User_Positions.Deleted = 0
					AND
					User_Positions.User_Positions_ID = '#arguments.userPositionId#'
		</cfquery>
</cfif>

		<cfreturn qGetPosition />

	</cffunction>

	<cffunction name="getUserPositionList" output="false" returntype="query" description="Dev Note: 10778 BDensmore">

		<cfargument name="userPositionId" type="any" required="true" default="0" />

		<cfquery name="qGetPositionList" datasource="#application.datasource#">
			SELECT	User_Positions.Service_Market_ID
			FROM	User_Positions
			WHERE
					User_Positions.Deleted = 0

					AND User_Positions.User_Positions_ID In (#arguments.userPositionId#)
					And User_Positions.Service_Market_ID <> ''
					And User_Positions.Service_Market_ID IS NOT NULL
		</cfquery>

		<cfreturn qGetPositionList />

	</cffunction>
	<cffunction name="getBrokerEmailAddress" output="false" returntype="string">

		<cfargument name="userPositionId" type="numeric" required="true" />
		<cfargument name="checkForBusinessSegment" type="boolean" required="false" default="0" />
		<cfargument name="BusinessSegmentId" type="numeric" required="false" default="0" />

		<cfset brokerEmail = "" />

		<!------ Get user position ----->
		<cfset qGetPosition = this.getUserPosition(arguments.userPositionId) />

		<cfif qGetPosition.Service_Market_ID NEQ "" AND Isnumeric(qGetPosition.Service_Market_ID)>

			<cfset qGetBrokers = CreateObject("component", "components.geography.market").getBrokers(qGetPosition.Service_Market_ID, arguments.checkForBusinessSegment, arguments.BusinessSegmentId) />

			<cfset brokerEmail = ValueList(qGetBrokers.E_Mail, ";") />

			<cfset brokerEmail = REReplaceNoCase(brokerEmail, ",", ";", "ALL") />
			<cfset brokerEmail = ";#brokerEmail#" />

			<cfset brokerEmail = replaceMultipleChars(brokerEmail, ";") />

		</cfif>

		<cfreturn brokerEmail />

	</cffunction>

	<cffunction name="getBrokerId" output="false" returntype="string">

			<cfargument name="userPositionId" type="any" required="true" />
			<cfargument name="checkForBusinessSegment" type="boolean" required="false" default="0" />
			<cfargument name="BusinessSegmentId" type="numeric" required="false" default="0" />

			<cfset var brokerId = "" />

			<!------ Get user position ----->
			<cfset var qGetPosition = this.getUserPositionList(arguments.userPositionId) />
			<cfset var serviceIds = "" />

			 <cfif qGetPosition.RecordCount>
				<cfset serviceIds = ValueList(qGetPosition.Service_Market_ID) />
				<cfset qGetBrokers = CreateObject("component", "components.geography.market").getBrokerIds(serviceIds, arguments.checkForBusinessSegment, arguments.BusinessSegmentId) />

				<cfset brokerId = ValueList(qGetBrokers.Legacy_Broker_ID, ",") />
			 </cfif>

			<cfreturn brokerId />

	</cffunction>

	<cffunction name="getUserNumber" output="false" returntype="string">

		<cfargument name="userId" type="string" required="true" />

		<cfquery name="qGetUserNumber" datasource="#application.datasource#">
			SELECT	LTRIM(RTRIM(_Users.User_Number)) User_Number
			FROM	_Users
			WHERE
					User_ID = '#arguments.userId#'
					AND	 _Users.Deleted = 0
		</cfquery>

		<cfif qGetUserNumber.recordCount>
			<cfreturn qGetUserNumber.User_Number />
		<cfelse>
			<cfreturn "" />
		</cfif>

	</cffunction>

	<cffunction name="getUserNumberExists" output="true" returntype="string">

		<cfargument name="userId" type="string" required="true" />

		<cfset var userNumber = getUserNumber(arguments.userId) />

		<cfreturn Len(userNumber) GT 0 />

	</cffunction>

	<!--- Dev Note 9846: Clay: Determine if a user is an eligible RSP --->
	<cffunction name="isUserEligibleRSP" output="false" returntype="boolean">
		<cfargument name="userID" type="string" required="true" />

		<cfset useLakebaseForgetEligibleRspData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForgetEligibleRspData>
	<cftry>
		<cfset getEligibleRspData = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#arguments.userID#",
				"deleted" = "eq.0",
				"select" = "is_eligible_rsp"
			}), "is_eligible_rsp"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetEligibleRspData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetEligibleRspData>
<cfquery name="getEligibleRspData" datasource="#application.datasource#">
			select is_eligible_rsp from _users where user_id = '#arguments.userID#' and deleted = 0
		</cfquery>
</cfif>

		<cfif getEligibleRSPData.Recordcount GT 0>
			<cfreturn getEligibleRspData.is_eligible_rsp />
		<cfelse>
			<cfreturn 0 />
		</cfif>
	</cffunction>

	<cffunction name="getUserInfo" output="false" returntype="query">

		<cfargument name="userId" type="string" required="true" />

		<cfquery name="qUserInfo" datasource="#application.datasource#">
			SELECT	*
			FROM	_Users
			WHERE	_Users.User_ID = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

		<cfreturn qUserInfo />

	</cffunction>

	<cffunction name="getCurrentSystemAdmin" output="false" returntype="query">

		<cfset useLakebaseForqGetCurrentSystemAdmin = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForqGetCurrentSystemAdmin>
	<cftry>
		<cfset qGetCurrentSystemAdmin = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"is_system_administrator" = "eq.1",
				"deleted" = "eq.0",
				"limit" = "1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetCurrentSystemAdmin = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetCurrentSystemAdmin>
<cfquery name="qGetCurrentSystemAdmin" datasource="#application.datasource#">
			SELECT	TOP 1 *
			FROM 	_Users
			WHERE 	Is_System_Administrator = 1
			AND		Deleted = 0
		</cfquery>
</cfif>

		<cfreturn qGetCurrentSystemAdmin />

	</cffunction>

	<cffunction name="getUserIsHQ" output="true" returntype="boolean">

		<cfargument name="userId" type="string" required="true" />
		<cfargument name="isPrimary" type="numeric" required="false" default="0" />

		<cfquery name="qGetHQPositionId" datasource="#application.datasource#">
			SELECT	User_Position_Holders.User_Positions_ID
			FROM	User_Position_Holders
			INNER JOIN User_Positions
			ON 		User_Positions.User_Positions_ID	= User_Position_Holders.User_Positions_ID
			AND 	User_Positions.Deleted = 0
			WHERE
					User_ID = '#arguments.userId#'
					<cfif arguments.isPrimary>
					AND  User_Position_Type = 'P'
					</cfif>
					AND	 User_Position_Holders.Deleted = 0
					AND	 User_Position_Holders.User_Positions_ID <> 0
					AND		User_Positions.Service_Zone_ID IS NULL <!------ Zone ID will be null for a hq positions ----->
					AND		User_Positions.Service_Region_ID IS NULL <!------ Region ID will be null for a hq positions ----->
					AND		User_Positions.Service_Market_ID IS NULL <!------ Market ID will be null for a hq positions ----->
		</cfquery>

		<cfset returnValue = 0 />
		<cfif qGetHQPositionId.recordCount>
			<cfset returnValue = 1 />
		</cfif>

		<cfreturn returnValue />

	</cffunction>

	<cffunction name="getRSPList" access="remote" returnType="query" returnformat="json">
		<cfargument name="userId" type="string" required="true" />
		<cfargument name="programScorecardRestrictCreatedBy" type="numeric"  required="true" />
		<cfargument name="showSalesPersonSelectionOverride" type="any"  required="false" default="" />

		<!--- get related cfc's --->
		<cfset stStruct = StructNew() />

		<cfset RSPUserList = QueryNew("User_ID, User_Code, User_Full_Name, User_Email, Name_First, Name_Last, User_Position_Type, User_Positions_ID, Position_Label, Profiles_ID, User_Work_Phone, Work_Phone_Ext, Company_Name, Position_Level") />
		<cfset showSalesPersonSelection = false>
		<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />

		<cfset qCurrentUser = this.getUser(arguments.userId) />
		<cfif application.returned_customer_setting.responsible_person>
			<cfset stStruct.userPosition = this.getPositionId(arguments.userId, 0) />
			<!--- Dev Note: Clay 9478 - if display_eligible_rsp is on, display the pull-down list for results of 1 or greater. --->
			<cfif ListLen(stStruct.userPosition, ",") GT 1
						or	(appsettings.getDisplayEligibleRSP() EQ 1 and (qCurrentUser.Is_Eligible_RSP EQ 0 or qCurrentUser.Is_On_Behalf_Of EQ 1)) >
				<cfset showSalesPersonSelection = true />
			</cfif>
		</cfif>
		
		<cfif showSalesPersonSelection or arguments.showSalesPersonSelectionOverride eq 1>
			<!--- class codes --->
			<cfif businessSegManager.isEnabled() AND appSettings.getClassCodesOn()>
				<cfset qGetUserClassCodes = businessSegManager.getActiveClassCodes(arguments.userId, 0) />
				<cfset stStruct.UserClassCodeList = ValueList(qgetUserClassCodes.class_code_id)>
			</cfif>

			<cfset stStruct.returnUserSecondaryPositionsForUser = arguments.userId >
			<cfif arguments.programScorecardRestrictCreatedBy >
				<cfset stStruct.userId = arguments.userId>
			</cfif>
			<cfif appsettings.getDisplayEligibleRSP() EQ 1>
				<cfset stStruct.Eligible_RSP = 1>
				<cfset stStruct.Is_On_Behalf_Of = 0>
			</cfif>
			<cfset stStruct.userPositionType = "P,S">
			<cfset stStruct.sortBy = "Position_Level,User_Positions.Position_Label,_Users.Name_First" />
			<cfset RSPUserList = this.search(stStruct) />
		<cfelse>
			<cfset RSPUserList = getUser(arguments.userId) />
		</cfif>

		<cfreturn RSPUserList />

	</cffunction>
	<!--- 60308 :: Best Plans Enhancement START--->
	<cffunction name="getUserPositionsList" output="false" returntype="query">
		<cfargument name="userId" type="string" required="true" />

		<cfquery name="qgetUserPositionsList" datasource="#application.datasource#">
			SELECT	User_Position_Holders.User_Positions_ID, User_Positions.Position_Label
			FROM	User_Position_Holders
			INNER JOIN User_Positions
			ON User_Positions.User_Positions_ID	= User_Position_Holders.User_Positions_ID
			AND User_Positions.Deleted = 0
			WHERE  User_ID = '#arguments.userId#'
			AND	 User_Position_Holders.Deleted = 0
			AND	 User_Position_Holders.User_Positions_ID <> 0
		</cfquery>

			<cfreturn qgetUserPositionsList />
	</cffunction>
	<!--- 60308 :: Best Plans Enhancement END--->

	<cffunction name="getRSPbyPosition" output="false" access="remote">
		<cfargument name="position_id" type="string" required="true" />

		<cfscript>
			local.stStruct                 = {};
			local.RSPUserList              = queryNew("User_ID, User_Code, User_Full_Name, User_Email, Name_First, Name_Last, User_Position_Type, User_Positions_ID, Position_Label, Profiles_ID, User_Work_Phone, Work_Phone_Ext, Company_Name, Position_Level");
			local.showSalesPersonSelection = false;
			local.businessSegManager       = createObject("component", "components.programs.business_segment.BusinessSegmentManager");
			local.stStruct.userPosition    = arguments.position_id;

			if ( appsettings.getDisplayEligibleRSP() is 1 ) {
				local.stStruct.Eligible_RSP    = 1;
				local.stStruct.Is_On_Behalf_Of = 0;
			}
			local.stStruct.userPositionType = "P,S";
			local.stStruct.sortBy = "Position_Level,User_Positions.Position_Label,_Users.Name_First";

			return this.search( local.stStruct );
		</cfscript>
	</cffunction>

</cfcomponent>