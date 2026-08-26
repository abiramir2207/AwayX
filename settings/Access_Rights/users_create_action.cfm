<!---
***********************************************************************
Modified By: Milan Mushran
Modification: Send Email to the users, if allowed by the company's admin
Filename: users_create_action.cfm
Modified Date: 9/8/2004
Purpose: For creating new users
Modified By: Clarence Morse 3/24/2006
Purpose: enhancements to allow faxing of user information, default
password and welcome letter.
***********************************************************************
--->
<cfset UsersIP = CGI.Remote_Addr>
<CFPARAM NAME="FORM.User_ID"	 					DEFAULT="">
<CFPARAM NAME="FORM.User_Number"	 				DEFAULT="">
<CFPARAM NAME="FORM.NAME_FIRST" 					DEFAULT="">
<CFPARAM NAME="FORM.NAME_LAST" 						DEFAULT="">
<CFPARAM NAME="FORM.TITLE" 							DEFAULT="">
<CFPARAM NAME="FORM.User_Authority_Sequence_ID" 	DEFAULT="0">
<CFPARAM NAME="FORM.WORK_ADDRESS_1" 				DEFAULT="">
<CFPARAM NAME="FORM.WORK_ADDRESS_2" 				DEFAULT="">
<CFPARAM NAME="FORM.WORK_CITY" 						DEFAULT="">
<CFPARAM NAME="FORM.WORK_STATE" 					DEFAULT="">
<CFPARAM NAME="FORM.WORK_ZIP" 						DEFAULT="">
<CFPARAM NAME="FORM.WORK_Country_Code"			 	DEFAULT="">
<CFPARAM NAME="FORM.WORK_PHONE_1" 					DEFAULT="">
<CFPARAM NAME="FORM.WORK_PHONE_2" 					DEFAULT="">
<CFPARAM NAME="FORM.WORK_PHONE_3" 					DEFAULT="">
<CFPARAM NAME="FORM.WORK_PHONE_Ext"					DEFAULT="">
<CFPARAM NAME="FORM.WORK_FAX_1" 					DEFAULT="">
<CFPARAM NAME="FORM.WORK_FAX_2" 					DEFAULT="">
<CFPARAM NAME="FORM.WORK_FAX_3" 					DEFAULT="">
<CFPARAM NAME="FORM.WORK_EMAIL" 					DEFAULT="">
<CFPARAM NAME="FORM.User_Profile_ID" 				DEFAULT="">
<CFPARAM NAME="FORM.Company_Main_ID"				DEFAULT="">
<CFPARAM NAME="FORM.USER_POSITIONS_ID"				DEFAULT="">
<CFPARAM NAME="USER_SEC_POSITIONS_ID"				DEFAULT="">
<CFPARAM NAME="FORM.Company_Name"					DEFAULT="">
<CFPARAM NAME="FORM.IS_ELIGIBLE_RSP"				DEFAULT="1">
<CFPARAM NAME="FORM.Is_On_Behalf_Of"				DEFAULT="0">
<CFPARAM NAME="FORM.Crucible_File_Download"			DEFAULT="0">
<CFPARAM NAME="FORM.User_Class_Code_ID" 			DEFAULT="">
<CFPARAM NAME="FORM.User_Business_Segment_ID" 		DEFAULT="">
<CFPARAM NAME="Form.User_Positions_List" 			DEFAULT="">
<CFPARAM NAME="FORM.ClassCodesOn" 					DEFAULT="">
<CFPARAM NAME="FORM.Line_of_Business_ID" 			DEFAULT="">
<CFPARAM NAME="FORM.Type_Code_ID"					DEFAULT="">
<CFPARAM NAME="FORM.IS_USDA_USER"					DEFAULT="0">
<CFPARAM NAME="FORM.user_usda_state_id"				DEFAULT="0">
<CFPARAM NAME="FORM.user_usda_county_id"			DEFAULT="0">
<CFPARAM NAME="FORM.user_usda_operator_id"			DEFAULT="0">
<CFPARAM NAME="FORM.user_usda_distributor_id_list"	DEFAULT="Null">
<CFPARAM NAME="FORM.user_usda_broker_id_list"		DEFAULT="Null">
<CFPARAM NAME="FORM.user_usda_operator_id_list"		DEFAULT="Null">
<CFPARAM NAME="FORM.activateuser" 					default="0">
<!--- Dev Note: Clay 9254 - Send_Welcome_Letter 1 = Send Email, 0 = Send Fax --->
<CFPARAM NAME="FORM.SEND_WELCOME_LETTER"			DEFAULT="1">
<CFPARAM NAME="FORM.blacksmith_user" 				DEFAULT="0" />
<CFPARAM NAME="FORM.user_language"					DEFAULT="English" />
<CFPARAM NAME="FORM.LDAP_User_Name" 				DEFAULT="" />
<CFPARAM NAME="form.Analytics_SSO_User_Name"		DEFAULT="" />
<!--- Dev Note: KAL; 7/1/2010; D23915: Single Instance Remote Approval --->
<CFPARAM NAME="FORM.RFA_Notification_Email" 		DEFAULT="1" />
<CFPARAM NAME="FORM.Remote_Approval_Option" 		DEFAULT="0" />
<CFPARAM NAME="FORM.BB_Remote_Approval_Option" 		DEFAULT="0" />
<CFPARAM NAME="FORM.User_Rights_ID" 				DEFAULT="1000" />
<CFPARAM NAME="FORM.upateAccessRights" 				DEFAULT="0" />
<CFPARAM NAME="FORM.Ember_Info"	DEFAULT="0" /><!--- 72497  --->

