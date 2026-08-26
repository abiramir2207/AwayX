<script>
function changeClass(obj,class_name) { obj.className = class_name; }
</script>
<cfset stDeductionLabels = createObject("component", "components.settings.Labels.Labels").init().GetDeductionLabelsStruct() />
<cfparam name="URL.AdminUserFromProfilesPage" default="0">
<cfoutput>
<!--- Lists of links stored as variables (Variable is the category name that will display on the page) --->

<!--- Create cfsavecontent variable="Geography" in alphabetical order --->
<cfset aryGeography = ArrayNew(1)>
<cfset aryGeographyLink = ArrayNew(1)>
<cfset aryGeographyFile = ArrayNew(1)>
<cfset aryGeographySPACaModule = ArrayNew(1)>

<!--- retrieve all settings and place them into request.settings variable --->
<cfset application.util.query.request_settings()>

	<!--- Dev Note: Clay 8950: Hide Market using Customer Setting --->
	<CFIF application.returned_customer_setting.tree_access_market EQ 1>
	  	<cfif getSpa.Market_Area_Maintenance OR URL.AdminUserFromProfilesPage eq 1>
		  	<!--- check Access level *****--->
		  		<cfset ArrayAppend(aryGeographyLink, "#lcase(application.returned_customer_setting.market_label_singular)# area")>
				<cfset ArrayAppend(aryGeographyFile, "/settings/Market_Area_Maintenance.cfm")>
				<cfset ArrayAppend(aryGeographySPACaModule, "Market_Area_Maintenance")>
	  	</cfif>
	</CFIF>

	<CFIF application.returned_customer_setting.tree_access_zone EQ 1>
	  	<cfif getSpa.zone_maintenance OR URL.AdminUserFromProfilesPage eq 1>
		  	<!--- check Access level *****--->
			<cfset ArrayAppend(aryGeographyLink, "#lcase(application.returned_customer_setting.zone_label_singular)#")>
			<cfset ArrayAppend(aryGeographyFile, "/settings/zone_maintenance.cfm")>
			<cfset ArrayAppend(aryGeographySPACaModule, "zone_maintenance")>
		</cfif>
	</CFIF>

	<cfif application.operatorVariableAvailable>
		<!------ operators ----->
		<cfif getSpa.Operator_Tree_index OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryGeographyLink, "#LCase(application.returned_customer_setting.operator_label_plural)#")>
			<cfset ArrayAppend(aryGeographyFile, "/settings/Operator_Tree/index.cfm")>
			<cfset ArrayAppend(aryGeographySPACaModule, "Operator_Tree_index")>
	  	</cfif>
	</cfif>

	  <!--- Dev Note: Clay 8950: Hide Broker using Customer Setting --->
	<CFIF application.returned_customer_setting.tree_access_broker EQ 1>
		<cfif getSpa.brokers_search_form OR URL.AdminUserFromProfilesPage eq 1>
		<!--- check Access level *****--->
			<cfset ArrayAppend(aryGeographyLink, "list #lcase(application.returned_customer_setting.broker_label_plural)#")>
			<cfset ArrayAppend(aryGeographyFile, "/settings/Access_Rights/brokers_search_form.cfm?PageTitle=#application.returned_customer_setting.broker_label_plural#: list #lcase(application.returned_customer_setting.broker_label_plural)#")>
			<cfset ArrayAppend(aryGeographySPACaModule, "brokers_search_form")>
		</cfif>
	</CFIF>

 	<CFIF application.returned_customer_setting.tree_access_region EQ 1>
	  	<cfif getSpa.region_maintenance OR URL.AdminUserFromProfilesPage eq 1>
		  	<!--- check Access level *****--->
			<cfset ArrayAppend(aryGeographyLink, "#lcase(application.returned_customer_setting.region_label_singular)#")>
			<cfset ArrayAppend(aryGeographyFile, "/settings/region_maintenance.cfm")>
      <!-----------------------------------------------------------------------------
      Dev Notes: D19047
      	While working on this label I found that the below Append was adding
        the same value "brokers_search_form" as above which was causing the update
        statement to throw an error. So that issue was fixed by changing the value
        to "region_maintenance"
        -Anand Rao/20-May-09
      ------------------------------------------------------------------------------>
			<cfset ArrayAppend(aryGeographySPACaModule, "region_maintenance")>
	  	</cfif>
	</CFIF>

<cfset aryGeography = aryGeographyLink>
<cfset ArraySort(aryGeography, "textnocase")>
<cfset ListGeography = ArrayToList(aryGeographyLink, ",")>

<cfsavecontent variable="Geography">
	<cfloop index = "LoopCount" from = "1" to = #ArrayLen(aryGeography)#>
		<cfset indexList = ListFind(ListGeography, "#aryGeography[LoopCount]#")>
		<cfif currentPage EQ "settings_frame_mainwindow.cfm"><cf_SPACaller module="#aryGeographySPACaModule[indexList]#"></cfif>
		<a href="#aryGeographyFile[indexList]#" target="mainwindow" onClick="window.parent.frames['toc'].location.href='settings_frame_toc.cfm?subnav=Geography'">
		 	 #aryGeographyLink[indexList]#
		</a><br>
	</cfloop>
</cfsavecontent>

<cfif request.settings.Show_Projects_ScoreCard>
<cfsavecontent variable="Projects">

  	<cfif getSpa.create_far OR URL.AdminUserFromProfilesPage eq 1>
	  	<!--- check Access level *****--->
	  	<cfif currentPage EQ "settings_frame_mainwindow.cfm"><cf_SPACaller module="create_far"></cfif>
		<a href="/ReportWriter/pm/administration/Functional_Area/create_far.cfm?PageTitle=PROJECTS: Functional Areas List Management" target="mainwindow" onClick="window.parent.frames['toc'].location.href='settings_frame_toc.cfm?subnav=Projects'">
			 functional areas
		</a><br>
	</cfif>

	<cfif getSpa.create_Phase OR URL.AdminUserFromProfilesPage eq 1>
		<!--- check Access level *****--->
		<cfif currentPage EQ "settings_frame_mainwindow.cfm"><cf_SPACaller module="create_Phase"></cfif>
		<a href="/ReportWriter/pm/administration/Phase/create_Phase.cfm?PageTitle=PROJECTS: Phase List Management" target="mainwindow" onClick="window.parent.frames['toc'].location.href='settings_frame_toc.cfm?subnav=Projects'">
			 phase
		</a><br>
	</cfif>

	<cfif getSpa.create_Priority OR URL.AdminUserFromProfilesPage eq 1>
		<!--- check Access level *****--->
		<cfif currentPage EQ "settings_frame_mainwindow.cfm"><cf_SPACaller module="create_Priority"></cfif>
		<a href="/ReportWriter/pm/administration/Priority/create_Priority.cfm?PageTitle=PROJECTS: Priority List Management" target="mainwindow" onClick="window.parent.frames['toc'].location.href='settings_frame_toc.cfm?subnav=Projects'">
			priorities
		</a><br>
  	</cfif>

	<cfif getSpa.create_Sponsor OR URL.AdminUserFromProfilesPage eq 1>
		<!--- check Access level *****--->
		<cfif currentPage EQ "settings_frame_mainwindow.cfm"><cf_SPACaller module="create_Sponsor"></cfif>
		<a href="/ReportWriter/pm/administration/Sponsor/create_Sponsor.cfm?PageTitle=PROJECTS: Sponsors List Management" target="mainwindow" onClick="window.parent.frames['toc'].location.href='settings_frame_toc.cfm?subnav=Projects'">
			 sponsors
		</a><br>
	</cfif>

	<cfif getSpa.create_status OR URL.AdminUserFromProfilesPage eq 1>
		<!--- check Access level *****--->
		<cfif currentPage EQ "settings_frame_mainwindow.cfm"><cf_SPACaller module="create_status"></cfif>
		<a href="/ReportWriter/pm/administration/status/create_status.cfm?PageTitle=PROJECTS: Status List Management" target="mainwindow" onClick="window.parent.frames['toc'].location.href='settings_frame_toc.cfm?subnav=Projects'">
			status
		</a><br>
  	</cfif>

