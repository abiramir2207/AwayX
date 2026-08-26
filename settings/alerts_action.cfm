

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Save to database the settings from the prior screen											 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Check to determine if the variables are disabled --->
<cfif Form.Flag EQ 0>
	<CFLOCATION URL="control_panel.cfm?Tab=3&ID=#createuuid()#" ADDTOKEN="No">
</CFIF>


<!--- Setup default values																			 --->
	<CFPARAM NAME="Alert_in_30" DEFAULT="0">
	<CFPARAM NAME="Alert_in_45" DEFAULT="0">
	<CFPARAM NAME="Alert_in_60" DEFAULT="0">
	<CFPARAM NAME="Alert_in_90" DEFAULT="0">
	<CFPARAM NAME="Alert_Expiration_Message" DEFAULT="">
	<CFPARAM NAME="Alert_Expiration_Email_Address" DEFAULT="">

<CFIF Form.up_sv EQ 0>
	<cfset useLakebaseForInsert_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users_settings")>
<cfif useLakebaseForInsert_Data>
	<cftry>
		<cfset application.oLakebase.insertRow("_users_settings", {
			"user_id" = "#request.AccessStructure.User_ID#",
			"alert_in_30" = "#Alert_in_30#",
			"alert_in_45" = "#Alert_in_45#",
			"alert_in_60" = "#Alert_in_60#",
			"alert_in_90" = "#Alert_in_90#",
			"alert_expiration_message" = "#Alert_Expiration_Message#",
			"alert_expiration_email_address" = "#Alert_Expiration_Email_Address#",
			"alert_date_updated" = "#createodbcdatetime(now())#"
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
				user_id, 
				Alert_in_30, 
				Alert_in_45, 
				Alert_in_60, 
				Alert_in_90, 
				Alert_Expiration_Message, 
				Alert_Expiration_Email_Address, 
				Alert_Date_Updated
			)
		VALUES
			(
				'#request.AccessStructure.User_ID#', 
				#Alert_in_30#, 
				#Alert_in_45#, 
				#Alert_in_60#, 
				#Alert_in_90#, 
				'#Alert_Expiration_Message#', 
				'#Alert_Expiration_Email_Address#', 
				#createodbcdatetime(now())#
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
				"alert_in_30" = "#Alert_in_30#",
				"alert_in_45" = "#Alert_in_45#",
				"alert_in_60" = "#Alert_in_60#",
				"alert_in_90" = "#Alert_in_90#",
				"alert_expiration_message" = "#Alert_Expiration_Message#",
				"alert_expiration_email_address" = "#Alert_Expiration_Email_Address#",
				"alert_date_updated" = "#createodbcdatetime(now())#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdate_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdate_Data>
<CFQUERY NAME="Update_Data" datasource="#application.datasource#">
		Update _Users_Settings
		Set
				Alert_in_30						= 		#Alert_in_30#,
				Alert_in_45						=		#Alert_in_45#,
				Alert_in_60						=		#Alert_in_60#,
				Alert_in_90						=		#Alert_in_90#,
				Alert_Expiration_Message		=		'#Alert_Expiration_Message#',
				Alert_Expiration_Email_Address	=		'#Alert_Expiration_Email_Address#',
				Alert_Date_Updated				=		#createodbcdatetime(now())#

		Where	user_id 						=		'#request.AccessStructure.User_ID#'
	</CFQUERY>
</cfif>
</CFIF>


<CFLOCATION URL="/settings/alerts_action.cfm?ID=#createuuid()#" ADDTOKEN="No">


