<cfcomponent displayname="BillbackAssignmentManager" hint="Billback Assignment Manager" extends="components.Base">
	<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
	<cffunction name="init" returntype="components.billback.BillbackAssignmentManager" output="false">
		<cfreturn this />
	</cffunction>

	<cffunction name="isAnalyst" output="false" returntype="boolean">
		<cfargument name="userId" type="string" required="false" default="" />

		<cfset qGetAnalysts = getAnalysts(analystUserId = arguments.userId) />

		<cfif qGetAnalysts.recordCount GT 0>
			<cfreturn true />
		</cfif>

		<cfreturn false />

	</cffunction>

	<cffunction name="getAvailableUsers" output="false" returntype="query">

		<cfquery name="qGetAvailableUsers" datasource="#application.datasource#">
			SELECT	User_ID, Name_First, Name_Last
			FROM	_Users
			WHERE	Deleted = 0
			AND		User_ID NOT IN (SELECT	Analyst_User_ID FROM BB_Analyst WHERE Deleted = 0)
			ORDER BY Name_First
		</cfquery>

		<cfreturn qGetAvailableUsers />

	</cffunction>

	<cffunction name="getAvailableMarkets" output="false" returntype="query">

		<cfquery name="qGetAvailableMarkets" datasource="#application.datasource#">
			SELECT 		Distinct Service_Markets.Service_Market_ID, Market_Name, User_Positions.Position_Label, Market_Number  <!---32567--->
			FROM 		Service_Markets
			INNER JOIN 	User_Positions
						ON User_Positions.Service_Market_ID = Service_Markets.Service_Market_ID
						AND User_Positions.Deleted = 0
			WHERE 		Service_Markets.Deleted = 0
			<!---77204 :: A Distributor/Market/Operator can now be associated to multiple analysts--->
			<cfif val(appSettings.get_Setting('BB_Assignment_By_Template')) NEQ 1>
			AND 		Service_Markets.Service_Market_ID NOT IN
						(	SELECT 	Service_Market_ID
							FROM 	BB_Assignment
							WHERE 	Deleted = 0
							AND 	Service_Market_ID is not null
						)
				</cfif>
			ORDER BY	Market_Name DESC
		</cfquery>

		<cfreturn qGetAvailableMarkets />

	</cffunction>

	<cffunction name="getAnalystMarkets" output="false" returntype="query">
		<cfargument name="analystUserId" type="string" required="true" />

		<cfquery name="qGetAnalystMarkets" datasource="#application.datasource#">
			SELECT  	Distinct BB_Assignment.Service_Market_ID, Market_Name, User_Positions.Position_Label, Market_Number <!---32567--->
			FROM 		BB_Assignment
			INNER JOIN 	Service_Markets
			ON 			Service_Markets.Service_Market_ID = BB_Assignment.Service_Market_ID
			AND 		Service_Markets.Deleted = 0
			INNER JOIN 	User_Positions
						ON User_Positions.Service_Market_ID = Service_Markets.Service_Market_ID
						AND User_Positions.Deleted = 0
			WHERE 		Analyst_User_ID = <cfqueryparam value="#arguments.analystUserId#" cfsqltype="CF_SQL_VARCHAR">
			AND 		BB_Assignment.Deleted = 0
			ORDER BY 	Market_Name
		</cfquery>

		<cfreturn qGetAnalystMarkets />

	</cffunction>

	<cffunction name="getAvailableDistributors" output="false" returntype="query">

		<cfquery name="qGetAvailableDistributors" datasource="#application.datasource#">
			SELECT 		BSA_Foodservice_Customers_ID Distributor_ID, Name, Shr_Ship_To, City, State, ZipCode,Ship_To     <!---32567--->
			FROM 		BSA_Foodservice_Customers
			WHERE 		Deleted = 0
			AND 		Active_Code = 'A'
			<!---77204 :: A Distributor/Market/Operator can now be associated to multiple analysts--->
			<cfif val(appSettings.get_Setting('BB_Assignment_By_Template')) NEQ 1>
			AND			BSA_Foodservice_Customers_ID NOT IN
						(	SELECT 	Distributor_ID
							FROM 	BB_Assignment
							WHERE 	Deleted = 0
							AND 	Distributor_ID IS NOT NULL
						)
			</cfif>
			ORDER BY Name
		</cfquery>

		<cfreturn qGetAvailableDistributors />

	</cffunction>


	<cffunction name="getAnalystDistributors" output="false" returntype="query">
		<cfargument name="analystUserId" type="string" required="true" />

		<cfquery name="qGetAnalystDistributors" datasource="#application.datasource#">
			SELECT  	DISTINCT BB_Assignment.Distributor_ID, BSA_Foodservice_Customers.Name, BSA_Foodservice_Customers.Shr_Ship_To, BSA_Foodservice_Customers.City, BSA_Foodservice_Customers.State, BSA_Foodservice_Customers.ZipCode  <!---32567--->
			FROM 		BB_Assignment
			INNER JOIN 	BSA_Foodservice_Customers
			ON 			BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = BB_Assignment.Distributor_ID
			AND 		BSA_Foodservice_Customers.Deleted = 0
			WHERE 		BB_Assignment.Analyst_User_ID = <cfqueryparam value="#arguments.analystUserId#" cfsqltype="CF_SQL_VARCHAR">
			AND 		BB_Assignment.Deleted = 0
			ORDER BY 	Name
		</cfquery>

		<cfreturn qGetAnalystDistributors />

	</cffunction>
	<cffunction name="getAvailableOperators" output="false" returntype="query">
		<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
		<cfquery name="qGetAvailableOperators" datasource="#application.datasource#">
			Select	distinct BSA_Operator_ID Operator_ID,*
			From	BSA_Operator
			Where	Deleted = 0
			AND	Display_Code = 'A'
			<!---77204 :: A Distributor/Market/Operator can now be associated to multiple analysts--->
			<cfif val(appSettings.get_Setting('BB_Assignment_By_Template')) NEQ 1>
			AND	BSA_Operator_ID NOT IN
				(	SELECT 	Operator_ID
					FROM 	BB_Assignment
					WHERE 	Deleted = 0
					AND 	Operator_ID IS NOT NULL
				)
				</cfif>
			ORDER BY Operator_Name  ASC
		</cfquery>

		<cfreturn qGetAvailableOperators />

	</cffunction>


	<cffunction name="getAnalystOperators" output="false" returntype="query">
		<cfargument name="analystUserId" type="string" required="true" />

		<cfquery name="qGetAnalystOperators" datasource="#application.datasource#">
			SELECT  	BB_Assignment.Operator_ID, BSA_Operator.Operator_Name, BSA_Operator.Operator_Type, BSA_Operator.Operator_City, BSA_Operator.Operator_State, BSA_Operator.Operator_Zip
			FROM 		BB_Assignment
			INNER JOIN 	BSA_Operator
			ON 		BSA_Operator.BSA_Operator_ID = BB_Assignment.Operator_ID
			AND 		BSA_Operator.Deleted = 0
			WHERE 		BB_Assignment.Analyst_User_ID = <cfqueryparam value="#arguments.analystUserId#" cfsqltype="CF_SQL_VARCHAR">
			AND 		BB_Assignment.Deleted = 0
			ORDER BY 	BSA_Operator.Operator_Name
		</cfquery>

		<cfreturn qGetAnalystOperators />

	</cffunction>

	<cffunction name="getAvailableAnalysts" output="false" returntype="query">

		<cfquery name="qGetAvailableAnalysts" datasource="#application.datasource#">
			SELECT 		Analyst_User_ID,
						Name_First,
						Name_Last
			FROM 		BB_Analyst
			INNER JOIN 	_Users
			ON 			_Users.User_ID = BB_Analyst.Analyst_User_ID
			WHERE 		BB_Analyst.Deleted = 0
			AND 		_Users.Deleted = 0
			AND 		Is_Supervisor = 0
			AND			Supervisor_ID IS NULL
			Order By Name_First
		</cfquery>

		<cfreturn qGetAvailableAnalysts />

	</cffunction>

	<cffunction name="getAvailableSupervidors" output="false" returntype="query">

		<cfquery name="local.getAvailableSupervidors" datasource="#application.datasource#">
			SELECT   Analyst_User_ID
					,Name_First
					,Name_Last
			FROM     BB_Analyst
					INNER JOIN _Users
						ON _Users.User_ID = BB_Analyst.Analyst_User_ID
			WHERE    BB_Analyst.Deleted = 0
					AND _Users.Deleted = 0
					AND Is_Director = 0
					AND Director_ID IS NULL
					AND Is_Supervisor = 1
					AND Supervisor_ID IS NOT NULL
			ORDER BY Name_First
		</cfquery>

		<cfreturn local.getAvailableSupervidors>

	</cffunction>

	<cffunction name="getSupervisorAnalysts" output="false" returntype="query">
		<cfargument name="supervisorUserId" type="string" required="true" />

		<cfquery name="qGetSupervisorAnalysts" datasource="#application.datasource#">
			SELECT 		Analyst_User_ID,
						Name_First,
						Name_Last
			FROM 		BB_Analyst
			INNER JOIN 	_Users
			ON 			_Users.User_ID = BB_Analyst.Analyst_User_ID
			WHERE 		BB_Analyst.Deleted = 0
			AND 		_Users.Deleted = 0
			AND 		Is_Supervisor = 0
			AND			Supervisor_ID = <cfqueryparam value="#arguments.supervisorUserId#" cfsqltype="CF_SQL_VARCHAR">
			Order By Name_First
		</cfquery>

		<cfreturn qGetSupervisorAnalysts />

	</cffunction>

	<cffunction name="getDirectorSupervisors" output="false" returntype="query">
		<cfargument name="directorUserId" type="string" required="true" />

		<cfquery name="qGetDirectorSupervisors" datasource="#application.datasource#">
			SELECT 		Analyst_User_ID,
					Name_First,
					Name_Last
			FROM 		BB_Analyst
			INNER JOIN 	_Users
			ON 		_Users.User_ID = BB_Analyst.Analyst_User_ID
			WHERE 		BB_Analyst.Deleted = 0
			AND 		_Users.Deleted = 0
			AND 		Is_Director = 0
			AND		Director_ID = <cfqueryparam value="#arguments.directorUserId#" cfsqltype="CF_SQL_VARCHAR">
			Order By 	Name_First
		</cfquery>

		<cfreturn qGetDirectorSupervisors />

	</cffunction>

	<cffunction name="getAnalysts" output="false" returntype="query">
		<cfargument name="bNonSupervisor" type="boolean" required="false" default="0" />
		<cfargument name="bDefaultAnalyst" type="boolean" required="false" default="0" />
		<cfargument name="analystUserId" type="string" required="false" default="" />
		<cfargument name="sortBy" type="string" required="false" default="Name_First" />
		<cfargument name="sourceCaller" type="string" required="false" default="CF" />

		<cfif isDefined("arguments.sourceCaller") AND arguments.sourceCaller EQ "FLEXBB">
			<cfset profile = CreateObject("component","components.user.Profile").init() />
			<cfset Get_Profile_Settings = profile.getProfileSettings(request.AccessStructure.Profiles_ID)>
			<cfset lGPSuppliedPosition = CreateObject("component", "components.user.UserManager").getPositionId(request.AccessStructure.user_id, 0, 1) />
			<cfset qHQPosition = CreateObject("component", "components.geography.position").getHQPosition() />

			<cfset bHQUser = 0>
			<cfif listcontains(lGPSuppliedPosition, qHQPosition.User_Positions_ID)>
				<cfset bHQUser = 1>
			</cfif>
			<cfif isDefined("arguments.analystUserId") AND arguments.analystUserId NEQ "">
				<cfset assigned_analystUserId = arguments.analystUserId  />
			<cfelse>
				<cfset assigned_analystUserId = request.AccessStructure.user_id />
			</cfif>
			<cfquery name="qUserIsAnalyst" datasource="#application.datasource#">
			SELECT 		Analyst_User_ID,
						Default_Analyst,
						Name_First,
						Name_Last,
						Is_Supervisor,
						Is_Default_Supervisor,
						Is_Director,
						Is_Default_Director,
						_Users.User_Email,
						_Users.Sales_Person_ID As User_ID_Int
			FROM 		BB_Analyst
			INNER JOIN 	_Users
			ON 			_Users.User_ID = BB_Analyst.Analyst_User_ID
			WHERE 		BB_Analyst.Deleted = 0
			-- AND 		_Users.Deleted = 0
			<cfif arguments.bNonSupervisor EQ 1>
			AND			Is_Supervisor = 0
			</cfif>
			<cfif arguments.bDefaultAnalyst EQ 1>
			AND			Default_Analyst = 1
			</cfif>
			AND			Analyst_User_ID = <cfqueryparam value="#assigned_analystUserId#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<cfset bUserIsAnalyst = qUserIsAnalyst.RecordCount />
		</cfif>

		<cfquery name="qGetAnalysts" datasource="#application.datasource#">
			SELECT 		Analyst_User_ID,
						Default_Analyst,
						Name_First,
						Name_Last,
						Is_Supervisor,
						Is_Default_Supervisor,
						Is_Director,
						Is_Default_Director,
						_Users.User_Email,
						_Users.Sales_Person_ID As User_ID_Int
			FROM 		BB_Analyst
			INNER JOIN 	_Users
			ON 			_Users.User_ID = BB_Analyst.Analyst_User_ID
			WHERE 		BB_Analyst.Deleted = 0
			AND 		_Users.Deleted = 0
			<cfif arguments.bNonSupervisor EQ 1>
			AND			Is_Supervisor = 0
			</cfif>
			<cfif arguments.bDefaultAnalyst EQ 1>
			AND			Default_Analyst = 1
			</cfif>
			<cfif isDefined("arguments.sourceCaller") AND arguments.sourceCaller EQ "FLEXBB">
				<cfif Get_Profile_Settings.BB_Search_By_Analyst OR (bHQUser and not bUserIsAnalyst)>
					AND 0=0
				<cfelse>
					AND 0=1
				</cfif>
			<cfelse>
				<cfif arguments.analystUserId NEQ "">
					AND			Analyst_User_ID = <cfqueryparam value="#arguments.analystUserId#" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
			</cfif>

			ORDER By #arguments.sortBy#
		</cfquery>

		<cfreturn qGetAnalysts />

	</cffunction>

	<cffunction name="getSupervisors" output="false" returntype="query">
		<cfargument name="bNonDirector" type="boolean" required="false" default="0" />
		<cfargument name="bDefaultSupervisor" type="boolean" required="false" default="0" />
		<cfargument name="analystUserId" type="string" required="false" default="" />
		<cfargument name="sortBy" type="string" required="false" default="Name_First" />

		<cfquery name="qGetSupervisors" datasource="#application.datasource#">
			SELECT 		Analyst_User_ID,
					Is_Default_Supervisor,
					Name_First,
					Name_Last
			FROM 		BB_Analyst
			INNER JOIN 	_Users
			ON 		_Users.User_ID = BB_Analyst.Analyst_User_ID
			WHERE 		BB_Analyst.Deleted = 0
			AND 		_Users.Deleted = 0
			AND 		Is_Supervisor = 1
			<cfif arguments.bNonDirector EQ 1>
			AND		Is_Director = 0
			</cfif>
			<cfif arguments.bDefaultSupervisor EQ 1>
			AND		Is_Default_Supervisor = 1
			</cfif>
			<cfif arguments.analystUserId NEQ "">
			AND		Analyst_User_ID = <cfqueryparam value="#arguments.analystUserId#" cfsqltype="CF_SQL_VARCHAR">
			</cfif>
			ORDER By 	Name_First
		</cfquery>

		<cfreturn qGetSupervisors />

	</cffunction>

	<cffunction name="getDirectors" output="false" returntype="query">
		<cfargument name="analystUserId" type="string" required="false" default="" />

		<cfquery name="qGetDirectors" datasource="#application.datasource#">
			SELECT 		Analyst_User_ID,
					Is_Default_Director,
					Name_First,
					Name_Last
			FROM 		BB_Analyst
			INNER JOIN 	_Users
			ON 		_Users.User_ID = BB_Analyst.Analyst_User_ID
			WHERE 		BB_Analyst.Deleted = 0
			AND 		_Users.Deleted = 0
			AND 		Is_Director = 1
			<cfif arguments.analystUserId NEQ "">
				AND		BB_Analyst.Analyst_User_ID = '#arguments.analystUserId#'
			</cfif>
			ORDER By 	Name_First
		</cfquery>

		<cfreturn qGetDirectors />

	</cffunction>

	<cffunction name="saveAnalysts" output="false" returntype="void">

		<cfargument name="analystUserIDList" type="string" required="true" />
		<cfargument name="defaultAnalystUserID" type="string" required="true" />
		<cfargument name="byUserId" type="string" required="true" />

		<!------ Get the current analyst list ----->
		<cfset qGetAnalysts = getAnalysts() />

		<!------ Add the analysts which are new ----->
		<cfloop list="#arguments.analystUserIDList#" index="thisAnalyst">
			<!------ 1. check if this analyst already exist in the database ----->
			<cfquery name="qCheckAnalyst" dbtype="query">
				SELECT	*
				FROM	qGetAnalysts
				WHERE	Analyst_User_ID = <cfqueryparam value="#thisAnalyst#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>

			<cfif qCheckAnalyst.recordCount EQ 0>
				<!------ 2. Insert into database ----->
				<cfquery name="qInsertAnalyst" datasource="#application.datasource#">
					INSERT INTO BB_Analyst (Analyst_User_ID)
					VALUES (
					<cfqueryparam value="#thisAnalyst#" cfsqltype="CF_SQL_VARCHAR">
					)
				</cfquery>
			</cfif>

		</cfloop>

		<!------ set default Analyst ----->
		<cfquery name="qDeleteExistingDefaultAnalyst" datasource="#application.datasource#">
			UPDATE	BB_Analyst
			SET		Default_Analyst = 0
			WHERE	Default_Analyst = 1
			AND		Analyst_User_ID <> <cfqueryparam value="#arguments.defaultAnalystUserID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<cfquery name="qUpdateNewDefaultAnalyst" datasource="#application.datasource#">
			UPDATE	BB_Analyst
			SET		Default_Analyst = 1
			WHERE	Default_Analyst = 0
			AND		Analyst_User_ID = <cfqueryparam value="#arguments.defaultAnalystUserID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

		<!------ Remove the analysts which are not in the current list ----->
		<!------ 1. Get the list of analysts to be removed ----->
		<cfquery name="qRemoveAnalysts" dbtype="query">
			SELECT	Analyst_User_ID
			FROM	qGetAnalysts
			<cfif arguments.analystUserIDList NEQ "">
			WHERE	Analyst_User_ID NOT IN (<cfqueryparam value="#arguments.analystUserIDList#" cfsqltype="CF_SQL_VARCHAR" list="true">)
			</cfif>
		</cfquery>

		<cfloop query="qRemoveAnalysts">
			<!------ 2. Reassign the billbacks for this analyst to default analyst ----->
			<cfif arguments.defaultAnalystUserID NEQ "">

				<cfset reassignAllBillbacks(Analyst_User_ID, arguments.defaultAnalystUserID, arguments.byUserId) />

			</cfif>

			<!------ 3. Remove Analyst ----->
			<cfquery name="qDeleteAssignment" datasource="#application.datasource#">
				UPDATE	BB_Assignment
				SET		Deleted = 1
				WHERE	Deleted = 0
				AND		Analyst_User_ID = <cfqueryparam value="#Analyst_User_ID#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<cfquery name="qDeleteAnalyst" datasource="#application.datasource#">
				UPDATE	BB_Analyst
				SET		Deleted = 1
				WHERE	Deleted = 0
				AND		Analyst_User_ID = <cfqueryparam value="#Analyst_User_ID#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>

		</cfloop>

	</cffunction>


	<cffunction name="saveSupervisors" output="false" returntype="void">

		<cfargument name="supervisorUserIDList" type="string" required="true" />
		<cfargument name="byUserId" type="string" required="true" />

		<!------ Get the current supervisor list ----->
		<cfset qGetSupervisors = getSupervisors() />

		<!------ Add the supervisors which are new ----->
		<cfif arguments.supervisorUserIDList NEQ "">
			<cfquery name="qAddSupervisor" datasource="#application.datasource#">
				UPDATE	BB_Analyst
				SET		Is_Supervisor = 1,
						Supervisor_ID = NULL,
						Director_ID = NULL
				WHERE	Deleted = 0
				AND		Analyst_User_ID IN (<cfqueryparam value="#arguments.supervisorUserIDList#" cfsqltype="CF_SQL_VARCHAR" list="true">)
				AND		(Is_Supervisor = 0 OR Supervisor_ID IS NOT NULL)
			</cfquery>

			<!--- 27844 removed default supervisor
			<!------ remove old default analyst ----->
			<cfquery name="qReSetDefaultSupervisor" datasource="#application.datasource#">
				UPDATE	BB_Analyst
				SET		Is_Default_Supervisor = 0
				WHERE	Deleted = 0
				AND		Analyst_User_ID <> <cfqueryparam value="#arguments.defaultSupervisorUserID#" cfsqltype="CF_SQL_VARCHAR">
				AND		Is_Default_Supervisor = 1
			</cfquery>

			<!------ add new default analyst ----->
			<cfquery name="qSetDefaultSupervisor" datasource="#application.datasource#">
				UPDATE	BB_Analyst
				SET		Is_Default_Supervisor = 1
				WHERE	Deleted = 0
				AND		Analyst_User_ID = <cfqueryparam value="#arguments.defaultSupervisorUserID#" cfsqltype="CF_SQL_VARCHAR">
				AND		Is_Default_Supervisor = 0
			</cfquery>
			--->

			<!------ Change the supervisor for analysts whose supervisor is getting deleted to the default supervisor ----->
			<cfquery name="qChangeToDefaultSupervisor" datasource="#application.datasource#">
				UPDATE	BB_Analyst
				SET	Supervisor_ID = NULL
				WHERE	Deleted = 0
				AND	Supervisor_ID NOT IN (<cfqueryparam value="#arguments.supervisorUserIDList#" cfsqltype="CF_SQL_VARCHAR" list="true">)
				AND	Is_Supervisor = 0
			</cfquery>


			<!------ Remove the supervisors which are to be removed also remove the deleted supervisors from director list----->
			<cfquery name="qRemoveSupervisor" datasource="#application.datasource#">
				UPDATE	BB_Analyst
				SET		Is_Supervisor = 0, Is_Director = 0, Director_ID = NULL, is_Default_Director=0
				WHERE	Deleted = 0
				AND		Analyst_User_ID NOT IN (<cfqueryparam value="#arguments.supervisorUserIDList#" cfsqltype="CF_SQL_VARCHAR" list="true">)
				AND		Is_Supervisor = 1
			</cfquery>


			<!------ Change the director for supervisors whose director is getting deleted to the default director ----->
			<cfset useLakebaseForqGetDefaultDirector = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_analyst")>
