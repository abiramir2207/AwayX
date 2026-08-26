<cfcomponent>
	<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<cffunction name="getAllPrograms" output="false" returntype="any" hint="this function will retun all programs based on user serach criteria in settlements page">

		<cfargument name="stForm" required="true" default="" type="any" />
		<cfargument name="ProgramRestrictions" default="1" required="false" >

<cfif arguments.stForm.search EQ 'prg'>
		<cfset UserPositionList = CreateObject("component", "components.user.UserManager").getPositionId(request.AccessStructure.user_id, 0, 1) />
		<cfset HQUser = CreateObject("component", "components.user.UserManager").getUserIsHQ(request.AccessStructure.user_id, 0) />

	<cfset useLakebaseForGet_Profile_Settings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("profiles_settings")>
<cfif useLakebaseForGet_Profile_Settings>
	<cftry>
		<cfset Get_Profile_Settings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("profiles_settings", {
				"profiles_id" = "eq.#request.Accessstructure.Profiles_ID#",
				"select" = "*"
			}), "*"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Profile_Settings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Profile_Settings>
<cfquery NAME="Get_Profile_Settings" datasource="#application.datasource#">
		SELECT	Profiles_Settings.*
		FROM	Profiles_Settings
		WHERE	Profiles_ID= '#request.Accessstructure.Profiles_ID#'
	</cfquery>
