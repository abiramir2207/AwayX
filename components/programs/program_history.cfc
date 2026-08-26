<cfcomponent hint="Program Change History" extends="components.Base">

	<cffunction name="init" output="false" returntype="components.programs.program_history">
	
		<cfreturn this />
		
	</cffunction>

	<!--- Get the Contract Number of the program --->
	<cffunction name="getContractNumber" output="false" returntype="query">
		<cfargument name="ProgramId" type="string" required="true">
		<cfargument name="GetFromContractMain" type="boolean" required="false" default="0">

			<cfquery name="qgetContractNumber" datasource="#application.datasource#">
				SELECT	Contract_Number
			<cfif GetFromContractMain eq 1>
				FROM	Contract_Main
			<cfelse>
				FROM	Program_History
			</cfif>				
				WHERE	Contract_Main_ID ='#arguments.ProgramId#'
			</cfquery>
			<cfreturn qgetContractNumber>
	</cffunction>
	
	<!--- Get the number of Existing Revisions --->
	<cffunction name="getHistoryCount" output="false" returntype="query">
		<cfargument name="Contract_Number" type="string" required="true">

			<cfquery name="qgetHistoryCount" datasource="#application.datasource#">
				SELECT	count(Contract_Number) As ProgramCount
				FROM	Program_History
				WHERE	Contract_Number ='#arguments.Contract_Number#'
			</cfquery>
			<cfreturn qgetHistoryCount>
	</cffunction>
	
	<!--- Get the persons who agreed to the program --->
	<cffunction name="getProgramAgreed" output="false" returntype="query">
		<cfargument name="ProgramId" type="string" required="true">
		
			<cfquery name="qgetProgramAgreed" datasource="#application.datasource#">
				SELECT 	Name_First, Name_Last, Max(Agree_DateTime) Agree_DateTime
				FROM 	Program_Agree pa INNER JOIN _Users u
				ON 		pa.User_Id = u.User_Id
				WHERE 	pa.ProgramID = #arguments.ProgramID#
				AND		pa.System_Agreement = 0
				GROUP BY u.User_ID,Name_Last, Name_First 
			</cfquery>
			<cfreturn qgetProgramAgreed>
	</cffunction>
	
	<!--- Get the persons User position ID (Required for Sales Person Responsible) --->
	<cffunction name="getUserPosition" output="false" returntype="query">
		<cfargument name="UserPositionID" type="string" required="true">

			<cfquery name="qgetUserPosition" datasource="#application.datasource#">
				SELECT Position_Label
				FROM User_Positions
				WHERE User_Positions_ID = '#arguments.UserPositionID#'
			</cfquery>
			<cfreturn qgetUserPosition>
	</cffunction>
	<!---
	<cffunction name="getRebateClaimMechanics" output="false" returntype="query">
		<cfargument name="ProgramID" type="string" required="true">

			<cfset useLakebaseForqgetClaimMechanics = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_rebates_component")>
<cfif useLakebaseForqgetClaimMechanics>
	<cftry>
		<cfset qgetClaimMechanics = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_rebates_component", {
				"program_id" = "eq.#arguments.ProgramID#",
				"select" = "claim_mechanics"
			}), "claim_mechanics"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetClaimMechanics = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetClaimMechanics>
<cfquery name="qgetClaimMechanics" datasource="#application.datasource#">
				SELECT DISTINCT Claim_Mechanics
				FROM Program_Rebates_Component
				WHERE Program_ID = '#arguments.ProgramID#'
			</cfquery>
