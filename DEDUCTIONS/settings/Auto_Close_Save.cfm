
<!--- Dev Note: KAL - D7911 Auto Close not allowed checkbox--->
<cfparam name="FORM.AutoClose_not_allowed"		default="0">
<cfparam name="Form.AutoApprove_not_allowed" 	default="0">
<cfparam name="Form.Enabled" 					default="0">
<cfparam name="Form.Match_Distributor_Bill_To" 	default="0">
<cfparam name="Form.Match_Reference_Number" 	default="0">
<cfparam name="Form.Match_Distributor_Ship_To" 	default="0">
<cfparam name="Form.Auto_Match_Reconcile" default="0"><!--- 61842 --->
<cfparam name="Form.Reconcile_Dollar_Amount_Value" default="0.00">
<cfparam name="Form.Dollar_Amount" 				 default="0.00">

<CFIF FORM.New_settings EQ 1>
<!---
DEV Notes: Anand Rao/04-Nov-09
D21107: Moved the if statement <cfif application.deductionLinksAvailable> to
appear after this current CFIF statement and also include a condition in
the insert and update so that the column Auto_Close_Amount, DD_Reason_Code_ID
would be populated with values only if the Application.deductionLinksAvailable
is set to 1 else they will be null
--->
	<cfset varAutoCloseAmount = (application.appSettingsGet.getDeduction_Module() AND FORM.AutoClose_not_allowed NEQ 1) ? FORM.Amount : javaCast("null", "")>
	<cfset varDDReasonCodeID = (application.appSettingsGet.getDeduction_Module() AND FORM.AutoClose_not_allowed NEQ 1) ? FORM.DD_Reason_Code_ID : javaCast("null", "")>
	<cfset useLakebaseForInsert_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_auto_close")>
	<cfif useLakebaseForInsert_Data>
		<cftry>
			<cfset application.oLakebase.insertRow("dd_auto_close", {
				"auto_close_amount" = varAutoCloseAmount,
				"dd_reason_code_id" = varDDReasonCodeID,
				"updated_by_user_id" = request.AccessStructure.User_ID,
				"updated_on" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss")
			})>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForInsert_Data = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForInsert_Data>
	<CFQUERY NAME="Insert_Data" DATASOURCE="#Application.Datasource#">
		INSERT INTO DD_Auto_Close 	(Auto_Close_Amount, DD_Reason_Code_ID, 	Updated_By_User_ID, Updated_On)
		VALUES 	(	<cfif application.appSettingsGet.getDeduction_Module()><cfif FORM.AutoClose_not_allowed EQ 1>null<cfelse>'#FORM.Amount#'</cfif><cfelse>null</cfif>,
							<cfif application.appSettingsGet.getDeduction_Module()><cfif FORM.AutoClose_not_allowed EQ 1>null<cfelse>'#FORM.DD_Reason_Code_ID#'</cfif><cfelse>null</cfif>,
							'#request.AccessStructure.User_ID#',
							getdate()	)
	</CFQUERY>
	</cfif>
