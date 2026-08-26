<!---------------------------------------------------------------------------------------------------------------------
            Component: \mvc\Models\VolumeForecast\vfmanager.cfc
            Date:      Nov 21 2011
            Author:    Chris Nguyen

            Purpose:   Volume Forecast DA Manager
----------------------------------------------------------------------------------------------------------------------->
<cfcomponent output="false" displayname="Volume Forecast" >

    <cffunction name="getProductCategories" output="false" access="public" returnType="query" hint="Return product categories">
        <cfargument name="vf_id" required="true" hint="I am the volume forecast ID list">

        <cfquery name="local.productCategories" datasource="#application.datasource#">
            SELECT DISTINCT pgpc.pg_Product_Category_Id
                                 , pgpc.pg_Product_Category_Name
                FROM VF_Planning_Groups vfpg
                         INNER JOIN PG_Product_Category pgpc
                             ON pgpc.pg_Product_Category_Id = vfpg.pg_Product_Category_Id AND pgpc.active = 1
                                        <!---38166 skip groups without any members--->
                    AND EXISTS ( SELECT TOP 1 1
                                   FROM PG_PRODUCT_MEMBERS ppm
                                  WHERE ppm.pg_Product_Category_Id = vfpg.pg_Product_Category_Id
                                        AND ppm.Deleted = 0 )
             WHERE vfpg.Deleted = 0
                        <cfif listLen(arguments.vf_id) eq 1>
                            AND vfpg.VF_Plan_ID = <cfqueryparam value="#arguments.vf_id#" cfsqltype="cf_sql_integer">
                        <cfelse>
                            AND vfpg.VF_Plan_ID IN ( <cfqueryparam value="#arguments.vf_id#" cfsqltype="cf_sql_integer" list="true"> )
                        </cfif>
             ORDER BY pgpc.pg_Product_Category_Name
        </cfquery>

        <cfreturn local.productCategories>
    </cffunction>

    <!--------------------------------------------------------------------------------------------------------------------->

    <cffunction name="getFuturePeriods" output="false" access="public" returnType="query" hint="Return volume forecast periods">
        <cfargument name="vf_id" required="true" hint="I am the volume forecast ID list">
        <cfargument name="quarter" required="true" type="numeric" hint="I am the quarter number (valid values are 1, 2, 3, 4)">
        <!---
            quarter 1: row 1 to row 3
            quarter 2: row 4 to row 6
            quarter 3: row 7 to row 9
            quarter 4: row 10 to row 12--->

        <cfset local.startPeriodRowNumber = (arguments.quarter * 3)>
        <cfquery name="local.periods" Datasource="#application.datasource#">
            SELECT *
                FROM (
                            SELECT ROW_NUMBER() OVER (ORDER BY Start_Date) AS Seq
                                  , *
                              FROM (
                                     SELECT DISTINCT vfp.Start_Date
                                                             , vfp.VF_Period_Id
                                                             , vfp.Period_desc
                                                             , Became_Actual = CASE WHEN GETDATE() > vfp.End_Date THEN 1 ELSE 0 END
                                                    FROM VF_Period vfp
                                                    INNER JOIN VF_Plan vp ON vp.VF_Plan_Class_ID = vfp.VF_Class_ID
                                                 WHERE
                                                                <cfif listLen(arguments.vf_id) eq 1>
                                                                    vp.VF_Plan_ID = <cfqueryparam value="#arguments.vf_id#" cfsqltype="cf_sql_integer">
                                                                <cfelse>
                                                                    vp.VF_Plan_ID IN ( <cfqueryparam value="#arguments.vf_id#" cfsqltype="cf_sql_integer" list="true"> )
                                                                </cfif>
                                             ) AS Temp
                         ) AS DataSet
             <cfoutput>WHERE DataSet.Seq > #local.startPeriodRowNumber#</cfoutput>
        </cfquery>

        <cfreturn local.periods>
    </cffunction>

    <!--------------------------------------------------------------------------------------------------------------------->

    <cffunction name="getPeriods" output="false" access="public" returnType="query" hint="Return volume forecast periods">
        <cfargument name="vf_id" required="true" hint="I am the volume forecast ID list">
        <cfargument name="quarter" required="false" type="numeric" hint="I am the quarter number (valid values are 1, 2, 3, 4)">
        <!---
            quarter 1: row 1 to row 3
            quarter 2: row 4 to row 6
            quarter 3: row 7 to row 9
            quarter 4: row 10 to row 12--->

        <cfif ( not StructKeyExists(arguments, 'quarter') )>
            <cfquery name="local.periods" Datasource="#application.datasource#">
                SELECT ROW_NUMBER() OVER (ORDER BY vfp.Start_Date) AS Seq
                             , vfp.VF_Period_Id
                             , vfp.Period_desc
                             , Became_Actual = CASE WHEN GETDATE() > vfp.End_Date THEN 1 ELSE 0 END
                    FROM VF_Period vfp
                    INNER JOIN VF_Plan vp ON vp.VF_Plan_Class_ID = vfp.VF_Class_ID
             WHERE
                        <cfif listLen(arguments.vf_id) eq 1>
                            vp.VF_Plan_ID = <cfqueryparam value="#arguments.vf_id#" cfsqltype="cf_sql_integer">
                        <cfelse>
                            vp.VF_Plan_ID IN ( <cfqueryparam value="#arguments.vf_id#" cfsqltype="cf_sql_integer" list="true"> )
                        </cfif>
            </cfquery>
        <cfelse>
            <cfset local.startPeriodRowNumber = ((arguments.quarter - 1) * 3) + 1>
            <cfquery name="local.periods" Datasource="#application.datasource#">
                SELECT *
                    FROM (
                                SELECT ROW_NUMBER() OVER (ORDER BY Start_Date) AS Seq
                                      , *
                                  FROM (
                                         SELECT DISTINCT vfp.Start_Date
                                                                 , vfp.VF_Period_Id
                                                                 , vfp.Period_desc
                                                                 , Became_Actual = CASE WHEN GETDATE() > vfp.End_Date THEN 1 ELSE 0 END
                                                        FROM VF_Period vfp
                                                        INNER JOIN VF_Plan vp ON vp.VF_Plan_Class_ID = vfp.VF_Class_ID
                                                     WHERE
                                                                    <cfif listLen(arguments.vf_id) eq 1>
                                                                        vp.VF_Plan_ID = <cfqueryparam value="#arguments.vf_id#" cfsqltype="cf_sql_integer">
                                                                    <cfelse>
                                                                        vp.VF_Plan_ID IN ( <cfqueryparam value="#arguments.vf_id#" cfsqltype="cf_sql_integer" list="true"> )
                                                                    </cfif>
                                                 ) AS Temp
                             ) AS DataSet
                 <cfoutput>WHERE DataSet.Seq BETWEEN #local.startPeriodRowNumber# AND #(local.startPeriodRowNumber + 2)#</cfoutput>
            </cfquery>
        </cfif>

        <cfreturn local.periods>
    </cffunction>

    <!--------------------------------------------------------------------------------------------------------------------->

    <cffunction name="getPeriodsbyStatus" output="false" access="public" returnType="query" hint="Return volume forecast periods">
        <cfargument name="vf_id" required="true" hint="I am the volume forecast ID list">
        <cfargument name="actual" required="true" type="boolean" hint="I am the actual indicator (valid values are 0, 1)">

        <cfquery name="local.periods" Datasource="#application.datasource#">
            SELECT vfp.VF_Period_Id
                FROM VF_Period vfp
                INNER JOIN VF_Plan vp ON vp.VF_Plan_Class_ID = vfp.VF_Class_ID
             WHERE <cfif listLen(arguments.vf_id) eq 1>
                            vp.VF_Plan_ID = <cfqueryparam value="#arguments.vf_id#" cfsqltype="cf_sql_integer">
                        <cfelse>
                            vp.VF_Plan_ID IN ( <cfqueryparam value="#arguments.vf_id#" cfsqltype="cf_sql_integer" list="true"> )
                        </cfif>
                         AND    <cfif arguments.actual>
                                     vfp.End_Date <= GETDATE()
                                    <cfelse>
                                        vfp.End_Date > GETDATE()
                                    </cfif>
        </cfquery>

        <cfreturn local.periods>
    </cffunction>

    <!--------------------------------------------------------------------------------------------------------------------->

    <cffunction name="getLevels" output="false" access="public" returnType="query" hint="Return volume forecast levels belong to a VF plan.">
        <cfargument name="vf_id" required="true" hint="I am the volume forecast ID list">
        <cfargument name="level" required="false" hint="Optional - I am the list of level IDs (delimited by commas)">

        <cfquery name="local.levels" Datasource="#application.datasource#">
            SELECT DISTINCT
                           vl.VF_Level_ID
                  , vf_Class.Year_Selection
                         , Updatedby = updatedby.Name_First + ' ' + updatedby.Name_Last
                         , LockedbyUserName = lockedby.Name_First + ' ' + lockedby.Name_Last
                         , lockedbyUserID = vl.Locked_By
                         , vl.Last_Updated_On
                         , vl.Service_Market_Id
                         , vl.Service_Region_ID
                         , vl.Service_Zone_ID
                FROM VF_Level vl
                         INNER JOIN vf_Plan ON vf_Plan.vf_Plan_ID = vl.vf_Plan_ID
                         INNER JOIN vf_Class ON vf_Plan.vf_Plan_Class_ID = vf_Class.vf_Class_ID
                         LEFT JOIN _Users updatedby ON updatedby.User_ID = vl.Last_Updated_By
                         LEFT JOIN _Users lockedby  ON lockedby.User_ID = vl.Locked_By
             WHERE
                            <cfif listLen(arguments.vf_id) eq 1>
                                vl.VF_Plan_ID = <cfqueryparam value="#arguments.vf_id#" cfsqltype="cf_sql_integer">
                            <cfelse>
                                vl.VF_Plan_ID IN ( <cfqueryparam value="#arguments.vf_id#" cfsqltype="cf_sql_integer" list="true"> )
                            </cfif>
                        AND vl.Deleted = 0
              AND vl.User_Position_Id IN ( SELECT Below_User_Positions_Id
                                            FROM POSITIONS_BELOW_ME pbm
                                           WHERE Below_User_Positions_Id IS NOT NULL
                                                 AND pbm.User_Positions_Id IN ( SELECT uph.User_Positions_Id
                                                                                  FROM USER_POSITION_HOLDERS uph
                                                                                 WHERE uph.Deleted = 0
                                                                                       AND Uph.User_Id = <cfqueryparam value="#request.AccessStructure.user_ID#" cfsqltype="cf_sql_varchar">) )
                         <cfif StructKeyExists(arguments, 'level') and arguments.level neq 'summary'>  <!--- 35777 --->
                            AND vl.VF_Level_Id in (<cfqueryparam value="#arguments.level#" cfsqltype="cf_sql_integer" list="yes">)
                         </cfif>
        </cfquery>

        <cfreturn local.levels>
    </cffunction>

    <!--------------------------------------------------------------------------------------------------------------------->

    <cffunction name="getDetail" output="false" access="public" returnType="query" hint="Return volume forecast detail belong to a VF level.">
        <cfargument name="vf_id" required="true" hint="I am the volume forecast ID list">
        <cfargument name="level" required="true" hint="I am the level ID">
        <cfargument name="periods" required="false" hint="Optional - I am the list of periods (delimited by commas)">
        <cfargument name="user_position_id" required="false" hint="I am the user position IDs list" default="">

        <cfquery name="local.detail" Datasource="#application.datasource#">
            SELECT vfd.pg_Product_Category_Id
                         , vfd.VF_Detail_ID
                         , vfd.VF_Period_Id
                         , ly_Volume = ISNULL(ly_Volume,0)
                         , ly_Delta_Percentage = ISNULL(ly_Delta_Percentage,0)
                         -- calculate ty_Delta_Percentage when it is NULL
						 ,ty_Delta_Percentage =  CAST(ISNULL(cast(ty_Delta_Percentage as DECIMAL(16,4)), CAST(ISNULL(ty_volume,0) / ISNULL(NULLIF(ly_volume,0),1) as DECIMAL(16,6)) * 100.0000) AS DECIMAL(16,2))
						 --, ty_Delta_Percentage = ISNULL(ty_Delta_Percentage,0)
                         -- calculate ty_volume when use_absolute is OFF
                         , ty_Volume = CASE WHEN ISNULL(Use_Absolute, 0) = 0 THEN ISNULL(ly_volume * ( 1 + ( ISNULL(ty_delta_percentage,0) / 100 ) ), 0) ELSE ISNULL(ty_volume,0) END
                         , ty_pgm = ISNULL(ty_pgm,0)
                         , ty_pgm_Forecast_Delta = ISNULL(ty_pgm_Forecast_Delta,0)
                         , ty_pgm_Forecast_Delta_Percentage = ISNULL(ty_pgm_Forecast_Delta_Percentage,0)
                         , ybly_Volume = ISNULL(ybly_Volume,0)
                         , actual_volume = ISNULL(actual_volume,0)
                       , Became_Actual = CASE WHEN GETDATE() > vfp.End_Date THEN 1 ELSE 0 END
                       , Rolling_52 = ISNULL(Rolling_52, 0)
                       , Rolling_Prev_52 = ISNULL(Rolling_Prev_52, 0)
                       , Rolling_13 = ISNULL(Rolling_13, 0)
                       , Rolling_Prev_13 = ISNULL(Rolling_Prev_13, 0)
                       , use_absolute
                       , vfd.vf_Level_Id
                       , vfd.vf_Plan_Id
                FROM VF_Detail vfd
                             INNER JOIN VF_Period vfp ON vfd.VF_Period_ID = vfp.VF_Period_ID
                             <cfif len(trim(arguments.user_position_id)) and arguments.user_position_id neq "all">
                                INNER JOIN VF_Level vl ON vl.VF_Level_Id = vfd.vf_Level_Id
                                                                                    AND vl.User_Position_Id IN (<cfqueryparam value="#arguments.user_position_id#" cfsqltype="cf_sql_integer" list="yes">)
                             </cfif>
             WHERE
                            <cfif listLen(arguments.vf_id) eq 1>
                                vfd.VF_Plan_ID = <cfqueryparam value="#arguments.vf_id#" cfsqltype="cf_sql_integer">
                            <cfelse>
                                vfd.VF_Plan_ID IN ( <cfqueryparam value="#arguments.vf_id#" cfsqltype="cf_sql_integer" list="true"> )
                            </cfif>
                            <cfif len(trim(arguments.level)) and arguments.level neq 'summary'>  <!--- 35777 --->
                                AND vfd.VF_Level_Id IN (<cfqueryparam value="#arguments.level#" cfsqltype="cf_sql_integer" list="yes">)
                            </cfif>
                          <cfif StructKeyExists(arguments, 'periods')>
                             AND vfd.VF_Period_Id in (<cfqueryparam value="#arguments.periods#" cfsqltype="cf_sql_integer" list="yes">)
                          </cfif>
                         AND vfd.Deleted = 0
        </cfquery>

        <cfreturn local.detail>
    </cffunction>

    <!--------------------------------------------------------------------------------------------------------------------->

    <cffunction name="getCurrPositionAndBelowVF" output="false" access="public" returnType="query" hint="Return volume forecast levels for current position and below">
        <cfargument name="byPlanId" required="false" default="0" type="numeric">
        <cfargument name="byClassIds" required="false" default="" type="string">

        <cfset local.businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
        <cfset local.businessSegIsEnabled = local.businessSegManager.isEnabled()>

        <cfif local.businessSegIsEnabled>
            <!---32355 - gather user assigned segments--->
            <cfset local.qClassCodes = local.businessSegManager.getActiveClassCodes(request.AccessStructure.User_ID, 0) />
        </cfif>

        <cfquery name="local.vfLevels" Datasource="#application.datasource#">
            SELECT vf_Plan.vf_Plan_Id
                         , vf_Level.VF_Level_ID
                         , Plan_Name = vf_Plan.vf_Plan_desc
                         , Class_Name = vf_Class.vf_Class_desc
                         , Segment_Name = Business_Segment.Business_Unit_desc
                         , Level_Name = CASE vf_Plan.Forecast_Level
                                                            WHEN 4 THEN bsa_FoodService_Customers.Name + ' (' + bsa_FoodService_Customers.shr_ship_to + ')'
                                                            ELSE User_Positions.Position_Label
                                                        END
                         , Position_ID = vf_Level.User_Position_Id
                         , vf_Plan.Forecast_Level
                         , Updated_By = updatedby.Name_First + ' ' + updatedby.Name_Last
                         , vf_Level.Last_Updated_On
                         , vf_Class.Year_Selection
                FROM vf_Plan
                         INNER JOIN vf_Level ON vf_Plan.vf_Plan_Id = vf_Level.vf_Plan_Id and vf_Level.Deleted = 0
                         LEFT JOIN Business_Segment ON Business_Segment.Business_Segment_Id = vf_Plan.vf_Plan_Segment_Id
                         INNER JOIN vf_Class ON vf_Class.vf_Class_Id = vf_Plan.vf_Plan_Class_Id
                         <!---get position name for forecasts by zone/region/market--->
                         LEFT JOIN User_Positions ON vf_Plan.Forecast_Level IN ( 0, 1, 2, 3 ) AND vf_Level.User_Position_Id = User_Positions.User_Positions_Id
                         <!---get customer name for forecasts by customers--->
                         LEFT JOIN bsa_FoodService_Customers ON vf_Plan.Forecast_Level = 4 AND vf_Level.bsa_FoodService_Customers_Id = bsa_FoodService_Customers.bsa_FoodService_Customers_Id
                         LEFT JOIN _Users updatedby ON updatedby.User_ID = vf_Level.Last_Updated_By
             WHERE vf_Plan.Deleted = 0
                         <!---include only volume levels with detail (calculated)--->
                         AND (SELECT COUNT(1)
                                FROM VF_Detail vfd
                               WHERE vfd.VF_Plan_ID = VF_Plan.VF_Plan_ID
                                     AND vfd.VF_Level_ID = vf_Level.vf_Level_ID
                                     AND vfd.Deleted = 0) > 0
                         AND vf_Level.User_Position_Id IN ( SELECT Below_User_Positions_Id
                                                                                                    FROM Positions_Below_Me pbm
                                                                                                 WHERE Below_User_Positions_Id IS NOT NULL
                                                                                                             AND pbm.User_Positions_Id IN ( SELECT Uph.User_Positions_Id
                                                                                                                                                                                FROM User_Position_Holders Uph
                                                                                                                                                                             WHERE Uph.Deleted = 0
                                                                                                                                                                                 AND Uph.User_Id = '#request.AccessStructure.user_ID#' ) )
                         <cfif arguments.byPlanId neq "0">
                            AND vf_Plan.vf_Plan_ID = <cfqueryparam value="#arguments.byPlanId#" cfsqltype="cf_sql_integer">
                         </cfif>
                         <cfif local.businessSegIsEnabled>
                            <!---32355 - filter based on user assigned segments--->
                          AND vf_Plan.VF_Plan_Segment_ID IN ( <cfqueryparam value="#ValueList(local.qClassCodes.Business_Segment_ID)#" cfsqltype="cf_sql_integer" list="yes"> )
                         </cfif>
                         <cfif len(trim(arguments.byClassIds))>
                            AND vf_class.vf_Class_ID in ( <cfqueryparam value="#arguments.byClassIDs#" cfsqltype="cf_sql_integer" list="yes"> )
                         </cfif>
             ORDER BY Level_Name
        </cfquery>

        <cfreturn local.vfLevels>
    </cffunction>

    <!--------------------------------------------------------------------------------------------------------------------->

    <cffunction name="getDirectAssignedMarkets" output="false" access="public" returnType="query" hint="Return direct assigned markets for a user">
        <cfargument name="userID" required="false">
        <cfargument name="Forecast_Level" required="true">

        <cfif not StructKeyExists(arguments, "userID")>
            <cfset arguments.userID = request.AccessStructure.user_ID>
        </cfif>

        <cfquery name="local.Markets" Datasource="#application.datasource#">
            SELECT  User_Positions.User_Positions_ID
                        , User_Positions.Position_Label
                        , User_Positions.Position_Description
                        , User_Positions.Position_Holder_User_ID
                        , User_Positions.Service_Zone_ID
                        , User_Positions.Service_Region_ID
                        , User_Positions.Service_Market_ID
                FROM User_Position_Holders
                         INNER JOIN User_Positions
                             ON User_Position_Holders.User_Positions_Id = User_Positions.User_Positions_Id
             WHERE User_Position_Holders.Deleted = 0
                         AND User_Position_Holders.User_Id = '#arguments.userID#'
                         <cfif arguments.Forecast_Level gte 3>      <!---market & customer--->
                                AND Service_Market_Id IS NOT NULL
                         <cfelseif arguments.Forecast_Level eq 1>   <!---zone--->
                                AND Service_Region_Id IS NULL
                         <cfelse>
                                AND Service_Market_Id IS NULL           <!---region--->
                         </cfif>
        </cfquery>

        <cfreturn local.Markets>
    </cffunction>

    <!--------------------------------------------------------------------------------------------------------------------->

    <cffunction name="saveForecast" output="false" access="public" returnType="void" hint="I save volume forecast from form elements into the database">
        <cfargument name="vf_id" required="true" type="numeric" hint="I am the volume forecast ID">
        <cfargument name="level" required="true" type="numeric" hint="I am the level ID">
        <cfargument name="quarter" required="true" type="numeric" hint="I am the quarter number (valid values are 1, 2, 3, 4)">

        <cfscript>
            const.deltaPrefix  = "delta_";
            const.volumePrefix = "volume_";
            const.use_absolute = 'abs_';

            var l    = {};
            l.changes = [];
            l.periods     = getPeriods( vf_id=arguments.vf_id, quarter=arguments.quarter );
            // grap data from db to determine if changes were made
            l.qForecast3Months = getDetail( vf_id=arguments.vf_id, level=arguments.level, periods=ValueList(l.periods.VF_Period_Id) );
        </cfscript>

    <!--- look for changes and load changed row ID into array l.changes --->
        <cfloop query="l.qForecast3Months">
            <cfscript>
              if ( structKeyExists( form, const.volumePrefix & l.qForecast3Months.vf_detail_id ) ) {
               var input = {};
                   input.volume       = replace( form[ const.volumePrefix & l.qForecast3Months.vf_detail_id ], ",", "", "all" );
                   input.percentage   = structKeyExists(form, const.deltaPrefix  & l.qForecast3Months.vf_detail_id) ? form[ const.deltaPrefix  & l.qForecast3Months.vf_detail_id ] : 'null';
                   input.use_absolute = form[ const.use_absolute & l.qForecast3Months.vf_detail_id ];
                  if ( ( l.qForecast3Months.use_absolute neq val(input.use_absolute) )
                    or ( l.qForecast3Months.ty_volume    neq val(input.volume) )
                    or ( input.percentage neq 'null' and l.qForecast3Months.ty_Delta_Percentage neq val(input.percentage) ) ) {
                    arrayAppend( l.changes, l.qForecast3Months.vf_detail_id );
                  }
              }
            </cfscript>
        </cfloop>

        <!--- update db based on array l.changes --->
        <cfloop array="#l.changes#" index="l.detail">
            <cfscript>
              var input = {};
                  input.volume       = replace( form[ const.volumePrefix & l.detail ], ",", "", "all" );
                  input.percentage   = structKeyExists(form, const.deltaPrefix  & l.detail) ? form[ const.deltaPrefix  & l.detail ] : 'null';
                  input.use_absolute = form[ const.use_absolute & l.detail ];
            </cfscript>
            <cfoutput>
            <cfquery name="l.qUpdateDb" Datasource="#application.datasource#" result="l.result">
             UPDATE VF_Detail
                    SET ty_Delta_Percentage = <cfif len(trim(input.percentage)) eq 0 or input.percentage eq 'null'> NULL <cfelse> #input.percentage# </cfif>
                       ,use_absolute        = #input.use_absolute#
                       ,ty_volume           = <cfif len(trim(input.percentage)) eq 0 or input.percentage eq 'null'> #val( input.volume )# <cfelse>  ly_Volume * ( 1 + ( ty_Delta_Percentage / 100 ) ) </cfif>
                WHERE VF_Detail_ID = <cfqueryparam value="#l.detail#" cfsqltype="cf_sql_integer">
            </cfquery>
            </cfoutput>
        </cfloop>

        <!---
		/////////////////////////////////////
        // CARRY FORWARD TO FUTURE MONTHS  //
		/////////////////////////////////////
        --->
        <cfif structKeyExists(form, 'carryfuturemonths') and form.carryfuturemonths eq '1'>
			<!---
			////////////////////////////////////////////////////////////////
			// locate the latest month in the quarter with non-empty values
			////////////////////////////////////////////////////////////////
			--->
            <cfscript>
            </cfscript>
            <cfquery name="local.latestMonthWithData" datasource="#application.datasource#">
                SELECT *
                  FROM dbo.vf_Detail AS vd
                 WHERE vd.Deleted = 0
                       AND vd.vf_Plan_Id = <cfqueryparam value="#arguments.vf_ID#" cfsqltype="cf_sql_integer">
                       AND vd.vf_Level_Id = <cfqueryparam value="#arguments.level#" cfsqltype="cf_sql_integer">
                       AND vd.vf_Period_Id = ( SELECT TOP 1 vd.vf_Period_Id
                                                 FROM dbo.vf_Detail AS vd
                                                WHERE vd.Deleted = 0
                                                      AND vd.vf_Plan_Id = <cfqueryparam value="#arguments.vf_ID#" cfsqltype="cf_sql_integer">
                                                      AND vd.vf_Level_Id = <cfqueryparam value="#arguments.level#" cfsqltype="cf_sql_integer">
                                                      AND vd.vf_Period_Id IN ( <cfqueryparam value="#valueList(l.periods.VF_Period_Id)#" cfsqltype="cf_sql_integer" list="true"> )
                                                      AND ( vd.ty_Delta_Percentage IS NOT NULL OR vd.ty_Volume IS NOT NULL )
                                                ORDER BY vd.vf_Period_Id DESC )
        	</cfquery>
			<!---
			////////////////////////////////////////////////////////////////
			// carry over to all future months
			////////////////////////////////////////////////////////////////
			--->
        	<cfif local.latestMonthWithData.recordCount gt 0>
                <!---
                ////////////////////////////////////////////////////////////////
                // get all future periods
                ////////////////////////////////////////////////////////////////
                --->
                <cfset local.futurePeriods = getFuturePeriods(arguments.vf_id, arguments.quarter)>
                <!---
                ///////////////////////////////////////////////////////////
                // copy forecast data from latest month to future months
                ///////////////////////////////////////////////////////////
                --->
                <cfoutput query="local.latestMonthWithData">
                    <!---
                    ///////////////////////////////////////////////////////////////////
                    // if product checkbox is checked (element exists) copy data over
                    ///////////////////////////////////////////////////////////////////
                    --->
                    <cfif structKeyExists(form, "cb_" & '#local.latestMonthWithData.Pg_product_category_id#')>
                        <cfquery name="local.update" datasource="#application.datasource#">
                            <!---
                            ////////////////////////////////////////////////////////////////////////////
                            // combine multiple update statements into one cfquery for best performance
                            ////////////////////////////////////////////////////////////////////////////
                            --->
                            <cfloop query="local.futurePeriods">
                                UPDATE VF_Detail
                                   SET <cfif local.latestMonthWithData.ty_delta_percentage eq ''>
                                            ty_Delta_Percentage = NULL
                                        <cfelse>
                                            ty_Delta_Percentage = #local.latestMonthWithData.ty_delta_percentage#
                                       </cfif>
                                        <cfif local.latestMonthWithData.ty_volume eq ''>
                                            ,ty_volume  = NULL
                                        <cfelse>
                                            ,ty_volume  = #local.latestMonthWithData.ty_volume#
                                        </cfif>
                                       ,use_absolute = #val(local.latestMonthWithData.use_absolute)#
                                 WHERE vf_Plan_Id       = #arguments.vf_ID#
                                       AND vf_Level_Id  = #arguments.level#
                                       AND vf_Period_Id = #local.futurePeriods.vf_Period_Id#
                                       AND Pg_product_category_id = '#local.latestMonthWithData.Pg_product_category_id#'    <!--- same product in other future period --->
                            </cfloop>
                        </cfquery>
                    </cfif>    <!--- structKeyExists(form, "cb_" & '#local.latestMonthWithData.Pg_product_category_id#') --->
                </cfoutput>    <!--- query="local.latestMonthWithData" --->
			</cfif>   <!--- cfif local.latestMonthWithData.recordCount gt 0 --->
		</cfif>    <!--- cfif structKeyExists(form, 'carryfuturemonths') and form.carryfuturemonths eq '1' --->

        <cfquery name="l.level" Datasource="#application.datasource#">
            UPDATE VF_Level
                 SET Last_Updated_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="cf_sql_varchar">
                         , Last_Updated_On = GetDate()
             WHERE VF_Level_Id = <cfqueryparam value="#arguments.level#" cfsqltype="cf_sql_integer">
        </cfquery>

    </cffunction>

    <!--------------------------------------------------------------------------------------------------------------------->

    <cffunction name="saveLockedBy" output="false" access="remote" returnType="void" hint="Update locked by">
        <cfargument name="level" required="true" hint="I am the level ID">
        <cfargument name="userID" required="true" type="string" hint="I am the user ID">

        <cfif isnumeric( arguments.level )>
            <cfquery name="local.saveLockedBy" Datasource="#application.datasource#">
                UPDATE VF_Level
                     SET Locked_By = <cfqueryparam value="#arguments.userID#" cfsqltype="cf_sql_varchar">
                             <cfif len(arguments.userID)>
                                    , Locked_Date = GETDATE()
                                    , Is_Locked = 1
                             <cfelse>
                                    , Locked_Date = NULL
                                    , Is_Locked = 0
                             </cfif>
                 WHERE VF_Level_ID = <cfqueryparam value="#arguments.level#" cfsqltype="cf_sql_integer">
                                <cfif len(arguments.userID) eq 0>
                                    <!---only unlock the record locked by the same user--->
                                    AND Locked_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="cf_sql_varchar">
                                </cfif>
            </cfquery>
        </cfif>

    </cffunction>

    <!--------------------------------------------------------------------------------------------------------------------->

    <cffunction name="isHeadQuarters" output="false" access="public" returnType="boolean" hint="Return true if current user has headquarters position">

        <cfquery name="local.query" Datasource="#application.datasource#">
            SELECT 1
              FROM USER_POSITION_HOLDERS a
                   INNER JOIN USER_POSITIONS b ON b.User_Positions_Id = a.User_Positions_Id
             WHERE a.Deleted = 0
                   AND a.User_Id = <cfqueryparam value="#request.AccessStructure.user_ID#" cfsqltype="cf_sql_varchar">
                   AND b.Position_Label = 'headquarters'
        </cfquery>

        <cfreturn (local.query.recordCount gt 0)>
    </cffunction>

    <!--------------------------------------------------------------------------------------------------------------------->

    <cffunction name="getPositions" output="false" access="public" returnType="query" hint="Return unique VF user positions.">
        <cfargument name="vf_id" required="true" hint="I am the volume forecast ID list">

        <cfquery name="local.query" Datasource="#application.datasource#">
            SELECT DISTINCT vl.User_Position_Id, up.Position_Label
                FROM VF_Level vl
                         INNER JOIN User_Positions up ON up.User_Positions_ID = vl.User_Position_Id
             WHERE
                            <cfif listLen(arguments.vf_id) eq 1>
                                vl.VF_Plan_ID = <cfqueryparam value="#arguments.vf_id#" cfsqltype="cf_sql_integer">
                            <cfelse>
                                vl.VF_Plan_ID IN ( <cfqueryparam value="#arguments.vf_id#" cfsqltype="cf_sql_integer" list="true"> )
                            </cfif>
                        AND vl.Deleted = 0
              AND vl.User_Position_Id IN ( SELECT Below_User_Positions_Id
                                            FROM POSITIONS_BELOW_ME pbm
                                           WHERE Below_User_Positions_Id IS NOT NULL
                                                 AND pbm.User_Positions_Id IN ( SELECT uph.User_Positions_Id
                                                                                  FROM USER_POSITION_HOLDERS uph
                                                                                 WHERE uph.Deleted = 0
                                                                                       AND Uph.User_Id = <cfqueryparam value="#request.AccessStructure.user_ID#" cfsqltype="cf_sql_varchar">) )
        </cfquery>

        <cfreturn local.query>
    </cffunction>

    <!--------------------------------------------------------------------------------------------------------------------->

    <cffunction name="getProducts" output="false" access="public" returnType="query" hint="Return unique VF products.">
        <cfargument name="vf_plan_id" required="true" hint="I am the volume forecast plan ID">
        <!---D60306 ::Exporting All Pages from Budgets and Volume Forecasts START --->
        <cfargument name="Product_Category_Name" required="true" default="pg_Product_Category_Name"  hint="I am the volume forecast plan ID">
        <cfargument name="Item" required="true" default="Item"   hint="I am the volume forecast plan ID">
        <!---D60306 ::Exporting All Pages from Budgets and Volume Forecasts END --->        
        <cfquery name="local.query" Datasource="#application.datasource#">
            SELECT DISTINCT pg.pg_Product_Category_Name AS #arguments.Product_Category_Name#
                            ,im.Item AS #arguments.Item# 
                            ,im.Description
			FROM VF_PLANNING_GROUPS vfpg
			INNER JOIN PG_PRODUCT_MEMBERS pgpm 
			ON pgpm.pg_Product_Category_Id = vfpg.pg_Product_Category_Id
			AND pgpm.Deleted = 0
			INNER JOIN PG_PRODUCT_CATEGORY pg 
			ON pg.pg_Product_Category_Id = pgpm.pg_Product_Category_Id
			INNER JOIN BSA_FOODSERVICE_ITEMS_MASTER im 
			ON im.bsa_FoodService_Items_Master_Id = pgpm.bsa_FoodService_Items_Master_Id
			WHERE vfpg.vf_Plan_Id = <cfqueryparam value="#arguments.vf_plan_id#" cfsqltype="cf_sql_integer">
			AND vfpg.Deleted = 0
			ORDER BY pg.pg_Product_Category_Name,im.Item
        </cfquery>

        <cfreturn local.query>
    </cffunction>

    <!--------------------------------------------------------------------------------------------------------------------->

    <cffunction name="getCustomers" output="false" access="public" returnType="query" hint="Return unique VF distributors.">
        <cfargument name="vf_plan_id" required="true" hint="I am the volume forecast plan ID">
        <cfargument name="vf_level_id" required="true" hint="I am the volume forecast level ID">
        <cfargument name="forecast_level" required="false" hint="I am the volume forecast level" default="0">

        <cfquery name="local.query" Datasource="#application.datasource#">
            DECLARE @VF_Plan_ID int, @VF_Level_ID int
            SET @VF_Plan_ID = #arguments.vf_plan_id#
            SET @VF_Level_ID = #arguments.vf_level_id#

            IF OBJECT_ID('tempdb..##tmp_dist') IS NOT NULL
            DROP TABLE ##tmp_dist

            CREATE TABLE ##tmp_dist (shr_Ship_To varchar(50), Name varchar(50))
            <cfif arguments.forecast_level eq 1 or arguments.forecast_level eq 2 or arguments.forecast_level eq 3>
            <!--- Only if volume plan has distributors specified --->
            IF EXISTS (
                SELECT  vfdp.PG_Customer_Category_ID
                FROM    VF_Distributor_Planning_Groups vfdp
                WHERE   vfdp.Deleted = 0
                AND     vfdp.VF_Plan_ID = @VF_Plan_ID
            )
            BEGIN
                INSERT INTO ##tmp_dist
                SELECT  c.shr_Ship_To, c.Name
                FROM    VF_Level l
                <cfif arguments.forecast_level eq 3>
                INNER JOIN Service_Markets m
                ON      m.Service_Market_ID = l.Service_Market_ID
                <cfelseif arguments.forecast_level eq 2>
                INNER JOIN Service_Markets m
                ON      m.Service_Region_ID = l.Service_Region_ID
                <cfelseif arguments.forecast_level eq 1>
                INNER JOIN Service_Regions r
                ON      r.Service_Zone_ID = l.Service_Zone_ID
                INNER JOIN Service_Markets m
                ON      m.Service_Region_ID = r.Service_Region_ID
                </cfif>
                <cfif application.appSettingsGet.getDistributorMultiPosition()>
                INNER JOIN Market_Distributor md
                ON      md.Service_Market_ID = m.Service_Market_ID
                AND     md.Deleted = 0
                INNER JOIN BSA_foodservice_Customers c
                ON      c.BSA_foodservice_Customers_ID = md.Distributor_ID
                <cfelse>
                INNER JOIN BSA_Foodservice_Brokers b
                ON      b.Service_Market_ID = m.Service_Market_ID
                AND     b.Deleted = 0
                INNER JOIN BSA_foodservice_Customers c
                ON      c.BSA_Foodservice_Brokers_ID = b.BSA_Foodservice_Brokers_ID
                </cfif>
                WHERE   l.VF_Plan_ID = @VF_Plan_ID
                AND     l.VF_Level_ID = @VF_Level_ID
                AND     l.Deleted = 0
                AND     EXISTS (
                        SELECT 1
                        FROM VF_Distributor_Planning_Groups vfdp
                        INNER JOIN PG_Customer_Members pgcm
                        ON vfdp.PG_Customer_Category_ID = pgcm.PG_Customer_Category_ID
                        AND pgcm.Deleted = 0
                        INNER JOIN BSA_Foodservice_Customers cm
                        ON cm.BSA_Foodservice_Customers_ID = pgcm.BSA_Foodservice_Customers_ID
                        WHERE vfdp.Deleted = 0
                        AND vfdp.VF_Plan_ID = l.VF_Plan_ID
                        AND pgcm.BSA_Foodservice_Customers_ID = c.BSA_Foodservice_Customers_ID
                        AND cm.Active_Code= 'A' -- only active customers
                )
            END
            </cfif>

            SELECT DISTINCT c.shr_Ship_To
                            ,c.Name
            FROM VF_PRODUCT_DISTRIBUTOR_DETAIL pdd
                   INNER JOIN BSA_FOODSERVICE_CUSTOMERS c ON c.bsa_FoodService_Customers_Id = pdd.bsa_FoodService_Customers_Id
            WHERE 1 = 1
                   AND pdd.Deleted = 0
                   AND pdd.vf_Plan_Id = @VF_Plan_ID
                   AND pdd.vf_Level_Id = @VF_Level_ID
            UNION
            SELECT  shr_Ship_To, Name
            FROM    ##tmp_dist
            ORDER BY 2

            IF OBJECT_ID('tempdb..##tmp_dist') IS NOT NULL
            DROP TABLE ##tmp_dist
        </cfquery>

        <cfreturn local.query>
    </cffunction>

    <!--------------------------------------------------------------------------------------------------------------------->

    <cffunction name="getClasses" output="false" access="public" returnType="query" hint="Return VF classes.">
        <cfargument name="activeOnly" required="false" default="true">
        <cfargument name="currentYearOnly" required="false" default="false">

        <cfquery name="local.query" Datasource="#application.datasource#">
            SELECT  vf_Class_ID
                   ,vf_Class_Number
                   ,vf_class_desc
              FROM VF_CLASS
             WHERE Deleted = 0
                   <cfif arguments.activeOnly>
                     AND Active = 1
                   </cfif>
                   <cfif arguments.currentYearOnly>
                    AND Getdate() BETWEEN Start_Date AND End_Date
                   </cfif>
                   ORDER BY Start_Date
        </cfquery>

        <cfreturn local.query>
    </cffunction>

</cfcomponent>
