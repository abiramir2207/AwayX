    <!---
    Description:
        Component used for programs

--->

<cfcomponent>

    <cffunction name="getFixedEZSettings" output="false" returntype="query">

        <cfargument name="programId" required="false" default="" />
        <cfargument name="productlist" required="true" default="" />
        <cfargument name="fixed_comp_ids" required="true" default="" />

        <CFQUERY NAME="qgetFixedEZSettings" datasource="#application.datasource#">
        select distinct BSA_Foodservice_Items_Master_ID,
            ISNULL(dbo.Program_Fixed_Price_Product_Data.Fixed_Price_Value,0.0000) as Fixed_Price_Value,
            Program_Fixed_Component_Name.Program_Fixed_Component_Name_Id,
            dbo.Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID
            from contract_products
            INNER JOIN  Program_Fixed_Price_Product_Data ON
            Contract_Products.Contract_Products_ID =
            Program_Fixed_Price_Product_Data.Contract_Products_ID
            and Program_Fixed_Price_Product_Data.deleted = 0
            INNER JOIN  Units_of_Measure
            ON Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID =
            Units_of_Measure.Unit_Of_Measure_ID
            inner JOIN Program_Fixed_Component
            ON Program_Fixed_Component.Program_Fixed_Component_Id =
            Program_Fixed_Price_Product_Data.Program_Fixed_Component_Id
            AND Program_Fixed_Component.DELETED = 0
            and Program_Fixed_Component.program_id =
            contract_products.contract_main_id
            INNER JOIN Program_Fixed_Component_Name On
            Program_Fixed_Component_Name.Program_Fixed_Component_Name_Id =
            Program_Fixed_Component.Program_Fixed_Component_Name_Id
            and Program_Fixed_Component_Name.deleted = 0
            where  Contract_Products.Deleted = 0
            and Contract_Products.product_type_id = 1
            AND Contract_Products.Contract_Main_ID = #arguments.programId#
            <CFIF LIstlen(arguments.fixed_comp_ids) GT 0>
            and
            Program_Fixed_Component_Name.Program_Fixed_Component_Name_Id IN (#arguments.fixed_comp_ids#)
            <cfelse>
            AND 1 = 2
            </CFIF>
            <CFIF ListLen(arguments.productlist) EQ 0>
            AND 1=2
            <CFELSE>
            AND contract_products.BSA_Foodservice_Items_Master_ID
            IN (#ListQualify(arguments.productlist, "'", ",")#)
            </cfif>
    </CFQUERY>

        <cfreturn qgetFixedEZSettings />

    </cffunction>


    <cffunction name="getFixedEZComponents" output="false" returntype="query">
        <cfargument name="programId" required="false" default="" />

        <cfset useLakebaseForqgetFixedEZComponents = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_fixed_component")>
<cfif useLakebaseForqgetFixedEZComponents>
	<cftry>
		<cfset qgetFixedEZComponents = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_fixed_component", {
				"deleted" = "eq.0",
				"program_id" = "eq.#arguments.programId#",
				"select" = "program_fixed_component_name_id"
			}), "program_fixed_component_name_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetFixedEZComponents = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetFixedEZComponents>
<CFQUERY NAME="qgetFixedEZComponents" datasource="#application.datasource#">
        select distinct Program_Fixed_Component_Name_Id
        from Program_Fixed_Component
        where deleted = 0
        and program_id = #arguments.programId#
        </CFQUERY>
