
<cfparam name="FORM.chkClaimPerfReq_1" default="0">
<cfparam name="FORM.reqClaimPerfReq_1" default="0">
<cfparam name="FORM.chkClaimPerfReq_2" default="0">
<cfparam name="FORM.reqClaimPerfReq_2" default="0">
<cfparam name="FORM.chkClaimPerfReq_3" default="0">
<cfparam name="FORM.reqClaimPerfReq_3" default="0">
<cfparam name="FORM.chkClaimPerfReq_4" default="0">
<cfparam name="FORM.reqClaimPerfReq_4" default="0">
<cfparam name="FORM.chkClaimPerfReq_5" default="0">
<cfparam name="FORM.reqClaimPerfReq_5" default="0">
<cfparam name="FORM.chkClaimPerfReq_6" default="0">
<cfparam name="FORM.reqClaimPerfReq_6" default="0">
<cfparam name="FORM.chkClaimPerfReq_7" default="0">
<cfparam name="FORM.reqClaimPerfReq_7" default="0">
<cfparam name="FORM.chkClaimPerfReq_8" default="0">
<cfparam name="FORM.reqClaimPerfReq_8" default="0">
<cfparam name="FORM.chkClaimPerfReq_9" default="0">
<cfparam name="FORM.reqClaimPerfReq_9" default="0">