</cfif>

		<cfif not HQUser>
			<cfquery name="qPositionsBelowMe" datasource="#application.datasource#">
				DECLARE @Positions_Below_Me table(
				  Below_User_Positions_ID   int          NOT NULL
				)

				INSERT INTO @Positions_Below_Me(Below_User_Positions_ID)
				SELECT	DISTINCT Below_User_Positions_ID
				FROM	Positions_Below_Me
				WHERE	User_Positions_ID IN (#PreserveSingleQuotes(UserPositionList)#)
			</cfquery>
		</cfif>

		<cfset GP_Position_List_From_My_Position_Down = "SELECT Below_User_Positions_ID FROM @Positions_Below_Me" />

		<cfset qUserNumber = "" />
		<cfif appSettings.getUserNumberRestrict()>
			<cfset qUser = CreateObject("component", "components.user.UserManager").getUser(programScorecardRestrictCreatedByUserId) />
			<cfset qUserNumber = qUser.User_Number />
		</cfif>

<cfif NOT HQUser>
	<CFSAVECONTENT variable="ProgramsWithDistUnderMe">
		SELECT	DISTINCT Contract_Distributors.Contract_Main_ID
		FROM	User_Positions
		INNER JOIN	BSA_Foodservice_Brokers
		ON User_Positions.Service_market_ID = BSA_Foodservice_Brokers.Service_market_ID
		INNER JOIN BSA_Foodservice_Customers
		ON BSA_Foodservice_Customers.Deleted = 0
		AND (BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID)
		INNER JOIN Contract_Distributors
		ON Contract_Distributors.Deleted = 0
		AND BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Contract_Distributors.BSA_Foodservice_Customers_ID
		WHERE	User_Positions.Deleted = 0
		AND User_Positions.User_Positions_ID IN(#GP_Position_List_From_My_Position_Down#)
	</CFSAVECONTENT>

	<CFSAVECONTENT variable="ProgramsWithBrokerUnderMe">
		SELECT	DISTINCT Contract_Brokers.Contract_Main_ID
		FROM	User_Positions
		INNER JOIN	BSA_Foodservice_Brokers
		ON User_Positions.Service_market_ID = BSA_Foodservice_Brokers.Service_market_ID
		INNER JOIN Contract_Brokers
		ON Contract_Brokers.Deleted = 0
		AND BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Contract_Brokers.BSA_Foodservice_Brokers_ID
		WHERE	User_Positions.Deleted = 0
		AND User_Positions.User_Positions_ID IN(#GP_Position_List_From_My_Position_Down#)
	</CFSAVECONTENT>
</cfif>

		<cfquery name="clearTempTables" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmp_customers') IS NOT NULL
			DROP TABLE ##tmp_customers

			IF OBJECT_ID('tempdb..##tmp_operators') IS NOT NULL
			DROP TABLE ##tmp_operators

			IF OBJECT_ID('tempdb..##tmp_items_Info') IS NOT NULL
			DROP TABLE ##tmp_items_Info

			IF OBJECT_ID('tempdb..##tmp_OPB_Program_List') IS NOT NULL
			DROP TABLE ##tmp_OPB_Program_List
		</cfquery>

	<!---CUSTOMER SEARCH---->
	<cfif len(arguments.stForm.customer_group_search) OR  len(arguments.stForm.customer_search)>

		<cfquery name="qCustomers" datasource="#application.datasource#">

			SELECT BSA_Foodservice_Customers_ID
			INTO ##tmp_customers
			FROM   BSA_Foodservice_Customers Cust

		<cfif len(arguments.stForm.customer_group_search)>
			LEFT JOIN Distributor_Family F ON F.Family_ID = Cust.Family_ID
			LEFT JOIN Distributor_Buying_Groups BG ON BG.Buying_group_ID = Cust. Buying_group_ID
			LEFT JOIN Distributor_Type DT ON DT.Distributor_Type_ID  = Cust.Distributor_Type_ID
		</cfif>

			WHERE Cust.Ship_To != 'Group'
		<cfif len(arguments.stForm.customer_search)>
		   AND (CUST.Ship_To LIKE '%#arguments.stForm.customer_search#%' OR CUST.Name LIKE '%#arguments.stForm.customer_search#%')
		</cfif>
	    <cfif len(arguments.stForm.customer_group_search)>
	       AND (F.Family LIKE '%#arguments.stForm.customer_group_search#%' OR F.Family_Name LIKE '%#arguments.stForm.customer_group_search#%'
	                 OR BG.Buying_Group LIKE '%#arguments.stForm.customer_group_search#%'  OR BG.Buying_Group_Name LIKE '%#arguments.stForm.customer_group_search#%'
					 OR DT.Distributor_Type LIKE '%#arguments.stForm.customer_group_search#%' OR DT.Distributor_Type_Name LIKE '%#arguments.stForm.customer_group_search#%' )
			</cfif>

		</cfquery>

	</cfif>

	<!---OPERATOR SEARCH--->
	<cfif len(arguments.stForm.Operator_Search)>
		<cfquery name="qCheckOperators" datasource="#application.datasource#">
			SELECT OP.BSA_Operator_ID
			INTO ##tmp_operators
			FROM BSA_Operator OP
			WHERE (OP.Legacy_ID LIKE '%#arguments.stForm.Operator_Search#%' OR OP.Operator_Name LIKE '%#arguments.stForm.Operator_Search#%')
		</cfquery>
	</cfif>

	<!---ITEM SEARCH--->
	<cfif len(arguments.stForm.item_search) OR len(arguments.stForm.item_group_search)>
		<cfquery name="qCheckItems" datasource="#application.datasource#">
			SELECT IM.BSA_Foodservice_Items_Master_ID
			INTO ##tmp_items_Info
			FROM BSA_Foodservice_Items_Master IM

			<cfif len(arguments.stForm.item_group_search)>
				INNER JOIN All_Product_Group_Type_Members GTM ON GTM.BSA_Foodservice_Items_Master_ID = IM.BSA_Foodservice_Items_Master_ID
				INNER JOIN All_Product_Group_Type GT ON GT.Group_GUID = GTM.Product_Group_ID
				AND GT.Product_Group_Level_ID < 200
			</cfif>
			WHERE IM.Item is NOT NULL
			<cfif len(arguments.stForm.item_search)>
			AND IM.Item LIKE '%#arguments.stForm.item_search#%' OR IM.Description LIKE '%#arguments.stForm.item_search#%'
			</cfif>
			<cfif len(arguments.stForm.item_group_search)>
	           AND (GT.Group_Number LIKE '%#arguments.stForm.customer_group_search#%' OR GT.Group_Desc LIKE '%#arguments.stForm.customer_group_search#%')
			</cfif>
		</cfquery>
	</cfif>

	<!---PROGRAM TEMPLATE SEARCH --->
	<cfif isdefined("arguments.stForm.template_list") AND len(arguments.stForm.template_list)>
		<cfset selectedTemplates = ListQualify(arguments.stForm.template_list,"'",",","CHAR")>
	</cfif>

	<!---PLANNER TEMPLATES SEARCH--->
	<cfif isdefined("arguments.stForm.planner_template_list") AND len(arguments.stForm.planner_template_list)>
		<cfset selectedPlannersTemplates = ListQualify(arguments.stForm.planner_template_list,"'",",","CHAR")>
	</cfif>

		<cfset isRebate = 0>
		<cfset RebateComponents = ''>

		<cfset isLumpSum= 0>
		<cfset LumpSumComponents = ''>

		<cfset isGrowth = 0>
		<cfset GrowthComponents = ''>

		<cfset isFixed = 0>
		<cfset FixedComponents = ''>

	<!---COMPONENT SEARCH--->
	<cfif isdefined("arguments.stForm.discount_type") AND len(arguments.stForm.discount_type)>
		<cfloop list="#arguments.stForm.discount_type#" index="Components" >
			<cfif Components EQ 'R'>
				<cfset isRebate = 1>
			</cfif>

			<cfif Components EQ 'L'>
				<cfset isLumpSum= 1>
			</cfif>

			<cfif Components EQ 'G'>
				<cfset isGrowth = 1>
			</cfif>

			<cfif Components EQ 'F'>
				<cfset isFixed = 1>
			</cfif>
		</cfloop>
	</cfif>

	<!---COMPONENT LIST SEARCH--->
	<cfif isdefined("arguments.stForm.component_list") AND len(arguments.stForm.component_list)>
		<cfloop list="#arguments.stForm.component_list#" index="Components" >
			<cfif ListFind(Components,"R")>
				<cfset isRebate = 1>
				<cfset RebateComponents = listappend(RebateComponents, RemoveChars(Components,1,2))>
			</cfif>

			<cfif ListFind(Components,"L")>
				<cfset isLumpSum= 1>
				<cfset LumpSumComponents = listappend(LumpSumComponents, RemoveChars(Components,1,2))>
			</cfif>

			<cfif ListFind(Components,"G")>
				<cfset isGrowth = 1>
				<cfset GrowthComponents = listappend(GrowthComponents, RemoveChars(Components,1,2))>
			</cfif>

			<cfif ListFind(Components,"F")>
				<cfset isFixed = 1>
				<cfset FixedComponents = listappend(FixedComponents, RemoveChars(Components,1,2))>
			</cfif>
		</cfloop>

	</cfif>

	<!---PAID TO SEARCH--->
	<cfif isdefined("arguments.stForm.paid_to") AND len(arguments.stForm.paid_to)>
		<cfset isRebate = 1>
		<cfset isLumpSum= 1>
		<cfset isGrowth = 1>
		<cfset isFixed = 1>
	</cfif>

<cfset forbidType = appSettings.getForbidAllowProfilesInTemplates() />

<cfquery name="qGetAllPrograms" datasource="#application.datasource#">

		DECLARE @Profile_Forbidden_Template TABLE(
		  Template_ID   INT          NOT NULL,
		  Forbid_Access_Type INT          NOT NULL
		)
			INSERT INTO @Profile_Forbidden_Template (Template_ID, Forbid_Access_Type)
			SELECT 	DISTINCT template_id, Forbid_Access_Type
			FROM 	Profile_Forbidden_Template
			WHERE 	Deleted = 0
			AND Forbid_Type = #forbidType#
			AND profile_id = #request.accessstructure.profiles_id#

			SELECT DISTINCT Contract_Number AS Program_Number
			INTO ##tmp_OPB_Program_List
			FROM Contract_Main CM

        <cfif len(arguments.stForm.customer_search) OR len(arguments.stForm.customer_group_search)>
            INNER JOIN  Contract_Distributors CD
            ON       CD.Contract_Main_ID = CM.Contract_Main_ID
            AND     CD.Deleted =0
            INNER JOIN ##tmp_customers Cust
            ON CD.BSA_Foodservice_Customers_ID = Cust.BSA_Foodservice_Customers_ID
        </cfif>

		<cfif len(arguments.stForm.Operator_Search)>
			INNER JOIN  Contract_Operators CO
			ON	CO.Contract_Main_ID = CM.Contract_Main_ID
			AND	CO.Deleted =0
			INNER JOIN ##tmp_operators OP
			ON CO.BSA_Operator_ID = OP.BSA_Operator_ID
		</cfif>

		<cfif len(arguments.stForm.item_search) OR  len(arguments.stForm.item_group_search)>
			INNER JOIN Contract_Products CP
			ON 	CP.Contract_Main_ID = CM.Contract_Main_ID
			AND CP.Deleted = 0
			INNER JOIN ##tmp_items_Info IM
			ON CP.BSA_Foodservice_Items_Master_ID = IM.BSA_Foodservice_Items_Master_ID
		</cfif>

		<cfif isdefined("arguments.stForm.template_list") AND len(arguments.stForm.template_list)>
			INNER JOIN Program_Control_Panel_Options PCPO
			ON PCPO.ProgramControl_Panel_Options_ID = CM.ProgramType_ID
			AND PCPO.First_Parent_ID IN (#PreserveSingleQuotes(selectedTemplates)#)
		</cfif>

		<cfif isdefined("arguments.stForm.planner_template_list") AND len(arguments.stForm.planner_template_list)>
			INNER JOIN Planners P
			ON P.Planner_ID = CM.Planner_ID
			AND P.Planner_Template_ID IN (#PreserveSingleQuotes(selectedPlannersTemplates)#)
		</cfif>

			WHERE CM.Effective_Start_Date #arguments.stForm.startDateCondition# '#arguments.stForm.startDate#'
			AND CM.Effective_End_Date  #arguments.stForm.endDateCondition# '#arguments.stForm.endDate#'
			AND CM.Manual_Cancel = 0
			AND CM.Approved = 1

		<cfif arguments.ProgramRestrictions eq 1>

			<cfif not HQUser AND Get_Profile_Settings.BB_Add_Payee_Any_Position NEQ 1>
				AND( (Creating_User_Position_ID IN(#PreserveSingleQuotes(UserPositionList)#) )
				OR ( Creating_User_Position_ID IN (#preserveSingleQuotes(GP_Position_List_From_My_Position_Down)#) )
					<!--- When this setting is on, we only show programs created by the users with the same position.
								Execute the code below only when the setting is off. "ProgramsWithDistUnderMe" and "ProgramsWithBrokerUnderMe"
								are set in scorecard/access_permissions.cfm
					--->
					<cfif NOT Get_Profile_Settings.Program_Scorecard_Restrict_Created_By>
					OR ( Contract_Main.Contract_Main_ID IN(#PreserveSingleQuotes(ProgramsWithDistUnderMe)#) )
					OR ( Contract_Main.Contract_Main_ID IN(#PreserveSingleQuotes(ProgramsWithBrokerUnderMe)#) )
					</cfif>
				)
			</cfif>

		<!--- If the below profile settings is on, then the user should only be allowed to see programs
					that have him/her as an RSP OR where the program creator's RSP has the user number same as
					this user's User number
		--->
		<cfif Get_Profile_Settings.Program_Scorecard_Restrict_Created_By>
			<cfset programScorecardRestrictCreatedByUserId = request.AccessStructure.user_id>
			AND (
				responsibleSalesPerson.User_ID = '#programScorecardRestrictCreatedByUserId#'
					<cfif Len(qUserNumber) GT 0>
						OR responsibleSalesPerson.User_Number = '#qUserNumber#'
					</cfif>
			)
		</cfif>

			AND CM.ProgramType_ID <cfif forbidType EQ 1>NOT </cfif>IN (select Template_ID from @Profile_Forbidden_Template WHERE Forbid_Access_Type = 1)
		</cfif>
		<!---PROGRAM SEARCH--->
		<cfif len(arguments.stForm.program_search)>
			AND (CM.Contract_Number like '%#arguments.stForm.program_search#%' OR CM.Contract_Title like '%#arguments.stForm.program_search#%')
		</cfif>


		<cfif (isdefined("arguments.stForm.component_list") AND len(arguments.stForm.component_list))
		 OR (isdefined("arguments.stForm.discount_type") AND len(arguments.stForm.discount_type))
		 OR (isdefined("arguments.stForm.paid_to") AND len(arguments.stForm.paid_to))>
		AND	(1=2
			<cfif isRebate>
				OR EXISTS (
					SELECT	1
					FROM	Program_Rebates_Component PRC
					WHERE 	PRC.Program_ID = CM.Contract_Main_ID
					<cfif len(RebateComponents)>
					AND 	PRC.Program_Rebates_Component_Name_ID IN (#PreserveSingleQuotes(RebateComponents)#)
					</cfif>
					<cfif isdefined("arguments.stForm.paid_to") AND len(arguments.stForm.paid_to)>
					AND 	Component_Paid_To IN (#PreserveSingleQuotes(arguments.stForm.paid_to)#)
					</cfif>
				)
			</cfif>

			<cfif isLumpSum>
				OR EXISTS (
					SELECT	1
					FROM	Program_Lump_Sums PLC
					WHERE 	PLC.Program_ID = CM.Contract_Main_ID
					<cfif len(LumpSumComponents)>
					AND 	PLC.Program_Lump_Sum_Name_ID IN (#PreserveSingleQuotes(LumpSumComponents)#)
					</cfif>
					<cfif isdefined("arguments.stForm.paid_to") AND len(arguments.stForm.paid_to)>
					AND 	Component_Paid_To IN (#PreserveSingleQuotes(arguments.stForm.paid_to)#)
					</cfif>
				)
			</cfif>

			<cfif isGrowth>
				OR EXISTS (
					SELECT	1
					FROM	Program_Growth_Components PGC
					WHERE		PGC.Program_ID = CM.Contract_Main_ID
					<cfif len(GrowthComponents)>
					AND 	PGC.Growth_Component_Name_ID IN (#PreserveSingleQuotes(GrowthComponents)#)
					</cfif>
					<cfif isdefined("arguments.stForm.paid_to") AND len(arguments.stForm.paid_to)>
					AND 	Component_Paid_To IN (#PreserveSingleQuotes(arguments.stForm.paid_to)#)
					</cfif>
				)
			</cfif>

			<cfif isFixed>
				OR EXISTS (
					SELECT	1
					FROM	Program_Fixed_Component PFC
					WHERE		PFC.Program_ID = CM.Contract_Main_ID
					<cfif len(FixedComponents)>
					AND 	PFC.Program_Fixed_Component_Name_ID IN (#PreserveSingleQuotes(FixedComponents)#)
					</cfif>
					<cfif isdefined("arguments.stForm.paid_to") AND len(arguments.stForm.paid_to)>
					AND 	Fixed_Component_Paid_To IN (#PreserveSingleQuotes(arguments.stForm.paid_to)#)
					</cfif>
				)
			</cfif>
			)
		</cfif>

		</cfquery>

<cfquery name="qCheckcount" datasource="#application.datasource#">
	SELECT COUNT(*) as TotalPrograms
	FROM ##tmp_OPB_Program_List
</cfquery>


<cfif qCheckcount.TotalPrograms GT 100>

	<cfset qOPBProgramDetails = QueryNew( "Planner_Number,Program_Number,Program_Title,Customer_ID,Customer_Name,	Delivery_Start_Date,Delivery_End_Date,Item_Number,Item_Description, Discount_Type,Component_Name,Program_Rate,Rebate_UOM,Volume,Volume_UOM,Extended_Amount,Operator_ID,Operator_Name,Accrued,Settled,Balance,Contract_Main_ID,BSA_Foodservice_Customers_ID,BSA_Foodservice_Items_Master_ID,BSA_Operator_ID,Discount_Type_ID,Component_Name_ID,Component_Paid_To,Rebate_UOM_ID,Net_Weight,Max_Program_Count,Program_Count,Detail_Count,Net_Weight,Sleeves_Per_Case,Case_Count,Price_CS,Contract_Main_ID,Template,Segment")>

<cfset QueryAddRow(qOPBProgramDetails)>
<cfset QuerySetCell(qOPBProgramDetails,"Max_Program_Count",'1')>
<cfset QuerySetCell(qOPBProgramDetails,"Program_Count",qCheckcount.TotalPrograms)>

<cfelse>

			<cfset userID = replace(request.AccessStructure.user_id,'-','_','ALL')>

			<cfstoredproc datasource="#application.datasource#" procedure=OPB_Program_Details>
				<cfprocparam cfsqltype="cf_sql_varchar" value="#userID#" dbvarname="@Table_Suffix">
			</cfstoredproc>

			<cfset tableName= '####tmp_OPB_Program_Details_'&userID>

			<cfquery name="qOPBProgramDetails" datasource="#application.datasource#">
		 		SELECT *
		 		FROM #tableName#
		 		ORDER BY Program_Number
			</cfquery>

</cfif>

<cfelse>
	<cfset qOPBProgramDetails = QueryNew( "Planner_Number,Program_Number,Program_Title,Customer_ID,Customer_Name,	Delivery_Start_Date,Delivery_End_Date,Item_Number,Item_Description, Discount_Type,Component_Name,Program_Rate,Rebate_UOM,Volume,Volume_UOM,Extended_Amount,Operator_ID,Operator_Name,Accrued,Settled,Balance,Contract_Main_ID,BSA_Foodservice_Customers_ID,BSA_Foodservice_Items_Master_ID,BSA_Operator_ID,Discount_Type_ID,Component_Name_ID,Component_Paid_To,Rebate_UOM_ID,Net_Weight,Max_Program_Count,Program_Count,Detail_Count,Net_Weight,Sleeves_Per_Case,Case_Count,Price_CS,Contract_Main_ID,Trmplate,Segment")>
</cfif>

	<cfreturn qOPBProgramDetails>

</cffunction>

	<cffunction name="getDeductions" output="false" returntype="query" access="remote">
		<cfargument name="BillbackID" required="false" default="" type="any" />
		<cfargument name="stForm" required="true" default="" type="any" />

		<cfset displayOnlyAssignedDeductions = appSettings.getDisplayOnlyAssignedDeductions()>
		<cfset UserPositionList = CreateObject("component", "components.user.UserManager").getPositionId(request.AccessStructure.user_id, 0, 1) />
		<cfset DD_Status_toHide	= CreateObject("component", "components.Deduction.settings.DeductionSettingsManager").DD_Status_Control(request.AccessStructure.profiles_id) />

		<cfquery NAME="HQPosition" datasource="#Application.datasource#">
			SELECT 	User_Positions_ID
			FROM 	User_Positions
			WHERE 	Service_Zone_ID IS NULL
			AND  Service_Region_ID IS NULL
			AND  Service_Market_ID IS NULL
			AND  Deleted = 0
		</cfquery>

		<cfset useLakebaseForDeductionsProfilesSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions_profiles_settings")>
<cfif useLakebaseForDeductionsProfilesSettings>
	<cftry>
		<cfset DeductionsProfilesSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions_profiles_settings", {
				"profiles_id" = "eq.#request.accessstructure.profiles_id#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDeductionsProfilesSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeductionsProfilesSettings>
<cfquery NAME="DeductionsProfilesSettings" datasource="#application.datasource#">
			SELECT *
			FROM Deductions_Profiles_Settings
			WHERE Profiles_ID = #request.accessstructure.profiles_id#
		</cfquery>
</cfif>

		<cfset useLakebaseForUserHasAssignments = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_analyst")>
<cfif useLakebaseForUserHasAssignments>
	<cftry>
		<cfset UserHasAssignments = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_analyst", {
				"analyst_user_id" = "eq.#request.AccessStructure.User_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUserHasAssignments = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUserHasAssignments>
<cfquery NAME="UserHasAssignments" datasource="#Application.datasource#">
			 SELECT *
			 FROM DD_Analyst
			 WHERE Analyst_User_ID = '#request.AccessStructure.User_ID#'
			 AND Deleted=0
		</cfquery>
</cfif>

		<cfquery NAME="IaASupervisor" datasource="#Application.datasource#">
			SELECT *
			FROM DD_Analyst
			WHERE 	Analyst_User_ID = '#request.AccessStructure.User_ID#'
			AND Is_Supervisor = 1
			AND Supervisor_ID IS NULL
			AND (LEN(LTRIM(RTRIM(Supervisor_ID))) = 0 OR LEN(LTRIM(RTRIM(Supervisor_ID))) IS NULL)
			AND Deleted = 0
		</cfquery>

		<cfif IaASupervisor.RecordCount GT 0>
			<cfquery NAME="GetAnalystUnderMe" datasource="#Application.datasource#">
				SELECT *
				FROM DD_Analyst
				WHERE 	Supervisor_ID = '#request.AccessStructure.User_ID#'
				<cfif IaASupervisor.Is_Default_Supervisor EQ 1>
					OR (LEN(LTRIM(RTRIM(Supervisor_ID))) = 0 OR LEN(LTRIM(RTRIM(Supervisor_ID))) IS NULL)
				</cfif>
				AND	Is_Supervisor = 0
				AND	Deleted = 0
			</cfquery>
			<cfset AnalystUnderMe_List = VALUELIST(GetAnalystUnderMe.Analyst_User_ID)>
			<cfset AnalystUnderMe_List = ListAppend(AnalystUnderMe_List, request.AccessStructure.User_ID)>
		</cfif>

			<cfset UserIsASupervisor = 0>
			<cfif IaASupervisor.RecordCount GT 0 AND GetAnalystUnderMe.RecordCount GT 0>
				<cfset UserIsASupervisor = 1>
			</cfif>

			<cfset SrchByAnalystAllowed = false />
			<!---- if the user profile "search by analyst"" = on or if user is an HQ ---->
			<cfif DeductionsProfilesSettings.DD_Search_By_Analyst OR ListFind(UserPositionList, HQPosition.User_Positions_ID)>
				<cfset SrchByAnalystAllowed = true>
			</cfif>

			<cfquery name="qGetDeductions" datasource="#application.datasource#">

			<cfif NOT ListFind(UserPositionList, HQPosition.User_Positions_ID)> <!---- not an HQ ----->
				DECLARE @Temp_Market_ID table (Service_Market_ID int)

				INSERT INTO @Temp_Market_ID(Service_Market_ID)
				SELECT DISTINCT Service_Markets.Service_Market_ID
				FROM 		User_Positions
				LEFT JOIN 	Service_Regions
				ON Service_Regions.Service_Zone_ID = User_Positions.Service_Zone_ID
				AND User_Positions.Service_Zone_ID IS NOT NULL
				AND User_Positions.Service_Region_ID IS NULL
				AND User_Positions.Service_Market_ID IS NULL
				LEFT JOIN 	Service_Markets
				ON	(
							(	Service_Markets.Service_Market_ID = User_Positions.Service_Market_ID
								AND User_Positions.Service_Market_ID IS NOT NULL
							 ) OR
							 (	Service_Markets.Service_Region_ID = User_Positions.Service_Region_ID
							 	AND User_Positions.Service_Region_ID IS NOT NULL
							 	AND User_Positions.Service_Market_ID IS NULL
							 ) OR
							(	User_Positions.Service_Zone_ID IS NOT NULL
								AND User_Positions.Service_Region_ID IS NULL
								AND User_Positions.Service_Market_ID IS NULL
								AND Service_Markets.Service_Region_ID = Service_Regions.Service_Region_ID
							) OR
							(	1=1
								AND User_Positions.Service_Zone_ID IS NULL
								AND User_Positions.Service_Region_ID IS NULL
								AND User_Positions.Service_Market_ID IS NULL
							)
						)
				AND Service_Markets.Service_Market_ID IS NOT NULL
				WHERE User_Positions.User_Positions_ID IN (#PreserveSingleQuotes(UserPositionList)#)
			</cfif>

		SELECT Deductions.Deduction_ID
								,DD_Status_Description
								,Deductions.DD_DedID
								,Deductions.DD_Date
								,Deductions.DD_Amount
								,Deductions.DD_Reference
								,<cfif appSettings.get_Setting('Display_Distributor_ID') eq '1'>BSA_Foodservice_Customers.Shr_Ship_To<cfelse>BSA_Foodservice_Customers.Ship_To</cfif> AS Customer_ID
								,BSA_Foodservice_Customers.Name
								,Deductions.DD_Check_Number
								,U.Name_First+' '+U.Name_Last AS Analyst
								,DD_Aging.DD_Aging_Label
								,BSA_Foodservice_Customers.Family_ID
		FROM	Deductions
		LEFT JOIN	BSA_Foodservice_Customers
		ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Deductions.Distributor_ID
		INNER JOIN 	DD_Status
		ON DD_Status.DD_Status_ID = Deductions.DD_Status
		<cfif LISTLEN(DD_Status_toHide) GT 0>
			AND	Deductions.DD_Status NOT IN (#DD_Status_toHide#)
		</cfif>
		INNER JOIN _Users U
		ON U.User_ID = Deductions.Analyst_User_ID

		LEFT JOIN	DD_Aging
		ON Start_Range <= datediff(d,Deductions.dd_date,getdate())
		AND (End_Range IS NULL OR End_Range >= datediff(d,Deductions.dd_date,getdate()))
		AND DD_Aging.Deleted = 0

		LEFT JOIN Distributor_Bill_To
		ON Distributor_Bill_To.Distributor_Bill_To_ID = Deductions.Distributor_Bill_To_ID

		WHERE Deductions.Split_Count = 0
		AND Deductions.DD_Closure_ID IS NULL
		AND Deductions.Is_Write_Off = 0
		AND Deductions.DD_Status NOT IN (4,5,6,9)

<cfif len(arguments.stForm.deduction_search)>
	AND ( Deductions.DD_DedID LIKE '%#arguments.stForm.deduction_search#%' OR Deductions.DD_DedID_SP_Number LIKE '%#arguments.stForm.deduction_search#%')
</cfif>

<cfif len(arguments.stForm.reference_search)>
	AND Deductions.DD_Reference LIKE '%#arguments.stForm.reference_search#%'
</cfif>

<cfif len(arguments.stForm.check_search)>
	AND Deductions.DD_Check_Number LIKE '%#arguments.stForm.check_search#%'
</cfif>

<cfif len(arguments.stForm.creference_search)>
	AND Deductions.DD_Customer_RefNo  LIKE '%#TRIM(arguments.stForm.creference_search)#%'
</cfif>

<cfif len(arguments.stForm.dd_customer_search)>
	AND BSA_Foodservice_Customers.Name LIKE '%#TRIM(arguments.stForm.dd_customer_search)#%'
</cfif>

<cfif len(arguments.stForm.dd_status_list)>
	AND Deductions.DD_Status IN (#listQualify(arguments.stForm.dd_status_list,"'")#)
</cfif>

	<cfif len(arguments.stForm.dd_family)>
		AND	( Deductions.Ass_BasedOn_Family_ID  IN (#listQualify(arguments.stForm.dd_family,"'")#)
								OR
			 					BSA_Foodservice_Customers.Family_ID IN (#listQualify(arguments.stForm.dd_family,"'")#)
			 				)
		</cfif>

<cfif len(arguments.stForm.dd_analyst)>
	AND Deductions.Analyst_User_ID IN (#listQualify(arguments.stForm.dd_analyst,"'")#)
</cfif>

<!---- SEARCH FILTERS START---->

	<!---- FILTER BY WORK ITEM AMOUNT ---->
	<cfif len(arguments.stForm.FILTERworkItemamount) AND len(arguments.stForm.FILTERddAmount)>
		<cfif appSettings.getDDCloseWithEqualBBAmt() eq 1>
			AND Deductions.DD_Amount = '#arguments.stForm.FILTERddAmount#'
		<cfelse>
			AND Deductions.DD_Amount >= '#arguments.stForm.FILTERddAmount#'
		</cfif>
	</cfif>

	<!---- FILTER BY DISTRIBUTOR ---->
<cfif len(arguments.stForm.MC_Shr_Ship_to) OR len(arguments.stForm.MC_Shr_Bill_To)>
AND ( 1= 2
  <cfif (appSettings.get_Setting('Deduction_match_using_bill_to_vendor') EQ '1')>
		OR (Distributor_Bill_To.Shr_Bill_To = '#arguments.stForm.MC_Vendor_ID#' OR Distributor_Bill_To.Name LIKE '%#TRIM(arguments.stForm.MC_Vendor_Name)#%')
	<cfelse>
		<cfif len(arguments.stForm.MC_Shr_Ship_to)>
			OR (BSA_Foodservice_Customers.Shr_Ship_To = '#arguments.stForm.MC_Shr_Ship_To#' OR	BSA_Foodservice_Customers.Name LIKE '%#TRIM(arguments.stForm.MC_Distributor_Name)#%')
		</cfif>

				<CFIF len(arguments.stForm.MC_Shr_Bill_To)>
					OR (
									<CFIF len(arguments.stForm.MC_Shr_Ship_to) AND (arguments.stForm.MC_Shr_Ship_To NEQ arguments.stForm.MC_Shr_Bill_To)>
										Deductions.Distributor_ID IS NULL AND
									</CFIF>
										(Distributor_Bill_To.Shr_Bill_To = '#arguments.stForm.MC_Shr_Bill_To#' OR Distributor_Bill_To.Name LIKE '%#TRIM(arguments.stForm.MC_Bill_To_Name)#%')
								)
				</CFIF>
	</cfif>
)
</cfif>

	<!--- FILTER BY REMAINING BALANCE --->
	<cfif len(arguments.stForm.FILTERremainingBalance) AND len(arguments.stForm.FILTERremainingAmt)>
		AND Deductions.DD_Amount <= '#arguments.stForm.FILTERremainingAmt#'
	</cfif>

	<!--- KEYWORD SEARCH ---->
	<cfif len(arguments.stForm.FILTERkeyword)>
	AND	(
		(CustomerName		LIKE '%#arguments.stForm.FILTERkeyword#%' AND CustomerName IS NOT NULL)
		OR (Shr_ship_to LIKE '%#arguments.stForm.FILTERkeyword#%' AND Shr_ship_to IS NOT NULL)
		OR (Name LIKE '%#arguments.stForm.FILTERkeyword#%' AND Name IS NOT NULL)
		OR (Shr_Bill_To LIKE '%#arguments.stForm.FILTERkeyword#%' AND Shr_Bill_To IS NOT NULL)
		OR (DD_Reference	LIKE '%#arguments.stForm.FILTERkeyword#%' AND DD_Reference IS NOT NULL)
		OR (DD_Check_Number 	LIKE '%#arguments.stForm.FILTERkeyword#%' AND DD_Check_Number 	IS NOT NULL)
		)
	</cfif>

<!---- SEARCH FILTERS END---->

		<cfif appSettings.getDDSentRejectIn1510() NEQ 1>AND  Deductions.DD_Rejected=0 </cfif>
	<!------------------------ check access permission - start -------------------------------------->
	<!-----
	Quick / Advanced Search					Profile Search By Analyst = ON
	--------------------------------------------------------------------------------------------------------------------
	HQ (not Analyst / not Supervisor)		All
	HQ (Analyst / Supervisor)				All
	Non HQ (not Analyst / not Supervisor)	All
	Non HQ (Analyst / Supervisor)			All
	--------------------------------------------------------------------------------------------------------------------
	Quick / Advanced Search					Profile Search By Analyst = OFF
	--------------------------------------------------------------------------------------------------------------------
	HQ (not Analyst / not Supervisor)		All
	HQ (Analyst / Supervisor)				All
	Non HQ (not Analyst / not Supervisor)	Based on user position only
	Non HQ (Analyst / Supervisor)			Based on analyst assignment only
	------>
					<cfif NOT DeductionsProfilesSettings.DD_ACCESS_LEVEL>
					AND 1=2
					<cfelseif NOT SrchByAnalystAllowed>
						<cfif displayOnlyAssignedDeductions and UserHasAssignments.RecordCount>
							AND Deductions.Analyst_User_ID = '#request.AccessStructure.User_ID#'
						<cfelse>
							<cfif ListFind(UserPositionList, HQPosition.User_Positions_ID)> <!---- is an HQ ----->
								AND 1=1
							<cfelseif UserHasAssignments.RecordCount AND NOT IaASupervisor.RecordCount><!--- not HQ, just an anlayst ---->
								AND Deductions.Analyst_User_ID = '#request.AccessStructure.User_ID#'
							<cfelseif UserIsASupervisor> <!---- not HQ, supervisor ----->
								AND Deductions.Analyst_User_ID IN (#LISTQUALIFY(AnalystUnderMe_List,"'",",","All")#)
							<cfelse> <!---- not analyst, not supervisor, not HQ ---->
								AND Service_Markets.Service_Market_ID IN (SELECT Service_Market_ID FROM @Temp_Market_ID)
							</cfif>
						</cfif>
					</cfif>
	<!------------------------ check access permission - end -------------------------------------->

			</cfquery>

			<cfreturn qGetDeductions>
		</cffunction>

	<cffunction name="UpdateDetails" output="false" returntype="query" hint="this function will insert records into temp OPB details table">
		<cfargument name="stForm" required="true" default="" type="any" />

		<cfset ConvertedVolumeUOM = 2>
		<cfif arguments.stForm.Volume_UOM EQ 'EA' OR arguments.stForm.Volume_UOM EQ 'SL' OR arguments.stForm.Volume_UOM EQ 'CS'>
			<cfset ConvertedVolumeUOM = 1>
		</cfif>

		<cfif arguments.stForm.Volume EQ 'x'>
			<cfset Volume = 1>
		<cfelse>
			<cfset Volume = arguments.stForm.Volume>
		</cfif>

			<cfquery name = "qUpdateDetails" datasource="#application.datasource#">
				UPDATE #arguments.stForm.TableName#
				SET Volume =  '#Volume#'
					   ,Volume_UOM =  '#arguments.stForm.Volume_UOM#'
					   ,Extended_Amount =  '#arguments.stForm.Extended_Amount#'
					   ,Volume_CS =  <cfif arguments.stForm.Volume_UOM EQ 'LB'>
																					#Volume# / Net_Weight
																				<cfelseif arguments.stForm.Volume_UOM EQ 'CWT'>
																					(#Volume# * 100) / Net_Weight
																				<cfelseif arguments.stForm.Volume_UOM EQ 'EA'>
																					#Volume# / Case_Count
																				<cfelseif arguments.stForm.Volume_UOM EQ 'SL'>
																					#Volume# / Sleeves_Per_Case
																				<cfelse>
																					#Volume#
																				</cfif>
					   ,Converted_Volume =  <cfif arguments.stForm.Volume_UOM EQ 'CWT'>
																											(#Volume# * 100) / Net_Weight
																										<cfelseif arguments.stForm.Volume_UOM EQ 'EA'>
																										#Volume# / Case_Count
																										<cfelseif arguments.stForm.Volume_UOM EQ 'SL'>
																											#Volume# / Sleeves_Per_Case
																										<cfelse>
																											#Volume#
																										</cfif>
					   ,Converted_Volume_UOM = #ConvertedVolumeUOM#
				WHERE Program_Number = '#arguments.stForm.Program_Number#'
				AND BSA_Foodservice_Customers_ID =  '#arguments.stForm.BSA_Foodservice_Customers_ID#'
				AND BSA_Foodservice_Items_Master_ID =  '#arguments.stForm.BSA_Foodservice_Items_Master_ID#'
				AND Component_Name_ID =  '#arguments.stForm.Component_Name_ID#'
				AND Component_Paid_To =  '#arguments.stForm.Component_Paid_To#'
			</cfquery>

			<cfquery name = "qGettotals" datasource="#application.datasource#">
          SELECT  CAST(SUM(Volume_CS) AS decimal(20,#appSettings.get_Setting('Decimal_display_for_CS')#)) AS TotalVolume
					          , SUM(Extended_Amount) AS TotalXAmount
					          , CASE WHEN COUNT(DISTINCT Component_Paid_To)  = 1 THEN 1 ELSE 0 END AS PaidTo
										, Sum(Component_Paid_To)/Count(Component_Paid_To) AS Component_Paid_To
          FROM #arguments.stForm.TableName#
          WHERE Volume <> 0
			</cfquery>

		<cfreturn qGettotals>
	</cffunction>

<cffunction name="createBillblack" output="false" returntype="any" hint="this function will create billback">

	<cfargument name="stForm"     required="true" default="" type="any" />

<cfquery name="qHeaderInfo" datasource="#application.datasource#">
	SET NOCOUNT ON

	INSERT INTO OPB_Header(
							BB_Reference
							,Billback_Date
							,BB_Payee_Type_ID
							,BB_Closing_Method_ID
							<cfif len(arguments.stForm.Vendor_Master_ID)>
							,Vendor_Master_ID
							</cfif>
							,BB_Start_Date
							,BB_End_Date
							<cfif len(arguments.stForm.Deduction_ID)>
							,Deduction_ID
							</cfif>
							,User_ID
							,BB_Creator_Notes
							,Claimed_Amt
							,Claimed_Qty
							,Allocated_Dollars
							,Document_ID
	)
	VALUES (
		'#arguments.stForm.BB_Ref#'
		,'#arguments.stForm.BB_Date#'
		,#arguments.stForm.Payee_Type#
		,#arguments.stForm.Closing_Method#
		<cfif len(arguments.stForm.Vendor_Master_ID)>
		,'#arguments.stForm.Vendor_Master_ID#'
		</cfif>
		,'#arguments.stForm.Del_Start#'
		,'#arguments.stForm.Del_End#'
		<cfif len(arguments.stForm.Deduction_ID)>
		,'#trim(arguments.stForm.Deduction_ID)#'
		</cfif>
		,'#request.AccessStructure.User_ID#'
		,'#arguments.stForm.BBNotes#'
		,'#arguments.stForm.Claimed_Amt#'
		,#arguments.stForm.Claimed_Qty#
		,'#arguments.stForm.Allocated#'
		,'#arguments.stForm.Doc_ID#'
	)

	SELECT OPB_Header_ID = @@IDENTITY
	SET NOCOUNT OFF
</cfquery>

		<cfset userID = replace(request.AccessStructure.user_id,'-','_','ALL')>

		<cfset tableName= '####tmp_OPB_Program_Details_'&userID>

<cfquery name="qDetailInfo" datasource="#application.datasource#">
	INSERT INTO OPB_Detail(
						 OPB_Header_ID
		 				,Program_Number
						,BSA_Foodservice_Customers_ID
						,BSA_Foodservice_Items_Master_ID
						,Discount_Type_ID
						,Component_Name_ID
						,Program_Rate
						,Rebate_UOM
						,Volume
						,Volume_UOM
						,Extended_Amount
						,BSA_Operator_ID
						,Accrued
						,Settled
						,Balance
						,Converted_Volume
						,Converted_Volume_UOM
	)
	SELECT  #qHeaderInfo.OPB_Header_ID#
				,Program_Number
				,BSA_Foodservice_Customers_ID
				,BSA_Foodservice_Items_Master_ID
				,Discount_Type_ID
				,Component_Name_ID
				,Program_Rate
			  ,CASE WHEN Rebate_UOM  = 'CS' THEN 1
									 WHEN Rebate_UOM  = 'LB' THEN 2
									 WHEN Rebate_UOM  = '%' THEN 3
									 WHEN Rebate_UOM  = 'EA' THEN 5
									 WHEN Rebate_UOM  = 'CWT' THEN 6
									 WHEN Rebate_UOM  = 'SL' THEN 7
									 ELSE 0
									 END AS Rebate_UOM
				,Volume
 		,CASE WHEN Volume_UOM  = 'CS' THEN 1
							 WHEN Volume_UOM  = 'LB' THEN 2
							 WHEN Rebate_UOM  = '%' THEN 3
							 WHEN Volume_UOM  = 'EA' THEN 5
							 WHEN Volume_UOM  = 'CWT' THEN 6
							 WHEN Volume_UOM  = 'SL' THEN 7
							 ELSE 0
							 END AS Volume_UOM
				,Extended_Amount
				,BSA_Operator_ID
				,Accrued
				,Settled
				,Balance
				,Converted_Volume
				,Converted_Volume_UOM
	FROM #tableName#
	WHERE Volume <> 0
</cfquery>

			<cfstoredproc datasource="#application.datasource#" procedure=OPB_BB_Create>
				<cfprocparam CFSQLType="CF_SQL_INTEGER" value="#qHeaderInfo.OPB_Header_ID#" dbvarname="@OPB_Header_ID">
			</cfstoredproc>

	<cfquery name="getBillbacks" datasource="#application.datasource#">
		SELECT DISTINCT B.BB_Code AS BB_Code, B.Billback_ID
		FROM OPB_Detail OPBD
		INNER JOIN Billback B
		ON B.Billback_ID = OPBD.Billback_ID
		WHERE OPBD.OPB_Header_ID = #qHeaderInfo.OPB_Header_ID#
	</cfquery>

<!--- INSERT DOCUMENTS---->
<cfif len(arguments.stForm.Doc_ID)>
<cfloop query="getBillbacks">
	<cfloop list="#arguments.stForm.Doc_ID#" index="Doc_ID" delimiters=",">
		<cfquery name="insertDocs" datasource="#application.datasource#">
			INSERT INTO Contract_Attachments (	Billback_ID,	Doc_ID )
			VALUES	( '#getBillbacks.Billback_ID#',	'#Doc_ID#')
		</cfquery>
	</cfloop>
</cfloop>
</cfif>

	<cfreturn getBillbacks>
</cffunction>

	<cffunction name="getDropdowns" output="false" access="remote" returntype="query" hint="this function will populate add products window drop downs">
		<cfargument name="type" required="true" default="1">
		<cfargument name="contract_main_id" required="false" default="1">

		<cfset userID = replace(request.AccessStructure.user_id,'-','_','ALL')>

		<cfset tableName= '####tmp_OPB_Program_Details_'&userID>

			<cfquery name="qdropdowns" datasource="#application.datasource#" >
				<cfif arguments.type eq 'customerID'>
					SELECT DISTINCT BSA_Foodservice_Customers_ID,  customer_name
					FROM #tableName#
					WHERE contract_main_id = '#arguments.contract_main_id#'
				<cfelseif arguments.type eq 'componentID'>
					SELECT  DISTINCT component_name_id, Component_Name
					FROM #tableName#
					WHERE contract_main_id = '#arguments.contract_main_id#'
				<cfelse>
					SELECT DISTINCT contract_main_id, Program_Number,component_name_id, Component_Name, BSA_Foodservice_Customers_ID,  customer_name
					FROM #tableName#
				</cfif>
			</cfquery>
		<cfreturn qdropdowns>
	</cffunction>

	 <cffunction name="insertNewItems" output="false" access="remote" returntype="any">
	 		<cfargument name="stForm"   required="true" default="" type="any" />

			<cfset userID = replace(request.AccessStructure.user_id,'-','_','ALL')>
			<cfset tableName= '####tmp_OPB_Program_Details_'&userID>

			<cfquery name="qItemInfo" datasource="#application.datasource#">
				SELECT BSA_Foodservice_Items_Master_ID, item, Description, Net_Weight, ISNULL(Case_Count, 0 ) AS Case_Count, ISNULL( Sleeves_per_case, 0) AS Sleeves_per_case
				FROM BSA_Foodservice_Items_Master
				WHERE BSA_Foodservice_Items_Master_ID IN (<cfqueryparam list="yes" value="#arguments.stForm.Items#">)
				AND DELETED = 0
			</cfquery>

		<cfloop query="qItemInfo">
			<cfset Price_CS = 0>

			<cfif appSettings.getPriceListByTemplate()>
				<cfquery name="qGetPriceCS" datasource="#application.datasource#">
						SELECT CAST(CS_Bracket_1 as DECIMAL(20, 4)) AS Price_CS
						FROM contract_main CM
						INNER JOIN  Program_Control_Panel_Options PCPO
						ON PCPO.ProgramControl_Panel_Options_ID = CM.ProgramType_ID
						INNER JOIN Price_List_Detail PL
						ON PL.Price_List_Header_ID = pcpo.Margin_Price_List_Header_ID
						AND	PL.Product_ID = '#qItemInfo.BSA_Foodservice_Items_Master_ID#'
						AND PL.Deleted = 0
						AND	(
								(PCPO.Base_Sales_based_on_Prg_Start_Date = 1 AND CM.Effective_Date_for_Price BETWEEN PL.[Start_Date] AND PL.End_Date)
						OR   (PCPO.Base_Sales_based_on_Prg_Start_Date = 0 AND PL.Active_Code = 'A')
						)
						WHERE CM.contract_main_id = #arguments.stForm.contract_main_id#
				</cfquery>
				<cfset Price_CS = '#qGetPriceCS.Price_CS#'>
			<cfelse>

				<cfquery name="qGMPriceCS" datasource="#application.datasource#">
					SELECT CAST(GM.CS_DEL_Price as DECIMAL(20,4)) AS Price_CS
					FROM Gross_Margin GM
					WHERE GM.Customer_ID = '#arguments.stForm.customer_ID#'
					AND GM.Product_ID = '#qItemInfo.BSA_Foodservice_Items_Master_ID#'
					AND GM.Deleted = 0
				</cfquery>
				<cfset Price_CS = '#qGMPriceCS.Price_CS#'>

				<cfif ! len(Price_CS)>
					<cfquery name="qIMPriceCS" datasource="#application.datasource#">
						SELECT CAST(imt.ITEM_DEL_BASE_PRICE as DECIMAL(20,4)) AS Price_CS
						FROM ITEM_MARGIN_TARGETS IMT
						WHERE IMT.Product_ID =  '#qItemInfo.BSA_Foodservice_Items_Master_ID#'
						AND IMT.Deleted = 0
					</cfquery>
					<cfset Price_CS = '#qIMPriceCS.Price_CS#'>
				</cfif>
			</cfif>
			<cfif ! len(Price_CS)>
				<cfset Price_CS = 0>
			</cfif>

					<cfquery name="qInsertProgramDetails" datasource="#application.datasource#">
				 		INSERT INTO #tableName# (
								Planner_Number,Program_Number,Program_Title,Customer_ID,Customer_Name,Delivery_Start_Date,Delivery_End_Date, Item_Number,Item_Description
							,Discount_Type,Component_Name, Program_Rate, Rebate_UOM, Accrued, Settled, Balance
							,Contract_Main_ID,BSA_Foodservice_Customers_ID,BSA_Foodservice_Items_Master_ID
							,BSA_Operator_ID,Discount_Type_ID,Component_Name_ID,Component_Paid_To,Net_Weight,Rebate_UOM_ID
							,Program_Count,Volume, Volume_UOM, Extended_Amount, Operator_ID, Operator_Name
							,Case_Count, Sleeves_per_case, Detail_Count, Price_CS, New_Item
				 			)
				 		SELECT  TOP 1 	Planner_Number,Program_Number,Program_Title,Customer_ID,Customer_Name,Delivery_Start_Date,Delivery_End_Date,   '#qItemInfo.item#' AS Item_Number, '#qItemInfo.Description#' AS Item_Description
							,Discount_Type,Component_Name,'0.0000' AS Program_Rate, Rebate_UOM, '0.0000' AS Accrued, '0.0000' AS Settled, '0.0000' AS Balance
							,Contract_Main_ID, BSA_Foodservice_Customers_ID, '#qItemInfo.BSA_Foodservice_Items_Master_ID#' AS BSA_Foodservice_Items_Master_ID
							,BSA_Operator_ID,Discount_Type_ID,Component_Name_ID,Component_Paid_To, '#qItemInfo.Net_Weight#' AS Net_Weight, Rebate_UOM_ID
							,Program_Count,	'0.0000' AS Volume, Volume_UOM, '0.0000' AS Extended_Amount, Operator_ID, Operator_Name
							,#qItemInfo.Case_Count# AS Case_Count,#qItemInfo.Sleeves_per_case# AS Sleeves_per_case, Detail_Count, #Price_CS#, 1 AS New_Item
							FROM #tableName#
							WHERE Contract_Main_ID = #arguments.stForm.contract_main_id#
							AND Component_Name_ID = #arguments.stForm.Component_Name_ID#
							AND BSA_Foodservice_Customers_ID = '#arguments.stForm.Customer_ID#'
							----AND BSA_Foodservice_Items_Master_ID <> '#qItemInfo.BSA_Foodservice_Items_Master_ID#'
					</cfquery>
		</cfloop>

			<cfreturn 1>
	 </cffunction>

	 <cffunction name="getNewItems" output="false" access="remote" returntype="any">

	 		<cfset userID = replace(request.AccessStructure.user_id,'-','_','ALL')>
			<cfset tableName= '####tmp_OPB_Program_Details_'&userID>

			<cfquery name="qGetNewItems" datasource="#application.datasource#">
				SELECT   Planner_Number , Program_Number, Program_Title, Customer_ID,Customer_Name,Delivery_Start_Date
											,Delivery_End_Date,Item_Number,Item_Description,Discount_Type,Component_Name,Program_Rate
											,Rebate_UOM,Volume,Volume_UOM,Extended_Amount,Operator_ID,Accrued,Settled,Balance,BSA_Foodservice_Customers_ID
											,BSA_Foodservice_Items_Master_ID,Discount_Type_ID,Component_Paid_To,Rebate_UOM_ID,Component_Name_ID
											,Program_Count,Detail_Count,Net_Weight,Sleeves_Per_case,Case_Count,Price_CS,Contract_Main_ID,Operator_Name
				FROM #tableName#
				WHERE New_Item = 1
			</cfquery>

			<cfreturn qGetNewItems>
	 </cffunction>

	 <cffunction name="getOperators" output="false" access="remote" returntype="any">
	 	<cfargument name="contract_main_id" required="true" default="" type="numeric" />
	 	<cfargument name="search_string" required="true" default="" type="any" />

		<cfset LegacyIdOn = application.returned_customer_setting.operator_legacy_id_on>

			<cfquery name="qOperators" datasource="#application.datasource#" >
				SELECT O.Operator_Name, <cfif LegacyIdOn> O.Legacy_ID<cfelse> O.BSA_Operator_ID </cfif>  AS Operator_ID
				FROM Contract_Operators CO
				INNER JOIN BSA_Operator O
				ON O.BSA_Operator_ID = CO.BSA_Operator_ID
				WHERE CO.Contract_Main_ID = #arguments.contract_main_id#
				AND CO.Deleted = 0
				AND (
					<cfif LegacyIdOn>
					 CAST(O.Legacy_ID AS VARCHAR) = '#arguments.search_string#'
					<cfelse>
					CAST(O.BSA_Operator_ID AS VARCHAR) = '#arguments.search_string#'
					</cfif>
					OR O.Operator_Name = '#arguments.search_string#'
				)
			</cfquery>

			<cfreturn qOperators>
	 </cffunction>

<cffunction name="runDeviations" output="false" access="remote" returntype="any">

	<cfstoredproc datasource="#application.datasource#" procedure="OPB_Run_Deviation">
		<cfprocparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.user_id#" dbvarname="@User_ID">
		<cfprocparam type="out"	 cfsqltype="cf_sql_varchar"	dbvarname="@OUTPUT" variable="qResults">
	</cfstoredproc>

	<cfreturn qResults>

</cffunction>

<cffunction name="getBillbacks" output="false" access="remote" returntype="any">
		<cfargument name="stForm" required="true" default="" type="any" />

		<cfset arguments.stForm.matchToCredit ="false" />

		<cfquery name="clearTempTables" datasource="#application.datasource#">

			IF OBJECT_ID('tempdb..##tmp_customers') IS NOT NULL
			DROP TABLE ##tmp_customers

			IF OBJECT_ID('tempdb..##tmp_operators') IS NOT NULL
			DROP TABLE ##tmp_operators

			IF OBJECT_ID('tempdb..##tmp_items_Info') IS NOT NULL
			DROP TABLE ##tmp_items_Info

			IF OBJECT_ID('tempdb..##tmp_billbacks') IS NOT NULL
			DROP TABLE ##tmp_billbacks

		</cfquery>



	<!---CUSTOMER SEARCH---->
	<cfif len(arguments.stForm.bb_customer_search)>

		<cfquery name="qCustomers" datasource="#application.datasource#">

			SELECT BSA_Foodservice_Customers_ID
			INTO ##tmp_customers
			FROM   BSA_Foodservice_Customers Cust
<!---or_Family F ON F.Family_ID = Cust.Family_ID
			LEFT JOIN Distributor_Buying_Groups BG ON BG.Buying_group_ID = Cust. Buying_group_ID
			LEFT JOIN Distributor_Type DT ON DT.Distributor_Type_ID  = Cust.Distributor_Type_ID
		</cfif>
---->
			WHERE Cust.Ship_To != 'Group'
		<cfif len(arguments.stForm.bb_customer_search)>
		   AND (CUST.Ship_To LIKE '%#arguments.stForm.bb_customer_search#%' OR CUST.Name LIKE '%#arguments.stForm.bb_customer_search#%')
		</cfif>
		<!---
	    <cfif len(arguments.stForm.customer_group_search)>
	       AND (F.Family LIKE '%#arguments.stForm.customer_group_search#%' OR F.Family_Name LIKE '%#arguments.stForm.customer_group_search#%'
	                 OR BG.Buying_Group LIKE '%#arguments.stForm.customer_group_search#%'  OR BG.Buying_Group_Name LIKE '%#arguments.stForm.customer_group_search#%'
					 OR DT.Distributor_Type LIKE '%#arguments.stForm.customer_group_search#%' OR DT.Distributor_Type_Name LIKE '%#arguments.stForm.customer_group_search#%' )
			</cfif>
			--->
		</cfquery>

	</cfif>

	<!---OPERATOR SEARCH--->
	<cfif len(arguments.stForm.bb_Operator_Search)>
		<cfquery name="qCheckOperators" datasource="#application.datasource#">
			SELECT OP.BSA_Operator_ID
			INTO ##tmp_operators
			FROM BSA_Operator OP
			WHERE (OP.Legacy_ID LIKE '%#arguments.stForm.bb_Operator_Search#%' OR OP.Operator_Name LIKE '%#arguments.stForm.bb_Operator_Search#%')
		</cfquery>
	</cfif>

	<!---ITEM SEARCH--->
	<cfif len(arguments.stForm.bb_item_search) OR len(arguments.stForm.bb_item_group_search)>
		<cfquery name="qCheckItems" datasource="#application.datasource#">
			SELECT IM.BSA_Foodservice_Items_Master_ID
			INTO ##tmp_items_Info
			FROM BSA_Foodservice_Items_Master IM

			<cfif len(arguments.stForm.bb_item_group_search)>
				INNER JOIN All_Product_Group_Type_Members GTM ON GTM.BSA_Foodservice_Items_Master_ID = IM.BSA_Foodservice_Items_Master_ID
				INNER JOIN All_Product_Group_Type GT ON GT.Group_GUID = GTM.Product_Group_ID
				AND GT.Product_Group_Level_ID < 200
			</cfif>
			WHERE IM.Item is NOT NULL
			<cfif len(arguments.stForm.bb_item_search)>
			AND IM.Item LIKE '%#arguments.stForm.bb_item_search#%' OR IM.Description LIKE '%#arguments.stForm.bb_item_search#%'
			</cfif>
			<cfif len(arguments.stForm.bb_item_group_search)>
	           AND (GT.Group_Number LIKE '%#arguments.stForm.bb_item_group_search#%' OR GT.Group_Desc LIKE '%#arguments.stForm.bb_item_group_search#%')
			</cfif>
		</cfquery>
	</cfif>

	<!---PROGRAM TEMPLATE SEARCH --->
	<cfif len(arguments.stForm.bb_template_list)>
		<cfset selectedTemplates = ListQualify(arguments.stForm.bb_template_list,"'",",","CHAR")>
	</cfif>

	<!---PLANNER TEMPLATES SEARCH
	<cfif len(arguments.stForm.planner_template_list)>
		<cfset selectedPlannersTemplates = ListQualify(arguments.stForm.planner_template_list,"'",",","CHAR")>
	</cfif>
	---->

		<cfset isRebate = 0>
		<cfset RebateComponents = ''>

		<cfset isLumpSum= 0>
		<cfset LumpSumComponents = ''>

		<cfset isGrowth = 0>
		<cfset GrowthComponents = ''>

		<cfset isFixed = 0>
		<cfset FixedComponents = ''>

	<!---COMPONENT SEARCH
	<cfif len(arguments.stForm.discount_type)>
		<cfloop list="#arguments.stForm.discount_type#" index="Components" >
			<cfif Components EQ 'R'>
				<cfset isRebate = 1>
			</cfif>

			<cfif Components EQ 'L'>
				<cfset isLumpSum= 1>
			</cfif>

			<cfif Components EQ 'G'>
				<cfset isGrowth = 1>
			</cfif>

			<cfif Components EQ 'F'>
				<cfset isFixed = 1>
			</cfif>
		</cfloop>
	</cfif>--->

	<!---COMPONENT LIST SEARCH--->
	<cfif len(arguments.stForm.bb_component_list)>
		<cfloop list="#arguments.stForm.bb_component_list#" index="Components" >
			<cfif ListFind(Components,"R")>
				<cfset isRebate = 1>
				<cfset RebateComponents = listappend(RebateComponents, RemoveChars(Components,1,2))>
			</cfif>

			<cfif ListFind(Components,"L")>
				<cfset isLumpSum= 1>
				<cfset LumpSumComponents = listappend(LumpSumComponents, RemoveChars(Components,1,2))>
			</cfif>

			<cfif ListFind(Components,"G")>
				<cfset isGrowth = 1>
				<cfset GrowthComponents = listappend(GrowthComponents, RemoveChars(Components,1,2))>
			</cfif>

			<cfif ListFind(Components,"F")>
				<cfset isFixed = 1>
				<cfset FixedComponents = listappend(FixedComponents, RemoveChars(Components,1,2))>
			</cfif>
		</cfloop>

	</cfif>

	<!---PAID TO SEARCH--->
	<cfif len(arguments.stForm.bb_paid_to)>
		<cfset isRebate = 1>
		<cfset isLumpSum= 1>
		<cfset isGrowth = 1>
		<cfset isFixed = 1>
	</cfif>

	<cfquery name="qDumpBillbacks" datasource="#application.datasource#">

			<cfif arguments.stForm.match_deduction>
    			DECLARE @Tmp_BB_Parent_ID_List table( 	BB_Parent_ID uniqueidentifier NOT NULL PRIMARY KEY )
					INSERT INTO @Tmp_BB_Parent_ID_List(BB_Parent_ID)
					SELECT	DISTINCT BB_Parent_ID
					FROM	Billback
					WHERE	Deleted = 0
					AND		BB_Parent_ID IS NOT NULL
			</cfif>

		SELECT B.Billback_ID, B.BB_Code AS Payable_ID, BS.BB_Status_Description AS BB_Status, BS.BB_Status_Abbreviation AS BB_Stauts_Abb
		--B.BB_Start_Date AS Delivery_start_date, B.BB_End_Date AS Delivery_end_date, B.BB_Date
		,	convert(varchar(10), B.BB_Start_Date, 101)  AS Delivery_start_date
		, convert(varchar(10), B.BB_End_Date, 101) AS Delivery_end_date
		, convert(varchar(10), B.BB_Date, 101) AS BB_Date
		, B.BB_Reference, Analyst.Name_First+' '+Analyst.Name_Last AS Analyst, ISNULL(B.Auto_Deviated_Amt, 0) AS Deviated_Amount, BCM.vchBillback_Closing_Method_Desc AS Closing_Method, BCM.Abbreviation AS Closing_Method_Abb
		, BPT.BB_Payee_Description AS Paid_To, B.Billback_Payee_Type_ID AS Payee_Type, BA.BB_Is_Locked AS Locked, ISNULL(BB_Approved.Paid_Amount, 0) AS Approved_Amount, B.BB_Amount AS Claimed_Amount, CAST('' AS varchar(50)) AS Payee_ID
		, CAST('' AS varchar(250)) AS Payee_Name , CAST('' AS varchar(50)) AS Payee_GUID, Auto_Billback, 0 AS BB_Loc_Duplicate
		<!---, ISNULL(B.BB_Loc_Duplicate, 0) AS BB_Loc_Duplicate--->
		, CASE WHEN (
								(B.Billback_Status_ID = 2 OR (B.Billback_Status_ID = 3 AND #appSettings.getUpdate_BB_Approve_Amt()# = 1))
								AND ISNULL(DD_Closure_Sent_on,'') = ''
								AND #appSettings.getFlex_BB_Deviation()# = 1
								AND Auto_Billback = 0
							)
							THEN 1
							ELSE 0 END AS Deviation
		, REPLACE(Original_BB_Code, 'BB-', '') AS BBCode
		, 0 AS Doc_Count
			, CAST(replace(convert(varchar, B.BB_Start_Date,101),'/','') AS INT) AS Converted_Start_Date
			, CAST(replace(convert(varchar, B.BB_End_Date,101),'/','') AS INT) AS Converted_End_Date
			, CAST(replace(convert(varchar, B.BB_Date,101),'/','') AS INT) AS Converted_BB_Date
INTO ##tmp_billbacks

		FROM Billback B

		INNER JOIN Billback_Status BS
		ON BS.Billback_Status_ID = B.Billback_Status_ID

		LEFT JOIN _Users Analyst
		ON Analyst.User_ID = B.Analyst_User_ID

		INNER JOIN Billback_Closing_Methods BCM
		ON BCM.iBillback_Closing_Method_ID = B.BB_Closing_Method

		INNER JOIN Billback_Payee_Type BPT
		ON BPT.Billback_Payee_Type_ID = B.Billback_Payee_Type_ID

		INNER JOIN Billback_Allied BA
		ON BA.Billback_id = B.Billback_ID

		LEFT JOIN BB_Approved
		ON BB_Approved.Billback_ID = B.Billback_ID

			INNER JOIN  Billback_Distributor BD
			ON 		BD.Billback_ID = B.Billback_ID
			AND 	BD.Deleted =0
		<cfif len(arguments.stForm.bb_customer_search)>
			INNER JOIN ##tmp_customers Cust
			ON 		BD.Distributor_ID = Cust.BSA_Foodservice_Customers_ID
		</cfif>

		<cfif len(arguments.stForm.bb_Operator_Search)>
			INNER JOIN  Billback_Operator BO
			ON	 	BO.Billback_ID = B.Billback_ID
			AND		BO.Deleted =0

			INNER JOIN ##tmp_operators OP
			ON 		BO.Operator_ID = OP.BSA_Operator_ID
		</cfif>

		<cfif len(arguments.stForm.bb_item_search) OR len(arguments.stForm.bb_item_group_search)>
			INNER JOIN  Billback_Product BP
			ON	 	BP.Billback_ID = B.Billback_ID
			AND		BP.Deleted =0

			INNER JOIN ##tmp_items_Info item
			ON 		item.Product_ID = BP.Product_ID
		</cfif>

		<cfif len(arguments.stForm.bb_program_search) OR len(arguments.stForm.bb_template_list)>
			INNER JOIN Billback_Program BP
			ON BP.Billback_ID = B.Billback_ID
			AND BP.Deleted = 0

			INNER JOIN Contract_Main CM
			ON CM.Contract_Main_ID = BP.Program_ID
			AND CM.Deleted = 0

			<cfif len(arguments.stForm.bb_program_search)>
				AND (CM.Contract_Number like '%#arguments.stForm.bb_program_search#%' OR CM.Contract_Title like '%#arguments.stForm.bb_program_search#%')
			</cfif>

		    <cfif len(arguments.stForm.bb_template_list)>
				AND CM.ProgramType_ID IN (<cfqueryparam list="yes" value="#selectedTemplates#">)
		    </cfif>
<!----
		 <cfif len(arguments.stForm.planner_template_list)>
				INNER JOIN Planners P
				ON P.Planner_ID = CM.Planner_ID
				AND P.Planner_Template_ID IN (#PreserveSingleQuotes(selectedPlannersTemplates)#)
			</cfif>
---->
		</cfif>

		LEFT JOIN BSA_Foodservice_Customers
		ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = BD.Distributor_ID

		LEFT JOIN Vendor_Master VM
		ON VM.vendor_Master_Id = BD.Distributor_ID

		LEFT JOIN 	Distributor_Bill_To
		ON Distributor_Bill_To.Distributor_Bill_To_ID = BSA_Foodservice_Customers.Distributor_Bill_To_ID

		WHERE B.BB_Associated_To_DD = 0
		AND B.BB_Payment_Request_Sent  = 0
		AND B.Deleted = 0

<cfif arguments.stForm.match_deduction>
		AND B.BB_Closing_Method = '2'
		AND B.Billback_Status_ID = 3

		AND NOT EXISTS (
				SELECT ParentCheck.BB_Parent_ID
		    FROM @Tmp_BB_Parent_ID_List ParentCheck
		    WHERE ParentCheck.BB_Parent_ID =  B.Billback_ID
		)
</cfif>

	<cfif len(arguments.stForm.payable_search)>
		<cfif arguments.stForm.fromCreate>
			AND B.BB_Code IN	(#listQualify(arguments.stForm.payable_search,"'")#)
		<cfelse>
			AND B.BB_Code like '%#arguments.stForm.payable_search#%'
		</cfif>
	</cfif>

	<cfif len(arguments.stForm.billback_search)>
		AND B.BB_Reference LIKE '%#arguments.stForm.billback_search#%'
	</cfif>

	<cfif len(arguments.stForm.bb_status_list)>
		AND B.Billback_Status_ID IN (#PreserveSingleQuotes(arguments.stForm.bb_status_list)#)
	</cfif>

	<cfif len(arguments.stForm.bb_closing_method)>
		AND B.BB_Closing_Method IN (#PreserveSingleQuotes(arguments.stForm.bb_closing_method)#)
	</cfif>

	<cfif len(arguments.stForm.billback_analyst)>
		AND B.Analyst_User_ID IN (#PreserveSingleQuotes(arguments.stForm.billback_analyst)#)
	</cfif>

<!--- SEARCH FILTERS SECTION ---->

<cfif len(arguments.stForm.FILTERworkItemamount)>
		<cfif appSettings.getDDCloseWithEqualBBAmt()>
			<cfif len(arguments.stForm.FILTERddAmount)>
				<cfif appSettings.getMultiple_BB_Per_Deduction()>
					AND Round(BB_Approved.Paid_Amount,2) <= '#arguments.stForm.FILTERddAmount#'
				<cfelse>
					AND Round(BB_Approved.Paid_Amount,2) = '#arguments.stForm.FILTERddAmount#'
				</cfif>
			</cfif>
			<!--- For clients like Heinz --->
		<cfelse>
			<cfif arguments.stForm.matchToCredit>
				AND BB_Approved.Paid_Amount <= #arguments.selecteditemvalue#
			<cfelse>
				<cfif len(arguments.stForm.FILTERddAmount)>
					AND	BB_Approved.Paid_Amount <= '#arguments.stForm.FILTERddAmount#'
				</cfif>
			</cfif>
		</cfif>
	</cfif>

	<cfif len(arguments.stForm.MC_Shr_Ship_to)>
		AND
		(
		BSA_Foodservice_Customers.Shr_Ship_To = '#arguments.stForm.MC_Shr_Ship_To#'
		OR BSA_Foodservice_Customers.Name LIKE '%#TRIM(arguments.stForm.MC_Distributor_Name)#%'
		OR VM.Vendor_ID = '#arguments.stForm.MC_Shr_Ship_To#'
		OR VM.Vendor_Name LIKE '%#TRIM(arguments.stForm.MC_Distributor_Name)#%'
		<cfif arguments.stForm.MC_Shr_Bill_To NEQ "">
			OR VM.Vendor_ID = '#arguments.stForm.MC_Shr_Bill_To#'
			OR VM.Vendor_Name LIKE '%#TRIM(arguments.stForm.MC_Bill_To_Name)#%'
		</cfif>
		)
	</cfif>

	<cfif len(arguments.stForm.MC_Shr_Bill_To)>
		<cfif (appSettings.get_Setting('Deduction_match_using_bill_to_vendor') EQ '1')>
				AND ( VM2.Vendor_ID = '#arguments.stForm.MC_Shr_Bill_To#'
				OR VM2.Vendor_Name LIKE '%#TRIM(arguments.stForm.MC_Bill_To_Name)#%'
				OR VM.Vendor_ID = '#arguments.stForm.MC_Shr_Bill_To#'
				OR VM.Vendor_Name LIKE '%#TRIM(arguments.stForm.MC_Bill_To_Name)#%'
				)
		<cfelse>
				AND ( Distributor_Bill_To.Shr_Bill_To = '#arguments.stForm.MC_Shr_Bill_To#'
				OR Distributor_Bill_To.Name LIKE '%#TRIM(arguments.stForm.MC_Bill_To_Name)#%'
				OR VM.Vendor_ID = '#arguments.stForm.MC_Shr_Bill_To#'
				OR VM.Vendor_Name LIKE '%#TRIM(arguments.stForm.MC_Bill_To_Name)#%'
				<cfif arguments.stForm.MC_Shr_Ship_to NEQ "">
						OR VM.Vendor_ID = '#arguments.stForm.MC_Shr_Ship_To#'
						OR VM.Vendor_Name LIKE '%#TRIM(arguments.stForm.MC_Distributor_Name)#%'
				</cfif>
				)
		</cfif>
	</cfif>

	<cfif len(arguments.stForm.FILTERkeyword)>
		AND ( (LOWER(BSA_Foodservice_Customers.name) LIKE '%#lcase(arguments.stForm.FILTERkeyword)#%' AND BSA_Foodservice_Customers.name IS NOT NULL)
		OR (LOWER(BSA_Foodservice_Customers.shr_ship_to) LIKE '%#lcase(arguments.stForm.FILTERkeyword)#%' AND BSA_Foodservice_Customers.shr_ship_to IS NOT NULL)
		OR (LOWER(B.referencenum)	LIKE '%#lcase(arguments.stForm.FILTERkeyword)#%' AND B.referencenum IS NOT NULL)
		OR (LOWER(B.bb_reference)	LIKE '%#lcase(arguments.stForm.FILTERkeyword)#%' AND B.bb_reference IS NOT NULL)
		)
	</cfif>

<cfif len(arguments.stForm.FILTERremainingBalance) AND len(arguments.stForm.FILTERremainingAmt)>
	AND Round(BB_Approved.Approved_Amount,2) <= '#arguments.stForm.FILTERremainingAmt#'
</cfif>

<cfif len(arguments.stForm.FILTERrefnumber) AND len(arguments.stForm.FILTERreferencenumber)>
			AND (
									(B.referenceNum LIKE '%#arguments.stForm.FILTERreferencenumber#%' AND B.referenceNum IS NOT NULL)
									OR (B.bb_reference	LIKE '%#arguments.stForm.FILTERreferencenumber#%' AND B.bb_reference IS NOT NULL)
							)
	</cfif>

	<cfif arguments.stForm.FILTERtype EQ 2 AND len(arguments.stForm.MC_Distributor_Family_ID) >
		AND BSA_Foodservice_Customers.Family_ID = '#arguments.stForm.MC_Distributor_Family_ID#'
	</cfif>

<!--- SEARCH FILTERS SECTION END ---->
<!---
	<cfif len(arguments.stForm.reference_search)>
		AND B.BB_Reference like '%#arguments.stForm.reference_search#%'
	</cfif>
---->
<cfif len(arguments.stForm.bb_component_list) OR len(arguments.stForm.bb_paid_to)>
			(1=2
			<cfif isRebate>
				OR EXISTS (
					SELECT 1
					FROM Billback_Program_Rebate_Component BPRC
					INNER JOIN Program_Rebates_Component PRC
					ON PRC.Program_Rebates_Component_ID = BPRC.Program_Rebates_Component_ID
					WHERE BPRC.Billback_ID = BP.Billback_ID
					<cfif len(RebateComponents)>
					AND 	BPRC.Program_Rebates_Component_Name_ID IN (#PreserveSingleQuotes(RebateComponents)#)
					</cfif>
					<cfif len(arguments.stForm.bb_paid_to)>
					AND 	PRC.Component_Paid_To IN (#PreserveSingleQuotes(arguments.stForm.bb_paid_to)#)
					</cfif>
				)
			</cfif>

			<cfif isLumpSum>
				OR EXISTS (
					SELECT 1
					FROM Billback_Program_Lumpsum_Component BPLC
					INNER JOIN Program_Lump_Sums PLC
					ON BPLC.Billback_ID = BP.Billback_ID
					AND PLC.Program_Lump_Sum_ID = BPLC.Program_Lump_Sum_ID
					WHERE BPLC.Billback_Program_ID = BP.Billback_Program_ID
					<cfif len(LumpSumComponents)>
					AND 	PLC.Program_Lump_Sum_Name_ID IN (#PreserveSingleQuotes(LumpSumComponents)#)
					</cfif>
					<cfif len(arguments.stForm.bb_paid_to)>
					AND 	PLC.Component_Paid_To IN (#PreserveSingleQuotes(arguments.stForm.bb_paid_to)#)
					</cfif>
				)
			</cfif>

			<cfif isGrowth>
				OR EXISTS (
					SELECT	1
					FROM	Program_Growth_Components PGC
					WHERE 	 PGC.Program_ID = BP.Program_ID
					<cfif len(GrowthComponents)>
					AND 	PGC.Growth_Component_Name_ID IN (#PreserveSingleQuotes(GrowthComponents)#)
					</cfif>
					<cfif len(arguments.stForm.bb_paid_to)>
					AND 	PGC.Component_Paid_To IN (#PreserveSingleQuotes(arguments.stForm.bb_paid_to)#)
					</cfif>
				)
			</cfif>

			<cfif isFixed>
				OR EXISTS (
					SELECT	1
					FROM	Program_Fixed_Component PFC
					WHERE	 PFC.Program_ID = BP.Program_ID
					<cfif len(FixedComponents)>
					AND 	PFC.Program_Fixed_Component_Name_ID IN (#PreserveSingleQuotes(FixedComponents)#)
					</cfif>
					<cfif len(arguments.stForm.bb_paid_to)>
					AND 	PFC.Fixed_Component_Paid_To IN (#PreserveSingleQuotes(arguments.stForm.bb_paid_to)#)
					</cfif>
				)
			</cfif>
			)
		</cfif>

<!--- UPDATE PAYEE ---->

	UPDATE ##tmp_Billbacks
	SET Payee_ID = COALESCE(O.Legacy_ID, cast(O.BSA_Operator_ID as char(50)))
			 ,Payee_Name = O.Operator_Name
			 ,Payee_GUID = O.BSA_Operator_ID
	FROM Billback_Operator BO
	INNER JOIN BSA_Operator O
	ON O.BSA_Operator_ID = BO.Operator_ID
	INNER JOIN ##tmp_Billbacks B
	ON B.Billback_ID = BO.Billback_ID
	WHERE BO.Deleted = 0
	AND B.Payee_Type = 2

	UPDATE ##tmp_Billbacks
	SET Payee_ID = CASE WHEN B.Auto_Billback = 1 THEN
										--ISNULL(VM.vendor_ID, <cfif appSettings.get_Setting('Display_Distributor_ID') eq '1'>C.Shr_Ship_To<cfelse>C.Ship_To</cfif>)
										ISNULL(VM.vendor_ID, C.Shr_Ship_To)
									ELSE
									C.Ship_To
									END
		,Payee_Name =
							CASE WHEN B.Auto_Billback = 1 THEN
										ISNULL(Vendor_Name,C.Name)
									ELSE
										C.Name
									END
		,Payee_GUID = C.BSA_Foodservice_Customers_ID
	FROM Billback_Distributor BD
	INNER JOIN ##tmp_Billbacks B
	ON B.Billback_ID = BD.Billback_ID
	LEFT JOIN BSA_Foodservice_Customers C
	ON C.BSA_Foodservice_Customers_ID = BD.Distributor_ID
	LEFT JOIN  Vendor_Master VM
	ON  VM.Vendor_master_ID = BD.Distributor_ID
	AND VM.Deleted = 0
	WHERE BD.Deleted = 0
	AND B.Payee_Type = 1


	UPDATE ##tmp_Billbacks
	SET Payee_ID =BB_Broker_Shared
			, Payee_Name = BFB.Broker_Name
			,Payee_GUID = BFB.BSA_Foodservice_Brokers_ID
	FROM Billback_Broker BB
	INNER JOIN ##tmp_Billbacks B
	ON B.Billback_ID = BB.Billback_ID
	INNER JOIN BSA_Foodservice_Brokers BFB
	ON BFB.BSA_Foodservice_Brokers_ID = BB.Broker_ID
	WHERE BB.Deleted = 0

	UPDATE ##tmp_Billbacks
	SET  Doc_Count = (SELECT count(*) FROM Contract_Attachments WHERE Contract_Attachments.Billback_ID = B.Billback_ID)
	FROM ##tmp_Billbacks B

</cfquery>

<cfquery name="qGetBillbacks" datasource="#application.datasource#">
	SELECT *
	FROM ##tmp_Billbacks
</cfquery>

<cfreturn qGetBillbacks>
</cffunction>

<cffunction name="ClearValues" output="false" access="remote" returntype="any">
	<cfargument name="ID" required="true" type="numeric">

		 	<cfset userID = replace(request.AccessStructure.user_id,'-','_','ALL')>
			<cfset tableName= '####tmp_OPB_Program_Details_'&userID>

	<cfquery name="qClearValues" datasource="#application.datasource#">

		IF EXISTS (
		    SELECT  *
		    FROM tempdb.dbo.sysobjects o
		    WHERE o.xtype in ('U')
		    AND o.id = object_id(N'tempdb..#tableName#')
		)

		UPDATE  #tableName#
		SET  Volume = '0.0000'
					,Volume_UOM = CASE WHEN Rebate_UOM_ID = 3 THEN 'CS' ELSE Rebate_UOM END
					,Volume_CS= NULL
					,Extended_Amount = '0.0000'
					,Converted_Volume= NULL
					,Converted_Volume_UOM= NULL
		<cfif arguments.ID NEQ 0>
		WHERE RowID = #arguments.ID#
		<cfelse>
		WHERE Volume != '0.0000'
		</cfif>


		select sum(Volume) AS claimedQty, sum(Extended_Amount) AS claimedAmt
		from #tableName#

	</cfquery>
	<cfreturn qClearValues>
</cffunction>

	<cffunction name="getReasonCodes" access="remote" 	returntype="any"  output="false" 	displayname="getReasonCodes">

		<cfargument name="ID" required="true" type="string">

		<cfset DDMgr = createObject("Component","components.Deduction.DeductionManager").init()>
		<cfset workItemInfo = DDMgr.getDeduction(arguments.ID)>

		<cfquery name="AutoCloseReason" datasource="#application.datasource#">
			SELECT DD_Reason_Code_ID
			FROM DD_Auto_Close
		</cfquery>

		<cfquery name="GetReasonCodes" datasource="#application.datasource#">
			SELECT DD_Reason_Code_ID, DD_Reason_Code_Description
			FROM DD_Reason_Code
			WHERE Deleted = 0 AND Display_In IN (1,3)
			<CFIF AutoCloseReason.RecordCount GT 0 AND AutoCloseReason.DD_Reason_Code_ID NEQ "">
				AND DD_Reason_Code_ID != #AutoCloseReason.DD_Reason_Code_ID#
			</CFIF>
			<CFIF appSettings.getRestrict_DD_Reason_Code_By_Closing_method()>
				<CFIF len(trim(workItemInfo.DD_Closure_ID)) GT 0 AND workItemInfo.DD_Closure_Type IS 1>
					AND Closing_Method = 1
				<CFELSEIF len(trim(workItemInfo.DD_Closure_ID)) GT 0 AND workItemInfo.DD_Closure_Type EQ 5>
					AND Closing_Method = 2
				<CFELSEIF (len(workItemInfo.Is_Last_Status_Rebill) GT 0 AND workItemInfo.Is_Last_Status_Rebill)>
					AND Closing_Method = 4
				<CFELSEIF (len(workItemInfo.Is_Write_Off) GT 0 AND workItemInfo.Is_Write_Off)>
					AND Closing_Method = 3
				<CFELSEIF (len(workItemInfo.DD_Rejected) GT 0 AND workItemInfo.DD_Rejected)>
					AND Closing_Method = 5
				</CFIF>
			</CFIF>
			ORDER BY DD_Reason_Code_Description
		</cfquery>

		<cfreturn GetReasonCodes>

	</cffunction>

<cffunction name="getRebills" access="remote" returntype="any" output="false">

<cfquery name="qGetRebills" datasource="#application.datasource#">
	SELECT DD_Rebill_Package_Hdr_ID,Rebill_Package_Title
	FROM DD_Rebill_Package_Hdr
	WHERE Deleted = 0 AND Active = 1
	ORDER BY Rebill_Package_Title
</cfquery>

<cfreturn qGetRebills>

</cffunction>

<cffunction name="getDefaultClass" access="remote" returntype="any" output="false">
		<cfargument name="ID" required="true" type="string">

		<cfquery name="SavedClass" datasource="#application.datasource#">
			SELECT DD_Classification_ID
			FROM Deductions
			WHERE Deduction_ID = '#arguments.ID#'
			AND (DD_Classification_ID  is not NULL AND DD_Classification_ID <> 0)
		</cfquery>

		<cfquery name="getAllClass" datasource="#application.datasource#">
			SELECT *
			FROM DD_Classification
			WHERE Deleted = 0
		<cfif SavedClass.recordCount and SavedClass.DD_Classification_ID neq "">
			OR DD_Classification_ID = #SavedClass.DD_Classification_ID#
		</cfif>
			ORDER BY DD_Classification_Desc
		</cfquery>

	<cfset useLakebaseForqGetDefaultClass = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getallclass")>
<cfif useLakebaseForqGetDefaultClass>
	<cftry>
		<cfset qGetDefaultClass = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getallclass", {
				"is_default" = "eq.1",
				"select" = "dd_classification_id"
			}), "dd_classification_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDefaultClass = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDefaultClass>
<cfquery name="qGetDefaultClass" dbtype="query">
		SELECT DD_Classification_ID
		FROM getAllClass
		WHERE IS_Default = 1
	</cfquery>
</cfif>

<cfreturn qGetDefaultClass>

</cffunction>

<cffunction name="getAllClasses" access="remote" returntype="any" output="false">
		<cfargument name="ID" required="true" type="string">

		<cfquery name="SavedClass" datasource="#application.datasource#">
			SELECT DD_Classification_ID
			FROM Deductions
			WHERE Deduction_ID = '#arguments.ID#'
			AND (DD_Classification_ID  is not NULL AND DD_Classification_ID <> 0)
		</cfquery>

		<cfquery name="qGetAllClass" datasource="#application.datasource#">
			SELECT DD_Classification_ID, DD_Classification_Desc
			FROM DD_Classification
			WHERE Deleted = 0
		<cfif SavedClass.recordCount and SavedClass.DD_Classification_ID neq "">
			OR DD_Classification_ID = #SavedClass.DD_Classification_ID#
		</cfif>
			ORDER BY DD_Classification_Desc
		</cfquery>

		<cfreturn qGetAllClass>

</cffunction>

<cffunction name="getDocIds" access="remote" returntype="any" output="false">
	<cfargument name="count" required="true">
	<cfset docInfo = ArrayNew(1)>

	<cfset useLakebaseForqGetAllDocIds = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("document_details")>
<cfif useLakebaseForqGetAllDocIds>
	<cftry>
		<cfset qGetAllDocIds = application.oLakebase.toQuery(
			application.oLakebase.selectRows("document_details", {
				"uploaded_by" = "eq.#request.AccessStructure.user_id#",
				"order" = "uploaded_date.desc",
				"select" = "count# doc_id,doc_uni_name"
			}), "count# doc_id,doc_uni_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetAllDocIds = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetAllDocIds>
<cfquery name="qGetAllDocIds" datasource="#application.datasource#">
		SELECT TOP #arguments.count# Doc_ID,Doc_Uni_Name
		FROM Document_Details
		WHERE  Uploaded_By = '#request.AccessStructure.user_id#'
		ORDER BY Uploaded_Date DESC
	</cfquery>
</cfif>

	<cfset ArrayAppend(docInfo, valueList(qGetAllDocIds.Doc_ID))>
	<cfset ArrayAppend(docInfo, valueList(qGetAllDocIds.Doc_Uni_Name))>

	<cfreturn docInfo>
</cffunction>

<cffunction name="getDistributorInfo" access="remote" returntype="any" output="false">
	<cfargument name="type" required="true">
	<cfargument name="ID" required="true">

	<cfquery name="qGetDistInfo" datasource="#application.datasource#">
	<cfif arguments.type EQ 'BB'>
		SELECT
			CASE WHEN BSAFC.Shr_Ship_To IS NULL THEN VM.Vendor_ID ELSE BSAFC.Shr_Ship_To END AS Payee_ID,
			CASE WHEN BSAFC.Name IS NULL THEN VM.Vendor_Name ELSE BSAFC.Name END AS Payee_Name,
			CASE WHEN DBT.Name IS NULL THEN VM.Vendor_Name ELSE DBT.Name END AS Bill_To_Name,
			CASE WHEN DBT.Shr_Bill_To IS NULL THEN VM.Vendor_ID ELSE DBT.Shr_Bill_To END As Shr_Bill_To,
			VM2.Vendor_ID AS MC_Vendor_ID,
			VM2.Vendor_Name AS MC_Vendor_Name,
			BSAFC.BSA_Foodservice_Customers_ID AS Dist_ID

			FROM Billback BB
			LEFT JOIN BB_Approved BBA
			ON BBA.Billback_ID = BB.Billback_ID
			LEFT JOIN(Billback_Distributor BBD
						LEFT JOIN BSA_Foodservice_Customers BSAFC
						ON (BBD.Distributor_ID = BSAFC.BSA_Foodservice_Customers_ID)
			)
			ON ( (BBD.Billback_ID = BB.Billback_ID)
			AND ( (BB.Billback_Payee_Type_ID = 1) OR (BB.Billback_Payee_Type_ID = 5))
			AND (BBD.Deleted = 0)
			)

			LEFT JOIN Distributor_Bill_To DBT
			ON BSAFC.Distributor_Bill_To_ID = DBT.Distributor_Bill_To_ID
			LEFT JOIN Vendor_Master VM
			ON BBD.Distributor_ID = VM.Vendor_Master_ID
			AND BBD.Deleted = 0
			LEFT JOIN Vendor_Master VM2
			ON BBA.Vendor_Master_ID = VM2.Vendor_Master_ID
			WHERE BB.billback_id = <cfqueryparam value="#arguments.ID#" cfsqltype="cf_sql_varchar">

	<cfelse>
		SELECT	RTRIM(BSA_Foodservice_Customers.Shr_Ship_To) as Shr_Ship_To
									,BSA_Foodservice_Customers.Name
									,Distributor_Bill_To.Name AS BillToName
									,Distributor_Bill_To.Shr_Bill_To
									,' ' AS MC_Vendor_ID
									,' ' AS MC_Vendor_Name
									,BSA_Foodservice_Customers.Family_ID
									,Deductions.DD_Reference
	FROM	Deductions
	LEFT JOIN	_Users
	ON 			_Users.User_ID = Deductions.Analyst_User_ID
	AND			_Users.deleted = 0
	LEFT JOIN	Distributor_Bill_To
	ON 			Distributor_Bill_To.Distributor_Bill_To_ID = Deductions.Distributor_Bill_To_ID
	LEFT JOIN	BSA_Foodservice_Customers
	ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Deductions.Distributor_ID
	WHERE	Deductions.Deduction_ID = <cfqueryparam value="#arguments.ID#" cfsqltype="cf_sql_varchar">
	</cfif>
</cfquery>
	<cfreturn qGetDistInfo>
</cffunction>

<cffunction name="CheckFixedPrice" output="false" access="remote" returntype="any">
		<cfset userID = replace(request.AccessStructure.user_id,'-','_','ALL')>
		<cfset tableName= '####tmp_OPB_Program_Details_'&userID>

		<cfquery name="qGetFixedPriceInfo" datasource="#application.datasource#">
			SELECT *
			FROM #tableName#
			WHERE Discount_Type = 'Fixed Price'
			AND Volume <> 0
			AND Extended_Amount = '0.0000'
		</cfquery>
		<cfreturn ValueList(qGetFixedPriceInfo.Item_Number)>
</cffunction>
</cfcomponent>