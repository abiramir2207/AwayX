<cfsetting requestTimeOut = "180">

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = application.appSettingsGet>
<!--- establish default values for the checkboxes --->
<cfset useLakebaseForGetCustomerTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("customer_type")>
<cfif useLakebaseForGetCustomerTypes>
	<cftry>
		<cfset GetCustomerTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("customer_type", {
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetCustomerTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetCustomerTypes>
<cfquery name="GetCustomerTypes" datasource="#application.datasource#">
SELECT *
FROM Customer_Type
WHERE Deleted = 0
</cfquery>
</cfif>

<CFSET getProfiles = CreateObject("component", "components.settings.profiles.profile").getAllProfiles()>

<cfset useLakebaseForDeleteAllPriorCustomerTypeValues = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("profile_customer_type_settings")>
<cfif useLakebaseForDeleteAllPriorCustomerTypeValues>
	<cftry>
		<cfset application.oLakebase.deleteRows("profile_customer_type_settings", {})>
		<cfcatch type="any">
			<cfset useLakebaseForDeleteAllPriorCustomerTypeValues = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeleteAllPriorCustomerTypeValues>
<cfquery name="DeleteAllPriorCustomerTypeValues" datasource="#application.datasource#">
	Delete from Profile_Customer_Type_Settings
</cfquery>
</cfif>

<CFLOOP query="GetCustomerTypes">
	<CFSET j = GetCustomerTypes.customer_type_id>
	<cfloop query="getProfiles">
		<cfset i = getProfiles.profiles_id>
		<cfset Default_FieldName = "Customer_Type">
			<cfset thisFieldName = "#trim(Default_FieldName)#_#j#_#i#">
			<cfparam name="form.#thisFieldName#" default="0">
			<cfset useLakebaseForInsertCustomertypeValues = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("profile_customer_type_settings")>
<cfif useLakebaseForInsertCustomertypeValues>
	<cftry>
		<cfset application.oLakebase.insertRow("profile_customer_type_settings", {
			"profiles_id" = "#i#",
			"customer_type_id" = "#j#",
			"profile_customer_type_value" = "#evaluate(thisFieldName)#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsertCustomertypeValues = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsertCustomertypeValues>
<cfquery name="InsertCustomertypeValues" datasource="#application.datasource#">
				INSERT INTO Profile_Customer_Type_Settings
				(
					Profiles_ID,
					customer_type_id,
					Profile_Customer_Type_Value
				)
				VALUES
				(
					#i#,
					#j#,
					#evaluate(thisFieldName)#
				)
			</cfquery>
</cfif>
	</cfloop>
</CFLOOP>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Save the profile settings																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!---only do this for spending cap values--->
<cfif appSettings.getApprovalSpendingCapOn() and appSettings.getApproveLSComponentByProfile() NEQ 1>
	<!---Deletes all values for active, non-deleted Lump sum approval amounts--->
	<cfquery name="DeleteAllPriorLSValues" datasource="#application.datasource#">
	Delete from Profile_LS_Approval
	WHERE Program_Lump_Sum_Name_ID IN (Select Program_Lump_Sum_Name_ID FROM Program_Lump_Sum_Name WHERE Deleted = 0 AND Active = 1)
	</cfquery>
</cfif>

<!--- Loops through all the form variables and  saves the settings  --->
<CFLOOP INDEX="Item" LIST="#Form.FieldNames#" DELIMITERS=",">

      <cfif appSettings.getApprovalSpendingCapOn() and appSettings.getApproveLSComponentByProfile() NEQ 1>
	<!---Lump sum approval amounts--->

	<cfif Left(Item,22) IS "PROGRAM_LUMP_SUM_NAME_">
		<cfset VarLen = len(Item)>
		<cfset IDs_Only = right(item,(VarLen - 22))>
		<cfset IDs_Only_len = len(IDs_Only)>
		<cfset Underscorelocation  = find("_",IDs_Only)>
		<cfset Profile_ID = left(IDs_Only,Underscorelocation-1)>


		<cfset Program_Lump_Sum_Name_ID = right(IDs_Only, (IDs_Only_len - Underscorelocation))>
		<cfset useLakebaseForEnterLSApprovalAmount = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("profile_ls_approval")>
<cfif useLakebaseForEnterLSApprovalAmount>
	<cftry>
		<cfset application.oLakebase.insertRow("profile_ls_approval", {
			"program_lump_sum_name_id" = "#Program_Lump_Sum_Name_ID#",
			"profiles_id" = "#Profile_ID#",
			"approval_amount" = "#evaluate(item)#"
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
			#Profile_ID#,
			'#evaluate(item)#'
		)
		</cfquery>
</cfif>
	</cfif>

      </cfif>
	<CFIF ucase(item) NEQ "PROGRAM_MARGIN_APPROVAL_METHOD">

		<!---TSF: Label 10108 - Added and extra and condition for the SELECTALLPROFILES form field--->
		<CFIF LEFT(item,3) NEQ "BB_" AND LEFT(item,14) NEQ "Customer_type_" AND left(item,5) NEQ "GROUP" AND LEFT(item,3) NEQ "DD_" AND LEFT(item,22) NEQ "PROGRAM_LUMP_SUM_NAME_" AND UCase(item) NEQ "READONLYMODE" and UCase(trim(item)) NEQ "SELECTALLPROFILES" and UCASE(trim(item)) NEQ "RELEASESETTLEMENT"
		 AND UCASE(trim(item)) NEQ "APPROVE_EXPORT_AGREEMENTS" AND UCASE(trim(item)) NEQ "CREATE_EXPORT_AGREEMENTS"  AND UCASE(trim(item)) NEQ "CREATE_APPROVE_EXPORT_AGREEMENTS" AND UCASE(trim(item)) NEQ "CREATE_NEW_EXPORT_CUSTOMER" AND UCASE(trim(item)) NEQ "CREDIT_MANAGER"
		 AND UCASE(trim(item)) NEQ "FREIGHT_VIEW_CREATE" AND UCASE(trim(item)) NEQ "APPROVE_FREIGHT_PROGRAMS" AND UCASE(trim(item)) NEQ "SEARCH_DOCUMENTS" AND UCase(item) NEQ "SHOWMESSAGE">
			<cfoutput>#item#</cfoutput><br>

			<!--- Reverse variable --->
			<CFSET reversed=reverse(item)>
			<!--- Find the placement of the first "_" --->
			<CFSET firstdash=find("_",reversed)>
			<cfset stringlen = len(item)>

			<!---figures out the profile number and the field name--->
			<cfset preamble_len = stringlen - firstdash>
			<cfset fieldname = left(item, preamble_len)>
			<cfset Profiles_ID = right(item, (firstdash-1))>

		</CFIF>
	<cfelse>
		<cfquery name="saveToGeneralSettings" datasource="#application.datasource#">
			UPDATE General_Settings
			SET program_margin_approval_method = '#FORM.program_margin_approval_method#'
		</cfquery>

	</CFIF>
</CFLOOP>

<cfset AvailableApprovalOptions = genSettingsManager.getApprovalTypeList()>
<cfset UserSetting = CreateObject("component","components.user.Profile").getUserSettingsPanel(request.AccessStructure.Profiles_ID)>

	<!--- Dev Note: drachala; D28010: Profile Setting modifications
		  what For: Check weather user selected any profiles if so we are passing argument into getprofiles query.	--->

	<cfset profile_id = ''>
	<cfif isdefined("url.profile_id")>
		<cfset profile_id = #trim(url.profile_id)#>
	</cfif>

<CFSET getProfiles = CreateObject("component", "components.settings.profiles.profile").getAllProfiles(profile_id=profile_id,UserSettingPanel=UserSetting.Settings_Panel)>

	<!--- End Dev Note: drachala; D28010: Profile Setting modifications  --->



<CFLOOP INDEX="ThisApprovalType" list="#AvailableApprovalOptions#">
	<CFLOOP INDEX="GroupCount" FROM="1" TO="#application.returned_customer_setting.approval_group_count#" STEP="1">
		<cfloop query="getProfiles">
			<cfset ProfileCount = getProfiles.profiles_id>
			<cfset ApprovalValueFileName = "Group_Approval_Type_#ThisApprovalType#_#GroupCount#_Profile_#ProfileCount#">
			<cfparam name="FORM.#ApprovalValueFileName#" 	default="0">
			<cfif isdefined("FORM.#ApprovalValueFileName#")>
				<cfset ApprovalValue = Evaluate("FORM.#ApprovalValueFileName#")>
				<cfset useLakebaseForDoesPairingExist = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("margin_group_profile_approval_margins")>
<cfif useLakebaseForDoesPairingExist>
	<cftry>
		<cfset DoesPairingExist = application.oLakebase.toQuery(
			application.oLakebase.selectRows("margin_group_profile_approval_margins", {
				"group_id" = "eq.#GroupCount#",
				"profile_id" = "eq.#ProfileCount#",
				"approval_method" = "eq.#ThisApprovalType#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDoesPairingExist = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDoesPairingExist>
<cfquery name="DoesPairingExist" datasource="#application.datasource#">
					SELECT 	*
					FROM 	Margin_Group_Profile_Approval_Margins
					WHERE 	Group_ID = '#GroupCount#'
							AND Profile_ID= '#ProfileCount#'
							AND Approval_Method = #ThisApprovalType#
				</cfquery>
</cfif>

				<cfif DoesPairingExist.Recordcount GT 0>
					<CFQUERY NAME="updateApprovalAmt" datasource="#application.datasource#">
						UPDATE 	Margin_Group_Profile_Approval_Margins
						SET 	Amount = <CFIF trim(ApprovalValue) EQ "*">'*'<CFELSE>'#trim(numberformat(ApprovalValue, '____________________________.___'))#'</CFIF>
						WHERE 	Group_ID = '#GroupCount#'
								AND Profile_ID= '#ProfileCount#'
								AND Approval_Method = #ThisApprovalType#
					</CFQUERY>
				<cfelse>
					<Cfquery name="InsertApprovalAmt" datasource="#application.datasource#">
					INSERT INTO Margin_Group_Profile_Approval_Margins
					(
						Group_ID,
						Profile_ID,
						Approval_Method,
						Amount
					)
					VALUES
					(
						'#GroupCount#',
						'#ProfileCount#',
						'#ThisApprovalType#',
						<CFIF trim(ApprovalValue) EQ "*">'*'<CFELSE>'#trim(numberformat(ApprovalValue, '____________________________.___'))#'</CFIF>
					)
					</CFQUERY>
				<!---Makes sure it exists to be updated--->
				</cfif>
			</cfif>
		</CFLOOP>
	</CFLOOP>
</CFLOOP>

<!--- save approval data --->
<!------
<CFSET getProfiles = CreateObject("component", "components.settings.profiles.profile").getAllProfiles()>
<CFLOOP INDEX="GroupCount" FROM="1" TO="#application.returned_customer_setting.approval_group_count#" STEP="1">
	<cfloop query="getProfiles"><cfset ProfileCount = getProfiles.profiles_id>
		<cfif isdefined("FORM.Group_#GroupCount#_Profile_#ProfileCount#")>

		<cfquery name="DoesPairingExist" datasource="#application.datasource#">
		SELECT *
		FROM Margin_Group_Profile_Approval_Margins
		WHERE Group_ID = '#GroupCount#' AND Profile_ID= '#ProfileCount#'
		</cfquery>

		<Cfif DoesPairingExist.Recordcount GT 0>
			<CFQUERY NAME="updateApprovalAmt" datasource="#application.datasource#">
				UPDATE Margin_Group_Profile_Approval_Margins
				SET Amount = <CFIF trim(evaluate("FORM.Group_#GroupCount#_Profile_#ProfileCount#")) EQ "*">'*'<CFELSE>'#trim(numberformat(evaluate("FORM.Group_#GroupCount#_Profile_#ProfileCount#"), '____________________________.___'))#'</CFIF>
				WHERE Group_ID = '#GroupCount#' AND Profile_ID= '#ProfileCount#'
			</CFQUERY>
		<cfelse>
			<Cfquery name="InsertApprovalAmt" datasource="#application.datasource#">
			INSERT INTO Margin_Group_Profile_Approval_Margins
			(
				Group_ID,
				Profile_ID,
				Amount
			)
			VALUES
			(
				'#GroupCount#',
				'#ProfileCount#',
				<CFIF trim(evaluate("FORM.Group_#GroupCount#_Profile_#ProfileCount#")) EQ "*">'*'<CFELSE>'#trim(numberformat(evaluate("FORM.Group_#GroupCount#_Profile_#ProfileCount#"), '____________________________.___'))#'</CFIF>
			)
			</CFQUERY>
		<!---Makes sure it exists to be updated--->
		</CFIF>
		</cfif>
	</CFLOOP>
</CFLOOP>
 ----->

<!---<cfif application.deductionLinksAvailable> --->
<cfif application.appSettingsGet.getDeduction_Module()>
<!------ Deduction ----->
<CFINCLUDE TEMPLATE="\deductions\settings\deduction_access_rights_action.cfm">
</cfif>

<CFINCLUDE TEMPLATE="\billbacks\settings\access_rights_action.cfm">
<!--- Return to Matrix --->

<!--- Operating Group --->
<cfif appSettings.getOperatingGroupOn()>
	<CFINCLUDE TEMPLATE="\settings\operating_group\access_rights_action.cfm">
</cfif>

<!--- START: 57305: Retail Planner/01-Mar-2016/Anand Rao --->
<cfif appSettings.get_Setting('Retail_Planner') eq '1'>
	  <cfinclude template="planners_access_rights_action.cfm">
</cfif>
<!--- END:  57305: Retail Planner/01-Mar-2016/Anand Rao --->

<!------ Post Approval Status ----->
<cfif appSettings.getPgmPostApprovalStatus() EQ 1>
	<cfset ProgramPostApprovalStatusManager = CreateObject("component", "components.programs.ProgramPostApprovalStatusManager").init() />

	<cfset qGetProfileProgramPostApprovalStatus = ProgramPostApprovalStatusManager.getProfileProgramPostApprovalStatus() />




								<!--- Dev Note: drachala; D28010: Profile Setting modifications
									  What For: Check weather user selected any profiles if so we run Query OF Query on getprofiles query.--->
								<cfif isdefined("url.profile_id") AND len(url.profile_id) GT 0>
								<cfquery name="QOQ6" dbtype="query">
								SELECT *
								FROM qGetProfileProgramPostApprovalStatus
								WHERE Profiles_id IN ( <cfqueryparam value="#trim(url.profile_id)#" cfsqltype="CF_SQL_INTEGER" list="yes"	/>	)
								</cfquery>
								<cfset qGetProfileProgramPostApprovalStatus = QOQ6>
								</cfif>
								<!--- End Dev Note: drachala; D28010: Profile Setting modifications  --->




	<!------ delete ----->
	<cfquery name="ForbiddenList" datasource="#application.datasource#">
		UPDATE	Profile_Post_Approval_Status
		SET		Deleted = 1
		WHERE	Deleted = 0
		<!--- Dev Note: drachala; D28010: Profile Setting modifications
		What For: Check weather user selected any profiles if so we run Query OF Query on getprofiles query.--->
		<cfif isdefined("url.profile_id") AND len(url.profile_id) GT 0>
		AND Profiles_id IN ( <cfqueryparam value="#trim(url.profile_id)#" cfsqltype="CF_SQL_INTEGER" list="yes"	/>	)
		</cfif>
			<!--- End Dev Note: drachala; D28010: Profile Setting modifications  --->
	</cfquery>



	<cfoutput query="qGetProfileProgramPostApprovalStatus" group="Program_Post_Approval_Status_ID">
		<cfset Current_Program_Post_Approval_Status_ID = Program_Post_Approval_Status_ID />
		<cfoutput>
		<cfset thisFieldName = "ProfileProgramPostApprovalStatus_#Current_Program_Post_Approval_Status_ID#_#Profiles_ID#" />
		<cfparam name="form.#thisFieldName#" default="0">
		<cfif Evaluate("form.#thisFieldName#") EQ 1>
			<!------ insert ----->
			<cfquery name="qInsertProfilePostApprovalStatus" datasource="#application.datasource#">
				INSERT INTO Profile_Post_Approval_Status
				(
					Program_Post_Approval_Status_ID,
					Profiles_ID
				)
				VALUES
				(
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Current_Program_Post_Approval_Status_ID#" />,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Profiles_ID#" />
				)
			</cfquery>
		</cfif>
		</cfoutput>
	</cfoutput>
</cfif>

<CFINCLUDE TEMPLATE="\settings\access_rights\update_access_rights.cfm">

<!--- Write the changes to the Log Table...SOX...as in Sarbanes, not the hackers in Red! --->

 <!--- <CFINCLUDE TEMPLATE="\settings\access_rights\profiles_settings_log.cfm"> --->

<cfif isdefined("url.profile_id") and len(url.profile_id) GT 0>
	<cfset profile_id = #trim(url.profile_id)#>
<cfelse>
	<cfset profile_id = "">
</cfif>

<CFLOCATION URL="index.cfm?profile_id=#profile_id#" ADDTOKEN="No">
