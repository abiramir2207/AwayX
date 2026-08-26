<cfcomponent hint="Program Manager" extends="mvc.Models.SettingsService">

    <cfscript>
        objTemplateManager          = CreateObject("component","components.programs.template.TemplateManager");
        objComponentManager         = CreateObject("component","mvc.Models.Program.Component.ComponentManager");
        objProgram                  = CreateObject("component","components.programs.Program");
        objProgramTemplateManager   = CreateObject("component","components.programs.Display_Program.viewprogramtemplateManager");
        objProgramManager           = CreateObject("component", "components.programs.ProgramManager");
        businessSegManager          = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager");
    </cfscript>

    <cffunction name="init" output="false" returntype="mvc.Models.Program.ProgramManager">
        <cfreturn this />
    </cffunction>

    <cffunction name="getTemplateMultiPrdAttrGroups" returntype="boolean">
        <cfreturn application.appSettingsGet.getTemplateMultipleProductAttrGroups()>
    </cffunction>

    <!---XXXX  GET PROGRAM QUERY WITH PERMISSIONS FOR INITIAL LOAD XXXXXXXXXXX
    This function is used by Flex program search.
    --->
    <cffunction name="getPrograms" output="true" returntype="query">
        <cfargument name="user_id" type="string" required="true" />
        <cfargument name="profiles_Id" type="string" required="true" />
        <cfargument name="startDate" type="string" required="false" />
        <cfargument name="endDate" type="string" required="false" />
        <cfargument name="showCatalog" type="Boolean" required="true" />
        <cfargument name="Creating_User_Position" type="numeric" required="false" default="0" />
        <cfargument name="Include_work_in_progress_below_me" type="numeric" required="false" default="0" />

        <cfset local.prgSettings = getProgramLevelSettings() />

        <cfset var sStartDate = DateFormat(arguments.startDate,'mm/dd/yyyy')>
        <cfset var sEndDate = DateFormat(arguments.endDate,'mm/dd/yyyy')>

        <cfset var appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
        <cfset var forbidType = appSettings.getForbidAllowProfilesInTemplates() />

        <cfset local.showProgramTradeSpendORVolume = 0>
        <cfset local.showVersionLevelTradeSpend = 0>
        <cfset local.showVersionLevelVolume = 0>
        <cfset local.showPayment = 0>
        <cfif appSettings.getProgramSearchDollarsAndVolume()>
            <cfif
                (
                <!--- If "Display Trade $" setting is ON --->
                (local.prgSettings.Display_Trade_Dollars eq 1)
                OR
                <!--- If "Display Volume" setting is ON --->
                (local.prgSettings.Display_Volume eq 1)
                OR
                <!--- If "Display Payment $" setting is ON --->
                (local.prgSettings.Display_Payment_Dollars eq 1)
                )
                >
                    <cfset local.showProgramTradeSpendORVolume = 1>
            </cfif>
            <!--- TRADE SPEND DOLLARS --->
            <!--- If "Display Trade $" setting is ON --->
            <cfif local.prgSettings.Display_Trade_Dollars eq 1>
                <cfif local.prgSettings.Display_Trade_Dollars_Type eq 1>
                    <!--- "Version value" option is selected. If "local.showVersionLevelTradeSpend" is 0,
                    then "Total program value" option is selected
                    --->
                    <cfset local.showVersionLevelTradeSpend = 1>
                </cfif>
            </cfif>
            <!--- VOLUME --->
            <!--- If "Display Volume" setting is ON --->
            <cfif local.prgSettings.Display_Volume eq 1>
                <cfif local.prgSettings.Display_Volume_Type eq 1>
                    <!--- "Version value" option is selected. If "local.showVersionLevelTradeSpend" is 0,
                    then "Total program value" option is selected
                    --->
                    <cfset local.showVersionLevelVolume = 1>
                </cfif>
            </cfif>
            <!--- PAYMENT DOLLARS (payment dollars only have a "Total program value". There is no "version value". --->
            <!--- If "Display Payment $" setting is ON --->
            <cfif local.prgSettings.Display_Payment_Dollars eq 1>
                <cfset local.showPayment = 1>
            </cfif>
        </cfif>

        <cfset var stSearch = StructNew()>

        <cfif Not isDefined("request.AccessStructure")>
            <cfset request.AccessStructure = structNew() />
            <cfset request.AccessStructure.user_id = arguments.user_id />
            <cfset request.AccessStructure.profiles_id = arguments.profiles_id />
        </cfif>
        <CFINCLUDE TEMPLATE="/scorecard/access_permissions.cfm">

        <cfset stSearch.User_Positions_ID = UserPositionList>
        <cfset stSearch.Profiles_ID = arguments.profiles_id>

        <cfset stSearch.GP_Position_List_From_My_Position_Down = GP_Position_List_From_My_Position_Down>
        <cfset stSearch.GP_Position_List_From_My_Position_Down_SC = GP_Position_List_From_My_Position_Down_SC>

        <cfset stSearch.ProgramsWithDistUnderMe = "0">
        <cfset stSearch.ProgramsWithBrokerUnderMe = "0">
        <cfset stSearch.ProgramsWithDistUnderMe_SC = "0">
        <cfset stSearch.ProgramsWithBrokerUnderMe_SC = "0">
        <cfif NOT Get_Profile_Settings.Program_Scorecard_Restrict_Created_By>
            <cfset stSearch.ProgramsWithDistUnderMe = ProgramsWithDistUnderMe>
            <cfset stSearch.ProgramsWithBrokerUnderMe = ProgramsWithBrokerUnderMe>
            <cfset stSearch.ProgramsWithDistUnderMe_SC = ProgramsWithDistUnderMe_SC>
            <cfset stSearch.ProgramsWithBrokerUnderMe_SC = ProgramsWithBrokerUnderMe_SC>
        </cfif>

        <cfif Get_Profile_Settings.Program_Scorecard_Restrict_Created_By>
            <cfset stSearch.programScorecardRestrictCreatedByUserId = request.AccessStructure.user_id>
        </cfif>

        <cfset stSearch.Read_Only_Catalog_Access = Get_Profile_Settings.Read_Only_Catalog_Access>
        <cfset stSearch.See_Awarded_In_Catalog = Get_Profile_Settings.See_Awarded_In_Catalog>

        <cfset moreAccessPermissionRestriction = getProgramAccessPermissionCode()>
        <cfset populateProgramSearchAccessPermissionTables(stSearch.User_Positions_ID,HQUser,arguments.showCatalog,stSearch.Read_Only_Catalog_Access)>
        <!--- Delete the temp tables in a separate query. While testing code, there are no issues that way, as
        the prevents the "table already exists" error.
        --->
        <cfquery name="delTbl" datasource="#application.datasource#">
            IF OBJECT_ID('tempdb..##tmp_Effective_Dates') IS NOT NULL
            DROP TABLE ##tmp_Effective_Dates

            IF OBJECT_ID('tempdb..##tmpPgmSrch_Program_Operators') IS NOT NULL
            DROP TABLE ##tmpPgmSrch_Program_Operators
        </cfquery>

        <cfquery name="getClaimMechanics" datasource="#application.datasource#">
            IF OBJECT_ID('tempdb..##tmp_ClaimMechanics') IS NOT NULL
            DROP TABLE ##tmp_ClaimMechanics

            SELECT PRC.Claim_Mechanics, CM.Contract_Main_ID
            INTO ##tmp_ClaimMechanics
            FROM Contract_main CM
            INNER JOIN Program_Rebates_Component PRC
            ON PRC.Program_ID = CM.Contract_Main_ID
            INNER JOIN Payment_Type PT
            ON PT.Payment_Type_ID = PRC.Claim_Mechanics
            AND (Is_Auto_Pay = 0 AND Restrict_From_Billback = 0 AND Off_Invoice = 0)
            WHERE CM.Deleted = 0
            AND CM.IsExclusionRevision = 0
            AND CM.Contract_Status_Type_IDX > 2
            AND CM.Flagged_As_Purged = 0
            AND(CM.Force_Expiration_Flag = 0 OR CM.Contract_Status_Type_IDX = 7)
            AND PRC.Deleted = 0
            <cfif arguments.startDate eq "" and arguments.endDate eq "">
                <cfif IsNumeric(appSettings.getExpiredRecentlyDays())>
                    AND  CM.Contract_End_Date >= DateAdd(d,- #appSettings.getExpiredRecentlyDays()#,getDate())
                </cfif>
            <cfelse>
                AND CM.Contract_Start_Date <= '#DateFormat(sEndDate,"mm/dd/yyyy")#'
                AND CM.Contract_End_Date >= '#DateFormat(sStartDate,"mm/dd/yyyy")#'
            </cfif>

            <!---UNION

            SELECT PFC.Claim_Mechanics, CM.Contract_Main_ID
            FROM Contract_main CM
            INNER JOIN Program_Fixed_Component PFC
            ON PFC.Program_ID = CM.Contract_Main_ID
            INNER JOIN Payment_Type PT
            ON PT.Payment_Type_ID = PFC.Claim_Mechanics
            AND (Is_Auto_Pay = 0 AND Restrict_From_Billback = 0 AND Off_Invoice = 0)
            WHERE CM.Deleted = 0
            AND CM.IsExclusionRevision = 0
            AND CM.Contract_Status_Type_IDX > 2
            AND CM.Flagged_As_Purged = 0
            AND(CM.Force_Expiration_Flag = 0 OR CM.Contract_Status_Type_IDX = 7)
            <cfif arguments.startDate eq "" and arguments.endDate eq "">
                <cfif IsNumeric(appSettings.getExpiredRecentlyDays())>
                    AND  CM.Contract_End_Date >= DateAdd(d,- #appSettings.getExpiredRecentlyDays()#,getDate())
                </cfif>
            <cfelse>
                AND CM.Contract_Start_Date <= '#DateFormat(sEndDate,"mm/dd/yyyy")#'
                AND CM.Contract_End_Date >= '#DateFormat(sStartDate,"mm/dd/yyyy")#'
            </cfif>--->

            UNION

            SELECT PGC.Claim_Mechanics , CM.Contract_Main_ID
            FROM Contract_main CM
            INNER JOIN Program_Growth_Components PGC
            ON PGC.Program_ID = CM.Contract_Main_ID
            INNER JOIN Payment_Type PT
            ON PT.Payment_Type_ID = PGC.Claim_Mechanics
            AND (Is_Auto_Pay = 0 AND Restrict_From_Billback = 0 AND Off_Invoice = 0)
            WHERE CM.Deleted = 0
            AND CM.IsExclusionRevision = 0
            AND CM.Contract_Status_Type_IDX > 2
            AND CM.Flagged_As_Purged = 0
            AND(CM.Force_Expiration_Flag = 0 OR CM.Contract_Status_Type_IDX = 7)
            AND PGC.Deleted = 0
            <cfif arguments.startDate eq "" and arguments.endDate eq "">
                <cfif IsNumeric(appSettings.getExpiredRecentlyDays())>
                    AND  CM.Contract_End_Date >= DateAdd(d,- #appSettings.getExpiredRecentlyDays()#,getDate())
                </cfif>
            <cfelse>
                AND CM.Contract_Start_Date <= '#DateFormat(sEndDate,"mm/dd/yyyy")#'
                AND CM.Contract_End_Date >= '#DateFormat(sStartDate,"mm/dd/yyyy")#'
            </cfif>

            UNION

            SELECT PLC.Claim_Mechanics, CM.Contract_Main_ID
            FROM Contract_main CM
            INNER JOIN Program_Lump_Sums PLC
            ON PLC.Program_ID = CM.Contract_Main_ID
            INNER JOIN Payment_Type PT
            ON PT.Payment_Type_ID = PLC.Claim_Mechanics
            AND (Is_Auto_Pay = 0 AND Restrict_From_Billback = 0 AND Off_Invoice = 0)
            WHERE CM.Deleted = 0
            AND CM.IsExclusionRevision = 0
            AND CM.Contract_Status_Type_IDX > 2
            AND CM.Flagged_As_Purged = 0
            AND(CM.Force_Expiration_Flag = 0 OR CM.Contract_Status_Type_IDX = 7)
            AND PLC.Deleted = 0
            <cfif arguments.startDate eq "" and arguments.endDate eq "">
                <cfif IsNumeric(appSettings.getExpiredRecentlyDays())>
                    AND  CM.Contract_End_Date >= DateAdd(d,- #appSettings.getExpiredRecentlyDays()#,getDate())
                </cfif>
            <cfelse>
                AND CM.Contract_Start_Date <= '#DateFormat(sEndDate,"mm/dd/yyyy")#'
                AND CM.Contract_End_Date >= '#DateFormat(sStartDate,"mm/dd/yyyy")#'
            </cfif>
        </cfquery>
        <!---<cftransaction isolation="READ_UNCOMMITTED">--->
        <!--- changes made by gayathri to the query to reflect the Request for approval programs that are agreed by others but couldn't approve..this is for mainly lambweston, but still the query results don't change for other customers..please don't get confused. Approved status was used for substatus of RFA (pending approval) since we don't have that feild in the DB--->
        <cfquery name="local.qGetProgramInfo" datasource="#application.datasource#">
            <!------ Get positions below ----->
            SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

            Create  table ##tmp_Effective_Dates
            (
              Contract_Number Nvarchar(255) not null PRIMARY KEY CLUSTERED,
              Effective_Start_Date datetime,
              Effective_End_Date datetime
            )

            <!--- Dev Note:38050 (Milan) - Get the minimum "Effective_Start_Date" and maximum "Effective_End_Date" per program (contract_number).
            Note: We need this logic for the following reason:
            When we do a price increase for a client, the affected programs get revised and the new rates are valid for the
            new revision with the start and/or end date of the revision changing based ON the date when the price change needs
            to be effective. By doing this, we only show the start and end dates for the new revision ON the program.
            By looking at the dates, the users do not know what is the complete date span of the program. The effective dates
            have the actual date span, provided we get the minimum effective start date and maximum effective end date. This
            way the users will see the complete start date and end date for a program and will not be revision dependant.
            ON the program summary, we show show both - version dates and delivery dates.
            --->
            <cfif appSettings.getProgram_search_dates()>
            INSERT INTO ##tmp_Effective_Dates WITH (TABLOCK) (Contract_Number,Effective_Start_Date,Effective_End_Date)
            SELECT Contract_Main.Contract_Number, MIN(Contract_Main.Effective_Start_Date) As Effective_Start_Date,
            MAX(Contract_Main.Effective_End_Date) As Effective_End_Date
            FROM Contract_Main
            WHERE Contract_Main.Approved = 1
            AND Contract_Main.effective_start_date IS NOT NULL
            AND Contract_Main.effective_end_Date IS NOT NULL
            GROUP BY Contract_Main.Contract_Number
			ORDER BY Contract_Main.Contract_Number
            </cfif>

            <cfif local.showProgramTradeSpendORVolume>
                <cfset getVolumeAndTradeSpendAndPaymentDollars()>
            </cfif>
            <!--- Dev Note(83363) -  Add Operator ID and Operator Name columns --->

			IF OBJECT_ID('tempdb..##tmp_Contract_Operator_ID') IS NOT NULL
                DROP TABLE  ##tmp_Contract_Operator_ID

            SELECT
				cp1.contract_main_id,
                MIN(cp1.BSA_Operator_ID) AS BSA_Operator_ID
			INTO ##tmp_Contract_Operator_ID
            FROM Contract_Operators cp1
            WHERE cp1.deleted = 0
			GROUP BY cp1.contract_main_id

            CREATE TABLE ##tmpPgmSrch_Program_Operators
            (
              Contract_Main_ID int NOT NULL PRIMARY KEY CLUSTERED,
              Operator_ID varchar(100) NULL,
              Operator_Name varchar(200) NOT NULL
            )
            <cfif local.prgSettings.Display_Operator_Info eq 1>
            INSERT INTO ##tmpPgmSrch_Program_Operators WITH (TABLOCK) (Contract_Main_ID,Operator_ID,Operator_Name)
            SELECT cp1.contract_main_id,
            <!--- Below logic is the same logic which is on the "getOperatorLegacyIDOn" function on "businessSegmentManager.cfc" --->
            CASE
               WHEN LTRIM(RTRIM(bsaop.Legacy_ID)) <> '' AND
               ((#application.returned_customer_setting.operator_legacy_id_on# = 1)
               OR
               (#businessSegManager.isEnabled()# = 1 AND len(cm.Business_Segment_ID) > 0 AND bsg.Operator_BS_Filter = 1))
            THEN
               bsaop.Legacy_ID
            ELSE
               CAST(bsaop.bsa_Operator_ID As varchar(100))
            END
            ,bsaop.Operator_Name
            <!--- FROM Contract_Operators cp1 --->
			FROM ##tmp_Contract_Operator_ID cp1
            INNER JOIN BSA_Operator bsaop
            ON bsaop.BSA_Operator_ID = cp1.BSA_Operator_ID
            <!--- INNER JOIN Contract_Main cm
            ON cp1.Contract_Main_ID = cm.Contract_Main_ID
            LEFT JOIN Business_Segment bsg
            ON bsg.Business_Segment_ID = cm.Business_Segment_ID
			--->
            WHERE cp1.deleted = 0
            <!--- AND cp1.bsa_Operator_ID IN
             (
               SELECT TOP 1 cp2.bsa_Operator_ID
               FROM Contract_Operators cp2
               WHERE cp2.deleted = 0
               AND cp1.contract_main_id = cp2. contract_main_id
             )
			 --->
            </cfif>
            <!---
            The logic for calculating trade spend $, committed $ and volume (above) is follows:
                - "Committed $" and "Volume" above can be at a "version" or "Total program value" level. It depends ON the setting, which is
                  ON the "program setting" page.Payment $ is always at a "Total program value" level.
                - When "budget functionality" is ON, AND the program template is associated to a budget,
                  then "trade spend" and "payment dollars" values come from the budget.
                - When program template is not associated to a budget, then "trade spend" and "payment dollar" values
                  come from the program. Volume is always from the program.
                - When the "trade spend" and "payment dollars" values from the budget are NULL for program(s)
                  (i.e. program template is not associated to a budget),then for those programs,
                  the values come from the program itself (assumption is that the value will be null, when the program's template is not associated to a budget).

                Note:If you change the select clause logic for trade spend $ or committed $ or volume, then make the comment changes below too.
                 In the select clauses (below) to retrieve data for these columns, there is additional logic:
                   a) Total program value:
                    a1)##TotalPrgTradeSpendAndVolume.Estimated_Program_Spend is used to get the trade spend $ (program_spend) as the logic for whether it comes from
                    budget or program is in the query above (##TotalPrgTradeSpendAndVolume table)
                    a2) ##TotalPrgTradeSpendAndVolume.Contract_Quantity is the volume.
                    a3) ISNULL(##TotalPrgTradeSpendAndVolume.actual_dollar,Contract_Main_Aux_Data.Paid_Amount): When the budget values are NULL for payment $
                    (when the program's template is not associated to a budget), then get it from the "paid_Amount" column. "paid_Amount" is the amount paid
                    for the billback.
                   b)  Version value:
                    b1) IsNull(##PrgVersionlevelTradeSpendAndVolume.Estimated_Committed_Dollar,Contract_Main_Aux_Data.Program_Spend): When the budget values are NULL
                    for Trade $ (when the program's template is not associated to a budget), then get it from the program - "program_spend" column.
                    b2) Contract_Main.Contract_Quantity is the volume.
                    b3) payment $ is never at a version level.
            --->
            <!---
            The fields are in this order:
            contract_main_id,contract_reference_number,contract_title,status_id,revision_version,prefixed_contract_number,
            searchable_contract_number,contract_number,contract_start_date,contract_end_date,status_abbreviation,
            contract_status_type_desc,rsp_user,creator_user,rfa_user,approver_user,owner_position,rfa_position,
            approver_position,created_type_deleted,created_type,include_claim_rates_report,include_pricing_report,
            payment_history,approved_status,is_catalog,is_autorenew,autorenew_pairs,doc_attached,revision_in_process,rollover,
            cancelled,rfa_age,program_post_approval_status_id,disagreed,expiring_no_revisions,program_trade_spend,
            program_volume,program_payment,Best_Plan_Program,program_released,acknowledged,not_acknowledged,release_eligible,
            claim_mechanics,legacy_id,creation_method,operator_id,operator_name
            --->
            SELECT  <!--- distinct --->
					cast(Contract_Main.contract_main_id as varchar(10)) + ','
                    <!--- Remove comma --->
                    + cast(Replace(ltrim(rtrim(isnull(nullif(Contract_Main.contract_reference_number,''),0))),',','') as varchar(30)) + ','
                    <!--- Remove comma, new line, tab --->
                    + CAST(ltrim(rtrim(Replace(Replace(Replace(Replace(Contract_Main.contract_title,',',''), CHAR(10), ''), CHAR(13), ''), CHAR(9), ''))) as varchar(4000))+ ','
                    + cast(Contract_Main.Contract_Status_Type_IDX as varchar(2)) + ','
                    + CASE
									WHEN LEN(Contract_Main.revision_version) = 4 THEN RIGHT('000' + CAST(Contract_Main.revision_version AS VARCHAR(10)), 4)
									WHEN LEN(Contract_Main.revision_version) = 5 THEN RIGHT('000' + CAST(Contract_Main.revision_version AS VARCHAR(10)), 5)
									ELSE RIGHT('000' + CAST(Contract_Main.revision_version AS VARCHAR(10)), 3)
								END + ','
                    + cast(Contract_Main.Contract_Number as varchar(30)) + ','
                    <!--- searchable_contract_number --->
                     + cast(SubString(Contract_Main.Contract_Number,charIndex('-',Contract_Main.Contract_Number)+1,len(Contract_Main.Contract_Number)) as varchar(30)) + ','
                    <!--- contract_number --->
                    + cast(Replace(Contract_Main.Contract_Number, '000-', '') + (CASE WHEN Contract_Main.Contract_Status_Type_IDX > 2 THEN '-' + CASE
									WHEN LEN(Contract_Main.revision_version) = 4 THEN RIGHT('000' + CAST(Contract_Main.revision_version AS VARCHAR(10)), 4)
									WHEN LEN(Contract_Main.revision_version) = 5 THEN RIGHT('000' + CAST(Contract_Main.revision_version AS VARCHAR(10)), 5)
									ELSE RIGHT('000' + CAST(Contract_Main.revision_version AS VARCHAR(10)), 3)
								END ELSE '' END) as varchar(30)) + ','
                    <!--- If Effective start date exists, use it, else use the contract start date.
                    Note: "##tmp_Effective_Dates" is populated only when "appSettings.getProgram_search_dates" is set to 1. Even then, "##tmp_Effective_Dates"
                    will not be populated for all programs.
                    --->
                    + cast(
                        IsNull(convert(char(10),##tmp_Effective_Dates.Effective_Start_Date,101),convert(char(10),Contract_Main.Contract_Start_Date,101))
                    as varchar(10)) + ','
                    <!--- If Effective end date exists, use it, else use the contract end date
                    Note: "##tmp_Effective_Dates" is populated only when "appSettings.getProgram_search_dates" is set to 1. Even then, "##tmp_Effective_Dates"
                    will not be populated for all programs.
                    --->
                    + cast(
                        IsNull(convert(char(10),##tmp_Effective_Dates.Effective_End_Date,101),convert(char(10),Contract_Main.Contract_End_Date,101))
                    as varchar(10)) + ','
                    <!--- status_abbreviation --->
                    + cast(ltrim(rtrim(Contract_Status_Types.Status_Abbreviation)) as varchar(10)) + ','
                    <!---  contract_status_type_desc --->
                    + cast(ltrim(rtrim(Contract_Status_Types.contract_status_type_desc)) as varchar(35)) + ','
                    +
                    CASE
                    <!---  If the RSP is deleted --->
                    WHEN len(ltrim(rtrim(ISNULL(responsibleSalesPerson.Name_First,'')))) = 0
                        THEN cast('Vacant' as varchar(6))
                    ELSE
                        cast(Replace(ISNULL(responsibleSalesPerson.Name_First + ' ' + responsibleSalesPerson.Name_Last, ''),',','') as varchar(50))
                    END
                    + ','
                    <!--- User --->
                    + cast(ISNULL(Replace(ltrim(rtrim(CreatorUser.Sales_Person_ID)),',',''),'') as varchar(50)) + ','
                    <!--- For programs which do not have a RFA and/or approved user, we need to use IsNull,else the program
                    will not be a part of the resultset. --->
                    + cast(ISNULL(Replace(ltrim(rtrim(RFAUser.Sales_Person_ID)),',',''),'') as varchar(50)) + ','
                    + cast(ISNULL(Replace(ltrim(rtrim(ApproverUser.Sales_Person_ID)),',',''),'') as varchar(50)) + ','
                    <!--- Earlier we had "position_label",instead of "User_Positions_ID" --->
                    + cast(Replace(ltrim(rtrim(Owner_Position.User_Positions_ID)),',','') as varchar(50)) + ','
                    <!--- For programs which do not have a RFA and/or approved user, we need to use IsNull,else the program
                    will not be a part of the resulset. --->
                    + cast(ISNULL(Replace(ltrim(rtrim(RFA_Position.User_Positions_ID)),',',''),'') as varchar(50)) + ','
                    + cast(ISNULL(Replace(ltrim(rtrim(Approver_Position.User_Positions_ID)),',',''),'') as varchar(50)) + ','
                    <!--- This is used for "created_type" --->
                    + cast(ltrim(rtrim(Program_Control_Panel_Options.Created_Type)) as varchar(255))  + ','
                    + cast(Contract_Main_Aux_Data.Include_Claim_Rates_Report as varchar(1)) + ','
                    + cast(Contract_Main_Aux_Data.Include_Pricing_Report as varchar(1)) + ','
                    <cfif appSettings.getpaymenthistoryon()>
                    + cast(IsNull(Contract_Main_Aux_Data.Payment_History,'') as varchar(1)) + ','
                    <cfelse>
                    + cast('' as varchar(1)) + ','
                    </cfif>
                    + case when Contract_Main.Contract_Status_Type_IDX in (4, 5, 6, 10) then cast(1 as varchar(1)) else cast(0 as varchar(1)) end + ','
                    <cfif arguments.showCatalog eq 1>
                        +
                        <cfif stSearch.Read_Only_Catalog_Access EQ 0>
                        cast(0 as varchar(1))
                        <cfelse>
                        cast(1 as varchar(1))
                        </cfif>
                    <cfelse>
                    + cast(0 as varchar(1))
                    </cfif> + ','
                    + cast(Contract_Main.is_autorenew as varchar(1)) + ','
                    <!--- What has auto renewed and the parent of the auto-renewed program. --->
                    + CASE WHEN (Contract_Main.is_autorenew = 1 OR Program_Auto_Renew.Renewed = 1)
                    THEN cast(1 as varchar(1))  ELSE cast(0 as varchar(1)) END
                    + ','
                    +
                    CASE
                         WHEN
                    LEN((SELECT top 1 Program_ID
                        FROM Contract_Attachments
                        Where Contract_Attachments.Program_ID = Contract_Main.Contract_Main_ID AND Contract_Attachments.Deleted = 0
                        )) > 0
                    THEN cast(1 as varchar(1))
                    ELSE cast(0 as varchar(1))
                    END
                    + ','
                    +
                    <!--- It has a revision --->
                    CASE
                          WHEN
                    LEN((Contract_Main_1.Contract_Main_ID
                        )) > 0
                    OR
                    <!--- It's a revision --->
                    (
                    Contract_Main.Revision_Of_Contract_Main_ID != '' AND Contract_Main.Revision_Of_Contract_Main_ID IS NOT NULL
                    AND Contract_Main.Approved = 0 AND Contract_Main.Deleted = 0
                    )
                    THEN cast(1 as varchar(1))
                    ELSE cast(0 as varchar(1))
                    END
                    + ','
                    +
                    CASE WHEN
                    (
                    LEN(LTRIM(Contract_Main.Rollover_From_Contract_Main_ID)) > 0
                    )
                    THEN cast(1 As varchar(1))
                    ELSE
                    cast(0 As varchar(1))
                    END + ','
                    +
                    CASE
                         WHEN Contract_Main.Manual_Cancel = 1
                            THEN cast(1 As varchar(1))
                         ELSE
                            cast(0 As varchar(1))
                    END + ','
                    +
                    CASE
                         WHEN
                            Contract_Main.Contract_Status_Type_IDX = 2
                        THEN
                            cast(DATEDIFF(d,Contract_Main.Broker_Approved_Date,GETDATE()) As varchar(4))
                        ELSE

                        cast(''  As varchar(4))
                    END + ','
                    <cfif appSettings.getPgmPostApprovalStatus() EQ 1>
                    <!--- Get "Pending ERP Research" and "Pending ERP Entry", only when a program is not cancelled --->
                    +
                    CASE
                         WHEN
                    LEN(IsNull(Contract_Main.program_post_approval_status_id,'')) > 0
                    AND IsNull(Contract_Main.Manual_Cancel,0) = 0
                    THEN
                        cast(IsNull(Contract_Main.program_post_approval_status_id,'') As varchar(1))
                    ELSE
                    cast('' as varchar(1))
                    END
                    <cfelse>
                    + cast('' as varchar(1))
                    </cfif>+ ','
                    +
                    CASE WHEN
                        Len(Contract_Main.Disagreed_User_ID) > 0
                    THEN cast(1 As varchar(1))
                    ELSE
                        cast(0 As varchar(1))
                    END+ ','
                    +
                    <!--- Where the program is expiring and it's revision does not exist --->
                    CASE WHEN
                        Contract_Main.Contract_Status_Type_IDX = 6
                    AND  NOT EXISTS (
                          SELECT  1
                          FROM  Contract_Main Rev
                          WHERE Rev.Revision_of_Contract_Main_ID = Contract_Main.Contract_Main_ID
                          AND  Rev.Deleted = 0
                    )
                    THEN cast(1 As varchar(1))
                    ELSE
                        cast(0 As varchar(1))
                    END

                    <!--- TRADE SPEND: TOTAL PROGRAM VALUE --->
                    <cfif local.showProgramTradeSpendORVolume AND local.showVersionLevelTradeSpend eq 0>
                    + ','
                    + cast(ISNULL(Replace(ltrim(rtrim(##TotalPrgTradeSpendAndVolume.Estimated_Program_Spend)),',',''),'0') as varchar(30))

                    <!--- TRADE SPEND: VERSION VALUE --->
                    <cfelseif local.showVersionLevelTradeSpend>
                    + ','
                    + cast(ISNULL(Replace(ltrim(rtrim(IsNull(##PrgVersionlevelTradeSpendAndVolume.Estimated_Committed_Dollar,Contract_Main_Aux_Data.Program_Spend))),',',''),'0') as varchar(30))
                    <cfelse>
                    + ','
                    + cast('0' as varchar(1))
                    </cfif>

                    <!--- VOLUME: TOTAL PROGRAM VALUE --->
                    <cfif local.showProgramTradeSpendORVolume AND local.showVersionLevelVolume eq 0>
                    + ','
                    + cast(ISNULL(Replace(ltrim(rtrim(##TotalPrgTradeSpendAndVolume.Contract_Quantity)),',',''),'0') as varchar(30))

                    <!--- VOLUME: VERSION VALUE --->
                    <cfelseif local.showVersionLevelVolume>
                    + ','
                    + cast(ISNULL(Replace(ltrim(rtrim(Contract_Main.Contract_Quantity)),',',''),'0') as varchar(30))
                    <cfelse>
                    + ','
                    + cast('0' as varchar(1))
                    </cfif>

                    <!--- PAYMENT DOLLARS: TOTAL PROGRAM VALUE.
                    THERE IS NO VERSION VALUE. BILLBACK PAYMENT IS ALWAYS CALCULATED FOR ALL THE PROGRAM VERSIONS COMBINED.
                    EVERY VERSION OF THE PROGRAM IN THE Paid_Amount COLUMN OF THE Contract_Main_Aux_Data
                    TABLE HAS THE SAME AMOUNT, AS THE TOTAL AMOUNT OF ALL THE VERSIONS COMBINED IS UPDATED FOR
                    ALL THE VERSIONS.
                    --->
                    <cfif local.showPayment>
                    + ','
                    + cast(ISNULL(Replace(ltrim(rtrim(ISNULL(##TotalPrgTradeSpendAndVolume.actual_dollar,Contract_Main_Aux_Data.Paid_Amount))),',',''),'0') as varchar(25))
                    <cfelse>
                    + ','
                    + cast('0' as varchar(1))
                    </cfif>
                    + ','
                    + cast(ltrim(rtrim(Contract_Main.Best_Plan_Program)) as varchar(1))+ ','
                    +
                    <cfif appSettings.getReleaseSettlement()>
                    CASE WHEN Program_Control_Panel_Options.Release_Settlement = 1
                        THEN
                            CASE WHEN Contract_Main.Released = 0
                                THEN cast('0' as varchar(1))
                            ELSE
                                cast('1' as varchar(1))
                            END
                    ELSE
                        cast('' as varchar(1))
                    END
                    <cfelse>
                        cast('' as varchar(1))
                    </cfif>
                    <cfif appSettings.getProgramLockTypeID() neq 0>
                    + ','
                    + CASE WHEN
                        Contract_Main.Approved = 1 AND Contract_Main.sent_to_external_client = 1
                    THEN
                        cast('1' as varchar(1))
                    ELSE
                        cast('0' as varchar(1))
                    END
                    + ','
                    + CASE WHEN
                        Contract_Main.Approved = 1 AND Contract_Main.sending_to_external_client = 1 AND Contract_Main.sent_to_external_client = 0
                    THEN
                        cast('1' as varchar(1))
                    ELSE
                        cast('0' as varchar(1))
                    END
                    <cfelse>
                    + ','
                    + cast('0' as varchar(1))
                    + ','
                    + cast('0' as varchar(1))
                    </cfif>
                    <cfif appSettings.getReleaseSettlement() AND Get_Profile_Settings.Release_Settlement EQ 1>
                    + ','
                    + CASE WHEN
                        Program_Control_Panel_Options.Release_Settlement <> 0
                        AND
                        (
                            (#appSettings.get_Setting('Release_Settlement_Availability')# <> '1')
                            OR
                            (
                                Contract_Main.Sending_To_External_Client = 0 AND Contract_Main.Sent_To_External_Client = 1
                                AND len(Contract_Main.Contract_Reference_Number) > 0 AND len(Contract_Main.External_Client_Ack_Date) > 0
                            )
                        )
                         AND Contract_Main.Released = 0
                         AND
                         (
                            Contract_Main.Contract_Status_Type_IDX = 5
                            OR Contract_Main.Contract_Status_Type_IDX = 6
                            OR Contract_Main.Contract_Status_Type_IDX = 7
                         )
                        THEN
                            cast('1' as varchar(1))
                        ELSE
                            cast('0' as varchar(1))
                        END
                    <cfelse>
                        + ','
                        + cast('0' as varchar(1))
                    </cfif>
                    <cfif appSettings.get_Setting('Quick_Pay_in_Program_Search') eq '1'>
                        +','
                        +CASE WHEN
                            isnull(Claim.Claim_Mechanics,0) > 0
                        THEN
                            cast('1' as varchar(1))
                        ELSE
                            cast('0' as varchar(1))
                        END
                    <cfelse>
                        + ','
                        + cast('0' as varchar(1))
                    </cfif>
                    <cfif businessSegManager.isEnabled()>
                        +','
                        + cast(Business_Segment.Business_Unit_Desc as varchar(100))
                    <cfelse>
                        + ','
                        + cast('0' as varchar(1))
                    </cfif>
                    <cfif appSettings.getView_Legacy_ID() EQ 1>
                        +','
                        + cast(IsNull(ltrim(rtrim(Contract_Main.legacy_deal_id)),'') as varchar(100))
                    <cfelse>
                        +','
                        +  cast('' as varchar(1))
                    </cfif>
                        +','
                        + cast(Contract_Main.creation_method as varchar(1))
                        +','
                        + cast(IsNull(##tmpPgmSrch_Program_Operators.Operator_ID,'') as varchar(100))
                        +','
                        + cast(IsNull(##tmpPgmSrch_Program_Operators.Operator_Name,'') as varchar(100))

                        +','
                    <!--- I added a trailing comma at the end. This makes sure that the last column gets into flex correctly --->
                    As Prog_Details
            FROM    Contract_Main

            <cfif NOT(arguments.showCatalog eq 1 and stSearch.Read_Only_Catalog_Access EQ 1)>
            INNER JOIN ##Profile_Forbidden_Template
            ON Contract_Main.ProgramType_ID = ##Profile_Forbidden_Template.Template_ID
            </cfif>

            INNER JOIN Program_Control_Panel_Options
            ON  Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID

            INNER JOIN Contract_Main_Aux_Data
            ON  Contract_Main_Aux_Data.Contract_Main_ID = Contract_Main.Contract_Main_ID

            LEFT JOIN _Users responsibleSalesPerson
            ON  responsibleSalesPerson.User_ID = Contract_Main.Responsible_User_ID
            AND responsibleSalesPerson.deleted = 0

            LEFT JOIN _Users CreatorUser
                ON Contract_Main.Creator_ID = CreatorUser.User_ID

            LEFT JOIN _Users RFAUser
            ON Contract_Main.Broker_User_ID = RFAUser.User_ID

            LEFT JOIN _Users ApproverUser
                ON Contract_Main.Approved_By_User_ID = ApproverUser.User_ID

            LEFT JOIN User_Positions as Owner_Position ON Contract_Main.Creating_User_Position_ID = Owner_Position.User_Positions_ID

            INNER JOIN Contract_Status_Types
            ON  Contract_Status_Types.Contract_Status_Type_ID =  Contract_Main.Contract_Status_Type_IDX

            LEFT JOIN User_Position_Holders As RFA_Position_Holders ON Contract_Main.Broker_User_ID = RFA_Position_Holders.User_ID
            and RFA_Position_Holders.deleted = 0
            AND RFA_Position_Holders.User_Position_Type = 'P'

            LEFT JOIN User_Positions as RFA_Position ON RFA_Position.User_Positions_ID = RFA_Position_Holders.User_Positions_ID

            LEFT JOIN User_Position_Holders As Approver_Position_Holders  ON Contract_Main.Approved_By_User_ID = Approver_Position_Holders.User_ID
            and Approver_Position_Holders.deleted = 0
            AND Approver_Position_Holders.User_Position_Type = 'P'

            LEFT JOIN User_Positions as Approver_Position ON Approver_Position.User_Positions_ID = Approver_Position_Holders.User_Positions_ID

            LEFT JOIN Contract_Main Contract_Main_1
            ON Contract_Main_1.Revision_Of_Contract_Main_ID = Contract_Main.Contract_Main_ID
            AND Contract_Main_1.Deleted = 0

            LEFT JOIN ##tmp_Effective_Dates
            ON ##tmp_Effective_Dates.Contract_Number = Contract_Main.Contract_Number

            <cfif local.showProgramTradeSpendORVolume>
            LEFT JOIN ##TotalPrgTradeSpendAndVolume
            ON ##TotalPrgTradeSpendAndVolume.Contract_Number = Contract_Main.Contract_Number

            LEFT JOIN ##PrgVersionlevelTradeSpendAndVolume
            ON ##PrgVersionlevelTradeSpendAndVolume.Contract_Number = Contract_Main.Contract_Number
            </cfif>

            LEFT JOIN Program_Auto_Renew
            ON Contract_Main.Contract_Main_ID = Program_Auto_Renew.Program_ID
            AND Program_Auto_Renew.Deleted = 0
            <!--- "Program_Auto_Renew.Renewed" has been added just to make sure that if there are duplicate records in the "Program_Auto_Renew" table
            with one record having "Renewed = 1" and the other "Renewed = 0", then the query will filter records with "Renewed = 1", and we
            will not get duplicates.
            --->
            AND Program_Auto_Renew.Renewed = 1
            LEFT JOIN ##tmp_ClaimMechanics Claim
            ON Claim.contract_main_id  = Contract_Main.Contract_Main_ID

            LEFT JOIN Business_Segment
            ON Business_Segment.Business_Segment_ID = Contract_Main.Business_Segment_ID

            LEFT JOIN ##tmpPgmSrch_Program_Operators
            ON ##tmpPgmSrch_Program_Operators.Contract_Main_ID = Contract_Main.Contract_Main_ID

            WHERE
        <!---D57639 :: View all versions of programs in program search START--->
            <cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
                (Contract_Main.Deleted = 0 OR (Contract_Main.Effective_Start_Date IS NOT NULL AND Contract_Main.Effective_End_Date IS NOT NULL))
            <cfelse>
                Contract_Main.Deleted = 0
            </cfif>
        <!---D57639 :: View all versions of programs in program search END--->
                    AND (Contract_Main.IsExclusionRevision = 0 OR Contract_Main.Contract_Status_Type_IDX > 2)
                    AND Contract_Main.Flagged_As_Purged = 0

                    <!--- dr D26891 --->
                    <cfif arguments.Creating_User_Position neq 0>
                        AND Contract_Main.creating_user_position_id= #arguments.Creating_User_Position#
                    </cfif>
                     <!--- dr D26891 --->




                    AND
                    (
                        Contract_Main.Force_Expiration_Flag = 0
                        OR
                        Contract_Main.Contract_Status_Type_IDX = 7
                    )
                    <!--- If the search is NOT for "date range". --->
                    <cfif arguments.startDate eq "" and arguments.endDate eq "">
                    <cfif IsNumeric(appSettings.getExpiredRecentlyDays())>
                    AND  Contract_Main.Contract_End_Date >= DateAdd(d,- #appSettings.getExpiredRecentlyDays()#,getDate())
                    </cfif>
                    <cfelse>
                    <!---
                    Return programs which overlap with the search dates (dataRangeStart OR dataRangeEnd).
                    If the search criteria is from 6/1/2013 - 9/30/2013, the following scenarios
                    will be used to return programs.
                    1) Programs with a start and end date between the search date range. Eg: 7/1/2013 to 7/31/2013.
                    2) Programs with a start date within the search date range. Eg: 7/1/2013 to 12/31/2013.
                    3) Programs with a end date within the search date range. Eg: 5/1/2013 to 6/30/2013.
                    4) Programs with the search data range within the start and end date. Eg: 1/1/2013 to 12/31/2013.
                    Note: All the above scenarios can be covered using just the 2 condiotions below.
                    --->
                    AND
                    Contract_Main.Contract_Start_Date <= '#DateFormat(sEndDate,"mm/dd/yyyy")#'
                    AND
                    Contract_Main.Contract_End_Date >= '#DateFormat(sStartDate,"mm/dd/yyyy")#'
                    </cfif>

                    <!------ Access permissions start ----->
                    ----Check Access Permissions
                    <cfif IsDefined("stSearch.programScorecardRestrictCreatedByUserId")>
                    <cfset qUserNumber = "" />
                    <cfif appSettings.getUserNumberRestrict()>
                    <cfset qUser = CreateObject("component", "components.user.UserManager").getUser(stSearch.programScorecardRestrictCreatedByUserId) />
                    <cfset qUserNumber = qUser.User_Number />
                    </cfif>
                    AND
                    (
                    Contract_Main.Responsible_User_ID = '#stSearch.programScorecardRestrictCreatedByUserId#'
                    <cfif Len(qUserNumber) GT 0>
                    OR (SELECT  User_Number FROM _Users WHERE User_ID = Contract_Main.Responsible_User_ID) = '#qUserNumber#'
                    </cfif>
                    )
                    </cfif>
                    AND
                    (
                    <cfif arguments.showCatalog eq 1>
                    <cfif stSearch.Read_Only_Catalog_Access EQ 1>
                    <!--- Catalog start --->
                    -- Catalog start
                    (
                        Program_Control_Panel_Options.Include_In_Catalog = 1
                     AND ((Contract_Main.Contract_Status_Type_IDX >= 3 and Contract_Main.Contract_Status_Type_IDX < 7) OR Contract_Main.Contract_Status_Type_IDX = 10 OR (Contract_Main.Contract_Status_Type_IDX = 7 and Contract_Main.CONTRACT_END_DATE >= DATEADD(D, -#appSettings.getExpiredRecentlyDays()# , GETDATE())))
                     <Cfif stSearch.See_Awarded_In_Catalog IS 1>
                     <!---Restriction -- if profile has seen only awarded and template says that the program should have awarded, the user will not be able to see the program in the catalog unless the program has been awarded--->
                     AND ((Program_Control_Panel_Options.Show_Awarded_In_Catalog = 1 AND Contract_Main.Is_Awarded = 1) OR Program_Control_Panel_Options.Show_Awarded_In_Catalog = 0)
                    </CFIF>
                    <!--- 29470 Update Catalog view to consider business segment --->
                    <cfset  businessSegmentsOn = 0 />
                    <cfset  Business_Segment_ID_List = "">
                    <cfif businessSegManager.isEnabled()>
                        <cfset businessSegmentsOn = 1 />
                        <cfset qGetBusSegments = businessSegManager.getActive(request.AccessStructure.user_id) />
                        <cfset Business_Segment_ID_List = ValueList(qGetBusSegments.Business_Segment_ID, ",")>
                    </cfif>
                    <cfif businessSegmentsOn EQ 1>
                        <cfif Len(Business_Segment_ID_List) GT 0>
                            AND Contract_Main.Business_Segment_ID IN (#Business_Segment_ID_List#)
                        <cfelse>
                            AND 1=2
                        </cfif>
                    </cfif>
                    )
                    -- Catalog end
                    <!--- Catalog end --->
                    </cfif>
                    <cfelse>
                    <!--- Program start --->
                    -- Program start
                    (
                    (
                        Contract_Main.Creating_User_Position_ID IN (#preserveSingleQuotes(stSearch.User_Positions_ID)#)
                        OR
                        (
                            <cfif NOT HQUser><!--- If HQ user no need to check for position --->
                            Contract_Main.Creating_User_Position_ID IN (#preserveSingleQuotes(stSearch.GP_Position_List_From_My_Position_Down_SC)#)
                            AND
                            </cfif>


                            <!--- dr D26891 --->
                            <cfif #arguments.Include_work_in_progress_below_me# EQ 0 AND Get_Profile_Settings.ProgramView_WIPPositionsBelowMe EQ 0>
                                (
                                Contract_Main.Contract_Status_Type_IDX > 1
                                OR
                                Contract_Main.Is_AutoRenew = 1
                                )
                            <cfelse>
                                1=1
                            </cfif>
                            <!--- dr D26891 --->
                        )




                        OR
                        (
                            Contract_Main.Contract_Status_Type_IDX >= 3
                            <cfif NOT HQUser><!--- If HQ user no need to check for position --->
                            AND
                            (
                                1=2
                                OR EXISTS
                                (
                                SELECT  1
                                FROM    ##TmpProgramsWithDistBrokerBelowMe t
                                WHERE   t.Contract_Main_ID = Contract_Main.Contract_Main_ID
                                )
                            )
                            </cfif>
                        )
                        <!---60308  Best Plans Enhancement START--->
                        OR Contract_Main.Best_Plan_Program = 1
                        <!---60308  Best Plans Enhancement END--->
                    )
                    #PreserveSingleQuotes(moreAccessPermissionRestriction)#
                    )

                    /*  Program end */
                 <!--- Program end --->
                    </cfif>
                    )
                    AND ISNULL(Contract_Main.Planner_ID, 0) = 0
                <!--- Dev Note: Milan 21662/22940 -If we are searching for any particular year, then we do not need to look at the
                    "Contract_Search_Options" table, but for "Current" or "Catalog" views, we need to check which statuses are
                    selected ON the settings panel and retreive only those statuses.
                --->
                <!--- Commented for now. This condition makes the query slow --->
                <!---
                    <cfif arguments.ArchiveYear eq "">
                    AND EXISTS
                    (
                    SELECT Contract_Status_Type_ID
                    FROM Contract_Search_Options
                    WHERE Contract_Main.Contract_Status_Type_IDX = Contract_Search_Options.Contract_Status_Type_ID
                    AND Contract_Search_Options.Contract_Status_Type_Selected = 1
                    )
                    </cfif>
                --->
                    ----Check Access Permissions End
                    <!------ Access permissions end ----->

                    <!--- No need to ORDER BY, as it is being sorted in FLEX
                    ORDER BY #sql_sort_by# #qryProgramSettings.scorecard_sort_method#
                    --->
					OPTION (MAXDOP 8)
        </cfquery>

        <!---</cftransaction>--->
        <cfreturn local.qGetProgramInfo>


    </cffunction>

    <cffunction name="populateProgramSearchAccessPermissionTables" output="false" returntype="void">
        <cfargument name="user_position_List" type="string" required="true" />
        <cfargument name="HQUser" type="boolean" required="true" />
        <cfargument name="showCatalog" type="string" required="false" default="0" />
        <cfargument name="Read_Only_Catalog_Access" type="string" required="false"  default="0" />

        <cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
        <cfset forbidType  = appSettings.getForbidAllowProfilesInTemplates() />
        <cfset moreAccessPermissionRestriction = getProgramAccessPermissionCode()>

        <!--- Delete the temp tables in a separate query. While testing code, there are no issues that way, as
        the prevents the "table already exists" error.
        --->
        <cfquery name="local.delTbl" datasource="#application.datasource#">
            IF OBJECT_ID('tempdb..##Profile_Forbidden_Template') IS NOT NULL
                DROP TABLE ##Profile_Forbidden_Template

            IF OBJECT_ID('tempdb..##Positions_Below_Me') IS NOT NULL
                DROP TABLE ##Positions_Below_Me

            IF OBJECT_ID('tempdb..##TmpProgramsWithDistBrokerBelowMe') IS NOT NULL
                DROP TABLE ##TmpProgramsWithDistBrokerBelowMe

			IF OBJECT_ID('tempdb..##TmpPgmSrch_PgmForThisCustomer') IS NOT NULL
                DROP TABLE ##TmpPgmSrch_PgmForThisCustomer

        </cfquery>

        <!---<cftransaction isolation="READ_UNCOMMITTED">--->
        <!--- changes made by gayathri to the query to reflect the Request for approval programs that are agreed by others but couldn't approve..this is for mainly lambweston, but still the query results don't change for other customers..please don't get confused. Approved status was used for substatus of RFA (pending approval) since we don't have that feild in the DB--->
        <cfquery name="local.qGetpopulateProgramSearchAccessPermissionTables" datasource="#application.datasource#">
            <!------ Get positions below ----->
            Create  table ##Positions_Below_Me (
              Below_User_Positions_ID   int          NOT NULL
            )
            <cfif NOT arguments.HQUser><!--- If HQ user no need to check for position --->
                CREATE  CLUSTERED  INDEX [I_Below_User_Positions_ID_tmp] ON [dbo].[##Positions_Below_Me]([Below_User_Positions_ID]) WITH  FILLFACTOR = 90,  PAD_INDEX  ON [PRIMARY]

                INSERT INTO ##Positions_Below_Me(Below_User_Positions_ID)
                    SELECT  DISTINCT Below_User_Positions_ID
                    FROM    Positions_Below_Me
                    WHERE   User_Positions_ID IN (#PreserveSingleQuotes(arguments.user_position_List)#)
            </cfif>

			<!--- 83860 When coming from Customer Profile Viewer ---->
			<cfif request.AccessStructure.External_Customer_Profile_Access EQ "1">
				IF OBJECT_ID('tempdb..##TmpPgmSrch_PgmForThisCustomer_Init') IS NOT NULL
                DROP TABLE ##TmpPgmSrch_PgmForThisCustomer_Init

				IF OBJECT_ID('tempdb..##TmpPgmSrch_PgmForThisCustomer') IS NOT NULL
                DROP TABLE ##TmpPgmSrch_PgmForThisCustomer

				CREATE TABLE ##TmpPgmSrch_PgmForThisCustomer_Init (Contract_Main_ID Int)

				<cfset custProfilePayeeType = 0 />

				<cfif request.AccessStructure.External_Customer_Profile_Access_CustType EQ "D">
					<!---- Get list of programs with provided distributor ---->

					INSERT INTO ##TmpPgmSrch_PgmForThisCustomer_Init WITH (TABLOCK)
					SELECT  DISTINCT CD.Contract_Main_ID
					FROM  	Contract_Distributors CD
					INNER JOIN BSA_Foodservice_Customers C
					ON 		C.BSA_Foodservice_Customers_ID = CD.BSA_Foodservice_Customers_ID
					AND		C.Shr_Ship_To = '#request.AccessStructure.External_Customer_Profile_Access_CustNum#'
					WHERE  	CD.Deleted = 0

					<cfset custProfilePayeeType = 1 />

				<cfelseif request.AccessStructure.External_Customer_Profile_Access_CustType EQ "O">
					<!---- Get list of programs with provided operator ---->

					INSERT INTO ##TmpPgmSrch_PgmForThisCustomer_Init WITH (TABLOCK)
					SELECT  DISTINCT CO.Contract_Main_ID
					FROM  	Contract_Operators CO
					INNER JOIN BSA_Operator O
					ON 		O.BSA_Operator_ID = CO.BSA_Operator_ID
					AND		O.Legacy_ID = '#request.AccessStructure.External_Customer_Profile_Access_CustNum#'
					WHERE  	CO.Deleted = 0

					<cfset custProfilePayeeType = 2 />

				</cfif>

				<!---- Get list of programs with component that pays to provided payee type ---->
				SELECT	Contract_Main_ID
				INTO	##TmpPgmSrch_PgmForThisCustomer
				FROM	##TmpPgmSrch_PgmForThisCustomer_Init s
				WHERE	EXISTS (
					SELECT	1 FROM Program_Fixed_Component c WHERE c.Program_ID = s.Contract_Main_ID AND c.Deleted = 0 AND c.Fixed_Component_Paid_To IN (#custProfilePayeeType#, 4)
				)
				UNION
				SELECT	Contract_Main_ID
				FROM	##TmpPgmSrch_PgmForThisCustomer_Init s
				WHERE	EXISTS (
					SELECT	1 FROM Program_Rebates_Component c WHERE c.Program_ID = s.Contract_Main_ID AND c.Deleted = 0 AND c.Component_Paid_To IN (#custProfilePayeeType#, 4)
				)
				UNION
				SELECT	Contract_Main_ID
				FROM	##TmpPgmSrch_PgmForThisCustomer_Init s
				WHERE	EXISTS (
					SELECT	1 FROM Program_Lump_Sums c WHERE c.Program_ID = s.Contract_Main_ID AND c.Deleted = 0 AND c.Component_Paid_To IN (#custProfilePayeeType#, 4)
				)
				UNION
				SELECT	Contract_Main_ID
				FROM	##TmpPgmSrch_PgmForThisCustomer_Init s
				WHERE	EXISTS (
					SELECT	1 FROM Program_Growth_Components c WHERE c.Program_ID = s.Contract_Main_ID AND c.Deleted = 0 AND c.Component_Paid_To IN (#custProfilePayeeType#, 4)
				)

			</cfif>

            <cfif NOT(arguments.showCatalog eq 1 and arguments.Read_Only_Catalog_Access EQ 1)>
                Create  table ##Profile_Forbidden_Template (
                  template_id int not null
                )

                INSERT INTO  ##Profile_Forbidden_Template(Template_ID)
                <!------ forbit type=1, forbid, 0=allow ----->
                <cfif forbidType EQ 1>
                    SELECT Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
                      FROM Program_Control_Panel_Options
                            LEFT JOIN Profile_Forbidden_Template ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Profile_Forbidden_Template.template_id
                                        AND Profile_Forbidden_Template.Forbid_Access_Type = 1
                                        AND Profile_Forbidden_Template.deleted = 0
                                        AND Profile_Forbidden_Template.Forbid_Type = #forbidType#
                                        AND Profile_Forbidden_Template.profile_id = #request.AccessStructure.Profiles_ID#
                    <!--- Show me the templates, which are not in the "Profile_Forbidden_Template" table --->
                    WHERE Profile_Forbidden_Template.template_id IS NULL
                <cfelse>
                    SELECT Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
                      FROM Program_Control_Panel_Options
                            INNER JOIN Profile_Forbidden_Template ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Profile_Forbidden_Template.template_id
                      WHERE Profile_Forbidden_Template.deleted = 0
                            AND Profile_Forbidden_Template.Forbid_Access_Type = 1
                            AND Profile_Forbidden_Template.Forbid_Type = #forbidType#
                            AND Profile_Forbidden_Template.profile_id = #request.AccessStructure.Profiles_ID#
                </cfif>

                CREATE  CLUSTERED  INDEX [I_Profile_Forbidden_Template_tmp] ON [dbo].[##Profile_Forbidden_Template]([Template_ID])
                WITH  FILLFACTOR = 90,  PAD_INDEX  ON [PRIMARY]
            </cfif>

            <cfif NOT arguments.HQUser><!--- If HQ user no need to check for position --->
                <cfif appSettings.getDistributorMultiPosition() IS 1>
                    SELECT  DISTINCT CD.Contract_Main_ID
                      INTO  ##TmpProgramsWithDistBrokerBelowMe
                      FROM  Contract_Distributors CD
                            INNER JOIN Market_Distributor MD ON MD.Distributor_ID = CD.BSA_Foodservice_Customers_ID
                                                                AND MD.Deleted = 0
                            INNER JOIN User_Positions ON  User_Positions.Service_market_ID = MD.Service_market_ID
                                                            AND User_Positions.Deleted = 0
                                                            AND User_Positions.User_Positions_ID IN (SELECT Below_User_Positions_ID FROM ##Positions_Below_Me)
                     WHERE  CD.Deleted = 0
                <cfelse>
                    SELECT  Contract_Distributors.Contract_Main_ID
                      INTO  ##TmpProgramsWithDistBrokerBelowMe
                      FROM  Contract_Distributors
                            INNER JOIN BSA_Foodservice_Customers ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Contract_Distributors.BSA_Foodservice_Customers_ID
                                                                    AND BSA_Foodservice_Customers.Deleted = 0
                            INNER JOIN BSA_Foodservice_Brokers ON BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID
                            INNER JOIN User_Positions ON User_Positions.Service_market_ID = BSA_Foodservice_Brokers.Service_market_ID
                                                        AND User_Positions.Deleted = 0
                                                        AND User_Positions.User_Positions_ID IN (SELECT Below_User_Positions_ID FROM ##Positions_Below_Me)
                     WHERE  Contract_Distributors.Deleted = 0

                    UNION

                    SELECT  Contract_Brokers.Contract_Main_ID
                      FROM  Contract_Brokers
                            INNER JOIN BSA_Foodservice_Brokers ON BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Contract_Brokers.BSA_Foodservice_Brokers_ID
                            INNER JOIN User_Positions ON User_Positions.Service_market_ID = BSA_Foodservice_Brokers.Service_market_ID
                                                        AND User_Positions.Deleted = 0
                                                        AND User_Positions.User_Positions_ID IN (SELECT Below_User_Positions_ID FROM ##Positions_Below_Me)
                     WHERE  Contract_Brokers.Deleted = 0
                </cfif>
            </cfif>
        </cfquery>
    </cffunction>


    <cffunction name="getProgramSettings" returntype="struct">
        <cfset var Company_ID = getCompanyID()>
        <cfset var SortOptions = StructNew()>

        <cfquery NAME="local.qgetProgramSettings" datasource="#application.datasource#">
            SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
            SELECT scorecard_sort_option, scorecard_sort_method, Display_Trade_Dollars,
                    Display_Payment_Dollars, Display_Volume, Display_Operator_Info
              FROM  _Users_Settings
             WHERE  User_ID = '#Company_ID.Company_Main_ID#'
        </cfquery>

        <cfswitch expression="#local.qgetProgramSettings.scorecard_sort_option#">
            <cfcase value="CN">
                <CFSET SortOptions.scorecard_Sort_option="contract_number">
            </cfcase>
            <cfcase value="CT">
                <CFSET SortOptions.scorecard_Sort_option="contract_title">
            </cfcase>
            <cfcase value="SD">
                <CFSET SortOptions.scorecard_Sort_option="contract_start_date">
            </cfcase>
            <cfcase value="ED">
                <CFSET SortOptions.scorecard_Sort_option="contract_end_date">
            </cfcase>
            <cfcase value="ST">
                <CFSET SortOptions.scorecard_Sort_option="status_id">
            </cfcase>
            <cfcase value="PT">
                <CFSET SortOptions.scorecard_Sort_option="created_type">
            </cfcase>
        </cfswitch>

        <!--- "SortField" in FLEX accepts an argument for "DESCENDING". So, we pass true for "DESC" and false for "ACS" --->
        <cfif local.qgetProgramSettings.scorecard_sort_method eq 'DESC'>
                <cfset SortOptions.scorecard_sort_method = "1">
        <cfelse>
                <cfset SortOptions.scorecard_sort_method = "0">
        </cfif>

        <cfset SortOptions.display_trade_dollars = local.qgetProgramSettings.Display_Trade_Dollars>
        <cfset SortOptions.display_payment_dollars = local.qgetProgramSettings.Display_Payment_Dollars>
        <cfset SortOptions.display_volume = local.qgetProgramSettings.Display_Volume>
        <cfset SortOptions.display_operator_info = qgetProgramSettings.Display_Operator_Info>

        <cfreturn SortOptions />
    </cffunction>

	<cffunction name="getPrgSettings" returntype="struct">
		<cfset var Company_ID = getCompanyID()>
		<cfset var SortOptions = StructNew()>

		<cfquery NAME="local.qgetProgramSettings" datasource="#application.datasource#">
			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT scorecard_sort_option, scorecard_sort_method, Display_Trade_Dollars,
				Display_Payment_Dollars, Display_Volume,Display_Operator_Info, Display_Reference_Number_In_Search_Results
			FROM  _Users_Settings
			WHERE  User_ID = '#Company_ID.Company_Main_ID#'
		</cfquery>

		<cfswitch expression="#local.qgetProgramSettings.scorecard_sort_option#">
			<cfcase value="CN">
				<CFSET SortOptions.scorecard_Sort_option="program">
			</cfcase>
			<cfcase value="CT">
				<CFSET SortOptions.scorecard_Sort_option="title">
			</cfcase>
			<cfcase value="SD">
				<CFSET SortOptions.scorecard_Sort_option="startDate">
			</cfcase>
			<cfcase value="ED">
				<CFSET SortOptions.scorecard_Sort_option="endDate">
			</cfcase>
			<cfcase value="PT">
				<CFSET SortOptions.scorecard_Sort_option="type">
			</cfcase>
		</cfswitch>

		<cfset SortOptions.scorecard_sort_method = local.qgetProgramSettings.scorecard_sort_method>

		<cfset SortOptions.display_trade_dollars = local.qgetProgramSettings.Display_Trade_Dollars>
		<cfset SortOptions.display_payment_dollars = local.qgetProgramSettings.Display_Payment_Dollars>
		<cfset SortOptions.display_volume = local.qgetProgramSettings.Display_Volume>
		<cfset SortOptions.display_operator_info = local.qgetProgramSettings.Display_Operator_Info>
        <cfset SortOptions.Display_Reference_Number_In_Search_Results = local.qgetProgramSettings.Display_Reference_Number_In_Search_Results>

		<cfreturn SortOptions />
	</cffunction>

    <cffunction name="getCompanyID" returntype="query">
        <cfset var qgetCompanyID = 0>
        <cfset useLakebaseForqgetCompanyID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("company_main")>
<cfif useLakebaseForqgetCompanyID>
	<cftry>
		<cfset qgetCompanyID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("company_main", {
				"deleted" = "eq.0",
				"select" = "company_main_id"
			}), "company_main_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetCompanyID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetCompanyID>
<cfquery NAME="qgetCompanyID" datasource="#application.datasource#">
          SELECT Company_Main_ID
          FROM Company_Main
          WHERE Deleted  = 0
        </cfquery>
</cfif>

        <cfreturn qgetCompanyID />
    </cffunction>

    <cffunction name="getProgramAccessPermissionCode" output="true" returntype="string">
        <cfset var businessSegmentsOn = 0 />
        <cfset var moreAccessPermissionRestriction = "" />
        <cfset var Business_Segment_ID_List = "">
        <cfset var qGetBusSegments = "" />
        <cfset var UserClassCodeList = "">
        <cfset var UserClassCodeUUIDList = "">
        <cfset var qGetUserClassCodes = "">
        <cfset var classCodeIDList = "">
        <cfset var appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
        <cfset var forbidType = appSettings.getForbidAllowProfilesInTemplates() />

        <cfif businessSegManager.isEnabled()>
            <cfset businessSegmentsOn = 1 />
            <cfset qGetBusSegments = businessSegManager.getActive(request.AccessStructure.user_id) />
            <cfset Business_Segment_ID_List = ValueList(qGetBusSegments.Business_Segment_ID, ",")>
        </cfif>

        <cfif businessSegManager.getClassCodesOn()>
            <cfset qGetUserClassCodes = businessSegManager.getActiveClassCodes(request.AccessStructure.User_ID, 0) />
            <cfset UserClassCodeList = ValueList(qgetUserClassCodes.class_code_id)>
            <cfset UserClassCodeUUIDList = ValueList(qgetUserClassCodes.Class_Code_UUID) />
        </cfif>

        <cfoutput>
        <cfsavecontent variable="moreAccessPermissionRestriction">

        <!--- Dev Notes: Milan - 23850 (Removed this condition) --->
        <!------ forbit type=1, forbid, 0=allow ----->
        <!---
        AND Contract_Main.ProgramType_ID
        <cfif forbidType EQ 1>not </cfif>
        in
        (select     Template_ID from    ##Profile_Forbidden_Template WHERE Forbid_Access_Type = 1)
        --->

        <!------ Business Segment restriction ----->
        <cfif businessSegmentsOn EQ 1>
            <cfif Len(Business_Segment_ID_List) GT 0>
            AND Contract_Main.Business_Segment_ID IN (#Business_Segment_ID_List#)
            <cfelse>
            AND 1=2
            </cfif>
            <!------ access permission restriction ON class code ----->
            <cfif businessSegManager.getClassCodesOn()>
                AND
                (
                    1=2
                    <cfif trim(UserClassCodeList) neq "">
                        OR Exists
                        (SELECT TOP 1 User_Class_Code.Class_Code_Id
                        FROM    User_Class_Code
                        WHERE   User_Class_Code.User_Id = Contract_Main.Responsible_User_ID
                                AND User_Class_Code.Deleted = 0
                                AND class_code_id in (#UserClassCodeList#))
                    </cfif>
                )
            </cfif>
        </cfif>
        <!------ DEV NOTE: DRK 9674/9742 : if the template - restrict group type is class code alone ----->
        <cfif appSettings.getTemplateRestrictGroupLevel() eq 10>
        <cfset classCodeIDList = UserClassCodeUUIDList />
        AND (Program_Control_Panel_Options.Restrict_On_Approval_Group = 0 <!------ either the template should not be restricted at group level  ----->
            <cfif classCodeIDList neq ""><!------ if the template is restricted at group level, check to see if the user have atleast one of the selected class code ----->
            OR
            Program_Control_Panel_Options.ProgramControl_Panel_Options_ID IN
            (
            SELECT  DISTINCT Program_Type_ID
            FROM    Template_Allow_Approval_Group
            WHERE   Deleted = 0
            AND     Group_ID IN (#ListQualify(classCodeIDList, "'")#))
            </cfif>
            )
        </cfif>

        </cfsavecontent>
        </cfoutput>

        <cfreturn moreAccessPermissionRestriction>
    </cffunction>

    <!--- Modified this function so that it works with the Flex Grid as well as AG Grid. --->
    <cffunction name="getUserAgreedProgramsIdList" output="false" returntype="array">
        <cfargument name="userId" required="true" type="string" />
        <cfargument name="returnData" required="false" type="boolean" default="1" />

        <cfset var a = arrayNew(1) />
        <cfif Len(arguments.userId) GT 0>
            <cfquery name="local.delTbl" datasource="#application.datasource#">
                IF OBJECT_ID('tempdb..##tmp_Program_Agree_List') IS NOT NULL
                    DROP TABLE ##tmp_Program_Agree_List
            </cfquery>

            <CFSET positionId = CreateObject("component", "components.user.UserManager").getPositionId(arguments.userID, 0) />
            <cfset lPositionsAbove = CreateObject("component", "components.geography.position").getPositionsAbove(positionId,0) />

            <cfset UsersToEvaluate = "">
            <cfif len(trim(lPositionsAbove)) GT 0>
                <cfset stStruct = StructNew() />
                <cfset stStruct.userPosition = lPositionsAbove />
                <cfset UserPositionsAbove = CreateObject("component", "components.user.userManager").search(stStruct) />

                <cfset UsersToEvaluate = ValueList(UserPositionsAbove.User_ID)>
            </cfif>
            <cfset UsersToEvaluate = Listappend(UsersToEvaluate, arguments.userID)>
            <cfset UsersToEvaluate = listqualify(UsersToEvaluate, "'", ",")>

            <cfquery name="qGetUserAgreedPrograms" datasource="#application.datasource#">
            SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
                SELECT
                <!--- Flex program search ---->
                <cfif arguments.returnData eq 1>
                DISTINCT CAST(Program_Agree.ProgramId As varchar(10)) As ProgramId
                <cfelse>
                <!--- AG Grid program search ---->
                DISTINCT Program_Agree.ProgramId
                INTO ##tmp_Program_Agree_List
                </cfif>
                FROM    Program_Agree_All_Group Program_Agree
                INNER JOIN Contract_Main
                ON      Contract_Main.Contract_Main_ID = Program_Agree.ProgramId
                AND     Contract_Main.Contract_Status_Type_IDX = 2
                AND     Contract_Main.Deleted = 0
                WHERE   Program_Agree.User_ID IN (#preservesinglequotes(UsersToEvaluate)#)
             </cfquery>

            <cfif arguments.returnData eq 1>
                <cfset a.AddAll(qGetUserAgreedPrograms[ "ProgramId" ])  />
            </cfif>
        </cfif>

        <cfreturn a>
    </cffunction>

    <!--- This function is being used by Flex Program search --->
    <cffunction name="getPendingApprovalPrograms" output="true" returntype="array">
        <cfargument name="userId" required="true" type="string" />
        <cfargument name="Profiles_ID" required="true" type="string" />

        <cfset var appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
        <cfset var forbidType = appSettings.getForbidAllowProfilesInTemplates() />
        <cfset var UserPositionList = "" />
        <cfset var userAuthoritySequenceLevelID = "" />
        <cfset var profileId = arguments.Profiles_ID />
        <cfset var profileSettingApproveFreightPrograms = 0 />
        <cfset var userAgreedProgramsIDList = "" />
        <cfset var qGetAuthoritySequenceLevel = "" />
        <cfset var a = arrayNew(1) />

        <cfif Len(arguments.userId) GT 0>
            <cfset qUserInfo = CreateObject("component", "components.user.UserManager").getUserInfo(arguments.userId) />

            <cfif appsettings.getDisplayEligibleRSP() EQ 0 OR qUserInfo.Is_Eligible_RSP EQ "1">

                <cfset userPositionList = CreateObject("component", "components.user.UserManager").getPositionId(arguments.userId, 0, 1) />

                <cfset userAuthoritySequenceLevelID = 0 />
                <cfif isNumeric(qUserInfo.Authority_Sequence_ID)>
                    <cfset qGetAuthoritySequenceLevel = CreateObject("component", "components.user.AuthoritySequenceManager").getAuthoritySequenceLevel(qUserInfo.Authority_Sequence_ID) />
                    <cfif qGetAuthoritySequenceLevel.recordCount>
                        <cfset userAuthoritySequenceLevelID = qGetAuthoritySequenceLevel.Authority_Sequence_Order />
                    </cfif>
                </cfif>


                <CFINCLUDE TEMPLATE="/get_access_profile.cfm">

                <cfset profileSettingApproveFreightPrograms = Get_Profile_Settings.Approve_Freight_Programs />
                <cfset userAgreedProgramsIDList = arraytoList(getUserAgreedProgramsIdList(arguments.userId)) />

                <cfquery name="qGetPendingApprovalPrograms" datasource="#application.datasource#">
                SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
                    <!----- get approvable programs ---->
                    DECLARE  @Approvable_Programs table
                    (
                      contract_main_id  int    NOT NULL
                    )

                    INSERT INTO @Approvable_Programs(contract_main_id)
                    SELECT DISTINCT Program_Approvable_Profiles.contract_main_id
                    FROM    Program_Approvable_Profiles
                    WHERE   Program_Approvable_Profiles.Authority_Sequence_Order = #userAuthoritySequenceLevelID#
                    AND     (
                                (       Program_Approvable_Profiles.profile_id = #profileId#
                                    and Program_Approvable_Profiles.user_positions_id in (#PreserveSingleQuotes(userPositionList)#)
                                )

                            )

                    <!----- get profile template approval access ---->
                    if object_id('tempdb..##Profile_Forbidden_Template') is not null
                    drop table ##Profile_Forbidden_Template

                    Create  table ##Profile_Forbidden_Template
                    (
                      template_id int not null
                    )
                    INSERT INTO  ##Profile_Forbidden_Template(Template_ID)
                    <!------ forbit type=1, forbid, 0=allow ----->
                    <cfif forbidType EQ 1>
                    SELECT Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
                    FROM Program_Control_Panel_Options
                    LEFT JOIN Profile_Forbidden_Template
                    ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Profile_Forbidden_Template.template_id
                    <!--- Forbid_Access_Type = 2 means not allowed to approve the program --->
                    AND Profile_Forbidden_Template.Forbid_Access_Type = 2
                    AND Profile_Forbidden_Template.deleted = 0
                    AND Profile_Forbidden_Template.Forbid_Type = #forbidType#
                    AND Profile_Forbidden_Template.profile_id = #Profiles_ID#
                    <!--- Show me the templates, which are not in the "Profile_Forbidden_Template" table --->
                    WHERE Profile_Forbidden_Template.template_id IS NULL

                    <cfelse>

                    SELECT Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
                    FROM Program_Control_Panel_Options
                    INNER JOIN Profile_Forbidden_Template
                    ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Profile_Forbidden_Template.template_id
                    WHERE Profile_Forbidden_Template.deleted = 0
                    <!--- Forbid_Access_Type = 2 means not allowed to approve the program --->
                    AND Profile_Forbidden_Template.Forbid_Access_Type = 2
                    AND Profile_Forbidden_Template.Forbid_Type = #forbidType#
                    AND Profile_Forbidden_Template.profile_id = #Profiles_ID#
                    </cfif>

                    CREATE  CLUSTERED  INDEX [I_Profile_Forbidden_Template_tmp] ON [dbo].[##Profile_Forbidden_Template]([Template_ID])
                    WITH  FILLFACTOR = 90,  PAD_INDEX  ON [PRIMARY]

                    <!--- Convert it to varchar because now we are loading all the program data as string,
                        including contract_main_id and so any other query getting program data needs to get data
                        as string only, so that there are no data type issues. Without conversion, Flex will not
                        return any records as the filter will fail.
                    --->
                    SELECT  CAST(contract_main.contract_main_id As varchar(10)) As contract_main_id
                    FROM    contract_main
                    LEFT JOIN contract_main_aux_data
                    ON      contract_main_aux_data.contract_main_id = contract_main.contract_main_id
                    WHERE   contract_main.deleted = 0
                    AND     contract_main.contract_status_type_idx = 2
                    AND
                        (
                            Contract_Main.Contract_Main_ID IN (SELECT Contract_Main_ID FROM @Approvable_Programs)
                            <!------ also show in pending approval tab if this user can approve this program ----->
                            AND
                            (
                            Contract_Main.ProgramType_ID
                            IN
                            (SELECT Template_ID FROM ##Profile_Forbidden_Template)
                            <cfif appSettings.getShow_Fixed_Freight() eq 1 and profileSettingApproveFreightPrograms eq 1>
                            or  Contract_Main_Aux_Data.Freight_Component_Type <> 0
                            </cfif>
                            )

                            <!------ no need to do the GDW4 filter any more because it is already handled in Program_Approvable_Profiles ----->
                        )
                        <!------ I have not agreed to this program ----->
                        <cfif Len(userAgreedProgramsIDList) GT 0>
                            AND Contract_Main.Contract_Main_ID NOT IN (#userAgreedProgramsIDList#)
                        </cfif>


                 </cfquery>

                <cfset a.AddAll(qGetPendingApprovalPrograms[ "Contract_Main_Id" ])  />

                <cfreturn  a />

            </cfif>
        </cfif>

        <cfreturn a />

    </cffunction>

    <!--- This function is being used by AG Grid Program Search --->
    <cffunction name="getPendingApprovalProgramList" output="false" returntype="void">
        <cfargument name="userId" required="true" type="string" />
        <cfargument name="Profiles_ID" required="true" type="string" />

        <cfset var appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
        <cfset var forbidType = appSettings.getForbidAllowProfilesInTemplates() />
        <cfset var UserPositionList = "" />
        <cfset var userAuthoritySequenceLevelID = "" />
        <cfset var profileId = arguments.Profiles_ID />
        <cfset var profileSettingApproveFreightPrograms = 0 />
        <cfset var userAgreedProgramsIDList = "" />
        <cfset var qGetAuthoritySequenceLevel = "" />
        <cfset var a = arrayNew(1) />
        <cfset var droptempTable = 0>
        <cfset var createtempTable = 0>

        <cfif Len(arguments.userId) GT 0>
            <cfset qUserInfo = CreateObject("component", "components.user.UserManager").getUserInfo(arguments.userId) />

                <cfquery name="droptempTable" datasource="#application.datasource#">
                    IF OBJECT_ID('tempdb..##tmp_pending_approval_programs_list') IS NOT NULL
                        DROP TABLE ##tmp_pending_approval_programs_list
                </cfquery>

                <cfquery name="createtempTable" datasource="#application.datasource#">
                    CREATE  TABLE ##tmp_pending_approval_programs_list (
                        contract_main_id  int    NOT NULL
                    )
                </cfquery>

            <cfif appsettings.getDisplayEligibleRSP() EQ 0 OR qUserInfo.Is_Eligible_RSP EQ "1">

                <cfset userPositionList = CreateObject("component", "components.user.UserManager").getPositionId(arguments.userId, 0, 1) />

                <cfset userAuthoritySequenceLevelID = 0 />
                <cfif isNumeric(qUserInfo.Authority_Sequence_ID)>
                    <cfset qGetAuthoritySequenceLevel = CreateObject("component", "components.user.AuthoritySequenceManager").getAuthoritySequenceLevel(qUserInfo.Authority_Sequence_ID) />
                    <cfif qGetAuthoritySequenceLevel.recordCount>
                        <cfset userAuthoritySequenceLevelID = qGetAuthoritySequenceLevel.Authority_Sequence_Order />
                    </cfif>
                </cfif>


                <CFINCLUDE TEMPLATE="/get_access_profile.cfm">

                <cfset profileSettingApproveFreightPrograms = Get_Profile_Settings.Approve_Freight_Programs />
                <cfset userAgreedProgramsIDList = arraytoList(getUserAgreedProgramsIdList(arguments.userId)) />
                <cfquery name="droptempTbl" datasource="#application.datasource#">
                  IF OBJECT_ID('tempdb..##Profile_Forbidden_Template_Approve') IS NOT NULL
                  DROP TABLE ##Profile_Forbidden_Template_Approve
                < /cfquery>

                <cfquery name="qGetPendingApprovalPrograms" datasource="#application.datasource#">
                SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
                    <!----- get approvable programs ---->
                    DECLARE  @Approvable_Programs table (
                      contract_main_id  int    NOT NULL
                    )

                    INSERT INTO @Approvable_Programs(contract_main_id)
                    SELECT DISTINCT Program_Approvable_Profiles.contract_main_id
                    FROM    Program_Approvable_Profiles
                    WHERE   Program_Approvable_Profiles.Authority_Sequence_Order = #userAuthoritySequenceLevelID#
                    AND     (
                                (       Program_Approvable_Profiles.profile_id = #profileId#
                                    and Program_Approvable_Profiles.user_positions_id in (#PreserveSingleQuotes(userPositionList)#)
                                )

                            )


                    Create  table ##Profile_Forbidden_Template_Approve (
                      template_id int not null
                    )
                    INSERT INTO  ##Profile_Forbidden_Template_Approve(Template_ID)
                    <!------ forbit type=1, forbid, 0=allow ----->
                    <cfif forbidType EQ 1>
                    SELECT Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
                    FROM Program_Control_Panel_Options
                    LEFT JOIN Profile_Forbidden_Template
                    ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Profile_Forbidden_Template.template_id
                    <!--- Forbid_Access_Type = 2 means not allowed to approve the program --->
                    AND Profile_Forbidden_Template.Forbid_Access_Type = 2
                    AND Profile_Forbidden_Template.deleted = 0
                    AND Profile_Forbidden_Template.Forbid_Type = #forbidType#
                    AND Profile_Forbidden_Template.profile_id = #Profiles_ID#
                    <!--- Show me the templates, which are not in the "Profile_Forbidden_Template" table --->
                    WHERE Profile_Forbidden_Template.template_id IS NULL

                    <cfelse>

                    SELECT Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
                    FROM Program_Control_Panel_Options
                    INNER JOIN Profile_Forbidden_Template
                    ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Profile_Forbidden_Template.template_id
                    WHERE Profile_Forbidden_Template.deleted = 0
                    <!--- Forbid_Access_Type = 2 means not allowed to approve the program --->
                    AND Profile_Forbidden_Template.Forbid_Access_Type = 2
                    AND Profile_Forbidden_Template.Forbid_Type = #forbidType#
                    AND Profile_Forbidden_Template.profile_id = #Profiles_ID#
                    </cfif>

                    CREATE  CLUSTERED  INDEX [I_Profile_Forbidden_Template_Approve_tmp] ON [dbo].[##Profile_Forbidden_Template_Approve]([Template_ID])
                    WITH  FILLFACTOR = 90,  PAD_INDEX  ON [PRIMARY]

                    INSERT INTO ##tmp_pending_approval_programs_list  WITH (TABLOCK) (contract_main_id)
                    SELECT contract_main.contract_main_id
                    FROM    contract_main
                    LEFT JOIN contract_main_aux_data
                    ON      contract_main_aux_data.contract_main_id = contract_main.contract_main_id
                    WHERE   contract_main.deleted = 0
                    AND     contract_main.contract_status_type_idx = 2
                    AND
                        (
                            Contract_Main.Contract_Main_ID IN (SELECT Contract_Main_ID FROM @Approvable_Programs)
                            <!------ also show in pending approval tab if this user can approve this program ----->
                            AND
                            (
                            Contract_Main.ProgramType_ID
                            IN
                            (SELECT Template_ID FROM ##Profile_Forbidden_Template_Approve)
                            <cfif appSettings.getShow_Fixed_Freight() eq 1 and profileSettingApproveFreightPrograms eq 1>
                            or  Contract_Main_Aux_Data.Freight_Component_Type <> 0
                            </cfif>
                            )

                            <!------ no need to do the GDW4 filter any more because it is already handled in Program_Approvable_Profiles ----->
                        )
                        <!------ I have not agreed to this program ----->
                        <cfif Len(userAgreedProgramsIDList) GT 0>
                            AND Contract_Main.Contract_Main_ID NOT IN (#userAgreedProgramsIDList#)
                        </cfif>


                 </cfquery>

            </cfif>
        </cfif>

    </cffunction>

    <cffunction name="fullTextStringClean" access="public" returntype="String">
        <cfargument name="s" required="true" default="">

        <cfscript>
            var r = "";
            if (len(arguments.s) gt 0) {
                    // remove all non-alphanumeric characters from string
                    r = trim(reReplace(arguments.s,'[^a-zA-Z0-9\,_.]',' ','ALL')); // replace with spaces
                    if (len(r) GT 0) {
                            // If criteria is not blank then break apart the words and create a new list with qualifiers for full text search
                            r = reReplace(r, '(\s)+',',','ALL');      // replace multiple spaces with comma
                            return reReplace(r, '(\,)+\1','\1','ALL');      // replace multiple commas with a single comma
                    }
                }
            return r;
        </cfscript>
    </cffunction>

    <cffunction name="fullTextStringModify" access="public" returntype="String">
        <cfargument name="s" required="true" default="">
        <cfscript>
            var r = "";
            if (len(arguments.s) GT 0) {
                    // Replace comma-delimited list with a list delimited by " OR "
                return replace(arguments.s, ",", '" OR "' ,"ALL");
            }
            return r;
        </cfscript>
    </cffunction>

    <cffunction name="fullTextProgramFilter" output="false" access="public" returntype="Array">
        <cfargument name="DistString" required="true" default="" />
        <cfargument name="OprString" required="true" default="" />
        <cfargument name="ItemString" required="true" default="" />
        <cfargument name="BuyingGroup" type="string" required="true" default=""/>
        <cfargument name="Family" type="string" required="true" default=""/>
         <!---<cfset User_ID = '#request.AccessStructure.user_id#'> --->
        <cfscript>
                var qContractFilter = '';
                var a = ArrayNew(1);
                var d = 0;
                var o = 0;
                var i = 0;
                var searchCriteria = 0;
                var dString = fullTextStringClean(arguments.DistString);
                var oString = fullTextStringClean(arguments.OprString);
                var iString = fullTextStringClean(arguments.ItemString);
                var bgString = fullTextStringModify(arguments.BuyingGroup);
                var fmlyString = fullTextStringModify(arguments.Family);
        </cfscript>

        <cfquery name="qContractFilter" datasource="#application.datasource#">
        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
        <!--- Convert it to varchar because now we are loading all the program data as string,
        including contract_main_id and so any other query getting program data needs to get data
        as string only, so that there are no data type issues. Without conversion, Flex will not
        return any records as the filter will fail.
        --->
            SELECT DISTINCT CAST(CM.Contract_Main_Id As varchar(10)) As Contract_Main_Id
            FROM Contract_Main CM
                <cfif dString neq ""  OR Left(arguments.BuyingGroup, 8) neq "Show All" OR Left(arguments.Family, 8) neq "Show All">
                    INNER JOIN dbo.BSA_Foodservice_Customers BFC ON 1 = 1

                    <cfset searchCriteria = 1>
                </cfif>

                <cfif dString neq "">
                    <cfloop from="1" to="#listLen(dString)#" index="d">
                    INNER JOIN CONTAINSTABLE(BSA_Foodservice_Customers, *, '"*#ListGetAt(dString,d)#*"') AS DIST_TABLE_#d#
                    ON DIST_TABLE_#d#.[KEY] = BFC.BSA_Foodservice_Customers_ID
                    </cfloop>
                </cfif>
                <!---
                    45992: Non-US Food's programs appear when searching US Foods in Corporate Parent filter/Anand Rao/13-Nov-2014
                    Add the  condition in the below two if conditions (AND BFC.Family_Name LIKE '%#fmlyString#%') so that
                    the matching results will be returned. With the CONTAINSTABLE it was returning the results in an OR condition.
                --->
                <cfif Left(arguments.BuyingGroup, 8) neq "Show All">
                    INNER JOIN CONTAINSTABLE(BSA_Foodservice_Customers,Buying_Group_Name, '"#bgString#"') AS DIST_TABLE_BG
                    ON DIST_TABLE_BG.[KEY] = BFC.BSA_Foodservice_Customers_ID
                    AND BFC.Buying_Group_Name LIKE '%#bgString#%'
                </cfif>

                <cfif Left(arguments.Family, 8) neq "Show All">
                    INNER JOIN CONTAINSTABLE(BSA_Foodservice_Customers,Family_Name, '"#fmlyString#"') AS DIST_TABLE_FMLY
                    ON DIST_TABLE_FMLY.[KEY] = BFC.BSA_Foodservice_Customers_ID
                    --AND BFC.Family_Name LIKE '%#fmlyString#%'
                </cfif>

                <cfif dString neq "" OR Left(arguments.BuyingGroup, 8) neq "Show All" OR Left(arguments.Family, 8) neq "Show All">
                    INNER JOIN Contract_Distributors CD ON
                        BFC.BSA_Foodservice_Customers_ID = CD.BSA_Foodservice_Customers_ID AND
                        CM.Contract_Main_Id =  CD.Contract_Main_Id AND
                        CD.Deleted = 0
                </cfif>

                <cfif oString neq "">
                    INNER JOIN BSA_Operator BO ON 1=1
                    <cfloop from="1" to="#listLen(oString)#" index="o">
                    INNER JOIN CONTAINSTABLE(BSA_Operator, *, '"*#ListGetAt(oString,o)#*"') AS OP_TABLE_#o#
                        ON OP_TABLE_#o#.[KEY] = BO.BSA_Operator_ID
                    </cfloop>
                    INNER JOIN Contract_Operators CO ON
                        BO.BSA_Operator_ID = CO.BSA_Operator_ID AND
                        CM.Contract_Main_Id =  CO.Contract_Main_Id AND
                        CO.Deleted = 0

                    <cfset searchCriteria = 1>
                </cfif>

                <cfif iString neq "">
                    INNER JOIN Item_Search BFI ON 1 = 1
                    <cfloop from="1" to="#listLen(iString)#" index="i">
                    INNER JOIN CONTAINSTABLE(Item_Search, *, '"*#ListGetAt(iString,i)#*"') AS IM_TABLE_#i#
                        ON IM_TABLE_#i#.[KEY] = BFI.Key_Id
                    </cfloop>
                    INNER JOIN Contract_Products CP ON
                        BFI.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID AND
                        CM.Contract_Main_Id =  CP.Contract_Main_Id AND
                        CP.Deleted = 0

                    <cfset searchCriteria = 1>
                </cfif>

                WHERE   CM.Deleted = 0

                <!--- If there was no search criteria passed to this function, then return no records. --->
                <cfif searchCriteria eq 0>
                AND 1 = 0
                </cfif>
        </cfquery>

        <cfset a.AddAll(qContractFilter[ "Contract_Main_Id" ])  />
        <cfreturn a />
    </cffunction>

    <cffunction name="variableExist" output="false">
        <cfargument name="sVarName" required="true" default="" type="string" />
        <cfargument name="sDefaultValue" required="false" default="" type="string" />

        <cfset returnValue = false>
        <cfif isDefined(arguments.sVarName)>
            <cfif Evaluate("#arguments.sVarName#") NEQ arguments.sDefaultValue>
                <cfset returnValue = true>
            </cfif>
        </cfif>

        <cfreturn returnValue />
    </cffunction>

	<cffunction name="getProgramJSON" access="remote" output="false" returnformat="JSON">
		<cfargument name="programId" type="numeric" required="true" />
        <cfargument name="bMarketPrice" type="boolean" required="false" default="0" />
        <cfargument name="bProdRateItemDesc" type="boolean" required="false" default="0" />
        <cfargument name="includeGroupMembers" type="Numeric" required="false" default="0" />
        <cfargument name="payeeType" type="string" required="false" default="" />
        <cfargument name="fromBillback" type="numeric" required="false" default="0" />
        <cfargument name="bNewRateMP" type="Boolean" required="false" default="0" />
		<cfargument name="bLowerCase" type="boolean" required="false" default="0" />
		<cfscript>
			var local.prg = '';
			var local.jsonData = '';
			local.prg = getProgram(arguments.programId, arguments.bMarketPrice, arguments.bProdRateItemDesc, arguments.includeGroupMembers, arguments.payeeType, arguments.fromBillback, arguments.bNewRateMP);
            if(arguments.bLowerCase) { local.prg = application.util.struct.structSortLowerCase(local.prg); }
			local.jsonData = serializeJSON(local.prg, "struct");
		</cfscript>

		<cfreturn local.jsonData/>
	</cffunction>

    <cffunction name="getProgram" output="false" returntype="struct" access="remote" hint="return the program object Program.vos.Program">
        <cfargument name="programId" type="Numeric" required="true" />
        <cfargument name="bMarketPrice" type="boolean" required="false" default="0" />
        <cfargument name="bProdRateItemDesc" type="boolean" required="false" default="0" />
        <cfargument name="includeGroupMembers" type="Numeric" required="false" default="0" />
        <cfargument name="payeeType" type="string" required="false" default="" />
        <cfargument name="fromBillback" type="numeric" required="false" default="0" />
        <cfargument name="bNewRateMP" type="Boolean" required="false" default="0" />

        <cfscript>
            //set local variables
            var nProgramId              = "";
            var iMarketPriceListId      = 0;
            var qReturnProgram          = "";
            var stData                  = structNew();
            var arrComponent            = ArrayNew(1);
            var arrComponentType        = ArrayNew(1);
            var bGetMarketPrice         = 0;
            var bGetProdRateItemDesc    = 0;
            var strPayeeType            = "";
            var nRetToBillback          = 0;

            //assign local variables
            nProgramId              = arguments.programId;
            bGetMarketPrice         = arguments.bMarketPrice;
            bGetProdRateItemDesc    = arguments.bProdRateItemDesc;
            strPayeeType            = arguments.payeeType;
            nRetToBillback          = arguments.fromBillback;

            //if MP load data from differnt place.  The Flag determines if we are editing program rates or Market Price list rates
            if(bGetMarketPrice)
            {
                stData = getProgramMarketPrice(nProgramId);
            }
            else
            {
                stData = getProgramRate(nProgramId, bGetProdRateItemDesc, arguments.includeGroupMembers, strPayeeType, nRetToBillback,arguments.bNewRateMP);
            }

            return stData;

        </cfscript>

    </cffunction>

    <cffunction name="getProgramRate" output="false" returntype="struct" access="private" hint="return the program object Program.vos.Program to the local getProgram() function">
        <cfargument name="programId" type="Numeric" required="true" />
        <cfargument name="bProdRateItemDesc" type="boolean" required="false" default="0" />
        <cfargument name="includeGroupMembers" type="Numeric" required="false" default="0" />
        <cfargument name="payeeType" type="string" required="false" default="" />
        <cfargument name="fromBillback" type="numeric" required="false" default="0" />
        <cfargument name="bNewRateMP" type="Boolean" required="false" default="0" />
        <cfscript>
            //set local variables
            var nProgramId          = "";
            var qReturnProgram      = "";
            var stData              = structNew();
            var stPrdAttr           = structNew();
            var arrPrdAttr          = ArrayNew(1);
            var arrComponent        = ArrayNew(1);
            var arrCustomers        = ArrayNew(1);
            var arrComponentType    = ArrayNew(1);
            var idxRow              = "";
            var arrDistributors     = ArrayNew(1);
            var arrOperators        = ArrayNew(1);
            var qGetDistributors    = "";
            var qGetOperators       = "";
            var strPayeeType        = "";
            var bMarketPriceTemplate = JavaCast("boolean",false );
            var nRetToBillback      = 0;
            var strConversionFactor = 0;
            var bHasConversionFactor = JavaCast("boolean",false);
            //var objDistributorManager         = CreateObject("component","mvc.Models.Distributor.DistributorSearchService");

            var qGroupsInTemplate = QueryNew('x');
            //assign local variables
            nProgramId      = arguments.programId;
            strPayeeType    = arguments.payeeType;
            nRetToBillback  = arguments.fromBillback;

            qPrgTemplate = objTemplateManager.getProgramTemplate(nProgramID);
            stTemplate = getTemplate(qPrgTemplate);

            qReturnProgram      = objProgram.getProgramInfo(nProgramId,1,nRetToBillback);
            arrComponent        = objComponentManager.getComponent(nProgramId,arguments.bProdRateItemDesc,0,arguments.includeGroupMembers, strPayeeType, nRetToBillback,arguments.bNewRateMP);

        //  if(getTemplateMultiPrdAttrGroups()){
                qGetDistributors = objProgramTemplateManager.getDistributors(nProgramId, 0, 0,0);
                arrDistributors = getCustomerDataStruct(qGetDistributors);
        //  }

            qGetOperators = objProgramTemplateManager.getOperators(nProgramId);
            arrOperators    = getOperatorDataStruct(qGetOperators);

            if(qPrgTemplate.Market_Price){
                bMarketPriceTemplate = JavaCast("boolean",true );
            }

            if(qPrgTemplate.Currency_Conversion_Factor){
                strConversionFactor = qPrgTemplate.Conversion_Factor;
                if (strConversionFactor neq 0){
                    bHasConversionFactor = JavaCast("boolean",true);
                }
            }

            arrPrdAttr = getGroupsInTemplate(qPrgTemplate.First_Parent_Id,qPrgTemplate.Group_Deal);
            //dmp(arrPrdAttr);

            //arrCustomers = objDistributorManager.getDistributors(nProgramId,'Rates');

            //Loop over query object and build the prodRate object
            for (idxRow = 1; idxRow LTE qReturnProgram.RecordCount; idxRow = (idxRow + 1))
            {
                if(qReturnProgram["Discount_Fixed_Prices"][idxRow]){
                    ArrayAppend(arrComponentType, 1);
                }
                if(qReturnProgram["Discount_Rebates"][idxRow]){
                    ArrayAppend(arrComponentType, 2);
                }
                if(qReturnProgram["Discount_Lump_Sums"][idxRow]){
                    ArrayAppend(arrComponentType, 3);
                }
                dots = '';
                if(LEN(qReturnProgram.contract_title) > 125){
                    dots = '... ';
                }
                stData["__type__"] = "mvc.Models.Program.Component.vos.Program";
                stData["programId"] = nProgramId;
                stData["title"] = LEFT(qReturnProgram["contract_title"][idxRow],125);
                stData["number"] = qReturnProgram["contract_number"][idxRow];
                stData["startDate"] = qReturnProgram["Contract_Start_Date"][idxRow];
                stData["endDate"] = qReturnProgram["Contract_End_Date"][idxRow];
                stData["components"] = arrComponent;
                stData["componentType"] = arrComponentType;
                stData["bMarketPriceTemplate"] = bMarketPriceTemplate;
                stData["arrPrdAttr"] = arrPrdAttr;
                stData["arrCustomers"] = arrCustomers;
                stData["conversionFactor"] = strConversionFactor;
                stData["bHasConversionFactor"] = bHasConversionFactor;
                stData["bRevision"] = qReturnProgram["Is_a_Revision"][idxRow];
                stData["template"] = stTemplate;
            }

            stData["distributors"]  = arrDistributors;
            stData["operators"]     = arrOperators;

            return stData;

        </cfscript>

    </cffunction>

    <cffunction name="getGroupsInTemplate" output="false" returntype="Array" >
        <cfargument name="argFirstParentID" required="true" default="0" type="numeric" />
        <cfargument name="bGroupDeal" required="true" default="0" type="boolean" />
        <cfscript>
            var arrPrdAttr = arrayNew(1);
            var obj = CreateObject("component","components.products.Group.ProductGroupAttributeManager");

            qGroupsInTemplate = obj.getProductGroupAttributesGroupTemplate(active = 1, FirstParentID = argFirstParentID, TemplateFiltersID = 0);

            /*  </cfscript>

                    <cfdump var = "#qGroupsInTemplate#" output="c:\dump.log" />
                <cfscript>*/

            for (idxRow = 1; idxRow LTE qGroupsInTemplate.RecordCount; idxRow = (idxRow + 1))
            {
                if(qGroupsInTemplate["PG_Flag"][idxRow] == 0  && ((qGroupsInTemplate["ALLOW_IN_GROUP_SEARCH"][idxRow] == 1 && bGroupDeal == 1) || (qGroupsInTemplate["ALLOW_IN_SEARCH"][idxRow] == 1 && bGroupDeal == 0))  ){
                    stPrdAttr["__type__"] = "mvc.Models.Item.vos.ProductAttr";
                    stPrdAttr["active"] = qGroupsInTemplate["ACTIVE"][idxRow];
                    stPrdAttr["allowFilter"] = qGroupsInTemplate["ALLOW_FILTER"][idxRow];
                    stPrdAttr["allowInGroupSearch"] = qGroupsInTemplate["ALLOW_IN_GROUP_SEARCH"][idxRow];
                    stPrdAttr["allowInSearch"] = qGroupsInTemplate["ALLOW_IN_SEARCH"][idxRow];
                    stPrdAttr["createdDate"] = qGroupsInTemplate["CREATED_DATE"][idxRow];
                    stPrdAttr["groupLevelId"] = qGroupsInTemplate["GROUP_LEVEL_ID"][idxRow];
                    stPrdAttr["groupLevelDesc"] = qGroupsInTemplate["Group_Level_Desc"][idxRow];
                    stPrdAttr["listOrder"] = qGroupsInTemplate["LIST_ORDER"][idxRow];
                    stPrdAttr["pgFlag"] = qGroupsInTemplate["PG_Flag"][idxRow];
                    stPrdAttr["pgGroupType"] = qGroupsInTemplate["PG_GROUP_TYPE"][idxRow];
                    stPrdAttr["productGroupAttributeId"] = qGroupsInTemplate["PRODUCT_GROUP_ATTRIBUTE_ID"][idxRow];
                    stPrdAttr["productGroupAttributeIdField"] = qGroupsInTemplate["PRODUCT_GROUP_ATTRIBUTE_ID_FIELD"][idxRow];
                    stPrdAttr["productGroupAttributeInterfaceField"] = qGroupsInTemplate["PRODUCT_GROUP_ATTRIBUTE_INTERFACE_FIELD"][idxRow];
                    stPrdAttr["productGroupAttributeMasterIdField"] = qGroupsInTemplate["PRODUCT_GROUP_ATTRIBUTE_MASTER_ID_FIELD"][idxRow];
                    stPrdAttr["productGroupAttributeNameField"] = qGroupsInTemplate["PRODUCT_GROUP_ATTRIBUTE_NAME_FIELD"][idxRow];
                    stPrdAttr["productGroupAttributeNumberField"] = qGroupsInTemplate["PRODUCT_GROUP_ATTRIBUTE_NUMBER_FIELD"][idxRow];
                    stPrdAttr["productGroupAttributeSearchSequenceField"] = qGroupsInTemplate["PRODUCT_GROUP_ATTRIBUTE_SEARCH_SEQUENCE_FIELD"][idxRow];
                    stPrdAttr["productGroupAttributeTable"] = qGroupsInTemplate["PRODUCT_GROUP_ATTRIBUTE_TABLE"][idxRow];
                    stPrdAttr["ProductGroupLevelId"] = qGroupsInTemplate["PRODUCT_GROUP_LEVEL_ID"][idxRow];
                    stPrdAttr["searchDp"] = ArrayNew('1');
                    ArrayAppend(arrPrdAttr, duplicate(stPrdAttr));
                }
            }

            return arrPrdAttr;
        </cfscript>

    </cffunction>

    <cffunction name="getTemplate" output="false" returntype="Struct" >
        <cfargument name="qTemplate" required="true" default="0" type="query" />
        <cfscript>
            var stTemplate = structNew();
            for (idxRow = 1; idxRow LTE qTemplate.RecordCount; idxRow = (idxRow + 1))
            {
                stTemplate["__type__"] = "mvc.Models.Template.vos.Template";
                stTemplate["templateId"]                = qTemplate["ProgramControl_Panel_Options_ID"][idxRow];
                stTemplate["firstParentId"]             = qTemplate["First_Parent_ID"][idxRow];
                stTemplate["bGroupDeal"]                = qTemplate["Group_Deal"][idxRow];  //JavaCast("boolean",true );
                stTemplate["bFixedGroupDeal"]           = qTemplate["Discount_Fixed_Group_Level"][idxRow];
                stTemplate["bRebateGroupDeal"]          = qTemplate["Discount_Rebates_Group_Level"][idxRow];
                stTemplate["genericType"]               = qTemplate["generic_type"][idxRow];
                stTemplate["createdType"]               = qTemplate["Created_Type"][idxRow];
                stTemplate["templateFiltersId"]         = qTemplate["Template_Filters_Id"][idxRow];
                stTemplate["claimMechanicChanged"]      = qTemplate["Claim_Mechanic_Changed"][idxRow];
                stTemplate["paymentFrequencyChanges"]   = qTemplate["Payment_Frequency_Changes"][idxRow];
                stTemplate["bCustomPrint"]              = qTemplate["Custom_Fixed_Price_Options"][idxRow];
                stTemplate["bCurrencyConversionFactor"] = qTemplate["Currency_Conversion_Factor"][idxRow];
                stTemplate["bEZButtonOn"]               = qTemplate["EZButton_On"][idxRow];
                stTemplate["bDiscountRebateMaxRateOn"]  = qTemplate["Discount_Rebate_Max_Rate_On"][idxRow];
                stTemplate["bEzButtonDefaultShowItemRates"] = qTemplate["EzButton_Default_Show_Item_Rates"][idxRow];
                stTemplate["bEzButtonEnterBeyondMaxRates"]  = qTemplate["EzButton_Enter_Beyond_Max_Rates"][idxRow];
            }

            return stTemplate;
        </cfscript>

    </cffunction>

    <cffunction name="getProgramMarketPrice" output="false" returntype="struct" access="private" hint="return the program object Program.vos.Program to the local getProgram() function">
        <cfargument name="programId" type="Numeric" required="true" />

        <cfscript>
            //set local variables
            var nProgramId          = "";
            var iMarketPriceListId  = 0;
            var qReturnProgram      = "";
            var stData              = structNew();
            var arrComponent        = ArrayNew(1);
            var arrComponentType    = ArrayNew(1);
            var idxRow              = "";
            var arrPrdAttr          = ArrayNew(1);
            var nFirstParentId      = 0;

            //assign local variables
            nProgramId  = arguments.programId;

            //not great -> we now pass in MPId as first arg.
            iMarketPriceListId      = nProgramId;
            objMarketPriceManager   = CreateObject("component","mvc.Models.Template.MarketPriceManager");
            //now go get the Template_Filter_Id based ON the iMarketPriceListId
            nProgramId = objMarketPriceManager.getTemplateFiltersIDBasedOnMP(iMarketPriceListId);

            qReturnProgram      = objMarketPriceManager.getMPHeader(nProgramId);

            arrComponent        = objMarketPriceManager.getMarketPriceLists(nProgramId,'comp',0,iMarketPriceListId);
            //dmp(arrComponent);
            nFirstParentId      = objMarketPriceManager.getFirstParentId(nProgramId);

            arrPrdAttr = getGroupsInTemplate(nFirstParentId,1);

            qPrgTemplate = objMarketPriceManager.getTemplateFilterInfo(nProgramId);
            stTemplate = getTemplate(qPrgTemplate);
            //dmp(qPrgTemplate);
            //arrPrdAttr = getGroupsInTemplate(qPrgTemplate.First_Parent_Id,qPrgTemplate.Group_Deal);
            //Loop over query object and build the Program object
            for (idxRow = 1; idxRow LTE qReturnProgram.RecordCount; idxRow = (idxRow + 1))
            {
                if(qReturnProgram["Discount_Fixed_Prices"][idxRow]){
                    ArrayAppend(arrComponentType, 1);
                }
                if(qReturnProgram["Discount_Rebates"][idxRow]){
                    ArrayAppend(arrComponentType, 2);
                }
                dots = '';
                if(LEN(qReturnProgram.contract_title) > 125){
                    dots = '... ';
                }
                stData["__type__"] = "mvc.Models.Program.Component.vos.Program";
                stData["programId"] = nProgramId;
                stData["title"] = LEFT(qReturnProgram["contract_title"][idxRow],125) & dots;
                stData["number"] = qReturnProgram["contract_number"][idxRow];
                stData["components"] = arrComponent;
                stData["componentType"] = arrComponentType;
                stData["bMarketPriceTemplate"] = qReturnProgram["Market_Price"][idxRow];
                stData["arrPrdAttr"] = arrPrdAttr;
                stData["template"] = stTemplate;
            }

            return stData;

        </cfscript>

    </cffunction>

    <cffunction name="getCustomerDataStruct" output="false" returntype="Array">

        <cfargument name="customerData" type="query" required="true" />

        <cfscript>
            //set local variables
            var qCustomerData   = "";
            var arrRetData      = ArrayNew(1);
            var stData          = structNew();
            var stAddressData   = structNew();
            var idxRow          = "";

            //assign local variables
            qCustomerData   = arguments.customerData;

            //Loop over query object and build the Customer object
            for (idxRow = 1; idxRow LTE qCustomerData.RecordCount; idxRow = (idxRow + 1))
            {
                stData = structNew();
                stData["__type__"] = "mvc.Models.Entity.vos.Customer";
                stData["shipTo"] = qCustomerData["Shr_Ship_To"][idxRow];
                stData["name"] = qCustomerData["name"][idxRow];
                stData["customerId"] = qCustomerData["BSA_Foodservice_Customers_ID"][idxRow];
                stAddressData = structNew();
                stAddressData["__type__"] = "mvc.Models.Entity.vos.Address";
                stAddressData["addressLine1"] = qCustomerData["Address_1"][idxRow];
                stAddressData["addressLine2"] = "";
                stAddressData["city"] = qCustomerData["City"][idxRow];
                stAddressData["state"] = qCustomerData["State"][idxRow];
                stAddressData["zipCode"] = qCustomerData["zipcode"][idxRow];
                stData["address"] = stAddressData;
                ArrayAppend(arrRetData, duplicate(stData));
            }

            return arrRetData;
        </cfscript>

    </cffunction>

    <cffunction name="getOperatorDataStruct" output="false" returntype="Array">

        <cfargument name="operatorData" type="query" required="true" />

        <cfscript>
            //set local variables
            var qOperatorData   = "";
            var arrRetData      = ArrayNew(1);
            var stData          = structNew();
            var stAddressData   = structNew();
            var idxRow          = "";

            //assign local variables
            qOperatorData   = arguments.operatorData;

            //Loop over query object and build the Customer object
            for (idxRow = 1; idxRow LTE qOperatorData.RecordCount; idxRow = (idxRow + 1))
            {
                stData = structNew();
                stData["__type__"] = "mvc.Models.Entity.vos.Operator";
                stData["ID"] = qOperatorData["BSA_Operator_ID"][idxRow];
                stData["name"] = qOperatorData["Operator_Name"][idxRow];
                stAddressData = structNew();
                stAddressData["__type__"] = "mvc.Models.Entity.vos.Address";
                stAddressData["addressLine1"] = qOperatorData["Operator_Address"][idxRow];
                stAddressData["addressLine2"] = "";
                stAddressData["city"] = qOperatorData["Operator_City"][idxRow];
                stAddressData["state"] = qOperatorData["Operator_State"][idxRow];
                stAddressData["zipCode"] = qOperatorData["Operator_Zip"][idxRow];
                stData["address"] = stAddressData;
                ArrayAppend(arrRetData, duplicate(stData));
            }

            return arrRetData;
        </cfscript>

    </cffunction>

    <cffunction name="Call_Pullback_Details_For_CorpRevisions" output="false">
     <cfargument name="contract_main_id" required="true" default="" type="string" />
        <!--- Nightly Job Now ececutes this: Common_For_Schedule -> Update_Pullback_Details_For_CorpRevisions_Caller --->
      <!---<CFTHREAD ACTION="RUN" NAME="PB_#arguments.contract_main_id#" p="#arguments.contract_main_id#" >
        <cfquery name="UpdatePullbackDetails" datasource="#application.datasource#">
            exec Update_Pullback_Details_For_CorpRevisions <cfqueryparam value="#p#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>
      </CFTHREAD>--->
    </cffunction>

    <!--- Setting to show/hide columns in program search grid --->
    <cffunction name="getProgramLevelSettings" output="false" returntype="query">
        <cfset useLakebaseForqgetProgramLevelSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users_settings")>
<cfif useLakebaseForqgetProgramLevelSettings>
	<cftry>
		<cfset qgetProgramLevelSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users_settings", {
				"user_id" = "eq.#request.AccessStructure.Company_Main_ID#",
				"select" = "display_trade_dollars,display_payment_dollars,display_volume,display_trade_dollars_type,display_volume_type,display_operator_info"
			}), "display_trade_dollars,display_payment_dollars,display_volume,display_trade_dollars_type,display_volume_type,display_operator_info"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetProgramLevelSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetProgramLevelSettings>
<cfquery NAME="qgetProgramLevelSettings" datasource="#application.datasource#">
        SELECT   Display_Trade_Dollars,Display_Payment_Dollars, Display_Volume,
            Display_Trade_Dollars_Type, Display_Volume_Type,Display_Operator_Info
        FROM    _Users_Settings
        WHERE   User_ID ='#request.AccessStructure.Company_Main_ID#'
        </cfquery>
</cfif>
        <cfreturn qgetProgramLevelSettings>
    </cffunction>

    <!--- Request is from flex to filter programs by budget classes (Function for Adobe Flex Program Search)--->
    <cffunction name="getProgramBudgetClasses" output="false" returntype="query">
        <cfargument name="budgetClassID" required="true" default="" type="string" />

        <cfquery NAME="qgetProgramBudgetClasses" datasource="#application.datasource#">
        <!--- Dev Note:50324. Modified datatype to varchar for flex program search. --->
        SELECT  DISTINCT CAST(cm.Contract_Main_ID As varchar(10)) As Contract_Main_ID
        FROM  Contract_Main cm
        INNER JOIN Budget_Program_Selection s
        ON          s.Program_ID = cm.Contract_Main_ID
        INNER JOIN Budget b
        ON          b.Budget_ID = s.Budget_ID
        WHERE b.Budget_Class_ID IN ( <cfqueryparam value="#arguments.budgetClassID#" cfsqltype="CF_SQL_INTEGER" list="true"> )
        </cfquery>
        <cfreturn qgetProgramBudgetClasses>
    </cffunction>

        <!--- Request is from AG Grid to filter programs by budget classes --->
    <cffunction name="getSearchByBudgetClasses" output="false" returntype="void">
        <cfargument name="budgetClassID" required="true" default="" type="string" />

        <cfquery name="local.delTbl" datasource="#application.datasource#">
            IF OBJECT_ID('tempdb..##tmp_Budget_Programs_List') IS NOT NULL
            DROP TABLE ##tmp_Budget_Programs_List
        </cfquery>

        <cfquery NAME="qgetProgramBudgetClasses" datasource="#application.datasource#">
        SELECT  DISTINCT cm.Contract_Main_ID
        INTO ##tmp_Budget_Programs_List
        FROM  Contract_Main cm
        INNER JOIN Budget_Program_Selection s
        ON          s.Program_ID = cm.Contract_Main_ID
        INNER JOIN Budget b
        ON          b.Budget_ID = s.Budget_ID
        <!--- DO NOT USE CFQUERYPARAM AS A TEMP TABLE IS BEING USED --->
        WHERE b.Budget_Class_ID IN (#arguments.budgetClassID#)
        </cfquery>
    </cffunction>

    <cffunction name="getVolumeAndTradeSpendAndPaymentDollars" output="false" returntype="void">
        <cfargument name="contractNumber" required="false" type="string" default="" />
        <cfargument name="contractMainID" required="false" type="string" />
        <cfargument name="plannerID" required="false" type="numeric" default="0" />
        <cfargument name="ignoreBudget" required="false" type="boolean" default="0" />

        <cfset var appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

            <!--- Delete the temp tables in a separate query. --->
            <cfquery name="local.delTbl" datasource="#application.datasource#">
                IF OBJECT_ID('tempdb..##tmp_programs') IS NOT NULL
                DROP TABLE  ##tmp_programs

                IF OBJECT_ID('tempdb..##PrgVersionlevelTradeSpendAndVolume') IS NOT NULL
                DROP TABLE  ##PrgVersionlevelTradeSpendAndVolume

                IF OBJECT_ID('tempdb..##TotalPrgTradeSpendAndVolume') IS NOT NULL
                DROP TABLE  ##TotalPrgTradeSpendAndVolume

                IF OBJECT_ID('tempdb..##tmpUniqueEffectiveDatesPerProgram') IS NOT NULL
                DROP TABLE  ##tmpUniqueEffectiveDatesPerProgram
            </cfquery>

            <cfquery name="qGetVolumeAndTradeSpendAndPaymentDollars" datasource="#application.datasource#">
                <!--- Populate the program list --->
                SELECT  CM.Contract_Number,
                    CM.Contract_Main_ID,
                    CM.ProgramType_ID,
                    CM.Effective_Start_Date,
                    CM.Effective_End_Date,
                    CM.Contract_Start_Date,
                    CM.Contract_End_Date,
                    Max_Effective_End_Date = MAX(CM.Effective_End_Date) OVER(PARTITION BY CM.Contract_Number),
                    Min_Effective_Start_Date = MIN(CM.Effective_Start_Date) OVER(PARTITION BY CM.Contract_Number),
                    Units_of_Measure.Abbreviation As volume_uom
                INTO ##tmp_programs
                FROM  Contract_Main CM
                INNER JOIN  Units_of_Measure
                ON CM.Contract_Quantity_UOM_IDX = Units_of_Measure.Unit_Of_Measure_ID
                WHERE   1=1
                <cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1 AND isDefined("arguments.contractMainID")>
                AND CM.contract_main_id = #arguments.contractMainID#
                <cfelse>
                    <cfif isDefined("arguments.contractNumber") AND arguments.contractNumber neq "">
                        AND CM.contract_number = '#arguments.contractNumber#'
                    </cfif>
                </cfif>
                <cfif arguments.plannerID neq 0>
                    AND CM.Planner_ID = #arguments.plannerID#
                </cfif>


                <!---
                Get all program versions here. No need to check "approval = 1". "committed_dollars" and "payment_dollars" require all versions to be returned.
                "volume" and "program_spend" (any value coming from the program) does need other conditions, which are added below in the code.
                --->

                <!---- Add an "incremental integer" (PrgVersionlevelTradeSpendAndVolume_ID). This is useful in finding duplicates. --->
                CREATE TABLE ##PrgVersionlevelTradeSpendAndVolume(
                    PrgVersionlevelTradeSpendAndVolume_ID int IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
                    Contract_Number Nvarchar(255),
                    Contract_Main_ID int,
                    Effective_Start_Date datetime,
                    Effective_End_Date datetime,
                    Min_Effective_Start_Date datetime,
                    Max_Effective_End_Date datetime,
                    Estimated_committed_dollar decimal(20,4),
                    Forecasted_to_go_committed_dollar decimal(20,4),
                    Estimated_program_Spend_Non_Lumpsum decimal(20,4),
                    Forecasted_to_go_program_Spend_Non_Lumpsum decimal(20,4),
                    Estimated_Program_Spend_Lumpsum decimal(20,4),
                    Forecasted_to_go_Program_Spend_Lumpsum decimal(20,4),
                    actual_dollar decimal(20,4),
                    Contract_Quantity bigint,
                    volume_uom varchar(5)
                )

                <cfif appSettings.getBudgetsFunctionalityOn() and arguments.ignoreBudget eq 0>
                <!--- Get values from all the program versions --->
                <!--- When "budget functionality" is ON, AND the program template is associated to a budget,
                then "trade spend" and "payment dollars" come from the budget.
                Here "trade spend" is "committed_dollar" and "payment dollars" is "actual_dollar".
                --->
                INSERT INTO ##PrgVersionlevelTradeSpendAndVolume WITH (TABLOCK)
                (Contract_Number,Contract_Main_ID,Effective_Start_Date,Effective_End_Date,Min_Effective_Start_Date,Max_Effective_End_Date,
                Estimated_Committed_Dollar,Forecasted_To_Go_Committed_Dollar,
                Estimated_program_Spend_Non_Lumpsum,Forecasted_to_go_program_Spend_Non_Lumpsum,
                Estimated_Program_Spend_Lumpsum,Forecasted_To_Go_Program_Spend_Lumpsum,actual_dollar,volume_uom
                )
                <!---
                NOTE: Dev Note: (51590) DO NOT USE "DISTINCT" CLAUSE HERE AS "Budget_Position_Program" AND "Budget_Distributor_Program"
                TABLES MAY HAVE MULTIPLE RECORDS (PROGRAM AND AMOUNT COMBINATION), WHICH NEED TO BE INCLUDED.
                --->
                SELECT CM.Contract_Number,
                    CM.Contract_Main_ID,
                    CM.Effective_Start_Date,
                    CM.Effective_End_Date,
                    CM.Min_Effective_Start_Date,
                    CM.Max_Effective_End_Date,
                    ISNULL(pg.committed_Dollar, 0) + ISNULL(dg.committed_Dollar, 0) As Estimated_committed_dollar,
                    <!--- PROGRAM VERSION IS ALREADY COMPLETED --->
                    CASE WHEN CM.Effective_End_Date < Getdate()
                                THEN 0
                        <!--- PROGRAM VERSION WILL START IN THE FUTURE - THE FULL ESTIMATED COMMITTED DOLLARS IS ALSO THE FORECASTED TO GO COMMITTED DOLLARS --->
                        WHEN  CM.Effective_Start_Date >= Getdate()
                                THEN
                                    CAST(((ISNULL(pg.committed_Dollar, 0) + ISNULL(dg.committed_Dollar, 0))
                                    *
                                    CAST(DATEDIFF(D, CM.Effective_Start_Date, CM.Effective_End_Date) + 1 as float)
                                    / CAST(DATEDIFF(D, CM.Contract_Start_Date, CM.Contract_End_Date) + 1 as float)
                                    ) as decimal(20, 4))
                        <!--- WE ARE IN-BETWEEN A PROGRAM VERSION - FORECASTED TO GO COMMITTED DOLLARS IS CALCULATED BASED ON THE REMAINING DAYS OF THE VERSION  --->
                        ELSE
                                    CAST(((ISNULL(pg.committed_Dollar, 0) + ISNULL(dg.committed_Dollar, 0))
                                    *
                                    CAST(DATEDIFF(D, getDate(), CM.Effective_End_Date) + 1 as float)
                                    / CAST(DATEDIFF(D, CM.Contract_Start_Date, CM.Contract_End_Date) + 1 as float)
                                    ) as decimal(20, 4))
                    END
                        As Forecasted_to_go_committed_dollar,
                    null As Estimated_program_Spend_Non_Lumpsum,
                    null As Forecasted_to_go_program_Spend_Non_Lumpsum,
                    null As Estimated_Program_Spend_Lumpsum,
                    null As Forecasted_to_go_Program_Spend_Lumpsum,
                    ISNULL(pg.actual_Dollar, 0) + ISNULL(dg.actual_Dollar, 0) As actual_dollar,
                    CM.volume_uom
                FROM  ##tmp_programs CM
                LEFT JOIN Budget_Position_Program pg
                ON CM.Contract_Number = pg.Contract_Number
                AND CM.Contract_Main_ID = pg.Contract_Main_ID
                LEFT JOIN Budget_Distributor_Program dg
                ON CM.Contract_Number = dg.Contract_Number
                AND CM.Contract_Main_ID = dg.Contract_Main_ID
                INNER JOIN Program_Control_Panel_Options  pcpo
                ON pcpo.ProgramControl_Panel_Options_ID = CM.ProgramType_ID
                <!---
                program template is associated to a budget.
                --->
                AND EXISTS
                (
                SELECT TOP 1 1
                FROM Budget_Template_Mappings btm
                WHERE pcpo.First_Parent_ID = btm.Template_First_Parent_ID
                )
                </cfif>

                <!--- Get values from all program versions separately. --->
                <!--- When program template is not associated to a budget:
                "Program_Spend_Non_Lumpsum" and "Program_Spend_Lumpsum" is populated below, only to get used
                in the "##TotalPrgTradeSpendAndVolume" table for all the versions of the program combined ("total program value").
                "payment dollars" is never calculated at the version level. It is always at the "total program value" level.
                --->
                INSERT INTO ##PrgVersionlevelTradeSpendAndVolume WITH (TABLOCK)
                (Contract_Number,Contract_Main_ID,Effective_Start_Date,Effective_End_Date,Min_Effective_Start_Date,Max_Effective_End_Date,
                Estimated_Committed_Dollar,Forecasted_To_Go_Committed_Dollar,
                Estimated_program_Spend_Non_Lumpsum,Forecasted_to_go_program_Spend_Non_Lumpsum,
                Estimated_Program_Spend_Lumpsum,Forecasted_To_Go_Program_Spend_Lumpsum,actual_dollar,volume_uom
                )
                SELECT      CM.Contract_Number,
                        CM.Contract_Main_ID,
                        CM.Effective_Start_Date,
                        CM.Effective_End_Date,
                        CM.Min_Effective_Start_Date,
                        CM.Max_Effective_End_Date,
                        null As estimated_committed_dollar,
                        null As forecasted_to_go_committed_dollar,

                        Estimated_Program_Spend_Non_Lumpsum = CAST((aux.Program_Spend_Non_Lumpsum
                        *
                        CAST(DATEDIFF(D, CM.Effective_Start_Date, CM.Effective_End_Date) + 1 as float)
                        / CAST(DATEDIFF(D, CM.Contract_Start_Date, CM.Contract_End_Date) + 1 as float)
                        ) as decimal(20, 4)),
                        Forecasted_To_Go_Program_Spend_Non_Lumpsum =
                        <!--- PROGRAM VERSION IS ALREADY COMPLETED --->
                        CASE WHEN CM.Effective_End_Date < Getdate()
                                THEN 0
                        <!--- PROGRAM VERSION WILL START IN THE FUTURE - THE FULL ESTIMATED "NON LUMPSUM TRADE SPEND" IS ALSO THE FORECASTED TO GO "NON LUMPSUM TRADE SPEND" --->
                        WHEN  CM.Effective_Start_Date >= Getdate()
                                THEN
                                    CAST((aux.Program_Spend_Non_Lumpsum
                                    *
                                    CAST(DATEDIFF(D, CM.Effective_Start_Date, CM.Effective_End_Date) + 1 as float)
                                    / CAST(DATEDIFF(D, CM.Contract_Start_Date, CM.Contract_End_Date) + 1 as float)
                                    ) as decimal(20, 4))
                        <!--- WE ARE IN-BETWEEN A PROGRAM VERSION - FORECASTED TO GO "NON LUMPSUM TRADE SPEND" IS CALCULATED BASED ON THE REMAINING DAYS OF THE VERSION  --->
                        ELSE
                                    CAST((aux.Program_Spend_Non_Lumpsum
                                    *
                                    CAST(DATEDIFF(D, getDate(), CM.Effective_End_Date) + 1 as float)
                                    / CAST(DATEDIFF(D, CM.Contract_Start_Date, CM.Contract_End_Date) + 1 as float)
                                    ) as decimal(20, 4))
                        END,
                        aux.Program_Spend_Lumpsum As Estimated_Program_Spend_Lumpsum,
                        Forecasted_To_Go_Program_Spend_Lumpsum =
                        CASE
                            <!--- ONLY FOR THE LAST VERSION OF THE PROGRAM, WHERE EFFECTIVE DATES ARE POPULATED --->
                            WHEN CM.Effective_End_Date = CM.Max_Effective_End_Date
                                THEN
                                    <!--- PROGRAM VERSION IS ALREADY COMPLETED --->
                                    CASE WHEN CM.Effective_End_Date < Getdate()
                                        THEN 0
                                      <!--- PROGRAM VERSION WILL START IN THE FUTURE - THE FULL ESTIMATED "LUMPSUM TRADE SPEND" IS ALSO THE FORECASTED TO GO "LUMPSUM TRADE SPEND" --->
                                     WHEN  CM.Min_Effective_Start_Date >= Getdate()
                                        THEN
                                            CAST((aux.Program_Spend_Lumpsum
                                            *
                                            CAST(DATEDIFF(D, CM.Effective_Start_Date, CM.Effective_End_Date) + 1 as float)
                                            / CAST(DATEDIFF(D, CM.Contract_Start_Date, CM.Contract_End_Date) + 1 as float)
                                            ) as decimal(20, 4))
                                    <!--- WE ARE IN-BETWEEN A PROGRAM VERSION - FORECASTED TO GO "LUMPSUM TRADE SPEND" IS CALCULATED BASED ON THE REMAINING DAYS OF THE VERSION  --->
                                    ELSE
                                            CAST((aux.Program_Spend_Lumpsum
                                            *
                                            CAST(DATEDIFF(D, getDate(), CM.Effective_End_Date) + 1 as float)
                                            / CAST(DATEDIFF(D, CM.Contract_Start_Date, CM.Contract_End_Date) + 1 as float)
                                            ) as decimal(20, 4))
                                    END
                            ELSE 0
                        END,
                        null As actual_dollar,
                        CM.volume_uom
                FROM ##tmp_programs CM
                INNER JOIN Contract_Main_Aux_Data aux
                ON          aux.Contract_Main_ID = CM.Contract_Main_ID
                INNER JOIN Contract_Main CM1
                ON          CM.Contract_Main_ID = CM1.Contract_Main_ID
                <!--- Program spend is only calculated for versions which are approved and effective_start_date is not null.
                In fact, all program values need this filter. Budget values (committed_dollar and payment_dollar) do not need it.
                --->
                WHERE CM1.Approved = 1
                AND   CM1.Effective_Start_Date IS NOT NULL
                <!---
                program template is not associated to a budget,
                as the program does not exist in "##PrgVersionlevelTradeSpendAndVolume"
                --->
                AND NOT EXISTS
                (
                SELECT TOP 1 1
                FROM ##PrgVersionlevelTradeSpendAndVolume tmpprg
                WHERE CM.Contract_Main_ID = tmpprg.Contract_Main_ID
                )

                <!--- Dev Note: (51590)
                Note 1: Earlier, Contract_Quantity was being populated in the "##tmp_programs" table. This causes an issue with
                the volume doubling/trebling etc, as the "##PrgVersionlevelTradeSpendAndVolume" had multiple records for the same version of the
                program due to join with  "Budget_Position_Program" AND "Budget_Distributor_Program" tables.
                So, "Contract_Quantity" (volume) needs to be populated here and we only need to populate it once for every version,
                provided their effective dates are different. IF a program was revised with no date change, the effective date does
                not change and so we do need to include volume for both the versions.
                Note: "Contract_Quantity" (Volume) is calculated based ON version dates of the program.
                For "Total Program value" (combined volume of all the versions with different effectuve dates), we need to SUM the volume
                for all those versions.
                BELOW WE ARE JUST FINDING PROGRAM VERSONS WITH UNIQUE EFFECTIVE DATES AND ONLY POPULATING VOLUME FOR THOSE PROGRAM VERSIONS.

                NOTE 2:(51778) We realized that committed_dollars and payment_dollars need to be calculated for all versions and volume should
                only be calculated for versions which are approved and effective_start_date is not null.
                That was another reason, volume logic needed to be written separately here.
                --->
                SELECT DISTINCT tb1.PrgVersionlevelTradeSpendAndVolume_ID
                INTO ##tmpUniqueEffectiveDatesPerProgram
                FROM ##PrgVersionlevelTradeSpendAndVolume tb1,##PrgVersionlevelTradeSpendAndVolume tb2
                WHERE tb1.Contract_Number = tb2.Contract_Number
                AND tb1.Effective_Start_Date = tb2.Effective_Start_Date
                AND tb1.Effective_End_Date = tb2.Effective_End_Date
                AND tb1.PrgVersionlevelTradeSpendAndVolume_ID < tb2.PrgVersionlevelTradeSpendAndVolume_ID

                <!--- Add volume below.
                Note: Below logic converts volume for the length of the program ("Contract_Quantity" stores the program volume)
                into volume based ON length of effective dates.
                --->
                UPDATE ##PrgVersionlevelTradeSpendAndVolume
                SET Contract_Quantity = CAST((CM.Contract_Quantity
                        *
                        CAST(DATEDIFF(D, CM.Effective_Start_Date, CM.Effective_End_Date) + 1 as float)
                        / CAST(DATEDIFF(D, CM.Contract_Start_Date, CM.Contract_End_Date) + 1 as float)
                        ) as decimal(20, 0))
                FROM ##PrgVersionlevelTradeSpendAndVolume
                INNER JOIN Contract_Main CM
                ON ##PrgVersionlevelTradeSpendAndVolume.Contract_Main_ID = CM.Contract_Main_ID
                <!--- Volume is only calculated for versions which are approved and effective_start_date is not null.
                In fact, all program values need this filter. Budget values (committed_dollar and payment_dollar) do not need it.
                --->
                WHERE CM.Approved = 1
                AND   CM.Effective_Start_Date IS NOT NULL
                AND PrgVersionlevelTradeSpendAndVolume_ID
                NOT IN
                (
                /* This table contains all duplicate records with the same contract_number and effective_start_date and effective_end_date.
                We need to populate contract_quantity only once for every combination of contract_number and effective_start_date
                and effective_end_date. "NOT IN" will make sure of that.
                Note: ##PrgVersionlevelTradeSpendAndVolume having duplicate records is fine. That happens due to join with
                "Budget_Position_Program" AND "Budget_Distributor_Program" tables.
                */
                SELECT PrgVersionlevelTradeSpendAndVolume_ID
                FROM ##tmpUniqueEffectiveDatesPerProgram
                )

                <!--- Sum values at program level (all versions) --->
                SELECT TradeSpend.Contract_Number,
                          <!--- When committed dollars are null (program template is not associated to a budget),
                            then get the "total program value" from the program's trade spend.
                           --->
                          CASE
                          WHEN SUM(TradeSpend.estimated_committed_dollar) IS NULL
                          THEN
                              ISNULL(CAST(
                              SUM(ISNULL(Estimated_Program_Spend_Non_Lumpsum, 0))
                              +
                              SUM(ISNULL((CASE
                                          WHEN TradeSpend.Effective_End_Date = TradeSpend.Max_Effective_End_Date
                                            THEN TradeSpend.Estimated_Program_Spend_Lumpsum
                                            ELSE 0
                                          END), 0))
                              as DECIMAL(20, 2)),0)
                          ELSE
                          <!--- When committed dollars are not null (program template is associated to a budget),
                          then get the "total program value" from the budget.
                          --->
                          <!--- USE SUM() FOR "TOTAL PROGRAM VALUE" FOR TRADE SPEND $. committed_dollar is TRADE SPEND $. --->
                          SUM(CAST(TradeSpend.estimated_committed_dollar AS DECIMAL(20,4)))
                          END
                          AS estimated_program_spend,

                          CASE
                          WHEN SUM(TradeSpend.forecasted_to_go_committed_dollar) IS NULL
                          THEN
                              ISNULL(CAST(
                              SUM(ISNULL(Forecasted_To_Go_Program_Spend_Non_Lumpsum, 0))
                              +
                              SUM(ISNULL(TradeSpend.Forecasted_To_Go_Program_Spend_Lumpsum, 0))
                              as DECIMAL(20, 2)),0)
                          ELSE
                          <!--- When committed dollars are not null (program template is associated to a budget),
                          then get the "total program value" from the budget.
                          --->
                          <!--- USE SUM() FOR "TOTAL PROGRAM VALUE" FOR TRADE SPEND $. committed_dollar is TRADE SPEND $. --->
                          SUM(CAST(TradeSpend.forecasted_to_go_committed_dollar AS DECIMAL(20,4)))
                          END
                          AS forecasted_to_go_program_spend,
                          <!--- "total program value" for the payment dollars. It is never for the "version" only. --->
                          <!--- USE SUM() FOR "TOTAL PROGRAM VALUE" FOR PAYMENT $. actual_dollar is PAYMENT $. --->
                          SUM(CAST(TradeSpend.actual_dollar AS DECIMAL(20,4))) as actual_dollar,
                          <!--- USE SUM() FOR "TOTAL PROGRAM VALUE", i.e. the combined value of all the program versions. Contract_Quantity is VOLUME. --->
                          SUM(Contract_Quantity) as Contract_Quantity,
                          volume_uom

                INTO  ##TotalPrgTradeSpendAndVolume
                FROM        ##PrgVersionlevelTradeSpendAndVolume TradeSpend
                GROUP BY TradeSpend.Contract_Number,volume_uom
				ORDER BY 1, 2
            </cfquery>
            <!--- This function does not return any value. Since the "##TotalPrgTradeSpendAndVolume" table gets populated, the populated values
            ON the table gets used.
            --->

        </cffunction>

	 <!--- This function is used by AG Grid program search --->
	<cffunction name="getProgramsData" output="false" access="remote" returntype="query">
        <!--- Required parameters: form.user_id, form.profiles_id --->
		<cfparam name="form.action_list"         default="">
		<cfparam name="form.budget_class_list"    default="">
		<cfparam name="form.business_segment"    default="">
		<cfparam name="form.buying_group_list"    default="">
		<cfparam name="form.condition_list"      default="">
		<cfparam name="form.distributor_search"  default="">
		<cfparam name="form.to_date"            default="">
		<cfparam name="form.endRow"             default="999999">
		<cfparam name="form.family_list"         default="">
		<cfparam name="form.item_search"         default="">
		<cfparam name="form.match_type"          default="0">
		<cfparam name="form.operator_search"     default="">
		<cfparam name="form.program_create_list"  default="">
		<cfparam name="form.program_search"      default="">
		<cfparam name="form.rsp_list"            default="">
		<cfparam name="form.show_catalog"        default="0">
		<cfparam name="form.sortColumn"         default="">
		<cfparam name="form.sortOrder"          default="">
		<cfparam name="form.from_date"          default="">
		<cfparam name="form.startRow"           default="0">
		<cfparam name="form.status_list"         default="">
		<cfparam name="form.template_list"       default="">
		<cfparam name="form.user_list"           default="">
		<cfparam name="form.user_position_list"  default="">
		<cfparam name="form.workflow_steps_list"  default="">
		<cfparam name="form.search_type"	default="MainSearch">
		<cfparam name="form.Creating_User_Position"	default="0">
		<cfparam name="form.Include_work_in_progress_below_me"	default="0">
		<cfparam name="form.Include_Operator_In_CSV"	default="0">
		<cfparam name="form.discount_type"      default="">
		<cfparam name="form.fixed_discount_types"      default="">
		<cfparam name="form.rebate_discount_types"      default="">
		<cfparam name="form.lump_sum_discount_types"      default="">
		<cfparam name="form.growth_discount_types"      default="">
		<cfparam name="form.rate_compare"      default="">
		<cfparam name="form.rate_val"      default="">
		<cfparam name="form.rate_uom"      default="">
		<cfparam name="form.refresh_data"      default="">
        <cfparam name="form.fromQP" default="0">

		<!--- If the user is searching for programs from the "list tab". then ignore the other search options from the main search page (search tab) --->
		<cfif form.search_type eq "ListSearch">
			<cfset form.program_search = "">
			<cfset form.distributor_search = "">
			<cfset form.operator_search = "">
			<cfset form.item_search = "">
			<cfset form.status_list = "">
			<cfset form.template_list = "">
			<cfset form.rsp_list = "">
			<cfset form.buying_group_list = "">
			<cfset form.family_list = "">
			<cfset form.condition_list = "">
			<cfset form.workflow_steps_list = "">
			<cfset form.user_list = "">
			<cfset form.user_position_list = "">
			<cfset form.action_list = "">
			<cfset form.budget_class_list = "">
			<cfset form.business_segment = "">
			<cfset form.show_catalog = "">

		<!--- If the user is searching for programs from the "search tab" (Main search page), then ignore the list of programs from the multiple programs search tab (list tab) --->
		<!---	<cfelseif form.search_type eq "MainSearch">
		<cfset form.program_create_list = ""> --->
		</cfif>


        <!--- Delete the temp tables in a separate query. While testing code, there are no issues that way, as
        the prevents the "table already exists" error.
        --->
        <cfquery name="local.delTbl" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmp_Effective_Dates') IS NOT NULL
				DROP TABLE ##tmp_Effective_Dates

			IF OBJECT_ID('tempdb..##tmp_program_create_list') IS NOT NULL
				DROP TABLE ##tmp_program_create_list

			IF OBJECT_ID('tempdb..##tmp_search_programs_result') IS NOT NULL
				DROP TABLE ##tmp_search_programs_result

			IF OBJECT_ID('tempdb..##tmp_ClaimMechanics') IS NOT NULL
				DROP TABLE ##tmp_ClaimMechanics

			IF OBJECT_ID('tempdb..##tmpPgmSrch_Program_Operators') IS NOT NULL
				DROP TABLE ##tmpPgmSrch_Program_Operators
        </cfquery>

        <cfscript>
            if (form.from_date neq "")
                form.from_date = dateFormat(form.from_date, 'mm/dd/yyyy');

            if (form.to_date neq "")
                form.to_date = dateFormat(form.to_date, 'mm/dd/yyyy');

            var appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings();
            var forbidType  = appSettings.getForbidAllowProfilesInTemplates();

            if (form.distributor_search neq "")
                form.distributor_search = fullTextStringClean(form.distributor_search);

            if (form.operator_search neq "")
                form.operator_search = fullTextStringClean(form.operator_search);

            if (form.item_search neq "")
                form.item_search = fullTextStringClean(form.item_search);

            if (not structKeyExists(request, "AccessStructure")) {
                request.AccessStructure             = structNew();
                request.AccessStructure.user_id     = form.user_id;
                request.AccessStructure.profiles_id = form.profiles_id;
            }

			/* Change the delimiter to comma from a "new line" character */
			local.program_create_List = replace(form.program_create_list, "#chr(13)##chr(10)#", ",", "all");
			/* Sometimes, instead of "chr(13)chr(10)" ("new line" character), only "chr(10)" gets passed.
			In that case, below line of code will take care of cnanging the delimiter.*/
			local.program_create_List = replace(local.program_create_List, "#chr(10)#", ",", "all");
            local.prgSettings         = getProgramLevelSettings();
			local.end_row             = form.endRow - form.startRow;
        </cfscript>

		<cfif request.AccessStructure.External_Customer_Profile_Access NEQ "1">
		<cfif form.refresh_data neq "1">
			<!--- Check if there is data in log which includes these dates --->
			<cfquery name="local.getSearchLog" datasource="#application.datasource#">
				select	1
				from	Contract_Main_Program_Search_Log
				where	CAST(Process_Date as DATE) = <cfqueryparam cfsqltype="cf_sql_date" value="#dateformat(Now(), 'm/d/yyyy')#" />
				<cfif Trim(form.from_date) neq "">
				and		From_Date <= <cfqueryparam cfsqltype="cf_sql_date" value="#dateformat(FORM.from_date, 'm/d/yyyy')#" />
				<cfelse>
					<cfif IsNumeric(appSettings.getExpiredRecentlyDays())>
					and		From_Date <= DateAdd(d,- #appSettings.getExpiredRecentlyDays()#,getDate())
					</cfif>
				</cfif>
				<cfif Trim(form.to_date) neq "">
				and		To_Date >= <cfqueryparam cfsqltype="cf_sql_date" value="#dateformat(FORM.to_date, 'm/d/yyyy')#" />
				<cfelse>
				and		To_Date = '12/31/9999'
				</cfif>
			</cfquery>
			<!--- If no overlapping log entry found, we need to call SP and refresh data --->
			<cfif not local.getSearchLog.recordCount>
				<cfset form.refresh_data = 1 />
			</cfif>
		</cfif>
		<cfif form.refresh_data eq "1">
			<!---  Call SP to refresh data --->
			<cfstoredproc procedure="USP_getProgramsData" datasource="#application.datasource#">
				<cfprocparam type="In" cfsqltype="cf_sql_date" dbvarname="@p_from_date"	value="#dateformat(form.from_date, 'm/d/yyyy')#" null="#(len(form.from_date) ? false : true)#" />
				<cfprocparam type="In" cfsqltype="cf_sql_date" dbvarname="@p_to_date" value="#dateformat(form.to_date, 'm/d/yyyy')#" null="#(len(form.to_date) ? false : true)#" />
				<cfprocparam type="In" cfsqltype="cf_sql_varchar" dbvarname="@user_id" value="#request.AccessStructure.user_id#" />
			</cfstoredproc>
		</cfif>
		</cfif>

        <!---<cfset local.timer.getClaimMechanics = getTickCount()>--->
<!---        <cfquery name="local.getClaimMechanics" datasource="#application.datasource#">
            SELECT PRC.Claim_Mechanics, CM.Contract_Main_ID
              INTO ##tmp_ClaimMechanics
              FROM Contract_main CM
                    INNER JOIN Program_Rebates_Component PRC ON PRC.Program_ID = CM.Contract_Main_ID
                    INNER JOIN Payment_Type PT ON PT.Payment_Type_ID = PRC.Claim_Mechanics AND (Is_Auto_Pay = 0 AND Restrict_From_Billback = 0 AND Off_Invoice = 0)
             WHERE CM.Deleted = 0
                    AND CM.IsExclusionRevision = 0
                    AND CM.Contract_Status_Type_IDX > 2
                    AND CM.Flagged_As_Purged = 0
                    AND (CM.Force_Expiration_Flag = 0 OR CM.Contract_Status_Type_IDX = 7)
                    <cfif form.from_date neq "" AND form.to_date neq "">
                        AND CM.Contract_Start_Date <= '#DateFormat(form.to_date,"mm/dd/yyyy")#'
                        AND CM.Contract_End_Date >= '#DateFormat(form.from_date,"mm/dd/yyyy")#'
                    <cfelseif form.from_date neq "">
                        AND CM.Contract_End_Date >= '#DateFormat(form.from_date,"mm/dd/yyyy")#'
                    <cfelseif IsNumeric(appSettings.getExpiredRecentlyDays())>
                        <!--- If the search is NOT for "date range". --->
                        AND  CM.Contract_End_Date >= DateAdd(d,- #appSettings.getExpiredRecentlyDays()#,getDate())
                    </cfif>

            UNION

            SELECT PFC.Claim_Mechanics, CM.Contract_Main_ID
              FROM Contract_main CM
                    INNER JOIN Program_Fixed_Component PFC ON PFC.Program_ID = CM.Contract_Main_ID
                    INNER JOIN Payment_Type PT ON PT.Payment_Type_ID = PFC.Claim_Mechanics AND (Is_Auto_Pay = 0 AND Restrict_From_Billback = 0 AND Off_Invoice = 0)
             WHERE CM.Deleted = 0
                    AND CM.IsExclusionRevision = 0
                    AND CM.Contract_Status_Type_IDX > 2
                    AND CM.Flagged_As_Purged = 0
                    AND (CM.Force_Expiration_Flag = 0 OR CM.Contract_Status_Type_IDX = 7)
                    <cfif form.from_date neq "" AND form.to_date neq "">
                        AND CM.Contract_Start_Date <= '#DateFormat(form.to_date,"mm/dd/yyyy")#'
                        AND CM.Contract_End_Date >= '#DateFormat(form.from_date,"mm/dd/yyyy")#'
                    <cfelseif form.from_date neq "">
                        AND CM.Contract_End_Date >= '#DateFormat(form.from_date,"mm/dd/yyyy")#'
                    <cfelse>
                        <cfif IsNumeric(appSettings.getExpiredRecentlyDays())>
                            <!--- If the search is NOT for "date range". --->
                            AND  CM.Contract_End_Date >= DateAdd(d,- #appSettings.getExpiredRecentlyDays()#,getDate())
                        </cfif>
                    </cfif>

            UNION

            SELECT PGC.Claim_Mechanics , CM.Contract_Main_ID
              FROM Contract_main CM
                    INNER JOIN Program_Growth_Components PGC ON PGC.Program_ID = CM.Contract_Main_ID
                    INNER JOIN Payment_Type PT ON PT.Payment_Type_ID = PGC.Claim_Mechanics AND (Is_Auto_Pay = 0 AND Restrict_From_Billback = 0 AND Off_Invoice = 0)
             WHERE CM.Deleted = 0
                    AND CM.IsExclusionRevision = 0
                    AND CM.Contract_Status_Type_IDX > 2
                    AND CM.Flagged_As_Purged = 0
                    AND (CM.Force_Expiration_Flag = 0 OR CM.Contract_Status_Type_IDX = 7)
                    <cfif form.from_date neq "" AND form.to_date neq "">
                        AND CM.Contract_Start_Date <= '#DateFormat(form.to_date,"mm/dd/yyyy")#'
                        AND CM.Contract_End_Date >= '#DateFormat(form.from_date,"mm/dd/yyyy")#'
                    <cfelseif form.from_date neq "">
                        AND CM.Contract_End_Date >= '#DateFormat(form.from_date,"mm/dd/yyyy")#'
                    <cfelse>
                        <cfif IsNumeric(appSettings.getExpiredRecentlyDays())>
                            <!--- If the search is NOT for "date range". --->
                            AND  CM.Contract_End_Date >= DateAdd(d,- #appSettings.getExpiredRecentlyDays()#,getDate())
                        </cfif>
                    </cfif>

            UNION

            SELECT PLC.Claim_Mechanics, CM.Contract_Main_ID
              FROM Contract_main CM
                    INNER JOIN Program_Lump_Sums PLC ON PLC.Program_ID = CM.Contract_Main_ID
                    INNER JOIN Payment_Type PT ON PT.Payment_Type_ID = PLC.Claim_Mechanics AND (Is_Auto_Pay = 0 AND Restrict_From_Billback = 0 AND Off_Invoice = 0)
             WHERE CM.Deleted = 0
                    AND CM.IsExclusionRevision = 0
                    AND CM.Contract_Status_Type_IDX > 2
                    AND CM.Flagged_As_Purged = 0
                    AND  (CM.Force_Expiration_Flag = 0 OR CM.Contract_Status_Type_IDX = 7)
                    <cfif form.from_date neq "" AND form.to_date neq "">
                        AND CM.Contract_Start_Date <= '#DateFormat(form.to_date,"mm/dd/yyyy")#'
                        AND CM.Contract_End_Date >= '#DateFormat(form.from_date,"mm/dd/yyyy")#'
                    <cfelseif form.from_date neq "">
                        AND CM.Contract_End_Date >= '#DateFormat(form.from_date,"mm/dd/yyyy")#'
                    <cfelse>
                        <cfif IsNumeric(appSettings.getExpiredRecentlyDays())>
                            <!--- If the search is NOT for "date range". --->
                            AND  CM.Contract_End_Date >= DateAdd(d,- #appSettings.getExpiredRecentlyDays()#,getDate())
                        </cfif>
                    </cfif>
        </cfquery>   --->
		<!---<cfset local.timer.getClaimMechanics = getTickCount() - local.timer.getClaimMechanics>--->

        <cfscript>
            local.showProgramTradeSpendORVolume = 0;
            local.showVersionLevelTradeSpend    = 0;
            local.showVersionLevelVolume        = 0;
            local.showPayment                   = 0;

            if (appSettings.getProgramSearchDollarsAndVolume()) {
                if (
                        // <!--- If "Display Trade $" setting is ON --->
                        (local.prgSettings.Display_Trade_Dollars eq 1)
                        OR
                        // <!--- If "Display Volume" setting is ON --->
                        (local.prgSettings.Display_Volume eq 1)
                        OR
                        // <!--- If "Display Payment $" setting is ON --->
                        (local.prgSettings.Display_Payment_Dollars eq 1)
                    )
                    local.showProgramTradeSpendORVolume = 1;

                // <!--- TRADE SPEND DOLLARS --->
                // <!--- If "Display Trade $" setting is ON --->
                if (local.prgSettings.Display_Trade_Dollars eq 1)
                    if (local.prgSettings.Display_Trade_Dollars_Type eq 1)
                        // <!--- "Version value" option is selected. If "local.showVersionLevelTradeSpend" is 0,
                        // then "Total program value" option is selected --->
                        local.showVersionLevelTradeSpend = 1;

                // <!--- VOLUME --->
                // <!--- If "Display Volume" setting is ON --->
                if (local.prgSettings.Display_Volume eq 1)
                    if (local.prgSettings.Display_Volume_Type eq 1)
                        // <!--- "Version value" option is selected. If "local.showVersionLevelTradeSpend" is 0,
                        // then "Total program value" option is selected--->
                        local.showVersionLevelVolume = 1;

                // <!--- PAYMENT DOLLARS (payment dollars only have a "Total program value". There is no "version value". --->
                // <!--- If "Display Payment $" setting is ON --->
                if (local.prgSettings.Display_Payment_Dollars eq 1)
                    local.showPayment = 1;
            }

            var GP_Position_List_From_My_Position_Down    = '';
            var GP_Position_List_From_My_Position_Down_SC = '';
            var moreAccessPermissionRestriction           = '';
            var Profile_Best_Plan_Program                 = '';
            var Profile_Cont_Prog_View_Create_Program     = '';
            var Profile_Delete_Program_Access             = '';
            var ProgramsWithBrokerUnderMe                 = '';
            var ProgramsWithBrokerUnderMe_SC              = '';
            var ProgramsWithDistUnderMe                   = '';
            var ProgramsWithDistUnderMe_SC                = '';
            var stSearch                                  = {};
            var UserPositionList                          = '';
        </cfscript>

		<!---<cfset local.timer.access_permissions = getTickCount()>--->
        <cfinclude template="/scorecard/access_permissions.cfm">
		<!---<cfset local.timer.access_permissions = getTickCount() - local.timer.access_permissions>

		<cfset local.timer.getProgramAccessPermissionCode = getTickCount()>
		--->
        <cfscript>
            stSearch.User_Positions_ID                         = UserPositionList;
            stSearch.Profiles_ID                               = form.profiles_id;
            stSearch.GP_Position_List_From_My_Position_Down    = GP_Position_List_From_My_Position_Down;
            stSearch.GP_Position_List_From_My_Position_Down_SC = GP_Position_List_From_My_Position_Down_SC;
            stSearch.ProgramsWithDistUnderMe                   = "0";
            stSearch.ProgramsWithBrokerUnderMe                 = "0";
            stSearch.ProgramsWithDistUnderMe_SC                = "0";
            stSearch.ProgramsWithBrokerUnderMe_SC              = "0";

            if (NOT Get_Profile_Settings.Program_Scorecard_Restrict_Created_By) {
                stSearch.ProgramsWithDistUnderMe      = ProgramsWithDistUnderMe;
                stSearch.ProgramsWithBrokerUnderMe    = ProgramsWithBrokerUnderMe;
                stSearch.ProgramsWithDistUnderMe_SC   = ProgramsWithDistUnderMe_SC;
                stSearch.ProgramsWithBrokerUnderMe_SC = ProgramsWithBrokerUnderMe_SC;
            }

            if (Get_Profile_Settings.Program_Scorecard_Restrict_Created_By)
                stSearch.programScorecardRestrictCreatedByUserId = request.AccessStructure.user_id;

            stSearch.Read_Only_Catalog_Access = Get_Profile_Settings.Read_Only_Catalog_Access;
            stSearch.See_Awarded_In_Catalog   = Get_Profile_Settings.See_Awarded_In_Catalog;
            moreAccessPermissionRestriction   = getProgramAccessPermissionCode();

            populateProgramSearchAccessPermissionTables(stSearch.User_Positions_ID, HQUser, form.show_catalog, stSearch.Read_Only_Catalog_Access);

            Profile_Cont_Prog_View_Create_Program = Get_Profile_Settings.Cont_Prog_View_Create_Program;
            Profile_Delete_Program_Access         = Get_Profile_Settings.Delete_Program_Access;
            Profile_Best_Plan_Program             = Get_Profile_Settings.Best_Plan_Program;
        </cfscript>
		<!---<cfset local.timer.getProgramAccessPermissionCode = getTickCount() - local.timer.getProgramAccessPermissionCode>

		<cfset local.timer.qGetProgramInfo = getTickCount()>
		--->


        <!--- retrieve timeout setting (in seconds) for program search --->
        <cfset local.timeout = val(application.util.query.get_Setting("program_search_timeout", 0))>

        <!--- use timeout attribute to allow CF to terminate excessive long queries --->
        <cfquery name="local.qGetProgramInfo" timeout="#local.timeout#" datasource="#application.datasource#">
            <!--- If the user searches for programs using the "create list" feature, create a temp table to hold the list of programs entered by the user.
                    Using the "IN" clause makes the query slow and so this is an alternate solution. --->
            <cfif form.match_type gt 0 AND local.program_create_List neq "">
                CREATE TABLE ##tmp_program_create_list (
                    Create_list_Contract_Number Nvarchar(255)
                )

                <cfloop list="#local.program_create_List#" index="local.i">
                    INSERT INTO ##tmp_program_create_list(Create_list_Contract_Number) VALUES('#local.i#')
                </cfloop>
            </cfif>

            SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

 <!---           CREATE TABLE ##tmp_Effective_Dates (
                Contract_Number      NVARCHAR(255) NOT NULL PRIMARY KEY CLUSTERED
               ,Effective_Start_Date DATETIME
               ,Effective_End_Date   DATETIME
            )

            <!--- Dev Note:38050 (Milan) - Get the minimum "Effective_Start_Date" and maximum "Effective_End_Date" per program (contract_number).
            Note: We need this logic for the following reason:
            When we do a price increase for a client, the affected programs get revised and the new rates are valid for the
            new revision with the start and/or end date of the revision changing based ON the date when the price change needs
            to be effective. By doing this, we only show the start and end dates for the new revision ON the program.
            By looking at the dates, the users do not know what is the complete date span of the program. The effective dates
            have the actual date span, provided we get the minimum effective start date and maximum effective end date. This
            way the users will see the complete start date and end date for a program and will not be revision dependant.
            ON the program summary, we show show both - version dates and delivery dates.
            --->
            <cfif appSettings.getProgram_search_dates()>
                INSERT INTO ##tmp_Effective_Dates WITH (TABLOCK) (
                    Contract_Number
                   ,Effective_Start_Date
                   ,Effective_End_Date
                )
                SELECT   Contract_Main.Contract_Number
                        ,MIN(Contract_Main.Effective_Start_Date) AS Effective_Start_Date
                        ,MAX(Contract_Main.Effective_End_Date)   AS Effective_End_Date
                FROM     Contract_Main
                WHERE    Contract_Main.Approved = 1
                         AND Contract_Main.effective_start_date IS NOT NULL
                         AND Contract_Main.effective_end_Date IS NOT NULL
                GROUP BY Contract_Main.Contract_Number
            </cfif>  --->

            <!--- If user selects for "CRA" from the "workflow" dropdown --->
            <cfif ListFind(form.workflow_steps_list,3) neq 0>
                <!--- Here, the "##Tmp_Program_CRA_List" temp table is populated --->
                <cfset objProgramManager.getApprovableUsers(programId=0, businessSegmentsOn=0, userPositionsID = form.user_position_list)>
            </cfif>

            <!--- If user selects for "Pending Approval" or "Under Review" from the "status" dropdown.
                For some reason when we search for "Agreed" and "Pending Approval" from the"status" dropdown, the "Pending Approval" code should be
                called before the "Agreed" code and that is why we have code for "102" being called before "101" below.
            --->
            <cfif ListFind(form.status_list,"102")  neq 0 OR ListFind(form.status_list,"103")  neq 0>
                <cfset getPendingApprovalProgramList(request.AccessStructure.User_ID, request.AccessStructure.profiles_id)>
            </cfif>

            <!--- If user selects for "Agreed" or "Under Review" from the "status" dropdown. --->
            <cfif ListFind(form.status_list,"101")  neq 0 OR ListFind(form.status_list,"103")  neq 0>
                <cfset getUserAgreedProgramsIdList(request.AccessStructure.User_ID, 0)>
            </cfif>

            <!--- If user selects an option from the "Budget Class" dropdown --->
            <cfif form.budget_class_list neq "">
                <!--- Here, the "##tmp_Budget_Programs_List" temp table is populated --->
                <cfset getSearchByBudgetClasses(form.budget_class_list)>
            </cfif>

<!---       <cfif local.showProgramTradeSpendORVolume>
                <cfset getVolumeAndTradeSpendAndPaymentDollars()>
            </cfif> --->

			<!--- Dev Note(83363) -  Add Operator ID and Operator Name columns --->
<!---			<cfif form.Include_Operator_In_CSV eq 1 AND local.prgSettings.Display_Operator_Info eq 1>
			CREATE TABLE ##tmpPgmSrch_Program_Operators
			(
				Contract_Main_ID int NOT NULL PRIMARY KEY CLUSTERED,
				Operator_ID varchar(100) NULL,
				Operator_Name varchar(200) NOT NULL
			)
			INSERT INTO ##tmpPgmSrch_Program_Operators WITH (TABLOCK) (Contract_Main_ID,Operator_ID,Operator_Name)
			SELECT cp1.contract_main_id,
			<!--- Below logic is the same logic which is on the "getOperatorLegacyIDOn" function on "businessSegmentManager.cfc" --->
			CASE
				WHEN LTRIM(RTRIM(bsaop.Legacy_ID)) <> '' AND
				((#application.returned_customer_setting.operator_legacy_id_on# = 1)
				OR
				(#businessSegManager.isEnabled()# = 1 AND len(cm.Business_Segment_ID) > 0 AND bsg.Operator_BS_Filter = 1))
			THEN
				bsaop.Legacy_ID
			ELSE
				CAST(bsaop.bsa_Operator_ID As varchar(100))
			END
			,bsaop.Operator_Name
			FROM Contract_Operators cp1
			INNER JOIN BSA_Operator bsaop
			ON bsaop.BSA_Operator_ID = cp1.BSA_Operator_ID
			INNER JOIN Contract_Main cm
			ON cp1.Contract_Main_ID = cm.Contract_Main_ID
			LEFT JOIN Business_Segment bsg
			ON bsg.Business_Segment_ID = cm.Business_Segment_ID
			WHERE cp1.deleted = 0
			AND cp1.bsa_Operator_ID IN
			(
				SELECT TOP 1 cp2.bsa_Operator_ID
				FROM Contract_Operators cp2
				WHERE cp2.deleted = 0
				AND cp1.contract_main_id = cp2. contract_main_id
			)
			</cfif> --->

            <!---
            The logic for calculating trade spend $, committed $ and volume (above) is follows:
                - "Committed $" and "Volume" above can be at a "version" or "Total program value" level. It depends ON the setting, which is
                  ON the "program setting" page.Payment $ is always at a "Total program value" level.
                - When "budget functionality" is ON, AND the program template is associated to a budget,
                  then "trade spend" and "payment dollars" values come from the budget.
                - When program template is not associated to a budget, then "trade spend" and "payment dollar" values
                  come from the program. Volume is always from the program.
                - When the "trade spend" and "payment dollars" values from the budget are NULL for program(s)
                  (i.e. program template is not associated to a budget),then for those programs,
                  the values come from the program itself (assumption is that the value will be null, when the program's template is not associated to a budget).

                Note:If you change the select clause logic for trade spend $ or committed $ or volume, then make the comment changes below too.
                 In the select clauses (below) to retrieve data for these columns, there is additional logic:
                   a) Total program value:
                    a1)##TotalPrgTradeSpendAndVolume.Estimated_Program_Spend is used to get the trade spend $ (program_spend) as the logic for whether it comes from
                    budget or program is in the query above (##TotalPrgTradeSpendAndVolume table)
                    a2) ##TotalPrgTradeSpendAndVolume.Contract_Quantity is the volume.
                    a3) ISNULL(##TotalPrgTradeSpendAndVolume.actual_dollar,Contract_Main_Aux_Data.Paid_Amount): When the budget values are NULL for payment $
                    (when the program's template is not associated to a budget), then get it from the "paid_Amount" column. "paid_Amount" is the amount paid
                    for the billback.
                   b)  Version value:
                    b1) IsNull(##PrgVersionlevelTradeSpendAndVolume.Estimated_Committed_Dollar,Contract_Main_Aux_Data.Program_Spend): When the budget values are NULL
                    for Trade $ (when the program's template is not associated to a budget), then get it from the program - "program_spend" column.
                    b2) Contract_Main.Contract_Quantity is the volume.
                    b3) payment $ is never at a version level.
            --->

            DECLARE @Default_Program_Contract_Number VARCHAR(20)
            SELECT @Default_Program_Contract_Number = Contract_Number FROM Contract_Main WHERE Contract_Main_ID IN (SELECT Default_Program FROM Billback_Settings)
            <!--- Note: We are not using a temp table as the performance is slower then expected. We need the "COUNT(1) OVER()" for counting the number of records --->
            SELECT  *
                    ,'' AS list_bad_rows
                    ,Rows_Cnt = COUNT(1) OVER()
            <!--- If the user searches for programs using the "create list" feature, create a temp table, as we need to find for "invalid" programs. --->
            <cfif (form.match_type gt 0 AND local.program_create_List neq "") OR (appSettings.get_Setting('Quick_Pay_in_Program_Search') eq '2' AND Get_Profile_Settings.AQP_Available eq 1)>
                INTO ##tmp_search_programs_result
            </cfif>
            FROM (
                    SELECT DISTINCT
                           Contract_Main.Contract_Main_ID
                          ,Contract_Main.status
                          ,Contract_Main.rfaAge
                          ,Contract_Main.program
                          ,Contract_Main.Contract_Number
                          <cfif form.match_type gt 0 AND program_create_List neq "">
                            <!--- "searchable_contract_number" is "Contract_Number" without prefix or suffix --->
                          ,Contract_Main.searchableContractNumber
                          <cfelse>
                          ,''
                          </cfif>                                                                                                                                                AS searchableContractNumber
                          ,Contract_Main.Contract_Title
                          <!--- display reference number in search results if the Display_Reference_Number_In_Search_Results setting is on --->
                          <cfif getPrgSettings().Display_Reference_Number_In_Search_Results>
                          +
						  (case when ISNULL(Contract_Main.Contract_Reference_Number, '') != '' then + '  (' +  Contract_Main.Contract_Reference_Number + ')'  else '' end)
                          </cfif>                                                                                                                                                 AS title
                          ,Contract_Main.type                                                                                                                                    AS type
                          ,Contract_Main.startDate                                                                                                                               AS startDate
                          ,Contract_Main.endDate                                                                                                                                 AS endDate
                          ,Contract_Main.rsp                                                                                                                                     AS rsp

                          <!--- TRADE SPEND: TOTAL PROGRAM VALUE --->
						  <!---
						  		113075:	Program Search - Display Estimated Trade for RFA
								Code change to display the trade spend when the program is in RFA status,
								which will override other settings.
						  --->
                          ,CASE WHEN (Contract_Main.Contract_Status_Type_IDX = 2) THEN
						  		ISNULL(Contract_Main.Contract_Main_Aux_Data_Program_Spend,'0')
							ELSE
							  <cfif local.showProgramTradeSpendORVolume AND local.showVersionLevelTradeSpend eq 0>
	                            ISNULL(Contract_Main.TotalPrgTradeSpendAndVolume_Estimated_Program_Spend,0)
	                          <!--- TRADE SPEND: VERSION VALUE --->
	                          <cfelseif local.showVersionLevelTradeSpend>
	                            ISNULL(IsNull(Contract_Main.PrgVersionlevelTradeSpendAndVolume_Estimated_Committed_Dollar,Contract_Main.Contract_Main_Aux_Data_Program_Spend),'0')
	                          <cfelse>
	                            0
	                          </cfif>
							END
							tradeDollars
                          <!--- VOLUME: TOTAL PROGRAM VALUE --->
                          ,<cfif local.showProgramTradeSpendORVolume AND local.showVersionLevelVolume eq 0>
                            ISNULL(Contract_Main.TotalPrgTradeSpendAndVolume_Contract_Quantity,0)
                          <!--- VOLUME: VERSION VALUE --->
                          <cfelseif local.showVersionLevelVolume>
                            ISNULL(Contract_Main.Contract_Main_Contract_Quantity,0)
                          <cfelse>
                            0
                          </cfif>                                                                                                                                                AS volume

                          <!--- PAYMENT DOLLARS: TOTAL PROGRAM VALUE.
                            THERE IS NO VERSION VALUE. BILLBACK PAYMENT IS ALWAYS CALCULATED FOR ALL THE PROGRAM VERSIONS COMBINED.
                            EVERY VERSION OF THE PROGRAM IN THE Paid_Amount COLUMN OF THE Contract_Main_Aux_Data
                            TABLE HAS THE SAME AMOUNT, AS THE TOTAL AMOUNT OF ALL THE VERSIONS COMBINED IS UPDATED FOR
                            ALL THE VERSIONS.
                            --->
                          ,<cfif local.showPayment>
                            ISNULL(ISNULL(Contract_Main.TotalPrgTradeSpendAndVolume_actual_dollar,Contract_Main.Contract_Main_Aux_Data_Paid_Amount),'0')
                           <cfelse>
                            0
                           </cfif>                                                                                                                                               AS paymentDollars
                          ,<cfif appSettings.get_Setting('Quick_Pay_in_Program_Search') neq '0'>
                            isnull(Contract_Main.Claim_Mechanics,0)                    
                           <cfelse>
                            0
                           </cfif>                                                                                                                                               AS claimMech
                          <cfif businessSegManager.isEnabled()>
                            ,Contract_Main.Business_Unit_Desc
                          <cfelse>
                            ,''
                           </cfif>                                                                                                                                               AS businessSegment
                          ,<cfif appSettings.getpaymenthistoryon()>
                            IsNull(Contract_Main.Payment_History,0)
                          <cfelse>
                            0
                          </cfif>                                                                                                                                                AS payHist
                          ,<cfif request.AccessStructure.External_Customer_Profile_Access EQ "1">1
                          <cfelseif form.show_catalog eq 1>
                                <cfif stSearch.Read_Only_Catalog_Access EQ 1>
                                    1
                                <cfelse>
                                    0
                                </cfif>
                           <cfelse>
                                0
                           </cfif>                                                                                                                                                AS isCatalog
                        <!---  <cfif local.prgSettings.Display_Operator_Info eq 1> --->
                         ,Contract_Main.Operator_ID                                                                                                              AS OperatorID
                         ,Contract_Main.Operator_Name                                                                                                         AS OperatorName
                       <!---   <cfelse>
                            ,'' AS OperatorID
                            ,'' AS OperatorName
                         </cfif> --->
                         ,Contract_Main.Best_Plan_Program
						 ,Contract_Main.Manual_Cancel
						 /* ,Contract_Main.Cancelled_By */
						 ,Contract_Main.Cancelled_By AS Cancelled_By
						 ,Contract_Main.Cancelled_Date AS Cancelled_Date
                         ,CASE WHEN Contract_Main.Contract_Number = @Default_Program_Contract_Number THEN 1 ELSE 0 END as Dummy_Program
                         ,Contract_Main.Released
                         ,CAST(0 as BIT) as Pays_To_Distributor
                         ,CAST(0 AS BIT) AS Accrual_On
                         ,ISNULL(Contract_Main.Planner_ID, 0) AS Planner_ID
			            ,Contract_Main.ProgramType_ID AS Template_ID
                        ,Contract_Main.Retail_Planner_Program_Specific_Approval
                    FROM   Contract_Main_Program_Search Contract_Main

                        <!--- If user did NOT request for CATALOG programs --->
                        <cfif NOT(form.show_catalog eq 1 and stSearch.Read_Only_Catalog_Access EQ 1)>
                            INNER JOIN ##Profile_Forbidden_Template ON Contract_Main.ProgramType_ID = ##Profile_Forbidden_Template.Template_ID
                        </cfif>

<!---                   INNER JOIN Program_Control_Panel_Options ON  Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
                        INNER JOIN Contract_Main_Aux_Data ON  Contract_Main_Aux_Data.Contract_Main_ID = Contract_Main.Contract_Main_ID
                        LEFT JOIN _Users responsibleSalesPerson ON responsibleSalesPerson.User_ID = Contract_Main.Responsible_User_ID AND responsibleSalesPerson.deleted = 0
                        INNER JOIN Contract_Status_Types ON  Contract_Status_Types.Contract_Status_Type_ID =  Contract_Main.Contract_Status_Type_IDX
						LEFT JOIN _Users cancelledbyuser	ON cancelledbyuser.User_ID = Contract_Main.Cancelled_By
                        <cfif form.workflow_steps_list neq "" AND form.workflow_steps_list neq 3>
                            LEFT JOIN _Users CreatorUser ON Contract_Main.Creator_ID = CreatorUser.User_ID
                            LEFT JOIN _Users RFAUser ON Contract_Main.Broker_User_ID = RFAUser.User_ID
                            LEFT JOIN _Users ApproverUser ON Contract_Main.Approved_By_User_ID = ApproverUser.User_ID
                        </cfif>
                        <!--- If the user selects an option from the "Position" dropdown.--->
                        <cfif form.user_position_list neq "">
                            LEFT JOIN User_Positions as Owner_Position ON Contract_Main.Creating_User_Position_ID = Owner_Position.User_Positions_ID
                            LEFT JOIN User_Position_Holders AS RFA_Position_Holders ON Contract_Main.Broker_User_ID = RFA_Position_Holders.User_ID
                                                                                    AND RFA_Position_Holders.deleted = 0
                                                                                    AND RFA_Position_Holders.User_Position_Type = 'P'
                            LEFT JOIN User_Positions as RFA_Position ON RFA_Position.User_Positions_ID = RFA_Position_Holders.User_Positions_ID
                            LEFT JOIN User_Position_Holders As Approver_Position_Holders  ON Contract_Main.Approved_By_User_ID = Approver_Position_Holders.User_ID
                                                                                            AND Approver_Position_Holders.deleted = 0
                                                                                            AND Approver_Position_Holders.User_Position_Type = 'P'
                            LEFT JOIN User_Positions as Approver_Position ON Approver_Position.User_Positions_ID = Approver_Position_Holders.User_Positions_ID
                        </cfif>
                        <!--- If user selects for "revision" from the "conditions" dropdown --->
                        <cfif ListFind(form.condition_list,"8")  neq 0>
                            LEFT JOIN Contract_Main Contract_Main_1 ON Contract_Main_1.Revision_Of_Contract_Main_ID = Contract_Main.Contract_Main_ID
                            AND Contract_Main_1.Deleted = 0
                        </cfif> --->

						<cfif ListFind(form.condition_list,"8")  neq 0>
                            LEFT JOIN Contract_Main Contract_Main_1 ON Contract_Main_1.Revision_Of_Contract_Main_ID = Contract_Main.Contract_Main_ID
                            AND Contract_Main_1.Deleted = 0
                        </cfif>

                        <!--- If user selects for "Agreed" or "Under Review" from the "status" dropdown --->
                        <cfif ListFind(form.status_list,"101") neq 0 OR ListFind(form.status_list,"103") neq 0>
                            LEFT JOIN ##tmp_Program_Agree_List ON ##tmp_Program_Agree_List.programId = Contract_Main.Contract_Main_ID
                        </cfif>
                        <!--- If user selects for "Pending Approval" or "Under Review" from the "status" dropdown --->
                        <cfif ListFind(form.status_list,"102")  neq 0 OR ListFind(form.status_list,"103") neq 0>
                            LEFT JOIN ##tmp_pending_approval_programs_list ON ##tmp_pending_approval_programs_list.Contract_Main_ID = Contract_Main.Contract_Main_ID
                        </cfif>

<!---                       LEFT JOIN ##tmp_Effective_Dates ON ##tmp_Effective_Dates.Contract_Number = Contract_Main.Contract_Number

                        <cfif local.showProgramTradeSpendORVolume>
                            LEFT JOIN ##TotalPrgTradeSpendAndVolume ON ##TotalPrgTradeSpendAndVolume.Contract_Number = Contract_Main.Contract_Number
                            LEFT JOIN ##PrgVersionlevelTradeSpendAndVolume ON ##PrgVersionlevelTradeSpendAndVolume.Contract_Number = Contract_Main.Contract_Number
                        </cfif>

                        <!--- If user selects for "Auto renewed" or "Auto renew pairs" from the "conditions" dropdown --->
                        <cfif ListFind(form.condition_list,1) neq 0 OR ListFind(form.condition_list,2) neq 0>
                            LEFT JOIN Program_Auto_Renew ON Contract_Main.Contract_Main_ID = Program_Auto_Renew.Program_ID
                            AND Program_Auto_Renew.Deleted = 0
                            <!--- "Program_Auto_Renew.Renewed" has been added just to make sure that if there are duplicate records in the "Program_Auto_Renew" table
                            with one record having "Renewed = 1" and the other "Renewed = 0", then the query will filter records with "Renewed = 1", and we
                            will not get duplicates.
                            --->
                            AND Program_Auto_Renew.Renewed = 1
                        </cfif>

                        <cfif businessSegManager.isEnabled()>
                            LEFT JOIN Business_Segment ON Business_Segment.Business_Segment_ID = Contract_Main.Business_Segment_ID
                        </cfif>

                        <!--- If the request is from "download report" and the setting to display operator in ON --->
                        <cfif form.Include_Operator_In_CSV eq 1 AND local.prgSettings.Display_Operator_Info eq 1>
                            LEFT JOIN ##tmpPgmSrch_Program_Operators
                            ON ##tmpPgmSrch_Program_Operators.Contract_Main_ID = Contract_Main.Contract_Main_ID
                        </cfif>   --->

                        <!--- If user selects for "CRA" from the "workflow" dropdown --->
                        <cfif ListFind(form.workflow_steps_list,3) neq 0>
                            LEFT JOIN ##Tmp_Program_CRA_List ON ##Tmp_Program_CRA_List.Contract_Main_ID = Contract_Main.Contract_Main_ID
                        </cfif>
                        <!--- If user selects an option from the "Budget Class" dropdown --->
                        <cfif form.budget_class_list neq "">
                            INNER JOIN ##tmp_Budget_Programs_List ON ##tmp_Budget_Programs_List.Contract_Main_ID = Contract_Main.Contract_Main_ID
                        </cfif>
                        <!--- If user does a keywprd search by "distributor" OR selects an option from the "Family" or "Buying Group" dropdown --->
                        <cfif (IsDefined("form.distributor_search") AND form.distributor_search neq "") OR form.family_list neq "" OR form.buying_group_list neq "">
                            INNER JOIN Contract_Distributors CD ON Contract_Main.Contract_Main_Id =  CD.Contract_Main_Id
                                                                    AND CD.Deleted = 0
                            INNER JOIN dbo.BSA_Foodservice_Customers BFC ON BFC.BSA_Foodservice_Customers_ID = CD.BSA_Foodservice_Customers_ID
                        </cfif>

                        <!--- FULL-TEXT SEARCH DISTRIBUTOR --->
                        <cfif IsDefined("form.distributor_search") AND form.distributor_search neq "">
                            <cfloop from="1" to="#listLen(form.distributor_search)#" index="local.d">
                                INNER JOIN CONTAINSTABLE(BSA_Foodservice_Customers, *, '"*#ListGetAt(form.distributor_search, local.d)#*"') AS DIST_TABLE_#local.d#
                                    ON DIST_TABLE_#local.d#.[KEY] = BFC.BSA_Foodservice_Customers_ID
                                </cfloop>
                        </cfif>
                        <!--- FULL-TEXT SEARCH FOR OPERATOR --->
                        <cfif IsDefined("form.operator_search") AND form.operator_search neq "">
                            INNER JOIN BSA_Operator BO ON 1=1
                            <cfloop from="1" to="#listLen(form.operator_search)#" index="local.o">
                                INNER JOIN CONTAINSTABLE(BSA_Operator, *, '"*#ListGetAt(form.operator_search,local.o)#*"') AS OP_TABLE_#local.o#
                                    ON OP_TABLE_#local.o#.[KEY] = BO.BSA_Operator_ID
                            </cfloop>
                            INNER JOIN Contract_Operators CO ON BO.BSA_Operator_ID = CO.BSA_Operator_ID
                                                                AND Contract_Main.Contract_Main_Id =  CO.Contract_Main_Id
                                                                AND CO.Deleted = 0
                        </cfif>
                        <!--- FULL-TEXT SEARCH FOR ITEM --->
                        <cfif IsDefined("form.item_search") AND form.item_search neq "">
                            INNER JOIN Item_Search BFI ON 1 = 1
                            <cfloop from="1" to="#listLen(form.item_search)#" index="local.i">
                                INNER JOIN CONTAINSTABLE(Item_Search, *, '"*#ListGetAt(form.item_search,local.i)#*"') AS IM_TABLE_#local.i#
                                    ON IM_TABLE_#local.i#.[KEY] = BFI.Key_Id
                            </cfloop>
                            INNER JOIN Contract_Products CP ON BFI.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID
                                                                AND Contract_Main.Contract_Main_Id =  CP.Contract_Main_Id
                                                                AND CP.Deleted = 0
                        </cfif>
                        <!--- If user selects an option from the "Family" dropdown --->
                        <cfif form.family_list neq "">
                            INNER JOIN Distributor_Family ON BFC.Family_ID = Distributor_Family.Family_ID
                        </cfif>
                        <!--- If user selects an option from the "Buying Group" dropdown --->
                        <cfif form.buying_group_list neq "">
                            INNER JOIN Distributor_Buying_Groups ON BFC.Buying_Group_ID = Distributor_Buying_Groups.Buying_Group_ID
                        </cfif>
<!---                       LEFT JOIN ##tmp_ClaimMechanics Claim ON Claim.contract_main_id  = Contract_Main.Contract_Main_ID   --->
						<!--- 96448	HF Bundle - Program Search - New Filtering Options / Anand Rao / 19-Oct-2020 --->
						<!--- FIXED PRICE --->
						<cfif (form.discount_type EQ 1 AND form.fixed_discount_types NEQ "")> 	<!--- Add INNER JOIN for Fixed Price --->
							INNER JOIN Program_Fixed_Component PFC ON PFC.Program_ID = Contract_Main.Contract_Main_ID
							AND PFC.Deleted = 0
							<cfif ((ListFind(form.condition_list,"16")  NEQ 0) OR (ListFind(form.condition_list,"17")  NEQ 0))>
	   							INNER JOIN Payment_Type PT
            					ON PT.Payment_Type_ID = PFC.Claim_Mechanics
								AND PT.Restrict_From_Billback IN (
								<cfif (ListFind(form.condition_list,"16")  NEQ 0 AND ListFind(form.condition_list,"17")  NEQ 0)>0,1
								<cfelseif (ListFind(form.condition_list,"16")  NEQ 0 AND ListFind(form.condition_list,"17")  EQ 0)>0
								<cfelseif (ListFind(form.condition_list,"16")  EQ 0 AND ListFind(form.condition_list,"17")  NEQ 0)>1
								</cfif>
								)
							</cfif>
							<cfif ((form.rate_compare NEQ "" AND form.rate_val NEQ "") OR (form.rate_uom NEQ ""))>
								INNER JOIN Program_Fixed_Price_Product_Data PFPPD
								ON PFPPD.Program_Fixed_Component_ID = PFC.Program_Fixed_Component_ID AND PFPPD.Deleted = 0
								<cfif IsDefined("form.item_search") AND form.item_search neq "">
									<!--- JOIN with Contract_Products CP is done above --->
									AND PFPPD.Contract_Products_ID = cp.Contract_Products_ID
								</cfif>
							</cfif>
						<!--- REBATES --->
						<cfelseif (form.discount_type EQ 2 AND form.rebate_discount_types NEQ "")> 	<!--- Add INNER JOIN for Rebates --->
							INNER JOIN Program_Rebates_Component PRC ON PRC.Program_ID = Contract_Main.Contract_Main_ID
							AND PRC.Deleted = 0
							<cfif ((ListFind(form.condition_list,"16")  NEQ 0) OR (ListFind(form.condition_list,"17")  NEQ 0))>
	   							INNER JOIN Payment_Type PT
            					ON PT.Payment_Type_ID = PRC.Claim_Mechanics
								AND PT.Restrict_From_Billback IN (
								<cfif (ListFind(form.condition_list,"16")  NEQ 0 AND ListFind(form.condition_list,"17") NEQ 0)>0,1
								<cfelseif (ListFind(form.condition_list,"16")  NEQ 0 AND ListFind(form.condition_list,"17") EQ 0)>0
								<cfelseif (ListFind(form.condition_list,"16")  EQ 0 AND ListFind(form.condition_list,"17") NEQ 0)>1
								</cfif>
								)
							</cfif>
							<cfif ((form.rate_compare NEQ "" AND form.rate_val NEQ "") OR (form.rate_uom NEQ ""))>
								INNER JOIN Program_Rebates_Component_Data PRCD
								ON PRCD.Program_Rebates_Component_ID = PRC.Program_Rebates_Component_ID
                                INNER JOIN Program_Rebates_Product_Data prpd
						            ON prpd.Program_Rebates_Product_Data_ID = prcd.Program_Rebates_Product_Data_ID AND prcd.Deleted = 0
								<cfif IsDefined("form.item_search") AND form.item_search neq "">
									<!--- JOIN with Contract_Products CP is done above --->
									AND PRPD.Contract_Products_ID = cp.Contract_Products_ID
									INNER JOIN BSA_Foodservice_Items_Master i
										ON i.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
								<cfelse>
									INNER JOIN Contract_Products cp2
										ON cp2.Contract_Products_ID = prpd.Contract_Products_ID AND cp2.Deleted = 0
									INNER JOIN BSA_Foodservice_Items_Master i
										ON i.BSA_Foodservice_Items_Master_ID = cp2.BSA_Foodservice_Items_Master_ID
								</cfif>
							</cfif>
						<!--- LUMP SUM --->
						<cfelseif (form.discount_type EQ 3 AND form.lump_sum_discount_types NEQ "")> 	<!--- Add INNER JOIN for Lump Sum --->
							INNER JOIN Program_Lump_Sums PLS ON PLS.Program_ID = Contract_Main.Contract_Main_ID
							AND PLS.Deleted = 0
							<cfif IsDefined("form.item_search") AND form.item_search neq "">
								INNER JOIN Program_Lump_Sum_Product_Data PLSPD
								ON		PLSPD.Program_Lump_Sum_ID = PLS.Program_Lump_Sum_ID
								AND		PLSPD.deleted = 0
								AND 	PLSPD.Contract_Products_ID = cp.Contract_Products_ID
							</cfif>
							<cfif ((ListFind(form.condition_list,"16")  NEQ 0) OR (ListFind(form.condition_list,"17") NEQ 0))>
	   							INNER JOIN Payment_Type PT
            					ON PT.Payment_Type_ID = PLS.Claim_Mechanics
								AND PT.Restrict_From_Billback IN (
								<cfif (ListFind(form.condition_list,"16")  NEQ 0 AND ListFind(form.condition_list,"17") NEQ 0)>0,1
								<cfelseif (ListFind(form.condition_list,"16")  NEQ 0 AND ListFind(form.condition_list,"17") EQ 0)>0
								<cfelseif (ListFind(form.condition_list,"16")  EQ 0 AND ListFind(form.condition_list,"17") NEQ 0)>1
								</cfif>
								)
							</cfif>
						<!--- GROWTH --->
						<cfelseif (form.discount_type EQ 4 AND form.growth_discount_types NEQ "")> 	<!--- Add INNER JOIN for Growth --->
							INNER JOIN Program_Growth_Components PGC ON PGC.Program_ID = Contract_Main.Contract_Main_ID
							AND PGC.Deleted = 0
							<cfif ((ListFind(form.condition_list,"16")  NEQ 0) OR (ListFind(form.condition_list,"17") NEQ 0))>
	   							INNER JOIN Payment_Type PT
            					ON PT.Payment_Type_ID = PGC.Claim_Mechanics
								AND PT.Restrict_From_Billback IN (
								<cfif (ListFind(form.condition_list,"16")  NEQ 0 AND ListFind(form.condition_list,"17") NEQ 0)>0,1
								<cfelseif (ListFind(form.condition_list,"16")  NEQ 0 AND ListFind(form.condition_list,"17") EQ 0)>0
								<cfelseif (ListFind(form.condition_list,"16")  EQ 0 AND ListFind(form.condition_list,"17") NEQ 0)>1
								</cfif>
								)
							</cfif>
							<cfif ((form.rate_compare NEQ "" AND form.rate_val NEQ "") OR (form.rate_uom NEQ ""))>
								INNER JOIN dbo.Program_Growth_Component_Product_Data PGCPD ON PGCPD.Program_Growth_Component_ID = PGC.Program_Growth_Component_ID AND PGCPD.Deleted = 0
								<cfif IsDefined("form.item_search") AND form.item_search neq "">
									AND PGCPD.Contract_Products_ID = CP.Contract_Products_ID
								</cfif>
								INNER JOIN Program_Growth_Component_Product_Tier_Data PGCPTD ON PGCPTD.Program_Growth_Component_Product_Data_ID = PGCPD.Program_Growth_Component_Product_Data_ID AND PGCPTD.Deleted = 0
							</cfif>
 						</cfif>
						<!--- 113368:	Planner programs in program search / Anand Rao / 15-Feb-2022 --->
						<cfif appSettings.get_Setting('Retail_Planner') EQ '1' AND get_profile_settings.Planner_Create NEQ 0>
							LEFT JOIN Planners PLA ON PLA.Planner_ID = Contract_Main.Planner_ID
							LEFT JOIN Planner_Template PLTEMP ON PLTEMP.Planner_Template_ID = PLA.Planner_Template_ID
							LEFT JOIN Profile_Forbidden_Planner PRPFPLA ON PRPFPLA.Planner_Template_ID = PLTEMP.Planner_Template_ID AND PRPFPLA.Profile_ID = #request.AccessStructure.Profiles_ID#
						</cfif>
                WHERE
                        <!---D57639 :: View all versions of programs in program search START--->
                        <cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
                            (Contract_Main.Deleted = 0 OR (Contract_Main.Effective_Start_Date IS NOT NULL AND Contract_Main.Effective_End_Date IS NOT NULL))
                        <cfelse>
                            Contract_Main.Deleted = 0
                        </cfif>

                        <!---D57639 :: View all versions of programs in program search END--->
                        AND (Contract_Main.IsExclusionRevision = 0 OR Contract_Main.Contract_Status_Type_IDX > 2)
                        AND Contract_Main.Flagged_As_Purged = 0

                        <!--- dr D26891 --->
                        <cfif form.Creating_User_Position neq 0>
                        AND Contract_Main.creating_user_position_id = #form..Creating_User_Position#
                        </cfif>
                        <!--- dr D26891 --->

                        AND
                        (
                            Contract_Main.Force_Expiration_Flag = 0
                            OR
                            Contract_Main.Contract_Status_Type_IDX = 7
                        )
                        <!---
								Return programs which overlap with the search dates (dataRangeStart OR dataRangeEnd).
								If the search criteria is from 6/1/2013 - 9/30/2013, the following scenarios
								will be used to return programs.
								1) Programs with a start and end date between the search date range. Eg: 7/1/2013 to 7/31/2013.
								2) Programs with a start date within the search date range. Eg: 7/1/2013 to 12/31/2013.
								3) Programs with a end date within the search date range. Eg: 5/1/2013 to 6/30/2013.
								4) Programs with the search data range within the start and end date. Eg: 1/1/2013 to 12/31/2013.
								Note: All the above scenarios can be covered using just the 2 condiotions below.
                          --->
                        <cfif form.from_date neq "" AND form.to_date neq "">
                            AND Contract_Main.Contract_Start_Date <= '#DateFormat(form.to_date,"mm/dd/yyyy")#'
                            AND Contract_Main.Contract_End_Date >= '#DateFormat(form.from_date,"mm/dd/yyyy")#'
                        <cfelseif form.from_date neq "">
                            AND Contract_Main.Contract_End_Date >= '#DateFormat(form.from_date,"mm/dd/yyyy")#'
                        <cfelse>
                            <cfif IsNumeric(appSettings.getExpiredRecentlyDays())>
                                <!--- If the search is NOT for "date range". --->
                                AND  Contract_Main.Contract_End_Date >= DateAdd(d,- #appSettings.getExpiredRecentlyDays()#,getDate())
                            </cfif>
                        </cfif>

                        <!----Check Access Permissions Start --->
                        <cfif IsDefined("stSearch.programScorecardRestrictCreatedByUserId")>
                            <cfset local.qUserNumber = "" />
                            <cfif appSettings.getUserNumberRestrict()>
                                <cfset local.qUser = CreateObject("component", "components.user.UserManager").getUser(stSearch.programScorecardRestrictCreatedByUserId) />
                                <cfset local.qUserNumber = local.qUser.User_Number />
                            </cfif>
                            AND
                            (
                                Contract_Main.Responsible_User_ID = '#stSearch.programScorecardRestrictCreatedByUserId#'
                                <cfif Len(local.qUserNumber) GT 0>
                                    OR (SELECT User_Number
                                          FROM _Users
                                         WHERE User_ID = Contract_Main.Responsible_User_ID) = '#local.qUserNumber#'
                                </cfif>
                            )
                        </cfif>

                        AND
                        (
                            <cfif form.show_catalog eq 1>
                                <cfif stSearch.Read_Only_Catalog_Access eq 1>
                                    <!--- Catalog start --->
                                    (
                                        Contract_Main.Include_In_Catalog = 1
                                        AND ((Contract_Main.Contract_Status_Type_IDX >= 3 and Contract_Main.Contract_Status_Type_IDX < 7)
                                                OR Contract_Main.Contract_Status_Type_IDX = 10
                                                OR (Contract_Main.Contract_Status_Type_IDX = 7 and Contract_Main.CONTRACT_END_DATE >= DATEADD(D, -#appSettings.getExpiredRecentlyDays()# , GETDATE())))
                                         <cfif stSearch.See_Awarded_In_Catalog IS 1>
                                             <!---Restriction -- if profile has seen only awarded and template says that the program should have awarded, the user will not be able to see the program in the catalog unless the program has been awarded--->
                                            AND ((Contract_Main.Show_Awarded_In_Catalog = 1 AND Contract_Main.Is_Awarded = 1) OR Contract_Main.Show_Awarded_In_Catalog = 0)
                                        </cfif>
                                        <!--- 29470 Update Catalog view to consider business segment --->
                                        <cfset  local.businessSegmentsOn = 0>
                                        <cfset  local.Business_Segment_ID_List = "">
                                        <cfif businessSegManager.isEnabled()>
                                            <cfset local.businessSegmentsOn = 1>
                                            <cfset qGetBusSegments = businessSegManager.getActive(request.AccessStructure.user_id)>
                                            <cfset local.Business_Segment_ID_List = valueList(qGetBusSegments.Business_Segment_ID, ",")>
                                        </cfif>
                                        <cfif local.businessSegmentsOn EQ 1>
                                            <cfif Len(local.Business_Segment_ID_List) GT 0>
                                                AND Contract_Main.Business_Segment_ID IN (#local.Business_Segment_ID_List#)
                                            <cfelse>
                                                AND 1=2
                                            </cfif>
                                        </cfif>
                                    )
                                    <!--- Catalog end --->
                                </cfif>     <!--- stSearch.Read_Only_Catalog_Access eq 1 --->
                            <cfelse>    <!--- form.show_catalog eq 1 --->
                                <!--- Program start --->
                                (
                                    (
                                        Contract_Main.Creating_User_Position_ID IN (#preserveSingleQuotes(stSearch.User_Positions_ID)#)
                                        OR
                                        (
                                             <cfif NOT HQUser><!--- If HQ user no need to check for position --->
                                                Contract_Main.Creating_User_Position_ID IN (#preserveSingleQuotes(stSearch.GP_Position_List_From_My_Position_Down_SC)#)
                                                AND
                                             </cfif>

                                             <!--- dr D26891 --->
                                             <cfif form.Include_work_in_progress_below_me eq 0 AND Get_Profile_Settings.ProgramView_WIPPositionsBelowMe eq 0>
                                              (
                                                Contract_Main.Contract_Status_Type_IDX > 1
                                                 OR
                                                 Contract_Main.Is_AutoRenew = 1
                                              )
                                             <cfelse>
                                             1=1
                                             </cfif>
                                             <!--- dr D26891 --->
                                        )
                                        OR
                                        (
                                            Contract_Main.Contract_Status_Type_IDX >= 3
                                            <cfif NOT HQUser><!--- If HQ user no need to check for position --->
                                                AND
                                                (
                                                    1=2
                                                    OR EXISTS
                                                    (
                                                        SELECT 1
                                                          FROM ##TmpProgramsWithDistBrokerBelowMe t
                                                         WHERE t.Contract_Main_ID = Contract_Main.Contract_Main_ID
                                                    )
                                                )
                                            </cfif>
                                        )
                                        <!---60308  Best Plans Enhancement START--->
                                        OR Contract_Main.Best_Plan_Program = 1
                                        <!---60308  Best Plans Enhancement END--->
                                    )
                                    #PreserveSingleQuotes(moreAccessPermissionRestriction)#
                                )
                                <!--- Program end --->
                            </cfif>     <!--- form.show_catalog eq 1 --->
                        )
                        <!---Only add filters below if coming from the main search tab. Users are unable to search Planner Programs from the list tab because form.show_catalog gets set to and empty string --->
                        <cfif form.search_type eq "MainSearch">
                            <!---   114038: STAGE2 Program Search Data Source filter  / Anand Rao / 23-Mar-2022
                                    Multiple conditions have been combined as some conditions were contradicting each other
                            --->
                            <!---  form.show_catalog ==> 0 = Programs; 1 = Catalog; 2 = Programs & Events; 3 = Events  --->
                                                    <cfif (appSettings.get_Setting('Retail_Planner') EQ '1' AND get_profile_settings.Planner_Create NEQ 0)>
                                <cfif ((form.show_catalog eq 0 OR form.show_catalog eq 1 OR form.show_catalog EQ ""))> <!--- SHOW ONLY PROGRAMS --->
                                    <!--- get_profile_settings.Planner_Create = 0 means Planner - None was picked in profile --->
                                    /* when the user picked the data source then do not show planner or planner with the Retail_Planner_Program_Specific_Approval = 0 */
                                    /* Show programs only */
                                    AND ((ISNULL(Contract_Main.Planner_ID, 0) = 0 OR Contract_Main.Retail_Planner_Program_Specific_Approval = 1) AND ISNULL(PRPFPLA.Access_is_forbidden,0) = 0)
                                <cfelseif (form.show_catalog eq 3)> <!--- SHOW ONLY PLANNERS --->
                                    /* Show planner only */
                                    AND  (ISNULL(Contract_Main.Planner_ID, 0) <> 0 AND ISNULL(PRPFPLA.Access_is_forbidden,0) = 0)
                                <cfelse> <!--- SHOW BOTH PROGRAMS AND EVENTS --->
                                    /* Show Programs & Events  */
                                    /* AND (ISNULL(Contract_Main.Planner_ID, 0) = 0 OR Contract_Main.Retail_Planner_Program_Specific_Approval = 1) */
                                    AND ISNULL(PRPFPLA.Access_is_forbidden,0) = 0
                                </cfif>
                            <cfelse>
                                <!--- 113368:	Planner programs in program search / Anand Rao / 15-Feb-2022 --->
                                /* Display only Non-planner programs and that have Retail_Planner_Program_Specific_Approval set to 1 */
                                    AND (ISNULL(Contract_Main.Planner_ID, 0) = 0 OR Contract_Main.Retail_Planner_Program_Specific_Approval = 1)
                            </cfif>
                        </cfif>
						<!--- 83860 When coming from Customer Profile Viewer ---->
						<cfif request.AccessStructure.External_Customer_Profile_Access EQ "1">
						<cfif request.AccessStructure.External_Customer_Profile_Access_CustType EQ "D" OR request.AccessStructure.External_Customer_Profile_Access_CustType EQ "O">
						AND EXISTS (SELECT 1 FROM ##TmpPgmSrch_PgmForThisCustomer t WHERE t.Contract_Main_ID = Contract_Main.Contract_Main_ID)
						AND Contract_Main.Approved = 1
						<cfelse>
						AND 1=2
						</cfif>
						</cfif>

                        <!--- If user selects an option from the "Family" dropdown --->
                        <cfif form.family_list neq "">
                            AND Distributor_Family.Family_ID IN (#ListQualify(form.family_list, "'")#)
                        </cfif>
                        <!--- If user selects an option from the "Buying Group" dropdown --->
                        <cfif form.buying_group_list neq "">
                            AND Distributor_Buying_Groups.Buying_Group_ID IN (#ListQualify(form.buying_group_list, "'")#)
                        </cfif>
                        <!--- If user selects an option from the "RSP" dropdown --->
                        <cfif form.rsp_list neq "">
                            AND Contract_Main.Responsible_User_ID IN (#ListQualify(form.rsp_list, "'")#)
                        </cfif>

                        <!--- If user selects an option from the "status" dropdown --->
                        <cfif form.status_list neq "">
                            AND
                            (1 = 0
                                <cfloop list="#form.status_list#" index="local.i">
                                    <cfswitch expression="#local.i#"><!--- WIP,RFA,Pre-Active,Active,Expiring,Expired,Lost,Pending Accept --->
                                        <cfcase value="1,2,4,5,6,7,8,9,10">
                                                OR (Contract_Main.Contract_Status_Type_IDX = #local.i#)
                                        </cfcase>
                                        <cfcase value="101"><!--- Agreed --->
                                                OR (##tmp_Program_Agree_List.programId IS NOT NULL)
                                        </cfcase>
                                        <cfcase value="102"><!--- Pending Approval --->
                                                OR (##tmp_pending_approval_programs_list.Contract_Main_ID IS NOT NULL)
                                        </cfcase>
                                        <cfcase value="103"><!--- Under Review --->
                                                OR
                                                (	<!--- If program is in RFA status and the program is not in "Agreed" OR "Pending Approval" status, then
                                                 	the program is in the "Under Review" status.
                                                 	--->
                                                    (Contract_Main.Contract_Status_Type_IDX = 2)
                                                    AND (##tmp_Program_Agree_List.programId IS NULL AND ##tmp_pending_approval_programs_list.Contract_Main_ID IS NULL)
                                                )
                                        </cfcase>
                                        <cfcase value="104"><!--- Approved --->
                                                OR (Contract_Main.Contract_Status_Type_IDX IN (4,5,6,10))
                                        </cfcase>
                                        <cfcase value="105"><!--- Pending ERP Research --->
                                                OR (LEN(IsNull(Contract_Main.program_post_approval_status_id,'')) > 0 AND IsNull(Contract_Main.Manual_Cancel,0) = 0 AND IsNull(Contract_Main.program_post_approval_status_id,'') = 1)
                                        </cfcase>
                                        <cfcase value="106"><!--- Pending ERP Entry --->
                                                OR (LEN(IsNull(Contract_Main.program_post_approval_status_id,'')) > 0 AND IsNull(Contract_Main.Manual_Cancel,0) = 0 AND IsNull(Contract_Main.program_post_approval_status_id,'') = 2)
                                        </cfcase>
                                    </cfswitch>
                                </cfloop>
                            )
                        </cfif>     <!--- form.status_list neq "" --->
                        <!--- If user selects an option from the "template" dropdown --->
                        <cfif form.template_list neq "">
                            AND Contract_Main.First_Parent_ID IN (#ListQualify(form.template_list, "'")#)
                        </cfif>
                        <!--- If user selects an option from the "Workflow" dropdown --->
                        <cfif form.workflow_steps_list neq "">
                            AND
                            (1 = 0
                                <cfloop list="#form.workflow_steps_list#" index="local.i">
                                    <cfswitch expression="#local.i#">
                                        <cfcase value="1"><!--- Created By --->
                                            <cfif form.user_list neq "">
                                                OR (Contract_Main.Creator_ID IN (#ListQualify(form.user_list, "'")#))
											<cfelse>
												<cfif form.user_position_list neq "">
													OR (Contract_Main.Owner_Position_User_Positions_ID IN (#form.user_position_list#))
												</cfif>
											</cfif>
                                        </cfcase>
                                        <cfcase value="2"><!--- RFA By --->
                                            <cfif form.user_list neq "">
                                                OR (Contract_Main.Broker_User_ID IN (#ListQualify(form.user_list, "'")#))
											<cfelse>
												<cfif form.user_position_list neq "">
													OR (Contract_Main.RFA_Position_User_Positions_ID IN (#form.user_position_list#))
												</cfif>
											</cfif>
                                        </cfcase>
                                        <cfcase value="3"><!--- CRA --->
                                                OR (##Tmp_Program_CRA_List.Contract_Main_ID IS NOT NULL
                                                        /* ngt - filter by selected user */
                                                        <cfif form.user_list neq ''>
                                                            AND ##Tmp_Program_CRA_List.User_ID IN (#ListQualify(form.user_list, "'")#)
                                                        </cfif>
                                                    )
                                        </cfcase>
                                        <cfcase value="4"><!--- Approved By --->
                                            <cfif form.user_list neq "">
                                                OR (Contract_Main.Approved_By_User_ID IN (#ListQualify(form.user_list, "'")#))
											<cfelse>
												<cfif form.user_position_list neq "">
													OR (Contract_Main.Approver_Position_User_Positions_ID IN (#form.user_position_list#))
												</cfif>
											</cfif>
                                        </cfcase>
                                    </cfswitch>
                                </cfloop>
                            )
                        </cfif>     <!--- form.workflow_steps_list neq "" --->

                        <!--- If user selects an option from the "Conditions" dropdown --->
                        <cfif (form.condition_list neq "" AND ListFind(form.condition_list,"16") EQ 0 AND ListFind(form.condition_list,"17") EQ 0)>
                            AND
                            (1 = 0
                                <cfloop list="#form.condition_list#" index="local.i">
                                    <cfswitch expression="#local.i#">
                                        <cfcase value="1"><!--- Auto renewed --->
                                            OR (Contract_Main.is_autorenew = 1)
                                        </cfcase>
                                        <cfcase value="2"><!--- Auto renew pairs --->
                                            OR (Contract_Main.is_autorenew = 1 OR Contract_Main.Renewed = 1)
                                        </cfcase>
                                        <cfcase value="3"><!--- Best Plan Programs --->
                                            OR (Contract_Main.Best_Plan_Program = 1)
                                        </cfcase>
                                        <cfcase value="4"><!--- Cancelled --->
                                            OR (Contract_Main.Manual_Cancel = 1)
                                        </cfcase>
                                        <cfcase value="5"><!--- Disagreed --->
                                            OR (Len(Contract_Main.Disagreed_User_ID) > 0)
                                        </cfcase>
                                        <cfcase value="6"><!--- Doc attached --->
                                            OR Contract_Main.Contract_Attachments_Exists = 1
 <!---                                           (
                                                LEN((SELECT TOP 1 Program_ID
                                                       FROM Contract_Attachments
                                                      WHERE Contract_Attachments.Program_ID = Contract_Main.Contract_Main_ID
                                                            AND Contract_Attachments.Deleted = 0
                                                        )) > 0
                                            ) --->
                                        </cfcase>
                                        <cfcase value="7"><!--- Not Cancelled --->
                                            OR (Contract_Main.Manual_Cancel = 0)
                                        </cfcase>
                                        <cfcase value="8"><!--- Revision --->
                                            OR
                                            (   <!--- It has a revision --->
                                                (LEN(Contract_Main_1.Contract_Main_ID) > 0)
                                                OR
                                                (<!--- It's a revision --->
                                                    Contract_Main.Revision_Of_Contract_Main_ID != '' AND Contract_Main.Revision_Of_Contract_Main_ID IS NOT NULL
                                                    AND Contract_Main.Approved = 0 AND Contract_Main.Deleted = 0
                                                )
                                            )
                                        </cfcase>
                                        <cfcase value="9"><!--- Expiring No Revisions --->
                                            <!--- Where the program is expiring and it's revision does not exist --->
                                            OR
                                            (
                                                Contract_Main.Contract_Status_Type_IDX = 6 AND Revision_Exists = 0 )
 <!---                                               AND NOT EXISTS
                                                    (
                                                         SELECT 1
                                                           FROM Contract_Main Rev
                                                          WHERE Rev.Revision_of_Contract_Main_ID = Contract_Main.Contract_Main_ID
                                                                    AND  Rev.Deleted = 0
                                                    )
                                                ) --->
                                        </cfcase>
                                        <cfcase value="10"><!--- Rollover --->
                                            OR (LEN(LTRIM(Contract_Main.Rollover_From_Contract_Main_ID)) > 0)
                                        </cfcase>
                                        <cfcase value="11"><!--- Released --->
                                            OR (Contract_Main.Release_Settlement = 1 AND Contract_Main.Released = 1)
                                        </cfcase>
                                        <cfcase value="12"><!--- Not Released --->
                                            OR (Contract_Main.Release_Settlement = 1 AND Contract_Main.Released = 0)
                                        </cfcase>
                                        <cfcase value="13"><!--- Acknowledged --->
                                            OR (Contract_Main.Approved = 1 AND Contract_Main.sent_to_external_client = 1)
                                        </cfcase>
                                        <cfcase value="14"><!--- Not Acknowledged --->
                                            OR (Contract_Main.Manual_Cancel = 0 AND Contract_Main.Approved = 1 AND Contract_Main.sending_to_external_client = 1 AND Contract_Main.sent_to_external_client = 0 AND Contract_Main.Cancel_Sent_To_External_Client=0)
                                        </cfcase>
                                        <cfcase value="15"><!--- Uploaded --->
                                            OR (Contract_Main.Creation_Method = 2)
                                        </cfcase>
                                    </cfswitch>
                                </cfloop>
                            )
                        </cfif>     <!--- form.ccondition_list neq "" --->

                        <!--- If user selects an option from the "Action" dropdown --->
                        <cfif form.action_list neq "">
                                <!--- If the user requested for "catalog" records and the user only has "Read-only access" for catalog records, then the user is not allowed to delete the records. --->
                                AND NOT(#val(form.show_catalog)# = 1 AND #stSearch.Read_Only_Catalog_Access# = 1)
                            <!--- Delete (Logic to determine whether a program is eliigible to be deleted) --->
                            <cfif form.action_list eq 1>
                                AND Contract_Main.Contract_Status_Type_IDX <=2
                                AND
                                (
                                    (NOT(#appSettings.getDeleteIsCancelAutoRenew()# = 1 AND Contract_Main.Is_AutoRenew = 1) AND #Profile_Cont_Prog_View_Create_Program# = 1)
                                    OR
                                    (#Profile_Delete_Program_Access# = 1)
                                )
                                AND NOT(Contract_Main.Best_Plan_Program = 1 AND #Profile_Best_Plan_Program# = 0)
                            <!--- Edit Won/loss Status --->
                            <cfelseif form.action_list eq 2>
                                AND Contract_Main.Contract_Status_Type_IDX = 10
                            <!--- Mass Approve --->
                            <cfelseif form.action_list eq 3>
                                AND Contract_Main.Contract_Status_Type_IDX = 2
                                AND ISNULL( Contract_Main.Planner_ID, 0 ) = 0
                            <!--- Release --->
                            <cfelseif form.action_list eq 4>
                                <cfif appSettings.getReleaseSettlement() AND Get_Profile_Settings.Release_Settlement EQ 1>
                                    AND Contract_Main.Release_Settlement <> 0
                                    AND
                                        (
                                            (#appSettings.get_Setting('Release_Settlement_Availability')# <> '1')
                                            OR
                                            (
                                                Contract_Main.Sending_To_External_Client = 0 AND Contract_Main.Sent_To_External_Client = 1
                                                AND len(Contract_Main.Contract_Reference_Number) > 0 AND len(Contract_Main.External_Client_Ack_Date) > 0
                                            )
                                        )
                                    AND Contract_Main.Released = 0
                                     AND
                                     (
                                        Contract_Main.Contract_Status_Type_IDX = 5
                                        OR Contract_Main.Contract_Status_Type_IDX = 6
                                        OR Contract_Main.Contract_Status_Type_IDX = 7
                                     )
                                    <cfelse>
                                        AND 1 = 0
                                </cfif>
                            </cfif>
                        </cfif>
                        <!--- If user selects an option from the "Segment" dropdown --->
                        <cfif form.business_segment neq "">
                                AND Contract_Main.Business_Segment_ID IN (#form.business_segment#)
                        </cfif>

                        <!--- keyword search (program)--->
                        <cfif form.program_search neq "">
                        AND
                        (
                          (LTRIM(RTRIM(ISNULL(NULLIF(Contract_Main.contract_reference_number,''),0))) LIKE '%#form.program_search#%')
                          OR
                          (Contract_Main.Contract_Number LIKE '%#form.program_search#%')
                          OR
                          (Contract_Main.Contract_Title LIKE '%#form.program_search#%')
                          OR
                          (replace(Contract_Main.Contract_Number, '000-', '') + (CASE WHEN Contract_Main.Contract_Status_Type_IDX > 2 THEN '-' + CASE
									WHEN LEN(Contract_Main.revision_version) = 4 THEN RIGHT('000' + CAST(Contract_Main.revision_version AS VARCHAR(10)), 4)
									WHEN LEN(Contract_Main.revision_version) = 5 THEN RIGHT('000' + CAST(Contract_Main.revision_version AS VARCHAR(10)), 5)
									ELSE RIGHT('000' + CAST(Contract_Main.revision_version AS VARCHAR(10)), 3)
								END ELSE '' END) LIKE '%#form.program_search#%')
                          <cfif appSettings.getView_Legacy_ID() eq 1>
                          OR
                          (Contract_Main.legacy_deal_id LIKE '%#form.program_search#%')
                          </cfif>
                        )
                        </cfif>

                        <!--- If the user searches for programs using the "create list" feature --->
                        <cfif form.match_type gt 0 AND local.program_create_List neq "">
                            AND EXISTS
                            (
                                SELECT 1
                                  FROM ##tmp_program_create_list tbl_create_list
                                 WHERE cast(SubString(Contract_Main.Contract_Number,charIndex('-',Contract_Main.Contract_Number)+1,len(Contract_Main.Contract_Number)) as varchar(30))
                                        <cfif form.match_type eq 1>
                                            LIKE '%' + tbl_create_list.Create_list_Contract_Number + '%'
                                        <cfelse>
                                            = tbl_create_list.Create_list_Contract_Number
                                        </cfif>
                            )
                        </cfif>
						<!--- 96448	HF Bundle - Program Search - New Filtering Options / Anand Rao / 19-Oct-2020 --->
						<cfif (form.discount_type EQ 1 AND form.fixed_discount_types NEQ "")> 		<!--- Add INNER JOIN for Fixed Price --->
							AND	PFC.Program_Fixed_Component_Name_ID IN (#form.fixed_discount_types#)
							<cfif (form.rate_compare NEQ "" AND form.rate_val NEQ "")>
                                AND CASE WHEN pfppd.User_Picked_UOM != 0 THEN pfppd.User_Picked_Fixed_Price ELSE pfppd.Fixed_Price_Value END
                                    <cfif (form.rate_compare EQ 'Greater_Or_Equal')>>=<cfelseif (form.rate_compare EQ 'Equal')>=<cfelseif (form.rate_compare EQ 'Less_Or_Equal')><=</cfif>
								#form.rate_val#
							</cfif>
							<cfif (form.rate_uom NEQ "")>
                                AND CASE WHEN pfppd.User_Picked_UOM != 0 THEN pfppd.User_Picked_UOM ELSE pfppd.Unit_Of_Measure_Id END IN (#form.rate_uom#)
							</cfif>
						<cfelseif (form.discount_type EQ 2 AND form.rebate_discount_types NEQ "")> 	<!--- Add INNER JOIN for Rebates --->
							AND	PRC.Program_Rebates_Component_Name_ID IN (#form.rebate_discount_types#)
							<cfif (form.rate_compare NEQ "" AND form.rate_val NEQ "")>
								AND
                                    CASE
                                    WHEN prcd.User_Picked_uom = 0 THEN
                                        Cast( prcd.Rate AS FLOAT )
                                    /** -- CS -> Eaches  **/
                                    WHEN prcd.Unit_Of_Measure_Id = 1
                                        AND prcd.User_Picked_uom = 5 THEN
                                        Cast( prcd.Rate AS FLOAT ) / Isnull( NULLIF( i.Case_Count, 0 ), 1 )
                                    /** -- LB -> Eaches  **/
                                    WHEN prcd.Unit_Of_Measure_Id = 2
                                        AND prcd.User_Picked_uom = 5 THEN
                                        ( Cast( prcd.Rate AS FLOAT ) * Cast( i.Net_Weight AS FLOAT ) ) / Isnull( NULLIF( i.Case_Count, 0 ), 1 )
                                    /** -- CS -> CWT  **/
                                    WHEN prcd.Unit_Of_Measure_Id = 1
                                        AND prcd.User_Picked_uom = 6 THEN
                                        ( Cast( prcd.Rate AS FLOAT ) * 100.00 ) / Cast( i.Net_Weight AS FLOAT )
                                    /** -- LB -> CWT  **/
                                    WHEN prcd.Unit_Of_Measure_Id = 2
                                        AND prcd.User_Picked_uom = 6 THEN
                                        ( Cast( prcd.Rate AS FLOAT ) * 100.00 )
                                    /** -- CS -> Sleeves  **/
                                    WHEN prcd.Unit_Of_Measure_Id = 1
                                        AND prcd.User_Picked_uom = 7 THEN
                                        Cast( prcd.Rate AS FLOAT ) / Isnull( NULLIF( i.Sleeves_Per_Case, 0 ), 1 )
                                    /** -- LB -> Sleeves  **/
                                    WHEN prcd.Unit_Of_Measure_Id = 2
                                        AND prcd.User_Picked_uom = 7 THEN
                                        ( Cast( prcd.Rate AS FLOAT ) * Cast( i.Net_Weight AS FLOAT ) ) / Isnull( NULLIF( i.Sleeves_Per_Case, 0 ), 1 )
                                    ELSE
                                        Cast( prcd.Rate AS FLOAT )
                                    END

                                    <cfif (form.rate_compare EQ 'Greater_Or_Equal')>>=<cfelseif (form.rate_compare EQ 'Equal')>=<cfelseif (form.rate_compare EQ 'Less_Or_Equal')><=</cfif>

								    #form.rate_val#
							</cfif>
							<cfif (form.rate_uom NEQ "")>
								AND CASE WHEN prcd.User_Picked_UOM != 0 THEN prcd.User_Picked_UOM ELSE prcd.Unit_Of_Measure_Id END IN (#form.rate_uom#)
							</cfif>
						<cfelseif (form.discount_type EQ 3 AND form.lump_sum_discount_types NEQ "")> 	<!--- Add INNER JOIN for Lump Sum --->
							AND	PLS.Program_Lump_Sum_Name_ID IN  (#form.lump_sum_discount_types#)
							<!--- when the component is lumpsum use the rate fields for the LS Amount check --->
							<cfif (form.rate_compare NEQ "" AND form.rate_val NEQ "")>
								AND Cast( PLS.Lump_Sum_Amount AS FLOAT )	<cfif (form.rate_compare EQ 'Greater_Or_Equal')>>=<cfelseif (form.rate_compare EQ 'Equal')>=<cfelseif (form.rate_compare EQ 'Less_Or_Equal')><=</cfif>
								#form.rate_val#
							</cfif>
						<cfelseif (form.discount_type EQ 4 AND form.growth_discount_types NEQ "")> 	<!--- Add INNER JOIN for Growth --->
							AND	PGC.Program_Growth_Components_Name_Id IN  (#form.growth_discount_types#)
							<cfif (form.rate_compare NEQ "" AND form.rate_val NEQ "")>
								AND CAST(PGCPTD.Rate as FLOAT) <cfif (form.rate_compare EQ 'Greater_Or_Equal')>>=<cfelseif (form.rate_compare EQ 'Equal')>=<cfelseif (form.rate_compare EQ 'Less_Or_Equal')><=</cfif>
								#form.rate_val#
							</cfif>
							<cfif (form.rate_uom NEQ "")>
								AND PGCPTD.Unit_Of_Measure_ID IN (#form.rate_uom#)
							</cfif>
						</cfif>
                        <!---- 117289---->
                        <cfif appSettings.get_Setting('Quick_Pay_in_Program_Search') neq '0' AND form.fromQP>
                        AND isnull(Contract_Main.Claim_Mechanics,0) > 0
                        </cfif>

                 ) AS tmp

                 <cfif (appSettings.get_Setting('Quick_Pay_in_Program_Search') eq '2' AND Get_Profile_Settings.AQP_Available eq 1)>
                    UPDATE t
                    SET Pays_To_Distributor = 1, Accrual_On = 1
                    FROM ##tmp_search_programs_result t
                    WHERE EXISTS (
                                                /* Rebate */
                                                SELECT 1
                                                FROM Contract_Main c
                                                INNER JOIN  Program_Rebates_Component prc
                                                ON			prc.Program_ID = c.Contract_Main_ID
                                                AND			prc.Deleted =0
                                                INNER JOIN Program_Rebates_Component_Name prcn
                                                ON prcn.Program_Rebates_Component_Name_ID = prc.Program_Rebates_Component_Name_ID
                                                WHERE c.Contract_Number = t.Contract_Number --All program versions
                                                AND c.Approved = 1
                                                AND prc.Component_Paid_To = 1 --Payee = Distributor
                                                AND (( prcn.Accrual_On = 1 AND DBO.udf_GetAppSetting('Advance_Quick_Pay_Control') IN ( 1,3) ) /* Accrual & Accrual & Budget */
					                                        OR ( DBO.udf_GetAppSetting('Advance_Quick_Pay_Control') IN (2,4) ) /* Budget & Program Trade Estimate */
				                                        )

                                                UNION
                                                /* Lump sum */
                                                SELECT 1
                                                FROM Contract_Main c
                                                INNER JOIN  Program_Lump_Sums plc
                                                ON			plc.Program_ID = c.Contract_Main_ID
                                                AND			plc.Deleted =0
                                                INNER JOIN Program_Lump_Sum_Name plcn
                                                ON plcn.Program_Lump_Sum_Name_ID = plc.Program_Lump_Sum_Name_ID
                                                WHERE c.Contract_Number = t.Contract_Number /*  All program versions */
                                                AND c.Approved = 1
                                                AND plc.Component_Paid_To = 1 /*  Payee = Distributor */
                                                AND (( plcn.Accrual_On = 1 AND DBO.udf_GetAppSetting('Advance_Quick_Pay_Control') IN ( 1,3) ) /*  Accrual & Accrual & Budget */
					                                        OR ( DBO.udf_GetAppSetting('Advance_Quick_Pay_Control') IN (2,4) ) /*  Budget & Program Trade Estimate */
				                                        )

                                                UNION
                                                /* Fixed */
                                                SELECT 1
                                                FROM Contract_Main c
                                                INNER JOIN  Program_Fixed_Component pfc
                                                ON			pfc.Program_ID = c.Contract_Main_ID
                                                AND			pfc.Deleted =0
                                                INNER JOIN Program_Fixed_Component_Name pfcn
                                                ON pfcn.Program_Fixed_Component_Name_ID = pfc.Program_Fixed_Component_Name_ID
                                                WHERE c.Contract_Number = t.Contract_Number /* All program versions */
                                                AND c.Approved = 1
                                                AND pfc.Fixed_Component_Paid_to = 1 /*  Payee = Distributor */
                                                AND (( pfcn.Accrual_On = 1 AND DBO.udf_GetAppSetting('Advance_Quick_Pay_Control') IN ( 1,3) ) /* Accrual & Accrual & Budget */
                                                              OR  ( DBO.udf_GetAppSetting('Advance_Quick_Pay_Control') IN (2,4) ) /*  Budget & Program Trade Estimate */
                                                        )
                                            )
                 </cfif>
            <!--- If the user searches for programs using the "create list" feature, get data from the temp table --->
            <cfif (form.match_type gt 0 AND local.program_create_List neq "") OR (appSettings.get_Setting('Quick_Pay_in_Program_Search') eq '2' AND Get_Profile_Settings.AQP_Available eq 1)>
                SELECT * FROM  ##tmp_search_programs_result
            </cfif>
            <!--- Default logic for sorting --->
            <cfif form.sortColumn eq "">
                <cfset prgSettings = getPrgSettings()>
                ORDER BY #prgSettings.scorecard_Sort_option# #prgSettings.scorecard_sort_method#
            <cfelse>
            <!--- Whenever a user clicks on a particular column for sorting --->
					ORDER BY #form.sortColumn# #form.sortOrder#
			</cfif>

            OFFSET #form.startRow# ROWS
            FETCH NEXT #local.end_row# ROWS ONLY
        </cfquery>

		<!---<cfset local.timer.qGetProgramInfo = getTickCount() - local.timer.qGetProgramInfo>--->

        <!--- If the user searches for programs using the "create list" feature, find programs which are not valid amd make a comma-delimited list of those values. --->
        <cfif form.match_type gt 0 AND local.program_create_List neq "">
            <!--- use timeout attribute to allow CF to terminate excessive long queries --->
            <cfquery name="local.getInvalidCreateList" timeout="#local.timeout#" datasource="#application.datasource#">
                DECLARE @Invalid_Create_list VARCHAR(max)

                SELECT @Invalid_Create_list = (
                                                SELECT CAST(Create_list_Contract_Number as varchar(20)) + ','
                                                  FROM ##tmp_program_create_list tbl_create_list
                                                 WHERE NOT EXISTS
                                                                (
                                                                    SELECT 1
                                                                      FROM ##tmp_search_programs_result tbl_prg
                                                                     WHERE tbl_prg.searchableContractNumber
                                                                            <cfif form.match_type eq 1>
                                                                                LIKE '%' +  tbl_create_list.Create_list_Contract_Number + '%'
                                                                            <cfelse>
                                                                                = tbl_create_list.Create_list_Contract_Number
                                                                            </cfif>
                                                                )
                                                                FOR XML PATH('')
                )
                SELECT @Invalid_Create_list AS Invalid_Create_list
            </cfquery>

            <!--- Add the comma-delimited list of "invalid" program values to only the first valid program which is returned.
            There is no use adding this list for all the returned records.
            --->
			<cfif (local.qGetProgramInfo.recordcount GTE 1)>
	            <cfset querySetCell(local.qGetProgramInfo, "list_bad_rows", local.getInvalidCreateList.Invalid_Create_list, 1)>
			<cfelse>
				 <cfset temp = QueryAddRow(local.qGetProgramInfo)>
				 <cfset temp = QuerySetCell(local.qGetProgramInfo, "list_bad_rows", local.getInvalidCreateList.Invalid_Create_list, 1)>
			</cfif>
        </cfif>

        <cfreturn local.qGetProgramInfo>
    </cffunction>

    <!--- Copied logic from contract_approve_broker_action_include.cfm --->
    <cffunction name="rfaProgramEZButtonHandling" output="true" returntype="any">
        <cfargument name="programId"	required="true" type="numeric" />

		<cfscript>
			var ApprovalManager 	= CreateObject("component", "components.programs.Approval.ApprovalManager");
            var profile 	        = CreateObject("component", "components.user.Profile");
			var iProgramId 	        = 0;
            var bAutoApproveProgram = 0;
            var Approve_LS          = 0;

			iProgramId		        = arguments.programId;
            Get_Profile_Settings    = profile.getProfileSettings(request.AccessStructure.Profiles_ID);
            CSLGetContractInfo      = objProgram.getProgramInfo(iProgramId);
            GetSettings             = objTemplateManager.get(CSLGetContractInfo.ProgramType_ID);
            appSettings             = application.oApplicationAppSettingsManager.getApplicationAppSettings();

		</cfscript>

        <cfif Get_Profile_Settings.Cont_Prog_Approval_Rights EQ 1 and CSLGetContractInfo.EZButton_On EQ 1 and CSLGetContractInfo.EzButton_Auto_Approve_On EQ 1>
            <!--- When template setting on the EZButton Page called "Max Rate should consider" is  NOT "Rebate & Lumpsum". --->
            <cfif GetSettings.EzButton_Max_Rate_Consider neq 2>
                <!--- Check approval rights for lumpsum --->
                <cfinclude template="/Common_Files/contracts/common_lumpsum_approval_check.cfm">
                <!--- If program has lump sum. --->
                <cfif programLumpSum GT 0>
                    <cfif IsDefined("letUserProceed")>
                        <cfif letUserProceed eq 1>
                            <cfset Approve_LS = 1>
                        </cfif>
                        <!--- Default value of "letUserProceed" is 1 and so if the value is not 0, then use the default value. --->
                    <cfelse>
                        <cfset Approve_LS = 1>
                    </cfif>
                <cfelse>
                    <cfset Approve_LS = 1>
                </cfif>
            <cfelse>
                <cfset Approve_LS = 1>
            </cfif>

            <cfif Approve_LS eq 1><!--- If there is lumpsum, lumpsum should be approvable OR there is no lumpsum. --->
                <cfset qGetDiscountTypes = objProgram.getDiscountTypes(iProgramId) />
                <cfif not(len(objProgram.getprogramDiscounttypes(iProgramId)) eq 0 AND listFind(valuelist(qGetDiscountTypes.Product_Type_ID),3)) >
                    <cfset qProductsNotApproved = ApprovalManager.autoApproveEZProducts(iProgramId, request.AccessStructure.user_id)>
                    <cfif not qProductsNotApproved.recordCount><!--- If all the products are approved --->
                        <cfset bAutoApproveProgram = 1 />
                    </cfif>
                </cfif>
            </cfif>

        </cfif>

        <cfreturn bAutoApproveProgram />

    </cffunction>

    <!--- copied logic from contract_approve_broker_action_include.cfm --->
     <cffunction name="autoApproveProgram" output="true" returntype="any">
        <cfargument name="programId"	required="true" type="numeric" />

        <cfscript>
			var ApprovalManager 	= CreateObject("component", "components.programs.Approval.ApprovalManager");
            var profile 	        = CreateObject("component", "components.user.Profile");
			var iProgramId 	        = 0;

			iProgramId		        = arguments.programId;
            Get_Profile_Settings    = profile.getProfileSettings(request.AccessStructure.Profiles_ID);

		</cfscript>


        <cfif Get_Profile_Settings.program_margin_approval_method IS 4> <!--- spending cap --->
            <cfset program_id = iProgramId />
            <cfinclude template="/Common_Files/contracts/contract_approve_action_include.cfm" />
        <cfelse>
            <cfset form.approval_method = 5 /> <!--- layered --->
            <cfset form.Approved_By_User_ID = request.AccessStructure.user_id />
            <cfset Program_ID = iProgramId />
            <cfinclude template="/Common_Files/contracts/Contract_layered_approve_action_Auto.cfm" />
        </cfif>

    </cffunction>

    <cfscript>
        remote function last_refresh_datetime() output="false" returnformat="JSON" hint="Returns date-time of the last refresh data." {
            local.qRefresh = queryExecute( "SELECT Process_Date
                                              FROM Contract_Main_Program_Search_Log
                                             WHERE Current_Data_Flag = 1
                                                    ORDER BY program_search_log_id DESC"
                                            ,[] ,{ datasource = application.datasource }
                                    );

            return "Data as of " & dateFormat(local.qRefresh.Process_Date, "mmm d, yyyy") & ' ' & timeFormat(local.qRefresh.Process_Date, "short");
        }
    </cfscript>
</cfcomponent>