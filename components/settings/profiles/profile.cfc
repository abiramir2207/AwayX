<cfcomponent hint="System Profile Management">


	<cffunction name="init" output="true">

		<cfargument name="profileId" type="numeric" default="0" required="yes" displayname="Profile ID">

		<!--- load empty profile --->

		<cfset tmpProfileQuery = this.getProfile(0)>

		<cfif arguments.profileId NEQ 0>
			<cfset tmpProfileQuery = this.getProfile(arguments.profileId)>
		</cfif>

		<cfwddx action="cfml2wddx" input="#tmpProfileQuery#" output="PacketContent" usetimezoneinfo="yes">

		<!--- write temp file --->
		<CFINCLUDE TEMPLATE="/get_App_Path.cfm">

		<cfset FileLocation = Application.Doc_path & "\temp_files\WddxPackets">
		<cfset FileName = replace(createuuid() & createuuid(),"-", "", "ALL") & ".DDX">

		<cfset FinalFileLocation = FileLocation & "\" & FileName>

		<cffile action="write" addnewline="yes" file="#FinalFileLocation#" output="#PacketContent#">

		<cfreturn FinalFileLocation />

	</cffunction>


	<cffunction name="getSetting" output="false" hint="Extract a setting from the profile packet">

		<cfargument name="FileLocation" type="string" required="yes">

		<cfargument name="Setting_Column_Name" type="string" required="yes">

		<cfset tmpProfileQuery = this.loadPacket(arguments.FileLocation)>

		<cfset useLakebaseForgetSettingFromQuery = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("tmpprofilequery")>