</cfsavecontent>
</cfif>
<!--- Create cfsavecontent variable="payables" in alphabetical order --->
<cfset aryPayables = ArrayNew(1)>
<cfset aryPayablesLink = ArrayNew(1)>
<cfset aryPayablesFile = ArrayNew(1)>
<cfset aryPayablesSPACaModule = ArrayNew(1)>

		<!---<cfif application.deductionLinksAvailable> --->
        <cfif request.settings.Deduction_Module>
		  <!------ deduction code ----->
			<cfif getSpa.Create_Stage OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryPayablesLink, LCase(stDeductionLabels["Action"]))>
				<cfset ArrayAppend(aryPayablesFile, "/Deductions/Settings/Stage/Create_Stage.cfm?PageTitle=Deductions: #stDeductionLabels['Action']# List Management")>
				<cfset ArrayAppend(aryPayablesSPACaModule, "Create_Stage")>
			</cfif>
		</cfif>

		<cfif getSpa.peril_age OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryPayablesLink, "age warning")>
			<cfset ArrayAppend(aryPayablesFile, "/billbacks/settings/peril_age.cfm")>
			<cfset ArrayAppend(aryPayablesSPACaModule, "peril_age")>
		</cfif>

		<!---<cfif application.deductionLinksAvailable> --->
		<!--- <cfif request.settings.Deduction_Module> --->
        <cfif request.settings.Deduction_Module>
                <cfif getSpa.Create_Aging OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryPayablesLink, "aging")>
				<cfset ArrayAppend(aryPayablesFile, "/Deductions/Settings/Aging/Create_Aging.cfm?PageTitle=Deductions: Aging Management")>
				<cfset ArrayAppend(aryPayablesSPACaModule, "Create_Aging")>
			</cfif>
		</cfif>
		<!--- label 38386   uncomment Alias Management --->
        <cfif request.settings.Use_Big_Billbacks>
			<cfif getSpa.Alias_Management OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryPayablesLink, "alias management")>
				<cfset ArrayAppend(aryPayablesFile, "/settings/AliasManagement/index.cfm")>
				<cfset ArrayAppend(aryPayablesSPACaModule, "Alias_Management")>
			</cfif>

		</cfif>


		<cfif getSpa.Auto_Approve OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryPayablesLink, "auto approve")>
			<cfset ArrayAppend(aryPayablesFile, "/billbacks/Settings/Auto_Approve.cfm?PageTitle=Billbacks: Auto Approve")>
			<cfset ArrayAppend(aryPayablesSPACaModule, "Auto_Approve")>
		</cfif>

		<cfif getSpa.Auto_Close OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryPayablesLink, "auto close/match")>
			<cfset ArrayAppend(aryPayablesFile, "/Deductions/Settings/Auto_Close.cfm?PageTitle=Deductions: Auto Close/Match")>
			<cfset ArrayAppend(aryPayablesSPACaModule, "Auto_Close")>
		</cfif>

        <cfif request.settings.BB_Auto_Report>
			<cfif getSpa.BB_AUTO_REPORT OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryPayablesLink, "auto pay")>
				<cfset ArrayAppend(aryPayablesFile, "/billbacks/Auto_BB_Report/bb_auto_report_view.cfm")>   <!--- 48219 --->
				<cfset ArrayAppend(aryPayablesSPACaModule, "BB_AUTO_REPORT")>

				<!--- 34980,37470  hold back building the new auto pay page
				<cfif request.AccessStructure.User_Rights_ID EQ 9999 >
					<cfset ArrayAppend(aryPayablesLink, "auto pay BB reference admin")>
					<cfset ArrayAppend(aryPayablesFile, "/billbacks/Auto_BB_Report/AutoPayAdminFx.cfm?PageTitle=BillBack: Auto Pay")>
					<cfset ArrayAppend(aryPayablesSPACaModule, "BB_AUTO_REPORT")>
				</cfif> --->

			</cfif>
		</CFIF>

		<cfif getSpa.BB_Business_Considerations_Reminders OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryPayablesLink, "bb bus. cons. reminders")>
			<cfset ArrayAppend(aryPayablesFile, "/Settings/BB_bus_con_reminders.cfm")>
			<cfset ArrayAppend(aryPayablesSPACaModule, "BB_Business_Considerations_Reminders")>
	  	</cfif>

		<cfif getSpa.BB_Assignment OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryPayablesLink, "billback assignment")>
			<cfset ArrayAppend(aryPayablesFile, "/billbacks/Assignment/index.cfm")>
			<cfset ArrayAppend(aryPayablesSPACaModule, "BB_Assignment")>
		</cfif>

    <!--- 18281 Start -Anand Rao/28-May-09 --->
		<cfif (getSpa.BB_Closing_Methods OR URL.AdminUserFromProfilesPage eq 1) AND request.AccessStructure.User_Rights_ID EQ 9999>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryPayablesLink, "billback closing methods")>
			<cfset ArrayAppend(aryPayablesFile, "/settings/BB_Closing_Methods/BB_Closing_methods.cfm")>
			<cfset ArrayAppend(aryPayablesSPACaModule, "BB_Closing_Methods")>
		</cfif>
    <!--- 18281 End --->

        <cfif request.settings.claimAutoPrint>
			<cfif getSpa.Billback_Batch_Print OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryPayablesLink, "claim print")>
				<cfset ArrayAppend(aryPayablesFile, "Billback_Batch_Print.cfm")>
				<cfset ArrayAppend(aryPayablesSPACaModule, "Billback_Batch_Print")>
			</cfif>
		</cfif>


      <cfif request.settings.DD_Show_Classification>
			<cfif getSpa.Create_Classifications OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryPayablesLink, LCase(stDeductionLabels["Classification"]))>
				<cfset ArrayAppend(aryPayablesFile, "/Deductions/Settings/classification/Create_Classifications.cfm?PageTitle=Deductions: #stDeductionLabels['Classification']# List Management")>
				<cfset ArrayAppend(aryPayablesSPACaModule, "Create_Classifications")>
			</cfif>
		  </cfif>
			<!---26487 - 2011-mar-9 chrisn: added deduction type--->
		<cfif getSpa.deduction_type OR URL.AdminUserFromProfilesPage eq 1>
      <cfif request.settings.DD_Show_DeductionType>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryPayablesLink, LCase(stDeductionLabels["Deduction Type"]))>
				<cfset ArrayAppend(aryPayablesFile, "/Deductions/Settings/DeductionType/index.cfm")>
				<cfset ArrayAppend(aryPayablesSPACaModule, "deduction_type")>
			</cfif>
		</cfif>
		<!---<cfif application.deductionLinksAvailable> --->
		<cfif request.settings.Deduction_Module>
			<cfif getSpa.Assignment_index2 OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryPayablesLink, "deduction assignment")>
				<cfset ArrayAppend(aryPayablesFile, "/deductions/Assignment/index2.cfm?PageTitle=Deductions: Manage Deductions Assignment")>
				<cfset ArrayAppend(aryPayablesSPACaModule, "Assignment_index2")>
			</cfif>
		</cfif>

		<cfif getSpa.expectations OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryPayablesLink, "deviation tolerance")>
			<cfset ArrayAppend(aryPayablesFile, "/billbacks/settings/expectations.cfm")>
			<cfset ArrayAppend(aryPayablesSPACaModule, "expectations")>
		</cfif>

		<CFIF application.returned_customer_setting.Show_Fund_Settings EQ 1 AND Get_Profile_Settings.Fund_Setting_Access EQ 1>
		  	<cfif getSpa.Fund_Management OR URL.AdminUserFromProfilesPage eq 1>
			  	<!--- check Access level *****--->
			  	<cfset ArrayAppend(aryPayablesLink, "fund")>
				<cfset ArrayAppend(aryPayablesFile, "/GL_Code/GL_Code_In_Program/Fund_Management.cfm")>
				<cfset ArrayAppend(aryPayablesSPACaModule, "Fund_Management")>
			</cfif>
		</CFIF>

		<cfif getSpa.Interface_Payables OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryPayablesLink, "interface payables")>
			<cfset ArrayAppend(aryPayablesFile, "/settings/interface_payables/interface_payables.cfm?PageTitle=BillBack: Interface Payables")>
			<cfset ArrayAppend(aryPayablesSPACaModule, "Interface_Payables")>
		</cfif>

		<CFIF application.returned_customer_setting.Upload_GL_Code EQ 1>
			<cfif getSpa.Upload_Gl_Code_index OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryPayablesLink, "manage gl code")>
				<cfset ArrayAppend(aryPayablesFile, "/GL_Code/Upload_Gl_Code/index.cfm")>
				<cfset ArrayAppend(aryPayablesSPACaModule, "Upload_Gl_Code_index")>
		  	</cfif>
		</CFIF>

		<!---<cfif application.deductionLinksAvailable> --->
		<cfif request.settings.Deduction_Module>
			<CFIF application.returned_customer_setting.DD_Show_Operator_For_RC_Of_Accrual EQ 1>
				<cfif getSpa.Create_Operator OR URL.AdminUserFromProfilesPage eq 1>
					<!--- check Access level *****--->
					<cfset ArrayAppend(aryPayablesLink, "#LCase(application.returned_customer_setting.operator_label_plural)#")>
					<cfset ArrayAppend(aryPayablesFile, "/Deductions/Settings/Operator/Create_Operator.cfm?PageTitle=Deductions: #application.returned_customer_setting.operator_label_singular#")>
					<cfset ArrayAppend(aryPayablesSPACaModule, "Create_Operator")>
				</cfif>
			</cfif>
		</cfif>

  		<cfif getSpa.DD_External_Settings OR URL.AdminUserFromProfilesPage eq 1>
	  		<!--- check Access level *****--->
	  		<cfset ArrayAppend(aryPayablesLink, "payables settings")>
			<cfset ArrayAppend(aryPayablesFile, "/deductions/settings/deduction_external_settings.cfm?PageTitle=Payables: Settings")>
			<cfset ArrayAppend(aryPayablesSPACaModule, "DD_External_Settings")>
		</cfif>

		<!--- START: 36746: Billbacks - Reprocess UI/Anand Rao/23-Apr-2013  --->
        <cfif request.settings.BB_Default_Program_Retry_Process>
	  		<cfif getSpa.Billback_Reprocess OR URL.AdminUserFromProfilesPage eq 1>
		  		<!--- check Access level *****--->
		  		<cfset ArrayAppend(aryPayablesLink, "re-process")>
				<cfset ArrayAppend(aryPayablesFile, "/billbacks/settings/reprocess.cfm")>
				<cfset ArrayAppend(aryPayablesSPACaModule, "Billback_Reprocess")>
			</cfif>
		</cfif>
		<!--- END: 36746: Billbacks - Reprocess UI/Anand Rao/23-Apr-2013  --->

        <!--- Dev Notes: 19384/Anand Rao/05-Apr-10  --->
        <cfif request.settings.Integrated_Rebill eq '1'>
			<cfif getSpa.Rebill_Packages OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryPayablesLink, "rebill packages")>
			<cfset ArrayAppend(aryPayablesFile, "/Deductions/Settings/Rebill/index_Rebill_Package.cfm?PageTitle=Deductions: Rebill Packages")>
			<cfset ArrayAppend(aryPayablesSPACaModule, "Rebill_Packages")>
			</cfif>
		</cfif>
    <!--- 19384 End --->

		<!---<cfif application.deductionLinksAvailable> --->
		<cfif request.settings.Deduction_Module>
			<cfif getSpa.Create_Reason_Code OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryPayablesLink, LCase(stDeductionLabels["Reason Code"]))>
				<cfset ArrayAppend(aryPayablesFile, "/Deductions/Settings/Reason_Code/Create_Reason_Code.cfm?PageTitle=Deductions: #stDeductionLabels['Reason Code']#")>
				<cfset ArrayAppend(aryPayablesSPACaModule, "Create_Reason_Code")>
			</cfif>
		</cfif>

		<CFIF application.returned_customer_setting.BB_PC_GL_reason_codes_on EQ 1>
			<cfif getSpa.create_reason_codeBB OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryPayablesLink, "reason codes maint.")>
				<cfset ArrayAppend(aryPayablesFile, "/billbacks/settings/BBReasonCode/create_reason_code.cfm")>
				<cfset ArrayAppend(aryPayablesSPACaModule, "create_reason_codeBB")>
			</cfif>
		</CFIF>

		<cfif request.settings.PullbacksOn> <!--- D48340 Recapture vs. Pullback Control Settings Options --->
		<!--- 43819 Recapture via list of operators --->
		<cfif getSpa.Recapture_By_Operator OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryPayablesLink, "#request.settings.Pullback_Label# by #lCase(application.returned_customer_setting.operator_label_singular)#")>
			<cfset ArrayAppend(aryPayablesFile, "/settings/Recapture_By_Operator.cfm")>
			<cfset ArrayAppend(aryPayablesSPACaModule, "Recapture_By_Operator")>
		</cfif>
		</cfif>
		<!---<cfif application.deductionLinksAvailable> --->
		<cfif request.settings.Deduction_Module>
			<cfif WhoRebills.Rebill IS 2 AND application.returned_customer_setting.DD_Show_Rebill EQ 1>
				<cfif getSpa.Rebill_Letter OR URL.AdminUserFromProfilesPage eq 1>
					<!--- check Access level *****--->
					<cfset ArrayAppend(aryPayablesLink, "rebill notification")>
					<cfset ArrayAppend(aryPayablesFile, "/Deductions/Settings/Rebill/index.cfm?PageTitle=Deductions: Rebill Clauses")>
					<cfset ArrayAppend(aryPayablesSPACaModule, "Rebill_Letter")>
				</cfif>
			</cfif>
			<cfif getSpa.Reminder_Status_Create OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryPayablesLink, "reminder types")>
				<cfset ArrayAppend(aryPayablesFile, "/Deductions/Settings/Reminder_Status_Create.cfm?PageTitle=Deductions: Reminder Type Management")>
				<cfset ArrayAppend(aryPayablesSPACaModule, "Reminder_Status_Create")>
			</cfif>
		</cfif>

        <cfif request.settings.settlement_sap_business>
			<cfif getSpa.SP_ReasonCode OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryPayablesLink, "shortpay reasons")>
				<cfset ArrayAppend(aryPayablesFile, "/Billbacks/settings/ShortPay_ReasonCode/SP_ReasonCode.cfm")>
				<cfset ArrayAppend(aryPayablesSPACaModule, "SP_ReasonCode")>
			</cfif>
		</CFIF>

		<cfif getSpa.BB_SubTotal_Display OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryPayablesLink, "sub-total display")>
			<cfset ArrayAppend(aryPayablesFile, "/billbacks/Settings/Sub_total_Display.cfm")>
			<cfset ArrayAppend(aryPayablesSPACaModule, "BB_SubTotal_Display")>
		</cfif>

		<!--- BJF D21919 Divested Items --->

		<cfif getSpa.Divested_Items OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryPayablesLink, "divested items")>
			<cfset ArrayAppend(aryPayablesFile, "/settings/Divested_Items/index.cfm")>
			<cfset ArrayAppend(aryPayablesSPACaModule, "Divested_Items")>
		</cfif>


		<cfif request.settings.PullbacksOn>
			<cfif getSpa.Unapplied_Pullbacks OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryPayablesLink, "unapplied #lcase(appSettings.getPullbackLabel())#")>
				<cfset ArrayAppend(aryPayablesFile, "/settings/unapplied_pullback_report.cfm?PageTitle=BillBack: Unapplied Pullback Report")>
				<cfset ArrayAppend(aryPayablesSPACaModule, "Unapplied_Pullbacks")>
			</cfif>
		</CFIF>

		<cfif request.settings.Vendor_Batching eq '1'>
		<cfif getSpa.vendor_Batching OR URL.AdminUserFromProfilesPage eq 1>
			<cfset billbackLabels = createObject("component", "mvc.Models.SettingsService").getBBLabels() />
			<cfset ArrayAppend(aryPayablesLink, lcase(billBackLabels["Vendor"]) & " batching")>
			<cfset ArrayAppend(aryPayablesFile, "/GL_Code/Vendor_management/vendorBatching.cfm")>
			<cfset ArrayAppend(aryPayablesSPACaModule, "vendor_Batching")>
		</cfif>
		</cfif>

		<CFIF application.returned_customer_setting.Upload_GL_Code EQ 1>
		  	<cfif getSpa.Upload_Product_Grp OR URL.AdminUserFromProfilesPage eq 1>
		  		<!--- check Access level *****--->
		  		<cfset ArrayAppend(aryPayablesLink, "upload product group")>
				<cfset ArrayAppend(aryPayablesFile, "/GL_Code/Product_Grp/Upload_Product_Grp.cfm")>
				<cfset ArrayAppend(aryPayablesSPACaModule, "Upload_Product_Grp")>
			</cfif>
		</CFIF>

		<!--- Clorox automation  --->
		<cfif appSettings.get_Setting('GPO_One_Page_Program_Creation') eq '1'>
			<cfset ArrayAppend(aryPayablesLink, "upload automation")>
			<cfset ArrayAppend(aryPayablesFile, "/billbacks/Upload_Automation/index.cfm")>
			<cfset ArrayAppend(aryPayablesSPACaModule, "Upload_Automation_Index")>
		</cfif>

        <cfif request.settings.BB_UPLOAD_UPDATED eq 1>
            <cfif getSpa.Upload_Billback_index OR URL.AdminUserFromProfilesPage eq 1>
                    <!--- check Access level *****--->
                    <cfset ArrayAppend(aryPayablesLink, "upload payables")>
                    <cfset ArrayAppend(aryPayablesFile, "/Settings/upload_billback_utility/index.cfm?Show_Tab=1")>
                    <cfset ArrayAppend(aryPayablesSPACaModule, "Upload_Billback_index")>
            </cfif>
		</CFIF>

		<cfif getSpa.vendor_Form OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****---><!--- d28955: modified link and redirect to new INDEX file --->
			<cfset ArrayAppend(aryPayablesLink, "vendor mgmt.")>
			<cfset ArrayAppend(aryPayablesFile, "/GL_Code/Vendor_management/index.cfm")>
			<cfset ArrayAppend(aryPayablesSPACaModule, "vendor_Form")>
		</cfif>

