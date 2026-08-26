
<CFPARAM NAME="Form.Is_Default" DEFAULT="0">
<CFPARAM NAME="Form.Is_MatchCentral_Default" DEFAULT="0">
<CFPARAM NAME="Form.Classification_Analyst_Profile" DEFAULT="">
	<CFPARAM NAME="Form.gl_account_code" DEFAULT="">

		
	<cfset  genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset  appSettings = genSettingsManager.get()>
		
	<!--- Delete record --->
<CFIF FORM.DeleteRecord EQ 1>
	<CFTRANSACTION ACTION="BEGIN">
	<cfset useLakebaseFordelete_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_classification")>
	<cfif useLakebaseFordelete_Data>
		<cftry>
			<cfset application.oLakebase.deleteRows("dd_classification", { "dd_classification_id" = "eq.#Form.DD_Classification_ID#" })>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseFordelete_Data = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseFordelete_Data>
	<CFQUERY NAME="delete_Data" datasource="#application.datasource#">
		DELETE FROM DD_Classification WHERE DD_Classification_ID =	'#Form.DD_Classification_ID#'
	</CFQUERY>
	</cfif>
	<!--- 70923 :: Create new feature for deduction workflow START--->
	<cfset useLakebaseFordelete_Classification_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_classification_analyst")>
	<cfif useLakebaseFordelete_Classification_Data>
		<cftry>
			<cfset application.oLakebase.deleteRows("dd_classification_analyst", { "dd_classification_id" = "eq.#Form.DD_Classification_ID#" })>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseFordelete_Classification_Data = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseFordelete_Classification_Data>
	<CFQUERY NAME="delete_Classification_Data" datasource="#application.datasource#">
		DELETE FROM DD_Classification_Analyst WHERE DD_Classification_ID = '#Form.DD_Classification_ID#'
	</CFQUERY>
	</cfif>
	<!--- 70923 :: Create new feature for deduction workflow END--->
	<cfset useLakebaseForgetDefault = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_classification")>
	<cfif useLakebaseForgetDefault>
		<cftry>
			<cfset getDefault = application.oLakebase.toQuery(
				application.oLakebase.selectRows("dd_classification", {
					"select" = "dd_classification_id",
					"deleted" = "eq.0",
					"is_default" = "eq.1"
				}),
				"dd_classification_id"
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForgetDefault = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForgetDefault>
	<CFQUERY NAME="getDefault" DATASOURCE="#Application.Datasource#">
		SELECT DD_Classification_ID FROM DD_Classification WHERE Deleted=0 AND Is_Default = 1
	</CFQUERY>
	</cfif>
	<CFIF getDefault.Recordcount GT 0>
		<cfset useLakebaseForUpdateDDStages = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
		<cfif useLakebaseForUpdateDDStages>
			<cftry>
				<cfset application.oLakebase.updateRows("deductions",
					{ "dd_classification_id" = "eq.#Form.DD_Classification_ID#" },
					{ "dd_classification_id" = getDefault.DD_Classification_ID }
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
			SET 	DD_Classification_ID = '#getDefault.DD_Classification_ID#'
			WHERE	DD_Classification_ID = '#Form.DD_Classification_ID#'
		</CFQUERY>
		</cfif>
	</CFIF>
	<CFTRANSACTION ACTION = "COMMIT">
	</CFTRANSACTION>
	<CFLOCATION URL="create_Classifications.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>

	<cfset useLakebaseForIsThereDefault = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_classification")>
	<cfif useLakebaseForIsThereDefault>
		<cftry>
			<cfset IsThereDefault = application.oLakebase.toQuery(
				application.oLakebase.selectRows("dd_classification", {
					"is_default" = "eq.1",
					"deleted" = "eq.0"
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
		SELECT * FROM DD_Classification WHERE Is_Default = 1 AND Deleted = 0
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
	<!--- remove the match central default from another entry if necessary --->
	<cfif Form.Is_Default IS 1>
		<cfset useLakebaseForRemoveDefault = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_classification")>
		<cfif useLakebaseForRemoveDefault>
			<cftry>
				<cfset application.oLakebase.updateRows("dd_classification",
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
			UPDATE DD_Classification
			Set Is_Default = 0
			WHERE Is_Default = 1
		</cfquery>
		</cfif>
	</cfif>
	<cfset useLakebaseForIsThereMatchCentralDefault = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_classification")>
	<cfif useLakebaseForIsThereMatchCentralDefault>
		<cftry>
			<cfset IsThereMatchCentralDefault = application.oLakebase.toQuery(
				application.oLakebase.selectRows("dd_classification", {
					"is_matchcentral_default" = "eq.1",
					"deleted" = "eq.0"
				})
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForIsThereMatchCentralDefault = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForIsThereMatchCentralDefault>
	<cfquery name="IsThereMatchCentralDefault" datasource="#application.datasource#">
		SELECT * FROM DD_Classification WHERE Is_MatchCentral_Default = 1 AND Deleted = 0
	</cfquery>
	</cfif>
	<!---See if something is already set as match central default--->
	<cfparam name="SetAsMatchCentralDefault" default="0">
<cfif val(appSettings.get_Setting('Custom_Deduction_workflow')) eq '0'>			
	<cfif IsThereMatchCentralDefault.RecordCount IS 0>
		<cfset SetAsMatchCentralDefault = 1>
		<cfset Form.Is_MatchCentral_Default = 1>
	</cfif>
</cfif>
	<!--- remove the match central default from another entry if necessary --->
	<cfif Form.Is_MatchCentral_Default IS 1>
		<cfset useLakebaseForRemoveMatchCentralDefault = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_classification")>
		<cfif useLakebaseForRemoveMatchCentralDefault>
			<cftry>
				<cfset application.oLakebase.updateRows("dd_classification",
					{ "is_matchcentral_default" = "eq.1" },
					{ "is_matchcentral_default" = 0 }
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForRemoveMatchCentralDefault = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForRemoveMatchCentralDefault>
		<cfquery name="RemoveMatchCentralDefault" datasource="#application.datasource#">
			UPDATE DD_Classification
			Set Is_MatchCentral_Default = 0
			WHERE Is_MatchCentral_Default = 1
		</cfquery>
		</cfif>
	</cfif>
<CFIF Form.DD_Classification_ID EQ "">
	<!--- Insert the record --->
		<cfset useLakebaseForSave_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_classification")>
<cfif useLakebaseForSave_Data>
	<cftry>
		<cfset application.oLakebase.insertRow("dd_classification", {
			"dd_classification_desc" = "#Form.DD_Classification_Desc#",
			"deleted" = "#Form.Deleted#",
			"is_default" = "#Form.Is_Default#",
			"is_matchcentral_default" = "#Form.IS_MatchCentral_Default#",
			"gl_account_code" = "#form.gl_account_code#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForSave_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSave_Data>
<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
			INSERT INTO		DD_Classification	(DD_Classification_Desc,Deleted,Is_Default,IS_MatchCentral_Default,GL_Account_Code)
			Values ('#Form.DD_Classification_Desc#',#Form.Deleted#,#Form.Is_Default#,#Form.IS_MatchCentral_Default#,'#form.gl_account_code#')
			SELECT SCOPE_IDENTITY() AS SCOPEIDENTITY
		</CFQUERY>
</cfif>
	<cfloop from="1" to="#listlen(Form.Classification_Analyst_Profile)#" index="A">
		<cfset useLakebaseForSave_Analyst_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_classification_analyst")>
<cfif useLakebaseForSave_Analyst_Data>
	<cftry>
		<cfset application.oLakebase.insertRow("dd_classification_analyst", {
			"dd_classification_id" = "#Save_Data.SCOPEIDENTITY#",
			"analyst_profiles_id" = "#listgetat(Form.Classification_Analyst_Profile, A)#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForSave_Analyst_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSave_Analyst_Data>
<CFQUERY NAME="Save_Analyst_Data" datasource="#application.datasource#">
			INSERT INTO DD_Classification_Analyst(DD_Classification_ID,Analyst_Profiles_ID)
			Values(#Save_Data.SCOPEIDENTITY#,'#listgetat(Form.Classification_Analyst_Profile, A)#')
		</CFQUERY>
</cfif>
	</cfloop>
		<CFLOCATION URL="create_Classifications.cfm" ADDTOKEN="No">
		<CFABORT>
<CFELSE>
<!--- Update the record --->
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		UPDATE 		DD_Classification
		SET 	DD_Classification_Desc 	=	'#Form.DD_Classification_Desc#',
					Deleted					=	#Form.Deleted#,
					Is_Default				= 	#Form.IS_Default#,
					IS_MatchCentral_Default	= 	#Form.IS_MatchCentral_Default#,
					GL_Account_Code = '#form.gl_account_code#'
		WHERE	DD_Classification_ID	=	'#Form.DD_Classification_ID#'
	</CFQUERY>
<cfloop from="1" to="#listlen(Form.Classification_Analyst_Profile)#" index="A">
	<CFQUERY NAME="Check_Analyst_Data" datasource="#application.datasource#">
		SELECT *
		FROM DD_Classification_Analyst
		WHERE DD_Classification_ID = #Form.DD_Classification_ID#
		AND Deleted = 0
		AND Analyst_Profiles_ID = '#listgetat(Form.Classification_Analyst_Profile, A)#'
	</CFQUERY>
	<cfif Check_Analyst_Data.Recordcount EQ 0>
		<CFQUERY NAME="Save_Analyst_Data" datasource="#application.datasource#">
			INSERT INTO DD_Classification_Analyst (DD_Classification_ID,Analyst_Profiles_ID)
			VALUES (#Form.DD_Classification_ID#, '#listgetat(Form.Classification_Analyst_Profile, A)#')
		</CFQUERY>
	</cfif>
</cfloop>
	<CFQUERY NAME="Save_Analyst_Data" datasource="#application.datasource#">
		UPDATE DD_Classification_Analyst
		SET Deleted = 1, Updated_Date = getdate(), Updated_By = '#request.AccessStructure.User_ID#'
		WHERE DD_Classification_ID = #Form.DD_Classification_ID#
		AND Deleted = 0
		AND Analyst_Profiles_ID NOT IN (<cfqueryparam value="#Form.Classification_Analyst_Profile#" cfsqltype="cf_sql_varchar" list="true">)
	</CFQUERY>
	<CFLOCATION URL="create_Classifications.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>