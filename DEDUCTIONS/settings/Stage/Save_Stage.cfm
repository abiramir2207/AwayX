
<CFPARAM NAME="Form.Is_Default" DEFAULT="0">
<CFPARAM NAME="Form.AUTOREMINDER" DEFAULT="0">
<CFPARAM NAME="Form.DD_STAGE_AUTO_REMINDER_DAYS" DEFAULT="0">
<CFPARAM NAME="form.Action_Analyst_Profile" DEFAULT="">

	<cfset  genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset  appSettings = genSettingsManager.get()>	
	
<cfif form.DD_STAGE_AUTO_REMINDER_DAYS eq "">
	<cfset form.DD_STAGE_AUTO_REMINDER_DAYS = 0 >
</cfif>

<!--- Delete record --->
<CFIF FORM.DeleteRecord EQ 1>
	<CFTRANSACTION ACTION="BEGIN">
	<cfset useLakebaseFordelete_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_stage")>
	<cfif useLakebaseFordelete_Data>
		<cftry>
			<cfset application.oLakebase.deleteRows("dd_stage", { "dd_stage_id" = "eq.#Form.DD_Stage_ID#" })>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseFordelete_Data = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseFordelete_Data>
	<CFQUERY NAME="delete_Data" datasource="#application.datasource#">
		DELETE FROM DD_Stage WHERE DD_Stage_ID = '#Form.DD_Stage_ID#'
	</CFQUERY>
	</cfif>
	<!--- 70923 :: Create new feature for deduction workflow START--->
	<cfset useLakebaseFordelete_Analyst_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_action_analyst")>
	<cfif useLakebaseFordelete_Analyst_Data>
		<cftry>
			<cfset application.oLakebase.deleteRows("dd_action_analyst", { "dd_stage_id" = "eq.#Form.DD_Stage_ID#" })>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseFordelete_Analyst_Data = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseFordelete_Analyst_Data>
	<CFQUERY NAME="delete_Analyst_Data" datasource="#application.datasource#">
		DELETE FROM DD_Action_Analyst WHERE DD_Stage_ID = '#Form.DD_Stage_ID#'
	</CFQUERY>
	</cfif>
	<!--- 70923 :: Create new feature for deduction workflow END--->
	<cfset useLakebaseForgetDefault = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_stage")>
	<cfif useLakebaseForgetDefault>
		<cftry>
			<cfset getDefault = application.oLakebase.toQuery(
				application.oLakebase.selectRows("dd_stage", {
					"select" = "dd_stage_id",
					"deleted" = "eq.0",
					"is_default" = "eq.1"
				}),
				"dd_stage_id"
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForgetDefault = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForgetDefault>
	<CFQUERY NAME="getDefault" DATASOURCE="#Application.Datasource#">
		SELECT DD_Stage_ID FROM DD_Stage WHERE Deleted=0 AND Is_Default = 1
	</CFQUERY>
	</cfif>
	<CFIF getDefault.Recordcount GT 0>
		<cfset useLakebaseForUpdateDDStages = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
		<cfif useLakebaseForUpdateDDStages>
			<cftry>
				<cfset application.oLakebase.updateRows("deductions",
					{ "dd_stage" = "eq.#Form.DD_Stage_ID#" },
					{ "dd_stage" = getDefault.DD_Stage_ID }
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForUpdateDDStages = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForUpdateDDStages>
		<CFQUERY NAME="UpdateDDStages" DATASOURCE="#Application.Datasource#">
			UPDATE 	Deductions
			SET 	DD_Stage = '#getDefault.DD_Stage_ID#'
			WHERE	DD_Stage = '#Form.DD_Stage_ID#'
		</CFQUERY>
		</cfif>
	</CFIF>
	<CFTRANSACTION ACTION = "COMMIT">
	</CFTRANSACTION>
	<CFLOCATION URL="create_Stage.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>

	<cfset useLakebaseForIsThereDefault = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_stage")>
	<cfif useLakebaseForIsThereDefault>
		<cftry>
			<cfset IsThereDefault = application.oLakebase.toQuery(
				application.oLakebase.selectRows("dd_stage", {
					"is_default" = "eq.1"
				})
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForIsThereDefault = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForIsThereDefault>
	<cfquery name="IsThereDefault" datasource="#application.datasource#">
		SELECT * FROM DD_Stage WHERE Is_Default = 1
	</cfquery>
	</cfif>
	<!---See if something is already set as default--->
	<cfparam name="SetAsDefault" default="0">
	<cfif val(appSettings.get_Setting('Custom_Deduction_workflow')) eq '0'>
		<cfif IsThereDefault.RecordCount IS 0>
			<cfset SetAsDefault = 1>
			<cfset Form.Is_Default = 1>
		</cfif>
	</cfif>
	<!--- remove the default from another entry if necessary --->
	<cfif Form.Is_Default IS 1>
		<cfset useLakebaseForRemoveDefault = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_stage")>
		<cfif useLakebaseForRemoveDefault>
			<cftry>
				<cfset application.oLakebase.updateRows("dd_stage",
					{ "is_default" = "eq.1" },
					{ "is_default" = 0 }
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForRemoveDefault = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForRemoveDefault>
		<cfquery name="RemoveDefault" datasource="#application.datasource#">
			UPDATE DD_Stage
			Set Is_Default = 0
			WHERE Is_Default = 1
		</cfquery>
		</cfif>
	</cfif>
<CFIF Form.DD_Stage_ID EQ "">
	<!--- Insert the record --->
	<cfset useLakebaseForSave_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_stage")>
<cfif useLakebaseForSave_Data>
	<cftry>
		<cfset application.oLakebase.insertRow("dd_stage", {
			"dd_stage_description" = "#Form.DD_Stage_Description#",
			"deleted" = "#Form.Deleted#",
			"is_default" = "#Form.Is_Default#",
			"is_auto_reminded" = "#Form.AUTOREMINDER#",
			"auto_default_days" = "#Form.DD_Stage_Auto_Reminder_Days#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForSave_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSave_Data>
<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		INSERT INTO DD_Stage (DD_Stage_Description,Deleted,Is_Default,Is_Auto_Reminded,Auto_Default_Days)
		Values ('#Form.DD_Stage_Description#',#Form.Deleted#,#Form.Is_Default#,#Form.AUTOREMINDER#,#Form.DD_Stage_Auto_Reminder_Days#)
		SELECT SCOPE_IDENTITY() AS SCOPEIDENTITY;
	</CFQUERY>
</cfif>
	<cfloop from="1" to="#listlen(form.Action_Analyst_Profile)#" index="A">
		<CFQUERY NAME="Save_Analyst_Data" datasource="#application.datasource#">
			INSERT INTO DD_Action_Analyst(DD_Stage_ID,Analyst_User_ID)
			Values(#Save_Data.SCOPEIDENTITY#,'#listgetat(form.Action_Analyst_Profile, A)#')
		</CFQUERY>
	</cfloop>
		<CFLOCATION URL="create_Stage.cfm" ADDTOKEN="No">
		<CFABORT>
<CFELSE>
<!--- Update the record --->
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		UPDATE 		DD_Stage
		SET 		DD_Stage_Description 	=	'#Form.DD_Stage_Description#',
					Deleted					=	#Form.Deleted#,
					Is_Default				= 	#Form.IS_Default#,
					Is_Auto_Reminded 		=   #Form.AUTOREMINDER#,
					Auto_Default_Days		=	#Form.DD_Stage_Auto_Reminder_Days#
		WHERE		DD_Stage_ID				=	'#Form.DD_Stage_ID#'
	</CFQUERY>
<cfloop from="1" to="#listlen(form.Action_Analyst_Profile)#" index="A">
	<CFQUERY NAME="Check_Analyst_Data" datasource="#application.datasource#">
		SELECT *
		FROM DD_Action_Analyst
		WHERE DD_Stage_ID = #Form.DD_Stage_ID#
		AND Deleted = 0
		AND Analyst_Profiles_ID = '#listgetat(form.Action_Analyst_Profile, A)#'
	</CFQUERY>
	<cfif Check_Analyst_Data.Recordcount EQ 0>
		<CFQUERY NAME="Save_Analyst_Data" datasource="#application.datasource#">
			INSERT INTO DD_Action_Analyst (DD_Stage_ID,Analyst_Profiles_ID)
			VALUES (#Form.DD_Stage_ID#, '#listgetat(form.Action_Analyst_Profile, A)#')
		</CFQUERY>
	</cfif>
</cfloop>
	<CFQUERY NAME="Save_Analyst_Data" datasource="#application.datasource#">
		UPDATE DD_Action_Analyst
		SET Deleted = 1, Updated_Date = getdate(), Updated_By = '#request.AccessStructure.User_ID#'
		WHERE DD_Stage_ID = #Form.DD_Stage_ID#
		AND Deleted = 0
		AND Analyst_Profiles_ID NOT IN (<cfqueryparam value="#form.Action_Analyst_Profile#" cfsqltype="cf_sql_varchar" list="true">)
	</CFQUERY>
	<CFLOCATION URL="create_Stage.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>