<!---- 117446 :: Billback - sales tax code START--->
	<cfif appSettings.getBillbacksSalesTax() EQ 2>
		<!--- check Access level *****--->
		<cfset ArrayAppend(aryPayablesLink, "tax")>
		<cfset ArrayAppend(aryPayablesFile, "/billbacks/settings/Create_Tax_Record.cfm?PageTitle=Payables: Create Tax Record")>
		<cfset ArrayAppend(aryPayablesSPACaModule, "Sales_Tax")>
	</cfif>
<!---- 117446 :: Billback - sales tax code END--->

<!--- START: 44787: Kraft - Alias update for invoice count in the Holding Pen --->
        <cfif request.settings.Show_Holding_Pen eq 1>
			<cfif getSpa.Show_Holding_Pen OR URL.AdminUserFromProfilesPage eq 1>
					<!--- check Access level *****--->
					<cfset ArrayAppend(aryPayablesLink, "holding pen")>
					<cfset ArrayAppend(aryPayablesFile, "/Settings/Holding_Pen/index.cfm")>
					<cfset ArrayAppend(aryPayablesSPACaModule, "Show_Holding_Pen")>
			</cfif>
		</cfif>
<!--- END: 44787: Kraft - Alias update for invoice count in the Holding Pen --->

<!--- START: 66060	Claims Input Accelerator - OCR Design and Planning - Phase 1 --->
		<cfif (request.settings.OCR_Upload_ON EQ '1')>
			<cfif getSpa.OCR_Upload OR URL.AdminUserFromProfilesPage eq 1>
					<!--- check Access level *****--->
					<cfset ArrayAppend(aryPayablesLink, "CIA Templates")>
					<cfset ArrayAppend(aryPayablesFile, "/billbacks/OCR_Upload/Settings/index.cfm?PageTitle=BillBack: CIA Templates")>
					<cfset ArrayAppend(aryPayablesSPACaModule, "OCR_Upload")>

					<cfset ArrayAppend(aryPayablesLink, "CIA Usage Report")>
					<cfset ArrayAppend(aryPayablesFile, "/billbacks/OCR_Upload/Settings/ReportIndex.cfm?PageTitle=BillBack: CIA Templates")>
					<cfset ArrayAppend(aryPayablesSPACaModule, "CIA_Usage_Report")>
			</cfif>
		</cfif>
<!--- END: 66060	Claims Input Accelerator - OCR Design and Planning - Phase 1 --->

        <cfif request.settings.product_replacement_enabled eq 1>
			<cfif getSpa.product_replacement OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->


				<cfset ArrayAppend(aryPayablesLink, "product replacement")>
				<cfset ArrayAppend(aryPayablesFile, "/settings/product_replacement/index.cfm")>
				<cfset ArrayAppend(aryPayablesSPACaModule, "product_replacement")>

			</cfif>

		</CFIF>

		<cfif getSpa.Default_Vendor_OR_BB_Closing_Method OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryPayablesLink, "def vendor/bb closing meth")>
			<cfset ArrayAppend(aryPayablesFile, "/settings/default_vendor/operators.cfm")>
			<cfset ArrayAppend(aryPayablesSPACaModule, "Default_Vendor_OR_BB_Closing_Method")>
		</cfif>

		<cfif request.settings.EDI_Viewer_Format NEQ "None">
			<cfif getSpa.EDI_Viewer OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryPayablesLink, "EDI viewer")>
				<cfif request.settings.EDI_Viewer_Format eq "Flex">
					<cfset ArrayAppend(aryPayablesFile, "/settings/EDI_Viewer/EDIViewerFx.cfm")>
				<cfelse>
					<cfset ArrayAppend(aryPayablesFile, "/settings/EDI_Viewer/EDIViewer_Main.cfm")>
				</cfif>
				<cfset ArrayAppend(aryPayablesSPACaModule, "EDI_Viewer")>
			</cfif>
		</cfif>

<cfset aryPayables = aryPayablesLink>
<cfset ArraySort(aryPayables, "textnocase")>
<cfset ListPayables = ArrayToList(aryPayablesLink, ",")>

<cfsavecontent variable="Payables">
	<cfif currentPage EQ "settings_frame_mainwindow.cfm">
	<div nowrap style="width:600px;">
		<div style="float:left; width:250px;">
	</cfif>
	<cfif ArrayLen(aryPayables) mod 2 is 0>
		<cfset middleNumber = ArrayLen(aryPayables)\2>
	<cfelse>
		<cfset middleNumber = ArrayLen(aryPayables)\2 +1>
	</cfif>
	<cfloop index = "LoopCount" from = "1" to = #ArrayLen(aryPayables)#>
		<cfset indexList = ListFind(ListPayables, "#aryPayables[LoopCount]#")>
		<cfif currentPage EQ "settings_frame_mainwindow.cfm"><cf_SPACaller module="#aryPayablesSPACaModule[indexList]#"></cfif>
		<a href="#aryPayablesFile[indexList]#" target="mainwindow" onClick="window.parent.frames['toc'].location.href='settings_frame_toc.cfm?subnav=Payables'">
		 	 #aryPayablesLink[indexList]#
		</a><br>
		<cfif LoopCount eq middleNumber>
			<cfif currentPage EQ "settings_frame_mainwindow.cfm">
	  			</div>
	  			<div style="float:left;">
			</cfif>
		</cfif>
	</cfloop>
	<cfif currentPage EQ "settings_frame_mainwindow.cfm">
			</div>
		</div>
	</cfif>
</cfsavecontent>

<!--- Create cfsavecontent variable="Programs" in alphabetical order --->
<cfset aryPrograms = ArrayNew(1)>
<cfset aryProgramsLink = ArrayNew(1)>
<cfset aryProgramsFile = ArrayNew(1)>
<cfset aryProgramsSPACaModule = ArrayNew(1)>
		<cfif application.bidPricingLinksAvailable>
			<!------ bid pricing ----->
			<cfif getSpa.bid_rules_index OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryProgramsLink, "bid rules")>
				<cfset ArrayAppend(aryProgramsFile, "/settings/bid_rules/index.cfm")>
				<cfset ArrayAppend(aryProgramsSPACaModule, "bid_rules_index")>
			</cfif>
		</cfif>

		<cfif request.settings.Budgets_Functionality_On>
			<cfif (getSpa.budgets and Get_Profile_Settings.create_budget neq -1) OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryProgramsLink, "budgets")>
				<cfset ArrayAppend(aryProgramsFile, "/Settings/Advanced_Budget/index.cfm")>
				<cfset ArrayAppend(aryProgramsSPACaModule, "budgets")>
			</cfif>
		</cfif>
		<!---</cfif>--->
		<cfif request.settings.Budgets_Functionality_On>
			<cfif getSpa.budget_reports OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryProgramsLink, "budget reports")>
				<cfset ArrayAppend(aryProgramsFile, "/Settings/Advanced_Budget/Orphaned_programs_Billbacks.cfm")>
				<cfset ArrayAppend(aryProgramsSPACaModule, "budget_reports")>
			</cfif>
		</cfif>


		<cfif getSpa.Business_Considerations_Reminders OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
				<cfset ArrayAppend(aryProgramsLink, "business considerations reminders")>
				<cfset ArrayAppend(aryProgramsFile, "/Settings/bus_con_reminders.cfm")>
				<cfset ArrayAppend(aryProgramsSPACaModule, "Business_Considerations_Reminders")>
		</cfif>

		<!---business segments--->
		<CFIF application.returned_customer_setting.business_segments_on EQ 1>
			<cfif (getSpa.business_segment_index OR URL.AdminUserFromProfilesPage eq 1) and  len(trim(request.settings.Business_Segment_Label)) gt 0>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryProgramsLink, "#lcase(request.settings.Business_Segment_Label)#")>
				<cfset ArrayAppend(aryProgramsFile, "/settings/business_segment/index.cfm")>
				<cfset ArrayAppend(aryProgramsSPACaModule, "business_segment_index")>
		  	</cfif>
		</CFIF>

	  	<cfif getSpa.payment_type_index OR URL.AdminUserFromProfilesPage eq 1>
		  	<!--- check Access level *****--->
				<cfset ArrayAppend(aryProgramsLink, "claim mechanics")>
				<cfset ArrayAppend(aryProgramsFile, "/settings/payment_type/index.cfm")>
				<cfset ArrayAppend(aryProgramsSPACaModule, "payment_type_index")>
	  	</cfif>

			<cfif getSpa.claim_rates OR URL.AdminUserFromProfilesPage eq 1>	<!---34596--->
					<cfset ArrayAppend(aryProgramsLink, "claim rates")>
					<cfset ArrayAppend(aryProgramsFile, "/settings/claim_rates/list.cfm")>
					<cfset ArrayAppend(aryProgramsSPACaModule, "claim_rates")>
	  	</cfif>

      <!--- Anand Rao/03-Jun-10/23635 - Competitive Data, Forge changes --->
	  	<cfif getSpa.competitive_data OR URL.AdminUserFromProfilesPage eq 1>
		  	<!--- check Access level *****--->
				<cfset ArrayAppend(aryProgramsLink, "competitive data")>
				<cfset ArrayAppend(aryProgramsFile, "/settings/competitive_data/competitive_data.cfm")>
				<cfset ArrayAppend(aryProgramsSPACaModule, "competitive_data")>
	  	</cfif>

		<!--- BJF D11147--->
        <cfif request.settings.Component_Product_Restrictions_On>
			<cfif getSpa.Component_Product_Restrictions OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryProgramsLink, "component restrictions")>
				<cfset ArrayAppend(aryProgramsFile, "/settings/Component_Product_Restrictions/index.cfm")>
				<cfset ArrayAppend(aryProgramsSPACaModule, "Component_Product_Restrictions")>
	 		</cfif>
		</cfif>

        <cfif request.settings.customer_type>
			<cfif getSpa.customer_type_list OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryProgramsLink, "customer types")>
				<cfset ArrayAppend(aryProgramsFile, "/settings/Customer_Type/customer_type_list.cfm")>
				<cfset ArrayAppend(aryProgramsSPACaModule, "customer_type_list")>
		  	</cfif>
		</cfif>

		<cfif getSpa.currency OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
				<cfset ArrayAppend(aryProgramsLink, "currency")>
				<cfset ArrayAppend(aryProgramsFile, "/settings/Currency/index.cfm?PageTitle=programs: currency")>
				<cfset ArrayAppend(aryProgramsSPACaModule, "currency")>
	  	</cfif>

		<!--- BJF: 11212 --->
        <cfif request.settings.Distributor_Product_Integrity_On eq 1>
			<cfif getSpa.Distributor_Product_Integrity_On OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryProgramsLink, "#lcase(application.returned_customer_setting.distributor_label_singular)# product integrity")>
				<cfset ArrayAppend(aryProgramsFile, "/Settings/Distributor_Product_Integrity/index.cfm")>
				<cfset ArrayAppend(aryProgramsSPACaModule, "Distributor_Product_Integrity_On")>
	  		</cfif>
		</CFIF>

		<!------ discount identifier ----->
		<CFIF application.returned_customer_setting.discount_identifier_on EQ 1>
			<cfif getSpa.Discount_Identifier_index OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryProgramsLink, "discount identifiers")>
				<cfset ArrayAppend(aryProgramsFile, "/settings/Discount_Identifier/index.cfm")>
				<cfset ArrayAppend(aryProgramsSPACaModule, "Discount_Identifier_index")>
			</cfif>
		</CFIF>

	  	<cfif getSpa.fixed_components_index OR URL.AdminUserFromProfilesPage eq 1>
		  	<!--- check Access level *****--->
			<cfset ArrayAppend(aryProgramsLink, "fixed components")>
			<cfset ArrayAppend(aryProgramsFile, "/settings/fixed_components/index.cfm?PageTitle=programs: fixed components")>
			<cfset ArrayAppend(aryProgramsSPACaModule, "fixed_components_index")>
	 	</cfif>

 <!---		<cfif getSpa.Formula_pricing_index>
	 		<!--- check Access level *****--->
			<cfset ArrayAppend(aryProgramsLink, "formula pricing")>
			<cfset ArrayAppend(aryProgramsFile, "/settings/Formula_pricing/index.cfm?PageTitle=programs: formula pricing")>
			<cfset ArrayAppend(aryProgramsSPACaModule, "Formula_pricing_index")>
  		</cfif>--->

  		<cfif getSpa.Formula_pricing_index OR URL.AdminUserFromProfilesPage eq 1>
	 		<!--- check Access level *****--->
			<cfset ArrayAppend(aryProgramsLink, "commodity maintenance")>
			<cfset ArrayAppend(aryProgramsFile, "/settings/Formula_Pricing/V2/getUSDACommodityPrices.cfm?PageTitle=programs: commodity maintenance")>
			<cfset ArrayAppend(aryProgramsSPACaModule, "Formula_pricing_index")>
  		</cfif>

		<cfif appSettings.getShow_Fixed_Freight() eq 1>
			<cfif getSpa.freight_settings OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryProgramsLink, "freight settings")>
				<cfset ArrayAppend(aryProgramsFile, "/Settings/freight/index.cfm")>
				<cfset ArrayAppend(aryProgramsSPACaModule, "freight_settings")>
			</cfif>
		</cfif>

		<!------ futures pricing ----->
		<cfif appSettings.getFuturesPricingAvailable()>
			<cfif getSpa.settings_index OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryProgramsLink, "futures pricing")>
				<cfset ArrayAppend(aryProgramsFile, "/Futures_Pricing/settings/index.cfm?PageTitle=programs: futures pricing")>
				<cfset ArrayAppend(aryProgramsSPACaModule, "settings_index")>
		  	</cfif>
		</cfif>

		<cfif appSettings.getGL_Account_On() IS 1>
			<cfif getSpa.GL_Account OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryProgramsLink, "#lcase(Application.GLAccountLabel)#")><!---42774 --->
				<cfset ArrayAppend(aryProgramsFile, "/Settings/GL_Account/index.cfm")>
				<cfset ArrayAppend(aryProgramsSPACaModule, "GL_Account")>
			</cfif>
		</cfif>

		<!--- Dev Notes: D23601/Anand Rao/01-Jul-10;  Margin Page, Items to Exclude --->
  		<cfif appSettings.getMarginItemsExclude()>
			<cfif getSpa.Margin_Items_To_Exclude OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryProgramsLink, "margin - items to exclude")>
				<cfset ArrayAppend(aryProgramsFile, "/Settings/Margin_Items_To_Exclude/index.cfm")>
				<cfset ArrayAppend(aryProgramsSPACaModule, "Margin_Items_To_Exclude")>
			</cfif>
		</cfif>

		<!--- Dev Note: KAL; 12/11/2010; D25195: Mass Program Upload --->
		<cfif getSpa.Mass_Program_Change_Upload OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryProgramsLink, "mass program change upload")>
			<cfset ArrayAppend(aryProgramsFile, "/Settings/Mass_Program_Change/index.cfm")>
			<cfset ArrayAppend(aryProgramsSPACaModule, "Mass_Program_Change_Upload")>
		</cfif>

		<!--- Dev Note: KAL; 05/30/2013; D34605: Mass Price Change --->
		<cfif getSpa.Mass_Price_Change OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryProgramsLink, "mass price change")>
			<cfset ArrayAppend(aryProgramsFile, "/Settings/Mass_Price_Change/index.cfm")>
			<cfset ArrayAppend(aryProgramsSPACaModule, "Mass_Price_Change")>
		</cfif>

		<!--- Dev Note: Tim Ford - 05/31/2017; D66318: Mass program load utility --->
		<cfif getSpa.Mass_Program_Load OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryProgramsLink, "mass program load")>
			<cfset ArrayAppend(aryProgramsFile, "/settings/Mass_Program_Load/index.cfm")>
			<cfset ArrayAppend(aryProgramsSPACaModule, "Mass_Program_Load")>
		</cfif>

		<!--- Dev Note: Milan (44077) - Modify Pre-active Dates --->
		<cfif appSettings.getMassChangePreactive() EQ 1 AND Get_Profile_Settings.Mass_Change_Program_Date EQ 1
		AND getSpa.Modify_Preactive_Dates OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryProgramsLink, "modify pre-active dates")>
			<cfset ArrayAppend(aryProgramsFile, "/Settings/Modify_Preactive_Dates/index.cfm")>
			<cfset ArrayAppend(aryProgramsSPACaModule, "Modify_Preactive_Dates")>
		</cfif>

		<!--- growth component --->
		<cfif getSpa.growth_components_index OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryProgramsLink, "growth components")>
			<cfset ArrayAppend(aryProgramsFile, "/settings/Growth_Components/index.cfm?PageTitle=programs: growth components")>
			<cfset ArrayAppend(aryProgramsSPACaModule, "growth_components_index")>
	 	</cfif>