</cfif>
			<cfreturn qgetClaimMechanics>
	</cffunction>
	--->

	<cffunction name="getResponsibleUser" output="false" returntype="query">
		<cfargument name="ContractNumber" type="string" required="true">
		<cfargument name="ApprovedDate" type="date" required="true">
		
			<cfquery name="qgetResponsibleUser" datasource="#application.datasource#">
				SELECT Responsible_User_ID, Creating_User_Position_ID
				FROM Program_Owner
				WHERE Program_Owner_ID = 
				(SELECT MAX(Program_Owner_ID) 
				 FROM Program_Owner
				 WHERE Contract_Number = '#ContractNumber#'
				 AND Date_Created <='#ApprovedDate#'
				 )
			</cfquery>
			<cfreturn qgetResponsibleUser>
	</cffunction>

	<!--- Get the programs that have been revised --->
	<cffunction name="getChangedPrograms" output="false" returntype="query">		
			<cfquery name="qgetChangedPrograms" datasource="#application.datasource#">
				SELECT TOP 100 * 
				FROM Get_Program_History_Programs
				<!--- Dev Note: Milan; 11370 - I have added the "ORDER BY" below, so that newer programs are updated
					  before the older programs, since I am using top 100 for the query now. Top 100 is required in case
					  of changes to a massive number of programs --->
				ORDER BY Child_Contract_Main_ID DESC
			</cfquery>
		<cfreturn qGetChangedPrograms>		
	</cffunction>
	

	<!--- Get the programs that have been approved --->
	<cffunction name="getApprovedPrograms" output="false" returntype="query">		
        <cfquery datasource="#application.datasource#">
            IF OBJECT_ID('TEMPDB..##Tmp_Pgms') IS NOT NULL
                DROP TABLE ##Tmp_Pgms
        </cfquery>

		<cfquery name="qGetApprovedPrograms" datasource="#application.datasource#">
            SELECT Contract_Main_ID 
              INTO ##Tmp_Pgms 
              FROM Program_History
             WHERE Program_History_Action_ID = 50

			SELECT	
					Contract_Main.Contract_Main_ID, 
					Contract_Main.Contract_Number,
					Contract_Main.Revision_Version,
					Contract_Main.Contract_Title, 
					Contract_Main.Contract_Start_Date, 
					Contract_Main.Contract_End_Date,
					CU.Name_First + ' ' + CU.Name_Last As Approver,
					CSP.Name_First + ' ' + CSP.Name_Last As SP,
					Creator.Name_First + ' ' + Creator.Name_Last As Creator,
					RFA_User.Name_First + ' ' + RFA_User.Name_Last As RFA_User,
					Contract_Main.Contract_Created_Date,
					Contract_Main.Approval_Date,
					Contract_Main.Broker_Approved_Date
			FROM	Contract_Main
					<!------ Approver ----->
					LEFT JOIN _Users CU
					ON
					CU.Deleted = 0
					AND CU.User_ID = Contract_Main.Approved_By_User_ID
					<!------ Sales Person Responsible ----->
					LEFT JOIN _Users CSP
					ON
					CSP.Deleted = 0
					AND CSP.User_ID = Contract_Main.Responsible_User_ID
					<!------ Creator ----->
					LEFT JOIN _Users Creator
					ON
					Creator.Deleted = 0
					AND Creator.User_ID = Contract_Main.Creator_ID
					<!------ RFA User ----->
					LEFT JOIN _Users RFA_User
					ON
					RFA_User.Deleted = 0
					AND RFA_User.User_ID = Contract_Main.Broker_User_ID					
			WHERE 	Contract_Main.Parent_Revised_Contract_Main_ID IS NULL 
					AND Contract_Main.Revision_of_Contract_Main_ID IS NULL 
					
					AND Contract_Main.Contract_Status_Type_IDX >= 4
					<!------ Added the lines below to avoid an error message ----->
					AND Contract_Main.Approved = 1
					AND NOT EXISTS (SELECT 1 FROM ##Tmp_Pgms t WHERE t.Contract_Main_ID = Contract_Main.Contract_Main_ID)
					
		</cfquery>
		<cfreturn qGetApprovedPrograms>		
	</cffunction>	
	
	<!--- Get the programs that have been cancelled --->
	<cffunction name="getCancelledPrograms" output="false" returntype="query">		
        <cfquery datasource="#application.datasource#">
            IF OBJECT_ID('TEMPDB..##Tmp_Pgms') IS NOT NULL
                DROP TABLE ##Tmp_Pgms
        </cfquery>
        
		<cfquery name="qGetCancelledPrograms" datasource="#application.datasource#">
            SELECT Contract_Main_ID 
              INTO ##Tmp_Pgms 
              FROM Program_History
             WHERE Program_History_Action_ID = 500

			SELECT	
					Contract_Main.Contract_Main_ID, 
					Contract_Main.Contract_Number,
					Contract_Main.Revision_Version,
					Contract_Main.Contract_Title, 
					Contract_Main.Contract_Start_Date, 
					Contract_Main.Contract_End_Date,
					Contract_Main.Cancelled_Date,
					CancelledUser.Name_First + ' ' + CancelledUser.Name_Last As Cancelled_By_User,
					ISNULL(Contract_Main.Manual_Cancel, 0) Manual_Cancel

			FROM	Contract_Main
					<!------ Cancelled_By ----->
					LEFT JOIN _Users CancelledUser
					ON
					CancelledUser.Deleted = 0
					AND CancelledUser.User_ID = Contract_Main.Cancelled_By
					WHERE Contract_Main.Manual_Cancel = 1
					AND Contract_Main.Contract_Status_Type_IDX >= 4
					AND Contract_Main.Approved = 1
					AND NOT EXISTS (SELECT 1 FROM ##Tmp_Pgms t WHERE t.Contract_Main_ID = Contract_Main.Contract_Main_ID)
					
		</cfquery>
		<cfreturn qGetCancelledPrograms>		
	</cffunction>	
	
	<!--- Get the list of user agreed for this program --->
	<cffunction name="getAgreedUsers" output="false" returntype="query">	
		<cfargument name="programId" type="numeric" required="true">
		<cfquery name="qGetAgreedUsers" datasource="#application.datasource#">
			SELECT 	Name_First, Name_Last, Max(Agree_DateTime) Agree_DateTime
			FROM 	Program_Agree pa 
			INNER JOIN _Users u
			ON 		pa.User_Id = u.User_Id
			WHERE 	pa.ProgramID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
			AND		pa.System_Agreement = 0
			GROUP BY u.User_ID,	u.Name_Last, u.Name_First 
		</cfquery>
		<cfreturn qGetAgreedUsers />
	</cffunction>
	
	
	<!--- Get the claim mechanics --->
	<cffunction name="getPaymentTypes" output="false" returntype="query">
		<cfargument name="Payment_Type_ID" type="string" required="true">

			<cfquery name="qgetPaymentTypes" datasource="#application.datasource#">
				SELECT	Payment_Type_Name
				FROM	Payment_Type
				WHERE	Payment_Type_ID ='#arguments.Payment_Type_ID#'
			</cfquery>
			<cfreturn qgetPaymentTypes>
	</cffunction>
	
		<!--- Get the payment cycle --->
	<cffunction name="getPaymentCycle" output="false" returntype="query">
		<cfargument name="Payment_Cycle_ID" type="string" required="true">

			<cfset useLakebaseForqgetPaymentCycle = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("payment_cycle")>
<cfif useLakebaseForqgetPaymentCycle>
	<cftry>
		<cfset qgetPaymentCycle = application.oLakebase.toQuery(
			application.oLakebase.selectRows("payment_cycle", {
				"payment_cycle_id" = "eq.#arguments.Payment_Cycle_ID#",
				"select" = "payment_cycle"
			}), "payment_cycle"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetPaymentCycle = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetPaymentCycle>
<cfquery name="qgetPaymentCycle" datasource="#application.datasource#">
				SELECT	Payment_Cycle
				FROM	Payment_Cycle
				WHERE	Payment_Cycle_ID ='#arguments.Payment_Cycle_ID#'
			</cfquery>
</cfif>
			<cfreturn qgetPaymentCycle>
	</cffunction>
	
	<cffunction name="getUserName" output="false" returntype="query">	
		<cfargument name="UserID" type="string" required="true">
		
		<cfset useLakebaseForqGetUserName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForqGetUserName>
	<cftry>
		<cfset qGetUserName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#UserID#",
				"select" = "name_first + ' ' + name_last as name"
			}), "name_first + ' ' + name_last as name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetUserName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetUserName>
<cfquery name="qGetUserName" datasource="#application.datasource#">
			SELECT Name_First + ' ' + Name_Last As Name
			FROM _Users 
			WHERE User_ID ='#UserID#'
		</cfquery>
</cfif>
		<cfreturn qGetUserName>
	</cffunction>
	
	<cffunction name="getOperatorsRemoved" output="false" returntype="query">	
		<cfargument name="ProgramId1" type="numeric" required="true">
		<cfargument name="ProgramId2" type="numeric" required="true">
		<cfargument name="showOnlyChange" type="numeric" required="true">
		
		<cfquery name="qGetOperator" datasource="#application.datasource#">
			SELECT	
					CASE 
					WHEN Child_Contract_Operators.BSA_Operator_ID IS NULL THEN
						''
					ELSE
						BSA_Operator.Operator_Name
					END As Child_Name,
					CASE 
					WHEN Parent_Contract_Operators.BSA_Operator_ID IS NULL THEN
						''
					ELSE
						BSA_Operator.Operator_Name
					END As Parent_Name,
					CASE 
					WHEN Child_Contract_Operators.BSA_Operator_ID IS NULL AND Parent_Contract_Operators.BSA_Operator_ID IS NOT NULL THEN
						1
					ELSE
						0
					END As Deleted,
					CASE 
					WHEN Child_Contract_Operators.BSA_Operator_ID IS NOT NULL AND Parent_Contract_Operators.BSA_Operator_ID IS NULL THEN
						1
					ELSE
						0
					END As Added,
					0 As Change
			FROM	Contract_Main
					LEFT JOIN Contract_Operators Child_Contract_Operators
					ON	Child_Contract_Operators.Deleted = 0
					AND	Child_Contract_Operators.Contract_Main_ID = Contract_Main.Contract_Main_ID
					LEFT JOIN Contract_Operators Parent_Contract_Operators
					ON	Parent_Contract_Operators.Deleted = 0
					AND	Parent_Contract_Operators.Contract_Main_ID = #arguments.ProgramId2#
					AND	Child_Contract_Operators.BSA_Operator_ID = Parent_Contract_Operators.BSA_Operator_ID
					INNER JOIN BSA_Operator
					ON	BSA_Operator.Deleted = 0
					AND	(BSA_Operator.BSA_Operator_ID = Child_Contract_Operators.BSA_Operator_ID
						OR
						BSA_Operator.BSA_Operator_ID = Parent_Contract_Operators.BSA_Operator_ID
						)
					AND ISNULL(Child_Contract_Operators.BSA_Operator_ID, Parent_Contract_Operators.BSA_Operator_ID) = ISNULL(Parent_Contract_Operators.BSA_Operator_ID, Child_Contract_Operators.BSA_Operator_ID)
					<cfif arguments.showOnlyChange>
					AND Parent_Contract_Operators.BSA_Operator_ID IS NULL
					</cfif>
					<!------ AND (Child_Contract_Operators.BSA_Operator_ID IS NULL OR Parent_Contract_Operators.BSA_Operator_ID IS NULL) ----->
			WHERE	Contract_Main.Contract_Main_ID = #arguments.ProgramId1#
		</cfquery>
		
		<cfreturn qGetOperator>
		
	</cffunction>
		
	<cffunction name="getDistributorsRemoved" output="false" returntype="query">	
		<cfargument name="ProgramId1" type="numeric" required="true">
		<cfargument name="ProgramId2" type="numeric" required="true">
		<cfargument name="showOnlyChange" type="numeric" required="true">
		
		<cfquery name="qGetDistributor" datasource="#application.datasource#">
			SELECT	DISTINCT BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID,
					CASE 
					WHEN Child_Contract_Distributors.BSA_Foodservice_Customers_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Customers.Name
					END As Child_Name,
					CASE 
					WHEN Parent_Contract_Distributors.BSA_Foodservice_Customers_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Customers.Name
					END As Parent_Name,
					Child_Contract_Distributors.BSA_Foodservice_Customers_ID Child_ID,
					Parent_Contract_Distributors.BSA_Foodservice_Customers_ID Parent_ID,
					Parent_Contract_Distributors.Program_Weight Parent_Weight,
					Child_Contract_Distributors.Program_Weight Child_Weight,
					CASE 
					WHEN Child_Contract_Distributors.BSA_Foodservice_Customers_ID IS NULL AND Parent_Contract_Distributors.BSA_Foodservice_Customers_ID IS NOT NULL THEN
						1
					ELSE
						0
					END As Deleted,
					CASE 
					WHEN Child_Contract_Distributors.BSA_Foodservice_Customers_ID IS NOT NULL AND Parent_Contract_Distributors.BSA_Foodservice_Customers_ID IS NULL THEN
						1
					ELSE
						0
					END As Added,
					CASE
					WHEN Child_Contract_Distributors.BSA_Foodservice_Customers_ID IS NOT NULL AND Parent_Contract_Distributors.BSA_Foodservice_Customers_ID IS NOT NULL AND Cast(Parent_Contract_Distributors.Program_Weight As float) <> CAST(Child_Contract_Distributors.Program_Weight As Float) THEN
						1
					ELSE
						0
					END As Change
			FROM	Contract_Main
					LEFT JOIN Contract_Distributors Child_Contract_Distributors
					ON	Child_Contract_Distributors.Deleted = 0
					AND	Child_Contract_Distributors.Contract_Main_ID = Contract_Main.Contract_Main_ID
					LEFT JOIN Contract_Distributors Parent_Contract_Distributors
					ON	Parent_Contract_Distributors.Deleted = 0
					AND	Parent_Contract_Distributors.Contract_Main_ID = #arguments.ProgramId2#
					AND	Child_Contract_Distributors.BSA_Foodservice_Customers_ID = Parent_Contract_Distributors.BSA_Foodservice_Customers_ID
					INNER JOIN BSA_Foodservice_Customers
					ON	BSA_Foodservice_Customers.Deleted = 0
					AND	(BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Child_Contract_Distributors.BSA_Foodservice_Customers_ID
						OR
						BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Parent_Contract_Distributors.BSA_Foodservice_Customers_ID
						)
					AND ISNULL(Child_Contract_Distributors.BSA_Foodservice_Customers_ID, Parent_Contract_Distributors.BSA_Foodservice_Customers_ID) = ISNULL(Parent_Contract_Distributors.BSA_Foodservice_Customers_ID, Child_Contract_Distributors.BSA_Foodservice_Customers_ID)
					<cfif arguments.showOnlyChange>
					AND Parent_Contract_Distributors.BSA_Foodservice_Customers_ID IS NULL
					</cfif>					
			WHERE	Contract_Main.Contract_Main_ID = #arguments.ProgramId1#
			ORDER BY Added, Deleted,Change
		</cfquery>
		
		<cfreturn qGetDistributor>
	
	</cffunction>
	
	<cffunction name="getBrokersRemoved" output="false" returntype="query">	
		<cfargument name="ProgramId1" type="numeric" required="true">
		<cfargument name="ProgramId2" type="numeric" required="true">
		<cfargument name="showOnlyChange" type="numeric" required="true">
		
		<cfquery name="qGetBroker" datasource="#application.datasource#">
			SELECT	DISTINCT BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID,
					CASE 
					WHEN Child_Contract_Brokers.BSA_Foodservice_Brokers_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Brokers.Broker_Name
					END As Child_Name,
					CASE 
					WHEN Parent_Contract_Brokers.BSA_Foodservice_Brokers_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Brokers.Broker_Name
					END As Parent_Name,
					CASE 
					WHEN Child_Contract_Brokers.BSA_Foodservice_Brokers_ID IS NULL AND Parent_Contract_Brokers.BSA_Foodservice_Brokers_ID IS NOT NULL THEN
						1
					ELSE
						0
					END As Deleted,
					CASE 
					WHEN Child_Contract_Brokers.BSA_Foodservice_Brokers_ID IS NOT NULL AND Parent_Contract_Brokers.BSA_Foodservice_Brokers_ID IS NULL THEN
						1
					ELSE
						0
					END As Added,
					0 As Change
			FROM	Contract_Main
					INNER JOIN Contract_Brokers Child_Contract_Brokers
					ON	Child_Contract_Brokers.Deleted = 0
					AND	Child_Contract_Brokers.Contract_Main_ID = Contract_Main.Contract_Main_ID
					LEFT JOIN Contract_Brokers Parent_Contract_Brokers
					ON	Parent_Contract_Brokers.Deleted = 0
					AND	Parent_Contract_Brokers.Contract_Main_ID = #arguments.ProgramId2#
					AND Child_Contract_Brokers.BSA_Foodservice_Brokers_ID = Parent_Contract_Brokers.BSA_Foodservice_Brokers_ID
					INNER JOIN BSA_Foodservice_Brokers
					ON	BSA_Foodservice_Brokers.Deleted = 0
					AND	(BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Child_Contract_Brokers.BSA_Foodservice_Brokers_ID
						OR
						BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Parent_Contract_Brokers.BSA_Foodservice_Brokers_ID
						)
					AND ISNULL(Child_Contract_Brokers.BSA_Foodservice_Brokers_ID, Parent_Contract_Brokers.BSA_Foodservice_Brokers_ID) = ISNULL(Parent_Contract_Brokers.BSA_Foodservice_Brokers_ID, Child_Contract_Brokers.BSA_Foodservice_Brokers_ID)
					<cfif arguments.showOnlyChange>
					AND Parent_Contract_Brokers.BSA_Foodservice_Brokers_ID IS NULL
					</cfif>					
			WHERE	Contract_Main.Contract_Main_ID = #arguments.ProgramId1#
		</cfquery>
		
		<cfreturn qGetBroker>
	</cffunction>
	
	<cffunction name="getFixedRemoved" output="false" returntype="query">	
		<cfargument name="ProgramId1" type="numeric" required="true">
		<cfargument name="ProgramId2" type="numeric" required="true">
		<!---
		<cfargument name="showOnlyChange" type="numeric" required="true">
		--->
		
		<cfquery name="qGetFixed" datasource="#application.datasource#">
			SELECT	DISTINCT BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
					First_Contract_Products.BSA_Foodservice_Items_Master_ID First_ID,
					Second_Contract_Products.BSA_Foodservice_Items_Master_ID Second_ID,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Item
					END As First_Item_ID,
					CASE 
					WHEN Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Item
					END As Second_Item_ID,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Description
					END As First_Name,
					CASE 
					WHEN Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Description
					END As Second_Name,
					First_Fixed.Fixed_Price_Value First_Price,
					Second_Fixed.Fixed_Price_Value Second_Price,
					First_Units_Of_Measure.Abbreviation First_UOM,
					Second_Units_Of_Measure.Abbreviation Second_UOM,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						1
					ELSE
						0
					END As Deleted,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL THEN
						1
					ELSE
						0
					END As Added,
					CASE
					WHEN 	First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL  
							AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL  
							AND (First_Program_Fixed.Program_Fixed_Component_Name_ID = Second_Program_Fixed.Program_Fixed_Component_Name_ID
								AND
								(First_Fixed.Fixed_Price_Value <> Second_Fixed.Fixed_Price_Value)
								OR 
								(First_Units_Of_Measure.Abbreviation <> Second_Units_Of_Measure.Abbreviation)
								) THEN
						1
					ELSE
						0
					END As Change,
					First_Program_Fixed.Program_Fixed_Component_Name_ID First_Component_ID,
					Second_Program_Fixed.Program_Fixed_Component_Name_ID Second_Component_ID,
					Program_Fixed_Component_Name.Program_Fixed_Component_Name
			FROM	Contract_Main
					<!------ Contract Products ----->
					INNER JOIN Contract_Products First_Contract_Products
					ON	First_Contract_Products.Deleted = 0
					AND	First_Contract_Products.Product_Type_ID = 1
					AND	First_Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
					AND 
					(
						<!------ Group ----->
						(First_Contract_Products.Product_Group_ID = CAST(First_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND First_Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(First_Contract_Products.Product_Group_ID, '') = '' AND First_Contract_Products.Is_Group = 0)
					) 
					LEFT JOIN Contract_Products Second_Contract_Products
					ON	Second_Contract_Products.Deleted = 0
					AND	Second_Contract_Products.Product_Type_ID = 1
					AND	Second_Contract_Products.Contract_Main_ID = #arguments.ProgramId1#
					AND	First_Contract_Products.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
					AND 
					(
						<!------ Group ----->
						(Second_Contract_Products.Product_Group_ID = CAST(Second_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Second_Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(Second_Contract_Products.Product_Group_ID, '') = '' AND Second_Contract_Products.Is_Group = 0)
					) 
					<!------ Fixed ----->
					INNER JOIN Program_Fixed_Price_Product_Data First_Fixed
					ON	First_Fixed.Deleted = 0
					AND	First_Fixed.Contract_Products_ID = First_Contract_Products.Contract_Products_ID
					LEFT JOIN Program_Fixed_Price_Product_Data Second_Fixed
					ON	Second_Fixed.Deleted = 0
					AND	Second_Fixed.Contract_Products_ID = Second_Contract_Products.Contract_Products_ID
					INNER JOIN Program_Fixed_Component First_Program_Fixed
					ON First_Program_Fixed.Program_Fixed_Component_ID = First_Fixed.Program_Fixed_Component_ID
					AND First_Program_Fixed.deleted = 0
					LEFT JOIN Program_Fixed_Component Second_Program_Fixed
					ON Second_Program_Fixed.Program_Fixed_Component_ID = Second_Fixed.Program_Fixed_Component_ID
					AND Second_Program_Fixed.deleted = 0
					LEFT JOIN Program_Fixed_Component_Name 
					ON First_Program_Fixed.Program_Fixed_Component_Name_ID =  Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID							
					<!------ UOM ----->
					INNER JOIN Units_Of_Measure First_Units_Of_Measure
					ON
					First_Units_Of_Measure.Unit_Of_Measure_ID = First_Fixed.Unit_Of_Measure_ID
					LEFT JOIN Units_Of_Measure Second_Units_Of_Measure
					ON
					Second_Units_Of_Measure.Unit_Of_Measure_ID = Second_Fixed.Unit_Of_Measure_ID
					 INNER JOIN BSA_Foodservice_Items_Master 
					ON	BSA_Foodservice_Items_Master.Deleted = 0
					AND	(BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = First_Contract_Products.BSA_Foodservice_Items_Master_ID
						OR
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
						)
					AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL
					AND ISNULL(First_Contract_Products.BSA_Foodservice_Items_Master_ID, Second_Contract_Products.BSA_Foodservice_Items_Master_ID) = ISNULL(Second_Contract_Products.BSA_Foodservice_Items_Master_ID, First_Contract_Products.BSA_Foodservice_Items_Master_ID)
					AND (First_Contract_Products.Product_Type_ID = 1 OR Second_Contract_Products.Product_Type_ID = 1)
			WHERE	Contract_Main.Contract_Main_ID = #arguments.ProgramId2#
			
			UNION
			
			SELECT	DISTINCT BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
					First_Contract_Products.BSA_Foodservice_Items_Master_ID First_ID,
					Second_Contract_Products.BSA_Foodservice_Items_Master_ID Second_ID,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Item
					END As First_Item_ID,
					CASE 
					WHEN Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Item
					END As Second_Item_ID,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Description
					END As First_Name,
					CASE 
					WHEN Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Description
					END As Second_Name,
					First_Fixed.Fixed_Price_Value First_Price,
					Second_Fixed.Fixed_Price_Value Second_Price,
					First_Units_Of_Measure.Abbreviation First_UOM,
					Second_Units_Of_Measure.Abbreviation Second_UOM,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL THEN
						1
					ELSE
						0
					END As Deleted,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						1
					ELSE
						0
					END As Added,
					CASE
					WHEN 	First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL  
							AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL  
							AND (First_Program_Fixed.Program_Fixed_Component_Name_ID = Second_Program_Fixed.Program_Fixed_Component_Name_ID
								AND
								(First_Fixed.Fixed_Price_Value <> Second_Fixed.Fixed_Price_Value)
								OR 
								(First_Units_Of_Measure.Abbreviation <> Second_Units_Of_Measure.Abbreviation)
								) THEN
						1
					ELSE
						0
					END As Change,
					First_Program_Fixed.Program_Fixed_Component_Name_ID First_Component_ID,
					Second_Program_Fixed.Program_Fixed_Component_Name_ID Second_Component_ID,
					Program_Fixed_Component_Name.Program_Fixed_Component_Name
			FROM	Contract_Main
					<!------ Contract Products ----->
					INNER JOIN Contract_Products First_Contract_Products
					ON	First_Contract_Products.Deleted = 0
					AND	First_Contract_Products.Product_Type_ID = 1
					AND	First_Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
					AND 
					(
						<!------ Group ----->
						(First_Contract_Products.Product_Group_ID = CAST(First_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND First_Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(First_Contract_Products.Product_Group_ID, '') = '' AND First_Contract_Products.Is_Group = 0)
					) 
					LEFT JOIN Contract_Products Second_Contract_Products
					ON	Second_Contract_Products.Deleted = 0
					AND	Second_Contract_Products.Product_Type_ID = 1
					AND	Second_Contract_Products.Contract_Main_ID = #arguments.ProgramId2#
					AND	First_Contract_Products.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
					AND 
					(
						<!------ Group ----->
						(Second_Contract_Products.Product_Group_ID = CAST(Second_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Second_Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(Second_Contract_Products.Product_Group_ID, '') = '' AND Second_Contract_Products.Is_Group = 0)
					) 
					<!------ Fixed ----->
					INNER JOIN Program_Fixed_Price_Product_Data First_Fixed
					ON	First_Fixed.Deleted = 0
					AND	First_Fixed.Contract_Products_ID = First_Contract_Products.Contract_Products_ID
					LEFT JOIN Program_Fixed_Price_Product_Data Second_Fixed
					ON	Second_Fixed.Deleted = 0
					AND	Second_Fixed.Contract_Products_ID = Second_Contract_Products.Contract_Products_ID
					INNER JOIN Program_Fixed_Component First_Program_Fixed
					ON First_Program_Fixed.Program_Fixed_Component_ID = First_Fixed.Program_Fixed_Component_ID
					AND First_Program_Fixed.deleted = 0
					LEFT JOIN Program_Fixed_Component Second_Program_Fixed
					ON Second_Program_Fixed.Program_Fixed_Component_ID = Second_Fixed.Program_Fixed_Component_ID
					AND Second_Program_Fixed.deleted = 0
					LEFT JOIN Program_Fixed_Component_Name 
					ON First_Program_Fixed.Program_Fixed_Component_Name_ID =  Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID							
					<!------ UOM ----->
					INNER JOIN Units_Of_Measure First_Units_Of_Measure
					ON
					First_Units_Of_Measure.Unit_Of_Measure_ID = First_Fixed.Unit_Of_Measure_ID
					LEFT JOIN Units_Of_Measure Second_Units_Of_Measure
					ON
					Second_Units_Of_Measure.Unit_Of_Measure_ID = Second_Fixed.Unit_Of_Measure_ID
					 INNER JOIN BSA_Foodservice_Items_Master
					ON	BSA_Foodservice_Items_Master.Deleted = 0
					AND	(BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = First_Contract_Products.BSA_Foodservice_Items_Master_ID
						OR
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
						)
					AND ISNULL(First_Contract_Products.BSA_Foodservice_Items_Master_ID, Second_Contract_Products.BSA_Foodservice_Items_Master_ID) = ISNULL(Second_Contract_Products.BSA_Foodservice_Items_Master_ID, First_Contract_Products.BSA_Foodservice_Items_Master_ID)
					AND (First_Contract_Products.Product_Type_ID = 1 OR Second_Contract_Products.Product_Type_ID = 1)
			WHERE	Contract_Main.Contract_Main_ID = #arguments.ProgramId1#
			ORDER BY Program_Fixed_Component_Name,Change, Deleted, Added 
		</cfquery>
		
		<cfreturn qGetFixed />	
	</cffunction>

	<cffunction name="getAllLumpSumNames" output="false" returntype="query">
		<cfargument name="ProgramId1" type="numeric" required="true">
		<cfargument name="ProgramId2" type="numeric" required="true">
		
		<cfquery name="qGetAllLumpSumNames" datasource="#application.datasource#">
			SELECT	First_Program_Lump_Sums.Program_Lump_Sum_Name_ID
			FROM	Contract_Main
					INNER JOIN Program_Lump_Sums First_Program_Lump_Sums
					ON
					First_Program_Lump_Sums.Deleted = 0
					AND First_Program_Lump_Sums.Program_ID = Contract_Main.Contract_Main_ID					
			WHERE	Contract_Main.Contract_Main_ID = #arguments.ProgramId1#
			UNION
			SELECT	First_Program_Lump_Sums.Program_Lump_Sum_Name_ID
			FROM	Contract_Main
					INNER JOIN Program_Lump_Sums First_Program_Lump_Sums
					ON
					First_Program_Lump_Sums.Deleted = 0
					AND First_Program_Lump_Sums.Program_ID = Contract_Main.Contract_Main_ID					
			WHERE	Contract_Main.Contract_Main_ID = #arguments.ProgramId2#
		</cfquery>
		
		<cfreturn qGetAllLumpSumNames>		
	</cffunction>
	
	<cffunction name="getThisLumpSum" output="false" returntype="query">
		<cfargument name="programId" type="numeric" required="true">
		<cfargument name="lumpSumNameId" type="string" required="true">
		
		<cfquery name="qGetAllLumpSums" datasource="#application.datasource#">
			SELECT	Program_Lump_Sum_Name.Program_Lump_Sum_Name, First_Program_Lump_Sums.Lump_Sum_Amount,
					First_Program_Lump_Sums.Lump_Sum_Volume, First_Program_Lump_Sums.Program_Lump_Sum_ID,
					First_Program_Lump_Sums.Program_Lump_Sum_Name_ID, First_Program_Lump_Sums.Program_Lumps_Sum_Ext_ID
					,First_Program_Lump_Sums.Claim_Mechanics
			FROM	Program_Lump_Sums First_Program_Lump_Sums
					INNER JOIN Program_Lump_Sum_Name
					ON
					Program_Lump_Sum_Name.Deleted = 0
					AND Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = First_Program_Lump_Sums.Program_Lump_Sum_Name_ID
			WHERE	First_Program_Lump_Sums.Deleted = 0
					AND First_Program_Lump_Sums.Program_Lump_Sum_Name_ID = '#arguments.lumpSumNameId#'
					AND First_Program_Lump_Sums.Program_ID = #arguments.programId#
			ORDER BY Program_Lump_Sum_Name.Program_Lump_Sum_Name, First_Program_Lump_Sums.Lump_Sum_Amount
		</cfquery>
		
		<cfreturn qGetAllLumpSums>		
	</cffunction>
	
	<cffunction name="getLumpProducts" output="false" returntype="query">
		<cfargument name="lumpsumId" type="string" required="true">
		
		<cfquery name="qGetLumpProducts" datasource="#application.datasource#">
		<cfif arguments.lumpsumId neq "">
			SELECT	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID As MaterialID, BSA_Foodservice_Items_Master.Item, BSA_Foodservice_Items_Master.Description,
				    CASE WHEN
					Contract_Products.Is_Group = 1 THEN
					'Groups'
					ELSE
					'Items' END As Is_Group
			FROM	Program_Lump_Sum_Product_Data
					INNER JOIN Contract_Products
					ON
					Contract_Products.Deleted = 0
					AND Contract_Products.Contract_Products_ID = Program_Lump_Sum_Product_Data.Contract_Products_ID
					AND 
					(
						<!------ Group ----->
						(Contract_Products.Product_Group_ID = CAST(Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(Contract_Products.Product_Group_ID, '') = '' AND Contract_Products.Is_Group = 0)
					) 
					INNER JOIN BSA_Foodservice_Items_Master
					ON
					BSA_Foodservice_Items_Master.Deleted = 0
					AND BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
			WHERE
					Program_Lump_Sum_Product_Data.Deleted = 0
					AND Program_Lump_Sum_Product_Data.Program_Lump_Sum_ID = '#arguments.lumpsumId#'
				<!--- <cfif arguments.Is_Group neq ""> 
					AND Contract_Products.Is_Group = #arguments.Is_Group#
			 </cfif> --->
			ORDER BY Contract_Products.Is_Group, BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
			</cfif>			
		</cfquery>
		
		<cfreturn qGetLumpProducts>
	</cffunction>

	<cffunction name="getPricingLevels" output="false" returntype="query">	
		<cfargument name="ProgramId1" type="numeric" required="true">
		<cfargument name="ProgramId2" type="numeric" required="true">
		
		<cfquery name="qGetPricingLevels" datasource="#application.datasource#">
			SELECT	DISTINCT Pricing_Level.Pricing_Level_ID, Pricing_Level.Pricing_Level_Label, Contract_Products.Is_Group
			FROM	Contract_Products					
					INNER JOIN Pricing_Level
					ON
					Pricing_Level.Deleted = 0
					AND Pricing_Level.Pricing_Level_ID = Contract_Products.Pricing_Level_ID
			WHERE	Contract_Products.Deleted = 0
					AND Contract_Products.Contract_Main_ID = #arguments.ProgramId1#
			
			UNION
			
			SELECT	DISTINCT Pricing_Level.Pricing_Level_ID, Pricing_Level.Pricing_Level_Label, Contract_Products.Is_Group
			FROM	Contract_Products					
					INNER JOIN Pricing_Level
					ON
					Pricing_Level.Deleted = 0
					AND Pricing_Level.Pricing_Level_ID = Contract_Products.Pricing_Level_ID
			WHERE	Contract_Products.Deleted = 0
					AND Contract_Products.Contract_Main_ID = #arguments.ProgramId2#
		</cfquery>
		
		<cfreturn qGetPricingLevels>		
	</cffunction>
	
	
	<cffunction name="getRebateRemoved" output="false" returntype="query">
		<cfargument name="ProgramId1" type="numeric" required="true">
		<cfargument name="ProgramId2" type="numeric" required="true">
		<cfargument name="showOnlyChange" type="numeric" required="true">
		<cfargument name="pricingLevelId" type="numeric" required="true">
		
		<cfquery name="qGetRebate" datasource="#application.datasource#">
			SELECT	DISTINCT BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
					First_Rebate.Program_Rebates_Product_Data_ID First_Rebate_ID,
					Second_Rebate.Program_Rebates_Product_Data_ID Second_Rebate_ID,
					First_Contract_Products.BSA_Foodservice_Items_Master_ID First_ID,
					Second_Contract_Products.BSA_Foodservice_Items_Master_ID Second_ID,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Item
					END As First_Item_ID,
					CASE 
					WHEN Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Item
					END As Second_Item_ID,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Description
					END As First_Name,
					CASE 
					WHEN Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Description
					END As Second_Name,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL THEN
						1
					ELSE
						0
					END As Deleted,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						1
					ELSE
						0
					END As Added,
					0 As Change
			FROM	Contract_Main
					<!------ Contract Products ----->
					INNER JOIN Contract_Products First_Contract_Products
					ON	First_Contract_Products.Deleted = 0
					AND	First_Contract_Products.Product_Type_ID = 2
					AND	First_Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
					AND First_Contract_Products.Pricing_Level_ID = #arguments.pricingLevelId#
					AND 
					(
						<!------ Group ----->
						(First_Contract_Products.Product_Group_ID = CAST(First_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND First_Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(First_Contract_Products.Product_Group_ID, '') = '' AND First_Contract_Products.Is_Group = 0)
					) 
					LEFT JOIN Contract_Products Second_Contract_Products
					ON	Second_Contract_Products.Deleted = 0
					AND	Second_Contract_Products.Product_Type_ID = 2
					AND	Second_Contract_Products.Contract_Main_ID = #arguments.ProgramId2#
					AND Second_Contract_Products.Pricing_Level_ID = #arguments.pricingLevelId#
					AND	First_Contract_Products.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
					AND 
					(
						<!------ Group ----->
						(Second_Contract_Products.Product_Group_ID = CAST(Second_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Second_Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(Second_Contract_Products.Product_Group_ID, '') = '' AND Second_Contract_Products.Is_Group = 0)
					) 
					<!------ Rebate ----->
					INNER JOIN Program_Rebates_Product_Data First_Rebate
					ON	First_Rebate.Deleted = 0
					AND	First_Rebate.Contract_Products_ID = First_Contract_Products.Contract_Products_ID
					LEFT JOIN Program_Rebates_Product_Data Second_Rebate
					ON	Second_Rebate.Deleted = 0
					AND	Second_Rebate.Contract_Products_ID = Second_Contract_Products.Contract_Products_ID										
					INNER JOIN BSA_Foodservice_Items_Master
					ON	BSA_Foodservice_Items_Master.Deleted = 0
					AND	(BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = First_Contract_Products.BSA_Foodservice_Items_Master_ID
						OR
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
						)
					<cfif arguments.showOnlyChange>
					AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL
					</cfif>
					AND ISNULL(First_Contract_Products.BSA_Foodservice_Items_Master_ID, Second_Contract_Products.BSA_Foodservice_Items_Master_ID) = ISNULL(Second_Contract_Products.BSA_Foodservice_Items_Master_ID, First_Contract_Products.BSA_Foodservice_Items_Master_ID)									
					AND (First_Contract_Products.Product_Type_ID = 2 OR Second_Contract_Products.Product_Type_ID = 2)
			WHERE	Contract_Main.Contract_Main_ID = #arguments.ProgramId1#
			ORDER BY Added, Deleted
		</cfquery>
		
		<cfreturn qGetRebate />	
	</cffunction>
	
	<cffunction name="getRebateRates" output="false" returntype="query">
		<cfargument name="rebateProductId" type="string" required="true">
		
		<cfquery name="qGetRebateRates" datasource="#application.datasource#">
			SELECT	Program_Rebates_Component_Data.Rate,
					Units_Of_Measure.Abbreviation UOM,
					Units_Of_Measure.Unit_Of_Measure_ID,
					Program_Rebates_Component_Name.Program_Rebates_Component_Name,
					Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID,
					Program_Rebates_Component.Claim_Mechanics
			FROM	Program_Rebates_Component_Data
					INNER JOIN Units_Of_Measure
					ON
					Units_Of_Measure.Unit_Of_Measure_ID = Program_Rebates_Component_Data.Unit_Of_Measure_ID
					INNER JOIN Program_Rebates_Component
					ON
					Program_Rebates_Component.Program_Rebates_Component_ID = Program_Rebates_Component_Data.Program_Rebates_Component_ID
					INNER JOIN Program_Rebates_Component_Name
					ON 
					Program_Rebates_Component.Program_Rebates_Component_Name_ID = Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID
			WHERE	Program_Rebates_Component_Data.Deleted = 0
					AND Program_Rebates_Component_Data.Program_Rebates_Product_Data_ID = '#arguments.rebateProductId#'
		</cfquery>
		
		<cfreturn qGetRebateRates>		
	</cffunction>
	
	<cffunction name="getAllGrowthProducts" output="false" returntype="query">	
		<cfargument name="ProgramId1" type="numeric" required="true">
		<cfargument name="ProgramId2" type="numeric" required="true">
		<cfargument name="showOnlyChange" type="numeric" required="true">
		
		<cfquery name="qGetAllGrowthProducts" datasource="#application.datasource#">
			SELECT	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, 
					First_Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID First_ID,
					First_Contract_Products.Contract_Main_ID First_Program_ID, Second_Contract_Products.Contract_Main_ID Second_Program_ID,
					Second_Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID Second_ID,
					Program_Growth_Components.Component_Name,
					CASE
					WHEN BSA_Foodservice_Items_Master.BSA_Product_Group_ID IS NULL THEN
					'Groups'
					ELSE
					'Items'
					END As Is_Group,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Item
					END As First_Item_ID,
					CASE 
					WHEN Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Item
					END As Second_Item_ID,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Description
					END As First_Name,
					CASE 
					WHEN Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Description
					END As Second_Name,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL THEN
						1
					ELSE
						0
					END As Deleted,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						1
					ELSE
						0
					END As Added
			FROM	Contract_Main
					INNER JOIN Contract_Products First_Contract_Products
					ON	First_Contract_Products.Deleted = 0
					AND	First_Contract_Products.Product_Type_ID = 4
					AND First_Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
					AND 
					(
						<!------ Group ----->
						(First_Contract_Products.Product_Group_ID = CAST(First_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND First_Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(First_Contract_Products.Product_Group_ID, '') = '' AND First_Contract_Products.Is_Group = 0)
					) 
					<!------ First Product ----->
					INNER JOIN 	Program_Growth_Component_Product_Data First_Program_Growth_Component_Product_Data
					ON	First_Program_Growth_Component_Product_Data.Deleted = 0
					AND	First_Program_Growth_Component_Product_Data.Contract_Products_ID = First_Contract_Products.Contract_Products_ID
					<!------ Second Product ----->
					LEFT JOIN Contract_Products Second_Contract_Products
					ON	Second_Contract_Products.Deleted = 0
					AND	Second_Contract_Products.Product_Type_ID = 4
					AND	Second_Contract_Products.Contract_Main_ID = #arguments.ProgramId2#
					AND	First_Contract_Products.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
					AND 
					(
						<!------ Group ----->
						(Second_Contract_Products.Product_Group_ID = CAST(Second_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Second_Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(Second_Contract_Products.Product_Group_ID, '') = '' AND Second_Contract_Products.Is_Group = 0)
					) 
					LEFT JOIN 	Program_Growth_Component_Product_Data Second_Program_Growth_Component_Product_Data
					ON	Second_Program_Growth_Component_Product_Data.Deleted = 0
					AND	Second_Program_Growth_Component_Product_Data.Contract_Products_ID = Second_Contract_Products.Contract_Products_ID
					<!------ Product Master ----->
					INNER JOIN 	BSA_Foodservice_Items_Master
					ON	BSA_Foodservice_Items_Master.Deleted = 0
					AND	(BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = First_Contract_Products.BSA_Foodservice_Items_Master_ID
						OR
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
						)					
					AND ISNULL(First_Contract_Products.BSA_Foodservice_Items_Master_ID, Second_Contract_Products.BSA_Foodservice_Items_Master_ID) = ISNULL(Second_Contract_Products.BSA_Foodservice_Items_Master_ID, First_Contract_Products.BSA_Foodservice_Items_Master_ID)					
					<!--- ADD --->			INNER JOIN Program_Growth_Components
						ON Program_Growth_Components.deleted = 0
						AND First_Program_Growth_Component_Product_Data.Program_Growth_Component_ID = Program_Growth_Components.Program_Growth_Component_ID
					<cfif arguments.showOnlyChange>
					AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL
					</cfif>
			WHERE	Contract_Main.Contract_Main_ID = #arguments.ProgramId1#
			AND 	BSA_Foodservice_Items_Master.BSA_Product_Group_ID IS NULL
			
			UNION
			
			SELECT	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, 
					First_Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID First_ID,
					First_Contract_Products.Contract_Main_ID First_Program_ID, Second_Contract_Products.Contract_Main_ID Second_Program_ID,
					Second_Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID Second_ID,
					Program_Growth_Components.Component_Name,
					CASE
					WHEN BSA_Foodservice_Items_Master.BSA_Product_Group_ID IS NULL THEN
					'Groups'
					ELSE
					'Items'
					END As Is_Group,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Item
					END As First_Item_ID,
					CASE 
					WHEN Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Item
					END As Second_Item_ID,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Description
					END As First_Name,
					CASE 
					WHEN Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Description
					END As Second_Name,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL THEN
						1
					ELSE
						0
					END As Deleted,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						1
					ELSE
						0
					END As Added
			FROM	Contract_Main
					INNER JOIN Contract_Products First_Contract_Products
					ON	First_Contract_Products.Deleted = 0
					AND	First_Contract_Products.Product_Type_ID = 4
					AND First_Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
					AND 
					(
						<!------ Group ----->
						(First_Contract_Products.Product_Group_ID = CAST(First_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND First_Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(First_Contract_Products.Product_Group_ID, '') = '' AND First_Contract_Products.Is_Group = 0)
					) 
					<!------ First Product ----->
					INNER JOIN 	Program_Growth_Component_Product_Data First_Program_Growth_Component_Product_Data
					ON	First_Program_Growth_Component_Product_Data.Deleted = 0
					AND	First_Program_Growth_Component_Product_Data.Contract_Products_ID = First_Contract_Products.Contract_Products_ID
					<!------ Second Product ----->
					LEFT JOIN Contract_Products Second_Contract_Products
					ON	Second_Contract_Products.Deleted = 0
					AND	Second_Contract_Products.Product_Type_ID = 4
					AND	Second_Contract_Products.Contract_Main_ID = #arguments.ProgramId2#
					AND	First_Contract_Products.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
					AND 
					(
						<!------ Group ----->
						(Second_Contract_Products.Product_Group_ID = CAST(Second_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Second_Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(Second_Contract_Products.Product_Group_ID, '') = '' AND Second_Contract_Products.Is_Group = 0)
					) 
					LEFT JOIN 	Program_Growth_Component_Product_Data Second_Program_Growth_Component_Product_Data
					ON	Second_Program_Growth_Component_Product_Data.Deleted = 0
					AND	Second_Program_Growth_Component_Product_Data.Contract_Products_ID = Second_Contract_Products.Contract_Products_ID
					<!------ Product Master ----->
					INNER JOIN 	BSA_Foodservice_Items_Master
					ON	BSA_Foodservice_Items_Master.Deleted = 0
					AND	(BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = First_Contract_Products.BSA_Foodservice_Items_Master_ID
						OR
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
						)					
					AND ISNULL(First_Contract_Products.BSA_Foodservice_Items_Master_ID, Second_Contract_Products.BSA_Foodservice_Items_Master_ID) = ISNULL(Second_Contract_Products.BSA_Foodservice_Items_Master_ID, First_Contract_Products.BSA_Foodservice_Items_Master_ID)					
					<!--- ADD --->			INNER JOIN Program_Growth_Components
						ON Program_Growth_Components.deleted = 0
						AND First_Program_Growth_Component_Product_Data.Program_Growth_Component_ID = Program_Growth_Components.Program_Growth_Component_ID
					<cfif arguments.showOnlyChange>
					AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL
					</cfif>
			WHERE	Contract_Main.Contract_Main_ID = #arguments.ProgramId1#
			AND	BSA_Foodservice_Items_Master.BSA_Product_Group_ID IS NOT NULL
			ORDER BY Is_Group, Program_Growth_Components.Component_Name, Deleted, Added
			<!---,BSA_Foodservice_Items_Master.Description --->
		</cfquery>
		
		<cfreturn qGetAllGrowthProducts>		
	</cffunction>
	
	<cffunction name="getGrowthProductRates" output="false" returntype="query">
		<cfargument name="productId" type="string" required="true">
		<cfargument name="ProgramId" type="string" required="true">
				
		<cfif isNumeric(arguments.ProgramId)>
			<cfquery name="qGetAllGrowthProducts" datasource="#application.datasource#">
				SELECT	First_Program_Growth_Component_Tiers.Tier_Number, First_Program_Growth_Component_Tiers.Range_Start, First_Program_Growth_Component_Tiers.Range_End,
						First_Program_Growth_Component_Product_Tier_Data.Rate First_Rate, First_Units_Of_measure.Abbreviation First_UOM
				FROM	Contract_Products First_Contract_Products
						<!------ First Product ----->
						INNER JOIN 	Program_Growth_Component_Product_Data First_Program_Growth_Component_Product_Data
						ON	First_Program_Growth_Component_Product_Data.Deleted = 0
						AND	First_Program_Growth_Component_Product_Data.Contract_Products_ID = First_Contract_Products.Contract_Products_ID
						INNER JOIN	Program_Growth_Components First_Program_Growth_Components
						ON	First_Program_Growth_Components.Deleted = 0
						AND	First_Program_Growth_Components.Program_Growth_Component_ID = First_Program_Growth_Component_Product_Data.Program_Growth_Component_ID
						INNER JOIN	Program_Growth_Component_Tiers First_Program_Growth_Component_Tiers
						ON	First_Program_Growth_Component_Tiers.Deleted = 0
						AND	First_Program_Growth_Components.Program_Growth_Component_ID = First_Program_Growth_Component_Tiers.Program_Growth_Component_ID
						INNER JOIN Program_Growth_Component_Product_Tier_Data First_Program_Growth_Component_Product_Tier_Data
						ON	First_Program_Growth_Component_Product_Tier_Data.Deleted = 0
						AND	First_Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Tier_ID = First_Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID
						AND	First_Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Product_Data_ID = First_Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID
						INNER JOIN Units_Of_measure First_Units_Of_measure
						ON	First_Units_Of_measure.Unit_Of_measure_ID = First_Program_Growth_Component_Product_Tier_Data.Unit_Of_measure_ID
				WHERE	First_Contract_Products.Deleted = 0
						AND First_Contract_Products.Contract_Main_ID = #arguments.ProgramId#
						AND First_Contract_Products.BSA_Foodservice_Items_Master_ID = '#arguments.productId#'
						AND 
						(
							<!------ Group ----->
							(First_Contract_Products.Product_Group_ID = CAST(First_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND First_Contract_Products.Is_Group = 1)
							OR
							<!------ Product ----->
							(ISNULL(First_Contract_Products.Product_Group_ID, '') = '' AND First_Contract_Products.Is_Group = 0)
						) 
				ORDER BY First_Program_Growth_Component_Tiers.Tier_Number
			</cfquery>
		<cfelse>			
			<cfset qGetAllGrowthProducts = QueryNew("Tier_Number, Range_Start, Range_End, First_Rate, First_UOM")>
		</cfif>
		
		<cfreturn qGetAllGrowthProducts>		
	</cffunction>
	
	<cffunction name="getOffInvoiceRemoved" output="false" returntype="query">
	
		<cfargument name="ProgramId1" type="numeric" required="true">
		<cfargument name="ProgramId2" type="numeric" required="true">
		<!---
		<cfargument name="showOnlyChange" type="numeric" required="true">
		--->
		<cfquery name="qGetOffInvoice" datasource="#application.datasource#">
			SELECT	DISTINCT BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
					First_Contract_Products.BSA_Foodservice_Items_Master_ID First_ID,
					Second_Contract_Products.BSA_Foodservice_Items_Master_ID Second_ID,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Description
					END As First_Name,
					CASE 
					WHEN Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Description
					END As Second_Name,
					First_OffInvoice.Discount_Amount * (CASE WHEN First_OffInvoice.Plus_Minus = 1 THEN 1 ELSE -1 END) First_Rate,
					Second_OffInvoice.Discount_Amount * (CASE WHEN Second_OffInvoice.Plus_Minus = 1 THEN 1 ELSE -1 END) Second_Rate,
					First_Units_Of_Measure.Abbreviation First_UOM,
					Second_Units_Of_Measure.Abbreviation Second_UOM,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL THEN
						1
					ELSE
						0
					END As Deleted,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						1
					ELSE
						0
					END As Added,
					CASE
					WHEN 	First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL  
							AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL  
							AND (
								First_OffInvoice.Discount_Amount <> Second_OffInvoice.Discount_Amount 
								OR
								First_OffInvoice.Plus_Minus <> Second_OffInvoice.Plus_Minus 
								OR 
								First_Units_Of_Measure.Abbreviation <> Second_Units_Of_Measure.Abbreviation
								) THEN
						1
					ELSE
						0
					END As Change,
					CASE WHEN
					First_Contract_Products.Is_Group = 1 THEN
					'Groups'
					ELSE
					'Items' END As Is_Group,
					'1' As SerialNum
			FROM	Contract_Main
					<!------ Contract Products ----->
					INNER JOIN Contract_Products First_Contract_Products
					ON	First_Contract_Products.Deleted = 0
					AND	First_Contract_Products.Product_Type_ID = 8
					AND	First_Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
					AND 
					(
						<!------ Group ----->
						(First_Contract_Products.Product_Group_ID = CAST(First_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND First_Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(First_Contract_Products.Product_Group_ID, '') = '' AND First_Contract_Products.Is_Group = 0)
					) 
					LEFT JOIN Contract_Products Second_Contract_Products
					ON	Second_Contract_Products.Deleted = 0
					AND	Second_Contract_Products.Product_Type_ID = 8
					AND	Second_Contract_Products.Contract_Main_ID = #arguments.ProgramId2#
					AND	First_Contract_Products.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
					AND 
					(
						<!------ Group ----->
						(Second_Contract_Products.Product_Group_ID = CAST(Second_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Second_Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(Second_Contract_Products.Product_Group_ID, '') = '' AND Second_Contract_Products.Is_Group = 0)
					) 
					<!------ Off Invoice ----->
					INNER JOIN Program_OffInvoice_Product_Data First_OffInvoice
					ON	First_OffInvoice.Deleted = 0
					AND	First_OffInvoice.Contract_Products_ID = First_Contract_Products.Contract_Products_ID
					LEFT JOIN Program_OffInvoice_Product_Data Second_OffInvoice
					ON	Second_OffInvoice.Deleted = 0
					AND	Second_OffInvoice.Contract_Products_ID = Second_Contract_Products.Contract_Products_ID					
					<!------ UOM ----->
					INNER JOIN Units_Of_Measure First_Units_Of_Measure
					ON
					First_Units_Of_Measure.Unit_Of_Measure_ID = First_OffInvoice.UOM
					LEFT JOIN Units_Of_Measure Second_Units_Of_Measure
					ON
					Second_Units_Of_Measure.Unit_Of_Measure_ID = Second_OffInvoice.UOM
					INNER JOIN BSA_Foodservice_Items_Master
					ON	BSA_Foodservice_Items_Master.Deleted = 0
					AND	(BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = First_Contract_Products.BSA_Foodservice_Items_Master_ID
						OR
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
						)
					AND ISNULL(First_Contract_Products.BSA_Foodservice_Items_Master_ID, Second_Contract_Products.BSA_Foodservice_Items_Master_ID) = ISNULL(Second_Contract_Products.BSA_Foodservice_Items_Master_ID, First_Contract_Products.BSA_Foodservice_Items_Master_ID)
					AND (First_Contract_Products.Product_Type_ID = 8 OR Second_Contract_Products.Product_Type_ID = 8)
			WHERE	Contract_Main.Contract_Main_ID = #arguments.ProgramId1#
			
			UNION
			
			SELECT	DISTINCT BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
					First_Contract_Products.BSA_Foodservice_Items_Master_ID First_ID,
					Second_Contract_Products.BSA_Foodservice_Items_Master_ID Second_ID,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Description
					END As First_Name,
					CASE 
					WHEN Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Description
					END As Second_Name,
					First_OffInvoice.Discount_Amount * (CASE WHEN First_OffInvoice.Plus_Minus = 1 THEN 1 ELSE -1 END) First_Rate,
					Second_OffInvoice.Discount_Amount * (CASE WHEN Second_OffInvoice.Plus_Minus = 1 THEN 1 ELSE -1 END) Second_Rate,
					First_Units_Of_Measure.Abbreviation First_UOM,
					Second_Units_Of_Measure.Abbreviation Second_UOM,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL THEN
						1
					ELSE
						0
					END As Deleted,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						1
					ELSE
						0
					END As Added,
					CASE
					WHEN 	First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL  
							AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL  
							AND (
								First_OffInvoice.Discount_Amount <> Second_OffInvoice.Discount_Amount 
								OR
								First_OffInvoice.Plus_Minus <> Second_OffInvoice.Plus_Minus 
								OR 
								First_Units_Of_Measure.Abbreviation <> Second_Units_Of_Measure.Abbreviation
								) THEN
						1
					ELSE
						0
					END As Change,
					CASE WHEN
					First_Contract_Products.Is_Group = 1 THEN
					'Groups'
					ELSE
					'Items' END As Is_Group,
					'2' As SerialNum
			FROM	Contract_Main
					<!------ Contract Products ----->
					INNER JOIN Contract_Products First_Contract_Products
					ON	First_Contract_Products.Deleted = 0
					AND	First_Contract_Products.Product_Type_ID = 8
					AND	First_Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
					AND 
					(
						<!------ Group ----->
						(First_Contract_Products.Product_Group_ID = CAST(First_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND First_Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(First_Contract_Products.Product_Group_ID, '') = '' AND First_Contract_Products.Is_Group = 0)
					) 
					LEFT JOIN Contract_Products Second_Contract_Products
					ON	Second_Contract_Products.Deleted = 0
					AND	Second_Contract_Products.Product_Type_ID = 8
					AND	Second_Contract_Products.Contract_Main_ID = #arguments.ProgramId1#
					AND	First_Contract_Products.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
					AND 
					(
						<!------ Group ----->
						(Second_Contract_Products.Product_Group_ID = CAST(Second_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Second_Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(Second_Contract_Products.Product_Group_ID, '') = '' AND Second_Contract_Products.Is_Group = 0)
					) 
					<!------ Off Invoice ----->
					INNER JOIN Program_OffInvoice_Product_Data First_OffInvoice
					ON	First_OffInvoice.Deleted = 0
					AND	First_OffInvoice.Contract_Products_ID = First_Contract_Products.Contract_Products_ID
					LEFT JOIN Program_OffInvoice_Product_Data Second_OffInvoice
					ON	Second_OffInvoice.Deleted = 0
					AND	Second_OffInvoice.Contract_Products_ID = Second_Contract_Products.Contract_Products_ID					
					<!------ UOM ----->
					INNER JOIN Units_Of_Measure First_Units_Of_Measure
					ON
					First_Units_Of_Measure.Unit_Of_Measure_ID = First_OffInvoice.UOM
					LEFT JOIN Units_Of_Measure Second_Units_Of_Measure
					ON
					Second_Units_Of_Measure.Unit_Of_Measure_ID = Second_OffInvoice.UOM
					INNER JOIN BSA_Foodservice_Items_Master
					ON	BSA_Foodservice_Items_Master.Deleted = 0
					AND	(BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = First_Contract_Products.BSA_Foodservice_Items_Master_ID
						OR
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
						)
					AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL
					AND ISNULL(First_Contract_Products.BSA_Foodservice_Items_Master_ID, Second_Contract_Products.BSA_Foodservice_Items_Master_ID) = ISNULL(Second_Contract_Products.BSA_Foodservice_Items_Master_ID, First_Contract_Products.BSA_Foodservice_Items_Master_ID)
					AND (First_Contract_Products.Product_Type_ID = 8 OR Second_Contract_Products.Product_Type_ID = 8)
			WHERE	Contract_Main.Contract_Main_ID = #arguments.ProgramId2#
			ORDER BY Is_Group, SerialNum, Change, Deleted, Added
		</cfquery>
		
		<cfreturn qGetOffInvoice />
	
	</cffunction>


	<cffunction name="getBidRequestRemoved" output="false" returntype="query">
	
		<cfargument name="ProgramId1" type="numeric" required="true">
		<cfargument name="ProgramId2" type="numeric" required="true">
		<!---
		<cfargument name="showOnlyChange" type="numeric" required="true">
		--->
		<cfquery name="qGetBidRequest" datasource="#application.datasource#">
			SELECT	DISTINCT BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
					First_Contract_Products.BSA_Foodservice_Items_Master_ID First_ID,
					Second_Contract_Products.BSA_Foodservice_Items_Master_ID Second_ID,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Description
					END As First_Name,
					CASE 
					WHEN Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Description
					END As Second_Name,
					First_BidRequest.Allowance First_Rate,
					Second_BidRequest.Allowance Second_Rate,
					First_Units_Of_Measure.Abbreviation First_UOM,
					Second_Units_Of_Measure.Abbreviation Second_UOM,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL THEN
						1
					ELSE
						0
					END As Deleted,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						1
					ELSE
						0
					END As Added,
					CASE
					WHEN 	First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL  
							AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL  
							AND (
								First_BidRequest.Allowance <> Second_BidRequest.Allowance
								OR 
								First_Units_Of_Measure.Abbreviation <> Second_Units_Of_Measure.Abbreviation
								) THEN
						1
					ELSE
						0
					END As Change,
					CASE WHEN
					First_Contract_Products.Is_Group = 1 THEN
					'Groups'
					ELSE
					'Items' END As Is_Group,
					'1' As SerialNum
			FROM	Contract_Main
					<!------ Contract Products ----->
					INNER JOIN Contract_Products First_Contract_Products
					ON	First_Contract_Products.Deleted = 0
					AND	First_Contract_Products.Product_Type_ID = 10
					AND	First_Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
					AND 
					(
						<!------ Group ----->
						(First_Contract_Products.Product_Group_ID = CAST(First_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND First_Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(First_Contract_Products.Product_Group_ID, '') = '' AND First_Contract_Products.Is_Group = 0)
					) 
					LEFT JOIN Contract_Products Second_Contract_Products
					ON	Second_Contract_Products.Deleted = 0
					AND	Second_Contract_Products.Product_Type_ID = 10
					AND	Second_Contract_Products.Contract_Main_ID = #arguments.ProgramId2#
					AND	First_Contract_Products.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
					AND 
					(
						<!------ Group ----->
						(Second_Contract_Products.Product_Group_ID = CAST(Second_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Second_Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(Second_Contract_Products.Product_Group_ID, '') = '' AND Second_Contract_Products.Is_Group = 0)
					) 
					<!------ Bid Request Fixed Pricing ----->
					INNER JOIN Program_Bid_Request_Product First_BidRequest
					ON	First_BidRequest.Deleted = 0
					AND	First_BidRequest.Contract_Products_ID = First_Contract_Products.Contract_Products_ID
					LEFT JOIN Program_Bid_Request_Product Second_BidRequest
					ON	Second_BidRequest.Deleted = 0
					AND	Second_BidRequest.Contract_Products_ID = Second_Contract_Products.Contract_Products_ID					
					<!------ UOM ----->
					INNER JOIN Units_Of_Measure First_Units_Of_Measure
					ON
					First_Units_Of_Measure.Unit_Of_Measure_ID = First_BidRequest.UOM
					LEFT JOIN Units_Of_Measure Second_Units_Of_Measure
					ON
					Second_Units_Of_Measure.Unit_Of_Measure_ID = Second_BidRequest.UOM
					INNER JOIN BSA_Foodservice_Items_Master
					ON	BSA_Foodservice_Items_Master.Deleted = 0
					AND	(BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = First_Contract_Products.BSA_Foodservice_Items_Master_ID
						OR
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
						)
					AND ISNULL(First_Contract_Products.BSA_Foodservice_Items_Master_ID, Second_Contract_Products.BSA_Foodservice_Items_Master_ID) = ISNULL(Second_Contract_Products.BSA_Foodservice_Items_Master_ID, First_Contract_Products.BSA_Foodservice_Items_Master_ID)
					AND (First_Contract_Products.Product_Type_ID = 10 OR Second_Contract_Products.Product_Type_ID = 10)
			WHERE	Contract_Main.Contract_Main_ID = #arguments.ProgramId1#
			
			UNION
			
			SELECT	DISTINCT BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
					First_Contract_Products.BSA_Foodservice_Items_Master_ID First_ID,
					Second_Contract_Products.BSA_Foodservice_Items_Master_ID Second_ID,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Description
					END As First_Name,
					CASE 
					WHEN Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Description
					END As Second_Name,
					First_BidRequest.Allowance First_Rate,
					Second_BidRequest.Allowance Second_Rate,
					First_Units_Of_Measure.Abbreviation First_UOM,
					Second_Units_Of_Measure.Abbreviation Second_UOM,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL THEN
						1
					ELSE
						0
					END As Deleted,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						1
					ELSE
						0
					END As Added,
					CASE
					WHEN 	First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL  
							AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL  
							AND (
								First_BidRequest.Allowance <> Second_BidRequest.Allowance 
								OR 
								First_Units_Of_Measure.Abbreviation <> Second_Units_Of_Measure.Abbreviation
								) THEN
						1
					ELSE
						0
					END As Change,
					CASE WHEN
					First_Contract_Products.Is_Group = 1 THEN
					'Groups'
					ELSE
					'Items' END As Is_Group,
					'2' As SerialNum
			FROM	Contract_Main
					<!------ Contract Products ----->
					INNER JOIN Contract_Products First_Contract_Products
					ON	First_Contract_Products.Deleted = 0
					AND	First_Contract_Products.Product_Type_ID = 10
					AND	First_Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
					AND 
					(
						<!------ Group ----->
						(First_Contract_Products.Product_Group_ID = CAST(First_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND First_Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(First_Contract_Products.Product_Group_ID, '') = '' AND First_Contract_Products.Is_Group = 0)
					) 
					LEFT JOIN Contract_Products Second_Contract_Products
					ON	Second_Contract_Products.Deleted = 0
					AND	Second_Contract_Products.Product_Type_ID = 10
					AND	Second_Contract_Products.Contract_Main_ID = #arguments.ProgramId1#
					AND	First_Contract_Products.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
					AND 
					(
						<!------ Group ----->
						(Second_Contract_Products.Product_Group_ID = CAST(Second_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Second_Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(Second_Contract_Products.Product_Group_ID, '') = '' AND Second_Contract_Products.Is_Group = 0)
					) 
					<!------ Bid Request Fixed Pricing ----->
					INNER JOIN Program_Bid_Request_Product First_BidRequest
					ON	First_BidRequest.Deleted = 0
					AND	First_BidRequest.Contract_Products_ID = First_Contract_Products.Contract_Products_ID
					LEFT JOIN Program_Bid_Request_Product Second_BidRequest
					ON	Second_BidRequest.Deleted = 0
					AND	Second_BidRequest.Contract_Products_ID = Second_Contract_Products.Contract_Products_ID					
					<!------ UOM ----->
					INNER JOIN Units_Of_Measure First_Units_Of_Measure
					ON
					First_Units_Of_Measure.Unit_Of_Measure_ID = First_BidRequest.UOM
					LEFT JOIN Units_Of_Measure Second_Units_Of_Measure
					ON
					Second_Units_Of_Measure.Unit_Of_Measure_ID = Second_BidRequest.UOM
					INNER JOIN BSA_Foodservice_Items_Master
					ON	BSA_Foodservice_Items_Master.Deleted = 0
					AND	(BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = First_Contract_Products.BSA_Foodservice_Items_Master_ID
						OR
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
						)
					AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL
					AND ISNULL(First_Contract_Products.BSA_Foodservice_Items_Master_ID, Second_Contract_Products.BSA_Foodservice_Items_Master_ID) = ISNULL(Second_Contract_Products.BSA_Foodservice_Items_Master_ID, First_Contract_Products.BSA_Foodservice_Items_Master_ID)
					AND (First_Contract_Products.Product_Type_ID = 10 OR Second_Contract_Products.Product_Type_ID = 10)
			WHERE	Contract_Main.Contract_Main_ID = #arguments.ProgramId2#
			ORDER BY Is_Group, SerialNum, Change, Deleted, Added
		</cfquery>
		
		<cfreturn qGetBidRequest/>
	
	</cffunction>
	

	<cffunction name="addProgramHistory" output="false" returntype="void">
		<cfargument name="programId" type="numeric" required="true">
		<cfargument name="contractNumber" type="string" required="true">
		<cfargument name="content" type="string" required="true">
		<cfargument name="historyAction" type="numeric" required="true">
		<cfargument name="deletePreviousEntry" type="numeric" required="true">		
		
		<cfquery datasource="#application.datasource#">
            <cfif arguments.deletePreviousEntry>
                    UPDATE 	Program_History
                    SET 	Deleted = 1
                    WHERE 	Contract_Main_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
                    AND		Program_History_Action_ID = <cfqueryparam value="#arguments.historyAction#" cfsqltype="CF_SQL_INTEGER">
            </cfif>

			INSERT INTO Program_History(Contract_Main_ID, Contract_Number, Contract_Details, Program_History_Action_ID)
			VALUES(	<cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#arguments.contractNumber#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#application.util.string.compress( arguments.content )#" cfsqltype="CF_SQL_LONGVARCHAR">,
					<cfqueryparam value="#arguments.historyAction#" cfsqltype="CF_SQL_INTEGER">)
		</cfquery>
	</cffunction>
		
</cfcomponent>