<cfif useLakebaseForqGetDefaultDirector>
	<cftry>
		<cfset qGetDefaultDirector = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bb_analyst", {
				"is_default_director" = "eq.1",
				"deleted" = "eq.0",
				"select" = "analyst_user_id"
			}), "analyst_user_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDefaultDirector = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDefaultDirector>
<cfquery name="qGetDefaultDirector" datasource="#application.datasource#">
				SELECT	Analyst_User_ID
				FROM	BB_Analyst
				WHERE	Is_Default_Director = 1
				AND	Deleted = 0
			</cfquery>
</cfif>

			<cfquery name="qChangeToDefaultDirector" datasource="#application.datasource#">
				UPDATE	BB_Analyst
				<cfif qGetDefaultDirector.recordcount EQ 1>
				SET	Director_ID = '#qGetDefaultDirector.Analyst_User_ID#'
				<cfelse>
				SET	Director_ID = NULL
				</cfif>
				WHERE	Deleted = 0
				AND	Director_ID NOT IN (<cfqueryparam value="#arguments.supervisorUserIDList#" cfsqltype="CF_SQL_VARCHAR" list="true">)
				AND	Is_Director = 0
			</cfquery>
		</cfif>


	</cffunction>

	<cffunction name="reassignAllBillbacks" output="false" returntype="void">

		<cfargument name="fromUserId" type="string" required="true" />
		<cfargument name="toUserId" type="string" required="true" />
		<cfargument name="byUserId" type="string" required="true" />

		<!------ insert into log table ----->
		<cfquery name="qGetBillbackReassignLog" datasource="#application.datasource#">
			INSERT INTO BB_Reassign (Billback_ID, From_User_ID, To_User_ID, By_User_ID)
			SELECT	Billback_ID, '#arguments.fromUserId#', '#arguments.toUserId#', '#arguments.byUserId#'
			FROM	Billback
			WHERE	Billback.Analyst_User_ID = <cfqueryparam value="#arguments.fromUserId#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

		<!------ reassign billback ----->
		<cfquery name="qGetBillbackReassignLog" datasource="#application.datasource#">
			UPDATE	Billback
			SET		Billback.Analyst_User_ID = <cfqueryparam value="#arguments.toUserId#" cfsqltype="CF_SQL_VARCHAR">
			WHERE	Billback.Analyst_User_ID = <cfqueryparam value="#arguments.fromUserId#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

	</cffunction>


	<cffunction name="saveAnalystMarkets" output="false" returntype="void">
		<cfargument name="analystUserId" type="string" required="true" />
		<cfargument name="marketIdList" type="string" required="true" />
		<cfargument name="byUserId" type="string" required="true" />

		<!------ remove existing market assignments ----->
		<cfquery name="qRemoveMarketAssignment" datasource="#application.datasource#">
			UPDATE 		BB_Assignment
			SET			Deleted = 1
			WHERE		Service_Market_ID IS NOT NULL
			AND 		Deleted = 0
			AND			Analyst_User_ID = <cfqueryparam value="#arguments.analystUserId#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

		<cfquery name="qRemoveMarketAssigmentFlag" datasource="#application.datasource#">
			UPDATE 	BB_Analyst
			SET		Market_Assigned = 0
			WHERE	Deleted = 0
			AND		Market_Assigned = 1
			AND			Analyst_User_ID = <cfqueryparam value="#arguments.analystUserId#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

		<cfif arguments.marketIdList NEQ "">
			<cfquery name="qAddMarketAssigmentFlag" datasource="#application.datasource#">
				UPDATE 	BB_Analyst
				SET		Market_Assigned = 1
				WHERE	Deleted = 0
				AND		Market_Assigned = 0
				AND		Analyst_User_ID = <cfqueryparam value="#arguments.analystUserId#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<cfloop list="#arguments.marketIdList#" index="marketId">
				<cfquery name="qInsertAnalystMarket" datasource="#application.datasource#">
					INSERT INTO BB_Assignment	(Analyst_User_ID, Service_Market_ID)
					VALUES	(
							<cfqueryparam value="#arguments.analystUserId#" cfsqltype="CF_SQL_VARCHAR">,
							<cfqueryparam value="#marketId#" cfsqltype="CF_SQL_INTEGER">
							)
				</cfquery>
			</cfloop>
		</cfif>

	</cffunction>

	<cffunction name="saveAnalystDistributors" output="false" returntype="void">
		<cfargument name="analystUserId" type="string" required="true" />
		<cfargument name="distributorIdList" type="string" required="true" />
		<cfargument name="byUserId" type="string" required="true" />

		<!------ remove existing distributor assignments ----->
		<cfquery name="qRemoveDistributorAssignment" datasource="#application.datasource#">
			UPDATE 		BB_Assignment
			SET			Deleted = 1
			WHERE		Distributor_ID IS NOT NULL
			AND 		Deleted = 0
			AND			Analyst_User_ID = <cfqueryparam value="#arguments.analystUserId#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

		<cfquery name="qRemoveDistributorAssigmentFlag" datasource="#application.datasource#">
			UPDATE 	BB_Analyst
			SET		Distributor_Assigned = 0
			WHERE	Deleted = 0
			AND		Distributor_Assigned = 1
			AND		Analyst_User_ID = <cfqueryparam value="#arguments.analystUserId#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

		<cfif arguments.distributorIdList NEQ "">
			<cfquery name="qAddDistributorAssigmentFlag" datasource="#application.datasource#">
				UPDATE 	BB_Analyst
				SET		Distributor_Assigned = 1
				WHERE	Deleted = 0
				AND		Distributor_Assigned = 0
				AND		Analyst_User_ID = <cfqueryparam value="#arguments.analystUserId#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<cfloop list="#arguments.distributorIdList#" index="distributorId">
				<cfquery name="qInsertAnalystDistributor" datasource="#application.datasource#">
					INSERT INTO BB_Assignment	(Analyst_User_ID, Distributor_ID)
					VALUES	(
							<cfqueryparam value="#arguments.analystUserId#" cfsqltype="CF_SQL_VARCHAR">,
							<cfqueryparam value="#distributorId#" cfsqltype="CF_SQL_VARCHAR">
							)
				</cfquery>
			</cfloop>
		</cfif>

	</cffunction>

	<cffunction name="saveAnalystOperators" output="false" returntype="void">
		<cfargument name="analystUserId" type="string" required="true" />
		<cfargument name="operatorIdList" type="string" required="true" />
		<cfargument name="byUserId" type="string" required="true" />

		<!------ remove existing operator assignments ----->
		<cfquery name="qRemoveOperatorAssignment" datasource="#application.datasource#">
			UPDATE 		BB_Assignment
			SET			Deleted = 1
			WHERE		Operator_ID IS NOT NULL
			AND 		Deleted = 0
			AND			Analyst_User_ID = <cfqueryparam value="#arguments.analystUserId#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

		<cfquery name="qRemoveOperatorAssigmentFlag" datasource="#application.datasource#">
			UPDATE 	BB_Analyst
			SET		Operator_Assigned = 0
			WHERE	Deleted = 0
			AND		Operator_Assigned = 1
			AND		Analyst_User_ID = <cfqueryparam value="#arguments.analystUserId#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

		<cfif arguments.operatorIdList NEQ "">
			<cfquery name="qAddOperatorAssigmentFlag" datasource="#application.datasource#">
				UPDATE 	BB_Analyst
				SET		Operator_Assigned = 1
				WHERE	Deleted = 0
				AND		Operator_Assigned = 0
				AND		Analyst_User_ID = <cfqueryparam value="#arguments.analystUserId#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<cfloop list="#arguments.operatorIdList#" index="operatorId">
				<cfquery name="qInsertAnalystOperator" datasource="#application.datasource#">
					INSERT INTO BB_Assignment	(Analyst_User_ID, Operator_ID)
					VALUES	(
							<cfqueryparam value="#arguments.analystUserId#" cfsqltype="CF_SQL_VARCHAR">,
							<cfqueryparam value="#operatorId#" cfsqltype="CF_SQL_VARCHAR">
							)
				</cfquery>
			</cfloop>
		</cfif>

	</cffunction>
	<cffunction name="saveSupervisorAnalysts" output="false" returntype="void">
		<cfargument name="supervisorUserId" type="string" required="true" />
		<cfargument name="analystIdList" type="string" required="true" />
		<cfargument name="byUserId" type="string" required="true" />

		<!------ remove analyst assignments ----->
		<cfquery name="qRemoveAnalystAssignment" datasource="#application.datasource#">
			UPDATE 		BB_Analyst
			SET			Supervisor_ID = NULL
			WHERE		Supervisor_ID IS NOT NULL
			AND 		Deleted = 0
			AND 		Is_Supervisor = 0
			AND			Supervisor_ID = <cfqueryparam value="#arguments.supervisorUserId#" cfsqltype="CF_SQL_VARCHAR">
			<cfif arguments.analystIdList NEQ "">
			AND			Analyst_User_ID NOT IN (<cfqueryparam value="#arguments.analystIdList#" cfsqltype="CF_SQL_VARCHAR" list="true">)
			</cfif>
		</cfquery>

		<!------ add analyst assignments ----->
		<cfquery name="qRemoveAnalystAssignment" datasource="#application.datasource#">
			UPDATE 		BB_Analyst
			SET			Supervisor_ID = <cfqueryparam value="#arguments.supervisorUserId#" cfsqltype="CF_SQL_VARCHAR">
			WHERE		Deleted = 0
			AND 		Is_Supervisor = 0
			<cfif arguments.analystIdList NEQ "">
			AND			Analyst_User_ID IN (<cfqueryparam value="#arguments.analystIdList#" cfsqltype="CF_SQL_VARCHAR" list="true">)
			<cfelse>
			AND			1 = 2
			</cfif>
		</cfquery>

	</cffunction>

	<cffunction name="saveDirectorSupervisor" output="false" returntype="void">
		<cfargument name="directorUserId" type="string" required="true" />
		<cfargument name="supervisorIdList" type="string" required="true" />
		<cfargument name="byUserId" type="string" required="true" />

		<!------ remove analyst assignments ----->
		<cfquery name="qRemoveSupervisorAssignment" datasource="#application.datasource#">
			UPDATE 		BB_Analyst
			SET		Director_ID = NULL
			WHERE		Director_ID IS NOT NULL
			AND 		Deleted = 0
			AND 		Is_Director = 0
			AND		Director_ID = <cfqueryparam value="#arguments.directorUserId#" cfsqltype="CF_SQL_VARCHAR">
			<cfif arguments.supervisorIdList NEQ "">
			AND		Analyst_User_ID NOT IN (<cfqueryparam value="#arguments.supervisorIdList#" cfsqltype="CF_SQL_VARCHAR" list="true">)
			</cfif>
		</cfquery>

		<!------ add analyst assignments ----->
		<cfquery name="qAddSupervisorAssignment" datasource="#application.datasource#">
			UPDATE 		BB_Analyst
			SET		Director_ID = <cfqueryparam value="#arguments.directorUserId#" cfsqltype="CF_SQL_VARCHAR">
			WHERE		Deleted = 0
			AND 		Is_Director = 0
			<cfif arguments.supervisorIdList NEQ "">
			AND			Analyst_User_ID IN (<cfqueryparam value="#arguments.supervisorIdList#" cfsqltype="CF_SQL_VARCHAR" list="true">)
			<cfelse>
			AND			1 = 2
			</cfif>
		</cfquery>

	</cffunction>

	<cffunction name="getBillbackAnalystId" output="false" returntype="string">
		<cfargument name="billbackId" type="string" required="true" />

		<cfquery name="qGetBillbackAnalyst" datasource="#application.datasource#">
			SELECT	Analyst_User_ID
			FROM	Billback
			WHERE	Billback_ID = <cfqueryparam value="#arguments.billbackId#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

		<cfreturn qGetBillbackAnalyst.Analyst_User_ID />

	</cffunction>

	<cffunction name="getBillbackAnalystName" output="false" returntype="string">
		<cfargument name="billbackId" type="string" required="true" />

		<cfset analystUserID = getBillbackAnalystId(arguments.billbackId) />

		<cfif analystUserID NEQ "">

			<cfset qUser = CreateObject("component", "components.user.UserManager").getUser(analystUserID) />

			<cfreturn qUser.User_Full_Name />

		</cfif>

		<cfreturn "" />

	</cffunction>

	<cffunction name="saveBillbackAnalyst" output="false" returntype="void">
		<cfargument name="billbackId" type="string" required="true" />
		<cfargument name="distributorId" type="string" required="false" default="" />
		<cfargument name="operatorId" type="string" required="false" default="" />
		<cfargument name="creatorId" type="string" required="false" default="" />          <!--- 43146 --->

		<cfset analystUserId = "" />

		<cfif arguments.distributorId neq ""><!------ get the analyst id for this distributor ----->
			<cfset analystUserId = getAnalystForDistributor(arguments.distributorId) />
		</cfif>
		<!--- BJF 11869 Add logic for operators --->
		<cfif arguments.operatorId NEQ "">
				<cfset analystUserId = getAnalystForOperator(arguments.operatorID)>
			</cfif>

		<!--- 43146 assign billback creator as default analyst if possible otherwise use default analyst --->
		<cfif arguments.creatorId NEQ "">
			<cfset local.qAnalysts = getAnalysts( analystUserId = arguments.creatorId)>
			<cfif local.qAnalysts.recordCount gt 0>
				<cfset analystUserId = local.qAnalysts.Analyst_User_ID>
			</cfif>
		</cfif>

		<!--- end operator assignment --->
		<cfif analystUserId eq ""><!------ if no analyst found get the default analyst ----->
			<cfset qDefaultAnalyst = getAnalysts(bDefaultAnalyst = 1) />
			<cfif qDefaultAnalyst.recordCount GT 0>
				<cfset analystUserId = qDefaultAnalyst.Analyst_User_ID />
			</cfif>
		</cfif>

		<cfset updateBillbackAnalyst(billbackId = arguments.billbackId, analystUserId = analystUserId) />

	</cffunction>

	<cffunction name="updateBillbackAnalyst" output="false" returntype="void">
		<cfargument name="billbackId" type="string" required="true" />
		<cfargument name="analystUserId" type="string" required="true" />

		<cfquery name="qSaveBillbackAnalyst" datasource="#application.datasource#">
			UPDATE	Billback
			SET		Analyst_User_ID = <cfqueryparam value="#arguments.analystUserId#" cfsqltype="CF_SQL_VARCHAR" null="#analystUserId EQ ""#">
			WHERE	Billback_ID = <cfqueryparam value="#arguments.billbackId#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

	</cffunction>

	<cffunction name="getAnalystForDistributor" output="false" returntype="string">
		<cfargument name="distributorId" type="string" required="true" />

		<!------ Find if this distributor alreay have an analyst assignment ----->
		<cfquery name="qGetDistributorAnalyst" datasource="#application.datasource#">
			SELECT  	Analyst_User_ID
			FROM 		BB_Assignment
			INNER JOIN 	BSA_Foodservice_Customers
			ON  		BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = BB_Assignment.Distributor_ID
			WHERE 		BB_Assignment.Deleted = 0
			AND			BSA_Foodservice_Customers.Deleted = 0
			AND			(
							cast(BSA_Foodservice_Customers_ID as varchar(36)) = <cfqueryparam value="#arguments.distributorId#" cfsqltype="cf_sql_varchar" >
							OR
							Shr_Ship_To = <cfqueryparam value="#arguments.distributorId#" cfsqltype="cf_sql_varchar">
						)
		</cfquery>

		<cfif qGetDistributorAnalyst.RecordCount GT 0>
			<cfreturn qGetDistributorAnalyst.Analyst_User_ID />
		</cfif>

		<!------ Find the market for this distributor ----->
		<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getDistributorMultiPosition()>
			<cfquery name="qGetDistributorMarket" datasource="#application.datasource#">
				SELECT		Market_Distributor.Service_Market_ID
				FROM		Market_Distributor
				INNER JOIN 	BSA_Foodservice_Customers
				ON  		BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Market_Distributor.Distributor_ID
				WHERE		BSA_Foodservice_Customers.Deleted = 0
				AND			(
								cast(BSA_Foodservice_Customers_ID as varchar(36)) = <cfqueryparam value="#arguments.distributorId#" cfsqltype="cf_sql_varchar" >
								OR
								Shr_Ship_To = <cfqueryparam value="#arguments.distributorId#" cfsqltype="cf_sql_varchar">
							)
				and 		Market_Distributor.Service_Market_ID is not null
			</cfquery>
		<cfelse>
			<cfquery name="qGetDistributorMarket" datasource="#application.datasource#">
				SELECT	BSA_Foodservice_Brokers.Service_Market_ID
				FROM	BSA_Foodservice_Customers

				INNER JOIN BSA_Foodservice_Brokers
				ON		BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID

				WHERE	BSA_Foodservice_Brokers.Service_Market_ID is not null
				and 	(
							cast(BSA_Foodservice_Customers_ID as varchar(36)) = <cfqueryparam value="#arguments.distributorId#" cfsqltype="cf_sql_varchar" >
							OR
							Shr_Ship_To = <cfqueryparam value="#arguments.distributorId#" cfsqltype="cf_sql_varchar">
						)
			</cfquery>
		</cfif>

		<cfif qGetDistributorMarket.recordCount>
			<cfset marketList = ValueList(qGetDistributorMarket.Service_Market_ID) />
			<!------ Go get the analyst for the market(s) involved ----->
			<cfquery name="qGetMarketAnalysts" datasource="#application.datasource#">
				SELECT	Analyst_User_ID
				FROM	BB_Assignment
				WHERE	Deleted = 0
				AND		Service_Market_ID IN (<cfqueryparam value="#marketList#" cfsqltype="CF_SQL_INTEGER" list="true">)
			</cfquery>

			<cfif qGetMarketAnalysts.recordCount GT 0>
				<cfreturn qGetMarketAnalysts.Analyst_User_ID />
			</cfif>
		</cfif>

		<!------ Still no analyst, return the default analyst ----->
		<cfset qGetDefaultAnalyst = getAnalysts(bDefaultAnalyst = 1) />
		<cfif qGetDefaultAnalyst.recordCount GT 0>

			<cfreturn qGetDefaultAnalyst.Analyst_User_ID />

		<cfelse>

			<cfreturn "" />

		</cfif>

	</cffunction>

	<cffunction name="getAnalystForOperator" output="false" returntype="string">
		<cfargument name="operatorId" type="string" required="true" />

			<cfquery name="qgetAnalystForOperator" datasource="#application.datasource#">
			SELECT BB_Assignment.Analyst_User_ID
				FROM BB_Assignment
				INNER JOIN BSA_Operator
				ON BSA_Operator.BSA_Operator_ID = BB_Assignment.Operator_ID
			WHERE BB_Assignment.Deleted = 0
			AND BSA_Operator.Deleted = 0
			AND BSA_Operator.BSA_Operator_ID = '#arguments.operatorId#'
			</cfquery>

		<cfif qgetAnalystForOperator.recordcount GT 0>
			<cfreturn qgetAnalystForOperator.Analyst_User_ID>
		<cfelse>
			<cfquery name="qgetAnalystForOperator" datasource="#application.datasource#">
			SELECT BB_Assignment.Analyst_User_ID
				FROM BB_Assignment
				INNER JOIN BSA_Operator
				ON BSA_Operator.BSA_Operator_ID = '#arguments.operatorId#'
				AND BSA_Operator.Deleted = 0
				INNER JOIN User_Positions
				ON BSA_Operator.User_Positions_ID = User_Positions.User_Positions_ID
				AND BB_Assignment.Service_Market_ID = User_Positions.Service_Market_ID
			WHERE BB_Assignment.Deleted = 0
			</cfquery>

			<cfif qgetAnalystForOperator.recordcount GT 0>
				<cfreturn qgetAnalystForOperator.Analyst_User_ID>
			</cfif>
		</cfif>

		<cfif qgetAnalystForOperator.recordcount EQ 0>
		<!------ Still no analyst, return the default analyst ----->
			<cfset qGetDefaultAnalyst = getAnalysts(bDefaultAnalyst = 1) />
			<cfreturn qGetDefaultAnalyst.Analyst_User_ID />
		</cfif>

	</cffunction>

	<cffunction name="getAvailableSupervisors" output="false" returntype="query">

		<cfquery name="qGetAvailableSupervisors" datasource="#application.datasource#">
			SELECT 		Analyst_User_ID,
					Name_First,
					Name_Last
			FROM 		BB_Analyst
			INNER JOIN 	_Users
			ON 		_Users.User_ID = BB_Analyst.Analyst_User_ID
			WHERE 		BB_Analyst.Deleted = 0
			AND 		_Users.Deleted = 0
			AND 		Is_Supervisor = 1
			AND 		Is_Director = 0
			AND		Director_ID IS NULL
			Order By Name_First
		</cfquery>

		<cfreturn qGetAvailableSupervisors />

	</cffunction>

	<cffunction name="saveDirectors" output="false" returntype="void">

		<cfargument name="directorUserIDList" type="string" required="true" />
		<cfargument name="byUserId" type="string" required="true" />

		<!------ Get the current supervisor list ----->
		<cfset qGetDirectors = getDirectors() />

		<!------ Add the directors which are new ----->
		<cfif arguments.directorUserIDList NEQ "">
			<cfquery name="qAddDirector" datasource="#application.datasource#">
				UPDATE	BB_Analyst
				SET		Is_Director = 1,
						Director_ID = NULL
				WHERE	Deleted = 0
				AND		Analyst_User_ID IN (<cfqueryparam value="#arguments.directorUserIDList#" cfsqltype="CF_SQL_VARCHAR" list="true">)
				AND		(Is_Director = 0 OR Director_ID IS NOT NULL)
			</cfquery>



			<!------ set Director_ID to NULL if the director was removed from director list ----->

			<cfquery name="qChangeToDefaultDirector" datasource="#application.datasource#">
				UPDATE	BB_Analyst
				SET		Director_ID = NULL
				WHERE	Deleted = 0
				AND		Director_ID NOT IN (<cfqueryparam value="#arguments.directorUserIDList#" cfsqltype="CF_SQL_VARCHAR" list="true">)
				AND		Is_Director = 0
			</cfquery>


			<!------ Remove the directorss which are to be removed ----->
			<cfquery name="qRemoveDirector" datasource="#application.datasource#">
				UPDATE	BB_Analyst
				SET		Is_director = 0
				WHERE	Deleted = 0
				AND		Analyst_User_ID NOT IN (<cfqueryparam value="#arguments.directorUserIDList#" cfsqltype="CF_SQL_VARCHAR" list="true">)
				AND		Is_Director = 1
			</cfquery>
		</cfif>

	</cffunction>

	<cffunction name="isDirector" output="false" returntype="boolean">
		<cfargument name="userId" type="string" required="false" default="" />

		<cfset qGetDirectors = GetDirectors(analystUserId = arguments.userId) />

		<cfif qGetDirectors.recordCount GT 0>
			<cfreturn true />
		</cfif>

		<cfreturn false />
	</cffunction>

	<cffunction name="getAssignNewDistributorsToDefaultAnalyst" output="false" returntype="boolean">
		<cfset useLakebaseForgetAssign_New_Distributors_to_Default_Analyst = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_application_settings")>