<!--- D38941 ---  Settings --  New Limited User Profile Edit Functionality--->
		<cfif getSpa.Limited_Revise OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryProgramsLink, "limited revise")>
			<cfset ArrayAppend(aryProgramsFile, "/settings/limited_revise.cfm?PageTitle=programs: limited revise")>
			<cfset ArrayAppend(aryProgramsSPACaModule, "limited_revise")>
	 	</cfif>
<!--- D38941 ---  Settings --  New Limited User Profile Edit Functionality--->


		<cfif appSettings.getUseXMaterial() EQ 1>
			<cfif getSpa.Generate_Interface_File OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryProgramsLink, "interface file")>
				<cfset ArrayAppend(aryProgramsFile, "Generate_Interface_File.cfm?PageTitle=programs: interface file")>
				<cfset ArrayAppend(aryProgramsSPACaModule, "Generate_Interface_File")>
		  	</cfif>
		</cfif>

		<cfif getSpa.lump_sum_names_index OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryProgramsLink, "#lcase(Application.LumpsumLabel)# components")>
			<cfset ArrayAppend(aryProgramsFile, "/settings/lump_sum_names/index.cfm")>
			<cfset ArrayAppend(aryProgramsSPACaModule, "lump_sum_names_index")>
 		</cfif>
		<!--- 23692 moved manage documents link to  Administration section
	  	<cfif getSpa.Create_Document_Details>
		  	<!--- check Access level *****--->
			<cfset ArrayAppend(aryProgramsLink, "manage documents")>
			<cfset ArrayAppend(aryProgramsFile, "/Common_Files/Documents/Create_Document_Details.cfm?PageTitle=programs: programs")>
			<cfset ArrayAppend(aryProgramsSPACaModule, "Create_Document_Details")>
	  	</cfif>
		--->
		<!--- <a href="/settings/margin_targets/index.cfm?PageTitle=programs: margin targets" target="mainwindow" onClick="window.parent.frames['toc'].location.href='settings_frame_toc.cfm?subnav=Programs'">  --->
		<cfif getSpa.upload_margin_targets_index OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryProgramsLink, "margin targets")>
			<CFIF appSettings.getuploadmargintargets_on()>
				<cfset ArrayAppend(aryProgramsFile, "/settings/upload_margin_targets/index.cfm?PageTitle=programs: margin targets")>
			<CFELSE>
				<cfset ArrayAppend(aryProgramsFile, "/settings/margin_targets/index.cfm?PageTitle=programs: margin targets")>
			</CFIF>
			<cfset ArrayAppend(aryProgramsSPACaModule, "upload_margin_targets_index")>
		</cfif>

		<cfif appSettings.getmodifyagreeprogram() eq 1>
			<cfif getSpa.edit_program_settings OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryProgramsLink, "modify agree")>
				<cfset ArrayAppend(aryProgramsFile, "/Settings/edit_agreed_program.cfm")>
				<cfset ArrayAppend(aryProgramsSPACaModule, "edit_program_settings")>
		  	</cfif>
	  	</cfif>

		<CFIF usdanoi_on EQ 1>
			<cfif getSpa.usdanoi_index OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryProgramsLink, "noi control panel")>
				<cfset ArrayAppend(aryProgramsFile, "/settings/usdanoi/index.cfm")>
				<cfset ArrayAppend(aryProgramsSPACaModule, "usdanoi_index")>
		  	</cfif>
		</cfif>

		<!------ off-invoice components ----->
		<cfif appSettings.getDisplayDistributorOffInvoice() IS 1>
			<cfif getSpa.offinvoice_components_index OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryProgramsLink, "off-invoice components")>
				<cfset ArrayAppend(aryProgramsFile, "/settings/offinvoice_components/index.cfm?PageTitle=programs: off-invoice components")>
				<cfset ArrayAppend(aryProgramsSPACaModule, "offinvoice_components_index")>
		 	</cfif>
		</cfif>

		<cfif appsettings.getOperatingGroupOn()>
			<cfif getSpa.operating_group_index OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryProgramsLink, "operating groups")>
				<cfset ArrayAppend(aryProgramsFile, "/Settings/Operating_group/index.cfm")>
				<cfset ArrayAppend(aryProgramsSPACaModule, "operating_group_index")>
		  	</cfif>
		</cfif>

		<cfif getSpa.operator_management OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryProgramsLink, "#LCase(application.returned_customer_setting.operator_label_singular)# management")>
			<cfset ArrayAppend(aryProgramsFile, "/Settings/operator_management/index.cfm")>
			<cfset ArrayAppend(aryProgramsSPACaModule, "operator_management")>
	  	</cfif>

		<!---accounting specialists--->
		<cfif application.returned_customer_setting.Accounting_Specialist eq 1>
			<cfif getSpa.Accounting_Specialists_index OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryProgramsLink, "payment processor")>
				<cfset ArrayAppend(aryProgramsFile, "/settings/Accounting_Specialists/index.cfm?PageTitle=programs: payment processor")>
				<cfset ArrayAppend(aryProgramsSPACaModule, "Accounting_Specialists_index")>
		  	</cfif>
		</cfif>

		<cfif getSpa.performance_requirements OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryProgramsLink, "performance requirements")>
			<cfset ArrayAppend(aryProgramsFile, "/Program_Wizard/performance_requirements.cfm")>
			<cfset ArrayAppend(aryProgramsSPACaModule, "performance_requirements")>
	 	</cfif>

		<!------ bid request components ----->
		<cfif appSettings.getDisplayProposal() IS 1>
			<cfif getSpa.bidrequest_components_index OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryProgramsLink, "proposal components")>
				<cfset ArrayAppend(aryProgramsFile, "/settings/bid_request_components/index.cfm?PageTitle=programs: proposal components")>
				<cfset ArrayAppend(aryProgramsSPACaModule, "bidrequest_components_index")>
		 	</cfif>
		</cfif>

		<cfif appSettings.getProgramCategory() IS 1>
			<cfif getSpa.Program_Category OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryProgramsLink, "program category")>
				<cfset ArrayAppend(aryProgramsFile, "/Settings/program_category/index.cfm")>
				<cfset ArrayAppend(aryProgramsSPACaModule, "Program_Category")>
		  	</cfif>
		</cfif>

		<!---Accounting program types--->
		<cfif appSettings.getUse_Accounting_Program_Type() EQ 1>
			<cfif getSpa.Accounting_Program_Type OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryProgramsLink, "program labels")>
				<cfset ArrayAppend(aryProgramsFile, "/settings/Accounting_Program_Types/index.cfm?PageTitle=programs: interface file")>
				<cfset ArrayAppend(aryProgramsSPACaModule, "Accounting_Program_Type")>
			</cfif>
		</cfif>
		<cfif appsettings.getProgramAlerts()>
		  <cfif getSpa.Program_Alerts OR URL.AdminUserFromProfilesPage eq 1><!--- D30010 : Settings Control Access – User incorrectly seeing --->
				<!---Program Alerts --->
				<cfset ArrayAppend(aryProgramsLink, "program alerts")>
				<cfset ArrayAppend(aryProgramsFile, "/settings/Program_Alerts/index.cfm")>
				<cfset ArrayAppend(aryProgramsSPACaModule, "Program_Alerts")>
		  </cfif>
		</cfif>