<cfswitch expression="#FORM.hiBit#">
<cfcase value="1">
	<cfif Len(FORM.selGeneric) eq 1>
		<cfset useLakebaseForsaveSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForsaveSettings>
	<cftry>
		<cfset application.oLakebase.insertRow("program_control_panel_options", {
			"company_main_id" = "#request.AccessStructure.Company_Main_ID#",
			"generic_type" = "#FORM.selGeneric#",
			"created_type" = "#FORM.sel#",
			"invoice_billback" = "#FORM.chkClaimPerfReq_1#",
			"ib_required" = "#FORM.reqClaimPerfReq_1#",
			"claim_period" = "#FORM.chkClaimPerfReq_2#",
			"cp_required" = "#FORM.reqClaimPerfReq_2#",
			"item_number" = "#FORM.chkClaimPerfReq_3#",
			"in_required" = "#FORM.reqClaimPerfReq_3#",
			"total_dollar_pound" = "#FORM.chkClaimPerfReq_4#",
			"tdp_required" = "#FORM.reqClaimPerfReq_4#",
			"menu_listing" = "#FORM.chkClaimPerfReq_5#",
			"ml_required" = "#FORM.reqClaimPerfReq_5#",
			"branded_point_of_sale" = "#FORM.chkClaimPerfReq_6#",
			"bpos_required" = "#FORM.reqClaimPerfReq_6#",
			"mandated_specification" = "#FORM.chkClaimPerfReq_7#",
			"ms_required" = "#FORM.reqClaimPerfReq_7#",
			"optional_specification" = "#FORM.chkClaimPerfReq_8#",
			"os_required" = "#FORM.reqClaimPerfReq_8#",
			"feature_sheet" = "#FORM.chkClaimPerfReq_9#",
			"fs_required" = "#FORM.reqClaimPerfReq_9#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForsaveSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForsaveSettings>
<cfquery name="saveSettings" datasource="#application.datasource#">
			INSERT INTO Program_Control_Panel_Options
				(Company_Main_ID,
				Generic_Type,
				Created_Type,
				Invoice_Billback,
				IB_Required,
				Claim_Period,
				CP_Required,
				Item_Number,
				IN_Required,
				Total_Dollar_Pound,
				TDP_Required,
				Menu_Listing,
				ML_Required,
				Branded_Point_Of_Sale,
				BPOS_Required,
				Mandated_Specification,
				MS_Required,
				Optional_Specification,
				OS_Required,
				Feature_Sheet,
				FS_Required)
			VALUES
				('#request.AccessStructure.Company_Main_ID#',
				'#FORM.selGeneric#',
				'#FORM.sel#',
				#FORM.chkClaimPerfReq_1#,
				#FORM.reqClaimPerfReq_1#,
				#FORM.chkClaimPerfReq_2#,
				#FORM.reqClaimPerfReq_2#,
				#FORM.chkClaimPerfReq_3#,
				#FORM.reqClaimPerfReq_3#,
				#FORM.chkClaimPerfReq_4#,
				#FORM.reqClaimPerfReq_4#,
				#FORM.chkClaimPerfReq_5#,
				#FORM.reqClaimPerfReq_5#,
				#FORM.chkClaimPerfReq_6#,
				#FORM.reqClaimPerfReq_6#,
				#FORM.chkClaimPerfReq_7#,
				#FORM.reqClaimPerfReq_7#,
				#FORM.chkClaimPerfReq_8#,
				#FORM.reqClaimPerfReq_8#,
				#FORM.chkClaimPerfReq_9#,
				#FORM.reqClaimPerfReq_9#)
		</cfquery>
</cfif>
	<cfelse>
		<cfloop index="item" list="#FORM.sel#" delimiters=",">
			<cfquery name="saveSettings" datasource="#application.datasource#">
				INSERT INTO Program_Control_Panel_Options
					(Company_Main_ID,
					Generic_Type,
					Created_Type,
					Invoice_Billback,
					IB_Required,
					Claim_Period,
					CP_Required,
					Item_Number,
					IN_Required,
					Total_Dollar_Pound,
					TDP_Required,
					Menu_Listing,
					ML_Required,
					Branded_Point_Of_Sale,
					BPOS_Required,
					Mandated_Specification,
					MS_Required,
					Optional_Specification,
					OS_Required,
					Feature_Sheet,
					FS_Required)
				VALUES
					('#request.AccessStructure.Company_Main_ID#',
					'#FORM.selGeneric#',
					'#item#',
					#FORM.chkClaimPerfReq_1#,
					#FORM.reqClaimPerfReq_1#,
					#FORM.chkClaimPerfReq_2#,
					#FORM.reqClaimPerfReq_2#,
					#FORM.chkClaimPerfReq_3#,
					#FORM.reqClaimPerfReq_3#,
					#FORM.chkClaimPerfReq_4#,
					#FORM.reqClaimPerfReq_4#,
					#FORM.chkClaimPerfReq_5#,
					#FORM.reqClaimPerfReq_5#,
					#FORM.chkClaimPerfReq_6#,
					#FORM.reqClaimPerfReq_6#,
					#FORM.chkClaimPerfReq_7#,
					#FORM.reqClaimPerfReq_7#,
					#FORM.chkClaimPerfReq_8#,
					#FORM.reqClaimPerfReq_8#,
					#FORM.chkClaimPerfReq_9#,
					#FORM.reqClaimPerfReq_9#)
			</cfquery>
		</cfloop>
	</cfif>
</cfcase>
<cfcase value="2">
	<cfset useLakebaseForupdSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForupdSettings>
	<cftry>
		<cfset application.oLakebase.updateRows("program_control_panel_options",
			{
				"created_type" = "eq.#FORM.oldCreatedType#"
			},
			{
				"company_main_id" = "#request.AccessStructure.Company_Main_ID#",
				"generic_type" = "#FORM.selGeneric#",
				"created_type" = "#FORM.sel#",
				"invoice_billback" = "#FORM.chkClaimPerfReq_1#",
				"ib_required" = "#FORM.reqClaimPerfReq_1#",
				"claim_period" = "#FORM.chkClaimPerfReq_2#",
				"cp_required" = "#FORM.reqClaimPerfReq_2#",
				"item_number" = "#FORM.chkClaimPerfReq_3#",
				"in_required" = "#FORM.reqClaimPerfReq_3#",
				"total_dollar_pound" = "#FORM.chkClaimPerfReq_4#",
				"tdp_required" = "#FORM.reqClaimPerfReq_4#",
				"menu_listing" = "#FORM.chkClaimPerfReq_5#",
				"ml_required" = "#FORM.reqClaimPerfReq_5#",
				"branded_point_of_sale" = "#FORM.chkClaimPerfReq_6#",
				"bpos_required" = "#FORM.reqClaimPerfReq_6#",
				"mandated_specification" = "#FORM.chkClaimPerfReq_7#",
				"ms_required" = "#FORM.reqClaimPerfReq_7#",
				"optional_specification" = "#FORM.chkClaimPerfReq_8#",
				"os_required" = "#FORM.reqClaimPerfReq_8#",
				"feature_sheet" = "#FORM.chkClaimPerfReq_9#",
				"fs_required" = "#FORM.reqClaimPerfReq_9#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdSettings>
<cfquery name="updSettings" datasource="#application.datasource#">
		UPDATE Program_Control_Panel_Options
		Set Company_Main_ID			=	'#request.AccessStructure.Company_Main_ID#',
			Generic_Type			=	'#FORM.selGeneric#',
			Created_Type			=	'#FORM.sel#',
			Invoice_Billback		=	#FORM.chkClaimPerfReq_1#,
			IB_Required				=	#FORM.reqClaimPerfReq_1#,
			Claim_Period			=	#FORM.chkClaimPerfReq_2#,
			CP_Required				=	#FORM.reqClaimPerfReq_2#,
			Item_Number				=	#FORM.chkClaimPerfReq_3#,
			IN_Required				=	#FORM.reqClaimPerfReq_3#,
			Total_Dollar_Pound		=	#FORM.chkClaimPerfReq_4#,
			TDP_Required			=	#FORM.reqClaimPerfReq_4#,
			Menu_Listing			=	#FORM.chkClaimPerfReq_5#,
			ML_Required				=	#FORM.reqClaimPerfReq_5#,
			Branded_Point_Of_Sale	=	#FORM.chkClaimPerfReq_6#,
			BPOS_Required			=	#FORM.reqClaimPerfReq_6#,
			Mandated_Specification	=	#FORM.chkClaimPerfReq_7#,
			MS_Required				=	#FORM.reqClaimPerfReq_7#,
			Optional_Specification	=	#FORM.chkClaimPerfReq_8#,
			OS_Required				=	#FORM.reqClaimPerfReq_8#,
			Feature_Sheet			=	#FORM.chkClaimPerfReq_9#,
			FS_Required				=	#FORM.reqClaimPerfReq_9#
		Where Created_Type			=   '#FORM.oldCreatedType#'
	</cfquery>
</cfif>
</cfcase>
<cfcase value="3">
	<cfset useLakebaseFordelSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseFordelSettings>
	<cftry>
		<cfset application.oLakebase.updateRows("program_control_panel_options",
			{
				"created_type" = "eq.#FORM.oldCreatedType#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseFordelSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordelSettings>
<cfquery name="delSettings" datasource="#application.datasource#">
		UPDATE Program_Control_Panel_Options
		Set deleted = 1
		Where Created_Type	=	'#FORM.oldCreatedType#'
	</cfquery>
</cfif>
</cfcase>
</cfswitch>


<cfoutput>
	<script>
		window.location.href = "control_panel_program.cfm?Tab=4";
	</script>
</cfoutput>
	