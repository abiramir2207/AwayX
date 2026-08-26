<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Save to database the settings from the prior screen											 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<CFIF Form.Payables_Expect_Volume_Purchase_Period EQ 1 AND isnumeric(trim(Form.Payables_Expect_Volume_Purchase_Period_other)) EQ 0>
		You must enter a number here...
		<CFABORT>
</CFIF>
<CFIF Form.Payables_Expect_Volume_Purchase_Period EQ 1 AND isnumeric(trim(Form.Payables_Expect_Volume_Purchase_Period_other))>
		<CFSET Payables_Expect_Volume_Purchase_Period=evaluate(Payables_Expect_Volume_Purchase_Period_other)>
</CFIF>


<CFIF Form.Payables_Expect_Volume_Aggregation_Period EQ 1 AND isnumeric(trim(Form.Payables_Expect_Volume_Aggregation_Period_other)) EQ 0>
		You must enter a number here...
		<CFABORT>
</CFIF>
<CFIF Form.Payables_Expect_Volume_Aggregation_Period EQ 1 AND isnumeric(trim(Form.Payables_Expect_Volume_Aggregation_Period))>
		<CFSET Payables_Expect_Volume_Aggregation_Period=evaluate(Payables_Expect_Volume_Aggregation_Period_other)>
</CFIF>


<CFIF Form.Payables_Expect_Volume_Offset_Period EQ 1 AND isnumeric(trim(Form.Payables_Expect_Volume_Offset_Period)) EQ 0>
		You must enter a number here...
		<CFABORT>
</CFIF>
<CFIF Form.Payables_Expect_Volume_Offset_Period EQ 1 AND isnumeric(trim(Payables_Expect_Volume_Offset_Period))>
		<CFSET Payables_Expect_Volume_Offset_Period=evaluate(Payables_Expect_Volume_Offset_Period_other)>
</CFIF>





<CFIF Form.up_sv EQ 0>
	<cfset useLakebaseForInsert_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users_settings")>
<cfif useLakebaseForInsert_Data>
	<cftry>
		<cfset application.oLakebase.insertRow("_users_settings", {
			"payables_expect_volume_purchase_period" = "#Payables_Expect_Volume_Purchase_Period#",
			"payables_expect_volume_aggregation_period" = "#Payables_Expect_Volume_Aggregation_Period#",
			"payables_expect_volume_offset_period" = "#Payables_Expect_Volume_Offset_Period#",
			"payables_expect_volume_highlight" = "#Payables_Expect_Volume_Highlight#",
			"payables_expect_volume_date_updated" = "#Date_Updated#"
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
				Payables_Expect_Volume_Purchase_Period,
				Payables_Expect_Volume_Aggregation_Period,
				Payables_Expect_Volume_Offset_Period,
				Payables_Expect_Volume_Highlight,
				Payables_Expect_Volume_Date_Updated
			)
		VALUES
			(
				'#Payables_Expect_Volume_Purchase_Period#',
				'#Payables_Expect_Volume_Aggregation_Period#',
				'#Payables_Expect_Volume_Offset_Period#',
				'#Payables_Expect_Volume_Highlight#',
				 #Date_Updated#
			)
	</CFQUERY>
</cfif>
<CFELSE>
	<cfset useLakebaseForUpdate_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users_settings")>
<cfif useLakebaseForUpdate_Data>
	<cftry>
		<cfset application.oLakebase.updateRows("_users_settings",
			{
				"user_id" = "eq.#User_ID#"
			},
			{
				"payables_expect_volume_purchase_period" = "#Payables_Expect_Volume_Purchase_Period#",
				"payables_expect_volume_aggregation_period" = "#Payables_Expect_Volume_Aggregation_Period#",
				"payables_expect_volume_offset_period" = "#Payables_Expect_Volume_Offset_Period#",
				"payables_expect_volume_highlight" = "#Payables_Expect_Volume_Highlight#",
				"payables_expect_volume_date_updated" = "#Date_Updated#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdate_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdate_Data>
<CFQUERY NAME="Update_Data" datasource="#application.datasource#">
		UPDATE	_Users_Settings
		SET		Payables_Expect_Volume_Purchase_Period		=	'#Payables_Expect_Volume_Purchase_Period#',
				Payables_Expect_Volume_Aggregation_Period	=	'#Payables_Expect_Volume_Aggregation_Period#',
				Payables_Expect_Volume_Offset_Period		=	'#Payables_Expect_Volume_Offset_Period#',
				Payables_Expect_Volume_Highlight			=	'#Payables_Expect_Volume_Highlight#',
				Payables_Expect_Volume_Date_Updated			=	 #Date_Updated#
		WHERE	User_ID										=	'#User_ID#'
	</CFQUERY>
</cfif>
</CFIF>


<CFLOCATION URL="e-volume_form.cfm?ID=#createuuid()#" ADDTOKEN="No">