<!--- D37372 Kraft Special Project - Program Qualificaitons START--->
		<cfif getSpa.Program_Qualifications OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryProgramsLink, "program qualifications")>
			<cfset ArrayAppend(aryProgramsFile, "/Program_Wizard/Program_Qualifications.cfm")>
			<cfset ArrayAppend(aryProgramsSPACaModule, "Program_Qualifications")>
		</cfif>
<!--- D37372 Kraft Special Project - Program Qualificaitons END --->

		<CFIF Get_Profile_Settings.Cont_Prog_View_Create_Program NEQ 0> <!--- 2 places to check for program access --->
			<cfif getSpa.Program_Wizard_index OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryProgramsLink, "program templates")><!---D38356	Chane Program Wizard to Program Templates  --->
				<cfset ArrayAppend(aryProgramsFile, "/Program_Wizard/index.cfm")>
				<cfset ArrayAppend(aryProgramsSPACaModule, "Program_Wizard_index")>
		  	</cfif>
		</cfif>

		<cfif getSpa.rebate_components_index OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryProgramsLink, "#lcase(Application.RebateLabel)# components")>
			<cfset ArrayAppend(aryProgramsFile, "/settings/rebate_components/index.cfm?PageTitle=programs: #Application.RebateLabel# components")>
			<cfset ArrayAppend(aryProgramsSPACaModule, "rebate_components_index")>
	  	</cfif>


		<cfif getSpa.contract_settings OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryProgramsLink, "settings")>
			<cfset ArrayAppend(aryProgramsFile, "/settings/contract_settings.cfm?PageTitle=programs: contracts")>
			<cfset ArrayAppend(aryProgramsSPACaModule, "contract_settings")>
		</cfif>


		<!--- D26123:volume forecast
			Added Volume forecast link Below START--->
		<cfif getSpa.volume_forecasting OR URL.AdminUserFromProfilesPage eq 1>
		<cfif Get_Profile_Settings.Volume_Forecast>
			<cfset ArrayAppend(aryProgramsLink, "volume forecasting")>
			<cfset ArrayAppend(aryProgramsFile, "/Settings/Volume_Forecast/index.cfm")>
			<cfset ArrayAppend(aryProgramsSPACaModule, "volume_forecasting")>
		</cfif>
		</cfif>
        <!--- D26123: volume forecast END --->

		<cfif appsettings.gettemplatecodes_on()>
			<cfif getSpa.template_codes_index OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryProgramsLink, "template codes")>
				<cfset ArrayAppend(aryProgramsFile, "/settings/template_codes/index.cfm")>
				<cfset ArrayAppend(aryProgramsSPACaModule, "template_codes_index")>
		  	</cfif>
		</cfif>

		<cfif appSettings.ShowUploadAccrual IS 1>
			<cfif getSpa.ShowUploadAccrual OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryProgramsLink, "upload corporate rates")>
				<cfset ArrayAppend(aryProgramsFile, "/settings/uploadaccrual/index.cfm")>
				<cfset ArrayAppend(aryProgramsSPACaModule, "ShowUploadAccrual")>
		  	</cfif>
		</cfif>

		<!--- Credit Types *****--->
		<!---
		D23133: Change Request - Bagcraft - Component level exclusions
		This settings panel should be available only when the application switch -Credit types are same as deduction reason codes is OFF. --->
		<CFIF appSettings.getCreditTypeIsDDReasonCode() EQ 0>
			<cfif getSpa.credit_types OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->

				<cfset ArrayAppend(aryProgramsLink, "credit types")>
				<cfset ArrayAppend(aryProgramsFile, "credit_types.cfm")>
				<cfset ArrayAppend(aryProgramsSPACaModule, "credit_types")>

			</cfif>

		</CFIF>

		<cfif getSpa.Approval_Considerations OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryProgramsLink, "approval considerations")>
			<cfset ArrayAppend(aryProgramsFile, "/settings/Approval_Considerations.cfm")>
			<cfset ArrayAppend(aryProgramsSPACaModule, "Approval_Considerations")>
		</cfif>

		<!---
		<cfif getSpa.product_alias_management>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryProgramsLink, "product alias management")>
			<cfset ArrayAppend(aryProgramsFile, "/settings/Alias/index.cfm")>
			<cfset ArrayAppend(aryProgramsSPACaModule, "product_alias_management")>
		</cfif>
		--->

		<cfif appSettings.getappEZButtonOn() and (getSpa.EZ_Button_Rate OR URL.AdminUserFromProfilesPage eq 1)>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryProgramsLink, "ez button rate")>
			<cfset ArrayAppend(aryProgramsFile, "/settings/EZ_Button_Rate/list.cfm")>
			<cfset ArrayAppend(aryProgramsSPACaModule, "EZ_Button_Rate")>
		</cfif>

<cfset aryPrograms = aryProgramsLink>
<cfset ArraySort(aryPrograms, "textnocase")>
<cfset ListPrograms = ArrayToList(aryProgramsLink, ",")>
<cfsavecontent variable="programs">
	<cfif currentPage EQ "settings_frame_mainwindow.cfm">
	<div nowrap style="width:600px;">
		<div style="float:left; width:250px;">
	</cfif>
	<cfif ArrayLen(aryPrograms) mod 2 is 0>
		<cfset middleNumber = ArrayLen(aryPrograms)\2>
	<cfelse>
		<cfset middleNumber = ArrayLen(aryPrograms)\2 +1>
	</cfif>
	<cfloop index = "LoopCount" from = "1" to = #ArrayLen(aryPrograms)#>
		<cfset indexList = ListFind(ListPrograms, "#aryPrograms[LoopCount]#")>
		<cfif currentPage EQ "settings_frame_mainwindow.cfm"><cf_SPACaller module="#aryProgramsSPACaModule[indexList]#"></cfif>
		<a href="#aryProgramsFile[indexList]#" target="mainwindow" onClick="window.parent.frames['toc'].location.href='settings_frame_toc.cfm?subnav=Programs'">
		 	 #aryProgramsLink[indexList]#
			<!--- When a user visits from the "profiles" page to assign "Hide/Show" access rights --->
			 <cfif URL.AdminUserFromProfilesPage eq 1 AND aryProgramsLink[indexList] eq "budgets">
			 <CF_SmallHelp
							width='300'
							imgPath='/Images/i.gif'
							imgWidth='12'
							imgHeight='11'
							dropdownCheck='0'
				>
				<p style='text-align: left;color:black'>Please take into consideration the profile access rights for this feature as well</p>
			</CF_SmallHelp>
			</cfif>
		</a><br>

		<cfif LoopCount eq middleNumber>
			<cfif currentPage EQ "settings_frame_mainwindow.cfm">
	  			</div>
	 			 <div style="float:left;">
			</cfif>
		</cfif>
	</cfloop>
	<cfif currentPage EQ "settings_frame_mainwindow.cfm">
			</div>
		</div>
	</cfif>
</cfsavecontent>

<!---- START: 57305: Retail Planner/01-Mar-2016/Anand Rao ---->
<cfset aryPlanner = ArrayNew(1)>
<cfset aryPlannerLink = ArrayNew(1)>
<cfset aryPlannerFile = ArrayNew(1)>
<cfset aryPlannerSPACaModule = ArrayNew(1)>
<cfif request.settings.Retail_Planner eq '1'>
    <cfif getSpa.Planner_Scorecard_Settings OR URL.AdminUserFromProfilesPage eq 1>
        <cfset ArrayAppend(aryPlannerLink, "scorecard summary")>
        <cfset ArrayAppend(aryPlannerFile, "/settings/planners/scorecard_summary/index.cfm")>
        <cfset ArrayAppend(aryPlannerSPACaModule, "Planner_Scorecard_Settings")>
    </cfif>
	<cfif getSpa.Planner_Calendar_Config OR URL.AdminUserFromProfilesPage eq 1>
		<!--- check Access level *****--->
		<cfset ArrayAppend(aryPlannerLink, "calendar info")>
		<cfset ArrayAppend(aryPlannerFile, "/settings/planners/Calendar_Info/index.cfm")>
		<cfset ArrayAppend(aryPlannerSPACaModule, "Planner_Calendar_Config")>
	</cfif>
	<cfscript>
		if ( getSpa.Planner_Indirect_Allocation or URL.AdminUserFromProfilesPage eq 1 ) {
			aryPlannerLink.append( "indirect % allocation" );
			aryPlannerFile.append( "/settings/planners/indirect_allocation/index.cfm" );
			aryPlannerSPACaModule.append( "Planner_Indirect_Allocation" );
		}
	</cfscript>
	<cfif getSpa.Planner_Perf_types OR URL.AdminUserFromProfilesPage eq 1>
		<!--- check Access level *****--->
		<cfset ArrayAppend(aryPlannerLink, "performance types")>
		<cfset ArrayAppend(aryPlannerFile, "/settings/Planners/Planner_Perf_Types/index.cfm")>
		<cfset ArrayAppend(aryPlannerSPACaModule, "Planner_Perf_types")>
	</cfif>
	<cfif getSpa.Planner_Templates OR URL.AdminUserFromProfilesPage eq 1>
		<!--- check Access level *****--->
		<cfset ArrayAppend(aryPlannerLink, "<CFOUTPUT>#LCase(Application.PlannerLabel)#</CFOUTPUT> templates")>
		<cfset ArrayAppend(aryPlannerFile, "/Planners/Templates/page_list.cfm")>
		<cfset ArrayAppend(aryPlannerSPACaModule, "Planner_Templates")>
	</cfif>
	<cfif getSpa.Planner_Customer_Settings OR URL.AdminUserFromProfilesPage eq 1>
		<!--- check Access level *****--->
		<cfset ArrayAppend(aryPlannerLink, "<CFOUTPUT>#LCase(Application.PlannerLabel)#</CFOUTPUT> customer settings")>
		<cfset ArrayAppend(aryPlannerFile, "/settings/Planners/planner_customer/index.cfm")>
		<cfset ArrayAppend(aryPlannerSPACaModule, "Planner_Customer_Settings")>
	</cfif>
	<cfif getSpa.Planner_Output_Settings OR URL.AdminUserFromProfilesPage eq 1>
		<!--- check Access level *****--->
		<cfset ArrayAppend(aryPlannerLink, "<CFOUTPUT>#LCase(Application.PlannerLabel)#</CFOUTPUT> output settings")>
		<cfset ArrayAppend(aryPlannerFile, "/settings/Planners/planner_output/list.cfm")>
		<cfset ArrayAppend(aryPlannerSPACaModule, "Planner_Output_Settings")>
	</cfif>
	<cfif appSettings.get_Setting('Planner_Targets_Enabled') EQ "1" AND (getSpa.Planner_Targets OR URL.AdminUserFromProfilesPage eq 1)>
		<!--- check Access level *****--->
		<cfset ArrayAppend(aryPlannerLink, "targets")>
		<cfset ArrayAppend(aryPlannerFile, "/settings/Planners/targets/index.cfm")>
		<cfset ArrayAppend(aryPlannerSPACaModule, "Planner_Targets")>
	</cfif>

	<cfset aryPlanner = aryPlannerLink>
	<cfset ArraySort(aryPlanner, "textnocase")>
	<cfset ListPlanner = ArrayToList(aryPlannerLink, ",")>
	<cfsavecontent variable="planner">
		<cfloop index = "LoopCount" from = "1" to = #ArrayLen(aryPlanner)#>
			<cfset indexList = ListFind(ListPlanner, "#aryPlanner[LoopCount]#")>
			<cfif currentPage EQ "settings_frame_mainwindow.cfm"><cf_SPACaller module="#aryPlannerSPACaModule[indexList]#"></cfif>
			<a href="#aryPlannerFile[indexList]#" target="mainwindow" onClick="window.parent.frames['toc'].location.href='settings_frame_toc.cfm?subnav=Planners'">
			 	 #aryPlannerLink[indexList]#
			</a><br>
		</cfloop>
	</cfsavecontent>

</cfif> <!--- END: <cfif appSettings.get_Setting('Retail_Planner') eq '1'> --->
<!--- END: 57305: Retail Planner/01-Mar-2016/Anand Rao --->



