<!------ Get application settings ----->
<!--- <cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()> --->
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<cfset GP_Supplied_Position = CreateObject("component", "components.user.UserManager").getPositionId(request.AccessStructure.user_id, 0, 1) />
<cfset HQPosition = CreateObject("component", "components.geography.position").getHQPosition() />

<cfset UserPositionList = GP_Supplied_Position>

<!--- "UseHashTables" is 1 when the user does search from flex --->
<cfparam name="UseHashTables" default="0">

<CFINCLUDE TEMPLATE="\settings\Access_Rights\approval_tree\get_positions_underneath_supplied_position.cfm">

<!--- D12833 BJF and DRK: If the user is HQ, they should be able to see all positions, so don't do the joins on user position

NOTE: It would further increase performance if all calling pages were modified NOT to include the list of programs if the users
--->
<cfset HQUser = 0>

<cfif FindNoCase("SELECT", GP_Supplied_Position)><!--- If raw query was returned --->
	<cfset HQUser = CreateObject("component", "components.user.UserManager").getUserIsHQ(request.AccessStructure.user_id, 0) />
<cfelse><!--- If list of positions were returned --->
	<cfif listfind(GP_Supplied_Position, HQPosition.User_Positions_ID)>
		<cfset HQUser = 1>
	</cfif>
</cfif>

<cfset BillbackIDs = "" />
<cfset AllowBillbackIDs = "" />
<cfset AllowAnalystIds = "" />
<cfset AnalystList = "" />

<!------ find if the user is an analyst ----->
<cfset billbackAssignmentManager = CreateObject("component", "components.billback.BillbackAssignmentManager") />
<cfset UserIsAnalyst = billbackAssignmentManager.isAnalyst(request.AccessStructure.User_ID) />
<cfset UserIsDirector = billbackAssignmentManager.isDirector(request.AccessStructure.User_ID) />

<!------
BIllback access rules
- Users who have access to billbacks who are not identified as analysts will see all billbacks that they created or are in their position tree.  (existing rule)
- Users who are identified as billback analysts will see what they created or those billbacks with a distributor who belongs in the markets and/or customers that are assigned to them in the billback assignment tool
	1. Customer level assignment will override market level assignment just like deduction.
	2. Billback analysts will not see billbacks based on position tree
	3. There will be only 1 analyst per billback
- Users who are identified as supervisors will see billbacks they create as well as those billbacks that their analysts see.
----->
<!--- D12833 If the user is not HQ we need to figure out which billbacks they can see --->



