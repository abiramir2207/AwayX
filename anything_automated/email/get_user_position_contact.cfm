
<!------ get_user_position_contact.cfm ----->
<cfparam name="CSL_Contract_Main_ID" default="0">
<cfparam name="sEmailAction" default="">
<cfparam name="checkRFANotificationEmail" default="0" />
<cfparam name="Setting_HQ_Send_Email_To_RSP_Only" default="0" />

<cfset HQ_Send_Email_To_RSP_Only = 0 />
<cfif Setting_HQ_Send_Email_To_RSP_Only>
	<cfif NOT isDefined("HQPosition")>
		<cfset HQPosition = CreateObject("component", "components.geography.position").getHQPosition() />
	</cfif>

	<!---  Check if Creating_User_Position_ID is HQ. If it is, then email should be sent to RSP only and not to 
	all the users in the HQ position. --->
	<cfif Creating_User_Position_ID EQ HQPosition.User_Positions_ID>
		<cfset HQ_Send_Email_To_RSP_Only = 1 />
	</cfif>
</cfif>

<cfset Contract_Resp_User_Class_Codes = "">
<cfif NOT isDefined("businessSegmentsOn")>
	<cfset userManager = CreateObject("component", "components.user.UserManager") />
	<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
	<cfset businessSegmentsOn = 0 />
	<cfif businessSegManager.isEnabled()>
		<cfset businessSegmentsOn = 1 />
	</cfif>
</cfif>
<cfif businessSegmentsOn>
	<cfif appSettings.getClassCodesOn()>
	<!------ Find the class codes the Contract_Responsible_User_ID has access to ----->
		<cfset qRespUserClassCodes = businessSegManager.getActiveClasscodes(Contract_Responsible_User_ID, 0)>
		<cfset Contract_Resp_User_Class_Codes = ValueList(qRespUserClassCodes.Class_Code_ID)>
	</cfif>
</cfif>

<cfparam name="CheckApprovalAccess" 	default="0">
				
<cfquery name="userPositionContactInfo" datasource="#application.datasource#">
	SELECT distinct  User_Positions.User_Positions_ID, User_Positions.Position_Label, ltrim(rtrim(_Users.User_Email)) User_Email, Profiles_Settings.Program_Scorecard_Restrict_Created_By
	FROM       	_Users 
				INNER JOIN	User_Position_Holders 
				ON _Users.User_ID = User_Position_Holders.User_ID 
				<!---BJF D10073 -- app setting to only email primary, vs primary and secondary positions --->
				<cfif appSettings.getsendsecondaryemail() EQ 0>
				AND User_Position_Holders.User_Position_Type <> 'S'
				</cfif>
				INNER JOIN	User_Positions 
				ON User_Position_Holders.User_Positions_ID = User_Positions.User_Positions_ID
				<cfif businessSegmentsOn>
				<cfif appSettings.getClassCodesOn()>
				INNER JOIN User_Class_Code 
				ON 	User_Class_Code.Deleted = 0
				AND User_Class_Code.User_ID = _Users.User_ID
				<cfif Len(Contract_Resp_User_Class_Codes) GT 0>
				AND User_Class_Code.Class_Code_ID IN (<cfqueryparam value="#Contract_Resp_User_Class_Codes#" cfsqltype="CF_SQL_INTEGER" list="Yes">)
				<cfelse>
				AND 1=2
				</cfif>
				<cfelse><!------ If shares same business segment ----->
				INNER JOIN User_Business_Segment 
				ON User_Business_Segment.Business_Segment_ID = <cfqueryparam value="#Contract_Business_Segment_ID#" cfsqltype="CF_SQL_INTEGER">
				AND User_Business_Segment.User_ID = _Users.User_ID
				AND User_Business_Segment.Deleted = 0 
				</cfif>
				</cfif>
				<!---Checks profile permissions--->
				INNER JOIN Profiles_Settings 
				ON Profiles_Settings.Profiles_ID = _Users.Profiles_ID
	WHERE     
				User_Positions.Deleted = 0
				AND User_Position_Holders.deleted = 0
				AND _Users.Deleted = 0
				AND User_Positions.User_Positions_ID = <cfqueryparam value="#Creating_User_Position_ID#" cfsqltype="CF_SQL_INTEGER">
				<!--- Dev Note: KAL; 7/2/2010; D23915: Single Instance Remote Approval --->
				<cfif checkRFANotificationEmail>
				AND	_Users.RFA_Notification_Email = 1 
				</cfif>				
				<cfset forbidType = appSettings.getForbidAllowProfilesInTemplates() />
				AND _Users.Profiles_ID 
				<cfif forbidType EQ 1>not</cfif><!------ forbit type=1, forbid, 0=allow ----->
				IN
				(
				select 	distinct profile_id 
				from 	Profile_Forbidden_Template 
				where 	Deleted = 0
						AND Forbid_Type = #forbidType#
						AND	Forbid_Access_Type = <cfif CheckApprovalAccess EQ 1>2<cfelse>1</cfif><!------ 1=Access,2=Approve ----->
						AND template_id = <cfqueryparam value="#Contract_Template_ID#" cfsqltype="CF_SQL_INTEGER">
				)
				<!--- This checks to make sure the profile can see programs for other users in the position, or is the creating user --->
			AND (Profiles_Settings.Program_Scorecard_Restrict_Created_By = 0 <Cfif isDefined("getThisProgramsStatusEmail.Creator_ID")>OR _Users.User_ID =  '#getThisProgramsStatusEmail.Creator_ID#'</CFIF>)
			<cfif CheckApprovalAccess EQ 1>
			AND	Profiles_Settings.Cont_Prog_View_Margins = 1
			AND Profiles_Settings.Cont_Prog_Approval_Rights = 1			
			</cfif>
			<cfif HQ_Send_Email_To_RSP_Only>
			AND _Users.User_ID = <cfqueryparam value="#Contract_Responsible_User_ID#" cfsqltype="CF_SQL_VARCHAR">
			</cfif>
