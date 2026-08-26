<!--------------------------------------------------------------------------------------------------------------------------------------------------------
  Component: \components\programs\Vendor\vendor.cfc
  Date:      2008
  Author:    Milan

  Remarks:

--------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfcomponent hint="Vendor Manager">

  <cffunction name="getVendorInfo" output="false" returntype="query">
    <cfargument name="Vendor_Master_ID" type="string" required="true" default="">

    <cfquery name="qgetVendorInfo" datasource="#application.datasource#">
     SELECT Vendor_Name,Vendor_ID
     FROM Vendor_Master
     WHERE Vendor_Master_ID
     <cfif arguments.Vendor_Master_ID eq "">
     IS NULL
      <cfelse>
     = '#arguments.Vendor_Master_ID#'
      </cfif>
    </cfquery>

    <cfreturn qgetVendorInfo>
  </cffunction>

  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->

  <cffunction name="isBankInfoMissing" output="false" access="remote" returnFormat="json">
    <cfargument name="vendor_id" type="string" required="true">
    <cfargument name="closing_method" type="string" required="true">

    <cfscript>
        local.result = {};
        local.result.errors = [];
    </cfscript>

    <cfquery name="local.vendor" datasource="#application.datasource#">
       SELECT *
         FROM Vendor_Master
        WHERE Vendor_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim( arguments.vendor_id )#">
    </cfquery>
    <cfquery name="local.closing_method" datasource="#application.datasource#">
       SELECT *
         FROM BILLBACK_CLOSING_METHODS
        WHERE iBillback_Closing_Method_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#trim( arguments.closing_method )#">
    </cfquery>

    <cfif local.closing_method.require_bank_info eq '1' and
         ( local.vendor.vendor_bank_name eq "" or
           local.vendor.vendor_bank_routing_number eq "" or
           local.vendor.vendor_bank_account_number eq "" )>
      <cfset arrayAppend(local.result.errors, "Missing bank information in selected vendor.")>
    </cfif>

    <cfreturn local.result>
  </cffunction>

  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->

  <cffunction name="isVendorMaster" output="false" access="remote" returnFormat="json">
    <cfargument name="vendor_id" type="string" required="true">

    <cfscript>
        local.result = {};
        local.result.errors = [];
    </cfscript>

    <cfquery name="local.query" datasource="#application.datasource#">
       SELECT 1
         FROM Vendor_Master
        WHERE Vendor_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim( arguments.vendor_id )#">
    </cfquery>

    <cfif local.query.recordCount eq 0>
      <cfset arrayAppend(local.result.errors, "Vendor ID is not valid.")>
    </cfif>

    <cfreturn local.result>
  </cffunction>

  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->

  <cffunction name="getVendors" access="public" returntype="query" output="false">
    <cfargument name="batched" type="string" required="false" default="yes">
    <cfquery name="local.query" datasource="#application.datasource#">
      SELECT Vendor_ID
            ,Vendor_Name
            ,Address_1
            ,City
            ,State
            ,Zipcode
            ,Is_Batched
            ,vendor_master_id
        FROM VENDOR_MASTER
       WHERE Deleted = 0
             <cfif arguments.batched eq "yes">
               AND Is_Batched = 1
             <cfelseif arguments.batched eq "no">
               AND Is_Batched = 0
             </cfif>
       ORDER BY Vendor_ID
    </cfquery>

    <cfreturn local.query>
  </cffunction>

  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->

  <cffunction name="getBillbacksOnHold" access="public" returntype="query" output="false">

    <cfquery name="local.query" datasource="#application.datasource#">
      SELECT ISNULL(bb.bb_Parent_Id, bb.BillBack_Id)         AS BillBack_Id
             ,Substring( bb.bb_Code, 1, 10 )                 AS bb_code       --BB_Code
             ,bb.bb_Reference       --Invoice
             ,bb.bb_amount
             ,bs.bb_Status_Abbreviation                      -- billback status
             ,CASE
                WHEN bb.BillBack_Payee_Type_Id = 1 THEN bsac.Ship_To
                WHEN bb.BillBack_Payee_Type_Id = 2 THEN
                  CASE
                    WHEN bsao.Legacy_Id IS NOT NULL THEN bsao.Legacy_Id
                    ELSE (CAST(bsao.bsa_Operator_Id AS varchar(100)))
                  END
              END                                            AS payee_id
             ,CASE
                WHEN bb.BillBack_Payee_Type_Id = 1 THEN bsac.Name
                WHEN bb.BillBack_Payee_Type_Id = 2 THEN bsao.Operator_Name
              END                                            AS payee_name
             ,bb.Hold    -- show check mark when hold = 1 else display unchecked
        FROM BILLBACK bb
             INNER JOIN BILLBACK_STATUS bs ON bs.BillBack_Status_Id = bb.BillBack_Status_Id
             INNER JOIN BILLBACK_CLOSING_METHODS bcm ON bcm.iBillBack_cLosing_Method_Id = bb.bb_cLosing_Method
             INNER JOIN BB_APPROVED ba ON ba.BillBack_Id = IsNull( bb.bb_Parent_Id, bb.BillBack_Id )
             INNER JOIN VENDOR_MASTER vm ON vm.Vendor_Master_Id = ba.Vendor_Master_Id
                                            AND vm.Deleted = 0
             LEFT JOIN BILLBACK_DISTRIBUTOR bd ON bd.BillBack_Id = IsNull( bb.bb_Parent_Id, bb.BillBack_Id )
                                                  AND bd.Deleted = 0
             LEFT JOIN BILLBACK_OPERATOR bo ON bo.BillBack_Id = IsNull( bb.bb_Parent_Id, bb.BillBack_Id )
                                               AND bo.Deleted = 0
             LEFT JOIN BSA_FOODSERVICE_CUSTOMERS bsac ON bsac.bsa_FoodService_Customers_Id = bd.Distributor_Id
             LEFT JOIN BSA_OPERATOR bsao ON bsao.bsa_Operator_Id = bo.Operator_Id
             LEFT JOIN BILLBACK_TXT_UPLOAD_HEADER_LOG th ON th.BillBack_Id = IsNull( bb.bb_Parent_Id, bb.BillBack_Id )
             LEFT JOIN _USERS released ON released.User_Id = bb.Released_By
       WHERE bb.Deleted = 0
             AND bb.bb_Reversed = 0
             AND bb.bb_Payment_Request_Sent = 0
             AND bb.bb_Received_ack_Type = 0
             AND IsNull( bsac.Name, bsao.Operator_Name ) IS NOT NULL
             ---AND bb.bb_Parent_Id IS NOT NULL
             AND ( bb.Hold = 1
                    OR bb.Released_Date >= Cast( CONVERT( VARCHAR(30), Getdate(), 101 ) AS DATETIME ) )
			 /*
			 	D46391 KRAFT VENDOR BATCHING -- Include CM = DD and CM/ Anand Rao/19-Nov-2014
				Removed the condition so that the results will return correctly when the Closing Method is
				Deductions or Credit Memo
			 */
             /*  AND bb.BillBack_Status_Id = 4 */
             AND NOT EXISTS ( SELECT 1
                                FROM Billback bbs
                               WHERE bbs.BB_Parent_ID = bb.Billback_ID
                                     AND bbs.deleted = 0
                                         AND bbs.bb_Reversed = 0
                                         AND bbs.bb_Payment_Request_Sent = 0
                                         AND bbs.bb_Received_ack_Type = 0
                                )

             ORDER BY bb_code
    </cfquery>

    <cfreturn local.query>
  </cffunction>

  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->

  <cffunction name="saveBatchedVendors" access="public" returntype="void" output="true">
    <cfargument name="form" required="true">

    <cfset local.prefix = "BATCHED_">
    <cfloop collection="#arguments.form#" item="local.item">
        <cfif local.item contains local.prefix>
         <cfquery name="local.query" datasource="#application.datasource#">
            <cfset local.vendor_master_id = replaceNocase(local.item, local.prefix, '')>
            UPDATE VENDOR_MASTER
               SET Is_Batched = 1
                  ,Batched_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="cf_sql_varchar">
                  ,Batched_Date = GETDATE()
                  ,UnBatched_By = NULL
                  ,UnBatched_Date = NULL
             WHERE vendor_master_id = <cfqueryparam value="#local.vendor_master_id#" cfsqltype="cf_sql_varchar">
          </cfquery>
        </cfif>
    </cfloop>

    <cfif len(arguments.form.notbatched)>
      <cfquery name="local.query" datasource="#application.datasource#">
        <cfloop list="#arguments.form.notbatched#" index="local.item">
        <cfif local.item contains local.prefix>
              <cfset local.vendor_master_id = replaceNocase(local.item, local.prefix, '')>
              UPDATE VENDOR_MASTER
                 SET Is_Batched = 0
                    ,UnBatched_By = <cfqueryparam value="#request.AccessStructure.User_ID#">
                    ,UnBatched_Date = GETDATE()
                    ,Batched_By = NULL
                    ,Batched_Date = NULL
               WHERE vendor_master_id = <cfqueryparam value="#local.vendor_master_id#" cfsqltype="cf_sql_varchar">

                UPDATE BILLBACK
                   SET Hold = 0
                       ,Released_Date = GETDATE()
                       ,Released_By = <cfqueryparam value="#request.AccessStructure.User_ID#">
                  FROM BILLBACK
                       INNER JOIN BB_APPROVED ON BB_APPROVED.BillBack_Id = BILLBACK.BillBack_Id
                                             AND BB_APPROVED.Vendor_Master_Id = <cfqueryparam value="#local.vendor_master_id#" cfsqltype="cf_sql_varchar">
                 WHERE BILLBACK.Hold = 1
                       AND BILLBACK.bb_Reversed = 0
                       AND BILLBACK.bb_Payment_Request_Sent = 0
                       AND BILLBACK.bb_Received_ack_Type = 0
            </cfif>
        </cfloop>
      </cfquery>
    </cfif>   <!---len(arguments.form.notbatched)>--->
  </cffunction>

  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->

  <cffunction name="saveBillbacksOnHold" access="public" returntype="void" output="true">
    <cfargument name="form" required="true">

    <cfset local.prefix = "BB_">

    <!---update released billbacks--->
    <cfloop collection="#arguments.form#" item="local.item">
        <cfif local.item contains local.prefix>
          <cfset local.billback_id = replaceNocase(local.item, local.prefix, '')>
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
        </cfif>
    </cfloop>

    <!---update billbacks switched from released back to hold--->
    <cfloop list="#arguments.form.notReleased#" index="local.item">
      <cfif local.item contains local.prefix>
        <cfset local.billback_id = replaceNocase(local.item, local.prefix, '')>
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
      </cfif>
    </cfloop>
  </cffunction>
</cfcomponent>