</cfif>

        <cfreturn qgetFixedEZComponents />

    </cffunction>


    <cffunction name="getRebateEZSettings" output="false" returntype="query">

        <cfargument name="programId" required="false" default="" />
        <cfargument name="productlist" required="true" default="" />
        <cfargument name="rebate_comp_id" required="true" default="" />


        <CFQUERY NAME="qgetRebateEZSettings" datasource="#application.datasource#">
            select ISNUll(rate,0) as rebate_rate,
            Program_Rebates_Component_Data.Unit_Of_Measure_Id,
            BSA_Foodservice_Items_Master_ID,
            Program_Rebates_Component.Program_Rebates_Component_Name_Id
            from
            contract_products inner join
            Program_Rebates_Product_Data on
            Program_Rebates_Product_Data.contract_products_id =
            contract_products.contract_products_id
            and contract_products.contract_main_id =
            Program_Rebates_Product_Data.program_id
            inner join Program_Rebates_Component_Data on
            Program_Rebates_Component_Data.Program_Rebates_Product_Data_id =
            Program_Rebates_Product_Data.Program_Rebates_Product_Data_Id
            and Program_Rebates_Component_Data.deleted = 0
            LEFT join Program_Rebates_Component on
            Program_Rebates_Component.Program_Rebates_Component_Id =
            Program_Rebates_Component_Data.Program_Rebates_Component_Id
            LEFT JOIN Program_Rebates_Component_Name On
            Program_Rebates_Component_Name.Program_Rebates_Component_Name_Id =
            Program_Rebates_Component.Program_Rebates_Component_Name_Id
            and Program_Rebates_Component_Name.deleted = 0
            where contract_products.deleted = 0
            and contract_products.product_type_id = 2
            and Program_Rebates_Product_Data.deleted = 0
            AND Contract_Products.Contract_Main_ID = #arguments.programId#
            <CFIF Listlen(arguments.rebate_comp_id) GT 0>
            and
            Program_Rebates_Component_Name.Program_Rebates_Component_Name_Id = '#arguments.Rebate_comp_id#'
            </CFIF>
            <CFIF ListLen(arguments.productlist) EQ 0>
            AND 1=2
            <CFELSE>
            AND contract_products.BSA_Foodservice_Items_Master_ID
            IN (#ListQualify(arguments.productlist, "'", ",")#)
            </cfif>
    </CFQUERY>

        <cfreturn qgetRebateEZSettings />

    </cffunction>

    <cffunction name="getRebateEZComponents" output="false" returntype="query">
        <cfargument name="programId" required="false" default="" />

        <cfset useLakebaseForqgetRebateEZComponents = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_rebates_component")>
<cfif useLakebaseForqgetRebateEZComponents>
	<cftry>
		<cfset qgetRebateEZComponents = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_rebates_component", {
				"deleted" = "eq.0",
				"program_id" = "eq.#arguments.programId#",
				"select" = "program_rebates_component_name_id"
			}), "program_rebates_component_name_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetRebateEZComponents = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetRebateEZComponents>
<CFQUERY NAME="qgetRebateEZComponents" datasource="#application.datasource#">
        select distinct Program_Rebates_Component_Name_Id
        from Program_Rebates_Component
        where deleted = 0
        and program_id = #arguments.programId#
        </CFQUERY>