</cfquery>

<cfquery name="getGSettings" datasource="#application.datasource#">
				SELECT
					send_daily_expiring_email,
					send_daily_expired_email,
					send_daily_active_email,
					send_daily_aging_billback_email,
					send_broker_email,
					send_Approve_email,
					Use_Discount_ID,
					Number_Of_Days_For_Summarized_Weekly_Expiring_Email,
					Send_Program_Starting_Email,
					Number_Of_Days_For_Program_Start
				FROM
					General_Settings
</cfquery>

<!------ if the setting says send_broker_email, add the broker too to the list, if the position is a market ----->
<cfif getGSettings.send_broker_email EQ 1>
	<cfset brokerEmailAddress = userManager.getBrokerEmailAddress(Creating_User_Position_ID, businessSegmentsOn, Contract_Business_Segment_ID) />
	<cfif Len(brokerEmailAddress) GT 0>
		<cfloop list="#brokerEmailAddress#" delimiters=";" index="thisBrokerEmail">
			<cfset thisBrokerEmail = trim(thisBrokerEmail)>
			<cfif FindNoCase("@", thisBrokerEmail)>
			<cfquery name="qGetEmailMatch" dbtype="query">
				SELECT 	*
				FROM	userPositionContactInfo
				WHERE	User_Email LIKE '%#thisBrokerEmail#%'
			</cfquery>
			<cfif NOT qGetEmailMatch.recordCount>
				<cfset QueryAddRow(userPositionContactInfo) />
				<cfset QuerySetCell(userPositionContactInfo, "User_Email", thisBrokerEmail) />
			</cfif>
			</cfif>
		</cfloop>
	</cfif>
</cfif>

	<cfif appSettings.getsenddistributorbrokeremail() EQ 1 and CSL_Contract_Main_ID NEQ 0 and sEmailAction EQ "approval">
	<cfquery name="getallBrokersEmailsforalldistributorsinprogram" datasource="#application.datasource#">
		select distinct _users.user_email from
		contract_distributors
		inner join bsa_foodservice_customers on bsa_foodservice_customers.bsa_foodservice_customers_id =
		contract_distributors.bsa_foodservice_customers_id
		inner join bsa_foodservice_brokers on bsa_foodservice_brokers.bsa_foodservice_brokers_id =
		bsa_foodservice_customers.bsa_foodservice_brokers_id
		inner join user_positions on user_positions.service_market_id =
		bsa_foodservice_brokers.service_market_id
		and user_positions.deleted = 0
		inner join user_position_holders on user_position_holders.user_positions_id =
		user_positions.user_positions_id
		and user_positions.service_region_id IS NOT NULL and user_positions.service_zone_id IS NOT NULL
		and user_position_holders.deleted = 0
		inner join _users on _users.user_id = user_position_holders.user_id
		and _users.deleted = 0
		where contract_distributors.deleted =0
		and contract_distributors.contract_main_id = <cfqueryparam value="#CSL_Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	
	<cfif getallBrokersEmailsforalldistributorsinprogram.recordcount GT 0>
		<cfloop query="getallBrokersEmailsforalldistributorsinprogram">
			<cfset thisBrokerEmail = trim(getallBrokersEmailsforalldistributorsinprogram.user_email)>
			<cfif FindNoCase("@", thisBrokerEmail)>
			<cfquery name="qGetEmailMatch" dbtype="query">
				SELECT 	*
				FROM	userPositionContactInfo
				WHERE
						User_Email LIKE '%#thisBrokerEmail#%'
			</cfquery>
			<cfif NOT qGetEmailMatch.recordCount>
				<cfset QueryAddRow(userPositionContactInfo) />
				<cfset QuerySetCell(userPositionContactInfo, "User_Email", thisBrokerEmail) />
			</cfif>
			</cfif>
		</cfloop>
	</cfif>
</cfif>

<cfset CheckApprovalAccess = 0 />