<cfif useLakebaseForgetAssign_New_Distributors_to_Default_Analyst>
	<cftry>
		<cfset getAssign_New_Distributors_to_Default_Analyst = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_application_settings", {
				"select" = "assign_new_distributors_to_default_analyst"
			}), "assign_new_distributors_to_default_analyst"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetAssign_New_Distributors_to_Default_Analyst = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetAssign_New_Distributors_to_Default_Analyst>
<cfquery name="getAssign_New_Distributors_to_Default_Analyst" datasource="#application.datasource#">
				select Assign_New_Distributors_to_Default_Analyst
				from _Application_Settings
		</cfquery>
</cfif>
		<cfreturn getAssign_New_Distributors_to_Default_Analyst.Assign_New_Distributors_to_Default_Analyst />
	</cffunction>

	<cffunction name="getAssignNewOperatorsToDefaultAnalyst" output="false" returntype="boolean">
		<cfset useLakebaseForgetAssign_New_Operators_to_Default_Analyst = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_application_settings")>
<cfif useLakebaseForgetAssign_New_Operators_to_Default_Analyst>
	<cftry>
		<cfset getAssign_New_Operators_to_Default_Analyst = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_application_settings", {
				"select" = "assign_new_operators_to_default_analyst"
			}), "assign_new_operators_to_default_analyst"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetAssign_New_Operators_to_Default_Analyst = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetAssign_New_Operators_to_Default_Analyst>
<cfquery name="getAssign_New_Operators_to_Default_Analyst" datasource="#application.datasource#">
				select Assign_New_Operators_to_Default_Analyst
				from _Application_Settings
		</cfquery>
</cfif>
		<cfreturn getAssign_New_Operators_to_Default_Analyst.Assign_New_Operators_to_Default_Analyst />
	</cffunction>
</cfcomponent>