<!---------------------------------------------------------------------------------------------------------------------
   Template: \components\Billback\Vendor_Hold.cfc
   Date:     2015 March
   Author:   Chris Nguyen
   Purpose:  Database supporting functions for Vendor Hold Research tool from home page

   Remarks:
---------------------------------------------------------------------------------------------------------------------->
<cfcomponent output="false">

    <cffunction name="getSegments" access="public" output="false" hint="Return all business segments">
        <cfset useLakebaseForlocal_data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("business_segment")>
<cfif useLakebaseForlocal_data>
	<cftry>
		<cfset local.data = application.oLakebase.toQuery(
			application.oLakebase.selectRows("business_segment", {
				"deleted" = "eq.0",
				"order" = "business_unit_id.asc",
				"select" = "business_unit_id"
			}), "business_unit_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForlocal_data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForlocal_data>
<cfquery name="local.data" datasource="#application.datasource#">
            SELECT Business_Unit_Id
              FROM Business_Segment
             WHERE Deleted = 0
             ORDER BY Business_Unit_Id
        </cfquery>
</cfif>

        <cfreturn local.data>
    </cffunction>

    <cffunction name="getStatuses" access="public" output="false" hint="Return all billback statuses">
        <cfquery name="local.data" datasource="#application.datasource#">
            SELECT bb_Status_Abbreviation
              FROM BillBack_Status
        </cfquery>

        <cfreturn local.data>
    </cffunction>

    <cffunction name="getClosings" access="public" output="false" hint="Return all closing methods">
        <cfquery name="local.data" datasource="#application.datasource#">
            SELECT vchBillBack_cLosing_Method_desc
              FROM BillBack_cLosing_Methods
             WHERE bENabLed = 1
                   AND Deleted = 0
             ORDER BY vchBillBack_cLosing_Method_desc
        </cfquery>

        <cfreturn local.data>
    </cffunction>


    <cffunction name="getBillBacks" access="public" output="false" hint="Return billbacks on hold along with WIP/RFA billbacks">
        <cfquery name="local.data" datasource="#application.datasource#">
            IF Object_Id( 'tempdb..##tmp_hold_approved' ) IS NOT NULL
              DROP TABLE ##tmp_hold_approved

            SELECT  bb.BillBack_Id
					   ,bb.bb_Parent_Id
					   ,vm.Vendor_Id
					   ,vm.Vendor_Name
					   ,bb.Referencenum,
						bb.BB_Closing_Method,
					    CASE WHEN bb.Billback_Payee_Type_ID = 1 THEN bsac.Ship_To
							 WHEN bb.Billback_Payee_Type_ID = 2 THEN CASE WHEN bsao.legacy_id IS NOT NULL THEN bsao.legacy_id 
																   ELSE CAST(bsao.BSA_Operator_ID AS VARCHAR(100))
															  END
						END AS Payee_ID,
						CASE WHEN bb.Billback_Payee_Type_ID = 1 THEN bsac.Name
							 WHEN bb.Billback_Payee_Type_ID = 2 THEN bsao.Operator_Name
						END AS Payee_Name
              INTO ##tmp_hold_approved
              FROM BillBack bb
					INNER JOIN bb_Approved ba ON ba.BillBack_Id = IsNull( bb.bb_Parent_Id, bb.BillBack_Id )
					LEFT JOIN Vendor_Master vm ON vm.Vendor_Master_Id = ba.Vendor_Master_Id
                                                  AND vm.Deleted = 0
					LEFT JOIN	Billback_Distributor bd
					ON			bd.Billback_ID = IsNull( bb.bb_Parent_Id, bb.BillBack_Id ) 
					AND			bd.Deleted =0
					LEFT JOIN	Billback_Operator bo
					ON			bo.Billback_ID = IsNull( bb.bb_Parent_Id, bb.BillBack_Id ) 
					AND			bo.Deleted =0
					LEFT JOIN	BSA_Foodservice_Customers bsac
					ON			bsac.BSA_Foodservice_Customers_ID = bd.Distributor_ID 
					LEFT JOIN	BSA_Operator  bsao
					ON			bsao.BSA_Operator_ID = bo.Operator_ID 
             WHERE bb.Deleted = 0
                   AND bb.bb_Reversed = 0
                   AND bb.bb_Payment_Request_Sent = 0
                   AND bb.bb_Received_ack_Type = 0
                   ---AND bb.bb_Parent_Id IS NOT NULL
                   AND ( bb.Hold = 1
                          OR bb.Released_Date >= Cast( CONVERT( VARCHAR(30), GetDate( ), 101 ) AS DATETIME ) )
                   AND NOT EXISTS ( SELECT 1
                                      FROM BillBack bbs
                                     WHERE bbs.bb_Parent_Id = bb.BillBack_Id
                                           AND bbs.Deleted = 0
                                           AND bbs.bb_Reversed = 0
                                           AND bbs.bb_Payment_Request_Sent = 0
                                           AND bbs.bb_Received_ack_Type = 0 )
			
            IF Object_Id( 'tempdb..##tmp_hold_Notapproved_1' ) IS NOT NULL
              DROP TABLE ##tmp_hold_Notapproved_1

            SELECT  bb.BillBack_Id
                   ,bb.bb_Parent_Id
                   ,vm.Vendor_Id
                   ,vm.Vendor_Name
                   ,bb.Referencenum,
				    bb.BB_Closing_Method,
					CASE WHEN bb.Billback_Payee_Type_ID = 1 THEN bsac.Ship_To
						 WHEN bb.Billback_Payee_Type_ID = 2 THEN CASE WHEN bsao.legacy_id IS NOT NULL THEN bsao.legacy_id 
															   ELSE CAST(bsao.BSA_Operator_ID AS VARCHAR(50))
														  END
					END AS Payee_ID,
					CASE WHEN bb.Billback_Payee_Type_ID = 1 THEN bsac.Name
						 WHEN bb.Billback_Payee_Type_ID = 2 THEN bsao.Operator_Name
					END AS Payee_Name
              INTO ##tmp_hold_Notapproved_1
              FROM BillBack bb
					LEFT JOIN BillBack_Distributor bd ON bd.BillBack_Id = IsNull( bb.bb_Parent_Id, bb.BillBack_Id )
                                                        AND bd.Deleted = 0
					LEFT JOIN BillBack_Operator bo ON bo.BillBack_Id = IsNull( bb.bb_Parent_Id, bb.BillBack_Id )
                                                     AND bo.Deleted = 0
					LEFT JOIN Vendor_Master vm ON vm.Vendor_Id = COALESCE( bd.UpLoaded_Vendor_Id, bo.UpLoaded_Vendor_Id )
					LEFT JOIN	BSA_Foodservice_Customers bsac
					ON			bsac.BSA_Foodservice_Customers_ID = bd.Distributor_ID 
					LEFT JOIN	BSA_Operator  bsao
					ON			bsao.BSA_Operator_ID = bo.Operator_ID 
             WHERE bb.Deleted = 0
                   AND bb.BillBack_Status_Id IN ( 1, 2 )
                   AND NOT EXISTS ( SELECT 1
                                      FROM BillBack bbs
                                     WHERE bbs.bb_Parent_Id = bb.BillBack_Id
                                           AND bbs.Deleted = 0
                                           AND bbs.bb_Reversed = 0
                                           AND bbs.bb_Payment_Request_Sent = 0
                                           AND bbs.bb_Received_ack_Type = 0 )
             
			  IF Object_Id( 'tempdb..##tmp_hold_Notapproved' ) IS NOT NULL
              DROP TABLE ##tmp_hold_Notapproved

			  SELECT *
			  INTO ##tmp_hold_Notapproved 
			  FROM ##tmp_hold_Notapproved_1 notapp
			  WHERE EXISTS ( SELECT 1
							 FROM ##tmp_hold_approved app
                             WHERE app.Referencenum = notapp.Referencenum 
                             AND ( (isnull(notapp.Vendor_Id, '') = isnull(app.Vendor_Id, '') AND app.BB_Closing_Method = 1)  -- Payment, match on vendor
									or 
									(notapp.Payee_ID = app.Payee_ID)   -- Others, match on Payee
								) 
							)
        			
            IF Object_Id( 'tempdb..##tmp_hold_research' ) IS NOT NULL
              DROP TABLE ##tmp_hold_research

            SELECT *
              INTO ##tmp_hold_research
              FROM ##tmp_hold_approved
            UNION ALL
            SELECT *
              FROM ##tmp_hold_Notapproved

            SELECT IsNull( bb.bb_Parent_Id, bb.BillBack_Id ) AS BillBack_Id
                   ,SubString( bb.bb_Code, 1, 10 )           AS bb_Code
                   ,bb.bb_Reference --Invoice
                   ,bb.Referencenum
                   ,bb.bb_Amount
                   ,bs.bb_Status_Abbreviation -- billback status
                   ,CASE
                      WHEN bb.BillBack_Payee_Type_Id = 1 THEN bsac.Ship_To
                      WHEN bb.BillBack_Payee_Type_Id = 2 THEN
                          CASE
                            WHEN bsao.Legacy_Id IS NOT NULL THEN bsao.Legacy_Id
                            ELSE ( Cast( bsao.bsa_Operator_Id AS VARCHAR( 100 )) )
                          END
                    END                                      AS Payee_Id
                   ,CASE
                      WHEN bb.BillBack_Payee_Type_Id = 1 THEN bsac.Name
                      WHEN bb.BillBack_Payee_Type_Id = 2 THEN bsao.Operator_Name
                    END                                      AS Payee_Name
                   ,bb.Hold -- show check mark when hold = 1 else display unchecked
                   ,isnull(##tmp_Hold_Research.Vendor_Name, '') as Vendor_Name
                   ,isnull(##tmp_Hold_Research.Vendor_Id, '') as Vendor_ID
                   ,cm.Business_Segment_Id
                   ,bseg.Business_Unit_Id                    AS Segment
                   ,( u2.Name_First + ' ' + u2.Name_Last )   AS Analyst
                   ,bcm.vchBillBack_cLosing_Method_desc      AS cLosing_Method
                   --,ba.bb_Amount
                   ,CASE
                      WHEN bb.BillBack_Status_Id = 1
                            OR bb.BillBack_Status_Id = 2 THEN NULL
                      ELSE ba.Expected_Amount
                    END                                      AS Expected_Amount
                   ,CASE
                      WHEN bb.BillBack_Status_Id = 1
                            OR bb.BillBack_Status_Id = 2 THEN NULL
                      ELSE ba.Approved_Amount
                    END                                      AS Approved_Amount
                   ,CASE
                      WHEN bb.BillBack_Status_Id = 1
                            OR bb.BillBack_Status_Id = 2 THEN NULL
                      ELSE ba.Date_Approved
                    END                                      AS Date_Approved
                   ,bb.Created_Date
                   ,CASE
                      WHEN bb.BillBack_Status_Id = 1
                            OR bb.BillBack_Status_Id = 2 THEN DatedIff( DAY, bb.Created_Date, GetDate( ) )
                      WHEN bb.BillBack_Status_Id >= 3 THEN DatedIff( DAY, bb.Created_Date, ba.Date_Approved )
                      ELSE 0
                    END                                      AS Age
                   ,bb.BillBack_Status_Id
              FROM BillBack bb
                   INNER JOIN ##tmp_hold_research ON bb.BillBack_Id = ##tmp_Hold_Research.BillBack_Id
                   INNER JOIN BillBack_Status bs ON bs.BillBack_Status_Id = bb.BillBack_Status_Id
                   INNER JOIN BillBack_cLosing_Methods bcm ON bcm.iBillBack_cLosing_Method_Id = bb.bb_cLosing_Method
                   LEFT JOIN bb_Approved ba ON ba.BillBack_Id = IsNull( bb.bb_Parent_Id, bb.BillBack_Id )
                   LEFT JOIN BillBack_Distributor bd ON bd.BillBack_Id = IsNull( bb.bb_Parent_Id, bb.BillBack_Id )
                                                        AND bd.Deleted = 0
                   LEFT JOIN BillBack_Operator bo ON bo.BillBack_Id = IsNull( bb.bb_Parent_Id, bb.BillBack_Id )
                                                     AND bo.Deleted = 0
                   LEFT JOIN bsa_FoodService_Customers bsac ON bsac.bsa_FoodService_Customers_Id = bd.Distributor_Id
                   LEFT JOIN bsa_Operator bsao ON bsao.bsa_Operator_Id = bo.Operator_Id
                   LEFT JOIN _Users released ON released.User_Id = bb.Released_By
                   LEFT JOIN _Users u2 ON u2.User_Id = bb.Analyst_User_Id
                   LEFT JOIN BillBack_Program bp ON bp.BillBack_Id = bb.BillBack_Id
                   LEFT JOIN Contract_Main cm ON cm.Contract_Main_Id = bp.Program_Id
                   LEFT JOIN Business_Segment bseg ON bseg.Business_Segment_Id = cm.Business_Segment_Id
             WHERE bb.Deleted = 0
                         ORDER BY Referencenum ASC
                                  ,BillBack_Status_Id DESC
        </cfquery>

        <cfreturn local.data>
    </cffunction>


    <cffunction name="saveData" access="public" output="false" hint="Save changes on ">
        <cfargument name="data" required="true" hint="">

        <cfif structKeyExists(arguments.data, "unrelease")>
            <cfloop list="#arguments.data.unrelease#" index="local.billback_id">
                <cfquery name="local.query" datasource="#application.datasource#">
                    UPDATE BILLBACK
                       SET Hold = 1
                          ,Released_By = NULL
                          ,Released_Date = NULL
                          ,Hold_Date = GETDATE()
                     WHERE billback_id = <cfqueryparam value="#local.billback_id#" cfsqltype="cf_sql_varchar">
                    <!---update the splits--->
                    UPDATE BILLBACK
                       SET Hold = 1
                          ,Released_By = NULL
                          ,Released_Date = NULL
                          ,Hold_Date = GETDATE()
                       WHERE bb_parent_id = <cfqueryparam value="#local.billback_id#" cfsqltype="cf_sql_varchar">
                </cfquery>
            </cfloop>
        </cfif>

        <cfif structKeyExists(arguments.data, "release")>
            <cfloop list="#arguments.data.release#" index="local.billback_id">
                <cfquery name="local.query" datasource="#application.datasource#">
                    UPDATE BILLBACK
                         SET Hold = 0
                            ,Released_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="cf_sql_varchar">
                            ,Released_Date = GETDATE()
                     WHERE billback_id = <cfqueryparam value="#local.billback_id#" cfsqltype="cf_sql_varchar">
                    <!---update the splits--->
                    UPDATE BILLBACK
                         SET Hold = 0
                            ,Released_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="cf_sql_varchar">
                            ,Released_Date = GETDATE()
                       WHERE bb_parent_id = <cfqueryparam value="#local.billback_id#" cfsqltype="cf_sql_varchar">
                </cfquery>
            </cfloop>
        </cfif>
    </cffunction>

</cfcomponent>