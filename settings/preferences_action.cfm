<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Save to database the settings from the prior screen											 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<CFIF Form.up_sv EQ 0>
	<cfset useLakebaseForInsert_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users_settings")>
<cfif useLakebaseForInsert_Data>
	<cftry>
		<cfset application.oLakebase.insertRow("_users_settings", {
			"prefered_uom" = "#Prefered_UOM#",
			"prefered_uom_date_updated" = "#Date_Updated#",
			"user_id" = "#request.AccessStructure.User_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsert_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsert_Data>
<CFQUERY NAME="Insert_Data" datasource="#application.datasource#">
		INSERT INTO _Users_Settings
			(
				Prefered_UOM, 
				Prefered_UOM_Date_Updated,
				user_id
			)
		VALUES
			(
				#Prefered_UOM#, 
				#Date_Updated#,
				'#request.AccessStructure.User_ID#'
			)
	</CFQUERY>
</cfif>
<CFELSE>
	<cfset useLakebaseForUpdate_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users_settings")>
<cfif useLakebaseForUpdate_Data>
	<cftry>
		<cfset application.oLakebase.updateRows("_users_settings",
			{
				"user_id" = "eq.#request.AccessStructure.User_ID#"
			},
			{
				"prefered_uom" = "#Prefered_UOM#",
				"prefered_uom_date_updated" = "#Date_Updated#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdate_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdate_Data>
<CFQUERY NAME="Update_Data" datasource="#application.datasource#">
		Update 	_Users_Settings
		Set		Prefered_UOM				= 		#Prefered_UOM#,
				Prefered_UOM_Date_Updated	=		#Date_Updated#
		Where	user_id 					=		'#request.AccessStructure.User_ID#'
	</CFQUERY>
</cfif>
</CFIF>




<CFLOCATION URL="preferences_form.cfm?ID=#createuuid()#" ADDTOKEN="No">






