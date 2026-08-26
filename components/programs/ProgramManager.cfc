<cfcomponent hint="Program Manager" extends="components.Base">

	<cfset this.businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />

	<cffunction name="init" output="false" returntype="components.programs.ProgramManager">

		<cfreturn this />

	</cffunction>

	<cffunction name="search2" output="true" returntype="query">
		<cfargument name="search" type="struct" required="false" default="#session.searchArg#" />
		<cfset var appSettings 		= application.oApplicationAppSettingsManager.getApplicationAppSettings()>
		<cfset var forbidType 						= appSettings.getForbidAllowProfilesInTemplates() />
		<cfset var ProgramScoreCard 				= appSettings.getProgramScoreCard() />
		<cfset var getProgramAgreeEscalate 			= appSettings.getProgramAgreeEscalate() />
		<cfset var getTemplateRestrictGroupLevel	= appSettings.getTemplateRestrictGroupLevel()>
		<cfset var getPgmPostApprovalStatus 		= appSettings.getPgmPostApprovalStatus()>
		<cfset var User_Agreed_Programs_ID_List = "">
		<cfset var User_Authority_Sequence_Level_ID = 0>
		<cfset this.search 		= arguments.search>
		<cfset Session.searchArg = arguments.search>

		<!--- set defaults --->
		<cfparam name="this.search.businessSegmentsOn" 		default="0">
		<cfparam name="this.search.scorecardStatus" 		default="0">
		<cfparam name="this.search.Read_Only_Catalog_Access" 	default="0">
		<cfparam name="this.search.title" 					default="">
		<cfparam name="this.search.item_number" 			default="">
		<cfparam name="this.search.UPC" 					default="">
		<cfparam name="this.search.Brand_ID" 				default="0">
		<cfparam name="this.search.Type_Code_Desc_ID" 		default="0">
		<cfparam name="this.search.description" 			default="">
		<cfparam name="this.search.PP_User_ID" 				default="">
		<cfparam name="this.search.See_Awarded_In_Catalog" 	default=0>
		<!--- set defaults --->

		<!---AppSettings--->

		<cfparam name="this.search.RFA_Agreed" 	default="0">

		<cfif isDefined("this.search.User_ID")>
			<cfset User_Agreed_Programs_ID_List = this.getUserAgreedProgramsIdList(this.search.User_ID, 2) />
			<cfset User_Authority_Sequence_Level_ID = this.getUserAuthoritySequenceId(this.search.User_ID) />
		</cfif>

		<CFSTOREDPROC PROCEDURE="test_scorecard_programs" datasource="#application.datasource#">
			<CFPROCPARAM TYPE="In"	CFSQLTYPE="cf_sql_varchar" 	VARIABLE="Positions_ID"				VALUE="#PreserveSingleQuotes(this.search.User_Positions_ID)#" NULL="No"><!---PreserveSingleQuotes()--->
			<CFPROCPARAM TYPE="In"	CFSQLTYPE="cf_sql_integer" 	VARIABLE="Profile_id"				VALUE="#this.search.Profiles_ID#" 	NULL="No">
			<CFPROCPARAM TYPE="In"	CFSQLTYPE="cf_sql_integer" 	VARIABLE="ScoreCardStatus"			VALUE="#this.search.ScoreCardStatus#" NULL="No">
			<CFPROCPARAM TYPE="In"	CFSQLTYPE="cf_sql_varchar" 	VARIABLE="SQL_Sort_By"				VALUE="#this.search.SQL_Sort_By#"	NULL="No">
			<CFPROCPARAM TYPE="In"	CFSQLTYPE="cf_sql_varchar" 	VARIABLE="SortOrder"				VALUE="#this.search.SortOrder#" 	NULL="No">
			<CFPROCPARAM TYPE="In"	CFSQLTYPE="cf_sql_integer" 	VARIABLE="rStart"					VALUE="#this.search.rStart#" 		NULL="No">
			<CFPROCPARAM TYPE="In"	CFSQLTYPE="cf_sql_integer"	VARIABLE="maxRow" 					VALUE="#this.search.maxRow#" 		NULL="No">
			<CFPROCPARAM TYPE="In"	CFSQLTYPE="cf_sql_bit"		VARIABLE="businessSegmentsOn"		VALUE="#this.search.businessSegmentsOn#" NULL="No">
			<CFPROCPARAM TYPE="In"	CFSQLTYPE="cf_sql_integer"	VARIABLE="RFA_Agreed"				VALUE="#this.search.RFA_Agreed#" 	NULL="No">
			<CFPROCPARAM TYPE="In"	CFSQLTYPE="cf_sql_integer"	VARIABLE="forbidType"				VALUE="#forbidType#" 				NULL="No">
			<CFPROCPARAM TYPE="In"	CFSQLTYPE="cf_sql_varchar"	VARIABLE="User_Agreed_Programs_ID_List"	VALUE="#User_Agreed_Programs_ID_List#" NULL="No">
			<CFPROCPARAM TYPE="In"	CFSQLTYPE="cf_sql_integer"	VARIABLE="User_Authority_Sequence_Level_ID"	VALUE="#User_Authority_Sequence_Level_ID#" NULL="No">
			<CFPROCPARAM TYPE="In"	CFSQLTYPE="cf_sql_integer"	VARIABLE="ProgramScoreCard"			VALUE="#ProgramScoreCard#" NULL="No">

			<CFPROCPARAM TYPE="In"	CFSQLTYPE="cf_sql_varchar"	VARIABLE="Business_Segment_ID_List"	VALUE="#this.search.Business_Segment_ID_List#" 	NULL="No">
			<CFPROCPARAM TYPE="In"	CFSQLTYPE="cf_sql_integer"	VARIABLE="readOnlyCatalogSearch"	VALUE="#this.search.readOnlyCatalogSearch#" 	NULL="No">
			<CFPROCPARAM TYPE="In"	CFSQLTYPE="cf_sql_integer"	VARIABLE="Read_Only_Catalog_Access"	VALUE="#this.search.Read_Only_Catalog_Access#" 	NULL="No">
			<CFPROCPARAM TYPE="In"	CFSQLTYPE="cf_sql_bit"		VARIABLE="getClassCodesOn"			VALUE="#this.businessSegManager.getClassCodesOn()#" NULL="No">
			<CFPROCPARAM TYPE="In"	CFSQLTYPE="cf_sql_varchar"	VARIABLE="UserClassCodeList"		VALUE="#this.search.UserClassCodeList#" 	NULL="No">
			<CFPROCPARAM TYPE="In"	CFSQLTYPE="cf_sql_integer"		VARIABLE="getTemplateRestrictGroupLevel" VALUE="#getTemplateRestrictGroupLevel#" NULL="No">
			<CFPROCPARAM TYPE="In"	CFSQLTYPE="cf_sql_varchar"	VARIABLE="UserClassCodeUUIDList"	VALUE="#this.search.UserClassCodeUUIDList#" NULL="No">
			<CFPROCPARAM TYPE="In"	CFSQLTYPE="cf_sql_bit"		VARIABLE="Program_Scorecard_Restrict_Created_By" VALUE="#this.search.Program_Scorecard_Restrict_Created_By#" NULL="No">

			<CFPROCPARAM TYPE="In"	CFSQLTYPE="cf_sql_bit"		VARIABLE="getPgmPostApprovalStatus"	VALUE="#getPgmPostApprovalStatus#" 			NULL="No">
			<CFPROCPARAM TYPE="In"	CFSQLTYPE="cf_sql_integer"	VARIABLE="postApprovalStatusId"		VALUE="#this.search.postApprovalStatusId#"	NULL="No">
			<CFPROCPARAM TYPE="In"	CFSQLTYPE="cf_sql_integer"	VARIABLE="agreeStatusId"			VALUE="#this.search.agreeStatusId#"			NULL="No">
			<CFPROCPARAM TYPE="In"	CFSQLTYPE="cf_sql_bit"		VARIABLE="getProgramAgreeEscalate"	VALUE="#getProgramAgreeEscalate#" 			NULL="No">
			<CFPROCPARAM TYPE="In"	CFSQLTYPE="cf_sql_integer"	VARIABLE="FakeStatusIdForProgramPostApprovalStatus"	VALUE="#this.search.FakeStatusIdForProgramPostApprovalStatus#" NULL="No">
			<!---search filters--->
			<CFPROCPARAM TYPE="In"	CFSQLTYPE="cf_sql_varchar"	VARIABLE="title"					VALUE="#this.search.title#" 	NULL="No">

			<!---     <CFPROCPARAM TYPE="In"	CFSQLTYPE="cf_sql_integer"	VARIABLE=""		VALUE="##" NULL="No">   --->
			<cfprocparam type="out"	CFSQLTYPE="cf_sql_integer"	VARIABLE="qCount">
			<cfprocresult name="qGetPrograms" resultset="1">
		</CFSTOREDPROC>

		<cfreturn qGetPrograms />
	</cffunction><!---search2 end--->

	<cffunction name="search" output="true" returntype="query">

		<cfargument name="search" type="struct" required="false" default="#StructNew()#" />

		<cfset this.search = arguments.search>

		<!--- set defaults --->
		<!--- dinesh for Label D26891  --->
		<cfparam name="this.search.from_position" 		default="">
		<cfparam name="this.search.Include_work_in_progress_below_me" 		default="0">
		<!--- dinesh for Label D26891  --->
		<cfparam name="this.search.businessSegmentsOn" 		default="0">
		<cfparam name="this.search.scorecardStatus" 		default="0">
		<cfparam name="this.search.Read_Only_Catalog_Access" 	default="0">
		<cfparam name="this.search.title" 					default="">
		<cfparam name="this.search.item_number" 			default="">
		<cfparam name="this.search.UPC" 					default="">
		<cfparam name="this.search.Brand_ID" 				default="0">
		<cfparam name="this.search.Type_Code_Desc_ID" 		default="0">
		<cfparam name="this.search.description" 			default="">
		<cfparam name="this.search.PP_User_ID" 				default="">
		<cfparam name="this.search.See_Awarded_In_Catalog" 	default=0>
		<cfparam name="this.search.Approve_Freight_Programs" 	default=0>
		<cfparam name="this.search.conditions" 				default="">

		<!--- Get application settings --->
		<!--- <cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
		<cfset appSettings = genSettingsManager.get()> --->
		<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
		<cfset forbidType = appSettings.getForbidAllowProfilesInTemplates() />

		<cfset moreAccessPermissionRestriction = this.getProgramAccessPermissionCode()>

		<cfif NOT isDefined("Get_Profile_Settings")>
			<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
		</cfif>

		<cfparam name="this.search.program_margin_approval_method" 	default="0">
		<cfparam name="this.search.FakeStatusIdForProgramPostApprovalStatus" 	default="0">
		<cfparam name="this.search.User_ID" 	default="">
		<cfparam name="this.search.GL_Account" 	default="">

		<cfset User_Agreed_Programs_ID_List = "">
		<cfset User_Authority_Sequence_Level_ID = 0>
		<cfparam name="this.search.RFA_Agreed" 	default="0">
<!---
	D41184  :: Prod Event 4511
	added because a cf error was popping up looking for  variable "THIS.SEARCH.CONDITIONS"
	problem could not be replicated in development and testing
 --->
		<cfparam name="this.search.conditions" 	default="0">
