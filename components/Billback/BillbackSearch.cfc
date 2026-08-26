<!---
FILE: 		BA Application - Model: BillbackSearch Component
FILENAME:   BillbackSearch.cfc
CREATED:  	11/14/2008 - Brad Lee MMCP/ACI
EDITED:   	11/18/2008 - Brad Lee MMCP/ACI
EDITED:     29-May-09  - Anand Rao
            -Added the LEFT OUTER JOIN on Billback_Closing_Methods table
             for extracting the values based on the Billback_Closing_Method_ID
FUNCTIONALITY:
- ALL Billback searches are facilitated by this object. (BEST cached as application.oBillbackSearch)
Note: IF the MVC V7 is implemented, then searchBillbacks() would be a method within the new Model BillbackManager.
This is only intended for the legacy code. --->

<!--- COLDFUSION COMPONENT: Model - Billback [Search] --->
<cfcomponent displayname="BillbackSearch" hint="I am the billback blueprint in charge of all search retrieval from BA Billbacks within the business logic layer. I am modeled after the MVC V7 dna.">

    <!--- Set the initialization flag to "False" --->
	<cfparam name="this.bObjectInitialized" type="boolean" default="0">

	<!--- If the construction process has not yet run... --->
	<cfif NOT this.bObjectInitialized>

		<!--- ENTITY Model METHOD: init() [begin] --->
       <cffunction name="init" output="false" returntype="components.Billback.BillbackSearch" hint="I INITIALIZE the BILLBACK SEARCH object representing ALL Billback Search Retrieval in application scope." displayname="Initialize BillbackSearch">

            <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
            <cfargument name="stBillbackSearchDNA" type="struct" required="false" hint="Billback Manager Info" default="#structNew()#">

            <!--- init... --->

			<!--- Set up the object skeleton --->
            <cfscript>
				if (structKeyExists(this, "objName") == false){
	                structInsert(this, 	"objName", 				uCase(application.applicationName) & " Application BillbackSearch");
	                structInsert(this, 	"objDateTimeCreated", 	createODBCDateTime(now()));
	                structInsert(this, 	"objDirectory",   		"components/Billback");
	                structInsert(this, 	"objParentObject",   	"Legacy Call");
	                structInsert(this, 	"objParentUserID",   	"na");
	                structInsert(this, 	"stObjectInfo",   		structNew(),true);

	                this.stObjectInfo.name 						= "The " & Ucase(application.applicationName) & " BillbackSearch";
	                this.stObjectInfo.description 				= "I govern all BILLBACK search requests for the " & Ucase(application.applicationName) & "  Application.";
	                this.stObjectInfo.lockTimeoutSeconds		= 15;

					//override our initial settings
	                structAppend(this,arguments.stBillbackSearchDNA,true);

	                structInsert(this,	"bObjectInitialized", 	1,true);
               }
            </cfscript>

            <!--- Return the final container to the caller --->
            <cfreturn this>

        </cffunction>
        <!--- ENTITY Model METHOD: init() [end] --->

	</cfif>

	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::
    :::::::::::: BillbackSearch Methods in alpha  :::::::::::
    :::: [including BillbackBean's Getters() & Setters()] ::::
    ::::::::::::::::::::::::::::::::::::::::::::: [begin] --->

    <!--- New METHOD: getScorecardBillbackContent() FUNCTIONALITY: I retrieve Scorecard Billback Content. [begin] --->
    <cffunction name="getScorecardBillbackContent" access="public" output="no" returntype="query"
		hint="I retrieve Scorecard Billback Content."
		displayname="Model > Billback > getScorecardBillbackContent()">

        <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
        <!--- ALWAYS employ argumentcollection ... --->

        <!--- let's set our initial values... --->
        <cfset var var_qScorecardBillbackContent = queryNew('cols')>
        <!--- <cfset var var_forbidType = ''> per Ana / Brad... --->
        <cfset var var_programScorecardRestrictCreatedByUserId = ''>
        <cfset var var_qUserNumber = ''>
        <cfset var var_qUser = ''>
        <cfset var var_apply_template_profile_filter = 1 />

	<cfquery name="delete_tmp_tables" datasource="#application.datasource#">
        <!---IF OBJECT_ID('tempdb..##tmp_billack_pre_filter') IS NOT NULL
	    DROP TABLE ##tmp_billack_pre_filter
	    --->

	    IF OBJECT_ID('tempdb..##tmp_billacks_cannot_see') IS NOT NULL
	    DROP TABLE ##tmp_billacks_cannot_see

	    IF OBJECT_ID('tempdb..##tmp_billack_templates') IS NOT NULL
	    DROP TABLE ##tmp_billack_templates

	    IF OBJECT_ID('tempdb..##tmp_billback_search_result') IS NOT NULL
	    DROP TABLE ##tmp_billback_search_result
	</cfquery>

        <cfquery name="var_qScorecardBillbackContent" datasource="#application.datasource#">
            set transaction isolation level read uncommitted
            <cfif NOT arguments.UserIsAnalyst>
                #PreserveSingleQuotes(arguments.AllowBillbackIDs)#
            <cfelse>
                #PreserveSingleQuotes(arguments.AllowAnalystIds)#
            </cfif>

            <cfif var_apply_template_profile_filter>

            <cfset var_forbidType = arguments.appSettings.getForbidAllowProfilesInTemplates() />

                DECLARE @Profile_Forbidden_Template table
                (
                Template_ID   int          NOT NULL PRIMARY KEY,
                Forbid_Access_Type int          NOT NULL
                )
                INSERT INTO @Profile_Forbidden_Template (Template_ID, Forbid_Access_Type)
                select 	distinct template_id, Forbid_Access_Type
                from 	Profile_Forbidden_Template
                where 	Deleted = 0
                AND Forbid_Type = #var_forbidType#
                AND Forbid_Access_Type = 1
                AND profile_id = #arguments.Get_Profile_Settings.Profiles_ID#

                DECLARE @Profile_Forbidden_Template_BB_Approve table
                (
                Template_ID   int          NOT NULL PRIMARY KEY,
                Forbid_Access_Type int          NOT NULL
                )
                INSERT INTO @Profile_Forbidden_Template_BB_Approve (Template_ID, Forbid_Access_Type)
                select 	distinct template_id, Forbid_Access_Type
                from 	Profile_Forbidden_Template
                where 	Deleted = 0
                AND Forbid_Type = #var_forbidType#
                AND Forbid_Access_Type = 4
                AND profile_id = #arguments.Get_Profile_Settings.Profiles_ID#
				<!---
                CREATE table ##tmp_billack_pre_filter
				(
					Billback_ID uniqueidentifier NOT NULL PRIMARY KEY
				)

				INSERT INTO ##tmp_billack_pre_filter (Billback_ID)
				SELECT 	Billback_ID
                FROM	Billback
                WHERE	Deleted = 0

                <!--- find the distinct templates in each billback --->
                SELECT 	DISTINCT Billback_Program.Billback_ID, Contract_Main.ProgramType_ID
                INTO	##tmp_billack_templates
                        FROM 	##tmp_billack_pre_filter
                INNER JOIN Billback_Program
                ON	##tmp_billack_pre_filter.Billback_ID = Billback_Program.Billback_ID
                AND	Billback_Program.Deleted = 0
                        INNER JOIN Contract_Main
                        ON 	Billback_Program.Program_ID = Contract_Main.Contract_Main_ID

                <!--- find the billbacks with templates that the current user should not see --->
                CREATE table ##tmp_billacks_cannot_see
				(
					Billback_ID uniqueidentifier NOT NULL PRIMARY KEY
				)
				INSERT INTO ##tmp_billacks_cannot_see (Billback_ID)
				SELECT	Billback_ID
                FROM	##tmp_billack_templates
                WHERE	ProgramType_ID
                <cfif var_forbidType EQ 0>not </cfif><!------ forbit type=1, forbid, 0=allow ----->
                IN (select Template_ID from @Profile_Forbidden_Template)

                drop table ##tmp_billack_templates
            	--->

				IF OBJECT_ID('tempdb..##tmp_billacks_cannot_see') IS NOT NULL
	    		DROP TABLE ##tmp_billacks_cannot_see

				CREATE table ##tmp_billacks_cannot_see
				(
					Billback_ID uniqueidentifier NOT NULL PRIMARY KEY
				)
				INSERT INTO ##tmp_billacks_cannot_see (Billback_ID)
		        SELECT     DISTINCT Billback.Billback_ID
		        FROM Billback
		        INNER JOIN Billback_Program
		        ON    Billback.Billback_ID = Billback_Program.Billback_ID
		        AND   Billback_Program.Deleted = 0
		        INNER JOIN Contract_Main
		        ON      Billback_Program.Program_ID = Contract_Main.Contract_Main_ID
		        WHERE Billback.Deleted = 0
		        and   ProgramType_ID
				<cfif var_forbidType EQ 0>not </cfif><!------ forbit type=1, forbid, 0=allow ----->
				IN (select Template_ID from @Profile_Forbidden_Template)

				IF OBJECT_ID('tempdb..##tmp_billacks_cannot_approve') IS NOT NULL
	    		DROP TABLE ##tmp_billacks_cannot_approve
				CREATE table ##tmp_billacks_cannot_approve
				(
					Billback_ID uniqueidentifier NOT NULL PRIMARY KEY
				)
				INSERT INTO ##tmp_billacks_cannot_approve (Billback_ID)
		        SELECT     DISTINCT Billback.Billback_ID
		        FROM Billback
		        INNER JOIN Billback_Program
		        ON    Billback.Billback_ID = Billback_Program.Billback_ID
		        AND   Billback_Program.Deleted = 0
		        INNER JOIN Contract_Main
		        ON      Billback_Program.Program_ID = Contract_Main.Contract_Main_ID
		        WHERE Billback.Deleted = 0
		        and   ProgramType_ID
				<cfif var_forbidType EQ 0>not </cfif><!------ forbit type=1, forbid, 0=allow ----->
				IN (select Template_ID from @Profile_Forbidden_Template_BB_Approve)
            </cfif>

            SELECT DISTINCT
				<cfif isDefined("arguments.startrow") and isDefined("arguments.endrow")>
					RowID=IDENTITY (int, 1, 1),
				</cfif>
                <cfif arguments.businessSegmentsOn>
                isnull((select top 1 business_unit_desc from business_segment where Business_Segment_ID in ( select top 1 Business_Segment_ID from contract_main where contract_main_id in (select top 1 program_id from billback_program where billback_program.billback_id = billback.billback_id))),'Unassigned')
                <cfelse>
                ''
                </cfif> as business_unit_desc,
				ISNULL((select top 1 Set_Billbacks_To_Paid_No_Interface from Program_Control_Panel_Options where ProgramControl_Panel_Options_ID in ( select top 1 ProgramType_ID from contract_main where contract_main_id in (select top 1 program_id from billback_program where billback_program.billback_id = billback.billback_id))),'0')
             as Set_Billbacks_To_Paid_No_Interface,
                Billback_Allied.BB_Is_Locked, Billback_Allied.BB_Locked_By_User_ID, Billback.*,
                <cfif arguments.appSettings.get_Setting('Claim_Less_Than_Expected_Deviation') eq "1">
                	ABS(Billback.BB_Amount-Billback.BB_Expected_Amount) as BB_Variance,
                <cfelse>
                	(Billback.BB_Amount-Billback.BB_Expected_Amount) as BB_Variance,
                </cfif>
			<!---
            CASE
                WHEN Billback.Billback_Payee_Type_ID=1 THEN
                ISNULL(BSA_Foodservice_Customers.Name,VM.Vendor_Name)
                --BSA_Foodservice_Customers.Name
                WHEN Billback.Billback_Payee_Type_ID=2 THEN
                BSA_Operator.Operator_Name

                WHEN Billback.Billback_Payee_Type_ID=3 THEN
                BSA_Foodservice_Brokers.Broker_Name

                WHEN Billback.Billback_Payee_Type_ID=4 THEN
                Billback_Unidentified_Payee.BB_UP_Name

                WHEN Billback.Billback_Payee_Type_ID=5 THEN
                Billback_Distributor.BB_Distributor_Name

                WHEN Billback.Billback_Payee_Type_ID=6 THEN
                Billback_Operator.BB_Operator_Name

                WHEN Billback.Billback_Payee_Type_ID=7 THEN
                Billback_Broker.BB_Broker_Name

            END AS Payee_Name,
			--->
			<!---
            (	SELECT 	Count(Contract_Attachments.Deleted)
                FROM 	Contract_Attachments
                INNER JOIN 	Document_Details ON contract_attachments.Doc_ID = Document_Details.Doc_ID
                            AND (	(	Public_View = 1
                                        AND User_Position_ID IN (#preserveSingleQuotes(arguments.GP_Position_List_From_My_Position_Down)#)
                                    )
                                        OR Public_View = 0
                                )
                WHERE 	Contract_Attachments.Billback_ID = Billback.Billback_ID
                        AND Contract_Attachments.Deleted = 0) AS Document_Count,
			--->
            <cfif arguments.section_to_open GT 2>
            ISNull(BB_Approved.Paid_Amount, 0) AS BB_Approved_Amount,
            <cfelse>
            '' AS BB_Approved_Amount,
            </cfif>
            <cfif application.returned_customer_setting.Accounting_Specialist eq 1>
            Billback_Program.Program_ID,
            ppUsers.Name_Last,
            </cfif>
			<!---
            Position_To_Approve.Position_Label Position_To_Approve_Label,
            Approve_Authority_Sequence.Authority_Sequence_Name Approve_Authority_Sequence_Name,
            Position_To_Approve.Position_Label Position_To_Approve_Label,
            Approve_Authority_Sequence.Authority_Sequence_Name Approve_Authority_Sequence_Name,
			--->
			<!---Billback.Auto_Billback,
            Billback.BB_Payment_Request_Sent,
            Billback.BB_Payment_Request_Sent_On,
            Billback.BB_Received_Ack_Type,
            Billback.BB_Received_Ack_Date,--->
            BB_Approved.Voucher_Number,
           <!--- Billback.BB_Approved_Void_Sent_On,
            Billback.BB_Approved_Void_Ack_Type,
            Billback.BB_Approved_Void_Ack_Date,--->
            Billback_Closing_Methods.Abbreviation,
            Billback_Closing_Methods.vchBillback_Closing_Method_Desc,
            BBanalyst.Name_first as BBanalyst_Name_first,
            BBanalyst.Name_last as BBanalyst_Name_last,

			<!--- START: Adding the Payee within the Search --->
			Payee_name =
			CASE WHEN  Billback.Billback_Payee_Type_ID = 1
			THEN
			/* Distributor */
			(SELECT DISTINCT TOP 1 ISNULL(BSA_Foodservice_Customers.Name,VM.Vendor_Name)
				FROM Billback_Distributor
				LEFT JOIN BSA_Foodservice_Customers
					ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Billback_Distributor.Distributor_ID
				LEFT JOIN Vendor_Master VM ON /* added VM join for Auto Pay w/multiple distributors */
					VM.vendor_Master_Id = Billback_Distributor.Distributor_ID
				WHERE	Billback_Distributor.Billback_ID = Billback.Billback_ID AND
					Billback_Distributor.Deleted = 0)

			WHEN Billback_Payee_Type_ID = 2 THEN
			/* Operator */
			(SELECT DISTINCT TOP 1 BSA_Operator.Operator_Name
				FROM BSA_Operator
				INNER JOIN Billback_Operator
					ON Billback_Operator.Billback_ID = Billback.Billback_ID
					AND Billback_Operator.Deleted = 0
					AND BSA_Operator.BSA_Operator_ID = Billback_Operator.Operator_ID)
			/* Broker */
			WHEN Billback_Payee_Type_ID = 3 THEN
			(SELECT DISTINCT TOP 1 BSA_Foodservice_Brokers.Broker_Name
				FROM BSA_Foodservice_Brokers
				INNER JOIN Billback_Broker
					ON Billback_Broker.Billback_ID = Billback.Billback_ID
					AND Billback_Broker.Deleted = 0
					AND BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Billback_Broker.Broker_ID)
			WHEN Billback_Payee_Type_ID = NULL THEN
			'NA'
		END
			<!--- END: Adding the Payee within the Search --->
			<!--- START: Payee ID--->
		,Payee_ID =
			CASE WHEN  Billback.Billback_Payee_Type_ID = 1
			THEN
			/* Distributor */
			(SELECT DISTINCT TOP 1 ISNULL(BSA_Foodservice_Customers.Ship_To,VM.Vendor_ID)
				FROM Billback_Distributor
				LEFT JOIN BSA_Foodservice_Customers
					ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Billback_Distributor.Distributor_ID
				LEFT JOIN Vendor_Master VM ON /* added VM join for Auto Pay w/multiple distributors */
					VM.vendor_Master_Id = Billback_Distributor.Distributor_ID
				WHERE	Billback_Distributor.Billback_ID = Billback.Billback_ID AND
					Billback_Distributor.Deleted = 0)

			WHEN Billback_Payee_Type_ID = 2 THEN
			/* Operator */
			(SELECT DISTINCT TOP 1 CAST(BSA_Operator.BSA_Operator_ID AS VARCHAR(50))
				FROM BSA_Operator
				INNER JOIN Billback_Operator
					ON Billback_Operator.Billback_ID = Billback.Billback_ID
					AND Billback_Operator.Deleted = 0
					AND BSA_Operator.BSA_Operator_ID = Billback_Operator.Operator_ID)
			/* Broker */
			WHEN Billback_Payee_Type_ID = 3 THEN
			(SELECT DISTINCT TOP 1 BSA_Foodservice_Brokers.Broker_Shard
				FROM BSA_Foodservice_Brokers
				INNER JOIN Billback_Broker
					ON Billback_Broker.Billback_ID = Billback.Billback_ID
					AND Billback_Broker.Deleted = 0
					AND BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Billback_Broker.Broker_ID)
			WHEN Billback_Payee_Type_ID = NULL THEN
			'NA'
		END
			<!--- END: Payee ID--->

            <cfif isDefined("arguments.startrow") and isDefined("arguments.endrow")>
				into ##tmp_billback_search_result
			</cfif>
            <!------ FROM BEGIN ----->
            FROM
            Billback
            LEFT JOIN Program_Agree_Status
            ON
            1=2
            <cfif arguments.Get_Profile_Settings.BB_RFA_Agreed EQ 1>
            OR
            Billback.Billback_Status_ID = 2
            </cfif>
            LEFT JOIN
            Billback_Allied
            ON (Billback_Allied.Billback_ID = Billback.Billback_ID)
            LEFT JOIN Billback_Closing_Methods
            ON (Billback.BB_Closing_Method = Billback_Closing_Methods.iBillback_Closing_Method_ID)
			<!---
            LEFT JOIN
            (
            Billback_Broker
            LEFT JOIN
            BSA_Foodservice_Brokers
            ON
            (Billback_Broker.Broker_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID)
            )
            ON
            (
            (Billback_Broker.Billback_ID = Billback.Billback_ID)
            AND
            (
                (Billback.Billback_Payee_Type_ID = 3)
                OR
                (Billback.Billback_Payee_Type_ID = 7)
            )
            AND
            (Billback_Broker.Deleted = 0)
            )

            LEFT JOIN
            (
            Billback_Distributor
            LEFT JOIN
            BSA_Foodservice_Customers
            ON
            (Billback_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID)
            )
            ON
            (
            (Billback_Distributor.Billback_ID = Billback.Billback_ID)
            AND
            (
                (Billback.Billback_Payee_Type_ID = 1)
                <!---OR
                (Billback.Billback_Payee_Type_ID = 5)--->
            )
            AND
            (Billback_Distributor.Deleted = 0)
            )

            LEFT JOIN Vendor_Master VM ON ---added VM join for Auto Pay w/multiple distributors
                    VM.vendor_Master_Id = Billback_Distributor.Distributor_ID
            LEFT JOIN
            (
            Billback_Operator
            LEFT JOIN
            BSA_Operator
            ON
            (Billback_Operator.Operator_ID = BSA_Operator.BSA_Operator_ID)
            )
            ON
            (
            (Billback_Operator.Billback_ID = Billback.Billback_ID)
            AND
            (
                (Billback.Billback_Payee_Type_ID = 2)
                OR
                (Billback.Billback_Payee_Type_ID = 6)
            )
            AND
            (Billback_Operator.Deleted = 0)
            )

            LEFT JOIN Billback_Unidentified_Payee
            ON
            (
            (Billback_Unidentified_Payee.Billback_ID = Billback.Billback_ID)
            AND
            (Billback.Billback_Payee_Type_ID = 4)
            AND
            (Billback_Unidentified_Payee.Deleted = 0)
            )
			--->
            LEFT JOIN BB_Approved
            ON
            BB_Approved.Billback_ID = Billback.Billback_ID
            AND
            Billback.Billback_Status_ID > 2
            <cfif application.returned_customer_setting.Accounting_Specialist eq 1>
                LEFT JOIN Billback_Program ON
                    Billback_Program.Billback_ID = Billback.Billback_ID
                    AND Billback_Program.Deleted = 0
                LEFT JOIN Program_Accounting_Specialist ON
                    Program_Accounting_Specialist.Program_ID = Billback_Program.Program_ID
                    AND Program_Accounting_Specialist.Deleted = 0
                LEFT JOIN _users ppUsers
                    ON ppUsers.User_ID = Program_Accounting_Specialist.User_ID
            </cfif>
            <!------ Display CRA ----->
			<!---
            LEFT JOIN User_Positions Position_To_Approve
            ON 	Position_To_Approve.User_Positions_ID =
            (
            SELECT	TOP 1 User_positions_ID
            FROM	BillbackApprovablePositions
            WHERE	BillbackApprovablePositions.Billback_ID = Billback.Billback_ID
                     AND NOT EXISTS
                                  (	SELECT DISTINCT BB_Agreed_Info.User_Position_ID
                                    FROM       	BB_Agreed_Info
                        LEFT JOIN	Authority_Sequence
                        ON			Authority_Sequence.Authority_Sequence_ID = BB_Agreed_Info.Authority_Sequence_ID
                                    WHERE      	BB_Agreed_Info.Billback_ID = Billback.Billback_ID
                                    AND			BB_Agreed_Info.Deleted = 0
                                    AND User_Positions_ID IS NOT NULL
                                    AND		BillbackApprovablePositions.User_Positions_ID = BB_Agreed_Info.User_Position_ID
                                    AND		ISNULL(BillbackApprovablePositions.Authority_Sequence_Order, 0) = ISNULL(Authority_Sequence.Authority_Sequence_Order, 0)
                       )
            ORDER BY BillbackApprovablePositions.Service_Market_ID DESC, BillbackApprovablePositions.Service_Region_ID DESC, BillbackApprovablePositions.Service_Zone_ID DESC, BillbackApprovablePositions.Authority_Sequence_Order DESC
            )
            LEFT JOIN Authority_Sequence Approve_Authority_Sequence
            ON
            Position_To_Approve.Service_Market_ID IS NULL
            AND Position_To_Approve.Service_Region_ID IS NULL
            AND Position_To_Approve.Service_Zone_ID IS NULL
            AND Approve_Authority_Sequence.Deleted = 0
            AND Approve_Authority_Sequence.Authority_Sequence_Order =
            (
            SELECT	TOP 1 Authority_Sequence_Order
            FROM	BillbackApprovablePositions
            WHERE	BillbackApprovablePositions.Billback_ID = Billback.Billback_ID
                     AND NOT EXISTS
                                  (	SELECT DISTINCT User_Position_ID
                                    FROM       	BB_Agreed_Info
                        LEFT JOIN	Authority_Sequence
                        ON			Authority_Sequence.Authority_Sequence_ID = BB_Agreed_Info.Authority_Sequence_ID
                                    WHERE      	BB_Agreed_Info.Billback_ID = Billback.Billback_ID
                                    AND			BB_Agreed_Info.Deleted = 0
                                    AND User_Positions_ID IS NOT NULL
                                    AND		BillbackApprovablePositions.User_Positions_ID = BB_Agreed_Info.User_Position_ID
                                    AND		ISNULL(BillbackApprovablePositions.Authority_Sequence_Order, 0) = ISNULL(Authority_Sequence.Authority_Sequence_Order, 0)
                        <!------
                        <cfif this.search.RFA_Agreed EQ 2>
                                    AND Executive_Agreement = 1
                        </cfif>
                        ----->
                       )
            ORDER BY BillbackApprovablePositions.Service_Market_ID DESC, BillbackApprovablePositions.Service_Region_ID DESC, BillbackApprovablePositions.Service_Zone_ID DESC, BillbackApprovablePositions.Authority_Sequence_Order DESC
            )
			--->
            <!------ Display CRA ----->
            LEFT JOIN _users BBanalyst
                    ON BBanalyst.User_ID = Billback.Analyst_User_ID
            <!------ WHERE CLAUSE BEGIN ----->
            WHERE
            Billback.Deleted = 0
            <cfif var_apply_template_profile_filter>
            AND Billback.Billback_ID NOT IN (select Billback_ID FROM ##tmp_billacks_cannot_see)
            </cfif>
            AND Billback.Billback_Status_ID = #arguments.section_to_open#
			<cfif (arguments.section_to_open EQ 9)>
				AND (DATEDIFF(d, GETDATE(), BB_Date)) >= -730
			</cfif>
			<!--- 114068: Billback authority not checking Segment / Anand Rao / 29-Mar-2022 --->
			<cfif (arguments.businessSegmentsOn AND structKeyExists(request.AccessStructure, "User_Business_Segments") and len(request.AccessStructure.User_Business_Segments))>
           		AND   ( isnull(( select top 1 Business_Segment_ID from contract_main where contract_main_id in (select top 1 program_id from billback_program where billback_program.billback_id = billback.billback_id)),0)
IN (#request.AccessStructure.User_Business_Segments#))
			</cfif>
            <cfif arguments.HQUser IS NOT 1 OR arguments.UserIsAnalyst EQ 1><!--- if user is an analyst or not HQ --->
            AND (Billback.BB_Creator_ID = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
                <cfif arguments.UserIsAnalyst EQ 0>
                    OR Billback.BB_Creator_User_Position_ID IN (#PreserveSingleQuotes(arguments.UserPositionList)#)
                    <cfif listlen(arguments.BillbackIDs) GT 0>
                    OR Billback.Billback_ID IN (#preservesinglequotes(arguments.BillBackIDs)#)
                    </cfif>
                <cfelse><!------ If billback analyst do not look at the position tree, use the analyst logic alone ----->
                    <cfif arguments.AnalystList NEQ "">
                    OR	Billback.Analyst_User_ID IN (#PreserveSingleQuotes(arguments.AnalystList)#)
                    OR	Billback.BB_Creator_ID IN (#PreserveSingleQuotes(arguments.AnalystList)#)
                    </cfif>
                </cfif>
                )
            </cfif>

                    <cfif arguments.Get_Profile_Settings.Program_Scorecard_Restrict_Created_By>
                            <!--- If the below profile settings is on, then the user should only be allowed to see programs
                        that have him/her as an RSP OR where the program creator's RSP has the user number same as
                        this user's User number
                    --->

                    AND NOT EXISTS
                    (
                        <cfset var_programScorecardRestrictCreatedByUserId = request.AccessStructure.user_id>
                        <cfset var_qUserNumber = "" />
                        <cfif arguments.appSettings.getUserNumberRestrict()>
                            <cfset var_qUser = createObject("component", "components.user.UserManager").getUser(var_programScorecardRestrictCreatedByUserId) />
                            <cfset var_qUserNumber = var_qUser.User_Number />
                        </cfif>
                        SELECT Billback_ID
                        FROM Billback_Program
                        INNER JOIN Contract_Main
                        ON Billback_Program.Program_ID = Contract_Main.Contract_Main_ID
                        LEFT JOIN _Users responsibleSalesPerson
                        ON 	responsibleSalesPerson.User_ID = Contract_Main.Responsible_User_ID
                        AND	responsibleSalesPerson.Deleted = 0
                        WHERE Billback_Program.Billback_ID = Billback.Billback_ID
                        AND Billback_Program.Deleted = 0
                        AND(
                        Isnull(rtrim(ltrim(Contract_Main.Responsible_User_ID)),'') != '#var_programScorecardRestrictCreatedByUserId#'
                            <cfif Len(var_qUserNumber) GT 0>
                        AND Isnull(rtrim(ltrim(responsibleSalesPerson.User_Number)),'') != '#var_qUserNumber#'
                            </cfif>
                        )
                    )
                    </cfif>
            <cfif isDefined("arguments.program_agree_status_ID")>
                <cfif arguments.program_agree_status_ID EQ 1>
                AND
                ( Billback.Billback_Status_ID = 2 AND Program_Agree_Status.Program_Agree_Status_ID = 1
                  AND Not Exists
                    (SELECT * FROM BB_Agreed_Info WHERE Deleted = 0 AND Billback_ID = Billback.Billback_ID AND User_position_ID IN (#PreserveSingleQuotes(arguments.UserPositionList)#) AND Authority_Sequence_ID = '#arguments.Auth_Sequence_ID#')
                  AND
                    (
                        #arguments.Get_Profile_Settings.BB_Approve# = 0

				        <cfif var_apply_template_profile_filter><!--- User cannot approve this billback --->
			            OR Billback.Billback_ID IN (select Billback_ID FROM ##tmp_billacks_cannot_approve)
			            </cfif>
                        OR

                        ((	SELECT 	Top 1 User_positions_ID
                                FROM 	Billback_Approvable_Positions as BillbackApprovablePositions
                                WHERE 	BillbackApprovablePositions.Billback_ID = Billback.Billback_ID AND
                                        NOT (	(	ISNULL(Authority_Sequence_Order, 0) = 0 OR
                                                    Authority_Sequence_Order IN (	SELECT 		ISNULL(Authority_Sequence_ORDER,0)
                                                                                    FROM 		BB_Agreed_Info
                                                                                    INNER JOIN 	Authority_Sequence ON Authority_Sequence.Authority_Sequence_ID = BB_Agreed_Info.Authority_Sequence_ID
                                                                                    WHERE 		Billback_ID = Billback.Billback_ID
                                                                                    AND			BB_Agreed_Info.Deleted = 0)
                                                ) AND
                                                User_positions_ID IN (		SELECT 	DISTINCT User_position_ID
                                                                            FROM 	BB_Agreed_Info
                                                                            WHERE 	Billback_ID = Billback.Billback_ID AND
                                                                            Deleted = 0)
                                            )
                            ORDER BY BillbackApprovablePositions.Service_Market_ID DESC, BillbackApprovablePositions.Service_Region_ID DESC, BillbackApprovablePositions.Service_Zone_ID DESC, BillbackApprovablePositions.Authority_Sequence_Order DESC
                            ) NOT IN (#PreserveSingleQuotes(arguments.UserPositionList)#) )
                        OR

                        (	ISNULL((	SELECT 	Top 1 Authority_Sequence_Order
                                        FROM 	Billback_Approvable_Positions as BillbackApprovablePositions
                                        WHERE 	BillbackApprovablePositions.Billback_ID = Billback.Billback_ID AND
                                                NOT (	(	ISNULL(Authority_Sequence_Order, 0) = 0 OR
                                                            Authority_Sequence_Order IN (	SELECT ISNULL(Authority_Sequence_ORDER,0)
                                                                                            FROM BB_Agreed_Info
                                                                                            INNER JOIN Authority_Sequence ON Authority_Sequence.Authority_Sequence_ID = BB_Agreed_Info.Authority_Sequence_ID
                                                                                            WHERE Billback_ID = Billback.Billback_ID
                                                                                            AND			BB_Agreed_Info.Deleted = 0)
                                                        ) AND
                                                        User_positions_ID IN (		SELECT 	DISTINCT User_position_ID
                                                                                    FROM 	BB_Agreed_Info
                                                                                    WHERE 	Billback_ID = Billback.Billback_ID AND
                                                                                    Deleted = 0)
                                                    )
                                        ORDER BY BillbackApprovablePositions.Service_Market_ID DESC, BillbackApprovablePositions.Service_Region_ID DESC, BillbackApprovablePositions.Service_Zone_ID DESC, BillbackApprovablePositions.Authority_Sequence_Order DESC
                                    ),0) <> '#arguments.Auth_Sequence_Order#'
                        )
                    )
                )
                <cfelseif arguments.program_agree_status_ID EQ 2>
                AND
                ( Billback.Billback_Status_ID = 2 AND Program_Agree_Status.Program_Agree_Status_ID = 2 AND
                  Not Exists
                    (SELECT * FROM BB_Agreed_Info WHERE Deleted = 0 AND Billback_ID = Billback.Billback_ID AND User_position_ID IN (#PreserveSingleQuotes(arguments.UserPositionList)#) AND Authority_Sequence_ID = '#arguments.Auth_Sequence_ID#')
                  AND
                    (
                        #arguments.Get_Profile_Settings.BB_Approve# = 1

				        <cfif var_apply_template_profile_filter><!--- User can approve this billback --->
			            AND Billback.Billback_ID NOT IN (select Billback_ID FROM ##tmp_billacks_cannot_approve)
			            </cfif>
                        AND

                        ((	SELECT 	Top 1 User_positions_ID
                                FROM 	Billback_Approvable_Positions as BillbackApprovablePositions
                                WHERE 	BillbackApprovablePositions.Billback_ID = Billback.Billback_ID AND
                                        NOT (	(	ISNULL(Authority_Sequence_Order, 0) = 0 OR
                                                    Authority_Sequence_Order IN (	SELECT 		ISNULL(Authority_Sequence_ORDER,0)
                                                                                    FROM 		BB_Agreed_Info
                                                                                    INNER JOIN 	Authority_Sequence ON Authority_Sequence.Authority_Sequence_ID = BB_Agreed_Info.Authority_Sequence_ID
                                                                                    WHERE 		Billback_ID = Billback.Billback_ID
                                                                                    AND			BB_Agreed_Info.Deleted = 0)
                                                ) AND
                                                User_positions_ID IN (	SELECT 	DISTINCT User_position_ID
                                                                        FROM 	BB_Agreed_Info
                                                                        WHERE 	Billback_ID = Billback.Billback_ID AND
                                                                                Deleted = 0)
                                            )
                            ORDER BY BillbackApprovablePositions.Service_Market_ID DESC, BillbackApprovablePositions.Service_Region_ID DESC, BillbackApprovablePositions.Service_Zone_ID DESC, BillbackApprovablePositions.Authority_Sequence_Order DESC
                            ) IN (#PreserveSingleQuotes(arguments.UserPositionList)#) )
                        AND

                        (	ISNULL((	SELECT 	Top 1 Authority_Sequence_Order
                                        FROM 	Billback_Approvable_Positions as BillbackApprovablePositions
                                        WHERE 	BillbackApprovablePositions.Billback_ID = Billback.Billback_ID AND
                                                NOT (	(	ISNULL(Authority_Sequence_Order, 0) = 0 OR
                                                            Authority_Sequence_Order IN (	SELECT 		ISNULL(Authority_Sequence_ORDER,0)
                                                                                            FROM 		BB_Agreed_Info
                                                                                            INNER JOIN 	Authority_Sequence ON Authority_Sequence.Authority_Sequence_ID = BB_Agreed_Info.Authority_Sequence_ID
                                                                                            WHERE 		Billback_ID = Billback.Billback_ID
                                                                                            AND			BB_Agreed_Info.Deleted = 0)
                                                        ) AND
                                                        User_positions_ID IN (	SELECT 	DISTINCT User_position_ID
                                                                                FROM 	BB_Agreed_Info
                                                                                WHERE 	Billback_ID = Billback.Billback_ID AND
                                                                                        Deleted = 0)
                                                    )
                                        ORDER BY BillbackApprovablePositions.Service_Market_ID DESC, BillbackApprovablePositions.Service_Region_ID DESC, BillbackApprovablePositions.Service_Zone_ID DESC, BillbackApprovablePositions.Authority_Sequence_Order DESC
                                    ),0) = '#arguments.Auth_Sequence_Order#'
                        )
                    )
                )
                <cfelseif arguments.program_agree_status_ID EQ 3>
                AND
                (Billback.Billback_Status_ID = 2 AND Program_Agree_Status.Program_Agree_Status_ID = 3 AND
                  Exists
                  (SELECT * FROM BB_Agreed_Info WHERE Deleted = 0 AND Billback_ID = Billback.Billback_ID AND User_position_ID IN (#PreserveSingleQuotes(arguments.UserPositionList)#) AND Authority_Sequence_ID = '#arguments.Auth_Sequence_ID#')
                )
                </cfif>

				 <cfif isDefined("arguments.bbFilterIds") and len(trim(arguments.bbFilterIds))>
				 	AND Billback.Billback_ID NOT IN
					(
						#ListQualify(arguments.bbFilterIds, "'")#
					)
				 </cfif>
            </cfif>

            Order By #Replace(arguments.sql_Sort_By,'BB_Approved_Amount','Paid_Amount','ALL')#

            <cfif isDefined("arguments.startrow") and isDefined("arguments.endrow")>
				declare @recordcount int
				declare @TotalClaimAmount decimal(20,2)
				declare @TotalVariance decimal(20,2)

				select   @recordcount = count(billback_id),
						@TotalClaimAmount = sum(CASE WHEN len(BB_Amount) = 0 then 0 ELSE BB_Amount END),
						@TotalVariance = sum(CASE WHEN len(BB_Variance) = 0 then 0 WHEN BB_Variance < 0 THEN 0 ELSE BB_Variance END)
				from ##tmp_billback_search_result

				select 	*, @recordcount as record_count, @TotalClaimAmount AS TotalClaimAmount, @TotalVariance AS TotalVariance
				from	##tmp_billback_search_result
				where	RowID between #arguments.startrow# and #arguments.endrow#

				drop table ##tmp_billback_search_result
			</cfif>

            <cfif var_apply_template_profile_filter>
            <!---drop table ##tmp_billack_pre_filter--->
            drop table ##tmp_billacks_cannot_see
            </cfif>
        </cfquery>
		<cfreturn var_qScorecardBillbackContent>

    </cffunction>
    <!--- New METHOD: getScorecardBillbackContent() FUNCTIONALITY: I retrieve Scorecard Billback Content. [end] --->


    <!--- New METHOD: searchBillbacks() FUNCTIONALITY: I search billbacks. [begin] --->
    <cffunction name="searchBillbacks" access="public" output="yes" hint="I search billbacks." returntype="query" displayname="Model > Billback > searchBillbacks()">
        <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
        <!--- ALWAYS employ argumentcollection ... --->
			<cfargument name="invoiceSearch" type="numeric" default="0" />
			<cfargument name="forDownload" type="numeric" default="0" required="false" />


        <!--- let's set our initial values... --->
        <cfscript>
            var var_qBillbackSearchResults = queryNew('cols');
            var var_programScorecardRestrictCreatedByUserId = '';
            var var_qUserNumber = '';
            var var_qUser = '';
            var var_apply_template_profile_filter = 0;
            var var_approved_BB_Only = 0;

            local.UserPositionList = createObject("component", "components.user.UserManager").getPositionId(request.AccessStructure.user_id, 0, 1);
            local.Auth_Sequence_ID = 0;
            local.payable_numbers = [];
        </cfscript>


        <!---- do not apply this filter is user is searching for billback to match against deductions --->
        <cfif arguments.source NEQ "Deductions" AND NOT arguments.MATCHCentral>
            <cfset var_apply_template_profile_filter = 1 />
        </cfif>

        <CFQUERY NAME="local.AuthoritySeq" DATASOURCE="#Application.Datasource#">
            SELECT Authority_Sequence_Order,Authority_Sequence_ID
              FROM Authority_Sequence
             WHERE Authority_Sequence_ID = (SELECT Authority_Sequence_ID
                                              FROM _Users
                                             WHERE User_ID = '#request.AccessStructure.User_ID#')
        </CFQUERY>
        <CFIF local.AuthoritySeq.recordCount GT 0>
            <cfscript>
                local.Auth_Sequence_Order = AuthoritySeq.Authority_Sequence_Order;
                local.Auth_Sequence_ID    = AuthoritySeq.Authority_Sequence_ID;
            </cfscript>
        </CFIF>

        <cfparam name="arguments.vendorName" default="">
        <cfif arguments.vendorName neq "">
            <!--- convert white spaces in between words into % for partial matching (e.g. "  STOP  AND  SHOP" becomes "STOP%AND%SHOP") --->
            <cfset arguments.vendorName = replace( replace(trim(arguments.vendorName), "  ", " ", "all"), " ", "%", "all" )>
        </cfif>

        <cfif structKeyExists(arguments, "payable_list")>    <!--- 50885 --->
            <!--- payable list exists :: remove carriage returns & line feeds, then split entries into an array --->
            <cfset local.payable_numbers = listToArray( replace(arguments.payable_list, chr(13) & chr(10), " ", "all"), " " )>
        </cfif>

        <cfset globalTableName = replace(request.AccessStructure.User_ID,'-','_','ALL')>

				<cfquery name="var_qDeleteTempTables" datasource="#application.datasource#">
					set transaction isolation level read uncommitted

					IF OBJECT_ID('tempdb..##tmp_billacks_cannot_see') IS NOT NULL
					DROP TABLE ##tmp_billacks_cannot_see

					IF OBJECT_ID('tempdb..##tmp_billack_templates') IS NOT NULL
					DROP TABLE ##tmp_billack_templates

					IF OBJECT_ID('tempdb..##tmp_billback_search_result') IS NOT NULL
					DROP TABLE ##tmp_billback_search_result

					IF OBJECT_ID('tempdb..##tmp_billacks_cannot_see') IS NOT NULL
					DROP TABLE ##tmp_billacks_cannot_see

					IF OBJECT_ID('tempdb..##tmp_billacks_cannot_approve') IS NOT NULL
					DROP TABLE ##tmp_billacks_cannot_approve

					IF OBJECT_ID('tempdb..##tmp_billback_search_final') IS NOT NULL
					DROP TABLE ##tmp_billback_search_final

					IF OBJECT_ID('tempdb..####tmp_billback_search_result_#globalTableName#') IS NOT NULL
					DROP TABLE ####tmp_billback_search_result_#globalTableName#

                    IF OBJECT_ID('tempdb..##BSA_Operator') IS NOT NULL
                    DROP TABLE ##BSA_Operator

                    IF OBJECT_ID('tempdb..##BSA_Operator_1') IS NOT NULL
                    DROP TABLE ##BSA_Operator_1

                    IF OBJECT_ID('tempdb..##Contract_Operators') IS NOT NULL
                    DROP TABLE ##Contract_Operators
</cfquery>

	<cfif isDefined('arguments.MC_CreateList') AND arguments.MC_CreateList NEQ "">
		<cfset arguments.Payable_Number = arguments.MC_CreateList>
	</cfif>

    <!---D107259 :: Billback access across Segments START ---->
        <cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager")>
        <cfset SegmentEnabled = businessSegManager.isEnabled()>
        <cfif SegmentEnabled>
            <cfset qGetBusSegments = businessSegManager.getActive(request.AccessStructure.user_id)>
            <cfset Business_Segment_ID_List = valueList(qGetBusSegments.Business_Segment_ID, ",")>
        </cfif>

        <cfset var templates_with_same_parent = "">

        <cfparam name="arguments.Program_Template" default="0">

        <!--- gather all template IDs with the same parent ID --->
        <cfif arguments.Program_Template neq "0">
            <!--- limit to 2000 rows due to CF limitation on number of cfqueryparams --->
            <cfquery name="local.qTemplates" datasource="#application.datasource#" maxrows="2000">
                SELECT ProgramControl_Panel_Options_ID
                  FROM Program_Control_Panel_Options
                 WHERE Deleted = 0 AND First_Parent_ID IN (<cfqueryparam value="#arguments.Program_Template#" list="true" cfsqltype="cf_sql_integer">)
            </cfquery>
            <cfset templates_with_same_parent = valueList(local.qTemplates.ProgramControl_Panel_Options_ID)>
        </cfif>


        <!--- retrieve timeout setting (in seconds) for bb search --->
        <cfset local.timeout = val(application.util.query.get_Setting("bb_search_timeout", 0))>
        <!--- use timeout attribute to allow CF to terminate excessive long queries --->
        <cfquery name="var_qBillbackSearchResults" timeout="#local.timeout#" datasource="#application.datasource#">

    <!---92675 :: BB Search modifications START--->
    <cfif structKeyExists(arguments, "Item_list") AND arguments.Item_list NEQ "">
        IF OBJECT_ID('tempdb..##TMP_Item_List') IS NOT NULL
        DROP TABLE ##TMP_Item_List
        CREATE TABLE ##TMP_Item_List (Item nvarchar(25))
        <cfloop list="#arguments.Item_list#" index="IN" delimiters=",#chr(13)##chr(10)##chr(9)#">
            INSERT INTO ##TMP_Item_List (Item)
            VALUES ('#TRIM(IN)#')
        </cfloop>
    </cfif>

    <cfif structKeyExists(arguments, "billback_list") AND arguments.billback_list NEQ "">
        IF OBJECT_ID('tempdb..##TMP_billback_list') IS NOT NULL
        DROP TABLE ##TMP_billback_list
        CREATE TABLE ##TMP_billback_list (Billback nvarchar(25))
        <cfloop list="#arguments.billback_list#" index="BB" delimiters=",#chr(13)##chr(10)##chr(9)#">
            INSERT INTO ##TMP_billback_list (Billback)
            VALUES ('#TRIM(BB)#')
        </cfloop>
    </cfif>

    <cfif structKeyExists(arguments, "reference_list") AND arguments.reference_list NEQ "">
        IF OBJECT_ID('tempdb..##TMP_reference_list') IS NOT NULL
        DROP TABLE ##TMP_reference_list
        CREATE TABLE ##TMP_reference_list (reference nvarchar(25))
        <cfloop list="#arguments.reference_list#" index="RL" delimiters=",#chr(13)##chr(10)##chr(9)#">
            INSERT INTO ##TMP_reference_list (reference)
            VALUES ('#TRIM(RL)#')
        </cfloop>
    </cfif>

    <cfif structKeyExists(arguments, "program_list") AND arguments.program_list NEQ "">
        IF OBJECT_ID('tempdb..##TMP_program_list') IS NOT NULL
        DROP TABLE ##TMP_program_list
        CREATE TABLE ##TMP_program_list (program_list nvarchar(25))
        <cfloop list="#arguments.program_list#" index="PL" delimiters=",#chr(13)##chr(10)##chr(9)#">
            INSERT INTO ##TMP_program_list (program_list)
            VALUES ('#TRIM(PL)#')
        </cfloop>
    </cfif>

    <cfif structKeyExists(arguments, "distributor_list") AND arguments.distributor_list NEQ "">
        IF OBJECT_ID('tempdb..##TMP_distributor_list') IS NOT NULL
        DROP TABLE ##TMP_distributor_list
        CREATE TABLE ##TMP_distributor_list (distributor_list nvarchar(25))
        <cfloop list="#arguments.distributor_list#" index="DL" delimiters=",#chr(13)##chr(10)##chr(9)#">
            INSERT INTO ##TMP_distributor_list (distributor_list)
            VALUES ('#TRIM(DL)#')
        </cfloop>
    </cfif>

    <cfif structKeyExists(arguments, "operator_list") AND arguments.operator_list NEQ "">
        IF OBJECT_ID('tempdb..##TMP_operator_list') IS NOT NULL
        DROP TABLE ##TMP_operator_list
        CREATE TABLE ##TMP_operator_list (operator_list nvarchar(25))
        <cfloop list="#arguments.operator_list#" index="OL" delimiters=",#chr(13)##chr(10)##chr(9)#">
            INSERT INTO ##TMP_operator_list (operator_list)
            VALUES ('#TRIM(OL)#')
        </cfloop>
    </cfif>

    <cfif structKeyExists(arguments, "operator_number_list") AND arguments.operator_number_list NEQ "">
        IF OBJECT_ID('tempdb..##TMP_operator_number_list') IS NOT NULL
        DROP TABLE ##TMP_operator_number_list
        CREATE TABLE ##TMP_operator_number_list (operator_number_list nvarchar(25))
        <cfloop list="#arguments.operator_number_list#" index="ONL" delimiters=",#chr(13)##chr(10)##chr(9)#">
            INSERT INTO ##TMP_operator_number_list (operator_number_list)
            VALUES ('#TRIM(ONL)#')
        </cfloop>
    </cfif>

    <cfif structKeyExists(arguments, "vendor_list") AND arguments.vendor_list NEQ "">
        IF OBJECT_ID('tempdb..##TMP_vendor_list') IS NOT NULL
        DROP TABLE ##TMP_vendor_list
        CREATE TABLE ##TMP_vendor_list (vendor_list nvarchar(25))
        <cfloop list="#arguments.vendor_list#" index="VL" delimiters=",#chr(13)##chr(10)##chr(9)#">
            INSERT INTO ##TMP_vendor_list (vendor_list)
            VALUES ('#TRIM(VL)#')
        </cfloop>
    </cfif>

			<cfif structKeyExists(arguments, "soldToNo_list") AND arguments.soldToNo_list NEQ "">
		      IF OBJECT_ID('tempdb..##TMP_soldToNo_list') IS NOT NULL
		      DROP TABLE ##TMP_soldToNo_list
		      CREATE TABLE ##TMP_soldToNo_list (soldToNo_list nvarchar(25))
		      <cfloop list="#arguments.soldToNo_list#" index="SL" delimiters=",#chr(13)##chr(10)##chr(9)#">
		          INSERT INTO ##TMP_soldToNo_list (soldToNo_list)
		          VALUES ('#TRIM(SL)#')
		      </cfloop>
		  </cfif>
		  <!---92675 :: BB Search modifications END--->

    <!--- 75568 :: Match Central - mass select and create list options START ---->
		<cfif arguments.Payable_Number NEQ "">
			IF OBJECT_ID('tempdb..##TMP_Payable_List') IS NOT NULL
			DROP TABLE ##TMP_Payable_List
			CREATE TABLE ##TMP_Payable_List (Payable nvarchar(25))
			<cfloop list="#arguments.Payable_Number#" index="PN" delimiters=",#chr(13)##chr(10)##chr(9)##chr(32)#">
				INSERT INTO ##TMP_Payable_List (Payable)
				VALUES ('#TRIM(PN)#')
			</cfloop>
		</cfif>
		<!--- 75568 :: Match Central - mass select and create list options END ---->
	<cfif arguments.source eq "Deductions">
		DECLARE @DD_Amount decimal(20, 4),
											@DD_Amount2 decimal(20, 2),
											@DD_Reference nvarchar(100)

		<cfif isDefined("arguments.Deduction_ID")>
			SELECT @DD_Amount = DD_Amount, @DD_Amount2 = Round(DD_Amount,2), @DD_Reference = LTRIM(RTRIM(DD_Reference))
			FROM Deductions
			WHERE Deduction_ID = '#arguments.Deduction_ID#'
		</cfif>
		DECLARE @Tmp_BB_Parent_ID_List table(BB_Parent_ID uniqueidentifier NOT NULL PRIMARY KEY)
		INSERT INTO @Tmp_BB_Parent_ID_List(arguments.BB_Parent_ID)
		SELECT	DISTINCT BB_Parent_ID
		FROM	Billback
		WHERE	Deleted = 0
		AND		BB_Parent_ID IS NOT NULL
	</cfif>   <!---  arguments.source eq "Deductions" --->

            <cfif NOT arguments.UserIsAnalyst>
                #PreserveSingleQuotes(arguments.AllowBillbackIDs)#
            <cfelse>
                #PreserveSingleQuotes(arguments.AllowAnalystIds)#
            </cfif>

	<cfif var_apply_template_profile_filter>
		<cfset var_forbidType = arguments.appSettings.getForbidAllowProfilesInTemplates() />

		DECLARE @Profile_Forbidden_Template table(
			Template_ID   int  NOT NULL PRIMARY KEY,
			Forbid_Access_Type int NOT NULL
		)

		INSERT INTO @Profile_Forbidden_Template (Template_ID, Forbid_Access_Type)
		SELECT DISTINCT template_id, Forbid_Access_Type
		FROM 	Profile_Forbidden_Template
		WHERE 	Deleted = 0
		AND Forbid_Type = #var_forbidType#
		AND Forbid_Access_Type = 1
		AND profile_id = #arguments.Get_Profile_Settings.Profiles_ID#

		CREATE table ##tmp_billacks_cannot_see	(Billback_ID uniqueidentifier NOT NULL PRIMARY KEY)

		INSERT INTO ##tmp_billacks_cannot_see (Billback_ID)
		SELECT   DISTINCT Billback.Billback_ID
		FROM Billback
		INNER JOIN Billback_Program
		ON Billback.Billback_ID = Billback_Program.Billback_ID
		AND Billback_Program.Deleted = 0
		INNER JOIN Contract_Main
		ON Billback_Program.Program_ID = Contract_Main.Contract_Main_ID
		WHERE Billback.Deleted = 0
		AND   ProgramType_ID
		<cfif var_forbidType EQ 0>NOT</cfif><!------ forbit type=1, forbid, 0=allow ----->
		IN (select Template_ID from @Profile_Forbidden_Template)

		DECLARE @Profile_Forbidden_Template_BB_Approve TABLE (
																							Template_ID INT NOT NULL PRIMARY KEY,
																							Forbid_Access_Type INT NOT NULL
																						)
		INSERT INTO @Profile_Forbidden_Template_BB_Approve (Template_ID, Forbid_Access_Type)
		SELECT  DISTINCT template_id, Forbid_Access_Type
		FROM    Profile_Forbidden_Template
		WHERE   Deleted = 0
		AND Forbid_Type = #var_forbidType#
		AND Forbid_Access_Type = 4
		AND profile_id = #arguments.Get_Profile_Settings.Profiles_ID#

		CREATE table ##tmp_billacks_cannot_approve ( Billback_ID uniqueidentifier NOT NULL PRIMARY KEY )
		INSERT INTO ##tmp_billacks_cannot_approve (Billback_ID)
		SELECT  DISTINCT Billback.Billback_ID
		FROM  Billback
		INNER  JOIN Billback_Program
		ON  Billback.Billback_ID = Billback_Program.Billback_ID
		AND Billback_Program.Deleted = 0
		INNER JOIN Contract_Main
		ON  Billback_Program.Program_ID = Contract_Main.Contract_Main_ID
		WHERE  Billback.Deleted = 0
		AND   ProgramType_ID <cfif var_forbidType EQ 0>NOT </cfif><!------ forbit type=1, forbid, 0=allow ----->
		IN (SELECT Template_ID FROM @Profile_Forbidden_Template_BB_Approve)
	</cfif>     <!--- if var_apply_template_profile_filter --->

	<!--- Only do this if operator is selected --->
    <cfif arguments.Operator_Name NEQ "" OR arguments.operatorID NEQ ""
            OR (structKeyExists(arguments, "operator_list") AND arguments.operator_list NEQ "")
            OR (structKeyExists(arguments, "operator_number_list") AND arguments.operator_number_list NEQ "")>


				set transaction isolation level read uncommitted
				SELECT *
				INTO ##BSA_Operator
				FROM BSA_Operator BSAO
				WHERE
                                <cfif arguments.operatorID NEQ "" AND arguments.Operator_Name EQ "">
                                <!------ operator id only ----->
                                BSAO.Legacy_ID LIKE '%#arguments.operatorID#%'
                                OR cast(BSAO.BSA_Operator_ID as char(50)) LIKE '%#arguments.operatorID#%'
                                <cfelseif	arguments.Operator_Name NEQ "" AND arguments.operatorID EQ "">
                                <!------ operator name only ----->
                                BSAO.Operator_Name LIKE '%#arguments.Operator_Name#%'

                                <cfelseif structKeyExists(arguments, "operator_list") AND arguments.operator_list NEQ "">
                                 Exists (
                                                        SELECT 1
                                                        FROM ##TMP_operator_list TMP
                                                        WHERE
                                                        (
                                                            (
                                                                BSAO.BSA_Operator_ID IS NOT NULL
                                                                AND BSAO.Operator_Name
                                                                <cfif structKeyExists(arguments, "match_type") AND arguments.match_type EQ "partial">
                                                                    LIKE '%' + TMP.operator_list + '%'
                                                                <cfelse>
                                                                    = TMP.operator_list
                                                                </cfif>
                                                            )
                                                        )
                                )
                            <cfelseif structKeyExists(arguments, "operator_number_list") AND arguments.operator_number_list NEQ "">
                                 Exists (
                                                        SELECT 1
                                                        FROM ##TMP_operator_number_list TMP
                                                        WHERE
                                                        (
                                                            (
                                                                BSAO.Legacy_ID
                                                                <cfif structKeyExists(arguments, "match_type") AND arguments.match_type EQ "partial">
                                                                    LIKE '%' + TMP.operator_number_list + '%'
                                                                <cfelse>
                                                                    = TMP.operator_number_list
                                                                </cfif>
                                                                OR cast(BSAO.BSA_Operator_ID as char(50))
                                                                <cfif structKeyExists(arguments, "match_type") AND arguments.match_type EQ "partial">
                                                                    LIKE '%' + TMP.operator_number_list + '%'
                                                                <cfelse>
                                                                    = TMP.operator_number_list
                                                                </cfif>
                                                            )
                                                        )
                                                    )
                          <cfelse>
                                <!------ operator id OR name  ----->
                                BSAO.Legacy_ID LIKE '%#arguments.operatorID#%'
                                OR cast(BSAO.BSA_Operator_ID as char(50)) LIKE '%#arguments.operatorID#%'
                                OR BSAO.Operator_Name LIKE '%#arguments.Operator_Name#%'
                                </cfif>

				SELECT *
				INTO ##BSA_Operator_1
				FROM ##BSA_Operator

				SELECT Contract_Operators.*
				INTO ##Contract_Operators
				FROM Contract_Operators INNER JOIN ##BSA_Operator_1 BSA_Operator_1 ON BSA_Operator_1.BSA_Operator_ID = Contract_Operators.BSA_Operator_ID
				WHERE Contract_Operators.Deleted = 0
	</cfif>

<cfif arguments.invoiceSearch EQ 0><!---D57147 :: New Feature to Search for BB's by Customer Invoice --->
  SELECT 	DISTINCT
  			<cfif arguments.forDownload>
  				TOP 100000
  			</cfif>
			<cfif isDefined("arguments.startrow") and isDefined("arguments.endrow")>
                RowID=IDENTITY (int, 1, 1),
			</cfif>
            <cfif arguments.businessSegmentsOn>
                isnull((select top 1 business_unit_desc from business_segment where Business_Segment_ID in ( select top 1 Business_Segment_ID from contract_main where contract_main_id in (select top 1 program_id from billback_program where billback_program.billback_id = billback.billback_id))),'Unassigned')
            <cfelse>
                ''
            </cfif> as business_unit_desc,
			ISNULL((select top 1 Set_Billbacks_To_Paid_No_Interface from Program_Control_Panel_Options where ProgramControl_Panel_Options_ID in ( select top 1 ProgramType_ID from contract_main where contract_main_id in (select top 1 program_id from billback_program where billback_program.billback_id = billback.billback_id))),'0')
             as Set_Billbacks_To_Paid_No_Interface,
            Billback_Allied.BB_Is_Locked, Billback_Allied.BB_Locked_By_User_ID, Billback.*,
            <cfif arguments.appSettings.get_Setting('Claim_Less_Than_Expected_Deviation') eq "1">
            	ABS(Billback.BB_Amount-Billback.BB_Expected_Amount) as BB_Variance,
            <cfelse>
            	(Billback.BB_Amount-Billback.BB_Expected_Amount) as BB_Variance,
            </cfif>
            Billback_Allied.BB_Locked_By_Match_Central,
            ISNull(BB_Approved.Paid_Amount, 0) AS BB_Approved_Amount,
            BB_Approved.Paid_Amount,
            <cfif application.returned_customer_setting.Accounting_Specialist eq 1>
                Billback_Program.Program_ID,
                ppUsers.Name_Last,
            </cfif>
			BB_Approved.Voucher_Number,
            <!--- ADDED FOR THE PURPOSE OF STORING THE BILL TO/PAYEE IN THE QUERY FOR MATCH CENTRAL --->
            <cfif arguments.MATCHCentral>
                CASE
                WHEN Billback.Billback_Payee_Type_ID = 1
                THEN
                CASE WHEN BSA_Foodservice_Customers.Shr_Ship_To	IS NULL
                <!--- When the Payee is the Vendor --->
                THEN VM.Vendor_ID
                ELSE BSA_Foodservice_Customers.Shr_Ship_To
                END
                WHEN Billback.Billback_Payee_Type_ID = 2
                THEN
                    (SELECT DISTINCT TOP 1 BSA_Operator.Legacy_ID
                    FROM BSA_Operator
                    INNER JOIN Billback_Operator
                    ON BSA_Operator.BSA_Operator_ID = Billback_Operator.Operator_ID
                    AND Billback_Operator.Deleted = 0
                    WHERE Billback_Operator.Billback_ID = Billback.Billback_ID)
                WHEN Billback.Billback_Payee_Type_ID = 3
                THEN
                    (SELECT DISTINCT TOP 1 BSA_Foodservice_Brokers.Broker_Legcy_Shard
                    FROM BSA_Foodservice_Brokers
                    INNER JOIN Billback_Broker
                    ON (BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Billback_Broker.Broker_ID)
                    AND Billback_Broker.Deleted = 0
                    WHERE Billback_Broker.Billback_ID = Billback.Billback_ID)
                ELSE NULL
                END AS Shr_Ship_To,

                CASE
                WHEN Billback.Billback_Payee_Type_ID = 1
                THEN
                CASE WHEN BSA_Foodservice_Customers.Name IS NULL
                <!--- When the Payee is the Vendor --->
                THEN VM.Vendor_Name
                ELSE BSA_Foodservice_Customers.Name
                END
                WHEN Billback.Billback_Payee_Type_ID = 2
                THEN
                    (SELECT DISTINCT TOP 1 BSA_Operator.Operator_Name
                    FROM BSA_Operator
                    INNER JOIN Billback_Operator
                    ON (BSA_Operator.BSA_Operator_ID = Billback_Operator.Operator_ID)
                    AND Billback_Operator.Deleted = 0
                    WHERE Billback_Operator.Billback_ID = Billback.Billback_ID)
                WHEN Billback.Billback_Payee_Type_ID = 3
                THEN
                    (SELECT DISTINCT TOP 1 BSA_Foodservice_Brokers.Broker_Name
                    FROM BSA_Foodservice_Brokers
                    INNER JOIN Billback_Broker
                    ON (BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Billback_Broker.Broker_ID)
                    AND Billback_Broker.Deleted = 0
                    WHERE Billback_Broker.Billback_ID = Billback.Billback_ID)
                ELSE NULL
                END AS Name,
            </cfif>
            <cfif arguments.source EQ "Deductions" AND arguments.appSettings.getMatch_BB_DD_Based_On_Same_ReferenceNum()>
                CASE
                WHEN LTRIM(RTRIM(Billback.BB_Reference)) = @DD_Reference THEN
                1
                ELSE
                0 END AS IsSameReferenceNum,
            </cfif>
            <!---Billback.BB_Approved_Void_Ack_Date,--->
            Billback_Closing_Methods.Abbreviation,
            Billback_Closing_Methods.vchBillback_Closing_Method_Desc,
            BBanalyst.Name_first as BBanalyst_Name_first,
            BBanalyst.Name_last as BBanalyst_Name_last,
			<!--- START: Adding the Payee within the Search --->
			Payee_name =
			CASE WHEN  Billback.Billback_Payee_Type_ID = 1
			THEN
			/* Distributor */
			(SELECT DISTINCT TOP 1 ISNULL(BSA_Foodservice_Customers.Name,VM.Vendor_Name)
				FROM Billback_Distributor
				LEFT JOIN BSA_Foodservice_Customers
				ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Billback_Distributor.Distributor_ID
				LEFT JOIN Vendor_Master VM /* ---added VM join for Auto Pay w/multiple distributors */
				ON VM.vendor_Master_Id = Billback_Distributor.Distributor_ID
				WHERE	Billback_Distributor.Billback_ID = Billback.Billback_ID
				AND Billback_Distributor.Deleted = 0)

			WHEN Billback_Payee_Type_ID = 2 THEN
			/* Operator */
			(SELECT DISTINCT TOP 1 BSA_Operator.Operator_Name
				FROM BSA_Operator
				INNER JOIN Billback_Operator
				ON Billback_Operator.Billback_ID = Billback.Billback_ID
				AND Billback_Operator.Deleted = 0
				AND BSA_Operator.BSA_Operator_ID = Billback_Operator.Operator_ID)
			/* Broker */
			WHEN Billback_Payee_Type_ID = 3 THEN
			(SELECT DISTINCT TOP 1 BSA_Foodservice_Brokers.Broker_Name
				FROM BSA_Foodservice_Brokers
				INNER JOIN Billback_Broker
				ON Billback_Broker.Billback_ID = Billback.Billback_ID
				AND Billback_Broker.Deleted = 0
				AND BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Billback_Broker.Broker_ID)
			WHEN Billback_Payee_Type_ID = NULL THEN
			'N/A'
		END
			<!--- END: Adding the Payee within the Search --->
		<!--- START: Payee ID--->
		,Payee_ID =
			CASE WHEN  Billback.Billback_Payee_Type_ID = 1
			THEN
			/* Distributor */
			(SELECT DISTINCT TOP 1 ISNULL(BSA_Foodservice_Customers.Ship_To,VM.Vendor_ID)
				FROM Billback_Distributor
				LEFT JOIN BSA_Foodservice_Customers
			  ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Billback_Distributor.Distributor_ID
				LEFT JOIN Vendor_Master VM  /* added VM join for Auto Pay w/multiple distributors */
				ON VM.vendor_Master_Id = Billback_Distributor.Distributor_ID
				WHERE	Billback_Distributor.Billback_ID = Billback.Billback_ID
				AND Billback_Distributor.Deleted = 0)

			WHEN Billback_Payee_Type_ID = 2 THEN
			/* Operator */
			(SELECT DISTINCT TOP 1 CAST(BSA_Operator.BSA_Operator_ID AS VARCHAR(50))
				FROM BSA_Operator
				INNER JOIN Billback_Operator
				ON Billback_Operator.Billback_ID = Billback.Billback_ID
				AND Billback_Operator.Deleted = 0
				AND BSA_Operator.BSA_Operator_ID = Billback_Operator.Operator_ID)
			/* Broker */
			WHEN Billback_Payee_Type_ID = 3 THEN
			(SELECT DISTINCT TOP 1 BSA_Foodservice_Brokers.Broker_Shard
				FROM BSA_Foodservice_Brokers
				INNER JOIN Billback_Broker
				ON Billback_Broker.Billback_ID = Billback.Billback_ID
				AND Billback_Broker.Deleted = 0
				AND BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Billback_Broker.Broker_ID)
			WHEN Billback_Payee_Type_ID = NULL THEN
			'NA'
		END
			<!--- END: Payee ID--->
		,BB_Approved.check_Date
		<CFIF arguments.appSettings.getOneProgramPerBillback() AND arguments.forDownload>
		,Contract_Main.Contract_Number
		/* ,Contract_Main.Contract_Title,Program_Control_Panel_Options.Created_Type */
		,(SELECT TOP 1 a.contract_title FROM Contract_Main a WHERE a.Contract_Number = Contract_Main.Contract_Number AND a.Approved = 1 ORDER BY a.Contract_Created_Date DESC) AS Contract_Title
		,(SELECT TOP 1 b.Created_Type FROM Program_Control_Panel_Options b WHERE b.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID ORDER BY b.Date_Created desc) AS Created_Type
		,(SELECT DISTINCT TOP 1 CAST(BSA_Operator.BSA_Operator_ID AS VARCHAR(50)) FROM BSA_Operator INNER JOIN Billback_Operator ON Billback_Operator.Billback_ID = Billback.Billback_ID AND Billback_Operator.Deleted = 0 AND BSA_Operator.BSA_Operator_ID = Billback_Operator.Operator_ID) AS BBOperator_ID
		</CFIF>
			<cfif isDefined("arguments.startrow") and isDefined("arguments.endrow")>
			INTO ##tmp_billback_search_result
			</cfif>

	FROM Billback
	INNER JOIN Billback_Allied
	ON (Billback_Allied.Billback_ID = Billback.Billback_ID)
	LEFT JOIN Billback_Closing_Methods
	ON (Billback.BB_Closing_Method = Billback_Closing_Methods.iBillback_Closing_Method_ID)

            <cfif arguments.Get_Profile_Settings.Program_Scorecard_Restrict_Created_By>
                <!--- If the below profile settings is on, then the user should only be allowed to see programs
            that have him/her as an RSP OR where the program creator's RSP has the user number same as
            this user's User number
            --->
            AND NOT EXISTS
            (
            <cfset var_programScorecardRestrictCreatedByUserId = request.AccessStructure.user_id>
            <cfset var_qUserNumber = "" />
            <cfif arguments.appSettings.getUserNumberRestrict()>
                <cfset var_qUser = createObject("component", "components.user.UserManager").getUser(var_programScorecardRestrictCreatedByUserId) />
                <cfset var_qUserNumber = var_qUser.User_Number />
            </cfif>
            SELECT Billback_ID
            FROM Billback_Program
            INNER JOIN Contract_Main
            ON Billback_Program.Program_ID = Contract_Main.Contract_Main_ID
            LEFT JOIN _Users responsibleSalesPerson
            ON 	responsibleSalesPerson.User_ID = Contract_Main.Responsible_User_ID
            AND	responsibleSalesPerson.Deleted = 0
            WHERE Billback_Program.Billback_ID = Billback.Billback_ID
            AND Billback_Program.Deleted = 0
            AND(
            Isnull(rtrim(ltrim(Contract_Main.Responsible_User_ID)),'') != '#var_programScorecardRestrictCreatedByUserId#'
            <cfif len(var_qUserNumber)>
                AND Isnull(rtrim(ltrim(responsibleSalesPerson.User_Number)),'') != '#var_qUserNumber#'
            </cfif>
            )
            )
            </cfif>
            <!--- Only do this join if the user is searching by broker --->
            <cfif arguments.Broker_ID NEQ "0" AND len(trim(arguments.Broker_ID))>
                INNER JOIN (
                Billback_Broker BBRO
                INNER JOIN BSA_Foodservice_Brokers BFB
                ON (BBRO.Broker_ID = BFB.BSA_Foodservice_Brokers_ID)
                )
                ON
                (
                (BBRO.Billback_ID = Billback.Billback_ID)
                AND ((Billback.Billback_Payee_Type_ID = 3) OR (Billback.Billback_Payee_Type_ID = 7))
                AND (BBRO.Deleted = 0)
                )
			<cfelse>
			  LEFT JOIN
                (
                Billback_Broker BBRO
                LEFT JOIN BSA_Foodservice_Brokers BFB
                ON (BBRO.Broker_ID = BFB.BSA_Foodservice_Brokers_ID)
                )
                ON
                (
                (BBRO.Billback_ID = Billback.Billback_ID)
                AND
                ((Billback.Billback_Payee_Type_ID = 3) OR (Billback.Billback_Payee_Type_ID = 7))
                AND (BBRO.Deleted = 0)
                )
            </cfif>
            <!---- End broker search --->
            <!--- Only do this if distributor is selected --->
            LEFT JOIN Billback_Distributor
            ON  Billback_Distributor.Billback_ID = Billback.Billback_ID
				    AND Billback_Distributor.Deleted = 0

            <cfif arguments.MATCHCentral>      <!---35071 Dup BBKs in Match Central Search Screen --->
                LEFT JOIN BSA_Foodservice_Customers
                ON Billback_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
                AND (Billback.Billback_Payee_Type_ID = 1)
            <cfelse>
                AND Billback.Billback_Payee_Type_ID = 1          <!---32343--->
								LEFT JOIN BILLBACK_DISTRIBUTOR_LIST
								ON BILLBACK_DISTRIBUTOR_LIST.BillBack_Id = BILLBACK.BillBack_Id        <!---32343--->
                AND BILLBACK_DISTRIBUTOR_LIST.Deleted = 0

                LEFT JOIN BSA_Foodservice_Customers
                ON
    		CASE
			WHEN Billback_Distributor.Distributor_ID IS NULL THEN
				BILLBACK_DISTRIBUTOR_LIST.Distributor_ID
			ELSE
				Billback_Distributor.Distributor_ID
                END
                =   BSA_FOODSERVICE_CUSTOMERS.bsa_FoodService_Customers_Id
		<!---32343--->
		<!---Dev Note: 40875 (Milan). - I modified the above join to use case statement to make the query faster.
		I tried using the "IsNull" function to make it a compact code but the performance did not improve:
		Code: IsNull(Billback_Distributor.Distributor_ID,BILLBACK_DISTRIBUTOR_LIST.Distributor_ID) = BSA_FOODSERVICE_CUSTOMERS.bsa_FoodService_Customers_Id
		--->
             </cfif>

            LEFT JOIN 	Distributor_Bill_To
            ON Distributor_Bill_To.Distributor_Bill_To_ID = BSA_Foodservice_Customers.Distributor_Bill_To_ID

			<cfif arguments.source EQ "Deductions" AND isDefined("arguments.Filter_Distributor_Bill_To_ID") AND arguments.Filter_Distributor_Bill_To_ID NEQ "" AND appSettings.get_Setting('Deduction_match_using_bill_to_vendor') EQ '1'>
			LEFT JOIN 	Distributor_Bill_To BT2
      ON BT2.Distributor_Bill_To_ID = '#arguments.Filter_Distributor_Bill_To_ID#'
			</cfif>


            <!--- Only do this if operator is selected --->
           <!---  <cfif arguments.Operator_Name NEQ "" OR arguments.operatorID NEQ "" OR arguments.vendorName neq ""> --->
            <!--- I have used Left Join because even if the operator is on the program we should show that billback, whether it
                    is on the billback or not.
            --->
                LEFT JOIN
                (
                Billback_Operator BO
                LEFT JOIN BSA_Operator BSAO
                ON (BO.Operator_ID = BSAO.BSA_Operator_ID)
                )
                ON
                (
                (BO.Billback_ID = Billback.Billback_ID)
                AND ((Billback.Billback_Payee_Type_ID = 2) OR (Billback.Billback_Payee_Type_ID = 6))
                AND (BO.Deleted = 0)
                )
            <!--- </cfif> --->
            LEFT JOIN BB_Approved
            ON	BB_Approved.Billback_ID = Billback.Billback_ID
				<cfif NOT arguments.MATCHCentral AND NOT arguments.source EQ "Deductions"> <!--- we already have filter below to only include approved billbacks --->
                AND Billback.Billback_Status_ID > 2
				</cfif>
            <cfif arguments.vendorID NEQ "" OR (structKeyExists(arguments, "vendor_list") AND arguments.vendor_list NEQ "")>
                LEFT JOIN vendor_dist_oper
                ON vendor_dist_oper.Vendor_Dist_Oper_ID = BB_Approved.Vendor_Dist_Oper_ID
                LEFT JOIN Vendor_Master
                ON Vendor_Master.Vendor_Master_ID = BB_Approved.Vendor_Master_ID
            </cfif>
           <!---  <cfif arguments.vendorName neq ""> --->
                LEFT JOIN ( Billback_Broker INNER JOIN BSA_Foodservice_Brokers ON (Billback_Broker.Broker_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID) )
                    ON ( (Billback_Broker.Billback_ID = Billback.Billback_ID)
                         AND ( (Billback.Billback_Payee_Type_ID = 3) OR (Billback.Billback_Payee_Type_ID = 7) )
                         AND (Billback_Broker.Deleted = 0) )
                LEFT JOIN Vendor_Master vm1 /* Look for the first "Non Null" value. */
							  ON vm1.vendor_Id = COALESCE(BO.Uploaded_Vendor_ID, Billback_Distributor.Uploaded_Vendor_ID, BBRO.Uploaded_Vendor_ID)
                LEFT JOIN BB_Approved bba2
								ON bba2.Billback_ID = Billback.Billback_ID/* This join is for autopay. */
                LEFT JOIN Vendor_Master vm2
								ON  bba2.Vendor_Master_Id = vm2.Vendor_Master_Id
            <!--- </cfif> --->
                LEFT JOIN Billback_Program
								ON Billback_Program.Billback_ID = Billback.Billback_ID
                AND Billback_Program.Deleted = 0
			<!--- Dev Note (70491) --->
            <!---D107259 :: Billback access across Segments START ---->
            <CFIF arguments.appSettings.getOneProgramPerBillback() OR (structKeyExists(arguments, "program_list") AND arguments.program_list NEQ "") OR SegmentEnabled>
                LEFT JOIN Contract_Main
                ON Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
            </CFIF>
            <!---D107259 :: Billback access across Segments END---->
            <cfif application.returned_customer_setting.Accounting_Specialist eq 1>
                LEFT JOIN Program_Accounting_Specialist
								ON Program_Accounting_Specialist.Program_ID = Billback_Program.Program_ID
                AND Program_Accounting_Specialist.Deleted = 0
                LEFT JOIN _users ppUsers
                ON ppUsers.User_ID = Program_Accounting_Specialist.User_ID
            </cfif>

            <cfif arguments.Operator_Name NEQ "" OR arguments.operatorID NEQ ""
            OR (structKeyExists(arguments, "operator_list") AND arguments.operator_list NEQ "")
            OR (structKeyExists(arguments, "operator_number_list") AND arguments.operator_number_list NEQ "")>
                LEFT JOIN
                (
                ##Contract_Operators Contract_Operators
                LEFT JOIN ##BSA_Operator BSA_Operator_1
                ON (BSA_Operator_1.BSA_Operator_ID = Contract_Operators.BSA_Operator_ID)
                )
                ON (Contract_Operators.Contract_Main_ID = Billback_Program.Program_ID)
                AND Contract_Operators.Deleted = 0
            </cfif>
			<cfif arguments.MATCHCentral
							OR arguments.source EQ "Deductions"
							OR arguments.soldToNo NEQ ""
							OR arguments.Distributor_Name NEQ ""
							OR arguments.distributor_list NEQ ""
							OR (structKeyExists(arguments, "soldToNo_list") AND arguments.soldToNo_list NEQ "")>
            LEFT JOIN Vendor_Master VM
						ON VM.vendor_Master_Id = Billback_Distributor.Distributor_ID
			</cfif>
            <!--- Only show billbacks with the default billback associated --->
            <cfif arguments.ShowIncompleteBillbacks NEQ 0 AND len(trim(arguments.ShowIncompleteBillbacks))>
                INNER JOIN Billback_Program DefaultProgram
                ON DefaultProgram.Billback_ID = Billback.Billback_ID
                AND DefaultProgram.Deleted = 0
                AND DefaultProgram.Program_ID = '#arguments.ShowIncompleteBillbacks#'
            </cfif>
            <!------ Display CRA ----->
			<!---
			<cfif NOT arguments.MATCHCentral AND NOT arguments.source EQ "Deductions">
            LEFT JOIN User_Positions Position_To_Approve
            ON
			Billback.Billback_Status_ID = 2
			AND Position_To_Approve.User_Positions_ID =
            (
            SELECT	TOP 1 User_positions_ID
            FROM	BillbackApprovablePositions
            WHERE	BillbackApprovablePositions.Billback_ID = Billback.Billback_ID
                 AND NOT EXISTS
                              (	SELECT DISTINCT BB_Agreed_Info.User_Position_ID
                                FROM       	BB_Agreed_Info
                    LEFT JOIN	Authority_Sequence
                    ON			Authority_Sequence.Authority_Sequence_ID = BB_Agreed_Info.Authority_Sequence_ID
                                WHERE      	BB_Agreed_Info.Billback_ID = Billback.Billback_ID
                                AND			BB_Agreed_Info.Deleted = 0
                                AND User_Positions_ID IS NOT NULL
                                AND		BillbackApprovablePositions.User_Positions_ID = BB_Agreed_Info.User_Position_ID
                                AND		ISNULL(BillbackApprovablePositions.Authority_Sequence_Order, 0) = ISNULL(Authority_Sequence.Authority_Sequence_Order, 0)
                   )
            ORDER BY BillbackApprovablePositions.Service_Market_ID DESC, BillbackApprovablePositions.Service_Region_ID DESC, BillbackApprovablePositions.Service_Zone_ID DESC, BillbackApprovablePositions.Authority_Sequence_Order DESC
            )
            LEFT JOIN Authority_Sequence Approve_Authority_Sequence
            ON
			Billback.Billback_Status_ID = 2
			AND Position_To_Approve.Service_Market_ID IS NULL
            AND Position_To_Approve.Service_Region_ID IS NULL
            AND Position_To_Approve.Service_Zone_ID IS NULL
            AND Approve_Authority_Sequence.Deleted = 0
            AND Approve_Authority_Sequence.Authority_Sequence_Order =
            (
            SELECT	TOP 1 Authority_Sequence_Order
            FROM	BillbackApprovablePositions
            WHERE	BillbackApprovablePositions.Billback_ID = Billback.Billback_ID
                 AND NOT EXISTS
                              (	SELECT DISTINCT User_Position_ID
                                FROM       	BB_Agreed_Info
                    LEFT JOIN	Authority_Sequence
                    ON			Authority_Sequence.Authority_Sequence_ID = BB_Agreed_Info.Authority_Sequence_ID
                                WHERE      	BB_Agreed_Info.Billback_ID = Billback.Billback_ID
                                AND			BB_Agreed_Info.Deleted = 0
                                AND User_Positions_ID IS NOT NULL
                                AND		BillbackApprovablePositions.User_Positions_ID = BB_Agreed_Info.User_Position_ID
                                AND		ISNULL(BillbackApprovablePositions.Authority_Sequence_Order, 0) = ISNULL(Authority_Sequence.Authority_Sequence_Order, 0)
                   )
            ORDER BY BillbackApprovablePositions.Service_Market_ID DESC, BillbackApprovablePositions.Service_Region_ID DESC, BillbackApprovablePositions.Service_Zone_ID DESC, BillbackApprovablePositions.Authority_Sequence_Order DESC
            )
			</cfif>
			--->
            <!------ Display CRA ----->
            LEFT JOIN _users BBanalyst
            ON BBanalyst.User_ID = Billback.Analyst_User_ID

 WHERE Billback.Deleted = 0
<cfif var_apply_template_profile_filter>
AND Billback.Billback_ID NOT IN (select Billback_ID FROM ##tmp_billacks_cannot_see)
</cfif>
			<!--- 114068: Billback authority not checking Segment / Anand Rao / 29-Mar-2022 --->
			<cfif (arguments.businessSegmentsOn AND structKeyExists(request.AccessStructure, "User_Business_Segments") and len(request.AccessStructure.User_Business_Segments))>
           		AND   ( isnull(( select top 1 Business_Segment_ID from contract_main where contract_main_id in (select top 1 program_id from billback_program where billback_program.billback_id = billback.billback_id)),0)
IN (#request.AccessStructure.User_Business_Segments#))
			</cfif>

            <!---TSF - Label 16253: Add Billback filter logic if search by analyst is not on for this profile--->
            <cfif not arguments.Get_Profile_Settings.BB_Search_By_Analyst>

            <cfif arguments.HQUser NEQ 1 OR arguments.UserIsAnalyst><!--- if user is an analyst or not HQ --->
            AND (
                Billback.BB_Creator_ID = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
                <cfif arguments.UserIsAnalyst EQ 0>
                    OR Billback.BB_Creator_User_Position_ID IN (#PreserveSingleQuotes(arguments.UserPositionList)#)
                    <cfif listlen(arguments.BillbackIDs) GT 0>
                        OR Billback.Billback_ID IN (SELECT Billback_ID FROM @Allow_Only_Billbacks)
                    </cfif>
                <cfelse><!------ If billback analyst do not look at the position tree, use the analyst logic alone ----->
                    <cfif arguments.AnalystList NEQ "">
                        OR	Billback.Analyst_User_ID IN (#PreserveSingleQuotes(arguments.AnalystList)#)
                        OR	Billback.BB_Creator_ID IN (#PreserveSingleQuotes(arguments.AnalystList)#)
                    </cfif>
                </cfif>
            )
            </cfif>

            </cfif>

            <!---
            TSF - Label 16253: If we have a value for arguments.Search_Filter_Analyst_User_ID
            and it is not 0 (Any Analyst) then we have to filter on the Billback.Analyst_User_ID
            --->
            <cfif len(trim(arguments.Search_Filter_Analyst_User_ID)) and arguments.Search_Filter_Analyst_User_ID neq 0>
                AND Billback.Analyst_User_ID = <cfqueryparam value="#arguments.Search_Filter_Analyst_User_ID#" cfsqltype="CF_SQL_VARCHAR">
            </cfif>

            <cfif arguments.Status NEQ 0 AND arguments.Status GT 0 AND len(trim(arguments.Status))>
                <!--- RFA statuses: agreed, pending approve, under review --->
                <cfif arguments.status gte 2000 and arguments.status lte 2005>
                    AND Billback.Billback_Status_ID = 2
                <cfelse>
                    AND Billback.Billback_Status_ID = #arguments.Status#
                </cfif>
            </cfif>

						<cfif arguments.Status EQ "-1">
                AND Billback.Billback_Status_ID != 5
            </cfif>

            <!--- Deviated --->
            <cfif arguments.Deviated NEQ "0" AND len(trim(arguments.Deviated))>
                AND Billback.Deviated = #arguments.Deviated#
            </cfif>

            <!--- Reference Number --->
            <cfif arguments.referenceNum NEQ "">
                AND Billback.referenceNum Like '%#arguments.referenceNum#%'
						</cfif>
<!---92675 :: BB Search modifications START--->
<cfif (structKeyExists(arguments, "Item_Number") AND arguments.Item_Number NEQ "") OR (structKeyExists(arguments, "Item_list") AND arguments.Item_list NEQ "")>
AND EXISTS (
												SELECT 1
												FROM Billback_Product BP
												INNER JOIN BSA_Foodservice_Items_Master IM
												ON IM.BSA_Foodservice_Items_Master_ID = BP.Product_ID
												<cfif structKeyExists(arguments, "Item_list") AND arguments.Item_list NEQ "">
												INNER JOIN ##TMP_Item_List TMP
												ON IM.Item <cfif structKeyExists(arguments, "match_type") AND arguments.match_type EQ "partial">
												LIKE '%' + TMP.Item + '%'
												<cfelse>
												= TMP.Item
												</cfif>
												<cfelseif structKeyExists(arguments, "Item_Number") AND arguments.Item_Number NEQ "">
												AND IM.Item LIKE '%#arguments.Item_Number#%'
												</cfif>
												WHERE BP.Billback_ID = Billback.Billback_ID
												AND BP.Deleted = 0
												)
</cfif>

 <!---92675 :: BB Search modifications END--->
            <cfif (arguments.Program_Status NEQ "0" AND len(trim(arguments.Program_Status)))
            OR (arguments.Generic_Type NEQ "0" AND len(trim(arguments.Generic_Type)))
            OR arguments.Contract_Number NEQ ""
            OR (structKeyExists(arguments, "program_list") AND arguments.program_list NEQ "")
            OR arguments.Program_Template NEQ "0"
            >
            AND EXISTS
            (
                SELECT	TOP 1 Billback_Program.Billback_Program_ID
                FROM	Billback_Program
                INNER JOIN	Contract_Main
                ON
                        (
                            (Contract_Main.Contract_Main_ID = Billback_Program.Program_ID)
                            <cfif arguments.Program_Status NEQ "0" AND IsNumeric(arguments.Program_Status)>
                            AND (Contract_Main.Contract_Status_Type_IDX = #arguments.Program_Status#)
                            </cfif>
                            <cfif arguments.Contract_Number NEQ "">
                            AND (Contract_Main.Contract_Number LIKE '%#Trim(arguments.Contract_Number)#%')
                            </cfif>
                        )
                        <cfif arguments.Generic_Type NEQ "0" AND len(trim(arguments.Generic_Type))>
                        INNER JOIN Program_Control_Panel_Options
                        ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
                        AND Program_Control_Panel_Options.Generic_Type = '#arguments.Generic_Type#'
                        </cfif>
                Where Billback_Program.Deleted = 0
                AND Billback_Program.Billback_ID = Billback.Billback_ID
                <cfif  arguments.Program_Template NEQ "0">
                    AND Contract_Main.ProgramType_ID IN (<cfqueryparam value="#templates_with_same_parent#" cfsqltype="CF_SQL_INTEGER" list="true">)
                </cfif>
            )
            </cfif>
            <!------ broker ----->
            <cfif arguments.Broker_ID NEQ "0" AND len(trim(arguments.Broker_ID))>
                AND
                (	(	Billback.Billback_Payee_Type_ID = 3
                    AND	Billback_Broker.Broker_ID IN (<cfif  findNoCase("','",arguments.Broker_ID)>'#arguments.Broker_ID#'<cfelse>'#Replace(arguments.Broker_ID,",","','", "ALL")#'</cfif>)
                    AND	Billback_Broker.Deleted = 0
                    )
                    <cfif arguments.Include_Eligible_Programs eq 1><!------ also include billback with programs which has this broker ----->
                    OR billback.billback_id IN ( SELECT 	DISTINCT billback_id FROM 	V_Billback_Program_Broker WHERE 	bsa_foodservice_brokers_id IN ('#arguments.Broker_ID#') )
                    </cfif>
                )
            </cfif>

            <!------ Deductions code ----->
            <cfif arguments.source EQ "Deductions">
            <cfif arguments.Distributor_Name NEQ "">
                <cfif arguments.appSettings.getMatch_BB_DD_Based_On_Same_ReferenceNum()>
                AND
                (
                    (
                        ((BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IS NOT NULL) AND (BSA_Foodservice_Customers.Name LIKE '%#arguments.Distributor_Name#%'))
                        OR
                        ((Billback.Billback_Payee_Type_ID = 1) AND (VM.Vendor_Master_ID IS NOT NULL) AND (VM.Vendor_Name LIKE '%#arguments.Distributor_Name#%'))
                    )	OR
                        LTRIM(RTRIM(Billback.BB_Reference)) = @DD_Reference
                )
                <cfelse>
                AND
                (
                    ((BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IS NOT NULL) AND (BSA_Foodservice_Customers.Name LIKE '%#arguments.Distributor_Name#%'))
                     OR
                    ((Billback.Billback_Payee_Type_ID = 1) AND (VM.Vendor_Master_ID IS NOT NULL) AND (VM.Vendor_Name LIKE '%#arguments.Distributor_Name#%'))
                )
                </cfif>
            </cfif>
            </cfif>
            <!------ distributor name ----->
            <cfif arguments.Distributor_Name NEQ "">
                AND
                (
									((BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IS NOT NULL) AND (BSA_Foodservice_Customers.Name LIKE '%#arguments.Distributor_Name#%'))
									OR
									((Billback.Billback_Payee_Type_ID = 1) AND (VM.Vendor_Master_ID IS NOT NULL) AND (VM.Vendor_Name LIKE '%#arguments.Distributor_Name#%'))
									<cfif arguments.Include_Eligible_Programs eq 1><!------ also include billback with programs which has this distributor ----->
									OR billback.billback_id IN ( SELECT 	DISTINCT billback_id FROM 	V_Billback_Program_Distributor WHERE 	NAME LIKE '%#trim(arguments.Distributor_Name)#%' )
									</cfif>
                )
            </cfif>
            <!------ Distributor Sold To ----->
            <cfif arguments.soldToNo NEQ "">
                AND
                (
                    (
                     (
                     	BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IS NOT NULL
                     AND BSA_Foodservice_Customers.Shr_Ship_To LIKE '%#arguments.soldToNo#%'
                     )
                    OR (VM.Vendor_ID LIKE '%#arguments.soldToNo#%')
                    )
                    <cfif arguments.Include_Eligible_Programs eq 1><!------ also include billback with programs which has this distributor ----->
                    OR billback.billback_id IN ( SELECT 	DISTINCT billback_id FROM 	V_Billback_Program_Distributor WHERE 	shr_ship_to LIKE '%#trim(arguments.soldToNo)#%' )
                    </cfif>
                )
            </cfif>

            <!--- Match billbacks to a deduction from Match Central --->
            <!--- When the Payee is the Vendor (Vendor_Master_ID in the Distributor_ID field in the Billback_Distributor
                  table, then for ship to searches, we need to treat Vendor_ID as both ship_to and bill_to.
                  Sameway for Name searches, we should treat Vendor_Name as both Distributor_name and Bill_To Name.
             --->
            <cfif (arguments.MC_Shr_Ship_to NEQ "")>
            AND
            (
            BSA_Foodservice_Customers.Shr_Ship_To = '#arguments.MC_Shr_Ship_To#'
            OR BSA_Foodservice_Customers.Name LIKE '%#TRIM(arguments.MC_Distributor_Name)#%'
            OR VM.Vendor_ID = '#arguments.MC_Shr_Ship_To#'
            OR VM.Vendor_Name LIKE '%#TRIM(arguments.MC_Distributor_Name)#%'
            <cfif arguments.MC_Shr_Bill_To NEQ "">
             OR VM.Vendor_ID = '#arguments.MC_Shr_Bill_To#'
             OR VM.Vendor_Name LIKE '%#TRIM(arguments.MC_Bill_To_Name)#%'
            </cfif>
            )
            </cfif>
            <!---D82085 :: JRS Upgrade 8.0 - BR6 Wildcard Search START--->
             <cfif isDefined('arguments.MC_Distributor_Family_ID') AND arguments.MC_Distributor_Family_ID NEQ "">
            	AND BSA_Foodservice_Customers.Family_ID = '#arguments.MC_Distributor_Family_ID#'
            </cfif>
            <!---D82085 :: JRS Upgrade 8.0 - BR6 Wildcard Search END--->
            <!--- Match billbacks to a deduction from Match Central --->
            <cfif (arguments.MC_Shr_Bill_To NEQ "")>
                <cfif (appSettings.get_Setting('Deduction_match_using_bill_to_vendor') EQ '1')>
                    AND ( VM2.Vendor_ID = '#arguments.MC_Shr_Bill_To#'
                    OR VM2.Vendor_Name LIKE '%#TRIM(arguments.MC_Bill_To_Name)#%'
                    OR VM.Vendor_ID = '#arguments.MC_Shr_Bill_To#'
                    OR VM.Vendor_Name LIKE '%#TRIM(arguments.MC_Bill_To_Name)#%'
                    )
                <cfelse>
                    AND ( Distributor_Bill_To.Shr_Bill_To = '#arguments.MC_Shr_Bill_To#'
                    OR Distributor_Bill_To.Name LIKE '%#TRIM(arguments.MC_Bill_To_Name)#%'
                    OR VM.Vendor_ID = '#arguments.MC_Shr_Bill_To#'
                    OR VM.Vendor_Name LIKE '%#TRIM(arguments.MC_Bill_To_Name)#%'
                    <cfif arguments.MC_Shr_Ship_to NEQ "">
                        OR VM.Vendor_ID = '#arguments.MC_Shr_Ship_To#'
                        OR VM.Vendor_Name LIKE '%#TRIM(arguments.MC_Distributor_Name)#%'
                   </cfif>
                    )
                </cfif>
          </cfif>

            <!------ operator name ----->
            <cfif arguments.Operator_Name NEQ "">
                AND
                (
                    ((Billback.Billback_Payee_Type_ID = 2) AND (BSAO.BSA_Operator_ID IS NOT NULL) AND (BSAO.Operator_Name LIKE '%#arguments.Operator_Name#%'))
                    OR
                    ((Billback.Billback_Payee_Type_ID = 6) AND (BO.Operator_ID IS NULL) AND (BO.BB_Operator_Name LIKE '%#arguments.Operator_Name#%'))
                    OR
                    ((Billback.Billback_Payee_Type_ID = 1) AND (BSA_Operator_1.BSA_Operator_ID IS NOT NULL) AND (BSA_Operator_1.Operator_Name LIKE '%#arguments.Operator_Name#%'))
                    <cfif arguments.Include_Eligible_Programs eq 1><!------ also include billback with programs which has this operator ----->
                    OR billback.billback_id IN ( SELECT 	DISTINCT billback_id FROM 	V_Billback_Program_Operator WHERE 	operator_name LIKE '%#trim(arguments.Operator_Name)#%' )
                    </cfif>
                )
            </cfif>
            <!------ operator ID ----->
            <cfif arguments.operatorID NEQ "">
                AND
                (
                    <!--- BJF 15836 -- I removed a coalesce in ID which meant that if there was a legacy ID you couldn't search by BA ID and also a null check which should never be true --->
                        <!--- Checks for operators on billback, only when payee is operator --->
                    ((Billback.Billback_Payee_Type_ID = 2) AND (BSAO.Legacy_ID LIKE '%#arguments.operatorID#%' OR cast(BSAO.BSA_Operator_ID as char(50)) LIKE '%#arguments.operatorID#%'))
                    OR
                        <!--- Checks for operator on program, but only when payee is distributor --->
                    ((Billback.Billback_Payee_Type_ID = 1) AND (BSA_Operator_1.Legacy_ID LIKE '%#arguments.operatorID#%' OR cast(BSA_Operator_1.BSA_Operator_ID as char(50)) LIKE '%#arguments.operatorID#%'))
                    <cfif arguments.Include_Eligible_Programs eq 1><!------ also include billback with programs which has this operator regardless of payee ----->
                    OR billback.billback_id IN ( SELECT 	DISTINCT billback_id FROM V_Billback_Program_Operator WHERE operator_id LIKE '%#trim(arguments.operatorID)#%' )
                    </cfif>
                )
            </cfif>

            <cfif arguments.Billback_Number NEQ "">
                AND Billback.BB_Reference LIKE '%#arguments.Billback_Number#%'
            </cfif>
            <cfif arrayLen(local.payable_numbers)>  <!--- 50885 --->
          		AND ( 1 = 0 <cfloop from="1" to="#arrayLen(local.payable_numbers)#" index="local.payable_index"> OR Billback.BB_Code LIKE '%#trim(local.payable_numbers[ local.payable_index ])#%' </cfloop> )
            </cfif>
            <cfif arguments.Payable_Number NEQ "">
							<!--- 75568 :: Match Central - mass select and create list options START ---->
							AND Exists (	SELECT 1  FROM ##TMP_Payable_List TMP 	WHERE Billback.BB_Code like '%' + TMP.Payable + '%' 	)
							<!--- 75568 :: Match Central - mass select and create list options END ---->
            </cfif>

    <!---92675 :: BB Search modifications START--->
    <cfif structKeyExists(arguments, "billback_list") AND arguments.billback_list NEQ "">
        AND Exists (SELECT 1
														FROM ##TMP_billback_list TMP
														WHERE Billback.BB_Reference
														<cfif structKeyExists(arguments, "match_type") AND arguments.match_type EQ "partial">
																LIKE '%' + TMP.Billback + '%'
														<cfelse>
															= TMP.Billback
														</cfif>
														)
		</cfif>

		<cfif structKeyExists(arguments, "program_list") AND arguments.program_list NEQ "">
        AND Exists (SELECT 1
														FROM ##TMP_program_list TMP
														WHERE Contract_Main.Contract_Number
														<cfif structKeyExists(arguments, "match_type") AND arguments.match_type EQ "partial">
																LIKE '%' + TMP.program_list + '%'
														<cfelse>
															= TMP.program_list
														</cfif>
													)
		</cfif>

		<cfif structKeyExists(arguments, "reference_list") AND arguments.reference_list NEQ "">
        AND Exists (SELECT 1
														FROM ##TMP_reference_list TMP
														WHERE Billback.referenceNum
														<cfif structKeyExists(arguments, "match_type") AND arguments.match_type EQ "partial">
																LIKE '%' + TMP.reference + '%'
														<cfelse>
															= TMP.reference
														</cfif>
														)
    </cfif>

	<cfif structKeyExists(arguments, "distributor_list") AND arguments.distributor_list NEQ "">
	AND Exists (SELECT 1
	            FROM ##TMP_distributor_list TMP
		    WHERE (
				(
				  BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IS NOT NULL
				  AND BSA_Foodservice_Customers.Name <cfif structKeyExists(arguments, "match_type") AND arguments.match_type EQ "partial">
				  					LIKE '%' + TMP.distributor_list + '%'
				                                     <cfelse>
								       = TMP.distributor_list
								     </cfif>
			        )
				OR
				( Billback.Billback_Payee_Type_ID = 1
				  AND VM.Vendor_Master_ID IS NOT NULL
				  AND VM.Vendor_Name <cfif structKeyExists(arguments, "match_type") AND arguments.match_type EQ "partial">
				                      LIKE '%' + TMP.distributor_list + '%'
				                     <cfelse>
						      = TMP.distributor_list
						     </cfif>
			        )
				<cfif arguments.Include_Eligible_Programs eq 1><!------ also include billback with programs which has this distributor ----->
				OR billback.billback_id IN ( SELECT DISTINCT billback_id
				                             FROM V_Billback_Program_Distributor
							     WHERE NAME <cfif structKeyExists(arguments, "match_type") AND arguments.match_type EQ "partial">
							     		LIKE '%' + TMP.distributor_list + '%'
								        <cfelse>
									= TMP.distributor_list
									</cfif>
				                            )
				</cfif>
		         )
	         )
	</cfif>

		<cfif structKeyExists(arguments, "operator_list") AND arguments.operator_list NEQ "">
        AND Exists (SELECT 1
	FROM ##TMP_operator_list TMP
	WHERE (
		( Billback.Billback_Payee_Type_ID = 2
		AND BSAO.BSA_Operator_ID IS NOT NULL
		AND BSAO.Operator_Name <cfif structKeyExists(arguments, "match_type") AND arguments.match_type EQ "partial">
					LIKE '%' + TMP.operator_list + '%'
					<cfelse>
					= TMP.operator_list
					</cfif>
		)
		OR
			( Billback.Billback_Payee_Type_ID = 6
			AND BO.Operator_ID IS NULL
			AND BO.BB_Operator_Name <cfif structKeyExists(arguments, "match_type") AND arguments.match_type EQ "partial">
						LIKE '%' + TMP.operator_list + '%'
						<cfelse>
						= TMP.operator_list
						</cfif>
			)
		OR
			( Billback.Billback_Payee_Type_ID = 1
			AND BSA_Operator_1.BSA_Operator_ID IS NOT NULL
			AND BSA_Operator_1.Operator_Name <cfif structKeyExists(arguments, "match_type") AND arguments.match_type EQ "partial">
			                                  LIKE '%' + TMP.operator_list + '%'
			                                 <cfelse>
			                                  = TMP.operator_list
			                                 </cfif>
			)
		)
	    )
		</cfif>

		<cfif structKeyExists(arguments, "operator_number_list") AND arguments.operator_number_list NEQ "">
        AND Exists (SELECT 1
		FROM ##TMP_operator_number_list TMP
		WHERE (
			( Billback.Billback_Payee_Type_ID = 2
			AND (
			BSAO.Legacy_ID <cfif structKeyExists(arguments, "match_type") AND arguments.match_type EQ "partial">
					LIKE '%' + TMP.operator_number_list + '%'
					<cfelse>
					= TMP.operator_number_list
					</cfif>
			OR cast(BSAO.BSA_Operator_ID as char(50)) <cfif structKeyExists(arguments, "match_type") AND arguments.match_type EQ "partial">
								   LIKE '%' + TMP.operator_number_list + '%'
								  <cfelse>
								   = TMP.operator_number_list
								  </cfif>
			)
			)OR( Billback.Billback_Payee_Type_ID = 1
			AND (
			BSA_Operator_1.Legacy_ID <cfif structKeyExists(arguments, "match_type") AND arguments.match_type EQ "partial">
			LIKE '%' + TMP.operator_number_list + '%'
			<cfelse>
			= TMP.operator_number_list
			</cfif>
			OR BSA_Operator_1.BSA_Operator_ID <cfif structKeyExists(arguments, "match_type") AND arguments.match_type EQ "partial">
			LIKE '%' + TMP.operator_number_list + '%'
			<cfelse>
			= TMP.operator_number_list
			</cfif>
			)
			)
)
														)
		</cfif>

		<cfif structKeyExists(arguments, "vendor_list") AND arguments.vendor_list NEQ "">
        AND Exists (SELECT 1
														FROM ##TMP_vendor_list TMP
														WHERE Vendor_dist_oper.Vendor_ID <cfif structKeyExists(arguments, "match_type") AND arguments.match_type EQ "partial">
																																													LIKE '%' + TMP.vendor_list + '%'
																																												<cfelse>
																																													= TMP.vendor_list
																																												</cfif>
																			OR Vendor_Master.Vendor_ID <cfif structKeyExists(arguments, "match_type") AND arguments.match_type EQ "partial">
																																												LIKE '%' + TMP.vendor_list + '%'
																																											<cfelse>
																																												= TMP.vendor_list
																																											</cfif>
																			OR VM1.Vendor_ID <cfif structKeyExists(arguments, "match_type") AND arguments.match_type EQ "partial">
																																				LIKE '%' + TMP.vendor_list + '%'
																																			<cfelse>
																																				= TMP.vendor_list
																																			</cfif>
																			OR VM2.Vendor_ID <cfif structKeyExists(arguments, "match_type") AND arguments.match_type EQ "partial">
																																				LIKE '%' + TMP.vendor_list + '%'
																																			<cfelse>
																																				= TMP.vendor_list
																																			</cfif>
													)
		</cfif>


   <cfif structKeyExists(arguments, "soldToNo_list") AND arguments.soldToNo_list NEQ "">
	   AND Exists (SELECT 1
			FROM ##TMP_soldToNo_list TMP
			WHERE  (
			(
			(
			BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IS NOT NULL
			AND BSA_Foodservice_Customers.Shr_Ship_To <cfif structKeyExists(arguments, "match_type") AND arguments.match_type EQ "partial">
			LIKE '%' + TMP.soldToNo_list + '%'
			<cfelse>
			= TMP.soldToNo_list
			</cfif>
			)
			OR VM.Vendor_ID <cfif structKeyExists(arguments, "match_type") AND arguments.match_type EQ "partial">
			LIKE '%' + TMP.soldToNo_list + '%'
			<cfelse>
			= TMP.soldToNo_list
			</cfif>
			)
			<cfif arguments.Include_Eligible_Programs eq 1><!------ also include billback with programs which has this distributor ----->
			OR billback.billback_id IN ( SELECT 	DISTINCT billback_id
			FROM 	V_Billback_Program_Distributor
			WHERE 	shr_ship_to <cfif structKeyExists(arguments, "match_type") AND arguments.match_type EQ "partial">
			LIKE '%' + TMP.soldToNo_list + '%'
			<cfelse>
			= TMP.soldToNo_list
			</cfif>

			)
			</cfif>

			)
			)
    </cfif>

    <!---92675 :: BB Search modifications END--->
             <cfif arguments.Billback_Title NEQ "">
                AND Billback.BB_Title LIKE '%#arguments.Billback_Title#%'
            </cfif>
            <cfif arguments.BB_Closing_Method NEQ "">
                AND Billback.BB_Closing_Method = '#arguments.BB_Closing_Method#'
            </cfif>
            <cfif arguments.BB_Closing_Method EQ "" AND arguments.source EQ "Deductions">
                AND Billback.BB_Closing_Method NOT IN (3,4)
            </cfif>

			<cfif (isDefined("arguments.Chk_Duplicates") AND arguments.Chk_Duplicates EQ 1)>
				AND ISNULL(Billback.BB_Upload_Dup_Group_ID,'') != ''
			</cfif>
			<cfif (isDefined("arguments.Chk_User_Duplicates") AND arguments.Chk_User_Duplicates EQ 1)>
				AND ISNULL(Billback.BB_All_Dup_Group_ID,'') != ''
				AND Billback.BB_Closing_Method != 4
				AND Billback.Billback_Status_ID != 8
            </cfif>
            <!--- 98106 :: Auto Deviations to consider if bb is beyond program budget START--->
			<cfif (isDefined("arguments.BB_Over_Budget") AND arguments.BB_Over_Budget EQ 1)>
				AND Billback.BB_In_RFA_Due_To_Budget = 1
				AND Billback.Billback_Status_ID = 2
			</cfif>
            <!--- 98106 :: Auto Deviations to consider if bb is beyond program budget END--->
			<cfif (isDefined("arguments.chk_opr_location_dup") AND arguments.chk_opr_location_dup EQ 1)>
				AND (ISNULL(Billback.BB_Loc_Duplicate,'') != '' OR Billback.BB_Loc_Duplicate != 0 )
			</cfif>

            <cfif arguments.Amount_Operator NEQ "" AND isNumeric(arguments.Amount)>
                <cfswitch EXPRESSION="#arguments.Amount_Operator#">
                    <cfcase VALUE="Greater_Or_Equal">
                        AND Billback.BB_Amount >= #arguments.Amount#
                    </cfcase>
                    <cfcase VALUE="Equal">
                        AND Billback.BB_Amount = #arguments.Amount#
                    </cfcase>
                    <cfcase VALUE="Less_Or_Equal">
                        AND Billback.BB_Amount <= #arguments.Amount#
                    </cfcase>
                </cfswitch>
            </cfif>
            <cfif arguments.source EQ "Deductions">
				<cfif isDefined("arguments.Filter_Distributor_ID") AND arguments.Filter_Distributor_ID NEQ "">
				    AND Billback_Distributor.Distributor_ID = '#arguments.Filter_Distributor_ID#'
				</cfif>
				<cfif isDefined("arguments.Filter_Distributor_Bill_To_ID") AND arguments.Filter_Distributor_Bill_To_ID NEQ "">
					<cfif appSettings.get_Setting('Deduction_match_using_bill_to_vendor') EQ '1'>
						AND BT2.Shr_Bill_To = vm2.Vendor_ID
					<cfelse>
						AND BSA_Foodservice_Customers.Distributor_Bill_To_ID = '#arguments.Filter_Distributor_Bill_To_ID#'
					</cfif>
				</cfif>

                <!------
                When you make any change here please take into consideration of the following.
                This section of code is used to associate a billback to a deduction.
                There is one more place this can happen, a deduction can be associated to a billback
                That also follow the same rule used here.
                So if any change is made to any rules in this section, please make change in the other place too
                ----->
                <cfif LEFT(application.returned_customer_setting.Customer_Keyword,1) NEQ "H" AND LEFT(application.returned_customer_setting.Customer_Keyword,1) NEQ "M">
                    AND Billback.Billback_Status_ID > 2
										AND Billback.Billback_Status_ID <> 5
                <cfelse>
					<cfset var_approved_BB_Only = 1 />
                    AND Billback.Billback_Status_ID = 3 <!--- AND Billback.BB_Closing_Method = 2 --->
                    <cfif application.returned_customer_setting.Upload_GL_Code EQ 1>
                    AND Billback.Billback_ID IN ( SELECT 	Top 1 Billback_ID
																																			FROM 	Gl_Code_Allocation
																																			WHERE 	Billback_ID = Billback.Billback_ID
																																			AND GL_Code_Allocation.Deleted = 0
																																			AND Allocation_Saved = 1
																																	)
					<!--- commenting below as we the same filter in the where condition using @Tmp_BB_Parent_ID_List --->
					<!---
                    AND
                    NOT EXISTS
                    ( 	SELECT Top 1 *
                        FROM Billback ParentCheck
                        WHERE ParentCheck.BB_Parent_ID =  Billback.Billback_ID
                    )
					--->
					</cfif>
                </cfif>
                AND BB_Associated_To_DD <> 1
                <!------ and this billback is not a split parent ----->
				AND NOT EXISTS
				( 	SELECT ParentCheck.BB_Parent_ID
				    FROM @Tmp_BB_Parent_ID_List ParentCheck
				    WHERE ParentCheck.BB_Parent_ID =  Billback.Billback_ID
				)
                <!---AND	Billback.Billback_ID NOT IN (SELECT BB_Parent_ID FROM @Tmp_BB_Parent_ID_List)--->
                <!------ vendor selection is required ----->
                <cfif application.returned_customer_setting.Upload_GL_Code EQ 1>
                    AND BB_Approved.Vendor_Master_ID IS NOT NULL
                </cfif>
                <!------ AND	BB_Approved.Paid_Amount <= (SELECT DD_Amount FROM Deductions WHERE Deduction_ID = '#arguments.Deduction_ID#') ----->
                <!--- For clients like McCain --->
                <cfif arguments.filterAmount>
                    <cfif arguments.appSettings.getDDCloseWithEqualBBAmt()>
                        <cfif arguments.appSettings.getMultiple_BB_Per_Deduction()>
                            AND Round(BB_Approved.Paid_Amount,2) <= @DD_Amount2
                        <cfelse>
                            AND Round(BB_Approved.Paid_Amount,2) = @DD_Amount2
                        </cfif>
                    <!--- For clients like Heinz --->
                    <cfelse>
                        <cfif arguments.matchToCredit>
                            AND BB_Approved.Paid_Amount <= #arguments.selecteditemvalue#
                        <cfelse>
                            AND	BB_Approved.Paid_Amount <= @DD_Amount
                        </cfif>
                    </cfif>
                </cfif>
            </cfif>
            <cfif arguments.BB_Aging NEQ 0>
            <cfswitch EXPRESSION="#arguments.BB_Aging#">
                <cfcase VALUE="1">
                    AND DateDiff(d, Billback.BB_Date, GetDate()) >= #arguments.Aging_Days#
                    AND Billback.Billback_Status_ID < 5
                </cfcase>
                <cfcase VALUE="2">
                    AND
                    (
                        DateDiff(d, Billback.BB_Date, GetDate()) < #arguments.Aging_Days#
                        OR
                        Billback.Billback_Status_ID >= 5
                    )
                </cfcase>
            </cfswitch>
            </cfif>
            <!---Dev Note: Milan; 11365-  BB_Date_Type is either billback, created, approved or RFA'd date --->
            <cfif arguments.Date_Operator NEQ "" AND isDate(arguments.BB_Date) AND (ListFindNOCase("Greater_Or_Equal,Equal,Less_Or_Equal",arguments.Date_Operator,",") GT 0)>
            AND DateDiff(d, '#arguments.BB_Date#', #arguments.BB_Date_Type#)
            <cfswitch EXPRESSION="#arguments.Date_Operator#">
                <cfcase VALUE="Greater_Or_Equal">
                    >=
                </cfcase>
                <cfcase VALUE="Equal">
                    =
                </cfcase>
                <cfcase VALUE="Less_Or_Equal">
                    <=
                </cfcase>
            </cfswitch>
            0
            </cfif>
            <cfif arguments.Start_Date_Operator NEQ "" AND isDate(arguments.Start_Date) AND (ListFindNOCase("Greater_Or_Equal,Equal,Less_Or_Equal",arguments.Start_Date_Operator,",") GT 0)>
            AND DateDiff(d, '#arguments.Start_Date#', Billback.BB_Start_Date)
            <cfswitch EXPRESSION="#arguments.Start_Date_Operator#">
                <cfcase VALUE="Greater_Or_Equal">
                    >=
                </cfcase>
                <cfcase VALUE="Equal">
                    =
                </cfcase>
                <cfcase VALUE="Less_Or_Equal">
                    <=
                </cfcase>
            </cfswitch>
            0
            </cfif>
            <cfif arguments.End_Date_Operator NEQ "" AND isDate(arguments.End_Date) AND (ListFindNOCase("Greater_Or_Equal,Equal,Less_Or_Equal",arguments.End_Date_Operator,",") GT 0)>
            AND DateDiff(d, '#arguments.End_Date#', Billback.BB_End_Date)
            <cfswitch EXPRESSION="#arguments.End_Date_Operator#">
                <cfcase VALUE="Greater_Or_Equal">
                    >=
                </cfcase>
                <cfcase VALUE="Equal">
                    =
                </cfcase>
                <cfcase VALUE="Less_Or_Equal">
                    <=
                </cfcase>
            </cfswitch>
            0
            </cfif>

            <!---filter on payment processor if payment processor id is not empty--->
            <cfif application.returned_customer_setting.Accounting_Specialist eq 1>
            <cfif  trim(arguments.PP_User_ID) NEQ "">
                AND Program_Accounting_Specialist.User_ID = '#arguments.PP_User_ID#'
            </cfif>
            </cfif>
            <!---- vendor id ---->
            <cfif arguments.vendorID NEQ "">
            and (vendor_dist_oper.Vendor_ID like '%#trim(arguments.vendorID)#%' OR Vendor_Master.Vendor_ID like '%#trim(arguments.vendorID)#%' OR vm1.Vendor_ID like '%#trim(arguments.vendorID)#%' OR vm2.Vendor_ID like '%#trim(arguments.vendorID)#%')
            </cfif>
            <cfif arguments.vendorName neq "">
                AND ( (vm1.Vendor_Name like '%#trim(arguments.vendorName)#%') or (vm2.Vendor_Name like '%#trim(arguments.vendorName)#%') )
            </cfif>
            <!--- ownership --->
            <cfif arguments.user_Position NEQ "" or arguments.user_Position_of NEQ "">
            <cfswitch EXPRESSION="#arguments.User_Position_Operator#">
                <cfcase VALUE="Created By">
                    <cfif arguments.user_Position_of NEQ "">
                        AND Billback.BB_Creator_ID = '#arguments.user_Position_of#'
                    </cfif>
                    <cfif arguments.user_Position NEQ "">
                        AND Billback.BB_Creator_User_Position_ID = #arguments.user_Position#
                    </cfif>
                </cfcase>
                <cfcase VALUE="Requesting Approval By">
                    <cfif arguments.user_Position_of NEQ "">
                        AND Billback.BB_Request_Approval_User_ID = '#arguments.user_Position_of#'
                    </cfif>
                    <cfif arguments.user_Position NEQ "">
                    AND EXISTS (
                        SELECT 	User_Positions_ID
                        FROM	User_Position_Holders
                        WHERE	User_Position_Holders.User_ID = Billback.BB_Request_Approval_User_ID
                        AND User_Position_Holders.Deleted = 0
                        AND User_Position_Holders.User_Positions_ID = #arguments.user_Position#
                    )
                    </cfif>
                </cfcase>
                <cfcase VALUE="Approved By">
                    <cfif arguments.user_Position_of NEQ "">
                        AND BB_Approved.User_Approved = '#arguments.user_Position_of#'
                    </cfif>
                    <cfif arguments.user_Position NEQ "">
                    AND EXISTS (
                        SELECT 	User_Positions_ID
                        FROM	User_Position_Holders
                        WHERE User_Position_Holders.User_ID = BB_Approved.User_Approved
                        AND User_Position_Holders.Deleted = 0
                        AND User_Position_Holders.User_Positions_ID = #arguments.user_Position#
                    )
                    </cfif>
                </cfcase>
            </cfswitch>
            </cfif>
            <!---handle identifier--->
            <cfif isDefined("arguments.Discount_Identifier") and arguments.Discount_Identifier NEQ 0 AND len(trim(arguments.Discount_Identifier))>
                and billback.billback_id in
                (
                    select distinct billback.billback_id
                    from billback
                    inner join billback_program
                            on billback.billback_id = billback_program.billback_id
                            and billback_program.deleted = 0
                    INNER JOIN	Contract_Main
                            on  Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
                    INNER JOIN Program_Control_Panel_Options
                            ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
                            AND Program_Control_Panel_Options.Discount_Identifier_ID = '#arguments.Discount_Identifier#'
                )
            </cfif>
            <!--- Dev Notes: Ana 12051 Search on uploaded BB --->
            <cfif arguments.Uploaded_Billback NEQ 0>
              <!--- Dev Notes: Anand Rao/19-Aug-2010
                    D24500: Billback Search Changes --->
                <!--- AND Uploaded_Billback = #arguments.Uploaded_Billback# --->
              <cfif arguments.Uploaded_Billback EQ "MANUAL">
                AND Uploaded_Billback = 0
              <cfelseif arguments.Uploaded_Billback EQ "UPLOADED">
                AND Uploaded_Billback =  2
              <cfelseif arguments.Uploaded_Billback EQ "BATCH">
                AND Uploaded_Billback =  3
              <cfelseif arguments.Uploaded_Billback EQ "AUTOPAY">
                AND Auto_Billback = 1
              <cfelseif arguments.Uploaded_Billback EQ "AUTOAPPROVED">
                AND Auto_Approved = 1 AND Auto_Billback = 0
            <cfelseif arguments.Uploaded_Billback EQ "QUICKPAY">
                AND billback.Quick_Pay = 1
              </cfif>
            </cfif>

            <!--- Dev Notes: Milan;16619 - Exclude Locked Billbacks on billback search for deduction association.
                    This  variable "ExcludeLockedBillbacks" has been set to 1 on '/deductions/search_screens/billbacks.cfm'
            --->
            <cfif arguments.ExcludeLockedBillbacks EQ 1>
                <cfif NOT arguments.MATCHCentral>
                    AND Billback_Allied.BB_Is_Locked = 0
                </cfif>
            </cfif>

            <cfif arguments.HideAllSplitBB>
                AND NOT EXISTS
				( 	SELECT Top 1 BB_Parent_ID
				    FROM @Tmp_BB_Parent_ID_List ParentCheck
				    WHERE ParentCheck.BB_Parent_ID =  Billback.Billback_ID
				)
                AND Billback.BB_Split_Number IS NULL
            </cfif>
            <cfif arguments.MATCHCentral AND var_approved_BB_Only EQ 0> <!--- set above when status=3 is already applied --->
                AND Billback.Billback_Status_ID NOT IN (4,5,7)
            </cfif>
            <!--- Milan (19466) The Billback Payee's Business segment ID needs to match the business
				  segment of the deduction's distributor
			--->
			<cfif arguments.businessSegmentsOn eq 1 AND (arguments.source EQ "Deductions" OR arguments.MATCHCentral) and isDefined("arguments.Deduction_ID")>
				AND
					CASE Billback.Billback_Payee_Type_ID
						WHEN 1
							THEN
								CASE BSA_Foodservice_Customers.Shr_Ship_To
									WHEN NULL
										THEN
											(
											SELECT ISNULL(BSA_Foodservice_Customers.Business_Segment_ID, Distributor_Bill_To.Business_Segment_ID)
											FROM Deductions
											LEFT JOIN BSA_Foodservice_Customers
											ON Deductions.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
											LEFT JOIN Distributor_Bill_To
											ON Distributor_Bill_To.Distributor_Bill_To_ID = Deductions.Distributor_Bill_To_ID
											AND Deductions.Distributor_ID IS NULL <!---  When deduction does not have distributor, check bill to --->
											WHERE Deductions.Deduction_ID = '#arguments.Deduction_ID#'
											)
									ELSE
									BSA_Foodservice_Customers.Business_Segment_ID
								END
						WHEN 2
							THEN
							(
							SELECT BSA_Operator.Business_Segment_ID
							FROM BSA_Operator
							INNER JOIN Billback_Operator
							ON BSA_Operator.BSA_Operator_ID = Billback_Operator.Operator_ID
							AND Billback_Operator.Deleted = 0
							WHERE Billback_Operator.Billback_ID = Billback.Billback_ID
							)
						WHEN 3
							THEN
							(
							SELECT BSA_Foodservice_Brokers.Business_Segment_ID
							FROM BSA_Foodservice_Brokers
							INNER JOIN Billback_Broker
							ON BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Billback_Broker.Broker_ID
							AND Billback_Broker.Deleted = 0
							WHERE Billback_Broker.Billback_ID = Billback.Billback_ID
							)
						ELSE
							(
							SELECT BSA_Foodservice_Customers.Business_Segment_ID
							FROM Deductions
							INNER JOIN BSA_Foodservice_Customers
							ON Deductions.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
							WHERE Deductions.Deduction_ID = '#arguments.Deduction_ID#'
							)
					 END
				IN (
						SELECT ISNULL(BSA_Foodservice_Customers.Business_Segment_ID, Distributor_Bill_To.Business_Segment_ID)
						FROM Deductions
						LEFT JOIN BSA_Foodservice_Customers
						ON Deductions.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
						LEFT JOIN Distributor_Bill_To
						ON Distributor_Bill_To.Distributor_Bill_To_ID = Deductions.Distributor_Bill_To_ID
						AND Deductions.Distributor_ID IS NULL <!---  When deduction does not have distributor, check bill to --->
						WHERE Deductions.Deduction_ID = '#arguments.Deduction_ID#'
					)

				</cfif>
			<cfif arguments.Check_Number NEQ "">
      	AND BB_Approved.Check_Number LIKE '%#arguments.Check_Number#%'
      </cfif>

            <!--- 52463 --->
            <cfif arguments.status eq '2001'>       <!--- under review :: logic copied from scorecard_home.cfm --->
                AND NOT EXISTS (SELECT 1
																								FROM BB_Agreed_Info
																								WHERE Deleted = 0
																								AND Billback_ID = Billback.Billback_ID
																								AND User_position_ID IN (#PreserveSingleQuotes(local.UserPositionList)#)
																								AND Authority_Sequence_ID = '#local.Auth_Sequence_ID#')
                AND
                        (
                            #Get_Profile_Settings.BB_Approve# = 0
                            <cfif var_apply_template_profile_filter><!--- User cannot approve this billback --->
                                OR Billback.Billback_ID IN (select Billback_ID FROM ##tmp_billacks_cannot_approve)
                            </cfif>

                            OR

                            ((  SELECT  Top 1 User_positions_ID
                                    FROM    BillbackApprovablePositions
                                    WHERE   BillbackApprovablePositions.Billback_ID = Billback.Billback_ID AND
                                            NOT (   (   ISNULL(Authority_Sequence_Order, 0) = 0 OR
                                                        Authority_Sequence_Order IN ( SELECT ISNULL(Authority_Sequence_ORDER,0)
                                                                                        FROM BB_Agreed_Info
                                                                                        INNER JOIN  Authority_Sequence
																																												ON Authority_Sequence.Authority_Sequence_ID = BB_Agreed_Info.Authority_Sequence_ID
                                                                                        WHERE  Billback_ID = Billback.Billback_ID
                                                                                        AND BB_Agreed_Info.Deleted = 0)
                                                    ) AND User_positions_ID IN (SELECT  DISTINCT User_position_ID
																																																		FROM BB_Agreed_Info
																																																		WHERE Billback_ID = Billback.Billback_ID
																																																		AND Deleted = 0)
                                                )
                                ORDER BY BillbackApprovablePositions.Service_Market_ID DESC, BillbackApprovablePositions.Service_Region_ID DESC, BillbackApprovablePositions.Service_Zone_ID DESC, BillbackApprovablePositions.Authority_Sequence_Order DESC
                                ) NOT IN (#PreserveSingleQuotes(local.UserPositionList)#))
                            OR

                            (   ISNULL((    SELECT  Top 1 Authority_Sequence_Order
                                            FROM    BillbackApprovablePositions
                                            WHERE   BillbackApprovablePositions.Billback_ID = Billback.Billback_ID
																						AND NOT ( (   ISNULL(Authority_Sequence_Order, 0) = 0
																							OR	Authority_Sequence_Order IN ( SELECT ISNULL(Authority_Sequence_ORDER,0)
																																																				FROM BB_Agreed_Info
																																																				INNER JOIN  Authority_Sequence
																																																				ON Authority_Sequence.Authority_Sequence_ID = BB_Agreed_Info.Authority_Sequence_ID
																																																				WHERE Billback_ID = Billback.Billback_ID
																																																				AND BB_Agreed_Info.Deleted = 0)
																																																			) AND User_positions_ID IN ( SELECT  DISTINCT User_position_ID
																																																																											FROM    BB_Agreed_Info
																																																																											WHERE   Billback_ID = Billback.Billback_ID
																																																																											AND Deleted = 0)
                                                        )
                                            ORDER BY BillbackApprovablePositions.Service_Market_ID DESC, BillbackApprovablePositions.Service_Region_ID DESC, BillbackApprovablePositions.Service_Zone_ID DESC, BillbackApprovablePositions.Authority_Sequence_Order DESC
                                        ),0) <> '#local.Auth_Sequence_Order#')
                        )

            <cfelseif arguments.status eq '2002'>   <!--- pending approval :: logic copied from scorecard_home.cfm --->
                AND NOT EXISTS (SELECT 1
                                  FROM BB_Agreed_Info
                                 WHERE Deleted = 0
                                   AND Billback_ID = Billback.Billback_ID
                                   AND User_position_ID IN (#PreserveSingleQuotes(local.UserPositionList)#)
                                   AND Authority_Sequence_ID = '#local.Auth_Sequence_ID#')
                AND     (
                            #Get_Profile_Settings.BB_Approve# = 1
                            <cfif var_apply_template_profile_filter><!--- User can approve this billback --->
                                AND Billback.Billback_ID NOT IN (select Billback_ID FROM ##tmp_billacks_cannot_approve)
                            </cfif>
                            AND
                            ((  SELECT  Top 1 User_positions_ID
                                    FROM    BillbackApprovablePositions
                                    WHERE   BillbackApprovablePositions.Billback_ID = Billback.Billback_ID AND
                                            NOT (   (   ISNULL(Authority_Sequence_Order, 0) = 0 OR
                                                        Authority_Sequence_Order IN (   SELECT      ISNULL(Authority_Sequence_ORDER,0)
																																																						FROM        BB_Agreed_Info
																																																						INNER JOIN  Authority_Sequence
																																																						ON Authority_Sequence.Authority_Sequence_ID = BB_Agreed_Info.Authority_Sequence_ID
																																																						WHERE       Billback_ID = Billback.Billback_ID
																																																						AND         BB_Agreed_Info.Deleted = 0)
                                                    ) AND
                                                    User_positions_ID IN (  SELECT  DISTINCT User_position_ID
																																													FROM    BB_Agreed_Info
																																													WHERE   Billback_ID = Billback.Billback_ID
																																													AND Deleted = 0)
                                                )
                                ORDER BY BillbackApprovablePositions.Service_Market_ID DESC, BillbackApprovablePositions.Service_Region_ID DESC, BillbackApprovablePositions.Service_Zone_ID DESC, BillbackApprovablePositions.Authority_Sequence_Order DESC
                                ) IN (#PreserveSingleQuotes(local.UserPositionList)#))
                            AND

                            (   ISNULL((    SELECT  Top 1 Authority_Sequence_Order
                                            FROM    BillbackApprovablePositions
                                            WHERE   BillbackApprovablePositions.Billback_ID = Billback.Billback_ID
																						AND NOT ( ( ISNULL(Authority_Sequence_Order, 0) = 0
																						OR Authority_Sequence_Order IN (   SELECT      ISNULL(Authority_Sequence_ORDER,0)
																																																				FROM        BB_Agreed_Info
																																																				INNER JOIN  Authority_Sequence
																																																				ON Authority_Sequence.Authority_Sequence_ID = BB_Agreed_Info.Authority_Sequence_ID
																																																				WHERE       Billback_ID = Billback.Billback_ID
																																																				AND         BB_Agreed_Info.Deleted = 0)
                                                            ) AND
                                                            User_positions_ID IN (  SELECT  DISTINCT User_position_ID
																																																	FROM    BB_Agreed_Info
																																																	WHERE   Billback_ID = Billback.Billback_ID
																																																	AND Deleted = 0)
                                                        )
                                            ORDER BY BillbackApprovablePositions.Service_Market_ID DESC, BillbackApprovablePositions.Service_Region_ID DESC, BillbackApprovablePositions.Service_Zone_ID DESC, BillbackApprovablePositions.Authority_Sequence_Order DESC
                                        ),0) = '#local.Auth_Sequence_Order#'
                            )
                        )

            <cfelseif arguments.status eq '2003'>   <!--- agreed --->
                AND EXISTS (SELECT 1
                                  FROM BB_Agreed_Info
                                 WHERE Deleted = 0
                                   AND Billback_ID = Billback.Billback_ID
                                   AND User_position_ID IN (#PreserveSingleQuotes(local.UserPositionList)#)
                                   AND Authority_Sequence_ID = '#local.Auth_Sequence_ID#')
            </cfif>
            <!--- 52463 --->
            <!---D107259 :: Billback access across Segments START ---->
                <cfif SegmentEnabled AND LEN(Business_Segment_ID_List)>
                    AND (
                    (Billback.Billback_Status_ID >= 2  AND Contract_Main.Business_Segment_ID in ( <cfqueryparam value="#Business_Segment_ID_List#" cfsqltype="CF_SQL_INTEGER" list="true"> ))
                        OR
                    (Billback.Billback_Status_ID = 1)
                    )
                </cfif>
               <!---D107259 :: Billback access across Segments END---->

			Order By #Replace(arguments.sql_Sort_By,'BB_Approved_Amount','Paid_Amount','ALL')#

			<cfif isDefined("arguments.startrow") and isDefined("arguments.endrow")>

				declare @recordcount int
				declare @TotalClaimAmount decimal(20,2)
				declare @TotalVariance decimal(20,2)

				select @recordcount = count(billback_id),
						@TotalClaimAmount = sum(CASE WHEN len(BB_Amount) = 0 then 0 ELSE BB_Amount END),
						@TotalVariance = sum(CASE WHEN len(BB_Variance) = 0 then 0 WHEN BB_Variance < 0 THEN 0 ELSE BB_Variance END)
				from ##tmp_billback_search_result

				select 	*, @recordcount as record_count, @TotalClaimAmount AS TotalClaimAmount, @TotalVariance AS TotalVariance
				from	##tmp_billback_search_result
				where	RowID between #arguments.startrow# and #arguments.endrow#

				drop table ##tmp_billback_search_result

			</cfif>
	<cfelse><!--- D57147 :: New Feature to Search for BB's by Customer Invoice --->

	SELECT DISTINCT Billback.Billback_ID, Billback.BB_Reference, Billback.BB_Start_Date, Billback.BB_End_Date,
				Billback.BB_Amount, Billback.BB_Expected_Amount,
				ISNull(BB_Approved.Paid_Amount, 0) AS BB_Approved_Amount, BB_Approved.Paid_Amount,
				Upload_ID = hl.Upload_ID,
				Unique_Key = Billback.BB_Reference + '-' + CAST(hl.Upload_ID as  varchar(100)),
				vm.Vendor_Name,
                vm.Vendor_ID,
				Payee_name =
					CASE WHEN  Billback.Billback_Payee_Type_ID = 1
					THEN
					/* Distributor */
					(SELECT DISTINCT TOP 1 ISNULL(BSA_Foodservice_Customers.Name,VM.Vendor_Name)
						FROM Billback_Distributor
						LEFT JOIN BSA_Foodservice_Customers
							ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Billback_Distributor.Distributor_ID
						LEFT JOIN Vendor_Master VM ON /* ---added VM join for Auto Pay w/multiple distributors */
							VM.vendor_Master_Id = Billback_Distributor.Distributor_ID
						WHERE	Billback_Distributor.Billback_ID = Billback.Billback_ID AND
							Billback_Distributor.Deleted = 0)

					WHEN Billback_Payee_Type_ID = 2 THEN
					/* Operator */
					(SELECT DISTINCT TOP 1 BSA_Operator.Operator_Name
						FROM BSA_Operator
						INNER JOIN Billback_Operator
							ON Billback_Operator.Billback_ID = Billback.Billback_ID
							AND Billback_Operator.Deleted = 0
							AND BSA_Operator.BSA_Operator_ID = Billback_Operator.Operator_ID)
					/* Broker */
					WHEN Billback_Payee_Type_ID = 3 THEN
					(SELECT DISTINCT TOP 1 BSA_Foodservice_Brokers.Broker_Name
						FROM BSA_Foodservice_Brokers
						INNER JOIN Billback_Broker
							ON Billback_Broker.Billback_ID = Billback.Billback_ID
							AND Billback_Broker.Deleted = 0
							AND BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Billback_Broker.Broker_ID)
					WHEN Billback_Payee_Type_ID = NULL THEN
					'N/A'
					END
				,Payee_ID =
					CASE WHEN  Billback.Billback_Payee_Type_ID = 1
					THEN
					/* Distributor */
					(SELECT DISTINCT TOP 1 ISNULL(BSA_Foodservice_Customers.Ship_To,VM.Vendor_ID)
						FROM Billback_Distributor
						LEFT JOIN BSA_Foodservice_Customers
							ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Billback_Distributor.Distributor_ID
						LEFT JOIN Vendor_Master VM ON /* added VM join for Auto Pay w/multiple distributors */
							VM.vendor_Master_Id = Billback_Distributor.Distributor_ID
						WHERE	Billback_Distributor.Billback_ID = Billback.Billback_ID AND
							Billback_Distributor.Deleted = 0)

					WHEN Billback_Payee_Type_ID = 2 THEN
					/* Operator */
					(SELECT DISTINCT TOP 1 CAST(BSA_Operator.BSA_Operator_ID AS VARCHAR(50))
						FROM BSA_Operator
						INNER JOIN Billback_Operator
							ON Billback_Operator.Billback_ID = Billback.Billback_ID
							AND Billback_Operator.Deleted = 0
							AND BSA_Operator.BSA_Operator_ID = Billback_Operator.Operator_ID)
					/* Broker */
					WHEN Billback_Payee_Type_ID = 3 THEN
					(SELECT DISTINCT TOP 1 BSA_Foodservice_Brokers.Broker_Shard
						FROM BSA_Foodservice_Brokers
						INNER JOIN Billback_Broker
							ON Billback_Broker.Billback_ID = Billback.Billback_ID
							AND Billback_Broker.Deleted = 0
							AND BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Billback_Broker.Broker_ID)
					WHEN Billback_Payee_Type_ID = NULL THEN
					'NA'
					END
				,Uploaded_Vendor_ID =
	                  CASE WHEN  Billback.Billback_Payee_Type_ID = 1
	                  THEN
	                  /* Distributor */
	                  (SELECT DISTINCT TOP 1 Uploaded_Vendor_ID
	                        FROM Billback_Distributor
	                        WHERE Billback_Distributor.Billback_ID = Billback.Billback_ID AND
	                              Billback_Distributor.Deleted = 0)

	                  WHEN Billback_Payee_Type_ID = 2 THEN
	                  /* Operator */
	                  (SELECT DISTINCT TOP 1 Uploaded_Vendor_ID
	                        FROM Billback_Operator
	                        WHERE Billback_Operator.Billback_ID = Billback.Billback_ID
	                              AND Billback_Operator.Deleted = 0)
	                  /* Broker */
	                  WHEN Billback_Payee_Type_ID = 3 THEN
	                  (SELECT DISTINCT TOP 1 Uploaded_Vendor_ID
	                        FROM Billback_Broker
	                        WHERE Billback_Broker.Billback_ID = Billback.Billback_ID
	                              AND Billback_Broker.Deleted = 0)
	                  WHEN Billback_Payee_Type_ID = NULL THEN
	                  'NA'
	                  END

	INTO ##tmp_billback_search_result

	FROM			Billback
	LEFT JOIN 	BB_Approved
	ON				BB_Approved.Billback_ID = Billback.Billback_ID
	AND				Billback.Billback_Status_ID > 2
	INNER JOIN Billback_Txt_Upload_Header_log hl
	ON				hl.Billback_ID = Billback.Billback_ID
	LEFT JOIN 	Vendor_Master vm
	ON          		vm.Vendor_Master_ID = BB_Approved.Vendor_Master_ID

	WHERE	Billback.Deleted = 0
	AND		Billback.Billback_ID NOT IN (select Billback_ID FROM ##tmp_billacks_cannot_see)
	AND		Billback.Uploaded_Billback in (2,3)
	<cfif len(url.Invoice_Number)>
		AND Billback.BB_Reference like '%#url.Invoice_Number#%'
	</cfif>
	<cfif len(url.Created_Date)>
		AND Billback.Created_Date
		<cfif url.dateFieldSign eq 1>
			> '#Dateformat(url.Created_Date,'mm/dd/yyyy')#'
		<cfelseif url.dateFieldSign eq 2>
			< '#Dateformat(url.Created_Date,'mm/dd/yyyy')#'
		<cfelse>
			= '#Dateformat(url.Created_Date,'mm/dd/yyyy')#'
		</cfif>
	</cfif>


	SELECT 	  Unique_Key
				, BB_Reference
				, BB_Start_Date
				, BB_End_Date
				, cast('' as varchar(200)) as Payee_ID
				, cast('' as varchar(200)) as Payee_Name
				, Customer_Invoice_Approved_Amount = sum(BB_Approved_Amount)
				, COUNT(bb_reference) as Total_Claims
				, SUM(Paid_Amount) AS Paid
				, SUM(BB_Expected_Amount) AS Expected
				, SUM(BB_Amount) AS Claimed
				, (SUM(BB_Expected_Amount) - SUM(BB_Amount)) AS Deviated
				,  Upload_ID
	INTO  	##tmp_billback_search_final
	FROM  ##tmp_billback_search_result
	GROUP BY Unique_Key, BB_Reference, BB_Start_Date, BB_End_Date, Upload_ID

       -- Get vendor per invoice
      UPDATE      t1
      SET         Payee_ID = isnull(t2.Vendor_ID, vm.Vendor_ID),
                  Payee_Name = isnull(t2.Vendor_Name, vm.vendor_name)
      FROM        ##tmp_billback_search_final t1
      INNER JOIN ##tmp_billback_search_result t2
      ON       t1.Unique_Key = t2.Unique_Key
      LEFT JOIN vendor_master  vm
      ON          vm.vendor_id = t2.uploaded_vendor_id

      -- if vendor not found, pick top 1 payee
      UPDATE      t1
      SET         Payee_ID = t2.Payee_ID,
                  Payee_Name = t2.Payee_Name
      FROM        ##tmp_billback_search_final t1
      INNER JOIN ##tmp_billback_search_result t2
      ON       t1.Unique_Key = t2.Unique_Key
      WHERE       t1.Payee_ID = '' or t1.Payee_ID is null

	declare @recordcount int
	SELECT @recordcount = COUNT(*) FROM ##tmp_billback_search_final

	SELECT *, @recordcount as record_count
	INTO ####tmp_billback_search_result_#globalTableName#
	FROM ##tmp_billback_search_final
	<cfif len(url.Customer_Name) AND len(url.Customer_Number)>
		WHERE Payee_ID LIKE '%#url.Customer_Number#%'
		AND Payee_Name LIKE '%#url.Customer_Name#%'
	<cfelseif len(url.Customer_Name) AND len(url.Customer_Number) EQ 0>
		WHERE Payee_Name LIKE '%#url.Customer_Name#%'
	<cfelseif len(url.Customer_Name) EQ 0 AND len(url.Customer_Number)>
		WHERE Payee_ID LIKE '%#url.Customer_Number#%'
	</cfif>


	DROP TABLE ##tmp_billback_search_result
	DROP TABLE ##tmp_billacks_cannot_see

</cfif>

<!---D57147 :: New Feature to Search for BB's by Customer Invoice --->
			<cfif var_apply_template_profile_filter>
			IF OBJECT_ID('tempdb..##tmp_billacks_cannot_see') IS NOT NULL
				drop table ##tmp_billacks_cannot_see
			</cfif>
	<!--- 75568 :: Match Central - mass select and create list options START ---->
 			IF OBJECT_ID('tempdb..##TMP_Payable_List') IS NOT NULL
			DROP TABLE ##TMP_Payable_List
	<!--- 75568 :: Match Central - mass select and create list options END ---->
        </cfquery>

<!---D57147 :: New Feature to Search for BB's by Customer Invoice --->
	<cfif arguments.invoiceSearch>
		<cfset var_qBillbackSearchResults = finalBillbacklist(argumentCollection = arguments, donotcallmeagain = 1)>
	</cfif>
<!---D57147 :: New Feature to Search for BB's by Customer Invoice --->

        <cfreturn var_qBillbackSearchResults>
    </cffunction>
    <!--- New METHOD: searchBillbacks() FUNCTIONALITY: I save letter settings to the DB. [end] --->

    <!--- MODEL getter|setter METHODS [begin] --->

    <!--- MODEL getter|setter METHODS [end] --->

    <!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::
    :::::::::::: BillbackSearch Methods in alpha  :::::::::::
    :::: [including BillbackBean's Getters() & Setters()] ::::
    ::::::::::::::::::::::::::::::::::::::::::::::: [end] --->

	<!---- Anand Rao/22-Dec-2011/D29654 Settings for BB Reset/Delete, PRG Unlock/Reactivate  --->
	<cffunction name="BBSearchByBBCode" output="false" returntype="query">
		<cfargument name="searchStringList" type="string" required="true"  />
		<cfargument name="userId" type="string" required="true"  />
		<!--- "1"  is for "Reset" and "2" is for "delete" --->
		<cfargument name="actionType" type="string" required="true"  />

		<cfquery name="qrySearchBBs" datasource="#application.datasource#">
			SELECT 	*
			FROM
						Billback
			WHERE
						<cfset counter = 0>
						(
						<cfloop list="#arguments.searchStringList#" index="i">
							<cfset counter = counter + 1>
							BB_Code Like '%#i#%'
							<cfif counter neq Listlen(arguments.searchStringList)>
							OR
							</cfif>
						</cfloop>
						)
						AND Deleted = 0
						<!--- Dev Note:(66084) - "Auto BB's are not allowed to be reset --->
						<cfif actionType eq 1>
						AND Auto_Billback = 0 /* Dev Note: KAL; Date 11/06/2012; D34888: Exclude Auto Pay Billbacks */
						</cfif>
			ORDER BY 	BB_Code,BB_Title
		</cfquery>
		<cfreturn qrySearchBBs />
	</cffunction>
	<!--- END D29654 --->

	<cffunction name="finalBillbacklist" access="public" output="yes" returntype="query">
		<cfargument name="donotcallmeagain" type="numeric" required="true" default="0"/>
			<cfset globalTableName = replace(request.AccessStructure.User_ID,'-','_','ALL')>

		<cfquery name="checkkSearchResults" datasource="#application.datasource#">
			SELECT [name]
			FROM tempdb.sys.tables
			WHERE [name] = '####tmp_billback_search_result_#globalTableName#'
		</cfquery>
		<cfif checkkSearchResults.recordcount EQ 0 and arguments.donotcallmeagain EQ 0>
			<cfset searchBillbacks(argumentCollection = arguments)>
		</cfif>

        <!--- retrieve timeout setting (in seconds) for bb search --->
        <cfset local.timeout = val(application.util.query.get_Setting("bb_search_timeout", 0))>

        <!--- use timeout attribute to allow CF to terminate excessive long queries --->
		<cfquery name="variables.qBillbackSearchResults" timeout="#local.timeout#" datasource="#application.datasource#">

			IF OBJECT_ID('tempdb..##tmp_billacks_sorted') IS NOT NULL
			DROP TABLE ##tmp_billacks_sorted

			SELECT      RowID=IDENTITY (int, 1, 1), *
			INTO  	##tmp_billacks_sorted
			FROM  ####tmp_billback_search_result_#globalTableName#
			ORDER BY BB_Reference

			SELECT   *
			FROM  ##tmp_billacks_sorted
			WHERE ROWID BETWEEN #arguments.startrow# AND #arguments.endrow#
			ORDER BY
			<cfif structKeyExists(arguments, "iSortCol_0") AND arguments.iSortCol_0 EQ 0>
				BB_Reference #arguments.sSortDir_0#
			<cfelseif structKeyExists(arguments, "iSortCol_0") AND arguments.iSortCol_0 EQ 1>
				BB_Start_Date #arguments.sSortDir_0#
			<cfelseif structKeyExists(arguments, "iSortCol_0") AND arguments.iSortCol_0 EQ 2>
				BB_End_Date #arguments.sSortDir_0#
			<cfelseif structKeyExists(arguments, "iSortCol_0") AND arguments.iSortCol_0 EQ 3>
				Total_Claims #arguments.sSortDir_0#
			<cfelseif structKeyExists(arguments, "iSortCol_0") AND arguments.iSortCol_0 EQ 4>
				Payee_Name #arguments.sSortDir_0#
			<cfelseif structKeyExists(arguments, "iSortCol_0") AND arguments.iSortCol_0 EQ 5>
				Claimed #arguments.sSortDir_0#
			<cfelseif structKeyExists(arguments, "iSortCol_0") AND arguments.iSortCol_0 EQ 6>
				Expected #arguments.sSortDir_0#
			<cfelseif structKeyExists(arguments, "iSortCol_0") AND arguments.iSortCol_0 EQ 7>
				Paid #arguments.sSortDir_0#
			<cfelseif arguments.iSortCol_0 EQ 8>
				Deviated  #arguments.sSortDir_0#
			<cfelse>
					1 asc
			</cfif>
		</cfquery>
		<cfreturn variables.qBillbackSearchResults>
	</cffunction>

</cfcomponent>