<cfif len(trim(FORM.user_usda_distributor_id_list)) IS 0>
	<cfset FORM.user_usda_distributor_id_list = "null">
</cfif>
<cfset primaryindex = ListFind(Form.User_Positions_List, form.USER_POSITIONS_ID)>
<cfset USER_SEC_POSITIONS_ID =  ListDeleteAt(Form.User_Positions_List, primaryindex)>
<cfif form.IS_ELIGIBLE_RSP eq 0>
	<cfset form.Is_On_Behalf_Of = 0 />
</cfif>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset oLDAPSettingsManager = createObject("component", "components.settings.LDAPSettingsManager").init() />
<cfset variables.qGetLDAPSettings = oLDAPSettingsManager.getLDAPSettings() />
<!---
Dev Notes: D24468/Anand Rao/17-Aug-10
URL on email notifications
--->
<cfset siteURL = application.HTTPVar & CGI.SERVER_NAME />
<CFIF FORM.UPDATERECORD EQ 0>
	<CFSET IDGENERATOR_GENERATEDIDVARIABLENAME = "Generated.User_ID">
	<CFSET IDGENERATOR_DESTINATIONTABLE = "_Users">
	<CFSET IDGENERATOR_DESTINATIONFIELD = "User_ID">
	<CFINCLUDE TEMPLATE="/common_files/keyGenerator.cfm">
	<cfif appSettings.getDefaultPasswordOn() EQ 0>
		<!--- Login info --->
		<CFSET alphastring = "ABCDEFGHIJKLMNOPQRSTUVWXYZ">
		<cfset tempPassword ="">
		<CFLOOP INDEX="LoopCount" FROM="1" TO="10" STEP="1">
			<CFSET tempPassword=tempPassword&mid(alphastring, randrange(1, len(alphastring)), 1)>
		</CFLOOP>
	<cfelse>
		<!--- Dev Note: Clay 9254 - If getDefaultPassword is on use the encrypted password from Db --->
		<cfinvoke component="components.settings.encryption" method="getPasswordKey" returnvariable="cryp_key" />
		<cf_cryp string="#appSettings.getDefaultPasswordForNewUsers()#" type="de" key="#cryp_key#">
		<cfset tempPassword = cryp.value />
	</cfif>
	<!--- Generate a new pin and encode it --->
	<cfset tempPin ="">
	<cfset hashPin = ""/>
	<cfif appSettings.getApprovalViaEmail() or appSettings.get_Setting('BB_Approval_Via_Email') >
		<cfset variables.pinMinLength = appSettings.getPinMinLength() />
		<cfset numString = "0123456789">
		<cfloop index="LoopCount" from="1" to="#variables.pinMinLength#" step="1">
			<cfset tempPin = tempPin&mid(numString, randrange(1, len(numString)), 1)>
		</cfloop>
		<cfset hashPin = hash(tempPin) />
	</cfif>
	<!---27172 - Include middle initial in the user code--->
	<cfif appSettings.getUserAccountMiddleInitial()>
		<cfset vars.middle_initial = form.name_middle_initial>
	<cfelse>
		<cfset vars.middle_initial = ''>
	</cfif>
	<cfset usernameString = lcase(left(trim(FORM.NAME_FIRST),1) & trim(vars.middle_Initial) & trim(FORM.NAME_LAST))>
	<cfset trailingNumber = 1>
	<cfset StopLoop = 0>
	<cfloop CONDITION="StopLoop EQ 0">
		<cfset concat_username = usernameString & trailingNumber>
		<cfquery NAME="checkForDuplicateUsername" datasource="#application.datasource#">
			SELECT User_Code
			FROM _Users
			WHERE lower(user_code) = '#concat_username#'
		</cfquery>
		<cfset trailingNumber = trailingNumber + 1>
		<cfif checkForDuplicateUsername.recordcount EQ 0><cfset StopLoop = 1></cfif>
	</cfloop>
	<CFQUERY NAME="saveUser" datasource="#application.datasource#">
		INSERT INTO	_Users
		(
		User_Code,
		User_Password,
		User_Pin,
		User_ID,
		LDAP_User_Name,
		Analytics_SSO_User_Name,
		Profiles_ID,
		Name_First,
		Name_Last,
		Company_Main_ID,
		Title,
		Authority_Sequence_ID,
		Work_Address_1,
		Work_Address_2,
		Work_City,
		Work_State,
		Work_Zip,
		work_Country_Code,
		Work_Phone_1,
		Work_Phone_2,
		Work_Phone_3,
		Work_Phone_Ext,
		Work_Fax_1,
		Work_Fax_2,
		Work_Fax_3,
		Is_Locked,
		LoginTries,
		Is_First_Time,
		Updated_By,
		Updated_date,
		Pin_Update_Date,
		User_Email,
		User_Number,
		Is_Eligible_RSP,
		Is_On_Behalf_Of,
		Crucible_File_Download,
		Company_Name,
		Blacksmith_User,
		user_language,
		RFA_Notification_Email,
		Remote_Approval_Option,
		BB_Remote_Approval_Option
		<!---Only show this if USDANOI is turned on--->
		<cfif appSettings.getUSDANOIEnabled() IS 1>
			,
			IS_USDA_USER,
			user_usda_state_id,
			user_usda_county_id,
			user_usda_operator_id,
			user_usda_distributor_id_list,
			user_usda_broker_id_list,
			user_usda_operator_id_list
		</cfif>
		<!--- Dev Note: drachala; D28871: Don't show Middle Initial field in user setup when app setting is OFF  START
		Added/Changed: Added IF condition to SHOW/HIDE Middle Initial Field--->
		<cfif appSettings.USER_ACCOUNT_MIDDLE_INITIAL>
			,Name_Middle_Initial                 <!---27172--->
		</cfif>
		<!--- End Dev Note: drachala; D28871: Don't show Middle Initial field in user setup when app setting is OFF  --->
		,Ember_Info<!--- 72497 --->
		)
		VALUES
		(
		'#concat_username#',
		'#hash(tempPassword)#',
		'#hashPin#',
		'#Generated.User_ID#',
		<cfqueryparam value="#FORM.LDAP_User_Name#" cfsqltype="CF_SQL_VARCHAR" null="#iif((FORM.LDAP_User_Name eq ""), de("yes"), de("no"))#" />,
		<cfqueryparam value="#FORM.Analytics_SSO_User_Name#" cfsqltype="CF_SQL_VARCHAR" null="#iif((FORM.Analytics_SSO_User_Name eq ""), de("yes"), de("no"))#" />,
		'#FORM.User_Profile_ID#',
		'#FORM.Name_First#',
		'#FORM.Name_Last#',
		'#FORM.Company_Main_ID#',
		'#FORM.Title#',
		#Form.User_Authority_Sequence_ID#,
		'#FORM.Work_Address_1#',
		'#FORM.Work_Address_2#',
		'#FORM.Work_City#',
		'#FORM.Work_State#',
		'#FORM.Work_Zip#',
		'#FORM.WORK_Country_Code#',
		'#FORM.Work_Phone_1#',
		'#FORM.Work_Phone_2#',
		'#FORM.Work_Phone_3#',
		'#FORM.Work_Phone_Ext#',
		'#FORM.Work_Fax_1#',
		'#FORM.Work_Fax_2#',
		'#FORM.Work_Fax_3#',
		0,
		0,
		1,
		'#request.AccessStructure.user_id#',
		GetDate(),
		GetDate(),
		'#FORM.Work_Email#',
		'#FORM.User_Number#',
		'#Form.Is_Eligible_RSP#',
		'#Form.Is_On_Behalf_Of#',
		'#Form.Crucible_File_Download#',
		'#Form.Company_Name#',
		'#form.blacksmith_user#',
		'#form.user_language#',
		<cfqueryparam value="#FORM.RFA_Notification_Email#" cfsqltype="cf_sql_integer">,
		<cfqueryparam value="#FORM.Remote_Approval_Option#" cfsqltype="cf_sql_integer">,
		<cfqueryparam value="#FORM.BB_Remote_Approval_Option#" cfsqltype="cf_sql_integer">
		<!---Only show this if USDANOI is turned on--->
		<cfif appSettings.getUSDANOIEnabled() IS 1>
			,
			'#FORM.IS_USDA_USER#',
			'#FORM.user_usda_state_id#',
			'#FORM.user_usda_county_id#',
			'#FORM.user_usda_operator_id#',
			<cfif FORM.user_usda_distributor_id_list IS "null" OR FORM.user_usda_distributor_id_list IS 0>null<cfelse> '#FORM.user_usda_distributor_id_list#'		</cfif>,
			<cfif FORM.user_usda_broker_id_list IS "null" OR FORM.user_usda_broker_id_list IS 0>null<cfelse> '#FORM.user_usda_broker_id_list#'		</cfif>,
			<cfif FORM.user_usda_operator_id_list IS "null" OR FORM.user_usda_operator_id_list IS 0>null<cfelse> '#FORM.user_usda_operator_id_list#'		</cfif>
		</cfif>
		<!--- Dev Note: drachala; D28871: Don't show Middle Initial field in user setup when app setting is OFF  START
		Added/Changed: Added IF condition to SHOW/HIDE Middle Initial Field--->
		<cfif appSettings.USER_ACCOUNT_MIDDLE_INITIAL>
			,<cfqueryparam value="#FORM.Name_Middle_Initial#" cfsqltype="cf_sql_varchar">   <!---27172--->
		</cfif>
		<!--- End Dev Note: drachala; D28871: Don't show Middle Initial field in user setup when app setting is OFF  --->
			,'#FORM.Ember_Info#'<!--- 72497 --->
		)
	</CFQUERY>
	<cfquery name="AddUserTransCreateUser" datasource="#application.datasource#">
		INSERT INTO Audit_User_Transactions(Trans_Type,Trans_User_Code,Trans_IP_Address,Trans_By_User_ID)
		VALUES
		(
		'CREATE-USER',
		<cfqueryparam value="#concat_username#" cfsqltype="CF_SQL_VARCHAR">,
		<cfqueryparam value="#UsersIP#" cfsqltype="CF_SQL_VARCHAR">,
		<cfqueryparam value="#Request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
		)
		</cfquery>
		<CFSET FORM.User_ID = Generated.User_ID>
	<CFELSE>
		<CFQUERY NAME="updateUser" datasource="#application.datasource#">
			UPDATE _Users
			SET
			Profiles_ID	 		=	'#FORM.User_Profile_ID#',
			Name_First	 		=	'#FORM.Name_First#',
			Name_Last	 		=	'#FORM.Name_Last#',
			LDAP_User_Name		=	<cfqueryparam value="#FORM.LDAP_User_Name#" cfsqltype="CF_SQL_VARCHAR" null="#iif((FORM.LDAP_User_Name eq ""), de("yes"), de("no"))#" />,
			LDAP_User_ID		=	<cfqueryparam value="#FORM.LDAP_User_Name#" cfsqltype="CF_SQL_VARCHAR" null="#iif((FORM.LDAP_User_Name eq ""), de("yes"), de("no"))#" />,
			Analytics_SSO_User_Name		=	<cfqueryparam value="#FORM.Analytics_SSO_User_Name#" cfsqltype="CF_SQL_VARCHAR" null="#iif((FORM.Analytics_SSO_User_Name eq ""), de("yes"), de("no"))#" />,
			Company_Main_ID	 	=	'#FORM.Company_Main_ID#',
			Title	 			=	'#FORM.Title#',
			Authority_Sequence_ID=	#Form.User_Authority_Sequence_ID#,
			Work_Address_1	 	=	REPLACE(REPLACE(REPLACE(REPLACE('#FORM.Work_Address_1#', CHAR(13), ''), CHAR(10), ''), 'CR', ''), 'LF', ''),
			Work_Address_2	 	=	REPLACE(REPLACE(REPLACE(REPLACE('#FORM.Work_Address_2#', CHAR(13), ''), CHAR(10), ''), 'CR', ''), 'LF', ''),
			Work_City	 		=	'#FORM.Work_City#',
			Work_State	 		=	'#FORM.Work_State#',
			Work_Zip	 		=	'#FORM.Work_Zip#',
			Work_Country_Code	=	'#FORM.WORK_Country_Code#',
			Work_Phone_1	 	=	'#FORM.Work_Phone_1#',
			Work_Phone_2	 	=	'#FORM.Work_Phone_2#',
			Work_Phone_3	 	=	'#FORM.Work_Phone_3#',
			Work_Phone_Ext	 	=	'#FORM.Work_Phone_Ext#',
			Work_Fax_1	 		=	'#FORM.Work_Fax_1#',
			Work_Fax_2	 		=	'#FORM.Work_Fax_2#',
			Work_Fax_3	 		=	'#FORM.Work_Fax_3#',
			Updated_By			= 	'#request.AccessStructure.user_id#',
			Updated_date		= 	GetDate(),
			User_Email	 		=	'#FORM.Work_Email#',
			User_Number			=	'#FORM.User_Number#',
			Is_Eligible_RSP		= 	'#FORM.Is_Eligible_RSP#',
			Is_On_Behalf_Of		=	'#FORM.Is_On_Behalf_Of#',
			Crucible_File_Download = '#FORM.Crucible_File_Download#',
			Company_Name		= 	'#FORM.Company_Name#',
			Blacksmith_User     =   '#form.blacksmith_user#',
			user_language       =   '#form.user_language#',
			RFA_Notification_Email		=	<cfqueryparam value="#FORM.RFA_Notification_Email#" cfsqltype="cf_sql_integer">,
			Remote_Approval_Option		=	<cfqueryparam value="#FORM.Remote_Approval_Option#" cfsqltype="cf_sql_integer">,
			BB_Remote_Approval_Option	=	<cfqueryparam value="#FORM.BB_Remote_Approval_Option#" cfsqltype="cf_sql_integer">
			<cfif form.activateuser EQ 1>
				,deleted = 0
			</cfif>
			<!---Only show this if USDANOI is turned on--->
			<cfif appSettings.getUSDANOIEnabled() IS 1>
				,
				IS_USDA_USER	= '#FORM.IS_USDA_USER#',
				user_usda_state_id	= '#FORM.user_usda_state_id#',
				user_usda_county_id	= '#FORM.user_usda_county_id#',
				user_usda_operator_id	= '#FORM.user_usda_operator_id#',
				user_usda_distributor_id_list = <cfif FORM.user_usda_distributor_id_list IS "null" OR FORM.user_usda_distributor_id_list IS 0>null<cfelse> '#FORM.user_usda_distributor_id_list#'</cfif>,
				user_usda_broker_id_list = <cfif FORM.user_usda_broker_id_list IS "null" OR FORM.user_usda_broker_id_list IS 0>null<cfelse> '#FORM.user_usda_broker_id_list#'</cfif>,
				user_usda_operator_id_list = <cfif FORM.user_usda_operator_id_list IS "null" OR FORM.user_usda_operator_id_list IS 0>null<cfelse> '#FORM.user_usda_operator_id_list#'</cfif>
			</cfif>
			<!--- Dev Note: drachala; D28871: Don't show Middle Initial field in user setup when app setting is OFF  START
			Added/Changed: Added IF condition to SHOW/HIDE Middle Initial Field--->
			<cfif appSettings.USER_ACCOUNT_MIDDLE_INITIAL>
				,Name_Middle_Initial = <cfqueryparam value="#FORM.Name_Middle_Initial#" cfsqltype="cf_sql_varchar">  <!---27172--->
			</cfif>
			<!--- End Dev Note: drachala; D28871: Don't show Middle Initial field in user setup when app setting is OFF  --->
			<cfif Request.AccessStructure.User_Rights_ID eq "9999" AND FORM.upateAccessRights EQ 1>
				,User_rights_id = <cfqueryparam value="#FORM.User_Rights_ID#" cfsqltype="cf_sql_integer">
			</cfif>
			,Ember_Info = '#FORM.Ember_Info#'<!--- 72497 --->
			WHERE

			User_ID 			=	'#FORM.User_ID#'
		</CFQUERY>
		<!---
		Dev Notes: 23086/Anand Rao/21-May-10
		User Traffic Changes
		--->
		<cfquery name="qGetUserCode" datasource="#application.datasource#">
			SELECT User_Code FROM _Users WHERE User_ID = <cfqueryparam value="#FORM.User_ID#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<cfif form.activateuser EQ 1>
				<cfquery name="AddUserTransActivateUser" datasource="#application.datasource#">
					INSERT INTO Audit_User_Transactions(Trans_Type,Trans_User_Code,Trans_IP_Address,Trans_By_User_ID)
					VALUES
					(
					'ACTIVATE-USER',
					<cfqueryparam value="#qGetUserCode.User_Code#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#UsersIP#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#Request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
					)
					</cfquery>
				<cfelse>
					<cfquery name="AddUserTransUpdateUser" datasource="#application.datasource#">
						INSERT INTO Audit_User_Transactions(Trans_Type,Trans_User_Code,Trans_IP_Address,Trans_By_User_ID)
						VALUES
						(
						'UPDATE-USER',
						<cfqueryparam value="#qGetUserCode.User_Code#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#UsersIP#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#Request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
						)
						</cfquery>
				</cfif>
				<!--- auto logout user --->
		</CFIF>
		<!--- update position --->
		<CFQUERY NAME="getExistingUserPosition" datasource="#application.datasource#">
			SELECT *
			FROM User_Position_Holders
			WHERE User_ID = '#FORM.User_ID#' AND DELETED = 0
		</CFQUERY>
		<cfif form.ClassCodesOn EQ 0>
			<!------ update business segments ----->
			<cfset useLakebaseForqDeleteUserBusinessSegment = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("user_business_segment")>