<!--- Create cfsavecontent variable="administration" in alphabetical order --->
<cfset aryAdministration = ArrayNew(1)>
<cfset aryAdministrationLink = ArrayNew(1)>
<cfset aryAdministrationFile = ArrayNew(1)>
<cfset aryAdministrationSPACaModule = ArrayNew(1)>


		<cfif getSpa.select_system_administrator_form OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryAdministrationLink, "administrator")>
			<cfset ArrayAppend(aryAdministrationFile, "select_system_administrator_form.cfm")>
			<cfset ArrayAppend(aryAdministrationSPACaModule, "select_system_administrator_form")>
	  	</cfif>

		<cfif appSettings.getAppSettingsOnForAll() OR request.AccessStructure.User_Rights_ID EQ 9999>
			<cfif getSpa.app_settings OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryAdministrationLink, "application settings")>
				<cfset ArrayAppend(aryAdministrationFile, "/settings/app_settings.cfm?PageTitle=SYSTEM ADMINISTRATION: APPLICATION GENERAL SETTINGS")>
				<cfset ArrayAppend(aryAdministrationSPACaModule, "app_settings")>

		  	</cfif>
		</cfif>
		<cfif appSettings.getlocalcostvariables() eq 1>
			<cfif getSpa.approval_cost_variables OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryAdministrationLink, "approval cost variables")>
				<cfset ArrayAppend(aryAdministrationFile, "/settings/approval_costs/index.cfm?PageTitle=SYSTEM ADMINISTRATION: APPROVAL COST VARIABLES")>
				<cfset ArrayAppend(aryAdministrationSPACaModule, "approval_cost_variables")>
		  	</cfif>
		</cfif>
		<cfif getSpa.Authorized_Distribution_List OR URL.AdminUserFromProfilesPage eq 1>
			<cfset ArrayAppend(aryAdministrationLink, "authorized distribution list (ADL)")>
			<cfset ArrayAppend(aryAdministrationFile, "/settings/ADL/index.cfm")>
			<cfset ArrayAppend(aryAdministrationSPACaModule, "Authorized_Distribution_List")>
		</cfif>
	  	<cfif appsettings.getDataIntViewer()>
			<cfif getSpa.dataintegration OR URL.AdminUserFromProfilesPage eq 1>
				<cfset ArrayAppend(aryAdministrationLink, "data integration viewer")>
				<cfset ArrayAppend(aryAdministrationFile, "/common_files/dataInt/dataIntMaster.cfm")>
				<cfset ArrayAppend(aryAdministrationSPACaModule, "dataintegration")>
	  		</cfif>

		<cfelseif appsettings.getsend_to_sap()>
			<cfif getSpa.dataintegration OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryAdministrationLink, "data integration viewer")>
				<cfset ArrayAppend(aryAdministrationFile, "/settings/dataintegration/saprebatechildren.cfm")>
				<cfset ArrayAppend(aryAdministrationSPACaModule, "dataintegration")>
			</cfif>
	  	</cfif>
		<cfif appSettings.getViewDeleteRecords()>
			<cfif getSpa.Delete_Records OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryAdministrationLink, "delete records")>
			<cfset ArrayAppend(aryAdministrationFile, "/Settings/delete_records.cfm")>
			<cfset ArrayAppend(aryAdministrationSPACaModule, "delete_records")>
			</cfif>
		</cfif>
		<!--- Dev Note: drachala; D29268: Email Log Update
			Moved email log link from Users to Administrators--->
        <!---Email Logs --->
		<cfif getSpa.email_log OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryAdministrationLink, "email log")>
			<cfset ArrayAppend(aryAdministrationFile, "/settings/Email_Log_Display.cfm")>
			<cfset ArrayAppend(aryAdministrationSPACaModule, "email_log")>
	  	</cfif>
	  	<!--- End Dev Note: drachala; D29268: Email Log Update  --->
		<!---Email notifications --->
		<cfif getSpa.email_notification OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryAdministrationLink, "email notifications")>
			<cfset ArrayAppend(aryAdministrationFile, "/settings/notification/index.cfm?PageTitle=SYSTEM ADMINISTRATION: Session Management")>
			<cfset ArrayAppend(aryAdministrationSPACaModule, "email_notification")>
	  	</cfif>
		<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getShowExportPrograms()>
			<cfif getSpa.Export_Data_Management OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryAdministrationLink, "export data management")>
				<cfset ArrayAppend(aryAdministrationFile, "/Settings/export_data_management/index.cfm")>
				<cfset ArrayAppend(aryAdministrationSPACaModule, "Export_Data_Management")>
			</cfif>
		</cfif>

		<cfif appSettings.External_Contacts_Option neq 0>   <!---28345--->
				<cfset ArrayAppend(aryAdministrationLink, "external contacts")>
				<cfset ArrayAppend(aryAdministrationFile, "/Settings/external_contacts/index.cfm")>
				<cfset ArrayAppend(aryAdministrationSPACaModule, "external_contacts")>
		</cfif>
		<cfif getSpa.fiscal_year_settings OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryAdministrationLink, "fiscal year")>
			<cfset ArrayAppend(aryAdministrationFile, "/settings/fiscal_year_settings.cfm?PageTitle=SYSTEM ADMINISTRATION: Fiscal Year")>
			<cfset ArrayAppend(aryAdministrationSPACaModule, "fiscal_year_settings")>
	  	</cfif>
		<!---Only show this link if floor pricing is turned on--->
		<cfif appSettings.getFloorPrice() IS 1>
			<cfif getSpa.floor_prices OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryAdministrationLink, "floor prices")>
				<cfset ArrayAppend(aryAdministrationFile, "/settings/floor_prices.cfm")>
				<cfset ArrayAppend(aryAdministrationSPACaModule, "floor_prices")>
		  	</cfif>
	  	</cfif>

		<cfif getSpa.Create_Document_Details OR URL.AdminUserFromProfilesPage eq 1>
		  	<!--- check Access level *****--->
			<cfset ArrayAppend(aryAdministrationLink, "manage documents")>
			<cfset ArrayAppend(aryAdministrationFile, "/Common_Files/Documents/Attach_Document.cfm?bFromSettings=1")>
			<cfset ArrayAppend(aryAdministrationSPACaModule, "Create_Document_Details")>
	  	</cfif>

		<!--- This is meant for sites we do not host --->
		<!---
		<cfif appSettings.getAppErrorAddToPunchlist() EQ 0 OR request.AccessStructure.USER_RIGHTS_ID EQ 9999>
			<cfif ((Get_Profile_Settings.Install_patch gt 0 AND getSpa.install_patch) OR URL.AdminUserFromProfilesPage eq 1)) AND request.AccessStructure.USER_RIGHTS_ID EQ 9999>
				<cfset ArrayAppend(aryAdministrationLink, "install patch")>
				<cfset ArrayAppend(aryAdministrationFile, "/Release_Tracker/file_upload.cfm?PageTitle=SYSTEM ADMINISTRATION: Install Patch")>
				<cfset ArrayAppend(aryAdministrationSPACaModule, "install_patch")>
			</cfif>
		</cfif>
		--->
		<cfif getSpa.session_management OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryAdministrationLink, "logoff time out")>
			<cfset ArrayAppend(aryAdministrationFile, "/settings/session_management.cfm?PageTitle=SYSTEM ADMINISTRATION: Session Management")>
			<cfset ArrayAppend(aryAdministrationSPACaModule, "session_management")>
	  	</cfif>
	  	<cfif getSpa.price_protection OR URL.AdminUserFromProfilesPage eq 1>
	  		<!--- check Access level *****--->
			<cfset ArrayAppend(aryAdministrationLink, "price protection")>
			<cfset ArrayAppend(aryAdministrationFile, "/settings/price_protection/price_protection_index.cfm")>
			<cfset ArrayAppend(aryAdministrationSPACaModule, "price_protection")>
	  	</cfif>
	  	<!--- <cfif getSpa.management_reports>
		  	<!--- check Access level *****--->
		  	<cfif currentPage EQ "settings_frame_mainwindow.cfm"><cf_SPACaller module="management_reports"></cfif>
		 	<A HREF="/reportwriter/performance_reports/management_reports.cfm" target="mainwindow" OnClick="window.parent.frames['toc'].location.href='settings_frame_toc.cfm?subnav=Administration'">
				reports
			</a><br>
	 	</cfif> --->
		<!--- Did not allow to see this link from the profiles page (RL.AdminUserFromProfilesPage eq 1), as this link is not meant for users other than "9999" users. --->
		<cfif request.AccessStructure.USER_RIGHTS_ID EQ 9999 AND URL.AdminUserFromProfilesPage eq 0>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryAdministrationLink, "scheduled jobs")>
				<cfset ArrayAppend(aryAdministrationFile, "/settings/scheduled_jobs/scheduled_jobs.cfm?PageTitle=SYSTEM ADMINISTRATION: scheduled jobs")>
				<cfset ArrayAppend(aryAdministrationSPACaModule, "scheduled_jobs")>
		</cfif>
		<!--- Did not allow to see this link from the profiles page (RL.AdminUserFromProfilesPage eq 1), as this link is not meant for users other than "9999" users. --->
		<cfif request.AccessStructure.USER_RIGHTS_ID EQ 9999 AND URL.AdminUserFromProfilesPage eq 0>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryAdministrationLink, "settings management")>
			<cfset ArrayAppend(aryAdministrationFile, "/settings/Settings_Management/Settings_Management.cfm?PageTitle=SYSTEM ADMINISTRATION: SETTINGS MANAGEMENT")>
			<cfset ArrayAppend(aryAdministrationSPACaModule, "settings_management")>
		</cfif>

		<!---BJF D10010 Client Work Request --->
		<CFIF usdanoi_on EQ 1>
			<cfif getSpa.usdanoi_index_2 OR URL.AdminUserFromProfilesPage eq 1>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryAdministrationLink, "schedule month end reports")>
				<cfset ArrayAppend(aryAdministrationFile, "/Settings/usdanoi/schedule_month_end_reports.cfm")>
				<cfset ArrayAppend(aryAdministrationSPACaModule, "usdanoi_index_2")>
		  	</cfif>
		</cfif>
	  	<cfif appSettings.getRevisionTypesOn()>
		  	<cfif getSpa.edit_revise_program_settings OR URL.AdminUserFromProfilesPage eq 1>
			  	<!--- check Access level *****--->
				<cfset ArrayAppend(aryAdministrationLink, "short cut approval")>
				<cfset ArrayAppend(aryAdministrationFile, "/Settings/edit_revise_program.cfm")>
				<cfset ArrayAppend(aryAdministrationSPACaModule, "edit_revise_program_settings")>
		  	</cfif>
		</cfif>

		<cfif appSettings.getProfitabilityModel()>
		  <!--- check Access level *****--->
			<cfif getSpa.prof_model_excludes OR URL.AdminUserFromProfilesPage eq 1>
				 <cfset ArrayAppend(aryAdministrationLink, "profitability model excludes")>
				 <cfset ArrayAppend(aryAdministrationFile, "/settings/Prof_Model_Excludes/template.cfm")>
				 <cfset ArrayAppend(aryAdministrationSPACaModule, "Prof_Model_Excludes")>
			</cfif>
		  <!--- check Access level *****--->
			<cfif getSpa.prof_model_classifications OR URL.AdminUserFromProfilesPage eq 1>
				 <cfset ArrayAppend(aryAdministrationLink, "profitability model classifications")>
				 <cfset ArrayAppend(aryAdministrationFile, "/settings/prof_model_classification/template.cfm")>
				 <cfset ArrayAppend(aryAdministrationSPACaModule, "prof_model_classifications")>
			</cfif>
		  <!--- check Access level *****--->
			<cfif getSpa.prof_model_xref OR URL.AdminUserFromProfilesPage eq 1>
				 <cfset ArrayAppend(aryAdministrationLink, "profitability model xref")>
				 <cfset ArrayAppend(aryAdministrationFile, "/settings/prof_model_xref/item.cfm")>
				 <cfset ArrayAppend(aryAdministrationSPACaModule, "prof_model_xref")>
			</cfif>
		</cfif>

	  	<cfif appSettings.getPgmPostApprovalStatus() and appSettings.getPgmPostApprovalStatusType() NEQ 1>
            <cfset post_approval_cfc    = CreateObject("component", "components.programs.ProgramPostApprovalStatusManager")>
            <cfset post_approval_access = post_approval_cfc.getProfileProgramPostApprovalStatusChangeAccess(request.AccessStructure.Profiles_ID, 2)>

            <cfif post_approval_access>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryAdministrationLink, "update entry status")>
				<cfset ArrayAppend(aryAdministrationFile, "/settings/post_approval_status/update_entry_status_index.cfm?PageTitle=SYSTEM ADMINISTRATION: UPDATE ENRTY STATUS")>
				<cfset ArrayAppend(aryAdministrationSPACaModule, "approval_cost_variables")>
		  	</cfif>
		</cfif>
		<!---BJF D10010 Client Work Request --->
    <cfif (Get_Profile_Settings.Submit_Work_Request IS 1 AND getSpa.Submit_Work_Request) OR URL.AdminUserFromProfilesPage eq 1>
				<cfset ArrayAppend(aryAdministrationLink, "work requests")>
				<cfset ArrayAppend(aryAdministrationFile, "/Settings/Work_Request/index.cfm")>
				<cfset ArrayAppend(aryAdministrationSPACaModule, "Submit_Work_Request")>
	  	</cfif>


      <!--- 24526 - Planning Groups Mock up START --->
      <!---   <!--- Condition for the Profile settings should go here --->
				<cfset ArrayAppend(aryAdministrationLink, "planning groups")>
				<cfset ArrayAppend(aryAdministrationFile, "/Settings/Planning_Groups/Mock/index.cfm")>
				<cfset ArrayAppend(aryAdministrationSPACaModule, "Planning_Groups")> --->

		<!--- Dev Notes: D24526/Anand Rao/04-Oct-10;  Planning Group Module --->
  		<cfif appSettings.getPlanningGroups()>
			<cfif ((getSpa.Planning_Groups OR URL.AdminUserFromProfilesPage eq 1) AND Get_Profile_Settings.Planning_Groups_Create NEQ 0)>
				<!--- check Access level *****--->
				<cfset ArrayAppend(aryAdministrationLink, "planning groups")>
				<cfset ArrayAppend(aryAdministrationFile, "/Settings/Planning_Groups/index.cfm")>
				<cfset ArrayAppend(aryAdministrationSPACaModule, "Planning_Groups")>
			</cfif>
		</cfif>
  <!--- D30948:Master data edit page START --->
        <cfif appSettings.getEdit_Product_Master_Data() AND Get_Profile_Settings.Edit_Product_MasterData>
			<cfif getSpa.Edit_Master_data OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
				<cfset ArrayAppend(aryAdministrationLink, "edit master data")>
				<cfset ArrayAppend(aryAdministrationFile, "/Settings/edit_master_data/index.cfm")>
				<cfset ArrayAppend(aryAdministrationSPACaModule, "Edit_Master_Data")>
			</cfif>
		</cfif>
   <!--- D30948:Master data edit page START --->

      <!--- 24526 - Planning Groups Mock up END --->

 <!--- D33669  ::  Customer Membership Dates START--->
		<cfif getSpa.Membership OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
 				<cfset ArrayAppend(aryAdministrationLink, "membership")>
				<cfset ArrayAppend(aryAdministrationFile, "/Settings/membership/index.cfm")>
				<cfset ArrayAppend(aryAdministrationSPACaModule, "Membership")>
		</cfif>
 <!--- D33669  ::  Customer Membership Dates END --->

		<cfif getSpa.Alias_Management_Admin OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryAdministrationLink, "alias management")>
			<cfif request.settings.alias_management_format is "Flex">
				<cfset ArrayAppend(aryAdministrationFile, "/settings/Alias_Management/AliasMainFx.cfm")>
			<cfelse>
				<cfset ArrayAppend(aryAdministrationFile, "/settings/Alias_Management/AliasMain.cfm")>
			</cfif>
			<cfset ArrayAppend(aryAdministrationSPACaModule, "Alias_Management_Admin")>
		</cfif>

		<cfif getSpa.alias_sources OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryAdministrationLink, "alias sources")>
			<cfset ArrayAppend(aryAdministrationFile, "/settings/Alias_Sources/alias_sources.cfm")>
			<cfset ArrayAppend(aryAdministrationSPACaModule, "alias_sources")>
		</cfif>

		<cfif getSpa.Product_Costs OR URL.AdminUserFromProfilesPage eq 1>  <!--- 39162 --->
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryAdministrationLink, "product costs")>
			<cfset ArrayAppend(aryAdministrationFile, "/settings/edit_master_data/productCosts.cfm")>
			<cfset ArrayAppend(aryAdministrationSPACaModule, "Product_Costs")>
		</cfif>