<cfif useLakebaseForgetSettingFromQuery>
	<cftry>
		<cfset getSettingFromQuery = application.oLakebase.toQuery(
			application.oLakebase.selectRows("tmpprofilequery", {
				"select" = "#setting_column_name#"
			}), "#setting_column_name#"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetSettingFromQuery = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetSettingFromQuery>
<cfquery name="getSettingFromQuery" dbtype="query">
			SELECT #Setting_Column_Name# FROM tmpProfileQuery
		</cfquery>
</cfif>

		<cfreturn evaluate("getSettingFromQuery.#Setting_Column_Name#") />

	</cffunction>


	<cffunction name="setSetting" output="false" hint="Update a setting in the profile packet">

		<cfargument name="FileLocation" type="string" required="yes">

		<cfargument name="Setting_Column_Name" type="string" required="yes">

		<cfargument name="Setting_Column_Value" type="string" required="yes">

		<cfset tmpProfileQuery = this.loadPacket(arguments.FileLocation)>

		<cfset temp = QuerySetCell(tmpProfileQuery, "#Setting_Column_Name#", Setting_Column_Value)>

		<cfset temp = this.writePacket(FileLocation, tmpProfileQuery)>

		<cfreturn this.loadPacket(FileLocation) />

	</cffunction>


	<cffunction name="getProfile" output="false" hint="Get all profile Information For Supplied Profile ID">

		<cfargument name="profileId" type="numeric" required="yes" displayname="Profile ID">

		<cfquery name="qGetProfile" datasource="#application.datasource#">
			SELECT   dbo.Profiles_Settings.*,
					 isNull(dbo.BB_Profiles_Settings.BB_Create,0) AS BB_Create,
					 isNull(dbo.BB_Profiles_Settings.BB_Delete,0) AS BB_Delete,
					 isNull(dbo.BB_Profiles_Settings.BB_View_Deviation,0) AS BB_View_Deviation,
					 isNull(dbo.BB_Profiles_Settings.BB_Approve,0) AS BB_Approve,
					 isNull(dbo.BB_Profiles_Settings.BB_DevGrid_Expected,0) AS BB_DevGrid_Expected,
					 isNull(dbo.BB_Profiles_Settings.BB_DevGrid_ELT,0) AS BB_DevGrid_ELT,
					 isNull(dbo.BB_Profiles_Settings.BB_DevGrid_Claimed,0) AS BB_DevGrid_Claimed,
					 isNull(dbo.BB_Profiles_Settings.BB_DevGrid_Selected,0) AS BB_DevGrid_Selected,
					 isNull(dbo.BB_Profiles_Settings.BB_Approve_Amount,0) AS BB_Approve_Amount,
					 isNull(dbo.BB_Profiles_Settings.BB_Approve_Critical,0) AS BB_Approve_Critical,
					 dbo.BB_Profiles_Settings.BB_User_ID,
					 dbo.BB_Profiles_Settings.BB_Updated_Date,
					 dbo.BB_Profiles_Settings.Created_Date,
					 dbo.Profiles.Profiles_Desc, dbo.Profiles.Profiles_Short_Desc,
					 isNull(dbo.BB_Profiles_Settings.BB_RFA_Agreed,0) AS BB_RFA_Agreed,
					 ISNULL(dbo.BB_Profiles_Settings.BB_Allow_Vendor_Master_Search,0) AS BB_Allow_Vendor_Master_Search,
					 ISNULL(dbo.BB_Profiles_Settings.BB_Add_Program,0) AS BB_Add_Program,
					 ISNULL(BB_Profiles_Settings.BB_Add_Payee_Any_Position, 0) AS BB_Add_Payee_Any_Position,
					 ISNULL(BB_Profiles_Settings.Max_BB_Oper_Location_Level_Dup_Approval_Amount, 0) AS Max_BB_Oper_Location_Level_Dup_Approval_Amount,  <!--- 76536: BB Oper Location Level - dup check - Anand Rao/09-Aug-2018 --->
					 ISNULL(BB_Profiles_Settings.View_Deviated_Items_Only_OnLoad, 0) AS View_Deviated_Items_Only_OnLoad,  <!--- START: 79028: BB Deviation Grid - default to only display items with deviation amt greater than $0  -Anand Rao/ 06-Sep-2018 --->
					 ISNULL(BB_Profiles_Settings.View_Count_Column_In_Deviation_Grid, 0) AS View_Count_Column_In_Deviation_Grid
			FROM     dbo.Profiles_Settings INNER JOIN
								  dbo.Profiles ON dbo.Profiles_Settings.Profiles_ID = dbo.Profiles.Profiles_ID LEFT OUTER JOIN
								  dbo.BB_Profiles_Settings ON dbo.Profiles_Settings.Profiles_ID = dbo.BB_Profiles_Settings.Profiles_ID
			WHERE    (dbo.Profiles_Settings.Deleted = 0) AND (dbo.BB_Profiles_Settings.Deleted = 0) and Profiles_Settings.Profiles_ID	=	#arguments.profileId#
			ORDER BY dbo.Profiles_Settings.Profiles_ID
		</cfquery>

		<cfreturn qGetProfile />

	</cffunction>


	<cffunction name="writePacket" output="false" hint="internal function to save packet">

		<cfargument name="FileLocation" type="string" required="yes">

		<cfargument name="ProfileQuery" type="query" required="yes">

		<cfwddx action="cfml2wddx" input="#arguments.ProfileQuery#" output="wddxpacketcontent" usetimezoneinfo="yes">

		<cffile action="write" addnewline="yes" file="#FileLocation#" output="#wddxpacketcontent#">

		<cfreturn this />

	</cffunction>


	<cffunction name="loadPacket" output="false" hint="load a profile packet by supplying a file location">

		<cfargument name="FileLocation" type="string" required="yes">

		<cffile action="read" file="#arguments.FileLocation#" variable="wddxpacketcontent">

		<cfwddx action="wddx2cfml" input="#wddxpacketcontent#" output="deSerializedPacket">

		<cfreturn deSerializedPacket />

	</cffunction>


	<cffunction name="commitSettings" output="false" hint="Saves Changes to packet to the database">

		<cfargument name="FileLocation" type="string" required="yes">

		<!--- create table to column mapping  --->
		<cfset aryColumnTableMap = arraynew(2)>

		<cfset tableList = "profiles_settings, BB_Profiles_Settings">

		<cfloop index="curTable" list="#tableList#">

			<cfquery name="getTableColumns" datasource="#application.datasource#">
				SELECT *
				FROM #curTable#
				WHERE 0=1
			</cfquery>

			<cfset aryColumnTableMap[arraylen(aryColumnTableMap)+1][1] = lcase(curTable)>

			<cfset aryColumnTableMap[arraylen(aryColumnTableMap)][2] = lcase(getTableColumns.columnlist)>

		</cfloop>

		<cfset tmpProfileQuery = this.loadPacket(arguments.FileLocation)>
		<cfset colExclusionList = lcase("BB_UPDATED_DATE,BB_USER_ID,CREATED_DATE,LAST_CHANGED_DATE,LAST_CHANGED_USER_ID,profiles_settings_id")>

		<!--- loop threw query --->
		<cfloop query="tmpProfileQuery">
		<cfset curProfileID = tmpProfileQuery.profiles_id>
			<!--- loop threw  each column in query--->
			<cfloop index="tblColumn" list="#tmpProfileQuery.columnlist#">

				<cfset curColumn = lcase(trim(tblColumn))>

				<cfif listfind(colExclusionList, curColumn) EQ 0>

					<cfset curColValue = lcase(evaluate("tmpProfileQuery.#curColumn#"))>

					<cfloop index="x" from="1" to="#arraylen(aryColumnTableMap)#">

						<cfset foundColumn = listfind(aryColumnTableMap[x][2], curColumn)>

						<cfif foundColumn NEQ 0>
							<cfquery name="saveSetting_#curColumn#" datasource="#application.datasource#">
								UPDATE #aryColumnTableMap[x][1]#
								SET #curColumn# = '#curColValue#'
								WHERE Profiles_ID = #curProfileID#
							</cfquery>
						</cfif>

					</cfloop>

				</cfif>

			</cfloop>

		</cfloop>

		<cfreturn this />

	</cffunction>

	<cffunction name="deleteProfile" output="true" hint="Updates Delete Bit In the Appropiate Tables">

		<cfargument name="profileId" type="numeric" required="yes" displayname="Profile ID">
		<cfargument name="substitute_profileId" type="numeric" required="yes" displayname="Replacement Profile ID for Deleted Profile">

		<cfset UsersIP = CGI.Remote_Addr>

    	<cfquery name="deleteProfile" datasource="#application.datasource#">
    		UPDATE Profiles SET Deleted = 1 WHERE Profiles_ID = '#arguments.profileId#'

    		UPDATE Profiles_Settings SET Deleted = 1 WHERE Profiles_ID = '#arguments.profileId#'

    		<cfif application.appSettingsGet.getDeduction_Module()>
    			UPDATE Deductions_Profiles_Settings
    			SET Deleted = 1
    			WHERE Profiles_ID = '#arguments.profileId#'
    		</cfif>
    	</cfquery>

    	<cfquery name="pull_MAX_ID" datasource="#application.datasource#">
    		SELECT MAX(profile_sequence) AS max_ps
    		FROM profiles
    	</cfquery>
    	<cfquery name="pull_CURRENT_ID" datasource="#application.datasource#">
    		SELECT profile_sequence
    		FROM profiles
    		WHERE Profiles_ID = '#arguments.profileId#'
    	</cfquery>
    	<cfloop from="#pull_CURRENT_ID.profile_sequence#" to="#pull_MAX_ID.max_ps#" index="ps">
    		<cfset new_ps = ps + 1>
    		<cfset useLakebaseForupdate_ps = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("profiles")>
<cfif useLakebaseForupdate_ps>
	<cftry>
		<cfset application.oLakebase.updateRows("profiles",
			{
				"profile_sequence" = "eq.#new_ps#",
				"deleted" = "eq.0"
			},
			{
				"profile_sequence" = "#ps#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdate_ps = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdate_ps>
<cfquery name="update_ps" datasource="#application.datasource#">
    			UPDATE profiles
    			SET profile_sequence = #ps# WHERE profile_sequence = #new_ps# AND deleted = 0
    		</cfquery>
</cfif>
    	</cfloop>

    	<cfset useLakebaseForgetUsersWithProfile = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForgetUsersWithProfile>
	<cftry>
		<cfset getUsersWithProfile = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"deleted" = "eq.0",
				"profiles_id" = "eq.#arguments.profileId#",
				"select" = "user_id"
			}), "user_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetUsersWithProfile = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetUsersWithProfile>
<cfquery name="getUsersWithProfile" datasource="#application.datasource#">
    		SELECT User_ID
    		FROM _Users
    		WHERE Deleted = 0 AND Profiles_ID = '#arguments.profileId#'
    	</cfquery>
</cfif>

		<CFSET ReasonText = "Your application security profile has been modified which requires you to log back in">

		<CFSET AutoLogout = CreateObject("component","components.AutoLogout.AutoLogout")>
		<CFSET oReasonArray = AutoLogout.initUserReasonArray()>

		<cfloop query="getUsersWithProfile">
			<cfset oReasonArray[arrayLen(oReasonArray)+1][1] = getUsersWithProfile.User_ID>
			<cfset oReasonArray[arrayLen(oReasonArray)][2] = ReasonText>
		</cfloop>
    	<cfset useLakebaseForupdateUserPositions = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForupdateUserPositions>
	<cftry>
		<cfset application.oLakebase.updateRows("_users",
			{
				"profiles_id" = "eq.#arguments.profileId#"
			},
			{
				"profiles_id" = "#arguments.substitute_profileId#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdateUserPositions = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdateUserPositions>
<cfquery name="updateUserPositions" datasource="#application.datasource#">
    		UPDATE _Users
    		SET Profiles_ID = '#arguments.substitute_profileId#'
    		WHERE Profiles_ID = '#arguments.profileId#'
    	</cfquery>
</cfif>
    	<!--- Dev Notes: 23086/Anand Rao/21-May-10 User Traffic Changes --->
    	<cfloop query="getUsersWithProfile">
    		<cfquery name="qGetUserCode" datasource="#application.datasource#">
    			SELECT User_Code FROM _Users WHERE User_ID = <cfqueryparam value="#getUsersWithProfile.User_ID#" cfsqltype="CF_SQL_VARCHAR">
    		</cfquery>
    		<cfquery name="AddUserTransAdminChange" datasource="#application.datasource#">
    			INSERT INTO
    			Audit_User_Transactions(Trans_Type,Trans_User_Code,Trans_IP_Address,Trans_By_User_ID)
    			VALUES
    			(
    			'PROFILE-UPDATE'
    			,<cfqueryparam value="#qGetUserCode.User_Code#" cfsqltype="CF_SQL_VARCHAR">
    			,<cfqueryparam value="#UsersIP#" cfsqltype="CF_SQL_VARCHAR">
    			,<cfqueryparam value="#REQUEST.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
    			)
    		</cfquery>
    	</cfloop>

		<cfset temp = AutoLogout.queueUserLogout(oReasonArray)>

		<cfreturn this />

	</cffunction>

	<cffunction name="getAllProfiles" output="false" hint="Returns a Query Of All The Profiles">


		<!--- Dev Note: drachala; D28010: Profile Setting modifications
				  what For: Check weather user selected any profiles if so we are passing argument into getprofiles query.	--->

        <cfargument name="profile_id" type="string" required="no" default="">

        	<!--- End Dev Note: drachala; D28010: Profile Setting modifications  --->
		<cfargument name="UserSettingPanel" type="numeric" required="no" default=5>
		<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
		<cfquery name="qGetProfiles" datasource="#application.datasource#">
			SELECT     DISTINCT dbo.Profiles_Settings.*,
						<cfif application.appSettingsGet.getDeduction_Module()>Deductions_Profiles_Settings.*,</cfif>
						<!--- 57305: Retail Planner/01-Mar-2016/Anand Rao --->
						<cfif appSettings.get_Setting('Retail_Planner') eq '1'>Planner_Profiles_Settings.*,	</cfif>
						isNull(dbo.BB_Profiles_Settings.BB_Create,0) AS BB_Create,
						isNull(dbo.BB_Profiles_Settings.BB_Delete,0) AS BB_Delete,
						isNull(dbo.BB_Profiles_Settings.BB_View_Deviation,0) AS BB_View_Deviation,
						isNull(dbo.BB_Profiles_Settings.BB_Approve,0) AS BB_Approve,
						isNull(dbo.BB_Profiles_Settings.BB_DevGrid_Expected,0) AS BB_DevGrid_Expected,
					 	isNull(dbo.BB_Profiles_Settings.BB_DevGrid_ELT,0) AS BB_DevGrid_ELT,
					 	isNull(dbo.BB_Profiles_Settings.BB_DevGrid_Claimed,0) AS BB_DevGrid_Claimed,
					 	isNull(dbo.BB_Profiles_Settings.BB_DevGrid_Selected,0) AS BB_DevGrid_Selected,
						isNull(dbo.BB_Profiles_Settings.BB_Approve_Amount,0) AS BB_Approve_Amount,
						isNull(dbo.BB_Profiles_Settings.BB_Tot_Approve_Amount,0) AS BB_Tot_Approve_Amount,
				 		isNull(dbo.BB_Profiles_Settings.BB_Approve_Critical,0) AS BB_Approve_Critical,
						dbo.BB_Profiles_Settings.BB_User_ID,
						dbo.BB_Profiles_Settings.BB_Updated_Date,
						dbo.BB_Profiles_Settings.Created_Date,
						dbo.Profiles.Profiles_Desc,
						dbo.Profiles.profile_sequence,
						dbo.Profiles.Profiles_Short_Desc,
						isNull(dbo.BB_Profiles_Settings.BB_RFA_Agreed,0) AS BB_RFA_Agreed,
						isNull(dbo.BB_Profiles_Settings.BB_Pay_Req_Approval_Amount,0) AS BB_Pay_Req_Approval_Amount,
						BB_Profiles_Settings.Approve_Last_Date_To_Claim,
						BB_Profiles_Settings.BB_Reverse,
						BB_Profiles_Settings.Autopay_Reverse,
						BB_Profiles_Settings.BB_Apply_Rebate_Rates,
						ISNULL(dbo.BB_Profiles_Settings.BB_Allow_Vendor_Master_Search,0) AS BB_Allow_Vendor_Master_Search,
						BB_Profiles_Settings.Mass_Billback_Pay,
						BB_Profiles_Settings.BB_Apply_Pullback,
						BB_Profiles_Settings.BB_Apply_Pullback_Amount,
						BB_Profiles_Settings.BB_UnApply_Pullback,
						ISNULL(dbo.BB_Profiles_Settings.BB_Add_Program,0) AS BB_Add_Program,
						BB_Profiles_Settings.BB_Volume_Override,
						BB_Profiles_Settings.BB_Rate_Override,
						BB_Profiles_Settings.BB_Adjust,
						BB_Profiles_Settings.BB_Mass_Approve,
						BB_Profiles_Settings.BB_Mass_Delete,
						Approve_BB_Beyond_Budget,
						BB_Profiles_Settings.BB_Search_By_Analyst,
						ISNULL(BB_Profiles_Settings.BB_Add_Payee_Any_Position, 0) AS BB_Add_Payee_Any_Position,
						ISNULL(Credit_Memo_Amount, 0) AS Credit_Memo_Amount,
            			BB_Profiles_Settings.BB_Dev_Grid_Manual_Rate_Override_Check,
						BB_Profiles_Settings.View_BB_CRA_Analysis_Report,
						BB_Profiles_Settings.Change_BB_Start_End_Date,
						BB_Profiles_Settings.BB_Reassign,
						BB_Profiles_Settings.Void_Credit_Request,
						BB_Profiles_Settings.Display_BB_EDI_Download,
						BB_Profiles_Settings.Display_BB_User_Download,
						BB_Profiles_Settings.Display_BB_III_Party_Download,
						BB_Profiles_Settings.Auto_Approve_Analysis,
						BB_Profiles_Settings.Allow_RFA_With_Default_Program,<!---61486 : Default program only when $'s equal to $0.00... --->
						BB_Profiles_Settings.BB_Display_Dist_Channel_Per_Program_Distributor, <!--- 77469	Display Dist Channel at BB_Program Distributor Level   [ CF work ] --->
						BB_Profiles_Settings.Max_BB_Oper_Location_Level_Dup_Approval_Amount, <!--- 76536: BB Oper Location Level - dup check - Anand Rao/09-Aug-2018 --->
						BB_Profiles_Settings.View_Deviated_Items_Only_OnLoad, <!--- 79028: BB Deviation Grid - default to only display items with deviation amt greater than $0  -Anand Rao/ 06-Sep-2018 --->
						BB_Profiles_Settings.View_Count_Column_In_Deviation_Grid
						,BB_Profiles_Settings.Settlements
						,BB_Profiles_Settings.Search_Customer_Invoice
						,BB_Profiles_Settings.AQP_Max_Overspend<!---97929--->
						,BB_Profiles_Settings.AQP_Available<!---108221--->
			FROM        Profiles_Settings
			INNER JOIN
						dbo.Profiles ON dbo.Profiles_Settings.Profiles_ID = dbo.Profiles.Profiles_ID
						AND Profiles.Deleted = 0
			LEFT OUTER JOIN  dbo.BB_Profiles_Settings ON dbo.Profiles_Settings.Profiles_ID = dbo.BB_Profiles_Settings.Profiles_ID
			<cfif application.appSettingsGet.getDeduction_Module()>LEFT OUTER JOIN Deductions_Profiles_Settings ON Deductions_Profiles_Settings.Profiles_ID = Profiles_Settings.Profiles_ID</cfif>

			<!--- 57305: Retail Planner/01-Mar-2016/Anand Rao --->
			<cfif appSettings.get_Setting('Retail_Planner') eq '1'>
				LEFT OUTER JOIN dbo.Planner_Profiles_Settings ON dbo.Planner_Profiles_Settings.Profiles_ID = dbo.Profiles_Settings.Profiles_ID
			</cfif>

			AND 	(dbo.BB_Profiles_Settings.Deleted = 0)
			WHERE   (dbo.Profiles_Settings.Deleted = 0)

				<!--- Dev Note: drachala; D28010: Profile Setting modifications
						  what For: Check weather user selected any profiles if so we are passing argument into getprofiles query.	--->
			<cfif #len(arguments.profile_id)# GT 0>
			AND Profiles.Profiles_id IN ( <cfqueryparam value="#arguments.profile_id#" cfsqltype="CF_SQL_INTEGER" list="yes"	/>	)
			</cfif>
				<!--- End Dev Note: drachala; D28010: Profile Setting modifications  --->
			<cfif #arguments.UserSettingPanel# LT 5>
				AND Profiles_Settings.Settings_Panel <> 5
			</cfif>
			ORDER BY  dbo.Profiles.profile_sequence, dbo.Profiles_Settings.Profiles_ID
		</cfquery>
		<cfreturn qGetProfiles />
<!--- Profiles_ID dbo.Profiles_Settings.profile_sequence,--->
	</cffunction>

	<cffunction name="addProfile" output="false" hint="Create New Profile">

		<cfargument name="Profile_Label" type="string" required="yes">

		<cfargument name="Profile_Label_Abbr" type="string" required="yes">
	<!--- Dev Note: drachala; D28010: Profile Setting modifications
    	What For: Added Max_profile_sequence Query to get MAX profile Sequnce and assign it to NEW PROFILE--->
	<cfquery name="max_profile_sequence" datasource="#application.datasource#">
		SELECT MAX(profile_sequence) AS ps
		FROM  Profiles
		WHERE deleted = 0
	</cfquery>
<cfset new_profile_sequence = #max_profile_sequence.ps# + 1>
	<!--- End Dev Note: drachala; D28010: Profile Setting modifications  --->
			<cfquery name="insertProfile" datasource="#application.datasource#">
				SET NOCOUNT ON
				INSERT INTO Profiles
				(Profiles_Desc,Profiles_Short_Desc,Profile_sequence)
				VALUES
				('#arguments.Profile_Label#', '#arguments.Profile_Label_Abbr#', #trim(new_profile_sequence)#)
				SELECT Profiles_ID = @@IDENTITY
				SET NOCOUNT OFF
			</cfquery>

			<cfset new_Profiles_ID = insertProfile.Profiles_ID>

			<!---
			<cfset useLakebaseForInsertProfileSetting = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("profiles_settings")>
<cfif useLakebaseForInsertProfileSetting>
	<cftry>
		<cfset application.oLakebase.insertRow("profiles_settings", {
			"profiles_id" = "#insertProfile.Profiles_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsertProfileSetting = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsertProfileSetting>
<cfquery name="InsertProfileSetting" datasource="#application.datasource#">
				INSERT INTO Profiles_Settings
				(
					Profiles_ID
				)
				VALUES
				(
					#insertProfile.Profiles_ID#
				)
			</cfquery>
</cfif> --->

			<!------
			Program Templates may have access permissions for new profiles being added
			Insert records for new records here
			 ----->
			<cfquery name="qInsertProgramTemplateForbidden" datasource="#application.datasource#">
				INSERT INTO Profile_Forbidden_Template
						(Profile_ID, Template_ID, Forbid_Access_Type, Forbid_Type)
				SELECT	#new_Profiles_ID#, Template_ID, Forbid_Access_Type, Forbid_Type
				FROM	Profile_Forbidden_Template
				WHERE	Profile_ID = 0
						AND Deleted = 0
			</cfquery>

			<cfset setMarginUOMDefaultSelect(profileId = new_Profiles_ID) />

		<cfreturn this />

	</cffunction>

	<cffunction name="updateUserProfile" output="false" hint="Change a user profile to the supplied profileID">

		<cfargument name="user_id" type="string" required="yes" displayname="User ID">

		<cfargument name="profileId" type="numeric" required="yes" displayname="Profile ID">

		<CFSET AutoLogout = CreateObject("component","components.AutoLogout.AutoLogout")>
		<CFSET oReasonArray = AutoLogout.initUserReasonArray()>
		<cfset oReasonArray[arrayLen(oReasonArray)+1][1] = arguments.User_ID>
		<cfset oReasonArray[arrayLen(oReasonArray)][2] = "Your user settings have been changed which requires you to re-login.">
		<cfset temp = AutoLogout.queueUserLogout(oReasonArray)>

	</cffunction>
	<!--- Dev Note: KAL; D7821 --->
	<cffunction name="getDD_Status_Settings" output="false" hint="Get all Deduction Status Information For Supplied Profile ID">

		<!--- Dev Note: drachala; D28010: Profile Setting modifications
				  what For: Check weather user selected any profiles if so we are passing argument into getprofiles query.	--->
         	 <cfargument name="profile_id" type="string" required="no" default="">
			<!--- End Dev Note: drachala; D28010: Profile Setting modifications  --->
		<cfquery name="qGetDD_Status_Settings" datasource="#application.datasource#">
			SELECT		dbo.PROFILES.Profiles_ID,
						dbo.DD_Status.DD_Status_ID,
						dbo.DD_Status.DD_Status_Order,
						dbo.DD_Status.DD_Status_Description,
						ISNull(dbo.DD_Status_Profile_Control.IS_Checked,0) AS IS_Checked
			FROM		dbo.DD_Status
						INNER JOIN dbo.PROFILES ON 1=1
						LEFT OUTER JOIN dbo.DD_Status_Profile_Control ON
						dbo.DD_Status.DD_Status_ID = dbo.DD_Status_Profile_Control.DD_Status_ID
			and			dbo.DD_Status_Profile_Control.Profiles_ID = dbo.PROFILES.Profiles_ID
			and			dbo.DD_Status_Profile_Control.Deleted = 0
			WHERE 		dbo.PROFILES.Deleted = 0
			and 		dbo.DD_Status.Deleted = 0
			<!--- Dev Note: drachala; D28010: Profile Setting modifications
						  what For: Check weather user selected any profiles if so we are passing argument into getprofiles query.	--->
			<cfif #len(arguments.profile_id)# GT 0>
						AND Profiles.Profiles_id IN ( <cfqueryparam value="#arguments.profile_id#" cfsqltype="CF_SQL_INTEGER" list="yes"	/>	)
			</cfif>
				<!--- End Dev Note: drachala; D28010: Profile Setting modifications  --->
			ORDER BY 	dbo.PROFILES.Profiles_ID, dbo.DD_Status.DD_Status_Order
		</cfquery>

		<cfreturn qGetDD_Status_Settings />

	</cffunction>
	<!--- Dev Note: KAL; D7821 --->


	<!--- Dev Note: Clay : D7029  --->
		<cffunction name="setProfilesLock" output="false" hint="Set the Profile as Locked or Unlocked">
			<cfargument name="userID" type="string" required="no" displayname="User ID" />
			<cfargument name="lockState" type="numeric" required="no" displayname="Lock State" default="0" />

			<cfif lockState EQ 1>
				<!--- Lock Profile Settings --->
				<cfquery name="qSetLockStatus" datasource="#application.datasource#">
					Update Profiles_Settings
					Set Is_Locked = 1,
						Locked_by_User_ID = '#userID#',
						Lock_Date = GetDate()
				</cfquery>

				<cfset currentState = 1 />
			<cfelse>
				<!--- UnLock Profile Settings --->
				<cfquery name="qSetLockStatus" datasource="#application.datasource#">
					Update Profiles_Settings
					Set Is_Locked = 0,
						Locked_by_User_ID = NULL,
						Lock_Date = NULL
				</cfquery>



				<cfset currentState = 0 />
			</cfif>

			<!--- Return Lock State --->
			<cfreturn currentState />
		</cffunction>


		<cffunction name="getSequenceProfileLockStatus" output="false" hint="Return Lock Status">
			<cfset useLakebaseForqGetSequenceProfileLockStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("profiles")>
<cfif useLakebaseForqGetSequenceProfileLockStatus>
	<cftry>
		<cfset qGetSequenceProfileLockStatus = application.oLakebase.toQuery(
			application.oLakebase.selectRows("profiles", {
				"select" = "is_locked,locked_by_user_id"
			}), "is_locked,locked_by_user_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetSequenceProfileLockStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetSequenceProfileLockStatus>
<cfquery name="qGetSequenceProfileLockStatus" datasource="#application.datasource#">
				 SELECT is_locked, Locked_By_User_ID
				 FROM Profiles
			</cfquery>
</cfif>
			<cfreturn qGetSequenceProfileLockStatus />
		</cffunction>


		<cffunction name="unlocksequenceprofiles" output="false" hint="UNLOCK SEQUENCE PROFILES">
			<cfargument name="userID" type="string" required="no" displayname="User ID" />
				<!--- UNLOCK SEQUENCE PROFILES --->
				<cfquery name="qSetSequenceProfilesLockStatus" datasource="#application.datasource#">
							UPDATE PROFILES
							SET IS_LOCKED = 0,
								  LOCKED_BY_USER_ID = NULL
							WHERE LOCKED_BY_USER_ID = <cfqueryparam value="#form.USER_ID#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
		</cffunction>

		<cffunction name="getProfileLockStatus" output="false" hint="Return Lock Status">
			<!--- Query for Lock Status' (by design all current profiles should have the same value) --->
			<cfset useLakebaseForqGetProfileLockStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("profiles_settings")>
<cfif useLakebaseForqGetProfileLockStatus>
	<cftry>
		<cfset qGetProfileLockStatus = application.oLakebase.toQuery(
			application.oLakebase.selectRows("profiles_settings", {
				"select" = "is_locked,locked_by_user_id,lock_date"
			}), "is_locked,locked_by_user_id,lock_date"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetProfileLockStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetProfileLockStatus>
<cfquery name="qGetProfileLockStatus" datasource="#application.datasource#">
				select distinct Is_Locked, Locked_By_User_ID, Lock_Date
				from Profiles_Settings
			</cfquery>
</cfif>

			<cfreturn qGetProfileLockStatus />
		</cffunction>

		<cffunction name="getdistinctProfiles" output="false" hint="Return Lock Status">
			<!--- Query for Lock Status' (by design all current profiles should have the same value) --->	<!--- Dev Note: Clay : 7029  --->

<!--- Dev Note: GV : D9589   --->
			<cfset useLakebaseForqgetdistinctProfiles = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("profiles")>
<cfif useLakebaseForqgetdistinctProfiles>
	<cftry>
		<cfset qgetdistinctProfiles = application.oLakebase.toQuery(
			application.oLakebase.selectRows("profiles", {
				"deleted" = "eq.0",
				"order" = "profiles_desc.asc",
				"select" = "profiles_id,profiles_desc"
			}), "profiles_id,profiles_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetdistinctProfiles = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetdistinctProfiles>
<cfquery name="qgetdistinctProfiles" datasource="#application.datasource#">
				select DISTINCT Profiles.Profiles_ID, Profiles_Desc
				from Profiles
				where deleted = 0
				order by Profiles_Desc
			</cfquery>
</cfif>

			<cfreturn qgetdistinctProfiles />
		</cffunction>
<!--- End Dev Note: GV : D9589   --->

	<cffunction name="removeInvalidMarginUOMSelection" output="false">

		<cfargument name="profileId" type="numeric" required="yes" displayname="Profile ID">
		<!--- If application settings->approval settings level is off, ake sure it is off in the profiles settings too --->
		<cfif application.appSettingsGet.getMarginDisplayLB() EQ 0>
		<cfquery name="qRemoveInvalidMarginUOMSelectionLB" datasource="#application.datasource#">
			UPDATE	Profiles_Settings
			SET		Margin_Display_UOM_LB = 0
			WHERE	Deleted = 0
			<cfif arguments.profileId neq 0>
			AND		Profiles_ID = <cfqueryparam value="#arguments.profileId#" cfsqltype="CF_SQL_Integer">
			</cfif>
			AND		Margin_Display_UOM_LB = 1
		</cfquery>
		</cfif>

		<cfif application.appSettingsGet.getMarginDisplayCS() EQ 0>
		<cfquery name="qRemoveInvalidMarginUOMSelectionCS" datasource="#application.datasource#">
			UPDATE	Profiles_Settings
			SET		Margin_Display_UOM_CS = 0
			WHERE	Deleted = 0
			<cfif arguments.profileId neq 0>
			AND		Profiles_ID = <cfqueryparam value="#arguments.profileId#" cfsqltype="CF_SQL_Integer">
			</cfif>
			AND		Margin_Display_UOM_CS = 1
		</cfquery>
		</cfif>

		<cfif application.appSettingsGet.getMarginDisplayEQ() EQ 0>
		<cfquery name="qRemoveInvalidMarginUOMSelectionEQ" datasource="#application.datasource#">
			UPDATE	Profiles_Settings
			SET		Margin_Display_UOM_EQ = 0
			WHERE	Deleted = 0
			<cfif arguments.profileId neq 0>
			AND		Profiles_ID = <cfqueryparam value="#arguments.profileId#" cfsqltype="CF_SQL_Integer">
			</cfif>
			AND		Margin_Display_UOM_EQ = 1
		</cfquery>
		</cfif>

	</cffunction>

	<cffunction name="setMarginUOMDefaultSelect" output="false">

		<cfargument name="profileId" type="numeric" required="yes" displayname="Profile ID">
		<!--- make sure each profile has atleast one UOM selected --->
		<cfquery name="qUpdateMarginUOMDefaultSelect" datasource="#application.datasource#">
			<!--- Margin_Display_default, 1=CS, 2=EQ, 3=LB---->
			<cfif application.appSettingsGet.getMarginDisplaydefault() EQ 3>
			UPDATE	Profiles_Settings
			SET		Margin_Display_UOM_LB = 1
			WHERE	Deleted = 0
			<cfif arguments.profileId neq 0>
			AND		Profiles_ID = <cfqueryparam value="#arguments.profileId#" cfsqltype="CF_SQL_Integer">
			</cfif>
			AND		Margin_Display_UOM_LB = 0
			AND		Margin_Display_UOM_CS = 0
			AND		Margin_Display_UOM_EQ = 0
			</cfif>

			<cfif application.appSettingsGet.getMarginDisplaydefault() EQ 1>
			UPDATE	Profiles_Settings
			SET		Margin_Display_UOM_CS = 1
			WHERE	Deleted = 0
			<cfif arguments.profileId neq 0>
			AND		Profiles_ID = <cfqueryparam value="#arguments.profileId#" cfsqltype="CF_SQL_Integer">
			</cfif>
			AND		Margin_Display_UOM_LB = 0
			AND		Margin_Display_UOM_CS = 0
			AND		Margin_Display_UOM_EQ = 0
			</cfif>

			<cfif application.appSettingsGet.getMarginDisplaydefault() EQ 2>
			UPDATE	Profiles_Settings
			SET		Margin_Display_UOM_EQ = 1
			WHERE	Deleted = 0
			<cfif arguments.profileId neq 0>
			AND		Profiles_ID = <cfqueryparam value="#arguments.profileId#" cfsqltype="CF_SQL_Integer">
			</cfif>
			AND		Margin_Display_UOM_LB = 0
			AND		Margin_Display_UOM_CS = 0
			AND		Margin_Display_UOM_EQ = 0
			</cfif>
		</cfquery>

	</cffunction>

	<cffunction name="copyProfile" output="false" hint="Copy profile">
		<cfargument name="Profile_Label" type="string" required="yes">
		<cfargument name="Profile_Label_Abbr" type="string" required="yes">
		<cfargument name="Copy_Profile_ID" type="numeric" required="no" default="0">

			<cfsetting requesttimeout=1800>
			<!--- Dev Note: drachala; D28010: Profile Setting modifications
			What For: Added Max_profile_sequence Query to get MAX profile Sequnce and assign it to COPY PROFILE--->
			<cfquery name="max_profile_sequence" datasource="#application.datasource#">
			SELECT MAX(profile_sequence) AS ps
			FROM  Profiles
			WHERE deleted = 0
			</cfquery>
			<cfset new_profile_sequence = #max_profile_sequence.ps# + 1>
			<!--- End Dev Note: drachala; D28010: Profile Setting modifications  --->


			<cfquery name="insertProfile" datasource="#application.datasource#">
				SET NOCOUNT ON
				INSERT INTO Profiles
				(Profiles_Desc,Profiles_Short_Desc,Profile_sequence)
				VALUES
				('#arguments.Profile_Label#', '#arguments.Profile_Label_Abbr#', #trim(new_profile_sequence)#)
				SELECT Profiles_ID = @@IDENTITY
				SET NOCOUNT OFF
			</cfquery>
			<cfset new_Profiles_ID = insertProfile.Profiles_ID>
			<!------
			Program Templates may have access permissions for new profiles being added
			Insert records for new records here
			 ----->
			<cfquery name="qInsertProgramTemplateForbidden" datasource="#application.datasource#">
				INSERT INTO Profile_Forbidden_Template
						(Profile_ID, Template_ID, Forbid_Access_Type, Forbid_Type)
				SELECT	#new_Profiles_ID#, Template_ID, Forbid_Access_Type, Forbid_Type
				FROM	Profile_Forbidden_Template
				WHERE	Profile_ID = '#arguments.Copy_Profile_ID#'
						AND Deleted = 0
			</cfquery>
			<!--- create table to column mapping  --->
			<cfset tableList = "profiles_settings,BB_Profiles_Settings">
			<cfloop index="curTable" list="#tableList#">
				<cfquery name="getColumnsProfiles_#curTable#" datasource="#application.datasource#">
					SELECT COLUMN_NAME as curCol
					FROM INFORMATION_SCHEMA.columns
					WHERE TABLE_NAME = '#curTable#'
					order by COLUMN_NAME
				</cfquery>
				<cfloop query="getColumnsProfiles_#curTable#">
					<cfif #curCol# neq "profiles_settings_ID" and  #curCol# neq "BB_Profiles_Settings_ID"  and #curCol# neq "Profiles_ID">
						<cfquery name="saveSetting_#curCol#" datasource="#application.datasource#">
							update #curTable#
							set #curCol# = 	(select #curCol# from #curTable# where Profiles_ID = '#arguments.Copy_Profile_ID#')
							where  Profiles_ID = #new_Profiles_ID#
						</cfquery>
					</cfif>
				</cfloop>
			</cfloop>

		<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
		<cfset appSettings = application.appSettingsGet>

		<!--- Only do this for spending cap values OR if "ApproveLSComponentByProfile" is ON --->
		<cfif appSettings.getApprovalSpendingCapOn() or appSettings.getApproveLSComponentByProfile()>
			<cfquery name="GetLSApprovalAmount" datasource="#application.datasource#">
				Select *
				from Profile_LS_Approval
				where deleted = 0
				and Profiles_ID =  '#arguments.Copy_Profile_ID#'
			</cfquery>
			<cfif GetLSApprovalAmount.recordcount GT 0>
				<cfloop query="GetLSApprovalAmount">
					<cfset useLakebaseForEnterLSApprovalAmount = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("profile_ls_approval")>
<cfif useLakebaseForEnterLSApprovalAmount>
	<cftry>
		<cfset application.oLakebase.insertRow("profile_ls_approval", {
			"program_lump_sum_name_id" = "#Program_Lump_Sum_Name_ID#",
			"profiles_id" = "#new_Profiles_ID#",
			"approval_amount" = "#Approval_Amount#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForEnterLSApprovalAmount = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForEnterLSApprovalAmount>
<cfquery name="EnterLSApprovalAmount" datasource="#application.datasource#">
						INSERT INTO Profile_LS_Approval
						(
							Program_Lump_Sum_Name_ID,
							Profiles_ID,
							Approval_Amount
						)
						VALUES
						(
							#Program_Lump_Sum_Name_ID#,
							#new_Profiles_ID#,
							'#Approval_Amount#'
						)
					</cfquery>
</cfif>
				</cfloop>
			</cfif>
		</cfif>

		<cfset useLakebaseForGetMarginGroupApprovalAmount = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("margin_group_profile_approval_margins")>
<cfif useLakebaseForGetMarginGroupApprovalAmount>
	<cftry>
		<cfset GetMarginGroupApprovalAmount = application.oLakebase.toQuery(
			application.oLakebase.selectRows("margin_group_profile_approval_margins", {
				"deleted" = "eq.0",
				"profile_id" = "eq.#arguments.Copy_Profile_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetMarginGroupApprovalAmount = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetMarginGroupApprovalAmount>
<cfquery name="GetMarginGroupApprovalAmount" datasource="#application.datasource#">
				Select *
				from Margin_Group_Profile_Approval_Margins
				where Deleted = 0
				and Profile_ID =  '#arguments.Copy_Profile_ID#'
		</cfquery>
</cfif>
		<cfif GetMarginGroupApprovalAmount.recordcount GT 0>
				<cfloop query="GetMarginGroupApprovalAmount">
					<cfset useLakebaseForEnterGetMarginGroupApprovalAmount = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("margin_group_profile_approval_margins")>
<cfif useLakebaseForEnterGetMarginGroupApprovalAmount>
	<cftry>
		<cfset application.oLakebase.insertRow("margin_group_profile_approval_margins", {
			"group_id" = "#Group_ID#",
			"profile_id" = "#new_Profiles_ID#",
			"amount" = "#Amount#",
			"approval_method" = "#Approval_Method#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForEnterGetMarginGroupApprovalAmount = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForEnterGetMarginGroupApprovalAmount>
<cfquery name="EnterGetMarginGroupApprovalAmount" datasource="#application.datasource#">
						INSERT INTO Margin_Group_Profile_Approval_Margins
						(
							Group_ID,
							Profile_ID,
							Amount,
							Approval_Method
						)
						VALUES
						(
							#Group_ID#,
							#new_Profiles_ID#,
							'#Amount#',
							'#Approval_Method#'
						)
					</cfquery>
</cfif>
				</cfloop>
		</cfif>
		<cfset useLakebaseForGetGroupApprovalRights = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("group_approval_rights")>
<cfif useLakebaseForGetGroupApprovalRights>
	<cftry>
		<cfset GetGroupApprovalRights = application.oLakebase.toQuery(
			application.oLakebase.selectRows("group_approval_rights", {
				"deleted" = "eq.0",
				"user_profile_id" = "eq.#arguments.Copy_Profile_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetGroupApprovalRights = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetGroupApprovalRights>
<cfquery name="GetGroupApprovalRights" datasource="#application.datasource#">
				Select *
				from Group_Approval_Rights
				where Deleted = 0
				and User_Profile_ID =  '#arguments.Copy_Profile_ID#'
		</cfquery>
</cfif>
		<cfif GetGroupApprovalRights.recordcount GT 0>
				<cfloop query="GetGroupApprovalRights">
					<cfset useLakebaseForEnterGetGroupApprovalRights = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("group_approval_rights")>
<cfif useLakebaseForEnterGetGroupApprovalRights>
	<cftry>
		<cfset application.oLakebase.insertRow("group_approval_rights", {
			"user_profile_id" = "#new_Profiles_ID#",
			"group_id" = "#Group_ID#",
			"group_type" = "#Group_type#",
			"group_id_approval" = "#Group_ID_Approval#",
			"group_id_margin" = "#Group_ID_Margin#",
			"group_id_spend_dollar" = "#Group_ID_Spend_Dollar#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForEnterGetGroupApprovalRights = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForEnterGetGroupApprovalRights>
<cfquery name="EnterGetGroupApprovalRights" datasource="#application.datasource#">
						INSERT INTO Group_Approval_Rights
						(
							User_Profile_Id,
							Group_ID,
							Group_type,
							Group_ID_Approval,
							Group_ID_Margin,
							Group_ID_Spend_Dollar
						)
						VALUES
						(
							#new_Profiles_ID#,
							'#Group_ID#',
							#Group_type#,
							#Group_ID_Approval#,
							'#Group_ID_Margin#',
							'#Group_ID_Spend_Dollar#'
						)
					</cfquery>
</cfif>
				</cfloop>
		</cfif>

		<!--- Operating Group --->
		<cfif appSettings.getOperatingGroupOn()>
			<cfset useLakebaseForGetOperatingGroupProfileMap = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("operating_group_profile_map")>
<cfif useLakebaseForGetOperatingGroupProfileMap>
	<cftry>
		<cfset GetOperatingGroupProfileMap = application.oLakebase.toQuery(
			application.oLakebase.selectRows("operating_group_profile_map", {
				"deleted" = "eq.0",
				"profiles_id" = "eq.#arguments.Copy_Profile_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetOperatingGroupProfileMap = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetOperatingGroupProfileMap>
<cfquery name="GetOperatingGroupProfileMap" datasource="#application.datasource#">
				Select *
				from Operating_Group_Profile_Map
				where Deleted = 0
				and Profiles_ID =  '#arguments.Copy_Profile_ID#'
			</cfquery>
</cfif>
			<cfif GetOperatingGroupProfileMap.recordcount GT 0>
			<cfloop query="GetOperatingGroupProfileMap">
				<cfset useLakebaseForEnterOperatingGroupProfileMap = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("operating_group_profile_map")>
<cfif useLakebaseForEnterOperatingGroupProfileMap>
	<cftry>
		<cfset application.oLakebase.insertRow("operating_group_profile_map", {
			"operating_group_id" = "#Operating_Group_ID#",
			"profiles_id" = "#new_Profiles_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForEnterOperatingGroupProfileMap = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForEnterOperatingGroupProfileMap>
<cfquery name="EnterOperatingGroupProfileMap" datasource="#application.datasource#">
					INSERT INTO Operating_Group_Profile_Map
					(
						Operating_Group_ID,
						Profiles_ID
					)
					VALUES
					(
						#Operating_Group_ID#,
						'#new_Profiles_ID#'
					)
				</cfquery>
</cfif>
			</cfloop>
			</cfif>
		</cfif>

		<!------ Post Approval Status ----->
		<cfif appSettings.getPgmPostApprovalStatus()>
			<cfset useLakebaseForGetProfilePostApprovalStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("profile_post_approval_status")>
<cfif useLakebaseForGetProfilePostApprovalStatus>
	<cftry>
		<cfset GetProfilePostApprovalStatus = application.oLakebase.toQuery(
			application.oLakebase.selectRows("profile_post_approval_status", {
				"deleted" = "eq.0",
				"profiles_id" = "eq.#arguments.Copy_Profile_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetProfilePostApprovalStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetProfilePostApprovalStatus>
<cfquery name="GetProfilePostApprovalStatus" datasource="#application.datasource#">
				Select *
				from Profile_Post_Approval_Status
				where Deleted = 0
				and Profiles_ID =  '#arguments.Copy_Profile_ID#'
			</cfquery>
</cfif>
			<cfif GetProfilePostApprovalStatus.recordcount GT 0>
				<cfloop query="GetProfilePostApprovalStatus" >
					<cfset useLakebaseForEnterProfilePostApprovalStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("profile_post_approval_status")>
<cfif useLakebaseForEnterProfilePostApprovalStatus>
	<cftry>
		<cfset application.oLakebase.insertRow("profile_post_approval_status", {
			"program_post_approval_status_id" = "#Program_Post_Approval_Status_ID#",
			"profiles_id" = "#new_Profiles_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForEnterProfilePostApprovalStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForEnterProfilePostApprovalStatus>
<cfquery name="EnterProfilePostApprovalStatus" datasource="#application.datasource#">
						INSERT INTO Profile_Post_Approval_Status
						(
							Program_Post_Approval_Status_ID,
							Profiles_ID
						)
						VALUES
						(
							'#Program_Post_Approval_Status_ID#',
							'#new_Profiles_ID#'
						)
					</cfquery>
</cfif>
				</cfloop>

			</cfif>
		</cfif>
		<!--- deductions --->
		<!--- <cfif application.deductionLinksAvailable> --->
		<cfif application.appSettingsGet.getDeduction_Module()>
			<cfset useLakebaseForInsertDeductionsProfilesSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions_profiles_settings")>
<cfif useLakebaseForInsertDeductionsProfilesSettings>
	<cftry>
		<cfset application.oLakebase.insertRow("deductions_profiles_settings", {
			"profiles_id" = "#new_Profiles_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsertDeductionsProfilesSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsertDeductionsProfilesSettings>
<cfquery name="InsertDeductionsProfilesSettings" datasource="#application.datasource#">
				INSERT INTO Deductions_Profiles_Settings (Profiles_ID) VALUES ('#new_Profiles_ID#')
			</cfquery>
</cfif>
			<cfquery name="getDeductionsProfilesSettingsCol" datasource="#application.datasource#">
					SELECT COLUMN_NAME as DDProfilesSettings
					FROM INFORMATION_SCHEMA.columns
					WHERE TABLE_NAME = 'Deductions_Profiles_Settings'
					order by COLUMN_NAME
			</cfquery>
			<cfloop query="getDeductionsProfilesSettingsCol">
					<cfif #DDProfilesSettings#  neq "DD_Profile_Settings_ID" and #DDProfilesSettings#  neq "Profiles_ID">
						<cfquery name="saveSetting_#DDProfilesSettings#" datasource="#application.datasource#">
							update Deductions_Profiles_Settings
							set #DDProfilesSettings# = 	(select #DDProfilesSettings# from Deductions_Profiles_Settings where Profiles_ID = '#arguments.Copy_Profile_ID#')
							where  Profiles_ID = #new_Profiles_ID#
						</cfquery>

					</cfif>
			</cfloop>
		</cfif>
		<!--- customer type --->
		<cfset UseCustomerType = appSettings.getCustomertype()>
		<cfif UseCustomerType IS 1>
			<cfset useLakebaseForGetCustomertypeValues = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("profile_customer_type_settings")>
<cfif useLakebaseForGetCustomertypeValues>
	<cftry>
		<cfset GetCustomertypeValues = application.oLakebase.toQuery(
			application.oLakebase.selectRows("profile_customer_type_settings", {
				"profiles_id" = "eq.#arguments.Copy_Profile_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetCustomertypeValues = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetCustomertypeValues>
<cfquery name="GetCustomertypeValues" datasource="#application.datasource#">
				Select *
				from Profile_Customer_Type_Settings
				where  Profiles_ID =  '#arguments.Copy_Profile_ID#'
			</cfquery>
</cfif>
			<cfif GetCustomertypeValues.recordcount GT 0>
				<cfloop query="GetCustomertypeValues" >
					<cfset useLakebaseForEnterGetOperatingGroupProfileMap = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("profile_customer_type_settings")>
<cfif useLakebaseForEnterGetOperatingGroupProfileMap>
	<cftry>
		<cfset application.oLakebase.insertRow("profile_customer_type_settings", {
			"profiles_id" = "#new_Profiles_ID#",
			"customer_type_id" = "#customer_type_id#",
			"profile_customer_type_value" = "#Profile_Customer_Type_Value#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForEnterGetOperatingGroupProfileMap = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForEnterGetOperatingGroupProfileMap>
<cfquery name="EnterGetOperatingGroupProfileMap" datasource="#application.datasource#">
						INSERT INTO Profile_Customer_Type_Settings
						(
							Profiles_ID,
							customer_type_id,
							Profile_Customer_Type_Value
						)
						VALUES
						(
							#new_Profiles_ID#,
							#customer_type_id#,
							#Profile_Customer_Type_Value#
						)
					</cfquery>
</cfif>
				</cfloop>
			</cfif>
		</cfif>

		<!--- COPY OVER CLOSING METHODS --->
		<cfquery name="INSERTBPCM" datasource="#application.datasource#">
			INSERT INTO BB_Profile_Closing_Methods (Profile_ID, Billback_Closing_Method_ID)
			SELECT #new_Profiles_ID#,Billback_Closing_Method_ID
			FROM  BB_Profile_Closing_Methods
			WHERE Profile_ID = '#arguments.Copy_Profile_ID#'
			AND Deleted = 0
		</cfquery>

		<!--- PLANNER SETTINGS --->
<cfif appSettings.get_Setting('Retail_Planner') eq '1'>

	<cfquery name="InsertPlannerSettings" datasource="#application.datasource#">
		INSERT INTO Planner_Profiles_Settings(
			Profiles_ID ,Planner_Create ,Planner_Margin_View ,Planner_Approval_Rights ,Marketing_Events_Create, Planner_Product_Calendar
		 ,Planner_Strategic_Guidelines ,NUC_Targets_Create ,Planner_Reassign ,Planner_Catalog,Planner_Max_Total_Spend, Planner_Target_Max_Overspend,
		 Planner_Target_Approval_Dollar, Planner_Target_Max_Slotting_Target_Increase
		)

		SELECT 	#new_Profiles_ID# ,Planner_Create ,Planner_Margin_View ,Planner_Approval_Rights ,Marketing_Events_Create, Planner_Product_Calendar
		 							,Planner_Strategic_Guidelines ,NUC_Targets_Create ,Planner_Reassign ,Planner_Catalog,Planner_Max_Total_Spend, Planner_Target_Max_Overspend,
				Planner_Target_Approval_Dollar, Planner_Target_Max_Slotting_Target_Increase
		FROM  Planner_Profiles_Settings
		WHERE Profiles_ID = '#arguments.Copy_Profile_ID#'
		AND Deleted = 0
	</cfquery>

</cfif>
	
	<!--- Settings control Panel --->
	<cfquery name="INSERTSCP" datasource="#application.datasource#">
			INSERT INTO Settings_Panel_Access_Modules_Profiles (Profiles_ID, Settings_Panel_Access_Modules_ID)
			SELECT #new_Profiles_ID#,Settings_Panel_Access_Modules_ID
			FROM  Settings_Panel_Access_Modules_Profiles
			WHERE Profiles_ID = '#arguments.Copy_Profile_ID#'
	</cfquery>

		<cfreturn this />
	</cffunction>

	<cffunction name="isActiveUsersAssociateToProfile" output="No" returntype="boolean">
		<cfargument name="profileId" type="numeric" required="yes" displayname="Profile ID">
		<cfset isActiveUsersWithProfile = 0 />
		<cfset useLakebaseForgetActiveUsersWithProfile = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForgetActiveUsersWithProfile>
	<cftry>
		<cfset getActiveUsersWithProfile = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"deleted" = "eq.0",
				"profiles_id" = "eq.#arguments.profileId#",
				"select" = "user_id"
			}), "user_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetActiveUsersWithProfile = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetActiveUsersWithProfile>
<cfquery name="getActiveUsersWithProfile" datasource="#application.datasource#">
			SELECT 	User_ID
			FROM 	_Users
			WHERE 	Deleted = 0
			AND 	Profiles_ID = '#arguments.profileId#'
		</cfquery>
</cfif>
		<cfif getActiveUsersWithProfile.recordcount GT 0>
			<cfset isActiveUsersWithProfile = 1/>
		</cfif>

		<cfreturn isActiveUsersWithProfile />
	</cffunction>

</cfcomponent>