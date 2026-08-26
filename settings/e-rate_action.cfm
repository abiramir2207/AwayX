<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Save to database the settings from the prior screen											 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->




<CFIF Form.Payables_Expect_Rate_Period EQ 1 AND isnumeric(trim(Form.Payables_Expect_Rate_Period_other)) EQ 0>
		You must enter a number here...
		<CFABORT>
</CFIF>

<CFIF Form.Payables_Expect_Rate_Period EQ 1 AND isnumeric(trim(Form.Payables_Expect_Rate_Period_other))>
		<CFSET Payables_Expect_Rate_Period=evaluate(Payables_Expect_Rate_Period_other)>
</CFIF>


<CFIF Form.up_sv EQ 0>
	<CFQUERY NAME="Insert_Data" datasource="#application.datasource#">
		INSERT INTO _Users_Settings
			(
				User_ID,
				Payables_Expect_Rate,
				Payables_Expect_Rate_Calc_percent_FOB,
				<!--- Payables_Expect_Rate_Calc_dollar_pound, --->
				Payables_Expect_Rate_Calc_dollar_case,
				Payables_Expect_Rate_Period,
				Payables_Expect_Rate_Include_Period,
				Payables_Expect_Rate_Highlight_billback,
				Payables_Expect_Rate_Date_Updated
			)
		VALUES
			(
				'#request.AccessStructure.Company_Main_ID#',
				'#Payables_Expect_Rate#',
				'#Payables_Expect_Rate_Calc_percent_FOB#',
				<!--- '#Payables_Expect_Rate_Calc_dollar_pound#', --->
				'',
				'#Payables_Expect_Rate_Period#',
				'#Payables_Expect_Rate_Include_Period#',
				'#Payables_Expect_Rate_Highlight_billback#',
				#Date_Updated#
			)
	</CFQUERY>
<CFELSE>
	<cfset useLakebaseForUpdate_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users_settings")>
<cfif useLakebaseForUpdate_Data>
	<cftry>
		<cfset application.oLakebase.updateRows("_users_settings",
			{
				"user_id" = "eq.#request.AccessStructure.Company_Main_ID#"
			},
			{
				"payables_expect_rate" = "#Payables_Expect_Rate#",
				"payables_expect_rate_calc_percent_fob" = "#Payables_Expect_Rate_Calc_percent_FOB#",
				"payables_expect_rate_period" = "#Payables_Expect_Rate_Period#",
				"payables_expect_rate_include_period" = "#Payables_Expect_Rate_Include_Period#",
				"payables_expect_rate_highlight_billback" = "#Payables_Expect_Rate_Highlight_billback#",
				"payables_expect_rate_date_updated" = "#Date_Updated#"
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
		SET		Payables_Expect_Rate					=	'#Payables_Expect_Rate#',
				Payables_Expect_Rate_Calc_percent_FOB	=	'#Payables_Expect_Rate_Calc_percent_FOB#',
				<!--- Payables_Expect_Rate_Calc_dollar_pound	=	'#Payables_Expect_Rate_Calc_dollar_pound#', --->
				<!--- Payables_Expect_Rate_Calc_dollar_case	=	'#Payables_Expect_Rate_Calc_dollar_case#', --->
				Payables_Expect_Rate_Period				=	'#Payables_Expect_Rate_Period#',
				Payables_Expect_Rate_Include_Period		=	'#Payables_Expect_Rate_Include_Period#',
				Payables_Expect_Rate_Highlight_billback	=	'#Payables_Expect_Rate_Highlight_billback#',
				Payables_Expect_Rate_Date_Updated		=	 #Date_Updated#
		WHERE	User_ID									=	'#request.AccessStructure.Company_Main_ID#'
	</CFQUERY>
</cfif>
</CFIF>







<CFLOCATION URL="e-rate_form.cfm?ID=#createuuid()#" ADDTOKEN="No">