<!--- D40659 :: Ability to run jobs for month end processes START --->
		<cfif getSpa.Run_Month_End_Jobs OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfset ArrayAppend(aryAdministrationLink, "run month end jobs")>
			<cfset ArrayAppend(aryAdministrationFile, "/settings/run_month_end_jobs.cfm")>
			<cfset ArrayAppend(aryAdministrationSPACaModule, "Run_Month_End_Jobs")>
		</cfif>
<!--- D40659 :: Ability to run jobs for month end processes END --->

<!--- 62230 :: In Settings have distributor, operator & product searches with no filters  START--->
	<!--- check Access level *****--->
	<cfif getSpa.Master_data EQ 1 OR URL.AdminUserFromProfilesPage EQ 1>
		<cfset ArrayAppend(aryAdministrationLink, "master data")>
		<cfset ArrayAppend(aryAdministrationFile, "/settings/master_data/distributor_master_data.cfm")>
		<cfset ArrayAppend(aryAdministrationSPACaModule, "Master_Data")>
	</cfif>
<!--- 62230 :: In Settings have distributor, operator & product searches with no filters  END--->
            
    <!--- 117080: Moved holiday list to Administration section and renamed to be manage holidays --->
    <cfif getSpa.Create_Holidays OR URL.AdminUserFromProfilesPage eq 1>
         <!--- check Access level *****--->
        <cfset ArrayAppend(aryAdministrationLink, "manage holidays")>
        <cfset ArrayAppend(aryAdministrationFile, "/billbacks/Check_Book/Bank_Tran/General_Ledger_Account/Create_Holidays.cfm")>
        <cfset ArrayAppend(aryAdministrationSPACaModule, "Create_Holidays")>
    </cfif>
  	<!--- cfif request.AccessStructure.USER_RIGHTS_ID EQ 9999> --->
  	<cfif ((isDefined("getSpa.Self_Serve") AND getSpa.Self_Serve) OR URL.AdminUserFromProfilesPage eq 1)>
 		<cfset ArrayAppend(aryAdministrationLink, "self serve")>
        <cfset ArrayAppend(aryAdministrationFile, "/settings/Self_Service/index.cfm")>
        <cfset ArrayAppend(aryAdministrationSPACaModule, "Self_Serve")>
	</cfif>
                    
<cfset aryAdministration = aryAdministrationLink>
<cfset ArraySort(aryAdministration, "textnocase")>
<cfset ListAdministration = ArrayToList(aryAdministrationLink, ",")>

<cfsavecontent variable="administration">

	<cfif currentPage EQ "settings_frame_mainwindow.cfm">
		<div nowrap style="width:600px;">
		<div style="float:left; width:250px;">
	</cfif>
	<cfif ArrayLen(aryAdministration) mod 2 is 0>
		<cfset middleNumber = ArrayLen(aryAdministration)\2>
	<cfelse>
		<cfset middleNumber = ArrayLen(aryAdministration)\2 +1>
	</cfif>
	<cfloop index = "LoopCount" from = "1" to = #ArrayLen(aryAdministration)#>
		<cfset indexList = ListFind(ListAdministration, "#aryAdministration[LoopCount]#")>
		<cfif currentPage EQ "settings_frame_mainwindow.cfm"><cf_SPACaller module="#aryAdministrationSPACaModule[indexList]#"></cfif>
		<a href="#aryAdministrationFile[indexList]#" target="mainwindow" onClick="window.parent.frames['toc'].location.href='settings_frame_toc.cfm?subnav=Administration'">
		 	 #aryAdministrationLink[indexList]#
			 <!--- When a user visits from the "profiles" page to assign "Hide/Show" access rights --->
			 <cfif URL.AdminUserFromProfilesPage eq 1 AND aryAdministrationLink[indexList] eq "work requests">
			 <CF_SmallHelp
							width='300'
							imgPath='/Images/i.gif'
							imgWidth='12'
							imgHeight='11'
							dropdownCheck='0'
				>
				<p style='text-align: left;color:black'>Please take into consideration the profile access rights for this feature as well</p>
			</CF_SmallHelp>
			</cfif>
		</a><br>

		<cfif LoopCount eq middleNumber>
			<cfif currentPage EQ "settings_frame_mainwindow.cfm">
	  			</div>
	 			 <div style="float:left;">
			</cfif>
		</cfif>
	</cfloop>

	<cfif currentPage EQ "settings_frame_mainwindow.cfm">
			</div>
		</div>
	</cfif>

</cfsavecontent>

<cfsavecontent variable="users">
	<cfif getSpa.users_create_form OR URL.AdminUserFromProfilesPage eq 1>
		<!--- check Access level *****--->
		<cfif currentPage EQ "settings_frame_mainwindow.cfm"><cf_SPACaller module="users_create_form"></cfif>
		<a href="/settings/Access_Rights/users_create_form.cfm?PageTitle=Users: add user"target="mainwindow" onClick="window.parent.frames['toc'].location.href='settings_frame_toc.cfm?subnav=Users'">
			add users
		</a><br>
 	</cfif>
	<cfif getSpa.Group_details OR URL.AdminUserFromProfilesPage eq 1>
		<!--- check Access level *****--->
		<cfif currentPage EQ "settings_frame_mainwindow.cfm"><cf_SPACaller module="Group_details"></cfif>
		<a href="Group_details.cfm?PageTitle=Users: Approval Group Maintenance"target="mainwindow" onClick="window.parent.frames['toc'].location.href='settings_frame_toc.cfm?subnav=Users'">
			approval groups
		</a><br>
 	</cfif>
	<cfif getSpa.authority_sequence_index OR URL.AdminUserFromProfilesPage eq 1>
		<!--- check Access level *****--->
		<cfif currentPage EQ "settings_frame_mainwindow.cfm"><cf_SPACaller module="authority_sequence_index"></cfif>
		<a href="/settings/authority_sequence/index.cfm"target="mainwindow" onClick="window.parent.frames['toc'].location.href='settings_frame_toc.cfm?subnav=Users'">
			authority sequence
		</a><br>
 	</cfif>
 	<!--- drachala; D29268: Email Log Update
	 	Moved email log link to Administrator Section from Users--->
	<!---<cfif getSpa.email_log>
		<!--- check Access level *****--->
		<cfif currentPage EQ "settings_frame_mainwindow.cfm"><cf_SPACaller module="email_log"></cfif>
		<a href="/settings/Email_Log_Display.cfm" target="mainwindow" onClick="window.parent.frames['toc'].location.href='settings_frame_toc.cfm?subnav=Users'">
			email log
		</a><br>
 	</cfif>--->
 	<!--- End Dev Note: drachala; D29268: Email Log Update  --->
	<cfif getSpa.users_search_form OR URL.AdminUserFromProfilesPage eq 1>
		<!--- check Access level *****--->
		<cfif currentPage EQ "settings_frame_mainwindow.cfm"><cf_SPACaller module="users_search_form"></cfif>
		<!--- Dev Note: drachala; D29591: List User page not sorting  START
        Added/Changed: Comment below link and added lew link--->
		<!---<a href="/index.cfm?event=settings.users.dspUsers" target="mainwindow" onClick="window.parent.frames['toc'].location.href='settings_frame_toc.cfm?subnav=Users'">--->
		<!--- End Dev Note: drachala; D29591: List User page not sorting  --->
		<a href="/views/settings/list_users.cfm" target="mainwindow" onClick="window.parent.frames['toc'].location.href='settings_frame_toc.cfm?subnav=Users'">
			list users
		</a>
		<cfif URL.AdminUserFromProfilesPage eq 1>&nbsp;&nbsp;&nbsp;
			<a href="/settings/Settings_Export.cfm" style="cursor:pointer">#application.util.string.actionLinkFormat("Export")#</a>
		</cfif>
		<br>
 	</cfif>
	<!--- Dev Note: KAL; 6/16/2010; D21544: LDAP : Remove Login Attempts feature when LDAP is on --->
	<cfif NOT appSettings.getLDAP_SSO_Enabled()>
		<cfif getSpa.login_attempts OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfif currentPage EQ "settings_frame_mainwindow.cfm"><cf_SPACaller module="login_attempts"></cfif>
			<a href="/settings/login_attempts.cfm" target="mainwindow" onClick="window.parent.frames['toc'].location.href='settings_frame_toc.cfm?subnav=Users'">
				login attempts
			</a><br>
	 	</cfif>
	</cfif>
	<cfif getSpa.traffic_info OR URL.AdminUserFromProfilesPage eq 1>
		<!--- check Access level *****--->
		<cfif currentPage EQ "settings_frame_mainwindow.cfm"><cf_SPACaller module="traffic_info"></cfif>
		<a href="/administrivia/traffic_info.cfm"target="mainwindow" onClick="window.parent.frames['toc'].location.href='settings_frame_toc.cfm?subnav=Users'">
			traffic info
		</a><br>
		</cfif>
	<!--- Dev Note: KAL; 6/16/2010; D21544: LDAP : Remove User Unlock when LDAP is on --->
	<cfif NOT appSettings.getLDAP_SSO_Enabled()>
		<cfif getSpa.unlock_user OR URL.AdminUserFromProfilesPage eq 1>
			<!--- check Access level *****--->
			<cfif currentPage EQ "settings_frame_mainwindow.cfm"><cf_SPACaller module="unlock_user"></cfif>
			<a href="/settings/unlock_user.cfm"target="mainwindow" onClick="window.parent.frames['toc'].location.href='settings_frame_toc.cfm?subnav=Users'">
				unlock user
			</a><br>
	 	</cfif>
	</cfif>
	<cfif getSpa.position_tree_index OR URL.AdminUserFromProfilesPage eq 1>
		<!--- check Access level *****--->
		<cfif currentPage EQ "settings_frame_mainwindow.cfm"><cf_SPACaller module="position_tree_index"></cfif>
		<a href="/settings/position_tree/index.cfm"target="mainwindow" onClick="window.parent.frames['toc'].location.href='settings_frame_toc.cfm?subnav=Users'">
			user positions
		</a><br>
 	</cfif>
	<!---
		Show the "user profiles link user he following cases -
		1) When user has acccess to thie module (getSpa.Access_Rights_index)
		2) Admin visits from the "user profile" page to "Show" or "hide" access rights  (URL.AdminUserFromProfilesPage eq 1)
		3) For "9999" users. (URL.AdminUserFromProfilesPage eq 0 AND request.AccessStructure.USER_RIGHTS_ID EQ 9999)
		Note: We have to use "URL.AdminUserFromProfilesPage eq 0", as "URL.AdminUserFromProfilesPage eq 1" is at a profile level
	--->
	<cfif getSpa.Access_Rights_index OR URL.AdminUserFromProfilesPage eq 1 OR (URL.AdminUserFromProfilesPage eq 0 AND request.AccessStructure.USER_RIGHTS_ID EQ 9999)>
		<!--- check Access level *****--->
		<cfif currentPage EQ "settings_frame_mainwindow.cfm"><cf_SPACaller module="Access_Rights_index"></cfif>
		<a href="/settings/user_profile_management_console.cfm" target="mainwindow" onClick="window.parent.frames['toc'].location.href='settings_frame_toc.cfm?subnav=Users'">
			user profiles
		</a><br>
	</cfif>
