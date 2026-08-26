<!---
  * ====================================================================================================
  *    @File: \mvc\models\planner\plannerTargets.cfc
  *  @Author: Chris Nguyen
  *    @Date: July 2020
  *
  * @Remarks: Planner Target Library Functions
  *
  * ====================================================================================================
--->
<cfcomponent name="PlannerTargets" displayname="Planner Targets" hint="Library functions for planner targets">

    <cffunction name="getTargets" output="false">
        <cfargument name="ids" required="false">

        <cfquery name="local.qTargets" datasource="#application.datasource#">
            SELECT Planner_Target_Header_ID,
                    th.Fiscal_Year,
                    MainDist.Group_Number AS Main_Distributor_Group_Number,
                    MainDist.Group_Desc   AS Main_Distributor_Group_Desc,
                    th.Active,
                    th.Invoice_Start_Date,
                    th.Invoice_End_Date,
                    th.Sales_Target_Updated_Date,
                    u.Name_First + ' ' + u.Name_Last AS Sales_Target_Updated_By,
                    th.Trade_Target_Updated_Date,
                    u2.Name_First + ' ' + u2.Name_Last AS Trade_Target_Updated_By,
                    th.Target_Adj_Updated_Date,
                    u3.Name_First + ' ' + u3.Name_Last AS Target_Adj_Updated_By,
                    th.Demo_Updated_Date,
                    u4.Name_First + ' ' + u4.Name_Last AS Demo_Updated_By,
                    th.Slotting_Updated_Date,
                    u5.Name_First + ' ' + u5.Name_Last AS Slotting_Updated_By,
                    th.Main_Distributor_Group_ID,
                    th.Main_Distributor_Group_Type,
                    th.Sub_Distributor_Group_Type,
                    th.Main_Product_Group_Type,
                    th.Sub_Product_Group_Type,
                    th.Slotting_Position_Type
            FROM Planner_Target_Header th
                INNER JOIN All_Customer_Group_Types MainDist
                        ON MainDist.Group_GUID = th.Main_Distributor_Group_ID
                            AND MainDist.Distributor_Group_Level_ID = th.Main_Distributor_Group_Type
                LEFT JOIN _Users u
                        ON u.User_ID = th.Sales_Target_Updated_By
                LEFT JOIN _Users u2
                        ON u2.User_ID = th.Trade_Target_Updated_By
                LEFT JOIN _Users u3
                        ON u3.User_ID = th.Target_Adj_Updated_By
                LEFT JOIN _Users u4
                        ON u4.User_ID = th.Demo_Updated_By
                LEFT JOIN _Users u5
                        ON u5.User_ID = th.Slotting_Updated_By
            WHERE 1 = 1
                <cfif structKeyExists(arguments, "ids")>
                    AND th.Planner_Target_Header_ID IN ( #listQualify(arguments.ids, "'", ",", "all")# )
                </cfif>
            ORDER BY Fiscal_Year DESC,
                    Main_Distributor_Group_Number
        </cfquery>

        <cfreturn local.qTargets>
    </cffunction>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

    <cffunction name="getSalesTargets" output="false">
        <cfargument name="id" required="true">

        <cfquery name="local.qTargets" datasource="#application.datasource#">
            SELECT  Main_Product_Group_ID
                    ,Main_Product_Group_Number
                    ,Main_Product_Group_Desc
                    ,Sales_Target_Original
                    ,Sales_Target_Override
                    ,Sales_Target_Override AS X_Sales_Target_Override
                    ,Sales_Target_Final
                    ,Sales_Target_Final - td.Sales_Target_Original AS Sales_Target_Absolute_Variance
                    ,cast(CASE WHEN td.Sales_Target_Original != 0
                            THEN ( td.Sales_Target_Final - td.Sales_Target_Original ) / td.Sales_Target_Original
                            ELSE 0
                        END AS DECIMAL (20, 4)) AS Sales_Target_Percentage_Change
            FROM        (   SELECT      td.Main_Product_Group_ID
                                ,MainProd.Group_Number         AS Main_Product_Group_Number
                                ,MainProd.Group_Desc           AS Main_Product_Group_Desc
                                ,SUM(td.Sales_Target_Original) AS Sales_Target_Original
                                ,SUM(td.Sales_Target_Override) AS Sales_Target_Override
                                ,SUM(td.Sales_Target_Final)    AS Sales_Target_Final
                        FROM    Planner_Target_Header              th
                                INNER JOIN Planner_Target_Detail   td
                                        ON td.Planner_Target_Header_ID = th.Planner_Target_Header_ID
                                INNER JOIN All_Product_Group_Types MainProd
                                        ON MainProd.Group_GUID = td.Main_Product_Group_ID AND   MainProd.Product_Group_Level_ID = th.Main_Product_Group_Type
                        WHERE   th.Planner_Target_Header_ID = #arguments.id#
                        GROUP BY
                                td.Main_Product_Group_ID
                                ,MainProd.Group_Number
                                ,MainProd.Group_Desc ) AS td
            ORDER BY    Main_Product_Group_Number
        </cfquery>

        <cfquery name="local.qTotals" datasource="#application.datasource#">
            SELECT  '' AS Main_Product_Group_ID
                    ,'' AS Main_Product_Group_Number
                    ,'TOTAL' AS Main_Product_Group_Desc
                    ,0.00 AS Sales_Target_Original
                    ,0.00 AS Sales_Target_Override
                    ,0.00 AS X_Sales_Target_Override
                    ,0.00 AS Sales_Target_Final
                    ,0.00 AS Sales_Target_Absolute_Variance
                    ,0.00 AS Sales_Target_Percentage_Change
        </cfquery>

        <cfreturn [ local.qTargets, local.qTotals ]>
    </cffunction>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

    <cffunction name="setSalesTargets" output="false">
        <cfargument name="data" required="true">

        <cfquery datasource="#application.datasource#">
            UPDATE Planner_Target_Header
               SET Sales_Target_Updated_Date = GETDATE()
                   ,Sales_Target_Updated_By = '#request.AccessStructure.User_ID#'
             WHERE Planner_Target_Header_ID = #arguments.data.id#

            /* remove "ITEM-" prefix */
             <cfloop collection="#arguments.data#" item="local.key">
                <cfif listFirst(local.key, "-") is "ITEM">
                    <cfset local.rate_input = arguments.data[ local.key ]>
                    <cfset local.item_id    = mid(local.key, 6, len(local.key) - 5)>

                    UPDATE Planner_Target_Detail
                        <cfif trim(local.rate_input) eq ''>
                            SET Sales_Target_Override = NULL
                                ,Sales_Target_Final = Sales_Target_Original
                        <cfelse>
                            SET Sales_Target_Override = #local.rate_input# * Percent_Per_Main_Product_Group
                                ,Sales_Target_Final    = #local.rate_input# * Percent_Per_Main_Product_Group
                        </cfif>
                     WHERE Planner_Target_Header_ID = #arguments.data.id# AND MAIN_PRODUCT_GROUP_ID = '#local.item_id#'
                </cfif>
             </cfloop>
        </cfquery>
    </cffunction>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

    <cffunction name="getDefaultTradeTargets" output="false">

        <cfquery name="local.qTargets" datasource="#application.datasource#">
			DECLARE @Sub_Product_Group_Type varchar(10),
					@Updated_By varchar(50),
					@Updated_By_User_Name varchar(200),
					@Updated_Date datetime

			SELECT    @Sub_Product_Group_Type = Value
			FROM     _settings
			WHERE    Input_Name = 'Planner_Target_Sub_Prod_Group_Type'

			IF @Sub_Product_Group_Type IS NULL OR @Sub_Product_Group_Type = '' OR @Sub_Product_Group_Type = '0'
			SET @Sub_Product_Group_Type = 12

			SELECT	TOP 1
					@Updated_Date = Updated_Date,
					@Updated_By = Updated_By
			FROM	Planner_Target_Trade_Default d
			ORDER BY Updated_Date Desc

			SELECT	@Updated_By_User_Name = u.Name_First + ' ' + u.Name_Last
			FROM	_Users u
            WHERE	u.User_ID = @Updated_By

            SELECT	g.Group_GUID as Sub_Product_Group_ID
					,g.Group_Number as Sub_Product_Group_Number
					,g.Group_Desc as Sub_Product_Group_Desc
                    ,ISNULL(d.Trade_Rate_Default, 0) AS Trade_Rate_Default
					,@Updated_Date as Updated_Date
					,@Updated_By_User_Name as Updated_By
			FROM	All_Product_Group_Types g
			LEFT JOIN Planner_Target_Trade_Default d
				   ON d.Sub_Product_Group_ID = g.Group_GUID
			WHERE	g.Product_Group_Level_ID = @Sub_Product_Group_Type
			AND		g.Deleted = 0
            ORDER BY    g.Group_Number
        </cfquery>

        <cfreturn local.qTargets>
    </cffunction>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

    <cffunction name="setDefaultTradeTargets" output="false">
        <cfargument name="data" required="true">

		<!--- 1. Save the values into table Planner_Target_Trade_Default --->
        <cfquery datasource="#application.datasource#">
            TRUNCATE TABLE Planner_Target_Trade_Default

            /* remove "ITEM-" prefix */
             <cfloop collection="#arguments.data#" item="local.key">
                <cfif listFirst(local.key, "-") is "ITEM">
                    <cfset local.rate_input = arguments.data[ local.key ]>
                    <cfset local.item_id    = mid(local.key, 6, len(local.key) - 5)>

                    INSERT INTO Planner_Target_Trade_Default (Sub_Product_Group_ID, Trade_Rate_Default, Updated_Date, Updated_By)
					VALUES (
						<cfqueryparam value="#local.item_id#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#local.rate_input#" cfsqltype="CF_SQL_DECIMAL">,
						<!---<cfqueryparam value= #createODBCdatetime(NOW())# cfsqltype="cf_sql_date">,--->
						GetDate(),
						<cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
					)
                </cfif>
             </cfloop>
        </cfquery>

		<!--- 2. Overwrite the original target trade rate for the fiscal year that the user is currently editing the default trade rate from --->
		<cfquery datasource="#application.datasource#">
			DECLARE @Fiscal_Year int

            SELECT 	@Fiscal_Year = Fiscal_Year
			FROM	Planner_Target_Header
			WHERE 	Planner_Target_Header_ID = #arguments.data.id#

			UPDATE	td
			SET		Trade_Rate_Target_Original = d.Trade_Rate_Default,
					Trade_Rate_Target_Final =
						CASE
						WHEN td.Trade_Rate_Target_Override IS NOT NULL THEN td.Trade_Rate_Target_Override
						ELSE d.Trade_Rate_Default
						END
			FROM	Planner_Target_Header th
			INNER JOIN Planner_Target_Detail td
			ON		td.Planner_Target_Header_ID = th.Planner_Target_Header_ID
			INNER JOIN Planner_Target_Trade_Default d
			ON		d.Sub_Product_Group_ID = td.Sub_Product_Group_ID
			WHERE	th.Fiscal_Year = @Fiscal_Year

		</cfquery>

    </cffunction>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

    <cffunction name="getTradeTargets" output="false">
        <cfargument name="id" required="true">

		<cfquery name="local.qDropTable" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmp_trade_targets') IS NOT NULL
			DROP TABLE ##tmp_trade_targets
        </cfquery>

		<cfquery name="local.qTargets" datasource="#application.datasource#">
			SELECT 	th.Sub_Product_Group_Type,
					td.Sub_Product_Group_ID,
					Sum(td.Sales_Target_Original)                                                                      AS Sales_Target_Original,
					Sum(td.Sales_Target_Override)                                                                      AS Sales_Target_Override,
					Sum(td.Sales_Target_Final)                                                                         AS Sales_Target_Final,
					Max(Trade_Rate_Target_Original)                                                                    AS Trade_Rate_Target_Original,
					Sum(CASE WHEN td.Trade_Rate_Target_Override IS NULL THEN 0 ELSE 1 END) AS Has_Override,

                    CASE SUM( td.Sales_Target_Final )
                        WHEN 0 THEN AVG(ISNULL( td.Trade_Rate_Target_Override, Trade_Rate_Target_Original ))
                        ELSE SUM( td.Sales_Target_Final * ISNULL( td.Trade_Rate_Target_Override, Trade_Rate_Target_Original ) ) /  SUM( td.Sales_Target_Final )
                    END AS Trade_Rate_Target_Override,

                    CASE SUM( td.Sales_Target_Final )
                        WHEN 0 THEN AVG( td.Trade_Rate_Target_Final )
                        ELSE SUM( td.Sales_Target_Final * td.Trade_Rate_Target_Final ) / SUM( td.Sales_Target_Final )
                    END AS Trade_Rate_Target_Final,

					Sum(td.Sales_Target_Final * td.Trade_Rate_Target_Final * 0.01)                                            AS Trade_Fund_Final,
					CAST(0 as decimal(20, 2))																			AS Sales_Target_Absolute_Variance,
					CAST(0 as decimal(20, 2))																			AS Sales_Target_Percentage_Change
			INTO	##tmp_trade_targets
			FROM 	Planner_Target_Header th
			INNER JOIN Planner_Target_Detail td
			ON 		td.Planner_Target_Header_ID = th.Planner_Target_Header_ID
			WHERE   th.Planner_Target_Header_ID = #arguments.id#
			GROUP BY th.Sub_Product_Group_Type, td.Sub_Product_Group_ID

			SELECT		Sub_Product_Group_ID,
						SubProd.Group_Number AS Sub_Product_Group_Number,
						SubProd.Group_Desc AS Sub_Product_Group_Desc,
						Sales_Target_Original,
						Sales_Target_Override,
						Sales_Target_Final,
						CAST(Trade_Rate_Target_Original / 100.00 AS DECIMAL(20,3)) AS Trade_Rate_Target_Original,
                        /* Trade_Rate_Target_Original,  */
						CASE Has_Override WHEN 0 THEN NULL ELSE CAST(Trade_Rate_Target_Override / 100.00 AS DECIMAL(20,3)) END AS Trade_Rate_Target_Override,
						CASE Has_Override WHEN 0 THEN NULL ELSE Trade_Rate_Target_Override END AS X_Trade_Rate_Target_Override,
						CAST(Trade_Rate_Target_Final / 100.00 AS DECIMAL(20,3)) AS Trade_Rate_Target_Final,
						CASE
						WHEN td.Sales_Target_Override IS NOT NULL THEN td.Sales_Target_Override - td.Sales_Target_Original
						ELSE 0
						END                         AS Sales_Target_Absolute_Variance,
						Cast(CASE
						WHEN td.Sales_Target_Override IS NOT NULL
							AND td.Sales_Target_Original != 0 THEN ( td.Sales_Target_Override - td.Sales_Target_Original ) / td.Sales_Target_Original
						ELSE 0
						END AS DECIMAL(20, 4)) 		AS Sales_Target_Percentage_Change,
						Trade_Fund_Final
			FROM	##tmp_trade_targets td
			INNER JOIN All_Product_Group_Types SubProd
			ON 		SubProd.Group_GUID = td.Sub_Product_Group_ID
			AND 	SubProd.Product_Group_Level_ID = td.Sub_Product_Group_Type
			ORDER BY Sub_Product_Group_Number
        </cfquery>

        <cfquery name="local.qTotals" datasource="#application.datasource#">
            SELECT '' AS Sub_Product_Group_ID,
                    '' AS Sub_Product_Group_Number,
                    'TOTAL' AS Sub_Product_Group_Desc,
                    0.00 AS Sales_Target_Original,
                    0.00 AS Sales_Target_Override,
                    0.00 AS Sales_Target_Final,
                    0.00 AS Trade_Rate_Target_Original,
                    0.00 AS Trade_Rate_Target_Override,
                    0.00 AS X_Trade_Rate_Target_Override,
                    0.00 AS Trade_Rate_Target_Final,
                    0.00 AS Sales_Target_Absolute_Variance,
                    0.00 AS Sales_Target_Percentage_Change,
                    0.00 AS Trade_Fund_Final
        </cfquery>

        <cfreturn [ local.qTargets, local.qTotals ]>
    </cffunction>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

    <cffunction name="setTradeTargets" output="false">
        <cfargument name="data" required="true">

        <cfquery datasource="#application.datasource#">
            UPDATE Planner_Target_Header
               SET Trade_Target_Updated_Date = GETDATE()
                   ,Trade_Target_Updated_By = '#request.AccessStructure.User_ID#'
             WHERE Planner_Target_Header_ID = #arguments.data.id#

            /* remove "ITEM-" prefix */
             <cfloop collection="#arguments.data#" item="local.key">
                <cfif listFirst(local.key, "-") is "ITEM">
                    <cfset local.rate_input = arguments.data[ local.key ]>
                    <cfset local.item_id    = mid(local.key, 6, len(local.key) - 5)>

                    UPDATE Planner_Target_Detail
                        <cfif trim(local.rate_input) eq ''>
                            SET Trade_Rate_Target_Override = NULL
                                ,Trade_Rate_Target_Final = Trade_Rate_Target_Original
                        <cfelse>
                            SET Trade_Rate_Target_Override = #local.rate_input#
                                ,Trade_Rate_Target_Final   = #local.rate_input#
                        </cfif>
                     WHERE Planner_Target_Header_ID = #arguments.data.id# AND Sub_Product_Group_ID = '#local.item_id#'
                </cfif>
             </cfloop>
        </cfquery>

    </cffunction>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

    <cffunction name="getDistributorGroupLabel" output="false">
        <cfset local.division = 'Planner_Target_Main_Dist_Group_Type'>

        <cfquery name="local.qLabels" datasource="#application.datasource#">
            SELECT      '#local.division#' AS Blackmsith_Label
                        ,Group_Level_Desc  AS Custom_Label
                FROM    Distributor_Group_Level l
                WHERE   l.Distributor_Group_Level_ID = (   SELECT    Value
                                                            FROM     _settings
                                                            WHERE    Input_Name = '#local.division#' )
        </cfquery>

        <cfreturn local.qLabels.recordCount
                        ? local.qLabels.Custom_Label
                        : 'Distributor Group'>
    </cffunction>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

    <cffunction name="getSubProductGroupLabel" output="false">
        <cfset local.groupType = 'Planner_Target_Sub_Prod_Group_Type'>

        <cfquery name="local.qLabels" datasource="#application.datasource#">
            SELECT      Group_Level_Desc  AS Custom_Label
                FROM    Product_Group_Level l
                WHERE   l.Product_Group_Level_ID = (   SELECT    Value
                                                            FROM     _settings
                                                            WHERE    Input_Name = '#local.groupType#' )
        </cfquery>

        <cfreturn local.qLabels.recordCount
                        ? local.qLabels.Custom_Label
                        : 'Product Group'>
    </cffunction>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

    <cffunction name="getDistGroupLabel" output="false">
        <cfargument name="typeID" required="true">

        <cfquery name="local.qLabels" datasource="#application.datasource#">
            SELECT      Group_Level_Desc  AS Custom_Label
                FROM    Distributor_Group_Level l
                WHERE   l.Distributor_Group_Level_ID = #val(arguments.typeID)#
        </cfquery>

        <cfreturn local.qLabels.recordCount
                        ? local.qLabels.Custom_Label
                        : 'Distributor Group'>
    </cffunction>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

    <cffunction name="getProductGroupLabel" output="false">
        <cfargument name="typeID" required="true">

        <cfquery name="local.qLabels" datasource="#application.datasource#">
            SELECT      Group_Level_Desc  AS Custom_Label
                FROM    Product_Group_Level l
                WHERE   l.Product_Group_Level_ID = #val(arguments.typeID)#
        </cfquery>

        <cfreturn local.qLabels.recordCount
                        ? local.qLabels.Custom_Label
                        : 'Product Group'>
    </cffunction>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

    <cffunction name="getPostionTypeLabel" output="false">
        <cfargument name="levelID" required="true">

        <cfset local.positionTypeLabel = "Position" />
        <cfset local.slottingLevel = arguments.levelID />
        <cfif local.slottingLevel eq 0>
            <!--- Headquarters --->
            <cfset local.positionTypeLabel = "Headquarters" />
        <cfelseif local.slottingLevel eq 1>
            <!--- Zone --->
            <cfset local.positionTypeLabel = application.returned_customer_setting.Zone_Label_Plural />
        <cfelseif local.slottingLevel eq 2>
            <!--- Region --->
            <cfset local.positionTypeLabel = application.returned_customer_setting.region_label_plural />
        <cfelseif local.slottingLevel eq 3>
            <!--- Market --->
           <cfset local.positionTypeLabel = application.returned_customer_setting.market_label_plural />
        </cfif>

        <cfreturn local.positionTypeLabel />
    </cffunction>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

    <cffunction name="getFiscalYears" output="false">
        <cfquery name="local.qFY" datasource="#application.datasource#">
            SELECT      DISTINCT
                        Planner_Year
                FROM    Planner_Week pw
                WHERE   Deleted = 0
        </cfquery>

        <cfreturn local.qFY>
    </cffunction>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

    <cffunction name="getDistributorGroupTypes" output="false">
        <cfset local.distTypeFilter = application.util.query.get_setting('Planner_Target_Main_Dist_Group_Filter', 0)>
        <cfset local.distGroupType  = application.util.query.get_setting('Planner_Target_Main_Dist_Group_Type', 0)>

		<cfquery name="local.qTypes" datasource="#application.datasource#">
            SELECT  Group_Desc, Group_Guid, Group_Number
              FROM  All_Customer_Group_Types
             WHERE  Distributor_Group_Level_ID = '#local.distGroupType#'
			        AND Deleted = 0
			        <cfif local.distTypeFilter neq "">
			            AND	Group_Number IN (<cfqueryparam value="#local.distTypeFilter#" cfsqltype="CF_SQL_VARCHAR" list="yes">)
			        </cfif>
        </cfquery>

        <cfreturn local.qTypes>
    </cffunction>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <cffunction name="setTargetStatus" output="false" access="remote">
        <cfargument name="id" required="true">
        <cfargument name="active" required="true">

        <cfquery datasource="#application.datasource#">
            UPDATE Planner_Target_Header
               SET Active = #arguments.active#
             WHERE Planner_Target_Header_ID = #arguments.id#
        </cfquery>
    </cffunction>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

    <cffunction name="getTargetAdjustments" output="false" access="remote">
        <cfargument name="id" required="true">

		<cfquery name="local.qAdjustments" datasource="#application.datasource#">
                SELECT
                    td.Sub_Product_Group_ID,
					td.Sub_Distributor_Group_ID,
                    SubProd.Group_Number               AS Sub_Product_Group_Number,
					SubProd.Group_Desc                 AS Sub_Product_Group_Desc,
					SubDist.Group_Number               AS Sub_Distributor_Group_Number,
					SubDist.Group_Desc                 AS Sub_Distributor_Group_Desc,
                    Sales_Target_Original,
                    Sales_Target_Override,
                    Sales_Target_Override AS X_Sales_Target_Override,
                    Sales_Target_Final,
                    CAST(Trade_Rate_Target_Original / 100.00 AS DECIMAL(20,3)) AS Trade_Rate_Target_Original,
					Trade_Rate_Target_Override,
                    Trade_Rate_Target_Override AS X_Trade_Rate_Target_Override,
                    CAST(Trade_Rate_Target_Final / 100.00 AS DECIMAL(20,3)) AS Trade_Rate_Target_Final,
                    CASE
                        WHEN td.Sales_Target_Override IS NOT NULL THEN td.Sales_Target_Override - td.Sales_Target_Original
                        ELSE 0
                    END   AS Sales_Target_Absolute_Variance,
                    Cast(CASE
                                WHEN td.Sales_Target_Override IS NOT NULL
                                    AND td.Sales_Target_Original != 0 THEN ( td.Sales_Target_Override - td.Sales_Target_Original ) / td.Sales_Target_Original
                                ELSE 0
                            END AS DECIMAL(20, 4))                                                                            AS Sales_Target_Percentage_Change,         /* 100 */
                    Sales_Target_Original * Trade_Rate_Target_Original * 0.01                                                        AS Trade_Fund_Original,
                    Sales_Target_Final * Trade_Rate_Target_Final * 0.01                                                              AS Trade_Fund_Final,
                    ( Sales_Target_Final * Trade_Rate_Target_Final * 0.01 ) - ( Sales_Target_Original * Trade_Rate_Target_Original * 0.01 ) AS Trade_Fund_Absolute_Variance,
                    Cast(CASE
                                WHEN ( Sales_Target_Original * Trade_Rate_Target_Original ) != 0 THEN ( ( Sales_Target_Final * Trade_Rate_Target_Final ) - ( Sales_Target_Original * Trade_Rate_Target_Original ) ) / ( Sales_Target_Original * Trade_Rate_Target_Original )
                                ELSE 0
                            END AS DECIMAL(20, 4))                                                                            AS Trade_Fund_Percentage_Change,     /* 100 */
                    Approved_Incremental_Funds,
                    Approved_Incremental_Funds AS X_Approved_Incremental_Funds
                FROM (SELECT
                            td.Sub_Product_Group_ID,
							td.Sub_Distributor_Group_ID,
							th.Sub_Product_Group_Type,
							th.Sub_Distributor_Group_Type,
                            Sum(td.Sales_Target_Original)      AS Sales_Target_Original,
                            Sum(td.Sales_Target_Override)      AS Sales_Target_Override,
                            Sum(td.Sales_Target_Final)         AS Sales_Target_Final,
                            Max(Trade_Rate_Target_Original)    AS Trade_Rate_Target_Original,
                            Max(Trade_Rate_Target_Override) / 100.00    AS Trade_Rate_Target_Override, <!--- Need to divide by 100 to resolve UI issue. 26.0% was being displayed at 2,600.0% --->
                            Max(Trade_Rate_Target_Final)       AS Trade_Rate_Target_Final,
                            Sum(td.Approved_Incremental_Funds) AS Approved_Incremental_Funds
                        FROM Planner_Target_Header th
                            INNER JOIN Planner_Target_Detail td
                                    ON td.Planner_Target_Header_ID = th.Planner_Target_Header_ID
                        WHERE th.Planner_Target_Header_ID = #arguments.id#
                        GROUP BY td.Sub_Product_Group_ID,
								td.Sub_Distributor_Group_ID,
                                th.Sub_Product_Group_Type,
                                th.Sub_Distributor_Group_Type) AS td
				INNER JOIN All_Product_Group_Types SubProd
						ON SubProd.Group_GUID = td.Sub_Product_Group_ID
							AND SubProd.Product_Group_Level_ID = td.Sub_Product_Group_Type
				INNER JOIN All_Customer_Group_Types SubDist
						ON SubDist.Group_GUID = td.Sub_Distributor_Group_ID
							AND SubDist.Distributor_Group_Level_ID = td.Sub_Distributor_Group_Type
                ORDER BY Sub_Distributor_Group_Desc, Sub_Product_Group_Desc
        </cfquery>

        <!--- TRADE_RATE_TARGET_FINAL --->
        <cfquery name="local.qTotals" datasource="#application.datasource#">
            SELECT
                '' AS Sub_Product_Group_ID,
                '' AS Sub_Distributor_Group_ID,
                '' AS Sub_Product_Group_Number,
                '' AS Sub_Product_Group_Desc,
                '' AS Sub_Distributor_Group_Number,
                'TOTAL' AS Sub_Distributor_Group_Desc,
                0.00 AS Sales_Target_Original,
                0.00 AS Sales_Target_Override,
                0.00 AS X_Sales_Target_Override,
                0.00 AS Sales_Target_Final,
                0.00 AS Trade_Rate_Target_Override,
                0.00 AS X_Trade_Rate_Target_Override,
                0.00 AS Sales_Target_Absolute_Variance,
                0.00 AS Trade_Fund_Original,
                0.00 AS Trade_Fund_Final,
                0.00 AS Trade_Fund_Absolute_Variance,
                0.00 AS Approved_Incremental_Funds,
                0.00 AS X_Approved_Incremental_Funds,
                0.00 AS Trade_Rate_Target_Original,
                0.00 AS Trade_Rate_Target_Final,
                0.00 AS Sales_Target_Percentage_Change,
                0.00 AS Trade_Fund_Percentage_Change
        </cfquery>

        <cfreturn [ local.qAdjustments, local.qTotals ]>
    </cffunction>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

    <cffunction name="setTargetAdjustments" output="false">
        <cfargument name="data" required="true">

        <cfset local.delimiter = "$">

        <cfquery datasource="#application.datasource#">
            UPDATE Planner_Target_Header
               SET Target_Adj_Updated_Date = GETDATE()
                   ,Target_Adj_Updated_By = '#request.AccessStructure.User_ID#'
             WHERE Planner_Target_Header_ID = #arguments.data.id#

            <!---  scan thru all form input elements  --->
            <cfloop collection="#arguments.data#" item="local.key">
                <!---  include only input element with 3 components in it  --->
                <cfif listLen(local.key, local.delimiter) eq 3>
                    <cfscript>
                        local.sub_keys    = listToArray(local.key, local.delimiter);
                        local.column_name = local.sub_keys[1];      //* 1st component = front-end column name */
                        local.dist_id     = local.sub_keys[2];      //* 2nd component = distributor group id */
                        local.item_id     = local.sub_keys[3];      //* 3rd component = item group id */
                        local.rate_input  = arguments.data[ local.key ];
                    </cfscript>

                    <cfif local.column_name is "SALES_TARGET_OVERRIDE">
                        UPDATE Planner_Target_Detail
                            <cfif trim(local.rate_input) eq ''>
                                SET Sales_Target_Override = NULL
                                    ,Sales_Target_Final   = Sales_Target_Original
                            <cfelse>
                                SET Sales_Target_Override = #local.rate_input# * Percent_Per_Sub_Product_Sub_Distributor_Group
                                    ,Sales_Target_Final   = #local.rate_input# * Percent_Per_Sub_Product_Sub_Distributor_Group
                            </cfif>
                        WHERE Planner_Target_Header_ID = #arguments.data.id#
                                AND Sub_Distributor_Group_ID = '#local.dist_id#'
                                AND Sub_Product_Group_ID = '#local.item_id#'
                    </cfif>

                    <cfif local.column_name is "TRADE_RATE_TARGET_OVERRIDE">
                        UPDATE Planner_Target_Detail
                            <cfif trim(local.rate_input) eq ''>
                                SET Trade_Rate_Target_Override = NULL
                                    ,Trade_Rate_Target_Final   = Trade_Rate_Target_Original
                            <cfelse>
                                SET Trade_Rate_Target_Override = #local.rate_input#
                                    ,Trade_Rate_Target_Final = #local.rate_input#
                            </cfif>
                        WHERE Planner_Target_Header_ID = #arguments.data.id#
                                AND Sub_Distributor_Group_ID = '#local.dist_id#'
                                AND Sub_Product_Group_ID = '#local.item_id#'
                    </cfif>

                    <cfif local.column_name is "APPROVED_INCREMENTAL_FUNDS">
                        UPDATE Planner_Target_Detail
                            <cfif trim(local.rate_input) eq ''>
                                SET Approved_Incremental_Funds = NULL
                            <cfelse>
                                SET Approved_Incremental_Funds = #local.rate_input# * Percent_Per_Sub_Product_Sub_Distributor_Group
                            </cfif>
                        WHERE Planner_Target_Header_ID = #arguments.data.id#
                                AND Sub_Distributor_Group_ID = '#local.dist_id#'
                                AND Sub_Product_Group_ID = '#local.item_id#'
                    </cfif>
                </cfif>
            </cfloop>
        </cfquery>
    </cffunction>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

    <cffunction name="getDemos" output="false" access="remote">
        <cfargument name="id" required="true">

        <cfquery name="local.qDemos" datasource="#application.datasource#">
            SELECT Sub_Product_Group_ID,
                Sub_Distributor_Group_ID,
                SubProd.Group_Number                              AS Sub_Product_Group_Number,
				SubProd.Group_Desc                                AS Sub_Product_Group_Desc,
				SubDist.Group_Number                              AS Sub_Distributor_Group_Number,
				SubDist.Group_Desc                                AS Sub_Distributor_Group_Desc,
                Sales_Target_Final,
                CAST(Trade_Rate_Target_Final / 100.00 AS DECIMAL(20,3)) AS Trade_Rate_Target_Final,
                Trade_Fund_Final,
                Approved_Incremental_Funds,
                Demo_Fund,
                Demo_Fund AS X_Demo_Fund,
                Demo_Fund_Override,
                Demo_Fund_Override AS X_Demo_Fund_Override,
                Demo_Fund_Final
            FROM (SELECT td.Sub_Product_Group_ID,
                        td.Sub_Distributor_Group_ID,
						th.Sub_Product_Group_Type,
						th.Sub_Distributor_Group_Type,
                        Sum(td.Sales_Target_Final)                        AS Sales_Target_Final,
                        Max(Trade_Rate_Target_Final)                      AS Trade_Rate_Target_Final,
                        Sum(Sales_Target_Final * Trade_Rate_Target_Final * 0.01) AS Trade_Fund_Final,
                        Sum(td.Approved_Incremental_Funds)                AS Approved_Incremental_Funds,
                        Sum(td.Demo_Fund)                                 AS Demo_Fund,
                        Sum(td.Demo_Fund_Override)                        AS Demo_Fund_Override,
                        Sum(td.Demo_Fund_Final)                           AS Demo_Fund_Final
                    FROM Planner_Target_Header th
                        INNER JOIN Planner_Target_Detail td
                                ON td.Planner_Target_Header_ID = th.Planner_Target_Header_ID
                    WHERE th.Planner_Target_Header_ID = #arguments.id#
                    GROUP BY td.Sub_Product_Group_ID,
                            td.Sub_Distributor_Group_ID,
                            th.Sub_Product_Group_Type,
                            th.Sub_Distributor_Group_Type) AS td
			INNER JOIN All_Product_Group_Types SubProd
					ON SubProd.Group_GUID = td.Sub_Product_Group_ID
						AND SubProd.Product_Group_Level_ID = td.Sub_Product_Group_Type
			INNER JOIN All_Customer_Group_Types SubDist
					ON SubDist.Group_GUID = td.Sub_Distributor_Group_ID
						AND SubDist.Distributor_Group_Level_ID = td.Sub_Distributor_Group_Type
            -- ORDER BY Sub_Product_Group_Number
            ORDER BY Sub_Distributor_Group_Desc, Sub_Product_Group_Desc
        </cfquery>

        <cfquery name="local.qTotals" datasource="#application.datasource#">
            SELECT
                    '' AS Sub_Product_Group_ID
                    ,'' AS Sub_Distributor_Group_ID
                    ,'' AS Sub_Product_Group_Number
                    ,'TOTAL' AS Sub_Product_Group_Desc
                    ,'' AS Sub_Distributor_Group_Number
                    ,'' AS Sub_Distributor_Group_Desc
                    ,0.00 AS Sales_Target_Final
                    ,0.00 AS Trade_Fund_Final
                    ,0.00 AS Approved_Incremental_Funds
                    ,0.00 AS Demo_Fund
                    ,0.00 AS X_Demo_Fund
                    ,0.00 AS Demo_Fund_Override
                    ,0.00 AS X_Demo_Fund_Override
                    ,0.00 AS Demo_Fund_Final
                    ,0.00 AS Trade_Rate_Target_Final
        </cfquery>

        <cfreturn [ local.qDemos, local.qTotals ]>
    </cffunction>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

    <cffunction name="setDemos" output="false" access="remote">
        <cfargument name="data" required="true">

        <cfset local.delimiter = "$">

        <cfquery datasource="#application.datasource#" result="local.qResult">
            UPDATE Planner_Target_Header
               SET Demo_Updated_Date = GETDATE()
                   ,Demo_Updated_By = '#request.AccessStructure.User_ID#'
             WHERE Planner_Target_Header_ID = #arguments.data.id#

            <!---  scan thru all form input elements --->
            <cfloop collection="#arguments.data#" item="local.key">
                <!---  include only input element with 3 components in it  --->
                <cfif listLen(local.key, local.delimiter) eq 3>
                    <cfscript>
                        local.sub_keys    = listToArray(local.key, local.delimiter);
                        local.column_name = local.sub_keys[1];      //* 1st component = front-end column name */
                        local.dist_id     = local.sub_keys[2];      //* 2nd component = distributor group id */
                        local.item_id     = local.sub_keys[3];      //* 3rd component = item group id */
                        local.rate_input  = arguments.data[ local.key ];

                        local.demo_fund_override = arguments.data[ "DEMO_FUND_OVERRIDE" & local.delimiter
                                                                    & local.dist_id & local.delimiter
                                                                    & local.item_id ];
                    </cfscript>

                    <cfif local.column_name is "DEMO_FUND">
                        UPDATE Planner_Target_Detail
                            <cfif trim(local.rate_input) eq ''>
                                SET Demo_Fund = NULL
                            <cfelse>
                                SET Demo_Fund = #local.rate_input# * Percent_Per_Sub_Product_Sub_Distributor_Group
                            </cfif>
                            <cfif trim(local.demo_fund_override) eq '' or trim(local.demo_fund_override) eq 'null' or trim(local.demo_fund_override) eq '0'>
                                    ,Demo_Fund_Override = NULL
                                    ,Demo_Fund_Final    = #local.rate_input# * Percent_Per_Sub_Product_Sub_Distributor_Group
                            <cfelse>
                                    ,Demo_Fund_Override = #local.demo_fund_override# * Percent_Per_Sub_Product_Sub_Distributor_Group
                                    ,Demo_Fund_Final    = #local.demo_fund_override# * Percent_Per_Sub_Product_Sub_Distributor_Group
                            </cfif>
                        WHERE Planner_Target_Header_ID = #arguments.data.id#
                                AND Sub_Distributor_Group_ID = '#local.dist_id#'
                                AND Sub_Product_Group_ID = '#local.item_id#'
                    </cfif>
                </cfif>
            </cfloop>
        </cfquery>

        <!--- <cfset request.dumpToEmail_address = "cnguyen@blacksmithapplications.com"> <cfset application.util.io.dumpToEmail(local)> --->
    </cffunction>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

    <cffunction name="getSlotting" output="false" access="remote">
        <cfargument name="id" required="true">

        <cfset useLakebaseForlocal_qSlottingHeader = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("planner_target_header")>
<cfif useLakebaseForlocal_qSlottingHeader>
	<cftry>
		<cfset local.qSlottingHeader = application.oLakebase.toQuery(
			application.oLakebase.selectRows("planner_target_header", {
				"planner_target_header_id" = "eq.#arguments.id#",
				"select" = "'not_released' as user_positions_id,'not released' as position_label,slotting_position_type,not_released_slotting_fund as slotting_fund,not_released_slotting_fund_final as slotting_fund_final,not_released_slotting_fund_override as slotting_fund_override,not_released_slotting_fund as x_slotting_fund,not_released_slotting_fund_final as x_slotting_fund_final,not_released_slotting_fund_override as x_slotting_fund_override,0 as slotting_fund_approved_final"
			}), "'not_released' as user_positions_id,'not released' as position_label,slotting_position_type,not_released_slotting_fund as slotting_fund,not_released_slotting_fund_final as slotting_fund_final,not_released_slotting_fund_override as slotting_fund_override,not_released_slotting_fund as x_slotting_fund,not_released_slotting_fund_final as x_slotting_fund_final,not_released_slotting_fund_override as x_slotting_fund_override,0 as slotting_fund_approved_final"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForlocal_qSlottingHeader = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForlocal_qSlottingHeader>
<cfquery name="local.qSlottingHeader" datasource="#application.datasource#">
			SELECT	'NOT_RELEASED' AS User_Positions_ID
                    ,'NOT RELEASED' AS Position_Label
                    ,Slotting_Position_Type
					,Not_Released_Slotting_Fund AS Slotting_Fund
					,Not_Released_Slotting_Fund_Final AS Slotting_Fund_Final
                    ,Not_Released_Slotting_Fund_Override AS Slotting_Fund_Override
					,Not_Released_Slotting_Fund AS X_Slotting_Fund
					,Not_Released_Slotting_Fund_Final AS X_Slotting_Fund_Final
                    ,Not_Released_Slotting_Fund_Override AS X_Slotting_Fund_Override
                    ,0 AS Slotting_Fund_Approved_Final
			FROM	Planner_Target_Header
			WHERE	Planner_Target_Header_ID = #arguments.id#
        </cfquery>
</cfif>

		<cfset local.slottingLevel = Val(local.qSlottingHeader.Slotting_Position_Type) />

		<cfquery name="local.qDropTable" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmp_positions') IS NOT NULL
			DROP TABLE ##tmp_positions
		</cfquery>

		<cfquery name="local.qSlottings" datasource="#application.datasource#">
			<cfif local.slottingLevel eq 0>
				<!--- Headquarters --->
				SELECT	up.User_Positions_ID
						,up.Position_Label
						,'' as Position_ID
				INTO	##tmp_positions
				FROM	User_positions up
				WHERE	up.Deleted = 0
				AND		LTRIM(up.Position_Label) != ''
				AND		up.Service_Zone_ID IS NULL
			<cfelseif local.slottingLevel eq 1>
				<!--- Zone --->
				SELECT	up.User_Positions_ID
						,up.Position_Label
						,z.Zone_Number as Position_ID
				INTO	##tmp_positions
				FROM	User_positions up
				INNER JOIN Service_Zones z
				ON		z.Service_Zone_ID = up.Service_Zone_ID
				WHERE	up.Deleted = 0
				AND		LTRIM(up.Position_Label) != ''
				AND		up.Service_Zone_ID IS NOT NULL
				AND		up.Service_Region_ID IS NULL
			<cfelseif local.slottingLevel eq 2>
				<!--- Region --->
				SELECT	up.User_Positions_ID
						,up.Position_Label
						,r.Region_Number as Position_ID
				INTO	##tmp_positions
				FROM	User_positions up
				INNER JOIN Service_Regions r
				ON		r.Service_Region_ID = up.Service_Region_ID
				WHERE	up.Deleted = 0
				AND		LTRIM(up.Position_Label) != ''
				AND		up.Service_Region_ID IS NOT NULL
				AND		up.Service_Market_ID IS NULL
			<cfelseif local.slottingLevel eq 3>
				<!--- Market --->
				SELECT	up.User_Positions_ID
						,up.Position_Label
						,m.Market_Number as Position_ID
				INTO	##tmp_positions
				FROM	User_positions up
				INNER JOIN Service_Markets m
				ON		m.Service_Market_ID = up.Service_Market_ID
				WHERE	up.Deleted = 0
				AND		LTRIM(up.Position_Label) != ''
				AND		up.Service_Market_ID IS NOT NULL
			<cfelse>
				<!--- Return nothing --->
				CREATE TABLE ##tmp_positions (User_Positions_ID int, Position_Label varchar(10), Position_ID varchar(10))
			</cfif>

			<cfif local.slottingLevel neq 0>
			-- Apply filter
			DECLARE @Planner_Target_Slotting_Position_Filter varchar(50)
			SELECT	@Planner_Target_Slotting_Position_Filter = LTRIM(ISNULL(DBO.udf_GetAppSetting('Planner_Target_Slotting_Position_Filter'), ''))

			IF @Planner_Target_Slotting_Position_Filter != ''
			BEGIN

				IF OBJECT_ID('tempdb..##tmpPlannerTargetSlottingPositionFilter') IS NOT NULL
				DROP TABLE ##tmpPlannerTargetSlottingPositionFilter

				SELECT	LTRIM(RTRIM(Value)) as Position_ID, Len(LTRIM(RTRIM(Value))) as Position_ID_Len
				INTO	##tmpPlannerTargetSlottingPositionFilter
				FROM	DBO.listToTable(@Planner_Target_Slotting_Position_Filter, ',')

				-- Remove the extra records
				DELETE	p
				FROM	##tmp_positions p
				WHERE	Position_ID != ''
				AND		NOT EXISTS (
					SELECT	1
					FROM	##tmpPlannerTargetSlottingPositionFilter f
					WHERE	Left(p.Position_ID, f.Position_ID_Len) = f.Position_ID
				)

			END
			</cfif>

			SELECT	up.User_Positions_ID
                    ,up.Position_Label
                    ,Slotting_Fund
                    ,Slotting_Fund AS X_Slotting_Fund
                    ,Slotting_Fund_Override
                    ,Slotting_Fund_Override AS X_Slotting_Fund_Override
                    ,Slotting_Fund_Final
					,Slotting_Fund_Approved_Final
			FROM	##tmp_positions up
			LEFT JOIN Planner_Target_Slotting sl
			ON		sl.Planner_Target_Header_ID = #arguments.id#
			AND		sl.User_Position_ID = up.User_Positions_ID
			ORDER BY Position_Label
        </cfquery>

        <cfquery name="local.qTotals" datasource="#application.datasource#">
            SELECT  'TOTAL' AS User_Positions_ID
                    ,'TOTAL' AS Position_Label
                    ,0.00 AS Slotting_Fund
                    ,0.00 AS X_Slotting_Fund
                    ,0.00 AS Slotting_Fund_Override
                    ,0.00 AS X_Slotting_Fund_Override
                    ,0.00 AS Slotting_Fund_Final
					,0.00 AS Slotting_Fund_Approved_Final
        </cfquery>

        <cfreturn [ local.qSlottings, local.qTotals, local.qSlottingHeader ]>
    </cffunction>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

    <cffunction name="setSlotting" output="false" access="remote">
        <cfargument name="data" required="true">

        <cfset local.delimiter    = "$">
        <cfset local.updated_rows = []>

        <cfquery datasource="#application.datasource#">
            UPDATE Planner_Target_Header
               SET Slotting_Updated_Date = GETDATE()
             WHERE 1 = 0

            <!---  scan thru all form input elements & update DEMO_FUND first --->
            <cfloop collection="#arguments.data#" item="local.key">
                <!---  include only input element with 2 components in it  --->
                <cfif listLen(local.key, local.delimiter) eq 2>
                    <cfscript>
                        local.sub_keys         = listToArray(local.key, local.delimiter);
                        local.column_name      = local.sub_keys[1];                          //* 1st component = front-end column name */
                        local.user_position_id = local.sub_keys[2];                          //* 2nd component = user position id */
                        local.rate_input       = arguments.data[ local.key ];
                    </cfscript>

                    <cfif local.column_name is "SLOTTING_FUND">
                        <cfif local.user_position_id is "NOT_RELEASED">
                            UPDATE Planner_Target_Header
                                SET  <cfif trim(local.rate_input) eq ''>
                                        Not_Released_Slotting_Fund = NULL
                                    <cfelse>
                                        Not_Released_Slotting_Fund = #local.rate_input#
                                    </cfif>
                                WHERE Planner_Target_Header_ID = #arguments.data.id#
                        <cfelse>
                            <cfset arrayAppend(local.updated_rows, local.user_position_id)>
                            <cfquery name="local.qRow" datasource="#application.datasource#" result="local.qResult">
                                UPDATE Planner_Target_Slotting
                                SET  <cfif trim(local.rate_input) eq ''>
                                            Slotting_Fund = NULL
                                        <cfelse>
                                            Slotting_Fund = #local.rate_input#
                                        </cfif>
                                WHERE Planner_Target_Header_ID = #arguments.data.id#
                                    AND User_Position_ID = #local.user_position_id#
                            </cfquery>

                            <cfif local.qResult.recordCount eq 0>
                                INSERT INTO Planner_Target_Slotting
                                    (Planner_Target_Header_ID, User_Position_ID, Slotting_Fund)
                                VALUES (#arguments.data.id#, #local.user_position_id#, #(trim(local.rate_input) eq '' ? NULL : local.rate_input)#)
                            </cfif>
                        </cfif>
                    </cfif>
                </cfif>
            </cfloop>
        </cfquery>

        <cfquery datasource="#application.datasource#">
            UPDATE Planner_Target_Header
               SET Slotting_Updated_Date = GETDATE()
             WHERE 1 = 0

            <!---  scan thru all form input elements & update  --->
            <cfloop collection="#arguments.data#" item="local.key">
                <!---  include only input element with 2 components in it  --->
                <cfif listLen(local.key, local.delimiter) eq 2>
                    <cfscript>
                        local.sub_keys         = listToArray(local.key, local.delimiter);
                        local.column_name      = local.sub_keys[1];                          //* 1st component = front-end column name */
                        local.user_position_id = local.sub_keys[2];                          //* 2nd component = user position id */
                        local.rate_input       = arguments.data[ local.key ];
                    </cfscript>

                    <cfif local.column_name is "SLOTTING_FUND_OVERRIDE">
                        <cfif local.user_position_id is "NOT_RELEASED">
                            UPDATE Planner_Target_Header
                            SET <cfif trim(local.rate_input) eq ''>
                                    Not_Released_Slotting_Fund_Override = NULL
                                <cfelse>
                                    Not_Released_Slotting_Fund_Override = #local.rate_input#
                                </cfif>
                                WHERE Planner_Target_Header_ID = #arguments.data.id#
                        <cfelse>
                            <cfset arrayAppend(local.updated_rows, local.user_position_id)>
                            <cfquery name="local.qResult" datasource="#application.datasource#">
                                UPDATE Planner_Target_Slotting
                                SET <cfif trim(local.rate_input) eq ''>
                                        Slotting_Fund_Override = NULL
                                    <cfelse>
                                        Slotting_Fund_Override = #local.rate_input#
                                    </cfif>
                                WHERE Planner_Target_Header_ID = #arguments.data.id#
                                        AND User_Position_ID = #local.user_position_id#

                                SELECT 1
                                  FROM Planner_Target_Slotting
                                WHERE Planner_Target_Header_ID = #arguments.data.id#
                                        AND User_Position_ID = #local.user_position_id#
                            </cfquery>

                            <cfif local.qResult.recordCount eq 0>
                                <cfquery datasource="#application.datasource#">
                                    INSERT INTO Planner_Target_Slotting
                                        (Planner_Target_Header_ID, User_Position_ID
                                            ,Slotting_Fund_Override, Slotting_Fund_Final)
                                    VALUES (#arguments.data.id#, #local.user_position_id#
                                            ,#(trim(local.rate_input) eq '' ? NULL : local.rate_input)#
                                            ,#(trim(local.rate_input) eq '' ? NULL : local.rate_input)#)
                                </cfquery>
                            </cfif>
                        </cfif>
                    </cfif>
                </cfif>
            </cfloop>
        </cfquery>

        <!--- update slotting_fund_final --->
        <cfquery datasource="#application.datasource#" result="local.qresult">
            UPDATE Planner_Target_Header
               SET Slotting_Updated_Date = GETDATE()
                   ,Slotting_Updated_By = '#request.AccessStructure.User_ID#'
                   ,Not_Released_Slotting_Fund_Final = ISNULL(Not_Released_Slotting_Fund_Override, Not_Released_Slotting_Fund)
             WHERE Planner_Target_Header_ID = #arguments.data.id#

            <cfloop array="#local.updated_rows#" index="local.user_position_id">
                UPDATE Planner_Target_Slotting
                   SET Slotting_Fund_Final = ISNULL(Slotting_Fund_Override, Slotting_Fund)
                   WHERE Planner_Target_Header_ID = #arguments.data.id#
                            AND User_Position_ID = #local.user_position_id#
            </cfloop>
        </cfquery>

		<cfset setSlottingApprovedValues(arguments.data.id)>
    </cffunction>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

    <cffunction name="getSlottingSaveApproveOptions" output="false" access="remote">
        <cfargument name="id" required="true">

		<cfquery name="local.qSlottingHeader" datasource="#application.datasource#">
			SELECT	isnull(Slotting_Increase_Approved_Amount, 0) as Slotting_Increase_Approved_Amount,
					isnull(Not_Released_Slotting_Fund, 0) as Not_Released_Slotting_Fund,
					isnull(Not_Released_Slotting_Fund_Final, 0) as Not_Released_Slotting_Fund_Final
			FROM	Planner_Target_Header h
			WHERE	h.Planner_Target_Header_ID = #arguments.id#
        </cfquery>

		<cfquery name="local.qSlottingTotals" datasource="#application.datasource#">
			SELECT	isnull(sum(Slotting_Fund), 0) as Slotting_Fund,
					isnull(sum(Slotting_Fund_Final), 0) as Slotting_Fund_Final,
					isnull(sum(Slotting_Fund_Final), 0) - isnull(sum(Slotting_Fund), 0) as Incr
			FROM	Planner_Target_Slotting sl
			WHERE	sl.Planner_Target_Header_ID = #arguments.id#
        </cfquery>

		<cfset local.slottingIncrease = local.qSlottingTotals.Incr + (local.qSlottingHeader.Not_Released_Slotting_Fund_Final - local.qSlottingHeader.Not_Released_Slotting_Fund) />
		<cfset local.priorApprovedSlotting = local.qSlottingHeader.Slotting_Increase_Approved_Amount />
		<cfset local.saveApproveOptions = {Approve: 0, Update: 0, Messages: '', slottingIncrease = local.slottingIncrease} />

		<cfif local.slottingIncrease eq 0 or local.slottingIncrease lte local.priorApprovedSlotting>
			<cfset local.saveApproveOptions = {Approve: 0, Update: 1, Messages: '', slottingIncrease = local.slottingIncrease} />
		<cfelse>
			<!--- Check if current user can approve slotting increase, set it as approved --->
			<cfquery name="local.qGetUserProfileSetting" datasource="#application.datasource#">
				SELECT	Planner_Target_Max_Slotting_Target_Increase
				FROM	_Users u
				INNER JOIN Planner_Profiles_Settings ps
				ON		ps.Profiles_ID = u.Profiles_ID
				WHERE	u.User_ID = '#request.AccessStructure.User_ID#'
			</cfquery>

			<cfset local.profileMaxSlottingIncrease = local.qGetUserProfileSetting.Planner_Target_Max_Slotting_Target_Increase />

			<cfif local.profileMaxSlottingIncrease eq "*"
				  or (local.slottingIncrease lte val(local.profileMaxSlottingIncrease))>

				<cfset local.saveApproveOptions = {Approve: 1, Update: 1, Messages: '', slottingIncrease = local.slottingIncrease} />

			</cfif>

		</cfif>

		<cfreturn local.saveApproveOptions />

    </cffunction>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

    <cffunction name="setSlottingApprovedValues" output="false" access="remote">
        <cfargument name="id" required="true">

		<cfset local.saveApproveOptions = getSlottingSaveApproveOptions(arguments.id) />

		<cfif local.saveApproveOptions.Approve eq 1>
			<!--- User can approve  --->
			<cfquery name="local.qApproveSlotting" datasource="#application.datasource#">
				UPDATE	Planner_Target_Header
				SET		Slotting_Increase_Approved_Amount = #local.saveApproveOptions.slottingIncrease#,
						Slotting_Increase_Approved_By = '#request.AccessStructure.User_ID#',
						Slotting_Increase_Approved_Date = Getdate(),
						Not_Released_Slotting_Approved_Fund_Final = Not_Released_Slotting_Fund_Final
				WHERE	Planner_Target_Header_ID = #arguments.id#

				UPDATE	Planner_Target_Slotting
				SET		Slotting_Fund_Approved_Final = Slotting_Fund_Final
				WHERE	Planner_Target_Header_ID = #arguments.id#
			</cfquery>
		<cfelseif local.saveApproveOptions.Update eq 1>
			<!--- Slotting increase is within prior approved amount, update  --->
			<cfquery name="local.qUpdateSlotting" datasource="#application.datasource#">
				UPDATE	Planner_Target_Header
				SET		Not_Released_Slotting_Approved_Fund_Final = Not_Released_Slotting_Fund_Final
				WHERE	Planner_Target_Header_ID = #arguments.id#

				UPDATE	Planner_Target_Slotting
				SET		Slotting_Fund_Approved_Final = Slotting_Fund_Final
				WHERE	Planner_Target_Header_ID = #arguments.id#
			</cfquery>
		<cfelse>
			<!--- User cannot approve and value not updated - send email  --->
			<cfset needSlottingApprovalEmail(arguments.id, local.saveApproveOptions.slottingIncrease)>
		</cfif>

    </cffunction>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

    <cffunction name="needSlottingApprovalEmail" output="false" access="remote">
		<cfargument name="id" required="true">
		<cfargument name="slottingIncrease" required="true">

		<cfset local.slottingIncrease = arguments.slottingIncrease />

		<cfquery name="local.qGetSlottingApprovalUsers" datasource="#application.datasource#">
			<!---
			Get 2 set of users.
			a) Find all users that satisfy one of below 2 criteria (eg: If 100,000 it will be Dir of Trade, VP of Sales. If more than 250,000 it will be VP of Sales)
			Profile setting "Max Slotting Target Increase" = *
			Profile setting "Max Slotting Target Increase" >= Variance
			c) Additionally include users who has a value provided in profile setting "Max Slotting Target Increase" and has profile settings value less than Variance (eg: If 100,000 there is no other user. If more than 250,000 additionally include Dir of Trade)
			--->
			IF OBJECT_ID('tempdb..##tmp_slotting_approvers') IS NOT NULL
			DROP TABLE ##tmp_slotting_approvers

			select	u.User_ID, u.Name_First + ' ' + u.Name_Last as UserName, u.User_Email,
					Planner_Target_Max_Slotting_Target_Increase,
					case
					when Planner_Target_Max_Slotting_Target_Increase = '*' then 1
					when (isnumeric(Planner_Target_Max_Slotting_Target_Increase) = 1 and cast(Planner_Target_Max_Slotting_Target_Increase as float) > #local.slottingIncrease#) then 1
					else 0
					end as can_Approve,
					DENSE_RANK() Over(order By case when Planner_Target_Max_Slotting_Target_Increase = '*' then 1 else 0 end desc, Planner_Target_Max_Slotting_Target_Increase desc) as [Rank]
			into	##tmp_slotting_approvers
			from	_Users u
			inner join Planner_Profiles_Settings ps
			on		ps.Profiles_ID = u.Profiles_ID
			where	u.Deleted = 0
			and		(ps.Planner_Target_Max_Slotting_Target_Increase = '*'
					or (isnumeric(Planner_Target_Max_Slotting_Target_Increase) = 1 and Planner_Target_Max_Slotting_Target_Increase != 0)
					)

			<!---
			b) Only include users with min profile setting value from above list with can_Approve = 1.
			If 2 set of users/profiles can approve given slotting increase, only keep the user with min profile value.
			(eg: If 100,000 it will be Dir of Trade. If more than 250,000 it will be VP of Sales)
			--->
			delete	##tmp_slotting_approvers
			where	[Rank] <
					(
						select	max([Rank])
						from	##tmp_slotting_approvers
						where	can_Approve = 1
					)

			select	*
			from	##tmp_slotting_approvers
		</cfquery>

		<cfif local.qGetSlottingApprovalUsers.recordCount>
			<cfset useLakebaseForlocal_qSystemAdmin = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForlocal_qSystemAdmin>
	<cftry>
		<cfset local.qSystemAdmin = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"is_system_administrator" = "eq.1",
				"deleted" = "eq.0",
				"limit" = "1",
				"select" = "user_email"
			}), "user_email"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForlocal_qSystemAdmin = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForlocal_qSystemAdmin>