</cfif>

        <cfreturn qgetRebateEZComponents />

    </cffunction>


    <cffunction name="getBidrequestEZSettings" output="false" returntype="query">

        <cfargument name="programId" required="false" default="" />
        <cfargument name="productlist" required="true" default="" />
        <cfargument name="comp_ids" required="true" default="" />

        <CFQUERY NAME="qgetBidrequestEZSettings" datasource="#application.datasource#">
        select distinct BSA_Foodservice_Items_Master_ID,
        ISNULL(Program_Bid_Request_Product.Price,0.0000) as Bidrequest_Price_Value,
        Program_Bidrequest_Component_Name.Program_Bidrequest_Component_Name_Id,
            dbo.Program_Bid_Request_Product.UOM as Unit_Of_Measure_ID
            from contract_products
            INNER JOIN  Program_Bid_Request_Product ON
            Contract_Products.Contract_Products_ID =
            Program_Bid_Request_Product.Contract_Products_ID
            and Program_Bid_Request_Product.deleted = 0
            inner JOIN Program_Bidrequest_Component
            ON Program_Bidrequest_Component.Program_Bidrequest_Component_Id =
            Program_Bid_Request_Product.Program_Bidrequest_Component_Id
            AND Program_Bidrequest_Component.DELETED = 0
            and Program_Bidrequest_Component.program_id =
            contract_products.contract_main_id
            INNER JOIN Program_Bidrequest_Component_Name On
            Program_Bidrequest_Component_Name.Program_Bidrequest_Component_Name_Id =
            Program_Bidrequest_Component.Program_Bidrequest_Component_Name_Id
            and Program_Bidrequest_Component_Name.deleted = 0
            where  Contract_Products.Deleted = 0
            and Contract_Products.product_type_id = 10
            AND Contract_Products.Contract_Main_ID = #arguments.programId#
            <CFIF LIstlen(arguments.comp_ids) GT 0>
            and
            Program_Bidrequest_Component_Name.Program_Bidrequest_Component_Name_Id IN (#arguments.comp_ids#)
            <cfelse>
            AND 1 = 2
            </CFIF>
            <CFIF ListLen(arguments.productlist) EQ 0>
            AND 1=2
            <CFELSE>
            AND contract_products.BSA_Foodservice_Items_Master_ID
            IN (#ListQualify(arguments.productlist, "'", ",")#)
            </cfif>
    </CFQUERY>

        <cfreturn qgetBidrequestEZSettings />

    </cffunction>

    <cffunction name="getGrowthEZSettings" output="false" returntype="query">

        <cfargument name="programId" required="false" default="" />
        <cfargument name="productlist" required="true" default="" />
        <cfargument name="component_id" required="true" default="" />

        <CFQUERY NAME="qgetGrowthEZSettings" datasource="#application.datasource#">
            SELECT  DISTINCT BSA_Foodservice_Items_Master_ID,
            isnull(rate,0) as growth_rate,
            Unit_Of_measure_id,tier_number
            FROM    Contract_Products
            INNER JOIN  Program_Growth_Component_Product_Data ON
            Contract_Products.Contract_Products_ID =
            Program_Growth_Component_Product_Data.Contract_Products_ID
            AND Program_Growth_Component_Product_Data.Deleted = 0
            inner join Program_Growth_Components on
            Program_Growth_Components.Program_Growth_Component_id =
            Program_Growth_Component_Product_Data.Program_Growth_Component_id
            and Program_Growth_Components.program_id =
            Contract_Products.Contract_Main_ID
            inner join Program_Growth_Component_Tiers on
            Program_Growth_Component_Tiers.Program_Growth_Component_id=
            Program_Growth_Components.Program_Growth_Component_ID
            and Program_Growth_Component_Tiers.deleted = 0
            inner join Program_Growth_Component_Product_Tier_Data on
Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Product_Data_id = Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_id
            and Program_Growth_Component_Product_Tier_Data.deleted = 0
            and Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Tier_Id=
            Program_Growth_Component_Tiers.Program_Growth_Component_Tier_Id
            WHERE   Contract_Products.Deleted = 0
            AND     Contract_Products.Contract_Main_ID = '#arguments.ProgramID#'
            AND     Contract_Products.Discounted_Item = 1
            AND
            (
            (Contract_Products.Product_Group_ID = CAST(Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Contract_Products.Is_Group = 1)
            OR
            (ISNULL(Contract_Products.Product_Group_ID, '') = '' AND Contract_Products.Is_Group = 0)
            )
            AND Program_Growth_Components.Program_Growth_Components_Name_ID = '#arguments.component_id#'
            <CFIF ListLen(arguments.productlist) EQ 0>
            AND 1=2
            <CFELSE>
            AND contract_products.BSA_Foodservice_Items_Master_ID
            IN (#ListQualify(arguments.productlist, "'", ",")#)
            </cfif>
            </CFQUERY>

        <cfreturn qgetGrowthEZSettings />

    </cffunction>

    <cffunction name="getLumpsumEZComponents" output="false" returntype="query">
        <cfargument name="programId" required="true" default="" />
        <cfargument name="Lumpsum_Name_Id" required="false" default="" />
        <CFQUERY NAME="qgetLumpsumEZComponents" datasource="#application.datasource#">
        select distinct *
        from Program_Lump_Sums
        where deleted = 0
        and program_id = #arguments.programId#
        <cfif isdefined("arguments.Lumpsum_Name_Id") and arguments.Lumpsum_Name_Id NEQ "">
        and Program_Lump_Sum_Name_ID = #Program_Lump_Sum_Name_ID#
        </cfif>
        </CFQUERY>

        <cfreturn qgetLumpsumEZComponents />

    </cffunction>

    <!--- 55147: EZ Button Settings - New Location in Application /Anand Rao/15-Oct-2015 --->

    <cffunction name="getEZButtonRates" output="false" returntype="query">
        <cfargument name="EZButtonRateID" required="false" default="" />

        <cfquery name="qGetEZButtonRates" datasource="#application.datasource#">
            DELETE FROM EZ_Button_Rate_Setting WHERE DATEDIFF(HOUR, Created_Date, GETDATE()) > 24 AND EZ_Button_Rate_Title = ''
        </cfquery>

        <cfquery name="qGetEZButtonRates" datasource="#application.datasource#">
         SELECT
            EZ_Button_Rate_ID,
            EZ_Button_Rate_Title,
            EZ_Contract_ID,
            Created_Date,
            Created_By,
            Updated_Date,
            Updated_By,
            Deleted,
               (SELECT COUNT(1)
                  FROM Program_Control_Panel_Options
                 WHERE Program_Control_Panel_Options.EZ_Button_Rate_ID = EZ_Button_Rate_Setting.EZ_Button_Rate_ID
                   AND Program_Control_Panel_Options.IsDominant = 1
                   AND Program_Control_Panel_Options.Deleted = 0) AS UsageCount
        FROM
            EZ_Button_Rate_Setting
        WHERE
            Deleted = 0
            AND EZ_Button_Rate_Title <> ''
            <cfif isdefined("arguments.EZButtonRateID") and arguments.EZButtonRateID NEQ "">
                AND EZ_Button_Rate_ID = #arguments.EZButtonRateID#
            </cfif>
        </cfquery>
        <cfreturn qGetEZButtonRates />

    </cffunction>


    <cffunction name="deleteEZButtonRate" access="public" returntype="void" output="no" hint="Delete EZ Button Rate Setting.">
        <cfargument name="EZ_Button_Rate_ID" required="true" default="">

        <cfquery name="local.query" datasource="#application.datasource#">
            UPDATE
                EZ_Button_Rate_Setting
            SET Deleted = 1
                ,Updated_By = <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#">
                ,Updated_Date = GetDate()
            WHERE
                EZ_Button_Rate_ID = <cfoutput>#arguments.EZ_Button_Rate_ID#</cfoutput>

            UPDATE
                Program_Control_Panel_Options
            SET
                EZ_Button_Rate_ID = NULL
            WHERE
                EZ_Button_Rate_ID = <cfoutput>#arguments.EZ_Button_Rate_ID#</cfoutput>
        </cfquery>
    </cffunction>


    <cffunction name="saveEZButtonRate" access="public" returntype="void" output="no" hint="Save config settings based on form parameters.">
        <cfquery name="local.query" datasource="#application.datasource#">
            UPDATE
                EZ_Button_Rate_Setting
            SET EZ_Button_Rate_Title = '#form.EZ_Button_Rate_Title#'
            <cfif FORM.pageAction EQ "edit">
                ,Updated_By = <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#">
                ,Updated_Date = GetDate()
            </cfif>
            WHERE EZ_Button_Rate_ID = #FORM.EZ_Button_Rate_ID#
        </cfquery>

        <cfset qryTemplateList = this.getEZTemplates()>
        <cfset EZButtonContractID = this.getEZButtonRates(EZButtonRateID=form.EZ_Button_Rate_ID)>


        <cfquery name="updTemplate" datasource="#application.datasource#">
            UPDATE Program_Control_Panel_Options
            SET EZ_Button_Rate_ID = NULL
            	,EZ_Contract_ID =  NULL
                , Updated_By = <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#">
                , Date_Updated = GetDate()
            WHERE EZ_Button_Rate_ID = #FORM.EZ_Button_Rate_ID#
         </cfquery>

        <cfloop query="qryTemplateList">
            <cfset chkboxIncludeChecked = 0 />
            <cfif (isDefined("FORM.chkBoxInclude_#qryTemplateList.First_Parent_ID#_"))>
                <cfset allowInSearch = 1 />
                <cfquery name="updProgram" datasource="#application.datasource#">
                    UPDATE Program_Control_Panel_Options
                    SET EZ_Button_Rate_ID = #FORM.EZ_Button_Rate_ID#
                    	,EZ_Contract_ID = #EZButtonContractID.EZ_Contract_ID#
                        ,Updated_By = <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#">
                        ,Date_Updated = GetDate()
                    WHERE First_Parent_ID = #qryTemplateList.First_Parent_ID#
                 </cfquery>
            </cfif>
        </cfloop>

    </cffunction>


    <cffunction name="duplicateExists" access="remote" returnFormat="json" output="no">
        <cfargument name="EZ_Button_Rate_ID" required="true" type="numeric">
        <cfargument name="EZ_Button_Rate_Title" required="true" type="string">

        <cfscript>
            local.result = {};
        </cfscript>

        <cftry>
            <cfquery name="local.query" datasource="#application.datasource#">
                SELECT 1
                      FROM EZ_Button_Rate_Setting
                 WHERE EZ_Button_Rate_ID    <> <cfqueryparam cfsqltype="cf_sql_integer"      value="#arguments.EZ_Button_Rate_ID#">
                   AND EZ_Button_Rate_Title  =  <cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.EZ_Button_Rate_Title#">
                   AND Deleted      =  0
            </cfquery>
            <cfcatch type="any">
                <!--- oops! error just occurred --->
                <cfset local.query = queryNew( 'foo' )>
            </cfcatch>
        </cftry>

        <cfset local.result.duplicateExists = (local.query.recordCount gt 0)>
        <cfreturn local.result>
    </cffunction>


  <cffunction name="getTemplates" access="public" returntype="query" output="no" hint="Returns template related claim rates settings.">
    <cfargument name="ProgramControl_Panel_Options_ID" required="false" default="">

    <cfquery name="local.query" datasource="#application.datasource#">
        SELECT DISTINCT
                Created_Type
               ,First_Parent_ID
               ,Program_Description
               ,Claim_Rates_Config_ID
                    <cfif val(arguments.ProgramControl_Panel_Options_ID) neq 0>
                ,b.Config_Name
                    </cfif>
          FROM Program_Control_Panel_Options a
        WHERE a.Deleted = 0
                    AND a.IsDominant = 1
                    AND EZ_Button_Rate_ID IS NULL
<!---                       <cfif val(arguments.ProgramControl_Panel_Options_ID) neq 0>
                        AND ProgramControl_Panel_Options_ID = <cfoutput>#arguments.ProgramControl_Panel_Options_ID#</cfoutput>
                    </cfif>
 --->              ORDER BY a.created_type
    </cfquery>
    <cfreturn local.query.qGetTemplates>
  </cffunction>


    <cffunction name="copyEZButtonRate" access="public" returntype="any" output="no" hint="Copy the EZ Button Rate Settings">
        <cfargument name="copiedEZButtonRateID" required="true" default="">

        <cfset local.copiedEzButtonRateSetting = this.getEZButtonRates( copiedEZButtonRateID ) />
        <cfquery name="local.copySetting" datasource="#application.datasource#">
			INSERT INTO [EZ_Button_Rate_Setting](EZ_Button_Rate_Title, Created_Date, Created_By )
            VALUES (
            				<cfqueryparam cfsqltype="cf_sql_varchar" value="Copy of #local.copiedEzButtonRateSetting.EZ_Button_Rate_Title#">,
				  			getDate(),
		  		  			<cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#">
						)

		  	SELECT SCOPE_IDENTITY() AS EZ_Button_Rate_ID
        </cfquery>
        <cfset local.NewEZButtonRateID = local.copySetting.EZ_Button_Rate_ID />
        <cfinclude template="/common_files/contracts/contract_number_generator.cfm">

        <cfquery name="local.getContractMainDetails" datasource="#application.datasource#">
		SET NOCOUNT ON
		SELECT ProgramType_ID,Responsible_User_ID
		FROM Contract_main
                WHERE contract_Main_ID = <cfqueryparam value='#local.copiedEzButtonRateSetting.EZ_Contract_ID#'>
        </cfquery>

        <CFSTOREDPROC PROCEDURE="USP_Copy_Program" datasource="#application.datasource#">
            <CFPROCPARAM TYPE="In"  CFSQLTYPE="CF_SQL_INTEGER"  DBVARNAME="@Program_ID_To_Replicate"        VALUE="#local.copiedEzButtonRateSetting.EZ_Contract_ID#">
            <CFPROCPARAM TYPE="In"  CFSQLTYPE="CF_SQL_VARCHAR"  DBVARNAME="@New_Contract_Number"            VALUE="TMP_#generator_contract_number#">
            <CFPROCPARAM TYPE="In"  CFSQLTYPE="CF_SQL_BIT"      DBVARNAME="@IsRevisionOfExistingContract"   VALUE="0">
            <CFPROCPARAM TYPE="In"  CFSQLTYPE="CF_SQL_BIT"      DBVARNAME="@ISROLLOVER"                     VALUE="0">
            <CFPROCPARAM TYPE="In"  CFSQLTYPE="CF_SQL_BIT"      DBVARNAME="@ForceFreightOnAutoCopy"         VALUE="0">
            <CFPROCPARAM TYPE="In"  CFSQLTYPE="CF_SQL_INTEGER"  DBVARNAME="@User_Position_ID"               VALUE="0" null="true">
            <CFPROCPARAM TYPE="In"  CFSQLTYPE="CF_SQL_VARCHAR"  DBVARNAME="@Responsible_User_ID"            VALUE="#local.getContractMainDetails.Responsible_User_ID#" null="true">
            <CFPROCPARAM TYPE="In"  CFSQLTYPE="CF_SQL_VARCHAR"  DBVARNAME="@Current_User_ID"                VALUE="#request.AccessStructure.User_ID#">
            <CFPROCPARAM TYPE="Out" CFSQLTYPE="CF_SQL_INTEGER"  DBVARNAME="@Contract_Main_ID"               VARIABLE="Renewed_Program_ID">
            <CFPROCPARAM TYPE="In"  CFSQLTYPE="CF_SQL_BIT"      DBVARNAME="@Is_Mass_Copy"                   VALUE="0">
            <CFPROCPARAM TYPE="Out" CFSQLTYPE="CF_SQL_INTEGER"  DBVARNAME="@Is_Group_Deal"                  VARIABLE="Is_Group_Deal">
            <CFPROCPARAM TYPE="In"  CFSQLTYPE="CF_SQL_BIT"      DBVARNAME="@From_EZ_Template"               VALUE="0">
            <CFPROCPARAM TYPE="In"  CFSQLTYPE="CF_SQL_BIT"      DBVARNAME="@Is_AutoRenew"                   VALUE="0">
        </CFSTOREDPROC>

        <cfquery name="local.qGetNewProgram" datasource="#application.datasource#">
            SELECT  Contract_Number, ProgramType_ID, Fiscal_Year
            FROM        Contract_Main
            WHERE   Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Renewed_Program_ID#">
        </cfquery>

        <cfquery name="local.updEzButtonRateSetting" datasource="#application.datasource#">
            // SELECT * FROM Contract_Main where contract_number = 'TMP_#generator_contract_number#'
            // SELECT @EZContractID = SCOPE_IDENTITY()
            UPDATE [EZ_Button_Rate_Setting] SET EZ_Contract_Id = <cfqueryparam value=#Renewed_Program_ID#>  WHERE EZ_Button_Rate_ID = <cfqueryparam value=#local.NewEZButtonRateID#>
        </cfquery>

        <cfreturn local.NewEZButtonRateID />
    </cffunction>


  <cffunction name="getEZTemplates" access="public" returntype="query" output="no" hint="Returns template related claim rates settings.">
    <cfargument name="pageAction" required = "false" default="">
    <cfargument name="EZ_Button_Rate_ID" required="false" default="">

        <cfquery name="qryGetEZTemplates" datasource="#application.datasource#">
            SELECT   DISTINCT PCPO.*
            FROM           Program_Control_Panel_Options PCPO
            WHERE PCPO.Deleted = 0
            AND PCPO.Active = 1
            AND PCPO.IsDominant = 1
            AND PCPO.EZButton_On = 1
            AND PCPO.programcontrol_panel_options_id
                NOT IN
                (       SELECT  DISTINCT Template_ID
                        FROM Profile_Forbidden_Template
                        WHERE   Deleted = 0
                        AND Forbid_Type = 1
                        AND     Forbid_Access_Type = 1
                        AND profile_id = 6
                )
            <cfif (isDefined("arguments.EZ_Button_Rate_ID") AND arguments.EZ_Button_Rate_ID NEQ "")>
                AND
                PCPO.EZ_Button_Rate_ID = #arguments.EZ_Button_Rate_ID#
            </cfif>
            <cfif (isDefined("arguments.pageAction") AND arguments.pageAction EQ "create")>
                AND PCPO.EZ_Button_Rate_ID IS NULL
            </cfif>
			order by PCPO.created_Type asc
        </cfquery>
    <cfreturn qryGetEZTemplates>
  </cffunction>



</cfcomponent>