</cfsavecontent>

<cfsavecontent variable="password">
	<cfif getSpa.password_form OR URL.AdminUserFromProfilesPage eq 1>
		<!--- check Access level *****--->
		<cfif currentPage EQ "settings_frame_mainwindow.cfm"><cf_SPACaller module="password_form"></cfif>
		<A HREF="/settings/password_form.cfm?PageTitle=Personal Settings: change password" target="mainwindow" OnClick="window.parent.frames['toc'].location.href='settings_frame_toc.cfm?subnav=Password'">
			change password
		</a><br>
	</cfif>
</cfsavecontent>

<!--- Create cfsavecontent variable="BSAAdmin" in alphabetical order --->
<cfset aryBSAAdmin = ArrayNew(1)>
<cfset aryBSAAdminLink = ArrayNew(1)>
<cfset aryBSAAdminFile = ArrayNew(1)>


	<cfif application.returned_customer_setting.show_dataintegration EQ 1>
		<cfset ArrayAppend(aryBSAAdminLink, "#LCase(application.CompanyName)# data")>
		<cfset ArrayAppend(aryBSAAdminFile, "/settings/AwayXIntegration/index.cfm?PageTitle=SYSTEM ADMINISTRATION: <CFOUTPUT>#application.CompanyName#</CFOUTPUT> Data Integration")>

		<cfset ArrayAppend(aryBSAAdminLink, "company bank")>
		<cfset ArrayAppend(aryBSAAdminFile, "/billbacks/Check_Book/Company_Bank_Info_form.cfm")>

		<cfset ArrayAppend(aryBSAAdminLink, "customer bank")>
		<cfset ArrayAppend(aryBSAAdminFile, "/billbacks/Check_Book/Distributor_Bank_Info.cfm")>

		<cfset ArrayAppend(aryBSAAdminLink, "data integration")>
		<cfset ArrayAppend(aryBSAAdminFile, "/settings/dataintegration/index.cfm?PageTitle=SYSTEM ADMINISTRATION: Data Integration")>
	</cfif>
	<cfif lcase(application.datasource) EQ "awayx">
		<cfset ArrayAppend(aryBSAAdminLink, "data purging")>
		<cfset ArrayAppend(aryBSAAdminFile, "/settings/purge_settings1.cfm?PageTitle=SYSTEM ADMINISTRATION: Data Purging")>
	</cfif>
	<cfif application.returned_customer_setting.show_dataintegration EQ 1>
		<!---<cfif application.deductionLinksAvailable> --->
		<cfif request.settings.Deduction_Module>
			<!------ deduction code ----->
			<cfset ArrayAppend(aryBSAAdminLink, "deduction settings")>
			<cfset ArrayAppend(aryBSAAdminFile, "/Deductions/Settings/Deduction_settings.cfm?PageTitle=Deductions: Deviation Settings")>
		</cfif>
	</cfif>
		<cfset ArrayAppend(aryBSAAdminLink, "feedback log")>
		<cfset ArrayAppend(aryBSAAdminFile, "/administrivia/view_email_log.cfm")>

		<cfset ArrayAppend(aryBSAAdminLink, "manual file modification")>
		<cfset ArrayAppend(aryBSAAdminFile, "/Release_Tracker/manual_modifications_interface.cfm?PageTitle=SYSTEM ADMINISTRATION: Manual File Modification Form")>
	<cfif lcase(application.datasource) EQ "awayx">
		<cfset ArrayAppend(aryBSAAdminLink, "purge queue")>
		<cfset ArrayAppend(aryBSAAdminFile, "/settings/phase_I_log.cfm?PageTitle=SYSTEM ADMINISTRATION: Purge Queue")>
	</cfif>
	<cfif application.returned_customer_setting.show_dataintegration EQ 1>
		<cfset ArrayAppend(aryBSAAdminLink, "price list tool")>
		<cfset ArrayAppend(aryBSAAdminFile, "/Manufacturers/index_1.cfm")>
		<cfif request.AccessStructure.USER_RIGHTS_ID EQ 9999>
			<cfset ArrayAppend(aryBSAAdminLink, "raw data tree view")>
			<cfset ArrayAppend(aryBSAAdminFile, "/settings/utilities/show_tree_from_position_table.cfm")>
		</cfif>
	</cfif>
		<cfset ArrayAppend(aryBSAAdminLink, "view installation report")>
		<cfset ArrayAppend(aryBSAAdminFile, "/Release_Tracker/installation_report.cfm?PageTitle=SYSTEM ADMINISTRATION: Installation Report")>

	<cfif application.returned_customer_setting.show_dataintegration EQ 1>
		<cfset ArrayAppend(aryBSAAdminLink, "view ledger")>
		<cfset ArrayAppend(aryBSAAdminFile, "/billbacks/Check_Book/Index.cfm")>
	</cfif>
		<!--- Comment it, as we dont use these links anymore --->
		<!---
		<cfset ArrayAppend(aryBSAAdminLink, "encrypt tool")>
		<cfset ArrayAppend(aryBSAAdminFile, "/settings/encrypt_tool_form.cfm?PageTitle=Personal Settings: encrypt tool")>
		<a href="/settings/customer_settings/Functional_page.cfm?PageTitle=SYSTEM ADMINISTRATION: Customer Settings"target="mainwindow" onClick="window.parent.frames['toc'].location.href='settings_frame_toc.cfm?subnav=BSAAdmin'">
			customer settings
		</a><br>
		--->

<cfset aryBSAAdmin = aryBSAAdminLink>
<cfset ArraySort(aryBSAAdmin, "textnocase")>
<cfset ListBSAAdmin = ArrayToList(aryBSAAdminLink, ",")>
<cfsavecontent variable="BSAAdmin">
	<cfloop index = "LoopCount" from = "1" to = #ArrayLen(aryBSAAdmin)#>
		<cfset indexList = ListFind(ListBSAAdmin, "#aryBSAAdmin[LoopCount]#")>
		<a href="#aryBSAAdminFile[indexList]#" target="mainwindow" onClick="window.parent.frames['toc'].location.href='settings_frame_toc.cfm?subnav=BSAAdmin'">
		 	 #aryBSAAdminLink[indexList]#
		</a><br>
	</cfloop>
</cfsavecontent>
</cfoutput>

<!--- Generate image tag variables --->
	<cfset geographyImg = "<img border='0' width='24' src='/Images/Control_panel/Brokers_closed.gif'>">
	<cfset projectsImg = "<img border='0' width='24' src='/Images/Control_panel/Projects_closed.gif'>">
	<cfset payablesImg = "<img border='0' width='24' src='/Images/Control_panel/Billbacks_closed.gif'>">
	<cfset programsImg = "<img border='0' width='24' src='/Images/Control_panel/Programs_closed.gif'>">
	<cfset adminImg = "<img border='0' width='24' src='/Images/Control_panel/Administrator_closed.gif'>">
	<cfset plannerImg = "<img border='0' width='24' src='/Images/Control_panel/Planner_closed.gif'>">
	<cfset usersImg = "<img border='0' width='24' src='/Images/Control_panel/Users_closed.gif'>">
	<cfset passwordImg = "<img border='0' width='24' src='/Images/Control_panel/Password_closed.gif'>">
	<cfset BSAImg = " <img border='0' width='24' src='/Images/Control_panel/folder-open.png'>">

<!--- Declare arrays and the list needed for the loop --->
	<cfset linksArray = ArrayNew(1)>
	<cfset imgArray = ArrayNew(1)>
	<cfset categoryList = "">

<!--- Append information to the arrays and list, rearrange the order of these groups to change the display order --->
	<!--- Geography Group --->
	<cfset arrayAppend(linksArray,#geography#)>
	<cfset arrayAppend(imgArray,#geographyImg#)>
	<cfset categoryList = listAppend(categoryList,"Geography",",")>
	<!--- End Geography Group --->
    <cfif appSettings.getShowProjectsScoreCard()>
	<!--- Projects Group --->
	<cfset arrayAppend(linksArray,#projects#)>
	<cfset arrayAppend(imgArray,#projectsImg#)>
	<cfset categoryList = listAppend(categoryList,"Projects",",")>
	<!--- End Projects Group --->
    </cfif>
<!--- Show this only if this user has access --->
	<!--- Payables Group --->
	<!---<cfif application.returned_customer_setting.show_billback IS 1> --->
	<CFIF application.appSettingsGet.getBillback_Module()>
		<cfset arrayAppend(linksArray,#payables#)>
		<cfset arrayAppend(imgArray,#payablesImg#)>
		<cfset categoryList = listAppend(categoryList,"Payables",",")>
	</cfif>
	<!--- End Payables Group --->

	<!--- Programs Group --->
	<cfset arrayAppend(linksArray,#programs#)>
	<cfset arrayAppend(imgArray,#programsImg#)>
	<cfset categoryList = listAppend(categoryList,"Programs",",")>
	<!--- End Programs Group --->

	<!--- Planners Group --->
	<cfif request.settings.Retail_Planner eq '1'>
		<cfset arrayAppend(linksArray,#planner#)>
		<cfset arrayAppend(imgArray,#plannerImg#)>
		<cfset categoryList = listAppend(categoryList,"#Application.PlannerLabel_Plural#",",")>
	</cfif>
	<!--- End Planners Group --->

	<!--- Administration Group --->
	<cfset arrayAppend(linksArray,#administration#)>
	<cfset arrayAppend(imgArray,#adminImg#)>
	<cfset categoryList = listAppend(categoryList,"Administration",",")>
	<!--- End Administration Group --->

	<!--- Users Group --->
	<cfset arrayAppend(linksArray,#users#)>
	<cfset arrayAppend(imgArray,#usersImg#)>
	<cfset categoryList = listAppend(categoryList,"Users",",")>
	<!--- End Users Group --->

	<!--- Password Group --->
	<!--- Dev Note: KAL; 6/16/2010; D21544: LDAP : Remove change password when LDAP is on --->
	<cfif NOT appSettings.getLDAP_SSO_Enabled()>
		<cfset arrayAppend(linksArray,#password#)>
		<cfset arrayAppend(imgArray,#passwordImg#)>
		<cfset categoryList = listAppend(categoryList,"Password",",")>
	</cfif>
	<!--- End Password Group --->

<!--- Show this only if user is a BSA administrator --->
	<!--- BSA Administration Group --->
	<cfif request.AccessStructure.USER_RIGHTS_ID EQ 9999>
		<cfset arrayAppend(linksArray,#BSAAdmin#)>
		<cfset arrayAppend(imgArray,#BSAImg#)>
		<cfset categoryList = listAppend(categoryList,"Admin Tools",",")>
	</cfif>
	<!--- END BSA Administration Group --->