<cfquery name="local.qSystemAdmin" datasource="#application.datasource#">
				SELECT	TOP 1 User_Email
				  FROM  _Users
				 WHERE 	Is_System_Administrator = 1
						AND	Deleted = 0
			</cfquery>
</cfif>

			<cfset qTargets = getTargets(arguments.id) />

			<cfset userEmailList = ValueList(local.qGetSlottingApprovalUsers.User_Email, ";") />
			<cfset mail_subject = "Blacksmith Applications - Planner Targets " & qTargets.Fiscal_Year & "-" & qTargets.Main_Distributor_Group_Number & ": slotting target increase needs approval">
			<cf_emailwrapper
				to 			= "#trim(userEmailList)#"
				from		= "#trim(local.qSystemAdmin.User_Email)#"
				subject		= "#mail_subject#"
				type		= "html"
				messagetype	= "1"
				generatedby	= "1"
				appArea		= "1"><cfoutput>
Slotting target increase needs approval.
<br><br>
Target: <strong>#qTargets.Fiscal_Year#-#qTargets.Main_Distributor_Group_Number#</strong><br>
Slotting increase: <strong>#DollarFormat(local.slottingIncrease)#</strong><br>
</cfoutput>
			</cf_emailwrapper>
		</cfif>

    </cffunction>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

    <cffunction name="getApprovalSummaries" output="false">
        <cfargument name="id" required="true">

        <cfquery name="local.qSummary" datasource="#application.datasource#">
            EXEC Planner_Target_Approval_Calc
                @Planner_ID = #arguments.id#
                ,@User_ID = '#request.AccessStructure.User_ID#'
        </cfquery>

        <cfreturn local.qSummary>
    </cffunction>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

    <cffunction name="getApprovalDetails" output="false">
        <cfargument name="id" required="true">

        <cfquery datasource="#application.datasource#">
            IF OBJECT_ID('tempdb..##tmp_tgtapp_trade') IS NOT NULL
                DROP TABLE ##tmp_tgtapp_trade

            IF Object_id('tempdb..##tmp_group_programs_without_members') IS NOT NULL
                DROP TABLE ##tmp_group_programs_without_members
        </cfquery>

        <cfquery name="local.qTrade" datasource="#application.datasource#">
            SELECT      Group_GUID
                        ,Group_Number
                        ,Group_Desc
                        ,Target_Revenue
                        ,Planner_Revenue
                        ,Variance_Revenue
                        ,Variance_Percent_Revenue
                        ,Target_Trade_Rate
                        ,Planner_Trade_Rate
                        ,Variance_Percent_Trade_Rate
                        ,Variance_Trade_Rate
                        ,Target_Trade_Dollar
                        ,Planner_Trade_Dollar
                        ,Variance_Trade_Dollar
                        ,Variance_Percent_Trade_Dollar
                        ,Approved_Incremental_Funds
                        ,RowID = ROW_NUMBER() Over (Order By Variance_Trade_Rate, Group_Desc)
                INTO    ##tmp_tgtapp_trade
                FROM    Planner_Target_Approval_Info_Trade
                WHERE   Planner_ID = #arguments.id#

            SELECT      Group_GUID
                        ,Group_Number
                        ,Group_Desc
                        ,1                        AS Kind_ID
                        ,'Revenue'                AS Kind
                        ,Target_Revenue           AS Target
                        ,Planner_Revenue          AS Planner
                        ,Variance_Revenue         AS Variance
                        ,Variance_Percent_Revenue AS Variance_PCT
                        ,RowID
                FROM    ##tmp_tgtapp_trade
            UNION
            SELECT      Group_GUID
                        ,Group_Number
                        ,Group_Desc
                        ,2                           AS Kind_ID
                        ,'Trade Rate'                AS Kind
                        ,Target_Trade_Rate           AS Target
                        ,Planner_Trade_Rate          AS Planner
                        ,Variance_Trade_Rate         AS Variance
                        ,Variance_Percent_Trade_Rate AS Variance_PCT
                        ,RowID
                FROM    ##tmp_tgtapp_trade
            UNION
            SELECT      Group_GUID
                        ,Group_Number
                        ,Group_Desc
                        ,3                          AS Kind_ID
                        ,'Incr Fund Req'            AS Kind
                        ,Approved_Incremental_Funds AS Target
                        ,NULL                       AS Planner
                        ,NULL                       AS Variance
                        ,NULL                       AS Variance_PCT
                        ,RowID
                FROM    ##tmp_tgtapp_trade
            UNION
            SELECT      Group_GUID
                        ,Group_Number
                        ,Group_Desc
                        ,4                             AS Kind_ID
                        ,'Trade $'                     AS Kind
                        ,Target_Trade_Dollar           AS Target
                        ,Planner_Trade_Dollar          AS Planner
                        ,Variance_Trade_Dollar         AS Variance
                        ,Variance_Percent_Trade_Dollar AS Variance_PCT
                        ,RowID
                FROM    ##tmp_tgtapp_trade
            ORDER BY RowID, Kind_ID
        </cfquery>

        <cfset useLakebaseForlocal_qDemo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("planner_target_approval_info_demo")>
