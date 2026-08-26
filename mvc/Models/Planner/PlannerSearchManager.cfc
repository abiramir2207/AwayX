<!----------------------------------------------------------------------------------
Name         :	PlannerSearchManager.cfc
Copyright    : 	(c) 2016 Blacksmith Applications, Inc.
Created Date : 	04/028/2016
Created By   : 	KAL
Description  : 	Search Manager for Planners
---------------------------------------------------------------------------------->


<cfcomponent name="PlannerSearchManager" displayname="PlannerSearchManager" hint="Manager for Search Planner Settings">

	<cfscript>
		genSettingsManager    = CreateObject("component", "components.settings.ApplicationSettingsManager").init() ;
		this.appSettings      = genSettingsManager.get();
		this.UserManager      = CreateObject("component", "components.user.UserManager") ;
		this.getUserIsHQ      = this.UserManager.getUserIsHQ(request.AccessStructure.user_id, 0) ;
		this.UserPositionList = this.UserManager.getPositionId(request.AccessStructure.user_id, 0, 0) ;
		this.profileSettings  = CreateObject("component","components.user.Profile").getProfileSettings(request.AccessStructure.Profiles_ID) ;
	</cfscript>

	<cffunction name="init" output="false" returntype="mvc.models.planner.PlannerSearchManager">
		<cfreturn this />
	</cffunction>

	<!--- delete planners --->
	<cffunction name="deletePlanners" returntype="string" access="remote">
		<cfargument name="plannerList"	required="true" type="string">

		<!--- gather planner and indirect planners --->
		<cfquery name="local.qPlanners" datasource="#application.datasource#">
			SELECT Planner_ID
			  FROM Planners
			 WHERE ( Planner_ID IN (<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.plannerList#" list="true">)
					OR
					Parent_Planner_ID IN (<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.plannerList#" list="true">)
					)
		</cfquery>

		<cfquery datasource="#application.datasource#">
		 /*  flag planners as deleted */
			UPDATE Planners
			SET Deleted = 1,
				Updated_By = '#request.AccessStructure.user_id#',
				Updated_Date = getDate()
			WHERE Planner_ID IN (<cfqueryparam cfsqltype="cf_sql_numeric" value="#valueList( local.qPlanners.Planner_ID )#" list="true">)

		 /*  flag programs as deleted */
			UPDATE cm
				SET cm.Deleted = 1
					,cm.Deleted_By = '#request.AccessStructure.user_id#'
					,cm.Deleted_Date = GETDATE()
				FROM Contract_Main cm
				WHERE cm.Deleted = 0
						AND cm.planner_ID IN (<cfqueryparam cfsqltype="cf_sql_numeric" value="#valueList( local.qPlanners.Planner_ID )#" list="true">)
		</cfquery>

		<cfreturn 1>
	</cffunction>

	<cffunction name="getPlanners" output="false">
		<cfargument name="planner_ids" required="true">

		<cfquery name="local.qPlanners" datasource="#application.datasource#">
			SELECT
				PL.Planner_ID,
				PL.Planner_Number,
				PL.Planner_Title,
				PT.Planner_Type,
				CONVERT(varchar(12), PT.Planner_Start_Date, 107) as Planner_Start_Date,
				CONVERT(varchar(12), PT.Planner_End_Date, 107) as Planner_End_Date,
				PS.Status_Abbreviation,
				PL.RSP_ID,
				PL.Status_ID,
				BSAFC.Name,
				BSAFC.Shr_Ship_To,
				CASE
					WHEN
						ISNULL(Distributor_Group_Level_ID, 0) = 0
					THEN
						'N'
					ELSE
						'Y'
				END
				AS Customer_Group,
				ISNULL(rspUser.Name_First + ' ' + rspUser.Name_Last, '') AS RSP_User_Name
				FROM
					Planners PL
					INNER JOIN
						Planner_Template PT
						ON PT.Planner_Template_ID = PL.Planner_Template_ID
					LEFT JOIN
						Planner_Status PS
						ON PS.Status_ID = PL.Status_ID
					LEFT JOIN
						BSA_Foodservice_Customers BSAFC
						ON BSAFC.BSA_Foodservice_Customers_ID = PL.Customer_ID
					LEFT JOIN
						_USERS rspUser
						ON rspUser.User_ID = PL.RSP_ID
				WHERE
					PL.Deleted = 0
					AND PL.Planner_ID IN ( <cfqueryparam list="true" value="#arguments.planner_ids#"> )
		</cfquery>

		<cfreturn local.qPlanners>
	</cffunction>

    <cffunction name="searchPlanners" returnformat="json" access="remote">


        <cfargument name="planner_template"  required="false" type="string"  default=""/>
        <cfargument name="planner"           required="false" type="string"  default=""/>
		<cfargument name="planner_status"    required="false" type="string"  default=""  />
        <cfargument name="customer"          required="false" type="string"  default=""/>
        <cfargument name="indirect_customer" required="false" type="string"  default=""/>
		<cfargument name="Family"            required="false" type="string"  default="0" />
		<cfargument name="Buying_Group"      required="false" type="string"  default="0" />
		<cfargument name="Cust_Id"           required="false" type="string"  default="0" />
		<cfargument name="Line_Of_Biz"       required="false" type="string"  default="0" />
		<cfargument name="Zone_ID"           required="false" type="string"  default="0" />
		<cfargument name="Region_ID"         required="false" type="string"  default="0" />
		<cfargument name="Broker"            required="false" type="string"  default="0" />
        <cfargument name="RSP_ID"            required="false" type="string"  default="0"/>
        <cfargument name="planner_id"        required="false" type="numeric" default="0"/>
        <cfargument name="exclude_plannerId" required="false" type="string"  default="0"  />
		<cfargument name="from_scorecard"    required="false" type="string"  default=""  />
        <cfargument name="Include_Indirect"  required="false" type="string"  default="0"/>
		<cfargument name="Catalog_View"      required="false" type="numeric" default="0" />
        <cfargument name="Program"           required="false" type="string"  default=""/>
        <cfargument name="currentTime"       required="false" type="string"  default=""/>
		<cfargument name="user_position"     required="false" default="">
		<cfargument name="Planner_Type"      required="false" default="">
		<cfargument name="target_planner_Id" required="false" default="">
		<cfargument name="planner_import_type" required="false" default="">
        <cfargument name="Include_direct"    required="false" default="0">
		<cfargument name="product"           required="false" default="">
		<cfargument name="business_segement_id" required="false" default="">
		<cfargument name="shr_ship_tos" required="false" default="">

        <!--- add additional new form elements to arguments --->
        <cfif cgi.request_method is "post">
            <cfset structAppend(arguments, form, true)>
        </cfif>

		<cfset local.callStacks  = callStackGet()>
		<cfset local.called_from = (arguments.from_scorecard eq '' ? '' : "scorecard")>

		<cfloop from="1" to="#arrayLen(local.callStacks)#" index="local.counter">
			<cfif local.callStacks[ local.counter ].template contains "\planners\reassign\index.cfm">
				<cfset local.called_from = "reassign">
			</cfif>
			<cfif local.called_from neq ''>
				<cfbreak>
			</cfif>
		</cfloop>

		<cfscript>
            if ( structKeyExists( request, "planner_indirect_categories" ) eq false ) {
                request.planner_indirect_categories = application.util.query.get_Setting( "Planner_Indirect_Categories", 0 );
            }

			local.include_cra_logic = 0;
			local.planner_status = 0;
			local.planner_sub_status = 0;
			local.UserID = request.AccessStructure.user_id;
			local.UsersToEvaluate = "";
			local.applyPositionFilter = 1;
			local.plannerTemplateManager = CreateObject("component","mvc.Models.Planner.PlannerTemplateManager");


			if(arguments.planner_status != "") {
				local.planner_status = ListFirst(arguments.planner_status, "-");
				local.planner_sub_status = Val(ListLast(arguments.planner_status, "-"));
			}

            /* we need to display the number of programs in under review, pending approval, agreed sub status*/
            if(this.profileSettings.RFA_Agreed EQ 1 OR this.profileSettings.RFA_Agreed EQ 2)
                local.include_cra_logic = 1;


			// Get users above this user
			positionId = CreateObject("component", "components.user.UserManager").getPositionId(local.userID, 0);
			lPositionsAbove = CreateObject("component", "components.geography.position").getPositionsAbove(positionId,0);

			if(len(trim(lPositionsAbove)) > 0) {
				stStruct = StructNew();
				stStruct.userPosition = lPositionsAbove;
				UserPositionsAbove = CreateObject("component", "components.user.userManager").search(stStruct);
				local.UsersToEvaluate = ValueList(UserPositionsAbove.User_ID);
			}
			local.UsersToEvaluate = Listappend(local.UsersToEvaluate, local.userID);
			local.UsersToEvaluate = listqualify(local.UsersToEvaluate, "'", ",");

			if(this.getUserIsHQ OR arguments.Catalog_View){
				local.applyPositionFilter = 0;
			}
		</cfscript>

		<cfif local.applyPositionFilter>
			<cfset local.getPositionsBelowMe     = this.getPositionsBelowMe() />
			<cfset local.plannersWithDistUnderMe = this.plannersWithDistUnderMe(local.getPositionsBelowMe) />
			<cfif local.getPositionsBelowMe eq "">
				<cfset local.getPositionsBelowMe = "0" />
			</cfif>
			<cfif local.plannersWithDistUnderMe eq "">
				<cfset local.plannersWithDistUnderMe = "0" />
			</cfif>
		</cfif>

		<cfoutput>
			<cfquery name="temp_Table_Drop" datasource="#application.datasource#">
				if object_id('tempdb..##Tmp_Planner_Search_Result') is not null
				drop table ##Tmp_Planner_Search_Result
				if object_id('tempdb..##Tmp_Planner_Approvable_Users') is not null
				drop table ##Tmp_Planner_Approvable_Users
				if object_id('tempdb..##Tmp_Approved_Planner_Programs') is not null
				drop table ##Tmp_Approved_Planner_Programs
                IF Object_id('tempdb..##Tmp_Filter_Products') IS NOT NULL
                    DROP TABLE ##Tmp_Filter_Products
				if object_id('tempdb..##Tmp_Target_Planner_Operators') is not null
					drop table ##Tmp_Target_Planner_Operators
                IF Object_id('tempdb..##Tmp_Search_Planner_Distributors') IS NOT NULL
                    DROP TABLE ##Tmp_Search_Planner_Distributors
                /* Get planners which includes the select product(s) 888 */
                IF Object_id('tempdb..##Tmp_Search_Planners_With_Prod') IS NOT NULL
                    DROP TABLE ##Tmp_Search_Planners_With_Prod
                IF Object_id('tempdb..##Tmp_Planner_Search_Templates') IS NOT NULL
                    DROP TABLE ##Tmp_Planner_Search_Templates
                IF Object_id('tempdb..##Tmp_Planner_Search_PGT')IS NOT NULL
                    DROP TABLE ##Tmp_Planner_Search_PGT
                IF Object_id('tempdb..##Tmp_Planner_Search_PGT_Prod')IS NOT NULL
                    DROP TABLE ##Tmp_Planner_Search_PGT_Prod
                IF Object_id('tempdb..##Tmp_Planner_Search_Template_Filter_Products_Allowed')IS NOT NULL
                    DROP TABLE ##Tmp_Planner_Search_Template_Filter_Products_Allowed
				IF Object_id('tempdb..##Tmp_Search_Planner_Operators') IS NOT NULL
                    DROP TABLE ##Tmp_Search_Planner_Operators
			</cfquery>

            <cfset local.businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager")>
            <cfif arguments.business_segement_id eq '' and local.businessSegManager.isEnabled()>
                <!--- gather user business segments, use it as a filter --->
                <cfset local.qUserSegments = local.businessSegManager.getActiveClassCodes(request.AccessStructure.User_ID, 0)>
                <cfset arguments.business_segement_id = valueList(local.qUserSegments.Business_Segment_ID)>
            </cfif>

			<cfif local.called_from is "scorecard">
				<cfquery name="qGetPlannerSearch" datasource="#application.datasource#">
					SELECT	PL.Planner_ID,
							PL.Planner_Number,
							PL.Status_ID,
							PL.Parent_Planner_ID,
                            CAST(0 as TINYINT) as Sub_Status_ID,
                            CAST('' AS VARCHAR(50)) AS Display_Order,
                            0 AS Indirect_Programs_Count,
                            0 AS Indirect_Planners_Count,
                            0 AS Program_Count,
							CAST(0 AS INT) AS Under_Review_Count,
							CAST(0 AS INT) AS Pending_approval_Count,
							CAST(0 AS INT) AS Agreed_Count,
                            ParentPlanner.Status_ID as Parent_Status_ID
					INTO    ##Tmp_Planner_Search_Result
					FROM   	Planners PL
                    INNER JOIN Planner_Template PT ON PT.Planner_Template_ID = PL.Planner_Template_ID
                    LEFT JOIN Planners ParentPlanner ON ParentPlanner.Planner_ID = PL.Parent_Planner_ID
					WHERE	PL.Deleted = 0
                            <!--- check below only if not a HQ user --->
                            <cfif local.applyPositionFilter>
                                <!--- check either the creator is below my position or my distributor is on the planner --->
                                AND
                                (
                                    <!--- check positions below me --->
                                    PL.Creator_Position_ID IN (#local.getPositionsBelowMe#)
                                    OR
                                    <!--- check planners with distributors below me --->
                                    PL.Planner_ID IN (#local.plannersWithDistUnderMe#)
                                )
                            </cfif>
                            <cfif arguments.business_segement_id neq ''>
                                AND PT.Business_Segment_ID IN ( #listQualify(arguments.business_segement_id, "'")# )
                            </cfif>
				</cfquery>
			<cfelse>
				<!--- code specific to import programs --->
				<cfset bApplyOperatorFilter = 0 />
				<cfif arguments.target_planner_Id neq "" and arguments.target_planner_Id neq "0">
					<cfquery name="qGetTargetPlannerInfo" datasource="#application.datasource#">
						select	Planner_ID,
								CASE ISNULL(PL.Parent_Planner_ID, 0) WHEN 0 THEN 'D' ELSE 'I' END as Direct_Indirect
						from	Planners PL
						where	PL.Planner_ID = #arguments.target_planner_Id#
					</cfquery>
					<cfif qGetTargetPlannerInfo.recordCount>
						<cfset arguments.Planner_Type = qGetTargetPlannerInfo.Direct_Indirect />
					</cfif>

					<cfif arguments.planner_import_type eq "2" and qGetTargetPlannerInfo.Direct_Indirect eq "I"> <!--- need to filter on operator --->

						<cfquery name="qGetPlannerOperators" datasource="#application.datasource#">
							select	BSA_Operator_ID
							into	##Tmp_Target_Planner_Operators
							from	Planner_Operators po
							where	po.Planner_ID = #arguments.target_planner_Id#
							and		po.Deleted = 0
						</cfquery>
						<cfset bApplyOperatorFilter = 1 />
						<cfset arguments.include_indirect = 1 />
					</cfif>
				</cfif>

				<cfquery name="qGetPlannerSearch" datasource="#application.datasource#">
                    DECLARE @Session_Expiration_In_Minutes AS FLOAT

                    SELECT @Session_Expiration_In_Minutes = Session_Expiration_Length * 24 * 60
                      FROM General_Settings

					SELECT DISTINCT
					PL.Planner_ID, <!--- 0 --->
					PL.Planner_Number, <!--- 1 --->
					PL.Planner_Title, <!--- 2 --->
					PT.Planner_Type, <!--- 3 --->
					CONVERT(varchar(12),PT.Planner_Start_Date,107) as Planner_Start_Date, <!--- 4 --->
					CONVERT(varchar(12),PT.Planner_End_Date,107) as Planner_End_Date, <!--- 5 --->
					PL.Planner_Template_ID, <!--- 6 --->
					PL.Creator_Position_ID, <!--- 7 --->
					PS.Status_Abbreviation, <!--- 8 --->
					PL.RSP_ID, <!--- 9 --->
					PL.Created_Date, <!--- 10 --->
					PL.Created_By, <!--- 11 --->
					PL.Approved, <!--- 12 --->
					PL.Approver_ID, <!--- 13 --->
					PL.Approved_Date, <!--- 14 --->
					PL.Active, <!--- 15 --->
					PL.Deleted, <!--- 16 --->
					PL.AOP_CS, <!--- 17 --->
					PL.AOP_LB, <!--- 18 --->
					PL.AOP_Sales_Dollars, <!--- 19 --->
					PL.Forecast_CS, <!--- 20 --->
					PL.Forecast_LB, <!--- 21 --->
					PL.Forecast_Sales_Dollars, <!--- 22 --->
					PL.Actual_CS, <!--- 23 --->
					PL.Actual_LB, <!--- 24 --->
					PL.Actual_Sales_Dollars, <!--- 25 --->
					PL.AOP_Trade_Dollars, <!--- 26 --->
					PL.Planned_Trade_Dollars, <!--- 27 --->
					PL.Approved_Trade_Dollars, <!--- 28 --->
					PL.Committed_Trade_Dollars, <!--- 29 --->
					PL.Actual_Trade_Dollars, <!--- 30 --->
					PL.Updated_Date, <!--- 31 --->
					PL.Updated_By, <!--- 32 --->
					PL.Status_ID, <!--- 33 --->
					BSAFC.Name, <!--- 34 --->
					BSAFC.Shr_Ship_To, <!--- 35 --->
					CASE
						WHEN ISNULL(Distributor_Group_Level_ID, 0) <= 0 THEN 'N'
						ELSE 'Y'
					END AS Customer_Group, <!--- 36 --->
					(
						SELECT COUNT(*) FROM Contract_Main cm WHERE cm.Planner_ID = PL.Planner_ID and cm.Deleted = 0 AND cm.Manual_Cancel = 0 AND CM.Contract_Start_Date >= PT.Planner_Start_Date
						AND CM.Contract_End_Date <= PT.Planner_End_Date
					) as Program_Count, <!--- 37 --->

                    /*** is session expired on locked user? ***/
                    CASE
                        WHEN DATEDIFF (n, st.Session_Date_Time_Stamp, GETDATE ()) > @Session_Expiration_In_Minutes THEN 0
                        ELSE ISNULL(l.Is_Locked, 0)
                    END AS Is_Locked,  <!--- 38 --->


					ISNULL(luser.Name_First + ' ' + luser.Name_Last, '') AS Locked_By_User_Name, <!--- 39 --->
					ISNULL(l.Locked_By_User_ID, '') as Locked_By_User_ID, <!--- 40 --->
					ISNULL(rspUser.Name_First + ' ' + rspUser.Name_Last, '') AS RSP_User_Name, <!--- 41 --->
					ISNULL(rspUserPositions.Position_Label, ' ') AS RSP_Position, <!--- 42 --->
					System_Locked, <!--- 43 --->
					System_Locked_Date, <!--- 44 --->
					PT.Wholesaler_Planner,  <!--- 45 --->
					PL.Parent_Planner_ID,
					<cfif local.called_from is "reassign">
						PL.Status_ID as Sub_Status_ID
					<cfelse>
						CAST(0 as TINYINT) as Sub_Status_ID
					</cfif>
					,CASE ISNULL(PL.Parent_Planner_ID, 0) WHEN 0 THEN 'D' ELSE 'I' END as Direct_Indirect,
                    PT.Planner_Start_Date as PL_Start_Date,
                    PT.Planner_End_Date as PL_End_Date,
                    PL.Customer_ID,
                    PL.Distributor_Group_Level_ID,
                    CAST('' AS VARCHAR(50)) AS Display_Order,
                    0 AS Indirect_Programs_Count,
                    0 AS Indirect_Planners_Count,
					ISNULL(PT.Business_Segment_ID, 0) as Business_Segment_ID,
					PT.Category

                   ,(
                        SELECT  Count ( 1 )
                          FROM  Contract_Main cm
                         WHERE  cm.Planner_ID                   = PL.Planner_ID
                                AND cm.Deleted                  = 0
                                AND cm.Manual_Cancel            = 0
                                AND cm.Contract_Status_Type_IDX = 2
                    )                                                                             AS RFA,
                    CAST(0 AS INT) AS Under_Review_Count,
                    CAST(0 AS INT) AS Pending_approval_Count,
                    CAST(0 AS INT) AS Agreed_Count,
                    (SELECT Status_ID FROM Planners ParentPlanner WHERE ParentPlanner.Planner_ID = PL.Parent_Planner_ID) as Parent_Status_ID


					INTO    ##Tmp_Planner_Search_Result
					FROM   Planners PL
						INNER JOIN Planner_Template PT ON PT.Planner_Template_ID = PL.Planner_Template_ID
						LEFT JOIN Planner_Status PS ON PS.Status_ID = PL.Status_ID
						LEFT JOIN BSA_Foodservice_Customers BSAFC ON BSAFC.BSA_Foodservice_Customers_ID = PL.Customer_ID
					    LEFT JOIN Lock l ON l.Main_ID = 'Planner' AND l.Secondary_ID = PL.Planner_ID

                    /*** bring in locked user session info ***/
                    LEFT JOIN Session_Tracker st ON l.Locked_By_User_ID > '' AND st.session_user_id = l.Locked_By_User_ID

					LEFT JOIN _USERS luser ON l.Locked_By_User_ID = luser.User_ID
					LEFT JOIN _USERS rspUser ON rspUser.User_ID = PL.RSP_ID
					LEFT JOIN User_Positions rspUserPositions on rspUserPositions.User_Positions_ID = PL.Creator_Position_ID
					WHERE
						PL.Deleted = 0
						AND PT.Planner_Template_ID IN ( #ListQualify(local.plannerTemplateManager.allowedTemplates(), "'", ",", "ALL")# )
                    <cfif arguments.business_segement_id neq ''>
                        AND PT.Business_Segment_ID IN ( #listQualify(arguments.business_segement_id, "'")# )
					</cfif>
					<cfif arguments.user_position neq ''>
                        AND rspUserPositions.User_Positions_ID IN ( #listQualify(arguments.user_position, "'")# )
					</cfif>

                    <cfif arguments.planner_template NEQ "">
                        AND	PT.Planner_Template_ID IN ( #listQualify(arguments.planner_template, "")# )
					</cfif>
					<cfif local.planner_status NEQ "0">
                        /* AND PL.Status_ID IN ( #listQualify(arguments.planner_status, "")# ) */
                        AND (PL.Status_ID IN ( #listQualify(local.planner_status, "")# )
                        <!--- 2. When user clicks [PRG � Under Review, PRG � Pending Approval, PRG � Agreed]
                       or searches for [PRG � Under Review, PRG � Pending Approval, PRG � Agreed]
                       we will include all indirect planners under a direct planner that is displayed.   --->
                        <cfif local.planner_status EQ "3" and local.planner_sub_status NEQ "0" and local.called_from neq "reassign">
                            OR EXISTS (SELECT 1 FROM Planners ParentPlanner WHERE ParentPlanner.Planner_ID = PL.Parent_Planner_ID and ParentPlanner.Status_ID = 3)
                        </cfif>
                        )
					</cfif>
					<cfif isDefined("arguments.planner") AND arguments.planner NEQ "">
						AND (Pl.Planner_number like '%#arguments.planner#%'
							OR Pl.Planner_Title like '%#arguments.planner#%'
						)
					</cfif>

					<cfif isDefined("arguments.Planner_Type") AND arguments.Planner_Type NEQ "">
						<cfif arguments.Planner_Type EQ "D">
							AND ISNULL(PL.Parent_Planner_ID, 0) = 0
						<cfelseif arguments.Planner_Type EQ "I">
							AND ISNULL(PL.Parent_Planner_ID, 0) != 0
						</cfif>
					</cfif>

					<cfif bApplyOperatorFilter>
						AND EXISTS (
							SELECT	1
							FROM	Planner_Operators po
							INNER JOIN ##Tmp_Target_Planner_Operators tpo
							ON		tpo.BSA_Operator_ID = po.BSA_Operator_ID
							WHERE	po.Planner_ID = PL.Planner_ID
							AND		po.Deleted = 0
						)

					</cfif>

					<cfif isDefined("arguments.customer") AND arguments.customer NEQ "">
                        /* this is a handling for planner_import_type eq 1 (import planners from different customer) */
                        <cfset condition_filter = arguments.planner_import_type eq '1' ? "NOT" : ''>

						AND (BSAFC.Shr_Ship_To LIKE '%#arguments.customer#%'
								OR BSAFC.Keyword_Search #condition_filter# LIKE '%#arguments.customer#%'
								OR BSAFC.Name #condition_filter# LIKE '%#arguments.customer#%'
								OR #condition_filter# EXISTS (
									SELECT	1
									FROM	Planner_Customer_Group_Members m
									INNER JOIN BSA_Foodservice_Customers c
									ON		c.BSA_Foodservice_Customers_ID = m.Distributor_ID
									WHERE	m.Planner_ID = PL.Planner_ID
									AND		(c.Shr_Ship_To LIKE '%#arguments.customer#%'
											OR c.Name LIKE '%#arguments.customer#%'
											)
								)
							)
					</cfif>

					<cfif arguments.shr_ship_tos neq "">
                        AND EXISTS ( SELECT	1
                                       FROM	Planner_Customer_Group_Members m
                                                INNER JOIN BSA_Foodservice_Customers c ON c.BSA_Foodservice_Customers_ID = m.Distributor_ID
                                      WHERE	m.Planner_ID = PL.Planner_ID
                                            AND	c.Shr_Ship_To IN (#listQualify(arguments.shr_ship_tos, "'")#)
                                    )
                    </cfif>

					<!--- family name --->
					<cfif isDefined("arguments.Family") AND arguments.Family NEQ "" AND arguments.Family NEQ 0>
                        AND (BSAFC.Family_ID IN ( #listQualify(arguments.Family, "'")# )
							OR EXISTS (
										SELECT	1
										FROM	Planner_Customer_Group_Members m
										INNER JOIN BSA_Foodservice_Customers c
										ON		c.BSA_Foodservice_Customers_ID = m.Distributor_ID
										WHERE	m.Planner_ID = PL.Planner_ID
                                        AND		c.Family_ID  IN ( #listQualify(arguments.Family, "'")# )
									)
						)
					</cfif>

					<!--- buying group --->
					<cfif isDefined("arguments.Buying_Group") AND arguments.Buying_Group NEQ "" AND arguments.Buying_Group NEQ 0>
                        AND (BSAFC.Buying_Group_ID IN ( #listQualify(arguments.Buying_Group, "'")# )
							OR EXISTS (
										SELECT	1
										FROM	Planner_Customer_Group_Members m
										INNER JOIN BSA_Foodservice_Customers c
										ON		c.BSA_Foodservice_Customers_ID = m.Distributor_ID
										WHERE	m.Planner_ID = PL.Planner_ID
                                        AND		c.Buying_Group_ID IN ( #listQualify(arguments.Buying_Group, "'")# )
									)
						)
					</cfif>

					<!--- Cust ID --->
					<cfif isDefined("arguments.Cust_Id") AND arguments.Cust_Id NEQ "" AND arguments.Cust_Id NEQ 0>
                        AND (BSAFC.Customer_ID IN ( #listQualify(arguments.Cust_Id, "'")# )
							OR EXISTS (
										SELECT	1
										FROM	Planner_Customer_Group_Members m
										INNER JOIN BSA_Foodservice_Customers c
										ON		c.BSA_Foodservice_Customers_ID = m.Distributor_ID
										WHERE	m.Planner_ID = PL.Planner_ID
                                        AND		c.Customer_ID IN ( #listQualify(arguments.Cust_Id, "'")# )
									)
						)
					</cfif>

					<!--- Line Of Business --->
					<cfif isDefined("arguments.Line_Of_Biz") AND arguments.Line_Of_Biz NEQ "" AND arguments.Line_Of_Biz NEQ 0>
                        AND (BSAFC.Line_Of_Business_ID IN ( #listQualify(arguments.Line_Of_Biz, "'")# )
							OR EXISTS (
										SELECT	1
										FROM	Planner_Customer_Group_Members m
										INNER JOIN BSA_Foodservice_Customers c
										ON		c.BSA_Foodservice_Customers_ID = m.Distributor_ID
										WHERE	m.Planner_ID = PL.Planner_ID
                                        AND		c.Line_Of_Business_ID IN ( #listQualify(arguments.Line_Of_Biz, "'")# )
									)
						)
					</cfif>



					<cfif (isDefined("arguments.Zone_ID") AND arguments.Zone_ID NEQ "" AND arguments.Zone_ID NEQ 0)
						  OR (isDefined("arguments.Region_ID") AND arguments.Region_ID NEQ "" AND arguments.Region_ID NEQ 0)
						  OR (isDefined("arguments.Broker") AND arguments.Broker NEQ "" AND arguments.Broker NEQ 0)>

						AND	EXISTS (
						<!---- getDistributorMultiPosition = 1, use table Market_Distributor ---->
						<cfif this.appSettings.getDistributorMultiPosition()>
							SELECT	1
							FROM	Market_Distributor md
							INNER JOIN Service_Markets m ON m.Service_Market_ID = md.Service_Market_ID
							INNER JOIN Service_Regions r ON r.Service_Region_ID = m.Service_Region_ID
							WHERE	(md.Distributor_ID = BSAFC.BSA_Foodservice_Customers_ID <!--- Planner has Individual distributor --->
									OR EXISTS (SELECT 1 FROM Planner_Customer_Group_Members mem WHERE mem.Planner_ID = PL.Planner_ID AND mem.Distributor_ID = md.Distributor_ID) <!--- Planner has multiple distributors --->
									)
							AND		md.Deleted = 0
							<cfif isDefined("arguments.Zone_ID") AND arguments.Zone_ID NEQ "" AND arguments.Zone_ID NEQ 0>
                                AND		r.Service_Zone_ID IN ( #listQualify(arguments.Zone_ID, "'")# )
							</cfif>
							<cfif isDefined("arguments.Region_ID") AND arguments.Region_ID NEQ "" AND arguments.Region_ID NEQ 0>
                                AND		r.Service_Region_ID IN ( #listQualify(arguments.Region_ID, "'")# )
							</cfif>
						<cfelse> <!---- getDistributorMultiPosition = 0, use table BSA_Foodservice_Brokers ---->
							SELECT	1
							FROM	BSA_Foodservice_Customers c
							INNER JOIN BSA_Foodservice_Brokers b ON b.BSA_Foodservice_Brokers_ID = c.BSA_Foodservice_Brokers_ID
							WHERE	(c.BSA_Foodservice_Customers_ID = BSAFC.BSA_Foodservice_Customers_ID <!--- Planner has Individual distributor --->
									OR EXISTS (SELECT 1 FROM Planner_Customer_Group_Members mem WHERE mem.Planner_ID = PL.Planner_ID AND mem.Distributor_ID = c.BSA_Foodservice_Customers_ID) <!--- Planner has multiple distributors --->
									)
							<cfif isDefined("arguments.Zone_ID") AND arguments.Zone_ID NEQ "" AND arguments.Zone_ID NEQ 0>
                                AND		b.Service_Zone_ID IN ( #listQualify(arguments.Zone_ID, "'")# )
							</cfif>
							<cfif isDefined("arguments.Region_ID") AND arguments.Region_ID NEQ "" AND arguments.Region_ID NEQ 0>
                                AND		b.Service_Region_ID IN ( #listQualify(arguments.Region_ID, "'")# )
							</cfif>
							<cfif isDefined("arguments.Broker") AND arguments.Broker NEQ "" AND arguments.Broker NEQ 0>
								AND		b.BSA_Foodservice_Brokers_ID IN (#ListQualify(arguments.Broker, "'", ",", "ALL")#)
							</cfif>
						</cfif>
						)

					</cfif>

					<!--- RSP --->
					<cfif isDefined("arguments.RSP_ID") AND arguments.RSP_ID NEQ "">
                        AND PL.RSP_ID  IN ( #listQualify(arguments.RSP_ID, "'")# )
					</cfif>

					<!--- indirect_customer --->
					<cfif isDefined("arguments.indirect_customer") AND arguments.indirect_customer NEQ "">
						AND EXISTS (
							<!--- Include parent planner in the search result if operator is part of the child planner --->
							SELECT	1
							FROM	Planners p
							INNER JOIN Planner_Operators po
							ON		po.Planner_ID = p.Planner_ID
							INNER JOIN BSA_Operator o
							ON		o.BSA_Operator_ID = po.BSA_Operator_ID
							AND		(o.Legacy_ID LIKE '%#arguments.indirect_customer#%'
									OR o.BSA_Operator_ID LIKE '%#arguments.indirect_customer#%'
									OR o.Operator_Name LIKE '%#arguments.indirect_customer#%'
									)
							WHERE	p.Parent_Planner_ID = PL.Planner_ID
							AND		p.Deleted = 0
							UNION
							<!--- operator is part of the planner --->
							SELECT	1
							FROM	Planner_Operators po
							INNER JOIN BSA_Operator o
							ON		o.BSA_Operator_ID = po.BSA_Operator_ID
							AND		(o.Legacy_ID LIKE '%#arguments.indirect_customer#%'
									OR o.BSA_Operator_ID LIKE '%#arguments.indirect_customer#%'
									OR o.Operator_Name LIKE '%#arguments.indirect_customer#%'
									)
							WHERE	po.Planner_ID = PL.Planner_ID
						)
					</cfif>

					<!--- Program --->
					<cfif isDefined("arguments.Program") AND arguments.Program NEQ "">
						AND EXISTS (
							<!--- program is part of the planner --->
							SELECT	1
							FROM	Contract_Main cm
							WHERE	cm.Planner_ID = PL.Planner_ID
							AND		(cm.Contract_Number LIKE '%#arguments.Program#%'
									OR cm.Contract_Title LIKE '%#arguments.Program#%'
									)
								AND cm.Deleted = 0
						)
					</cfif>

					<!--- check below only if not a HQ user --->
					<cfif local.applyPositionFilter>
						<!--- check either the creator is below my position or my distributor is on the planner --->
						AND
						(
							<!--- check positions below me --->
							PL.Creator_Position_ID IN (#local.getPositionsBelowMe#)
							OR
							<!--- check planners with distributors below me --->
							PL.Planner_ID IN (#local.plannersWithDistUnderMe#)
						)

					</cfif>

					<cfif arguments.Catalog_View>
						AND PT.Include_In_Catalog = 1
						AND PL.Status_ID > 2
					</cfif>

					<!--- exclude given planners --->
					<cfif isDefined("arguments.exclude_plannerId") AND len(arguments.exclude_plannerId)>
						AND ( PL.Planner_ID NOT IN (#arguments.exclude_plannerId#) )
					</cfif>

				</cfquery>
			</cfif><!--- else local.called_from is "scorecard" --->


			<!--- Only include planner CRA logic --->
			<cfif local.include_cra_logic EQ 1>
				<cfscript>
					local.ProgramManager = CreateObject("component", "components.programs.ProgramManager").init();
					local.qGetApprovableUsers = local.ProgramManager.getApprovableUsers(
									programId = 0,
									PlannerId = 0,
									PlannerListTmpTable = "##Tmp_Planner_Search_Result");
				</cfscript>

			</cfif>

			<!--- Logic copied from PlannerManager.getApprovableUsers() --->
			<cfquery name="qPlannerCRAUsers" datasource="#application.datasource#">

				CREATE TABLE ##Tmp_Approved_Planner_Programs (Planner_ID Int, Parent_Planner_ID int, Contract_Main_ID Int, Contract_Status_Type_IDX Int, Program_Sub_Status_ID Tinyint)

				<cfif local.include_cra_logic EQ 1>
					SELECT 	t.*,
						Position_Rank = Rank() OVER (Partition By t.Planner_ID Order By Service_Zone_ID Desc, Service_Region_ID Desc, Service_Market_ID Desc, Authority_Sequence_Order Desc),
						Position_Type = CASE
											WHEN Service_Zone_ID IS NULL AND Service_Region_ID IS NULL AND Service_Market_ID IS NULL THEN 0
											WHEN Service_Zone_ID IS NOT NULL AND Service_Region_ID IS NULL AND Service_Market_ID IS NULL THEN 1
											WHEN Service_Zone_ID IS NOT NULL AND Service_Region_ID IS NOT NULL AND Service_Market_ID IS NULL THEN 2
											WHEN Service_Zone_ID IS NOT NULL AND Service_Region_ID IS NOT NULL AND Service_Market_ID IS NOT NULL THEN 3
										END,
						cm.Planner_ID as Program_Planner_ID
					INTO    ##Tmp_Planner_Approvable_Users
					FROM 	##Tmp_Program_CRA_List t
					INNER JOIN Contract_Main cm
					ON      cm.Contract_Main_ID = t.Contract_Main_ID

					<!----
					Filter on Position_Rank = 1. We don't want zone users to be displayed in CRA list if there are region users in the CRA list.
					This is to avoid below scenario,

					PGM1 CRA = RegionAUser1 -> Then ZoneAUser1
					PGM2 CRA = RegionAUser2 -> Then ZoneAUser1
					Planner CRA = RegionAUser1, RegionAUser2

					After RegionAUser1 agrees to the planner we will have below,
					PGM1 CRA = ZoneAUser1
					PGM2 CRA = RegionAUser2 -> Then ZoneAUser1
					Planner CRA = RegionAUser2  (We do not want to show ZoneAUser1 at this point. we want to wait till RegionAUser2 agrees to the planner)

					After RegionAUser2 agrees to the planner we will have below,
					PGM1 CRA = ZoneAUser1
					PGM2 CRA = ZoneAUser1
					Planner CRA = ZoneAUser1
					---->

					<!---**************************************** Planner Status = 2 RFA ****************************************--->
					<!--- For RFA planners, get the planner sub status --->
					<cfif local.called_from is "scorecard" OR (local.planner_status EQ "2" and local.include_cra_logic EQ 1)><!--- scorecard or search filter --->
						<!--- Planner Sub_Status_ID = 2 = Planner in Pending Approval --->
						UPDATE  ##Tmp_Planner_Search_Result
						SET     Sub_Status_ID = 102
						WHERE   EXISTS (
							SELECT  *
							FROM    ##Tmp_Planner_Approvable_Users cra
							WHERE   cra.Position_Rank = 1
							AND     cra.Planner_ID = ##Tmp_Planner_Search_Result.Planner_ID
							AND     cra.User_ID = '#local.UserID#'
						)
						AND Status_ID = 2

						<!--- Planner Sub_Status_ID = 3 = Planner in Agreed --->
						UPDATE  ##Tmp_Planner_Search_Result
						SET     Sub_Status_ID = 103
						WHERE   EXISTS (
							SELECT	1
							FROM	Contract_Main
							INNER JOIN Program_Agree_All_Group Program_Agree
							ON 		Contract_Main.Contract_Main_ID = Program_Agree.ProgramId
							AND     Program_Agree.User_ID IN (#preservesinglequotes(local.UsersToEvaluate)#)     /* Include all users above this user also */
							WHERE   Contract_Main.Planner_ID = ##Tmp_Planner_Search_Result.Planner_ID
							AND 	Contract_Main.Contract_Status_Type_IDX = 2
							AND		Contract_Main.Deleted = 0
						)
						AND Status_ID = 2

						<!--- Planner Sub_Status_ID = 1 = Planner in Under Review --->
						UPDATE  ##Tmp_Planner_Search_Result
						SET     Sub_Status_ID = 101
						WHERE   Status_ID = 2
						AND     Sub_Status_ID = 0
					</cfif>

					<!---**************************************** Planner Status = 3 Approved ****************************************--->
					<!--- For all planners, get the program sub status --->

						<!--- A. Get list of RFA programs for Approved planner --->
						<!--- Program_Sub_Status_ID = 1 = Under Review --->
						INSERT INTO ##Tmp_Approved_Planner_Programs
						SELECT  p.Planner_ID, ISNULL(p.Parent_Planner_ID, p.Planner_ID) as Parent_Planner_ID, cm.Contract_Main_ID, cm.Contract_Status_Type_IDX, CAST(101 as TINYINT) as Program_Sub_Status_ID
						FROM    ##Tmp_Planner_Search_Result p
						INNER JOIN Contract_Main cm
						ON      cm.Planner_ID = p.Planner_ID
						AND     cm.Contract_STatus_Type_IDX = 2
						AND     cm.Deleted = 0
						<cfif local.called_from is "scorecard"><!--- scorecard --->
						<!---
						1. In the home page scorecard indirect planner programs will count against direct planner.
						Scenario: We display programs under [PRG � Under Review, PRG � Pending Approval, PRG � Agreed] in scorecard only for planners that are approved.
						If there are approved direct planners with non-approved indirect planners, programs from non-approved indirect planners were not getting included due to the planner.status_ID = 3 filter.
						Solution: We will include indirect planner programs if direct planner is approved.
						--->
						WHERE   (p.Status_ID = 3 OR p.Parent_Status_ID = 3)
                        </cfif>

						<!--- Program_Sub_Status_ID = 2 = Pending Approval --->
						UPDATE  p
						SET     Program_Sub_Status_ID = 102
						FROM    ##Tmp_Approved_Planner_Programs p
						WHERE   Contract_Status_Type_IDX = 2
						AND     EXISTS (
							SELECT  *
							FROM    ##Tmp_Planner_Approvable_Users cra
							WHERE   cra.Contract_Main_ID = p.Contract_Main_ID
							AND     cra.Program_Planner_ID = p.Planner_ID
							AND     cra.User_ID = '#local.UserID#'
							AND		cra.Position_Rank = 1
						)

						<!--- Program_Sub_Status_ID = 3 = Agreed --->
						UPDATE  p
						SET     Program_Sub_Status_ID = 103
						FROM    ##Tmp_Approved_Planner_Programs p
						WHERE   Contract_Status_Type_IDX = 2
						AND     EXISTS (
						   SELECT	1
							FROM	Program_Agree_All_Group Program_Agree
							WHERE   p.Contract_Main_ID = Program_Agree.ProgramId
							AND     Program_Agree.User_ID IN (#preservesinglequotes(local.UsersToEvaluate)#) /* Include all users above this user also */
						)


				<cfelse> <!--- else local.include_cra_logic EQ 1 --->
					<cfif (this.profileSettings.RFA_Agreed NEQ 1 AND this.profileSettings.RFA_Agreed NEQ 2)
						  AND (local.called_from is "scorecard"
								OR (local.planner_status EQ "3" and local.planner_sub_status EQ "2"))><!--- scorecard or search filter --->
						<!--- Get list of RFA programs for Approved planner --->
						INSERT INTO ##Tmp_Approved_Planner_Programs
						SELECT  ISNULL(p.Parent_Planner_ID, p.Planner_ID), p.Parent_Planner_ID, cm.Contract_Main_ID, cm.Contract_Status_Type_IDX, CAST(2 as TINYINT) as Program_Sub_Status_ID
						FROM    ##Tmp_Planner_Search_Result p
						INNER JOIN Contract_Main cm
						ON      cm.Planner_ID = p.Planner_ID
						AND     cm.Contract_STatus_Type_IDX = 2
						AND     cm.Deleted = 0
						WHERE   p.Status_ID = 3
					</cfif>

				</cfif> <!--- end else local.include_cra_logic EQ 1 --->

				<cfif local.called_from is "scorecard" OR (local.planner_status EQ "3" and local.planner_sub_status EQ "10")><!--- scorecard or search filter --->
					<!--- Get list of Pending Accept programs for Approved planner --->
					INSERT INTO ##Tmp_Approved_Planner_Programs
					SELECT  ISNULL(p.Parent_Planner_ID, p.Planner_ID), p.Parent_Planner_ID, cm.Contract_Main_ID, cm.Contract_Status_Type_IDX, CAST(10 as TINYINT) as Program_Sub_Status_ID
					FROM    ##Tmp_Planner_Search_Result p
					INNER JOIN Contract_Main cm
					ON      cm.Planner_ID = p.Planner_ID
					AND     cm.Contract_Status_Type_IDX = 10
					AND     cm.Deleted = 0
					WHERE   p.Status_ID = 3
				</cfif>

			</cfquery>

            <!--- ~~~~~~~ filter by product ~~~~~~~~ --->
            <cfif trim(arguments.product) neq ''>

				<cfset useLakebaseForlocal_getSegmentSetting = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("business_segment_enabled")>
<cfif useLakebaseForlocal_getSegmentSetting>
	<cftry>
		<cfset local.getSegmentSetting = application.oLakebase.toQuery(
			application.oLakebase.selectRows("business_segment_enabled", {
				"select" = "planner_volume_plan_segment_enable"
			}), "planner_volume_plan_segment_enable"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForlocal_getSegmentSetting = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForlocal_getSegmentSetting>
<cfquery name="local.getSegmentSetting" datasource="#application.datasource#">
					SELECT Planner_Volume_Plan_Segment_Enable FROM Business_Segment_Enabled
				</cfquery>
</cfif>

				<cfset local.filterSegment = Val(local.getSegmentSetting.Planner_Volume_Plan_Segment_Enable) />

                <cfquery datasource="#application.datasource#">
                    SELECT i.BSA_Foodservice_Items_Master_ID
                      INTO ##Tmp_Filter_Products
                      FROM BSA_Foodservice_Items_Master i
                     WHERE i.Item IS NOT NULL
                           AND ( i.Item LIKE '%#arguments.product#%'
                                  OR i.Description LIKE '%#arguments.product#%' )
                    UNION
                    SELECT gm.BSA_Foodservice_Items_Master_ID
                      FROM All_Product_Group_Types gt
                           INNER JOIN All_Product_Group_Type_Members gm
                                   ON gm.Product_Group_ID = gt.Group_GUID
                                      AND gm.Product_Group_Level_ID = gt.Product_Group_Level_ID
                     WHERE ( gt.Group_Number LIKE '%#arguments.product#%'
                              OR gt.Group_Desc LIKE '%#arguments.product#%' )

					SELECT r.Planner_Template_ID,
					       Count(DISTINCT ptf.Group_Level_ID) AS Filter_Type_Count
					  INTO ##Tmp_Planner_Search_Templates
					  FROM ##Tmp_Planner_Search_Result r
					       LEFT JOIN Planner_Template_Filters ptf
					              ON ptf.Planner_Template_ID = r.Planner_Template_ID
					                 AND ptf.Allow_Filter = 1
					                 AND ptf.PG_Group_Type = 1
					 GROUP BY r.Planner_Template_ID

					SELECT DISTINCT t.Planner_Template_ID,
					                p.Product_Group_level_ID,
					                p.Product_Group_ID
					  INTO ##Tmp_Planner_Search_PGT
					  FROM ##Tmp_Planner_Search_Templates t
					       INNER JOIN Planner_Template_Filters ptf
					               ON ptf.Planner_Template_ID = t.Planner_Template_ID
					                  AND ptf.Allow_Filter = 1
					                  AND ptf.PG_Group_Type = 1
					       INNER JOIN Planner_Template_Filters_Products p
					               ON p.Planner_Template_ID = ptf.Planner_Template_ID
					                  AND p.Product_Group_level_ID = ptf.Group_Level_ID

					SELECT DISTINCT s.Planner_Template_ID,
					                t.Filter_Type_Count,
					                s.Product_Group_Level_ID,
					                m.BSA_Foodservice_Items_Master_ID
					  INTO ##Tmp_Planner_Search_PGT_Prod
					  FROM ##Tmp_Planner_Search_PGT s
					       INNER JOIN ##Tmp_Planner_Search_Templates t
					               ON t.Planner_Template_ID = s.Planner_Template_ID
					       INNER JOIN All_Product_Group_Type_Members m
					               ON m.Product_Group_Level_ID = s.Product_Group_Level_ID
					                  AND m.Product_Group_ID = s.Product_Group_ID

					SELECT Planner_Template_ID,
					       Filter_Type_Count,
					       BSA_Foodservice_Items_Master_ID,
					       Count(DISTINCT Product_Group_Level_ID) AS cnt
					  INTO ##Tmp_Planner_Search_Template_Filter_Products_Allowed
					  FROM ##Tmp_Planner_Search_PGT_Prod
					 GROUP BY Planner_Template_ID,
					          Filter_Type_Count,
					          BSA_Foodservice_Items_Master_ID
					HAVING Count(DISTINCT Product_Group_Level_ID) >= Filter_Type_Count
					UNION
					SELECT Planner_Template_ID,
					       Filter_Type_Count,
					       NULL AS BSA_Foodservice_Items_Master_ID,
					       0    AS cnt
					  FROM ##Tmp_Planner_Search_Templates
					 WHERE Filter_Type_Count = 0

                    SELECT p.Planner_ID,
                           p.Customer_ID AS Distributor_ID
                      INTO ##Tmp_Search_Planner_Distributors
                      FROM ##Tmp_Planner_Search_Result p
                     WHERE Isnull(p.Distributor_Group_Level_ID, 0) = 0
                    		AND p.Category NOT IN ( #listQualify( request.planner_indirect_categories, "'" )# )
                    UNION
                    SELECT p.Planner_ID,
                           gm.Distributor_ID
                      FROM ##Tmp_Planner_Search_Result p
                           INNER JOIN Planner_Customer_Group_Members gm
                                   ON gm.Planner_ID = p.Planner_ID
                     WHERE p.Category NOT IN ( #listQualify( request.planner_indirect_categories, "'" )# )
					UNION
                    SELECT p.Planner_ID,
                           '00000000-0000-0000-0000-000000000000' as Distributor_ID
                      FROM ##Tmp_Planner_Search_Result p
                     WHERE p.Category IN ( #listQualify( request.planner_indirect_categories, "'" )# )

					<!--- Tmp_Search_Planner_Operators --->
					 SELECT DISTINCT p.Planner_ID,
                           	CASE WHEN p.Category IN ( #listQualify( request.planner_indirect_categories, "'" )# )
							   		THEN po.BSA_Operator_ID
									ELSE 0
							END as BSA_Operator_ID
                      INTO ##Tmp_Search_Planner_Operators
                      FROM ##Tmp_Planner_Search_Result p
						LEFT JOIN Planner_Operators po
							ON po.Planner_ID = p.Planner_ID

                    SELECT DISTINCT p.Planner_ID
                      INTO ##Tmp_Search_Planners_With_Prod
                      FROM ##Tmp_Planner_Search_Result p
                           INNER JOIN Planner_Week pw
                                   ON pw.Planner_Week_Start_Date >= p.PL_Start_Date
                                      AND pw.Planner_Week_End_Date <= p.PL_End_Date
                           INNER JOIN Planner_Volume_Plan pvp
                                   ON pvp.Planner_Week_ID = pw.Planner_Week_ID
                                      AND EXISTS (SELECT 1
                                                    FROM ##Tmp_Search_Planner_Distributors dist
                                                   WHERE dist.Planner_ID = p.Planner_ID
                                                         and dist.Distributor_ID = pvp.BSA_Foodservice_Customers_ID)
                                      AND EXISTS (SELECT 1
                                                    FROM ##Tmp_Search_Planner_Operators op
                                                   WHERE op.Planner_ID = p.Planner_ID
                                                         and op.BSA_Operator_ID = pvp.BSA_Operator_ID)
                                      AND EXISTS (SELECT 1
                                                    FROM ##Tmp_Filter_Products prod
                                                   WHERE prod.BSA_Foodservice_Items_Master_ID = pvp.BSA_Foodservice_Items_Master_ID)
									<cfif local.filterSegment>
                                      AND pvp.Business_Segment_ID = p.Business_Segment_ID
									</cfif>
                  AND EXISTS (SELECT 1
                                FROM ##Tmp_Planner_Search_Template_Filter_Products_Allowed templateFilter
                               WHERE templateFilter.Planner_Template_ID = p.Planner_Template_ID
                                     AND ( templateFilter.Filter_Type_Count = 0
                                            OR templateFilter.BSA_Foodservice_Items_Master_ID = pvp.BSA_Foodservice_Items_Master_ID ))

                    /* remove planner that does not include the selected products  */
                    DELETE ##Tmp_Planner_Search_Result
                     WHERE NOT EXISTS (SELECT 1
                                         FROM ##Tmp_Search_Planners_With_Prod f
                                        WHERE f.Planner_ID = ##Tmp_Planner_Search_Result.Planner_ID)
                </cfquery>
            </cfif>

            <cfquery name="qGetPlanner" datasource="#application.datasource#">
                DECLARE @id_format AS VARCHAR(10)
                SET @id_format = '0000000000'

                /* use display_order to group parent planner and child planners together */

                /* parent planners have 'self planner id-0000000000' */
                UPDATE ##Tmp_Planner_Search_Result
                   SET Display_Order = FORMAT(Planner_ID, @id_format) + '-' + FORMAT(9999999999, @id_format)
                      ,Indirect_Planners_Count = ISNULL((SELECT COUNT(1) FROM ##Tmp_Planner_Search_Result b WHERE b.Parent_Planner_ID = ##Tmp_Planner_Search_Result.Planner_ID), 0)
                      ,Indirect_Programs_Count = ISNULL((SELECT SUM(Program_Count) FROM ##Tmp_Planner_Search_Result b WHERE b.Parent_Planner_ID = ##Tmp_Planner_Search_Result.Planner_ID), 0)
                 WHERE Parent_Planner_ID IS NULL

                /* child planners have 'parent planner id-self planner id' */
                UPDATE ##Tmp_Planner_Search_Result
                   SET Display_Order = FORMAT(Parent_Planner_ID, @id_format) + '-' + FORMAT(Planner_ID, @id_format)
                 WHERE Parent_Planner_ID IS NOT NULL

                <!---  Update program counts for - under review, pending approval, agreed --->
                <cfif local.include_cra_logic EQ 1>
                UPDATE  ##Tmp_Planner_Search_Result
                SET     Under_Review_Count = (
                            SELECT  Count(1)
                            FROM    ##Tmp_Approved_Planner_Programs cm
                            WHERE   cm.Planner_ID = ##Tmp_Planner_Search_Result.Planner_ID
                            AND     cm.Program_Sub_Status_ID = 101 <!--- Under review --->
                )

                UPDATE  ##Tmp_Planner_Search_Result
                SET     Pending_approval_Count = (
                            SELECT  Count(1)
                            FROM    ##Tmp_Approved_Planner_Programs cm
                            WHERE   cm.Planner_ID = ##Tmp_Planner_Search_Result.Planner_ID
                            AND     cm.Program_Sub_Status_ID = 102 <!--- pending approval --->
                )

                UPDATE  ##Tmp_Planner_Search_Result
                SET     Agreed_Count = (
                            SELECT  Count(1)
                            FROM    ##Tmp_Approved_Planner_Programs cm
                            WHERE   cm.Planner_ID = ##Tmp_Planner_Search_Result.Planner_ID
                            AND     cm.Program_Sub_Status_ID = 103 <!--- agreed --->
                )
                </cfif>


				<!--- Return results --->
				SELECT
				*, convert(nvarchar(8), getdate(), 112) as currentTime
				FROM    ##Tmp_Planner_Search_Result
				WHERE   1 = 1
				<!--- Include Indirect --->
                <cfif arguments.include_indirect eq "1" and arguments.include_direct eq "1">
                    AND 1 = 1
                <cfelseif arguments.include_indirect eq "1" or arguments.Planner_Type EQ "I">
                    AND Parent_Planner_ID IS NOT NULL
                <cfelse>
                    AND Parent_Planner_ID IS NULL
                </cfif>
				<cfif local.planner_status EQ "2" and local.planner_sub_status NEQ "0">
					AND Sub_Status_ID = #local.planner_sub_status#
					AND Parent_Planner_ID IS NULL
				</cfif>
				<!---**************************************** Planner Status = 3 Approved ****************************************--->
				<cfif local.planner_status EQ "3" and local.planner_sub_status NEQ "0" and local.called_from neq "reassign">
					AND EXISTS (
						   SELECT	1
							FROM	##Tmp_Approved_Planner_Programs cm
                            WHERE   (cm.Planner_ID = ##Tmp_Planner_Search_Result.Planner_ID
                                    OR cm.Parent_Planner_ID = ##Tmp_Planner_Search_Result.Planner_ID
                                    ) <!--- Include direct if indirect has programs --->
							AND     cm.Program_Sub_Status_ID = #local.planner_sub_status#
						)
				</cfif>
                ORDER BY Display_Order DESC
			</cfquery>

        </cfoutput>

		<cfreturn qGetPlanner />

	</cffunction>

	<cffunction name="getPlannerScorecardCount" returntype="query" access="remote">

		<cfscript>
			local.qSearchResult = searchPlanners(from_scorecard=1);
		</cfscript>

		<!--- Drop all temp tables --->
		<cfquery name="temp_Table_Drop" datasource="#application.datasource#">
			if object_id('tempdb..##Tmp_Planner_Status') is not null
			drop table ##Tmp_Planner_Status
			if object_id('tempdb..##Tmp_Approved_Planner_Program_Status') is not null
			drop table ##Tmp_Approved_Planner_Program_Status
		</cfquery>

		<cfquery name="qPlannerScorecardCount" datasource="#application.datasource#">

			<!--- Get planner status list --->
			<cfif this.profileSettings.RFA_Agreed EQ 1 OR this.profileSettings.RFA_Agreed EQ 2>
				<!--- RFA is split into Under Reeview, Pending Approval and Agreed --->
				SELECT  s.Status_ID, s.Status_Description, 0 as Sub_Status_ID, s.Status_Description as Sub_Status_Desc
				INTO    ##Tmp_Planner_Status
				FROM    Planner_Status s
				WHERE   s.Status_ID NOT IN (2)
				UNION
				SELECT  s.Status_ID, s.Status_Description, 100 + pas.Program_Agree_Status_ID as Sub_Status_ID, pas.Program_Agree_Status_Desc as Sub_Status_Desc
				FROM    Planner_Status s
				INNER JOIN Program_Agree_Status pas ON  1 = 1
				WHERE   s.Status_ID = 2
			<cfelse>
				<!--- RFA is not split --->
				SELECT  s.Status_ID, s.Status_Description, 0 as Sub_Status_ID, s.Status_Description as Sub_Status_Desc
				INTO    ##Tmp_Planner_Status
				FROM    Planner_Status s
			</cfif>

			<!--- Approved planners: Get program status list --->
			create table ##Tmp_Approved_Planner_Program_Status (Sub_Status_ID int, Sub_Status_Desc varchar(200), Approved_Status_Order int)

			<cfif this.profileSettings.RFA_Agreed EQ 1 OR this.profileSettings.RFA_Agreed EQ 2>
				<!--- RFA is split into Under Reeview, Pending Approval and Agreed --->
				insert into ##Tmp_Approved_Planner_Program_Status
				SELECT  100 + Program_Agree_Status_ID as Sub_Status_ID, 'PRG ' + Program_Agree_Status_Desc as Sub_Status_Desc, 2 as Approved_Status_Order
				FROM    Program_Agree_Status
			<cfelse>
				<!--- RFA is not split --->
				insert into ##Tmp_Approved_Planner_Program_Status
				SELECT 2 as Sub_Status_ID, 'PRG Req For Approval' as Sub_Status_Desc, 2 as Approved_Status_Order
			</cfif>
			insert into ##Tmp_Approved_Planner_Program_Status
			SELECT 10 as Sub_Status_ID, 'PRG Pending Accept' as Sub_Status_Desc, 10 as Approved_Status_Order

			<!--- Get count per status --->
			SELECT  1 as Display_Order, 'Planner' as Record_type, s.Status_ID, s.Status_Description, s.Sub_Status_ID, s.Sub_Status_Desc, Count(p.Planner_ID) as Planner_Count, null as Program_Count, 1 as Approved_Status_Order
			FROM    ##Tmp_Planner_Status s
			LEFT JOIN ##Tmp_Planner_Search_Result p
			ON      p.Status_ID = s.Status_ID
			AND     p.Sub_Status_ID = s.Sub_Status_ID
			AND     p.Parent_Planner_ID IS NULL <!--- Planner scorecard will not include indirect planners --->
			GROUP BY s.Status_ID, s.Status_Description, s.Sub_Status_ID, s.Sub_Status_Desc
			UNION
			SELECT  2 as Display_Order, 'Program' as Record_type, 3 as Status_ID, '' as Status_Description, s.Sub_Status_ID, s.Sub_Status_Desc, null as Planner_Count, count(p.Contract_Main_ID) as Program_Count, s.Approved_Status_Order
			FROM    ##Tmp_Approved_Planner_Program_Status s
			LEFT JOIN ##Tmp_Approved_Planner_Programs p
			ON      p.Program_Sub_Status_ID = s.Sub_Status_ID
			GROUP BY s.Sub_Status_ID, s.Sub_Status_Desc, s.Approved_Status_Order
			ORDER BY Display_Order, Status_ID, Approved_Status_Order, Sub_Status_ID
		</cfquery>

		<cfreturn	qPlannerScorecardCount />

	</cffunction>

	<cffunction name="getPlannerStatus" returntype="query" access="remote">

		<cfquery name="qGetStatus" datasource="#application.datasource#">
			<!--- Planner Status --->
			SELECT
				Status_ID,
				Status_Description + ' [' + Status_Abbreviation + ']' as Status_Description,
				Status_Abbreviation,
				CAST(Status_ID as varchar(10)) + '-0' as Use_Status_ID,
				Status_Order,
				1 as Sort_Order_1,
				0 as Program_Agree_Status_ID
			FROM Planner_Status
			<!--- Planner: Under Review, Pending Approval, Agreed --->
			<cfif this.profileSettings.RFA_Agreed EQ 1 OR this.profileSettings.RFA_Agreed EQ 2>
				UNION
				SELECT
					Status_ID,
					Program_Agree_Status.Program_Agree_Status_Desc as Status_Description,
					Status_Abbreviation,
					CAST(Status_ID as varchar(10)) + '-' + CAST(100 + Program_Agree_Status.Program_Agree_Status_ID as varchar(10)) as Use_Status_ID,
					Status_Order,
					2 as Sort_Order_1,
					Program_Agree_Status.Program_Agree_Status_ID
				FROM Planner_Status
				INNER JOIN Program_Agree_Status ON 1 = 1
				WHERE 	Planner_Status.Status_ID = 2
				<!--- Program: Under Review, Pending Approval, Agreed --->
				UNION
				SELECT
					Status_ID,
					' PRG ' + ISNULL(Program_Agree_Status.Program_Agree_Status_Desc, Status_Description) as Status_Description,
					Status_Abbreviation,
					CAST(Status_ID as varchar(10)) + '-' + CAST(100 + Program_Agree_Status.Program_Agree_Status_ID as varchar(10)) as Use_Status_ID,
					Status_Order,
					3 as Sort_Order_1,
					Program_Agree_Status.Program_Agree_Status_ID
				FROM Planner_Status
				INNER JOIN Program_Agree_Status ON 1 = 1
				WHERE 	Planner_Status.Status_ID = 3
			<cfelse>
				UNION
				SELECT
					Status_ID,
					' PRG ' + 'Request For Approval' as Status_Description,
					Status_Abbreviation,
					CAST(Status_ID as varchar(10)) + '-2' as Use_Status_ID,
					Status_Order,
					3 as Sort_Order_1,
					2 as Program_Agree_Status_ID
				FROM Planner_Status
				WHERE 	Planner_Status.Status_ID = 3
			</cfif>
			<!--- Program: Pending Accept --->
			UNION
			SELECT
				Status_ID,
				' PRG ' + 'Pending Accept' as Status_Description,
				Status_Abbreviation,
				CAST(Status_ID as varchar(10)) + '-10' as Use_Status_ID,
				Status_Order,
				3 as Sort_Order_1,
				10 as Program_Agree_Status_ID
			FROM Planner_Status
			WHERE 	Planner_Status.Status_ID = 3
			ORDER BY Sort_Order_1, Status_Order, Program_Agree_Status_ID
		</cfquery>

		<cfreturn qGetStatus />

	</cffunction>

	<!--- get positions below me --->
	<cffunction name="getPositionsBelowMe" returntype="string" access="remote">

		<cfset local.UserPositionList = this.UserPositionList />

		<cfquery name="qGetPositionsBelowMe" datasource="#application.datasource#">
			SELECT DISTINCT Below_User_Positions_Id
			FROM   Positions_Below_Me
			WHERE  User_Positions_Id IN ( <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.UserPositionList#" list="true"> )
		</cfquery>

		<cfreturn valueList(qGetPositionsBelowMe.Below_User_Positions_Id) />

	</cffunction>

	<!--- get distributors below me --->
	<cffunction name="plannersWithDistUnderMe" returntype="string" access="remote">

		<cfargument name="PositionsBelowMe" 	required="true" type="string" />

		<cfset local.UserPositionList = this.UserPositionList />
		<cfset local.HQUser           = this.getUserIsHQ />

		<cfquery name="qPlannersWithDistUnderMe" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##Mydistributors') IS NOT NULL
				DROP TABLE ##Mydistributors

			CREATE  TABLE ##Mydistributors
			(
			  BSA_Foodservice_Customers_ID UNIQUEIDENTIFIER
			)

			INSERT INTO ##Mydistributors (BSA_FoodService_Customers_ID)
			SELECT	Distinct BSA_FoodService_Customers.BSA_FoodService_Customers_ID
			FROM	BSA_FoodService_Customers
				<cfif this.appSettings.getDistributorMultiPosition()>
					INNER JOIN Market_Distributor
					ON 	Market_Distributor.Deleted = 0
					AND Market_Distributor.Distributor_ID = BSA_FoodService_Customers.BSA_FoodService_Customers_ID
					INNER JOIN Service_Markets
					ON Service_Markets.Service_Market_ID = Market_Distributor.Service_Market_ID
				</cfif>
				INNER JOIN BSA_Foodservice_Brokers
				<cfif this.appSettings.getDistributorMultiPosition()>
					ON BSA_Foodservice_Brokers.Service_Market_ID = Service_Markets.Service_Market_ID
				<cfelse>
					ON BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = BSA_FoodService_Customers.BSA_Foodservice_Brokers_ID
				</cfif>
				AND BSA_Foodservice_Brokers.Deleted = 0
				INNER JOIN User_Positions
				<cfif this.appSettings.getDistributorMultiPosition()>
					ON User_Positions.Service_Market_Id  = Service_Markets.Service_Market_ID
				<cfelse>
					ON User_Positions.Service_Market_Id = bsa_FoodService_Brokers.Service_Market_Id
				</cfif>
				AND User_Positions.Deleted = 0
				WHERE User_Positions.User_Positions_ID IN ( <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.PositionsBelowMe#" list="true"> )
				AND BSA_FoodService_Customers.Deleted = 0
				AND BSA_Foodservice_Customers.Retail_Customer = 1

			<!--- groups --->
			SELECT	DISTINCT Planner_ID
			FROM	##Mydistributors D
					INNER JOIN Planner_Customer_Group_Members
					ON Planner_Customer_Group_Members.Distributor_ID = D.Bsa_foodservice_customers_ID
			UNION
			<!--- customers --->
			SELECT	DISTINCT Planner_ID
			FROM	##Mydistributors D
					INNER JOIN Planners
					ON Planners.Customer_ID = D.Bsa_foodservice_customers_ID
					AND ISNULL(Planners.Distributor_Group_Level_ID, 0) = 0
		</cfquery>

		<cfreturn valueList(qPlannersWithDistUnderMe.Planner_ID) />

	</cffunction>


</cfcomponent>