<!--- MAYBE HAVE A CONDITION AS TO WHEN TO USE TEMP TABLE AND WHEN MEMORY TABLES AS THIS FILE IS BEING CALLED FROM MULTIPLE PLACES --->
	<cfif UserIsAnalyst EQ 0> <!--- If the user is not an analyst, use the position tree  --->
	<cfif HQUser IS NOT 1>
		<cfoutput>
			<cfsavecontent variable="AllowBillbackIDs">

				if object_id('tempdb..##tmp_Positions_Below_Me') IS NOT NULL
				drop table ##tmp_Positions_Below_Me

				SELECT	DISTINCT Below_User_Positions_ID
				INTO	##tmp_Positions_Below_Me
				FROM	Positions_Below_Me
				WHERE	User_Positions_ID IN (#PreserveSingleQuotes(GP_Position_List_From_My_Position_Down)#)

				<cfif UseHashTables eq 0>
				DECLARE @Distributor_Allowed_Billbacks table
				<cfelse>
				CREATE TABLE ##Distributor_Allowed_Billbacks
				</cfif>
				(
				  Billback_Id   uniqueidentifier          NOT NULL
				)


				<cfif UseHashTables eq 0>
				INSERT INTO @Distributor_Allowed_Billbacks
				<cfelse>
				INSERT INTO ##Distributor_Allowed_Billbacks
				</cfif>
				SELECT 	bb.Billback_ID


				FROM
				Billback bb
				---------------------------------------------------
				INNER JOIN
					(
					Billback_Distributor
					INNER JOIN
					BSA_Foodservice_Customers
					ON Billback_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
					)
				ON
				(
				(Billback_Distributor.Billback_ID = bb.Billback_ID)
				AND
				(bb.Billback_Payee_Type_ID = 1)
				AND
				(Billback_Distributor.Deleted = 0)
				)

				<cfif appSettings.getDistributorMultiPosition()>
				INNER JOIN	Market_Distributor
				ON Market_Distributor.Deleted = 0
				AND BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Market_Distributor.Distributor_ID
				<cfelse>
				LEFT JOIN BSA_Foodservice_Brokers
				ON	BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID =  BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID
				</cfif>
				INNER JOIN	User_Positions
				ON
				(
					(
						<cfif appSettings.getDistributorMultiPosition()>
						(Market_Distributor.Service_Market_ID = User_Positions.Service_Market_ID)
						<cfelse>
						(BSA_Foodservice_Brokers.Service_Market_ID = User_Positions.Service_Market_ID)
						</cfif>
					)
					AND
					(User_Positions.User_Positions_ID IN (SELECT	DISTINCT Below_User_Positions_ID FROM	##tmp_Positions_Below_Me))
				)
				AND EXISTS (SELECT	1 FROM	##tmp_Positions_Below_Me WHERE Below_User_Positions_ID = User_Positions.User_Positions_ID)
				WHERE
				bb.Deleted = 0

				-----------------Markets--------------------------
				<cfif UseHashTables eq 0>
				DECLARE @Market_Allowed_Billbacks table
				<cfelse>
				CREATE TABLE ##Market_Allowed_Billbacks
				</cfif>
				(
				  Billback_Id   uniqueidentifier          NOT NULL
				)


				<cfif UseHashTables eq 0>
				INSERT INTO @Market_Allowed_Billbacks
				<cfelse>
				INSERT INTO ##Market_Allowed_Billbacks
				</cfif>
				SELECT	bb.Billback_ID

				FROM
				Billback bb
				---------------------------------------------------

				INNER JOIN	Billback_Broker
				ON
				(
				(Billback_Broker.Billback_ID = bb.Billback_ID)
				AND
				(bb.Billback_Payee_Type_ID = 3)
				AND
				(Billback_Broker.Deleted = 0)
				)
				----------------------------------------------------
				INNER JOIN	BSA_Foodservice_Brokers
				ON

				(Billback_Broker.Broker_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID)

				INNER JOIN	User_Positions
				ON
				(
					(
						(BSA_Foodservice_Brokers.Service_Market_ID = User_Positions.Service_Market_ID)
					)
					AND
					(User_Positions.User_Positions_ID IN (SELECT	DISTINCT Below_User_Positions_ID FROM	##tmp_Positions_Below_Me))
				)
				AND EXISTS (SELECT	1 FROM	##tmp_Positions_Below_Me WHERE Below_User_Positions_ID = User_Positions.User_Positions_ID)

				WHERE
				bb.Deleted = 0

				<cfif UseHashTables eq 0>
				DECLARE @Position_Allowed_Billbacks table
				<cfelse>
				CREATE TABLE ##Position_Allowed_Billbacks
				</cfif>
				(
				  Billback_Id   uniqueidentifier          NOT NULL
				)

				<cfif UseHashTables eq 0>
				INSERT INTO @Position_Allowed_Billbacks
				<cfelse>
				INSERT INTO ##Position_Allowed_Billbacks
				</cfif>

				SELECT	Billback.Billback_ID
				FROM	Billback
				WHERE	Deleted = 0
				<!---AND	BB_Creator_User_Position_ID IN (#PreserveSingleQuotes(GP_Position_List_From_My_Position_Down)#)--->
				AND EXISTS (SELECT	1 FROM	##tmp_Positions_Below_Me WHERE Below_User_Positions_ID = BB_Creator_User_Position_ID)


				<cfif UseHashTables eq 0>
				INSERT INTO @Position_Allowed_Billbacks
				<cfelse>
				INSERT INTO ##Position_Allowed_Billbacks
				</cfif>

				<!--- Users should be able to see billbacks from their programs --->
				SELECT	Billback.Billback_ID
				FROM	Billback
				INNER JOIN Billback_Program
				ON		Billback_Program.Billback_ID = Billback.Billback_ID
				AND		Billback_Program.Deleted = 0
				INNER JOIN Contract_Main
				ON		 Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
				WHERE	Billback.Deleted = 0
				<!---AND		Contract_Main.Creating_User_Position_ID IN (#PreserveSingleQuotes(GP_Position_List_From_My_Position_Down)#)---->
				AND EXISTS (SELECT	1 FROM	##tmp_Positions_Below_Me WHERE Below_User_Positions_ID =  Contract_Main.Creating_User_Position_ID)


				<cfif UseHashTables eq 0>
				DECLARE @Allow_Only_Billbacks table
				<cfelse>
				CREATE TABLE ##Allow_Only_Billbacks
				</cfif>
				(
				  Billback_Id   uniqueidentifier          NOT NULL
				)

				<cfif UseHashTables eq 0>
				INSERT INTO @Allow_Only_Billbacks
				<cfelse>
				INSERT INTO ##Allow_Only_Billbacks
				</cfif>

				SELECT	Billback_ID
				<cfif UseHashTables eq 0>
				FROM	@Market_Allowed_Billbacks
				<cfelse>
				FROM	##Market_Allowed_Billbacks
				</cfif>

				UNION
				SELECT	Billback_ID
				<cfif UseHashTables eq 0>
				FROM	@Distributor_Allowed_Billbacks
				<cfelse>
				FROM	##Distributor_Allowed_Billbacks
				</cfif>

				UNION
				SELECT	Billback_ID

				<cfif UseHashTables eq 0>
				FROM	@Position_Allowed_Billbacks
				<cfelse>
				FROM	##Position_Allowed_Billbacks
				</cfif>

			</cfsavecontent>
		</cfoutput>

		<cfif UseHashTables eq 0>
			<cfset BillbackIDs = "SELECT Billback_Id FROM @Allow_Only_Billbacks" />
		<cfelse>
			<cfset BillbackIDs = "SELECT Billback_Id FROM ##Allow_Only_Billbacks" />
		</cfif>
	<cfelse><!--- The user has an HQ position and can see all billbacks --->
		<cfset BillbackIDs = "SELECT Billback.Billback_Id Billback WHERE Billback.Deleted = 0" />
	</cfif>
<cfelse><!------ If the user is an analyst do not use the position tree, use the analyst supervisor rule described above ----->
	<cfoutput>
	<cfsavecontent variable="AllowAnalystIds">
		<cfif UseHashTables eq 0>
		DECLARE @Allow_Analysts table
		<cfelse>
		CREATE TABLE ##Allow_Analysts
		</cfif>
		(
		  Analyst_User_Id   NVARCHAR(50)
		)

		<cfif UseHashTables eq 0>
		INSERT INTO @Allow_Analysts(Analyst_User_Id) VALUES('#request.AccessStructure.User_ID#')
		INSERT INTO @Allow_Analysts(Analyst_User_Id)
		<cfelse>
		INSERT INTO ##Allow_Analysts(Analyst_User_Id) VALUES('#request.AccessStructure.User_ID#')
		INSERT INTO ##Allow_Analysts(Analyst_User_Id)
		</cfif>

		SELECT	Analyst_User_Id
		FROM	BB_Analyst
		WHERE	Deleted = 0

		<cfif UserIsDirector EQ 0>
			AND		Supervisor_ID = '#request.AccessStructure.User_ID#'
		<cfelse>
			AND	Supervisor_ID in (
			SELECT	Analyst_User_Id
			FROM	BB_Analyst
			WHERE	Deleted = 0
			AND	director_ID = '#request.AccessStructure.User_ID#')
		</cfif>
            <!---  D43145 :: Billback Scorecard Summary
				If user is director, include supervisors also in the list
				 --->
            <cfif UserIsDirector EQ 1>
            UNION
            SELECT      Analyst_User_Id
            FROM  BB_Analyst
            WHERE Deleted = 0
            AND         director_ID = '#request.AccessStructure.User_ID#'
            </cfif>

	</cfsavecontent>
	<cfif UseHashTables eq 0>
		<cfset AnalystList = "SELECT Analyst_User_Id FROM @Allow_Analysts" />
	<cfelse>
		<cfset AnalystList = "SELECT Analyst_User_Id FROM ##Allow_Analysts" />
	</cfif>
	</cfoutput>
</cfif>

	<!--- Only when "UserHashTables" is 1, will these tables exist --->
	<cfquery name="del_temp_tables" datasource="#application.datasource#">
		if object_id('tempdb..##Market_Allowed_Billbacks') is not null
		drop table ##Market_Allowed_Billbacks

		if object_id('tempdb..##Distributor_Allowed_Billbacks') is not null
		drop table ##Distributor_Allowed_Billbacks

		if object_id('tempdb..##Position_Allowed_Billbacks') is not null
		drop table ##Position_Allowed_Billbacks
	</cfquery>