<cfif useLakebaseForlocal_qDemo>
	<cftry>
		<cfset local.qDemo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("planner_target_approval_info_demo", {
				"planner_id" = "eq.#arguments.id#",
				"select" = "group_guid,group_number,group_desc,target_demo,planner_demo,variance_demo"
			}), "group_guid,group_number,group_desc,target_demo,planner_demo,variance_demo"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForlocal_qDemo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForlocal_qDemo>
<cfquery name="local.qDemo" datasource="#application.datasource#">
            SELECT Group_GUID,
                Group_Number,
                Group_Desc,
                Target_Demo,
                Planner_Demo,
                Variance_Demo
            FROM Planner_Target_Approval_Info_Demo
            WHERE Planner_ID = #arguments.id#
        </cfquery>
</cfif>

        <cfquery name="local.qNo_Members" datasource="#application.datasource#">
            SELECT cm.Contract_Main_ID,
                cm.Contract_Number,
                cp.Product_Group_Level_ID,
                cp.BSA_Foodservice_Items_Master_ID AS Group_ID
            INTO ##tmp_group_programs_without_members
            FROM Contract_Main cm
                INNER JOIN Planners p
                        ON p.Planner_ID = cm.Planner_ID
                LEFT JOIN Planner_Perf_Types pt
                        ON pt.Planner_Perf_Types_ID = cm.Planner_Perf_Type_ID
                INNER JOIN Contract_Products cp
                        ON cp.Contract_Main_ID = cm.Contract_Main_ID
                            AND cp.Deleted = 0
                            AND cp.Is_Group = 1
                            AND cp.products_not_captured_flag = 1
            WHERE ( cm.Planner_ID = #arguments.id#
                    OR p.Parent_Planner_ID = #arguments.id# )
                AND cm.Deleted = 0
                AND cm.Contract_Status_Type_IDX = 2
                AND cm.Manual_Cancel = 0
                AND Isnull(pt.Accrual, 0) = 0

            SELECT DISTINCT Contract_Number,
                            g.Group_Number,
                            g.Group_Desc
            FROM ##tmp_group_programs_without_members t
                INNER JOIN All_Product_Group_Types g
                        ON g.Group_GUID = t.Group_ID
                            AND g.Product_Group_Level_ID = t.Product_Group_Level_ID
            ORDER BY Contract_Number,
                    Group_Number,
                    Group_Desc
        </cfquery>

        <cfreturn [local.qTrade, local.qDemo, local.qNo_Members]>
    </cffunction>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

    <cffunction name="updateOriginalTargetRevenue" output="false" access="remote">
        <cfargument name="data" required="true">

        <cfquery datasource="#application.datasource#">
             UPDATE Planner_Target_Detail
                SET Sales_Target_Original = Sales_Target_Final
                    ,Sales_Target_Override = NULL
              WHERE Planner_Target_Header_ID = #arguments.data.id#
        </cfquery>
    </cffunction>

</cfcomponent>