<cfif useLakebaseForqDeleteUserBusinessSegment>
	<cftry>
		<cfset application.oLakebase.updateRows("user_business_segment",
			{
				"user_id" = "eq.#FORM.User_ID#",
				"deleted" = "eq.0"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqDeleteUserBusinessSegment = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqDeleteUserBusinessSegment>
<cfquery name="qDeleteUserBusinessSegment" datasource="#application.datasource#">
				UPDATE	User_Business_Segment
				SET		Deleted = 1
				WHERE
				User_ID = '#FORM.User_ID#'
				AND DELETED = 0
			</cfquery>
</cfif>
			<cfloop list="#FORM.User_Business_Segment_ID#" index="thisBusinessSegmentID">
				<cfquery name="qInsertUserBusinessSegment" datasource="#application.datasource#">
					INSERT INTO User_Business_Segment (Business_Segment_ID, User_ID)
					VALUES ('#thisBusinessSegmentID#', '#FORM.User_ID#')
					</cfquery>
			</cfloop>
		<cfelse>
			<!------ update Class Codes----->
			<cfquery name="qDeleteUserClassCode" datasource="#application.datasource#">
				UPDATE	User_Class_Code
				SET		Deleted = 1
				WHERE	User_ID = '#FORM.User_ID#'
				AND 	DELETED = 0
			</cfquery>
			<cfloop list="#FORM.User_Class_Code_ID#" index="thisClassCodeID">
				<cfquery name="qInsertUserClassCode" datasource="#application.datasource#">
					INSERT INTO User_Class_Code (Class_Code_ID, User_ID)
					VALUES ('#thisClassCodeID#', '#FORM.User_ID#')
					</cfquery>
			</cfloop>
	</cfif>
	<!---Type codes--->
	<cfif len(trim(FORM.Type_Code_ID)) GT 0>
		<!---Update Type Codes--->
		<cfquery name="UpdateTypeCodes" datasource="#application.datasource#">
			UPDATE 	User_Type_Code
			SET 	Deleted = 1
			WHERE 	User_ID = '#form.User_ID#'
			AND		Deleted = 0
		</cfquery>
		<cfloop list="#FORM.Type_Code_ID#" index="ThisTypeCodeID">
			<cfquery name="InsertTypeCode" datasource="#application.datasource#">
				INSERT INTO User_Type_Code (User_ID, Type_Code_ID)
				VALUES ('#FORM.User_ID#', '#ThisTypeCodeID#')
			</cfquery>
		</cfloop>
	</cfif>
	<!---Type codes--->
	<cfif len(trim(FORM.Line_of_Business_ID)) GT 0>
		<!---Update Type Codes--->
		<cfquery name="UpdateLOB" datasource="#application.datasource#">
			UPDATE 	user_LOB
			SET 	Deleted = 1
			WHERE 	User_ID = '#form.User_ID#'
			AND		Deleted = 0
		</cfquery>
		<cfloop list="#FORM.Line_of_Business_ID#" index="ThisLOBID">
			<cfquery name="InsertLOB" datasource="#application.datasource#">
				INSERT INTO User_LOB (User_ID, Line_Of_Business_ID)
				VALUES ('#FORM.User_ID#', '#ThisLOBID#')
			</cfquery>
		</cfloop>
	</cfif>
	<CFIF getExistingUserPosition.Recordcount EQ 0>
		<!--- Add NEw Position --->
		<CFQUERY NAME="addNewPrimaryPositionHolder" datasource="#application.datasource#">
			INSERT INTO User_Position_Holders
			(User_Positions_ID, User_ID,User_Position_Type)
			VALUES
			('#FORM.USER_POSITIONS_ID#', '#FORM.User_ID#','P')
			</CFQUERY>
			<cfif #ListLen(USER_SEC_POSITIONS_ID,',' )# GT 0>
				<cfloop list="#USER_SEC_POSITIONS_ID#" index="i">
					<CFQUERY NAME="addNewSecondaryPositionHolder" datasource="#application.datasource#">
						INSERT INTO User_Position_Holders
						(User_Positions_ID, User_ID,User_Position_Type)
						VALUES
						('#i#', '#FORM.User_ID#','S')
						</CFQUERY>
				</cfloop>
		</cfif>
	<CFELSE>
		<CFQUERY NAME="UPDATEPRIMARYUSERPOSITION" datasource="#application.datasource#">
			UPDATE 	User_Position_Holders
			SET		User_Positions_ID = '#FORM.USER_POSITIONS_ID#',
			User_Position_Type = 'P'
			WHERE 	User_ID = '#FORM.User_ID#' AND DELETED = 0 AND User_Position_Type = 'P'
			</CFQUERY>
			<cfif #ListLen(USER_SEC_POSITIONS_ID,',' )# GT 0>
				<CFQUERY NAME="UPDATESECONDARYUSERPOSITION_1" datasource="#application.datasource#">
					UPDATE User_Position_Holders
					SET
					Deleted = 1
					WHERE User_ID = '#FORM.User_ID#' AND User_Position_Type = 'S'
					AND User_Positions_ID NOT IN (#USER_SEC_POSITIONS_ID#)
					</CFQUERY>
					<CFQUERY NAME="GETSECONDARYUSERPOSITIONS" datasource="#application.datasource#">
						SELECT 	User_Positions_ID
						FROM 	User_Position_Holders
						WHERE 	User_ID = '#FORM.User_ID#' AND User_Position_Type = 'S'
						AND DELETED = 0
						</CFQUERY>
						<cfif GETSECONDARYUSERPOSITIONS.RecordCount GT 0>
							<cfset SecValueList = ValueList(GETSECONDARYUSERPOSITIONS.User_Positions_ID)>
						<cfelse>
							<cfset SecValueList = "">
						</cfif>
						<cfloop list="#USER_SEC_POSITIONS_ID#" index="i">
							<cfif NOT ListFindNoCase(SecValueList, i , ',')>
								<CFQUERY NAME="UPDATESECONDARYUSERPOSITION_2" datasource="#application.datasource#">
									INSERT INTO User_Position_Holders
									(User_Positions_ID, User_ID,User_Position_Type)
									VALUES
									('#i#', '#FORM.User_ID#','S')
									</CFQUERY>
							</cfif>
					</cfloop>
				<cfelse>
					<CFQUERY NAME="UPDATESECONDARYUSERPOSITION_1" datasource="#application.datasource#">
						UPDATE 	User_Position_Holders
						SET		Deleted = 1
						WHERE 	User_ID = '#FORM.User_ID#' AND User_Position_Type = 'S'
						</CFQUERY>
				</CFIF>
		</CFIF>
		<!--- update position --->
		<cfset useLakebaseForgetProfileDescription = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("profiles")>
<cfif useLakebaseForgetProfileDescription>
	<cftry>
		<cfset getProfileDescription = application.oLakebase.toQuery(
			application.oLakebase.selectRows("profiles", {
				"profiles_id" = "eq.#USER_PROFILE_ID#",
				"select" = "profiles_desc"
			}), "profiles_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetProfileDescription = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetProfileDescription>
<CFQUERY NAME="getProfileDescription" datasource="#application.datasource#">
			SELECT 	Profiles_Desc
			FROM 	Profiles
			WHERE 	Profiles_ID = '#USER_PROFILE_ID#'
		</CFQUERY>
</cfif>
		<cfset useLakebaseForgetCompanyInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("company_main")>
<cfif useLakebaseForgetCompanyInfo>
	<cftry>
		<cfset getCompanyInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("company_main", {
				"company_main_id" = "eq.#COMPANY_MAIN_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetCompanyInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetCompanyInfo>
<CFQUERY NAME="getCompanyInfo" datasource="#application.datasource#">
			SELECT *
			FROM Company_Main
			WHERE Company_Main_ID = '#COMPANY_MAIN_ID#'
		</CFQUERY>
</cfif>
		<cfset useLakebaseForgetStateCode = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_states")>
<cfif useLakebaseForgetStateCode>
	<cftry>
		<cfset getStateCode = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_states", {
				"state_id" = "eq.#WORK_STATE#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetStateCode = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetStateCode>
<CFQUERY NAME="getStateCode" datasource="#application.datasource#">
			SELECT *
			FROM _states
			WHERE State_ID = '#WORK_STATE#'
		</CFQUERY>
</cfif>
		<cfset useLakebaseForgetPositionInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("user_positions")>
<cfif useLakebaseForgetPositionInfo>
	<cftry>
		<cfset getPositionInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("user_positions", {
				"user_positions_id" = "eq.#USER_POSITIONS_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetPositionInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetPositionInfo>
<CFQUERY NAME="getPositionInfo" datasource="#application.datasource#">
			SELECT *
			FROM User_Positions
			WHERE User_Positions_ID = '#USER_POSITIONS_ID#'
			</CFQUERY>
</cfif>
			<!--- ||||||||||||||| CREATE XML LOG OF CHANGES |||||||||||||||
			<cfif appSettings.getAuditTrailStorage() NEQ 0>
				<cfset createLog = createObject("component", "components.settings.AuditTrail.AuditTrail").init()>
				<cfset createLog.createXMLlog("_Users",1,FORM.User_ID)>
				<cfset createLog.createXMLlog("User_Position_Holders",1,FORM.User_ID)>
			</cfif>
			||||||||||||||| CREATE XML LOG OF CHANGES ||||||||||||||| --->
			<!--- rebuild approval structure --->
			<!--- <CFINCLUDE TEMPLATE="\settings\Access_Rights\approval_tree\Approver_Tree_Build.cfm"> --->
			<CFIF FORM.UPDATERECORD EQ 0>
				<CFSET PAGE_TITLE= "">
				<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
				<HTML>
					<HEAD>
						<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
						<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
					</HEAD>
					<BODY BACKGROUND="" BGCOLOR="WhiteSmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" ONLOAD="" ONBEFOREUNLOAD="">
						<CFSET pagetitle="USER CREATION SUCCESSFUL">
						<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
						<!--- Check whether emailing new password is allowed by the admin. If so, send an email to the new user --->
						<cfset DontEmailTempPassword = appSettings.getTempPassword()>
						<CFOUTPUT>
						The user has been created.
						<!--- Send the Email --->
						<cfif DontEmailTempPassword>
							<span style="color:red"><br />Note: As per request, they will not receive their user name and password by email.</span>
						<cfelse>
							They will receive their user name and password by email.
						</cfif>
						<p></p>
						<B>User Information</B>:<BR>
						<BR>
						<CFSAVECONTENT VARIABLE="UserInfo">
						<style>
							.dataLabel {
								font-weight: bold;
							}
						</style>
						<TABLE>
							<!--- Dev Note: Kal;  D21554: Single sign on to application using LDAP --->
							<cfif (appSettings.getLDAP_SSO_Enabled()
									OR appSettings.getSingleSign_on() eq 2
									OR appSettings.getSingleSignOnOverrideUserId() )
									AND len(LDAP_User_Name) >
									<TR>
										<TD CLASS="dataLabel" ALIGN="right">SSO User Name:</TD>
										<TD>#LDAP_User_Name#</TD>
									</TR>
							<cfelse>
								<TR>
									<TD CLASS="dataLabel" ALIGN="right">User Name:</TD>
									<TD>#concat_username#</TD>
								</TR>
							</cfif>
							<cfif appSettings.getSingleSignOnOverrideUserId() OR (NOT (appSettings.getLDAP_SSO_Enabled() or len(Form.LDAP_User_Name)))>
								<TR>
									<TD CLASS="dataLabel" ALIGN="right">Password:</TD>
									<TD><FONT SIZE="+1" face="Courier New"><B>#tempPassword#</B></FONT></TD>
								</TR>
							</cfif>
							<TR>
								<TD CLASS="dataLabel" ALIGN="right">Pin:</TD>
								<TD><FONT SIZE="+1" face="Courier New"><B>#tempPin#</B></FONT></TD>
							</TR>
							<TR>
								<TD CLASS="dataLabel" ALIGN="right">Name:</TD>
								<TD>#Name_First#&nbsp;#Name_Last#</TD>
							</TR>
							<TR>
								<TD CLASS="dataLabel" ALIGN="right">Email:</TD>
								<TD>#WORK_EMAIL#</TD>
							</TR>
							<TR>
								<TD CLASS="dataLabel" ALIGN="right">Position:</TD>
								<TD>#getPositionInfo.Position_Label#</TD>
							</TR>
							<TR>
								<TD CLASS="dataLabel" ALIGN="right">Profile:</TD>
								<TD>#getProfileDescription.Profiles_Desc#</TD>
							</TR>
							<TR>
								<TD CLASS="dataLabel" ALIGN="right">Company:</TD>
								<TD>#getCompanyInfo.Company_Name#</TD>
							</TR>
							<TR>
								<TD CLASS="dataLabel" ALIGN="right">Title:</TD>
								<TD>#Title#</TD>
							</TR>
							<TR>
								<TD CLASS="dataLabel" ALIGN="right">Address:</TD>
								<TD>
									#Work_Address_1#<BR>
									<cfif len(trim(Work_Address_2)) GT 0>#Work_Address_1#<BR></cfif>
									#Work_City#, #getStateCode.State_Code# #Work_Zip#
								</TD>
							</TR>
							<TR>
								<TD CLASS="dataLabel" ALIGN="right">Phone:</TD>
								<TD>#Work_Phone_1#-#Work_Phone_2#-#Work_Phone_3#<cfif len(trim(WORK_PHONE_EXT)) GT 0>&nbsp;Ext.#WORK_PHONE_EXT# </cfif></TD>
							</TR>
							<TR>
								<TD CLASS="dataLabel" ALIGN="right">Fax:</TD>
								<TD>#Work_Fax_1#-#Work_Fax_2#-#Work_Fax_3#</TD>
							</TR>
							<cfif appSettings.getLDAP_SSO_Enabled() AND (FORM.UPDATERECORD EQ 0)>
								<TR>
									<TD CLASS="dataLabel" ALIGN="right">New User Activation:</TD>
									<TD>
										<a href="#siteURL#/index2.cfm?id=#Generated.User_ID#">Click link to activate account</a><br/>
										[#variables.qGetLDAPSettings.LDAP_NEW_USER_MESSAGE#]
									</TD>
								</TR>
							<cfelse>
								<TR>
									<TD CLASS="dataLabel" ALIGN="right">Link:</TD>
									<TD><a href="#siteURL#"><cfoutput>#siteURL#</cfoutput></a></TD>
								</TR>
							</cfif>
						</TABLE>
						</CFSAVECONTENT>
						#UserInfo#
						<BR>
						<center>
						<span STYLE="color:red;font-weight:bold;">[</span>
						<A HREF="/index.cfm?event=settings.users.dspUsers" STYLE="font-weight:bold;font-weight:bold;">return to user listing</A>
						<span STYLE="color:red;">]</span>
						</center>
					</BODY>
				</HTML>
				</CFOUTPUT>
				<!--- 114192: User creation - event error 
							  Re-added this code from the file to avoid error caused from WR112524 /Anand Rao / 17-Mar-2022
				--->				
				<CFSET Contact_Admin_Email_Address = "">
				<CFQUERY NAME="get_Contact_Admin_Email_Address" datasource="#application.datasource#">
					SELECT 	User_Email, Name_First, Name_Last, Work_Phone_1, Work_Phone_2, Work_Phone_3, Work_Phone_Ext, Company_Main.Company_Name
					FROM 	_Users
							INNER JOIN
				            Company_Main ON _Users.Company_Main_ID = Company_Main.Company_Main_ID
					WHERE Contact_Administrator = <cfqueryparam value="1" cfsqltype="CF_SQL_INTEGER">
				</CFQUERY>
				<CFIF get_Contact_Admin_Email_Address.recordCount GT 0>
					<CFSET Contact_Admin_Email_Address = get_Contact_Admin_Email_Address.User_Email>
				<CFELSE>
					<CFQUERY NAME="get_Contact_Admin_Email_Address" datasource="#application.datasource#">
						SELECT 	User_Email, Name_First, Name_Last, Work_Phone_1, Work_Phone_2, Work_Phone_3, Work_Phone_Ext, Company_Main.Company_Name
						FROm 	_Users
								INNER JOIN
				            	Company_Main ON _Users.Company_Main_ID = Company_Main.Company_Main_ID
						WHERE Is_System_Administrator = <cfqueryparam value="1" cfsqltype="CF_SQL_INTEGER">
					</CFQUERY>
					<CFIF get_Contact_Admin_Email_Address.recordCount GT 0>
						<CFSET Contact_Admin_Email_Address = get_Contact_Admin_Email_Address.User_Email>
					</CFIF>
				</CFIF>
				
				<CFINCLUDE TEMPLATE="/get_Contact_Admin_Email_Address.cfm">
				<cfif appSettings.getWelcomeLetterOn()>
					<!--- Set the filepath for the attached welcome letter --->
					<cfif isdefined("Form.Welcome_Letter") AND len(Form.Welcome_Letter)>
						<cfset fileWelcomeLetter = "#application.doc_mapping#\Data_Files\Uploaded\Documents\Uploaded_Doc\#form.welcome_letter#" />
					</cfif>
					<!--- Check If Send Fax is checked --->
					<cfif form.send_welcome_letter EQ 0>
						<!--- Reassign Work Email and From Address for faxing --->
						<cfset WORK_EMAIL = #trim(FORM.Work_Fax_1)# & #trim(FORM.Work_Fax_2)# & #trim(FORM.Work_Fax_3)# & "@faxmail.com" />
						<cfset Contact_Admin_Email_Address = application.CompanyFaxFromEmail />
					</cfif>
				</cfif>
				<!--- Send the Email --->
				<cfif DontEmailTempPassword eq 0>
					<cfoutput>
					<CF_EMAILWRAPPER TO="#WORK_EMAIL#"
					FROM="#Contact_Admin_Email_Address#"
					SUBJECT="#application.CompanyName# New User Information (#siteURL#)"
					TYPE="HTML"
					messagetype="1"
					generatedby="2"
					apparea="9"
					logMessage="0">
					Welcome to #application.CompanyName#.
					<p></p>
					The information below was entered when your account was created. If any of the information is incorrect, or has changed, please contact the #application.returned_customer_setting.Company_Name# #application.CompanyName# Administrator.<p>
					#UserInfo#
					<BR>
					<B>#application.returned_customer_setting.Company_Name# #application.CompanyName# Administrator</B><BR>
					#get_Contact_Admin_Email_Address.Name_First# #get_Contact_Admin_Email_Address.Name_Last#<BR>
					#get_Contact_Admin_Email_Address.User_Email#<Br>
					#get_Contact_Admin_Email_Address.Work_Phone_1#-#get_Contact_Admin_Email_Address.Work_Phone_2#-#get_Contact_Admin_Email_Address.Work_Phone_3#<cfif len(trim(get_Contact_Admin_Email_Address.Work_Phone_Ext)) GT 0>&nbsp;Ext.&nbsp;#get_Contact_Admin_Email_Address.Work_Phone_Ext#</cfif><br>
					<BR><BR><BR>
					<cfif appSettings.getWelcomeLetterOn()>
						<cfif isdefined("Form.Welcome_Letter") AND len(Form.Welcome_Letter)>
							<CF_EMAILWRAPPERPARAM file="#fileWelcomeLetter#">
						</cfif>
					</cfif>
					</CF_EMAILWRAPPER>
					</cfoutput>
				</cfif>
			<CFELSE>
			<!---
				<CFLOCATION URL="/index.cfm?event=settings.users.dspUsers" />
			--->
				<CFLOCATION URL="/views/settings/list_users.cfm?upateAccessRights=#FORM.upateAccessRights#" />
			</CFIF>