<!--- D41184  :: prod event 4511 END--->
		<cfset Current_User_Is_Eligible_RSP = 1 />
		<cfif isDefined("this.search.User_ID")>

			<cfset User_Agreed_Programs_ID_List = this.getUserAgreedProgramsIdList(this.search.User_ID, 2) />
			<cfset User_Authority_Sequence_Level_ID = this.getUserAuthoritySequenceId(this.search.User_ID) />

			<cfif appsettings.getDisplayEligibleRSP() EQ 1>
				<cfset UserManager = CreateObject("component", "components.user.UserManager").init() />
				<cfset qUserInfo = UserManager.getUserInfo(this.search.User_ID) />
				<cfset Current_User_Is_Eligible_RSP = qUserInfo.Is_Eligible_RSP />
			</cfif>

		</cfif>

		<CFIF Super.variableExist("this.search.Start_Date", "")>
			<cfset var sStartDate = DateFormat(this.search.start_Date,'mm/dd/yyyy')>
		</CFIF>
		<CFIF Super.variableExist("this.search.end_Date", "")>
			<cfset var sEndDate = DateFormat(this.search.end_Date,'mm/dd/yyyy')>
		</CFIF>

		<cftransaction isolation="READ_UNCOMMITTED"><!---  try to stop deadlocks --->

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
				<cfif Super.variableExist("this.search.Start_Date", "") and Super.variableExist("this.search.end_Date", "")>
					<cfif this.search.start_Date eq "" and this.search.end_Date eq "">
						<cfif IsNumeric(appSettings.getExpiredRecentlyDays())>
							AND  CM.Contract_End_Date >= DateAdd(d,- #appSettings.getExpiredRecentlyDays()#,getDate())
						</cfif>
					<cfelse>
							AND CM.Contract_Start_Date <= '#DateFormat(sEndDate,"mm/dd/yyyy")#'
							AND CM.Contract_End_Date >= '#DateFormat(sStartDate,"mm/dd/yyyy")#'
					</cfif>
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
				<cfif this.search.start_Date eq "" and this.search.end_Date eq "">
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
				<cfif Super.variableExist("this.search.Start_Date", "") and Super.variableExist("this.search.end_Date", "")>
					<cfif this.search.start_Date eq "" and this.search.end_Date eq "">
						<cfif IsNumeric(appSettings.getExpiredRecentlyDays())>
							AND  CM.Contract_End_Date >= DateAdd(d,- #appSettings.getExpiredRecentlyDays()#,getDate())
						</cfif>
					<cfelse>
							AND CM.Contract_Start_Date <= '#DateFormat(sEndDate,"mm/dd/yyyy")#'
							AND CM.Contract_End_Date >= '#DateFormat(sStartDate,"mm/dd/yyyy")#'
					</cfif>
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
				<cfif Super.variableExist("this.search.Start_Date", "") and Super.variableExist("this.search.end_Date", "")>
					<cfif this.search.start_Date eq "" and this.search.end_Date eq "">
						<cfif IsNumeric(appSettings.getExpiredRecentlyDays())>
							AND  CM.Contract_End_Date >= DateAdd(d,- #appSettings.getExpiredRecentlyDays()#,getDate())
						</cfif>
					<cfelse>
							AND CM.Contract_Start_Date <= '#DateFormat(sEndDate,"mm/dd/yyyy")#'
							AND CM.Contract_End_Date >= '#DateFormat(sStartDate,"mm/dd/yyyy")#'
					</cfif>
				</cfif>
			</cfquery>

		<!--- Get Program --->
        <cfquery  datasource="#application.datasource#">
            IF OBJECT_ID('tempdb..##Positions_Below_Me') IS NOT NULL
                DROP TABLE ##Positions_Below_Me
            IF OBJECT_ID('tempdb..##Profile_Forbidden_Template') IS NOT NULL
                DROP TABLE ##Profile_Forbidden_Template
            IF OBJECT_ID('tempdb..##Program_Agree') IS NOT NULL
                DROP TABLE ##Program_Agree
        </cfquery>

		<cfquery name="qGetPrograms" datasource="#application.datasource#">
		CREATE  TABLE ##Positions_Below_Me
			(
			  Below_User_Positions_ID   int          NOT NULL
			)
			CREATE CLUSTERED  INDEX [I_Below_User_Positions_ID_tmp] ON [dbo].[##Positions_Below_Me]([Below_User_Positions_ID]) WITH  FILLFACTOR = 90,  PAD_INDEX  ON [PRIMARY]

            CREATE TABLE ##Profile_Forbidden_Template (
                                                        Template_ID INT NOT NULL
                                                        , Forbid_Access_Type INT NOT NULL
                                                    )

			INSERT INTO ##Positions_Below_Me(Below_User_Positions_ID)
			SELECT	DISTINCT Below_User_Positions_ID
			FROM	Positions_Below_Me
			WHERE	User_Positions_ID IN (#PreserveSingleQuotes(this.search.User_Positions_ID)#)

			INSERT INTO ##Profile_Forbidden_Template (Template_ID, Forbid_Access_Type)
			select 	distinct template_id, Forbid_Access_Type
			from 	Profile_Forbidden_Template
			where 	Deleted = 0
					AND Forbid_Type = #forbidType#
					AND profile_id = #this.search.Profiles_ID#

            CREATE TABLE ##Program_Agree (
                User_Positions_ID INT NOT NULL
                , Program_ID INT NOT NULL
                , Authority_Sequence_ID INT NULL
                )

			INSERT INTO ##Program_Agree(User_Positions_ID, Program_ID, Authority_Sequence_ID)
			SELECT DISTINCT User_Positions_ID, PROGRAMID, Authority_Sequence_ID
			FROM       	Program_Agree
			WHERE      	User_Positions_ID IS NOT NULL
			<cfif this.search.RFA_Agreed EQ 2><!--- check for executive agreement --->
			AND 		Executive_Agreement = 1
			</cfif>
			<!---
			D12155: DRK: Users below will not see program in UR if a user above has agreed.
			DECLARE  @Programs_agreedby_HQpositionsabove table
			(
			  contract_main_id  int    NOT NULL
			)
			INSERT INTO @Programs_agreedby_HQpositionsabove
			(contract_main_id)
			select distinct Program_ID
			from ##Program_Agree pm
			inner join user_positions on
			user_positions.user_positions_id =
			pm.user_positions_id
			left join authority_sequence on
			authority_sequence.authority_sequence_id =
			pm.authority_sequence_id
			where user_positions.Deleted = 0
			AND Service_Market_ID IS NULL
			AND Service_Region_ID IS NULL
			AND Service_Zone_ID IS NULL
			and pm.User_Positions_ID in (#PreserveSingleQuotes(this.search.User_Positions_ID)#)
			<cfif User_Authority_Sequence_Level_ID NEQ 0>
			and authority_sequence.authority_sequence_order <=  #User_Authority_Sequence_Level_ID#
			</cfif>
			--->

			DECLARE  @Approvable_Programs table
			(
			  contract_main_id  int    NOT NULL
			)
			<!----- D12096 : if current user is not an eligible RSP, that user should not see any thing in their pending apporval bucket --->
			<cfif appsettings.getDisplayEligibleRSP() EQ 0 OR Current_User_Is_Eligible_RSP EQ "1">
			INSERT INTO @Approvable_Programs(contract_main_id)
			SELECT DISTINCT Program_Approvable_Profiles.contract_main_id
			FROM   Program_Approvable_Profiles

			WHERE
			Program_Approvable_Profiles.Authority_Sequence_Order = #User_Authority_Sequence_Level_ID#
			AND
			(
				(		Program_Approvable_Profiles.profile_id = #this.search.Profiles_ID#
					and Program_Approvable_Profiles.user_positions_id in (#PreserveSingleQuotes(this.search.User_Positions_ID)#)
				)
				<!---
				D12155: DRK: Users below will not see program in UR if a user above has agreed.
				OR
				(		contract_main_id in (select distinct contract_main_id from @Programs_agreedby_HQpositionsabove)
					<!--- D9958: GV - Check template profile restriction also --->
					and (#this.search.Profiles_ID# in
								(select 	profile_id 	from program_approvable_all_profiles
								where 		contract_main_id = Program_Approvable_Profiles.contract_main_id
								)
						)
				)--->
			)
			</cfif>

			<cfif len(trim(this.search.GL_Account)) GT 0>
			DECLARE @Gl_Account_ID table
			(
			  GL_Account_ID   int          NOT NULL

			)
			INSERT INTO @Gl_Account_ID
			SELECT GL_Account_ID
			FROM GL_Account
			WHERE (GL_Account LIKE '%#this.search.GL_Account#%' OR GL_Account LIKE '%#this.search.GL_Account#%' Or GL_Account_Desc Like '%#this.search.GL_Account#%')
			AND Deleted = 0
			</cfif>

			SELECT	DISTINCT
					Generic_Type,
					discount_identifier.discount_identifier_number,
					Contract_Main.Contract_Main_ID,
					Contract_Number,
					Contract_Title,
					Contract_Start_Date,
					Contract_End_Date,
					Contract_Status_Type_IDX,
					rejected,
					Contract_Is_Locked,
					Units_of_Measure.Unit_Of_Measure_Desc,
					Contract_Quantity,
					Contract_Reference_Number,
					Contract_Locked_By_User_ID,
					Approval_date,
					Broker_Approved_Date,
					Approved,
					programtype_id,
					Revision_of_Contract_Main_ID,
					Is_A_Revision,
					IsRollOver,
					revision_version,
					Is_AutoRenew,
					Auto_Renew,
					modifying_user_id,
					modifying_program,
					Sent_To_External_Client,
					Sending_To_External_Client,
					last_extract_date,
					External_Client_Ack_Date,
					EXTERNAL_CLIENT_CANCEL_ACK_DATE,
					Cancel_Sent_to_Client,
					Error_From_External_Client,
					Unsuccessful_Ack_From_External_Client,
					Unsuccessful_Ack_Reason_From_External_Client,
					Manual_Cancel,
					Cancelled_Date,
					Cancelled.Name_First + ' ' + Cancelled.Name_Last AS Cancelled_Name,
					Responsible_User_ID,
					responsibleSalesPerson.Name_First + ' ' + responsibleSalesPerson.Name_Last SalesPerson_Responsible,
					<cfif this.search.businessSegmentsOn EQ 1>
						Contract_Main.Business_Segment_ID,
					<cfelse>
						0 AS Business_Segment_ID,
					</cfif>
					Units_of_Measure.Unit_Of_Measure_Desc,
					Units_of_Measure.Abbreviation,
					Program_Control_Panel_Options.Created_Type
					,_Users.Name_First
					,_Users.Name_Last
					,
					(
						SELECT 		COUNT(*)
						FROM		Contract_Attachments
						INNER JOIN 	Document_Details ON contract_attachments.Doc_ID = Document_Details.Doc_ID
									AND (	(	Public_View = 1
												AND User_Position_ID IN (#preserveSingleQuotes(this.search.GP_Position_List_From_My_Position_Down_SC)#)
											)
												OR Public_View = 0
										)
						WHERE
									Contract_Attachments.Program_ID = Contract_Main.Contract_Main_ID
									AND
									Contract_Attachments.Deleted = 0
					) AS Contract_Attachments_Count,
					<cfif this.search.businessSegmentsOn EQ 1>
						Business_Segment.Business_Unit_Desc
					<cfelse>
						'' As Business_Unit_Desc
					</cfif>

					<cfif appSettings.getProgramScoreCard() NEQ 0>
					<!--- Get the operator --->
						,Operator_Name
						,CASE WHEN (BSA_Operator.Legacy_ID IS NOT NULL AND Len(RTrim(LTrim(BSA_Operator.Legacy_ID))) != 0)
								THEN CAST(BSA_Operator.Legacy_ID As varchar(50))
							  ELSE
								CAST(BSA_Operator.BSA_Operator_ID As varchar(50))
						 END As OperatorID
					<!--- Get the distributor/distributor buying group --->
						,bfc1.Name
					</cfif>
					,Program_Control_Panel_Options.Catalog_Type,
					<cfif this.search.scorecardStatus NEQ 0>
					<!--- from scorecard --->
						<cfif this.search.Read_Only_Catalog_Access EQ 1 AND this.search.scorecardStatus EQ 9>
							1
						<cfelse>0
						</cfif>
					<cfelse>
						<!--- not from scorecard --->
						<!---
						search.readOnlyCatalogSearch
						0: only program
						1: only catalog
						2: Both
						 --->
						<cfif this.search.Read_Only_Catalog_Access EQ 1 AND this.search.readOnlyCatalogSearch EQ 1>
						1
						<cfelseif this.search.Read_Only_Catalog_Access EQ 1 AND this.search.readOnlyCatalogSearch EQ 2>
						CASE
						WHEN Contract_Main.Contract_Status_Type_IDX < 3 THEN
							0
						WHEN Program_Control_Panel_Options.Include_In_Catalog = 0 THEN
							0
						WHEN (Creating_User_Position_ID IN  (#preserveSingleQuotes(this.search.User_Positions_ID)#)) #PreserveSingleQuotes(moreAccessPermissionRestriction)# THEN
							0
						<CFIF Len(this.search.GP_Position_List_From_My_Position_Down_SC) GT 0>
						WHEN Contract_Status_Type_IDX >= 2 AND Creating_User_Position_ID IN (#preserveSingleQuotes(this.search.GP_Position_List_From_My_Position_Down_SC)#) #PreserveSingleQuotes(moreAccessPermissionRestriction)# THEN
							0
						WHEN Contract_Status_Type_IDX >= 4 AND Contract_Main.Contract_Main_ID IN (#PreserveSingleQuotes(this.search.ProgramsWithDistUnderMe_SC)#) #PreserveSingleQuotes(moreAccessPermissionRestriction)# THEN
							0
						WHEN Contract_Status_Type_IDX >= 4 AND Contract_Main.Contract_Main_ID IN (#PreserveSingleQuotes(this.search.ProgramsWithBrokerUnderMe_SC)#) #PreserveSingleQuotes(moreAccessPermissionRestriction)# THEN
							0
						</CFIF>
						ELSE
							1
						END
						<cfelse>0
						</cfif>
					</cfif>
					AS justACatalog,
					Position_To_Approve.Position_Label Position_To_Approve_Label,
					Contract_Main_Aux_Data.Program_Spend
					<!--- Payment Processor Filter --->
					<cfif application.returned_customer_setting.Accounting_Specialist eq 1>

						,ppUsers.Name_Last

					</cfif>
					<!--- If the appsetting allows for viewing requester/approver position on the scorecard and
						  the program is approved --->
					<cfif appSettings.get_Requester_Approver_Position() AND this.search.scorecardStatus GTE 4>
						,User_Positions.Position_Label Position_Approved_Label
					</cfif>

					<cfif appSettings.getReleaseSettlement()>
					,Released_By
					</cfif>
					<cfif appSettings.get_Setting('Quick_Pay_in_Program_Search') eq '1'>
					,CASE WHEN
						isnull(Claim.Claim_Mechanics,0) > 0
					THEN 1 ELSE 0 END AS Claim_Mechanics
					<cfelse>
					,0 AS Claim_Mechanics
					</cfif>
                    ,Contract_Main_Aux_Data.Payment_History
			FROM	Contract_Main
					LEFT JOIN Contract_Main_Aux_Data
					ON	Contract_Main_Aux_Data.Contract_Main_ID = Contract_Main.Contract_Main_ID
					<!--- If the appsetting allows for viewing requester/approver position on the scorecard and
						  the program is approved --->
					<cfif appSettings.get_Requester_Approver_Position() AND this.search.scorecardStatus GTE 4>
					LEFT JOIN  User_Position_Holders
					ON
						Contract_Main.Approved_By_User_ID = User_Position_Holders.User_ID
						AND User_Position_Type = 'P'
						AND User_Position_Holders.Deleted = 0
					LEFT JOIN User_Positions
					ON
						User_Positions.User_Positions_ID = User_Position_Holders.User_Positions_ID
					AND User_Positions.deleted = 0
					</cfif>
					INNER JOIN			Units_of_Measure
					ON
					Contract_Main.Contract_Quantity_UOM_IDX = Units_of_Measure.Unit_Of_Measure_ID
					INNER JOIN			Program_Control_Panel_Options
					ON
					Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
					LEFT JOIN discount_identifier
					ON
					discount_identifier.discount_identifier_id = program_control_panel_options.discount_identifier_id
					LEFT JOIN			_Users
					ON
					(
					(Contract_Main.Broker_User_ID = _Users.User_ID)
					AND
					((Contract_Main.Broker_User_ID = _Users.User_ID) AND (Contract_Status_Type_IDX = 2))
					OR
					((Contract_Main.Approved_By_User_ID = _Users.User_ID) AND (Contract_Status_Type_IDX >= 4))
					)
					LEFT JOIN 			_Users Cancelled
					ON Cancelled.User_ID = Contract_Main.Cancelled_By
					LEFT JOIN _Users responsibleSalesPerson
					ON 	responsibleSalesPerson.User_ID = Responsible_User_ID
					AND	responsibleSalesPerson.Deleted = 0
					<!--- Business Segment Filter --->
					<cfif this.search.businessSegmentsOn EQ 1>
					LEFT JOIN Business_Segment
					ON
					Business_Segment.Deleted = 0
					AND
					Business_Segment.Business_Segment_ID = Contract_Main.Business_Segment_ID
					</cfif>
					<!--- Payment Processor Filter --->
					<cfif application.returned_customer_setting.Accounting_Specialist eq 1>

						LEFT JOIN Program_Accounting_Specialist ON
						Program_Accounting_Specialist.Program_ID = Contract_Main.Contract_Main_ID
						AND Program_Accounting_Specialist.Deleted = 0
						LEFT JOIN _users ppUsers
						ON ppUsers.User_ID = Program_Accounting_Specialist.User_ID

					</cfif>

					<!--- Operator Name --->
					LEFT JOIN 	Contract_Operators a
					ON 	a.Deleted = 0
					AND a.Contract_Main_ID = Contract_Main.Contract_Main_ID
					AND	BSA_Operator_ID = (	SELECT Top 1 b.BSA_Operator_ID
												FROM 	Contract_Operators b
												WHERE 	b.Deleted = 0
												AND		b.Contract_Main_ID = a.Contract_Main_ID
												)
					LEFT JOIN 	BSA_Operator
					ON
					BSA_Operator.BSA_Operator_ID = a.BSA_Operator_ID
					AND	BSA_Operator.BSA_Operator_ID = a.BSA_Operator_ID

					<!--- For the distributor/distributor buying group --->
					LEFT JOIN 	Contract_Distributors cd1
					ON cd1.Deleted = 0
					AND cd1.Contract_Main_ID = Contract_Main.Contract_Main_ID
					AND	cd1.BSA_Foodservice_Customers_ID = ( SELECT Top 1 cd2.BSA_Foodservice_Customers_ID
												FROM 	Contract_Distributors cd2
												WHERE 	cd2.Deleted = 0
												AND		cd2.Contract_Main_ID = cd1.Contract_Main_ID
												)

					LEFT JOIN 	BSA_Foodservice_Customers	bfc1
					ON
					bfc1.BSA_Foodservice_Customers_ID = cd1.BSA_Foodservice_Customers_ID
					AND	bfc1.BSA_Foodservice_Customers_ID = cd1.BSA_Foodservice_Customers_ID
					<!---//////////////Product Filter///////////////--->
					<cfif 	Len(trim(this.search.item_number))
							OR Len(trim(this.search.UPC))
							OR this.search.Brand_ID neq 0 OR this.search.Type_Code_Desc_ID neq 0
							OR Len(trim(this.search.description))>
						INNER JOIN Contract_Products
						ON	Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
						AND Contract_Products.Deleted = 0
						INNER JOIN BSA_Foodservice_Items_Master
						ON	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
						AND
						(
							<!---we have to do logic for and and or operators. it's not pretty--->
							<cfif Len(trim(this.search.item_number))>
								BSA_Foodservice_Items_Master.Item = '#trim(this.search.item_number)#'
							</cfif>
							<cfif Len(trim(this.search.UPC))>
								<cfif Len(trim(this.search.item_number))>OR</cfif>
								BSA_Foodservice_Items_Master.UPC = '#trim(this.search.UPC)#'
							</cfif>
							<cfif this.search.Brand_ID neq 0>
								<cfif Len(trim(this.search.item_number)) or Len(trim(this.search.UPC))>OR</cfif>
								BSA_Foodservice_Items_Master.Brand_ID = '#this.search.Brand_ID#'
							</cfif>
							<cfif this.search.Type_Code_Desc_ID neq 0>
								<cfif Len(trim(this.search.item_number)) or Len(trim(this.search.UPC)) or this.search.Brand_ID neq 0>OR</cfif>
								BSA_Foodservice_Items_Master.Type_Code_Desc_ID = '#this.search.Type_Code_Desc_ID#'
							</cfif>
							<cfif Len(trim(this.search.description))>
								<cfif Len(trim(this.search.item_number)) or Len(trim(this.search.UPC)) or this.search.Brand_ID neq 0 or this.search.Type_Code_Desc_ID neq 0 >OR</cfif>
								BSA_Foodservice_Items_Master.Description LIKE '%#trim(this.search.description)#%'
							</cfif>
						)
					</cfif>
					<!---handle for lost bid requests--->
					<cfif Super.variableExist("this.search.item_number", "") AND this.search.item_number EQ 8>
						INNER JOIN			Program_Bid_Request
						ON
						Program_Bid_Request.Program_ID = Contract_Main.Contract_Main_ID
						AND	Program_Bid_Request.Bid_Request_Status_ID = 4
						AND	Program_Bid_Request.Deleted = 0
					</cfif>
					LEFT JOIN User_Positions Position_To_Approve
					ON 	Position_To_Approve.User_Positions_ID =
					(
					SELECT	TOP 1 User_positions_ID
					FROM	Program_Approvable_Profiles
					WHERE	Program_Approvable_Profiles.Contract_Main_ID = Contract_Main.Contract_Main_ID
					)
					<!--- DEV NOTE: KAL; D38689: Add Conditions drop down field to Advance Program Search --->
					LEFT JOIN Contract_Attachments
					ON 	Contract_Attachments.Program_ID = Contract_Main.Contract_Main_ID
					AND Contract_Attachments.Deleted = 0

			LEFT JOIN ##tmp_ClaimMechanics Claim
			ON Claim.contract_main_id  = Contract_Main.Contract_Main_ID

			WHERE	Contract_Main.Deleted = 0
					AND (IsExclusionRevision = 0 OR Contract_Status_Type_IDX > 2)
					AND	Contract_Status_Type_IDX >= 0
					AND	Contract_Main.Flagged_As_Purged = 0
					AND
					(
						(Contract_Main.Force_Expiration_Flag = 0)
						OR
						(Contract_Status_Type_IDX = 7)
					)
			<!--- "Claim Rates" or "Pricing" Report --->
			<cfparam name="this.search.Report_Type" default="0">
			<cfif this.search.Report_Type eq 1>
				AND Contract_Main_Aux_Data.Include_Claim_Rates_Report = 1
				AND Contract_Main.Approved = 1
				AND Contract_Main.manual_cancel = 0
			<cfelseif this.search.Report_Type eq 2>
				AND Contract_Main_Aux_Data.Include_Pricing_Report = 1
				AND Contract_Main.Approved = 1
				AND Contract_Main.manual_cancel = 0
			</cfif>

		<!--- dinesh for Label D26891  --->
			<cfif len(this.search.from_position) gt 0>
			   AND Contract_Main.creating_user_position_id= #this.search.from_position#
			</cfif>
		<!--- dinesh for Label D26891  --->

			<!--- Dev Note: CPM 11286 Filter By Date and User Positions/Profiles --->
			<cfif appSettings.getReleaseSettlement()>

				<cfif (isdefined("this.search.RS_Start_Date") and len(this.search.RS_Start_Date_Operator)) OR (isdefined("this.search.RS_End_Date") AND len(this.search.RS_End_Date_Operator))>
					<cfif len(this.search.RS_Start_Date) NEQ 0 AND len(this.search.RS_End_Date) NEQ 0>
						AND (DateDiff(d, '#this.search.RS_Start_Date#', Contract_Main.Released_Date) #this.search.RS_Start_Date_Operator# 0
						AND DateDiff(d, '#this.search.RS_End_Date#', Contract_Main.Released_Date) #this.search.RS_End_Date_Operator# 0)
					<cfelseif len(this.search.RS_Start_Date) NEQ 0>
						AND DateDiff(d, '#this.search.RS_Start_Date#', Contract_Main.Released_Date) #this.search.RS_Start_Date_Operator# 0
					<cfelseif len(this.search.RS_End_Date) NEQ 0>
						AND DateDiff(d, '#this.search.RS_End_Date#', Contract_Main.Released_Date) #this.search.RS_End_Date_Operator# 0
					</cfif>
				</cfif>

				<!--- Handles for when passing user position of AUTO --->
				<cfif isdefined("this.search.rs_user_position_of") AND this.search.rs_user_position_of EQ "AUTO">
						AND Released = 2
				<cfelse>
					<cfif isdefined("this.search.rs_user_position_of") AND len(this.search.rs_user_position_of) NEQ 0>
						AND Released_By IN (select distinct user_id from user_position_holders where user_positions_id = '#this.search.rs_user_position_of#')
					</cfif>
					<cfif isdefined("this.search.rs_user_position") AND len(this.search.rs_user_position) NEQ 0>
						AND Released_By IN (select distinct user_id from user_position_holders where user_positions_id = '#this.search.rs_user_position_of#')
					</cfif>
				</cfif>

			</cfif>


					<cfif this.search.scorecardStatus NEQ 0>
						<cfparam name="this.search.RFA_Agreed" 	default="0">
						AND
						<cfif this.search.scorecardStatus EQ 9>
						<!---
						Deepa: If status is 9, that mean show all programs (read only catalog)
						Any user with Read only catalog profile access can see all program (read only)
						--->
						1=1
						<CFELSEIF appSettings.getPgmPostApprovalStatus() EQ 1 AND this.search.scorecardStatus EQ this.search.FakeStatusIdForProgramPostApprovalStatus>
						Program_Post_Approval_Status_ID = #this.search.postApprovalStatusId#
						<!--- Dev Note: Clay 8967   --->
						AND (Contract_Main.Manual_Cancel = 0 OR Contract_Main.Manual_Cancel IS NULL)
						<CFELSE>
						Contract_Status_Type_IDX = #this.search.scorecardStatus#
						</CFIF>
						<cfparam name="this.search.agreeStatusId" 	default="0">
						<!--- Under Review --->
						<CFIF this.search.scorecardStatus EQ 2 AND  ListFindNoCase("1,2", this.search.RFA_Agreed) AND this.search.agreeStatusId EQ 1>
							AND
							(
								<!--- START 3 --->
								(
								<cfif appSettings.getProgramAgreeEscalate()>
									 Contract_Main.Contract_Main_ID not in (select Contract_Main_ID from @Approvable_Programs)
									<cfelse>
									ISNULL(Scorecard_program_agree, 0) = 0
									</cfif>
								)
								<!--- END 3 --->
								<!--- also show in under review tab if this user cannot approce this program --->
								OR
								(
								Contract_Main.ProgramType_ID
								<cfif forbidType EQ 0>not </cfif><!--- forbit type=1, forbid, 0=allow --->
								in
								(select 	Template_ID from 	##Profile_Forbidden_Template WHERE Forbid_Access_Type = 2)
								<cfif appSettings.getShow_Fixed_Freight() eq 1 and this.search.Approve_Freight_Programs eq 1>
								and 	Contract_Main_Aux_Data.Freight_Component_Type = 0
								</cfif>
								)

								<!--- no need to do the GDW4 filter any more because it is already handled in Program_Approvable_Profiles --->
							)
							<!--- I have not agreed to this program --->
							<cfif Len(User_Agreed_Programs_ID_List) GT 0>
							AND Contract_Main.Contract_Main_ID NOT IN (#User_Agreed_Programs_ID_List#)
							</cfif>
						</cfif>
						<!--- Pending Approval --->
						<CFIF this.search.scorecardStatus EQ 2 AND  ListFindNoCase("1,2", this.search.RFA_Agreed) AND this.search.agreeStatusId EQ 2>
							AND
							(
								<cfif appSettings.getProgramAgreeEscalate()>
								<!--- START 4 --->
							 	Contract_Main.Contract_Main_ID in (select Contract_Main_ID from @Approvable_Programs)
								<cfelse>
								ISNULL(Scorecard_program_agree, 0) > 0
								</cfif>
								<!--- also show in pending approval tab if this user cannot approce this program --->
								AND
								(
								Contract_Main.ProgramType_ID
								<cfif forbidType EQ 1>not </cfif><!--- forbid type=1, forbid, 0=allow --->
								in
								(select 	Template_ID from 	##Profile_Forbidden_Template WHERE Forbid_Access_Type = 2)
								<cfif appSettings.getShow_Fixed_Freight() eq 1 and this.search.Approve_Freight_Programs eq 1>
								or 	Contract_Main_Aux_Data.Freight_Component_Type <> 0
								</cfif>
								)

								<!--- no need to do the GDW4 filter any more because it is already handled in Program_Approvable_Profiles --->
							)
							<!--- I have not agreed to this program --->
							<cfif Len(User_Agreed_Programs_ID_List) GT 0>
							AND Contract_Main.Contract_Main_ID NOT IN (#User_Agreed_Programs_ID_List#)
							</cfif>
						</cfif>
						<!--- Agreed --->
						<CFIF this.search.scorecardStatus EQ 2 AND  ListFindNoCase("1,2", this.search.RFA_Agreed) AND this.search.agreeStatusId EQ 3>
							<!--- I have not agreed to this program --->
							<cfif Len(User_Agreed_Programs_ID_List) GT 0>
							AND Contract_Main.Contract_Main_ID IN (#User_Agreed_Programs_ID_List#)
							<cfelse>
							AND 1 = 2
							</cfif>
						</cfif>
					</cfif>
					<cfif this.search.title NEQ "">
						AND Contract_Main.contract_title LIKE '#this.search.title#%'
					</cfif>
					<cfparam name="this.search.readOnlyCatalogSearch" 	default="">
					<!--- Access permissions start --->
					/*----Check Access Permissions*/
					<cfif 	this.search.Read_Only_Catalog_Access EQ 1
							AND (this.search.scorecardStatus EQ 9 OR this.search.readOnlyCatalogSearch EQ 1)>
					<!--- [Deepa] show all catalog the programs
					Any user with Read only catalog profile access can see all catalog programs (read only)
					 --->
					 AND Program_Control_Panel_Options.Include_In_Catalog = 1
					 AND ((Contract_Main.Contract_Status_Type_IDX >= 3 and Contract_Main.Contract_Status_Type_IDX < 7) OR Contract_Main.Contract_Status_Type_IDX = 10 OR (Contract_Main.Contract_Status_Type_IDX = 7 and CONTRACT_END_DATE >= DATEADD(D, -367 , GETDATE())))
					 <Cfif this.search.See_Awarded_In_Catalog IS 1>
					 <!---Restriction -- if profile has seen only awarded and template says that the program should have awarded, the user will not be able to see the program in the catalog unless the program has been awarded--->
					 AND ((Program_Control_Panel_Options.Show_Awarded_In_Catalog = 1 AND Contract_Main.Is_Awarded = 1) OR Program_Control_Panel_Options.Show_Awarded_In_Catalog = 0)
					</CFIF>
					<cfelse>
					AND
					(
						<cfif this.search.Read_Only_Catalog_Access EQ 1 AND this.search.readOnlyCatalogSearch EQ 2>
						(Program_Control_Panel_Options.Include_In_Catalog = 1 AND ((Contract_Main.Contract_Status_Type_IDX >= 3 and Contract_Main.Contract_Status_Type_IDX < 7) OR Contract_Main.Contract_Status_Type_IDX = 10 OR (Contract_Main.Contract_Status_Type_IDX = 7 and CONTRACT_END_DATE >= DATEADD(D, -367 , GETDATE()))))
						OR
						</cfif>
						<cfif Super.variableExist("this.search.programScorecardRestrictCreatedByUserId", "")>
						<cfset qUserNumber = "" />
						<cfif appSettings.getUserNumberRestrict()>
						<cfset qUser = CreateObject("component", "components.user.UserManager").getUser(this.search.programScorecardRestrictCreatedByUserId) />
						<cfset qUserNumber = qUser.User_Number />
						</cfif>
						(responsibleSalesPerson.User_ID = '#this.search.programScorecardRestrictCreatedByUserId#'
						<cfif Len(qUserNumber) GT 0>
						OR responsibleSalesPerson.User_Number = '#qUserNumber#'
						</cfif>
						)AND
						</cfif>
						((
						(
							(Creating_User_Position_ID IN  (#PreserveSingleQuotes(this.search.User_Positions_ID)#))
						)
						OR
						(
							(
							(1=2)
							<CFIF Len(this.search.GP_Position_List_From_My_Position_Down_SC) GT 0>
							OR
							Creating_User_Position_ID IN (#preserveSingleQuotes(this.search.GP_Position_List_From_My_Position_Down_SC)#)
							</CFIF>
							)
							<!--- dinesh for Label D26891 added if condition to make sure this filters does not apply when you serach program for reassign --->
							<cfif this.search.Include_work_in_progress_below_me eq 0 AND Get_Profile_Settings.ProgramView_WIPPositionsBelowMe EQ 0>
							AND
							(Contract_Status_Type_IDX >= 2

							OR
							Contract_Main.Is_AutoRenew = 1
							)
							</cfif>
							<!--- dinesh for Label D26891  --->
						)
						<!---D16089<cfif Left(application.returned_customer_setting.Customer_keyword, 1) NEQ "C" AND Left(application.returned_customer_setting.Customer_keyword, 1) NEQ "a">--->
						OR
						(
							(
							(1=2)
							<CFIF len(this.search.GP_Position_List_From_My_Position_Down)GT 0>
							OR
							(Contract_Main.Contract_Main_ID IN
							(#PreserveSingleQuotes(this.search.ProgramsWithDistUnderMe_SC)#)
							)
							</CFIF>
							<CFIF len(this.search.GP_Position_List_From_My_Position_Down)GT 0>
							OR
							(Contract_Main.Contract_Main_ID IN
							(#PreserveSingleQuotes(this.search.ProgramsWithBrokerUnderMe_SC)#)
							)
							</CFIF>
							)
							AND
							(Contract_Status_Type_IDX >= 4)
						)
						<!---</cfif>--->
						)
						<!--- more access permission restriction --->
						#PreserveSingleQuotes(moreAccessPermissionRestriction)#
						)
					)
					</cfif>
					/* ----Check Access Permissions End */
					<!--- Access permissions end --->

					<!--- Search For criteria --->
					<CFIF Super.variableExist("this.search.Business_Segment_ID", "0") AND this.search.Business_Segment_ID NEQ "" AND IsNumeric(this.search.Business_Segment_ID)>
					AND Contract_Main.Business_Segment_ID = #this.search.Business_Segment_ID#
					</CFIF>
					<CFIF Super.variableExist("this.search.Responsible_Sales_Person", "") AND this.search.Responsible_Sales_Person NEQ 0>
					AND Contract_Main.Responsible_User_ID = '#this.search.Responsible_Sales_Person#'
					</CFIF>
					<CFIF Super.variableExist("this.search.Responsible_Sales_Person", "") AND this.search.Responsible_Sales_Person NEQ 0>
					AND Contract_Main.Responsible_User_ID = '#this.search.Responsible_Sales_Person#'
					</CFIF>
					<CFIF Super.variableExist("this.search.Legacy_Deal_ID", "")>
					AND Contract_Main.Legacy_Deal_ID LIKE '%#this.search.Legacy_Deal_ID#%'
					</CFIF>
					<CFIF Super.variableExist("this.search.User_Position_Operator", "") AND Super.variableExist("this.search.User_Position", "")>
					<CFSWITCH EXPRESSION="#this.search.User_Position_Operator#">
							<CFCASE VALUE="Created By">
								AND Creating_User_Position_ID = #this.search.User_Position#
							</CFCASE>
							<CFCASE VALUE="Requesting Approval">
								AND
								EXISTS
								(
									SELECT 	User_Positions_ID
									FROM	User_Position_Holders
									WHERE
											User_Position_Holders.User_ID = Contract_Main.Broker_User_ID
											AND
											User_Position_Holders.Deleted = 0
											AND
											User_Position_Holders.User_Positions_ID = #this.search.User_Position#
								)
							</CFCASE>
							<CFCASE VALUE="Approved By">
								AND
								EXISTS
								(
									SELECT 	User_Positions_ID
									FROM	User_Position_Holders
									WHERE
											User_Position_Holders.User_ID = Contract_Main.Approved_By_User_ID
											AND
											User_Position_Holders.Deleted = 0
											AND
											User_Position_Holders.User_Positions_ID = #this.search.User_Position#
								)
							</CFCASE>
						</CFSWITCH>
					</CFIF>
					<cfparam name="this.search.Status" 	default="-1">
					<CFIF  this.search.Status EQ "-1">
						<!--- all status --->
					<CFELSEIF this.search.Status NEQ "0">
						<!--- particular status --->
						AND Contract_Status_Type_IDX = #this.search.Status#
					<CFELSE>
						<!--- = 0, means all non-expired --->
						AND Contract_Status_Type_IDX <> 7
					</CFIF>
					<CFIF Super.variableExist("this.search.Generic_Type", "0")>
						AND	Program_Control_Panel_Options.Generic_Type = '#this.search.Generic_Type#'
					</CFIF>
					<!--- search based on template type --->
					<CFIF Super.variableExist("this.search.Template_Name", "0")>
						AND	Program_Control_Panel_Options.Created_Type = '#this.search.Template_Name#'
					</CFIF>
					<CFIF Super.variableExist("this.search.Discount_Identifier", "0") AND IsNumeric(this.search.Discount_Identifier)>
						AND	Program_Control_Panel_Options.Discount_Identifier_ID = '#this.search.Discount_Identifier#'
					</CFIF>
					<CFIF 	Super.variableExist("this.search.Start_Date", "")
							AND Super.variableExist("this.search.Start_date_Operator", "")
							AND ISDate(this.search.Start_Date)
							AND (this.search.Start_date_Operator EQ "Greater_Or_Equal"
								OR this.search.Start_date_Operator EQ "Equal"
								OR this.search.Start_date_Operator EQ "Less_Or_Equal"
								)>
						AND DateDiff(d, '#this.search.Start_Date#', Contract_Start_Date)
						<CFSWITCH expression="#this.search.Start_date_Operator#">
							<CFCASE value="Greater_Or_Equal">
							>=
							</CFCASE>
							<CFCASE value="Equal">
							=
							</CFCASE>
							<CFCASE value="Less_Or_Equal">
							<=
							</CFCASE>
						</CFSWITCH>
						0
					</CFIF>
					<CFIF 	Super.variableExist("this.search.End_Date", "")
							AND Super.variableExist("this.search.End_date_Operator", "")
							AND ISDate(this.search.End_Date)
							AND (this.search.End_date_Operator EQ "Greater_Or_Equal"
								OR this.search.End_date_Operator EQ "Equal"
								OR this.search.End_date_Operator EQ "Less_Or_Equal"
								)>
						AND DateDiff(d, '#this.search.End_Date#', Contract_End_Date)
						<CFSWITCH expression="#this.search.End_date_Operator#">
							<CFCASE value="Greater_Or_Equal">
							>=
							</CFCASE>
							<CFCASE value="Equal">
							=
							</CFCASE>
							<CFCASE value="Less_Or_Equal">
							<=
							</CFCASE>
						</CFSWITCH>
						0
					</CFIF>
					<CFIF Super.variableExist("this.search.Program_Title", "") and this.search.Program_Title NEQ "">
						AND (Contract_Main.Contract_Title LIKE '%#this.search.Program_Title#%' OR Contract_Main.Contract_Reference_Number LIKE '%#this.search.Program_Title#%' )
					</CFIF>
					<CFIF Super.variableExist("this.search.Program_Number", "")>
						AND Contract_Main.Contract_Number LIKE '%#this.search.Program_Number#%'
					</CFIF>
					<cfparam name="this.search.Operator_Name" 	default="">
					<CFIF Len(this.search.Operator_Name) GT 0>
						AND
						EXISTS
						(
							SELECT	TOP 1 Contract_Operators.Contract_Main_ID
							FROM	Contract_Operators
									INNER JOIN	BSA_Operator
									ON
									(
										(BSA_Operator.Deleted = 0)
										AND
										(Contract_Operators.BSA_Operator_ID = BSA_Operator.BSA_Operator_ID)
										AND
										(BSA_Operator.Operator_Name Like '%#this.search.Operator_Name#%')
									)
							WHERE
								Contract_Operators.Contract_Main_ID = Contract_Main.Contract_Main_ID
								AND
								Contract_Operators.Deleted = 0
						)
					</CFIF>
					<!--- Dev Note: Milan; 8497.--->
					<cfparam name="this.search.Operator_Number" 	default="">
					<CFIF Len(this.search.Operator_Number) GT 0>

					<!---BJF D9992 -- changed logic so it behaves the same way for number and name --->
					AND
						EXISTS
						(
							SELECT	TOP 1 Contract_Operators.Contract_Main_ID
							FROM	Contract_Operators
									INNER JOIN	BSA_Operator
									ON
									(
										(BSA_Operator.Deleted = 0)
										AND
										(Contract_Operators.BSA_Operator_ID = BSA_Operator.BSA_Operator_ID)
										AND
										(CAST(BSA_Operator.Legacy_ID As varchar(50)) Like '%#this.search.Operator_Number#%' OR CAST(BSA_Operator.BSA_Operator_ID As varchar(50)) Like '%#this.search.Operator_Number#%' )
									)
							WHERE
								Contract_Operators.Contract_Main_ID = Contract_Main.Contract_Main_ID
								AND
								Contract_Operators.Deleted = 0
						)


					<!--- 	CASE WHEN (BSA_Operator.Legacy_ID IS NOT NULL AND Len(RTrim(LTrim(BSA_Operator.Legacy_ID))) != 0)
							THEN
									CAST(BSA_Operator.Legacy_ID As varchar(50))
							ELSE
									CAST(BSA_Operator.BSA_Operator_ID As varchar(50))
							END
										Like '%#this.search.Operator_Number#%'

										(
					 ---> <!---Removed this so now it checks both when you key an entry: BJF D9634  --->
					<!--- (
						CAST(BSA_Operator.Legacy_ID As varchar(50)) Like '%#this.search.Operator_Number#%'	OR

					CAST(BSA_Operator.BSA_Operator_ID As varchar(50)) Like '%#this.search.Operator_Number#%'
					)	 --->
					</CFIF>
					<!--- End Note: Milan; 8497.--->




					<!--- Search on geography --->
					<cfparam name="this.search.Broker_ID" 	default="0">
					<cfparam name="this.search.Service_Zone_ID" 	default="0">
					<cfparam name="this.search.Service_Region_ID" 	default="0">
					<cfparam name="this.search.Service_Market_ID" 	default="0">
					<CFIF this.search.Broker_ID NEQ "0" OR this.search.Service_Zone_ID  NEQ "0" OR this.search.Service_Region_ID  NEQ "0" OR this.search.Service_Market_ID  NEQ "0">
						AND
						EXISTS
						(
							SELECT TOP 1 Contract_Main_ID FROM
							(
							SELECT	TOP 1 Contract_Distributors.Contract_Main_ID
							FROM	BSA_FoodService_Customers
								INNER JOIN Contract_Distributors
								ON
								Contract_Distributors.Deleted = 0
								AND Contract_Distributors.BSA_FoodService_Customers_ID = BSA_FoodService_Customers.BSA_FoodService_Customers_ID
								<cfif appSettings.getDistributorMultiPosition()>
								INNER JOIN Market_Distributor
								ON
								Market_Distributor.Deleted = 0
								AND Market_Distributor.Distributor_ID = BSA_FoodService_Customers.BSA_FoodService_Customers_ID
								INNER JOIN Service_Markets
								ON Service_Markets.Service_Market_ID = Market_Distributor.Service_Market_ID
								</cfif>
								INNER JOIN BSA_Foodservice_Brokers
								ON
								<cfif appSettings.getDistributorMultiPosition()>
								BSA_Foodservice_Brokers.Service_Market_ID = Service_Markets.Service_Market_ID
								<cfelse>
								BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = BSA_FoodService_Customers.BSA_Foodservice_Brokers_ID
								</cfif>
								AND
								BSA_Foodservice_Brokers.Deleted = 0
								<CFIF this.search.Service_Zone_ID  NEQ "0" OR this.search.Service_Region_ID  NEQ "0" OR this.search.Service_Market_ID  NEQ "0">
								<CFIF this.search.Service_Market_ID NEQ "0">
									<cfif appSettings.getDistributorMultiPosition()>
									AND Service_Markets.Service_Market_ID
									<cfelse>
									AND BSA_Foodservice_Brokers.Service_Market_ID
									</cfif> = #this.search.Service_Market_ID#
								</CFIF>
								<CFIF this.search.Service_Region_ID NEQ "0">
									<cfif appSettings.getDistributorMultiPosition()>
									AND Service_Markets.Service_Region_ID
									<cfelse>
									AND BSA_Foodservice_Brokers.Service_Region_ID</cfif> IN (#PreserveSingleQuotes(this.search.Service_Region_ID)#)
								</CFIF>
								<CFIF this.search.Service_Zone_ID NEQ "0">
									INNER JOIN Service_Regions
									ON
									<cfif appSettings.getDistributorMultiPosition()>
									Service_Regions.Service_Region_ID = Service_Markets.Service_Region_ID
									<cfelse>
									Service_Regions.Service_Region_ID = BSA_Foodservice_Brokers.Service_Region_ID
									</cfif>
									AND
									Service_Regions.Deleted = 0
									AND
									Service_Regions.Service_Zone_ID = '#this.search.Service_Zone_ID#'
								</CFIF>
								</CFIF>
							WHERE
								<CFIF this.search.Broker_ID NEQ "0">
								BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID IN (#PreserveSingleQuotes(this.search.Broker_ID)#)
								AND
								</CFIF>
								Contract_Main_ID = Contract_Main.Contract_Main_ID

							) AS DDD
						)
					</CFIF>

					<!--- search on customer/distributor --->
					<cfparam name="this.search.Family_Name" 	default="0">
					<cfparam name="this.search.Buying_Group" 	default="0">
					<cfparam name="this.search.Distributor_Name" 	default="">
					<cfparam name="this.search.Distributor_shipto" 	default="">
					<CFIF (((this.search.Family_Name NEQ "0") OR (this.search.Buying_Group NEQ "0"))) OR (Len(this.search.Distributor_Name) GT 0) OR (Len(this.search.Distributor_shipto) GT 0)>
						AND
						EXISTS
						(
						SELECT	TOP 1 Contract_Distributors.Contract_Main_ID
						FROM
								Contract_Distributors
								---INNER JOIN START
								INNER JOIN
								BSA_FoodService_Customers
								ON
								(BSA_FoodService_Customers.BSA_FoodService_Customers_ID = Contract_Distributors.BSA_FoodService_Customers_ID)
								<CFIF ((this.search.Family_Name NEQ "0") OR (this.search.Buying_Group NEQ "0"))>
								AND
								NOT (BSA_FoodService_Customers.BSA_FoodService_Customers_ID IS NULL)
								</CFIF>
								<CFIF Len(Trim(this.search.Distributor_Name)) GT 0>
								AND
								BSA_FoodService_Customers.Name LIKE '%#this.search.Distributor_Name#%'
								</CFIF>
								<CFIF Len(Trim(this.search.Distributor_shipto)) GT 0>
								AND
								BSA_FoodService_Customers.Shr_Ship_To LIKE '%#this.search.Distributor_shipto#%'
								</CFIF>
							WHERE
								Contract_Distributors.Deleted = 0
								AND
								Contract_Distributors.Contract_Main_ID = Contract_Main.Contract_Main_ID
								<CFIF this.search.Family_Name NEQ "0">
								AND
								EXISTS
								(
									SELECT	TOP 1 Distributor_Family.Family_ID
									FROM	Distributor_Family
									WHERE
										Distributor_Family.family_ID = BSA_FoodService_Customers.family_ID
										AND
										Distributor_Family.Deleted=0
										AND
										Distributor_Family.Family_ID = '#this.search.Family_Name#'
								)
								</CFIF>
								<CFIF this.search.Buying_Group NEQ "0">
								AND
								EXISTS
								(
									SELECT	TOP 1 Distributor_Buying_Groups.Buying_Group_ID
									FROM	Distributor_Buying_Groups
									WHERE
										 Distributor_Buying_Groups.Buying_Group_ID = BSA_FoodService_Customers.Buying_Group_ID
										 AND
										 Distributor_Buying_Groups.Deleted=0
										 AND
										 Distributor_Buying_Groups.Buying_Group_ID = '#this.search.Buying_Group#'
								)
								</CFIF>
						)
					</CFIF>

					<!---filter on payment processor if payment processor id is not empty--->
					<cfif application.returned_customer_setting.Accounting_Specialist eq 1>

						<CFIF  trim(this.search.PP_User_ID) NEQ "">
							AND Program_Accounting_Specialist.User_ID = '#this.search.PP_User_ID#'
						</CFIF>

					</cfif>

					<!--- search for GL --->

					<cfif len(trim(this.search.GL_Account))>
					AND Contract_Main.Contract_Main_ID IN
						(
							SELECT Program_ID
							FROM Program_Fixed_Component
							WHERE GL_Account_ID IN (SELECT GL_Account_ID FROM @GL_Account_ID)
							AND Deleted = 0
							UNION
							SELECT Program_ID
							FROM Program_Rebates_Component
							WHERE GL_Account_ID IN (SELECT GL_Account_ID FROM @GL_Account_ID)
							AND Deleted = 0
							UNION
							SELECT Program_ID
							FROM Program_Lump_Sums
							WHERE GL_Account_ID IN (SELECT GL_Account_ID FROM @GL_Account_ID)
							AND Deleted = 0
							UNION
							SELECT Program_ID
							FROM Program_Growth_Components
							WHERE GL_Account_ID IN (SELECT GL_Account_ID FROM @GL_Account_ID)
							AND Deleted = 0
						)

					</cfif>

					<!--- DEV NOTE: KAL; D38689: Add Conditions drop down field to Advance Program Search --->
					<cfif this.search.conditions neq 0>
						<cfswitch expression="#this.search.conditions#">
							<cfcase value="Auto_Renewed">
								AND Is_AutoRenew = 1
							</cfcase>
							<cfcase value="Cancelled">
								AND Manual_Cancel = 1
							</cfcase>
							<cfcase value="Doc_Attached">
								AND Contract_Attachments.Attachment_ID is not NULL
							</cfcase>
							<cfcase value="Not_Cancelled">
								AND Manual_Cancel = 0
							</cfcase>
							<cfcase value="Revision">
								AND Is_A_Revision = 1
							</cfcase>
						</cfswitch>
					</cfif>

			<cfif Super.variableExist("this.search.sql_Sort_By", "")>
			ORDER BY #TRIM(this.search.sql_Sort_By)#
			</cfif>
			DROP TABLE ##Positions_Below_Me
		</cfquery>
		</cftransaction>

        <cfreturn qGetPrograms />


	</cffunction>

	<cffunction name="getProgramAccessPermissionCode" output="true" returntype="string">


		<cfoutput>
		<cfsavecontent variable="moreAccessPermissionRestriction">
		AND Contract_Main.ProgramType_ID
		<cfif forbidType EQ 1>not </cfif><!--- forbit type=1, forbid, 0=allow --->
		in
		(select 	Template_ID from 	##Profile_Forbidden_Template WHERE Forbid_Access_Type = 1)

		<!--- Business Segment restriction --->
		<cfif this.search.businessSegmentsOn EQ 1>
			<cfparam name="this.search.Business_Segment_ID_List" 	default="">
			<cfif Len(this.search.Business_Segment_ID_List) GT 0>
			AND Contract_Main.Business_Segment_ID IN (#this.search.Business_Segment_ID_List#)
			<cfelse>
			AND 1=2
			</cfif>
			<!--- access permission restriction on class code --->
			<cfif this.businessSegManager.getClassCodesOn()>
				<cfparam name="this.search.UserClassCodeList" 	default="">
				AND
				(
					1=2
					<cfif trim(this.search.UserClassCodeList) neq "">
						OR Exists
						(SELECT User_Class_Code.Class_Code_Id
						FROM	User_Class_Code
						WHERE	User_Class_Code.Deleted = 0
								AND User_Class_Code.User_Id = Contract_Main.Responsible_User_ID
								AND class_code_id in (#this.search.UserClassCodeList#))
					</cfif>
					<!--- OLD :: modified for performance reasons
						<cfloop list="#this.search.UserClassCodeList#" index="thisClassCode">
					OR #thisClassCode# IN
					(SELECT User_Class_Code.Class_Code_Id
					FROM	User_Class_Code
					WHERE	User_Class_Code.Deleted = 0
							AND User_Class_Code.User_Id = Contract_Main.Responsible_User_ID)
					</cfloop> --->
				)
			</cfif>
		</cfif>
		<!--- DEV NOTE: DRK 9674/9742 : if the template - restrict group type is class code alone --->
		<cfif appSettings.getTemplateRestrictGroupLevel() eq 10>
		<cfparam name="this.search.UserClassCodeUUIDList" 	default="">
		<cfset classCodeIDList = this.search.UserClassCodeUUIDList />
		AND	(Program_Control_Panel_Options.Restrict_On_Approval_Group = 0 <!--- either the template should not be restricted at group level  --->
			<cfif classCodeIDList neq ""><!--- if the template is restricted at group level, check to see if the user have atleast one of the selected class code --->
			OR
			Program_Control_Panel_Options.ProgramControl_Panel_Options_ID IN
			(
			SELECT	DISTINCT Program_Type_ID
			FROM	Template_Allow_Approval_Group
			WHERE	Deleted = 0
			AND		Group_ID IN (#ListQualify(classCodeIDList, "'")#))
			</cfif>
			)
		</cfif>

		</cfsavecontent>
		</cfoutput>

		<cfreturn moreAccessPermissionRestriction>

	</cffunction>

	<cffunction name="getProgramScorecardSummary" output="true" returntype="query">

		<cfargument name="search" type="struct" required="false" default="#StructNew()#" />
		<cfargument name="useCache" required="false" type="numeric" default="1">

		<cfset cacheSpan = DateAdd("n",2,Now())  />    <!--- This is a fix for a CF Bug.  Set it to a future date or else it uses cache --->
		<cfif arguments.useCache EQ 1>
			<cfset cacheSpan = createodbcdatetime("#DateFormat(Now(), "mm/dd/yyyy")#") /> <!--- this creates a data with 0 hour,minute, seconds.... midnight so the cache gets used all day --->
		</cfif>
		<cfset this.search = arguments.search>

		<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

		<!--- D8399: Post-Approval Status --->
		<cfif appSettings.getPgmPostApprovalStatus() EQ 1>
			<cfset ProgramPostApprovalStatusManager = CreateObject("component", "components.programs.ProgramPostApprovalStatusManager").init() />
			<cfset arProgramPostApprovalStatusAccessForUserProfile = ProgramPostApprovalStatusManager.getSelectedProfileProgramPostApprovalStatusArray(this.search.Profiles_ID) />
		</cfif>

		<cfset forbidType = appSettings.getForbidAllowProfilesInTemplates() />

		<cfset moreAccessPermissionRestriction = this.getProgramAccessPermissionCode()>
		<cfif NOT isDefined("Get_Profile_Settings")>
			<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
		</cfif>

		<cfparam name="this.search.program_margin_approval_method" 	default="0">
		<cfparam name="this.search.See_Awarded_In_Catalog" 	default=0>
		<cfparam name="this.search.Approve_Freight_Programs" 	default=0>
		<cfparam name="this.search.User_Positions_ID" 	default="">

		<cfset User_Agreed_Programs_ID_List = "">
		<cfset User_Authority_Sequence_Level_ID = 0>

		<cfset Current_User_Is_Eligible_RSP = 1 />
		<cfif isDefined("this.search.User_ID")>

			<cfset User_Agreed_Programs_ID_List = this.getUserAgreedProgramsIdList(this.search.User_ID, 2) />
			<cfset User_Authority_Sequence_Level_ID = this.getUserAuthoritySequenceId(this.search.User_ID) />

			<cfif appsettings.getDisplayEligibleRSP() EQ 1>
				<cfset UserManager = CreateObject("component", "components.user.UserManager").init() />
				<cfset qUserInfo = UserManager.getUserInfo(this.search.User_ID) />
				<cfset Current_User_Is_Eligible_RSP = qUserInfo.Is_Eligible_RSP />
			</cfif>

		</cfif>

		<cfset HQPosition = CreateObject("component", "components.geography.position").getHQPosition() />
		<cfset HQUser = 0>
		<cfif listfind(this.search.User_Positions_ID, HQPosition.User_Positions_ID)>
			<cfset HQUser = 1>
		</cfif>

		<cftransaction isolation="READ_UNCOMMITTED">

        <cfquery datasource="#application.datasource#">
            IF OBJECT_ID('tempdb..##Profile_Forbidden_Template') IS NOT NULL
                DROP TABLE ##Profile_Forbidden_Template
			<!--- Get positions below --->
			IF OBJECT_ID('tempdb..##Positions_Below_Me') IS NOT NULL
			    DROP TABLE ##Positions_Below_Me
			IF OBJECT_ID('tempdb..##Programs_With_Dist_Below_Me') IS NOT NULL
				DROP TABLE ##Programs_With_Dist_Below_Me
        </cfquery>

		<!--- changes made by gayathri to the query to reflect the Request for approval programs that are agreed by others but couldn't approve..this is for mainly lambweston, but still the query results don't change for other customers..please don't get confused. Approved status was used for substatus of RFA (pending approval) since we don't have that feild in the DB--->
		<cfquery name="qGetProgramInfo" datasource="#application.datasource#" cachedafter="#cacheSpan#">
			CREATE TABLE ##Positions_Below_Me
			(
			  Below_User_Positions_ID   int          NOT NULL
			)
			CREATE  CLUSTERED  INDEX [I_Below_User_Positions_ID_tmp] ON [dbo].[##Positions_Below_Me]([Below_User_Positions_ID]) WITH  FILLFACTOR = 90,  PAD_INDEX  ON [PRIMARY]

			INSERT INTO ##Positions_Below_Me(Below_User_Positions_ID)
			SELECT	DISTINCT Below_User_Positions_ID
			FROM	Positions_Below_Me
			WHERE	User_Positions_ID IN (#PreserveSingleQuotes(this.search.User_Positions_ID)#)

			<CFIF appSettings.getDistributorMultiPosition() eq 1 AND NOT HQUser>
				SELECT	DISTINCT CD.Contract_Main_ID
				INTO	##Programs_With_Dist_Below_Me
				FROM	User_Positions
				INNER JOIN Market_Distributor MD
				ON		User_Positions.Service_market_ID = MD.Service_market_ID
				AND		MD.Deleted = 0
				INNER JOIN Contract_Distributors CD
				ON		CD.BSA_Foodservice_Customers_ID = MD.Distributor_ID
				AND		CD.Deleted = 0
				WHERE	User_Positions.Deleted = 0
				AND	EXISTS (SELECT 1 FROM ##Positions_Below_Me p WHERE p.Below_User_Positions_ID = User_Positions.User_Positions_ID)
			</CFIF>

            CREATE TABLE ##Profile_Forbidden_Template (
                                                        Template_ID INT NOT NULL
                                                        , Forbid_Access_Type INT NOT NULL
                                                    )

			INSERT INTO ##Profile_Forbidden_Template (Template_ID, Forbid_Access_Type)
			select 	distinct template_id, Forbid_Access_Type
			from 	Profile_Forbidden_Template
			where 	Deleted = 0
					AND Forbid_Type = #forbidType#
					AND profile_id = #this.search.Profiles_ID#


			DECLARE @Program_Agree table
			(
			  User_Positions_ID   int          NOT NULL,
			  Program_ID int          NOT NULL,
			  Authority_Sequence_ID int NULL
			)
			INSERT INTO @Program_Agree(User_Positions_ID, Program_ID, Authority_Sequence_ID)
			SELECT DISTINCT User_Positions_ID, PROGRAMID, Authority_Sequence_ID
			FROM       	Program_Agree
			WHERE      	User_Positions_ID IS NOT NULL
			<cfif this.search.RFA_Agreed EQ 2><!--- check for executive agreement --->
			AND 		Executive_Agreement = 1
			</cfif>

			<!---
			D12155: DRK: Users below will not see program in UR if a user above has agreed.
			DECLARE  @Programs_agreedby_HQpositionsabove table
			(
			  contract_main_id  int    NOT NULL
			)
			INSERT INTO @Programs_agreedby_HQpositionsabove
			(contract_main_id)
			select distinct Program_ID
			from @Program_Agree pm
			inner join user_positions on
			user_positions.user_positions_id =
			pm.user_positions_id
			left join authority_sequence on
			authority_sequence.authority_sequence_id =
			pm.authority_sequence_id
			where user_positions.Deleted = 0
			AND Service_Market_ID IS NULL
			AND Service_Region_ID IS NULL
			AND Service_Zone_ID IS NULL
			and pm.User_Positions_ID in (#PreserveSingleQuotes(this.search.User_Positions_ID)#)
			<cfif User_Authority_Sequence_Level_ID NEQ 0>
			and authority_sequence.authority_sequence_order <=  #User_Authority_Sequence_Level_ID#
			</cfif>
			--->

			DECLARE  @Approvable_Programs table
			(
			  contract_main_id  int    NOT NULL
			)
			<!----- D12096 : if current user is not an eligible RSP, that user should not see any thing in their pending apporval bucket --->
			<cfif appsettings.getDisplayEligibleRSP() EQ 0 OR Current_User_Is_Eligible_RSP EQ "1">
			INSERT INTO @Approvable_Programs(contract_main_id)
			SELECT DISTINCT Program_Approvable_Profiles.contract_main_id
			FROM   Program_Approvable_Profiles
			WHERE
			Program_Approvable_Profiles.Authority_Sequence_Order = #User_Authority_Sequence_Level_ID#
			AND
			(
				(		Program_Approvable_Profiles.profile_id = #this.search.Profiles_ID#
					and Program_Approvable_Profiles.user_positions_id in (#PreserveSingleQuotes(this.search.User_Positions_ID)#)
				)
				<!---
				D12155: DRK: Users below will not see program in UR if a user above has agreed.
				OR
				(		contract_main_id in (select distinct contract_main_id from @Programs_agreedby_HQpositionsabove)
					<!--- D9958: GV - Check template profile restriction also --->
					and (#this.search.Profiles_ID# in
								(select 	profile_id 	from program_approvable_all_profiles
								where 		contract_main_id = Program_Approvable_Profiles.contract_main_id
								)
						)
				)--->
			)
			</cfif>



			DECLARE @Scorecard_Count table
			(
            Contract_Status_Type_ID   Float,

            Status_Count Int,

            Contract_Status_Type_Desc NVARCHAR(50),

            Program_Agree_Status_ID Int,

			Contract_Status_Order Int
			)
			INSERT INTO @Scorecard_Count (Contract_Status_Type_ID, Status_Count, Contract_Status_Order,Contract_Status_Type_Desc,            Program_Agree_Status_ID)
			SELECT 	Contract_Status_Types.Contract_Status_Type_ID, count(Contract_Main.Contract_Main_ID) AS Status_Count,Contract_Status_Types.Contract_Status_Order,
			<cfif this.search.RFA_Agreed EQ 1 OR this.search.RFA_Agreed EQ 2>
				CASE
				WHEN Contract_Status_Types.Contract_Status_Type_ID = 2 THEN
					Program_Agree_Status.Program_Agree_Status_Desc
				ELSE
				Contract_Status_Types.Contract_Status_Type_Desc
				END Contract_Status_Type_Desc
			<cfelse>
				Contract_Status_Types.Contract_Status_Type_Desc
			</cfif>
				, ISNULL(Program_Agree_Status.Program_Agree_Status_ID, 0) Program_Agree_Status_ID
			FROM 	Contract_Status_Types
					LEFT JOIN Program_Agree_Status
					ON
					1=2
					<cfif this.search.RFA_Agreed EQ 1 OR this.search.RFA_Agreed EQ 2>
					OR
					Contract_Status_Types.Contract_Status_Type_ID = 2
					</cfif>
					LEFT JOIN (	Contract_Main
								INNER JOIN Program_Control_Panel_Options
								ON	Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
								INNER JOIN Contract_Main_Aux_Data
								ON	Contract_Main_Aux_Data.Contract_Main_ID = Contract_Main.Contract_Main_ID
							  )
					ON
					Contract_Status_Types.Contract_Status_Type_ID = Contract_Main.Contract_Status_Type_IDX
					<cfif this.search.RFA_Agreed EQ 1>
					AND
					(
					Contract_Status_Types.Contract_Status_Type_ID <> 2
					OR
					(
						<!--- Under Review START --->
						(
						Program_Agree_Status.Program_Agree_Status_ID = 1
						<!--- I have not agreed to this program --->
						<cfif Len(User_Agreed_Programs_ID_List) GT 0>
						AND Contract_Main.Contract_Main_ID NOT IN (#User_Agreed_Programs_ID_List#)
						</cfif>
						AND (
							<cfif appSettings.getProgramAgreeEscalate()>
							 Contract_Main.Contract_Main_ID not in (select Contract_Main_ID from @Approvable_Programs)
							<cfelse>
							ISNULL(Scorecard_program_agree, 0) = 0
							</cfif>
							OR
							(
								Contract_Status_Types.Contract_Status_Type_ID = 2
								<!--- also show in under Review tab if this user cannot approve this program --->
								AND
								(
								Contract_Main.ProgramType_ID
								<cfif forbidType EQ 0>not </cfif><!--- forbit type=1, forbid, 0=allow --->
								in
								(select 	Template_ID from 	##Profile_Forbidden_Template WHERE Forbid_Access_Type = 2)
								<cfif appSettings.getShow_Fixed_Freight() eq 1 and this.search.Approve_Freight_Programs eq 1>
								and 	Contract_Main_Aux_Data.Freight_Component_Type = 0
								</cfif>
								)
							)
							<!--- no need to do the GDW4 filter any more because it is already handled in Program_Approvable_Profiles --->
							)
						)
						<!--- Under Review END --->
						OR
						<!--- Pending approval START --->
						(
						Program_Agree_Status.Program_Agree_Status_ID = 2
						<!--- I have not agreed to this program --->
						<cfif Len(User_Agreed_Programs_ID_List) GT 0>
						AND Contract_Main.Contract_Main_ID NOT IN (#User_Agreed_Programs_ID_List#)
						</cfif>
						AND
						<cfif appSettings.getProgramAgreeEscalate()>
									 Contract_Main.Contract_Main_ID in (select Contract_Main_ID from @Approvable_Programs)
									<cfelse>
									ISNULL(Scorecard_program_agree, 0) > 0 <!--- D12319 --->
									</cfif>
						<!--- also show in pending approval tab if this user cannot approce this program --->
						AND
						(
						Contract_Main.ProgramType_ID
						<cfif forbidType EQ 1>not </cfif><!--- forbit type=1, forbid, 0=allow --->
						in
						(select 	Template_ID from 	##Profile_Forbidden_Template WHERE Forbid_Access_Type = 2)
						<cfif appSettings.getShow_Fixed_Freight() eq 1 and this.search.Approve_Freight_Programs eq 1>
						or 	Contract_Main_Aux_Data.Freight_Component_Type <> 0
						</cfif>
						)
						<!--- no need to do the GDW4 filter any more because it is already handled in Program_Approvable_Profiles --->
						)
						<!--- Pending approval END --->
						OR
						<!--- Agreed START --->
						(
						Program_Agree_Status.Program_Agree_Status_ID = 3
						AND Contract_Status_Types.Contract_Status_Type_ID = Contract_Main.Contract_Status_Type_IDX
						<!--- I have agreed to this program --->
						<cfif Len(User_Agreed_Programs_ID_List) GT 0>
						AND Contract_Main.Contract_Main_ID IN (#User_Agreed_Programs_ID_List#)
						<cfelse>
						AND 1=2
						</cfif>
						)
						<!--- Agreed END --->

					)
					)
					<cfelseif this.search.RFA_Agreed EQ 2>
					AND
					(
						(Contract_Status_Types.Contract_Status_Type_ID <> 3
						AND Contract_Status_Types.Contract_Status_Type_ID = Contract_Main.Contract_Status_Type_IDX
						AND (ISNULL(Scorecard_exec_agree, 0) = 0 OR Contract_Status_Types.Contract_Status_Type_ID <> 2)
						)

						OR
						(
						Contract_Status_Types.Contract_Status_Type_ID = 3
						AND (Contract_Status_Types.Contract_Status_Type_ID - 1) = Contract_Main.Contract_Status_Type_IDX
						AND ISNULL(Scorecard_exec_agree, 0) > 0
						)
					)
					</cfif>
					AND
					Contract_Main.Deleted = 0
					AND (IsExclusionRevision = 0 OR Contract_Status_Type_IDX > 2)
					AND Contract_Status_Types.Contract_Status_Type_ID <> 7
					<cfif IsNumeric(appSettings.getExpiredRecentlyDays())>
					AND  Contract_Main.Contract_End_Date >= DateAdd(d,- #appSettings.getExpiredRecentlyDays()#,getDate())
					</cfif>
					<cfif this.search.businessSegmentsOn EQ 1>
						<cfif Len(this.search.Business_Segment_ID_List) GT 0>
						AND Contract_Main.Business_Segment_ID IN (#this.search.Business_Segment_ID_List#)
						<cfelse>
						AND 1=2
						</cfif>
					</cfif>
					<cfif Super.variableExist("this.search.programScorecardRestrictCreatedByUserId", "")>
					<cfset qUserNumber = "" />
					<cfif appSettings.getUserNumberRestrict()>
					<cfset qUser = CreateObject("component", "components.user.UserManager").getUser(this.search.programScorecardRestrictCreatedByUserId) />
					<cfset qUserNumber = qUser.User_Number />
					</cfif>
					AND
					(Responsible_User_ID = '#this.search.programScorecardRestrictCreatedByUserId#'
					<cfif Len(qUserNumber) GT 0>
					OR (SELECT  User_Number FROM _Users WHERE User_ID = Responsible_User_ID) = '#qUserNumber#'
					</cfif>
					)
					</cfif>
					AND Contract_Main.Flagged_As_Purged = 0
					AND
					(
						Contract_Main.Force_Expiration_Flag = 0
						OR
						Contract_Status_Types.Contract_Status_Type_ID = 7
					)
					<!--- Access permissions start --->
					/*----Check Access Permissions*/
					AND
					(
						Creating_User_Position_ID IN (#preserveSingleQuotes(this.search.User_Positions_ID)#)

						OR
						(
							Creating_User_Position_ID IN (#preserveSingleQuotes(this.search.GP_Position_List_From_My_Position_Down_SC)#)

							AND
							<cfif Get_Profile_Settings.ProgramView_WIPPositionsBelowMe EQ 0>
							(
							Contract_Main.Contract_Status_Type_IDX > 1
							OR
							Contract_Main.Is_AutoRenew = 1
							)
							<cfelse>
							    1=1
							</cfif>

						)

						<!---D16089<cfif Left(application.returned_customer_setting.Customer_keyword, 1) NEQ "C" AND Left(application.returned_customer_setting.Customer_keyword, 1) NEQ "a">--->
						OR
						(
							Contract_Main.Contract_Status_Type_IDX > 3
							AND
							(
								1=2
								<CFIF appSettings.getDistributorMultiPosition() eq 0>
								<CFIF len(this.search.GP_Position_List_From_My_Position_Down)GT 0>
									OR Contract_Main.Contract_Main_ID IN
									(
									#PreserveSingleQuotes(this.search.ProgramsWithDistUnderMe_SC)#
									)
								</CFIF>
								</CFIF>
								<CFIF len(this.search.GP_Position_List_From_My_Position_Down)GT 0>
									OR Contract_Main.Contract_Main_ID IN
									(
									#PreserveSingleQuotes(this.search.ProgramsWithBrokerUnderMe_SC)#
									)
								</CFIF>
								<!--- D51292 START --->
								<!---Tim Ford - 07/10/2015: WR 51292 - The User Position Tree shows distributors attached but does not save them: Added code below so that record counts match those in program search --->
								<CFIF appSettings.getDistributorMultiPosition() eq 1 AND NOT HQUser>

									OR EXISTS
									(
										SELECT	1
										FROM	##Programs_With_Dist_Below_Me PGM_Dist_Blw
										WHERE	PGM_Dist_Blw.Contract_Main_ID = Contract_Main.Contract_Main_ID
									)
								</CFIF>
								<!--- D51292 END --->
							)
						)
						<!---</cfif>--->
					)
					#PreserveSingleQuotes(moreAccessPermissionRestriction)#
					/*----Check Access Permissions End*/
					<!--- Access permissions end --->
			WHERE
					Contract_Status_Types.Contract_Status_Type_ID <> 3
					AND
					Contract_Status_Types.Contract_Status_Type_ID <> 7

					<cfif getIsBidFeatureOn() eq 0>
					AND Contract_Main.Contract_Status_Type_IDX NOT IN (8,10)
					</cfif>
			AND (
					ISNULL(Contract_Main.Planner_ID, 0) = 0
					OR Program_Control_Panel_Options.Retail_Planner_Program_Specific_Approval = 1
				)

			GROUP BY Contract_Status_Types.Contract_Status_Type_ID, ISNULL(Program_Agree_Status.Program_Agree_Status_ID, 0), Contract_Status_Types.Contract_Status_Order, Contract_Status_Types.Contract_Status_Type_Desc, Program_Agree_Status.Program_Agree_Status_Desc



      		SELECT Contract_Status_Type_ID, Status_Count,Contract_Status_Order, Contract_Status_Type_Desc, Program_Agree_Status_ID
            FROM   @Scorecard_Count
			<cfif this.search.Read_Only_Catalog_Access EQ 1>
			UNION

			SELECT	9 AS Contract_Status_Type_ID, count(Contract_Main.Contract_Main_ID) AS Status_Count, 10 As Contract_Status_Order, 'Catalog' As Contract_Status_Type_Desc,
					0 Program_Agree_Status_ID
			FROM	Contract_Main
					INNER JOIN			Program_Control_Panel_Options
					ON
					Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
					AND Program_Control_Panel_Options.Include_In_Catalog = 1

			WHERE
					Contract_Main.Deleted = 0
					AND Contract_Main.Flagged_As_Purged = 0
					AND ((Contract_Main.Contract_Status_Type_IDX >= 3 and Contract_Main.Contract_Status_Type_IDX < 7) OR Contract_Main.Contract_Status_Type_IDX = 10  OR (Contract_Main.Contract_Status_Type_IDX = 7 and CONTRACT_END_DATE >= DATEADD(D, -367 , GETDATE())))
					<Cfif this.search.See_Awarded_In_Catalog IS 1 AND this.search.Read_Only_Catalog_Access EQ 1>
					 <!---Restriction -- if profile has seen only awarded and template says that the program should have awarded, the user will not be able to see the program in the catalog unless the program has been awarded--->
					 AND ((Program_Control_Panel_Options.Show_Awarded_In_Catalog = 1 AND Contract_Main.Is_Awarded = 1) OR Program_Control_Panel_Options.Show_Awarded_In_Catalog = 0)
					</CFIF>
			AND ISNULL(Contract_Main.Planner_ID, 0) = 0
			</cfif>

			<cfif appSettings.getPgmPostApprovalStatus() EQ 1>
			<cfset  arLen = ArrayLen(arProgramPostApprovalStatusAccessForUserProfile) />
			<cfif arLen GT 0>
			UNION

			SELECT	#ProgramPostApprovalStatusManager.getFakeStatusIdForProgramPostApprovalStatus()# AS Contract_Status_Type_ID, count(Contract_Main.Contract_Main_ID) AS Status_Count,
					10 As Contract_Status_Order,
					Program_Post_Approval_Status.Program_Post_Approval_Status_Desc As Contract_Status_Type_Desc,
					Program_Post_Approval_Status.Program_Post_Approval_Status_ID Program_Agree_Status_ID
			FROM	Program_Post_Approval_Status
					LEFT JOIN			Contract_Main
					ON		Contract_Main.Deleted = 0
					AND		Program_Post_Approval_Status.Program_Post_Approval_Status_ID = Contract_Main.Program_Post_Approval_Status_ID
					AND Contract_Main.Flagged_As_Purged = 0
					AND
					(
						Contract_Main.Force_Expiration_Flag = 0
						OR
						Contract_Main.Contract_Status_Type_IDX = 7
					)
					AND Contract_Main.Contract_Status_Type_IDX >= 3
			WHERE	Program_Post_Approval_Status.Deleted = 0
			<!--- Dev Note: Clay : D8967 Filter Cancelled Programs from Pending ERP Entry/ Research  --->
			AND 	(Contract_Main.Manual_Cancel = 0 OR Contract_Main.Manual_Cancel IS NULL)
			<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getPgmPostApprovalStatusType() EQ 1><!--- Dev Note: DRK : 6122 ignore id=2 if appsettings value=1 --->
			AND		Program_Post_Approval_Status.Program_Post_Approval_Status_ID <> 2
			</cfif>
			AND ISNULL(Contract_Main.Planner_ID, 0) = 0
			GROUP BY Program_Post_Approval_Status.Program_Post_Approval_Status_ID, Program_Post_Approval_Status.Program_Post_Approval_Status_Desc
			</cfif>
			</cfif>

			Order By Contract_Status_Order,Contract_Status_Type_ID, Program_Agree_Status_ID
			DROP TABLE ##Positions_Below_Me
		</cfquery>
		</cftransaction>
		<cfreturn qGetProgramInfo>

	</cffunction>

	<cffunction name="getProgramInfo" output="true" returntype="query">

		<cfargument name="programId" required="true" type="numeric" />

		<cfquery name="qGetProgramInfo" datasource="#application.datasource#">
			SELECT	Contract_Main.ProgramType_ID
						,Contract_Main.Line_Of_Business_Id
						,Program_Control_Panel_Options.Restrict_On_Approval_Group
						,Contract_Main.Responsible_User_ID
			FROM	Contract_Main
					INNER JOIN Program_Control_Panel_Options
			ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
			WHERE	Contract_Main.Contract_Main_ID = #arguments.programId#
		</cfquery>

		<cfreturn qGetProgramInfo>

	</cffunction>

	<cffunction name="getProgramTemplateInfo" output="true" returntype="query">

		<cfargument name="programId" required="true" type="numeric" />

		<cfquery name="qGetProgramTemplateInfo" datasource="#application.datasource#">
			SELECT 	Program_Control_Panel_Options.*
			FROM 	Program_Control_Panel_Options
			INNER JOIN Contract_Main
			ON 		Contract_Main.ProgramType_ID =Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
			WHERE 	Contract_Main_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

		<cfreturn qGetProgramTemplateInfo />

	</cffunction>

	<cffunction name="setUserAgree" output="true">

		<cfargument name="programId" required="true" type="numeric" />
		<cfargument name="userId" required="true" type="string" />
		<cfargument name="userProfileId" required="true" type="numeric" />
		<cfargument name="below_program_margin" required="false" type="boolean" default="0" />
		<cfargument name="program_margin_value" required="false" type="string" default = "0" />
		<cfargument name="approvable_program_margin_value" required="false" type="string" default = "0" />
		<!--- Get user profile settings --->
		<cfset user_executive_agreement = 0>
		<cfset qGetProfileSettings = CreateObject("component","components.user.Profile").getProfileSettings(arguments.userProfileId)>
		<cfif qGetProfileSettings.executive_agreement EQ 1>
			<cfset user_executive_agreement = 1>
		</cfif>

		<!--- Insert into Agree Table --->
		<cfquery name="insertprogramuseragreed" datasource="#application.datasource#">
			INSERT INTO Program_Agree
					(User_Id, ProgramId, User_Agree, Agree_DateTime, Executive_Agreement, User_Positions_ID, Authority_Sequence_ID,below_program_margin,program_margin_value,approvable_program_margin_value)
			SELECT	_Users.User_ID, Contract_Main.Contract_Main_ID, 1, GetDate(), #user_executive_agreement#,
					User_User_Positions.User_Positions_ID, _Users.Authority_Sequence_ID
					,#arguments.below_program_margin#,#arguments.program_margin_value#,
					'#arguments.approvable_program_margin_value#'
			FROM	Contract_Main
					INNER JOIN User_Positions
					ON 		User_Positions.User_Positions_ID = Creating_User_Position_ID
					INNER JOIN _Users
					ON 		_Users.User_ID = '#arguments.userId#'
					INNER JOIN User_Position_Holders
					ON 		User_Position_Holders.Deleted = 0
					AND 		User_Position_Holders.User_ID = _Users.User_ID
					INNER JOIN User_Positions User_User_Positions
					ON 		User_User_Positions.Deleted = 0
					AND 	User_User_Positions.User_Positions_ID = User_Position_Holders.User_Positions_ID
					AND 	(User_User_Positions.Service_Zone_ID = User_Positions.Service_Zone_ID OR User_User_Positions.Service_Zone_ID IS NULL)
					AND 	(User_User_Positions.Service_Region_ID = User_Positions.Service_Region_ID OR User_User_Positions.Service_Region_ID IS NULL)
					AND 	(User_User_Positions.Service_Market_ID = User_Positions.Service_Market_ID OR User_User_Positions.Service_Market_ID IS NULL)
			WHERE	Contract_Main.Contract_Main_ID = #arguments.programId#

			INSERT INTO Program_Agree_All_Group
				(User_Id, ProgramId, User_Agree, Agree_DateTime, Executive_Agreement, User_Positions_ID, Authority_Sequence_ID,below_program_margin,program_margin_value,approvable_program_margin_value)
			Select
					User_Id, ProgramId, User_Agree, Agree_DateTime, Executive_Agreement, User_Positions_ID, Authority_Sequence_ID,below_program_margin,program_margin_value,approvable_program_margin_value
			from	program_agree
			where	programid = #arguments.programId#
		</cfquery>

		<cfquery name="updateUsersagreedcount" datasource="#application.datasource#">
			UPDATE 	contract_main
			SET 	Scorecard_program_agree =  ISNULL(Scorecard_program_agree, 0) + 1
					<cfif user_executive_agreement EQ 1>
					, Scorecard_Exec_agree = ISNULL(Scorecard_Exec_agree, 0) + 1
					</cfif>
			WHERE 	contract_main_id = #arguments.programId#
		</cfquery>


	</cffunction>


	<cffunction name="setSentEmailtoNextCRA" output="false" returntype="void">

		<cfargument name="programId" required="true" type="numeric" />
		<cfargument name="userId" required="true" type="string" />

		<cfset returnValue = 1>

		<cfquery name="qGetEmailSentForAnyPosition" datasource="#application.datasource#">
			INSERT INTO Program_Agree_Email_Log
					(Program_ID, User_Positions_ID, Authority_Sequence_ID, Email_Sent)
			SELECT	Contract_Main.Contract_Main_ID, User_User_Positions.User_Positions_ID, _Users.Authority_Sequence_ID, 1
			FROM	Contract_Main
					INNER JOIN User_Positions
					ON 		User_Positions.User_Positions_ID = Creating_User_Position_ID
					INNER JOIN _Users
					ON 		_Users.User_ID = '#arguments.userId#'
					INNER JOIN User_Position_Holders
					ON 		User_Position_Holders.Deleted = 0
					AND 		User_Position_Holders.User_ID = _Users.User_ID
					INNER JOIN User_Positions User_User_Positions
					ON 		User_User_Positions.Deleted = 0
					AND 	User_User_Positions.User_Positions_ID = User_Position_Holders.User_Positions_ID
					AND 	(User_User_Positions.Service_Zone_ID = User_Positions.Service_Zone_ID OR User_User_Positions.Service_Zone_ID IS NULL)
					AND 	(User_User_Positions.Service_Region_ID = User_Positions.Service_Region_ID OR User_User_Positions.Service_Region_ID IS NULL)
					AND 	(User_User_Positions.Service_Market_ID = User_Positions.Service_Market_ID OR User_User_Positions.Service_Market_ID IS NULL)
			WHERE	Contract_Main.Contract_Main_ID = #arguments.programId#
		</cfquery>

	</cffunction>

	<cffunction name="sendEmailtoNextCRA" output="false" returntype="boolean">

		<cfargument name="programId" required="true" type="numeric" />
		<cfargument name="userId" required="true" type="string" />

		<cfset returnValue = 1>

		<cfquery name="qGetEmailSentForAnyPosition" datasource="#application.datasource#">
			SELECT	TOP 1 Program_Agree_Email_Log.User_Positions_ID
			FROM	_Users
					INNER JOIN User_Position_Holders
					ON 		User_Position_Holders.Deleted = 0
					AND 	User_Position_Holders.User_ID = _Users.User_ID
					INNER JOIN Program_Agree_Email_Log
					ON	Program_Agree_Email_Log.Deleted = 0
					AND	Program_Agree_Email_Log.Email_Sent = 1
					AND	Program_Agree_Email_Log.Program_ID = #arguments.programId#
					AND	Program_Agree_Email_Log.User_Positions_ID = User_Position_Holders.User_Positions_ID
					AND	(ISNULL(_Users.Authority_Sequence_ID, 0) = 0 OR Program_Agree_Email_Log.Authority_Sequence_ID = _Users.Authority_Sequence_ID)
			WHERE	_Users.User_ID = '#arguments.userId#'
		</cfquery>
		<cfif qGetEmailSentForAnyPosition.recordCount>
			<cfset returnValue = 0>
		</cfif>

		<cfreturn returnValue />

	</cffunction>


	<cffunction name="getUserAgreedProgramsIdList" output="true" returntype="string">

		<cfargument name="userId" required="true" type="string" />
		<cfargument name="statusId" required="false" type="numeric" default="0" />

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
			SELECT	DISTINCT Program_Agree.ProgramId
			FROM	Program_Agree_All_Group Program_Agree
					<cfif arguments.statusId NEQ 0>
					INNER JOIN Contract_Main
					ON Contract_Main.Contract_Main_ID = Program_Agree.ProgramId
					AND Contract_Main.Contract_Status_Type_IDX = #arguments.statusId#
					</cfif>
			WHERE	<cfif Len(arguments.userId) GT 0>
					Program_Agree.User_ID IN (#preservesinglequotes(UsersToEvaluate)#)
					<cfelse>
					1=2
					</cfif>
		 </cfquery>


		<cfreturn ValueList(qGetUserAgreedPrograms.ProgramId) />

	</cffunction>

	<cffunction name="getUserAuthoritySequenceId" output="false" returntype="numeric">

		<cfargument name="userId" required="true" type="string" />

		<cfset returnValue = 0 />

		<cfset qUser = CreateObject("component", "components.user.UserManager").getUser(arguments.userId) />

		<cfif qUser.recordCount>

			<cfif isNumeric(qUser.Authority_Sequence_ID)>

				<cfset qGetAuthoritySequenceLevel = CreateObject("component", "components.user.AuthoritySequenceManager").getAuthoritySequenceLevel(qUser.Authority_Sequence_ID) />

				<cfif qGetAuthoritySequenceLevel.recordCount>
					<cfset returnValue = qGetAuthoritySequenceLevel.Authority_Sequence_Order />
				</cfif>

			</cfif>

		</cfif>

		<cfif NOT isNumeric(returnValue)>
			<cfset returnValue = 0>
		</cfif>

		<cfreturn returnValue />

	</cffunction>

	<cffunction name="getApprovableUsers" output="true" returntype="query">

		<cfargument name="programId" type="numeric" required="true" />
		<cfargument name="businessSegmentsOn" type="numeric" required="false" default="0" />
		<cfargument name="responsibleUserId" type="string" required="false" default="" />
		<cfargument name="checkMassApprove" type="numeric" required="false" default="0" />
		<cfargument name="checkRFANotificationEmail" type="numeric" required="false" default="0" />
		<cfargument name="checkRemoteApprovalOption" type="numeric" required="false" default="0" />
		<cfargument name="userID" type="string" required="false" default="" />
		<cfargument name="userPositionsID" type="numeric" required="false" default="0" />
		<cfargument name="HQSendEmailToRSPOnly" type="numeric" required="false" default="0" />
		<cfargument name="plannerId" type="numeric" required="false" default="0" />
		<cfargument name="PlannerListTmpTable" type="string" required="false" default="" />

		<!---
		Different conditions to check for
			- User not in forbid list or user in allow list
			- user not in agreed list
			- Check Business Segment/Class Code restriction if applicable
			- GDW4 Approval if the users approval is base don layered or disposal
		 --->

		<!--- D31726:CRA/NRA accounts for user segments START --->
		<!--- from flex is it possible we are not passing this argument --->
		<cfif arguments.businessSegmentsOn eq 0>
			<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
			<cfset arguments.businessSegmentsOn = businessSegManager.isEnabled()/>
		</cfif>
		<!--- D31726:CRA/NRA accounts for user segments END --->

		<!--- Get application settings --->
		<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
		<cfset appSettings = genSettingsManager.get()>

		<cfset approvalGroupManager = CreateObject("component", "components.settings.ApprovalGroupManager").init() />
		<cfset approvalGroupType = approvalGroupManager.getGroupTypeInfo() />

		<cfset forbidType = appSettings.getForbidAllowProfilesInTemplates() />

        <cfquery name="temp_Table_Drop" datasource="#application.datasource#">
                if object_id('tempdb..##Tmp_Program_CRA_List') is not null
                drop table ##Tmp_Program_CRA_List
        </cfquery>
		<!--- Get Program --->
		<cfquery name="qGetApprovalbleUsers" datasource="#application.datasource#">

			SELECT	DISTINCT
					<!--- Dev Note:50324. Modified datatype to varchar for flex program search. --->
					CAST(Contract_Main.Contract_Main_ID As varchar(10)) As Contract_Main_ID,
					Contract_Main.Contract_Number,
					Contract_Main.Contract_Title,
					Contract_Main.Broker_User_ID,
					Contract_Main.Broker_Approved_Date,
					Contract_Main.Contract_Start_Date,
					Contract_Main.Contract_End_Date,
					Contract_Main.ProgramType_ID,
					Contract_Main.Notes,
					Position_To_Approve.User_Positions_ID,
					Approve_Authority_Sequence.Authority_Sequence_Order,
					Approve_Authority_Sequence.Authority_Sequence_ID,
					Approve_Authority_Sequence.Authority_Sequence_Name,
					_Users.User_ID,
					_Users.Name_First + ' ' + _Users.Name_Last User_Full_Name,
					_Users.User_Code,
					ltrim(rtrim(_Users.User_Email)) User_Email,
					_Users.RFA_Notification_Email,
					_Users.Remote_Approval_Option,
					Profiles.Profiles_Desc,
					Position_To_Approve.Position_Label,
					Contract_Main_Aux_Data.Program_spend,
					Position_To_Approve.Service_Zone_ID,
					Position_To_Approve.Service_Region_ID,
					Position_To_Approve.Service_Market_ID,
					ISNULL(Planners.Parent_Planner_ID, Contract_Main.Planner_ID) as Planner_ID,
                    Program_Control_Panel_Options.Created_Type
            INTO    ##Tmp_Program_CRA_List
            FROM	Contract_Main
					LEFT JOIN Planners
					ON  Planners.Planner_ID = Contract_Main.Planner_ID
					INNER JOIN Contract_Main_Aux_Data
					ON	Contract_Main_Aux_Data.Contract_Main_ID = Contract_Main.Contract_Main_ID
					INNER JOIN Program_Control_Panel_Options
					ON	Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
					INNER JOIN Program_Approvable_Profiles
					ON	Program_Approvable_Profiles.Contract_Main_ID = Contract_Main.Contract_Main_ID
					INNER JOIN User_Positions Position_To_Approve
					ON 	Position_To_Approve.User_Positions_ID = Program_Approvable_Profiles.User_positions_ID
					INNER JOIN User_Position_Holders
					ON 	User_Position_Holders.Deleted = 0
					AND	User_Position_Holders.User_Positions_ID = Position_To_Approve.User_Positions_ID
					INNER JOIN _Users
					ON	_Users.Deleted = 0
					AND	_Users.User_ID = User_Position_Holders.User_ID
					AND	_Users.Profiles_ID = Program_Approvable_Profiles.profile_id
					<cfif arguments.userID neq "">
					AND	_Users.User_ID = '#arguments.userID#'
					</cfif>
                    <cfif isNumeric(arguments.userPositionsID)>
                        <cfif arguments.userPositionsID neq 0>
					        AND	Position_To_Approve.User_Positions_ID = '#arguments.userPositionsID#'
                        </cfif>
                    <cfelseif isSimpleValue(arguments.userPositionsID)>
                        <cfif arguments.userPositionsID neq '0'>
					        AND	Position_To_Approve.User_Positions_ID IN ( <cfqueryparam list="true" value='#arguments.userPositionsID#'> )
                        </cfif>
					</cfif>
					<cfif appsettings.getDisplayEligibleRSP() EQ 1>
					AND	_Users.Is_Eligible_RSP = 1 <!--- D12096: Filter CRA list to only show eligible RSP's --->
					</cfif>
					<!--- Dev Note: KAL; 7/2/2010; D23915: Single Instance Remote Approval --->
					<cfif arguments.checkRFANotificationEmail>
					AND	_Users.RFA_Notification_Email = 1
					</cfif>
					<cfif arguments.HQSendEmailToRSPOnly>
					AND _Users.User_ID = <cfqueryparam value="#arguments.responsibleUserId#" cfsqltype="CF_SQL_VARCHAR">
					</cfif>
					<cfif arguments.checkRemoteApprovalOption>
					AND	_Users.Remote_Approval_Option > 0
					</cfif>
					<!--- End Note: KAL; 7/2/2010; D23915: Single Instance Remote Approval --->
					<!--- Don't show BSA users --->
					<cfif appSettings.getHide_BSA_Users() IS 1>
					AND (_Users.User_Rights_ID IS NULL
					OR _Users.User_Rights_ID != 9999)
					</cfif>

					<!--- user not in agreed list --->
					and	_Users.User_ID NOT IN
					(
					SELECT	DISTINCT Program_Agree.User_ID
					FROM	Program_Agree_All_Group Program_Agree
					WHERE	Program_Agree.ProgramId = Contract_Main.Contract_Main_ID
					)
					<!--- Manual Selection of Approvers --->
					AND (
						Program_Control_Panel_Options.Manual_Selection_Of_Approvers = 0
						<!--- Only apply this logic is table has any entry --->
						OR	NOT EXISTS (
							SELECT	1
							FROM	Program_Approval_By_Profile l
							WHERE	l.Program_ID = Contract_Main.Contract_Main_ID
							AND		l.Deleted = 0
							)
						OR	_Users.User_ID IN (
							SELECT	Approved_By_User_ID
							FROM	Program_Approval_By_Profile l
							WHERE	l.Program_ID = Contract_Main.Contract_Main_ID
							AND		l.Approved_By_User = 0
							AND		l.Deleted = 0
							)
					)
					INNER JOIN Profiles
					ON	Profiles.Profiles_ID = _Users.Profiles_ID

					INNER JOIN Profiles_Settings
					ON	Profiles_Settings.Deleted = 0
					AND	Profiles_Settings.Profiles_ID = _Users.Profiles_ID
					<!--- Dev Note: KAL; D19440/20199: Approval via email: List Users with Mass Approval Rights --->
					<cfif arguments.checkMassApprove>
					AND	Profiles_Settings.Mass_RFA_Program_Approve = 1
					</cfif>

					<!--- User not in forbid list/in allow list --->
					AND
					(
						_Users.Profiles_ID
					<cfif forbidType EQ 1>not </cfif><!--- forbit type=1, forbid, 0=allow --->
					in
					(	select 	distinct profile_id
						from 	Profile_Forbidden_Template
						where 	Deleted = 0
								AND Forbid_Type = #forbidType#
								AND	Forbid_Access_Type = 2<!--- 1=access, 2=approve --->
								AND template_id = Contract_Main.ProgramType_ID
					)
					<cfif appSettings.getShow_Fixed_Freight() eq 1>
					OR 	(Contract_Main_Aux_Data.Freight_Component_Type <> 0	AND	Profiles_Settings.Approve_Freight_Programs = 1)
					</cfif>
					)

					<!--- no need to do the GDW4 filter any more because it is already handled in Program_Approvable_Profiles --->

					<!--- check for profile level approval right --->
					AND
					(
					(Profiles_Settings.Cont_Prog_View_Margins = 1 AND Profiles_Settings.Cont_Prog_Approval_Rights = 1)
					<cfif appSettings.getShow_Fixed_Freight() eq 1>
					OR 	(Contract_Main_Aux_Data.Freight_Component_Type <> 0	AND	Profiles_Settings.Approve_Freight_Programs = 1)
					</cfif>
					)

					<!--- Check Business Segment/Class Code restriction --->
					<cfif arguments.businessSegmentsOn>
					<cfif this.businessSegManager.getClassCodesOn()>
						<cfset ContractClassCodeList = "" />
						<cfsilent>
						<cfif arguments.responsibleUserId NEQ "">
							<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
							<cfset qGetUserClassCodes = businessSegManager.getActiveClassCodes(arguments.responsibleUserId, 0) />
							<cfset ContractClassCodeList = ValueList(qgetUserClassCodes.class_code_id)>
						</cfif>
						</cfsilent>
						INNER JOIN Class_Code
						ON	Class_Code.Business_Segment_ID = Contract_Main.Business_Segment_ID
						INNER JOIN User_Class_Code
						ON	User_Class_Code.Deleted = 0
						AND	Class_Code.Class_Code_ID = User_Class_Code.Class_Code_ID
						AND	User_Class_Code.User_ID = _Users.User_ID
						AND
						(
							1=2
							<cfloop list="#ContractClassCodeList#" index="thisClassCode">
							OR Class_Code.Class_Code_ID = #thisClassCode#
							</cfloop>
						)
					<cfelse>
						INNER JOIN User_Business_Segment
						ON	User_Business_Segment.Deleted = 0
						AND	User_Business_Segment.Business_Segment_ID = Contract_Main.Business_Segment_ID
						AND	User_Business_Segment.User_ID = _Users.User_ID
					</cfif>
					</cfif>

					LEFT JOIN Authority_Sequence Approve_Authority_Sequence
					ON
					<cfif appSettings.getAuthority_Sequence_For_HQ_Only()>
					Position_To_Approve.Service_Market_ID IS NULL
					AND Position_To_Approve.Service_Region_ID IS NULL
					AND Position_To_Approve.Service_Zone_ID IS NULL
					AND</cfif> Approve_Authority_Sequence.Deleted = 0
					AND Approve_Authority_Sequence.Authority_Sequence_Order = Program_Approvable_Profiles.Authority_Sequence_Order
			WHERE	Contract_Main.Contract_Status_Type_IDX = 2
			AND		Contract_Main.Deleted = 0
			<cfif arguments.programId NEQ 0>
			AND		Contract_Main.Contract_Main_ID = #arguments.programId#
			</cfif>
			<cfif arguments.plannerId NEQ 0>
			AND		(Contract_Main.Planner_ID = #arguments.plannerId# OR Planners.Parent_Planner_ID = #arguments.plannerId#)
			</cfif>
			<cfif arguments.PlannerListTmpTable neq "">
			AND		EXISTS (SELECT 1 FROM #arguments.PlannerListTmpTable# t WHERE t.Planner_ID = Contract_Main.Planner_ID OR t.Planner_ID = Planners.Parent_Planner_ID)
			</cfif>
			AND		(Approve_Authority_Sequence.Authority_Sequence_ID IS NULL OR Approve_Authority_Sequence.Authority_Sequence_ID = _Users.Authority_Sequence_ID)

            SELECT  *
            FROM    ##Tmp_Program_CRA_List
			<cfif arguments.programId NEQ 0>
			ORDER BY Authority_Sequence_Order DESC
			<cfelse>
			ORDER BY User_Full_Name, User_Email, User_ID, Contract_Main_ID
			</cfif>
		</cfquery>

		<cfreturn qGetApprovalbleUsers />

	</cffunction>

	<cffunction name="isProgramAgreed" output="false" returntype="boolean">

		<cfargument name="programId" required="true" type="numeric" />
		<cfargument name="userId" required="false" type="string" />

		<cfset returnValue = 0 />
		<!--- Check to see if it's a revision--->
		<cfquery name="qCheckProgramAgreed" datasource="#application.datasource#">

			SELECT 	User_Agree
			FROM 	Program_Agree
			WHERE 	ProgramId = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
			<cfif isdefined("arguments.userId") and arguments.userId NEQ "">
			AND		User_Id = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">
			</cfif>

		</cfquery>
		<cfif qCheckProgramAgreed.recordCount>
			<cfset returnValue = qCheckProgramAgreed.User_Agree />
		</cfif>

		<cfreturn returnValue />

	</cffunction>

	<cffunction name="programHasGroups" output="false">

		<cfargument name="programId" required="true" type="numeric">
		<cfargument name="discountType" required="false" type="numeric" default="0">

		<cfset rProgramHasGroups = 0 />

		<!---check to see if we have any group entries--->
		<cfquery name="qCheckContractGroups" datasource="#application.datasource#">

			SELECT 	TOP 1 Contract_Main_ID
			FROM	Contract_Products
			WHERE	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.programId#" />
			AND		Deleted = 0
			AND		Is_Group = 1
			<CFIF arguments.discountType neq 0>
			AND	Product_Type_ID = <cfqueryparam value="#arguments.discountType#" cfsqltype="CF_SQL_INTEGER">
			</CFIF>

		</cfquery>

		<!---if we have a group entry then return true--->
		<cfif qCheckContractGroups.RecordCount>
			<cfset rProgramHasGroups = 1 />
		</cfif>

		<cfreturn rProgramHasGroups />

	</cffunction>

	<cffunction name="programHasDistributors" output="false">

		<cfargument name="programId" required="true" type="numeric">

		<cfset rProgramHasDistributors = 0 />

		<!---check to see if this contract has a customer--->
		<cfquery name="qCheckContractDist" datasource="#application.datasource#">

			SELECT TOP 1 BSA_Foodservice_Customers_ID
			FROM 	Contract_Distributors
			WHERE 	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.programId#" />
			AND 	Deleted = 0

		</cfquery>

		<!---if we have a customer then return true--->
		<cfif qCheckContractDist.RecordCount>
			<cfset rProgramHasDistributors = 1 />
		</cfif>

		<cfreturn rProgramHasDistributors />

	</cffunction>


	<cffunction name="ParentProgramInfo" output="false" returntype="query">

		<cfargument name="programId" required="true" type="numeric">

	<!--- Get information from the parent programs (used for date exclusion programs - the child programs) --->
	<cfquery name="qgetParentContractInfo" datasource="#application.datasource#">
		SELECT Contract_Main.Contract_Number, Contract_Main.Revision_Version, Contract_Main.Contract_Main_ID,contract_start_date
		FROM Contract_Main INNER JOIN Program_Exclusions
		ON Contract_Main.Contract_Main_ID = Program_Exclusions.Original_Program_ID
		WHERE
		--Contract_Main.Deleted = 0
		--AND
		Program_Exclusions.Deleted = 0
		AND Program_Exclusions.Revision_Program_ID = '#arguments.programId#'
	</cfquery>

		<cfreturn qgetParentContractInfo />

	</cffunction>


	<cffunction name="ChildProgramIDs" output="false" returntype="query">

		<cfargument name="programId" required="true" type="numeric">
		<cfargument name="IsParent" required="true" type="boolean">

	<!--- Get the Date Exclusion program ID's (Child program ID's) --->
		<cfquery name="qgetDateExclusionprogramIDs" datasource="#application.datasource#">
			SELECT pe.Revision_Program_ID, cm.Contract_Start_Date, cm.Contract_End_Date
			FROM Program_Exclusions pe INNER JOIN Contract_Main cm
			ON cm.Contract_Main_ID = pe.Original_Program_ID
			WHERE pe.Deleted = 0
			<cfif IsParent eq 0>
			AND cm.Contract_Main_ID ='#arguments.programId#'
			<cfelse>
			AND pe.Original_Program_ID = '#arguments.programId#'
			</cfif>
		</cfquery>

		<cfreturn qgetDateExclusionprogramIDs />

	</cffunction>

	<cffunction name="DateExclusionDates" output="false" returntype="query">

	<cfargument name="programId" required="true" type="string">
	<cfset arguments.programId = Replace(arguments.programId,"#chr(39)#","","ALL")>
	<!--- Get a day before Contract Start Date and a day after the Contract End Date(This is used to get the Original program dates) --->
	<cfquery name="qgetDateExclusionDates" datasource="#application.datasource#">
	SELECT DateAdd(d,-1,Contract_Start_Date) As Before_Date_Exclusion_Contract_Start_Date, DateAdd(d,1,Contract_End_Date) As After_Date_Exclusion_Contract_End_Date,
	Contract_Start_Date, Contract_End_Date
	FROM  Contract_Main
	WHERE Contract_Main_ID IN(#arguments.programId#)
	</cfquery>

		<cfreturn qgetDateExclusionDates />

	</cffunction>

	<cffunction name="getagreedtypecodes" output="false" returntype="query">

	<cfargument name="programId" required="true" type="string">
	<cfargument name="User_Profile" type="numeric" required="true" default="0" />
	<cfargument name="approval_GroupTablename" type="string" required="true" />
	<cfargument name="approval_GroupIDFIELD" type="string" required="true" />

	<cfquery name="qgetagreedtypecodes" datasource="#application.datasource#">
	select distinct contract_products.BSA_Foodservice_Items_Master_Id,
	BSA_Foodservice_Items_Master.#arguments.approval_GroupIDFIELD#
	from contract_products
	INNER JOIN 	BSA_Foodservice_Items_Master
	ON 			BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id =
	contract_products.BSA_Foodservice_Items_Master_Id
	and 		BSA_Foodservice_Items_Master.deleted = 0
	INNER JOIN 	#arguments.approval_GroupTablename#
	ON 			#arguments.approval_GroupTablename#.#arguments.approval_GroupIDFIELD# = BSA_Foodservice_Items_Master.#arguments.approval_GroupIDFIELD#
	AND			#arguments.approval_GroupTablename#.#arguments.approval_GroupIDFIELD# IN
		(
			SELECT	DISTINCT #arguments.approval_GroupIDFIELD#
			FROM	#arguments.approval_GroupTablename#
			INNER JOIN Group_Approval_Rights Group_Level_Access_Rights
			ON Group_Level_Access_Rights.Deleted = 0
			AND Group_Level_Access_Rights.Group_ID = #arguments.approval_GroupTablename#.#arguments.approval_GroupIDFIELD#
			AND Group_Level_Access_Rights.Group_Type = 1
			AND	Group_Level_Access_Rights.Group_ID_Approval = 1
			AND Group_Level_Access_Rights.User_Profile_Id = #arguments.User_Profile#
						)
where contract_main_id = #arguments.programId#
and contract_products.deleted = 0
</cfquery>
		<cfreturn qgetagreedtypecodes />

	</cffunction>

	<cffunction name="getagreedtprogramsettings" output="false" returntype="query">
		<cfset useLakebaseForqgetagreedtprogramsettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("general_settings")>
<cfif useLakebaseForqgetagreedtprogramsettings>
	<cftry>
		<cfset qgetagreedtprogramsettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("general_settings", {
				"select" = "edit_basic_info,edit_operators,edit_opr_basinfo"
			}), "edit_basic_info,edit_operators,edit_opr_basinfo"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetagreedtprogramsettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetagreedtprogramsettings>
<cfquery name="qgetagreedtprogramsettings" datasource="#application.datasource#">
			select edit_basic_info, edit_operators,edit_opr_basinfo
			from general_settings
		</cfquery>
</cfif>
		<cfreturn qgetagreedtprogramsettings />

	</cffunction>

	<cffunction name="saveEditAgreedProgramSettings" output="false">
	<cfargument name="formScope" required="true" type="struct" />
		<cfquery name="qsaveEditAgreedProgramSettings" datasource="#application.datasource#">
			update general_settings
			set edit_basic_info = #Evaluate("arguments.formScope.edit_basic_info")#,
			edit_operators = #Evaluate("arguments.formScope.edit_operators")#,
			edit_opr_basinfo = #Evaluate("arguments.formScope.edit_opr_basinfo")#
		</cfquery>
	</cffunction>

	<cffunction name="getmodifyinguser" output="false" returntype="query">
		<cfargument name="user_id" type="string" required="true" />
		<cfquery name="qgetmodifyinguser" datasource="#application.datasource#">
			select name_first + ' ' + name_last as User_name
			from _users
			where user_id = '#arguments.user_id#'
		</cfquery>
		<cfreturn qgetmodifyinguser />

	</cffunction>

	<cffunction name="getStartDates" output="false" returntype="string">
	<cfargument name="programId" required="true" type="string">
	<cfargument name="StartDate" type="string" required="true" />
	<cfquery name="qgetStartDateDates" datasource="#application.datasource#">
							select count(*) as DECount from
							Program_Exclusions
							where original_program_id = '#arguments.programId#'
							and start_date = '#arguments.StartDate#'
							and deleted = 0
						</cfquery>
		<cfreturn qgetStartDateDates.DECount  />
	</cffunction>

	<cffunction name="getParentProgramInfo" output="false" returntype="query">
	<cfargument name="programId" required="true" type="string">

		<cfset useLakebaseForqGetParentProgramInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForqGetParentProgramInfo>
	<cftry>
		<cfset qGetParentProgramInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#arguments.ProgramID#",
				"select" = "revision_of_contract_main_id"
			}), "revision_of_contract_main_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetParentProgramInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetParentProgramInfo>
<cfquery name="qgetParentProgramInfo" datasource="#application.datasource#">
			SELECT Revision_of_Contract_Main_ID
			FROM Contract_Main
			WHERE Contract_Main_ID = '#arguments.ProgramID#'
		</cfquery>
</cfif>
		<cfreturn qgetParentProgramInfo  />
	</cffunction>


	<!---BJF: I don't think this is used anymore. /common_files/contracts/operator_program_list.cfm now uses the search function and puts in the operator id as though one was searching for it. D9634  --->
	<cffunction name="getoperatorprograms" output="false" returntype="query">
	<cfargument name="operatorId" required="true" type="string">
	<cfquery name="qgetoperatorprograms" datasource="#application.datasource#">
			select contract_main.contract_main_id,contract_title,contract_start_date,contract_end_date,contract_number,
			contract_status_types.contract_status_type_desc,_users.name_last, _users.name_first
			 from contract_main
			 inner join contract_status_types on
			 contract_status_types.contract_status_type_id = contract_main.contract_status_type_idx
			inner join contract_operators on
			contract_operators.contract_main_id = contract_main.contract_main_id
			left join _users on _users.user_id = contract_main.responsible_user_id
			where contract_main.deleted = 0
			and contract_operators.bsa_operator_id = '#arguments.operatorId#'
			and contract_operators.deleted = 0
	</cfquery>
		<cfreturn qgetoperatorprograms />
	</cffunction>

	<cffunction name="getAffectBrokerCommission" output="false" returntype="string">

		<cfargument name="AffectBrokerCommissionId" type="string" required="true" />

		<cfif isNumeric(arguments.AffectBrokerCommissionId)>
			<cfset AffectBrokerCommissionArray = ArrayNew(1) />
			<cfset AffectBrokerCommissionArray[1] = "None Selected" />
			<cfset AffectBrokerCommissionArray[2] = "Yes" />
			<cfset AffectBrokerCommissionArray[3] = "No" />
			<cfset AffectBrokerCommissionArray[4] = "Unknown" />

			<cfif arguments.AffectBrokerCommissionId GTE 0 AND arguments.AffectBrokerCommissionId LT ArrayLen(AffectBrokerCommissionArray)>
				<cfreturn AffectBrokerCommissionArray[arguments.AffectBrokerCommissionId+1] />
			</cfif>
		</cfif>

		<cfreturn "" />

	</cffunction>

	<cffunction name="getAffectBrokerCommissionType" output="false" returntype="string">

		<cfargument name="AffectBrokerCommissionTypeId" type="string" required="true" />

		<cfif isNumeric(arguments.AffectBrokerCommissionTypeId)>
			<cfset AffectBrokerCommissionTypeArray = ArrayNew(1) />
			<cfset AffectBrokerCommissionTypeArray[1] = "None Selected" />
			<cfset AffectBrokerCommissionTypeArray[2] = "Reduced" />
			<cfset AffectBrokerCommissionTypeArray[3] = "Zero" />
			<cfset AffectBrokerCommissionTypeArray[4] = "Unknown" />

			<cfif arguments.AffectBrokerCommissionTypeId GTE 0 AND arguments.AffectBrokerCommissionTypeId LT ArrayLen(AffectBrokerCommissionTypeArray)>
				<cfreturn AffectBrokerCommissionTypeArray[arguments.AffectBrokerCommissionTypeId+1] />
			</cfif>
		</cfif>

		<cfreturn "" />

	</cffunction>

	<cffunction name="getAffectShelter" output="false" returntype="string">

		<cfargument name="AffectShelterId" type="string" required="true" />

		<cfif isNumeric(arguments.AffectShelterId)>
			<cfset AffectShelterArray = ArrayNew(1) />
			<cfset AffectShelterArray[1] = "None Selected" />
			<cfset AffectShelterArray[2] = "Yes" />
			<cfset AffectShelterArray[3] = "No" />
			<cfset AffectShelterArray[4] = "Unknown" />

			<cfif arguments.AffectShelterId GTE 0 AND arguments.AffectShelterId LT ArrayLen(AffectShelterArray)>
				<cfreturn AffectShelterArray[arguments.AffectShelterId+1] />
			</cfif>
		</cfif>

		<cfreturn "" />

	</cffunction>

	<cffunction name="getAffectShelterTypes" output="false" returntype="string">

		<cfargument name="AffectShelterTypesList" type="string" required="true" />

		<cfset retrunValue = "" />

		<cfloop list="#arguments.AffectShelterTypesList#" index="AffectShelterTypeId">
			<cfset retrunValue = ListAppend(retrunValue, getAffectShelterType(AffectShelterTypeId)) />
		</cfloop>

		<cfreturn retrunValue />

	</cffunction>

	<cffunction name="getAffectShelterType" output="false" returntype="string">

		<cfargument name="AffectShelterTypeId" type="string" required="true" />

		<cfif isNumeric(arguments.AffectShelterTypeId)>
			<cfset AffectShelterTypeArray = ArrayNew(1) />
			<cfset AffectShelterTypeArray[1] = "None Selected" />
			<cfset AffectShelterTypeArray[2] = "Local" />
			<cfset AffectShelterTypeArray[3] = "Corporate" />

			<cfif arguments.AffectShelterTypeId GTE 0 AND arguments.AffectShelterTypeId LT ArrayLen(AffectShelterTypeArray)>
				<cfreturn AffectShelterTypeArray[arguments.AffectShelterTypeId+1] />
			</cfif>
		</cfif>

		<cfreturn "" />

	</cffunction>
	<cffunction name="getProgramStatus" access="public" returntype="query" output="false" description="Get the different statuses and their descriptions fro the Flash Scorecard Status Viewer">
		<cfset var appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
				<!--- getStatus --->
		<cfquery name="qGetStatus" datasource="#application.datasource#">
			SELECT	Contract_Status_Types.Contract_Status_Type_ID,
					<cfif request.Get_Profile_Settings.RFA_Agreed EQ 1 or request.Get_Profile_Settings.RFA_Agreed EQ 2>
					CASE
					WHEN Contract_Status_Types.Contract_Status_Type_ID = 2 THEN Program_Agree_Status.Program_Agree_Status_Desc
					ELSE Contract_Status_Types.Contract_Status_Type_Desc
					END Contract_Status_Type_Desc,
					<cfelse>
					Contract_Status_Types.Contract_Status_Type_Desc,
					</cfif>
					ISNULL(Program_Agree_Status_ID, 0) Program_Agree_Status_ID,
					cast(Contract_Status_Types.Contract_Status_Type_ID as varchar(15)) + ':' + cast(ISNULL(Program_Agree_Status_ID, 0) as varchar(15)) statIDagreeID
			FROM	Contract_Status_Types
					LEFT JOIN Program_Agree_Status
					ON  1=2
					<cfif request.Get_Profile_Settings.RFA_Agreed EQ 1 OR request.Get_Profile_Settings.RFA_Agreed EQ 2>
					OR	Contract_Status_Types.Contract_Status_Type_ID = 2
					</cfif>
			WHERE	Contract_Status_Types.Contract_Status_Type_ID <> 3

			<cfif appSettings.getPgmPostApprovalStatus() EQ 1>
			<cfset ProgramPostApprovalStatusManager = CreateObject("component", "components.programs.ProgramPostApprovalStatusManager").init() />
			<cfset arProgramPostApprovalStatusAccessForUserProfile = ProgramPostApprovalStatusManager.getSelectedProfileProgramPostApprovalStatusArray(request.AccessStructure.Profiles_ID) />
			<cfset  arLen = ArrayLen(arProgramPostApprovalStatusAccessForUserProfile) />
			UNION
			SELECT	#ProgramPostApprovalStatusManager.getFakeStatusIdForProgramPostApprovalStatus()# AS Contract_Status_Type_ID,
							Program_Post_Approval_Status.Program_Post_Approval_Status_Desc As Contract_Status_Type_Desc,
							Program_Post_Approval_Status.Program_Post_Approval_Status_ID Program_Agree_Status_ID
			FROM	Program_Post_Approval_Status
			WHERE	Program_Post_Approval_Status.Deleted = 0
			<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getPgmPostApprovalStatusType() EQ 1><!--- ignore id=2 if appsettings value=1 --->
			AND		Program_Post_Approval_Status.Program_Post_Approval_Status_ID <> 2
			</cfif>
			</cfif>

			ORDER BY Contract_Status_Type_ID, Program_Agree_Status_ID
		</cfquery>

		<cfif request.Get_Profile_Settings.Read_Only_Catalog_Access EQ 1>
			<cfset QueryAddRow(qGetStatus) />
			<cfset QuerySetCell(qGetStatus, "Contract_Status_Type_ID", 9) />
			<cfset QuerySetCell(qGetStatus, "Contract_Status_Type_Desc", "Catalog") />
			<cfset QuerySetCell(qGetStatus, "Program_Agree_Status_ID", 0) />
			<cfset QuerySetCell(qGetStatus, "statIDagreeID", "9:0") />
		</cfif>
		<cfreturn qGetStatus />

	</cffunction>
	<cffunction name="insertFavorites" access="public" output="false" hint="insert programs in to the users list of favorites" returntype="void">
		<cfargument name="items" type="array" required="yes">
		<cfargument name="user_id" type="uuid" required="yes">
		<cfset var frm = arraylen(items)>
		<cfloop index="i" from="#frm#" to="1" step="-1">
			<cfset useLakebaseForqgetFav = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_favorites")>
<cfif useLakebaseForqgetFav>
	<cftry>
		<cfset qgetFav = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_favorites", {
				"user_id" = "eq.#arguments.user_id#",
				"program_id" = "eq.#items[i].data#",
				"select" = "program_id"
			}), "program_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetFav = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetFav>
<cfquery name="qgetFav" datasource="#application.datasource#">
				select Program_id from Program_Favorites
					where User_ID = '#arguments.user_id#' and
					program_id = '#items[i].data#'
			</cfquery>
</cfif>
			<cfif qgetFav.recordcount eq 0> <!--- if not there, insert record --->
				<cfquery name="qInsFav" datasource="#application.datasource#">
					insert into Program_Favorites (Program_id, User_Id, Program_Number)
						Values ('#items[i].data#','#arguments.user_id#', '#items[i].label#')
				</cfquery>
			</cfif>
		</cfloop>

	</cffunction>

	<cffunction name="removeFavorites" access="public" output="false" hint="insert programs in to the users list of favorites" returntype="void">
		<cfargument name="items" type="array" required="yes">
		<cfargument name="user_id" type="uuid" required="yes">
		<cfset var frm = arraylen(items)>
		<cfloop index="i" from="#frm#" to="1" step="-1">
			<cfquery name="qgetFav" datasource="#application.datasource#">
				select Program_id from Program_Favorites
					where User_ID = '#arguments.user_id#' and
					program_id = '#items[i].data#'
			</cfquery>
			<cfif qgetFav.recordcount gt 0> <!--- if not there, insert record --->
				<cfquery name="qDelFav" datasource="#application.datasource#">
					delete from Program_Favorites where
					User_ID = '#arguments.user_id#'
					and program_id = '#items[i].data#'
				</cfquery>
			</cfif>
		</cfloop>

	</cffunction>

	<cffunction name="GetFavorites" access="public" output="false" hint="insert programs in to the users list of favorites" returntype="query">
		<cfargument name="user_id" type="uuid" required="yes">
			<cfquery name="qgetFavs" datasource="#application.datasource#">
				select Program_id, program_number from Program_Favorites
					where user_id = '#arguments.User_ID#'
			</cfquery>
		<cfreturn qgetFavs />
	</cffunction>

	<cffunction name="GetSettings" output="true" returntype="query">
		<cfargument name="programId" required="true" type="numeric" />
		<cfquery name="qGetSettings" datasource="#application.datasource#">
		SELECT 	EZButton_On,EZ_Contract_Id, Discount_Rebate_Max_Rate_On, Contract_Main.Business_Segment_ID
		FROM 	Contract_Main
		INNER JOIN	Program_Control_Panel_Options
		ON 		(Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID)
		WHERE 	Contract_Main_ID = #arguments.ProgramID#
		</cfquery>
		<cfreturn qGetSettings />
	</cffunction>

	<!--- If the freight app setting is "ON" AND the program template has freight "ON", then the program template is
		  a "freight based" program template --->
	<cffunction name="GetIsProgramFreightOn" output="false" returntype="boolean">
		<cfargument name="programId" required="true" type="numeric" />
		<cfquery name="qryGetIsProgramFreightOn" datasource="#application.datasource#">
		SELECT Freight_Program
		FROM Contract_Main cm
		INNER JOIN Program_Control_Panel_Options pcpo
		ON cm.ProgramType_ID = pcpo.ProgramControl_Panel_Options_ID
		WHERE cm.Contract_Main_ID = #arguments.ProgramID#
		</cfquery>

		<cfset IsProgramFreightOn = 0>
		<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getShow_Fixed_Freight() eq 1
		AND qryGetIsProgramFreightOn.Freight_Program EQ 1>
			<cfset IsProgramFreightOn = 1>
		</cfif>
		<cfreturn IsProgramFreightOn />
	</cffunction>
	<!--- If the freight app setting is "ON" AND the contract main aux data has freight "ON", then the program is
		  a "freight" program --->
	<cffunction name="GetProgramFreightComponentType" output="false" returntype="numeric">
		<cfargument name="programId" required="true" type="numeric" />
		<cfset FreightComponentType = 0>
		<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getShow_Fixed_Freight() eq 1>
			<cfquery name="qGetProgramFreightComponentType" datasource="#application.datasource#">
				SELECT 	Freight_Component_Type
				FROM 	Contract_Main_Aux_Data
				WHERE 	Contract_Main_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
			<cfset FreightComponentType = qGetProgramFreightComponentType.Freight_Component_Type />
		</cfif>
		<cfreturn FreightComponentType />
	</cffunction>
	<!--- If the freight app setting is "ON" AND the contract main aux data has freight "ON", then the program is
		  a "freight" program --->
	<cffunction name="SetProgramFreightComponentType" output="false" returntype="void">
		<cfargument name="programId" required="true" type="numeric" />
		<cfargument name="freightComponentType" required="true" type="numeric" />
		<cfquery name="qSetProgramFreightComponentType" datasource="#application.datasource#">
			UPDATE	Contract_Main_Aux_Data
			SET		Freight_Component_Type = <cfqueryparam value="#arguments.freightComponentType#" cfsqltype="cf_sql_integer">
			WHERE 	Contract_Main_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
	</cffunction>

	<!--- Check if the program has auto pay components --->
	<cffunction name="programHasAutoPayComponents" output="no" returntype="numeric">

		<cfargument name="programId"	type="numeric" />

		<cfset var bProgramHasAutoPayComps 	= "" />

		<cfset bProgramHasAutoPayComps 	= 0 />

		<cfquery name="qCheckForAutoPayComponents" datasource="#application.datasource#">
			DECLARE
			@Contract_Main_ID INT

			SET @Contract_Main_ID = #arguments.programId#

			SELECT	Payment_Type.*
			FROM	Payment_Type
					LEFT JOIN Program_Rebates_Component ON
					Program_Rebates_Component.Program_ID = @Contract_Main_ID AND
					Program_Rebates_Component.Deleted = 0 AND
					Payment_Type.Payment_Type_ID = Program_Rebates_Component.Claim_Mechanics
					LEFT JOIN Program_Fixed_Component ON
					Program_Fixed_Component.Program_ID = @Contract_Main_ID AND
					Program_Fixed_Component.Deleted = 0 AND
					Payment_Type.Payment_Type_ID = Program_Fixed_Component.Claim_Mechanics
					LEFT JOIN Program_Lump_Sums ON
					Program_Lump_Sums.Program_ID = @Contract_Main_ID AND
					Program_Lump_Sums.Deleted = 0 AND
					Payment_Type.Payment_Type_ID = Program_Lump_Sums.Claim_Mechanics
					LEFT JOIN Program_Growth_Components ON
					Program_Growth_Components.Program_ID = @Contract_Main_ID AND
					Program_Growth_Components.Deleted = 0 AND
					Payment_Type.Payment_Type_ID = Program_Growth_Components.Claim_Mechanics
			WHERE	Payment_Type.Is_Auto_Pay = 1
			AND		(
						Program_Rebates_Component.Claim_Mechanics IS NOT NULL OR
						Program_Fixed_Component.Claim_Mechanics IS NOT NULL OR
						Program_Lump_Sums.Claim_Mechanics IS NOT NULL OR
						Program_Growth_Components.Claim_Mechanics IS NOT NULL
					)
		</cfquery>

		<cfif qCheckForAutoPayComponents.RecordCount>
			<cfset bProgramHasAutoPayComps = 1 />
		</cfif>

		<cfreturn bProgramHasAutoPayComps />

	</cffunction>

	<!--- encapsulate the Set Program locktype logic --->
	<cffunction name="setProgramLockType" output="false" returntype="void">
		<cfargument name="programId"	type="numeric" />
		<!---if the lock type is not Do not lock and the program has claim mechanics with locks on...
		then set the program lock type id in contract_main_aux_data--->
		<cfset appsettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
		<cfif appsettings.getProgramLockTypeID()>
			<cfset bProgramHasLockComps = this.programHasLockComponents(programId) />
			<cfset val = 0>
			<cfif bProgramHasLockComps>
				<cfset val = #appsettings.getProgramLockTypeID()#>
			</cfif>
				<!---set the Program_Lock_Type_ID in Contract_Main_Aux_Data--->
				<cfset useLakebaseForqUpdateProgramLockTypeID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main_aux_data")>
<cfif useLakebaseForqUpdateProgramLockTypeID>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_main_aux_data",
			{
				"contract_main_id" = "eq.#programId#"
			},
			{
				"program_lock_type_id" = "#val#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqUpdateProgramLockTypeID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqUpdateProgramLockTypeID>
<cfquery name="qUpdateProgramLockTypeID" datasource="#application.datasource#">
					UPDATE	Contract_Main_Aux_Data
					SET			Program_Lock_Type_ID = #val#
					WHERE	Contract_Main_ID = #programId#
				</cfquery>
</cfif>
		</cfif>
	</cffunction>
	<!--- Check if the program has lock components --->
	<cffunction name="programHasLockComponents" output="no" returntype="numeric">

		<cfargument name="programId"	type="numeric" />

		<cfset var bProgramHasLockComps 	= "" />

		<cfset bProgramHasLockComps 	= 0 />

		<cfquery name="qCheckForLockComponents" datasource="#application.datasource#">
			DECLARE
			@Contract_Main_ID INT

			SET @Contract_Main_ID = #arguments.programId#

			SELECT	1
			FROM	Payment_Type
					LEFT JOIN Program_Rebates_Component ON
					Program_Rebates_Component.Program_ID = @Contract_Main_ID AND
					Program_Rebates_Component.Deleted = 0 AND
					Payment_Type.Payment_Type_ID = Program_Rebates_Component.Claim_Mechanics
					LEFT JOIN Program_Fixed_Component ON
					Program_Fixed_Component.Program_ID = @Contract_Main_ID AND
					Program_Fixed_Component.Deleted = 0 AND
					Payment_Type.Payment_Type_ID = Program_Fixed_Component.Claim_Mechanics
					LEFT JOIN Program_Lump_Sums ON
					Program_Lump_Sums.Program_ID = @Contract_Main_ID AND
					Program_Lump_Sums.Deleted = 0 AND
					Payment_Type.Payment_Type_ID = Program_Lump_Sums.Claim_Mechanics
					LEFT JOIN Program_Growth_Components ON
					Program_Growth_Components.Program_ID = @Contract_Main_ID AND
					Program_Growth_Components.Deleted = 0 AND
					Payment_Type.Payment_Type_ID = Program_Growth_Components.Claim_Mechanics
			WHERE	Payment_Type.Program_Lock_Type_ID > 0
			AND		(
						Program_Rebates_Component.Claim_Mechanics IS NOT NULL OR
						Program_Fixed_Component.Claim_Mechanics IS NOT NULL OR
						Program_Lump_Sums.Claim_Mechanics IS NOT NULL OR
						Program_Growth_Components.Claim_Mechanics IS NOT NULL
					)

			<!--- Check whether any of the components on the program have the property "Program Interface Lock" ON --->
			UNION

			SELECT	1
			FROM	Program_Rebates_Component_Name
					INNER JOIN Program_Rebates_Component ON
					Program_Rebates_Component.Program_Rebates_Component_Name_ID = Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID
			WHERE	Program_Rebates_Component.Program_ID = @Contract_Main_ID
			AND Program_Rebates_Component.Deleted = 0
			AND Program_Rebates_Component_Name.Program_Lock_Type_ID > 0

			UNION

			SELECT	1
			FROM	Program_Fixed_Component_Name
					INNER JOIN Program_Fixed_Component ON
					Program_Fixed_Component.Program_Fixed_Component_Name_ID = Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID
			WHERE	Program_Fixed_Component.Program_ID = @Contract_Main_ID
			AND Program_Fixed_Component.Deleted = 0
			AND Program_Fixed_Component_Name.Program_Lock_Type_ID > 0

			UNION

			SELECT	1
			FROM	Program_Lump_Sum_Name
					INNER JOIN Program_Lump_Sums ON
					Program_Lump_Sums.Program_Lump_Sum_Name_ID = Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID
			WHERE	Program_Lump_Sums.Program_ID = @Contract_Main_ID
			AND Program_Lump_Sums.Deleted = 0
			AND Program_Lump_Sum_Name.Program_Lock_Type_ID > 0

			UNION

			SELECT	1
			FROM	Program_Growth_Components_Name
					INNER JOIN Program_Growth_Components ON
					Program_Growth_Components.Program_Growth_Components_Name_ID = Program_Growth_Components_Name.Program_Growth_Components_Name_ID
			WHERE	Program_Growth_Components.Program_ID = @Contract_Main_ID
			AND Program_Growth_Components.Deleted = 0
			AND Program_Growth_Components_Name.Program_Lock_Type_ID > 0
		</cfquery>

		<cfif qCheckForLockComponents.RecordCount>
			<cfset bProgramHasLockComps = 1 />
		</cfif>

		<cfreturn bProgramHasLockComps />

	</cffunction>

	<cffunction name="getProgramIncludeInReport" output="no" returntype="boolean">
		<cfargument name="approved" type="boolean" required="yes">
		<cfargument name="genericType" type="string" required="yes">
		<cfargument name="cancelled" type="boolean" required="yes">
		<cfargument name="report_type" type="numeric" required="yes">
		<cfargument name="IncludeInReport" type="numeric" required="yes">

		<cfset var bIncludeInReport = 0 />

		<cfif arguments.report_type eq 1>
			<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getProgramClaimRatesReportAvailable()>
				<cfif arguments.approved eq 1 and arguments.cancelled eq 0  and arguments.IncludeInReport eq 1>
					<cfset bIncludeInReport = 1 />
				</cfif>
			</cfif>

		<cfelseif arguments.report_type eq 2>
			<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getShowPricingReport()>
				<cfif arguments.approved eq 1 and arguments.cancelled eq 0 and arguments.IncludeInReport eq 1>
					<cfset bIncludeInReport = 1 />
				</cfif>
			</cfif>
		</cfif>

		<cfreturn bIncludeInReport />

	</cffunction>

	<cffunction name="getParentHasPreviousRevisions" output="false" returntype="boolean">
		<cfargument name="parentProgramId" required="true" type="string">
		<cfargument name="currentProgramId" required="true" type="numeric">
		<cfargument name="bGrandParentHasPreviousRevision" type="numeric" default="-1">

		<cfset var bParentHasPreviousRevisions = 0 />
		<cfset var bGrandParentHasPreviousRevisions = arguments.bGrandParentHasPreviousRevision />

		<cfif isNumeric(arguments.parentProgramId)><!--- only if there is a parent program --->
			<!--- If bGrandParentHasPreviousRevisions is passed in to the function we don't have to do the query --->
			<cfif bGrandParentHasPreviousRevisions eq -1>
				<!--- Find if the parent program is a revision of another parent program with earlier revisions  --->
				<cfquery name="qGetParentProgramInfo" datasource="#application.datasource#">
					SELECT 	Parent_Has_Previous_Revision
					FROM 	Contract_Main
					WHERE 	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.parentProgramId#" />
				</cfquery>
				<cfset bGrandParentHasPreviousRevisions = qGetParentProgramInfo.Parent_Has_Previous_Revision />
			</cfif>

			<cfif bGrandParentHasPreviousRevisions eq 1>
				<cfset bParentHasPreviousRevisions = 1 />
			<cfelse>
				<!--- Find if parent program has earlier revisions --->
				<cfquery name="qGetRevisions" datasource="#application.datasource#">
					SELECT 	Contract_Main_ID
					FROM 	Contract_Main
					WHERE 	Revision_of_Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.parentProgramId#" />
					<cfif arguments.currentProgramId neq 0>
					AND		Contract_Main_ID !=  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.currentProgramId#" />
					</cfif>
					AND		(Approved = 1 OR Deleted = 0)
					AND Manual_Cancel = 0
				</cfquery>
				<cfif qGetRevisions.recordCount>
					<cfset bParentHasPreviousRevisions = 1 />
				</cfif>
			</cfif>

		</cfif>

		<cfreturn bParentHasPreviousRevisions  />
	</cffunction>

	<cffunction name="getCompetitorList" output="false" returntype="query">
		<cfargument name="Program_Bid_Won_By_Code" type="numeric" required ="false" default="0">

		<cfset var qGetCompetitorList = "" />

		<cfquery name="qGetCompetitorList" datasource="#application.datasource#">
		 SELECT	Program_Bid_Won_By_ID,
			Program_Bid_Won_By_Code,
			Program_Bid_Won_By_Description,
			Active,
			Deleted,
			Created_Date,
			Updated_Date,
			Updated_By
		 FROM	Program_Bid_Won_By
		 WHERE Deleted = 0
		 AND Active = 1
		 <cfif Program_Bid_Won_By_Code>
		 	OR Program_Bid_Won_By_Code = '#arguments.Program_Bid_Won_By_Code#'
		 </cfif>
		 ORDER BY Program_Bid_Won_By_Description
		</cfquery>

		<cfreturn qGetCompetitorList />
	</cffunction>

	<cffunction name="getCompetitorSource" output="false" returntype="query">
		<cfargument name="Active" type="numeric" required ="false" default="1">

		<cfset var qGetCompetitorSource = "" />

		<cfset useLakebaseForqGetCompetitorSource = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_bid_source")>
<cfif useLakebaseForqGetCompetitorSource>
	<cftry>
		<cfset qGetCompetitorSource = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_bid_source", {
				"deleted" = "eq.0",
				"active" = "eq.#arguments.Active#",
				"order" = "program_bid_source_description.asc",
				"select" = "program_bid_source_id,program_bid_source_code,program_bid_source_description,active,deleted,created_date,updated_date,updated_by"
			}), "program_bid_source_id,program_bid_source_code,program_bid_source_description,active,deleted,created_date,updated_date,updated_by"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetCompetitorSource = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetCompetitorSource>
<cfquery name="qGetCompetitorSource" datasource="#application.datasource#">
		 SELECT	Program_Bid_Source_ID,
			Program_Bid_Source_Code,
			Program_Bid_Source_Description,
			Active,
			Deleted,
			Created_Date,
			Updated_Date,
			Updated_By
		 FROM	Program_Bid_Source
		 WHERE 	Deleted = 0
		 AND Active = #arguments.Active#
		 ORDER BY Program_Bid_Source_Description
		</cfquery>
</cfif>

		<cfreturn qGetCompetitorSource />
	</cffunction>

	<cffunction name="getCompetitorSourceType" output="false" returntype="query">

		<cfset var qGetCompetitorSourceType = "" />

		<cfset useLakebaseForqGetCompetitorSourceType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_bid_source_type")>
<cfif useLakebaseForqGetCompetitorSourceType>
	<cftry>
		<cfset qGetCompetitorSourceType = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_bid_source_type", {
				"deleted" = "eq.0",
				"active" = "eq.1",
				"order" = "program_bid_source_type_description.asc",
				"select" = "program_bid_source_type_id,program_bid_source_type_code,program_bid_source_type_description,active,deleted,created_date,updated_date,updated_by"
			}), "program_bid_source_type_id,program_bid_source_type_code,program_bid_source_type_description,active,deleted,created_date,updated_date,updated_by"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetCompetitorSourceType = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetCompetitorSourceType>
<cfquery name="qGetCompetitorSourceType" datasource="#application.datasource#">
		 SELECT	Program_Bid_Source_Type_ID,
			Program_Bid_Source_Type_Code,
			Program_Bid_Source_Type_Description,
			Active,
			Deleted,
			Created_Date,
			Updated_Date,
			Updated_By
		 FROM	Program_Bid_Source_Type
		 WHERE 	Deleted = 0
		 AND Active = 1
		 ORDER BY Program_Bid_Source_Type_Description
		</cfquery>
</cfif>

		<cfreturn qGetCompetitorSourceType />
	</cffunction>

	<!--- Get the price bracket for the program --->
	<cffunction name="getPriceListBracketForProgram" access="public" returntype="query" output="false">
		<cfargument name="programID" type="string" required="true" />

		<cfset useLakebaseForqGetPriceListBracketForProgram = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main_aux_data")>
<cfif useLakebaseForqGetPriceListBracketForProgram>
	<cftry>
		<cfset qGetPriceListBracketForProgram = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main_aux_data", {
				"contract_main_id" = "eq.#arguments.programID#",
				"select" = "price_list_id,pricebracket_update,pricebracket_update_by,pricebracket_update_date"
			}), "price_list_id,pricebracket_update,pricebracket_update_by,pricebracket_update_date"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetPriceListBracketForProgram = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetPriceListBracketForProgram>
<cfquery name="qGetPriceListBracketForProgram" datasource="#application.datasource#">
		  SELECT Price_List_ID,PriceBracket_Update,PriceBracket_Update_By,PriceBracket_Update_Date
		  FROM Contract_Main_Aux_Data
		  WHERE Contract_Main_ID = '#arguments.programID#'
		</cfquery>
</cfif>

		<cfreturn qGetPriceListBracketForProgram>

	</cffunction>

	<!--- Get a list of all price brackets --->
	<cffunction name="getAllPriceListBrackets" access="public" returntype="query" output="false">

		  	<!--- Dev Note: drachala; D28504: Update bracket drop down list to remove price list ID  START
              Changed/Added: changed Select statement to get distinct Bracket value.--->
		<cfset useLakebaseForqGetAllPriceListBrackets = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("v_price_list_bracket")>
<cfif useLakebaseForqGetAllPriceListBrackets>
	<cftry>
		<cfset qGetAllPriceListBrackets = application.oLakebase.toQuery(
			application.oLakebase.selectRows("v_price_list_bracket", {
				"order" = "bracket.asc",
				"select" = "bracket"
			}), "bracket"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetAllPriceListBrackets = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetAllPriceListBrackets>
<cfquery name="qGetAllPriceListBrackets" datasource="#application.datasource#">
		  SELECT distinct Bracket
		  FROM V_Price_List_Bracket
		  ORDER BY Bracket
		</cfquery>
</cfif>
		<!--- End Dev Note: drachala; D28504: Update bracket drop down list to remove price list ID  --->
		<cfreturn qGetAllPriceListBrackets>

	</cffunction>

	<!--- Get info as to whether a price bracket is overridden OR not. --->
	<cffunction name="getPriceListBracketOverridden" access="public" returntype="boolean" output="false">
		<cfargument name="programID" type="string" required="true" />
		<cfargument name="priceListID" type="string" required="true" />
		<cfargument name="selectedPriceBracket" type="string" required="false" default="0" />

		<cfset var priceBracketOverridden = 0>
		<cfset var priceBracketUpdate = 0>

	       <!--- Check whether the price bracket is updated in the db. We do not check this when the "price bracket" is saved into the db. --->
	      <cfif arguments.selectedPriceBracket eq 0>
		<cfset useLakebaseForqIsPriceListBracketOverridden = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main_aux_data")>
<cfif useLakebaseForqIsPriceListBracketOverridden>
	<cftry>
		<cfset qIsPriceListBracketOverridden = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main_aux_data", {
				"contract_main_id" = "eq.#arguments.programID#",
				"select" = "pricebracket_update"
			}), "pricebracket_update"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqIsPriceListBracketOverridden = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqIsPriceListBracketOverridden>
<CFQUERY NAME="qIsPriceListBracketOverridden" datasource="#application.datasource#">
		  SELECT PriceBracket_Update
		  FROM Contract_Main_Aux_Data
		  WHERE contract_Main_ID = '#arguments.programID#'
		</CFQUERY>
</cfif>

		<cfset priceBracketUpdate = qIsPriceListBracketOverridden.PriceBracket_Update>

		<cfelse>

		<!--- Used when price bracket is saved into the db --->
		<cfset priceBracketUpdate = 0>

	      </cfif>

		<!--- Do this under the following conditions:
			- If the "PriceBracket_Update" field is set to 0 in the db, then check this so that when a user visits the edit component page
			  and clicks on save, then we need to see whether the user changed the bracket on the pop up page. If yes, themn show the "override" icon
			  next to bracket on the "i" image.
			- When the user clicks on "save" on the fixed component page, then compare the price bracket with what was already existing in the db.
		--->
		<cfif priceBracketUpdate eq 0>
			<CFQUERY NAME="qIsPriceListBracketOverridden" datasource="#application.datasource#">
			  SELECT Count(Contract_Main_ID) As PriceBracket_Update
			  FROM Contract_Main_Aux_Data
			  WHERE contract_Main_ID = '#arguments.programID#'
			  <!--- It is necessary to convert nulls to blanks for comparison. NULL is not good for comparison --->
			  AND IsNull(Price_List_ID,'') <> '#arguments.priceListID#'
			</CFQUERY>
		</cfif>

		<cfif qIsPriceListBracketOverridden.PriceBracket_Update GT 0>
			<cfset priceBracketOverridden = 1>
		</cfif>

		<cfreturn priceBracketOverridden>

	</cffunction>


	<cffunction name="getItemCustPriceTemplatePS" access="public" returntype="query" output="false">
		<cfargument name="product_id" type="string" required="true" />
		<cfargument name="Contract_Main_ID" type="string" required="false" default =""/>
		<cfargument name="priceHeaderListID" type="string" required="true" />

		<cfquery name="qgetItemCustPriceTemplatePS" datasource="#application.datasource#">
			SELECT	CAST(ISNULL(price_list_detail.LB_FOB_Price, 0) as decimal(20, 3)) as FOB_LB_Price,
				CAST(ISNULL(price_list_detail.CS_FOB_Price, 0) as decimal(20, 3)) as FOB_CS_Price
		 	FROM price_list_header
			INNER JOIN price_list_detail
			ON	price_list_detail.price_list_header_id = price_list_header.price_list_header_id
			AND	price_list_detail.deleted = 0
			AND	price_list_detail.product_id = '#arguments.product_id#'
			WHERE	price_list_header.price_list_header_ID = '#arguments.priceHeaderListID#'
			AND	price_list_header.deleted = 0
		</cfquery>
		<!--- if no record is found create a row with zero values [D41345 - Event error 17796 GM: Row number 0 is out of bounds]--->
		<cfif qgetItemCustPriceTemplatePS.RecordCount EQ 0>
			<cfquery name="qgetItemCustPriceTemplatePS" datasource="#application.datasource#">
				SELECT CAST(0 as decimal(20, 3)) as FOB_LB_Price,
							 CAST(0 as decimal(20, 3)) as FOB_CS_Price
			</cfquery>
		</cfif>

		<cfreturn qgetItemCustPriceTemplatePS />
	</cffunction>

	<cffunction name="getProgramProductsPaidToWithDuplicateDiscountTypes" access="public" returntype="query" output="false">
		<cfargument name="programId" type="numeric" required="true" />

		<cfquery name="qGetProgramProductsPaidToWithDuplicateDiscountTypes" datasource="#application.datasource#">

			set transaction isolation level read uncommitted

			<!--- *********** Get list of fixed price and rebate products --->
			IF OBJECT_ID('tempdb..##tmp_program_products') IS NOT NULL
			DROP TABLE ##tmp_program_products

			select	contract_products.BSA_Foodservice_Items_Master_ID,
					contract_products.Product_Type_ID,
					Program_Fixed_Component_Name.Program_Fixed_Component_Name as Component_Name,
					Program_Fixed_Component.Fixed_Component_Paid_to as Component_Paid_To,
					Program_Fixed_Price_Product_Data.Fixed_Price_Value as Rate, Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID
			into	##tmp_program_products
			from	contract_main

			inner join contract_products
			on	contract_products.Contract_Main_ID = contract_main.contract_main_id
			and	contract_products.Deleted = 0
			and	contract_products.Product_Type_ID = 1 -- fixed price

			inner join Program_Fixed_Component
			on	Program_Fixed_Component.Program_ID = contract_main.contract_main_id
			and	Program_Fixed_Component.Deleted = 0

			inner join Program_Fixed_Component_Name
			on	Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID = Program_Fixed_Component.Program_Fixed_Component_Name_ID

			inner join Program_Fixed_Price_Product_Data
			on	Program_Fixed_Price_Product_Data.Contract_Products_ID = contract_products.contract_products_id
			and	Program_Fixed_Price_Product_Data.Program_Fixed_Component_id = Program_Fixed_Component.Program_Fixed_Component_id
			and	Program_Fixed_Price_Product_Data.Deleted = 0
			and	CAST(Program_Fixed_Price_Product_Data.Fixed_Price_Value as float) != 0

			where	contract_main.contract_main_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.programId#">

			union

			select	contract_products.BSA_Foodservice_Items_Master_ID,
					contract_products.Product_Type_ID,
					Program_Rebates_Component_Name.Program_Rebates_Component_Name as Component_Name,
					Program_Rebates_Component.Component_Paid_To as Component_Paid_To,
					Program_Rebates_Component_Data.Rate, Program_Rebates_Component_Data.Unit_Of_Measure_ID
			from	contract_main

			inner join contract_products
			on	contract_products.Contract_Main_ID = contract_main.contract_main_id
			and	contract_products.Deleted = 0
			and	contract_products.Product_Type_ID = 2 -- rebate

			inner join Program_Rebates_Component
			on	Program_Rebates_Component.Program_ID = contract_main.contract_main_id
			and	Program_Rebates_Component.Deleted = 0

			inner join Program_Rebates_Component_Name
			on	Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID = Program_Rebates_Component.Program_Rebates_Component_Name_ID

			inner join Program_Rebates_Product_Data
			on	Program_Rebates_Product_Data.Contract_Products_ID = contract_products.contract_products_id
			and Program_Rebates_Product_Data.Deleted = 0

			inner join Program_Rebates_Component_Data
			on	Program_Rebates_Component_Data.Program_Rebates_Product_Data_ID = Program_Rebates_Product_Data.Program_Rebates_Product_Data_ID
			and	Program_Rebates_Component_Data.Program_Rebates_Component_ID = Program_Rebates_Component.Program_Rebates_Component_ID
			and	Program_Rebates_Component_Data.Deleted = 0
			and	CAST(Program_Rebates_Component_Data.Rate as float) != 0

			where	contract_main.contract_main_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.programId#">


			<!--- *********** Find products with more than one discount type for same paid to --->
			;With tmp_dups (Component_Paid_To, BSA_Foodservice_Items_Master_ID) As
			(
			select	Component_Paid_To, BSA_Foodservice_Items_Master_ID
			from	##tmp_program_products
			group by Component_Paid_To, BSA_Foodservice_Items_Master_ID
			Having COUNT(distinct Product_Type_ID) > 1
			)

			<!--- *********** Get the details of the products with more than one discount type for same paid to --->
			select	BSA_Foodservice_Items_Master.Item, BSA_Foodservice_Items_Master.Description,
					Discount_Type.Discount_Type_Desc,
					##tmp_program_products.Component_Name, Payment_Paid_To_Types.Payment_Paid_To_Type_Name,
					cast(cast(##tmp_program_products.Rate as float) as decimal(20, 4)) as Rate, Units_of_Measure.Abbreviation
			from	tmp_dups

			inner join ##tmp_program_products
			on	##tmp_program_products.Component_Paid_To = tmp_dups.Component_Paid_To
			and	##tmp_program_products.BSA_Foodservice_Items_Master_ID = tmp_dups.BSA_Foodservice_Items_Master_ID

			inner join BSA_Foodservice_Items_Master
			on	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = ##tmp_program_products.BSA_Foodservice_Items_Master_ID

			left join Discount_Type
			on	Discount_Type.Discount_Type_ID = ##tmp_program_products.Product_Type_ID

			left join Payment_Paid_To_Types
			on	Payment_Paid_To_Types.Payment_Paid_To_Type_ID = ##tmp_program_products.Component_Paid_To

			left join Units_of_Measure
			on	Units_of_Measure.Unit_of_Measure_ID = ##tmp_program_products.Unit_Of_Measure_ID

			Order By BSA_Foodservice_Items_Master.Item, BSA_Foodservice_Items_Master.Description, Discount_Type.Discount_Type_Desc, Payment_Paid_To_Types.Payment_Paid_To_Type_Name

		</cfquery>

		<cfreturn qGetProgramProductsPaidToWithDuplicateDiscountTypes />

	</cffunction>

	<cffunction name="setApprovedMarginData" output="false" returntype="boolean">
		<cfargument name="ContractMainID" required="true" type="numeric" />
		<cfset returnValue = 0>
		<!---  ----------------------------------------------------------------------------------------------------------------
			Copy the margin from Contract_Product_Margin when program is approved into Contract_Product_Margin_Approved table,
			only if there is no entry for the program in the Contract_Product_Margin_Approved table.
		--->
		<cfquery name="qApprovedMargin" datasource="#application.datasource#">
			SELECT	COUNT(Contract_Main_ID) as Count
			FROM 	Contract_Product_Margin_Approved
			WHERE	Deleted = 0
			AND	Contract_Main_ID = <cfqueryparam value="#arguments.ContractMainID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

		<cfif qApprovedMargin.Count eq 0>
			<cfquery name="qCopyApprovedMargin" datasource="#application.datasource#">
				INSERT INTO Contract_Product_Margin_Approved
						(Contract_Product_Margin_ID, Contract_Product_ID, Contract_Main_ID, Product_Type_ID, Unit_Of_Measure, Contract_Start_Date, Contract_End_Date, FPR_LB, FPR_CS, FPV_LB, FPV_CS, FPE, FPM, FMW, RER_LB, RER_CS, REV_LB, REV_CS, REE, REM, RMW, TLS, GRR_LB, GRR_CS, GRV_LB, GRV_CS, GEE, GRM, GMW, PTER, PTEC, PTRM, PTTM, PLF_LB, PLF_CS, PLB_LB, PLB_CS, TFV, CCL, NCA, ICC, INW, ACC, CREATED_DATE, UPDATED_DATE, Deleted, TPA, KPR_LB, KPR_CS, KPV_LB, KPV_CS, KPE, KPM, KMW, OER_LB, OER_CS, OEV_LB, OEV_CS, OEE, OEM, OMW, BPR_LB, BPR_CS, BPV_LB, BPV_CS, BPE, BPM, BMW, QPR_LB, QPR_CS, QPV_LB, QPV_CS, QPE, QPM, QMW, Product_Id, Base_Sales_LB, Base_Sales_CS, Cash_discount_LB, Cash_discount_CS, Net_Sales_LB, Net_Sales_CS, Cost_LB, Cost_CS, Item_Allowance_LB, Item_Allowance_CS, Base_Discount_LB, Base_Discount_CS, LumpsumAmount_LB, LumpsumAmount_CS, Diff_Fixed_Price_LB, Diff_Fixed_Price_CS, Diff_Formula_Price_LB, Diff_Formula_Price_CS, Item_Deliverytype, ProductVolume_LB, ProductVolume_CS, Net_Weight, TPA_Growth_Rate, TargetMargin, TPA_CS, TPA_LB, Operating_Income_CS, Operating_Income_LB, OperatingMargin_CS, OperatingMargin_LB, OperatingMargin_percent, Product_Program_Volume_LB, Product_Program_Volume_CS, FPR_STAT, RER_STAT, GRR_STAT, KPR_STAT, OER_STAT, QPR_STAT, Base_Sales_STAT, Cash_discount_STAT, Net_Sales_STAT, Cost_STAT, Item_Allowance_STAT, Base_Discount_STAT, LumpsumAmount_STAT, Diff_Fixed_Price_STAT, Diff_Formula_Price_STAT, ProductVolume_STAT, TPA_STAT, Operating_Income_Stat, OperatingMargin, Product_Program_Volume_STAT, Contribution_Margin_CS, Contribution_Margin_LB, Contribution_Margin_percent, Cost2_LB, Cost2_CS, Customer_Freight, Group_Id, Fixed_Price_Rebate_Type, Formula_Price_Rebate_Type, Bid_Price_Rebate_Type, Spend_Dollar_LB, Spend_Dollar_CS, stock_price, PullbackAmount_CS, PullbackAmount_LB, PullbackAmount_STAT, Broker_Base_CS, Brokerage_Rate, Broker_Cost_CS, Broker_Cost_LB, Program_Price_LB, Total_Allowance_Distributor, Total_Allowance_Operator, Total_Allowance_Broker, Net_Price_LB, Net_Price_CS, Program_Fixed_Price_CS, Program_Fixed_Price_LB, Used_Net_Price, Used_Fixed_Price, Trade_CS, Trade_LB, Trade_STAT, Trade_Percent, Annualized_Allowance_CS, Annualized_Allowance_LB, Annualized_Allowance_Stat, Annualized_Lumpsum_Allowance_CS, Annualized_Lumpsum_Allowance_LB, Annualized_Lumpsum_Allowance_Stat,
						Allowance_Surcharges_CS, Allowance_Surcharges_LB, Allowance_Surcharges_STAT,
						Customer_Freight_CS, Customer_Freight_LB, Customer_Freight_STAT,
						Other_Spend_CS, Other_Spend_LB, Other_Spend_STAT,
						Cost_COGS_CS, Cost_COGS_LB, Cost_COGS_STAT,
						Cost_Manufacturing_Variance_CS, Cost_Manufacturing_Variance_LB, Cost_Manufacturing_Variance_STAT,
						Shuttle_Freight_CS, Shuttle_Freight_LB, Shuttle_Freight_STAT,
						Custom_Warehouse_CS, Custom_Warehouse_LB, Custom_Warehouse_STAT,
						Custom_Brokerage_CS, Custom_Brokerage_LB, Custom_Brokerage_STAT,
						MAP_MDF_CS, MAP_MDF_LB, MAP_MDF_STAT,
						SGA_CS, SGA_LB, SGA_STAT,
						TPA_Oper_CS, TPA_Oper_LB, TPA_Oper_STAT,
						Gross_Margin_CS, Gross_Margin_LB, Gross_Margin_STAT,
						Contribution_Margin_Alt_CS, Contribution_Margin_Alt_LB, Contribution_Margin_Alt_STAT,
						Variable_Contribution_Margin_CS, Variable_Contribution_Margin_LB, Variable_Contribution_Margin_STAT,Blanket_Bid_CS, Blanket_Bid_LB,
                        Ideal_Price_CS, Ideal_Price_LB, Ideal_Price_STAT)
				SELECT	Contract_Product_Margin_ID, Contract_Product_ID, Contract_Main_ID, Product_Type_ID, Unit_Of_Measure, Contract_Start_Date, Contract_End_Date, FPR_LB, FPR_CS, FPV_LB, FPV_CS, FPE, FPM, FMW, RER_LB, RER_CS, REV_LB, REV_CS, REE, REM, RMW, TLS, GRR_LB, GRR_CS, GRV_LB, GRV_CS, GEE, GRM, GMW, PTER, PTEC, PTRM, PTTM, PLF_LB, PLF_CS, PLB_LB, PLB_CS, TFV, CCL, NCA, ICC, INW, ACC, CREATED_DATE, UPDATED_DATE, Deleted, TPA, KPR_LB, KPR_CS, KPV_LB, KPV_CS, KPE, KPM, KMW, OER_LB, OER_CS, OEV_LB, OEV_CS, OEE, OEM, OMW, BPR_LB, BPR_CS, BPV_LB, BPV_CS, BPE, BPM, BMW, QPR_LB, QPR_CS, QPV_LB, QPV_CS, QPE, QPM, QMW, Product_Id, Base_Sales_LB, Base_Sales_CS, Cash_discount_LB, Cash_discount_CS, Net_Sales_LB, Net_Sales_CS, Cost_LB, Cost_CS, Item_Allowance_LB, Item_Allowance_CS, Base_Discount_LB, Base_Discount_CS, LumpsumAmount_LB, LumpsumAmount_CS, Diff_Fixed_Price_LB, Diff_Fixed_Price_CS, Diff_Formula_Price_LB, Diff_Formula_Price_CS, Item_Deliverytype, ProductVolume_LB, ProductVolume_CS, Net_Weight, TPA_Growth_Rate, TargetMargin, TPA_CS, TPA_LB, Operating_Income_CS, Operating_Income_LB, OperatingMargin_CS, OperatingMargin_LB, OperatingMargin_percent, Product_Program_Volume_LB, Product_Program_Volume_CS, FPR_STAT, RER_STAT, GRR_STAT, KPR_STAT, OER_STAT, QPR_STAT, Base_Sales_STAT, Cash_discount_STAT, Net_Sales_STAT, Cost_STAT, Item_Allowance_STAT, Base_Discount_STAT, LumpsumAmount_STAT, Diff_Fixed_Price_STAT, Diff_Formula_Price_STAT, ProductVolume_STAT, TPA_STAT, Operating_Income_Stat, OperatingMargin, Product_Program_Volume_STAT, Contribution_Margin_CS, Contribution_Margin_LB, Contribution_Margin_percent, Cost2_LB, Cost2_CS, Customer_Freight, Group_Id, Fixed_Price_Rebate_Type, Formula_Price_Rebate_Type, Bid_Price_Rebate_Type, Spend_Dollar_LB, Spend_Dollar_CS, stock_price, PullbackAmount_CS, PullbackAmount_LB, PullbackAmount_STAT, Broker_Base_CS, Brokerage_Rate, Broker_Cost_CS, Broker_Cost_LB, Program_Price_LB, Total_Allowance_Distributor, Total_Allowance_Operator, Total_Allowance_Broker, Net_Price_LB, Net_Price_CS, Program_Fixed_Price_CS, Program_Fixed_Price_LB, Used_Net_Price, Used_Fixed_Price, Trade_CS, Trade_LB, Trade_STAT, Trade_Percent, Annualized_Allowance_CS, Annualized_Allowance_LB, Annualized_Allowance_Stat, Annualized_Lumpsum_Allowance_CS, Annualized_Lumpsum_Allowance_LB, Annualized_Lumpsum_Allowance_Stat,
				Allowance_Surcharges_CS, Allowance_Surcharges_LB, Allowance_Surcharges_STAT,
				Customer_Freight_CS, Customer_Freight_LB, Customer_Freight_STAT,
				Other_Spend_CS, Other_Spend_LB, Other_Spend_STAT,
				Cost_COGS_CS, Cost_COGS_LB, Cost_COGS_STAT,
				Cost_Manufacturing_Variance_CS, Cost_Manufacturing_Variance_LB, Cost_Manufacturing_Variance_STAT,
				Shuttle_Freight_CS, Shuttle_Freight_LB, Shuttle_Freight_STAT,
				Custom_Warehouse_CS, Custom_Warehouse_LB, Custom_Warehouse_STAT,
				Custom_Brokerage_CS, Custom_Brokerage_LB, Custom_Brokerage_STAT,
				MAP_MDF_CS, MAP_MDF_LB, MAP_MDF_STAT,
				SGA_CS, SGA_LB, SGA_STAT,
				TPA_Oper_CS, TPA_Oper_LB, TPA_Oper_STAT,
				Gross_Margin_CS, Gross_Margin_LB, Gross_Margin_STAT,
				Contribution_Margin_Alt_CS, Contribution_Margin_Alt_LB, Contribution_Margin_Alt_STAT,
				Variable_Contribution_Margin_CS, Variable_Contribution_Margin_LB, Variable_Contribution_Margin_STAT,Blanket_Bid_CS, Blanket_Bid_LB,
                Ideal_Price_CS, Ideal_Price_LB, Ideal_Price_STAT
				FROM 	Contract_Product_Margin
				WHERE	Deleted = 0
				AND	Contract_Main_ID = <cfqueryparam value="#arguments.ContractMainID#" cfsqltype="CF_SQL_INTEGER">
				ORDER BY Created_Date DESC
			</cfquery>

			<cfquery name="marginComparsion" datasource="#application.datasource#" >
				UPDATE Contract_Product_Margin_Approved
				SET Cust_T_Target = MTU.Net_Sales_Target_Value, Cust_T_Floor = MTU.Net_Sales_Floor_Value,
					Cust_GM_Target = MTU.GM_Target_Value, Cust_GM_Floor = MTU.GM_Floor_Value
				FROM Margin_Targets_Upload MTU
				INNER JOIN Contract_Product_Margin_Approved CPMA
				ON CPMA.Product_ID = MTU.BSA_Foodservice_Items_Master_ID
				WHERE CPMA.Contract_Main_ID =  <cfqueryparam value="#arguments.ContractMainID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
                
			<cfset returnValue = 1>
		</cfif>
		<cfreturn returnValue />
	</cffunction>

	<cffunction name="bProgramHasBillback" output="false" returntype="boolean">

		<cfargument name="contractMainID" type="numeric" required="true" default="" />

		<cfscript>
			nContractMainID = 0;
			bRetValue = false;

			nContractMainID	=	arguments.contractMainID;
		</cfscript>

		<cfquery name="qCheckBillbackProgram" datasource="#application.datasource#">
			SELECT	cm.Contract_Main_ID, cm.Contract_Number, bp.Program_ID, b.BB_Code
			FROM	Contract_Main cm
					INNER JOIN Billback_Program bp ON bp.Program_ID = cm.Contract_Main_ID AND bp.Deleted = 0
					INNER JOIN Billback b ON b.Billback_ID = bp.Billback_ID AND b.Billback_Status_ID >= 3 AND b.Billback_Status_ID <> 8 AND b.Deleted = 0
					INNER JOIN BB_Approved ba ON ba.billback_id = b.billback_id
			WHERE	cm.Contract_Number = (SELECT Contract_Number FROM Contract_Main WHERE Contract_Main_ID = '#nContractMainID#')
			AND		cm.Approved = 1
			AND		cm.Contract_Status_Type_IDX >= 3
		</cfquery>

		<cfif qCheckBillbackProgram.RecordCount>
			<cfset bRetValue = true />
		</cfif>

		<cfreturn bRetValue />

	</cffunction>

	<!--- If no templates have Bid feature ON AND there are no programs in "Lost" or "Pending Accept" status,
	then Bid feature is OFF.
	--->
	<cffunction name="getIsBidFeatureOn" output="false" returntype="boolean">

		<cfset var bBidFeatureOn = 0>

		<!--- Check for at least one template which has Bid feature ON. --->
		<cfset useLakebaseForqIsBidTemplate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForqIsBidTemplate>
	<cftry>
		<cfset qIsBidTemplate = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"deleted" = "eq.0",
				"isdominant" = "eq.1",
				"bidrequeststatuson" = "eq.1",
				"limit" = "1",
				"select" = "programcontrol_panel_options_id"
			}), "programcontrol_panel_options_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqIsBidTemplate = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqIsBidTemplate>
<cfquery name="qIsBidTemplate" datasource="#application.datasource#">
			SELECT TOP 1 ProgramControl_Panel_Options_ID
			FROM Program_Control_Panel_Options
			WHERE deleted = 0
			AND IsDominant = 1
			AND BidRequestStatusOn = 1
		</cfquery>
</cfif>

		<cfset bBidFeatureOn = qIsBidTemplate.recordcount>

		<cfif qIsBidTemplate.recordcount eq 0>
			<!--- Check for at least one program which is in "Lost" or "Pending Accept" status. --->
			<cfquery name="qIsBidProgram" datasource="#application.datasource#">
				SELECT TOP 1 Contract_Main_ID
				FROM  Contract_Main
				WHERE Contract_Status_Type_IDX in (8,10)
				AND deleted = 0
			</cfquery>

			<cfset bBidFeatureOn = qIsBidProgram.recordcount>
		</cfif>

		<cfreturn bBidFeatureOn />

	</cffunction>

	<!--- START: 47231: Program LH link called EZ Rate/Anand Rao/05-Jan-2015
					Insert the EZ template values into the Program_Template_EZ_Rate Table after approval
	--->

	<cffunction name="updEZProgramProducts" output="false" returntype="boolean">

		<cfargument name="contractMainID" type="numeric" required="true" default="" />
		<cfset bRetValue = 0 />
		<cfquery name="ProgramEZRates" datasource="#application.datasource#">
			SELECT	*
			FROM	DBO.UDF_EZ_GET_PROGRAM_PRODUCTS (#arguments.contractMainID#, 'RETURN_ALL', #request.AccessStructure.Profiles_ID#)
			ORDER BY item
		</cfquery>
		<cfif (ProgramEZRates.Recordcount NEQ 0)>
		<!---  Delete all the rows, if they already exists for the same contract numbers, incase of Reset and Approve Programs. --->
			<cfquery name="delProgramEZRates" datasource="#application.datasource#">
				DELETE FROM Program_Template_EZ_Rate WHERE Contract_Main_ID = #arguments.contractMainID#
			</cfquery>

			<cfloop query = "ProgramEZRates">
				<cfquery name="insProgramEZRates" datasource="#application.datasource#">
				INSERT INTO Program_Template_EZ_Rate
				(
					Contract_Main_ID,
					Product_ID,
					Template_EZ_Rate,
					Template_EZ_Rate_UOM,
					Program_EZ_Rate,
					Program_EZ_Rate_UOM,
					Variance,
					Created_Date
				)
				VALUES
				(
					#arguments.contractMainID#,
					'#ProgramEZRates.BSA_Foodservice_Items_Master_ID#',
					#ProgramEZRates.ez_rate#,
					#ProgramEZRates.ez_uom#,
					#ProgramEZRates.Program_rate#,
					#ProgramEZRates.program_uom#,
					#ProgramEZRates.variance#,
					GetDate()
				)
				</cfquery>
			</cfloop>
			<cfset bRetValue = 1 />
		</cfif>

		<cfreturn bRetValue />

	</cffunction>

	<cffunction name="getContractVersions" output="false" returntype="any">

		<cfargument name="contractMainID" type="numeric" required="true" default="" />

		<cfquery name="lstContractVersions" datasource="#application.datasource#">
			SELECT Distinct
				U1.name_first + ''  + U1.name_last as created_user,
				U2.name_first + ' ' + U2.name_last as approved_user,
				PF.Profiles_Desc,
				CM.contract_number + '-' + CASE
									WHEN LEN(CM.revision_version) = 4 THEN RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 4)
									WHEN LEN(CM.revision_version) = 5 THEN RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 5)
									ELSE RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 3)
								END AS Program_Number_Full,
				CM.contract_number AS Program_Number,
				CM.revision_version, CM.Contract_Main_ID, CM.Contract_Title,
				CM.contract_Start_Date, CM.contract_End_Date, CM.Approval_Date,
				CM.Contract_Status_Type_IDX, CM.preactive_expired, CM.is_a_revision,
				isnull(CMAD.Freight_Component_Type, 0) as Freight_Component_Type,
				isnull(CM.renewal_of_contract_main_ID, 0) as Copied_Program_ID,
				isnull(CM2.revision_version, 0) as Copied_Version,
				isnull((CM2.contract_number + '-' + CASE
									WHEN LEN(CM.revision_version) = 4 THEN RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 4)
									WHEN LEN(CM.revision_version) = 5 THEN RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 5)
									ELSE RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 3)
								END as Copied_Contract_Number,
				CST.Contract_Status_Type_Desc
			FROM contract_main CM
			LEFT JOIN contract_main_aux_data CMAD ON CM.contract_main_id = CMAD.contract_main_id
			LEFT JOIN contract_main CM2 ON isnull(CM.renewal_of_contract_main_ID, 0) = CM2.contract_main_id
			INNER JOIN _users U1 ON U1.user_id = CM.creator_id
			LEFT JOIN _users U2 ON U2.user_id = CM.Approved_By_User_ID
			INNER JOIN Contract_Status_Types CST ON CST.Contract_Status_Type_ID = CM.Contract_Status_Type_IDX
			LEFT JOIN Profiles PF ON PF.Profiles_ID = U2.Profiles_ID
			WHERE CM.contract_number in (SELECT Contract_Number From Contract_Main WHERE Contract_Main_ID = #arguments.contractMainID#)
		 	AND CM.Contract_Status_Type_IDX >= 2
			--AND CM.revision_version != 0
			ORDER BY CM.Contract_Main_ID DESC
 	</cfquery>
	<cfreturn lstContractVersions />

	</cffunction>


		<cffunction name="getProgramInfoComplete" output="true" returntype="query">

		<cfargument name="programId" required="true" type="numeric" />

		<cfquery name="qGetProgramInfo" datasource="#application.datasource#">
			SELECT	CM.ProgramType_ID,
					CM.Line_Of_Business_Id,
					CM.Contract_Number,
					CM.contract_number + '-' + CASE
									WHEN LEN(CM.revision_version) = 4 THEN RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 4)
									WHEN LEN(CM.revision_version) = 5 THEN RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 5)
									ELSE RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 3)
								END AS Program_Number_Full,
					CM.Contract_Number AS Program_Number,
					CM.Contract_Title,
					CM.Contract_Start_Date,
					CM.Contract_End_Date,
					CM.Contract_Created_Date,
					CM.Approval_Date,
					CM.Responsible_User_ID,
					CM.Creator_ID,
					CM.Approved_By_User_ID,
					CM.Contract_Status_Type_IDX,
					CM.Contract_Reference_Number,
					PCPO.Restrict_On_Approval_Group,
					PCPO.Created_Type,
					U1.Name_First + ' ' + U1.Name_Last AS RSP_Name,
					U2.Name_First + ' ' + U2.Name_last AS Approved_User,
					U3.Name_First + ' ' + U3.Name_last AS Created_User,
					PF.Profiles_Desc,
					PCPO.Display_Blanket_Bid As Blanket_Bid_Template,
					CM.Is_Blanket_Bid As Blanket_Bid_Program,
					aux.Override_Price_List_Id,
					aux.Gpo_Price_List_Id,
					aux.NonGpo_Price_List_Id
			FROM	Contract_Main CM
					inner join Contract_Main_Aux_Data aux on
						aux.Contract_Main_ID = cm.Contract_Main_ID
					INNER JOIN Program_Control_Panel_Options PCPO ON
						PCPO.ProgramControl_Panel_Options_ID = CM.ProgramType_ID
					INNER JOIN _Users U1 ON
						CM.Responsible_user_ID = U1.User_ID
					LEFT JOIN _Users U2 ON
						U2.User_ID = CM.Approved_By_User_ID
					LEFT JOIN Profiles PF ON
						PF.Profiles_ID = U2.Profiles_ID
					INNER JOIN _Users U3 ON
						U3.User_ID = CM.Creator_ID
			WHERE	CM.Contract_Main_ID = #arguments.programId#
		</cfquery>

		<cfreturn qGetProgramInfo>

	</cffunction>

	<cffunction name="getProgramVersionsWithinEffectiveDates" access="public" returntype="string" output="false">
		<cfargument name="Contract_Main_ID" type="string" required="true" />
		<cfargument name="start_Date"  required="true" />
		<cfargument name="end_Date" required="true" />

		<cfset var prgList = "">

		<CFQUERY NAME="qGetProgramVersionsWithinEffectiveDates" datasource="#application.datasource#">
			SELECT Contract_Main_ID
			FROM Contract_Main
			WHERE Contract_Number =
			(
				SELECT Contract_Number
				FROM Contract_Main
				WHERE Contract_Main_ID = '#arguments.Contract_Main_ID#'
			)
			<!--- Below logic is the overlap logic --->
			AND Effective_Start_Date <= #CreateODBCDate(arguments.end_date)#
			AND Effective_End_Date >= #CreateODBCDate(arguments.start_date)#
		</CFQUERY>

		<cfset prgList = ValueList(qGetProgramVersionsWithinEffectiveDates.Contract_Main_ID)>

		<cfreturn prgList>
	</cffunction>

	<cffunction name="getProgramEffectiveDateSpan" output="false" returntype="query">
		<cfargument name="ContractNumber" type="string" required="true" />
			<cfquery name="qgetProgramEffectiveDateSpan" datasource="#application.datasource#">
				SELECT Min(Effective_Start_Date) as Start_Date, Max(Effective_End_Date) as End_Date
				FROM	 contract_main
				WHERE Contract_Number = '#arguments.ContractNumber#'
			</cfquery>
		<cfreturn qgetProgramEffectiveDateSpan />
	</cffunction>
<!---76380 decimal places START--->
		<cffunction name="decimalPrecisionByUOM" output="true" returntype="string">
			<cfargument name="UOM" required="true" type="any" />
			<cfargument name="type" required="true" type="numeric" />
			<cfargument name="formulaPrice" required="false" type="boolean" default="false" />

			<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
			<cfset appSettings = genSettingsManager.get()>

			<cfset arguments.UOM = val(arguments.UOM)>
			<cfset decimalprecision = '9.'>
			<cfset decimalformat = 0>
			<cfif arguments.UOM EQ '1'> <!---- CS---->
				<cfif arguments.formulaPrice>
					<cfif not StructKeyExists(request, "Formula_Pricing_Round_For_CS")>
						<cfset request.Setting_Decimal_display_for_CS = appSettings.get_Setting('Formula_Pricing_Round_For_CS') />
					</cfif>
				<cfelse>
					<cfif not StructKeyExists(request, "Setting_Decimal_display_for_CS")>
						<cfset request.Setting_Decimal_display_for_CS = appSettings.get_Setting('Decimal_display_for_CS') />
					</cfif>
				</cfif>
				<cfset decimalformat = request.Setting_Decimal_display_for_CS >
				<cfloop from="1" to="#decimalformat#" index="a">
					<cfset decimalprecision = decimalprecision&9>
				</cfloop>
			<cfelseif arguments.UOM EQ '2'><!---- LBS ---->
				<cfif arguments.formulaPrice>
					<cfif not StructKeyExists(request, "Formula_Pricing_Round_For_LB")>
						<cfset request.Setting_Decimal_display_for_LB = appSettings.get_Setting('Formula_Pricing_Round_For_LB') />
					</cfif>
				<cfelse>
					<cfif not StructKeyExists(request, "Setting_Decimal_display_for_LB")>
						<cfset request.Setting_Decimal_display_for_LB = appSettings.get_Setting('Decimal_display_for_LB') />
					</cfif>
				</cfif>
				<cfset decimalformat = request.Setting_Decimal_display_for_LB>
				<cfloop from="1" to="#decimalformat#" index="a">
					<cfset decimalprecision = decimalprecision&9>
				</cfloop>
			<cfelseif arguments.UOM EQ '3'><!----%---->
				<cfif not StructKeyExists(request, "Setting_Decimal_display_for_Percentage")>
					<cfset request.Setting_Decimal_display_for_Percentage = appSettings.get_Setting('Decimal_display_for_Percentage') />
				</cfif>
				<cfset decimalformat = request.Setting_Decimal_display_for_Percentage>
				<cfloop from="1" to="#decimalformat#" index="a">
					<cfset decimalprecision = decimalprecision&9>
				</cfloop>
			<cfelseif arguments.UOM EQ '5'><!----EA---->
				<cfif not StructKeyExists(request, "Setting_Decimal_display_for_EA")>
					<cfset request.Setting_Decimal_display_for_EA = appSettings.get_Setting('Decimal_display_for_EA') />
				</cfif>
				<cfset decimalformat = request.Setting_Decimal_display_for_EA>
				<cfloop from="1" to="#decimalformat#" index="a">
					<cfset decimalprecision = decimalprecision&9>
				</cfloop>
			<cfelseif arguments.UOM EQ '6'><!----CWT---->
				<cfif not StructKeyExists(request, "Setting_Decimal_display_for_CWT")>
					<cfset request.Setting_Decimal_display_for_CWT = appSettings.get_Setting('Decimal_display_for_CWT') />
				</cfif>
				<cfset decimalformat = request.Setting_Decimal_display_for_CWT>
				<cfloop from="1" to="#decimalformat#" index="a">
					<cfset decimalprecision = decimalprecision&9>
				</cfloop>
			<cfelse><!----Default---->
				<cfset decimalformat = '4'>
				<cfset decimalprecision = '9.9999'>
			</cfif>
		<cfif arguments.type EQ 1>
			<cfreturn decimalprecision>
		<cfelse>
			<cfreturn decimalformat>
		</cfif>
		</cffunction>
<!---76380 decimal places END--->

		<cffunction name="getIsRecaptureOperatorOnForAnyProgramRebateComponent" access="public" returntype="boolean" output="false">
			<cfargument name="programId" required="true" type="string">

			<cfset var bComponentExists = 0>

			<CFQUERY NAME="qGetIsRecaptureOperatorOnForAnyProgramRebateComponent" datasource="#application.datasource#">
				SELECT 1
				FROM Program_Rebates_Component prc
				INNER JOIN Program_Rebates_Component_Name prcn
				ON prc.Program_Rebates_Component_Name_ID = prcn.Program_Rebates_Component_Name_ID
				WHERE prc.Program_ID = '#arguments.programId#'
				AND prc.deleted = 0
				AND prcn.Alternate_Recapture_By_Operator = 1
			</CFQUERY>

			<cfif qGetIsRecaptureOperatorOnForAnyProgramRebateComponent.recordcount GT 0>
				<cfset bComponentExists = 1>
			</cfif>

			<cfreturn bComponentExists>
		</cffunction>

		<cffunction name="copyComponentFromSettings" access="remote" returnformat="JSON" output="false">
			<cfargument name="component_name_id" required="true" type="numeric">
			<cfargument name="discount_type_id" required="true" type="numeric">

			<CFSTOREDPROC PROCEDURE="Copy_Program_components" DATASOURCE="#application.datasource#">
				<cfprocparam type = "IN" dbVarName = "@component_name_id" value = "#arguments.component_name_id#" CFSQLType="CF_SQL_INTEGER">
				<cfprocparam type = "IN" dbVarName = "@discount_type" value = "#arguments.discount_type_id#" CFSQLType="CF_SQL_INTEGER">
				<cfprocparam type = "OUT" dbVarName = "@New_Component_ID" CFSQLType="CF_SQL_INTEGER" VARIABLE="New_Component_ID">
			</CFSTOREDPROC>

				<cfreturn serializeJSON(New_Component_ID) />
		</cffunction>

		<cffunction name="CheckProductGroupExistsOnProgram" access="public" returntype="boolean" output="false">
			<cfargument name="programId" required="true" type="string">

			<cfset local.bProductGroupExists = 0>

			<cfset useLakebaseForqCheckProductGroupExistsOnProgram = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForqCheckProductGroupExistsOnProgram>
	<cftry>
		<cfset qCheckProductGroupExistsOnProgram = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_products", {
				"contract_main_id" = "eq.#arguments.programId#",
				"deleted" = "eq.0",
				"is_group" = "eq.1",
				"limit" = "1",
				"select" = "contract_main_id"
			}), "contract_main_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckProductGroupExistsOnProgram = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckProductGroupExistsOnProgram>
<CFQUERY NAME="qCheckProductGroupExistsOnProgram" datasource="#application.datasource#">
				SELECT TOP 1 Contract_Main_ID
				FROM Contract_Products
				WHERE Contract_Main_ID = '#arguments.programId#'
				AND deleted = 0
				AND Is_Group = 1
			</CFQUERY>
</cfif>

			<cfif qCheckProductGroupExistsOnProgram.recordcount GT 0>
				<cfset local.bProductGroupExists = 1>
			</cfif>

			<cfreturn local.bProductGroupExists>
		</cffunction>

		<!--- Dev Note(79237) - When a 2nd Component (Child of the first component) exists, we need to make sure that the "paid to", Rate and UOM of the 2nd component matches the first component --->
		<cffunction name="updateSecondComponentRates" access="public" output="false">
			<cfargument name="programID" type="string" required="true">
			<cfargument name="DiscountType" type="string" required="true">
			<cfargument name="prodID" type="string" required="false" default="">

			<cfif application.appSettingsGet.get_Setting('Include_Second_Component_Feature') eq '1'>

			<cfif arguments.prodID neq "">
				<cfset arguments.prodID = Replace(arguments.prodID,"_","-","ALL")>
			</cfif>

				<cfstoredproc procedure="UPDATE_SECOND_COMPONENT_RATES" datasource="#application.datasource#">
					<cfprocparam type="IN" CFSQLType="CF_SQL_INTEGER" dbVarName="@programID" value="#arguments.programID#" null="no">
					<cfprocparam type="IN" CFSQLType="CF_SQL_INTEGER" dbVarName="@DiscountType" value="#arguments.DiscountType#" null="no">
					<cfif arguments.prodID neq "">
					<cfprocparam type="IN" CFSQLType="CF_SQL_VARCHAR" dbVarName="@ProductID" value="#arguments.prodID#">
					</cfif>
				</cfstoredproc>
			</cfif>
		</cffunction>

</cfcomponent>