<CFELSE>
	<cfset varAutoCloseAmount = (application.appSettingsGet.getDeduction_Module() AND FORM.AutoClose_not_allowed NEQ 1) ? FORM.Amount : javaCast("null", "")>
	<cfset varDDReasonCodeID = (application.appSettingsGet.getDeduction_Module() AND FORM.AutoClose_not_allowed NEQ 1) ? FORM.DD_Reason_Code_ID : javaCast("null", "")>
	<cfset useLakebaseForUpdate_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_auto_close")>
	<cfif useLakebaseForUpdate_Data>
		<cftry>
			<cfset application.oLakebase.updateRows("dd_auto_close", {},
				{
					"auto_close_amount" = varAutoCloseAmount,
					"dd_reason_code_id" = varDDReasonCodeID,
					"updated_by_user_id" = request.AccessStructure.User_ID,
					"updated_on" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss")
				}
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForUpdate_Data = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForUpdate_Data>
	<CFQUERY NAME="Update_Data" DATASOURCE="#Application.Datasource#">
		UPDATE DD_Auto_Close
		SET			Auto_Close_Amount 		=	<cfif application.appSettingsGet.getDeduction_Module()><cfif FORM.AutoClose_not_allowed EQ 1>null<cfelse>'#FORM.Amount#'</cfif><cfelse>null</cfif>,
					DD_Reason_Code_ID		=	<cfif application.appSettingsGet.getDeduction_Module()><cfif FORM.AutoClose_not_allowed EQ 1>null<cfelse>'#FORM.DD_Reason_Code_ID#'</cfif><cfelse>null</cfif>,
					Updated_By_User_ID		=	'#request.AccessStructure.User_ID#',
					Updated_On				=	getdate()
	</CFQUERY>
	</cfif>
</CFIF>

<cfif application.appSettingsGet.getDeduction_Module()>
	<!---if the auto match is disabled then just set enabled to 0 in the DD_Auto_Match table--->
	<cfif form.Enabled>
		<cfparam name="Form.Use_Auto_Match_DD_Reason_Code" 	default="0">
		<cfparam name="Form.Use_Write_Off_DD_Reason_Code" 	default="0">
		<cfparam name="Form.Write_Off_Dollar_Amount_Value" 	default="0">

		<CFQUERY NAME="qUpdateDDAutoMatch" DATASOURCE="#Application.Datasource#">
			UPDATE	DD_Auto_Match
			SET		Enabled = #form.Enabled#,
					Dollar_Amount = #form.Dollar_Amount#,
					Dollar_Amount_Value = <cfif len(trim(#form.Dollar_Amount_Value#))>#form.Dollar_Amount_Value#<cfelse>0.00</cfif>,
					Match_Reference_Number = #form.Match_Reference_Number#,
					Match_Distributor_Bill_To = #form.Match_Distributor_Bill_To#,
					Match_Distributor_Ship_To = #form.Match_Distributor_Ship_To#,
					Auto_Match_DD_Reason_Code_ID = <cfif form.Use_Auto_Match_DD_Reason_Code eq 0>NULL<cfelse>#form.Auto_Match_DD_Reason_Code_ID#</cfif>,
					Write_Off_DD_Reason_Code_ID = <cfif form.Use_Write_Off_DD_Reason_Code eq 0>NULL<cfelse>#form.Write_Off_DD_Reason_Code_ID#</cfif>,
					Use_Auto_Match_DD_Reason_Code = #form.Use_Auto_Match_DD_Reason_Code#,
					Use_Write_Off_DD_Reason_Code = #form.Use_Write_Off_DD_Reason_Code#,
					Deduction_Status_After_Auto_Match = #form.Deduction_Status_After_Auto_Match#,
					Write_Off_Dollar_Amount_Value = <cfif len(trim(#form.Write_Off_Dollar_Amount_Value#))>#form.Write_Off_Dollar_Amount_Value#<cfelse>0.00</cfif>
					,Auto_Match_Reconcile  = #form.Auto_Match_Reconcile#<!--- 61842 --->
					,Reconcile_Dollar_Amount_Value = <cfif len(trim(#form.Reconcile_Dollar_Amount_Value#))>#form.Reconcile_Dollar_Amount_Value#<cfelse>0.00</cfif><!---98653--->
			WHERE	DD_Auto_Match_ID = #form.DD_Auto_Match_ID#
		</CFQUERY>


		<!----D69678 :: Modify Auto Match logic to use Family and Reference only based on the Setting START--->
		<cfif form.Match_Distributor_Bill_To EQ 3>
			<cfset qGetExistingFamilyList = createObject("component", "components.Billback.BillbackSettingsManager").UpdateFamilyRecords(fromAutoMatch=1,fromAutoDeviation=0,familyList='#form.familyList#')/>
		</cfif>
		<!----D69678 :: Modify Auto Match logic to use Family and Reference only based on the Setting END--->

	<cfelse>
		<CFQUERY NAME="qUpdateDDAutoMatch" DATASOURCE="#Application.Datasource#">
			UPDATE	DD_Auto_Match
			SET		Enabled = #form.Enabled#
			WHERE	DD_Auto_Match_ID = #form.DD_Auto_Match_ID#
		</CFQUERY>
	</cfif>
</cfif>

<CFLOCATION URL="Auto_Close.cfm" ADDTOKEN="No">