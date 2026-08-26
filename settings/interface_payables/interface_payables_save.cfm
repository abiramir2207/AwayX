<!---interface_payables_save.cfm--->
<cfif not len(trim(form.Cannot_Exceed_Percent))>
	<cfset form.Cannot_Exceed_Percent = "0.00" />
</cfif>
<cfif not len(trim(form.Cannot_Exceed_Dollar))>
	<cfset form.Cannot_Exceed_Dollar = "0.00" />
</cfif>
<cfif not len(trim(form.Billback_LS_Auto_Process_Amt))>
	<cfset form.Billback_LS_Auto_Process_Amt = "0.00" />
</cfif>

<CFPARAM NAME="Form.Auto_Deviation_Inc_Manual_BB" DEFAULT="0">
<CFPARAM NAME="Form.Maximum_Dollar_Amount_Checked" DEFAULT="0">
<CFPARAM NAME="Form.Auto_Deviation_Family_Level" DEFAULT="0">
<CFPARAM NAME="Form.AutoProcess_Check_BB_Beyond_Budget" DEFAULT="0">

<cftransaction>

	<CFQUERY NAME="qSaveToleranceSettings" DATASOURCE="#Application.Datasource#">
		UPDATE	Billback_Tolerance_Settings
		SET		Cannot_Exceed_Percent = '#form.Cannot_Exceed_Percent#',
						Cannot_Exceed_Dollar = '#form.Cannot_Exceed_Dollar#',
						Auto_Deviation_Inc_Manual_BB = #FORM.Auto_Deviation_Inc_Manual_BB#,
						Maximum_Dollar_Amount_Checked = #FORM.Maximum_Dollar_Amount_Checked#,
					<cfif Form.Maximum_Dollar_Amount_Checked EQ 1>
						Maximum_Dollar_Amount = '#FORM.Maximum_Dollar_Amount#',
						Billback_Status_For_Max_Dollar_Amt = #FORM.Billback_Status_For_Max_Dollar_Amt#,
					</cfif>
						Last_Updated_Date = getDate(),
						Last_Updated_By = '#request.AccessStructure.User_ID#',
						Auto_Deviation_Family_Level = #form.Auto_Deviation_Family_Level#,
						Billback_LS_Auto_Process_Amt = '#form.Billback_LS_Auto_Process_Amt#',
						AutoProcess_Check_BB_Beyond_Budget = #form.AutoProcess_Check_BB_Beyond_Budget#
		WHERE	Billback_Tolerance_Settings_ID = #form.Billback_Tolerance_Settings_ID#
	</CFQUERY>

	<cfloop list="#form.Billback_Closing_Method_ID_List#" index="indxList">

		<CFQUERY NAME="qUpdateClosingMethod" DATASOURCE="#Application.Datasource#">
			UPDATE	Billback_Closing_Methods
			SET		Auto_Dev_BB_Status_Below = #evaluate("form.#indxList#_Auto_Dev_BB_Status_Below")#,
					Auto_Dev_BB_Status_Exceed = #evaluate("form.#indxList#_Auto_Dev_BB_Status_Exceed")#
			WHERE	iBillback_Closing_Method_ID = #indxList#
		</CFQUERY>

	</cfloop>

		<!----D74179 :: Auto Deviations at Family level START--->
		<cfif form.Auto_Deviation_Family_Level>
			<cfset qGetExistingFamilyList = createObject("component", "components.Billback.BillbackSettingsManager").UpdateFamilyRecords(fromAutoMatch=0,fromAutoDeviation=1,familyList='#form.familyList#')/>
		</cfif>
		<!----D74179 :: Auto Deviations at Family level END--->

</cftransaction>

<CFLOCATION URL="interface_payables.cfm" ADDTOKEN="No">